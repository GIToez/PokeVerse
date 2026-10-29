#!/usr/bin/env python3
"""Concept sheet for clearer top bar icons: the current art next to redrawn ones, at bar size and at
the phone drawer's size. Same tiles, line weight and colours as scripts/art/topbar_icons.py.

    python3 docs/concepts/topbar-icons/icons.py

Writes sheet.png and bar.png next to this file. Needs cairosvg and Pillow.
"""
import importlib.util
import io
from pathlib import Path

import cairosvg
from PIL import Image, ImageDraw, ImageFont

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[2]
MODERN = REPO / 'core/client-redemption/pokeverse-modern'

spec = importlib.util.spec_from_file_location('topbar_icons', REPO / 'scripts/art/topbar_icons.py')
T = importlib.util.module_from_spec(spec)
spec.loader.exec_module(T)

GOLD = T.GOLD

# 24x24 line icons, same classes as topbar_icons.ICONS
NEW = {
    'n_pokedex': ('#4fb3ff',
        '<rect x="4.5" y="2.5" width="15" height="19" rx="2.5" fill="#c8362f"/>'
        '<circle cx="9" cy="7" r="2.9" fill="#efe6cf" stroke-width="0"/>'
        '<circle class="af" cx="9" cy="7" r="1.9"/>'
        '<circle cx="13.6" cy="6" r=".5" fill="#ffd75a" stroke="#ffd75a"/>'
        '<circle cx="15.8" cy="6" r=".5" fill="#6fe08a" stroke="#6fe08a"/>'
        '<rect x="7.5" y="11.4" width="9" height="6" rx="1" fill="#1d3060"/>'),
    'n_tasks': ('#6fe08a',
        '<rect x="5" y="4" width="14" height="17.5" rx="2.5"/>'
        '<rect x="9" y="2.2" width="6" height="3.6" rx="1.2" class="bg"/>'
        '<path class="a" d="M7.8 10.6l1.3 1.3 2.2-2.5M7.8 16.2l1.3 1.3 2.2-2.5"/>'
        '<path d="M13.2 11h3M13.2 16.6h3"/>'),
    'n_quest': (GOLD,
        '<path d="M6 3h8.5L19 7.5V21H6z"/><path d="M14.5 3v4.5H19"/>'
        '<path class="a" stroke-width="3.2" d="M12.5 9.4v4.8"/>'
        '<circle class="af" cx="12.5" cy="17.7" r="1.4"/>'),
    'n_tracker': (GOLD,
        '<ellipse class="af" cx="12" cy="15.6" rx="4.4" ry="3.7"/>'
        '<circle class="af" cx="6.4" cy="10.2" r="1.9"/><circle class="af" cx="9.9" cy="6.4" r="1.9"/>'
        '<circle class="af" cx="14.1" cy="6.4" r="1.9"/><circle class="af" cx="17.6" cy="10.2" r="1.9"/>'),
    'n_cap': ('#ff5a4f',
        '<path class="af" d="M4 15a7 7 0 0 1 14 0z"/>'
        '<path d="M2.8 15H15c3.2 0 5.6.5 6.8 1.9"/>'
        '<path d="M10.4 15a3.4 3.4 0 0 1 6.8 0" fill="#efe6cf" stroke-width="0"/>'
        '<circle cx="11" cy="7.4" r=".9" fill="#efe6cf" stroke-width="0"/>'),
    'n_backpack': ('#5ad1c4',
        '<rect x="5" y="6.5" width="14" height="15" rx="3.5"/>'
        '<path d="M9 6.5V5a3 3 0 0 1 6 0v1.5"/>'
        '<path d="M5 12h14"/>'
        '<rect class="a" x="8.6" y="14.6" width="6.8" height="4.2" rx="1.2"/>'),
    'n_nearby': ('#ff5a4f',
        '<circle cx="6" cy="6.5" r="2.4"/><circle cx="6" cy="12.5" r="2.4"/><circle cx="6" cy="18.5" r="2.4"/>'
        '<path class="af" d="M3.6 6.5a2.4 2.4 0 0 1 4.8 0z"/>'
        '<path d="M11 6.5h9.5M11 12.5h7M11 18.5h8.5"/>'),
    'n_social': ('#ff6f91',
        '<circle cx="9" cy="8" r="3.4"/><path d="M2.8 20.5a6.2 6.2 0 0 1 12.4 0"/>'
        '<circle class="a" cx="16.6" cy="8.8" r="2.8"/><path class="a" d="M16.2 14.3a5 5 0 0 1 5.3 5.2"/>'),
    'n_hotkeys': ('#ff5a4f',
        '<path class="af" d="M3 10a7 7 0 0 1 14 0z"/>'
        '<circle cx="10" cy="10" r="7"/><path d="M3 10h14"/>'
        '<circle cx="10" cy="10" r="2" class="bg"/>'
        '<rect x="13" y="13.5" width="8.5" height="8" rx="2" class="bg"/>'
        '<path d="M15.6 18.8h3.3" stroke-width="1.6"/>'),
}
T.ICONS.update(NEW)

# (name, what it opens, current art, concept art or None to keep). Art is an ICONS key, or a
# 40x20 sheet in the repo whose left half is the button.
BUTTONS = [
    ('Pokepedia', 'Every Pokemon, where it lives, maps', 'pokepedia', 'n_pokedex',
     'A Pokedex says "Pokemon info" at a glance; the book with a ball is harder to read small.'),
    ('Tasks', 'The daily task board', 'tasks', 'n_tasks',
     'A checklist with two ticks, so it reads as "to-do" and not as one more document.'),
    ('Quest Log', 'Your quests', 'quest', 'n_quest',
     'The gold "!" that marks quest NPCs in the world, big enough to see on the bar.'),
    ('Daily login', 'The daily reward calendar', 'daily', None, 'A gift already reads as a reward.'),
    ('Tracker', 'Follows a Pokemon or a task to where it is', 'tracker', 'n_tracker',
     'A paw print: tracking a Pokemon down. Binoculars looked like "look around".'),
    ('Trainer Card', 'Your card, badges and stats', 'trainercard', None, 'Already reads as an ID card.'),
    ('Vocation', 'Your class: Ace, Catcher, Ranger, Medic...', 'vocation', 'n_cap',
     "A trainer's cap for \"what kind of trainer you are\". The shield with a star looked like rank or defence."),
    ('Bag', 'Your items', 'inventory', 'n_backpack',
     'A backpack with a flap and a pocket. The old shape looked like a jar.'),
    ('Nearby', 'Who is around you: wild, trainers, NPCs', 'battle', 'n_nearby',
     'A list with Poke Balls, like the window itself. The crosshair looked like "attack".'),
    ('Social', 'Friends and who is online', 'vip', 'n_social',
     'Two people for friends. The heart alone looked like "favourites".'),
    ('Analyser', 'Hunt stats: exp, loot, catches per hour', 'analyser', None, 'Charts and a lens; clear enough.'),
    ('Reports', 'Report a bug or a player', 'modules/game_reports/images/button_reports.png', None,
     'The flag is the usual "report" sign.'),
    ('Admin', 'Staff tools (staff only)', 'modules/game_admin/images/button_admin.png', None, 'Staff know it.'),
    ('Item hotkeys', 'Items bound to keys', 'hotkeys', 'n_hotkeys',
     'A key with a Poke Ball on it: keys for items. A whole keyboard looked like "controls".'),
    ('Audio', 'Sound on or off', 'audio', None, 'A speaker is the clearest there is.'),
    ('Activity', 'Your catches, sales, level-ups', 'modules/game_pokegear/images/button_bell.png', None,
     'A bell is the usual "what happened" sign.'),
]

FONT = '/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf'
BOLD = '/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf'
BG = (16, 24, 44)
CARD = (28, 40, 70)
TEXT = (238, 242, 255)
DIM = (150, 165, 200)
CHANGED = (255, 215, 90)
KEPT = (120, 140, 180)


def svg_png(svg, size):
    png = cairosvg.svg2png(bytestring=svg.encode(), output_width=size * 4, output_height=size * 4)
    return Image.open(io.BytesIO(png)).convert('RGBA').resize((size, size), Image.LANCZOS)


def button(art, size):
    if art.endswith('.png'):
        sheet = Image.open(MODERN / art).convert('RGBA').crop((0, 0, 20, 20))
        return sheet.resize((size, size), Image.LANCZOS)
    off = (20 - T.GLYPH) / 2
    return svg_png(T.svg_doc(20, 20, T.tile(0, False) + T.glyph(art, off, off, T.GLYPH)), size)


def font(path, size):
    return ImageFont.truetype(path, size)


def wrap(draw, text, face, width):
    lines, line = [], ''
    for word in text.split():
        test = (line + ' ' + word).strip()
        if draw.textlength(test, font=face) > width and line:
            lines.append(line)
            line = word
        else:
            line = test
    return lines + [line]


def bar(concept, size=30, gap=5):
    arts = [(b[3] or b[2]) if concept else b[2] for b in BUTTONS] + ['options', 'logout']
    width = len(arts) * (size + gap) + gap
    img = Image.new('RGBA', (width, size + 2 * gap), (21, 33, 62, 255))
    x = gap
    for art in arts:
        tile = button(art, size)
        img.alpha_composite(tile, (x, gap))
        x += size + gap
    return img


def sheet():
    cols, card_w, card_h, pad = 4, 420, 250, 22
    head = 300
    width = cols * card_w + (cols + 1) * pad
    rows = (len(BUTTONS) + cols - 1) // cols
    height = head + rows * (card_h + pad) + pad
    img = Image.new('RGBA', (width, height), BG + (255,))
    draw = ImageDraw.Draw(img)
    draw.text((pad, 18), 'Top bar icons: can you tell what each one opens?', font=font(BOLD, 34), fill=TEXT)
    draw.text((pad, 64), 'Gold = redrawn, grey = kept. Same tiles, colours and line weight as today.',
              font=font(FONT, 20), fill=DIM)

    for i, (label, concept) in enumerate((('Now', False), ('Concept', True))):
        y = 108 + i * 90
        draw.text((pad, y + 22), label, font=font(BOLD, 22), fill=TEXT)
        strip = bar(concept)
        img.alpha_composite(strip, (pad + 120, y))
    draw.text((pad + 120, 262), 'The bar at its real size on a 1080p screen (30px). Settings and Exit stay as they are.',
              font=font(FONT, 17), fill=DIM)

    for index, (name, opens, now, new, why) in enumerate(BUTTONS):
        col, row = index % cols, index // cols
        x = pad + col * (card_w + pad)
        y = head + row * (card_h + pad)
        draw.rounded_rectangle((x, y, x + card_w, y + card_h), 14, fill=CARD,
                               outline=CHANGED if new else (45, 60, 95), width=2 if new else 1)
        draw.text((x + 16, y + 12), name, font=font(BOLD, 22), fill=TEXT)
        tag = 'redrawn' if new else 'kept'
        face = font(BOLD, 15)
        draw.text((x + card_w - 16 - draw.textlength(tag, font=face), y + 17), tag, font=face,
                  fill=CHANGED if new else KEPT)
        draw.text((x + 16, y + 42), opens, font=font(FONT, 15), fill=DIM)
        big = 66
        if new:
            img.alpha_composite(button(now, big), (x + 30, y + 72))
            draw.text((x + 30 + big + 16, y + 72 + big // 2 - 14), '->', font=font(BOLD, 24), fill=DIM)
            img.alpha_composite(button(new, big), (x + 30 + big + 60, y + 72))
            img.alpha_composite(button(now, 30), (x + 290, y + 90))
            img.alpha_composite(button(new, 30), (x + 340, y + 90))
            draw.text((x + 286, y + 126), 'bar size', font=font(FONT, 13), fill=DIM)
        else:
            img.alpha_composite(button(now, big), (x + 30, y + 72))
            img.alpha_composite(button(now, 30), (x + 290, y + 90))
        ty = y + 158
        for line in wrap(draw, why, font(FONT, 15), card_w - 32)[:4]:
            draw.text((x + 16, ty), line, font=font(FONT, 15), fill=TEXT)
            ty += 20
    return img


def main():
    sheet().convert('RGB').save(HERE / 'sheet.png')
    side = Image.new('RGBA', (bar(False).width + 40, 2 * bar(False).height + 60), BG + (255,))
    side.alpha_composite(bar(False), (20, 20))
    side.alpha_composite(bar(True), (20, 40 + bar(False).height))
    side.convert('RGB').save(HERE / 'bar.png')


if __name__ == '__main__':
    main()
