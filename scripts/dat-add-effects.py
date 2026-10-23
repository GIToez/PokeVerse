#!/usr/bin/env python3
"""Appends effects to the PokeVerse data.dat for art drawn from PNG frames.

    scripts/dat-add-effects.py <data.dat> <tiles>:<frames> [<tiles>:<frames> ...]

Each effect is <tiles> by <tiles> (1 for 32 px art, 2 for 64 px) with <frames> animation frames,
and gets the next client effect id (the server's effect id is one lower). Its sprites are all
sprite 0 (nothing), so it only shows through an `image-frames:` entry under `effects:` in
things.otml; the folder needs at least <frames> PNGs of <tiles> * 32 pixels. The client plays one
frame per effect tick, so the frame count sets how long it shows.
"""
import importlib.util
import os
import struct
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
spec = importlib.util.spec_from_file_location('dat_add_items', os.path.join(ROOT, 'scripts', 'dat-add-items.py'))
dat_tool = importlib.util.module_from_spec(spec)
spec.loader.exec_module(dat_tool)


def blank_effect(tiles, frames):
    size = bytes([tiles, tiles]) + (bytes([tiles * 32]) if tiles > 1 else b'')
    sprites = tiles * tiles * frames
    return bytes([dat_tool.LAST_ATTR]) + size + bytes([1, 1, 1, 1, frames]) + b'\0\0\0\0' * sprites


def main():
    if len(sys.argv) < 3:
        sys.exit(__doc__)
    path, specs = sys.argv[1], []
    for arg in sys.argv[2:]:
        tiles, frames = (int(v) for v in arg.split(':'))
        if tiles not in (1, 2) or not 1 <= frames <= 255:
            sys.exit('bad effect %s' % arg)
        specs.append((tiles, frames))
    data = open(path, 'rb').read()
    signature, items, outfits, effects, missiles, _, items_end = dat_tool.parse(data)
    i = items_end
    for _ in range(outfits + effects):
        i = dat_tool.read_thing(data, i)
    added = b''.join(blank_effect(t, f) for t, f in specs)
    header = struct.pack('<IHHHH', signature, items, outfits, effects + len(specs), missiles)
    out = header + data[12:i] + added + data[i:]
    dat_tool.parse(out)
    open(path, 'wb').write(out)
    print('added client effects %d-%d (server %d-%d)' % (effects + 1, effects + len(specs), effects, effects + len(specs) - 1))


if __name__ == '__main__':
    main()
