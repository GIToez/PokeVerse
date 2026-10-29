# Future generations: Gen 4 to 6

Everything needed to add Pokémon #387 Turtwig to #718 Zygarde. The game has #1 to #386 today
and will have 718 when this is done. Gen 7 and later are not part of this: there are no faces
for them yet. We have permission to use PAdventures' art.

The plan is also summed up in [upcoming-features.md](upcoming-features.md#23-new-pokémon-gen-4-to-6).
[`gen4-6-checklist.csv`](gen4-6-checklist.csv) has one row per Pokémon: what it evolves from
and how, its PAdventures face, where its walk sprite comes from, and a column for the approved
walk sprite.

## Links

Bulbapedia and The Spriters Resource block scripts (a Cloudflare check), but they open in a
browser.

| What | Link |
| --- | --- |
| Bulbapedia page (stats, Pokédex text, evolutions) | `https://bulbapedia.bulbagarden.net/wiki/<Name>_(Pokémon)`, e.g. [Turtwig](https://bulbapedia.bulbagarden.net/wiki/Turtwig_(Pok%C3%A9mon)) |
| PokéAPI species (Pokédex text, evolution chain, legendary/baby) | `https://pokeapi.co/api/v2/pokemon-species/<number>/`, e.g. [387](https://pokeapi.co/api/v2/pokemon-species/387/) |
| PokéAPI Pokémon (base stats, types, abilities, moves) | `https://pokeapi.co/api/v2/pokemon/<number>/`, e.g. [387](https://pokeapi.co/api/v2/pokemon/387/) |
| PokéAPI evolution chain | `https://pokeapi.co/api/v2/evolution-chain/<id>/` (the id is in the species) |
| All 332 species at once | [pokemon-species?limit=332&offset=386](https://pokeapi.co/api/v2/pokemon-species?limit=332&offset=386) |
| Portrait (Showdown Gen 5 sprites, what ours are) | `https://play.pokemonshowdown.com/sprites/gen5/<name>.png`, e.g. [turtwig](https://play.pokemonshowdown.com/sprites/gen5/turtwig.png) |
| Shiny portrait | `https://play.pokemonshowdown.com/sprites/gen5-shiny/<name>.png` |
| 3D Pokédex picture (animated model) | `https://play.pokemonshowdown.com/sprites/ani/<name>.gif`, e.g. [turtwig](https://play.pokemonshowdown.com/sprites/ani/turtwig.gif) |
| Shiny 3D picture | `https://play.pokemonshowdown.com/sprites/ani-shiny/<name>.gif` |
| Cry (convert to `.ogg`) | `https://play.pokemonshowdown.com/audio/cries/<name>.mp3`, e.g. [turtwig](https://play.pokemonshowdown.com/audio/cries/turtwig.mp3) |
| Smogon sprite project (credit for the Gen 6+ Showdown sprites) | [smogon.com thread](https://www.smogon.com/forums/threads/smogon-sprite-project.3647722/) |
| PAdventures sprites (faces, Pokédex tiles, walk sprites) | [DistTopic/padventures-sprites](https://github.com/DistTopic/padventures-sprites) |
| PAdventures item (faces are items 13825 to 14591) | `https://raw.githubusercontent.com/DistTopic/padventures-sprites/main/sprites/item/<id>.png`, e.g. [Turtwig, 14249](https://raw.githubusercontent.com/DistTopic/padventures-sprites/main/sprites/item/14249.png) |
| PAdventures creature (walk sprite sheet) | `https://raw.githubusercontent.com/DistTopic/padventures-sprites/main/sprites/creature/<id>.png` |
| PAdventures sizes and frame counts | [data/metadata.json](https://raw.githubusercontent.com/DistTopic/padventures-sprites/main/data/metadata.json) |
| Mystery Dungeon walk sprites (fallback) | [PMDCollab/SpriteCollab](https://github.com/PMDCollab/SpriteCollab): `sprite/<NNNN>/Walk-Anim.png` and `AnimData.xml`, e.g. [0387](https://raw.githubusercontent.com/PMDCollab/SpriteCollab/master/sprite/0387/Walk-Anim.png) |
| Battle Trozei faces (64x64, not chosen) | [The Spriters Resource, sheet 64891](https://www.spriters-resource.com/3ds/pokemonbattletrozei/sheet/64891/) |

Showdown names are lowercase with no spaces or punctuation (`mimejr`, `porygonz`,
`flabebe`). PokéAPI names use dashes (`mime-jr`, `porygon-z`).

## Sources

- **Stats, types and Pokédex text:** Bulbapedia's numbers, read from PokéAPI (the same base
  stats, Pokédex entries and evolutions) and checked against Bulbapedia by hand.
- **Swap bar faces:** PAdventures' 32x32 heads, items 13825 to 14591. These are the Battle
  Trozei drawings cropped to fill the square and cleaned up by hand, the same size and style as
  our Gen 1 to 3 faces, so they fit the current slot. All 332 are matched to a Pokédex number
  by picture (one to one, in order). They are still images: they get our 4-frame bob, and a
  blink later.
- **Pokédex:** the 3D pictures. Showdown's animated 3D models for the big picture, like our
  stills, and PAdventures' 3D Pokédex tiles for the grid. Their tiles are in several id ranges
  that still need matching to numbers.
- **Portraits:** Showdown's Gen 5 sprites, which is what ours are.
- **Cries:** Showdown, converted to `.ogg`.
- **Shiny art:** PAdventures' faces are normal colours only. Shiny faces and shiny walk
  sprites are recoloured using the colours of Showdown's shiny sprites.

## Walk sprites (outfits)

| Walk sprite | Gen 4 | Gen 5 | Gen 6 | Total |
| --- | --- | --- | --- | --- |
| 6500 pack, named with high or medium confidence | 53 | 122 | 3 | 178 |
| PAdventures creature sheet | 18 | 9 | 34 | 61 |
| 6500 pack, unsure name | 20 | 15 | 11 | 46 |
| Not found yet | 16 | 10 | 21 | 47 |

For the 93 that are unsure or not found, the rest of the PAdventures creature sheets get
searched first. The earlier search only covered the species the pack lacked. Mystery Dungeon
sprites at 2x come after that.

**Every outfit is approved one by one.** Some of the names that look right are wrong (several
showed up in the earlier review sheets), so nothing goes in on the matcher's word. For each
Pokémon:

- A review sheet shows every candidate side by side: front, side and back, at game size and
  zoomed in, with the source of each (pack code, PAdventures creature id or Mystery Dungeon).
- The pick goes in the checklist's `ApprovedWalk` column; `rejected` means none fit.
- Only approved outfits are imported.

**Better than ours.** Some pack and PAdventures sprites are better than outfits we already
have for Gen 1 to 3. They go on a separate list with ours next to the candidate, and nothing
we have is replaced without approval. Places to look:

- the 688 PAdventures sheets that match our outfits tile for tile;
- pack folders 08 (recolours and edits of ours) and 09 (other art for Gen 1 to 3), listed in
  [sprite-pack-review](sprite-pack-review/README.md).

The list is in [art-audit](art-audit/README.md), together with the trainer outfits, add-ons and
Pokémon costumes we don't have.

## What each Pokémon needs

Taken from Treecko, a Gen 3 Pokémon that has all of these.

| Where | File | What |
| --- | --- | --- |
| Server | `lib/ps/config/pokemon/<name>.lua` | Types; Attack, Defense, Sp. Atk and Sp. Def (base stats); energy; catch chance; `dexStorage` (10000 + number); `catchStorage` (16000 + number); the 3 face item ids; evolutions; Pokédex text; moves by level; field abilities (Cut, Surf, Fly...); egg groups; egg item; special abilities; TMs; egg moves |
| Server | `monster/Pokemons/<name>.xml` | HP = base HP; speed = 200 + base Speed; melee every 100000 / base Speed ms; melee attack = base Attack; defense = base Defense; level range by stage (20 to 30 first stage, 85 to 95 final, 100 legendary); look type; corpse; cry text; loot |
| Server | `monster/Shiny/shiny <name>.xml` | The same, with the shiny look type and corpse |
| Server | `monster/monsters.xml` | Both monsters listed |
| Server | `lib/ps/config/pokemonsNumbers.lua`, `pokemonsNames.lua` | Name to number, number to name, shiny name; `POKEMON_NUMBER` from 386 to 718 |
| Server | `lib/ps/config/pokemon.lua` | Shiny face ids; the egg item to Pokémon list |
| Server | `items/items.xml` | 2 fainted corpses (fresh, then decayed), 2 shiny corpses, the egg (first stages only), the doll |
| Server | `lib/ps/config/evYields.lua`, `lib/ps/tools/generateLoot.lua`, `lib/ps/config/pokepedia.lua` | EV yield, loot table, where it lives on the map |
| Server | `world/map-spawn.xml` | Spawns, once it has a home |
| Server, if it applies | `lib/ps/others/outfits.lua`, `lib/ps/config/legendaryAnchors.lua` | Ride, fly, surf and dive outfits; habitats for legendaries |
| Client art (`data.dat`/`data.spr`) | Outfits | Walk sprite and shiny walk sprite; ride, fly, surf and dive ones where it has them |
| Client art | Items | Swap bar face and shiny face (4 frames), Pokédex tile, portrait-slot item, 4 corpses, egg, doll |
| Client | `data/images/staticPortraits/<n>.png`, `data/images/pictures/<n>.png`, `data/images/pokeicons/<NNN>.png` | Portrait, 3D Pokédex picture, box icon |
| Client | `data/sounds/cries/<n>.ogg` | Cry |
| Client | `modules/gamelib/pokemon.lua` | Name, face item and number |
| Mapper | `mapper/RME/data/854/creatures.xml` | So spawns can be placed |

Tools in the repo: `scripts/dat-set-outfit.py new` adds an outfit; `scripts/dat-add-items.py`
adds items; an `image:` or `image-frames:` line in `things.otml` draws a PNG for an item.

## Changes beyond one Pokémon

- **New evolutions for 23 Pokémon we have:** Magnezone, Togekiss, Leafeon, Glaceon, Sylveon,
  Gallade, Froslass, Weavile, Honchkrow, Mismagius, Roserade, Rhyperior, Electivire, Magmortar,
  Mamoswine, Gliscor, Porygon-Z, Dusknoir, Probopass, Yanmega, Ambipom, Lickilicky and
  Tangrowth. Their config files get the evolution.
- **7 babies before Pokémon we have:** Happiny, Bonsly, Mime Jr., Munchlax, Mantyke, Chingling
  and Budew.
- **Evolution items:** our evolutions are a level plus an item. Trade evolutions become a
  level, and friendship uses the Soothe Bell, like Crobat. New items needed:
  - stones: Dawn, Dusk, Shiny and Oval Stones;
  - held items: Razor Claw, Razor Fang, Electirizer, Magmarizer, Protector, Reaper Cloth,
    Dubious Disc, Whipped Dream and Sachet.
- **Moves:** each Pokémon gets about 14 moves at set levels, picked from the 455 the game has,
  the same way the Gen 1 to 3 lists were made. Signature moves that are missing (Roar of Time,
  Spacial Rend, Shadow Force, Judgment, Blue Flare and the like) are new moves.
- **Special abilities:** the game has 113. New ones such as Technician, Adaptability, Multiscale
  or Protean get added, or the closest existing one is used.
- **Item ids:** the automatic face and Pokédex tile ids (28149 + number and 28013 + number)
  run into the Gen 3 eggs and faces past #386, so new Pokémon get their own id block. The
  storages 10387 to 10718 and 16387 to 16718 are free.
- **Forms:** one form per Pokémon to start. Rotom, Giratina, Shaymin and the rest can switch
  forms later, the way Deoxys will. Megas are Gen 6 but not part of this.

## Size of the job

- **Generated by a script, then checked:** the server files (config, 2 monster files, numbers,
  names, EV yields, Pokédex text) and the downloaded art (faces, Pokédex tiles and pictures,
  portraits, box icons, cries). The checking is the main work.
- **Picked by hand:**
  - moves, special abilities and egg data for 332 Pokémon;
  - the walk sprite approval, one by one, plus shiny recolours;
  - ride, fly and surf sprites.
- **Built new:** about 13 evolution items, the signature moves and special abilities that are
  missing, corpses, eggs and dolls.
- **Map work:** homes and spawns for 332 Pokémon, which depends on the region decision below.

## Order of work

1. A script that reads PokéAPI and writes the config file, both monster files, and the number,
   name, EV and Pokédex text entries for all 332. Moves, abilities and egg data are filled from
   lists checked by hand.
2. Art import: faces, Pokédex tiles, portraits, pictures, box icons and cries for all 332.
3. Walk sprites: review sheets, approval one by one, then import, a generation at a time.
4. Evolution items, the 23 new evolutions and the 7 babies.
5. Homes and spawns region by region, then loot and the Pokepedia.

## To decide

- **Where they live:** new regions (Sinnoh, Unova, Kalos), or mixed into Kanto and Johto.
  Until they have spawns, they can only come from eggs, events or admins.
- **The legendaries:** in the [legendary revamp](upcoming-features.md#22-legendary-revamp-stages-1-to-3-built)
  with their own habitats and events, or held back.
- **Which stats:** Bulbapedia shows today's base stats, which include the Gen 6 and 7 buffs.
  Use those, or the stats from when each Pokémon came out.
