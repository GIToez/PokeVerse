# PokeNation → PokeVerse feature parity

Static comparison of gameplay systems between **PokeNation** (reference) and **PokeVerse** (the PokeJornadas import being evaluated). Both are TFS 0.3.6 "PSoul" (PokeAimar) servers with OTClient-based clients.

| Item | Value |
|---|---|
| PokeNation | branch `cursor/phase3b-pokemon-ui-c0d2`, commit `e272654` (2026-10-07). Its `original/` tree (the untouched PSoul archive) was used as a three-way baseline, so "Jornadas Changed It" describes Verse vs. the original PSoul code, and Nation-only changes are called out separately. |
| PokeVerse | branch `cursor/phase2-verify-build-test` |
| Method | Static only: file diffs (`diff -rq/-w --strip-trailing-cr`), XML registration diffs (`talkactions`, `actions`, `creaturescripts`, `globalevents`, `movements`), the library loader (`lib/999-ps.lua` loads `lib/ps/systems/` with a non-recursive `dodirectory`, and every `data/lib/*.lua` is loaded by `luascript.cpp`), NPC spawn lists (`world/map-spawn.xml`), and C++ and client module diffs. |
| PokeNation statuses | **CONFIRMED WORKING** only where PokeNation's own docs record a runtime PASS (`PHASE_2_TEST_MATRIX.md` P2-xx, `PHASE_3_TEST_MATRIX.md` S-xx/C-xx, `reference/FEATURES.md`, `BUG_TRIAGE.md`). Anything else is the static status. |
| Working in Verse | **NOT TESTED** by default. A later runtime phase fills this in. **BROKEN** or **DISABLED** appears only where static evidence shows a definite break or a feature that is switched off or unreachable. |

Path shorthand. Nation paths are relative to `server/data/` or to the client module folder. Verse paths are relative to `server/runtime-data/data/` or `client/runtime-data/modules/`.
- `sys/` = `lib/ps/systems/`
- `ev/` = `lib/ps/events/`
- `fn/` = `lib/ps/functions/`
- `cfg/` = `lib/ps/config/`
- `npc/` = `npc/scripts/`
- `cl/` = client module (Nation's legacy `client/modules/`, or Verse's modules)
- `pn/` = Nation's new Redemption client, `client-pokenation/modules/`

Two facts affect many rows:
1. **Different map.** Verse ships the Jornadas map: `map.otbm` is 52 MB against Nation's 130 MB. Verse has 8,822 spawn blocks against 19,295, 452 distinct NPC names against 725, and 196 houses against 577. Verse has **no spawns west of x=3000** and very few south of y=1000. Systems whose NPCs are not placed on the map are unreachable even though their code is loaded.
2. **NPC scripts are nearly identical.** Jornadas only added eight daily NPCs and changed `npc/nurse_joy.lua` and `npc/quest_professorMark.lua`. Of the 55 `sys/` files, Verse changed 9 (001, 004, 006, 010, 012, 027, 038, 043, 045) and Nation changed 2 (003, 055) plus added 056. Wherever a row says "Same System: Yes", PokeNation's runtime result applies to identical code.

---

## 1. Core Pokémon

| Feature | PokeNation | PokeVerse | Same System | Jornadas Changed It | Working in Verse | Missing in Verse | Notes |
|---|---|---|---|---|---|---|---|
| Starter Pokémon | CONFIRMED WORKING (P2-02) `npc/quest_professorOak.lua` | APPEARS IMPLEMENTED `npc/quest_professorOak.lua`; Oak spawned | Yes | Script unchanged. Starter movesets rewritten in `cfg/pokemon/{bulbasaur,charmander,squirtle}.lua`; Oak outfit changed | NOT TESTED | No | Verse also creates characters in the client (`poke_create`, C++ `0xFC/0xFD`) |
| Call / summon | CONFIRMED WORKING (P2-04) `fn/others.lua doPokemonCall` | APPEARS IMPLEMENTED `fn/others.lua` | Modified | On call, rolls missing IVs and adds IV/EV/base HP to max HP; summon checks use `getPlayerPokemons` (excludes the guardian) | NOT TESTED | No | |
| Return | CONFIRMED WORKING (P2-04) `fn/ball/inUse.lua` | APPEARS IMPLEMENTED `fn/ball/inUse.lua` | Yes | Only the extra Pokébar packet fields | NOT TESTED | No | |
| Pokébar | CONFIRMED WORKING (P2-04, P2-33) `sys/006-fastcall.lua`, `cl/game_pokebar` | APPEARS IMPLEMENTED `sys/006`, `cl/game_pokebar` | Modified | Bar add/update packets now carry level, energy, max energy, gender and EXP% (C++ and client); exhaust added on fast-call | NOT TESTED | No | The wire format no longer matches either Nation client |
| Catching | CONFIRMED WORKING (P2-09) `fn/ball/empty.lua` | APPEARS IMPLEMENTED `fn/ball/empty.lua` | Modified | Rolls 6 IVs into the new ball; Daily Catch task hook | NOT TESTED | No | |
| Ball counter | CONFIRMED WORKING (P2-09) `sys/020-ballCounter.lua` | APPEARS IMPLEMENTED `sys/020` | Yes | — | NOT TESTED | No | |
| Ball seals | APPEARS IMPLEMENTED `sys/019-ballSeal.lua` (BUG-21) | APPEARS IMPLEMENTED `sys/019` | Yes | — | NOT TESTED | No | |
| Pokémon leveling | CONFIRMED WORKING (P2-05, P2-15) `fn/player.lua` | APPEARS IMPLEMENTED `fn/player.lua` | Yes | Extra-banner-rate helpers added only | NOT TESTED | No | Nation fractional-EXP text (BUG-07) is also in Verse |
| Pokémon EXP | CONFIRMED WORKING (P2-05) `fn/player.lua doPlayerPokemonAddExperience` | APPEARS IMPLEMENTED `fn/player.lua` | Modified | No server EXP-event multiplier (that is Nation-only); XP banners and `sys/012` instead | NOT TESTED | No | |
| Fainting | CONFIRMED WORKING (P2-10) `ev/creaturescripts/onPokemonDeath.lua` | APPEARS IMPLEMENTED same file | Yes | Extra Pokébar fields only | NOT TESTED | No | |
| Revive | CONFIRMED WORKING (P2-10, discharged ball and heal path) `ev/actions/potions/pokemonRevive.lua` | APPEARS IMPLEMENTED same file | Yes | Adds a dungeon hook (`Dz.onUseMedicament` can block revive) | NOT TESTED | No | The revive item itself was not exercised by Nation |
| Pokémon Center healing | CONFIRMED WORKING (P2-07) `npc/nurse_joy.lua` | APPEARS IMPLEMENTED `npc/nurse_joy.lua`; 60 Nurse Joy spawns (124 in Nation) | Modified | Hometown-change dialogue commented out; greeting voice removed | NOT TESTED | No | |
| Hometown change | APPEARS IMPLEMENTED (`nurse_joy.lua` "hometown") | MISSING (commented out in `npc/nurse_joy.lua:238-247`) | No | Removed | DISABLED | Yes | |
| Evolution | CONFIRMED WORKING (P2-11) `ev/actions/evolve.lua` | APPEARS IMPLEMENTED `ev/actions/evolve.lua` plus `/evolve` talkaction | Modified | New `/evolve` command (`ev/talkactions/evolve.lua`) evolves the active Pokémon without the icon | NOT TESTED | No | |
| Nickname | CONFIRMED WORKING (P2-12) `npc/soulTrade.lua` | APPEARS IMPLEMENTED `npc/soulTrade.lua`; 1 Soul Trade NPC spawned (16 in original) | Yes | — | NOT TESTED | No | Richard (4733,130,7) is spawned in both |
| Sex / gender | APPEARS IMPLEMENTED (observed "male Rattata", P2-09) `src/monster.cpp` | APPEARS IMPLEMENTED; gender also shown on the client Pokébar and items | Modified | Gender sent in the item and Pokébar packets | NOT TESTED | No | |
| Shiny Pokémon | APPEARS IMPLEMENTED `spawn.cpp`, `shinyAppearChance` | APPEARS IMPLEMENTED (`config.lua shinyAppearChance = 8192`) | Yes | Friendship "shiny charm" value exists but is never read | NOT TESTED | No | |
| Hunger / feeding | PARTIAL (P2-08; BUG-19 spam) `sys/047-pokemonFood.lua` | PARTIAL `sys/047` | Yes | — | NOT TESTED | No | Same once-a-minute hunger message |
| Pokédex | PARTIAL (P2-09 catch XP, P2-33 window, C-08 386-entry status PASS) `sys/010`, `cl/game_pokedex` | PARTIAL `sys/010`, `cl/game_pokedex` | Modified | Helper functions made global; the **status list is no longer sent at login** (`fn/player.lua:1062` commented), only on Pokédex upgrade; client restyled (`/images/pokemon_image/`) | NOT TESTED | No | The Verse client still waits for `onPokedexStatus`, so the dex grid is likely empty after login |
| Status conditions | CONFIRMED WORKING (P2-13, poison) `sys/008-conditions.lua`, `cl/game_statusbar` | APPEARS IMPLEMENTED `sys/008`, `cl/game_statusbar` | Yes | — | NOT TESTED | No | BUG-27 subid copy-paste is shared |

## 2. Moves and development

| Feature | PokeNation | PokeVerse | Same System | Jornadas Changed It | Working in Verse | Missing in Verse | Notes |
|---|---|---|---|---|---|---|---|
| Moves | CONFIRMED WORKING (P2-06; GM energy fix BUG-05, `tools/energy_test.py`) `sys/003-skill.lua`, `cfg/moves/` | APPEARS IMPLEMENTED `sys/003`, `cfg/moves/` | Modified | **All 456 moves have `requiredEnergy = 0`** (energy cost removed); new move Fireball; starter learnsets rewritten | NOT TESTED | No | With zero cost, Nation's GM-energy bug cannot occur in Verse |
| Cooldowns | CONFIRMED WORKING (P2-06) `sys/007-cooldown.lua` | APPEARS IMPLEMENTED `sys/007` | Yes | — | NOT TESTED | No | Day-of-year clock (BUG-34) is shared |
| TMs | CONFIRMED WORKING (P2-16) `sys/018`, `cl/game_tmchoose` | APPEARS IMPLEMENTED `sys/018`, `cl/game_tmchoose` | Yes | — | NOT TESTED | No | Nation's new client fixes the listener leak (BUG-57); Verse keeps it |
| Held items | CONFIRMED WORKING (P2-17) `sys/046-heldItem.lua` | APPEARS IMPLEMENTED `sys/046` | Yes | — | NOT TESTED | No | BUG-28 is shared |
| Vitamins | CONFIRMED WORKING (P2-18) `sys/040-vitamin.lua` | CONFIRMED WORKING (Zinc, harness) `sys/040` | Yes | Phase 2 Zinc description fix only | PASS (Zinc); the other 7 NOT TESTED | No | Full audit: `MISSING_FROM_POKEVERSE.md` → VITAMIN_AUDIT |
| Special / passive abilities | APPEARS IMPLEMENTED `sys/017`, `sys/039` | APPEARS IMPLEMENTED `sys/017`, `sys/039` | Yes | — | NOT TESTED | No | |
| Field abilities (overall) | CONFIRMED WORKING for Ride and Fly (P2-20/21); others APPEARS IMPLEMENTED `fn/abilities.lua` | APPEARS IMPLEMENTED `fn/abilities.lua` | Modified | Scyther speed entry added, a dead headbutt block removed, one extra ability area in `ev/actions/abilities.lua` | NOT TESTED | No | |
| Pokémon addons | PARTIAL (P2-22) `sys/038-pokemonAddon.lua` | APPEARS IMPLEMENTED `sys/038` | Modified | About 100 new addons (ids 262–360) and extra addon item ranges in `actions.xml` | NOT TESTED | No | Better in Verse (content) |
| Eggs | CONFIRMED WORKING (P2-19) `sys/045-pokemonEgg.lua` | APPEARS IMPLEMENTED `sys/045` | Modified | Egg ball creation passes the new IV arguments | NOT TESTED | No | |
| Incubators | CONFIRMED WORKING (P2-19, hatch after 60 min) `ev/actions/eggIncubator/` | APPEARS IMPLEMENTED same | Yes | — | NOT TESTED | No | |
| Breeding | APPEARS IMPLEMENTED `npc/daycareFemale.lua`, `daycareMale.lua` | APPEARS IMPLEMENTED same; both daycare NPCs spawned | Yes | — | NOT TESTED | No | |
| Daycare | APPEARS IMPLEMENTED (not tested, level 85 + premium) | APPEARS IMPLEMENTED | Yes | — | NOT TESTED | No | Also adds Boost (`extraPoints`) in both |
| Egg moves | APPEARS IMPLEMENTED `npc/eggmove_*.lua` | APPEARS IMPLEMENTED same | Yes | — | NOT TESTED | No | |
| Mastery | APPEARS IMPLEMENTED `sys/014-mastery.lua`, `npc/mastery_*.lua` (35 mastery NPCs spawned) | DISABLED: `sys/014` loads, but **none** of the mastery NPCs (Ader, Dax, Darus…) is in Verse's `map-spawn.xml` | Yes | Not placed on the Jornadas map; the shop sells a "mastery rank" (`/BuyMasteryRank`) instead | DISABLED | Yes (unreachable) | |
| Extra EXP rate | APPEARS IMPLEMENTED `sys/012-extraExpRate.lua` (items) | APPEARS IMPLEMENTED `sys/012` | Modified | Start/end messages commented out; extra "banner rate" added; area XP banners (`lib/bannerExp.lua`) | NOT TESTED | No | |
| Extra catch rate | APPEARS IMPLEMENTED `sys/053` | APPEARS IMPLEMENTED `sys/053` | Yes | — | NOT TESTED | No | |
| Extra loot rate | APPEARS IMPLEMENTED `sys/052` | APPEARS IMPLEMENTED `sys/052` | Yes | — | NOT TESTED | No | |
| Extra egg rate | APPEARS IMPLEMENTED `sys/054` | APPEARS IMPLEMENTED `sys/054` | Yes | — | NOT TESTED | No | |

## 3. Jornadas-specific Pokémon systems

| Feature | PokeNation | PokeVerse | Same System | Jornadas Changed It | Working in Verse | Missing in Verse | Notes |
|---|---|---|---|---|---|---|---|
| Boost / `extraPoints` | APPEARS IMPLEMENTED: existed in PSoul (`cfg/balls.lua extraPoints`, level-up gains, daycare and NPC +10, shown as `[+N]` in the ball description and in `pn/game_pokemondetails`) | PARTIAL `cfg/balls.lua`, `lib/game_pokemonInfo.lua:903` | Modified | Exposed in the Pokémon Info window; Oak gives level+9 | NOT TESTED | No | Existed in Nation and is visible there. Verse audit: cap 109 vs 110, boost stone 12618 is a stub |
| IVs | MISSING | PARTIAL: 6 IV attributes (`cfg/balls.lua` base+74…79), rolled on catch (`fn/ball/empty.lua`) and on call (`fn/others.lua`) | No | Added by Jornadas | NOT TESTED | No | Only the HP IV changes stats (max HP); attack/defense/speed IVs are never read by damage code |
| EVs | MISSING | BROKEN: `lib/game_pokemonInfo.lua:254,760,774` use `ballsAttributes.evspendingPoints`, which is undefined (the key is `evpoints`) | No | Added by Jornadas | BROKEN | No | Only the HP EV is used by `doPokemonCall` |
| Nature | MISSING | PARTIAL: 25 natures (`cfg/balls.lua nature`) | No | Added by Jornadas | NOT TESTED | No | `getBallPokemonNature` is only read for the description; no stat effect |
| Base-stat upgrades | MISSING | PARTIAL: stones 35539–35544 via opcode 63 (`lib/game_pokemonInfo.lua`); reset item 35553 | No | Added by Jornadas | NOT TESTED | No | Only base HP affects stats |
| Friendship | MISSING | PARTIAL: level/EXP bought with money or diamonds (`lib/game_pokemonInfo.lua:606-640`) | No | Added by Jornadas | NOT TESTED | No | Crit, loot luck, shiny charm and energy-regen bonuses are written but never read. The "inverted money check" in Verse's FEATURE_AUDIT is not an inversion (only a redundant remove on the refusal path) |
| Graphical Pokémon Info | PARTIAL: the legacy client has none; the new client has `pn/game_pokemondetails` (parses the ball look text, not runtime-tested, C-11) | PARTIAL `cl/game_pokemonInfo` (100 images) + `lib/game_pokemonInfo.lua` (opcode 63) | Replaced | Full stats, IV/EV/base, friendship and reset window | NOT TESTED | No | Better in Verse, apart from the EV bug |

## 4. World abilities

| Feature | PokeNation | PokeVerse | Same System | Jornadas Changed It | Working in Verse | Missing in Verse | Notes |
|---|---|---|---|---|---|---|---|
| Ride | CONFIRMED WORKING (P2-20) `ev/actions/abilities.lua` | APPEARS IMPLEMENTED same | Yes | — | NOT TESTED | No | |
| Fly | CONFIRMED WORKING (P2-21) `ev/talkactions/flyUp.lua`, `flyDown.lua` | APPEARS IMPLEMENTED same | Modified | Hotkey aliases `h1` (up), `h2` (down), `h3` (find); Fly added to one more species | NOT TESTED | No | |
| Surf | APPEARS IMPLEMENTED | APPEARS IMPLEMENTED | Modified | Swim effect extended to new water tiles 32957–32974, 33991–33996 | NOT TESTED | No | |
| Dive (+ oxygen mask) | APPEARS IMPLEMENTED (BUG-50) `sys/033` | APPEARS IMPLEMENTED `sys/033` | Modified | New underwater enter/leave tiles 32955/32956 | NOT TESTED | No | |
| Cut | APPEARS IMPLEMENTED | APPEARS IMPLEMENTED | Yes | — | NOT TESTED | No | |
| Dig | APPEARS IMPLEMENTED | APPEARS IMPLEMENTED | Yes | — | NOT TESTED | No | |
| Rock Smash | APPEARS IMPLEMENTED | APPEARS IMPLEMENTED | Yes | — | NOT TESTED | No | |
| Strength | PARTIAL (`"Strenght"` typo in 59 species, BUG-30) | PARTIAL (same typo; species files only gained `hp`/`speed`) | Yes | — | NOT TESTED | No | |
| Teleport / Find | APPEARS IMPLEMENTED `/tp`, `/find` | APPEARS IMPLEMENTED | Yes | `/find` alias `h3` | NOT TESTED | No | |
| Fishing | APPEARS IMPLEMENTED `sys/043-fishing.lua` | APPEARS IMPLEMENTED `sys/043` | Modified | **Removed the 4-tile maximum cast distance** and the cast projectile | NOT TESTED | No | Nation keeps the range check |
| Headbutt | APPEARS IMPLEMENTED `sys/036` | APPEARS IMPLEMENTED `sys/036` | Yes | — | NOT TESTED | No | |
| Ski | APPEARS IMPLEMENTED `sys/032` | APPEARS IMPLEMENTED `sys/032` | Yes | — | NOT TESTED | No | |
| Sandboard | APPEARS IMPLEMENTED `sys/042` | APPEARS IMPLEMENTED `sys/042` | Yes | — | NOT TESTED | No | |
| Berry trees | APPEARS IMPLEMENTED `sys/015` | APPEARS IMPLEMENTED `sys/015` | Yes | — | NOT TESTED | No | |
| Surprise boxes | APPEARS IMPLEMENTED `sys/034` (BUG-41: only x<2048) | DISABLED: `globalevents/scripts/start.lua:229-232` "Loading SupriseBox" startup step commented out | Yes | Spawning switched off | DISABLED | Yes (disabled) | Verse's map has no spawns at x<2048 anyway |
| Travel | APPEARS IMPLEMENTED `npc/travels.lua` (7 NPCs) | APPEARS IMPLEMENTED (6 NPCs spawned) | Yes | — | NOT TESTED | No | |
| Citizens | APPEARS IMPLEMENTED (observed at start) `sys/027` | APPEARS IMPLEMENTED `sys/027` | Modified | Position list edited | NOT TESTED | No | |
| Day / night | APPEARS IMPLEMENTED `game.cpp` light, `cl/game_time` | APPEARS IMPLEMENTED, `cl/game_time` restyled | Yes | Clock UI | NOT TESTED | No | |
| Environment / weather / sound | DISABLED (`game_environment` not loaded, BUG-69) | DISABLED: `lib/059-AmbientSound.lua` sends opcodes 81/85, which no client handler receives; `game_environment` not loaded | Modified | Server ambient-sound sender added | DISABLED | No | Dead in both |
| Town guide map marks | CONFIRMED WORKING (P2-25) `sys/026-guide.lua` | APPEARS IMPLEMENTED `sys/026`; 7 guides spawned (17 in original) | Yes | — | NOT TESTED | No | |
| Wild respawn events (Sudowoodo tree) | APPEARS IMPLEMENTED `globalevents.xml sudowoodoTree` | DISABLED (globalevent commented) | Yes | Switched off | DISABLED | Yes (disabled) | |
| Startup quest spawns (Wampi tree, Juanito letter, Crystal Onix, Aerodactyl whirlpool, 5 random NPCs) | APPEARS IMPLEMENTED `globalevents/scripts/start.lua` | DISABLED (commented out in `start.lua:50-93`) | Yes | Switched off | DISABLED | Yes (disabled) | The black shell and ice yolk spawns are kept |

## 5. Battles and challenges

| Feature | PokeNation | PokeVerse | Same System | Jornadas Changed It | Working in Verse | Missing in Verse | Notes |
|---|---|---|---|---|---|---|---|
| Wild battles | CONFIRMED WORKING (P2-05) | APPEARS IMPLEMENTED | Modified | C++ `monster.cpp`: passive wild Pokémon fight back once damaged, guardian targeting rules; `ev/creaturescripts/onDeath.lua` adds level-scaled player EXP loss on death | NOT TESTED | No | |
| NPC trainer battles | CONFIRMED WORKING (S-07 win and loss under `no-pvp` after the BUG-01 C++ fix) `sys/001` | APPEARS IMPLEMENTED `sys/001` (165 trainer NPCs spawned vs 183) | Yes | Comments translated to Portuguese only | NOT TESTED | No | Verse's `combat.cpp` is unpatched but `config.lua worldType = "pvp"`, the workaround Nation verified in P2-29 |
| Gyms | CONFIRMED WORKING (S-08 Brock win, badge message, TM 33) `npc/npcbattle_{brock…giovanni}.lua` | APPEARS IMPLEMENTED; all 8 leaders spawned | Yes | — | NOT TESTED | No | |
| Badges | PARTIAL (badge message PASS; BUG-16 placeholder risk) `sys/001 doPlayerGiveBadge` | PARTIAL (same code) | Yes | — | NOT TESTED | No | |
| Badge case | APPEARS IMPLEMENTED `sys/024`, `cl/game_badgecase` | APPEARS IMPLEMENTED same | Yes | — | NOT TESTED | No | |
| Elite Four | APPEARS IMPLEMENTED `sys/049` (BUG-64) | APPEARS IMPLEMENTED `sys/049`; Drogo Toby spawned | Yes | — | NOT TESTED | No | |
| Team Rocket | PARTIAL (rewards commented out, BUG-44) `sys/050` | PARTIAL `sys/050` | Yes | — | NOT TESTED | No | |
| Bosses | APPEARS IMPLEMENTED (`/boss` reply, P2-14) `sys/021` | APPEARS IMPLEMENTED `sys/021` | Yes | — | NOT TESTED | No | |
| Dungeons (PSoul bird/mastery) | APPEARS IMPLEMENTED `sys/028` (BUG-45) | APPEARS IMPLEMENTED `sys/028` | Yes | Separate modern dungeon system added (§8) | NOT TESTED | No | |
| Ranger Club | APPEARS IMPLEMENTED `sys/029` (23 NPCs) | APPEARS IMPLEMENTED `sys/029` (9 NPCs, Dan Lambert spawned) | Yes | — | NOT TESTED | No | |
| Safari Zone | APPEARS IMPLEMENTED `sys/016` | APPEARS IMPLEMENTED `sys/016`; Jeffrey spawned | Yes | — | NOT TESTED | No | Safari fishing disabled in both |
| Battle Tower | APPEARS IMPLEMENTED `npc/fi_battletower.lua` | APPEARS IMPLEMENTED; Rafael Townson spawned | Yes | — | NOT TESTED | No | |
| Frontier Island | APPEARS IMPLEMENTED (48 `npcbattle_fi_*`) | APPEARS IMPLEMENTED (all 48 spawned) | Yes | — | NOT TESTED | No | |
| Stadium Arena | APPEARS IMPLEMENTED `npc/lib/frontierisland/stadiumarena` | APPEARS IMPLEMENTED; Kurt Petrillose spawned | Yes | — | NOT TESTED | No | |
| Wave Arena | APPEARS IMPLEMENTED `npc/lib/wavearena.lua` | APPEARS IMPLEMENTED; Leroi Bradley spawned | Yes | — | NOT TESTED | No | |
| Tournaments | PARTIAL (P2-28 scheduler broadcast; ids 2/3 commented, BUG-20) `src/tournament.cpp`, `XML/tournaments.xml` | APPEARS IMPLEMENTED: all 4 tournaments enabled (`XML/tournaments.xml`) | Modified | Tiers 2/3 enabled and renamed (Begginer/Great/Expert/Veteran) | NOT TESTED | No | Better in Verse: no BUG-20 |
| PvP arena | APPEARS IMPLEMENTED `sys/009`, `src/pvparena.cpp` (BUG-17) | APPEARS IMPLEMENTED `sys/009` | Modified | PvP-area entry tile `ev/movements/pvp.lua` and electric doors (`ev/movements/doreletric/`) | NOT TESTED | No | BUG-17 is shared |
| Duels | CONFIRMED WORKING (S-10, 1×1 duel to the end) `ev/actions/duel.lua`, `cl/game_duelmessage` | APPEARS IMPLEMENTED same | Yes | — | NOT TESTED | No | |
| Quests | CONFIRMED WORKING (P2-26 framework; C-15 quest log) `sys/002`, `npc/quest_*` | APPEARS IMPLEMENTED `sys/002` | Yes | Only 94 quest NPCs spawned (176 in original) | NOT TESTED | No | Less content on the smaller map |

## 6. Economy and social

| Feature | PokeNation | PokeVerse | Same System | Jornadas Changed It | Working in Verse | Missing in Verse | Notes |
|---|---|---|---|---|---|---|---|
| Bank | CONFIRMED WORKING (P2-27 deposit/withdraw/balance; transfer PARTIAL) `npc/bank.lua` | APPEARS IMPLEMENTED `npc/bank.lua`; only Emmet Cash spawned | Yes | — | NOT TESTED | No | |
| Item market (PSoul binary, 0xF4–0xF9) | PARTIAL (C-14 packet round trip PASS; NPC Jaron Jewell not spawned; BUG-36/37) `src/iomarket.cpp` | MISSING: `iomarket.cpp` deleted, market parsers commented out in `protocolgame.cpp`/`game.cpp`; `npc/market.lua` calls the unregistered `doPlayerSendMarketEnter` | Replaced | Replaced by the Lua/opcode-64 graphical market (§8) | DISABLED | Yes (replaced) | The replacement is statically broken |
| Pokémon market | PARTIAL (P2-30) `npc/shop_pokemonMarket.lua` | PARTIAL same; Jack Eden spawned | Yes | — | NOT TESTED | No | BUG-31 is shared |
| PokéTrader | PARTIAL (P2-31) `npc/poketrader.lua` | PARTIAL same | Yes | — | NOT TESTED | No | BUG-32 is shared |
| Premium shop | PARTIAL (website dependent) `npc/soulTrade.lua` | PARTIAL `npc/soulTrade.lua` + graphical shop (§8) | Modified | Diamonds/PokeCoins shop added | NOT TESTED | No | |
| SoulCoins | PARTIAL (P2-12 nick paid with a Soul Coin) `accounts.soulcoins` | APPEARS IMPLEMENTED `accounts.soulcoins` | Yes | Diamonds (item 34524) and PokeCoins added alongside | NOT TESTED | No | |
| Casino / slot machine | APPEARS IMPLEMENTED `sys/044`, `cl/game_slotmachine` | APPEARS IMPLEMENTED same | Yes | — | NOT TESTED | No | |
| Autoloot | PARTIAL (P2-24 FAIL: OFF never persisted, BUG-04) | PARTIAL (same `login.lua`/C++ default) | Yes | — | NOT TESTED | No | |
| TV / spectating | APPEARS IMPLEMENTED `ev/actions/tv`, `ev/talkactions/tv` | APPEARS IMPLEMENTED same | Yes | — | NOT TESTED | No | |
| Polls | CONFIRMED WORKING (C-13 packets and votes stored; polls created by SQL) `src/polls.cpp` | APPEARS IMPLEMENTED `src/polls.cpp`, `cl/game_poll` | Yes | — | NOT TESTED | No | Website needed to create polls |
| Guilds | APPEARS IMPLEMENTED (Soul Trade, 5 Soul Coins) | APPEARS IMPLEMENTED | Yes | — | NOT TESTED | No | No guild war in either |
| Houses | APPEARS IMPLEMENTED `/house buy…` talkactions | PARTIAL: commands renamed `!buyhouse`/`!sellhouse`/… plus obfuscated words; house UIs `cl/game_house*` (opcodes 199/201/202); the owner panel (200) has no sender | Modified | Graphical house windows; Portuguese commands | NOT TESTED | No | 196 houses vs 577 |
| Wiki Chat | CONFIRMED WORKING (P2-23) `sys/031` | APPEARS IMPLEMENTED `sys/031` | Yes | — | NOT TESTED | No | Nation also translated `cfg/002-wikiChat.lua` |
| Referrals | APPEARS IMPLEMENTED (website) `sys/035` | APPEARS IMPLEMENTED `sys/035` | Yes | — | NOT TESTED | No | |
| Coupons | PARTIAL (BUG-54) `/cupom` | PARTIAL same | Yes | — | NOT TESTED | No | |
| Highscores | APPEARS IMPLEMENTED (static, `updateHighscores = false`) `sys/011/013/022` | APPEARS IMPLEMENTED (same config) | Yes | — | NOT TESTED | No | |
| Achievements | APPEARS IMPLEMENTED `sys/023` | APPEARS IMPLEMENTED `sys/023` + `lib/000-achievements_lib.lua` | Modified | Second achievement library added | NOT TESTED | No | Two parallel systems in Verse |
| Doll case | APPEARS IMPLEMENTED `sys/041`, `cl/game_dollcase` | APPEARS IMPLEMENTED same | Yes | — | NOT TESTED | No | |
| Clothes / addons | APPEARS IMPLEMENTED `ev/actions/clotheShowcase.lua`, `clothesKit.lua`; 80 outfits | APPEARS IMPLEMENTED; 209 outfits in `XML/outfits.xml`, clothes shop items 34601–34730 (`actions/scripts/shop/roupas_loja.lua`) | Modified | Many new outfits and a clothes shop | NOT TESTED | No | Better in Verse (content) |
| Statistics / datalog | CONFIRMED WORKING (passive, §2.16) `sys/025`, `src/iodatalog.cpp` | APPEARS IMPLEMENTED same | Yes | — | NOT TESTED | No | `datalog_ping` is missing from Verse's dump (Nation's schema has it) |
| Localization | CONFIRMED WORKING (S-02…S-05, C-05; BUG-08/09 fixed) `src/localization.cpp`, ext. opcode 1 | PARTIAL: login language byte unvalidated (`source/protocollogin.cpp:86-89`, BUG-08 unfixed); opcode 1 has no handler; `/lang` works | Yes | — | NOT TESTED | No | Better in Nation |
| Tips / tutorial | APPEARS IMPLEMENTED `cl/game_tips`, `cl/game_guide`, `cl/game_tutorial` | APPEARS IMPLEMENTED same modules | Yes | — | NOT TESTED | No | |

## 7. Seasonal and events

| Feature | PokeNation | PokeVerse | Same System | Jornadas Changed It | Working in Verse | Missing in Verse | Notes |
|---|---|---|---|---|---|---|---|
| Anniversary | PARTIAL (P2-32: always on, BUG-14) `sys/048`, `globalevents.xml` | DISABLED: globalevent, `onKill` and `onSpawn` hooks commented out | Yes | Switched off | DISABLED | Yes (disabled) | Re-enable by uncommenting three lines |
| Halloween | DISABLED (NPCs live) `sys/037` | DISABLED (Hermitwo/Selam spawned, Trevor not) | Yes | — | DISABLED | No | |
| Easter | DISABLED `sys/030` | DISABLED | Yes | — | DISABLED | No | |
| Christmas | DISABLED `sys/051` | DISABLED | Yes | — | DISABLED | No | |
| July Vacation | DISABLED `sys/055` | DISABLED | Yes | — | DISABLED | No | Nation only translated comments |
| Birthday / respect boxes | APPEARS IMPLEMENTED `ev/actions/events/{birthdayBox,respectBox}.lua` | APPEARS IMPLEMENTED same | Yes | — | NOT TESTED | No | |
| Server-wide EXP event | CONFIRMED WORKING (`tools/exp_event_test.py`, 24 checks; survives restart) `sys/056-expEvent.lua`, `/doubleexp`, `/expevent`, `expEventCheck`, C++ `Game::getExpEventMultiplier` | MISSING: only per-player boosts (`sys/012` potions) and area XP banners (`lib/bannerExp.lua`, items 29838/26758–26761, +5–60 % within 10 tiles for 60 min) | No | Jornadas has no server-wide equivalent | DISABLED | Yes | |

## 8. Jornadas additions

| Feature | PokeNation | PokeVerse | Same System | Jornadas Changed It | Working in Verse | Missing in Verse | Notes |
|---|---|---|---|---|---|---|---|
| Battle Pass | MISSING | PARTIAL `lib/game_pass.lua`, `cl/game_pass` (opcode 61) | No | Added | NOT TESTED | No | Season ended 2021-11-04; `Pass.PassVersion` is undefined (`game_pass.lua:363`); client uses `loadstring` |
| Daily Calendar | MISSING | PARTIAL `lib/game_calendar.lua`, `cl/game_calendar` (opcode 62) | No | Added | NOT TESTED | No | Only Sep 2021 configured |
| Modern Dungeon UI | MISSING | PARTIAL `lib/game_dungeon.lua`, `cl/game_dungeon` (opcode 41) | No | Added | NOT TESTED | No | `dungeon_ranking` table missing; Beginner maps only |
| Crafting | MISSING | PARTIAL `lib/game_craft.lua`, `cl/game_craft` (opcode 103) | No | Added | NOT TESTED | No | Only rank E recipes |
| Professions | MISSING | PARTIAL `lib/ProfessionLib.lua`, `lib/game_work.lua`, `lib/ps/profission/` (gathering items 34240–34245, craft tables 34292–34371) | No | Added | NOT TESTED | No | `/profission` runs a test script |
| Kill tasks | MISSING (old `sys/disabled/005-task.lua` unloaded in both) | APPEARS IMPLEMENTED `lib/057-Module_Kill.lua`, `cl/game_task` (opcode 58) | No | Added | NOT TESTED | No | |
| Daily kill | MISSING | APPEARS IMPLEMENTED `lib/057-Daily Kill.lua`, `creaturescripts/scripts/dailys/`, 4 daily NPCs | No | Added | NOT TESTED | No | |
| Daily catch | MISSING | APPEARS IMPLEMENTED `lib/058-Daily Catch.lua`, hook in `fn/ball/empty.lua`, 4 daily NPCs | No | Added | NOT TESTED | No | |
| Graphical market | MISSING (Nation keeps the binary market) | BROKEN `lib/game_market.lua`, `cl/game_market` (opcode 64): tables `market_items` and `market_historic` are not in `pokeaventuras.sql` | No | Added; replaces the C++ market | BROKEN | No | 59 references to the missing tables |
| Graphical shop | MISSING (`game_shop` dead in the legacy client) | PARTIAL `cl/game_shop`, `talkactions/scripts/shop/` (opcode 27) | No | Added | NOT TESTED | No | `/shoppokecoin` used by `mercado.lua` but not registered |
| Pokémon Info | see §3 | PARTIAL `cl/game_pokemonInfo` | Replaced | Added | NOT TESTED | No | EV spending broken |
| In-client account creation | MISSING (`accountManager = false`, website or seed SQL) | APPEARS IMPLEMENTED `cl/poke_create`, C++ `protocollogin.cpp` `0xFC/0xFD`, `XML/CreateAcc.xml` | No | Added | NOT TESTED | No | Insecure (Verse SECURITY_AUDIT finding 15) |
| Notifications | MISSING | APPEARS IMPLEMENTED `cl/game_notifications`, `lib/notifications.lua` (opcode 25) | No | Added | NOT TESTED | No | |
| Updater | MISSING (Nation's `pn/updater` is the stock Redemption one) | NOT TESTED `cl/game_updater` | No | Added | NOT TESTED | No | No update host in the repo |
| Depot password lock | MISSING | APPEARS IMPLEMENTED `lib/060-Depot_locker.lua`, `cl/game_depotlock` (opcode 60) | No | Added | NOT TESTED | No | |
| Guardian Pokémon | MISSING | APPEARS IMPLEMENTED `lib/guardian.lua`, card item 27291 (`ev/actions/card/cardcharizard.lua`), `/guardian`, C++ `monster.cpp` targeting | No | Added: a 60-minute legendary companion | NOT TESTED | No | |
| XP banners | MISSING | APPEARS IMPLEMENTED `lib/bannerExp.lua`, `actions/scripts/banners/xpplank.lua`, `creaturescripts bannerexp.lua` | No | Added | NOT TESTED | No | |
| Daily NPC gift boxes | MISSING | APPEARS IMPLEMENTED `ev/actions/dailys/presente*.lua` | No | Added | NOT TESTED | No | |
| Stack money button | MISSING | BROKEN: `cl/game_inventory` sends opcode 141 and nothing handles it on the server | No | Added | BROKEN | No | A `$stackemoney$` talkaction exists but the client never sends it |
| Bottom menu / top menu / chat UI | MISSING (legacy) | APPEARS IMPLEMENTED `cl/game_bottommenu`, `cl/client_topmenu`, `cl/game_chat` | No | Added | NOT TESTED | No | |

---

## Classification

### PRESENT IN BOTH
- Starter Pokémon, call/summon, return, Pokébar, catching, ball counter, ball seals, leveling, Pokémon EXP, fainting, revive, Pokémon Center healing, evolution, nickname, sex/gender, shiny Pokémon, hunger/feeding, Pokédex, status conditions
- Moves, cooldowns, TMs, held items, vitamins, special/passive abilities, field abilities, Pokémon addons, eggs, incubators, breeding, daycare, egg moves, extra EXP/catch/loot/egg rates, Boost (`extraPoints`)
- Ride, Fly, Surf, Dive/oxygen mask, Cut, Dig, Rock Smash, Strength, Teleport/Find, Fishing, Headbutt, Ski, Sandboard, berry trees, travel, citizens, day/night, town guide map marks
- Wild battles, NPC trainer battles, gyms, badges, badge case, Elite Four, Team Rocket, bosses, PSoul dungeons, Ranger Club, Safari Zone, Battle Tower, Frontier Island, Stadium Arena, Wave Arena, tournaments, PvP arena, duels, quests
- Bank, Pokémon market, PokéTrader, premium shop, SoulCoins, casino/slot machine, autoloot, TV, polls, guilds, houses, Wiki Chat, referrals, coupons, highscores, achievements, doll case, clothes/addons, statistics/datalog, localization, tips/tutorial
- Halloween, Easter, Christmas and July Vacation (disabled in both), birthday/respect boxes

### PRESENT ONLY IN POKENATION
- Server-wide EXP event (`/doubleexp`, `/expevent`, `sys/056`, C++ multiplier)
- PSoul binary item market (C++ `iomarket`, 0xF4–0xF9)
- Mastery, reachable in practice (Verse loads the code but spawns no mastery NPCs)
- Hometown change at Nurse Joy
- Surprise-box spawning, the Sudowoodo respawn event and the startup quest spawns (code present in Verse, switched off)
- Anniversary event active (Verse has it switched off)
- The larger PSoul world: Orange Archipelago and southern regions, about 10,000 more spawns, more quest/bank/Soul Trade NPCs, 381 more houses
- Engine fixes: BUG-01 combat fix, BUG-05 GM energy, BUG-08 language validation, BUG-68 login challenge, the C++ extended-opcode dispatcher
- New OTClient Redemption client (`client-pokenation/`) with the PSoul protocol profile and a ported Pokémon UI, including `game_pokemondetails`

### PRESENT ONLY IN POKEVERSE
- IVs, EVs, natures, base-stat upgrades, friendship, graphical Pokémon Info
- Battle Pass, Daily Calendar, modern Dungeon UI, Crafting, Professions, kill tasks, daily kill, daily catch, graphical market, graphical shop (diamonds/PokeCoins), in-client account creation, notifications, updater, depot password lock
- Guardian Pokémon, XP banners, daily NPC gift boxes, `/evolve` command, fly/find hotkey aliases (`h1`–`h3`), stack-money button, graphical house windows, bottom/top menu, chat module, server ambient-sound sender
- Level-scaled player EXP loss on death; wild Pokémon retaliate when attacked; zero-energy moves

### SAME SYSTEM BUT BETTER IN POKENATION
- Localization (BUG-08/09 fixed; extended opcode 1 handled)
- Pokédex (status list still sent at login)
- Mastery, quests, bank, Soul Trade, Ranger Club, guides (more NPCs placed on the larger map)
- Fishing (keeps the cast-range check)
- NPC trainer battles, gyms and duels (C++ fix works under `no-pvp`; Verse relies on `worldType = "pvp"`)
- Anniversary (runs, though permanently)
- TM chooser (listener leak fixed in Nation's new client)

### SAME SYSTEM BUT BETTER IN POKEVERSE
- Tournaments (all four tiers enabled; no BUG-20)
- Pokémon addons (about 100 extra addons)
- Clothes/outfits (209 vs 80, plus a clothes shop)
- Pokébar (shows level, energy, gender and EXP)
- Houses (graphical windows, apart from the dead owner panel)
- Boost (`extraPoints`), now visible in Pokémon Info

### SAME SYSTEM BUT BROKEN IN POKEVERSE
- Mastery (unreachable: no NPCs on the map)
- Surprise boxes, the Sudowoodo respawn event and the startup quest spawns (switched off)
- Hometown change (commented out)
- Pokédex status at login (removed; the client still expects it, so the grid is likely empty; needs a runtime check)
- PSoul item-market NPC script (`npc/market.lua` calls a C++ function Verse no longer registers; the NPC is unspawned in both)

### REPLACED BY A NEWER JORNADAS IMPLEMENTATION
- PSoul binary item market → graphical Lua market (opcode 64), currently broken by missing tables
- Ball look text and `pn/game_pokemondetails` → `game_pokemonInfo` window
- Server EXP event (Nation) → per-player boosts and area XP banners (different scope, not a true equivalent)
- `/house …` commands → `!buyhouse`-style commands and house UI modules
- Old disabled task system (`sys/disabled/005-task.lua`) → `057-Module_Kill.lua` kill tasks and daily kill/catch
- Premium shop via website and Soul Trade → in-client `game_shop` (diamonds, PokeCoins)

---

## Engine-level differences

**Server C++.** Compared `/workspace/server/source` with Nation's `server/src`, and both with Nation's `original/server/source`.

- Only in Nation: `iomarket.cpp/.h` (binary market), `extendedopcodes.h` (C++ dispatcher for extended opcodes 0/1) and `schemas/` (SQL). Only in Verse: `CMakeLists.txt`. Every other file exists in both.
- **Nation changes are small and targeted** (25 files, mostly under 30 changed lines):
  - BUG-01 `combat.cpp`: consented fights work under `no-pvp`.
  - BUG-05: infinite-mana energy reporting.
  - BUG-08 language validation (`localization.cpp`, `iologindata.cpp`, `protocollogin.cpp`).
  - BUG-09 PokeNation OS ids 0x14–0x17 (`enums.h`).
  - BUG-68 login-challenge check (`protocolgame.cpp`).
  - Boost.Asio port (`connection.*`, `server.*`).
  - Server EXP event (`Game::getExpEventMultiplier`, `Player` EXP gain, `SERVER_EXP_EVENT_MULTIPLIER`).
- **Verse changes are large** (game.cpp about 1,100 changed lines, protocolgame.cpp about 1,300, luascript.cpp about 200):
  - The binary market is commented out (`parseMarket*`, `sendMarket*`, `Game::player*Market*`, `doPlayerSendMarketEnter`).
  - In-client account and character creation (`protocollogin.cpp` versions `0xFC`/`0xFD`, `IOLoginData::createAccount/createCharacter`, `XML/CreateAcc.xml`).
  - Extended Pokébar packets (level, energy, gender, EXP).
  - Item packets carry Pokémon name, level and gender; creature packets carry types, level and EXP.
  - Guardian and passive-retaliation logic in `monster.cpp`; item stacks up to 10,000.
  - New Lua bindings (`getContainerItems`, `doItemSetCount`, `doPlayerSendMarketMailByName`).
  - Verse has **none** of Nation's fixes: `combat.cpp` and `localization.cpp` are byte-identical to the original, the login challenge is skipped, and the shutdown bug (BUG-72) is still in `server.cpp`.
- PSoul C++ subsystems in both: TV/cast channels (`TVChannel`, `/tvlist`), autoloot (`Player::autoLoot`), party duels (`partyduel.cpp`), PvP/survive arenas (`pvparena.cpp`), tournaments (`tournament.cpp`, `iotournament.cpp`), polls (`polls.cpp`, `iopoll.cpp`), datalog (`iodatalog.cpp`), player statistics (`ioplayerstatistics.cpp`), guilds (`ioguild.cpp`), houses and localization. The bank is NPC Lua in both. **Guild war exists in neither** (only a `znote_guild_wars` website table in Verse's dump).
- Extended opcodes: Verse dispatches every client→server opcode in Lua (`creaturescripts/scripts/opcode.lua`: 41, 61, 62, 63, 64, 103), with opcode 10 (dash) in C++. Nation handles 0/1 in C++ (`extendedopcodes.h`) and has no Lua dispatcher.

**Client C++ (PSoul `0xFF` family).**
- Both use the same 26 sub-opcodes (`protocolcodes.h` identical to the legacy PSoul client). Verse's `protocolgameparse.cpp` changes the payloads:
  - 0x04/0x06 Pokébar add/update append `U8 level, U16 maxEnergy, U16 energy, U16 gender, U8 exp%`.
  - Item reads append `string pokemonName` (+ `U32 level, U32 gender` unless `"none"`).
  - Creature reads append `U8 type1, U8 type2, U16 level, U32 exp`.
- **The Verse wire format therefore no longer matches PokeNation's legacy client or the new `psoul312` Redemption client.** Porting either Nation client to Verse, or Nation server code to Verse, needs these fields reconciled.
- Nation's new client adds `protocolgameparsepsoul.cpp` (gated by `GamePSoulProtocol`), reads the `0x14`/`0x19` counts as `U16` (BUG-59/60), and fixes the jump assertion (BUG-75).

---

## Counts

"Meaningful PokeNation systems" means every row above whose PokeNation status is not MISSING: **110** systems. Each one is in exactly one bucket.

| Bucket | Count | Systems |
|---|---|---|
| Present in Verse (same or modified, same activation state as Nation) | **100** | All other non-MISSING rows, including the four events disabled in both and the environment/sound feature that is dead in both |
| Replaced by a Jornadas implementation | **2** | PSoul binary item market (→ graphical market, itself broken); Pokémon details window (→ Pokémon Info) |
| Missing, disabled or unreachable in Verse | **7** | Server-wide EXP event, Mastery (no NPCs), hometown change, surprise boxes, Sudowoodo respawn event, startup quest spawns, Anniversary |
| Broken in Verse (static) | **0** | No Nation system is statically broken in Verse. The definite static breaks are all in Jornadas additions: EVs, graphical market, stack-money button, house owner panel |
| Uncertain | **1** | Pokédex (status list no longer sent at login) |

Jornadas-only systems: 28 rows (§3 IV/EV/nature/base/friendship/Pokémon Info plus the §8 rows). Statically, 4 are BROKEN (EVs, graphical market, stack money, house owner panel), 13 are PARTIAL and the rest APPEARS IMPLEMENTED or NOT TESTED.
