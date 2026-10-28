"""The Warp Styles pieces (game_warpfx, docs/upcoming-features.md section 28): the warp pad, the light
streak, the beam and its scan line, sparkles, the victory burst, confetti and badge glint, the dizzy star,
the rain cloud and its drops, the faint orb, the Poke Ball (shut and open) and its red light, the
firework sparks, the trophy, the sweat drop and the gloom lines. Run from the repository root:

    python3 scripts/art/warp_fx_art.py
"""
import math
import os

from PIL import Image, ImageDraw

OUT = 'core/client-redemption/pokeverse-modern/modules/game_warpfx/images'
S = 4  # drawn this many times larger, then scaled down


def glow(w, h, colour, falloff=2.0):
    img = Image.new('RGBA', (w, h), (0, 0, 0, 0))
    cx, cy = (w - 1) / 2, (h - 1) / 2
    for y in range(h):
        for x in range(w):
            d = math.hypot((x - cx) / max(1, cx), (y - cy) / max(1, cy))
            a = max(0.0, 1 - d) ** falloff
            img.putpixel((x, y), colour + (round(255 * a),))
    return img


def star(size, points, inner, colour, outline=None):
    big = size * S
    img = Image.new('RGBA', (big, big), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    c = big / 2
    poly = []
    for i in range(points * 2):
        r = c * 0.96 if i % 2 == 0 else c * inner
        a = -math.pi / 2 + i * math.pi / points
        poly.append((c + math.cos(a) * r, c + math.sin(a) * r))
    d.polygon(poly, fill=colour + (255,), outline=outline and outline + (255,), width=S * 2 if outline else 0)
    return img.resize((size, size), Image.LANCZOS)


def pad():
    """The warp pad under the trainer's feet: a flat cyan ring with a bright rim."""
    w, h = 64, 24
    big = Image.new('RGBA', (w * S, h * S), (0, 0, 0, 0))
    d = ImageDraw.Draw(big)
    d.ellipse([0, 0, w * S - 1, h * S - 1], fill=(70, 200, 255, 90), outline=(190, 245, 255, 255), width=3 * S)
    d.ellipse([w * S * 0.22, h * S * 0.22, w * S * 0.78, h * S * 0.78], outline=(120, 225, 255, 200), width=2 * S)
    img = big.resize((w, h), Image.LANCZOS)
    img.alpha_composite(glow(w, h, (210, 250, 255), 2.5))
    return img


def streak():
    """A tall column of light, white in the middle, fading at both ends."""
    w, h = 16, 96
    img = Image.new('RGBA', (w, h), (0, 0, 0, 0))
    for y in range(h):
        v = math.sin(math.pi * y / (h - 1)) ** 0.6
        for x in range(w):
            u = 1 - abs(x - (w - 1) / 2) / ((w - 1) / 2)
            core = u ** 3
            col = tuple(round(a + (255 - a) * core) for a in (90, 210, 255))
            img.putpixel((x, y), col + (round(255 * v * u ** 1.5),))
    return img


def beam():
    """The Premium beam: a gold-and-white column with soft edges."""
    w, h = 40, 128
    img = Image.new('RGBA', (w, h), (0, 0, 0, 0))
    for y in range(h):
        v = min(1.0, y / (h * 0.25)) * (0.55 + 0.45 * (y / (h - 1)))
        for x in range(w):
            u = 1 - abs(x - (w - 1) / 2) / ((w - 1) / 2)
            core = u ** 4
            col = tuple(round(a + (255 - a) * core) for a in (255, 200, 80))
            img.putpixel((x, y), col + (round(200 * v * u ** 1.2),))
    return img


def scanline():
    w, h = 64, 6
    img = Image.new('RGBA', (w, h), (0, 0, 0, 0))
    for y in range(h):
        v = 1 - abs(y - (h - 1) / 2) / ((h - 1) / 2)
        for x in range(w):
            u = 1 - abs(x - (w - 1) / 2) / ((w - 1) / 2)
            img.putpixel((x, y), (255, 245, 200, round(255 * v * min(1, u * 3))))
    return img


def sparkle():
    img = star(16, 4, 0.2, (255, 255, 255))
    img.alpha_composite(glow(16, 16, (255, 240, 180), 3.0))
    return img


def burst():
    """The victory burst: gold rays around a bright middle."""
    size = 96
    big = Image.new('RGBA', (size * S, size * S), (0, 0, 0, 0))
    d = ImageDraw.Draw(big)
    c = size * S / 2
    for i in range(12):
        a = i * math.pi / 6
        r = c * (0.98 if i % 2 == 0 else 0.7)
        tip = (c + math.cos(a) * r, c + math.sin(a) * r)
        s1 = (c + math.cos(a + 0.12) * c * 0.2, c + math.sin(a + 0.12) * c * 0.2)
        s2 = (c + math.cos(a - 0.12) * c * 0.2, c + math.sin(a - 0.12) * c * 0.2)
        d.polygon([tip, s1, s2], fill=(255, 215, 90, 210))
    img = big.resize((size, size), Image.LANCZOS)
    img.alpha_composite(glow(size, size, (255, 250, 220), 1.6))
    return img


CONFETTI = [(255, 90, 90), (90, 200, 255), (255, 220, 70), (120, 230, 120)]


def confetti(i):
    img = Image.new('RGBA', (8, 8), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    col = CONFETTI[i] + (255,)
    if i % 2 == 0:
        d.rectangle([1, 2, 6, 5], fill=col)
    else:
        d.polygon([(4, 0), (7, 4), (4, 7), (0, 4)], fill=col)
    return img


def glint():
    """A badge glint: a gold eight-point star."""
    img = star(24, 8, 0.4, (255, 215, 80), (255, 250, 210))
    img.alpha_composite(glow(24, 24, (255, 255, 230), 3.5))
    return img


def dizzy():
    return star(14, 5, 0.45, (255, 230, 90), (255, 255, 255))


def cloud():
    w, h = 56, 28
    big = Image.new('RGBA', (w * S, h * S), (0, 0, 0, 0))
    d = ImageDraw.Draw(big)
    for x, y, r in [(16, 17, 9), (27, 12, 11), (39, 16, 9), (24, 20, 8), (34, 20, 8)]:
        d.ellipse([(x - r) * S, (y - r) * S, (x + r) * S, (y + r) * S], fill=(110, 115, 130, 235))
    for x, y, r in [(25, 9, 6), (36, 13, 4)]:
        d.ellipse([(x - r) * S, (y - r) * S, (x + r) * S, (y + r) * S], fill=(150, 155, 170, 235))
    return big.resize((w, h), Image.LANCZOS)


def drop():
    w, h = 4, 10
    big = Image.new('RGBA', (w * S, h * S), (0, 0, 0, 0))
    d = ImageDraw.Draw(big)
    d.ellipse([0, h * S * 0.4, w * S - 1, h * S - 1], fill=(120, 180, 255, 230))
    d.polygon([(w * S / 2, 0), (0, h * S * 0.7), (w * S - 1, h * S * 0.7)], fill=(120, 180, 255, 230))
    return big.resize((w, h), Image.LANCZOS)


def orb():
    """The faint orb: a soft red-and-white ball of light."""
    size = 32
    img = glow(size, size, (255, 140, 150), 0.8)
    img.alpha_composite(glow(size, size, (255, 255, 255), 1.6))
    img.alpha_composite(glow(size, size, (255, 255, 255), 1.6))
    return img


def pokeball(opened):
    """A Poke Ball seen a little from above, shaded; opened: the red top lifted and tipped back."""
    size = 24
    big = Image.new('RGBA', (size * S, size * S), (0, 0, 0, 0))
    d = ImageDraw.Draw(big)
    cx, r = size * S / 2, size * S * (0.34 if opened else 0.42)
    lift = size * S * 0.22 if opened else 0
    cy = cx + lift * 0.7
    box = [cx - r, cy - r, cx + r, cy + r]
    d.ellipse(box, fill=(250, 250, 250, 255), outline=(30, 30, 40, 255), width=S * 2)
    d.pieslice([box[0] + S, box[1] + S, box[2] - S, box[3] - S], 90, 180, fill=(205, 205, 215, 255))
    if opened:
        d.ellipse([cx - r * 0.8, cy - r * 0.35, cx + r * 0.8, cy + r * 0.35], fill=(255, 250, 225, 255),
                  outline=(30, 30, 40, 255), width=S)
    top = [box[0], box[1] - lift, box[2], box[3] - lift]
    d.chord(top, 180, 360, fill=(225, 45, 50, 255), outline=(30, 30, 40, 255), width=S * 2)
    d.chord([top[0] + r * 0.25, top[1] + r * 0.2, top[2] - r * 0.6, top[3] - r * 1.1], 180, 300, fill=(255, 140, 140, 255))
    if not opened:
        d.rectangle([box[0], cy - S * 1.5, box[2], cy + S * 1.5], fill=(30, 30, 40, 255))
        d.ellipse([cx - r * 0.32, cy - r * 0.32, cx + r * 0.32, cy + r * 0.32], fill=(30, 30, 40, 255))
        d.ellipse([cx - r * 0.2, cy - r * 0.2, cx + r * 0.2, cy + r * 0.2], fill=(255, 255, 255, 255))
    return big.resize((size, size), Image.LANCZOS)


def redray():
    """The capture light: a red ray, bright in the middle, lying flat (rotated in the game)."""
    w, h = 64, 14
    img = Image.new('RGBA', (w, h), (0, 0, 0, 0))
    for y in range(h):
        v = 1 - abs(y - (h - 1) / 2) / ((h - 1) / 2)
        for x in range(w):
            u = min(1.0, x / 6, (w - 1 - x) / 6)
            core = v ** 3
            col = (255, round(60 + 180 * core), round(70 + 170 * core))
            img.putpixel((x, y), col + (round(235 * v ** 1.3 * u),))
    return img


SPARKS = [(255, 110, 120), (120, 220, 255), (255, 225, 90)]


def spark(i):
    img = glow(12, 12, SPARKS[i], 0.6)
    img.alpha_composite(glow(12, 12, SPARKS[i], 0.9))
    img.alpha_composite(glow(12, 12, (255, 255, 255), 2.0))
    return img


def trophy():
    """A gold cup on a dark base, with a shine down its left side."""
    w, h = 28, 32
    big = Image.new('RGBA', (w * S, h * S), (0, 0, 0, 0))
    d = ImageDraw.Draw(big)
    gold, dark, line = (255, 200, 60, 255), (200, 140, 30, 255), (90, 55, 10, 255)
    k = S
    d.arc([1 * k, 4 * k, 11 * k, 16 * k], 90, 270, fill=line, width=3 * k)
    d.arc([17 * k, 4 * k, 27 * k, 16 * k], 270, 90, fill=line, width=3 * k)
    d.pieslice([4 * k, -6 * k, 24 * k, 20 * k], 0, 180, fill=gold, outline=line, width=k)
    d.rectangle([4 * k, 2 * k, 24 * k, 7 * k], fill=gold, outline=line, width=k)
    d.polygon([(12 * k, 19 * k), (16 * k, 19 * k), (17 * k, 25 * k), (11 * k, 25 * k)], fill=dark, outline=line)
    d.rectangle([7 * k, 25 * k, 21 * k, 31 * k], fill=(110, 70, 40, 255), outline=line, width=k)
    d.rectangle([10 * k, 27 * k, 18 * k, 29 * k], fill=gold)
    d.line([(8 * k, 4 * k), (9 * k, 13 * k)], fill=(255, 250, 210, 255), width=2 * k)
    return big.resize((w, h), Image.LANCZOS)


def sweat():
    """The anime sweat drop: big, pale blue, with a white shine."""
    w, h = 14, 22
    big = Image.new('RGBA', (w * S, h * S), (0, 0, 0, 0))
    d = ImageDraw.Draw(big)
    edge, fill = (40, 90, 170, 255), (170, 215, 255, 245)
    d.ellipse([1 * S, 8 * S, 13 * S, 21 * S], fill=fill, outline=edge, width=S)
    d.polygon([(7 * S, 0), (1.6 * S, 13 * S), (12.4 * S, 13 * S)], fill=fill)
    d.line([(7 * S, 0), (1.4 * S, 13.5 * S)], fill=edge, width=S)
    d.line([(7 * S, 0), (12.6 * S, 13.5 * S)], fill=edge, width=S)
    d.ellipse([4 * S, 12 * S, 7 * S, 17 * S], fill=(255, 255, 255, 255))
    return big.resize((w, h), Image.LANCZOS)


def gloom():
    """The gloom lines over a defeated head: dark blue-violet strokes fading down."""
    w, h = 40, 28
    img = Image.new('RGBA', (w, h), (0, 0, 0, 0))
    for i, x0 in enumerate(range(3, w - 2, 5)):
        length = h - (i % 3) * 4
        for y in range(length):
            a = (1 - y / length) ** 0.8
            for x in (x0, x0 + 1):
                img.putpixel((x, y), (70, 60, 140, round(220 * a)))
    return img


def main():
    os.makedirs(OUT, exist_ok=True)
    pieces = {
        'pad': pad(), 'streak': streak(), 'beam': beam(), 'scanline': scanline(), 'sparkle': sparkle(),
        'burst': burst(), 'glint': glint(), 'star': dizzy(), 'cloud': cloud(), 'drop': drop(), 'orb': orb(),
        'pokeball': pokeball(False), 'pokeball-open': pokeball(True), 'redray': redray(), 'trophy': trophy(),
        'sweat': sweat(), 'gloom': gloom(),
    }
    for i in range(4):
        pieces['confetti-%d' % i] = confetti(i)
    for i in range(len(SPARKS)):
        pieces['spark-%d' % i] = spark(i)
    for name, img in pieces.items():
        img.save(os.path.join(OUT, name + '.png'))
    print('wrote %d images to %s' % (len(pieces), OUT))


if __name__ == '__main__':
    main()
