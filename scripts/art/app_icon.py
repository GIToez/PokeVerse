#!/usr/bin/env python3
"""Renders the PokeVerse app icon (a dusk-coloured ball with a crescent moon on its button).

    python3 scripts/art/app_icon.py [--preview out.png]

Writes the Windows .ico files, the window icon (clienticon.png) and the Android launcher icons.
Every size is rendered on its own (supersampled), with thicker lines at the small sizes so
16x16 and 24x24 stay readable.
"""
import argparse
import math
import os

from PIL import Image

root = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

OUTLINE = (26, 16, 48)
TOP_HI = (112, 64, 208)
TOP_LO = (232, 92, 156)
BOTTOM_HI = (246, 242, 252)
BOTTOM_LO = (196, 184, 226)
MOON = (255, 216, 96)
BUTTON = (250, 248, 255)
BG_HI = (58, 34, 104)
BG_LO = (150, 64, 120)

ICO_SIZES = [16, 24, 32, 48, 64, 128, 256]
ANDROID = {"mdpi": 48, "hdpi": 72, "xhdpi": 96, "xxhdpi": 144, "xxxhdpi": 192}
STARS = [(-0.42, -0.36, 0.035), (-0.12, -0.62, 0.025), (0.30, -0.50, 0.03)]


def lerp(a, b, t):
    return tuple(round(x + (y - x) * t) for x, y in zip(a, b))


def ball_pixel(u, v, s):
    """Colour at (u, v) in ball units (radius 1, y down) for an icon of s pixels, or None."""
    r = math.hypot(u, v)
    if r > 1:
        return None
    # line widths in ball units, at least about one output pixel
    px = 2.0 / (s * 0.94)
    line = max(0.09, 1.3 * px)
    band = max(0.085, 1.0 * px)
    if r > 1 - line:
        return OUTLINE

    # button
    br = math.hypot(u, v)
    ring_out, ring_in = 0.36, 0.36 - max(0.09, 1.2 * px)
    if br < ring_out:
        if br > ring_in:
            return OUTLINE
        if s >= 32:
            mr = ring_in * 0.62
            mc = (u + ring_in * 0.08, v)
            cut = (u - ring_in * 0.18, v - ring_in * 0.14)
            if math.hypot(*mc) < mr and math.hypot(*cut) > mr * 0.85:
                return MOON
        return BUTTON
    if abs(v) < band:
        return OUTLINE

    if v < 0:
        t = (v + 1) / 1.0
        col = lerp(TOP_HI, TOP_LO, max(0, min(1, t)) ** 1.2)
        if s >= 48:
            for sx, sy, sr in STARS:
                d = abs(u - sx) + abs(v - sy)
                if d < sr * 1.6:
                    col = lerp(col, (255, 250, 230), 0.9 if d < sr * 0.7 else 0.45)
        # soft highlight towards the top left
        hl = math.hypot((u + 0.38) / 0.42, (v + 0.52) / 0.24)
        if hl < 1 and s >= 24:
            col = lerp(col, (255, 255, 255), 0.35 * (1 - hl) ** 0.6)
        return col
    t = v / 1.0
    col = lerp(BOTTOM_HI, BOTTOM_LO, max(0, min(1, t)) ** 0.8)
    return col


def render_ball(s, scale=0.94, ss=4):
    """The ball alone on a transparent s x s canvas, diameter scale * s."""
    img = Image.new("RGBA", (s, s), (0, 0, 0, 0))
    px = img.load()
    rad = s * scale / 2
    c = s / 2
    for y in range(s):
        for x in range(s):
            acc = [0, 0, 0, 0]
            for sy in range(ss):
                for sx in range(ss):
                    u = (x + (sx + 0.5) / ss - c) / rad
                    v = (y + (sy + 0.5) / ss - c) / rad
                    col = ball_pixel(u, v, s * scale / 0.94)
                    if col:
                        acc[0] += col[0]
                        acc[1] += col[1]
                        acc[2] += col[2]
                        acc[3] += 1
            n = acc[3]
            if n:
                px[x, y] = (acc[0] // n, acc[1] // n, acc[2] // n, round(255 * n / (ss * ss)))
    return img


def background(s, round_shape):
    img = Image.new("RGBA", (s, s), (0, 0, 0, 0))
    px = img.load()
    ss = 3
    corner = s * 0.18
    for y in range(s):
        col = lerp(BG_HI, BG_LO, y / max(1, s - 1))
        for x in range(s):
            n = 0
            for sy in range(ss):
                for sx in range(ss):
                    fx, fy = x + (sx + 0.5) / ss, y + (sy + 0.5) / ss
                    if round_shape:
                        inside = math.hypot(fx - s / 2, fy - s / 2) <= s / 2
                    else:
                        dx = max(corner - fx, 0, fx - (s - corner))
                        dy = max(corner - fy, 0, fy - (s - corner))
                        inside = math.hypot(dx, dy) <= corner
                    n += inside
            if n:
                px[x, y] = col + (round(255 * n / (ss * ss)),)
    return img


def launcher(s, round_shape):
    img = background(s, round_shape)
    ball = render_ball(s, scale=0.66 if round_shape else 0.72)
    img.alpha_composite(ball)
    return img


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--preview")
    args = ap.parse_args()

    icons = {s: render_ball(s) for s in ICO_SIZES}
    for rel in ("core/client-redemption/cmake/icon/otcicon.ico", "core/client-redemption/src/otcicon.ico"):
        path = os.path.join(root, rel)
        big = icons[256]
        big.save(path, format="ICO", sizes=[(s, s) for s in ICO_SIZES],
                 append_images=[icons[s] for s in ICO_SIZES if s != 256])
        print("wrote", rel)

    for rel, s in (("core/client-legacy/data/images/clienticon.png", 128),
                   ("core/client-redemption/data/images/clienticon.png", 256)):
        icons.get(s, render_ball(s)).save(os.path.join(root, rel))
        print("wrote", rel)

    res = os.path.join(root, "core/client-redemption/android/app/src/main/res")
    for density, s in ANDROID.items():
        d = os.path.join(res, "mipmap-" + density)
        launcher(s, False).save(os.path.join(d, "ic_launcher.webp"), lossless=True)
        launcher(s, True).save(os.path.join(d, "ic_launcher_round.webp"), lossless=True)
    print("wrote android mipmaps")

    if args.preview:
        sizes = [16, 24, 32, 48, 64, 128, 256]
        w = sum(s * (4 if s <= 32 else 2 if s <= 64 else 1) + 16 for s in sizes) + 192 * 2 + 32
        sheet = Image.new("RGBA", (w, 300), (40, 40, 48, 255))
        x = 8
        for s in sizes:
            k = 4 if s <= 32 else 2 if s <= 64 else 1
            sheet.alpha_composite(icons[s].resize((s * k, s * k), Image.NEAREST), (x, 8))
            x += s * k + 16
        sheet.alpha_composite(launcher(192, False), (x, 8))
        sheet.alpha_composite(launcher(192, True), (x + 208, 8))
        sheet.save(args.preview)


if __name__ == "__main__":
    main()
