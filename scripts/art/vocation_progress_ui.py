#!/usr/bin/env python3
"""Draws the vocation progress window artwork (game_vocation, after the vocation is chosen): the
wide banners, the perk icons and the rank track's nodes, in the line style of the top bar icons
(topbar_icons.py). The panels, rows, badges and bars come from game_fishing.

    scripts/art/vocation_progress_ui.py

Writes into core/client-redemption/pokeverse-modern/modules/game_vocation/images. Needs cairosvg.
"""
import sys
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter

sys.path.insert(0, str(Path(__file__).parent))
from topbar_icons import render, svg_doc, CREAM, GOLD, STROKE  # noqa: E402

OUT = Path(__file__).resolve().parents[2] / 'core/client-redemption/pokeverse-modern/modules/game_vocation/images'
BANNERS = Path(__file__).parent / 'vocation-banners'
VOCATIONS = ('ace', 'catcher', 'breeder', 'ranger', 'angler', 'medic')
WIDE = (828, 118)
ICON = 16

# 24x24 line icons; class "a" strokes in the accent, "af" fills in it
PERKS = {
    'exp': ('#ffd75a', '<path class="a" d="M13 2.5 5.5 13.5H12l-1 8 7.5-11H12z"/>'),
    'ball': ('#ff5a4f', '<circle cx="12" cy="12" r="8.5"/><path d="M3.5 12h17"/>'
             '<path class="af" d="M3.5 12a8.5 8.5 0 0 1 17 0z"/><circle cx="12" cy="12" r="2.6" fill="#1d3060"/>'),
    'back': ('#6fe08a', '<path d="M5 12a7 7 0 1 0 2.2-5.1"/><path class="a" d="M4.5 3.5v4.4h4.4"/>'),
    'egg': ('#ffd75a', '<path d="M12 3c3.6 0 6.5 5.4 6.5 9.6A6.5 6.5 0 0 1 5.5 12.6C5.5 8.4 8.4 3 12 3z"/>'
            '<path class="a" d="M9 14.5l1.8-1.6 1.6 1.6 1.8-1.6 1.6 1.6"/>'),
    'eggs': ('#ff6f91', '<path d="M9 5c2.5 0 4.5 3.8 4.5 6.7a4.5 4.5 0 0 1-9 0C4.5 8.8 6.5 5 9 5z"/>'
             '<path class="a" d="M16 9c2 0 3.6 3 3.6 5.3a3.6 3.6 0 0 1-7.2 0C12.4 12 14 9 16 9z"/>'),
    'clock': ('#7fb2ff', '<circle cx="12" cy="12" r="8.5"/><path class="a" d="M12 7.2V12l3.2 2.2"/>'),
    'radar': ('#5ad1c4', '<circle cx="12" cy="12" r="8.5"/><circle cx="12" cy="12" r="4.2" stroke-width="1.4"/>'
              '<path class="a" d="M12 12l6-6"/>'),
    'target': ('#5ad1c4', '<circle cx="12" cy="12" r="8.5"/><circle cx="12" cy="12" r="4.4"/>'
               '<circle class="af" cx="12" cy="12" r="1.4"/>'),
    'filter': ('#7fb2ff', '<path d="M4 5h16l-6.2 7.4V19l-3.6-1.8v-4.8z"/>'),
    'compass': ('#ffd75a', '<circle cx="12" cy="12" r="8.5"/><path class="af" d="M15.6 8.4 13.4 13.4 8.4 15.6 10.6 10.6z"/>'),
    'star': ('#ffd75a', '<path class="a" d="M12 3.2l2.6 5.5 6 .8-4.4 4.2 1.1 6-5.3-2.9-5.3 2.9 1.1-6L3.4 9.5l6-.8z"/>'),
    'crown': ('#ffb347', '<path class="a" d="M4 17.5 3 8l5 4 4-6.5 4 6.5 5-4-1 9.5z"/><path d="M4.5 20.5h15"/>'),
    'fish': ('#4fb3ff', '<path d="M3 12c3-4.5 8-6 12.5-3.2L20.5 6v12l-5-2.8C11 18 6 16.5 3 12z"/>'
             '<circle class="af" cx="8" cy="11" r="1.2"/>'),
    'map': ('#ff5a4f', '<path d="M3 6.2 9 4l6 2.2L21 4v13.8L15 20l-6-2.2L3 20z"/><path class="a" d="M9 4v13.8M15 6.2V20"/>'),
    'crane': ('#7fb2ff', '<path d="M5 21V4h13"/><path d="M5 8l5-4"/><path class="a" d="M16 4v6.5"/>'
              '<path class="a" d="M14 12.5a2 2 0 1 0 4 0"/><path d="M2.5 21h6"/>'),
    'heal': ('#6fe08a', '<rect x="5" y="7" width="14" height="13" rx="2.5"/><path d="M9 7V4.5h6V7"/>'
             '<path class="a" d="M12 10.2v6.6M8.7 13.5h6.6"/>'),
    'heart': ('#ff6f91', '<path class="af" d="M12 20s-7.5-4.6-7.5-10A4 4 0 0 1 12 7.6 4 4 0 0 1 19.5 10c0 5.4-7.5 10-7.5 10z"/>'),
    'outfit': ('#ffd75a', '<path d="M8.5 3.5 3.5 7l2.4 3.6L8 9.4V20.5h8V9.4l2.1 1.2L20.5 7l-5-3.5"/>'
               '<path class="a" d="M8.5 3.5a3.5 3.5 0 0 0 7 0"/>'),
    'title': ('#ffd75a', '<path d="M7 3.5h10v6a5 5 0 0 1-10 0z"/><path d="M12 14.5v3.5M8.5 20.5h7"/>'
              '<path class="a" d="M7 5H4a3 3 0 0 0 3 4M17 5h3a3 3 0 0 1-3 4"/>'),
    'trial': ('#ffd75a', '<path d="M6 3.5h12v17H6z"/><path class="a" d="M9 9l2 2 4-4M9 15h6"/>'),
    'guide': ('#7fb2ff', '<path d="M4 4.5h6a2 2 0 0 1 2 2v14a2 2 0 0 0-2-2H4z"/>'
              '<path d="M20 4.5h-6a2 2 0 0 0-2 2v14a2 2 0 0 1 2-2h6z"/>'),
    'ranks': ('#ffd75a', '<path d="M8 3.5 12 9l4-5.5"/><circle class="a" cx="12" cy="15" r="5.5"/>'),
    'up': ('#6fe08a', '<path class="a" d="M12 20V5M6 11l6-6 6 6"/>'),
}


def line_icon(key, size=ICON, stroke=CREAM):
    accent, body = PERKS[key]
    body = body.replace('class="af"', f'fill="{accent}" stroke="{accent}"').replace('class="a"', f'stroke="{accent}"')
    k = size / 24
    svg = (f'<g transform="scale({k})" fill="none" stroke="{stroke}" stroke-width="{STROKE}" '
           f'stroke-linecap="round" stroke-linejoin="round">{body}</g>')
    return render(svg_doc(size, size, svg), size, size)


def wide_banner(key):
    """The banner art with the left half darkened for the title, rounded top corners."""
    w, h = WIDE
    src = Image.open(BANNERS / f'{key}.jpg').convert('RGBA')
    crop_h = round(src.width * h / w)
    top = max(0, (src.height - crop_h) // 3)
    im = src.crop((0, top, src.width, top + crop_h)).resize((w, h), Image.LANCZOS)
    shade = Image.new('L', (w, 1))
    for x in range(w):
        t = x / w
        shade.putpixel((x, 0), int(235 * max(0.0, 1 - t / 0.62) ** 1.2))
    shade = shade.resize((w, h))
    dark = Image.new('RGBA', (w, h), (10, 18, 36, 255))
    dark.putalpha(shade)
    im = Image.alpha_composite(im, dark)
    mask = Image.new('L', (w * 2, h * 2), 0)
    ImageDraw.Draw(mask).rounded_rectangle((0, 0, w * 2 - 1, h * 2 - 1), 14, fill=255)
    im.putalpha(mask.resize((w, h), Image.LANCZOS))
    edge = Image.new('RGBA', (w * 2, h * 2), (0, 0, 0, 0))
    ImageDraw.Draw(edge).rounded_rectangle((1, 1, w * 2 - 2, h * 2 - 2), 14, outline=(46, 74, 118, 255), width=3)
    return Image.alpha_composite(im, edge.resize((w, h), Image.LANCZOS))


def node(kind, size=30):
    s = 4
    big = Image.new('RGBA', (size * s, size * s), (0, 0, 0, 0))
    d = ImageDraw.Draw(big)
    c = size * s / 2
    r = c - 2 * s
    colors = {
        'done': ((226, 178, 62, 255), (255, 214, 90, 255), None),
        'current': ((226, 160, 40, 255), (255, 230, 140, 255), (255, 200, 80, 120)),
        'next': ((20, 34, 64, 255), (90, 170, 255, 255), None),
        'locked': ((20, 30, 52, 255), (80, 96, 128, 255), None),
    }[kind]
    fill, ring, glow = colors
    if glow:
        g = Image.new('RGBA', big.size, (0, 0, 0, 0))
        ImageDraw.Draw(g).ellipse((c - r - 1.5 * s, c - r - 1.5 * s, c + r + 1.5 * s, c + r + 1.5 * s), fill=glow)
        big = Image.alpha_composite(big, g.filter(ImageFilter.GaussianBlur(2 * s)))
        d = ImageDraw.Draw(big)
    d.ellipse((c - r, c - r, c + r, c + r), fill=fill, outline=ring, width=int(2.2 * s))
    im = big.resize((size, size), Image.LANCZOS)
    if kind == 'done':
        im.alpha_composite(render(svg_doc(16, 16, '<path d="M3.5 8.5l3 3 6-7" fill="none" stroke="#2a1e00" '
                                                  'stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round"/>'),
                                  16, 16), (7, 7))
    elif kind == 'locked':
        im.alpha_composite(render(svg_doc(14, 14, '<rect x="3" y="6.5" width="8" height="6" rx="1.4" fill="#8090b0"/>'
                                                  '<path d="M4.8 6.5V5a2.2 2.2 0 0 1 4.4 0v1.5" fill="none" '
                                                  'stroke="#8090b0" stroke-width="1.5"/>'), 14, 14), (8, 8))
    return im


def perk_on(size=20):
    """The green tick circle in front of each perk row."""
    svg = ('<circle cx="10" cy="10" r="8.6" fill="#1f5a3a" stroke="#4fd17a" stroke-width="1.4"/>'
           '<path d="M6 10.3l2.6 2.6 5.2-5.6" fill="none" stroke="#bdf5cf" stroke-width="2" stroke-linecap="round" '
           'stroke-linejoin="round"/>')
    return render(svg_doc(size, size, svg), size, size)


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    for key in VOCATIONS:
        wide_banner(key).save(OUT / f'wide_{key}.png')
    for key in PERKS:
        line_icon(key).save(OUT / f'perk_{key}.png')
    for kind in ('done', 'current', 'next', 'locked'):
        node(kind).save(OUT / f'node_{kind}.png')
    perk_on().save(OUT / 'perk_on.png')


if __name__ == '__main__':
    main()
