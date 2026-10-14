# mapper/

Everything needed to edit the PokeVerse world in Remere's Map Editor (RME), kept apart from the
live map so work in progress never reaches the server by accident.

| Folder | Contents |
| --- | --- |
| `RME/` | RME 8.54 (Windows). `data/854/` holds the server's `items.otb` and `items.xml`, and a `creatures.xml` generated from the server's monsters and NPCs. |
| `client/` | `Tibia.dat` / `Tibia.spr`: the game's sprites (copies of `core/client-legacy/data/things`). |
| `map/` | `johto-wip.otbm` with its `map-spawn.xml` and `map-house.xml`: the work copy. |

The live map in `core/server/data/world/` is only changed by `scripts/mapper/publish.py`.

## Opening the map in RME

1. Run `mapper/RME/RME.exe`.
2. On first start (or in *File > Preferences > Client Version*), pick client **8.54** and set its
   folder to `mapper/client`.
3. *File > Open* `mapper/map/johto-wip.otbm`. Spawns and houses load from the same folder.

## Scripts (`scripts/mapper/`)

| Script | Use |
| --- | --- |
| `sync.py` | Refreshes `RME/` (items, creatures) and `client/` from the server and client. `--reset-map` replaces `map/` with a fresh copy of the live map. |
| `build_johto.py` | Generates the Johto pieces built so far on top of the live map and writes `map/`. |
| `render.py` | Renders part of a map with the real sprites: `render.py <map> x0 y0 x1 y1 out.png [--floor 7] [--scale 0.5]`. |
| `verify.py` | Checks a map the way the server loads it (node tree, duplicate tiles, unknown items, houses, spawns). |
| `publish.py` | Verifies `map/` and copies it over the live map files. |
| `fetch_encounters.py` | Re-downloads the HeartGold/SoulSilver encounter tables into `johto_encounters.json` (only needed if the tables change). |

`build_johto.py` always starts from the live map, so running it again throws away hand edits in
`map/`. Once hand editing starts, edit in RME only.

## How the Johto generator works

- **Layout:** `johto_layout.py` holds the approved concept (towns, routes, landmarks, coarse land,
  mountain, forest and water masks). `build_johto.py` refines it to single tiles with noise so
  edges are irregular.
- **Ground and borders:** ground items come from RME's ground brushes (`grounds.xml`) with the
  brush's own variation chances. `autoborder.py` is a port of RME's auto-border, checked against
  Kanto: it gives the same borders on 99.8% of Route 1's tiles.
- **Decoration:** grass tufts, bushes, trees, ferns, flowers and stones use the same items and
  rates as Kanto's Route 1, clustered into groves and forests.
- **Buildings:** copied tile for tile from Pallet Town (Pokémon Center with Nurse Joy, Oak's lab,
  two house types). House tiles get new house ids in `map-house.xml`.
- **Caves:** made like Kanto's: mountain top ground carved out of solid mountain on the floor
  below, with rocky patches, debris, stones and wall candles. The way in is Kanto's stairs
  (22709 outside, 22702 below ground one tile north of it).
- **Wild Pokémon:** each spawn is drawn from the HeartGold/SoulSilver land table of its route,
  weighted by the game's encounter rate averaged over morning, day and night
  (`johto_encounters.json`). Spawns stay off tiles next to mountains, since the mountain edge
  blocks.
- **Kanto edits:** Kanto's unfinished, undecorated grass south of the Elite Four building; the
  pass through Kanto's mountain from the west gate to the building (including a broken ramp on
  that road that led up to nothing); the counters that closed the building's west and south
  doors. Kanto tiles next to new ground get their borders recalculated, and nothing else on them
  changes.

## Built so far

- **South:** New Bark Town (town 50, temple 2722,803,7), Route 29 toward Cherrygrove, Route 27,
  Tohjo Falls (river out of the ridge, wooden bridge), Route 26 to the south gate (3049,700) and
  the road from the gate to the Elite Four building's south door.
- **North:** the west gate (3049,593) and its pass to the building's west door, Route 28 with a
  pond, the Silver–Indigo range around the plateau, Mt. Silver with snowfields, its Pokémon
  Center (2921,520) and the cave mouth (2903,503,7), and Mt. Silver Cave 1F on floor 8.
- 465 Pokémon spawns, and Nurse Joy with Chansey in both Pokémon Centers.

## Scripts with town positions

- `core/server/data/npc/scripts/nurse_joy.lua`, `CITY_BY_POS`: New Bark's nurse (2722,795,7) is
  in. Mt. Silver's nurse only heals, like in the games, so it has no entry.
- `core/server/data/lib/ps/systems/026-guide.lua` (`GUIDES`) and
  `core/server/data/npc/scripts/travels.lua` (`TRAVELS`): entries go in when a Johto town gets a
  guide NPC or a travel stop.
