#!/usr/bin/env python3
"""Art for the Mega forms (docs/mega-art.md): shiny walk sheets, swap bar faces and pictures.

    scripts/art/mega_forms_art.py <6500 pack folder> <out dir> [form name ...]

For each form in FORMS (or the named ones) this writes, from the sprite pack sheet already drawn
in as its normal look and the Showdown and pokesprite art (downloaded into /tmp/pv-megaart):
  <out>/normal/<name>.png        the Primals' walk sheet: our Groudon or Kyogre repainted
  <out>/shiny/<name>.png         the shiny walk sheet, a recolour of the pack sheet (or the pack's
                                 own shiny sheet); none when the game has no shiny of the Pokemon
  <out>/faces/<name>-<kind>-N.png  32x32 swap bar face, 4 bob frames, normal and shiny,
                                 from the pokesprite box icon (placeholders until drawn)
and copies into the client's images:
  staticPortraits/<dex>-<form>.png   Showdown gen5 (96x96, the same set as ours)
  pictures/<dex>-<form>.png          a still of Showdown's animated model
  pokeicons/<NNN>-<form>.png         the box icon at 32x32, like the face
The walk sheets and faces are then drawn in with scripts/dat-set-outfit.py and
scripts/dat-add-sprite-items.py --frames 4.
"""
import colorsys
import os
import subprocess
import sys
from collections import Counter, defaultdict

import numpy as np
from PIL import Image, ImageSequence

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
IMAGES = os.path.join(ROOT, 'core', 'client-legacy', 'data', 'images')
CACHE = '/tmp/pv-megaart'
SHOWDOWN = 'https://play.pokemonshowdown.com/sprites'
POKESPRITE = 'https://raw.githubusercontent.com/msikma/pokesprite/master/pokemon-gen8'


def mega_x(r, g, b, h, s, v):
    """Black body to dark teal, dark blue wings to dark red; the blue flames stay."""
    if v < 0.06:
        return None
    if s < 0.15:
        return r * 0.39, g * 1.33, b * 1.08
    if 185 <= h <= 235:
        if v < 0.55:
            return b, g * 0.46, g * 0.46
        if s < 0.7:
            return r, min(255, g * 1.12), b
    return None


def mega_y(r, g, b, h, s, v):
    """Orange body to grey-purple, cream belly paler, teal wings to dark red."""
    if v < 0.06:
        return None
    lum = 0.299 * r + 0.587 * g + 0.114 * b
    if (h <= 32 or h >= 345) and s >= 0.6:
        return lum * 0.9, lum * 0.88, lum * 1.1
    if 32 < h <= 62 and s < 0.62:
        m = (r + g + b) / 3
        return r + (m - r) * 0.5, g + (m - g) * 0.5, b + (m - b) * 0.5 + 15
    if 170 <= h <= 215 and s >= 0.3:
        return min(255, b * 1.35 + 20), g * 0.28, b * 0.45
    return None


# Our 96 px Groudon and Kyogre repainted in the Primal colours (Showdown's groudon-primal and
# kyogre-primal), so the Primals keep our art's size and style
PRIMAL_GROUDON = {
    (152, 0, 0): (0x7c, 0x21, 0x29), (208, 56, 0): (0xd8, 0x22, 0x2a), (248, 128, 88): (0xfe, 0x73, 0x6b),
    (64, 96, 104): (0x27, 0x23, 0x24), (120, 136, 144): (0x3f, 0x3b, 0x3c), (168, 176, 184): (0x59, 0x53, 0x55),
    (208, 216, 216): (0x64, 0x62, 0x6c), (184, 112, 32): (0xfa, 0xb6, 0x72), (248, 224, 152): (0xff, 0xf4, 0x93),
}
PRIMAL_KYOGRE = {
    (24, 152, 224): (0x03, 0x4e, 0xa3), (0, 96, 176): (0x08, 0x2a, 0x78), (120, 200, 248): (0x07, 0x88, 0xd6),
    (208, 56, 0): (0xc7, 0xea, 0xfe), (152, 0, 0): (0x00, 0xbf, 0xec), (248, 128, 88): (0xff, 0xf4, 0x93),
    (64, 96, 104): (0x10, 0x1c, 0x4c), (120, 136, 144): (0x76, 0x8a, 0xc4), (168, 176, 184): (0x95, 0xc5, 0xdb),
}
# {name: (colour map, glow)}: glow is (seam colour, glow colour) for the thin dark seams between
# Primal Groudon's plates, which glow like its magma lines
PRIMAL_PAINT = {
    'kyogre-primal': (PRIMAL_KYOGRE, None),
    'groudon-primal': (PRIMAL_GROUDON, ((152, 0, 0), (0xff, 0xf4, 0x93))),
}

# name: (dex, file suffix, pack sheet, "pzN" for PokeZHero's outfit N exported into the pack folder
# as outfit_pzN_.png (/tmp/pz/export.py), or "look:N" to copy our own outfit N, repainted with
# PRIMAL_PAINT for the Primals, Showdown name, pokesprite name, shiny rule). The shiny rule is None to learn the colours from
# Showdown's normal and shiny gen5 sprites (which share one pose), a function, a pack sheet number
# for a drawn shiny, or False when the game has no shiny of the Pokemon.
FORMS = {
    'venusaur-mega': (3, 'mega', 1863, 'venusaur-mega', 'venusaur-mega', None),
    'charizard-megax': (6, 'mega-x', 8231, 'charizard-megax', 'charizard-mega-x', mega_x),
    'charizard-megay': (6, 'mega-y', 8233, 'charizard-megay', 'charizard-mega-y', mega_y),
    'blastoise-mega': (9, 'mega', 1657, 'blastoise-mega', 'blastoise-mega', None),
    'beedrill-mega': (15, 'mega', 79, 'beedrill-mega', 'beedrill-mega', None),
    'pidgeot-mega': (18, 'mega', 2081, 'pidgeot-mega', 'pidgeot-mega', None),
    'alakazam-mega': (65, 'mega', 'pz1921', 'alakazam-mega', 'alakazam-mega', None),
    'slowbro-mega': (80, 'mega', 6140, 'slowbro-mega', 'slowbro-mega', None),
    'gengar-mega': (94, 'mega', 1851, 'gengar-mega', 'gengar-mega', None),
    'kangaskhan-mega': (115, 'mega', 2060, 'kangaskhan-mega', 'kangaskhan-mega', None),
    'gyarados-mega': (130, 'mega', 6139, 'gyarados-mega', 'gyarados-mega', 8037),
    'aerodactyl-mega': (142, 'mega', 2061, 'aerodactyl-mega', 'aerodactyl-mega', None),
    'ampharos-mega': (181, 'mega', 1858, 'ampharos-mega', 'ampharos-mega', None),
    'steelix-mega': (208, 'mega', 2138, 'steelix-mega', 'steelix-mega', None),
    'scizor-mega': (212, 'mega', 1892, 'scizor-mega', 'scizor-mega', None),
    'tyranitar-mega': (248, 'mega', 1854, 'tyranitar-mega', 'tyranitar-mega', None),
    'sceptile-mega': (254, 'mega', 2071, 'sceptile-mega', 'sceptile-mega', None),
    'blaziken-mega': (257, 'mega', 1857, 'blaziken-mega', 'blaziken-mega', None),
    'swampert-mega': (260, 'mega', 7156, 'swampert-mega', 'swampert-mega', None),
    'sableye-mega': (302, 'mega', 'pz1945', 'sableye-mega', 'sableye-mega', None),
    'mawile-mega': (303, 'mega', 1859, 'mawile-mega', 'mawile-mega', None),
    'sharpedo-mega': (319, 'mega', 8120, 'sharpedo-mega', 'sharpedo-mega', None),
    'camerupt-mega': (323, 'mega', 5853, 'camerupt-mega', 'camerupt-mega', None),
    'altaria-mega': (334, 'mega', 2062, 'altaria-mega', 'altaria-mega', None),
    'absol-mega': (359, 'mega', 'pz1918', 'absol-mega', 'absol-mega', None),
    'glalie-mega': (362, 'mega', 2066, 'glalie-mega', 'glalie-mega', None),
    'latias-mega': (380, 'mega', 'pz1935', 'latias-mega', 'latias-mega', False),
    'latios-mega': (381, 'mega', 'look:2626', 'latios-mega', 'latios-mega', False),
    'mewtwo-megay': (150, 'mega-y', 'pz1944', 'mewtwo-megay', 'mewtwo-mega-y', None),
    'gardevoir-mega': (282, 'mega', 'pz1928', 'gardevoir-mega', 'gardevoir-mega', None),
    'banette-mega': (354, 'mega', 'pz1923', 'banette-mega', 'banette-mega', None),
    'salamence-mega': (373, 'mega', 'pz1946', 'salamence-mega', 'salamence-mega', None),
    'metagross-mega': (376, 'mega', 'pz1943', 'metagross-mega', 'metagross-mega', None),
    'kyogre-primal': (382, 'primal', 'look:1561', 'kyogre-primal', 'kyogre-primal', False),
    'groudon-primal': (383, 'primal', 'look:1562', 'groudon-primal', 'groudon-primal', False),
}


def fetch(url, name):
    path = os.path.join(CACHE, name)
    if not os.path.exists(path):
        subprocess.run(['curl', '-sfA', 'Mozilla', '-o', path, url], check=True)
    return path


def lab(rgb):
    rgb = rgb.astype(float) / 255
    rgb = np.where(rgb > 0.04045, ((rgb + 0.055) / 1.055) ** 2.4, rgb / 12.92)
    m = np.array([[0.4124, 0.3576, 0.1805], [0.2126, 0.7152, 0.0722], [0.0193, 0.1192, 0.9505]])
    xyz = rgb @ m.T / np.array([0.9505, 1, 1.089])
    f = np.where(xyz > 0.008856, np.cbrt(xyz), 7.787 * xyz + 16 / 116)
    return np.stack([116 * f[..., 1] - 16, 500 * (f[..., 0] - f[..., 1]), 200 * (f[..., 1] - f[..., 2])], -1)


def learned_rule(normal, shiny):
    """Each sheet colour takes the shiny colour of the nearest normal one, keeping its shading."""
    a, b = np.array(normal), np.array(shiny)
    both = (a[..., 3] > 0) & (b[..., 3] > 0)
    pairs = defaultdict(Counter)
    for p, q in zip(a[both][:, :3], b[both][:, :3]):
        pairs[tuple(p)][tuple(q)] += 1
    src = np.array(list(pairs))
    dst = np.array([pairs[k].most_common(1)[0][0] for k in pairs])
    src_lab = lab(src)

    def rule(r, g, b, h, s, v):
        i = np.linalg.norm(src_lab - lab(np.array([r, g, b])), axis=1).argmin()
        return tuple(dst[i].astype(int) + (np.array([r, g, b]) - src[i].astype(int)))
    return rule


def keep_flame(normal, shiny, grow=4):
    """The shiny sheet with the tail flame back in the normal sheet's colours: the orange around
    each yellow flame core. Thin yellow body lines vanish when the cores are shaved by a pixel."""
    a, out = np.array(normal.convert('RGBA')), np.array(shiny.convert('RGBA'))
    rgb, opaque = a[..., :3].astype(float) / 255, a[..., 3] > 0
    hi, lo = rgb.max(-1), rgb.min(-1)
    spread = np.maximum(hi - lo, 1e-6)
    sat = np.where(hi > 0, (hi - lo) / np.maximum(hi, 1e-6), 0)
    r, g, b = rgb[..., 0], rgb[..., 1], rgb[..., 2]
    hue = np.where(hi == r, ((g - b) / spread) % 6, np.where(hi == g, (b - r) / spread + 2, (r - g) / spread + 4)) * 60
    core = opaque & (hue >= 40) & (hue <= 62) & (sat > 0.55) & (hi > 0.85)
    pad = np.pad(core, 1)
    near = core & pad[:-2, 1:-1] & pad[2:, 1:-1] & pad[1:-1, :-2] & pad[1:-1, 2:]
    for _ in range(grow + 1):
        pad = np.pad(near, 1)
        near = near | pad[:-2, 1:-1] | pad[2:, 1:-1] | pad[1:-1, :-2] | pad[1:-1, 2:]
    flame = near & opaque & ((hue <= 40) | (hue >= 345)) & (sat >= 0.5)
    out[flame, :3] = a[flame, :3]
    return Image.fromarray(out)


# forms whose shiny keeps the normal tail flame (keep_flame)
KEEP_FLAME = {'charizard-megay'}


def recolour(sheet, rule):
    px = np.array(sheet.convert('RGBA'))
    out, opaque = px.copy(), px[..., 3] > 0
    for c in np.unique(px[opaque][:, :3], axis=0):
        r, g, b = (int(x) for x in c)
        h, s, v = colorsys.rgb_to_hsv(r / 255, g / 255, b / 255)
        new = rule(r, g, b, h * 360, s, v)
        if new is not None:
            out[opaque & np.all(px[..., :3] == c, axis=-1), :3] = np.clip(np.array(new), 0, 255).astype(np.uint8)
    return Image.fromarray(out)


def outfit_sheet(look):
    """Our outfit as a pack-style sheet (directions across, frames down), the layout dat-set-outfit.py reads."""
    import importlib.util
    sys.path.insert(0, os.path.join(ROOT, 'scripts', 'mapper'))
    import pvmap
    spec = importlib.util.spec_from_file_location('dat_set_outfit', os.path.join(ROOT, 'scripts', 'dat-set-outfit.py'))
    tool = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(tool)
    things = os.path.join(ROOT, 'core', 'client-legacy', 'data', 'things')
    data = open(os.path.join(things, 'data.dat'), 'rb').read()
    spr = pvmap.Spr(os.path.join(things, 'data.spr'))
    i = tool.outfit_spans(data)[look - 1][0]
    while data[i] != tool.dat_tool.LAST_ATTR:
        attr = data[i]
        i += 1 + (2 if attr in tool.dat_tool.U16_ATTRS else 4 if attr in tool.dat_tool.U16X2_ATTRS else 0)
    w, h = data[i + 1], data[i + 2]
    i += 3 + (1 if w > 1 or h > 1 else 0)
    layers, px, py, pz, frames = data[i:i + 5]
    ids = np.frombuffer(data, '<u4', w * h * layers * px * py * pz * frames, i + 5)
    # square frames standing on their bottom right tile, also for outfits wider than tall (Sharpedo)
    size = 32 * max(w, h)
    sheet = np.zeros((frames * size, px * size, 4), np.uint8)
    for f in range(frames):
        for d in range(px):
            for y in range(h):
                for x in range(w):
                    sid = int(ids[((f * pz * py * px + d) * layers) * h * w + y * w + x])
                    raw = sid and spr.rgba(sid)
                    if raw:
                        sheet[f * size + size - 32 * (y + 1):f * size + size - 32 * y,
                              d * size + size - 32 * (x + 1):d * size + size - 32 * x] = \
                            np.frombuffer(raw, np.uint8).reshape(32, 32, 4)
    return Image.fromarray(sheet)


def repaint(sheet, colours, glow):
    """Swaps the sheet's palette; with glow, seam pixels between two body pixels take the glow colour."""
    px = np.array(sheet.convert('RGBA'))
    rgb, opaque = px[..., :3], px[..., 3] > 0
    out = px.copy()
    if glow:
        seam = opaque & np.all(rgb == glow[0], axis=-1)
        body = opaque & ~seam & (rgb.max(axis=-1) > 40)
        pad = np.pad(body, 1)
        across = ((pad[1:-1, :-2] & pad[1:-1, 2:]) | (pad[:-2, 1:-1] & pad[2:, 1:-1])
                  | (pad[:-2, :-2] & pad[2:, 2:]) | (pad[:-2, 2:] & pad[2:, :-2]))
        out[seam & across, :3] = glow[1]
    for old, new in colours.items():
        hit = opaque & np.all(rgb == old, axis=-1) & np.all(out[..., :3] == rgb, axis=-1)
        out[hit, :3] = new
    return Image.fromarray(out)


def face(icon):
    """The box icon on a 32x32 face, standing on the bottom; wide ones keep their head side."""
    im = icon.convert('RGBA')
    im = im.crop(im.getbbox())
    im = im.crop((0, max(0, im.height - 30), min(32, im.width), im.height))
    out = Image.new('RGBA', (32, 32), (0, 0, 0, 0))
    out.alpha_composite(im, ((32 - im.width) // 2, 31 - im.height))
    return out


def bob(still):
    """4 frames lifting it 0, 1, 2 and 1 pixels, the rise of our own faces."""
    frames = []
    for up in (0, 1, 2, 1):
        frame = Image.new('RGBA', (32, 32), (0, 0, 0, 0))
        frame.alpha_composite(still.crop((0, up, 32, 32)))
        frames.append(frame)
    return frames


def model_still(gif):
    """First frame of the animated model, cropped, at least 100x100 like our pictures."""
    frame = next(ImageSequence.Iterator(Image.open(gif))).convert('RGBA')
    frame = frame.crop(frame.getbbox())
    w, h = max(100, frame.width), max(100, frame.height)
    out = Image.new('RGBA', (w, h), (0, 0, 0, 0))
    out.alpha_composite(frame, ((w - frame.width) // 2, (h - frame.height) // 2))
    return out


def main():
    if len(sys.argv) < 3:
        sys.exit(__doc__)
    pack, out = sys.argv[1:3]
    os.makedirs(CACHE, exist_ok=True)
    only = set(sys.argv[3:])
    for sub in ('normal', 'shiny', 'faces'):
        os.makedirs(os.path.join(out, sub), exist_ok=True)
    for name, (dex, suffix, sheet, showdown, pokesprite, rule) in FORMS.items():
        if only and name not in only:
            continue
        normal = Image.open(fetch('%s/gen5/%s.png' % (SHOWDOWN, showdown), 'gen5-%s.png' % showdown)).convert('RGBA')
        own = isinstance(sheet, str) and sheet.startswith('look:')
        if own:
            colours, glow = PRIMAL_PAINT.get(name, ({}, None))
            repaint(outfit_sheet(int(sheet[5:])), colours, glow).save(os.path.join(out, 'normal', name + '.png'))
        else:
            pack_sheet = Image.open(os.path.join(pack, 'outfit_%s_.png' % sheet))
            if isinstance(sheet, str):
                pack_sheet.save(os.path.join(out, 'normal', name + '.png'))
        if isinstance(rule, int) and rule is not False:
            Image.open(os.path.join(pack, 'outfit_%d_.png' % rule)).save(os.path.join(out, 'shiny', name + '.png'))
        elif rule is not False:
            shiny = Image.open(fetch('%s/gen5-shiny/%s.png' % (SHOWDOWN, showdown),
                                     'gen5-shiny-%s.png' % showdown)).convert('RGBA')
            shiny_sheet = recolour(pack_sheet, rule or learned_rule(normal, shiny))
            if name in KEEP_FLAME:
                shiny_sheet = keep_flame(pack_sheet, shiny_sheet)
            shiny_sheet.save(os.path.join(out, 'shiny', name + '.png'))
        for kind in ('regular', 'shiny') if rule is not False else ('regular',):
            icon = Image.open(fetch('%s/%s/%s.png' % (POKESPRITE, kind, pokesprite), 'box-%s-%s.png' % (kind, pokesprite)))
            still = face(icon)
            for n, frame in enumerate(bob(still)):
                frame.save(os.path.join(out, 'faces', '%s-%s-%d.png' % (name, 'shiny' if kind == 'shiny' else 'normal', n)))
            if kind == 'regular':
                still.save(os.path.join(IMAGES, 'pokeicons', '%03d-%s.png' % (dex, suffix)))
        normal.save(os.path.join(IMAGES, 'staticPortraits', '%d-%s.png' % (dex, suffix)))
        gif = fetch('%s/ani/%s.gif' % (SHOWDOWN, showdown), 'ani-%s.gif' % showdown)
        model_still(gif).save(os.path.join(IMAGES, 'pictures', '%d-%s.png' % (dex, suffix)))
        print(name)


if __name__ == '__main__':
    main()
