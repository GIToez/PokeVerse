#!/usr/bin/env python3
"""Swap bar faces for the Pokémon we do not have yet, from the Battle Trozei icon sheet.

    scripts/art/trozei_faces.py <sheet.png>

The sheet is Pokémon Battle Trozei's "Small Pokémon Icons" (spriters-resource.com, 3DS, asset
64891): 24 x 32 cells of 64x64, a Poké Ball and then #1 to #718 with some forms in between.
Our own faces stay as they are; this writes art/sprites/faces/<dex>.png for every number past
POKEMON_NUMBER (#387 to #718), ready for when those Pokémon are added.

Each face is shrunk to 32x32 by averaging, then cut to a few flat colours with no dithering
and given a solid dark outline, so it reads like our hand-drawn faces instead of a blurred
picture.
"""
import os
import re
import sys

import numpy as np
from PIL import Image

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
NUMBERS = os.path.join(ROOT, 'core', 'server', 'data', 'lib', 'ps', 'config', 'pokemonsNumbers.lua')
OUT = os.path.join(ROOT, 'art', 'sprites', 'faces')
LAST_DEX = 718
COLOURS = 18
OUTLINE = (28, 22, 30)
# cells that are not the next Pokédex number: the second Jigglypuff, Unown B to ?, East Sea
# Shellos and Gastrodon, Sky Shaymin, blue Basculin, Zen Darmanitan, female Frillish and
# Jellicent, White and Black Kyurem, Resolute Keldeo, two more Pyroar and female Meowstic
EXTRA_CELLS = {40, *range(203, 230), 451, 453, 523, 582, 588, 626, 628, 682, 683, 685, 707, 708, 719}


def dex_cells():
    cells = [c for c in range(1, 24 * 32) if c not in EXTRA_CELLS]
    return {dex: cells[dex - 1] for dex in range(1, LAST_DEX + 1)}


def averaged(cell):
    """64x64 RGBA to 32x32, colours averaged by coverage, hard alpha."""
    a = np.asarray(cell.convert('RGBA')).astype(np.float64) / 255
    rgb, alpha = a[..., :3], a[..., 3:]
    pre = (rgb * alpha).reshape(32, 2, 32, 2, 3).mean(axis=(1, 3))
    al = alpha.reshape(32, 2, 32, 2, 1).mean(axis=(1, 3))
    rgb = np.where(al > 0, pre / np.maximum(al, 1e-6), 0)
    out = np.concatenate([rgb, (al > 0.45).astype(np.float64)], axis=2)
    return Image.fromarray((out * 255).round().astype(np.uint8), 'RGBA')


def flat(face):
    alpha = np.asarray(face)[..., 3] > 0
    rgb = face.convert('RGB').quantize(COLOURS, method=Image.MEDIANCUT, dither=Image.Dither.NONE).convert('RGB')
    a = np.asarray(rgb).copy()
    pad = np.pad(alpha, 1)
    edge = alpha & ~(pad[:-2, 1:-1] & pad[2:, 1:-1] & pad[1:-1, :-2] & pad[1:-1, 2:])
    a[edge & (a @ np.array([0.299, 0.587, 0.114]) > 70)] = OUTLINE
    out = np.dstack([a, alpha * 255]).astype(np.uint8)
    out[~alpha] = 0
    return Image.fromarray(out, 'RGBA')


def main():
    if len(sys.argv) != 2:
        sys.exit(__doc__)
    sheet = Image.open(sys.argv[1]).convert('RGBA')
    have = int(re.search(r'POKEMON_NUMBER\s*=\s*(\d+)', open(NUMBERS, encoding='latin-1').read())[1])
    os.makedirs(OUT, exist_ok=True)
    count = 0
    for dex, cell in dex_cells().items():
        if dex <= have:
            continue
        row, col = divmod(cell, 24)
        face = flat(averaged(sheet.crop((col * 64, row * 64, col * 64 + 64, row * 64 + 64))))
        face.save(os.path.join(OUT, '%d.png' % dex))
        count += 1
    print('%d faces (#%d to #%d) in %s' % (count, have + 1, LAST_DEX, os.path.relpath(OUT, ROOT)))


if __name__ == '__main__':
    main()
