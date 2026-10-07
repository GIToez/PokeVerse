#!/usr/bin/env python3
"""Read-only audit of the OTBM world map, spawns, houses, monsters and NPCs.

Usage (from the repository root):
    python3 tools/map_audit.py [--data server/runtime-data/data] [--output FILE]

Prints a Markdown statistics report to stdout (or writes it to --output).
Standard library only.
"""
import argparse
import collections
import glob
import os
import re
import struct
import sys
import time
import xml.etree.ElementTree as ET

NODE_ESC, NODE_START, NODE_END = 0xFD, 0xFE, 0xFF

OTBM_ROOT, OTBM_MAP_DATA, OTBM_TILE_AREA, OTBM_TILE, OTBM_ITEM = 0, 2, 4, 5, 6
OTBM_TOWNS, OTBM_TOWN, OTBM_HOUSETILE, OTBM_WAYPOINTS, OTBM_WAYPOINT = 12, 13, 14, 15, 16

ATTR_DESCRIPTION, ATTR_TILE_FLAGS, ATTR_ITEM = 1, 3, 9
ATTR_EXT_SPAWN_FILE, ATTR_EXT_HOUSE_FILE = 11, 13

TILESTATE_PROTECTIONZONE = 0x01
ITEM_GROUP_GROUND = 1

_SPECIAL = re.compile(b"[\xfd\xfe\xff]")


def walk_nodes(buf, start, on_data, on_end):
    """Stream a node tree. on_data(type, data, stack) fires once per node with
    its own (unescaped) payload; on_end(type, stack) fires when it closes.
    `stack` is a list of per-node dicts ({'type': t, ...}) usable as scratch."""
    stack = []
    chunks = []
    pos = start
    search = _SPECIAL.search
    n = len(buf)
    while pos < n:
        m = search(buf, pos)
        if m is None:
            break
        i = m.start()
        c = buf[i]
        if c == NODE_ESC:
            chunks.append(buf[pos:i])
            chunks.append(buf[i + 1:i + 2])
            pos = i + 2
            continue
        if stack and not stack[-1]["_done"]:
            chunks.append(buf[pos:i])
            top = stack[-1]
            top["_done"] = True
            on_data(top["type"], b"".join(chunks), stack)
        chunks = []
        if c == NODE_START:
            stack.append({"type": buf[i + 1], "_done": False})
            pos = i + 2
        else:
            if not stack:
                raise ValueError("unbalanced node end at offset %d" % i)
            on_end(stack[-1]["type"], stack)
            stack.pop()
            pos = i + 1
            if not stack:
                return pos
    if stack:
        raise ValueError("unterminated node tree (depth %d)" % len(stack))
    return pos


def read_str(data, p):
    (ln,) = struct.unpack_from("<H", data, p)
    return data[p + 2:p + 2 + ln].decode("latin-1"), p + 2 + ln


# ---------------------------------------------------------------- items.otb
def parse_items_otb(path):
    with open(path, "rb") as f:
        buf = f.read()
    info = {"version": None, "groups": {}}

    def on_data(t, data, stack):
        if len(stack) == 1:
            p = 4  # flags
            while p + 3 <= len(data):
                attr = data[p]
                (ln,) = struct.unpack_from("<H", data, p + 1)
                if attr == 0x01 and ln >= 12:
                    info["version"] = struct.unpack_from("<III", data, p + 3)
                p += 3 + ln
        elif len(stack) == 2:
            p = 4
            while p + 3 <= len(data):
                attr = data[p]
                (ln,) = struct.unpack_from("<H", data, p + 1)
                if attr == 0x10 and ln == 2:
                    (sid,) = struct.unpack_from("<H", data, p + 3)
                    info["groups"][sid] = t
                    break
                p += 3 + ln

    walk_nodes(buf, 4, on_data, lambda t, s: None)
    return info


# --------------------------------------------------------------------- OTBM
class MapStats:
    def __init__(self):
        self.header = {}
        self.descriptions = []
        self.spawn_file = None
        self.house_file = None
        self.tiles = 0
        self.house_tiles = 0
        self.pz_tiles = 0
        self.no_items = 0
        self.no_ground = 0
        self.floor_counts = collections.Counter()
        self.minx = self.miny = 1 << 30
        self.maxx = self.maxy = -1
        self.positions = set()
        self.house_tile_ids = collections.Counter()
        self.towns = []
        self.waypoints = []
        self.warnings = []
        self.duplicate_tiles = 0


def parse_otbm(path, ground_ids):
    with open(path, "rb") as f:
        buf = f.read()
    ms = MapStats()
    ident = buf[:4]
    ms.header["identifier"] = ident.decode("latin-1") if ident == b"OTBM" else ident.hex()
    if ident not in (b"\0\0\0\0", b"OTBM"):
        ms.warnings.append("unexpected file identifier %r" % ident)
    area = [0, 0, 0]

    def on_data(t, data, stack):
        parent = stack[-2]["type"] if len(stack) > 1 else None
        if len(stack) == 1:
            if len(data) >= 16:
                v, w, h, ma, mi = struct.unpack_from("<IHHII", data, 0)
                ms.header.update(version=v, width=w, height=h, items_major=ma, items_minor=mi)
            else:
                ms.warnings.append("root node payload too short (%d bytes)" % len(data))
        elif t == OTBM_MAP_DATA and len(stack) == 2:
            p = 0
            while p < len(data):
                attr = data[p]
                if attr in (ATTR_DESCRIPTION, ATTR_EXT_SPAWN_FILE, ATTR_EXT_HOUSE_FILE):
                    s, p = read_str(data, p + 1)
                    if attr == ATTR_DESCRIPTION:
                        ms.descriptions.append(s)
                    elif attr == ATTR_EXT_SPAWN_FILE:
                        ms.spawn_file = s
                    else:
                        ms.house_file = s
                else:
                    ms.warnings.append("unknown MAP_DATA attribute %d" % attr)
                    break
        elif t == OTBM_TILE_AREA:
            area[0], area[1], area[2] = struct.unpack_from("<HHB", data, 0)
        elif t in (OTBM_TILE, OTBM_HOUSETILE) and parent == OTBM_TILE_AREA:
            x = area[0] + data[0]
            y = area[1] + data[1]
            z = area[2]
            p = 2
            frame = stack[-1]
            frame.update(x=x, y=y, z=z, flags=0, items=0, ground=False, house=None)
            if t == OTBM_HOUSETILE:
                (frame["house"],) = struct.unpack_from("<I", data, p)
                p += 4
            while p < len(data):
                attr = data[p]
                if attr == ATTR_TILE_FLAGS:
                    (frame["flags"],) = struct.unpack_from("<I", data, p + 1)
                    p += 5
                elif attr == ATTR_ITEM:
                    (iid,) = struct.unpack_from("<H", data, p + 1)
                    frame["items"] += 1
                    if iid in ground_ids:
                        frame["ground"] = True
                    p += 3
                else:
                    ms.warnings.append("unknown tile attribute %d at %d,%d,%d" % (attr, x, y, z))
                    break
        elif t == OTBM_ITEM and parent in (OTBM_TILE, OTBM_HOUSETILE):
            tile = stack[-2]
            tile["items"] += 1
            if len(data) >= 2 and struct.unpack_from("<H", data, 0)[0] in ground_ids:
                tile["ground"] = True
        elif t == OTBM_TOWN:
            (tid,) = struct.unpack_from("<I", data, 0)
            name, p = read_str(data, 4)
            tx, ty, tz = struct.unpack_from("<HHB", data, p)
            ms.towns.append((tid, name, tx, ty, tz))
        elif t == OTBM_WAYPOINT:
            name, p = read_str(data, 0)
            wx, wy, wz = struct.unpack_from("<HHB", data, p)
            ms.waypoints.append((name, wx, wy, wz))

    def on_end(t, stack):
        if t not in (OTBM_TILE, OTBM_HOUSETILE) or "x" not in stack[-1]:
            return
        f = stack[-1]
        x, y, z = f["x"], f["y"], f["z"]
        key = x | (y << 16) | (z << 32)
        if key in ms.positions:
            ms.duplicate_tiles += 1
            return
        ms.positions.add(key)
        ms.tiles += 1
        ms.floor_counts[z] += 1
        if x < ms.minx: ms.minx = x
        if x > ms.maxx: ms.maxx = x
        if y < ms.miny: ms.miny = y
        if y > ms.maxy: ms.maxy = y
        if f["house"] is not None:
            ms.house_tiles += 1
            ms.house_tile_ids[f["house"]] += 1
        if f["flags"] & TILESTATE_PROTECTIONZONE:
            ms.pz_tiles += 1
        if f["items"] == 0:
            ms.no_items += 1
        if not f["ground"]:
            ms.no_ground += 1

    walk_nodes(buf, 4, on_data, on_end)
    return ms


# ---------------------------------------------------------------- XML data
def parse_xml(path):
    with open(path, "rb") as f:
        raw = f.read()
    try:
        return ET.fromstring(raw)
    except ET.ParseError:
        return ET.fromstring(raw.decode("latin-1").encode("utf-8").replace(b'encoding="ISO-8859-1"', b""))


def load_houses(path):
    houses = []
    for h in parse_xml(path).iter("house"):
        houses.append({
            "id": int(h.get("houseid")),
            "name": h.get("name"),
            "town": int(h.get("townid", 0)),
            "size": int(h.get("size", 0) or 0),
            "entry": (int(h.get("entryx")), int(h.get("entryy")), int(h.get("entryz"))),
        })
    return houses


def load_spawns(path):
    zones = []
    for s in parse_xml(path).iter("spawn"):
        cx, cy, cz = int(s.get("centerx")), int(s.get("centery")), int(s.get("centerz"))
        mons, npcs = [], []
        zdiff = 0
        for child in s:
            if child.get("z") is not None and int(child.get("z")) != cz:
                zdiff += 1
            entry = (child.get("name"), cx + int(child.get("x", 0)), cy + int(child.get("y", 0)), cz)
            if child.tag == "monster":
                mons.append(entry)
            elif child.tag == "npc":
                npcs.append(entry)
        zones.append({"center": (cx, cy, cz), "radius": int(s.get("radius", 0)), "monsters": mons, "npcs": npcs,
                      "zdiff": zdiff})
    return zones


def load_monsters(data_dir):
    names = {}
    missing_files = []
    root = parse_xml(os.path.join(data_dir, "monster", "monsters.xml"))
    for m in root.iter("monster"):
        name, fn = m.get("name"), m.get("file")
        names[name.lower()] = name
        if fn and not os.path.isfile(os.path.join(data_dir, "monster", fn)):
            missing_files.append((name, fn))
    return names, missing_files


def load_npcs(data_dir):
    by_file, by_attr = set(), set()
    bad = []
    for path in glob.glob(os.path.join(data_dir, "npc", "*.xml")):
        by_file.add(os.path.splitext(os.path.basename(path))[0].lower())
        try:
            n = parse_xml(path)
            if n.get("name"):
                by_attr.add(n.get("name").lower())
        except ET.ParseError:
            with open(path, "rb") as f:
                m = re.search(rb'<npc[^>]*\sname="([^"]*)"', f.read())
            if m:
                by_attr.add(m.group(1).decode("latin-1").lower())
            else:
                bad.append(os.path.basename(path))
    return by_file, by_attr, bad


# ------------------------------------------------------------------ report
def ascii_density(ms, z, cols=96):
    xs, ys = ms.maxx - ms.minx + 1, ms.maxy - ms.miny + 1
    cell = max(1, -(-xs // cols))
    rows = -(-ys // cell)
    grid = [[0] * cols for _ in range(rows)]
    mask = (1 << 16) - 1
    for key in ms.positions:
        if (key >> 32) != z:
            continue
        x, y = key & mask, (key >> 16) & mask
        grid[(y - ms.miny) // cell][(x - ms.minx) // cell] += 1
    full = cell * cell
    ramp = " .:-=+*#%@"
    lines = []
    for row in grid:
        lines.append("".join(ramp[0] if v == 0 else ramp[min(9, 1 + v * 9 // (full + 1))] for v in row).rstrip())
    while lines and not lines[-1]:
        lines.pop()
    return cell, lines


def table(headers, rows):
    out = ["| " + " | ".join(headers) + " |", "|" + "|".join("---" for _ in headers) + "|"]
    out += ["| " + " | ".join(str(c) for c in r) + " |" for r in rows]
    return "\n".join(out)


def main():
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("--data", default="server/runtime-data/data")
    ap.add_argument("--output")
    args = ap.parse_args()
    d = args.data
    t0 = time.time()

    otb = parse_items_otb(os.path.join(d, "items", "items.otb"))
    ground_ids = {sid for sid, g in otb["groups"].items() if g == ITEM_GROUP_GROUND}
    ms = parse_otbm(os.path.join(d, "world", "map.otbm"), ground_ids)
    houses = load_houses(os.path.join(d, "world", "map-house.xml"))
    zones = load_spawns(os.path.join(d, "world", "map-spawn.xml"))
    monster_names, missing_monster_files = load_monsters(d)
    npc_files, npc_attrs, bad_npcs = load_npcs(d)
    elapsed = time.time() - t0

    o = []
    w = o.append
    h = ms.header
    w("## OTBM header\n")
    w(table(["Field", "Value"], [
        ("File identifier", h.get("identifier")),
        ("OTBM version", h.get("version")),
        ("Declared width x height", "%s x %s" % (h.get("width"), h.get("height"))),
        ("items.otb version referenced by map (major.minor)", "%s.%s" % (h.get("items_major"), h.get("items_minor"))),
        ("items.otb on disk (major.minor.build)", ".".join(map(str, otb["version"])) if otb["version"] else "?"),
        ("Description strings", "<br>".join(repr(s) for s in ms.descriptions) or "(none)"),
        ("Spawn file", ms.spawn_file), ("House file", ms.house_file),
    ]))

    w("\n## Tiles\n")
    w(table(["Metric", "Value"], [
        ("X range (actual)", "%d .. %d" % (ms.minx, ms.maxx)),
        ("Y range (actual)", "%d .. %d" % (ms.miny, ms.maxy)),
        ("Occupied tiles", "{:,}".format(ms.tiles)),
        ("House tiles", "{:,}".format(ms.house_tiles)),
        ("Protection-zone tiles (flag 0x01)", "{:,}".format(ms.pz_tiles)),
        ("Tiles without a ground-group item", "{:,}".format(ms.no_ground)),
        ("...of which tiles with no items at all", "{:,}".format(ms.no_items)),
        ("Duplicate tile positions (ignored)", ms.duplicate_tiles),
    ]))
    w("\nTiles per floor:\n")
    w(table(["z", "Tiles"], [(z, "{:,}".format(c)) for z, c in sorted(ms.floor_counts.items())]))

    w("\n## Towns (OTBM TOWNS node)\n")
    w(table(["ID", "Name", "Temple (x, y, z)", "Temple tile exists"],
            [(t, n, "%d, %d, %d" % (x, y, z), "yes" if (x | (y << 16) | (z << 32)) in ms.positions else "**no**")
             for t, n, x, y, z in sorted(ms.towns)]))
    w("\nWaypoints: %d" % len(ms.waypoints))
    if 0 < len(ms.waypoints) <= 40:
        w(" - " + ", ".join("%s (%d,%d,%d)" % wp for wp in ms.waypoints))
    w("\n")

    w("\n## Houses (map-house.xml)\n")
    town_names = {t[0]: t[1] for t in ms.towns}
    per_town = collections.defaultdict(lambda: [0, 0])
    for hs in houses:
        per_town[hs["town"]][0] += 1
        per_town[hs["town"]][1] += hs["size"]
    xml_ids = collections.Counter(hs["id"] for hs in houses)
    tile_ids = set(ms.house_tile_ids)
    no_tiles = sorted(i for i in xml_ids if i not in tile_ids)
    no_xml = sorted(i for i in tile_ids if i not in xml_ids)
    dup_ids = sorted(i for i, c in xml_ids.items() if c > 1)
    bad_entry = [hs for hs in houses
                 if (hs["entry"][0] | (hs["entry"][1] << 16) | (hs["entry"][2] << 32)) not in ms.positions]
    w(table(["Metric", "Value"], [
        ("Houses in XML", len(houses)),
        ("Sum of `size`", "{:,}".format(sum(hs["size"] for hs in houses))),
        ("Distinct house ids on house tiles", len(tile_ids)),
        ("XML houses with no house tiles", "%d %s" % (len(no_tiles), no_tiles[:30] if no_tiles else "")),
        ("Tile house ids without XML entry", "%d %s" % (len(no_xml), no_xml[:30] if no_xml else "")),
        ("Duplicate house ids in XML", "%d %s" % (len(dup_ids), dup_ids[:30] if dup_ids else "")),
        ("Houses whose entry position has no tile", len(bad_entry)),
        ("Town ids referenced but not in TOWNS node", sorted(t for t in per_town if t not in town_names)),
    ]))
    w("\nPer town:\n")
    w(table(["Town id", "Town", "Houses", "Total size"],
            [(t, town_names.get(t, "?"), c, s) for t, (c, s) in sorted(per_town.items())]))

    w("\n## Spawns (map-spawn.xml)\n")
    mons = [m for z in zones for m in z["monsters"]]
    npcs = [n for z in zones for n in z["npcs"]]
    mcount = collections.Counter(m[0] for m in mons)
    ncount = collections.Counter(n[0] for n in npcs)
    undefined_m = sorted(n for n in mcount if n.lower() not in monster_names)
    undefined_n = sorted(n for n in ncount if n.lower() not in npc_files and n.lower() not in npc_attrs)
    floors = set(ms.floor_counts)
    out_bounds = [z for z in zones if not (ms.minx <= z["center"][0] <= ms.maxx and ms.miny <= z["center"][1] <= ms.maxy)]
    bad_floor = [z for z in zones if z["center"][2] not in floors]
    center_missing = [z for z in zones
                      if (z["center"][0] | (z["center"][1] << 16) | (z["center"][2] << 32)) not in ms.positions]
    m_missing = [m for m in mons if (m[1] | (m[2] << 16) | (m[3] << 32)) not in ms.positions]
    n_missing = [n for n in npcs if (n[1] | (n[2] << 16) | (n[3] << 32)) not in ms.positions]
    empty_zones = sum(1 for z in zones if not z["monsters"] and not z["npcs"])
    w(table(["Metric", "Value"], [
        ("Spawn zones", "{:,}".format(len(zones))),
        ("Empty spawn zones", empty_zones),
        ("Child entries whose `z` differs from centerz (server uses centerz)", sum(z["zdiff"] for z in zones)),
        ("Monster spawn entries", "{:,}".format(len(mons))),
        ("NPC spawn entries", "{:,}".format(len(npcs))),
        ("Distinct monster names", len(mcount)),
        ("Distinct NPC names", len(ncount)),
        ("Monster names not in monsters.xml", len(undefined_m)),
        ("Monster names matching monsters.xml only case-insensitively",
         sum(1 for n in mcount if n.lower() in monster_names and monster_names[n.lower()] != n)),
        ("NPC names with more than one spawn entry", sum(1 for c in ncount.values() if c > 1)),
        ("NPC names without npc/*.xml (file name or name attr)", len(undefined_n)),
        ("Spawn centers outside actual tile bounds", len(out_bounds)),
        ("Spawn centers on a floor with no tiles", len(bad_floor)),
        ("Spawn centers with no tile at that position", len(center_missing)),
        ("Monster entries placed on non-existent tiles (exhaustive)", "{:,}".format(len(m_missing))),
        ("NPC entries placed on non-existent tiles (exhaustive)", len(n_missing)),
    ]))
    w("\nTop 25 monsters by spawn entries:\n")
    w(table(["#", "Monster", "Entries"], [(i + 1, n, c) for i, (n, c) in enumerate(mcount.most_common(25))]))
    w("\nMonster names in spawns not defined in monsters.xml (name: entries):\n")
    w(", ".join("%s: %d" % (n, mcount[n]) for n in undefined_m) or "(none)")
    w("\nNPC names in spawns without an NPC definition (name: entries):\n")
    w(", ".join("%s: %d" % (n, ncount[n]) for n in undefined_n) or "(none)")
    if m_missing:
        w("\nSample monster entries on non-existent tiles (name x,y,z):\n")
        w(", ".join("%s %d,%d,%d" % m for m in m_missing[:20]))
    if n_missing:
        w("\nNPC entries on non-existent tiles (name x,y,z):\n")
        w(", ".join("%s %d,%d,%d" % n for n in n_missing[:40]))
    if out_bounds or bad_floor:
        w("\nSpawn centers outside bounds / on empty floors:\n")
        w(", ".join("%d,%d,%d" % z["center"] for z in (out_bounds + bad_floor)[:40]))

    w("\n## Monster / NPC definition files\n")
    w(table(["Metric", "Value"], [
        ("Entries in monsters.xml", len(monster_names)),
        ("monsters.xml entries whose file is missing", len(missing_monster_files)),
        ("npc/*.xml files", len(npc_files)),
        ("NPC xml files with unreadable name", len(bad_npcs)),
    ]))
    if missing_monster_files:
        w("\nMissing monster files: " + ", ".join("%s (%s)" % m for m in missing_monster_files[:40]))

    cell, lines = ascii_density(ms, 7)
    w("\n## Floor 7 density overview\n")
    w("Each character = %dx%d tiles, origin (%d, %d) top-left; ramp ` .:-=+*#%%@` = empty -> full.\n"
      % (cell, cell, ms.minx, ms.miny))
    w("```\n" + "\n".join(lines) + "\n```")

    w("\n## Parse notes\n")
    w("- items.otb items in GROUND group: %d" % len(ground_ids))
    w("- Parse time: %.1f s" % elapsed)
    for warn in ms.warnings[:20] or ["No OTBM parse warnings."]:
        w("- " + warn)
    if len(ms.warnings) > 20:
        w("- ... %d more warnings" % (len(ms.warnings) - 20))

    text = "\n".join(o) + "\n"
    if args.output:
        with open(args.output, "w") as f:
            f.write(text)
    else:
        sys.stdout.write(text)


if __name__ == "__main__":
    main()
