#!/usr/bin/env python3
"""Renders the Pokepedia's map pictures from the server map with the client sprites.

    scripts/mapper/render_pokepedia.py [--out build/map-pictures] [--jobs 4]
        [--only houses|world] [--state <out>-state.json] [--show-hidden] [--underground]

houses: one picture per house floor, <out>/houses/<house id>_<z>.png: the house's tiles and a few
tiles around them, without the floors above so the rooms show. <out>/houses/index.json maps each
house id and floor to [x, y, w, h, pixel width, pixel height]: the picture's top-left tile, its
size in tiles and in pixels, min(16, 512 / longest side) pixels per tile.

world: the world map of the ground floor and the floors above it as the client's satellite map
chunks (src/client/satellitemap.cpp), 512x512 pictures in <out>/world: lod 8 at 4 pixels per tile
(128x128 tiles), and lods 16, 32 and 64 built from them for the zoomed-out map. The client draws
floors 0-7 over the ground floor; the ground floor is drawn with the floors above it, the way it
looks from outside, and the floors above it are only opaque on their own tiles. Underground floors
(8-15) are not drawn: there the client shows the minimap the player has explored. House pictures
still cover every floor. --underground draws floors 8-15 too, one floor at a time ("minimap"
chunks), for previews while mapping.

A piece is only drawn again when its tiles change: <out>-state.json keeps a hash of each piece's
tiles (and of the sprites), so a map change redraws just the pieces it touches. Files that no
longer match a piece are removed.

The regions in hidden-regions.txt (next to this script) are left out of both, until they are
removed from the list; --show-hidden draws them anyway, for previews.

The pictures are not kept in the repository: the client release renders them (the last render and
its state are cached, so a release only draws what changed), and scripts/assemble-redemption-client.sh copies
<out> into the client's data/images/pokepedia when it exists. Without them the Pokepedia shows
the minimap.

Reads core/server/data/world/map.otbm, items.otb, and the client's data.dat and data.spr.
"""
import argparse
import hashlib
import json
import lzma
import os
import re
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
HIDDEN = os.path.join(HERE, 'hidden-regions.txt')
OUT = os.path.join(ROOT, 'build/map-pictures')

HOUSE_MARGIN = 3
HOUSE_TILE = 16
HOUSE_MAX_PIXELS = 512
CHUNK = 128
SCALE = 4
PIXELS = CHUNK * SCALE
# bump to redraw every piece after a change to how they are drawn
WORLD_VERSION = 1
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

def survey(underground=False):
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
            if z <= GROUND or underground:
                key = (z, x // CHUNK, y // CHUNK)
                chunks[key] = chunks.get(key, 0) + 1
            if z < GROUND:
                # the ground floor picture is drawn with the floors above, so a piece with only raised
                # tiles (Fortree's treetops) still needs one
                key = (GROUND, x // CHUNK, y // CHUNK)
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
    return range(0, GROUND + 1) if z == GROUND else [z]


def chunk_name(lod, z, cx, cy):
    """The client's satellite map file for a chunk; cx, cy count chunks of that lod."""
    tiles = PIXELS * lod // 32
    return '%s-%d-%d-%d-%d-pv.bmp.lzma' % ('satellite' if z <= GROUND else 'minimap', lod,
                                            cx * tiles // 32, cy * tiles // 32, z)


def write_chunk(img, path):
    """A 512x512 picture as the client reads it: 32 header bytes, then an LZMA-alone 32-bit BMP."""
    rgb = img.convert('RGB').quantize(COLORS, method=Image.Quantize.MEDIANCUT).convert('RGB')
    rgb.putalpha(img.getchannel('A'))
    pixels = rgb.tobytes('raw', 'BGRA')
    bmp = struct.pack('<2sIHHI', b'BM', 54 + len(pixels), 0, 0, 54)
    bmp += struct.pack('<IiiHHIIiiII', 40, img.width, -img.height, 1, 32, 0, len(pixels), 2835, 2835, 0, 0)
    packed = lzma.compress(bmp + pixels, format=lzma.FORMAT_ALONE,
                           filters=[{'id': lzma.FILTER_LZMA1, 'preset': 6, 'dict_size': 1 << 21}])
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, 'wb') as f:
        f.write(bytes(32) + packed)


def read_chunk(path):
    data = lzma.decompress(open(path, 'rb').read()[32:], format=lzma.FORMAT_ALONE)
    offset, = struct.unpack_from('<I', data, 10)
    width, height = struct.unpack_from('<ii', data, 18)
    return Image.frombytes('RGBA', (width, abs(height)), data[offset:], 'raw', 'BGRA')


def inputs_digest():
    """What every piece depends on besides its own tiles: the sprites and the way they're drawn."""
    h = hashlib.sha1(b'world %d' % WORLD_VERSION)
    for path in (OTB, DAT, SPR, render.__file__):
        with open(path, 'rb') as f:
            for block in iter(lambda: f.read(1 << 20), b''):
                h.update(block)
    return h.hexdigest()


def piece_box(cx, cy):
    x0, y0 = cx * CHUNK, cy * CHUNK
    return x0, y0, x0 + CHUNK - 1, y0 + CHUNK - 1


def render_piece(r, tiles, z, cx, cy):
    x0, y0, x1, y1 = piece_box(cx, cy)
    # where the map has nothing the client's background shows, the same on every floor
    img = r.render_scaled(tiles, x0, y0, x1, y1, z, upper=(z == GROUND), scale=SCALE / 32.0,
                          background=(0, 0, 0, 0))
    # off the ground the client draws the floor over the ground below, so only its own tiles are opaque
    if z != GROUND:
        alpha = Image.new('L', img.size, 0)
        for (x, y, tz) in tiles:
            if tz == z and x0 <= x <= x1 and y0 <= y <= y1:
                alpha.paste(255, ((x - x0) * SCALE, (y - y0) * SCALE, (x - x0 + 1) * SCALE, (y - y0 + 1) * SCALE))
        img.putalpha(alpha)
    if any(rx1 <= x1 and x0 <= rx2 and ry1 <= y1 and y0 <= ry2 for _, rx1, ry1, rx2, ry2 in _hidden):
        # the floors above can reach into a hidden region's edge
        for y in range(y0, y1 + 1):
            for x in range(x0, x1 + 1):
                if hidden(x, y):
                    img.paste((0, 0, 0, 0), ((x - x0) * SCALE, (y - y0) * SCALE, (x - x0 + 1) * SCALE, (y - y0 + 1) * SCALE))
    return img


def render_band(args):
    """Draws the pieces of one row (cy) whose tiles changed since the hashes in known."""
    cy, keys, out, known = args
    x0, y0, x1, y1 = piece_box(0, cy)
    needed = set()
    for z, _ in keys:
        needed.update(floors_for(z))
    # the floors above the ground are drawn shifted up and left, so read a little further down and right
    tiles = visible_tiles(pvmap.read_region(MAP, 0, y0 - 2, 65535, y1 + 10, needed, data=map_data()))
    columns = {}
    for (x, y, z), items in tiles.items():
        for cx in ((x + 2) // CHUNK, (x + 2) // CHUNK - 1):
            if cx * CHUNK - 2 <= x <= cx * CHUNK + CHUNK + 9:
                columns.setdefault(cx, {})[(x, y, z)] = items
    r = None
    done = []
    for z, cx in keys:
        part = {k: v for k, v in columns.get(cx, {}).items() if k[2] in floors_for(z)}
        bx0, by0, bx1, by1 = piece_box(cx, cy)
        h = hashlib.sha1(repr((sorted(part.items()), [reg for reg in _hidden if reg[1] <= bx1 + 10 and
                               bx0 - 2 <= reg[3] and reg[2] <= by1 + 10 and by0 - 2 <= reg[4]])).encode())
        digest = h.hexdigest()
        path = os.path.join(out, 'world', chunk_name(8, z, cx, cy))
        drawn = known.get('8/%d/%d/%d' % (z, cx, cy)) != digest or not os.path.exists(path)
        if drawn:
            r = r or renderer()
            write_chunk(render_piece(r, part, z, cx, cy), path)
        done.append((z, cx, cy, digest, drawn))
    return done


def build_level(args):
    """One chunk of a coarser lod, from the 2x2 chunks of the lod below."""
    lod, z, cx, cy, out = args
    img = Image.new('RGBA', (PIXELS, PIXELS), (0, 0, 0, 0))
    half = PIXELS // 2
    for dy in range(2):
        for dx in range(2):
            path = os.path.join(out, 'world', chunk_name(lod // 2, z, cx * 2 + dx, cy * 2 + dy))
            if os.path.exists(path):
                img.paste(read_chunk(path).resize((half, half), Image.LANCZOS), (dx * half, dy * half))
    write_chunk(img, os.path.join(out, 'world', chunk_name(lod, z, cx, cy)))


def world_main(out, jobs, chunks, width, height, state_path):
    inputs = inputs_digest()
    state = {}
    if os.path.exists(state_path):
        state = json.load(open(state_path))
    if state.get('inputs') != inputs:
        state = {'inputs': inputs, 'chunks': {}}
    known = state['chunks']
    os.makedirs(os.path.join(out, 'world'), exist_ok=True)

    rows = {}
    for (z, cx, cy) in chunks:
        rows.setdefault(cy, []).append((z, cx))
    # the busiest rows first, so the pool doesn't end waiting on one long row
    work = sorted(((cy, sorted(keys), out, known) for cy, keys in rows.items()), key=lambda w: -len(w[1]))
    total = sum(len(w[1]) for w in work)
    print('world %dx%d tiles: %d pieces in %d rows' % (width, height, total, len(work)))
    current = {}
    changed = {8: set()}
    count = drawn = 0
    with Pool(jobs, initializer=set_hidden, initargs=(_hidden,)) as pool:
        for part in pool.imap_unordered(render_band, work):
            for z, cx, cy, digest, was_drawn in part:
                current['8/%d/%d/%d' % (z, cx, cy)] = digest
                if was_drawn:
                    changed[8].add((z, cx, cy))
                    drawn += 1
            count += len(part)
            print('  world %d / %d, %d drawn' % (count, total, drawn))

        lod = 8
        while lod < 64:
            parent = {}
            for key in current:
                if key.startswith('%d/' % lod):
                    z, cx, cy = (int(v) for v in key.split('/')[1:])
                    parent.setdefault((z, cx // 2, cy // 2), []).append(current[key])
            lod *= 2
            todo = []
            for (z, cx, cy), digests in sorted(parent.items()):
                key = '%d/%d/%d/%d' % (lod, z, cx, cy)
                current[key] = hashlib.sha1(repr(sorted(digests)).encode()).hexdigest()
                if known.get(key) != current[key] or not os.path.exists(
                        os.path.join(out, 'world', chunk_name(lod, z, cx, cy))):
                    todo.append((lod, z, cx, cy, out))
            pool.map(build_level, todo, chunksize=4)
            print('  lod %d: %d chunks, %d drawn' % (lod, len(parent), len(todo)))

    wanted = {chunk_name(*(int(v) for v in key.split('/'))) for key in current}
    removed = 0
    for name in os.listdir(os.path.join(out, 'world')):
        if name not in wanted:
            os.remove(os.path.join(out, 'world', name))
            removed += 1
    state['chunks'] = current
    with open(state_path, 'w') as f:
        json.dump(state, f, separators=(',', ':'), sort_keys=True)
    print('world: %d chunks, %d pieces drawn, %d old files removed' % (len(current), drawn, removed))


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--out', default=OUT)
    ap.add_argument('--jobs', type=int, default=4)
    ap.add_argument('--only', choices=('houses', 'world'))
    ap.add_argument('--state', help='the piece hashes of the last render (default: <out>-state.json)')
    ap.add_argument('--show-hidden', action='store_true')
    ap.add_argument('--underground', action='store_true')
    args = ap.parse_args()
    if not args.show_hidden:
        set_hidden(read_hidden(HIDDEN))
        for name, x1, y1, x2, y2 in _hidden:
            print('hidden: %s (%d,%d - %d,%d)' % (name, x1, y1, x2, y2))
    print('reading the map...')
    chunks, houses, width, height = survey(args.underground)
    if args.only != 'world':
        houses_main(args.out, args.jobs, houses)
    if args.only != 'houses':
        state = args.state or os.path.normpath(args.out) + '-state.json'
        world_main(args.out, args.jobs, chunks, width, height, state)


if __name__ == '__main__':
    main()
