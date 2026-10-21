#!/usr/bin/env python3
"""Pokemon-themed mouse cursors: every map and window cursor, plus the new use-with cursors for potions.

    scripts/art/pokemon_cursors.py --shot <game screenshot>

Writes build/pokemon-cursors/:

board-map.png       map and window cursors: today's next to the new one at 4x, its frames, and at real size
board-use-with.png  the use-with cursors (Poke Ball, Pokedex and Order are today's; the potions are new)
cursors.gif         every cursor animating at 3x
files/<name>.png    the cursors as animated PNGs, named like the files in data/cursors

With --install the cursors and cursors.otml also go to pokeverse-modern/data/cursors, which the
assembled client copies over Redemption's own.

The arrow cursors keep the click on the arrow's tip, so aiming feels the same as today. The ring cursors
(target and the potions) click in the middle, like the Poke Ball cursor.
"""
import argparse
import math
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter, ImageFont

REPO = Path(__file__).resolve().parents[2]
TODAY = REPO / 'core/client-redemption/data/cursors'
TODAY_MODERN = REPO / 'core/client-redemption/pokeverse-modern/data/cursors'
S = 8
FRAMES = 8
FRAME_MS = 110
# the 32x32 drawings ship at 40x40: the stock cursors (23 to 32 pixels) are hard to see on the map
OUTPUT_SIZE = {32: 40}

DARK = (11, 18, 34)
RED = (226, 52, 52)
RED_DARK = (150, 24, 32)
WHITE = (246, 248, 252)
GREY = (200, 206, 218)
GOLD = (255, 214, 90)
GOLD_DARK = (190, 132, 30)
ORANGE = (255, 138, 40)
CYAN = (84, 214, 255)
BLUE = (60, 150, 255)
GREEN = (90, 220, 120)
PURPLE = (168, 92, 220)
PINK = (255, 120, 190)
BROWN = (196, 112, 52)
BROWN_DARK = (120, 64, 28)


def s(v):
    return int(round(v * S))


def font(size, bold=False):
    name = 'DejaVuSans-Bold.ttf' if bold else 'DejaVuSans.ttf'
    return ImageFont.truetype(f'/usr/share/fonts/truetype/dejavu/{name}', size)


def layer(size):
    return Image.new('RGBA', (s(size), s(size)), (0, 0, 0, 0))


def finish(im, size, shadow=True):
    if shadow:
        alpha = im.getchannel('A').filter(ImageFilter.GaussianBlur(s(0.8)))
        sh = Image.new('RGBA', im.size, (0, 0, 0, 0))
        sh.putalpha(alpha.point(lambda a: int(a * 0.5)))
        base = Image.new('RGBA', im.size, (0, 0, 0, 0))
        base.alpha_composite(sh, (s(0.8), s(1.1)))
        base.alpha_composite(im)
        im = base
    out = OUTPUT_SIZE.get(size, size)
    return im.resize((out, out), Image.LANCZOS)


def circle(d, cx, cy, r, **kw):
    d.ellipse((s(cx - r), s(cy - r), s(cx + r), s(cy + r)), **kw)


def poly(d, points, fill, outline=DARK, width=1.2):
    pts = [(s(x), s(y)) for x, y in points]
    d.polygon(pts, fill=outline)
    d.line(pts + [pts[0]], fill=outline, width=int(s(width) * 2), joint='curve')
    d.polygon(pts, fill=fill)


def stroke(d, points, color, width, outline=DARK, ow=1.0):
    pts = [(s(x), s(y)) for x, y in points]
    if outline:
        d.line(pts, fill=outline, width=int(s(width + 2 * ow)), joint='curve')
        for x, y in (pts[0], pts[-1]):
            r = s(width + 2 * ow) / 2
            d.ellipse((x - r, y - r, x + r, y + r), fill=outline)
    d.line(pts, fill=color, width=int(s(width)), joint='curve')
    for x, y in (pts[0], pts[-1]):
        r = s(width) / 2
        d.ellipse((x - r, y - r, x + r, y + r), fill=color)


def arc(d, cx, cy, r, start, end, color, width, outline=DARK, ow=1.0):
    box = (s(cx - r), s(cy - r), s(cx + r), s(cy + r))
    if outline:
        d.arc(box, start - 2, end + 2, fill=outline, width=int(s(width + 2 * ow)))
    d.arc(box, start, end, fill=color, width=int(s(width)))


def wave(t):
    return 0.5 - 0.5 * math.cos(2 * math.pi * t)


def ball(r, angle=0.0, top=RED):
    side = s(2 * r + 4)
    im = Image.new('RGBA', (side, side), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    c = side / 2 / S
    circle(d, c, c, r, fill=DARK)
    inner = r - max(0.9, r * 0.14)
    box = (s(c - inner), s(c - inner), s(c + inner), s(c + inner))
    d.pieslice(box, 180, 360, fill=top)
    d.pieslice(box, 0, 180, fill=WHITE)
    band = max(0.9, r * 0.17)
    d.rectangle((s(c - inner), s(c - band / 2), s(c + inner), s(c + band / 2)), fill=DARK)
    circle(d, c, c, r * 0.4, fill=DARK)
    circle(d, c, c, r * 0.4 - 0.8, fill=WHITE)
    return im.rotate(angle, resample=Image.BICUBIC)


def paste_center(im, part, cx, cy):
    im.alpha_composite(part, (int(s(cx) - part.width / 2), int(s(cy) - part.height / 2)))


def sparkle(d, cx, cy, r, color, alpha=255):
    c = color + (alpha,)
    pts = []
    for k in range(8):
        a = math.radians(45 * k - 90)
        rr = r if k % 2 == 0 else r * 0.32
        pts.append((s(cx + rr * math.cos(a)), s(cy + rr * math.sin(a))))
    d.polygon(pts, fill=c)


# The Poke Ball arrow: red top, white bottom, a dark band across, like a Poke Ball.

ARROW = [(1.5, 1.2), (1.5, 21.0), (6.4, 16.6), (9.6, 23.6), (13.0, 22.1), (9.9, 15.3), (16.2, 15.3)]


def arrow(im):
    d = ImageDraw.Draw(im)
    poly(d, ARROW, WHITE)
    red = Image.new('RGBA', im.size, (0, 0, 0, 0))
    rd = ImageDraw.Draw(red)
    rd.polygon([(s(x), s(y)) for x, y in ARROW], fill=RED)
    mask = Image.new('L', im.size, 0)
    ImageDraw.Draw(mask).rectangle((0, 0, im.width, s(10.6)), fill=255)
    clipped = Image.new('RGBA', im.size, (0, 0, 0, 0))
    clipped.paste(red, (0, 0), mask)
    im.alpha_composite(clipped)
    d.line([(s(1.5), s(11.1)), (s(12.0), s(11.1))], fill=DARK, width=s(1.2))
    circle(d, 4.6, 11.1, 2.2, fill=DARK)
    circle(d, 4.6, 11.1, 1.2, fill=WHITE)
    d.line([(s(2.7), s(3.4)), (s(2.7), s(7.6))], fill=(255, 150, 150), width=s(0.7))


def with_arrow(size=32):
    def deco(fn):
        def run(t):
            im = layer(size)
            arrow(im)
            fn(im, ImageDraw.Draw(im), t)
            return finish(im, size)
        run.__name__ = fn.__name__
        return run
    return deco


@with_arrow()
def default(im, d, t):
    pass


@with_arrow()
def walk(im, d, t):
    """Paw prints stepping down and to the right."""
    steps = [(17.5, 20.5, -1), (22.0, 23.5, 1), (24.5, 28.5, -1)]
    for k, (x, y, side) in enumerate(steps):
        phase = (t * 3 - k) % 3
        if phase > 2.2:
            continue
        a = int(255 * (1.0 if phase < 1.2 else 1 - (phase - 1.2)))
        a = max(0, min(255, a))
        x += side * 1.6
        circle(d, x, y, 2.7, fill=DARK + (a,))
        circle(d, x, y, 1.9, fill=BROWN + (a,))
        for dx, dy in ((-2.4, -2.6), (0, -3.6), (2.4, -2.6)):
            circle(d, x + dx, y + dy, 1.35, fill=DARK + (a,))
            circle(d, x + dx, y + dy, 0.75, fill=BROWN + (a,))


@with_arrow()
def attack(im, d, t):
    """Three claw scratches slash in, then a hit spark."""
    grow = min(1.0, t * 2.2)
    fade = 1.0 if t < 0.7 else max(0.0, 1 - (t - 0.7) / 0.3)
    for k in range(3):
        x0, y0 = 22.5 + k * 3.2, 15.5
        x1, y1 = 16.5 + k * 3.2, 29.5
        xe, ye = x0 + (x1 - x0) * grow, y0 + (y1 - y0) * grow
        if grow > 0.05:
            a = int(255 * fade)
            stroke(d, [(x0, y0), (xe, ye)], (255, 236, 200, a), 1.3, outline=ORANGE + (a,), ow=0.9)
    if 0.35 < t < 0.8:
        r = 3.6 * math.sin(math.pi * (t - 0.35) / 0.45)
        sparkle(d, 27.5, 21.0, r + 1.0, DARK, 200)
        sparkle(d, 27.5, 21.0, r, GOLD)


@with_arrow()
def talk(im, d, t):
    """A speech bubble with dots typing in."""
    x0, y0, x1, y1 = 15.5, 15.5, 31.0, 26.5
    d.rounded_rectangle((s(x0 - 1), s(y0 - 1), s(x1 + 1), s(y1 + 1)), radius=s(4.5), fill=DARK)
    poly(d, [(18.5, 25.5), (17.0, 31.0), (23.0, 25.5)], WHITE, width=1.0)
    d.rounded_rectangle((s(x0), s(y0), s(x1), s(y1)), radius=s(3.8), fill=WHITE)
    lit = int(t * 4) % 4
    for k in range(3):
        on = k < lit
        circle(d, 19.3 + k * 4.0, 21.0, 1.35, fill=(40, 120, 230) if on else (170, 182, 204))


def bag(d, x, y, bob):
    """The trainer bag: a rounded satchel with a Poke Ball clasp."""
    y += bob
    stroke(d, [(x + 3, y + 1.5), (x + 4.5, y - 2.5), (x + 9.5, y - 2.5), (x + 11, y + 1.5)], BROWN_DARK, 1.1, ow=0.8)
    d.rounded_rectangle((s(x - 1), s(y - 1), s(x + 15), s(y + 12)), radius=s(3.5), fill=DARK)
    d.rounded_rectangle((s(x), s(y), s(x + 14), s(y + 11)), radius=s(3), fill=BROWN)
    d.pieslice((s(x), s(y - 4.5), s(x + 14), s(y + 7)), 0, 180, fill=(232, 74, 60))
    d.line([(s(x + 0.5), s(y + 1.3)), (s(x + 13.5), s(y + 1.3))], fill=DARK, width=s(0.8))
    paste = ball(2.4)
    return paste, (x + 7, y + 6.0)


@with_arrow()
def container(im, d, t):
    """The bag, bobbing."""
    b, (cx, cy) = bag(d, 16.0, 18.5, -0.9 * wave(t))
    paste_center(im, b, cx, cy)


@with_arrow()
def quickloot(im, d, t):
    """The bag with sparkles: quick loot."""
    b, (cx, cy) = bag(d, 16.0, 18.5, 0)
    paste_center(im, b, cx, cy)
    for k, (x, y) in enumerate(((29.0, 15.0), (14.5, 28.5), (30.0, 27.0))):
        a = wave(t + k / 3)
        if a > 0.15:
            sparkle(d, x, y, 1.0 + 1.8 * a, DARK, int(180 * a))
            sparkle(d, x, y, 0.6 + 1.6 * a, GOLD, int(255 * a))


@with_arrow()
def use(im, d, t):
    """A Game Boy A button: press to use doors, levers and switches."""
    cx, cy = 24.0, 23.5
    press = 0.9 * max(0.0, math.sin(2 * math.pi * t))
    r = 6.4 + 1.6 * wave(t)
    arc(d, cx, cy, r + 1.5, 0, 360, (255, 255, 255, int(160 * (1 - wave(t)))), 0.8, outline=None)
    circle(d, cx, cy + 1.0, 6.0, fill=DARK)
    circle(d, cx, cy + 0.6, 5.1, fill=RED_DARK)
    circle(d, cx, cy - 0.4 + press, 5.1, fill=DARK)
    circle(d, cx, cy - 0.4 + press, 4.3, fill=(204, 40, 80))
    f = font(s(6.2), True)
    d.text((s(cx), s(cy - 0.5 + press)), 'A', font=f, fill=WHITE, anchor='mm')


@with_arrow()
def look(im, d, t):
    """A magnifier with a Pokedex-blue lens."""
    cx, cy = 22.0, 21.0
    stroke(d, [(cx + 4.0, cy + 4.0), (cx + 8.5, cy + 8.5)], RED, 2.0)
    circle(d, cx, cy, 5.8, fill=DARK)
    circle(d, cx, cy, 4.8, fill=WHITE)
    lit = 0.6 + 0.4 * wave(t)
    circle(d, cx, cy, 3.9, fill=tuple(int(c * lit) for c in BLUE))
    circle(d, cx - 1.4, cy - 1.5, 1.2, fill=(255, 255, 255, 220))


def pointerbutton(t):
    """A pointing hand in a trainer's fingerless glove: blue on the back of the hand, a red cuff."""
    im = layer(32)
    d = ImageDraw.Draw(im)
    skin = (255, 218, 182)
    glove = (44, 62, 120)
    o = 1.1
    parts = [
        ((6.6, 0.8, 11.0, 15.0), 2.2, skin),
        ((10.6, 8.6, 14.6, 15.5), 2.0, skin),
        ((14.2, 9.4, 18.0, 15.8), 1.9, skin),
        ((17.6, 10.6, 21.2, 16.4), 1.8, skin),
        ((5.6, 12.6, 21.2, 24.2), 3.6, glove),
        ((5.0, 21.6, 21.8, 26.0), 1.2, RED),
    ]
    for (x0, y0, x1, y1), r, _ in parts:
        d.rounded_rectangle((s(x0 - o), s(y0 - o), s(x1 + o), s(y1 + o)), radius=s(r + o), fill=DARK)
    poly(d, [(2.2, 15.6), (5.4, 13.8), (8.8, 19.0), (6.2, 21.2)], skin, width=1.1)
    for (x0, y0, x1, y1), r, fill in parts:
        d.rounded_rectangle((s(x0), s(y0), s(x1), s(y1)), radius=s(r), fill=fill)
    for x in (10.8, 14.4, 17.8):
        d.line([(s(x), s(13.0)), (s(x), s(15.0))], fill=DARK, width=s(0.6))
    d.line([(s(7.6), s(2.4)), (s(7.6), s(8.0))], fill=(255, 255, 255, 150), width=s(0.7))
    paste_center(im, ball(2.6), 13.4, 18.4)
    return finish(im, 32)


def text_beam(t):
    im = layer(32)
    d = ImageDraw.Draw(im)
    stroke(d, [(8, 5), (8, 25)], WHITE, 1.4)
    for y in (4.2, 25.8):
        stroke(d, [(4.6, y), (11.4, y)], RED, 1.6)
    return finish(im, 32)


def resize_arrow(vertical):
    def run(t):
        im = layer(32)
        d = ImageDraw.Draw(im)
        a, b = 3.0, 29.0
        stroke(d, [(a + 3, 16), (b - 3, 16)], WHITE, 1.8)
        poly(d, [(a, 16), (a + 6, 11.4), (a + 6, 20.6)], RED)
        poly(d, [(b, 16), (b - 6, 11.4), (b - 6, 20.6)], RED)
        paste_center(im, ball(3.4), 16, 16)
        if vertical:
            im = im.rotate(90, resample=Image.BICUBIC)
        return finish(im, 32)
    return run


def target(t):
    """Use with anything else: a red and white crosshair that breathes."""
    im = layer(32)
    d = ImageDraw.Draw(im)
    c = 16
    gap = 5.0 + 1.4 * wave(t)
    arc(d, c, c, 10.5, 0, 360, (255, 255, 255, 170), 0.9, outline=None)
    for k in range(4):
        a = math.radians(90 * k)
        ux, uy = math.cos(a), math.sin(a)
        px, py = -uy, ux
        tip = (c + ux * gap, c + uy * gap)
        base = (c + ux * (gap + 6.5), c + uy * (gap + 6.5))
        poly(d, [tip, (base[0] + px * 3.6, base[1] + py * 3.6), (base[0] - px * 3.6, base[1] - py * 3.6)],
             RED if k % 2 == 0 else WHITE, width=1.0)
    circle(d, c, c, 1.7, fill=DARK)
    circle(d, c, c, 0.9, fill=WHITE)
    return finish(im, 32)


# The potion family: a turning dashed ring in the item's colour, the item tucked in the lower right,
# spraying or sparkling towards the middle, where the click lands (like the Poke Ball cursor).

def ring(im, d, t, color, size=48):
    c = size / 2
    g = Image.new('RGBA', im.size, (0, 0, 0, 0))
    circle(ImageDraw.Draw(g), c, c, 12.5, outline=color + (110,), width=s(3.5))
    im.alpha_composite(g.filter(ImageFilter.GaussianBlur(s(1.4))))
    turn = 45 * t
    for k in range(8):
        a = turn + 45 * k
        arc(d, c, c, 13.0, a + 6, a + 33, color, 2.2)
    circle(d, c, c, 2.0, fill=DARK)
    circle(d, c, c, 1.1, fill=WHITE)


def mist(im, t, color, origin=(31, 31)):
    fx = Image.new('RGBA', im.size, (0, 0, 0, 0))
    d = ImageDraw.Draw(fx)
    ox, oy = origin
    for k in range(3):
        p = (t + k / 3) % 1.0
        x = ox + (24 - ox) * p * 0.85 + (k - 1) * 1.6 * p
        y = oy + (24 - oy) * p * 0.85 - (k - 1) * 1.6 * p
        r = 1.2 + 2.4 * p
        a = int(255 * (1 - p * 0.75))
        circle(d, x, y, r, fill=color + (a,))
    im.alpha_composite(fx)


def spray_bottle(body, cap=WHITE):
    """A spray potion leaning towards the middle, nozzle at (x, y)."""
    im = Image.new('RGBA', (s(20), s(20)), (0, 0, 0, 0))
    bd = ImageDraw.Draw(im)
    bd.rounded_rectangle((s(5.2), s(1.0), s(10.8), s(6.0)), radius=s(1.2), fill=DARK)
    bd.rectangle((s(6.2), s(2.0), s(9.8), s(6.0)), fill=cap)
    bd.rectangle((s(2.6), s(0.0), s(6.4), s(2.4)), fill=DARK)
    bd.rectangle((s(3.4), s(0.6), s(6.4), s(1.8)), fill=cap)
    bd.rounded_rectangle((s(2.8), s(5.2), s(13.2), s(19.0)), radius=s(3.0), fill=DARK)
    bd.rounded_rectangle((s(3.9), s(6.3), s(12.1), s(17.9)), radius=s(2.2), fill=body)
    bd.rectangle((s(3.9), s(10.0), s(12.1), s(13.4)), fill=WHITE)
    bd.rounded_rectangle((s(5.0), s(7.2), s(6.4), s(9.4)), radius=s(0.6), fill=(255, 255, 255, 150))
    im = im.resize((int(im.width * 1.25), int(im.height * 1.25)), Image.LANCZOS)
    return im.rotate(40, resample=Image.BICUBIC, expand=True)


def potion(t):
    im = layer(48)
    d = ImageDraw.Draw(im)
    ring(im, d, t, PINK)
    mist(im, t, (255, 170, 225))
    paste_center(im, spray_bottle(PURPLE), 35.5, 35.0)
    return finish(im, 48)


def antidote(t):
    im = layer(48)
    d = ImageDraw.Draw(im)
    ring(im, d, t, GREEN)
    mist(im, t, (150, 255, 170))
    paste_center(im, spray_bottle((60, 170, 90), cap=(255, 214, 90)), 35.5, 35.0)
    return finish(im, 48)


def revive(t):
    """Revive: a gold crystal that glints, with sparkles drifting to the middle."""
    im = layer(48)
    d = ImageDraw.Draw(im)
    ring(im, d, t, GOLD)
    cx, cy = 37.0, 37.0
    poly(d, [(cx, cy - 7.5), (cx + 5.5, cy), (cx, cy + 7.5), (cx - 5.5, cy)], (255, 226, 80), width=1.2)
    poly(d, [(cx, cy - 4.2), (cx + 2.6, cy), (cx, cy + 4.2), (cx - 2.6, cy)], (255, 250, 200), width=0.01)
    d.line([(s(cx - 5.5), s(cy)), (s(cx + 5.5), s(cy))], fill=GOLD_DARK, width=s(0.6))
    fx = Image.new('RGBA', im.size, (0, 0, 0, 0))
    fd = ImageDraw.Draw(fx)
    for k in range(3):
        p = (t + k / 3) % 1.0
        x, y = cx - 3 + (24 - cx) * p * 0.8, cy - 3 + (24 - cy) * p * 0.8
        a = int(255 * (1 - p * 0.7))
        sparkle(fd, x, y, 3.4 * (1 - p) + 1.6, DARK, a // 2)
        sparkle(fd, x, y, 2.8 * (1 - p) + 1.2, (255, 250, 210), a)
    im.alpha_composite(fx)
    return finish(im, 48)


def elixir(t):
    """Elixir: a corked bottle; blue drops rise to the middle (it restores move uses)."""
    im = layer(48)
    d = ImageDraw.Draw(im)
    ring(im, d, t, CYAN)
    cx, top = 37.5, 28.0
    d.rounded_rectangle((s(cx - 2.6), s(top - 0.8), s(cx + 2.6), s(top + 3.0)), radius=s(1), fill=DARK)
    d.rectangle((s(cx - 1.7), s(top), s(cx + 1.7), s(top + 2.6)), fill=BROWN)
    d.ellipse((s(cx - 6.6), s(top + 2.0), s(cx + 6.6), s(top + 16.0)), fill=DARK)
    d.ellipse((s(cx - 5.5), s(top + 3.1), s(cx + 5.5), s(top + 14.9)), fill=(220, 236, 250))
    d.chord((s(cx - 5.5), s(top + 3.1), s(cx + 5.5), s(top + 14.9)), 10, 170, fill=BLUE)
    circle(d, cx - 2.2, top + 6.6, 1.1, fill=(255, 255, 255, 220))
    fx = Image.new('RGBA', im.size, (0, 0, 0, 0))
    fd = ImageDraw.Draw(fx)
    for k in range(3):
        p = (t + k / 3) % 1.0
        x, y = cx - 4 + (24 - cx + 4) * p * 0.85, top + (24 - top) * p * 0.85
        a = int(255 * (1 - p * 0.7))
        circle(fd, x, y, 1.9 + 0.6 * (1 - p), fill=DARK + (a,))
        circle(fd, x, y, 1.2 + 0.6 * (1 - p), fill=CYAN + (a,))
    im.alpha_composite(fx)
    return finish(im, 48)


def energy(t):
    """Energy drink: a can with a lightning bolt; little bolts zip to the middle."""
    im = layer(48)
    d = ImageDraw.Draw(im)
    ring(im, d, t, (255, 190, 40))
    x0, y0 = 32.5, 29.0
    d.rounded_rectangle((s(x0 - 1), s(y0 - 1), s(x0 + 10.5), s(y0 + 16)), radius=s(2.5), fill=DARK)
    d.rectangle((s(x0 + 0.2), s(y0 + 0.2), s(x0 + 9.3), s(y0 + 2.2)), fill=GREY)
    d.rectangle((s(x0 + 0.2), s(y0 + 2.2), s(x0 + 9.3), s(y0 + 14.8)), fill=(40, 70, 200))
    poly(d, [(x0 + 5.8, y0 + 3.4), (x0 + 2.2, y0 + 9.2), (x0 + 4.8, y0 + 9.2), (x0 + 3.4, y0 + 13.8),
             (x0 + 7.4, y0 + 7.6), (x0 + 4.8, y0 + 7.6)], (255, 222, 60), width=0.6)
    fx = Image.new('RGBA', im.size, (0, 0, 0, 0))
    fd = ImageDraw.Draw(fx)
    for k in range(2):
        p = (t + k / 2) % 1.0
        x, y = x0 - 1 + (24 - x0 + 1) * p * 0.85, y0 + (24 - y0) * p * 0.85
        a = int(255 * (1 - p * 0.7))
        stroke(fd, [(x + 1.6, y - 1.8), (x - 0.4, y), (x + 0.8, y + 0.4), (x - 1.2, y + 2.4)],
               (255, 230, 80, a), 1.0, outline=DARK + (a,), ow=0.6)
    im.alpha_composite(fx)
    return finish(im, 48)


def static(fn):
    return lambda: [fn(0)]


def animated(fn, n=FRAMES):
    return lambda: [fn(i / n) for i in range(n)]


def hot(x, y, size=32):
    """A hot spot drawn on the size grid, where the shipped file is bigger."""
    k = OUTPUT_SIZE.get(size, size) / size
    return (round(x * k), round(y * k))


# name, today's file, today's directory, frames, hot spot, when it shows
MAP_CURSORS = [
    ('default', 'default_tibia', TODAY, static(default), hot(1, 1), 'Everywhere else'),
    ('walk', 'walkcursor', TODAY, animated(walk), hot(1, 1), 'Map: a tile you can walk to'),
    ('attack', 'attackcursor', TODAY, animated(attack), hot(1, 1), 'Map: a wild Pokemon you can attack'),
    ('talk', 'talkcursor', TODAY, animated(talk), hot(1, 1), 'Map: an NPC'),
    ('containercursor', 'containercursor', TODAY, animated(container), hot(1, 1), 'Map: a bag, chest or body to open'),
    ('quicklootcursor', 'quicklootcursor', TODAY, animated(quickloot), hot(1, 1), 'Map: a body with quick loot'),
    ('pointinghand', 'pointinghand', TODAY, animated(use), hot(1, 1), 'Map: something to use (doors, levers)'),
    ('lookcursor', 'lookcursor', TODAY, animated(look), hot(1, 1), 'Look (defined, unused today)'),
    ('pointerbutton', 'pointerbutton', TODAY, static(pointerbutton), hot(8, 1), 'Hovering a button'),
    ('text', 'textcursor', TODAY, static(text_beam), hot(8, 15), 'Hovering a text field'),
    ('horizontal', 'horizontalcursor', TODAY, static(resize_arrow(False)), hot(16, 16), 'Resizing a panel sideways'),
    ('vertical', 'verticalcursor', TODAY, static(resize_arrow(True)), hot(16, 16), 'Resizing a panel up or down'),
]

USE_CURSORS = [
    ('target', 'targetcursor', TODAY, animated(target), hot(16, 16), 'Use with... any other item'),
    ('ball', 'ballcursor', TODAY_MODERN, None, (24, 24), 'Use with... a Poke Ball (kept)'),
    ('dex', 'dexcursor', TODAY_MODERN, None, (24, 24), 'Use with... the Pokedex (kept)'),
    ('order', 'ordercursor', TODAY_MODERN, None, (24, 24), 'Use with... the Order (kept)'),
    ('potion', None, None, animated(potion), (24, 24), 'NEW: Potion, Super, Hyper, Max Potion'),
    ('revive', None, None, animated(revive), (24, 24), 'NEW: Revive'),
    ('antidote', None, None, animated(antidote), (24, 24), 'NEW: Antidote'),
    ('elixir', None, None, animated(elixir), (24, 24), 'NEW: Elixir'),
    ('energy', None, None, animated(energy), (24, 24), 'NEW: Energy drinks'),
]


def load_frames(path):
    im = Image.open(path)
    out = []
    for i in range(getattr(im, 'n_frames', 1)):
        im.seek(i)
        out.append(im.convert('RGBA'))
    return out


def save_apng(frames_, path):
    if len(frames_) == 1:
        frames_[0].save(path)
        return
    frames_[0].save(path, save_all=True, append_images=frames_[1:], duration=FRAME_MS, loop=0, disposal=1, blend=0)


def text(d, xy, s_, size, color=(232, 238, 250), bold=False):
    d.text(xy, s_, font=font(size, bold), fill=color)


def zoom(cur, factor):
    return cur.resize((cur.width * factor, cur.height * factor), Image.NEAREST)


GROUNDS = [(969, 234), (875, 600), (234, 469), (781, 187), (980, 700)]


def on_ground(shot, cur, hot, k, w=96, h=96):
    gx, gy = GROUNDS[k % len(GROUNDS)]
    crop = shot.crop((gx - w // 2, gy - h // 2, gx + w // 2, gy + h // 2)).convert('RGBA')
    crop.alpha_composite(cur, (w // 2 - hot[0], h // 2 - hot[1]))
    return crop


def build_board(shot, rows, title, subtitle, out):
    row_h = 152
    W, H = 1440, 120 + row_h * len(rows)
    board = Image.new('RGBA', (W, H), (10, 17, 32, 255))
    d = ImageDraw.Draw(board)
    text(d, (32, 24), title, 28, bold=True)
    text(d, (32, 64), subtitle, 15, (170, 186, 214))
    x_today, x_new, x_strip, x_map = 300, 400, 560, 1320
    for x, label in ((x_today, 'Today'), (x_new, 'New (4x)'), (x_strip, 'Animation frames (2x)'),
                     (x_map - 4, 'Real size')):
        text(d, (x, 94), label, 13, (150, 168, 200), bold=True)
    y = 114
    for k, (name, old, old_dir, made, hot, when, frames_) in enumerate(rows):
        d.rounded_rectangle((20, y, W - 20, y + row_h - 8), radius=8, fill=(18, 28, 50), outline=(44, 66, 108))
        new_tag = when.startswith('NEW')
        text(d, (36, y + 14), name, 17, GOLD if not new_tag else (120, 230, 150), bold=True)
        text(d, (36, y + 40), when.replace('NEW: ', ''), 13, (200, 212, 232))
        n = len(frames_)
        size = frames_[0].width
        text(d, (36, y + 62), f'{size}x{size}, {n} frame{"s" if n > 1 else ""}', 12, (130, 148, 180))
        if old:
            o = load_frames(old_dir / f'{old}.png')[0]
            cell = Image.new('RGBA', (80, 80), (32, 46, 78, 255))
            f = 2 if o.width <= 32 else 1
            oz = zoom(o, f)
            cell.alpha_composite(oz, ((80 - oz.width) // 2, (80 - oz.height) // 2))
            board.alpha_composite(cell, (x_today, y + 32))
        else:
            d.rounded_rectangle((x_today, y + 32, x_today + 80, y + 112), radius=4, outline=(60, 80, 120))
            text(d, (x_today + 22, y + 64), 'none', 13, (110, 126, 160))
        big = Image.new('RGBA', (136, 136), (32, 46, 78, 255))
        z = frames_[min(2, n - 1)].resize((128, 128), Image.LANCZOS)
        big.alpha_composite(z, ((136 - z.width) // 2, (136 - z.height) // 2))
        board.alpha_composite(big, (x_new, y + 4))
        for j, fr in enumerate(frames_[:8]):
            cell = Image.new('RGBA', (88, 88), (32, 46, 78, 255))
            fz = fr.resize((64, 64), Image.LANCZOS) if size <= 32 else fr.resize((80, 80), Image.LANCZOS)
            cell.alpha_composite(fz, ((88 - fz.width) // 2, (88 - fz.height) // 2))
            board.alpha_composite(cell, (x_strip + j * 92, y + 28))
        board.alpha_composite(on_ground(shot, frames_[min(2, n - 1)], hot, k), (x_map, y + 24))
        y += row_h
    board.convert('RGB').save(out)


def build_gif(rows, out):
    cols = 7
    cell = 150
    n_rows = (len(rows) + cols - 1) // cols
    imgs = []
    for f in range(FRAMES):
        im = Image.new('RGB', (cols * cell, n_rows * cell + 10), (10, 17, 32))
        d = ImageDraw.Draw(im)
        for k, (name, _, _, _, _, when, frames_) in enumerate(rows):
            x, y = (k % cols) * cell, (k // cols) * cell + 6
            d.rounded_rectangle((x + 6, y, x + cell - 6, y + cell - 8), radius=8, fill=(22, 34, 60))
            fr = frames_[f % len(frames_)]
            z = fr.resize((96, 96), Image.LANCZOS) if fr.width <= 32 else fr.resize((112, 112), Image.LANCZOS)
            im.paste(z, (x + (cell - z.width) // 2, y + 6 + (112 - z.height) // 2), z)
            text(d, (x + 14, y + cell - 30), name, 13, GOLD if not when.startswith('NEW') else (120, 230, 150),
                 bold=True)
        imgs.append(im)
    imgs[0].save(out, save_all=True, append_images=imgs[1:], duration=FRAME_MS, loop=0)


# the cursors.otml name of each cursor; "window" is the arrow over windows, the same as the default
OTML_NAMES = {'default': ['default', 'window']}


def install(rows):
    lines = ['Cursors']
    for name, old, old_dir, make, hot_spot, _, frames_ in rows:
        image = old or name + 'cursor'
        if make:
            save_apng(frames_, TODAY_MODERN / f'{image}.png')
        for otml_name in OTML_NAMES.get(name, [name]):
            lines += [f'  {otml_name}:', f'    image: {image}', f'    hot-spot: {hot_spot[0]} {hot_spot[1]}']
    (TODAY_MODERN / 'cursors.otml').write_text('\n'.join(lines) + '\n')


def resolve(rows):
    out = []
    for name, old, old_dir, make, hot, when in rows:
        frames_ = make() if make else load_frames(old_dir / f'{old}.png')
        out.append((name, old, old_dir, make, hot, when, frames_))
    return out


def main():
    ap = argparse.ArgumentParser(description=__doc__.split('\n')[0])
    ap.add_argument('--shot', required=True, help='game screenshot for the real-size previews')
    ap.add_argument('--out', default=str(REPO / 'build/pokemon-cursors'))
    ap.add_argument('--install', action='store_true', help='write the cursors into pokeverse-modern/data/cursors')
    args = ap.parse_args()
    out = Path(args.out)
    (out / 'files').mkdir(parents=True, exist_ok=True)
    shot = Image.open(args.shot).convert('RGB')
    map_rows = resolve(MAP_CURSORS)
    use_rows = resolve(USE_CURSORS)
    for name, old, _, make, _, _, frames_ in map_rows + use_rows:
        if make:
            save_apng(frames_, out / 'files' / f'{old or name + "cursor"}.png')
    build_board(shot, map_rows, 'Pokemon mouse cursors: map and windows',
                'The arrow is a Poke Ball (red top, white bottom, the band and button). The click is still '
                'the arrow tip.', out / 'board-map.png')
    build_board(shot, use_rows, 'Use with... cursors',
                'Poke Ball, Pokedex and Order stay as they are. Each potion gets its own ring; the click is '
                'in the middle.', out / 'board-use-with.png')
    build_gif(map_rows + use_rows, out / 'cursors.gif')
    if args.install:
        install(map_rows + use_rows)
    print(f'wrote {out}')


if __name__ == '__main__':
    main()
