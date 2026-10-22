#!/usr/bin/env python3
"""DS-era (Gen 4/5) Pokemon look for the world map: every item placed on map.otbm is repainted
in flat cel steps lit from the top left, with a 1 px outline in a dark of its own colour.

Ground and borders get seamless grass, sand and water textures, a tufted grass lip and sand
sunk under it; objects are repainted whole (all their sprites at once, so shading runs across
them) along clean palettes, and the bigger ones drop a soft shadow. The houses come from
house_reskin.py and the crates from box_reskin.py, both in the same colours. Left as they are:
the Pokemon Center and Mart and the rest of the custom Pokemon building art they are drawn in,
and anything that can be picked up (potions, balls, berries keep their icons).

    ds_world.py --preview out.png [--box x0,y0,x1,y1]   render with the new art, data.spr untouched
    ds_world.py --write-spr                             put the new art into data.spr

The original data.spr is tagged backup/data-spr-before-ds-style.
"""
import argparse
import collections
import os
import pickle
import re
import struct
import sys

import numpy as np
from PIL import Image, ImageFilter

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
sys.path.insert(0, os.path.join(os.path.dirname(HERE), 'mapper'))
import box_reskin  # noqa: E402
import house_reskin as h  # noqa: E402
import pvmap  # noqa: E402
from render import Renderer  # noqa: E402

GROUND, BORDER, PICKUPABLE = 0, 1, 17
# the Pokemon Center and Mart and the custom building art around them, already in the style
REFERENCE = set(range(22084, 23251)) | {11873, 18746}
# server ids from here on are PokeVerse's own art (signs, machines, furniture, statues), already modern
CUSTOM_FROM = 11390
ITEMS_XML = os.path.join(os.path.dirname(h.ITEMS), 'items.xml')
CACHE = '/tmp/ds_world_items.pkl'
BEDS = '/tmp/ds_world_beds.pkl'

GRASS = [(56, 112, 80), (96, 176, 88), (112, 184, 80), (120, 192, 112), (128, 208, 112), (152, 224, 120)]
PATH = [(152, 120, 96), (176, 152, 104), (200, 184, 128), (208, 192, 136), (216, 200, 136), (232, 220, 168)]
DIRT = [(104, 68, 40), (120, 82, 48), (132, 92, 54), (144, 100, 60), (152, 108, 66), (168, 124, 80)]
WATER = [(32, 96, 160), (40, 128, 192), (64, 168, 224), (112, 196, 236), (200, 216, 216), (240, 248, 248)]
FOLIAGE = [(14, 72, 64), (24, 96, 64), (50, 135, 99), (72, 164, 86), (104, 192, 88), (150, 222, 110)]
TRUNK = [(72, 48, 32), (104, 72, 48), (144, 104, 72), (184, 136, 96), (210, 170, 124)]
ROCK = [(72, 80, 96), (104, 112, 136), (128, 152, 160), (160, 192, 200), (200, 216, 216), (236, 244, 244)]
GOLD = [(150, 96, 20), (216, 160, 48), (240, 216, 104), (252, 240, 160)]
RED = [(112, 24, 32), (168, 40, 40), (216, 72, 56), (240, 120, 96), (250, 180, 160)]
OUTLINE = {'green': (16, 48, 32), 'wood': (48, 28, 20), 'dirt': (48, 28, 20), 'stone': (48, 56, 64),
           'water': (16, 48, 96), 'yellow': (96, 56, 16), 'red': (72, 16, 24)}
OBJECT_RAMPS = {'green': FOLIAGE, 'wood': TRUNK, 'dirt': TRUNK, 'stone': ROCK, 'water': WATER,
                'yellow': GOLD, 'red': RED}


ICE = [(72, 128, 168), (120, 184, 216), (168, 220, 240), (208, 240, 250), (240, 252, 255)]
OBJECT_RAMPS['ice'] = ICE
OBJECT_RAMPS['water'] = [(24, 36, 96), (36, 64, 152), (52, 104, 200), (84, 148, 224), (140, 196, 240), (216, 236, 248)]
OBJECT_RAMPS['crimson'] = [(40, 10, 14), (72, 16, 20), (104, 24, 26), (136, 36, 32), (168, 56, 44), (200, 92, 64)]
OUTLINE['crimson'] = (32, 8, 12)
OUTLINE['ice'] = (48, 96, 128)


def classify(rgb):
    r, g, b = rgb[..., 0] / 255, rgb[..., 1] / 255, rgb[..., 2] / 255
    mx, mn = np.maximum(np.maximum(r, g), b), np.minimum(np.minimum(r, g), b)
    d = mx - mn
    s = np.where(mx > 0, d / np.maximum(mx, 1e-6), 0)
    dd = np.maximum(d, 1e-6)
    hue = np.where(mx == r, ((g - b) / dd) % 6, np.where(mx == g, (b - r) / dd + 2, (r - g) / dd + 4)) * 60
    hue = np.where(d < 1e-6, 0, hue)
    mat = np.full(r.shape, 'stone', object)
    mat[(hue >= 65) & (hue < 170) & (s > 0.15)] = 'green'
    mat[(hue >= 170) & (hue < 260) & (s > 0.2)] = 'water'
    mat[(hue >= 40) & (hue < 65) & (s > 0.45) & (mx > 0.55)] = 'yellow'
    brown = (((hue < 45) | (hue >= 330)) & (s > 0.15)) | ((hue >= 15) & (hue < 50) & (s > 0.08))
    mat[brown] = 'wood'
    mat[brown & (s > 0.6) & (hue < 15) & (mx > 0.45)] = 'red'
    mat[(hue >= 260) & (hue < 330) & (s > 0.2)] = 'other'
    return mat


def lum(rgb):
    return rgb[..., 0] * 0.3 + rgb[..., 1] * 0.59 + rgb[..., 2] * 0.11


def ramp_at(ramp, s, steps=False):
    """Colour along a ramp, s in 0..1: blended, or in flat cel steps."""
    if steps:
        r = np.array(ramp, float)
        return r[np.clip((np.clip(s, 0, 0.999) * len(r)).astype(int), 0, len(r) - 1)]
    r = np.array(ramp, float)
    t = np.clip(s, 0, 1) * (len(r) - 1)
    i = np.minimum(t.astype(int), len(r) - 2)
    f = (t - i)[..., None]
    return r[i] * (1 - f) + r[i + 1] * f


def blurf(a, radius, pad=0):
    if pad:
        a = np.pad(a, pad, mode='edge')
    im = Image.fromarray(np.clip(a * 255, 0, 255).astype(np.uint8))
    out = np.array(im.filter(ImageFilter.GaussianBlur(radius))).astype(float) / 255
    return out[pad:-pad, pad:-pad] if pad else out


def grain(seed, density):
    """Sparse single pixels, scattered without lining up, so a repeated tile does not show."""
    rng = np.random.default_rng(seed)
    return rng.random((32, 32)) < density


def grass_texture():
    s = np.full((32, 32), 0.75)                   # GRASS[4], the sheet's (128, 208, 112)
    s[grain(1, 0.10)] = 0.6                      # (120, 192, 112) grain
    rng = np.random.default_rng(2)
    for _ in range(7):                           # short light blades leaning right
        x, y = rng.integers(0, 32, 2)
        for k in range(rng.integers(2, 4)):
            s[(y - k) % 32, (x + k) % 32] = 0.9
        s[(y + 1) % 32, x % 32] = 0.45
    return ramp_at(GRASS, s, steps=True)


def dirt_texture():
    s = np.full((32, 32), 0.55)                   # DIRT[3], the shared colour map's dirt (144, 100, 60)
    s[grain(3, 0.12)] = 0.4
    s[grain(4, 0.06)] = 0.7
    return ramp_at(DIRT, s, steps=True)


def water_texture():
    s = np.full((32, 32), 0.45)
    s[grain(6, 0.05)] = 0.38
    rng = np.random.default_rng(5)
    for _ in range(3):
        x, y = rng.integers(0, 32, 2)
        for k in range(4):
            s[y % 32, (x + k) % 32] = 0.7 if 0 < k < 3 else 0.55
    return ramp_at(WATER, s, steps=True)


TEX = {'green': grass_texture(), 'dirt': dirt_texture(), 'wood': dirt_texture(), 'water': water_texture()}


def shift(m, dy, dx, fill=False):
    out = np.full_like(m, fill)
    H, W = m.shape
    ys, yd = (slice(0, H - dy), slice(dy, H)) if dy >= 0 else (slice(-dy, H), slice(0, H + dy))
    xs, xd = (slice(0, W - dx), slice(dx, W)) if dx >= 0 else (slice(-dx, W), slice(0, W + dx))
    out[yd, xd] = m[ys, xs]
    return out


def near(m, steps=1):
    out = m.copy()
    for _ in range(steps):
        out = out | shift(out, 1, 0) | shift(out, -1, 0) | shift(out, 0, 1) | shift(out, 0, -1)
    return out


def drop_specks(m, size=8):
    """Clear little islands, the loose pixels Tibia's ragged borders leave."""
    seen = np.zeros_like(m)
    out = m.copy()
    H, W = m.shape
    for y0, x0 in zip(*np.nonzero(m)):
        if seen[y0, x0]:
            continue
        comp, todo = [], [(y0, x0)]
        seen[y0, x0] = True
        while todo:
            y, x = todo.pop()
            comp.append((y, x))
            for q in ((y + 1, x), (y - 1, x), (y, x + 1), (y, x - 1)):
                if 0 <= q[0] < H and 0 <= q[1] < W and m[q] and not seen[q]:
                    seen[q] = True
                    todo.append(q)
        touches = any(y in (0, H - 1) or x in (0, W - 1) for y, x in comp)
        if len(comp) < size and not touches:
            for p in comp:
                out[p] = False
    return out


FRINGE = [(64, 144, 80), (96, 176, 88)]          # grass edge: dark rim, then mid green
SUNK = [(88, 56, 36, 255), (112, 76, 44, 230), (128, 88, 52, 150)]  # dirt under the grass lip


def paint_ground(a):
    """A ground or border sprite in the DS look: each material laid with its seamless texture;
    grass borders get a smooth tufted lip and the dirt beside them sinks in a darker band."""
    rgb, alpha = a[..., :3].astype(float), a[..., 3]
    op = alpha > 0
    mat = classify(rgb)
    border = not op.all()
    n = max(op.sum(), 1)
    if (mat[op] == 'green').sum() < 0.15 * n and (mat[op] == 'water').sum() < 0.4 * n:
        mat[op] = 'dirt'
        if border:
            op = drop_specks(blurf(op.astype(float), 1.0, pad=4) > 0.55, 12)
            mat[op] = 'dirt'
    if border:
        g = op & (mat == 'green')
        if g.any():
            g = blurf(g.astype(float), 1.3, pad=4) > 0.5
            g = drop_specks(g)
            yy, xx = np.mgrid[0:32, 0:32]
            tuft = near(g) & ~g & ((xx * 3 + yy * 5) % 7 == 0)   # little regular tufts on the lip
            g = g | tuft
            rest = op & ~np.isin(mat, ['green']) & ~g
            op = g | rest
            mat = np.where(g, 'green', mat)
    res = np.zeros((32, 32, 4), float)
    res[..., 3] = op * 255
    for k, tex in TEX.items():
        sel = op & (mat == k)
        res[sel, :3] = tex[sel]
    other = op & ~np.isin(mat, list(TEX))
    if other.any():
        res[other, :3] = relight(a, other, 'stone')[other]
    for k in ('green', 'water'):
        m = op & (mat == k)
        if not m.any():
            continue
        outside = ~m if border else (~m & op)
        d1 = m & near(outside)
        d2 = m & ~d1 & near(d1)
        if k == 'green':
            res[d1, :3] = FRINGE[0]
            res[d2, :3] = FRINGE[1]
        else:
            res[d1, :3] = WATER[4]
            res[d2, :3] = WATER[3]
    if border:
        g = op & (mat == 'green')
        if g.any():
            ring, prev = g, g
            for c in SUNK:
                band = near(prev) & ~ring & ~op
                res[band] = c
                ring = ring | band
                prev = band
    return np.clip(res, 0, 255).astype(np.uint8)


def mat_fill(mat, op):
    """Material of the nearest opaque pixel, for pixels the smoothed outline adds."""
    m = mat.copy()
    for _ in range(2):
        for dy, dx in ((1, 0), (-1, 0), (0, 1), (0, -1)):
            src = shift(m, dy, dx, 'stone')
            okk = shift(op, dy, dx)
            take = ~op & okk
            m[take] = src[take]
    return m


def despeckle(mat, op):
    """Pixels with fewer than three neighbours of their material take the object's main material."""
    kinds, counts = np.unique(mat[op], return_counts=True)
    main = kinds[counts.argmax()]
    same = np.zeros(mat.shape, int)
    for dy in (-1, 0, 1):
        for dx in (-1, 0, 1):
            if dy or dx:
                same += shift(mat, dy, dx, '') == mat
    out = mat.copy()
    out[op & (same < 3) & ~np.isin(mat, ['yellow', 'red', 'other'])] = main
    return out


def relight(img, sel, kind, ramp=None):
    """Smooth modern shading: the original's light and dark clusters, softened, plus a rounded
    volume lit from the top left, laid along a clean ramp."""
    ramp = ramp or OBJECT_RAMPS.get(kind, ROCK)
    L = lum(img[..., :3].astype(float)) / 255
    w = sel.astype(float)
    rad = 1.6 if kind == 'green' else 0.5
    Ls = blurf(L * w, rad, pad=4) / np.maximum(blurf(w, rad, pad=4), 1e-3)
    vals = Ls[sel]
    lo, hi = np.percentile(vals, 4), np.percentile(vals, 96)
    n = np.clip((Ls - lo) / max(hi - lo, 1e-3), 0, 1)
    vol = np.pad(blurf(w, 3.0, pad=8), 2, mode='edge')
    lightdir = vol[4:, 4:] - vol[:-4, :-4]
    s = (0.12 + 0.62 * n + 0.9 * lightdir) if kind == 'green' else (0.08 + 0.8 * n + 0.5 * lightdir)
    if kind == 'stone':
        s = 0.05 + 0.62 * n + 0.5 * lightdir
    if kind == 'green':
        # each leaf clump lit on its top-left rim, shaded on the far side
        p = np.pad(Ls, 2, mode='edge')
        s = s + 1.4 * (Ls - p[:-4, :-4])
    out = np.zeros(img.shape[:2] + (3,))
    out[...] = ramp_at(ramp, s, steps=True)
    return out


def paint_object(img):
    """A whole multi-tile item at once, so the shading runs across its sprites without seams."""
    a = img.copy()
    op = a[..., 3] > 0
    if not op.any():
        return a
    mat = despeckle(classify(a[..., :3].astype(float)), op)
    cyan = hue_of(a[..., :3].astype(float)) < 205
    mat[(mat == 'water') & cyan & (blurf(lum(a[..., :3].astype(float)) / 255, 1.5, pad=4) > 0.55)] = 'ice'
    px = a[op][:, :3].astype(float)
    if lum(px.mean(0)) < 95 and px[:, 0].mean() > 1.8 * px[:, 1].mean():    # dark red rock stays dark red
        mat[op & np.isin(mat, ['wood', 'dirt', 'red', 'yellow'])] = 'crimson'
    out = a.astype(float)
    for k in set(mat[op].tolist()):
        sel = op & (mat == k)
        if k == 'other' or sel.sum() < 3:
            continue
        out[sel, :3] = relight(a, sel, k)[sel]
    edge = op & (shift(~op, 1, 0) | shift(~op, 0, 1) | shift(~op, -1, 0) | shift(~op, 0, -1))
    small = op.sum() < 260
    for k, c in OUTLINE.items():
        out[edge & (mat == k), :3] = (GRASS[0] if k == 'green' else OBJECT_RAMPS.get(k, ROCK)[0]) if small else c
    out[edge & ~np.isin(mat, list(OUTLINE)), :3] *= 0.5
    if op.sum() >= 260:
        sh = shift(op, 3, 2) & ~op
        out[sh] = (24, 48, 32, 70)
    return np.clip(out, 0, 255).astype(np.uint8)



def map_items():
    """Client ids of every item placed on the map, top-level items of each tile."""
    if os.path.exists(CACHE) and os.path.getmtime(CACHE) > os.path.getmtime(h.MAP):
        return pickle.load(open(CACHE, 'rb'))
    otb = pvmap.Otb(h.ITEMS)
    data = open(h.MAP, 'rb').read()
    found = set()
    for ev, typ, depth, a, b, _ in pvmap.walk(data):
        if ev != 'open':
            continue
        if typ in (pvmap.TILE, pvmap.HOUSETILE):
            item = pvmap.parse_tile_props(pvmap.unescape(data[a:b]), typ == pvmap.HOUSETILE)[4]
            if item is not None:
                found.add(item)
        elif typ == pvmap.ITEM and depth == 4:
            found.add(struct.unpack_from('<H', pvmap.unescape(data[a:a + 4]), 0)[0])
    cids = {otb.client_id(i) for i in found}
    pickle.dump(cids, open(CACHE, 'wb'))
    return cids


def custom_art(otb):
    """Client ids of PokeVerse's own items, except nature, which follows the world style."""
    nature = set()
    for line in open(ITEMS_XML, encoding='utf-8', errors='replace'):
        m = re.search(r'<item (?:fromid="(\d+)" toid="(\d+)"|id="(\d+)")[^>]*name="([^"]*)"', line)
        if m and re.search(r'\b(tree|bush|grass|hedge)\b', m.group(4), re.I):
            a = int(m.group(1) or m.group(3))
            nature.update(range(a, int(m.group(2) or a) + 1))
    out = {otb.client_id(i) for i in otb.items if i >= CUSTOM_FROM and i not in nature}
    tibia = {otb.client_id(i) for i in otb.items if i < CUSTOM_FROM}    # custom entries reusing Tibia art
    out.discard(None)
    return out - tibia - set(PAVING)


def map_usage():
    """({border client id: Counter of the grounds it is laid on}, {client id: share of uses below floor 7})."""
    if os.path.exists(BEDS) and os.path.getmtime(BEDS) > os.path.getmtime(h.MAP):
        return pickle.load(open(BEDS, 'rb'))
    otb, dat = pvmap.Otb(h.ITEMS), pvmap.Dat(h.DAT)
    data = open(h.MAP, 'rb').read()
    beds = collections.defaultdict(collections.Counter)
    under, total = collections.Counter(), collections.Counter()
    ground = area = None
    for ev, typ, depth, a, b, _ in pvmap.walk(data):
        if ev != 'open':
            continue
        if typ == pvmap.TILE_AREA:
            area = struct.unpack_from('<HHB', pvmap.unescape(data[a:b]), 0)
            continue
        cid = None
        if typ in (pvmap.TILE, pvmap.HOUSETILE):
            item = pvmap.parse_tile_props(pvmap.unescape(data[a:b]), typ == pvmap.HOUSETILE)[4]
            ground = cid = otb.client_id(item) if item is not None else None
        elif typ == pvmap.ITEM and depth == 4:
            cid = otb.client_id(struct.unpack_from('<H', pvmap.unescape(data[a:a + 4]), 0)[0])
            t = dat.things.get(cid)
            if t and GROUND in t[0]:
                ground = cid
            elif t and BORDER in t[0] and ground is not None:
                beds[cid][ground] += 1
        if cid is not None:
            total[cid] += 1
            under[cid] += area[2] > 7
    out = dict(beds), {c: under[c] / total[c] for c in total}
    pickle.dump(out, open(BEDS, 'wb'))
    return out


def ds_pixels(a, cave=False, crumbs=False):
    """Ground and edges off the textures: one fixed colour map for every item, so each original colour
    lands on the same DS colour wherever it is and neighbouring pieces stay seamless."""
    op = a[..., 3] > 0
    full = op.all()
    raw = a[..., :3].astype(float)
    rgb = 0.5 * raw + 0.5 * box_blur(raw, full, 1)
    L = lum(rgb)
    mx, mn = rgb.max(-1), rgb.min(-1)
    sat = (mx - mn) / np.maximum(mx, 1)
    hue = hue_of(rgb)
    out = a.copy()
    done = ~op

    def put(sel, ramp, cuts):
        nonlocal done
        sel = sel & ~done
        out[sel, :3] = np.array(ramp)[np.searchsorted(cuts, L[sel])]
        done = done | sel

    put((hue >= 185) & (hue <= 250) & (sat > 0.35) & (L < 150), WATER[1:4], [45, 125])
    put((hue >= 165) & (hue <= 215) & (sat > 0.12) & (L >= 150), [ICE[1], ICE[2], ICE[4]], [160, 228])
    put((hue >= 65) & (hue <= 165) & (sat > 0.25), GRASS, [50, 80, 110, 150, 185])
    put(sat < 0.15, GRAYS[:5] + [SNOW[1], SNOW[2], SNOW[3]], [40, 75, 110, 145, 175, 200, 222])
    earth = (hue >= 12) & (hue <= 50) & (sat >= 0.25) & (sat <= 0.78)
    if crumbs:      # Tibia's dark dirt crumbs run redder than its dirt
        earth = earth | ((hue < 12) & (sat >= 0.25) & (sat <= 0.78) & (L < 100))
    put(earth & (L < 235), DS_EARTH, [45, 60, 100, 140, 228])
    rest = ~done
    if rest.any():
        v = mx[rest] / 255
        lv = np.array([0.24, 0.38, 0.52, 0.66, 0.8, 0.92, 1.0])
        q = lv[np.searchsorted((lv[:-1] + lv[1:]) / 2, v)]
        col = np.clip(rgb[rest] * (q / np.maximum(v, 1e-3))[:, None], 0, 255)
        out[rest, :3] = (col // 8 * 8).astype(np.uint8)   # snap so near-equal shades merge into one flat colour
    return despeckle_px(out, op, full)


def hue_of(rgb):
    r, g, b = rgb[..., 0], rgb[..., 1], rgb[..., 2]
    mx, mn = rgb.max(-1), rgb.min(-1)
    d = np.maximum(mx - mn, 1e-6)
    hh = np.where(mx == r, ((g - b) / d) % 6, np.where(mx == g, (b - r) / d + 2, (r - g) / d + 4))
    return np.where(mx - mn < 1e-6, 0, hh * 60)


def house_sprites(dat):
    art = h.originals(dat, None)
    h.STYLE.update({'tile': 'tiles', 'width': 16, 'eave': 3,
                    'roof': [(88, 24, 32), (140, 40, 40), (168, 52, 40), (184, 56, 40), (200, 80, 48), (228, 120, 80)],
                    'wood': [(56, 36, 28), (80, 56, 48), (112, 88, 72), (142, 112, 91), (167, 135, 114)],
                    'plaster': [(200, 200, 192), (224, 224, 216), (240, 240, 232), (250, 250, 246)],
                    'glass': [(40, 96, 160), (72, 144, 184), (112, 184, 208), (220, 240, 248)],
                    'outline': (40, 16, 16)})
    return h.build(dat, art)


NATURAL = [(105.7, 65.9, 28.7), (62.4, 121.6, 31.3), (33.8, 73.1, 31.4), (38.0, 75.3, 164.1)]

# close to grass/dirt in colour but really floors, roofs, frames and jungle leaves
NOT_NATURAL = {194, 482, 484, 489, 490, 970, 971, 972, 973, 978, 1152, 6171, 7348, 8619, 8620,
               13067, 15377, 15379, 15380, 20328, 20375, 20376, 20377} | set(range(8308, 8317))


def grass_ground(t, rgba):
    px = [rgba(s) for s in t[8] if s and rgba(s) is not None]
    px = np.concatenate([p[p[..., 3] > 0][:, :3] for p in px]).astype(float)
    return (classify(px[None])[0] == 'green').mean() > 0.6


def natural(t, rgba):
    """Grass, dirt and water ground; paving, floors, roofs, snow and lava stay as they are."""
    px = [img[img[..., 3] > 0][:, :3] for img in (rgba(s) for s in t[8] if s) if img is not None]
    px = np.concatenate(px).astype(float) if px else np.zeros((0, 3))
    if len(px) == 0:
        return False
    mat = classify(px[None])[0]
    wet = mat == 'water'
    ice = wet.any() and lum(px[wet]).mean() >= 140          # light cyan is ice, not water
    deep = wet & ~ice
    shore = 0.1 <= deep.mean() <= 0.9 and (~deep & (mat != 'green')).mean() >= 0.1
    if GROUND in t[0]:
        mean = px.mean(0)
        if shore:
            return 'mixed'
        if (mat == 'green').mean() > 0.6 or deep.mean() > 0.6:
            return True
        return min(np.linalg.norm(mean - np.array(ref)) for ref in NATURAL) < 28 and px.std(0).mean() < 30
    if (mat == 'green').mean() >= 0.15:
        return True
    if deep.mean() >= 0.15:
        return 'mixed'
    return np.linalg.norm(px.mean(0) - np.array(NATURAL[0])) < 28


ROAD = [(88, 88, 104), (152, 152, 168), (176, 176, 192), (200, 200, 216), (224, 224, 232)]    # city paving
COBBLE = [(72, 72, 88), (124, 124, 140), (148, 148, 164), (172, 172, 186), (198, 198, 210)]
WOODEN = [(80, 44, 28), (132, 84, 48), (172, 118, 70), (206, 154, 96), (232, 192, 132)]  # logs and planks
GRAYS = [(48, 48, 64), (80, 80, 100), (112, 112, 136), (144, 144, 168), (176, 176, 198), (208, 208, 224),
         (236, 238, 248)]
# dark steps for dirt, close to Tibia's own brown so paths, crumbs and cave floors agree; light steps for sand
DS_EARTH = [(80, 52, 32), (112, 76, 44), (144, 100, 60), (176, 136, 88), (232, 220, 168), (244, 236, 196)]
CAVE = [(56, 36, 28), (84, 56, 40), (112, 76, 52), (140, 100, 68), (168, 128, 88), (196, 160, 112)]
SNOW = [(168, 184, 216), (200, 216, 236), (224, 234, 246), (240, 246, 252), (252, 254, 255)]
ROCKY = [(72, 56, 48), (116, 96, 82), (144, 124, 102), (168, 148, 120), (192, 174, 144)]    # Pewter's stony ground
HUT_ROOF = range(9408, 9416)                     # the far slope of the small huts beside the Pokemon Centers
# rims and ridges laid over the flat roof tiles
ROOF_EDGES = list(range(8621, 8633)) + [8643, 8644] + [1157, 1160, 1162, 1163, 1164, 1165, 1166, 1167, 1170, 1172, 1173, 1174, 1175, 1176]
ROOF_TILES = {1158, 1159, 1161, 1168, 1169, 1171, 8619, 8620}
MADE_EDGES = {cid: 7593 for cid in range(7605, 7617)}     # {edge: its ground}, Pewter's brown cobble
STEPS = [0.12, 0.38, 0.62, 0.85]
LIFT = [0.6, 0.82, 1.0, 1.14, 1.28]


def tone(t, rgba):
    """Luminance range and mean colour over all of an item's sprites, so its variants share the same steps."""
    px = [img[img[..., 3] > 0][:, :3] for img in (rgba(s) for s in t[8] if s) if img is not None]
    px = np.concatenate(px).astype(float)
    L = lum(px)
    return np.percentile(L, 5), np.percentile(L, 95), px.mean(0)


def smooth(a, full, size=3):
    r = size // 2
    p = np.pad(a, [(r, r), (r, r)] + [(0, 0)] * (a.ndim - 2), mode='wrap' if full else 'edge')
    st = np.stack([p[dy:dy + 32, dx:dx + 32] for dy in range(size) for dx in range(size)])
    return np.median(st, 0)


def paint_floor(a, lo, hi, mean, ramp=None):
    """Paving, floors and other made ground: the original pattern in flat cel steps."""
    rgb = a[..., :3].astype(float)
    full = (a[..., 3] > 0).all()
    k = np.searchsorted(STEPS, np.clip((smooth(lum(rgb), full) - lo) / max(hi - lo, 1), 0, 1))
    out = a.copy()
    if ramp is not None:
        out[..., :3] = np.array(ramp)[k]
    else:
        base = smooth(rgb, full)
        want = lum(mean) * np.array(LIFT)[k]
        out[..., :3] = np.clip(base * (want / np.maximum(lum(base), 1))[..., None], 0, 255)
    return out


def paving(ramp, w, hgt, stagger, seed):
    """Seamless stone paving: flat faces, a lit top-left rim, a shaded bottom-right rim and dark grout."""
    y, x = np.mgrid[0:32, 0:32]
    u = (x + (w // 2) * ((y // hgt) % 2) * stagger) % w
    v = y % hgt
    k = np.full((32, 32), 2)
    k[(u == w - 2) | (v == hgt - 2)] = 1
    k[(u == 0) | (v == 0)] = 3
    k[(u == w - 1) | (v == hgt - 1)] = 0
    k[grain(seed, 0.03) & (k == 2)] = 1
    k[grain(seed + 1, 0.02) & (k == 2)] = 3
    return np.array(ramp)[k]


PAVING = {429: paving(ROAD, 16, 16, False, 11), 10790: paving(ROAD, 16, 16, False, 13)}
PAVING.update({cid: paving(COBBLE, 16, 8, True, 20 + cid) for cid in range(500, 505)})


def paint_flat_roof(a):
    out = a.copy()
    pal = h.STYLE['roof']
    for y in range(32):
        for x in range(32):
            out[y, x, :3] = pal[int(np.clip(h.shingle_shade(x, y % 8, y // 8), 0, len(pal) - 1))]
    return out


def paint_roof_edge(a):
    out = paint_flat_roof(a)
    op = a[..., 3] > 0
    rim = op & ~(shift(op, 1, 0, True) & shift(op, -1, 0, True) & shift(op, 0, 1, True) & shift(op, 0, -1, True))
    out[rim, :3] = h.STYLE['roof'][1]
    return out


def recolor_ground(a):
    """Shore and snow edges: every pixel keeps its place, only the colours move onto the DS ramps."""
    rgb = a[..., :3].astype(float)
    op = a[..., 3] > 0
    L = smooth(lum(rgb), op.all())
    mat = classify(rgb)
    out = a.copy()
    water = op & (mat == 'water') & (L < 140)
    out[water, :3] = np.array(WATER)[np.searchsorted([60, 110, 170], L[water]) + 1]
    foam = op & ~water & (L >= 170) & (mat != 'yellow')
    out[foam, :3] = np.array(SNOW)[np.searchsorted([185, 205, 225, 240], L[foam])]
    green = op & (mat == 'green')
    out[green, :3] = np.array(GRASS)[np.searchsorted([60, 90, 120, 150], L[green]) + 1]
    sand = op & ~water & ~foam & ~green & np.isin(mat, ['yellow', 'wood', 'red'])
    out[sand, :3] = np.array(PATH)[np.searchsorted([90, 130, 160, 190, 215], L[sand])]
    rest = op & ~water & ~foam & ~green & ~sand
    out[rest, :3] = np.array(COBBLE)[np.searchsorted([70, 100, 130, 160], L[rest])]
    return out


def made_ground(t, rgba, like=None):
    """{sid: art} for town floors with a hand-tuned ramp (dark stone, wood), else None;
    edges pass their ground as like, to be shaded in its exact steps."""
    lo, hi, mean = tone(like or t, rgba)
    m = lum(mean)
    sat = (mean.max() - mean.min()) / max(mean.max(), 1)
    if m < 60 and sat < 0.35:
        ramp = ROCKY
    elif sat > 0.3 and m < 175 and mean[0] > mean[1] > mean[2] and mean[1] > 0.55 * mean[0]:
        ramp = WOODEN
    else:
        return None
    return {sid: despeckle_px(paint_floor(rgba(sid), lo, hi, mean, ramp), rgba(sid)[..., 3] > 0,
                              (rgba(sid)[..., 3] > 0).all())
            for sid in t[8] if sid and rgba(sid) is not None}


def box_blur(a, full, n=3):
    for _ in range(n):
        p = np.pad(a, [(1, 1), (1, 1)] + [(0, 0)] * (a.ndim - 2), mode='wrap' if full else 'edge')
        a = sum(p[dy:dy + 32, dx:dx + 32] for dy in range(3) for dx in range(3)) / 9
    return a


def majority(img, op, full, passes=2):
    """Each pixel takes the colour most of its 3x3 neighbours have: no lone specks, clean flat shapes."""
    key = img[..., 0].astype(np.int64) << 16 | img[..., 1].astype(np.int64) << 8 | img[..., 2]
    for _ in range(passes):
        vals = np.unique(key[op])
        if len(vals) < 2:
            break
        counts = np.stack([box_blur(((key == v) & op).astype(float), full, 1) for v in vals])
        best = vals[counts.argmax(0)]
        key = np.where(op, best, key)
    out = img.copy()
    out[..., 0], out[..., 1], out[..., 2] = key >> 16 & 255, key >> 8 & 255, key & 255
    return out


def despeckle_px(img, op, full, passes=2):
    """Pixels with fewer than two same-coloured neighbours take the commonest colour around them;
    one-pixel lines survive, lone specks do not."""
    key = img[..., 0].astype(np.int64) << 16 | img[..., 1].astype(np.int64) << 8 | img[..., 2]
    for _ in range(passes):
        vals = np.unique(key[op])
        if len(vals) < 2:
            break
        counts = np.stack([box_blur(((key == v) & op).astype(float), full, 1) * 9 for v in vals])
        own = np.take_along_axis(counts, np.searchsorted(vals, key)[None].clip(0, len(vals) - 1), 0)[0]
        key = np.where(op & (own < 2.5), vals[counts.argmax(0)], key)
    out = img.copy()
    out[..., 0], out[..., 1], out[..., 2] = key >> 16 & 255, key >> 8 & 255, key & 255
    return out


def dirt_like(t, rgba):
    """Natural earth (not grass, not water): drawn with the shared colour map so every variant matches."""
    px = np.concatenate([p[p[..., 3] > 0][:, :3] for p in (rgba(s) for s in t[8] if s) if p is not None]).astype(float)
    m = classify(px[None])[0]
    return (m == 'water').mean() < 0.6 and (m == 'green').mean() < 0.6


def dark_dirt(t, rgba):
    """Dark brown earth overall, as Tibia's dirt crumbs and dark dirt edges are."""
    px = np.concatenate([p[p[..., 3] > 0][:, :3] for p in (rgba(s) for s in t[8] if s) if p is not None]).astype(float)
    mean = px.mean(0)
    sat = (mean.max() - mean.min()) / max(mean.max(), 1)
    return 5 <= hue_of(mean[None])[0] <= 25 and 0.3 <= sat <= 0.75 and lum(mean) < 110


def grass_edge(t, rgba):
    px = np.concatenate([p[p[..., 3] > 0][:, :3] for p in (rgba(s) for s in t[8] if s) if p is not None]).astype(float)
    return (classify(px[None])[0] == 'green').mean() >= 0.15


def dirt_ground(t, rgba):
    return not grass_ground(t, rgba)


def build():
    """{sprite id: 32x32 RGBA} of the new art."""
    dat, spr = pvmap.Dat(h.DAT), pvmap.Spr(h.SPR)
    new = dict(house_sprites(dat))
    new.update({sid: np.array(im) for sid, im in box_reskin.sprites().items()})
    items = map_items()
    custom = custom_art(pvmap.Otb(h.ITEMS))
    keep, tibia = set(), set()
    for cid, t in dat.things.items():
        (keep if cid in REFERENCE or cid in custom else tibia).update(s for s in t[8] if s)
    keep -= tibia - {s for c in REFERENCE if c in dat.things for s in dat.things[c][8]}
    raw = {}

    def rgba(sid):
        if sid not in raw:
            px = spr.rgba(sid)
            raw[sid] = np.frombuffer(px, np.uint8).reshape(32, 32, 4).copy() if px else None
        return raw[sid]

    beds, under = map_usage()

    grassy = {}

    def on_grass(cid):
        """Grass edges laid over other grass have no dirt to sink into."""
        bed = beds.get(cid)
        if not bed:
            return False
        for g in bed:
            if g not in grassy:
                t = dat.things.get(g)
                grassy[g] = bool(t) and any(s and rgba(s) is not None for s in t[8]) and grass_ground(t, rgba)
        return sum(n for g, n in bed.items() if grassy[g]) >= 0.7 * sum(bed.values())

    grounds, objects = [], []
    for cid in sorted(dat.things):
        t = dat.things[cid]
        if cid in REFERENCE or cid in custom:
            continue
        if GROUND in t[0] or BORDER in t[0]:
            grounds.append((cid, t))
        else:
            objects.append(t)
    for cid, t in grounds:
        free = [sid for sid in t[8] if sid and sid not in new and sid not in keep and rgba(sid) is not None]
        if not free:
            continue
        if cid in PAVING:
            art = {sid: np.dstack([PAVING[cid], rgba(sid)[..., 3]]).astype(np.uint8) for sid in free}
        elif cid in ROOF_TILES:
            art = {sid: paint_flat_roof(rgba(sid)) for sid in free}
        else:
            cave = under.get(cid, 0) > 0.7
            kind = natural(t, rgba) if cid not in NOT_NATURAL else False
            kind = kind if kind == 'mixed' else bool(kind)
            edge = BORDER in t[0] and grass_edge(t, rgba)
            art = None
            if kind is True and edge:
                art = {sid: (recolor_ground if on_grass(cid) else paint_ground)(rgba(sid)) for sid in free}
            elif kind is True and GROUND in t[0] and grass_ground(t, rgba):
                art = {sid: paint_ground(rgba(sid)) for sid in free}
            elif kind is True and GROUND in t[0] and not dirt_like(t, rgba):
                art = {sid: paint_ground(rgba(sid)) for sid in free}
            elif kind is False and not cave and GROUND in t[0]:
                art = made_ground(t, rgba)
            elif cid in MADE_EDGES:
                art = made_ground(t, rgba, dat.things[MADE_EDGES[cid]])
            crumbs = not cave and BORDER in t[0] and dark_dirt(t, rgba)
            art = art or {sid: ds_pixels(rgba(sid), cave, crumbs) for sid in free}
        new.update({sid: img for sid, img in art.items() if sid in free})
    for cid in ROOF_EDGES:
        for sid in dat.things[cid][8]:
            if sid and sid not in new and rgba(sid) is not None:
                new[sid] = paint_roof_edge(rgba(sid))
    for cid in HUT_ROOF:
        t = dat.things[cid]
        art = {sid: rgba(sid) for sid in t[8] if sid and sid not in new and rgba(sid) is not None}
        open_edges = np.dstack([np.full((t[2] * 32, t[1] * 32), 9, np.uint8), np.zeros((t[2] * 32, t[1] * 32), np.uint8)])
        for pat, img in h.compose(t, art).items():
            done = h.paint_roof(img, False, -1, open_edges)
            for pp, idx, x, y in h.layout(t):
                sid = t[8][idx] if idx < len(t[8]) else 0
                if pp == pat and sid in art:
                    new[sid] = done[y:y + 32, x:x + 32].copy()
    for t in objects:
        sprites = t[8]
        if all(not s or s in new or s in keep for s in sprites):
            continue
        art = {s: rgba(s) for s in sprites if s and rgba(s) is not None}
        for p, img in h.compose(t, art).items():
            done = paint_object(img)
            for pp, idx, x, y in h.layout(t):
                sid = sprites[idx] if idx < len(sprites) else 0
                if pp == p and sid in art and sid not in new and sid not in keep:
                    new[sid] = done[y:y + 32, x:x + 32].copy()
    spr.f.close()
    return new


def preview(new, box, out):
    r = Renderer(h.ITEMS, h.DAT, h.SPR)
    r.sprite_images.update({sid: Image.fromarray(img, 'RGBA') for sid, img in new.items()})
    x0, y0, x1, y1 = box
    tiles = pvmap.read_region(h.MAP, x0 - 2, y0 - 2, x1 + 10, y1 + 10, range(0, 8))
    r.render(tiles, x0, y0, x1, y1, 7).convert('RGB').save(out)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--preview')
    ap.add_argument('--box', default=','.join(map(str, h.VIEW)))
    ap.add_argument('--write-spr', action='store_true', help='put the new art into data.spr')
    args = ap.parse_args()
    new = build()
    print('%d sprites repainted' % len(new))
    if args.preview:
        preview(new, tuple(int(v) for v in args.box.split(',')), args.preview)
    if args.write_spr:
        h.write_spr(new)


if __name__ == '__main__':
    main()
