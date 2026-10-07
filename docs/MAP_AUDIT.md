# World map audit

Read-only audit of `server/runtime-data/data/world/map.otbm` together with `map-spawn.xml`, `map-house.xml`, `monster/monsters.xml`, `npc/*.xml` and `items/items.otb`.

Regenerate the statistics below (they take about 15–20 s and peak at about 350 MB of RAM, standard library only):

```bash
python3 tools/map_audit.py                              # print Markdown report to stdout
python3 tools/map_audit.py --output /tmp/map_stats.md   # write it to a file
```

Everything from "OTBM header" down is the script's output, unchanged. The summary and notes in this section were written by hand.

## Summary

- The map is OTBM version 2, declared 5879 x 3541, and was saved with Remere's Map Editor 3.7.0. It references items.otb 3.16, which matches the `items.otb` on disk (3.16.461).
- It has 5,006,599 tiles on all 16 floors (z 0–15). Floor 7 holds 2.2 M of them (44 %).
- There are 17 towns. Towns 1–9 and 32 are the Kanto cities (Viridian, Pewter, Cerulean, Saffron, Celadon, Vermilion, Lavender, Fuchsia, Cinnabar, Pallet). Towns 34–40 are service or test areas: Tutorial, Trade center, teste, pvp, tutorial, clas, Market. Every temple position sits on an existing tile. The map has no waypoints.
- The 196 houses in `map-house.xml` match the house ids on house tiles exactly in both directions. Every house belongs to one of towns 1–9.
- `map-spawn.xml` has 8,822 spawn zones with 8,888 monster entries (196 distinct names) and 662 NPC entries (452 distinct names). Every monster name resolves in `monsters.xml` and every NPC name resolves to an `npc/*.xml` file. Every spawn center and every individual monster and NPC position lands on an existing tile. That last check was exhaustive, not sampled.

## Integrity findings

None of these are blocking errors. They are things worth knowing about.

| Finding | Detail |
|---|---|
| 20 empty `<spawn>` zones | The zones have no monster or NPC children. The server ignores them, but they are clutter. |
| Duplicate or near-duplicate towns | Town 36 `teste` and town 40 `Market` share the temple position 4589,136,7. Towns 34 `Tutorial` and 38 `tutorial` differ only in letter case. Towns `teste`, `pvp` and `clas` look like leftover test entries. |
| Pallet (32) and Tutorial (34) temples are on floor 6 | Every other city temple is on floor 7. This is probably intentional (an upper floor of a building), but worth checking. |
| 412,395 tiles have no GROUND-group item | Only 823 of these tiles are completely empty (no items at all). The rest have items such as borders, walls or decorations but no ground from the items.otb GROUND group. In practice these are mostly border or void tiles stacked over other floors. |
| Scattered content west of x≈2500 | About 57 k tiles lie at x<2500, y<2500. They include a tile column starting at (1,1,7) and a large rectangular outline south of the main continent (see the overview). The main game area is roughly x 3000–5900, y 0–2000. |
| NPCs spawned many times | 40 NPC names have more than one spawn entry. Most are expected (Nurse Joy 60, Nurse Chansey 24, Police Officer 23). Substitute (15) and Target (7) are probably arena or minigame dummies. |
| `monsters.xml` is far larger than what spawns | It defines 1,173 monsters, but only 196 distinct names appear in spawns. The rest are evolutions, bosses, events or clones that are spawned from scripts. |

## Method notes

- The script streams the node tree, which uses 0xFD escape, 0xFE node start and 0xFF node end. It handles TILE_AREA, TILE, HOUSETILE, ITEM, TOWN and WAYPOINT nodes. It reads tile flags (attribute 3) and the inline ground item (attribute 9).
- "Ground" means an item whose items.otb group is GROUND (1), either inline or as a direct child ITEM node.
- Spawn child `x`/`y` values are offsets from the spawn center. Positions use `centerz`; every child `z` equals `centerz` anyway.
- NPC names are matched case-insensitively against both the `npc/*.xml` file name and the `<npc name="">` attribute. The `npc/backup/` folder is excluded.
- Monster names are matched case-insensitively against `monsters.xml`. The script also verifies that every `file=` it references exists.

## OTBM header

| Field | Value |
|---|---|
| File identifier | 00000000 |
| OTBM version | 2 |
| Declared width x height | 5879 x 3541 |
| items.otb version referenced by map (major.minor) | 3.16 |
| items.otb on disk (major.minor.build) | 3.16.461 |
| Description strings | "Saved with Remere's Map Editor 3.7.0"<br>'No map description available.' |
| Spawn file | map-spawn.xml |
| House file | map-house.xml |

## Tiles

| Metric | Value |
|---|---|
| X range (actual) | 1 .. 5879 |
| Y range (actual) | 1 .. 3541 |
| Occupied tiles | 5,006,599 |
| House tiles | 34,050 |
| Protection-zone tiles (flag 0x01) | 59,579 |
| Tiles without a ground-group item | 412,395 |
| ...of which tiles with no items at all | 823 |
| Duplicate tile positions (ignored) | 0 |

Tiles per floor:

| z | Tiles |
|---|---|
| 0 | 25,793 |
| 1 | 32,951 |
| 2 | 54,417 |
| 3 | 115,825 |
| 4 | 254,338 |
| 5 | 389,440 |
| 6 | 558,245 |
| 7 | 2,200,946 |
| 8 | 490,963 |
| 9 | 445,887 |
| 10 | 249,655 |
| 11 | 103,515 |
| 12 | 37,214 |
| 13 | 22,556 |
| 14 | 15,936 |
| 15 | 8,918 |

## Towns (OTBM TOWNS node)

| ID | Name | Temple (x, y, z) | Temple tile exists |
|---|---|---|---|
| 1 | Viridian | 3254, 564, 7 | yes |
| 2 | Pewter | 3306, 298, 7 | yes |
| 3 | Cerulean | 3883, 316, 7 | yes |
| 4 | Saffron | 3932, 476, 7 | yes |
| 5 | Celadon | 3700, 438, 7 | yes |
| 6 | Vermilion | 3968, 643, 7 | yes |
| 7 | Lavender | 4190, 554, 7 | yes |
| 8 | Fuchsia | 3859, 847, 7 | yes |
| 9 | Cinnabar | 3369, 1050, 7 | yes |
| 32 | Pallet | 3332, 806, 6 | yes |
| 34 | Tutorial | 5000, 806, 6 | yes |
| 35 | Trade center | 4663, 136, 10 | yes |
| 36 | teste | 4589, 136, 7 | yes |
| 37 | pvp | 4834, 135, 10 | yes |
| 38 | tutorial | 5020, 789, 7 | yes |
| 39 | clas | 4742, 1406, 7 | yes |
| 40 | Market | 4589, 136, 7 | yes |

Waypoints: 0



## Houses (map-house.xml)

| Metric | Value |
|---|---|
| Houses in XML | 196 |
| Sum of `size` | 23,383 |
| Distinct house ids on house tiles | 196 |
| XML houses with no house tiles | 0  |
| Tile house ids without XML entry | 0  |
| Duplicate house ids in XML | 0  |
| Houses whose entry position has no tile | 0 |
| Town ids referenced but not in TOWNS node | [] |

Per town:

| Town id | Town | Houses | Total size |
|---|---|---|---|
| 1 | Viridian | 29 | 3004 |
| 2 | Pewter | 29 | 2422 |
| 3 | Cerulean | 17 | 2704 |
| 4 | Saffron | 21 | 2974 |
| 5 | Celadon | 21 | 2601 |
| 6 | Vermilion | 28 | 3271 |
| 7 | Lavender | 12 | 1961 |
| 8 | Fuchsia | 25 | 2733 |
| 9 | Cinnabar | 14 | 1713 |

## Spawns (map-spawn.xml)

| Metric | Value |
|---|---|
| Spawn zones | 8,822 |
| Empty spawn zones | 20 |
| Child entries whose `z` differs from centerz (server uses centerz) | 0 |
| Monster spawn entries | 8,888 |
| NPC spawn entries | 662 |
| Distinct monster names | 196 |
| Distinct NPC names | 452 |
| Monster names not in monsters.xml | 0 |
| Monster names matching monsters.xml only case-insensitively | 0 |
| NPC names with more than one spawn entry | 40 |
| NPC names without npc/*.xml (file name or name attr) | 0 |
| Spawn centers outside actual tile bounds | 0 |
| Spawn centers on a floor with no tiles | 0 |
| Spawn centers with no tile at that position | 0 |
| Monster entries placed on non-existent tiles (exhaustive) | 0 |
| NPC entries placed on non-existent tiles (exhaustive) | 0 |

Top 25 monsters by spawn entries:

| # | Monster | Entries |
|---|---|---|
| 1 | Gloom | 337 |
| 2 | Pidgeotto | 270 |
| 3 | Weepinbell | 265 |
| 4 | Oddish | 256 |
| 5 | Geodude | 228 |
| 6 | Metapod | 221 |
| 7 | Dugtrio | 211 |
| 8 | Pidgey | 210 |
| 9 | Ekans | 205 |
| 10 | Grimer | 186 |
| 11 | Bellsprout | 180 |
| 12 | Butterfree | 180 |
| 13 | Zubat | 179 |
| 14 | Rattata | 175 |
| 15 | Diglett | 173 |
| 16 | Caterpie | 170 |
| 17 | Kakuna | 155 |
| 18 | Rocket Grunt Main | 122 |
| 19 | Gastly | 117 |
| 20 | Graveler | 110 |
| 21 | Weedle | 110 |
| 22 | Beedrill | 103 |
| 23 | Spearow | 94 |
| 24 | Kadabra | 92 |
| 25 | Muk | 89 |

Monster names in spawns not defined in monsters.xml (name: entries):

(none)

NPC names in spawns without an NPC definition (name: entries):

(none)

## Monster / NPC definition files

| Metric | Value |
|---|---|
| Entries in monsters.xml | 1173 |
| monsters.xml entries whose file is missing | 0 |
| npc/*.xml files | 910 |
| NPC xml files with unreadable name | 0 |

## Floor 7 density overview

Each character = 62x62 tiles, origin (1, 1) top-left; ramp ` .:-=+*#%@` = empty -> full.

```
@:                                    ..
-.                                    :.                         :.     .++.:+=+****#*=%%%%:-==
                                                        .:. -+-#%@===-. :@@:-:+%%@@*%*=@@@@-#@%
                                                  .=-=-:%@+-+#*@@@@@@%   %@   *#%@@*%*=@@@@-*%*
                                                  .@@@@@@@@@@@@@@@@@@%   #%   -***#**@%@@@@-.#-
                                                  :@@@@@@@@@@@@@=%@@@%        .=*#*=+@##=--. :.
                                                 .-@@@@@@@@@@@@@..+@@%     *###-*%+#:%*%::*: .
                                                 %@@@@@@@@@@@@@@@**@@%     #@@@=+%+::#=  :*:
                                                 %@@@@@@@@@@@@@@@@@@@%     #@@@@+*=-:  :
                                                 %@@@@@@@@@@@@@@@@@@@@=    %@@@@*#=:@@--.
                                                 %@@@@@@@@@@@@@@@@@@@@*    =#@@@-: :@@-*-
                                                 %@@@@@@@@@@@@@@@@@@@%:    .=*#*-: .::...
                                   .             %@@@@@@@@@@@@@@@@@+@%         *+=
                                                 %@@@@@@@@@@@@@@@@@@@%     ===: -.
                                                 %@@@@@@@@@@@@@@@@@@@%     %@@=
                                                 %@@@#*@@@@@@@@@@@@@@%     %@@+%=#**#+#+#-
                                               #@@@@@@@@@@@@@@@@@@@@@%.    %@%.+--*:#.#:+=
                                               %@@@@@@@@@@@@@@@@@@@@@%     %@%-@-%*#%+@=@-
                                               %@@@@@@@@@@@@@@@@@@@@@%     :-:-#.#:*-=+-*
                                               %@@@@@@@@@@@@@@@@@@@@@%        .#==#-%:%-#=
                                          .....%@@@@@@@@@@@@@@@@@@@@@%......    . . . ....
                                          -:::::::::::::::::::::::::::::::::..   ..  ..:.....
                                          :                               .-@@@%@%@%%%@@@@@@@*
                                          :                               .:====%%++-+=--+*%#*
                                          :                               .:    ..
                                          :                               .:
                                          :                               .:
                                          :                               .:
                                          :                               .:
                                          :                               .:
                                          :                               .:
                                          :                               .:
                                          :                               .:
                                          :                               .:
                                          :                               .:
                                          :                               .:
                                          :                               .:
                                          :                               .:
                                          :                               .:
                                          :                               .:
                                          :                               .:
                                          :                               .:
                                          :                               .:
                                          :                               .:
                                          :                               .:
                                          :                               .:
                                          :                               .:
                                          :                               .:
                                          :                               .:
                                          :                               .:
                                          :                               .:
                                          :                               .:
                                          :                               .:
                                          :                               .:
                                          :                               .:
                                          :                               .:
                                          :...............................::
                                          .::::::::::::::::::::::::::::::::.
```

## Parse notes

- items.otb items in GROUND group: 4444
- Parse time: 15.7 s
- No OTBM parse warnings.
