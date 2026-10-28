#!/usr/bin/env python3
"""Rebuilds Tohjo Falls on the dev map: the walk behind the falls, its lake cave, the bridge and the house.

    scripts/mapper/edit_tohjo_falls.py [--map mapper/map/dev.otbm] [--out <same>] [--spawns <map-spawn.xml>]

Outside, under the ridge where the Tohjo river comes out:
  falls     two 7-tile falls from a tarn on the mountain (floor 4), built column by column like Kanto's
            (spray on top, the face down through floors 5-7, foam a tile south) so Waterfall still works,
            with a 3-tile rock gap between them; a spring on the summit feeds the tarn by a stream
  ledge     the path along the cliff's foot behind both falls. Floors 5 and 6 over it hold only the
            falling water (no ground), so the client keeps drawing the curtain over a player there
  cuts      bends through a rock spur each side, open to the sky all along so nothing hides the way:
            west onto Route 27's meadow, east toward Route 26
  cave      the way down is behind the gap (an unseen stairs, 459, at the back of a notch); the cave
            below is build_johto's 'Tohjo Falls' (a lake cavern), which replaces the old one and its
            wild Pokémon, and whose falls climb to the radio room (TOHJO_LEDGE) as before
  trails    2 wide, from each end of the Route 26/27 road's bridge up the bank to the mouth on that side
  bridge    the road's bridge raised a floor: one straight deck (floor 6) with rails along its north and
            south rows, wooden steps up at each end of the two rows between them (the rails block)
  house     Pallet's cottage east of the bridge, as Route 27's house in the games, empty for now

Seeded, so the same map gives the same result; run it on a map without it (the dev map has it).
To redo it on a map that has it, build from an older map that doesn't with --from: everything in
the area on --map is then replaced by what that gives.
"""
import argparse
import os
import sys

import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import autoborder  # noqa: E402
import build_johto as BJ  # noqa: E402
import johto_edit  # noqa: E402
import pvmap  # noqa: E402

ROOT = os.path.dirname(os.path.dirname(HERE))
DEV = os.path.join(ROOT, 'mapper', 'map')
ITEMS = os.path.join(ROOT, 'core', 'server', 'data', 'items', 'items.otb')
DAT = os.path.join(ROOT, 'core', 'client-legacy', 'data', 'things', 'data.dat')

AREA = (2832, 588, 2984, 738)
HOUSE_SRC = (3302, 804, 3310, 813)     # Pallet's cottage, door at (3304, 813)
HX, HY = 2913, 679
SEED = 27
CAVE_SEED = 7

WF_FACE, WF_TOP, WF_FOOT = BJ.WATERFALL_UP, BJ.WATERFALL_TOP, BJ.WATERFALL_FOOT
BOULDERS = [3329, 3338]
LOOSE_ROCKS = [3607, 3608, 3615, 3616]
TREES = set(range(2690, 2791)) | {12295}
TUFTS = {6216, 6217, 6218, 6219}
PLANKS = (6210, 6211, 6212)
RAILS = range(3758, 3774)
STEP_E, STEP_W, STAIRS_DOWN_HIDDEN = 3679, 3681, 459

LEDGE = 667                     # the path behind the falls (floor 7)
Y = LEDGE + 1                   # the falls' row
TOP = 4                         # the tarn's floor
FALLS = [(2893, 2899), (2904, 2910)]
FX0, FX1 = FALLS[0][0], FALLS[-1][1]
LIP = Y
WEST, EAST = (2884, 2890), (2920, 2926)  # the old cave mouths' recesses, rock again
WT, ET = (2886, 2887), (2924, 2925)
HOLE = (2901, LEDGE - 2)
NOTCH_HOLE = [(x, LEDGE - 1) for x in range(2900, 2904)] + [(2901, LEDGE - 2), (2902, LEDGE - 2)]
SPAN = [(x, y) for x in range(2905, 2912) for y in range(707, 711)]
DECK = {707: 6211, 710: 6212}
WALK_ROWS = (708, 709)


def wobble(x, k):
    return int(round(np.sin(x * 0.9 + k) * 0.6 + np.sin(x * 0.37 + 2 * k) * 0.7))


def design(tiles, house_src, thing_attrs):
    """{(x, y, z): [item ids]} for every tile that changes outside, and the house's tiles."""
    rng = np.random.default_rng(SEED)
    B = autoborder.Brushes()
    MOUNTAIN, TOPG, SEA, SHALLOW = B['mountain'], B['mountain top ground'], B['sea'], B['walkable sea']
    GRASS, DIRT = B['grass'], B['dirt']

    def pick(br):
        ids, w = zip(*([(i, c) for i, c in br.items if c > 0] or br.items))
        w = np.array(w, float)
        return int(rng.choice(ids, p=w / w.sum()))

    brush = {k: B.by_item.get(ids[0]) for k, ids in tiles.items() if ids}
    dirty = set()

    def setb(x, y, z, br):
        brush[(x, y, z)] = br
        dirty.add((x, y, z))

    def unset(k):
        brush[k] = None
        dirty.add(k)

    def top_floor(x, y):
        for z in range(0, 8):
            v = tiles.get((x, y, z))
            if v and B.by_item.get(v[0]) is not None:
                return z
        return 8

    def raise_to(x, y, z, br):
        setb(x, y, z, br)
        for zz in range(z + 1, 8):
            setb(x, y, zz, MOUNTAIN)

    # the tarn on floor 4, on a shelf that runs into the stone terrace east of it
    cx = (FX0 + FX1) / 2
    half = {652: 4.5, 653: 6.5, 654: 8, 655: 9.5, 656: 10.5, 657: 11.2, 658: 11.7, 659: 12, 660: 12, 661: 11.8,
            662: 11.4, 663: 11, 664: 10.6, 665: 10.2, 666: 9.8, 667: 9.4, 668: 9}
    lake = {(x, y) for y, h in half.items() for x in range(FX0 - 12, FX1 + 13) if abs(x - cx) <= h}
    shelf = set()
    for (x, y) in lake:
        for dx in range(-4, 5):
            for dy in range(-4, 5):
                if dx * dx + dy * dy <= 13 and y + dy <= LIP:
                    shelf.add((x + dx, y + dy))
    shelf = {(x, y) for (x, y) in shelf if y < LIP - 2 or FX0 - 3 <= x <= FX1 + 3}
    for (x, y) in shelf:
        near = min(abs(x - lx) + abs(y - ly) for (lx, ly) in lake if abs(lx - x) < 4 and abs(ly - y) < 4) \
            if (x, y) not in lake else 0
        if (x, y) in lake:
            setb(x, y, TOP, SEA)
        elif near <= 2 and y < LIP - 1:
            setb(x, y, TOP, GRASS)
        else:
            setb(x, y, TOP, TOPG)
        for z in range(TOP + 1, 8):
            setb(x, y, z, MOUNTAIN)
    # one-floor steps down from the shelf wherever it would drop two floors at once
    inner = shelf
    for z in (TOP + 1, TOP + 2):
        ring = set()
        for (x, y) in inner:
            for dx in range(-2, 3):
                for dy in range(-2, 3):
                    p = (x + dx, y + dy)
                    if p not in inner and dx * dx + dy * dy <= 5 and p[1] <= LEDGE - 3:
                        ring.add(p)
        ring = {p for p in ring if top_floor(*p) > z}
        for (x, y) in ring:
            setb(x, y, z, GRASS if brush.get((x, y, z + 1)) is GRASS or top_floor(x, y) <= 7 else TOPG)
            for zz in range(z + 1, 8):
                setb(x, y, zz, MOUNTAIN)
        inner = inner | ring
    # north-east: the strip between the shelf and the stone terrace lifted, with a step down below it
    ne = [(x, y) for x in range(2913, 2933) for y in range(652, 661) if top_floor(x, y) == 5 and brush.get((x, y, TOP)) is None]
    for (x, y) in ne:
        raise_to(x, y, TOP, TOPG)
    for (x, y) in ne:
        for dy in (1, 2):
            p = (x, y + dy)
            if p[1] <= LEDGE - 5 and top_floor(*p) > 5 and brush.get(p + (TOP,)) is None and brush.get(p + (5,)) in (None, MOUNTAIN):
                if brush.get(p + (5,)) is None:
                    raise_to(p[0], p[1], 5, TOPG)
    # the spring on the summit to the west, a short fall off it, and the stream across the terrace
    spring = [(x, y) for x in range(2875, 2881) for y in range(639, 644) if (x - 2877.5) ** 2 / 9 + (y - 641.3) ** 2 / 4 <= 1]
    for (x, y) in spring:
        setb(x, y, 3, SEA)
    cascade = [(2877, 643), (2878, 643)]
    pts = [(2877, 644), (2879, 646), (2883, 647), (2887, 649), (2890, 651), (2893, 653)]
    stream = set()
    for (ax, ay), (bx, by) in zip(pts, pts[1:]):
        n = max(abs(bx - ax), abs(by - ay))
        for i in range(n + 1):
            sx, sy = round(ax + (bx - ax) * i / n), round(ay + (by - ay) * i / n)
            stream |= {(sx, sy), (sx + 1, sy)}
    for (x, y) in stream:
        for dx in range(-2, 3):
            for dy in range(-2, 3):
                p = (x + dx, y + dy)
                if top_floor(*p) > TOP and brush.get(p + (TOP,)) is None:
                    raise_to(p[0], p[1], TOP, GRASS)
    for (x, y) in stream:
        raise_to(x, y, TOP, SEA)
    for (x, y) in cascade:
        setb(x, y, TOP, MOUNTAIN)
    for x in range(FX0 - 3, FX1 + 4):         # nothing south of the lip up there, so the falls show
        for y in range(LIP + 1, LIP + 4):
            unset((x, y, TOP))
    for x in range(FALLS[0][1] + 1, FALLS[1][0]):
        for y in (LIP, LIP - 1):
            setb(x, y, TOP, TOPG)

    # floor 7: the ledge along the mountain's foot; behind the falls one tile, rock behind it
    for lo, hi in (WEST, EAST):
        for x in range(lo, hi + 1):
            for y in range(LEDGE - 1, 671):
                setb(x, y, 7, MOUNTAIN)
    for x in range(WT[0], ET[1] + 1):
        for y in (LEDGE - 1, LEDGE):
            if y == LEDGE - 1 and (FX0 - 3 <= x <= FX1 + 1 or x < WT[0] + 2 or x > ET[1] - 2):
                continue
            setb(x, y, 7, TOPG)
    for x in range(FX0 - 3, FX1 + 3):
        setb(x, Y, 7, MOUNTAIN)
    for x in range(FX0 - 3, FX1 + 3):         # the plunge pool
        for y in range(Y + 1, Y + 4):
            if y < Y + 3 or FX0 <= x <= FX1:
                setb(x, y, 7, SEA)
    for z in (5, 6):                          # open sky over the falls
        for y in range(LEDGE - 1, LEDGE + 3):
            for x in range(WEST[0] - 1, EAST[1] + 2):
                if brush.get((x, y, z)) is not None or (x, y, z) in tiles:
                    unset((x, y, z))

    # the cuts: short bends through rounded spurs, open to the sky end to end; the rock
    # fingers the old ravines left south of the cliff go back to grass
    def west_edge(y):
        return 2875 + max(0, min(5, y - 661)) + (wobble(y, 4) if y < 665 else 0)

    spur_w = {(x, y) for y in range(652, 671) for x in range(west_edge(y), FX0 - 3)
              if y < 670 + min(0, wobble(x, 2)) and not (x >= 2886 and y < 665)}
    terrace_w = {(x, y) for y in range(653, 665) for x in range(west_edge(y) + 3 + max(0, wobble(y, 5)), 2887)
                 if y <= 662 + wobble(x, 6)}
    spur_e = {(x, y) for x in range(FX1 + 3, 2947)
              for y in range(661, (670 if x <= 2931 else 669) + max(-1, min(1, wobble(x, 3))))}
    spur_e |= {(x, 670) for x in range(2922, 2935)} | {(x, y) for x in range(2923, 2933) for y in (671, 672)} - {(2923, 672), (2932, 672)}
    spur_w |= {(x, y) for x in range(2876, 2880) for y in range(664, 672)} - {(2876, 664), (2876, 671)}
    mouth_w = {(x, y) for x in range(2876, 2882) for y in range(LEDGE - 1, LEDGE + 3)}
    mouth_e = {(x, y) for x in range(2926, 2930) for y in range(LEDGE + 3, LEDGE + 6)}
    tun_w = {(x, LEDGE) for x in range(2882, FX0 - 3)} | {(x, LEDGE - 1) for x in range(2884, FX0 - 3)} | \
        {(x, LEDGE + 1) for x in range(2882, 2885)}
    tun_e = {(x, LEDGE) for x in range(FX1 + 3, 2927)} | {(x, LEDGE - 1) for x in range(FX1 + 3, 2925)} | \
        {(x, LEDGE + 1) for x in range(2925, 2929)} | {(2927, LEDGE + 2), (2928, LEDGE + 2)}
    spur_w -= mouth_w
    spur_e -= mouth_e
    tunnels = tun_w | tun_e | mouth_w | mouth_e

    def free_above(x, y, z):
        return top_floor(x, y) >= z and all(brush.get((x, y, k)) is None for k in range(TOP, z))

    for (x, y) in spur_w | spur_e:
        if free_above(x, y, 6):
            setb(x, y, 6, TOPG)
            setb(x, y, 7, MOUNTAIN)
    for (x, y) in terrace_w:
        if free_above(x, y, 5):
            setb(x, y, 5, GRASS)
            setb(x, y, 6, MOUNTAIN)
            setb(x, y, 7, MOUNTAIN)
    for (x, y) in tun_w | tun_e:
        setb(x, y, 7, TOPG)
    # a floor-6 tile draws over the floor-7 tile up-left of it too, so a cut is open over both
    cuts = {(x + d, y + d) for (x, y) in tunnels for d in (0, 1)}
    for (x, y) in cuts:
        unset((x, y, 6))
    for (x, y) in mouth_w | mouth_e:
        unset((x, y, 6))
        setb(x, y, 7, TOPG)
    for x in list(range(2864, 2894)) + list(range(FX1 + 1, 2940)):
        for y in range(661, 690):
            if (x, y) in spur_w | spur_e | tunnels or (FX0 - 3 <= x <= FX1 + 2 and y <= LEDGE + 4):
                continue
            if brush.get((x, y, 7)) in (MOUNTAIN, TOPG, DIRT) and brush.get((x, y, 6)) is None and \
                    not (2894 <= x <= 2912 and y <= 678) and (y >= 670 or x < 2878):
                setb(x, y, 7, GRASS)

    trail = set()

    def path(points):
        for (ax, ay), (bx, by) in zip(points, points[1:]):
            n = max(abs(bx - ax), abs(by - ay))
            for i in range(n + 1):
                px, py = round(ax + (bx - ax) * i / n), round(ay + (by - ay) * i / n)
                for dx in range(2):
                    for dy in range(2):
                        p = (px + dx, py + dy, 7)
                        if brush.get(p) in (GRASS, DIRT, B['lawn'], TOPG):
                            setb(*p, DIRT)
                            trail.add(p)

    path([(2899, 708), (2899, 702), (2898, 697), (2895, 694), (2891, 692), (2889, 688), (2884, 685), (2881, 680), (2878, 677),
          (2876, 673), (2874, 669), (2876, LEDGE), (2884, LEDGE)])
    path([(2914, 707), (2914, 702), (2914, 698), (2915, 695), (2916, 692), (2920, 690), (2922, 689), (2923, 685), (2926, 681), (2927, 677),
          (2927, 673), (2927, LEDGE + 2)])
    for (x, y) in NOTCH_HOLE:
        setb(x, y, 7, TOPG)
    # the old road's ends left under the rock beside the trails go back to grass
    for x in range(2864, 2940):
        for y in range(661, 705):
            p = (x, y, 7)
            if brush.get(p) is DIRT and p not in trail and \
                    any(brush.get(k) is not None or tiles.get(k) for k in ((x, y, 6), (x + 1, y + 1, 6))):
                setb(*p, GRASS)
    # under the raised deck the river runs on, shallow so nothing is cut off where the bridge stood
    for x in range(2905, 2912):
        for y in range(703, 715):
            ids = tiles.get((x, y, 7)) or []
            if (x, y) in SPAN or (ids and (ids[0] == 6210 or B.by_item.get(ids[0]) is SHALLOW)):
                setb(x, y, 7, SHALLOW)
    hdx, hdy = HX - HOUSE_SRC[0], HY - HOUSE_SRC[1]
    house = {(x + hdx, y + hdy, z): ids for (x, y, z), ids in house_src.items()
             if HOUSE_SRC[0] <= x <= HOUSE_SRC[2] and HOUSE_SRC[1] <= y <= HOUSE_SRC[3] and 4 <= z <= 7 and ids}
    for (x, y, z) in house:
        if z == 7:
            setb(x, y, 7, GRASS)
    door_front = (3304 + hdx, 814 + hdy)
    path([door_front, (door_front[0] + 6, door_front[1] + 1)])

    # tiles from the brush maps
    new = {}
    ring = dirty | {(x + dx, y + dy, z) for (x, y, z) in dirty for dx in (-1, 0, 1) for dy in (-1, 0, 1)}
    for (x, y, z) in sorted(ring):
        center = brush.get((x, y, z))
        old = tiles.get((x, y, z), [])
        if center is None:
            if (x, y, z) in dirty:
                new[(x, y, z)] = []
                if z < 7:
                    nb = [MOUNTAIN if b_ in (MOUNTAIN, TOPG) else None
                          for b_ in (brush.get((x + dx, y + dy, z)) for dx, dy in autoborder.NEIGHBOURS)]
                    new[(x, y, z)] = B.borders_for(GRASS, nb, optional=True)
            continue
        nb = [brush.get((x + dx, y + dy, z)) for dx, dy in autoborder.NEIGHBOURS]
        if z < 7 and center is not MOUNTAIN and center is not SEA:
            nb = [b or MOUNTAIN for b in nb]
        border = B.borders_for(center, nb, optional=z < 7 and center is not SEA)
        if (x, y, z) in dirty:
            ground = pick(center)
            keep = [i for i in old[1:] if i not in B.border_item_ids and B.by_item.get(i) is None
                    and i not in PLANKS and i not in RAILS]
            if center is not (B.by_item.get(old[0]) if old else None):
                keep = [i for i in keep if i not in TUFTS]
            if (x, y, z) in trail:
                keep = [i for i in keep if i not in TREES]
            if z == 7 and (x, y) in tunnels:
                keep = []
            if center in (MOUNTAIN, TOPG, SEA):
                keep = [i for i in keep if i not in TREES]
        else:
            ground = old[0] if old else pick(center)
            keep = [i for i in old[1:] if i not in B.border_item_ids]
        new[(x, y, z)] = [ground] + border + keep
    for (x, y) in cuts:
        new[(x, y, 6)] = []
    for (x, y) in cascade:
        new[(x, y, 3)].append(WF_TOP)
        new[(x, y, TOP)].append(WF_FACE)
        new[(x, y + 1, TOP)].append(WF_FOOT)
    # the falls, column by column
    for a, b in FALLS:
        for x in range(a, b + 1):
            new.setdefault((x, Y, TOP), []).append(WF_TOP)
            for z in range(TOP + 1, 8):
                new.setdefault((x, Y, z), []).append(WF_FACE)
            new[(x, Y + 1, 7)] = [i for i in new[(x, Y + 1, 7)] if i not in B.border_item_ids] + [WF_FOOT]
            if rng.random() < 0.7:
                new[(x, Y + 2, 7)].append(WF_FOOT)
    for x, y in ((FX0 - 3, Y + 2), (FX0 + 2, Y + 3), (FX1 - 1, Y + 3), (FX1 + 2, Y + 1), ((FX0 + FX1) // 2, Y + 3)):
        if (x, y, 7) in new and brush.get((x, y, 7)) is SEA:
            new[(x, y, 7)].append(int(rng.choice(LOOSE_ROCKS)))
    for p in [(2896, 658, TOP), (2908, 661, TOP)]:
        if p in new and B.by_item.get(new[p][0]) is SEA:
            new[p].append(int(rng.choice(BOULDERS)))
    # the bridge: the deck on floor 6, a step up onto it at each end of the two rows it is walked on
    for (x, y) in SPAN:
        rails = {707: [[3758, 3773], [3769]], 710: [[3761, 3772], [3768]]}.get(y)
        new[(x, y, 6)] = [DECK.get(y, 6210)] + (rails[x % 2] if rails else [])
    for y in WALK_ROWS:
        new[(2904, y, 7)] = (new.get((2904, y, 7)) or tiles[(2904, y, 7)])[:1] + [STEP_E]
        new[(2912, y, 7)] = (new.get((2912, y, 7)) or tiles[(2912, y, 7)])[:1] + [STEP_W]
        new[(2904, y, 6)] = [STAIRS_DOWN_HIDDEN]
        new[(2912, y, 6)] = [6210, STAIRS_DOWN_HIDDEN]   # closes the gap the floor's offset leaves
    for x in range(2900, 2918):                # nothing blocking on the road where it meets the steps
        for y in WALK_ROWS:
            k = (x, y, 7)
            if k in tiles and 3607 in (new.get(k) or tiles[k]):
                new[k] = [i for i in (new.get(k) or tiles[k]) if i != 3607]
    for y in (707, 710):
        new[(2912, y, 6)] = [DECK[y]] + ([3758, 3773] if y == 707 else [3761, 3772])
    for k, ids in house.items():
        new[k] = list(ids)
    for x in range(HX - 2, HX + 11):
        for y in range(HY - 2, HY + 12):
            k = (x, y, 7)
            if k not in house and (new.get(k) or tiles.get(k)):
                new[k] = [i for i in (new.get(k) or tiles.get(k)) if i not in TREES]
    new[HOLE + (7,)] = new[HOLE + (7,)][:1] + [STAIRS_DOWN_HIDDEN]

    # boulder faces left on groundless upper tiles would hide the curtain from the ledge: drop them
    after = dict(tiles)
    after.update(new)
    prio = {0: 0, 1: 1, 2: 2, 3: 3}

    def limits_view(items, free_view):
        for i in sorted(items, key=lambda i: min([p for a, p in prio.items() if a in thing_attrs(i)] or [9])):
            a = thing_attrs(i)
            if not any(k in a for k in (0, 1, 2, 3)):
                break
            if 23 not in a and (0 in a or (2 in a if free_view else (2 in a and 14 in a))):
                return True
        return False

    walk = [(x, y) for x in range(FX0 - 3, FX1 + 1) for y in (LEDGE - 1, LEDGE) if brush.get((x, y, 7)) is TOPG]
    for _ in range(40):
        changed = False
        for (x, y) in walk:
            for ix in (-1, 0, 1):
                for iy in (-1, 0, 1):
                    pos = (x + ix, y + iy, 7)
                    for k in range(1, 3):
                        for p in ((pos[0], pos[1], 7 - k), (pos[0] + k, pos[1] + k, 7 - k)):
                            items = after.get(p, [])
                            if items and brush.get(p) is None and limits_view(items, False) | limits_view(items, True):
                                after[p] = [i for i in items if not limits_view([i], False) and not limits_view([i], True)]
                                changed = True
        if not changed:
            break
    for k in list(new):
        new[k] = after[k]
    return new, set(house), (hdx, hdy)


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument('--map', default=os.path.join(DEV, 'dev.otbm'))
    ap.add_argument('--from', dest='source', help='build from this map, without the falls, and write the area onto --map')
    ap.add_argument('--out')
    ap.add_argument('--spawns')
    args = ap.parse_args()
    out = args.out or args.map
    spawns_in = os.path.join(os.path.dirname(args.map), 'map-spawn.xml')
    spawns_out = args.spawns or os.path.join(os.path.dirname(out), 'map-spawn.xml')

    data = open(args.map, 'rb').read()
    raw = johto_edit.read_boxes(open(args.source, 'rb').read() if args.source else data, {'area': AREA, 'house': HOUSE_SRC})
    base = raw['area']
    tiles = {k: johto_edit.ids_of(t) for k, t in base.items()}
    house_raw = raw['house']
    otb, dat = pvmap.Otb(ITEMS), pvmap.Dat(DAT)

    def thing_attrs(i):
        th = dat.things.get(otb.client_id(i))
        return th[0] if th else {}

    new, house, (hdx, hdy) = design(tiles, {k: johto_edit.ids_of(t) for k, t in house_raw.items()}, thing_attrs)
    edit = johto_edit.Edit(base)
    for k, ids in new.items():
        edit.set(k, ids)
    for (x, y, z), t in house_raw.items():
        if (x + hdx, y + hdy, z) in house:
            edit.copy((x + hdx, y + hdy, z), t)

    # the cave: the old one's tiles go, the new one is built in their place
    cave = next(c for c in BJ.CAVES if c['name'] == 'Tohjo Falls')
    cz = cave.get('z', 8)
    cx0, cy0, cx1, cy1 = cave['box']
    old_box = (cx0 - 8, cy0 - 8, cx1 + 8, cy1 + 8)

    def in_old(x, y):
        return old_box[0] <= x <= old_box[2] and old_box[1] <= y <= old_box[3]

    for (x, y, z) in base:
        if z == cz and in_old(x, y):
            edit.set((x, y, z), [])
    bx0, by0, bx1, by1 = BJ.BOX
    cave_tiles, cave_spawns = BJ.build_cave(cave, autoborder.Brushes(), np.zeros((by1 - by0 + 1, bx1 - bx0 + 1), bool),
                                            np.random.default_rng(CAVE_SEED))
    for k, t in cave_tiles.items():
        edit.set(k, johto_edit.ids_of(t), src=t, flags=0)

    new_tiles, remove = edit.tiles()
    if args.source:
        built = {k: t for k, t in base.items() if k not in remove}
        built.update(new_tiles)
        now = johto_edit.read_boxes(data, {'area': AREA})['area']
        new_tiles, remove = built, set(now) - set(built)
    cut = pvmap.write_map(data, out, new_tiles, remove)
    print('%s: %d tiles written, %d removed (%d replaced)' % (out, len(new_tiles), len(remove), cut))

    src = open(spawns_in, encoding='latin-1').read()
    dropped = []

    def drop(x, y, z, body):
        if z == cz and in_old(x, y):
            dropped.append((x, y))
            return True
        return False

    add = [((x, y, z), [('monster', n, 0, 0)]) for n, x, y, z in cave_spawns]
    with open(spawns_out, 'w', encoding='latin-1', newline='') as f:
        f.write(johto_edit.edit_spawns(src, drop, add))
    print('%s: %d old cave spawns out, %d in' % (spawns_out, len(dropped), len(add)))


if __name__ == '__main__':
    main()
