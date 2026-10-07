# Building and Running the Server on Windows

Windows x64 is the **primary** server platform (`PLATFORM_COMPATIBILITY.md`). The server is built from the same `server/source` as on Linux (`BUILD_SERVER_LINUX.md`). Platform differences live in a few `#ifdef WINDOWS` blocks that already existed in TFS 0.3.6, plus the Phase 3 console shutdown handler. There is no Windows-only gameplay code.

**Toolchain choice.** The original server was built on Windows with Dev-C++ and MinGW (`server/source/dev-cpp/`). PokeVerse keeps that compiler family: **MinGW-w64 GCC from MSYS2 (UCRT64 environment)**. MSVC is not used, because the TFS 0.3.6 code relies on GCC behaviour (`-fpermissive`, GNU extensions). The original Windows binaries are never run or used as evidence.

## Tested environment (CI)

| Item | Version |
|---|---|
| Windows | Windows Server 2025 (GitHub `windows-2025` runner), x64 |
| Shell / package manager | MSYS2, UCRT64 environment (`msys2/setup-msys2`) |
| Compiler | MinGW-w64 GCC 16.2.0 (MSYS2 Rev4), C++11 with GNU extensions |
| Build system | CMake 4.4.4 with Ninja |
| Boost | 1.92.0. Filesystem and thread are used; system and regex are linked only if the Boost build provides them. The server uses `io_context` and `steady_timer` and builds with deprecated Asio APIs disabled. |
| Lua | 5.1.5 (`mingw-w64-ucrt-x86_64-lua51`) |
| Database client | MariaDB Connector/C 3.4.9 (`mingw-w64-ucrt-x86_64-libmariadbclient`, `libmariadb.dll`). SQLite 3 is also compiled in. |
| Other | libxml2, OpenSSL 3, GMP, zlib, libiconv |
| Database server (CI) | MariaDB 10.11 (`shogo82148/actions-setup-mysql`) |

Visual Studio and MSVC are not required.

## Set up a Windows development machine

1. Install MSYS2 from https://www.msys2.org (default `C:\msys64`) and open **"MSYS2 UCRT64"**.
2. Install the toolchain and dependencies:

   ```bash
   pacman -Syu
   pacman -S --needed git mingw-w64-ucrt-x86_64-{gcc,cmake,ninja,pkgconf,boost,libxml2,openssl,lua51,libmariadbclient,sqlite3,gmp,python}
   ```

3. Install MariaDB Server 10.11 for Windows (MSI from mariadb.org). Add its `bin` directory to `PATH` so the `mysql` client is available in the UCRT64 shell.
4. Clone the repository. The server needs no Git LFS files; the client's `Tibia.spr` does.

## Build

From the UCRT64 shell, at the repository root:

```bash
tools/build_server.sh                      # RelWithDebInfo (default)
BUILD_TYPE=Release tools/build_server.sh   # Release
BUILD_TYPE=Debug tools/build_server.sh     # Debug
```

The script runs these commands:

```bash
cmake -S server/source -B build/server -G Ninja -DCMAKE_BUILD_TYPE=RelWithDebInfo
cmake --build build/server -j"$(nproc)"
install build/server/pokeverse-server.exe dist/server/
ldd dist/server/pokeverse-server.exe   # every DLL from /ucrt64/bin is copied next to the exe
```

| Output | Path |
|---|---|
| Build tree | `build\server\` |
| Server executable | `dist\server\pokeverse-server.exe` |
| Runtime DLLs | Copied into `dist\server\` by `build_server.sh`. As built in CI: `libstdc++-6`, `libgcc_s_seh-1`, `libwinpthread-1`, `lua51`, `libmariadb`, `libsqlite3-0`, `libxml2-16`, `libcrypto-3-x64`, `libssl-3-x64`, `libgmp-10`, `zlib1`, `libiconv-2`, `libintl-8`, `libzstd`. Connector/C also pulls in `libcurl-4`, `libssh2-1`, `libnghttp2-14`, `libnghttp3-9`, `libngtcp2-16`, `libngtcp2_crypto_ossl-0`, `libpsl-5`, `libidn2-0`, `libunistring-5`, `libbrotlicommon` and `libbrotlidec`. Boost is linked statically, so no Boost DLL is needed. The CI artifact `pokeverse-server-windows-x64` is that directory. |
| Runtime data | `server\runtime-data\` (config, `data\`, map). This is the working directory. |

`dist\server` is self-contained apart from MariaDB itself. It runs outside the MSYS2 shell, for example from `cmd` or PowerShell, provided the working directory is `server\runtime-data`.

## Database (DEVELOPMENT ONLY)

```bash
MYSQL="mysql -uroot -p<root-password> -h127.0.0.1" tools/setup_dev_db.sh
```

This creates the `pokeverse` database, runs the migrations and seeds the dev accounts. The server connects as `pokeverse` / `pokeverse-dev` to `localhost:3306` (`config.lua`). On Windows a TCP connection may be seen as coming from `127.0.0.1` rather than `localhost`. If the server reports "Access denied", also create the `pokeverse` user for host `127.0.0.1`; CI does this.

## Run

```bash
tools/run_server.sh                 # foreground, from the UCRT64 shell
tools/smoke_server.sh               # startup test (PASS/FAIL), then stops the server
```

The direct equivalent from `cmd`:

```bat
cd server\runtime-data
mkdir logs\server logs\chat logs\bots logs\talkactions
..\..\dist\server\pokeverse-server.exe
```

The server listens on 127.0.0.1 port 7564 (login) and port 8548 (game).

## Shutdown on Windows

Windows has no SIGTERM or SIGQUIT. Phase 3 adds a console control handler (`consoleCtrlHandler` in `otserv.cpp`). **Ctrl+C**, **Ctrl+Break**, closing the console window, and Windows logoff or shutdown all trigger the same save-and-shutdown path as `kill -QUIT` on Linux (`GAME_STATE_SHUTDOWN`: players and the map are saved, then the server exits). For a close or shutdown event, Windows allows a few seconds before it terminates the process. Use Ctrl+C for a guaranteed full save.

`tools/smoke_server.sh` stops the server with `taskkill /F`, because MSYS2 cannot signal native processes and the smoke test saves nothing.

## Logging and crash reporting

| What | Where |
|---|---|
| Console output | stdout. `run_server.sh` keeps it on the console; `smoke_server.sh` writes it to a file. |
| Engine logs | `server\runtime-data\logs\{server,chat,bots,talkactions}\` |
| Emergency save | The `__EMERGENCY_SAVE__` handler for SIGSEGV, SIGILL, SIGFPE and SIGABRT is POSIX-only. On Windows a crash ends the process without an emergency save. Rely on periodic saves. |
| Crash dumps | Not enabled. `__EXCEPTION_TRACER__` (MinGW stack dumper) is off, as on Linux. Windows Error Reporting / ProcDump can capture dumps. |

## Known Windows-specific issues

| Issue | Status |
|---|---|
| Boost 1.87+ removed `io_service` and related APIs, and `deadline_timer` is unavailable in Boost 1.92. MSYS2 only ships Boost 1.87 and newer. | **Fixed**: the networking code was ported to `io_context` and `steady_timer`; Linux uses the same code |
| `MAXUINT32` local variable clashes with the Windows SDK macro | **Fixed** (`tools.cpp`) |
| `_WIN32_WINNT` was set to Windows XP (0x0501) | Raised to Windows 7 (0x0601), as modern Boost.Asio and MinGW-w64 require |
| No clean shutdown on Ctrl+C or console close | **Fixed**: console control handler |
| No emergency save on crash | Open (POSIX signals only) |
| The "Outdated MySQL server detected" warning | Harmless (the client library version check is wrong), as on Linux |

## Verification status

| Check | Result |
|---|---|
| Source build (RelWithDebInfo) | **PASS**: CI run 37612035643, 2026-10-07 |
| Startup smoke (MariaDB 10.11) | **PASS**. The startup log matches the Linux log line for line (config, RSA, SQL, items, monsters, map 5879x3541, spawns, houses, NPCs, all script systems, "Cristal server Online!"). The only warning is the harmless "Outdated MySQL" one. |
| Debug build | NOT TESTED (`BUILD_TYPE=Debug`) |
| Clean shutdown (Ctrl+C) | NOT TESTED in CI: a native console control event cannot be sent from the CI shell |

See `PLATFORM_COMPATIBILITY.md` (Server matrix → Windows) for the current results. Build and startup are covered by CI (`.github/workflows/windows-server.yml`). Player login, gameplay, save and load, restart persistence and admin commands against a Windows server need a client session and are recorded there as they are tested.
