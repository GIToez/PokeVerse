# assets/

## design-psd/ (not committed)

These are the Photoshop sources for the PokeJornadas interface, from the original `PSDS.zip`: 36 files, 2.5 GB. Several files are larger than GitHub's 100 MB per-file limit (`NEW INTERFACE.psd` 649 MB, `PASSE DO TREINADOR.psd` 570 MB, `LOJA.psd` 396 MB, `POKE STATUS.psd` 142 MB, `MARKET.psd` 101 MB). The whole folder is therefore ignored by Git.

To restore it locally, run `tools/import/fetch-pokejornadas.sh` and copy `_import/extracted/PSDS/PSDS/` to `assets/design-psd/`.

Options for sharing these later: Git LFS (it would need about 2.5 GB of LFS storage and bandwidth), a separate design-assets repository with LFS, or external storage (Drive, S3, release assets).

| File | Size | Covers |
|---|---|---|
| NEW INTERFACE.psd | 649 MB | Overall new in-game interface |
| PASSE DO TREINADOR.psd | 570 MB | Battle pass ("Trainer Pass") |
| LOJA.psd | 396 MB | Game shop |
| POKE STATUS.psd | 142 MB | Pokémon status / info window |
| MARKET.psd | 101 MB | Market |
| DUNGEONS.psd | 88 MB | Dungeon UI |
| DEPOT LOCK.psd | 82 MB | Depot password lock |
| PROFISSÕES.psd | 80 MB | Professions / crafting |
| ACCOUNT AND CHARACTER.psd | 71 MB | Login and character list |
| DAILY KILL.psd | 71 MB | Daily kill task |
| kit design/ (4 files) | 72 MB | UI kits (dark, blue, yellow) and a reference mockup |
| PORTRAITS.psd | 23 MB | Pokémon portraits |
| CASA.psd | 22 MB | Houses |
| ENTERGAME.psd / .png | 20 MB | Login screen |
| POKEDEX.psd, POKEDEX-ICON.psd | 16 MB | Pokédex |
| POKEBOLAS.psd | 12 MB | Pokéballs |
| TRADE NPC.psd | 11 MB | NPC trade |
| BOTTOMMENU.psd, BOTTOMMENU_DIAMOND.psd | 11 MB | Bottom menu |
| ADDONS, HOTKEYS, CONFIGURAÇÕES, POKÉMON SELECT, EXIT, FOCE EXIT, POKE SLOT, BLOCK DROP, MOVE ITEM AGRUPAVEL, PERSONAGEM RELOAD, dollcase, DEATH WINDOW | under 10 MB each | Smaller windows and dialogs |
