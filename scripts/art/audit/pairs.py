import math, pickle, sys
from PIL import Image, ImageDraw, ImageFont
from frames import *
from ourpage import frame as our_frame, lab

padv = pickle.load(open('padv.pkl', 'rb'))
pack = pickle.load(open('pack.pkl', 'rb'))
FONT = ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf', 10)


def theirs(src, i, d=2):
    if src == 'padv':
        return padv_frame(i, padv[i]['g'], d)
    r = pack[i]
    return pack_frame(i, r['c'], r['layers'], d)


def name(look):
    v = lab.get(look)
    return v[0][1] if v else str(look)


def page(pairs, path, cols=8, size=72):
    rows = math.ceil(len(pairs) / cols)
    W = 2 * size + 8
    out = Image.new('RGBA', (cols * W, rows * (size + 24)), (20, 24, 32, 255))
    d = ImageDraw.Draw(out)
    for i, (src, sid, look) in enumerate(pairs):
        x, y = (i % cols) * W, (i // cols) * (size + 24)
        if look:
            out.alpha_composite(on_bg(our_frame(look), size - 2, (50, 60, 90, 255)), (x + 1, y))
        out.alpha_composite(on_bg(theirs(src, sid), size - 2), (x + size + 1, y))
        d.text((x + 3, y + size), ('%s' % name(look))[:22] if look else '-', font=FONT, fill=(180, 190, 230))
        d.text((x + 3, y + size + 11), ('A' if src == 'padv' else 'K') + str(sid), font=FONT, fill=(230, 230, 230))
    out.convert('RGB').save(path)


def chunks(pairs, prefix, per=96):
    for p in range(math.ceil(len(pairs) / per)):
        page(pairs[p * per:(p + 1) * per], '%s_%02d.png' % (prefix, p + 1))
    return math.ceil(len(pairs) / per)


if __name__ == '__main__':
    out = []
    for src, dd in (('padv', padv), ('pack', pack)):
        for sid, r in sorted(dd.items()):
            if r.get('bad') or not (0.1 < r['share'] < 0.999):
                continue
            kinds = set(a for a, _ in lab.get(r['best'], [('other', '')]))
            if kinds & {'pokemon', 'pokeaddon'} or kinds == {'other'}:
                if src == 'padv' and r['g']['layers'] == 2 and kinds == {'other'}:
                    continue
                out.append((src, sid, r['best']))
    out.sort(key=lambda p: (p[2], p[0]))
    pickle.dump(out, open('pairs.pkl', 'wb'))
    print(len(out), chunks(out, 'pg/pair'))
