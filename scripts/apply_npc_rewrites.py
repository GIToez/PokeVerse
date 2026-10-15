#!/usr/bin/env python3
"""Applies docs/npc-rewrites.json to the NPC files, the quest config and the shared libraries.

Each entry names where its line is (an XML message of an NPC, an NPC script, a quest field
or a library) and the old and new text. Lines are matched by their exact old text inside a
Lua string or XML attribute, so running it twice changes nothing the second time. Keys of
pt_br.loc that were the old English text are renamed to the new one, so translations stay.

  python3 scripts/apply_npc_rewrites.py            # apply
  python3 scripts/apply_npc_rewrites.py --dry-run  # only report
"""

import argparse
import collections
import html
import json
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DATA = os.path.join(ROOT, 'core', 'server', 'data')
NPC_DIR = os.path.join(DATA, 'npc')
QUESTS = os.path.join(DATA, 'lib', 'ps', 'config', '003-quest.lua')
PT_BR = os.path.join(ROOT, 'core', 'server', 'pt_br.loc')
REWRITES = os.path.join(ROOT, 'docs', 'npc-rewrites.json')

STRING_RE = re.compile(r'"((?:[^"\\\n]|\\.)*)"|\'((?:[^\'\\\n]|\\.)*)\'|\[\[(.*?)\]\]', re.S)


def unescape(s):
    return s.replace("\\'", "'").replace('\\"', '"')


def literal(content, quote):
    if quote == '[[':
        return '[[' + content + ']]'
    return quote + content.replace(quote, '\\' + quote) + quote


def replace_literals(code, old, new, start=0, end=None, limit=None):
    """Replaces Lua string literals whose text is `old` between start and end."""
    end = len(code) if end is None else end
    out, pos, n = [], 0, 0
    for m in STRING_RE.finditer(code, start, end):
        groups = m.groups()
        idx = next(i for i, g in enumerate(groups) if g is not None)
        if unescape(groups[idx]) != old:
            continue
        quote = ['"', "'", '[['][idx]
        if quote == '[[' and ']]' in new:
            continue
        out.append(code[pos:m.start()])
        out.append(literal(new, quote))
        pos = m.end()
        n += 1
        if limit and n >= limit:
            break
    out.append(code[pos:])
    return ''.join(out), n


def npc_files():
    by_name = collections.defaultdict(list)
    for fn in os.listdir(NPC_DIR):
        if fn.endswith('.xml'):
            path = os.path.join(NPC_DIR, fn)
            with open(path, encoding='utf-8', errors='replace') as f:
                m = re.search(r'<npc\s+name="([^"]*)"', f.read())
            if m:
                by_name[html.unescape(m.group(1))].append(path)
    return by_name


def xml_attr(s):
    return html.escape(s, quote=True).replace('&#x27;', "'")


class Files:
    def __init__(self):
        self.text = {}
        self.encoding = {}

    def get(self, path):
        if path not in self.text:
            with open(path, 'rb') as f:
                raw = f.read()
            try:
                self.text[path], self.encoding[path] = raw.decode('utf-8'), 'utf-8'
            except UnicodeDecodeError:
                self.text[path], self.encoding[path] = raw.decode('latin-1'), 'latin-1'
            self.original = getattr(self, 'original', {})
            self.original[path] = self.text[path]
        return self.text[path]

    def set(self, path, text):
        self.text[path] = text

    def changed(self):
        return [p for p in self.text if self.text[p] != self.original[p]]

    def save(self):
        for p in self.changed():
            with open(p, 'w', encoding=self.encoding[p], newline='') as f:
                f.write(self.text[p])


def apply(entries, files, by_name):
    done, missing = [], []
    for e in entries:
        owner, where, old, new = e['npc'], e['where'], e['text'], e['rewrite']
        if old == new:
            continue
        n = 0
        if where.startswith(('message_', 'keyword_reply')):
            for path in by_name.get(owner, []):
                xml = files.get(path)
                pattern = re.compile(r'(<parameter\s+key="' + re.escape(where) + r'"\s+value=")([^"]*)(")')
                def sub(m):
                    nonlocal n
                    if html.unescape(m.group(2)) == old:
                        n += 1
                        return m.group(1) + xml_attr(new) + m.group(3)
                    return m.group(0)
                files.set(path, pattern.sub(sub, xml))
        elif where.startswith('quest '):
            _, storage, key = where.split(' ', 2)
            code = files.get(QUESTS)
            # several NPCs share storage numbers, so look inside this NPC's block first
            block = re.search(r'\[\s*"' + re.escape(owner) + r'"\s*\]\s*=\s*\{', code)
            block_end = re.compile(r'\n\s*\[\s*"[^"]+"\s*\]\s*=\s*\{').search(code, block.end()) if block else None
            start = block.end() if block else 0
            stop = block_end.start() if block_end else len(code)
            for m in re.compile(r'\bstorage\s*=\s*' + re.escape(storage) + r'\s*,').finditer(code, start, stop):
                nxt = re.compile(r'\bstorage\s*=\s*\d+\s*,').search(code, m.end())
                end = nxt.start() if nxt else len(code)
                k = re.compile(r'\b' + re.escape(key) + r'\s*=\s*').search(code, m.end(), end)
                if k:
                    # the audit lists a line once per NPC; it may be in several of its quests
                    code, found = replace_literals(code, old, new, k.end(), end, limit=1)
                    n += found
            files.set(QUESTS, code)
        else:
            rel = where if where.startswith('npc/scripts/') else owner
            path = os.path.join(DATA, rel)
            if os.path.isfile(path):
                code, n = replace_literals(files.get(path), old, new)
                files.set(path, code)
        (done if n else missing).append(e)
    return done, missing


def rename_translations(done):
    if not os.path.exists(PT_BR):
        return 0
    renames = {}
    for e in done:
        renames.setdefault(e['text'].replace('\n', '\\n'), e['rewrite'].replace('\n', '\\n'))
    with open(PT_BR, encoding='latin-1', newline='') as f:
        lines = f.read().split('\n')
    n = 0
    for i, line in enumerate(lines):
        key, sep, value = line.partition('@')
        if sep and key in renames:
            lines[i] = renames[key] + '@' + value
            n += 1
    with open(PT_BR, 'w', encoding='latin-1', newline='') as f:
        f.write('\n'.join(lines))
    return n


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument('--dry-run', action='store_true')
    args = ap.parse_args()
    with open(REWRITES, encoding='utf-8') as f:
        entries = json.load(f)
    files = Files()
    done, missing = apply(entries, files, npc_files())
    changed = files.changed()
    print(f'{len(done)} of {len(entries)} lines rewritten in {len(changed)} files')
    for e in missing:
        print(f"  not found: {e['npc']} / {e['where']}: {e['text'][:80]}", file=sys.stderr)
    if not args.dry_run:
        files.save()
        print(f'{rename_translations(done)} pt_br.loc keys renamed')


if __name__ == '__main__':
    main()
