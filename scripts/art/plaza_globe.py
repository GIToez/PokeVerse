#!/usr/bin/env python3
"""The Union Room plaza: a GTS-style globe on the octagon floor of the old Trading Area.

The plaza (map 4717-4725, 135-142, floor 7) is one picture cut into one-tile floor overlays
(items 27864-27936). Two seasonal copies of the room (origins in COPIES) stand on dirt, so the
inside of the octagon is painted with the room's floor tile rather than left see-through. This
keeps the octagon wall of the old picture, repaints its inside and draws the globe there.

    plaza_globe.py --mockup out.png      the room rendered with the new plaza, for review
    plaza_globe.py --before out.png      the same room as it is now
    plaza_globe.py --move-teleporters    moves the two return teleporters (action id 100) from
                                         above the middle to the west and east of the globe, in
                                         every copy of the room (map.otbm; does nothing when done)

Writes art/sprites/plaza/sheet.png (the new plaza) and sheet_original.png.
"""
import argparse
import math
import os
import sys
from collections import deque

import numpy as np
from PIL import Image, ImageDraw, ImageFilter, ImageFont

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, os.path.join(ROOT, 'scripts/mapper'))
import pvmap  # noqa: E402
from render import Renderer  # noqa: E402

MAP = os.path.join(ROOT, 'core/server/data/world/map.otbm')
ITEMS = os.path.join(ROOT, 'core/server/data/items/items.otb')
DAT = os.path.join(ROOT, 'core/client-legacy/data/things/data.dat')
SPR = os.path.join(ROOT, 'core/client-legacy/data/things/data.spr')
FONT = os.path.join(ROOT, 'core/client-redemption/pokeverse-modern/data/fonts/ttf/pixelify-sans.ttf')
OUT = os.path.join(ROOT, 'art/sprites/plaza')

ORIGIN = (4717, 135, 7)  # top-left tile of the plaza
COPIES = [ORIGIN, (4630, 124, 7), (4657, 106, 7)]
TILES = (9, 8)
PLAZA_ITEMS = range(27864, 27937)
FLOOR = 20073  # the room's floor tile, under the plaza
TELEPORTERS = range(11905, 11908)
# plaza tiles of the two return teleporters: where they were, and where they go
TELEPORTER_MOVES = [((4, 2), (1, 3)), ((5, 2), (7, 3))]
# on the plaza sheet: the middle of tile (4, 3), where TRADE_ROOM_POSITION lands trainers
GLOBE_CENTER = (144, 112)
GLOBE_RADIUS = 46
ROOM = (4708, 130, 4732, 150)  # the room around it, for the renders

K = 4  # supersampling for the drawing

INK = (28, 30, 46)
RED = (226, 52, 44)
RED_LIGHT = (255, 112, 96)
RED_DARK = (160, 28, 30)
WHITE = (244, 244, 246)
WHITE_SHADE = (196, 202, 214)
CYAN = (110, 214, 255)
BLUE = (52, 132, 236)
BLUE_DARK = (24, 70, 160)
LOGO_YELLOW = (255, 203, 5)
LOGO_BLUE = (54, 106, 190)
LOGO_BLUE_DARK = (30, 50, 120)

# The title wants the fan-made "Pokemon Solid" font (dafont.com/pokemon.font). Its license is
# not stated, so it is not kept in the repo; pass it with --title-font. Only the pixels it
# draws end up in the game.
TITLE_FONT = FONT
TITLE = 'POKEVERSE'


def read_room():
    """The map tiles of the room around the plaza."""
    rx0, ry0, rx1, ry1 = ROOM
    return pvmap.read_region(MAP, rx0 - 2, ry0 - 2, rx1 + 10, ry1 + 10, range(0, ORIGIN[2] + 1))


def plaza_sheet(tiles, otb, dat, spr):
    x0, y0, z = ORIGIN
    sheet = Image.new('RGBA', (TILES[0] * 32, TILES[1] * 32), (0, 0, 0, 0))
    sprites = {}
    for (x, y, tz), items in tiles.items():
        if tz != z or not (0 <= x - x0 < TILES[0] and 0 <= y - y0 < TILES[1]):
            continue
        for sid in items:
            if sid in PLAZA_ITEMS:
                sprite = dat.things[otb.client_id(sid)][8][0]
                sprites[(x - x0, y - y0)] = sprite
                px = spr.rgba(sprite)
                if px:
                    sheet.paste(Image.frombytes('RGBA', (32, 32), px), ((x - x0) * 32, (y - y0) * 32))
    return sheet, sprites


def wall_mask(sheet):
    """The octagon wall: dark gray pixels connected to the transparent outside."""
    a = np.array(sheet).astype(int)
    h, w = a.shape[:2]
    rgb, alpha = a[..., :3], a[..., 3]
    hi, lo = rgb.max(axis=2), rgb.min(axis=2)
    dark = (alpha > 0) & (hi < 150) & (hi - lo < 30)
    seen = alpha == 0
    queue = deque(zip(*np.nonzero(seen)))
    wall = np.zeros((h, w), bool)
    while queue:
        y, x = queue.popleft()
        for dy in (-1, 0, 1):
            for dx in (-1, 0, 1):
                ny, nx = y + dy, x + dx
                if 0 <= ny < h and 0 <= nx < w and not seen[ny, nx] and dark[ny, nx]:
                    seen[ny, nx] = True
                    wall[ny, nx] = True
                    queue.append((ny, nx))
    return wall


def inner_shadow(inside):
    """A soft shade along the inside of the wall, so the floor sits lower than it."""
    m = Image.fromarray(((~inside) * 255).astype(np.uint8))
    blur = np.array(m.filter(ImageFilter.GaussianBlur(5))).astype(float) / 255
    alpha = np.clip(blur * 1.6, 0, 1) * inside * 110
    out = np.zeros(inside.shape + (4,), np.uint8)
    out[..., :3] = (20, 18, 30)
    out[..., 3] = alpha.astype(np.uint8)
    return Image.fromarray(out)


def arc_text(draw, text, center, radius, start_deg, font, passes, clockwise=True, tracking=0.0):
    """Letters along a circle, centered on start_deg (0 is east, 90 south).

    passes is [(color, stroke_width)], drawn widest first over every letter, so one letter's
    outline never covers its neighbour's fill."""
    widths = [draw.textlength(ch, font=font) + tracking for ch in text]
    total = sum(widths) - tracking
    span = total / radius
    start = math.radians(start_deg) - (span / 2 if clockwise else -span / 2)
    layer = Image.new('RGBA', draw.im.size, (0, 0, 0, 0))
    size = int(font.size * 2.4)
    for color, stroke in passes:
        angle = start
        for ch, wch in zip(text, widths):
            step = wch / radius
            mid = angle + (step / 2 if clockwise else -step / 2)
            cx = center[0] + math.cos(mid) * radius
            cy = center[1] + math.sin(mid) * radius
            glyph = Image.new('RGBA', (size, size), (0, 0, 0, 0))
            ImageDraw.Draw(glyph).text((size / 2, size / 2), ch, font=font, fill=color, anchor='mm',
                                       stroke_width=stroke, stroke_fill=color)
            rot = -math.degrees(mid) - (90 if clockwise else -90)
            glyph = glyph.rotate(rot, resample=Image.BICUBIC)
            layer.alpha_composite(glyph, (int(cx - size / 2), int(cy - size / 2)))
            angle += step if clockwise else -step
    return layer


def arrow_arc(draw, center, radius, start, end, width, color, outline):
    """A curved arrow from start to end degrees (clockwise), head at the end."""
    cx, cy = center
    box = (cx - radius, cy - radius, cx + radius, cy + radius)
    draw.arc(box, start, end, fill=outline, width=width + 2 * K)
    draw.arc(box, start, end, fill=color, width=width)
    a = math.radians(end)
    tip = (cx + math.cos(a + 0.18) * radius, cy + math.sin(a + 0.18) * radius)
    side = width * 1.25
    p1 = (cx + math.cos(a) * (radius - side), cy + math.sin(a) * (radius - side))
    p2 = (cx + math.cos(a) * (radius + side), cy + math.sin(a) * (radius + side))
    draw.polygon([p1, p2, tip], fill=color, outline=outline, width=K)


def globe_layer(size, center, r):
    """The globe at K times the size: a Poke Ball with a world on its top half."""
    W, H = size[0] * K, size[1] * K
    cx, cy, R = center[0] * K, center[1] * K, r * K
    img = Image.new('RGBA', (W, H), (0, 0, 0, 0))

    glow = Image.new('RGBA', (W, H), (0, 0, 0, 0))
    ImageDraw.Draw(glow).ellipse((cx - R * 1.3, cy - R * 1.3, cx + R * 1.3, cy + R * 1.3), fill=CYAN + (120,))
    glow = glow.filter(ImageFilter.GaussianBlur(R * 0.22))
    img.alpha_composite(glow)

    shadow = Image.new('RGBA', (W, H), (0, 0, 0, 0))
    ImageDraw.Draw(shadow).ellipse((cx - R + 4 * K, cy - R + 7 * K, cx + R + 4 * K, cy + R + 7 * K), fill=(0, 0, 0, 90))
    img.alpha_composite(shadow.filter(ImageFilter.GaussianBlur(3 * K)))

    ball = Image.new('RGBA', (W, H), (0, 0, 0, 0))
    d = ImageDraw.Draw(ball)
    box = (cx - R, cy - R, cx + R, cy + R)
    d.ellipse(box, fill=WHITE)
    d.chord(box, 180, 360, fill=RED)
    # shading: darker toward the lower right of each half
    shade = Image.new('L', (W, H), 0)
    ImageDraw.Draw(shade).ellipse((cx - R * 1.25, cy - R * 1.3, cx + R * 0.75, cy + R * 0.7), fill=255)
    shade = shade.filter(ImageFilter.GaussianBlur(R * 0.25))
    dk = np.zeros((H, W, 4), np.uint8)
    dk[..., 3] = (np.array(ball)[..., 3].astype(float) * (1 - np.array(shade) / 255) * 0.32).astype(np.uint8)
    ball.alpha_composite(Image.fromarray(dk))

    # the world on the red half: meridians and parallels, and a few lands
    world = Image.new('RGBA', (W, H), (0, 0, 0, 0))
    w = ImageDraw.Draw(world)
    lands = [(-0.55, -0.55, 0.32, 0.2), (0.1, -0.7, 0.36, 0.16), (0.35, -0.35, 0.22, 0.14), (-0.2, -0.28, 0.18, 0.1)]
    for lx, ly, rx, ry in lands:
        w.ellipse((cx + (lx - rx) * R, cy + (ly - ry) * R, cx + (lx + rx) * R, cy + (ly + ry) * R), fill=RED_DARK + (255,))
    for k in (0.35, 0.72):
        w.arc((cx - R * k, cy - R, cx + R * k, cy + R), 180, 360, fill=RED_LIGHT + (230,), width=int(1.4 * K))
    w.line((cx, cy - R, cx, cy), fill=RED_LIGHT + (230,), width=int(1.4 * K))
    for f in (0.38, 0.72):
        yy = cy - R * f
        half = math.sqrt(max(0, 1 - f * f)) * R
        w.line((cx - half, yy, cx + half, yy), fill=RED_LIGHT + (230,), width=int(1.4 * K))
    redmask = Image.new('L', (W, H), 0)
    ImageDraw.Draw(redmask).chord(box, 180, 360, fill=255)
    world.putalpha(Image.fromarray(np.minimum(np.array(world)[..., 3], np.array(redmask))))
    ball.alpha_composite(world)

    # highlight
    hl = Image.new('RGBA', (W, H), (0, 0, 0, 0))
    ImageDraw.Draw(hl).ellipse((cx - R * 0.72, cy - R * 0.82, cx - R * 0.22, cy - R * 0.5), fill=(255, 255, 255, 150))
    ball.alpha_composite(hl.filter(ImageFilter.GaussianBlur(2 * K)))

    # band, button and rim
    d = ImageDraw.Draw(ball)
    band = R * 0.11
    d.rectangle((cx - R, cy - band, cx + R, cy + band), fill=INK)
    clip = Image.new('L', (W, H), 0)
    ImageDraw.Draw(clip).ellipse(box, fill=255)
    ball.putalpha(Image.fromarray(np.minimum(np.array(ball)[..., 3], np.array(clip))))
    d = ImageDraw.Draw(ball)
    d.ellipse(box, outline=INK, width=int(2.2 * K))
    br = R * 0.27
    d.ellipse((cx - br, cy - br, cx + br, cy + br), fill=INK)
    br2 = R * 0.19
    d.ellipse((cx - br2, cy - br2, cx + br2, cy + br2), fill=WHITE)
    br3 = R * 0.11
    d.ellipse((cx - br3, cy - br3, cx + br3, cy + br3), fill=CYAN, outline=BLUE, width=K)
    img.alpha_composite(ball)

    # trade arrows going round the globe
    arrows = Image.new('RGBA', (W, H), (0, 0, 0, 0))
    a = ImageDraw.Draw(arrows)
    ar = R * 1.22
    arrow_arc(a, (cx, cy), ar, 125, 235, int(3.6 * K), CYAN, BLUE_DARK)
    arrow_arc(a, (cx, cy), ar, 305, 415, int(3.6 * K), CYAN, BLUE_DARK)
    img.alpha_composite(arrows)

    # PokéVerse arched over the globe in the Pokémon logo style, UNION ROOM straight across under it
    d = ImageDraw.Draw(img)
    big = ImageFont.truetype(TITLE_FONT, int(30 * K))
    passes = [(LOGO_BLUE_DARK, int(3.2 * K)), (LOGO_BLUE, int(2 * K)), (LOGO_YELLOW, 0)]
    img.alpha_composite(arc_text(d, TITLE, (cx, cy), R * 1.86, 270, big, passes, tracking=-1.5 * K))
    small = ImageFont.truetype(FONT, int(16 * K))
    d.text((cx, cy + R * 1.58), 'UNION ROOM', font=small, fill=WHITE, anchor='mm',
           stroke_width=2 * K, stroke_fill=INK)

    arr = np.array(img.resize(size, Image.LANCZOS))
    # crisp edges for the pixel look; keep the glow soft
    solid = arr[..., 3] > 150
    arr[..., 3] = np.where(solid, 255, arr[..., 3] // 2)
    return Image.fromarray(arr)


def floor_sheet(otb, dat, spr):
    """The room's floor tile over the whole plaza, in the pattern it has at ORIGIN."""
    attrs, w, h, layers, pxn, pyn, pzn, frames, sprites = dat.things[otb.client_id(FLOOR)]
    x0, y0, z = ORIGIN
    out = Image.new('RGBA', (TILES[0] * 32, TILES[1] * 32), (0, 0, 0, 0))
    for dy in range(TILES[1]):
        for dx in range(TILES[0]):
            idx = (((z % pzn) * pyn + (y0 + dy) % pyn) * pxn + (x0 + dx) % pxn) * layers
            out.paste(Image.frombytes('RGBA', (32, 32), spr.rgba(sprites[idx])), (dx * 32, dy * 32))
    return out


def build(sheet, floor):
    wall = wall_mask(sheet)
    alpha = np.array(sheet)[..., 3] > 0
    inside = alpha & ~wall
    out = np.array(sheet).copy()
    out[inside] = np.array(floor)[inside]
    new = Image.fromarray(out)
    new.alpha_composite(inner_shadow(inside))

    globe = globe_layer(new.size, GLOBE_CENTER, GLOBE_RADIUS)
    g = np.array(globe)
    g[..., 3] = (g[..., 3] * inside).astype(np.uint8)
    new.alpha_composite(Image.fromarray(g))
    return new


def render_room(r, tiles, sprites=None, sheet=None):
    """The room as the client draws it; with a sheet, the plaza sprites drawn from it instead."""
    rx0, ry0, rx1, ry1 = ROOM
    # the game draws the exit teleporters above the plaza art; render.py draws stacked items the
    # other way round, so they go first here
    tiles = {p: sorted(v, key=lambda s: s not in TELEPORTERS) for p, v in tiles.items()}
    r.sprite_images.clear()
    if sheet is not None:
        for (dx, dy), sprite in sprites.items():
            r.sprite_images[sprite] = sheet.crop((dx * 32, dy * 32, dx * 32 + 32, dy * 32 + 32))
    return r.render(tiles, rx0, ry0, rx1, ry1, ORIGIN[2], False)


def move_teleporters():
    """Moves the return teleporters in every copy of the room; returns how many moved."""
    data = open(MAP, 'rb').read()
    wanted = [(ox + dx, oy + dy, z) for ox, oy, z in COPIES for move in TELEPORTER_MOVES for dx, dy in move]
    raw = pvmap.read_tiles_raw(MAP, wanted, data)
    changed, moved = {}, 0
    for ox, oy, z in COPIES:
        for (fx, fy), (tx, ty) in TELEPORTER_MOVES:
            src, dst = (ox + fx, oy + fy, z), (ox + tx, oy + ty, z)
            blobs = pvmap.split_items(raw[src].children)
            ids = pvmap.child_item_ids(raw[src].children)
            keep = [b for b, i in zip(blobs, ids) if i not in TELEPORTERS]
            gone = [b for b, i in zip(blobs, ids) if i in TELEPORTERS]
            if not gone:
                continue
            raw[src].children = b''.join(keep)
            raw[dst].children += b''.join(gone)
            changed[src], changed[dst] = raw[src], raw[dst]
            moved += len(gone)
    if changed:
        tmp = MAP + '.tmp'
        pvmap.write_map(data, tmp, changed)
        os.replace(tmp, MAP)
    return moved


def write_spr(sprites, sheet):
    """Replaces the plaza sprites in data.spr with their tiles of the sheet."""
    if len(set(sprites.values())) != len(sprites):
        raise SystemExit('two plaza tiles share a sprite; they cannot get different art')
    new = {sprite: sheet.crop((dx * 32, dy * 32, dx * 32 + 32, dy * 32 + 32)).tobytes()
           for (dx, dy), sprite in sprites.items()}
    # data.spr is hard linked into other checkouts, so write a new file rather than edit it
    tmp = SPR + '.tmp'
    pvmap.write_sprites(SPR, tmp, new)
    check = pvmap.Spr(tmp)
    for sprite, px in new.items():
        want = np.frombuffer(px, np.uint8).reshape(-1, 4).copy()
        want[want[:, 3] == 0] = 0  # .spr keeps no color for transparent pixels
        if (check.rgba(sprite) or bytes(4096)) != want.tobytes():
            raise SystemExit('sprite %d did not read back the same' % sprite)
    old = pvmap.Spr(SPR)
    for sprite in range(1, old.count + 1, 97):
        if sprite not in new and old.rgba(sprite) != check.rgba(sprite):
            raise SystemExit('sprite %d changed though it is not part of the plaza' % sprite)
    old.f.close()
    check.f.close()
    os.replace(tmp, SPR)
    print('wrote %d plaza sprites into data.spr' % len(new))


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--mockup')
    ap.add_argument('--before')
    ap.add_argument('--move-teleporters', action='store_true')
    ap.add_argument('--write-spr', action='store_true', help='put the new plaza into data.spr')
    ap.add_argument('--title-font', help='Pokemon Solid.ttf; the title falls back to Pixelify Sans')
    args = ap.parse_args()
    global TITLE_FONT, TITLE
    if args.title_font:
        TITLE_FONT, TITLE = args.title_font, 'PokéVerse'

    if args.move_teleporters:
        print('moved %d teleporters' % move_teleporters())
    otb, dat, spr = pvmap.Otb(ITEMS), pvmap.Dat(DAT), pvmap.Spr(SPR)
    tiles = read_room()
    os.makedirs(OUT, exist_ok=True)
    original = os.path.join(OUT, 'sheet_original.png')
    sheet, sprites = plaza_sheet(tiles, otb, dat, spr)
    # once data.spr carries the new plaza, the old picture is only in sheet_original.png
    if os.path.exists(original):
        sheet = Image.open(original).convert('RGBA')
    else:
        sheet.save(original)
    new = build(sheet, floor_sheet(otb, dat, spr))
    new.save(os.path.join(OUT, 'sheet.png'))
    if args.write_spr:
        write_spr(sprites, new)
        spr = pvmap.Spr(SPR)
    if args.mockup or args.before:
        r = Renderer(ITEMS, DAT, SPR)
        if args.before:
            render_room(r, tiles).convert('RGB').save(args.before)
        if args.mockup:
            render_room(r, tiles, sprites, new).convert('RGB').save(args.mockup)


if __name__ == '__main__':
    main()
