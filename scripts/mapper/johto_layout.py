"""The approved Johto layout (concept v5): towns, routes, landmarks and the coarse land masks.

Everything here is in map tiles. The masks are on a 4x4-tile grid covering LAYOUT_BOX; the
builder refines them to single tiles. Random fields use a fixed seed so the layout never moves
between runs.
"""
import numpy as np
from PIL import Image, ImageFilter

LAYOUT_BOX = (1650, 0, 3460, 1300)
CELL = 4
WEST_LIMIT = 1700
EAST_LIMIT = 3047

TOWNS = {
    'New Bark Town': (2720, 800, 30), 'Cherrygrove City': (2545, 835, 34), 'Violet City': (2500, 560, 46),
    'Azalea Town': (2385, 1040, 34), 'Goldenrod City': (2320, 730, 70), 'Ecruteak City': (2330, 400, 52),
    'Olivine City': (2120, 520, 46), 'Cianwood City': (1930, 645, 34), 'Mahogany Town': (2550, 390, 30),
    'Blackthorn City': (2735, 370, 40),
}
ROUTES = {
    '26': [(3049, 700), (2985, 703), (2905, 712)],
    '27': [(2905, 712), (2830, 765), (2720, 800)],
    '29': [(2720, 800), (2640, 830), (2545, 835)],
    '30': [(2545, 835), (2565, 720), (2545, 620)],
    '31': [(2545, 620), (2500, 560)],
    '32': [(2500, 560), (2475, 660), (2465, 800), (2450, 925)],
    '33': [(2450, 925), (2385, 1040)],
    '34': [(2385, 1040), (2295, 960), (2290, 830), (2320, 730)],
    '35': [(2320, 730), (2330, 615)],
    '36': [(2330, 615), (2420, 585), (2500, 560)],
    '37': [(2330, 615), (2335, 500), (2330, 400)],
    '38': [(2330, 400), (2225, 395), (2140, 425)],
    '39': [(2140, 425), (2120, 520)],
    '42': [(2330, 400), (2440, 395), (2550, 390)],
    '43': [(2550, 390), (2545, 290), (2550, 190)],
    '44': [(2550, 390), (2650, 380), (2735, 370)],
    '45': [(2735, 370), (2745, 480), (2705, 600)],
    '46': [(2705, 600), (2685, 720), (2650, 828)],
    '28': [(3049, 592), (2955, 590), (2905, 520)],
    '47': [(1930, 645), (1850, 615), (1795, 530)],
}
SEA_ROUTES = {'40': [(2120, 520), (2075, 585), (2030, 620)], '41': [(2030, 620), (1930, 645)]}
ANIME_LANDMARKS = {
    'Ho-Oh Shrine': (2905, 360), 'Dragon Holy Land': (2800, 275), 'Lake Slowpoke + Slowpoke Temple': (2650, 445),
    'Charicific Valley': (2610, 520), 'Blue Moon Falls': (2585, 905), 'Onix Tunnel': (2330, 1010),
    'Lake of Life': (2030, 285), 'Lake Lucid': (2245, 440), 'Remoraid Mountain': (2190, 470),
    'Snowtop Mountain (Articuno)': (2200, 205), 'Mount Quena': (2400, 130),
    'Blue Point Isle': (2110, 735), 'Red Rock Isle': (2010, 770), 'Yellow Rock Isle': (2070, 680), 'Silver Rock Isle': (1985, 700),
    'Ogi Isle': (2150, 640), 'I.S.S. Raspberry wreck': (2045, 805),
}
HUNTING = {
    'Alph Meadows': (2385, 840, 70), 'Violet Woodlands': (2420, 690, 55), 'Cherrygrove Bay': (2640, 905, 60),
    'Southern Isle': (2060, 930, 40), 'Arbor Woods': (2060, 340, 45), 'Silver Highlands': (2770, 600, 50),
    'Tohjo Lowlands': (2940, 840, 50), 'Mortar Badlands': (2440, 480, 60), 'Rage Marshes': (2440, 220, 70),
    'Ecruteak Old Forest': (2210, 290, 70), 'Olivine Cliffs': (2030, 430, 60), 'Azalea South Woods': (2470, 1170, 90),
    'Frozen North': (2700, 220, 70), 'Goldenrod Bay Shore': (2170, 820, 55), 'Ilex Coast': (2200, 1000, 60),
    'Goldenrod Outskirts': (2220, 650, 50),
}
LANDMARKS = {
    'Mt. Silver': (2905, 400), 'Tohjo Falls': (2905, 712), 'Dark Cave': (2705, 600), 'Union Cave': (2450, 925),
    'Ruins of Alph': (2420, 640), 'Ilex Forest': (2292, 900), 'National Park': (2330, 615), 'Slowpoke Well': (2410, 1075),
    'Sprout Tower': (2530, 540), 'Bell Tower': (2300, 300), 'Burned Tower': (2360, 380), 'Mt. Mortar': (2440, 395),
    'Lake of Rage': (2550, 175), 'Ice Path': (2650, 378), "Dragon's Den": (2790, 320), 'Whirl Islands (game caves)': (2030, 620),
    'Olivine Lighthouse': (2085, 545), 'Safari Zone': (1795, 520), 'Battle Frontier': (2010, 360),
}
WEST_GATE = (3049, 592)
SOUTH_GATE = (3049, 700)

# floor-7 ground classes used by the layout
VOID, UNKNOWN, WATER, MOUNTAIN, GRASS, SAND, OTHER = range(7)


def concept(ground_class, occupied_cells):
    """Coarse masks of the layout.

    ground_class: callable (x, y) -> floor-7 class of the existing map.
    occupied_cells: set of (x // 32, y // 32) holding any tile on any floor.
    """
    X0, Y0, X1, Y1 = LAYOUT_BOX
    C = CELL
    GW, GH = (X1 - X0) // C, (Y1 - Y0) // C
    rng = np.random.default_rng(7)

    allowed = np.zeros((GH, GW), bool)
    sub = np.zeros((GH, GW), np.uint8)
    for gy in range(GH):
        for gx in range(GW):
            tx, ty = X0 + gx * C, Y0 + gy * C
            allowed[gy, gx] = (tx // 32, ty // 32) not in occupied_cells and 20 <= ty <= 1268 and WEST_LIMIT <= tx <= EAST_LIMIT
            sub[gy, gx] = ground_class(tx, ty)
    water7 = sub == WATER
    land7 = (sub != VOID) & (sub != WATER)
    near_land = np.asarray(Image.fromarray(land7.astype(np.uint8) * 255).filter(ImageFilter.MaxFilter(13))).astype(bool)
    allowed |= (water7 | (sub == VOID)) & ~near_land
    allowed[:, :(WEST_LIMIT - X0) // C] = False

    def noise(scale, octaves=4):
        out = np.zeros((GH, GW))
        amp, tot = 1.0, 0.0
        for o in range(octaves):
            s = max(2, int(scale / (2 ** o)))
            g = rng.random((GH // s + 3, GW // s + 3))
            img = Image.fromarray((g * 255).astype(np.uint8)).resize(((GW // s + 3) * s, (GH // s + 3) * s), Image.BICUBIC)
            out += amp * (np.asarray(img, float)[:GH, :GW] / 255 - 0.5)
            tot += amp
            amp *= 0.5
        return out / tot

    yy, xx = np.mgrid[0:GH, 0:GW]
    TX, TY = X0 + xx * C, Y0 + yy * C

    def blob(cx, cy, r, n, amp=0.45):
        d = np.hypot(TX - cx, TY - cy) / r
        return d + n * amp * 2 < 1.0

    def seg_dist(ax, ay, bx, by):
        vx, vy = bx - ax, by - ay
        t = np.clip(((TX - ax) * vx + (TY - ay) * vy) / max(1, vx * vx + vy * vy), 0, 1)
        return np.hypot(TX - (ax + t * vx), TY - (ay + t * vy))

    def corridor(pts, w, n, amp=0.5):
        m = np.zeros((GH, GW), bool)
        for a, b in zip(pts, pts[1:]):
            m |= seg_dist(*a, *b) + n * amp * w * 2 < w
        return m

    nL, nM, nF, nS = noise(60), noise(40), noise(30), noise(50)

    land = np.zeros((GH, GW), bool)
    for x, y, r in TOWNS.values():
        land |= blob(x, y, r * 2.4, nL)
    for pts in ROUTES.values():
        land |= corridor(pts, 55, nL)
    for x, y, r in HUNTING.values():
        land |= blob(x, y, r * 1.4, nL)
    for n in ('Mt. Silver', 'Battle Frontier', 'Safari Zone', 'Bell Tower', "Dragon's Den"):
        land |= blob(*LANDMARKS[n], 110 if n == 'Mt. Silver' else 70, nL)
    land |= blob(2905, 420, 150, nL, 0.25) | corridor([(2830, 600), (3045, 625)], 40, nL, 0.3)
    land |= corridor([(2650, 700), (2900, 700)], 70, nL)
    land |= corridor([(2860, 720), (2990, 800), (3047, 880)], 75, nL, 0.25) | blob(2960, 850, 90, nL, 0.25)
    for (x, y, r) in [(1985, 700, 40), (2070, 680, 30), (2110, 735, 34), (2010, 770, 26), (2150, 640, 16), (1945, 760, 18)]:
        land |= blob(x, y, r, nL, 0.35)
    land |= blob(2060, 930, 45, nL, 0.15)
    land |= blob(2200, 380, 95, nL) | blob(2200, 230, 80, nL) | blob(2400, 150, 85, nL) | blob(2050, 280, 85, nL)
    land |= blob(2650, 300, 50, nL) | blob(2860, 560, 50, nL)
    for (x, y, r) in [(2030, 620, 22), (2060, 600, 14), (1860, 735, 16), (1820, 705, 12), (1880, 760, 10), (2005, 650, 12)]:
        land |= blob(x, y, r, nL, 0.3)
    water_sea = corridor(SEA_ROUTES['40'] + SEA_ROUTES['41'][1:], 70, nL, 0.2)
    land &= ~(water_sea & ~blob(2030, 620, 24, nL, 0.3) & ~blob(2005, 650, 14, nL, 0.3))
    land &= allowed
    sea = allowed & ~land
    sea &= ~water7

    mount = np.zeros((GH, GW), bool)
    mount |= blob(2440, 410, 85, nM) | corridor([(2380, 330), (2500, 460)], 45, nM)
    mount |= corridor([(2830, 615), (3045, 625)], 22, nM, 0.3)
    mount |= blob(2905, 420, 140, nM, 0.3)
    mount |= corridor([(2685, 430), (2770, 640)], 35, nM)
    mount |= blob(2470, 930, 45, nM)
    mount |= corridor([(2210, 470), (2280, 560)], 30, nM)
    land |= corridor([(2905, 420), (2990, 470), (3047, 520)], 70, nM, 0.25) & allowed
    mount |= corridor([(2905, 420), (2990, 470), (3047, 520)], 70, nM, 0.25) | corridor([(2960, 600), (3047, 640)], 35, nM, 0.2)
    mount |= blob(2190, 470, 35, nM, 0.3) | blob(2200, 215, 55, nM, 0.3) | blob(2400, 140, 60, nM, 0.3)
    mount &= land
    for pts in ROUTES.values():
        mount &= ~corridor(pts, 9, nM, 0.1)
    for x, y, r in TOWNS.values():
        mount &= ~blob(x, y, r * 1.2, nM, 0.1)
    snow = (blob(2700, 260, 140, nS) | blob(2905, 380, 90, nS, 0.3) | blob(2200, 215, 45, nS, 0.3) | blob(2400, 125, 35, nS, 0.3)) & land
    forest = (blob(2292, 900, 70, nF) | blob(2040, 275, 70, nF) | corridor([(2330, 440), (2335, 590)], 45, nF)
              | corridor([(2240, 395), (2160, 420)], 40, nF) | blob(2210, 290, 80, nF) | blob(2520, 1150, 90, nF)
              | corridor([(2860, 740), (2760, 790)], 35, nF) | blob(2420, 690, 50, nF)
              | corridor([(2600, 830), (2680, 815)], 25, nF)) & land & ~mount
    for pts in ROUTES.values():
        forest &= ~corridor(pts, 8, nF, 0.1)
    for x, y, r in TOWNS.values():
        forest &= ~blob(x, y, r * 1.3, nF, 0.1)
    lakes = (blob(2550, 175, 45, nS, 0.3) | blob(2245, 440, 22, nS, 0.2) | blob(2650, 445, 20, nS, 0.2)
             | blob(2000, 250, 18, nS, 0.2) | blob(2190, 470, 8, nS, 0.1) | blob(2400, 175, 10, nS, 0.1)
             | blob(2345, 640, 14, nS, 0.2) | blob(2420, 230, 25, nS) | blob(2800, 520, 18, nS)) & land
    river = (corridor([(2905, 640), (2905, 712), (2920, 820)], 6, nS, 0.2)
             | corridor([(2400, 180), (2420, 260), (2470, 330)], 5, nS, 0.2)) & land
    return {'land': land, 'sea': sea, 'mount': mount, 'snow': snow, 'forest': forest, 'lakes': lakes,
            'river': river, 'allowed': allowed}
