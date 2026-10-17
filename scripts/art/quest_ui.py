#!/usr/bin/env python3
"""Draws the quest log artwork (game_quests): the badges over the NPCs' name plates and the scroll
icon of the window and the notices. The top bar button is data/images/options/button_questlog
(topbar_icons.py).

    scripts/art/quest_ui.py <out dir>

The output goes to core/client-redemption/pokeverse-modern/modules/game_quests/images. The badges are
14x14 rings: gold "!" (a quest to start), grey "?" (one under way), gold "?" (one to hand in), crossed
swords (battle), coin bag (shop), ship wheel (travel), coin (bank), pink cross (heal) and egg (daycare).
"""
import math
import sys
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[2]
FONT = ROOT / 'core/client-redemption/data/fonts/ttf/arialb.ttf'
K = 16  # drawn at K times on a 14-unit grid, then shrunk

GOLD = (255, 204, 64, 255)
GOLD_DARK = (122, 78, 10, 255)
INK = (40, 26, 6, 255)
WHITE = (250, 250, 250, 255)
PAPER = (246, 226, 176, 255)
PAPER_DARK = (196, 160, 98, 255)
RED_SEAL = (200, 52, 52, 255)

BADGES = {
    # name: (ring fill, ring edge)
    'quest_available': ((255, 204, 64, 255), GOLD_DARK),
    'quest_ready': ((255, 204, 64, 255), GOLD_DARK),
    'quest_active': ((176, 184, 196, 255), (70, 76, 88, 255)),
    'battle': ((214, 64, 64, 255), (96, 18, 22, 255)),
    'shop': ((78, 184, 92, 255), (20, 80, 34, 255)),
    'travel': ((70, 140, 224, 255), (16, 50, 110, 255)),
    'bank': ((40, 168, 160, 255), (10, 74, 70, 255)),
    'heal': ((250, 140, 182, 255), (140, 40, 82, 255)),
    'daycare': ((242, 150, 64, 255), (120, 60, 14, 255)),
}


def p(points):
    return [(x * K, y * K) for x, y in points]


def ring(fill, edge, size=14):
    im = Image.new('RGBA', (size * K, size * K), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    d.ellipse((0, 0, size * K - 1, size * K - 1), fill=edge)
    d.ellipse((1.2 * K, 1.2 * K, (size - 1.2) * K, (size - 1.2) * K), fill=fill)
    # a light top half, as on the other plate icons
    shine = Image.new('RGBA', im.size, (0, 0, 0, 0))
    ImageDraw.Draw(shine).ellipse((2.4 * K, 1.8 * K, (size - 2.4) * K, 7 * K), fill=(255, 255, 255, 60))
    im.alpha_composite(shine)
    return im, d


def glyph(d, text, color, size=11.5, dy=0.0):
    font = ImageFont.truetype(str(FONT), int(size * K))
    box = d.textbbox((0, 0), text, font=font)
    w, h = box[2] - box[0], box[3] - box[1]
    d.text((7 * K - w / 2 - box[0], 7 * K - h / 2 - box[1] + dy * K), text, font=font, fill=color)


def swords(d):
    for flip in (1, -1):
        def q(x, y):
            return (7 + (x - 7) * flip, y)
        d.line(p([q(3.4, 3.4), q(9.6, 9.6)]), fill=WHITE, width=int(1.6 * K))
        d.line(p([q(8.2, 11.2), q(11.2, 8.2)]), fill=WHITE, width=int(1.3 * K))
        d.line(p([q(10.2, 10.2), q(11.4, 11.4)]), fill=WHITE, width=int(1.5 * K))


def coin_bag(d):
    d.ellipse(p([(3.4, 5.6), (10.6, 11.8)]), fill=PAPER)
    d.polygon(p([(5.2, 6.2), (8.8, 6.2), (9.6, 3.2), (4.4, 3.2)]), fill=PAPER)
    d.line(p([(5, 5.8), (9, 5.8)]), fill=PAPER_DARK, width=int(0.9 * K))
    glyph(d, '$', (40, 110, 40, 255), size=6, dy=1.8)


def wheel(d):
    c = 7 * K
    for i in range(8):
        a = i * math.pi / 4
        d.line([(c, c), (c + math.cos(a) * 5.4 * K, c + math.sin(a) * 5.4 * K)], fill=WHITE, width=int(1.1 * K))
    d.ellipse(p([(3.6, 3.6), (10.4, 10.4)]), outline=WHITE, width=int(1.2 * K))
    d.ellipse(p([(5.9, 5.9), (8.1, 8.1)]), fill=WHITE)


def coin(d):
    d.ellipse(p([(3.2, 3.2), (10.8, 10.8)]), fill=(255, 214, 90, 255), outline=GOLD_DARK, width=int(0.8 * K))
    glyph(d, '$', GOLD_DARK, size=6.4)


def cross(d):
    d.rectangle(p([(5.6, 3.2), (8.4, 10.8)]), fill=WHITE)
    d.rectangle(p([(3.2, 5.6), (10.8, 8.4)]), fill=WHITE)


def egg(d):
    d.ellipse(p([(4.2, 2.8), (9.8, 11.4)]), fill=(250, 246, 232, 255))
    for x, y in ((5.6, 6.0), (8.2, 8.0), (6.4, 9.4)):
        d.ellipse(p([(x - 0.8, y - 0.8), (x + 0.8, y + 0.8)]), fill=(96, 176, 96, 255))


def badge(name):
    im, d = ring(*BADGES[name])
    if name == 'quest_available':
        glyph(d, '!', INK)
    elif name == 'quest_ready':
        glyph(d, '?', INK)
    elif name == 'quest_active':
        glyph(d, '?', (64, 70, 82, 255))
    elif name == 'battle':
        swords(d)
    elif name == 'shop':
        coin_bag(d)
    elif name == 'travel':
        wheel(d)
    elif name == 'bank':
        coin(d)
    elif name == 'heal':
        cross(d)
    elif name == 'daycare':
        egg(d)
    return im.resize((14, 14), Image.LANCZOS)


def scroll(size, k=16):
    """A rolled parchment with a red seal, on a 34-unit grid"""
    im = Image.new('RGBA', (34 * k, 34 * k), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)

    def q(points):
        return [(x * k, y * k) for x, y in points]
    d.rounded_rectangle(q([(7, 6), (27, 29)]), radius=2 * k, fill=PAPER_DARK)
    d.rectangle(q([(8.4, 7), (25.6, 28)]), fill=PAPER)
    for y in (12, 16, 20):
        d.line(q([(11, y), (23, y)]), fill=PAPER_DARK, width=int(1.4 * k))
    for y in (4.5, 27):
        d.rounded_rectangle(q([(4, y), (30, y + 4)]), radius=2 * k, fill=(150, 104, 52, 255))
        d.rounded_rectangle(q([(5, y + 0.8), (29, y + 3.2)]), radius=1.4 * k, fill=(214, 168, 100, 255))
    d.ellipse(q([(19, 20), (26, 27)]), fill=RED_SEAL)
    d.ellipse(q([(20.6, 21.6), (24.4, 25.4)]), fill=(232, 96, 90, 255))
    return im.resize((size, size), Image.LANCZOS)


def main():
    out = Path(sys.argv[1] if len(sys.argv) > 1 else
               ROOT / 'core/client-redemption/pokeverse-modern/modules/game_quests/images')
    out.mkdir(parents=True, exist_ok=True)
    for name in BADGES:
        badge(name).save(out / ('npc_' + name + '.png'), optimize=True)
    # drawn instead of the server's static quest bubble on an NPC with nothing for the trainer
    Image.new('RGBA', (1, 1), (0, 0, 0, 0)).save(out / 'npc_none.png')
    scroll(34).save(out / 'icon_quests.png', optimize=True)
    scroll(22).save(out / 'icon_quests_small.png', optimize=True)


if __name__ == '__main__':
    main()
