#!/usr/bin/env python3
"""Draws the Coordinator, a test Store outfit (female) on the new 64x64 body template.

    outfit_coordinator.py [out dir]

The template (art/sprites/outfits/templates/female_64.png) is a grey mannequin: 4 directions
(south, east, north, west) by 3 frames, 64x64 each, plus a fifth pose. Only the standing frame
(row 0) is drawn so far. Each frame gets a hand-placed skeleton (SKELETON); every template pixel
goes to its nearest bone, and the clothes are painted by bone with the template's own shading.

Base: long hair (head colour), tube top (body), pleated skirt (legs), knee boots (feet).
Add-on 1: knit beanie with a Poke Ball pin (legs colour). Add-on 2: scarf (feet colour).
Writes <pattern>_<direction>_0_<layer>.png (pattern 0 base, 1 beanie, 2 scarf; layer 0 grey
base, 1 RGB mask) and preview.png. --scene also writes world.png: Pallet Town's fountain square
from the map (Git LFS) with Coordinators next to today's 32 px outfits and Pokemon, to judge
the template's size in the world.
"""
import math
import os
import sys

from PIL import Image

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
TPL = Image.open(os.path.join(ROOT, 'art/sprites/outfits/templates/female_64.png')).convert('RGBA')
OUT = os.path.join(ROOT, 'art/sprites/outfits/coordinator')

S, E, N, W = 'S', 'E', 'N', 'W'
COLUMN = {S: 0, E: 1, N: 2, W: 3}

# Joints per (direction, frame). Arms: shoulder, elbow, hand. Legs: hip, knee, ankle, toe.
SKELETON = {
    (S, 0): dict(head=(12, 10, 10), neck=(18, 21), pelvis=(34, 34),
                 arms=[((10, 25), (12, 30), (16, 36)), ((24, 11), (40, 15), (52, 28))],
                 legs=[((30, 34), (40, 46), (43, 57), (43, 61)), ((40, 32), (52, 44), (56, 56), (57, 61))]),
    (E, 0): dict(head=(10, 13, 10), neck=(19, 21), pelvis=(34, 36),
                 arms=[((18, 8), (28, 12), (36, 15)), ((11, 24), (16, 36), (28, 52))],
                 legs=[((34, 30), (45, 41), (50, 43), (60, 43)), ((32, 40), (42, 50), (48, 56), (60, 57))]),
    (N, 0): dict(head=(12, 8, 9.5), neck=(18, 17), pelvis=(36, 38),
                 arms=[((24, 17), (38, 22), (52, 32)), ((9, 22), (12, 30), (15, 38))],
                 legs=[((32, 36), (40, 46), (44, 56), (46, 60)), ((42, 34), (50, 42), (56, 52), (58, 58))]),
    (W, 0): dict(head=(8, 13, 10), neck=(17, 19), pelvis=(36, 36),
                 arms=[((20, 9), (30, 12), (38, 15)), ((17, 24), (22, 38), (30, 52))],
                 legs=[((35, 30), (46, 42), (52, 46), (58, 47)), ((34, 38), (44, 50), (50, 56), (56, 61))]),
}


def seg_dist(p, a, b):
    ax, ay = a
    bx, by = b
    dx, dy = bx - ax, by - ay
    L2 = dx * dx + dy * dy
    t = 0 if L2 == 0 else max(0, min(1, ((p[0] - ax) * dx + (p[1] - ay) * dy) / L2))
    q = (ax + dx * t, ay + dy * t)
    return math.hypot(p[0] - q[0], p[1] - q[1]), t


def bones(sk):
    hx, hy, hr = sk['head']
    out = [('head', (hx, hy), (hx, hy), hr), ('torso', sk['neck'], sk['pelvis'], 9.0)]
    for i, (sh, el, ha) in enumerate(sk['arms']):
        out += [('uarm%d' % i, sh, el, 3.2), ('farm%d' % i, el, ha, 3.0)]
    for i, (hip, kn, an, toe) in enumerate(sk['legs']):
        out += [('thigh%d' % i, hip, kn, 5.0), ('shin%d' % i, kn, an, 4.0), ('foot%d' % i, an, toe, 3.5)]
    return out


def template(d, f):
    c = COLUMN[d]
    return TPL.crop((c * 64, f * 64, c * 64 + 64, f * 64 + 64))


def segment(d, f):
    """{pixel: (part, t)} for every opaque template pixel."""
    img = template(d, f)
    px = img.load()
    bs = bones(SKELETON[(d, f)])
    labels = {}
    for y in range(64):
        for x in range(64):
            if px[x, y][3] == 0:
                continue
            best = None
            for name, a, b, r in bs:
                dist, t = seg_dist((x, y), a, b)
                score = dist / r
                if best is None or score < best[0]:
                    best = (score, name, t)
            labels[(x, y)] = (best[1], best[2])
    return img, labels



HEAD, BODY, LEGS, FEET = (255, 255, 0), (255, 0, 0), (0, 255, 0), (0, 0, 255)
OUTLINE = (5, 4, 3)
SKIN = {255: (255, 238, 224), 223: (247, 212, 182), 186: (226, 174, 136), 138: (190, 130, 96),
        117: (166, 110, 80), 85: (126, 78, 56), 69: (100, 60, 44)}
CLOTH = {255: 240, 223: 222, 186: 184, 138: 140, 117: 118, 85: 88, 69: 72}
BALL_RED, BALL_WHITE, BALL_DARK = (226, 52, 44), (246, 246, 240), (30, 28, 30)


def tone(v):
    """Snap to the template's grey steps."""
    return min(CLOTH, key=lambda k: abs(k - v))


class Canvas:
    def __init__(self):
        self.c, self.m = {}, {}

    def put(self, p, col, mask=None):
        if not (0 <= p[0] < 64 and 0 <= p[1] < 64):
            return
        self.c[p] = col
        if mask:
            self.m[p] = mask
        else:
            self.m.pop(p, None)

    def grey(self, p, v, mask):
        v = CLOTH[tone(v)]
        self.put(p, (v, v, v), mask)

    def outline_new(self, new, solid):
        """Outline the transparent pixels around new pixels."""
        for (x, y) in list(new):
            for q in ((x + 1, y), (x - 1, y), (x, y + 1), (x, y - 1)):
                if q not in self.c and q not in solid and 0 <= q[0] < 64 and 0 <= q[1] < 64:
                    self.put(q, OUTLINE)

    def images(self):
        b = Image.new('RGBA', (64, 64), (0, 0, 0, 0))
        m = Image.new('RGBA', (64, 64), (0, 0, 0, 0))
        for p, col in self.c.items():
            b.putpixel(p, col + (255,))
        for p, col in self.m.items():
            m.putpixel(p, col + (255,))
        return b, m


class Painter:
    HEM = 1.2
    def __init__(self, d, f):
        self.d, self.f = d, f
        self.sk = SKELETON[(d, f)]
        self.img, self.labels = segment(d, f)
        self.px = self.img.load()
        self.solid = set(self.labels)
        hx, hy, hr = self.sk['head']
        self.hx, self.hy, self.hr = hx, hy, hr

    def axis(self, p):
        """Position along the neck-to-pelvis axis (0 neck, 1 pelvis) and across it."""
        nx, ny = self.sk['neck']
        px_, py_ = self.sk['pelvis']
        ax, ay = px_ - nx, py_ - ny
        ln2 = ax * ax + ay * ay
        ln = math.sqrt(ln2)
        along = ((p[0] - nx) * ax + (p[1] - ny) * ay) / ln2
        across = ((p[0] - nx) * -ay + (p[1] - ny) * ax) / ln
        return along, across

    def v(self, p):
        return self.px[p][0]

    def is_line(self, p):
        return p in self.solid and self.px[p][0] < 20

    def part(self, p):
        return self.labels[p]

    # ---------------- base -----------------
    def zone(self, p):
        """What the base wears at a template pixel."""
        name, t = self.labels[p]
        nx, ny = self.sk['neck']
        along, _ = self.axis(p)
        if name == 'torso':
            if math.hypot(p[0] - nx, p[1] - ny) < 4.2 or t < 0.08:
                return 'skin'
            return 'top' if t < 0.6 else 'skirt'
        if name.startswith('thigh'):
            return 'skirt' if along < self.HEM else 'skin'
        if name.startswith('shin'):
            return 'boot' if t > 0.22 else 'skin'
        if name.startswith('foot'):
            return 'boot'
        return 'skin'

    def base(self):
        cv = Canvas()
        zones = {}
        for p in self.labels:
            if self.is_line(p):
                cv.put(p, OUTLINE)
                continue
            z = self.zone(p)
            zones[p] = z
            v = tone(self.v(p))
            if z == 'skin':
                cv.put(p, SKIN[v])
            elif z == 'top':
                cv.grey(p, v, BODY)
            elif z == 'skirt':
                cv.grey(p, v, LEGS)
            elif z == 'boot':
                cv.grey(p, v, FEET)
        # the skirt is one piece: fill between the legs, flare one pixel out at the hem
        skirt = {p for p, z in zones.items() if z == 'skirt'}
        add = set()
        for y in range(64):
            row = sorted(x for (x, yy) in skirt if yy == y)
            for x in range(row[0], row[-1] + 1) if row else ():
                if (x, y) not in self.solid and self.axis((x, y))[0] > 0.85:
                    add.add((x, y))
        for (x, y) in list(skirt):
            if self.axis((x, y))[0] > self.HEM - 0.22:
                for q in ((x + 1, y), (x - 1, y), (x, y + 1), (x + 1, y + 1), (x - 1, y + 1),
                          (x + 2, y), (x - 2, y), (x + 2, y + 1), (x - 2, y + 1)):
                    if q not in self.solid and self.axis(q)[0] < self.HEM + 0.1:
                        add.add(q)
        for q in add:
            cv.grey(q, 117, LEGS)
            zones[q] = 'skirt'
        for p, z in zones.items():
            if z == 'skirt':
                along, across = self.axis(p)
                if along > 0.85 and round(across) % 4 == 0 and cv.c.get(p) != OUTLINE:
                    cv.grey(p, CLOTH[tone(cv.c[p][0])] - 40, LEGS)
        # seams: a dark line where clothes meet skin
        for p, z in zones.items():
            if z in ('top', 'skirt', 'boot'):
                for q in ((p[0] + 1, p[1]), (p[0] - 1, p[1]), (p[0], p[1] + 1), (p[0], p[1] - 1)):
                    if zones.get(q) == 'skin':
                        cv.put(p, OUTLINE)
                        break
        # boot cuff: the lighter band at the top of each boot
        for p, z in zones.items():
            name, t = self.labels.get(p, ('', 0))
            if z == 'boot' and name.startswith('shin') and 0.22 < t < 0.34 and cv.c[p] != OUTLINE:
                cv.grey(p, 223, FEET)
        self.hair(cv)
        cv.outline_new([p for p in cv.c if p not in self.solid], self.solid)
        return cv

    def hair(self, cv):
        d, hx, hy, r = self.d, self.hx, self.hy, self.hr
        head = [p for p, (n, _) in self.labels.items() if n == 'head' and not self.is_line(p)]
        covered = set()
        for (x, y) in head:
            dx, dy = x - hx, y - hy
            if d == S:
                face = dy >= 1 and abs(dx) <= 6.5
                bang = dy in (1, 2) and (x % 4 != 1)
                cover = not face or bang
            elif d == E:
                cover = dx <= 3 or dy <= -4 or (dy <= -2 and x % 3 == 0)
            else:
                cover = True
            if cover:
                covered.add((x, y))
        cx, cy = hx - r * 0.2, hy - r * 0.9
        for p in covered:
            v = self.v(p)
            ang = math.atan2(p[1] - cy, p[0] - cx)
            if round(ang * 9) % 3 == 0 and math.hypot(p[0] - cx, p[1] - cy) > 4:
                v -= 45
            cv.grey(p, v, HEAD)
        # long hair
        locks = []
        nx, ny = self.sk['neck']
        px_, py_ = self.sk['pelvis']
        down = ((px_ - nx), (py_ - ny))
        ln = math.hypot(*down)
        down = (down[0] / ln, down[1] / ln)
        if d == S:
            locks = [((hx - 7, hy + 4), (hx - 9, hy + 17), 3.2, 'behind'),
                     ((hx + 7, hy + 4), (hx + 11, hy + 13), 2.6, 'behind')]
        elif d == E:
            locks = [((hx - 5, hy + 4), (hx - 6, hy + 19), 3.6, 'behind')]
        elif d == N:
            top = (hx + 2, hy + r - 3)
            locks = [(top, (top[0] + down[0] * 16, top[1] + down[1] * 16), 5.2, 'front')]
        else:
            top = (hx + 3, hy + r - 3)
            locks = [(top, (top[0] + down[0] * 14, top[1] + down[1] * 14), 4.4, 'front')]
        for a, b, w, layer in locks:
            for y in range(64):
                for x in range(64):
                    dist, t = seg_dist((x, y), a, b)
                    width = w * (1 - 0.45 * t)
                    if dist > width:
                        continue
                    p = (x, y)
                    if layer == 'behind' and p in self.solid:
                        continue
                    edge = dist / width
                    v = 200 if edge < 0.35 else 160 if edge < 0.7 else 120
                    bx, by = b[0] - a[0], b[1] - a[1]
                    side = ((x - a[0]) * -by + (y - a[1]) * bx) / math.hypot(bx, by)
                    if round(side / width * 3) in (-1, 1) and abs(side / width * 3 - round(side / width * 3)) < 0.2:
                        v -= 45
                    cv.grey(p, v, HEAD)

    # ---------------- add-on 1: beanie -----------------
    BEANIE = {S: (0.05, 0), E: (-0.05, -0.35), N: (0.25, 0), W: (0.0, 0.35)}  # rim height, tilt

    def beanie(self):
        cv = Canvas()
        d, hx, hy, r = self.d, self.hx, self.hy, self.hr
        rim_k, tilt = self.BEANIE[d]
        head = {p for p, (n, _) in self.labels.items() if n == 'head'}

        def rim(x):
            return hy + r * rim_k + tilt * (x - hx)

        pts = {p for p in head if p[1] <= rim(p[0])}
        bulge = set()
        for (x, y) in pts:
            for q in ((x - 1, y), (x + 1, y), (x, y - 1)):
                if q not in head and q not in pts and 0 <= q[1]:
                    bulge.add(q)
        for p in pts | bulge:
            if self.is_line(p) and p not in bulge:
                continue
            depth = rim(p[0]) - p[1]
            if depth < 2.5:
                v = 223 if depth >= 1 else 186
                if p[0] % 2 == 0:
                    v = 186 if v == 223 else 138
            else:
                v = self.v(p) if p in self.solid and not self.is_line(p) else 138
                if 2.5 <= depth < 3.5:
                    v = 85
            cv.grey(p, v, LEGS)
        pin = {S: (hx - 6, 0), E: (hx + 3, 0), N: None, W: (hx - 7, 0)}[d]
        if pin:
            x = pin[0]
            y = int(rim(x)) - 3
            for dx in (0, 1, 2):
                cv.put((x + dx, y), BALL_RED)
                cv.put((x + dx, y + 1), BALL_DARK)
                cv.put((x + dx, y + 2), BALL_WHITE)
            cv.put((x + 1, y + 1), BALL_WHITE)
        for p in list(cv.c):
            for q in ((p[0] + 1, p[1]), (p[0] - 1, p[1]), (p[0], p[1] + 1), (p[0], p[1] - 1)):
                if q not in cv.c and 0 <= q[0] < 64 and 0 <= q[1] < 64 and (q not in head or q[1] > rim(q[0])):
                    cv.put(q, OUTLINE)
        return cv

    # ---------------- add-on 2: scarf -----------------
    # band centre, band direction, half length; tail start offset and end offset from the centre
    SCARF = {S: ((18, 20), (0.72, -0.69), 4.5, (-2, 2), (0, 10)),
             E: ((20, 20), (0.6, -0.8), 4.5, (-3, 1), (-9, 7)),
             N: ((19, 17), (0.75, -0.65), 6, (2, 2), (7, 11)),
             W: ((18, 19), (0.6, -0.8), 4.5, (3, 1), (9, 6))}

    def scarf(self):
        cv = Canvas()
        (cx, cy), (ux, uy), half, t0, t1 = self.SCARF[self.d]
        band = (cx - ux * half, cy - uy * half), (cx + ux * half, cy + uy * half)
        tail = (cx + t0[0], cy + t0[1]), (cx + t1[0], cy + t1[1])
        face = {p for p, (n, _) in self.labels.items() if n == 'head'} if self.d in (S, E) else set()
        for y in range(64):
            for x in range(64):
                p = (x, y)
                db, _ = seg_dist(p, *band)
                dt, tt = seg_dist(p, *tail)
                if db <= 2.3 and p not in face:
                    v = 223 if db < 0.9 else 186 if db < 1.7 else 138
                    cv.grey(p, v, FEET)
                elif dt <= 2.0 and tt > 0.1:
                    v = 186 if dt < 0.9 else 138
                    if tt > 0.85 and (x + y) % 2:
                        v = 223
                    cv.grey(p, v, FEET)
        for p in list(cv.c):
            for q in ((p[0] + 1, p[1]), (p[0] - 1, p[1]), (p[0], p[1] + 1), (p[0], p[1] - 1)):
                if q not in cv.c and 0 <= q[0] < 64 and 0 <= q[1] < 64:
                    cv.put(q, OUTLINE)
        return cv


def colorize(base, mask, colors):
    out = base.copy()
    op, mp = out.load(), mask.load()
    keys = {HEAD: 0, BODY: 1, LEGS: 2, FEET: 3}
    for y in range(64):
        for x in range(64):
            m = mp[x, y]
            if m[3] and m[:3] in keys:
                c = colors[keys[m[:3]]]
                p = op[x, y]
                op[x, y] = (p[0] * c[0] // 255, p[1] * c[1] // 255, p[2] * c[2] // 255, p[3])
    return out


def build(d, f):
    p = Painter(d, f)
    return [c.images() for c in (p.base(), p.beanie(), p.scarf())]


def dressed(layers, colors, addons=(1, 2)):
    img = Image.new('RGBA', (64, 64), (0, 0, 0, 0))
    for i in (0,) + tuple(addons):
        img.alpha_composite(colorize(*layers[i], colors))
    return img


# palette indices: head, body, legs, feet
COORDINATOR_SETS = [(95, 114, 92, 112), (41, 0, 68, 68), (75, 63, 0, 78), (114, 71, 114, 71)]
# tile, then ('new', direction, colour set, add-ons) or ('old', look type, direction, palette indices)
SCENE = (3282, 808, 3301, 822)
CAST = [(3289, 814, ('new', S, 0, (1, 2))), (3291, 814, ('old', 1384, S, (75, 75, 125, 95))),
        (3290, 815, ('old', 376, W, None)), (3294, 813, ('new', W, 1, (1,))),
        (3286, 817, ('new', E, 2, (2,))), (3287, 818, ('old', 1385, E, (95, 68, 114, 19))),
        (3297, 817, ('new', N, 3, (1, 2))), (3292, 819, ('old', 1380, S, (115, 0, 114, 114))),
        (3299, 812, ('old', 357, S, None))]
DISPLACEMENT = 8  # outfits are drawn 8 px up and left of their tile, like today's (dat attribute 25)


def scene(outfit_color):
    sys.path.insert(0, os.path.join(ROOT, 'scripts/mapper'))
    import outfit_sprites
    import pvmap
    from render import Renderer
    x0, y0, x1, y1 = SCENE
    tiles = pvmap.read_region(os.path.join(ROOT, 'core/server/data/world/map.otbm'),
                              x0 - 2, y0 - 2, x1 + 10, y1 + 10, range(0, 8))
    things = outfit_sprites.THINGS
    r = Renderer(os.path.join(ROOT, 'core/server/data/items/items.otb'),
                 os.path.join(things, 'data.dat'), os.path.join(things, 'data.spr'))
    img = r.render(tiles, x0, y0, x1, y1, 7).convert('RGBA')
    looks = outfit_sprites.read_outfits(open(os.path.join(things, 'data.dat'), 'rb').read())
    spr = outfit_sprites.Spr(os.path.join(things, 'data.spr'))
    client_dir = {N: 0, E: 1, S: 2, W: 3}
    for tx, ty, who in sorted(CAST, key=lambda c: (c[1], c[0])):
        px, py = (tx - x0) * 32 + 32, (ty - y0) * 32 + 32
        if who[0] == 'new':
            _, d, k, addons = who
            sprite = dressed(build(d, 0), [outfit_color(i) for i in COORDINATOR_SETS[k]], addons)
            img.alpha_composite(sprite, (px - 64 - DISPLACEMENT, py - 64 - DISPLACEMENT))
            continue
        _, look, d, indices = who
        thing = looks[look]
        sprite = outfit_sprites.frame_image(spr, thing, 0, client_dir[d], 0, 0, 0)
        disp = 0
        if indices:
            mask = outfit_sprites.frame_image(spr, thing, 1, client_dir[d], 0, 0, 0)
            sprite = colorize(sprite, mask, [outfit_color(i) for i in indices])
            disp = DISPLACEMENT
        img.alpha_composite(sprite, (px - sprite.width - disp, py - sprite.height - disp))
    return img


def main():
    args = [a for a in sys.argv[1:] if not a.startswith('--')]
    out = args[0] if args else OUT
    os.makedirs(out, exist_ok=True)
    sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
    from outfit_sprites import outfit_color
    colors = [outfit_color(i) for i in COORDINATOR_SETS[0]]
    preview = Image.new('RGBA', (64 * 4, 64 * 4), (96, 150, 80, 255))
    for col, d in enumerate((S, E, N, W)):
        layers = build(d, 0)
        for pattern, (base, mask) in enumerate(layers):
            base.save(os.path.join(out, '%d_%s_0_0.png' % (pattern, d)))
            mask.save(os.path.join(out, '%d_%s_0_1.png' % (pattern, d)))
        for row, addons in enumerate(((), (1,), (2,), (1, 2))):
            preview.alpha_composite(dressed(layers, colors, addons), (col * 64, row * 64))
    preview.save(os.path.join(out, 'preview.png'))
    if '--scene' in sys.argv:
        scene(outfit_color).convert('RGB').save(os.path.join(out, 'world.png'))
    print('coordinator -> %s' % os.path.relpath(out, ROOT))


if __name__ == '__main__':
    main()
