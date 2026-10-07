# Phase 3 Report (status at 2026-10-07)

PokeVerse stays the game; OTClient Redemption is now its client engine, and the legacy OTClient 0.6.6 fork is the parity reference. This report covers branch `cursor/phase3-redemption-489e` (PR #3, stacked on the Phase 2 branch). Nothing is merged to `main`.

All evidence follows source → build → dist → test. The original Windows binaries from the archive were never run.

## Platform status

| Target | Status | Evidence | What is missing |
|---|---|---|---|
| Windows client | **PARTIAL** | Redemption Release and Debug build with MSVC; packaging validation; launch with software OpenGL. The CI end-to-end job logs Trainer and GM Admin in to a Windows-built server: map, walking, chat, inventory, Pokémon bar, summon, switch, move bar, a move with its server cooldown and damage (runs 37631181970, 37635170266). | Hands-on play on a Windows desktop with a GPU. Most PokeVerse modules are not ported. |
| Windows server | **PASS** | MinGW-w64 build; startup log identical to Linux; login, wrong password refused, admin commands, save on logout, persistence across `/shutdown` and restart (run 37625226771); serves the Redemption end-to-end job. | — |
| Android client | **PARTIAL** | arm64-v8a APK builds in CI with the PokeVerse assets (runs 37625227955, 37631181970). | Never installed or run: no device or emulator is available. |
| Linux client | **PARTIAL** | Same CI coverage as Windows under Xvfb against a Linux server, with the same steps passing (run 37635170266). | Most PokeVerse modules are not ported. |
| Linux server | **PASS** | Build, startup, protocol smoke, Redemption smoke, legacy runtime harness, restart persistence, clean shutdown. | — |

Details: `PLATFORM_COMPATIBILITY.md`. A Linux pass is never used in place of a Windows result.

## Work by area

| Area | Status | Where |
|---|---|---|
| Baseline and Phase 2 diff audit | Done | `PHASE_3_BASELINE.md`, `PHASE_2_DIFF_AUDIT.md` |
| Client variants (production / debug / harness) and harness guard | Done. CMake refuses bot protection off outside `harness`; the packaging guard refuses harness and debug builds, the guard variables, the bot module and the Redemption smoke script; CI checks all of it. | `CLIENT_VARIANTS.md`, `tools/package_client.sh` |
| Redemption import | Done, as a subtree (opentibiabr/otclient@396f0b3) | `REDEMPTION_BASELINE.md` |
| Redemption builds | Done on Windows (Release, Debug), Linux (Release, Debug) and Android (arm64 APK) | `BUILD_REDEMPTION.md` |
| Protocol compatibility | Done for login, game, the 854 wire extensions and the 0xFF sub-protocol, behind `GamePokeVerse`. SPR/DAT kept; no Thing ID renumbering. | `REDEMPTION_PROTOCOL_COMPATIBILITY.md` |
| Module port | Partial: `game_pokebar` and `game_pokemoves` ported and tested; the rest are mapped but not ported | `REDEMPTION_PARITY_MATRIX.md`, `LEGACY_ASSET_DEPENDENCY_MAP.md` |
| Server portability | Done: Boost.Asio port, Windows build, console shutdown handler, server exits after `/shutdown` | `BUILD_SERVER_WINDOWS.md`, `BUILD_SERVER_LINUX.md` |
| EV system | Preserved and documented; vitamin audit done | `EV_SYSTEM_CURRENT.md`, `MISSING_FROM_POKEVERSE.md` (`VITAMIN_AUDIT`) |
| Translation | Partial. Done: admin and operator text, MOTD and login message (localized per account), shutdown broadcasts, Help channel, `tournaments.xml`, 38 English command names with hidden deprecated aliases, the `pt_br.loc` CR fix. Open: the remaining player-facing server strings listed in the audit. | `TRANSLATION_AUDIT.md`, `COMMAND_REFERENCE.md` |
| Rebrand | Done from the audit: window titles, app names, server identity; unknown URLs are `TODO - POKEVERSE URL REQUIRED`; legal and upstream attribution kept. In-game Pokémon Centers are unchanged, with a regression check. | `POKEVERSE_REBRAND_AUDIT.md`, `tools/validate.py brand` |
| Tibia audit and asset map | Done | `POKEVERSE_REBRAND_AUDIT.md`, `LEGACY_ASSET_DEPENDENCY_MAP.md` |
| Known issues | Kept current | `KNOWN_ISSUES.md` |
| Regression tests | `tools/validate.py`: 18 guarded fixes, the command-alias check, the Pokémon Center check, Lua/XML/script/module checks. Runtime: protocol smoke (Linux, Windows server), Redemption smoke (Linux, Windows), legacy runtime harness (Linux). | `tools/` |
| CI | `validate.yml`, `windows-server.yml`, `platforms.yml` (Windows, Android, Linux builds; Windows and Linux end-to-end) | `.github/workflows/` |

## Fixes found along the way

- The server process never exited after a save-and-shutdown (`ServiceManager::stop` did nothing).
- The server dropped client packets until after the login database write.
- Looking at an unowned house sent a test broadcast to every player (`showbuywindowhouse`).
- On Linux every Portuguese `pt_br.loc` value kept a trailing carriage return.
- The legacy move bar listened for signal names the C++ never raises (`KNOWN_ISSUES.md` #17; fixed in the Redemption port).
- Windows CI: MSYS2 turned GM commands such as `/i` into file paths; Latin-1 log text broke `sort`.

## Not done in Phase 3

- Porting the remaining PokeVerse modules (Pokémon Info, Pokédex, Battle Pass, Shop, Market, Task, Craft, Dungeon, …). The asset map lists what each one needs.
- Hands-on Windows desktop testing and any Android device testing.
- The remaining player-facing translation items in `TRANSLATION_AUDIT.md`.
- PokeVerse art for the Redemption login screen (`KNOWN_ISSUES.md` #16).

## Future work (deliberately not implemented)

The Nation vitamin import, kill-based EVs, an asset pipeline (atlases, compression), a UI redesign, replacing the legacy updater, and any rebalance.

## Development accounts

`player`/`player` (Trainer) and `admin`/`admin` (GM Admin) exist only in the development database on 127.0.0.1 and must never reach a production database.
