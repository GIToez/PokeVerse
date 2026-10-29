#!/usr/bin/env python3
"""The Verse Orb item frames, from the 12-frame concept (docs/concepts/verse-orb-frames.png).

    python3 scripts/art/verse_orb.py <out dir>

The concept fills its 32x32 tile, twice the size of a Pokedollar note, so each frame is shrunk
to 22 px (premultiplied box filter, hard alpha, a dark rim) and set a little right of and below
the middle, where items sit on their tile. Writes orb-00.png to orb-11.png and strip.png (the
frames side by side, 3x). Then:

    python3 scripts/dat-set-item-frames.py --hold 3 6499 <out dir>/orb-*.png
"""
import os
import sys

import numpy as np
from PIL import Image

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
CONCEPT = os.path.join(ROOT, 'docs/concepts/verse-orb-frames.png')
SIZE = 22
OFFSET = (7, 8)
RIM = (42, 26, 82)


def shrink(tile):
    px = np.array(tile).astype(float)
    px[..., :3] *= px[..., 3:4] / 255
    small = np.array(Image.fromarray(px.clip(0, 255).astype(np.uint8), 'RGBA').resize((SIZE, SIZE), Image.BOX)).astype(float)
    alpha = small[..., 3]
    rgb = np.where(alpha[..., None] > 0, small[..., :3] * 255 / np.maximum(alpha[..., None], 1), 0)
    solid = alpha > 110
    out = np.zeros((SIZE, SIZE, 4), np.uint8)
    out[..., :3] = rgb.clip(0, 255)
    out[..., 3] = np.where(solid, 255, 0)
    pad = np.pad(solid, 1)
    edge = solid & ~(pad[:-2, 1:-1] & pad[2:, 1:-1] & pad[1:-1, :-2] & pad[1:-1, 2:])
    out[edge, :3] = RIM
    out[~solid] = 0
    return Image.fromarray(out, 'RGBA')


def main():
    if len(sys.argv) != 2:
        sys.exit(__doc__)
    out_dir = sys.argv[1]
    os.makedirs(out_dir, exist_ok=True)
    concept = Image.open(CONCEPT).convert('RGBA')
    count = concept.width // 32
    strip = Image.new('RGBA', (32 * count, 32), (40, 50, 70, 255))
    for k in range(count):
        tile = Image.new('RGBA', (32, 32))
        tile.alpha_composite(shrink(concept.crop((k * 32, 0, k * 32 + 32, 32))), OFFSET)
        tile.save(os.path.join(out_dir, 'orb-%02d.png' % k))
        strip.alpha_composite(tile, (k * 32, 0))
    strip.resize((strip.width * 3, strip.height * 3), Image.NEAREST).save(os.path.join(out_dir, 'strip.png'))
    print('wrote %d frames into %s' % (count, out_dir))


if __name__ == '__main__':
    main()
