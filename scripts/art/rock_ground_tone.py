#!/usr/bin/env python3
"""Mountain top ground (server 4405-4421) drawn as rocky ground (4570-4579).

The dark mountain top ground shows as hard squares where it was painted beside rocky ground and
the light stone border. Its sprites get the rocky ground tiles, so the two read as one ground.

    rock_ground_tone.py --mockup out.png X0 Y0 X1 Y1   floor 7 of the map with the new paint
    rock_ground_tone.py --write-spr                     puts the new sprites into data.spr

The original sprites are kept in art/sprites/rock-ground/original.png (with sprites.txt), so the
paint can be rebuilt after data.spr carries it.
"""
import argparse
import os
import sys

import numpy as np
from PIL import Image

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, os.path.join(ROOT, 'scripts/mapper'))
import pvmap  # noqa: E402
from render import Renderer  # noqa: E402

MAP = os.path.join(ROOT, 'core/server/data/world/map.otbm')
ITEMS = os.path.join(ROOT, 'core/server/data/items/items.otb')
DAT = os.path.join(ROOT, 'core/client-legacy/data/things/data.dat')
SPR = os.path.join(ROOT, 'core/client-legacy/data/things/data.spr')
OUT = os.path.join(ROOT, 'art/sprites/rock-ground')
DARK = range(4405, 4422)
LIGHT = range(4570, 4580)


def item_sprites(otb, dat, server_ids):
    out = []
    for sid in server_ids:
        for s in dat.things[otb.client_id(sid)][8]:
            if s and s not in out:
                out.append(s)
    return out


def originals(ids, spr):
    sheet_path, ids_path = os.path.join(OUT, 'original.png'), os.path.join(OUT, 'sprites.txt')
    if os.path.exists(sheet_path):
        ids = [int(s) for s in open(ids_path).read().split()]
        sheet = np.array(Image.open(sheet_path).convert('RGBA'))
        return {sid: sheet[(i // 16) * 32:(i // 16) * 32 + 32, (i % 16) * 32:(i % 16) * 32 + 32].copy()
                for i, sid in enumerate(ids)}
    art = {sid: np.frombuffer(spr.rgba(sid), np.uint8).reshape(32, 32, 4).copy() for sid in ids}
    sheet = np.zeros((((len(ids) + 15) // 16) * 32, 16 * 32, 4), np.uint8)
    for i, sid in enumerate(ids):
        sheet[(i // 16) * 32:(i // 16) * 32 + 32, (i % 16) * 32:(i % 16) * 32 + 32] = art[sid]
    os.makedirs(OUT, exist_ok=True)
    Image.fromarray(sheet, 'RGBA').save(sheet_path)
    open(ids_path, 'w').write(' '.join(map(str, ids)) + '\n')
    return art


def repaint(art, light):
    """Every dark sprite becomes one of the rocky ground tiles. A recolor of the dark texture keeps
    its cracks and tile seams and does not read as the same ground, so the tiles are copied whole;
    neighbouring sprites of a 3x3 pattern get different ones."""
    tiles = [light[s] for s in sorted(light)]
    return {sid: tiles[(i * 3 + i // 9) % len(tiles)].copy() for i, sid in enumerate(sorted(art))}


def write_spr(new):
    # data.spr is hard linked into other checkouts, so write a new file rather than edit it
    tmp = SPR + '.tmp'
    px = {sid: img.tobytes() for sid, img in new.items()}
    pvmap.write_sprites(SPR, tmp, px)
    check = pvmap.Spr(tmp)
    for sid, raw in px.items():
        want = np.frombuffer(raw, np.uint8).reshape(-1, 4).copy()
        want[want[:, 3] == 0] = 0  # .spr keeps no color for transparent pixels
        if (check.rgba(sid) or bytes(4096)) != want.tobytes():
            raise SystemExit('sprite %d did not read back the same' % sid)
    old = pvmap.Spr(SPR)
    for sid in range(1, old.count + 1, 97):
        if sid not in px and old.rgba(sid) != check.rgba(sid):
            raise SystemExit('sprite %d changed though it was not repainted' % sid)
    old.f.close()
    check.f.close()
    os.replace(tmp, SPR)
    print('wrote %d sprites into data.spr' % len(px))


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--mockup', nargs=5, metavar=('OUT', 'X0', 'Y0', 'X1', 'Y1'))
    ap.add_argument('--write-spr', action='store_true')
    args = ap.parse_args()
    otb, dat, spr = pvmap.Otb(ITEMS), pvmap.Dat(DAT), pvmap.Spr(SPR)
    dark = item_sprites(otb, dat, DARK)
    others = {s for cid, t in dat.things.items() for s in t[8]
              if cid not in {otb.client_id(i) for i in DARK}}
    if others & set(dark):
        raise SystemExit('sprites shared with other items: %s' % sorted(others & set(dark)))
    light = {s: np.frombuffer(spr.rgba(s), np.uint8).reshape(32, 32, 4)
             for s in item_sprites(otb, dat, LIGHT)}
    new = repaint(originals(dark, spr), light)
    if args.mockup:
        out, x0, y0, x1, y1 = args.mockup[0], *map(int, args.mockup[1:])
        r = Renderer(ITEMS, DAT, SPR)
        r.sprite_images.update({s: Image.fromarray(img, 'RGBA') for s, img in new.items()})
        tiles = pvmap.read_region(MAP, x0 - 2, y0 - 2, x1 + 10, y1 + 10, range(0, 8))
        r.render(tiles, x0, y0, x1, y1, 7).convert('RGB').save(out)
        print('wrote', out)
    if args.write_spr:
        write_spr(new)


if __name__ == '__main__':
    main()
