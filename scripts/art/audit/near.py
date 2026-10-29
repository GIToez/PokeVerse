import pickle, collections
import numpy as np
from PIL import Image
from frames import padv_frame
from ourpage import frame as our_frame, lab

padv = pickle.load(open('padv.pkl', 'rb'))


def feat(im):
    bb = im.getbbox()
    if not bb:
        return None
    im = im.crop(bb)
    a = np.asarray(im.convert('RGBA'), dtype=np.float32) / 255
    m = a[..., 3] > 0.5
    if m.sum() < 30:
        return None
    hsv = np.asarray(im.convert('RGB').convert('HSV'), dtype=np.float32) / 255
    px = hsv[m]
    sat = px[:, 1] > 0.2
    h1 = np.histogram(px[sat, 0], 12, (0, 1), weights=px[sat, 1])[0]
    h2 = np.histogram(px[:, 2], 6, (0, 1))[0]
    h = np.concatenate([h1 / max(1, m.sum()), h2 / m.sum()])
    s = np.asarray(Image.fromarray((m * 255).astype(np.uint8)).resize((12, 12), Image.BILINEAR), dtype=np.float32) / 255
    s = s.flatten()
    v = np.concatenate([h * 3, s / np.linalg.norm(s), [im.width / 64, im.height / 64]])
    return v / np.linalg.norm(v)


ours = {}
for look, v in lab.items():
    names = [n for a, n in v if a == 'pokemon']
    if not names or any(w in names[0] for w in ('Shiny', 'Cloned', 'RC ', 'Test')):
        continue
    f = feat(our_frame(look))
    if f is not None:
        ours[look] = (names[0], f)
keys = list(ours)
M = np.stack([ours[k][1] for k in keys])

res = []
for sid, r in padv.items():
    if r['g']['layers'] != 1 or r['share'] >= 0.5 or r['packshare'] >= 0.5:
        continue
    try:
        f = feat(padv_frame(sid, r['g']))
    except Exception:
        continue
    if f is None:
        continue
    s = M @ f
    j = int(s.argmax())
    res.append((float(s[j]), sid, keys[j]))
res.sort(reverse=True)
pickle.dump((res, {k: ours[k][0] for k in keys}), open('near.pkl', 'wb'))
print(len(ours), len(res), [round(r[0], 3) for r in res[::300]])
