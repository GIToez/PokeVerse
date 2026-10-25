#!/usr/bin/env python3
"""Dresses Hoenn's bare grass the way its games' routes look, on top of the terrain as it is.

    scripts/mapper/build_hoenn_deco.py [--map core/server/data/world/map.otbm] [--out <same>]

Only grass tiles holding nothing but their ground are touched, and only on the topmost floor seen
at that spot, in Hoenn's routes, their Around/Outskirts filler and its outdoor landmarks
(areas_hoenn.lua), never in towns, houses, protection zones, under a floor above, on a wild
Pokémon's or NPC's tile. Paths, cliffs, water and
heights stay as they are.

  plains   grass tufts, groves of round trees, bushes, ferns, flowers, stones, logs (wild_deco at
           PLAIN_KEEP of its trees and bushes, tufts on PLAIN_TUFT of the rest), and patches of
           tall grass (jungle grass) away from the paths for the hunting grounds
  woods    where the map already has trees thick enough (WOODS within WOODS_REACH tiles), the
           forest's canopy, undergrowth and ferns, with its glades

Nothing that blocks splits a floor's walkable ground: where it would, the trees and bushes either
side of the cut are left out until every part that was joined still is. Seeded, so the same map
gives the same result; run it on a map without it (after publishing Johto, which starts from the
backup, run it again).
"""
import argparse
import os
import re
import struct
import sys

import numpy as np
from scipy import ndimage

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import autoborder  # noqa: E402
import build_johto as B  # noqa: E402
import pvmap  # noqa: E402

ROOT = os.path.dirname(os.path.dirname(HERE))
WORLD = os.path.join(ROOT, 'core', 'server', 'data', 'world')
AREAS = os.path.join(ROOT, 'core', 'client-redemption', 'pokeverse-modern', 'modules', 'game_environment',
                     'areas_hoenn.lua')
ITEMS = os.path.join(ROOT, 'core', 'server', 'data', 'items', 'items.otb')

HOENN = (48, 773, 2224, 2304)
FLOORS = range(0, 8)
SEED = 211
OUTDOORS = re.compile(r'^(Route \d+|Around |Outskirts of )')
LANDMARKS = {'Petalburg Woods', 'Meteor Falls', 'Mt. Chimney', 'Jagged Pass', 'Route 111 Desert', 'Mt. Pyre'}
FILLER_ROCK = 919  # the mountain under a plateau, never seen from above
TALL_GRASS = 3263
DEBRIS = 6481
PLAIN_KEEP = 0.6
PLAIN_TUFT = 0.24
FOREST_TUFT = 0.38
TALL_SHARE = 0.22  # of the open grass, before patches too small or too near a path are dropped
TALL_SMALLEST = 14
WOODS, WOODS_REACH = 0.10, 9
TREES = {i for i, _ in B.BROADLEAF + B.CONIFERS} | {2767, 2768}


def read_hoenn(data, box):
    """{(x, y, z): (house_id, flags, [item ids])} for Hoenn's tiles on FLOORS."""
    x0, y0, x1, y1 = box
    tiles = {}
    area = cur = None
    for ev, t, depth, a, b, _ in pvmap.walk(data):
        if ev != 'open':
            if t in (pvmap.TILE, pvmap.HOUSETILE):
                cur = None
            continue
        if t == pvmap.TILE_AREA:
            area = struct.unpack_from('<HHB', pvmap.unescape(data[a:b]), 0)
        elif t in (pvmap.TILE, pvmap.HOUSETILE):
            p = pvmap.unescape(data[a:b])
            x, y, z = area[0] + p[0], area[1] + p[1], area[2]
            if x0 <= x <= x1 and y0 <= y <= y1 and z in FLOORS:
                _, _, house, flags, item = pvmap.parse_tile_props(p, t == pvmap.HOUSETILE)
                cur = [] if item is None else [item]
                tiles[(x, y, z)] = (house, flags, cur)
            else:
                cur = None
        elif t == pvmap.ITEM and cur is not None and depth == 4:
            cur.append(struct.unpack_from('<H', pvmap.unescape(data[a:a + 4]), 0)[0])
    return tiles


def outdoor_mask(box):
    """Per (y, x) of the box: inside one of areas_hoenn's routes, fillers or outdoor landmarks (the
    first area containing a tile names it, as in the client)."""
    x0, y0, x1, y1 = box
    taken = np.zeros((y1 - y0 + 1, x1 - x0 + 1), bool)
    ok = np.zeros_like(taken)
    rect = re.compile(r'\{ (\d+), (\d+), (\d+), (\d+), (\d+), (\d+), "([^"]+)"')
    for m in rect.finditer(open(AREAS).read()):
        ax0, ay0, az0, ax1, ay1, az1 = map(int, m.groups()[:6])
        if not az0 <= 7 <= az1:
            continue
        sl = (slice(max(ay0, y0) - y0, min(ay1, y1) - y0 + 1), slice(max(ax0, x0) - x0, min(ax1, x1) - x0 + 1))
        name = m.group(7)
        fresh = ~taken[sl]
        ok[sl] |= fresh & bool(OUTDOORS.match(name) or name in LANDMARKS)
        taken[sl] = True
    return ok


def creature_spots(path):
    """(x, y, z) of every wild Pokémon and NPC in a spawn file, and every spawn's centre."""
    spots = set()
    spawn = re.compile(r'<spawn centerx="(\d+)" centery="(\d+)" centerz="(\d+)"')
    one = re.compile(r'<(?:monster|npc) name="[^"]*" x="(-?\d+)" y="(-?\d+)" z="(\d+)"')
    cx = cy = 0
    for line in open(path, encoding='latin-1'):
        m = spawn.search(line)
        if m:
            cx, cy = int(m.group(1)), int(m.group(2))
            spots.add((cx, cy, int(m.group(3))))
            continue
        m = one.search(line)
        if m:
            spots.add((cx + int(m.group(1)), cy + int(m.group(2)), int(m.group(3))))
    return spots


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--map', default=os.path.join(WORLD, 'map.otbm'))
    ap.add_argument('--spawns', default=os.path.join(WORLD, 'map-spawn.xml'))
    ap.add_argument('--out', default=None)
    args = ap.parse_args()
    out = args.out or args.map
    data = open(args.map, 'rb').read()
    otb = pvmap.Otb(ITEMS)
    brushes = autoborder.Brushes()
    grass = brushes['grass']
    tiles = read_hoenn(data, HOENN)
    creatures = creature_spots(args.spawns)
    print('Hoenn: %d tiles' % len(tiles))

    box = HOENN
    f = B.Field(SEED, box)
    H, W = f.h, f.w
    outdoors = outdoor_mask(box)

    # The tile seen from above at each spot (floor z is drawn 7 - z tiles up and left).
    top = {}
    for (x, y, z), (_, _, ids) in tiles.items():
        if not ids or ids[0] == FILLER_ROCK:
            continue
        sx, sy = x - (7 - z), y - (7 - z)
        if box[0] <= sx <= box[2] and box[1] <= sy <= box[3] and ((sx, sy) not in top or z < top[(sx, sy)][2]):
            top[(sx, sy)] = (x, y, z)
    land = np.zeros((H, W), bool)
    road = np.zeros((H, W), bool)
    treed = np.zeros((H, W), bool)
    bare = np.zeros((H, W), bool)
    for (sx, sy), (x, y, z) in top.items():
        iy, ix = sy - box[1], sx - box[0]
        house, flags, ids = tiles[(x, y, z)]
        land[iy, ix] = True
        if brushes.by_item.get(ids[0]) is not grass:
            road[iy, ix] = True
            continue
        treed[iy, ix] = any(i in TREES for i in ids[1:])
        bare[iy, ix] = (len(ids) == 1 and not house and not flags and outdoors[y - box[1], x - box[0]]
                        and (x, y, z - 1) not in tiles and (x, y, z) not in creatures)
    near_creature = np.zeros((H, W), bool)
    for (x, y, z) in creatures:
        if (x, y, z) in tiles:
            sx, sy = x - (7 - z), y - (7 - z)
            if box[0] <= sx <= box[2] and box[1] <= sy <= box[3]:
                near_creature[sy - box[1], sx - box[0]] = True

    road_d = B.distance(~road)
    woods = B.soften(B.local_mean(treed.astype(float), land, WOODS_REACH) > WOODS, 3)
    canopy, glade = f.noise(14), f.noise(12)
    groves = f.noise(16) + 0.15 * np.clip((road_d - 12) / 12.0, 0, 1)
    tufty, flowery = f.noise(8), f.noise(10)
    tall = f.noise(11) + 0.3 * f.noise(4)
    inner = bare & (B.distance(bare) > 1) & (road_d > 2.5) & ~woods
    tall_mask = np.zeros((H, W), bool)
    if inner.any():
        tall_mask = B.keep_parts((tall > np.quantile(tall[inner], 1 - TALL_SHARE)) & inner, TALL_SMALLEST)
        tall_mask = B.keep_parts(B.soften(tall_mask, 1.5) & bare & (road_d > 2.5) & ~woods, TALL_SMALLEST)
    near_tall = B.grow(tall_mask, 1) & ~tall_mask
    print('bare grass %d, woods %d, tall grass %d' % (bare.sum(), (bare & woods).sum(), tall_mask.sum()))

    rng = np.random.default_rng(SEED)
    new_ground = {}
    new_deco = {}
    for iy, ix in zip(*np.nonzero(bare)):
        pos = top[(ix + box[0], iy + box[1])]
        if tall_mask[iy, ix]:
            new_ground[pos] = TALL_GRASS
            continue
        wd = bool(woods[iy, ix])
        r = rng.random()
        deco = [] if near_tall[iy, ix] else B.wild_deco(rng, r, wd, road_d[iy, ix], canopy[iy, ix], -1.0,
                                                        glade[iy, ix], groves[iy, ix], tufty[iy, ix], flowery[iy, ix])
        if deco and not wd and rng.random() > PLAIN_KEEP:
            deco = []
        if deco and near_creature[iy, ix] and any(otb.blocks(i) for i in deco):
            deco = []
        if not deco:
            r = rng.random()
            if r < (FOREST_TUFT if wd else PLAIN_TUFT):
                deco = [B.pick(rng, B.TUFTS)]
            elif r < (FOREST_TUFT if wd else PLAIN_TUFT) + 0.012:
                deco = [DEBRIS]
        if deco:
            new_deco[pos] = deco

    # Keep every floor's walkable ground in one piece where it was.
    blockers = {p for p, d in new_deco.items() if any(otb.blocks(i) for i in d)}
    dropped = 0
    for z in FLOORS:
        walk = np.zeros((H, W), bool)
        placed = np.zeros((H, W), bool)
        for (x, y, zz), (_, _, ids) in tiles.items():
            if zz == z and ids and not any(otb.blocks(i) for i in ids):
                walk[y - box[1], x - box[0]] = True
        for (x, y, zz) in blockers:
            if zz == z:
                placed[y - box[1], x - box[0]] = True
        if not placed.any():
            continue
        before, _ = ndimage.label(walk)
        while True:
            after, n = ndimage.label(walk & ~placed)
            # parts that were one: each old part should hold one new one
            pairs = np.unique(np.stack([before[walk & ~placed], after[walk & ~placed]]), axis=1)
            olds, counts = np.unique(pairs[0], return_counts=True)
            split = set(olds[counts > 1].tolist())
            if not split:
                break
            # each piece cut off from the biggest piece of its part gets one tree or bush taken out,
            # one that joins it to another piece
            sizes = np.bincount(after.ravel())
            biggest = {}
            for o, a in pairs.T:
                if o in split and (o not in biggest or sizes[a] > sizes[biggest[o]]):
                    biggest[o] = a
            pockets = {int(a) for o, a in pairs.T if o in split and a != biggest[o]}
            cand = placed & np.isin(before, list(split))
            ys, xs = np.nonzero(cand)
            cut, opened = [], set()
            for iy, ix in zip(ys, xs):
                labs = {int(after[ny, nx]) for ny, nx in ((iy - 1, ix), (iy + 1, ix), (iy, ix - 1), (iy, ix + 1))
                        if 0 <= ny < H and 0 <= nx < W and after[ny, nx] > 0}
                mine = (labs & pockets) - opened
                if mine and len(labs) > 1:
                    cut.append((iy, ix))
                    opened |= mine
            # a piece walled in deeper grows by one of its trees at a time until it meets another
            for iy, ix in zip(ys, xs):
                labs = {int(after[ny, nx]) for ny, nx in ((iy - 1, ix), (iy + 1, ix), (iy, ix - 1), (iy, ix + 1))
                        if 0 <= ny < H and 0 <= nx < W and after[ny, nx] > 0}
                mine = (labs & pockets) - opened
                if mine:
                    cut.append((iy, ix))
                    opened |= mine
            if not cut:
                break
            for iy, ix in cut:
                placed[iy, ix] = False
                pos = (ix + box[0], iy + box[1], z)
                new_deco[pos] = [B.pick(rng, B.TUFTS)] if rng.random() < PLAIN_TUFT else []
                blockers.discard(pos)
                dropped += 1
    new_deco = {p: d for p, d in new_deco.items() if d}
    print('kept clear for the paths through: %d' % dropped)

    raw = pvmap.read_tiles_raw(None, set(new_ground) | set(new_deco), data)
    new_tiles = {}
    for pos, t in raw.items():
        children = t.children
        ground = t.ground
        if pos in new_ground:
            if ground is not None:
                ground = new_ground[pos]
            else:
                rest = pvmap.split_items(children)[1:]
                children = pvmap.item_node(new_ground[pos]) + b''.join(rest)
        children += b''.join(pvmap.item_node(i) for i in new_deco.get(pos, []))
        new_tiles[pos] = pvmap.RawTile(t.house_id, t.flags, ground, children)
    counts = {}
    for d in new_deco.values():
        for i in d:
            kind = 'trees' if i in TREES and otb.blocks(i) else 'tufts' if i in dict(B.TUFTS) else 'other'
            counts[kind] = counts.get(kind, 0) + 1
    print('tall grass %d tiles; decoration %s' % (len(new_ground), counts))
    tmp = out + '.tmp'
    pvmap.write_map(data, tmp, new_tiles)
    os.replace(tmp, out)
    print('wrote %s (%d tiles changed)' % (out, len(new_tiles)))


if __name__ == '__main__':
    main()
