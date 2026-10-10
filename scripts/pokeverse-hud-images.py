#!/usr/bin/env python3
"""Draws the PokeVerse HUD artwork (pills, bars, portrait ring, party balls).

usage: pokeverse-hud-images.py <out dir>
"""
import sys
from pathlib import Path

from PIL import Image, ImageDraw

SCALE = 4  # drawn large, then scaled down for smooth edges

PANEL = (20, 28, 29, 225)
PANEL_EDGE = (78, 104, 104, 200)
TRACK = (6, 10, 10, 235)
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


def bar_fill(out, name, top, bottom):
    w, h = 12, 8
    im = canvas(w, h)
    grad = Image.new('RGBA', im.size)
    for y in range(im.height):
        t = y / (im.height - 1)
        grad.paste(tuple(round(a + (b - a) * t) for a, b in zip(top, bottom)) + (255,), (0, y, im.width, y + 1))
    mask = Image.new('L', im.size, 0)
    ImageDraw.Draw(mask).rounded_rectangle((0, 0, im.width - 1, im.height - 1), 4 * SCALE, fill=255)
    im.paste(grad, (0, 0), mask)
    save(im, out, name)


def portrait(out, size=66):
    im = canvas(size, size)
    d = ImageDraw.Draw(im)
    s = im.width
    for r in range(s // 2, 0, -1):
        t = r / (s / 2)
        c = tuple(round(a + (b - a) * t) for a, b in zip((52, 98, 170), (24, 52, 104)))
        d.ellipse((s / 2 - r, s / 2 - r, s / 2 + r, s / 2 + r), fill=c + (255,))
    save(im, out, 'portrait-disc')

    im = canvas(size, size)
    d = ImageDraw.Draw(im)
    d.ellipse((0, 0, s - 1, s - 1), outline=GOLD_DARK, width=5 * SCALE)
    d.ellipse((SCALE, SCALE, s - 1 - SCALE, s - 1 - SCALE), outline=GOLD, width=3 * SCALE)
    save(im, out, 'portrait-ring')


def ball(out, name, top, bottom, band=(16, 16, 16), button=(240, 240, 240)):
    n = 14
    im = canvas(n, n)
    d = ImageDraw.Draw(im)
    s = im.width - 1
    d.ellipse((0, 0, s, s), fill=band + (255,))
    inset = SCALE
    d.pieslice((inset, inset, s - inset, s - inset), 180, 360, fill=top + (255,))
    d.pieslice((inset, inset, s - inset, s - inset), 0, 180, fill=bottom + (255,))
    d.rectangle((0, s / 2 - SCALE * 0.8, s, s / 2 + SCALE * 0.8), fill=band + (255,))
    c, r = s / 2, 2.6 * SCALE
    d.ellipse((c - r, c - r, c + r, c + r), fill=band + (255,))
    r = 1.6 * SCALE
    d.ellipse((c - r, c - r, c + r, c + r), fill=button + (255,))
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


def main():
    out = Path(sys.argv[1])
    out.mkdir(parents=True, exist_ok=True)
    rounded(out, 'panel', 24, 24, 9, PANEL, PANEL_EDGE)
    rounded(out, 'track', 12, 8, 4, TRACK)
    bar_fill(out, 'fill-health', (96, 226, 140), (44, 170, 92))
    bar_fill(out, 'fill-pokemon', (110, 180, 245), (52, 116, 200))
    bar_fill(out, 'fill-experience', (250, 204, 82), (214, 150, 30))
    portrait(out)
    ball(out, 'ball', (222, 44, 52), (240, 240, 240))
    ball(out, 'ball-fainted', (96, 70, 72), (130, 130, 130), button=(150, 150, 150))
    ball(out, 'ball-empty', (74, 90, 94), (54, 66, 70), band=(14, 20, 22), button=(104, 120, 124))
    heart(out)
    rounded(out, 'slot', 16, 16, 6, (12, 18, 19, 210), (70, 92, 92, 220))
    rounded(out, 'slot-hover', 16, 16, 6, (30, 42, 43, 220), (150, 176, 176, 240))
    rounded(out, 'slot-active', 16, 16, 6, (40, 36, 18, 220), GOLD)


if __name__ == '__main__':
    main()
