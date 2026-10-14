"""Johto's towns as approved in the design proposal: what each one copies from its Kanto mirror
(New Bark from Pallet, Cherrygrove from Viridian, Violet from Pewter, Azalea from Cerulean),
where its streets, buildings, water and landmarks go, and the decoration around them.

Buildings are copied tile for tile from Kanto. Boxes are the building's house tiles plus the
ring of walls around them, on the ground floor, with every floor above copied along. Houses keep
being houses (rent 0) unless the building is a landmark (`rent: False`), which drops the house ids.
"""
import numpy as np

# name: source box on floor 7, and whether its houses stay rentable.
BUILDINGS = {
    # Pallet Town (New Bark)
    'pallet-duplex': {'box': (3284, 822, 3306, 834)},
    'pallet-house': {'box': (3301, 789, 3311, 800)},
    'pallet-farm-a': {'box': (3270, 800, 3276, 805)},
    'pallet-farm-b': {'box': (3280, 787, 3286, 792)},
    'pallet-farm-c': {'box': (3272, 784, 3278, 789)},
    'pallet-farm-d': {'box': (3277, 827, 3283, 832)},
    # Viridian City (Cherrygrove)
    'viridian-198': {'box': (3279, 586, 3291, 597)},
    'viridian-201': {'box': (3310, 587, 3324, 598)},
    'viridian-202': {'box': (3313, 567, 3324, 578)},
    'viridian-205': {'box': (3280, 541, 3293, 552)},
    'viridian-206': {'box': (3258, 542, 3271, 553)},
    'viridian-208': {'box': (3286, 607, 3296, 616)},
    'viridian-209': {'box': (3311, 603, 3322, 614)},
    'viridian-210': {'box': (3326, 573, 3339, 583)},
    'viridian-211': {'box': (3280, 527, 3293, 537)},
    'viridian-212': {'box': (3301, 522, 3313, 532)},
    # Pewter City (Violet)
    'pewter-226': {'box': (3266, 252, 3272, 257)},
    'pewter-227': {'box': (3261, 246, 3266, 252)},
    'pewter-228': {'box': (3253, 249, 3259, 254)},
    'pewter-229': {'box': (3252, 259, 3258, 264)},
    'pewter-230': {'box': (3259, 263, 3264, 269)},
    'pewter-232': {'box': (3300, 312, 3311, 324)},
    'pewter-235': {'box': (3282, 320, 3293, 331)},
    'pewter-239': {'box': (3267, 292, 3278, 304)},
    'pewter-240': {'box': (3295, 272, 3307, 284)},
    'pewter-241': {'box': (3316, 263, 3328, 287)},
    'pewter-246': {'box': (3300, 246, 3313, 257)},
    'pewter-247': {'box': (3271, 270, 3286, 282)},
    # Cerulean City (Azalea)
    'cerulean-270': {'box': (3886, 325, 3899, 338)},
    'cerulean-271': {'box': (3855, 324, 3868, 334)},
    'cerulean-272': {'box': (3853, 300, 3866, 313)},
    'cerulean-274': {'box': (3898, 301, 3911, 314)},
    'cerulean-275': {'box': (3913, 307, 3926, 317)},
    'cerulean-276': {'box': (3884, 339, 3896, 350)},
    'cerulean-277': {'box': (3907, 331, 3918, 344)},
    'cerulean-278': {'box': (3840, 306, 3853, 317)},
    'cerulean-279': {'box': (3838, 294, 3851, 304)},
    'cerulean-282': {'box': (3897, 282, 3911, 293)},
    'cerulean-283': {'box': (3887, 263, 3902, 276)},
    'cerulean-284': {'box': (3924, 280, 3938, 292)},
    # Landmarks: Kanto buildings standing in for Johto's, not for rent.
    'sprout-tower': {'box': (3872, 238, 3893, 258), 'rent': False},
    'academy': {'box': (3260, 520, 3279, 537), 'rent': False},
    'theatre': {'box': (3323, 292, 3348, 303), 'rent': False},
    'kurts-house': {'box': (3848, 270, 3863, 283), 'rent': False},
    'guide-gent': {'box': (3286, 607, 3296, 616), 'rent': False},
    # Pallet's house and cottage without their walls' ring (the door is below the box, `door` its
    # first column): Officer Jenny's police box, the boathouse and the windmills (a wheel on the roof).
    'police-box': {'box': (3302, 790, 3314, 799), 'walled': False, 'door': 5, 'rent': False},
    'boathouse': {'box': (3302, 804, 3310, 813), 'walled': False, 'door': 3, 'rent': False},
    'windmill': {'box': (3302, 804, 3310, 813), 'walled': False, 'door': 3, 'rent': False},
}

# Decoration (item ids), none of which players can pick up or move. Fences go like Pallet's: a post
# in the top-left corner, rails along the top and bottom, side pieces and a post bottom-right.
FENCE_TOP_LEFT, FENCE_H, FENCE_V, FENCE_BOTTOM_RIGHT = 1533, 1536, 1534, 1535
STREET_LAMP = 1479
LANTERN = 3743
BENCH_S = 1662
STATUE = 1448
CAT_STATUE = 1450
CHERRY_TREE = 10143
RED_TREE, YELLOW_TREE = 2704, 2706
FLOWERS = [2740, 2742, 2743, 2748, 2749, 2750, 2751, 2752, 2753]
PARASOLS = [7716, 7717, 7718]
CRATES = [7481]
WOOD_PILES = [5546, 8581]
HAY = [3848, 3849, 3850, 3851]
SCARECROW = 13491
BOAT = 3587
SIGN = 1429
STREET_SIGN = 1438
PC_SIGN, MART_SIGN = 11887, 11888
FURNACES = [8684, 8686, 8688, 8690]
MILL_WHEEL = (1379, 1380)
CAMPFIRE = 1421


class Town:
    """Collects one town's layout. Coordinates are absolute map tiles."""

    def __init__(self, spec, sizes):
        self.spec = spec
        self.sizes = sizes  # prefab name -> (w, h)
        self.buildings = []
        self.streets = []  # (polyline, half width)
        self.plazas = []  # (x, y, r)
        self.rivers = []  # (polyline, half width)
        self.ponds = []  # (x, y, r)
        self.islets = []  # (x, y, r)
        self.decor = {}  # (x, y) -> list of item ids
        self.grounds = {}  # (x, y) -> brush name forced under the decoration
        self.taken = set()
        self.npcs = []
        self.errors = []
        self.wheels = []  # windmills (top-left corner) that get MILL_WHEEL on the front of the roof

    # -- buildings
    def free(self, name, x, y, margin=1):
        w, h = self.sizes[name]
        return not any((xx, yy) in self.taken for xx in range(x - margin, x + w + margin)
                       for yy in range(y - margin, y + h + margin))

    def free_tile(self, x, y):
        return (x, y) not in self.taken

    def put(self, name, x, y, check=True):
        w, h = self.sizes[name]
        if check and not self.free(name, x, y):
            self.errors.append('%s at %d,%d overlaps' % (name, x, y))
            return None
        self.buildings.append((name, x, y))
        self.taken |= {(xx, yy) for xx in range(x, x + w) for yy in range(y, y + h)}
        return x, y, w, h

    def row(self, names, x, street_y, side, gap=2, setback=4, limit=None):
        """Buildings along an east-west street, left to right, north or south of it."""
        for name in names:
            w, h = self.sizes[name]
            y = street_y - setback - h + 1 if side == 'north' else street_y + setback
            while not self.free(name, x, y):
                x += 1
            if limit is not None and x + w > limit:
                break
            self.put(name, x, y)
            x += w + gap
        return x

    def col(self, names, street_x, y, side, gap=2, setback=4, limit=None):
        """Buildings along a north-south street, top to bottom, west or east of it."""
        for name in names:
            w, h = self.sizes[name]
            x = street_x - setback - w + 1 if side == 'west' else street_x + setback
            while not self.free(name, x, y):
                y += 1
            if limit is not None and y + h > limit:
                break
            self.put(name, x, y)
            y += h + gap
        return y

    def block(self, x0, y0, x1, y1):
        self.taken |= {(x, y) for x in range(x0, x1 + 1) for y in range(y0, y1 + 1)}

    # -- decoration
    def item(self, x, y, *ids, ground=None):
        self.decor.setdefault((x, y), []).extend(ids)
        if ground:
            self.grounds[(x, y)] = ground
        self.taken.add((x, y))

    def fence(self, x0, y0, x1, y1, gates=()):
        ring = {(x0, y0): FENCE_TOP_LEFT, (x1, y1): FENCE_BOTTOM_RIGHT}
        for x in range(x0 + 1, x1 + 1):
            ring[(x, y0)] = FENCE_H
        for x in range(x0 + 1, x1):
            ring[(x, y1)] = FENCE_H
        for y in range(y0 + 1, y1 + 1):
            ring.setdefault((x0, y), FENCE_V)
        for y in range(y0 + 1, y1):
            ring[(x1, y)] = FENCE_V
        for (x, y), item in ring.items():
            if (x, y) not in gates:
                self.item(x, y, item)

    def ground(self, x0, y0, x1, y1, brush):
        for x in range(x0, x1 + 1):
            for y in range(y0, y1 + 1):
                self.grounds[(x, y)] = brush


def _rng(seed):
    return np.random.default_rng(seed)


def new_bark(t):
    """Pallet's mirror: a windy farming town on the coast. Elm's lab and its research yard to the
    west, homes and farm sheds around the main street, a ridge of windmills to the north and a
    little harbour on the bay to the south-east."""
    rng = _rng(50)
    t.streets += [([(2676, 806), (2770, 806)], 2), ([(2722, 806), (2722, 846), (2740, 852), (2760, 852)], 1.5),
                  ([(2722, 806), (2722, 790), (2740, 785), (2758, 786)], 1)]
    t.plazas.append((2719, 806, 5))
    t.put('pokecenter', 2712, 795)
    t.item(2710, 803, PC_SIGN)
    # Elm's lab with a fenced research yard and a greenhouse of flower beds
    t.put('lab', 2684, 789)
    t.fence(2668, 787, 2681, 801, gates=[(2681, 797), (2681, 798)])
    for x in range(2670, 2680, 3):
        t.item(x, 789, FLOWERS[x % len(FLOWERS)])
    t.item(2674, 795, STATUE)
    t.item(2671, 799, BENCH_S)
    t.item(2677, 799, BENCH_S)
    t.item(2683, 802, SIGN)
    t.fence(2684, 811, 2697, 820, gates=[(2690, 811), (2691, 811)])
    for y in range(813, 819, 2):
        for x in range(2686, 2696):
            t.item(x, y, FLOWERS[(x + y) % 3 + 3], ground='dirt')
    # homes along the main street (Pallet's houses open to the west, the pairs to the north)
    t.put('pallet-house', 2735, 791)
    t.put('pallet-house', 2751, 791)
    t.put('pallet-duplex', 2728, 810)
    t.put('pallet-duplex', 2754, 810)
    t.put('pallet-house', 2702, 812)
    t.put('pallet-house', 2703, 779)
    # farm sheds and a paddock with hay in the south-west
    for name, x, y in [('pallet-farm-a', 2660, 811), ('pallet-farm-b', 2669, 811),
                       ('pallet-farm-c', 2660, 820), ('pallet-farm-d', 2671, 821)]:
        t.put(name, x, y)
    t.fence(2662, 830, 2689, 841, gates=[(2675, 830), (2676, 830)])
    for x, y in [(2665, 833), (2668, 837), (2681, 834), (2686, 839), (2672, 839)]:
        t.item(x, y, int(rng.choice(HAY)))
    t.item(2678, 836, SCARECROW)
    # windmill ridge, along the lane up from the square
    for x, y in [(2726, 775), (2740, 772), (2754, 775)]:
        t.put('windmill', x, y)
        t.wheels.append((x, y))
        t.item(x + 10, y + 7, int(rng.choice(WOOD_PILES)))
    # harbour: a pier into the bay, boats, a boathouse with crates and wood
    t.put('boathouse', 2727, 836)
    for x, y in [(2737, 843), (2738, 845), (2736, 847)]:
        t.item(x, y, int(rng.choice(CRATES + WOOD_PILES)))
    t.pier = ([(2760, 852), (2792, 852)], 1)
    t.item(2787, 856, BOAT, ground='walkable sea')
    t.item(2790, 848, BOAT, ground='walkable sea')
    for x in (2690, 2730, 2760):
        t.item(x, 803, STREET_LAMP)


def cherrygrove(t):
    """Viridian's mirror on the bay: grey stone streets, a river through town with bridges, the moon
    festival plaza, cherry trees and flower gardens, Officer Jenny's police box, Guide Gent's house
    by the east road and a beach front with a boardwalk and stalls."""
    rng = _rng(51)
    t.streets += [([(2500, 836), (2622, 836)], 2.5), ([(2552, 795), (2552, 836)], 2),
                  ([(2500, 815), (2552, 815)], 1.5), ([(2552, 836), (2552, 852), (2530, 856), (2575, 856)], 1.5)]
    t.rivers.append(([(2526, 788), (2528, 812), (2524, 836), (2527, 860), (2527, 872)], 2.2))
    t.plazas += [(2569, 836, 8), (2532, 836, 4)]
    t.put('pokecenter', 2537, 824)
    t.item(2535, 832, PC_SIGN)
    t.put('mart', 2555, 822)
    t.item(2554, 832, MART_SIGN)
    # moon festival plaza: a stage, a ring of lanterns, statues and flower beds
    t.ground(2566, 823, 2576, 826, 'wooden floor')
    for k in range(12):
        a = k / 12 * 6.283
        t.item(int(round(2569 + np.cos(a) * 7)), int(round(836 + np.sin(a) * 6)), LANTERN)
    t.item(2565, 840, STATUE)
    t.item(2573, 840, STATUE)
    for x in range(2557, 2569, 2):
        t.item(x, 848, FLOWERS[x % len(FLOWERS)])
    # homes: doors to the south face the street below them, doors to the north the one above
    t.put('viridian-202', 2580, 820)
    t.put('viridian-210', 2594, 821)
    t.put('viridian-201', 2580, 841)
    t.put('viridian-209', 2598, 841)
    t.put('viridian-206', 2504, 841)
    t.put('viridian-205', 2502, 800)
    t.put('viridian-212', 2505, 820)
    t.put('viridian-211', 2532, 801)
    t.put('viridian-198', 2556, 800)
    t.put('viridian-208', 2534, 840)
    t.put('police-box', 2610, 821)
    t.item(2608, 833, STREET_SIGN)
    t.put('guide-gent', 2612, 841)
    # cherry trees along the river
    for y in range(795, 860, 6):
        for x in (2520, 2533):
            if t.free_tile(x, y):
                t.item(x, y, CHERRY_TREE)
    # beach front: boardwalk, parasols and stalls; rocky islets in the bay
    t.boardwalk = ([(2530, 862), (2580, 862)], 1)
    for x in range(2534, 2580, 6):
        t.item(x, 866, int(rng.choice(PARASOLS)), ground='sand')
        t.item(x + 2, 860, int(rng.choice(CRATES)))
    t.islets += [(2546, 884, 3), (2565, 880, 2.5), (2588, 890, 3.5)]


def violet(t):
    """Pewter's mirror: an old town with Sprout Tower on an island in a moat north of the square,
    the Pokémon Academy and its schoolyard, the theatre, a market lane in the old town, homes in
    the suburbs and the Gym."""
    rng = _rng(52)
    t.streets += [([(2440, 566), (2552, 566)], 2.5), ([(2499, 538), (2499, 612)], 2.5),
                  ([(2440, 590), (2556, 590)], 1.5), ([(2462, 545), (2540, 545)], 1.5)]
    t.plazas.append((2499, 566, 7))
    # Sprout Tower on its island, a plank walkway over the moat
    t.ponds.append(('rect', 2485, 509, 2514, 537, 3))
    t.put('sprout-tower', 2489, 512)
    t.bridge_ns = [(2498, 2500, 534, 538)]
    t.put('pokecenter', 2508, 554)
    t.item(2507, 562, PC_SIGN)
    t.put('mart', 2520, 553)
    t.item(2530, 562, MART_SIGN)
    t.put('gym', 2470, 570)
    # the Academy and its fenced schoolyard across the street
    t.put('academy', 2516, 570)
    t.fence(2516, 594, 2535, 602, gates=[(2525, 594), (2526, 594)])
    for x in range(2519, 2534, 4):
        t.item(x, 598, BENCH_S)
    # the theatre (Comedy Grand Prix) facing the square
    t.put('theatre', 2462, 549)
    for x in range(2464, 2486, 6):
        t.item(x, 548, STREET_LAMP)
    # old town market lane
    for x in range(2506, 2540, 4):
        t.item(x, 549, int(rng.choice(PARASOLS)))
        t.item(x + 1, 542, int(rng.choice(CRATES + WOOD_PILES)))
    # homes
    t.put('pewter-246', 2518, 529)
    t.put('pewter-239', 2534, 528)
    t.put('pewter-227', 2470, 535)
    t.put('pewter-232', 2470, 594)
    t.put('pewter-235', 2448, 594)
    t.put('pewter-240', 2504, 604)
    t.put('pewter-247', 2538, 594)
    t.put('pewter-226', 2448, 571)
    t.put('pewter-228', 2458, 571)
    t.put('pewter-229', 2447, 580)
    t.put('pewter-230', 2458, 581)
    for x in (2475, 2490, 2535, 2545):
        t.item(x, 562, STREET_LAMP)


def azalea(t):
    """Cerulean's mirror: Kurt's house and its Apricorn grove in the north-west, the charcoal kiln
    yard, a river with bridges, the Slowpoke Well with Slowpoke statues and offerings, Slowpoke
    crossing signs and the Gym in the south-west."""
    rng = _rng(53)
    t.streets += [([(2352, 1040), (2470, 1040)], 2.5), ([(2400, 1012), (2400, 1078)], 2),
                  ([(2356, 1060), (2400, 1060)], 1.5), ([(2352, 1078), (2400, 1078)], 1.5)]
    t.rivers.append(([(2414, 990), (2416, 1020), (2412, 1050), (2418, 1085)], 2.2))
    t.plazas.append((2394, 1040, 5))
    t.put('pokecenter', 2386, 1028)
    t.item(2384, 1036, PC_SIGN)
    t.put('mart', 2370, 1027)
    t.item(2368, 1036, MART_SIGN)
    t.put('gym', 2354, 1044)
    # Kurt's house in the fenced Apricorn grove
    t.fence(2350, 996, 2382, 1024, gates=[(2366, 1024), (2367, 1024)])
    t.put('kurts-house', 2358, 1006)
    for x, y in [(2353, 999), (2357, 1001), (2377, 1001), (2379, 1006), (2353, 1012), (2377, 1012),
                 (2354, 1019), (2378, 1018)]:
        t.item(x, y, RED_TREE if (x + y) % 2 else YELLOW_TREE)
    # charcoal kiln yard
    t.ground(2385, 1046, 2397, 1056, 'dirt')
    for k, x in enumerate(range(2386, 2397, 3)):
        t.item(x, 1047, FURNACES[k % len(FURNACES)])
        t.item(x, 1052, int(rng.choice(WOOD_PILES)))
    t.item(2396, 1055, CAMPFIRE)
    # Slowpoke Well: water in a stone ring on a stone square, Slowpoke statues and flowers as offerings
    t.ground(2402, 1072, 2410, 1080, 'gray stone tiles')
    t.ground(2405, 1075, 2406, 1076, 'walkable sea')
    t.block(2404, 1074, 2407, 1077)
    for x, y in [(2404, 1074), (2407, 1074), (2404, 1077), (2407, 1077)]:
        t.item(x, y, FENCE_V)
    t.item(2403, 1073, CAT_STATUE)
    t.item(2409, 1073, CAT_STATUE)
    for x in (2403, 2409):
        t.item(x, 1079, FLOWERS[x % len(FLOWERS)])
    t.item(2402, 1081, SIGN)
    for x, y in [(2380, 1037), (2410, 1037), (2397, 1066)]:
        t.item(x, y, STREET_SIGN)
    # homes
    t.put('cerulean-272', 2384, 1008)
    t.put('cerulean-276', 2370, 1044)
    t.put('cerulean-275', 2432, 1026)
    t.put('cerulean-278', 2448, 1025)
    t.put('cerulean-271', 2432, 1045)
    t.put('cerulean-277', 2448, 1045)
    t.put('cerulean-279', 2421, 1060)
    t.put('cerulean-282', 2354, 1064)
    t.put('cerulean-284', 2372, 1063)


LAYOUTS = {50: new_bark, 51: cherrygrove, 52: violet, 53: azalea}


def layout(spec, sizes, strict=True):
    t = Town(spec, sizes)
    t.pier = t.boardwalk = None
    t.bridge_ns = []
    LAYOUTS[spec['town_id']](t)
    if strict and t.errors:
        raise ValueError('%s: %s' % (spec['name'], '; '.join(t.errors)))
    return t
