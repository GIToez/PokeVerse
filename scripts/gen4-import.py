#!/usr/bin/env python3
"""Adds the Gen 4 Pokemon (scripts/data/gen4-plan.json) to the server and the clients.

    scripts/gen4-import.py <art dir>

The art dir is scripts/art/gen4_art.py's output. Run once on a clean checkout: it appends outfits
and items, so a second run adds them again.

Draws into data.dat and data.spr the walk sheets (normal and shiny) as new outfits and the faces,
Pokedex tiles, corpses, eggs and dolls as new client items; adds the server items to items.otb and
items.xml (portraits, 4 corpses, egg, doll) and writes, from the plan and PokeAPI (the plan's cache):
  config/pokemon/<name>.lua, monster/Pokemons/<name>.xml, monster/Shiny/shiny <name>.xml,
  monster/monsters.xml, pokemonsNames.lua, pokemonsNumbers.lua (POKEMON_NUMBER = 493),
  evYields.lua, generateLoot.lua, config/pokemon.lua (shiny faces, eggs), the legendary lists,
  the Pokepedia rare list, the client's gamelib/pokemon.lua and both clients' Pokedex tile ids,
and the new evolutions of the old Pokemon that need no new item (Ambipom, Magnezone, Leafeon...).
Legendaries get no shiny, no egg and no wild spawn (they come with the legendary system later).
Loot copies an old Pokemon of the same main type and stage, with the new doll and no TMs.
"""
import importlib.util
import json
import os
import re
import struct
import subprocess
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SERVER = os.path.join(ROOT, 'core', 'server', 'data')
LIB = os.path.join(SERVER, 'lib', 'ps')
CONFIG = os.path.join(LIB, 'config')
PLAN = os.path.join(ROOT, 'scripts', 'data', 'gen4-plan.json')
OTB = os.path.join(SERVER, 'items', 'items.otb')
GEN4_VERSION_GROUPS = ('diamond-pearl', 'platinum', 'heartgold-soulsilver')
FIELD_MOVES = [('cut', '"Cut"'), ('rock-smash', '"Rock Smash"'), ('headbutt', '"Headbutt"'),
               ('flash', '"Flash"'), ('strength', 'POKEMON_ABILITIES.STRENGTH'),
               ('dig', 'POKEMON_ABILITIES.DIG'), ('teleport', '"Teleport", "Blink"')]
EGG_GROUPS = {'monster': 'MONSTER', 'water1': 'WATER_1', 'bug': 'BUG', 'flying': 'FLYING',
              'ground': 'FIELD', 'fairy': 'FAIRY', 'plant': 'GRASS', 'humanshape': 'HUMAN_LIKE',
              'water3': 'WATER_3', 'mineral': 'MINERAL', 'indeterminate': 'AMORPHOUS',
              'water2': 'WATER_2', 'ditto': 'DITTO', 'dragon': 'DRAGON'}
# our constants' spellings
ABILITY_NAMES = {'SERENE_GRACE': 'SERENA_GRACE', 'LIGHTNING_ROD': 'LIGHTNINGROD',
                 'COMPOUND_EYES': 'COMPOUNDEYES', 'AIR_LOCK': 'AIR_LOOK'}
ELEMENTS = {'fighting': 'FIGHT'}
BABY_LEVEL = 25
# the old Pokemon's new evolutions whose items aren't in the game yet
NEW_ITEMS = {'SHINY_STONE', 'DUSK_STONE', 'DAWN_STONE', 'OVAL_STONE', 'ICE_STONE', 'RAZOR_CLAW',
             'RAZOR_FANG', 'ELECTIRIZER', 'MAGMARIZER', 'PROTECTOR', 'REAPER_CLOTH', 'DUBIOUS_DISC'}
RARE = ['Cranidos', 'Rampardos', 'Shieldon', 'Bastiodon', 'Gible', 'Gabite', 'Garchomp', 'Riolu',
        'Lucario', 'Spiritomb', 'Rotom', 'Happiny', 'Munchlax', 'Mantyke', 'Togekiss', 'Leafeon',
        'Glaceon', 'Porygon-Z', 'Magnezone', 'Electivire', 'Magmortar', 'Rhyperior']
# client item templates (Bagon's) and server item templates
FACE, DEX_TILE, CORPSE, CORPSE_DECAYED, EGG, DOLL = 27364, 27110, 27562, 27093, 27383, 27851
S_PORTRAIT, S_SHINY_PORTRAIT = 28520, 29418
S_CORPSE, S_CORPSE_DECAYED, S_SHINY_CORPSE, S_SHINY_CORPSE_DECAYED = 28854, 28719, 29552, 29292
S_EGG, S_DOLL = 28539, 29095


def load(path, name):
    spec = importlib.util.spec_from_file_location(name, path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


P = load(os.path.join(ROOT, 'scripts', 'gen4-plan.py'), 'gen4_plan')
OTB_TOOL = load(os.path.join(ROOT, 'scripts', 'otb-add-item.py'), 'otb_add_item')


def read(path):
    return open(path, encoding='utf-8', errors='surrogateescape', newline='').read()


def write(path, text):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    open(path, 'w', encoding='utf-8', errors='surrogateescape', newline='').write(text)


def nl(text):
    return '\r\n' if '\r\n' in text else '\n'


def insert_after(text, pattern, lines):
    """Inserts the lines after the first line matching pattern, in the file's line endings."""
    m = re.search(pattern, text, re.M)
    assert m, pattern
    end = text.index('\n', m.end()) + 1
    return text[:end] + ''.join(line + nl(text) for line in lines) + text[end:]


def insert_before(text, pattern, lines, start=0):
    m = re.compile(pattern, re.M).search(text, start)
    assert m, pattern
    begin = text.rindex('\n', 0, m.start()) + 1 if m.start() else 0
    return text[:begin] + ''.join(line + nl(text) for line in lines) + text[begin:]


def slug(name):
    return re.sub(r'[^a-z0-9-]', '', name.lower().replace(' ', '-').replace('.', ''))


def file_name(name):
    return name.lower().rstrip('.')


def article(name):
    return 'an' if name[0].lower() in 'aeiou' else 'a'


def lua_list(items):
    return '{ ' + ', '.join(items) + ' }' if items else '{}'


# --- PokeAPI ---------------------------------------------------------------------------------

API = P.Api('/tmp/pokeapi-cache')


def species(s):
    return API.get('pokemon-species/' + s)


def pokemon(s):
    sp = species(s)
    variety = next((v for v in sp['varieties'] if v['is_default']), sp['varieties'][0])
    return API.get(variety['pokemon']['url'])


def root_of(s):
    while True:
        prev = species(s)['evolves_from_species']
        if not prev:
            return s
        s = prev['name']


def description(s):
    entries = [e for e in species(s)['flavor_text_entries'] if e['language']['name'] == 'en']
    best = next((e for e in entries if e['version']['name'] == 'platinum'), entries[0])
    text = re.sub(r'\s+', ' ', best['flavor_text'].replace('\f', ' ')).strip()
    text = text.replace('POKéMON', 'POKEMON').replace('Pokémon', 'POKEMON').replace('é', 'e')
    return text.replace('"', '\\"')


def moves_by(s, method, groups=None):
    out = set()
    for m in pokemon(s)['moves']:
        for d in m['version_group_details']:
            if d['move_learn_method']['name'] == method and (groups is None or d['version_group']['name'] in groups):
                out.add(m['move']['name'])
    return out


def move_name(move_slug):
    return P.english(API.get('move/' + move_slug)['names'])


# --- our constants and old Pokemon -----------------------------------------------------------

CONSTANTS = read(os.path.join(LIB, 'others', 'constants.lua'))


def constant_block(name):
    start = CONSTANTS.index(name + ' = {')
    body = CONSTANTS[start:CONSTANTS.index('\n}', start)]
    body = re.sub(r'--\[\[.*?\]\]', '', body, flags=re.S)
    return {k: int(v) for k, v in re.findall(r'^\s*([A-Z0-9_]+) = (\d+),?', body, re.M)}


TMS = constant_block('TM_IDS')
TM_BY_KEY = {P.key(k): k for k in TMS if k != 'NONE'}
SPECIAL = constant_block('POKEMON_SPECIAL_ABILITY_IDS')
OUR_MOVES = P.our_moves()


_CONFIGS = {}


def old_config(name):
    if not _CONFIGS:
        for f in os.listdir(os.path.join(CONFIG, 'pokemon')):
            path = os.path.join(CONFIG, 'pokemon', f)
            for n in re.findall(r'^POKEMON\["([^"]+)"\] = \{', read(path), re.M):
                _CONFIGS.setdefault(n, path)
    return _CONFIGS[name], read(_CONFIGS[name])


def is_baby(s, by_slug):
    """A baby here: the plan's babies and the old Pokemon that spawn at levels 1-10 (Pichu, not Togepi)."""
    if s in by_slug:
        return by_slug[s]['baby']
    name = P.english(species(s)['names'])
    try:
        return level_range(monster_xml(name))[1] <= 1
    except FileNotFoundError:
        return False


def old_field(name, field):
    _, text = old_config(name)
    body = re.search(r'^POKEMON\["%s"\] = \{(.*?)^\}' % re.escape(name), text, re.S | re.M).group(1)
    m = re.search(r'^\s*%s = (.*?),?\r?$' % field, body, re.M)
    return m.group(1) if m else None


MONSTER_FILES = dict(re.findall(r'<monster name="([^"]+)" file="([^"]+)"/>',
                                re.sub(r'<!--.*?-->', '', read(os.path.join(SERVER, 'monster', 'monsters.xml')), flags=re.S)))


def monster_xml(name):
    if name not in MONSTER_FILES:
        raise FileNotFoundError(name)
    return read(os.path.join(SERVER, 'monster', MONSTER_FILES[name]))


def level_range(xml):
    m = re.search(r'experience="(\d+)".*?minLevel="(\d+)" maxLevel="(\d+)"', xml)
    return int(m.group(1)), int(m.group(2)), int(m.group(3))


# --- the plan --------------------------------------------------------------------------------

def stage_of(p, by_name):
    """(experience, min level, max level, doll price, kind) by stage, as in docs/future-generations.md."""
    if p['legendary']:
        return 15, 100, 100, 200, 'legendary'
    if p['baby']:
        return 5, 1, 10, 80, 'baby'
    s = slug(p['name'])
    by_slug = {slug(q['name']): q for q in by_name.values()}
    chain = []
    x = s
    while species(x)['evolves_from_species']:
        x = species(x)['evolves_from_species']['name']
        if not is_baby(x, by_slug):
            chain.append(x)
    depth, children = len(chain), bool(p['evolvesTo'])
    if depth == 0 and children:
        rule = (5, 20, 30, 80, 'first')
    elif depth == 0:
        bst = sum(p['stats'].values())
        rule = (15, 70, 80, 130, 'strong') if bst >= 480 else (10, 40, 50, 130, 'single')
    elif children or depth == 1:
        rule = (10, 40, 50, 130 if children else 150, 'middle' if children else 'final')
    else:
        rule = (15, 85, 95, 150, 'final')
    # a new evolution of an old Pokemon is stronger than it, whatever the rule says
    if p['from'] and p['from'] not in by_name:
        exp, lo, hi = level_range(monster_xml(p['from']))
        if hi >= rule[1]:
            rule = (max(rule[0], exp), min(100, lo + 10), min(100, hi + 10)) + rule[3:]
    return rule


def evolutions(p, by_name):
    out, skipped = [], []
    for child in p['evolvesTo']:
        c = by_name.get(child)
        if c is None:
            # a baby: evolves into its old Pokemon
            out.append('{ name = "%s", requiredLevel = %d }' % (child, BABY_LEVEL))
            continue
        e = c['evolve']
        if set(e['items']) & NEW_ITEMS:
            skipped.append(child)
            continue
        items = ', requiredItems = { %s }' % ', '.join('ITEMS.' + i for i in e['items']) if e['items'] else ''
        out.append('{ name = "%s", requiredLevel = %d%s }' % (child, e['level'], items))
    return out, skipped


def tms_of(s):
    names = {move_name(m) for m in moves_by(s, 'machine', GEN4_VERSION_GROUPS)}
    keys = {TM_BY_KEY[P.key(n)] for n in names if P.key(n) in TM_BY_KEY}
    return ['TM_IDS.' + k for k in sorted(keys, key=TMS.get)]


def egg_moves_of(s):
    names = {move_name(m) for m in moves_by(root_of(s), 'egg')}
    return sorted('"%s"' % OUR_MOVES[P.key(n)] for n in names if P.key(n) in OUR_MOVES)


def field_abilities(s):
    learnable = {m['move']['name'] for m in pokemon(s)['moves']}
    return [lua for move, lua in FIELD_MOVES if move in learnable]


def special_abilities(s):
    out = []
    for a in pokemon(s)['abilities']:
        if a['is_hidden']:
            continue
        k = re.sub(r'[^A-Z0-9]+', '_', P.english(API.get(a['ability']['url'])['names']).upper()).strip('_')
        k = ABILITY_NAMES.get(k, k)
        if k in SPECIAL:
            out.append('POKEMON_SPECIAL_ABILITY_IDS.' + k)
    return out


def ev_yield(s):
    order = ['hp', 'attack', 'defense', 'special-attack', 'special-defense', 'speed']
    effort = {st['stat']['name']: st['effort'] for st in pokemon(s)['stats']}
    return '{ %s }' % ', '.join(str(effort[k]) for k in order)


def sex(s):
    rate = species(s)['gender_rate']
    return {-1: 2, 0: 1, 8: 0}.get(rate)


# --- art -------------------------------------------------------------------------------------

def run(*args):
    out = subprocess.run([sys.executable] + [str(a) for a in args], capture_output=True, text=True, cwd=ROOT)
    if out.returncode:
        sys.exit(out.stdout + out.stderr)
    return out.stdout


def outfits(paths):
    out = run(os.path.join(ROOT, 'scripts', 'dat-set-outfit.py'), *[x for p in paths for x in ('new', p)])
    looks = {m.group(2): int(m.group(1)) for m in re.finditer(r'new outfit (\d+) for (\S+)\.png', out)}
    return [looks[os.path.basename(p)[:-4]] for p in paths]


def client_items(template, paths, frames=1):
    args = (['--frames', frames] if frames > 1 else []) + [template] + paths
    out = run(os.path.join(ROOT, 'scripts', 'dat-add-sprite-items.py'), *args)
    ids = {m.group(2): int(m.group(1)) for m in re.finditer(r'client item (\d+): (\S+)', out)}
    return [ids[os.path.basename(p)] for p in paths[::frames]]


class Otb:
    """Appends copies of server items, each drawing a given client item."""

    def __init__(self):
        self.data = open(OTB, 'rb').read()
        _, _, children, self.root_end = OTB_TOOL.read_node(self.data, 4)
        self.templates, self.last = {}, 0
        for start, _ in children:
            node_type, props, _, _ = OTB_TOOL.read_node(self.data, start)
            flags, attrs = OTB_TOOL.item_attrs(props)
            sid = next(struct.unpack('<H', v)[0] for a, v in attrs if a == OTB_TOOL.ATTR_SERVERID)
            self.templates[sid] = (node_type, flags, attrs)
            self.last = max(self.last, sid)
        self.nodes = []

    def add(self, template, client_id):
        self.last += 1
        if 30000 < self.last < 30100:
            sys.exit('server ids 30001-30099 are read as 1-99')
        node_type, flags, attrs = self.templates[template]
        props = bytearray(flags)
        for attr, value in attrs:
            if attr == OTB_TOOL.ATTR_SERVERID:
                value = struct.pack('<H', self.last)
            elif attr == OTB_TOOL.ATTR_CLIENTID:
                value = struct.pack('<H', client_id)
            props += bytes([attr]) + struct.pack('<H', len(value)) + value
        self.nodes.append(bytes([OTB_TOOL.START, node_type]) + OTB_TOOL.escape(bytes(props)) + bytes([OTB_TOOL.END]))
        return self.last

    def save(self):
        at = self.root_end - 1
        assert self.data[at] == OTB_TOOL.END
        open(OTB, 'wb').write(self.data[:at] + b''.join(self.nodes) + self.data[at:])


# --- writing ---------------------------------------------------------------------------------

def config_text(p, d):
    s = slug(p['name'])
    st = p['stats']
    lines = [
        'POKEMON["%s"] = {' % p['name'],
        '    pTypes = %s,' % lua_list(['ELEMENT_' + ELEMENTS.get(t, t.upper()) for t in p['types']]),
        '    dexStorage = %d,' % (10000 + p['number']),
        '    atk = %d,' % st['atk'], '    def = %d,' % st['def'],
        '    spAtk = %d,' % st['spAtk'], '    spDef = %d,' % st['spDef'],
        '    energy = 100,',
        '    chance = %d,' % p['chance'],
        '    portrait = %d,' % d['portrait'],
        '    dexPortrait = 0,',
        '    fastcallPortrait = %d,' % d['face'],
        '    catchStorage = -1,',
        '    evolutions = %s,' % lua_list(d['evolutions']),
        '    description = "%s",' % description(s),
        '    skills = %s,' % lua_list('"%s", %d' % (m, lvl) for m, lvl in p['skills']),
        '    abilities = %s,' % lua_list(field_abilities(s)),
    ]
    if p['legendary']:
        lines += ['    eggGroup = {},', '    eggId = 0,', '    eggChance = 0,']
    else:
        groups = [EGG_GROUPS[g['name']] for g in species(s)['egg_groups'] if g['name'] in EGG_GROUPS]
        lines += ['    eggGroup = %s,' % lua_list('POKEMON_EGG_GROUP_' + g for g in groups),
                  '    eggId = %d,' % d['eggId'], '    eggChance = 20,']
    lines += ['    specialAbilities = %s,' % lua_list(special_abilities(s)),
              '    learnableTms = %s,' % lua_list(tms_of(s)),
              '    eggMoves = %s' % lua_list([] if p['legendary'] else egg_moves_of(s)), '}', '']
    return '\r\n'.join(lines)


TEMPLATE_XML = read(os.path.join(SERVER, 'monster', 'Pokemons', 'bagon.xml'))
TEMPLATE_SHINY_XML = read(os.path.join(SERVER, 'monster', 'Shiny', 'shiny bagon.xml'))


def monster_text(template, name, p, d, look, corpse, loot):
    st = p['stats']
    exp, lo, hi = d['stage'][:3]
    x = template.replace('"Shiny Bagon"', '"%s"' % name).replace('"a Shiny Bagon"', '"a %s"' % name)
    # what's left of Bagon is the normal name, and the shiny's nickname
    x = x.replace('"Bagon"', '"%s"' % p['name']).replace('"a Bagon"', '"%s %s"' % (article(name), name))
    head = '<monster name="%s"' % name
    x = re.sub(r'experience="\d+" speed="\d+"', 'experience="%d" speed="%d"' % (exp, 200 + st['speed']), x, count=1)
    level = 'minLevel="%d" maxLevel="%d"' % (lo, hi)
    if d['sex'] is not None:
        level += ' sex="%d"' % d['sex']
    x = re.sub(r'minLevel="\d+" maxLevel="\d+"', level, x, count=1)
    assert head in x
    x = re.sub(r'<health now="\d+" max="\d+"/>', '<health now="%d" max="%d"/>' % (st['hp'], st['hp']), x)
    x = re.sub(r'<look type="\d+" corpse="\d+"/>', '<look type="%d" corpse="%d"/>' % (look, corpse), x)
    x = re.sub(r'<attack name="melee" interval="\d+" skill="24" attack="\d+"/>',
               '<attack name="melee" interval="%d" skill="24" attack="%d"/>' % (round(100000 / st['speed']), st['atk']), x)
    x = re.sub(r'<defenses armor="10" defense="\d+"/>', '<defenses armor="10" defense="%d"/>' % st['def'], x)
    x = x.replace('sentence="BAGON!"', 'sentence="%s!"' % p['name'].upper())
    x = re.sub(r'<loot>.*?</loot>', '<loot>%s</loot>' % loot, x, flags=re.S)
    return x


def loot_template(p, by_name, item_names):
    """An old Pokemon of the same main type and stage: its XML loot and generateLoot entry."""
    loot_lua = read(os.path.join(LIB, 'tools', 'generateLoot.lua'))
    entries = dict(re.findall(r'^    \["([^"]+)"\] = \{\s*\n(\s*profit = \d+,\s*\n\s*loots = \{.*?\n\s*\}\s*\n)    \},',
                              loot_lua, re.S | re.M))
    legendary = set(LEGENDARY_OLD)
    main = 'ELEMENT_' + ELEMENTS.get(p['types'][0], p['types'][0].upper())
    best = None
    # legendaries with no old legendary of their type copy the nearest legendary of any type
    for same_type in (True, False):
        for name, number in P_NUMBERS.items():
            if name not in entries or (name in legendary) != p['legendary']:
                continue
            try:
                types = old_field(name, 'pTypes')
                xml = monster_xml(name)
            except (KeyError, FileNotFoundError, AttributeError):
                continue
            if not types or (same_type and main not in types.split(',')[0]):
                continue
            chance = int(old_field(name, 'chance') or 0)
            score = (abs(chance - p['chance']), -number)
            if best is None or score < best[0]:
                best = (score, name, xml, entries[name])
        if best:
            break
    _, name, xml, entry = best
    return name, re.search(r'<loot>(.*?)</loot>', xml, re.S).group(1), entry


def new_loot(template, p, doll_id, item_names):
    name, xml_loot, entry = template
    old_doll = '%s doll' % name.lower()
    out = []
    for m in re.finditer(r'<item id="(\d+)"[^>]*/>', xml_loot):
        iname = item_names.get(int(m.group(1)), '')
        if iname.lower().startswith('tm '):
            continue
        if iname == old_doll:
            out.append(m.group(0).replace('id="%s"' % m.group(1), 'id="%d"' % doll_id))
        else:
            out.append(m.group(0))
    lua = []
    for line in entry.splitlines():
        if re.search(r'name = "TM ', line):
            continue
        lua.append(line.replace('"%s"' % old_doll, '"%s doll"' % p['name'].lower()))
    return ''.join(out), '\n'.join(lua), name


def main():
    if len(sys.argv) != 2:
        sys.exit(__doc__)
    art = sys.argv[1]
    plan = json.load(open(PLAN))
    by_name = {p['name']: p for p in plan}
    shinies = [p for p in plan if not p['legendary']]
    eggs = [p for p in plan if not p['from'] and not p['legendary']]
    path = lambda *a: os.path.join(art, *a)

    print('outfits...')
    looks = dict(zip([p['number'] for p in plan], outfits([path('normal', '%d.png' % p['number']) for p in plan])))
    shiny_looks = dict(zip([p['number'] for p in shinies],
                           outfits([path('shiny', '%d.png' % p['number']) for p in shinies])))
    print('client items...')
    faces = client_items(FACE, [path('faces', '%d-normal-%d.png' % (p['number'], n)) for p in plan for n in range(4)], 4)
    shiny_faces = client_items(FACE, [path('faces', '%d-shiny-%d.png' % (p['number'], n)) for p in shinies for n in range(4)], 4)
    tiles = client_items(DEX_TILE, [path('dex', '%d.png' % p['number']) for p in plan])
    corpse_art = [path('corpse', '%d-normal.png' % p['number']) for p in plan]
    shiny_corpse_art = [path('corpse', '%d-shiny.png' % p['number']) for p in shinies]
    c_fresh, c_decayed = client_items(CORPSE, corpse_art), client_items(CORPSE_DECAYED, corpse_art)
    c_shiny_fresh, c_shiny_decayed = client_items(CORPSE, shiny_corpse_art), client_items(CORPSE_DECAYED, shiny_corpse_art)
    c_eggs = client_items(EGG, [path('egg', '%d.png' % p['number']) for p in eggs])
    c_dolls = client_items(DOLL, [path('doll', '%d.png' % p['number']) for p in plan])
    assert tiles == list(range(tiles[0], tiles[0] + len(plan)))

    print('server items...')
    otb = Otb()
    first_portrait = otb.last + 1
    portrait = {p['number']: otb.add(S_PORTRAIT, c) for p, c in zip(plan, faces)}
    shiny_portrait = {p['number']: otb.add(S_SHINY_PORTRAIT, c) for p, c in zip(shinies, shiny_faces)}
    last_portrait = otb.last
    corpses, shiny_corpses = {}, {}
    for p, fresh, decayed in zip(plan, c_fresh, c_decayed):
        corpses[p['number']] = (otb.add(S_CORPSE, fresh), otb.add(S_CORPSE_DECAYED, decayed))
    for p, fresh, decayed in zip(shinies, c_shiny_fresh, c_shiny_decayed):
        shiny_corpses[p['number']] = (otb.add(S_SHINY_CORPSE, fresh), otb.add(S_SHINY_CORPSE_DECAYED, decayed))
    egg_items = {p['number']: otb.add(S_EGG, c) for p, c in zip(eggs, c_eggs)}
    dolls = {p['number']: otb.add(S_DOLL, c) for p, c in zip(plan, c_dolls)}
    otb.save()

    items_path = os.path.join(SERVER, 'items', 'items.xml')
    items_xml = read(items_path)
    item_names = {int(i): n for i, n in re.findall(r'<item id="(\d+)"[^>]*? name="([^"]*)"', items_xml)}
    xml = ['\t<!-- Gen 4 (scripts/gen4-import.py): portraits, corpses, eggs and dolls -->',
           '\t<item fromid="%d" toid="%d" article="a" name="pokemon portrait">' % (first_portrait, last_portrait),
           '\t\t<attribute key="slotType" value="legs" />', '\t</item>']

    def corpse_xml(ids, name):
        fresh, decayed = ids
        out = []
        for sid, duration, to in ((fresh, 20, decayed), (decayed, 40, 0)):
            out += ['\t<item id="%d" article="a" name="fainted %s">' % (sid, name),
                    '\t\t<attribute key="containerSize" value="10" />',
                    '\t\t<attribute key="duration" value="%d" />' % duration,
                    '\t\t<attribute key="corpseType" value="blood" />',
                    '\t\t<attribute key="decayTo" value="%d" />' % to, '\t</item>']
        return out

    # --- per Pokemon data ---
    data = {}
    old_evolutions = []
    for p in plan:
        n, name = p['number'], p['name']
        root = slug(name)
        while species(root)['evolves_from_species']:
            root = species(root)['evolves_from_species']['name']
        root_name = P.english(species(root)['names'])
        if p['legendary']:
            egg_id = 0
        elif root_name in by_name:
            egg_id = egg_items[by_name[root_name]['number']]
        else:
            egg_id = int(old_field(root_name, 'eggId') or 0)
        evo, skipped = evolutions(p, by_name)
        data[n] = {'portrait': portrait[n], 'face': faces[plan.index(p)], 'evolutions': evo, 'skipped': skipped,
                   'eggId': egg_id, 'stage': stage_of(p, by_name), 'sex': sex(slug(name))}
        if p['from'] and p['from'] not in by_name:
            e = p['evolve']
            if set(e['items']) & NEW_ITEMS:
                data[n]['skipped_from'] = True
            else:
                items = ', requiredItems = { %s }' % ', '.join('ITEMS.' + i for i in e['items']) if e['items'] else ''
                old_evolutions.append((p['from'], '{ name = "%s", requiredLevel = %d%s }' % (name, e['level'], items)))

    for p in plan:
        name = p['name']
        xml += corpse_xml(corpses[p['number']], name.lower())
        if p['number'] in shiny_corpses:
            xml += corpse_xml(shiny_corpses[p['number']], 'shiny ' + name.lower())
    for p in eggs:
        xml.append('\t<item id="%d" article="%s" name="%s egg" />' % (egg_items[p['number']], article(p['name']), p['name'].lower()))
    for p in plan:
        xml.append('\t<item id="%d" article="a" name="%s doll" sellprice="%d"/>'
                   % (dolls[p['number']], p['name'].lower(), data[p['number']]['stage'][3]))
    items_xml = insert_before(items_xml, r'^</items>', xml)
    write(items_path, items_xml)
    item_names.update({dolls[p['number']]: '%s doll' % p['name'].lower() for p in plan})

    print('configs and monsters...')
    loot_lua_entries, ev_lines = [], []
    for p in plan:
        n, name, d = p['number'], p['name'], data[p['number']]
        write(os.path.join(CONFIG, 'pokemon', file_name(name) + '.lua'), config_text(p, d))
        template = loot_template(p, by_name, item_names)
        xml_loot, lua_loot, from_name = new_loot(template, p, dolls[n], item_names)
        d['loot_from'] = from_name
        loot_lua_entries += ['    ["%s"] = {' % name] + lua_loot.splitlines() + ['    },']
        write(os.path.join(SERVER, 'monster', 'Pokemons', file_name(name) + '.xml'),
              monster_text(TEMPLATE_XML, name, p, d, looks[n], corpses[n][0], xml_loot))
        if n in shiny_looks:
            x = monster_text(TEMPLATE_SHINY_XML, 'Shiny ' + name, p, d, shiny_looks[n], shiny_corpses[n][0], xml_loot)

            write(os.path.join(SERVER, 'monster', 'Shiny', 'shiny %s.xml' % file_name(name)), x)
        ev_lines.append('    ["%s"] = %s,' % (name, ev_yield(slug(name))))

    p_ = os.path.join(SERVER, 'monster', 'monsters.xml')
    s = read(p_)
    s = insert_after(s, r'<monster name="Deoxys" file=', ['\t<monster name="%s" file="Pokemons/%s.xml"/>\t'
                                                          % (p['name'], file_name(p['name'])) for p in plan])
    s = insert_after(s, r'<!--<monster name="Shiny Deoxys"', ['\t<monster name="Shiny %s" file="Shiny/shiny %s.xml"/>\t'
                                                              % (p['name'], file_name(p['name'])) for p in shinies])
    write(p_, s)

    # names: a 4th generation list
    p_ = os.path.join(CONFIG, 'pokemonsNames.lua')
    s = read(p_)
    names = ['    "%s",' % p['name'] for p in plan]
    names[-1] = names[-1].rstrip(',')
    s = insert_before(s, r'^local SHINY = \{', ['local NORMAL_4TH = {'] + names + ['}', ''])
    m = re.search(r'^local SHINY = \{.*?\n\}', s, re.S | re.M)
    body = m.group(0)
    last = body.rstrip('}').rstrip()
    body = last + ',\n' + ''.join('    "Shiny %s",\n' % p['name'] for p in shinies).rstrip(',\n') + '\n}'
    s = s[:m.start()] + body + s[m.end():]
    s = s.replace('table_concat(NORMAL_1ST, NORMAL_2ND, NORMAL_3RD, SHINY)', 'table_concat(NORMAL_1ST, NORMAL_2ND, NORMAL_3RD, NORMAL_4TH, SHINY)')
    s = s.replace('table_concat(NORMAL_1ST, NORMAL_2ND, NORMAL_3RD)', 'table_concat(NORMAL_1ST, NORMAL_2ND, NORMAL_3RD, NORMAL_4TH)')
    s = s.replace('local NORMAL_3RD_SETTED = table.set(NORMAL_3RD)\n',
                  'local NORMAL_3RD_SETTED = table.set(NORMAL_3RD)\nlocal NORMAL_4TH_SETTED = table.set(NORMAL_4TH)\n')
    s = s.replace('    elseif (NORMAL_3RD_SETTED[name]) then\n        return 3\n',
                  '    elseif (NORMAL_3RD_SETTED[name]) then\n        return 3\n    elseif (NORMAL_4TH_SETTED[name]) then\n        return 4\n')
    assert 'NORMAL_4TH_SETTED[name]' in s
    write(p_, s)

    p_ = os.path.join(CONFIG, 'pokemonsNumbers.lua')
    s = read(p_)
    s = s.replace('POKEMON_NUMBER = 386', 'POKEMON_NUMBER = 493', 1)
    s = insert_after(s, r'^    \["Deoxys"\] = 386,', ['    ["%s"] = %d,' % (p['name'], p['number']) for p in plan])
    s = insert_after(s, r'^    \["Shiny Deoxys"\] = 386,', ['    ["Shiny %s"] = %d,' % (p['name'], p['number']) for p in shinies])
    s = insert_after(s, r'^    \[386\] = "Deoxys",', ['    [%d] = "%s",' % (p['number'], p['name']) for p in plan])
    write(p_, s)

    p_ = os.path.join(CONFIG, 'evYields.lua')
    s = read(p_)
    s = insert_after(s, r'^    \["Deoxys"\] = ', ev_lines)
    write(p_, s)

    p_ = os.path.join(LIB, 'tools', 'generateLoot.lua')
    s = read(p_)
    m = re.search(r'^    \["Deoxys"\] = \{.*?^    \},\n', s, re.S | re.M)
    s = s[:m.end()] + '\n'.join(loot_lua_entries) + '\n' + s[m.end():]
    write(p_, s)

    p_ = os.path.join(CONFIG, 'pokemon.lua')
    s = read(p_)
    lines = []
    for p in shinies:
        lines += ['POKEMONS["Shiny %s"].portrait = %d' % (p['name'], shiny_portrait[p['number']]),
                  'POKEMONS["Shiny %s"].fastcallPortrait = %d' % (p['name'], shiny_faces[shinies.index(p)]), '']
    last_face = list(re.finditer(r'^POKEMONS\["Shiny [^"]+"\]\.fastcallPortrait = \d+\r?\n', s, re.M))[-1]
    s = s[:last_face.end()] + '\n' + '\n'.join(lines) + s[last_face.end():]
    m = re.search(r'^    \[28539\] = "Bagon",.*?\n(\})', s, re.S | re.M)
    before = s[:m.start(1)].rstrip()
    if not before.endswith(','):
        before += ','
    s = before + '\n' + ''.join('    [%d] = "%s",\n' % (egg_items[p['number']], p['name']) for p in eggs) + s[m.start(1):]
    s = s.replace('        if (getPokemonGenerationByName(name) == 3) then', '        if ((getPokemonGenerationByName(name) or 0) >= 3) then')
    write(p_, s)

    # the new evolutions of the old Pokemon
    for old, evo in old_evolutions:
        path_, text = old_config(old)
        head = re.search(r'^POKEMON\["%s"\] = \{' % re.escape(old), text, re.M)
        e = nl(text)
        many = re.compile(r'^    evolutions = \{\r?\n(.*?)\r?\n    \},', re.M | re.S).search(text, head.end())
        one = re.compile(r'^    evolutions = \{(.*)\},\r?$', re.M).search(text, head.end())
        if many and (not one or many.start() <= one.start()):
            m = many
            new = '    evolutions = {' + e + m.group(1).rstrip() + ',' + e + '        ' + evo + e + '    },'
        else:
            m = one
            inner = m.group(1).strip()
            new = '    evolutions = { %s },' % (inner + ', ' + evo if inner else evo)
            new += '\r' if m.group(0).endswith('\r') else ''
        text = text[:m.start()] + new + text[m.end():]
        write(path_, text)

    legendaries = [p['name'] for p in plan if p['legendary']]
    p_ = os.path.join(LIB, 'systems', '056-discordBridge.lua')
    s = read(p_)
    s = s.replace('"Kyogre", "Groudon", "Rayquaza", "Jirachi", "Deoxys",\n',
                  '"Kyogre", "Groudon", "Rayquaza", "Jirachi", "Deoxys",\n        %s,\n'
                  % ', '.join('"%s"' % x for x in legendaries), 1)
    assert '"Arceus"' in s
    write(p_, s)
    p_ = os.path.join(LIB, 'systems', '027-citizens.lua')
    s = read(p_)
    s = s.replace('"Rayquaza", "Jirachi", "Deoxys"}', '"Rayquaza", "Jirachi", "Deoxys",\n    %s}'
                  % ', '.join('"%s"' % x for x in legendaries), 1)
    assert '"Arceus"' in s
    write(p_, s)
    p_ = os.path.join(LIB, 'systems', '069-pokepedia.lua')
    s = read(p_)
    s = s.replace('    "Relicanth" }) do', '    "Relicanth", %s }) do' % ', '.join('"%s"' % x for x in RARE), 1)
    assert '"Rhyperior"' in s
    write(p_, s)

    print('client...')
    p_ = os.path.join(ROOT, 'core', 'client-legacy', 'modules', 'gamelib', 'pokemon.lua')
    s = read(p_)
    s = insert_after(s, r'^POKEMON\[#POKEMON \+ 1\] = \{name = "Deoxys"',
                     ['POKEMON[#POKEMON + 1] = {name = "%s", iconItemId = %d}' % (p['name'], faces[i]) for i, p in enumerate(plan)])
    s = insert_after(s, r'^    \["Deoxys"\] = 386,', ['    ["%s"] = %d,' % (p['name'], p['number']) for p in plan])
    s = insert_after(s, r'^    \[386\] = "Deoxys",', ['    [%d] = "%s",' % (p['number'], p['name']) for p in plan])
    s = insert_after(s, r'^POKEMON\[#POKEMON \+ 1\] = \{name = "Shiny Kingdra"',
                     ['POKEMON[#POKEMON + 1] = {name = "Shiny %s", iconItemId = %d}' % (p['name'], shiny_faces[i])
                      for i, p in enumerate(shinies)])
    s = insert_after(s, r'^    \["Shiny Tyranitar"\] = 248,', ['    ["Shiny %s"] = %d,' % (p['name'], p['number']) for p in shinies])
    write(p_, s)
    base = tiles[0] - plan[0]['number']
    p_ = os.path.join(ROOT, 'core', 'client-legacy', 'modules', 'game_pokedex', 'pokedex.lua')
    s = read(p_)
    old = '    else\n        itemId = (27108 - 251) + id\n    end'
    assert old in s.replace('\r\n', '\n')
    new = ('    elseif (id <= 386) then\n        itemId = (27108 - 251) + id\n    else\n'
           '        itemId = (%d - 387) + id\n    end' % tiles[0])
    s = s.replace(old.replace('\n', nl(s)), new.replace('\n', nl(s)))
    write(p_, s)
    p_ = os.path.join(ROOT, 'core', 'client-redemption', 'pokeverse-modern', 'modules', 'game_pokedex', 'modern.lua')
    s = read(p_)
    old = '        return 15647 + number\n    end\n    return 26857 + number'
    assert old in s.replace('\r\n', '\n')
    new = ('        return 15647 + number\n    elseif number <= 386 then\n        return 26857 + number\n    end\n'
           '    return %d + number' % base)
    s = s.replace(old.replace('\n', nl(s)), new.replace('\n', nl(s)))
    write(p_, s)
    run(os.path.join(ROOT, 'scripts', 'make-cry-voices.py'))

    report = {p['name']: {k: v for k, v in {
        'look': looks[p['number']], 'shinyLook': shiny_looks.get(p['number']),
        'face': data[p['number']]['face'], 'dexTile': tiles[plan.index(p)],
        'levels': data[p['number']]['stage'][1:3], 'loot': data[p['number']]['loot_from'],
        'skipped': data[p['number']]['skipped'] or None, 'evolutionWaits': data[p['number']].get('skipped_from'),
    }.items() if v is not None} for p in plan}
    json.dump(report, open(os.path.join(art, 'import-report.json'), 'w'), indent=1)
    print('old evolutions:', old_evolutions)
    print('done: %d Pokemon, outfits %d-%d, server items %d-%d' % (len(plan), min(looks.values()),
          max(shiny_looks.values()), first_portrait, otb.last))


P_NUMBERS = {}
LEGENDARY_OLD = ["Articuno", "Zapdos", "Moltres", "Mewtwo", "Mew", "Raikou", "Entei", "Suicune", "Lugia",
                 "Ho-Oh", "Celebi", "Regirock", "Regice", "Registeel", "Latias", "Latios", "Kyogre",
                 "Groudon", "Rayquaza", "Jirachi", "Deoxys"]
for _n, _num in re.findall(r'^    \["([^"]+)"\] = (\d+),', read(os.path.join(CONFIG, 'pokemonsNumbers.lua')), re.M):
    if not _n.startswith('Shiny ') and int(_num) <= 386:
        P_NUMBERS[_n] = int(_num)

if __name__ == '__main__':
    main()
