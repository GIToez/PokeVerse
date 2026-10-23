#!/usr/bin/env python3
"""Draws an outfit from a sprite sheet into the PokeVerse data.dat and data.spr.

    scripts/dat-set-outfit.py <look> <sheet.png> [<look> <sheet.png> ...]

A look of `new` adds the outfit after the last one and prints the id it got.

The sheet is laid out like the "6500 sprite pokemon" pack (docs/sprite-pack-review): the four
directions (north, east, south, west) across and the animation frames down, every frame a square
of 32 to 192 pixels (a whole number of tiles). The outfit becomes one layer of that size with a
frame per row, standing on its tile's bottom right like the other Pokemon. Its old sprites are left in data.spr; the new
ones go on sprite ids no thing uses, so nothing else changes. Use it for looks that have no art,
e.g. Latias (1559) and Latios (1560).
"""
import importlib.util
import os
import struct
import sys

import numpy as np
from PIL import Image

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DAT = os.path.join(ROOT, 'core/client-legacy/data/things/data.dat')
sys.path.insert(0, os.path.join(ROOT, 'scripts', 'art'))
sys.path.insert(0, os.path.join(ROOT, 'scripts', 'mapper'))


def load(name):
    spec = importlib.util.spec_from_file_location(name.replace('-', '_'), os.path.join(ROOT, 'scripts', name + '.py'))
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


dat_tool, footprints = load('dat-add-items'), load('add-footprints')


def outfit_spans(data):
    _, items, outfits, _, _, _, i = dat_tool.parse(data)
    spans = []
    for _ in range(outfits):
        end = dat_tool.read_thing(data, i)
        spans.append((i, end))
        i = end
    return spans


def tiles_of(sheet):
    """{(frame, direction, x, y): 32x32 RGBA array} with x and y counted from the bottom right, and the size."""
    a = np.array(Image.open(sheet).convert('RGBA'))
    size = a.shape[1] // 4
    if size % 32 or not 32 <= size <= 192 or a.shape[0] % size:
        sys.exit('%s: expected four directions across of 32 to 192 pixels, got %dx%d'
                 % (sheet, a.shape[1], a.shape[0]))
    n = size // 32
    out = {}
    for frame in range(a.shape[0] // size):
        for d in range(4):
            cell = a[frame * size:(frame + 1) * size, d * size:(d + 1) * size]
            for y in range(n):
                for x in range(n):
                    px = cell[32 * (n - 1 - y):32 * (n - y), 32 * (n - 1 - x):32 * (n - x)].copy()
                    px[px[..., 3] == 0] = 0
                    out[(frame, d, x, y)] = px
    return out, n, a.shape[0] // size


def main():
    args = sys.argv[1:]
    if not args or len(args) % 2:
        sys.exit(__doc__)
    import house_reskin
    data = bytearray(open(DAT, 'rb').read())
    pairs = []
    for look, sheet in zip(args[0::2], args[1::2]):
        if look == 'new':
            signature, items, outfits, effects, missiles, _, _ = dat_tool.parse(bytes(data))
            end = outfit_spans(bytes(data))[-1][1]
            data[end:end] = bytes([dat_tool.LAST_ATTR, 1, 1, 1, 1, 1, 1, 1]) + bytes(4)
            data[0:12] = struct.pack('<IHHHH', signature, items, outfits + 1, effects, missiles)
            look = outfits + 1
            print('new outfit %d for %s' % (look, os.path.basename(sheet)))
        pairs.append((int(look), sheet))
    used = footprints.used_sprites(bytes(data))
    free = (s for s in range(1, max(used)) if s not in used)
    new_sprites = {}
    for look, sheet in sorted(pairs, reverse=True):
        spans = outfit_spans(bytes(data))
        if not 1 <= look <= len(spans):
            sys.exit('no outfit %d' % look)
        tiles, n, frames = tiles_of(sheet)
        ids = []
        for frame in range(frames):
            for d in range(4):
                for y in range(n):
                    for x in range(n):
                        px = tiles[(frame, d, x, y)]
                        if not px[..., 3].any():
                            ids.append(0)
                            continue
                        sid = next(free)
                        new_sprites[sid] = px
                        ids.append(sid)
        size = bytes([n, n]) + (bytes([min(64, 32 * n)]) if n > 1 else b'')
        thing = bytes([dat_tool.LAST_ATTR]) + size + bytes([1, 4, 1, 1, frames]) + struct.pack('<%dI' % len(ids), *ids)
        start, end = spans[look - 1]
        data[start:end] = thing
        print('outfit %d: %d px, %d frames, %d sprites from %s' % (look, 32 * n, frames, sum(1 for s in ids if s),
                                                                  os.path.basename(sheet)))
    dat_tool.parse(bytes(data))
    open(DAT, 'wb').write(data)
    house_reskin.write_spr({sid: Image.fromarray(px) for sid, px in new_sprites.items()})


if __name__ == '__main__':
    main()
