#!/usr/bin/env python3
"""Pulls the Ruby/Sapphire/Emerald wild encounter tables for Hoenn from Bulbapedia.

    scripts/mapper/fetch_hoenn_encounters.py   ->  scripts/mapper/hoenn_encounters.json

Same shape as johto_encounters.json (fetch_encounters.py): place -> area -> method ->
{pokemon: weight}, plus "levels": {pokemon: [min, max]} per area. The weight is the encounter
rate averaged over the three versions (a Pokémon in one version only counts a third). Only the
Generation III section is read. The result is committed, so nothing needs the network later.
"""
import json
import os
import re
import sys
import time

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from fetch_encounters import rate, wikitext  # noqa: E402

PAGES = {
    **{str(n): 'Hoenn Route %d' % n for n in range(101, 135)},
    'Petalburg Woods': 'Petalburg Woods', 'Rusturf Tunnel': 'Rusturf Tunnel', 'Granite Cave': 'Granite Cave',
    'Fiery Path': 'Fiery Path', 'Jagged Pass': 'Jagged Pass', 'Meteor Falls': 'Meteor Falls',
    'Mt. Pyre': 'Mt. Pyre', 'Shoal Cave': 'Shoal Cave', 'Cave of Origin': 'Cave of Origin',
    'Seafloor Cavern': 'Seafloor Cavern', 'Sky Pillar': 'Sky Pillar', 'Victory Road': 'Victory Road (Hoenn)',
    'Safari Zone': 'Hoenn Safari Zone', 'Abandoned Ship': 'Abandoned Ship', 'New Mauville': 'New Mauville',
    'Desert Underpass': 'Desert Underpass', 'Artisan Cave': 'Artisan Cave', 'Altering Cave': 'Altering Cave',
    'Mirage Island': 'Mirage Island', 'Scorched Slab': 'Scorched Slab', 'Magma Hideout': 'Magma Hideout',
    'Sealed Chamber': 'Sealed Chamber', 'Island Cave': 'Island Cave', 'Desert Ruins': 'Desert Ruins',
    'Ancient Tomb': 'Ancient Tomb', 'Southern Island': 'Southern Island', 'Faraway Island': 'Faraway Island',
    'Birth Island': 'Birth Island', 'Navel Rock': 'Navel Rock', 'Terra Cave': 'Terra Cave', 'Marine Cave': 'Marine Cave',
    'Littleroot Town': 'Littleroot Town', 'Petalburg City': 'Petalburg City', 'Dewford Town': 'Dewford Town',
    'Slateport City': 'Slateport City', 'Lilycove City': 'Lilycove City', 'Mossdeep City': 'Mossdeep City',
    'Sootopolis City': 'Sootopolis City', 'Pacifidlog Town': 'Pacifidlog Town', 'Ever Grande City': 'Ever Grande City',
    'Fortree City': 'Fortree City', 'Rustboro City': 'Rustboro City', 'Mauville City': 'Mauville City',
}
METHODS = {'Grass': 'land', 'Cave': 'land', 'Sand': 'land', 'Rock Smash': 'rock smash', 'Surf': 'water',
           'Surfing': 'water', 'Dive': 'dive', 'Seaweed': 'dive', 'Fish Old': 'fishing', 'Fish Good': 'fishing',
           'Fish Super': 'fishing', 'Fishing': 'fishing', 'Old Rod': 'fishing', 'Good Rod': 'fishing', 'Super Rod': 'fishing'}
CACHE = os.environ.get('BULBAPEDIA_CACHE', '/tmp/bulbapedia-cache')
OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'hoenn_encounters.json')


def levels(s):
    nums = [int(n) for n in re.findall(r'\d+', re.sub(r'\{\{.*?\}\}', '', s))]
    return [min(nums), max(nums)] if nums else None


def parse(text):
    """Pages with Generation sections are read in their Generation III one; pages without (most
    caves) are read whole. A "Special encounters" section goes under "special"."""
    areas = {}
    has_gens = re.search(r'^=+\s*Generation ', text, re.M) is not None
    area, in_gen3, special, gen_depth, div_method = 'main', not has_gens, False, None, None
    for line in text.splitlines():
        h = re.match(r'^(=+)\s*(.*?)\s*\1\s*$', line)
        if h:
            title = re.sub(r"\[\[|\]\]|'''|\{\{.*?\}\}", '', h.group(2)).strip()
            depth = len(h.group(1))
            div_method = None
            if title.startswith('Generation'):
                in_gen3 = title == 'Generation III'
                gen_depth = depth
                area = 'special' if special else 'main'
            elif gen_depth is None or depth < gen_depth:
                special = title.startswith('Special encounter')
                gen_depth = None
                in_gen3 = not has_gens and (title.startswith('Pokémon') or special)
                area = 'special' if special else 'main'
            elif in_gen3 and not special:
                area = title
            continue
        if not in_gen3:
            continue
        d = re.match(r'^\{\{[Cc]atch/div\|[^|]*\|(.*)\}\}\s*$', line)
        if d:
            label = re.sub(r'\{\{color2\|[^|]*\|([^}]*)\}\}', r'\1', d.group(1))
            label = re.sub(r'<[^>]+>|\{\{.*?\}\}', ' ', label).strip()
            div_method = METHODS.get(label)
            if div_method is None and not special:
                area = label
            continue
        m = re.match(r'^\{\{[Cc]atch/entry3a?\|(.*)\}\}\s*$', line)
        if not m:
            continue
        parts = m.group(1).split('|')
        pos = [p for p in parts if '=' not in p]
        if len(pos) < 8:
            continue
        _dex, name, r, s, e, where, lv, pct = pos[:8]
        where = re.sub(r'\{\{.*?\}\}|<[^>]+>', '', where).strip()
        method, key = METHODS.get(where), area
        if special:
            method, key = 'special', 'special'
        elif method is None:
            method = div_method or 'land'
            if where and where not in ('Land', 'Walking'):
                key = where
        versions = sum(v.strip() == 'yes' for v in (r, s, e))
        w = rate(re.sub(r'\{\{tt\|([^|}]*).*', r'\1', pct)) * versions / 3.0
        if w <= 0 and method != 'special':
            continue
        a = areas.setdefault(key, {})
        table = a.setdefault(method, {})
        table[name] = round(table.get(name, 0) + max(w, 0), 2)
        lvl = levels(lv)
        if lvl:
            old = a.setdefault('levels', {}).get(name)
            a['levels'][name] = [min(old[0], lvl[0]), max(old[1], lvl[1])] if old else lvl
    return areas


def cached(title):
    path = os.path.join(CACHE, re.sub(r'[^\w.-]', '_', title) + '.txt')
    if os.path.exists(path):
        return open(path, encoding='utf-8').read()
    text = wikitext(title)
    os.makedirs(CACHE, exist_ok=True)
    open(path, 'w', encoding='utf-8').write(text)
    time.sleep(0.5)
    return text


def main():
    out = {}
    for key, title in PAGES.items():
        try:
            out[key] = parse(cached(title))
        except Exception as e:  # noqa: BLE001
            print('skip %s: %s' % (title, e), file=sys.stderr)
            continue
        print(key, {a: {m: len(t) for m, t in ms.items() if m != 'levels'} for a, ms in out[key].items()})
    json.dump(out, open(OUT, 'w'), indent=1, sort_keys=True, ensure_ascii=False)
    print('wrote', OUT)


if __name__ == '__main__':
    main()
