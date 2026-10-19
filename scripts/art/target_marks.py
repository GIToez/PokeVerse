#!/usr/bin/env python3
"""Draws the marks under creatures and under the mouse on the game map.

    scripts/art/target_marks.py [<data dir>]

Writes into core/client-redemption/pokeverse-modern/data (or <data dir>):

images/game/target/pokeball-{target,follow,idle}.png
    The Poke Ball ring under the attacked, followed or hovered creature (Options > Interface >
    Target marker). It's a 32x32 tile, drawn under the creature (Creature::setCrosshairTexture).
    The target and follow rings pulse: animated PNGs, which the client plays (apngloader).
images/game/crosshair/{pokeball,ring,pokedex}.png
    The mouse-over tile marks (Options > Interface > Crosshair), drawn on top of the tile under
    the mouse (MapView::setCrosshairTexture). They're drawn over everything on the tile, so they
    keep the middle clear.

The classic rings are the legacy client's (client-legacy/data/images/ui/crosshair-*.png) and
aren't drawn here.
"""
import sys
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter

SCALE = 8
TILE = 32

RED = (232, 48, 40)
GREEN = (64, 200, 96)
GREY = (200, 208, 220)
WHITE = (246, 246, 246)
DARK = (28, 28, 40)


def s(v):
    return int(round(v * SCALE))


def canvas():
    return Image.new('RGBA', (TILE * SCALE, TILE * SCALE), (0, 0, 0, 0))


def shrink(im):
    return im.resize((TILE, TILE), Image.LANCZOS)


def circle(draw, cx, cy, r, **kw):
    draw.ellipse((s(cx - r), s(cy - r), s(cx + r), s(cy + r)), **kw)


def pokeball_ring(top, glow):
    """A Poke Ball's outline as a ring: top half colour, bottom half white, the black band and the
    two buttons across the middle, a faint fill and a glow of the top colour."""
    cx = cy = TILE / 2
    outer, inner = 14.6, 9.8
    im = canvas()

    halo = canvas()
    hd = ImageDraw.Draw(halo)
    circle(hd, cx, cy, outer + 0.6, outline=top + (int(255 * glow),), width=s(2.4))
    im.alpha_composite(halo.filter(ImageFilter.GaussianBlur(s(1.4))))

    fill = canvas()
    circle(ImageDraw.Draw(fill), cx, cy, inner, fill=top + (int(40 + 40 * glow),))
    im.alpha_composite(fill)

    ring = canvas()
    rd = ImageDraw.Draw(ring)
    circle(rd, cx, cy, outer, fill=DARK + (255,))
    box = (s(cx - outer + 1), s(cy - outer + 1), s(cx + outer - 1), s(cy + outer - 1))
    rd.pieslice(box, 180, 360, fill=top + (255,))
    rd.pieslice(box, 0, 180, fill=WHITE + (255,))
    circle(rd, cx, cy, inner + 1, fill=DARK + (255,))
    circle(rd, cx, cy, inner, fill=(0, 0, 0, 0))
    rd.rectangle((0, s(cy - 0.8), s(TILE), s(cy + 0.8)), fill=DARK + (255,))
    mask = canvas()
    md = ImageDraw.Draw(mask)
    circle(md, cx, cy, outer, fill=(255, 255, 255, 255))
    circle(md, cx, cy, inner, fill=(0, 0, 0, 0))
    ring.putalpha(Image.composite(ring.getchannel('A'), Image.new('L', ring.size, 0), mask.getchannel('A')))
    rd = ImageDraw.Draw(ring)
    for bx in (cx - (outer + inner) / 2, cx + (outer + inner) / 2):
        circle(rd, bx, cy, 2.6, fill=DARK + (255,))
        circle(rd, bx, cy, 1.6, fill=WHITE + (255,))
    im.alpha_composite(ring)
    return shrink(im)


def save_pulse(frames, path, durations):
    frames[0].save(path, save_all=True, append_images=frames[1:], duration=durations, loop=0,
                   disposal=1, blend=0)


def corners():
    """Four Poke Ball corner brackets: red on top, white below, outlined so they read on snow."""
    im = canvas()
    d = ImageDraw.Draw(im)
    arm, inset, width = 8.5, 1.5, 2.4

    def bracket(x, y, dx, dy, color, pad):
        x0, y0 = x, y
        x1, y1 = x + dx * arm, y + dy * arm
        w = width + pad * 2
        d.line((s(x0), s(y0), s(x1), s(y0)), fill=color, width=s(w))
        d.line((s(x0), s(y0), s(x0), s(y1)), fill=color, width=s(w))
        for px, py in ((x0, y0), (x1, y0), (x0, y1)):
            circle(d, px, py, w / 2, fill=color)

    spots = [(inset + width / 2, inset + width / 2, 1, 1, RED),
             (TILE - inset - width / 2, inset + width / 2, -1, 1, RED),
             (inset + width / 2, TILE - inset - width / 2, 1, -1, WHITE),
             (TILE - inset - width / 2, TILE - inset - width / 2, -1, -1, WHITE)]
    for x, y, dx, dy, _ in spots:
        bracket(x, y, dx, dy, DARK + (230,), 0.8)
    for x, y, dx, dy, color in spots:
        bracket(x, y, dx, dy, color + (255,), 0)
    return shrink(im)


def thin_ring():
    im = canvas()
    d = ImageDraw.Draw(im)
    circle(d, 16, 16, 13.6, outline=DARK + (170,), width=s(2.8))
    circle(d, 16, 16, 13.2, outline=WHITE + (235,), width=s(1.6))
    for angle in range(4):
        x, y = [(16, 2.4), (29.6, 16), (16, 29.6), (2.4, 16)][angle]
        circle(d, x, y, 1.5, fill=DARK + (200,))
        circle(d, x, y, 0.9, fill=WHITE + (255,))
    return shrink(im)


def pokedex():
    """A Pokedex scanner: a rounded red frame, white ticks at the edges and a lens in a corner."""
    im = canvas()
    d = ImageDraw.Draw(im)
    box = (s(1.6), s(1.6), s(TILE - 1.6), s(TILE - 1.6))
    d.rounded_rectangle(box, radius=s(6), outline=DARK + (200,), width=s(3.0))
    d.rounded_rectangle((s(2.2), s(2.2), s(TILE - 2.2), s(TILE - 2.2)), radius=s(5.4),
                        outline=RED + (255,), width=s(1.8))
    for x0, y0, x1, y1 in ((16, 2, 16, 6.5), (16, 25.5, 16, 30), (2, 16, 6.5, 16), (25.5, 16, 30, 16)):
        d.line((s(x0), s(y0), s(x1), s(y1)), fill=DARK + (220,), width=s(2.6))
        d.line((s(x0), s(y0), s(x1), s(y1)), fill=WHITE + (255,), width=s(1.4))
    circle(d, 6.2, 6.2, 2.4, fill=DARK + (230,))
    circle(d, 6.2, 6.2, 1.6, fill=(90, 200, 255, 255))
    circle(d, 5.7, 5.7, 0.6, fill=WHITE + (255,))
    return shrink(im)


def main():
    out = Path(sys.argv[1]) if len(sys.argv) > 1 else (
        Path(__file__).resolve().parents[2] / 'core/client-redemption/pokeverse-modern/data')
    target = out / 'images/game/target'
    crosshair = out / 'images/game/crosshair'
    target.mkdir(parents=True, exist_ok=True)
    crosshair.mkdir(parents=True, exist_ok=True)

    pulse = (0.25, 0.5, 0.8, 0.5)
    for name, color in (('target', RED), ('follow', GREEN)):
        save_pulse([pokeball_ring(color, glow) for glow in pulse], target / f'pokeball-{name}.png',
                   [160, 160, 220, 160])
    pokeball_ring(GREY, 0.2).save(target / 'pokeball-idle.png')

    corners().save(crosshair / 'pokeball.png')
    thin_ring().save(crosshair / 'ring.png')
    pokedex().save(crosshair / 'pokedex.png')


if __name__ == '__main__':
    main()
