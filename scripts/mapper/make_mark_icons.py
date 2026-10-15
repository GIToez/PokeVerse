#!/usr/bin/env python3
"""Draws the minimap's guide mark icons (game_minimap/images/marks/<name>.png) from the game's sprites.

    scripts/mapper/make_mark_icons.py

Each icon is a 14x14 dark disc with a ring in its group's colour and an item sprite inside it.
game_minimap/pokeverse.lua picks the icon from the words in a guide mark's name. Run this again
after adding an icon here, and commit the pictures; they are small and don't change with the map.
"""
import os
import sys

from PIL import Image, ImageDraw

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import render  # noqa: E402

ROOT = os.path.normpath(os.path.join(HERE, '..', '..'))
OTB = os.path.join(ROOT, 'core/server/data/items/items.otb')
DAT = os.path.join(ROOT, 'core/client-legacy/data/things/data.dat')
SPR = os.path.join(ROOT, 'core/client-legacy/data/things/data.spr')
OUT = os.path.join(ROOT, 'core/client-redemption/pokeverse-modern/modules/game_minimap/images/marks')

SIZE = 14
INSIDE = 10
SUPER = 4

RINGS = {
    'center': (232, 72, 63),
    'mart': (79, 143, 240),
    'shop': (92, 200, 106),
    'gym': (255, 215, 90),
    'travel': (95, 211, 230),
    'other': (220, 230, 255),
}

# name: (group, server item id, or a function that draws the inside at SUPER x scale)
ICONS = {
    'center': ('center', 12159),        # poke ball
    'mart': ('mart', 12244),            # pokemon health potion
    'food': ('shop', 12205),            # burger
    'berry': ('shop', 14767),           # oran berry
    'furniture': ('shop', 12027),       # small white couch
    'shopping': ('shop', 23589),        # shopping bag
    'bike': ('shop', 13218),            # mach bike
    'gym_boulder': ('gym', 12213),
    'gym_cascade': ('gym', 12215),
    'gym_thunder': ('gym', 12217),
    'gym_rainbow': ('gym', 12219),
    'gym_soul': ('gym', 12221),
    'gym_marsh': ('gym', 12223),
    'gym_volcano': ('gym', 12225),
    'gym_earth': ('gym', 12227),
    'gym': ('gym', 12280),              # badge case
    'ship': ('travel', 12258),          # lapras doll
    'fly': ('travel', 12253),           # pidgeot doll
    'balloon': ('travel', 12270),       # jigglypuff doll
    'train': ('travel', 23540),         # ticket
    'guild': ('other', 'house'),
    'ranger': ('other', 12271),         # bulbasaur doll
    'daycare': ('other', 12154),        # egg
    'casino': ('other', 23497),         # poke coin
    'museum': ('other', 12092),         # helix fossil
    'safari': ('other', 12171),         # safari ball
    'silph': ('other', 12190),          # master ball
    'lab': ('other', 12281),            # pokedex
    'place': ('other', 12256),          # pikachu doll, for marks without a better icon
}


def draw_house(d, s):
    white = (235, 240, 255, 255)
    d.polygon([(s * 0.5, s * 0.05), (s, s * 0.5), (0, s * 0.5)], fill=white)
    d.rectangle((s * 0.15, s * 0.45, s * 0.85, s * 0.95), fill=white)
    d.rectangle((s * 0.4, s * 0.62, s * 0.6, s * 0.95), fill=(11, 20, 39, 255))


DRAWN = {'house': draw_house}


def sprite(r, server_id):
    img = r.render({(1, 1, 7): [server_id]}, 0, 0, 1, 1, 7, upper=False, background=(0, 0, 0, 0))
    box = img.getbbox()
    img = img.crop(box)
    if max(img.size) > INSIDE:
        scale = INSIDE / max(img.size)
        img = img.resize((max(1, round(img.width * scale)), max(1, round(img.height * scale))), Image.LANCZOS)
    return img


def disc(group):
    big = Image.new('RGBA', (SIZE * SUPER, SIZE * SUPER), (0, 0, 0, 0))
    d = ImageDraw.Draw(big)
    d.ellipse((0, 0, SIZE * SUPER - 1, SIZE * SUPER - 1), fill=(11, 20, 39, 235), outline=RINGS[group] + (255,),
              width=int(1.5 * SUPER))
    return big.resize((SIZE, SIZE), Image.LANCZOS)


def main():
    r = render.Renderer(OTB, DAT, SPR)
    os.makedirs(OUT, exist_ok=True)
    for name, (group, what) in ICONS.items():
        icon = disc(group)
        if isinstance(what, str):
            s = (INSIDE - 2) * SUPER
            inside = Image.new('RGBA', (s, s), (0, 0, 0, 0))
            DRAWN[what](ImageDraw.Draw(inside), s - 1)
            inside = inside.resize((INSIDE - 2, INSIDE - 2), Image.LANCZOS)
        else:
            inside = sprite(r, what)
        icon.alpha_composite(inside, ((SIZE - inside.width) // 2, (SIZE - inside.height) // 2))
        icon.save(os.path.join(OUT, name + '.png'))
    print('wrote %d icons to %s' % (len(ICONS), OUT))


if __name__ == '__main__':
    main()
