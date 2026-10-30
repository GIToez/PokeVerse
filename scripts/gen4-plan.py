#!/usr/bin/env python3
"""Gen 4 plan: base stats from PokeAPI (the same numbers as Bulbapedia), with our own evolution
levels, catch chances and move lists, made by the rules in docs/gen4-levels-and-moves.md.

Writes docs/gen4-levels-and-moves.md (the list to check) and scripts/data/gen4-plan.json (what
the import reads). Only moves the server already has are used; missing ones are listed.

Usage: scripts/gen4-plan.py [--cache DIR]
"""
import argparse, glob, json, os, re, urllib.request
from collections import defaultdict

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
CONFIG = os.path.join(ROOT, 'core/server/data/lib/ps/config')
API = 'https://pokeapi.co/api/v2/'
GEN4 = range(387, 494)
VERSION_GROUPS = ['scarlet-violet', 'sword-shield', 'ultra-sun-ultra-moon', 'sun-moon',
                  'omega-ruby-alpha-sapphire', 'x-y', 'black-2-white-2', 'platinum']
# Pseudo-legendary lines: a slower curve, like Larvitar and Dratini.
PSEUDO = {'gible'}
STARTERS = {'turtwig', 'chimchar', 'piplup'}
# Babies in the games that are a normal first form here (Lucario shouldn't evolve at 25).
NOT_BABY = {'riolu'}
NEW_ITEMS = {
    'shiny-stone': 'SHINY_STONE', 'dusk-stone': 'DUSK_STONE', 'dawn-stone': 'DAWN_STONE',
    'oval-stone': 'OVAL_STONE', 'ice-stone': 'ICE_STONE', 'razor-claw': 'RAZOR_CLAW',
    'razor-fang': 'RAZOR_FANG', 'electirizer': 'ELECTIRIZER', 'magmarizer': 'MAGMARIZER',
    'protector': 'PROTECTOR', 'reaper-cloth': 'REAPER_CLOTH', 'dubious-disc': 'DUBIOUS_DISC',
}
OLD_ITEMS = {'thunder-stone': 'THUNDERSTONE', 'leaf-stone': 'LEAF_STONE', 'water-stone': 'WATER_STONE',
             'fire-stone': 'FIRE_STONE', 'moon-stone': 'MOON_STONE', 'sun-stone': 'SUN_STONE'}
# Evolutions by place in the games; newer games use these stones instead.
PLACE_ITEMS = {'magnezone': 'thunder-stone', 'probopass': 'thunder-stone', 'leafeon': 'leaf-stone',
               'glaceon': 'ice-stone'}

key = lambda s: re.sub(r'[^a-z0-9]', '', s.lower())


class Api:
    def __init__(self, cache):
        self.cache = cache
        os.makedirs(cache, exist_ok=True)

    def get(self, url):
        if not url.startswith('http'):
            url = API + url
        fn = os.path.join(self.cache, url.replace(API, '').strip('/').replace('/', '_') + '.json')
        if os.path.exists(fn):
            return json.load(open(fn))
        req = urllib.request.Request(url, headers={'User-Agent': 'pokeverse-gen4-plan'})
        data = json.load(urllib.request.urlopen(req, timeout=60))
        tmp = fn + '.tmp'
        json.dump(data, open(tmp, 'w'))
        os.replace(tmp, fn)
        return data


def english(entries, field='name'):
    return next(e[field] for e in entries if e['language']['name'] == 'en')


def our_pokemon():
    """Name to (skills, evolutions, chance) for every Pokemon in the server config."""
    out = {}
    for f in glob.glob(os.path.join(CONFIG, 'pokemon/*.lua')):
        text = open(f, encoding='utf-8', errors='ignore').read().replace('\r', '')
        for m in re.finditer(r'^POKEMON\["([^"]+)"\]\s*=\s*\{(.*?)^\}', text, re.S | re.M):
            body = m.group(2)
            skills = re.search(r'^\s*skills = \{([^}]*)\}', body, re.M)
            out[m.group(1)] = {
                'skills': [(a, int(b)) for a, b in re.findall(r'"([^"]+)",\s*(\d+)', skills.group(1))] if skills else [],
                'evolutions': [(a, int(b)) for a, b in re.findall(r'name = "([^"]+)", requiredLevel = (\d+)', body)],
                'chance': int((re.search(r'\bchance = (\d+)', body) or [0, 0])[1]),
            }
    return out


def our_moves():
    moves = {}
    for f in glob.glob(os.path.join(CONFIG, 'moves/*.lua')):
        for name in re.findall(r'MOVES\["([^"]+)"\]', open(f, encoding='utf-8', errors='ignore').read()):
            moves[key(name)] = name
    return moves


class Plan:
    def __init__(self, api):
        self.api = api
        self.ours = our_pokemon()
        self.moves = our_moves()
        self.missing = defaultdict(set)
        self.species = {}

    def sp(self, slug):
        if slug not in self.species:
            s = self.api.get('pokemon-species/' + slug)
            p = self.api.get(s['varieties'][0]['pokemon']['url'] if not any(v['is_default'] for v in s['varieties'])
                             else next(v for v in s['varieties'] if v['is_default'])['pokemon']['url'])
            self.species[slug] = {'s': s, 'p': p, 'name': english(s['names'])}
        return self.species[slug]

    def move_info(self, url):
        m = self.api.get(url)
        return {'name': english(m['names']), 'power': m['power'] or 0, 'class': m['damage_class']['name'],
                'type': m['type']['name']}

    def learnset(self, slug):
        """Level-up moves (official level, our move name, info), then the other moves we have."""
        p = self.sp(slug)['p']
        for vg in VERSION_GROUPS:
            lv = {}
            for m in p['moves']:
                for d in m['version_group_details']:
                    if d['version_group']['name'] == vg and d['move_learn_method']['name'] == 'level-up':
                        lv[m['move']['url']] = min(lv.get(m['move']['url'], 999), d['level_learned_at'])
            if lv:
                break
        level, other = [], []
        for url, lvl in sorted(lv.items(), key=lambda x: x[1]):
            info = self.move_info(url)
            if key(info['name']) in self.moves:
                level.append((lvl, self.moves[key(info['name'])], info))
            else:
                self.missing[info['name']].add(self.sp(slug)['name'])
        for m in p['moves']:
            if m['move']['url'] in lv:
                continue
            info = self.move_info(m['move']['url'])
            if key(info['name']) in self.moves and info['class'] != 'status':
                other.append((999, self.moves[key(info['name'])], info))
        return level, other

    def types(self, slug):
        return [t['type']['name'] for t in self.sp(slug)['p']['types']]

    def pick(self, slug, slots, taken, evolved_at):
        """Fill `slots` levels with moves not in `taken`: early official moves for a first form,
        the moves it learns after evolving for later forms; at most one status move in four."""
        level, other = self.learnset(slug)
        stab = set(self.types(slug))
        cands = [c for c in level if c[1] not in taken]
        if evolved_at:
            # Later forms: what they learn after evolving, then their strongest attacks left.
            late = [c for c in cands if c[0] == 0 or c[0] >= evolved_at]
            rest = [c for c in cands if c not in late] + [c for c in other if c[1] not in taken]
            rest = [c for c in rest if c[2]['class'] != 'status' and c[2]['power'] >= 60]
            rest.sort(key=lambda c: (c[2]['type'] not in stab, -c[2]['power']))
            cands = late + rest
        chosen, status = [], 0
        for c in cands:
            if len(chosen) == len(slots):
                break
            if c[2]['class'] == 'status':
                if status >= max(1, len(slots) // 4):
                    continue
                status += 1
            chosen.append(c)
        if len(chosen) < len(slots):
            extra = sorted((c for c in other if c[1] not in taken and c[1] not in [x[1] for x in chosen]),
                           key=lambda c: (c[2]['type'] not in stab, c[2]['power']))
            chosen += extra[:len(slots) - len(chosen)]
        firsts = chosen[:1] if not evolved_at else []
        rest = sorted(chosen[len(firsts):], key=lambda c: (c[2]['class'] == 'status', c[2]['power'], c[0]))
        # Status moves keep their place by level; attacks get stronger with level.
        attacks = [c for c in rest if c[2]['class'] != 'status']
        statuses = sorted([c for c in rest if c[2]['class'] == 'status'], key=lambda c: c[0])
        order = firsts + attacks
        for s in statuses:
            pos = min(len(order), max(1, round(len(order) * (s[0] / 70))))
            order.insert(pos, s)
        return [(c[1], lvl) for lvl, c in zip(slots, order)]

    # -- evolution lines ------------------------------------------------------------------
    def chain(self, slug):
        url = self.sp(slug)['s']['evolution_chain']['url']
        return self.api.get(url)['chain']

    def build(self):
        lines, seen = [], set()
        for n in GEN4:
            slug = self.api.get(f'pokemon-species/{n}')['name']
            if slug in seen:
                continue
            root = self.chain(slug)
            if root['species']['name'] in seen:
                root = {'species': {'name': slug}, 'evolves_to': []}
            lines.append(self.line(root))
            seen.update(x['slug'] for x in lines[-1])
        return lines

    def line(self, root):
        """Every Pokemon of one evolution line, first form first."""
        nodes = []

        # PokeAPI puts Manaphy under Phione with no way to evolve; Phione doesn't evolve
        def keep(e):
            return e['evolution_details'] and self.sp(e['species']['name'])['s']['id'] <= GEN4[-1]

        def walk(node, parent, depth):
            slug = node['species']['name']
            nodes.append({'slug': slug, 'parent': parent, 'depth': depth, 'node': node})
            for e in node['evolves_to']:
                if keep(e):
                    walk(e, slug, depth + 1)
        walk(root, None, 0)
        for x in nodes:
            x['node'] = dict(x['node'], evolves_to=[e for e in x['node']['evolves_to'] if keep(e)])
        by = {x['slug']: x for x in nodes}
        for x in nodes:
            info = self.sp(x['slug'])
            x['name'] = info['name']
            x['gen4'] = info['s']['id'] in GEN4
            x['ours'] = self.ours.get(info['name'])
            x['baby'] = info['s']['is_baby'] and x['slug'] not in NOT_BABY
            x['legend'] = info['s']['is_legendary'] or info['s']['is_mythical']
            x['mythical'] = info['s']['is_mythical']
            x['children'] = [e['species']['name'] for e in x['node']['evolves_to']]
        stages = 1 + max(x['depth'] for x in nodes) - (1 if nodes[0]['baby'] else 0)
        pseudo = nodes[0]['slug'] in PSEUDO
        starter = nodes[0]['slug'] in STARTERS
        for x in nodes:
            x['stages'] = stages
            if x['parent']:
                x['evolve'] = self.evolution(by[x['parent']], x, stages, pseudo, starter, by)
        for x in nodes:
            self.moves_for(x, by, stages)
            x['chance'] = self.chance(x, by, stages, pseudo)
        return nodes

    def evolution(self, parent, x, stages, pseudo, starter, by):
        d = x['node']['evolution_details'][0] if x['node']['evolution_details'] else {}
        item = (d.get('item') or {}).get('name') or (d.get('held_item') or {}).get('name') or PLACE_ITEMS.get(x['slug'])
        siblings = [by[c] for c in parent['children'] if c != x['slug']]
        old_sibling = next((s for s in siblings if s['ours'] and parent['ours']), None)
        stage = parent['depth'] - (1 if by[next(iter(by))]['baby'] else 0)  # 0 for a first evolution
        note = ''
        if parent['baby']:
            level = 25
        elif parent['ours'] and old_sibling:
            # A new branch next to one we have (Leafeon by Vaporeon, Gallade by Gardevoir): same level.
            level = next(lv for name, lv in parent['ours']['evolutions'] if name == old_sibling['name'])
        elif parent['ours'] and not x['ours'] and not parent['ours']['evolutions']:
            # A new last form for a Pokemon that used to be final.
            level = 60 if parent['parent'] else 40
        elif pseudo:
            level = 40 if stage == 0 else 60
        elif stage >= 1:
            level = 55 if starter else 50
        elif stages >= 3:
            level = 35
        else:
            official = d.get('min_level') or 30
            level = 30 if official < 25 else 35 if official < 35 else 40
        if d.get('known_move') or d.get('known_move_type'):
            note = 'official: knows %s' % ((d.get('known_move') or d.get('known_move_type'))['name'])
        if d.get('gender'):
            note = 'official: %s only' % ('female' if d['gender'] == 1 else 'male')
        items = []
        if item and item in NEW_ITEMS:
            items = [NEW_ITEMS[item]]
        elif item and item in OLD_ITEMS:
            items = [OLD_ITEMS[item]]
        time = {'day': 'DAY', 'night': 'NIGHT'}.get(d.get('time_of_day') or '')
        if time and not items:
            time = None  # friendship by day or night: level only, like Pichu
        return {'level': level, 'items': items, 'time': time if items else None, 'note': note,
                'random': x['slug'] in ('wormadam', 'mothim')}

    def moves_for(self, x, by, stages):
        if x['ours']:
            x['skills'] = x['ours']['skills']
            return
        parent = by.get(x['parent'])
        taken = [m for m, _ in parent['skills']] if parent else []
        start = x['evolve']['level'] + 5 if parent else 1
        if x['children']:
            end = min(by[c]['evolve']['level'] for c in x['children']) - 5 if 'evolve' in by[x['children'][0]] else 30
        elif x['legend']:
            end = 70
        elif not parent:
            end = 65
        elif parent['ours'] and not parent['ours']['evolutions']:
            start = max(lv for _, lv in parent['skills']) + 5
            end = start + 10
        else:
            end = 75 if stages >= 3 else 70
        slots = ([1] if start == 1 else []) + list(range(max(start, 5), end + 1, 5))
        evolved_at = None
        if parent:
            d = x['node']['evolution_details'][0] if x['node']['evolution_details'] else {}
            evolved_at = d.get('min_level') or 1
        x['skills'] = (parent['skills'] if parent else []) + self.pick(x['slug'], slots, taken, evolved_at)

    def chance(self, x, by, stages, pseudo):
        if x['ours']:
            return x['ours']['chance']
        if x['legend']:
            return 100000 if x['mythical'] else 10000
        if x['baby']:
            return 150
        parent = by.get(x['parent'])
        if parent and parent['ours'] and not parent['ours']['evolutions']:
            return max(800, 2 * parent['ours']['chance'])
        if parent and parent['ours']:
            return max(500, parent['ours']['chance'] * 2)
        stage = x['depth'] - (1 if by[next(iter(by))]['baby'] else 0)
        if pseudo:
            return [500, 1200, 2000][stage]
        if stages == 1:
            bst = sum(s['base_stat'] for s in self.sp(x['slug'])['p']['stats'])
            return 700 if bst >= 500 else 400
        if stages == 2:
            return [150, 500][stage]
        return [150, 300, 800][min(stage, 2)]

    def stats(self, slug):
        s = {st['stat']['name']: st['base_stat'] for st in self.sp(slug)['p']['stats']}
        return {'hp': s['hp'], 'atk': s['attack'], 'def': s['defense'], 'spAtk': s['special-attack'],
                'spDef': s['special-defense'], 'speed': s['speed']}


def describe_evolve(e):
    parts = ['level %d' % e['level']] + [i.replace('_', ' ').title() for i in e['items']]
    if e['time']:
        parts.append('by ' + e['time'].lower())
    if e['random']:
        parts.append('random')
    return ' + '.join(parts)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--cache', default='/tmp/pokeapi-cache')
    args = ap.parse_args()
    plan = Plan(Api(args.cache))
    lines = plan.build()

    data, md = [], []
    for line in lines:
        rows = []
        for x in line:
            if not x['gen4']:
                continue
            row = {'number': plan.sp(x['slug'])['s']['id'], 'name': x['name'], 'types': plan.types(x['slug']),
                   'stats': plan.stats(x['slug']), 'chance': x['chance'], 'skills': x['skills'],
                   'from': plan.sp(x['parent'])['name'] if x['parent'] else None,
                   'evolve': x.get('evolve'), 'legendary': x['legend'], 'baby': x['baby'],
                   'evolvesTo': [plan.sp(c)['name'] for c in x['children']]}
            data.append(row)
            rows.append(row)
        if rows:
            md.append(line)
    data.sort(key=lambda r: r['number'])

    out = ['# Gen 4: levels, catch chance and moves', '',
           'Generated by `scripts/gen4-plan.py`. Base stats are from PokeAPI (the same numbers as',
           'Bulbapedia). Evolution levels, catch chances and move lists are ours, made by the rules',
           'below from how our Gen 1 to 3 Pokemon are set up. Only moves the server already has are used.', '',
           '## Rules', '',
           '- **Evolution levels.** First evolution at 30, 35 or 40 by how late it is in the games '
           '(35 in three-stage lines), second at 50 (55 for the starters). Gible\'s line is like Larvitar\'s: '
           '40 and 60. Babies evolve at 25. A new last form for a Pokemon that used to be final evolves at '
           '40 after a one-stage Pokemon (Aipom, Gligar) and 60 after a middle one (Magneton, Rhydon). A new '
           'branch next to one we have uses the same level (Leafeon and Glaceon at 30 like Vaporeon, Gallade '
           'at 50 like Gardevoir).',
           '- **Evolution items.** Stone and held-item evolutions keep their item. Trades become a level '
           'plus the item they held. Evolutions by place use the stone newer games use (Magnezone and '
           'Probopass: Thunder Stone, Leafeon: Leaf Stone, Glaceon: Ice Stone). Friendship and "knows a '
           'move" evolutions are a level only. Burmy becomes Wormadam or Mothim at random, like Wurmple.',
           '- **Moves.** A new move every 5 levels from level 1, until the level it evolves at; an evolved '
           'form keeps every move of the one before and adds its own. Final forms reach level 70 (75 in '
           'three-stage lines), so most have 14 moves. One-stage Pokemon: 14 moves to level 65. Legendaries: '
           '15 to level 70. Babies: 5 to level 20. First forms take their earliest official moves; evolved '
           'forms the ones learned after evolving. At most one move in four is a status move. When the '
           'official list runs short, TM and egg attacks of its own type fill in. Attacks get stronger with level.',
           '- **Catch chance** (higher is harder): 150 for first forms; 300 then 800 in three-stage lines; '
           '500 for the second of two; 400 for one-stage Pokemon (700 with a base stat total of 500 or more); '
           '150 for babies; Gible 500, 1200, 2000; 10000 for legendaries, 100000 for mythicals; new last forms '
           'of our Pokemon twice the one before (at least 800).', '']
    newitems = sorted({i for line in md for x in line if 'evolve' in x for i in x['evolve']['items']
                       if i in NEW_ITEMS.values()})
    out += ['## New evolution items', '', ', '.join(i.replace('_', ' ').title() for i in newitems), '']
    out += ['## Moves Gen 4 Pokemon learn that the server doesn\'t have', '',
            'Not used. Add any of them and run the script again to put them in the lists. Which ones to add',
            'first: [move-audit.md](move-audit.md).', '',
            '| Move | Learned by |', '| --- | --- |']
    for m, who in sorted(plan.missing.items(), key=lambda x: (-len(x[1]), x[0])):
        out.append('| %s | %s |' % (m, ', '.join(sorted(who))))
    out += ['', '## The list', '']
    for line in md:
        names = ' > '.join(x['name'] + ('' if x['gen4'] else ' (ours)') for x in line)
        out += ['### ' + names, '']
        for x in line:
            r = next((r for r in data if r['name'] == x['name']), None)
            if not r:
                continue
            st = r['stats']
            head = '**#%d %s** (%s). HP %d, Atk %d, Def %d, SpA %d, SpD %d, Spe %d. Catch %d.' % (
                r['number'], r['name'], '/'.join(t.title() for t in r['types']), st['hp'], st['atk'],
                st['def'], st['spAtk'], st['spDef'], st['speed'], r['chance'])
            if r['evolve']:
                head += ' From %s at %s.' % (r['from'], describe_evolve(r['evolve']))
                if r['evolve']['note']:
                    head += ' (%s)' % r['evolve']['note']
            out += [head, '', ', '.join('%d %s' % (lv, m) for m, lv in r['skills']), '']
    # Evolutions added to Pokemon we already have
    edits = []
    for line in md:
        by = {x['slug']: x for x in line}
        for x in line:
            if x['gen4'] and x['parent'] and by[x['parent']]['ours']:
                edits.append('- %s: add %s at %s' % (by[x['parent']]['name'], x['name'], describe_evolve(x['evolve'])))
            if not x['gen4'] and x['parent'] and x['ours'] and by[x['parent']]['gen4']:
                edits.append('- %s (new baby) evolves into %s at %s' % (by[x['parent']]['name'], x['name'],
                                                                        describe_evolve(x['evolve'])))
    out[out.index('## The list'):out.index('## The list')] = ['## Changes to Pokemon we have', ''] + edits + ['']
    open(os.path.join(ROOT, 'docs/gen4-levels-and-moves.md'), 'w').write('\n'.join(out) + '\n')
    os.makedirs(os.path.join(ROOT, 'scripts/data'), exist_ok=True)
    json.dump(data, open(os.path.join(ROOT, 'scripts/data/gen4-plan.json'), 'w'), indent=1)
    print('%d Pokemon, %d lines, %d missing moves' % (len(data), len(md), len(plan.missing)))


if __name__ == '__main__':
    main()
