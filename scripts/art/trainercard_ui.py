#!/usr/bin/env python3
"""Draws the Trainer Card window artwork (game_trainercard): line icons in the style of the top bar
icons (topbar_icons.py), the sex symbols, the trophy and badge slots and the rank shield. The window
frame and tabs come from game_dailytasks, the panels and badges from game_fishing. The hometown
scenes are trainercard_scenes.py.

    scripts/art/trainercard_ui.py

Writes into core/client-redemption/pokeverse-modern/modules/game_trainercard/images. Needs cairosvg.
"""
import sys
from pathlib import Path

from PIL import Image, ImageDraw

sys.path.insert(0, str(Path(__file__).parent))
from topbar_icons import render, svg_doc, CREAM, STROKE  # noqa: E402

OUT = Path(__file__).resolve().parents[2] / 'core/client-redemption/pokeverse-modern/modules/game_trainercard/images'

# 24x24 line icons; class "a" strokes in the accent, "af" fills in it
ICONS = {
    'card': ('#7fb2ff', '<rect x="2.5" y="5" width="19" height="14" rx="2.5"/>'
             '<circle class="a" cx="8.3" cy="10.6" r="2.2"/><path class="a" d="M5 16.2a3.4 3.4 0 0 1 6.6 0"/>'
             '<path d="M14 10h4.5M14 13.5h3"/>'),
    'user': ('#7fb2ff', '<circle class="a" cx="12" cy="8" r="4"/><path d="M4.5 20.5a7.5 7.5 0 0 1 15 0"/>'),
    'trophy': ('#ffd75a', '<path d="M7 3.5h10v6a5 5 0 0 1-10 0z"/><path d="M12 14.5v3.5M8.5 20.5h7"/>'
               '<path class="a" d="M7 5H4a3 3 0 0 0 3 4M17 5h3a3 3 0 0 1-3 4"/>'),
    'medal': ('#ffd75a', '<path d="M8 3.5 12 9l4-5.5"/><circle class="a" cx="12" cy="15" r="5.5"/>'),
    'book': ('#7fb2ff', '<path d="M5 4.5h11.5a2 2 0 0 1 2 2v14H7a2 2 0 0 1-2-2z"/><path class="a" d="M5 16.5h13.5"/>'),
    'level': ('#ffd75a', '<path class="af" d="M12 3.2l2.6 5.5 6 .8-4.4 4.2 1.1 6-5.3-2.9-5.3 2.9 1.1-6L3.4 9.5l6-.8z"/>'),
    'home': ('#ffd75a', '<path d="M12 21s-6.5-6.1-6.5-11a6.5 6.5 0 0 1 13 0c0 4.9-6.5 11-6.5 11z"/>'
             '<circle class="a" cx="12" cy="10" r="2.3"/>'),
    'guild': ('#c58cff', '<path d="M12 2.8 19.5 6v5.6c0 4.6-3.2 8.4-7.5 9.6-4.3-1.2-7.5-5-7.5-9.6V6z"/>'),
    'mastery': ('#ff8a3d', '<path class="af" d="M12 21a6 6 0 0 1-6-6c0-4 3-5.5 3.5-9.5 2.5 1.5 4 4 4 6.5 1-1 1.5-2 1.5-3.5'
                ' 2 1.6 3 4 3 6.5a6 6 0 0 1-6 6z"/>'),
    'clock': ('#7fb2ff', '<circle cx="12" cy="12" r="8.5"/><path class="a" d="M12 7.2V12l3.2 2.2"/>'),
    'calendar': ('#ffd75a', '<rect x="3.5" y="5" width="17" height="15.5" rx="2.5"/><path d="M3.5 10h17"/>'
                 '<path class="a" d="M8 3v4M16 3v4"/>'),
    'duel': ('#ffd75a', '<path d="M4 4l11 11M20 4 9 15"/><path class="a" d="M13 17l4 4M11 17l-4 4M15.5 15.5l3-3M8.5 15.5l-3-3"/>'),
    'respect': ('#ff6f91', '<path class="af" d="M12 20s-7.5-4.6-7.5-10A4 4 0 0 1 12 7.6 4 4 0 0 1 19.5 10c0 5.4-7.5 10-7.5 10z"/>'),
    'badge': ('#ffd75a', '<circle cx="12" cy="9.5" r="6"/><path class="a" d="M8.5 14.5 7 21l5-2.5 5 2.5-1.5-6.5"/>'),
    'stats': ('#7fb2ff', '<path d="M4 20.5h16"/><path class="a" d="M7 17v-5M12 17V7M17 17v-8"/>'),
    'about': ('#7fb2ff', '<path d="M4 5.5h16v10.5H10l-4.5 4v-4H4z"/><path class="a" d="M8 9.5h8M8 12.5h5"/>'),
    'ball': ('#ff5a4f', '<circle cx="12" cy="12" r="8.5"/><path d="M3.5 12h17"/>'
             '<path class="af" d="M3.5 12a8.5 8.5 0 0 1 17 0z"/><circle cx="12" cy="12" r="2.6" fill="#1d3060"/>'),
    'dex': ('#ff5a4f', '<rect x="5" y="3" width="14" height="18" rx="2.5"/><circle class="a" cx="12" cy="9.5" r="3"/>'
            '<path d="M8.5 16h7"/>'),
    'shiny': ('#ffd75a', '<path class="af" d="M12 3l1.8 6.2L20 11l-6.2 1.8L12 19l-1.8-6.2L4 11l6.2-1.8z"/>'),
    'cup': ('#ffd75a', '<path d="M7 3.5h10v6a5 5 0 0 1-10 0z"/><path d="M12 14.5v3.5M8.5 20.5h7"/>'),
    'trainer': ('#ff8a80', '<circle cx="12" cy="12" r="8.5"/><path class="a" d="M8 9l8 6M16 9l-8 6"/>'),
    'pencil': ('#7fb2ff', '<path d="M4 20l1-4.5L16 4.5l3.5 3.5-11 11z"/><path class="a" d="M13.5 7l3.5 3.5"/>'),
    'plus': ('#7fb2ff', '<circle cx="12" cy="12" r="8.5"/><path class="a" d="M12 8v8M8 12h8"/>'),
    'vip': ('#cfe2ff', '<circle cx="9.5" cy="8" r="3.6"/><path d="M3 20a6.5 6.5 0 0 1 13 0"/><path class="a" d="M19 8v6M16 11h6"/>'),
    'trade': ('#cfe2ff', '<path d="M4 8h14l-3.5-3.5M20 16H6l3.5 3.5"/>'),
    'message': ('#cfe2ff', '<path d="M4 5.5h16v10.5H10l-4.5 4v-4H4z"/>'),
    'swords': ('#cfe2ff', '<path d="M4 4l11 11M20 4 9 15"/><path d="M13 17l4 4M11 17l-4 4"/>'),
    'outfit': ('#cfe2ff', '<path d="M8.5 3.5 3.5 7l2.4 3.6L8 9.4V20.5h8V9.4l2.1 1.2L20.5 7l-5-3.5"/>'
               '<path d="M8.5 3.5a3.5 3.5 0 0 0 7 0"/>'),
    'lock': ('#cfe2ff', '<rect x="5" y="10.5" width="14" height="10" rx="2.2"/><path d="M8 10.5V7.5a4 4 0 0 1 8 0v3"/>'),
    'eye': ('#cfe2ff', '<path d="M2.5 12S6 5.5 12 5.5 21.5 12 21.5 12 18 18.5 12 18.5 2.5 12 2.5 12z"/>'
            '<circle cx="12" cy="12" r="3"/>'),
    'cancel': ('#ffb4b4', '<path d="M6 6l12 12M18 6 6 18"/>'),
    'save': ('#ffffff', '<path d="M5 12.5l4.5 4.5L19 7.5"/>'),
    'remove': ('#ff8a80', '<path class="a" d="M7 7l10 10M17 7 7 17"/>'),
    'chevron': ('#ffd75a', '<path class="a" d="M6 9l6 6 6-6"/>'),
}

SEX = {'male': '#5aa9ff', 'female': '#ff7aa8'}


def line_icon(key, size=16, stroke=CREAM):
    accent, body = ICONS[key]
    body = body.replace('class="af"', f'fill="{accent}" stroke="{accent}"').replace('class="a"', f'stroke="{accent}"')
    k = size / 24
    svg = (f'<g transform="scale({k})" fill="none" stroke="{stroke}" stroke-width="{STROKE}" '
           f'stroke-linecap="round" stroke-linejoin="round">{body}</g>')
    return render(svg_doc(size, size, svg), size, size)


def sex_icon(kind, size=14):
    color = SEX[kind]
    if kind == 'male':
        body = '<circle cx="10" cy="14" r="6"/><path d="M14.5 9.5 20 4M14.5 4H20v5.5"/>'
    else:
        body = '<circle cx="12" cy="9" r="6"/><path d="M12 15v6.5M8.5 18.5h7"/>'
    k = size / 24
    svg = (f'<g transform="scale({k})" fill="none" stroke="{color}" stroke-width="3" '
           f'stroke-linecap="round" stroke-linejoin="round">{body}</g>')
    return render(svg_doc(size, size, svg), size, size)


def frame(size, fill, outline, radius=8, width=2, dashed=False):
    """A rounded slot: trophy tiles, badge slots, the scene frame (image-border friendly)."""
    s = 4
    w, h = size
    big = Image.new('RGBA', (w * s, h * s), (0, 0, 0, 0))
    d = ImageDraw.Draw(big)
    box = (width * s // 2, width * s // 2, w * s - 1 - width * s // 2, h * s - 1 - width * s // 2)
    d.rounded_rectangle(box, radius * s, fill=fill, outline=None if dashed else outline, width=width * s)
    im = big.resize(size, Image.LANCZOS)
    if dashed:
        d = ImageDraw.Draw(im)
        for x in range(radius, w - radius, 6):
            d.line((x, 1, x + 2, 1), fill=outline)
            d.line((x, h - 2, x + 2, h - 2), fill=outline)
        for y in range(radius, h - radius, 6):
            d.line((1, y, 1, y + 2), fill=outline)
            d.line((w - 2, y, w - 2, y + 2), fill=outline)
    return im


def shield(size=(26, 30)):
    """The rank shield over the scene's top-left corner; the number is drawn on top by the client."""
    w, h = size
    s = 4
    big = Image.new('RGBA', (w * s, h * s), (0, 0, 0, 0))
    d = ImageDraw.Draw(big)
    pts = [(2 * s, 2 * s), (w * s - 2 * s, 2 * s), (w * s - 2 * s, h * s * 0.62), (w * s / 2, h * s - 2 * s),
           (2 * s, h * s * 0.62)]
    d.polygon(pts, fill=(150, 30, 40, 255), outline=(255, 214, 90, 255))
    d.line(pts + [pts[0]], fill=(255, 214, 90, 255), width=int(1.6 * s))
    return big.resize(size, Image.LANCZOS)


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    for key in ICONS:
        line_icon(key).save(OUT / f'icon_{key}.png')
    line_icon('card', 30).save(OUT / 'header.png')
    for kind in SEX:
        sex_icon(kind).save(OUT / f'sex_{kind}.png')
        sex_icon(kind, 20).save(OUT / f'sex_{kind}_big.png')
    frame((40, 40), (20, 32, 60, 255), (60, 90, 140, 255)).save(OUT / 'slot.png')
    frame((40, 40), (40, 34, 14, 255), (226, 178, 62, 255)).save(OUT / 'slot_on.png')
    frame((40, 40), (18, 28, 52, 255), (90, 140, 210, 255), dashed=True).save(OUT / 'slot_add.png')
    frame((40, 40), (30, 46, 82, 255), (90, 170, 255, 255)).save(OUT / 'slot_hover.png')
    frame((40, 40), (0, 0, 0, 0), (226, 178, 62, 255), radius=10, width=3).save(OUT / 'scene_frame.png')
    frame((40, 24), (120, 24, 34, 255), (220, 70, 70, 255), radius=6).save(OUT / 'nameplate.png')
    frame((40, 24), (40, 30, 10, 255), (226, 178, 62, 255), radius=6).save(OUT / 'title.png')
    frame((40, 24), (20, 34, 70, 255), (70, 110, 180, 255), radius=6).save(OUT / 'pill.png')
    shield().save(OUT / 'shield.png')


if __name__ == '__main__':
    main()
