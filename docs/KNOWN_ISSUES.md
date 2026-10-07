# Known Issues

These are open issues carried into Phase 3 and issues found during it. Phase 3 fixes an issue only if it blocks client parity, or if it is trivial, low-risk and can be tested on its own.

| # | Issue | Area | Impact | Blocks parity? | Status | Evidence |
|---|---|---|---|---|---|---|
| 1 | **Stack money, extended opcode 141.** `game_inventory/inventory.lua` sends opcode 141 (`StackingMoney`) from the "Stack money" button, but no server handler exists. | Client and server | The button does nothing | No. The legacy client behaves the same, so a Redemption port reproduces it. | Open | `EXTENDED_OPCODE_MAP.md`; no handler in `creaturescripts/scripts/opcode.lua` |
| 2 | **House owner panel, opcode 200.** `game_houseowner/houseowner.lua` handles S→C opcode 200 (`house_data\|...`), but no server Lua sends it. | Client and server | The house owner panel never fills | No (houses are NOT TESTED) | Open | `EXTENDED_OPCODE_MAP.md` |
| 3 | **`/shoppokecoin` is not registered.** The shop add-on pages (`game_shop/addons.lua`, 5 call sites) send `/shoppokecoin <offer>`, but `talkactions.xml` has no such command. | Server | Buying shop add-ons with pokécoins does nothing | No (same on the legacy client) | Open. Needs the intended purchase logic, which isn't available, so implementing it is not a trivial fix. | `COMMAND_REFERENCE.md` |
| 4 | **House 221 `warnings` overflow on shutdown.** The engine saves an uninitialized `warnings` counter for unowned house 221, and MySQL rejects `2520515808` (out of range). | Server, C++ | That one house row isn't saved at shutdown. Startup and gameplay are unaffected. | No | Open | `SERVER_STARTUP_REPORT.md` row 11 |
| 5 | **`/cb` with a lower-case Pokémon name errors.** The name check ignores case, but the `POKEMONS[...]` lookup in `getPokemonSpecialAbilities` is case-sensitive. | Server, GM tool | GMs must type `Charmander`, not `charmander` | No | Open (GM-only; workaround: proper case) | `FEATURE_TEST_MATRIX.md` |
| 6 | **`Pass.PassVersion` is undefined** (`lib/game_pass.lua:363`) | Server | None while the pass version is 1 | No | Open | `FEATURE_TEST_MATRIX.md` |
| 7 | **Harness needs a fresh server.** Wild Pokémon spawned by earlier harness runs (`/m rattata`) stay on the map and attack the test Pokémon. Recall and resummon then report "This ball is discharged." | Test tooling | False failures in `tools/runtime_test.sh` | No | Documented. Restart the server before a harness run (`CLIENT_VARIANTS.md`). | Phase 3 run 2026-10-07 |
| 8 | **No emergency save on Windows crashes.** The `__EMERGENCY_SAVE__` signal handler is POSIX-only. | Server, Windows | A crash on Windows loses unsaved progress since the last periodic save | No | Open | `BUILD_SERVER_WINDOWS.md` |
| 9 | **The server status header reads "Unknown, version Unknown (Unknown)"** (`STATUS_SERVER_NAME` etc. in `resources.h`) | Server branding | Cosmetic | No | Rebrand item (`POKEVERSE_REBRAND_AUDIT.md`) | Startup log, Linux and Windows |
| 10 | **The outdated-client message points at `http://www.psoul.net`** (`CLIENT_VERSION_STRING`) | Server branding | Wrong URL shown to outdated clients | No | Rebrand item → "TODO - POKEVERSE URL REQUIRED" | `resources.h` |
| 11 | `WARNING: attempt to destroy widget 'missionPanel' two times` | Legacy client | Harmless log noise when the Battle Pass window closes | No | Open | Harness `client-errors.log` |
| 12 | `ERROR: reach max zoom in`, `CAST ERROR ... TPoint<int>` | Legacy client | Harmless startup log noise | No | Open | `SERVER_STARTUP_REPORT.md` rows 12 and 13 |
## Fixed in Phase 3

| Issue | Fix |
|---|---|
| The server didn't build with Boost 1.87+ (removed `io_service`, `deadline_timer`, `address_v4::from_string`, `io_context::dispatch`, `to_ulong`) | Ported to `io_context`, `steady_timer`, `make_address_v4`, `boost::asio::post`/`dispatch` and `to_uint`. Deprecated Boost APIs are now compile errors on every platform. |
| The server didn't build on Windows (`MAXUINT32` macro clash, XP-era `_WIN32_WINNT`, missing Winsock libraries) | `tools.cpp` rename, `_WIN32_WINNT=0x0601`, link `ws2_32`/`mswsock` |
| The Windows server had no clean shutdown | Console control handler: Ctrl+C or closing the console saves and shuts down |
| The staged Redemption package shipped upstream's bot (`mods/game_bot`, vBot 4.8), found in the Windows Release artifact of Platforms run 37609336370 | `tools/stage_redemption.sh` drops `game_bot` and its `client_mods` load entry (the `client-redemption/` subtree stays unmodified). `tools/package_client.sh` refuses any `game_bot` directory, and `validate.py regressions` guards both. |
| Harness builds could be packaged by mistake | Separate variants plus the packaging guard (`CLIENT_VARIANTS.md`) |
