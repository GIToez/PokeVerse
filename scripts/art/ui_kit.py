#!/usr/bin/env python3
"""The PokeVerse UI kit: direction D of docs/ui-redesign.md (see-through navy cards, hairline
edge, gold accent) drawn into the images the client's shared styles use.

    scripts/art/ui_kit.py

Writes under core/client-redemption/pokeverse-modern:
  data/images/ui/            Redemption's names, so every style that uses them changes at once:
                             miniwindow_body, miniwindow_header, miniwindow_buttons, scrollbar,
                             buttons, item, window
  data/images/inventory/     containerslot
  modules/game_dailytasks/images/window   the popup frame 15 PokeVerse windows share
  data/images/pokeverse-ui/  the PokeVerse pieces: sockets, chips, the move slot and its type edges

Frames are 9-slice images; the border each style must use is noted next to it.
"""
import sys
from pathlib import Path

from PIL import Image, ImageDraw

sys.path.insert(0, str(Path(__file__).parent))
from login_ui import SCALE, canvas, s  # noqa: E402

REPO = Path(__file__).resolve().parents[2]
OVERLAY = REPO / 'core/client-redemption/pokeverse-modern'

# the tokens (docs/ui-redesign.md)
BODY = (14, 23, 41)
SIDE_ALPHA = 0.72      # side windows: the map shows through
WINDOW_ALPHA = 0.94    # popups hold more text and stack over each other, so barely see-through
EDGE = (55, 82, 132)
EDGE_ALPHA = 0.5
GOLD = (217, 170, 59)
TEXT = (238, 242, 255)
MUTED = (180, 194, 220)
SLOT = (10, 18, 31)
SLOT_ALPHA = 0.55
CHIP = (6, 10, 20)
HOVER = (40, 62, 104)

TYPE_COLORS = {
    'normal': (184, 178, 160), 'fire': (240, 138, 60), 'water': (79, 156, 240), 'grass': (92, 196, 106),
    'electric': (242, 207, 58), 'ice': (126, 216, 230), 'fighting': (200, 80, 60), 'poison': (170, 90, 200),
    'ground': (216, 176, 96), 'flying': (143, 182, 240), 'psychic': (240, 100, 150), 'bug': (160, 190, 50),
    'rock': (184, 160, 90), 'ghost': (110, 90, 160), 'dragon': (140, 108, 240), 'dark': (122, 106, 90),
    'steel': (159, 180, 200), 'fairy': (240, 160, 210),
}


def rgba(c, a=1.0):
    return tuple(c[:3]) + (int(round(255 * a)),)


def save(im, path):
    path.parent.mkdir(parents=True, exist_ok=True)
    im.resize((im.width // SCALE, im.height // SCALE), Image.LANCZOS).save(path)
    print(path.relative_to(REPO))


def card(w, h, r, alpha, edge=True):
    im = canvas(w, h)
    ImageDraw.Draw(im).rounded_rectangle((0, 0, im.width - 1, im.height - 1), s(r), fill=rgba(BODY, alpha),
                                         outline=rgba(EDGE, EDGE_ALPHA) if edge else None, width=s(1))
    return im


def slot(size, r=6, alpha=SLOT_ALPHA, edge=None):
    im = canvas(size, size)
    ImageDraw.Draw(im).rounded_rectangle((0, 0, im.width - 1, im.height - 1), s(r), fill=rgba(SLOT, alpha),
                                         outline=edge, width=s(1.2) if edge else 0)
    return im


# --- side windows ------------------------------------------------------------------------

def miniwindow_body():
    """MiniWindow, image-border: 8."""
    return card(32, 32, 7, SIDE_ALPHA)


def window_buttons():
    """miniwindow_buttons: 10 icons of 14x14 by 3 rows (normal, hover, pressed), in Redemption's
    order: minimise, maximise, close, up, filter, dot, lock, unlock, menu, new window."""
    im = canvas(140, 42)
    d = ImageDraw.Draw(im)
    for row, (circle, color) in enumerate([(0.10, MUTED), (0.22, TEXT), (0.9, GOLD)]):
        for i in range(10):
            cx, cy, r = s(14 * i + 7), s(14 * row + 7), s(6)
            d.ellipse((cx - r, cy - r, cx + r, cy + r), fill=rgba(TEXT if row < 2 else GOLD, circle))
            ink = rgba(CHIP if row == 2 else color)
            w = s(1.4)
            u = s(1)

            def line(*pts):
                d.line([(cx + x * u, cy + y * u) for x, y in pts], fill=ink, width=w, joint='curve')
            if i == 0:
                line((-2.8, 0), (2.8, 0))
            elif i == 1:
                line((-2.8, 0), (2.8, 0)); line((0, -2.8), (0, 2.8))
            elif i == 2:
                line((-2.4, -2.4), (2.4, 2.4)); line((-2.4, 2.4), (2.4, -2.4))
            elif i == 3:
                line((-2.6, 1.4), (0, -1.4), (2.6, 1.4))
            elif i == 4:
                line((-3, -2.2), (3, -2.2), (0.8, 0.6), (0.8, 2.8), (-0.8, 2), (-0.8, 0.6), (-3, -2.2))
            elif i == 5:
                d.ellipse((cx - s(1.6), cy - s(1.6), cx + s(1.6), cy + s(1.6)), fill=ink)
            elif i in (6, 7):
                d.rounded_rectangle((cx - s(2.8), cy - s(0.6), cx + s(2.8), cy + s(3.2)), s(0.8), fill=ink)
                if i == 6:
                    d.arc((cx - s(1.9), cy - s(3.6), cx + s(1.9), cy + s(0.4)), 180, 360, fill=ink, width=s(1.2))
                    line((-1.9, -1.6), (-1.9, -0.4)); line((1.9, -1.6), (1.9, -0.4))
                else:
                    d.arc((cx - s(0.2), cy - s(3.8), cx + s(3.6), cy + s(0.2)), 180, 360, fill=ink, width=s(1.2))
            elif i == 8:
                for dx in (-2.6, 0, 2.6):
                    d.ellipse((cx + s(dx) - s(0.9), cy - s(0.9), cx + s(dx) + s(0.9), cy + s(0.9)), fill=ink)
            elif i == 9:
                d.rounded_rectangle((cx - s(3), cy - s(2.2), cx + s(2.2), cy + s(3)), s(0.8), outline=ink, width=s(1.2))
                line((0.4, -3), (3, -3), (3, -0.4))
    return im


def scrollbar():
    """scrollbar, 36x74: arrows at (0,0) (12,0) (0,12) (12,12), the vertical slider at (0,24) 12x14,
    the horizontal slider at (12,26) 12x12, the vertical track at (24,0) 12x74. Slider border 6."""
    im = canvas(36, 74)
    d = ImageDraw.Draw(im)
    ink, pressed = rgba(MUTED, 0.8), rgba(GOLD)
    for col, color in enumerate([ink, pressed]):
        for row, up in enumerate([True, False]):
            cx, cy = s(12 * col + 6), s(12 * row + 6)
            k = -1 if up else 1
            d.line([(cx - s(2.6), cy - k * s(1.3)), (cx, cy + k * s(1.3)), (cx + s(2.6), cy - k * s(1.3))],
                   fill=color, width=s(1.4), joint='curve')
    # sliders: a slim pill
    d.rounded_rectangle((s(3), s(24.5), s(9), s(37.5)), s(3), fill=rgba(MUTED, 0.75))
    d.rounded_rectangle((s(12.5), s(29), s(23.5), s(35)), s(3), fill=rgba(MUTED, 0.75))
    # track: a faint line
    d.rounded_rectangle((s(28.5), s(1), s(31.5), s(73)), s(1.5), fill=rgba(TEXT, 0.08))
    return im


def buttons():
    """buttons, 43x40: normal at (0,0), pressed/checked at (0,20). image-border: 5 in the override."""
    im = canvas(43, 40)
    d = ImageDraw.Draw(im)
    d.rounded_rectangle((0, 0, im.width - 1, s(20) - s(1)), s(5), fill=rgba((27, 42, 70), 0.95),
                        outline=rgba(EDGE), width=s(1))
    d.rounded_rectangle((0, s(20), im.width - 1, im.height - 1), s(5), fill=rgba((20, 31, 54), 0.95),
                        outline=rgba(GOLD), width=s(1.2))
    return im


def window():
    """window (MainWindow and every Window), 256x256: Redemption's image-border 6, image-border-top 27,
    which the styles derived from Window copied, so the corner radius stays within 6 px.
    A hairline under the 27 px title band."""
    im = card(256, 256, 6, WINDOW_ALPHA)
    d = ImageDraw.Draw(im)
    d.line((s(6), s(26), im.width - s(6), s(26)), fill=rgba(EDGE, 0.6), width=s(1))
    return im


def popup_frame():
    """game_dailytasks/images/window, 64x64: image-border 24 (kept, the 15 modules set it)."""
    return card(64, 64, 10, WINDOW_ALPHA)


# --- PokeVerse pieces ---------------------------------------------------------------------

def socket(size, state='normal'):
    """A round portrait socket for the swap bar: normal, hover, or active (the Pokemon that is out)."""
    im = canvas(size, size)
    d = ImageDraw.Draw(im)
    d.ellipse((0, 0, im.width - 1, im.height - 1), fill=rgba(HOVER if state == 'hover' else SLOT, 0.7))
    if state == 'active':
        d.ellipse((0, 0, im.width - 1, im.height - 1), outline=rgba(GOLD), width=s(2))
    return im


SOCKET = 46  # the swap bar socket (game_pokebar QuickCallSlot)
RING_STEPS = 20


def ring_strip(size, color, width=3):
    """The HP ring around a socket, RING_STEPS + 1 frames side by side (frame i = i / RING_STEPS
    of the health), clockwise from 12 o'clock over a faint track."""
    im = canvas(size * (RING_STEPS + 1), size)
    d = ImageDraw.Draw(im)
    w = s(width)
    for i in range(RING_STEPS + 1):
        x0 = s(size * i)
        box = (x0 + w // 2, w // 2, x0 + s(size) - 1 - w // 2, im.height - 1 - w // 2)
        d.ellipse(box, outline=rgba(TEXT, 0.14), width=w)
        if i:
            d.arc(box, -90, -90 + 360 * i / RING_STEPS, fill=rgba(color), width=w)
    return im


def chip(w, h, alpha=0.88):
    """A pill for keys, levels and costs; image-border h/2."""
    im = canvas(w, h)
    ImageDraw.Draw(im).rounded_rectangle((0, 0, im.width - 1, im.height - 1), s(h / 2), fill=rgba(CHIP, alpha))
    return im


def move_slot(edge):
    """The moves bar slot, 40x40, with a type-coloured edge."""
    return slot(40, 9, 0.6, rgba(edge))


def cooldown_wedges(size=40, steps=24):
    """Radial cooldown: frame i darkens what is still to wait, from 12 o'clock clockwise."""
    im = Image.new('RGBA', (size * steps * SCALE, size * SCALE), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    for i in range(steps):
        left = 1 - i / steps
        x0 = i * size * SCALE
        box = (x0 - s(size), -s(size), x0 + s(size * 2), s(size * 2))
        d.pieslice(box, -90 + 360 * (1 - left), 270, fill=(0, 0, 0, 165))
    # keep each frame inside its own rounded square
    mask = Image.new('L', im.size, 0)
    md = ImageDraw.Draw(mask)
    for i in range(steps):
        x0 = i * size * SCALE
        md.rounded_rectangle((x0 + s(1), s(1), x0 + s(size - 1), s(size - 1)), s(8), fill=255)
    out = Image.new('RGBA', im.size, (0, 0, 0, 0))
    out.paste(im, (0, 0), mask)
    return out


def lock_badge():
    im = canvas(16, 16)
    d = ImageDraw.Draw(im)
    d.rounded_rectangle((s(3.5), s(7), s(12.5), s(14)), s(1.5), fill=rgba(TEXT))
    d.arc((s(5), s(2.5), s(11), s(9.5)), 180, 360, fill=rgba(TEXT), width=s(1.6))
    d.line((s(5.2), s(6), s(5.2), s(7.5)), fill=rgba(TEXT), width=s(1.6))
    d.line((s(10.8), s(6), s(10.8), s(7.5)), fill=rgba(TEXT), width=s(1.6))
    return im


def underline():
    im = canvas(22, 2)
    ImageDraw.Draw(im).rounded_rectangle((0, 0, im.width - 1, im.height - 1), s(1), fill=rgba(GOLD))
    return im


def main():
    ui = OVERLAY / 'data/images/ui'
    save(miniwindow_body(), ui / 'miniwindow_body.png')
    Image.new('RGBA', (16, 15), (0, 0, 0, 0)).save(ui / 'miniwindow_header.png')
    print((ui / 'miniwindow_header.png').relative_to(REPO))
    save(window_buttons(), ui / 'miniwindow_buttons.png')
    save(scrollbar(), ui / 'scrollbar.png')
    save(buttons(), ui / 'buttons.png')
    save(slot(34), ui / 'item.png')
    save(window(), ui / 'window.png')
    save(slot(34), OVERLAY / 'data/images/inventory/containerslot.png')
    save(popup_frame(), OVERLAY / 'modules/game_dailytasks/images/window.png')

    kit = OVERLAY / 'data/images/pokeverse-ui'
    save(underline(), kit / 'title-underline.png')
    save(card(32, 32, 8, WINDOW_ALPHA), kit / 'panel.png')  # popups and cards, image-border 8
    save(chip(16, 12), kit / 'chip.png')
    save(socket(SOCKET), kit / 'socket.png')
    save(socket(SOCKET, 'active'), kit / 'socket-active.png')
    save(socket(SOCKET, 'hover'), kit / 'socket-hover.png')
    for name, color in [('health', (67, 194, 113)), ('mid', (230, 179, 58)), ('low', (224, 86, 106))]:
        save(ring_strip(SOCKET, color), kit / f'ring-{name}.png')
    for kind, color in TYPE_COLORS.items():
        save(move_slot(color), kit / f'move-{kind}.png')
    save(move_slot(EDGE), kit / 'move-empty.png')
    save(cooldown_wedges(), kit / 'cooldown.png')
    save(lock_badge(), kit / 'lock.png')


if __name__ == '__main__':
    main()
