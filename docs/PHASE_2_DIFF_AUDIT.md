# Phase 2 Diff Audit

**Question.** Why is the Phase 2 diff ([PR #2](https://github.com/GIToez/PokeVerse/pull/2)) so large, and is any of it accidental?

**Verdict: EXPECTED.** Nearly all of the diff is a directory restructure where file contents are unchanged. The real code changes are small and each one maps to a documented Phase 2 fix. I found no line-ending churn, mode-bit churn, generated files, LFS pointer swaps or binaries added to Git. No cleanup commit is needed.

## Raw numbers

The diff runs from `5c183ed` (the import branch) to `590162b` (the Phase 2 head).

| Measure | Value |
|---|---|
| Files, with rename detection (`git diff -M --shortstat`) | 11,329 files, +3,724 / −307 lines |
| Files, without rename detection (`--no-renames`) | 22,584 files, +981,043 / −977,626 lines |
| Renames | 11,255, of which 11,213 are R100 (identical content) |
| Added | 31 |
| Deleted | 28 |
| Modified in place | 15 |
| Mode-only changes | 0 |

Without rename detection, GitHub's view counts every moved file twice, once as a deletion and once as an addition. That double counting is where the "~1M lines" figure comes from.

## Where the renames come from

The Phase 2 layout separates source from runtime data (`ARCHITECTURE.md`):

| From | To | Files |
|---|---|---|
| `client/modules/…` | `client/runtime-data/modules/…` | 3,536 |
| `server/data/…` | `server/runtime-data/data/…` | 2,630 |
| `client/data/…` | `client/runtime-data/data/…` | 2,203 |
| `client-src/src/…` | `client/source/src/…` | 354 |
| `server-src/…` | `server/source/…` | rest |

## Classification

| Group | Count | Class | Reason |
|---|---|---|---|
| R100 renames (layout) | 11,213 | EXPECTED | Identical content, moved to the documented layout |
| R<100 renames | ~42 | EXPECTED | The Phase 2 fixes landed in moved files. Examples: `table.lua` (R065, data-only payload parser), `crypt.cpp` (R087), `resourcemanager.cpp` (R090), `statictext.cpp`, `containers.lua`, `pokemon.lua`, `game_pokemonInfo.lua`, `game_market.lua`, `chat.lua` |
| Deleted Windows binaries and DLLs | most of the 28 | EXPECTED | Moved out of Git to the ignored `original/binaries/` (`ORIGINAL_BINARY_INVENTORY.md`). Never run. |
| Deleted `docs/BINARY_INVENTORY.md` | 1 | EXPECTED | Superseded by `ORIGINAL_BINARY_INVENTORY.md` |
| Deleted `server/data/XML/admin.xml` | 1 | EXPECTED | Recreated under `runtime-data` with secrets removed (`SECURITY_AUDIT.md`) |
| Added tools, docs, migration, CI | 31 | EXPECTED | `tools/*.sh`, `tools/validate.py`, the runtime harness, `database/migrations/001_phase2_baseline.sql`, `.github/workflows/validate.yml`, Phase 2 docs, `data/spells/scripts/.gitkeep` |
| Modified in place | 15 | EXPECTED | README, `.gitignore`, docs, config hardening |
| Line-ending churn | 0 | — | With `git diff -M --shortstat --ignore-cr-at-eol` the totals are +3,723 / −306, a difference of one line (one edited line whose ending changed). CRLF files such as `statictext.cpp` and `game_pokemonInfo.lua` were edited byte-wise. |
| Accidental files (build output, logs, `tmpCitizen_*.xml`, `settings.sav`) | 0 | — | All are git-ignored or restored before commit |

## Reviewing the real changes

To see only content changes, hiding the moves:

```bash
git diff -M --diff-filter=RM 5c183ed 590162b -- . ':!*.png' | less   # renamed-with-edits plus modified
git diff -M --diff-filter=R --stat 5c183ed 590162b | grep -v '=>.*| *0$'
```

## Conclusion

Nothing to clean up. Reverting the restructure would cause another ~11k renames and would discard no noise. The legitimate Phase 2 fixes are all kept.
