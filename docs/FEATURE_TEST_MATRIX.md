# Feature Test Matrix (Phase 2)

All runtime results come from the **source-built** server and client (`dist/`), started with the tools in `tools/`. None come from the original Windows binaries.

**Setup.** Ubuntu 24.04, MariaDB 10.11 and the development database from `tools/setup_dev_db.sh`.

**Evidence sources:**
- **Harness**: `tools/runtime_test.sh`. It logs in as `admin` / `GM Admin` and drives each system the way its UI button does. It records the extended-opcode payloads, the server text messages and the windows that opened, and takes one screenshot per step. Server and client errors are collected separately.
- **Manual**: the client driven with `xdotool` on Xvfb or the VM display, as `player` / `Trainer`.
- **Smoke**: `tools/smoke_server.sh` and `tools/smoke_login.sh`. CI runs these.
- **Static**: reading the source, plus `tools/validate.py` (Lua and XML syntax, script references, module references, payload format and codec, database tables).

**Results:**
- **PASS**: the system did what it should at runtime, with no server or client error.
- **PARTIAL**: the main path works, but part of the system was not exercised or has an open bug.
- **FAIL**: broken at runtime.
- **NOT TESTED**: no runtime test. Static evidence only.

| System | Static Evidence | Runtime Test | Result | Bugs | Notes |
|---|---|---|---|---|---|
| Server build | `server/source/CMakeLists.txt`, `tools/build_server.sh`; fixes listed in `BUILD_BASELINE.md` | CI and local builds with GCC 13 | PASS | — | Also passes from a fresh clone plus `git lfs pull` |
| Client build (Linux) | `tools/build_client.sh`, `client/source` | CI and local builds | PASS | — | The harness variant (`VARIANT=harness`) builds from the same source with bot protection off |
| Server startup | `tools/smoke_server.sh` | Smoke (local and CI) | PASS | Fixed: spells dir, charset, encryption marker, missing tables, log dirs | Only the harmless "Outdated MySQL" warning remains (`SERVER_STARTUP_REPORT.md`) |
| Database schema | `tools/check_db_tables.py`; migration `001_phase2_baseline.sql` | `validate.py db` (every table the Lua references exists) | PASS | Fixed: market and dungeon tables | — |
| Account login and character list | `protocollogin.cpp`; SHA-1 passwords | Smoke, manual, harness: `player` → Trainer and `admin` → GM Admin | PASS | Fixed: CI login smoke (language picker on a fresh profile, click offsets) | Development accounts only |
| Enter game and render | — | Manual and harness: map, inventory, minimap, health and chat render; the title shows the character | PASS | — | Screenshot `00-login.png` |
| Walking | — | Manual: arrow keys | PASS | — | — |
| Chat (say, Default tab, NPC replies) | `modules/game_chat` | Manual: "ola pokeverse" appears in the tab and above the character; Professor Oak's greeting arrives | PASS | Fixed: Ctrl+A used `consoleTextEdit`, which `game_chat` does not have | Screenshot `chat-default-tab.png` |
| NPC and monster speech bubbles | `client/statictext.cpp` | Harness: Pokémon move calls and NPC chatter with no client error | PASS | Fixed: Lua stack leak that aborted assert-enabled builds | — |
| Containers / pokébag | `modules/game_containers` | Harness: the pokébag opens and `/i` items arrive | PASS | Fixed: crash when a container reused a slot that had no window | — |
| GM item creation `/i` | `talkactions/scripts/createitem.lua` (access 4) | Harness: balls, food, money, held item, vitamin, market PC | PASS | — | With no count it creates 1000; always pass `,1` |
| GM Pokémon creation `/cb` | `talkactions/scripts/pokemon.lua` | Harness: `/cb Charmander,15,10` gives a charged ball | PARTIAL | `/cb charmander` (lower case) errors in `getPokemonSpecialAbilities`: the name check ignores case but the table lookup does not | GM-only tool; left as is |
| Summon and recall (ball in feet slot) | `lib/ps/functions/ball/charged.lua` | Harness: Charmander appears and returns. A level-50 Pokémon is refused for the level-8 GM ("must be at least level 40") | PASS | — | Level rule: `MAX_LEVEL_DIFF_BETWEEN_PLAYER_POKEMON = 10` |
| Pokémon Info window | `lib/game_pokemonInfo.lua`, `modules/game_pokemonInfo` | Harness: `/pokeivev` sends the full Info payload (IVs, EVs, base, friendship) and the window opens | PASS | Fixed: the info reply errored when no Pokémon was summoned | Without a summon the client says "You must call your Pokemon first" (original behavior) |
| EV spend | `upgradeEv` | Harness: HP +10 and Sp.Def +5; points 75 → 60; the ball description shows `(+10)` and `(+5)` | PASS | Fixed: `evspendingPoints` attribute was missing (Phase 2 fix) | — |
| EV reset | `doResetEvs` | Harness: EVs back to +0 and points 75; reply `IvReseted` | PASS | — | The request needs the reset item (35552) |
| Friendship: feed | `friendship` / `type=exp` | Harness: an apple gives 25 EXP | PASS | — | — |
| Friendship: level up | `friendship` / `type=level` | Harness: with no money → `SemDinheiro` and nothing removed; with 50,000 → level 1→2, 30,000 removed | PASS | Fixed: the insufficient-funds path used to remove money (Phase 2 fix) | — |
| Held items (Dragon Fang) | `046-heldItem.lua` | Harness: "received the Dragon Fang held item"; the ball shows "Held Item: Dragon Fang" | PASS | Fixed: Dragon Fang used the wrong element constant (Phase 2 fix) | Refused while the Pokémon is out (original behavior) |
| Vitamins (Zinc) | `040-vitamin.lua` | Harness: "received the Zinc vitamin … +5% Special Defense" | PASS | Fixed: Zinc description id (Phase 2 fix) | — |
| Pokédex | `010-pokedex.lua`, `lib/ps/config/pokemon.lua` | Harness: using the dex on Charmander registers it (+140 XP, achievement "This is a Pokedex!") | PASS | Fixed: `getPokemonDexStorage` was undefined, so every dex use failed | — |
| Achievements | `023-achievement.lua` | Harness: "The First!" on first login, "This is a Pokedex!" | PASS | — | — |
| Wild Pokémon combat | `004-skillDamage.lua`, monsters | Harness: Charmander damages and kills a GM-spawned Rattata ("Loot of a Rattata: a bitten apple", +375 XP) in one run | PARTIAL | — | In later runs the Rattata spawned on a tile the Charmander could not reach, so it never died. Spawn placement, not a code fault |
| Catching (empty ball on corpse) | `lib/ps/functions/ball/empty.lua` | Harness: the throw ran, but there was no fresh corpse; "Sorry, not possible." | NOT TESTED | — | The catch itself has not been exercised; see the combat row |
| Battle Pass | `lib/game_pass.lua`, `modules/game_pass` | Harness: `/passopen` sends Pass, rewards (3 pages) and missions; the window opens | PASS | `Pass.PassVersion` is undefined (`game_pass.lua:363`). Harmless while version = 1 | No new season added (out of scope) |
| Daily sign-in calendar | `lib/game_calendar.lua`, `modules/game_calendar` | Harness: rewards payload with the current date; the window opens | PASS | — | Claiming a reward not exercised |
| Dungeons (map list) | `lib/game_dungeon.lua`, `028-dungeons.lua` | Harness: the `Maps` request returns the map list with rewards, then the player's keys; the window opens | PARTIAL | — | Entering and finishing a dungeon not exercised |
| Crafting | `lib/game_craft.lua`, `modules/game_craft` | Harness: the rank E recipe list loads; the window opens | PARTIAL | — | Crafting an item not exercised |
| Tasks | `lib/057-Module_Kill.lua`, `modules/game_task` | Harness: task list and unlocked ranks load; the window opens | PARTIAL | — | Accepting and finishing a task not exercised |
| Shop (diamond shop) | `talkactions/scripts/shop/open.lua`, `modules/game_shop` | Harness: `/ShopOpen` → `OpenShop`; the window opens | PARTIAL | `/shoppokecoin` is referenced but not registered | Purchases not exercised |
| Market | `lib/game_market.lua` | Harness: using the market PC loads every tab (buy, sell, my offers, history); the window opens | PARTIAL | Fixed: doubled `item_index` in 5 DELETE queries (Phase 2 fix) | Creating, buying and cancelling offers not exercised |
| NPC dialogue | `data/npc`, `npc/scripts` | Manual: Professor Oak greeting | PARTIAL | `Soya.xml` points at a missing script (never spawned) | Shops and quests through NPCs not exercised |
| Duels, PvP arena, tournaments | C++ `partyduel`, `pvparena`, `tournament` | — | NOT TESTED | — | Needs two players |
| Eggs, daycare, breeding | `045-pokemonEgg.lua` | — | NOT TESTED | — | — |
| Fishing, headbutt, surf/fly/ride | `043-fishing.lua`, `036-headbutt.lua`, movement scripts | — | NOT TESTED | — | — |
| Houses | C++ houses, `modules/game_house*` | — | NOT TESTED | On shutdown an uninitialized `warnings` value fails to save for house 221 | — |
| Quests, bosses, Elite Four, events | `002-quest.lua`, `021-boss.lua`, `049-eliteFour.lua`, event systems | — | NOT TESTED | — | Seasonal events are date-gated |
| Updater | `LEGACY_UPDATER` (default OFF) | Client start: reports "up to date" and downloads nothing | PASS (disabled) | — | Disabled by policy |
| Account creation (0xFC/0xFD) | `protocollogin.cpp` behind `__ACCOUNT_CREATION__` | — | DISABLED | — | Security: compiled out (`SECURITY_AUDIT.md`) |
| Client payload decoding | `table.fromLiteral` (data-only parser, replaces `loadstring`) | `validate.py codec`: round-trip plus 7 hostile inputs rejected; the harness decoded every payload above | PASS | — | — |

## Reproduce

```bash
tools/setup_dev_db.sh
KEEP_RUNNING=1 tools/smoke_server.sh /tmp/server-run.log
VARIANT=harness tools/build_client.sh
DISPLAY=:1 tools/runtime_test.sh /tmp/runtime-harness /tmp/server-run.log
```

Before each commit, restore the NPC files the server rewrites at startup: `git checkout -- server/runtime-data/data/npc/`.
