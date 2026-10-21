"""DS-era Pokemon repaints of the wooden crate (client 2469), the cardboard box with its Poke Ball
stamp (2473) and the chest (2483), drawn pixel by pixel on the same footprints."""
from PIL import Image


def box_faces(x0, y0, x1, y1, depth):
    """Pixel sets of an oblique box: top rectangle x0..x1, y0..y1, extruded down-right by depth."""
    top, front, side = set(), set(), set()
    for y in range(y0, y1 + 1):
        for x in range(x0, x1 + 1):
            top.add((x, y))
    for k in range(1, depth + 1):
        for x in range(x0 + k, x1 + k + 1):
            front.add((x, y1 + k))
        for y in range(y0 + k, y1 + k + 1):
            side.add((x1 + k, y))
    side -= top
    front -= top
    side -= front
    return top, front, side


class Sprite:
    def __init__(self):
        self.px = {}

    def put(self, p, c):
        if 0 <= p[0] < 32 and 0 <= p[1] < 32:
            self.px[p] = c

    def image(self):
        im = Image.new('RGBA', (32, 32), (0, 0, 0, 0))
        for p, c in self.px.items():
            im.putpixel(p, c + (255,))
        return im


def outline(sp, pts, col):
    for (x, y) in list(pts):
        for q in ((x + 1, y), (x - 1, y), (x, y + 1), (x, y - 1)):
            if q not in pts:
                sp.put((x, y), col)
                break


def crate():
    O = (74, 40, 22)
    D = (140, 82, 40)
    M = (196, 128, 62)
    L = (230, 172, 94)
    H = (250, 216, 146)
    SD = (98, 54, 28)
    SM = (140, 84, 42)
    SL = (168, 106, 54)
    NAIL = (92, 84, 84)
    x0, y0, x1, y1, dep = 2, 4, 23, 20, 7
    top, front, side = box_faces(x0, y0, x1, y1, dep)
    sp = Sprite()
    # top: 2 px frame around a planked panel with one diagonal brace
    for (x, y) in top:
        fx, fy = x - x0, y - y0
        w, h = x1 - x0, y1 - y0
        frame = fx <= 2 or fy <= 2 or fx >= w - 2 or fy >= h - 2
        if frame:
            c = M
            if fx == 1 or fy == 1:
                c = H
            if fx == w - 1 or fy == h - 1:
                c = D
            if (fx <= 2 or fx >= w - 2) and 2 < fy < h - 2:
                c = L if fx in (1, 2) else D if fx == w - 1 else M
            sp.put((x, y), c)
            continue
        ix, iy = fx - 3, fy - 3
        c = L
        if ix % 4 == 3:
            c = D
        elif ix % 4 == 0:
            c = H
        # diagonal brace from top-left to bottom-right of the panel
        iw, ih = w - 5, h - 5
        t = ix - iy * iw / ih
        if -2.4 <= t <= 2.4:
            c = H if t < -1.3 else M if t < 1.3 else O
        sp.put((x, y), c)
    for (x, y) in front:
        k = y - y1
        fx = x - x0 - k
        c = M
        if k in (1, 4):
            c = L
        if k in (3, 6):
            c = D
        if fx <= 1 or fx >= x1 - x0 - 1:
            c = D if fx <= 1 else SM
        sp.put((x, y), c)
    for (x, y) in side:
        k = x - x1
        fy = y - y0 - k
        c = SM
        if fy <= 1 or fy >= y1 - y0 - 1:
            c = SL if fy <= 1 else SD
        elif k == 1:
            c = SL
        elif (y - k) % 5 == 0:
            c = SD
        sp.put((x, y), c)
    for p in [(x0 + 1, y0 + 1), (x1 - 1, y0 + 1), (x0 + 1, y1 - 1), (x1 - 1, y1 - 1)]:
        sp.put(p, NAIL)
    allpts = top | front | side
    outline(sp, allpts, O)
    for x in range(x0 + 1, x1 + 1):
        sp.put((x, y1), O)
    for y in range(y0 + 1, y1 + 1):
        sp.put((x1, y), O)
    for k in range(1, dep):
        sp.put((x1 + k, y1 + k), O)
    return sp.image()


def cardboard():
    O = (96, 62, 32)
    D = (166, 118, 64)
    M = (208, 162, 100)
    L = (232, 196, 134)
    H = (246, 222, 170)
    SD = (128, 86, 46)
    SM = (164, 116, 64)
    TAPE = (238, 228, 198)
    SHINE = (255, 251, 236)
    RED = (222, 64, 52)
    WHITE = (250, 246, 236)
    INK = (60, 40, 30)
    x0, y0, x1, y1, dep = 1, 5, 23, 20, 8
    top, front, side = box_faces(x0, y0, x1, y1, dep)
    sp = Sprite()
    cy = (y0 + y1) // 2
    for (x, y) in top:
        fx, fy = x - x0, y - y0
        c = L
        if fy == 1:
            c = H
        if y == cy or y == cy + 1:
            c = D if y == cy + 1 else M
        if abs(fx - (x1 - x0) // 2) <= 2:
            c = TAPE
            if fx - (x1 - x0) // 2 == -1:
                c = SHINE
        if fx >= x1 - x0 - 1:
            c = M
        sp.put((x, y), c)
    for (x, y) in front:
        k = y - y1
        fx = x - x0 - k
        c = M
        if k == 1:
            c = L
        if k >= dep - 1:
            c = D
        if abs(fx - (x1 - x0) // 2) <= 2 and k <= 3:
            c = TAPE
        sp.put((x, y), c)
    # Poke Ball stamp on the left flap
    ball = ["..rrr..",
            ".rrrrr.",
            "rrrrrrr",
            "kkkWkkk",
            "wwwwwww",
            ".wwwww.",
            "..www.."]
    bx, by = x0 + 3, y0 + 2
    stamp = set()
    for j, row in enumerate(ball):
        for i, ch in enumerate(row):
            col = {'r': RED, 'w': WHITE, 'k': INK, 'W': WHITE}.get(ch)
            if col:
                sp.put((bx + i, by + j), col)
                stamp.add((bx + i, by + j))
    for (x, y) in stamp:
        for q in ((x + 1, y), (x - 1, y), (x, y + 1), (x, y - 1)):
            if q not in stamp:
                sp.put(q, INK)
    for (x, y) in side:
        k = x - x1
        fy = y - y0 - k
        c = SM
        if k == 1:
            c = M
        if fy == cy - y0 or fy == cy - y0 + 1:
            c = SD
        sp.put((x, y), c)
    allpts = top | front | side
    outline(sp, allpts, O)
    for x in range(x0 + 1, x1 + 1):
        sp.put((x, y1), O)
    for y in range(y0 + 1, y1 + 1):
        sp.put((x1, y), O)
    for k in range(1, dep):
        sp.put((x1 + k, y1 + k), O)
    return sp.image()


class Wide(Sprite):
    def put(self, p, c):
        if 0 <= p[0] < 64 and 0 <= p[1] < 32:
            self.px[p] = c

    def image(self):
        im = Image.new('RGBA', (64, 32), (0, 0, 0, 0))
        for p, c in self.px.items():
            im.putpixel(p, c + (255,))
        return im


def chest():
    """The 2x1 chest (client 2483): returns (left tile, right tile)."""
    O = (70, 30, 20)
    WD = (128, 52, 34)
    WM = (172, 78, 46)
    WL = (206, 108, 62)
    WH = (230, 142, 86)
    SM = (136, 58, 36)
    GD = (176, 120, 30)
    GM = (232, 180, 48)
    GH = (255, 232, 120)
    KEY = (40, 24, 20)
    x0, y0, x1, y1, dep = 24, 2, 53, 19, 10
    top, front, side = box_faces(x0, y0, x1, y1, dep)
    sp = Wide()
    w = x1 - x0
    bands = [x0 + 5, x1 - 5]
    for (x, y) in top:
        fy = y - y0
        c = WL
        if fy % 4 == 0:
            c = WM
        if fy == 1:
            c = WH
        if y == y1 - 4:
            c = O
        if y in (y1 - 3, y1 - 2, y1 - 1):
            c = WM if y != y1 - 3 else WH
        for b in bands:
            if abs(x - b) <= 1:
                c = GH if x == b - 1 else GM if x == b else GD
        sp.put((x, y), c)
    for (x, y) in front:
        k = y - y1
        fx = x - x0 - k
        c = WM
        if k == 1:
            c = GM
        if k == 2:
            c = GD
        if k >= dep - 1:
            c = WD
        if 3 <= k < dep - 1 and (k - 3) % 3 == 2:
            c = WD
        for b in bands:
            if abs(fx - (b - x0)) <= 1 and k > 1:
                c = GH if fx == b - x0 - 1 else GM if fx == b - x0 else GD
        sp.put((x, y), c)
    # lock plate on the front, sheared with the face
    cx = x0 + w // 2
    plate = ["GGGGG", "GgkgG", "GgkgG", "GGGGG"]
    for j, row in enumerate(plate):
        k = 3 + j
        for i, ch in enumerate(row):
            p = (cx - 2 + i + k, y1 + k)
            sp.put(p, {'G': GM, 'g': GH, 'k': KEY}[ch])
    for (x, y) in side:
        k = x - x1
        fy = y - y0 - k
        c = SM
        if k == 1:
            c = WM
        if fy == y1 - y0 - 4:
            c = O
        if fy in (1, 2):
            c = GD
        sp.put((x, y), c)
    allpts = top | front | side
    outline(sp, allpts, O)
    for x in range(x0 + 1, x1 + 1):
        sp.put((x, y1), O)
    for y in range(y0 + 1, y1 + 1):
        sp.put((x1, y), O)
    for k in range(1, dep):
        sp.put((x1 + k, y1 + k), O)
    im = sp.image()
    return im.crop((0, 0, 32, 32)), im.crop((32, 0, 64, 32))


def sprites():
    """{sprite id: 32x32 RGBA image} for data.spr."""
    left, right = chest()
    return {298: crate(), 1225: cardboard(), 88561: left, 88560: right}
