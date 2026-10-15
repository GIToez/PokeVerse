#!/usr/bin/env python3
"""Renders the Pokepedia's house pictures from the server map with the client sprites.

    scripts/mapper/render_pokepedia.py [--out build/map-pictures] [--jobs 4]

One picture per house floor, <out>/houses/<house id>_<z>.png: the house's tiles and a few tiles
around them, without the floors above so the rooms show. <out>/houses/index.json maps each house
id and floor to [x, y, w, h, pixel width, pixel height]: the picture's top-left tile, its size in
tiles and in pixels, min(16, 512 / longest side) pixels per tile.

The pictures are not kept in the repository: the client release renders them (cached until the
map or the sprites change), and scripts/assemble-redemption-client.sh copies <out> into the
client's data/images/pokepedia when it exists. Without them the Houses tab shows the minimap.

Reads core/server/data/world/map.otbm, items.otb, and the client's data.dat and data.spr.
"""
import argparse
import json
import os
import shutil
import struct
import sys
from multiprocessing import Pool

from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import pvmap  # noqa: E402
import render  # noqa: E402

ROOT = os.path.normpath(os.path.join(HERE, '..', '..'))
MAP = os.path.join(ROOT, 'core/server/data/world/map.otbm')
OTB = os.path.join(ROOT, 'core/server/data/items/items.otb')
DAT = os.path.join(ROOT, 'core/client-legacy/data/things/data.dat')
SPR = os.path.join(ROOT, 'core/client-legacy/data/things/data.spr')
OUT = os.path.join(ROOT, 'build/map-pictures')

HOUSE_MARGIN = 3
HOUSE_TILE = 16
HOUSE_MAX_PIXELS = 512
COLORS = 256

_renderer = None


def renderer():
    global _renderer
    if _renderer is None:
        _renderer = render.Renderer(OTB, DAT, SPR)
    return _renderer


def save(img, path):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    img.convert('RGB').quantize(COLORS, method=Image.Quantize.MEDIANCUT).save(path, optimize=True)


# a single streaming pass for every house tile

def survey(path):
    data = open(path, 'rb').read()
    houses = {}
    area = None
    for ev, t, depth, a, b, _ in pvmap.walk(data):
        if ev != 'open':
            continue
        if t == pvmap.TILE_AREA:
            area = struct.unpack_from('<HHB', pvmap.unescape(data[a:b]), 0)
        elif t in (pvmap.TILE, pvmap.HOUSETILE):
            p = pvmap.unescape(data[a:b])
            x, y, z = area[0] + p[0], area[1] + p[1], area[2]
            if t == pvmap.HOUSETILE:
                house_id = struct.unpack_from('<I', p, 2)[0]
                houses.setdefault(house_id, []).append((x, y, z))
    return houses


def house_boxes(houses):
    """[(house id, z, x0, y0, x1, y1)] around each floor's tiles."""
    boxes = []
    for house_id, tiles in sorted(houses.items()):
        floors = {}
        for x, y, z in tiles:
            floors.setdefault(z, []).append((x, y))
        for z, spots in sorted(floors.items()):
            xs, ys = [s[0] for s in spots], [s[1] for s in spots]
            boxes.append((house_id, z, min(xs) - HOUSE_MARGIN, min(ys) - HOUSE_MARGIN,
                          max(xs) + HOUSE_MARGIN, max(ys) + HOUSE_MARGIN))
    return boxes


def picture_size(w, h):
    scale = min(HOUSE_TILE, HOUSE_MAX_PIXELS / max(w, h))
    return int(w * scale), int(h * scale)


def render_house(args):
    box, tiles, out = args
    house_id, z, x0, y0, x1, y1 = box
    img = renderer().render(tiles, x0, y0, x1, y1, z, upper=False)
    img = img.resize(picture_size(x1 - x0 + 1, y1 - y0 + 1), Image.LANCZOS)
    save(img, os.path.join(out, 'houses', '%d_%d.png' % (house_id, z)))
    return box


def houses_main(out, jobs):
    print('reading the map...')
    shutil.rmtree(os.path.join(out, 'houses'), ignore_errors=True)
    houses = survey(MAP)
    boxes = house_boxes(houses)
    print('%d houses, %d pictures' % (len(houses), len(boxes)))
    wanted = set()
    for _, z, x0, y0, x1, y1 in boxes:
        for y in range(y0 - 2, y1 + 3):
            for x in range(x0 - 2, x1 + 3):
                wanted.add((x, y, z))
    tiles = pvmap.read_tiles(MAP, wanted)
    work = []
    for box in boxes:
        _, z, x0, y0, x1, y1 = box
        part = {}
        for y in range(y0 - 2, y1 + 3):
            for x in range(x0 - 2, x1 + 3):
                items = tiles.get((x, y, z))
                if items:
                    part[(x, y, z)] = items
        work.append((box, part, out))
    with Pool(jobs) as pool:
        for n, _ in enumerate(pool.imap_unordered(render_house, work, chunksize=4), 1):
            if n % 50 == 0:
                print('  %d / %d' % (n, len(work)))
    index = {}
    for house_id, z, x0, y0, x1, y1 in boxes:
        w, h = x1 - x0 + 1, y1 - y0 + 1
        index.setdefault(str(house_id), {})[str(z)] = [x0, y0, w, h, *picture_size(w, h)]
    with open(os.path.join(out, 'houses', 'index.json'), 'w') as f:
        json.dump(index, f, separators=(',', ':'), sort_keys=True)
    print('wrote %d pictures to %s' % (len(boxes), os.path.join(out, 'houses')))


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--out', default=OUT)
    ap.add_argument('--jobs', type=int, default=4)
    args = ap.parse_args()
    houses_main(args.out, args.jobs)


if __name__ == '__main__':
    main()
