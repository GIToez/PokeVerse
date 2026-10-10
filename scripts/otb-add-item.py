#!/usr/bin/env python3
"""Appends a server item to items.otb that copies an existing item's flags and attributes.

    scripts/otb-add-item.py <items.otb> <template server id> <new server id> [client id]

The new id must be the next free id after the last item. The server reads ids 30001-30099 as 1-99,
so those can't be used. Clients don't read items.otb; the new item draws the template's (or the
given) client sprite.
"""
import struct
import sys

ESCAPE, START, END = 0xFD, 0xFE, 0xFF
ATTR_SERVERID, ATTR_CLIENTID = 0x10, 0x11


def escape(data):
    out = bytearray()
    for b in data:
        if b in (ESCAPE, START, END):
            out.append(ESCAPE)
        out.append(b)
    return bytes(out)


def read_node(data, i):
    """Returns (type, unescaped props, children as (start, end) spans, end index) for the node at i."""
    assert data[i] == START
    start = i
    i += 1
    node_type = data[i]
    i += 1
    props = bytearray()
    children = []
    while True:
        b = data[i]
        if b == ESCAPE:
            props.append(data[i + 1])
            i += 2
        elif b == START:
            _, _, _, child_end = read_node(data, i)
            children.append((i, child_end))
            i = child_end
        elif b == END:
            return node_type, bytes(props), children, i + 1
        else:
            props.append(b)
            i += 1


def item_attrs(props):
    attrs = []
    j = 4
    while j < len(props):
        attr = props[j]
        length = struct.unpack('<H', props[j + 1:j + 3])[0]
        attrs.append((attr, props[j + 3:j + 3 + length]))
        j += 3 + length
    return props[:4], attrs


def main():
    if len(sys.argv) not in (4, 5):
        sys.exit(__doc__)
    path, template_id, new_id = sys.argv[1], int(sys.argv[2]), int(sys.argv[3])
    client_id = int(sys.argv[4]) if len(sys.argv) == 5 else None
    if 30000 < new_id < 30100:
        sys.exit('ids 30001-30099 are read as 1-99 by the server')

    data = open(path, 'rb').read()
    _, _, root_children, root_end = read_node(data, 4)

    template = None
    last_id = 0
    for start, end in root_children:
        node_type, props, _, _ = read_node(data, start)
        flags, attrs = item_attrs(props)
        server_id = next(struct.unpack('<H', v)[0] for a, v in attrs if a == ATTR_SERVERID)
        last_id = max(last_id, server_id)
        if server_id == template_id:
            template = (node_type, flags, attrs)
    if template is None:
        sys.exit('template id %d not found' % template_id)
    if new_id != last_id + 1:
        sys.exit('new id must be %d (the last item is %d)' % (last_id + 1, last_id))

    node_type, flags, attrs = template
    props = bytearray(flags)
    for attr, value in attrs:
        if attr == ATTR_SERVERID:
            value = struct.pack('<H', new_id)
        elif attr == ATTR_CLIENTID and client_id is not None:
            value = struct.pack('<H', client_id)
        props += bytes([attr]) + struct.pack('<H', len(value)) + value
    node = bytes([START, node_type]) + escape(bytes(props)) + bytes([END])

    insert_at = root_end - 1
    assert data[insert_at] == END
    open(path, 'wb').write(data[:insert_at] + node + data[insert_at:])
    print('added item %d (copy of %d)' % (new_id, template_id))


if __name__ == '__main__':
    main()
