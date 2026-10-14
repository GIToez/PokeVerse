#!/usr/bin/env python3
"""Renders part of an OTBM map with the client sprites, like RME's view of it.

    scripts/mapper/render.py <map.otbm> <x0> <y0> <x1> <y1> <out.png> [--floor 7] [--scale 0.5]
        [--items core/server/data/items/items.otb] [--dat core/client-legacy/data/things/data.dat]
        [--spr core/client-legacy/data/things/data.spr] [--no-upper]

Upper floors (lower z numbers) are drawn on top, shifted one tile up-left per floor, the way
the client shows them, unless --no-upper is given.
"""
import argparse
import os
import sys

from PIL import Image

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import pvmap  # noqa: E402

ROOT = os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..'))
GROUND, BORDER, BOTTOM, TOP, DISPLACEMENT, ELEVATION = 0, 1, 2, 3, 25, 26


class Renderer:
    def __init__(self, otb_path, dat_path, spr_path):
        self.otb = pvmap.Otb(otb_path)
        self.dat = pvmap.Dat(dat_path)
        self.spr = pvmap.Spr(spr_path)
        self.sprite_images = {}

    def sprite(self, sid):
        if sid not in self.sprite_images:
            px = self.spr.rgba(sid)
            self.sprite_images[sid] = Image.frombytes('RGBA', (32, 32), px) if px else None
        return self.sprite_images[sid]

    def layer_of(self, attrs):
        if GROUND in attrs:
            return 0
        if BORDER in attrs:
            return 1
        if BOTTOM in attrs:
            return 2
        if TOP in attrs:
            return 4
        return 3

    def draw_tile(self, img, items, x, y, z, px, py):
        things = []
        for sid in items:
            cid = self.otb.client_id(sid)
            thing = self.dat.things.get(cid)
            if thing:
                things.append(thing)
        common = [t for t in things if self.layer_of(t[0]) == 3]
        ordered = ([t for t in things if self.layer_of(t[0]) in (0, 1, 2)] + common[::-1]
                   + [t for t in things if self.layer_of(t[0]) == 4])
        elevation = 0
        for attrs, w, h, layers, pxn, pyn, pzn, frames, sprites in ordered:
            dx, dy = attrs.get(DISPLACEMENT, (0, 0))
            xp, yp, zp = x % pxn, y % pyn, z % pzn
            for layer in range(layers):
                for hy in range(h):
                    for wx in range(w):
                        idx = ((((zp * pyn + yp) * pxn + xp) * layers + layer) * h + hy) * w + wx
                        im = self.sprite(sprites[idx]) if idx < len(sprites) else None
                        if im:
                            img.alpha_composite(im, (px - wx * 32 - dx - elevation, py - hy * 32 - dy - elevation))
            if ELEVATION in attrs:
                elevation = min(24, elevation + attrs[ELEVATION])

    def render(self, tiles, x0, y0, x1, y1, floor, upper=True):
        top = 0 if upper else floor
        margin = (floor - top) + 2
        w, h = (x1 - x0 + 1 + margin) * 32, (y1 - y0 + 1 + margin) * 32
        img = Image.new('RGBA', (w, h), (0, 0, 0, 255))
        for z in range(floor, top - 1, -1):
            shift = (floor - z) * 32
            for y in range(y0 - 2, y1 + margin + 1):
                for x in range(x0 - 2, x1 + margin + 1):
                    items = tiles.get((x, y, z))
                    if items:
                        self.draw_tile(img, items, x, y, z, (x - x0 + margin) * 32 - shift, (y - y0 + margin) * 32 - shift)
        m = margin * 32
        return img.crop((m, m, m + (x1 - x0 + 1) * 32, m + (y1 - y0 + 1) * 32))

    def render_scaled(self, tiles, x0, y0, x1, y1, floor, upper=True, scale=1.0, chunk=64):
        """Same as render, built in chunks so large areas can be drawn small without huge buffers."""
        if scale >= 1.0:
            return self.render(tiles, x0, y0, x1, y1, floor, upper)
        px = 32 * scale
        out = Image.new('RGBA', (int((x1 - x0 + 1) * px), int((y1 - y0 + 1) * px)), (0, 0, 0, 255))
        for cy in range(y0, y1 + 1, chunk):
            for cx in range(x0, x1 + 1, chunk):
                ex, ey = min(x1, cx + chunk - 1), min(y1, cy + chunk - 1)
                part = self.render(tiles, cx, cy, ex, ey, floor, upper)
                w, h = int(round((ex - x0 + 1) * px)) - int(round((cx - x0) * px)), int(round((ey - y0 + 1) * px)) - int(round((cy - y0) * px))
                out.paste(part.resize((w, h), Image.LANCZOS), (int(round((cx - x0) * px)), int(round((cy - y0) * px))))
        return out


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('map')
    ap.add_argument('x0', type=int)
    ap.add_argument('y0', type=int)
    ap.add_argument('x1', type=int)
    ap.add_argument('y1', type=int)
    ap.add_argument('out')
    ap.add_argument('--floor', type=int, default=7)
    ap.add_argument('--scale', type=float, default=1.0)
    ap.add_argument('--no-upper', action='store_true')
    ap.add_argument('--items', default=os.path.join(ROOT, 'core/server/data/items/items.otb'))
    ap.add_argument('--dat', default=os.path.join(ROOT, 'core/client-legacy/data/things/data.dat'))
    ap.add_argument('--spr', default=os.path.join(ROOT, 'core/client-legacy/data/things/data.spr'))
    args = ap.parse_args()

    r = Renderer(args.items, args.dat, args.spr)
    top = 0 if not args.no_upper else args.floor
    tiles = pvmap.read_region(args.map, args.x0 - 2, args.y0 - 2, args.x1 + 10, args.y1 + 10, range(top, args.floor + 1))
    img = r.render_scaled(tiles, args.x0, args.y0, args.x1, args.y1, args.floor, not args.no_upper, args.scale)
    if args.scale > 1.0:
        img = img.resize((int(img.width * args.scale), int(img.height * args.scale)), Image.LANCZOS)
    img.convert('RGB').save(args.out)
    print('wrote %s (%dx%d)' % (args.out, img.width, img.height))


if __name__ == '__main__':
    main()
