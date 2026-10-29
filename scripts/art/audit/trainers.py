import collections, csv, json, pickle, re
from frames import *

padv = pickle.load(open('padv.pkl', 'rb'))
pack = pickle.load(open('pack.pkl', 'rb'))
fold = {}
for r in csv.DictReader(open('rename_plan.csv')):
    m = re.search(r'#(\d+)', r['name'])
    if m:
        fold[int(m.group(1))] = r['folder']
master = {}
for r in csv.DictReader(open('master_full.csv')):
    n = int(re.search(r'outfit_(\d+)_', r['Pack file']).group(1))
    master[n] = r

cands = []
padv_packs = set()
for sid, r in sorted(padv.items()):
    g = r['g']
    if g['layers'] != 2 or r['share'] >= 0.5:
        continue
    if r['packshare'] >= 0.5:
        padv_packs.add(r['pack'])
    im = padv_frame(sid, g)
    cands.append(dict(src='padv', id=sid, addons=g['py'] > 1, mount=g['pz'] > 1, im=im, sil=silhouette(im)))
for n, r in sorted(pack.items()):
    if r.get('bad') or r['share'] >= 0.5 or n in padv_packs:
        continue
    m = master.get(n, {})
    is_trainer = fold.get(n) == '11 Trainer outfits' or (m.get('Use') == 'outfit' and fold.get(n) != '15 Exact duplicates'
                                                          and not m.get('Status', '').startswith('duplicate'))
    if not is_trainer:
        continue
    im = pack_frame(n, r['c'], r['layers'])
    cands.append(dict(src='pack', id=n, addons=False, mount=False, im=im, sil=silhouette(im), colour=r['layers'] == 2))

groups = collections.OrderedDict()
for c in cands:
    if c['sil'] is None:
        continue
    groups.setdefault(c['sil'], []).append(c)
uniq = []
for sil, cs in groups.items():
    cs.sort(key=lambda c: (c['src'] != 'padv', not c['addons']))
    best = dict(cs[0])
    best['copies'] = len(cs)
    uniq.append(best)
print('candidates', len(cands), 'unique', len(uniq),
      collections.Counter((u['src'], u['addons']) for u in uniq))
pickle.dump([{k: v for k, v in u.items() if k != 'im'} for u in uniq], open('trainers.pkl', 'wb'))
