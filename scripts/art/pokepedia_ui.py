#!/usr/bin/env python3
"""Draws the Pokepedia window icons, in the style of the Tasks window (tasks_ui.py).

    scripts/art/pokepedia_ui.py <out dir>

The output goes to core/client-redemption/pokeverse-modern/modules/game_pokepedia/images. The window
frame, tabs, cards and buttons are the Tasks window's (game_dailytasks/images).
"""
import math
import sys
from pathlib import Path

from PIL import ImageDraw

sys.path.insert(0, str(Path(__file__).parent))
from login_ui import canvas, save, s, icon, draw_pokeball  # noqa: E402

GOLD = (226, 178, 62, 255)
GOLD_LIGHT = (255, 214, 90, 255)
WHITE = (236, 242, 255, 255)
SKY = (120, 200, 255, 255)
NAVY = (14, 22, 40, 255)
GREEN = (98, 214, 140, 255)
RED = (240, 96, 96, 255)


def draw_book(size=30):
    im = icon(size)
    d = ImageDraw.Draw(im)
    k = size / 30
    d.rounded_rectangle((s(4 * k), s(3 * k), s(26 * k), s(27 * k)), s(3 * k), fill=(196, 52, 52, 255),
                        outline=(120, 24, 24, 255), width=s(1.2 * k))
    d.rectangle((s(6.5 * k), s(3 * k), s(8 * k), s(27 * k)), fill=(120, 24, 24, 255))
    d.rectangle((s(22.5 * k), s(5 * k), s(26 * k), s(25 * k)), fill=(244, 238, 222, 255))
    ball = draw_pokeball(round(12 * k))
    im.alpha_composite(ball, (s(10.5 * k), s(9 * k)))
    return im


def draw_map(color, size=18):
    im = icon(size)
    d = ImageDraw.Draw(im)
    k = size / 18
    pts = [(2, 4), (6.5, 2), (11.5, 4), (16, 2), (16, 14), (11.5, 16), (6.5, 14), (2, 16)]
    d.polygon([(s(x * k), s(y * k)) for x, y in pts], outline=color, width=s(1.5 * k))
    for x in (6.5, 11.5):
        d.line((s(x * k), s((2 if x == 6.5 else 4) * k), s(x * k), s((14 if x == 6.5 else 16) * k)), fill=color,
               width=s(1.3 * k))
    return im


def draw_house(color, size=18):
    im = icon(size)
    d = ImageDraw.Draw(im)
    k = size / 18
    d.polygon(((s(1.5 * k), s(8.5 * k)), (s(9 * k), s(2 * k)), (s(16.5 * k), s(8.5 * k))), fill=color)
    d.rectangle((s(3.5 * k), s(8 * k), s(14.5 * k), s(16 * k)), fill=color)
    d.rectangle((s(7.5 * k), s(10.5 * k), s(10.5 * k), s(16 * k)), fill=NAVY)
    return im


def draw_dex(color, size=18):
    im = icon(size)
    d = ImageDraw.Draw(im)
    k = size / 18
    d.rounded_rectangle((s(3 * k), s(1.5 * k), s(15 * k), s(16.5 * k)), s(2 * k), outline=color, width=s(1.5 * k))
    d.ellipse((s(5.5 * k), s(4 * k), s(9.5 * k), s(8 * k)), fill=color)
    d.rectangle((s(5.5 * k), s(10.5 * k), s(12.5 * k), s(11.8 * k)), fill=color)
    d.rectangle((s(5.5 * k), s(13 * k), s(10.5 * k), s(14.3 * k)), fill=color)
    return im


def draw_bag(color, size=18):
    im = icon(size)
    d = ImageDraw.Draw(im)
    k = size / 18
    d.arc((s(5.5 * k), s(1.5 * k), s(12.5 * k), s(8.5 * k)), 180, 360, fill=color, width=s(1.5 * k))
    d.rounded_rectangle((s(2.5 * k), s(5 * k), s(15.5 * k), s(16.5 * k)), s(2.5 * k), fill=color)
    d.rectangle((s(6.5 * k), s(9 * k), s(11.5 * k), s(11 * k)), fill=NAVY)
    return im


def draw_pin(color, size=16):
    im = icon(size)
    d = ImageDraw.Draw(im)
    k = size / 16
    d.ellipse((s(3 * k), s(0.8 * k), s(13 * k), s(10.8 * k)), fill=color, outline=NAVY, width=s(1 * k))
    d.polygon(((s(4 * k), s(8 * k)), (s(12 * k), s(8 * k)), (s(8 * k), s(15.5 * k))), fill=color)
    d.ellipse((s(6 * k), s(3.8 * k), s(10 * k), s(7.8 * k)), fill=NAVY)
    return im


def draw_dot(color, size=6):
    im = icon(size)
    d = ImageDraw.Draw(im)
    d.ellipse((s(0.5), s(0.5), s(size - 0.5), s(size - 0.5)), fill=color, outline=NAVY, width=s(0.8))
    return im


def draw_flag(color, size=16):
    im = icon(size)
    d = ImageDraw.Draw(im)
    k = size / 16
    d.line((s(4 * k), s(1.5 * k), s(4 * k), s(15 * k)), fill=WHITE, width=s(1.6 * k))
    d.polygon(((s(4.5 * k), s(2 * k)), (s(14 * k), s(5 * k)), (s(4.5 * k), s(8.5 * k))), fill=color)
    return im


def draw_center(color, size=16):
    im = icon(size)
    d = ImageDraw.Draw(im)
    c, w = s(size / 2), s(size * 0.1)
    d.ellipse((s(size * 0.2), s(size * 0.2), s(size * 0.8), s(size * 0.8)), outline=color, width=w)
    d.ellipse((c - s(1.6), c - s(1.6), c + s(1.6), c + s(1.6)), fill=color)
    for a, b in ((0, size * 0.25), (size * 0.75, size)):
        d.line((s(a), c, s(b), c), fill=color, width=w)
        d.line((c, s(a), c, s(b)), fill=color, width=w)
    return im


def draw_arrow(color, up, size=14):
    im = icon(size)
    d = ImageDraw.Draw(im)
    if up:
        pts = ((size / 2, 2), (size - 2, size - 4), (2, size - 4))
    else:
        pts = ((2, 4), (size - 2, 4), (size / 2, size - 2))
    d.polygon([(s(x), s(y)) for x, y in pts], fill=color)
    return im


def draw_route(color, size=18):
    im = icon(size)
    d = ImageDraw.Draw(im)
    k = size / 18
    pts = [(3, 15), (7, 9), (11, 11), (15, 3)]
    for i in range(len(pts) - 1):
        d.line((s(pts[i][0] * k), s(pts[i][1] * k), s(pts[i + 1][0] * k), s(pts[i + 1][1] * k)), fill=color,
               width=s(1.6 * k))
    for x, y in pts:
        d.ellipse((s((x - 1.8) * k), s((y - 1.8) * k), s((x + 1.8) * k), s((y + 1.8) * k)), fill=color)
    return im


def draw_eye(color, size=14):
    im = icon(size)
    d = ImageDraw.Draw(im)
    d.ellipse((s(1), s(3.5), s(size - 1), s(size - 3.5)), outline=color, width=s(1.4))
    c = s(size / 2)
    d.ellipse((c - s(2.2), c - s(2.2), c + s(2.2), c + s(2.2)), fill=color)
    return im


def draw_question(size=32):
    im = icon(size)
    d = ImageDraw.Draw(im)
    d.rounded_rectangle((s(1), s(1), s(size - 1), s(size - 1)), s(5), fill=(20, 32, 58, 255),
                        outline=(52, 80, 124, 255), width=s(1.2))
    k = size / 32
    d.arc((s(10 * k), s(6 * k), s(22 * k), s(17 * k)), 200, 380, fill=(110, 130, 170, 255), width=s(3 * k))
    d.line((s(16 * k), s(16.5 * k), s(16 * k), s(20 * k)), fill=(110, 130, 170, 255), width=s(3 * k))
    d.ellipse((s(14.3 * k), s(22.5 * k), s(17.7 * k), s(25.9 * k)), fill=(110, 130, 170, 255))
    return im


def draw_pin_button(color, size=12):
    im = icon(size)
    d = ImageDraw.Draw(im)
    k = size / 12
    d.ellipse((s(3 * k), s(0.5 * k), s(9 * k), s(6.5 * k)), fill=color)
    d.line((s(6 * k), s(6 * k), s(6 * k), s(11.5 * k)), fill=color, width=s(1.5 * k))
    return im


def draw_x(color, size=12):
    im = icon(size)
    d = ImageDraw.Draw(im)
    w = s(1.6)
    d.line((s(2.5), s(2.5), s(size - 2.5), s(size - 2.5)), fill=color, width=w)
    d.line((s(size - 2.5), s(2.5), s(2.5), s(size - 2.5)), fill=color, width=w)
    return im


def draw_open_book(color, size=18):
    im = icon(size)
    d = ImageDraw.Draw(im)
    k = size / 18
    for side in (-1, 1):
        x0, x1 = (9 - 0.4) * k, (9 + side * 7.8) * k
        d.polygon(((s(x0), s(4 * k)), (s(x1), s(2.5 * k)), (s(x1), s(14 * k)), (s(x0), s(15.5 * k))), fill=color)
        for y in (5.8, 8.3, 10.8):
            d.line((s((9 + side * 2) * k), s((y + 0.2) * k), s((9 + side * 6) * k), s((y - 0.6) * k)), fill=NAVY,
                   width=s(1 * k))
    d.line((s(9 * k), s(4 * k), s(9 * k), s(15.5 * k)), fill=NAVY, width=s(1.2 * k))
    return im


def draw_chevron(color, down, size=12):
    im = icon(size)
    d = ImageDraw.Draw(im)
    if down:
        pts = ((2.5, 4), (6, 8), (9.5, 4))
    else:
        pts = ((4, 2.5), (8, 6), (4, 9.5))
    d.line([(s(x * size / 12), s(y * size / 12)) for x, y in pts], fill=color, width=s(1.8), joint='curve')
    return im


def draw_step_badge(size=20):
    im = icon(size)
    d = ImageDraw.Draw(im)
    d.ellipse((s(0.5), s(0.5), s(size - 0.5), s(size - 0.5)), fill=GOLD_LIGHT, outline=GOLD, width=s(1))
    return im


def draw_keycap(size=22):
    """A keyboard key, stretched with a 6 px border."""
    im = icon(size)
    d = ImageDraw.Draw(im)
    d.rounded_rectangle((s(0.5), s(0.5), s(size - 0.5), s(size - 0.5)), s(5), fill=(14, 22, 40, 255),
                        outline=(70, 100, 150, 255), width=s(1))
    d.rounded_rectangle((s(1.5), s(1.5), s(size - 1.5), s(size - 3.5)), s(4), fill=(36, 56, 96, 255))
    return im


FRAME = Path(__file__).resolve().parents[2] / 'core/client-redemption/data/images/options/button_taskboard.png'


def toolbar_button(art, out, name):
    """A 40x20 side-panel button (off and on halves) on the frame of the Redemption buttons."""
    from PIL import Image
    frame = Image.open(FRAME).convert('RGBA')
    d = ImageDraw.Draw(frame)
    for x in (0, 20):
        d.rectangle((x + 2, 2, x + 17, 17), fill=frame.getpixel((x + 2, 2)))
    small = art.resize((14, 14), Image.LANCZOS)
    for x in (0, 20):
        frame.alpha_composite(small, (x + 3, 3))
    frame.save(out / (name + '.png'))


def main():
    out = Path(sys.argv[1] if len(sys.argv) > 1 else '.')
    out.mkdir(parents=True, exist_ok=True)
    book = draw_book(56)
    toolbar_button(book, out, 'button_pokepedia')
    toolbar_button(draw_route(GOLD_LIGHT, 56), out, 'button_tracker')
    save(draw_book(), out, 'icon_pokepedia')
    save(draw_book(18), out, 'icon_pokepedia_small')
    save(draw_map(WHITE), out, 'icon_map')
    save(draw_house(WHITE), out, 'icon_house')
    save(draw_dex(WHITE), out, 'icon_dex')
    save(draw_bag(WHITE), out, 'icon_items')
    save(draw_route(WHITE), out, 'icon_route')
    save(draw_pin(GOLD_LIGHT), out, 'mark_waypoint')
    save(draw_pin(SKY), out, 'mark_stop')
    save(draw_pin(GREEN), out, 'mark_reached')
    save(draw_flag(RED), out, 'mark_spawn')
    save(draw_dot(GOLD_LIGHT), out, 'route_dot')
    save(draw_center(WHITE), out, 'icon_center')
    save(draw_arrow(WHITE, True), out, 'icon_floor_up')
    save(draw_arrow(WHITE, False), out, 'icon_floor_down')
    save(draw_eye(WHITE), out, 'icon_show')
    save(draw_question(), out, 'item_unknown')
    save(draw_pin_button(GOLD_LIGHT), out, 'icon_pinned')
    save(draw_pin_button((150, 170, 205, 255)), out, 'icon_pin')
    save(draw_x((150, 170, 205, 255)), out, 'icon_remove')
    save(draw_open_book(WHITE), out, 'icon_wiki')
    save(draw_chevron(GOLD_LIGHT, False), out, 'chevron_right')
    save(draw_chevron(GOLD_LIGHT, True), out, 'chevron_down')
    save(draw_step_badge(), out, 'step_badge')
    save(draw_keycap(), out, 'keycap')


if __name__ == '__main__':
    main()
