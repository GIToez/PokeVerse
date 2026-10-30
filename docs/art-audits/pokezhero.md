# PokeZHero client (OTC 1.2) art audit

Source: `POKEZHERO OTC 1.2 [CLIENT].zip` (Drive). Its `data/things/1098/Tibia.dat` and `Tibia.spr` are not
encrypted: 10.98 layout, alpha-channel sprites, 36,863 items, 3,489 outfits, 933 effects, 499,232 sprites.
Nothing is imported yet.

Every sprite was compared with our `data.spr` by exact pixels and by shape, opaque tiles also by colour
(an 8x8 thumbnail, nearest of ours), and new outfits against the PAdventures and 6500 pack sheets.
The art is CipSoft's Tibia 10.x sets and Pokemon fan sprites, the same footing as our own art, not an
open licence.

## Outfits

| | Looks |
| --- | --- |
| We have them | 897 |
| Recolours of ours | 372 |
| Empty | 215 |
| New, also in PAdventures or the 6500 pack | 587 |
| New, only here: Pokemon (about 915-2023 and 2845+) | 365 |
| New, only here: trainer outfits, mostly attack poses (2024-2844) | 478 |
| New, only here: Tibia monsters (1-914) | 575 |

`pokezhero-outfits.csv` lists every new look, its group, and the other source that has it.

## Items

New art (most of its sprites unlike any of ours, duplicates dropped): 812 ground, 1,938 borders,
1,282 walls, 3,049 multi-tile buildings and nature, 416 decor, 5,392 carried, 3,990 other.
`pokezhero-items.csv` lists them. Pokemon-themed ones: Poke Ball floor 23962, Poke floors
29319-29333, gym floor emblem 27159-27200, race track 31683-31694, carpets 28654-28668, machines
23862-23866, 36599, 36610-36613; Pokemon corpses 25743-26018 and 36016-36420; move icons 35140-35800.
