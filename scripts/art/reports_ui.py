#!/usr/bin/env python3
"""Draws the Reports window artwork (game_reports): the top bar button, the header icon (a gold flag) and the
small kind icons of the list rows (a bug and a trainer).

    scripts/art/reports_ui.py <out dir>

The output goes to core/client-redemption/pokeverse-modern/modules/game_reports/images. The button keeps the
Trainer Card button's frame (two 20x20 states: normal and the gold-edged pressed one) with the flag on it.
"""
import sys
from pathlib import Path

from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[2]
BUTTON_FRAME = ROOT / 'core/client-redemption/pokeverse-modern/modules/game_trainercard/images/button_trainercard.png'
GOLD = (255, 208, 72, 255)
DARK = (150, 98, 20, 255)
POLE = (220, 230, 255, 255)
POLE_DARK = (120, 138, 175, 255)
RED = (232, 80, 110, 255)
RED_DARK = (150, 40, 64, 255)
BLUE = (110, 160, 240, 255)
BLUE_DARK = (50, 82, 150, 255)
K = 16


def canvas():
    im = Image.new('RGBA', (34 * K, 34 * K), (0, 0, 0, 0))
    return im, ImageDraw.Draw(im)


def p(points):
    return [(x * K, y * K) for x, y in points]


def flag(size):
    """A pennant on a pole filling a size x size square"""
    im, d = canvas()
    d.rounded_rectangle((5 * K, 2 * K, 9 * K, 33 * K), 2 * K, fill=POLE_DARK)
    d.rounded_rectangle((6 * K, 3 * K, 8 * K, 32 * K), K, fill=POLE)
    d.polygon(p([(8, 4), (31, 9), (24, 13.5), (31, 18), (8, 22)]), fill=DARK)
    d.polygon(p([(9.5, 6), (27, 9.6), (21.5, 13.5), (27, 17.4), (9.5, 20)]), fill=GOLD)
    d.ellipse((4 * K, 0.5 * K, 10 * K, 6.5 * K), fill=GOLD)
    return im.resize((size, size), Image.LANCZOS)


def bug(size):
    """A round beetle seen from above"""
    im, d = canvas()
    for side in (-1, 1):
        for y in (13, 19, 25):
            d.line(p([(17 + side * 8, y), (17 + side * 14, y + side * 0 - 3)]), fill=RED_DARK, width=int(2.4 * K))
        d.line(p([(17 + side * 3, 7), (17 + side * 8, 1.5)]), fill=RED_DARK, width=int(2 * K))
    d.ellipse((7 * K, 9 * K, 27 * K, 32 * K), fill=RED_DARK)
    d.ellipse((8.6 * K, 10.6 * K, 25.4 * K, 30.4 * K), fill=RED)
    d.line(p([(17, 11), (17, 30)]), fill=RED_DARK, width=int(1.6 * K))
    d.ellipse((11 * K, 3.5 * K, 23 * K, 13 * K), fill=RED_DARK)
    for x, y in ((12.5, 17), (21.5, 17), (13, 24), (21, 24)):
        d.ellipse(((x - 2) * K, (y - 2) * K, (x + 2) * K, (y + 2) * K), fill=RED_DARK)
    return im.resize((size, size), Image.LANCZOS)


def trainer(size):
    """A head and shoulders"""
    im, d = canvas()
    d.ellipse((10 * K, 2 * K, 24 * K, 16 * K), fill=BLUE_DARK)
    d.ellipse((11.6 * K, 3.6 * K, 22.4 * K, 14.4 * K), fill=BLUE)
    d.rounded_rectangle((4 * K, 18 * K, 30 * K, 40 * K), 11 * K, fill=BLUE_DARK)
    d.rounded_rectangle((5.6 * K, 19.6 * K, 28.4 * K, 40 * K), 10 * K, fill=BLUE)
    return im.crop((0, 0, 34 * K, 34 * K)).resize((size, size), Image.LANCZOS)


def button():
    out = Image.open(BUTTON_FRAME).convert('RGBA')
    px = out.load()
    icon = flag(14)
    for frame in (0, 20):
        # paint over the card icon with the frame's own background, blended across from edge to edge
        for y in range(3, 17):
            a, b = px[frame + 2, y], px[frame + 17, y]
            for x in range(3, 17):
                t = (x - 2) / 15
                px[frame + x, y] = tuple(int(a[i] + (b[i] - a[i]) * t) for i in range(3)) + (255,)
        out.alpha_composite(icon, (frame + 3, 3))
    return out


def main():
    out = Path(sys.argv[1] if len(sys.argv) > 1 else
               ROOT / 'core/client-redemption/pokeverse-modern/modules/game_reports/images')
    out.mkdir(parents=True, exist_ok=True)
    button().save(out / 'button_reports.png', optimize=True)
    flag(34).save(out / 'icon_reports.png', optimize=True)
    bug(22).save(out / 'kind_bug.png', optimize=True)
    trainer(22).save(out / 'kind_player.png', optimize=True)


if __name__ == '__main__':
    main()
