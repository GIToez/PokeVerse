# Phase 1 — Foundation setup

**Goal:** the Windows development environment in `builds/dev/` can be downloaded, set
up, launched and played locally using simple batch files. No new gameplay features;
no removal of existing working features.

## Status

| Step | Status |
| --- | --- |
| Folder structure | Done |
| Import original project into `references/` | Done |
| Initial source audit | Done (below) |
| Copy sources into `core/` | Not started |
| English standardization | Not started |
| Build server from source (Windows) | Not started |
| Build legacy client from source (Windows) | Not started |
| Local database setup and accounts | Not started |
| `setup.bat`, `start-server.bat`, `start-client.bat` | Not started |
| Verify login, character creation, in-game movement | Not started |

## Initial audit of `references/Projeto/`

### Server — `PSOUL/`

- Based on The Forgotten Server 0.x (C++), customised for PSoul (tournaments, market,
  polls, duels, player statistics, localization).
- Prebuilt 32-bit Windows binary `PS.exe` with its runtime DLLs (MinGW, Lua 5.1,
  libxml2, MySQL, SQLite, GMP, OpenSSL).
- Source in `PSOUL/Source Server/`. Built with Dev-C++ 4.9.9.2 (MinGW, 32-bit) via
  `dev-cpp/Makefile.win`. Dependencies: Boost (system, regex, filesystem, thread), GMP,
  Lua 5.1, libxml2, MySQL client, SQLite3, OpenSSL (libeay32). Also has autotools files
  (`configure.ac`, `autogen.sh`) for Linux.
- `config.lua` already binds to `127.0.0.1`. Ports: login 7564, game 8548, status 7190.
  Database: MySQL, database name `genesis`, password hashing `sha256`.
- Player-facing translation: `pt_br.loc`.

### Legacy client — `Client/` and `Sources/Source client/`

- Based on OTClient 3.1.2 (C++ with Lua modules).
- Prebuilt 32-bit Windows binary `Client/Poke Aimar.exe` with DirectX/ANGLE DLLs.
- Assets in `Client/data/` (`things/data.spr` is 308 MB) and many custom PSoul modules
  in `Client/modules/` (pokedex, pokebar, market, tournaments, and more).
- Source in `Sources/Source client/`: CMake project plus a Visual Studio 2013
  (`vc12/`) solution.

### Map editor and design documents — `RME - PSoul/`

- Remere's Map Editor (binary and source) configured for PSoul.
- Game-design documents in Portuguese (balance sheets, move lists, tier lists, PvP).

## Known blockers and risks

1. **No game database dump.** The archive only has the generic TFS schemas
   (`Source Server/schemas/mysql.sql`, `sqlite.sql`, `pgsql.sql`). PSoul adds custom
   tables (market, tournaments, polls, statistics), so the schema must be reconstructed
   from the server source before accounts and characters can be created.
2. **Old toolchains.** The server targets Dev-C++ 4.9.9.2 / old MinGW and old Boost;
   the client targets Visual Studio 2013. Modern compilers will likely need source
   fixes; behaviour and protocol must stay the same.
3. **Client source vs. shipped client.** It must be confirmed that
   `Sources/Source client/` matches the features of the shipped `Poke Aimar.exe`
   and its Lua modules.
4. **Translation scope.** Much of the backend (Lua scripts, comments, XML) is in
   Portuguese. Renaming must update every reference without touching the database
   schema, protocol or player-facing translations.
