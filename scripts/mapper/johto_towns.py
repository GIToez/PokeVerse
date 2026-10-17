"""Johto's towns as approved in the design proposal: what each one copies from its Kanto mirror
(New Bark from Pallet, Cherrygrove from Viridian, Violet from Pewter, Azalea from Cerulean,
Goldenrod from Saffron and Celadon, Ecruteak from Fuchsia, Olivine from Vermilion, Cianwood from Cinnabar,
Mahogany and Blackthorn from Lavender),
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
    # Saffron City and Celadon City (Goldenrod)
    **{'saffron-%d' % h: {'box': b} for h, b in [
        (292, (3919, 491, 3933, 505)), (293, (3903, 490, 3917, 504)), (294, (3914, 505, 3929, 517)),
        (295, (3942, 495, 3955, 510)), (296, (3939, 458, 3951, 469)), (297, (3927, 447, 3942, 457)),
        (298, (3926, 457, 3939, 467)), (299, (3903, 459, 3916, 469)), (300, (3904, 442, 3916, 453)),
        (301, (3903, 469, 3915, 481)), (302, (3889, 470, 3903, 482)), (303, (3888, 493, 3903, 506)),
        (304, (3956, 500, 3971, 515)), (305, (3961, 478, 3975, 492)), (306, (3971, 500, 3986, 514)),
        (307, (3983, 459, 3996, 471))]},
    **{'celadon-%d' % h: {'box': b} for h, b in [
        (248, (3687, 451, 3698, 464)), (249, (3674, 449, 3687, 461)), (250, (3708, 450, 3720, 463)),
        (251, (3720, 441, 3735, 453)), (252, (3719, 420, 3734, 433)), (253, (3693, 416, 3705, 429)),
        (254, (3705, 406, 3721, 419)), (255, (3672, 429, 3684, 441)), (256, (3661, 429, 3672, 441)),
        (257, (3679, 464, 3696, 478)), (258, (3645, 450, 3659, 465)), (259, (3623, 454, 3637, 467)),
        (260, (3637, 465, 3650, 479)), (261, (3634, 418, 3651, 433)), (262, (3638, 404, 3654, 418))]},
    # Fuchsia City (Ecruteak), Vermilion City (Olivine) and Cinnabar Island (Cianwood)
    **{'fuchsia-%d' % h: {'box': b} for h, b in [
        (357, (3835, 854, 3847, 866)), (358, (3856, 858, 3867, 870)), (359, (3867, 860, 3878, 872)),
        (360, (3855, 870, 3866, 882)), (361, (3886, 855, 3898, 867)), (362, (3898, 857, 3908, 868)),
        (363, (3885, 867, 3897, 878)), (364, (3874, 835, 3886, 846)), (365, (3875, 824, 3888, 835)),
        (367, (3852, 827, 3866, 838)), (369, (3867, 802, 3880, 815)), (370, (3880, 804, 3891, 815)),
        (371, (3891, 803, 3902, 816)), (372, (3902, 802, 3914, 815))]},
    **{'vermilion-%d' % h: {'box': b} for h, b in [
        (331, (3969, 657, 3981, 670)), (332, (3982, 655, 3995, 668)), (333, (3995, 653, 4005, 666)),
        (334, (3987, 628, 3999, 640)), (337, (3970, 598, 3982, 610)), (338, (3957, 599, 3970, 611)),
        (341, (3934, 605, 3947, 617)), (342, (3922, 604, 3933, 616)), (344, (3905, 652, 3918, 666))]},
    **{'cinnabar-%d' % h: {'box': b} for h, b in [
        (376, (3376, 1040, 3387, 1053)), (378, (3359, 1022, 3372, 1032)), (380, (3344, 1018, 3355, 1027)),
        (381, (3325, 1039, 3339, 1051)), (382, (3326, 1027, 3338, 1039)), (383, (3374, 1008, 3388, 1018)),
        (386, (3387, 1037, 3398, 1046))]},
    # Lavender Town (Mahogany and Blackthorn)
    **{'lavender-%d' % h: {'box': b} for h, b in [
        (308, (4168, 539, 4179, 549)), (309, (4161, 557, 4172, 567)), (310, (4188, 566, 4202, 579)),
        (311, (4208, 555, 4222, 568)), (312, (4210, 534, 4224, 548)), (313, (4186, 530, 4200, 544)),
        (314, (4155, 535, 4168, 547)), (315, (4143, 555, 4155, 567)), (316, (4145, 567, 4156, 580)),
        (317, (4160, 586, 4175, 598)), (318, (4175, 587, 4188, 601)), (319, (4189, 591, 4205, 605))]},
    # Landmarks: Kanto buildings standing in for Johto's, not for rent.
    'sprout-tower': {'box': (3872, 238, 3893, 258), 'rent': False},
    'academy': {'box': (3260, 520, 3279, 537), 'rent': False},
    'theatre': {'box': (3323, 292, 3348, 303), 'rent': False},
    'kurts-house': {'box': (3848, 270, 3863, 283), 'rent': False},
    'guide-gent': {'box': (3286, 607, 3296, 616), 'rent': False},
    # Goldenrod: Saffron's six-storey guild hall as the Radio Tower, Celadon's department store, its
    # guild hall as the Global Terminal and Saffron's café as the Game Corner.
    'radio-tower': {'box': (3997, 455, 4014, 472), 'rent': False},
    'global-terminal': {'box': (3720, 457, 3737, 474), 'rent': False},
    'dept-store': {'box': (3678, 399, 3698, 414), 'walled': False, 'door': 9, 'rent': False},
    'game-corner': {'box': (3956, 443, 3970, 453), 'walled': False, 'door': 0, 'rent': False},
    # Ecruteak: Fuchsia's five-storey walled hall as the Bell Tower, its guild hall round an open,
    # overgrown court as the Burned Tower. Vermilion's round guild hall on its hill as the Olivine
    # Lighthouse, and Cinnabar's lab as Cianwood's Pharmacy.
    'bell-tower': {'box': (3851, 802, 3863, 817), 'walled': False, 'door': 10, 'rent': False},
    'burned-tower': {'box': (3814, 794, 3834, 810), 'rent': False},
    'lighthouse': {'box': (3890, 568, 3910, 589), 'z': 6, 'rent': False},
    'pharmacy': {'box': (3355, 1001, 3372, 1012), 'walled': False, 'door': 9, 'rent': False},
    # Mahogany's souvenir shop: Lavender's little house with the stairs down
    'souvenir-shop': {'box': (4142, 530, 4153, 540), 'walled': False, 'door': 3, 'rent': False},
    # the Ruins of Alph research center: a Celadon building
    'ruins-lab': {'box': (3638, 404, 3654, 418), 'rent': False},
    # the Route 34 Day-Care: Pallet's house without its walls' ring, like the police box
    'daycare': {'box': (3302, 790, 3314, 799), 'walled': False, 'door': 5, 'rent': False},
    # Pallet's house and cottage without their walls' ring (the door is below the box, `door` its
    # first column): Officer Jenny's police box, the boathouse and the windmills (a wheel on the roof).
    # The Safari Zone's warden's office (a Vermilion house).
    'safari-gate': {'box': (3972, 621, 3987, 634), 'rent': False},
    'police-box': {'box': (3302, 790, 3314, 799), 'walled': False, 'door': 5, 'rent': False},
    'boathouse': {'box': (3302, 804, 3310, 813), 'walled': False, 'door': 3, 'rent': False},
    'windmill': {'box': (3302, 804, 3310, 813), 'walled': False, 'door': 3, 'rent': False},
    # The Battle Frontier's five facilities, none of them houses, so `entries` are where their doors
    # open (relative to the box, the tile outside): Saffron's four-storey office as the Battle Tower
    # (its gate in the south-east corner), Vermilion's metal works as the Battle Factory, Celadon's
    # slot machines and card tables as the Battle Arcade, Cerulean's pillared hall round its pool as
    # the Battle Hall and Saffron's colonnade round its fountains as the Battle Castle. They are
    # `enclosed`: the rockery in the Tower's corner and the Factory's indoor pool are copied too.
    'battle-tower': {'box': (3867, 479, 3887, 494), 'entries': [(18, 16), (19, 16)], 'enclosed': True, 'rent': False},
    # Kanto's works are entered from below (the stairs in from the basement are not copied), so a
    # doorway is opened (`open`) from the room inside the door up into the hall
    'battle-factory': {'box': (3920, 654, 3938, 669), 'entries': [(19, 11), (19, 12)], 'open': [(14, 9)],
                       'enclosed': True, 'rent': False},
    'battle-arcade': {'box': (3622, 435, 3638, 452), 'entries': [(17, 3), (17, 4)], 'enclosed': True, 'rent': False},
    'battle-hall': {'box': (3910, 255, 3929, 273), 'entries': [(8, 18), (9, 18), (17, 2)], 'enclosed': True,
                    'rent': False},
    'battle-castle': {'box': (3957, 454, 3981, 469), 'entries': [(7, 13), (8, 13)], 'enclosed': True, 'rent': False},
}

# Decoration (item ids), none of which players can pick up or move. Fences go like Pallet's: a post
# in the top-left corner, rails along the top and bottom, side pieces and a post bottom-right.
FENCE_TOP_LEFT, FENCE_H, FENCE_V, FENCE_BOTTOM_RIGHT = 1533, 1536, 1534, 1535
STREET_LAMP = 1479
LANTERN = 3743
# Kanto's white benches, two tiles each: west and east halves, or north and south halves
BENCH_W, BENCH_E, BENCH_N, BENCH_S = 18103, 18104, 18105, 18106
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
TRAPDOOR = 369
# Mahogany's souvenir shop, and the floor tiles by its east wall that become the stairs down to the
# Rocket Hideout (build_johto.UNDERGROUND lines the hideout's stairs up with them)
SOUVENIR_SHOP = (2569, 378)
SHOP_STAIRS = [(SOUVENIR_SHOP[0] + 10, SOUVENIR_SHOP[1] + 7), (SOUVENIR_SHOP[0] + 10, SOUVENIR_SHOP[1] + 8)]
# Goldenrod's Magnet Train station: the top of its stairway down, off the north avenue
# (build_johto.UNDERGROUND brings Cerulean's walled stairway, landing and station under it)
TRAIN_STAIRS = (2330, 660)
TRAIN_STEPS = 3220
TRAIN_RAILING = {(-1, -2): 1528, (0, -2): 1524, (1, -2): 1524, (1, -1): 1526, (1, 0): 1526, (1, 1): 1526,
                 (-1, 2): 1528, (0, 2): 1524, (1, 2): 1530}


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
        self.areas = []  # (x0, y0, x1, y1) kept clear of wild trees, like the ground around the streets
        self.raw = {}  # (x, y) -> ground item put in as it is (a trapdoor), not drawn from a brush
        self.stairs_down = []  # (x, y) floor tiles inside a building that become stairs down

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

    def bench(self, x, y, upright=False):
        """A bench from (x, y) one tile east (or, upright, south)."""
        dx, dy = (0, 1) if upright else (1, 0)
        if not self.free_tile(x + dx, y + dy):
            x, y = x - dx, y - dy
        self.item(x, y, BENCH_N if upright else BENCH_W)
        self.item(x + dx, y + dy, BENCH_S if upright else BENCH_E)

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


def _seg_dist(x, y, a, b):
    (ax, ay), (bx, by) = a, b
    vx, vy = bx - ax, by - ay
    k = min(1.0, max(0.0, ((x - ax) * vx + (y - ay) * vy) / max(1, vx * vx + vy * vy)))
    return float(np.hypot(x - (ax + k * vx), y - (ay + k * vy)))


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
    t.bench(2671, 799)
    t.bench(2677, 799)
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
        t.bench(x, 598)
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
    yard, a river with bridges, the Slowpoke Well (a trapdoor down) with Slowpoke statues and offerings, Slowpoke
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
    # the way down into the well, on the ring's south side
    t.item(2405, 1077)
    t.raw[(2405, 1077)] = TRAPDOOR
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


def goldenrod(t):
    """Saffron's mirror, with Celadon's department store: the big city of the region, a paved grid
    of two avenues crossing at a square with a round fountain and a ring of side streets. The Radio Tower to the
    north-east, the department store and Game Corner across from Whitney's Gym and the Pokémon
    Center, the Global Terminal by the south gate, a flower shop and its gardens, and a harbour on
    the bay in the south-west."""
    rng = _rng(54)
    t.streets += [([(2320, 662), (2320, 800)], 3), ([(2248, 730), (2396, 730)], 3),
                  ([(2272, 690), (2368, 690)], 2), ([(2250, 770), (2368, 770)], 2),
                  ([(2272, 690), (2272, 770)], 2), ([(2368, 690), (2368, 770)], 2)]
    t.plazas.append((2320, 730, 9))
    # the round fountain on the square: a basin in a stone ring, lamps round it, and flower beds
    # between the avenues
    for x in range(2315, 2326):
        for y in range(725, 736):
            d = np.hypot(x - 2320, y - 730)
            if d < 2.6:
                t.ground(x, y, x, y, 'walkable sea')
            elif d < 4.2:
                t.ground(x, y, x, y, 'small tiled gray stone')
    t.block(2316, 726, 2324, 734)
    for x, y in [(2317, 727), (2323, 727), (2317, 733), (2323, 733)]:
        t.item(x, y, STREET_LAMP)
    # north of the first street: the Radio Tower and homes
    t.put('radio-tower', 2340, 668)
    t.item(2338, 686, SIGN)
    # the Magnet Train's stairway down at the head of the avenue: Cerulean's stone railing round its
    # two steps, open to the west, on a paved forecourt joined to the avenue
    sx, sy = TRAIN_STAIRS
    t.ground(sx - 13, sy - 6, sx + 3, sy + 5, 'gray stone tiles')
    t.block(sx - 2, sy - 5, sx + 3, sy + 5)
    for (dx, dy), railing in TRAIN_RAILING.items():
        t.item(sx + dx, sy + dy, railing)
    for dy in (0, 1):
        t.item(sx, sy + dy)
        t.raw[(sx, sy + dy)] = TRAIN_STEPS
    t.item(sx - 2, sy - 3, SIGN)
    for x, y in [(sx - 13, sy - 6), (sx + 3, sy - 6), (sx + 3, sy + 5)]:
        t.item(x, y, STREET_LAMP)
    t.put('saffron-300', 2276, 674)
    t.put('saffron-305', 2295, 671)
    # north-west block: homes along the first street, then the Pokémon Center, Mart and Gym on the avenue
    t.put('saffron-292', 2276, 694)
    t.put('saffron-303', 2296, 694)
    t.put('pokecenter', 2278, 718)
    t.item(2276, 726, PC_SIGN)
    t.put('mart', 2289, 717)
    t.item(2298, 726, MART_SIGN)
    t.put('gym', 2301, 713)
    # north-east block: homes, the department store and the Game Corner
    t.put('celadon-249', 2326, 694)
    t.put('celadon-260', 2347, 694)
    t.put('dept-store', 2326, 710)
    t.put('game-corner', 2349, 715)
    # south blocks: homes facing the main street and the third street
    t.put('saffron-293', 2277, 734)
    t.put('celadon-258', 2298, 734)
    t.put('saffron-307', 2277, 755)
    t.put('celadon-256', 2300, 755)
    t.put('saffron-306', 2326, 734)
    t.put('saffron-304', 2347, 734)
    t.put('celadon-252', 2326, 754)
    t.put('saffron-302', 2347, 755)
    # west of the ring, facing the west street; east of it, facing the east street
    t.put('saffron-294', 2254, 695)
    t.put('celadon-257', 2252, 740)
    t.put('saffron-297', 2371, 694)
    t.put('celadon-251', 2371, 708)
    t.put('saffron-295', 2371, 736)
    t.put('celadon-250', 2371, 755)
    # by the south gate: the Global Terminal, and the flower shop with its fenced gardens
    t.put('global-terminal', 2324, 776)
    t.put('celadon-255', 2300, 776)
    t.fence(2276, 775, 2296, 791, gates=[(2296, 781), (2296, 782)])
    for y in range(778, 790, 3):
        for x in range(2279, 2294):
            t.item(x, y, FLOWERS[(x + y) % len(FLOWERS)], ground='dirt')
    # harbour: a pier from the third street into the bay, boats and crates
    t.pier = ([(2250, 770), (2226, 770)], 1)
    for x, y in [(2253, 765), (2255, 776), (2258, 776)]:
        t.item(x, y, int(rng.choice(CRATES + WOOD_PILES)))
    t.item(2231, 766, BOAT, ground='walkable sea')
    t.item(2236, 775, BOAT, ground='walkable sea')
    # street lamps along the avenues, benches round the square, trees in planters
    for y in range(676, 800, 12):
        for x in (2316, 2324):
            if t.free_tile(x, y) and not 724 <= y <= 736:
                t.item(x, y, STREET_LAMP)
    for x in range(2256, 2396, 12):
        for y in (726, 734):
            if t.free_tile(x, y) and not 2310 <= x <= 2330:
                t.item(x, y, STREET_LAMP)
    for x, y in [(2311, 727), (2328, 727), (2311, 733), (2328, 733)]:
        t.bench(x, y)
    for cx, cy in [(2315, 725), (2325, 725), (2315, 735), (2325, 735)]:
        for dx, dy in [(0, 0), (1, 0), (0, 1), (-1, 0), (0, -1)]:
            x, y = cx + dx, cy + dy
            if abs(x - 2320) > 3 and abs(y - 730) > 3 and t.free_tile(x, y):
                t.item(x, y, FLOWERS[(x + y) % len(FLOWERS)])


def national_park(t):
    """A walled park on lawn: gray stone walks crossing at a fountain, flower beds, benches and lamps,
    rows of trees along the walks and the contest grass around them. Gates south (Route 35),
    east (Route 36) and north (Route 37)."""
    t.streets += [([(2325, 618), (2325, 556)], 1.5), ([(2290, 588), (2362, 588)], 1.5)]
    t.plazas.append((2325, 588, 6))
    t.areas.append((2287, 557, 2363, 617))
    t.fence(2286, 556, 2364, 618, gates=[(2324, 618), (2325, 618), (2326, 618),
                                         (2364, 587), (2364, 588), (2364, 589),
                                         (2324, 556), (2325, 556), (2326, 556)])
    t.ground(2323, 586, 2327, 590, 'small tiled gray stone')
    t.ground(2324, 587, 2326, 589, 'walkable sea')
    t.block(2323, 586, 2327, 590)
    t.item(2325, 588, STATUE)
    for x, y in [(2323, 586), (2327, 586), (2323, 590), (2327, 590)]:
        t.item(x, y, STREET_LAMP)
    for k in range(10):
        a = k / 10 * 6.283
        x, y = int(round(2325 + np.cos(a) * 9)), int(round(588 + np.sin(a) * 9))
        if t.free_tile(x, y):
            t.item(x, y, FLOWERS[k % len(FLOWERS)])
    for x in range(2296, 2360, 8):
        for y in (584, 592):
            if abs(x - 2325) > 8:
                if (x // 8) % 2:
                    t.bench(x, y)
                else:
                    t.item(x, y, STREET_LAMP)
    for y in range(564, 616, 8):
        for x in (2321, 2329):
            if abs(y - 588) > 8:
                t.item(x, y, CHERRY_TREE)
    # a ring of trees inside the wall, and a flower bed in each quarter
    for x in range(2290, 2362, 6):
        for y in (560, 614):
            if abs(x - 2325) > 4:
                t.item(x, y, RED_TREE if (x // 6) % 2 else YELLOW_TREE)
    for y in range(566, 612, 6):
        for x in (2290, 2360):
            if abs(y - 588) > 4:
                t.item(x, y, RED_TREE if (y // 6) % 2 else YELLOW_TREE)
    for cx, cy in [(2305, 572), (2345, 572), (2305, 604), (2345, 604)]:
        for x in range(cx - 4, cx + 5):
            for y in (cy - 1, cy + 1):
                t.item(x, y, FLOWERS[(x + y) % len(FLOWERS)], ground='dirt')


def ruins_of_alph(t):
    """The ruins on their plateau: sandstone courts with broken stones and statues in front of four
    chambers cut into rock mounds, and the research center by the path in from Route 36."""
    t.streets += [([(2410, 600), (2410, 628), (2440, 641), (2486, 652)], 1.5)]
    t.areas.append((2380, 604, 2470, 668))
    t.put('ruins-lab', 2372, 606)
    courts = [(2392, 634), (2414, 652), (2436, 628), (2444, 656)]
    for x0, y0 in courts:
        t.ground(x0, y0, x0 + 8, y0 + 5, 'tiled sandstone floor')
        t.block(x0 - 1, y0 - 14, x0 + 9, y0 + 6)  # the court and the mound behind it
        for dx, dy in [(0, 0), (8, 0), (0, 5), (8, 5)]:
            t.item(x0 + dx, y0 + dy, int(3729 + (x0 + dx + y0) % 4))
        t.item(x0 + 2, y0 + 3, STATUE)
        t.item(x0 + 6, y0 + 3, STATUE)
    # broken stones strewn over the plateau, off the path
    street = t.streets[-1][0]
    rng = _rng(55)
    for _ in range(60):
        x, y = int(rng.integers(2382, 2468)), int(rng.integers(606, 666))
        near_path = min(_seg_dist(x, y, a, b) for a, b in zip(street, street[1:])) < 4
        if not near_path and all(t.free_tile(x + dx, y + dy) for dx in range(-2, 3) for dy in range(-2, 3)):
            t.item(x, y, int(rng.choice([3729, 3730, 3731, 3732])))


def ilex_shrine(t):
    """The shrine in a clearing beside the Ilex Forest path: a stone court with a statue, lanterns and
    flowers."""
    t.ground(2288, 939, 2296, 945, 'tiled sandstone floor')
    t.areas.append((2284, 935, 2300, 949))
    t.item(2292, 940, STATUE)
    t.item(2290, 941, LANTERN)
    t.item(2294, 941, LANTERN)
    for x in range(2289, 2296, 2):
        t.item(x, 946, FLOWERS[x % len(FLOWERS)])


def ecruteak(t):
    """Fuchsia's mirror: the old town of wooden houses on dirt streets, two streets crossed by the
    avenue from Route 37 that runs on north to the Bell Tower's gate. The Burned Tower by the north
    street, the Pokémon Center, Mart and Gym on the main street, which leads west to Route 38 and
    east to Route 42, and the Kimono Dance Theater on a lane east of the avenue. Lanterns and cherry
    trees along the avenue."""
    t.streets += [([(2264, 410), (2396, 410)], 2), ([(2280, 375), (2380, 375)], 2),
                  ([(2330, 342), (2330, 456)], 2.5)]
    t.plazas.append((2330, 410, 7))
    # north street: homes and the Burned Tower
    t.put('fuchsia-369', 2282, 358)
    t.put('fuchsia-370', 2299, 360)
    t.put('burned-tower', 2338, 355)
    t.item(2336, 373, SIGN)
    t.put('fuchsia-371', 2362, 358)
    # main street, north side: a home, the Pokémon Center and Mart, the Gym and homes east of the avenue
    t.put('fuchsia-372', 2270, 393)
    t.put('pokecenter', 2285, 399)
    t.item(2283, 407, PC_SIGN)
    t.put('mart', 2296, 398)
    t.item(2305, 407, MART_SIGN)
    t.put('fuchsia-360', 2308, 394)
    t.put('gym', 2337, 394)
    t.put('fuchsia-359', 2353, 394)
    t.put('fuchsia-361', 2367, 394)
    t.put('fuchsia-363', 2382, 395)
    # main street, south side: the homes with their doors on the street
    t.put('fuchsia-357', 2272, 414)
    t.put('fuchsia-362', 2287, 414)
    t.put('fuchsia-367', 2300, 414)
    t.put('fuchsia-365', 2337, 414)
    t.put('fuchsia-358', 2353, 414)
    t.put('fuchsia-364', 2367, 414)
    for y in range(430, 456, 6):
        for x in (2326, 2334):
            t.item(x, y, LANTERN)
    for y in range(346, 372, 6):
        for x in (2326, 2334):
            t.item(x, y, CHERRY_TREE)
    for x, y in [(2324, 403), (2335, 403), (2324, 417), (2335, 417)]:
        t.item(x, y, CHERRY_TREE)
    # the Kimono Dance Theater (Pewter's theatre) on a lane east off the avenue, lanterns along it
    t.streets.append(([(2330, 452), (2372, 452)], 1.5))
    t.put('theatre', 2340, 436)
    for x in range(2342, 2372, 6):
        t.item(x, 455, LANTERN)


def bell_tower(t):
    """The Bell Tower on its sandstone court north of Ecruteak, lanterns along the walk up from the
    town and cherry trees round the court."""
    t.put('bell-tower', 2295, 288)
    t.streets += [([(2305, 306), (2305, 322), (2330, 334), (2330, 342)], 1.5)]
    t.areas.append((2280, 280, 2322, 314))
    t.ground(2299, 305, 2311, 310, 'tiled sandstone floor')
    for x, y in [(2299, 305), (2311, 305), (2299, 310), (2311, 310)]:
        t.item(x, y, LANTERN)
    for y in range(314, 322, 4):
        t.item(2302, y, LANTERN)
        t.item(2308, y, LANTERN)
    for k in range(14):
        a = k / 14 * 6.283
        x, y = int(round(2301 + np.cos(a) * 19)), int(round(297 + np.sin(a) * 16))
        if t.free_tile(x, y) and y < 305:
            t.item(x, y, CHERRY_TREE)


def olivine(t):
    """Vermilion's mirror: the port city on the bay, the avenue from Route 39 crossing two streets.
    The Pokémon Center, Mart and Gym on the first street, the harbour street below it with the
    S.S. Aqua's dock, a sandy market square by it, a pier with boats to the west and the Lighthouse
    on its point to the south-west, at the start of Route 40."""
    rng = _rng(56)
    t.streets += [([(2140, 466), (2140, 526)], 2), ([(2100, 500), (2186, 500)], 2),
                  ([(2100, 524), (2182, 524)], 2), ([(2100, 524), (2100, 561), (2084, 561)], 1.5)]
    t.plazas.append((2140, 500, 6))
    t.put('vermilion-338', 2090, 484)
    t.put('pokecenter', 2106, 489)
    t.item(2104, 497, PC_SIGN)
    t.put('mart', 2117, 488)
    t.item(2126, 497, MART_SIGN)
    t.put('gym', 2145, 484)
    t.put('vermilion-334', 2161, 484)
    t.put('vermilion-337', 2176, 484)
    # between the streets: homes with their doors on the first street
    t.put('vermilion-331', 2104, 504)
    t.put('vermilion-333', 2119, 504)
    t.put('vermilion-332', 2145, 504)
    t.put('vermilion-344', 2161, 504)
    # harbour street: homes, the dock and the Lighthouse
    t.put('vermilion-341', 2146, 528)
    t.put('vermilion-342', 2163, 528)
    t.put('lighthouse', 2076, 536)
    t.item(2098, 557, SIGN)
    # the S.S. Aqua's pier, between the two homes; the ship (build_johto.py's SHIP) moors at its end
    t.boardwalk = ([(2161, 526), (2161, 571)], 1)
    t.pier = ([(2100, 500), (2074, 500)], 1)
    t.item(2082, 496, BOAT, ground='walkable sea')
    t.item(2086, 504, BOAT, ground='walkable sea')
    t.item(2118, 548, BOAT, ground='walkable sea')
    for x, y in [(2127, 528), (2127, 532), (2134, 530), (2134, 536)]:
        t.item(x, y, int(rng.choice(CRATES + WOOD_PILES)))
    for x in range(2108, 2184, 12):
        for y in (496, 520):
            if t.free_tile(x, y) and not 2134 <= x <= 2146:
                t.item(x, y, STREET_LAMP)
    # the harbour market: a sandy square below the harbour street, stalls under parasols and crates
    for x in range(2106, 2125):
        for y in range(527, 537):
            if np.hypot((x - 2115) / 8.5, (y - 531.5) / 5) < 1:
                t.ground(x, y, x, y, 'sand')
    for x, y in [(2110, 529), (2115, 528), (2120, 529), (2109, 534), (2121, 534)]:
        t.item(x, y, PARASOLS[(x + y) % len(PARASOLS)])
    for x, y in [(2111, 530), (2116, 529), (2119, 530)]:
        t.item(x, y, int(rng.choice(CRATES)))


def moomoo_farm(t):
    """The Moomoo Farm on Route 39: the farmhouse and a fenced pasture with hay and a scarecrow."""
    t.put('house', 2098, 412)
    t.streets += [([(2104, 425), (2140, 425)], 1)]
    t.areas.append((2090, 410, 2130, 456))
    t.fence(2094, 428, 2126, 454, gates=[(2126, 440), (2126, 441), (2103, 428), (2104, 428)])
    rng = _rng(57)
    for _ in range(14):
        x, y = int(rng.integers(2097, 2124)), int(rng.integers(431, 452))
        if all(t.free_tile(x + dx, y + dy) for dx in (-1, 0, 1) for dy in (-1, 0, 1)):
            t.item(x, y, int(rng.choice(HAY)))
    t.item(2110, 442, SCARECROW)


def cianwood(t):
    """Cinnabar's mirror: the island town at the end of Route 41, two streets crossed by the avenue,
    the Pokémon Center, Mart and the Pharmacy on the first street, the Gym on the second and a pier
    out to the sea route in the east."""
    t.streets += [([(1925, 616), (1925, 690)], 2), ([(1888, 640), (1962, 640)], 2),
                  ([(1890, 676), (1960, 676)], 2)]
    t.plazas.append((1925, 640, 6))
    t.put('pokecenter', 1897, 629)
    t.item(1895, 637, PC_SIGN)
    t.put('mart', 1909, 628)
    t.item(1918, 637, MART_SIGN)
    t.put('pharmacy', 1930, 625)
    t.put('cinnabar-376', 1893, 644)
    t.put('cinnabar-380', 1908, 644)
    t.put('cinnabar-386', 1930, 644)
    t.put('cinnabar-383', 1893, 662)
    t.put('gym', 1930, 660)
    t.put('cinnabar-378', 1891, 680)
    t.put('cinnabar-381', 1907, 680)
    t.put('cinnabar-382', 1946, 680)
    t.pier = ([(1962, 640), (1986, 640)], 1)
    t.item(1980, 636, BOAT, ground='walkable sea')
    for x, y in [(1950, 630), (1955, 652), (1950, 668)]:
        t.item(x, y, PARASOLS[x % len(PARASOLS)])


def mahogany(t):
    """Lavender's mirror: the small town between Mt. Mortar and the Ice Path. The main street runs
    from Route 42 to Route 44 and the avenue north to Route 43 and the Lake of Rage. The Pokémon
    Center, Mart and souvenir shop (stairs down to the Rocket Hideout) on the main street, the Gym
    behind it."""
    t.streets += [([(2520, 392), (2586, 392)], 2), ([(2550, 345), (2550, 424)], 2)]
    t.plazas.append((2550, 392, 6))
    t.put('pokecenter', 2527, 381)
    t.item(2525, 389, PC_SIGN)
    t.put('mart', 2537, 380)
    t.item(2546, 389, MART_SIGN)
    t.put('lavender-308', 2555, 378)
    t.put('souvenir-shop', *SOUVENIR_SHOP)
    t.stairs_down += SHOP_STAIRS
    t.put('lavender-314', 2532, 362)
    t.put('gym', 2558, 360)
    t.put('lavender-310', 2576, 358)
    t.put('lavender-317', 2522, 396)
    t.put('lavender-318', 2555, 396)
    t.put('lavender-309', 2572, 400)
    for y in range(400, 424, 6):
        t.item(2546, y, LANTERN)
        t.item(2554, y, LANTERN)


def blackthorn(t):
    """Lavender's mirror as the dragon tamers' town under the mountains: the main street from the
    Ice Path's exit, the avenue south to Route 45, the Gym on the main street and Dragon's Den
    behind it, a pond with the dragon shrine on its islet."""
    t.streets += [([(2706, 388), (2776, 388)], 2), ([(2742, 336), (2742, 420)], 2),
                  ([(2742, 336), (2758, 336)], 1)]
    t.plazas.append((2742, 388, 6))
    t.put('pokecenter', 2718, 377)
    t.item(2716, 385, PC_SIGN)
    t.put('mart', 2729, 376)
    t.item(2738, 385, MART_SIGN)
    t.put('gym', 2746, 372)
    t.put('lavender-313', 2762, 370)
    t.put('lavender-312', 2724, 352)
    t.put('lavender-311', 2746, 352)
    t.put('lavender-319', 2718, 392)
    t.put('lavender-315', 2746, 392)
    t.put('lavender-316', 2762, 392)
    # Dragon's Den: the pond and the shrine on its islet, reached by Surf
    cx, cy = 2770, 335
    for x in range(cx - 9, cx + 10):
        for y in range(cy - 9, cy + 10):
            d = np.hypot(x - cx, y - cy)
            if d < 3:
                t.ground(x, y, x, y, 'tiled sandstone floor')
            elif d < 9:
                t.ground(x, y, x, y, 'walkable sea')
    t.block(cx - 9, cy - 9, cx + 9, cy + 9)
    t.item(cx, cy, STATUE)
    t.item(cx - 1, cy + 1, LANTERN)
    t.item(cx + 1, cy + 1, LANTERN)


WILD_TREES = [2700, 2702, 2703, 2707, 2708]
BOULDERS = [3607, 1285, 3615, 3616]
SAFARI_BUSHES = [2767, 2768]
SAFARI_PLANTS = [6216, 6217, 6218, 6219, 3610, 3611, 3612, 3613, 2740, 2742]
SNOWY_FIR = 2698


def _shrine(t, cx, cy, w, h, statue=STATUE):
    """A sandstone court with a statue in the middle and a lantern at each corner."""
    t.ground(cx - w, cy - h, cx + w, cy + h, 'tiled sandstone floor')
    t.areas.append((cx - w - 4, cy - h - 4, cx + w + 4, cy + h + 4))
    t.item(cx, cy, statue)
    for x, y in [(cx - w, cy - h), (cx + w, cy - h), (cx - w, cy + h), (cx + w, cy + h)]:
        t.item(x, y, LANTERN)


def safari_zone(t):
    """The Safari Zone at the end of Route 47: the warden's office on the street, a fenced reserve
    behind it with a sand flat, a marsh pond, a grove and a rocky corner around the open grass,
    where its Pokémon spawn."""
    rng = _rng(47)
    t.streets += [([(1772, 570), (1830, 570)], 2), ([(1810, 570), (1810, 546)], 1)]
    t.put('safari-gate', 1787, 552)
    t.item(1806, 568, SIGN)
    x0, y0, x1, y1 = 1752, 470, 1838, 546
    t.areas.append((x0 + 1, y0 + 1, x1 - 1, y1 - 1))
    t.fence(x0, y0, x1, y1, gates=[(1809, y1), (1810, y1), (1811, y1)])
    t.ground(1756, 474, 1784, 498, 'sand')
    for _ in range(10):
        x, y = int(rng.integers(1758, 1783)), int(rng.integers(476, 497))
        if t.free_tile(x, y):
            t.item(x, y, int(rng.choice(BOULDERS)))
    cx, cy = 1818, 492
    for x in range(cx - 9, cx + 10):
        for y in range(cy - 7, cy + 8):
            if np.hypot((x - cx) / 9.0, (y - cy) / 7.0) < 1:
                t.ground(x, y, x, y, 'walkable sea')
    t.block(cx - 9, cy - 7, cx + 9, cy + 7)
    for _ in range(26):
        x, y = int(rng.integers(1756, 1784)), int(rng.integers(512, 542))
        if all(t.free_tile(x + dx, y + dy) for dx in (-1, 0, 1) for dy in (-1, 0, 1)):
            t.item(x, y, int(rng.choice(WILD_TREES)))
    for _ in range(12):
        x, y = int(rng.integers(1820, 1836)), int(rng.integers(522, 542))
        if t.free_tile(x, y):
            t.item(x, y, int(rng.choice(BOULDERS)))
    # copses and thickets across the open grass: solid clumps, each well clear of the others, the
    # fence, the pond and the way in from the gate, so the grass still runs all round every one
    for gx, gy in [(1795, 480), (1790, 508), (1802, 530), (1771, 508), (1826, 513), (1776, 534)]:
        r = float(rng.uniform(3.5, 5))
        for x in range(int(gx - r), int(gx + r) + 1):
            for y in range(int(gy - r), int(gy + r) + 1):
                if abs(x - 1810) < 3 or not (x0 + 3 <= x <= x1 - 3 and y0 + 3 <= y <= y1 - 3):
                    continue
                if np.hypot(x - gx, y - gy) > r * float(rng.uniform(0.75, 1.05)) or rng.random() < 0.12:
                    continue
                if t.free_tile(x, y):
                    t.item(x, y, int(rng.choice(WILD_TREES)) if rng.random() < 0.55 else int(rng.choice(SAFARI_BUSHES)))
    # gaps shut in by a copse are filled, so nothing spawns where it can't get out
    open_ = {(x, y) for x in range(x0 + 1, x1) for y in range(y0 + 1, y1) if t.free_tile(x, y)}
    while open_:
        part, todo = set(), [open_.pop()]
        while todo:
            x, y = todo.pop()
            part.add((x, y))
            for p in ((x + 1, y), (x - 1, y), (x, y + 1), (x, y - 1)):
                if p in open_:
                    open_.discard(p)
                    todo.append(p)
        if len(part) <= 6:
            for x, y in part:
                t.item(x, y, int(rng.choice(SAFARI_BUSHES)))
    for _ in range(90):
        x, y = int(rng.integers(x0 + 2, x1 - 1)), int(rng.integers(y0 + 2, y1 - 1))
        if t.free_tile(x, y) and abs(x - 1810) >= 3:
            t.item(x, y, int(rng.choice(SAFARI_PLANTS)))


def battle_frontier(t):
    """The Battle Frontier on the cliffs north-west of Olivine, as in HeartGold and SoulSilver: the
    Battle Tower at the head of a paved square with a fountain in the middle, the Battle Castle and
    Battle Arcade either side of it, the Battle Factory and Battle Hall down the avenue south, and the
    Exchange Service Corner's stalls (where Battle Points are traded) on the square. The trail from
    Route 38 comes in at the east end of the cross avenue."""
    px, py = 2008, 358
    t.streets += [([(1962, py), (2052, py)], 2), ([(px, 342), (px, 394)], 2)]
    t.put('battle-castle', 1966, 328)
    t.put('battle-tower', 1998, 326)
    t.put('battle-arcade', 2022, 326)
    t.put('battle-factory', 1972, 372)
    t.put('battle-hall', 2026, 370)
    t.plazas.append((px, py, 7))
    t.areas.append((1958, 318, 2056, 398))
    t.ground(px - 2, py - 2, px + 2, py + 2, 'small tiled gray stone')
    t.ground(px - 1, py - 1, px + 1, py + 1, 'walkable sea')
    t.block(px - 2, py - 2, px + 2, py + 2)
    t.item(px, py, STATUE)
    # the Exchange Service Corner
    for x in (px - 5, px + 5):
        t.item(x, py + 5, PARASOLS[1])
        t.item(x + 1, py + 5, CRATES[0])
    for x in range(1966, 2052, 8):
        if abs(x - px) > 8:
            t.item(x, py - 3, STREET_LAMP)
            t.item(x, py + 3, FLOWERS[(x // 8) % len(FLOWERS)])
    for y in range(346, 394, 8):
        if abs(y - py) > 8:
            t.item(px - 3, y, STREET_LAMP)
            t.item(px + 3, y, STREET_LAMP)
    t.item(2050, py - 3, SIGN)


SACRED_FLAME = [7504, 7505, 7506, 7507]  # the fire shrine, 2x2: top left, top right, bottom left, bottom right
STONE_BRAZIER = 1486
WINGED_TOTEM = 3803
# a red carpet's pieces, 3x3 in the order top left, top, top right, left, middle, right, bottom left, ...
RED_CARPET = list(range(4394, 4403))


def ho_oh_shrine():
    """The anime's Ho-Oh Shrine (Pop Goes The Sneasel), the temple grounds on Mt. Silver where the
    Sacred Flame burns, built on the summit at the end of the climb: a sandstone court, the flame at
    its north end between two statues of Ho-Oh and winged totems, a red carpet up to it lined with
    lit braziers. Returns {(dx, dy): (ground, items)} from the court's middle (between the two
    middle columns, dx -1 and 0), and where its guards stand (Machop and Machoke, as in the anime)."""
    out = {}
    for dx in range(-6, 6):
        for dy in range(-8, 7):
            out[(dx, dy)] = ('tiled sandstone floor', [])

    def put(dx, dy, *items):
        out[(dx, dy)][1].extend(items)

    for (dx, dy), item in zip([(-1, -7), (0, -7), (-1, -6), (0, -6)], SACRED_FLAME):
        put(dx, dy, item)
    for dx in (-3, 2):
        put(dx, -6, STATUE)
    for dx in (-5, 4):
        put(dx, -7, WINGED_TOTEM)
    for dy in range(-5, 7):
        row = 0 if dy == -5 else 6 if dy == 6 else 3
        for dx, col in zip(range(-2, 2), (0, 1, 1, 2)):
            put(dx, dy, RED_CARPET[row + col])
    for dx in (-3, 2):
        for dy in (-3, 0, 3):
            put(dx, dy, STONE_BRAZIER)
    for dx, dy in [(-6, -8), (5, -8), (-6, 6), (5, 6)]:
        put(dx, dy, LANTERN)
    return out, [('Machop', -4, 5), ('Machoke', 3, 5)]


def dragon_holy_land(t):
    """The Dragon Holy Land in the mountains above Blackthorn: a pond with the dragon shrine on its
    islet, lanterns on the shore."""
    cx, cy = 2802, 280
    for x in range(cx - 11, cx + 12):
        for y in range(cy - 11, cy + 12):
            d = np.hypot(x - cx, y - cy)
            if d < 3:
                t.ground(x, y, x, y, 'tiled sandstone floor')
            elif d < 10:
                t.ground(x, y, x, y, 'walkable sea')
    t.block(cx - 11, cy - 11, cx + 11, cy + 11)
    t.areas.append((cx - 15, cy - 15, cx + 15, cy + 15))
    t.item(cx, cy, STATUE)
    for k in range(8):
        a = k / 8 * 6.283
        t.item(int(round(cx + np.cos(a) * 12)), int(round(cy + np.sin(a) * 12)), LANTERN)


def lake_slowpoke(t):
    """The Slowpoke Temple's court on Lake Slowpoke's north shore, with Slowpoke statues."""
    _shrine(t, 2640, 424, 4, 3, statue=CAT_STATUE)
    t.item(2636, 428, SIGN)


def snowtop(t):
    """Snowtop Mountain's summit, where Articuno's statue stands among snowy firs."""
    _shrine(t, 2200, 214, 3, 3)
    for x, y in [(2193, 208), (2207, 208), (2193, 220), (2207, 221)]:
        t.item(x, y, SNOWY_FIR)


def mount_quena(t):
    """Mount Quena's snowy summit above the Rage Marshes, a cairn and a campfire."""
    _shrine(t, 2401, 128, 3, 2)
    t.item(2397, 132, CAMPFIRE)


LAYOUTS = {50: new_bark, 51: cherrygrove, 52: violet, 53: azalea, 54: goldenrod, 55: ecruteak, 56: olivine,
           57: cianwood, 58: mahogany, 59: blackthorn, 'National Park': national_park, 'Ruins of Alph': ruins_of_alph, 'Ilex Shrine': ilex_shrine,
           'Bell Tower': bell_tower, 'Moomoo Farm': moomoo_farm, 'Safari Zone': safari_zone,
           'Battle Frontier': battle_frontier, 'Dragon Holy Land': dragon_holy_land,
           'Lake Slowpoke': lake_slowpoke, 'Snowtop Mountain': snowtop, 'Mount Quena': mount_quena}


def layout(spec, sizes, strict=True):
    t = Town(spec, sizes)
    t.pier = t.boardwalk = None
    t.bridge_ns = []
    LAYOUTS[spec.get('town_id', spec['name'])](t)
    if strict and t.errors:
        raise ValueError('%s: %s' % (spec['name'], '; '.join(t.errors)))
    return t
