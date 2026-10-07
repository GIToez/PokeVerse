# Server Startup Report (Phase 2)

This report covers the source-built server (`dist/server/pokeverse-server`) started with `tools/run_server.sh`. It ran against the development database from `tools/setup_dev_db.sh` on Ubuntu 24.04 with MariaDB 10.11. `tools/smoke_server.sh` repeats this check, and CI runs it.

## Current result

The server reaches `>> Cristal server Online!` in about 60 seconds (most of that is loading the 5879×3541 map). It listens on 127.0.0.1:7564 (login) and 127.0.0.1:8548 (game).

The startup log contains **one** message apart from normal progress lines:

```
> WARNING: Outdated MySQL server detected, consider upgrading to a newer version.
```

That message is a SAFE WARNING (see below). No other message from startup, from logging in, or from entering the game appears in the log.

## Classification

Classes:

- **BLOCKING**: prevents start, login or play.
- **FUNCTIONAL BUG**: a feature misbehaves.
- **STALE CONTENT**: data left over from the base distribution or from removed features.
- **SAFE WARNING**: harmless.

| # | Message (first seen) | Class | Cause | Status |
|---|---|---|---|---|
| 1 | `[Warning - Event::loadScript] Cannot load script (scripts/../../lib/ps/events/spells/scripts/<Move>.lua)` ×484, followed by `Cant load spell` XML warnings ×2,453 in monster files | **BLOCKING** | `spells.xml` addresses every Pokémon move as `scripts/../../lib/...`. Windows normalizes `..` lexically, but POSIX requires `data/spells/scripts/` to exist, and it did not, so no moves loaded. | **Fixed:** added `data/spells/scripts/.gitkeep` |
| 2 | SQL error when the server stored the MOTD, which contains accented Portuguese text | **FUNCTIONAL BUG** | libmariadb defaults to utf8mb4. The tables and scripts are Latin-1, so accented text was rejected. | **Fixed:** `MYSQL_SET_CHARSET_NAME latin1` in `databasemysql.cpp` |
| 3 | `> WARNING: You cannot change the encryption to SHA1, change it back in config.lua to "md5".` | **BLOCKING** for login | The dump's `server_config.encryption` marker was 3, but the stored passwords and `config.lua` use SHA-1 (2). The server refused to reconcile them. | **Fixed:** migration `001_phase2_baseline.sql` sets the marker to 2 |
| 4 | Missing tables (`market_items`, `market_offers` with the wrong schema, `market_historic`, `dungeon_ranking`). Errors appear when the market or dungeon systems run. | **FUNCTIONAL BUG** | These tables were absent from the imported dump, or it had a TFS 1.x shape. | **Fixed:** migration created them from the columns the Lua actually queries. `tools/check_db_tables.py` reports every referenced table. |
| 5 | `> WARNING: Outdated MySQL server detected, consider upgrading to a newer version.` | **SAFE WARNING** | TFS 0.3.6 compares `mysql_get_client_version()` with 50019. libmariadb reports its own 3.x version number (e.g. 30307), so the test is meaningless. The warning only concerns a MySQL ≤ 5.0.19 reconnect bug. | Left as is; documented. `smoke_server.sh` ignores it. |
| 6 | `data/npc/tmpCitizen_*.xml` change on every start (50 files) | **SAFE WARNING** (repository hygiene) | `lib/ps/systems/027-citizens.lua` rewrites random citizen NPCs at startup. | Expected behavior. Do not commit these diffs (`git checkout -- server/runtime-data/data/npc/`). |
| 7 | `data/npc/Soya.xml` references a missing `scripts/loot.lua` | **STALE CONTENT** | A stock TFS shop NPC that is never spawned (absent from `world/map-spawn.xml`). | Left in place. `tools/validate.py` allowlists it. |
| 8 | Client side: `modules/game_dungeon/favorites.lua` is JSON, not Lua, and the client rewrites it at runtime | **STALE CONTENT** / hygiene | The dungeon module stores favorites with `io.open` in its own folder. With the `dist/client` symlinks, this writes into `client/runtime-data`. | Left as is; allowlisted in the Lua syntax check |
| 9 | Client side: `ERROR: unable to open audio device` (ALSA) | **SAFE WARNING** | No sound card on headless or CI machines | The client now skips sound when no device exists. It used to crash. |

## Login and gameplay entry

These were checked with `tools/smoke_login.sh`, by hand in the client, and in the server log:

```
Trainer has logged in.
```

- The player `player`/`player` sees the character list (Trainer, level 8, world Cristal).
- After selecting the character, the map, inventory, minimap, chat and health panels render.
- The client window title becomes `Pokémon Jornadas | Jogador: Trainer`.
- No Lua error appears on the server or the client during login.

## How to reproduce

```bash
tools/setup_dev_db.sh            # once (DEVELOPMENT ONLY)
tools/smoke_server.sh            # PASS: server online with a clean startup log
KEEP_RUNNING=1 tools/smoke_server.sh /tmp/server-run.log   # leaves the server running
DISPLAY=:1 tools/smoke_login.sh player player Trainer /tmp/server-run.log
```
