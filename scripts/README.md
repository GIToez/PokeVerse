# scripts/

Build and setup automation.

| Script | Purpose |
| --- | --- |
| `verify-references.sh` | Checks that `references/` still matches the original archive byte-for-byte. |
| `protocol-test.py` | Pure-Python game client: login, character list, game login, walking and logout against a running server. |
| `test-server-linux.sh` | Builds a throwaway MariaDB, sets up the database, starts the server and runs the protocol tests (Linux). |
| `package-windows.sh` | Assembles `PokeVerse-Windows-Dev/` from the Windows builds (runs in MSYS2, used by CI). |
| `windows-package/` | The `.bat` files and README that ship inside the Windows package. |
| `test-package-windows.py` | Tests an extracted Windows package end to end using only its own files. |
| `account-test.py` | Account manager test: create, log in, delete (or check an existing account with `--account`). |
| `package-windows-live-client.sh` | Assembles the Windows live client (`PokeVerse-Windows-Live`), pointed at the live server. |
| `windows-live-client/` | README that ships inside the Windows live client. |
| `live/` | Live server (OVH) tooling. See [`docs/live-server.md`](../docs/live-server.md). |
| `live/bootstrap-ovh.sh` | One-time server setup (run once as root on the server). |
| `live/package-linux-server.sh` | Assembles the Linux live server package. |
| `live/deploy.sh` | Runs a workflow action against the server over SSH (GitHub Actions side). |
| `live/pokeverse-ctl` | Server-side tool: deploy, health check, backup, restore, rollback, settings. |
| `live/rehearsal.sh` | CI only: full deployment rehearsal on a disposable Ubuntu 24.04 runner. |
| `live/systemd/` | systemd services (game server, Discord bot, daily backup). |
