#!/usr/bin/env python3
"""Draws the legendary effects: the signs each species leaves in its area, takeoff and landing,
meteors and Mew's reveal (docs/upcoming-features.md, legendary revamp).

    scripts/art/legendary_fx.py [<data dir>] [--preview <dir>]

Writes <data dir>/images/effects/legendary_<name>/<frame>.png (data dir defaults to
core/client-legacy/data), the frame folders things.otml image-frames plays. With --preview it
also writes, into <dir>:
    legendary_fx.gif/.png   every effect on a fitting tile, 3x
    legendary_flight.gif    Articuno flying over grass with its ground shadow, Lugia's shape under water
The flight shadow is not art: the client draws the creature's own sprite dark and see-through on
the ground, the way flight_shadow() does here.
"""
import math
import os
import random
import sys

from PIL import Image, ImageChops, ImageDraw, ImageFilter

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
S = 8

GOLD = (255, 214, 80)
YELLOW = (255, 236, 90)
WHITE = (255, 255, 255)
ICE = (190, 236, 255)
FIRE = (255, 120, 30)
EMBER = (255, 190, 60)
PINK = (255, 140, 210)
GREEN = (120, 240, 120)
PURPLE = (190, 90, 255)
TEAL = (60, 240, 220)
STEEL = (210, 220, 235)
DUST = (214, 190, 146)


def canvas(size):
    return Image.new('RGBA', (size * S, size * S), (0, 0, 0, 0))


def shrink(im, size):
    return im.resize((size, size), Image.LANCZOS)


def p(v):
    return v * S


def rgba(c, a):
    return tuple(c[:3]) + (max(0, min(255, int(a))),)


def glow(im, radius, strength=1.0):
    """The image with a soft halo of its own colours."""
    halo = im.filter(ImageFilter.GaussianBlur(p(radius)))
    if strength != 1.0:
        halo.putalpha(halo.getchannel('A').point(lambda v: min(255, int(v * strength))))
    out = halo
    out.alpha_composite(im)
    return out


def dot(d, x, y, r, c, a=255):
    d.ellipse((p(x - r), p(y - r), p(x + r), p(y + r)), fill=rgba(c, a))


def star(d, x, y, r, c, a=255, thin=0.22):
    """A four-point sparkle."""
    pts = []
    for k in range(8):
        ang = k * math.pi / 4
        rr = r if k % 2 == 0 else r * thin
        pts.append((p(x + math.cos(ang) * rr), p(y + math.sin(ang) * rr)))
    d.polygon(pts, fill=rgba(c, a))
    dot(d, x, y, r * 0.18, WHITE, a)


def five_star(d, x, y, r, c, a=255, rot=0.0):
    pts = []
    for k in range(10):
        ang = rot - math.pi / 2 + k * math.pi / 5
        rr = r if k % 2 == 0 else r * 0.45
        pts.append((p(x + math.cos(ang) * rr), p(y + math.sin(ang) * rr)))
    d.polygon(pts, fill=rgba(c, a))


def snowflake(d, x, y, r, a=255, rot=0.0):
    for k in range(3):
        ang = rot + k * math.pi / 3
        dx, dy = math.cos(ang) * r, math.sin(ang) * r
        d.line((p(x - dx), p(y - dy), p(x + dx), p(y + dy)), fill=rgba(WHITE, a), width=max(1, int(p(0.45))))
    dot(d, x, y, r * 0.3, ICE, a)


def bolt(d, x0, y0, x1, y1, rng, c, width, a=255, jag=2.0, steps=6):
    pts = [(x0, y0)]
    for k in range(1, steps):
        t = k / steps
        nx = x0 + (x1 - x0) * t + rng.uniform(-jag, jag)
        ny = y0 + (y1 - y0) * t + rng.uniform(-jag * 0.4, jag * 0.4)
        pts.append((nx, ny))
    pts.append((x1, y1))
    d.line([(p(a_), p(b_)) for a_, b_ in pts], fill=rgba(c, a), width=int(p(width)), joint='curve')
    d.line([(p(a_), p(b_)) for a_, b_ in pts], fill=rgba(WHITE, a), width=max(1, int(p(width * 0.4))))


def feather(size, c, edge, ang, scale=1.0):
    """A feather on its own layer, centred, rotated by ang degrees."""
    im = canvas(size)
    d = ImageDraw.Draw(im)
    cx, cy = size / 2, size / 2
    L, W = 7.0 * scale, 2.2 * scale
    d.ellipse((p(cx - W), p(cy - L), p(cx + W), p(cy + L)), fill=rgba(c, 255), outline=rgba(edge, 255), width=int(p(0.5)))
    for k in range(-5, 6):
        y = cy + k * L / 6
        d.line((p(cx), p(y), p(cx + W * 0.9), p(y - 1.2 * scale)), fill=rgba(edge, 160), width=int(p(0.3)))
        d.line((p(cx), p(y), p(cx - W * 0.9), p(y - 1.2 * scale)), fill=rgba(edge, 160), width=int(p(0.3)))
    d.line((p(cx), p(cy - L), p(cx), p(cy + L + 1.5 * scale)), fill=rgba(edge, 255), width=int(p(0.45)))
    return im.rotate(ang, resample=Image.BICUBIC, center=(p(cx), p(cy)))


def paste_at(im, layer, x, y, size):
    """layer (a canvas of size) centred on (x, y) of im."""
    im.alpha_composite(layer, (int(p(x - size / 2)), int(p(y - size / 2))))


def ground_ring(d, cx, cy, r, c, a, width):
    d.ellipse((p(cx - r), p(cy - r * 0.5), p(cx + r), p(cy + r * 0.5)), outline=rgba(c, a), width=int(p(width)))


def puff(d, x, y, r, c, a):
    dot(d, x, y, r, c, a)
    dot(d, x - r * 0.6, y + r * 0.2, r * 0.7, c, a)
    dot(d, x + r * 0.6, y + r * 0.25, r * 0.65, c, a)


def wave(t):
    return 0.5 - 0.5 * math.cos(2 * math.pi * t)


# Each effect: fn(t, f, n) -> canvas at S, with t = f / n. Loops have their last frame lead into
# the first; bursts play once.

def raikou_sparks(t, f, n, size=32):
    im = canvas(size)
    d = ImageDraw.Draw(im)
    for k in range(4):
        life = (f - k * 4) % n
        if life > 3:
            continue
        rng = random.Random((f - life) * 7 + k * 31)
        x, y = rng.uniform(9, 23), rng.uniform(12, 25)
        a = 255 - life * 60
        bolt(d, x - 7, y - 4, x + 7, y + 3, rng, (60, 40, 0), 2.6, a * 0.6, jag=3, steps=5)
        rng = random.Random((f - life) * 7 + k * 31)
        rng.uniform(9, 23), rng.uniform(12, 25)
        bolt(d, x - 7, y - 4, x + 7, y + 3, rng, YELLOW, 1.6, a, jag=3, steps=5)
        star(d, x + 7, y + 3, 2.2, YELLOW, a)
    return glow(im, 2.0, 1.6)


def entei_scorch(t, f, n, size=32):
    im = canvas(size)
    d = ImageDraw.Draw(im)
    rng = random.Random(5)
    for _ in range(7):
        x, y, r = rng.uniform(10, 22), rng.uniform(19, 25), rng.uniform(2.5, 5)
        d.ellipse((p(x - r), p(y - r * 0.5), p(x + r), p(y + r * 0.5)), fill=(30, 18, 12, 120))
    im = im.filter(ImageFilter.GaussianBlur(p(0.8)))
    d = ImageDraw.Draw(im)
    pulse = 120 + 100 * wave(t)
    cracks = [((16, 22), (11, 20)), ((16, 22), (21, 19.5)), ((16, 22), (19, 25)), ((11, 20), (8.5, 21.5))]
    hot = canvas(size)
    hd = ImageDraw.Draw(hot)
    for a_, b_ in cracks:
        hd.line((p(a_[0]), p(a_[1]), p(b_[0]), p(b_[1])), fill=rgba(FIRE, pulse), width=int(p(0.8)))
    im.alpha_composite(glow(hot, 1.0, 1.2))
    for k in range(5):
        u = (t + k / 5) % 1
        x = 10 + k * 3 + math.sin(u * 6 + k) * 1.5
        y = 22 - u * 18
        dot(d, x, y, 1.3 * (1 - u) + 0.5, EMBER, 255 * (1 - u))
    for k in range(3):
        u = (t + k / 3) % 1
        y = 18 - u * 14
        pts = [(p(9 + j * 2), p(y + math.sin(j + u * 9) * 0.8)) for j in range(8)]
        d.line(pts, fill=(255, 230, 200, int(70 * math.sin(math.pi * u))), width=int(p(0.6)))
    return im


def suicune_mist(t, f, n, size=32):
    im = canvas(size)
    d = ImageDraw.Draw(im)
    for k in range(4):
        u = (t + k / 4) % 1
        x = 4 + u * 24
        y = 15 + k * 3 + math.sin(u * 2 * math.pi + k) * 1.2
        a = 210 * math.sin(math.pi * u)
        dot(d, x, y, 5.5, (235, 250, 255), a)
        dot(d, x + 4, y + 0.5, 4.2, (200, 235, 255), a * 0.9)
        dot(d, x - 4, y + 1, 3.6, (220, 245, 255), a * 0.8)
    im = im.filter(ImageFilter.GaussianBlur(p(1.3)))
    d = ImageDraw.Draw(im)
    tw = wave(t * 2)
    star(d, 21, 12, 1.5 + 2.5 * tw, (160, 240, 255), 140 + 115 * tw)
    return im


def articuno_frost(t, f, n, size=32):
    im = canvas(size)
    d = ImageDraw.Draw(im)
    for x, y, r in ((9, 25, 2.4), (14, 27, 1.8), (22, 25.5, 2.2)):
        d.polygon([(p(x - r), p(y)), (p(x), p(y - r * 0.9)), (p(x + r), p(y)), (p(x), p(y + r * 0.5))],
                  fill=(210, 245, 255, 170), outline=(255, 255, 255, 220))
    for k in range(5):
        u = (t + k / 5) % 1
        x = 4 + k * 6 + math.sin(u * 2 * math.pi + k) * 1.5
        y = -2 + u * 28
        snowflake(d, x, y, 2.0, 255 * min(1, 4 * (1 - u)), rot=u * 3)
    u = t
    fx, fy = 16 + math.sin(u * 2 * math.pi) * 6, 4 + u * 18
    im.alpha_composite(feather(size, (150, 210, 255), (60, 120, 210), math.sin(u * 2 * math.pi) * 40 + 30, 1.0),
                       (int(p(fx - size / 2)), int(p(fy - size / 2))))
    return glow(im, 0.8, 0.8)


def zapdos_bolt(t, f, n, size=32):
    im = canvas(size)
    d = ImageDraw.Draw(im)
    rng = random.Random(11)
    if 1 <= f <= 4:
        a = (255, 255, 220, 160)[f - 1]
        bolt(d, 20, -2, 15, 25, rng, YELLOW, 1.6, a, jag=3, steps=7)
        ground_ring(d, 15, 25, 4 + f, YELLOW, a * 0.7, 0.7)
    if f >= 2:
        fade = max(0.0, 1 - (f - 2) / (n - 2))
        for k in range(4):
            rk = random.Random(f * 13 + k)
            x = 15 + rk.uniform(-6, 6)
            y = 25 + rk.uniform(-2, 2)
            if rk.random() < 0.6:
                bolt(d, x - 1.5, y, x + 1.5, y - 1, rk, YELLOW, 0.6, 255 * fade, jag=1, steps=3)
    out = glow(im, 2.0, 1.6)
    if f in (1, 2):
        flash = canvas(size)
        ImageDraw.Draw(flash).ellipse((p(6), p(18), p(26), p(32)), fill=(255, 250, 200, 90 if f == 1 else 45))
        out = Image.alpha_composite(flash.filter(ImageFilter.GaussianBlur(p(3))), out)
    return out


def moltres_feather(t, f, n, size=32):
    im = canvas(size)
    d = ImageDraw.Draw(im)
    fx, fy = 16 + math.sin(t * 2 * math.pi) * 6, 4 + t * 18
    for k in range(6):
        u = (t - k * 0.03) % 1
        x, y = 16 + math.sin(u * 2 * math.pi) * 6, 4 + u * 18 - 2
        dot(d, x + random.Random(k + f).uniform(-1, 1), y, 0.8 - k * 0.1, EMBER, 220 - k * 35)
    fe = feather(size, (255, 150, 40), (220, 50, 20), math.sin(t * 2 * math.pi) * 40 - 20, 1.05)
    flame = fe.filter(ImageFilter.GaussianBlur(p(1.2)))
    flame = ImageChops.multiply(flame, Image.new('RGBA', flame.size, (255, 90, 20, 255)))
    paste_at(im, flame, fx, fy - 1, size)
    paste_at(im, fe, fx, fy, size)
    return glow(im, 1.2, 1.0)


def hooh_rainbow(t, f, n, size=32):
    im = canvas(size)
    d = ImageDraw.Draw(im)
    colors = [(255, 70, 70), (255, 160, 50), (255, 230, 70), (90, 220, 90), (80, 160, 255), (170, 100, 255)]
    a = 60 + 70 * wave(t)
    for k, c in enumerate(colors):
        r = 13 - k * 1.1
        d.arc((p(16 - r), p(24 - r), p(16 + r), p(24 + r)), 180, 360, fill=rgba(c, a), width=int(p(1.1)))
    im = im.filter(ImageFilter.GaussianBlur(p(0.4)))
    d = ImageDraw.Draw(im)
    for k in range(6):
        u = (t * 2 + k / 6) % 1
        rk = random.Random(k * 17 + int(t * 2 + k / 6))
        x, y = rk.uniform(5, 27), rk.uniform(6, 26)
        tw = math.sin(math.pi * u)
        star(d, x, y, 0.6 + 2.0 * tw, GOLD, 255 * tw)
    return glow(im, 1.0, 1.0)


def water_ripple(t, f, n, size=32):
    im = canvas(size)
    d = ImageDraw.Draw(im)
    for k in range(3):
        u = (t + k / 3) % 1
        ground_ring(d, 16, 18, 2 + u * 13, WHITE, 200 * (1 - u), 0.9)
    return im


def groudon_crack(t, f, n, size=64):
    im = canvas(size)
    d = ImageDraw.Draw(im)
    rng = random.Random(3)
    grow = min(1.0, t * 2.2)
    branches = []
    for k in range(6):
        ang = k * math.pi / 3 + rng.uniform(-0.3, 0.3)
        pts, x, y = [(32, 40)], 32, 40
        for j in range(5):
            ang += rng.uniform(-0.5, 0.5)
            x += math.cos(ang) * 4.2
            y += math.sin(ang) * 2.1
            pts.append((x, y))
        branches.append(pts)
    keep = max(2, int(round(grow * 6)))
    for pts in branches:
        seg = pts[:keep]
        d.line([(p(x), p(y)) for x, y in seg], fill=(40, 22, 14, 230), width=int(p(1.8)))
    hot = canvas(size)
    hd = ImageDraw.Draw(hot)
    heat = 170 + 85 * wave(t * 3)
    for pts in branches:
        hd.line([(p(x), p(y)) for x, y in pts[:keep]], fill=rgba((255, 110, 20), heat), width=int(p(0.8)))
    im.alpha_composite(glow(hot, 1.6, 1.5))
    d = ImageDraw.Draw(im)
    if t < 0.6:
        for k in range(6):
            rk = random.Random(k)
            u = t / 0.6
            ang = rk.uniform(0, 2 * math.pi)
            x = 32 + math.cos(ang) * (4 + u * 18)
            y = 40 + math.sin(ang) * (2 + u * 8) - math.sin(math.pi * u) * 6
            dot(d, x, y, 1.0, (120, 90, 60), 255 * (1 - u))
            puff(d, 32 + math.cos(ang) * u * 14, 41 + math.sin(ang) * u * 6, 2.5 + u * 2, DUST, 110 * (1 - u))
    return im


def rayquaza_wind(t, f, n, size=32):
    im = canvas(size)
    d = ImageDraw.Draw(im)
    for k in range(3):
        u = (t + k / 3) % 1
        y = 9 + k * 6
        x0 = -10 + u * 40
        a = 200 * math.sin(math.pi * u)
        a = 255 * math.sin(math.pi * u)
        d.arc((p(x0 - 12), p(y - 5), p(x0 + 12), p(y + 5)), 190, 350, fill=rgba((235, 255, 240), a), width=int(p(1.4)))
        d.arc((p(x0 - 1), p(y - 3.5), p(x0 + 7), p(y + 3.5)), 160, 470, fill=rgba((90, 220, 120), a), width=int(p(1.2)))
        dot(d, x0 - 10, y + 2, 1.0, (90, 220, 120), a)
    return glow(im, 1.0, 1.3)


def mewtwo_psychic(t, f, n, size=32):
    im = canvas(size)
    d = ImageDraw.Draw(im)
    for k in range(3):
        u = (t + k / 3) % 1
        r = 2 + u * 14
        d.ellipse((p(16 - r), p(18 - r * 0.6), p(16 + r), p(18 + r * 0.6)), outline=rgba(PURPLE, 255 * (1 - u)), width=int(p(1.3)))
    for k in range(3):
        ang = t * 2 * math.pi + k * 2 * math.pi / 3
        dot(d, 16 + math.cos(ang) * 8, 18 + math.sin(ang) * 4.5 - 3, 1.7, (235, 180, 255), 255)
    return glow(im, 1.4, 1.3)


def regirock_rocks(t, f, n, size=32):
    im = canvas(size)
    d = ImageDraw.Draw(im)
    for k in range(3):
        u = (t + k / 3) % 1
        x = 8 + k * 8
        if u < 0.55:
            y = -2 + (u / 0.55) ** 2 * 26
            r = 3.4 - k * 0.4
            d.polygon([(p(x - r), p(y)), (p(x), p(y - r)), (p(x + r), p(y - 0.2)), (p(x + 0.3), p(y + r))],
                      fill=(150, 112, 78, 255), outline=(60, 40, 28, 255), width=int(p(0.5)))
        else:
            v = (u - 0.55) / 0.45
            puff(d, x, 24, 2 + v * 3, DUST, 220 * (1 - v))
    return im


def regice_frost(t, f, n, size=32):
    im = canvas(size)
    d = ImageDraw.Draw(im)
    grow = 0.6 + 0.4 * wave(t)
    for k, (x, ang) in enumerate(((10, -20), (16, 0), (22, 15), (13, -8), (19, 8))):
        h = (10 - 1.5 * (k % 3)) * grow
        L = canvas(size)
        ld = ImageDraw.Draw(L)
        ld.polygon([(p(16 - 2), p(25)), (p(16), p(25 - h)), (p(16 + 2), p(25))], fill=(170, 225, 255, 235),
                   outline=(255, 255, 255, 255), width=int(p(0.4)))
        L = L.rotate(ang, resample=Image.BICUBIC, center=(p(16), p(24)))
        im.alpha_composite(L, (int(p(x - 16)), 0))
    d = ImageDraw.Draw(im)
    tw = wave(t * 2)
    star(d, 18, 15, 1 + 2 * tw, WHITE, 255 * tw)
    return glow(im, 0.9, 0.9)


def registeel_sparks(t, f, n, size=32):
    im = canvas(size)
    d = ImageDraw.Draw(im)
    for k in range(10):
        u = (t * 2 + k / 10) % 1
        rk = random.Random(k * 7 + int(t * 2 + k / 10) * 3)
        ang = rk.uniform(-2.6, -0.5)
        sp = rk.uniform(14, 20)
        x = 16 + math.cos(ang) * sp * u
        y = 22 + math.sin(ang) * sp * u + 14 * u * u
        x2 = 16 + math.cos(ang) * sp * (u - 0.25)
        y2 = 22 + math.sin(ang) * sp * (u - 0.25) + 14 * (u - 0.25) ** 2
        d.line((p(x2), p(y2), p(x), p(y)), fill=rgba(STEEL if k % 2 else (255, 236, 170), 255 * (1 - u * 0.7)), width=int(p(1.1)))
    tw = wave(t * 4)
    star(d, 16, 22, 2 + 2.5 * tw, WHITE, 255)
    return glow(im, 1.2, 1.4)


def sparkles(color, extra=None):
    def fn(t, f, n, size=32):
        im = canvas(size)
        d = ImageDraw.Draw(im)
        for k in range(5):
            u = (t * 2 + k / 5) % 1
            rk = random.Random(k * 29 + int(t * 2 + k / 5) * 5)
            x, y = rk.uniform(6, 26), rk.uniform(8, 26) - u * 3
            tw = math.sin(math.pi * u)
            star(d, x, y, 1.0 + 3.2 * tw, color, 255 * min(1, tw * 1.5))
        if extra:
            extra(im, t, size)
        return glow(im, 1.2, 1.5)
    return fn


def celebi_leaf(im, t, size):
    leaf = canvas(size)
    ld = ImageDraw.Draw(leaf)
    ld.ellipse((p(13), p(10.5), p(19), p(21.5)), fill=(110, 210, 90, 230), outline=(50, 140, 50, 255))
    ld.line((p(16), p(12), p(16), p(21)), fill=(50, 140, 50, 255), width=int(p(0.4)))
    leaf = leaf.rotate(math.sin(t * 2 * math.pi) * 50 + 30, resample=Image.BICUBIC, center=(p(16), p(16)))
    paste_at(im, leaf, 12 + math.sin(t * 2 * math.pi) * 5, 8 + t * 14, size)


def mew_bubble(im, t, size):
    d = ImageDraw.Draw(im)
    y = 26 - t * 18
    d.ellipse((p(18.5), p(y - 3), p(24.5), p(y + 3)), outline=rgba((255, 170, 225), 255 * math.sin(math.pi * t)), width=int(p(0.7)))
    dot(d, 20.3, y - 0.8, 0.5, WHITE, 220 * math.sin(math.pi * t))


def jirachi_star(t, f, n, size=64):
    im = canvas(size)
    d = ImageDraw.Draw(im)
    u = min(1.0, t / 0.6)
    x, y = 58 - u * 30, 4 + u * 40
    if t < 0.6:
        for k in range(14):
            v = k / 14
            tx, ty = x + v * 22, y - v * 30
            dot(d, tx, ty, 2.4 * (1 - v), GOLD, 200 * (1 - v))
        five_star(d, x, y, 3.4, (255, 245, 150), 255, rot=t * 8)
    else:
        v = (t - 0.6) / 0.4
        ground_ring(d, 28, 44, 3 + v * 16, GOLD, 220 * (1 - v), 1.0)
        for k in range(6):
            ang = k * math.pi / 3 + 0.3
            star(d, 28 + math.cos(ang) * v * 14, 44 + math.sin(ang) * v * 7 - math.sin(math.pi * v) * 8, 2.2 * (1 - v) + 0.4, GOLD, 255 * (1 - v))
        five_star(d, 28, 42, 3.0 * (1 - v) + 1, (255, 245, 150), 255 * (1 - v))
    return glow(im, 1.6, 1.4)


def takeoff(t, f, n, size=64):
    im = canvas(size)
    d = ImageDraw.Draw(im)
    ground_ring(d, 32, 44, 4 + t * 22, WHITE, 255 * (1 - t), 2.0)
    ground_ring(d, 32, 44, 2 + t * 14, DUST, 240 * (1 - t), 1.6)
    for k in range(8):
        ang = k * math.pi / 4 + 0.2
        puff(d, 32 + math.cos(ang) * (6 + t * 16), 44 + math.sin(ang) * (3 + t * 7), 2.5 + t * 3, DUST, 230 * (1 - t))
    for k in range(5):
        x = 22 + k * 5
        y0 = 40 - t * 34
        d.line((p(x), p(y0 + 8), p(x), p(y0)), fill=rgba(WHITE, 255 * (1 - t)), width=int(p(1.3)))
    return im.filter(ImageFilter.GaussianBlur(p(0.25)))


def landing(t, f, n, size=64):
    im = canvas(size)
    d = ImageDraw.Draw(im)
    if t < 0.3:
        v = t / 0.3
        for k in range(5):
            x = 22 + k * 5
            y0 = 6 + v * 30
            d.line((p(x), p(y0), p(x), p(y0 + 8)), fill=rgba(WHITE, 255), width=int(p(1.3)))
    else:
        v = (t - 0.3) / 0.7
        ground_ring(d, 32, 44, 3 + v * 24, DUST, 255 * (1 - v), 2.4)
        for k in range(10):
            ang = k * math.pi / 5 + 0.1
            puff(d, 32 + math.cos(ang) * (4 + v * 20), 44 + math.sin(ang) * (2 + v * 9), 2.8 + v * 3, DUST, 235 * (1 - v))
        for k in range(6):
            rk = random.Random(k + 40)
            ang = rk.uniform(math.pi * 1.1, math.pi * 1.9)
            dot(d, 32 + math.cos(ang) * v * 18, 44 - math.sin(math.pi * v) * 9 + math.sin(ang) * v * 4, 1.4, (110, 80, 55), 255 * (1 - v))
    return im.filter(ImageFilter.GaussianBlur(p(0.25)))


def deoxys_impact(t, f, n, size=64):
    im = canvas(size)
    d = ImageDraw.Draw(im)
    if t < 0.25:
        v = t / 0.25
        x, y = 60 - v * 28, -4 + v * 46
        for k in range(10):
            w = k / 10
            dot(d, x + w * 16, y - w * 26, 3.2 * (1 - w), (255, 140, 60), 230 * (1 - w))
        dot(d, x, y, 3.0, (255, 240, 200), 255)
        return glow(im, 2.0, 1.4)
    v = (t - 0.25) / 0.75
    d.ellipse((p(18), p(37), p(46), p(51)), fill=(120, 92, 66, 255))
    d.ellipse((p(20), p(38), p(44), p(50)), fill=(36, 24, 20, 235))
    d.ellipse((p(23), p(40), p(41), p(48)), fill=(60, 36, 50, 220))
    if v < 0.3:
        w = v / 0.3
        flash = canvas(size)
        ImageDraw.Draw(flash).ellipse((p(32 - 26 * w), p(44 - 13 * w), p(32 + 26 * w), p(44 + 13 * w)),
                                      fill=(255, 230, 180, int(200 * (1 - w))))
        im.alpha_composite(flash.filter(ImageFilter.GaussianBlur(p(2))))
    for k in range(8):
        rk = random.Random(k + 70)
        ang = rk.uniform(0, 2 * math.pi)
        w = min(1.0, v * 1.6)
        dot(d, 32 + math.cos(ang) * w * 22, 44 + math.sin(ang) * w * 8 - math.sin(math.pi * w) * 14, 1.0,
            (100, 72, 52), 255 * (1 - w))
    en = canvas(size)
    ed = ImageDraw.Draw(en)
    for k in range(6):
        u = (v * 2 + k / 6) % 1
        x = 24 + k * 3.2 + math.sin(u * 7 + k) * 2.5
        y = 44 - u * 26
        c = TEAL if k % 2 else (255, 110, 70)
        pts = [(p(x + math.sin(u * 9 + j) * 1.6), p(y - j * 2.2)) for j in range(4)]
        ed.line(pts, fill=rgba(c, 255 * math.sin(math.pi * u) * (0.5 + 0.5 * v)), width=int(p(1.5)))
    ed.ellipse((p(25), p(41), p(39), p(47)), fill=rgba(TEAL, 90 + 60 * wave(v * 3)))
    im.alpha_composite(glow(en, 1.4, 1.5))
    return im


def mew_reveal(t, f, n, size=64):
    im = canvas(size)
    d = ImageDraw.Draw(im)
    if t < 0.2:
        v = t / 0.2
        puff(d, 32, 36, 6 + v * 6, (235, 235, 245), 230)
        puff(d, 28, 30, 4 + v * 5, (250, 250, 255), 220)
        return glow(im, 1.0, 0.8)
    v = (t - 0.2) / 0.8
    d.ellipse((p(32 - 24 * v), p(36 - 24 * v), p(32 + 24 * v), p(36 + 24 * v)), outline=rgba(PINK, 230 * (1 - v)), width=int(p(1.4)))
    for k in range(10):
        ang = k * math.pi / 5 + v
        r = 4 + v * 20
        star(d, 32 + math.cos(ang) * r, 36 + math.sin(ang) * r, 2.8 * (1 - v) + 0.5, PINK if k % 2 else WHITE, 255 * (1 - v * 0.8))
    if v < 0.4:
        dot(d, 32, 36, 9 * (1 - v / 0.4), (255, 220, 245), 200 * (1 - v / 0.4))
    return glow(im, 1.4, 1.2)


# name: (fn, size, frames, preview tile)
EFFECTS = {
    'raikou_sparks': (raikou_sparks, 32, 16, 'grass'),
    'entei_scorch': (entei_scorch, 32, 16, 'dirt'),
    'suicune_mist': (suicune_mist, 32, 16, 'water'),
    'articuno_frost': (articuno_frost, 32, 16, 'grass'),
    'zapdos_bolt': (zapdos_bolt, 32, 12, 'grass'),
    'moltres_feather': (moltres_feather, 32, 16, 'dirt'),
    'hooh_rainbow': (hooh_rainbow, 32, 16, 'grass'),
    'water_ripple': (water_ripple, 32, 12, 'water'),
    'groudon_crack': (groudon_crack, 64, 16, 'dirt'),
    'rayquaza_wind': (rayquaza_wind, 32, 12, 'grass'),
    'mewtwo_psychic': (mewtwo_psychic, 32, 12, 'dirt'),
    'regirock_rocks': (regirock_rocks, 32, 12, 'dirt'),
    'regice_frost': (regice_frost, 32, 16, 'dirt'),
    'registeel_sparks': (registeel_sparks, 32, 12, 'dirt'),
    'mew_sparkles': (sparkles(PINK, mew_bubble), 32, 16, 'grass'),
    'celebi_sparkles': (sparkles(GREEN, celebi_leaf), 32, 16, 'grass'),
    'jirachi_star': (jirachi_star, 64, 16, 'grass'),
    'deoxys_impact': (deoxys_impact, 64, 16, 'dirt'),
    'takeoff': (takeoff, 64, 10, 'grass'),
    'landing': (landing, 64, 10, 'grass'),
    'mew_reveal': (mew_reveal, 64, 12, 'grass'),
}

LABELS = {
    'raikou_sparks': 'Raikou: sparks', 'entei_scorch': 'Entei: scorch, heat',
    'suicune_mist': 'Suicune: mist', 'articuno_frost': 'Articuno: snow, feather',
    'zapdos_bolt': 'Zapdos: lightning', 'moltres_feather': 'Moltres: fire feather',
    'hooh_rainbow': 'Ho-Oh: rainbow, gold', 'water_ripple': 'Lugia/Kyogre: wake',
    'groudon_crack': 'Groudon: quake crack', 'rayquaza_wind': 'Rayquaza: wind',
    'mewtwo_psychic': 'Mewtwo: psychic', 'regirock_rocks': 'Regirock: rocks',
    'regice_frost': 'Regice: frost', 'registeel_sparks': 'Registeel: metal',
    'mew_sparkles': 'Mew: pink sparkles', 'celebi_sparkles': 'Celebi: green, leaf',
    'jirachi_star': 'Jirachi: falling star', 'deoxys_impact': 'Deoxys: meteor impact',
    'takeoff': 'Takeoff', 'landing': 'Landing', 'mew_reveal': 'Mew: reveal',
}


def frames(name):
    fn, size, n, _ = EFFECTS[name]
    return [shrink(fn(f / n, f, n, size), size) for f in range(n)]


def write(data_dir):
    for name in EFFECTS:
        out = os.path.join(data_dir, 'images', 'effects', 'legendary_' + name)
        os.makedirs(out, exist_ok=True)
        for k, im in enumerate(frames(name)):
            im.save(os.path.join(out, '%d.png' % k), optimize=True)


# Previews: tiles and sprites from data.dat/data.spr (pulled from LFS).

TILES = {'grass': 4526, 'water': 4609, 'dirt': 351}


def things():
    sys.path.insert(0, os.path.join(ROOT, 'scripts', 'art'))
    sys.path.insert(0, os.path.join(ROOT, 'scripts', 'mapper'))
    import new_pokemon_art_preview
    return new_pokemon_art_preview.Things()


def field(th, kind, w, h):
    tile = th.item_frames(TILES[kind])[0]
    im = Image.new('RGBA', (32 * w, 32 * h))
    for y in range(h):
        for x in range(w):
            im.alpha_composite(tile, (32 * x, 32 * y))
    return im


def preview_sheet(th, out):
    zoom, cell, cols = 3, 64, 7
    names = list(EFFECTS)
    rows = (len(names) + cols - 1) // cols
    W, H = cols * (cell * zoom + 12) + 12, rows * (cell * zoom + 34) + 12
    all_frames = {n: frames(n) for n in names}
    grounds = {k: field(th, k, 2, 2) for k in TILES}
    sheet_frames = []
    for f in range(48):
        im = Image.new('RGBA', (W, H), (26, 30, 40, 255))
        d = ImageDraw.Draw(im)
        for k, name in enumerate(names):
            _, size, n, kind = EFFECTS[name]
            x, y = 12 + (k % cols) * (cell * zoom + 12), 12 + (k // cols) * (cell * zoom + 34)
            tile = grounds[kind].copy()
            fr = all_frames[name][(f // 2) % n]
            if size == 32:
                tile.alpha_composite(fr, (16, 16))
            else:
                tile.alpha_composite(fr, (0, 0))
            im.alpha_composite(tile.resize((cell * zoom, cell * zoom), Image.NEAREST), (x, y))
            d.text((x, y + cell * zoom + 6), LABELS[name], fill=(235, 235, 240))
        sheet_frames.append(im)
    sheet_frames[0].convert('RGB').save(os.path.join(out, 'legendary_fx.png'))
    pal = [f.convert('RGB').quantize(256, method=Image.Quantize.MEDIANCUT) for f in sheet_frames]
    pal[0].save(os.path.join(out, 'legendary_fx.gif'), save_all=True, append_images=pal[1:], duration=60, loop=0)


def flight_shadow(sprite, alpha=0.38, blur=1.2):
    """What the client draws on the ground under a flyer: its sprite, black and see-through."""
    a = sprite.getchannel('A').point(lambda v: int(v * alpha))
    sh = Image.new('RGBA', sprite.size, (8, 10, 20, 0))
    sh.putalpha(a)
    return sh.filter(ImageFilter.GaussianBlur(blur))


def preview_flight(th, out):
    zoom = 2
    W, H = 12, 7
    grass = field(th, 'grass', W, H)
    water = field(th, 'water', W, H)
    art = th.outfit_dirs(495)['E']
    lugia = th.outfit_dirs(1075)['E']
    snow = frames('articuno_frost')
    ripple = frames('water_ripple')
    out_frames = []
    n = 64
    for f in range(n):
        u = f / n
        top = grass.copy()
        x = int(-96 + u * (32 * W + 96))
        lift = 40 + int(4 * math.sin(u * 8 * math.pi))
        sx, sy = x + 26, 3 * 32 - 26
        sprite = art[(f // 3) % len(art)]
        for k in range(1, 4):
            tx = (sx + 48 - k * 48) // 32
            if 0 <= tx < W:
                top.alpha_composite(snow[(f + k * 3) % len(snow)], (tx * 32, 4 * 32))
        top.alpha_composite(flight_shadow(sprite), (sx, sy))
        top.alpha_composite(sprite, (x, 3 * 32 - 64 - lift))

        bottom = water.copy()
        lx = int(32 * W - u * (32 * W + 96))
        lsprite = lugia[(f // 3) % len(lugia)].transpose(Image.FLIP_LEFT_RIGHT)
        bottom.alpha_composite(flight_shadow(lsprite, 0.5, 2.0), (lx, 3 * 32 - 64))
        for k in range(1, 3):
            tx = (lx + 48 + k * 40) // 32
            if 0 <= tx < W:
                bottom.alpha_composite(ripple[(f + k * 4) % len(ripple)], (tx * 32, 3 * 32 - 16))

        im = Image.new('RGBA', (32 * W * zoom, 32 * H * 2 * zoom + 40), (26, 30, 40, 255))
        im.alpha_composite(top.resize((32 * W * zoom, 32 * H * zoom), Image.NEAREST), (0, 0))
        im.alpha_composite(bottom.resize((32 * W * zoom, 32 * H * zoom), Image.NEAREST), (0, 32 * H * zoom + 40))
        d = ImageDraw.Draw(im)
        d.text((8, 32 * H * zoom + 6), 'Top: Articuno flying over, its shadow on the ground and snow under its path.',
               fill=(235, 235, 240))
        d.text((8, 32 * H * zoom + 22), 'Bottom: Lugia travelling under the sea, only its dark shape and the wake.',
               fill=(235, 235, 240))
        out_frames.append(im)
    out_frames[0].convert('RGB').save(os.path.join(out, 'legendary_flight.png'))
    pal = [f.convert('RGB').quantize(256, method=Image.Quantize.MEDIANCUT) for f in out_frames]
    pal[0].save(os.path.join(out, 'legendary_flight.gif'), save_all=True, append_images=pal[1:], duration=70, loop=0)


def main(argv):
    preview = None
    if '--preview' in argv:
        i = argv.index('--preview')
        preview = argv[i + 1]
        argv = argv[:i] + argv[i + 2:]
    data_dir = argv[0] if argv else os.path.join(ROOT, 'core', 'client-legacy', 'data')
    write(data_dir)
    if preview:
        os.makedirs(preview, exist_ok=True)
        th = things()
        preview_sheet(th, preview)
        preview_flight(th, preview)


if __name__ == '__main__':
    main(sys.argv[1:])
