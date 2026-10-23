#!/usr/bin/env python3
"""Builds core/server/data/lib/ps/config/legendaryAnchors.lua, the points wild legendaries
spawn at and move between (systems/078-wildLegendaries.lua), in every region.

Points come from the map spawns (world/map-spawn.xml): a wild land Pokemon spawns there, so
the tile is walkable ground. Water-type spawns are left out (they sit on water) but count for
the "water" tag of the points near them. Each point has:

- its area name: the client's music areas (client-legacy sounds1/2.lua, drawn for the old map,
  2351 tiles further west) cover Kanto and the Orange Islands; elsewhere it is empty and the
  server says "around <town>";
- its zone: the nearest town of its region, like Weather.zoneAt (the regions are
  Weather.REGIONS' boxes);
- tags, from the types of the Pokemon spawning within TAG_RADIUS on its floor, its floor, the
  area name and how far it is from its town: water, cold, fire, electric, forest, rock, steel,
  mystic (psychic and ghost), mountain, high, cave, indoor, remote, peaceful;
- the species that spawns on it (Mew takes its look).

The points are thinned to one per CELL so each area is covered evenly. NEIGHBORS lists, for each
zone, the zones with a point within NEIGHBOR_DISTANCE of one of its own on the surface: the zones
a ground roamer may walk to. The server checks each point again before using it (ground, no
water, no protection zone, room for the monster, open sky when outdoors).

    python3 scripts/make-legendary-anchors.py
"""

import collections
import os
import re
import struct
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(ROOT, "scripts", "mapper"))
import pvmap  # noqa: E402

LEGACY_AREAS = os.path.join(ROOT, "core/client-legacy/modules/game_environment")
MAP_OFFSET_X = 2351
MAP = os.path.join(ROOT, "core/server/data/world/map.otbm")
SPAWNS = os.path.join(ROOT, "core/server/data/world/map-spawn.xml")
POKEMON_DIR = os.path.join(ROOT, "core/server/data/lib/ps/config/pokemon")
OUT = os.path.join(ROOT, "core/server/data/lib/ps/config/legendaryAnchors.lua")

# Weather.REGIONS, checked in order; Kanto is everything else.
REGIONS = [
    ("johto", (1700, 20, 3048, 1270)),
    ("orange", (2641, 1311, 4647, 3486)),
    ("hoenn", (48, 773, 2224, 2304)),
]
# Towns no legendary goes to (the tutorial and the starter island).
SKIP_TOWNS = {"Tutorial", "Beginner Island"}

CELL = 24
TAG_RADIUS = 10
NEIGHBOR_DISTANCE = 48
REMOTE = 150
PEACEFUL = 60

# Area name words that mean indoors (buildings), and words that give a tag.
INDOOR_WORDS = (
    "Tower", "Pokemansion", "Temple", "Tomb", "Within", "Interior", "Power Plant", "Gym",
    "Rocket", "House", "Center", "Mart", "Hotel", "Pokepolis", "Aquarium",
)
NAME_TAGS = (
    ("forest", ("Forest", "Jungle", "Garden", "Park")),
    ("mountain", ("Mountain", "Mt.", "Hill", "Peak", "Ape", "Plateau")),
    ("fire", ("Volcano", "Lava", "Fire")),
    ("cold", ("Seafoam", "Ice", "Snow", "Iceberg", "Frozen")),
    ("water", ("Sea", "Beach", "Coast", "Harbor", "Island", "Lake", "River", "Waterfall", "Bay", "Shore")),
    ("mystic", ("Ruins", "Tower", "Archaeological", "Ancient", "Tomb", "Temple", "Pokemansion")),
    ("electric", ("Power Plant",)),
)
TYPE_TAGS = {
    "ELEMENT_WATER": "water", "ELEMENT_ICE": "cold", "ELEMENT_FIRE": "fire", "ELEMENT_ELECTRIC": "electric",
    "ELEMENT_GRASS": "forest", "ELEMENT_BUG": "forest", "ELEMENT_ROCK": "rock", "ELEMENT_GROUND": "rock",
    "ELEMENT_STEEL": "steel", "ELEMENT_PSYCHIC": "mystic", "ELEMENT_GHOST": "mystic",
}
# Spawns of a type it takes within TAG_RADIUS for the tag (one Oddish isn't a forest).
TAG_MIN = {"forest": 2, "rock": 2}


def region_of(x, y):
    for name, (x0, y0, x1, y1) in REGIONS:
        if x0 <= x <= x1 and y0 <= y <= y1:
            return name
    return "kanto"


def read_towns():
    data = open(MAP, "rb").read()
    start = data.rfind(b"\xfe\x0c\xfe\x0d")
    if start < 0:
        raise SystemExit("no town list in the map (pull map.otbm from LFS)")
    towns = []
    for event, kind, _, a, b, _ in pvmap.walk(data, start):
        if event == "open" and kind == pvmap.TOWN:
            p = pvmap.unescape(data[a:b])
            n = struct.unpack_from("<H", p, 4)[0]
            name = p[6:6 + n].decode("latin-1")
            x, y, z = struct.unpack_from("<HHB", p, 6 + n)
            if x > 0 and name not in SKIP_TOWNS:
                towns.append((name, x, y, z, region_of(x, y)))
        elif event == "close" and kind == pvmap.TOWNS:
            break
    return towns


def zone_finder(towns):
    by_region = collections.defaultdict(list)
    for town in towns:
        by_region[town[4]].append(town)

    def zone_of(x, y):
        region = region_of(x, y)
        best = None
        for name, tx, ty, tz, _ in by_region[region]:
            d = max(abs(tx - x), abs(ty - y))
            if best is None or d < best[0]:
                best = (d, name, tz)
        return (best[1], best[0], region, best[2]) if best else (None, None, region, None)

    return zone_of


def read_areas():
    areas = []
    for name in ("sounds1.lua", "sounds2.lua"):
        text = open(os.path.join(LEGACY_AREAS, name), encoding="latin-1").read()
        pattern = r'\[8\] = "([^"]*)",\s*\["fromPos"\] = (\{[^}]*\}),\s*\["toPos"\] = (\{[^}]*\})'
        for m in re.finditer(pattern, text):
            a = {k: int(v) for k, v in re.findall(r'\["([xyz])"\] = (\d+)', m.group(2))}
            b = {k: int(v) for k, v in re.findall(r'\["([xyz])"\] = (\d+)', m.group(3))}
            areas.append((m.group(1), a["x"] + MAP_OFFSET_X, a["y"], a["z"],
                          b["x"] + MAP_OFFSET_X, b["y"], b["z"]))
    return areas


def area_index(areas, bucket=64):
    index = collections.defaultdict(list)
    for area in areas:
        for bx in range(area[1] // bucket, area[4] // bucket + 1):
            for by in range(area[2] // bucket, area[5] // bucket + 1):
                index[(bx, by)].append(area)

    def area_of(x, y, z):
        best = None
        for name, x0, y0, z0, x1, y1, z1 in index[(x // bucket, y // bucket)]:
            if x0 <= x <= x1 and y0 <= y <= y1 and z0 <= z <= z1:
                size = (x1 - x0 + 1) * (y1 - y0 + 1)
                if best is None or size < best[0]:
                    best = (size, name)
        return best[1] if best else None

    return area_of


def species_types():
    types = {}
    for file in os.listdir(POKEMON_DIR):
        text = open(os.path.join(POKEMON_DIR, file), encoding="latin-1").read()
        for m in re.finditer(r'POKEMON\["([^"]+)"\]\s*=\s*\{\s*pTypes\s*=\s*\{([^}]*)\}', text):
            types[m.group(1)] = re.findall(r"ELEMENT_\w+", m.group(2))
    return types


def read_spawns():
    spawns, center = [], None
    for line in open(SPAWNS, encoding="utf-8"):
        m = re.search(r'<spawn centerx="(\d+)" centery="(\d+)" centerz="(\d+)"', line)
        if m:
            center = tuple(map(int, m.groups()))
            continue
        m = re.search(r'<monster name="([^"]+)" x="(-?\d+)" y="(-?\d+)"', line)
        if m and center:
            name = m.group(1)
            spawns.append((name[6:] if name.startswith("Shiny ") else name,
                           center[0] + int(m.group(2)), center[1] + int(m.group(3)), center[2]))
    return spawns


def thin(points, cell):
    """One point per cell and floor: the one nearest the middle of the cell's points."""
    cells = collections.defaultdict(list)
    for p in points:
        cells[(p[1] // cell, p[2] // cell, p[3])].append(p)
    result = []
    for key in sorted(cells):
        group = cells[key]
        mx = sum(p[1] for p in group) / len(group)
        my = sum(p[2] for p in group) / len(group)
        result.append(min(group, key=lambda p: (p[1] - mx) ** 2 + (p[2] - my) ** 2))
    return result


def main():
    towns = read_towns()
    zone_of = zone_finder(towns)
    area_of = area_index(read_areas())
    types = species_types()
    spawns = read_spawns()

    near = collections.defaultdict(list)
    for name, x, y, z in spawns:
        near[(x // TAG_RADIUS, y // TAG_RADIUS, z)].append((name, x, y))

    def tags_at(x, y, z, area, town_z):
        counts = collections.Counter()
        for bx in (x // TAG_RADIUS - 1, x // TAG_RADIUS, x // TAG_RADIUS + 1):
            for by in (y // TAG_RADIUS - 1, y // TAG_RADIUS, y // TAG_RADIUS + 1):
                for name, sx, sy in near[(bx, by, z)]:
                    if max(abs(sx - x), abs(sy - y)) <= TAG_RADIUS:
                        for t in set(TYPE_TAGS.get(e) for e in types.get(name, ())):
                            if t:
                                counts[t] += 1
        tags = {t for t, n in counts.items() if n >= TAG_MIN.get(t, 1)}
        if area:
            for tag, words in NAME_TAGS:
                if any(w in area for w in words):
                    tags.add(tag)
            if any(w in area for w in INDOOR_WORDS):
                tags.add("indoor")
        if z > 7:
            tags.add("cave")
        elif z <= town_z - 2:
            tags.update(("high", "mountain"))
        elif z < town_z and "rock" in tags:
            tags.add("mountain")
        return tags

    land = []
    for name, x, y, z in spawns:
        if "ELEMENT_WATER" in types.get(name, ()):
            continue
        zone, distance, region, town_z = zone_of(x, y)
        if not zone:
            continue
        area = area_of(x, y, z) if region in ("kanto", "orange") else None
        land.append((name, x, y, z, area or "", zone, region, distance, town_z))
    land = sorted(set(land), key=lambda p: (p[1], p[2], p[3], p[0]))

    points = []
    for name, x, y, z, area, zone, region, distance, town_z in thin(land, CELL):
        tags = tags_at(x, y, z, area, town_z)
        if distance > REMOTE:
            tags.add("remote")
        elif distance < PEACEFUL:
            tags.add("peaceful")
        points.append((x, y, z, area, zone, ",".join(sorted(tags)), name))

    surface = collections.defaultdict(list)
    for p in points:
        if p[2] <= 7:
            surface[(p[0] // NEIGHBOR_DISTANCE, p[1] // NEIGHBOR_DISTANCE)].append(p)
    neighbors = collections.defaultdict(set)
    for (bx, by), group in surface.items():
        for dx in (-1, 0, 1):
            for dy in (-1, 0, 1):
                for a in group:
                    for b in surface.get((bx + dx, by + dy), ()):
                        if a[4] != b[4] and max(abs(a[0] - b[0]), abs(a[1] - b[1])) <= NEIGHBOR_DISTANCE:
                            neighbors[a[4]].add(b[4])

    out = [
        "-- Generated by scripts/make-legendary-anchors.py from the map spawns and towns; edit that, not this.",
        "-- POINTS: { x, y, z, area name (\"\": around the zone's town), zone (town name), tags, spawn species }.",
        "-- NEIGHBORS: the zones a ground roamer may walk to from each zone.",
        "LEGENDARY_ANCHORS = {",
        "    POINTS = {",
    ]
    out += ['        {%d, %d, %d, "%s", "%s", "%s", "%s"},' % p for p in points]
    out += ["    },", "    NEIGHBORS = {"]
    for zone in sorted(neighbors):
        out.append('        ["%s"] = { %s },' % (zone, ", ".join('"%s"' % n for n in sorted(neighbors[zone]))))
    out += ["    },", "}", ""]
    with open(OUT, "w", encoding="utf-8") as f:
        f.write("\n".join(out))

    by_region = collections.Counter(zone_of(p[0], p[1])[2] for p in points)
    tag_count = collections.Counter(t for p in points for t in p[5].split(",") if t)
    print("points: %d %s" % (len(points), dict(by_region)))
    print("tags: %s" % dict(tag_count.most_common()))
    print("zones with neighbors: %d of %d towns" % (len(neighbors), len(towns)))
    lonely = sorted({t[0] for t in towns} - set(neighbors))
    if lonely:
        print("zones without neighbors: %s" % ", ".join(lonely))


if __name__ == "__main__":
    main()
