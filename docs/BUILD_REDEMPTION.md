# Building OTClient Redemption (`client-redemption/`)

This document covers how to build the Redemption client on each target platform. The build steps are those of the unmodified upstream client (`REDEMPTION_BASELINE.md`). Platform priority is Windows, then Android, then Linux (`PLATFORM_COMPATIBILITY.md`). The PokeVerse-specific changes are made on top of this clean build.

Build products never go inside `client-redemption/`. They go to `build/client-redemption/<type>/`, and staged runnable copies go to `dist/client-redemption*/`. Both directories are git-ignored.

## Common

- **Dependency manager.** vcpkg in manifest mode (`client-redemption/vcpkg.json`). Pin vcpkg to the manifest's `builtin-baseline` `9e593bb18ea69cc5095e012465dcd675a822ed0d`. A newer vcpkg checkout also works locally, because manifest mode resolves port versions against the baseline.
- **Dependencies.** asio, abseil, cpp-httplib, cppcodec, discord-rpc, liblzma, libarchive, libobfuscate, libogg, libpng (apng), libvorbis, nlohmann-json, openal-soft, openssl, parallel-hashmap, physfs, protobuf, pugixml, stduuid, zlib, bshoshany-thread-pool, fmt, ixwebsocket, spdlog, utfcpp, freetype, inih, luajit, opengl, glew. Windows also uses angle. The `tests` feature adds gtest.
- **Presets.** Defined in `client-redemption/CMakePresets.json`. Each preset's own `binaryDir` is overridden with `-B build/client-redemption/<type>`. `-DTOGGLE_BIN_FOLDER=ON` puts the executable in `<build>/bin/`.
- **Environment variables.**
  - `VCPKG_ROOT` is required by the presets.
  - `VCPKG_DEFAULT_BINARY_CACHE` holds the vcpkg binary cache. It defaults to `~/.cache/vcpkg/archives`, and CI caches it.
  - `CC`/`CXX` apply on Linux only and default to `gcc-14`/`g++-14`.
  - `JOBS` and `EXTRA_CMAKE_ARGS` are optional.
- **Scripts.**
  - `tools/build_redemption.sh [release|debug]` picks `linux-*` or `windows-*` from the host.
  - `tools/stage_redemption.sh [release|debug]` copies the executable and runtime files into `dist/`.
  - `tools/package_client.sh dist/client-redemption` packages a production build after the harness guard (`CLIENT_VARIANTS.md`).

| Type | Preset (Linux / Windows) | CMake build type | vcpkg triplet (Linux / Windows) | Tests |
|---|---|---|---|---|
| release | `linux-release` / `windows-release` | RelWithDebInfo | `x64-linux` / `x64-windows-static-release` | off |
| debug | `linux-debug` / `windows-debug` | Debug (`DEBUG_LOG=ON`) | `x64-linux` / `x64-windows` | on for Linux (gtest); off in Windows CI |

## Windows x64 (PRIMARY)

| Item | Value |
|---|---|
| OS / runner | Windows Server 2025 with Visual Studio 2026 (GitHub `windows-2025-vs2026`, the same runner upstream uses) |
| Compiler | MSVC v145 toolset (`cl.exe`), x64 |
| Generator | Ninja (bundled with Visual Studio) |
| Shell | Git Bash with the MSVC developer environment (`ilammy/msvc-dev-cmd`, or "x64 Native Tools" prompt, then `bash`) |

```bash
git clone https://github.com/microsoft/vcpkg.git && git -C vcpkg checkout 9e593bb18ea69cc5095e012465dcd675a822ed0d
./vcpkg/bootstrap-vcpkg.bat -disableMetrics
export VCPKG_ROOT="$PWD/vcpkg"
EXTRA_CMAKE_ARGS="-DOPTIONS_ENABLE_IPO=OFF -DOTCLIENT_BUILD_TESTS=OFF" tools/build_redemption.sh release
tools/stage_redemption.sh release        # dist/client-redemption/pokeverse-client.exe
tools/package_client.sh dist/client-redemption
```

The equivalent raw commands:

```bat
cmake -S client-redemption -B build\client-redemption\release --preset windows-release -DTOGGLE_BIN_FOLDER=ON -DOPTIONS_ENABLE_IPO=OFF
cmake --build build\client-redemption\release
```

| Output | Path |
|---|---|
| Release executable | `build/client-redemption/release/bin/otclient.exe` (static triplet: no vcpkg DLLs) |
| Debug executable | `build/client-redemption/debug/bin/otclient.exe` plus vcpkg DLLs (dynamic `x64-windows` triplet) |
| Standalone Release package | `dist/client-redemption/` → `dist/packages/pokeverse-client-windows-x64.tar.gz` (CI artifact `pokeverse-client-windows-x64-release`) |

**Status:** built in CI by `platforms.yml` job `windows-client`. See `PLATFORM_COMPATIBILITY.md` for the latest result. Visual Studio solution builds (`client-redemption/vc18/otclient.sln`) are not used by PokeVerse.

## Android ARM64 (SECONDARY)

| Item | Value |
|---|---|
| Host | Ubuntu 24.04 (GitHub `ubuntu-24.04`) |
| JDK | Temurin 17 |
| Android SDK | compileSdk 36, build-tools 36.0.0, CMake 3.22.1 (SDK) |
| NDK | 29.0.13599879 |
| ABI / triplet | `arm64-v8a` / `arm64-android` |
| LuaJIT | Built separately by `client-redemption/build_luajit_android.sh` at LuaJIT commit `d0e88930ddde28ff662503f9f20facf34f7265aa` |
| Assets | `data/`, `mods/`, `modules/`, `init.lua`, ... packed into `android/app/src/main/assets/data.zip` |

```bash
cd client-redemption
git clone https://github.com/LuaJIT/LuaJIT.git luajit-src && git -C luajit-src checkout d0e88930ddde28ff662503f9f20facf34f7265aa
OTCLIENT_ANDROID_ABIS=arm64-v8a ./build_luajit_android.sh
# pack data.zip (see .github/workflows/platforms.yml, step "Pack game assets")
cd android && OTCLIENT_ANDROID_ABIS=arm64-v8a ./gradlew :app:assembleRelease
```

The output is `client-redemption/android/app/build/outputs/apk/release/*.apk` (CI artifact `pokeverse-client-android-arm64`). The Android build writes `luajit-src/`, `android/app/libs` and `android/app/build` inside `client-redemption/`. These are upstream's Gradle conventions. `android/app/libs` and `build/` are ignored by upstream's `.gitignore`; the root `.gitignore` adds `luajit-src/` and the generated `data.zip`.

Android uses the same game protocol as the desktop clients. There is no separate gameplay protocol.

**Status:** built in CI by `platforms.yml` job `android-client`. Not yet installed on a device or emulator (`PLATFORM_COMPATIBILITY.md`).

## Linux x64 (TERTIARY)

| Item | Value |
|---|---|
| OS | Ubuntu 24.04.4 LTS |
| Compiler | GCC 14.2.0 (`gcc-14`/`g++-14`; the system default GCC 13 is not used) |
| CMake / Ninja | 3.28.3 / 1.11.1 |
| vcpkg | `/home/ubuntu/vcpkg` locally (tool 2026-09-26); the baseline commit in CI |
| System packages | `ccache gcc-14 g++-14 ninja-build pkg-config autoconf autoconf-archive automake libtool libtool-bin libltdl-dev libgl1-mesa-dev libglu1-mesa-dev libx11-dev libxcursor-dev libxi-dev libxinerama-dev libxrandr-dev linux-libc-dev perl` |

```bash
git clone https://github.com/microsoft/vcpkg.git ~/vcpkg && ~/vcpkg/bootstrap-vcpkg.sh -disableMetrics
tools/build_redemption.sh release   # build/client-redemption/release/bin/otclient
tools/build_redemption.sh debug     # build/client-redemption/debug/bin/otclient + gtest suites
ctest --test-dir build/client-redemption/debug
tools/stage_redemption.sh release
```

The script runs:

```bash
CC=gcc-14 CXX=g++-14 cmake -S client-redemption -B build/client-redemption/release --preset linux-release -DTOGGLE_BIN_FOLDER=ON
cmake --build build/client-redemption/release -j"$(nproc)"
```

### Linux results (2026-10-07, local, unmodified upstream 396f0b3)

| Build | Result | Notes |
|---|---|---|
| Release (`linux-release`) | **PASS** | First run about 20 minutes on 4 CPUs (10:07 to 10:27), most of it building vcpkg dependencies. `otclient` is 159 MB with debug info. |
| Debug (`linux-debug`) | **PASS** | About 6 minutes after the Release run filled the binary cache. `otclient` is 304 MB. |
| Unit tests (`ctest`, Debug) | **PASS** | 34/34 |
| Launch (Xvfb/VM display) | **PASS** | The window "OTClient - Redemption" opens and shows the upstream language selector. Only error: "Unable to open audio device" (no sound card). |
| Packaging | **PASS** | `tools/package_client.sh dist/client-redemption`: 87 MB tarball |

## Running against the PokeVerse server

The PokeVerse changes in `client-redemption/` are listed in `REDEMPTION_PROTOCOL_COMPATIBILITY.md` §11 and `REDEMPTION_PARITY_MATRIX.md`. They are separate commits on top of the upstream subtree; see the upstream delta with `git diff 96f1e0f32 -- client-redemption/`.

- **Assets.** `tools/stage_redemption.sh` puts `client/runtime-data/data/things/Tibia.{dat,spr}` into `dist/client-redemption*/data/things/854/`, as hard links where possible. Nothing is renumbered or converted. `Tibia.spr` is a 275 MB Git LFS object; without `git lfs pull` the stage warns and contains no game assets. Upstream's asset download (`Services.clientAssets`) is disabled in `init.lua`.
- **Server.** `init.lua` lists `127.0.0.1`, port 7564, protocol 854. At 854 `modules/game_features/features.lua` enables the PokeVerse feature set, including `GamePokeVerse`.
- **Names.** The window title is "PokeVerse". User settings and the log file use the compact name `pokeverse` (for example `~/.local/share/pokeverse/` on Linux, `%APPDATA%\pokeverse\` on Windows; exact paths come from PhysFS). The user script is still `otclientrc.lua`, because upstream packaging ships that name.
- **Smoke test.** With a server running (`KEEP_RUNNING=1 tools/smoke_server.sh`):

```bash
tools/smoke_redemption_login.sh /tmp/redemption-smoke.log                    # player / Trainer
PV_ACCOUNT=admin PV_PASSWORD=admin PV_CHARACTER="GM Admin" \
  SCREENSHOT=/tmp/gm.png tools/smoke_redemption_login.sh /tmp/gm.log
```

  It runs a throwaway copy of the dist with `tools/redemption_smoke_rc.lua` as the user script, so `dist/` never contains test code. It works under Xvfb on Linux and under Git Bash or MSYS2 on Windows; there it needs an OpenGL driver, for example the Mesa llvmpipe DLLs that CI drops next to the executable. CI runs it on both platforms: `platforms.yml` → `windows-e2e` (Windows client and Windows server) and the Linux Release job.

## Common errors

| Symptom | Cause / fix |
|---|---|
| `vcpkg not found at ...` | Set `VCPKG_ROOT` to a bootstrapped vcpkg checkout |
| CMake: "No such preset" / condition false | The `linux-*` presets only work on Linux and the `windows-*` presets only on Windows (the presets have host conditions) |
| Linux: C++20 or `std::format` errors with GCC 13 | Use GCC 14 (`CC=gcc-14 CXX=g++-14`), as upstream recommends |
| vcpkg port build fails for missing `autoconf`/`libtool` | Install the Linux system packages above. Some ports build with autotools. |
| Windows: `v145 toolset not found` | Use Visual Studio 2026 or override `VCPKG_PLATFORM_TOOLSET` |
| Windows: link takes very long | Pass `-DOPTIONS_ENABLE_IPO=OFF`, as upstream CI does |
| `Unable to open audio device` | Harmless on machines without a sound device |
| "Things are not loaded, please put spr and dat in things/854/" | `Tibia.spr` is an LFS pointer: `git lfs pull`, then restage |
| `Unhandled opcode 0xFF` | `modules/gamelib/pokeverse.lua` is not loaded (check `gamelib.otmod`) |
| First build is slow | vcpkg builds every dependency from source. Keep `VCPKG_DEFAULT_BINARY_CACHE`; CI caches it. |
