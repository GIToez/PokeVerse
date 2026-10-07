# Import Verification (Phase 2A)

**Result: the PokeJornadas import is complete.** Every file the client, server, source trees and database need is in Git and byte-identical to the original archive. The only content change is the redacted admin password. No REQUIRED file is unresolved.

Re-run at any time with `tools/verify_import.py` (exit status is non-zero if a REQUIRED file is missing or differs). Use `--tsv FILE` for a per-file report.

## Source of truth

| Item | Value |
|---|---|
| Archive | `poke jornadas completo + src.rar`, kept locally as `.downloads/pokejornadas_src.rar` (ignored) |
| Archive SHA-256 | `238dce875523c59bb4e065b8ea7a140bbaedd7dd84e5f74e7d4e585e5bd5bc06`, **re-verified** |
| Contents | `Cliente.zip`, `otclient src.zip`, `Servidor.zip`, `Source Server.zip`, `PSDS.zip`, `Atualizando Cliente.zip`, `pokeaventuras (1).sql` (all present in `_import/archive/`) |
| Manifest | `original/MANIFEST.sha256.tsv`: 11,934 files (path, size, SHA-256) from the extraction |

## Summary by category

| Category | Manifest files | Result |
|---|---|---|
| REQUIRED | 11,254 | 11,253 tracked and byte-identical; 1 intentional change (`server/runtime-data/data/XML/admin.xml`, password redacted) |
| OPTIONAL | 509 | 3 tracked (`hash.xml`, `hash.xmlfile`, an empty `.gitignore`). 277 kept locally and ignored (259 server logs, `settings.sav`, `crashreport.log`, IDE folders, 2 `.bak`, `Thumbs.db`). 229 not in the tree: the nested `Source Server/.git` (228 files, moved to `_import/source-server.git`) and its `.gitignore` (deleted because it hid source folders) |
| BUILD OUTPUT | 109 | Not tracked. Kept locally in `original/binaries/server-source/` (MinGW `.o`/`.res`) |
| ORIGINAL BINARY | 26 | Not tracked. Kept locally in `original/binaries/`, never run (see [ORIGINAL_BINARY_INVENTORY.md](ORIGINAL_BINARY_INVENTORY.md)) |
| DESIGN SOURCE | 36 | Not in the current tree (removed on request). All 36 are Git LFS objects in commit `5e2eaee`; every LFS object id equals the manifest SHA-256, and GitHub's LFS server confirmed it holds all of them |

## Components

| Component | Expected | Present | Manifest Verified | Runtime Required | Action |
|---|---|---|---|---|---|
| Client entry point | `init.lua` | Yes (`client/runtime-data/init.lua`) | Yes | REQUIRED | None |
| Client modules | 69 modules (`client`, `client_*` ×8, `corelib`, `gamelib`, `game_*` ×57, `poke_create`) plus an IDE `.project/` folder | Yes, 69 | Yes (all Lua/OTUI/images) | REQUIRED | None |
| Client data | images (1,879), fonts (30), locales (6), sounds (472 OGG), shaders (28), particles (60), cursors (5), styles (25) | Yes | Yes | REQUIRED | None |
| Client things | `Tibia.dat` (1.9 MB), `Tibia.spr` (275,213,812 B), `Tibia.otml`, `Tibia.otfi` | Yes | Yes. `Tibia.spr` is a Git LFS object (oid `e6b41b22…6d71` = manifest SHA-256), verified as real content after `git lfs pull` | REQUIRED | None |
| Client updater files | `data/hash.xml`, `hash.xmlfile` | Yes | Yes | OPTIONAL (legacy updater disabled) | None |
| Client source | `CMakeLists.txt`, `src/client` (custom protocol, PSoul opcodes, updater `game.cpp`/`download.cpp`, sprite/dat decryption), `src/framework` (core, graphics, luaengine, net, otml, platform, sound, ui, util, xml), `vc12/` project, `tools/` | Yes: 148 `.cpp`, 179 `.h` | Yes | REQUIRED (build) | None. Third-party libraries are not included (system packages are used) |
| Server datapack | `data/` with actions, creaturescripts, globalevents, items, lib (incl. `lib/ps`, `json.lua`), monster, movements, npc, raids, spells, talkactions, weapons, world, XML | Yes | Yes | REQUIRED | None |
| World map | `data/world/map.otbm` (52,345,793 B), `map-spawn.xml` (1.2 MB), `map-house.xml` (23 KB), `map-sound.xml` | Yes (regular Git; under GitHub's 100 MB limit) | Yes | REQUIRED | None |
| Server config and localization | `config.lua`, `pt_br.loc`, `json.lua` | Yes | Yes | REQUIRED | `config.lua` is later adjusted for local development (Phase 2K) |
| Server admin config | `data/XML/admin.xml` | Yes | Differs on purpose (password redacted) | REQUIRED | Hardened in Phase 2G |
| Server source | 90 `.cpp`, 100 `.h` incl. PSoul additions (partyduel, pvparena, tournament, iopoll, localization, iodatalog, ioplayerstatistics); `configure.ac`, `Makefile.am`, `autogen.sh`, `dev-cpp/*.dev`/`Makefile.win`, `.cbp`, `project/`, `doc/`, `mods/` | Yes | Yes | REQUIRED (build) | None |
| Server SQL copy | `server/runtime-data/poketibia.sql` | Yes | Yes. **Byte-identical** to `database/pokeaventuras.sql` | OPTIONAL | None |
| Database dump | `database/pokeaventuras.sql` (223,588 B, 141 `CREATE TABLE`) | Yes | Yes. Ends with `COMMIT;` and the closing `SET` statements, so it is not truncated | REQUIRED | Repairs go into `database/migrations/` (Phase 2H) |
| Updater hash tool | `Tools/Release/Hash.exe`, empty `OTClientHash/` | `Hash.exe` in `original/binaries/updater-hash/` | Yes | ORIGINAL BINARY | None |
| Original binaries | `PS.exe`, `otclient.exe`, 22 DLLs, `.a`/`.def`, `iidking-v2.01.exe`, `Large Address Aware.exe` | Yes, in `original/binaries/` (ignored) | Yes | ORIGINAL BINARY | Never run |
| Compiler output | 108 `.o`, 1 `.res` | Yes, in `original/binaries/server-source/` (ignored) | Yes | BUILD OUTPUT | Replaced by `build/` |
| Design sources | 33 `.psd`, 2 `.psb`, 1 `.png` (see below) | In Git history (`5e2eaee`) and on the LFS server, not in the working tree | Yes (LFS oid = manifest SHA-256 for all 36) | DESIGN SOURCE | Removed from the current tree on request; recoverable with `git checkout 5e2eaee -- assets/design-psd` followed by `git lfs pull` |

## Design sources (PSD/PSB)

All expected files are present as LFS objects: NEW INTERFACE, POKE STATUS, POKEDEX, POKEDEX-ICON, PASSE DO TREINADOR, LOJA, MARKET, DUNGEONS, PROFISSÕES, DAILY KILL, ACCOUNT AND CHARACTER, POKÉMON SELECT (`.psb`), PokeCenter - POKE SLOT, DEPOT LOCK, BOTTOMMENU, BOTTOMMENU_DIAMOND, HOTKEYS, TRADE NPC, ADDONS, BLOCK DROP, CASA, CONFIGURAÇÕES, ENTERGAME (`.psd` and `.png`), EXIT, FOCE EXIT, MOVE ITEM AGRUPAVEL, PERSONAGEM RELOAD, POKEBOLAS, dollcase, Portraits1/PORTRAITS, death window/DEATH WINDOW (`.psb`), and the four `kit design/` files. Per-file sizes and hashes are in [DESIGN_ASSET_AUDIT.md](DESIGN_ASSET_AUDIT.md).

## Fresh-clone check

See the "Fresh clone" section of [PHASE_2_VIABILITY_REPORT.md](PHASE_2_VIABILITY_REPORT.md): a clean clone plus `git lfs pull` was built and verified with this tool.
