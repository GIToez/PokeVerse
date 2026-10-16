#!/usr/bin/env python3
"""Draws the Ranger radar popup artwork (game_radar): the radar disc and its direction cone, the
blips, the player and target rings, the arrow on the game map, the minimap flag and the panels.

    scripts/art/radar_ui.py <out dir>

The output goes to core/client-redemption/pokeverse-modern/modules/game_radar/images. The window
frame is the Tasks window's (game_dailytasks/images/window). Frames are 9-slice images: the otui
sets image-border to the border noted next to each one. The cone and the map arrow point east;
the client rotates them.
"""
import math
import sys
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter

sys.path.insert(0, str(Path(__file__).parent))
from login_ui import canvas, save, s, glow_frame, icon, draw_lock  # noqa: E402

DISC = 400  # the radar widget; the client maps the range onto RADIUS pixels
RADIUS = 176
EDGE = (46, 74, 118, 255)
RING = (70, 150, 220)
YELLOW = (255, 214, 64)
CYAN = (90, 210, 255)

BLIPS = {
    'unknown': (255, 92, 92),
    'common': (255, 92, 92),
    'uncommon': (70, 160, 255),
    'rare': (190, 100, 255),
    'shiny': (120, 255, 230),
    'legendary': (255, 170, 40),
}


def blur(im, radius):
    return im.filter(ImageFilter.GaussianBlur(radius))


def disc():
    im = canvas(DISC, DISC)
    W = im.width
    c, r = W / 2, s(RADIUS)

    halo = Image.new('RGBA', im.size, RING + (0,))
    m = Image.new('L', im.size, 0)
    ImageDraw.Draw(m).ellipse((c - r - s(6), c - r - s(6), c + r + s(6), c + r + s(6)), outline=170, width=s(5))
    halo.putalpha(blur(m, s(7)))
    im.alpha_composite(halo)

    # the field: dark navy, a little lighter in the middle
    field = Image.new('RGBA', im.size, (0, 0, 0, 0))
    fd = ImageDraw.Draw(field)
    steps = 40
    for i in range(steps):
        t = i / (steps - 1)
        rr = r * (1 - t)
        col = (int(10 + 16 * t), int(22 + 26 * t), int(42 + 34 * t), 245)
        fd.ellipse((c - rr, c - rr, c + rr, c + rr), fill=col)
    im.alpha_composite(field)

    d = ImageDraw.Draw(im)
    # spokes every 30 degrees and the four range rings
    for deg in range(0, 360, 30):
        a = math.radians(deg)
        d.line((c, c, c + math.cos(a) * r, c + math.sin(a) * r), fill=RING + (38,), width=s(1))
    for k in (0.25, 0.5, 0.75):
        rr = r * k
        d.ellipse((c - rr, c - rr, c + rr, c + rr), outline=RING + (70,), width=s(1.2))
    d.line((c - r, c, c + r, c), fill=RING + (70,), width=s(1.2))
    d.line((c, c - r, c, c + r), fill=RING + (70,), width=s(1.2))

    # the bezel with ticks
    d.ellipse((c - r, c - r, c + r, c + r), outline=(110, 190, 255, 230), width=s(2.5))
    outer = r + s(9)
    d.ellipse((c - outer, c - outer, c + outer, c + outer), outline=(60, 110, 170, 150), width=s(1.2))
    for deg in range(0, 360, 10):
        a = math.radians(deg)
        long = deg % 90 == 0
        r0 = r + s(2)
        r1 = r + s(8 if long else 5)
        d.line((c + math.cos(a) * r0, c + math.sin(a) * r0, c + math.cos(a) * r1, c + math.sin(a) * r1),
               fill=(130, 200, 255, 220 if long else 120), width=s(1.6 if long else 1))
    return im


def cone():
    """A soft yellow cone from the middle of the disc towards the east."""
    im = canvas(DISC, DISC)
    W = im.width
    c, r = W / 2, s(RADIUS - 4)
    half = math.radians(13)
    m = Image.new('L', im.size, 0)
    md = ImageDraw.Draw(m)
    steps = 30
    for i in range(steps, 0, -1):
        rr = r * i / steps
        a = int(150 * (1 - i / steps) ** 0.6 + 30)
        pts = [(c, c)] + [(c + math.cos(t) * rr, c + math.sin(t) * rr)
                          for t in (-half + k * 2 * half / 12 for k in range(13))]
        md.polygon(pts, fill=a)
    fill = Image.new('RGBA', im.size, YELLOW + (0,))
    fill.putalpha(blur(m, s(1.5)))
    im.alpha_composite(fill)
    return im


def blip(color, size=14):
    im = icon(size)
    W = im.width
    c = W / 2
    glow = Image.new('RGBA', im.size, color + (0,))
    m = Image.new('L', im.size, 0)
    ImageDraw.Draw(m).ellipse((c - s(5.5), c - s(5.5), c + s(5.5), c + s(5.5)), fill=200)
    glow.putalpha(blur(m, s(1.6)))
    im.alpha_composite(glow)
    d = ImageDraw.Draw(im)
    d.ellipse((c - s(3.6), c - s(3.6), c + s(3.6), c + s(3.6)), fill=color + (255,))
    d.ellipse((c - s(1.6), c - s(2.2), c + s(0.4), c - s(0.4)), fill=(255, 255, 255, 170))
    return im


def star_blip(color, size=18, points=4):
    im = icon(size)
    W = im.width
    c = W / 2
    pts = []
    for i in range(points * 2):
        a = math.pi * i / points - math.pi / 2
        rr = s(7.5) if i % 2 == 0 else s(2.6)
        pts.append((c + math.cos(a) * rr, c + math.sin(a) * rr))
    glow = Image.new('RGBA', im.size, color + (0,))
    m = Image.new('L', im.size, 0)
    ImageDraw.Draw(m).polygon(pts, fill=230)
    glow.putalpha(blur(m, s(1.8)))
    im.alpha_composite(glow)
    d = ImageDraw.Draw(im)
    d.polygon(pts, fill=color + (255,))
    d.ellipse((c - s(1.6), c - s(1.6), c + s(1.6), c + s(1.6)), fill=(255, 255, 255, 230))
    return im


def halo(color, size=44):
    """The area a vague blip stands for."""
    im = icon(size)
    W = im.width
    c = W / 2
    m = Image.new('L', im.size, 0)
    md = ImageDraw.Draw(m)
    md.ellipse((s(3), s(3), W - s(3), W - s(3)), fill=46)
    md.ellipse((s(3), s(3), W - s(3), W - s(3)), outline=120, width=s(1))
    fill = Image.new('RGBA', im.size, color + (0,))
    fill.putalpha(blur(m, s(1)))
    im.alpha_composite(fill)
    return im


def ring(size, color, width, glow=True):
    im = icon(size)
    W = im.width
    pad = s(3)
    if glow:
        g = Image.new('RGBA', im.size, color + (0,))
        m = Image.new('L', im.size, 0)
        ImageDraw.Draw(m).ellipse((pad, pad, W - pad, W - pad), outline=230, width=s(width + 1.5))
        g.putalpha(blur(m, s(1.6)))
        im.alpha_composite(g)
    ImageDraw.Draw(im).ellipse((pad, pad, W - pad, W - pad), outline=color + (255,), width=s(width))
    return im


def center():
    im = ring(40, CYAN, 2)
    W = im.width
    d = ImageDraw.Draw(im)
    d.ellipse((s(7), s(7), W - s(7), W - s(7)), fill=(20, 44, 80, 200))
    return im


def map_arrow(size=52):
    """The arrow drawn beside the trainer on the game map; it points east."""
    im = icon(size)
    W = im.width
    c = W / 2
    k = size / 40
    pts = [(c + s(15 * k), c), (c - s(9 * k), c - s(12 * k)), (c - s(3 * k), c), (c - s(9 * k), c + s(12 * k))]
    shadow = Image.new('RGBA', im.size, (0, 0, 0, 0))
    m = Image.new('L', im.size, 0)
    ImageDraw.Draw(m).polygon([(x + s(1), y + s(1.5)) for x, y in pts], fill=170)
    shadow.putalpha(blur(m, s(1.8)))
    im.alpha_composite(shadow)
    glow = Image.new('RGBA', im.size, YELLOW + (0,))
    m = Image.new('L', im.size, 0)
    ImageDraw.Draw(m).polygon(pts, fill=200)
    glow.putalpha(blur(m, s(2.2)))
    im.alpha_composite(glow)
    d = ImageDraw.Draw(im)
    d.polygon(pts, fill=YELLOW + (255,), outline=(120, 80, 0, 255))
    d.line((pts[1], pts[2]), fill=(255, 245, 190, 255), width=s(1.2))
    return im


def flag(size=12):
    im = icon(size)
    W = im.width
    d = ImageDraw.Draw(im)
    d.ellipse((s(1), s(1), W - s(1), W - s(1)), fill=(20, 26, 40, 255))
    d.ellipse((s(2.2), s(2.2), W - s(2.2), W - s(2.2)), fill=YELLOW + (255,))
    d.ellipse((s(4.4), s(4.4), W - s(4.4), W - s(4.4)), fill=(20, 26, 40, 255))
    return im


def row(fill, edge):
    im = canvas(40, 24)
    ImageDraw.Draw(im).rounded_rectangle((s(0.5), s(0.5), im.width - s(1), im.height - s(1)), s(5),
                                         fill=fill, outline=edge, width=s(1.2))
    return im


def chevron():
    im = icon(8)
    ImageDraw.Draw(im).line(((s(2.5), s(1)), (s(5.5), s(4)), (s(2.5), s(7))), fill=(170, 190, 225, 255),
                            width=s(1.5), joint='curve')
    return im


def badge():
    im = canvas(24, 16)
    ImageDraw.Draw(im).rounded_rectangle((0, 0, im.width - 1, im.height - 1), s(4), fill=(255, 255, 255, 255))
    return im


def header_icon(size=30):
    im = icon(size)
    W = im.width
    c = W / 2
    d = ImageDraw.Draw(im)
    d.ellipse((s(2), s(2), W - s(2), W - s(2)), fill=(16, 34, 62, 255), outline=(110, 190, 255, 255), width=s(2))
    for k in (0.62, 0.3):
        rr = (W / 2 - s(2)) * k
        d.ellipse((c - rr, c - rr, c + rr, c + rr), outline=(70, 150, 220, 200), width=s(1.2))
    a = math.radians(-40)
    d.pieslice((s(4), s(4), W - s(4), W - s(4)), -70, -40, fill=YELLOW + (110,))
    d.line((c, c, c + math.cos(a) * (W / 2 - s(4)), c + math.sin(a) * (W / 2 - s(4))), fill=YELLOW + (255,),
           width=s(1.8))
    d.ellipse((c + s(4), c + s(3), c + s(7.5), c + s(6.5)), fill=(255, 92, 92, 255))
    d.ellipse((c - s(1.6), c - s(1.6), c + s(1.6), c + s(1.6)), fill=(236, 242, 255, 255))
    return im


def main():
    out = Path(sys.argv[1]) if len(sys.argv) > 1 else (
        Path(__file__).resolve().parents[2] / 'core/client-redemption/pokeverse-modern/modules/game_radar/images')
    out.mkdir(parents=True, exist_ok=True)
    save(disc(), out, 'radar')
    save(cone(), out, 'cone')
    for kind, color in BLIPS.items():
        if kind in ('shiny', 'legendary'):
            save(star_blip(color, points=4 if kind == 'shiny' else 5), out, f'blip_{kind}')
            save(halo(color), out, f'halo_{kind}')
        else:
            save(blip(color), out, f'blip_{kind}')
    save(halo(BLIPS['common']), out, 'halo_unknown')
    save(ring(26, YELLOW, 2), out, 'selected')
    save(center(), out, 'center')
    save(map_arrow(), out, 'arrow')
    save(flag(), out, 'flag')
    save(glow_frame(40, 40, 8, (14, 24, 44, 235), EDGE, None, 0), out, 'panel')  # border 10
    save(row((22, 34, 60, 230), (52, 78, 120, 255)), out, 'row')  # border 6
    save(row((30, 46, 80, 240), (86, 124, 186, 255)), out, 'row_hover')  # border 6
    save(row((26, 52, 96, 245), (110, 180, 255, 255)), out, 'row_on')  # border 6
    save(chevron(), out, 'chevron')
    save(draw_lock((150, 170, 205, 255)), out, 'lock')
    save(badge(), out, 'badge')  # border 5, tinted per type with image-color
    save(header_icon(), out, 'icon_radar')


if __name__ == '__main__':
    main()
