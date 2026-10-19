#!/usr/bin/env python3
"""Draws the itch.io page's cover, banner and background.

    scripts/art/itch_assets.py [--out build/itch] [--shot <screenshot>] [--art <illustration>...]

The background and the banner are the world map the client release renders
(scripts/mapper/render_pokepedia.py, build/map-pictures); render it first. The covers are a game
screenshot (--shot) and any illustrations (--art), each with the PokeVerse logo and the tagline.

<out>/cover.png             630x500, from --shot
<out>/cover-art-<n>.png     630x500, one per --art
<out>/banner.png            960x280, Kanto across the page's column, the logo on the left
<out>/background.png        1920x1080, the whole world, dark and soft behind the page's column

The colours are the page's: BG #101820, BG 2 #192735, links #FFCB05. The text is Lato
(<out>/fonts or the system's; without it, DejaVu Sans).
"""
import argparse
import os
import sys
from pathlib import Path

from PIL import Image, ImageDraw, ImageEnhance, ImageFilter, ImageFont

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'scripts/mapper'))
import render_pokepedia as rp  # noqa: E402

LOGO = ROOT / 'core/client-redemption/pokeverse-modern/modules/client_background/images/logo.png'
WORLD = ROOT / 'build/map-pictures/world'

BG = (16, 24, 32)
BG2 = (25, 39, 53)
GOLD = (255, 203, 5)
WHITE = (245, 245, 250)
SEA = (40, 72, 160)
TAGLINE = 'Catch. Train. Battle. Explore.'

COVER = (630, 500)
BANNER = (960, 280)
BACKGROUND = (1920, 1080)

# tile boxes: x0, y0, x1, y1
KANTO = (3150, 180, 4330, 1080)
# Kanto and the east of Johto, 16:9
MAINLAND = (2420, 0, 4340, 1080)


def font(size, out):
    for path in (out / 'fonts/Lato-Black.ttf', Path('/usr/share/fonts/truetype/lato/Lato-Black.ttf')):
        if path.exists():
            return ImageFont.truetype(str(path), size)
    return ImageFont.truetype('DejaVuSans-Bold.ttf', size)


def logo(width):
    im = Image.open(LOGO)
    im.seek(0)  # an animated PNG: the first frame is the logo at rest
    im = im.convert('RGBA')
    return im.resize((width, round(im.height * width / im.width)), Image.LANCZOS)


def world(box, lod):
    """The ground floor of the world map between the tiles of box, from the lod's chunks."""
    tiles = rp.PIXELS * lod // 32
    scale = rp.PIXELS / tiles
    x0, y0, x1, y1 = box
    img = Image.new('RGBA', (round((x1 - x0) * scale), round((y1 - y0) * scale)), SEA + (255,))
    for cy in range(y0 // tiles, y1 // tiles + 1):
        for cx in range(x0 // tiles, x1 // tiles + 1):
            path = WORLD / rp.chunk_name(lod, rp.GROUND, cx, cy)
            if path.exists():
                chunk = rp.read_chunk(path)
                img.alpha_composite(chunk, (round((cx * tiles - x0) * scale), round((cy * tiles - y0) * scale)))
    return img


def cover_crop(im, size):
    """im scaled to cover size, centered."""
    w, h = size
    scale = max(w / im.width, h / im.height)
    im = im.resize((round(im.width * scale), round(im.height * scale)), Image.LANCZOS)
    x, y = (im.width - w) // 2, (im.height - h) // 2
    return im.crop((x, y, x + w, y + h))


def fade(img, top=0, bottom=0, left=0, right=0, color=BG):
    """Fades the edges of img into color over the given sizes in pixels."""
    w, h = img.size
    mask = Image.new('L', (w, h), 0)
    d = ImageDraw.Draw(mask)
    for edge, size in (('top', top), ('bottom', bottom), ('left', left), ('right', right)):
        for i in range(size):
            a = round(255 * (1 - i / size) ** 1.6)
            if edge == 'top':
                d.line((0, i, w, i), fill=a)
            elif edge == 'bottom':
                d.line((0, h - 1 - i, w, h - 1 - i), fill=a)
            elif edge == 'left':
                d.line((i, 0, i, h), fill=a)
            else:
                d.line((w - 1 - i, 0, w - 1 - i, h), fill=a)
    # the strongest edge wins where two meet
    out = img.convert('RGBA')
    out.alpha_composite(Image.composite(Image.new('RGBA', (w, h), color + (255,)), Image.new('RGBA', (w, h), (0, 0, 0, 0)), mask))
    return out


def shadowed_text(img, xy, text, size, out, fill=WHITE, anchor='la'):
    f = font(size, out)
    shadow = Image.new('RGBA', img.size, (0, 0, 0, 0))
    ImageDraw.Draw(shadow).text((xy[0] + 2, xy[1] + 3), text, font=f, fill=(0, 0, 0, 200), anchor=anchor)
    img.alpha_composite(shadow.filter(ImageFilter.GaussianBlur(3)))
    ImageDraw.Draw(img).text(xy, text, font=f, fill=fill, anchor=anchor)


def glow(img, mark, xy, radius=14, alpha=170):
    """Pastes mark at xy over a soft dark halo, so it reads on any picture."""
    halo = Image.new('RGBA', img.size, (0, 0, 0, 0))
    shape = Image.new('RGBA', mark.size, BG + (alpha,))
    shape.putalpha(mark.getchannel('A').point(lambda a: alpha if a > 0 else 0))
    halo.alpha_composite(shape, xy)
    img.alpha_composite(halo.filter(ImageFilter.GaussianBlur(radius)))
    img.alpha_composite(mark, xy)


def make_cover(picture, out):
    img = cover_crop(picture.convert('RGBA'), COVER)
    img = fade(img, top=150, bottom=120, color=BG)
    mark = logo(470)
    glow(img, mark, ((COVER[0] - mark.width) // 2, 14))
    shadowed_text(img, (COVER[0] // 2, COVER[1] - 34), TAGLINE.upper(), 30, out, fill=GOLD, anchor='ms')
    return img.convert('RGB')


def make_banner(out):
    img = world(KANTO, 16)
    img = cover_crop(img, BANNER)
    img = ImageEnhance.Brightness(img.convert('RGB')).enhance(0.8).convert('RGBA')
    img = fade(img, left=420, top=30, bottom=60)
    mark = logo(380)
    glow(img, mark, (30, (BANNER[1] - mark.height) // 2 - 18))
    shadowed_text(img, (30 + mark.width // 2, BANNER[1] - 36), TAGLINE, 24, out, fill=GOLD, anchor='ms')
    ImageDraw.Draw(img).rectangle((0, BANNER[1] - 4, BANNER[0], BANNER[1]), fill=GOLD)
    return img.convert('RGB')


def make_background(out):
    img = world(MAINLAND, 16)
    img = cover_crop(img, BACKGROUND)
    img = img.convert('RGB').filter(ImageFilter.GaussianBlur(1.5))
    img = ImageEnhance.Brightness(img).enhance(0.55)
    img = ImageEnhance.Color(img).enhance(0.8)
    # the page's column (960 wide) sits in the middle: darker there, the world shows at the sides
    img = img.convert('RGBA')
    shade = Image.new('L', BACKGROUND, 0)
    d = ImageDraw.Draw(shade)
    cx, half = BACKGROUND[0] // 2, 480
    for x in range(BACKGROUND[0]):
        dist = max(0, abs(x - cx) - half)
        d.line((x, 0, x, BACKGROUND[1]), fill=round(150 * max(0.0, 1 - dist / 220)))
    img.alpha_composite(Image.composite(Image.new('RGBA', BACKGROUND, BG + (255,)),
                                        Image.new('RGBA', BACKGROUND, (0, 0, 0, 0)), shade))
    return fade(img, bottom=260, top=60).convert('RGB')


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--out', default=str(ROOT / 'build/itch'))
    ap.add_argument('--shot', help='the game screenshot for cover.png')
    ap.add_argument('--crop', type=int, nargs=4, metavar=('L', 'T', 'R', 'B'),
                    help='the part of --shot to use, so the game panels stay out of the cover')
    ap.add_argument('--art', nargs='*', default=[], help='illustrations for cover-art-<n>.png')
    args = ap.parse_args()
    out = Path(args.out)
    out.mkdir(parents=True, exist_ok=True)
    if not any(WORLD.glob('satellite-16-*')):
        sys.exit('no world map in %s: run scripts/mapper/render_pokepedia.py --only world' % WORLD)

    make_banner(out).save(out / 'banner.png', optimize=True)
    make_background(out).save(out / 'background.png', optimize=True)
    if args.shot:
        shot = Image.open(args.shot)
        if args.crop:
            shot = shot.crop(tuple(args.crop))
        make_cover(shot, out).save(out / 'cover.png', optimize=True)
    for n, path in enumerate(args.art, 1):
        make_cover(Image.open(path), out).save(out / ('cover-art-%d.png' % n), optimize=True)
    for name in sorted(os.listdir(out)):
        if name.endswith('.png'):
            print(out / name, Image.open(out / name).size)


if __name__ == '__main__':
    main()
