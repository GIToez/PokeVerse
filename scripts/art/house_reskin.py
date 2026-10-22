#!/usr/bin/env python3
"""Pokemon Center style roof and walls for the red-roofed timber-frame houses (Pallet and the rest).

Every roof and wall piece keeps its outline; only the paint changes. Roof shingles become clean
rows in the Pokemon Center's red ramp, lit from the original's slope shading. Plaster becomes a
flat cream with a shadow under the timber, timber a three-tone brown, and window panes light blue.

    house_reskin.py --before out.png     the Pallet house by the Pokemon Center as it is now
    house_reskin.py --mockup out.png     the same with the new roof and walls
    house_reskin.py --write-spr          puts the new sprites into data.spr

The original sprites are kept in art/sprites/house/original.png (with sprites.txt), so the art
can be rebuilt after data.spr carries the new paint.
"""
import argparse
import os
import sys
from collections import deque

import numpy as np
from PIL import Image, ImageFilter

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, os.path.join(ROOT, 'scripts/mapper'))
import pvmap  # noqa: E402
from render import Renderer  # noqa: E402

MAP = os.path.join(ROOT, 'core/server/data/world/map.otbm')
ITEMS = os.path.join(ROOT, 'core/server/data/items/items.otb')
DAT = os.path.join(ROOT, 'core/client-legacy/data/things/data.dat')
SPR = os.path.join(ROOT, 'core/client-legacy/data/things/data.spr')
OUT = os.path.join(ROOT, 'art/sprites/house')
VIEW = (3318, 797, 3352, 824)  # two Pallet houses and the Pokemon Center, floor 7
TOWN = (3232, 772, 3350, 850)  # all of Pallet, where the roof outline is measured

# client ids
ROOF_ITEMS = [8620] + list(range(8633, 8643)) + list(range(5033, 5041)) + list(range(9416, 9424))
# pieces of roofs that slope east and west: their shingle rows run north-south
VERTICAL_ROOF = set(range(5033, 5037)) | set(range(9416, 9424))
# a step of the red ramp per piece, so the slopes read apart: the narrow west slopes and the
# lower wing's roof in shade, the ridge in the light
TONES = {5033: -1, 5034: -1, 9416: -1, 9417: -1, 9422: 1, 9423: 1, 5037: -1, 5038: -1}
DORMERS = [5043, 5044]
# walls running north-south show their east face, a step darker than the south faces
EAST_WALLS = {1281, 1286, 1288, 5148, 5149, 5150, 5153, 5154, 6436, 6438}
CORNERS = {1285, 1287, 1289, 1291}  # south face on the left tile, east face on the right
WINDOW_ITEMS = list(range(6435, 6439))
WALL_ITEMS = list(range(1281, 1292)) + list(range(5145, 5155))
# stone walls drawn over the plaster wall: they take the new plaster with them
PLASTER_USERS = [1292, 1293]

OUTLINE = (58, 34, 30)
# the Pokemon Center roof is (196, 67, 45) with (224, 102, 81) and (235, 127, 109) above it
ROOF = [(96, 34, 28), (138, 46, 34), (168, 58, 40), (194, 74, 50), (218, 104, 76), (236, 142, 112)]
ROOF_CUTS = [37, 48, 63, 78, 90]  # original luminance to ROOF index, for the small dormers
WOOD = [(84, 44, 28), (122, 66, 38), (156, 90, 52), (186, 118, 70), (214, 152, 100)]
PLASTER = [(214, 196, 166), (236, 222, 196), (248, 240, 220), (255, 251, 236)]
ROOF_DEEP = [(84, 30, 26), (122, 40, 30), (150, 52, 36), (176, 64, 44), (202, 90, 62), (224, 124, 94)]
PLASTER_WARM = [(206, 182, 144), (226, 206, 170), (240, 224, 192), (250, 240, 214)]
WOOD_DEEP = [(70, 36, 24), (104, 56, 32), (136, 78, 44), (166, 102, 60), (196, 134, 84)]
# FireRed/LeafGreen, from pret/pokefirered: the Pallet Town house roof (primary palette 2), its
# pinkish wood (palette 1), window glass (palette 3) and the blue-grey it outlines with
# the body sits on (205, 82, 74) as in the game; (140, 28, 38) is a step under its darkest red
ROOF_FRLG = [(90, 57, 65), (140, 28, 38), (172, 32, 41), (205, 82, 74), (222, 106, 98), (238, 148, 115)]
WOOD_FRLG = [(90, 57, 65), (123, 74, 74), (148, 106, 106), (189, 148, 139), (222, 197, 164)]
PLASTER_FRLG = [(222, 197, 164), (238, 213, 197), (246, 238, 222), (255, 250, 242)]
WHITE_FRLG = [(172, 189, 205), (205, 222, 238), (230, 238, 238), (246, 246, 255)]
GLASS_FRLG = [(49, 98, 164), (98, 164, 222), (156, 213, 255), (246, 246, 255)]
OUTLINE_FRLG = (65, 74, 106)
GLASS = [(70, 104, 150), (116, 166, 214), (172, 214, 244), (236, 248, 255)]
STYLE = {'tile': 'shakes', 'width': 16, 'roof': ROOF_DEEP, 'eave': 3, 'walls': 'bevel',
         'plaster': PLASTER_WARM, 'wood': WOOD_DEEP, 'siding': False, 'east': -1,
         'outline': OUTLINE, 'glass': GLASS}


def lum(rgb):
    return rgb[..., 0] * 0.3 + rgb[..., 1] * 0.59 + rgb[..., 2] * 0.11


def median(a, size):
    k = size // 2
    p = np.pad(a, k, mode='edge')
    stack = [p[j:j + a.shape[0], i:i + a.shape[1]] for j in range(size) for i in range(size)]
    return np.median(np.stack(stack), axis=0)


def blur(a, radius):
    top = max(float(a.max()), 1e-6)
    im = Image.fromarray(np.clip(a * 255 / top, 0, 255).astype(np.uint8))
    return np.array(im.filter(ImageFilter.GaussianBlur(radius))).astype(float) * top / 255


def grow(mask, steps):
    for _ in range(steps):
        p = np.pad(mask, 1)
        mask = mask | p[:-2, 1:-1] | p[2:, 1:-1] | p[1:-1, :-2] | p[1:-1, 2:]
    return mask


def layout(thing):
    """(pattern and layer, sprite index, x, y) of every sprite of an item, as the client lays it out."""
    attrs, w, h, layers, pxn, pyn, pzn, frames, sprites = thing
    for p in range(pxn * pyn * pzn * frames):
        for layer in range(layers):
            for hy in range(h):
                for wx in range(w):
                    idx = ((p * layers + layer) * h + hy) * w + wx
                    yield (p, layer), idx, (w - 1 - wx) * 32, (h - 1 - hy) * 32


def compose(thing, art):
    w, h = thing[1], thing[2]
    pats = {}
    for p, idx, x, y in layout(thing):
        img = pats.setdefault(p, np.zeros((h * 32, w * 32, 4), np.uint8))
        sid = thing[8][idx] if idx < len(thing[8]) else 0
        if sid in art:
            img[y:y + 32, x:x + 32] = art[sid]
    return pats


def panes(rgba):
    """Light pixels shut in by the window frame, not reaching the wall's outline: the glass."""
    a = rgba[..., 3] > 0
    L = lum(rgba[..., :3].astype(float))
    light = a & (L > 170)
    seen = np.zeros_like(light)
    glass = np.zeros_like(light)
    H, W = light.shape
    for sy, sx in zip(*np.nonzero(light)):
        if seen[sy, sx]:
            continue
        comp, closed, todo = [], True, deque([(sy, sx)])
        seen[sy, sx] = True
        while todo:
            y, x = todo.popleft()
            comp.append((y, x))
            for q in ((y + 1, x), (y - 1, x), (y, x + 1), (y, x - 1)):
                if not (0 <= q[0] < H and 0 <= q[1] < W) or not a[q]:
                    closed = False
                elif light[q] and not seen[q]:
                    seen[q] = True
                    todo.append(q)
        if closed and len(comp) <= 80:
            for p in comp:
                glass[p] = True
    return glass


def shingle_shade(u, t, row):
    """ROOF index of a shingle pixel: u runs along the row, t across it (0 is the row's top)."""
    tile = STYLE['tile']
    k = [4, 3, 3, 3, 3, 3, 2, 1][t]
    if tile == 'rows':
        return k
    w = STYLE['width']
    s = (u + (w // 2) * (row % 2)) % w
    if tile == 'shakes':
        # no dark lines: a row ends where its shade meets the next row's lit top
        k = [4, 4, 3, 3, 3, 3, 2, 2][t]
        if s == 0 and t > 0:
            k -= 1
        return k
    if tile == 'tiles':
        # staggered clay tiles with rounded lower corners
        if s == 0 and 0 < t:
            k -= 1
        elif s == 1 and 0 < t < 6:
            k += 1
        if t == 7 and s in (0, 1, w - 1):
            k = 0
        elif t == 6 and s in (0, w - 1):
            k = 1
    return k


def paint_roof(rgba, vertical, tone, edges):
    rgb = rgba[..., :3].astype(float)
    a = rgba[..., 3] > 0
    r, g, b = rgb[..., 0], rgb[..., 1], rgb[..., 2]
    hue = 60 * (g - b) / np.maximum(r - b, 1)
    hue[~a] = 10
    shingle = a & (median(np.clip(hue, 0, 40), 5) < 13.5)
    L = lum(rgb)
    edge = a & grow(~a, 2)
    below, right = edges[..., 0], edges[..., 1] > 0
    pal = STYLE['roof']
    out = rgba.copy()
    for y, x in zip(*np.nonzero(a)):
        if shingle[y, x]:
            u, v = (y, x) if vertical else (x, y)
            k = shingle_shade(u, v % 8, v // 8) + tone
            if below[y, x] <= STYLE['eave']:
                # the eave: a dark lip under a lit edge
                k = [0, 1, 4][below[y, x] - 1] if STYLE['eave'] == 3 else k - 1
            elif right[y, x]:
                k -= 1
            c = pal[int(np.clip(k, 0, len(pal) - 1))]
        else:
            v = L[y, x]
            c = STYLE['outline'] if v < 38 and edge[y, x] else STYLE['wood'][int(np.searchsorted([70, 100, 128, 150], v))]
        out[y, x, :3] = c
    return out


def paint_dormer(rgba):
    rgb = rgba[..., :3].astype(float)
    a = rgba[..., 3] > 0
    r, g, b = rgb[..., 0], rgb[..., 1], rgb[..., 2]
    L = lum(rgb)
    hue = 60 * (g - b) / np.maximum(r - b, 1)
    out = rgba.copy()
    for y, x in zip(*np.nonzero(a)):
        v = L[y, x]
        if v < 34:
            c = STYLE['outline']
        elif hue[y, x] < 13.5 and r[y, x] > 1.8 * g[y, x]:
            c = STYLE['roof'][int(np.searchsorted(ROOF_CUTS, v))]
        elif v > 165:
            c = STYLE['plaster'][2 if v > 210 else 1]
        else:
            c = STYLE['wood'][int(np.searchsorted([70, 100, 128, 150], v))]
        out[y, x, :3] = c
    return out


def paint_wall(rgba, window, cid):
    rgb = rgba[..., :3].astype(float)
    a = rgba[..., 3] > 0
    L = lum(rgb)
    Ls = lum(np.stack([median(rgb[..., ch], 3) for ch in range(3)], -1))
    glass = panes(rgba) if window else np.zeros(a.shape, bool)
    plaster = a & ~glass & (L > 165) & ((rgb[..., 0] - rgb[..., 2]) > 18)
    dark = a & ~glass & (L < 46)
    wood = a & ~plaster & ~glass & ~dark
    H, W = a.shape
    bevel = STYLE['walls'] == 'bevel'

    def at(m, y, x):
        return 0 <= y < H and 0 <= x < W and m[y, x]
    out = rgba.copy()
    gy, gx = np.nonzero(glass)
    for y, x in zip(*np.nonzero(a)):
        east = cid in EAST_WALLS or (cid in CORNERS and x >= W // 2)
        shade = STYLE['east'] if east else 0
        if glass[y, x]:
            # a diagonal glint across each pane, brighter towards the top left
            d = (x - gx.min()) + (y - gy.min())
            k = 2 if L[y, x] > 200 else 1
            if d % 9 in (3, 4):
                k = 3
            c = STYLE['glass'][k]
        elif plaster[y, x]:
            k = 3 if Ls[y, x] > 232 else 2 if Ls[y, x] > 196 else 1
            if STYLE['siding']:
                k = 2
                line = (y - x) % 6 if east else y % 6
                if line == 0:
                    k = 1
                elif line == 1:
                    k = 3
            if at(wood, y - 1, x) or (bevel and at(wood, y, x - 1)):
                k = min(k, 1)
            c = STYLE['plaster'][int(np.clip(k + shade, 0, 3))]
        elif dark[y, x]:
            c = STYLE['outline']
        else:
            k = int(np.searchsorted([64, 92, 112], Ls[y, x]))
            if y == 0 or not a[y - 1, x]:
                k = 4
            elif at(glass, y - 1, x) or at(glass, y + 1, x):
                k = 0
            elif bevel and (at(plaster, y - 1, x) or at(plaster, y, x - 1)):
                k = 3
            elif bevel and (at(plaster, y + 1, x) or at(plaster, y, x + 1)):
                k = 0
            c = STYLE['wood'][int(np.clip(k + shade, 0, 4))]
        out[y, x, :3] = c
    return out


def jobs():
    """(items, painter) in order; a sprite shared by several items takes the first one's paint."""
    return [(DORMERS, lambda im, cid, e: paint_dormer(im)),
            (ROOF_ITEMS, lambda im, cid, e: paint_roof(im, cid in VERTICAL_ROOF, TONES.get(cid, 0), e)),
            (WINDOW_ITEMS, lambda im, cid, e: paint_wall(im, True, cid)),
            (WALL_ITEMS, lambda im, cid, e: paint_wall(im, False, cid))]


def sprite_ids(dat):
    """The sprites to repaint: those of the roof and wall items that no other kind of item uses
    (the window shutters, say, are shared by the stone, brick and ice windows too)."""
    family = set(PLASTER_USERS)
    for items, _ in jobs():
        family.update(items)
    shared = set()
    for cid, thing in dat.things.items():
        if cid not in family:
            shared.update(thing[8])
    out = []
    for items, _ in jobs():
        for cid in items:
            for s in dat.things[cid][8]:
                if s and s not in out and s not in shared:
                    out.append(s)
    return out


def originals(dat, spr):
    """The sprites as they were before this script painted them, kept beside the new art."""
    sheet_path, ids_path = os.path.join(OUT, 'original.png'), os.path.join(OUT, 'sprites.txt')
    if os.path.exists(sheet_path):
        ids = [int(s) for s in open(ids_path).read().split()]
        sheet = np.array(Image.open(sheet_path).convert('RGBA'))
        return {sid: sheet[(i // 16) * 32:(i // 16) * 32 + 32, (i % 16) * 32:(i % 16) * 32 + 32].copy()
                for i, sid in enumerate(ids)}
    ids = [s for s in sprite_ids(dat) if spr.rgba(s)]
    sheet = np.zeros((((len(ids) + 15) // 16) * 32, 16 * 32, 4), np.uint8)
    art = {}
    for i, sid in enumerate(ids):
        art[sid] = np.frombuffer(spr.rgba(sid), np.uint8).reshape(32, 32, 4).copy()
        sheet[(i // 16) * 32:(i // 16) * 32 + 32, (i % 16) * 32:(i % 16) * 32 + 32] = art[sid]
    os.makedirs(OUT, exist_ok=True)
    Image.fromarray(sheet, 'RGBA').save(sheet_path)
    with open(ids_path, 'w') as f:
        f.write('\n'.join(map(str, ids)) + '\n')
    return art


class LabelRenderer(Renderer):
    """Renders like the client and records which sprite pixel ends up on top at every pixel."""

    def draw_tile(self, img, items, x, y, z, px, py):
        things = []
        for sid in items:
            thing = self.dat.things.get(self.otb.client_id(sid))
            if thing:
                things.append(thing)
        common = [t for t in things if self.layer_of(t[0]) == 3]
        ordered = ([t for t in things if self.layer_of(t[0]) in (0, 1, 2)] + common[::-1]
                   + [t for t in things if self.layer_of(t[0]) == 4])
        elevation = 0
        H, W = self.sid.shape
        for attrs, w, h, layers, pxn, pyn, pzn, frames, sprites in ordered:
            dx, dy = attrs.get(25, (0, 0))
            xp, yp, zp = x % pxn, y % pyn, z % pzn
            for layer in range(layers):
                for hy in range(h):
                    for wx in range(w):
                        idx = ((((zp * pyn + yp) * pxn + xp) * layers + layer) * h + hy) * w + wx
                        sid = sprites[idx] if idx < len(sprites) else 0
                        if not sid or sid not in self.alpha:
                            continue
                        ox, oy = px - wx * 32 - dx - elevation, py - hy * 32 - dy - elevation
                        x0, y0, x1, y1 = max(ox, 0), max(oy, 0), min(ox + 32, W), min(oy + 32, H)
                        if x0 >= x1 or y0 >= y1:
                            continue
                        m = self.alpha[sid][y0 - oy:y1 - oy, x0 - ox:x1 - ox]
                        self.sid[y0:y1, x0:x1][m] = sid
                        self.pix[y0:y1, x0:x1][m] = self.index[y0 - oy:y1 - oy, x0 - ox:x1 - ox][m]
            if 26 in attrs:
                elevation = min(24, elevation + attrs[26])

    def label(self, tiles, x0, y0, x1, y1, floor, alpha):
        margin = floor + 2
        w, h = (x1 - x0 + 1 + margin) * 32, (y1 - y0 + 1 + margin) * 32
        self.alpha = alpha
        self.index = np.arange(1024).reshape(32, 32)
        self.sid = np.zeros((h, w), np.int64)
        self.pix = np.zeros((h, w), np.int64)
        for z in range(floor, -1, -1):
            shift = (floor - z) * 32
            for y in range(y0 - 2, y1 + margin + 1):
                for x in range(x0 - 2, x1 + margin + 1):
                    items = tiles.get((x, y, z))
                    if items:
                        self.draw_tile(None, items, x, y, z, (x - x0 + margin) * 32 - shift,
                                       (y - y0 + margin) * 32 - shift)
        return self.sid, self.pix


def measure_eaves(dat, art, tiles, box):
    """For every roof sprite pixel, how often what lies 1-3 px below it, or right of it, is not
    roof when it is drawn on the map. Roof pieces overlap and butt against each other, so a
    piece's own edge says little; only the town shows which edges are the roof's outline."""
    roof, slope = set(), {}
    for cid in ROOF_ITEMS + DORMERS:
        for s in dat.things[cid][8]:
            if s in art:
                roof.add(s)
                slope.setdefault(s, (cid in VERTICAL_ROOF, TONES.get(cid, 0)))
    classes = sorted(set(slope.values()))
    alpha = {sid: art[sid][..., 3] > 0 for sid in art}
    r = LabelRenderer(ITEMS, DAT, SPR)
    sid, pix = r.label(tiles, *box, 7, alpha)
    is_roof = np.isin(sid, list(roof))
    # a different slope below counts as open too: that is where one roof overhangs another
    cls = np.full(sid.shape, -1)
    for s, c in slope.items():
        cls[sid == s] = classes.index(c)
    H, W = sid.shape
    seen = {s: np.zeros(1024) for s in roof}
    hits = {s: np.zeros((4, 1024)) for s in roof}  # open below at 1, 2, 3 px; open to the right
    ys, xs = np.nonzero(is_roof)
    keys = sid[ys, xs]
    pixel = pix[ys, xs]
    here = cls[ys, xs]
    opens = []
    for d in (1, 2, 3):
        yy = np.minimum(ys + d, H - 1)
        opens.append(~is_roof[yy, xs] | (cls[yy, xs] != here))
    xx = np.minimum(xs + 1, W - 1)
    opens.append(~is_roof[ys, xx] | (cls[ys, xx] != here))
    for s in roof:
        m = keys == s
        if not m.any():
            continue
        np.add.at(seen[s], pixel[m], 1)
        for k in range(4):
            np.add.at(hits[s][k], pixel[m][opens[k][m]], 1)
    eaves = {}
    for s in roof:
        frac = hits[s] / np.maximum(seen[s], 1)
        below = np.full(1024, 9, np.uint8)
        for d in (3, 2, 1):
            below[frac[d - 1] > 0.5] = d
        eaves[s] = np.stack([below.reshape(32, 32), (frac[3] > 0.5).reshape(32, 32).astype(np.uint8)], -1)
    return eaves


def save_eaves(eaves):
    ids = [int(x) for x in open(os.path.join(OUT, 'sprites.txt')).read().split()]
    sheet = np.zeros((((len(ids) + 15) // 16) * 32, 16 * 32, 3), np.uint8)
    for i, sid in enumerate(ids):
        if sid in eaves:
            y, x = (i // 16) * 32, (i % 16) * 32
            sheet[y:y + 32, x:x + 32, 0] = eaves[sid][..., 0] * 28
            sheet[y:y + 32, x:x + 32, 1] = eaves[sid][..., 1] * 255
            sheet[y:y + 32, x:x + 32, 2] = 255
    Image.fromarray(sheet, 'RGB').save(os.path.join(OUT, 'eaves.png'))


def load_eaves():
    """{sprite: 32x32x2} of roof sprites: rows below that are open (1-3, 9 for none), open right."""
    path = os.path.join(OUT, 'eaves.png')
    if not os.path.exists(path):
        return {}
    ids = [int(x) for x in open(os.path.join(OUT, 'sprites.txt')).read().split()]
    sheet = np.array(Image.open(path).convert('RGB'))
    out = {}
    for i, sid in enumerate(ids):
        cell = sheet[(i // 16) * 32:(i // 16) * 32 + 32, (i % 16) * 32:(i % 16) * 32 + 32]
        if cell[0, 0, 2]:
            out[sid] = np.stack([cell[..., 0] // 28, cell[..., 1] // 255], -1)
    return out


def build(dat, art):
    eaves = load_eaves()
    blank = np.dstack([np.full((32, 32), 9, np.uint8), np.zeros((32, 32), np.uint8)])
    new = {}
    for items, painter in jobs():
        for cid in items:
            thing = dat.things[cid]
            w, h = thing[1], thing[2]
            edge = {}
            for p, idx, x, y in layout(thing):
                e = edge.setdefault(p, np.dstack([np.full((h * 32, w * 32), 9, np.uint8),
                                                  np.zeros((h * 32, w * 32), np.uint8)]))
                sid = thing[8][idx] if idx < len(thing[8]) else 0
                e[y:y + 32, x:x + 32] = eaves.get(sid, blank)
            pats = {p: painter(img, cid, edge[p]) for p, img in compose(thing, art).items()}
            for p, idx, x, y in layout(thing):
                sid = thing[8][idx] if idx < len(thing[8]) else 0
                if sid in art and sid not in new:
                    new[sid] = pats[p][y:y + 32, x:x + 32].copy()
    return new


def write_spr(new):
    # data.spr is hard linked into other checkouts, so write a new file rather than edit it
    tmp = SPR + '.tmp'
    px = {sid: img.tobytes() for sid, img in new.items()}
    pvmap.write_sprites(SPR, tmp, px)
    check = pvmap.Spr(tmp)
    for sid, raw in px.items():
        want = np.frombuffer(raw, np.uint8).reshape(-1, 4).copy()
        want[want[:, 3] == 0] = 0  # .spr keeps no color for transparent pixels
        if (check.rgba(sid) or bytes(4096)) != want.tobytes():
            raise SystemExit('sprite %d did not read back the same' % sid)
    old = pvmap.Spr(SPR)
    for sid in range(1, old.count + 1, 97):
        if sid not in px and old.rgba(sid) != check.rgba(sid):
            raise SystemExit('sprite %d changed though it was not repainted' % sid)
    old.f.close()
    check.f.close()
    os.replace(tmp, SPR)
    print('wrote %d sprites into data.spr' % len(px))


def read_view():
    x0, y0, x1, y1 = VIEW
    return pvmap.read_region(MAP, x0 - 2, y0 - 2, x1 + 10, y1 + 10, range(0, 8))


def render(tiles, sprites):
    r = Renderer(ITEMS, DAT, SPR)
    r.sprite_images.update({sid: Image.fromarray(img, 'RGBA') for sid, img in sprites.items()})
    return r.render(tiles, *VIEW, 7).convert('RGB')


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--before')
    ap.add_argument('--mockup')
    ap.add_argument('--write-spr', action='store_true', help='put the new roofs and walls into data.spr')
    ap.add_argument('--measure-eaves', action='store_true',
                    help='find the roof outline on the Pallet houses (map.otbm), into eaves.png')
    args = ap.parse_args()
    dat, spr = pvmap.Dat(DAT), pvmap.Spr(SPR)
    art = originals(dat, spr)
    if args.measure_eaves:
        x0, y0, x1, y1 = TOWN
        tiles = pvmap.read_region(MAP, x0 - 2, y0 - 2, x1 + 10, y1 + 10, range(0, 8))
        save_eaves(measure_eaves(dat, art, tiles, TOWN))
    new = build(dat, art)
    if args.before or args.mockup:
        tiles = read_view()
        if args.before:
            render(tiles, art).save(args.before)
        if args.mockup:
            render(tiles, new).save(args.mockup)
    if args.write_spr:
        spr.f.close()
        write_spr(new)


if __name__ == '__main__':
    main()
