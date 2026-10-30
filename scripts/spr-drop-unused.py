#!/usr/bin/env python3
"""Drops the art no client thing uses from the PokeVerse data.spr.

    scripts/spr-drop-unused.py [--dry-run]

dat-set-outfit.py and the other art tools leave a replaced outfit's old sprites in data.spr, and
write new sprites on the end of the file with the old bytes left behind. This rewrites data.spr
with only the sprites an item, outfit, effect or missile in data.dat draws: every other sprite id
becomes empty (the art tools reuse those ids), and the unused bytes go. Sprite ids, the count and
the signature stay the same, so data.dat doesn't change. Nothing in the clients draws a sprite
by its id, only through data.dat's things.
"""
import os
import struct
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
THINGS = os.path.join(ROOT, 'core', 'client-legacy', 'data', 'things')
sys.path.insert(0, os.path.join(ROOT, 'scripts'))


def load(name):
    import importlib.util
    spec = importlib.util.spec_from_file_location(name.replace('-', '_'), os.path.join(ROOT, 'scripts', name + '.py'))
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


dat_tool = load('dat-add-items')


def used_sprites(data):
    """Every sprite id a thing in data.dat draws."""
    _, items, outfits, effects, missiles = struct.unpack_from('<IHHHH', data, 0)
    used, i = set(), 12
    for _ in range(items - 99 + outfits + effects + missiles):
        end = dat_tool.read_thing(data, i)
        j = i
        while data[j] != dat_tool.LAST_ATTR:
            attr = data[j]
            j += 1
            if attr in dat_tool.U16_ATTRS:
                j += 2
            elif attr in dat_tool.U16X2_ATTRS:
                j += 4
            elif attr == dat_tool.MARKET_ATTR:
                j += 6
                j += 2 + struct.unpack_from('<H', data, j)[0] + 4
        j += 1
        width, height = data[j], data[j + 1]
        j += 2 + (1 if width > 1 or height > 1 else 0) + 5
        used.update(struct.unpack_from('<%dI' % ((end - j) // 4), data, j))
        i = end
    used.discard(0)
    return used


def main():
    dry = '--dry-run' in sys.argv[1:]
    dat, spr = os.path.join(THINGS, 'data.dat'), os.path.join(THINGS, 'data.spr')
    used = used_sprites(open(dat, 'rb').read())
    with open(spr, 'rb') as src:
        signature, count = struct.unpack('<II', src.read(8))
        offsets = struct.unpack('<%dI' % count, src.read(4 * count))
        if max(used) > count:
            sys.exit('data.dat draws sprite %d, data.spr has %d' % (max(used), count))
        keep = [sid for sid in range(1, count + 1) if offsets[sid - 1] and sid in used]
        dropped = sum(1 for sid in range(1, count + 1) if offsets[sid - 1] and sid not in used)
        missing = sum(1 for sid in used if not offsets[sid - 1])
        before = os.path.getsize(spr)
        out = spr + '.tmp'
        with open(out, 'wb') as dst:
            dst.write(struct.pack('<II', signature, count))
            dst.write(b'\0' * 4 * count)
            new = [0] * count
            for sid in keep:
                src.seek(offsets[sid - 1] + 3)
                size = struct.unpack('<H', src.read(2))[0]
                src.seek(offsets[sid - 1])
                new[sid - 1] = dst.tell()
                dst.write(src.read(5 + size))
            dst.seek(8)
            dst.write(struct.pack('<%dI' % count, *new))
        after = os.path.getsize(out)
    print('%d sprites kept, %d unused dropped, %d drawn but empty; %.1f MB -> %.1f MB'
          % (len(keep), dropped, missing, before / 2 ** 20, after / 2 ** 20))
    if dry:
        os.remove(out)
    else:
        os.replace(out, spr)


if __name__ == '__main__':
    main()
