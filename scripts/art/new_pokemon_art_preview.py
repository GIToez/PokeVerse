#!/usr/bin/env python3
"""Preview sheets for art of Pokemon we do not have yet (#387 and up).

    scripts/art/new_pokemon_art_preview.py [out dir]

Downloads samples from the sources in docs/new-pokemon-art.md into /tmp/pv-newart and
draws, next to our own art for the same slot:
  dex_art_compare.png/.gif   96x96 portrait + 3D Pokedex model (Showdown gen5 + ani)
  swapbar_faces.png/.gif     32x32 swap bar faces converted from Pokemon Shuffle
  overworld_pmd_x2.png/.gif  in-game walk sprites, Mystery Dungeon pixel-doubled
Our in-game sprites and faces are read from data.dat/data.spr, so data.spr has to be
pulled from LFS first. Nothing in the client or server is changed.
"""
import os
import re
import struct
import subprocess
import sys

from PIL import Image, ImageDraw, ImageFilter, ImageSequence

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, os.path.join(ROOT, 'scripts', 'mapper'))
import pvmap  # noqa: E402

THINGS = os.path.join(ROOT, 'core', 'client-legacy', 'data', 'things')
IMAGES = os.path.join(ROOT, 'core', 'client-legacy', 'data', 'images')
CACHE = '/tmp/pv-newart'
SHOWDOWN = 'https://play.pokemonshowdown.com/sprites'
PMD = 'https://raw.githubusercontent.com/PMDCollab/SpriteCollab/master'
BULBA_API = 'https://archives.bulbagarden.net/w/api.php'
BG = (32, 36, 48, 255)
OURS_BG = (60, 100, 64)
NEW_BG = (58, 68, 100)


def fetch(url, name):
    path = os.path.join(CACHE, name)
    if not os.path.exists(path):
        subprocess.run(['curl', '-sfA', 'Mozilla', '-o', path, url], check=True)
    return path


def shuffle(dex):
    name = 'shuffle_%03d.png' % dex
    if not os.path.exists(os.path.join(CACHE, name)):
        import json
        out = subprocess.run(['curl', '-sA', 'Mozilla', '%s?action=query&titles=File:Shuffle%03d.png'
                              '&prop=imageinfo&iiprop=url&format=json' % (BULBA_API, dex)],
                             capture_output=True, check=True).stdout
        page = next(iter(json.loads(out)['query']['pages'].values()))
        fetch(page['imageinfo'][0]['url'], name)
    return os.path.join(CACHE, name)


class Things:
    """Items and outfits of data.dat with their sprites from data.spr."""

    def __init__(self):
        self.data = open(os.path.join(THINGS, 'data.dat'), 'rb').read()
        _, items, outfits = struct.unpack_from('<IHH', self.data, 0)
        i, self.items = self._parse(12, items - 99)
        _, self.outfits = self._parse(i, outfits)
        self.spr = pvmap.Spr(os.path.join(THINGS, 'data.spr'))

    def _parse(self, i, count):
        data, out = self.data, []
        for _ in range(count):
            while True:
                a = data[i]
                i += 1
                if a == 0xFF:
                    break
                if a in pvmap.Dat.U16:
                    i += 2
                elif a in pvmap.Dat.U16X2:
                    i += 4
                elif a == pvmap.Dat.MARKET:
                    i += 6
                    i += 2 + struct.unpack_from('<H', data, i)[0] + 4
            w, h = data[i], data[i + 1]
            i += 2 + (1 if w > 1 or h > 1 else 0)
            dims = data[i:i + 5]
            i += 5
            n = w * h * dims[0] * dims[1] * dims[2] * dims[3] * dims[4]
            out.append((w, h) + tuple(dims) + (struct.unpack_from('<%dI' % n, data, i),))
            i += 4 * n
        return i, out

    def _draw(self, thing, frame, xpattern):
        w, h, layers, px, py, pz, _, sprites = thing
        img = Image.new('RGBA', (32 * w, 32 * h), (0, 0, 0, 0))
        base = (((frame * pz) * py) * px + xpattern) * layers * h * w
        for y in range(h):
            for x in range(w):
                rgba = self.spr.rgba(sprites[base + y * w + x])
                if rgba:
                    img.alpha_composite(Image.frombytes('RGBA', (32, 32), rgba),
                                        (32 * (w - 1 - x), 32 * (h - 1 - y)))
        return img

    def item_frames(self, client_id):
        thing = self.items[client_id - 100]
        return [self._draw(thing, f, 0) for f in range(thing[6])]

    def outfit_dirs(self, look):
        """{'N'|'E'|'S'|'W': [frames]} for an outfit (xpattern is the direction)."""
        thing = self.outfits[look - 1]
        return {'NESW'[d]: [self._draw(thing, f, d) for f in range(thing[6])] for d in range(thing[3])}


def gif_frames(path):
    return [f.convert('RGBA') for f in ImageSequence.Iterator(Image.open(path))]


def centered(img, size):
    canvas = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    img = img.copy()
    img.thumbnail((size, size))
    canvas.paste(img, ((size - img.width) // 2, (size - img.height) // 2), img)
    return canvas


def save(frames, out, name, duration):
    frames[0].convert('RGB').save(os.path.join(out, name + '.png'))
    pal = [f.convert('RGB').convert('P', palette=Image.ADAPTIVE) for f in frames]
    pal[0].save(os.path.join(out, name + '.gif'), save_all=True, append_images=pal[1:],
                duration=duration, loop=0)


def dex_sheet(out):
    ours = [(1, 'Bulbasaur'), (6, 'Charizard'), (25, 'Pikachu')]
    new = [('turtwig', 'Turtwig #387'), ('chimchar', 'Chimchar #390'), ('piplup', 'Piplup #393'),
           ('lucario', 'Lucario #448'), ('garchomp', 'Garchomp #445'), ('chespin', 'Chespin #650'),
           ('froakie', 'Froakie #656'), ('rowlet', 'Rowlet #722'), ('scorbunny', 'Scorbunny #813'),
           ('sprigatito', 'Sprigatito #906')]
    cells = []
    for dex, label in ours:
        cells.append((True, label, Image.open('%s/staticPortraits/%d.png' % (IMAGES, dex)).convert('RGBA'),
                      [Image.open('%s/pictures/%d.png' % (IMAGES, dex)).convert('RGBA')]))
    for name, label in new:
        portrait = Image.open(fetch('%s/gen5/%s.png' % (SHOWDOWN, name), 'gen5_%s.png' % name)).convert('RGBA')
        model = [centered(f, 100) for f in gif_frames(fetch('%s/ani/%s.gif' % (SHOWDOWN, name), 'ani_%s.gif' % name))]
        cells.append((False, label, portrait, model))
    cw, ch, cols = 130, 250, 7
    frames = []
    for t in range(0, 60, 2):
        im = Image.new('RGBA', (cw * cols, ch * ((len(cells) + cols - 1) // cols) + 30), BG)
        d = ImageDraw.Draw(im)
        d.text((8, 8), 'Top: 96x96 portrait. Bottom: 3D Pokedex picture. Green = ours, blue = Showdown', fill=(230,) * 3)
        for k, (mine, label, portrait, model) in enumerate(cells):
            x, y = (k % cols) * cw, 30 + (k // cols) * ch
            d.rectangle([x + 4, y, x + cw - 4, y + ch - 6], fill=OURS_BG if mine else NEW_BG)
            d.text((x + 8, y + 4), label, fill=(255,) * 3)
            im.paste(portrait, (x + 17, y + 20), portrait)
            frame = centered(model[t % len(model)], 100)
            im.paste(frame, (x + 15, y + 125), frame)
        frames.append(im)
    save(frames, out, 'dex_art_compare', 60)


def shuffle_face(path, size=30, colors=20):
    """A Shuffle icon as a 32x32 face with hard alpha, a dark outline and few colors."""
    im = Image.open(path).convert('RGBA')
    im = im.crop(im.getbbox())
    im.thumbnail((size, size), Image.LANCZOS)
    im.putalpha(im.split()[3].point(lambda a: 255 if a > 110 else 0))
    face = Image.new('RGBA', (32, 32), (0, 0, 0, 0))
    face.paste(im, ((32 - im.width) // 2, (32 - im.height) // 2), im)
    alpha = face.split()[3]
    outline = Image.new('RGBA', (32, 32), (48, 16, 16, 255))
    outline.putalpha(alpha.filter(ImageFilter.MaxFilter(3)))
    outline.alpha_composite(face)
    flat = outline.convert('RGB').quantize(colors, method=Image.MEDIANCUT).convert('RGBA')
    flat.putalpha(outline.split()[3])
    return flat


def bob(face):
    """Placeholder 4-frame idle (ours are hand-drawn)."""
    frames = []
    for dy, squash in [(0, 0), (1, 1), (0, 0), (-1, 0)]:
        c = Image.new('RGBA', (32, 32), (0, 0, 0, 0))
        f = face.resize((32, 32 - squash), Image.NEAREST) if squash else face
        c.alpha_composite(f, (0, max(0, dy + squash)))
        frames.append(c)
    return frames


def faces_sheet(out, things):
    ours = [('Bulbasaur #1', 10635), ('Charizard #6', 10640), ('Pikachu #25', 10659),
            ('Gyarados #130', 10764), ('Mewtwo #150', 10784)]
    new = [('Turtwig #387', 387), ('Chimchar #390', 390), ('Piplup #393', 393), ('Garchomp #445', 445),
           ('Lucario #448', 448), ('Chespin #650', 650), ('Froakie #656', 656), ('Rowlet #722', 722),
           ('Litten #725', 725)]
    cells = [(True, label, things.item_frames(cid)) for label, cid in ours]
    cells += [(False, label, bob(shuffle_face(shuffle(dex)))) for label, dex in new]
    z, cols = 3, 7
    cw, ch = 32 * z + 30, 32 * z + 40
    frames = []
    for t in range(8):
        im = Image.new('RGBA', (cw * cols + 10, 30 + ch * ((len(cells) + cols - 1) // cols)), BG)
        d = ImageDraw.Draw(im)
        d.text((8, 8), 'Swap bar faces, 32x32 at 3x. Green = ours, blue = converted from Pokemon Shuffle', fill=(230,) * 3)
        for k, (mine, label, fr) in enumerate(cells):
            x, y = 5 + (k % cols) * cw, 30 + (k // cols) * ch
            d.rectangle([x, y, x + cw - 6, y + ch - 6], fill=OURS_BG if mine else NEW_BG)
            im.alpha_composite(fr[(t // 2) % len(fr)].resize((32 * z, 32 * z), Image.NEAREST), (x + 12, y + 6))
            d.text((x + 6, y + ch - 22), label, fill=(255,) * 3)
        frames.append(im)
    save(frames, out, 'swapbar_faces', 110)


def pmd_walk(dex):
    """Mystery Dungeon walk frames for S/E/N/W (rows 0, 2, 4, 6 of the 8-direction sheet)."""
    xml = open(fetch('%s/sprite/%04d/AnimData.xml' % (PMD, dex), 'pmd_%04d.xml' % dex)).read()
    w, h = map(int, re.search(r'<Name>Walk</Name>.*?<FrameWidth>(\d+)</FrameWidth>\s*'
                              r'<FrameHeight>(\d+)</FrameHeight>', xml, re.S).groups())
    sheet = Image.open(fetch('%s/sprite/%04d/Walk-Anim.png' % (PMD, dex), 'pmd_%04d.png' % dex)).convert('RGBA')
    n = sheet.width // w
    return {d: [sheet.crop((f * w, r * h, f * w + w, r * h + h)) for f in range(n)]
            for d, r in {'S': 0, 'E': 2, 'N': 4, 'W': 6}.items()}


def trim(dirs, scale=1):
    out = {}
    for d, frames in dirs.items():
        boxes = [f.getbbox() for f in frames]
        bb = (min(b[0] for b in boxes), min(b[1] for b in boxes), max(b[2] for b in boxes), max(b[3] for b in boxes))
        size = ((bb[2] - bb[0]) * scale, (bb[3] - bb[1]) * scale)
        out[d] = [f.crop(bb).resize(size, Image.NEAREST) for f in frames]
    return out


def overworld_sheet(out, things):
    cells = [(True, 'Bulbasaur', trim(things.outfit_dirs(352))),
             (True, 'Charizard', trim(things.outfit_dirs(357)))]
    for dex, label in [(6, 'Charizard'), (387, 'Turtwig #387'), (448, 'Lucario #448'), (906, 'Sprigatito #906')]:
        cells.append((False, 'PMD %s x2' % label, trim(pmd_walk(dex), 2)))
    z, box, lw = 2, 144, 170
    frames = []
    for t in range(12):
        im = Image.new('RGBA', (lw + 4 * (box + 8) + 10, 30 + len(cells) * (box + 8)), BG)
        d = ImageDraw.Draw(im)
        d.text((8, 8), 'In-game walk sprites at 2x. Columns: South, East, North, West', fill=(230,) * 3)
        for r, (mine, label, dirs) in enumerate(cells):
            y = 30 + r * (box + 8)
            d.text((8, y + box // 2 - 6), ('OURS ' if mine else '') + label,
                   fill=(140, 230, 140) if mine else (230,) * 3)
            for c, dn in enumerate('SENW'):
                x = lw + c * (box + 8)
                d.rectangle([x, y, x + box - 1, y + box - 1], fill=(96, 140, 88))
                f = dirs[dn][t % len(dirs[dn])]
                f = f.resize((f.width * z, f.height * z), Image.NEAREST)
                im.alpha_composite(f, (x + (box - f.width) // 2, y + box - 4 - f.height))
        frames.append(im)
    save(frames, out, 'overworld_pmd_x2', 140)


def main():
    out = sys.argv[1] if len(sys.argv) > 1 else CACHE
    os.makedirs(CACHE, exist_ok=True)
    os.makedirs(out, exist_ok=True)
    dex_sheet(out)
    things = Things()
    faces_sheet(out, things)
    overworld_sheet(out, things)
    print('wrote sheets to', out)


if __name__ == '__main__':
    main()
