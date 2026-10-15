#!/usr/bin/env python3
"""Draws the vocation window artwork (game_vocation): the cards, the round vocation icons, the
perk bullet and the card banners, in the style of the Tasks window (tasks_ui.py).

    scripts/art/vocation_ui.py <out dir>

The output goes to core/client-redemption/pokeverse-modern/modules/game_vocation/images. The
banners are cropped from the pixel-art pictures in scripts/art/vocation-banners. The window frame
is the Tasks window's (game_dailytasks/images/window). Frames are 9-slice images: the otui sets
image-border to the border noted next to each one.
"""
import math
import sys
from pathlib import Path

from PIL import Image, ImageDraw

sys.path.insert(0, str(Path(__file__).parent))
from login_ui import canvas, save, s, rounded_mask, glow_frame, icon, draw_pokeball  # noqa: E402

GOLD = (226, 178, 62, 255)
GOLD_LIGHT = (255, 214, 90, 255)
GOLD_GLOW = (240, 190, 80)
EDGE = (46, 74, 118, 255)
NAVY = (14, 22, 40, 255)
WHITE = (236, 242, 255, 255)
SKY = (120, 200, 255, 255)

BANNERS = Path(__file__).parent / 'vocation-banners'
BANNER_SIZE = (214, 96)
VOCATIONS = ('ace', 'catcher', 'breeder', 'ranger', 'angler', 'medic')


def banner(key):
    src = Image.open(BANNERS / f'{key}.jpg').convert('RGBA')
    w, h = BANNER_SIZE
    crop_h = round(src.width * h / w)
    top = (src.height - crop_h) // 2
    im = src.crop((0, top, src.width, top + crop_h)).resize((w * 2, h * 2), Image.LANCZOS)
    mask = Image.new('L', im.size, 0)
    d = ImageDraw.Draw(mask)
    d.rounded_rectangle((0, 0, im.width - 1, im.height - 1), 12, fill=255)
    d.rectangle((0, im.height // 2, im.width - 1, im.height - 1), fill=255)
    im.putalpha(mask)
    return im.resize((w, h), Image.LANCZOS)


def medallion(draw_inner, size=34):
    im = icon(size)
    d = ImageDraw.Draw(im)
    d.ellipse((s(0.8), s(0.8), s(size - 0.8), s(size - 0.8)), fill=(16, 26, 48, 255), outline=GOLD, width=s(2))
    d.ellipse((s(3.2), s(3.2), s(size - 3.2), s(size - 3.2)), outline=(120, 92, 36, 255), width=s(0.8))
    inner = draw_inner(20)
    im.alpha_composite(inner, ((im.width - inner.width) // 2, (im.height - inner.height) // 2))
    return im


def draw_flame(size):
    im = icon(size)
    d = ImageDraw.Draw(im)
    k = size / 20

    def flame(scale, color):
        pts = []
        for i in range(40):
            t = i / 39 * 2 * math.pi
            r = 1 - 0.55 * max(0, math.sin(t)) ** 3
            x = 10 + 6.5 * scale * math.cos(t) * r
            y = 12 + 7 * scale * math.sin(t) * (1 if math.sin(t) > 0 else 1.6)
            pts.append((s(x * k), s(y * k)))
        d.polygon(pts, fill=color)

    flame(1.0, (240, 96, 40, 255))
    flame(0.62, (255, 190, 60, 255))
    flame(0.3, (255, 240, 170, 255))
    return im


def draw_net(size):
    im = icon(size)
    d = ImageDraw.Draw(im)
    k = size / 20
    d.line((s(3 * k), s(18 * k), s(10 * k), s(11 * k)), fill=(200, 150, 90, 255), width=s(2 * k))
    d.ellipse((s(8 * k), s(2 * k), s(18 * k), s(12 * k)), outline=WHITE, width=s(1.6 * k))
    for i in (1, 2):
        x = 8 + i * 10 / 3
        d.line((s(x * k), s(3 * k), s(x * k), s(11 * k)), fill=(170, 190, 220, 255), width=s(0.8 * k))
        y = 2 + i * 10 / 3
        d.line((s(9 * k), s(y * k), s(17 * k), s(y * k)), fill=(170, 190, 220, 255), width=s(0.8 * k))
    return im


def draw_egg(size):
    im = icon(size)
    d = ImageDraw.Draw(im)
    k = size / 20
    d.ellipse((s(4.5 * k), s(2 * k), s(15.5 * k), s(18.5 * k)), fill=(244, 238, 222, 255),
              outline=(190, 178, 150, 255), width=s(0.8 * k))
    for x, y, r in ((8, 8, 1.8), (12.5, 11, 1.5), (9, 14, 1.3)):
        d.ellipse((s((x - r) * k), s((y - r) * k), s((x + r) * k), s((y + r) * k)), fill=(110, 190, 120, 255))
    return im


def draw_binoculars(size):
    im = icon(size)
    d = ImageDraw.Draw(im)
    k = size / 20
    body = (90, 110, 140, 255)
    for x in (2.5, 11):
        d.rounded_rectangle((s(x * k), s(5 * k), s((x + 6.5) * k), s(12 * k)), s(1.5 * k), fill=body)
        d.ellipse((s((x - 0.5) * k), s(10 * k), s((x + 7) * k), s(17.5 * k)), fill=(60, 76, 100, 255),
                  outline=WHITE, width=s(1.2 * k))
        d.ellipse((s((x + 1.5) * k), s(12 * k), s((x + 5) * k), s(15.5 * k)), fill=SKY)
    d.rectangle((s(8.8 * k), s(7 * k), s(11.2 * k), s(11 * k)), fill=body)
    return im


def draw_hook(size):
    im = icon(size)
    d = ImageDraw.Draw(im)
    k = size / 20
    d.line((s(11 * k), s(2 * k), s(11 * k), s(12 * k)), fill=WHITE, width=s(1.8 * k))
    d.arc((s(5 * k), s(7 * k), s(13 * k), s(17 * k)), 0, 200, fill=WHITE, width=s(1.8 * k))
    d.polygon(((s(4.2 * k), s(11 * k)), (s(7.6 * k), s(9.5 * k)), (s(6.5 * k), s(13 * k))), fill=WHITE)
    d.ellipse((s(9.5 * k), s(0.8 * k), s(12.5 * k), s(3.8 * k)), outline=SKY, width=s(1.2 * k))
    return im


def draw_bandage(size):
    im = icon(size)
    k = size / 20
    band = icon(size)
    d = ImageDraw.Draw(band)
    d.rounded_rectangle((s(1.5 * k), s(6.5 * k), s(18.5 * k), s(13.5 * k)), s(3.5 * k), fill=(236, 188, 140, 255),
                        outline=(176, 124, 80, 255), width=s(0.8 * k))
    d.rectangle((s(7 * k), s(7 * k), s(13 * k), s(13 * k)), fill=(250, 236, 220, 255))
    d.rectangle((s(9.2 * k), s(7.8 * k), s(10.8 * k), s(12.2 * k)), fill=(226, 64, 64, 255))
    d.rectangle((s(7.8 * k), s(9.2 * k), s(12.2 * k), s(10.8 * k)), fill=(226, 64, 64, 255))
    band = band.rotate(-35, resample=Image.BICUBIC)
    im.alpha_composite(band)
    return im


def draw_bullet(size=10):
    im = icon(size)
    d = ImageDraw.Draw(im)
    k = size / 10
    d.polygon(((s(5 * k), s(0.5 * k)), (s(8.4 * k), s(5.6 * k)), (s(1.6 * k), s(5.6 * k))), fill=SKY)
    d.ellipse((s(1.6 * k), s(2.8 * k), s(8.4 * k), s(9.6 * k)), fill=SKY)
    d.ellipse((s(3.2 * k), s(4.6 * k), s(5 * k), s(6.4 * k)), fill=(220, 240, 255, 255))
    return im


def selected_card():
    im = glow_frame(40, 40, 8, (22, 36, 64, 245), GOLD_LIGHT, GOLD_GLOW, 4)
    return im


ICONS = {
    'ace': draw_flame, 'catcher': draw_net, 'breeder': draw_egg,
    'ranger': draw_binoculars, 'angler': draw_hook, 'medic': draw_bandage,
}


def main():
    out = Path(sys.argv[1])
    out.mkdir(parents=True, exist_ok=True)

    save(glow_frame(40, 40, 8, (18, 30, 54, 240), EDGE, None, 0), out, 'card')  # border 10
    save(glow_frame(40, 40, 8, (22, 36, 64, 245), (86, 124, 186, 255), None, 0), out, 'card_hover')  # border 10
    save(selected_card(), out, 'card_selected')  # border 14
    save(draw_pokeball(30), out, 'icon_vocation')
    save(draw_bullet(), out, 'bullet')
    for key in VOCATIONS:
        save(medallion(ICONS[key]), out, f'icon_{key}')
        banner(key).save(out / f'banner_{key}.png')


if __name__ == '__main__':
    main()
