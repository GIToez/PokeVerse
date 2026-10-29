import pickle
from highlight import sheet
from packpages import byname
near, names = pickle.load(open('near.pkl', 'rb'))
padv_look = {sid: look for _, sid, look in near}
PACK = {
 'Bulbasaur': [4267], 'Ivysaur': [3086], 'Venusaur': [5229, 7719], 'Charmander': [1252, 4268], 'Charizard': [8233, 6184],
 'Squirtle': [4269], 'Wartortle': [5653], 'Butterfree': [3102], 'Pikachu': [4973], 'Raichu': [4983],
 'Nidorina': [3133], 'Nidoqueen': [3141], 'Jigglypuff': [2184], 'Wigglytuff': [3126], 'Grimer': [3261],
 'Meowth': [3163], 'Mankey': [5869], 'Poliwhirl': [3259], 'Poliwrath': [3162], 'Machoke': [3171], 'Machamp': [3179],
 'Slowpoke': [3137], 'Haunter': [3360], 'Gengar': [2182], 'Kingler': [3291], 'Lickitung': [362], 'Chansey': [4443],
 'Staryu': [393], 'Tentacruel': [6620], 'Eevee': [7198], 'Flareon': [1330], 'Omanyte': [5866], 'Omastar': [3240],
 'Snorlax': [3345], 'Zapdos': [3247], 'Moltres': [3310], 'Mew': [3071], 'Cyndaquil': [674], 'Typhlosion': [1534],
 'Totodile': [679], 'Croconaw': [680], 'Espeon': [3693], 'Ursaring': [1449, 3426], 'Tyranitar': [2703], 'Lugia': [1600],
 'Grovyle': [3874], 'Pelipper': [3889], 'Sableye': [3873], 'Wailord': [4032], 'Altaria': [4087], 'Zangoose': [3922],
 'Groudon': [1596], 'Rayquaza': [8055],
}
PADV = [47057]
items = []
KEEP = ['Ivysaur', 'Charizard', 'Butterfree', 'Raichu', 'Nidorina', 'Jigglypuff', 'Mankey', 'Poliwrath', 'Machoke', 'Machamp', 'Slowpoke', 'Haunter', 'Gengar', 'Lickitung', 'Chansey', 'Tentacruel', 'Eevee', 'Flareon', 'Omastar', 'Zapdos', 'Moltres', 'Espeon', 'Grovyle', 'Altaria', 'Zangoose', 'Rayquaza', 'Croconaw']
for sp, ns in PACK.items():
    if sp not in KEEP: continue
    look = byname.get(sp.lower())
    items.append((sp, ([('ours', look, 0)] if look else []) + [('pack', n, 0) for n in ns]))
for sid in PADV:
    look = padv_look[sid]
    items.append((names[look] + ' (PAdv)', [('ours', look, 0), ('padv', sid, 0)]))
sheet(items, 'pg/hl_better.png', cols=6, title='Better art for Pokemon we have (blue = ours, green = theirs)')
print(len(items))
