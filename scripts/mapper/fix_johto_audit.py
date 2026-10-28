#!/usr/bin/env python3
"""Fixes from the Johto audit on the dev map: roof and wall pieces left hanging off houses,
Cherrygrove's boardwalk that lay on the grass, and dirt roads that ran into the hills' cliffs.

    scripts/mapper/fix_johto_audit.py [roofs] [pier] [cliffs] [--map mapper/map/dev.otbm] [--out <same>]

Does all the parts unless told which.

  roofs     the conversion left strips of tiled roof, white stone wall and railing beside or below
            some houses, a row or two off the building with grass under them, so they hang in the air.
            In each place listed in STRAYS, every tile on floors 4-6 whose ground is one of those
            pieces and that has only them and then natural ground under it goes. (Found by audit, each
            checked on a render; the places where such a piece is a house's real eave are not listed.)
            Then, all over Johto, the building pieces on floors 3-6 over open ground that lie in runs a
            tile or two across, mostly clear of any wall on the ground floor (hanging); KEEP_PIECES
            lists the places where such runs are meant.
  pier      the boardwalk along Cherrygrove's south edge, on the grass strip above the beach: the
            strip goes under water like the bay it opens onto, so the boardwalk stands in the water,
            and the parasols that stood on it move to the sand spit on the bay's east side.
  cliffs    build_johto laid its hills over the dirt, so roads and dirt fields ran up to a cliff and on
            along its top. The dirt in the cliff's face, in front of it and along the top's edge turns
            to grass, the cliff keeping its gravel; dirt that leaves under 2 wide or in small crumbs
            goes too. The ramps stay as they are; walking is not changed anywhere.

Seeded, so the same map gives the same result; run it on a map without it (the dev map has it).
"""
import argparse
import os
import re
import sys

import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import autoborder  # noqa: E402
import johto_edit  # noqa: E402
import pvmap  # noqa: E402
import walkcheck  # noqa: E402

ROOT = os.path.dirname(os.path.dirname(HERE))
DEV = os.path.join(ROOT, 'mapper', 'map')
SEED = 11
PARTS = ['roofs', 'pier', 'cliffs']

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
TRACKS = {'dirt', 'light dirt', 'earth'}
RAMPS = {1388, 1390, 1392, 1394}   # build_johto's ramps and the stairs down above them
RAMP_TOP = 459
LIP = set(range(4456, 4468))      # the mountain's border, which draws a hill's lip
GRAVEL = set(range(4468, 4480))   # the mountain's gravel border
CRUMB = 16   # dirt a cliff's verge leaves in patches smaller than this goes too
SEA = {'sea', 'walkable sea', 'clear water'}
STREETS = {'gray stone tiles', 'dark cobblestone', 'cobblestone', 'pavement', 'ugly cobblestone', 'grassy cobblestone',
           'small tiled gray stone', 'white gravel'}
# what counts as a piece of a building, by item name (or 'roof' anywhere in it)
STRUCT = re.compile(r'wall|window|door|railing|fence|pillar|column|arch|framework|marquee|counter|gate|bars')
# a street is a building's floor when walls on the ground floor close it in this near on all four sides
ENCLOSED = 12
JOHTO = (1700, 20, 3047, 1270)
KEEP_PIECES = [(2832, 588, 2984, 738),   # Tohjo Falls, rebuilt by edit_tohjo_falls.py
               (2350, 668, 2360, 678),   # Goldenrod's cream tower: its pieces stand on its own floors
               (2659, 812, 2683, 826)]   # the farm's pen roofs

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


def item_names():
    xml = open(walkcheck.ITEMS_XML, encoding='latin-1').read()
    names = {}
    for m in re.finditer(r'<item (?:id="(\d+)"|fromid="(\d+)" toid="(\d+)")[^>]*?name="([^"]*)"', xml):
        a, b = int(m.group(1) or m.group(2)), int(m.group(1) or m.group(3))
        for i in range(a, b + 1):
            names[i] = m.group(4).lower()
    return names


def hanging(tiles, brushes, names):
    """The building pieces (wall, window, railing, framework, roof ...) on floors 3-6 over open ground
    in thin runs, a tile or two across, that mostly stand off any wall on the ground floor."""
    fc = walkcheck.floor_changes()
    odd = walkcheck.WATER | set(fc) | {6210, 6211, 6212}

    def ground(x, y):
        ids = tiles.get((x, y, 7))
        return brushes.by_item.get(ids[0]) if ids else None

    def piece(k):
        ids = tiles.get(k)
        if not ids or ids[0] in odd or any(i in odd for i in ids):
            return False
        return any(STRUCT.search(names.get(i, '')) or 'roof' in names.get(i, '') for i in ids)

    def wall7(x, y):
        return any(STRUCT.search(names.get(i, '')) for i in (tiles.get((x, y, 7)) or [])[1:])

    def enclosed(x, y):
        return all(any(wall7(x + dx * i, y + dy * i) for i in range(ENCLOSED + 1))
                   for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)))

    def outdoors(x, y):
        g = ground(x, y)
        if g is None or g.name in SEA:
            return False
        return g.name in NATURAL or g.name in STREETS and not enclosed(x, y)

    def off(x, y):
        return not any(wall7(x + dx, y + dy) for dx in (-1, 0, 1) for dy in (-1, 0, 1))

    found = {k for k in tiles if 3 <= k[2] <= 6 and JOHTO[0] <= k[0] <= JOHTO[2]
             and not any(a <= k[0] <= c and b <= k[1] <= d for a, b, c, d in KEEP_PIECES)
             and piece(k) and outdoors(k[0], k[1])}
    seen, gone = set(), set()
    for s in sorted(found):
        if s in seen:
            continue
        run, todo = [s], [s]
        seen.add(s)
        while todo:
            x, y, z = todo.pop()
            for dx in (-1, 0, 1):
                for dy in (-1, 0, 1):
                    q = (x + dx, y + dy, z)
                    if q in found and q not in seen:
                        seen.add(q)
                        run.append(q)
                        todo.append(q)
        xs, ys = [p[0] for p in run], [p[1] for p in run]
        if min(max(xs) - min(xs), max(ys) - min(ys)) <= 1 and 2 * sum(off(x, y) for x, y, _ in run) >= len(run):
            gone |= set(run)
    return gone


def pick(br, rng):
    ids, w = zip(*([(i, c) for i, c in br.items if c > 0] or br.items))
    w = np.array(w, float)
    return int(rng.choice(ids, p=w / w.sum()))


def repaint(tiles, brushes, paint, rng):
    """{(x, y, z): [item ids]} for `paint` ({key: brush}) and the tiles round it, bordered again; floors
    above the ground floor border as if mountain lay all round, which keeps a cliff's lip. The mountain's
    gravel (an optional border, which borders_for leaves out) stays where it was."""
    B = brushes
    brush = {k: B.by_item.get(ids[0]) for k, ids in tiles.items() if ids}
    brush.update(paint)
    mountain = B['mountain']
    ring = {(x + dx, y + dy, z) for (x, y, z) in paint for dx in (-1, 0, 1) for dy in (-1, 0, 1)}
    new = {}
    for (x, y, z) in sorted(ring):
        center = brush.get((x, y, z))
        if center is None:
            continue
        nb = [brush.get((x + dx, y + dy, z)) for dx, dy in autoborder.NEIGHBOURS]
        if z < 7:
            nb = [b or mountain for b in nb]
        old = tiles.get((x, y, z), [])
        keep = [i for i in old[1:] if i not in B.border_item_ids or i in GRAVEL]
        first = pick(center, rng) if (x, y, z) in paint else old[0]
        new[(x, y, z)] = [first] + B.borders_for(center, nb) + keep
    return {k: v for k, v in new.items() if v != tiles.get(k)}


def verges(tiles, brushes):
    """{(x, y, z): grass brush} for the dirt at a cliff: the cliff face, the dirt in front of it and the
    dirt along the top's edge, so no road runs into a cliff; then dirt left under 2 tiles wide."""
    B = brushes
    grass = B['grass']
    stairs = set(RAMPS) | {RAMP_TOP}

    def br(k):
        ids = tiles.get(k)
        return B.by_item.get(ids[0]) if ids else None

    def dirt(k):
        b = paint.get(k) or br(k)
        return b is not None and b.name in TRACKS and k not in fixed and (k[2] == 7 or k in hill)

    def top(x, y, z):
        return (x, y, z) in hill

    fixed = {k for k, ids in tiles.items() if any(i in stairs for i in ids)}
    keys = [k for k in tiles if JOHTO[0] <= k[0] <= JOHTO[2] and not
            any(a <= k[0] <= c and b <= k[1] <= d for a, b, c, d in KEEP_PIECES[:1])]
    # the hills' tops: natural ground above the ground floor run together with a cliff's lip
    ground = {k for k in keys if 3 <= k[2] <= 6 and (br(k) is not None and br(k).name in NATURAL)}
    hill = {k for k in ground if any(i in LIP for i in tiles[k])}
    todo = list(hill)
    while todo:
        x, y, z = todo.pop()
        for dx in (-1, 0, 1):
            for dy in (-1, 0, 1):
                q = (x + dx, y + dy, z)
                if q in ground and q not in hill:
                    hill.add(q)
                    todo.append(q)
    paint = {}
    for (x, y, z) in keys:
        if not 4 <= z <= 7 or not dirt((x, y, z)):
            continue
        face = top(x, y, z - 1) or top(x + 1, y + 1, z - 1)
        lip = z < 7 and any(br((x + dx, y + dy, z)) is None for dx in (-1, 0, 1) for dy in (-1, 0, 1))
        if face or lip:
            paint[(x, y, z)] = grass
    for (x, y, z) in list(paint):
        for dx in (-1, 0, 1):
            for dy in (-1, 0, 1):
                k = (x + dx, y + dy, z)
                if k not in paint and dirt(k) and not (top(k[0], k[1], z - 1) or top(k[0] + 1, k[1] + 1, z - 1)):
                    paint[k] = grass
    near = {(x + dx, y + dy, z) for (x, y, z) in paint for dx in range(-3, 4) for dy in range(-3, 4)}
    while True:
        thin = [k for k in near if k not in paint and dirt(k) and not any(
            all(dirt((k[0] + sx + ax, k[1] + sy + ay, k[2])) for ax in (0, 1) for ay in (0, 1))
            for sx in (-1, 0) for sy in (-1, 0))]
        for k in thin:
            paint[k] = grass
        if not thin:
            break
    seen = set()
    for s in sorted(near):
        if s in seen or not dirt(s):
            continue
        patch, todo = [s], [s]
        seen.add(s)
        while todo:
            x, y, z = todo.pop()
            for q in ((x + 1, y, z), (x - 1, y, z), (x, y + 1, z), (x, y - 1, z)):
                if q not in seen and dirt(q):
                    seen.add(q)
                    patch.append(q)
                    todo.append(q)
        if len(patch) < CRUMB:
            for k in patch:
                paint[k] = grass
    return paint


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
    new = {}
    for (x, y, z) in sorted(ring):
        center = brush.get((x, y, z))
        if center is None:
            continue
        nb = [brush.get((x + dx, y + dy, z)) for dx, dy in autoborder.NEIGHBOURS]
        old = tiles.get((x, y, z), [])
        if (x, y, z) in under:
            new[(x, y, z)] = [pick(center, rng)] + B.borders_for(center, nb)
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
    ap.add_argument('parts', nargs='*', choices=PARTS)
    args = ap.parse_args()
    args.parts = args.parts or PARTS
    out = args.out or args.map

    data = open(args.map, 'rb').read()
    base = johto_edit.read_boxes(data, {'johto': JOHTO})['johto']
    tiles = {k: johto_edit.ids_of(t) for k, t in base.items()}
    B = autoborder.Brushes()
    rng = np.random.default_rng(SEED)
    edit = johto_edit.Edit(base)

    def apply(changed):
        for k, ids in changed.items():
            edit.set(k, ids)
            if ids:
                tiles[k] = ids
            else:
                tiles.pop(k, None)
        return len(changed)

    done = []
    if 'roofs' in args.parts:
        gone = strays(tiles, B)
        gone |= hanging(tiles, B, item_names())
        done.append('%d hanging roof and wall pieces out' % apply({k: [] for k in gone}))
    if 'pier' in args.parts:
        done.append('%d tiles at the pier' % apply(pier(tiles, B, rng)))
    if 'cliffs' in args.parts:
        done.append('%d tiles at the cliffs' % apply(repaint(tiles, B, verges(tiles, B), rng)))
    new_tiles, remove = edit.tiles()
    cut = pvmap.write_map(data, out, new_tiles, remove)
    print('%s: %s; %d written, %d removed (%d replaced)' % (out, ', '.join(done), len(new_tiles), len(remove), cut))


if __name__ == '__main__':
    main()
