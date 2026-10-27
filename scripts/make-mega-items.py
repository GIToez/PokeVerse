#!/usr/bin/env python3
"""Adds the Mega Evolution items to items.otb and items.xml (once).

    scripts/make-mega-items.py
    scripts/make-mega-items.py --unstack

Server ids 30175-30271, in the order of core/server/data/lib/ps/config/megaItems.lua, draw client
items 28818-28914 (scripts/dat-add-sprite-items.py, docs/mega-art.md). The Mega Ring copies the
running shoes (worn in the key item slot), everything else the Everstone (a held item). The
Mega Stones stack like the Everstone; the ring and its parts are unique items and don't:
--unstack clears the stackable flag on them (the add does it too). The client's data.dat must
match (scripts/dat-add-items.py --unstack 28818 28819 28820).
"""
import importlib.util
import os
import re
import struct
import subprocess
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OTB = os.path.join(ROOT, 'core/server/data/items/items.otb')
XML = os.path.join(ROOT, 'core/server/data/items/items.xml')
CONFIG = os.path.join(ROOT, 'core/server/data/lib/ps/config/megaItems.lua')
FIRST_SERVER, FIRST_CLIENT, COUNT = 30175, 28818, 97
RING_ITEMS = 3
EVERSTONE, RUNNING_SHOES = 30138, 18754
FLAG_STACKABLE = 1 << 7


def article(name):
    return 'an' if name[0].lower() in 'aeiou' else 'a'


def unstack():
    spec = importlib.util.spec_from_file_location('otb_add_item', os.path.join(ROOT, 'scripts/otb-add-item.py'))
    otb = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(otb)
    data = open(OTB, 'rb').read()
    _, _, children, _ = otb.read_node(data, 4)
    out, last, changed = [], 0, 0
    for start, end in children:
        node_type, props, _, _ = otb.read_node(data, start)
        flags, attrs = otb.item_attrs(props)
        server_id = next(struct.unpack('<H', v)[0] for a, v in attrs if a == otb.ATTR_SERVERID)
        if not FIRST_SERVER <= server_id < FIRST_SERVER + RING_ITEMS:
            continue
        value = struct.unpack('<I', flags)[0]
        if not value & FLAG_STACKABLE:
            continue
        props = struct.pack('<I', value & ~FLAG_STACKABLE) + props[4:]
        out += [data[last:start], bytes([otb.START, node_type]) + otb.escape(props) + bytes([otb.END])]
        last = end
        changed += 1
    out.append(data[last:])
    open(OTB, 'wb').write(b''.join(out))
    print('made %d items not stackable' % changed)


def main():
    if sys.argv[1:] == ['--unstack']:
        unstack()
        return
    stones = re.findall(r'\{ "([^"]+)", "([^"]+)", "([^"]+)" \}', open(CONFIG).read())
    items = [
        ('empty mega ring', 'A Mega Ring without its Key Stone. Use the Key Stone on it (or it on the Key Stone) '
                            'to complete the ring.', None),
        ('key stone', 'A stone filled with a mysterious power. Use it on an empty Mega Ring (or the ring on it) '
                      'to complete the ring.', None),
        ('mega ring', 'Worn in the key item slot, it lets a Pokemon holding its Mega Stone Mega Evolve.', 'ring'),
    ]
    for name, pokemon, form in stones:
        if form.startswith('Primal'):
            text = 'An orb said to hold an ancient power. Held by %s, it lets it undergo Primal Reversion.' % pokemon
        else:
            text = 'One of the mysterious Mega Stones. Held by %s, it lets it Mega Evolve into %s.' % (pokemon, form)
        items.append((name.lower(), text, None))
    if len(items) != COUNT:
        sys.exit('expected %d items, got %d' % (COUNT, len(items)))

    xml = open(XML).read()
    if 'id="%d"' % FIRST_SERVER in xml:
        sys.exit('the Mega items are in items.xml already')
    entries = []
    for i, (name, text, slot) in enumerate(items):
        server_id, client_id = FIRST_SERVER + i, FIRST_CLIENT + i
        template = RUNNING_SHOES if slot else EVERSTONE
        subprocess.run([sys.executable, os.path.join(ROOT, 'scripts/otb-add-item.py'), OTB,
                        str(template), str(server_id), str(client_id)], check=True, stdout=subprocess.DEVNULL)
        lines = ['\t<item id="%d" article="%s" name="%s">' % (server_id, article(name), name)]
        if slot:
            lines.append('\t\t<attribute key="slotType" value="%s" />' % slot)
        lines.append('\t\t<attribute key="description" value="%s" />' % text)
        lines.append('\t</item>')
        entries.append('\n'.join(lines))
    xml = xml.replace('</items>', '\n'.join(entries) + '\n</items>')
    open(XML, 'w').write(xml)
    unstack()
    print('added items %d-%d' % (FIRST_SERVER, FIRST_SERVER + len(items) - 1))


if __name__ == '__main__':
    main()
