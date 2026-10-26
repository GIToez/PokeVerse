"""The Mega bar and button on the HUD (game_pokehud/mega.lua, docs/concepts/mega-gauge-hud.png).
The fills reuse the shape of fill-energy.png in the three Mega colours: purple while charging, gold when
full, green while Mega Evolved. The symbol is a rainbow Key Stone ring; the round button comes off, ready
(gold) and active (green). Run from the repository root:

    python3 scripts/art/mega_hud_art.py
"""
import math
import os

from PIL import Image, ImageDraw

OUT = 'core/client-redemption/pokeverse-modern/modules/game_pokehud/images'
S = 8  # drawn this many times larger, then scaled down

FILLS = {
    'fill-mega-charge': ((206, 120, 255), (124, 46, 196)),
    'fill-mega-full': ((255, 226, 120), (232, 160, 30)),
    'fill-mega-active': ((140, 255, 170), (40, 196, 104)),
}

RAINBOW = [(255, 92, 92), (255, 170, 60), (255, 232, 80), (110, 220, 110), (80, 170, 255), (178, 110, 255)]
NAVY = (10, 20, 40, 255)
WHITE = (255, 255, 255, 255)

BUTTONS = {
    'mega-button-off': ((96, 104, 118, 255), 0.45),
    'mega-button-ready': ((250, 200, 64, 255), 1.0),
    'mega-button-active': ((96, 236, 140, 255), 1.0),
}


def fill(name, top, bottom):
    mask = Image.open(os.path.join(OUT, 'fill-energy.png')).convert('RGBA')
    width, height = mask.size
    out = Image.new('RGBA', mask.size)
    for y in range(height):
        t = y / (height - 1)
        colour = tuple(round(a + (b - a) * t) for a, b in zip(top, bottom))
        for x in range(width):
            out.putpixel((x, y), colour + (mask.getpixel((x, y))[3],))
    out.save(os.path.join(OUT, name + '.png'))


def symbol(size, dim=1.0):
    """The Key Stone: a ring of six colours around a white helix on navy."""
    big = size * S
    img = Image.new('RGBA', (big, big), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    box = (S * 0.3, S * 0.3, big - S * 0.3, big - S * 0.3)
    d.ellipse(box, fill=NAVY)
    for i, colour in enumerate(RAINBOW):
        c = tuple(round(v * dim + 60 * (1 - dim)) for v in colour) + (255,)
        d.pieslice(box, i * 60 - 90, (i + 1) * 60 - 90, fill=c)
    inner = big * 0.22
    d.ellipse((inner, inner, big - inner, big - inner), fill=NAVY)
    centre, radius = big / 2, big / 2 - inner - S * 0.4
    white = tuple(round(v * dim + 60 * (1 - dim)) for v in WHITE[:3]) + (255,)
    for strand in (0, math.pi):
        points = []
        for step in range(25):
            t = step / 24
            y = centre - radius + 2 * radius * t
            x = centre + math.sin(t * 2 * math.pi + strand) * radius * 0.55
            points.append((x, y))
        d.line(points, fill=white, width=max(2, round(S * 0.9)))
    return img


def button(name, ring, dim):
    size = 18
    big = size * S
    img = Image.new('RGBA', (big, big), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    d.ellipse((0, 0, big - 1, big - 1), fill=ring)
    d.ellipse((S * 1.6, S * 1.6, big - S * 1.6, big - S * 1.6), fill=NAVY)
    icon = symbol(12, dim)
    offset = (big - icon.width) // 2
    img.alpha_composite(icon, (offset, offset))
    img.resize((size, size), Image.LANCZOS).save(os.path.join(OUT, name + '.png'))


def main():
    for name, (top, bottom) in FILLS.items():
        fill(name, top, bottom)
    symbol(11).resize((11, 11), Image.LANCZOS).save(os.path.join(OUT, 'mega.png'))
    for name, (ring, dim) in BUTTONS.items():
        button(name, ring, dim)

    preview = Image.new('RGBA', (11 + 18 * 3 + 12 * 3 + 40, 20), (20, 28, 44, 255))
    x = 2
    for name in ['mega', 'mega-button-off', 'mega-button-ready', 'mega-button-active'] + list(FILLS):
        part = Image.open(os.path.join(OUT, name + '.png'))
        preview.alpha_composite(part, (x, (20 - part.height) // 2))
        x += part.width + 6
    preview.resize((preview.width * 8, preview.height * 8), Image.NEAREST).save('/tmp/mega_hud_preview.png')


if __name__ == '__main__':
    main()
