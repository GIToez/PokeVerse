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
  a flower shop with fenced gardens and a harbour pier on the bay. Ecruteak after Fuchsia (dirt
  streets, wooden houses, the Burned Tower from Fuchsia's guild hall round its overgrown court,
  lanterns and cherry trees along the avenue up to the Bell Tower), Olivine after Vermilion (grey
  stone paving, the Lighthouse from Vermilion's round guild hall on a point, a pier with boats, the
  S.S. Aqua's dock) and Cianwood after Cinnabar (an island town of dirt streets, the Pharmacy
  from Cinnabar's lab, a pier toward Route 41). Mahogany and Blackthorn both follow Lavender, the
  last Kanto town not used yet, with its slate-roofed homes and souvenir shop: Mahogany on dirt
  crossroads with lanterns, Blackthorn on dark cobblestone with Dragon's Den, a pond with a shrine
  islet north of the town. Every door gets a footpath to the paving.
- **Sites:** laid out like towns but without a temple: the National Park (a fenced lawn with
  stone walks, a fountain, flower beds, benches and trees, where the park's own Pokémon spawn),
  the Ruins of Alph (sandstone courts with statues before four rock mounds, broken stones, the
  research center), Ilex Forest's shrine, the Bell Tower (Fuchsia's five-storey walled hall on a
  sandstone court) and the Moomoo Farm (farmhouse and a fenced pasture where Route 39's Pokémon
  spawn). Ilex Forest has a wall of trees from the sea to
  Union Cave's ridge, so its path is the only way from Route 34 to Azalea above ground.
- **Caves:** made like Kanto's: mountain top ground carved out of solid mountain on the floor
  below, with rocky patches, debris, stones and wall candles. The way in is an open ravine cut
  into the mountain face (no roof, so the mouth reads as a cave and not a missing tile), with
  Kanto's hole in the rock (6130) at its end, floor either side of it. The rock (919) leaves its
  own corner for the tile down-right of it to draw, so the rock round the hole is edged as round
  the ravine floor, or it shows black. Underground floors get no daylight in the client, so
  every cave has wall candles and glowing crystals along its walls (blue, pale ice, green, or a
  dim glow in Dark Cave, per cave in `CAVE_LIGHT`). A clear lane runs down the middle of every
  tunnel, so no room is cut off. The Ruins of
  Alph's chambers are single rooms under their mounds, entered by stairs from their courts.
  Lower floors are carved the same way on their own floor, joined by stairs down from the floor
  above; the Slowpoke Well is entered through a trapdoor and left by a ladder.
- **Terrain depth:** open country rises in terraced hills up to floor 4, spread evenly over the
  region (noise against its local mean), each reached by ramps from the nearest road; mountain
  ranges stand in tiers up to seven floors, with gravel and rock along their cliffs, and forests
  are thick with trees, bushes and undergrowth. Snow is dressed with stones (never the snow heap,
  486, which is a floor change).
- **Mt. Silver** (`SILVER`, `plan_silver`), the tallest mountain, climbs as in HeartGold and
  SoulSilver: a lobed, uneven cone with wide ledges round the peak, one per floor, trails wide
  enough for its wild Pokémon, and a flat summit on floor 0 (the highest floor there is). Each
  ledge is closed one way round by a shoulder of the ledge above pushed out across it (broad at
  the cliff behind, narrowing and bending as it reaches the cliff in front, `shoulder`) and the
  other way by a lake (Surf) or another such shoulder with one crooked way through it two tiles
  wide, crossing it where it is thin, opening out into a clearing closed by a ragged patch of
  trees (Cut) or rocks (Rock Smash); the build checks that nothing gets round a patch. The way
  up zigzags: from 1F (floor 8) up inside the mountain to the lower
  mountainside (floor 5), Surf across its lake, a ramp to floor 4, Cut, a ramp to floor 3, Rock
  Smash, into the 2F tunnel under the ledge above (a patch of rocks where it opens out), out on
  floor 2, Rock Smash, a ramp to floor 1, and the 3F tunnel out onto the summit. Outdoor ramps
  come three side by side and climb only north or west, so the ramp is never hidden under the
  ledge above (ice ramps on snow). Tunnel mouths are wide cuts into the cliffs; the mountain
  keeps its old height round the ravine to the cave mouth, so the mouth stays in sight. Without
  Surf a player gets no higher than caves on floor 4; Surf and Cut reach floor 3; all three
  reach the summit.
  The rest of the inside is caves (`SILVER['caves']`, `silver_caves`): off the tunnels and in
  from mouths on the ledges, winding passages that branch, loop and end blind, caverns at some
  ends, and ramps or stone cave stairs under a rock hole up to more caves on the floor above.
  Caves are kept well apart from each other and from the lakes; most have the one way in, and
  the links (`'link'`) come out again on the ledge above, joining only ledges between the same
  obstacles, so none is a way round one. They are dressed with rocky patches, debris, stones,
  wall candles and, from floor 4 up, ice crystals.
- **Copied interiors:** Kanto's Rocket Hideout (four floors under Celadon's Game Corner) goes
  under Mahogany's souvenir shop, and the basement under Celadon's guild hall under the Global
  Terminal. Each floor is cut from its box by flood fill from its stairs, leaving out Celadon's
  sewers next to it, and stairs down from a floor that is not copied are dropped.
- **Wild Pokémon:** each spawn is drawn from the HeartGold/SoulSilver land table of its route,
  weighted by the game's encounter rate averaged over morning, day and night
  (`johto_encounters.json`). Spawns stay off tiles next to mountains, since the mountain edge
  blocks. The Ruins of Alph's chambers hold Unown only (Bulbapedia has no single table for them),
  and Bulbapedia's Nidoran♀/♂ are the server's Nidorana/Nidorano. The sea routes have no land
  table, so their surf table spawns on their islands and beaches, a step back from the water
  like the cave ponds'. Spawns only go where players can walk to from a road or street, since
  wild trees and bushes can close off small pockets in the forests.
- **Kanto edits:** Kanto's unfinished, undecorated grass south of the Elite Four building; the
  pass through Kanto's mountain from the west gate to the building (including a broken ramp on
  that road that led up to nothing); the counters that closed the building's west and south
  doors. Kanto tiles next to new ground get their borders recalculated, and nothing else on them
  changes. A stray 8x7 patch of plain grass out in Goldenrod's bay (2222–2229, 773–779, nothing
  refers to it) becomes sea.

## Built so far

- **South:** New Bark Town (town 50, temple 2717,805,7), Route 29 toward Cherrygrove, Route 27,
  Tohjo Falls (river out of the ridge and on out to sea, no bridge), Route 26 to the south gate (3049,700) and
  the road from the gate to the Elite Four building's south door.
- **North:** the west gate (3049,593) and its pass to the building's west door, Route 28 with a
  pond, the Silver–Indigo range around the plateau, Mt. Silver with snowfields, its Pokémon
  Center (2921,520) and the cave mouth (2903,503,7), Mt. Silver Cave 1F on floor 8 and the climb
  to the summit (2905,400,0), with the 2F and 3F tunnels.
- **West:** Cherrygrove City (town 51, temple 2542,834,7) at the end of Route 29, Routes 30 and
  31 north to Violet City (town 52, temple 2513,564,7, with a Gym and Sprout Tower), Route 32 south with its
  Pokémon Center (2470,862), Union Cave 1F (in at 2448,881, out at 2442,962), Route 33 and
  Azalea Town (town 53, temple 2391,1038,7, with a Gym and the Slowpoke Well, B1F on floor 8
  through the trapdoor at 2405,1077). Union Cave goes down to B1F (floor 9, stairs at 2480,908)
  and B2F (floor 10, stairs at 2466,950), whose lake is left free of spawns for Lapras. Union Cave's ridge
  runs to Ilex Forest's wall of trees, so like in the games the cave and the forest are the ways
  south.
- **Goldenrod's area:** Goldenrod City (town 54, temple 2283,728,7, with a Gym, a round fountain
  with lamps and flower beds at 2320,730, and the Global Terminal's basement down the stairs at
  2326,780) on the bay, Route
  34 south with the Day-Care (2333,828), Ilex Forest and its shrine (2292,940) down to Azalea,
  Route 35 north to the National Park (2325,588), Route 36 east to Violet, and the Ruins of Alph
  (chambers at 2396,633, 2418,651, 2440,627 and 2448,655) between Route 36 and Route 32.
- **Ecruteak and the coast:** Route 37 from the National Park's north gate to Ecruteak City
  (town 55, temple 2290,409,7, with a Gym, the Burned Tower, the Dance Theater at 2340,436 on a
  lantern street, and the Bell Tower at 2295,288), Route
  38 west and Route 39 south past the Moomoo Farm (2110,440) to Olivine City (town 56, temple
  2111,499,7, with a Gym, the Lighthouse at 2076,536 and a beach market with parasols and crates
  at 2115,531). Route 40 is sea from Olivine to the
  Whirl Islands (1F on floor 8, in at 2030,607 and 2004,659), Route 41 sea on to Cianwood City
  (town 57, temple 1902,639,7, with a Gym and the Pharmacy). A strait keeps Cianwood's side apart
  from the mainland, so it is reached by Surf only.
- **The east:** Route 42 from Ecruteak past Mt. Mortar (1F on floor 8, in at 2425,384 and
  2495,382) to Mahogany Town (town 58, temple 2532,391,7, with a Gym and the souvenir shop,
  whose stairs at 2579,385 lead down to the Rocket Hideout's four floors),
  Route 43 north to the Lake of Rage, whose water Pokémon spawn on its shore. Route 44 runs east
  below a snowfield of fir trees to the Ice Path (1F, in at 2668,382 and 2708,378), under the
  ridge that walls Blackthorn City off (town 59, temple 2723,387,7, with a Gym and Dragon's Den at
  2770,335). Routes 45 and 46 run south past Dark Cave (1F, in at 2585,610 and 2690,611).
- **The rest of the layout:** Routes 47 and 48 from Cianwood to the Safari Zone (1810,560, its
  own wild Pokémon inside the fence), the Battle Frontier (2010,366) north-west of Olivine, the
  hunting grounds with trails in from the routes and wild Pokémon of their own (Olivine Cliffs,
  Arbor Woods, Lake of Life, Ecruteak Old Forest, Snowtop Mountain, Mount Quena, Rage Marshes,
  Mortar Badlands, Frozen North, Dragon Holy Land, Lake Slowpoke, Azalea South Woods), the
  anime's isles off the west coast, and sea all round; nothing in the layout's extent is left
  empty. Azalea South Woods' island runs on a little past the bottom edge to a beach, and the
  channel below it (down to y 2300) is sea, joining the open sea west of Johto to the islands'
  (a stray square of plain grass in it is made sea). The empty map west of the area (x 48-1699,
  down to y 772) and north of Kanto's coast (up to y 20, as far east as x 4327) is sea too, so the
  world's outline runs straight along the top; a strip of Kanto's floor-7 hole over its caves that
  showed next to the new sea is closed with mountain.
  Olivine's bay south of the city is a run of rounded coves, and the islands and points that reach
  the sea west of Johto end in rounded tips short of it (no straight cuts),
  and a square of plain grass off Snowtop Mountain's north coast on the base map, the only tiles
  in its chunks, is redone with the rest of the coast.
- **Getting around (as in HeartGold/SoulSilver, see Bulbapedia):** Surf from New Bark onto Route
  27 (a channel at x 2805) and again across the Tohjo river to Route 26; Route 42 is cut by two
  small lakes (x 2445 and 2475), so Mahogany's side is reached through Mt. Mortar or by Surf;
  Blackthorn's side through the Ice Path, or Dark Cave with Rock Smash (rocks across the tunnel at
  x 2604, floor 8), a cliff standing in for Route 46's one-way ledges; Cut for the jungle grass
  across the Ilex Forest path (y 918) on the way to Route 34; Surf to Cianwood, Routes 47 and 48
  on foot from there; Mt. Silver from Route 28 only (the range is walled on the west). The
  server's field moves are in `core/server/data/lib/ps/events/actions/abilities.lua` (Cut: jungle
  grass 3985, Rock Smash: rock 1285, both grow back).
- 1186 Pokémon spawns (none inside towns); Nurse Joy with Chansey in every Pokémon Center and a
  clerk in every Mart; 106 houses.
- **Not yet:** townsfolk and shop staff in the new landmarks, the towers' insides, Goldenrod's
  Magnet Train station and the rest of the Underground, Tohjo Falls' cave with Waterfall, the
  Ho-Oh Shrine, the lower floors of Mt. Mortar, the Ice Path
  and the Whirl Islands, the Gym leaders, Route 36's Sudowoodo and Route 46's one-way ledges.
  Wild Pokémon are to be redone area by area once the terrain is finished.
  The gates are open passes, since Kanto has no route gatehouses.

## Scripts with town positions

- `core/server/data/npc/scripts/nurse_joy.lua`, `CITY_BY_POS`: New Bark (2717,797,7),
  Cherrygrove (2542,826,7), Violet (2513,556,7), Azalea (2391,1030,7), Goldenrod (2283,720,7),
  Ecruteak (2290,401,7), Olivine (2111,491,7), Cianwood (1902,631,7), Mahogany (2532,383,7) and
  Blackthorn (2723,379,7) are in (`build_johto.py` prints them). The Mt. Silver and Route 32 nurses only heal, like in
  the games, so they have no entry.
- `core/server/data/lib/ps/systems/026-guide.lua` (`GUIDES`) and
  `core/server/data/npc/scripts/travels.lua` (`TRAVELS`): entries go in when a Johto town gets a
  guide NPC or a travel stop.
