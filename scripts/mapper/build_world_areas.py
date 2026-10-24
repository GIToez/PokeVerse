#!/usr/bin/env python3
"""Writes the area banner's fallback names (the client's game_environment, areas_world.lua).

    scripts/mapper/build_world_areas.py [--map core/server/data/world/map.otbm] [--out <file>]

The client looks these up after Johto's and Hoenn's areas and the legacy (Kanto, Orange Islands)
ones, before the region names (sounds_pokeverse.lua's SOUNDS_FALLBACK), so they only name what
nothing else does and can cover whole seas. On floors 0-7:

  Johto's edges  land in Johto's box (and the strip east of it by Routes 26-28, which Kanto's
                 areas leave out) takes the nearest of Johto's outdoor names (areas_johto.lua)
  Kanto's gaps   land the legacy areas leave out: Route 2's road (which has none), then the
                 nearest legacy outdoor name within KANTO_GAP tiles (the Orange Islands too;
                 seams of KANTO_SEAM tiles between legacy areas first)
  the seas       water takes the nearest sea route's lane within reach (Johto's Routes 40 and
                 41, Kanto's 19, 20 and 21), else in the Orange Islands the nearest island's
                 "<island> Waters", else the region's sea ("Johto Sea", "Kanto Sea", "Orange
                 Archipelago"). Hoenn's sea is in areas_hoenn.lua.

Run it again after Johto's areas change (build_johto.py).
"""
import argparse
import os
import re
import struct
import subprocess
import sys

import numpy as np
from scipy import ndimage

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import pvmap  # noqa: E402
from build_johto import AREA_BUILDINGS, AREA_GYMS, SEA_LINES, SHIP, WRECK, area_rects  # noqa: E402
from build_map_labels import CITIES  # noqa: E402

ROOT = os.path.dirname(os.path.dirname(HERE))
WORLD = os.path.join(ROOT, 'core', 'server', 'data', 'world')
ENV = os.path.join(ROOT, 'core', 'client-redemption', 'pokeverse-modern', 'modules', 'game_environment')
OUT = os.path.join(ENV, 'areas_world.lua')

W, H = 4690, 3531  # the surface; past x 4690 are the instances
FLOORS = (0, 7)
AREA_CELL = 4
WATER_IDS = set(range(4608, 4626)) | {4664, 4665, 4666} | set(range(4820, 4826))

JOHTO = (1700, 20, 3048, 1270)
ORANGE = (2641, 1311, 4647, 3486)
HOENN = (48, 773, 2224, 2304)
JOHTO_STRIP = (3049, 250, 3170, 1000)
JOHTO_EDGE = 160  # how far Johto's land names reach out to its coasts

# Sea routes with no area at sea: their lanes, (x, y) points
SEA_LANES = {
    'johto': {'Route 40': SEA_LINES['40'], 'Route 41': SEA_LINES['41']},
    'kanto': {
        'Route 19': [(3860, 905), (3855, 990)],
        'Route 20': [(3840, 1000), (3700, 1005), (3600, 995), (3420, 1010)],
        'Route 21': [(3292, 840), (3300, 900), (3330, 950)],
    },
}
LAND_LANES = {'Route 02': [(3296, 545), (3300, 430), (3305, 315)]}
LAND_LANE_REACH = 30
KANTO_SEAM = 4  # seams between legacy areas, before the lanes
KANTO_GAP = 12
LEGACY = os.path.join(ROOT, 'core', 'client-legacy', 'modules', 'game_environment')
LEGACY_OFFSET_X = 2351
LANE_REACH = 90
ISLAND_WATERS = 70
SEAS = {'johto': 'Johto Sea', 'kanto': 'Kanto Sea', 'orange': 'Orange Archipelago'}
TRACKS = {'Johto Sea': 'water_01', 'Kanto Sea': 'water_01', 'Orange Archipelago': 'water_01',
          'Waters': 'water_01', 'Route 02': 'random_city_01_05', 'Route 19': 'swamp_03', 'Route 20': 'swamp_03', 'Route 21': 'swamp_03'}


def top_grounds(path):
    """The ground of each column's highest tile on floors 0-7 (0: none), H x W."""
    data = open(path, 'rb').read()
    ground = np.zeros((H, W), np.uint16)
    top_z = np.full((H, W), 99, np.int8)
    area = None
    pending = None  # a tile whose ground is its first item node
    for ev, t, depth, a, b, _ in pvmap.walk(data):
        if ev != 'open':
            if t in (pvmap.TILE, pvmap.HOUSETILE):
                pending = None
            continue
        if t == pvmap.TILE_AREA:
            area = struct.unpack_from('<HHB', pvmap.unescape(data[a:b]), 0)
        elif t in (pvmap.TILE, pvmap.HOUSETILE):
            pending = None
            p = pvmap.unescape(data[a:b])
            x, y = area[0] + p[0], area[1] + p[1]
            if area[2] <= FLOORS[1] and x < W and y < H and area[2] < top_z[y, x]:
                item = pvmap.parse_tile_props(p, t == pvmap.HOUSETILE)[4]
                if item is not None:
                    ground[y, x] = item
                    top_z[y, x] = area[2]
                else:
                    pending = (x, y, area[2])
        elif t == pvmap.ITEM and depth == 4 and pending:
            x, y, z = pending
            ground[y, x] = struct.unpack_from('<H', pvmap.unescape(data[a:a + 4]), 0)[0]
            top_z[y, x] = z
            pending = None
    return ground


def johto_names():
    """Johto's outdoor names on the ground floor (areas_johto.lua's first match), and their tracks."""
    rows = re.findall(r'\{ (\d+), (\d+), (\d+), (\d+), (\d+), (\d+), "([^"]+)"(?:, "([^"]+)")? \}',
                      open(os.path.join(ENV, 'areas_johto.lua')).read())
    skip = set(AREA_BUILDINGS.values()) | set(AREA_GYMS.values()) | {'House', WRECK['name'], SHIP['name']}
    names, tracks = [''], {}
    grid = np.zeros((H, W), np.int32)
    for r in reversed(rows):
        x0, y0, z0, x1, y1, z1 = map(int, r[:6])
        name = r[6]
        if name in skip or not (z0 <= 7 <= z1) or z0 > 0:
            continue
        if name not in names:
            names.append(name)
        tracks[name] = r[7] or None
        grid[y0:y1 + 1, x0:x1 + 1] = names.index(name)
    return grid, names, tracks


LEGACY_DUMP = r'''
dofile(LEGACY .. '/sounds1.lua')
dofile(LEGACY .. '/sounds2.lua')
local all = {}
for k, v in pairs(SOUNDS1) do all[k] = v end
for k, v in pairs(SOUNDS2) do all[k] = v end
for i = 1, #all do
    local a = all[i]
    io.write(a[8] or '', '\t', a.fromPos.x + OFFSET, '\t', a.fromPos.y, '\t', a.fromPos.z, '\t',
        a.toPos.x + OFFSET, '\t', a.toPos.y, '\t', a.toPos.z, '\n')
end
'''


def legacy_names():
    """The legacy areas' outdoor names on the ground floor (first match), as johto_names."""
    script = 'LEGACY = %r; OFFSET = %d\n%s' % (LEGACY, LEGACY_OFFSET_X, LEGACY_DUMP)
    text = subprocess.run(['lua', '-e', script], check=True, capture_output=True, text=True).stdout
    src = open(os.path.join(ENV, 'area_names.lua')).read()
    building = re.findall(r'"([^"]+)"', src[src.index('BUILDING_WORDS'):src.index('THEME_WORDS')])
    renames = [(a, b, int(x0), int(y0), int(x1), int(y1)) for a, b, x0, y0, x1, y1 in re.findall(
        r'from = "([^"]+)", to = "([^"]+)", fromPos = \{ x = (\d+), y = (\d+), z = \d+ \}, '
        r'toPos = \{ x = (\d+), y = (\d+)', open(os.path.join(ENV, 'sounds_pokeverse.lua')).read())]
    names = ['']
    grid = np.zeros((H, W), np.int32)
    for line in reversed(text.splitlines()):
        name, *coords = line.split('\t')
        x0, y0, z0, x1, y1, z1 = (int(v) for v in coords)
        for old, new, bx0, by0, bx1, by1 in renames:
            if name == old and bx0 <= x0 and x1 <= bx1 and by0 <= y0 and y1 <= by1:
                name = new
        if not name or any(word in name for word in building) or not (z0 <= 7 <= z1):
            continue
        if name not in names:
            names.append(name)
        grid[max(y0, 0):y1 + 1, max(x0, 0):min(x1, W - 1) + 1] = names.index(name)
    return grid, names


def box_mask(box):
    m = np.zeros((H, W), bool)
    m[box[1]:box[3] + 1, box[0]:box[2] + 1] = True
    return m


def lane_grid(lanes):
    g = np.zeros((H, W), np.int32)
    for k, pts in enumerate(lanes):
        for (ax, ay), (bx, by) in zip(pts, pts[1:]):
            n = max(abs(bx - ax), abs(by - ay), 1)
            for i in range(n + 1):
                g[round(ay + (by - ay) * i / n), round(ax + (bx - ax) * i / n)] = k + 1
    return g


def build(map_path, out_path):
    ground = top_grounds(map_path)
    water = (ground == 0) | np.isin(ground, list(WATER_IDS))
    land = ~water
    johto, orange, hoenn = box_mask(JOHTO), box_mask(ORANGE) & ~box_mask(JOHTO), box_mask(HOENN) & ~box_mask(JOHTO)
    kanto = ~johto & ~orange & ~hoenn
    print('read the map')

    names = ['']
    tracks = {}

    def name_id(name):
        if name not in names:
            names.append(name)
        return names.index(name)

    out = np.zeros((H, W), np.int32)

    # Johto's edges
    jgrid, jnames, jtracks = johto_names()
    tracks.update(jtracks)
    dist, (iy, ix) = ndimage.distance_transform_edt(jgrid == 0, return_indices=True)
    edge = land & (johto | box_mask(JOHTO_STRIP)) & (jgrid == 0) & (dist <= JOHTO_EDGE)
    ids = np.array([name_id(n) if n else 0 for n in jnames], np.int32)
    out[edge] = ids[jgrid[iy[edge], ix[edge]]]

    # Kanto's (and the Orange Islands') gaps
    lgrid, lnames = legacy_names()
    gaps = land & (kanto | orange) & (lgrid == 0) & (out == 0)
    ld, (gy, gx) = ndimage.distance_transform_edt(lgrid == 0, return_indices=True)
    ids = np.array([name_id(n) if n else 0 for n in lnames], np.int32)
    near = gaps & (ld <= KANTO_SEAM)
    out[near] = ids[lgrid[gy[near], gx[near]]]
    gaps &= ~near
    g = lane_grid(list(LAND_LANES.values()))
    d, (ly, lx) = ndimage.distance_transform_edt(g == 0, return_indices=True)
    lane_ids = np.array([0] + [name_id(n) for n in LAND_LANES], np.int32)
    near = gaps & (d <= LAND_LANE_REACH)
    out[near] = lane_ids[g[ly[near], lx[near]]]
    gaps &= ~near
    near = gaps & (ld <= KANTO_GAP)
    out[near] = ids[lgrid[gy[near], gx[near]]]

    # the seas: sea route lanes, island waters, the region's sea
    for region, mask in (('johto', johto), ('kanto', kanto), ('orange', orange)):
        sea = water & mask
        lanes = SEA_LANES.get(region, {})
        if lanes:
            g = lane_grid(list(lanes.values()))
            d, (ly, lx) = ndimage.distance_transform_edt(g == 0, return_indices=True)
            lane_ids = np.array([0] + [name_id(n) for n in lanes], np.int32)
            near = sea & (d <= LANE_REACH)
            out[near] = lane_ids[g[ly[near], lx[near]]]
            sea &= ~near
        if region == 'orange':
            islands, n = ndimage.label(ndimage.binary_dilation(land & mask, iterations=4))
            cities = [(c, x, y) for c, x, y in CITIES if ORANGE[0] <= x <= ORANGE[2] and ORANGE[1] <= y <= ORANGE[3]]
            seed = np.zeros((H, W), np.int32)
            for k, sl in enumerate(ndimage.find_objects(islands)):
                ys, xs = np.nonzero(islands[sl] == k + 1)
                cy, cx = ys.mean() + sl[0].start, xs.mean() + sl[1].start
                city, d2 = min(((c, (x - cx) ** 2 + (y - cy) ** 2) for c, x, y in cities), key=lambda t: t[1])
                if d2 <= 150 ** 2:
                    name = re.sub(r' (North|South)$', '', city) + ' Waters'
                    seed[sl][islands[sl] == k + 1] = name_id(name)
            d, (sy, sx) = ndimage.distance_transform_edt(seed == 0, return_indices=True)
            near = sea & (d <= ISLAND_WATERS)
            out[near] = seed[sy[near], sx[near]]
            sea &= ~near
        out[sea] = name_id(SEAS[region])

    # a cell takes a name of its land if it has any (a path along the shore keeps its name), the
    # tiles nearest its middle first
    c = AREA_CELL
    h, w = H // c, W // c
    tiles = out[:h * c, :w * c].reshape(h, c, w, c)
    on_land = land[:h * c, :w * c].reshape(h, c, w, c)
    order = sorted(((dy, dx) for dy in range(c) for dx in range(c)),
                   key=lambda p: (p[0] - (c - 1) / 2) ** 2 + (p[1] - (c - 1) / 2) ** 2)
    cells = np.zeros((h, w), np.int32)
    for want_land in (True, False):
        for dy, dx in order:
            t = tiles[:, dy, :, dx]
            pick = (cells == 0) & (t != 0) & (on_land[:, dy, :, dx] if want_land else True)
            cells[pick] = t[pick]
    rows = [(names[label], ax0 * c, ay0 * c, FLOORS[0], (ax1 + 1) * c - 1, (ay1 + 1) * c - 1, FLOORS[1])
            for ax0, ay0, ax1, ay1, label in area_rects(cells, 1)]
    lines = ['-- Generated by scripts/mapper/build_world_areas.py; edit that, not this.',
             '-- { x0, y0, z0, x1, y1, z1, name, track }: sounds_pokeverse.lua adds them to SOUNDS_FALLBACK',
             '-- in order, the first containing the player wins.', 'AREAS_WORLD = {']
    for name, ax0, ay0, az0, ax1, ay1, az1 in rows:
        assert name.isascii() and '"' not in name, name
        track = tracks.get(name) or TRACKS.get(name) or (TRACKS['Waters'] if name.endswith(' Waters') else None)
        lines.append('    { %d, %d, %d, %d, %d, %d, "%s"%s },' % (ax0, ay0, az0, min(ax1, W - 1), min(ay1, H - 1), az1,
                                                                 name, ', "%s"' % track if track else ''))
    lines.append('}')
    with open(out_path, 'w', newline='\n') as f:
        f.write('\n'.join(lines) + '\n')
    print('wrote %s: %d areas, %d names' % (out_path, len(rows), len(set(r[0] for r in rows))))


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--map', default=os.path.join(WORLD, 'map.otbm'))
    ap.add_argument('--out', default=OUT)
    args = ap.parse_args()
    build(args.map, args.out)


if __name__ == '__main__':
    main()
