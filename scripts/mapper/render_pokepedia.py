#!/usr/bin/env python3
"""Renders the Pokepedia's map pictures from the server map with the client sprites.

    scripts/mapper/render_pokepedia.py [--out build/map-pictures] [--jobs 4]
        [--only houses|world] [--show-hidden]

houses: one picture per house floor, <out>/houses/<house id>_<z>.png: the house's tiles and a few
tiles around them, without the floors above so the rooms show. <out>/houses/index.json maps each
house id and floor to [x, y, w, h, pixel width, pixel height]: the picture's top-left tile, its
size in tiles and in pixels, min(16, 512 / longest side) pixels per tile.

world: the world map of every floor in pieces of 128x128 tiles at 4 pixels per tile,
<out>/world/<z>/<cx>_<cy>.png, and overview blocks of 512x512 tiles at 1 pixel per tile,
<out>/world/<z>/o_<ox>_<oy>.png, for the zoomed-out map. The ground floor is drawn with the floors
above it, the way it looks from outside; floors above the ground show the ground dimmed under
them. <out>/world/index.json lists the pieces and blocks of each floor.

The regions in hidden-regions.txt (next to this script) are left out of both, until they are
removed from the list; --show-hidden draws them anyway, for previews.

The pictures are not kept in the repository: the client release renders them (cached until the
map, the sprites or the hidden regions change), and scripts/assemble-redemption-client.sh copies
<out> into the client's data/images/pokepedia when it exists. Without them the Pokepedia shows
the minimap.

Reads core/server/data/world/map.otbm, items.otb, and the client's data.dat and data.spr.
"""
import argparse
import json
import os
import re
import shutil
import struct
import sys
from multiprocessing import Pool

from PIL import Image, ImageEnhance

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import pvmap  # noqa: E402
import render  # noqa: E402

ROOT = os.path.normpath(os.path.join(HERE, '..', '..'))
MAP = os.path.join(ROOT, 'core/server/data/world/map.otbm')
OTB = os.path.join(ROOT, 'core/server/data/items/items.otb')
DAT = os.path.join(ROOT, 'core/client-legacy/data/things/data.dat')
SPR = os.path.join(ROOT, 'core/client-legacy/data/things/data.spr')
HIDDEN = os.path.join(HERE, 'hidden-regions.txt')
OUT = os.path.join(ROOT, 'build/map-pictures')

HOUSE_MARGIN = 3
HOUSE_TILE = 16
HOUSE_MAX_PIXELS = 512
CHUNK = 128
OVERVIEW = 512
SCALE = 4
GROUND = 7
COLORS = 256

_renderer = None
_map = None
_hidden = []


def renderer():
    global _renderer
    if _renderer is None:
        _renderer = render.Renderer(OTB, DAT, SPR)
    return _renderer


def map_data():
    global _map
    if _map is None:
        _map = open(MAP, 'rb').read()
    return _map


def save(img, path):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    img.convert('RGB').quantize(COLORS, method=Image.Quantize.MEDIANCUT).save(path, optimize=True)


# hidden regions: "name: x1,y1 - x2,y2" per line, # starts a comment

def read_hidden(path):
    regions = []
    if not os.path.exists(path):
        return regions
    pattern = re.compile(r'^(.*?):\s*(\d+)\s*,\s*(\d+)\s*-\s*(\d+)\s*,\s*(\d+)$')
    for number, line in enumerate(open(path), 1):
        line = line.split('#', 1)[0].strip()
        if not line:
            continue
        m = pattern.match(line)
        if not m:
            sys.exit('%s:%d: expected "name: x1,y1 - x2,y2", got: %s' % (path, number, line))
        x1, y1, x2, y2 = (int(v) for v in m.groups()[1:])
        regions.append((m.group(1).strip(), min(x1, x2), min(y1, y2), max(x1, x2), max(y1, y2)))
    return regions


def set_hidden(regions):
    global _hidden
    _hidden = regions


def hidden(x, y):
    for _, x1, y1, x2, y2 in _hidden:
        if x1 <= x <= x2 and y1 <= y <= y2:
            return True
    return False


def visible_tiles(tiles):
    if not _hidden:
        return tiles
    return {k: v for k, v in tiles.items() if not hidden(k[0], k[1])}


# a single streaming pass: what the map holds, per floor and piece, and every house tile

def survey():
    data = map_data()
    chunks = {}
    houses = {}
    width = height = 0
    area = None
    for ev, t, depth, a, b, _ in pvmap.walk(data):
        if ev != 'open':
            continue
        if t == pvmap.TILE_AREA:
            area = struct.unpack_from('<HHB', pvmap.unescape(data[a:b]), 0)
        elif t in (pvmap.TILE, pvmap.HOUSETILE):
            p = pvmap.unescape(data[a:b])
            x, y, z = area[0] + p[0], area[1] + p[1], area[2]
            if hidden(x, y):
                continue
            width, height = max(width, x + 1), max(height, y + 1)
            key = (z, x // CHUNK, y // CHUNK)
            chunks[key] = chunks.get(key, 0) + 1
            if t == pvmap.HOUSETILE:
                house_id = struct.unpack_from('<I', p, 2)[0]
                houses.setdefault(house_id, []).append((x, y, z))
    return chunks, houses, width, height


# houses

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


def houses_main(out, jobs, houses):
    shutil.rmtree(os.path.join(out, 'houses'), ignore_errors=True)
    boxes = house_boxes(houses)
    print('%d houses, %d pictures' % (len(houses), len(boxes)))
    wanted = set()
    for _, z, x0, y0, x1, y1 in boxes:
        for y in range(y0 - 2, y1 + 3):
            for x in range(x0 - 2, x1 + 3):
                wanted.add((x, y, z))
    tiles = visible_tiles(pvmap.read_tiles(MAP, wanted, data=map_data()))
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
    with Pool(jobs, initializer=set_hidden, initargs=(_hidden,)) as pool:
        for n, _ in enumerate(pool.imap_unordered(render_house, work, chunksize=4), 1):
            if n % 100 == 0:
                print('  houses %d / %d' % (n, len(work)))
    index = {}
    for house_id, z, x0, y0, x1, y1 in boxes:
        w, h = x1 - x0 + 1, y1 - y0 + 1
        index.setdefault(str(house_id), {})[str(z)] = [x0, y0, w, h, *picture_size(w, h)]
    os.makedirs(os.path.join(out, 'houses'), exist_ok=True)
    with open(os.path.join(out, 'houses', 'index.json'), 'w') as f:
        json.dump(index, f, separators=(',', ':'), sort_keys=True)
    print('wrote %d house pictures' % len(boxes))


# world

def floors_for(z):
    if z == GROUND:
        return range(0, GROUND + 1)
    if z < GROUND:
        return sorted({z, GROUND})
    return [z]


def render_band(args):
    """Renders every piece of one row of pieces (cy) for the given floors."""
    cy, keys, out = args
    y0, y1 = cy * CHUNK, cy * CHUNK + CHUNK - 1
    needed = set()
    for z, _ in keys:
        needed.update(floors_for(z))
    # the floors above the ground are drawn shifted up and left, so read a little further down
    tiles = visible_tiles(pvmap.read_region(MAP, 0, y0 - 2, 65535, y1 + 10, needed, data=map_data()))
    r = renderer()
    scale = SCALE / 32.0
    done = []
    for z, cx in keys:
        x0, x1 = cx * CHUNK, cx * CHUNK + CHUNK - 1
        if z >= GROUND:
            img = r.render_scaled(tiles, x0, y0, x1, y1, z, upper=(z == GROUND), scale=scale)
        else:
            base = r.render_scaled(tiles, x0, y0, x1, y1, GROUND, upper=False, scale=scale)
            base = ImageEnhance.Brightness(base.convert('RGB')).enhance(0.35).convert('RGBA')
            mine = {k: v for k, v in tiles.items() if k[2] == z}
            top = r.render_scaled(mine, x0, y0, x1, y1, z, upper=False, scale=scale)
            # the floor's own tiles are opaque; where it has none the dimmed ground shows
            alpha = Image.new('L', top.size, 0)
            for (x, y, _) in mine:
                if x0 <= x <= x1 and y0 <= y <= y1:
                    alpha.paste(255, ((x - x0) * SCALE, (y - y0) * SCALE, (x - x0 + 1) * SCALE, (y - y0 + 1) * SCALE))
            base.paste(top, (0, 0), alpha)
            img = base
        if any(rx1 <= x1 and x0 <= rx2 and ry1 <= y1 and y0 <= ry2 for _, rx1, ry1, rx2, ry2 in _hidden):
            # the floors above can reach into a hidden region's edge
            black = Image.new('RGBA', (SCALE, SCALE), (0, 0, 0, 255))
            for y in range(y0, y1 + 1):
                for x in range(x0, x1 + 1):
                    if hidden(x, y):
                        img.paste(black, ((x - x0) * SCALE, (y - y0) * SCALE))
        save(img, os.path.join(out, 'world', str(z), '%d_%d.png' % (cx, cy)))
        done.append((z, cx, cy))
    return done


def overviews(out, done):
    blocks = {}
    per = OVERVIEW // CHUNK
    for z, cx, cy in done:
        blocks.setdefault((z, cx // per, cy // per), []).append((cx, cy))
    for (z, ox, oy), parts in sorted(blocks.items()):
        img = Image.new('RGB', (OVERVIEW, OVERVIEW), (0, 0, 0))
        for cx, cy in sorted(parts):
            piece = Image.open(os.path.join(out, 'world', str(z), '%d_%d.png' % (cx, cy))).convert('RGB')
            piece = piece.resize((CHUNK, CHUNK), Image.LANCZOS)
            img.paste(piece, ((cx - ox * per) * CHUNK, (cy - oy * per) * CHUNK))
        save(img, os.path.join(out, 'world', str(z), 'o_%d_%d.png' % (ox, oy)))
    return sorted(blocks)


def world_main(out, jobs, chunks, width, height):
    shutil.rmtree(os.path.join(out, 'world'), ignore_errors=True)
    rows = {}
    for (z, cx, cy) in chunks:
        rows.setdefault(cy, []).append((z, cx))
    # the busiest rows first, so the pool doesn't end waiting on one long row
    work = sorted(((cy, sorted(keys), out) for cy, keys in rows.items()), key=lambda w: -len(w[1]))
    total = sum(len(w[1]) for w in work)
    print('world %dx%d tiles: %d pieces in %d rows' % (width, height, total, len(work)))
    done = []
    with Pool(jobs, initializer=set_hidden, initargs=(_hidden,)) as pool:
        for part in pool.imap_unordered(render_band, work):
            done += part
            print('  world %d / %d' % (len(done), total))
    blocks = overviews(out, done)
    floors = {}
    for z, cx, cy in sorted(done):
        floors.setdefault(str(z), {'pieces': [], 'blocks': []})['pieces'].append([cx, cy])
    for z, ox, oy in blocks:
        floors[str(z)]['blocks'].append([ox, oy])
    index = {'piece': CHUNK, 'block': OVERVIEW, 'scale': SCALE, 'width': width, 'height': height,
             'floors': floors}
    with open(os.path.join(out, 'world', 'index.json'), 'w') as f:
        json.dump(index, f, separators=(',', ':'), sort_keys=True)
    print('wrote %d world pieces and %d overview blocks' % (len(done), len(blocks)))


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--out', default=OUT)
    ap.add_argument('--jobs', type=int, default=4)
    ap.add_argument('--only', choices=('houses', 'world'))
    ap.add_argument('--show-hidden', action='store_true')
    args = ap.parse_args()
    if not args.show_hidden:
        set_hidden(read_hidden(HIDDEN))
        for name, x1, y1, x2, y2 in _hidden:
            print('hidden: %s (%d,%d - %d,%d)' % (name, x1, y1, x2, y2))
    print('reading the map...')
    chunks, houses, width, height = survey()
    if args.only != 'world':
        houses_main(args.out, args.jobs, houses)
    if args.only != 'houses':
        world_main(args.out, args.jobs, chunks, width, height)


if __name__ == '__main__':
    main()
