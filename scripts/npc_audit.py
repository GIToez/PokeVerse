#!/usr/bin/env python3
"""Audit NPC dialogue for clickable keywords.

Words in {braces} in an NPC message show blue and can be clicked in the client. For every NPC
(data/npc/*.xml) this lists:

  - keywords the NPC answers to that no message of it ever shows in braces (players have to
    guess them, like "duel" at gym leaders);
  - questions in a script that answers "yes" whose text has no {yes} (and {no});
  - greetings that show no keyword at all although the NPC answers to some.

Shared code (the travel and shop modules, the quest and NPC battle libraries) is checked once,
under "Shared code", because a fix there covers every NPC that uses it.

  python3 scripts/npc_audit.py              # writes docs/npc-audit.md
  python3 scripts/npc_audit.py --json out   # also writes the raw findings
"""

import argparse
import collections
import html
import json
import os
import re

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DATA = os.path.join(ROOT, 'core', 'server', 'data')
NPC_DIR = os.path.join(DATA, 'npc')
SCRIPTS = os.path.join(NPC_DIR, 'scripts')
SPAWN = os.path.join(DATA, 'world', 'map-spawn.xml')
QUEST_LIB = os.path.join(DATA, 'lib', 'ps', 'systems', '002-quest.lua')

# Answered by the focus module or meaningless as a hint
IGNORED = {'hi', 'hello', 'hey', 'bye', 'farewell', 'goodbye', 'yes', 'no', 'ok', 'job', 'name'}
# Portuguese aliases next to the English keyword; never the only hint a player needs
PORTUGUESE = {
    'sim', 'nao', 'oi', 'ola', 'tchau', 'missao', 'tarefa', 'ajuda', 'treinador', 'uva', 'problema',
    'arquipelago', 'laranja', 'negociar', 'comercio', 'destino', 'lista', 'viagem', 'viajar',
    'batalha', 'duelar', 'lutar', 'entrar', 'zona', 'sair', 'trocar', 'comprar', 'vender', 'ajudar',
    'cancelar', 'iniciar', 'comecar', 'terminar', 'pegar', 'deixar', 'depositar', 'sacar', 'saldo',
    'casa', 'quarto', 'aluguel', 'pokemon', 'informacao', 'informacoes', 'recompensa', 'premio',
    'torneio', 'inscrever', 'desistir', 'remover', 'retirar', 'treinar', 'treino', 'cancelar',
    'jogar', 'fichas', 'moedas', 'trocar', 'loja', 'tutorial', 'pular', 'continuar', 'voltar',
    'guilda', 'criar', 'convidar', 'expulsar', 'clan', 'cla', 'zerar', 'resetar', 'vitamina',
    'roupa', 'roupas', 'addon', 'addons', 'ovo', 'ovos', 'chocar', 'jornal', 'entregar',
}

STRING_RE = re.compile(r'"((?:[^"\\\n]|\\.)*)"|\'((?:[^\'\\\n]|\\.)*)\'|\[\[(.*?)\]\]', re.S)
MSGCONTAINS_RE = re.compile(r'msgcontains\s*\(\s*\w+\s*,\s*(\{[^}]*\}|"[^"]*"|\'[^\']*\')')
ADDKEYWORD_RE = re.compile(r'add(?:Child)?Keyword\s*\(\s*\{([^}]*)\}')
MSG_EQUALS_RE = re.compile(r'\b(?:msg|message)(?::lower\(\))?\s*[~=]=\s*("[^"]*"|\'[^\']*\')')
BRACED_RE = re.compile(r'\{([^{}]+)\}')
YES_RE = re.compile(r'msgcontains\s*\(\s*\w+\s*,\s*["\']yes["\']|SHOP_YESWORD|doQuestTalk|doTalkEnd')


def lua_strings(text):
    out = []
    for m in STRING_RE.finditer(text):
        s = next(g for g in m.groups() if g is not None)
        out.append(s.replace("\\'", "'").replace('\\"', '"'))
    return out


def strip_comments(text):
    text = re.sub(r'--\[(=*)\[.*?\]\1\]', '', text, flags=re.S)
    return re.sub(r'--[^\n]*', '', text)


def keyword_groups(code):
    """Sets of words that do the same thing (one if/elseif condition or one addKeyword)."""
    groups = []
    for line in code.splitlines():
        words = []
        for m in MSGCONTAINS_RE.finditer(line):
            words += [w.lower() for w in lua_strings(m.group(1))]
        for m in MSG_EQUALS_RE.finditer(line):
            words += [w.lower() for w in lua_strings(m.group(1))]
        if words:
            groups.append(frozenset(words))
    for m in ADDKEYWORD_RE.finditer(code):
        words = [w.lower() for w in lua_strings(m.group(1))]
        if words:
            groups.append(frozenset(words))
    return groups


def braced(texts):
    words = set()
    for t in texts:
        for m in BRACED_RE.finditer(t):
            inner = m.group(1).lower()
            words.add(inner.strip())
            words.update(re.findall(r"[a-z0-9'.-]+", inner))
    return words


OPEN_QUESTION = re.compile(r'^\W*(how|what|which|where|who|why|when|sorry)\b', re.I)


def is_question(s):
    """A yes/no question: open questions and ones that already offer {choices} don't count."""
    s = s.strip()
    return ('?' in s and len(s.split()) >= 3 and not s.startswith('(') and '{' not in s
            and not OPEN_QUESTION.match(s))


def says_yes(s):
    low = s.lower()
    return '{yes' in low


def questions_without_yes(code, texts):
    if not YES_RE.search(code):
        return []
    return sorted({t for t in texts if is_question(t) and not says_yes(t)})


def english(group):
    return {w for w in group if w not in PORTUGUESE and w not in IGNORED and re.fullmatch(r"[a-z0-9 '.-]+", w)
            and re.search('[a-z]', w)}


def parse_npc(path):
    with open(path, encoding='utf-8', errors='replace') as f:
        xml = f.read()
    name = re.search(r'<npc\s+name="([^"]*)"', xml)
    script = re.search(r'script="([^"]*)"', xml)
    params = {k: html.unescape(v) for k, v in re.findall(r'<parameter\s+key="([^"]*)"\s+value="([^"]*)"', xml)}
    return {
        'file': os.path.basename(path),
        'name': name.group(1) if name else os.path.basename(path)[:-4],
        'script': os.path.basename(script.group(1)) if script else None,
        'params': params,
    }


def quest_keywords():
    with open(QUEST_LIB, encoding='utf-8') as f:
        code = f.read()
    default = lua_strings(re.search(r'DEFAULT_KEYWORDS\s*=\s*\{([^}]*)\}', code).group(1))
    per = {}
    for m in re.finditer(r'KEYWORDS\["([^"]+)"\]\s*=\s*\{([^}]*)\}', code):
        per[m.group(1)] = lua_strings(m.group(2))
    return default, per


def placed_npcs():
    with open(SPAWN, encoding='utf-8', errors='replace') as f:
        return collections.Counter(html.unescape(n) for n in re.findall(r'<npc\s+name="([^"]*)"', f.read()))


SHARED = [
    ('Travel module (every travel NPC)', os.path.join(NPC_DIR, 'lib', 'npcsystem', 'modules.lua'),
     r'function TravelModule\.travel.*?\n    end'),
    ('Outfit module', os.path.join(NPC_DIR, 'lib', 'npcsystem', 'modules.lua'),
     r'function OutfitModule\.obtain.*?\n    end'),
    ('NPC battles (gym leaders, trainers, Elite Four)', os.path.join(DATA, 'lib', 'ps', 'systems', '001-npcBattle.lua'),
     r'doTalkStart.*?\nend'),
    ('Quests (every quest NPC)', QUEST_LIB, r'function doQuestTalkStart.*?\nend'),
]


def audit_shared():
    found = []
    for title, path, pattern in SHARED:
        with open(path, encoding='utf-8') as f:
            code = strip_comments(f.read())
        m = re.search(pattern, code, re.S)
        if not m:
            continue
        block = m.group(0)
        qs = sorted({t for t in lua_strings(block) if is_question(t) and not says_yes(t)})
        if not qs and '{yes' not in block.lower():
            # questions built with .. leave the ? in a literal of its own
            qs = [ln.strip() for ln in block.splitlines()
                  if re.search(r'["\'][^"\']*\?[^"\']*["\']', ln) and 'say' in ln]
        rel = os.path.relpath(path, ROOT)
        found.append({'title': title, 'file': rel, 'questions': qs})
    return found


def audit(args):
    placed = placed_npcs()
    q_default, q_per = quest_keywords()
    scripts = {}
    for fn in os.listdir(SCRIPTS):
        if fn.endswith('.lua'):
            with open(os.path.join(SCRIPTS, fn), encoding='utf-8', errors='replace') as f:
                code = strip_comments(f.read())
            scripts[fn] = {'code': code, 'texts': lua_strings(code), 'groups': keyword_groups(code)}

    npcs = [parse_npc(os.path.join(NPC_DIR, fn)) for fn in sorted(os.listdir(NPC_DIR)) if fn.endswith('.xml')]
    users = collections.defaultdict(list)
    for npc in npcs:
        users[npc['script']].append(npc['name'])

    results = []
    for npc in npcs:
        p = npc['params']
        greet = p.get('message_greet', '')
        sc = scripts.get(npc['script']) or {'code': '', 'texts': [], 'groups': []}
        texts = [greet] + [v for k, v in p.items() if k.startswith('message_')] + sc['texts']
        groups = list(sc['groups'])
        if 'doQuestTalk' in sc['code']:
            groups.append(frozenset(w.lower() for w in q_per.get(npc['name'], q_default)))
        if p.get('module_shop') == '1' or 'shop_buyable' in p or 'shop_sellable' in p:
            groups.append(frozenset({'trade', 'offer'}))
        if p.get('travel_destinations'):
            # the destination list itself shows every destination in braces
            groups.append(frozenset({'travel', 'destination', 'list', 'where'}))

        shown = braced(texts)
        missing = []
        seen = set()
        for g in groups:
            eng = english(g)
            if not eng or g in seen:
                continue
            seen.add(g)
            if not (g & shown):
                missing.append(sorted(eng))
        missing.sort()

        handles_any = any(english(g) for g in groups)
        greet_shows = bool(BRACED_RE.search(greet))
        shared_script = len(users[npc['script']]) > 1
        results.append({
            'name': npc['name'],
            'file': npc['file'],
            'script': npc['script'],
            'shared_script': shared_script,
            'placed': placed.get(npc['name'], 0),
            'greeting': greet,
            'greeting_without_keywords': handles_any and not greet_shows,
            'hidden_keywords': missing,
            'questions_without_yes': [] if shared_script else questions_without_yes(sc['code'], sc['texts']),
        })

    shared_questions = {}
    for fn, users_of in users.items():
        if fn and len(users_of) > 1 and fn in scripts:
            qs = questions_without_yes(scripts[fn]['code'], scripts[fn]['texts'])
            if qs:
                shared_questions[fn] = {'npcs': len(users_of), 'questions': qs}

    return results, audit_shared(), shared_questions


def write_report(results, shared, shared_questions, out):
    live = [r for r in results if r['placed']]
    hidden = [r for r in live if r['hidden_keywords']]
    no_yes = [r for r in live if r['questions_without_yes']]
    bare_greet = [r for r in live if r['greeting_without_keywords']]
    clean = [r for r in live if not (r['hidden_keywords'] or r['questions_without_yes'] or r['greeting_without_keywords'])]

    by_script = collections.defaultdict(list)
    for r in live:
        if r['hidden_keywords'] or r['greeting_without_keywords'] or r['questions_without_yes']:
            family = re.sub(r'^(npcbattle|mastery)_.*', r'\1_*.lua', r['script'] or '(no script)')
            by_script[family].append(r)

    lines = [
        '# NPC dialogue audit',
        '',
        'Generated by `scripts/npc_audit.py`; run it again after changing NPCs. Words in {braces} in',
        'an NPC message show blue and can be clicked. This lists what players can say to an NPC but',
        'never see as a blue word, and questions that expect yes or no without showing them.',
        '',
        '## Summary',
        '',
        '| | NPCs |',
        '| --- | --- |',
        f'| NPC files | {len(results)} |',
        f'| Placed on the map | {len(live)} |',
        f'| Placed, with nothing to fix | {len(clean)} |',
        f'| Greeting shows no blue word although the NPC answers to some | {len(bare_greet)} |',
        f'| Answers to a word it never shows in blue | {len(hidden)} |',
        f'| Own script asks a yes/no question without {{yes}} | {len(no_yes)} |',
        '',
        'NPC files not placed on the map are left out below; they are listed at the end.',
        '',
        '## Shared code',
        '',
        'One fix here covers every NPC that uses it.',
        '',
    ]
    for s in shared:
        if s['questions']:
            lines.append(f"- **{s['title']}** (`{s['file']}`):")
            lines += [f'  - `{q}`' if 'say' in q else f'  - "{q}"' for q in s['questions']]
    for fn, info in sorted(shared_questions.items(), key=lambda kv: -kv[1]['npcs']):
        lines.append(f"- **`npc/scripts/{fn}`** ({info['npcs']} NPCs):")
        lines += [f'  - "{q}"' for q in info['questions'][:12]]
        if len(info['questions']) > 12:
            lines.append(f"  - and {len(info['questions']) - 12} more")
    lines += ['', '## By script', '',
              'Each NPC: the words it answers to but never shows (synonyms together), and whether its',
              'greeting shows any blue word.', '']

    for script, rs in sorted(by_script.items(), key=lambda kv: (-len(kv[1]), kv[0])):
        lines.append(f'### `{script}` ({len(rs)} NPCs)')
        lines.append('')
        common = collections.Counter(' / '.join(k) for r in rs for k in r['hidden_keywords'])
        if len(rs) > 3 and common:
            top = ', '.join(f'{k} ({n})' for k, n in common.most_common(8))
            lines.append(f'Most often hidden: {top}.')
            lines.append('')
        lines.append('| NPC | Hidden words | Greeting |')
        lines.append('| --- | --- | --- |')
        for r in sorted(rs, key=lambda r: r['name']):
            words = ', '.join(' / '.join(k) for k in r['hidden_keywords']) or '-'
            greet = 'no blue word' if r['greeting_without_keywords'] else 'ok'
            lines.append(f"| {r['name']} | {words} | {greet} |")
        own = [r for r in rs if r['questions_without_yes']]
        if own:
            lines.append('')
            lines.append('Questions without {yes}:')
            lines.append('')
            for r in own:
                for q in r['questions_without_yes'][:6]:
                    lines.append(f'- {r["name"]}: "{q}"')
                if len(r['questions_without_yes']) > 6:
                    lines.append(f"- {r['name']}: and {len(r['questions_without_yes']) - 6} more")
        lines.append('')

    unplaced = sorted(r['name'] for r in results if not r['placed'])
    lines += ['## Not placed on the map', '', f'{len(unplaced)} NPC files: ' + ', '.join(unplaced) + '.', '']
    with open(out, 'w', encoding='utf-8') as f:
        f.write('\n'.join(lines))


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument('--out', default=os.path.join(ROOT, 'docs', 'npc-audit.md'))
    ap.add_argument('--json')
    args = ap.parse_args()
    results, shared, shared_questions = audit(args)
    write_report(results, shared, shared_questions, args.out)
    if args.json:
        with open(args.json, 'w', encoding='utf-8') as f:
            json.dump({'npcs': results, 'shared': shared, 'shared_scripts': shared_questions}, f, indent=1)
    live = [r for r in results if r['placed']]
    print(f"{len(results)} NPC files, {len(live)} placed; "
          f"{sum(1 for r in live if r['greeting_without_keywords'])} greetings without a blue word, "
          f"{sum(1 for r in live if r['hidden_keywords'])} with hidden words, "
          f"{sum(1 for r in live if r['questions_without_yes'])} with questions without {{yes}}")


if __name__ == '__main__':
    main()
