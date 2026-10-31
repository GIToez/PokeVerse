# PokeZHero client (OTC 1.2) art audit

Source: `POKEZHERO OTC 1.2 [CLIENT].zip` (Drive). Its `data/things/1098/Tibia.dat` and `Tibia.spr` are not
encrypted: 10.98 layout, alpha-channel sprites, 36,863 items, 3,489 outfits, 933 effects, 499,232 sprites.

## Imported

`scripts/art/import-things.py` added these after our own things (nothing of ours changed);
`pokezhero-imported.csv` maps every PokeZHero id to its new client and server id.

| | PokeZHero ids | Client ids | Server ids |
| --- | --- | --- | --- |
| Orange race track floor | 31683-31694, 31707-31709 | 29883-29897 | 31096-31110 |
| Orange floor pieces drawn for it (`orange-floor/`) | | 30052-30058 | 31265-31271 |
| Blue, light blue and grey floors | 32107-32118, 30582-30587, 30568, 27785, 31506, 31508 | 29898-29919 | 31111-31132 |
| Green carpet | 28654-28668 | 29920-29934 | 31133-31147 |
| Poke Ball gym floor | 27159-27200 | 29935-29976 | 31148-31189 |
| Walls and windows | 27051-27062, 33515-33536 | 29977-30010 | 31190-31223 |
| Stairs, glass | 30596-30613, 26834-26836 | 30011-30031 | 31224-31244 |
| Machines | 23862-23866, 33547, 36599, 36601, 36722-36729, 36802 | 30032-30047 | 31245-31260 |
| Trees | 36712, 36713, 36796, 36797 | 30048-30051 | 31261-31264 |
| Trainer and Pokemon looks (every new one in `pokezhero-outfits.csv`) | | outfits 2906-4248 | |

The orange set had only a top edge; `orange-floor/` adds the left, right and bottom lanes, the
bottom corners and two bottom turns (`area.png` shows a whole area). Every orange piece is
repainted on one seamless floor with a brown rim outside the line, so an area has no
per-tile frames or shading. The map editor lists the floors and buildings under the
PokeVerse floors / PokeVerse buildings tilesets. Not imported: the branded PokeDash floors
(23962-23978, 29319-29333), the Magikarp statues, the white walls (we have 2222-2233) and the
Tibia monster looks.

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
