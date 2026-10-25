#!/usr/bin/env python3
"""Checks an OTBM map the way the server's loader would see it.

    scripts/mapper/verify.py [mapper/map/johto-wip.otbm] [--items core/server/data/items/items.otb]

Reports broken node structure, tiles stored twice, item ids missing from items.otb, house tiles
whose house is not in the house file, and spawns placed on missing or blocked tiles.
"""
import argparse
import collections
import os
import re
import struct
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import pvmap  # noqa: E402

ROOT = os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..'))


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('map', nargs='?', default=os.path.join(ROOT, 'mapper', 'map', 'johto-wip.otbm'))
    ap.add_argument('--items', default=os.path.join(ROOT, 'core', 'server', 'data', 'items', 'items.otb'))
    args = ap.parse_args()
    folder = os.path.dirname(os.path.abspath(args.map))
    otb = pvmap.Otb(args.items)
    data = open(args.map, 'rb').read()

    problems = []
    seen = set()
    dupes = 0
    unknown = collections.Counter()
    house_tiles = collections.Counter()
    towns = []
    tiles = 0
    area = None
    pos = None
    depth_ok = True
    blocking = set()
    for ev, t, depth, a, b, _ in pvmap.walk(data):
        if ev == 'close':
            if t == pvmap.ROOT and depth != 0:
                depth_ok = False
            continue
        if t == pvmap.TILE_AREA:
            area = struct.unpack_from('<HHB', pvmap.unescape(data[a:b]), 0)
        elif t in (pvmap.TILE, pvmap.HOUSETILE):
            p = pvmap.unescape(data[a:b])
            pos = (area[0] + p[0], area[1] + p[1], area[2])
            tiles += 1
            if pos in seen:
                dupes += 1
            seen.add(pos)
            _, _, house_id, _, item = pvmap.parse_tile_props(p, t == pvmap.HOUSETILE)
            if house_id:
                house_tiles[house_id] += 1
            if item is not None:
                if item not in otb.items:
                    unknown[item] += 1
                if otb.blocks(item):
                    blocking.add(pos)
        elif t == pvmap.ITEM and depth == 4:
            sid = struct.unpack_from('<H', pvmap.unescape(data[a:a + 4]), 0)[0]
            if sid not in otb.items:
                unknown[sid] += 1
            if otb.blocks(sid):
                blocking.add(pos)
        elif t == pvmap.TOWN:
            p = pvmap.unescape(data[a:b])
            tid = struct.unpack_from('<I', p, 0)[0]
            n = struct.unpack_from('<H', p, 4)[0]
            towns.append((tid, p[6:6 + n].decode('latin-1'), struct.unpack_from('<HHB', p, 6 + n)))
    if not depth_ok:
        problems.append('node tree does not close properly')
    if dupes:
        problems.append('%d tiles are stored twice' % dupes)
    if unknown:
        problems.append('item ids missing from items.otb: %s' % dict(unknown.most_common(10)))

    house_file = os.path.join(folder, 'map-house.xml')
    houses = {}
    if os.path.exists(house_file):
        for m in re.finditer(r'<house [^>]*/>', open(house_file, encoding='latin-1').read()):
            attrs = dict(re.findall(r'(\w+)="([^"]*)"', m.group(0)))
            if int(attrs['houseid']) in houses:
                problems.append('house id %s is used twice in map-house.xml' % attrs['houseid'])
            houses[int(attrs['houseid'])] = attrs
    missing_houses = [h for h in house_tiles if h not in houses]
    if missing_houses:
        problems.append('house tiles for houses missing from map-house.xml: %s' % sorted(missing_houses)[:20])
    for hid, attrs in houses.items():
        if hid in house_tiles:
            entry = (int(attrs['entryx']), int(attrs['entryy']), int(attrs['entryz']))
            if entry not in seen:
                problems.append('house %d entry %s has no tile' % (hid, entry))

    spawn_file = os.path.join(folder, 'map-spawn.xml')
    bad_spawns = []
    n_spawns = 0
    if os.path.exists(spawn_file):
        src = open(spawn_file, encoding='latin-1').read()
        for m in re.finditer(r'<spawn centerx="(\d+)" centery="(\d+)" centerz="(\d+)"[^>/]*>(.*?)</spawn>', src, re.S):
            cx, cy, cz = int(m.group(1)), int(m.group(2)), int(m.group(3))
            for c in re.finditer(r'<(monster|npc) name="([^"]+)" x="(-?\d+)" y="(-?\d+)"', m.group(4)):
                n_spawns += 1
                p = (cx + int(c.group(3)), cy + int(c.group(4)), cz)
                if p not in seen or p in blocking:
                    bad_spawns.append((c.group(2), p))
    print('%d tiles, %d towns, %d houses with tiles, %d spawned creatures' % (tiles, len(towns), len(house_tiles), n_spawns))
    print('last towns: %s' % towns[-3:])
    if bad_spawns:
        print('note: %d creatures spawn on a missing or blocked tile: %s' % (len(bad_spawns), bad_spawns[:80]))
    if problems:
        for p in problems:
            print('PROBLEM: ' + p)
        sys.exit(1)
    print('ok')


if __name__ == '__main__':
    main()
