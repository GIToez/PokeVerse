#!/usr/bin/env python3
"""Gives walls a hook, so wall props (wreaths, banners, tapestries) hang on them.

    scripts/item-hooks.py <items.otb> <data.dat> --south <server ids> --east <server ids> [--check]

A wall along a room's north side (it runs east-west) hooks south; one along its west side (it runs
north-south) hooks east. Ids are comma-separated server ids. The server reads the hook from
items.otb (FLAG_HORIZONTAL is south, FLAG_VERTICAL is east) and the client draws a hung prop
facing that way from data.dat (8.54 raw attribute 19 is south, 20 is east), so both files change.
--check only prints what each id has now.
"""
import importlib.util
import os
import struct
import sys

HERE = os.path.dirname(os.path.abspath(__file__))


def load(name):
    spec = importlib.util.spec_from_file_location(name.replace('-', '_'), os.path.join(HERE, name + '.py'))
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


otb = load('otb-add-item')
dat = load('dat-add-items')

FLAG_HANGABLE, FLAG_VERTICAL, FLAG_HORIZONTAL = 1 << 16, 1 << 17, 1 << 18
OTB_FLAG = {'south': FLAG_HORIZONTAL, 'east': FLAG_VERTICAL}
DAT_ATTR = {'south': 19, 'east': 20}


def otb_items(data):
    """{server id: (node start, node end, node type, flags, attrs)}"""
    _, _, children, _ = otb.read_node(data, 4)
    items = {}
    for start, end in children:
        node_type, props, _, _ = otb.read_node(data, start)
        flags, attrs = otb.item_attrs(props)
        server_id = next(struct.unpack('<H', v)[0] for a, v in attrs if a == otb.ATTR_SERVERID)
        items[server_id] = (start, end, node_type, struct.unpack('<I', flags)[0], attrs)
    return items


def client_id(attrs):
    return next(struct.unpack('<H', v)[0] for a, v in attrs if a == otb.ATTR_CLIENTID)


def dat_attrs(data, start):
    """The raw attributes of the thing at start as [(attr, its data)], and the index of its 0xFF."""
    attrs, i = [], start
    while data[i] != dat.LAST_ATTR:
        attr = data[i]
        i += 1
        if attr in dat.U16_ATTRS:
            size = 2
        elif attr in dat.U16X2_ATTRS:
            size = 4
        elif attr == dat.MARKET_ATTR:
            size = 8 + struct.unpack_from('<H', data, i + 6)[0] + 4
        else:
            size = 0
        attrs.append((attr, data[i:i + size]))
        i += size
    return attrs, i


def describe(flags):
    return ''.join(c if flags & f else '-' for c, f in (('S', FLAG_HORIZONTAL), ('E', FLAG_VERTICAL), ('H', FLAG_HANGABLE)))


def main():
    args = sys.argv[1:]
    check = '--check' in args
    args = [a for a in args if a != '--check']
    if len(args) < 2:
        sys.exit(__doc__)
    otb_path, dat_path, rest = args[0], args[1], args[2:]
    wanted = {}
    while rest:
        side, ids = rest[0].lstrip('-'), rest[1] if len(rest) > 1 else ''
        if side not in OTB_FLAG or not ids:
            sys.exit(__doc__)
        for sid in ids.split(','):
            wanted[int(sid)] = side
        rest = rest[2:]

    otb_data = open(otb_path, 'rb').read()
    dat_data = open(dat_path, 'rb').read()
    items = otb_items(otb_data)
    offsets = dat.parse(dat_data)[5]
    for sid in wanted:
        if sid not in items:
            sys.exit('server item %d is not in %s' % (sid, otb_path))
        if items[sid][3] & FLAG_HANGABLE:
            sys.exit('server item %d hangs on walls itself' % sid)

    if check:
        for sid, side in sorted(wanted.items()):
            _, _, _, flags, attrs = items[sid]
            cid = client_id(attrs)
            raw = [a for a, _ in dat_attrs(dat_data, offsets[cid][0])[0]] if cid in offsets else None
            print('%d (client %s): otb %s, dat %s' % (sid, cid, describe(flags), raw))
        return

    # Rewrite from the end of each file so earlier offsets stay valid
    otb_edits = []
    for sid, side in wanted.items():
        start, end, node_type, flags, attrs = items[sid]
        flags = (flags & ~(FLAG_HORIZONTAL | FLAG_VERTICAL)) | OTB_FLAG[side]
        props = bytearray(struct.pack('<I', flags))
        for attr, value in attrs:
            props += bytes([attr]) + struct.pack('<H', len(value)) + value
        otb_edits.append((start, end, bytes([otb.START, node_type]) + otb.escape(bytes(props)) + bytes([otb.END])))
    for start, end, node in sorted(otb_edits, reverse=True):
        otb_data = otb_data[:start] + node + otb_data[end:]

    sides = {}
    for sid, side in wanted.items():
        cid = client_id(items[sid][4])
        if cid not in offsets:
            sys.exit('client item %d (server %d) is not in %s' % (cid, sid, dat_path))
        if sides.setdefault(cid, side) != side:
            sys.exit('client item %d is drawn by server items hooking both south and east' % cid)
    dat_edits = []
    for cid, side in sides.items():
        start = offsets[cid][0]
        attrs, end = dat_attrs(dat_data, start)
        attrs = sorted([(a, v) for a, v in attrs if a not in DAT_ATTR.values()] + [(DAT_ATTR[side], b'')])
        dat_edits.append((start, end, b''.join(bytes([a]) + v for a, v in attrs)))
    for start, end, attrs in sorted(set(dat_edits), reverse=True):
        dat_data = dat_data[:start] + attrs + dat_data[end:]

    dat.parse(dat_data)
    if set(otb_items(otb_data)) != set(items):
        raise ValueError('items.otb lost or gained items')
    open(otb_path, 'wb').write(otb_data)
    open(dat_path, 'wb').write(dat_data)
    south = sorted(s for s, side in wanted.items() if side == 'south')
    east = sorted(s for s, side in wanted.items() if side == 'east')
    print('hook south: %s' % (', '.join(map(str, south)) or 'none'))
    print('hook east: %s' % (', '.join(map(str, east)) or 'none'))


if __name__ == '__main__':
    main()
