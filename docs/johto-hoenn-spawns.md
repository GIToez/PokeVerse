# Johto and Hoenn spawning pass

Audit of where wild Pokemon spawn in Johto and Hoenn, compared with Kanto
and with Bulbapedia, plus the plan for fixing them. Nothing in
`map-spawn.xml` is changed yet; this is the plan to agree on first.

Tools:

- `scripts/mapper/spawn_audit.py` measures every region, floor and area:
  open ground, spawns, density, levels and species. It writes
  `build/spawn-audit.json`.
- `scripts/mapper/fetch_hoenn_encounters.py` reads the Bulbapedia
  Ruby/Sapphire/Emerald tables into `scripts/mapper/hoenn_encounters.json`.
  Johto already had `johto_encounters.json` from HeartGold/SoulSilver.

"Open ground" means a tile a Pokemon can stand on: not water, not inside a
house, not a protection zone. Density is spawns per 1,000 open-ground tiles.
Water Pokemon count against the shore tiles they spawn on.

## What the audit found

### Density

| Region | Surface (floor 7) | Above (hills, towers) | Below (caves) |
|---|---:|---:|---:|
| Kanto | 5.6 | 10.2 | 14.3 |
| Johto | 7.3 | 7.5 | 13.6 |
| Hoenn | 9.0 | 12.9 | 19.8 |

The averages hide the real issue, which is how evenly the spawns are spread.
The next table shows the share of player-sized screens (15 by 11 tiles) that
have at least one Pokemon:

| Region | Surface | Above | Below |
|---|---:|---:|---:|
| Kanto | 49% | 62% | 78% |
| Johto | 42% | 36% | 56% |
| Hoenn | 76% | 75% | 94% |

Johto's spawns are bunched up, with long empty stretches between them.
Hoenn is dense, but most of that density sits in the filler land around
towns ("Outskirts of ..." and "Around ..."), not on the real routes.

Kanto, used as the reference, works out to roughly:

| Area type | Spawns per 1,000 tiles |
|---|---:|
| Routes | 10 (12 on raised ground) |
| Forests and mountains | 17 to 18 |
| Caves | 19 to 21 |

### Johto

- **Species are mostly right.** 80% of Johto spawns match Bulbapedia's
  HeartGold/SoulSilver tables. Most of the rest are evolved forms placed on
  hills on purpose, such as Pidgeotto and Noctowl on Routes 29 and 30.
- **Layering is already Kanto-like.** The surface is 75% first stages, and
  raised ground is 57% second stages.
- **Caves are almost empty:**

  | Cave | Spawns |
  |---|---:|
  | Ice Path | 3 |
  | Slowpoke Well | 3 |
  | Whirl Islands | 2 |
  | Dark Cave | 5 |
  | Mt. Mortar | 5 |
  | Ruins of Alph | 6 |
  | Mt. Silver Cave | 8 |
  | Union Cave | 30 |

- **Sparse routes and areas:** Routes 28, 33, 36, 39, 40, 41, 42 and 45,
  Mt. Silver, Mount Quena, Snowtop Mountain, National Park and Lake of Rage.
- **Overfull routes:** 26, 27, 43, 46 and 47 are above Kanto density.
- **Bringing Johto to Kanto density** adds about 1,700 spawns overall:
  about 2,270 added in the sparse areas, minus the overfull ones.
- **Many "missing" species are Headbutt, fishing or Rock Smash encounters.**
  Exeggcute, Pineco, Aipom and Heracross come from Headbutt trees; Magikarp,
  Poliwag, Qwilfish and Remoraid come from fishing. Those already come from
  the Headbutt and Fishing skills, so they are left out of land spawns.

### Hoenn

- **Only 21% of spawns match Bulbapedia.** The Hoenn map arrived with a
  random mix. Some examples:

  | Area | Spawns now | Bulbapedia (Ruby/Sapphire/Emerald) |
  |---|---|---|
  | New Mauville | Manectric, Minun, Plusle, Electrike | Magnemite, Voltorb |
  | Route 113 | Treecko, Slakoth line, Skitty, Poochyena | Spinda, Sandshrew, Slugma, Skarmory |
  | Jagged Pass | Torchic, Combusken, Blaziken, Camerupt | Numel, Spoink, Machop |
  | Route 112 | Aron, Lairon, Aggron | Numel, Marill, Machop |
  | Route 119 | Seedot line, Shroomish | Oddish, Zigzagoon, Linoone, Tropius, Kecleon |
  | Route 116 | Loudred, Exploud, Delcatty | Zigzagoon, Whismur, Taillow, Nincada, Skitty |
  | Meteor Falls | Meditite, Zangoose, Spoink, Baltoy | Zubat, Solrock or Lunatone, Bagon (lower floor) |

- **Wild starters:** Torchic is on Jagged Pass and Treecko on Route 113,
  and their evolutions appear too. Kanto also has wild starters; Johto
  has none.
- **The sea routes are nearly empty.** Routes 105 to 109 and 124 to 134 have
  almost no shore spawns, so Wingull, Pelipper, Tentacool and Wailmer are
  rare. The filler areas next to them are crowded.
- **No layering:** Hoenn's caves are no harder than its routes, and raised
  ground isn't any more evolved than the surface.
- **Bringing Hoenn to Kanto density** gives about 5,870 spawns, against
  6,800 now. That is about 600 added in sparse areas and about 1,540 removed
  where it's over (mostly filler).

### Levels

Most spawns don't set a level. The game rolls one between the species'
`minLevel` and `maxLevel` in its monster file, so the species config decides
the level, not the location.

- Kanto's early commons start low: Rattata 1 to 10, Caterpie 1 to 10,
  Pidgey 5 to 15. The median Kanto minimum is 15 on the surface and 20
  above and below.
- Many Gen 2 and Gen 3 early commons start at 20 to 30: Zigzagoon,
  Poochyena, Taillow, Lotad, Seedot, Ralts, Wingull, Hoothoot, Ledyba and
  Spinarak. The exceptions are Sentret and Wurmple, which are 1 to 10. So
  Route 101 in Hoenn is harder than Route 1 in Kanto, even with the right
  species.

## Rules for the new spawns (Kanto style)

1. **Species come from Bulbapedia** for each area: HeartGold/SoulSilver for
   Johto, Ruby/Sapphire/Emerald for Hoenn. That covers grass, cave, surf
   (placed on shore tiles) and the Safari Zone. Headbutt, Rock Smash and
   fishing stay with their skills. For filler areas with no Bulbapedia page
   (Hoenn's "Outskirts" and "Around" areas, Johto's added woods and
   mountains), species come from the nearest real route.
2. **Roads get the first stages.** Tiles within a few steps of a road or
   path get the area's first-stage species. The open grass away from the
   road gets the full Bulbapedia mix.
3. **Raised floors get the next stage.** Hills and upper floors get the
   evolved forms of the area's species, like Johto's hills now and Kanto.
4. **Deeper cave floors are harder.** The entrance floor gets the area's
   lowest-level table; each floor down gets the next table or evolutions.
   Bulbapedia's per-floor tables are used where they exist (Union Cave B1F
   and B2F, Mt. Mortar, Ice Path, Seafloor Cavern, Meteor Falls, Granite
   Cave, Shoal Cave, Mt. Pyre).
5. **Density follows Kanto by area type:** routes 10, forests and mountains
   17, caves 20 spawns per 1,000 open tiles. Spawns are spread across the
   area, not clumped, so the share of screens with a Pokemon matches Kanto.
6. **Group size and respawn time stay the same** as now: about 60 seconds,
   with Kanto's spacing.
7. **Not touched:** Kanto, the Orange Islands, Battle Tower, the Rocket
   Hideout, Bell Tower, towns, houses, Legendary spots, and NPC and quest
   spawns.

## Special spawns

The full list for both regions is saved in
[upcoming-features.md, section 29](upcoming-features.md#29-special-spawns-from-the-games-two-built).
Two are built (`106-rareSpawns.lua`):

- **Red Gyarados** at the Lake of Rage: back 6 hours after it is caught or defeated.
- **Lapras** on Union Cave B2F: Fridays only, back 3 hours after it is caught or defeated.

Where they spawn:

- [Lake of Rage](concepts/rare-spawns/redGyarados.png)
- [Union Cave B2F](concepts/rare-spawns/fridayLapras.png)

## Implementation plan

1. **Spawn generator** (`scripts/mapper/build_region_spawns.py`). It works
   area by area for Johto and Hoenn:
   - removes the area's current wild spawns (NPC, quest, Legendary and
     special spawns are kept by name list);
   - finds road tiles by ground item id and marks them as the "road" zone;
   - places spawns evenly at the area's target density;
   - picks species from Bulbapedia using rules 1 to 4;
   - writes them back to `map-spawn.xml` in the same format.

   It is run once and the result committed, like `build_johto.py`.
   `spawn_audit.py` is rerun afterwards to check density, screen coverage
   and the Bulbapedia match.
2. **Special spawns:** the Red Gyarados and the Friday Lapras are built
   in `106-rareSpawns.lua`. The rest are planned in the future features
   list.
3. **Server test checks:**
   - every Johto and Hoenn area is within density bounds;
   - no species outside its Bulbapedia list (plus evolutions on raised or
     deeper floors);
   - caves get harder going down.

## Decided (October 31)

- **Kanto is not touched.** Only Johto and Hoenn spawns change.
- **Levels stay the species' own** (`minLevel` to `maxLevel`). The first Johto routes start
  around level 20, which is fine. Roads still feel easier because they get the first stages,
  which have the lowest levels.
- **Wild starters stay**, as in Kanto, but only in a few special areas. Hoenn's Torchic on
  Jagged Pass and Treecko on Route 113 move to one special spot each, and their evolutions
  come off the general routes.
- **Water Pokemon spawn on land by the water:** along the coast, on islands and around lakes
  and cave pools. Underwater spawns come with diving later.
- **Special spawns** go on the future features list, except the Red Gyarados and the Friday
  Lapras.

## Still to decide

- **Hoenn's crowded filler areas** (the "Outskirts of ..." and "Around ..." land): bring them
  down to Kanto density, or only fill the sparse areas and leave them as they are.
