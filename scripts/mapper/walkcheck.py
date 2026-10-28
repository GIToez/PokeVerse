#!/usr/bin/env python3
"""Where a player can walk from a spot, by the server's rules.

    scripts/mapper/walkcheck.py X,Y,Z [--box x0,y0,x1,y1] [--to X,Y,Z ...] [--surf] [--map mapper/map/dev.otbm]

A tile can be stood on when it has items and none of them blocks (items.otb). Water needs --surf.
Floor changes follow Tile::queryDestination (core/server/src/tile.cpp): stepping onto a floorchange
north/south/east/west item takes you up a floor and a tile that way, onto a floorchange down item a
floor down (and a tile back off the stairs below). Reports whether each --to spot is reached, and for
one that isn't, the reached tile closest to it.
"""
import argparse
import os
import re
import sys
from collections import deque

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import johto_edit  # noqa: E402
import pvmap  # noqa: E402

ROOT = os.path.dirname(os.path.dirname(HERE))
ITEMS_XML = os.path.join(ROOT, 'core', 'server', 'data', 'items', 'items.xml')
ITEMS_OTB = os.path.join(ROOT, 'core', 'server', 'data', 'items', 'items.otb')
WATER = set(range(4608, 4626)) | {4664, 4665, 4666} | set(range(4820, 4826))
STEPS = {'north': (0, -1), 'south': (0, 1), 'east': (1, 0), 'west': (-1, 0)}


def floor_changes():
    xml = open(ITEMS_XML, encoding='latin-1').read()
    fc = {}
    for m in re.finditer(r'<item (?:id="(\d+)"|fromid="(\d+)" toid="(\d+)")[^>]*[^/]>((?:(?!<item ).)*?)</item>', xml, re.S):
        v = re.search(r'floorchange" value="(\w+)"', m.group(4))
        if v:
            a, b = int(m.group(1) or m.group(2)), int(m.group(1) or m.group(3))
            for i in range(a, b + 1):
                fc[i] = v.group(1)
    return fc


class Walker:
    def __init__(self, tiles, otb=None, surf=False):
        self.t = tiles
        self.otb = otb or pvmap.Otb(ITEMS_OTB)
        self.fc = floor_changes()
        self.surf = surf

    def changes(self, p):
        return {self.fc[i] for i in self.t.get(p, []) if i in self.fc}

    def dest(self, p):
        x, y, z = p
        c = self.changes(p)
        if 'down' in c:
            below = self.changes((x, y, z + 1))
            dx = (-1 if 'east' in below else 0) + (1 if 'west' in below else 0)
            dy = (1 if 'north' in below else 0) + (-1 if 'south' in below else 0)
            return (x + dx, y + dy, z + 1)
        for k, (dx, dy) in STEPS.items():
            if k in c:
                return (x + dx, y + dy, z - 1)
        return p

    def standable(self, p):
        ids = self.t.get(p)
        if not ids or any(self.otb.blocks(i) for i in ids):
            return False
        return self.surf or not any(i in WATER for i in ids)

    def reach(self, start, box=None):
        seen = {start}
        dq = deque([start])
        while dq:
            x, y, z = dq.popleft()
            for dx, dy in STEPS.values():
                q = self.dest((x + dx, y + dy, z))
                if q in seen or (box and not (box[0] <= q[0] <= box[2] and box[1] <= q[1] <= box[3])):
                    continue
                if self.standable(q):
                    seen.add(q)
                    dq.append(q)
        return seen


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument('start')
    ap.add_argument('--box', required=True)
    ap.add_argument('--to', nargs='*', default=[])
    ap.add_argument('--surf', action='store_true')
    ap.add_argument('--map', default=os.path.join(ROOT, 'mapper', 'map', 'dev.otbm'))
    args = ap.parse_args()
    box = tuple(int(v) for v in args.box.split(','))
    data = open(args.map, 'rb').read()
    tiles = {k: johto_edit.ids_of(v) for k, v in johto_edit.read_boxes(data, {'b': box})['b'].items()}
    w = Walker(tiles, surf=args.surf)
    seen = w.reach(tuple(int(v) for v in args.start.split(',')), box)
    print('%d tiles reached' % len(seen))
    for s in args.to:
        p = tuple(int(v) for v in s.split(','))
        near = min(seen, key=lambda q: (abs(q[0] - p[0]) + abs(q[1] - p[1]) + 9 * abs(q[2] - p[2])))
        print('%s %s' % (p, 'reached' if p in seen else 'NOT reached (closest %s)' % (near,)))


if __name__ == '__main__':
    main()
