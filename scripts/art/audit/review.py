"""One row per Pokemon we have: our sprite, then every candidate redraw numbered, for picking by hand."""
import collections, csv, math, os, pickle, re, sys
from PIL import Image, ImageDraw, ImageFont
from frames import silhouette
from highlight import img, BLUE, GREEN, BG


def fit(im, size, bg):
    out = Image.new('RGBA', (size, size), bg)
    k = min(size / 64, size / max(im.width, im.height))
    im = im.resize((max(1, round(im.width * k)), max(1, round(im.height * k))), Image.NEAREST)
    out.alpha_composite(im, ((size - im.width) // 2, size - im.height))
    return out
from ourpage import lab
from packpages import byname

PREFIX = re.compile(r'^(Shiny|Cloned|RC|Test|Rocket\'s|Angry|Scary|Noisy|Suramoon|Thief) ', re.I)
FONT = ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf', 11)
BOLD = ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf', 13)


def species(name):
    name = re.sub(r' - \w+$', '', name.strip())
    name = re.sub(r' \(.*?\)', '', name)
    while PREFIX.match(name):
        name = PREFIX.sub('', name)
    return name.strip()


def gather():
    rows = collections.defaultdict(list)
    for sp, n, _ in pickle.load(open('other.pkl', 'rb')):
        rows[species(sp)].append(('pack', n))
    for src, sid, look in pickle.load(open('pairs.pkl', 'rb')):
        names = [n for a, n in lab.get(look, []) if a == 'pokemon']
        if src == 'padv' and names:
            rows[species(names[0])].append(('padv', sid))
    out = []
    for sp, cands in rows.items():
        look = byname.get(sp.lower())
        if not look:
            continue
        seen, keep = {silhouette(img('ours', look))}, []
        for c in cands:
            try:
                s = silhouette(img(*c))
            except Exception:
                continue
            if s and s not in seen:
                seen.add(s)
                keep.append(c)
        if keep:
            out.append((look, sp, keep))
    out.sort()
    return out


def draw(rows, path, size=96, per_line=7):
    cell = 2 * size + 4
    lines = [(r, k) for r in rows for k in range(math.ceil(len(r[2]) / per_line))]
    W = cell * (per_line + 1) + 8
    H = len(lines) * (size + 22) + 4
    out = Image.new('RGBA', (W, H), BG)
    d = ImageDraw.Draw(out)
    for li, ((look, sp, cands), k) in enumerate(lines):
        y = 4 + li * (size + 22)
        if k == 0:
            for j, dd in enumerate((2, 1)):
                out.alpha_composite(fit(img('ours', look, dd), size - 2, BLUE), (4 + j * size, y))
            d.text((6, y + size + 2), '%s (#%d)' % (sp, look), font=BOLD, fill=(240, 240, 240))
        for j, c in enumerate(cands[k * per_line:(k + 1) * per_line]):
            x = 4 + cell * (j + 1)
            for jj, dd in enumerate((2, 1)):
                try:
                    out.alpha_composite(fit(img(c[0], c[1], dd), size - 2, GREEN), (x + jj * size, y))
                except Exception:
                    pass
            num = k * per_line + j + 1
            d.text((x + 2, y + size + 2), '%d  %s%d' % (num, 'K' if c[0] == 'pack' else 'A', c[1]), font=FONT, fill=(200, 210, 240))
    out.convert('RGB').save(path)


if __name__ == '__main__':
    outdir = sys.argv[1]
    rows = gather()
    pickle.dump(rows, open('review.pkl', 'wb'))
    os.makedirs(outdir, exist_ok=True)
    page, pages, n = [], [], 0
    for r in rows:
        lines = math.ceil(len(r[2]) / 7)
        if page and n + lines > 10:
            pages.append(page); page, n = [], 0
        page.append(r); n += lines
    pages.append(page)
    for i, p in enumerate(pages):
        draw(p, os.path.join(outdir, 'better_art_%02d.png' % (i + 1)))
    with open(os.path.join(outdir, '..', 'better_art_picks.csv'), 'w', newline='') as f:
        w = csv.writer(f)
        w.writerow(['Pokemon', 'Our look type', 'Page', 'Candidates (number = code)', 'Pick (number, or blank to keep ours)'])
        for i, p in enumerate(pages):
            for look, sp, cands in p:
                w.writerow([sp, look, 'better_art_%02d.png' % (i + 1),
                            ' '.join('%d=%s%d' % (j + 1, 'K' if s == 'pack' else 'A', c) for j, (s, c) in enumerate(cands)), ''])
    print(len(rows), sum(len(r[2]) for r in rows), len(pages))
