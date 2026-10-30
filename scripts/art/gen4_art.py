#!/usr/bin/env python3
"""Art for the Gen 4 Pokemon (scripts/data/gen4-plan.json), drawn in by scripts/gen4-import.py.

    scripts/art/gen4_art.py <walk sheet dir> <out dir> [dex number ...]

The walk sheets are PokeZHero's outfits exported as <dex>.png (/tmp/pz/export.py: look dex + 2608,
Rotom 3106). For each Pokemon this writes into <out>:
  normal/<dex>.png, shiny/<dex>.png   walk sheets; the shiny one is the normal one recoloured with
                                      the colours learned from Showdown's gen5 normal and shiny sprites
  faces/<dex>-<normal|shiny>-N.png    swap bar face, 4 bob frames, from the PAdventures face item
  dex/<dex>.png                       Pokedex tile: our tile frame and sky with the face on it
  corpse/<dex>-<normal|shiny>.png     the walk sheet's south frame lying on its side
  egg/<dex>.png                       Bagon's egg in the Pokemon's two main colours (first stages)
  doll/<dex>.png                      the pokesprite box icon, small like our dolls
and into the clients: images staticPortraits/<dex>.png (Showdown gen5), pictures/<dex>.png (a still
of Showdown's animated model) and pokeicons/<NNN>.png (the box icon), and the Showdown cry as
sounds/cries/<dex>.ogg (both clients) and sounds/voice_cries/<dex>.ogg (Redemption).
Everything but the walk sheets and the client images is a placeholder until drawn by hand.
"""
import colorsys
import csv
import json
import os
import re
import subprocess
import sys

import numpy as np
from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
sys.path.insert(0, os.path.join(os.path.dirname(HERE), 'mapper'))
import mega_forms_art as M  # noqa: E402

ROOT = M.ROOT
PLAN = os.path.join(ROOT, 'scripts', 'data', 'gen4-plan.json')
CHECKLIST = os.path.join(ROOT, 'docs', 'gen4-6-checklist.csv')
PADV = 'https://raw.githubusercontent.com/DistTopic/padventures-sprites/main/sprites/item/%d.png'
CRY = 'https://play.pokemonshowdown.com/audio/cries/%s.mp3'
SOUNDS = [os.path.join(ROOT, 'core', 'client-legacy', 'data', 'sounds', 'cries'),
          os.path.join(ROOT, 'core', 'client-redemption', 'data', 'sounds', 'cries'),
          os.path.join(ROOT, 'core', 'client-redemption', 'data', 'sounds', 'voice_cries')]
# client items the placeholders are drawn after: Grovyle's dex tile and Bagon's egg
DEX_TILE, EGG = 27110, 27383
SKY_TOP, SKY_LOW = (120, 192, 216), (224, 232, 176)


def showdown(name):
    return re.sub(r'[^a-z0-9]', '', name.lower())


def pokesprite(name):
    return re.sub(r'[^a-z0-9-]', '', name.lower().replace(' ', '-').replace('.', ''))


def client_item(cid):
    sys.path.insert(0, os.path.join(ROOT, 'scripts', 'mapper'))
    import pvmap
    things = os.path.join(ROOT, 'core', 'client-legacy', 'data', 'things')
    dat, spr = pvmap.Dat(os.path.join(things, 'data.dat')), pvmap.Spr(os.path.join(things, 'data.spr'))
    sid = dat.things[cid][8][0]
    return np.frombuffer(spr.rgba(sid), np.uint8).reshape(32, 32, 4).copy()


def tile_parts():
    """Grovyle's tile split into its frame (dark corners, 1 px grey border) and a sky to paint the face on."""
    a = client_item(DEX_TILE)
    # the art covers the tile's right and bottom border in places, so the rounded frame is the
    # top left quarter's (corner inset per row), mirrored: grey 192 on the top and left, 139 on
    # the bottom and right, dark corners outside
    inset = [int(np.argmax(a[y, :16, 0] > 12)) for y in range(16)]
    frame = np.zeros((32, 32), bool)
    out = a.copy()
    for y in range(32):
        k = inset[min(y, 31 - y)]
        top = y < 16
        for x in range(32):
            d = min(x, 31 - x)
            if y in (0, 31) and d >= k or d == k:
                frame[y, x] = True
                out[y, x] = (192, 192, 192, 255) if y == 0 or (top and x < 16) else (139, 139, 139, 255)
            elif d < k:
                frame[y, x] = True
                out[y, x] = (10, 10, 10, 255)
    a = out
    sky = np.zeros((32, 32, 4), np.uint8)
    profile = [tuple(a[y, 3, :3]) for y in range(4, 17)]
    for y in range(32):
        sky[y, :, :3] = profile[min(max(y - 4, 0), len(profile) - 1)] if y < 17 else SKY_LOW
    sky[..., 3] = 255
    return a, frame, sky


def dex_tile(face, parts):
    a, frame, sky = parts
    out = Image.fromarray(sky)
    out.alpha_composite(face)
    out = np.array(out)
    out[frame] = a[frame]
    return Image.fromarray(out)


def corpse(sheet, dark=0.8):
    """The first frame facing south, lying on its side, fit into a 32 px tile like our corpses."""
    size = sheet.width // 4
    cell = sheet.crop((2 * size, 0, 3 * size, size)).convert('RGBA')
    cell = cell.crop(cell.getbbox()).rotate(90, expand=True)
    if max(cell.size) > 32:
        k = 32 / max(cell.size)
        cell = cell.resize((max(1, round(cell.width * k)), max(1, round(cell.height * k))), Image.BOX)
        px = np.array(cell)
        px[..., 3] = np.where(px[..., 3] >= 128, 255, 0)
        cell = Image.fromarray(px)
    px = np.array(cell).astype(float)
    px[..., :3] *= dark
    cell = Image.fromarray(px.clip(0, 255).astype(np.uint8))
    out = Image.new('RGBA', (32, 32), (0, 0, 0, 0))
    out.alpha_composite(cell, ((32 - cell.width) // 2, 32 - cell.height))
    return out


def main_colours(sprite):
    """The two most used body colours of a sprite (outline and near white left out), each the
    average of its hue group."""
    px = np.array(sprite.convert('RGBA'))
    px = px[px[..., 3] > 0][:, :3].astype(float)
    hsv = np.array([colorsys.rgb_to_hsv(*(p / 255)) for p in px])
    body = (hsv[:, 2] > 0.25) & ~((hsv[:, 1] < 0.12) & (hsv[:, 2] > 0.85))
    px, hsv = px[body], hsv[body]
    # hue bins of 30 degrees, plus one bin for greys
    bins = np.where(hsv[:, 1] < 0.18, 12, (hsv[:, 0] * 12).astype(int) % 12)
    order = np.bincount(bins, minlength=13).argsort()[::-1]
    picks = [px[bins == b].mean(0) for b in order[:2] if (bins == b).any()]
    while len(picks) < 2:
        picks.append(np.array([230.0, 230, 230]))
    return picks


def egg(colours, template):
    """Bagon's egg: the grey shell in the first colour and the blue spots in the second, keeping its shading."""
    out = template.copy()
    rgb = template[..., :3].astype(float)
    opaque = template[..., 3] > 0
    sat = rgb.max(-1) - rgb.min(-1)
    lum = rgb.mean(-1)
    shell, spot = opaque & (sat < 20), opaque & (sat >= 20)
    for mask, colour, ref in ((shell, colours[0], 212.0), (spot, colours[1], 150.0)):
        c = np.array(colour)
        out[mask, :3] = np.clip(c * (lum[mask] / ref)[:, None], 0, 255).astype(np.uint8)
    return Image.fromarray(out)


def doll(icon, box=20):
    im = icon.convert('RGBA')
    im = im.crop(im.getbbox())
    k = min(1, box / max(im.size))
    if k < 1:
        im = im.resize((max(1, round(im.width * k)), max(1, round(im.height * k))), Image.BOX)
        px = np.array(im)
        px[..., 3] = np.where(px[..., 3] >= 128, 255, 0)
        im = Image.fromarray(px)
    out = Image.new('RGBA', (32, 32), (0, 0, 0, 0))
    out.alpha_composite(im, ((32 - im.width) // 2 + 2, 28 - im.height))
    return out


def face_items():
    out = {}
    for row in csv.DictReader(open(CHECKLIST, encoding='utf-8')):
        m = re.search(r'PAdventures item (\d+)', row['FaceItem'])
        if m:
            out[int(row['Dex'])] = int(m.group(1))
    return out


def main():
    if len(sys.argv) < 3:
        sys.exit(__doc__)
    sheets, out = sys.argv[1:3]
    only = {int(a) for a in sys.argv[3:]}
    os.makedirs(M.CACHE, exist_ok=True)
    for sub in ('normal', 'shiny', 'faces', 'dex', 'corpse', 'egg', 'doll'):
        os.makedirs(os.path.join(out, sub), exist_ok=True)
    for d in SOUNDS:
        os.makedirs(d, exist_ok=True)
    plan = json.load(open(PLAN))
    faces = face_items()
    parts = tile_parts()
    egg_template = client_item(EGG)
    for p in plan:
        dex, name = p['number'], p['name']
        if only and dex not in only:
            continue
        sd, ps = showdown(name), pokesprite(name)
        normal = Image.open(M.fetch('%s/gen5/%s.png' % (M.SHOWDOWN, sd), 'gen5-%s.png' % sd)).convert('RGBA')
        shiny = Image.open(M.fetch('%s/gen5-shiny/%s.png' % (M.SHOWDOWN, sd), 'gen5-shiny-%s.png' % sd)).convert('RGBA')
        rule = M.learned_rule(normal, shiny)
        sheet = Image.open(os.path.join(sheets, '%d.png' % dex)).convert('RGBA')
        sheet.save(os.path.join(out, 'normal', '%d.png' % dex))
        shiny_sheet = M.recolour(sheet, rule)
        shiny_sheet.save(os.path.join(out, 'shiny', '%d.png' % dex))
        face = Image.open(M.fetch(PADV % faces[dex], 'padv-%d.png' % faces[dex])).convert('RGBA')
        for kind, still in (('normal', face), ('shiny', M.recolour(face, rule))):
            for n, frame in enumerate(M.bob(still)):
                frame.save(os.path.join(out, 'faces', '%d-%s-%d.png' % (dex, kind, n)))
        dex_tile(face, parts).save(os.path.join(out, 'dex', '%d.png' % dex))
        corpse(sheet).save(os.path.join(out, 'corpse', '%d-normal.png' % dex))
        corpse(shiny_sheet).save(os.path.join(out, 'corpse', '%d-shiny.png' % dex))
        if not p['from']:
            egg(main_colours(normal), egg_template).save(os.path.join(out, 'egg', '%d.png' % dex))
        icon = Image.open(M.fetch('%s/regular/%s.png' % (M.POKESPRITE, ps), 'box-regular-%s.png' % ps))
        doll(icon).save(os.path.join(out, 'doll', '%d.png' % dex))
        M.face(icon).save(os.path.join(M.IMAGES, 'pokeicons', '%03d.png' % dex))
        normal.save(os.path.join(M.IMAGES, 'staticPortraits', '%d.png' % dex))
        gif = M.fetch('%s/ani/%s.gif' % (M.SHOWDOWN, sd), 'ani-%s.gif' % sd)
        M.model_still(gif).save(os.path.join(M.IMAGES, 'pictures', '%d.png' % dex))
        mp3 = M.fetch(CRY % sd, 'cry-%s.mp3' % sd)
        first = os.path.join(SOUNDS[0], '%d.ogg' % dex)
        subprocess.run(['ffmpeg', '-loglevel', 'error', '-y', '-i', mp3, '-ar', '44100', '-ac', '2',
                        '-c:a', 'libvorbis', '-q:a', '4', first], check=True)
        for d in SOUNDS[1:]:
            # the Redemption client already has the XY voice cries of Gen 4
            if not os.path.exists(os.path.join(d, '%d.ogg' % dex)):
                with open(first, 'rb') as src, open(os.path.join(d, '%d.ogg' % dex), 'wb') as dst:
                    dst.write(src.read())
        print(dex, name)


if __name__ == '__main__':
    main()
