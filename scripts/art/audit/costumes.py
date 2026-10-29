import pickle, re
from highlight import sheet, img
from frames import silhouette
from packpages import byname, status
cos = pickle.load(open('costume.pkl', 'rb'))
near, names = pickle.load(open('near.pkl', 'rb'))
padv_look = {sid: look for _, sid, look in near}
padv = pickle.load(open('padv.pkl', 'rb'))
items, sils = [], set()
for _, n, _ in cos:
    nm = status.get(n, {}).get('Name', '') or '?'
    sp = re.split(r' \(|,', nm)[0].strip()
    look = byname.get(sp.lower())
    items.append((nm, ([('ours', look, 0)] if look else []) + [('pack', n, 0)]))
    sils.add(silhouette(img('pack', n)))
items.sort(key=lambda x: x[0])
sheet(items, 'pg/hl_costumes_pack.png', cols=8, size=80, title='6500 pack: Pokemon costumes we do not have (blue = our base sprite)')
PADV = {45799: 'Hitmontop (Santa hat)', 45797: 'Hitmonchan (Santa hat)', 44820: 'Snorlax (pumpkin)', 45442: 'Raichu (mouse ears)',
        45802: 'Raichu (Santa)', 47650: 'Pidgey (Santa hat)', 41843: 'Slowking (hat)', 41830: 'Cubone (Santa)',
        43954: 'Aggron (witch hat)', 47139: 'Meowth (costume)', 45746: 'Wigglytuff (costume)', 41910: 'Jynx (hat)',
        46262: 'Muk (cap)', 47659: 'Sudowoodo (Christmas tree)', 44983: 'Espeon (crown)', 44981: 'Umbreon (crown)',
        41859: 'Ampharos (wizard hat)', 41860: 'Ampharos (costume)', 43943: 'Chansey (nurse)', 40691: 'Diglett (costume)',
        40764: 'Diglett (witch hat)', 40339: 'Diglett (Santa hat)', 45237: 'Pumpkin costume', 44358: 'Shiftry (hat)',
        45027: 'Lapras (rider)', 48255: 'Lapras (rider)', 42979: 'Dugtrio (costume)', 40792: 'Dunsparce (costume)'}
pitems, dup = [], 0
for sid, label in PADV.items():
    if sid not in padv:
        continue
    if silhouette(img('padv', sid)) in sils:
        dup += 1
        continue
    look = padv_look.get(sid) or padv[sid].get('best')
    pitems.append((label, [('ours', look, 0), ('padv', sid, 0)]))
sheet(pitems, 'pg/hl_costumes_padv.png', cols=7, size=88, title='PAdventures: Pokemon costumes not in the pack (blue = closest sprite of ours)')
print(len(items), len(pitems), dup)
