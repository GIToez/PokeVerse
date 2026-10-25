#!/usr/bin/env python3
"""Repaints the stray dark patches of mountain top ground on the surface as the lighter rocky ground.

    scripts/mapper/fix_rock_borders.py <map.otbm> [--out map.otbm] [--max-size 12]

Mountain top ground (rocks, 4405-4421) is the dark grey floor of mountain tops. Small patches of it
were painted on the surface floor where the grey around them is the lighter rocky ground (4570-4579)
and its stone border, so they show as hard dark squares (Viridian Forest has several). A patch
(4-connected rock ground on floor 7) of at most --max-size tiles gets rocky ground when it touches
rocky ground, or when it sits in grass and dirt (some of it dirt) with no mountain item on or next
to it. The stone border (RME border 20) stays: the map draws it round rocky ground as well. Bigger
patches, and mountain tops, are left as they are. Without --out it only counts and lists the patches.
"""
import argparse
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import autoborder  # noqa: E402
import pvmap  # noqa: E402

ROCKY = list(range(4570, 4580))
SURFACE = 7  # above it the rock ground is the top of a mountain
MOUNTAIN_ITEMS = set(range(903, 914)) | {918, 919} | set(range(4468, 4514))
SIDES = ((1, 0), (-1, 0), (0, 1), (0, -1))


def stray_patches(tiles, brushes, max_size):
    rock = brushes['mountain top ground']
    rocky = brushes['rocky ground']
    dirt = brushes['dirt']
    open_ground = {dirt, brushes['grass']}

    def is_rock(pos):
        ids = tiles.get(pos)
        return pos[2] == SURFACE and bool(ids) and brushes.by_item.get(ids[0]) is rock

    seen = set()
    for start in tiles:
        if start in seen or not is_rock(start):
            continue
        patch, todo = [], [start]
        seen.add(start)
        while todo:
            x, y, z = todo.pop()
            patch.append((x, y, z))
            for dx, dy in SIDES:
                q = (x + dx, y + dy, z)
                if q not in seen and is_rock(q):
                    seen.add(q)
                    todo.append(q)
        if len(patch) > max_size:
            continue
        touches_dirt, touches_rocky, near_mountain, other = False, False, False, False
        for x, y, z in patch:
            for dx, dy in autoborder.NEIGHBOURS + ((0, 0),):
                ids = tiles.get((x + dx, y + dy, z))
                if not ids:
                    continue
                if any(i in MOUNTAIN_ITEMS for i in ids):
                    near_mountain = True
                if (dx, dy) in SIDES and not is_rock((x + dx, y + dy, z)):
                    ground = brushes.by_item.get(ids[0])
                    touches_dirt = touches_dirt or ground is dirt
                    touches_rocky = touches_rocky or ground is rocky
                    other = other or ground not in open_ground
        if touches_rocky or (touches_dirt and not near_mountain and not other):
            yield patch


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('map')
    ap.add_argument('--out')
    ap.add_argument('--max-size', type=int, default=12)
    args = ap.parse_args()

    data = open(args.map, 'rb').read()
    brushes = autoborder.Brushes()
    tiles = pvmap.read_region(args.map, 0, 0, 0xFFFF, 0xFFFF, data=data)
    patches = sorted(stray_patches(tiles, brushes, args.max_size), key=len, reverse=True)
    positions = [p for patch in patches for p in patch]
    print('%d stray rock patches, %d tiles' % (len(patches), len(positions)))
    for patch in patches:
        x, y, z = min(patch)
        print('  %d,%d,%d  %d tiles' % (x, y, z, len(patch)))
    if not args.out:
        return
    raw = pvmap.read_tiles_raw(args.map, set(positions), data=data)
    for (x, y, z), tile in raw.items():
        ground = ROCKY[(x * 7 + y * 13) % len(ROCKY)]
        if tile.ground is not None:
            tile.ground = ground
        else:
            items = pvmap.split_items(tile.children)
            items[0] = pvmap.item_node(ground)
            tile.children = b''.join(items)
    pvmap.write_map(data, args.out, raw)
    print('wrote', args.out)


if __name__ == '__main__':
    main()
