# Architecture

PokeVerse currently **is** the PokeJornadas codebase, reorganized but otherwise unchanged. This document describes that codebase as it was imported.

## Lineage

```
OpenTibia → The Forgotten Server 0.3.6 "Crying Damson" (2009/2010, GPLv3)
          → PSoul / PokeCenter custom engine ("PS.exe", Brazilian PokeTibia scene)
          → PokeJornadas (2021, custom UI and systems)
          → PokeVerse (this repository)

edubart/otclient 0.6.6 (MIT)
          → PSoul/PokeCenter OTClient fork (app name "Pokecenter", PSoul protocol extensions)
          → PokeJornadas client (custom UI modules, built-in updater, asset encryption)
```

Branding found in the code: **PokeCenter** (`config.lua` `ownerName`, client app name, NPC text), **PSoul** (`resources.h` outdated-client message, `psoul.net`), **PokeJornadas** (`client/init.lua` error message), **Nordic SOUL** (`settings.sav` path), and the database name **poketibia** / **pokeaventuras**.

## Components

```
            ┌──────────────────────────── client/ (Windows, OTClient 0.6.6 fork) ───────────────────────────┐
            │ otclient.exe (x86, gcc 4.8.1, OpenGL ES 2 via ANGLE: libEGL/libGLESv2, d3dx9_43)               │
            │ init.lua → modules/ (69 Lua/OTUI modules) + data/ (things, images, sounds, styles, fonts)      │
            └───────────────┬───────────────────────────────────────────────────────────────┬──────────────┘
                            │ Tibia 8.6-style protocol (XTEA/RSA)                           │ HTTP (updater)
                            │ + ExtendedOpcode 0x32 (JSON / Lua-table / marker strings)     ▼
                            │ + PSoul sub-protocol 0xFF                               update web server
                            │ + hidden talkactions                                    (not included)
            ┌───────────────▼────────── server/ (Windows, TFS 0.3.6 fork, PS.exe) ───────────────────────┐
            │ C++ engine (server-src/)  ── Lua 5.1 scripting ── data/ (lib/ps systems, XML, map)        │
            └───────────────┬────────────────────────────────────────────────────────────────────────────┘
                            │ MySQL (libmysql) or SQLite
            ┌───────────────▼───────────────┐            ┌─────────────────────────────────────────────┐
            │ database/ MariaDB 10.4 dump    │◀──────────│ website (Znote AAC + blog + PayPal/PayGol)   │
            │ 141 tables                     │           │ NOT INCLUDED in the package (tables only)    │
            └────────────────────────────────┘            └─────────────────────────────────────────────┘
```

## Server

| Item | Finding |
|---|---|
| Engine | The Forgotten Server **0.3.6 "Crying Damson"** (`server-src/doc/README`, `doc/CHANGELOG`), heavily customized |
| Protocol | Tibia 8.6-era layout. `CLIENT_VERSION_MIN 312` / `MAX 1343` (custom numbering, `resources.h`). The version check in `ProtocolGame::login` is commented out. |
| Language / build | C++03/early C++11. **Dev-C++ / MinGW** (`dev-cpp/Makefile.win`, `TheForgottenServer.dev`, `project/PO.dev`), plus Code::Blocks project (`TheForgottenServer.cbp`) and autotools (`configure.ac`, `Makefile.am`, `autogen.sh`) |
| Defines | `__USE_MYSQL__ __USE_SQLITE__ __ENABLE_SERVER_DIAGNOSTIC__ __EXCEPTION_TRACER__ __EMERGENCY_SAVE__ __CONSOLE__` |
| Libraries | boost (system, regex, filesystem, thread; `make gcc fixes boost 140/` patches suggest **Boost 1.40**), GMP, **Lua 5.1**, libmysql, SQLite3, libxml2, OpenSSL (libeay32), ws2_32 |
| Output | `PS.exe` (x86 Windows console). The shipped binary is identical to `server-src/dev-cpp/PS.exe`. |
| Custom C++ (non-stock TFS) | `partyduel.*` (duels), `pvparena.*`, `tournament.*` + `iotournament.*`, `polls.*` + `iopoll.*`, `localization.*` (multi-language, `pt_br.loc`), `iodatalog.*` (datalog tables), `ioplayerstatistics.*`, Pokémon-specific Lua functions in `luascript.cpp` (13k+ lines), PSoul sub-protocol senders in `protocolgame.cpp`, dash walking, OTClient ExtendedOpcode support |
| Database | MySQL/MariaDB (`sqlType = "mysql"`, `sqlDatabase = "pokeaventuras"`). The dump's internal name is `poketibia`. |
| Ports | login/admin/status `7564`, game `8548` (`config.lua`) |

### Server data layout (`server/data/`)

| Folder | Content |
|---|---|
| `lib/` | Load order `000-` to `999-`. Stock TFS libs plus custom `game_*.lua` (calendar, craft, dungeon, market, pass, pokemonInfo, work), daily kill/catch, depot locker, ambient sound, achievements, professions, notifications, `json.lua` |
| `lib/ps/` | **Core PSoul framework (1,824 files)**: `config/` (434 per-Pokémon configs, 456 move configs, balls, storages, quests 460 KB), `systems/` (55 numbered systems), `functions/` (player, pokemon, abilities, ball states), `events/` (actions, creaturescripts, globalevents, movements, spells, talkactions), `profission/`, `others/` (constants, logger, outfits), `tools/` (loot generator, catch test, balance calculator) |
| `monster/` | 1,176 XML files (`Pokemons/`, shinies, bosses, event monsters) |
| `npc/` | 1,282 files (NPC XML + `scripts/` + `lib/npcsystem`, Frontier Island, wave arena) |
| `actions/ movements/ talkactions/ creaturescripts/ globalevents/ spells/ weapons/ raids/` | Standard TFS event folders, mostly thin XML wrappers that point into `lib/ps/events/` |
| `items/` | `items.otb`, `items.xml`, `randomization.xml` |
| `world/` | `map.otbm` (49.9 MiB), `map-house.xml`, `map-spawn.xml`, `map-sound.xml` (+ generated `.lua`) |
| `XML/` | `groups`, `vocations`, `outfits`, `quests`, `stages`, `channels`, `tournaments`, `servers`, `admin`, `CreateAcc` |

The PSoul systems layer (`lib/ps/systems/0NN-*.lua`) is the core of the gameplay. See `FEATURES.md`.

## Client

| Item | Finding |
|---|---|
| Base | **edubart/otclient 0.6.6** (`client-src/CMakeLists.txt`, crash report `app version: 0.6.6`) |
| App name | `Pokecenter` (crash report) |
| Binary | `otclient.exe` x86, gcc 4.8.1, built Oct 1 2021 (crash report), OpenGL ES 2.0 through ANGLE (`libEGL.dll`, `libGLESv2.dll`, `d3dx9_43.dll`) |
| Lua | 5.1 (`lua5.1.dll`) |
| Custom C++ | Built-in updater (`client/download.cpp`, `Game::Updater*`, `framework/net/protocolhttp.*`), PSoul `0xFF` sub-protocol parser, `.spr`/`.dat` decryption (`decryptSPR`/`decryptDAT`), custom health/exp bar (`creature.cpp` loads `data/images/new_bar.png`), `uisprite`, `uiprogressrect`, poll window opcodes |
| Source completeness | `client-src/` contains `src/framework`, `src/client`, `src/main.cpp`, CMake and VS2013 (`vc12/`) projects. Every file referenced by CMake is present except the optional `graphics/dx/painterdx9.*` (DirectX option is off by default). Not included: third-party dependencies, `LICENSE`/`README`/`AUTHORS`, `otclientrc.lua`. |
| Assets | `data/things/Tibia.dat` + `Tibia.spr` (262 MB) + `Tibia.otml`/`Tibia.otfi` (extended, transparency), 1,879 images, 472 OGG sounds, 30 fonts, 28 shaders, 60 particles |
| Modules | 69 directories (plus an IDE `.project/` folder). See `CLIENT_UI.md` / `UI_AUDIT.md`. |

### Client load order (`client/init.lua`)

1. Anti-tamper file check (aborts on injector artifacts).
2. Add `data/` and `modules/` to search paths, load `*.otpkg`, `config.otml`.
3. Autoload modules: libraries (0–99: `corelib`, `gamelib`) → client (100–499: `client`, entergame, options, …) → game (500–999: `game_interface` and all `game_*`) → mods (1000–9999).

## Updater

- **In-client updater:** `client/modules/game_updater` and C++ `Game::UpdaterXmlClient/UpdaterVerificClient/UpdaterClient`. It downloads `data/hash.xml` and changed files over HTTP from `http://localhost/otclient/`.
- **Hash generator:** `tools/updater-hash/Tools/Release/Hash.exe` (binary only, no source). It produces `hash.xml` (`<hashings><hashing name="…" hash="MD5"/>`).
- The server-side update host is not included.

## Website

**Not included.** The SQL dump contains tables for **Znote AAC** (`znote_*`), a blog (`blog_posts`, `blog_post_*`), tickets, PayPal IPN (`instant_payment_notifications`, `paypal_items`), PayGol, `donates` and `coupons`. The server also has a Gesior shop delivery script (`gesior-shop-system.lua`). The tables it needs are missing from the dump.

## Design assets

The original package's `PSDS/` folder (36 design files, 2.6 GB, **not kept in this repository**) holds: the source art for the new interface, battle pass ("PASSE DO TREINADOR"), shop ("LOJA"), market, dungeons, professions, depot lock, Pokémon status, Pokédex, entergame, houses ("CASA"), portraits and more.
