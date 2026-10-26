"""The Mega Evolution animation on the map (game_megafx, docs/upcoming-features.md "The animation"):
the Key Stone sparkle, the light of the streams, the stone's glow, the swirling orb (four frames), the
shards of the burst and the Mega Evolution symbol. Run from the repository root:

    python3 scripts/art/mega_fx_art.py
"""
import math
import os
import sys

from PIL import Image, ImageDraw, ImageFilter

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from mega_hud_art import RAINBOW, symbol  # noqa: E402

OUT = 'core/client-redemption/pokeverse-modern/modules/game_megafx/images'
S = 4  # drawn this many times larger, then scaled down


def rainbow(t):
    t = t % 1.0 * len(RAINBOW)
    a, b = RAINBOW[int(t) % len(RAINBOW)], RAINBOW[(int(t) + 1) % len(RAINBOW)]
    f = t - int(t)
    return tuple(round(x + (y - x) * f) for x, y in zip(a, b))


def glow(size, colour, falloff=2.2):
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    c = (size - 1) / 2
    for y in range(size):
        for x in range(size):
            d = math.hypot(x - c, y - c) / c
            a = max(0.0, 1 - d) ** falloff
            img.putpixel((x, y), colour + (round(255 * a),))
    return img


def spark(size):
    """A four-point star, white in the middle with rainbow tips."""
    big = size * S
    img = Image.new('RGBA', (big, big), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    c = big / 2
    for i in range(4):
        angle = i * math.pi / 2
        tip = (c + math.cos(angle) * c * 0.98, c + math.sin(angle) * c * 0.98)
        side1 = (c + math.cos(angle + math.pi / 2) * c * 0.14, c + math.sin(angle + math.pi / 2) * c * 0.14)
        side2 = (c + math.cos(angle - math.pi / 2) * c * 0.14, c + math.sin(angle - math.pi / 2) * c * 0.14)
        d.polygon([tip, side1, (c, c), side2], fill=rainbow(i / 4) + (255,))
    small = img.resize((size, size), Image.LANCZOS)
    small.alpha_composite(glow(size, (255, 255, 255), 3.0))
    return small


def orb(size, frame, frames):
    """A see-through ball of energy with rainbow swirls; the frames turn the swirls."""
    big = size * S
    img = Image.new('RGBA', (big, big), (0, 0, 0, 0))
    c = big / 2
    body = glow(big, (255, 250, 235), 1.2)
    body.putalpha(body.getchannel('A').point(lambda a: round(a * 0.6)))
    img.alpha_composite(body)
    d = ImageDraw.Draw(img)
    turn = frame / frames * 2 * math.pi / 3
    for arm in range(3):
        points = []
        for step in range(40):
            t = step / 39
            angle = turn + arm * 2 * math.pi / 3 + t * 2.6
            r = c * (0.25 + 0.68 * t)
            points.append((c + math.cos(angle) * r, c + math.sin(angle) * r * 0.92))
        for i in range(len(points) - 1):
            colour = rainbow(arm / 3 + i / 80)
            width = max(2, round(S * (6.0 - 4.0 * i / len(points))))
            d.line([points[i], points[i + 1]], fill=colour + (255,), width=width)
    d.ellipse((S, S, big - S, big - S), outline=(255, 255, 255, 170), width=S * 2)
    img = img.filter(ImageFilter.GaussianBlur(S * 0.4))
    return img.resize((size, size), Image.LANCZOS)


def shard(size, index):
    big = size * S
    img = Image.new('RGBA', (big, big), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    d.polygon([(big * 0.5, 0), (big * 0.9, big * 0.62), (big * 0.35, big)], fill=rainbow(index / 6) + (255,))
    d.line([(big * 0.5, big * 0.08), (big * 0.42, big * 0.9)], fill=(255, 255, 255, 230), width=S)
    return img.resize((size, size), Image.LANCZOS)


def main():
    os.makedirs(OUT, exist_ok=True)
    spark(32).save(os.path.join(OUT, 'spark.png'))
    glow(16, (255, 248, 220), 0.9).save(os.path.join(OUT, 'stream.png'))
    glow(48, (255, 236, 170), 1.4).save(os.path.join(OUT, 'stone-glow.png'))
    for frame in range(4):
        orb(96, frame, 4).save(os.path.join(OUT, 'orb-%d.png' % frame))
    for index in range(6):
        shard(14, index).save(os.path.join(OUT, 'shard-%d.png' % index))
    symbol(40).resize((40, 40), Image.LANCZOS).save(os.path.join(OUT, 'symbol.png'))

    names = ['spark', 'stream', 'stone-glow', 'orb-0', 'orb-1', 'shard-0', 'shard-3', 'symbol']
    parts = [Image.open(os.path.join(OUT, n + '.png')) for n in names]
    preview = Image.new('RGBA', (sum(p.width for p in parts) + 8 * len(parts), 100), (30, 60, 40, 255))
    x = 4
    for part in parts:
        preview.alpha_composite(part, (x, (100 - part.height) // 2))
        x += part.width + 8
    preview.resize((preview.width * 3, preview.height * 3), Image.NEAREST).save('/tmp/mega_fx_preview.png')


if __name__ == '__main__':
    main()
