#!/usr/bin/env python3
"""Draws the login and character select artwork: panel frames, fields, buttons, character
cards and the small icons.

    scripts/art/login_ui.py <out dir>

The output goes to core/client-redemption/pokeverse-modern/modules/client_entergame/images.
Frames are 9-slice images: the otui sets image-border to the BORDER of each frame.
"""
import math
import sys
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter

SCALE = 4  # drawn large, then scaled down for smooth edges

NAVY = (14, 22, 40, 238)
NAVY_LIGHT = (24, 36, 60, 245)
FIELD = (10, 16, 30, 235)
EDGE = (52, 92, 150, 255)
GLOW = (64, 170, 255)
WHITE = (236, 242, 255, 255)
MUTED = (150, 170, 205, 255)
YELLOW = ((255, 214, 64), (244, 170, 20))
GREEN = ((62, 200, 120), (28, 150, 82))
CARD_GREEN = ((40, 150, 110), (22, 96, 76))


def canvas(w, h):
    return Image.new('RGBA', (w * SCALE, h * SCALE), (0, 0, 0, 0))


def save(im, out, name):
    w, h = im.width // SCALE, im.height // SCALE
    im.resize((w, h), Image.LANCZOS).save(out / f'{name}.png')


def s(v):
    return int(round(v * SCALE))


def vertical_gradient(w, h, top, bottom):
    g = Image.new('RGBA', (w, h))
    px = g.load()
    for y in range(h):
        t = y / max(1, h - 1)
        c = tuple(int(top[i] + (bottom[i] - top[i]) * t) for i in range(3)) + (255,)
        for x in range(w):
            px[x, y] = c
    return g


def rounded_mask(w, h, r, inset=0):
    m = Image.new('L', (w, h), 0)
    ImageDraw.Draw(m).rounded_rectangle((inset, inset, w - 1 - inset, h - 1 - inset), r, fill=255)
    return m


def glow_frame(w, h, r, fill, edge, glow, glow_size):
    """A rounded panel with an outer glow, the glow inside the image margin."""
    im = canvas(w, h)
    W, H, R, G = im.width, im.height, s(r), s(glow_size)
    if glow:
        halo = Image.new('RGBA', (W, H), glow + (0,))
        m = Image.new('L', (W, H), 0)
        ImageDraw.Draw(m).rounded_rectangle((G, G, W - 1 - G, H - 1 - G), R, outline=200, width=s(2))
        m = m.filter(ImageFilter.GaussianBlur(G / 2))
        halo.putalpha(m)
        im.alpha_composite(halo)
    body = Image.new('RGBA', (W, H), fill)
    body.putalpha(Image.eval(rounded_mask(W, H, R, G), lambda a: a * fill[3] // 255))
    im.alpha_composite(body)
    d = ImageDraw.Draw(im)
    d.rounded_rectangle((G, G, W - 1 - G, H - 1 - G), R, outline=edge, width=s(1.5))
    return im


def gradient_button(w, h, r, colors, outline=None, shine=True):
    im = canvas(w, h)
    W, H = im.width, im.height
    g = vertical_gradient(W, H, colors[0], colors[1])
    g.putalpha(rounded_mask(W, H, s(r)))
    im.alpha_composite(g)
    d = ImageDraw.Draw(im)
    if shine:
        top = Image.new('RGBA', (W, H), (255, 255, 255, 0))
        m = Image.new('L', (W, H), 0)
        ImageDraw.Draw(m).rounded_rectangle((s(1), s(1), W - 1 - s(1), H // 2), s(r), fill=46)
        top.putalpha(m)
        im.alpha_composite(top)
    d.rounded_rectangle((0, 0, W - 1, H - 1), s(r), outline=outline or (255, 255, 255, 70), width=s(1))
    return im


def outline_button(w, h, r, color, fill=(16, 26, 46, 230)):
    im = canvas(w, h)
    W, H = im.width, im.height
    d = ImageDraw.Draw(im)
    d.rounded_rectangle((0, 0, W - 1, H - 1), s(r), fill=fill, outline=color, width=s(1.5))
    return im


def brighten(im, amount):
    r, g, b, a = im.split()
    rgb = Image.merge('RGB', (r, g, b)).point(lambda v: min(255, int(v * amount)))
    out = rgb.convert('RGBA')
    out.putalpha(a)
    return out


# --- icons (drawn in a 16x16 box unless noted) -------------------------------------------

def icon(size=16):
    return canvas(size, size)


def draw_user(color):
    im = icon()
    d = ImageDraw.Draw(im)
    d.ellipse((s(5), s(2), s(11), s(8)), fill=color)
    d.chord((s(2.5), s(9), s(13.5), s(19)), 180, 360, fill=color)
    return im


def draw_lock(color):
    im = icon()
    d = ImageDraw.Draw(im)
    d.arc((s(4.5), s(1.5), s(11.5), s(9.5)), 180, 360, fill=color, width=s(1.6))
    d.line((s(4.5), s(5.5), s(4.5), s(8)), fill=color, width=s(1.6))
    d.line((s(11.5), s(5.5), s(11.5), s(8)), fill=color, width=s(1.6))
    d.rounded_rectangle((s(3), s(7.5), s(13), s(14.5)), s(1.5), fill=color)
    d.ellipse((s(7), s(9.5), s(9), s(11.5)), fill=(14, 22, 40, 255))
    return im


def draw_eye(color, crossed):
    im = icon(18)
    d = ImageDraw.Draw(im)
    d.arc((s(0.5), s(4), s(17.5), s(22)), 207, 333, fill=color, width=s(1.5))
    d.arc((s(0.5), s(-4), s(17.5), s(14)), 27, 153, fill=color, width=s(1.5))
    d.ellipse((s(6.5), s(6.5), s(11.5), s(11.5)), fill=color)
    if crossed:
        d.line((s(3), s(15), s(15), s(3)), fill=(14, 22, 40, 255), width=s(3))
        d.line((s(3), s(15), s(15), s(3)), fill=color, width=s(1.5))
    return im


def draw_check(box, checked):
    im = icon()
    d = ImageDraw.Draw(im)
    if checked:
        d.rounded_rectangle((s(1), s(1), s(15), s(15)), s(3), fill=(236, 242, 255, 255))
        d.line((s(4), s(8.5), s(7), s(11.5), s(12.5), s(4.5)), fill=(20, 40, 80, 255), width=s(2), joint='curve')
    else:
        d.rounded_rectangle((s(1), s(1), s(15), s(15)), s(3), fill=(10, 16, 30, 255), outline=box, width=s(1.3))
    return im


def draw_gear(color, size=24):
    im = icon(size)
    d = ImageDraw.Draw(im)
    c, R, r = s(size / 2), s(size * 0.40), s(size * 0.30)
    pts = []
    teeth = 8
    for i in range(teeth * 4):
        a = i / (teeth * 4) * 2 * math.pi
        rad = R if (i % 4) in (0, 1) else r
        pts.append((c + rad * math.cos(a), c + rad * math.sin(a)))
    d.polygon(pts, fill=color)
    hole = s(size * 0.14)
    d.ellipse((c - hole, c - hole, c + hole, c + hole), fill=(0, 0, 0, 0))
    return im


def draw_news(color, size=24):
    im = icon(size)
    d = ImageDraw.Draw(im)
    k = size / 24
    d.rounded_rectangle((s(5 * k), s(3 * k), s(19 * k), s(21 * k)), s(2 * k), outline=color, width=s(1.8 * k))
    for y in (8, 12, 16):
        d.line((s(8 * k), s(y * k), s(16 * k), s(y * k)), fill=color, width=s(1.6 * k))
    return im


def draw_globe(color, size=24):
    im = icon(size)
    d = ImageDraw.Draw(im)
    k = size / 24
    box = (s(3 * k), s(3 * k), s(21 * k), s(21 * k))
    w = s(1.6 * k)
    d.ellipse(box, outline=color, width=w)
    d.ellipse((s(8 * k), s(3 * k), s(16 * k), s(21 * k)), outline=color, width=w)
    d.line((s(3 * k), s(12 * k), s(21 * k), s(12 * k)), fill=color, width=w)
    d.line((s(12 * k), s(3 * k), s(12 * k), s(21 * k)), fill=color, width=w)
    return im


def draw_male(color):
    im = icon()
    d = ImageDraw.Draw(im)
    d.ellipse((s(2), s(5.5), s(10.5), s(14)), outline=color, width=s(1.8))
    d.line((s(9), s(7), s(14), s(2)), fill=color, width=s(1.8))
    d.line((s(9.5), s(2), s(14), s(2), s(14), s(6.5)), fill=color, width=s(1.8))
    return im


def draw_female(color):
    im = icon()
    d = ImageDraw.Draw(im)
    d.ellipse((s(3.5), s(1), s(12.5), s(10)), outline=color, width=s(1.8))
    d.line((s(8), s(10), s(8), s(15.5)), fill=color, width=s(1.8))
    d.line((s(5.5), s(13), s(10.5), s(13)), fill=color, width=s(1.8))
    return im


def draw_star(color):
    im = icon(12)
    d = ImageDraw.Draw(im)
    c = s(6)
    pts = []
    for i in range(10):
        a = -math.pi / 2 + i * math.pi / 5
        rad = s(5.5) if i % 2 == 0 else s(2.4)
        pts.append((c + rad * math.cos(a), c + rad * math.sin(a)))
    d.polygon(pts, fill=color)
    return im


def draw_pin(color):
    im = icon(12)
    d = ImageDraw.Draw(im)
    d.ellipse((s(2), s(0.5), s(10), s(8.5)), fill=color)
    d.polygon(((s(2.6), s(6)), (s(9.4), s(6)), (s(6), s(11.5))), fill=color)
    d.ellipse((s(4.4), s(2.9), s(7.6), s(6.1)), fill=(14, 22, 40, 255))
    return im


def draw_clock(color):
    im = icon(12)
    d = ImageDraw.Draw(im)
    d.ellipse((s(0.8), s(0.8), s(11.2), s(11.2)), outline=color, width=s(1.3))
    d.line((s(6), s(3), s(6), s(6), s(8.5), s(7.5)), fill=color, width=s(1.3))
    return im


def draw_calendar(color):
    im = icon(12)
    d = ImageDraw.Draw(im)
    d.rounded_rectangle((s(1), s(2), s(11), s(11)), s(1.2), outline=color, width=s(1.3))
    d.rectangle((s(1), s(2), s(11), s(4.5)), fill=color)
    for x in (3.5, 8.5):
        d.line((s(x), s(0.5), s(x), s(2.5)), fill=color, width=s(1.3))
    return im


def draw_plus(color, size=34):
    im = icon(size)
    d = ImageDraw.Draw(im)
    w = s(2)
    d.ellipse((s(1), s(1), s(size - 1), s(size - 1)), outline=color, width=w)
    c = s(size / 2)
    d.line((c, s(size * 0.28), c, s(size * 0.72)), fill=color, width=w)
    d.line((s(size * 0.28), c, s(size * 0.72), c), fill=color, width=w)
    return im


def draw_close(color):
    im = icon(18)
    d = ImageDraw.Draw(im)
    d.rounded_rectangle((s(0.5), s(0.5), s(17.5), s(17.5)), s(3), outline=(90, 120, 170, 255), width=s(1.2),
                        fill=(16, 26, 46, 230))
    d.line((s(5.5), s(5.5), s(12.5), s(12.5)), fill=color, width=s(1.6))
    d.line((s(12.5), s(5.5), s(5.5), s(12.5)), fill=color, width=s(1.6))
    return im


def draw_trash(color):
    im = icon(14)
    d = ImageDraw.Draw(im)
    d.line((s(2), s(3.5), s(12), s(3.5)), fill=color, width=s(1.4))
    d.line((s(5.5), s(1.5), s(8.5), s(1.5)), fill=color, width=s(1.4))
    d.polygon(((s(3), s(4.5)), (s(11), s(4.5)), (s(10.2), s(13)), (s(3.8), s(13))), outline=color, width=s(1.3))
    return im


def draw_pokeball(size, top=(232, 64, 64, 255), line=(20, 26, 40, 255), bottom=(240, 244, 250, 255)):
    im = icon(size)
    d = ImageDraw.Draw(im)
    box = (s(0.6), s(0.6), s(size - 0.6), s(size - 0.6))
    d.pieslice(box, 180, 360, fill=top)
    d.pieslice(box, 0, 180, fill=bottom)
    c = s(size / 2)
    d.line((box[0], c, box[2], c), fill=line, width=s(size * 0.09))
    d.ellipse(box, outline=line, width=s(size * 0.07))
    r = s(size * 0.17)
    d.ellipse((c - r, c - r, c + r, c + r), fill=bottom, outline=line, width=s(size * 0.07))
    return im


def draw_badge(size=44):
    """The pokeball emblem on top of the login panel."""
    im = canvas(size, size)
    W = im.width
    halo = Image.new('RGBA', (W, W), GLOW + (0,))
    m = Image.new('L', (W, W), 0)
    ImageDraw.Draw(m).ellipse((s(4), s(4), W - s(4), W - s(4)), fill=220)
    halo.putalpha(m.filter(ImageFilter.GaussianBlur(s(3))))
    im.alpha_composite(halo)
    d = ImageDraw.Draw(im)
    d.ellipse((s(6), s(6), W - s(6), W - s(6)), fill=NAVY_LIGHT, outline=EDGE, width=s(1.5))
    ball = draw_pokeball(20, top=(120, 190, 255, 255), line=(14, 22, 40, 255), bottom=(220, 236, 255, 255))
    im.alpha_composite(ball, ((W - ball.width) // 2, (W - ball.height) // 2))
    return im


def draw_party_slot(size=40):
    im = canvas(size, size)
    W = im.width
    d = ImageDraw.Draw(im)
    g = vertical_gradient(W, W, (36, 54, 86), (16, 26, 46))
    m = Image.new('L', (W, W), 0)
    ImageDraw.Draw(m).ellipse((s(1), s(1), W - s(1), W - s(1)), fill=255)
    g.putalpha(m)
    im.alpha_composite(g)
    d.ellipse((s(1), s(1), W - s(1), W - s(1)), outline=(80, 120, 180, 255), width=s(1.2))
    return im


def draw_portrait(w=82, h=98):
    im = glow_frame(w, h, 8, (12, 22, 44, 240), EDGE, GLOW, 5)
    W, H = im.width, im.height
    spot = Image.new('RGBA', (W, H), (90, 170, 255, 0))
    m = Image.new('L', (W, H), 0)
    ImageDraw.Draw(m).ellipse((s(14), H - s(36), W - s(14), H - s(14)), fill=110)
    spot.putalpha(m.filter(ImageFilter.GaussianBlur(s(4))))
    im.alpha_composite(spot)
    return im


def draw_card_create(w=64, h=64):
    im = canvas(w, h)
    W, H = im.width, im.height
    d = ImageDraw.Draw(im)
    d.rounded_rectangle((0, 0, W - 1, H - 1), s(8), fill=(14, 22, 40, 200))
    # dashed outline
    dash, gap, inset = s(6), s(4), s(1)
    color = (80, 110, 160, 255)
    for x in range(s(10), W - s(10), dash + gap):
        d.line((x, inset, min(x + dash, W - s(10)), inset), fill=color, width=s(1.3))
        d.line((x, H - 1 - inset, min(x + dash, W - s(10)), H - 1 - inset), fill=color, width=s(1.3))
    for y in range(s(10), H - s(10), dash + gap):
        d.line((inset, y, inset, min(y + dash, H - s(10))), fill=color, width=s(1.3))
        d.line((W - 1 - inset, y, W - 1 - inset, min(y + dash, H - s(10))), fill=color, width=s(1.3))
    for box, start in (((0, 0, s(16), s(16)), 180), ((W - s(17), 0, W - 1, s(16)), 270),
                       ((W - s(17), H - s(17), W - 1, H - 1), 0), ((0, H - s(17), s(16), H - 1), 90)):
        d.arc(box, start, start + 90, fill=color, width=s(1.3))
    return im


def draw_server(color):
    im = icon()
    d = ImageDraw.Draw(im)
    for y in (1.5, 6, 10.5):
        d.rounded_rectangle((s(1.5), s(y), s(14.5), s(y + 3.8)), s(1), outline=color, width=s(1.3))
        d.ellipse((s(11), s(y + 1.2), s(12.4), s(y + 2.6)), fill=color)
    return im


def draw_signal(color, bars=4):
    im = icon()
    d = ImageDraw.Draw(im)
    for i in range(4):
        x, top = 1.5 + i * 3.6, 12.5 - i * 3.2
        fill = color if i < bars else (60, 80, 110, 255)
        d.rounded_rectangle((s(x), s(top), s(x + 2.4), s(14.5)), s(0.6), fill=fill)
    return im


def draw_gender(color):
    im = icon()
    d = ImageDraw.Draw(im)
    d.ellipse((s(2), s(4), s(10), s(12)), outline=color, width=s(1.6))
    d.line((s(6), s(12), s(6), s(15.5)), fill=color, width=s(1.6))
    d.line((s(4), s(14), s(8), s(14)), fill=color, width=s(1.6))
    d.line((s(9), s(5), s(14), s(0.8)), fill=color, width=s(1.6))
    d.line((s(10.5), s(0.8), s(14), s(0.8), s(14), s(4.3)), fill=color, width=s(1.6))
    return im


def draw_palette(color):
    im = icon()
    d = ImageDraw.Draw(im)
    d.ellipse((s(1), s(1.5), s(15), s(14.5)), fill=color)
    d.ellipse((s(8.5), s(8.5), s(12.5), s(12.5)), fill=(0, 0, 0, 0))
    for (x, y), c in (((4.5, 5), (232, 72, 72, 255)), ((7.6, 3.4), (255, 214, 64, 255)),
                      ((10.8, 5), (80, 200, 120, 255)), ((4.2, 8.6), (80, 150, 255, 255))):
        d.ellipse((s(x - 1.3), s(y - 1.3), s(x + 1.3), s(y + 1.3)), fill=c)
    return im


def draw_hair(color):
    im = icon()
    d = ImageDraw.Draw(im)
    d.chord((s(2), s(2), s(14), s(15)), 180, 360, fill=color)
    d.polygon(((s(2), s(8.5)), (s(14), s(8.5)), (s(13), s(12)), (s(10.5), s(9.5)), (s(8), s(12)),
               (s(5.5), s(9.5)), (s(3), s(12))), fill=color)
    return im


def draw_shirt(color):
    im = icon()
    d = ImageDraw.Draw(im)
    d.polygon(((s(5.5), s(2)), (s(10.5), s(2)), (s(15), s(5)), (s(13), s(8)), (s(11.5), s(7)), (s(11.5), s(14.5)),
               (s(4.5), s(14.5)), (s(4.5), s(7)), (s(3), s(8)), (s(1), s(5))), fill=color)
    d.chord((s(6), s(0), s(10), s(4)), 0, 180, fill=(0, 0, 0, 0))
    return im


def draw_pants(color):
    im = icon()
    d = ImageDraw.Draw(im)
    d.polygon(((s(3.5), s(1.5)), (s(12.5), s(1.5)), (s(13.5), s(14.5)), (s(9.5), s(14.5)), (s(8), s(6.5)),
               (s(6.5), s(14.5)), (s(2.5), s(14.5))), fill=color)
    return im


def draw_shoe(color):
    im = icon()
    d = ImageDraw.Draw(im)
    d.polygon(((s(2), s(3)), (s(7), s(3)), (s(7.5), s(7.5)), (s(13), s(9)), (s(15), s(11)), (s(15), s(13.5)),
               (s(1.5), s(13.5))), fill=color)
    d.line((s(1.5), s(11.6), s(15), s(11.6)), fill=(14, 22, 40, 255), width=s(1))
    return im


def draw_more(color, size=18):
    im = icon(size)
    d = ImageDraw.Draw(im)
    d.rounded_rectangle((s(0.5), s(0.5), s(size - 0.5), s(size - 0.5)), s(3), fill=(16, 26, 46, 235),
                        outline=(90, 130, 190, 255), width=s(1))
    c = s(size / 2)
    for dx in (-4, 0, 4):
        d.ellipse((c + s(dx) - s(1.2), c - s(1.2), c + s(dx) + s(1.2), c + s(1.2)), fill=color)
    return im


def draw_arrow(color, left, size=30):
    im = icon(size)
    d = ImageDraw.Draw(im)
    d.rounded_rectangle((s(0.5), s(0.5), s(size - 0.5), s(size - 0.5)), s(6), fill=(16, 26, 46, 230),
                        outline=(80, 120, 180, 255), width=s(1.2))
    c, k = s(size / 2), s(size * 0.16)
    if left:
        pts = (c + k * 0.6, c - k), (c - k * 0.6, c), (c + k * 0.6, c + k)
    else:
        pts = (c - k * 0.6, c - k), (c + k * 0.6, c), (c - k * 0.6, c + k)
    d.line(pts, fill=color, width=s(2.2), joint='curve')
    return im


def draw_chevron(color, size=12):
    im = icon(size)
    d = ImageDraw.Draw(im)
    d.line((s(2), s(4), s(size / 2), s(8.5), s(size - 2), s(4)), fill=color, width=s(1.8), joint='curve')
    return im


def draw_dot(on, size=8):
    im = icon(size)
    d = ImageDraw.Draw(im)
    if on:
        d.ellipse((s(0.5), s(0.5), s(size - 0.5), s(size - 0.5)), fill=(110, 210, 255, 255))
    else:
        d.ellipse((s(1), s(1), s(size - 1), s(size - 1)), outline=(90, 120, 170, 255), width=s(1.2))
    return im


def draw_stage(w=296, h=200):
    """The outfit preview backdrop of the create character window: spotlight and floor ring."""
    im = glow_frame(w, h, 10, (8, 14, 28, 245), EDGE, None, 0)
    W, H = im.width, im.height
    inside = rounded_mask(W, H, s(10), s(1.5))
    light = Image.new('RGBA', (W, H), (120, 200, 255, 0))
    m = Image.new('L', (W, H), 0)
    ImageDraw.Draw(m).polygon(((W * 0.44, 0), (W * 0.56, 0), (W * 0.72, H * 0.86), (W * 0.28, H * 0.86)), fill=46)
    m = m.filter(ImageFilter.GaussianBlur(s(10)))
    light.putalpha(Image.composite(m, Image.new('L', (W, H), 0), inside))
    im.alpha_composite(light)
    cx, cy, rx, ry = W / 2, H * 0.82, W * 0.26, H * 0.075
    ring = Image.new('RGBA', (W, H), GLOW + (0,))
    m = Image.new('L', (W, H), 0)
    ImageDraw.Draw(m).ellipse((cx - rx, cy - ry, cx + rx, cy + ry), outline=255, width=s(3))
    ImageDraw.Draw(m).ellipse((cx - rx * 0.7, cy - ry * 0.7, cx + rx * 0.7, cy + ry * 0.7), outline=150, width=s(2))
    ring.putalpha(Image.composite(m.filter(ImageFilter.GaussianBlur(s(2))), Image.new('L', (W, H), 0), inside))
    im.alpha_composite(ring)
    floor = Image.new('RGBA', (W, H), GLOW + (0,))
    m = Image.new('L', (W, H), 0)
    ImageDraw.Draw(m).ellipse((cx - rx, cy - ry, cx + rx, cy + ry), fill=70)
    floor.putalpha(m.filter(ImageFilter.GaussianBlur(s(6))))
    im.alpha_composite(floor)
    return im


def main():
    out = Path(sys.argv[1])
    out.mkdir(parents=True, exist_ok=True)

    # frames (border = radius + glow, see the otui image-border values)
    save(glow_frame(64, 64, 12, NAVY, EDGE, GLOW, 8), out, 'panel')  # border 22
    save(glow_frame(32, 32, 6, FIELD, (44, 70, 112, 255), None, 0), out, 'field')  # border 8
    save(glow_frame(32, 32, 6, FIELD, (90, 160, 240, 255), None, 0), out, 'field_focus')
    save(glow_frame(40, 40, 8, (18, 30, 52, 235), (46, 74, 118, 255), None, 0), out, 'card')  # border 10
    card = canvas(40, 40)
    g = vertical_gradient(card.width, card.height, CARD_GREEN[0], CARD_GREEN[1])
    g.putalpha(rounded_mask(card.width, card.height, s(8)))
    card.alpha_composite(g)
    ImageDraw.Draw(card).rounded_rectangle((0, 0, card.width - 1, card.height - 1), s(8), outline=(110, 240, 170, 255),
                                           width=s(1.6))
    save(card, out, 'card_selected')
    save(draw_card_create(), out, 'card_create')  # border 12
    save(brighten(draw_card_create(), 1.4), out, 'card_create_hover')
    save(glow_frame(40, 40, 8, (12, 20, 38, 210), (40, 64, 104, 255), None, 0), out, 'inner')  # border 10

    # buttons (border 8)
    for name, im in (('button_yellow', gradient_button(48, 32, 7, YELLOW, (255, 236, 150, 255))),
                     ('button_green', gradient_button(48, 32, 7, GREEN, (150, 255, 190, 255))),
                     ('button_blue', outline_button(48, 32, 7, (70, 140, 230, 255), (22, 44, 84, 235))),
                     ('button_red', outline_button(48, 32, 7, (232, 92, 92, 255), (62, 22, 30, 235))),
                     ('button_gold', outline_button(48, 32, 7, (226, 178, 62, 255), (40, 32, 14, 230)))):
        save(im, out, name)
        save(brighten(im, 1.15), out, name + '_hover')
        save(brighten(im, 0.85), out, name + '_pressed')

    # icons
    save(draw_user(MUTED), out, 'icon_user')
    save(draw_lock(MUTED), out, 'icon_lock')
    eye = canvas(18, 36)
    eye.alpha_composite(draw_eye(MUTED, False), (0, 0))
    eye.alpha_composite(draw_eye(WHITE, True), (0, s(18)))
    save(eye, out, 'icon_eye')  # clip 0 0 18 18 shown, 0 18 18 18 hidden
    check = canvas(16, 32)
    check.alpha_composite(draw_check(MUTED, False), (0, 0))
    check.alpha_composite(draw_check(MUTED, True), (0, s(16)))
    save(check, out, 'checkbox')  # clip 0 0 16 16 off, 0 16 16 16 on
    save(draw_gear(WHITE), out, 'icon_settings')
    save(draw_news(WHITE), out, 'icon_news')
    save(draw_globe(WHITE), out, 'icon_website')
    save(draw_male((96, 170, 255, 255)), out, 'icon_male')
    save(draw_female((255, 120, 180, 255)), out, 'icon_female')
    save(draw_star((255, 214, 64, 255)), out, 'icon_level')
    save(draw_pin((120, 200, 255, 255)), out, 'icon_location')
    save(draw_clock((120, 200, 255, 255)), out, 'icon_playtime')
    save(draw_calendar((120, 200, 255, 255)), out, 'icon_lastlogin')
    save(draw_plus(WHITE), out, 'icon_create')
    save(draw_close(WHITE), out, 'icon_close')
    save(draw_trash((255, 120, 120, 255)), out, 'icon_delete')
    save(draw_pokeball(16), out, 'icon_pokeball')
    save(draw_pokeball(14, top=(255, 255, 255, 255), line=(28, 110, 60, 255), bottom=(255, 255, 255, 255)), out,
         'icon_play')
    save(draw_pokeball(18, top=(40, 30, 10, 255), line=(255, 214, 64, 255), bottom=(40, 30, 10, 255)), out,
         'icon_login')
    save(draw_badge(), out, 'badge')
    save(draw_party_slot(), out, 'party_slot')
    save(draw_party_slot(30), out, 'party_slot_small')
    save(draw_portrait(), out, 'portrait')  # border 13

    # create character
    accent = (120, 200, 255, 255)
    save(draw_stage(), out, 'stage')
    save(glow_frame(40, 48, 7, (14, 24, 44, 235), (46, 74, 118, 255), None, 0), out, 'thumb')  # border 9
    save(glow_frame(40, 48, 7, (20, 44, 70, 245), (110, 210, 255, 255), None, 0), out, 'thumb_selected')
    for name, left in (('arrow_left', True), ('arrow_right', False)):
        save(draw_arrow(WHITE, left), out, name)
        save(brighten(draw_arrow(WHITE, left), 1.3), out, name + '_hover')
    save(draw_chevron(MUTED), out, 'icon_chevron')
    save(draw_dot(False), out, 'dot')
    save(draw_dot(True), out, 'dot_on')
    save(draw_more(WHITE), out, 'swatch_more')
    save(brighten(draw_more(WHITE), 1.3), out, 'swatch_more_hover')
    save(draw_server(accent), out, 'icon_server')
    save(draw_signal((80, 220, 120, 255)), out, 'icon_signal')
    save(draw_gender(accent), out, 'icon_gender')
    save(draw_palette(accent), out, 'icon_palette')
    save(draw_hair(accent), out, 'icon_hair')
    save(draw_shirt(accent), out, 'icon_shirt')
    save(draw_pants(accent), out, 'icon_pants')
    save(draw_shoe(accent), out, 'icon_shoes')
    save(draw_eye(accent, False), out, 'icon_preview')


if __name__ == '__main__':
    main()
