import math, pickle, sys
from PIL import ImageDraw, ImageFont
from frames import *

padv = pickle.load(open('padv.pkl', 'rb'))
pack = pickle.load(open('pack.pkl', 'rb'))
FONT = ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf', 10)


def frame_of(u, direction=2, addon=0):
    if u['src'] == 'padv':
        return padv_frame(u['id'], padv[u['id']]['g'], direction, addon)
    r = pack[u['id']]
    return pack_frame(u['id'], r['c'], r['layers'], direction)


def label(u):
    return ('A' if u['src'] == 'padv' else 'K') + str(u['id']) + ('+' if u.get('addons') else '')


def page(items, path, cols=15, size=80):
    rows = math.ceil(len(items) / cols)
    out = Image.new('RGBA', (cols * size, rows * (size + 12)), (20, 24, 32, 255))
    d = ImageDraw.Draw(out)
    for i, u in enumerate(items):
        x, y = (i % cols) * size, (i // cols) * (size + 12)
        out.alpha_composite(on_bg(frame_of(u), size - 2), (x + 1, y))
        d.text((x + 3, y + size - 1), label(u), font=FONT, fill=(230, 230, 230))
    out.convert('RGB').save(path)


if __name__ == '__main__':
    items = pickle.load(open(sys.argv[1], 'rb'))
    prefix = sys.argv[2]
    per = int(sys.argv[3]) if len(sys.argv) > 3 else 150
    for p in range(math.ceil(len(items) / per)):
        page(items[p * per:(p + 1) * per], '%s_%02d.png' % (prefix, p + 1))
    print(math.ceil(len(items) / per))
