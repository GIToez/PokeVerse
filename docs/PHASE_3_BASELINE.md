# Phase 3 Baseline

This is the state of PokeVerse at the start of Phase 3 (Redemption client migration). I checked it on 2026-10-07 before making any Phase 3 changes.

## Source of truth

| Item | Value |
|---|---|
| Repository | `GIToez/PokeVerse` |
| Phase 2 branch | `cursor/phase2-verify-build-test` |
| Phase 2 head commit | `590162b741434f7236f9443213939d3e6fb3ef88` ("Add PHASE_2_VIABILITY_REPORT.md (recommendation A)") |
| Phase 2 PR | [#2](https://github.com/GIToez/PokeVerse/pull/2), draft, open, base `cursor/import-pokejornadas-base-489e` |
| Import PR | [#1](https://github.com/GIToez/PokeVerse/pull/1), draft, open, base `main` |
| Import branch head | `5c183ed694d17419640f1b39c81d4daecf0b7a35` |
| `main` head | `fc8a58bd0f551088f660838469e1fa95c3c33f1d` (not merged into; Phase 2 is unmerged by policy) |
| CI on Phase 2 head | `Validate` run 37603622624: **success** (static checks, build and smoke, login smoke) |
| Phase 3 branch | `cursor/phase3-redemption-489e`, created from `590162b` |

Neither PR has been merged. Phase 3 is stacked on Phase 2.

## Re-verification on the Phase 2 head

- CI run 37603622624 on `590162b` passed. It covers static validation, the server and client builds, server startup, and the login smoke test, all from a fresh clone.
- Locally (Ubuntu 24.04, GCC 13, MariaDB 10.11), the server built from `590162b` runs with only the documented "Outdated MySQL" warning. The last harness run on this build produced the results in `FEATURE_TEST_MATRIX.md`.
- Phase 3 re-runs the harness after each client-affecting change. See `REDEMPTION_PARITY_MATRIX.md`.

## Known working (PASS at runtime)

Server build, client build, server startup, database schema, login and character list, enter game, walking, chat, speech bubbles, containers, `/i`, summon and recall, Pokémon Info, EV spend, EV reset, friendship feed and level up, held items (Dragon Fang), vitamins (Zinc), Pokédex, achievements, payload decoding. Battle Pass and calendar windows open and receive their full payloads.

## Partial

| System | What is missing |
|---|---|
| `/cb` | Lower-case names fail |
| Wild combat | Works once; spawn placement made later runs unreachable |
| Dungeons, crafting, tasks, shop, market | Only the window and its data load were exercised |
| NPC dialogue | Greeting only |
| Battle Pass, calendar | Claiming rewards not exercised |

## Untested

Catching, duels and PvP, eggs and daycare, fishing, headbutt, surf, fly and ride, houses, quests, bosses, Elite Four and events.

## Open bugs carried into Phase 3

See `KNOWN_ISSUES.md` for details and status.

1. Stack-money extended opcode 141 has no client handler.
2. House owner panel, opcode 200.
3. `/shoppokecoin` is referenced but not registered.
4. House 221 `warnings` value overflows on shutdown save.
5. `/cb` with a lower-case Pokémon name errors.
6. `Pass.PassVersion` is undefined (harmless while the version is 1).

## Phase 2 fixes that must not regress

- `getPokemonDexStorage` (Pokédex).
- `StaticText::compose` Lua stack leak (speech bubbles).
- Pokémon Info when the Pokémon is in its ball.
- Container slot reuse crash.
- Chat `Ctrl+A`.

The harness (`tools/runtime_test.sh`) exercises the first four. Phase 3 adds a static regression check for all five: `tools/validate.py regressions`, which CI runs.
