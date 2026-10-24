#!/usr/bin/env python3
"""Swap bar faces for the Pokémon we do not have yet, from the Battle Trozei icon sheet.

    scripts/art/trozei_faces.py <sheet.png>

The sheet is Pokémon Battle Trozei's "Small Pokémon Icons" (spriters-resource.com, 3DS, asset
64891): 24 x 32 cells of 64x64, a Poké Ball and then #1 to #718 with some forms in between.
Our own faces stay as they are; this writes art/sprites/faces/<dex>/0.png to 3.png for every
number past POKEMON_NUMBER (#387 to #718), ready for when those Pokémon are added. They are
kept at the sheet's 64x64 (shrinking them to our 32x32 loses too much) and bob like our faces:
4 frames that lift the face 0, 2, 4 and 2 pixels, the same rise as ours at twice the size.
"""
import os
import re
import shutil
import sys

from PIL import Image

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
NUMBERS = os.path.join(ROOT, 'core', 'server', 'data', 'lib', 'ps', 'config', 'pokemonsNumbers.lua')
OUT = os.path.join(ROOT, 'art', 'sprites', 'faces')
LAST_DEX = 718
BOB = (0, 2, 4, 2)
# cells that are not the next Pokédex number: the second Jigglypuff, Unown B to ?, East Sea
# Shellos and Gastrodon, Sky Shaymin, blue Basculin, Zen Darmanitan, female Frillish and
# Jellicent, White and Black Kyurem, Resolute Keldeo, two more Pyroar and female Meowstic
EXTRA_CELLS = {40, *range(203, 230), 451, 453, 523, 582, 588, 626, 628, 682, 683, 685, 707, 708, 719}


def dex_cells():
    cells = [c for c in range(1, 24 * 32) if c not in EXTRA_CELLS]
    return {dex: cells[dex - 1] for dex in range(1, LAST_DEX + 1)}


def bob_frames(face):
    """The face at rest sits low enough to rise without its top being cut off; the few that
    fill the whole cell bob less."""
    left, top, right, bottom = face.getbbox()
    room = top + face.height - bottom
    scale = min(1.0, room / max(BOB))
    lift = max(0, min(max(BOB) - top, face.height - bottom))
    rest = Image.new('RGBA', face.size)
    rest.alpha_composite(face, (0, lift))
    frames = []
    for up in BOB:
        up = int(up * scale)
        frame = Image.new('RGBA', face.size)
        frame.alpha_composite(rest, (0, -up))
        frames.append(frame)
    return frames


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
        face = sheet.crop((col * 64, row * 64, col * 64 + 64, row * 64 + 64))
        folder = os.path.join(OUT, str(dex))
        shutil.rmtree(folder, ignore_errors=True)
        os.makedirs(folder)
        for phase, frame in enumerate(bob_frames(face)):
            frame.save(os.path.join(folder, '%d.png' % phase))
        stale = os.path.join(OUT, '%d.png' % dex)
        if os.path.exists(stale):
            os.remove(stale)
        count += 1
    print('%d faces (#%d to #%d) in %s' % (count, have + 1, LAST_DEX, os.path.relpath(OUT, ROOT)))


if __name__ == '__main__':
    main()
