# Build Status

**Nothing has been built or run yet.** This document lists what build inputs exist and what is missing, based only on reading the files.

| Component | Source | Build system(s) | Toolchain implied | Third-party deps shipped? | Status |
|---|---|---|---|---|---|
| Server (`server/source/`) | Yes, complete per `dev-cpp/Makefile.win` (all 90 `.cpp` and 100 `.h` present) | Dev-C++ (`dev-cpp/*.dev`, `Makefile.win`), second Dev-C++ project (`project/PO.dev`), Code::Blocks (`dev-cpp/TheForgottenServer.cbp`), autotools (`configure.ac`, `Makefile.am`, `autogen.sh`, `debianfix.sh`) | MinGW gcc (3.4–4.x era) from "Stian's Repack Dev-Cpp v2", Win32 | **No** (libraries expected under `C:/Users/walox/Downloads/Stian's Repack Dev-Cpp v2/lib`, `C:/OpenSSL-Win32/lib/MinGW`) | **Unknown / not built.** A prebuilt `PS.exe` exists (identical to `original/binaries/server-source/dev-cpp/PS.exe`). |
| Client (`client/source/`) | Yes. All CMake-referenced files present except optional DX9 painter (off by default) | CMake 2.6+ (`CMakeLists.txt`, `src/framework/cmake/*.cmake`), Visual Studio 2013 (`vc12/otclient.sln`) | gcc 4.8.1 MinGW (crash report) or MSVC 2013; OpenGL ES 2 + EGL (ANGLE) | **No** | **Unknown / not built.** A prebuilt `otclient.exe` exists. |
| Hash tool (`tools/updater-hash/`) | **No source** | — | MinGW (`libgcc_s_dw2-1`, `libstdc++-6`, `libphysfs`, `LIBEAY32`) | **No** (its DLLs are not included either) | **Binary only, not runnable as shipped.** |
| Database (`database/`) | SQL dump | — | MariaDB 10.4.11 / phpMyAdmin 5.0.1 (dump header) | — | Importable in principle. **Several tables used by scripts are missing.** See `DATABASE.md`. |
| Website | **Not included** | — | Znote AAC (PHP) implied by tables | — | Missing |

## Server build inputs

- Libraries (from `Makefile.win` `LIBS`): `boost_system`, `boost_regex`, `boost_filesystem`, `boost_thread`, `gmp`, `lua5.1`, `mysql`, `sqlite3`, `xml2`, `eay32` (OpenSSL 0.9.8/1.0), `wsock32`, `ws2_32`.
- `make gcc fixes boost 140/` (`libstdcpp3.hpp`, `xtime.hpp`) shows the code targeted **Boost 1.40** with old MinGW. Modern Boost and compilers will need source fixes.
- Runtime DLLs shipped with the server package: `lua5.1.dll`, `libmysql.dll`, `mysql.dll` (LuaSQL), `sqlite3.dll`, `libxml2.dll`, `libxml2-2.dll`, `libiconv-2.dll`, `iconv.dll`, `zlib1.dll`, `libeay32.dll`.
- Leftover object files (`*.o`) are in the source root and `dev-cpp/obj/`. They are excluded from Git.
- The autotools files are the stock TFS 0.3.6 ones and probably were not maintained for the custom sources.

## Client build inputs

- CMake options: `FRAMEWORK_SOUND`, `FRAMEWORK_GRAPHICS`, `FRAMEWORK_XML`, `FRAMEWORK_NET` (all ON), `FRAMEWORK_SQL` OFF, `USE_STATIC_LIBS`, `OPENGLES` (`2.0` matches the shipped binary), `ENCRYPTIONKEY_NUMERIC_FIRST/SECOND/THIRD` (asset encryption keys; defaults 255/0/255).
- Expected deps (stock OTClient 0.6.x): Boost (system, thread, filesystem), Lua 5.1 or LuaJIT, PhysFS, OpenSSL, zlib, GLEW or OpenGL ES + EGL, OpenAL, libogg/libvorbis, and **WinINet** (Windows-only updater in `client/runtime-data/download.cpp`).
- The custom updater (`download.cpp`) includes `<wininet.h>`, so the client source as-is is **Windows-only**.
- `install()` in CMake references `README.md BUGS LICENSE AUTHORS init.lua otclientrc.lua`. Only `init.lua` exists (in `client/runtime-data/`).

## Runtime layout expected

- `client/runtime-data/` is a ready-to-run Windows client folder: `otclient.exe` + DLLs + `init.lua` + `data/` + `modules/`. Git excludes the binaries and `Tibia.spr`.
- `server/runtime-data/` is a ready-to-run Windows server folder: `PS.exe` + DLLs + `config.lua` + `data/` + `pt_br.loc`. Git excludes the binaries. It needs MySQL with the dump imported as database `pokeaventuras` (the dump says `poketibia`).

## Next steps (not started)

1. Build the server on a modern toolchain (Linux gcc/clang, CMake), keeping TFS 0.3.6 semantics.
2. Build the client from `client/source/` (Windows first, since WinINet is used). Compare the result against the shipped `otclient.exe`.
3. Reconstruct the missing SQL tables (`market_items`, `market_historic`, `dungeon_ranking`, `player_stored_items`, `datalog_ping`, `z_ots_comunication`, `z_shop_history`).
4. Run everything in an isolated VM or container the first time. See `SECURITY_AUDIT.md`.
