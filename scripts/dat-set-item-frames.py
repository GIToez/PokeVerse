#!/usr/bin/env python3
"""Redraws an existing client item as an animation of 32x32 frames, in data.dat and data.spr.

    scripts/dat-set-item-frames.py [--hold N] <client id> <frame.png> [<frame.png> ...]

The item keeps its attributes (stackable and so on) and its id, so the server and items.otb
don't change. It becomes one 1x1 layer with one pattern, so every stack count draws the same
animation. --hold N shows every frame N times: the client plays item frames at
item-ticks-per-frame (75 ms in data/setup.otml), so 12 frames with --hold 3 make a 2.7 second
loop. Its old sprites are left in data.spr; the new ones go on sprite ids no thing uses.
Used for the Verse Orb (client item 6499, server item 6500), from scripts/art/verse_orb.py.
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


def frame(path):
    im = Image.open(path).convert('RGBA')
    if im.size != (32, 32):
        sys.exit('%s: expected 32x32, got %dx%d' % (path, im.width, im.height))
    px = np.array(im)
    px[px[..., 3] == 0] = 0
    return px


def main():
    args = sys.argv[1:]
    hold = 1
    if args and args[0] == '--hold':
        hold, args = int(args[1]), args[2:]
    if len(args) < 2 or hold < 1:
        sys.exit(__doc__)
    client_id, paths = int(args[0]), args[1:]
    if len(paths) * hold > 255:
        sys.exit('%d frames held %d times is more than the 255 a thing can have' % (len(paths), hold))
    data = open(DAT, 'rb').read()
    _, _, _, _, _, offsets, _ = dat_tool.parse(data)
    if client_id not in offsets:
        sys.exit('client id %d not found' % client_id)
    start, end = offsets[client_id]
    # make_still keeps the attributes and ends with width, height, layers, patterns, frames and one sprite
    head = dat_tool.make_still(data, start, end)[:-5]
    used = footprints.used_sprites(data)
    free = (s for s in range(1, max(used)) if s not in used)
    sids = [next(free) for _ in paths]
    order = [sid for sid in sids for _ in range(hold)]
    thing = head + bytes([len(order)]) + struct.pack('<%dI' % len(order), *order)
    out = data[:start] + thing + data[end:]
    dat_tool.parse(out)
    open(DAT, 'wb').write(out)
    import house_reskin
    house_reskin.write_spr({sid: Image.fromarray(frame(p)) for sid, p in zip(sids, paths)})
    print('client item %d: %d frames x%d (sprites %s)' % (client_id, len(paths), hold, ', '.join(map(str, sids))))


if __name__ == '__main__':
    main()
