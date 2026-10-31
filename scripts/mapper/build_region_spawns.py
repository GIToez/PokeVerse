#!/usr/bin/env python3
"""Redoes the wild spawns of Johto and Hoenn the way Kanto's are laid out (docs/johto-hoenn-spawns.md).

    scripts/mapper/build_region_spawns.py [--map core/server/data/world/map.otbm] [--seed 31] [--dry-run]

For each Johto and Hoenn area in AREAS it takes the area's wild spawns out of map-spawn.xml and
lays new ones over its open ground:
  * species from Bulbapedia (johto_encounters.json from HeartGold/SoulSilver, hoenn_encounters.json
    from Ruby/Sapphire/Emerald): the land table on ground, the Surf table on land by the water;
    Headbutt, Rock Smash and fishing stay with their skills
  * near a road only the table's first stages; the area's main floor (the one with the most open
    ground) has the table as it is, each floor above it is half an evolution step further on; a
    cave's floors take its Bulbapedia floor tables in order, then evolve one step per floor
  * Kanto's density by kind of area (RATES), spread evenly so no stretch is empty
  * levels stay the species' own (level="0")
Areas not in AREAS (towns, houses, gyms, Battle Tower, the Rocket Hideout, Bell Tower), Kanto, the
Orange Islands, NPCs and the STARTERS spots are left as they are.

The ground ids of the map are cached in build/region-ground.npz; delete it after a map change.
"""
import argparse
import collections
import glob
import json
import math
import os
import re
import struct
import sys

import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import pvmap  # noqa: E402
from spawn_audit import AreaIndex, REGIONS, WATER, region_of  # noqa: E402

ROOT = os.path.dirname(os.path.dirname(HERE))
DATA = os.path.join(ROOT, 'core', 'server', 'data')
SPAWN_XML = os.path.join(DATA, 'world', 'map-spawn.xml')
BOXES = {name: (x0, y0, x1, y1) for name, x0, y0, x1, y1 in REGIONS if name in ('Johto', 'Hoenn')}
ENCOUNTERS = {
    'johto': json.load(open(os.path.join(HERE, 'johto_encounters.json'))),
    'hoenn': json.load(open(os.path.join(HERE, 'hoenn_encounters.json'))),
}
MONSTER_NAMES = {'Nidoran♀': 'Nidorana', 'Nidoran♂': 'Nidorano', "Farfetch'd": 'Farfetchd'}

# Spawns per 1,000 tiles of open ground, from Kanto (docs/johto-hoenn-spawns.md); a route's floors
# above its main one are a little busier, as Kanto's terraces are.
RATES = {'route': 10.0, 'route above': 12.0, 'forest': 17.0, 'mountain': 17.0, 'cave': 20.0}
# Evolution steps per floor above an area's main floor (a half step moves half of each one's weight on)
STEP_PER_FLOOR = 0.5
# Near a road (this many tiles) only the first stages of a table spawn
ROAD_REACH = 3
# Land this close to water is the shore, where the Surf table spawns (SHORE_SHARE of the time when
# the area has a land table too)
SHORE_REACH = 2
SHORE_SHARE = 0.7
# Specials (docs/upcoming-features.md section 29), the Ruins chambers' Unown and the Route 30 Togepi
# (togepi-to-johto.py) stay out of the tables and keep their spawns
SPECIAL = {'Lapras', 'Feebas', 'Kecleon', 'Wynaut', 'Sudowoodo', 'Unown', 'Togepi'}
# Never wild in a kept mix (Steven's Beldum is a gift)
NOT_WILD = {'Beldum', 'Metang', 'Metagross'}
STARTERS = {
    'Johto': [('Chikorita', 'Bayleef', 'Meganium'), ('Cyndaquil', 'Quilava', 'Typhlosion'),
              ('Totodile', 'Croconaw', 'Feraligatr')],
    'Hoenn': [('Treecko', 'Grovyle', 'Sceptile'), ('Torchic', 'Combusken', 'Blaziken'),
              ('Mudkip', 'Marshtomp', 'Swampert')],
}
STARTER_NAMES = {n for families in STARTERS.values() for f in families for n in f}
# Share of a starter ground's spawns that are its family, and the family's split by stage
STARTER_SHARE = 0.45
STARTER_STAGES = (55.0, 32.0, 13.0)

# Ground a spawn can't go on (Pokemon stay off roofs, indoor floors, paving, stairs and rafts)
NO_SPAWN_GROUND = re.compile(r'roof|wooden|marble|tile|pavement|asphalt|iron|timber|carpet|raft|stairs|branch|'
                             r'^floor$|^water$')
ROAD_GROUND = re.compile(r'^dirt$|pavement|stone tile|sandstone tile')

J, HN = 'johto', 'hoenn'


def t(game, place, *subs):
    return [(game, place, s) for s in (subs or ('main',))]


# Every area that is redone: its kind (RATES), its Bulbapedia tables and, for caves and mountains
# with a table per floor, `floors` {z: tables} (floors past the last listed evolve one step each).
# `starter` makes it the region's ground for that starter family; `keep_mix` keeps the species the
# area has now (sea towns with no route on land near them), with `water` for their shore.
AREAS = {
    'Johto': {
        **{'Route %d' % n: {'kind': 'route', 'tables': t(J, str(n))} for n in range(26, 49)},
        'Lake of Rage': {'kind': 'route', 'tables': t(J, '43') + t(J, 'Lake of Rage')},
        'Moomoo Farm': {'kind': 'route', 'tables': t(J, '39')},
        'Olivine Cliffs': {'kind': 'route', 'tables': t(J, '48')},
        'Lake of Life': {'kind': 'route', 'tables': t(J, '35')},
        'Rage Marshes': {'kind': 'route', 'tables': t(J, '43'), 'starter': 'Totodile'},
        'Dragon Holy Land': {'kind': 'route', 'tables': t(J, '45') + t(J, "Dragon's Den")},
        'Lake Slowpoke': {'kind': 'route', 'tables': t(J, 'Slowpoke Well', 'B1F')},
        'Ruins of Alph': {'kind': 'route', 'tables': t(J, 'Ruins of Alph', 'Outside'),
                          'floors': {8: [('unown', '', '')]}},
        'National Park': {'kind': 'forest', 'tables': t(J, 'National Park')},
        'Arbor Woods': {'kind': 'forest', 'tables': t(J, 'National Park'), 'starter': 'Chikorita'},
        'Ilex Forest': {'kind': 'forest', 'tables': t(J, 'Ilex Forest')},
        'Azalea South Woods': {'kind': 'forest', 'tables': t(J, 'Ilex Forest')},
        'Ecruteak Old Forest': {'kind': 'forest', 'tables': t(J, 'Ilex Forest')},
        'Safari Zone': {'kind': 'forest', 'tables': t(J, 'Safari Zone')},
        'Mt. Silver': {'kind': 'mountain', 'tables': t(J, 'Mt. Silver'),
                       'floors': {7: t(J, 'Mt. Silver'), 6: t(J, 'Mt. Silver'),
                                  5: t(J, 'Mt. Silver Cave', 'Lower mountainside'),
                                  4: t(J, 'Mt. Silver Cave', 'Lower mountainside'),
                                  3: t(J, 'Mt. Silver Cave', 'Upper mountainside'),
                                  2: t(J, 'Mt. Silver Cave', 'Upper mountainside'),
                                  1: t(J, 'Mt. Silver Cave', 'Upper mountainside'),
                                  0: t(J, 'Mt. Silver Cave', 'Upper mountainside')}},
        'Mount Quena': {'kind': 'mountain', 'tables': t(J, 'Mt. Silver')},
        'Snowtop Mountain': {'kind': 'mountain', 'tables': t(J, 'Ice Path', '1F and B1F')},
        'Frozen North': {'kind': 'mountain', 'tables': t(J, 'Ice Path', 'B2F and B3F')},
        'Mortar Badlands': {'kind': 'mountain', 'tables': t(J, 'Mt. Mortar', '1F (entrance)'), 'starter': 'Cyndaquil'},
        'Union Cave': {'kind': 'cave', 'floors': {8: t(J, 'Union Cave', '1F, Ruins exits top rooms'),
                                                  9: t(J, 'Union Cave', 'B1F'),
                                                  10: t(J, 'Union Cave', 'B2F, Ruins exits lower rooms')}},
        'Dark Cave': {'kind': 'cave', 'tables': t(J, 'Dark Cave', 'Route 31 side', 'Route 45 side')},
        'Ice Path': {'kind': 'cave', 'tables': t(J, 'Ice Path', '1F and B1F', 'B2F and B3F')},
        'Mt. Mortar': {'kind': 'cave', 'tables': t(J, 'Mt. Mortar', '1F (entrance)', '1F (back)', '2F', 'B1F')},
        'Mt. Silver Cave': {'kind': 'cave', 'tables': t(J, 'Mt. Silver Cave', '1F', '2F', '3F')},
        'Slowpoke Well': {'kind': 'cave', 'tables': t(J, 'Slowpoke Well', 'B1F', 'B2F')},
        'Whirl Islands': {'kind': 'cave', 'tables': t(J, 'Whirl Islands', '1F-B1F', 'B2F', 'B3F')},
        'Tohjo Falls': {'kind': 'cave', 'tables': t(J, 'Tohjo Falls')},
    },
    'Hoenn': {
        **{'Route %d' % n: {'kind': 'route', 'tables': t(HN, str(n))} for n in range(101, 124)},
        'Route 119': {'kind': 'route', 'tables': t(HN, '119', 'Long grass', 'main')},
        'Route 120': {'kind': 'route', 'tables': t(HN, '120', 'Long grass', 'main')},
        # the sea routes' land (islands and beaches; their underwater floors wait for diving)
        **{'Route %d' % n: {'kind': 'route', 'tables': t(HN, str(n)), 'floors_max': 7} for n in range(124, 135)},
        'Route 130': {'kind': 'route', 'tables': t(HN, '131'), 'floors_max': 7},
        'Route 111 Desert': {'kind': 'route', 'tables': t(HN, '111')},
        'Petalburg Woods': {'kind': 'forest', 'tables': t(HN, 'Petalburg Woods')},
        'Jagged Pass': {'kind': 'mountain', 'tables': t(HN, 'Jagged Pass')},
        'Mt. Chimney': {'kind': 'mountain', 'tables': t(HN, 'Fiery Path'),
                        'floors': {7: t(HN, 'Fiery Path'), 6: t(HN, 'Fiery Path'), 5: t(HN, 'Jagged Pass'),
                                   4: t(HN, 'Jagged Pass')}},
        'Mt. Pyre': {'kind': 'mountain', 'floors': {7: t(HN, 'Mt. Pyre', 'Exterior'), 6: t(HN, 'Mt. Pyre', '1F-3F'),
                                                    5: t(HN, 'Mt. Pyre', '1F-3F'), 4: t(HN, 'Mt. Pyre', '4F-6F'),
                                                    3: t(HN, 'Mt. Pyre', '4F-6F'), 2: t(HN, 'Mt. Pyre', 'Summit'),
                                                    1: t(HN, 'Mt. Pyre', 'Summit')}},
        'Meteor Falls': {'kind': 'mountain', 'floors': {7: t(HN, 'Meteor Falls', '1F 1R'),
                                                        6: t(HN, 'Meteor Falls', '1F 2R & B1F 1R'),
                                                        5: t(HN, 'Meteor Falls', '1F 2R & B1F 1R'),
                                                        4: t(HN, 'Meteor Falls', 'B1F 2R'),
                                                        3: t(HN, 'Meteor Falls', 'B1F 2R')}},
        'Granite Cave': {'kind': 'cave', 'floors': {8: t(HN, 'Granite Cave', '1F'),
                                                    9: t(HN, 'Granite Cave', 'B1F', 'B2F')}},
        'New Mauville': {'kind': 'cave', 'tables': t(HN, 'New Mauville', 'Entrance', 'Basement')},
        'Rusturf Tunnel': {'kind': 'cave', 'tables': t(HN, 'Rusturf Tunnel')},
        'Shoal Cave': {'kind': 'cave', 'tables': t(HN, 'Shoal Cave', 'Main cave'),
                       'floors': {8: t(HN, 'Shoal Cave', 'Main cave', 'Ice room')}},
        'Sootopolis': {'kind': 'cave', 'floors_min': 8, 'tables': t(HN, 'Cave of Origin', 'Entrance', '1F-B3F')},
        'Around Sootopolis': {'kind': 'cave', 'floors_min': 8, 'tables': t(HN, 'Cave of Origin', 'Entrance', '1F-B3F')},
        # the land round the towns takes the nearest route's table
        **{'%s %s' % (pre, town): {'kind': 'route', 'tables': t(HN, route)}
           for town, route in (('Littleroot', '101'), ('Oldale', '102'), ('Petalburg', '104'),
                               ('Rustboro', '116'), ('Slateport', '110'), ('Mauville', '117'),
                               ('Verdanturf', '117'), ('Lavaridge', '112'), ('Fallarbor', '113'),
                               ('Lilycove', '121'))
           for pre in ('Around', 'Outskirts of')},
        **{'%s %s' % (pre, town): {'kind': 'route', 'tables': t(HN, '119', 'Long grass', 'main')}
           for town in ('Fortree',) for pre in ('Around', 'Outskirts of')},
        **{'%s %s' % (pre, town): {'kind': 'route', 'keep_mix': True, 'water': t(HN, route), 'floors_max': 7}
           for town, route in (('Dewford', '106'), ('Pacifidlog', '131'), ('Mossdeep', '125'),
                               ('Sootopolis', '126'))
           for pre in ('Around', 'Outskirts of') if (pre, town) != ('Around', 'Sootopolis')},
    },
}


def floor_change_items():
    """Items that move a creature to another floor or place (ladders, holes, stairs, teleports)."""
    src = open(os.path.join(DATA, 'items', 'items.xml'), encoding='latin-1').read()
    out = set()
    for m in re.finditer(r'<item (?:id="(\d+)"|fromid="(\d+)" toid="(\d+)")(.*?)</item>', src, re.S):
        if 'key="floorchange"' in m.group(4) or re.search(r'key="type" value="teleport"', m.group(4)):
            lo = int(m.group(1) or m.group(2))
            hi = int(m.group(1) or m.group(3))
            out.update(range(lo, hi + 1))
    return out


def read_ground(path, otb):
    """(x, y, z, ground id, water, floor change) for every standable tile of Johto and Hoenn, in one
    pass over the map."""
    moves = floor_change_items()
    data = open(path, 'rb').read()
    out = []
    area = None
    cur = None

    def inside(x, y):
        return any(x0 <= x <= x1 and y0 <= y <= y1 for x0, y0, x1, y1 in BOXES.values())

    for ev, t, depth, a, b, _ in pvmap.walk(data):
        if ev == 'close':
            if t in (pvmap.TILE, pvmap.HOUSETILE) and cur is not None:
                pos, ids, skip = cur
                cur = None
                if skip or not ids or any(otb.blocks(i) for i in ids):
                    continue
                out.append((pos[0], pos[1], pos[2], ids[0], any(i in WATER for i in ids), any(i in moves for i in ids)))
            continue
        if t == pvmap.TILE_AREA:
            area = struct.unpack_from('<HHB', pvmap.unescape(data[a:b]), 0)
        elif t in (pvmap.TILE, pvmap.HOUSETILE):
            p = pvmap.unescape(data[a:b])
            x, y = area[0] + p[0], area[1] + p[1]
            if not inside(x, y):
                cur = None
                continue
            _, _, house_id, flags, item = pvmap.parse_tile_props(p, t == pvmap.HOUSETILE)
            cur = ((x, y, area[2]), [item] if item is not None else [], bool(house_id) or bool(flags & 1))
        elif t == pvmap.ITEM and cur is not None and depth == 4:
            cur[1].append(struct.unpack_from('<H', pvmap.unescape(data[a:a + 4]), 0)[0])
    return np.array(out, np.int32).reshape(-1, 6)


def load_ground(map_path, cache):
    if os.path.exists(cache):
        return np.load(cache)['tiles']
    otb = pvmap.Otb(os.path.join(DATA, 'items', 'items.otb'))
    tiles = read_ground(map_path, otb)
    os.makedirs(os.path.dirname(cache), exist_ok=True)
    np.savez_compressed(cache, tiles=tiles)
    return tiles


def item_names():
    names = {}
    src = open(os.path.join(DATA, 'items', 'items.xml'), encoding='latin-1').read()
    for m in re.finditer(r'<item (?:id="(\d+)"|fromid="(\d+)" toid="(\d+)")[^>]*?name="([^"]*)"', src):
        if m.group(1):
            names[int(m.group(1))] = m.group(4)
        else:
            for i in range(int(m.group(2)), int(m.group(3)) + 1):
                names[i] = m.group(4)
    return names


def server_monsters():
    return set(re.findall(r'<monster name="([^"]+)"', open(os.path.join(DATA, 'monster', 'monsters.xml')).read()))


def load_evolutions(known):
    """Each Pokemon's next stages, from the server's Pokemon configs (as build_johto.py)."""
    out = {}
    for path in glob.glob(os.path.join(DATA, 'lib', 'ps', 'config', '_pokemon', '*.lua')):
        src = open(path, encoding='utf-8', errors='replace').read()
        m = re.match(r'\s*POKEMON\["([^"]+)"\]', src)
        start = src.find('evolutions = {')
        if not m or m.group(1) not in known or start < 0:
            continue
        depth, i = 0, start + len('evolutions = ')
        for i in range(i, len(src)):
            depth += {'{': 1, '}': -1}.get(src[i], 0)
            if depth == 0:
                break
        nexts = [n for n in re.findall(r'name = "([^"]+)"', src[start:i]) if n in known]
        if nexts:
            out[m.group(1)] = nexts
    return out


class Species:
    def __init__(self, released):
        self.released = released
        self.evolutions = load_evolutions(released)
        self.evolved_from = {n for nexts in self.evolutions.values() for n in nexts}

    def first_stage(self, name):
        return name not in self.evolved_from

    def table(self, sources, method):
        """The weights of `sources` (game, place, sub) for `method`, each source counted the same."""
        out = collections.Counter()
        for game, place, sub in sources:
            if game == 'unown':
                out['Unown'] += 1.0 if method == 'land' else 0.0
                continue
            raw = ENCOUNTERS[game].get(place, {}).get(sub, {}).get(method, {})
            raw = {MONSTER_NAMES.get(n, n): w for n, w in raw.items()}
            raw = {n: w for n, w in raw.items() if n in self.released and n not in SPECIAL and w > 0}
            total = sum(raw.values())
            for n, w in raw.items():
                out[n] += w / total
        return {n: w for n, w in out.items() if w > 0}

    def evolved(self, table, steps):
        out = collections.Counter()

        def add(name, w, s):
            nexts = self.evolutions.get(name)
            if s <= 0 or not nexts:
                out[name] += w
                return
            if s < 1:
                out[name] += w * (1 - s)
                w, s = w * s, 1
            for n in nexts:
                add(n, w / len(nexts), s - 1)

        for name, w in table.items():
            add(name, w, steps)
        return dict(out)

    def firsts(self, table):
        f = {n: w for n, w in table.items() if self.first_stage(n)}
        return f or table


def pick(rng, table):
    names = sorted(table)
    w = np.array([table[n] for n in names], float)
    return names[rng.choice(len(names), p=w / w.sum())]


def dilate(mask, r):
    out = mask.copy()
    for dy in range(-r, r + 1):
        for dx in range(-r, r + 1):
            if dx or dy:
                out |= np.roll(np.roll(mask, dy, 0), dx, 1)
    return out


def spread(rng, cells, target, taken):
    """Up to `target` of `cells` [(x, y)], spread out: a spot is skipped while another is closer than
    the spacing, which starts from the cells' own spacing at `target` and shrinks until enough fit.
    `taken` are spots already there (kept spawns) and get the new ones' spacing too."""
    if target <= 0 or not cells:
        return []
    order = [cells[i] for i in rng.permutation(len(cells))]
    chosen = []
    d = max(1.5, math.sqrt(len(cells) / float(target)) * 0.9)
    used = set(chosen)
    while len(chosen) < target and d >= 1.0:
        cell = max(1, int(d))
        grid = collections.defaultdict(list)
        for p in list(taken) + chosen:
            grid[(p[0] // cell, p[1] // cell)].append(p)
        d2 = d * d
        for p in order:
            if len(chosen) >= target:
                break
            if p in used:
                continue
            gx, gy = p[0] // cell, p[1] // cell
            r = int(math.ceil(d / cell))
            near = False
            for ix in range(gx - r, gx + r + 1):
                for iy in range(gy - r, gy + r + 1):
                    for q in grid.get((ix, iy), ()):
                        if (q[0] - p[0]) ** 2 + (q[1] - p[1]) ** 2 < d2:
                            near = True
                            break
                    if near:
                        break
                if near:
                    break
            if not near:
                chosen.append(p)
                used.add(p)
                grid[(gx, gy)].append(p)
        d *= 0.85
    return chosen


SPAWN_RE = re.compile(r'  <spawn centerx="(\d+)" centery="(\d+)" centerz="(\d+)" radius="(\d+)">\n((?:(?!<spawn |</spawn>).)*)  </spawn>\n', re.S)
ENTRY_RE = re.compile(r'    <(monster|npc) name="([^"]+)" x="(-?\d+)" y="(-?\d+)" z="(\d+)" spawntime="(\d+)" level="(\d+)"/>\n')


def read_spawn_file():
    """The file as pieces: text kept as it is (the header, empty spawns) and the spawns with entries."""
    src = open(SPAWN_XML, encoding='latin-1').read()
    pieces = []
    at = 0
    comments = [c.span() for c in re.finditer(r'<!--.*?-->', src, re.S)]
    for m in SPAWN_RE.finditer(src):
        if any(c0 <= m.start() < c1 for c0, c1 in comments) or m.start() < at:
            continue
        cx, cy, cz, radius = map(int, m.groups()[:4])
        entries = []
        for e in ENTRY_RE.finditer(m.group(5)):
            kind, name = e.group(1), e.group(2)
            x, y, z, st, lvl = map(int, e.groups()[2:])
            entries.append({'kind': kind, 'name': name, 'x': cx + x, 'y': cy + y, 'z': z, 'spawntime': st, 'level': lvl,
                            'raw': e.group(0)})
        if len(re.findall(r'<(?:monster|npc) ', m.group(5))) != len(entries):
            raise SystemExit('unexpected spawn entry near %d,%d,%d' % (cx, cy, cz))
        pieces.append(src[at:m.start()])
        pieces.append({'center': (cx, cy, cz), 'radius': radius, 'entries': entries})
        at = m.end()
    end = src.rindex('</spawns>')
    if at > end:
        raise SystemExit('map-spawn.xml ends in a way this script can not read')
    pieces.append(src[at:end])
    tail = src[end:]
    rest = re.sub(r'<!--.*?-->', '', ''.join(p for p in pieces if isinstance(p, str)), flags=re.S)
    if re.search(r'<(?:monster|npc) ', rest):
        raise SystemExit('map-spawn.xml has spawns this script can not read')
    return pieces, tail


def write_spawn_file(pieces, tail, new):
    out = []
    for p in pieces:
        if isinstance(p, str):
            out.append(p)
            continue
        if not p['entries']:
            continue
        cx, cy, cz = p['center']
        out.append('  <spawn centerx="%d" centery="%d" centerz="%d" radius="%d">\n' % (cx, cy, cz, p['radius']))
        out.extend(e['raw'] for e in p['entries'])
        out.append('  </spawn>\n')
    for name, x, y, z in sorted(new, key=lambda s: (s[3], s[2], s[1], s[0])):
        out.append('  <spawn centerx="%d" centery="%d" centerz="%d" radius="1">\n' % (x, y, z))
        out.append('    <monster name="%s" x="0" y="0" z="%d" spawntime="60" level="0"/>\n' % (name, z))
        out.append('  </spawn>\n')
    out.append(tail)
    open(SPAWN_XML, 'w', encoding='latin-1', newline='\n').write(''.join(out))


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument('--map', default=os.path.join(DATA, 'world', 'map.otbm'))
    ap.add_argument('--cache', default=os.path.join(ROOT, 'build', 'region-ground.npz'))
    ap.add_argument('--seed', type=int, default=31)
    ap.add_argument('--dry-run', action='store_true')
    ap.add_argument('--report', default=os.path.join(ROOT, 'build', 'region-spawns.json'))
    args = ap.parse_args()
    rng = np.random.default_rng(args.seed)

    tiles = load_ground(args.map, args.cache)
    names = item_names()
    pieces, tail = read_spawn_file()
    blocks = [p for p in pieces if not isinstance(p, str)]
    known = server_monsters()
    released = {e['name'] for b in blocks for e in b['entries'] if e['kind'] == 'monster'} & known
    species = Species(released)
    idx = AreaIndex()

    ground_ids = np.unique(tiles[:, 3])
    no_spawn = {int(g) for g in ground_ids if NO_SPAWN_GROUND.search(names.get(int(g), '?'))}
    road = {int(g) for g in ground_ids if ROAD_GROUND.search(names.get(int(g), '?'))}
    shallow = {int(g) for g in ground_ids if names.get(int(g)) == 'shallow water'}

    # per floor: grids of open ground, water, road and the area of each tile, over both regions
    x0 = min(b[0] for b in BOXES.values())
    y0 = min(b[1] for b in BOXES.values())
    x1 = max(b[2] for b in BOXES.values())
    y1 = max(b[3] for b in BOXES.values())
    w, h = x1 - x0 + 1, y1 - y0 + 1
    labels = idx.labels(tiles[:, :3])
    floors = {}
    for z in range(16):
        sel = tiles[:, 2] == z
        if not sel.any():
            continue
        tz, lz = tiles[sel], labels[sel]
        g = {'open': np.zeros((h, w), bool), 'water': np.zeros((h, w), bool), 'road': np.zeros((h, w), bool),
             'shallow': np.zeros((h, w), bool), 'ok': np.zeros((h, w), bool), 'area': np.zeros((h, w), np.int16)}
        xs, ys = tz[:, 0] - x0, tz[:, 1] - y0
        is_water = tz[:, 4] == 1
        g['water'][ys[is_water], xs[is_water]] = True
        land = ~is_water
        g['open'][ys[land], xs[land]] = True
        gid = tz[:, 3]
        g['road'][ys[land], xs[land]] = np.isin(gid[land], list(road))
        g['shallow'][ys[land], xs[land]] = np.isin(gid[land], list(shallow))
        g['ok'][ys[land], xs[land]] = ~np.isin(gid[land], list(no_spawn)) & (tz[land, 5] == 0)
        g['area'][ys, xs] = lz
        g['near_road'] = dilate(g['road'], ROAD_REACH)
        g['shore'] = dilate(g['water'], SHORE_REACH) | g['shallow']
        floors[z] = g

    def region_at(x, y):
        return region_of(x, y)

    # which (region, area) every existing wild spawn is in, and what goes
    redo = {(r, a) for r, areas in AREAS.items() for a in areas}
    kept_by = collections.defaultdict(list)
    removed = collections.Counter()
    mixes = collections.defaultdict(collections.Counter)
    for b in blocks:
        keep_entries = []
        for e in b['entries']:
            x, y, z = e['x'], e['y'], e['z']
            r = region_at(x, y)
            a = idx.at(x, y, z)
            spec = AREAS.get(r, {}).get(a)
            if (e['kind'] != 'monster' or e['name'] not in released or (r, a) not in redo
                    or not in_floors(spec, z) or e['level'] or e['spawntime'] not in (60, 62)):
                keep_entries.append(e)
                if (r, a) in redo:
                    kept_by[(r, a, z)].append((x, y))
                continue
            if e['name'] in SPECIAL or e['name'] in STARTER_NAMES and r == 'Hoenn':
                # the specials and Hoenn's starter grounds stay where they are
                keep_entries.append(e)
                kept_by[(r, a, z)].append((x, y))
                continue
            removed[(r, a, z)] += 1
            mixes[(r, a)][e['name']] += 1
        b['entries'] = keep_entries

    new = []
    report = []
    for r, areas in AREAS.items():
        aid = {a: idx.ids.get(a) for a in areas}
        for a, spec in sorted(areas.items()):
            if aid[a] is None:
                continue
            zs = [z for z in floors if in_floors(spec, z) and (floors[z]['area'] == aid[a]).any()]
            if not zs:
                continue
            counts = {z: int(((floors[z]['area'] == aid[a]) & floors[z]['open'] & floors[z]['ok']
                              & in_region(r, x0, y0, w, h)).sum()) for z in zs}
            base = max((z for z in zs if z <= 7), key=lambda z: counts[z], default=min(zs))
            cave_floors = sorted(z for z in zs if z > 7)
            for z in zs:
                g = floors[z]
                mask = (g['area'] == aid[a]) & g['open'] & g['ok'] & in_region(r, x0, y0, w, h)
                ys, xs = np.nonzero(mask)
                cells = [(int(x) + x0, int(y) + y0) for x, y in zip(xs, ys)]
                if len(cells) < 30:
                    continue
                kind = spec['kind']
                above = 0 if z > 7 else max(0, base - z)
                rate = RATES['route above' if kind == 'route' and above else kind]
                kept = kept_by.get((r, a, z), [])
                target = int(round(rate * len(cells) / 1000.0)) - len(kept)
                land, water = tables_for(species, spec, z, above, cave_floors, mixes[(r, a)])
                if spec.get('starter') and land:
                    land = with_starter(species, land, r, spec['starter'], above)
                if not land and not water:
                    continue
                chosen = spread(rng, cells, target, kept)
                placed = collections.Counter()
                for x, y in chosen:
                    gx, gy = x - x0, y - y0
                    shore = g['shore'][gy, gx]
                    if water and (not land or (shore and rng.random() < SHORE_SHARE)):
                        table = water
                    else:
                        table = land
                        if g['near_road'][gy, gx]:
                            table = species.firsts(table)
                    name = pick(rng, table)
                    placed[name] += 1
                    new.append((name, x, y, z))
                report.append({'region': r, 'area': a, 'z': z, 'open': len(cells), 'kept': len(kept),
                               'removed': removed[(r, a, z)], 'placed': sum(placed.values()),
                               'species': dict(placed.most_common())})

    for e in report:
        print('%-6s %-26s z%-2d open %6d kept %3d removed %4d placed %4d  %s' % (
            e['region'], e['area'], e['z'], e['open'], e['kept'], e['removed'], e['placed'],
            ', '.join('%s %d' % kv for kv in list(e['species'].items())[:6])))
    print('removed %d, placed %d' % (sum(removed.values()), len(new)), file=sys.stderr)
    os.makedirs(os.path.dirname(args.report), exist_ok=True)
    json.dump(report, open(args.report, 'w'), indent=1)
    if not args.dry_run:
        write_spawn_file(pieces, tail, new)


def in_floors(spec, z):
    if spec is None:
        return False
    return spec.get('floors_min', 0) <= z <= spec.get('floors_max', 15)


_region_masks = {}


def in_region(r, x0, y0, w, h):
    """Tiles of the grid in region `r`, with 079-weather.lua's order (Johto before Hoenn where they meet)."""
    if r not in _region_masks:
        ys, xs = np.mgrid[0:h, 0:w]
        xs, ys = xs + x0, ys + y0
        earlier = np.zeros((h, w), bool)
        for name, bx0, by0, bx1, by1 in REGIONS:
            inside = (xs >= bx0) & (xs <= bx1) & (ys >= by0) & (ys <= by1)
            _region_masks[name] = inside & ~earlier
            earlier |= inside
    return _region_masks[r]


def tables_for(species, spec, z, above, cave_floors, mix):
    """(land, water) tables of an area's floor."""
    if spec.get('keep_mix'):
        land = {n: float(c) for n, c in mix.items() if n not in STARTER_NAMES | SPECIAL | NOT_WILD}
        water = species.table(spec['water'], 'water') if spec.get('water') else {}
        return species.evolved(land, above * STEP_PER_FLOOR) if above else land, water
    floors = spec.get('floors', {})
    steps = above * STEP_PER_FLOOR
    if z in floors:
        sources, steps = floors[z], 0
    elif floors and (z > 7 or not spec.get('tables')):
        # past the listed floors: the nearest one's table, evolved for each floor further in or up
        nearest = min(floors, key=lambda f: (abs(f - z), f))
        sources = floors[nearest]
        further = (z > nearest) if z > 7 else (z < nearest)
        steps = abs(z - nearest) * (1 if z > 7 else STEP_PER_FLOOR) if further else 0
    else:
        sources = spec.get('tables', [])
        if z > 7 and cave_floors:
            steps = cave_floors.index(z)
    land = species.table(sources, 'land')
    water = species.table(sources, 'water')
    if steps:
        land = species.evolved(land, steps)
        water = species.evolved(water, steps)
    return land, water


def with_starter(species, land, region, first, above):
    family = next(f for f in STARTERS[region] if f[0] == first)
    total = sum(land.values())
    share = total * STARTER_SHARE / (1 - STARTER_SHARE)
    out = dict(land)
    fam = {n: share * s / sum(STARTER_STAGES) for n, s in zip(family, STARTER_STAGES)}
    if above:
        fam = species.evolved(fam, above * STEP_PER_FLOOR)
    for n, wgt in fam.items():
        out[n] = out.get(n, 0.0) + wgt
    return out


if __name__ == '__main__':
    main()
