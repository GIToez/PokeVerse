#!/usr/bin/env python3
"""Adds a set of footprints: one trace item per ground (dirt, grass, sand) for a kind of walker.

    scripts/add-footprints.py <set> <style> [<species> ...]
    scripts/add-footprints.py --turn
    scripts/add-footprints.py --lua

The sets live in scripts/art/footprints.json. "trainer" (shoe prints, players and NPCs) uses the
original trace items. "pokemon" (paired ovals) is what every Pokemon leaves unless a set lists its
species; a species set, e.g. `add-footprints.py pikachu paw Pikachu Raichu`, gets its own items.
The style names a print drawing in ds_world.PRINT_STYLES.

Each new item copies its ground's template trace: the same ground layer, with the prints layer
pointed at a sprite no item uses, which ds_world.py draws. It is appended to data.dat, items.otb
and items.xml, and the server's footprints table (lib/ps/config/footprints.lua) is written again.
The template's prints face north; each set also gets an east, a south and a west item per ground
(--turn adds the ones a set is missing), drawn turned, so the prints follow the way the walker goes.
Run ds_world.py --write-prints afterwards so the new prints are drawn into data.spr.
--lua only writes the table again.
"""
import importlib.util
import json
import os
import re
import struct
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
MANIFEST = os.path.join(ROOT, 'scripts/art/footprints.json')
DAT = os.path.join(ROOT, 'core/client-legacy/data/things/data.dat')
OTB = os.path.join(ROOT, 'core/server/data/items/items.otb')
XML = os.path.join(ROOT, 'core/server/data/items/items.xml')
LUA = os.path.join(ROOT, 'core/server/data/lib/ps/config/footprints.lua')
TURNS = ('east', 'south', 'west')


def load(name):
    spec = importlib.util.spec_from_file_location(name.replace('-', '_'), os.path.join(ROOT, 'scripts', name + '.py'))
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


dat_tool, otb_tool = load('dat-add-items'), load('otb-add-item')


def sprite_span(data, start):
    """(offset of the sprite ids, layers) of the thing at start."""
    i = start
    while True:
        attr = data[i]
        i += 1
        if attr == dat_tool.LAST_ATTR:
            break
        if attr in dat_tool.U16_ATTRS:
            i += 2
        elif attr in dat_tool.U16X2_ATTRS:
            i += 4
        elif attr == dat_tool.MARKET_ATTR:
            i += 6
            i += 2 + struct.unpack_from('<H', data, i)[0] + 4
    width, height = data[i], data[i + 1]
    i += 2 + (1 if width > 1 or height > 1 else 0)
    return i + 5, data[i]


def all_things(data):
    """(start, end) of every thing in the file: items, outfits, effects and missiles."""
    _, items, outfits, effects, missiles, offsets, i = dat_tool.parse(data)
    spans = [offsets[c] for c in range(100, items + 1)]
    for _ in range(outfits + effects + missiles):
        end = dat_tool.read_thing(data, i)
        spans.append((i, end))
        i = end
    return spans


def used_sprites(data):
    used = set()
    for start, end in all_things(data):
        at, _ = sprite_span(data, start)
        used.update(struct.unpack_from('<%dI' % ((end - at) // 4), data, at))
    return used


def otb_items(data):
    _, _, children, _ = otb_tool.read_node(data, 4)
    items = {}
    for start, end in children:
        _, props, _, _ = otb_tool.read_node(data, start)
        _, attrs = otb_tool.item_attrs(props)
        attrs = dict(attrs)
        sid = struct.unpack('<H', attrs[otb_tool.ATTR_SERVERID])[0]
        cid = struct.unpack('<H', attrs[otb_tool.ATTR_CLIENTID])[0] if otb_tool.ATTR_CLIENTID in attrs else None
        items[sid] = (start, end, cid)
    return items


def add_otb_item(data, template, server_id, client_id):
    _, _, _, root_end = otb_tool.read_node(data, 4)
    start, end, _ = otb_items(data)[template]
    node_type, props, _, _ = otb_tool.read_node(data, start)
    flags, attrs = otb_tool.item_attrs(props)
    out = bytearray(flags)
    for attr, value in attrs:
        if attr == otb_tool.ATTR_SERVERID:
            value = struct.pack('<H', server_id)
        elif attr == otb_tool.ATTR_CLIENTID:
            value = struct.pack('<H', client_id)
        out += bytes([attr]) + struct.pack('<H', len(value)) + value
    node = bytes([otb_tool.START, node_type]) + otb_tool.escape(bytes(out)) + bytes([otb_tool.END])
    return data[:root_end - 1] + node + data[root_end - 1:]


def xml_block(xml, server_id):
    m = re.search(r'\t<item id="%d"[^>]*?(?:/>|[^/]>.*?</item>)\n' % server_id, xml, re.S)
    if not m:
        sys.exit('item %d is not in items.xml' % server_id)
    return m.group(0)


def write_lua(manifest):
    lines = ['-- Written by scripts/add-footprints.py from scripts/art/footprints.json; do not edit.',
             '-- The ground a walker steps on, and the trace item each set of footprints turns it into.',
             'FOOTPRINT_GROUNDS = {']
    for ground, info in manifest['grounds'].items():
        lines.append('    -- %s' % ground.capitalize())
        lines += ['    [%d] = "%s",' % (g, ground) for g in info['grounds']]
    lines += ['}', '', '-- set -> ground -> the way the walker faces -> trace item', 'FOOTPRINTS = {']
    for name, s in manifest['sets'].items():
        lines.append('    %s = {' % name)
        for g in manifest['grounds']:
            item = s['items'][g]
            ways = [('north', item['server'])] + [(w, item['turned'][w]['server']) for w in TURNS
                                                  if w in item.get('turned', {})]
            lines.append('        %s = {%s},' % (g, ', '.join('%s = %d' % w for w in ways)))
        lines.append('    },')
    lines += ['}', '', '-- Pokemon with prints of their own; every other Pokemon leaves the "pokemon" set.',
              'FOOTPRINT_SPECIES = {']
    for name, s in manifest['sets'].items():
        lines += ['    ["%s"] = "%s",' % (species, name) for species in s['species']]
    lines += ['}', '']
    open(LUA, 'w').write('\n'.join(lines))


def add_items(templates, label):
    """A copy of each template trace with its prints layer on a free sprite, appended to data.dat, items.otb
    and items.xml. Returns one {'server', 'client', 'sprite'} per template, in order."""
    dat = open(DAT, 'rb').read()
    otb = open(OTB, 'rb').read()
    xml = open(XML).read()
    used = used_sprites(dat)
    free = (s for s in range(1, max(used)) if s not in used)
    otb_ids = otb_items(otb)
    server_id = max(otb_ids) + 1
    if 30000 < server_id < 30100:
        server_id = 30100
    signature, count, outfits, effects, missiles, offsets, items_end = dat_tool.parse(dat)
    new_things, xml_add, entries = [], [], []
    for template in templates:
        start, end = offsets[otb_ids[template][2]]
        at, layers = sprite_span(dat, start)
        if layers != 2:
            sys.exit('trace %d has no prints layer' % template)
        thing = bytearray(dat[start:end])
        sprite = next(free)
        ids = list(struct.unpack_from('<%dI' % ((end - at) // 4), dat, at))
        ids = [sprite if k % 2 else s for k, s in enumerate(ids)]
        struct.pack_into('<%dI' % len(ids), thing, at - start, *ids)
        new_things.append(bytes(thing))
        client_id = count + len(new_things)
        otb = add_otb_item(otb, template, server_id, client_id)
        xml_add.append(re.sub(r'id="%d"' % template, 'id="%d"' % server_id, xml_block(xml, template), 1))
        entries.append({'server': server_id, 'client': client_id, 'sprite': sprite})
        server_id += 1

    dat = (struct.pack('<IHHHH', signature, count + len(new_things), outfits, effects, missiles)
           + dat[12:items_end] + b''.join(new_things) + dat[items_end:])
    dat_tool.parse(dat)
    otb_items(otb)
    xml = xml.replace('</items>', '\t<!-- %s -->\n%s</items>' % (label, ''.join(xml_add)))
    open(DAT, 'wb').write(dat)
    open(OTB, 'wb').write(otb)
    open(XML, 'w').write(xml)
    return entries


def turn(manifest):
    """The east, south and west items of every set and ground that has only the north one."""
    todo = [(name, ground, way) for name, s in manifest['sets'].items() for ground, item in s['items'].items()
            for way in TURNS if way not in item.get('turned', {})]
    if not todo:
        return
    entries = add_items([manifest['sets'][n]['items'][g]['server'] for n, g, _ in todo], 'turned footprints')
    for (name, ground, way), e in zip(todo, entries):
        manifest['sets'][name]['items'][ground].setdefault('turned', {})[way] = e
        print('%s %s %s: server %d, client %d, prints sprite %d' % (name, ground, way, e['server'], e['client'],
                                                                    e['sprite']))


def main():
    manifest = json.load(open(MANIFEST))
    args = sys.argv[1:]
    if args == ['--lua']:
        write_lua(manifest)
        return
    if args == ['--turn']:
        turn(manifest)
        open(MANIFEST, 'w').write(json.dumps(manifest, indent=2) + '\n')
        write_lua(manifest)
        return
    if len(args) < 2:
        sys.exit(__doc__)
    name, style, species = args[0], args[1], args[2:]
    if name in manifest['sets']:
        sys.exit('set "%s" already exists' % name)
    claimed = {sp for s in manifest['sets'].values() for sp in s['species']}
    if set(species) & claimed:
        sys.exit('already in a set: %s' % ', '.join(sorted(set(species) & claimed)))

    grounds = list(manifest['grounds'])
    entries = add_items([manifest['grounds'][g]['template'] for g in grounds], '%s footprints' % name)
    manifest['sets'][name] = {'style': style, 'species': species, 'items': dict(zip(grounds, entries))}
    turn(manifest)
    open(MANIFEST, 'w').write(json.dumps(manifest, indent=2) + '\n')
    write_lua(manifest)
    for ground, e in zip(grounds, entries):
        print('%s %s: server %d, client %d, prints sprite %d' % (name, ground, e['server'], e['client'], e['sprite']))


if __name__ == '__main__':
    main()
