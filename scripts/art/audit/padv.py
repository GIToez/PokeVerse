"""PAdventures creatures: tile keys per sheet (base frames = first px rows) and the best matching
look of ours by share of base tiles."""
import collections, json, pickle
import numpy as np
from PIL import Image
from ours import key
from frames import PADV, PADV_ROOT, PACK

D = PADV
meta = json.load(open(PADV_ROOT + 'data/metadata.json'))['things']
ours, lab = pickle.load(open('ours.pkl', 'rb'))
index = collections.defaultdict(set)
for look, o in ours.items():
    for k in o['keys']:
        index[k].add(look)


def tiles(img, x0, y0, w, h):
    out = []
    for ty in range(h):
        for tx in range(w):
            k = key(img[y0 + ty * 32:y0 + ty * 32 + 32, x0 + tx * 32:x0 + tx * 32 + 32])
            if k:
                out.append(k)
    return out


res = {}
for sid, v in meta.items():
    if v['cat'] != 'creature':
        continue
    g = v['g']
    img = np.array(Image.open(D + sid + '.png').convert('RGBA'))
    W, H = g['w'] * 32, g['h'] * 32
    cols, rows = img.shape[1] // W, img.shape[0] // H
    base, extra = set(), set()
    for r in range(rows):
        for c in range(cols):
            ks = tiles(img, c * W, r * H, g['w'], g['h'])
            (base if r < g['px'] else extra).update(ks)
    votes = collections.Counter()
    for k in base:
        for look in index.get(k, ()):
            votes[look] += 1
    best = votes.most_common(1)[0] if votes else (None, 0)
    res[int(sid)] = dict(g=g, rows=rows, cols=cols, base=base, extra=extra, best=best[0],
                         share=best[1] / len(base) if base else 0)
pickle.dump(res, open('padv.pkl', 'wb'))
c = collections.Counter()
for r in res.values():
    c['ours' if r['share'] >= 0.5 else 'partial' if r['share'] > 0.1 else 'new'] += 1
print(c)
