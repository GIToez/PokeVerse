# references/

Original reference projects. **Never modify anything in this folder.** Copy files
into `core/` and work on the copies there.

## Projeto/ — original PSoul project

Imported from the source archive provided by the project owner
(RAR5, 277,469,662 bytes, SHA-256
`0fc400e613bdb600cfa07f8db0f4cb988f6d20c2234a73da65c0256cff066ddc`).
Every project file in the archive is included. Only the archive's own git metadata
was left out: the nested `Source Server/.git/` repository, `Client/.gitattributes`
and six `.gitignore` files (235 files in total).

| Path | Contents |
| --- | --- |
| `Projeto/PSOUL/` | Server: compiled Windows build (`PS.exe` + DLLs), `config.lua`, `data/` (scripts, monsters, NPCs, map). |
| `Projeto/PSOUL/Source Server/` | Server C++ source (The Forgotten Server 0.x based), Dev-C++ project in `dev-cpp/`, DB schemas in `schemas/`. |
| `Projeto/Client/` | Client: compiled Windows build (`Poke Aimar.exe`), `data/`, Lua `modules/`. |
| `Projeto/Sources/Source client/` | Client C++ source (OTClient based), CMake and Visual Studio 2013 (`vc12/`) projects. |
| `Projeto/RME - PSoul/` | Remere's Map Editor (binary and source) plus game-design documents (Portuguese). |

### Verifying integrity

`MANIFEST.sha256` lists the SHA-256 of every file as extracted from the original
archive. Run:

```bash
scripts/verify-references.sh
```
