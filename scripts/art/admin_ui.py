#!/usr/bin/env python3
"""Draws the Admin window artwork (game_admin): the top bar button and the window's header icon, a gold crown.

    scripts/art/admin_ui.py <out dir>

The output goes to core/client-redemption/pokeverse-modern/modules/game_admin/images. The button keeps the
Trainer Card button's frame (two 20x20 states: normal and the gold-edged pressed one) with the crown on it.
"""
import sys
from pathlib import Path

from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[2]
BUTTON_FRAME = ROOT / 'core/client-redemption/pokeverse-modern/modules/game_trainercard/images/button_trainercard.png'
GOLD = (255, 208, 72, 255)
DARK = (150, 98, 20, 255)
PEARL = (255, 236, 170, 255)
GEM = (232, 80, 110, 255)


def crown(size, k=16):
    """A crown filling a size x size square, drawn on a 34-unit grid at k times and shrunk"""
    im = Image.new('RGBA', (34 * k, 34 * k), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)

    def p(points):
        return [(x * k, y * k) for x, y in points]
    d.polygon(p([(2, 27), (2, 10), (9.5, 18), (17, 5), (24.5, 18), (32, 10), (32, 27)]), fill=DARK)
    d.polygon(p([(3.8, 25.5), (3.8, 13.8), (9.8, 20.6), (17, 8.8), (24.2, 20.6), (30.2, 13.8), (30.2, 25.5)]), fill=GOLD)
    d.rectangle((2 * k, 27.5 * k, 32 * k, 32 * k), fill=DARK)
    d.rectangle((3.8 * k, 28.8 * k, 30.2 * k, 30.6 * k), fill=GOLD)
    for x, y in ((2, 10), (17, 5), (32, 10)):
        d.ellipse(((x - 2.4) * k, (y - 2.4) * k, (x + 2.4) * k, (y + 2.4) * k), fill=PEARL)
    d.ellipse((14.5 * k, 19 * k, 19.5 * k, 24 * k), fill=GEM)
    return im.resize((size, size), Image.LANCZOS)


def button():
    out = Image.open(BUTTON_FRAME).convert('RGBA')
    px = out.load()
    icon = crown(14)
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
               ROOT / 'core/client-redemption/pokeverse-modern/modules/game_admin/images')
    out.mkdir(parents=True, exist_ok=True)
    button().save(out / 'button_admin.png', optimize=True)
    crown(34).save(out / 'icon_admin.png', optimize=True)


if __name__ == '__main__':
    main()
