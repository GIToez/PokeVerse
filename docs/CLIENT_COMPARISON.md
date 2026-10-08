# Comparing the legacy and the Redemption client

PokeVerse has two desktop clients. Both are built by GitHub Actions from this repository and connect to the same PokeVerse server (`127.0.0.1:7564`, protocol 854, the same PokeVerse 854 SPR/DAT):

| | Legacy client | Redemption client |
|---|---|---|
| Source | `client/source` + `client/runtime-data` (OTClient 0.6.6 fork, the original PokeJornadas/PokeVerse interface and modules) | `client-redemption/` (OTClient Redemption) |
| Executable | `legacy-client/pokeverse-legacy-client(.exe)` | `redemption-client/pokeverse-client(.exe)` |
| Windows build | MSYS2 UCRT64 GCC ([BUILD_LEGACY_WINDOWS.md](BUILD_LEGACY_WINDOWS.md)) | MSVC + vcpkg ([BUILD_WINDOWS.md](BUILD_WINDOWS.md)) |
| Settings | `%USERPROFILE%\Pokecenter` (Windows), `~/.Pokecenter` (Linux) | `%APPDATA%\pokeverse` (Windows), `~/.local/share/pokeverse` (Linux) |
| Log | `%USERPROFILE%\Pokecenter.log`, `~/Pokecenter.log` | `redemption-client/pokeverse.log` |
| Android | no target (see below) | `PokeVerse-Redemption-Android-arm64.apk` |

Redemption stays the primary client. The legacy client is shipped so testers can compare the two; neither replaces the other. No original PokeJornadas executable or DLL is shipped: both clients are compiled from reviewed source, the legacy WinINet auto-updater is compiled out (`LEGACY_UPDATER=OFF`) and the validators refuse any file whose name or SHA-256 matches `original/MANIFEST.sha256.tsv`.

## Packages

All of them come from the Platforms workflow, <https://github.com/GIToez/PokeVerse/actions/workflows/platforms.yml> (open a green run, then **Artifacts**). A `v*` tag attaches them to the GitHub Release with the version in the name.

| Artifact | Contents | Start with |
|---|---|---|
| `PokeVerse-Server-Windows` | `server/`, `database/`, `scripts/`, database setup, start and stop | `Setup Database.bat`, `Start Server.bat`, `Stop Server.bat` |
| `PokeVerse-Legacy-Windows` | `legacy-client/` | `Start Legacy Client.bat` |
| `PokeVerse-Redemption-Windows` | `redemption-client/` | `Start Redemption Client.bat` |
| `PokeVerse-Client-Comparison-Windows` | the three above in one folder: `server/`, `database/`, `legacy-client/`, `redemption-client/`, `scripts/` | `Setup Database.bat`, `Start Server.bat`, `Start Legacy Client.bat`, `Start Redemption Client.bat`, `Start Both Clients.bat`, `Stop Server.bat` |
| `PokeVerse-Server-Linux` | `PokeVerse-Server-Linux.tar.gz` | `./setup-database.sh`, `./start-server.sh`, `./stop-server.sh` |
| `PokeVerse-Legacy-Linux` | `PokeVerse-Legacy-Linux.tar.gz` | `./start-legacy-client.sh` |
| `PokeVerse-Redemption-Linux` | `PokeVerse-Redemption-Linux.tar.gz` | `./start-redemption-client.sh` |
| `PokeVerse-Redemption-Android-arm64` | `PokeVerse-Redemption-Android-arm64.apk` (the same APK as `PokeVerse-Android-arm64`) | install the APK |
| `PokeVerse-Client-Comparison-Results-Windows`, `-Linux` | screenshots, metrics and logs of the CI comparison run | — |

`PokeVerse-Windows-Dev` and `PokeVerse-Linux-Dev` (server + Redemption client) are still built and tested as before. The server and Redemption files in the separate packages are copied unchanged from them.

### Windows, step by step

1. Download `PokeVerse-Client-Comparison-Windows.zip`, right-click it, *Extract All*. Any folder works, also with spaces in the path.
2. Install MariaDB Server once (<https://mariadb.org/download/>, defaults, remember the root password).
3. `Setup Database.bat` once; it ends with `Database setup: SUCCESS`.
4. `Start Server.bat`; wait for `server Online!`. It refuses to start a second server.
5. `Start Legacy Client.bat`, `Start Redemption Client.bat`, or `Start Both Clients.bat` (it starts no server; it refuses while none runs). Each window title says which client it is.
6. Log in with `player` / `player` (Trainer) or `admin` / `admin` (GM Admin). A character can be online only once: to compare the same character, log out of one client first; to run both at once, use one account in each.
7. `Stop Server.bat` (or Ctrl+C in the server window) saves and stops the server.

The separate packages work the same way: extract `PokeVerse-Server-Windows` and run its server, then extract and start either client package anywhere.

## How the packages are checked

- `tools/package_split.sh` builds them from the validated development package and the legacy client build.
- `tools/validate_split_packages.sh` refuses a package set when:
  - an executable is mislabeled or swapped (the `Pokecenter` marker only exists in the legacy client, `Redemption` only in the Redemption client, and each folder has a `CLIENT` file);
  - legacy files are in the Redemption client or the other way round;
  - images, modules, `client/runtime-data` files, DLLs or shared libraries are missing;
  - Git LFS pointers, harness or smoke files, logs, sources, Mesa, the bot module, the legacy updater or original PokeJornadas binaries are present;
  - a client is in the server package, or the server config does not use 127.0.0.1;
  - the comparison package differs from the separate packages.
- `tools/test_split_package_guard.sh` tampers with copies of the real packages in 26 ways (30 on Windows) and fails unless every copy is refused.
- `tools/test_split_packages.sh` runs the packages outside the checkout from a path with spaces:
  1. database setup, twice;
  2. `Start Both Clients` refuses without a server (Windows);
  3. one server, and a second start is refused;
  4. each unmodified launcher starts exactly its packaged executable;
  5. both clients log the same character into that server one after the other (`tools/compare_clients.sh`);
  6. the package's stop script saves and stops the server.

## Comparison run

`tools/compare_clients.sh` runs the Redemption smoke and then the legacy smoke against one running server, with the same account (`player` / Trainer) and the same 1280x720 window. Both runs are read-only for the legacy client (its production build keeps bot protection on), so it logs in through the login and character windows' own functions and observes. CI publishes the result as `PokeVerse-Client-Comparison-Results-Linux` and `-Windows` (`comparison/summary.md`, `legacy.png`, `redemption.png`, logs and metrics).

The run below is from the Linux packages (Ubuntu 24.04, Xvfb, Mesa llvmpipe software OpenGL, no audio device), extracted from the tarballs:

| | Legacy | Redemption |
|---|---|---|
| Login smoke | PASS | PASS |
| Launch to in game | 2.5 s | 2.0 s |
| Memory, map loaded | 0.78 GB | 1.04 GB |
| FPS (software OpenGL, CPU-bound) | 60–64 | 160–200 |
| Texture errors / Lua errors | 0 / 0 | 0 / 0 |
| Log lines containing "error" | 1 ("reach max zoom in") | 13 (all: no audio device on the CI machine) |

What both clients showed for the same character on the same server:

- **Inventory:** the same 6 items in the same slots (ids 11597, 11827, 11241, 11242, 10786, 11872).
- **Creatures on screen:** Professor Oak (lookType 2594), Oak's Assistant (2596), Nurse Joy (560) and Trainer (612), with the same outfits in both.
- **Server messages:** both received the welcome text and the channel greetings.
- **Feature modules:** each feature below loaded in both clients (`login`, `map`, `minimap`, `pokebar`, `moves`, `inventory`, `containers`, `pokedex`, `pokemon_info`, `npc_trade`, `shop`, `market`, `chat`, `battle_list`, `hotkeys`, `outfit`, `questlog`, `task`, `battle_pass`, `craft`, `tm_choose`, `statusbar`, `pokekill`, `effects`).

FPS under software OpenGL measures the CPU renderer, not a GPU; compare FPS on real hardware by hand. Memory and startup time are comparable between the two because they ran on the same machine one after the other.

**Screenshots** (same position outside Professor Oak's lab, 1280x720):

- The legacy client draws the map over the whole window with the PokeJornadas floating panels: Health Info, Inventory with Mochila/Order/Pokedex buttons, Minimap, and the chat at the bottom left.
- The Redemption client uses its framed layout: the map viewport in the middle, the right-hand panel with inventory and Pokédex/Order/Badges/Mochila buttons, Store, the Battle List and VIP; the action bar and chat are below the map.
- The visible map area differs: the legacy client shows more tiles around the character.

## Feature compatibility report

Sources:

- **Automated (this work):** `tools/compare_clients.sh`, from the packages, both clients, the same server.
- **Redemption smoke:** `tools/smoke_redemption_login.sh` as Trainer and as GM Admin with Pokémon. It runs in CI on Windows and Linux against the same server; [REDEMPTION_PARITY_MATRIX.md](REDEMPTION_PARITY_MATRIX.md) has the details.
- **Legacy harness:** `tools/runtime_test.sh` with the legacy client's harness build (the same source with bot protection off) and manual runs, recorded in [FEATURE_TEST_MATRIX.md](FEATURE_TEST_MATRIX.md) (Phase 2, 2026-10-07). It is not re-run on every commit.
- **Manual:** still to be done by a tester with both packages. Nothing in this table is claimed from "both clients start".

| Feature | Legacy client | Redemption client | Same? |
|---|---|---|---|
| Login, character selection | Automated: PASS (Trainer) | Automated: PASS (Trainer, GM Admin) | Same account and character list |
| Entering the game | Automated: PASS, map loaded | Automated: PASS, map loaded | Same position |
| Map | Automated: tiles and screenshot | Automated: tiles and screenshot | Same map; legacy shows a larger area |
| UI layout | PokeJornadas floating panels | Redemption framed layout | Different by design (no UI redesign in this task) |
| Sprites and outfits | Automated: same lookTypes for every creature on screen | Same | Same SPR/DAT file |
| Pokémon bar | Module loaded; summon and recall: legacy harness PASS | Redemption smoke: portrait, summon and switch | Manual side-by-side check pending |
| Moves | Module loaded; move calls: legacy harness PASS | Redemption smoke: move used, cooldown returned | Manual check pending |
| Inventory | Automated: identical items | Automated: identical items | Yes |
| Containers | Legacy harness: the pokébag opens | Module loaded | Manual check pending |
| Pokédex | Legacy harness: registering Charmander | Redemption smoke: status list (386 entries), window opens | Manual check pending |
| Pokémon Info and stats (EVs) | Legacy harness: window, EV spend and reset | Redemption smoke: window, EV spend, forged upgrade refused | Manual check pending |
| NPCs | Automated: same NPCs and outfits; Oak greeting: manual PASS | Same NPCs and outfits; Oak greeting in the smoke | Manual dialogue check pending |
| Chat | Automated: receives server and channel messages; say: manual PASS | Smoke: receives and sends | Manual check pending |
| Shops (diamond shop, NPC trade) | Legacy harness: shop opens (purchases not exercised) | Redemption smoke: shop opens, forged and unaffordable offers refused | Manual check pending |
| GTS / market | Legacy harness: market tabs load (offers not exercised) | Two-account market test in CI (Linux) | Manual check pending |
| Visual effects | Module `game_effects` loaded; not verified | `game_attachedeffects` loaded; not verified | Not verified |
| Audio | OpenAL engine present; not verified | OpenAL engine present; not verified | Not verified (CI has no audio device) |
| Movement and controls | Walking with arrow keys: manual PASS; automation blocked by bot protection | Smoke: walk one step | Manual check pending |
| Performance and stability | Startup 2.5 s, 0.78 GB, clean exit, 0 Lua errors | Startup 2.0 s, 1.04 GB, clean exit, 0 Lua errors | Comparable on the same machine; FPS needs real hardware |

"Manual check pending" means both clients have the feature and each was exercised on its own, but nobody has yet compared the two side by side. Visual effects and audio have not been verified in either client.

## No legacy Android target

The legacy client cannot be built for Android, and none is shipped:

- **Platform layer:** OTClient 0.6.6 has only Win32 and X11 windows (`framework/platform/win32window.cpp`, `x11window.cpp`). There is no Android or EGL window, no touch input and no Android activity or APK project.
- **Graphics:** its OpenGL ES path is an incomplete desktop option, not a mobile port.
- **What it would take:** a new platform layer, input handling and packaging, which would be a port of the engine rather than a build of it.

The Android client is Redemption, which has a working Android platform layer: `PokeVerse-Redemption-Android-arm64.apk`.
