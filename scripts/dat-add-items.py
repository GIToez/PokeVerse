#!/usr/bin/env python3
"""Appends client items to the PokeVerse data.dat as copies of an existing item.

    scripts/dat-add-items.py <data.dat> <template client id> <count>
    scripts/dat-add-items.py <data.dat> --check
    scripts/dat-add-items.py <data.dat> --still <client id> [<client id> ...]
    scripts/dat-add-items.py <data.dat> --unstack <client id> [<client id> ...]

The new items get the next client ids after the last item and draw the template's sprites,
so data.spr does not change. Give them their own art with an `image:` entry under `items:`
in things.otml (the Redemption client draws that PNG instead of the sprites).
--check only parses the file and prints the counts.
--still turns items into a single still picture (one layer, pattern and frame, the first
sprite), keeping their attributes. The client draws an `image:` PNG only on the first
animation frame, so an item copied from an animated template flickers between its PNG and
the template's sprites until it is made still.
--unstack drops the stackable attribute. The client reads a count byte for every stackable
item, so it must match the server's items.otb or the client misreads the rest of the packet.

The format is the 8.54 one with u32 sprite ids: raw attribute 8 has no data and the ones
above it are one lower than in 8.6, and raw 33 is the PokeVerse market block.
"""
import struct
import sys

LAST_ATTR = 0xFF
STACKABLE_ATTR = 5
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


def make_still(data, start, end):
    """The thing at data[start:end] as a 1x1 picture with one layer, pattern and frame."""
    i = start
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
    width, height = data[i], data[i + 1]
    j = i + 2 + (1 if width > 1 or height > 1 else 0) + 5
    first_sprite = data[j:j + 4]
    return data[start:i] + bytes([1, 1, 1, 1, 1, 1, 1]) + first_sprite


def unstack(data, start, end):
    """The thing at data[start:end] without the stackable attribute."""
    out = bytearray()
    i = start
    while True:
        attr = data[i]
        size = 2 if attr in U16_ATTRS else 4 if attr in U16X2_ATTRS else 0
        if attr == MARKET_ATTR:
            name_length = struct.unpack_from('<H', data, i + 7)[0]
            size = 6 + 2 + name_length + 4
        if attr != STACKABLE_ATTR:
            out += data[i:i + 1 + size]
        i += 1 + size
        if attr == LAST_ATTR:
            break
    return bytes(out) + data[i:end]


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
    if len(sys.argv) >= 4 and sys.argv[2] in ('--still', '--unstack'):
        path, ids = sys.argv[1], [int(v) for v in sys.argv[3:]]
        change = make_still if sys.argv[2] == '--still' else unstack
        data = open(path, 'rb').read()
        _, _, _, _, _, offsets, _ = parse(data)
        out, last = [], 0
        for client_id in sorted(ids):
            if client_id not in offsets:
                sys.exit('client id %d not found' % client_id)
            start, end = offsets[client_id]
            out += [data[last:start], change(data, start, end)]
            last = end
        out.append(data[last:])
        out = b''.join(out)
        parse(out)
        open(path, 'wb').write(out)
        print('made %d items %s: %s' % (len(ids), 'still' if change is make_still else 'not stackable',
                                         ' '.join(str(v) for v in sorted(ids))))
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
