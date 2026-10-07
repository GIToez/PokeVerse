# Phase 3C Report (status at 2026-10-07)

Phase 3C brings the Redemption client close to PokeVerse feature parity and packages it for testing on a real Windows PC. This report covers branch `cursor/phase3-redemption-489e` (PR #3). Nothing is merged to `main`.

All evidence follows source → build → dist → test. The original Windows binaries were never run. Statuses: **PASS**, **PARTIAL**, **FAIL**, **BLOCKED**, **NOT TESTED**. A Linux result never stands in for a Windows one.

## Acceptance summary

| Item | Status | Evidence / reason |
|---|---|---|
| Windows test package (`PokeVerse.exe`, `PokeVerseServer.exe`, database `.bat`, launch `.bat`, README) | **PARTIAL** | `tools/package_windows.sh` and `packaging/windows/` assemble it, and `tools/validate_windows_package.sh` checks it (no harness, no bot module, CRLF batch files, required tables). The CI package job has not passed yet: its last failure was the guard self-test's own LF file, which is fixed, and the rerun is queued behind a stuck run (below). Not tried on a real Windows PC |
| Windows client | **PARTIAL** | CI end-to-end passed through Pokémon Info, Pokédex, status bar, TM chooser and achievements (run 37654195191). The Windows end-to-end job has failed since 6f9f33d77; the fixes for the known causes are pushed but not yet run in CI |
| Windows server | **PASS** | `windows-server.yml` passes on every push (latest 37678137314, on 82b03e936) |
| Android client | **PARTIAL** | The APK builds. It has never been installed or run (no device or emulator) |
| Linux client | **PARTIAL** | Every ported module passes locally; CI passed through the shop (run 37665182290). Some modules are not ported |
| Linux server | **PASS** | Build, startup, protocol smoke (now with the challenge and language checks), Redemption smokes, legacy harness |
| Module port (§ port order) | **PARTIAL** | 15 PokeVerse modules ported and tested; 17 legacy modules not ported (`REDEMPTION_MODULE_AUDIT.md`) |
| Shop security | **PASS** (local) | Server-owned prices and balance, forged offers refused, rate limit, refunds (`SECURITY_AUDIT.md`, Phase 3C) |
| Market (ext opcode 64, two accounts) | **PASS** (local) | `tools/smoke_market.sh`: list, buy, sell, cancel, make/accept offer, offers to me, history, forged requests, 16 database checks. Refuse and the physical market tile are NOT TESTED. Added to Linux CI, not yet run there |
| Translations (§15) | **PARTIAL** | English canonical, Portuguese kept with the picker; baked Portuguese market art remains (`TRANSLATION_AUDIT.md` §6) |
| PokeNation fixes (§33) | **PASS** | BUG-08 (language) and BUG-68 (login challenge) fixed with PokeVerse's own changes and tested; BUG-57 fixed in the Redemption TM chooser; BUG-75 does not apply (`KNOWN_ISSUES.md`) |
| Pokémon Center terms | **PASS** | `tools/validate.py brand` regression check unchanged |
| Hands-on Windows desktop play | **NOT TESTED** | Needs a person with a Windows PC: `WINDOWS_HANDS_ON_TESTING.md` |
| Android device play | **NOT TESTED** | `ANDROID_RUNTIME_TESTING.md` |

## Modules ported in Phase 3C

Each line is a hard check in `tools/smoke_redemption_login.sh` (GM Admin and Trainer) or `tools/smoke_market.sh`. "Local" means Linux runs on 2026-10-07.

| Module | Linux | Windows |
|---|---|---|
| Pokémon Info, EV allocation and persistence | PASS (CI, local) | PASS (CI run 37654195191) |
| Pokédex (login status list, open, info) | PASS (CI, local) | PASS (CI run 37654195191; info step skipped there) |
| Status bar | PASS (signals injected) | PASS (CI run 37654195191) |
| TM chooser | PASS | PASS (CI run 37654195191) |
| Achievements | PASS | PASS (CI run 37654195191) |
| HUD | PASS (CI, local) | NOT TESTED |
| Battle Pass (season ended: buying refused, collect forging ignored) | PASS (CI, local) | NOT TESTED |
| Tasks and kill popup | PASS (CI for tasks; popup local) | NOT TESTED |
| Crafting | PASS (CI, local) | NOT TESTED |
| Diamond shop | PASS (CI, local) | NOT TESTED |
| Player market | PASS (local) | NOT TESTED |
| Loot strip (auto loot) | PASS (local) | NOT TESTED |

The Battle Pass season in the data ended in 2021 (`lib/game_pass.lua`), so purchases are refused by design. A new season is a content task, not a port.

## PokeNation fixes checked (§33)

| PokeNation bug | In PokeVerse? | Result |
|---|---|---|
| BUG-08: an out-of-range login language byte was stored and later dereferenced a missing translation table | Yes: any client could crash the server | Fixed in `protocollogin.cpp`, `iologindata.cpp`, `localization.cpp`/`.h`, `luascript.cpp`. `tools/protocol_smoke.sh`: byte 99 is ignored, and a stored `lang_id = 7` logs in and plays |
| BUG-68: the echoed game-login challenge was skipped | Yes | Fixed in `protocolgame.cpp`/`.h`; wire bytes unchanged. Protocol smoke: a forged echo is refused and logged. The Redemption, legacy and Python clients still log in |
| BUG-57: the TM chooser connected instead of disconnecting on terminate | Legacy client only | The Redemption port disconnects |
| BUG-59/60: U16 counts | — | Redemption reads them as U16 (`gamelib/pokeverse.lua`) |
| BUG-75: jump assert `delay >= 0` | No | The Redemption Debug build did not assert in 300 jumps (`std::max<double>`); the legacy build has `-DNDEBUG` |

## CI status

- Validate and Windows server pass on every push.
- Platforms (Windows, Android and Linux client builds, the Windows package job, and the Windows and Linux end-to-end jobs) has not completed since run 37669387609 got stuck in the Linux release job at 19:02 UTC. The workflow does not cancel in-progress runs, so every newer run waits behind it. **Someone with write access needs to cancel run 37669387609**; otherwise GitHub stops it at its 6-hour limit.
- Steps that could hang now have 30-minute timeouts, and the harness force-kills a client that ignores SIGTERM.
- The Windows end-to-end failures since 6f9f33d77 had three causes: the task-kill check, a market baseline bug (both fixed), and the GM run after the Trainer run failing to load SPR/DAT with an empty log. The last one is unconfirmed; the suspected cause, the shared `%APPDATA%` settings folder, is removed by `--user-dir` (82b03e936), and the harness now logs the client's exit status.

## Not done in Phase 3C

- Unported modules: calendar, dungeons, depot lock, doll and badge cases, slot machine, tips and guide, level-up effects, houses, poll, clock, duel message, ambient environment, account creation (`KNOWN_ISSUES.md` #15).
- Market refuse and the physical market tile (`KNOWN_ISSUES.md` #22, #23).
- Redrawn English market art (#20).
- Kill-based EV training (deliberately not implemented), SPR/DAT replacement (kept).
- Any run on a real Windows desktop or Android device.

## Documents

`BUILD_WINDOWS.md`, `BUILD_SERVER_WINDOWS.md`, `WINDOWS_HANDS_ON_TESTING.md`, `ANDROID_RUNTIME_TESTING.md`, `PLATFORM_COMPATIBILITY.md`, `REDEMPTION_MODULE_AUDIT.md`, `REDEMPTION_PARITY_MATRIX.md`, `SECURITY_AUDIT.md`, `TRANSLATION_AUDIT.md`, `KNOWN_ISSUES.md`.
