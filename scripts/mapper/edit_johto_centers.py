#!/usr/bin/env python3
"""Gives Johto's cities the big Pokémon Center and a Mart lot of its own, on the dev map.

    scripts/mapper/edit_johto_centers.py [--map mapper/map/dev.otbm] [--out <same>] [--spawns <map-spawn.xml>]

The towns and remote spots (New Bark, Cherrygrove, Azalea, Mahogany, Route 32, Mt. Silver) keep the
small center. In each city of CITIES:
  center    Pewter's (the back room and the teleport machine to the trade center, Nurse Joy and
            Chansey where Pewter has them), on the ground the small center and the Mart stood on,
            its door on the town's main street by a 4-wide spur in that street's paving
  Mart      the city's own Mart moved, whole, to a lot elsewhere in town (at least 4 tiles from the
            center and 2 from other buildings, clear of their upper floors and roofs, few trees and no
            paving under it), its door joined to the town's roads by a 2-wide path
  the rest  the old buildings' ground goes back to grass, their signs, roofs (floor 6), protection zone
            and staff move with them, and the town's temple goes to the new center's door

Seeded, so the same map gives the same result; run it on a map without it (the dev map has it).
"""
import argparse
import os
import sys
from collections import deque

import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import autoborder  # noqa: E402
import johto_edit  # noqa: E402
import pvmap  # noqa: E402

ROOT = os.path.dirname(os.path.dirname(HERE))
DEV = os.path.join(ROOT, 'mapper', 'map')

SEED = 5
PEWTER = (3299, 289)          # Pewter's center, the city center copied
CW, CH = 15, 14
DOOR = (7, 8)                 # its door's columns, on its bottom row
SPUR = range(6, 10)           # the street spur's columns
NURSE = (7, 8)                # Pewter's nurse spawn, from the box's corner
MW = MH = 9                   # a Mart
MSPUR = range(3, 7)
CENTER_SIGN, MART_SIGN = 11887, 11888
MOVABLE = {7716, 7717, 7718}
ROADS = {'dirt', 'gray stone tiles', 'dark cobblestone'}
TUFT = {6216, 6217, 6218, 6219}
# name: (town id, small center's corner, Mart's corner)
CITIES = {'Violet': (52, (2508, 554), (2520, 553)), 'Goldenrod': (54, (2278, 718), (2289, 717)),
          'Ecruteak': (55, (2285, 399), (2296, 398)), 'Olivine': (56, (2106, 489), (2117, 488)),
          'Blackthorn': (59, (2718, 377), (2729, 376)), 'Cianwood': (57, (1897, 629), (1909, 628))}
READ = (45, 45, 55, 45)        # how far west, north, east and south of the old center the city is read


class Planner:
    def __init__(self, t):
        self.t = t
        self.B = autoborder.Brushes()

    def brush_of(self, k):
        ids = self.t.get(k)
        return self.B.by_item.get(ids[0]) if ids else None

    def is_tree(self, k):
        return any(2690 <= i <= 2790 for i in self.t.get(k, []))

    def decor(self, ids):
        B = self.B
        return [i for i in ids[1:] if i not in B.border_item_ids and i not in TUFT and B.by_item.get(i) is None and i < 10000]

    def make_busy(self, free_boxes, taken, grass_only=False):
        t, B = self.t, self.B

        def busy(xx, yy, margin=False):
            if in_any(taken, xx, yy):
                return True
            if in_any(free_boxes, xx, yy):
                return False
            ids = t.get((xx, yy, 7))
            if not ids:
                return True
            # a floor k up draws k tiles up-left, so a neighbour's upper floors and roof cover this tile
            if any(t.get((xx + k, yy + k, 7 - k)) for k in range(1, 5)):
                return True
            br = B.by_item.get(ids[0])
            if br is None or any(i >= 10000 and i not in B.border_item_ids and i not in (CENTER_SIGN, MART_SIGN) for i in ids[1:]):
                return True
            if margin:
                return False
            if any(i not in MOVABLE for i in self.decor(ids)) and not self.is_tree((xx, yy, 7)):
                return True
            return br.name in ('sea', 'walkable sea', 'mountain')

        def soft(xx, yy):
            if in_any(free_boxes, xx, yy):
                return False
            return grass_only and (self.brush_of((xx, yy, 7)) or B['grass']).name in ROADS
        busy.soft = soft
        return busy

    def fit(self, busy, w, h, spur, xs, ys, anchor, roads, gone=(), reach=3):
        """The best box (cost, x0, y0, y1, street) whose door spur meets a road row 2-3 tiles below it."""
        best = None
        for bx0 in xs:
            for by1 in ys:
                by0 = by1 - h + 1
                if any(busy(a, b) for a in range(bx0, bx0 + w) for b in range(by0, by1 + 1)):
                    continue
                trees = sum(self.is_tree((a, b, 7)) for a in range(bx0, bx0 + w) for b in range(by0, by1 + 1))
                if trees > 3:
                    continue
                soft = sum(busy.soft(a, b) for a in range(bx0, bx0 + w) for b in range(by0, by1 + 1))
                if soft > (10 if w == MW else 999):
                    continue
                if any(busy(a, b, True) for a in range(bx0 - 1, bx0 + w + 1) for b in range(by0 - 1, by1 + 1)):
                    continue
                for street in range(by1 + 2, by1 + reach + 1):
                    if any(self.brush_of((bx0 + c, street, 7)) not in roads or in_any(gone, bx0 + c, street) for c in spur):
                        continue
                    if any(busy(bx0 + c, b, True) or self.is_tree((bx0 + c, b, 7)) for c in spur for b in range(by1 + 1, street)):
                        continue
                    cost = abs(bx0 + w / 2 - anchor[0]) + abs(by1 - anchor[1]) + 3 * trees + (2 if w == MW else 0.2) * soft
                    if best is None or cost < best[0]:
                        best = (cost, bx0, by0, by1, street)
                    break
        return best

    def mart_lot(self, busy, center, gone, xs, ys, max_len=16):
        """The best Mart lot (cost, x0, y0, y1, path) whose door a short 2-wide path joins to a road."""
        t, B = self.t, self.B
        _, bx0, by0, by1, street = center
        door = (bx0 + 7.5, by1)
        roads = {self.brush_of((bx0 + 7, street, 7))}
        best = None
        for ax in xs:
            for ay1 in ys:
                ay0 = ay1 - MH + 1
                if any(busy(a, b) for a in range(ax, ax + MW) for b in range(ay0, ay1 + 1)):
                    continue
                if any(busy(a, b, True) for a in range(ax - 2, ax + MW + 2) for b in range(ay0 - 2, ay1 + 1)):
                    continue
                trees = sum(self.is_tree((a, b, 7)) for a in range(ax, ax + MW) for b in range(ay0, ay1 + 1))
                soft = sum(busy.soft(a, b) for a in range(ax, ax + MW) for b in range(ay0, ay1 + 1))
                if trees > 3 or soft > 10:
                    continue
                start = (ax + 4, ay1 + 1)

                def ok(p):
                    for q in (p, (p[0] + 1, p[1]), (p[0], p[1] + 1), (p[0] + 1, p[1] + 1)):
                        if busy(q[0], q[1], True) or self.is_tree(q + (7,)):
                            return False
                        br = self.brush_of(q + (7,))
                        if br is None or br.name in ('sea', 'walkable sea', 'mountain'):
                            return False
                        if ax - 1 <= q[0] <= ax + MW and ay0 - 1 <= q[1] <= ay1:
                            return False
                    return True

                if not ok(start):
                    continue
                prev = {start: None}
                dq = deque([start])
                end = None
                while dq:
                    p = dq.popleft()
                    n, q = 0, p
                    while prev[q] is not None:
                        q = prev[q]
                        n += 1
                    if n > max_len:
                        break
                    if all(self.brush_of((p[0] + d, p[1], 7)) in roads and not in_any(gone, p[0] + d, p[1]) for d in (0, 1)):
                        end = p
                        break
                    for dx, dy in ((0, 1), (1, 0), (-1, 0), (0, -1)):
                        np_ = (p[0] + dx, p[1] + dy)
                        if np_ not in prev and ok(np_):
                            prev[np_] = p
                            dq.append(np_)
                if not end:
                    continue
                route = []
                q = end
                while q is not None:
                    route.append(q)
                    q = prev[q]
                dist = abs(ax + 4.5 - door[0]) + abs(ay1 - door[1])
                cost = 3 * len(route) + 0.3 * dist + 3 * trees + 2 * soft
                if best is None or cost < best[0]:
                    best = (cost, ax, ay0, ay1, route[::-1])
        return best

    def plan(self, c_at, m_at, min_gap=4):
        (x, y), (mx, my) = c_at, m_at
        road = self.brush_of((x + 4, y + 10, 7))
        old_c, old_m = (x, y, x + 8, y + 9), (mx, my, mx + 8, my + 10)
        gone = [(x, y + 8, x + 8, y + 9), (mx, my + 9, mx + 8, my + 10)]
        mid = (min(x, mx) + max(x, mx) + 8 + 1) / 2
        c = self.fit(self.make_busy([old_c, old_m], [], True), CW, CH, SPUR, range(min(x, mx) - 8, max(x, mx) + 4),
                     range(y + 6, y + 9), (mid, y + 7), {road}, gone=gone)
        if not c:
            return road, None, None
        _, bx0, by0, by1, street = c
        g = min_gap
        taken = [(bx0 - g, by0 - g, bx0 + CW - 1 + g, street + g)]
        m = self.mart_lot(self.make_busy([old_m, old_c], taken, True), c, gone, range(x - 36, x + 42), range(y - 30, y + 36))
        return road, c, m


def in_any(boxes, xx, yy):
    return any(a0 <= xx <= a1 and b0 <= yy <= b1 for (a0, b0, a1, b1) in boxes)


def build(P, rng, c_at, m_at, road, c, m, pewter):
    """{(x, y, 7): [item ids]} of the city after the move, and {(x, y, 7): source (x, y, 7)} for the
    tiles that came with a building."""
    t, B = P.t, P.B
    (x, y), (mx, my) = c_at, m_at
    GRASS = B['grass']
    after = {k: list(v) for k, v in t.items()}
    brush, dirty, came = {}, set(), {}

    def pick(br):
        ids, w = zip(*([(i, n) for i, n in br.items if n > 0] or br.items))
        w = np.array(w, float)
        return int(rng.choice(ids, p=w / w.sum()))

    def clear(x0, y0, x1, y1, keep_road_rows_from, rd):
        for xx in range(x0, x1 + 1):
            for yy in range(y0, y1 + 1):
                if yy >= keep_road_rows_from and P.brush_of((xx, yy, 7)) is not rd:
                    continue
                brush[(xx, yy, 7)] = GRASS
                after[(xx, yy, 7)] = []
                dirty.add((xx, yy, 7))

    def paste(srcd, sx0, sy0, w, h, bx0, by0, door, spur, street):
        by1 = by0 + h - 1
        for xx in range(bx0, bx0 + w):
            for yy in range(by0, by1 + 1):
                d = P.decor(after.get((xx, yy, 7), []))
                up = (xx, by0 - 1, 7)
                if d and up in after and not P.decor(after[up]) and B.by_item.get(after[up][0]) is not None:
                    after[up] = after[up] + d
        for yy in range(by0, by1 + 1):
            for xx in range(bx0, bx0 + w):
                sk = (xx - bx0 + sx0, yy - by0 + sy0, 7)
                s = srcd.get(sk, [])
                k = (xx, yy, 7)
                dirty.discard(k)
                came[k] = sk
                if s and B.by_item.get(s[0]) is None:
                    after[k] = list(s)
                    brush[k] = None
                else:
                    br = brush.get(k, P.brush_of(k)) or GRASS
                    if yy == by1 and (xx - bx0) in door:
                        br = road
                    brush[k] = br
                    after[k] = [pick(br)] + [i for i in s[1:] if i >= 10000 and i not in TUFT]
                    dirty.add(k)
        for col in spur:
            for yy in range(by1 + 1, street):
                k = (bx0 + col, yy, 7)
                brush[k] = road
                after[k] = [pick(road)]
                dirty.add(k)

    clear(x, y, x + 8, y + 9, y + 8, road)
    msrc = {(xx, yy, 7): list(t[(xx, yy, 7)]) for xx in range(mx, mx + MW) for yy in range(my, my + MH) if (xx, yy, 7) in t}
    clear(mx, my, mx + 8, my + 10, my + 9, P.brush_of((mx + 4, my + 11, 7)))
    _, bx0, by0, by1, street = c
    paste(pewter, PEWTER[0], PEWTER[1], CW, CH, bx0, by0, DOOR, SPUR, street)
    _, ax0, ay0, ay1, route = m
    paste(msrc, mx, my, MW, MH, ax0, ay0, (), (), ay1 + 1)
    mroad = P.brush_of(route[-1] + (7,))
    route = route + [(ax0 + col, ay1 + 1) for col in MSPUR]
    for (px, py) in route:
        for d, e in ((0, 0), (1, 0), (0, 1), (1, 1)):
            k = (px + d, py + e, 7)
            if P.brush_of(k) not in {B[n] for n in ROADS} or k in brush:
                brush[k] = mroad
                after[k] = [pick(mroad)]
                dirty.add(k)

    sign_at = []

    def move_sign(sign, ox0, oy0, ox1, oy1, at):
        for xx in range(ox0 - 3, ox1 + 4):
            for yy in range(oy0 - 3, oy1 + 4):
                k = (xx, yy, 7)
                if sign in after.get(k, []):
                    after[k] = [i for i in after[k] if i != sign]
        after[at] = after.get(at, []) + [sign]
        sign_at.append(at)

    move_sign(CENTER_SIGN, x, y, x + 8, y + 8, (bx0 + 4, by1 + 1, 7))
    move_sign(MART_SIGN, mx, my, mx + 8, my + 9, (ax0 + 9, ay1 + 1, 7))

    def br_at(k):
        return brush[k] if k in brush else P.brush_of(k)
    ring = dirty | {(a + dx, b + dy, z) for (a, b, z) in dirty for dx in (-1, 0, 1) for dy in (-1, 0, 1)}
    for k in ring:
        center = br_at(k)
        if center is None:
            continue
        a, b, z = k
        nb = [br_at((a + dx, b + dy, z)) for dx, dy in autoborder.NEIGHBOURS]
        border = B.borders_for(center, nb)
        cur = after.get(k) or [pick(center)]
        g = cur[0] if B.by_item.get(cur[0]) is center else pick(center)
        keep = [i for i in cur[1:] if i not in B.border_item_ids and B.by_item.get(i) is None]
        if k in sign_at:
            keep = [i for i in keep if i not in TUFT]
        after[k] = [g] + border + keep
    return after, came


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument('--map', default=os.path.join(DEV, 'dev.otbm'))
    ap.add_argument('--out')
    ap.add_argument('--spawns')
    args = ap.parse_args()
    out = args.out or args.map
    spawns_in = os.path.join(os.path.dirname(args.map), 'map-spawn.xml')
    spawns_out = args.spawns or os.path.join(os.path.dirname(out), 'map-spawn.xml')

    data = open(args.map, 'rb').read()
    boxes = {'pewter': (PEWTER[0], PEWTER[1], PEWTER[0] + CW - 1, PEWTER[1] + CH - 1)}
    for name, (_, (x, y), _) in CITIES.items():
        boxes[name] = (x - READ[0], y - READ[1], x + READ[2], y + READ[3])
    raw = johto_edit.read_boxes(data, boxes)
    pewter_raw = raw['pewter']
    pewter = {k: johto_edit.ids_of(v) for k, v in pewter_raw.items() if k[2] == 7}
    rng = np.random.default_rng(SEED)

    new_tiles, remove, town_moves, staff, moved_npcs = {}, set(), {}, [], []
    for name, (town, c_at, m_at) in CITIES.items():
        base = raw[name]
        P = Planner({k: johto_edit.ids_of(v) for k, v in base.items() if k[2] >= 2})
        road, c, m = P.plan(c_at, m_at)
        if not c or not m:
            raise SystemExit('%s: no room for the center or the Mart' % name)
        after, came = build(P, rng, c_at, m_at, road, c, m, pewter)
        (x, y), (mx, my) = c_at, m_at
        _, bx0, by0, by1, street = c
        _, ax0, ay0, ay1, route = m
        old_c, old_m = (x, y, x + 8, y + 9), (mx, my, mx + 8, my + 10)
        edit = johto_edit.Edit(base)
        for k, ids in after.items():
            if k[2] != 7 or ids == johto_edit.ids_of(base.get(k)) and k not in came:
                continue
            sk = came.get(k)
            src = pewter_raw.get(sk) if sk and sk in pewter_raw else base.get(sk) if sk else None
            if src is not None:
                edit.set(k, ids, src=src, flags=src.flags)
            elif in_any([old_c, old_m], k[0], k[1]):
                edit.set(k, ids, flags=0)
            else:
                edit.set(k, ids)
        # the roofs (floor 6) go with their buildings
        roofs = {}
        for (px, py, pz), tile in pewter_raw.items():
            if pz == 6:
                roofs[(px - PEWTER[0] + bx0, py - PEWTER[1] + by0, 6)] = tile
        for (px, py, pz), tile in base.items():
            if pz == 6 and mx <= px <= mx + MW - 1 and my <= py <= my + MH - 1:
                roofs[(px - mx + ax0, py - my + ay0, 6)] = tile
        for (px, py, pz) in base:
            if pz == 6 and (in_any([old_c], px, py) or mx <= px <= mx + MW - 1 and my <= py <= my + MH - 1):
                edit.set((px, py, 6), [])
        for k, tile in roofs.items():
            if k in base and not (in_any([old_c], k[0], k[1]) or mx <= k[0] <= mx + MW - 1 and my <= k[1] <= my + MH - 1):
                raise SystemExit('%s: a roof would land on %s' % (name, k))
            edit.copy(k, tile)
        tiles, gone = edit.tiles()
        new_tiles.update(tiles)
        remove |= gone
        town_moves[town] = (bx0 + DOOR[0], by1 + 1, 7)
        staff.append(((bx0 + NURSE[0], by0 + NURSE[1], 7), [('npc', "Nurse Joy's Chansey", 0, -1), ('npc', 'Nurse Joy', 1, -1)]))
        moved_npcs.append((old_c, old_m, (mx, my), (ax0, ay0)))
        print('%-10s center %s door on %s, street row %d; Mart %s, path of %d to the road; temple %s'
              % (name, (bx0, by0), road.name, street, (ax0, ay0), len(route), town_moves[town]))

    cut = pvmap.write_map(data, out, new_tiles, remove, town_moves=town_moves)
    print('%s: %d tiles written, %d removed (%d replaced)' % (out, len(new_tiles), len(remove), cut))

    src = open(spawns_in, encoding='latin-1').read()
    clerks = []

    def drop(x, y, z, body):
        if z != 7:
            return False
        for old_c, old_m, (mx, my), (ax0, ay0) in moved_npcs:
            if in_any([old_c], x, y) and 'Nurse Joy' in body and '<monster' not in body:
                return True
            if in_any([old_m], x, y) and 'name="Mart"' in body and '<monster' not in body:
                clerks.append(((x - mx + ax0, y - my + ay0, 7), [('npc', 'Mart', 0, 0)]))
                return True
        return False

    text = johto_edit.edit_spawns(src, drop, [])
    if len(clerks) != len(CITIES):
        raise SystemExit('found %d Mart clerks for %d cities' % (len(clerks), len(CITIES)))
    text = johto_edit.edit_spawns(text, lambda *a: False, staff + clerks)
    with open(spawns_out, 'w', encoding='latin-1', newline='') as f:
        f.write(text)
    print('%s: %d nurses and %d Mart clerks moved' % (spawns_out, len(staff), len(clerks)))


if __name__ == '__main__':
    main()
