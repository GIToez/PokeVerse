# assets/

This folder is reserved for PokeVerse's own source assets.

The original PokeJornadas package also contained 36 Photoshop design sources (`PSDS.zip`, 2.6 GB: NEW INTERFACE, PASSE DO TREINADOR, LOJA, MARKET, POKE STATUS, DUNGEONS and others). They are **not part of this repository**: the exported PNGs they produced are already in `client/`, so the project does not need them. If they are ever needed, `tools/import/fetch-pokejornadas.sh` re-downloads the original package, and the files are under `_import/extracted/PSDS/PSDS/`. Their hashes are listed in `original/MANIFEST.sha256.tsv`.
