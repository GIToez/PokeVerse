# PokeVerse

PokeVerse is an independent Pokémon MMORPG project currently based on the PokeJornadas/PSoul codebase.

> **PokeVerse is not the original PokeJornadas project**, and it is not affiliated with PokeJornadas, PSoul, PokeCenter or any of their authors. The PokeJornadas package ("poke jornadas completo + src", 2021) is only the **starting base**. It was imported as-is and has been audited and documented, but not yet modified (apart from redacting one plaintext credential). PokeVerse is also a separate project from PokeNation; the two share no code.

**Goals:** modernize the engine and client, improve the UI, and expand the gameplay systems, while keeping the strengths of the PokeJornadas base (its custom interface, Pokémon enhancement systems, dungeons, battle pass and market).

## Status

**Phase 1 (import and audit) is complete. Nothing has been built or run yet.**

| Component | Folder | Base | Source? | Notes |
|---|---|---|---|---|
| Game client | `client/runtime-data/` | OTClient 0.6.6 fork (PSoul/PokeCenter → PokeJornadas) | Lua/OTUI modules: yes | 69 modules. `Tibia.spr` via Git LFS. |
| Client source | `client/source/` | edubart/otclient 0.6.6 (C++) | Yes | Includes custom updater, PSoul protocol and asset encryption. Third-party deps not included. |
| Game server | `server/runtime-data/` | TFS 0.3.6 fork (`PS.exe`) | Lua/XML: yes | `data/lib/ps` PSoul framework, map, monsters, NPCs |
| Server source | `server/source/` | The Forgotten Server 0.3.6 (C++) | Yes | Dev-C++/MinGW, Lua 5.1, MySQL/SQLite |
| Database | `database/` | MariaDB 10.4 dump | — | 141 tables. A few tables used by scripts are missing. |
| Updater hash tool | `tools/updater-hash/` | — | **No** (binary only) | `Hash.exe` kept locally in `original/binaries/` |
| Website | — | Znote AAC implied by the schema | **Not included** | |

## Repository layout

```
PokeVerse/
├── client/
│   ├── source/        OTClient C++ source (CMake)
│   └── runtime-data/  init.lua, modules/, data/ (Tibia.dat, Tibia.spr via LFS, images, sounds…)
├── server/
│   ├── source/        TFS 0.3.6-based C++ source (CMake for Linux; original Dev-C++/autotools files kept)
│   └── runtime-data/  config.lua, data/ (scripts, XML, map, spawns, houses), pt_br.loc
├── database/          Original SQL dump + migrations/
├── build/             Compiler output (generated, ignored)
├── dist/              Runnable packages (generated, ignored)
├── tools/             Build, run, import-verification and validation scripts
├── assets/            Reserved for PokeVerse source assets
├── original/          Manifest of the original archive; binaries/ (local only, ignored)
└── docs/              Audit and verification documentation
```

## Documentation

| Document | Content |
|---|---|
| [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) | Engines, versions, lineage, component diagram |
| [docs/FEATURES.md](docs/FEATURES.md) | Gameplay systems found and how they are implemented |
| [docs/FEATURE_AUDIT.md](docs/FEATURE_AUDIT.md) | Feature-by-feature status table |
| [docs/CLIENT_UI.md](docs/CLIENT_UI.md) | Client modules and the custom interface |
| [docs/UI_AUDIT.md](docs/UI_AUDIT.md) | UI-by-UI status table |
| [docs/EXTENDED_OPCODE_MAP.md](docs/EXTENDED_OPCODE_MAP.md) | Every custom client/server message |
| [docs/DATABASE.md](docs/DATABASE.md) | Schema, custom tables, missing tables |
| [docs/BUILD_STATUS.md](docs/BUILD_STATUS.md) | Build systems and dependencies |
| [docs/SECURITY_AUDIT.md](docs/SECURITY_AUDIT.md) | Static security findings. **Read before running anything.** |
| [docs/ORIGINAL_BINARY_INVENTORY.md](docs/ORIGINAL_BINARY_INVENTORY.md) | The original binaries (kept locally, never run) |
| [docs/ORIGINAL_STRUCTURE.md](docs/ORIGINAL_STRUCTURE.md) | How the original archive was laid out and mapped into this repo |

## Cloning

The repository uses [Git LFS](https://git-lfs.com) for `client/runtime-data/data/things/Tibia.spr` (262 MB). Install Git LFS before cloning:

```bash
git lfs install
git clone https://github.com/GIToez/PokeVerse.git
```

A normal clone downloads everything needed to run the client and server, including `Tibia.spr`. The client and server are built from source (see [docs/BUILD_BASELINE.md](docs/BUILD_BASELINE.md)); the original Windows binaries are not in Git (see [docs/ORIGINAL_BINARY_INVENTORY.md](docs/ORIGINAL_BINARY_INVENTORY.md)).

Left out: compiler output, logs, IDE metadata, files containing personal paths, and the original Photoshop design sources (see [assets/README.md](assets/README.md)). The original archive can be re-downloaded and verified with `tools/import/fetch-pokejornadas.sh` and `original/MANIFEST.sha256.tsv`.

## Safety

Do not run the shipped executables on a personal machine. The client runs Lua code sent by the server, and the built-in updater downloads files over plain HTTP without signatures. See [docs/SECURITY_AUDIT.md](docs/SECURITY_AUDIT.md).

## Licensing

- The server is derived from The Forgotten Server 0.3.6, which is **GPLv3** (`server/source/doc/LICENSE`).
- The client is derived from OTClient, which is **MIT**. The license file is missing from `client/source/`.
- Pokémon and all related names are trademarks of Nintendo, Game Freak and The Pokémon Company. The game art, sprites and maps come from the PokeJornadas/PSoul community, and their provenance and licensing are **unknown**.
