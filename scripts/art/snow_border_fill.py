#!/usr/bin/env python3
"""The snow border (server 4737-4748) filled with today's snow.

The border's snow side is one flat blue-grey (160, 192, 200), an older snow colour, and shows as hard
blue-grey squares beside the white snow ground (Christmas Village) and on the paths through it. The
fill gets the snow ground's pixels (server 670), so the border's snow is the snow beside it.

    snow_border_fill.py --mockup out.png X0 Y0 X1 Y1   floor 7 of the map with the new sprites
    snow_border_fill.py --write-spr                     puts the new sprites into data.spr

The original sprites are kept in art/sprites/snow-border/original.png (with sprites.txt).
"""
import argparse
import os
import sys

import numpy as np
from PIL import Image

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import rock_ground_tone as tool  # noqa: E402

tool.OUT = os.path.join(tool.ROOT, 'art/sprites/snow-border')
BORDER = range(4737, 4749)
FILL = (160, 192, 200)
SNOW = 670


def paint_fill(art, snow):
    new = {}
    for sid, img in art.items():
        img = img.copy()
        fill = (img[:, :, 0] == FILL[0]) & (img[:, :, 1] == FILL[1]) & (img[:, :, 2] == FILL[2]) & (img[:, :, 3] == 255)
        img[fill] = snow[fill]
        new[sid] = img
    return new


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--mockup', nargs=5, metavar=('OUT', 'X0', 'Y0', 'X1', 'Y1'))
    ap.add_argument('--write-spr', action='store_true')
    args = ap.parse_args()
    otb, dat, spr = tool.pvmap.Otb(tool.ITEMS), tool.pvmap.Dat(tool.DAT), tool.pvmap.Spr(tool.SPR)
    sprites = tool.item_sprites(otb, dat, BORDER)
    snow = np.frombuffer(spr.rgba(tool.item_sprites(otb, dat, [SNOW])[0]), np.uint8).reshape(32, 32, 4)
    new = paint_fill(tool.originals(sprites, spr), snow)
    if args.mockup:
        out, x0, y0, x1, y1 = args.mockup[0], *map(int, args.mockup[1:])
        r = tool.Renderer(tool.ITEMS, tool.DAT, tool.SPR)
        r.sprite_images.update({s: Image.fromarray(img, 'RGBA') for s, img in new.items()})
        tiles = tool.pvmap.read_region(tool.MAP, x0 - 2, y0 - 2, x1 + 10, y1 + 10, range(0, 8))
        r.render(tiles, x0, y0, x1, y1, 7).convert('RGB').save(out)
        print('wrote', out)
    if args.write_spr:
        tool.write_spr(new)


if __name__ == '__main__':
    main()
