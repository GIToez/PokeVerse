# Binary Inventory

Every non-text, non-media file in the import, classified. **Nothing was deleted.** Files marked "Do not commit" stay on disk in the working tree, are ignored through `.gitignore`, and can be restored from the original archive (`tools/import/fetch-pokejornadas.sh`, verified with `original/MANIFEST.sha256.tsv`).

Column meanings:

- **Required:** needed to run that component as shipped.
- **Rebuildable:** can be produced from source that is in this repository or from public upstream source.
- **Source Available:** whether the source is in the repo, upstream (public third-party project), or nowhere.

## Client (`client/`)

| File | Required | Rebuildable | Source Available | Commit Recommendation |
|---|---|---|---|---|
| `otclient.exe` (5.6 MB, x86) | Yes | Probably, from `client-src/` (unverified) | Yes (`client-src/`); exact revision unconfirmed | **Do not commit.** Keep as a release artifact until a source build is confirmed equivalent. |
| `lua5.1.dll` | Yes | Yes | Upstream (Lua 5.1) | Do not commit |
| `libEGL.dll`, `libGLESv2.dll` | Yes (binary links them) | Yes | Upstream (ANGLE) | Do not commit |
| `d3dx9_43.dll` | Yes (ANGLE dependency) | No | No (Microsoft DirectX redistributable) | Do not commit (redistribution terms) |
| `irrKlang.dll`, `ikpMP3.dll`, `ikpFlac.dll` | **No** (`otclient.exe` does not import them, and no Lua references them) | No | No (proprietary irrKlang) | Do not commit. Likely leftovers. |
| `ex.dll` (lua-ex) | **No** (not loaded anywhere) | Yes | Upstream (lua-ex) | Do not commit. Remove (process-spawn capability). |
| `libtest.a`, `libtest.def` | No | — | No | Do not commit (build leftover) |
| `data/things/Tibia.spr` (262.5 MB) | Yes | No | No (sprite asset; may be encrypted) | **Cannot commit** (over GitHub's 100 MB limit). Use Git LFS, a release asset, or external storage. |
| `data/things/Tibia.dat` (1.9 MB) | Yes | No | No | **Commit** (asset, small) |
| `data/fonts/*.otfont` + PNG | Yes | — | — | Commit (text plus images) |
| `data/hash.xml` (636 KB), `data/hash.xmlfile` (0 B) | No (updater cache, regenerated) | Yes (hash tool) | — | Do not commit (generated updater file) |
| `crashreport.log` | No | — | — | Do not commit (contains a local Windows path) |

## Client source (`client-src/`)

| File | Required | Rebuildable | Source Available | Commit Recommendation |
|---|---|---|---|---|
| `src/otcicon.ico` | Yes (build resource) | — | — | Commit |

## Server (`server/`)

| File | Required | Rebuildable | Source Available | Commit Recommendation |
|---|---|---|---|---|
| `PS.exe` (7.4 MB, x86) | Yes | Probably, from `server-src/` (unverified) | Yes (`server-src/`; identical to `server-src/dev-cpp/PS.exe`) | **Do not commit.** Release artifact. |
| `lua5.1.dll` | Yes | Yes | Upstream | Do not commit |
| `libmysql.dll` | Yes | No (vendor binary) | Upstream (MySQL Connector/C) | Do not commit |
| `mysql.dll` (LuaSQL MySQL driver) | Possibly | Yes | Upstream (LuaSQL) | Do not commit |
| `sqlite3.dll` | Yes (linked) | Yes | Upstream | Do not commit |
| `libxml2-2.dll`, `libxml2.dll`, `libiconv-2.dll`, `iconv.dll`, `zlib1.dll` | Yes | Yes | Upstream | Do not commit |
| `libeay32.dll` | Yes | Yes | Upstream (OpenSSL 0.9.8/1.0, end-of-life) | Do not commit |
| `iidking-v2.01.exe` | **No** | No | No | **Do not commit.** Do not run (PE import injector). |
| `Large Address Aware.exe` | **No** | No | No | Do not commit |
| `data/world/map.otbm` (52,345,793 bytes = 49.9 MiB) | Yes | No (map editor output) | No | **Commit.** Just below GitHub's 50 MiB warning. A good LFS candidate later, because every map edit adds about 50 MB to history. |
| `data/items/items.otb` (1.4 MB) | Yes | No (item editor output) | No | Commit |
| `pt_br.loc` (0.9 MB, ISO-8859 text) | Yes (localization) | — | It *is* the source | Commit |
| `poketibia.sql` | No (setup) | — | — | Commit (identical to `database/pokeaventuras.sql`) |
| `forgottenserver.map` (0 B) | No | — | — | Do not commit (runtime file) |
| `settings.sav` (77 B) | No | — | — | Do not commit (Dev-C++/launcher state with a personal path) |
| `logs/` (259 files) | No | — | — | Do not commit (runtime logs) |

## Server source (`server-src/`)

| File | Required | Rebuildable | Source Available | Commit Recommendation |
|---|---|---|---|---|
| `*.o` in the root (21) and `dev-cpp/obj/*.o` (87) (28.8 MB total) | No | Yes | Yes | Do not commit (compiler output) |
| `dev-cpp/obj/TheForgottenServer_private.res` | No | Yes | Yes (`.rc`) | Do not commit |
| `dev-cpp/PS.exe` | No (duplicate of `server/PS.exe`) | Yes | Yes | Do not commit |
| `*.ico` (`TheForgottenServer.ico`, `dev-cpp/PS.ico`, `project/PO.ico`, …) | Yes (resource scripts reference them) | — | — | Commit |
| `*.layout` | No | — | — | Do not commit (IDE state) |
| `.git/` (nested repository, 1 commit) | No | — | — | Moved to `_import/source-server.git`, not committed |

## Tools (`tools/updater-hash/`)

| File | Required | Rebuildable | Source Available | Commit Recommendation |
|---|---|---|---|---|
| `Tools/Release/Hash.exe` | No (only for publishing client updates) | No | **No** | Do not commit. Rewrite if needed. |

## Design sources (`assets/design-psd/`)

| File | Required | Rebuildable | Source Available | Commit Recommendation |
|---|---|---|---|---|
| 33 `.psd`, 2 `.psb`, 1 `.png` (2.5 GB) | No (the exported PNGs are already in `client/`) | — | They *are* the sources | **Cannot commit.** 5 files are over 100 MB. Use external storage or a dedicated LFS repository. |

## Media (committed)

| Group | Count | Size | Commit Recommendation |
|---|---|---|---|
| `client/**/*.png` | 5,150 | about 70 MB | Commit |
| `client/data/sounds/**/*.ogg` | 472 | 49 MB | Commit |
| `client/data/shaders/*.frag`, particles, styles | — | about 2 MB | Commit |

## Summary

- Native binaries **not** committed: 2 client exe/dll groups (11 files), 15 server exe/dll files, 1 tool exe, 109 object/resource files.
- Large assets not committed: `Tibia.spr` (262.5 MB) and the PSD folder (2.5 GB).
- No binary was deleted. All of them remain in the working tree and in the original archive.
