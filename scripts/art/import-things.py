#!/usr/bin/env python3
"""Adds items and outfits from another client's 10.98 Tibia.dat / Tibia.spr to the PokeVerse data.dat and data.spr.

    scripts/art/import-things.py <source folder> <list.csv> [--out mapping.csv]

The list has a header and one row per thing: `kind,source id,name` (kind `item` or `outfit`; the name is
for the server's items.xml and may be empty). Nothing of ours changes: the new items go after our last
item, the new outfits after our last outfit, and their sprites after our last sprite (a sprite that is
already in data.spr, byte for byte, is reused). Every layer, pattern and frame is kept, so trainer outfits
still take the head, body, legs and feet colours. Outfits keep the walking frames with the idle frame first,
the way the 8.54 client animates them, and drop the mount patterns (the 8.54 client has no mounts).

New items also get a server item in items.otb and items.xml: a copy of one of ours with the same
client flags (ground and its speed, blocking, stacking order, pickupable and so on), pointing at the new
client id. The mapping file lists kind, source id, new client id (items and outfits), server id (items) and name.
Run scripts/mapper/sync.py afterwards so the map editor gets the new things.
"""
import argparse
import csv
import hashlib
import importlib.util
import os
import struct
import sys
from xml.sax.saxutils import quoteattr

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
THINGS = os.path.join(ROOT, 'core/client-legacy/data/things')
ITEMS = os.path.join(ROOT, 'core/server/data/items')


def load(name):
    spec = importlib.util.spec_from_file_location(name.replace('-', '_'), os.path.join(ROOT, 'scripts', name + '.py'))
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


otb_tool = load('otb-add-item')

# 10.98 attribute -> size of its data (attributes not listed have none)
SRC_U16 = {0, 8, 9, 26, 29, 30, 33, 35}
SRC_U16X2 = {22, 25}
SRC_MARKET = 34
# ours (8.54 with u32 sprites)
OUR_U16 = {0, 9, 10, 26, 29, 30}
OUR_U16X2 = {22, 25}
OUR_MARKET = 33
OTB_SPEED, OTB_LIGHT = 0x14, 0x2A
# client flags the server item has to agree with; the rest (light, minimap colour...) don't matter for the template
TEMPLATE_FLAGS = (1, 2, 3, 4, 5, 6, 7, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 27, 31)


def our_attr(src):
    """10.98 attribute -> ours, or None to drop it (no-move-animation, cloth, market, usable, wrapping...)."""
    if src < 8:
        return src
    if src <= 15:
        return src + 1
    if 17 <= src <= 32:
        return src
    return None


def parse_source(path):
    data = open(path, 'rb').read()
    _, items, outfits, effects, missiles = struct.unpack_from('<IHHHH', data, 0)
    out = {'item': {}, 'outfit': {}}
    i = 12
    for cat, first, last in (('item', 100, items), ('outfit', 1, outfits), ('effect', 1, effects), ('missile', 1, missiles)):
        for cid in range(first, last + 1):
            attrs = []
            while True:
                a = data[i]
                i += 1
                if a == 0xFF:
                    break
                if a in SRC_U16:
                    attrs.append((a, data[i:i + 2]))
                    i += 2
                elif a in SRC_U16X2:
                    attrs.append((a, data[i:i + 4]))
                    i += 4
                elif a == SRC_MARKET:
                    i += 6
                    n = struct.unpack_from('<H', data, i)[0]
                    i += 2 + n + 4
                else:
                    attrs.append((a, b''))
            groups = []
            ngroups = 1
            if cat == 'outfit':
                ngroups = data[i]
                i += 1
            for _ in range(ngroups):
                kind = 0
                if cat == 'outfit':
                    kind = data[i]
                    i += 1
                w, h = data[i], data[i + 1]
                i += 2
                exact = 32
                if w > 1 or h > 1:
                    exact = data[i]
                    i += 1
                layers, px, py, pz, frames = data[i:i + 5]
                i += 5
                if frames > 1:
                    i += 1 + 4 + 1 + 8 * frames
                n = w * h * layers * px * py * pz * frames
                sprites = struct.unpack_from('<%dI' % n, data, i)
                i += 4 * n
                groups.append((kind, w, h, exact, layers, px, py, pz, frames, sprites))
            if cat in out:
                out[cat][cid] = (attrs, groups)
    assert i == len(data), (i, len(data))
    return out


def sprite_index(frame, z, y, x, layer, tile, w, h, layers, px, py, pz):
    return ((((frame * pz + z) * py + y) * px + x) * layers + layer) * w * h + tile


def flatten(cat, groups):
    """One 8.54 group: (w, h, exact, layers, px, py, pz, frames, sprites)."""
    if cat == 'item' or len(groups) == 1:
        _, w, h, exact, layers, px, py, pz, frames, sprites = groups[0]
        frame_list = [(groups[0], f) for f in range(frames)]
    else:
        idle = next((g for g in groups if g[0] == 0), groups[0])
        moving = next((g for g in groups if g[0] == 1), groups[-1])
        _, w, h, exact, layers, px, py, pz, frames, sprites = moving
        same = idle[1:8] == moving[1:8]
        frame_list = ([(idle, 0)] if same else []) + [(moving, f) for f in range(moving[8])]
    keep_z = 1 if cat == 'outfit' else pz
    out = []
    for group, f in frame_list:
        _, gw, gh, _, gl, gpx, gpy, gpz, _, gs = group
        for z in range(keep_z):
            for y in range(py):
                for x in range(px):
                    for layer in range(layers):
                        for tile in range(w * h):
                            out.append(gs[sprite_index(f, z, y, x, layer, tile, gw, gh, gl, gpx, gpy, gpz)])
    return w, h, exact, layers, px, py, keep_z, len(frame_list), out


def encode_thing(attrs, group, sprite_map):
    w, h, exact, layers, px, py, pz, frames, sprites = group
    out = bytearray()
    for a, value in attrs:
        ours = our_attr(a)
        if ours is not None:
            out.append(ours)
            out += value
    out.append(0xFF)
    out += bytes([w, h])
    if w > 1 or h > 1:
        out.append(exact)
    out += bytes([layers, px, py, pz, frames])
    for s in sprites:
        out += struct.pack('<I', sprite_map.get(s, 0))
    return bytes(out)


def read_spr(path):
    data = open(path, 'rb').read()
    signature, count = struct.unpack_from('<II', data, 0)
    offsets = struct.unpack_from('<%dI' % count, data, 8)
    return data, signature, count, offsets


def blob(data, offset):
    if offset == 0:
        return None
    size = struct.unpack_from('<H', data, offset + 3)[0]
    return data[offset:offset + 5 + size]


def our_flags(raw, i):
    """Flags (and ground speed) of one of our things starting at byte i, and the index after its attributes."""
    flags, speed = set(), 0
    while True:
        a = raw[i]
        i += 1
        if a == 0xFF:
            return flags, speed, i
        if a == 0:
            speed = struct.unpack_from('<H', raw, i)[0]
        if a in OUR_U16:
            i += 2
        elif a in OUR_U16X2:
            i += 4
        elif a == OUR_MARKET:
            i += 6
            n = struct.unpack_from('<H', raw, i)[0]
            i += 2 + n + 4
        flags.add(a)


def client_light(raw):
    """The otb light value (level, colour as u16 each) from an encoded thing of ours, or None."""
    i = 0
    while raw[i] != 0xFF:
        a = raw[i]
        i += 1
        if a == 22:
            return raw[i:i + 4]
        if a in OUR_U16:
            i += 2
        elif a in OUR_U16X2:
            i += 4
    return None


def template_key(flags, speed):
    return tuple(sorted(f for f in flags if f in TEMPLATE_FLAGS)) + (('ground', speed) if 0 in flags else ())


def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument('source')
    parser.add_argument('list')
    parser.add_argument('--out', default=None)
    args = parser.parse_args()

    rows = [r for r in csv.DictReader(open(args.list, encoding='utf-8')) if r.get('kind')]
    source = parse_source(os.path.join(args.source, 'Tibia.dat'))
    src_spr, _, _, src_offsets = read_spr(os.path.join(args.source, 'Tibia.spr'))

    dat_path, spr_path = os.path.join(THINGS, 'data.dat'), os.path.join(THINGS, 'data.spr')
    dat = open(dat_path, 'rb').read()
    dat_tool = load('dat-add-items')
    signature, n_items, n_outfits, n_effects, n_missiles, offsets, items_end = dat_tool.parse(dat)
    outfits_end = items_end
    for _ in range(n_outfits):
        outfits_end = dat_tool.read_thing(dat, outfits_end)
    our_spr, spr_signature, our_count, our_offsets = read_spr(spr_path)

    known = {}
    for sid, off in enumerate(our_offsets, 1):
        b = blob(our_spr, off)
        if b:
            known.setdefault(hashlib.sha1(b[3:]).digest(), sid)

    wanted = []
    for row in rows:
        kind, src_id = row['kind'].strip(), int(row['source id'])
        if src_id not in source[kind]:
            sys.exit('%s %d is not in the source' % (kind, src_id))
        attrs, groups = source[kind][src_id]
        wanted.append((kind, src_id, (row.get('name') or '').strip(), attrs, flatten(kind, groups)))

    sprite_map, new_blobs = {}, []
    for _, _, _, _, group in wanted:
        for s in group[8]:
            if s == 0 or s in sprite_map:
                continue
            b = blob(src_spr, src_offsets[s - 1]) if s <= len(src_offsets) else None
            if b is None:
                sprite_map[s] = 0
                continue
            key = hashlib.sha1(b[3:]).digest()
            if key not in known:
                new_blobs.append(b)
                known[key] = our_count + len(new_blobs)
            sprite_map[s] = known[key]

    item_bytes, outfit_bytes, mapping = bytearray(), bytearray(), []
    next_item, next_outfit = n_items + 1, n_outfits + 1
    for kind, src_id, name, attrs, group in wanted:
        encoded = encode_thing(attrs, group, sprite_map)
        if kind == 'item':
            item_bytes += encoded
            mapping.append([kind, src_id, next_item, '', name, encoded])
            next_item += 1
        else:
            outfit_bytes += encoded
            mapping.append([kind, src_id, next_outfit, '', name, None])
            next_outfit += 1
    if next_item - 1 > 0xFFFF:
        sys.exit('too many items for u16 client ids')

    header = struct.pack('<IHHHH', signature, next_item - 1, next_outfit - 1, n_effects, n_missiles)
    new_dat = header + dat[12:items_end] + item_bytes + dat[items_end:outfits_end] + outfit_bytes + dat[outfits_end:]

    # server items: a copy of one of ours with the same client flags
    otb_path, xml_path = os.path.join(ITEMS, 'items.otb'), os.path.join(ITEMS, 'items.xml')
    otb = open(otb_path, 'rb').read()
    _, _, root_children, root_end = otb_tool.read_node(otb, 4)
    by_client, last_server = {}, 0
    for start, end in root_children:
        node_type, props, _, _ = otb_tool.read_node(otb, start)
        flag_bytes, attrs = otb_tool.item_attrs(props)
        values = {a: v for a, v in attrs}
        if otb_tool.ATTR_SERVERID not in values:
            continue
        server_id = struct.unpack('<H', values[otb_tool.ATTR_SERVERID])[0]
        last_server = max(last_server, server_id)
        if otb_tool.ATTR_CLIENTID in values:
            by_client.setdefault(struct.unpack('<H', values[otb_tool.ATTR_CLIENTID])[0], (server_id, node_type, flag_bytes, attrs))
    templates = {}
    for client_id, (start, _) in offsets.items():
        if client_id in by_client:
            flags, speed, _ = our_flags(dat, start)
            templates.setdefault(template_key(flags, speed), by_client[client_id])
    nodes, xml_lines, server_id = bytearray(), [], last_server
    for row in mapping:
        if row[0] != 'item':
            continue
        flags, speed, _ = our_flags(row[5], 0)
        key = template_key(flags, speed)
        template = templates.get(key)
        if template is None and 0 in flags:
            template = next((t for k, t in templates.items()
                             if len(k) > 1 and k[-2] == 'ground' and k[:-2] == key[:-2]), None)
        if template is None:
            sys.exit('no item of ours has the client flags of %s %d: %s' % (row[0], row[1], key))
        server_id += 1
        if 30000 < server_id < 30100:
            server_id = 30100
        _, node_type, flag_bytes, attrs = template
        light = client_light(row[5])
        props = bytearray(flag_bytes)
        for attr, value in attrs:
            if attr == otb_tool.ATTR_SERVERID:
                value = struct.pack('<H', server_id)
            elif attr == otb_tool.ATTR_CLIENTID:
                value = struct.pack('<H', row[2])
            elif attr == OTB_SPEED and 0 in flags:
                value = struct.pack('<H', speed)
            elif attr == OTB_LIGHT:
                if light is None:
                    continue
                value, light = light, None
            props += bytes([attr]) + struct.pack('<H', len(value)) + value
        if light is not None:
            props += bytes([OTB_LIGHT]) + struct.pack('<H', len(light)) + light
        nodes += bytes([otb_tool.START, node_type]) + otb_tool.escape(bytes(props)) + bytes([otb_tool.END])
        row[3] = server_id
        xml_lines.append('\t<item id="%d" name=%s/>\n' % (server_id, quoteattr(row[4] or 'decoration')))
    insert_at = root_end - 1
    xml = open(xml_path, 'rb').read()
    end = xml.rindex(b'</items>')

    count = our_count + len(new_blobs)
    shift = 4 * len(new_blobs)
    body_start = 8 + 4 * our_count
    new_offsets = [o + shift if o else 0 for o in our_offsets]
    pos = 8 + 4 * count + (len(our_spr) - body_start)
    for b in new_blobs:
        new_offsets.append(pos)
        pos += len(b)
    with open(spr_path, 'wb') as f:
        f.write(struct.pack('<II', spr_signature, count))
        f.write(struct.pack('<%dI' % count, *new_offsets))
        f.write(memoryview(our_spr)[body_start:])
        for b in new_blobs:
            f.write(b)
    open(dat_path, 'wb').write(new_dat)
    open(otb_path, 'wb').write(otb[:insert_at] + bytes(nodes) + otb[insert_at:])
    if xml_lines:
        open(xml_path, 'wb').write(xml[:end] + ''.join(xml_lines).encode('latin-1', 'replace') + xml[end:])

    print('%d items (client %d-%d), %d outfits (%d-%d), %d new sprites (%d reused)' % (
        sum(r[0] == 'item' for r in mapping), n_items + 1, next_item - 1, sum(r[0] == 'outfit' for r in mapping),
        n_outfits + 1, next_outfit - 1, len(new_blobs), len([s for s in sprite_map.values() if s and s <= our_count])))
    if args.out:
        with open(args.out, 'w', newline='', encoding='utf-8') as f:
            w = csv.writer(f)
            w.writerow(['kind', 'source id', 'client id', 'server id', 'name'])
            for row in mapping:
                w.writerow(row[:5])


if __name__ == '__main__':
    main()
