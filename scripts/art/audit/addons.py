import pickle
from highlight import sheet, padv
tr = pickle.load(open('trainers.pkl', 'rb'))
items = []
for u in tr:
    if u['src'] != 'padv' or not u['addons']:
        continue
    g = padv[u['id']]['g']
    cells = [('padv', u['id'], a) for a in range(min(g['py'], 3))]
    items.append(('A%d%s' % (u['id'], ' +mount' if u['mount'] else ''), cells))
half = (len(items) + 1) // 2
for k, part in enumerate((items[:half], items[half:])):
    sheet(part, 'pg/hl_addons_%d.png' % (k + 1), cols=6, size=80, fixed=True,
          title='PAdventures trainer outfits with add-ons (base, add-on 1, add-on 2) - %d of 2' % (k + 1))
print(len(items))
