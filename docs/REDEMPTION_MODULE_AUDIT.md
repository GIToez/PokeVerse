# Redemption Module Audit

Every Lua module of the legacy reference client (`client/runtime-data/modules/`) is listed here with what happened to it in the Redemption client (`client-redemption/modules/`).

Statuses:
- **PORTED + TESTED**: the module was rewritten for Redemption, and `tools/smoke_redemption_login.sh` exercises it against the server on every run.
- **PORTED**: rewritten but not exercised by a run.
- **REDEMPTION BUILT-IN**: Redemption's own module does the job and speaks the same Tibia 8.54 protocol.
- **NOT PORTED**: no Redemption equivalent yet.

A module is never PASS on inspection alone. Smoke lines are quoted as `LINE` from local Linux runs on 2026-10-07; CI runs the same script on Windows and Linux (`PLATFORM_COMPATIBILITY.md`).

## PokeVerse modules ported in Phase 3

| Legacy module | Redemption module | Channel | Status | Evidence (smoke lines) |
|---|---|---|---|---|
| `game_pokebar` | `game_pokebar` | 0xFF PokemonBar* | PORTED + TESTED | `MODULE game_pokebar visible=true portraits=6`, `SUMMON OK`, `SWITCH OK`, `RECALL OK`, `RESUMMON OK` |
| `game_pokemoves` | `game_pokemoves` | 0xFF MoveBar*, PokemonMoves, cooldown | PORTED + TESTED | `MOVE OK move=Tackle cooldown=1 overlay=true … health=100->0` |
| `game_pokemonInfo` | `game_pokemonInfo` | ext opcode 63 | PORTED + TESTED | `INFO OPEN OK`, `EV ALLOCATE OK hp=17->18 points=483->482`, `EV FORGED REJECTED`, `EV PERSIST OK` after recall and summon |
| `game_pokedex` | `game_pokedex` | 0xFF Pokedex* | PORTED + TESTED | `DEX LOGIN STATUS OK entries=386`, `DEX OPEN OK`, `DEX INFO OK id=4 name=Charmander type1=Fire moves=8 families=4,5,6` |
| HUD (trainer health, Pokémon energy and level) | `game_healthinfo` | Tibia player stats: mana is the summon's energy, magic level its level | PORTED + TESTED | `HUD trainer=185/185 energy=0/5200 pokemonLevel=100(1%) summon=Rattata health=66%` |
| `game_statusbar` | `game_statusbar` | 0xFF 14/15/16 | PORTED + TESTED (signals injected by the test; real battle conditions NOT TESTED) | `STATUSBAR ADD OK`, `REMOVE OK`, `CLEAR OK` |
| `game_tmchoose` | `game_tmchoose` | 0xFF 13, answered with `/tc` | PORTED + TESTED | `TM WINDOW OK moves=3`, `TM CONFIRM OK chosen=11695`, `TM FORGED REJECTED` |
| Achievements (`game_questlog` tab) | `game_questlog` | ext opcode | PORTED + TESTED | `QUESTLOG OK quests=3`, `ACHIEVEMENTS OK entries=149 completed=2` |
| `game_pass` | `game_pass` | ext opcode 61 | PORTED + TESTED | `PASS OPEN OK … missions=27`, `PASS FORGED COLLECT IGNORED`, `PASS BUY REFUSED reply=This Battle Pass season has ended.` |
| `game_task` | `game_task` | ext opcode 58 | PORTED + TESTED | `TASK ACCEPT OK`, `TASK SECOND REFUSED`, `TASK EARLY COLLECT REFUSED`, `TASK PROGRESS doing=rattata kills=1/40`, `TASK CANCEL OK` |
| `game_pokekill` | `game_pokekill` | ext opcode 59 | PORTED + TESTED | `POKEKILL POPUP OK visible=true panel=moduleKill text=Rattata 1/40`. The NPC-task panel (`WindowName = "npc"`) is ported but no server script sends it |
| `game_craft` | `game_craft` | ext opcode 103 | PORTED + TESTED (GM) | `CRAFT MISSING REFUSED`, `CRAFT FORGED QUANTITY REJECTED`, `CRAFT CREATE OK wool=6->5`, `CRAFT COLLECT OK cloth=14->15` |
| `game_shop` (diamond shop) | `game_pokeshop` | ext opcode 27 | PORTED + TESTED | `SHOP FORGED OFFER REFUSED`, `SHOP BUY OK diamonds=15->10`, `SHOP RATE LIMIT OK`, Trainer `SHOP INSUFFICIENT REFUSED`. Server prices only; see `SECURITY_AUDIT.md` |
| `game_market` (player market) | `game_pokemarket` | ext opcode 64 | PORTED + TESTED (two accounts) | `tools/smoke_market.sh`: `MARKET LIST OK`, `MARKET FORGED BUY/SELL/ACCEPT/OFFER REFUSED`, `MARKET BUY OK gold=100->90`, `MARKET SELL OK`, `MARKET CANCEL OK`, `MARKET MAKE OFFER OK`, `MARKET OFFER OK`, `MARKET OFFERS TO ME OK`, `MARKET ACCEPT OK`, `MARKET HISTORY OK`, plus 16 database checks (rows, mailed items and coins, history, `logs/market.log`) |
| `game_lootlist` | `game_lootlist` | 0xFF 26 LootList | PORTED + TESTED | `LOOT LIST OK visible=true icons=2 items=12830x1,11076x1` after `/autoloot` and using a defeated Rattata's corpse. When the Rattata drops nothing (about 60%), the run logs `LOOT EMPTY` and must have seen "Loot of a Rattata: nothing." |

Redemption's own Tibia store (`game_store`), Tibia market (`game_market`) and the other upstream systems below are not PokeVerse features. They stay in the tree, and the production profile disables the ones the server cannot serve (`CLIENT_VARIANTS.md`).

## Legacy modules covered by Redemption built-ins

| Legacy module | Redemption module | Status | Notes |
|---|---|---|---|
| `client`, `client_*`, `corelib`, `gamelib`, `game_interface`, `game_things` | same names | REDEMPTION BUILT-IN | PokeVerse additions live in `gamelib/pokeverse.lua` (0xFF parser), `gamelib/protocollogin.lua` (language byte, character list fields) and `game_features` |
| `game_containers` | `game_containers` | REDEMPTION BUILT-IN, TESTED | The market and craft tests open the backpack and move items out of it |
| `game_console`, `game_chat` | `game_console` | REDEMPTION BUILT-IN, TESTED (say, server and NPC text) | The legacy `game_chat` (1,425 lines of custom channel UI) is not ported; channels work through `game_console` |
| `game_inventory`, `game_skills`, `game_battle`, `game_minimap`, `game_hotkeys`, `game_outfit`, `game_viplist`, `game_textmessage`, `game_textwindow`, `game_questlog`, `game_npctrade`, `game_playertrade`, `game_playerdeath`, `game_ruleviolation`, `game_bugreport`, `game_tutorial`, `game_notifications`, `game_healthinfo` | same names | REDEMPTION BUILT-IN | Inventory and text messages are exercised by the smoke. NPC trade, player trade, outfit, VIP, death screen, rule violation and bug report are NOT TESTED |
| `game_combatcontrols`, `game_bottommenu` | `game_mainpanel` | REDEMPTION BUILT-IN | Fight and chase modes live in the main panel; the PokeVerse buttons (Pokédex, Pokémon Info, Battle Pass, Tasks) are added there |

## Legacy modules not ported

Every one of these still works in the legacy client. The server side is unchanged, so each is a client-only port.

| Legacy module | What it does | Server channel | Size (Lua lines) | Status |
|---|---|---|---|---|
| `game_calendar` | Daily reward calendar and its shop | ext opcode 62 | 562 | NOT PORTED |
| `game_dungeon` | Dungeon teams, queue, difficulty and ranking | ext opcode 41 (JSON) | 656 | NOT PORTED |
| `game_depotlock` | Depot lock window | ext opcode `DepotLock` | 402 | NOT PORTED |
| `game_dollcase` | Doll collection case | 0xFF DollCaseStatus / DollCaseUpdate (parsed) | 349 | NOT PORTED |
| `game_badgecase` | Badge case shown when the badge container opens | container open | 101 | NOT PORTED |
| `game_slotmachine` | Casino slot machine | 0xFF SlotMachine (parsed) | 190 | NOT PORTED |
| `game_poll` | Poll window | 0xFF PollWindow (parsed) and 0xFA/0xFB | 143 | NOT PORTED (no poll in the dev database) |
| `game_tips` | Tutorial tips | 0xFF Tip (parsed); sent by quest steps | 62 | NOT PORTED |
| `game_guide` | Gameplay tutorial image and text | ext opcodes `GameplayTutorialImage/Text` | 61 | NOT PORTED |
| `game_advanceeffect` | Level-up and Pokémon level-up effects | 0xFF PokemonLevelUp (parsed), skill change | 306 | NOT PORTED |
| `game_duelmessage` | Duel notification | skill change | 71 | NOT PORTED |
| `game_effects` | Creature effect overlays | creature signals | 120 | NOT PORTED |
| `game_time` | In-game clock | login light hour (parsed) | 158 | NOT PORTED |
| `game_environment` | Ambient sounds and effects | none (data tables, 353k lines) | 353,420 | NOT PORTED |
| `game_house`, `game_housebuy`, `game_houseowner`, `game_houseownerenter` | House look, purchase and owner panels | `OPCODE_HOUSE` | 122–132 each | NOT PORTED. The owner panel never filled in the legacy client either (`KNOWN_ISSUES.md` #2) |
| `poke_create` | In-client account creation | login server | 268 | NOT PORTED |
| `game_updater` | Legacy file updater | HTTP | 120 | NOT PORTED. Redemption has its own `updater`, disabled in production |

The 0xFF parser already emits every signal these modules listen to, so each port is UI work plus a smoke step. Suggested order, by how often players meet the feature: calendar, dungeon, depot lock, tips and guide, advance effect, doll and badge cases, slot machine, houses, poll, time, duel message, effects, environment, account creation.
