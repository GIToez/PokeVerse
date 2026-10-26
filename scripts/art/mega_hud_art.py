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


GLOW_OUT = 'core/client-redemption/pokeverse-modern/modules/game_pokemoves/images/mega-glow.png'
GLOW_FRAMES = 24
GLOW_SIZE = 48  # the 40 px move slot with 4 px around it for the halo
GREEN = (125, 255, 168)


def slot_edge(points):
    """Evenly spaced points around the move slot's rounded edge (40 px, radius 9), clockwise from the top."""
    lo, hi, r = 4 * S, 44 * S, 9 * S
    straight = hi - lo - 2 * r
    arc = math.pi * r / 2
    length = 4 * (straight + arc)
    corners = [((hi - r, lo + r), -90), ((hi - r, hi - r), 0), ((lo + r, hi - r), 90), ((lo + r, lo + r), 180)]
    starts = [((lo + r, lo), (1, 0)), ((hi, lo + r), (0, 1)), ((hi - r, hi), (-1, 0)), ((lo, hi - r), (0, -1))]
    out = []
    for i in range(points):
        d = (i / points * length + straight / 2) % length
        side = int(d // (straight + arc))
        d -= side * (straight + arc)
        if d < straight:
            (x, y), (dx, dy) = starts[side]
            out.append((x + dx * d, y + dy * d))
        else:
            (cx, cy), a0 = corners[side]
            a = math.radians(a0 + (d - straight) / arc * 90)
            out.append((cx + r * math.cos(a), cy + r * math.sin(a)))
    return out


def mega_glow():
    """The boosted move: a soft green edge that pulses a little and a spark running around it."""
    from PIL import ImageFilter
    big = GLOW_SIZE * S
    path = slot_edge(240)
    strip = Image.new('RGBA', (GLOW_SIZE * GLOW_FRAMES, GLOW_SIZE), (0, 0, 0, 0))
    for frame in range(GLOW_FRAMES):
        pulse = 0.5 - 0.5 * math.cos(2 * math.pi * frame / GLOW_FRAMES)
        halo = Image.new('RGBA', (big, big), (0, 0, 0, 0))
        ImageDraw.Draw(halo).rounded_rectangle((4 * S, 4 * S, 44 * S, 44 * S), 9 * S,
                                               outline=GREEN + (round(150 + 70 * pulse),), width=3 * S)
        halo = halo.filter(ImageFilter.GaussianBlur(2.2 * S))
        img = halo.copy()
        d = ImageDraw.Draw(img)
        d.rounded_rectangle((4 * S, 4 * S, 44 * S, 44 * S), 9 * S,
                            outline=GREEN + (round(170 + 60 * pulse),), width=round(1.5 * S))
        spark = Image.new('RGBA', (big, big), (0, 0, 0, 0))
        sd = ImageDraw.Draw(spark)
        head = int(frame / GLOW_FRAMES * len(path))
        tail = 60
        for k in range(tail, -1, -1):
            x, y = path[(head - k) % len(path)]
            t = 1 - k / tail
            radius = (0.8 + 1.6 * t) * S
            colour = tuple(round(g + (255 - g) * t) for g in GREEN)
            sd.ellipse((x - radius, y - radius, x + radius, y + radius), fill=colour + (round(255 * t ** 1.5),))
        img.alpha_composite(spark.filter(ImageFilter.GaussianBlur(1.6 * S)))
        img.alpha_composite(spark)
        strip.alpha_composite(img.resize((GLOW_SIZE, GLOW_SIZE), Image.LANCZOS), (frame * GLOW_SIZE, 0))
    strip.save(GLOW_OUT)


def main():
    mega_glow()
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
