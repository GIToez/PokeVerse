#!/usr/bin/env python3
"""Draws the Johto and Hoenn gym badges in the style of the Kanto badge sprites.

    scripts/art/badge_art.py [--sheet out.png]

Kanto and the Orange Islands have item sprites: a small badge on a 32x32 tile with a dark outline,
and a grey "slot" twin for a badge not earned yet. Johto and Hoenn have no gyms yet, so they get
plain images the badge case and the Trainer card show in their slots.
Writes core/client-redemption/pokeverse-modern/data/images/pokeverse-ui/badges/<region>-<badge>.png
and <region>-<badge>-slot.png. --sheet also writes a preview of all of them at 4x.
"""
import math
import os
import sys

from PIL import Image, ImageDraw

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.normpath(os.path.join(HERE, '..', '..'))
OUT = os.path.join(ROOT, 'core/client-redemption/pokeverse-modern/data/images/pokeverse-ui/badges')

SIZE = 32
OUTLINE = (34, 30, 44, 255)
C = 16  # the badge's centre on the tile


def hexc(value):
    value = value.lstrip('#')
    return tuple(int(value[i:i + 2], 16) for i in (0, 2, 4)) + (255,)


def shade(mask, base, light, dark, tilt=(1, 1)):
    """Fills mask with base, lighter towards the top left and darker towards the bottom right."""
    img = Image.new('RGBA', (SIZE, SIZE), (0, 0, 0, 0))
    px, mpx = img.load(), mask.load()
    box = mask.getbbox()
    if not box:
        return img
    cx, cy = (box[0] + box[2]) / 2, (box[1] + box[3]) / 2
    span = max(box[2] - box[0], box[3] - box[1]) / 2
    for y in range(SIZE):
        for x in range(SIZE):
            if mpx[x, y]:
                t = ((x - cx) * tilt[0] + (y - cy) * tilt[1]) / max(span, 1)
                px[x, y] = hexc(light) if t < -0.45 else hexc(dark) if t > 0.4 else hexc(base)
    return img


def mask_of(draw_fn):
    mask = Image.new('L', (SIZE, SIZE), 0)
    draw_fn(ImageDraw.Draw(mask))
    return mask


def outline(img):
    """A 1px dark outline round everything drawn."""
    src = img.load()
    out = img.copy()
    dst = out.load()
    for y in range(SIZE):
        for x in range(SIZE):
            if src[x, y][3]:
                continue
            for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                nx, ny = x + dx, y + dy
                if 0 <= nx < SIZE and 0 <= ny < SIZE and src[nx, ny][3]:
                    dst[x, y] = OUTLINE
                    break
    return out


def layer(img, mask, base, light, dark, tilt=(1, 1)):
    img.alpha_composite(shade(mask, base, light, dark, tilt))


def poly(points):
    return lambda d: d.polygon(points, fill=255)


def ellipse(box):
    return lambda d: d.ellipse(box, fill=255)


def star(cx, cy, outer, inner, points, rotation=-90):
    out = []
    for i in range(points * 2):
        r = outer if i % 2 == 0 else inner
        a = math.radians(rotation + i * 180 / points)
        out.append((cx + r * math.cos(a), cy + r * math.sin(a)))
    return out


def regular(cx, cy, r, sides, rotation=-90):
    return [(cx + r * math.cos(math.radians(rotation + i * 360 / sides)),
             cy + r * math.sin(math.radians(rotation + i * 360 / sides))) for i in range(sides)]


def dot(img, x, y, colour):
    img.putpixel((x, y), hexc(colour))


# -- Johto ------------------------------------------------------------------------------------------

def zephyr(img):
    # two swept wings meeting at the bottom
    layer(img, mask_of(poly([(16, 23), (6, 10), (9, 9), (16, 17)])), '#b9c3cf', '#eef3f8', '#7d8896')
    layer(img, mask_of(poly([(16, 23), (26, 10), (23, 9), (16, 17)])), '#b9c3cf', '#eef3f8', '#7d8896', (-1, 1))
    layer(img, mask_of(poly([(9, 13), (5, 15), (12, 19)])), '#9aa5b3', '#dfe6ee', '#6c7684')
    layer(img, mask_of(poly([(23, 13), (27, 15), (20, 19)])), '#9aa5b3', '#dfe6ee', '#6c7684', (-1, 1))


def hive(img):
    # a red bug: round body, black head and stripe, black spots
    layer(img, mask_of(ellipse((9, 10, 23, 24))), '#d8323a', '#ff7a6e', '#8f1a22')
    layer(img, mask_of(ellipse((12, 7, 20, 13))), '#2b2633', '#58516a', '#17131d')
    d = ImageDraw.Draw(img)
    d.line([(16, 13), (16, 23)], fill=hexc('#2b2633'))
    for x, y in ((12, 15), (20, 15), (12, 20), (20, 20)):
        d.rectangle([x - 1, y - 1, x, y], fill=hexc('#2b2633'))


def plain(img):
    # a gold four-point star with a pink heart of a diamond
    layer(img, mask_of(poly(star(16, 16, 10, 4, 4))), '#f2c230', '#fff0a0', '#b8860b')
    layer(img, mask_of(poly([(16, 12), (20, 16), (16, 20), (12, 16)])), '#f07aa8', '#ffc2dc', '#b8406f')


def fog(img):
    # a pale ghost-flame curling up
    layer(img, mask_of(poly([(10, 24), (8, 16), (12, 9), (17, 6), (15, 11), (21, 9), (24, 15), (22, 24)])),
          '#f6c25a', '#fff1b8', '#c07a20')
    layer(img, mask_of(ellipse((12, 14, 20, 22))), '#fbe3a0', '#fffbe8', '#e0a848')


def storm(img):
    # a brown fist-like round with a grey band of knuckles
    layer(img, mask_of(ellipse((8, 9, 24, 25))), '#a86a3c', '#d8a070', '#6c3e1c')
    layer(img, mask_of(poly([(9, 13), (23, 13), (23, 17), (9, 17)])), '#9aa3ad', '#dde3ea', '#646c76')
    d = ImageDraw.Draw(img)
    for x in (12, 16, 20):
        d.line([(x, 13), (x, 17)], fill=hexc('#646c76'))


def mineral(img):
    # a steel hexagon cut in facets
    layer(img, mask_of(poly(regular(16, 16, 10, 6, -90))), '#a4b0bd', '#eef3f8', '#5f6b78')
    layer(img, mask_of(poly(regular(16, 16, 5, 6, -90))), '#c8d2dc', '#ffffff', '#8693a1')


def glacier(img):
    # a pale blue ice crystal
    layer(img, mask_of(poly([(16, 5), (22, 16), (16, 27), (10, 16)])), '#7fd0f0', '#e2f7ff', '#3d8fbf')
    layer(img, mask_of(poly([(6, 16), (16, 12), (26, 16), (16, 20)])), '#a8e2f7', '#f2fcff', '#5aa8d0')


def rising(img):
    # a dragon's fin: blue diamond, red core
    layer(img, mask_of(poly([(16, 5), (25, 14), (21, 26), (11, 26), (7, 14)])), '#3a64c8', '#8fb0ff', '#1e3478')
    layer(img, mask_of(poly([(16, 11), (20, 16), (16, 22), (12, 16)])), '#e0403a', '#ff9a86', '#922420')


# -- Hoenn ------------------------------------------------------------------------------------------

def stone(img):
    # a grey stone, rounded and faceted
    layer(img, mask_of(poly([(16, 6), (25, 22), (22, 25), (10, 25), (7, 22)])), '#9c958c', '#dad4cb', '#5e5850')
    layer(img, mask_of(poly([(16, 11), (20, 21), (12, 21)])), '#b8b1a8', '#ece7e0', '#7d766e')


def knuckle(img):
    # an orange round with a blue band across it
    layer(img, mask_of(ellipse((8, 8, 24, 24))), '#f09a3a', '#ffd08a', '#a85a14')
    layer(img, mask_of(poly([(8, 14), (24, 12), (24, 18), (8, 20)])), '#3f6fd0', '#9ab8ff', '#203c80')


def dynamo(img):
    # a yellow gear with a dark hub
    layer(img, mask_of(poly(star(16, 16, 11, 8, 8, -90))), '#f2d03a', '#fff3a6', '#b8920e')
    layer(img, mask_of(ellipse((12, 12, 20, 20))), '#5a4f3a', '#8a7d62', '#2e2818')


def heat(img):
    # a red flame
    layer(img, mask_of(poly([(16, 4), (22, 12), (24, 19), (20, 26), (12, 26), (8, 19), (11, 13), (14, 15)])),
          '#e2382e', '#ff8a6a', '#8e1a14')
    layer(img, mask_of(poly([(16, 13), (19, 19), (17, 24), (15, 24), (13, 19)])), '#ffb43a', '#fff0a0', '#d07a18')


def balance(img):
    # a tilted square, red over gold
    layer(img, mask_of(poly([(16, 5), (27, 16), (16, 27), (5, 16)])), '#f2c230', '#fff0a0', '#b8860b')
    layer(img, mask_of(poly([(16, 9), (23, 16), (16, 23), (9, 16)])), '#d8323a', '#ff7a6e', '#8f1a22')


def feather(img):
    # a blue-violet feather
    layer(img, mask_of(poly([(22, 5), (25, 9), (17, 22), (10, 27), (8, 25), (12, 17)])), '#6a6ae0', '#b8b8ff', '#33338a')
    d = ImageDraw.Draw(img)
    d.line([(22, 7), (9, 26)], fill=hexc('#e8e8ff'))


def mind(img):
    # two overlapping rounds, pink and violet
    layer(img, mask_of(ellipse((6, 9, 19, 22))), '#e86aa8', '#ffb6da', '#9a2e66')
    layer(img, mask_of(ellipse((13, 9, 26, 22))), '#a35ad8', '#dcb0ff', '#5e2a8a')


def rain(img):
    # a blue drop with a white glint
    layer(img, mask_of(poly([(16, 4), (22, 15), (23, 19), (20, 25), (12, 25), (9, 19), (10, 15)])),
          '#3a8ee0', '#9ad0ff', '#1a4e8e')
    for x, y in ((13, 16), (13, 17), (14, 15)):
        dot(img, x, y, '#ffffff')


BADGES = [
    ('johto', [('zephyr', zephyr), ('hive', hive), ('plain', plain), ('fog', fog),
               ('storm', storm), ('mineral', mineral), ('glacier', glacier), ('rising', rising)]),
    ('hoenn', [('stone', stone), ('knuckle', knuckle), ('dynamo', dynamo), ('heat', heat),
               ('balance', balance), ('feather', feather), ('mind', mind), ('rain', rain)]),
]


def grey(img):
    """The slot twin: the same badge in greys, as the Kanto badge slots are."""
    out = img.copy()
    px = out.load()
    for y in range(SIZE):
        for x in range(SIZE):
            r, g, b, a = px[x, y]
            if a and (r, g, b, a) != OUTLINE:
                v = int(0.3 * r + 0.59 * g + 0.11 * b)
                v = int(110 + (v - 110) * 0.7)
                px[x, y] = (v, v, min(255, v + 6), a)
    return out


def main():
    os.makedirs(OUT, exist_ok=True)
    tiles = []
    for region, badges in BADGES:
        for name, draw in badges:
            img = Image.new('RGBA', (SIZE, SIZE), (0, 0, 0, 0))
            draw(img)
            img = outline(img)
            slot = grey(img)
            img.save(os.path.join(OUT, '%s-%s.png' % (region, name)))
            slot.save(os.path.join(OUT, '%s-%s-slot.png' % (region, name)))
            tiles.append((img, slot))
    if '--sheet' in sys.argv:
        path = sys.argv[sys.argv.index('--sheet') + 1]
        sheet = Image.new('RGBA', (len(tiles) * 34, 68), (40, 44, 60, 255))
        for i, (img, slot) in enumerate(tiles):
            sheet.alpha_composite(img, (i * 34 + 1, 1))
            sheet.alpha_composite(slot, (i * 34 + 1, 35))
        sheet.resize((sheet.width * 3, sheet.height * 3), Image.NEAREST).save(path)
    print('wrote %d badges to %s' % (len(tiles), OUT))


if __name__ == '__main__':
    main()
