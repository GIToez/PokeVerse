#!/usr/bin/env python3
"""Pulls the HeartGold/SoulSilver wild encounter tables for Johto from Bulbapedia.

    scripts/mapper/fetch_encounters.py   ->  scripts/mapper/johto_encounters.json

The result is committed, so the builder never needs the network. Each place maps area -> method
-> {pokemon: weight}, where the weight is the encounter rate averaged over morning, day and
night (and over both versions when a Pokémon is only in one of them).
"""
import json
import os
import re
import sys
import time
import urllib.parse
import urllib.request

PAGES = {
    '26': 'Kanto Route 26', '27': 'Kanto Route 27', '28': 'Kanto Route 28',
    **{str(n): 'Johto Route %d' % n for n in range(29, 47)},
    'Mt. Silver': 'Mt. Silver', 'Mt. Silver Cave': 'Mt. Silver Cave', 'Tohjo Falls': 'Tohjo Falls',
    'Union Cave': 'Union Cave', 'Dark Cave': 'Dark Cave', 'Ice Path': 'Ice Path', 'Ilex Forest': 'Ilex Forest',
    'Mt. Mortar': 'Mt. Mortar', 'Slowpoke Well': 'Slowpoke Well', 'Ruins of Alph': 'Ruins of Alph',
    'National Park': 'National Park', 'Lake of Rage': 'Lake of Rage', 'Whirl Islands': 'Whirl Islands',
    "Dragon's Den": "Dragon's Den", 'Sprout Tower': 'Sprout Tower', 'Burned Tower': 'Burned Tower',
    'Bell Tower': 'Bell Tower', 'Safari Zone': 'Johto Safari Zone', 'Olivine City': 'Olivine City',
    'Cianwood City': 'Cianwood City', 'Goldenrod City': 'Goldenrod City', 'Cherrygrove City': 'Cherrygrove City',
    'New Bark Town': 'New Bark Town', 'Violet City': 'Violet City', 'Ecruteak City': 'Ecruteak City',
}
METHODS = {'Grass': 'land', 'Cave': 'land', 'Rock Smash': 'rock smash', 'Surf': 'water', 'Headbutt': 'headbutt',
           'Fish Old': 'fishing', 'Fish Good': 'fishing', 'Fish Super': 'fishing'}
OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'johto_encounters.json')


def wikitext(title):
    q = urllib.parse.urlencode({'action': 'parse', 'page': title, 'prop': 'wikitext', 'format': 'json', 'redirects': 1})
    req = urllib.request.Request('https://bulbapedia.bulbagarden.net/w/api.php?' + q, headers={'User-Agent': 'PokeVerse-mapper'})
    return json.load(urllib.request.urlopen(req, timeout=60))['parse']['wikitext']['*']


def rate(s):
    s = s.strip().rstrip('%')
    try:
        return float(s)
    except ValueError:
        return 0.0


def parse(text):
    areas = {}
    area = 'main'
    in_gen4 = False
    for line in text.splitlines():
        h = re.match(r'^(=+)\s*(.*?)\s*\1\s*$', line)
        if h:
            title = re.sub(r"\[\[|\]\]|'''|\{\{.*?\}\}", '', h.group(2)).strip()
            if len(h.group(1)) <= 3:
                in_gen4 = title == 'Generation IV'
                area = 'main'
            elif in_gen4:
                area = title
            continue
        b = re.match(r'^\{\{[Cc]atch/div\|[^|]*\|([^}]*)\}\}', line)
        if b and in_gen4 and 'Headbutt' not in b.group(1) and b.group(1) not in ('Surfing', 'Fishing', 'Rock Smash', 'Special'):
            area = re.sub(r'<[^>]+>', ' ', b.group(1)).strip()
        m = re.match(r'^\{\{[Cc]atch/entryhs\|(.*)\}\}\s*$', line)
        if not m:
            continue
        parts = m.group(1).split('|')
        pos = [p for p in parts if '=' not in p]
        kw = dict(p.split('=', 1) for p in parts if '=' in p)
        _dex, name, hg, ss, where = pos[:5]
        method = METHODS.get(where.strip())
        if method is None:
            continue
        if 'all' in kw:
            r = rate(kw['all'])
        else:
            r = sum(rate(x) for x in pos[6:9]) / 3.0
        versions = (hg == 'yes') + (ss == 'yes')
        r *= versions / 2.0
        if r <= 0:
            continue
        table = areas.setdefault(area, {}).setdefault(method, {})
        table[name] = round(table.get(name, 0) + r, 2)
    return areas


def main():
    out = {}
    for key, title in PAGES.items():
        try:
            out[key] = parse(wikitext(title))
        except Exception as e:  # noqa: BLE001
            print('skip %s: %s' % (title, e), file=sys.stderr)
            continue
        print(key, {a: {m: len(t) for m, t in ms.items()} for a, ms in out[key].items()})
        time.sleep(0.5)
    json.dump(out, open(OUT, 'w'), indent=1, sort_keys=True, ensure_ascii=False)
    print('wrote', OUT)


if __name__ == '__main__':
    main()
