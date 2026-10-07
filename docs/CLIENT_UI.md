# Client UI

The client is an OTClient 0.6.6 fork (app name "Pokecenter") with 69 Lua/OTUI modules in `client/modules/`. This document describes how the interface is put together and what makes the PokeJornadas UI different from stock OTClient. The status of each UI is tracked in [UI_AUDIT.md](UI_AUDIT.md).

## Loading

- `client/init.lua` runs an anti-tamper check, sets up resources and loads the `client*` modules plus `corelib` and `gamelib`.
- `game_interface/interface.otmod` loads 53 game modules through `load-later` (54 entries, because `game_market` is listed twice).
- `game_bottommenu`, `game_craft`, `game_depotlock`, `game_guide`, `game_house*`, `game_market`, `game_pokekill` and `game_updater` also set `autoload: true`.
- **Not loaded by anything:** `client_serverlist`, `game_console` (replaced by `game_chat`), `game_environment` (ambient sound).

## What makes the PokeJornadas UI distinctive

| Element | Module / files | Notes |
|---|---|---|
| **Bottom menu bar** | `game_bottommenu` (7 images) | Replaces the stock side panels with a bar of buttons: Pokémon IVs, combat controls, addons, Pokébar, health info, minimap, party, battle and more. |
| **Top-menu icon buttons** | `client_topmenu`, `data/images/topbuttons` (38 icons) | Icon set replacing the stock text buttons. |
| **Custom health bars** | `data/images/new_bar.png`, C++ `UIProgressRect`, creature drawing | Image-based HP bars instead of the stock flat bars. |
| **Pokébar** | `game_pokebar` (35 images) | Party bar fed by PSoul raw opcode 0xFF (sub-opcodes 3–8): icons, level, HP, gender, fast-call number. |
| **Move bar** | `game_pokemoves` | Move icons and cooldowns (sub-opcodes 1, 9). |
| **Pokémon info window** | `game_pokemonInfo` (100 images) | Stats, nature, IVs/EVs, base upgrades, friendship and resets. JSON on opcode 63. |
| **Battle pass** | `game_pass` (102 images) | Two reward tracks over 50 levels. Design source: `PASSE DO TREINADOR.psd`. |
| **Daily calendar** | `game_calendar` (66 images) | Month grid with rewards and a point shop. |
| **Dungeon browser** | `game_dungeon` (66 images, 5 OTUI files) | Difficulty and map selection, team creation, queue, ranking. |
| **Game shop** | `game_shop` (8 Lua, 7 OTUI, **2,455 images**, 23.6 MB) | The largest module. Product art for every item. Design source: `LOJA.psd`. |
| **Market** | `game_market` (37 images, 5 OTUI files) | Search, sort, buy, sell and offers. Design source: `MARKET.psd`. |
| **Craft** | `game_craft` (38 images) | Profession ranks and recipes. |
| **Task window** | `game_task` (74 images) | Kill-task list and ranks. |
| **Animated notifications** | `game_notifications` (33 images, 3 OTUI files) | Broadcast banners and catch popups (JSON on opcode 25). |
| **Login / character screens** | `client_entergame` (22 images), `client_background` (25 images), `poke_create` (12 images) | Custom background art, in-client account creation with a starter-Pokémon choice. |
| **Day/night clock** | `game_time` (6 images) | Shows world time with day/night icons. |
| **Depot lock** | `game_depotlock` (41 images, 7 OTUI files) | Password lock for the depot. |
| **Pokédex, doll case, badge case, trainer cards** | `game_pokedex`, `game_dollcase`, `game_badgecase`, `data/images/trainerCards` | Collection windows. |
| **Fonts** | `data/fonts/damas.otfont`, `damage-font.otfont` | Custom title font and damage numbers. |
| **Asset encryption** | C++ `decryptSPR` / `decryptDAT` | `Tibia.spr` (169,214 sprites) and `Tibia.dat` are encrypted. The client source can decrypt them. |
| **Design sources** | `assets/design-psd/` (Git LFS) | NEW INTERFACE, PASSE DO TREINADOR, LOJA, POKE STATUS, MARKET and others. See `assets/README.md`. |

## Client-side C++ additions that the UI depends on

- `UISprite` and `UIProgressRect` widgets.
- PSoul raw-opcode parser (0xFF) feeding `g_game.onPokemon*`, `onPokedex*`, `onStatusBar*`, `onDollCase*` and other callbacks.
- WinINet HTTP updater (`g_game.getUpdateProgress`, `getProgressFiles`) used by `game_updater`.
- Custom login packets (`0xFC`/`0xFD`) used by `poke_create`.

## Known UI problems

- Five modules (`game_market`, `game_craft`, `game_pass`, `game_calendar`, `game_task`) run server data with `loadstring` (SECURITY_AUDIT finding 1).
- `game_notifications` loads images from `/images/game/pokes/`, which does not exist.
- `game_duelmessage` calls `g_ui.loadUI('duelMessage')` and `game_lootlist` calls `g_ui.loadUI('lootList')`, but the files are `duelmessage.otui` and `lootlist.otui`. This works on Windows and breaks on case-sensitive filesystems (Linux builds).
- Server features with **no UI**: held items, evolution, abilities, achievements, auctions (PokéTrader), Pokémon storage (no PC), Pokémon Center.
- The client never handles ambient-sound opcodes 81/85, and the "stack money" button (opcode 141) has no server handler.
- `game_houseowner` (opcode 200) never receives data from the server.
