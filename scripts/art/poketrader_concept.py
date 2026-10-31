#!/usr/bin/env python3
"""Concept mock-ups of a PokeTrader auction window (docs/concepts/poketrader).

    scripts/art/poketrader_concept.py

Drawn from the client's own images (the game_dailytasks frame, game_fishing rows, tabs and panels,
client_entergame fields and buttons), its fonts and the item sprites, so it looks like the Event
Shop and Bank windows. Needs the real data.spr (git lfs pull). Writes auction.jpg, mybids.jpg and
phone.jpg; the lots, bids and money are made up.
"""
import math
import os
import sys

from PIL import Image, ImageDraw, ImageFilter, ImageFont

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.normpath(os.path.join(HERE, '..', '..'))
sys.path.insert(0, os.path.join(ROOT, 'scripts/mapper'))
import pvmap  # noqa: E402

MODULES = os.path.join(ROOT, 'core/client-redemption/pokeverse-modern/modules')
FONTS = os.path.join(ROOT, 'core/client-redemption/data/fonts/ttf')
OTB = os.path.join(ROOT, 'core/server/data/items/items.otb')
DAT = os.path.join(ROOT, 'core/client-legacy/data/things/data.dat')
SPR = os.path.join(ROOT, 'core/client-legacy/data/things/data.spr')
BACKDROP = os.path.join(ROOT, 'docs/concepts/side-panel/today.jpg')
OUT = os.path.join(ROOT, 'docs/concepts/poketrader')

TEXT, MUTED, GOLD, WHITE = '#dce6ff', '#96aacd', '#ffd75a', '#ffffff'
GREEN, RED, ORANGE = '#7ee08f', '#ff8a8a', '#ffb45a'

# server item id, name, kind, minimum bid, highest bid, bids, state
LOTS = [
    (31084, 'Dusk Stone', 'Evolution item  -  rare lot', 25000, 31815, 6, 'outbid'),
    (17349, 'TM Ice Beam', 'TM  -  semi-rare lot', 10000, 12120, 4, 'lead'),
    (12240, 'Draco Plate', 'Plate  -  semi-rare lot', 15000, None, 0, 'none'),
    (13305, '100 Lava Cookies', 'Every week', 5000, 5353, 3, 'none'),
    (23546, 'Blue Flute', 'Once per trainer', 1000, 1250, 2, 'owned'),
]
BANK = 148250


def dollars(v):
    return '${:,}'.format(int(v))


def next_bid(highest, minimum):
    return math.ceil(highest * 1.01) if highest else minimum


class Painter:
    def __init__(self, w, h, s, renderer):
        self.s, self.r = s, renderer
        self.img = Image.new('RGBA', (w * s, h * s), (0, 0, 0, 0))
        self.d = ImageDraw.Draw(self.img)
        self.fonts = {}
        self.images = {}

    def font(self, name, size):
        key = (name, size)
        if key not in self.fonts:
            path = {'bold': os.path.join(FONTS, 'arialb.ttf'), 'body': 'DejaVuSans.ttf',
                    'bodyb': 'DejaVuSans-Bold.ttf'}[name]
            self.fonts[key] = ImageFont.truetype(path, round(size * self.s))
        return self.fonts[key]

    def source(self, rel):
        if rel not in self.images:
            img = Image.open(os.path.join(MODULES, rel + '.png')).convert('RGBA')
            self.images[rel] = img.resize((img.width * self.s, img.height * self.s), Image.LANCZOS)
        return self.images[rel]

    def nine(self, rel, x, y, w, h, border, opacity=1.0):
        """An otui image-border box."""
        s, src = self.s, self.source(rel)
        b = border * s
        x, y, w, h = round(x * s), round(y * s), round(w * s), round(h * s)
        sw, sh = src.size
        box = Image.new('RGBA', (w, h))
        xs = [(0, b, 0, b), (b, sw - b, b, w - b), (sw - b, sw, w - b, w)]
        ys = [(0, b, 0, b), (b, sh - b, b, h - b), (sh - b, sh, h - b, h)]
        for sx0, sx1, dx0, dx1 in xs:
            for sy0, sy1, dy0, dy1 in ys:
                if dx1 > dx0 and dy1 > dy0:
                    box.paste(src.crop((sx0, sy0, sx1, sy1)).resize((dx1 - dx0, dy1 - dy0), Image.LANCZOS), (dx0, dy0))
        if opacity < 1:
            box.putalpha(box.getchannel('A').point(lambda a: int(a * opacity)))
        self.img.alpha_composite(box, (x, y))

    def picture(self, rel, x, y, size=None):
        src = self.source(rel)
        if size:
            src = src.resize((size * self.s, size * self.s), Image.LANCZOS)
        self.img.alpha_composite(src, (round(x * self.s), round(y * self.s)))

    def item(self, cid, x, y, size=32, count=1, dim=False):
        attrs, w, h, layers, pxn, pyn, pzn, frames, sprites = self.r['dat'].things[cid]
        pattern = 0
        if pxn * pyn >= 8 and count > 1:
            pattern = 7 if count >= 50 else 6 if count >= 25 else 5 if count >= 10 else min(count, 5) - 1
        xp, yp = pattern % pxn, pattern // pxn
        icon = Image.new('RGBA', (32 * w, 32 * h))
        for layer in range(layers):
            for hy in range(h):
                for wx in range(w):
                    idx = (((yp * pxn + xp) * layers + layer) * h + hy) * w + wx
                    px = self.r['spr'].rgba(sprites[idx]) if idx < len(sprites) else None
                    if px:
                        icon.alpha_composite(Image.frombytes('RGBA', (32, 32), px), ((w - 1 - wx) * 32, (h - 1 - hy) * 32))
        icon = icon.crop((icon.width - 32, icon.height - 32, icon.width, icon.height))
        icon = icon.resize((size * self.s, size * self.s), Image.NEAREST)
        if dim:
            icon = Image.merge('RGBA', (*icon.convert('LA').convert('RGB').split(), icon.getchannel('A').point(lambda a: a // 2)))
        self.img.alpha_composite(icon, (round(x * self.s), round(y * self.s)))

    def text(self, x, y, s, size=11, color=TEXT, font='body', anchor='la'):
        self.d.text((round(x * self.s), round(y * self.s)), s, font=self.font(font, size), fill=color, anchor=anchor)

    def width(self, s, size, font='body'):
        return self.d.textlength(s, font=self.font(font, size)) / self.s

    def tag(self, x, y, label, color, fill, anchor='left'):
        w = self.width(label, 10, 'bold') + 14
        if anchor == 'right':
            x -= w
        self.d.rounded_rectangle([x * self.s, y * self.s, (x + w) * self.s, (y + 17) * self.s], 8 * self.s, fill=fill)
        self.text(x + w / 2, y + 9, label, 10, color, 'bold', 'mm')
        return w

    def button(self, color, x, y, w, h, label, text_color, off=False):
        self.nine('game_dailytasks/images/button_off' if off else f'client_entergame/images/button_{color}', x, y, w, h, 8)
        self.text(x + w / 2, y + h / 2 + 1, label, 12, '#6f7c96' if off else text_color, 'bold', 'mm')

    def chip(self, x, y, label, count=None, on=False):
        w = self.width(label, 11, 'bold') + 24 + (self.width(str(count), 10, 'bold') + 14 if count is not None else 0)
        self.nine('game_fishing/images/tab_on' if on else 'game_fishing/images/tab', x, y, w, 24, 8)
        self.text(x + 12, y + 13, label, 11, WHITE if on else MUTED, 'bold', 'lm')
        if count is not None:
            cx = x + 12 + self.width(label, 11, 'bold') + 6
            self.tag(cx, y + 4, str(count), '#1a1406' if on else TEXT, GOLD if on else '#2a3c60')
        return w

    def save(self, path, backdrop=None):
        img = self.img
        if backdrop:
            bg = Image.open(backdrop).convert('RGB').resize(img.size, Image.LANCZOS).filter(ImageFilter.GaussianBlur(6 * self.s))
            bg = Image.blend(bg, Image.new('RGB', img.size, (8, 12, 22)), 0.55).convert('RGBA')
            bg.alpha_composite(img)
            img = bg
        img.convert('RGB').save(path, quality=92)
        print(path, img.size)


def header(p, x, y, w, subtitle):
    p.item(3043, x, y)
    p.text(x + 40, y - 2, 'PokeTrader Auction', 20, WHITE, 'bold')
    p.text(x + 40, y + 22, subtitle, 11, MUTED)
    p.picture('client_entergame/images/icon_close', x + w - 21, y + 3, 18)
    # the bank, as in the Event Shop and Bank windows
    bx = x + w - 34 - 190
    p.nine('game_fishing/images/panel', bx, y - 4, 190, 42, 10)
    p.item(3031, bx + 8, y + 1, count=100)
    p.text(bx + 46, y + 2, 'In the bank', 11, MUTED)
    p.text(bx + 46, y + 16, dollars(BANK), 15, GOLD, 'bold')


def status_tag(p, x, y, state, highest, anchor='left'):
    if state == 'lead':
        return p.tag(x, y, 'Your bid is the highest', '#0f2414', GREEN, anchor)
    if state == 'outbid':
        return p.tag(x, y, 'Outbid', '#2a0d0d', RED, anchor)
    if state == 'owned':
        return p.tag(x, y, 'You already have one', TEXT, '#3a4664', anchor)
    if not highest:
        return p.tag(x, y, 'No bids yet', TEXT, '#2a3c60', anchor)
    return 0


def lot_row(p, x, y, w, lot, selected=False, h=58):
    sid, name, kind, minimum, highest, bids, state = lot
    cid = p.r['otb'].client_id(sid)
    locked = state == 'owned'
    rel = 'row_on' if selected else 'row_locked' if locked else 'row'
    p.nine(f'game_fishing/images/{rel}', x, y, w, h, 8, 0.6 if locked else 1)
    fy = y + (h - 44) / 2
    p.picture('game_fishing/images/portrait', x + 6, fy)
    p.item(cid, x + 12, fy + 6, count=100 if sid == 13305 else 1, dim=locked)
    p.text(x + 58, y + h / 2 - 15, name, 13, '#9aa6bf' if locked else GOLD, 'bold')
    p.text(x + 58, y + h / 2 + 4, kind, 10, MUTED)
    # the money column
    rx = x + w - 12
    if highest:
        p.text(rx, y + h / 2 - 15, dollars(highest), 14, '#9aa6bf' if locked else GREEN, 'bold', 'ra')
        p.text(rx, y + h / 2 + 4, f'highest of {bids} bids', 10, MUTED, anchor='ra')
    else:
        p.text(rx, y + h / 2 - 15, dollars(minimum), 14, TEXT, 'bold', 'ra')
        p.text(rx, y + h / 2 + 4, 'minimum bid', 10, MUTED, anchor='ra')
    tag_x = x + 58 + max(p.width(name, 13, 'bold'), 0) + 10
    status_tag(p, tag_x, y + h / 2 - 16, state, highest)


def stat(p, x, y, w, label, value, color=TEXT):
    p.text(x, y, label, 11, MUTED)
    p.text(x + w, y, value, 12, color, 'bold', 'ra')


def footer(p, x, y, w):
    p.picture('game_dailytasks/images/icon_clock', x, y + 3, 12)
    p.text(x + 18, y, 'New lots in 3d 14h 22m', 12, WHITE, 'bold')
    p.picture('game_dailytasks/images/icon_info', x + 200, y + 2, 14)
    p.text(x + 220, y + 1, 'A bid must beat the highest by 1%. Your money leaves the bank when you bid,', 10, MUTED)
    p.text(x + 220, y + 15, 'comes back if someone beats you, and the item you win goes to your depot.', 10, MUTED)


def auction(r):
    W, H, S = 900, 600, 2
    p = Painter(W, H, S, r)
    p.nine('game_dailytasks/images/window', 0, 0, W, H, 24)
    x0, y0, x1 = 26, 24, W - 26
    header(p, x0, y0, x1 - x0, 'Tiger Kelsey is in Cerulean City today  -  bid here or talk to him')
    cx = x0
    for label, count, on in (('This week', 5, True), ('My bids', 2, False), ('Won', 1, False), ('History', None, False)):
        cx += p.chip(cx, y0 + 50, label, count, on) + 6
    # the lots
    lx, lw, ly = x0, 540, y0 + 86
    for i, lot in enumerate(LOTS):
        lot_row(p, lx, ly + i * 64, lw, lot, selected=i == 0)
    # the selected lot
    sid, name, kind, minimum, highest, bids, state = LOTS[0]
    dx, dw, dy, dh = lx + lw + 14, x1 - lx - lw - 14, ly, 404
    p.nine('game_fishing/images/panel', dx, dy, dw, dh, 10)
    p.picture('game_fishing/images/portrait', dx + dw / 2 - 33, dy + 12, 66)
    p.item(r['otb'].client_id(sid), dx + dw / 2 - 24, dy + 21, 48)
    p.text(dx + dw / 2, dy + 92, name, 16, WHITE, 'bold', 'ma')
    p.text(dx + dw / 2, dy + 113, 'Evolves Murkrow and Misdreavus', 10, MUTED, anchor='ma')
    sx, sw = dx + 14, dw - 28
    stat(p, sx, dy + 140, sw, 'Minimum bid', dollars(minimum))
    stat(p, sx, dy + 160, sw, 'Highest bid', dollars(highest), GREEN)
    stat(p, sx, dy + 180, sw, 'Your bid', dollars(31500), RED)
    stat(p, sx, dy + 200, sw, 'Bids', str(bids))
    p.d.line([(sx * S, (dy + 224) * S), ((sx + sw) * S, (dy + 224) * S)], fill='#34507a', width=S)
    p.text(sx, dy + 234, 'Raise your bid to', 11, MUTED)
    p.nine('client_entergame/images/field_focus', sx, dy + 252, sw, 30, 8)
    p.text(sx + 10, dy + 267, dollars(next_bid(highest, minimum)), 13, WHITE, 'bold', 'lm')
    p.text(sx + sw - 10, dy + 267, 'lowest you can bid', 10, MUTED, anchor='rm')
    qx = sx
    for label in ('Lowest', '+5%', '+10%'):
        qx += p.chip(qx, dy + 290, label) + 6
    p.button('green', sx, dy + 324, sw, 32, 'Raise bid  (+' + dollars(next_bid(highest, minimum) - 31500) + ')', WHITE)
    p.button('red', sx, dy + 362, sw, 30, 'Take my bid back', '#ffb4b4')
    footer(p, x0, H - 52, x1 - x0)
    p.save(os.path.join(OUT, 'auction.jpg'), BACKDROP)


def my_bids(r):
    W, H, S = 900, 600, 2
    p = Painter(W, H, S, r)
    p.nine('game_dailytasks/images/window', 0, 0, W, H, 24)
    x0, y0, x1 = 26, 24, W - 26
    header(p, x0, y0, x1 - x0, 'Money in your bids: ' + dollars(31500 + 12120) + '  -  it comes back if you are beaten')
    cx = x0
    for label, count, on in (('This week', 5, False), ('My bids', 2, True), ('Won', 1, False), ('History', None, False)):
        cx += p.chip(cx, y0 + 50, label, count, on) + 6
    lx, lw, ly = x0, 540, y0 + 86
    p.text(lx, ly, 'This week', 13, WHITE, 'bold')
    rows = [(LOTS[0], 'Your bid $31,500  -  beaten by $315', True), (LOTS[1], 'Your bid $12,120  -  4 bids', False)]
    for i, (lot, note, selected) in enumerate(rows):
        sid, name, kind, minimum, highest, bids, state = lot
        y = ly + 22 + i * 64
        p.nine('game_fishing/images/row_on' if selected else 'game_fishing/images/row', lx, y, lw, 58, 8)
        p.picture('game_fishing/images/portrait', lx + 6, y + 7)
        p.item(r['otb'].client_id(sid), lx + 12, y + 13)
        p.text(lx + 58, y + 14, name, 13, GOLD, 'bold')
        p.text(lx + 58, y + 33, note, 10, MUTED)
        status_tag(p, lx + 66 + p.width(name, 13, 'bold'), y + 13, state, highest)
        if state == 'outbid':
            p.button('gold', lx + lw - 190, y + 13, 84, 32, 'Raise', GOLD)
            p.button('red', lx + lw - 98, y + 13, 86, 32, 'Take back', '#ffb4b4')
        else:
            p.button('red', lx + lw - 98, y + 13, 86, 32, 'Take back', '#ffb4b4', off=True)
            p.picture('game_dailytasks/images/icon_lock', lx + lw - 122, y + 21, 16)
    wy = ly + 172
    p.text(lx, wy, 'Won', 13, WHITE, 'bold')
    y = wy + 22
    p.nine('game_fishing/images/row', lx, y, lw, 58, 8)
    p.picture('game_fishing/images/portrait', lx + 6, y + 7)
    p.item(r['otb'].client_id(18087), lx + 12, y + 13)
    p.text(lx + 58, y + 14, 'Thunderstone', 13, GOLD, 'bold')
    p.text(lx + 58, y + 33, 'Last week, for $26,800  -  sent to your depot', 10, MUTED)
    p.tag(lx + lw - 12, y + 20, 'In your depot', '#1a1406', GOLD, 'right')
    p.text(lx, y + 80, "Can't cancel a bid while it's the highest: the lock shows which ones.", 10, MUTED)
    # bid history of the selected lot
    sid, name, kind, minimum, highest, bids, state = LOTS[0]
    dx, dw, dy, dh = lx + lw + 14, x1 - lx - lw - 14, ly, 404
    p.nine('game_fishing/images/panel', dx, dy, dw, dh, 10)
    p.item(r['otb'].client_id(sid), dx + 14, dy + 12)
    p.text(dx + 54, dy + 13, name, 15, WHITE, 'bold')
    p.text(dx + 54, dy + 32, 'Bid history', 10, MUTED)
    history = [(31815, '12 min ago', False), (31500, '2 h ago', True), (31185, '2 h ago', False),
               (30000, 'Yesterday', False), (27250, '2 days ago', False), (25000, '3 days ago', False)]
    for i, (amount, when, you) in enumerate(history):
        y = dy + 60 + i * 34
        if you:
            p.nine('game_fishing/images/row_on', dx + 8, y - 4, dw - 16, 30, 8)
        top = i == 0
        p.text(dx + 18, y + 2, dollars(amount), 13, GREEN if top else (GOLD if you else TEXT), 'bold')
        p.text(dx + 18, y + 4 + 13, 'You' if you else 'A trainer', 9, GOLD if you else MUTED)
        p.text(dx + dw - 18, y + 6, ('Highest  -  ' if top else '') + when, 10, MUTED, anchor='ra')
    p.text(dx + 14, dy + dh - 44, 'Other bidders stay anonymous, like', 10, MUTED)
    p.text(dx + 14, dy + dh - 30, 'when you ask Tiger Kelsey.', 10, MUTED)
    footer(p, x0, H - 52, x1 - x0)
    p.save(os.path.join(OUT, 'mybids.jpg'), BACKDROP)


def phone(r):
    # a landscape phone (844 x 390 points); the lot list and the bid sheet side by side, bigger rows
    W, H, S = 844, 390, 2
    p = Painter(W, H, S, r)
    p.nine('game_dailytasks/images/window', 0, 0, W, H, 24)
    x0, y0, x1 = 20, 16, W - 20
    p.item(3043, x0, y0)
    p.text(x0 + 40, y0 + 4, 'PokeTrader', 18, WHITE, 'bold')
    p.text(x0 + 40, y0 + 24, 'New lots in 3d 14h', 10, MUTED)
    cx = x0 + 180
    for label, count, on in (('This week', 5, True), ('My bids', 2, False), ('Won', 1, False)):
        cx += p.chip(cx, y0 + 6, label, count, on) + 6
    p.item(3031, x1 - 160, y0 + 4, count=100)
    p.text(x1 - 124, y0 + 10, dollars(BANK), 14, GOLD, 'bold')
    p.picture('client_entergame/images/icon_close', x1 - 26, y0 + 6, 24)
    lx, lw, ly = x0, 470, y0 + 48
    for i, lot in enumerate(LOTS[:4]):
        lot_row(p, lx, ly + i * 70, lw, lot, selected=i == 0, h=64)
    sid, name, kind, minimum, highest, bids, state = LOTS[0]
    dx, dw, dy, dh = lx + lw + 12, x1 - lx - lw - 12, ly, H - ly - 18
    p.nine('game_fishing/images/panel', dx, dy, dw, dh, 10)
    p.item(r['otb'].client_id(sid), dx + 14, dy + 12, 40)
    p.text(dx + 64, dy + 14, name, 15, WHITE, 'bold')
    p.text(dx + 64, dy + 34, 'Highest ' + dollars(highest) + '  -  yours ' + dollars(31500), 10, MUTED)
    sx, sw = dx + 14, dw - 28
    p.nine('client_entergame/images/field_focus', sx, dy + 70, sw, 40, 8)
    p.text(sx + 12, dy + 90, dollars(next_bid(highest, minimum)), 15, WHITE, 'bold', 'lm')
    qx = sx
    for label in ('Lowest', '+5%', '+10%'):
        qx += p.chip(qx, dy + 120, label) + 8
    p.button('green', sx, dy + 156, sw, 44, 'Raise bid', WHITE)
    p.button('red', sx, dy + 210, sw, 40, 'Take my bid back', '#ffb4b4')
    p.save(os.path.join(OUT, 'phone.jpg'), BACKDROP)


def main():
    if os.path.getsize(SPR) < 1 << 20:
        sys.exit('data.spr is a Git LFS pointer: git lfs pull --include=core/client-legacy/data/things/data.spr')
    os.makedirs(OUT, exist_ok=True)
    r = {'otb': pvmap.Otb(OTB), 'dat': pvmap.Dat(DAT), 'spr': pvmap.Spr(SPR)}
    auction(r)
    my_bids(r)
    phone(r)


if __name__ == '__main__':
    main()
