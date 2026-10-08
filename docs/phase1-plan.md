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
| Copy sources into `core/` | Done |
| Build server from source | Done: Linux (GCC 13, Boost 1.83) and Windows (MSYS2 MinGW-w64, GCC 15, Boost 1.92) |
| Build legacy client from source | Done: Linux and Windows |
| Local database setup and accounts | Done: `core/database/`, reconstructed PSoul tables |
| Windows package and `.bat` files | Done: `PokeVerse-Windows-Dev` CI artifact, see [windows-dev-package.md](windows-dev-package.md) |
| PSoul to PokeVerse rename, English backend | Done (see notes below) |
| Verify login, character creation, in-game movement | Done: protocol tests against the extracted package on a clean Windows runner and on Linux; real client by hand on Linux (login, character list, in game, walking, saved position) |

## What was changed to build with current toolchains

- **Boost.Asio:** `io_service` to `io_context`, `post`/`dispatch` free functions,
  `make_address_v4`, `to_uint`, resolver results instead of `query`/`iterator`,
  `steady_timer` instead of `deadline_timer` (no longer in Boost 1.92's `asio.hpp`).
- **OpenSSL 1.1/3 (client):** the RSA key is set through `RSA_set0_*`/`RSA_get0_*` and
  cipher contexts come from `EVP_CIPHER_CTX_new`, instead of reading struct internals.
- **Compiler fixes:** removed `std::tr1`, explicit casts for timer durations, an array
  initializer in `talkaction.cpp`, `NULL` instead of `false` for a pointer return, a
  misnamed `getLength()` call in `point.h` (GCC 15 checks template bodies), and the
  `UILayout` constructor moved out of line.
- **Runtime fixes:** APNG decoding passes its `z_stream` by reference (modern zlib
  rejects copies, which made animated images blank); a negative jump-animation delay is
  clamped to 0.
- **Client assets:** the source decrypts `.lua/.png/.otui/.spr/.dat` files with a built-in
  AES key, but the shipped data is plain text. Decryption is now behind the CMake option
  `ENCRYPTED_ASSETS` (default `OFF`).
- **Server includes:** MariaDB headers come from the pkg-config include path
  (`__MYSQL_ALT_INCLUDE__`).

## Rename and English standardization

- Player-facing texts, identifiers (`GameServerPokeVerse*` protocol enums), app name,
  executables (`pokeverse-server`, `pokeverse-client`), the database (`pokeverse`) and
  the matching `pt_br.loc` translation keys say PokeVerse.
- Kept on purpose: the anniversary-event items "PSoul letter P/S/O/U/L", "PSoul token" and
  "PSoul backpack" (their sprites spell the old name and the event matches on the names);
  "Deepsoul Stone" (an in-game item); the Portuguese command aliases `/cupom`,
  `/comando`, `/comandos` (English aliases already exist).
- File, folder and command names were already English. Remaining Portuguese code
  comments were translated. Portuguese/Spanish player texts and translations are kept.

## Known issues (existing, not fixed in Phase 1)

- **Real Windows client GUI not yet driven end to end in CI.** GitHub's Windows runners
  have no GPU driver. The shipped client exits there (heap corruption, `0xC0000374`) right
  after reporting a 1024x1024 texture limit, i.e. on Windows' built-in OpenGL 1.1 fallback.
  With Mesa software OpenGL it starts and stays running, but the keyboard-driven login
  could not be confirmed on the runner. The same client source logs in and walks on Linux.
  Needs a check on a real Windows PC with a graphics driver.

- The NPC Soya references a missing `loot.lua` (Soya is not placed on the map).
- Tournaments 2 and 3 are commented out in XML, but `tournament.lua` still queries them
  ("Npc interface" errors in the server log).
- The server prints "Outdated MySQL server detected"; it is only a version-string check.
- `duelMessage.otui` and `lootList.otui` are referenced with different capitalisation
  than the files; this only fails on case-sensitive file systems (Linux), not Windows.
- Some in-game texts and buttons still link to the old websites (psoul.net, pokenordic);
  a PokeVerse website is out of scope for Phase 1.
- The PokeVerse table extensions (`pokeverse-extensions.sql`) and the starting kit for new
  characters were reconstructed from the server source, because the archive has no
  game database dump.

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
