#!/usr/bin/env python3
"""Puts back the original art of items that can be picked up, which the DS world repaint
(ds_world.py, October 21 and 22) drew over: Poke Ball and apple stacks, books, scrolls, chests,
flowers and the like came out flat and washed out in the bag.

A sprite goes back to its art from before the repaint when every item drawing it can be picked
up, the repaint changed it, and nothing has changed it since. Sprites a pickup shares with
furniture or map decoration (crates, barrels, banners) keep the world style.

    restore_pickup_icons.py --sheet out.png    before and after of every item that changes
    restore_pickup_icons.py --write-spr        put the original art back into data.spr
"""
import argparse
import collections
import os
import struct
import subprocess
import sys

import numpy as np
from PIL import Image, ImageDraw

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
sys.path.insert(0, os.path.join(os.path.dirname(HERE), 'mapper'))
import house_reskin as h  # noqa: E402
import pvmap  # noqa: E402

PICKUPABLE = 17
BEFORE = 'backup/data-spr-before-ds-style'
AFTER = 'db191e9b'      # the last commit of the repaint
SPR_PATH = 'core/client-legacy/data/things/data.spr'


def lfs_file(ref):
    """Local path of data.spr as it was at ref, fetched from LFS if needed."""
    root = os.path.dirname(os.path.dirname(HERE))
    pointer = subprocess.check_output(['git', 'show', '%s:%s' % (ref, SPR_PATH)], cwd=root, text=True)
    oid = next(line.split(':')[1] for line in pointer.splitlines() if line.startswith('oid '))
    path = os.path.join(root, '.git', 'lfs', 'objects', oid[:2], oid[2:4], oid)
    if not os.path.exists(path):
        subprocess.check_call(['git', 'lfs', 'fetch', 'origin', ref, '--include', SPR_PATH], cwd=root)
    return path


class Raw:
    """Encoded sprite bytes, for comparing sprites without decoding them."""

    def __init__(self, path):
        self.data = open(path, 'rb').read()
        self.count = struct.unpack_from('<I', self.data, 4)[0]

    def get(self, sid):
        if sid > self.count:
            return None
        off = struct.unpack_from('<I', self.data, 8 + (sid - 1) * 4)[0]
        if off == 0:
            return b''
        size = struct.unpack_from('<H', self.data, off + 3)[0]
        return self.data[off + 3:off + 5 + size]


def find():
    """({sprite id: original 32x32 RGBA}, client ids of the items that change)."""
    dat = pvmap.Dat(h.DAT)
    users = collections.defaultdict(set)
    pickups = set()
    for cid, t in dat.things.items():
        for sid in t[8]:
            if sid:
                users[sid].add(cid)
        if PICKUPABLE in t[0]:
            pickups.add(cid)
    before_path = lfs_file(BEFORE)
    before, after, now = Raw(before_path), Raw(lfs_file(AFTER)), Raw(h.SPR)
    original = pvmap.Spr(before_path)
    out, items = {}, set()
    for sid in range(1, before.count + 1):
        if not users[sid] or not users[sid] <= pickups:
            continue
        old = before.get(sid)
        if old == after.get(sid) or now.get(sid) != after.get(sid):
            continue
        px = original.rgba(sid)
        out[sid] = np.frombuffer(px, np.uint8).reshape(32, 32, 4).copy() if px else np.zeros((32, 32, 4), np.uint8)
        items |= users[sid]
    return out, sorted(items)


def sheet(sprites, items, path):
    dat, spr = pvmap.Dat(h.DAT), pvmap.Spr(h.SPR)

    def icon(cid, fixed):
        _, w, hgt, *_rest, sids = dat.things[cid]
        im = Image.new('RGBA', (32 * w, 32 * hgt))
        for y in range(hgt):
            for x in range(w):
                sid = sids[y * w + x]
                if fixed and sid in sprites:
                    tile = Image.fromarray(sprites[sid], 'RGBA')
                else:
                    px = spr.rgba(sid)
                    tile = Image.frombytes('RGBA', (32, 32), px) if px else None
                if tile:
                    im.paste(tile, (32 * (w - 1 - x), 32 * (hgt - 1 - y)))
        return im.resize((64, 64), Image.NEAREST)

    cols = 12
    rows = (len(items) + cols - 1) // cols
    out = Image.new('RGBA', (cols * 140, rows * 80), (22, 26, 44, 255))
    draw = ImageDraw.Draw(out)
    for i, cid in enumerate(items):
        x, y = i % cols * 140, i // cols * 80
        out.alpha_composite(icon(cid, False), (x + 2, y + 2))
        out.alpha_composite(icon(cid, True), (x + 68, y + 2))
        draw.text((x + 2, y + 67), str(cid), fill=(200, 200, 200))
    out.save(path)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--sheet', help='before (now) and after (original) of every item that changes')
    ap.add_argument('--write-spr', action='store_true', help='put the original art back into data.spr')
    args = ap.parse_args()
    sprites, items = find()
    print('%d sprites on %d items' % (len(sprites), len(items)))
    if args.sheet:
        sheet(sprites, items, args.sheet)
    if args.write_spr:
        h.write_spr(sprites)


if __name__ == '__main__':
    main()
