#!/usr/bin/env python3
"""Draws the Angler's Fishing Guide artwork (game_fishing): the header rod, the region tabs and the
"you are here" pin, the tier rows, the portrait frames, the skill bar and the panels.

    scripts/art/fishing_ui.py <out dir>

The output goes to core/client-redemption/pokeverse-modern/modules/game_fishing/images. The window
frame is the Tasks window's (game_dailytasks/images/window). Frames are 9-slice images: the otui
sets image-border to the border noted next to each one. The Pokemon themselves are the Pokedex
portraits in data/images/staticPortraits.
"""
import sys
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter

sys.path.insert(0, str(Path(__file__).parent))
from login_ui import canvas, save, s, glow_frame, icon, draw_lock, draw_pin  # noqa: E402

EDGE = (46, 74, 118, 255)
WATER = (79, 179, 255)
GOLD = (255, 214, 90)
GREEN = (126, 224, 143)


def blur(im, radius):
    return im.filter(ImageFilter.GaussianBlur(radius))


def box(w, h, r, fill, edge, width=1.2):
    im = canvas(w, h)
    ImageDraw.Draw(im).rounded_rectangle((s(0.5), s(0.5), im.width - s(1), im.height - s(1)), s(r),
                                         fill=fill, outline=edge, width=s(width))
    return im


def tab(on):
    im = canvas(60, 28)
    d = ImageDraw.Draw(im)
    if on:
        d.rounded_rectangle((s(0.5), s(0.5), im.width - s(1), im.height - s(1)), s(6),
                            fill=(28, 70, 124, 245), outline=WATER + (255,), width=s(1.4))
        d.line((s(8), im.height - s(2.5), im.width - s(8), im.height - s(2.5)), fill=WATER + (255,), width=s(2))
    else:
        d.rounded_rectangle((s(0.5), s(0.5), im.width - s(1), im.height - s(1)), s(6),
                            fill=(20, 32, 56, 230), outline=(52, 78, 120, 255), width=s(1.2))
    return im


def portrait(edge, glow=None):
    im = canvas(44, 44)
    W = im.width
    if glow:
        g = Image.new('RGBA', im.size, glow + (0,))
        m = Image.new('L', im.size, 0)
        ImageDraw.Draw(m).rounded_rectangle((s(2), s(2), W - s(2), W - s(2)), s(7), outline=200, width=s(2.5))
        g.putalpha(blur(m, s(1.5)))
        im.alpha_composite(g)
    ImageDraw.Draw(im).rounded_rectangle((s(2), s(2), W - s(2), W - s(2)), s(7), fill=(12, 22, 42, 240),
                                         outline=edge, width=s(1.5))
    return im


def check(size=16):
    im = icon(size)
    W = im.width
    d = ImageDraw.Draw(im)
    d.ellipse((s(1), s(1), W - s(1), W - s(1)), fill=GREEN + (255,))
    d.line((s(4.3), s(8.4), s(7), s(11), s(11.8), s(5.4)), fill=(16, 52, 30, 255), width=s(2), joint='curve')
    return im


def track():
    im = canvas(40, 10)
    ImageDraw.Draw(im).rounded_rectangle((0, 0, im.width - 1, im.height - 1), s(5), fill=(8, 14, 28, 255),
                                         outline=(52, 78, 120, 255), width=s(1))
    return im


def fill():
    im = canvas(40, 10)
    W, H = im.size
    grad = Image.new('RGBA', im.size)
    gd = ImageDraw.Draw(grad)
    for y in range(H):
        t = y / (H - 1)
        gd.line((0, y, W, y), fill=(int(110 - 50 * t), int(205 - 60 * t), 255, 255))
    m = Image.new('L', im.size, 0)
    ImageDraw.Draw(m).rounded_rectangle((s(1), s(1), W - s(1), H - s(1)), s(4), fill=255)
    im.paste(grad, (0, 0), m)
    return im


def pill(color):
    im = canvas(24, 16)
    ImageDraw.Draw(im).rounded_rectangle((0, 0, im.width - 1, im.height - 1), s(4), fill=color)
    return im


def header_icon(size=30):
    im = icon(size)
    W = im.width
    d = ImageDraw.Draw(im)
    d.ellipse((s(2), s(2), W - s(2), W - s(2)), fill=(16, 34, 62, 255), outline=WATER + (255,), width=s(2))
    # water at the bottom
    d.chord((s(4), s(4), W - s(4), W - s(4)), 20, 160, fill=(40, 110, 190, 255))
    # the rod, the line and the hook
    d.line((s(8), s(22), s(21), s(7)), fill=(236, 242, 255, 255), width=s(2))
    d.line((s(21), s(7), s(21), s(17)), fill=(170, 200, 240, 255), width=s(1))
    d.arc((s(18), s(15), s(22), s(20)), 0, 180, fill=GOLD + (255,), width=s(1.6))
    d.ellipse((s(19.8), s(13.5), s(22.2), s(15.9)), fill=(255, 92, 92, 255))
    return im


def main():
    out = Path(sys.argv[1]) if len(sys.argv) > 1 else (
        Path(__file__).resolve().parents[2] / 'core/client-redemption/pokeverse-modern/modules/game_fishing/images')
    out.mkdir(parents=True, exist_ok=True)
    save(glow_frame(40, 40, 8, (14, 24, 44, 235), EDGE, None, 0), out, 'panel')  # border 10
    save(box(40, 40, 6, (22, 34, 60, 230), (52, 78, 120, 255)), out, 'row')  # border 8
    save(box(40, 40, 6, (30, 46, 80, 240), (86, 124, 186, 255)), out, 'row_hover')  # border 8
    save(box(40, 40, 6, (26, 52, 96, 245), WATER + (255,), 1.6), out, 'row_on')  # border 8
    save(box(40, 40, 6, (16, 22, 36, 220), (40, 52, 76, 255)), out, 'row_locked')  # border 8
    save(tab(False), out, 'tab')  # border 8
    save(tab(True), out, 'tab_on')  # border 8
    save(portrait((60, 96, 150, 255)), out, 'portrait')
    save(portrait((100, 150, 220, 255)), out, 'portrait_hover')
    save(portrait(GOLD + (255,), GOLD), out, 'portrait_regional')
    save(track(), out, 'track')  # border 5
    save(fill(), out, 'fill')  # border 5
    save(pill((255, 255, 255, 255)), out, 'badge')  # border 5, tinted per type with image-color
    save(pill((90, 66, 10, 255)), out, 'tag')  # border 5
    save(check(), out, 'check')
    save(draw_lock((150, 170, 205, 255)), out, 'lock')
    save(draw_pin((255, 92, 92, 255)), out, 'pin')
    save(header_icon(), out, 'icon_fishing')


if __name__ == '__main__':
    main()
