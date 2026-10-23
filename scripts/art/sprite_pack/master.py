"""Builds the master list from rows6.json, codes.json and names/page_NN.json.

master_full.csv  every pack file with its status (duplicate / already ours / to keep) and name
master_review.csv one row per code (distinct shape still to import), for the Google Sheet
"""
import csv, glob, json, re, collections

rows = {r['pack']: r for r in json.load(open('rows6.json'))}
codes = json.load(open('codes.json'))
names = {}
for f in sorted(glob.glob('names/page_*.json')):
    names.update(json.load(open(f)))

species = {}
for s in csv.DictReader(open('species.csv')):
    species[s['identifier'].replace('-', '')] = (int(s['id']), int(s['generation_id']))
species.update({'nidoranf': (29, 1), 'nidoranm': (32, 1), 'mrmime': (122, 1), 'farfetchd': (83, 1),
                'hooh': (250, 2), 'mimejr': (439, 4), 'porygonz': (474, 4), 'typenull': (772, 7)})


def dex(name):
    base = re.split(r'[\s(?]', name.strip(), 1)[0].lower()
    base = re.sub(r'[^a-z]', '', base)
    return species.get(base, ('', ''))


def ours_name(r):
    if not r['labels']:
        return '', ''
    n, k = r['labels'].split(';')[0].split('|')
    return n, k.split('/')[0]


review = []
code_of = {}
for code, packs in codes.items():
    n = names.get(code, ['', '', ''])
    for p in packs:
        code_of[p] = code
    d, g = dex(n[0]) if n[0] else ('', '')
    form_gen = {'mega': 6, 'primal': 6, 'alolan': 7, 'galarian': 8, 'hisuian': 8, 'paldean': 9, 'gigantamax': 8}
    for form, fg in form_gen.items():
        if g and form in n[0].lower():
            g = max(g, fg)
    first = rows[packs[0]]
    review.append(dict(code=code, page=int(code[1:].split('-')[0]), name=n[0], use=n[1], confidence=n[2],
                       dex=d, gen=g, colourable='yes' if first['mask_px'] > 40 else '',
                       files=' '.join('outfit_%d_.png' % p for p in packs)))

with open('master_review.csv', 'w', newline='') as f:
    w = csv.writer(f)
    w.writerow(['Code', 'Page', 'Name (my guess)', 'Use', 'Confidence', 'Dex', 'Gen', 'Colourable',
                'YOUR NAME / FIX', 'YOUR USE / FIX', 'Files'])
    for r in sorted(review, key=lambda r: (r['page'], int(r['code'].split('-')[1]))):
        w.writerow([r['code'], r['page'], r['name'], r['use'], r['confidence'], r['dex'], r['gen'],
                    r['colourable'], '', '', r['files']])

with open('master_full.csv', 'w', newline='') as f:
    w = csv.writer(f)
    w.writerow(['Pack file', 'Status', 'Code', 'Name', 'Use', 'Our outfit id'])
    for p, r in sorted(rows.items()):
        if r['status'] == 'keep':
            if p in code_of:
                n = names.get(code_of[p], ['', '', ''])
                w.writerow(['outfit_%d_.png' % p, 'to import', code_of[p], n[0], n[1], ''])
            else:
                n, k = ours_name(r)
                if r['kind'].startswith('player'):
                    n, k = 'player outfit', 'outfit'
                w.writerow(['outfit_%d_.png' % p, 'to import', '', n, k, r['ours'] or ''])
        else:
            n, k = ours_name(rows[int(r['status'].split()[-1].strip(')'))] if r['status'].startswith('duplicate') else r)
            w.writerow(['outfit_%d_.png' % p, r['status'], '', n, k, r['ours'] or ''])

c = collections.Counter(r['confidence'] for r in review)
print('codes', len(review), 'named pages', len(glob.glob('names/page_*.json')), c)
gens = collections.Counter(r['gen'] for r in review if r['gen'])
print('by gen', sorted(gens.items()))
