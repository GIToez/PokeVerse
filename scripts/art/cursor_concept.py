#!/usr/bin/env python3
"""Concept for bigger Order and Pokedex mouse cursors (the cursor while picking what to use them on).

    scripts/art/cursor_concept.py --shot <1920x1080 game screenshot>

Writes build/cursor-concept/:

board.png       the three directions: each cursor at 4x, at actual size over the map, and its frames
in-game.png     every direction at actual size over the screenshot, next to today's cursors
<a|b|c>/{order,dex}cursor.png
                the cursors, 48x48 animated PNGs that drop into core/client-redemption/pokeverse-modern/
                data/cursors (with the hot spot from HOT_SPOTS in cursors.otml)

Today's cursors (24x24, scripts/art/target_marks.py) are read from the repository for the comparison.
Windows shows cursors in colour at their own size and plays the frames; X11 turns them into black and
white (X11Window::internalLoadMouseCursor), so the outlines keep them readable there too.
"""
import argparse
import math
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter, ImageFont

REPO = Path(__file__).resolve().parents[2]
CURSORS = REPO / 'core/client-redemption/pokeverse-modern/data/cursors'
SIZE = 48
S = 8
FRAMES = 8
FRAME_MS = 90

DARK = (11, 18, 34)
RED = (226, 52, 52)
RED_DARK = (150, 24, 32)
WHITE = (246, 248, 252)
GOLD = (255, 214, 90)
GOLD_DARK = (190, 132, 30)
CYAN = (84, 214, 255)
BLUE = (60, 150, 255)
SCREEN = (24, 64, 52)

# where the click lands, in cursor pixels
HOT_SPOTS = {'a': (24, 24), 'b': (3, 2), 'c': (24, 24)}
DIRECTIONS = {
    'a': ('A. Classic, bigger',
          "Today's shapes at twice the size, with a dark outline and shadow so they read on snow and "
          "sand. The arrows breathe in and out; the Pokedex frame sweeps a scan line."),
    'b': ('B. Trainer pointer',
          "A normal arrow pointer that carries the tool: a wobbling Poke Ball for orders, a little "
          "Pokedex with a blinking lens and a scanning screen. The click is at the arrow's tip."),
    'c': ('C. Holo reticle',
          "A see-through targeting ring in the glass HUD's gold and blue, with a turning dashed ring "
          "for orders and a rotating scanner arc for the Pokedex. The click is in the middle."),
}


def s(v):
    return int(round(v * S))


def font(size, bold=False):
    name = 'DejaVuSans-Bold.ttf' if bold else 'DejaVuSans.ttf'
    return ImageFont.truetype(f'/usr/share/fonts/truetype/dejavu/{name}', size)


def layer():
    return Image.new('RGBA', (s(SIZE), s(SIZE)), (0, 0, 0, 0))


def finish(im, shadow=True):
    """Supersampled layer to a 48x48 cursor, with a soft drop shadow under it."""
    if shadow:
        alpha = im.getchannel('A').filter(ImageFilter.GaussianBlur(s(1.1)))
        sh = Image.new('RGBA', im.size, (0, 0, 0, 0))
        sh.putalpha(alpha.point(lambda a: int(a * 0.55)))
        base = Image.new('RGBA', im.size, (0, 0, 0, 0))
        base.alpha_composite(sh, (s(1), s(1.5)))
        base.alpha_composite(im)
        im = base
    return im.resize((SIZE, SIZE), Image.LANCZOS)


def circle(d, cx, cy, r, **kw):
    d.ellipse((s(cx - r), s(cy - r), s(cx + r), s(cy + r)), **kw)


def ball(r, angle=0.0, top=RED):
    """A Poke Ball of radius r (cursor pixels), turned by angle degrees, on its own supersampled layer."""
    side = s(2 * r + 4)
    im = Image.new('RGBA', (side, side), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    c = side / 2 / S
    circle(d, c, c, r, fill=DARK)
    inner = r - 1.3
    box = (s(c - inner), s(c - inner), s(c + inner), s(c + inner))
    d.pieslice(box, 180, 360, fill=top)
    d.pieslice(box, 0, 180, fill=WHITE)
    band = max(1.2, r * 0.17)
    d.rectangle((s(c - inner), s(c - band / 2), s(c + inner), s(c + band / 2)), fill=DARK)
    circle(d, c, c, r * 0.38, fill=DARK)
    circle(d, c, c, r * 0.38 - 1.0, fill=WHITE)
    circle(d, c, c, r * 0.14, fill=(200, 206, 218))
    d.ellipse((s(c - inner * 0.62), s(c - inner * 0.78), s(c - inner * 0.18), s(c - inner * 0.42)),
              fill=(255, 255, 255, 120))
    return im.rotate(angle, resample=Image.BICUBIC)


def paste_center(im, part, cx, cy):
    im.alpha_composite(part, (int(s(cx) - part.width / 2), int(s(cy) - part.height / 2)))


def poly(d, points, fill, outline=DARK, width=1.6):
    pts = [(s(x), s(y)) for x, y in points]
    d.polygon(pts, fill=outline)
    d.line(pts + [pts[0]], fill=outline, width=int(s(width) * 2), joint='curve')
    d.polygon(pts, fill=fill)


def stroke(d, points, color, width, outline=DARK, ow=1.4):
    pts = [(s(x), s(y)) for x, y in points]
    d.line(pts, fill=outline, width=int(s(width + 2 * ow)), joint='curve')
    for x, y in (pts[0], pts[-1]):
        r = s(width + 2 * ow) / 2
        d.ellipse((x - r, y - r, x + r, y + r), fill=outline)
    d.line(pts, fill=color, width=int(s(width)), joint='curve')
    for x, y in (pts[0], pts[-1]):
        r = s(width) / 2
        d.ellipse((x - r, y - r, x + r, y + r), fill=color)


def arc(d, cx, cy, r, start, end, color, width, outline=DARK, ow=1.3):
    box = (s(cx - r), s(cy - r), s(cx + r), s(cy + r))
    if outline:
        d.arc(box, start - 2, end + 2, fill=outline, width=int(s(width + 2 * ow)))
    d.arc(box, start, end, fill=color, width=int(s(width)))


def wave(t):
    return 0.5 - 0.5 * math.cos(2 * math.pi * t)


# A. Classic, bigger

def order_a(t):
    im = layer()
    d = ImageDraw.Draw(im)
    gap = 13.0 + 2.6 * wave(t)
    for k in range(4):
        a = math.radians(90 * k)
        ux, uy = math.cos(a), math.sin(a)
        px, py = -uy, ux
        tip = (24 + ux * gap, 24 + uy * gap)
        base = (24 + ux * (gap + 7.5), 24 + uy * (gap + 7.5))
        poly(d, [tip, (base[0] + px * 5.2, base[1] + py * 5.2), (base[0] - px * 5.2, base[1] - py * 5.2)], GOLD)
        mid = (24 + ux * (gap + 5.6), 24 + uy * (gap + 5.6))
        d.line([(s(mid[0] + px * 3.0), s(mid[1] + py * 3.0)), (s(mid[0] - px * 3.0), s(mid[1] - py * 3.0))],
               fill=GOLD_DARK, width=s(1))
    circle(d, 24, 24, 11.6, outline=(255, 255, 255, 110), width=s(1))
    paste_center(im, ball(9.5), 24, 24)
    return finish(im)


def dex_a(t):
    im = layer()
    d = ImageDraw.Draw(im)
    lo, hi, arm = 6.5, 41.5, 10
    for cx, cy, dx, dy in ((lo, lo, 1, 1), (hi, lo, -1, 1), (lo, hi, 1, -1), (hi, hi, -1, -1)):
        stroke(d, [(cx, cy + dy * arm), (cx, cy), (cx + dx * arm, cy)], RED, 3.2)
    y = 12 + 24 * t
    glow = Image.new('RGBA', im.size, (0, 0, 0, 0))
    gd = ImageDraw.Draw(glow)
    gd.rectangle((s(10), s(y - 2.2), s(38), s(y + 2.2)), fill=CYAN + (90,))
    im.alpha_composite(glow.filter(ImageFilter.GaussianBlur(s(1.2))))
    d.line([(s(10), s(y)), (s(38), s(y))], fill=CYAN + (230,), width=s(1.2))
    for a in range(4):
        ux, uy = [(1, 0), (0, 1), (-1, 0), (0, -1)][a]
        stroke(d, [(24 + ux * 4.5, 24 + uy * 4.5), (24 + ux * 8.5, 24 + uy * 8.5)], WHITE, 1.4, ow=1.1)
    circle(d, 24, 24, 2.2, fill=DARK)
    circle(d, 24, 24, 1.2, fill=WHITE)
    lit = 0.55 + 0.45 * wave(t * 2)
    circle(d, 8.5, 8.5, 4.4, fill=DARK)
    circle(d, 8.5, 8.5, 3.3, fill=tuple(int(c * lit + 30 * (1 - lit)) for c in BLUE))
    circle(d, 7.5, 7.4, 1.1, fill=(255, 255, 255, 220))
    return finish(im)


# B. Trainer pointer

POINTER = [(3, 2), (3, 30), (9.6, 24.2), (13.8, 33.4), (18.4, 31.4), (14.4, 22.4), (22.8, 22.4)]


def pointer(d, fill, edge):
    poly(d, POINTER, fill, width=1.5)
    d.line([(s(4.6), s(5.6)), (s(4.6), s(26))], fill=edge, width=s(1))


def order_b(t):
    im = layer()
    d = ImageDraw.Draw(im)
    pointer(d, WHITE, (255, 255, 255))
    swing = 22 * math.sin(2 * math.pi * t)
    hop = 1.4 * abs(math.sin(2 * math.pi * t))
    paste_center(im, ball(9.6, swing), 34.5, 34.5 - hop)
    for k, (x, y) in enumerate(((24.5, 26.5), (22.5, 32.0), (27.0, 21.5))):
        a = (wave(t + k / 3) * 0.8 + 0.2)
        d.line([(s(x), s(y)), (s(x - 3.2), s(y + 1.1))], fill=GOLD + (int(255 * a),), width=s(1.4))
    return finish(im)


def dex_b(t):
    im = layer()
    d = ImageDraw.Draw(im)
    pointer(d, RED, (255, 140, 140))
    x0, y0, x1, y1 = 24, 23, 46, 46
    d.rounded_rectangle((s(x0), s(y0), s(x1), s(y1)), radius=s(4), fill=DARK)
    d.rounded_rectangle((s(x0 + 1.3), s(y0 + 1.3), s(x1 - 1.3), s(y1 - 1.3)), radius=s(3), fill=RED)
    d.line([(s(x0 + 1.3), s(y0 + 8.2)), (s(x1 - 1.3), s(y0 + 8.2))], fill=RED_DARK, width=s(1.2))
    lit = 0.5 + 0.5 * wave(t * 2)
    circle(d, x0 + 5.6, y0 + 4.6, 3.4, fill=WHITE)
    circle(d, x0 + 5.6, y0 + 4.6, 2.5, fill=tuple(int(c * lit + 20 * (1 - lit)) for c in BLUE))
    circle(d, x0 + 4.9, y0 + 3.8, 0.8, fill=(255, 255, 255, 230))
    for k, color in enumerate(((255, 90, 90), (255, 220, 90), (110, 230, 120))):
        circle(d, x0 + 11.5 + k * 3.2, y0 + 3.6, 1.0, fill=color)
    sx0, sy0, sx1, sy1 = x0 + 3.4, y0 + 10.6, x1 - 3.4, y1 - 3.4
    d.rounded_rectangle((s(sx0), s(sy0), s(sx1), s(sy1)), radius=s(1.5), fill=DARK)
    d.rounded_rectangle((s(sx0 + 0.9), s(sy0 + 0.9), s(sx1 - 0.9), s(sy1 - 0.9)), radius=s(1), fill=SCREEN)
    y = sy0 + 1.6 + (sy1 - sy0 - 3.2) * t
    d.line([(s(sx0 + 1.2), s(y)), (s(sx1 - 1.2), s(y))], fill=(140, 255, 200), width=s(0.9))
    cx, cy = (sx0 + sx1) / 2, (sy0 + sy1) / 2
    circle(d, cx, cy, 2.6, outline=(140, 255, 200, 160), width=s(0.6))
    return finish(im)


# C. Holo reticle

def glow_ring(im, cx, cy, r, color, width, blur):
    g = Image.new('RGBA', im.size, (0, 0, 0, 0))
    gd = ImageDraw.Draw(g)
    circle(gd, cx, cy, r, outline=color + (110,), width=s(width))
    im.alpha_composite(g.filter(ImageFilter.GaussianBlur(s(blur))))


def order_c(t):
    im = layer()
    glow_ring(im, 24, 24, 18, GOLD, 4, 1.6)
    d = ImageDraw.Draw(im)
    turn = 45 * t
    for k in range(8):
        a = turn + 45 * k
        arc(d, 24, 24, 18.5, a + 6, a + 33, GOLD, 2.4)
    for k in range(4):
        a = math.radians(90 * k + 45)
        ux, uy = math.cos(a), math.sin(a)
        stroke(d, [(24 + ux * 11.5, 24 + uy * 11.5), (24 + ux * 14.5, 24 + uy * 14.5)], WHITE, 1.5, ow=1.1)
    paste_center(im, ball(6.8, 0), 24, 24)
    return finish(im)


def dex_c(t):
    im = layer()
    glow_ring(im, 24, 24, 17, CYAN, 3, 1.4)
    d = ImageDraw.Draw(im)
    arc(d, 24, 24, 17, 0, 360, CYAN + (170,), 1.2, ow=1.0)
    a = 360 * t
    arc(d, 24, 24, 17, a, a + 95, CYAN, 3.0)
    for ux, uy in ((1, 0), (0, 1), (-1, 0), (0, -1)):
        stroke(d, [(24 + ux * 19.5, 24 + uy * 19.5), (24 + ux * 23.0, 24 + uy * 23.0)], WHITE, 1.5, ow=1.1)
    r = 6.5 + 0.8 * wave(t * 2)
    for dx, dy in ((1, 1), (-1, 1), (1, -1), (-1, -1)):
        stroke(d, [(24 + dx * r, 24 + dy * (r - 3)), (24 + dx * r, 24 + dy * r), (24 + dx * (r - 3), 24 + dy * r)],
               CYAN, 1.3, ow=1.0)
    circle(d, 24, 24, 2.0, fill=DARK)
    circle(d, 24, 24, 1.1, fill=WHITE)
    return finish(im)


DRAW = {'a': (order_a, dex_a), 'b': (order_b, dex_b), 'c': (order_c, dex_c)}


def frames(fn):
    return [fn(i / FRAMES) for i in range(FRAMES)]


def save_apng(frames_, path):
    frames_[0].save(path, save_all=True, append_images=frames_[1:], duration=FRAME_MS, loop=0, disposal=1, blend=0)


def text(d, xy, s_, size, color=(232, 238, 250), bold=False, width=None):
    f = font(size, bold)
    if not width:
        d.text(xy, s_, font=f, fill=color)
        return xy[1] + size + 4
    x, y = xy
    line = ''
    for word in s_.split():
        trial = (line + ' ' + word).strip()
        if d.textlength(trial, font=f) > width and line:
            d.text((x, y), line, font=f, fill=color)
            y += size + 5
            line = word
        else:
            line = trial
    if line:
        d.text((x, y), line, font=f, fill=color)
        y += size + 5
    return y


def zoom(cur, factor):
    return cur.resize((cur.width * factor, cur.height * factor), Image.NEAREST)


def on_map(shot, box, cur, at):
    """A crop of the screenshot with the cursor drawn at its actual size, hot spot at `at`."""
    crop = shot.crop(box).convert('RGBA')
    crop.alpha_composite(cur, at)
    return crop


def card(board, xy, size, fill=(20, 32, 58), edge=(55, 82, 132)):
    d = ImageDraw.Draw(board)
    x, y = xy
    d.rounded_rectangle((x, y, x + size[0], y + size[1]), radius=10, fill=fill, outline=edge, width=1)


def old_cursors():
    return {n: Image.open(CURSORS / f'{n}cursor.png').convert('RGBA') for n in ('order', 'dex')}


def build_board(shot, made, out):
    W, H = 1920, 1250
    board = Image.new('RGBA', (W, H), (10, 17, 32, 255))
    d = ImageDraw.Draw(board)
    text(d, (48, 34), 'Order and Pokedex cursors', 34, bold=True)
    text(d, (48, 82), '48 x 48 instead of 24 x 24, animated. Each cursor at 4x, at its real size on the map, '
         'and its frames.', 17, (170, 186, 214))
    old = old_cursors()
    card(board, (1440, 26), (440, 96))
    text(d, (1460, 38), 'Today (24 x 24)', 15, (170, 186, 214), bold=True)
    tile = shot.crop((1010, 600, 1066, 656)).convert('RGBA')
    for k, n in enumerate(('order', 'dex')):
        x = 1460 + k * 210
        t = tile.copy()
        t.alpha_composite(old[n], (16, 16))
        board.alpha_composite(t, (x, 60))
        board.alpha_composite(zoom(old[n], 2), (x + 66, 60 - 0))
        text(d, (x + 122, 76), n.capitalize(), 14)

    ground = (1010, 600, 1210, 800)
    y = 150
    for key, (name, desc) in DIRECTIONS.items():
        card(board, (36, y), (1848, 352))
        text(d, (60, y + 22), name, 22, GOLD, bold=True)
        yy = text(d, (60, y + 60), desc, 15, (200, 212, 232), width=300)
        hx, hy = HOT_SPOTS[key]
        text(d, (60, yy + 10), f'Click point: {hx}, {hy}', 14, (150, 168, 200))
        text(d, (60, yy + 32), f'{FRAMES} frames, {FRAME_MS} ms each', 14, (150, 168, 200))
        for k, tool in enumerate(('order', 'dex')):
            fr = made[key][tool]
            x = 400 + k * 740
            label = 'Order' if tool == 'order' else 'Pokedex'
            text(d, (x, y + 18), label, 17, bold=True)
            bg = shot.crop((ground[0], ground[1], ground[0] + 192, ground[1] + 192)).convert('RGBA')
            bg = Image.blend(bg, Image.new('RGBA', bg.size, (10, 17, 32, 255)), 0.35)
            bg.alpha_composite(zoom(fr[0], 4))
            board.alpha_composite(bg, (x, y + 46))
            d.rectangle((x, y + 46, x + 191, y + 237), outline=(55, 82, 132))
            spots = [(1060, 500), (370, 640)] if tool == 'dex' else [(1150, 470), (560, 330)]
            for j, (cx, cy) in enumerate(spots):
                box = (cx - 60, cy - 60, cx + 60, cy + 60)
                crop = on_map(shot, box, fr[2], (60 - hx, 60 - hy))
                board.alpha_composite(crop, (x + 210 + j * 132, y + 46))
                d.rectangle((x + 210 + j * 132, y + 46, x + 329 + j * 132, y + 165), outline=(55, 82, 132))
            text(d, (x + 210, y + 172), 'actual size', 13, (150, 168, 200))
            strip_y = y + 252
            for j, f in enumerate(fr):
                cell = Image.new('RGBA', (82, 82), (30, 46, 80, 255))
                cell.alpha_composite(f.resize((72, 72), Image.LANCZOS), (5, 5))
                board.alpha_composite(cell, (x + j * 86, strip_y))
        y += 370
    board.convert('RGB').save(out / 'board.png')


def build_in_game(shot, made, out):
    """Every direction at its real size where it would be used: the order on the ground by Charizard and
    the Pokedex on Charizard, next to today's cursors."""
    W, H = 1920, 760
    img = Image.new('RGBA', (W, H), (10, 17, 32, 255))
    d = ImageDraw.Draw(img)
    text(d, (40, 26), 'At their real size in the game', 28, bold=True)
    text(d, (40, 66), 'Left: today. Order on the ground beside Charizard, Pokedex on Charizard.', 16, (170, 186, 214))
    old = old_cursors()
    cols = [('Today', {'order': [old['order']], 'dex': [old['dex']]}, (12, 12))] + \
           [(DIRECTIONS[k][0], made[k], HOT_SPOTS[k]) for k in DIRECTIONS]
    box_w, box_h = 452, 300
    for c, (name, fr, hot) in enumerate(cols):
        x = 40 + c * (box_w + 12)
        text(d, (x, 104), name, 17, GOLD, bold=True)
        for r, (tool, (px, py)) in enumerate((('order', (1240, 600)), ('dex', (1092, 545)))):
            y = 136 + r * (box_h + 12)
            box = (px - box_w // 2, py - box_h // 2, px + box_w // 2, py + box_h // 2)
            f = fr[tool][min(2, len(fr[tool]) - 1)]
            spot = (box_w // 2 - hot[0], box_h // 2 - hot[1])
            img.alpha_composite(on_map(shot, box, f, spot), (x, y))
            d.rectangle((x, y, x + box_w - 1, y + box_h - 1), outline=(55, 82, 132))
    img.convert('RGB').save(out / 'in-game.png')


def main():
    ap = argparse.ArgumentParser(description=__doc__.split('\n')[0])
    ap.add_argument('--shot', required=True, help='1920x1080 game screenshot')
    ap.add_argument('--out', default=str(REPO / 'build/cursor-concept'))
    args = ap.parse_args()
    out = Path(args.out)
    out.mkdir(parents=True, exist_ok=True)
    shot = Image.open(args.shot).convert('RGB')
    made = {}
    for key, (order_fn, dex_fn) in DRAW.items():
        made[key] = {'order': frames(order_fn), 'dex': frames(dex_fn)}
        (out / key).mkdir(exist_ok=True)
        save_apng(made[key]['order'], out / key / 'ordercursor.png')
        save_apng(made[key]['dex'], out / key / 'dexcursor.png')
    build_board(shot, made, out)
    build_in_game(shot, made, out)
    print(f'wrote {out}')


if __name__ == '__main__':
    main()
