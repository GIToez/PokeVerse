#!/usr/bin/env python3
"""Stands the Mega and Primal walk sprites on their tile like their base form.

    scripts/art/mega_align.py [--dry-run] [form name ...]

The sprite pack draws a Pokemon centred in its frame, while our outfits stand on the bottom
right tile, so a pack Mega sat up and to the left of its base form. For each Mega outfit (the
monster files in monster/Mega) this finds, per direction, where the feet are (the middle of the
bottom quarter of the sprite and its lowest row) on the Mega and on its base form, and:
  - gives the outfit an offset (dat attribute 25, signed; the PokeVerse client reads it so) that
    moves it right and down by the largest shift any direction needs;
  - moves each direction's art left and up by what it needs less than that, growing the frame
    up and left when the art would leave it.
No direction is moved past the right or bottom edge of the tile; a wide Mega stands further left.
Run it on the outfits as drawn in; running it again changes nothing.
"""
import os
import re
import struct
import subprocess
import sys
import tempfile

import numpy as np
from PIL import Image

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, os.path.join(ROOT, 'scripts', 'art'))
import mega_forms_art  # noqa: E402

MONSTERS = os.path.join(ROOT, 'core', 'server', 'data', 'monster')
DAT = os.path.join(ROOT, 'core', 'client-legacy', 'data', 'things', 'data.dat')
tool = None


def load_tool():
    import importlib.util
    spec = importlib.util.spec_from_file_location('dat_set_outfit', os.path.join(ROOT, 'scripts', 'dat-set-outfit.py'))
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def monster_files():
    xml = open(os.path.join(MONSTERS, 'monsters.xml'), encoding='latin-1').read()
    return {name.lower(): path for name, path in re.findall(r'<monster name="([^"]*)" file="([^"]*)"', xml)}


def look_of(files, name):
    text = open(os.path.join(MONSTERS, files[name.lower()]), encoding='latin-1').read()
    return int(re.search(r'look type="(\d+)"', text).group(1))


def base_name(form):
    return re.sub(r' [XY]$', '', form.replace('Mega ', '').replace('Primal ', ''))


def feet(sheet):
    """Per direction: the feet's x and lowest row, from the frame's bottom right."""
    a = np.array(sheet)
    size = a.shape[1] // 4
    out = []
    for d in range(4):
        seen = (a[:, d * size:(d + 1) * size, 3] > 0).reshape(-1, size, size).any(0)
        ys, xs = np.nonzero(seen)
        top, bottom = ys.min(), ys.max()
        band = max(4, (bottom - top) // 4)
        fx = np.nonzero(seen[bottom - band:bottom + 1].any(0))[0]
        out.append(((fx.min() + fx.max()) / 2 - size, bottom - size))
    return out


def edges(sheet):
    """Per direction: the art's right and bottom edge over all frames, from the frame's bottom right."""
    a = np.array(sheet)
    size = a.shape[1] // 4
    out = []
    for d in range(4):
        seen = (a[:, d * size:(d + 1) * size, 3] > 0).reshape(-1, size, size).any(0)
        ys, xs = np.nonzero(seen)
        out.append((xs.max() + 1 - size, ys.max() + 1 - size))
    return out


def displacement(data, start):
    """The outfit's offset (x, y) and where its attributes end."""
    i, offset = start, (0, 0)
    while data[i] != tool.dat_tool.LAST_ATTR:
        attr = data[i]
        if attr == 25:
            offset = struct.unpack('<hh', data[i + 1:i + 5])
        i += 1 + (2 if attr in tool.dat_tool.U16_ATTRS else 4 if attr in tool.dat_tool.U16X2_ATTRS else 0)
    return offset, i


def shifted(sheet, moves):
    """The sheet with direction d's art moved left and up by moves[d], in a frame grown to fit."""
    a = np.array(sheet)
    size = a.shape[1] // 4
    frames = a.shape[0] // size
    grow = 0
    for d, (mx, my) in enumerate(moves):
        seen = a[:, d * size:(d + 1) * size, 3] > 0
        cells = seen.reshape(frames, size, size).any(0)
        ys, xs = np.nonzero(cells)
        grow = max(grow, mx - xs.min(), my - ys.min())
    new = size + (-(-grow // 32) * 32 if grow > 0 else 0)
    out = Image.new('RGBA', (4 * new, frames * new), (0, 0, 0, 0))
    for f in range(frames):
        for d, (mx, my) in enumerate(moves):
            cell = Image.fromarray(a[f * size:(f + 1) * size, d * size:(d + 1) * size])
            frame = Image.new('RGBA', (new, new), (0, 0, 0, 0))
            frame.paste(cell, (new - size - mx, new - size - my))
            out.paste(frame, (d * new, f * new))
    return out


def main():
    global tool
    args = sys.argv[1:]
    dry = '--dry-run' in args
    only = {a.lower() for a in args if a != '--dry-run'}
    tool = load_tool()
    files = monster_files()
    data = open(DAT, 'rb').read()
    spans = tool.outfit_spans(data)
    forms = sorted(name for name, path in files.items() if path.lower().startswith('mega/'))
    plans = []
    for form in forms:
        if only and form not in only:
            continue
        title = re.search(r'<monster name="([^"]*)"', open(os.path.join(MONSTERS, files[form]), encoding='latin-1').read()).group(1)
        look, base = look_of(files, form), look_of(files, base_name(title))
        (ox, oy), _ = displacement(data, spans[look - 1][0])
        (bx, by), _ = displacement(data, spans[base - 1][0])
        sheet = mega_forms_art.outfit_sheet(look)
        mega, ours = feet(sheet), feet(mega_forms_art.outfit_sheet(base))
        # shifts right and down on the map, counting the offsets both already have
        need = [(round(ours[d][0] - bx - (mega[d][0] - ox)), int(ours[d][1] - by - (mega[d][1] - oy))) for d in range(4)]
        # never past the tile's right or bottom edge: the next tiles' items are drawn over that
        need = [(min(nx, ox - rx), min(ny, oy - ry)) for (nx, ny), (rx, ry) in zip(need, edges(sheet))]
        dx, dy = max(n[0] for n in need), max(n[1] for n in need)
        moves = [(dx - n[0], dy - n[1]) for n in need]
        if not (dx or dy or any(mx or my for mx, my in moves)):
            continue
        print('%-24s look %4d on %4d: offset %+d, %+d; per direction %s' % (title, look, base, ox - dx, oy - dy, moves))
        plans.append((look, shifted(sheet, moves) if any(mx or my for mx, my in moves) else None, (ox - dx, oy - dy)))
    if dry or not plans:
        return
    with tempfile.TemporaryDirectory() as tmp:
        pairs = []
        for look, sheet, _ in plans:
            if sheet is not None:
                path = os.path.join(tmp, '%d.png' % look)
                sheet.save(path)
                pairs += [str(look), path]
        if pairs:
            subprocess.run([sys.executable, os.path.join(ROOT, 'scripts', 'dat-set-outfit.py')] + pairs, check=True)
    data = bytearray(open(DAT, 'rb').read())
    for look, _, (x, y) in sorted(plans, reverse=True):
        start = tool.outfit_spans(bytes(data))[look - 1][0]
        i = start
        while data[i] != tool.dat_tool.LAST_ATTR:
            attr = data[i]
            step = 1 + (2 if attr in tool.dat_tool.U16_ATTRS else 4 if attr in tool.dat_tool.U16X2_ATTRS else 0)
            if attr == 25:
                del data[i:i + step]
                continue
            i += step
        if x or y:
            data[i:i] = bytes([25]) + struct.pack('<hh', x, y)
    tool.dat_tool.parse(bytes(data))
    open(DAT, 'wb').write(data)


if __name__ == '__main__':
    main()
