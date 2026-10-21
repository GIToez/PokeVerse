#!/usr/bin/env python3
"""Draws the Ace Trainer, a Store outfit with two add-ons, on the Rider body (look type 1385).

    outfit_ace_trainer.py [out dir]

The body keeps the Rider's size, lean, walk cycle and light; everything it wears is redrawn:
spiky hair (head colour), a long-sleeved jacket (body), trousers (legs) and sneakers (feet),
with a fixed charcoal undershirt, belt, white cuffs and white soles. Add-on 1 is a trainer cap
(body colour, white front), add-on 2 a backpack (feet colour, like the sneakers) with a Poke Ball on it.

Writes, in the outfit layout of the client (64x64 frames, 2 layers, 4 directions x 3 frames x
3 add-on patterns): frames/<pattern>_<direction>_<frame>_<layer>.png, sheet.png (rows: pattern
and layer, columns: frame and direction) and preview images coloured like the client does.
"""
import os
import sys

from PIL import Image

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import outfit_sprites  # noqa: E402

ROOT = outfit_sprites.ROOT
BODY_LOOK = 1385
OUT = os.path.join(ROOT, 'art/sprites/outfits/ace_trainer')
NORTH, EAST, SOUTH, WEST = range(4)
SIZE = 64

HEAD, BODY, LEGS, FEET = (255, 255, 0), (255, 0, 0), (0, 255, 0), (0, 0, 255)
OUTLINE = (0, 0, 0)
SHIRT = (78, 82, 98)
BELT = (58, 46, 40)
BUCKLE = (226, 196, 92)
WHITE = (240, 240, 236)
BALL_RED = (222, 48, 40)
BALL_DARK = (24, 24, 28)


def lum(p):
    return int(0.3 * p[0] + 0.59 * p[1] + 0.11 * p[2])


def grey(v):
    v = max(0, min(255, int(v)))
    return (v, v, v)


def classify(base, mask):
    """Labels every pixel: '.', 'k' outline, 's' skin, 'g' unmasked grey, 'H', 'B', 'L', 'F'."""
    bp, mp = base.load(), mask.load()
    grid = {}
    for y in range(SIZE):
        for x in range(SIZE):
            b, m = bp[x, y], mp[x, y]
            if b[3] == 0:
                continue
            c = 'g'
            if m[3] and max(m[:3]) > 200:
                r, g, bl = m[:3]
                c = 'H' if r > 200 and g > 200 else 'B' if r > 200 else 'L' if g > 200 else 'F'
            elif max(b[:3]) < 40:
                c = 'k'
            elif b[0] - b[2] > 30:
                c = 's'
            grid[(x, y)] = c
    return grid


def components(points):
    points, comps = set(points), []
    while points:
        stack, comp = [points.pop()], set()
        while stack:
            p = stack.pop()
            comp.add(p)
            for q in ((p[0] + 1, p[1]), (p[0] - 1, p[1]), (p[0], p[1] + 1), (p[0], p[1] - 1)):
                if q in points:
                    points.remove(q)
                    stack.append(q)
        comps.append(comp)
    return comps


class Layer:
    """A frame being drawn: colour and mask per pixel."""

    def __init__(self):
        self.color, self.mask = {}, {}

    def put(self, p, color, mask=None):
        if not (0 <= p[0] < SIZE and 0 <= p[1] < SIZE):
            return
        self.color[p] = color
        if mask:
            self.mask[p] = mask
        else:
            self.mask.pop(p, None)

    def outline(self, keep=()):
        """Black outline on the transparent pixels around the drawing."""
        add = set()
        for (x, y) in self.color:
            for q in ((x + 1, y), (x - 1, y), (x, y + 1), (x, y - 1)):
                if q not in self.color and q not in keep and 0 <= q[0] < SIZE and 0 <= q[1] < SIZE:
                    add.add(q)
        for q in add:
            self.put(q, OUTLINE)

    def images(self):
        base = Image.new('RGBA', (SIZE, SIZE), (0, 0, 0, 0))
        mask = Image.new('RGBA', (SIZE, SIZE), (0, 0, 0, 0))
        for p, c in self.color.items():
            base.putpixel(p, c + (255,))
        for p, m in self.mask.items():
            mask.putpixel(p, m + (255,))
        return base, mask


def poke_ball(layer, x, y):
    """A 3x3 Poke Ball with its top-left at x, y."""
    for dx in range(3):
        layer.put((x + dx, y), BALL_RED)
        layer.put((x + dx, y + 1), BALL_DARK)
        layer.put((x + dx, y + 2), WHITE)
    layer.put((x + 1, y + 1), WHITE)


class Frame:
    def __init__(self, direction, base, mask):
        self.d = direction
        self.grid = classify(base, mask)
        self.px = base.load()
        skin = [p for p, c in self.grid.items() if c in 'sg']
        self.hy0 = min(p[1] for p in skin)
        comps = components(p for p in skin if p[1] <= self.hy0 + 9 or self.grid[p] == 's')
        top = min(skin, key=lambda p: (p[1], p[0]))
        self.head = {p for p in next(c for c in comps if top in c) if p[1] <= self.hy0 + 9}
        rest = set(skin) - self.head
        self.arms = [c for c in components(p for p in rest if self.grid[p] == 's') if len(c) > 3]
        self.shirt = {p for p in rest if self.grid[p] == 'g'}
        xs = [p[0] for p in self.head if p[1] <= self.hy0 + 6]
        self.hx0, self.hx1 = min(xs), max(xs)
        self.torso = [p for p, c in self.grid.items() if c == 'B']

    # -- base ------------------------------------------------------------------------------

    def draw_base(self):
        out = Layer()
        for p, c in self.grid.items():
            v = lum(self.px[p])
            if c == 'k':
                out.put(p, OUTLINE)
            elif c == 'B':
                out.put(p, grey(30 + v * 0.9), BODY)
            elif c == 'L':
                out.put(p, grey(20 + v * 0.85), LEGS)
            elif c == 'F':
                below = self.grid.get((p[0], p[1] + 1), '.')
                if below == '.' or (below == 'k' and self.grid.get((p[0], p[1] + 2), '.') == '.'):
                    out.put(p, WHITE)
                else:
                    out.put(p, grey(40 + v * 0.8), FEET)
            elif c == 'H':
                out.put(p, grey(v), HEAD)
            elif p in self.shirt:
                out.put(p, self.shirt_color(p, v))
            else:
                out.put(p, self.px[p][:3])

        self.draw_sleeves(out)
        self.draw_belt(out)
        self.draw_hair(out)
        out.outline()
        return out

    def shirt_color(self, p, v):
        """The undershirt; seen from the back, the Rider's number patch becomes a Poke Ball."""
        if self.d in (NORTH, WEST):
            ys = [q[1] for q in self.shirt]
            mid = (min(ys) + max(ys)) / 2
            return BALL_RED if p[1] < mid else WHITE
        f = v / 230
        return tuple(int(ch * f) for ch in SHIRT)

    def draw_sleeves(self, out):
        torso = set(self.torso)
        for arm in self.arms:
            shoulder = min(arm, key=lambda p: min(abs(p[0] - t[0]) + abs(p[1] - t[1]) for t in torso))
            dist = {p: ((p[0] - shoulder[0]) ** 2 + (p[1] - shoulder[1]) ** 2) ** 0.5 for p in arm}
            reach = max(dist.values())
            for p in arm:
                v = lum(self.px[p])
                if dist[p] < reach - 3.2:
                    out.put(p, grey(v * 0.95), BODY)
                elif dist[p] < reach - 2.2:
                    out.put(p, WHITE)

    def draw_belt(self, out):
        belt = sorted(p for p, c in self.grid.items()
                      if c == 'L' and self.grid.get((p[0], p[1] - 1)) == 'B')
        for p in belt:
            out.put(p, BELT)
        if belt and self.d != NORTH:
            out.put(belt[len(belt) // 2], BUCKLE)

    def draw_hair(self, out):
        d, x0, x1, y0 = self.d, self.hx0, self.hx1, self.hy0
        width = x1 - x0
        hair = set()
        for (x, y) in self.head:
            row = y - y0
            if d == NORTH:
                cover = row <= 7
            elif d == SOUTH:
                cover = row <= 2 or (row <= 3 and (x - x0) % 3 != 1) or \
                    (row <= 6 and (x <= x0 + 1 or x >= x1 - 1))
            elif d == EAST:
                cover = row <= 2 or (row <= 3 and (x - x0) % 3 == 0) or (x - x0) <= width * 0.45 and row <= 7
            else:
                cover = row <= 2 or (row <= 3 and (x - x0) % 3 == 0) or (x1 - x) <= width * 0.45 and row <= 7
            if cover:
                hair.add((x, y))
        hair |= set(self.spikes())
        for (x, y) in hair:
            row = y - y0
            v = 228 - row * 11
            if (x + y) % 4 == 0:
                v -= 28
            out.put((x, y), grey(v), HEAD)

    def spikes(self):
        """Spikes swept back, against the lean, so a cap can sit on top."""
        d, x0, x1, y0 = self.d, self.hx0, self.hx1, self.hy0
        pts = []

        def spike(x, y, dx, dy, n):
            for i in range(n):
                pts.append((x + dx * i, y + dy * i))
                pts.append((x + dx * i + (1 if dx == 0 else 0), y + dy * i + (1 if dy == 0 else 0)))

        if d == SOUTH:
            spike(x0 - 1, y0 + 2, -1, 0, 2)
            spike(x0 - 1, y0 + 4, -1, 1, 2)
            spike(x1 + 1, y0 + 2, 1, 0, 2)
            spike(x1 + 1, y0 + 4, 1, 1, 2)
            spike(x0 + 2, y0 - 1, -1, -1, 2)
            spike(x0 + 6, y0 - 1, 0, -1, 2)
        elif d == NORTH:
            spike(x0 - 1, y0 + 2, -1, 0, 2)
            spike(x0 - 1, y0 + 5, -1, 1, 2)
            spike(x1 + 1, y0 + 3, 1, 0, 2)
            spike(x1 + 1, y0 + 6, 1, 1, 1)
            spike(x0 + 3, y0 + 8, 0, 1, 2)
            spike(x0 + 6, y0 + 8, 0, 1, 2)
            spike(x0 + 2, y0 - 1, -1, -1, 2)
        elif d == EAST:
            spike(x0 - 1, y0 + 1, -1, -1, 2)
            spike(x0 - 1, y0 + 3, -1, 0, 3)
            spike(x0 - 1, y0 + 6, -1, 1, 2)
            spike(x0 + 4, y0 - 1, -1, -1, 2)
        else:
            spike(x1 + 1, y0 + 1, 1, -1, 2)
            spike(x1 + 1, y0 + 3, 1, 0, 3)
            spike(x1 + 1, y0 + 6, 1, 1, 2)
            spike(x1 - 4, y0 - 1, 1, -1, 2)
        return [p for p in pts if p not in self.grid or self.grid[p] in '.k']

    # -- add-on 1: cap ---------------------------------------------------------------------

    def draw_cap(self):
        out = Layer()
        d, x0, x1, y0 = self.d, self.hx0, self.hx1, self.hy0
        crown = {p for p in self.head if p[1] - y0 <= 2}
        crown |= {(x, y0 - 1) for x in range(x0 + 1, x1)}
        crown |= {(x, y0 - 2) for x in range(x0 + 3, x1 - 2)}
        front = set()
        if d == SOUTH:
            front = {(x, y) for (x, y) in crown if x0 + 3 <= x <= x1 - 3 and y0 - 1 <= y <= y0 + 1}
        elif d == EAST:
            front = {(x, y) for (x, y) in crown if x >= x1 - 3 and y0 - 1 <= y <= y0 + 1}
        elif d == WEST:
            front = {(x, y) for (x, y) in crown if x <= x0 + 3 and y0 - 1 <= y <= y0 + 1}
        for (x, y) in crown:
            v = 222 - (y - y0 + 2) * 12
            if d in (EAST, WEST) and (x - x0) in (0, x1 - x0):
                v -= 30
            if (x, y) in front:
                out.put((x, y), WHITE)
            else:
                out.put((x, y), grey(v), BODY)
        if d == SOUTH:
            mid = (x0 + x1) // 2
            out.put((mid, y0), BALL_RED)
            for x in range(x0, x1 + 1):
                out.put((x, y0 + 3), grey(150), BODY)
        elif d == EAST:
            for x in range(x1 - 1, x1 + 4):
                out.put((x, y0 + 3), grey(150), BODY)
            for x in range(x1 + 1, x1 + 3):
                out.put((x, y0 + 2), grey(175), BODY)
        elif d == WEST:
            for x in range(x0 - 3, x0 + 2):
                out.put((x, y0 + 3), grey(150), BODY)
            for x in range(x0 - 2, x0):
                out.put((x, y0 + 2), grey(175), BODY)
        else:
            mid = (x0 + x1) // 2
            out.put((mid, y0 + 2), BALL_DARK)
            out.put((mid - 1, y0 + 3), grey(160), BODY)
            out.put((mid + 1, y0 + 3), grey(160), BODY)
            out.put((mid, y0 + 3), grey(160), BODY)
        out.outline()
        return out

    # -- add-on 2: backpack ----------------------------------------------------------------

    def centerline(self):
        """x of the middle of the torso for each row, from the neck to the belt."""
        neck = ((self.hx0 + self.hx1) / 2, self.hy0 + 9)
        legs = [p for p, c in self.grid.items() if c == 'L']
        waist = min(p[1] for p in legs)
        belt = [p for p in legs if p[1] <= waist + 2]
        hip = (sum(p[0] for p in belt) / len(belt), sum(p[1] for p in belt) / len(belt))
        return lambda y: neck[0] + (hip[0] - neck[0]) * (y - neck[1]) / (hip[1] - neck[1])

    def run_at(self, x, y):
        """The torso pixels of row y around column x."""
        torso = set(self.torso)
        x = int(round(x))
        if (x, y) not in torso:
            near = [p[0] for p in torso if p[1] == y]
            if not near:
                return None
            x = min(near, key=lambda q: abs(q - x))
        lo = hi = x
        while (lo - 1, y) in torso or self.grid.get((lo - 1, y)) == 'g':
            lo -= 1
        while (hi + 1, y) in torso or self.grid.get((hi + 1, y)) == 'g':
            hi += 1
        return lo, hi

    def draw_backpack(self):
        out = Layer()
        d = self.d
        center = self.centerline()
        top = self.hy0 + 10
        pack = {}
        rows = 8 if d == NORTH else 7
        anchor = self.run_at(center(top + 1), top + 1)
        for i in range(rows):
            y = top + i
            shift = -int(i * 0.35)
            if d == NORTH:
                left = int(round(center(top + 3))) - 4 + shift
                span = range(left, left + 9)
            elif d == EAST:
                span = range(anchor[0] - 3 + shift, anchor[0] + 2 + shift)
            elif d == WEST:
                span = range(anchor[1] - 1 + shift, anchor[1] + 4 + shift)
            else:
                run = self.run_at(center(y), y)
                span = (run[0] + 1, run[1] - 1) if run and i < 6 else ()
            span = list(span)
            if d != SOUTH and i in (0, rows - 1) and len(span) > 2:
                span = span[1:-1]
            for x in span:
                pack[(x, y)] = i
        for (x, y), i in pack.items():
            if d == SOUTH:
                out.put((x, y), grey(120), FEET)
                continue
            v = 215 if i < 3 else 175
            if i == 3:
                v = 120
            if i == rows - 1 or (x, y + 1) not in pack:
                v = 130
            out.put((x, y), grey(v), FEET)
        if d == NORTH:
            xs = [x for x, y in pack if y == top + 4]
            poke_ball(out, (min(xs) + max(xs)) // 2 - 1, top + 4)
        elif d in (EAST, WEST):
            xs = [x for x, y in pack if y == top + 4]
            poke_ball(out, (min(xs) + max(xs)) // 2 - 1, top + 3)
        out.outline(keep=set(self.grid) if d == SOUTH else ())
        return out


def build():
    data = open(os.path.join(outfit_sprites.THINGS, 'data.dat'), 'rb').read()
    look = outfit_sprites.read_outfits(data)[BODY_LOOK]
    spr = outfit_sprites.Spr(os.path.join(outfit_sprites.THINGS, 'data.spr'))
    frames = {}
    for d in range(4):
        for f in range(look['frames']):
            base = outfit_sprites.frame_image(spr, look, 0, d, 0, 0, f)
            mask = outfit_sprites.frame_image(spr, look, 1, d, 0, 0, f)
            fr = Frame(d, base, mask)
            frames[(0, d, f)] = fr.draw_base().images()
            frames[(1, d, f)] = fr.draw_cap().images()
            frames[(2, d, f)] = fr.draw_backpack().images()
    return frames, look['frames']


def outfit_color(index):
    """Port of Outfit::getColor: the 133 colours of the outfit window."""
    steps, values = 19, 7
    if index >= steps * values:
        index = 0
    if index % steps:
        hue = index % steps / 18.0
        sat, val = [(0.25, 1), (0.25, 0.75), (0.5, 0.75), (0.667, 0.75), (1, 1), (1, 0.75),
                    (1, 0.5)][index // steps]
    else:
        hue, sat, val = 0, 0, 1 - index / steps / values
    if val == 0:
        return (0, 0, 0)
    if sat == 0:
        return grey(val * 255)
    if hue < 1 / 6:
        r, b = val, val * (1 - sat)
        g = b + (val - b) * 6 * hue
    elif hue < 2 / 6:
        g, b = val, val * (1 - sat)
        r = g - (val - b) * (6 * hue - 1)
    elif hue < 3 / 6:
        g, r = val, val * (1 - sat)
        b = r + (val - r) * (6 * hue - 2)
    elif hue < 4 / 6:
        b, r = val, val * (1 - sat)
        g = b - (val - r) * (6 * hue - 3)
    elif hue < 5 / 6:
        b, g = val, val * (1 - sat)
        r = g + (val - g) * (6 * hue - 4)
    else:
        r, g = val, val * (1 - sat)
        b = r - (val - g) * (6 * hue - 5)
    return (int(r * 255), int(g * 255), int(b * 255))


def colorize(base, mask, colors):
    """The look in the game: masked pixels are multiplied by the head/body/legs/feet colour."""
    out = base.copy()
    op, mp = out.load(), mask.load()
    keys = {HEAD: 0, BODY: 1, LEGS: 2, FEET: 3}
    for y in range(base.height):
        for x in range(base.width):
            m = mp[x, y]
            if m[3] and m[:3] in keys:
                c = colors[keys[m[:3]]]
                p = op[x, y]
                op[x, y] = (p[0] * c[0] // 255, p[1] * c[1] // 255, p[2] * c[2] // 255, p[3])
    return out


def dressed(frames, d, f, colors, addons=(1, 2)):
    img = Image.new('RGBA', (SIZE, SIZE), (0, 0, 0, 0))
    for pattern in (0,) + tuple(addons):
        base, mask = frames[(pattern, d, f)]
        img.alpha_composite(colorize(base, mask, colors))
    return img


def main():
    out = sys.argv[1] if len(sys.argv) > 1 else OUT
    frames, count = build()
    os.makedirs(os.path.join(out, 'frames'), exist_ok=True)
    sheet = Image.new('RGBA', (SIZE * 4 * count, SIZE * 6), (0, 0, 0, 0))
    for (pattern, d, f), (base, mask) in frames.items():
        for layer, img in enumerate((base, mask)):
            img.save(os.path.join(out, 'frames', '%d_%d_%d_%d.png' % (pattern, d, f, layer)))
            sheet.paste(img, ((f * 4 + d) * SIZE, (pattern * 2 + layer) * SIZE))
    sheet.save(os.path.join(out, 'sheet.png'))
    print('%d frames -> %s' % (len(frames) * 2, os.path.relpath(out, ROOT)))


if __name__ == '__main__':
    main()
