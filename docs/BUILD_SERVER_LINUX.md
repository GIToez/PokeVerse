# Building and Running the Server on Linux

Linux is a **secondary** server platform after Windows (`PLATFORM_COMPATIBILITY.md`). It is fully supported and is where automated regression testing runs. The source is the same as on Windows (`BUILD_SERVER_WINDOWS.md`); there is no Linux-only gameplay code.

## Tested environment

| Item | Version |
|---|---|
| OS | Ubuntu 24.04.4 LTS (x86-64). The `ubuntu-24.04` image is used locally and in CI. |
| Compiler | GCC 13.3.0 (`gcc`/`g++`) |
| Build system | CMake 3.28.3 with Unix Makefiles |
| Boost | 1.83 (system, filesystem, thread, regex). The build uses `BOOST_ASIO_NO_DEPRECATED` and `BOOST_FILESYSTEM_NO_DEPRECATED`, so it also builds with Boost 1.87+. |
| Lua | 5.1.5 (`liblua5.1-0-dev`) |
| Database client | libmariadb 10.11 (`libmariadb-dev`, `libmariadb-dev-compat`). The SQLite driver is also compiled in. |
| Other | libxml2, OpenSSL 3.0, GMP 6.3, pthreads |
| Database server | MariaDB 10.11 |

## Dependencies

```bash
sudo apt-get install -y build-essential cmake pkg-config \
  libboost-system-dev libboost-filesystem-dev libboost-thread-dev libboost-regex-dev \
  libxml2-dev libssl-dev liblua5.1-0-dev lua5.1 libmariadb-dev libmariadb-dev-compat \
  libsqlite3-dev libgmp-dev mariadb-server
```

## Build

```bash
tools/build_server.sh                     # RelWithDebInfo (default)
BUILD_TYPE=Release tools/build_server.sh  # Release
BUILD_TYPE=Debug tools/build_server.sh    # Debug
```

The script runs these commands:

```bash
CC=gcc CXX=g++ cmake -S server/source -B build/server -DCMAKE_BUILD_TYPE=RelWithDebInfo
cmake --build build/server -j"$(nproc)"
install -m 0755 build/server/pokeverse-server dist/server/pokeverse-server
```

| Output | Path |
|---|---|
| Build tree | `build/server/` (git-ignored) |
| Runnable binary | `dist/server/pokeverse-server` (git-ignored) |
| Runtime data | `server/runtime-data/` (config, `data/`, map). The server runs with this as its working directory. |

## Database (DEVELOPMENT ONLY)

```bash
sudo systemctl start mariadb
tools/setup_dev_db.sh          # creates `pokeverse`, applies migrations, seeds the dev accounts
```

The dev credentials are `pokeverse` / `pokeverse-dev` on `localhost:3306`. The game accounts are `player`/`player` (Trainer) and `admin`/`admin` (GM Admin). Never use them outside a local machine.

## Run

```bash
tools/run_server.sh                                       # foreground
tools/smoke_server.sh                                     # startup test: PASS/FAIL, then stops the server
KEEP_RUNNING=1 tools/smoke_server.sh /tmp/server-run.log  # leave it running for client tests
```

The server reaches `>> Cristal server Online!` in about 60 seconds. It listens on 127.0.0.1 port 7564 (login) and port 8548 (game).

## Shutdown

| Signal | Effect |
|---|---|
| `kill -QUIT <pid>` | **Clean shutdown**: saves players and the map, then exits |
| `kill -TERM <pid>` | Shuts down services without the full save path |
| Ctrl+C (SIGINT) | Immediate exit (no handler). `smoke_server.sh` uses this, because the smoke test saves nothing. |
| `kill -HUP <pid>` | Save without stopping |

## Verified on Linux (2026-10-07)

| Check | Result |
|---|---|
| Source build (RelWithDebInfo) | PASS (local and CI) |
| Build with Boost deprecated APIs disabled | PASS |
| Startup smoke | PASS. Only the documented "Outdated MySQL" warning appears. |
| Database connection, map, NPC and script load | PASS (part of startup) |
| Player login and gameplay | PASS: login smoke plus the full runtime harness (`FEATURE_TEST_MATRIX.md`) |
| Persistence across restart | PARTIAL. After a server restart, GM Admin logged in with "Your last visit was ... on 10:18:40", which was the session before the restart, and first-login achievements were not re-awarded. Item and Pokémon state across a restart has not been checked: the harness resets the inventory on each run. |
| CI regression | `validate.yml` (build, startup, login) |

## Known Linux issues

- On shutdown the house 221 `warnings` value overflows (`KNOWN_ISSUES.md`).
- The server rewrites `data/npc/tmpCitizen_*.xml` on every start. Run `git checkout -- server/runtime-data/data/npc/` before committing.
