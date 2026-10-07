# Phase 2 Viability Report

**Question:** is PokeVerse (the imported PokeJornadas source) a viable, independent base for further development?

**Answer:** yes. It builds from source, starts cleanly, players can log in and play, and its core Pokémon systems work at runtime. The pipeline is SOURCE → BUILD → DIST → TEST. The original Windows binaries were never run or used as evidence.

## What was verified

| Area | Result | Evidence |
|---|---|---|
| Import integrity | Every archive file is accounted for; LFS assets present | `IMPORT_VERIFICATION.md`, `tools/verify_import.py` |
| Server build (Linux, GCC 13, Boost 1.83) | PASS | `BUILD_BASELINE.md`; CI |
| Client build (Linux, OTClient 0.6.6 fork) | PASS | `BUILD_BASELINE.md`; CI |
| Database (MariaDB) | PASS: dump, migration `001_phase2_baseline.sql`, development accounts, every referenced table present | `DATABASE.md`, `tools/check_db_tables.py` |
| Server startup | PASS: clean log, bound to 127.0.0.1 | `SERVER_STARTUP_REPORT.md`; `tools/smoke_server.sh` in CI |
| Login and entering the game | PASS for both development accounts | `tools/smoke_login.sh` (CI, Xvfb, fresh profile) |
| Gameplay systems | 24 PASS, 8 PARTIAL, 1 PASS (disabled), 1 DISABLED, 6 NOT TESTED | `FEATURE_TEST_MATRIX.md` (scripted harness plus manual) |
| Security blockers | Fixed or disabled | `SECURITY_AUDIT.md` |
| Static validation | PASS | `tools/validate.py`: Lua and XML syntax, script and module references, payload format, codec round-trip and hostile input, database tables |

## Fresh clone check

A clean `git clone` of the branch followed by `git lfs pull` was verified end to end:

- **Size.** `Tibia.spr` (LFS) is 275 MB. `.git` is 395 MB and the working tree 503 MB.
- **Validation.** `tools/validate.py` passes on the clone.
- **Builds.** `tools/build_server.sh` and `tools/build_client.sh` both succeed on the clone.
- **Completeness.** The only paths in the working copy but not in the clone are git-ignored IDE files (`.idea`).
- **CI.** CI repeats the check on every push. It found the two fresh-clone problems that a developer machine hid: the missing log directories, and the client's first-start language picker. Both are fixed.

## What Phase 2 changed

- **Build fixes.** These were minimal, with no gameplay changes (`BUILD_BASELINE.md`).
- **Security**
  - Server payloads are decoded by a data-only parser instead of `loadstring`.
  - The updater is disabled.
  - Account creation over the login protocol is compiled out.
  - The default credentials are removed.
  - The remote admin protocol is disabled (and not compiled).
- **Bugs fixed.** All were small, local fixes; none is a rebalance or redesign. The list is in `WORKING_FEATURES.md`.
  - Bugs found by audit: EV spending, the EV boost cap, Dragon Fang, Zinc, the friendship money check, and the market DELETE queries.
  - Bugs found only at runtime: the Pokédex registration failure, the Pokémon Info error, the client crash on Pokémon speech, the container crash and the chat error.
- **Tooling**
  - Validation script, startup smoke test and login smoke test.
  - The scripted runtime harness (`tools/runtime_test.sh`).
  - The CI workflow `validate.yml`.
- **Out of scope.** No gameplay development, UI redesign, rebalancing, translation or PokeNation code.

## Risks and open items

1. **Untested systems.** Duels, PvP and tournaments, eggs, houses, quests, bosses and events were not exercised (`FEATURE_TEST_MATRIX.md`). Catching has not been exercised end to end. The harness never had a fresh corpse to throw the ball at.
2. **Known open bugs.** All are small (`WORKING_FEATURES.md` → BROKEN):
   - the stack-money opcode has no handler;
   - the house owner panel has no sender;
   - `/shoppokecoin` is unregistered;
   - house 221's `warnings` value fails to save on shutdown;
   - `/cb` treats Pokémon names case-sensitively.
3. **Stale content.** The Battle Pass season and calendar are configured for 2021.
4. **Engine age.** TFS 0.3.6 and OTClient 0.6.6, built with many deprecation warnings. Known engine fixes exist in PokeNation (BUG-68 login challenge, BUG-72 shutdown) and should be ported per fix in a later, explicit phase (`MISSING_FROM_POKEVERSE.md`).
5. **Windows.** The Windows builds are no longer maintained or tested.
6. **Smaller map.** PokeVerse has the Jornadas map, which is smaller than PokeNation's PSoul world (`MAP_AUDIT.md`).

## Recommendation

No doc in this repository records the spec's exact wording for the options, so here is how I applied them:

- **A:** continue with PokeVerse as an independent, working base.
- **B:** usable only after substantial stabilization or porting work.
- **C:** not viable as a base.

**Recommendation: A. Continue with PokeVerse as an independent base.**

The baseline builds, runs, passes CI and plays. Every blocker found was small and local, and was fixed without touching game design. The open items above are small or are untested features, not structural problems.

Suggested order for the next phase:

1. Extend the runtime harness to cover catching, duels (two clients), a dungeon run, a craft, a task and a market trade.
2. Fix the small open bugs listed above.
3. Port the PokeNation engine fixes one at a time (BUG-68 first, for security), each with its own test.
