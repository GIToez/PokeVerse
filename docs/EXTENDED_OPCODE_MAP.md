# ExtendedOpcode Map

Static audit of every custom client/server channel in the imported PokeJornadas code. Nothing was executed; all of this comes from reading the source.

Paths are relative to the PokeVerse repository root:

- Client Lua: `client/runtime-data/modules/...`
- Server Lua: `server/runtime-data/data/...`
- Server C++: `server/source/...`
- Client C++: `client/source/src/...`

PokeJornadas uses **four** client/server channels:

1. **ExtendedOpcode** (protocol byte `0x32`): `opcode (u8) + string buffer`. This is the main custom channel, documented below.
2. **PSoul binary sub-protocol** (server opcode `0xFF`, sub-opcode `u8`): hard-coded in C++ on both sides and used for the Pokébar, move bar, Pokédex, and so on. See [PSoul sub-protocol](#psoul-binary-sub-protocol-server--client-opcode-0xff).
3. **Hidden talkactions**: the client sends chat text such as `/shopdiamond ...` through `g_game.talk`. See [Talkaction pseudo-protocol](#talkaction-pseudo-protocol-client--server-via-chat).
4. Stock Tibia 8.6-era protocol opcodes (not custom; not documented here).

## Plumbing

| Side | File | Notes |
|---|---|---|
| Server receive | `server/source/protocolgame.cpp` `ProtocolGame::parseExtendedOpcode` | Reads `u8 opcode` and `string buffer`, then schedules `Game::parsePlayerExtendedOpcode`. |
| Server dispatch | `server/source/game.cpp` `Game::parsePlayerExtendedOpcode` | Opcode `10` (dash walking) is handled **in C++**. Everything else goes to the Lua `extendedopcode` creature events. |
| Server Lua handler | `server/runtime-data/data/creaturescripts/scripts/opcode.lua` (`onExtendedOpcode`), registered as `onOpcode` in `creaturescripts.xml` and in `login.lua` | A single dispatcher for every client→server opcode. |
| Server send | `server/source/protocolgame.cpp` `ProtocolGame::sendExtendedOpcode` and Lua `doSendPlayerExtendedOpcode(cid, opcode, buffer)` (`server/source/luascript.cpp`) | Only sent to OTClient users (`isUsingOtclient`). |
| Client receive | `client/source/src/client/protocolgameparse.cpp` `parseExtendedOpcode` | Opcode `0` enables extended opcodes and `2` is ping-back (both in C++). Everything else goes to Lua `ProtocolGame:onExtendedOpcode`. |
| Client dispatch | `client/runtime-data/modules/gamelib/protocolgame.lua` | `ProtocolGame.registerExtendedOpcode(id, cb)`: one callback per opcode, range 0–255. |
| Client send | `protocolGame:sendExtendedOpcode(id, string)` | |
| Shared constants | `client/runtime-data/modules/gamelib/const.lua` (`ExtendedIds`), `client/runtime-data/modules/gamelib/protocol.lua` (`GameServerOpcodes`), `server/runtime-data/data/lib/ps/others/constants.lua` (`EXTENDED_IDS`), `server/runtime-data/data/lib/000-constant.lua` (`GameServerOpcodes`) | The client defines `TaskModule=58`, `PokeKill=59` and `DepotLock=60` inside its *raw protocol* `GameServerOpcodes` table, but uses them as ExtendedOpcode IDs. |

Payload encodings in use:

- **JSON**, via `json.encode` / `json.decode` (`server/runtime-data/json.lua`, `server/runtime-data/data/lib/json.lua`, and the client corelib).
- **Lua table literal**: the server uses `table.tostring(t)` and the client runs `loadstring("return " .. buffer)()`. **This is remote code execution by design.** See `SECURITY_AUDIT.md`.
- **Ad-hoc strings** with markers such as `###MARKETBUYITEM###,ItemCode:...` or `level#Collect#type`.

## Opcode table

Direction: C→S is client to server, S→C is server to client.

| Opcode | Client Module | Server Script | Purpose | Payload |
|---|---|---|---|---|
| 0 | C++ (`protocolgameparse.cpp`) | C++ engine | `Activate`: the server announces extended-opcode support | empty |
| 1 | `client_locales/locales.lua` (`ExtendedIds.Locale`) | **none found** (language is changed with the `setLanguage` talkaction) | Send or receive the selected locale | S→C/C→S: locale name string. **No server Lua handler.** |
| 2 | C++ | C++ | Ping / ping-back | empty |
| 3–7 | `ExtendedIds.Sound/Game/Particles/MapShader/NeedsUpdate` constants only | `EXTENDED_IDS.*` constants only | Reserved (stock OTClient IDs). No senders or handlers found. | — |
| 8 | `game_guide/guide.lua` (`GameplayTutorialText`) | `creaturescripts/scripts/login.lua`, `lib/ps/events/movements/activationTile.lua`, `lib/ps/events/creaturescripts/gameplayTutorial_onKill.lua`, `npc/scripts/quest_red.lua`, `npc/scripts/gameplayTutorial_shop.lua` | Gameplay tutorial text popup | S→C: plain text |
| 9 | `game_guide/guide.lua` (`GameplayTutorialImage`) | same as 8, plus `lib/ps/config/003-quest.lua`, `npc/scripts/quest_professorOak.lua` | Gameplay tutorial image popup | S→C: image id or path string |
| 10 | `client_options/options.lua` (`ExtendedIds.DashWalking`) | **C++** `Game::parsePlayerExtendedOpcode` → `Player::setIsDashWalking` | Toggle dash walking | C→S: `"1"` / `"0"` |
| 25 | `game_notifications/notifications.lua` | `lib/050-function.lua` `doSendCustomBroadcastMessage` (+ `lib/notifications.lua`) | Animated broadcast and notification banners | S→C JSON: `{action="showBroadcastNotification", background_color, opacity, icon, time, text}` |
| 27 | `game_shop/shop.lua` (`onExtendedOpcode`) | `talkactions/scripts/shop/shop.lua`, `namediamond.lua`, `namepokecoin.lua`, `masteryBuy.lua`, `open.lua`, `lib/050-function.lua` | Game shop responses (balance, purchase results, open shop) | S→C JSON `response` objects. Purchases are C→S **talkactions**, not opcodes. |
| 41 | `game_dungeon/dungeon.lua` | `lib/game_dungeon.lua` (`Dz.Opcode = 41`), `creaturescripts/scripts/opcode.lua`, `lib/ps/events/creaturescripts/onKill.lua` | Dungeon browser, team, queue, ranking | C→S JSON `{protocol="Maps"/"Ranking"/"CreateTeam"/"LeaveTeam"/"InviteToTeam"/"AcceptInvite"/"Play"/"CancelQueue", diff, mapId, name}`. S→C JSON `{protocol="keys"/"team"/"invite"/"ranking"/"close"/"closeinformation", ...}` |
| 58 | `game_task/task.lua` (`GameServerOpcodes.TaskModule`) | `lib/057-Module_Kill.lua`, `talkactions/scripts/task_mod/taskModule.lua`, `talkactions/scripts/task_mod/parseRank.lua` | Kill-task module (task list, ranks) | S→C: Lua table literal (`table.tostring`) or the literal `"[resetList]"`. Client runs `loadstring("__newBuffer = " .. buffer)()`. C→S uses talkactions `/task`, `/parseRank`, `/buyrank`, `/showtaskrank`. |
| 59 | `game_pokekill/pokekill.lua` | `creaturescripts/scripts/dailys/task_kill.lua` | Kill-log popup for the daily kill task | S→C JSON |
| 60 | `game_depotlock/depotlock.lua` | `actions/scripts/depot_passworld.lua`, `talkactions/scripts/deposito/depot_show.lua` | Depot (locker) password lock | S→C JSON `{argument="NoPass"/"NoRelease"/...}`. C→S uses talkactions (depot password commands). |
| 61 | `game_pass/pass.lua` | `lib/game_pass.lua` (`Pass.opcode`), `talkactions/scripts/passopen.lua`, `talkactions/scripts/pass/pass35.lua`, `talkactions/scripts/pass/pass50.lua`, `creaturescripts/scripts/opcode.lua` | Battle pass ("Passe do Treinador") | C→S strings: `"BuyLevel"`, `"BuyPass35"`, `"BuyPass50"`, `"<level>#Collect#<passType>"`. S→C: Lua table literal (client `loadstring`). C→S talkactions `/SendPass35`, `/SendPass50`. |
| 62 | `game_calendar/calendar.lua` | `lib/game_calendar.lua`, `creaturescripts/scripts/opcode.lua`, `creaturescripts/scripts/login.lua` (`sendDRShop`) | Daily login reward calendar and its reward shop | C→S strings: `"<month>REQUEST<year>"`, `"COLLECT"`, `"###BUYITEM###<id>"`. S→C: Lua table literal (client `loadstring`). |
| 63 | `game_pokemonInfo/pokemonInfo.lua` | `lib/game_pokemonInfo.lua`, `creaturescripts/scripts/opcode.lua`, `talkactions/scripts/pokeivev.lua` | Pokémon info window: base and IV/EV upgrades, friendship, resets | C→S JSON `{protocol="upgrade", patternId="base"/"ivev", tab={...}}`, `{protocol="friendship", type="exp"/"level", id, useDiamonds}`, `{protocol="reset", type="ivev"/"base"}`. S→C JSON `{protocol="Info", ...}`. Reset consumes item 35552 (IV/EV) or 35553 (base). |
| 64 | `game_market/market.lua` (`marketOpcode`) | `lib/game_market.lua`, `actions/scripts/market.lua`, `creaturescripts/scripts/opcode.lua` | Global player market | C→S marker strings: `###MARKETALL###`, `###MARKETBUYITEMS###,Page:,Order:,...`, `###MARKETOFFERSITEMS###`, `###MARKETBUYITEMSOFFERSBYITEMCODE###,ItemCode:`, `###MARKETBUYITEM###`, `###MARKETBUYPOSTOFFER###`, `###MARKETBUYCANCELMAKEOFFER###`, `###MARKETBUYMAKEOFFER###`, `###CHECKCANSELL###,X:,Y:,Z:`, `###MARKETSELLITEM###`, `###MARKETREMOVESELLITEM###`, `###MARKETSELLITEMS###`, `###MARKETACCEPTOFFER###`, `###MARKETREFUSEOFFER###`, `###MARKETCANCELOFFER###`. S→C: Lua table literal (client `loadstring`). |
| 65 | — | `lib/000-constant.lua` (`GameServerOpcodes.Dungeon = 65`) | Defined but unused. The dungeon system actually uses 41. | — |
| 81 | **no client handler found** | `lib/059-AmbientSound.lua` | Stop ambient sound | S→C: empty string. **Dropped by the client.** |
| 85 | **no client handler found** | `lib/059-AmbientSound.lua` | Play ambient sound | S→C: `"<sound>|true/false"`. **Dropped by the client.** The client's `game_environment` module plays sounds from local tables instead. |
| 103 | `game_craft/craft.lua` (`opcode = 103`) | `lib/game_craft.lua` (`CRAFT.OPCODE`), `creaturescripts/scripts/opcode.lua` | Crafting / professions | C→S strings: `"###RANK###<rank>"`, `"###CRAFT###,RANK<r>,ID<id>,QNT<n>"`, `"<rank>###SPEEDUP###<id>"`, `"<rank>###COLLECT###<id>"`. S→C: Lua table literal (client `loadstring`). |
| 141 | `game_inventory/inventory.lua` (`StackingMoney`) | **none found** | "Stack money" button | C→S: `1`. **No server handler.** |
| 199 | `game_house/house.lua` | `creaturescripts/scripts/look.lua` | House info window (look at a house door) | S→C: `"house_data|name|owner|town|size|price"`. Actions are C→S obfuscated talk words (see below). |
| 200 | `game_houseowner/houseowner.lua` | **no sender found** in server Lua | House owner panel | S→C: same `house_data|...` format expected. **No server sender.** |
| 201 | `game_housebuy/housebuy.lua` | `creaturescripts/scripts/look.lua` | House buy window | S→C: `house_data|...` |
| 202 | `game_houseownerenter/houseownerenter.lua` | `creaturescripts/scripts/look.lua` | House panel shown to the owner when entering | S→C: `house_data|...` |

### Mismatches and dead channels

- **Server sends with no client handler:** 81 and 85 (ambient sound).
- **Client sends with no server handler:** 1 (locale; the server has no Lua handler) and 141 (stack money).
- **Client handler with no server sender found:** 200 (house owner).
- **Defined but unused:** 3–7 and 65.
- `opcode.lua` handles 41, 61, 62, 63, 64 and 103. `login.lua` also registers an `onShop` event whose XML line is commented out in `creaturescripts.xml`, so that registration does nothing.

## PSoul binary sub-protocol (server → client, opcode `0xFF`)

Defined in `client/source/src/client/protocolcodes.h` (`GameServerPSoulOpcodes`). The client parses these in `protocolgameparse.cpp` and the server builds them in `server/source/protocolgame.cpp`. Each one is forwarded to a Lua global `g_game.<callback>`.

| Sub-opcode | Name | Server C++ sender | Client Lua callback | Client module |
|---|---|---|---|---|
| 1 | MoveBarUpdate | `sendPokemonSkills` | `g_game.onPokemonMoves(iconItemId, moves)` | `game_pokemoves` |
| 2 | MoveBarClose | `sendPokemonSkillContainerClose` | `onMoveBarClose` | **no Lua listener found** |
| 3 | MoveBarOpen | `sendPokemonSkillContainerOpen` | `onMoveBarOpen` and `onPokemonBarOpen` | `game_pokebar` (only `onPokemonBarOpen` has a listener) |
| 4 | PokemonBarAdd | `sendPokemonWindowAddPokemonIcon` | `onPokemonBarAdd(itemId, fastcallNumber, textColor, text, level, maxMana, mana, gender, ...)` | `game_pokebar` |
| 5 | PokemonBarRemove | `sendPokemonWindowRemovePokemonIcon` | `onPokemonBarRemove(fastcallNumber)` | `game_pokebar` |
| 6 | PokemonBarUpdate | `sendPokemonWindowUpdatePokemonIcon` | `onPokemonBarUpdate(...)` | `game_pokebar` |
| 7 | PokemonBarOpen | `sendPokemonWindowOpen` | `onPokemonBarOpen` | `game_pokebar` |
| 8 | PokemonBarClose | `sendPokemonWindowClose` | `onPokemonBarClose` | `game_pokebar` |
| 9 | MoveCooldown | `sendPokemonSkillCooldown` | `onPokemonMoveCooldown(itemId, cooldown)` | `game_pokemoves` |
| 10 | PokedexStatus | `sendPokedexStatus` | `onPokedexStatus(status)` | `game_pokedex` |
| 11 | PokedexOpen | `sendPokedexOpen` | `onPokedexOpen` | `game_pokedex` |
| 12 | PokedexUpdate | `sendPokedexItemUpdate` | `onPokedexUpdate(number, status)` | `game_pokedex` |
| 13 | TmChoose | `sendTmWindow` | `onTmChoose(tmMoveItemId, moves)` | `game_tmchoose` |
| 14 | StatusBarAdd | `sendPokemonStatusAdd` | `onStatusBarAdd(itemId, cooldown)` | `game_statusbar` |
| 15 | StatusBarRemove | `sendPokemonStatusRemove` | `onStatusBarRemove(itemId)` | `game_statusbar` |
| 16 | StatusBarClear | `sendPokemonStatusClear` | `onStatusBarClear` | `game_statusbar` |
| 17 | PokedexInfo | `sendPokedexInfo` | `onPokedexInfo(id, details, moves, effectiveness, families)` | `game_pokedex` |
| 18 | CreatureJump | `sendCreatureJump` | C++ creature jump animation | — |
| 19 | CreatureEffect | (C++) | `creature:onEffect(effectId, var)` | `game_effects` |
| 20 | DollCaseStatus | `sendDollCaseStatus` | `onDollCaseStatus(status)` | `game_dollcase` |
| 21 | DollCaseUpdate | `sendDollCaseUpdate` | `onDollCaseUpdate(number, status)` | `game_dollcase` |
| 22 | SlotMachine | `sendSlotMachine` | `onSlotMachine(r1, r2, r3)` | `game_slotmachine` |
| 23 | Tip | `sendTip` | `onTip(id)` | `game_tips` |
| 24 | PollWindow | `sendPollWindow` | `onPollWindow(name, textMode or options)` | `game_poll` |
| 25 | PokemonLevelUp | `sendPokemonLevelUp` | `onPokemonLevelUp(number, newLevel, newMoves)` | `game_advanceeffect` |
| 26 | LootList | `sendLootList` | `onLootList(list)` | `game_lootlist` |

Client→server custom raw opcodes: `0xFA` (`ClientRequestPollWindow`, server `parseRequestPollWindow`) and `0xFB` (poll vote, `parsePollVote`). The server has stubs for the Tibia 9.44 market opcodes `0xF4`–`0xF8`, but they are commented out.

## Talkaction pseudo-protocol (client → server via chat)

Many custom UIs send commands as hidden chat messages (`g_game.talk(...)`) that the server handles with talkactions in `server/runtime-data/data/talkactions/`.

| Client module | Words sent | Purpose |
|---|---|---|
| `game_shop` (`roupas.lua`, `decoracoes.lua`, `addons.lua`, `mercado.lua`) | `/shoppokecoin <...>`, `/shopdiamond <...>` | Buy shop items with Poké Coins or Diamonds |
| `game_shop/shop.lua` | `/namepokecoin`, `/namediamond` | Character name change paid with Poké Coins or Diamonds |
| `game_shop/clas.lua` | `/BuyMasteryRank <...>` | Buy a mastery or clan rank |
| `game_pass/pass.lua` | `/SendPass35`, `/SendPass50` | Battle pass purchase confirmation |
| `game_task/task.lua` | `/task`, `/parseRank`, `/buyrank`, `/showtaskrank` | Task module |
| `game_interface/gameinterface.lua` | `/dpconfig` | Depot configuration |
| `game_house*` modules | `buyhouseewqnml`, `abandonarweqn`, `subdonoeqwxv`, `hospedeseeq`, `chutarrrase`, `portassdawt`, `showbuywindowhouse` | House buy, abandon, sub-owner, guests, kick, doors (deliberately obfuscated words) |

These are not authenticated beyond the normal game session. The server must validate every parameter itself.
