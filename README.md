# PokeVerse

PokeVerse is being rebuilt from a clean, organized foundation, starting from the original PSoul project.

## Repository layout

| Folder | Purpose |
| --- | --- |
| `references/` | Original reference projects. Read-only; copy from here, never edit in place. |
| `core/` | Our working source code: server, Redemption client, and the legacy client (no longer updated; its data and PokeVerse modules are the source the Redemption client is assembled from). |
| `builds/dev/` | Ready-to-run Windows development environment (localhost only). |
| `builds/live/` | Release packages: Linux server, Redemption clients (Windows/Linux/Android/web). |
| `docs/` | Project documentation (English). |
| `scripts/` | Build and setup automation. |

Source code lives in `core/`; compiled output lives in `builds/`. The two are never mixed.

See [`docs/project-structure.md`](docs/project-structure.md) for details and
[`docs/phase1-plan.md`](docs/phase1-plan.md) for the current roadmap.

## Play locally on Windows

Download the **PokeVerse-Windows-Dev** artifact from the latest successful
**Windows dev package** run in the Actions tab, extract it, run `Setup Database.bat`,
then `Start Server and Client.bat`. Log in with `test` / `test`.
See [`docs/windows-dev-package.md`](docs/windows-dev-package.md).

## Live server

The live server runs on OVHcloud (Ubuntu 24.04) and is deployed by the **Live server**
workflow. Players use the Redemption client from the **Client release** workflow, which connects to it.
See [`docs/live-server.md`](docs/live-server.md).

## Redemption client

The new client runs PokeVerse on the OTClient Redemption engine, for Windows, Linux and
Android, and updates itself from GitHub so players install it only once. It is the only
client that gets updates; the legacy client is no longer built or shipped.
See [`docs/phase3-redemption.md`](docs/phase3-redemption.md) and
[`docs/client-updates.md`](docs/client-updates.md).

## Cloning

Some assets are larger than 100 MB and are stored with [Git LFS](https://git-lfs.com/).
Install Git LFS before cloning:

```bash
git lfs install
git clone https://github.com/GIToez/PokeVerse.git
```
