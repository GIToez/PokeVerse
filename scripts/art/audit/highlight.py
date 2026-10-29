import math, pickle
from PIL import Image, ImageDraw, ImageFont
from frames import padv_frame, pack_frame, on_bg
from ourpage import frame as our_frame

padv = pickle.load(open('padv.pkl', 'rb'))
pack = pickle.load(open('pack.pkl', 'rb'))
FONT = ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf', 11)
BLUE, GREEN, BG = (50, 60, 90, 255), (58, 84, 58, 255), (20, 24, 32, 255)


def img(src, i, d=2, addon=0):
    if src == 'ours':
        return our_frame(i, d, addon)
    if src == 'padv':
        im = padv_frame(i, padv[i]['g'], d, addon)
        if addon:
            base = padv_frame(i, padv[i]['g'], d, 0)
            base.alpha_composite(im)
            im = base
        return im
    r = pack[i]
    return pack_frame(i, r['c'], r['layers'], d)


def tag(src, i):
    return {'ours': '#', 'padv': 'A', 'pack': 'K'}[src] + str(i)


def fit(im, size, bg):
    out = Image.new('RGBA', (size, size), bg)
    k = size / max(im.width, im.height)
    im = im.resize((max(1, int(im.width * k)), max(1, int(im.height * k))), Image.NEAREST)
    out.alpha_composite(im, ((size - im.width) // 2, (size - im.height) // 2))
    return out


def sheet(items, path, cols=8, size=96, title=None, fixed=False):
    """items: list of (label, [(src, id, addon), ...]); first cell blue if src == 'ours'."""
    per = max(len(c) for _, c in items)
    W = per * size + 6
    top = 26 if title else 0
    rows = math.ceil(len(items) / cols)
    out = Image.new('RGBA', (cols * W, top + rows * (size + 30)), BG)
    d = ImageDraw.Draw(out)
    if title:
        d.text((6, 6), title, font=ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf', 14), fill=(240, 240, 240))
    for n, (label, cells) in enumerate(items):
        x, y = (n % cols) * W, top + (n // cols) * (size + 30)
        for k, (src, i, a) in enumerate(cells):
            try:
                im = img(src, i, 2, a)
            except Exception:
                continue
            bg = BLUE if src == 'ours' else GREEN
            out.alpha_composite((fit if fixed else on_bg)(im, size - 2, bg), (x + k * size + 1, y))
        d.text((x + 3, y + size), label[:26], font=FONT, fill=(230, 230, 230))
        d.text((x + 3, y + size + 13), ' '.join(tag(s, i) for s, i, a in cells if s != 'ours' and a == 0)[:30], font=FONT, fill=(170, 180, 220))
    out.convert('RGB').save(path)
