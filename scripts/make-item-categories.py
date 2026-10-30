#!/usr/bin/env python3
"""Writes core/server/data/lib/ps/config/itemCategories.lua: the generated item categories.

    scripts/make-item-categories.py [--audit]

docs/concepts/side-panel (Categories for everything). The Bag, the PC stash and the GTS share these
after the hand-made ones in systems/065-itemCategories.lua, which keep any item they list. An item
is in the first category below that takes it (PRIORITY), and the list is written in rail order
(ORDER). Only items a trainer can carry (items.otb pickupable) and can get count: PokeVerse items
(ids past 11388), Pokemon loot, the Event Token Shop and anything a script hands out. --audit prints
what is still in no category. Run it again after adding items.
"""
import glob
import importlib.util
import os
import re
import struct
import sys
import xml.etree.ElementTree as ET

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DATA = os.path.join(ROOT, 'core/server/data')
OUT = os.path.join(DATA, 'lib/ps/config/itemCategories.lua')
HAND_MADE = os.path.join(DATA, 'lib/ps/systems/065-itemCategories.lua')

FIRST_POKEVERSE_ID = 11388  # the ids before are Tibia's
FLAG_PICKUPABLE = 1 << 5
NOT_KEY_ITEMS = {10502, 10510}  # wedding rings
KEY_ITEMS = [12292, 12293, 12294, 10223,  # fishing rods
             12280, 18623, 23956, 23463,  # badge cases, coin case, doll case
             30175, 30176]  # empty Mega Ring, Key Stone
EVENT_TOKENS = [14461, 27935, 14632, 25270, 24549, 29132, 14438, 14439, 14440, 14441, 14442]
# the interface's own pictures, not things a trainer holds
NOT_ITEMS = re.compile(r'portrait|unregistered pokemon|^next page$|^previous page$|\bicon\b|empty pokemon slot|'
                       r'^pokemon team$')


def words(*names):
    return re.compile(r'\b(' + '|'.join(names) + r')\b')


# name rules; an item a rule doesn't take falls through to the next
RULES = {
    'Key Items': words('badge slot', 'badge', 'pokedex', 'dex', 'radar', 'teletransporter'),
    'Quest Items': re.compile(r"\w's |\b(letter|diary|key|card|parchment|message|list|note|notebook|book|recipe|"
                              r"invitation|document|map|newspaper|laboratory|package|extraction|secret file|rune|"
                              r"gs ball|hanzo hasashi|ernest upper|articuno feather|zapdos feather|moltres feather|"
                              r"old amber|register machine|miniature house)\b"),
    'Poke Balls': re.compile(r'^empty .*\bballs?$|^(soul|coloured|heavy torn) ball$|master ball prototype'),
    'Seals': re.compile(r'\bseal( [a-g])?$|\bseal box\b|^(twinkle|liquid|burst) seal'),
    'Eggs & Fossils': re.compile(r'(?<!coloured )\begg$|fossil'),
    'Outfits': words('costume', 'clothes', r'addon #\d', 'hat', 'cap', 'mask', 'cape', 'scarf', 'kimono', 'headband',
                     'helmet', 'bandana', 'beret', 'turban', 'crown', 'tiara', 'halo', 'makeup', 'glasses', 'band',
                     'stripes?', 'dress', 'suit', 'batsuit', 'armor', 'jacket', 'apron', 'boots', 'cloak', 'saddle',
                     'collar', 'nose', 'beard', 'headdress', 'tattoo', 'shoulder', 'bow', 'ribbon', 'disguise',
                     'ninja pack', 'pirate pack', 'mummy pack', 'metal pack', 'metalic pack', 'rastafari', 'eye patch',
                     'lipstick', 'life jacket', 'shower cap', 'pumpkinhead', 'squad jacket', 'champion belt',
                     'eyeglasses', 'postman bag', 'traveler bag', 'backpack'),
    'Boxes': words('treasure chest', 'surprise box', 'surprise bag', 'present', 'present bag', 'pokemon box',
                   'piggy bank', 'parcel', 'crate', 'box', 'chest'),
    'Boosts & Tickets': words('ticket', 'boost', 'booster', 'spirit tonic', 'mastery stone', 'stone of knowledge',
                              'egg move capsule', 'pp max', 'restore stone', 'rare candy', 'resynthesizer',
                              'diablerie', 'gallantry', 'impetus', 'momentum', 'patronage', 'pulse', 'resistor',
                              'sense', 'vigilance'),
    'Medicine': words('potion', 'medicine'),
    'Berry Seeds': words('berry tree', 'seed'),
    'Tools': words('shovel', 'pick', 'rope', 'saw', 'wrench', 'axe', 'toolbox', 'net', 'scope', 'telescope', 'camera',
                   'tv camera', 'flute', 'scouter', 'wand', 'flat iron', 'fork', 'cleaver', 'watering can',
                   'waterhose', 'lantern', 'torch', 'microphone', 'player', 'drum', 'trumpet', 'target marker',
                   'hard disk', 'old radio', 'trap', 'bait', 'slingshot', 'small stone', 'snowball',
                   'teleporter', 'time watch', 'compass', 'remover', 'incubator', 'sleep device', 'penknife',
                   'broom', 'pipe', 'pokedrum'),
    'Food': words('cakes?', 'cookie', 'fruit', 'burger', 'bread', 'ice cream', 'lemonade', 'tea', 'honey', 'candy',
                  'chocolate', 'onigiri', 'block', 'grapes?', 'mango', 'banana', 'apple', 'lunch pack', 'winterberries',
                  'dough', 'flour', 'potato', 'meat', 'ham', 'fish', 'pie', 'juice', 'milk', 'water drink', 'gingerbread',
                  'candy cane', 'pizza', 'sandwich', 'soup', 'sushi', 'egg roll', 'hot dog', 'coconut water',
                  'beer', 'baby bottle', 'jujube', 'cup'),
    'Valuables': words('diamond', 'pearl', 'ruby', 'emerald', 'topaz', 'sapphire', 'amethyst', 'ore', 'goblet',
                       'bracelets?', 'necklace', 'amulet', 'pendant', 'nugget', 'crystal', 'asteroid fragment',
                       'stone fragment', 'orb', 'core', 'jewel', 'gold', 'silver', 'trophy', 'medal', 'golden bug',
                       'great golden bug', 'poke coin', 'cash bag'),
    'Materials': words('wood', 'boards', 'metal bar', 'esmeril', 'motor', 'transformer', 'gear', 'charcoal', 'shell',
                       'pollen', 'weed', 'spikes', 'jaw', '(?<!razor )claw', '(?<!reaper )cloth', 'tail', 'stick', 'leaves', 'oil', 'flask',
                       'bottle', 'essence', 'venom', 'ice cube', 'nail', 'element', 'weaver', 'sack', 'mushroom',
                       'deepsoul stone', 'yolk stone'),
    'Dolls & Decor': re.compile(r'\w kit$|' + words(
                           'doll', 'dolls', 'statue', 'lamp', 'curtain', 'tapestry', 'chair', 'table', 'carpet', 'rug',
                           'figure', 'figurine', 'plush', 'poster', 'painting', 'picture', 'vase', 'clock', 'cushion',
                           'sofa', 'couch', 'bed', 'shelf', 'bookcase', 'pillow', 'ornament', 'wreath', 'garland',
                           'decoration', 'stand', 'freezer', 'computer', 'flower kit', 'tree kit', 'showcase',
                           'furniture', 'teddy', 'bear', 'toy', 'balloon', 'model ship', 'mirror', 'flag', 'candle',
                           'candelabrum', 'candlestick', 'rose', 'flower', 'plant', 'pot', 'fireworks rocket',
                           'habitat', 'dice', 'cortain', 'flatwares', 'pillar').pattern),
    'Event': re.compile(r'easter|chocoegg|coloured egg|paint ticket|\btoken\b|halloween|christmas|pumpkin|santa|'
                        r'anniversary|grinch|suramoon'),
}
OUTFIT_KIT = re.compile(r' kit \d+$')
# rail order; Pokemon, Bags and Money come from the ball table, items.xml and the coin values
ORDER = ['Pokemon', 'Eggs & Fossils', 'Key Items', 'Quest Items', 'Tools', 'Outfits', 'Bags', 'Boxes', 'Seals',
         'Boosts & Tickets', 'Food', 'Valuables', 'Materials', 'Money', 'Dolls & Decor', 'Event', 'Drops']
# what these rules find joins the hand-made category of that name
MORE = ['Poke Balls', 'Medicine', 'Berry Seeds']
PRIORITY = ['Key Items', 'Pokemon', 'Event tokens', 'Money', 'Bags', 'Quest Items', 'Poke Balls', 'Seals',
            'Eggs & Fossils', 'Outfits', 'Boxes', 'Boosts & Tickets', 'Medicine', 'Berry Seeds', 'Tools', 'Food',
            'Valuables', 'Materials', 'Dolls & Decor', 'Event', 'Drops']
# a representative item for each category's rail icon; the first item when there is none
ICONS = {'Pokemon': 12159, 'Key Items': 30177, 'Dolls & Decor': 19088, 'Event': 14461, 'Drops': 12230,
         'Bags': 12282, 'Money': 2152}
# what a script hands an item out with
GIVEN = [r'AddItem\w*\(\s*[\w.]+\s*,\s*(\d{4,5})',
         r'\b(?:itemid|itemId|item_id|itemID|item|id|reward|rewardId|prize)\s*=\s*(\d{4,5})\b',
         r'"(?:[^",]+),(\d{4,5}),\d+', r'\{\s*(\d{4,5})\s*,\s*\d+\s*\}', r'items\s*=\s*\{([\d,\s]+)\}']


def item_table():
    """id -> (name, attributes) from items.xml."""
    items = {}
    for item in ET.parse(os.path.join(DATA, 'items/items.xml')).getroot():
        name = (item.get('name') or '').lower()
        attrs = {a.get('key', '').lower(): a.get('value') for a in item.findall('attribute')}
        if item.get('id'):
            ids = [int(item.get('id'))]
        elif item.get('fromid'):
            ids = range(int(item.get('fromid')), int(item.get('toid')) + 1)
        else:
            continue
        for i in ids:
            items[i] = (name, attrs)
    return items


def pickupable_ids():
    """Server ids items.otb lets a trainer carry."""
    spec = importlib.util.spec_from_file_location('otb_add_item', os.path.join(ROOT, 'scripts/otb-add-item.py'))
    otb = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(otb)
    data = open(os.path.join(DATA, 'items/items.otb'), 'rb').read()
    _, _, children, _ = otb.read_node(data, 4)
    ids = set()
    for start, _ in children:
        _, props, _, _ = otb.read_node(data, start)
        flags, attrs = otb.item_attrs(props)
        if struct.unpack('<I', flags)[0] & FLAG_PICKUPABLE:
            ids.update(struct.unpack('<H', v)[0] for a, v in attrs if a == otb.ATTR_SERVERID)
    return ids


def loot_items(items):
    by_name = {}
    for i, (name, _) in items.items():
        by_name.setdefault(name, i)
    found = set()
    for path in glob.glob(os.path.join(DATA, 'monster/**/*.xml'), recursive=True):
        text = open(path, encoding='latin-1').read()
        start = text.find('<loot')
        if start < 0:
            continue
        for kind, value in re.findall(r'<item (id|name)="([^"]+)"', text[start:]):
            i = int(value) if kind == 'id' else by_name.get(value.lower())
            if i:
                found.add(i)
    return found


def event_shop_items():
    text = open(os.path.join(DATA, 'lib/ps/systems/094-eventShop.lua')).read()
    return {int(v) for v in re.findall(r'itemId = (\d+)', text)}


def given_items():
    found = set()
    for path in glob.glob(os.path.join(DATA, '**/*'), recursive=True):
        if (not os.path.isfile(path) or not path.endswith(('.lua', '.xml')) or path == OUT
                or any(part in path for part in ('/monster/', '/items/', '/world/'))):
            continue
        text = open(path, encoding='latin-1').read()
        for pattern in GIVEN:
            for group in re.findall(pattern, text):
                found.update(int(x) for x in re.findall(r'\d{4,5}', group))
    return found


def ball_items():
    """The ids of a ball holding a Pokemon (config/balls.lua: charged, discharged, inUse)."""
    text = open(os.path.join(DATA, 'lib/ps/config/balls.lua')).read()
    return {int(v) for v in re.findall(r'\b(?:charged|discharged|inUse) = (\d+)', text)}


def mega_stone_range():
    text = open(os.path.join(DATA, 'lib/ps/config/megaItems.lua')).read()
    first = int(re.search(r'MEGA_FIRST_STONE_ID = (\d+)', text).group(1))
    stones = text[text.index('local STONES = {'):text.index('MEGA_FIRST_STONE_ID =')]
    return first, first + len(re.findall(r'\{ "[^"]+", "[^"]+", "[^"]+" \}', stones)) - 1


def hand_made_ids():
    """Every id the hand-made categories list (their range() and plain numbers)."""
    text = open(HAND_MADE).read()
    text = text[text.index('local LIST = {'):text.index('local NOT_TRADED')]
    first, last = mega_stone_range()
    text = text.replace('MEGA_FIRST_STONE_ID', str(first)).replace('MEGA_LAST_STONE_ID', str(last))
    ids = set()
    for first, last in re.findall(r'range\((\d+), (\d+)', text):
        ids.update(range(int(first), int(last) + 1))
    text = re.sub(r'range\([^)]*\)', '', text)
    ids.update(int(v) for v in re.findall(r'\b(\d{4,5})\b', text))
    return ids


def main():
    items = item_table()
    carried = pickupable_ids()
    loot = loot_items(items)
    shop = event_shop_items()
    obtainable = loot | shop | given_items()
    taken = hand_made_ids()
    candidates = sorted(i for i, (name, _) in items.items()
                        if name and i in carried and i not in taken and not NOT_ITEMS.search(name)
                        and (i > FIRST_POKEVERSE_ID or i in obtainable or i in KEY_ITEMS))

    def name(i):
        return items[i][0]

    lists = {}
    for category in PRIORITY:
        free = [i for i in candidates if i not in taken]
        if category == 'Key Items':
            ids = [i for i in free if (items[i][1].get('slottype') == 'ring' and i > FIRST_POKEVERSE_ID
                                       and i not in NOT_KEY_ITEMS) or i in KEY_ITEMS or RULES[category].search(name(i))]
        elif category == 'Pokemon':
            ids = [i for i in free if i in ball_items() or re.search(r'\b(charged|discharged)\b.*\bball\b', name(i))]
        elif category == 'Event tokens':
            ids = [i for i in free if i in EVENT_TOKENS]
            category = 'Event'
        elif category == 'Money':
            ids = [i for i in free if items[i][1].get('worth')]
        elif category == 'Bags':
            ids = [i for i in free if items[i][1].get('containersize')]
        elif category == 'Dolls & Decor':
            ids = [i for i in free if (i > FIRST_POKEVERSE_ID or i in shop or i in obtainable)
                   and RULES[category].search(name(i)) and not OUTFIT_KIT.search(name(i))]
        elif category == 'Event':
            ids = [i for i in free if i in shop or RULES[category].search(name(i))]
        elif category == 'Drops':
            ids = [i for i in free if i in loot]
        elif category == 'Tools':
            ids = [i for i in free if RULES[category].search(name(i)) or name(i) in ('stone', 'kit')]
        else:
            ids = [i for i in free if RULES[category].search(name(i))]
        lists.setdefault(category, []).extend(ids)
        taken.update(ids)

    if '--audit' in sys.argv:
        left = [i for i in candidates if i not in taken]
        print('%d items in no category:' % len(left))
        for i in left:
            print('  %d %s' % (i, name(i)))
        return

    lines = ['-- Generated by scripts/make-item-categories.py: the item categories after the hand-made ones',
             '-- (server ids), in rail order. An item a hand-made category lists stays in it (ItemCategories,',
             '-- systems/065-itemCategories.lua).', '', 'ITEM_CATEGORIES_EXTRA = {']
    for category in ORDER:
        ids = sorted(lists.get(category, []))
        icon = ICONS.get(category, ids[0] if ids else 0)
        lines.append('    { name = "%s", icon = %d, items = {' % (category, icon))
        for row in range(0, len(ids), 16):
            lines.append('        ' + ', '.join(str(i) for i in ids[row:row + 16]) + ',')
        lines.append('    } },')
    lines += ['}', '', '-- found by the rules, added to the hand-made category of that name', 'ITEM_CATEGORIES_MORE = {']
    for category in MORE:
        ids = sorted(lists.get(category, []))
        lines.append('    ["%s"] = {' % category)
        for row in range(0, len(ids), 16):
            lines.append('        ' + ', '.join(str(i) for i in ids[row:row + 16]) + ',')
        lines.append('    },')
    lines.append('}')
    open(OUT, 'w').write('\n'.join(lines) + '\n')
    print(', '.join('%s %d' % (category, len(lists.get(category, []))) for category in ORDER + MORE))
    print('%d left for Other' % len([i for i in candidates if i not in taken]))


if __name__ == '__main__':
    main()
