#!/usr/bin/env python3
"""Writes game_mart/mart_items.lua: the Poke Mart's category and description for every item an NPC sells or
buys, keyed by client item id (the trade window only knows those). Run it again after changing a shop list
or an item description.

    python3 scripts/make-mart-items.py
"""
import glob
import os
import re
import sys
import xml.etree.ElementTree as ET

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(ROOT, 'scripts', 'mapper'))
import pvmap  # noqa: E402

SERVER = os.path.join(ROOT, 'core', 'server', 'data')
OUT = os.path.join(ROOT, 'core', 'client-redemption', 'pokeverse-modern', 'modules', 'game_mart', 'mart_items.lua')

FOOD = {'apple', 'brown bread', 'brown mushroom', 'burguer', 'carrot', 'coconut water', 'cup', 'egg', 'ham',
        'hot dog', 'ice cream cone', 'lemonade', 'meat', 'pizza', 'potato chip', 'sushi', 'tea'}
TOOLS = {'rope', 'flashlight', 'net', 'pick', 'hoe', 'carpenter hammer', 'watering can', 'oxygen mask',
         'field remover', 'ball seal remover', 'bed removal', 'mach bike', 'empty flask', 'toolbox',
         'empty pokemon egg incubator', 'berry pot'}
MAIL = {'parcel', 'letter', 'label'}
HELD = {'everstone', 'destiny knot'}


def category(name):
    n = name.lower()
    if n.startswith('safari'):
        return 'safari'
    if 'backpack' in n:
        return 'backpacks'
    if n.startswith('empty') and n.endswith('ball'):
        return 'balls'
    if any(w in n for w in ('potion', 'revive', 'antidote', 'elixir')):
        return 'potions'
    if 'berry' in n:
        return 'berries'
    if n in FOOD or 'churros' in n:
        return 'food'
    if n in TOOLS or 'fishing rod' in n:
        return 'tools'
    if n in MAIL:
        return 'mail'
    if n in HELD or n.startswith('power '):
        return 'held'
    if 'clothes kit' in n or n == 'lipstick':
        return 'clothes'
    return 'furniture'


def shop_entries(text, key):
    m = re.search(r'key="%s"\s+value="([^"]*)"' % key, text)
    if not m:
        return []
    out = []
    for entry in m.group(1).split(';'):
        parts = [p.strip() for p in entry.split(',')]
        if len(parts) >= 3 and parts[1].isdigit():
            out.append((parts[0], int(parts[1])))
    return out


def descriptions():
    found = {}
    for item in ET.parse(os.path.join(SERVER, 'items', 'items.xml')).getroot().iter('item'):
        ids = []
        if item.get('id'):
            ids = [int(item.get('id'))]
        elif item.get('fromid') and item.get('toid'):
            ids = range(int(item.get('fromid')), int(item.get('toid')) + 1)
        for attr in item.iter('attribute'):
            if attr.get('key') == 'description' and attr.get('value'):
                for sid in ids:
                    found[sid] = attr.get('value').strip()
    return found


def lua_string(s):
    return '"' + s.replace('\\', '\\\\').replace('"', '\\"').replace('\n', ' ') + '"'


def main():
    otb = pvmap.Otb(os.path.join(SERVER, 'items', 'items.otb'))
    texts = descriptions()
    items = {}
    for path in sorted(glob.glob(os.path.join(SERVER, 'npc', '*.xml'))):
        text = open(path, encoding='latin-1').read()
        for name, sid in shop_entries(text, 'shop_buyable'):
            cid = otb.client_id(sid)
            if cid:
                items[cid] = (category(name), texts.get(sid))
        for name, sid in shop_entries(text, 'shop_sellable'):
            cid = otb.client_id(sid)
            if cid and cid not in items:
                items[cid] = (None, texts.get(sid))
    lines = ['-- Written by scripts/make-mart-items.py from the NPC shop lists and items.xml; don\'t edit by hand.',
             '-- client item id = { c = the Buy tab category, d = the item\'s description }',
             'MART_ITEMS = {']
    for cid in sorted(items):
        cat, desc = items[cid]
        fields = []
        if cat:
            fields.append('c = %s' % lua_string(cat))
        if desc:
            fields.append('d = %s' % lua_string(desc))
        if fields:
            lines.append('    [%d] = { %s },' % (cid, ', '.join(fields)))
    lines.append('}')
    os.makedirs(os.path.dirname(OUT), exist_ok=True)
    with open(OUT, 'w') as f:
        f.write('\n'.join(lines) + '\n')
    print('%d items -> %s' % (len(items), os.path.relpath(OUT, ROOT)))


if __name__ == '__main__':
    main()
