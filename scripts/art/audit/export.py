import csv, glob, os, pickle, re, shutil
OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '../../../docs/art-audit/')
os.makedirs(OUT + 'pages', exist_ok=True)
import costumes
from highlight import padv as P
from packpages import status
def tag(s, i): return {'pack': 'pack', 'padv': 'PAdventures', 'ours': 'ours'}[s], i
IP = re.compile(r'stitch|bat costume|captain|mario|spider|batman', re.I)
with open(OUT + 'costumes.csv', 'w', newline='') as f:
    w = csv.writer(f); w.writerow(['Costume', 'Source', 'Id', 'Our base look type', 'Note'])
    for label, cells in costumes.items + costumes.pitems:
        ours = next((i for s, i, _ in cells if s == 'ours'), '')
        for s, i, _ in cells:
            if s != 'ours': w.writerow([label, *tag(s, i), ours, 'other franchise' if IP.search(label) else ''])
tr = pickle.load(open('trainers.pkl', 'rb'))
with open(OUT + 'trainer_outfits.csv', 'w', newline='') as f:
    w = csv.writer(f); w.writerow(['Source', 'Id', 'Colourable', 'Add-ons', 'Mount', 'Pack name', 'Copies with same shape'])
    for u in tr:
        if u['src'] == 'padv':
            g = P[u['id']]['g']
            w.writerow(['PAdventures', u['id'], 'yes', g['py'] - 1, 'yes' if g['pz'] > 1 else '', '', u['copies']])
        else:
            w.writerow(['pack', u['id'], 'yes' if u.get('colour') else 'no', 0, '', status.get(u['id'], {}).get('Name', ''), u['copies']])
for f in glob.glob('pg/hl_*.png'):
    shutil.copy(f, OUT + os.path.basename(f).replace('hl_', ''))
for pat, name in (('tr_*', 'trainers_%s'), ('other_*', 'pack_other_art_%s'), ('cand_0[123]', 'padventures_nearest_%s')):
    for f in sorted(glob.glob('pg/%s.png' % pat)):
        shutil.copy(f, OUT + 'pages/' + name % f.split('_')[-1])
print(os.listdir(OUT), os.listdir(OUT + 'pages'))
