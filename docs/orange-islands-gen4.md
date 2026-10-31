# Orange Islands: Gen 4 evolutions

**Status: live.** `scripts/mapper/orange-gen4-spawns.py` wrote the spawns below into
`world/map-spawn.xml` (and the mapper copy): 112 spawns changed and 8 added.

Sinnoh comes later as its own region, with the Sinnoh families (Turtwig, Starly, Shinx, Gible,
Riolu and the rest) and the Gen 4 legendaries. Until then, the Orange Islands, the high-level
area with Pokémon from every generation, get the **Gen 4 evolutions of older Pokémon**, each one
where its pre-evolution already spawns.

## The rule

- A Gen 4 evolution only goes to an area where its pre-evolution spawns today.
- About **1 for every 5** of the pre-evolution's spawns in that area, at least 1. Areas with
  fewer than 3 of the pre-evolution get none (except where that's the only spot).
- Each one **replaces** a spawn of its pre-evolution on the same tile, so the area keeps the
  same number of Pokémon and the same look; it just gets a rarer, stronger one mixed in.
- Spawn time and level work like the spawn it replaces, so the rarity follows the Pokémon:
  Togekiss and Lickilicky keep the 45-minute spawns of the Togetic and Lickitung they replace,
  the rest respawn every minute like their pre-evolutions.

Counts come from `world/map-spawn.xml`; island is the nearest town, area is the name the area
banner shows (`scripts/make-legendary-anchors.py`'s lookup).

## Spawns

| Gen 4 | Evolves from | Where its pre-evolution spawns (island: area, count) | Spawns |
|---|---|---|---|
| **Magnezone** | Magneton (60 + Thunder Stone) | Shamouti: Lightning Island 32; Hamlin: Power Plant of Hamlin 16; Mandarin North: Venomous Jungle 13; Mandarin North: Mountain House 1; Mandarin North: unnamed spot 1 | 6 at Lightning Island (Shamouti), 3 at Power Plant of Hamlin (Hamlin), 3 at Venomous Jungle (Mandarin North) |
| **Electivire** | Electabuzz (60 + Electirizer) | Shamouti: Lightning Island 10; Hamlin: Power Plant of Hamlin 3; Mandarin North: Venomous Jungle 2 | 2 at Lightning Island (Shamouti), 1 at Power Plant of Hamlin (Hamlin) |
| **Magmortar** | Magmar (60 + Magmarizer) | Shamouti: Fire Island 6; Pinkan: Fairchild Cave 4 | 1 at Fire Island (Shamouti), 1 at Fairchild Cave (Pinkan) |
| **Rhyperior** | Rhydon (60 + Protector) | Sunburst: Crystal Cave 10; Kumquat: Great Mountain 8; Pinkan: Mountain Living Stone 7; Trovitopolis: Desert Mandarin Cave 6; Kumquat: Earth Society Cave 4; Pummelo: Desert Island #3 Cave 2; Shamouti: Mountain of Prophecy 1 | 2 at Crystal Cave (Sunburst), 2 at Great Mountain (Kumquat), 1 at Mountain Living Stone (Pinkan), 1 at Desert Mandarin Cave (Trovitopolis), 1 at Earth Society Cave (Kumquat) |
| **Mamoswine** | Piloswine (60) | Navel: Mountain High 24; Mandarin North: Refuge Cold 8; Shamouti: Ice Island 7; Kumquat: Earth Society Cave 7 | 5 at Mountain High (Navel), 2 at Refuge Cold (Mandarin North), 1 at Ice Island (Shamouti), 1 at Earth Society Cave (Kumquat) |
| **Togekiss** | Togetic (60 + Shiny Stone) | Moro: Forgotten Temple 4 | 1 at Forgotten Temple (Moro) |
| **Tangrowth** | Tangela (40) | Seven Grapefruit: Seven Grapefruit #2 14; Pummelo: Pummelo Forest 12; Murcott: Desert Island #2 12; Trovitopolis: Trovita 9; Moro: Living Jungle 8; Moro: Goldeen 8; Seven Grapefruit: Grape Mountain 5; Mandarin South 02: Living Jungle 3; Desert Island 92: Seven Grapefruit #2 3; Mandarin South 02: Goldeen 2; Mandarin South 01: Goldeen 1 | 3 at Seven Grapefruit #2 (Seven Grapefruit), 2 at Pummelo Forest (Pummelo), 2 at Desert Island #2 (Murcott), 2 at Trovita (Trovitopolis), 2 at Living Jungle (Moro), 2 at Goldeen (Moro), 1 at Grape Mountain (Seven Grapefruit), 1 at Living Jungle (Mandarin South 02), 1 at Seven Grapefruit #2 (Desert Island 92) |
| **Yanmega** | Yanma (40) | Valencia: Woodland 18; Seven Grapefruit: Seven Grapefruit #3 12; Mandarin South 02: Forested Region 12; Butwal: Insect Jungle 11; Butwal: Mountain Cleopatra 2; Valencia: Valencia 1; Mandarin South 01: Forested Region 1; Butwal: unnamed spot 1 | 4 at Woodland (Valencia), 2 at Seven Grapefruit #3 (Seven Grapefruit), 2 at Forested Region (Mandarin South 02), 2 at Insect Jungle (Butwal) |
| **Gliscor** | Gligar (40 + Razor Fang, night) | Desert Island 92: Cavern 14; Hamlin: Tunnel of Salvation 10; Hamlin: unnamed spot 4; Mandarin North: Mountain House 1 | 3 at Cavern (Desert Island 92), 2 at Tunnel of Salvation (Hamlin), 1 at an unnamed spot (Hamlin) |
| **Weavile** | Sneasel (40 + Razor Claw, night) | Shamouti: Ice Island 30; Navel: Mountain High 11; Mandarin North: Refuge Cold 3; Pummelo: Refuge Cold 1 | 6 at Ice Island (Shamouti), 2 at Mountain High (Navel), 1 at Refuge Cold (Mandarin North) |
| **Honchkrow** | Murkrow (40 + Dusk Stone) | Desert Island 92: Green Mountain 13; Kumquat: Forest North 12; Desert Island 92: Kinnow 7; Mandarin South 02: Forested Region 6; Desert Island 92: Great Beach 4; Mandarin South 01: Forested Region 1; Desert Island 92: Dangerous Grotto 1 | 3 at Green Mountain (Desert Island 92), 2 at Forest North (Kumquat), 1 at Kinnow (Desert Island 92), 1 at Forested Region (Mandarin South 02), 1 at Great Beach (Desert Island 92) |
| **Mismagius** | Misdreavus (40 + Dusk Stone) | Moro: Castle Fear 12; Desert Island 92: Haunted Tomb 12; Moro: Haunted Tomb 10; Moro: unnamed spot 3; Desert Island 92: Earth Cavern 3 | 2 at Castle Fear (Moro), 2 at Haunted Tomb (Desert Island 92), 2 at Haunted Tomb (Moro), 1 at an unnamed spot (Moro), 1 at Earth Cavern (Desert Island 92) |
| **Ambipom** | Aipom (40) | Kumquat: Forest North 13; Shamouti: Meadow 10; Kumquat: Around the Kumquat 3 | 3 at Forest North (Kumquat), 2 at Meadow (Shamouti), 1 at Around the Kumquat (Kumquat) |
| **Lickilicky** | Lickitung (40) | Shamouti: Meadow 2 | 1 at Meadow (Shamouti) |

Total: 98 spawns, replacing the same number of pre-evolution spawns.

## Gen 3 and Eevee evolutions (habitat spots)

Their pre-evolutions don't spawn in the Orange Islands, so each takes 2 spawns of a Pokémon of the
same habitat, on the same tiles and spawn times.

| Gen 4 | Evolves from | Spawns (replacing) |
|---|---|---|
| Gallade | Kirlia (Dawn Stone) | 2 at Forgotten Temple (Moro), replacing Kadabra |
| Froslass | Snorunt (Dawn Stone) | 2 at Ice Island (Shamouti), replacing Jynx |
| Glaceon | Eevee (Ice Stone) | 2 at Ice Island (Shamouti), replacing Dewgong |
| Dusknoir | Dusclops (Reaper Cloth) | 2 at Castle Fear (Moro), replacing Gengar |
| Probopass | Nosepass (Thunder Stone) | 2 at Crystal Cave (Sunburst), replacing Golem |
| Roserade | Roselia (Shiny Stone) | 2 at Pummelo Forest (Pummelo), replacing Victreebel |
| Leafeon | Eevee (Leaf Stone) | 2 at Seven Grapefruit #2 (Seven Grapefruit), replacing Tangela |

## Added spawns

- **Porygon-Z:** 1 on the deepest floor of the Power Plant of Hamlin (floor 10), next to a
  Porygon2, with the 45-minute spawn time of the rest of the Porygon line.
- **Munchlax:** 1 next to each of the 3 Snorlax at Forested Region (Mandarin South 02).
- **Mantyke:** 1 next to 4 of the 7 Mantine at Submerged Desert Island #4 (Pinkan); the other
  three have no free water tile next to them.

## Babies from eggs

A Day Care egg hatches the first form of the mother's line. The Gen 4 babies now start their
lines: Snorlax lays Munchlax eggs, Mantine Mantyke, Chansey and Blissey Happiny, Mr. Mime
Mime Jr., Sudowoodo Bonsly, Roselia (and Roserade, as before) Budew, and Chimecho Chingling.
Eggs already laid keep their species (a Snorlax egg still hatches Snorlax).

## Kept for Sinnoh

The Sinnoh families and the Gen 4 legendaries: the Sinnoh region.

## The Porygon line

- Porygon: 1 spawn at the Power Plant of Hamlin and 1 in the Venomous Jungle (Mandarin North,
  floor 5), and the Pokemon Surprise Box quest reward (Mr. Mime, Porygon or Ditto).
- Porygon2: 3 spawns at the Power Plant of Hamlin, or Porygon at level 55 with an Up-Grade.
- Porygon-Z: 1 spawn at the Power Plant of Hamlin, or Porygon2 at level 60 with a Dubious Disc.
- All of them respawn every 45 minutes.
- Up-Grade and Dubious Disc, like every evolution item: the weekly PokeTrader auction (a 30%
  chance each week of one rare item, out of 28), and rare drops from Pokémon that already
  evolved (Up-Grade from Porygon2, the Dubious Disc from Porygon-Z). The Up-Grade is also a
  quest reward. The item NPCs (Alton Dane and the others) only buy them.
