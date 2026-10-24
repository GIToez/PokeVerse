#!/usr/bin/env python3
"""Writes the world map's names: regions, cities, routes and landmarks with the spot each name
is drawn on, for the Pokepedia map, the minimap's full view and the Places list.

    scripts/mapper/build_map_labels.py [--out <file>]

Writes core/client-redemption/pokeverse-modern/modules/game_minimap/map_labels.lua.

Cities are listed below (the middle of each town). Routes and landmarks come from the area
names the area banner uses (client-legacy's sounds1.lua and sounds2.lua, moved east by the same
2351 tiles game_environment moves them, and game_environment/areas_johto.lua): each name is drawn
in the middle of its largest rectangle on the ground floor (floors 5 and 6 for a route that only has
raised ground, such as the Cycling Road). Routes are every "Route NN" (a suffix such as " - Cycling
Road" is dropped); landmarks are the names in LANDMARKS. PLACES overrides a spot or adds a name the
areas don't have: the routes with no area, placed between the places Bulbapedia says they connect.

Regions are the server's boxes (079-weather.lua's Weather.REGIONS, the same order: Johto's box
overlaps Hoenn's sea); Kanto is the rest. Past x = OTHER_X are the event and instance areas (the
Union Room, the cake land, Tutorial Island): region "other", no map names. Names inside a region
listed in hidden-regions.txt are left out.

Needs lua (5.1) to read the area files.
"""
import argparse
import collections
import os
import re
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(HERE))
MODERN = os.path.join(ROOT, 'core/client-redemption/pokeverse-modern/modules')
LEGACY = os.path.join(ROOT, 'core/client-legacy/modules/game_environment')
OUT = os.path.join(MODERN, 'game_minimap/map_labels.lua')
HIDDEN = os.path.join(HERE, 'hidden-regions.txt')

LEGACY_OFFSET_X = 2351
OTHER_X = 4690
ROUTE = re.compile(r'^Route 0*(\d+)(?: - .*)?$')

# id, name, box (x1, y1, x2, y2) or None for the rest
REGIONS = [
    ('johto', 'Johto', (1700, 20, 3048, 1270)),
    ('orange', 'Orange Islands', (2641, 1311, 4647, 3486)),
    ('hoenn', 'Hoenn', (48, 773, 2224, 2304)),
    ('kanto', 'Kanto', None),
]
# the Places list's order
REGION_ORDER = ['kanto', 'johto', 'orange', 'hoenn', 'other']
# where the region's name is drawn when zoomed out (the middle of its cities otherwise)
REGION_SPOTS = {
    'kanto': (3720, 600),
    'johto': (2420, 640),
    'orange': (3600, 2450),
    'hoenn': (860, 1560),
}

CITIES = [
    ('Viridian', 3296, 560), ('Pallet', 3292, 799), ('Pewter', 3305, 296), ('Cerulean', 3888, 305),
    ('Saffron', 3938, 478), ('Celadon', 3700, 437), ('Lavender', 4191, 557), ('Vermilion', 3952, 637),
    ('Fuchsia', 3863, 845), ('Cinnabar', 3357, 1035),
    ('New Bark', 2721, 812), ('Cherrygrove', 2550, 829), ('Violet', 2498, 569), ('Azalea', 2398, 1040),
    ('Goldenrod', 2315, 731), ('Ecruteak', 2331, 399), ('Olivine', 2132, 513), ('Cianwood', 1926, 657),
    ('Mahogany', 2553, 384), ('Blackthorn', 2744, 376),
    ('Hamlin', 3473, 1493), ('Tarroco', 3235, 1490), ('Kumquat', 3516, 1674), ('Pummelo', 3062, 1658),
    ('Millsweet', 3071, 1905), ('Desert Island', 2823, 1819), ('Mandarin Island North', 2966, 2197),
    ('Mikan', 2719, 2408), ('Sunburst', 3025, 2551), ('Tangelo', 2726, 2780), ('Valencia', 2985, 2949),
    ('Pinkan', 3265, 2784), ('Fairchild', 3473, 2496), ('Mandarin Island South', 3542, 3234),
    ('Trovita', 3339, 3191), ('Shamouti', 3524, 1937), ('Cleopatra', 3923, 1945), ('Butwal', 4102, 1777),
    ('Ascorbia', 4430, 1705), ('Navel', 4402, 2249), ('Desert Island', 4145, 2351),
    ('Seven Grapefruit', 4332, 2630), ('Moro', 4178, 2934), ('Golden', 3904, 3030), ('Murcott', 4121, 3233),
    ('Desert Island', 4001, 3458), ('Kinow', 3827, 2633),
    ('Littleroot', 513, 1832), ('Oldale', 519, 1709), ('Petalburg', 396, 1689), ('Rustboro', 256, 1506),
    ('Dewford', 408, 2005), ('Slateport', 728, 1787), ('Mauville', 777, 1451), ('Verdanturf', 544, 1510),
    ('Fallarbor', 475, 1143), ('Lavaridge', 572, 1326), ('Fortree', 996, 1151), ('Lilycove', 1354, 1313),
    ('Mossdeep', 1732, 1429), ('Sootopolis', 1576, 1547), ('Pacifidlog', 1311, 1762),
]

# area name: the name on the map (None keeps it)
LANDMARKS = {
    # Kanto
    'Viridian Forest': None, 'Mt. Moon': None, 'Cerulean Cave': None, 'Rock Tunnel': None,
    'Power Plant': None, 'Lavender Tower': 'Pokemon Tower', 'Seafoam': 'Seafoam Islands',
    'Stone Mountain': None, 'Birds Mountain': None, 'Grampa Canyon': None, 'S. S. Anne': None,
    'The Volcano Coast Cave': 'Volcano Coast Cave', 'Within the Iceberg': 'Iceberg',
    # Johto
    'Ilex Forest': None, 'Lake of Rage': None, 'Mt. Silver': None, 'Ruins of Alph': None,
    'National Park': None, 'Bell Tower': None, 'Burned Tower': None, 'Sprout Tower': None,
    'Olivine Lighthouse': 'Lighthouse', 'Moomoo Farm': None, 'Mortar Badlands': None,
    'Rage Marshes': None, 'Frozen North': None, 'Snowtop Mountain': None, 'Mount Quena': None,
    'Dragon Holy Land': None, 'Lake Slowpoke': None, 'Lake of Life': None, 'Battle Frontier': None,
    'Safari Zone': None, 'Arbor Woods': None, 'Ecruteak Old Forest': 'Old Forest',
    'Azalea South Woods': 'South Woods', 'Olivine Cliffs': None, 'I.S.S. Raspberry': None,
    # Orange Islands
    'Pinkan Island': None, 'Fire Island': None, 'Ice Island': None, 'Lightning Island': None,
    'Leaf Jungle': None, 'Venomous Jungle': None, 'Jungle Murcott': None, 'Pummelo Forest': None,
    'Forest North': None, 'Great Beach': None, 'Beach Tarroco': None, 'Beach Tangelo': None,
    'Rind Island': None, 'Meadow': None, 'Desert Mandarin': None, 'Forgotten Temple': None,
    'Cave of Fear': None, 'Mountain Living Stone': None,
    'Petalburg Woods': None, 'Meteor Falls': None, 'Mt. Chimney': None, 'Jagged Pass': None,
    'Route 111 Desert': 'Desert', 'Mt. Pyre': None, 'Ever Grande': None,
}

# name: (kind, x, y): moves a name, or adds one the areas don't have
PLACES = {
    # Kanto
    'Route 2': ('route', 3300, 425),  # Viridian - Pewter
    'Route 17': ('route', 3620, 680),  # the Cycling Road bridge
    'Route 18': ('route', 3740, 800),  # Cycling Road - Fuchsia
    'Route 20': ('route', 3460, 990),  # sea, Cinnabar - Seafoam Islands - Fuchsia
    'Route 21': ('route', 3305, 910),  # sea, Pallet - Cinnabar
    # Hoenn
    'Route 101': ('route', 515, 1772),  # Littleroot - Oldale
    'Route 102': ('route', 455, 1702),  # Oldale - Petalburg
    'Route 103': ('route', 575, 1625),  # Oldale - Route 110
    'Route 104': ('route', 250, 1610),  # Petalburg - Rustboro - Route 105
    'Route 105': ('route', 150, 1790),  # sea, Route 104 - Route 106
    'Route 106': ('route', 250, 1955),  # sea, Route 105 - Dewford
    'Route 107': ('route', 500, 2015),  # sea, Dewford - Route 108
    'Route 108': ('route', 635, 1960),  # sea, Route 107 - Route 109
    'Route 109': ('route', 720, 1900),  # Slateport's beach and sea
    'Route 110': ('route', 745, 1600),  # Slateport - Mauville - Route 103
    'Route 111': ('route', 795, 1105),  # Mauville - the desert - Route 112 - Route 113; north of the desert
    'Route 112': ('route', 680, 1375),  # Route 111 - Lavaridge - Mt. Chimney
    'Route 113': ('route', 620, 1150),  # Route 111 - Fallarbor
    'Route 114': ('route', 320, 1130),  # Fallarbor - Meteor Falls
    'Route 115': ('route', 195, 1385),  # Meteor Falls - Rustboro
    'Route 116': ('route', 370, 1465),  # Rustboro - Rusturf Tunnel
    'Route 117': ('route', 660, 1485),  # Verdanturf - Mauville
    'Route 118': ('route', 950, 1455),  # Mauville - Route 119 - Route 123
    'Route 119': ('route', 985, 1300),  # Route 118 - Fortree
    'Route 120': ('route', 1120, 1200),  # Fortree - Route 121
    'Route 121': ('route', 1235, 1330),  # Route 120 - Lilycove - Route 122
    'Route 122': ('route', 1250, 1445),  # sea, Route 121 - Route 123
    'Route 123': ('route', 1100, 1525),  # Route 122 - Route 118
    'Route 124': ('route', 1550, 1335),  # sea, Lilycove - Mossdeep - Route 126
    'Route 125': ('route', 1735, 1345),  # sea, Mossdeep - Shoal Cave
    'Route 126': ('route', 1455, 1505),  # sea around Sootopolis
    'Route 127': ('route', 1720, 1550),  # sea, Mossdeep - Route 126 - Route 128
    'Route 128': ('route', 1785, 1700),  # sea, Route 127 - Ever Grande
    'Route 129': ('route', 1650, 1855),  # sea, Route 128 - Route 130
    'Route 130': ('route', 1500, 1890),  # sea, Route 129 - Route 131
    'Route 131': ('route', 1420, 1780),  # sea, Route 130 - Pacifidlog
    'Route 132': ('route', 1180, 1780),  # sea, Pacifidlog - Route 133
    'Route 133': ('route', 1020, 1810),  # sea, Route 132 - Route 134
    'Route 134': ('route', 880, 1835),  # sea, Route 133 - Slateport
}


def read_hidden(path):
    """The hidden regions' boxes, and the "bounds" box (None: no bounds)."""
    boxes, bounds = [], None
    if not os.path.exists(path):
        return boxes, bounds
    pattern = re.compile(r'^(.*?):\s*(\d+)\s*,\s*(\d+)\s*-\s*(\d+)\s*,\s*(\d+)$')
    for line in open(path):
        line = line.split('#', 1)[0].strip()
        m = pattern.match(line)
        if m:
            x1, y1, x2, y2 = (int(v) for v in m.groups()[1:])
            box = (min(x1, x2), min(y1, y2), max(x1, x2), max(y1, y2))
            if m.group(1).strip().lower() == 'bounds':
                bounds = box
            else:
                boxes.append(box)
    return boxes, bounds


def region_at(x, y):
    if x >= OTHER_X:
        return 'other'
    for rid, _, box in REGIONS:
        if box is None or (box[0] <= x <= box[2] and box[1] <= y <= box[3]):
            return rid
    return 'kanto'


DUMP = r'''
local function out(name, x0, y0, z0, x1, y1, z1)
    if name and name ~= '' then
        io.write(name, '\t', x0, '\t', y0, '\t', z0, '\t', x1, '\t', y1, '\t', z1, '\n')
    end
end
dofile(LEGACY .. '/sounds1.lua')
dofile(LEGACY .. '/sounds2.lua')
for _, list in ipairs({ SOUNDS1, SOUNDS2 }) do
    for _, a in pairs(list) do
        if a.fromPos then
            out(a[8], a.fromPos.x + OFFSET, a.fromPos.y, a.fromPos.z, a.toPos.x + OFFSET, a.toPos.y, a.toPos.z)
        end
    end
end
dofile(JOHTO)
for _, a in ipairs(AREAS_JOHTO) do
    out(a[7], a[1], a[2], a[3], a[4], a[5], a[6])
end
dofile(HOENN)
for _, a in ipairs(AREAS_HOENN) do
    out(a[7], a[1], a[2], a[3], a[4], a[5], a[6])
end
'''


def read_areas():
    script = 'LEGACY = %r; JOHTO = %r; HOENN = %r; OFFSET = %d\n%s' % (
        LEGACY, os.path.join(MODERN, 'game_environment/areas_johto.lua'),
        os.path.join(MODERN, 'game_environment/areas_hoenn.lua'), LEGACY_OFFSET_X, DUMP)
    try:
        text = subprocess.run(['lua', '-e', script], check=True, capture_output=True, text=True).stdout
    except FileNotFoundError:
        sys.exit('needs lua (5.1) on the PATH')
    areas = collections.defaultdict(list)
    raised = collections.defaultdict(list)
    for line in text.splitlines():
        name, *coords = line.split('\t')
        x0, y0, z0, x1, y1, z1 = (int(v) for v in coords)
        if z0 <= 7 <= z1:
            areas[name].append((min(x0, x1), min(y0, y1), max(x0, x1), max(y0, y1)))
        elif z1 >= 5 and z0 <= 6 and ROUTE.match(name):
            raised[name].append((min(x0, x1), min(y0, y1), max(x0, x1), max(y0, y1)))
    for name, rects in raised.items():
        if name not in areas:
            areas[name] = rects
    return areas


def spot(rects):
    x0, y0, x1, y1 = max(rects, key=lambda r: (r[2] - r[0]) * (r[3] - r[1]))
    return (x0 + x1) // 2, (y0 + y1) // 2


def snap(rects, x, y):
    """(x, y), or the nearest spot in `rects` when it lies outside them."""
    best = None
    for x0, y0, x1, y1 in rects:
        sx, sy = min(max(x, x0), x1), min(max(y, y0), y1)
        d = (sx - x) ** 2 + (sy - y) ** 2
        if best is None or d < best[0]:
            best = (d, sx, sy)
    return (x, y) if best is None else best[1:]


def lua_string(text):
    return '"%s"' % text.replace('\\', '\\\\').replace('"', '\\"')


def main():
    parser = argparse.ArgumentParser(description=__doc__.split('\n')[0])
    parser.add_argument('--out', default=OUT)
    args = parser.parse_args()

    hidden, bounds = read_hidden(HIDDEN)

    def shown(x, y):
        if bounds and not (bounds[0] <= x <= bounds[2] and bounds[1] <= y <= bounds[3]):
            return False
        return not any(b[0] <= x <= b[2] and b[1] <= y <= b[3] for b in hidden)

    labels = []
    for name, x, y in CITIES:
        labels.append(('city', name, x, y))
    areas = read_areas()
    for name, rects in areas.items():
        route = ROUTE.match(name)
        if route:
            labels.append(('route', 'Route %s' % route.group(1)) + spot(rects))
        elif name in LANDMARKS:
            labels.append(('landmark', LANDMARKS[name] or name) + spot(rects))
    for name, (kind, x, y) in PLACES.items():
        labels = [label for label in labels if label[1] != name]
        x, y = snap(areas.get(name, []), x, y)
        labels.append((kind, name, x, y))
    labels = [label for label in labels if label[2] < OTHER_X and shown(label[2], label[3])]

    order = {'city': 0, 'route': 1, 'landmark': 2}
    labels.sort(key=lambda l: (REGION_ORDER.index(region_at(l[2], l[3])), order[l[0]],
                               int(l[1][6:]) if l[0] == 'route' else 0, l[1]))

    lines = [
        '-- Generated by scripts/mapper/build_map_labels.py; edit that, not this.',
        '-- The world map\'s names. MAP_REGIONS: the regions in the Places list\'s order, with the spot',
        '-- their name is drawn on and their box (none: the rest of the surface). MAP_LABELS: the cities,',
        '-- routes and landmarks, kind "city", "route" or "landmark".',
        '',
        'MAP_REGIONS = {',
    ]
    names = {rid: name for rid, name, _ in REGIONS}
    names['other'] = 'Other places'
    boxes = {rid: box for rid, _, box in REGIONS}
    for rid in REGION_ORDER:
        fields = ['id = %s' % lua_string(rid), 'name = %s' % lua_string(names[rid])]
        cities = [(x, y) for kind, _, x, y in labels if kind == 'city' and region_at(x, y) == rid]
        if rid in REGION_SPOTS or cities:
            x, y = REGION_SPOTS.get(rid) or (sum(c[0] for c in cities) // len(cities),
                                             sum(c[1] for c in cities) // len(cities))
            if shown(x, y):
                fields.append('position = { x = %d, y = %d, z = 7 }' % (x, y))
        if rid == 'other':
            fields.append('from = { x = %d, y = 0 }, to = { x = 65535, y = 65535 }' % OTHER_X)
        elif boxes.get(rid):
            b = boxes[rid]
            fields.append('from = { x = %d, y = %d }, to = { x = %d, y = %d }' % b)
        lines.append('    { %s },' % ', '.join(fields))
    lines += ['}', '', 'MAP_LABELS = {']
    for kind, name, x, y in labels:
        lines.append('    { kind = %s, region = %s, name = %s, position = { x = %d, y = %d, z = 7 } },' % (
            lua_string(kind), lua_string(region_at(x, y)), lua_string(name), x, y))
    lines += ['}', '']
    with open(args.out, 'w') as f:
        f.write('\n'.join(lines))
    counts = collections.Counter(label[0] for label in labels)
    print('%s: %d cities, %d routes, %d landmarks' % (os.path.relpath(args.out, ROOT), counts['city'],
                                                     counts['route'], counts['landmark']))


if __name__ == '__main__':
    main()
