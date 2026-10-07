# Original Structure

## Acquisition

| Item | Value |
|---|---|
| Source used | MediaFire primary link (`https://www.mediafire.com/file/d89t3ol1beq8129/poke+jornadas+completo+++src.rar/file`). The direct URL was resolved from the HTML page. The Mega mirror was not needed. |
| Archive | `poke jornadas completo + src.rar`, stored locally as `.downloads/pokejornadas_src.rar` (ignored by Git) |
| Size | 1,004,746,234 bytes (958.2 MB) |
| SHA-256 | `238dce875523c59bb4e065b8ea7a140bbaedd7dd84e5f74e7d4e585e5bd5bc06` |
| Format | RAR5, not solid, 7 entries, entries stored (except the SQL file). The password-protected inner zips use the same password as the RAR. |
| Tools | 7-Zip 23.01 for the zips; RARLAB `unrar` 7.12 for the RAR5-compressed SQL entry (Debian's 7-Zip build lacks the RAR codec) |
| Reproduce | `tools/import/fetch-pokejornadas.sh` |

## Archive contents (top level)

| Entry | Date | Size | Contents | Maps to |
|---|---|---|---|---|
| `Atualizando Cliente.zip` | 2022-03-13 | 97 KB | `Atualizando Cliente/Tools/Release/Hash.exe` + empty `OTClientHash/` | `tools/updater-hash/` |
| `Cliente.zip` | 2022-03-13 | 190.9 MB (427 MB unpacked) | `Cliente/`: Windows client | `client/` |
| `otclient src.zip` | 2022-03-13 | 0.76 MB | `otclient/`: client C++ source | `client-src/` |
| `pokeaventuras (1).sql` | 2020-08-01 | 224 KB | MariaDB dump | `database/pokeaventuras.sql` |
| `PSDS.zip` | 2022-03-13 | 776.6 MB (2.5 GB unpacked) | `PSDS/`: Photoshop design sources | `assets/design-psd/` (Git LFS) |
| `Servidor.zip` | 2022-03-13 | 26.1 MB (85 MB unpacked) | `Servidor/`: Windows server | `server/` |
| `Source Server.zip` | 2022-03-13 | 10.3 MB (43 MB unpacked) | `Source Server/`: server C++ source (with a `.git`) | `server-src/` |

Each zip wraps a single folder of the same name (for example `Cliente.zip → Cliente/…`). That wrapper level was dropped when mapping into PokeVerse.

## Mapping rules applied

- The original layout was **sensible**: one folder per component. So the mapping is a **1:1 rename** of each component folder. **No files were moved within a component.**
- `Source Server/.git` (a single commit, "iniciando projeto", remote `bitbucket.org/romulo_junges/pokespace-source.git`) was moved out to `_import/source-server.git` (ignored) so it does not become an embedded repository.
- `Source Server/.gitignore` (`*/*`, `!*.cpp`, `!*.h`) was deleted from `server-src/`. It would have hidden `doc/`, `mods/` and the build project files from Git. The original copy is still in `_import/extracted` and in the manifest.
- `server/poketibia.sql` is byte-identical to the root SQL file. Both are kept; Git stores the content once.
- The only content change: `server/data/XML/admin.xml` `loginpassword` was redacted to `CHANGE_ME`.
- A full copy under `original/` was **not** made, because it would duplicate about 3 GB. Instead, `original/MANIFEST.sha256.tsv` lists **every file of the original extraction** (11,934 files): original path, size and SHA-256. Use it to verify a re-extraction.

## Original tree (directories to depth 4, with file counts and sizes)

```
Atualizando Cliente/Atualizando Cliente/     (1 file, 0.3 MB)
  OTClientHash/                              (empty)
  Tools/Release/Hash.exe
Cliente/Cliente/                             (6,134 files, 407.7 MB)
  otclient.exe, init.lua, *.dll, libtest.a/.def, crashreport.log
  data/                                      (2,511 files, 351.6 MB)
    cursors/ fonts/ images/(1,879) locales/ particles/ shaders/ sounds/(472 ogg) styles/
    things/  Tibia.dat, Tibia.spr (262.5 MB), Tibia.otml, Tibia.otfi
    hash.xml, hash.xmlfile
  modules/                                   (3,610 files, 47.0 MB; 69 modules + .project/)
    client client_background client_entergame client_locales client_options client_serverlist
    client_styles client_terminal client_topmenu corelib gamelib
    game_advanceeffect game_badgecase game_battle game_bottommenu game_bugreport game_calendar
    game_chat game_combatcontrols game_console game_containers game_craft game_depotlock
    game_dollcase game_duelmessage game_dungeon game_effects game_environment game_guide
    game_healthinfo game_hotkeys game_house game_housebuy game_houseowner game_houseownerenter
    game_interface game_inventory game_lootlist game_market game_minimap game_notifications
    game_npctrade game_outfit game_pass game_playerdeath game_playertrade game_pokebar
    game_pokedex game_pokekill game_pokemonInfo game_pokemoves game_poll game_questlog
    game_ruleviolation game_shop(2,471 files, 23.6 MB) game_skills game_slotmachine
    game_statusbar game_task game_textmessage game_textwindow game_things game_time game_tips
    game_tmchoose game_tutorial game_updater game_viplist poke_create
otclient src/otclient/                       (368 files, 2.4 MB)
  CMakeLists.txt
  src/  main.cpp otcicon.*  client/(84)  framework/(267: core graphics input luaengine net otml
        platform sound sql stdext ui util xml cmake)
  tools/ gimp-bitmap-generator katepart-syntax lua-binding-generator
  vc12/  otclient.sln .vcxproj .filters
  .vscode/
PSDS/PSDS/                                   (36 files, 2,504.5 MB)
  NEW INTERFACE.psd (649 MB), PASSE DO TREINADOR.psd (570 MB), LOJA.psd (396 MB),
  POKE STATUS.psd (142 MB), MARKET.psd (101 MB), DUNGEONS.psd, DEPOT LOCK.psd, PROFISSÕES.psd,
  ACCOUNT AND CHARACTER.psd, DAILY KILL.psd, CASA.psd, ENTERGAME.psd/.png, POKEDEX.psd,
  POKEDEX-ICON.psd, POKEBOLAS.psd, TRADE NPC.psd, BOTTOMMENU.psd, BOTTOMMENU_DIAMOND.psd,
  ADDONS.psd, HOTKEYS.psd, CONFIGURAÇÕES.psd, POKÉMON SELECT.psb, EXIT.psd, FOCE EXIT.psd,
  PokeCenter - POKE SLOT.psd, BLOCK DROP.psd, MOVE ITEM AGRUPAVEL.psd, PERSONAGEM RELOAD.psd,
  dollcase.psd
  Portraits1/PORTRAITS.psd  death window/DEATH WINDOW.psb
  kit design/ (UI Elements Dark PRINCIPAL.psd, kit azul, kit amarelo.psd, GUI-Apple-Watch-Concepts-42mm.psd)
Servidor/Servidor/                           (4,804 files, 81.5 MB)
  PS.exe, *.dll, iidking-v2.01.exe, Large Address Aware.exe
  config.lua, json.lua, pt_br.loc, poketibia.sql, settings.sav, forgottenserver.map (0 bytes)
  data/                                      (4,526 files, 63.3 MB)
    .idea/ XML/ actions/ creaturescripts/ globalevents/ items/ lib/(1,859) monster/(1,176)
    movements/ npc/(1,282) raids/ spells/ talkactions/ weapons/ world/(51.1 MB)
  logs/                                      (259 files, 2.3 MB; Aug–Nov 2021)
Source Server/Source Server/                 (590 files, 40.1 MB)
  *.cpp (90) *.h (100) *.o (21) config.lua configure.ac Makefile.am autogen.sh debianfix.sh
  gui_resources.rc TheForgottenServer.ico
  .git/  dev-cpp/(Makefile.win, *.dev, *.cbp, PS.exe, obj/ 88 .o)  doc/  mods/
  make gcc fixes boost 140/  project/(PO.dev, Makefile.win)
pokeaventuras (1).sql
```

## Original → PokeVerse

| Original path | PokeVerse path | In Git? |
|---|---|---|
| `Cliente/Cliente/` | `client/` | Yes (`Tibia.spr` via Git LFS), except `crashreport.log`, `modules/.project/`, `Thumbs.db` |
| `otclient src/otclient/` | `client-src/` | Yes, except `.vscode/` |
| `Servidor/Servidor/` | `server/` | Yes, except `logs/`, `settings.sav`, `forgottenserver.map`, `data/.idea/`, `*.bak` |
| `Source Server/Source Server/` | `server-src/` | Yes, except `*.o`, `dev-cpp/obj/`, `*.res`, `*.layout`. The `.git/` was moved out. |
| `pokeaventuras (1).sql` | `database/pokeaventuras.sql` | Yes |
| `Atualizando Cliente/Atualizando Cliente/` | `tools/updater-hash/` | Yes (`Hash.exe` plus a README) |
| `PSDS/PSDS/` | `assets/design-psd/` | Yes, via Git LFS (2.6 GB, not downloaded by default). See `assets/README.md`. |
