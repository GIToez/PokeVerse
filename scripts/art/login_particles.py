#!/usr/bin/env python3
"""Draws the login screen particle textures: a tumbling autumn leaf (APNG) and a firefly glow.

    python3 scripts/art/login_particles.py [out-dir]

The default out-dir is core/client-redemption/pokeverse-modern/data/particles.
"""
import math
import os
import sys

from PIL import Image

root = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
out = sys.argv[1] if len(sys.argv) > 1 else os.path.join(
    root, "core/client-redemption/pokeverse-modern/data/particles")

# white-ish leaf so the particle colours tint it; '#' body, '+' shade, '|' stem
LEAF = [
    "....##..",
    "...####.",
    "..###+##",
    ".###+###",
    ".##+####",
    "##+####.",
    "|+####..",
    "|.##....",
]
SHADES = {"#": (255, 255, 255, 255), "+": (200, 200, 200, 255), "|": (170, 170, 170, 255)}


def leaf_frame(squash):
    """The leaf flattened horizontally by squash (1 = face on, 0 = edge on, below 0 mirrored)."""
    size = 10
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    w = len(LEAF[0])
    for y, row in enumerate(LEAF):
        for x, ch in enumerate(row):
            if ch == ".":
                continue
            nx = round((x - (w - 1) / 2) * squash + (size - 1) / 2)
            img.putpixel((nx, y + 1), SHADES[ch])
    return img


def firefly():
    size = 16
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    c = (size - 1) / 2
    for y in range(size):
        for x in range(size):
            d = math.hypot(x - c, y - c) / c
            if d >= 1:
                continue
            a = (1 - d) ** 2.2
            if d < 0.22:
                a = 1
            img.putpixel((x, y), (255, 255, 255, round(255 * a)))
    return img


def main():
    os.makedirs(out, exist_ok=True)
    # a negative squash mirrors the leaf, so the loop reads as a full flip
    frames = [leaf_frame(s) for s in (1, 0.7, 0.3, -0.3, -0.7, -1, -0.7, -0.3, 0.3, 0.7)]
    frames[0].save(os.path.join(out, "leaf.png"), save_all=True, append_images=frames[1:],
                   duration=140, loop=0, disposal=1, blend=0)
    firefly().save(os.path.join(out, "firefly.png"))
    print("wrote", out)


if __name__ == "__main__":
    main()
