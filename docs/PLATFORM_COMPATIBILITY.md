# Platform Compatibility

## Priority

| Rank | Client | Server |
|---|---|---|
| 1 (PRIMARY) | Windows x64 | Windows x64 |
| 2 (SECONDARY) | Android ARM64 | Linux x64 |
| 3 (TERTIARY) | Linux x64 | — |

Windows is the primary development and player test platform. When platforms disagree, fix Windows first, then Android, then Linux. Do not knowingly break Linux to make Windows work: there is one codebase with platform abstractions, and no per-platform gameplay code. Android uses the same server protocol as the desktop clients.

**Linux CI success is not proof that PokeVerse works.** A green build is build evidence only. A runtime row here is PASS only when that feature was exercised on that platform, and a Linux pass never stands in for a Windows result.

Statuses: **PASS**, **PARTIAL**, **FAIL**, **BLOCKED**, **NOT TESTED**.

## How each platform is tested

All evidence follows source → build → dist → test. The original Windows binaries from the archive are never run.

| Platform | Build evidence | Runtime evidence | Limits |
|---|---|---|---|
| Windows client | CI `platforms.yml` → Windows Redemption client, Release and Debug (MSVC), plus packaging validation | CI "Windows end-to-end" job: the Release package, with Mesa llvmpipe for OpenGL, logs in to a **Windows-built server** on the same runner (`tools/smoke_redemption_login.sh` driving `tools/redemption_smoke_rc.lua`). Screenshots are uploaded as artifacts. | Software rendering on a headless runner: no GPU, no frame-rate or input-device check. Hands-on play on a Windows desktop still needs a person. |
| Windows server | CI `windows-server.yml` (MSYS2 UCRT64 / MinGW-w64) | Same workflow: startup smoke, then `tools/protocol_smoke.sh` with the headless protocol client against MariaDB 10.11 | — |
| Android client | CI `platforms.yml` → arm64-v8a APK | — | No device or emulator is available (no KVM). Install, launch and touch tests need a device. |
| Linux client | CI `platforms.yml` → Linux Redemption client, Release and Debug; local builds | CI: the same smoke as Windows under Xvfb against a Linux server. Local: the same smoke plus the legacy-client runtime harness. | — |
| Linux server | Local and CI `validate.yml` | Local: startup, protocol smoke, Redemption smoke, legacy runtime harness. CI: startup and protocol smoke. | — |

What the Redemption smoke checks, in order (each step is a hard `need` in `tools/smoke_redemption_login.sh`):

1. SPR/DAT 854 load, character list, the character exists.
2. Enter game, at least one PokeVerse 0xFF sub-protocol signal parsed, map tiles received.
3. `game_pokebar` loaded. With `PV_EXPECT_POKEBAR=1` (GM Admin, who gets a Charmander from `/cb` first): a portrait is shown; clicking it summons that Pokémon; a second portrait switches (when there is one); the move bar fills; a move used on a spawned Rattata comes back with a server cooldown.
4. One step of walking, a chat line, clean logout.

The Pokémon tests run at 3325,806,6, just outside the starting temple, because the server refuses moves inside a protection zone.

## Client matrix (Redemption client)

| Feature | Windows | Android | Linux |
|---|---|---|---|
| Build | **PASS**: Release and Debug, CI run 37625227955 | **PASS**: arm64-v8a APK, CI run 37625227955 | **PASS**: Release and Debug, CI run 37625227955; local |
| Packaging (no harness, no bot module) | **PASS** (CI packaging validation) | n/a (APK) | **PASS** |
| Launch | **PASS** (software GL) | NOT TESTED (no device) | **PASS** |
| Login and character list | **PASS**: CI end-to-end, Trainer and GM Admin | NOT TESTED | **PASS**: CI and local |
| Enter game | **PASS** | NOT TESTED | **PASS** |
| Map rendering | **PASS**: tiles and creatures received, screenshot | NOT TESTED | **PASS** |
| Movement | **PASS**: one step (`WALK OK 3332,806,6 -> 3332,807,6`) | NOT TESTED | **PASS** |
| Chat | **PASS**: own line echoed; Help and Wiki Chat channel messages received | NOT TESTED | **PASS** |
| Inventory | **PASS**: equipment slots received | NOT TESTED | **PASS** |
| Pokémon bar (display) | **PASS**: GM Admin shows `poke1=Charmander` | NOT TESTED | **PASS** |
| Summon and switch from the bar | PENDING: the CI run for commit 345b3c058 (see below) | NOT TESTED | **PASS** (local; CI pending the same commit) |
| Move bar, using a move, cooldown | PENDING (same run) | NOT TESTED | **PASS** (local: Scratch/Tackle hit a Rattata, cooldown overlay shown) |
| Pokémon Info, Pokédex, EVs, vitamins | BLOCKED: modules not ported (`LEGACY_ASSET_DEPENDENCY_MAP.md`) | BLOCKED | BLOCKED |
| Containers | NOT TESTED | NOT TESTED | NOT TESTED |
| Battle Pass, Shop, Market | BLOCKED: modules not ported | BLOCKED | BLOCKED |
| Settings persistence | NOT TESTED | NOT TESTED | NOT TESTED |
| Touch controls / UI scaling | n/a | NOT TESTED | n/a |

A previous move-test run in CI (commit e22dd9c25) failed on Linux because the move was used inside the temple's protection zone. The fix is in `tools/redemption_smoke_rc.lua` (commit 345b3c058). This section is updated when that run finishes.

### Legacy reference client (`client/`, OTClient 0.6.6 fork), for comparison

| Feature | Windows | Linux |
|---|---|---|
| Build | NOT TESTED (built on Linux only; the original Windows binaries are not evidence) | **PASS** |
| Login, enter game, gameplay | NOT TESTED | **PASS**: full harness (`FEATURE_TEST_MATRIX.md`) |

## Server matrix

| Feature | Windows | Linux |
|---|---|---|
| Server build | **PASS**: CI `windows-server.yml` (MinGW-w64 GCC, Boost) | **PASS** |
| Server startup | **PASS**: the startup log matches Linux line for line | **PASS** |
| Database connection | **PASS**: MariaDB 10.11 | **PASS** |
| Map load | **PASS**: 5879x3541 map, spawns, houses, NPCs and every script system | **PASS** |
| Player login | **PASS**: protocol smoke (run 37625226771) and the Redemption client (run 37625227955) | **PASS** |
| Wrong password refused | **PASS** (run 37625226771) | **PASS** |
| Admin commands | **PASS**: `/i` (run 37625226771); `/cb` before the end-to-end GM smoke (run 37625227955) | **PASS**: `/i`, `/cb`, `/m`, `/goto`, and the English command names with their deprecated aliases |
| Save/load | **PASS**: `/i` items saved on logout (0 → 2 apples in `player_items`) | **PASS** |
| Restart persistence | **PASS**: items still there after `/shutdown` and a restart (run 37625226771) | **PASS** |
| Clean shutdown | **PASS**: GM `/shutdown`: world saved, ports closed, process exits | **PASS**: GM `/shutdown` and `kill -QUIT` |
| Pokémon gameplay | **PASS** for summon/switch/moves once the pending run passes; Pokémon bar data **PASS** | **PASS** (Redemption smoke and legacy harness) |

## Completion status (Phase 3)

| Target | Status | Reason |
|---|---|---|
| Windows client | PARTIAL | Builds, packages, logs in, renders, walks, chats and shows the Pokémon bar against a Windows server in CI. Summon/moves pending one CI run. Not hands-on tested on a real Windows desktop with a GPU. Most PokeVerse modules are not ported yet. |
| Windows server | PASS | Build, startup, login, admin commands, save/load, restart persistence and clean shutdown all pass in CI. |
| Android client | PARTIAL | The APK builds in CI. It has never been installed or run (no device). |
| Linux client | PARTIAL | Same coverage as Windows, plus summon/switch/moves locally. Most PokeVerse modules are not ported yet. |
| Linux server | PASS | |

This table is updated as results arrive. The final values are reported in the Phase 3 final report.
