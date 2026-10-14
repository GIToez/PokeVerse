#!/usr/bin/env python3
"""Draws the Tasks window artwork: the gold framed window, cards, tabs, progress bars, buttons
and icons, in the style of the login screens (login_ui.py).

    scripts/art/tasks_ui.py <out dir>

The output goes to core/client-redemption/pokeverse-modern/modules/game_dailytasks/images.
Frames are 9-slice images: the otui sets image-border to the border noted next to each one.
"""
import math
import sys
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter

sys.path.insert(0, str(Path(__file__).parent))
from login_ui import (canvas, save, s, vertical_gradient, rounded_mask, glow_frame, gradient_button,  # noqa: E402
                      outline_button, brighten, icon, draw_clock, draw_lock)

NAVY = (14, 22, 40, 244)
EDGE = (46, 74, 118, 255)
GOLD = (226, 178, 62, 255)
GOLD_LIGHT = (255, 214, 90, 255)
GOLD_GLOW = (240, 190, 80)
WHITE = (236, 242, 255, 255)
MUTED = (150, 170, 205, 255)
SKY = (120, 200, 255, 255)


def track(w=24, h=10):
    im = canvas(w, h)
    d = ImageDraw.Draw(im)
    d.rounded_rectangle((0, 0, im.width - 1, im.height - 1), s(h / 2), fill=(8, 14, 28, 255),
                        outline=(40, 64, 104, 255), width=s(1))
    return im


def fill(colors, w=24, h=10):
    im = canvas(w, h)
    g = vertical_gradient(im.width, im.height, colors[0], colors[1])
    g.putalpha(rounded_mask(im.width, im.height, s(h / 2)))
    im.alpha_composite(g)
    shine = Image.new('RGBA', im.size, (255, 255, 255, 0))
    m = Image.new('L', im.size, 0)
    ImageDraw.Draw(m).rounded_rectangle((s(1), s(1), im.width - s(1), im.height // 2), s(h / 2), fill=60)
    shine.putalpha(m)
    im.alpha_composite(shine)
    return im


def tab(on):
    im = canvas(48, 32)
    W, H = im.width, im.height
    if on:
        g = vertical_gradient(W, H, (44, 76, 128), (22, 40, 74))
        g.putalpha(rounded_mask(W, H, s(7)))
        im.alpha_composite(g)
        ImageDraw.Draw(im).rounded_rectangle((0, 0, W - 1, H - 1), s(7), outline=GOLD, width=s(1.6))
    else:
        ImageDraw.Draw(im).rounded_rectangle((0, 0, W - 1, H - 1), s(7), fill=(16, 26, 46, 235),
                                             outline=(52, 80, 124, 255), width=s(1.2))
    return im


def icon_frame(size=44):
    im = canvas(size, size)
    W = im.width
    g = vertical_gradient(W, W, (34, 54, 90), (14, 24, 44))
    g.putalpha(rounded_mask(W, W, s(8)))
    im.alpha_composite(g)
    ImageDraw.Draw(im).rounded_rectangle((0, 0, W - 1, W - 1), s(8), outline=(70, 110, 170, 255), width=s(1.2))
    return im


# --- icons -------------------------------------------------------------------------------

def draw_sun(color, size=18):
    im = icon(size)
    d = ImageDraw.Draw(im)
    c = s(size / 2)
    for i in range(8):
        a = i * math.pi / 4
        r0, r1 = s(size * 0.34), s(size * 0.48)
        d.line((c + r0 * math.cos(a), c + r0 * math.sin(a), c + r1 * math.cos(a), c + r1 * math.sin(a)),
               fill=color, width=s(size * 0.09))
    r = s(size * 0.24)
    d.ellipse((c - r, c - r, c + r, c + r), fill=color)
    return im


def draw_calendar(color, size=18, face=None):
    im = icon(size)
    d = ImageDraw.Draw(im)
    k = size / 18
    d.rounded_rectangle((s(2 * k), s(3.5 * k), s(16 * k), s(16.5 * k)), s(2 * k), outline=color, width=s(1.5 * k),
                        fill=face)
    d.rectangle((s(2 * k), s(3.5 * k), s(16 * k), s(7 * k)), fill=color)
    for x in (5.5, 12.5):
        d.line((s(x * k), s(1.5 * k), s(x * k), s(5 * k)), fill=color, width=s(1.6 * k))
    for row in range(2):
        for col in range(3):
            x, y = 5 + col * 4, 9.5 + row * 3.4
            d.rectangle((s(x * k), s(y * k), s((x + 1.8) * k), s((y + 1.8) * k)), fill=color)
    return im


def draw_crosshair(color, size=18):
    im = icon(size)
    d = ImageDraw.Draw(im)
    c, w = s(size / 2), s(size * 0.09)
    d.ellipse((s(size * 0.16), s(size * 0.16), s(size * 0.84), s(size * 0.84)), outline=color, width=w)
    d.ellipse((c - s(1.3), c - s(1.3), c + s(1.3), c + s(1.3)), fill=color)
    for a, b in ((0, size * 0.3), (size * 0.7, size)):
        d.line((s(a), c, s(b), c), fill=color, width=w)
        d.line((c, s(a), c, s(b)), fill=color, width=w)
    return im


def draw_info(color, size=14):
    im = icon(size)
    d = ImageDraw.Draw(im)
    d.ellipse((s(0.7), s(0.7), s(size - 0.7), s(size - 0.7)), outline=color, width=s(1.2))
    c = s(size / 2)
    d.ellipse((c - s(0.9), s(3), c + s(0.9), s(4.8)), fill=color)
    d.line((c, s(6.2), c, s(10.8)), fill=color, width=s(1.6))
    return im


def draw_refresh(color, size=14):
    im = icon(size)
    d = ImageDraw.Draw(im)
    d.arc((s(1.5), s(1.5), s(size - 1.5), s(size - 1.5)), 30, 320, fill=color, width=s(1.6))
    tip = (s(size - 2.2), s(size * 0.28))
    d.polygon((tip, (tip[0] - s(3.6), tip[1] - s(0.6)), (tip[0] - s(0.4), tip[1] + s(3.4))), fill=color)
    return im


def draw_clipboard(size=30):
    im = icon(size)
    d = ImageDraw.Draw(im)
    k = size / 30
    d.rounded_rectangle((s(4 * k), s(4 * k), s(26 * k), s(29 * k)), s(3 * k), fill=(196, 140, 70, 255),
                        outline=(120, 80, 36, 255), width=s(1.2 * k))
    d.rounded_rectangle((s(7 * k), s(8 * k), s(23 * k), s(26.5 * k)), s(1.5 * k), fill=(244, 246, 252, 255))
    d.rounded_rectangle((s(10 * k), s(1.5 * k), s(20 * k), s(7.5 * k)), s(2 * k), fill=(170, 182, 200, 255),
                        outline=(90, 100, 120, 255), width=s(1 * k))
    for i, y in enumerate((12.5, 17, 21.5)):
        d.line((s(9.5 * k), s(y * k), s(11.5 * k), s((y + 1.6) * k), s(14 * k), s((y - 1.6) * k)),
               fill=(60, 170, 90, 255), width=s(1.3 * k))
        d.line((s(15.5 * k), s(y * k), s(21 * k), s(y * k)), fill=(130, 146, 170, 255), width=s(1.4 * k))
    return im


def draw_chest(size=40):
    im = icon(size)
    d = ImageDraw.Draw(im)
    k = size / 40
    wood, dark, gold = (170, 96, 40, 255), (96, 50, 20, 255), (255, 206, 72, 255)
    d.rounded_rectangle((s(4 * k), s(16 * k), s(36 * k), s(35 * k)), s(2.5 * k), fill=wood, outline=dark,
                        width=s(1.4 * k))
    d.chord((s(4 * k), s(5 * k), s(36 * k), s(27 * k)), 180, 360, fill=(190, 110, 48, 255), outline=dark,
            width=s(1.4 * k))
    d.rectangle((s(4 * k), s(15 * k), s(36 * k), s(19 * k)), fill=gold, outline=dark, width=s(1 * k))
    for x in (8, 30):
        d.rectangle((s(x * k), s(6.5 * k), s((x + 2.6) * k), s(35 * k)), fill=gold)
    d.rounded_rectangle((s(16.5 * k), s(14 * k), s(23.5 * k), s(23.5 * k)), s(1.5 * k), fill=gold, outline=dark,
                        width=s(1 * k))
    d.ellipse((s(19 * k), s(17 * k), s(21 * k), s(19 * k)), fill=dark)
    glow = Image.new('RGBA', im.size, (255, 230, 120, 0))
    m = Image.new('L', im.size, 0)
    ImageDraw.Draw(m).ellipse((s(8 * k), s(4 * k), s(32 * k), s(16 * k)), fill=70)
    glow.putalpha(m.filter(ImageFilter.GaussianBlur(s(3 * k))))
    im.alpha_composite(glow)
    return im


def draw_points(size=22):
    """Hunt Points: a teal four point star."""
    im = icon(size)
    d = ImageDraw.Draw(im)
    c = s(size / 2)
    pts = []
    for i in range(8):
        a = -math.pi / 2 + i * math.pi / 4
        rad = s(size * 0.48) if i % 2 == 0 else s(size * 0.16)
        pts.append((c + rad * math.cos(a), c + rad * math.sin(a)))
    d.polygon(pts, fill=(90, 230, 220, 255), outline=(30, 120, 130, 255))
    d.ellipse((c - s(size * 0.08), c - s(size * 0.08), c + s(size * 0.08), c + s(size * 0.08)),
              fill=(230, 255, 255, 255))
    return im


MEDALS = {
    'bronze': ((222, 150, 92), (150, 86, 44)),
    'silver': ((232, 238, 248), (140, 152, 172)),
    'gold': ((255, 222, 96), (204, 140, 24)),
    'master': ((196, 140, 255), (110, 60, 190)),
}


def draw_medal(colors, size=44):
    im = icon(size)
    W = im.width
    c = W / 2
    pts = []
    for i in range(6):
        a = math.pi / 6 + i * math.pi / 3
        pts.append((c + s(size * 0.46) * math.cos(a), c + s(size * 0.46) * math.sin(a)))
    g = vertical_gradient(W, W, colors[0], colors[1])
    m = Image.new('L', (W, W), 0)
    ImageDraw.Draw(m).polygon(pts, fill=255)
    g.putalpha(m)
    im.alpha_composite(g)
    d = ImageDraw.Draw(im)
    d.polygon(pts, outline=(255, 255, 255, 150), width=s(1.2))
    inner = [(c + (x - c) * 0.66, c + (y - c) * 0.66) for x, y in pts]
    d.polygon(inner, fill=(22, 32, 54, 255), outline=colors[1] + (255,), width=s(1))
    star = []
    for i in range(10):
        a = -math.pi / 2 + i * math.pi / 5
        rad = s(size * 0.2) if i % 2 == 0 else s(size * 0.085)
        star.append((c + rad * math.cos(a), c + rad * math.sin(a)))
    d.polygon(star, fill=colors[0] + (255,))
    return im


def draw_ready(kind, size=72):
    """The big picture on the "Ready for a new day/week?" card: a sun or a calendar in a glow."""
    im = canvas(size, size)
    W = im.width
    halo = Image.new('RGBA', (W, W), GOLD_GLOW + (0,))
    m = Image.new('L', (W, W), 0)
    ImageDraw.Draw(m).ellipse((s(6), s(6), W - s(6), W - s(6)), fill=120)
    halo.putalpha(m.filter(ImageFilter.GaussianBlur(s(8))))
    im.alpha_composite(halo)
    picture = (draw_sun(GOLD_LIGHT, 48) if kind == 'sun'
               else draw_calendar((236, 92, 80, 255), 48, face=(250, 246, 236, 255)))
    im.alpha_composite(picture, ((W - picture.width) // 2, (W - picture.height) // 2))
    return im


def main():
    out = Path(sys.argv[1])
    out.mkdir(parents=True, exist_ok=True)

    save(glow_frame(64, 64, 14, NAVY, GOLD, GOLD_GLOW, 8), out, 'window')  # border 24
    save(glow_frame(40, 40, 8, (18, 30, 54, 240), EDGE, None, 0), out, 'card')  # border 10
    save(glow_frame(40, 40, 8, (12, 20, 38, 220), (40, 64, 104, 255), None, 0), out, 'section')  # border 10
    save(glow_frame(40, 40, 8, (34, 30, 30, 235), (176, 138, 56, 255), None, 0), out, 'card_gold')  # border 10
    save(icon_frame(), out, 'icon_frame')  # border 10
    save(tab(False), out, 'tab')  # border 8
    save(brighten(tab(False), 1.3), out, 'tab_hover')
    save(tab(True), out, 'tab_on')
    save(track(), out, 'track')  # border 5
    save(fill(((110, 196, 255), (40, 112, 220))), out, 'fill_blue')
    save(fill(((255, 222, 96), (226, 150, 20))), out, 'fill_gold')
    save(fill(((110, 230, 150), (36, 160, 90))), out, 'fill_green')
    claim = gradient_button(48, 32, 7, ((70, 146, 240), (32, 86, 186)), (150, 200, 255, 255))
    save(claim, out, 'button_claim')  # border 8
    save(brighten(claim, 1.15), out, 'button_claim_hover')
    save(brighten(claim, 0.85), out, 'button_claim_pressed')
    save(outline_button(48, 32, 7, (60, 84, 120, 255), (20, 30, 50, 235)), out, 'button_off')

    save(draw_clipboard(), out, 'icon_tasks')
    save(draw_sun(GOLD_LIGHT), out, 'icon_daily')
    save(draw_calendar(WHITE), out, 'icon_weekly')
    save(draw_crosshair(WHITE), out, 'icon_hunting')
    save(draw_clock(GOLD_LIGHT), out, 'icon_clock')
    save(draw_info(SKY), out, 'icon_info')
    save(draw_refresh(WHITE), out, 'icon_refresh')
    save(draw_lock(MUTED), out, 'icon_lock')
    save(draw_chest(), out, 'chest')
    save(draw_points(), out, 'icon_points')
    for name, colors in MEDALS.items():
        save(draw_medal(colors), out, 'rank_' + name)
    save(draw_ready('sun'), out, 'ready_daily')
    save(draw_ready('calendar'), out, 'ready_weekly')


if __name__ == '__main__':
    main()
