#!/usr/bin/env python3
"""Adds the 12 Gen 4 evolution items and the evolutions that wait for them.

    scripts/gen4-evolution-items.py <icon dir>

Run once, after scripts/gen4-import.py. <icon dir> holds the pokesprite evo-item icons
(shiny-stone.png, dusk-stone.png and so on, 32x32). Writes:
  data.dat/data.spr       a still client item per icon (Deepseatooth's attributes)
  items.otb, items.xml    a server item per icon, after the last one
  config/pokemon.lua      the ITEMS constants
  config/pokemon/*.lua    the evolutions from scripts/data/gen4-plan.json (Roserade, Togekiss...),
                          Happiny's Oval Stone by day and Burmy's random pick
  monster XMLs, generateLoot.lua
                          every Gen 4 evolution drops its own item at chance 20 (as Raichu drops
                          the Thunderstone, Chansey the Oval Stone) and no other evolution item;
                          legendaries keep theirs
  the stone buyers, the Poke Trader's rare offers and the client's item names
"""
import json
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DATA = os.path.join(ROOT, 'core', 'server', 'data')
LIB = os.path.join(DATA, 'lib', 'ps')
I = __import__('importlib.util').util
spec = I.spec_from_file_location('gen4_import', os.path.join(ROOT, 'scripts', 'gen4-import.py'))
G = I.module_from_spec(spec)
spec.loader.exec_module(G)

TEMPLATE_CLIENT, TEMPLATE_SERVER = 27649, 28893  # Deepseatooth
STONE = "A stone used for making certain kinds of pokemon evolve."
OBJECT = "A peculiar object used for making certain kinds of pokemon evolve."
# constant, name, icon, stone?, loot price (generateLoot), Poke Trader minimum bid
ITEMS = [
    ('SHINY_STONE', 'Shiny Stone', 'shiny-stone', True, 25000),
    ('DUSK_STONE', 'Dusk Stone', 'dusk-stone', True, 25000),
    ('DAWN_STONE', 'Dawn Stone', 'dawn-stone', True, 25000),
    ('ICE_STONE', 'Ice Stone', 'ice-stone', True, 22500),
    ('OVAL_STONE', 'Oval Stone', 'oval-stone', True, 22500),
    ('RAZOR_CLAW', 'Razor Claw', 'razor-claw', False, 30000),
    ('RAZOR_FANG', 'Razor Fang', 'razor-fang', False, 30000),
    ('ELECTIRIZER', 'Electirizer', 'electirizer', False, 30000),
    ('MAGMARIZER', 'Magmarizer', 'magmarizer', False, 30000),
    ('PROTECTOR', 'Protector', 'protector', False, 30000),
    ('REAPER_CLOTH', 'Reaper Cloth', 'reaper-cloth', False, 30000),
    ('DUBIOUS_DISC', 'Dubious Disc', 'dubious-disc', False, 30000),
]
OLD_ITEMS = {'FIRE_STONE': 18083, 'MOON_STONE': 18084, 'SUN_STONE': 18085, 'LEAF_STONE': 18086,
             'THUNDERSTONE': 18087, 'WATER_STONE': 18088, 'UPGRADE': 18089, 'DRAGON_SCALE': 18090,
             'KINGS_ROCK': 18091, 'METAL_COAT': 18092, 'SOOTHE_BELL': 18093, 'PUNCH_MACHINE': 18094,
             'KICK_MACHINE': 18095, 'SPIN_MACHINE': 18096, 'DEEPSEASCALE': 28892, 'DEEPSEATOOTH': 28893,
             'PRISM_SCALE': 28914}
OLD_NAMES = {18083: 'Fire Stone', 18084: 'Moon Stone', 18085: 'Sun Stone', 18086: 'Leaf Stone',
             18087: 'Thunderstone', 18088: 'Water Stone', 18089: 'Up-Grade', 18090: 'Dragon Scale',
             18091: "King's Rock", 18092: 'Metal Coat', 18093: 'Soothe Bell', 18094: 'Punch Machine',
             18095: 'Kick Machine', 18096: 'Spin Machine', 28892: 'Deepseascale', 28893: 'Deepseatooth',
             28914: 'Prism Scale'}
TIMES = {'DAY': 'WORLD_LIGHT_STATE_DAY', 'NIGHT': 'WORLD_LIGHT_STATE_NIGHT'}
LOOT_CHANCE = 20


def read(path):
    return open(path, encoding='latin-1', newline='').read()


def write(path, text):
    open(path, 'w', encoding='latin-1', newline='').write(text)


def evolution_line(name, e):
    items = ', '.join('ITEMS.' + i for i in e['items'])
    time = ', requiredTime = %s' % TIMES[e['time']] if e.get('time') else ''
    return '{ name = "%s", requiredLevel = %d, requiredItems = { %s }%s }' % (name, e['level'], items, time)


def config_path(name):
    return os.path.join(LIB, 'config', 'pokemon', G.file_name(name) + '.lua')


def find_evolutions(s, parent):
    """(start, end, body, one line?) of the Pokemon's evolutions field."""
    at = s.index('POKEMON["%s"] = {' % parent)
    one = re.compile(r'^    evolutions = \{([^\r\n]*)\},\r?$', re.M).search(s, at)
    many = re.compile(r'^    evolutions = \{\r?\n(.*?)^    \},\r?$', re.M | re.S).search(s, at)
    m = min([x for x in (one, many) if x], key=lambda x: x.start())
    return m.start(), m.end(), m.group(1), m is one


def add_evolution(parent, line):
    path = config_path(parent)
    s = read(path)
    start, end, body, one = find_evolutions(s, parent)
    nl = G.nl(s)
    if one and not body.strip():
        new = '    evolutions = { %s },' % line
    elif one:
        new = '    evolutions = { %s, %s },' % (body.strip(), line)
    else:
        new = '    evolutions = {' + nl + body.rstrip().rstrip(',') + ',' + nl + '        ' + line + nl + '    },'
    write(path, s[:start] + new + s[end:])


def set_evolutions(parent, text):
    path = config_path(parent)
    s = read(path)
    start, end, _, _ = find_evolutions(s, parent)
    write(path, s[:start] + '    evolutions = %s,' % text + s[end:])


def monster_files(name):
    out = [os.path.join(DATA, 'monster', 'Pokemons', G.file_name(name) + '.xml')]
    shiny = os.path.join(DATA, 'monster', 'Shiny', 'shiny ' + G.file_name(name) + '.xml')
    return out + ([shiny] if os.path.exists(shiny) else [])


def set_loot_xml(path, drop, own):
    s = read(path)
    s = re.sub(r'<item id="(\d+)" countmax="1" chance="\d+"/>',
               lambda m: '' if int(m.group(1)) in drop and int(m.group(1)) not in own else m.group(0), s)
    have = {int(x) for x in re.findall(r'<item id="(\d+)"', s)}
    add = ''.join('<item id="%d" countmax="1" chance="%d"/>' % (i, LOOT_CHANCE) for i in own if i not in have)
    assert s.count('</loot>') == 1, path
    write(path, s.replace('</loot>', add + '</loot>'))


def set_loot_tool(s, name, drop_names, own_names):
    m = re.search(r'^    \["%s"\] = \{\r?\n.*?^    \},?\r?\n' % re.escape(name), s, re.M | re.S)
    assert m, name
    block = m.group(0)
    for n in drop_names - own_names:
        block = re.sub(r'^ +\{ name = "%s", countmax = 1, chance = \d+ \},\r?\n' % re.escape(n), '', block, flags=re.M)
    nl = G.nl(s)
    for n in own_names:
        if '"%s"' % n not in block:
            end = block.rindex('        }')
            block = block[:end] + '            { name = "%s", countmax = 1, chance = %d },' % (n, LOOT_CHANCE) + nl + block[end:]
    return s[:m.start()] + block + s[m.end():]


def main():
    if len(sys.argv) != 2:
        sys.exit(__doc__)
    icons = [os.path.join(sys.argv[1], icon + '.png') for _, _, icon, _, _ in ITEMS]
    plan = json.load(open(G.PLAN))

    print('client items...')
    client = G.client_items(TEMPLATE_CLIENT, icons)
    otb = G.Otb()
    server = [otb.add(TEMPLATE_SERVER, c) for c in client]
    otb.save()
    ids = dict(OLD_ITEMS, **{const: sid for (const, *_), sid in zip(ITEMS, server)})
    names = {**OLD_NAMES, **{sid: name for (_, name, *_), sid in zip(ITEMS, server)}}

    print('items.xml...')
    p = os.path.join(DATA, 'items', 'items.xml')
    s = read(p)
    nl = G.nl(s)
    lines = []
    for (const, name, _, stone, _), sid in zip(ITEMS, server):
        lines += ['\t<item id="%d" article="%s" name="%s" sellprice="%d">' % (sid, G.article(name), name, 35000 if stone else 150000),
                  '\t\t<attribute key="description" value="%s" />' % (STONE if stone else OBJECT),
                  '\t\t<attribute key="rareEffect" value="1" />', '\t</item>']
    end = s.rindex('</items>')
    write(p, s[:end] + nl.join(lines) + nl + s[end:])

    print('ITEMS...')
    p = os.path.join(LIB, 'config', 'pokemon.lua')
    s = read(p)
    s = G.insert_after(s, r'^    PRISM_SCALE = 28914,', ['    %s = %d,' % (const, sid) for (const, *_), sid in zip(ITEMS, server)])
    write(p, s)

    print('evolutions...')
    new = {const for const, *_ in ITEMS}
    own = {}  # Pokemon -> the evolution items it evolved with
    for x in plan:
        e = x.get('evolve')
        if not e or not e['items'] or not x['from']:
            continue
        own[x['name']] = [ids[i] for i in e['items']]
        if set(e['items']) & new:
            add_evolution(x['from'], evolution_line(x['name'], e))
    set_evolutions('Happiny', '{ { name = "Chansey", requiredLevel = %d, requiredItems = { ITEMS.OVAL_STONE }, '
                              'requiredTime = WORLD_LIGHT_STATE_DAY } }' % G.BABY_LEVEL)
    set_evolutions('Burmy', '{ { name = "Wormadam", requiredLevel = 30, random = true }, '
                            '{ name = "Mothim", requiredLevel = 30, random = true } }')
    own['Chansey'] = [ids['OVAL_STONE']]

    print('loot...')
    evo_ids = set(ids.values())
    tool = os.path.join(LIB, 'tools', 'generateLoot.lua')
    t = read(tool)
    for x in plan + [{'name': 'Chansey', 'legendary': False}]:
        if x['legendary']:
            continue
        mine = own.get(x['name'], [])
        for path in monster_files(x['name']):
            set_loot_xml(path, evo_ids, mine)
        t = set_loot_tool(t, x['name'], set(names.values()), {names[i] for i in mine})
    nl = G.nl(t)
    t = G.insert_after(t, r'^    \["Prism Scale"\] = \{ id = 28914, price = 30000 \},',
                       ['    ["%s"] = { id = %d, price = %d },' % (name, sid, price) for (_, name, _, _, price), sid in zip(ITEMS, server)])
    write(tool, t)

    print('npcs...')
    for f in os.listdir(os.path.join(DATA, 'npc')):
        p = os.path.join(DATA, 'npc', f)
        if not f.endswith('.xml'):
            continue
        s = read(p)
        if '\t\tPrism Scale, 28914\n' not in s.replace('\r\n', '\n'):
            continue
        nl = G.nl(s)
        more = ''.join(';' + nl + '\t\t%s, %d' % (name, sid) for (_, name, *_), sid in zip(ITEMS, server))
        s = s.replace('\t\tPrism Scale, 28914' + nl, '\t\tPrism Scale, 28914' + more + nl, 1)
        write(p, s)
    p = os.path.join(DATA, 'lib', 'ps', 'systems', '105-pokeTrader.lua')
    s = read(p)
    s = G.insert_after(s, r'^ +\{ itemId = 18096, count = 1, minBid = 30000 \}, -- Spin Machine',
                       ['        { itemId = %d, count = 1, minBid = %d }, -- %s' % (sid, price, name)
                        for (_, name, _, _, price), sid in zip(ITEMS, server)])
    write(p, s)

    print('client names...')
    p = os.path.join(ROOT, 'core', 'client-legacy', 'modules', 'gamelib', 'items.lua')
    s = read(p)
    s = G.insert_after(s, r'^    \[16701\] = "Spin Machine",', ['    [%d] = "%s",' % (c, name) for (_, name, *_), c in zip(ITEMS, client)])
    write(p, s)

    for (const, name, *_), sid, c in zip(ITEMS, server, client):
        print('%-12s server %d client %d' % (name, sid, c))


if __name__ == '__main__':
    main()
