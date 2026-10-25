#!/usr/bin/env python3
"""Turns the stray patches of mountain top ground left in grass and dirt paths into dirt.

    scripts/mapper/fix_rock_borders.py <map.otbm> [--out map.otbm] [--max-size 12]

Mountain top ground (rocks, 4405-4421) is the grey floor of mountain tops. Small patches of it were
painted into dirt paths on the surface floor away from any mountain (Viridian Forest has several),
where it shows as hard grey squares under the grass border. A patch (4-connected rock ground on
floor 7) of at most --max-size tiles, with only grass and dirt beside it (some of it dirt) and no
mountain item on or next to it, gets dirt (103) as its ground; its stone border comes off the tiles
around it that no other rock ground is next to. Bigger patches set in grass, and rock in stone or
sand areas, are left as they are. The grass border on it stays right: grass borders dirt and rock
with the same border. Without --out it only counts and lists the patches.
"""
import argparse
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import autoborder  # noqa: E402
import pvmap  # noqa: E402

DIRT = 103
SURFACE = 7  # above it the rock ground is the top of a mountain
STONE_BORDER = set(range(4514, 4526))  # the rock ground's own border (RME border 20)
MOUNTAIN_ITEMS = set(range(903, 914)) | {918, 919} | set(range(4468, 4514))
SIDES = ((1, 0), (-1, 0), (0, 1), (0, -1))


def stray_patches(tiles, brushes, max_size):
    rock = brushes['mountain top ground']
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
        touches_dirt, near_mountain, other = False, False, False
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
                    other = other or ground not in open_ground
        if touches_dirt and not near_mountain and not other:
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
    converted = set(positions)
    rock = brushes['mountain top ground']

    def rock_left_near(x, y, z):
        for dx, dy in autoborder.NEIGHBOURS + ((0, 0),):
            q = (x + dx, y + dy, z)
            ids = tiles.get(q)
            if q not in converted and ids and brushes.by_item.get(ids[0]) is rock:
                return True
        return False

    around = {(x + dx, y + dy, z) for x, y, z in converted for dx, dy in autoborder.NEIGHBOURS + ((0, 0),)}
    unbordered = {q for q in around if q in tiles and not rock_left_near(*q)
                  and any(i in STONE_BORDER for i in tiles[q][1:])}
    raw = pvmap.read_tiles_raw(args.map, converted | unbordered, data=data)
    for pos, tile in raw.items():
        items = pvmap.split_items(tile.children)
        if pos in converted:
            if tile.ground is not None:
                tile.ground = DIRT
            else:
                items[0] = pvmap.item_node(DIRT)
        if pos in unbordered:
            items = [blob for blob in items if pvmap.child_item_ids(blob)[0] not in STONE_BORDER]
        tile.children = b''.join(items)
    print('stone border taken off %d tiles' % len(unbordered))
    pvmap.write_map(data, args.out, raw)
    print('wrote', args.out)


if __name__ == '__main__':
    main()
