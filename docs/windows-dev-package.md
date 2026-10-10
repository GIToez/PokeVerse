# Windows development package

`PokeVerse-Windows-Dev` contains everything needed to run PokeVerse on one Windows PC:
the compiled server, the Redemption client (`client-windows\otclient.exe`), a portable MariaDB
and batch files.
No compilers or installers are needed. Everything listens on 127.0.0.1 only.

## Download

1. Open the repository's **Actions** tab, workflow **Windows dev package**.
2. Open the latest successful run and download the artifact **PokeVerse-Windows-Dev**.
3. Extract the zip, for example to `C:\PokeVerse`.

## Use

1. `Setup Database.bat` (once; safe to run again).
2. `Start Server and Client.bat`.
3. Log in with `test` / `test` (character Trainer) or `admin` / `admin` (character Admin,
   game master). Server address and port are preset to 127.0.0.1:7564.

More accounts: `Create Account.bat`, or interactively with the same file. The package's
`README.txt` explains every script, folder and common problems.

The client is the same Redemption build players get (modern layout), pointed at
127.0.0.1:7564 and without the updater. Its log is `%APPDATA%\pokeverse\pokeverse\pokeverse.log`.

## How it is built

The workflow `.github/workflows/windows-dev-package.yml` has these jobs:

| Job | What it does |
| --- | --- |
| Build server (Windows, MSYS2) | Builds `core/server` with MSYS2 MinGW-w64 (64-bit), downloads MariaDB 11.4 (Windows zip), and runs `scripts/package-windows.sh`, which copies the server with its DLLs, game data, SQL files and `scripts/windows-package/`. |
| Build Redemption client (Windows) | Builds `core/client-redemption` with MSVC and vcpkg (same cache as the Client release workflow). |
| Add the Redemption client to the dev package | Runs `scripts/assemble-redemption-client.sh --host 127.0.0.1` into `client-windows\` of the package. |
| Test package on a clean Windows runner | Downloads the artifact on a fresh runner without MSYS2 and runs `scripts/test-package-windows.py` with `PATH` limited to Windows system folders: database setup (twice), `Create Account.bat`, `Start Server.bat`, protocol tests (wrong password refused, login, character list, game login, walking), database checks (positions saved, starting items) and a client start-up check. GitHub runners have no OpenGL 2.0 driver, so if the shipped client cannot start, a copy of it is retried with Mesa's software OpenGL (CI only; Mesa is not shipped). |
| Server test (Linux) | Builds the server on Ubuntu and runs `scripts/test-server-linux.sh`. |

## Database setup order

`Setup Database.bat` runs, on 127.0.0.1:3307:

1. `00-create-database.sql` as root: database `pokeverse`, user `pokeverse`/`pokeverse`
   (local connections only).
2. `01-base-schema.sql` (the original TFS schema), only if the `accounts` table does not exist yet.
3. `10-pokeverse-extensions.sql`, `20-world-defaults.sql`, `30-account-tools.sql`,
   `40-dev-seed.sql`; all can be re-run safely.

The same files live in the repository as `core/database/*.sql` and
`core/server/schemas/{mysql,pokeverse-extensions}.sql`.

## Building locally

Windows, in an MSYS2 MINGW64 shell with the packages listed in the workflow:

```bash
cmake -S core/server -B build/server -G Ninja -DCMAKE_BUILD_TYPE=Release && cmake --build build/server
curl -fsSL -o mariadb.zip https://archive.mariadb.org/mariadb-11.4.8/winx64-packages/mariadb-11.4.8-winx64.zip
scripts/package-windows.sh build/server mariadb.zip dist
```

Then build the Redemption client (`cmake --preset windows-release` in `core/client-redemption`,
MSVC with vcpkg) and run
`scripts/assemble-redemption-client.sh --host 127.0.0.1 dist/PokeVerse-Windows-Dev/client-windows <otclient.exe and DLLs>`.

Linux (server test): build `core/server` the same way, then
`scripts/test-server-linux.sh build/server/pokeverse-server`.
