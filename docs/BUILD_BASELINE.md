# Build Baseline (Phase 2)

PokeVerse builds from source on Linux. The pipeline is **source → build → `dist/` → test**. The original Windows binaries in `original/binaries/` are reference material only. They are not run or used as evidence (see `ORIGINAL_BINARY_INVENTORY.md`).

The CI workflow `.github/workflows/validate.yml` repeats every step below on `ubuntu-24.04`.

## Toolchain (verified)

| Item | Version used |
|---|---|
| OS | Ubuntu 24.04 (x86_64) |
| Compiler | GCC 13.3 (`CC=gcc CXX=g++`; the scripts set this) |
| CMake | 3.28 |
| Boost | 1.83 (server: system, filesystem, thread, regex) |
| Lua | 5.1 (`liblua5.1-0-dev`). LuaJIT is not used. |
| Database client | libmariadb 3.x (`libmariadb-dev`, plus `libmariadb-dev-compat` for `<mysql/mysql.h>`) |
| Database server | MariaDB 10.11 |
| OpenSSL | 3.0 |
| Client libraries | PhysFS, zlib, GLEW + OpenGL (Mesa is fine), OpenAL, Ogg/Vorbis |

To install everything:

```bash
sudo apt-get install -y build-essential cmake pkg-config \
  libboost-system-dev libboost-filesystem-dev libboost-thread-dev libboost-regex-dev \
  libxml2-dev libssl-dev liblua5.1-0-dev lua5.1 libmariadb-dev libmariadb-dev-compat libsqlite3-dev libgmp-dev \
  libphysfs-dev zlib1g-dev libglew-dev libgl1-mesa-dev libopenal-dev libvorbis-dev libogg-dev \
  mariadb-server
```

## Commands

```bash
git lfs pull                 # Tibia.spr is an LFS object; the client cannot draw without it
tools/build_server.sh        # build/server  -> dist/server/pokeverse-server
tools/build_client.sh        # build/client  -> dist/client/pokeverse-client + libotc_framework.so
tools/setup_dev_db.sh        # DEVELOPMENT ONLY: database `pokeverse` + migrations + dev accounts
tools/run_server.sh          # runs dist/server/pokeverse-server from server/runtime-data
(cd dist/client && ./pokeverse-client)
```

- **Output layout.** `build/` and `dist/` are git-ignored.
  - `dist/client/data`, `modules` and `init.lua` are symlinks into `client/runtime-data`.
  - `COPY_DATA=1 tools/build_client.sh` copies them instead.
  - The client binary has rpath `$ORIGIN`, so it finds `libotc_framework.so` next to itself.
- **Tests.**
  - `tools/validate.py` runs the static checks.
  - `tools/smoke_server.sh` is the startup smoke test.
  - `tools/smoke_login.sh` is the end-to-end login test. It needs an X display; use Xvfb in CI.

## Server: source changes needed to build

These are minimal fixes for APIs removed since Boost 1.40 and MinGW GCC 3/4, plus two memory-safety fixes. Gameplay code is unchanged.

| File | Change | Why |
|---|---|---|
| `server/source/CMakeLists.txt` | New CMake build (the original builds used Dev-C++ / Code::Blocks / unmaintained autotools) | Linux build |
| `house.h` | `boost/tr1/unordered_set` → `<unordered_set>` | TR1 was removed from Boost |
| `luascript.cpp`, `scriptmanager.cpp` | `it->leaf()` → `it->path().filename().string()` | Boost.Filesystem v3 API |
| `connection.h` | Anonymous enums → `static const int32_t` timeouts | Ambiguous with modern Boost.Asio overloads |
| `chat.cpp` | `return false` → `return NULL` in a pointer function | Invalid C++ under GCC 13 |
| `protocolgame.cpp` | `<< hex` → `<< hex.str()` | Streams no longer convert to `void*` |
| `talkaction.cpp` | Array initialization rewritten as a loop | Invalid initializer (MinGW accepted it) |
| `game.h` | `globalSaveMessage[2]` → `[3]` | Index 2 was written: out-of-bounds write |
| `player.cpp` | Loop `i <= 13` → `i < 13` over `talkState[13]` | Out-of-bounds write |
| `databasemysql.cpp` | `MYSQL_SET_CHARSET_NAME latin1` before connect | Data and scripts are Latin-1; utf8mb4 defaults rejected the MOTD insert |
| `protocollogin.cpp` | 0xFC/0xFD account-creation opcodes compiled only with `__ACCOUNT_CREATION__` | Security (see `SECURITY_AUDIT.md`) |

## Client: source changes needed to build and run

| File | Change | Why |
|---|---|---|
| `framework/CMakeLists.txt`, `client/CMakeLists.txt`, `game.cpp` | `LEGACY_UPDATER` option (default OFF) gates the WinINet updater (`download.cpp`). When it is off, the updater reports "up to date, 0 files". | The updater is Windows-only, and disabled by policy |
| `CMakeLists.txt`, `main.cpp` | `CLIENT_ENCRYPTION` option (default OFF) around `getKey()` | The imported data is plaintext. The key from the `info` file would XOR it into garbage. |
| `framework/global.h` | `IsDebuggerPresent()` stub on non-Windows | Windows API |
| `platform/unixcrashhandler.cpp` | `#include <csignal>` | Missing include |
| `util/crypt.cpp` | OpenSSL 1.1+ `RSA_set0_*` / `RSA_generate_key_ex` | Opaque RSA struct in OpenSSL 3 |
| `stdext/shared_object.h` | SFINAE on pointer convertibility | GCC 13 rejected an incomplete-type check |
| `graphics/apngloader.cpp` | Pass `z_stream` by reference | zlib ≥ 1.2.9 rejects copied streams. Every PNG decoded as noise. |
| `sound/soundmanager.cpp` | Skip preload/play when there is no audio device | Assertion crash on headless or audio-less machines |
| `core/resourcemanager.cpp/.h` | `resolvePathCase()` falls back to a case-insensitive per-component lookup on non-Windows | Module and asset paths were authored on case-insensitive Windows |

Client build flags (in `tools/build_client.sh`): `-DLUAJIT=OFF -DUSE_STATIC_LIBS=OFF -DCMAKE_BUILD_WITH_INSTALL_RPATH=ON -DCMAKE_INSTALL_RPATH='$ORIGIN'`.

## Runtime data changes needed on Linux

- **Spell scripts directory.** Added the empty directory `server/runtime-data/data/spells/scripts/` (with a `.gitkeep`). Spell paths are written as `scripts/../../lib/...`, and POSIX path resolution requires `scripts/` to exist. Without it, 484 scripts failed to load.
- **Database settings.** `config.lua` points at the development database: `pokeverse`, user `pokeverse`, password `pokeverse-dev`. These are local development values only. The original `root`/no-password settings were removed.

## Known build warnings and limits

- Both builds emit many compiler warnings from the 2010-era code (deprecated declarations, sign comparisons). None are errors.
- **Windows builds are not maintained.**
  - The old Dev-C++ and VS2013 projects are kept for reference but untested.
  - A Windows build would need `LEGACY_UPDATER` left OFF unless the updater is reviewed first.
- The server prints `WARNING: Outdated MySQL server detected`. TFS 0.3.6 compares libmariadb's 3.x client version number, so this is harmless (see `SERVER_STARTUP_REPORT.md`).
