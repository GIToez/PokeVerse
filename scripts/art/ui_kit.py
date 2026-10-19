#!/usr/bin/env python3
"""The PokeVerse UI kit: direction D of docs/ui-redesign.md (see-through navy cards, hairline
edge, gold accent) drawn into the images the client's shared styles use.

    scripts/art/ui_kit.py

Writes under core/client-redemption/pokeverse-modern:
  data/images/ui/            Redemption's names, so every style that uses them changes at once:
                             miniwindow_body, miniwindow_header, miniwindow_buttons, scrollbar,
                             buttons, item, window, and the controls (text fields, combo boxes,
                             check boxes, tabs, chat tabs, small buttons, flat panels, frames,
                             popup menus, progress bars)
  data/images/automap/       automap_buttons (the minimap zoom and full map buttons)
  data/images/inventory/     containerslot
  modules/game_dailytasks/images/window   the popup frame 15 PokeVerse windows share
  modules/game_npcdialog/images           panel, inset, word and goodbye buttons
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
WINDOW_ALPHA = 1.0     # popups hold text and stack over each other, so text behind must not show
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


# --- controls -----------------------------------------------------------------------------
# Same size and state layout as the sheets they replace, so no style has to move a clip.

FIELD = (8, 14, 26)
FIELD_ALPHA = 0.85
RAISED = (27, 42, 70)


def well(w, h, r=3, fill=FIELD, alpha=FIELD_ALPHA, edge=0.6):
    """An inset box: text fields, list and panel wells."""
    im = canvas(w, h)
    ImageDraw.Draw(im).rounded_rectangle((0, 0, im.width - 1, im.height - 1), s(r), fill=rgba(fill, alpha),
                                         outline=rgba(EDGE, edge) if edge else None, width=s(1))
    return im


def frame_only(w, h, r=3, alpha=0.6):
    im = canvas(w, h)
    ImageDraw.Draw(im).rounded_rectangle((0, 0, im.width - 1, im.height - 1), s(r), outline=rgba(EDGE, alpha),
                                         width=s(1))
    return im


def chevron(d, cx, cy, color, size=3.0):
    d.line([(cx - s(size), cy - s(size / 2)), (cx, cy + s(size / 2)), (cx + s(size), cy - s(size / 2))],
           fill=color, width=s(1.4), joint='curve')


def combobox(w, h, rows, arrow=21, r=3):
    """ComboBox sheets: rows of (state) bands h tall, then the popup background band.
    states: 'normal', 'open', 'on'."""
    im = canvas(w, h * (len(rows) + 1))
    d = ImageDraw.Draw(im)
    for i, state in enumerate(rows):
        y0, y1 = s(h * i), s(h * (i + 1)) - 1
        fill = HOVER if state == 'open' else FIELD
        edge = rgba(GOLD, 0.9) if state == 'open' else rgba(EDGE, 0.7)
        d.rounded_rectangle((0, y0, im.width - 1, y1), s(r), fill=rgba(fill, 0.92), outline=edge, width=s(1))
        ax = im.width - s(arrow / 2) - s(1)
        d.line((im.width - s(arrow), y0 + s(4), im.width - s(arrow), y1 - s(4)), fill=rgba(EDGE, 0.5), width=s(1))
        if state != 'on':
            chevron(d, ax, (y0 + y1) // 2, rgba(GOLD if state == 'open' else MUTED))
    y0 = s(h * len(rows))
    d.rounded_rectangle((0, y0, im.width - 1, im.height - 1), s(r), fill=rgba(BODY, 0.97), outline=rgba(EDGE),
                        width=s(1))
    return im


def check_box(size, state, round_=False):
    """state: 'off', 'on', 'on-disabled'."""
    im = canvas(size, size)
    d = ImageDraw.Draw(im)
    box = (s(0.5), s(0.5), im.width - 1 - s(0.5), im.height - 1 - s(0.5))
    on = state != 'off'
    fill = rgba(GOLD, 0.45 if state == 'on-disabled' else 1) if on else rgba(FIELD, 0.9)
    edge = None if on else rgba(MUTED, 0.6)
    if round_:
        d.ellipse(box, fill=rgba(FIELD, 0.9), outline=rgba(GOLD if on else MUTED, 1 if on else 0.6), width=s(1.2))
        if on:
            k = size * 0.27
            d.ellipse((s(k), s(k), im.width - s(k), im.height - s(k)), fill=fill)
        return im
    d.rounded_rectangle(box, s(size * 0.25), fill=fill, outline=edge, width=s(1))
    if on:
        u = size / 12
        d.line([(s(3 * u), s(6.2 * u)), (s(5.2 * u), s(8.4 * u)), (s(9.2 * u), s(3.8 * u))], fill=rgba(CHIP),
               width=s(1.6 * u), joint='curve')
    return im


def sheet(cells, w, pitch, h=None):
    """Stack images vertically every `pitch` px."""
    im = canvas(w, pitch * (len(cells) - 1) + (h or pitch))
    for i, cell in enumerate(cells):
        im.alpha_composite(cell, (0, s(pitch * i)))
    return im


def tab(w, h, state, r=3, gold_line=True):
    """A tab with rounded top corners; state 'normal', 'hover' or 'checked'. The tab styles use
    image-border 3, so the radius stays 3 and the gold line reaches into the corners' columns:
    the middle columns are tiled, and a line that stops short of them comes out dashed."""
    im = canvas(w, h)
    d = ImageDraw.Draw(im)
    fill = {'normal': (rgba(FIELD, 0.75)), 'hover': rgba(HOVER, 0.85), 'checked': rgba(RAISED, 0.97)}[state]
    d.rounded_rectangle((0, 0, im.width - 1, im.height - 1 + s(r)), s(r), fill=fill,
                        outline=rgba(EDGE, 0.8 if state == 'checked' else 0.45), width=s(1))
    if state == 'checked' and gold_line:
        d.rectangle((s(r - 1), im.height - s(2), im.width - 1 - s(r - 1), im.height - 1), fill=rgba(GOLD))
    return im


def small_button(w, h, state, r=4):
    im = canvas(w, h)
    fill = {'normal': rgba(RAISED, 0.95), 'hover': rgba(HOVER, 0.95), 'pressed': rgba((20, 31, 54), 0.95)}[state]
    edge = rgba(GOLD) if state == 'pressed' else rgba(EDGE)
    ImageDraw.Draw(im).rounded_rectangle((0, 0, im.width - 1, im.height - 1), s(r), fill=fill, outline=edge,
                                         width=s(1))
    return im


def progress_frame(w=80, h=16):
    """Drawn over the bar's background-color fill, so the inside stays clear."""
    im = canvas(w, h)
    d = ImageDraw.Draw(im)
    d.rounded_rectangle((0, 0, im.width - 1, im.height - 1), s(2), outline=rgba(CHIP, 0.9), width=s(1.5))
    d.rounded_rectangle((s(1), s(1), im.width - 1 - s(1), im.height // 2), s(1.5), fill=(255, 255, 255, 28))
    return im


def automap_buttons():
    """automap_buttons, 40x60: rows full map, zoom out, zoom in; column 0 normal, column 20 pressed."""
    im = canvas(40, 60)
    d = ImageDraw.Draw(im)
    for col in range(2):
        for row in range(3):
            x0, y0 = s(20 * col), s(20 * row)
            d.rounded_rectangle((x0 + s(1), y0 + s(1), x0 + s(19) - 1, y0 + s(19) - 1), s(5),
                                fill=rgba(HOVER if col else RAISED, 0.95), outline=rgba(GOLD if col else EDGE),
                                width=s(1))
            cx, cy, ink = x0 + s(10), y0 + s(10), rgba(TEXT)
            if row == 0:
                pts = [(-5, -3.5), (-1.7, -5), (1.7, -3.5), (5, -5), (5, 3.5), (1.7, 5), (-1.7, 3.5), (-5, 5)]
                d.polygon([(cx + s(x), cy + s(y)) for x, y in pts], outline=ink, width=s(1.3))
                d.line((cx - s(1.7), cy - s(5), cx - s(1.7), cy + s(3.5)), fill=ink, width=s(1.1))
                d.line((cx + s(1.7), cy - s(3.5), cx + s(1.7), cy + s(5)), fill=ink, width=s(1.1))
            else:
                d.line((cx - s(4), cy, cx + s(4), cy), fill=ink, width=s(1.8))
                if row == 2:
                    d.line((cx, cy - s(4), cx, cy + s(4)), fill=ink, width=s(1.8))
    return im


# --- chat ---------------------------------------------------------------------------------

def round_icon(d, cx, cy, state, draw):
    """A 16 px round button: 'normal' (muted icon), 'pressed' (gold disc, dark icon), 'off' (dim)."""
    r = s(7)
    fill = {'normal': rgba(TEXT, 0.10), 'pressed': rgba(GOLD, 0.9), 'off': rgba(TEXT, 0.05)}[state]
    d.ellipse((cx - r, cy - r, cx + r, cy + r), fill=fill)
    ink = {'normal': rgba(MUTED), 'pressed': rgba(CHIP), 'off': rgba(MUTED, 0.35)}[state]
    draw(d, cx, cy, ink)


def _line(d, cx, cy, ink, *pts, w=1.4):
    d.line([(cx + s(x), cy + s(y)) for x, y in pts], fill=ink, width=s(w), joint='curve')


def icon_folder(d, cx, cy, ink):
    _line(d, cx, cy, ink, (-4, -2.5), (-1.5, -2.5), (-0.5, -1.5), (4, -1.5), (4, 3), (-4, 3), (-4, -2.5))


def icon_message(d, cx, cy, ink):
    d.rounded_rectangle((cx - s(4), cy - s(3.2), cx + s(4), cy + s(2)), s(1.5), outline=ink, width=s(1.3))
    _line(d, cx, cy, ink, (-1.5, 2), (-2.5, 4), (0.5, 2))


def icon_ignore(d, cx, cy, ink):
    d.ellipse((cx - s(3.6), cy - s(3.6), cx + s(3.6), cy + s(3.6)), outline=ink, width=s(1.3))
    _line(d, cx, cy, ink, (-2.5, 2.5), (2.5, -2.5), w=1.3)


def icon_close(d, cx, cy, ink):
    _line(d, cx, cy, ink, (-2.6, -2.6), (2.6, 2.6))
    _line(d, cx, cy, ink, (-2.6, 2.6), (2.6, -2.6))


def icon_lock(locked):
    def draw(d, cx, cy, ink):
        d.rounded_rectangle((cx - s(3), cy - s(0.5), cx + s(3), cy + s(3.5)), s(0.8), fill=ink)
        box = (cx - s(2), cy - s(4), cx + s(2), cy + s(0.5)) if locked else (cx, cy - s(4.2), cx + s(4), cy + s(0.3))
        d.arc(box, 180, 360, fill=ink, width=s(1.2))
        if locked:
            _line(d, cx, cy, ink, (-2, -1.8), (-2, -0.5), w=1.2)
            _line(d, cx, cy, ink, (2, -1.8), (2, -0.5), w=1.2)
    return draw


def icon_dots(d, cx, cy, ink):
    for dx in (-2.8, 0, 2.8):
        d.ellipse((cx + s(dx) - s(1), cy - s(1), cx + s(dx) + s(1), cy + s(1)), fill=ink)


def icon_target(d, cx, cy, ink):
    d.ellipse((cx - s(3.4), cy - s(3.4), cx + s(3.4), cy + s(3.4)), outline=ink, width=s(1.2))
    d.ellipse((cx - s(1), cy - s(1), cx + s(1), cy + s(1)), fill=ink)


def console_buttons():
    """console_buttons, 48x111: rows channels (0), message (16), ignore (32), close (48),
    draggable lock (64: unlocked, locked), hide (80), exiva (95: on, pressed, off). Column 0 normal,
    16 pressed or checked."""
    im = canvas(48, 111)
    d = ImageDraw.Draw(im)
    rows = [(0, icon_folder), (16, icon_message), (32, icon_ignore), (48, icon_close), (80, icon_dots)]
    for y, draw in rows:
        for col, state in enumerate(('normal', 'pressed')):
            round_icon(d, s(16 * col + 8), s(y + 8), state, draw)
    round_icon(d, s(8), s(72), 'normal', icon_lock(False))
    round_icon(d, s(24), s(72), 'pressed', icon_lock(True))
    for col, state in enumerate(('normal', 'pressed', 'off')):
        round_icon(d, s(16 * col + 8), s(103), state, icon_target)
    return im


def chat_arrows(left):
    """console_flash_left/right, 54x18: normal, pressed, disabled."""
    im = canvas(54, 18)
    d = ImageDraw.Draw(im)
    k = -1 if left else 1
    for col, state in enumerate(('normal', 'pressed', 'off')):
        cx, cy = s(18 * col + 9), s(9)
        round_icon(d, cx, cy, state, lambda d, cx, cy, ink: _line(d, cx, cy, ink, (-k * 1.3, -2.6), (k * 1.3, 0),
                                                                     (-k * 1.3, 2.6), w=1.6))
    return im


def say_mode(kind):
    """console_say/whisper/yell, 36x18: normal, pressed. A speech bubble: whisper small, yell with a !."""
    im = canvas(36, 18)
    d = ImageDraw.Draw(im)
    for col, state in enumerate(('normal', 'pressed')):
        def draw(d, cx, cy, ink):
            k = 0.7 if kind == 'whisper' else 1.0
            d.rounded_rectangle((cx - s(4.5 * k), cy - s(3.5 * k), cx + s(4.5 * k), cy + s(2.2 * k)), s(2 * k),
                                outline=ink, width=s(1.3))
            _line(d, cx, cy, ink, (-2 * k, 2.2 * k), (-3 * k, 4.2 * k), (0, 2.2 * k), w=1.2)
            if kind == 'yell':
                _line(d, cx, cy, ink, (0, -2.2), (0, -0.2), w=1.4)
                d.ellipse((cx - s(0.7), cy + s(0.6), cx + s(0.7), cy + s(1.6)), fill=ink)
        cx, cy = s(18 * col + 9), s(9)
        r = s(8)
        d.ellipse((cx - r, cy - r, cx + r, cy + r), fill=rgba(GOLD, 0.9) if col else rgba(RAISED, 0.95),
                  outline=None if col else rgba(EDGE), width=s(1))
        draw(d, cx, cy, rgba(CHIP) if col else rgba(TEXT))
    return im


def qt_scrollbar(vertical):
    """scrollbar_new_vertical (34x78): track (0,0,10,78), up (10,0) up pressed (10,12) down (10,24)
    down pressed (10,36), 12x12; slider (22,0,12,44), border 7 top and bottom.
    scrollbar_new_horizontal (78x34) is the same turned: track (0,0,78,10), left (42,10) left pressed
    (30,10) right (66,10) right pressed (54,10); slider (34,22,44,12)."""
    im = canvas(34, 78)
    d = ImageDraw.Draw(im)
    d.rounded_rectangle((s(3.5), s(1), s(6.5), s(77)), s(1.5), fill=rgba(TEXT, 0.08))
    for i, (up, pressed) in enumerate([(True, False), (True, True), (False, False), (False, True)]):
        cx, cy = s(16), s(12 * i + 6)
        k = -1 if up else 1
        _line(d, cx, cy, rgba(GOLD) if pressed else rgba(MUTED, 0.8), (-2.6, -k * 1.3), (0, k * 1.3), (2.6, -k * 1.3))
    d.rounded_rectangle((s(25), s(1), s(31), s(43)), s(3), fill=rgba(MUTED, 0.75))
    if vertical:
        return im
    # the horizontal sheet: the vertical one turned, with the buttons in their own places
    h = canvas(78, 34)
    hd = ImageDraw.Draw(h)
    hd.rounded_rectangle((s(1), s(3.5), s(77), s(6.5)), s(1.5), fill=rgba(TEXT, 0.08))
    for x, left, pressed in [(42, True, False), (30, True, True), (66, False, False), (54, False, True)]:
        cx, cy = s(x + 6), s(16)
        k = -1 if left else 1
        _line(hd, cx, cy, rgba(GOLD) if pressed else rgba(MUTED, 0.8), (-k * 1.3, -2.6), (k * 1.3, 0), (-k * 1.3, 2.6))
    hd.rounded_rectangle((s(35), s(25), s(77), s(31)), s(3), fill=rgba(MUTED, 0.75))
    return h


def read_only_icon():
    """game/console/readOnly, 96x16: the button that splits the chat into a second, read-only list."""
    im = card(96, 16, 4, 0.9)
    d = ImageDraw.Draw(im)
    ink = rgba(MUTED)
    cx, cy = s(38), s(8)
    d.ellipse((cx - s(5), cy - s(3.2), cx + s(5), cy + s(3.2)), outline=ink, width=s(1.2))
    d.ellipse((cx - s(1.6), cy - s(1.6), cx + s(1.6), cy + s(1.6)), fill=ink)
    for y, x1 in ((5, 64), (8, 60), (11, 56)):
        d.line((s(47), s(y), s(x1), s(y)), fill=rgba(MUTED, 0.7), width=s(1.2))
    return im


def chat(ui, kit):
    save(console_buttons(), ui / 'console_buttons.png')
    save(chat_arrows(True), ui / 'console_flash_left.png')
    save(chat_arrows(False), ui / 'console_flash_right.png')
    for kind in ('say', 'whisper', 'yell'):
        save(say_mode(kind), ui / f'console_{kind}.png')
    save(qt_scrollbar(True), ui / 'scrollbar_new_vertical.png')
    save(qt_scrollbar(False), ui / 'scrollbar_new_horizontal.png')
    save(read_only_icon(), ui.parent / 'game/console/readOnly.png')
    save(card(32, 32, 8, 0.9), kit / 'chat-body.png')                         # GameBottomPanel, border 8
    save(well(24, 24, 6, FIELD, 0.45, 0.35), kit / 'chat-buffer.png')        # the message list, border 6


def npc_dialog(out):
    """game_npcdialog: panel (border 10), inset (border 6), word and goodbye buttons (20x22, border 7).
    Yes and No keep their green and red."""
    save(card(32, 32, 8, 0.96), out / 'panel.png')
    save(well(20, 20, 5), out / 'inset.png')
    for name in ('word', 'goodbye'):
        save(small_button(20, 22, 'normal', 6), out / f'{name}.png')
        save(small_button(20, 22, 'hover', 6), out / f'{name}-hover.png')


def controls(ui):
    save(well(32, 32, 3), ui / 'textedit.png')                       # TextEdit, border 4 in controls.otui
    save(combobox(98, 20, ['normal', 'open', 'on']), ui / 'combobox_square.png')
    save(combobox(91, 20, ['normal', 'open', 'on'], 22), ui / 'combobox_new.png')
    save(combobox(91, 23, ['normal', 'open', 'on']), ui / 'combobox_rounded.png')
    save(sheet([check_box(12, s_) for s_ in ('off', 'on', 'on-disabled')], 12, 12), ui / 'checkbox.png')
    save(sheet([check_box(12, s_, True) for s_ in ('off', 'on', 'on-disabled')], 12, 12), ui / 'checkboxcircle.png')
    save(sheet([check_box(12, s_, True) for s_ in ('off', 'on')], 12, 12), ui / 'checkbox_round.png')
    save(sheet([check_box(13, s_) for s_ in ('off', 'on', 'on-disabled')], 14, 13, 14), ui / 'newcheckbox.png')
    save(check_box(12, 'off'), ui / 'checkbox-unchecked.png')
    save(check_box(12, 'on'), ui / 'checkbox-checked.png')
    save(check_box(12, 'on-disabled'), ui / 'checkbox-checked-disabled.png')
    save(sheet([tab(96, 18, st) for st in ('normal', 'hover', 'checked')], 96, 18, 21), ui / 'tabbutton_square.png')
    save(sheet([tab(22, 23, st) for st in ('normal', 'hover', 'checked')], 22, 23), ui / 'tabbutton_rounded.png')
    save(sheet([tab(114, 21, st, gold_line=False) for st in ('normal', 'checked')], 114, 21),
         ui / 'tabbutton_new_shadowed.png')
    save(sheet([tab(96, 18, 'checked'), tab(96, 18, 'normal')], 96, 18), ui / 'console_button.png')
    for name in ('button', 'button_rounded'):
        save(sheet([small_button(22, 23, st) for st in ('normal', 'hover', 'pressed')], 22, 23), ui / f'{name}.png')
    save(small_button(98, 40, 'normal'), ui / 'button-9grid-idle.png')
    save(small_button(98, 40, 'pressed'), ui / 'button-9grid-pressed.png')
    save(well(32, 32, 3, alpha=0.55, edge=0.45), ui / 'panel_flat.png')       # border 4 in controls.otui
    save(well(32, 32, 3, RAISED, 0.6, 0.45), ui / 'panel_lightflat.png')
    save(well(100, 100, 3, alpha=0.5, edge=0.5), ui / '2pixel_up_frame_borderimage.png')
    save(frame_only(100, 100, 2), ui / '2pixel_up_frame_borderimage_dark.png')
    save(frame_only(96, 96, 1), ui / '1pixel-down-frame.png')
    save(frame_only(96, 96, 1, 0.8), ui / '1pixel_down_frame.png')           # the minimap frame
    save(automap_buttons(), ui.parent / 'automap/automap_buttons.png')
    save(card(102, 102, 4, 0.97), ui / '3pixel_frame_borderimage.png')        # popup menus, border 4
    save(card(256, 256, 4, WINDOW_ALPHA), ui / 'window_new.png')
    save(card(256, 239, 4, WINDOW_ALPHA), ui / 'window_headless.png')
    save(progress_frame(), ui / 'progressbar.png')


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
    controls(ui)
    chat(ui, OVERLAY / 'data/images/pokeverse-ui')
    npc_dialog(OVERLAY / 'modules/game_npcdialog/images')

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
    # the NPC shop's offer boxes (game_npctrade), image-border 6
    save(well(24, 24, 6, SLOT, 0.8, 0.6), kit / 'offer.png')
    save(well(24, 24, 6, HOVER, 0.9, 0), kit / 'offer-hover.png')
    offer = well(24, 24, 6, RAISED, 0.95, 0)
    ImageDraw.Draw(offer).rounded_rectangle((0, 0, offer.width - 1, offer.height - 1), s(6), outline=rgba(GOLD),
                                            width=s(1.5))
    save(offer, kit / 'offer-selected.png')


if __name__ == '__main__':
    main()
