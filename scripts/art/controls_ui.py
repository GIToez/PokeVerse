#!/usr/bin/env python3
"""Draws the Item hotkeys window and Settings artwork: action icons, keycaps, switches and
slider parts, in the line style of the top bar (scripts/art/topbar_icons.py).

    scripts/art/controls_ui.py

Writes into core/client-redemption/pokeverse-modern/modules/game_hotkeys/images and
.../modules/client_options/images. Keycaps are 9-slice images: the otui sets image-border: 6.

Needs cairosvg (pip install cairosvg).
"""
from pathlib import Path

from topbar_icons import ICONS, ROOT, glyph, gear, render, svg_doc

HOTKEYS = ROOT / 'modules/game_hotkeys/images'
OPTIONS = ROOT / 'modules/client_options/images'

ICONS.update({
    'keyboard': ('#7fb2ff', ICONS['hotkeys'][1]),
    'self': ('#6fe08a', '<circle cx="12" cy="7.5" r="3.8"/><path d="M4.5 21a7.5 7.5 0 0 1 15 0"/>'
                        '<path class="a" d="M16.5 4.8l1.8 1.8 3.4-3.6"/>'),
    'poke': ('#ff5a4f', '<circle cx="12" cy="12" r="8.5"/><path class="af" d="M3.5 12a8.5 8.5 0 0 1 17 0z"/>'
                        '<path d="M3.5 12h17"/><circle cx="12" cy="12" r="2.6" class="bg"/>'),
    'cross': ('#ffd75a', '<path d="M12 3v6M12 15v6M3 12h6M15 12h6"/><circle class="a" cx="12" cy="12" r="1.2"/>'),
    'target': ICONS['battle'],
    'hand': ('#7fb2ff', '<path d="M8 12V5.5a1.5 1.5 0 0 1 3 0V11M11 10V4a1.5 1.5 0 0 1 3 0v6M14 10V5.5a1.5 1.5 0 0 1 3 0V14'
                        'a7 7 0 0 1-7 7 6 6 0 0 1-5-3l-2.5-4.5a1.5 1.5 0 0 1 2.6-1.5L8 14"/>'),
    'text': ('#ff6f91', '<path d="M5 6h14M12 6v13"/><path class="a" d="M8.5 19h7"/>'),
    'warn': ('#ffb547', '<path d="M12 3.5 21.5 20h-19z"/><path class="a" d="M12 10v4.5M12 17.3h.01"/>'),
    'check': ('#6fe08a', '<circle cx="12" cy="12" r="9"/><path class="a" d="M7.8 12.3l2.8 2.8 5.6-6"/>'),
    'swap': ('#7fb2ff', '<path class="a" d="M7 7h11l-3-3M17 17H6l3 3"/>'),
    'plus': ('#6fe08a', '<path class="a" d="M12 5v14M5 12h14"/>'),
    'trash': ('#ff7a6b', '<path d="M4.5 7h15M9.5 7V4.5h5V7M6.5 7l1 13h9l1-13"/><path class="a" d="M10.2 11v5.5M13.8 11v5.5"/>'),
    'bag': ICONS['inventory'],
    'chat': ('#7fb2ff', '<path d="M4 5.5h16v10H10l-4.5 3.5v-3.5H4z"/><path class="a" d="M8 10.5h8"/>'),
    'wasd': ('#ffd75a', '<rect x="9" y="3" width="6" height="6" rx="1.5"/><rect x="3" y="11" width="6" height="6" rx="1.5"/>'
                        '<rect class="a" x="9" y="11" width="6" height="6" rx="1.5"/><rect x="15" y="11" width="6" height="6" rx="1.5"/>'),
    'search': ('#96aacd', '<circle cx="10.5" cy="10.5" r="6"/><path d="M15 15l5 5"/>'),
    'copy': ('#96aacd', '<rect x="8" y="8" width="12" height="12" rx="2.5"/><path d="M16 8V6a2 2 0 0 0-2-2H6a2 2 0 0 0-2 2v8a2 2 0 0 0 2 2h2"/>'),
    'pen': ('#96aacd', '<path d="M4 20l1-4.5L15.5 5a2.1 2.1 0 0 1 3 3L8 18.5z"/><path class="a" d="M13.5 7l3 3"/>'),
    'layout': ('#5ad1c4', '<rect x="3" y="4" width="18" height="16" rx="2.5"/><path d="M3 9h18M9 9v11"/><path class="a" d="M12.5 13h5M12.5 16h3.5"/>'),
    'monitor': ('#ffd75a', '<rect x="2.5" y="4" width="19" height="12.5" rx="2.5"/><path d="M8.5 20.5h7M12 16.5v4"/><path class="a" d="M7 12.5l3-3 2.5 2.5 4-4"/>'),
    'dots': ('#6fe08a', '<circle cx="5.5" cy="12" r="1.6"/><circle cx="12" cy="12" r="1.6"/><circle class="af" cx="18.5" cy="12" r="1.6"/>'),
    'mouse': ('#ffd75a', '<rect x="6" y="2.5" width="12" height="19" rx="6"/><path class="a" d="M12 6.5v4"/>'),
    'sound': ('#ff6f91', ICONS['audio'][1]),
    'gear': ('#7fb2ff', gear()),
})

# icons for buttons and rows (glyph only, transparent)
SMALL = ['plus', 'trash', 'swap', 'bag', 'warn', 'check', 'chat', 'wasd', 'search', 'copy', 'pen', 'keyboard',
         'gear', 'layout', 'monitor', 'sound', 'dots', 'mouse']
# the "when pressed" choices
ACTIONS = ['poke', 'cross', 'target', 'self', 'hand', 'text']


def header_icon(key):
    body = ('<defs><linearGradient id="t" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#27407a"/>'
            '<stop offset="1" stop-color="#1a2c55"/></linearGradient></defs>'
            '<rect x=".75" y=".75" width="28.5" height="28.5" rx="7" fill="url(#t)" stroke="#4b6cab" stroke-width="1.2"/>'
            + glyph(key, 5, 5, 20, bg='#1f3466'))
    return render(svg_doc(30, 30, body), 30, 30)


def keycap(top, bottom, edge, lip, ring=None):
    ringsvg = f'<rect x=".75" y=".75" width="22.5" height="20.5" rx="5" fill="none" stroke="{ring}" stroke-width="1.5"/>' if ring else ''
    body = (f'<defs><linearGradient id="k" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="{top}"/>'
            f'<stop offset="1" stop-color="{bottom}"/></linearGradient></defs>'
            f'<rect x="1" y="1" width="22" height="20" rx="4.5" fill="{lip}"/>'
            f'<rect x="1" y="1" width="22" height="18" rx="4.5" fill="url(#k)" stroke="{edge}" stroke-width="1"/>'
            + ringsvg)
    return render(svg_doc(24, 22, body), 24, 22)


def switch(on):
    # 28x16 so it fits the 14px rows of the option cards
    track, edge, knob, x = (('#2f7d4a', '#6fe08a', '#ffffff', 20) if on else ('#1d2f58', '#34508a', '#96aacd', 8))
    body = (f'<rect x=".75" y=".75" width="26.5" height="14.5" rx="7.25" fill="{track}" stroke="{edge}" stroke-width="1"/>'
            f'<circle cx="{x}" cy="8" r="5.3" fill="{knob}"/>')
    return render(svg_doc(28, 16, body), 28, 16)


def slider_parts():
    track = render(svg_doc(16, 6, '<rect width="16" height="6" rx="3" fill="#1d2f58"/>'), 16, 6)
    fill = render(svg_doc(16, 6, '<rect width="16" height="6" rx="3" fill="#7fb2ff"/>'), 16, 6)
    # 13px: the scroll bar sizes its slider to 13 with default-scroll
    knob = render(svg_doc(13, 13, '<circle cx="6.5" cy="6.5" r="5.4" fill="#efe6cf" stroke="#0c1730" stroke-width="1.6"/>'), 13, 13)
    return track, fill, knob


def main():
    for d in (HOTKEYS, OPTIONS):
        d.mkdir(parents=True, exist_ok=True)
    header_icon('keyboard').save(HOTKEYS / 'icon_hotkeys.png')
    header_icon('gear').save(OPTIONS / 'icon_settings.png')
    for key in SMALL:
        render(svg_doc(16, 16, glyph(key, 0, 0, 16)), 16, 16).save(HOTKEYS / f'icon_{key}.png')
    for key in ACTIONS:
        render(svg_doc(20, 20, glyph(key, 0, 0, 20, bg='#14244a')), 20, 20).save(HOTKEYS / f'act_{key}.png')
    keycap('#2b4580', '#1e3364', '#4b6cab', '#14244a').save(HOTKEYS / 'key.png')
    keycap('#7a2b2b', '#5a1f24', '#ff6b5f', '#3a1216').save(HOTKEYS / 'key_bad.png')
    keycap('#0b1427', '#0b1427', '#2c4a82', '#0b1427').save(HOTKEYS / 'key_empty.png')
    keycap('#0b1427', '#0b1427', '#ffd75a', '#0b1427', ring='#ffd75a').save(HOTKEYS / 'key_capture.png')
    switch(False).save(OPTIONS / 'switch_off.png')
    switch(True).save(OPTIONS / 'switch_on.png')
    track, fill, knob = slider_parts()
    track.save(OPTIONS / 'slider_track.png')
    fill.save(OPTIONS / 'slider_fill.png')
    knob.save(OPTIONS / 'slider_knob.png')


if __name__ == '__main__':
    main()
