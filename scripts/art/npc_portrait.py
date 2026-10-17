#!/usr/bin/env python3
"""Turns a square picture into a round NPC portrait in the gym leaders' style: 168x168, a white rim
and a colored ring around the picture.

    scripts/art/npc_portrait.py <picture> <out.png> <ring color> [left,top,right,bottom crop]

The NPC dialogue window (game_npcdialog) shows the portraits from data/images/portraits. Nurse Joy:
    scripts/art/npc_portrait.py nurse-joy.jpg .../data/images/portraits/nurse_joy.png '#e85c96' 92,20,932,860
"""
import sys

from PIL import Image, ImageDraw

SIZE = 168
RIM = 8   # the picture starts this far in
SCALE = 4 # the circles are drawn larger and shrunk for smooth edges


def circle(inset):
    big = SIZE * SCALE
    mask = Image.new('L', (big, big), 0)
    ImageDraw.Draw(mask).ellipse((inset, inset, big - 1 - inset, big - 1 - inset), fill=255)
    return mask.resize((SIZE, SIZE), Image.LANCZOS)


def portrait(picture, color, crop=None):
    color = tuple(int(color.lstrip('#')[i:i + 2], 16) for i in (0, 2, 4))
    if crop:
        picture = picture.crop(crop)
    picture = picture.convert('RGB').resize((SIZE, SIZE), Image.LANCZOS)
    ring = Image.composite(Image.new('RGBA', (SIZE, SIZE), color + (255,)),
                           Image.new('RGBA', (SIZE, SIZE), (255, 255, 255, 255)), circle(10))
    out = Image.new('RGBA', (SIZE, SIZE), (0, 0, 0, 0))
    out.paste(ring, (0, 0), circle(0))
    out.paste(picture, (0, 0), circle(RIM * SCALE))
    return out


def main():
    if len(sys.argv) < 4:
        sys.exit(__doc__)
    crop = tuple(int(v) for v in sys.argv[4].split(',')) if len(sys.argv) > 4 else None
    portrait(Image.open(sys.argv[1]), sys.argv[3], crop).save(sys.argv[2], optimize=True)


if __name__ == '__main__':
    main()
