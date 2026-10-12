#!/usr/bin/env python3
"""Builds the animated login background (an APNG the client scales up without smoothing).

    scripts/art/login_scene.py [--preview out.gif] <base.png> <out.png>

<base.png> is the still scene (scripts/art/login-scene-base.png, 480x270). The animation is
added here: twinkling stars, shimmering water, flickering city windows and a sparkle sweep
on the river. The loop is FRAMES * FRAME_MS long and every effect repeats exactly within it.
"""
import argparse
import math
import random

from PIL import Image

W, H = 480, 270
FRAMES = 48
FRAME_MS = 100

# Regions of the base image (480x270)
SKY_MAX_Y = 105
WATER_Y = (163, 191)
WATER_SKIP = [(52, 152, 0, 999), (348, 999, 171, 999)]  # x0, x1, y0, y1: the trainer and the bush
CITY = (285, 480, 112, 166)


def in_water(x, y):
    if not (WATER_Y[0] <= y < WATER_Y[1]):
        return False
    return not any(x0 <= x < x1 and y0 <= y < y1 for x0, x1, y0, y1 in WATER_SKIP)


def lerp(a, b, t):
    return tuple(int(a[i] + (b[i] - a[i]) * t + 0.5) for i in range(3))


def sky_reference(base):
    """Average sky colour of each row, taken from the empty middle of the sky."""
    px = base.load()
    ref = []
    for y in range(H):
        cols = [px[x, y] for x in range(205, 275)]
        ref.append(tuple(sum(c[i] for c in cols) // len(cols) for i in range(3)))
    return ref


def is_sky(px, ref, x, y):
    c, r = px[x, y], ref[y]
    return sum(abs(c[i] - r[i]) for i in range(3)) < 28


def pick_stars(base, ref, rng):
    px = base.load()
    stars = []
    tries = 0
    while len(stars) < 34 and tries < 5000:
        tries += 1
        x, y = rng.randrange(4, W - 4), rng.randrange(3, SKY_MAX_Y)
        if 196 <= x <= 284 and y < 70:
            continue  # the logo sits here
        if all(is_sky(px, ref, x + dx, y + dy) for dx in (-2, 0, 2) for dy in (-2, 0, 2)):
            if all(abs(x - sx) + abs(y - sy) > 10 for sx, sy, *_ in stars):
                big = len(stars) < 5
                stars.append((x, y, rng.randrange(FRAMES), rng.choice((1, 2)), big))
    return stars


def pick_windows(base, rng):
    px = base.load()
    windows = []
    x0, x1, y0, y1 = CITY
    for y in range(y0, y1):
        for x in range(x0, min(x1, W)):
            r, g, b = px[x, y]
            if r > 190 and g > 120 and r - b > 40 and 0 < x < W - 1:
                # a lit window sits in a dark building; the bright sky at the horizon does not
                dark = sum(1 for dx in (-1, 0, 1) for dy in (-1, 0, 1)
                           if (dx or dy) and sum(px[x + dx, y + dy]) < 300)
                if dark < 5:
                    continue
                windows.append((x, y, rng.randrange(FRAMES), rng.random() < 0.25))
    return windows


def build(base):
    rng = random.Random(7)
    ref = sky_reference(base)
    stars = pick_stars(base, ref, rng)
    windows = pick_windows(base, rng)
    src = base.load()
    frames = []
    for f in range(FRAMES):
        t = f / FRAMES
        frame = base.copy()
        px = frame.load()

        # Water: each row sways one pixel left and right, the phase rolling down the river
        for y in range(*WATER_Y):
            shift = round(math.sin(2 * math.pi * (2 * t + y * 0.37)) * 1.1)
            if shift == 0:
                continue
            for x in range(W):
                if in_water(x, y) and in_water(x + shift, y) and 0 <= x + shift < W:
                    px[x, y] = src[x + shift, y]

        # A soft sparkle band drifting across the water
        band = (t * (W + 120)) - 60
        for y in range(WATER_Y[0] + 2, WATER_Y[1], 3):
            for x in range(int(band) - 24, int(band) + 24):
                if 0 <= x < W and in_water(x, y) and (x * 7 + y * 13 + f) % 11 == 0:
                    k = 1 - abs(x - band) / 24
                    px[x, y] = lerp(px[x, y], (255, 200, 235), 0.55 * k)

        # Stars: each one brightens and fades on its own phase
        for x, y, phase, speed, big in stars:
            a = (math.sin(2 * math.pi * (speed * t + phase / FRAMES)) + 1) / 2
            core = lerp(ref[y], (255, 248, 230), 0.35 + 0.65 * a)
            px[x, y] = core
            if big and a > 0.55:
                glow = lerp(ref[y], (255, 240, 220), (a - 0.55) * 1.4)
                for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                    px[x + dx, y + dy] = glow

        # City windows: a quarter of them switch off now and then
        for x, y, phase, flickers in windows:
            if flickers and ((f + phase) % FRAMES) < FRAMES // 6:
                px[x, y] = lerp(src[x, y], (70, 40, 90), 0.7)

        frames.append(frame)
    return frames


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("base")
    ap.add_argument("out")
    ap.add_argument("--preview", help="also write a GIF preview scaled x2")
    args = ap.parse_args()

    base = Image.open(args.base).convert("RGB")
    if base.size != (W, H):
        raise SystemExit("base must be %dx%d" % (W, H))
    frames = build(base)
    # One palette for every frame keeps the file small; sampled from frames spread over the loop
    sample = Image.new("RGB", (W, H * 4))
    for i in range(4):
        sample.paste(frames[i * FRAMES // 4], (0, H * i))
    palette = sample.quantize(colors=255, method=Image.FASTOCTREE, dither=Image.Dither.NONE)
    indexed = [fr.quantize(palette=palette, dither=Image.Dither.NONE) for fr in frames]
    indexed[0].save(args.out, save_all=True, append_images=indexed[1:], duration=FRAME_MS, loop=0,
                    disposal=0, blend=0, optimize=True)
    if args.preview:
        big = [fr.resize((W * 2, H * 2), Image.NEAREST) for fr in frames]
        big[0].save(args.preview, save_all=True, append_images=big[1:], duration=FRAME_MS, loop=0)
    print("%s: %d frames, %d ms each" % (args.out, len(frames), FRAME_MS))


if __name__ == "__main__":
    main()
