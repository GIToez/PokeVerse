#!/usr/bin/env python3
"""Writes core/server/data/lib/ps/config/questSteps.lua: where the quest log's Go there leads for the
quests whose next step isn't simply "find that Pokemon" or "go back to the NPC" (lib/ps/systems/075-quests.lua).

- QUEST_STEPS[quest storage] = { step, ... }: the custom quests' own steps, in the order their
  finishing check (questRequest in 003-quest.lua) lists them. A step is done when its storage is
  finished ({ storage = N, ... }) or when the trainer carries the item ({ item = id, count = n, ... }).
- QUEST_ITEM_SOURCES[item id] = { place, ... }: where a quest item comes from when no wild Pokemon
  drops it (those are worked out on the server from the loot): the NPCs that sell or give it, the
  map objects and tiles whose scripts give it, and the chests or floors it lies in.

Each place is { x, y, z, label }. They are found by reading the scripts that set the storage or give
the item and where those scripts are used: the NPCs that run them (data/world/map-spawn.xml), the
map objects they are used on or registered for (data/actions/actions.xml, data/movements/movements.xml,
by item id, action id and unique id in data/world/map.otbm), and the quests whose storage they are.

Needs the real map (git lfs pull). Run it again after changing quests, quest scripts, NPCs or the map:

    python3 scripts/make-quest-steps.py
"""
import collections
import json
import os
import re
import struct
import sys
import xml.etree.ElementTree as ET

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DATA = os.path.join(ROOT, "core/server/data")
OUTPUT = os.path.join(DATA, "lib/ps/config/questSteps.lua")
MAP = os.path.join(DATA, "world/map.otbm")
sys.path.insert(0, os.path.join(ROOT, "scripts/mapper"))
import pvmap  # noqa: E402

RARE = 12  # map items that appear more often than this are scenery, not quest spots


def read(path):
    with open(path, encoding="latin-1") as f:
        return f.read()


# ------------------------------------------------------------------------------------------------
# The map: rare items (also inside containers, at their tile), action ids and unique ids
# ------------------------------------------------------------------------------------------------

def item_attrs(p):
    aid = uid = None
    off = 2
    while off < len(p):
        t = p[off]
        off += 1
        if t == pvmap.A_ACTION_ID:
            aid = struct.unpack_from("<H", p, off)[0]
            off += 2
        elif t == pvmap.A_UNIQUE_ID:
            uid = struct.unpack_from("<H", p, off)[0]
            off += 2
        elif t in (pvmap.A_COUNT, 22):
            off += 1
        elif t in (pvmap.A_RUNE_CHARGES, pvmap.A_DEPOT_ID):
            off += 2
        elif t == pvmap.A_HOUSE_DOOR_ID:
            off += 1
        elif t == pvmap.A_TELE_DEST:
            off += 5
        elif t in (pvmap.A_TEXT, pvmap.A_DESCRIPTION, 7):
            off += 2 + struct.unpack_from("<H", p, off)[0]
        else:
            break
    return aid, uid


def index_map(path):
    if open(path, "rb").read(7) == b"version":
        sys.exit("%s is a Git LFS pointer: run git lfs pull first" % path)
    data = open(path, "rb").read()
    count = collections.Counter()
    items = collections.defaultdict(list)
    aids = collections.defaultdict(list)  # action id -> [(item id, pos)]
    uids = collections.defaultdict(list)
    area = tile = None
    for ev, t, depth, a, b, _ in pvmap.walk(data):
        if ev != "open":
            continue
        if t == pvmap.TILE_AREA:
            area = struct.unpack_from("<HHB", pvmap.unescape(data[a:b]), 0)
        elif t in (pvmap.TILE, pvmap.HOUSETILE):
            p = pvmap.unescape(data[a:b])
            tile = (area[0] + p[0], area[1] + p[1], area[2])
            item = pvmap.parse_tile_props(p, t == pvmap.HOUSETILE)[4]
            if item is not None:
                count[item] += 1
                if count[item] <= RARE:
                    items[item].append(tile)
        elif t == pvmap.ITEM and depth >= 4 and tile:
            p = pvmap.unescape(data[a:b])
            item = struct.unpack_from("<H", p, 0)[0]
            count[item] += 1
            if count[item] <= RARE:
                items[item].append(tile)
            aid, uid = item_attrs(p)
            if aid:
                aids[aid].append((item, tile))
            if uid:
                uids[uid].append((item, tile))
    return {i: v for i, v in items.items() if count[i] <= RARE}, aids, uids


# ------------------------------------------------------------------------------------------------
# Names, NPCs, registrations
# ------------------------------------------------------------------------------------------------

def item_names():
    names = {}
    for m in re.finditer(r"<item\s+([^>]*)>", read(os.path.join(DATA, "items/items.xml"))):
        attrs = m.group(1)
        name = re.search(r'name="([^"]*)"', attrs)
        if not name:
            continue
        one = re.search(r'\bid="(\d+)"', attrs)
        if one:
            names[int(one.group(1))] = name.group(1)
            continue
        lo, hi = re.search(r'fromid="(\d+)"', attrs), re.search(r'toid="(\d+)"', attrs)
        if lo and hi:
            for i in range(int(lo.group(1)), int(hi.group(1)) + 1):
                names[i] = name.group(1)
    return names


def spawns():
    """NPC and monster name -> [positions] from map-spawn.xml (x, y are offsets, z is the floor)."""
    npcs, monsters = collections.defaultdict(list), collections.defaultdict(list)
    for spawn in ET.parse(os.path.join(DATA, "world/map-spawn.xml")).getroot().iter("spawn"):
        cx, cy = int(spawn.get("centerx")), int(spawn.get("centery"))
        for kind, out in (("npc", npcs), ("monster", monsters)):
            for c in spawn.iter(kind):
                out[c.get("name")].append((cx + int(c.get("x")), cy + int(c.get("y")), int(c.get("z"))))
    return npcs, monsters


def id_list(text):
    """'12-14;20' -> [12, 13, 14, 20]"""
    out = []
    for part in (text or "").split(";"):
        part = part.strip()
        if "-" in part:
            lo, hi = part.split("-", 1)
            if lo.isdigit() and hi.isdigit() and int(hi) - int(lo) < 2000:
                out.extend(range(int(lo), int(hi) + 1))
        elif part.isdigit():
            out.append(int(part))
    return out


def registrations():
    """script path -> {'itemid': [...], 'actionid': [...], 'uniqueid': [...], 'kind': ...}"""
    regs = collections.defaultdict(lambda: collections.defaultdict(list))
    for kind, xml, base in (("action", "actions/actions.xml", "actions/scripts"),
                            ("movement", "movements/movements.xml", "movements/scripts")):
        text = read(os.path.join(DATA, xml))
        for m in re.finditer(r"<(?:action|movevent|movement)\s([^>]*)/?>", text):
            attrs = dict(re.findall(r'(\w+)="([^"]*)"', m.group(1)))
            value = attrs.get("value") or attrs.get("script")
            if not value:
                continue
            path = os.path.normpath(os.path.join(DATA, base, value))
            regs[path]["kind"] = kind
            for key in ("itemid", "actionid", "uniqueid"):
                regs[path][key].extend(id_list(attrs.get(key)))
            for key, alias in (("fromid", "itemid"), ("fromaid", "actionid"), ("fromuid", "uniqueid")):
                if key in attrs:
                    hi = attrs.get(key.replace("from", "to"))
                    regs[path][alias].extend(id_list("%s-%s" % (attrs[key], hi or attrs[key])))
    return regs


def npc_scripts():
    """npc script path -> [npc names]"""
    out = collections.defaultdict(list)
    for name in os.listdir(os.path.join(DATA, "npc")):
        if name.endswith(".xml"):
            m = re.search(r'<npc\s[^>]*name="([^"]+)"[^>]*script="([^"]+)"', read(os.path.join(DATA, "npc", name)))
            if m:
                out[os.path.normpath(os.path.join(DATA, "npc/scripts", m.group(2)))].append(m.group(1))
    return out


def death_scripts():
    """creature script path -> [monster names that carry its event]"""
    events = {}
    text = read(os.path.join(DATA, "creaturescripts/creaturescripts.xml"))
    for m in re.finditer(r'<event\s[^>]*name="([^"]+)"[^>]*value="([^"]+)"', text):
        events[m.group(1)] = os.path.normpath(os.path.join(DATA, "creaturescripts/scripts", m.group(2)))
    out = collections.defaultdict(list)
    for d, _, files in os.walk(os.path.join(DATA, "monster")):
        for f in files:
            if f.endswith(".xml"):
                t = read(os.path.join(d, f))
                name = re.search(r'<monster[^>]*name="([^"]+)"', t)
                for ev in re.findall(r'<event\s+name="([^"]+)"', t):
                    if name and ev in events:
                        out[events[ev]].append(name.group(1))
    return out


# ------------------------------------------------------------------------------------------------
# The quests
# ------------------------------------------------------------------------------------------------

def quests():
    """[(npc, storage, quest type, questRequest text, startPosition, finishPosition)]"""
    lines = read(os.path.join(DATA, "lib/ps/config/003-quest.lua")).split("\n")
    out, npc, cur = [], None, None
    for i, line in enumerate(lines):
        m = re.match(r'\s{4}\["([^"]+)"\]\s*=\s*\{', line)
        if m:
            npc = m.group(1)
        m = re.match(r"\s{12}storage\s*=\s*(\d+)", line)
        if m:
            cur = {"npc": npc, "storage": int(m.group(1)), "type": None, "request": "", "start": None, "finish": None, "startItems": set()}
            out.append(cur)
        if cur is None:
            continue
        m = re.match(r"\s{12}questType\s*=\s*QUEST_TYPE\.(\w+)", line)
        if m:
            cur["type"] = m.group(1)
        m = re.match(r"\s{12}(start|finish)Position\s*=\s*\{\s*x\s*=\s*(\d+),\s*y\s*=\s*(\d+),\s*z\s*=\s*(\d+)", line)
        if m:
            cur[m.group(1)] = tuple(int(v) for v in m.groups()[1:])
        m = re.match(r"\s{12}questStartItems\s*=\s*\{([^}]*)\}", line)
        if m:
            nums = [int(x) for x in re.findall(r"\d+", m.group(1))]
            cur["startItems"] = set(nums[0::2])
        if re.match(r"\s{12}questRequest\s*=", line):
            text, j = line, i
            if "function" in line:
                depth = 0
                while True:
                    t = re.sub(r"--.*", "", lines[j])
                    depth += len(re.findall(r"\bfunction\b|\bthen\b|\bdo\b", t)) - len(re.findall(r"\bend\b", t))
                    depth -= len(re.findall(r"\belseif\b", t))  # elseif ... then opens nothing new
                    if j > i:
                        text += "\n" + lines[j]
                    if depth <= 0 or j - i > 60:
                        break
                    j += 1
            cur["request"] = text
    return out


# ------------------------------------------------------------------------------------------------
# Finding where a storage is set or an item is given
# ------------------------------------------------------------------------------------------------

class Finder:
    def __init__(self):
        print("indexing the map...", file=sys.stderr)
        self.items, self.aids, self.uids = index_map(MAP)
        self.names = item_names()
        self.npcs, self.monsters = spawns()
        self.regs = registrations()
        self.npc_scripts = npc_scripts()
        self.death_scripts = death_scripts()
        self.quests = quests()
        self.by_storage = {q["storage"]: q for q in self.quests}
        self.scripts = {}
        for d, _, files in os.walk(DATA):
            for f in files:
                if f.endswith(".lua") and f != "003-quest.lua" and "/disabled" not in d:
                    p = os.path.normpath(os.path.join(d, f))
                    self.scripts[p] = read(p)
        # NPCs the scripts put on the map themselves (holiday events): ["Calico"] = { x = 5853, ... },
        # doCreateNpc("Name", { x = ... })
        pos_re = r"\{\s*x\s*=\s*(\d+)\s*,\s*y\s*=\s*(\d+)\s*,\s*z\s*=\s*(\d+)\s*\}"
        for text in self.scripts.values():
            for name, x, y, z in re.findall(r'\["([^"]+)"\]\s*=\s*' + pos_re, text) + \
                    re.findall(r'doCreateNpc\(\s*"([^"]+)"\s*,\s*' + pos_re, text):
                if name not in self.npcs or not self.npcs[name]:
                    self.npcs.setdefault(name, [])
                    self.npcs[name].append((int(x), int(y), int(z)))
        self.unresolved = []

    def name(self, item):
        return self.names.get(item) or "item %d" % item

    def npc_places(self, npc, label=None):
        return [(p, label or "Talk to %s" % npc) for p in self.npcs.get(npc, [])]

    def quest_place(self, storage):
        q = self.by_storage[storage]
        pos = q["start"] or q["finish"]
        if pos:
            return [(pos, "Talk to %s" % q["npc"])]
        return self.npc_places(q["npc"])

    def blocks(self, text, number):
        """The `[key] = function ... end` blocks (activation tiles, item tables) that mention number."""
        keys = []
        for m in re.finditer(r"^\s*\[(\d+)\]\s*=\s*function\b", text, re.M):
            body = text[m.end():]
            nxt = re.search(r"^\s*\[\d+\]\s*=\s*function\b", body, re.M)
            if re.search(r"\b%d\b" % number, body[:nxt.start()] if nxt else body):
                keys.append(int(m.group(1)))
        return keys

    def tool(self, reg):
        """The item the trainer uses, for a script registered on items that aren't map objects."""
        tools = [i for i in (reg or {}).get("itemid", []) if i not in self.items]
        return ("the %s" % self.name(tools[0])) if len(tools) == 1 else None

    def from_script(self, path, number, setter_re, label_item=None):
        """Places where the script at path, which sets/gives number, is used."""
        text = self.scripts[path]
        places = []
        tool = self.tool(self.regs.get(path))
        use = ("Use %s" % tool) if tool else "Use it"
        here = label_item or ("%s here" % use if tool else "Go here")
        # an NPC that runs it
        for npc in self.npc_scripts.get(path, []):
            places += self.npc_places(npc)
        # a monster whose death runs it
        for monster in self.death_scripts.get(path, []):
            places += [(p, "Defeat %s" % monster) for p in self.monsters.get(monster, [])]
        # a position written next to the number: { pos = { x = 3288, y = 259, z = 7 }, storage = 8424 }
        for line in text.split("\n"):
            if re.search(r"\b%d\b" % number, line):
                for x, y, z in re.findall(r"x\s*=\s*(\d+)\s*,\s*y\s*=\s*(\d+)\s*,\s*z\s*=\s*(\d+)", line):
                    places.append(((int(x), int(y), int(z)), here))
        reg = self.regs.get(path)
        if reg and not places:
            # registered per action or unique id, with a block per id: only the block that sets it
            keys = self.blocks(text, number)
            for key in keys:
                for item, pos in self.aids.get(key, []) + self.uids.get(key, []):
                    if not reg["itemid"] or item in reg["itemid"] or key in reg["actionid"] + reg["uniqueid"]:
                        places.append((pos, here))
            if not keys:
                for key in reg["actionid"]:
                    places += [(pos, here) for _, pos in self.aids.get(key, [])]
                for key in reg["uniqueid"]:
                    places += [(pos, here) for _, pos in self.uids.get(key, [])]
            # the script checks the object it is used on: itemEx.actionid ~= 100 (with itemEx.itemid ~= 804)
            if not places:
                ex_ids = [int(x) for x in re.findall(r"itemEx\.itemid\s*[~=]=\s*(\d+)", text)]
                for key in re.findall(r"itemEx\.actionid\s*[~=]=\s*(\d+)", text):
                    places += [(pos, here) for item, pos in self.aids.get(int(key), []) if not ex_ids or item in ex_ids]
                for key in re.findall(r"itemEx\.(?:uid|uniqueid)\s*[~=]=\s*(\d+)", text):
                    places += [(pos, label_item or "Here") for _, pos in self.uids.get(int(key), [])]
            # used on a named NPC or creature (the Sleeping Tauros, Courts Ted's Machop): the names on the
            # number's own line first (a name -> storage table), else every name the script compares
            if not places and "itemEx" in text:
                def named(names):
                    out = []
                    for name in names:
                        for p in self.npcs.get(name, []) or self.monsters.get(name, [])[:3]:
                            out.append((p, label_item or "%s on %s" % (use, name)))
                    return out
                lines_with = [l for l in text.split("\n") if re.search(r"\b%d\b" % number, l)]
                places += named([n for l in lines_with for n in re.findall(r'"([^"]{3,40})"', l)])
                if not places:
                    places += named(re.findall(r'"([^"]{3,40})"', text))
            # a tool used on map objects (Gary Oak's magnifier on the bushes): the objects named on the
            # same line as the number (an item -> storage table), else every rare map object the script names
            if not places:
                same_line = []
                for line in text.split("\n"):
                    if re.search(r"\b%d\b" % number, line):
                        same_line += [int(x) for x in re.findall(r"\b(\d{3,5})\b", line) if int(x) != number]
                targets = [i for i in same_line if i in self.items] or \
                          [int(x) for x in set(re.findall(r"\b(\d{3,5})\b", text)) if int(x) in self.items and int(x) != number]
                for item in targets:
                    places += [(p, label_item or "%s on the %s" % (use, self.name(item))) for p in self.items[item]]
                # objects registered for the script itself and placed on the map (a lever, a statue)
                if not places:
                    for item in reg["itemid"]:
                        places += [(p, label_item or "The %s" % self.name(item)) for p in self.items.get(item, [])]
        return places

    def sets(self, text, number, calls):
        """True when the script sets/gives number: in one of the calls, through a local holding it, or in a
        table the script feeds them from (a number that only appears in checks doesn't count)."""
        if not re.search(r"\b%d\b" % number, text):
            return False
        names = [str(number)] + re.findall(r"\blocal\s+(\w+)\s*=\s*%d\b" % number, text) + \
            re.findall(r"^\s*(\w+)\s*=\s*%d\b" % number, text, re.M)
        for name in names:
            if re.search(r"(?:%s)\(\s*[\w.]+\s*,\s*%s\b" % (calls, re.escape(name)), text):
                return True
        if not re.search(r"(?:%s)\(" % calls, text):
            return False
        # tables: [23535] = 8415, { 8241, ... }, storage = 8241
        for line in text.split("\n"):
            if re.search(r"\b%d\b" % number, line) and not re.search(r"getCreatureStorage|getPlayerStorageValue|getPlayerItemCount|RemoveItem", line):
                if re.search(r"=\s*%d\b|\[\s*%d\s*\]|\{\s*%d\b|,\s*%d\s*[,}]" % (number, number, number, number), line):
                    return True
        return False

    def battle_places(self, battle):
        """getPlayerDefeatedNPC(cid, id): the NPC whose script makes NpcBattle:new(name, x, id, ...)."""
        places = []
        for path, text in self.scripts.items():
            m = re.search(r"NpcBattle:new\([^,]+,\s*[\w.]+\s*,\s*%d\b" % battle, text)
            if m:
                for npc in self.npc_scripts.get(path, []):
                    places += self.npc_places(npc, "Battle %s" % npc)
        return places

    def storage_places(self, storage):
        if storage in self.by_storage:
            return self.quest_place(storage)
        places = []
        for path, text in self.scripts.items():
            if self.sets(text, storage, r"doCreatureSetStorage|setPlayerStorageValue|doCreatureIncreaseStorage|doPlayerIncreaseStorage"):
                places += self.from_script(path, storage, None)
        return places

    def item_places(self, item, depth=0):
        places = []
        for path, text in self.scripts.items():
            if self.sets(text, item, r"doPlayerAddItem|doPlayerSafeAddItem|doPlayerAddUniqueItem|doCreateItemEx|"
                                     r"doAddContainerItem|doPlayerAddItemEx|setRewardItems"):
                if re.search(r"NpcBattle:new", text):
                    found = []
                    for npc in self.npc_scripts.get(path, []):
                        found += self.npc_places(npc, "Battle %s for the %s" % (npc, self.name(item)))
                else:
                    found = self.from_script(path, item, None, "Get the %s" % self.name(item))
                # made from something the trainer carries (onigiri sauce -> seasoned onigiri): where that comes from
                reg = self.regs.get(path)
                if not found and reg and depth < 2:
                    for tool in reg["itemid"][:3]:
                        if tool != item:
                            found += [(p, "Get the %s (for the %s)" % (self.name(tool), self.name(item)))
                                      for p, _ in self.item_places(tool, depth + 1)]
                places += found
        # NPC shops
        for name in os.listdir(os.path.join(DATA, "npc")):
            if name.endswith(".xml"):
                t = read(os.path.join(DATA, "npc", name))
                shop = re.search(r'key="shop_(?:buyable|sellable)"\s+value="([^"]*)"', t, re.S)
                npc = re.search(r'<npc\s[^>]*name="([^"]+)"', t)
                if shop and npc and re.search(r",\s*%d\s*," % item, shop.group(1)):
                    places += self.npc_places(npc.group(1), "Buy it from %s" % npc.group(1))
        # lying on the map, in a chest or on the floor
        if not places and item in self.items:
            places += [(p, "The %s is here" % self.name(item)) for p in self.items[item]]
        return places


def dedupe(places, limit=8):
    seen, out = set(), []
    for pos, label in places:
        if pos not in seen:
            seen.add(pos)
            out.append((pos, label))
    return out[:limit]


def lua_places(places):
    return ", ".join('{ x = %d, y = %d, z = %d, label = "%s" }' % (p[0], p[1], p[2], label.replace('"', "'"))
                     for p, label in places)


def main():
    f = Finder()
    dropped = set()
    for d, _, files in os.walk(os.path.join(DATA, "monster")):
        for name in files:
            if name.endswith(".xml"):
                t = read(os.path.join(d, name))
                if "<loot" in t:
                    dropped.update(int(x) for x in re.findall(r'<item id="(\d+)"', t.split("<loot", 1)[1]))
    steps, sources, report = {}, {}, collections.defaultdict(list)
    wanted_items = set()
    for q in f.quests:
        req = q["request"]
        if q["type"] == "BRING_ITEMS":
            m = re.search(r"questRequest\s*=\s*\{([^}]*)\}", req)
            nums = [int(x) for x in re.findall(r"\d+", re.sub(r"--.*", "", m.group(1)))] if m else []
            wanted_items.update(nums[0::2])
        elif q["type"] == "CUSTOM" and "function" in req:
            body = re.sub(r"--.*", "", req)
            out = []
            # storages: direct, at least a count, or a list/range the check loops over with a variable
            checks = [(int(n), int(c) if c else None) for n, c in
                      re.findall(r"getCreatureStorage\(\s*cid\s*,\s*(\d+)\s*\)\s*(?:>=\s*(\d+))?", body)]
            if re.search(r"getCreatureStorage\(\s*cid\s*,\s*[a-zA-Z_]\w*\s*\)", body):
                for table in re.findall(r"\{([\d\s,]+)\}", body):
                    checks += [(int(n), None) for n in re.findall(r"\d+", table)]
                for lo, hi in re.findall(r"for\s+\w+\s*=\s*(\d+)\s*,\s*(\d+)\s+do", body):
                    checks += [(n, None) for n in range(int(lo), int(hi) + 1)]
            for s, at_least in checks:
                if s == q["storage"] or any(st.get("storage") == s for st in out):
                    continue
                places = dedupe(f.storage_places(s))
                if places:
                    step = {"storage": s, "places": places}
                    if at_least:
                        step["atLeast"] = at_least
                    out.append(step)
                else:
                    report["no place for storage"].append("%s %d: storage %d" % (q["npc"], q["storage"], s))
            # NPC battles
            battles = [int(n) for n in re.findall(r"getPlayerDefeatedNPC\(\s*cid\s*,\s*(\d+)\s*\)", body)]
            if re.search(r"getPlayerDefeatedNPC\(\s*cid\s*,\s*[a-zA-Z_]\w*\s*\)", body):
                for lo, hi in re.findall(r"for\s+\w+\s*=\s*(\d+)\s*,\s*(\d+)\s+do", body):
                    battles += list(range(int(lo), int(hi) + 1))
            for b in battles:
                places = dedupe(f.battle_places(b))
                if places:
                    out.append({"battle": b, "places": places})
                else:
                    report["no place for battle"].append("%s %d: battle %d" % (q["npc"], q["storage"], b))
            # items: getPlayerItemCount(cid, id) >= n, or { id = X, count = N } lists
            wanted = re.findall(r"getPlayerItemCount\(\s*cid\s*,\s*(\d+)\s*\)\s*(?:>=\s*(\d+)|>\s*0)?", body)
            wanted += re.findall(r"\{\s*id\s*=\s*(\d+)\s*,\s*count\s*=\s*(\d+)", body)
            for item, count in wanted:
                item = int(item)
                if item in q["startItems"] or any(st.get("item") == item for st in out):
                    continue  # the quest gives it when it starts
                places = dedupe(f.item_places(item))
                if places:
                    out.append({"item": item, "count": int(count or 1), "places": places})
                elif item not in dropped:
                    report["no place for item"].append("%s %d: %s" % (q["npc"], q["storage"], f.name(item)))
                else:
                    out.append({"item": item, "count": int(count or 1), "drop": True})
            if out:
                steps[q["storage"]] = out
            else:
                report["custom quest without steps"].append("%s %d" % (q["npc"], q["storage"]))
    for item in sorted(wanted_items):
        if item in dropped:
            continue  # the server finds who drops it
        places = dedupe(f.item_places(item))
        if places:
            sources[item] = places
        else:
            report["no place for item"].append("bring %s" % f.name(item))

    lines = [
        "-- Written by scripts/make-quest-steps.py from the quests, their scripts, the NPCs and the map. Don't edit:",
        "-- run it again after changing them. Where the quest log's Go there leads (lib/ps/systems/075-quests.lua).",
        "",
        "-- the custom quests' steps, in the order their finishing check lists them",
        "QUEST_STEPS = {",
    ]
    for storage in sorted(steps):
        q = f.by_storage[storage]
        lines.append("    [%d] = { -- %s" % (storage, q["npc"]))
        for st in steps[storage]:
            if "storage" in st:
                key = "storage = %d" % st["storage"] + (", atLeast = %d" % st["atLeast"] if st.get("atLeast") else "")
            elif "battle" in st:
                key = "battle = %d" % st["battle"]
            else:
                key = "item = %d, count = %d" % (st["item"], st["count"])
            if st.get("drop"):
                lines.append("        { %s, drop = true }, -- %s" % (key, f.name(st["item"])))
            else:
                lines.append("        { %s, places = { %s } }," % (key, lua_places(st["places"])))
        lines.append("    },")
    lines += ["}", "", "-- where a quest item comes from when no wild Pokemon drops it", "QUEST_ITEM_SOURCES = {"]
    for item in sorted(sources):
        lines.append("    [%d] = { %s }, -- %s" % (item, lua_places(sources[item]), f.name(item)))
    lines += ["}", ""]
    with open(OUTPUT, "w", encoding="latin-1") as out:
        out.write("\n".join(lines))
    print("%d quests with steps, %d quest items with a source -> %s" % (len(steps), len(sources), os.path.relpath(OUTPUT, ROOT)))
    for kind, rows in report.items():
        print("%s: %d" % (kind, len(rows)))
        for row in rows:
            print("    " + row)


if __name__ == "__main__":
    main()
