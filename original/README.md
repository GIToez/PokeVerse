# original/

A full copy of the original extracted PokeJornadas package is **not** kept here, because it would add about 3 GB, mostly duplicating `client/runtime-data/`, `server/runtime-data/`, `server/source/`, `client/source/` and `database/`.

Instead:

- `MANIFEST.sha256.tsv` lists every file from the original extraction (11,934 files) with its original path, size and SHA-256. Paths are relative to the extraction root, which holds one folder per inner zip plus the SQL file (for example `Cliente/Cliente/otclient.exe`).
- `../docs/ORIGINAL_STRUCTURE.md` describes the archive and how each original folder maps into this repository.
- `../tools/import/fetch-pokejornadas.sh` re-downloads, verifies and extracts the original archive into `_import/` (ignored by Git).
