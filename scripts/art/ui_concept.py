#!/usr/bin/env python3
"""Concept boards for the PokeVerse UI redesign (docs/ui-redesign.md): the right column, a popup
window, the swap bar and the moves bar drawn over a real 1920x1080 game screenshot, once per design
direction.

    scripts/art/ui_concept.py --shot build/itch-raw/final_forest_battle8.png

Writes build/ui-concept/concept-<a|b|c>.png, detail-<a|b|c>.png (the popup and the bars at twice the
size) and board.png with all three and their right columns. The minimap is the real satellite map (scripts/mapper/render_pokepedia.py --only world); the
item icons and Pokemon portraits are cut from the screenshot, so it has to be the forest battle shot
the coordinates below were measured on.

Needs cairosvg (pip install cairosvg).
"""
import argparse
import base64
import io
import sys
from pathlib import Path
from xml.sax.saxutils import escape

import cairosvg
from PIL import Image, ImageDraw, ImageFont

sys.path.insert(0, str(Path(__file__).resolve().parent))
sys.path.insert(0, str(Path(__file__).resolve().parents[1] / 'mapper'))
from topbar_icons import glyph  # noqa: E402
import render_pokepedia  # noqa: E402

REPO = Path(__file__).resolve().parents[2]
W, H = 1920, 1080
FONT = 'DejaVu Sans'

# the three directions; A is the one docs/ui-redesign.md picks
THEMES = {
    'a': dict(
        name='A. Pokedex Glass', body='#0e1729', body_alpha=0.9, edge='#375284', header='#13203a',
        header_alpha=0.95, title='#eef2ff', accent='#d9aa3b', text='#e8ecf4', muted='#96aacd',
        slot='#0a121f', slot_edge='#2c4470', radius=8, shadow=True, headers=True, ring_bg='#1b2a46',
        chip='#1b2a46', chip_text='#e8ecf4', button='#d9aa3b', button_text='#1a1406', socket='round',
        bar_panel=True, glyph_bg='#13203a', select='#d9aa3b', select_text='#1a1406'),
    'b': dict(
        name='B. Trainer Gear', body='#f3f5f9', body_alpha=0.97, edge='#1d2433', header='#d8303b',
        header_alpha=1.0, title='#ffffff', accent='#ffffff', text='#1d2433', muted='#5d6b82',
        slot='#ffffff', slot_edge='#c9d1de', radius=10, shadow=True, headers=True, ring_bg='#dfe4ec',
        chip='#1d2433', chip_text='#ffffff', button='#d8303b', button_text='#ffffff', socket='ball',
        bar_panel=True, glyph_bg='#d8303b', select='#d8303b', select_text='#ffffff'),
    'c': dict(
        name='C. Minimal HUD', body='#080c14', body_alpha=0.62, edge=None, header=None,
        header_alpha=0, title='#c9d4ea', accent='#7fb2ff', text='#e8ecf4', muted='#8a98b4',
        slot='#ffffff', slot_alpha=0.06, slot_edge=None, radius=6, shadow=False, headers=False,
        ring_bg='#ffffff22', chip='#00000088', chip_text='#e8ecf4', button='#7fb2ff', button_text='#06101f',
        socket='round', bar_panel=False, glyph_bg='#101827', select='#7fb2ff', select_text='#06101f'),
}

TYPE_COLORS = {'fire': '#f08a3c', 'flying': '#8fb6f0', 'dragon': '#8c6cf0', 'normal': '#b8b2a0',
               'dark': '#7a6a5a', 'steel': '#9fb4c8', 'ground': '#d8b060'}
# the Charizard bar in the screenshot, left to right
MOVES = [('fire', 12, None), ('normal', 30, None), ('fire', 30, None), ('dragon', 53, 0.6), ('fire', 49, None),
         ('flying', 53, None), ('fire', 75, None), ('dragon', 38, None), ('fire', 60, None), ('dark', 30, None),
         ('flying', 60, None), ('fire', 90, 'lock')]
KEYS = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '-', '=']

# where the screenshot's own UI is, and where to take map pixels to paint over it
COVER = [((1740, 26, 1920, 1080), (1560, 26)), ((0, 360, 70, 760), (70, 360)), ((640, 850, 1290, 920), (640, 925))]
INVENTORY = {'order': (27, 178), 'badges': (63, 178), 'dex': (27, 212)}
EQUIPMENT = [(120, 184), (155, 184), (120, 219), (155, 219)]
BATTLE_ROWS = [((18, 334), 'Butterfree', 33, 1.0, False), ((18, 363), 'Kel', None, 1.0, False),
               ((18, 388), 'Caterpie', 8, 0.18, True), ((18, 410), 'Charizard', 100, 1.0, False)]
POKEBAG = [((30, 514), 95), ((68, 514), 3), ((104, 514), 20)]
BALL = (30, 606)


def data_uri(img):
    buf = io.BytesIO()
    img.save(buf, 'PNG')
    return 'data:image/png;base64,' + base64.b64encode(buf.getvalue()).decode()


def image(img, x, y, w=None, h=None, opacity=1.0):
    w, h = w or img.width, h or img.height
    return (f'<image x="{x}" y="{y}" width="{w}" height="{h}" opacity="{opacity}" '
            f'style="image-rendering:pixelated" href="{data_uri(img)}"/>')


def text(x, y, s, size=11, color='#fff', weight='normal', anchor='start', opacity=1.0):
    return (f'<text x="{x}" y="{y}" font-family="{FONT}" font-size="{size}" font-weight="{weight}" fill="{color}" '
            f'text-anchor="{anchor}" opacity="{opacity}">{escape(s)}</text>')


def rect(x, y, w, h, r, fill, opacity=1.0, stroke=None, sw=1):
    s = f' stroke="{stroke}" stroke-width="{sw}"' if stroke else ''
    return f'<rect x="{x}" y="{y}" width="{w}" height="{h}" rx="{r}" fill="{fill}" fill-opacity="{opacity}"{s}/>'


def cut(shot, center, size, key_bg=True):
    """An icon from the screenshot, with the old dark slot behind it made transparent."""
    cx, cy = center
    img = shot.crop((1740 + cx - size // 2, cy - size // 2, 1740 + cx + size // 2, cy + size // 2)).convert('RGBA')
    if key_bg:
        px = img.load()
        for y in range(img.height):
            for x in range(img.width):
                r, g, b, _ = px[x, y]
                if b >= r and b >= g - 6 and r + g + b < 150:
                    px[x, y] = (0, 0, 0, 0)
    return img


def backdrop(shot):
    img = shot.convert('RGB').copy()
    for (l, t, r, b), (sx, sy) in COVER:
        img.paste(shot.crop((sx, sy, sx + r - l, sy + b - t)), (l, t))
    return img


def minimap_picture(w, h):
    tiles_w, tiles_h = w / 4, h / 4
    x0, y0 = 3300 - tiles_w / 2, 425 - tiles_h / 2
    cx, cy = int(x0 // 128), int(y0 // 128)
    path = Path(render_pokepedia.OUT) / 'world' / render_pokepedia.chunk_name(8, 7, cx, cy)
    chunk = render_pokepedia.read_chunk(path)
    px, py = int((x0 - cx * 128) * 4), int((y0 - cy * 128) * 4)
    return chunk.crop((px, py, px + w, py + h))


class Painter:
    def __init__(self, t, shot):
        self.t, self.shot, self.out = t, shot, []

    def add(self, *parts):
        self.out.extend(parts)

    def card(self, x, y, w, h, title=None, icon=None):
        t = self.t
        if t['shadow']:
            self.add(rect(x + 1, y + 3, w, h, t['radius'], '#000', 0.35))
        self.add(rect(x, y, w, h, t['radius'], t['body'], t['body_alpha'], t['edge']))
        if not title:
            return y
        if t['headers']:
            hh = 24
            self.add(f'<clipPath id="c{x}{y}"><rect x="{x}" y="{y}" width="{w}" height="{h}" rx="{t["radius"]}"/></clipPath>',
                     f'<g clip-path="url(#c{x}{y})">', rect(x, y, w, hh, 0, t['header'], t['header_alpha']), '</g>')
            if t['edge']:
                self.add(f'<path d="M{x} {y + hh}h{w}" stroke="{t["edge"]}" stroke-opacity="0.6"/>')
            self.add(glyph(icon, x + 7, y + 5, 14, stroke=t['title'], bg=t['glyph_bg']),
                     text(x + 26, y + 16, title, 11, t['title'], 'bold'))
            if t is THEMES['a']:
                self.add(rect(x + 7, y + hh - 2, 30, 2, 1, t['accent']))
            self.window_buttons(x + w - 8, y + 12, t['title'])
            return y + hh
        # Minimal: a small icon tab, the title in the body
        self.add(rect(x + 6, y + 6, 18, 18, 5, t['glyph_bg'], 0.9), glyph(icon, x + 8, y + 8, 14, stroke=t['accent']),
                 text(x + 30, y + 19, title.upper(), 9, t['muted'], 'bold'))
        self.window_buttons(x + w - 8, y + 15, t['muted'], small=True)
        return y + 26

    def window_buttons(self, right, cy, color, small=False):
        r = 6 if not small else 5
        x = right - r
        # close, menu, minimise from the right
        self.add(f'<circle cx="{x}" cy="{cy}" r="{r}" fill="{color}" fill-opacity="0.12"/>',
                 f'<path d="M{x - 2.5} {cy - 2.5}l5 5M{x + 2.5} {cy - 2.5}l-5 5" stroke="{color}" stroke-width="1.4" stroke-linecap="round"/>')
        x -= 2 * r + 4
        self.add(f'<circle cx="{x}" cy="{cy}" r="{r}" fill="{color}" fill-opacity="0.12"/>',
                 *[f'<circle cx="{x + d}" cy="{cy}" r="0.9" fill="{color}"/>' for d in (-2.6, 0, 2.6)])
        x -= 2 * r + 4
        self.add(f'<circle cx="{x}" cy="{cy}" r="{r}" fill="{color}" fill-opacity="0.12"/>',
                 f'<path d="M{x - 2.8} {cy}h5.6" stroke="{color}" stroke-width="1.4" stroke-linecap="round"/>')

    def slot(self, x, y, s, item=None, count=None, round_=False):
        t = self.t
        fill_alpha = t.get('slot_alpha', 1.0)
        if round_ or t['socket'] == 'ball':
            r = s / 2
            self.add(f'<circle cx="{x + r}" cy="{y + r}" r="{r}" fill="{t["slot"]}" fill-opacity="{fill_alpha}"'
                     + (f' stroke="{t["slot_edge"]}"' if t['slot_edge'] else '') + '/>')
            if t['socket'] == 'ball':
                self.add(f'<path d="M{x + 3} {y + r}h{s - 6}" stroke="{t["slot_edge"]}" stroke-width="1"/>')
        else:
            self.add(rect(x, y, s, s, 6, t['slot'], fill_alpha, t['slot_edge']))
        if item is not None:
            self.add(image(item, x + (s - item.width) / 2, y + (s - item.height) / 2))
        if count is not None:
            self.add(text(x + s - 3, y + s - 3, str(count), 9, t['text'], 'bold', 'end'))

    def chip(self, x, y, label, value, w):
        t = self.t
        self.add(rect(x, y, w, 18, 9, t['chip'], 0.9), text(x + 8, y + 13, label, 9, t['muted']),
                 text(x + w - 8, y + 13, value, 9, t['chip_text'], 'bold', 'end'))

    def bar(self, x, y, w, frac, color, h=4):
        self.add(rect(x, y, w, h, h / 2, self.t['ring_bg']), rect(x, y, max(h, w * frac), h, h / 2, color))

    # the right column
    def right_column(self):
        t, shot = self.t, self.shot
        x, w = 1748, 166
        y = 34
        # minimap
        self.card(x, y, w, 132)
        self.add(f'<clipPath id="mm"><rect x="{x + 5}" y="{y + 5}" width="{w - 10}" height="122" rx="{t["radius"] - 3}"/></clipPath>',
                 f'<g clip-path="url(#mm)">', image(minimap_picture(w - 10, 122), x + 5, y + 5), '</g>',
                 f'<path d="M{x + w / 2 - 5} {y + 66}h10M{x + w / 2} {y + 61}v10" stroke="#fff" stroke-width="2"/>')
        self.add(rect(x + 10, y + 108, 84, 16, 8, '#000', 0.55), text(x + 52, y + 120, '3300, 425, 7', 9, '#fff', 'bold', 'middle'))
        self.add(rect(x + w - 28, y + 10, 20, 62, 10, '#000', 0.5))
        for i, s in enumerate(['+', '-', '\u25ce']):
            self.add(text(x + w - 18, y + 26 + i * 19, s, 12, '#fff', 'bold', 'middle'))
        y += 132 + 8
        # inventory
        top = self.card(x, y, w, 150, 'Inventory', 'inventory')
        for i, (key, label) in enumerate([('order', 'Order'), ('dex', 'Dex'), ('badges', 'Badges')]):
            bx = x + 6 + i * 52
            self.add(rect(bx, top + 6, 48, 46, 7, t['slot'], t.get('slot_alpha', 1.0), t['slot_edge']),
                     image(cut(shot, INVENTORY[key], 24), bx + 12, top + 9), text(bx + 24, top + 48, label, 9, t['text'], 'bold', 'middle'))
        for i, c in enumerate(EQUIPMENT):
            self.slot(x + 6 + i * 39, top + 58, 35, cut(shot, c, 30))
        self.chip(x + 6, top + 99, 'Balls', '10,000', 76)
        self.chip(x + 86, top + 99, 'Respect', '0', 74)
        y += 150 + 8
        # battle list
        top = self.card(x, y, w, 128, 'Battle List', 'battle')
        for i, (c, name, level, hp, target) in enumerate(BATTLE_ROWS):
            ry = top + 4 + i * 25
            if target:
                self.add(rect(x + 4, ry, w - 8, 23, 6, t['select'], 0.16, t['select']))
            self.add(image(cut(shot, c, 18), x + 9, ry + 2), text(x + 32, ry + 11, name, 10, '#ff6b6b' if target else t['text'], 'bold'))
            if level:
                self.add(rect(x + w - 44, ry + 2, 36, 12, 6, t['chip'], 0.9), text(x + w - 26, ry + 11, f'Lv {level}', 8, t['chip_text'], 'bold', 'middle'))
            self.bar(x + 32, ry + 15, w - 42, hp, '#e0566a' if hp < 0.3 else '#43c271')
        y += 128 + 8
        # tracker
        top = self.card(x, y, w, 62, 'Tracker', 'tracker')
        self.add(text(x + 10, top + 16, 'Track a Pokemon from the', 9, t['muted']), text(x + 10, top + 29, 'Pokepedia, or a task.', 9, t['muted']))
        y += 62 + 8
        # simple pokebag
        top = self.card(x, y, w, 70, 'Simple pokebag', 'store')
        for i in range(4):
            item = cut(shot, POKEBAG[i][0], 30) if i < 3 else None
            self.slot(x + 6 + i * 39, top + 6, 35, item, POKEBAG[i][1] if i < 3 else None)
        y += 70 + 8
        # trainer belt
        top = self.card(x, y, w, 70, 'Trainer belt', 'trainercard')
        for i in range(4):
            self.slot(x + 6 + i * 39, top + 6, 35, cut(shot, BALL, 26), round_=True)

    def popup(self):
        t = self.t
        x, y, w, h = 120, 150, 500, 360
        top = self.card(x, y, w, h, 'Quests', 'quest')
        # tabs
        for i, (label, on) in enumerate([('Active', True), ('Available', False), ('Done', False)]):
            tx = x + 12 + i * 92
            self.add(rect(tx, top + 10, 86, 24, 12, t['select'] if on else t['chip'], 1 if on else 0.8),
                     text(tx + 43, top + 26, label, 10, t['select_text'] if on else t['chip_text'], 'bold', 'middle'))
        # dropdown
        self.add(rect(x + w - 150, top + 10, 138, 24, 7, t['slot'], t.get('slot_alpha', 1.0), t['slot_edge']),
                 text(x + w - 140, top + 26, 'All regions', 10, t['text']),
                 f'<path d="M{x + w - 30} {top + 19}l5 5 5-5" fill="none" stroke="{t["muted"]}" stroke-width="1.6"/>')
        rows = [('A work for Oak', 'Pallet Town', 'Lv 1', True), ('Fishing lesson', 'Pallet Town', 'Lv 1', False),
                ('Headbutting', 'Pallet Town', 'Lv 1', False), ('Stressed Pokemon', 'Pallet Town', 'Lv 10', False),
                ('Pokedex research', 'Pallet Town', 'Lv 10', False)]
        for i, (name, town, level, sel) in enumerate(rows):
            ry = top + 46 + i * 46
            self.add(rect(x + 12, ry, w - 40, 40, 8, t['select'] if sel else t['slot'], 0.18 if sel else t.get('slot_alpha', 1.0),
                          t['select'] if sel else t['slot_edge']),
                     text(x + 26, ry + 17, name, 11, t['text'], 'bold'), text(x + 26, ry + 32, town, 9, t['muted']),
                     rect(x + w - 86, ry + 12, 48, 16, 8, t['chip'], 0.9),
                     text(x + w - 62, ry + 24, level, 9, t['chip_text'], 'bold', 'middle'))
        # thin scrollbar
        self.add(rect(x + w - 20, top + 46, 6, 226, 3, t['ring_bg']), rect(x + w - 20, top + 46, 6, 80, 3, t['muted']))
        # checkbox and buttons
        by = y + h - 40
        self.add(rect(x + 14, by + 6, 16, 16, 4, t['select']),
                 f'<path d="M{x + 18} {by + 14}l3 3 6-6" fill="none" stroke="{t["select_text"]}" stroke-width="2"/>',
                 text(x + 38, by + 18, 'Show finished', 10, t['text']),
                 rect(x + w - 200, by, 90, 28, 8, t['chip'], 0.9), text(x + w - 155, by + 18, 'Close', 11, t['chip_text'], 'bold', 'middle'),
                 rect(x + w - 102, by, 90, 28, 8, t['button']), text(x + w - 57, by + 18, 'Track', 11, t['button_text'], 'bold', 'middle'))

    def swap_bar(self, portraits):
        t = self.t
        x, y, s, step = 10, 330, 50, 60
        if t['bar_panel']:
            self.add(rect(x - 4, y - 6, s + 8, step * 6 + 6, 14, t['body'], t['body_alpha'] * 0.85, t['edge']))
        hps = [1.0, 1.0, 1.0, 0.88, 1.0, 0.0]
        for i, (img, hp) in enumerate(zip(portraits, hps)):
            sy = y + i * step
            cx, cy, r = x + s / 2, sy + s / 2, s / 2 - 2
            if i == 0:
                self.add(f'<circle cx="{cx}" cy="{cy}" r="{r + 3}" fill="none" stroke="{t["accent"]}" stroke-width="2" opacity="0.9"/>')
            fill = t['slot'] if t['socket'] != 'ball' else '#ffffff'
            self.add(f'<circle cx="{cx}" cy="{cy}" r="{r}" fill="{fill}" fill-opacity="{t.get("slot_alpha", 1.0) if t["socket"] != "ball" else 1}"/>')
            if t['socket'] == 'ball':
                self.add(f'<path d="M{cx - r} {cy}a{r} {r} 0 0 1 {2 * r} 0z" fill="#d8303b"/>',
                         f'<path d="M{cx - r} {cy}h{2 * r}" stroke="#1d2433" stroke-width="2"/>')
            # the HP ring
            circ = 2 * 3.14159 * (r - 1)
            color = '#43c271' if hp > 0.5 else ('#e6b33a' if hp > 0.2 else '#e0566a')
            self.add(f'<circle cx="{cx}" cy="{cy}" r="{r - 1}" fill="none" stroke="{t["ring_bg"]}" stroke-width="3"/>',
                     f'<circle cx="{cx}" cy="{cy}" r="{r - 1}" fill="none" stroke="{color}" stroke-width="3" '
                     f'stroke-dasharray="{circ * hp} {circ}" transform="rotate(-90 {cx} {cy})" stroke-linecap="round"/>')
            portrait = img if hp > 0 else img.convert('LA').convert('RGBA')
            self.add(image(portrait, cx - 15, cy - 15, opacity=1 if hp > 0 else 0.45))
            self.add(rect(x - 2, sy - 2, 20, 13, 6, t['chip'], 0.95), text(x + 8, sy + 8, f'F{i + 1}', 8, t['chip_text'], 'bold', 'middle'))
            if hp == 0:
                self.add(text(cx, cy + 4, 'FNT', 10, '#ff6b6b', 'bold', 'middle'))

    def moves_bar(self, icons):
        t = self.t
        s, gap = 46, 6
        total = len(MOVES) * (s + gap) - gap
        x0, y0 = (W - total) / 2, 974
        if t['bar_panel']:
            self.add(rect(x0 - 8, y0 - 8, total + 16, s + 16, 14, t['body'], t['body_alpha'], t['edge']))
        for i, ((kind, cost, state), icon) in enumerate(zip(MOVES, icons)):
            x = x0 + i * (s + gap)
            edge = TYPE_COLORS[kind]
            self.add(rect(x, y0, s, s, 10, t['slot'] if t['socket'] != 'ball' else '#ffffff', t.get('slot_alpha', 1.0), edge, 2))
            self.add(image(icon, x + (s - icon.width) / 2, y0 + (s - icon.height) / 2, opacity=0.35 if state == 'lock' else 1))
            if isinstance(state, float):
                # radial cooldown: the part still to wait is dark
                cx, cy, r = x + s / 2, y0 + s / 2, s
                import math
                a = 2 * math.pi * state
                ex, ey = cx + r * math.sin(a), cy - r * math.cos(a)
                large = 1 if state > 0.5 else 0
                self.add(f'<clipPath id="cd{i}"><rect x="{x + 1}" y="{y0 + 1}" width="{s - 2}" height="{s - 2}" rx="9"/></clipPath>',
                         f'<path clip-path="url(#cd{i})" d="M{cx} {cy}L{cx} {cy - r}A{r} {r} 0 {large} 1 {ex} {ey}z" fill="#000" fill-opacity="0.6"/>',
                         text(cx, cy + 5, '4s', 13, '#fff', 'bold', 'middle'))
            if state == 'lock':
                cx, cy = x + s / 2, y0 + s / 2 - 2
                self.add(rect(cx - 7, cy - 1, 14, 11, 2, '#e8ecf4'),
                         f'<path d="M{cx - 4} {cy - 1}v-3a4 4 0 0 1 8 0v3" fill="none" stroke="#e8ecf4" stroke-width="2"/>',
                         rect(x + 6, y0 + s - 15, s - 12, 12, 6, '#000', 0.7), text(cx, y0 + s - 6, 'Lv 80', 8, '#fff', 'bold', 'middle'))
            self.add(rect(x - 3, y0 - 4, 15, 13, 6, t['chip'], 0.95), text(x + 4.5, y0 + 6, KEYS[i], 9, t['chip_text'], 'bold', 'middle'))
            if state != 'lock':
                self.add(rect(x + s - 24, y0 + s - 10, 26, 13, 6, '#2a1d4f', 0.95),
                         f'<path d="M{x + s - 18} {y0 + s - 8}l-3 5h3l-1 4 4-6h-3l1-3z" fill="#c4a0ff"/>',
                         text(x + s - 4, y0 + s, str(cost), 8, '#e8dcff', 'bold', 'end'))


def mockup(key, shot, portraits, icons):
    t = THEMES[key]
    p = Painter(t, shot)
    p.right_column()
    p.popup()
    p.swap_bar(portraits)
    p.moves_bar(icons)
    body = image(backdrop(shot), 0, 0) + ''.join(p.out)
    svg = f'<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="{W}" height="{H}">{body}</svg>'
    png = cairosvg.svg2png(bytestring=svg.encode(), output_width=W, output_height=H)
    img = Image.open(io.BytesIO(png)).convert('RGB')
    label = ImageDraw.Draw(img)
    font = ImageFont.truetype('DejaVuSans-Bold.ttf', 22)
    label.rectangle((640, 120, 640 + 16 + label.textlength(t['name'], font=font), 156), fill=(0, 0, 0))
    label.text((648, 124), t['name'], font=font, fill=(255, 255, 255))
    return img


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--shot', required=True, help='the 1920x1080 forest battle screenshot')
    ap.add_argument('--out', default=str(REPO / 'build/ui-concept'))
    args = ap.parse_args()
    out = Path(args.out)
    out.mkdir(parents=True, exist_ok=True)
    shot = Image.open(args.shot).convert('RGBA')
    if shot.size != (W, H):
        sys.exit('the screenshot must be 1920x1080')

    portraits = []
    for i in range(6):
        y = round(399 + 60.3 * i)
        img = shot.crop((24, y - 11, 54, y + 19)).convert('RGBA')
        px = img.load()
        for yy in range(img.height):
            for xx in range(img.width):
                r, g, b, _ = px[xx, yy]
                if b >= r and r + g + b < 150:
                    px[xx, yy] = (0, 0, 0, 0)
        portraits.append(img)
    icons = []
    for i in range(12):
        img = shot.crop((round(665 + 43.5 * i), 868, round(665 + 43.5 * i) + 22, 888)).convert('RGBA')
        px = img.load()
        # the old "C1" key labels sit in the top left corner
        for yy in range(8):
            for xx in range(12):
                if min(px[xx, yy][:3]) > 150:
                    px[xx, yy] = (0, 0, 0, 0)
        for yy in range(img.height):
            for xx in range(img.width):
                r, g, b, _ = px[xx, yy]
                if b >= r and r + g + b < 120:
                    px[xx, yy] = (0, 0, 0, 0)
        icons.append(img)

    shots = []
    for key in THEMES:
        img = mockup(key, shot, portraits, icons)
        img.save(out / f'concept-{key}.png', optimize=True)
        shots.append(img)

    # one row per direction: the whole screen and its right column at twice the size
    board = Image.new('RGB', (1280 + 360 + 30, 3 * 730 + 10), (16, 24, 32))
    for i, (key, img) in enumerate(zip(THEMES, shots)):
        board.paste(img.resize((1280, 720), Image.LANCZOS), (10, 10 + i * 730))
        board.paste(img.crop((1740, 26, 1920, 386)).resize((360, 720), Image.LANCZOS), (1300, 10 + i * 730))
    board.save(out / 'board.png', optimize=True)

    # the popup and the two bars at twice the size
    for key, img in zip(THEMES, shots):
        popup = img.crop((110, 140, 630, 520)).resize((1040, 760), Image.LANCZOS)
        swap = img.crop((0, 318, 72, 690)).resize((144, 744), Image.LANCZOS)
        moves = img.crop((628, 960, 1292, 1032)).resize((1328, 144), Image.LANCZOS)
        detail = Image.new('RGB', (1350, 930), (16, 24, 32))
        detail.paste(popup, (10, 10))
        detail.paste(swap, (1200, 10))
        detail.paste(moves, (10, 780))
        detail.save(out / f'detail-{key}.png', optimize=True)
    for name in sorted(p.name for p in out.glob('*.png')):
        print(out / name)


if __name__ == '__main__':
    main()
