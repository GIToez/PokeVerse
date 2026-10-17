#!/usr/bin/env python3
"""Draws the type matchup badges of the moves bar (game_pokemoves): a green up arrow (super
effective, 2x), two green arrows (a double weakness, the 2.5x cap), a red down arrow (not very
effective, 0.5x), two red arrows (0.25x) and a grey crossed circle (no effect).

    scripts/art/move_matchup.py <out dir>

The output goes to core/client-redemption/pokeverse-modern/modules/game_pokemoves/images.
"""
import sys
from pathlib import Path

from PIL import Image, ImageDraw

K = 16  # drawn at K times on a 14-unit grid, then shrunk
SIZE = 14

GREEN = (88, 214, 92, 255)
GREEN_DARK = (18, 82, 26, 255)
RED = (240, 76, 76, 255)
RED_DARK = (100, 16, 18, 255)
GREY = (190, 196, 206, 255)
GREY_DARK = (58, 62, 72, 255)


def canvas():
    return Image.new('RGBA', (SIZE * K, SIZE * K), (0, 0, 0, 0))


def arrow(draw, top, height, up, fill, edge):
    """One chevron arrow, `height` units tall from `top`."""
    w = SIZE * K
    cx = w / 2
    t, b = top * K, (top + height) * K
    if up:
        tip, base = t, b
    else:
        tip, base = b, t
    shaft = 2.2 * K
    neck = tip + (base - tip) * 0.5
    points = [
        (cx, tip),
        (cx + 5.6 * K, neck),
        (cx + shaft, neck),
        (cx + shaft, base),
        (cx - shaft, base),
        (cx - shaft, neck),
        (cx - 5.6 * K, neck),
    ]
    draw.polygon(points, fill=fill, outline=edge, width=int(1.1 * K))


def single(up, fill, edge):
    img = canvas()
    arrow(ImageDraw.Draw(img), 1.0, 12.0, up, fill, edge)
    return img


def double(up, fill, edge):
    img = canvas()
    draw = ImageDraw.Draw(img)
    w = SIZE * K
    for top in (0.6, 6.4):
        layer = canvas()
        ld = ImageDraw.Draw(layer)
        t, b = top * K, (top + 7.0) * K
        tip, base = (t, b) if up else (b, t)
        cx = w / 2
        ld.polygon([(cx, tip), (cx + 6.0 * K, base), (cx + 2.6 * K, base), (cx, tip + (base - tip) * 0.45),
                    (cx - 2.6 * K, base), (cx - 6.0 * K, base)], fill=fill, outline=edge, width=int(1.0 * K))
        img = Image.alpha_composite(img, layer)
    return img


def immune():
    img = canvas()
    draw = ImageDraw.Draw(img)
    m = 1.2 * K
    w = SIZE * K
    draw.ellipse((m, m, w - m, w - m), fill=GREY, outline=GREY_DARK, width=int(1.2 * K))
    draw.line((3.6 * K, 3.6 * K, w - 3.6 * K, w - 3.6 * K), fill=GREY_DARK, width=int(2.0 * K))
    return img


def save(img, path):
    img.resize((SIZE, SIZE), Image.LANCZOS).save(path)


def main():
    out = Path(sys.argv[1]) if len(sys.argv) > 1 else Path(
        __file__).resolve().parents[2] / 'core/client-redemption/pokeverse-modern/modules/game_pokemoves/images'
    out.mkdir(parents=True, exist_ok=True)
    save(single(True, GREEN, GREEN_DARK), out / 'matchup_strong.png')
    save(double(True, GREEN, GREEN_DARK), out / 'matchup_double_strong.png')
    save(single(False, RED, RED_DARK), out / 'matchup_weak.png')
    save(double(False, RED, RED_DARK), out / 'matchup_double_weak.png')
    save(immune(), out / 'matchup_immune.png')


if __name__ == '__main__':
    main()
