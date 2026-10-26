#!/usr/bin/env python3
"""Adds client items that draw their own 32x32 picture from data.spr.

    scripts/dat-add-sprite-items.py [--frames N] <template client id> <icon.png> [<icon.png> ...]

Every icon becomes a new client item after the last one, with the template's attributes
(pickupable, movable and so on) and one still sprite. The sprites go on ids no thing uses, so
nothing else changes, and every client draws them (no `image:` entry in things.otml needed).
With --frames N, every N icons in a row are the animation frames of one item (like the swap
bar faces, 4 frames). Prints the client id each item got.
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


def icon(path):
    im = Image.open(path).convert('RGBA')
    if im.size != (32, 32):
        sys.exit('%s: expected 32x32, got %dx%d' % (path, im.width, im.height))
    px = np.array(im)
    px[px[..., 3] == 0] = 0
    return px


def main():
    if len(sys.argv) < 3:
        sys.exit(__doc__)
    import house_reskin
    args = sys.argv[1:]
    frames = 1
    if args[0] == '--frames':
        frames, args = int(args[1]), args[2:]
    template_id, icons = int(args[0]), args[1:]
    if frames < 1 or len(icons) % frames:
        sys.exit('%d icons do not make items of %d frames' % (len(icons), frames))
    data = open(DAT, 'rb').read()
    signature, items, outfits, effects, missiles, offsets, items_end = dat_tool.parse(data)
    if template_id not in offsets:
        sys.exit('template client id %d not found (items are 100-%d)' % (template_id, items))
    still = dat_tool.make_still(data, *offsets[template_id])[:-4]
    # make_still ends with width, height, layers, pattern x, y, z and frames (all 1)
    head = still[:-1] + bytes([frames])
    used = footprints.used_sprites(data)
    free = (s for s in range(1, max(used)) if s not in used)
    new_sprites, things = {}, []
    for n in range(len(icons) // frames):
        group = icons[n * frames:(n + 1) * frames]
        sids = [next(free) for _ in group]
        for sid, path in zip(sids, group):
            new_sprites[sid] = icon(path)
        things.append(head + struct.pack('<%dI' % frames, *sids))
        print('client item %d: %s (sprites %s)' % (items + n + 1, os.path.basename(group[0]),
                                                   ', '.join(map(str, sids))))
    header = struct.pack('<IHHHH', signature, items + len(things), outfits, effects, missiles)
    out = header + data[12:items_end] + b''.join(things) + data[items_end:]
    dat_tool.parse(out)
    open(DAT, 'wb').write(out)
    house_reskin.write_spr({sid: Image.fromarray(px) for sid, px in new_sprites.items()})


if __name__ == '__main__':
    main()
