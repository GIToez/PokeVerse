# Platform Compatibility

## Priority

| Rank | Client | Server |
|---|---|---|
| 1 (PRIMARY) | Windows x64 | Windows x64 |
| 2 (SECONDARY) | Android ARM64 | Linux x64 |
| 3 (TERTIARY) | Linux x64 | — |

Windows is the primary development and player test platform. When platforms disagree, fix Windows first, then Android, then Linux. Do not knowingly break Linux to make Windows work: there is one codebase with platform abstractions, and no per-platform gameplay code.

**Linux CI success is not proof that PokeVerse works.** A green build is build evidence only. A runtime row here is PASS only when that feature was exercised on that platform.

Statuses: **PASS**, **PARTIAL**, **FAIL**, **BLOCKED**, **NOT TESTED**.

## How each platform is tested

| Platform | Build evidence | Runtime evidence | Limits |
|---|---|---|---|
| Windows client | CI `platforms.yml` → `windows-client` (VS 2026, Release and Debug). Packaging guard. | CI launch test with software OpenGL (Mesa llvmpipe): checks only that the process stays up and takes a screenshot. Gameplay needs a Windows desktop with a GPU. | The agent environment is Linux only and cannot drive a Windows desktop. Hands-on Windows gameplay tests must be done by a person and recorded here. |
| Windows server | CI `windows-server.yml` (MSYS2 UCRT64 / MinGW-w64) | CI startup smoke against MariaDB 10.11 on the Windows runner | Player login to a Windows server needs a client connection; not automated yet |
| Android client | CI `platforms.yml` → `android-client` (arm64-v8a APK) | — | No device or emulator is available to the agent (no KVM). Install, launch and touch tests need a device. |
| Linux client | Local and CI `linux-client` builds | Local: full runtime harness (legacy client), Redemption launch. CI: Redemption launch under Xvfb. | — |
| Linux server | Local and CI `validate.yml` | Local: startup, login, full runtime harness. CI: startup and login smoke. | — |

## Client matrix (Redemption client unless noted)

| Feature | Windows | Android | Linux |
|---|---|---|---|
| Redemption build | PENDING CI (see below) | **PASS**: arm64-v8a APK built in CI (clean upstream, run 37609336370) | **PASS**: Release and Debug, local; 34/34 unit tests; Release in CI |
| Client launch | PENDING CI (software GL) | NOT TESTED | **PASS** (clean upstream: window opens, language selector shown) |
| Login | BLOCKED (protocol port pending) | BLOCKED | BLOCKED (protocol port pending; `REDEMPTION_PROTOCOL_COMPATIBILITY.md`) |
| Enter game | BLOCKED | BLOCKED | BLOCKED |
| Map rendering | BLOCKED | BLOCKED | BLOCKED |
| Movement | BLOCKED | BLOCKED | BLOCKED |
| Pokémon systems | BLOCKED | BLOCKED | BLOCKED |
| Pokémon Info | BLOCKED | BLOCKED | BLOCKED |
| EVs | BLOCKED | BLOCKED | BLOCKED |
| Vitamins | BLOCKED | BLOCKED | BLOCKED |
| Pokédex | BLOCKED | BLOCKED | BLOCKED |
| Inventory | BLOCKED | BLOCKED | BLOCKED |
| Containers | BLOCKED | BLOCKED | BLOCKED |
| Chat | BLOCKED | BLOCKED | BLOCKED |
| Battle Pass | BLOCKED | BLOCKED | BLOCKED |
| Shop | BLOCKED | BLOCKED | BLOCKED |
| Market | BLOCKED | BLOCKED | BLOCKED |
| Settings persistence | NOT TESTED | NOT TESTED | NOT TESTED |
| Touch controls / UI scaling | n/a | NOT TESTED | n/a |

### Legacy reference client (`client/`, OTClient 0.6.6 fork), for comparison

| Feature | Windows | Linux |
|---|---|---|
| Build | NOT TESTED (Phase 2 builds the legacy client on Linux only; the original Windows binaries are not used as evidence) | **PASS** |
| Login, enter game, gameplay | NOT TESTED | **PASS**: full harness (`FEATURE_TEST_MATRIX.md`) |

## Server matrix

| Feature | Windows | Linux |
|---|---|---|
| Server build | **PASS**: CI `windows-server.yml` run 37612035643 (MinGW-w64 GCC 16.2, Boost 1.92) | **PASS** |
| Server startup | **PASS**: CI startup smoke; the log matches Linux line for line | **PASS** |
| Database connection | **PASS**: MariaDB 10.11, libmariadb 3.4.9 | **PASS** |
| Map load | **PASS**: 5879x3541 map, spawns, houses, NPCs (citizens) and every script system | **PASS** |
| Player login | NOT TESTED | **PASS** |
| Pokémon gameplay | NOT TESTED | **PASS** (harness) |
| Save/load | NOT TESTED | **PASS**: logout save, then load on the next login (harness) |
| Restart persistence | NOT TESTED | PARTIAL (`BUILD_SERVER_LINUX.md`) |
| Admin commands | NOT TESTED | **PASS**: `/i`, `/cb`, `/m` (harness) |
| Clean shutdown | NOT TESTED (console handler added; `BUILD_SERVER_WINDOWS.md`) | PASS (`kill -QUIT`) |

## Completion status (Phase 3)

| Target | Status | Reason |
|---|---|---|
| Windows client | BLOCKED | Builds pending; gameplay needs the protocol port and a Windows desktop |
| Windows server | PARTIAL | Builds and starts cleanly in CI. Login, gameplay and persistence against a Windows server not yet tested. |
| Android client | BLOCKED | APK pending; needs the protocol port and a device |
| Linux client | PARTIAL | Clean Redemption builds and launches; PokeVerse login blocked on the protocol port |
| Linux server | PASS | |

This table is updated as results arrive. The final values are reported in the Phase 3 final report.
