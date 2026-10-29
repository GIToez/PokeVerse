"""6500 pack sheets: 4 directions across (each with its colour mask next to it on colourable
sheets), frames down. Tile keys of the base layer and the best matching look of ours."""
import collections, glob, os, pickle, re
import numpy as np
from PIL import Image
from ours import key
from frames import PADV, PADV_ROOT, PACK

D = PACK
ours, lab = pickle.load(open('ours.pkl', 'rb'))
index = collections.defaultdict(set)
for look, o in ours.items():
    for k in o['keys']:
        index[k].add(look)


def layout(w, h):
    c = w // 4
    if c and h % c == 0 and c % 32 == 0:
        return c, 1
    return w // 8, 2


res = {}
for path in glob.glob(D + 'outfit_*_.png'):
    n = int(re.search(r'outfit_(\d+)_', path).group(1))
    img = np.array(Image.open(path).convert('RGBA'))
    h, w = img.shape[:2]
    c, layers = layout(w, h)
    if c < 32 or c % 32:
        res[n] = dict(c=c, layers=layers, base=set(), best=None, share=0, bad=True)
        continue
    base = set()
    for d in range(4):
        x0 = d * layers * c
        for y0 in range(0, h - c + 1, c):
            for ty in range(c // 32):
                for tx in range(c // 32):
                    k = key(img[y0 + ty * 32:y0 + ty * 32 + 32, x0 + tx * 32:x0 + tx * 32 + 32])
                    if k:
                        base.add(k)
    votes = collections.Counter()
    for k in base:
        for look in index.get(k, ()):
            votes[look] += 1
    best = votes.most_common(1)[0] if votes else (None, 0)
    res[n] = dict(c=c, layers=layers, frames=h // c, base=base, best=best[0],
                  share=best[1] / len(base) if base else 0)
pickle.dump(res, open('pack.pkl', 'wb'))
cnt = collections.Counter('ours' if r['share'] >= 0.5 else 'partial' if r['share'] > 0.1 else 'new' for r in res.values())
print(cnt, sum(1 for r in res.values() if r.get('bad')))
