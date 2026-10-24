#!/usr/bin/env python3
"""Writes Hoenn's area banner sections (the client's game_environment, areas_hoenn.lua).

    scripts/mapper/build_hoenn_areas.py [--map core/server/data/world/map.otbm] [--out <file>]

Hoenn came with the map and had no areas, so walking it never changed the area name. This names
every tile of Hoenn's box (79-weather.lua's Weather.REGIONS) on every floor, in this order (the
client takes the first area containing the player):

  buildings  each house (its house tiles), and the Pokemon Center and Mart rooms around the
             Nurse Joy and Mart NPCs (map-spawn.xml)
  caves      CAVES, on their own floors
  the rest   one name per column, cut into rectangles AREA_CELL tiles on a side, all floors:
             TOWNS (their houses' box and a margin), over LANDMARKS, over the nearest route in
             ROUTES (the route's road on land, its sea lane on water) within reach, else filler:
             "Around <town>" by a town, "Outskirts of <town>" further out, "Hoenn Sea" offshore.

Floors below ground take the name above them unless a cave claims them: the Dive floors under the
sea routes are those routes, the room under Rustboro's rock is Rustboro.

Names are Bulbapedia's (Ruby/Sapphire/Emerald) where the map has the place.
"""
import argparse
import collections
import os
import re
import struct
import sys

import numpy as np
from scipy import ndimage

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import pvmap  # noqa: E402
from build_johto import area_rects  # noqa: E402

ROOT = os.path.dirname(os.path.dirname(HERE))
WORLD = os.path.join(ROOT, 'core', 'server', 'data', 'world')
OUT = os.path.join(ROOT, 'core', 'client-redemption', 'pokeverse-modern', 'modules', 'game_environment',
                   'areas_hoenn.lua')

HOENN = (48, 773, 2224, 2304)
JOHTO = (1700, 20, 3048, 1270)  # checked first by the server, its box overlaps Hoenn's north-east sea
GROUND_Z = 7
AREA_CELL = 4
WATER_IDS = set(range(4608, 4626)) | {4664, 4665, 4666} | set(range(4820, 4826))
SAND_IDS = {231}

# The Pokemon Center and Mart prefabs around their NPC: (dx0, dy0, dx1, dy1)
ROOMS = {'Nurse Joy': (-7, -7, 6, 5), 'Mart': (-5, -1, 2, 6)}

TOWN_MARGIN = 8
AROUND = 30  # "Around <town>" this close to a town and away from a road
LAND_REACH = 55  # a route's name this far from its road on land
SEA_REACH = 140  # and from its lane at sea

# Town names are the map-house.xml names' first word(s) ("Rustboro House #04")
TOWNS = ['Littleroot', 'Oldale', 'Petalburg', 'Rustboro', 'Dewford', 'Slateport', 'Mauville', 'Verdanturf',
         'Fallarbor', 'Lavaridge', 'Fortree', 'Lilycove', 'Mossdeep', 'Sootopolis', 'Pacifidlog']
# Town boxes widened over what belongs to the town but has no house (Fortree's forest,
# Lilycove's beach, Slateport's beach, Sootopolis's crater).
TOWN_EXTRA = {
    'Fortree': (935, 1105, 1070, 1235),
    'Lilycove': (1300, 1275, 1445, 1370),
    'Slateport': (680, 1735, 810, 1850),
    'Sootopolis': (1495, 1500, 1645, 1625),
    'Mauville': (742, 1418, 832, 1500),
}

# Each route's road (land) or lane (sea), (x, y) points along it. Sea routes are the ones in SEA_ROUTES.
ROUTES = {
    '101': [(515, 1805), (520, 1760), (528, 1728)],
    '102': [(500, 1705), (465, 1702), (432, 1700)],
    '103': [(525, 1685), (515, 1630), (575, 1615), (640, 1612), (700, 1615)],
    '104': [(352, 1700), (300, 1705), (250, 1680), (225, 1620), (215, 1560), (225, 1540)],
    '105': [(150, 1700), (140, 1790), (160, 1870)],
    '106': [(185, 1920), (240, 1955), (300, 1975)],
    '107': [(470, 2010), (530, 2005), (575, 1995)],
    '108': [(600, 1990), (640, 1965), (670, 1940)],
    '109': [(730, 1850), (725, 1900), (720, 1950)],
    '110': [(745, 1725), (740, 1660), (745, 1600), (770, 1545), (790, 1505)],
    '111': [(790, 1415), (795, 1350), (800, 1250), (795, 1170), (790, 1110)],
    '112': [(740, 1440), (680, 1430), (630, 1400), (600, 1360)],
    '113': [(530, 1150), (600, 1148), (680, 1145), (760, 1120)],
    '114': [(415, 1170), (390, 1220), (380, 1300)],
    '115': [(230, 1450), (200, 1390), (175, 1320), (190, 1250)],
    '116': [(305, 1490), (360, 1485), (420, 1465), (450, 1450)],
    '117': [(570, 1515), (620, 1505), (680, 1495), (742, 1470)],
    '118': [(835, 1470), (880, 1495), (930, 1505)],
    '119': [(915, 1490), (920, 1420), (905, 1330), (900, 1250), (925, 1200), (945, 1170)],
    '120': [(1070, 1175), (1130, 1205), (1170, 1250), (1180, 1290)],
    '121': [(1185, 1300), (1240, 1315), (1300, 1312)],
    '122': [(1260, 1385), (1250, 1440), (1240, 1500)],
    '123': [(945, 1510), (1020, 1505), (1100, 1520), (1180, 1545), (1230, 1545)],
    '124': [(1450, 1320), (1530, 1350), (1610, 1390), (1680, 1420)],
    '125': [(1610, 1330), (1660, 1340), (1720, 1355), (1780, 1380)],
    '126': [(1450, 1470), (1440, 1560), (1460, 1640)],
    '127': [(1700, 1500), (1700, 1560), (1690, 1620)],
    '128': [(1680, 1680), (1750, 1700), (1810, 1720)],
    '129': [(1700, 1820), (1640, 1850), (1580, 1870)],
    '130': [(1540, 1880), (1480, 1880), (1420, 1860)],
    '131': [(1400, 1800), (1360, 1775), (1335, 1765)],
    '132': [(1265, 1765), (1200, 1775), (1140, 1785)],
    '133': [(1100, 1790), (1040, 1800), (980, 1810)],
    '134': [(940, 1820), (880, 1825), (830, 1830)],
}
SEA_ROUTES = {'105', '106', '107', '108', '122', '124', '125', '126', '127', '128', '129', '130', '131', '132',
              '133', '134'}

# name: shape, on land only. ('disc', x, y, r), ('box', x0, y0, x1, y1), ('sand', x0, y0, x1, y1): the
# sand in the box.
LANDMARKS = [
    ('Petalburg Woods', ('box', 222, 1568, 322, 1662)),
    ('Meteor Falls', ('box', 280, 1185, 470, 1395)),
    ('Mt. Chimney', ('disc', 575, 1215, 72)),
    ('Jagged Pass', ('box', 505, 1262, 650, 1318)),
    ('Route 111 Desert', ('sand', 705, 1140, 880, 1405)),
    ('Mt. Pyre', ('disc', 1245, 1430, 36)),
    ('Shoal Cave', ('disc', 1672, 1362, 26)),
    ('Ever Grande', ('box', 1820, 1515, 2000, 1800)),
]
# name, floors, box: the caves below ground
CAVES = [
    ('Granite Cave', (8, 9), (225, 1938, 343, 2009)),
    ('Rusturf Tunnel', (8, 9), (410, 1438, 522, 1486)),
    ('New Mauville', (8, 8), (739, 1505, 905, 1597)),
    ('Shoal Cave', (8, 8), (1648, 1348, 1692, 1382)),
]

TRACKS = {
    'Littleroot': 'random_city_05_10', 'Oldale': 'random_city_01_05', 'Petalburg': 'random_city_11_15',
    'Rustboro': 'random_city_21_27', 'Dewford': 'random_city_01_05', 'Slateport': 'random_city_16_20',
    'Mauville': 'random_city_21_27', 'Verdanturf': 'random_city_05_10', 'Fallarbor': 'random_city_11_15',
    'Lavaridge': 'city_26', 'Fortree': 'random_city_16_20', 'Lilycove': 'random_city_21_27',
    'Mossdeep': 'random_city_11_15', 'Sootopolis': 'city_26', 'Pacifidlog': 'random_city_01_05',
    'Route': 'jungle_01', 'Sea route': 'water_01', 'Hoenn Sea': 'water_01', 'Around': 'jungle_01',
    'Outskirts of': 'jungle_01', 'Petalburg Woods': 'jungle_02', 'Meteor Falls': 'waterfall_01',
    'Mt. Chimney': 'lava_01', 'Jagged Pass': 'wind_low_01', 'Route 111 Desert': 'wind_low_01',
    'Mt. Pyre': 'terror_01', 'Shoal Cave': 'cave_04', 'Granite Cave': 'cave_05', 'Rusturf Tunnel': 'cave_01',
    'New Mauville': 'cave_02', 'Pokemon Center': 'pokemon_center_01',
}


def track_of(name):
    if name in TRACKS:
        return TRACKS[name]
    m = re.match(r'Route (\d+)$', name)
    if m:
        return TRACKS['Sea route' if m.group(1) in SEA_ROUTES else 'Route']
    for prefix in ('Around', 'Outskirts of'):
        if name.startswith(prefix + ' '):
            return TRACKS[prefix]
    return None


def read_hoenn(path):
    """{(x, y, z): (house id, [item ids])} for Hoenn's box, every floor."""
    data = open(path, 'rb').read()
    x0, y0, x1, y1 = HOENN
    tiles = {}
    area = cur = None
    for ev, t, depth, a, b, _ in pvmap.walk(data):
        if ev != 'open':
            if t in (pvmap.TILE, pvmap.HOUSETILE):
                cur = None
            continue
        if t == pvmap.TILE_AREA:
            area = struct.unpack_from('<HHB', pvmap.unescape(data[a:b]), 0)
        elif t in (pvmap.TILE, pvmap.HOUSETILE):
            p = pvmap.unescape(data[a:b])
            x, y = area[0] + p[0], area[1] + p[1]
            if x0 <= x <= x1 and y0 <= y <= y1:
                _, _, house, _, item = pvmap.parse_tile_props(p, t == pvmap.HOUSETILE)
                cur = [house, [item] if item is not None else []]
                tiles[(x, y, area[2])] = cur
            else:
                cur = None
        elif t == pvmap.ITEM and depth == 4 and cur is not None:
            cur[1].append(struct.unpack_from('<H', pvmap.unescape(data[a:a + 4]), 0)[0])
    return tiles


def spawn_npcs(names):
    src = open(os.path.join(WORLD, 'map-spawn.xml'), encoding='latin-1').read()
    out = []
    for m in re.finditer(r'<spawn centerx="(\d+)" centery="(\d+)" centerz="(\d+)"[^>]*>(.*?)</spawn>', src, re.S):
        cx, cy = int(m.group(1)), int(m.group(2))
        for n in re.finditer(r'<npc name="([^"]+)" x="(-?\d+)" y="(-?\d+)" z="(\d+)"', m.group(4)):
            if n.group(1) in names:
                out.append((n.group(1), cx + int(n.group(2)), cy + int(n.group(3)), int(n.group(4))))
    return out


def in_box(x, y, box):
    return box[0] <= x <= box[2] and box[1] <= y <= box[3]


def room(tiles, x, y, z, footprint, reach=16):
    """The roofed room around (x, y, z): the tiles on z with a tile on the floor above, flooded from
    (x, y), kept to the prefab's footprint (dx0, dy0, dx1, dy1) around (x, y), as Mauville is one
    roofed plaza. Returns its box or None."""
    seen = {(x, y)}
    todo = [(x, y)]
    while todo:
        cx, cy = todo.pop()
        for nx, ny in ((cx + 1, cy), (cx - 1, cy), (cx, cy + 1), (cx, cy - 1)):
            if (nx, ny) in seen or abs(nx - x) > reach or abs(ny - y) > reach:
                continue
            if (nx, ny, z) in tiles and (nx, ny, z - 1) in tiles:
                seen.add((nx, ny))
                todo.append((nx, ny))
    if len(seen) < 9:
        return None
    xs, ys = [p[0] for p in seen], [p[1] for p in seen]
    dx0, dy0, dx1, dy1 = footprint
    return max(min(xs), x + dx0), max(min(ys), y + dy0), min(max(xs), x + dx1), min(max(ys), y + dy1)


def raster_lines(shape, x0, y0, lines):
    """An int grid with each line's points (and the steps between them) set to its index + 1."""
    g = np.zeros(shape, np.int32)
    for k, pts in enumerate(lines):
        for (ax, ay), (bx, by) in zip(pts, pts[1:]):
            n = max(abs(bx - ax), abs(by - ay), 1)
            for i in range(n + 1):
                g[round(ay + (by - ay) * i / n) - y0, round(ax + (bx - ax) * i / n) - x0] = k + 1
    return g


def build(map_path, out_path):
    x0, y0, x1, y1 = HOENN
    w, h = x1 - x0 + 1, y1 - y0 + 1
    tiles = read_hoenn(map_path)
    print('read %d tiles' % len(tiles))

    # columns: land (some ground that isn't water on the floors up to the ground floor)
    land = np.zeros((h, w), bool)
    sand = np.zeros((h, w), bool)
    top = {}
    for (x, y, z), (house, items) in tiles.items():
        if z <= GROUND_Z and items and ((x, y) not in top or z < top[(x, y)][0]):
            top[(x, y)] = (z, items[0])
    for (x, y), (z, g) in top.items():
        if g not in WATER_IDS:
            land[y - y0, x - x0] = True
        if g in SAND_IDS:
            sand[y - y0, x - x0] = True

    # towns: their houses' tiles
    houses = {}
    src = open(os.path.join(WORLD, 'map-house.xml'), encoding='latin-1').read()
    for m in re.finditer(r'<house name="([^"]*)" houseid="(\d+)"', src):
        houses[int(m.group(2))] = m.group(1)
    house_tiles = collections.defaultdict(list)
    for (x, y, z), (house, items) in tiles.items():
        if house:
            house_tiles[house].append((x, y, z))
    town_box = {}
    for hid, pts in house_tiles.items():
        town = next((t for t in TOWNS if houses.get(hid, '').startswith(t + ' ')), None)
        if not town:
            continue
        bx = town_box.get(town, (99999, 99999, -1, -1))
        town_box[town] = (min(bx[0], *(p[0] for p in pts)), min(bx[1], *(p[1] for p in pts)),
                          max(bx[2], *(p[0] for p in pts)), max(bx[3], *(p[1] for p in pts)))
    npcs = spawn_npcs({'Nurse Joy', 'Mart'})
    npcs = [n for n in npcs if in_box(n[1], n[2], HOENN) and not in_box(n[1], n[2], JOHTO)]
    for name, x, y, z in npcs:
        town = min(town_box, key=lambda t: max(town_box[t][0] - x, x - town_box[t][2], 0) +
                   max(town_box[t][1] - y, y - town_box[t][3], 0))
        bx = town_box[town]
        town_box[town] = (min(bx[0], x), min(bx[1], y), max(bx[2], x), max(bx[3], y))
    for town in TOWNS:
        assert town in town_box, 'no houses for %s' % town
        bx = town_box[town]
        bx = (bx[0] - TOWN_MARGIN, bx[1] - TOWN_MARGIN, bx[2] + TOWN_MARGIN, bx[3] + TOWN_MARGIN)
        if town in TOWN_EXTRA:
            e = TOWN_EXTRA[town]
            bx = (min(bx[0], e[0]), min(bx[1], e[1]), max(bx[2], e[2]), max(bx[3], e[3]))
        town_box[town] = bx

    # routes, then filler, landmarks and towns over them
    keys = list(ROUTES)
    seeds = raster_lines((h, w), x0, y0, [ROUTES[k] for k in keys])
    dist, (iy, ix) = ndimage.distance_transform_edt(seeds == 0, return_indices=True)
    nearest = seeds[iy, ix]
    route_names = np.array([''] + ['Route %s' % k for k in keys], object)
    area_of = route_names[nearest]
    area_of[(land & (dist > LAND_REACH)) | (~land & (dist > SEA_REACH))] = ''

    town_seed = np.zeros((h, w), np.int32)
    for k, town in enumerate(TOWNS):
        bx = town_box[town]
        town_seed[bx[1] - y0:bx[3] - y0 + 1, bx[0] - x0:bx[2] - x0 + 1] = k + 1
    tdist, (ty, tx) = ndimage.distance_transform_edt(town_seed == 0, return_indices=True)
    town_names = np.array([''] + TOWNS, object)
    near_town = town_names[town_seed[ty, tx]]
    road_dist = dist
    around = land & (tdist <= AROUND) & ((road_dist > 20) | (area_of == ''))
    area_of[around] = 'Around ' + near_town[around]
    out = land & (area_of == '')
    area_of[out] = 'Outskirts of ' + near_town[out]
    area_of[~land & (area_of == '')] = 'Hoenn Sea'

    yy, xx = np.mgrid[y0:y1 + 1, x0:x1 + 1]
    for name, shape in LANDMARKS:
        if shape[0] == 'disc':
            _, cx, cy, r = shape
            m = (xx - cx) ** 2 + (yy - cy) ** 2 <= r * r
        else:
            _, bx0, by0, bx1, by1 = shape
            m = (xx >= bx0) & (xx <= bx1) & (yy >= by0) & (yy <= by1)
            if shape[0] == 'sand':
                m &= ndimage.binary_closing(sand, iterations=3)
                lab, n = ndimage.label(m)
                if n:
                    m = lab == np.argmax(np.bincount(lab.ravel())[1:]) + 1
        area_of[m & land] = name
    for town in TOWNS:
        bx = town_box[town]
        area_of[bx[1] - y0:bx[3] - y0 + 1, bx[0] - x0:bx[2] - x0 + 1] = town
    area_of[(xx >= JOHTO[0]) & (xx <= JOHTO[2]) & (yy >= JOHTO[1]) & (yy <= JOHTO[3])] = ''

    # buildings and caves first
    first = []
    rooms = []
    for name, x, y, z in sorted(npcs, key=lambda n: n[0] != 'Nurse Joy'):
        if any(in_box(x, y, r) for r in rooms):
            continue
        r = room(tiles, x, y, z, ROOMS[name])
        if r:
            rooms.append(r)
            first.append(('Pokemon Center' if name == 'Nurse Joy' else 'Pokemon Mart', r[0], r[1], 0, r[2], r[3], GROUND_Z))
    for hid, pts in sorted(house_tiles.items()):
        xs, ys, zs = [p[0] for p in pts], [p[1] for p in pts], [p[2] for p in pts]
        if any(in_box(min(xs), min(ys), r) and in_box(max(xs), max(ys), r) for r in rooms):
            continue
        first.append(('House', min(xs), min(ys), min(zs), max(xs), max(ys), max(zs)))
    for name, (za, zb), (bx0, by0, bx1, by1) in CAVES:
        first.append((name, bx0, by0, za, bx1, by1, zb))

    rows = list(first)
    for ax0, ay0, ax1, ay1, name in area_rects(area_of, AREA_CELL):
        rows.append((name, ax0 + x0, ay0 + y0, 0, min(ax1 + x0, x1), min(ay1 + y0, y1), 15))
    lines = ['-- Generated by scripts/mapper/build_hoenn_areas.py; edit that, not this.',
             '-- { x0, y0, z0, x1, y1, z1, name, track }: sounds_pokeverse.lua adds them in order, the first',
             '-- containing the player wins.', 'AREAS_HOENN = {']
    for name, ax0, ay0, az0, ax1, ay1, az1 in rows:
        assert name.isascii() and '"' not in name, name
        track = track_of(name)
        lines.append('    { %d, %d, %d, %d, %d, %d, "%s"%s },' % (ax0, ay0, az0, ax1, ay1, az1, name,
                                                                 ', "%s"' % track if track else ''))
    lines.append('}')
    with open(out_path, 'w', newline='\n') as f:
        f.write('\n'.join(lines) + '\n')
    names = collections.Counter(r[0] for r in rows)
    print('wrote %s: %d areas, %d buildings, %d names' % (out_path, len(rows), len(first), len(names)))
    return area_of


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--map', default=os.path.join(WORLD, 'map.otbm'))
    ap.add_argument('--out', default=OUT)
    args = ap.parse_args()
    build(args.map, args.out)


if __name__ == '__main__':
    main()
