#!/usr/bin/env python3
"""Puts the Gen 4 evolutions in the Orange Islands and takes the babies out (docs/orange-islands-gen4.md).

- Evolutions of older Pokemon: in each area where the pre-evolution spawns, about 1 of every 5 of
  its spawns becomes the evolution (rounded, at least 1; areas with fewer than 3 get none unless
  it's the species' only area). The spawn keeps its tile and spawn time.
- Evolutions of Gen 3 Pokemon and Eevee, whose pre-evolution doesn't spawn here: a few spawns of
  a Pokemon of the same habitat become the evolution (HABITAT).
- Porygon-Z: one new spawn on the deepest floor of the Power Plant of Hamlin, next to Porygon2,
  with the Porygon line's 45-minute spawn time.
- Babies (BABIES): the Orange Islands are a high-level area, so every baby spawn becomes the
  Pokemon of its line that spawns most in that area (the first of the line if none does), on
  the same tile and spawn time.

New spawns go on a free tile next to the spawn they belong to (or 2 tiles away if none is): the same ground as that spawn's
tile, nothing on it that blocks (items.otb), and no other spawn. Writes core/server/data/world/map-spawn.xml and its mapper copy; refuses to run
twice. Run scripts/make-pokepedia-data.py afterwards.

    python3 scripts/mapper/orange-gen4-spawns.py
"""
import collections
import importlib.util
import os
import re
import shutil
import struct
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
SPAWNS = os.path.join(ROOT, "core/server/data/world/map-spawn.xml")
MAPPER_SPAWNS = os.path.join(ROOT, "mapper/map/map-spawn.xml")

spec = importlib.util.spec_from_file_location("anchors", os.path.join(ROOT, "scripts/make-legendary-anchors.py"))
anchors = importlib.util.module_from_spec(spec)
spec.loader.exec_module(anchors)
pvmap = anchors.pvmap

EVOLUTIONS = [
    ("Magnezone", "Magneton"), ("Electivire", "Electabuzz"), ("Magmortar", "Magmar"),
    ("Rhyperior", "Rhydon"), ("Mamoswine", "Piloswine"), ("Togekiss", "Togetic"),
    ("Tangrowth", "Tangela"), ("Yanmega", "Yanma"), ("Gliscor", "Gligar"), ("Weavile", "Sneasel"),
    ("Honchkrow", "Murkrow"), ("Mismagius", "Misdreavus"), ("Ambipom", "Aipom"),
    ("Lickilicky", "Lickitung"),
]
RATIO = 5
MIN_AREA = 3

# evolution: (zone, area, Pokemon whose spawns it takes, how many)
HABITAT = {
    "Gallade": ("Moro", "Forgotten Temple", "Kadabra", 2),
    "Froslass": ("Shamouti", "Ice Island", "Jynx", 2),
    "Glaceon": ("Shamouti", "Ice Island", "Dewgong", 2),
    "Dusknoir": ("Moro", "Castle Fear", "Gengar", 2),
    "Probopass": ("Sunburst", "Crystal Cave", "Golem", 2),
    "Roserade": ("Pummelo", "Pummelo Forest", "Victreebel", 2),
    "Leafeon": ("Seven Grapefruit", "Seven Grapefruit #2", "Tangela", 2),
}

# new Pokemon: (zone, area, the Pokemon it spawns next to, spawn time or None for the adult's)
NEXT_TO = [
    ("Porygon-Z", ("Hamlin", "Power Plant of Hamlin", "Porygon2", 2700), {"floor": 10, "count": 1}),
]

# baby: the rest of its line; the first one is what the baby becomes where none of it spawns
BABIES = {
    "Pichu": ["Pikachu", "Raichu"], "Cleffa": ["Clefairy", "Clefable"], "Igglybuff": ["Jigglypuff", "Wigglytuff"],
    "Togepi": ["Togetic", "Togekiss"], "Tyrogue": ["Hitmonlee", "Hitmonchan", "Hitmontop"], "Smoochum": ["Jynx"],
    "Elekid": ["Electabuzz", "Electivire"], "Magby": ["Magmar", "Magmortar"], "Azurill": ["Marill", "Azumarill"],
    "Wynaut": ["Wobbuffet"], "Budew": ["Roselia", "Roserade"], "Chingling": ["Chimecho"], "Bonsly": ["Sudowoodo"],
    "Mime Jr.": ["Mr. Mime"], "Happiny": ["Chansey", "Blissey"], "Munchlax": ["Snorlax"], "Mantyke": ["Mantine"],
}

ITEMS_OTB = os.path.join(ROOT, "core/server/data/items/items.otb")
BLOCKING = 0x1 | 0x4  # items.otb flags: blocks movement, blocks pathfinding

MONSTER = re.compile(r'(<monster name=")([^"]+)(" x="(-?\d+)" y="(-?\d+)" z="(\d+)" spawntime="(\d+)")')


def read():
    """Each monster line: index, name, absolute x, y, z, spawn time, the spawn block's start line."""
    lines = open(SPAWNS, encoding="utf-8").read().split("\n")
    monsters, center, block = [], None, None
    for i, line in enumerate(lines):
        m = re.search(r'<spawn centerx="(\d+)" centery="(\d+)" centerz="(\d+)"', line)
        if m:
            center, block = tuple(map(int, m.groups())), i
            continue
        m = MONSTER.search(line)
        if m and center:
            monsters.append({"line": i, "name": m.group(2), "x": center[0] + int(m.group(4)),
                             "y": center[1] + int(m.group(5)), "z": int(m.group(6)),
                             "spawntime": int(m.group(7)), "block": block, "center": center})
    return lines, monsters


def blocking_items():
    spec = importlib.util.spec_from_file_location("otb", os.path.join(ROOT, "scripts/otb-add-item.py"))
    otb = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(otb)
    data = open(ITEMS_OTB, "rb").read()
    blocking = set()
    for start, _ in otb.read_node(data, 4)[2]:
        flags, attrs = otb.item_attrs(otb.read_node(data, start)[1])
        sid = next((struct.unpack("<H", v)[0] for a, v in attrs if a == otb.ATTR_SERVERID), None)
        if sid is not None and struct.unpack("<I", flags)[0] & BLOCKING:
            blocking.add(sid)
    return blocking


def spread(group, k):
    """k of the group, evenly through it in map order."""
    group = sorted(group, key=lambda s: (s["z"], s["y"], s["x"]))
    n = len(group)
    return [group[(2 * j + 1) * n // (2 * k)] for j in range(k)]


def main():
    lines, monsters = read()
    area_of = anchors.area_finder()
    zone_of = anchors.zone_finder(anchors.read_towns())
    orange = [s for s in monsters if anchors.region_of(s["x"], s["y"]) == "orange"]
    new_names = {e for e, _ in EVOLUTIONS} | set(HABITAT) | {n for n, _, _ in NEXT_TO}
    if any(s["name"] in new_names for s in orange):
        raise SystemExit("the Orange Islands already have Gen 4 spawns; nothing written")
    for s in orange:
        s["zone"] = zone_of(s["x"], s["y"])[0]
        s["area"] = area_of(s["x"], s["y"], s["z"]) or "unnamed spot"

    by_area = collections.defaultdict(list)
    for s in orange:
        by_area[(s["name"], s["zone"], s["area"])].append(s)

    report = []
    for evo, pre in EVOLUTIONS:
        groups = {k[1:]: g for k, g in by_area.items() if k[0] == pre}
        for (zone, area), group in sorted(groups.items(), key=lambda i: -len(i[1])):
            n = len(group)
            if n < MIN_AREA and len(groups) > 1:
                continue
            k = max(1, int(n / RATIO + 0.5))
            for s in spread(group, k):
                s["new"] = evo
            report.append((evo, pre, zone, area, n, k))

    for evo, (zone, area, pre, k) in HABITAT.items():
        group = [s for s in by_area[(pre, zone, area)] if "new" not in s]
        if len(group) < k:
            raise SystemExit("%s: only %d %s at %s (%s)" % (evo, len(group), pre, area, zone))
        for s in spread(group, k):
            s["new"] = evo
        report.append((evo, pre, zone, area, len(by_area[(pre, zone, area)]), k))

    additions = []
    for name, (zone, area, adult, spawntime), opts in NEXT_TO:
        adults = by_area[(adult, zone, area)]
        if "floor" in opts:
            adults = [s for s in adults if s["z"] == opts["floor"]]
        if not adults:
            raise SystemExit("%s: no %s at %s (%s)" % (name, adult, area, zone))
        adults = spread(adults, opts.get("count", len(adults)))
        additions.append((name, adults, len(adults), spawntime, zone, area, adult))

    # babies: each becomes the Pokemon of its line that spawns most in its area
    line_of = {adult: baby for baby, rest in BABIES.items() for adult in rest}
    families = collections.defaultdict(collections.Counter)
    for s in orange:
        name = s.get("new", s["name"])
        if name in line_of:
            families[(line_of[name], s["zone"], s["area"])][name] += 1
    grown = collections.Counter()
    for s in orange:
        if s["name"] in BABIES:
            common = families[(s["name"], s["zone"], s["area"])].most_common(1)
            s["new"] = common[0][0] if common else BABIES[s["name"]][0]
            grown[(s["new"], s["name"], s["zone"], s["area"])] += 1
    for (adult, baby, zone, area), n in sorted(grown.items()):
        report.append((adult, "from " + baby, zone, area, n, n))

    for s in orange:
        if "new" in s:
            lines[s["line"]] = MONSTER.sub(lambda m: m.group(1) + s["new"] + m.group(3), lines[s["line"]], 1)

    taken = {(s["x"], s["y"], s["z"]) for s in monsters}
    near = [(dx, dy) for dx in range(-2, 3) for dy in range(-2, 3) if dx or dy]
    wanted = {(s["x"] + dx, s["y"] + dy, s["z"]) for a in additions for s in a[1] for dx, dy in near + [(0, 0)]}
    tiles = pvmap.read_tiles(anchors.MAP, wanted)
    blocking = blocking_items()

    inserts = collections.defaultdict(list)
    for name, adults, needed, spawntime, zone, area, adult in additions:
        placed = 0
        for s in adults:
            if placed == needed:
                break
            own = tiles.get((s["x"], s["y"], s["z"]))
            spots = sorted(((s["x"] + dx, s["y"] + dy, s["z"]) for dx, dy in near),
                           key=lambda p: (max(abs(p[0] - s["x"]), abs(p[1] - s["y"])), abs(p[0] - s["x"]) + abs(p[1] - s["y"])))
            for p in spots:
                t = tiles.get(p)
                if p in taken or not t or not own or t[0] != own[0] or blocking & set(t):
                    continue
                taken.add(p)
                cx, cy, _ = s["center"]
                inserts[s["block"]].append('    <monster name="%s" x="%d" y="%d" z="%d" spawntime="%d" level="0"/>'
                                           % (name, p[0] - cx, p[1] - cy, p[2], spawntime or s["spawntime"]))
                placed += 1
                break
        if placed < needed:
            print("  %s at %s: no free tile for %d of %d" % (name, area, needed - placed, needed))
        report.append((name, "next to " + adult, zone, area, len(adults), placed))

    for block in sorted(inserts, reverse=True):
        end = block + 1
        while "</spawn>" not in lines[end]:
            end += 1
        radius = re.search(r'radius="(\d+)"', lines[block])
        needed = max(max(abs(int(v)) for v in re.findall(r' [xy]="(-?\d+)"', m)) for m in inserts[block])
        if radius and needed > int(radius.group(1)):
            lines[block] = lines[block].replace(radius.group(0), 'radius="%d"' % needed)
        lines[end:end] = inserts[block]

    open(SPAWNS, "w", encoding="utf-8").write("\n".join(lines))
    shutil.copyfile(SPAWNS, MAPPER_SPAWNS)
    for evo, pre, zone, area, n, k in report:
        print("%-11s %-20s %-18s %-28s %3d -> %d" % (evo, pre, zone, area, n, k))
    print("total: %d spawns changed, %d added" % (sum(1 for s in orange if "new" in s),
                                                sum(len(v) for v in inserts.values())))


if __name__ == "__main__":
    sys.exit(main())
