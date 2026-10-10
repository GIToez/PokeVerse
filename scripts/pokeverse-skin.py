#!/usr/bin/env python3
"""Recolours Redemption's grey UI images into the legacy PokeVerse palette.

    scripts/pokeverse-skin.py <redemption data/images> <out dir> [<subdir>...]

Grey images (the Tibia stone) become the legacy slate teal, with the stone grain
flattened; grey buttons become the legacy teal. Coloured art and light glyphs are kept.
Only images that change are written, at the same path under <out dir>, so the result
overlays Redemption's data (core/client-redemption/pokeverse-modern/data/images).
"""
import os
import sys

import numpy as np
from PIL import Image

# legacy images/ui/panel_flat.png (47, 63, 64) and button.png (1, 142, 136), per unit of grey
SLATE = np.array([0.81, 1.09, 1.10]) * 0.88
TEAL = np.array([0.02, 1.33, 1.27])
GRAIN = 22  # grey steps of stone texture that are flattened; larger steps are edges and bevels
GREY_SATURATION = 0.10


def box_blur(grey, radius):
    # wrap-around, so tiled backgrounds stay seamless
    padded = np.pad(grey, radius, mode="wrap")
    size = 2 * radius + 1
    sums = padded.cumsum(0).cumsum(1)
    sums = np.pad(sums, ((1, 0), (1, 0)))
    h, w = grey.shape
    total = sums[size:size + h, size:size + w] - sums[:h, size:size + w] - sums[size:size + h, :w] + sums[:h, :w]
    return total / (size * size)


def is_button(rel):
    name = os.path.basename(rel).lower()
    return "button" in name and not any(c in name for c in ("blue", "gold", "red", "green", "store"))


def recolour(path, rel):
    with Image.open(path) as im:
        if getattr(im, "n_frames", 1) > 1:
            return None
        rgba = np.asarray(im.convert("RGBA")).astype(float)
    rgb, alpha = rgba[..., :3], rgba[..., 3]
    shown = alpha > 16
    if shown.sum() < 16:
        return None
    mx, mn = rgb.max(axis=2), rgb.min(axis=2)
    saturation = np.where(mx > 0, (mx - mn) / np.maximum(mx, 1), 0)
    if saturation[shown].mean() > GREY_SATURATION:
        return None

    grey = rgb.mean(axis=2)
    smooth = box_blur(grey, min(5, (min(grey.shape) - 1) // 2))
    grain = np.abs(grey - smooth) < GRAIN
    # the stone becomes one flat colour, like the legacy panels; frames and bevels stay
    stone = shown & grain
    flat = np.where(grain, grey[stone].mean(), grey) if stone.any() else grey
    if grain[shown].mean() > 0.98:
        flat = np.full_like(grey, grey[shown].mean())

    tint = TEAL if is_button(rel) else SLATE
    coloured = flat[..., None] * tint
    # light glyphs, text and highlights stay neutral
    keep = np.clip((flat - 150) / 80, 0, 1)[..., None]
    out = coloured * (1 - keep) + flat[..., None] * keep
    # pixels that already carry colour (icons on grey buttons) keep it
    own = (saturation > 0.25)[..., None]
    out = np.where(own, rgb, out)
    result = np.dstack([np.clip(out, 0, 255), alpha]).astype(np.uint8)
    return Image.fromarray(result, "RGBA")


def main():
    if len(sys.argv) < 3:
        sys.stderr.write(__doc__)
        return 1
    src, dst = sys.argv[1], sys.argv[2]
    subdirs = sys.argv[3:] or ["ui"]
    written = 0
    for sub in subdirs:
        for root, _, names in os.walk(os.path.join(src, sub)):
            for name in sorted(names):
                if not name.lower().endswith(".png"):
                    continue
                path = os.path.join(root, name)
                rel = os.path.relpath(path, src)
                image = recolour(path, rel)
                if image is None:
                    continue
                target = os.path.join(dst, rel)
                os.makedirs(os.path.dirname(target), exist_ok=True)
                image.save(target, optimize=True)
                written += 1
    print("%d images recoloured into %s" % (written, dst))
    return 0


if __name__ == "__main__":
    sys.exit(main())
