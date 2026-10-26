#!/usr/bin/env python3
"""Art for the Mega forms (docs/mega-art.md): shiny walk sheets, swap bar faces and pictures.

    scripts/art/mega_forms_art.py <6500 pack folder> <out dir>

For each form in FORMS this writes, from the sprite pack sheet already drawn in as its normal
look and the Showdown and pokesprite art (downloaded into /tmp/pv-megaart):
  <out>/shiny/<name>.png         the shiny walk sheet, a recolour of the pack sheet
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


# name: (dex, file suffix, pack sheet, Showdown name, pokesprite name, shiny rule or None to
# learn the colours from Showdown's normal and shiny gen5 sprites, which share one pose)
FORMS = {
    'venusaur-mega': (3, 'mega', 1863, 'venusaur-mega', 'venusaur-mega', None),
    'charizard-megax': (6, 'mega-x', 8231, 'charizard-megax', 'charizard-mega-x', mega_x),
    'charizard-megay': (6, 'mega-y', 8233, 'charizard-megay', 'charizard-mega-y', mega_y),
    'blastoise-mega': (9, 'mega', 1657, 'blastoise-mega', 'blastoise-mega', None),
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
    if len(sys.argv) != 3:
        sys.exit(__doc__)
    pack, out = sys.argv[1:]
    os.makedirs(CACHE, exist_ok=True)
    for sub in ('shiny', 'faces'):
        os.makedirs(os.path.join(out, sub), exist_ok=True)
    for name, (dex, suffix, sheet, showdown, pokesprite, rule) in FORMS.items():
        normal = Image.open(fetch('%s/gen5/%s.png' % (SHOWDOWN, showdown), 'gen5-%s.png' % showdown)).convert('RGBA')
        shiny = Image.open(fetch('%s/gen5-shiny/%s.png' % (SHOWDOWN, showdown),
                                 'gen5-shiny-%s.png' % showdown)).convert('RGBA')
        pack_sheet = Image.open(os.path.join(pack, 'outfit_%d_.png' % sheet))
        recolour(pack_sheet, rule or learned_rule(normal, shiny)).save(os.path.join(out, 'shiny', name + '.png'))
        for kind in ('regular', 'shiny'):
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
