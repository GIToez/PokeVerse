# Binary Inventory

Every non-text, non-media file in the import, classified. **Nothing was deleted.** Everything needed to run the client and server is committed: the prebuilt binaries as regular Git files, and `Tibia.spr` plus the PSD/PSB design sources through **Git LFS** (`.gitattributes`). The only files left out are compiler output, logs, IDE state and files that contain personal paths. Those stay on disk, are ignored through `.gitignore`, and can be restored from the original archive (`tools/import/fetch-pokejornadas.sh`, verified with `original/MANIFEST.sha256.tsv`).

Column meanings:

- **Required:** needed to run that component as shipped.
- **Rebuildable:** can be produced from source that is in this repository or from public upstream source.
- **Source Available:** whether the source is in the repo, upstream (public third-party project), or nowhere.
- **Commit Recommendation:** what is in Git now, with notes for later clean-up.

## Client (`client/`)

| File | Required | Rebuildable | Source Available | Commit Recommendation |
|---|---|---|---|---|
| `otclient.exe` (5.6 MB, x86) | Yes | Probably, from `client-src/` (unverified) | Yes (`client-src/`); exact revision unconfirmed | **Committed.** Replace with a source build once one is confirmed equivalent. |
| `lua5.1.dll` | Yes | Yes | Upstream (Lua 5.1) | Committed |
| `libEGL.dll`, `libGLESv2.dll` | Yes (binary links them) | Yes | Upstream (ANGLE) | Committed |
| `d3dx9_43.dll` | Yes (ANGLE dependency) | No | No (Microsoft DirectX redistributable) | Committed. Check redistribution terms before a public release. |
| `irrKlang.dll`, `ikpMP3.dll`, `ikpFlac.dll` | **No** (`otclient.exe` does not import them, and no Lua references them) | No | No (proprietary irrKlang) | Committed as shipped. Likely leftovers; candidates for removal. |
| `ex.dll` (lua-ex) | **No** (not loaded anywhere) | Yes | Upstream (lua-ex) | Committed as shipped. Candidate for removal (process-spawn capability). |
| `libtest.a`, `libtest.def` | No | — | No | Committed as shipped (build leftover) |
| `data/things/Tibia.spr` (262.5 MB) | Yes | No | No (sprite asset; encrypted) | **Committed via Git LFS** (over GitHub's 100 MB limit for regular files) |
| `data/things/Tibia.dat` (1.9 MB) | Yes | No | No | Committed |
| `data/fonts/*.otfont` + PNG | Yes | — | — | Committed |
| `data/hash.xml` (636 KB), `data/hash.xmlfile` (0 B) | Used by the updater | Yes (hash tool) | — | Committed. Regenerate whenever client files change. |
| `crashreport.log` | No | — | — | Not committed (contains a local Windows path) |

## Client source (`client-src/`)

| File | Required | Rebuildable | Source Available | Commit Recommendation |
|---|---|---|---|---|
| `src/otcicon.ico` | Yes (build resource) | — | — | Committed |

## Server (`server/`)

| File | Required | Rebuildable | Source Available | Commit Recommendation |
|---|---|---|---|---|
| `PS.exe` (7.4 MB, x86) | Yes | Probably, from `server-src/` (unverified) | Yes (`server-src/`; identical to `server-src/dev-cpp/PS.exe`) | **Committed.** Replace with a source build once one is confirmed. |
| `lua5.1.dll` | Yes | Yes | Upstream | Committed |
| `libmysql.dll` | Yes | No (vendor binary) | Upstream (MySQL Connector/C) | Committed |
| `mysql.dll` (LuaSQL MySQL driver) | Possibly | Yes | Upstream (LuaSQL) | Committed |
| `sqlite3.dll` | Yes (linked) | Yes | Upstream | Committed |
| `libxml2-2.dll`, `libxml2.dll`, `libiconv-2.dll`, `iconv.dll`, `zlib1.dll` | Yes | Yes | Upstream | Committed |
| `libeay32.dll` | Yes | Yes | Upstream (OpenSSL 0.9.8/1.0, end-of-life) | Committed. Upgrade when rebuilding. |
| `iidking-v2.01.exe` | **No** | No | No | Committed as shipped. **Do not run** (PE import injector). Candidate for removal. |
| `Large Address Aware.exe` | **No** | No | No | Committed as shipped. Candidate for removal. |
| `data/world/map.otbm` (52,345,793 bytes = 49.9 MiB) | Yes | No (map editor output) | No | Committed (regular Git). Just below GitHub's 50 MiB warning; move to LFS before frequent map edits. |
| `data/items/items.otb` (1.4 MB) | Yes | No (item editor output) | No | Committed |
| `pt_br.loc` (0.9 MB, ISO-8859 text) | Yes (localization) | — | It *is* the source | Committed |
| `poketibia.sql` | No (setup) | — | — | Committed (identical to `database/pokeaventuras.sql`) |
| `forgottenserver.map` (0 B) | No | — | — | Not committed (runtime file, recreated by the server) |
| `settings.sav` (77 B) | No | — | — | Not committed (contains a personal path) |
| `logs/` (259 files) | No | — | — | Not committed (runtime logs) |

## Server source (`server-src/`)

| File | Required | Rebuildable | Source Available | Commit Recommendation |
|---|---|---|---|---|
| `*.o` in the root (21) and `dev-cpp/obj/*.o` (87) (28.8 MB total) | No | Yes | Yes | Not committed (compiler output) |
| `dev-cpp/obj/TheForgottenServer_private.res` | No | Yes | Yes (`.rc`) | Not committed (compiler output) |
| `dev-cpp/PS.exe` | No (duplicate of `server/PS.exe`) | Yes | Yes | Committed (identical content, so Git stores it once) |
| `*.ico` (`TheForgottenServer.ico`, `dev-cpp/PS.ico`, `project/PO.ico`, …) | Yes (resource scripts reference them) | — | — | Committed |
| `*.layout` | No | — | — | Not committed (IDE state) |
| `.git/` (nested repository, 1 commit) | No | — | — | Moved to `_import/source-server.git`, not committed |

## Tools (`tools/updater-hash/`)

| File | Required | Rebuildable | Source Available | Commit Recommendation |
|---|---|---|---|---|
| `Tools/Release/Hash.exe` | Only for publishing client updates | No | **No** | Committed. Rewrite if it needs changes. |

## Design sources (`assets/design-psd/`)

| File | Required | Rebuildable | Source Available | Commit Recommendation |
|---|---|---|---|---|
| 33 `.psd`, 2 `.psb` (2.6 GB) | No (the exported PNGs are already in `client/`) | — | They *are* the sources | **Committed via Git LFS.** `.lfsconfig` excludes them from default LFS downloads; see `assets/README.md`. |
| `ENTERGAME.png` (1.1 MB) | No | — | — | Committed (regular Git) |

## Media (committed)

| Group | Count | Size | Commit Recommendation |
|---|---|---|---|
| `client/**/*.png` | 5,150 | about 70 MB | Committed |
| `client/data/sounds/**/*.ogg` | 472 | 49 MB | Committed |
| `client/data/shaders/*.frag`, particles, styles | — | about 2 MB | Committed |

## Summary

- Committed as regular Git files: all 26 shipped `.exe`/`.dll`/`.a`/`.def` files and the updater hash list (about 33 MB).
- Committed through Git LFS: `Tibia.spr` (262.5 MB) and 35 PSD/PSB files (2.6 GB), 36 LFS objects in total.
- Not committed: 109 object/resource files, 260 log files, `settings.sav`, `forgottenserver.map`, IDE metadata, two `.bak` files and `Thumbs.db`.
- No file was deleted. Everything remains in the working tree and in the original archive.
