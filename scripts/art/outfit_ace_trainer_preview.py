#!/usr/bin/env python3
"""Pictures of the Ace Trainer outfit as the game shows it.

    outfit_ace_trainer_preview.py [out dir]

Needs the map and data.spr from Git LFS. Writes, next to the sprites:
- world.png: Pallet Town's fountain square from the map with Ace Trainers in five colour sets.
- showcase.png: the add-ons in every direction, the base and mask layers, and the colour sets.
- walk.gif: the walk cycle in the four directions.
The colour sets use the outfit window's palette; the indices are printed for /outfit tests.
"""
import os
import sys

from PIL import Image, ImageDraw, ImageFont

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
sys.path.insert(0, os.path.join(HERE, '..', 'mapper'))
import outfit_ace_trainer as ace  # noqa: E402
import outfit_sprites  # noqa: E402
import pvmap  # noqa: E402
from render import Renderer  # noqa: E402

ROOT = outfit_sprites.ROOT
MAP = os.path.join(ROOT, 'core/server/data/world/map.otbm')
SCENE = (3282, 808, 3301, 822)  # Pallet Town's fountain square, floor 7
GRASS_TILE = (2, 1)  # a plain grass tile of the scene, for the showcase background
SETS = {  # head, body, legs, feet
    'Classic': ((70, 45, 30), (215, 40, 40), (40, 55, 120), (245, 200, 40)),
    'Rival': ((190, 110, 50), (40, 90, 210), (45, 45, 50), (240, 240, 240)),
    'Grass': ((25, 25, 25), (60, 170, 70), (170, 150, 105), (240, 130, 30)),
    'Psychic': ((240, 210, 100), (140, 60, 180), (70, 70, 80), (240, 120, 170)),
    'Shadow': ((235, 235, 235), (40, 40, 45), (40, 40, 45), (220, 180, 40)),
}
# tile x, y, (direction, frame, colour set, add-ons) for trainers or (look type, direction) for Pokemon
CAST = [
    (3289, 814, 'trainer', (ace.SOUTH, 0, 'Classic', (1, 2))),
    (3290, 815, 'pokemon', (376, ace.WEST)),
    (3294, 813, 'trainer', (ace.WEST, 1, 'Rival', (1,))),
    (3286, 817, 'trainer', (ace.EAST, 2, 'Grass', (2,))),
    (3297, 817, 'trainer', (ace.NORTH, 0, 'Psychic', (1, 2))),
    (3292, 819, 'trainer', (ace.SOUTH, 1, 'Shadow', (1, 2))),
    (3299, 812, 'pokemon', (357, ace.SOUTH)),
]
DISPLACEMENT = 8  # outfits are drawn 8 px up and left of their tile (dat attribute 25)
DIRECTIONS = [ace.SOUTH, ace.EAST, ace.NORTH, ace.WEST]


def palette_index(rgb):
    return min(range(133), key=lambda i: sum((a - b) ** 2 for a, b in zip(ace.outfit_color(i), rgb)))


def font(size, bold=False):
    name = 'DejaVuSans-Bold.ttf' if bold else 'DejaVuSans.ttf'
    try:
        return ImageFont.truetype('/usr/share/fonts/truetype/dejavu/' + name, size)
    except OSError:
        return ImageFont.load_default()


def world(frames, sets):
    tiles = pvmap.read_region(MAP, SCENE[0] - 2, SCENE[1] - 2, SCENE[2] + 10, SCENE[3] + 10, range(0, 8))
    r = Renderer(os.path.join(ROOT, 'core/server/data/items/items.otb'),
                 os.path.join(outfit_sprites.THINGS, 'data.dat'), os.path.join(outfit_sprites.THINGS, 'data.spr'))
    scene = r.render(tiles, *SCENE, 7).convert('RGBA')
    data = open(os.path.join(outfit_sprites.THINGS, 'data.dat'), 'rb').read()
    looks = outfit_sprites.read_outfits(data)
    spr = outfit_sprites.Spr(os.path.join(outfit_sprites.THINGS, 'data.spr'))
    for tx, ty, kind, args in sorted(CAST, key=lambda c: (c[1], c[0])):
        px, py = (tx - SCENE[0]) * 32, (ty - SCENE[1]) * 32
        if kind == 'trainer':
            d, f, name, addons = args
            img = ace.dressed(frames, d, f, sets[name], addons)
            scene.alpha_composite(img, (px + 32 - ace.SIZE - DISPLACEMENT, py + 32 - ace.SIZE - DISPLACEMENT))
        else:
            look, d = args
            img = outfit_sprites.frame_image(spr, looks[look], 0, d, 0, 0, 0)
            scene.alpha_composite(img, (px + 32 - img.width, py + 32 - img.height))
    return scene


class Showcase:
    SCALE, CW, CH, CROP = 3, 40, 42, (26, 22, 66, 64)

    def __init__(self, grass):
        self.grass = grass

    def cell(self, img):
        c = Image.new('RGBA', (self.CW, self.CH))
        for gx in range(0, self.CW + 32, 32):
            for gy in range(0, self.CH + 32, 32):
                c.paste(self.grass, (gx - 8, gy - 6))
        pad = Image.new('RGBA', (68, 68), (0, 0, 0, 0))
        pad.paste(img, (0, 0))
        c.alpha_composite(pad.crop(self.CROP))
        return c

    def block(self, title, rows):
        s = self.SCALE
        width = max(len(ims) for _, ims in rows) * self.CW * s + 160
        b = Image.new('RGBA', (max(width, 640), 32 + len(rows) * (self.CH * s + 8)), (28, 32, 40, 255))
        draw = ImageDraw.Draw(b)
        draw.text((10, 7), title, fill=(255, 214, 90), font=font(15, True))
        for i, (label, ims) in enumerate(rows):
            y = 32 + i * (self.CH * s + 8)
            draw.text((10, y + self.CH * s // 2 - 8), label, fill=(230, 230, 230), font=font(13))
            for j, im in enumerate(ims):
                b.alpha_composite(self.cell(im).resize((self.CW * s, self.CH * s), Image.NEAREST),
                                  (160 + j * self.CW * s, y))
        return b


def with_mask(frames, pattern, d):
    base, mask = frames[(pattern, d, 0)]
    img = base.copy()
    img.alpha_composite(mask)
    return img


def main():
    out = sys.argv[1] if len(sys.argv) > 1 else ace.OUT
    os.makedirs(out, exist_ok=True)
    frames, _ = ace.build()
    sets = {}
    for name, rgbs in SETS.items():
        indices = [palette_index(c) for c in rgbs]
        sets[name] = [ace.outfit_color(i) for i in indices]
        print('%-8s head %3d  body %3d  legs %3d  feet %3d' % ((name,) + tuple(indices)))

    scene = world(frames, sets)
    scene.convert('RGB').save(os.path.join(out, 'world.png'))

    gx, gy = GRASS_TILE
    show = Showcase(scene.crop((gx * 32, gy * 32, gx * 32 + 32, gy * 32 + 32)))
    classic = sets['Classic']
    blocks = [
        show.block('Ace Trainer: add-ons (south, east, north, west)', [
            (label, [ace.dressed(frames, d, 0, classic, addons) for d in DIRECTIONS])
            for label, addons in [('Base', ()), ('+ Add-on 1: Cap', (1,)), ('+ Add-on 2: Pack', (2,)),
                                  ('Full outfit', (1, 2))]]),
        show.block('Layers: grey base, then RGB mask (yellow head, red body, green legs, blue feet)', [
            (label, [frames[(p, d, 0)][0] for d in DIRECTIONS] + [with_mask(frames, p, d) for d in DIRECTIONS[:2]])
            for label, p in [('Base', 0), ('Add-on 1', 1), ('Add-on 2', 2)]]),
        show.block('Colour sets: with add-ons / base', [
            (name, [ace.dressed(frames, d, 0, colors, (1, 2)) for d in DIRECTIONS[:2]]
             + [ace.dressed(frames, d, 0, colors, ()) for d in DIRECTIONS[:2]]) for name, colors in sets.items()]),
    ]
    sheet = Image.new('RGBA', (max(b.width for b in blocks), sum(b.height + 10 for b in blocks) - 10),
                      (20, 22, 28, 255))
    y = 0
    for b in blocks:
        sheet.alpha_composite(b, (0, y))
        y += b.height + 10
    sheet.convert('RGB').save(os.path.join(out, 'showcase.png'))

    steps = []
    for f in (1, 0, 2, 0):
        row = Image.new('RGBA', (show.CW * 4, show.CH))
        for k, d in enumerate(DIRECTIONS):
            row.alpha_composite(show.cell(ace.dressed(frames, d, f, classic)), (k * show.CW, 0))
        steps.append(row.resize((row.width * 4, row.height * 4), Image.NEAREST).convert('RGB'))
    steps[0].save(os.path.join(out, 'walk.gif'), save_all=True, append_images=steps[1:], duration=160, loop=0)
    print('previews -> %s' % os.path.relpath(out, ROOT))


if __name__ == '__main__':
    main()
