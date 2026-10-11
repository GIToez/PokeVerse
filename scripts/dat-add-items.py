#!/usr/bin/env python3
"""Appends client items to the PokeVerse data.dat as copies of an existing item.

    scripts/dat-add-items.py <data.dat> <template client id> <count>
    scripts/dat-add-items.py <data.dat> --check

The new items get the next client ids after the last item and draw the template's sprites,
so data.spr does not change. Give them their own art with an `image:` entry under `items:`
in things.otml (the Redemption client draws that PNG instead of the sprites).
--check only parses the file and prints the counts.

The format is the 8.54 one with u32 sprite ids: raw attribute 8 has no data and the ones
above it are one lower than in 8.6, and raw 33 is the PokeVerse market block.
"""
import struct
import sys

LAST_ATTR = 0xFF
# raw attribute -> size of its data; attributes not listed have none
U16_ATTRS = {0, 9, 10, 26, 29, 30}
U16X2_ATTRS = {22, 25}
MARKET_ATTR = 33


def read_thing(data, i):
    """Returns the index just after the thing that starts at i."""
    while True:
        attr = data[i]
        i += 1
        if attr == LAST_ATTR:
            break
        if attr in U16_ATTRS:
            i += 2
        elif attr in U16X2_ATTRS:
            i += 4
        elif attr == MARKET_ATTR:
            i += 6
            name_length = struct.unpack_from('<H', data, i)[0]
            i += 2 + name_length + 4
        elif attr > 40:
            raise ValueError('unknown attribute %d at byte %d' % (attr, i - 1))

    width, height = data[i], data[i + 1]
    i += 2
    if width > 1 or height > 1:
        i += 1
    layers, pattern_x, pattern_y, pattern_z, frames = data[i:i + 5]
    i += 5
    return i + 4 * width * height * layers * pattern_x * pattern_y * pattern_z * frames


def parse(data):
    signature, items, outfits, effects, missiles = struct.unpack_from('<IHHHH', data, 0)
    offsets = {}
    i = 12
    for client_id in range(100, items + 1):
        start = i
        i = read_thing(data, i)
        offsets[client_id] = (start, i)
    items_end = i
    for _ in range(outfits + effects + missiles):
        i = read_thing(data, i)
    if i != len(data):
        raise ValueError('parsed %d of %d bytes' % (i, len(data)))
    return signature, items, outfits, effects, missiles, offsets, items_end


def main():
    if len(sys.argv) == 3 and sys.argv[2] == '--check':
        data = open(sys.argv[1], 'rb').read()
        _, items, outfits, effects, missiles, _, _ = parse(data)
        print('items 100-%d, %d outfits, %d effects, %d missiles' % (items, outfits, effects, missiles))
        return
    if len(sys.argv) != 4:
        sys.exit(__doc__)

    path, template_id, count = sys.argv[1], int(sys.argv[2]), int(sys.argv[3])
    data = open(path, 'rb').read()
    signature, items, outfits, effects, missiles, offsets, items_end = parse(data)
    if template_id not in offsets:
        sys.exit('template client id %d not found (items are 100-%d)' % (template_id, items))
    if items + count > 0xFFFF:
        sys.exit('too many items')

    start, end = offsets[template_id]
    header = struct.pack('<IHHHH', signature, items + count, outfits, effects, missiles)
    out = header + data[12:items_end] + data[start:end] * count + data[items_end:]
    parse(out)
    open(path, 'wb').write(out)
    print('added client items %d-%d (copies of %d)' % (items + 1, items + count, template_id))


if __name__ == '__main__':
    main()
