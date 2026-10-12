#!/usr/bin/env python3
"""Builds the animated login logo: scripts/art/login-logo.png with a glint sweeping the yellow letters.

    python3 scripts/art/login_logo.py [out.png]

The default output is core/client-redemption/pokeverse-modern/modules/client_background/images/logo.png.
"""
import os
import sys

from PIL import Image

here = os.path.dirname(os.path.abspath(__file__))
root = os.path.dirname(os.path.dirname(here))
out = sys.argv[1] if len(sys.argv) > 1 else os.path.join(
    root, "core/client-redemption/pokeverse-modern/modules/client_background/images/logo.png")

HOLD_MS = 3600
SWEEP_FRAMES = 12
SWEEP_MS = 45
BAND = 34  # glint width in pixels, measured along x
SLANT = 0.45  # x shift per pixel of y


def is_fill(p):
    r, g, b, a = p
    return a > 200 and r > 200 and g > 150 and b < 140


def main():
    logo = Image.open(os.path.join(here, "login-logo.png")).convert("RGBA")
    w, h = logo.size
    px = logo.load()
    fill = [[is_fill(px[x, y]) for y in range(h)] for x in range(w)]

    frames = [logo]
    durations = [HOLD_MS]
    span = w + BAND * 2 + h * SLANT
    for i in range(SWEEP_FRAMES):
        centre = -BAND - h * SLANT + span * (i + 0.5) / SWEEP_FRAMES
        frame = logo.copy()
        fp = frame.load()
        for y in range(h):
            row_centre = centre + y * SLANT
            for x in range(max(0, int(row_centre - BAND)), min(w, int(row_centre + BAND) + 1)):
                if not fill[x][y]:
                    continue
                k = 1 - abs(x - row_centre) / BAND
                if k <= 0:
                    continue
                k = min(1, k * 1.6) * 0.85
                r, g, b, a = fp[x, y]
                fp[x, y] = (round(r + (255 - r) * k), round(g + (255 - g) * k), round(b + (250 - b) * k), a)
        frames.append(frame)
        durations.append(SWEEP_MS)

    os.makedirs(os.path.dirname(out), exist_ok=True)
    frames[0].save(out, save_all=True, append_images=frames[1:], duration=durations, loop=0,
                   disposal=0, blend=0, optimize=True)
    print("wrote", out, os.path.getsize(out), "bytes")


if __name__ == "__main__":
    main()
