#!/usr/bin/env python3
"""Renders the Trainer Card's hometown scenes from the map: one small picture per town.

    scripts/art/trainercard_scenes.py [--map core/server/data/world/map.otbm] [--preview out.png]

Each scene is COLS x ROWS tiles at 32 px, saved at 1x (the card shows it at 2x without smoothing):
game_trainercard/images/scenes/<town id>.png, plus default.png (Pallet) for towns without one.
The spot is the nearest open-air place to the town's temple where the bottom row, the one the
trainer walks on, has no blocking items, nothing is under a roof or an upper floor, and no house
tiles. SPOTS overrides the automatic pick with a top-left tile for a town.
"""
import argparse
import json
import os
import struct
import sys

from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.normpath(os.path.join(HERE, '..', '..'))
sys.path.insert(0, os.path.join(ROOT, 'scripts', 'mapper'))
import pvmap  # noqa: E402
from render import Renderer  # noqa: E402

OUT = os.path.join(ROOT, 'core/client-redemption/pokeverse-modern/modules/game_trainercard/images/scenes')
COLS, ROWS = 4, 3
SEARCH = 22  # tiles around the temple
DEFAULT_TOWN = 32  # Pallet
TOWNS_CACHE = '/tmp/trainercard_towns.json'  # reading the towns takes a pass over the whole map
SPOTS = {}  # town id -> (x, y): the scene's top-left tile on the temple's floor


def read_map(path, boxes):
    """One pass over the map: towns, and {(x, y, z): (items, house)} for tiles inside any box."""
    data = open(path, 'rb').read()
    tiles, towns = {}, []
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
            x, y, z = area[0] + p[0], area[1] + p[1], area[2]
            cur = None
            for x0, y0, x1, y1, zmax in boxes:
                if x0 <= x <= x1 and y0 <= y <= y1 and z <= zmax:
                    _, _, _, _, item = pvmap.parse_tile_props(p, t == pvmap.HOUSETILE)
                    cur = []
                    if item is not None:
                        cur.append(item)
                    tiles[(x, y, z)] = (cur, t == pvmap.HOUSETILE)
                    break
        elif t == pvmap.ITEM and cur is not None and depth == 4:
            cur.append(struct.unpack_from('<H', pvmap.unescape(data[a:a + 4]), 0)[0])
        elif t == pvmap.TOWN:
            p = pvmap.unescape(data[a:b])
            n = struct.unpack_from('<H', p, 4)[0]
            x, y, z = struct.unpack_from('<HHB', p, 6 + n)
            towns.append((struct.unpack_from('<I', p, 0)[0], p[6:6 + n].decode('latin-1'), x, y, z))
    return tiles, towns


def town_list(path):
    """The towns, from a cache next to the scenes (reading them needs the whole map)."""
    cache = TOWNS_CACHE
    if os.path.exists(cache):
        return [tuple(t) for t in json.load(open(cache))]
    _, towns = read_map(path, [])
    return towns


def open_air(tiles, x, y, z):
    for s in range(1, z + 1):
        for dx in (0, 1):
            for dy in (0, 1):
                if (x + s - 1 + dx, y + s - 1 + dy, z - s) in tiles:
                    return False
    return True


def pick(tiles, otb, town):
    _, _, tx, ty, z = town
    best = None
    for y in range(ty - SEARCH, ty + SEARCH - ROWS):
        for x in range(tx - SEARCH, tx + SEARCH - COLS):
            ok, detail = True, 0
            for j in range(ROWS):
                for i in range(COLS):
                    tile = tiles.get((x + i, y + j, z))
                    if not tile or not tile[0] or tile[1] or not open_air(tiles, x + i, y + j, z):
                        ok = False
                        break
                    items = tile[0]
                    if j == ROWS - 1 and any(otb.blocks(sid) for sid in items):
                        ok = False
                        break
                    detail += len(items) - 1
                if not ok:
                    break
            if ok:
                distance = abs(x + COLS / 2 - tx) + abs(y + ROWS / 2 - ty)
                score = 0.4 * distance - min(detail, 14)
                if best is None or score < best[0]:
                    best = (score, x, y)
    return best and (best[1], best[2])


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--map', default=os.path.join(ROOT, 'core/server/data/world/map.otbm'))
    ap.add_argument('--preview')
    args = ap.parse_args()
    os.makedirs(OUT, exist_ok=True)

    towns = [t for t in town_list(args.map) if t[2] > 0]
    boxes = [(x - SEARCH - 4, y - SEARCH - 4, x + SEARCH + 12, y + SEARCH + 12, z) for _, _, x, y, z in towns]
    tiles, read = read_map(args.map, boxes)
    if read:
        towns = [t for t in read if t[2] > 0]
        json.dump(read, open(TOWNS_CACHE, 'w'))

    r = Renderer(os.path.join(ROOT, 'core/server/data/items/items.otb'),
                 os.path.join(ROOT, 'core/client-legacy/data/things/data.dat'),
                 os.path.join(ROOT, 'core/client-legacy/data/things/data.spr'))
    items = {pos: tile[0] for pos, tile in tiles.items()}
    scenes = []
    for town in towns:
        tid, name, _, _, z = town
        spot = SPOTS.get(tid) or pick(tiles, r.otb, town)
        if not spot:
            print('no spot for %s' % name)
            continue
        x, y = spot
        img = r.render(items, x, y, x + COLS - 1, y + ROWS - 1, z).convert('RGB')
        img.save(os.path.join(OUT, '%d.png' % tid), optimize=True)
        if tid == DEFAULT_TOWN:
            img.save(os.path.join(OUT, 'default.png'), optimize=True)
        scenes.append((name, img))
        print('%-18s %d,%d,%d' % (name, x, y, z))

    if args.preview:
        per = 8
        w, h = COLS * 32 * 2, ROWS * 32 * 2
        sheet = Image.new('RGB', (per * w, ((len(scenes) + per - 1) // per) * h))
        for k, (_, img) in enumerate(scenes):
            sheet.paste(img.resize((w, h), Image.NEAREST), ((k % per) * w, (k // per) * h))
        sheet.save(args.preview)


if __name__ == '__main__':
    main()
