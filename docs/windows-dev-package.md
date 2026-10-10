# Windows development package

`PokeVerse-Windows-Dev` contains everything needed to run PokeVerse on one Windows PC:
the compiled server, the compiled legacy client, a portable MariaDB and batch files.
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

## Redemption client against the local server

The **Client release** workflow also uploads **PokeVerse-Windows-Client-Local**: the Redemption
client (modern layout) pointed at 127.0.0.1:7564, without the updater. Download it from the
same pull request, extract it next to the dev package, start the server with `Start Server.bat`
and run `otclient.exe` from the extracted folder. The legacy client in the dev package works
against the same server at the same time.

## How it is built

The workflow `.github/workflows/windows-dev-package.yml` has three jobs:

| Job | What it does |
| --- | --- |
| Build server and client (Windows, MSYS2) | Builds `core/server` and `core/client-legacy` with MSYS2 MinGW-w64 (64-bit), downloads MariaDB 11.4 (Windows zip), and runs `scripts/package-windows.sh`, which copies the executables with their DLLs, game data, SQL files and `scripts/windows-package/`. |
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
cmake -S core/client-legacy -B build/client -G Ninja -DCMAKE_BUILD_TYPE=Release -DUSE_STATIC_LIBS=OFF && cmake --build build/client
curl -fsSL -o mariadb.zip https://archive.mariadb.org/mariadb-11.4.8/winx64-packages/mariadb-11.4.8-winx64.zip
scripts/package-windows.sh build/server build/client mariadb.zip dist
```

Linux (server test): build `core/server` the same way, then
`scripts/test-server-linux.sh build/server/pokeverse-server`.
