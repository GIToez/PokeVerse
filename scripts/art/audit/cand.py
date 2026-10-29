import pickle, numpy as np
from frames import padv_frame, silhouette
from ourpage import frame as our_frame
from pairs import page, chunks
padv = pickle.load(open('padv.pkl', 'rb'))
res, names = pickle.load(open('near.pkl', 'rb'))
def crop(im):
    return np.asarray(im.crop(im.getbbox()), dtype=np.int16)
def same(a, b):
    a, b = crop(a), crop(b)
    H, W = max(a.shape[0], b.shape[0]), max(a.shape[1], b.shape[1])
    best = 0
    for A, B in ((a, b), (b, a)):
        pa = np.zeros((H, W, 4), np.int16); pb = pa.copy()
        pa[H - A.shape[0]:, :A.shape[1]] = A
        for dx in range(W - B.shape[1] + 1):
            pb[:] = 0
            pb[H - B.shape[0]:, dx:dx + B.shape[1]] = B
            m = (pa[..., 3] > 0) | (pb[..., 3] > 0)
            best = max(best, float((np.abs(pa - pb).max(-1)[m] < 32).mean()))
    return best
keep, nsame, seen = [], 0, set()
for s, sid, look in res[:700]:
    th = padv_frame(sid, padv[sid]['g'])
    if same(th, our_frame(look)) > 0.7:
        nsame += 1
        continue
    sil = silhouette(th)
    if sil in seen:
        continue
    seen.add(sil)
    keep.append((s, sid, look))
pickle.dump(keep, open('cand.pkl', 'wb'))
import glob, os
for f in glob.glob('pg/cand_*.png'): os.remove(f)
print(nsame, len(keep), chunks([('padv', sid, look) for _, sid, look in keep], 'pg/cand', per=120))
