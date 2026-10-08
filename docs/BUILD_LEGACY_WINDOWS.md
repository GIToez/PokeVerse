# Building the legacy client on Windows

Testers never need this: the Platforms workflow builds the legacy client (`windows-legacy-client` job) and packages it as `PokeVerse-Legacy-Windows` and `PokeVerse-Client-Comparison-Windows` ([CLIENT_COMPARISON.md](CLIENT_COMPARISON.md)). This page is for developers who want to build `client/source` themselves.

The legacy client is the OTClient 0.6.6 fork in `client/source`, with its data in `client/runtime-data`. On Windows it is built with MSYS2 UCRT64 GCC, the same toolchain as the Windows server ([BUILD_SERVER_WINDOWS.md](BUILD_SERVER_WINDOWS.md)). The imported PokeJornadas `otclient.exe` and its DLLs are never used.

## Steps

1. Install MSYS2 from <https://www.msys2.org/> and open the **MSYS2 UCRT64** shell.
2. Install the packages (the CI list in `.github/workflows/platforms.yml`):

   ```bash
   pacman -S --needed git git-lfs \
     mingw-w64-ucrt-x86_64-{gcc,cmake,ninja,pkgconf,ccache,boost,lua51,physfs,openssl,zlib,glew,openal,libvorbis,libogg,binutils}
   ```

3. Fetch the sprite file, which is stored in Git LFS: `git lfs pull --include client/runtime-data/data/things/Tibia.spr`.
4. Build:

   ```bash
   tools/build_client.sh
   ```

   The result is in `dist/client/`. It contains:

   - `pokeverse-client.exe` and `libotc_framework.dll`;
   - the UCRT64 DLLs they load (found with `ldd`);
   - a copy of `client/runtime-data` (data, modules, `init.lua`).

   Run the client from that folder.

## Settings

| Option | Value | Notes |
|---|---|---|
| Build type | RelWithDebInfo | `tools/package_split.sh` strips the debug info for the package. |
| Bot protection | on | Production variant. `VARIANT=harness` turns it off for local runtime tests only; harness builds are never packaged. |
| `LEGACY_UPDATER` | OFF | The original WinINet updater downloaded files over plain HTTP. The validators refuse a package whose binary imports `wininet.dll` or contains the updater's URL. |
| C++ standard | `-std=gnu++17` | Set through `CXX_STD_FLAG`: MSYS2's Boost no longer builds as C++11. |
| Generator | Ninja | Used for a fresh build directory. |

## Packaging

`tools/package_split.sh windows <PokeVerse-Windows-Dev> dist/client <out-dir>` builds the separate packages. The legacy executable is named `pokeverse-legacy-client.exe` there.

The legacy client refuses to start next to an `opengl32.dll`. CI's GPU-less runners therefore use Mesa only in throwaway copies (`MESA_DIR` in `tools/smoke_legacy_login.sh`), and never in a package.
