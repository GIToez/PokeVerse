#!/usr/bin/env python3
"""Draws the PokeVerse HUD artwork (pills, bars, portrait ring, party balls) and,
when a second directory is given, the level-up / new-move popup artwork.

usage: pokeverse-hud-images.py <out dir> [<popup out dir>]
"""
import math
import sys
from pathlib import Path

from PIL import Image, ImageDraw

SCALE = 4  # drawn large, then scaled down for smooth edges

# the navy of the login screens and window art (scripts/pokeverse-skin.py)
PANEL = (15, 23, 41, 228)
PANEL_EDGE = (58, 86, 140, 210)
TRACK = (5, 9, 19, 235)
GOLD = (226, 178, 62, 255)
GOLD_DARK = (120, 86, 22, 255)


def canvas(w, h):
    return Image.new('RGBA', (w * SCALE, h * SCALE), (0, 0, 0, 0))


def save(im, out, name):
    w, h = im.width // SCALE, im.height // SCALE
    im.resize((w, h), Image.LANCZOS).save(out / f'{name}.png')


def rounded(out, name, w, h, radius, fill, outline=None):
    im = canvas(w, h)
    d = ImageDraw.Draw(im)
    d.rounded_rectangle((0, 0, im.width - 1, im.height - 1), radius * SCALE, fill=fill,
                        outline=outline, width=SCALE if outline else 0)
    save(im, out, name)


def bar_width(h):
    """A pill as tall as its bar: the client tiles bordered images, so each bar height needs its own.
    The caps are the image borders (half the height, pokehud.lua); 2 pixels between them stretch."""
    return 2 * math.ceil(h / 2) + 2


def bar_fill(out, name, top, bottom, h):
    w = bar_width(h)
    im = canvas(w, h)
    grad = Image.new('RGBA', im.size)
    for y in range(im.height):
        t = y / (im.height - 1)
        grad.paste(tuple(round(a + (b - a) * t) for a, b in zip(top, bottom)) + (255,), (0, y, im.width, y + 1))
    mask = Image.new('L', im.size, 0)
    ImageDraw.Draw(mask).rounded_rectangle((0, 0, im.width - 1, im.height - 1), h / 2 * SCALE, fill=255)
    im.paste(grad, (0, 0), mask)
    save(im, out, name)


def portrait(out, size=66, disc='portrait-disc', ring='portrait-ring'):
    im = canvas(size, size)
    d = ImageDraw.Draw(im)
    s = im.width
    for r in range(s // 2, 0, -1):
        t = r / (s / 2)
        c = tuple(round(a + (b - a) * t) for a, b in zip((52, 98, 170), (24, 52, 104)))
        d.ellipse((s / 2 - r, s / 2 - r, s / 2 + r, s / 2 + r), fill=c + (255,))
    save(im, out, disc)

    im = canvas(size, size)
    d = ImageDraw.Draw(im)
    d.ellipse((0, 0, s - 1, s - 1), outline=GOLD_DARK, width=5 * SCALE)
    d.ellipse((SCALE, SCALE, s - 1 - SCALE, s - 1 - SCALE), outline=GOLD, width=3 * SCALE)
    save(im, out, ring)


def ball(out, name, top, bottom, band=(16, 16, 16), button=(240, 240, 240), n=14):
    im = canvas(n, n)
    d = ImageDraw.Draw(im)
    s = im.width - 1
    k = SCALE * n / 14
    d.ellipse((0, 0, s, s), fill=band + (255,))
    inset = max(k, SCALE * 0.75)
    d.pieslice((inset, inset, s - inset, s - inset), 180, 360, fill=top + (255,))
    d.pieslice((inset, inset, s - inset, s - inset), 0, 180, fill=bottom + (255,))
    d.rectangle((0, s / 2 - k * 0.8, s, s / 2 + k * 0.8), fill=band + (255,))
    c, r = s / 2, 2.6 * k
    d.ellipse((c - r, c - r, c + r, c + r), fill=band + (255,))
    r = 1.6 * k
    d.ellipse((c - r, c - r, c + r, c + r), fill=button + (255,))
    save(im, out, name)


def mini_dex(out, name, n=9):
    """The name plate's "registered in your Pokedex" mark: a tiny red Pokedex."""
    im = canvas(n, n)
    d = ImageDraw.Draw(im)
    s = SCALE
    w = im.width - 1
    d.rounded_rectangle((s, 0, w - s, w), 1.5 * s, fill=(16, 16, 16, 255))
    d.rounded_rectangle((2 * s, s, w - 2 * s, w - s), s, fill=(214, 48, 52, 255))
    c, r = w / 2, 1.5 * s
    d.ellipse((c - r, 2 * s, c + r, 2 * s + 2 * r), fill=(120, 205, 255, 255))
    d.rectangle((3 * s, w - 3.2 * s, w - 3 * s, w - 2.2 * s), fill=(40, 22, 22, 255))
    save(im, out, name)


def heart(out):
    im = canvas(12, 11)
    d = ImageDraw.Draw(im)
    s = SCALE
    red = (232, 64, 84, 255)
    d.ellipse((0, 0, 6.5 * s, 6.5 * s), fill=red)
    d.ellipse((5.5 * s, 0, 12 * s - 1, 6.5 * s), fill=red)
    d.polygon(((0.4 * s, 4.2 * s), (11.6 * s, 4.2 * s), (6 * s, 10.8 * s)), fill=red)
    save(im, out, 'heart')


def bolt(out):
    im = canvas(9, 12)
    d = ImageDraw.Draw(im)
    s = SCALE
    d.polygon(((5.6 * s, 0), (0.4 * s, 6.8 * s), (4 * s, 6.8 * s), (2.8 * s, 12 * s - 1),
               (8.6 * s, 4.8 * s), (5 * s, 4.8 * s), (6.8 * s, 0)), fill=(196, 160, 255, 255))
    save(im, out, 'bolt')


def popup_card(out):
    """Level-up card background, drawn as a 9-slice (image-border: 12): panel, edge and a gold top accent."""
    w = h = 32
    im = canvas(w, h)
    d = ImageDraw.Draw(im)
    s = SCALE
    d.rounded_rectangle((0, 0, im.width - 1, im.height - 1), 10 * s, fill=(16, 23, 24, 235),
                        outline=PANEL_EDGE, width=s)
    d.rounded_rectangle((10 * s, 1 * s, im.width - 1 - 10 * s, 3 * s - 1), s, fill=GOLD)
    save(im, out, 'popup-card')


def badge(out, name, top, bottom, symbol, n=20):
    im = canvas(n, n)
    d = ImageDraw.Draw(im)
    s = im.width
    d.ellipse((0, 0, s - 1, s - 1), fill=(10, 14, 15, 255))
    for r in range(s // 2 - 2 * SCALE, 0, -1):
        t = r / (s / 2 - 2 * SCALE)
        c = tuple(round(a + (b - a) * t) for a, b in zip(top, bottom))
        d.ellipse((s / 2 - r, s / 2 - r, s / 2 + r, s / 2 + r), fill=c + (255,))
    white = (255, 255, 255, 255)
    k = SCALE * n / 20
    c = s / 2
    if symbol == 'up':
        d.polygon(((c, c - 6 * k), (c + 5.5 * k, c), (c + 2.2 * k, c), (c + 2.2 * k, c + 6 * k),
                   (c - 2.2 * k, c + 6 * k), (c - 2.2 * k, c), (c - 5.5 * k, c)), fill=white)
    else:
        points = []
        for i in range(10):
            a = -math.pi / 2 + i * math.pi / 5
            r = (6.5 if i % 2 == 0 else 2.8) * k
            points.append((c + r * math.cos(a), c + 0.6 * k + r * math.sin(a)))
        d.polygon(points, fill=white)
    save(im, out, name)


def popups(out):
    out.mkdir(parents=True, exist_ok=True)
    popup_card(out)
    portrait(out, 60, 'popup-disc', 'popup-ring')
    badge(out, 'badge-up', (120, 236, 156), (36, 150, 80), 'up')
    badge(out, 'badge-star', (255, 214, 96), (200, 136, 20), 'star')


def main():
    out = Path(sys.argv[1])
    out.mkdir(parents=True, exist_ok=True)
    if len(sys.argv) > 2:
        popups(Path(sys.argv[2]))
    rounded(out, 'panel', 24, 24, 9, PANEL, PANEL_EDGE)
    # the bar heights in pokehud.otui: experience 6, health 13, energy and the Mega bar 11
    for h in (6, 11, 13):
        rounded(out, 'track-%d' % h, bar_width(h), h, h / 2, TRACK)
    bar_fill(out, 'fill-health', (96, 226, 140), (44, 170, 92), 13)
    bar_fill(out, 'fill-pokemon', (110, 180, 245), (52, 116, 200), 13)
    bar_fill(out, 'fill-experience', (250, 204, 82), (214, 150, 30), 6)
    bar_fill(out, 'fill-energy', (184, 140, 255), (118, 72, 222), 11)
    bar_fill(out, 'fill-energy-low', (255, 132, 146), (200, 52, 74), 11)
    portrait(out)
    ball(out, 'ball', (222, 44, 52), (240, 240, 240))
    ball(out, 'ball-fainted', (96, 70, 72), (130, 130, 130), button=(150, 150, 150))
    ball(out, 'ball-empty', (74, 90, 94), (54, 66, 70), band=(14, 20, 22), button=(104, 120, 124))
    heart(out)
    bolt(out)
    rounded(out, 'slot', 16, 16, 6, (12, 18, 19, 210), (70, 92, 92, 220))
    rounded(out, 'slot-hover', 16, 16, 6, (30, 42, 43, 220), (150, 176, 176, 240))
    rounded(out, 'slot-active', 16, 16, 6, (40, 36, 18, 220), GOLD)
    ball(out, 'plate-caught', (222, 44, 52), (240, 240, 240), n=9)
    mini_dex(out, 'plate-dex')


if __name__ == '__main__':
    main()
