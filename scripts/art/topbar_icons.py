#!/usr/bin/env python3
"""Draws the top menu bar buttons: navy tiles with cream line icons, one accent colour each,
and a gold ring for open windows.

    scripts/art/topbar_icons.py

Writes into core/client-redemption/pokeverse-modern, replacing Redemption's images of the same
name. Sheets are 40x20 (normal | open or pressed), as MainToggleButton clips them; the icons
under images/topbuttons are glyphs only, drawn by the client on images/options/button_empty.
The Store sheet is 108x40 (normal over pressed).

Needs cairosvg (pip install cairosvg).
"""
import io
import math
from pathlib import Path

import cairosvg
from PIL import Image

ROOT = Path(__file__).resolve().parents[2] / 'core/client-redemption/pokeverse-modern'
OPTIONS = ROOT / 'data/images/options'
TOPBUTTONS = ROOT / 'data/images/topbuttons'
POKEPEDIA = ROOT / 'modules/game_pokepedia/images'

SCALE = 4
CREAM = '#efe6cf'
GOLD = '#ffd75a'
STROKE = 2.1  # in the 24 unit icon grid
GLYPH = 14    # icon size in pixels on a 20 pixel button


def gear():
    pts = []
    teeth, ro, ri = 8, 10.2, 7.4
    for i in range(teeth):
        a = i * 2 * math.pi / teeth
        for da, r in ((-0.30, ri), (-0.17, ro), (0.17, ro), (0.30, ri)):
            pts.append((12 + r * math.cos(a + da), 12 + r * math.sin(a + da)))
    d = 'M' + ' L'.join(f'{x:.2f} {y:.2f}' for x, y in pts) + ' Z'
    return f'<path d="{d}"/><circle class="a" cx="12" cy="12" r="3"/>'


# 24x24 line icons; class "a" strokes in the accent, "af" fills in it, "bg" fills in the tile colour
ICONS = {
    'pokepedia': ('#ff5a4f',
        '<rect x="4" y="2.5" width="16" height="19" rx="2.5"/><path d="M7.4 2.5v19"/>'
        '<path class="af" d="M9.4 12a4.6 4.6 0 0 1 9.2 0z"/>'
        '<circle cx="14" cy="12" r="4.6"/><path d="M9.4 12h9.2"/>'
        '<circle cx="14" cy="12" r="1.5" class="bg"/>'),
    'tasks': ('#6fe08a',
        '<rect x="5" y="4" width="14" height="17.5" rx="2.5"/>'
        '<rect x="9" y="2.2" width="6" height="3.6" rx="1.2" class="bg"/>'
        '<path class="a" d="M8.6 13.2l2.4 2.4 4.6-5"/>'),
    'quest': (GOLD,
        '<path d="M6 3.5h10.5a2 2 0 0 1 2 2v13a2 2 0 0 1-2 2H7.5"/>'
        '<path d="M6 3.5a2 2 0 0 0-2 2v13a2 2 0 0 0 2 2 2 2 0 0 0 2-2V5.5a2 2 0 0 0-2-2z"/>'
        '<path class="a" d="M13.2 7.5v5.2M13.2 15.8h.01"/>'),
    'daily': ('#ff6f91',
        '<rect x="3.5" y="9" width="17" height="4.2" rx="1.2"/><path d="M5 13.2v7.3h14v-7.3"/>'
        '<path class="a" d="M12 9v11.5"/>'
        '<path class="a" d="M12 9C10.2 5.2 6.6 5 6.9 7.4 7.2 9 12 9 12 9zM12 9c1.8-3.8 5.4-4 5.1-1.6C16.8 9 12 9 12 9z"/>'),
    'tracker': (GOLD,
        '<circle cx="6.8" cy="15.5" r="4"/><circle cx="17.2" cy="15.5" r="4"/>'
        '<path d="M4.2 12.4 6 5.5a1.6 1.6 0 0 1 3.1.3V12M19.8 12.4 18 5.5a1.6 1.6 0 0 0-3.1.3V12M10.8 14.2h2.4"/>'
        '<path class="a" d="M5.2 14.6a1.9 1.9 0 0 1 1.6-1.1M15.6 14.6a1.9 1.9 0 0 1 1.6-1.1"/>'),
    'minimap': ('#ff5a4f',
        '<path d="M3 6.2 9 4l6 2.2L21 4v13.8L15 20l-6-2.2L3 20z"/><path d="M9 4v13.8M15 6.2V20" opacity=".55"/>'
        '<path class="af" d="M15 7.2a2.6 2.6 0 0 1 2.6 2.6c0 1.9-2.6 4.4-2.6 4.4s-2.6-2.5-2.6-4.4A2.6 2.6 0 0 1 15 7.2z"/>'),
    'inventory': ('#5ad1c4',
        '<path d="M5.5 10a6.5 6.5 0 0 1 13 0v9a2.5 2.5 0 0 1-2.5 2.5H8A2.5 2.5 0 0 1 5.5 19z"/>'
        '<path d="M9.2 4.6V4a2.8 2.8 0 0 1 5.6 0v.6"/>'
        '<rect class="a" x="8.8" y="13.5" width="6.4" height="4.5" rx="1.2"/>'),
    'skills': ('#6fe08a',
        '<path d="M3.5 20.5h17"/><path d="M6.5 20.5v-5M11 20.5v-8.5"/><path class="a" d="M15.5 20.5V8"/>'
        '<path class="a" d="M13 6.2l2.5-2.7 2.5 2.7"/>'),
    'battle': ('#ff5a4f',
        '<circle cx="12" cy="12" r="7"/><path d="M12 2.5v4M12 17.5v4M2.5 12h4M17.5 12h4"/>'
        '<circle class="af" cx="12" cy="12" r="2.2"/>'),
    'vip': ('#ff6f91',
        '<circle cx="9" cy="8" r="3.6"/><path d="M2.8 20.5a6.2 6.2 0 0 1 12.4 0"/>'
        '<path class="af" d="M18 15.6s-3.6-2.2-3.6-4.6a1.8 1.8 0 0 1 3.6-.4 1.8 1.8 0 0 1 3.6.4c0 2.4-3.6 4.6-3.6 4.6z"/>'),
    'hotkeys': ('#7fb2ff',
        '<rect x="2.5" y="6" width="19" height="13" rx="3"/>'
        '<path d="M6.5 10h.01M10.2 10h.01M13.8 10h.01M17.5 10h.01"/><path class="a" d="M7.5 14.6h9"/>'),
    'audio': ('#7fb2ff',
        '<path d="M4 9.2h3.6L12.5 5v14l-4.9-4.2H4z"/>'
        '<path class="a" d="M15.8 9.2a4 4 0 0 1 0 5.6M18.4 6.6a7.6 7.6 0 0 1 0 10.8"/>'),
    'muted': ('#ff7a6b',
        '<path d="M4 9.2h3.6L12.5 5v14l-4.9-4.2H4z"/>'
        '<path class="a" d="M15.5 9.5l5 5M20.5 9.5l-5 5"/>'),
    'options': ('#7fb2ff', gear()),
    'terminal': ('#7fb2ff',
        '<rect x="2.5" y="4" width="19" height="16" rx="3"/><path class="a" d="M6.8 9.5l3 2.5-3 2.5"/><path d="M12 15h5"/>'),
    'logout': ('#ff7a6b',
        '<path d="M10 3.5H6.5a2 2 0 0 0-2 2v13a2 2 0 0 0 2 2H10"/>'
        '<path class="a" d="M14.5 7.5 19 12l-4.5 4.5M19 12H9.5"/>'),
    'store': ('#c0392b',
        '<path d="M5 8.5h14l-1.1 12H6.1z"/><path d="M9 8.5V6.8a3 3 0 0 1 6 0v1.7"/>'
        '<circle class="af" cx="12" cy="14.6" r="2.2"/>'),
}

# 40x20 sheets the game buttons load with setImageSource
SHEETS = {
    OPTIONS / 'button_questlog.png': 'quest',
    OPTIONS / 'button_skills.png': 'skills',
    OPTIONS / 'button_vip.png': 'vip',
    OPTIONS / 'button_battlelist.png': 'battle',
    OPTIONS / 'hotkeys.png': 'hotkeys',
    OPTIONS / 'button_taskboard.png': 'tasks',
    OPTIONS / 'rewardwall.png': 'daily',
    POKEPEDIA / 'button_pokepedia.png': 'pokepedia',
    POKEPEDIA / 'button_tracker.png': 'tracker',
}

# glyphs the icon buttons draw over button_empty
GLYPHS = {
    'button_mute_up': 'audio',
    'button_mute_pressed': 'muted',
    'button_options': 'options',
    'logout': 'logout',
    'terminal': 'terminal',
    'minimap': 'minimap',
    'inventory': 'inventory',
}


def render(svg, w, h):
    png = cairosvg.svg2png(bytestring=svg.encode(), output_width=w * SCALE, output_height=h * SCALE)
    return Image.open(io.BytesIO(png)).convert('RGBA').resize((w, h), Image.LANCZOS)


def glyph(key, x, y, size, stroke=CREAM, bg='#1d3060'):
    accent, body = ICONS[key]
    body = (body.replace('class="af"', f'fill="{accent}" stroke="{accent}"')
            .replace('class="a"', f'stroke="{accent}"').replace('class="bg"', f'fill="{bg}"'))
    k = size / 24
    return (f'<g transform="translate({x} {y}) scale({k})" fill="none" stroke="{stroke}" '
            f'stroke-width="{STROKE}" stroke-linecap="round" stroke-linejoin="round">{body}</g>')


def tile(x, opened):
    top, bottom, edge = ('#2a3a5e', '#1f2d4f', GOLD) if opened else ('#23396a', '#1a2c55', '#34508a')
    gid = 'on' if opened else 'off'
    shine = '' if opened else (f'<path d="M{x + 4} 1.6h12" stroke="#3f5f9e" stroke-width=".8" '
                               'stroke-linecap="round"/>')
    return (f'<defs><linearGradient id="{gid}" x1="0" y1="0" x2="0" y2="1">'
            f'<stop offset="0" stop-color="{top}"/><stop offset="1" stop-color="{bottom}"/></linearGradient></defs>'
            f'<rect x="{x + .5}" y=".5" width="19" height="19" rx="5" fill="url(#{gid})" stroke="{edge}" '
            f'stroke-width="{1.1 if opened else .9}"/>{shine}')


def svg_doc(w, h, body):
    return f'<svg xmlns="http://www.w3.org/2000/svg" width="{w}" height="{h}" viewBox="0 0 {w} {h}">{body}</svg>'


def sheet(key=None):
    off = (20 - GLYPH) / 2
    body = tile(0, False) + tile(20, True)
    if key:
        body += glyph(key, off, off, GLYPH) + glyph(key, 20 + off, off, GLYPH, bg='#24345a')
    return render(svg_doc(40, 20, body), 40, 20)


def store():
    rows = []
    for y, (top, bottom, rim) in ((0, ('#ffd969', '#f0a92a', '#fff3b8')), (20, ('#e8b843', '#d38f1c', '#f2d27a'))):
        rows.append(
            f'<defs><linearGradient id="g{y}" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="{top}"/>'
            f'<stop offset="1" stop-color="{bottom}"/></linearGradient></defs>'
            f'<rect x="1" y="{y + 1}" width="106" height="18" rx="9" fill="url(#g{y})" stroke="#c98a18" stroke-width=".9"/>'
            f'<path d="M9 {y + 2.2}h90" stroke="{rim}" stroke-width=".8" stroke-linecap="round"/>'
            + glyph('store', 27.5, y + 3, 14, stroke='#2a1e00', bg='#f0b53a') +
            f'<text x="44.5" y="{y + 14.2}" font-family="DejaVu Sans" font-weight="bold" font-size="11" '
            f'fill="#2a1e00">Store</text>')
    return render(svg_doc(108, 40, ''.join(rows)), 108, 40)


def badge_dot():
    return render(svg_doc(8, 8, '<circle cx="4" cy="4" r="3.3" fill="#ff4b4b" stroke="#152341" stroke-width="1.1"/>'), 8, 8)


def main():
    for d in (OPTIONS, TOPBUTTONS, POKEPEDIA):
        d.mkdir(parents=True, exist_ok=True)
    for path, key in SHEETS.items():
        sheet(key).save(path)
    sheet().save(OPTIONS / 'button_empty.png')
    for name, key in GLYPHS.items():
        render(svg_doc(GLYPH, GLYPH, glyph(key, 0, 0, GLYPH)), GLYPH, GLYPH).save(TOPBUTTONS / f'{name}.png')
    store().save(OPTIONS / 'store_large.png')
    badge_dot().save(OPTIONS / 'badge_dot.png')


if __name__ == '__main__':
    main()
