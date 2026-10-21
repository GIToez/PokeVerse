#!/usr/bin/env python3
"""Reads PokeVerse outfits from the legacy client's data.dat and data.spr.

    outfit_sprites.py info <look type>...
    outfit_sprites.py dump <look type> <out dir>

dump writes every sprite group of the outfit as a PNG sheet: one row per add-on pattern
(base, add-on 1, add-on 2), one column per direction (north, east, south, west) and frame,
with the base layer and the colour mask layer side by side.
"""
import os
import struct
import sys

from PIL import Image

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
THINGS = os.path.join(ROOT, "core/client-legacy/data/things")
sys.path.insert(0, os.path.join(ROOT, "scripts"))
dat_add_items = __import__("dat-add-items")


def read_outfits(data):
    signature, items, outfits, effects, missiles = struct.unpack_from('<IHHHH', data, 0)
    i = 12
    for _ in range(100, items + 1):
        i = dat_add_items.read_thing(data, i)
    looks = {}
    for look in range(1, outfits + 1):
        start = i
        i = dat_add_items.read_thing(data, i)
        looks[look] = parse_dims(data, start)
    return looks


def parse_dims(data, i):
    while data[i] != 0xFF:
        attr = data[i]
        i += 1
        if attr in dat_add_items.U16_ATTRS:
            i += 2
        elif attr in dat_add_items.U16X2_ATTRS:
            i += 4
        elif attr == dat_add_items.MARKET_ATTR:
            i += 6
            i += 2 + struct.unpack_from('<H', data, i)[0] + 4
    i += 1
    width, height = data[i], data[i + 1]
    i += 2
    exact = 32
    if width > 1 or height > 1:
        exact = data[i]
        i += 1
    layers, px, py, pz, frames = data[i:i + 5]
    i += 5
    count = width * height * layers * px * py * pz * frames
    sprites = struct.unpack_from('<%dI' % count, data, i)
    return dict(width=width, height=height, exact=exact, layers=layers, px=px, py=py, pz=pz,
                frames=frames, sprites=sprites)


class Spr:
    def __init__(self, path):
        self.f = open(path, 'rb')
        self.f.seek(4)
        self.count = struct.unpack('<I', self.f.read(4))[0]

    def image(self, sprite_id):
        img = Image.new('RGBA', (32, 32), (0, 0, 0, 0))
        if sprite_id == 0 or sprite_id > self.count:
            return img
        self.f.seek(8 + (sprite_id - 1) * 4)
        offset = struct.unpack('<I', self.f.read(4))[0]
        if offset == 0:
            return img
        self.f.seek(offset + 3)
        size = struct.unpack('<H', self.f.read(2))[0]
        raw = self.f.read(size)
        px, j = 0, 0
        pixels = img.load()
        while j < size:
            transparent, colored = struct.unpack_from('<HH', raw, j)
            j += 4
            px += transparent
            for _ in range(colored):
                r, g, b, a = raw[j:j + 4]
                j += 4
                pixels[px % 32, px // 32] = (r, g, b, a)
                px += 1
        return img


def frame_image(spr, d, layer, x, y, z, frame):
    w, h, size = d['width'], d['height'], 32
    img = Image.new('RGBA', (w * size, h * size), (0, 0, 0, 0))
    for hh in range(h):
        for ww in range(w):
            index = ((((((frame * d['pz'] + z) * d['py'] + y) * d['px'] + x) * d['layers'] + layer)
                      * h + hh) * w + ww)
            tile = spr.image(d['sprites'][index])
            img.alpha_composite(tile, ((w - 1 - ww) * size, (h - 1 - hh) * size))
    return img


def main():
    if len(sys.argv) < 3:
        sys.exit(__doc__)
    data = open(os.path.join(THINGS, "data.dat"), 'rb').read()
    looks = read_outfits(data)
    if sys.argv[1] == 'info':
        for look in map(int, sys.argv[2:]):
            d = looks[look]
            print(look, {k: v for k, v in d.items() if k != 'sprites'})
        return
    look, out = int(sys.argv[2]), sys.argv[3]
    os.makedirs(out, exist_ok=True)
    d = looks[look]
    spr = Spr(os.path.join(THINGS, "data.spr"))
    cw, ch = d['width'] * 32, d['height'] * 32
    sheet = Image.new('RGBA', (cw * d['px'] * d['frames'] * d['layers'], ch * d['py'] * d['pz']))
    for z in range(d['pz']):
        for y in range(d['py']):
            for frame in range(d['frames']):
                for x in range(d['px']):
                    for layer in range(d['layers']):
                        col = (frame * d['px'] + x) * d['layers'] + layer
                        sheet.alpha_composite(frame_image(spr, d, layer, x, y, z, frame),
                                              (col * cw, (z * d['py'] + y) * ch))
    sheet.save(os.path.join(out, "look_%d.png" % look))
    print({k: v for k, v in d.items() if k != 'sprites'})


if __name__ == "__main__":
    main()
