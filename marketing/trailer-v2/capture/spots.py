#!/usr/bin/env python3
"""Nearest open outdoor spot (no roof above, 5x5 standable) to each X,Y[,Z]: spots.py X,Y [X,Y ...] [--r 25] [--water]"""
import sys
sys.path.insert(0, '/tmp/wt-merge/scripts/mapper')
import johto_edit, pvmap, walkcheck

MAP = '/tmp/pvtrailer/server/data/world/map.otbm'
args = [a for a in sys.argv[1:] if not a.startswith('--')]
R = int(next((a.split('=')[1] for a in sys.argv if a.startswith('--r=')), 25))
water = '--water' in sys.argv
data = open(MAP, 'rb').read()
otb = pvmap.Otb(walkcheck.ITEMS_OTB)
boxes = {}
for a in args:
    v = [int(x) for x in a.split(',')]
    boxes[a] = (v[0] - R - 3, v[1] - R - 3, v[0] + R + 3, v[1] + R + 3)
RAW = johto_edit.read_boxes(data, boxes)
for a in args:
    v = [int(x) for x in a.split(',')]
    x, y, z = v[0], v[1], (v[2] if len(v) > 2 else 7)
    tiles = {k: johto_edit.ids_of(t) for k, t in RAW[a].items()}
    w = walkcheck.Walker(tiles, otb=otb)
    def roofless(p):
        return all((p[0], p[1], zz) not in tiles for zz in range(0, p[2]))
    def ok(p):
        if water:
            ids = tiles.get(p, [])
            return ids and any(i in walkcheck.WATER for i in ids) and roofless(p)
        return all(w.standable((p[0] + dx, p[1] + dy, p[2])) and roofless((p[0] + dx, p[1] + dy, p[2]))
                   for dx in range(-2, 3) for dy in range(-2, 3))
    best = None
    for d in range(R + 1):
        for dx in range(-d, d + 1):
            for dy in range(-d, d + 1):
                if max(abs(dx), abs(dy)) != d: continue
                if ok((x + dx, y + dy, z)):
                    best = (x + dx, y + dy, z); break
            if best: break
        if best: break
    print(a, '->', '%d,%d,%d' % best if best else 'none')
