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
| Summon from the bar | **PASS**: `SUMMON OK creature=Charmander level=15` (run 37631181970) | NOT TESTED | **PASS**: same, run 37631181970; local |
| Switch from the bar | **PASS**: `SWITCH OK creature=Bulbasaur level=15` (run 37635170266) | NOT TESTED | **PASS**: same, run 37635170266; local |
| Move bar | **PASS**: 4 moves for Charmander (run 37631181970) | NOT TESTED | **PASS** (run 37631181970; local) |
| Using a move, cooldown, damage | **PASS**: Scratch hit a GM-spawned Rattata (100% → 79%), server cooldown 6 s, cooldown overlay shown (run 37631181970) | NOT TESTED | **PASS**: Rattata 100% → 72% (run 37631181970); local |
| Pokémon Info, EV allocation and persistence | **PASS**: `INFO OPEN OK`, `EV ALLOCATE OK`, `EV FORGED REJECTED`, `EV PERSIST OK` (run 37654195191) | NOT TESTED | **PASS** (CI run 37665182290; local) |
| Pokédex (login status list, open, close) | **PASS**: `DEX LOGIN STATUS OK`, `DEX OPEN OK` (run 37654195191). `DEX INFO` was skipped in that run | NOT TESTED | **PASS**: including `DEX INFO OK` locally |
| Status bar (0xFF 14/15/16) | **PASS** (run 37654195191; the signals are injected by the test) | NOT TESTED | **PASS** |
| TM chooser | **PASS**: `TM WINDOW OK`, `TM CONFIRM OK`, `TM FORGED REJECTED` (run 37654195191) | NOT TESTED | **PASS** |
| Achievements (quest log tab) | **PASS**: `ACHIEVEMENTS OK` (run 37654195191) | NOT TESTED | **PASS** |
| HUD (trainer health, Pokémon energy and level) | NOT TESTED: added after the last green Windows run | NOT TESTED | **PASS** (CI run 37665182290; local) |
| Battle Pass | NOT TESTED (same reason) | NOT TESTED | **PASS**: open, forged collect ignored, buy refused because the season has ended (CI run 37665182290) |
| Tasks and kill popup | NOT TESTED (same reason) | NOT TESTED | **PASS**: accept, refusals, cancel in CI run 37665182290; kill progress and `POKEKILL POPUP OK` locally only |
| Crafting | NOT TESTED (same reason) | NOT TESTED | **PASS** (CI run 37665182290, GM) |
| Diamond shop | NOT TESTED (same reason) | NOT TESTED | **PASS**: forged offer refused, buy, rate limit, insufficient balance (CI run 37665182290) |
| Player market (two accounts) | NOT TESTED (same reason) | NOT TESTED | **PASS** locally (`tools/smoke_market.sh`, 2026-10-07). Added to CI, not yet run there |
| Loot strip (auto loot) | NOT TESTED (same reason) | NOT TESTED | **PASS** locally only |
| Containers | NOT TESTED | NOT TESTED | **PASS**: the craft and market tests move items out of the backpack |
| Calendar, dungeons, doll/badge case, other unported modules | BLOCKED: not ported (`REDEMPTION_MODULE_AUDIT.md`) | BLOCKED | BLOCKED |
| Settings persistence | NOT TESTED | NOT TESTED | NOT TESTED |
| Touch controls / UI scaling | n/a | NOT TESTED | n/a |

Two earlier CI runs (e22dd9c25 and cab8e69b2) failed the move step on Windows and Linux with "Your Pokemon can't use moves while you're in the protection zone": the move was used inside the starting temple. Since 345b3c058 the smoke teleports to 3325,806,6 first, and run 37631181970 passed every job.

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
| Pokémon gameplay | **PASS**: Pokémon bar data, summon, move bar, move use, cooldown and damage (run 37631181970) | **PASS** (Redemption smoke and legacy harness) |

## Windows end-to-end status (Phase 3C)

The Windows end-to-end job last passed on f2c224fe0 (run 37654195191), which covered everything up to achievements. It has failed on every run since 6f9f33d77 (run 37657786372). The causes so far:

| Runs | Cause | Fix |
|---|---|---|
| 37657786372 and later | The task-kill check and a market baseline bug in the test | Fixed in the smoke (`KNOWN_ISSUES.md`, "Fixed in Phase 3C") |
| 37665182290 and later | The GM run directly after the Trainer run logs "854 SPR/DAT did not load", with an empty `client-gm.log` | Suspected cause: settings left in the shared Windows user folder (`%APPDATA%`) by the previous run. Since 82b03e936 every run passes `--user-dir` with an empty folder of its own, and the harness logs the client's exit status. Not yet confirmed in CI |

The Windows test package job failed on a CRLF check in its own guard self-test; that is fixed (`tools/test_windows_package_guard.sh`), and it is also waiting for a CI run.

Platforms run 37669387609 has been stuck in the Linux release job since 19:02 UTC. The workflow does not cancel in-progress runs, so every newer Platforms run waits behind it and is cancelled when a newer one queues. The steps now have 30-minute timeouts and the harness force-kills a client that ignores SIGTERM, but the stuck run itself has to be cancelled by someone with write access to the repository. Otherwise GitHub stops it at its 6-hour limit.

## Completion status (Phase 3C)

| Target | Status | Reason |
|---|---|---|
| Windows client | PARTIAL | Builds and packages in CI. End-to-end in CI passed through Pokémon Info, Pokédex, status bar, TM chooser and achievements (run 37654195191). The modules added after that (HUD, Battle Pass, tasks, crafting, shop, market, loot) have not passed on Windows yet. Not hands-on tested on a Windows desktop with a GPU. |
| Windows server | PASS | Build, startup, login, admin commands, save/load, restart persistence and clean shutdown pass in CI (`windows-server.yml`). |
| Android client | PARTIAL | The APK builds in CI. It has never been installed or run (no device); `ANDROID_RUNTIME_TESTING.md` is the checklist. |
| Linux client | PARTIAL | Every ported module passes locally; CI passed through the shop (run 37665182290). Some PokeVerse modules are not ported. |
| Linux server | PASS | |
