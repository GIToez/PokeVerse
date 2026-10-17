#!/usr/bin/env python3
"""Builds core/server/data/lib/ps/config/legendaryAnchors.lua, the points wild legendaries
spawn at and roam between (systems/078-wildLegendaries.lua).

Points come from the map spawns (world/map-spawn.xml): a wild land Pokemon spawns there, so
the tile is walkable ground. Water-type spawns are left out (they sit on water) and so are
indoor and underground areas, except for the home areas that are caves or buildings
(Cerulean Cave, Rock Tunnel, the Power Plant, the Pokemansion). Area names come from the
client's music areas (client-legacy sounds1/2.lua, drawn for the old map, 2351 tiles further
west) and are what the "spotted near" messages show.

The points are thinned to one per cell so the pool covers Kanto evenly. The server checks
each point again before using it (ground, no water, no protection zone, room for the
monster).

    python3 scripts/make-legendary-anchors.py
"""

import collections
import json
import os
import re

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
LEGACY_AREAS = os.path.join(ROOT, "core/client-legacy/modules/game_environment")
MAP_OFFSET_X = 2351
SPAWNS = os.path.join(ROOT, "core/server/data/world/map-spawn.xml")
POKEMON_DIR = os.path.join(ROOT, "core/server/data/lib/ps/config/pokemon")
OUT = os.path.join(ROOT, "core/server/data/lib/ps/config/legendaryAnchors.lua")

# Kanto on the current map. Johto lies west of x 3050, the Orange Islands south of y 1150.
KANTO = (3050, 100, 4400, 1150)

ROAM_CELL = 32
HOME_CELL = 16

# Area name words that mean indoors, underground or under water.
INDOOR_WORDS = (
    "Cave", "Culvert", "Tunnel", "Diglett", "Tower", "Pokemansion", "Temple", "Tomb", "Hole",
    "Lair", "Within", "Interior", "Power Plant", "Gym", "Rocket", "Sea", "Lake", "House",
    "Center", "Mart", "Hotel", "Iceberg", "Pokepolis", "Unknown",
)

# Home areas: key -> area names. A species' home is one of these keys.
HOMES = collections.OrderedDict([
    ("seafoam", ["Seafoam", "Seafoam Mountain", "Interior Seafoam Mountain"]),
    ("power_plant", ["Power Plant"]),
    ("volcano", ["Volcano", "Volcano Cave", "The Volcano Coast", "The Volcano Coast Cave"]),
    ("routes_11_12", ["Route 11", "Route 12", "Route 13", "Around the Vermilion"]),
    ("rivers", ["River Mt. Moon", "Waterfall Mt. Moon", "Waterfall Cerulean",
                "Waterfall Mountain Route 16", "Route 24", "Route 25"]),
    ("rock_tunnel", ["Rock Tunnel", "Around the Rock Tunnel"]),
    ("coasts", ["Natural Harbor", "The Volcano Coast", "North Forest of the Volcano Coast",
                "Route 19", "Route 25", "Seafoam"]),
    ("cerulean_cave", ["Cerulean Cave"]),
    ("mansion", ["Pokemansion"]),
    ("southern_shores", ["Route 19", "Seafoam", "Natural Harbor",
                         "Forest South Of The Volcano Coast"]),
    ("indigo", ["Route 22", "Route 23", "Ape Mountain", "Living Herb Mountain"]),
    ("viridian_forest", ["Viridian Forest", "Viridian Forest Mountain"]),
    ("mt_moon", ["Mt. Moon", "Around the Mt. Moon", "Waterfall Mt. Moon", "River Mt. Moon"]),
])


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


def water_species():
    names = set()
    for file in os.listdir(POKEMON_DIR):
        text = open(os.path.join(POKEMON_DIR, file), encoding="latin-1").read()
        for m in re.finditer(r'POKEMON\["([^"]+)"\]\s*=\s*\{\s*pTypes\s*=\s*\{([^}]*)\}', text):
            if "ELEMENT_WATER" in m.group(2):
                names.add(m.group(1))
    return names


def read_spawns():
    spawns, center = [], None
    for line in open(SPAWNS, encoding="utf-8"):
        m = re.search(r'<spawn centerx="(\d+)" centery="(\d+)" centerz="(\d+)"', line)
        if m:
            center = tuple(map(int, m.groups()))
            continue
        m = re.search(r'<monster name="([^"]+)" x="(-?\d+)" y="(-?\d+)"', line)
        if m and center:
            spawns.append((m.group(1), center[0] + int(m.group(2)), center[1] + int(m.group(3)), center[2]))
    return spawns


def thin(points, cell):
    """One point per cell and floor: the one nearest the middle of the cell's points."""
    cells = collections.defaultdict(list)
    for p in points:
        cells[(p[0] // cell, p[1] // cell, p[2])].append(p)
    result = []
    for key in sorted(cells):
        group = cells[key]
        mx = sum(p[0] for p in group) / len(group)
        my = sum(p[1] for p in group) / len(group)
        result.append(min(group, key=lambda p: (p[0] - mx) ** 2 + (p[1] - my) ** 2))
    return result


def lua_points(points):
    return ",\n".join('        {%d, %d, %d, "%s"}' % p for p in points)


def main():
    area_of = area_index(read_areas())
    water = water_species()
    x0, y0, x1, y1 = KANTO
    land = []
    for name, x, y, z in read_spawns():
        base = name[6:] if name.startswith("Shiny ") else name
        if base in water or not (x0 <= x <= x1 and y0 <= y <= y1):
            continue
        area = area_of(x, y, z)
        if area:
            land.append((x, y, z, area))
    land = sorted(set(land))

    roam = [p for p in land if p[2] <= 7 and not any(w in p[3] for w in INDOOR_WORDS)]
    roam = thin(roam, ROAM_CELL)
    homes = collections.OrderedDict()
    for key, names in HOMES.items():
        homes[key] = thin([p for p in land if p[3] in names], HOME_CELL)
        if not homes[key]:
            raise SystemExit("home area %s has no points" % key)

    out = [
        "-- Generated by scripts/make-legendary-anchors.py from the map spawns; edit that, not this.",
        "-- { x, y, z, area name }. ROAM covers Kanto outdoors; HOMES are the species' home areas.",
        "LEGENDARY_ANCHORS = {",
        "    ROAM = {",
        lua_points(roam),
        "    },",
        "    HOMES = {",
    ]
    for key, points in homes.items():
        out += ["        %s = {" % key, lua_points(points).replace("\n        ", "\n            ")
                .replace('        {', '            {', 1), "        },"]
    out += ["    },", "}", ""]
    with open(OUT, "w", encoding="utf-8") as f:
        f.write("\n".join(out))

    print("roam points: %d (areas: %d)" % (len(roam), len({p[3] for p in roam})))
    for key, points in homes.items():
        print("  %-16s %3d  %s" % (key, len(points), ", ".join(sorted({p[3] for p in points}))))


if __name__ == "__main__":
    main()
