# Building PokeVerse on Windows

This is how to build the Windows client (`pokeverse-client.exe`), the Windows server (`pokeverse-server.exe`) and the development package (`dist\windows\PokeVerse-Windows-Dev\`) on one Windows PC. The steps and versions are the ones CI runs (`.github/workflows/platforms.yml`, `windows-server.yml`).

Details live in two other files:
- `BUILD_REDEMPTION.md`: client presets, triplets and the other platforms.
- `BUILD_SERVER_WINDOWS.md`: the server toolchain, database and runtime.

To only play or test, download `PokeVerse-Windows-Dev.zip` from CI or a GitHub Release and follow `DOWNLOAD_AND_RUN.md`. You do not need to build anything.

## Versions

Client (CI job "Windows Redemption client", run 37667259073):

| Item | Version |
|---|---|
| Windows | Windows Server 2025, build 10.0.26100 (runner image `windows-2025-vs2026` 20260925.250.1). Windows 10/11 x64 should work but have not been used for builds |
| Visual Studio | 2026 (18.0) Enterprise. Community works the same way. Workload: "Desktop development with C++" |
| MSVC | toolset 14.51.36231, compiler 19.51.36260.0, x64 |
| Windows SDK / UCRT | 10.0.26100.0 |
| CMake | the one bundled with Visual Studio. The presets need CMake ≥ 3.24 |
| Generator | Ninja (bundled with Visual Studio) |
| vcpkg | checkout `9e593bb18ea69cc5095e012465dcd675a822ed0d` (the manifest's `builtin-baseline`). The tool reported version 2026-07-27 |
| vcpkg triplets | `x64-windows-static-release` (Release, no DLLs), `x64-windows` (Debug) |
| Git for Windows | any current version, for Git Bash and Git LFS |

Server: MSYS2 UCRT64 with MinGW-w64 GCC 16.2.0, CMake 4.4.4, Boost 1.92.0, Lua 5.1.5 and MariaDB Connector/C 3.4.9. The full table is in `BUILD_SERVER_WINDOWS.md`.

## One-time setup

1. Install **Visual Studio 2026** with "Desktop development with C++".
2. Install **Git for Windows** (includes Git Bash and Git LFS).
3. Install **MSYS2** to `C:\msys64` and the server packages (`BUILD_SERVER_WINDOWS.md`, "Set up a Windows development machine").
4. Install **MariaDB Server 10.11** (only needed to run, not to build).
5. Clone the repository and fetch the client's sprite file from LFS:

   ```bat
   git clone https://github.com/GIToez/PokeVerse.git
   cd PokeVerse
   git lfs pull --include client/runtime-data/data/things/Tibia.spr
   ```

6. Clone and bootstrap vcpkg at the pinned baseline, outside the repository:

   ```bat
   git clone https://github.com/microsoft/vcpkg.git C:\vcpkg
   git -C C:\vcpkg checkout 9e593bb18ea69cc5095e012465dcd675a822ed0d
   C:\vcpkg\bootstrap-vcpkg.bat -disableMetrics
   setx VCPKG_ROOT C:\vcpkg
   ```

   Open a new console afterwards so `VCPKG_ROOT` is set.

## Build

All three scripts are in `tools\windows\`, run from any `cmd` window, and stop at the first error with its exit code.

| Script | What it does | Output |
|---|---|---|
| `Build-PokeVerse-Client-Windows.bat [release\|debug]` | Loads the MSVC x64 environment (vswhere + vcvars64) unless `cl.exe` is already on `PATH`, then runs `tools/build_redemption.sh` and `tools/stage_redemption.sh` in Git Bash | `dist\client-redemption\pokeverse-client.exe` (Release) or `dist\client-redemption-debug\` |
| `Build-PokeVerse-Server-Windows.bat` | Runs `tools/build_server.sh` in the MSYS2 UCRT64 shell | `dist\server\` |
| `Build-PokeVerse-Windows.bat` | Both of the above, then `tools/package_windows.sh`, which assembles and validates the development package | `dist\windows\PokeVerse-Windows-Dev\` |

Environment variables: `VCPKG_ROOT` (required for the client), `GIT_BASH` (default `%ProgramFiles%\Git\bin\bash.exe`), `MSYS2_ROOT` (default `C:\msys64`), `BUILD_TYPE` for the server (`RelWithDebInfo` by default, or `Release`/`Debug`).

The first client build compiles every vcpkg dependency and takes the longest; later builds reuse the vcpkg binary cache (`%LOCALAPPDATA%\vcpkg\archives`).

## What the package contains

`tools/package_windows.sh` copies the client (`client\pokeverse-client.exe`) and the server (`server\pokeverse-server.exe`, with `config.lua` set to the local development database), adds the 854 SPR/DAT, the server's MinGW DLLs (listed in `server\required-dlls.txt`), the database schema, migrations and the development seed, the `.bat` launchers and `README.txt`. `tools/validate_windows_package.sh --check-imports` then checks that every DLL an executable imports is shipped or part of Windows.

`tools/validate_windows_package.sh` then refuses the package if it finds any of these:
- harness or debug builds, the smoke `otclientrc.lua` or auto-login code;
- the upstream bot module, Mesa DLLs, sources or CI scripts;
- credentials or a `config.lua`;
- a missing DLL;
- `.bat` and text files without CRLF line endings.

`tools/test_windows_package_guard.sh` checks that each of those refusals still works.

## Verify a build

- **Client and server together**: from Git Bash, with MariaDB running and `tools/setup_dev_db.sh` applied:

  ```bash
  KEEP_RUNNING=1 tools/smoke_server.sh /tmp/server.log
  tools/smoke_redemption_login.sh /tmp/client-trainer.log
  PV_ACCOUNT=admin PV_PASSWORD=admin PV_CHARACTER="GM Admin" PV_EXPECT_POKEBAR=1 tools/smoke_redemption_login.sh /tmp/client-gm.log
  ```

  The smoke copies the client to a temporary folder with a test `otclientrc.lua`; the dist itself never contains test code. On a headless machine it needs an OpenGL driver (CI copies Mesa llvmpipe DLLs into the temporary copy only).
- **Package**: follow `README.txt`, then the checklist in `WINDOWS_HANDS_ON_TESTING.md`.

## Common errors

| Message | Cause | Fix |
|---|---|---|
| `ERROR: set VCPKG_ROOT to a vcpkg checkout` | `VCPKG_ROOT` is missing | Step 6, then open a new console |
| `cl.exe is still not on PATH` | Visual Studio lacks the C++ workload, or vswhere is missing | Install "Desktop development with C++" |
| `no 854 assets in dist` | `Tibia.spr` is still an LFS pointer | `git lfs pull --include client/runtime-data/data/things/Tibia.spr`, then rebuild |
| vcpkg download errors | Network or proxy | Retry; the binary cache keeps finished ports |
| `PACKAGE INVALID: ... does not have CRLF line endings` | A file was edited with LF endings | Keep CRLF in `packaging\windows\*` (the packager converts its own outputs) |
