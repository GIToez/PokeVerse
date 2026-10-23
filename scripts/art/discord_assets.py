#!/usr/bin/env python3
"""Draws the Discord server's icon, banner and invite background.

    scripts/art/discord_assets.py [--out build/discord]

<out>/icon.png              512x512, the client's Poke Ball over the night sky; Discord crops it to a circle
<out>/banner.png            960x540, the login scene with the PokeVerse logo
<out>/invite-splash.png     1920x1080, the login scene with the logo and the tagline

The art is the client's: the login scene (login-scene-base.png), the client icon and the logo.
"""
import argparse
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter

from itch_assets import BG, GOLD, ROOT, TAGLINE, fade, glow, logo, shadowed_text

SCENE = ROOT / 'scripts/art/login-scene-base.png'
BALL = ROOT / 'core/client-redemption/data/images/clienticon.png'

ICON = 512
BANNER = (960, 540)
SPLASH = (1920, 1080)


def scene(size):
    """The login scene at size; it's pixel art at 16:9, so it scales by whole steps."""
    return Image.open(SCENE).convert('RGBA').resize(size, Image.NEAREST)


def make_icon():
    # the sky above the river, around the moon
    sky = Image.open(SCENE).convert('RGBA').crop((40, 0, 280, 240)).resize((ICON, ICON), Image.NEAREST)
    sky = sky.filter(ImageFilter.GaussianBlur(6))
    img = Image.new('RGBA', (ICON, ICON), BG + (255,))
    img.alpha_composite(sky)
    ball = Image.open(BALL).convert('RGBA').resize((360, 360), Image.LANCZOS)
    xy = ((ICON - ball.width) // 2, (ICON - ball.height) // 2)
    halo = Image.new('RGBA', img.size, (0, 0, 0, 0))
    ImageDraw.Draw(halo).ellipse((xy[0] - 10, xy[1] - 10, xy[0] + ball.width + 6, xy[1] + ball.height + 6),
                                 fill=GOLD + (120,))
    img.alpha_composite(halo.filter(ImageFilter.GaussianBlur(22)))
    img.alpha_composite(ball, xy)
    return img.convert('RGB')


def make_banner(out):
    img = fade(scene(BANNER), top=150, color=BG)
    mark = logo(460)
    glow(img, mark, ((BANNER[0] - mark.width) // 2, 22), radius=18)
    return img.convert('RGB')


def make_splash(out):
    img = fade(scene(SPLASH), top=320, bottom=220, color=BG)
    mark = logo(820)
    glow(img, mark, ((SPLASH[0] - mark.width) // 2, 50), radius=28)
    shadowed_text(img, (SPLASH[0] // 2, SPLASH[1] - 70), TAGLINE.upper(), 56, out, fill=GOLD, anchor='ms')
    return img.convert('RGB')


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--out', default=str(ROOT / 'build/discord'))
    args = ap.parse_args()
    out = Path(args.out)
    out.mkdir(parents=True, exist_ok=True)
    make_icon().save(out / 'icon.png', optimize=True)
    make_banner(out).save(out / 'banner.png', optimize=True)
    make_splash(out).save(out / 'invite-splash.png', optimize=True)
    for name in ('icon.png', 'banner.png', 'invite-splash.png'):
        print(out / name, Image.open(out / name).size)


if __name__ == '__main__':
    main()
