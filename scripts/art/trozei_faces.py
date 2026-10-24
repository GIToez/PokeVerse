#!/usr/bin/env python3
"""Swap bar faces for the Pokémon we do not have yet, from the Battle Trozei icon sheet.

    scripts/art/trozei_faces.py <sheet.png>

The sheet is Pokémon Battle Trozei's "Small Pokémon Icons" (spriters-resource.com, 3DS, asset
64891): 24 x 32 cells of 64x64, a Poké Ball and then #1 to #718 with some forms in between.
Our own faces stay as they are; this writes art/sprites/faces/<dex>.png for every number past
POKEMON_NUMBER (#387 to #718), ready for when those Pokémon are added. They are kept at the
sheet's 64x64: shrinking them to our 32x32 loses too much.
"""
import os
import re
import sys

from PIL import Image

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
NUMBERS = os.path.join(ROOT, 'core', 'server', 'data', 'lib', 'ps', 'config', 'pokemonsNumbers.lua')
OUT = os.path.join(ROOT, 'art', 'sprites', 'faces')
LAST_DEX = 718
# cells that are not the next Pokédex number: the second Jigglypuff, Unown B to ?, East Sea
# Shellos and Gastrodon, Sky Shaymin, blue Basculin, Zen Darmanitan, female Frillish and
# Jellicent, White and Black Kyurem, Resolute Keldeo, two more Pyroar and female Meowstic
EXTRA_CELLS = {40, *range(203, 230), 451, 453, 523, 582, 588, 626, 628, 682, 683, 685, 707, 708, 719}


def dex_cells():
    cells = [c for c in range(1, 24 * 32) if c not in EXTRA_CELLS]
    return {dex: cells[dex - 1] for dex in range(1, LAST_DEX + 1)}


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
        sheet.crop((col * 64, row * 64, col * 64 + 64, row * 64 + 64)).save(os.path.join(OUT, '%d.png' % dex))
        count += 1
    print('%d faces (#%d to #%d) in %s' % (count, have + 1, LAST_DEX, os.path.relpath(OUT, ROOT)))


if __name__ == '__main__':
    main()
