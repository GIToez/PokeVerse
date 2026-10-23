import json, collections, sys
import numpy as np
from PIL import Image
sys.path.insert(0, '/workspace/scripts/art')
sys.path.insert(0, '/tmp/sprites6500/work')
from new_pokemon_art_preview import Things
from match import key

D = '/tmp/sprites6500/6500 sprite pokemon/'
rows = json.load(open('rows.json'))
lab = {int(k): v for k, v in json.load(open('labels.json')).items()}
t = Things()

kind_of = {}
for oid, ls in lab.items():
    ks = {l.split('|')[1].split('/')[0] for l in ls}
    kind_of[oid] = ks
tile_kinds = collections.defaultdict(set)
for oid, ks in kind_of.items():
    if oid - 1 >= len(t.outfits):
        continue
    for s in set(t.outfits[oid - 1][-1]):
        r = t.spr.rgba(s)
        k = key(r) if r else None
        if k:
            tile_kinds[k] |= ks
rider_tiles = {k for k, ks in tile_kinds.items() if ks & {'ride', 'fly', 'surf', 'dive'} and 'walk' not in ks}

MASK = np.array([[255, 0, 0], [0, 255, 0], [0, 0, 255], [255, 255, 0]])
for r in rows:
    im = Image.open(D + 'outfit_%d_.png' % r['pack']).convert('RGBA')
    a = np.array(im)
    px = a[a[..., 3] > 0][:, :3]
    mask = sum(int((px == c).all(1).sum()) for c in MASK) if len(px) else 0
    r['mask_px'] = mask
    rt = 0
    for y in range(0, im.height - 31, 32):
        for x in range(0, im.width - 31, 32):
            k = key(a[y:y + 32, x:x + 32].tobytes())
            if k in rider_tiles:
                rt += 1
    r['rider_tiles'] = rt
    if r['labels']:
        r['kind'] = r['labels'].split(';')[0].split('|')[1].split('/')[0]
        r['name'] = r['labels'].split(';')[0].split('|')[0]
    elif mask > 40:
        r['kind'], r['name'] = 'player outfit (colourable)', ''
    elif rt:
        r['kind'], r['name'] = 'rider (ride/fly/surf)', ''
    elif r['ours']:
        r['kind'], r['name'] = 'ours, unused', ''
    else:
        r['kind'], r['name'] = 'new - needs naming', ''
json.dump(rows, open('rows2.json', 'w'))
print(collections.Counter(r['kind'] for r in rows))
