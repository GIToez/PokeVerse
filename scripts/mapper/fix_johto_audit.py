#!/usr/bin/env python3
"""Fixes from the Johto audit on the dev map: roof and wall pieces left hanging off houses, and
Cherrygrove's boardwalk that lay on the grass.

    scripts/mapper/fix_johto_audit.py [roofs] [pier] [--map mapper/map/dev.otbm] [--out <same>]

Does both parts unless told which.

  roofs     the conversion left strips of tiled roof, white stone wall and railing beside or below
            some houses, a row or two off the building with grass under them, so they hang in the air.
            In each place listed in STRAYS, every tile on floors 4-6 whose ground is one of those
            pieces and that has only them and then natural ground under it goes. (Found by audit, each
            checked on a render; the places where such a piece is a house's real eave are not listed.)
  pier      the boardwalk along Cherrygrove's south edge, on the grass strip above the beach: the
            strip goes under water like the bay it opens onto, so the boardwalk stands in the water,
            and the parasols that stood on it move to the sand spit on the bay's east side.

Seeded, so the same map gives the same result; run it on a map without it (the dev map has it).
"""
import argparse
import os
import sys

import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import autoborder  # noqa: E402
import johto_edit  # noqa: E402
import pvmap  # noqa: E402

ROOT = os.path.dirname(os.path.dirname(HERE))
DEV = os.path.join(ROOT, 'mapper', 'map')
SEED = 11

STRAYS = [
    (1892, 687, 1905, 691), (1904, 644, 1906, 653), (1946, 689, 1958, 694),                            # Cianwood
    (2100, 484, 2105, 494), (2118, 504, 2118, 515), (2146, 541, 2158, 542), (2159, 507, 2160, 515),    # Olivine
    (2163, 541, 2171, 542), (2176, 530, 2176, 540),
    (2276, 709, 2285, 710), (2298, 750, 2302, 750), (2310, 695, 2313, 706), (2312, 756, 2313, 766),    # Goldenrod
    (2359, 735, 2363, 748), (2359, 755, 2363, 766), (2371, 705, 2387, 706), (2384, 755, 2384, 757),
    (2384, 763, 2384, 769), (2386, 742, 2386, 753),
    (2460, 1045, 2461, 1051), (2462, 1025, 2463, 1031),                                                 # Azalea
    (2505, 851, 2518, 853), (2556, 812, 2569, 813),                                                     # Cherrygrove
]
PIECES = set(range(925, 945)) | {1111, 1112, 1113, 5303, 5304} | set(range(1582, 1593))
NATURAL = {'grass', 'dirt', 'sand', 'lawn', 'light dirt', 'earth', 'jungle grass', 'dried grass', 'snow', 'swamp',
           'dry earth'}

PIER = (2529, 861, 2581, 863)                       # the boardwalk
UNDER = [(2529, 864, 2581, 867), (2529, 868, 2571, 870)]   # grass and sand from it down to the bay
BEACH = [(2573, 870), (2574, 873), (2574, 876), (2574, 879), (2575, 882)]   # the spit, for the parasols
AREA = (2520, 852, 2590, 886)
PARASOLS = (7716, 7717, 7718)


def strays(tiles, brushes):
    def piece(k):
        ids = tiles.get(k)
        return bool(ids) and ids[0] in PIECES

    def hangs(x, y, z):
        if any(tiles.get((x, y, zz)) and not piece((x, y, zz)) for zz in range(z + 1, 7)):
            return False
        g = tiles.get((x, y, 7))
        br = brushes.by_item.get(g[0]) if g else None
        return br is not None and br.name in NATURAL

    return {k for k in tiles if 4 <= k[2] <= 6 and any(a <= k[0] <= c and b <= k[1] <= d for a, b, c, d in STRAYS)
            and piece(k) and hangs(*k)}


def pier(tiles, brushes, rng):
    """{(x, y, 7): [item ids]} for the tiles around the boardwalk that change."""
    B = brushes
    WATER = B['walkable sea']
    brush = {k: B.by_item.get(ids[0]) for k, ids in tiles.items() if ids and k[2] == 7}
    under = {(x, y, 7) for a, b, c, d in UNDER for x in range(a, c + 1) for y in range(b, d + 1)}
    parasols = []
    for (x, y, z) in sorted(under):
        parasols += [i for i in tiles[(x, y, z)][1:] if i in PARASOLS]
        brush[(x, y, z)] = WATER
    ring = under | {(x + dx, y + dy, 7) for (x, y, _) in under for dx in (-1, 0, 1) for dy in (-1, 0, 1)}

    def pick(br):
        ids, w = zip(*([(i, c) for i, c in br.items if c > 0] or br.items))
        w = np.array(w, float)
        return int(rng.choice(ids, p=w / w.sum()))

    new = {}
    for (x, y, z) in sorted(ring):
        center = brush.get((x, y, z))
        if center is None:
            continue
        nb = [brush.get((x + dx, y + dy, z)) for dx, dy in autoborder.NEIGHBOURS]
        old = tiles.get((x, y, z), [])
        if (x, y, z) in under:
            new[(x, y, z)] = [pick(center)] + B.borders_for(center, nb)
        else:
            keep = [i for i in old[1:] if i not in B.border_item_ids]
            new[(x, y, z)] = [old[0]] + B.borders_for(center, nb) + keep
    for (x, y), i in zip(BEACH, parasols):
        k = (x, y, 7)
        new[k] = (new.get(k) or tiles[k]) + [i]
    return {k: v for k, v in new.items() if v != tiles.get(k)}


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument('--map', default=os.path.join(DEV, 'dev.otbm'))
    ap.add_argument('--out')
    ap.add_argument('parts', nargs='*', choices=['roofs', 'pier'], default=['roofs', 'pier'])
    args = ap.parse_args()
    out = args.out or args.map

    data = open(args.map, 'rb').read()
    boxes = {'s%d' % n: b for n, b in enumerate(STRAYS)}
    boxes['pier'] = AREA
    raw = johto_edit.read_boxes(data, boxes)
    base = {}
    for part in raw.values():
        base.update(part)
    tiles = {k: johto_edit.ids_of(t) for k, t in base.items()}
    B = autoborder.Brushes()

    edit = johto_edit.Edit(base)
    gone = strays(tiles, B) if 'roofs' in args.parts else set()
    for k in gone:
        edit.set(k, [])
    changed = pier(tiles, B, np.random.default_rng(SEED)) if 'pier' in args.parts else {}
    for k, ids in changed.items():
        edit.set(k, ids)
    new_tiles, remove = edit.tiles()
    cut = pvmap.write_map(data, out, new_tiles, remove)
    print('%s: %d hanging roof and wall pieces out, %d tiles at the pier; %d written, %d removed (%d replaced)'
          % (out, len(gone), len(changed), len(new_tiles), len(remove), cut))


if __name__ == '__main__':
    main()
