#!/usr/bin/env python3
"""Measures the wild spawns of Kanto, Johto and Hoenn so they can be compared area by area.

    scripts/mapper/spawn_audit.py [--map core/server/data/world/map.otbm] [--cache build/spawn-tiles.npz]
        [--json build/spawn-audit.json]

For every area (the client's area names: areas_johto.lua, areas_hoenn.lua and, for Kanto, the
legacy sounds1/2.lua) and floor it counts the open ground (standable, not water, not a house or a
protection zone tile), the water, the wild spawns on them and their species' level ranges
(monster XML minLevel/maxLevel). Regions are 079-weather.lua's boxes; Kanto is the rest, without
the Orange Islands.

Floors: "surface" is z 7, "above" z 0-6 (hills, towers, plateaus), "below" z 8-15 (caves,
dungeons). Density is spawns per 1,000 tiles of open ground (water spawns per 1,000 water tiles).

Reading the map takes a few minutes, so the tiles are cached in --cache; delete it after a map
change.
"""
import argparse
import collections
import json
import os
import re
import struct
import sys

import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import pvmap  # noqa: E402

ROOT = os.path.dirname(os.path.dirname(HERE))
DATA = os.path.join(ROOT, 'core', 'server', 'data')
ENV = os.path.join(ROOT, 'core', 'client-redemption', 'pokeverse-modern', 'modules', 'game_environment')
LEGACY = os.path.join(ROOT, 'core', 'client-legacy', 'modules', 'game_environment')
LEGACY_OFFSET_X = 2351  # build_world_areas.py: the legacy areas are this far west of the map
WATER = set(range(4608, 4626)) | {4664, 4665, 4666} | set(range(4820, 4826))
REGIONS = [  # 079-weather.lua's Weather.REGIONS
    ('Johto', 1700, 20, 3048, 1270),
    ('Orange Islands', 2641, 1311, 4647, 3486),
    ('Hoenn', 48, 773, 2224, 2304),
]
W, H = 6400, 4096  # past the map's far corner
NPC_WORDS = ('Nurse', 'Joy', 'Grunt', 'Trainer', 'Rocket')


def region_of(x, y):
    for name, x0, y0, x1, y1 in REGIONS:
        if x0 <= x <= x1 and y0 <= y <= y1:
            return name
    return 'Kanto'


def floor_class(z):
    return 'surface' if z == 7 else ('above' if z < 7 else 'below')


def read_tiles(path, otb):
    """Arrays of (x, y, z) for open ground and for water, in one pass over the map."""
    data = open(path, 'rb').read()
    land, water = [], []
    area = None
    cur = None
    for ev, t, depth, a, b, _ in pvmap.walk(data):
        if ev == 'close':
            if t in (pvmap.TILE, pvmap.HOUSETILE) and cur is not None:
                pos, ids, skip = cur
                cur = None
                if skip or not ids or any(otb.blocks(i) for i in ids):
                    continue
                (water if any(i in WATER for i in ids) else land).append(pos)
            continue
        if t == pvmap.TILE_AREA:
            area = struct.unpack_from('<HHB', pvmap.unescape(data[a:b]), 0)
        elif t in (pvmap.TILE, pvmap.HOUSETILE):
            p = pvmap.unescape(data[a:b])
            _, _, house_id, flags, item = pvmap.parse_tile_props(p, t == pvmap.HOUSETILE)
            cur = ((area[0] + p[0], area[1] + p[1], area[2]), [item] if item is not None else [],
                   bool(house_id) or bool(flags & 1))
        elif t == pvmap.ITEM and cur is not None and depth == 4:
            cur[1].append(struct.unpack_from('<H', pvmap.unescape(data[a:a + 4]), 0)[0])
    return np.array(land, np.int32).reshape(-1, 3), np.array(water, np.int32).reshape(-1, 3)


def generated_areas(path, var):
    out = []
    for m in re.finditer(r'\{ (\d+), (\d+), (\d+), (\d+), (\d+), (\d+), "([^"]+)"', open(path, encoding='utf-8').read()):
        x0, y0, z0, x1, y1, z1 = map(int, m.groups()[:6])
        out.append((x0, y0, z0, x1, y1, z1, m.group(7)))
    return out


def legacy_areas():
    out = []
    for name in ('sounds1.lua', 'sounds2.lua'):
        src = open(os.path.join(LEGACY, name), encoding='latin-1').read()
        for m in re.finditer(r'\[6\] = (\d+),.*?\[8\] = "([^"]*)",\s*\["fromPos"\] = \{(.*?)\},\s*\["toPos"\] = \{(.*?)\}', src, re.S):
            f = {k: int(v) for k, v in re.findall(r'\["(\w)"\] = (-?\d+)', m.group(3))}
            t = {k: int(v) for k, v in re.findall(r'\["(\w)"\] = (-?\d+)', m.group(4))}
            out.append((int(m.group(1)), f['x'] + LEGACY_OFFSET_X, f['y'], f['z'], t['x'] + LEGACY_OFFSET_X, t['y'],
                        t['z'], m.group(2)))
    return out


class AreaIndex:
    """The area name of a tile: Johto's and Hoenn's generated areas (first match wins), then the
    legacy ones (first match wins, as in build_world_areas.py), then areas_world.lua's fallbacks."""

    def __init__(self):
        self.names = ['?']
        self.ids = {'?': 0}
        self.grid = {}
        gen = generated_areas(os.path.join(ENV, 'areas_johto.lua'), 'AREAS_JOHTO') + \
            generated_areas(os.path.join(ENV, 'areas_hoenn.lua'), 'AREAS_HOENN')
        legacy = legacy_areas()
        world = generated_areas(os.path.join(ENV, 'areas_world.lua'), 'AREAS_WORLD')
        for z in range(16):
            g = np.zeros((H, W), np.int16)
            for x0, y0, z0, x1, y1, z1, name in reversed(world):
                if z0 <= z <= z1:
                    g[y0:y1 + 1, x0:x1 + 1] = self.id(name)
            for pr, x0, y0, z0, x1, y1, z1, name in reversed(legacy):
                if z0 <= z <= z1:
                    g[max(0, y0):y1 + 1, max(0, x0):x1 + 1] = self.id(name)
            for x0, y0, z0, x1, y1, z1, name in reversed(gen):
                if z0 <= z <= z1:
                    g[y0:y1 + 1, x0:x1 + 1] = self.id(name)
            self.grid[z] = g

    def id(self, name):
        if name not in self.ids:
            self.ids[name] = len(self.names)
            self.names.append(name)
        return self.ids[name]

    def at(self, x, y, z):
        if 0 <= x < W and 0 <= y < H and 0 <= z < 16:
            return self.names[self.grid[z][y, x]]
        return '?'

    def labels(self, pts):
        out = np.zeros(len(pts), np.int16)
        for z in range(16):
            sel = pts[:, 2] == z
            if sel.any():
                out[sel] = self.grid[z][pts[sel, 1], pts[sel, 0]]
        return out


def monster_levels():
    index = dict(re.findall(r'<monster name="([^"]+)" file="([^"]+)"',
                            open(os.path.join(DATA, 'monster', 'monsters.xml'), encoding='latin-1').read()))
    levels = {}
    for name, f in index.items():
        p = os.path.join(DATA, 'monster', f)
        if not os.path.exists(p):
            continue
        head = open(p, encoding='latin-1').read(2000)
        lo, hi = re.search(r'minLevel="(\d+)"', head), re.search(r'maxLevel="(\d+)"', head)
        if lo and hi:
            levels[name] = (int(lo.group(1)), int(hi.group(1)))
    return levels


def spawns():
    src = open(os.path.join(DATA, 'world', 'map-spawn.xml'), encoding='latin-1').read()
    out = []
    for m in re.finditer(r'<spawn centerx="(\d+)" centery="(\d+)" centerz="(\d+)"[^>]*>(.*?)</spawn>', src, re.S):
        cx, cy, cz = int(m.group(1)), int(m.group(2)), int(m.group(3))
        for mm in re.finditer(r'<monster name="([^"]+)" x="(-?\d+)" y="(-?\d+)"[^>]*spawntime="(\d+)"(?:[^>]*level="(\d+)")?', m.group(4)):
            out.append((mm.group(1), cx + int(mm.group(2)), cy + int(mm.group(3)), cz, int(mm.group(4)), int(mm.group(5) or 0)))
    return out


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument('--map', default=os.path.join(DATA, 'world', 'map.otbm'))
    ap.add_argument('--cache', default=os.path.join(ROOT, 'build', 'spawn-tiles.npz'))
    ap.add_argument('--json', default=os.path.join(ROOT, 'build', 'spawn-audit.json'))
    args = ap.parse_args()

    if os.path.exists(args.cache):
        c = np.load(args.cache)
        land, water = c['land'], c['water']
    else:
        otb = pvmap.Otb(os.path.join(DATA, 'items', 'items.otb'))
        land, water = read_tiles(args.map, otb)
        os.makedirs(os.path.dirname(args.cache), exist_ok=True)
        np.savez_compressed(args.cache, land=land, water=water)
    print('%d open ground tiles, %d water tiles' % (len(land), len(water)), file=sys.stderr)

    idx = AreaIndex()
    levels = monster_levels()
    water_grid = {}
    for z in np.unique(water[:, 2]).tolist():
        g = np.zeros((H, W), bool)
        sel = water[water[:, 2] == z]
        g[sel[:, 1], sel[:, 0]] = True
        water_grid[z] = g

    areas = collections.defaultdict(lambda: {'land': 0, 'water': 0, 'spawns': collections.Counter(),
                                             'water_spawns': collections.Counter(), 'levels': []})

    def key(region, z, name):
        return (region, floor_class(z), z, name)

    for arr, kind in ((land, 'land'), (water, 'water')):
        lab = idx.labels(arr)
        for (x, y, z), a in zip(arr.tolist(), lab.tolist()):
            r = region_of(x, y)
            if r == 'Orange Islands':
                continue
            areas[key(r, z, idx.names[a])][kind] += 1

    unknown = collections.Counter()
    for name, x, y, z, st, lvl in spawns():
        if any(w in name for w in NPC_WORDS) or name not in levels:
            unknown[name] += 1
            continue
        r = region_of(x, y)
        if r == 'Orange Islands':
            continue
        a = areas[key(r, z, idx.at(x, y, z))]
        on_water = z in water_grid and 0 <= x < W and 0 <= y < H and water_grid[z][y, x]
        (a['water_spawns'] if on_water else a['spawns'])[name] += 1
        a['levels'].append(levels[name][0])

    out = []
    for (r, fc, z, name), a in areas.items():
        n = sum(a['spawns'].values())
        nw = sum(a['water_spawns'].values())
        if a['land'] + a['water'] < 50 and not n + nw:
            continue
        out.append({'region': r, 'floors': fc, 'z': z, 'area': name, 'land': a['land'], 'water': a['water'],
                    'spawns': n, 'water_spawns': nw,
                    'density': round(1000.0 * n / a['land'], 2) if a['land'] else None,
                    'water_density': round(1000.0 * nw / a['water'], 2) if a['water'] else None,
                    'min_level_avg': round(sum(a['levels']) / len(a['levels']), 1) if a['levels'] else None,
                    'species': dict(a['spawns'].most_common()), 'water_species': dict(a['water_spawns'].most_common())})
    out.sort(key=lambda e: (e['region'], e['area'], e['z']))
    os.makedirs(os.path.dirname(args.json), exist_ok=True)
    json.dump({'areas': out, 'skipped': dict(unknown.most_common(40))}, open(args.json, 'w'), indent=1)

    tot = collections.defaultdict(lambda: [0, 0, 0, 0, []])
    for e in out:
        t = tot[(e['region'], e['floors'])]
        t[0] += e['land']
        t[1] += e['spawns']
        t[2] += e['water']
        t[3] += e['water_spawns']
    print('%-8s %-8s %10s %8s %8s %10s %8s %8s' % ('region', 'floors', 'ground', 'spawns', '/1000', 'water', 'spawns', '/1000'))
    for (r, fc), t in sorted(tot.items()):
        print('%-8s %-8s %10d %8d %8.2f %10d %8d %8.2f' % (r, fc, t[0], t[1], 1000.0 * t[1] / max(1, t[0]),
                                                         t[2], t[3], 1000.0 * t[3] / max(1, t[2])))


if __name__ == '__main__':
    main()
