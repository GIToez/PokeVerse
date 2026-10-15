#!/usr/bin/env python3
"""Audit what placed NPCs say: their greetings, script lines and quest dialogue.

For every NPC placed on the map (world/map-spawn.xml) this checks each line players can read:

  - Portuguese left untranslated;
  - leftovers from Tibia or the old servers (gold coins, Thais, PokeSoul...);
  - blue words ({word}) the NPC does not answer to, so clicking them does nothing;
  - quests whose text asks for a different item, Pokemon, count or level than the quest checks,
    and quests nobody can start (the NPC is not placed or its script has no quest talk);
  - formatting: unbalanced braces, double spaces, a missing space after punctuation;
  - spelling and grammar, with LanguageTool when it is installed
    (pip install language_tool_python; Java 17+). Names of Pokemon, items, NPCs and places
    are not counted as misspelled.

NPCs that only greet (no keywords, no quests, no shop) are listed as one-liners: not a problem,
just NPCs whose dialogue is still to be written.

  python3 scripts/npc_conversation_audit.py               # docs/npc-conversations.md
  python3 scripts/npc_conversation_audit.py --no-grammar  # skip LanguageTool
"""

import argparse
import collections
import hashlib
import html
import json
import os
import re
import subprocess
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import npc_audit as base  # noqa: E402

ROOT = base.ROOT
DATA = base.DATA
QUEST_CONFIG = os.path.join(DATA, 'lib', 'ps', 'config', '003-quest.lua')
ITEMS = os.path.join(DATA, 'items', 'items.xml')
MONSTERS = os.path.join(DATA, 'monster')
CACHE = os.path.join(ROOT, 'build', 'npc-grammar-cache.json')

# talk_questDone is left out: 002-quest.lua never says it
QUEST_TALK = ['talk_questStarting', 'talk_questStarted', 'talk_questFinishing', 'talk_questFinished',
              'talk_questFinishFail']
TYPE_NAMES = {0: 'bring items', 1: 'bring Pokemon', 2: 'Pokedex', 3: 'defeat', 4: 'catch', 5: 'custom'}

PORTUGUESE_WORDS = {
    'voce', 'você', 'nao', 'não', 'está', 'obrigado', 'obrigada', 'também', 'tambem', 'então',
    'entao', 'aqui', 'agora', 'muito', 'nível', 'nivel', 'desculpe', 'ainda', 'pode', 'fazer',
    'quer', 'deseja', 'preciso', 'precisa', 'tenho', 'seu', 'sua', 'meu', 'minha', 'para', 'pra',
    'com', 'favor', 'olá', 'ola', 'que', 'uma', 'isso', 'essa', 'esse', 'seus', 'suas', 'mais',
    'quando', 'onde', 'porque', 'pokémons', 'treinador', 'missão', 'missao', 'tarefa', 'sim',
    'bem', 'vindo', 'bem-vindo', 'até', 'logo', 'dinheiro', 'ajuda', 'ajudar', 'pegar', 'falar',
    'comigo', 'você', 'algum', 'alguma', 'nada', 'tudo', 'cidade', 'loja', 'aventura',
}
PORTUGUESE_CHARS = re.compile('[ãõçÃÕÇâêôáéíóúà]')

LEFTOVERS = [
    (re.compile(r'\b(gold|platinum|crystal) coins?\b', re.I), 'Tibia money'),
    (re.compile(r'\b(thais|carlin|venore|rookgaard|edron|darashia|ankrahmun|kazordoon|ab\'dendriel|'
                r'port hope|svargrond|liberty bay|yalahar)\b', re.I), 'Tibia town'),
    (re.compile(r'\b(knights?|paladins?|sorcerers?|druids?|rook(er|ie)? island)\b', re.I), 'Tibia vocation'),
    (re.compile(r'\b(tibia|cipsoft|tibiano)\b', re.I), 'Tibia'),
    (re.compile(r'\b(p ?soul|poke ?soul|pokesoul|pokexgames|pxg|otpokemon|poketibia|pokemon ?dash|shinyzone)\b',
                re.I), 'old server name'),
    (re.compile(r'\b(lorem|ipsum|asdf|teste|testing 123|todo|fixme|xxx+)\b', re.I), 'placeholder'),
]

# where NPC lines are said; strings elsewhere in a script are usually code
SAY_LINE = re.compile(r'say|Say|setMessage|reply|sayStory|createStory|TextMessage|message\s*=|text\s*=|'
                      r'msg\s*=|talk\w*\s*=|answer', re.S)
WORD_RE = re.compile(r"[A-Za-zÀ-ÿ][A-Za-zÀ-ÿ'-]*")


def is_dialogue(s):
    s = s.strip()
    if len(s) < 4 or not re.search('[A-Za-z]{2}', s):
        return False
    if re.fullmatch(r'[\w.%/-]+', s) or re.search(r'[=<>]=|\bfunction\b|\(cid\)|\.lua\b|\.xml\b|^%', s):
        return False
    return len(s.split()) >= 2 or s.endswith(('!', '?', '.'))


def dialogue_strings(code):
    out = []
    for line in code.splitlines():
        if SAY_LINE.search(line):
            out += [s for s in base.lua_strings(line) if is_dialogue(s)]
    return out


def load_quests():
    try:
        raw = subprocess.check_output(['lua5.1', os.path.join(ROOT, 'scripts', 'npc_quests_dump.lua'), QUEST_CONFIG])
    except (OSError, subprocess.CalledProcessError) as e:
        sys.exit(f'cannot read the quests with lua5.1: {e}')
    return json.loads(raw)


def load_items():
    names = {}
    with open(ITEMS, encoding='utf-8', errors='replace') as f:
        for line in f:
            m = re.search(r'<item\s+(?:id="(\d+)"|fromid="(\d+)"\s+toid="(\d+)")[^>]*?\bname="([^"]*)"', line)
            if not m:
                continue
            plural = re.search(r'plural="([^"]*)"', line)
            entry = (html.unescape(m.group(4)), html.unescape(plural.group(1)) if plural else '')
            if m.group(1):
                names[int(m.group(1))] = entry
            else:
                for i in range(int(m.group(2)), int(m.group(3)) + 1):
                    names[i] = entry
    return names


def load_monsters():
    names = set()
    for dirpath, _, files in os.walk(MONSTERS):
        for fn in files:
            if fn.endswith('.xml'):
                with open(os.path.join(dirpath, fn), encoding='utf-8', errors='replace') as f:
                    head = f.read(600)
                m = re.search(r'<monster\s+name="([^"]*)"', head)
                if m:
                    names.add(html.unescape(m.group(1)))
    return names


def vocabulary(items, monsters, npc_names):
    words = set()
    for text in list(monsters) + [n for n, _ in items.values()] + [p for _, p in items.values()] + list(npc_names):
        words.update(w.lower() for w in WORD_RE.findall(text))
    with open(base.SPAWN, encoding='utf-8', errors='replace') as f:
        spawn = f.read()
    words.update(w.lower() for w in WORD_RE.findall(' '.join(re.findall(r'name="([^"]*)"', spawn))))
    words.update({
        'pokemon', 'pokémon', 'pokemons', 'pokedex', 'pokédex', 'pokeball', 'pokeballs', 'poké', 'poke',
        'pokecenter', 'pokemart', 'pokepedia', 'pokeverse', 'kanto', 'johto', 'hoenn', 'sinnoh', 'orange',
        'pallet', 'viridian', 'pewter', 'cerulean', 'vermilion', 'lavender', 'celadon', 'fuchsia', 'saffron',
        'cinnabar', 'shamouti', 'nanji', 'tanoby', 'outcast', 'seafoam', 'daycare', 'pvp', 'npc', 'npcs',
        'exp', 'hp', 'tm', 'tms', 'hm', 'iv', 'ivs', 'ev', 'evs', 'gts', 'addon', 'addons', 'ok', 'okay',
        'mt', 'pokecoin', 'pokecoins', 'shiny', 'shinies', 'ditto', 'rocket', 'bike', 'pokémons',
        'hmm', 'hmmm', 'huh', 'heh', 'hehe', 'haha', 'hahaha', 'ahh', 'ah', 'oh', 'ohh', 'eh', 'mmm', 'uh',
        'yay', 'wow', 'zzz', 'aha', 'grr', 'shh', 'psst', 'phew', 'ugh', 'umm', 'um',
        'silph', 'mikan', 'sevii', 'pummelo', 'ascorbia', 'butwal', 'singleplayer', 'hicks', 'nagumo',
    })
    return words


def find_portuguese(text):
    words = [w.lower() for w in WORD_RE.findall(text)]
    hits = [w for w in words if w in PORTUGUESE_WORDS]
    # "para", "com", "sim", "mais" alone are often names or English; two words or an accent is a sentence
    if len(set(hits)) >= 2 or (PORTUGUESE_CHARS.search(text) and hits):
        return sorted(set(hits))
    return None


def find_leftovers(text):
    return sorted({f'{label}: "{m.group(0)}"' for rx, label in LEFTOVERS for m in rx.finditer(text)})


def find_format(text):
    problems = []
    depth = 0
    for c in text:
        depth += {'{': 1, '}': -1}.get(c, 0)
        if depth < 0 or depth > 1:
            break
    fragment = text.lstrip().startswith('}') or text.rstrip().endswith('{')  # joined with .. in the code
    if not fragment and (depth != 0 or text.count('{') != text.count('}')):
        problems.append('unbalanced { }')
    if '{}' in text or '{ }' in text:
        problems.append('empty { }')
    if re.search(r'\S  +\S', text):
        problems.append('double space')
    if re.search(r'\s[,.!?;:](\s|$)', text) and not re.search(r'\s\.\.\.', text):
        problems.append('space before punctuation')
    prose = re.sub(r'/\w+\[[^\]]*\]|\S+\.\w{2,4}\b|https?://\S+', '', text)
    if re.search(r'[a-z]{2}[,!?;][A-Za-z]', prose) or re.search(r'[a-z]{3}\.[A-Z][a-z]', prose):
        problems.append('no space after punctuation')
    if re.search(r'&(amp|quot|lt|gt|#\d+);', text):
        problems.append('HTML entity')
    m = re.search(r'\b(\w+) \1\b', text, re.I)
    if m and m.group(1).lower() not in {'ha', 'he', 'no', 'bye', 'so', 'very', 'go', 'that', 'had', 'zz', 'ya',
                                        'tri', 'la', 'hi', 'oh', 'run', 'come', 'yes', 'hey'}:
        problems.append(f'repeated word "{m.group(1)}"')
    return problems


# ---------------------------------------------------------------- grammar (LanguageTool)

IGNORED_RULES = {
    'UPPERCASE_SENTENCE_START',  # many lines are fragments joined at runtime
    'WHITESPACE_RULE', 'COMMA_PARENTHESIS_WHITESPACE', 'DOUBLE_PUNCTUATION',  # covered by the format check
    'EN_QUOTES', 'DASH_RULE', 'ELLIPSIS', 'PUNCTUATION_PARAGRAPH_END', 'SENTENCE_WHITESPACE',
    'EN_UNPAIRED_BRACKETS', 'EN_UNPAIRED_QUOTES', 'ENGLISH_WORD_REPEAT_BEGINNING_RULE',
    'EN_COMPOUNDS', 'EN_A_VS_AN', 'ARROWS', 'PLUS_MINUS', 'MULTIPLICATION_SIGN',
    'OK', 'TOO_LONG_SENTENCE', 'INTERJECTIONS_PUNCTUATION', 'EXTREME_ADJECTIVES',
    'PROFANITY', 'FILE_EXTENSIONS_CASE', 'SOME_FACULTY', 'EN_SPECIFIC_CASE',
    # style, not mistakes: the game writes "Pokemon"; characters talk casually
    'POKEMON', 'HALLOWEEN', 'GONNA', 'GOTTA', 'WANNA', 'CONSECUTIVE_SPACES', 'ENGLISH_WORD_REPEAT_RULE',
    'COMMA_COMPOUND_SENTENCE', 'MISSING_COMMA_AFTER_INTRODUCTORY_PHRASE', 'PRP_COMMA', 'HUH_COMMA',
    'SENT_START_CONJUNCTIVE_LINKING_ADVERB_COMMA', 'COMMA_TAG_QUESTION', 'SENT_START_ARE_NOT_ARENT_FORMAL',
}
LAUGH = re.compile(r"^(m?u?w?a?f?w?)?((ha|he|hi|ho|hu|ah|eh)+h*|e+r+|u+f+|y+o+|y+u+|hiho|hm+|zz+|aa+h*|o+h+)$", re.I)


def ignored_spelling(word, vocab):
    if re.search(r'PLAYERNAME|[%|$\d]', word):
        return True
    parts = [w for w in WORD_RE.findall(word)]
    if not parts:
        return True
    for p in parts:
        low = p.lower()
        if low in vocab or low.rstrip("'s") in vocab or LAUGH.match(p):
            continue
        if p.isupper() and len(p) >= 3:  # shouting and Pokemon cries (VAPOREONN)
            continue
        return False
    return True


def run_grammar(texts, vocab):
    try:
        import language_tool_python
    except ImportError:
        return None
    cache = {}
    if os.path.exists(CACHE):
        with open(CACHE, encoding='utf-8') as f:
            cache = json.load(f)
    todo = [t for t in texts if hashlib.sha1(t.encode()).hexdigest() not in cache]
    if todo:
        tool = language_tool_python.LanguageTool('en-US')
        for i, t in enumerate(todo):
            clean = re.sub(r'[{}]', '', t)
            found = []
            for m in tool.check(clean):
                if m.rule_id in IGNORED_RULES:
                    continue
                word = clean[m.offset:m.offset + m.error_length]
                found.append({'rule': m.rule_id, 'spelling': m.rule_issue_type == 'misspelling',
                              'word': word, 'message': m.message,
                              'fix': (m.replacements or [''])[0]})
            cache[hashlib.sha1(t.encode()).hexdigest()] = found
            if (i + 1) % 200 == 0:
                print(f'  grammar: {i + 1}/{len(todo)}', file=sys.stderr)
        tool.close()
        os.makedirs(os.path.dirname(CACHE), exist_ok=True)
        with open(CACHE, 'w', encoding='utf-8') as f:
            json.dump(cache, f)
    out = {}
    for t in texts:
        found = []
        for m in cache[hashlib.sha1(t.encode()).hexdigest()]:
            if m['rule'] in IGNORED_RULES or (m['spelling'] and ignored_spelling(m['word'], vocab)):
                continue
            found.append(m)
        out[t] = found
    return out


# ---------------------------------------------------------------- quests

def plural_forms(name):
    n = name.lower()
    forms = {n, n + 's', n + 'es'}
    if n.endswith('y'):
        forms.add(n[:-1] + 'ies')
    if n.endswith('f'):
        forms.add(n[:-1] + 'ves')
    return forms


GENERIC = {'small', 'large', 'empty', 'piece', 'pieces', 'some', 'with', 'from', 'pokemon', 'item', 'bottle',
            'full', 'old', 'new', 'box', 'bag', 'pack', 'the'}


def item_forms(name, plural):
    """Ways a line can name an item: the full name, its plural, or one of its distinctive words."""
    forms = plural_forms(name) | ({plural.lower()} if plural else set())
    for w in re.findall(r"[a-z']+", name.lower()):
        w = w.split("'")[0]
        if len(w) >= 4 and w not in GENERIC:
            forms |= plural_forms(w)
    return forms


def text_has(text, names):
    low = text.lower()
    return any(re.search(r'\b' + re.escape(n) + r'\b', low) for n in names)


def number_words(n):
    words = {1: 'one|a|an', 2: 'two', 3: 'three', 4: 'four', 5: 'five', 6: 'six', 7: 'seven', 8: 'eight',
             9: 'nine', 10: 'ten', 12: 'twelve', 15: 'fifteen', 20: 'twenty', 30: 'thirty', 50: 'fifty',
             100: 'hundred'}
    return words.get(n, '')


def has_count(text, n):
    if re.search(r'(?<![\d.])' + str(n) + r'(?![\d.])', text):
        return True
    w = number_words(n)
    return bool(w) and bool(re.search(r'\b(' + w + r')\b', text, re.I))


def talk(q, key):
    v = q.get(key)
    return v if isinstance(v, str) else ''


def auto_started():
    """Quest storages that a script or another quest starts, so their start lines are never said."""
    found = set()
    for root, _, fns in os.walk(DATA):
        for fn in fns:
            if fn.endswith('.lua'):
                with open(os.path.join(root, fn), encoding='utf-8', errors='replace') as f:
                    code = f.read()
                found.update(int(n) for n in re.findall(
                    r'doCreatureSetStorage\(\s*\w+\s*,\s*(\d+)\s*,\s*QUEST_STATUS\.STARTED', code))
                found.update(int(n) for n in re.findall(r'doPlayerStartQuest\([^()]*,\s*(\d+)\s*\)', code))
    return found


def check_quest(q, items, started_elsewhere=frozenset()):
    auto = q.get('blockStart') or q.get('storage') in started_elsewhere
    # a quest started elsewhere is explained by whoever starts it; its NPC only asks for it back
    text = ' '.join(talk(q, k) for k in ('talk_questStarting', 'talk_questStarted') +
                    (('talk_questFinishing',) if auto else ()))
    problems = []
    req = q.get('questRequest')
    kind = q.get('questType')
    pairs = []
    if kind == 0 and isinstance(req, list):
        pairs = [(req[i], req[i + 1]) for i in range(0, len(req) - 1, 2)]
    elif isinstance(req, dict) and '__fn' in req:
        pairs = [(int(a), int(b)) for a, b in
                 re.findall(r'getPlayerItemCount\(\s*cid\s*,\s*(\d+)\s*\)\s*>=\s*(\d+)', req['__fn'])]
    wanted = []
    if pairs:
        for item_id, count in pairs:
            name, plural = items.get(item_id, (f'item {item_id}', ''))
            wanted.append((f'{count} {plural if count > 1 and plural else name}', item_forms(name, plural), count))
    elif kind in (1, 3, 4) and isinstance(req, list) and len(req) >= 2:
        wanted.append((f'{req[1]} {req[0]}', plural_forms(req[0]), req[1]))
    elif kind == 2 and isinstance(req, int):
        wanted.append((f'{req} Pokemon in the Pokedex', set(), req))

    # for these types the NPC says what the quest checks when it is accepted (002-quest.lua)
    if kind in (0, 1, 2, 3, 4):
        wanted = []
    for label, forms, count in wanted:
        missing = []
        if forms and not text_has(text, forms):
            missing.append('what')
        if isinstance(count, int) and count > 1 and not has_count(text, count):
            missing.append('how many')
        if missing:
            problems.append(f"checks for **{label}**, the text does not say {' or '.join(missing)}")

    level = q.get('requiredLevel')
    for m in re.finditer(r'\blevel (\d+)', ' '.join(talk(q, k) for k in QUEST_TALK), re.I):
        if isinstance(level, int) and int(m.group(1)) != level:
            problems.append(f'text says level {m.group(1)}, the quest needs level {level}')
    # talk_questDone is never said (002-quest.lua); quests with blockStart are started elsewhere
    needed = ['talk_questFinishing', 'talk_questFinished', 'talk_questFinishFail']
    if not auto:
        needed = ['talk_questStarting', 'talk_questStarted'] + needed
    for k in needed:
        if q.get(k) is not None and not isinstance(q.get(k), str):
            continue  # built at runtime
        if not talk(q, k).strip():
            problems.append(f'empty `{k}`')
    return problems


# ---------------------------------------------------------------- per NPC

def answered_words(npc, sc, q_default, q_per, shared_groups):
    words = {'hi', 'hello', 'bye', 'farewell', 'yes', 'no', 'sim', 'nao'}
    groups = list(sc['groups'])
    code = sc['code']
    if 'doQuestTalk' in code or 'getCurrentQuest' in code:
        groups.append(frozenset(w.lower() for w in q_per.get(npc['name'], q_default)))
    if 'NpcBattle' in code or 'doTalkStart' in code or 'npcBattle' in (npc['script'] or ''):
        groups += shared_groups['battle']
    p = npc['params']
    if p.get('module_shop') == '1' or 'shop_buyable' in p or 'shop_sellable' in p:
        words.update({'trade', 'offer', 'buy', 'sell'})
    if p.get('module_keywords') == '1' and p.get('keywords'):
        words.update(w.strip().lower() for w in re.split(r'[;,]', p['keywords']) if w.strip())
    if p.get('travel_destinations'):
        words.update({'travel', 'destination', 'destinations', 'list', 'where'})
        for dest in p['travel_destinations'].split(';'):
            name = dest.split(',')[0].strip().lower()
            if name:
                words.add(name)
    if 'TravelModule' in code or 'travel' in (npc['script'] or '').lower():
        groups += shared_groups['travel']
    for g in groups:
        words.update(g)
    for var in set(re.findall(r'msgcontains\s*\(\s*\w+\s*,\s*([A-Za-z_]\w*)\s*\)', code)):
        m = re.search(r'\b' + var + r'\s*=\s*["\']([^"\']+)["\']', code)
        if m:
            words.add(m.group(1).lower())
    for m in re.finditer(r'keywords\s*=\s*\{([^}]*)\}', code):
        words.update(w.lower() for w in base.lua_strings(m.group(1)))
    if re.search(r'\[\s*(msg|message)(:lower\(\))?\s*\]', code):
        # words looked up in a table: any short string in the script may be one
        words.update(s.lower() for s in base.lua_strings(code) if 0 < len(s.split()) <= 3 and len(s) < 30)
    dynamic = bool(re.search(r'msgcontains\s*\(\s*\w+\s*,\s*[a-zA-Z_][\w.\[\]]*\s*\)', code)) or \
        bool(re.search(r'\[\s*(msg|message)(:lower\(\))?\s*\]', code)) or \
        'string.find(msg' in code or 'msg:find' in code or ('msg:lower()' in code and '==' in code)
    return words, dynamic


SHORT_ANSWERS = {'hi', 'hello', 'bye', 'farewell', 'yes', 'no', 'sim', 'nao'}

# checked by hand: these scripts take any word at that point in the talk
ANSWERS_ANY_WORD = {
    ('eggmove_remover.lua', 'none'),  # any word that is not a plate name means no plate
    ('quest_red.lua', 'journey'),  # after the first Pokemon, any word leads to the town choice
}


def dead_blue_words(texts, words, dynamic):
    """Clicking a blue word says it; NPCs match keywords anywhere in the message (npc/lib/npc.lua)."""
    dead = set()
    keys = [w for w in words if w and w not in SHORT_ANSWERS]
    for t in texts:
        for m in base.BRACED_RE.finditer(t):
            inner = m.group(1).strip().lower()
            if not inner or inner in words or any(k in inner for k in keys):
                continue
            # PLAYERNAME and other runtime placeholders
            if re.search(r'[|%$]', inner):
                continue
            dead.add(m.group(1).strip())
    return sorted(dead), dynamic


def audit(args):
    placed = base.placed_npcs()
    q_default, q_per = base.quest_keywords()
    quests = load_quests()
    items = load_items()
    monsters = load_monsters()

    scripts = {}
    for fn in os.listdir(base.SCRIPTS):
        if fn.endswith('.lua'):
            with open(os.path.join(base.SCRIPTS, fn), encoding='utf-8', errors='replace') as f:
                code = base.strip_comments(f.read())
            scripts[fn] = {'code': code, 'texts': dialogue_strings(code), 'groups': base.keyword_groups(code)}

    def lib_groups(path):
        with open(path, encoding='utf-8') as f:
            return base.keyword_groups(base.strip_comments(f.read()))

    shared_groups = {
        'battle': lib_groups(os.path.join(DATA, 'lib', 'ps', 'systems', '001-npcBattle.lua')),
        'travel': lib_groups(os.path.join(base.NPC_DIR, 'lib', 'npcsystem', 'modules.lua')),
    }

    npcs = [base.parse_npc(os.path.join(base.NPC_DIR, fn)) for fn in sorted(os.listdir(base.NPC_DIR))
            if fn.endswith('.xml')]
    by_name = {n['name']: n for n in npcs}
    users = collections.defaultdict(list)
    for npc in npcs:
        if placed.get(npc['name']):
            users[npc['script']].append(npc['name'])
    vocab = vocabulary(items, monsters, [n['name'] for n in npcs])

    # every line, with where it comes from; shared scripts and libraries count once
    lines = []  # (owner, source, text)
    for npc in npcs:
        if not placed.get(npc['name']):
            continue
        for k, v in npc['params'].items():
            if k.startswith('message_') or k.startswith('keyword_reply'):
                lines.append((npc['name'], k, v))
        sc = npc['script']
        if sc in scripts and len(users[sc]) == 1:
            lines += [(npc['name'], f'npc/scripts/{sc}', t) for t in scripts[sc]['texts']]
        for i, q in enumerate(quests.get(npc['name'], [])):
            for k in QUEST_TALK:
                if talk(q, k):
                    lines.append((npc['name'], f'quest {q.get("storage", i)} {k}', talk(q, k)))
    for sc, names in users.items():
        if sc in scripts and len(names) > 1:
            lines += [(f'npc/scripts/{sc}', f'{len(names)} NPCs', t) for t in scripts[sc]['texts']]
    for title, path, pattern in base.SHARED:
        with open(path, encoding='utf-8') as f:
            code = base.strip_comments(f.read())
        rel = os.path.relpath(path, os.path.join(ROOT, 'core', 'server', 'data'))
        lines += [(rel, title, t) for t in dialogue_strings(code)]

    seen = set()
    unique = []
    for line in lines:
        key = (line[0], line[2])
        if key not in seen:
            seen.add(key)
            unique.append(line)
    lines = unique

    grammar = None if args.no_grammar else run_grammar(sorted({t for _, _, t in lines}), vocab)

    findings = collections.defaultdict(lambda: collections.defaultdict(list))
    for owner, source, text in lines:
        f = findings[owner]
        pt = find_portuguese(text)
        if pt:
            f['portuguese'].append((source, text, ', '.join(pt)))
        for lo in find_leftovers(text):
            f['leftovers'].append((source, text, lo))
        for fm in find_format(text):
            f['format'].append((source, text, fm))
        if grammar is not None and not pt:
            for m in grammar.get(text, []):
                kind = 'spelling' if m['spelling'] else 'grammar'
                if m['spelling']:
                    note = f"\"{m['word']}\" → \"{m['fix']}\"" if m['fix'] else f"\"{m['word']}\""
                else:
                    note = m['message'] + (f" (\"{m['word']}\" → \"{m['fix']}\")" if m['fix'] else '')
                f[kind].append((source, text, note))

    quest_problems = []
    started_elsewhere = auto_started()
    for npc_name, qs in sorted(quests.items()):
        npc = by_name.get(npc_name)
        reason = None
        if not npc:
            reason = 'no NPC with this name'
        elif not placed.get(npc_name):
            reason = 'the NPC is not placed on the map'
        else:
            code = scripts.get(npc['script'], {}).get('code', '')
            if 'doQuestTalk' not in code and 'getCurrentQuest' not in code and 'Quest' not in code:
                reason = f"its script (`{npc['script']}`) has no quest talk"
        for q in qs:
            probs = check_quest(q, items, started_elsewhere)
            if probs or reason:
                quest_problems.append({'npc': npc_name, 'storage': q.get('storage'),
                                       'type': TYPE_NAMES.get(q.get('questType'), '?'),
                                       'unreachable': reason, 'problems': probs})

    dead = {}
    one_liners = []
    answers = {}
    for npc in npcs:
        if placed.get(npc['name']):
            sc = scripts.get(npc['script']) or {'code': '', 'texts': [], 'groups': []}
            answers[npc['name']] = answered_words(npc, sc, q_default, q_per, shared_groups)[0]

    def answered_elsewhere(word, me):
        low = word.lower()
        return sorted(n for n, ws in answers.items() if n != me and
                      (low in ws or any(k in low for k in ws if k and k not in SHORT_ANSWERS)))

    for npc in npcs:
        if not placed.get(npc['name']):
            continue
        sc = scripts.get(npc['script']) or {'code': '', 'texts': [], 'groups': []}
        texts = [v for k, v in npc['params'].items() if k.startswith('message_')] + sc['texts']
        for q in quests.get(npc['name'], []):
            texts += [talk(q, k) for k in QUEST_TALK if talk(q, k)]
        words, dynamic = answered_words(npc, sc, q_default, q_per, shared_groups)
        d, dyn = dead_blue_words(texts, words, dynamic)
        d = [w for w in d if (npc['script'], w.lower()) not in ANSWERS_ANY_WORD]
        if d:
            labelled = []
            for w in d:
                others = answered_elsewhere(w, npc['name'])
                if others and len(others) <= 3:
                    labelled.append(f"{w} (answered by {', '.join(others)})")
                else:
                    labelled.append(w)
            dead[npc['name']] = {'script': npc['script'], 'words': labelled, 'dynamic': dyn}
        has_more = (base.english(frozenset(words) - {'hi', 'hello', 'bye', 'farewell', 'yes', 'no'})
                    or npc['name'] in quests)
        if not has_more and not any(base.english(g) for g in sc['groups']):
            one_liners.append(npc)

    return {
        'lines': lines, 'findings': findings, 'quests': quest_problems, 'dead': dead,
        'one_liners': one_liners, 'placed': placed, 'npcs': npcs, 'users': users,
        'quest_count': sum(len(v) for v in quests.values()), 'grammar_run': grammar is not None,
    }


# ---------------------------------------------------------------- report

def md(text):
    return text.replace('|', '\\|').replace('\n', ' ')


def write_report(r, out):
    findings = r['findings']
    total = collections.Counter()
    for f in findings.values():
        for k, v in f.items():
            total[k] += len(v)
    owners = lambda kind: sorted(o for o, f in findings.items() if f.get(kind))  # noqa: E731
    live = [n for n in r['npcs'] if r['placed'].get(n['name'])]
    unreachable = [q for q in r['quests'] if q['unreachable']]
    # quests nobody can start are listed in their own section and not fixed
    mismatched = [q for q in r['quests'] if q['problems'] and not q['unreachable']]

    spell_words = collections.Counter()
    for f in findings.values():
        for _, _, note in f.get('spelling', []):
            spell_words[note] += 1

    L = [
        '# NPC conversation audit',
        '',
        'Generated by `scripts/npc_conversation_audit.py`; run it again after changing NPCs. It reads',
        'every line a placed NPC can say: the greeting and messages in its XML, its script, and its',
        'quests in `lib/ps/config/003-quest.lua`. Shared scripts and libraries are checked once, under',
        'their file name, since one fix there covers every NPC that uses them. The blue-word and yes/no',
        'audit is in [npc-audit.md](npc-audit.md).',
        '',
        '## Summary',
        '',
        '| | |',
        '| --- | --- |',
        f'| NPCs placed on the map | {len(live)} |',
        f'| Lines checked | {len(r["lines"])} |',
        f'| Quests | {r["quest_count"]} |',
        f'| Lines still in Portuguese | {total["portuguese"]} ({len(owners("portuguese"))} NPCs or files) |',
        f'| Tibia or old-server leftovers | {total["leftovers"]} ({len(owners("leftovers"))}) |',
        f'| Quests whose text does not match what they check | {len(mismatched)} |',
        f'| Quests nobody can start | {len(unreachable)} |',
        f'| NPCs with blue words that do nothing | {len(r["dead"])} |',
        f'| Formatting problems | {total["format"]} ({len(owners("format"))}) |',
    ]
    if r['grammar_run']:
        L += [f'| Spelling mistakes | {total["spelling"]} ({len(owners("spelling"))}) |',
              f'| Grammar problems | {total["grammar"]} ({len(owners("grammar"))}) |']
    else:
        L += ['| Spelling and grammar | not checked (LanguageTool not installed) |']
    L += [f'| One-liners (only a greeting so far) | {len(r["one_liners"])} |']
    rewrites_path = os.path.join(ROOT, 'docs', 'npc-rewrites.json')
    rewrites = []
    if os.path.exists(rewrites_path):
        with open(rewrites_path, encoding='utf-8') as f:
            rewrites = json.load(f)
        L.append(f'| Lines that read badly (reading review) | {len(rewrites)} |')
    L.append('')
    if rewrites:
        per = collections.Counter(x['npc'] for x in rewrites)
        L += ['## Reading review', '',
              'Every line was also read by a reviewer for broken or unclear English that the checks below miss',
              '("do you want help me?", "Likes no.", "where to flow"). The lines that need work, with a',
              'proposed rewrite each, are in [npc-rewrites.md](npc-rewrites.md). Most lines to fix:', '',
              ', '.join(f'{n} ({c})' for n, c in per.most_common(30)) + '.', '']

    def section(kind, title, intro, limit=None):
        os_ = owners(kind)
        if not os_:
            return
        L.extend([f'## {title}', '', intro, ''])
        for o in os_:
            items = findings[o][kind]
            L.append(f'**{o}**')
            L.append('')
            for source, text, note in items[:limit] if limit else items:
                L.append(f'- {note} - "{md(text)}" ({source})')
            if limit and len(items) > limit:
                L.append(f'- and {len(items) - limit} more')
            L.append('')

    section('portuguese', 'Still in Portuguese', 'Lines a player reads in Portuguese; the Portuguese words found are listed first.')
    section('leftovers', 'Tibia and old-server leftovers', 'Names, money and places from Tibia or the servers PokeVerse grew out of.')

    if mismatched:
        L += ['## Quests whose text does not match', '',
              'The quest checks for one thing and the NPC asks for another (or does not say how many).',
              'Checked against `questRequest`, the item names in `items.xml` and `requiredLevel`.',
              'Bring, defeat, catch and Pokedex quests are left out: when one is accepted the NPC says',
              'exactly what it checks ("(Mission: bring 20 onigiri.)"), so only custom quests are compared.',
              'Start lines of quests that a script or another quest starts are never said, so they may be empty.', '',
              '| NPC | Quest (storage) | Type | Problem |', '| --- | --- | --- | --- |']
        for q in mismatched:
            for p in q['problems']:
                L.append(f"| {q['npc']} | {q['storage']} | {q['type']} | {p} |")
        L.append('')
    if unreachable:
        L += ['## Quests nobody can start', '', '| NPC | Quests | Why |', '| --- | --- | --- |']
        per = collections.OrderedDict()
        for q in unreachable:
            per.setdefault((q['npc'], q['unreachable']), []).append(str(q['storage']))
        for (npc, why), st in per.items():
            L.append(f'| {npc} | {", ".join(st)} | {why} |')
        L.append('')

    if r['dead']:
        L += ['## Blue words that do nothing', '',
              'Words shown in {braces} that the NPC does not answer to: clicking them gets no reply.',
              '"Maybe" means the script also matches words it builds at runtime, so check by talking to it.', '',
              'NPCs sharing a script and the same words are one row.', '',
              '| NPC | Script | Blue words | |', '| --- | --- | --- | --- |']
        rows = collections.defaultdict(list)
        for name, d in r['dead'].items():
            rows[(d['script'], tuple(d['words']), d['dynamic'])].append(name)
        for (script, words, dyn), names in sorted(rows.items(), key=lambda kv: sorted(kv[1])[0]):
            who = names[0] if len(names) == 1 else f'{len(names)} NPCs: ' + ', '.join(sorted(names))
            L.append(f"| {who} | `{script}` | {md(', '.join(words))} | {'maybe' if dyn else ''} |")
        L.append('')

    section('format', 'Formatting', 'Unbalanced braces, double spaces and missing spaces after punctuation.')

    if r['grammar_run']:
        if spell_words:
            L += ['## Spelling', '', 'Most common misspellings (LanguageTool, with game names left out):', '',
                  '| Misspelling | Times |', '| --- | --- |']
            for w, n in spell_words.most_common(60):
                L.append(f'| {md(w)} | {n} |')
            L.append('')
        section('spelling', 'Spelling by NPC', 'Every misspelled line.')
        section('grammar', 'Grammar', "LanguageTool's grammar findings, with its suggested fix.")

    if r['one_liners']:
        L += ['## One-liners', '', 'NPCs that only greet: no keywords, quest or shop yet. Not a problem, just a list',
              'of NPCs whose dialogue is still to be written.', '']
        by_script = collections.defaultdict(list)
        for n in r['one_liners']:
            if n['name'] not in by_script[n['script'] or '(no script)']:
                by_script[n['script'] or '(no script)'].append(n['name'])
        for sc, names in sorted(by_script.items(), key=lambda kv: -len(kv[1])):
            L.append(f'- `{sc}` ({len(names)}): ' + ', '.join(sorted(names)))
        L.append('')

    with open(out, 'w', encoding='utf-8') as f:
        f.write('\n'.join(L))
    return total


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument('--out', default=os.path.join(ROOT, 'docs', 'npc-conversations.md'))
    ap.add_argument('--no-grammar', action='store_true')
    args = ap.parse_args()
    r = audit(args)
    total = write_report(r, args.out)
    print(f"{len(r['lines'])} lines, {r['quest_count']} quests; "
          + ', '.join(f'{k} {v}' for k, v in sorted(total.items()))
          + f"; quest problems {len(r['quests'])}, dead blue words {len(r['dead'])}, one-liners {len(r['one_liners'])}")


if __name__ == '__main__':
    main()
