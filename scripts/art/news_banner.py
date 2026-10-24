"""Art for the news banner (game_newsbanner): the Poke Ball and its two halves, the glow, the banner
frame and the category icons. Run from the repository root:

    python3 scripts/art/news_banner.py

The frame is drawn white where the category colour goes (image-color tints it in the client), and
the dark fill is a separate image so the tint doesn't touch it.
"""
import math
import os

from PIL import Image, ImageDraw, ImageFilter

OUT = 'core/client-redemption/pokeverse-modern/modules/game_newsbanner/images'
S = 4  # drawn this many times larger, then scaled down

CATEGORIES = {
    'event': ((255, 196, 46), 'star'),
    'legendary': ((186, 120, 255), 'spark'),
    'server': ((255, 84, 84), 'wrench'),
    'staff': ((84, 168, 255), 'megaphone'),
    'milestone': ((96, 220, 120), 'trophy'),
    'tip': ((190, 196, 210), 'bulb'),
    'news': ((120, 200, 230), 'scroll'),
}

INK = (28, 28, 34, 255)


def save(im, name, size=None):
    if size:
        im = im.resize(size, Image.LANCZOS)
    else:
        im = im.resize((im.width // S, im.height // S), Image.LANCZOS)
    im.save(os.path.join(OUT, name + '.png'))


def pokeball(r, pad=2):
    size = (2 * r + 2 * pad) * S
    im = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    c = size / 2
    rr = r * S
    box = (c - rr, c - rr, c + rr, c + rr)
    d.ellipse(box, fill=(245, 245, 245, 255))
    d.pieslice(box, 180, 360, fill=(228, 52, 30, 255))
    d.ellipse((c - rr * 0.62, c - rr * 0.78, c - rr * 0.18, c - rr * 0.42), fill=(255, 140, 120, 200))
    band = rr * 0.16
    d.rectangle((c - rr, c - band, c + rr, c + band), fill=INK)
    d.ellipse(box, outline=INK, width=int(2.5 * S))
    d.ellipse((c - rr * 0.34, c - rr * 0.34, c + rr * 0.34, c + rr * 0.34), fill=INK)
    d.ellipse((c - rr * 0.22, c - rr * 0.22, c + rr * 0.22, c + rr * 0.22), fill=(250, 250, 250, 255))
    return im


def glow(size):
    s = size * S
    im = Image.new('RGBA', (s, s), (255, 255, 255, 0))
    px = im.load()
    c = s / 2
    for y in range(s):
        for x in range(s):
            t = math.hypot(x - c, y - c) / c
            if t < 1:
                px[x, y] = (255, 255, 255, int(255 * (1 - t) ** 2))
    return im


def ring(size, width):
    s = size * S
    im = Image.new('RGBA', (s, s), (0, 0, 0, 0))
    ImageDraw.Draw(im).ellipse((width * S, width * S, s - width * S, s - width * S), outline=(255, 255, 255, 255),
                               width=width * S)
    return im.filter(ImageFilter.GaussianBlur(S * 0.6))


def shimmer(w, h):
    im = Image.new('RGBA', (w * S, h * S), (255, 255, 255, 0))
    px = im.load()
    for y in range(h * S):
        for x in range(w * S):
            # a slanted band, brightest in the middle
            u = (x - (w * S) / 2 + (y - (h * S) / 2) * 0.45) / (w * S / 2)
            if abs(u) < 1:
                px[x, y] = (255, 255, 255, int(70 * (1 - abs(u)) ** 1.5))
    return im


def sparkle(size):
    s = size * S
    im = Image.new('RGBA', (s, s), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    c = s / 2
    d.polygon([(c, 0), (c + s * 0.14, c), (c, s), (c - s * 0.14, c)], fill=(255, 255, 255, 255))
    d.polygon([(0, c), (c, c + s * 0.14), (s, c), (c, c - s * 0.14)], fill=(255, 255, 255, 255))
    return im


def frame(w, h, radius, edge):
    """The banner's outline (white, tinted in game) and its dark glass fill, both 9-sliced."""
    fill = Image.new('RGBA', (w * S, h * S), (0, 0, 0, 0))
    d = ImageDraw.Draw(fill)
    d.rounded_rectangle((0, 0, w * S - 1, h * S - 1), radius * S, fill=(16, 24, 44, 236))
    d.rounded_rectangle((3 * S, 3 * S, w * S - 4 * S, h * S * 0.45), (radius - 3) * S, fill=(40, 50, 74, 236))
    outline = Image.new('RGBA', (w * S, h * S), (0, 0, 0, 0))
    ImageDraw.Draw(outline).rounded_rectangle((0, 0, w * S - 1, h * S - 1), radius * S, outline=(255, 255, 255, 255),
                                              width=edge * S)
    return fill, outline


def shadow(w, h, radius):
    pad = 8
    im = Image.new('RGBA', ((w + 2 * pad) * S, (h + 2 * pad) * S), (0, 0, 0, 0))
    ImageDraw.Draw(im).rounded_rectangle((pad * S, (pad + 2) * S, (w + pad) * S, (h + pad + 2) * S), radius * S,
                                         fill=(0, 0, 0, 130))
    return im.filter(ImageFilter.GaussianBlur(4 * S))


def icon(kind, color, size):
    s = size * S
    im = Image.new('RGBA', (s, s), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    c = s / 2
    col = color + (255,)
    dark = (20, 26, 44, 255)
    if kind == 'star':
        pts = []
        for i in range(10):
            a = -math.pi / 2 + i * math.pi / 5
            rad = s * 0.48 if i % 2 == 0 else s * 0.21
            pts.append((c + rad * math.cos(a), c + 0.04 * s + rad * math.sin(a)))
        d.polygon(pts, fill=col)
    elif kind == 'spark':
        for a, length in ((0, 0.48), (math.pi / 2, 0.48), (math.pi / 4, 0.3), (3 * math.pi / 4, 0.3)):
            for sgn in (1, -1):
                x, y = c + sgn * length * s * math.cos(a), c + sgn * length * s * math.sin(a)
                ox, oy = 0.09 * s * math.cos(a + math.pi / 2), 0.09 * s * math.sin(a + math.pi / 2)
                d.polygon([(c + ox, c + oy), (x, y), (c - ox, c - oy)], fill=col)
        d.ellipse((c - s * 0.1, c - s * 0.1, c + s * 0.1, c + s * 0.1), fill=(255, 255, 255, 255))
    elif kind == 'wrench':
        d.line((s * 0.22, s * 0.8, s * 0.6, s * 0.42), fill=col, width=int(s * 0.17))
        d.ellipse((s * 0.48, s * 0.1, s * 0.9, s * 0.52), fill=col)
        d.ellipse((s * 0.64, s * 0.2, s * 0.8, s * 0.36), fill=dark)
        d.polygon([(s * 0.7, s * 0.06), (s * 0.94, s * 0.06), (s * 0.94, s * 0.3), (s * 0.74, s * 0.28)], fill=(0, 0, 0, 0))
    elif kind == 'megaphone':
        d.polygon([(s * 0.14, s * 0.36), (s * 0.38, s * 0.36), (s * 0.84, s * 0.12), (s * 0.84, s * 0.88),
                   (s * 0.38, s * 0.64), (s * 0.14, s * 0.64)], fill=col)
        d.rectangle((s * 0.24, s * 0.62, s * 0.37, s * 0.86), fill=col)
    elif kind == 'trophy':
        d.pieslice((s * 0.22, s * -0.02, s * 0.78, s * 0.6), 0, 180, fill=col)
        d.rectangle((s * 0.22, s * 0.08, s * 0.78, s * 0.3), fill=col)
        d.rectangle((s * 0.44, s * 0.56, s * 0.56, s * 0.76), fill=col)
        d.rectangle((s * 0.28, s * 0.76, s * 0.72, s * 0.9), fill=col)
        d.arc((s * 0.04, s * 0.1, s * 0.36, s * 0.44), 90, 270, fill=col, width=int(s * 0.08))
        d.arc((s * 0.64, s * 0.1, s * 0.96, s * 0.44), 270, 90, fill=col, width=int(s * 0.08))
    elif kind == 'bulb':
        d.ellipse((s * 0.18, s * 0.02, s * 0.82, s * 0.64), fill=col)
        d.rectangle((s * 0.35, s * 0.54, s * 0.65, s * 0.8), fill=col)
        d.rectangle((s * 0.4, s * 0.83, s * 0.6, s * 0.94), fill=col)
        d.line((s * 0.42, s * 0.66, s * 0.58, s * 0.66), fill=dark, width=int(s * 0.05))
    elif kind == 'scroll':
        d.rounded_rectangle((s * 0.16, s * 0.12, s * 0.84, s * 0.88), s * 0.08, fill=col)
        for y in (0.32, 0.5, 0.68):
            d.line((s * 0.28, s * y, s * 0.72, s * y), fill=dark, width=int(s * 0.07))
    return im


def badge(size, edge):
    s = size * S
    im = Image.new('RGBA', (s, s), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    d.ellipse((0, 0, s - 1, s - 1), fill=(255, 255, 255, 52), outline=(255, 255, 255, 255), width=edge * S)
    return im


def rail(w, h):
    im = Image.new('RGBA', (w * S, h * S), (0, 0, 0, 0))
    ImageDraw.Draw(im).rounded_rectangle((0, 0, w * S - 1, h * S - 1), w * S // 2, fill=(255, 255, 255, 95))
    return im


def button(w, h):
    im = Image.new('RGBA', (w * S, h * S), (0, 0, 0, 0))
    ImageDraw.Draw(im).rounded_rectangle((0, 0, w * S - 1, h * S - 1), h * S // 2, fill=(255, 255, 255, 30),
                                         outline=(255, 255, 255, 150), width=S)
    return im


def main():
    os.makedirs(OUT, exist_ok=True)
    ball = pokeball(21)
    save(ball, 'ball')
    side = ball.rotate(90, resample=Image.BICUBIC)  # seam upright, red half on the left
    save(side.crop((0, 0, side.width // 2, side.height)), 'half_left')
    save(side.crop((side.width // 2, 0, side.width, side.height)), 'half_right')
    save(glow(96), 'glow')
    save(ring(96, 3), 'ring')
    save(shimmer(56, 60), 'shimmer')
    save(sparkle(14), 'sparkle')
    fill, outline = frame(48, 48, 12, 2)
    save(fill, 'fill')
    save(outline, 'edge')
    save(shadow(48, 48, 12), 'shadow')
    save(badge(38, 2), 'badge')
    save(rail(6, 40), 'rail')
    save(button(24, 20), 'button')
    for name, (color, kind) in CATEGORIES.items():
        save(icon(kind, color, 22), 'icon_' + name)


if __name__ == '__main__':
    main()
