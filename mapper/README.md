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
- **Buildings:** copied tile for tile from Kanto (all floors, roofs included): Pallet Town's
  Pokémon Center with Nurse Joy, Oak's lab, Viridian's Mart with its clerk and Gym, and the homes
  and landmarks the towns borrow from their Kanto mirror (see `johto_towns.py`). House tiles get
  new house ids in `map-house.xml` (rent 0); landmarks are not houses.
- **Towns:** `johto_towns.py` lays out each town after its Kanto mirror, as approved: New Bark
  after Pallet (dirt lanes, Elm's lab with a research yard and greenhouse, farm sheds, a hay
  paddock, windmills with a wheel on the roof, a harbour with a pier and boats), Cherrygrove after
  Viridian (grey stone paving, a river with bridges, the festival plaza with a stage and lanterns,
  cherry trees, the police box, Guide Gent's house, a beach boardwalk with parasols, islets),
  Violet after Pewter (dark cobblestone, Sprout Tower on an island in a moat, the Academy and its
  schoolyard, the theatre, a market lane, farm plots, the Gym) and Azalea after Cerulean
  (cobblestone, Kurt's house in a fenced Apricorn grove, the charcoal kiln yard, the Slowpoke
  Well, a river with a bridge, the Gym). Goldenrod is the big city, after Saffron with
  Celadon's department store: grey stone paving in a grid of two avenues and a ring of side
  streets, a fountain square, the Radio Tower (Saffron's six-storey guild hall), the department
  store, the Game Corner (Saffron's café), the Global Terminal (Celadon's guild hall), the Gym,
  a flower shop with fenced gardens and a harbour pier on the bay. Every door gets a footpath to
  the paving.
- **Sites:** laid out like towns but without a temple: the National Park (a fenced lawn with
  stone walks, a fountain, flower beds, benches and trees, where the park's own Pokémon spawn),
  the Ruins of Alph (sandstone courts with statues before four rock mounds, broken stones, the
  research center) and Ilex Forest's shrine. Ilex Forest has a wall of trees from the sea to
  Union Cave's ridge, so its path is the only way from Route 34 to Azalea above ground.
- **Caves:** made like Kanto's: mountain top ground carved out of solid mountain on the floor
  below, with rocky patches, debris, stones and wall candles. The way in is a corridor cut into
  the mountain under a floor-6 roof, like Kanto's passages, with Kanto's stairs (22709) at its
  end. A clear lane runs down the middle of every tunnel, so no room is cut off. The Ruins of
  Alph's chambers are single rooms under their mounds, entered by stairs from their courts.
- **Wild Pokémon:** each spawn is drawn from the HeartGold/SoulSilver land table of its route,
  weighted by the game's encounter rate averaged over morning, day and night
  (`johto_encounters.json`). Spawns stay off tiles next to mountains, since the mountain edge
  blocks. The Ruins of Alph's chambers hold Unown only (Bulbapedia has no single table for them),
  and Bulbapedia's Nidoran♀/♂ are the server's Nidorana/Nidorano.
- **Kanto edits:** Kanto's unfinished, undecorated grass south of the Elite Four building; the
  pass through Kanto's mountain from the west gate to the building (including a broken ramp on
  that road that led up to nothing); the counters that closed the building's west and south
  doors. Kanto tiles next to new ground get their borders recalculated, and nothing else on them
  changes. A stray 8x7 patch of plain grass out in Goldenrod's bay (2222–2229, 773–779, nothing
  refers to it) becomes sea.

## Built so far

- **South:** New Bark Town (town 50, temple 2717,805,7), Route 29 toward Cherrygrove, Route 27,
  Tohjo Falls (river out of the ridge, wooden bridge), Route 26 to the south gate (3049,700) and
  the road from the gate to the Elite Four building's south door.
- **North:** the west gate (3049,593) and its pass to the building's west door, Route 28 with a
  pond, the Silver–Indigo range around the plateau, Mt. Silver with snowfields, its Pokémon
  Center (2921,520) and the cave mouth (2903,503,7), and Mt. Silver Cave 1F on floor 8.
- **West:** Cherrygrove City (town 51, temple 2542,834,7) at the end of Route 29, Routes 30 and
  31 north to Violet City (town 52, temple 2513,564,7, with a Gym and Sprout Tower), Route 32 south with its
  Pokémon Center (2470,862), Union Cave 1F (in at 2448,881, out at 2442,962), Route 33 and
  Azalea Town (town 53, temple 2391,1038,7, with a Gym and the Slowpoke Well). Union Cave's ridge
  runs to Ilex Forest's wall of trees, so like in the games the cave and the forest are the ways
  south.
- **Goldenrod's area:** Goldenrod City (town 54, temple 2283,728,7, with a Gym) on the bay, Route
  34 south with the Day-Care (2333,828), Ilex Forest and its shrine (2292,940) down to Azalea,
  Route 35 north to the National Park (2325,588), Route 36 east to Violet, and the Ruins of Alph
  (chambers at 2396,633, 2418,651, 2440,627 and 2448,655) between Route 36 and Route 32.
- 710 Pokémon spawns (none inside towns); Nurse Joy with Chansey in every Pokémon Center and a
  clerk in every Mart; 63 houses.
- **Not yet:** townsfolk and shop staff in the new landmarks, Sprout Tower's and the Slowpoke
  Well's insides, Goldenrod's Magnet Train station and Underground, Dark Cave, the cave floors
  below 1F and the Gym leaders; Route 37 north of the park, the north (Ecruteak, Mahogany,
  Blackthorn, Ice Path) and the coast (Olivine, Cianwood). The gates are open passes, since
  Kanto has no route gatehouses.

## Scripts with town positions

- `core/server/data/npc/scripts/nurse_joy.lua`, `CITY_BY_POS`: New Bark (2717,797,7),
  Cherrygrove (2542,826,7), Violet (2513,556,7), Azalea (2391,1030,7) and Goldenrod (2283,720,7)
  are in (`build_johto.py` prints them). The Mt. Silver and Route 32 nurses only heal, like in
  the games, so they have no entry.
- `core/server/data/lib/ps/systems/026-guide.lua` (`GUIDES`) and
  `core/server/data/npc/scripts/travels.lua` (`TRAVELS`): entries go in when a Johto town gets a
  guide NPC or a travel stop.
