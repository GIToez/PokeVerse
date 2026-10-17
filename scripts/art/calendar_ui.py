#!/usr/bin/env python3
"""Draws the event calendar artwork (game_calendar): the calendar page of the window and the banner,
and the moon of each day.

    scripts/art/calendar_ui.py <out dir>

The output goes to core/client-redemption/pokeverse-modern/modules/game_calendar/images:
icon_calendar.png (34x34), icon_calendar_small.png (16x16) and moon_0.png .. moon_7.png (14x14:
new moon, waxing crescent, first quarter, waxing gibbous, full moon, waning gibbous, last quarter,
waning crescent).
"""
import math
import sys
from pathlib import Path

from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[2]
K = 16  # drawn at K times, then shrunk

PAGE = (246, 240, 228, 255)
PAGE_EDGE = (150, 140, 128, 255)
RED = (214, 64, 64, 255)
RED_DARK = (120, 26, 30, 255)
RING = (90, 96, 108, 255)
INK = (60, 64, 76, 255)
MOON_LIT = (250, 238, 196, 255)
MOON_DARK = (58, 66, 92, 255)
MOON_EDGE = (150, 158, 186, 255)


def calendar(size):
    """A desk calendar page with a red header, two rings and a dotted grid, on a 34-unit grid"""
    im = Image.new('RGBA', (34 * K, 34 * K), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)

    def q(points):
        return [(x * K, y * K) for x, y in points]
    d.rounded_rectangle(q([(4, 6), (30, 31)]), radius=3 * K, fill=PAGE_EDGE)
    d.rounded_rectangle(q([(5.2, 7.2), (28.8, 29.8)]), radius=2.2 * K, fill=PAGE)
    d.rounded_rectangle(q([(5.2, 7.2), (28.8, 14)]), radius=2.2 * K, fill=RED)
    d.rectangle(q([(5.2, 11), (28.8, 14)]), fill=RED)
    d.line(q([(5.2, 14), (28.8, 14)]), fill=RED_DARK, width=int(0.8 * K))
    for x in (11, 23):
        d.rounded_rectangle(q([(x - 1.4, 3), (x + 1.4, 10)]), radius=1.4 * K, fill=RING)
        d.ellipse(q([(x - 0.7, 3.6), (x + 0.7, 5)]), fill=(170, 176, 188, 255))
    for row in range(3):
        for col in range(4):
            x, y = 9.5 + col * 5, 18 + row * 4
            fill = RED if (row, col) == (1, 2) else INK
            d.rounded_rectangle(q([(x - 1.3, y - 1.1), (x + 1.3, y + 1.1)]), radius=0.5 * K, fill=fill)
    return im.resize((size, size), Image.LANCZOS)


def moon(phase):
    """phase 0..7, 0 = new moon, 4 = full moon; the lit part is on the right while waxing"""
    size = 14
    im = Image.new('RGBA', (size * K, size * K), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    r = 6 * K
    c = 7 * K
    d.ellipse((c - r - K * 0.6, c - r - K * 0.6, c + r + K * 0.6, c + r + K * 0.6), fill=MOON_EDGE)
    d.ellipse((c - r, c - r, c + r, c + r), fill=MOON_DARK)
    angle = phase / 8 * 2 * math.pi
    lit = (1 - math.cos(angle)) / 2  # the lit fraction of the disc
    if lit > 0.01:
        mask = Image.new('L', im.size, 0)
        m = ImageDraw.Draw(mask)
        # the terminator is an ellipse of half-width |cos| * r; the lit side is a half disc plus or minus it
        w = abs(math.cos(angle)) * r
        waxing = phase <= 4
        if waxing:
            m.pieslice((c - r, c - r, c + r, c + r), -90, 90, fill=255)
        else:
            m.pieslice((c - r, c - r, c + r, c + r), 90, 270, fill=255)
        if lit < 0.5:
            m.ellipse((c - w, c - r, c + w, c + r), fill=0)
        else:
            m.ellipse((c - w, c - r, c + w, c + r), fill=255)
        im.paste(Image.new('RGBA', im.size, MOON_LIT), (0, 0), mask)
        circle = Image.new('L', im.size, 0)
        ImageDraw.Draw(circle).ellipse((c - r - K * 0.6, c - r - K * 0.6, c + r + K * 0.6, c + r + K * 0.6), fill=255)
        im.putalpha(circle)
    return im.resize((size, size), Image.LANCZOS)


def main():
    out = Path(sys.argv[1] if len(sys.argv) > 1 else
               ROOT / 'core/client-redemption/pokeverse-modern/modules/game_calendar/images')
    out.mkdir(parents=True, exist_ok=True)
    calendar(34).save(out / 'icon_calendar.png', optimize=True)
    calendar(16).save(out / 'icon_calendar_small.png', optimize=True)
    for phase in range(8):
        moon(phase).save(out / ('moon_%d.png' % phase), optimize=True)


if __name__ == '__main__':
    main()
