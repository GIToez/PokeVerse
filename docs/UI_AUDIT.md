# UI Audit

One row per client UI in `client/runtime-data/modules/`. **Nothing has been run**, so statuses come from reading the code; see [FEATURE_AUDIT.md](FEATURE_AUDIT.md) for what the statuses mean. Lua and OTUI are file counts. Assets is the number of PNG/JPG images inside the module folder (shared images live in `client/runtime-data/data/images`). Rows marked **★** are part of what makes the PokeJornadas UI distinctive (see [CLIENT_UI.md](CLIENT_UI.md)).

## Custom PokeJornadas / PSoul UIs

| UI Feature | Module | Lua | OTUI | Assets | Server Dependency | Status |
|---|---|---|---|---|---|---|
| ★ Bottom menu bar | `game_bottommenu` | 1 | 1 | 7 | None (opens other modules) | Appears Implemented |
| ★ Top-menu icons | `client_topmenu` | 1 | 1 | 0 (+38 in `data/images/topbuttons`) | None | Appears Implemented |
| ★ Custom HP bars | C++ + `data/images/new_bar.png` | — | — | 1 | Creature health (stock) | Appears Implemented |
| ★ Pokébar (party) | `game_pokebar` | 1 | 1 | 35 | PSoul 0xFF sub-opcodes 3–8 | Appears Implemented |
| ★ Move bar | `game_pokemoves` | 1 | 1 | 0 | PSoul 0xFF 1, 9 (2 has no listener) | Appears Implemented |
| ★ Pokémon info / upgrades | `game_pokemonInfo` | 1 | 1 | 100 | Opcode 63 (JSON), `lib/game_pokemonInfo.lua` | Partial (server-side EV and friendship bugs) |
| ★ Battle pass | `game_pass` | 1 | 2 | 102 | Opcode 61 (`loadstring`), `lib/game_pass.lua` | Partial (season expired 2021-11-04) |
| ★ Daily calendar | `game_calendar` | 2 | 1 | 66 | Opcode 62 (`loadstring`), `lib/game_calendar.lua` | Partial (only Sep 2021 configured) |
| ★ Dungeon browser | `game_dungeon` | 2 | 5 | 66 | Opcode 41 (JSON), `lib/game_dungeon.lua`, `dungeon_ranking` (missing) | Partial |
| ★ Game shop | `game_shop` | 8 | 7 | 2,455 | Opcode 27 + shop talkactions | Partial (`/shoppokecoin` unregistered) |
| ★ Global market | `game_market` | 1 | 5 | 37 | Opcode 64 (`loadstring`), `lib/game_market.lua`, missing tables | Broken (missing `market_items` / `market_historic`) |
| ★ Craft / professions | `game_craft` | 1 | 1 | 38 | Opcode 103 (`loadstring`) | Partial (only rank E) |
| ★ Kill tasks | `game_task` | 1 | 1 | 74 | Opcode 58 (`loadstring`) | Appears Implemented |
| ★ Notifications / broadcasts | `game_notifications` | 1 | 3 | 33 | Opcode 25 (JSON) | Partial (`/images/game/pokes/` missing) |
| ★ Login background | `client_background` | 1 | 1 | 25 | None | Appears Implemented |
| ★ Enter game / character list | `client_entergame` | 2 | 4 | 22 | Login protocol | Appears Implemented |
| ★ Account / character creation | `poke_create` | 1 | 2 | 12 | Custom login packets `0xFC`/`0xFD` | Appears Implemented (insecure; SECURITY_AUDIT 15) |
| ★ Day/night clock | `game_time` | 1 | 1 | 6 | World light / time | Appears Implemented |
| Depot lock | `game_depotlock` | 4 | 7 | 41 | Opcode 60 + talkactions | Appears Implemented |
| Daily kill log | `game_pokekill` | 1 | 1 | 19 | Opcode 59 | Appears Implemented |
| Pokédex | `game_pokedex` | 1 | 4 | 6 | PSoul 0xFF 10–12, 17 | Appears Implemented |
| TM choice | `game_tmchoose` | 1 | 1 | 0 | PSoul 0xFF 13 | Appears Implemented |
| Status bar (conditions) | `game_statusbar` | 1 | 1 | 0 | PSoul 0xFF 14–16 | Appears Implemented |
| Level-up effect | `game_advanceeffect` | 1 | 1 | 0 | PSoul 0xFF 25 | Appears Implemented |
| Creature effects | `game_effects` | 1 | 0 | 0 | PSoul 0xFF 19 | Appears Implemented |
| Doll case | `game_dollcase` | 1 | 1 | 0 | PSoul 0xFF 20–21 | Appears Implemented |
| Badge case | `game_badgecase` | 1 | 1 | 0 | Badge system | Unknown |
| Slot machine | `game_slotmachine` | 1 | 1 | 0 | PSoul 0xFF 22 | Appears Implemented |
| Tips | `game_tips` | 1 | 1 | 0 | PSoul 0xFF 23 | Appears Implemented |
| Polls | `game_poll` | 1 | 1 | 0 | PSoul 0xFF 24, C++ `iopoll` | Appears Implemented |
| Loot list | `game_lootlist` | 1 | 1 | 0 | PSoul 0xFF 26 | Appears Implemented (case-sensitive `loadUI('lootList')`) |
| Duel invite | `game_duelmessage` | 1 | 1 | 0 | C++ `partyduel` | Appears Implemented (case-sensitive `loadUI('duelMessage')`) |
| Gameplay guide popups | `game_guide` | 1 | 1 | 0 | Opcodes 8/9 | Appears Implemented |
| Tutorial book | `game_tutorial` | 79 | 1 | 0 | None (local content) | Appears Implemented |
| House info | `game_house` | 1 | 4 | 8 | Opcode 199 | Appears Implemented |
| House buy | `game_housebuy` | 1 | 1 | 4 | Opcode 201 | Appears Implemented |
| House owner panel | `game_houseowner` | 1 | 1 | 2 | Opcode 200 (**no server sender**) | Broken |
| House owner enter | `game_houseownerenter` | 1 | 1 | 2 | Opcode 202 | Appears Implemented |
| Client updater | `game_updater` | 1 | 1 | 17 | C++ WinINet updater + HTTP host (not included) | Unknown (insecure; SECURITY_AUDIT 2) |
| Chat (replaces console) | `game_chat` | 1 | 4 | 0 | Stock channels | Appears Implemented |
| Locale switch | `client_locales` | 2 | 1 | 0 | Opcode 1 (no server handler) | Partial |
| Options (incl. dash walking) | `client_options` | 1 | 5 | 0 | Opcode 10 (C++) | Appears Implemented |
| Inventory (incl. stack money) | `game_inventory` | 1 | 1 | 0 | Opcode 141 (**no server handler**) | Partial |
| Ambient sound | `game_environment` | 4 | 1 | 0 | Opcodes 81/85 never handled; module not loaded | Broken |

## Stock OTClient UIs (lightly or not customised)

| UI Feature | Module | Lua | OTUI | Assets | Server Dependency | Status |
|---|---|---|---|---|---|---|
| Game interface root | `game_interface` | 3 | 7 | 14 | Game protocol | Appears Implemented |
| Health info | `game_healthinfo` | 1 | 1 | 0 | Stock | Appears Implemented |
| Battle list | `game_battle` | 1 | 2 | 0 | Stock | Appears Implemented |
| Minimap | `game_minimap` | 1 | 2 | 0 | Stock | Appears Implemented |
| Containers | `game_containers` | 1 | 1 | 0 | Stock | Appears Implemented |
| Skills | `game_skills` | 1 | 1 | 0 | Stock | Appears Implemented |
| Combat controls | `game_combatcontrols` | 1 | 1 | 0 | Stock | Appears Implemented |
| Hotkeys | `game_hotkeys` | 1 | 1 | 0 | Stock | Appears Implemented |
| Outfit | `game_outfit` | 1 | 2 | 0 | Stock | Appears Implemented |
| NPC trade | `game_npctrade` | 1 | 1 | 0 | Stock | Appears Implemented |
| Player trade | `game_playertrade` | 1 | 1 | 0 | Stock | Appears Implemented |
| VIP list | `game_viplist` | 1 | 3 | 0 | Stock | Appears Implemented |
| Quest log | `game_questlog` | 1 | 2 | 0 | Stock | Appears Implemented |
| Text messages | `game_textmessage` | 1 | 1 | 0 | Stock | Appears Implemented |
| Text window | `game_textwindow` | 1 | 1 | 0 | Stock | Appears Implemented |
| Player death | `game_playerdeath` | 1 | 1 | 0 | Stock | Appears Implemented |
| Bug report | `game_bugreport` | 1 | 1 | 0 | Stock | Appears Implemented |
| Rule violation | `game_ruleviolation` | 1 | 1 | 0 | Stock | Appears Implemented |
| Terminal | `client_terminal` | 2 | 1 | 0 | None | Appears Implemented |
| Console (unused) | `game_console` | 1 | 5 | 0 | — | Unknown (not loaded) |
| Server list (unused) | `client_serverlist` | 2 | 2 | 0 | — | Unknown (not loaded) |
| Libraries | `client`, `client_styles`, `corelib`, `gamelib`, `game_things` | 1 / 1 / 41 / 19 / 1 | 0 | 0 | — | Appears Implemented |

## UIs that do not exist

| UI Feature | Module | Lua | OTUI | Assets | Server Dependency | Status |
|---|---|---|---|---|---|---|
| Held item management | — | — | — | — | `046-heldItem.lua` | Missing |
| Evolution | — | — | — | — | `doPokemonEvolve` | Missing |
| Abilities | — | — | — | — | `017`, `039` | Missing |
| Achievements | — | — | — | — | two achievement systems | Missing |
| Auction (PokéTrader) | — | — | — | — | `poketrader_*` | Missing (NPC dialogue only) |
| Pokémon storage / PC | — | — | — | — | none | Missing |
| Pokémon Center | — | — | — | — | NPC dialogue | Missing |
