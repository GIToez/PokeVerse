#!/usr/bin/env python3
"""Draws the icons of the inventory's Order, Pokedex and Badges tiles from the game's sprites.

    scripts/art/inventory_tiles.py

The sprites have their name written under the picture ("Order", "Dex", "Badges"). The tiles show the
picture and their own label instead, so each icon is the sprite cut above its text.
Writes core/client-redemption/pokeverse-modern/data/images/pokeverse-ui/inv-<name>.png; the
game_inventory patch picks the icon by the item's server id.
"""
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.normpath(os.path.join(HERE, '..', '..'))
sys.path.insert(0, os.path.join(ROOT, 'scripts/mapper'))
import render  # noqa: E402

OTB = os.path.join(ROOT, 'core/server/data/items/items.otb')
DAT = os.path.join(ROOT, 'core/client-legacy/data/things/data.dat')
SPR = os.path.join(ROOT, 'core/client-legacy/data/things/data.spr')
OUT = os.path.join(ROOT, 'core/client-redemption/pokeverse-modern/data/images/pokeverse-ui')

# name: (server item id, first row of the written name in the 32x32 sprite)
ICONS = {
    'inv-order': (7730, 22),
    'inv-pokedex': (12281, 24),
    'inv-badges-kanto': (12280, 23),
    'inv-badges-orange': (18623, 23),
}


def main():
    r = render.Renderer(OTB, DAT, SPR)
    for name, (server_id, text_row) in ICONS.items():
        img = r.render({(1, 1, 7): [server_id]}, 0, 0, 1, 1, 7, upper=False, background=(0, 0, 0, 0))
        img = img.crop((img.width - 32, img.height - 32, img.width, img.height - 32 + text_row))
        img = img.crop(img.getbbox())
        img.save(os.path.join(OUT, name + '.png'))
        print(name, img.size)


if __name__ == '__main__':
    main()
