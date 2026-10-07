# Gameplay Features

This document lists the gameplay systems found in the PokeJornadas base and explains how each one is put together. **Everything here comes from reading the code. Nothing has been run.** The status of each feature is tracked in [FEATURE_AUDIT.md](FEATURE_AUDIT.md). The messages between client and server are listed in [EXTENDED_OPCODE_MAP.md](EXTENDED_OPCODE_MAP.md).

Path conventions: `ps/` means `server/runtime-data/data/lib/ps/`, `lib/` means `server/runtime-data/data/lib/`, and `modules/` means `client/runtime-data/modules/`.

## How Pokémon are stored

There is no Pokémon table. A Pokémon is a **pokeball item** whose item attributes (`ballsAttributes`, read and written through `ps/functions`) hold species, nickname, level, experience, `extraPoints` (boost), nature, IVs, EVs, base upgrades, held item, ability, addon, friendship, egg move and so on. The pokeball moves with the player's inventory and depot. The SQL tables `player_pokemon`, `pokemon_market`, `daycare_*` and the datalog tables only hold copies or logs.

- Species: 386 Pokémon (Gen 1–3) and 369 shiny forms, with 434 species config files under `ps/config`.
- Moves: 456 move definitions (`ps/systems/003-skill.lua`, `004-skillDamage.lua`). Move cooldowns are in `007-cooldown.lua` and the fast-call bar is in `006-fastcall.lua`.
- There are **no PC boxes**. When the party and backpack are full, caught Pokémon go to the depot.

## Pokémon enhancement

| System | Where | How it works |
|---|---|---|
| **Boost** (`extraPoints`) | C++ (`+0.5%` HP per point), `ps/functions`, daycare, quests | Earned by levelling past 100, by daycare training and from quests. The cap is inconsistent: 109 in one place, 110 in another. The "boost stone" item 12618 is a stub. |
| **Base upgrade** | `lib/game_pokemonInfo.lua`, opcode 63 | Stones 35539–35544 raise one base stat each, up to 150 per stat. Reset ticket 35553. |
| **IVs / EVs** | `lib/game_pokemonInfo.lua`, `talkactions/scripts/pokeivev.lua` | IVs are random 1–31 at creation. The EV pool is level × 5, capped at 250 per stat and 500 total. Reset ticket 35552. **Bug:** `ballsAttributes.evspendingPoints` is referenced but never defined. |
| **Natures** | `NATURES` in `lib/game_pokemonInfo.lua` | 25 natures. Each one flags stats as raised (1), lowered (2) or unchanged (0); the multiplier is applied elsewhere. |
| **Vitamins** | `ps/systems/040-vitamin.lua` | HP Up, Protein, Iron, Calcium, Zinc, Carbos. **Bug:** Zinc's description uses the Calcium values. |
| **Friendship** | `lib/game_pokemonInfo.lua` | Raised by care actions and can be bought. **Bug:** the money check is inverted. |
| **Held items** | `ps/systems/046-heldItem.lua` | Seven tiers per item. **Bug:** Dragon Fang applies the Fire bonus. |
| **Special abilities** | `ps/systems/017-specialAbilities.lua` | Per-species passives. |
| **Field abilities** | `ps/systems/039-pokemonAbility.lua` | Cut, rock smash, fly, ride, surf, dig, flash, teleport and similar. |
| **Mastery** | `ps/systems/014-mastery.lua` | Per-species progress, with mastery tokens bought from NPCs. |
| **Addons** | `ps/systems/038-pokemonAddon.lua` | Cosmetic outfits for Pokémon. |
| **Food** | `ps/systems/047-pokemonFood.lua` | Feeding and hunger. |
| **Ball seals, ball counter** | `ps/systems/019-ballSeal.lua`, `020-ballCounter.lua` | Release effects; catch statistics (`ball_counter` table). |
| **TMs, egg moves** | `ps/systems/018-technicalMachine.lua`, egg code | TM choice window (PSoul sub-opcode 13). Egg moves are stored on the ball and logged in `datalog_egg_move_*`. |
| **Evolution** | `doPokemonEvolve` in `ps/functions` | Stones and level evolutions. There is no client window for it. |

## Eggs and daycare

- `ps/systems/045-pokemonEgg.lua` handles eggs. Incubators (items 14048 and 14049) hatch an egg in about 60 minutes. The hatchling is level 1 with +10 boost, and the shiny chance is 1/8192.
- Daycare NPCs use the `daycare_*` tables. Breeding uses egg groups and the `egg_counter` table. `054-extraEggRate.lua` adds a global egg-rate multiplier.

## Progression and live content

| System | Where | Notes |
|---|---|---|
| **Battle pass** ("Passe do Treinador") | `lib/game_pass.lua`, `modules/game_pass`, opcode 61 | Two tracks: VIP (premium account) and Premium (bought). 50 levels with 10 stars each. Buying a level costs 3 diamonds. `pass50` grants 50 stars and 20 PokeCoins. Data is stored in storages only. **The season ended** (`Pass.endDate` is 4 Nov 2021). `Pass.PassVersion` is undefined (only `Pass.version` exists). Missions are not wired up, and many rewards are placeholders (`2160` × 4). |
| **Dungeons** | `lib/game_dungeon.lua`, `lib/game_dungeon_maps.lua`, `modules/game_dungeon`, opcode 41 (JSON) | Teams, queue and ranking, with difficulties from Beginner to Experient. Only the Beginner maps are filled in, and only Map 1 ("Toca dos Rattatas") is fully detailed. Keys are items. Uses storage 868689. The `dungeon_ranking` table is **missing**. There is also an older legendary-birds dungeon in `ps/systems/028-dungeons.lua`. |
| **Daily calendar** | `lib/game_calendar.lua`, `modules/game_calendar`, opcode 62 | Daily login rewards plus a point shop (storage 3457753). Only **September 2021** has rewards configured. |
| **Crafting / professions** | `lib/game_craft.lua`, `lib/ProfessionLib.lua`, `lib/ProfissionBlock.lua`, `ps/profission`, `modules/game_craft`, opcode 103 | Ranks E to S. Only rank E has real recipes. |
| **Kill tasks** | `lib/057-Module_Kill.lua`, `talkactions/scripts/task_mod`, `modules/game_task`, opcode 58 | Task list and ranks. |
| **Daily kill / catch** | `lib/057-Daily Kill.lua`, `lib/058-Daily Catch.lua`, `modules/game_pokekill`, opcode 59 | Daily objectives. |
| **Quests** | `ps/systems/002-quest.lua`, `ps/config/003-quest.lua`, quest NPCs | Includes Professor Oak and the gameplay-tutorial chain (opcodes 8/9). |
| **Achievements** | `lib/000-achievements_lib.lua` **and** `ps/systems/023-achievement.lua` | Two parallel implementations. There is no client window. |
| **Badges, Elite Four, gyms** | `ps/systems/024-badgeCase.lua`, `049-eliteFour.lua`, `001-npcBattle.lua` | Badge case window (`game_badgecase`). NPC trainer battles. |
| **Ranger Club** | `ps/systems/029-rangerClub.lua` | Tasks and bosses (`datalog_rangerclub_*`). |
| **Bosses** | `ps/systems/021-boss.lua` | Spawns and rewards (`datalog_boss_*`). |
| **Team Rocket battles** | `ps/systems/050-rocketBattle.lua` | |
| **Highscores** | `ps/systems/011-highscore.lua`, `013-tournamentHighscore.lua`, `022-highscores.lua`; C++ `ioplayerstatistics` | |
| **Pokédex, doll case** | `ps/systems/010-pokedex.lua`, `041-dollCase.lua` | PSoul sub-opcodes 10–12, 17, 20–21. |
| **Rate events** | `012-extraExpRate.lua`, `052-extraLootRate.lua`, `053-extraCatchRate.lua`, `054-extraEggRate.lua` | Global multipliers. |
| **Seasonal events** | `030-easterEvent.lua`, `037-halloweenEvent.lua`, `048-anniversaryEvent.lua`, `051-christmasEvent.lua`, `055-julyVacationEvent.lua` | Event drops logged in `datalog_*_drops`. |
| **Guardian** | `lib/guardian.lua` | |

## PvP and competition

| System | Where |
|---|---|
| Duels (with bets) | C++ `partyduel`, `modules/game_duelmessage`, `datalog_duel_bet` |
| PvP arena / colosseum | C++ `pvparena`, `ps/systems/009-pvpArena.lua`, `datalog_colosseum_arena` |
| Tournaments | C++ `tournament`, `iotournament` |
| Polls | C++ `iopoll`, `modules/game_poll` (PSoul sub-opcode 24) |

## Economy

| Item | Where | Notes |
|---|---|---|
| **Gold** | Stock money items, `lib/060-Depot_locker.lua`, `stacke.lua` | The client's "stack money" button (opcode 141) has no server handler. |
| **Diamonds** | Item 34524 | Premium currency for the pass, shop and name changes. |
| **PokeCoins** | Storage 414141 | Granted by the pass and shop. |
| **SoulCoins** | `accounts.soulcoins`, `soulTrade` NPC | |
| **Referral points** | `ps/systems/035-referral.lua` | `datalog_referral_exchange`. |
| **Calendar points** | Storage 3457753 | Spent in the calendar shop. |
| **Premium days** | Accounts | Unlocks the VIP pass track. |
| **Game shop** | `modules/game_shop`, `talkactions/scripts/shop/*`, opcode 27 responses | Purchases are talkactions. `/shoppokecoin` is **not registered**, the bless purchase does nothing, and the Gesior web-shop delivery script is commented out. Name change costs 25 diamonds or 50 PokeCoins. |
| **Global market** | `lib/game_market.lua`, `modules/game_market`, opcode 64 | Gold only. Fee is `max(1, price/1000)`. Listings last 60 hours. Needs the **missing** `market_items` and `market_historic` tables and a custom `market_offers` layout that does not match the dump. Two DELETE queries build `item_index..item_index`, so they never match. |
| **Pokémon market / PokéTrader** | NPC `pokemon_market`, `poketrader_*` tables | Separate from the item market. |
| **Slot machine, surprise box, coupons** | `ps/systems/044-slotMachine.lua`, `034-surpriseBox.lua` | Slot-machine window (sub-opcode 22). |
| **Payments** | `paypal_*`, `paygol_*` tables, `gesior-shop-system.lua` | Web side not included. |

## World and exploration

Safari Zone (`016`), fishing (`043`), headbutt trees (`036`), berries and mining (`015`), ski (`032`), sandboard (`042`), oxygen mask / diving (`033`), citizens and towns (`027`), houses (C++ plus `modules/game_house*`, opcodes 199–202), depot password lock (`lib/060-Depot_locker.lua`, opcode 60), ambient sound (`lib/059-AmbientSound.lua`, opcodes 81/85, ignored by the client), day/night clock (`modules/game_time`), and dash walking (opcode 10, C++). There is no TV/cast spectating system.

## Accounts and onboarding

- In-client account and character creation (`modules/poke_create`, custom login packets `0xFC`/`0xFD`). The player picks a starter (Charmander, Bulbasaur or Squirtle), sex, town and world. See **SECURITY_AUDIT.md finding 15**.
- Gameplay tutorial popups (`game_guide`, opcodes 8/9) and a separate tutorial book (`game_tutorial`).
- Portuguese localization in C++ (`server/runtime-data/pt_br.loc`) and client locales.

## Logging

`iodatalog.cpp` and `ps/systems/025-datalog.lua` write about 30 `datalog_*` tables (logins, catches, trades, level-ups, coin use, events). `datalog_ping` is missing from the dump.
