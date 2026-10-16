#!/usr/bin/env python3
"""Draws the Day Care window artwork (game_daycare): the two Pokemon cards (edged in the Pokemon's
gender color), the egg slot ring and the event pill.

    scripts/art/daycare_ui.py <out dir>

The output goes to core/client-redemption/pokeverse-modern/modules/game_daycare/images. The window
frame is the Tasks window's (game_dailytasks/images/window); panels, rows, portraits and the training
bar are the Fishing Guide's (game_fishing/images), the sex marks the Trainer Card's, the header and
info icons the vocation window's (icon_breeder, perk_*), and the eggs are the egg items. Frames are 9-slice images: the otui sets image-border to the border noted
next to each one.
"""
import sys
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter

sys.path.insert(0, str(Path(__file__).parent))
from login_ui import canvas, save, s  # noqa: E402

MALE = (96, 170, 255)
FEMALE = (255, 120, 180)
NEUTRAL = (186, 160, 230)
EMPTY = (70, 92, 130)
GOLD = (255, 214, 90)


def blur(im, radius):
    return im.filter(ImageFilter.GaussianBlur(radius))


def card(edge, glow):
    im = canvas(48, 48)
    W, H = im.size
    if glow:
        g = Image.new('RGBA', im.size, edge + (0,))
        m = Image.new('L', im.size, 0)
        ImageDraw.Draw(m).rounded_rectangle((s(3), s(3), W - s(3), H - s(3)), s(9), outline=170, width=s(3))
        g.putalpha(blur(m, s(2)))
        im.alpha_composite(g)
    ImageDraw.Draw(im).rounded_rectangle((s(3), s(3), W - s(3), H - s(3)), s(9), fill=(14, 24, 44, 240),
                                         outline=edge + (255,), width=s(1.6))
    return im


def egg_slot(edge):
    im = canvas(112, 112)
    W = im.width
    g = Image.new('RGBA', im.size, edge + (0,))
    m = Image.new('L', im.size, 0)
    ImageDraw.Draw(m).ellipse((s(6), s(6), W - s(6), W - s(6)), outline=190, width=s(4))
    g.putalpha(blur(m, s(3)))
    im.alpha_composite(g)
    d = ImageDraw.Draw(im)
    d.ellipse((s(6), s(6), W - s(6), W - s(6)), fill=(12, 20, 38, 245), outline=edge + (255,), width=s(2))
    d.ellipse((s(14), s(14), W - s(14), W - s(14)), outline=edge + (90,), width=s(1))
    return im


def pill(color):
    im = canvas(24, 18)
    ImageDraw.Draw(im).rounded_rectangle((0, 0, im.width - 1, im.height - 1), s(5), fill=color)
    return im


def main():
    out = Path(sys.argv[1]) if len(sys.argv) > 1 else (
        Path(__file__).resolve().parents[2] / 'core/client-redemption/pokeverse-modern/modules/game_daycare/images')
    out.mkdir(parents=True, exist_ok=True)
    save(card(MALE, True), out, 'card_male')  # border 12
    save(card(FEMALE, True), out, 'card_female')  # border 12
    save(card(NEUTRAL, True), out, 'card_neutral')  # border 12
    save(card(EMPTY, False), out, 'card_empty')  # border 12
    save(egg_slot(EMPTY), out, 'egg_slot')
    save(egg_slot(GOLD), out, 'egg_slot_ready')
    save(pill((92, 66, 10, 240)), out, 'event')  # border 6


if __name__ == '__main__':
    main()
