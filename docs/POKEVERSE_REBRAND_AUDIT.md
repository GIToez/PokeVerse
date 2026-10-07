# PokeVerse rebrand audit

This is a read-only audit of old-project branding in the repository. **No file was changed.** It lists every place where the names of the old projects (PokeJornadas, PSoul, PokeCenter, Pokenordic and others) or of the engines (OTClient, The Forgotten Server, OpenTibia, Tibia) appear, and assigns each one a class:

| Class | Meaning |
|---|---|
| RENAME TO POKEVERSE | Old project/app identity. Replace with PokeVerse. Old website URLs and e-mails become the literal text `TODO - POKEVERSE URL REQUIRED`. |
| KEEP - GAMEPLAY TERM | In-game term, mainly the Pokémon Center building, Nurse Joy, heal/depot locations. Must not be renamed. |
| KEEP - UPSTREAM ENGINE | OTClient / TFS / OpenTibia / PSoul-fork engine identifiers, comments, build targets, upstream Redemption content. |
| KEEP - LEGAL | Licence, copyright, AUTHORS, author attribution, trademark or non-affiliation notices. |
| KEEP - COMPATIBILITY | Asset file names (`Tibia.spr`, `Tibia.dat`), protocol identifiers, database/file names other tools depend on. |
| KEEP - HISTORICAL | Text describing the import history or the original data. |
| MANUAL REVIEW | Needs a product decision (reason given). |

**Method.** Every tracked file plus untracked, non-ignored files (`git ls-files -co --exclude-standard`) was scanned byte by byte with case-insensitive regexes, so Latin-1 files were matched too (`Pok\xe9mon`). Binary files (`.png`, `.spr`, `.dat`, `.otbm`, `.otb`, `.ogg`, `.dll`, …) were skipped; branding images were opened and inspected individually. Line numbers are 1-based and refer to the working tree at commit `570e2ff7e`. Items that could not be fully checked are marked **UNVERIFIED**.

**Encoding warning for whoever applies the edits.** Many target files are ISO-8859-1 / Windows-1252, often with CRLF line endings: `client/runtime-data/init.lua`, `modules/client/client.lua`, `modules/client_background/background.lua`, `data/locales/pt.lua`, `modules/game_tutorial/content/pt/*.lua`, `modules/poke_create/create.lua`, `server/runtime-data/config.lua`, `pt_br.loc`, `data/lib/ps/config/002-wikiChat.lua`, `data/lib/ps/events/globalevents/globalMessages.lua`, `data/creaturescripts/scripts/login.lua`. Edit them byte-preserving (do not save them as UTF-8), or accented text such as `Pokémon` and `não` will be corrupted in game.

**Localization coupling.** The server translates player text with `__L(cid, "<English text>")`, which looks the English string up verbatim as the key in `server/runtime-data/pt_br.loc` (`server/source/localization.cpp:295-312`, format `english@portuguese`). When an English string is renamed in Lua/XML, the matching `pt_br.loc` key **and** its Portuguese value must be changed to the identical text, or Portuguese players get the untranslated English line. The legacy client works the same way with `tr("...")` and `data/locales/pt.lua`.

---

## 1. Summary counts

### 1.1 Per search term (occurrences)

Area columns: Legacy client = `client/` (source and runtime-data); Redemption = `client-redemption/`; Root = `README.md`, `.github/`, `.gitignore`, `.gitattributes`; Original = `original/` and `assets/`.

| Term (regex, case-insensitive) | Total | Files | Legacy client | Redemption | server/source | server/runtime-data | database | tools | docs | Root | Original |
|---|---|---|---|---|---|---|---|---|---|---|---|
| PokeJornadas (`poke[ _-]?jornadas`) | 49 | 25 | 4 | 0 | 0 | 0 | 1 | 4 | 25 | 10 | 5 |
| Pokémon Jornadas (`pok(e\|é\|\xe9)mon jornadas`) | 3 | 3 | 2 | 0 | 0 | 0 | 0 | 0 | 1 | 0 | 0 |
| Jornadas (any form, superset of the two rows above) | 89 | 32 | 6 | 1 | 0 | 0 | 2 | 6 | 59 | 10 | 5 |
| PSoul (`p[ _-]?soul`, includes `PSoulXxx` identifiers) | 207 | 77 | 47 | 0 | 4 | 85 | 0 | 0 | 65 | 6 | 0 |
| PokeSoul | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| psoul.net | 19 | 8 | 1 | 0 | 1 | 14 | 0 | 0 | 3 | 0 | 0 |
| Nordic SOUL | 1 | 1 | 0 | 0 | 0 | 0 | 0 | 0 | 1 | 0 | 0 |
| PokeCenter / Pokecenter / Poke Center | 44 | 17 | 4 | 0 | 0 | 21 | 0 | 2 | 14 | 2 | 1 |
| Pokémon Center (incl. `pokemon_center_0N` sound ids) | 1178 | 32 | 1096 | 0 | 0 | 76 | 0 | 0 | 4 | 0 | 2 |
| PokeNation | 42 | 5 | 0 | 0 | 0 | 0 | 0 | 0 | 41 | 1 | 0 |
| Tibia (any, incl. OpenTibia, tibian, Tibia.spr) | 653 | 323 | 34 | 260 | 257 | 38 | 1 | 0 | 51 | 7 | 5 |
| poketibia | 19 | 14 | 5 | 0 | 0 | 1 | 1 | 0 | 11 | 0 | 1 |
| OTClient / otclient | 3124 | 934 | 836 | 1386 | 43 | 6 | 0 | 16 | 87 | 9 | 741 |
| The Forgotten Server | 824 | 53 | 0 | 5 | 792 | 1 | 0 | 1 | 9 | 3 | 13 |
| TFS (whole word) | 58 | 25 | 0 | 19 | 11 | 4 | 1 | 2 | 18 | 2 | 1 |
| OpenTibia | 270 | 208 | 1 | 26 | 238 | 0 | 0 | 0 | 5 | 0 | 0 |
| pokeaventuras | 26 | 14 | 0 | 0 | 0 | 0 | 2 | 6 | 17 | 0 | 1 |

Additional old brands found that were not in the requested term list (all included in the tables below):

| Term | Where | Occurrences |
|---|---|---|
| Pokenordic / pokenordic.com | `server/runtime-data/data/creaturescripts/scripts/login.lua:70`, `data/lib/ps/events/creaturescripts/onJoinChannel.lua:85` (×2), `docs/SECURITY_AUDIT.md:106` | 4 |
| pokezring.net | `client/runtime-data/modules/poke_create/create.lua:222` | 1 |
| Pokemon Genesis World | `database/pokeaventuras.sql:3187-3188`, `server/runtime-data/poketibia.sql:3187-3188` | 4 |
| pokezworld.com.br, fairytailon.com.br, facebook.com/systemyart | `website:` lines in 10 legacy `.otmod` files (author attribution) | 10 |
| "Nordico SOUL" | `server/runtime-data/settings.sav` (git-ignored, not tracked; Windows path `C:\Users\…\01 Nordico SOUL\server\PS.exe`) | 1 |

False positives excluded from the rename lists: `Deepsoul` (a quest stone, 30+ hits in quest Lua, `quests.xml:1028`, `pt_br.loc`) matches `p ?soul` but is a gameplay item; the Portuguese word "jornada(s)" ("journey") in `client-redemption/data/locales/pt.lua:57`, `professorTommy.lua` and `login.lua:49`.

### 1.2 Per class

Counted as rows of the tables in section 2 (4 rows carry a split class such as `KEEP - LEGAL (headers) / KEEP - UPSTREAM ENGINE (rest)`; they are counted under each class they name, shown as "+N split"). Several rows aggregate many occurrences (the occurrence column gives the approximate number each class covers).

| Class | Rows | Occurrences covered (approx.) |
|---|---|---|
| RENAME TO POKEVERSE | 52 | ~100 |
| KEEP - GAMEPLAY TERM | 1 aggregate row (+ the full list in section 3) | ~1,250 (all Pokémon Center / Centro Pokémon / Nurse Joy hits) |
| KEEP - UPSTREAM ENGINE | 19 (+4 split) | ~3,900 (OTClient, TFS, OpenTibia, upstream Redemption content) |
| KEEP - LEGAL | 4 (+3 split) | ~1,000 (copyright/licence headers, otmod `author:`/`website:`, README notices) |
| KEEP - COMPATIBILITY | 6 (+1 split) | ~90 (asset names, protocol enums, DB file name) |
| KEEP - HISTORICAL | 14 | ~1,150 (docs, `original/`, import tools, DB comments, commented-out code) |
| MANUAL REVIEW | 14 | ~60 |

---

## 2. Findings by area

Columns: **UF** = user-facing (shown to a player or end user).

### 2.1 Legacy client (`client/source`, `client/runtime-data`)

| Term | File:line | Context | UF | Class | Recommended action / new text | Notes |
|---|---|---|---|---|---|---|
| PokeCenter | `client/source/src/main.cpp:86` | `g_app.setName("Pokecenter");` | Y | RENAME TO POKEVERSE | `g_app.setName("PokeVerse");` | App name. Appears in the crash report header (`app name: …`, `framework/platform/*crashhandler.cpp`), the terminal (`client_terminal/commands.lua:157`) and the startup log line (`init.lua:20`). Needs a client rebuild. |
| PokeCenter | `client/source/src/main.cpp:87` | `g_app.setCompactName("Pokecenter");` | Y | RENAME TO POKEVERSE | `g_app.setCompactName("pokeverse");` | **Compatibility impact.** The compact name is the settings directory (`init.lua:13` → `ResourceManager::setupUserWriteDir`: Linux `~/.Pokecenter`, Windows `<PHYSFS user dir>\Pokecenter`, exact Windows path UNVERIFIED) and the log file name (`init.lua:16`, `Pokecenter.log`). Renaming loses existing `config.otml` (saved login, locale, window size, hotkeys) and minimap files unless they are migrated, e.g. copy `~/.Pokecenter/*` to the new directory on first start. `tools/smoke_login.sh:26`, `tools/runtime_test.sh:14` and `docs/BUILD_BASELINE.md:60` must change in the same commit. |
| Pokémon Jornadas | `client/runtime-data/modules/client/client.lua:85` | `g_window.setTitle("Pokémon Jornadas")` | Y | RENAME TO POKEVERSE | `g_window.setTitle("PokeVerse")` | Login-screen window title. Latin-1 file. **`tools/smoke_login.sh:40` finds the window with `xdotool search --name "Jornadas"`; change it in the same commit or the smoke and runtime tests fail.** |
| Pokémon Jornadas | `client/runtime-data/modules/client_background/background.lua:38` | `g_window.setTitle("Pokémon Jornadas \| Jogador: "..name)` | Y | RENAME TO POKEVERSE | `g_window.setTitle("PokeVerse \| Jogador: "..name)` | In-game window title. Same xdotool dependency. |
| PokeJornadas, poketibia | `client/runtime-data/init.lua:9` | `g_logger.fatal("… Equipe PokeJornadas BRAZIL - Contato: contato(a)pokejornadas.com - Pokémon Online - PokeTibia")` | Y | RENAME TO POKEVERSE | `… Equipe PokeVerse - Contato: TODO - POKEVERSE URL REQUIRED - Pokémon Online` | Fatal dialog shown when anti-cheat files are detected. The e-mail is treated like a URL. Dropping "PokeTibia" is optional. |
| (logo image) | `client/runtime-data/modules/client_entergame/images/logo.png` | Image reads "POKÉMON JORNADAS" (245×99, used by `entergame.otui:11-13` `LogoServ`) | Y | RENAME TO POKEVERSE | Replace with a PokeVerse logo of the same size | Login screen. Byte-identical to the updater logo below. |
| (logo image) | `client/runtime-data/modules/game_updater/images/logo.png` | Same "POKÉMON JORNADAS" image, `updater.otui:61-62` | Y | RENAME TO POKEVERSE | Replace with a PokeVerse logo | Updater window. |
| (logo image) | `client/runtime-data/modules/client_background/images/logo.png` | Larger "POKÉMON JORNADAS" logo (446×186), `background.otui:288-290` `logoAccount` | Y | RENAME TO POKEVERSE | Replace with a PokeVerse logo | Shown on the account screen (`background.lua:86`). |
| PSoul | `client/runtime-data/modules/game_poll/poll.otui:31` | `!text: tr('PSoul Poll')` | Y | RENAME TO POKEVERSE | `!text: tr('PokeVerse Poll')` | Keep in sync with `poll.lua:38` and `pt.lua:296`. |
| PSoul | `client/runtime-data/modules/game_poll/poll.lua:38` | `pollIcon:setTooltip(tr("PSoul Poll"))` | Y | RENAME TO POKEVERSE | `pollIcon:setTooltip(tr("PokeVerse Poll"))` | |
| PSoul | `client/runtime-data/data/locales/pt.lua:296` | `["PSoul Poll"] = "Enquete PSoul",` | Y | RENAME TO POKEVERSE | `["PokeVerse Poll"] = "Enquete PokeVerse",` | Latin-1 file. |
| PSoul | `client/runtime-data/modules/game_tutorial/content/en/01.lua:5`, `02.lua:5`, `10.lua:5`, `26.lua:5`, `29.lua:5`, `30.lua:5`, `33.lua:5`, `35.lua:5`, `36.lua:5`, `39.lua:5`, `39.lua:7` | e.g. "It shows a part of the PSoul world…", "To release a Pokemon in PSoul…" | Y | RENAME TO POKEVERSE | Replace each `PSoul` with `PokeVerse` (11 lines, 11 occurrences) | In-game tutorial. ASCII, CRLF. |
| PSoul | `client/runtime-data/modules/game_tutorial/content/pt/01.lua:5`, `02.lua:5`, `10.lua:5`, `26.lua:5`, `29.lua:5`, `30.lua:5`, `33.lua:5` (×2), `35.lua:5`, `36.lua:5`, `39.lua:5`, `39.lua:7` | e.g. "mundo do PSoul", "no PSoul", "Dentro do PSoul" | Y | RENAME TO POKEVERSE | Replace each `PSoul` with `PokeVerse` (11 lines, 12 occurrences) | Windows-1252, CRLF. |
| (URL) | `client/runtime-data/modules/poke_create/create.lua:222` | `g_platform.openUrl("pokezring.net/regras.php")` | Y | RENAME TO POKEVERSE | `g_platform.openUrl("TODO - POKEVERSE URL REQUIRED")` | Old server's rules page, opened from the account-creation window. Not in the requested term list. |
| PokeCenter, PokeJornadas, PSoul, psoul.net, others | `modules/game_bottommenu/bottommenu.otmod:5`, `game_pokekill/pokekill.otmod:5` (`www.pokecenter.com.br`); `game_depotlock/depotlock.otmod:5`, `game_time/time.otmod:5` (`pokejornadas.com.br`); `game_tutorial/tutorial.otmod:4-5` (`author: PSoul`, `www.psoul.net`); `author: PSoul` in 17 `.otmod` files in total (tutorial plus 16 more: (advanceeffect, badgecase, dollcase, duelmessage, effects, environment, guide, lootlist, pokebar, pokedex, pokemoves, poll, slotmachine, statusbar, tips, tmchoose, …)); `game_chat/chat.otmod:5`, `game_task/task.otmod:5`, 8× `facebook.com/systemyart` | `author:` / `website:` module metadata | N | KEEP - LEGAL | Keep | Author attribution of the module that came with the import; never shown in the UI (no Lua reads the `website` field). If the team prefers not to ship old domains, change only `website:` to `TODO - POKEVERSE URL REQUIRED` and keep `author:`. |
| poketibia | `modules/game_house/house.otmod:3`, `game_housebuy/housebuy.otmod:3`, `game_houseowner/houseowner.otmod:3`, `game_houseownerenter/houseownerenter.otmod:3` | `description: House look module for Poketibia` | N | MANUAL REVIEW | Optionally `… for PokeVerse` | "Poketibia" is the genre name (Pokémon servers on the Tibia engine), not a project brand. Not user-facing. |
| PSoul | `modules/game_time/time.lua:4`, `:135` | `PSOUL_MINUTE_PER_SECOND = 2.5` | N | KEEP - UPSTREAM ENGINE | Keep | Internal constant of the PSoul fork. |
| PSoul | `client/source/src/client/protocolcodes.h:151-181`, `protocolgameparse.cpp:62-176` | `GameServerPSoul = 255`, `GameServerPSoulMoveBarUpdate`, … (54 lines) | N | KEEP - COMPATIBILITY | Keep | Names of the `0xFF` sub-protocol shared with the server; the docs call it "the PSoul sub-protocol". |
| OTClient | `client/source/**` (394 lines, 316 of them `Copyright (c) 2010-2014 OTClient` headers) | licence headers, `project(otclient)`, `// initialize … otclient` | N | KEEP - LEGAL (headers) / KEEP - UPSTREAM ENGINE (rest) | Keep | `client/source/CMakeLists.txt:2` `project(otclient)` builds `otclient`; `tools/build_client.sh:23,33` already installs it as `pokeverse-client`. |
| OTClient | `client/runtime-data/modules/*/*.otmod` (34 lines: `website: www.otclient.info`, `author: OTClient team`) | module metadata | N | KEEP - LEGAL | Keep | Upstream attribution. |
| OTClient, Tibia | `modules/gamelib/const.lua:209,216-218`, `gamelib/game.lua:23,45`, `gamelib/protocol.lua:17,27,117,123`, `game_interface/gameinterface.lua:182-183`, `game_console/console.lua:148` | `OtclientLinux = 10`, `isOfficialTibia()`, `-- original tibia ONLY` | N | KEEP - UPSTREAM ENGINE | Keep | Engine code and OS/protocol constants. |
| Tibia | `client/runtime-data/data/things/Tibia.spr`, `Tibia.dat`, `Tibia.otfi` (`assets-name: Tibia`, line 6), `Tibia.otml`; `modules/game_things/things.lua:36-38`; `data/hash.xml:2927-2930` | asset names and loaders | N | KEEP - COMPATIBILITY | Keep | Asset file names. |
| Tibia | `client/runtime-data/data/locales/{de,es,pl,pt,sv}.lua` (5 lines), `modules/client_locales/neededtranslations.lua:37` | "Also known as dash in tibia community…" | N | KEEP - UPSTREAM ENGINE | Keep | Upstream translation key that no OTUI/Lua file displays (orphan). Reword it if an option ever uses it. |
| PokeCenter | `client/runtime-data/crashreport.log:2` | `app name: Pokecenter` | N | KEEP - HISTORICAL | Keep (file is git-ignored, a 2021 crash log from the original package) | New crash reports take the name from `g_app.getName()`, so they change automatically with `main.cpp:86`. |
| (images) | `client/runtime-data/data/images/clienticon.png`, `client/source/src/otcicon.ico` | Window/taskbar icon (Pokémon Masters artwork; Windows exe icon) | Y | MANUAL REVIEW | Replace with a PokeVerse icon if desired | No old-brand text in `clienticon.png`; `.ico` contents UNVERIFIED. |

### 2.2 Redemption client (`client-redemption/`)

Only user-facing branding is itemized. Everything else is upstream OTClient Redemption (1,386 OTClient, 260 Tibia, 26 OpenTibia, 19 TFS, 5 "The Forgotten Server" occurrences) and is **KEEP - UPSTREAM ENGINE** (see the summary rows at the end of this table).

| Term | File:line | Context | UF | Class | Recommended action / new text | Notes |
|---|---|---|---|---|---|---|
| OTClient | `client-redemption/init.lua:100` | `g_app.setName("OTClient - Redemption");` | Y | RENAME TO POKEVERSE | `g_app.setName("PokeVerse");` | Window title (`modules/startup/startup.lua:65` `g_window.setTitle(g_app.getName())`, also `src/framework/core/modulemanager.cpp:150`), version label on the login background (`client_background/background.lua:14`), crash report `app name:`. **CI dependency:** `.github/workflows/platforms.yml:267,270` wait for a window named `OTClient`; change them in the same commit. |
| OTClient | `client-redemption/init.lua:101` | `g_app.setCompactName("otclient");` | N | RENAME TO POKEVERSE | `g_app.setCompactName("pokeverse");` | **Compatibility impact.** It names the user directory (`init.lua:142`; `PHYSFS_getPrefDir(org, compact)` + `.otclient/`, `resourcemanager.cpp:352-385,746-757`), the log file `otclient.log` in the work dir (`init.lua:109`) and the user script `/otclientrc.lua` (`init.lua:175`). After the rename that script would be looked up as `pokeverserc.lua`, so either rename `client-redemption/otclientrc.lua` and the list in `tools/stage_redemption.sh:25`, or keep `"otclientrc.lua"` hard-coded. Existing settings must be migrated. |
| (org name) | `client-redemption/init.lua:102` | `g_app.setOrganizationName("otcr");` | N | RENAME TO POKEVERSE | `g_app.setOrganizationName("pokeverse");` | Part of the per-user settings path (`%APPDATA%\otcr\…` on Windows, `~/.local/share/otcr/…` on Linux; exact PHYSFS paths UNVERIFIED). Same migration note. |
| OTClient | `client-redemption/modules/client_bottommenu/bottommenu.otui:50` | `text: OTClient Redemption` | Y | RENAME TO POKEVERSE | `text: PokeVerse` | Large caption on the login screen (module loaded from `modules/client/client.otmod:16`). |
| OTClient | `.github/workflows/platforms.yml:267`, `:270` | `xdotool search --name "OTClient"` | N | RENAME TO POKEVERSE | `xdotool search --name "PokeVerse"` | Only together with `init.lua:100`. |
| (images) | `client-redemption/data/images/clienticon.png`, `data/images/background.png`, `cmake/icon/otcicon.ico` | OTClient knight icon; medieval fantasy login background | Y | MANUAL REVIEW | Replace with PokeVerse art | No text in either PNG, but both are upstream/Tibia-style art, not PokeVerse. `.ico` UNVERIFIED. |
| Tibia | `client-redemption/modules/client_entergame/createAccount.otui:155` | "I agree to the Tibia Service Agreement,\n Tibia Rules and Tibia Privacy Policy." | Y | MANUAL REVIEW | If account creation is enabled: "I agree to the PokeVerse Service Agreement, Rules and Privacy Policy." | Only reachable when `Services.createAccount` is set; it is commented out in `init.lua:9`. The policy texts themselves do not exist yet. |
| OTClient | `client-redemption/android/app/src/main/res/values/strings.xml:2` | `<string name="app_name">otclient</string>` | Y (Android) | MANUAL REVIEW | `PokeVerse` if the Android build is shipped | CI builds Android (`platforms.yml`). |
| OTClient | `client-redemption/src/CMakeLists.txt:1056-1058`, `:1073`, `:1076` | `MACOSX_BUNDLE_BUNDLE_NAME "OTClient"`, `DISPLAY_NAME "OTClient"`, `IDENTIFIER "com.otclient.otclient"`, `OUTPUT_NAME "OTClient"`, `ICON_FILE "OTClient"` | Y (macOS) | MANUAL REVIEW | `PokeVerse` / e.g. a PokeVerse bundle id, only if a macOS build is shipped | Upstream build file; macOS is not a current target. |
| OTClient | `client-redemption/src/framework/config.h:58` | `#define RPC_LARGE_TEXT "OTClient - Redemption"` (Discord) | N | KEEP - UPSTREAM ENGINE | Keep | `ENABLE_DISCORD_RPC 0` (line 48). Revisit if Discord presence is enabled. |
| OTClient | `client-redemption/src/framework/core/application.h:80-82` | defaults `otbr`, `"OTClient - Redemption"`, `"otclient"` | N | KEEP - UPSTREAM ENGINE | Keep | Overridden by `init.lua:100-102`. |
| Tibia | `client-redemption/init.lua:13`, `modules/client_assets/client_assets.lua:5` | `repository = "dudantas/tibia-client"` | N | KEEP - COMPATIBILITY | Keep | Upstream asset-download source. PokeVerse ships its own `Tibia.spr`/`Tibia.dat`; whether `clientAssets.enabled = true` should stay is a separate decision. |
| OTClient | `client-redemption/CMakeLists.txt:48`, `src/CMakeLists.txt:1,51,55` | `project(otclient)`, `add_executable(${PROJECT_NAME} …)` | N | KEEP - UPSTREAM ENGINE | Keep | `tools/stage_redemption.sh:13-14,17,22` already copies `otclient` to `pokeverse-client`. |
| OTClient | `client-redemption/modules/updater/updater.otmod:4-5` | `author: otclient@otclient.ovh`, `website: otclient.ovh` | N | KEEP - LEGAL | Keep | Updater is inactive (`Services.updater` commented, `init.lua:6`). |
| Tibia | `modules/game_store/*`, `game_shop/*`, `game_market/*`, `game_cyclopedia/*`, `game_blessing/blessing.lua:10`, `game_stash/game_stash.lua:38`, `game_notifications/templates/screenshot.otui:53`, `gamelib/market.lua:118` (~120 lines) | "Tibia Coins", "Embrace of Tibia", Tibia achievements | Y (only if those modules are used with a server that sends the data) | KEEP - UPSTREAM ENGINE | Keep (see section 4) | Upstream Tibia-12/13 content. Revisit if PokeVerse turns on the store, market or cyclopedia UI. |
| OTClient, Tibia, OpenTibia, TFS | rest of `client-redemption/` (`src/`, `README.md`, `docs/`, `.github/`, `mods/`, `Dockerfile*`, `vc18/`, `android/`, `LICENSE`, `AUTHORS`; 386 `Copyright … OTClient` headers) | engine code, docs, licence | N | KEEP - UPSTREAM ENGINE / KEEP - LEGAL | Keep | |

### 2.3 Server configuration (`server/runtime-data/config.lua`, `server/source`)

`config.lua` is ISO-8859-1 with CRLF line endings.

| Term | File:line | Context | UF | Class | Recommended action / new text | Notes |
|---|---|---|---|---|---|---|
| PokeCenter | `server/runtime-data/config.lua:99` | `motd = "Sejá bem vindo ao PokeCenter - MMORPG"` | Y | RENAME TO POKEVERSE | `motd = "Sejá bem vindo ao PokeVerse - MMORPG"` | Sent at login (`protocollogin.cpp:418-420`). A new text gets a new MOTD id (`game.cpp:6317-6330`), so every client shows it once. |
| PokeCenter | `server/runtime-data/config.lua:104` | `loginMessage = "Bem-vindo ao PokeCenter, torne-se um mestre pokémon. …"` | Y | RENAME TO POKEVERSE | `loginMessage = "Bem-vindo ao PokeVerse, torne-se um mestre pokémon. Passe por todas as missões, conclua as quest's e explore nossas cidades. "` | Refers to the game, not the building. |
| PokeCenter | `server/runtime-data/config.lua:316` | `ownerName = "PokeCenter"` | Y | RENAME TO POKEVERSE | `ownerName = "PokeVerse"` | Status protocol / server lists (`status.cpp:149,233`). |
| PokeCenter | `server/runtime-data/config.lua:317` | `ownerEmail = "contact@pokecenter.net"` | Y | RENAME TO POKEVERSE | `ownerEmail = "TODO - POKEVERSE URL REQUIRED"` | Old domain. |
| PokeCenter | `server/runtime-data/config.lua:318` | `url = "http://www.pokecenter.net/"` | Y | RENAME TO POKEVERSE | `url = "TODO - POKEVERSE URL REQUIRED"` | Also shown to players in "This account does not contain any character yet. Create a new character on the <serverName> website at <url>." (`protocollogin.cpp:407-408`) and in status XML (`status.cpp:142`). |
| (world name) | `server/runtime-data/config.lua:103` | `serverName = "Cristal"` | Y | MANUAL REVIEW | Keep or choose a PokeVerse world name | World name shown in the character list. Not an old project brand. |
| PSoul | `server/runtime-data/config.lua:333` | `-- PSoul` | N | KEEP - UPSTREAM ENGINE | Keep | Section header for the PSoul fork's config keys (`shinyAppearChance`, …). |
| The Forgotten Server, Tibia | `server/runtime-data/config.lua:1`, `:57`, `:216` | `-- The Forgotten Server Config`, "famous Tibia anti-magebomb system" | N | KEEP - UPSTREAM ENGINE | Keep | Comments. |
| psoul.net | `server/source/resources.h:81` | `#define CLIENT_VERSION_STRING "Your client is outdated, please visit http://www.psoul.net and download the latest client."` | Y | RENAME TO POKEVERSE | `"Your client is outdated, please visit TODO - POKEVERSE URL REQUIRED and download the latest client."` | Sent on version mismatch (`protocollogin.cpp:325`, `protocolold.cpp:73,89`). Needs a server rebuild. |
| PSoul | `server/source/configure.ac:243`, `player.cpp:1511`, `player.h:276` | `#echo PSoul 0.1.0`, `// PSoul uses global depot` | N | KEEP - UPSTREAM ENGINE | Keep | Fork comments. |
| The Forgotten Server, TFS, OpenTibia | `server/source/**` (792 + 11 + 238 occurrences: 188 `// OpenTibia - an opensource roleplaying game` headers, `dev-cpp/TheForgottenServer*.dev` project files (710 lines), `Makefile.am`, `configure.ac:2`, `gameservers.h:28`, `protocolhttp.cpp:48,59`, `databasemanager.cpp:279`, `configmanager.cpp:89-97`, `doc/*`) | engine | N | KEEP - LEGAL (headers) / KEEP - UPSTREAM ENGINE (rest) | Keep | `STATUS_SERVER_NAME` is `"Unknown"` (`resources.h:83`), so the console banner shows no brand. |
| The Forgotten Server | `server/source/config.lua:98,102-103,118,314-317` | TFS sample config (`motd = "Welcome to the Forgotten Server!"`, `url = "http://otland.net/"`) | N | KEEP - UPSTREAM ENGINE | Keep | Upstream sample; the server runs with `server/runtime-data/config.lua` (`tools/run_server.sh:2`). |

### 2.4 Server scripts, NPCs, items and text (`server/runtime-data/data`, `pt_br.loc`)

NPC spawn status comes from `data/world/map-spawn.xml` ("unspawned" = the NPC name does not occur there; other spawn mechanisms UNVERIFIED).

| Term | File:line | Context | UF | Class | Recommended action / new text | Notes |
|---|---|---|---|---|---|---|
| PokeCenter | `data/lib/ps/events/globalevents/globalMessages.lua:3` | "…site que não seja o pokecenter.com, a equipe não da itens ou pokemons." | Y | RENAME TO POKEVERSE | replace `pokecenter.com` with `TODO - POKEVERSE URL REQUIRED` | Rotating broadcast. Latin-1. Until a URL exists, consider disabling the URL messages so players never see the placeholder. |
| PokeCenter | `globalMessages.lua:4` | "…any site other than pokecenter.com…" | Y | RENAME TO POKEVERSE | replace `pokecenter.com` with `TODO - POKEVERSE URL REQUIRED` | |
| PokeCenter | `globalMessages.lua:11`, `:12` | "Acesse agora: http://www.pokecenter.com" / "Visit now: http://www.pokecenter.com" | Y | RENAME TO POKEVERSE | URL → `TODO - POKEVERSE URL REQUIRED` | |
| PokeCenter | `globalMessages.lua:19`, `:20` | "…oficial do pokecenter (http://www.pokecenter.com)!" / "…official pokecenter (http://www.pokecenter.com)!" | Y | RENAME TO POKEVERSE | "…oficial do PokeVerse (TODO - POKEVERSE URL REQUIRED)!" / "…official PokeVerse (TODO - POKEVERSE URL REQUIRED)!" | "pokecenter" here is the game/site, not the building. |
| PokeCenter | `globalMessages.lua:23`, `:24` | "…Acesse: http://forum.pokecenter.com/" | Y | RENAME TO POKEVERSE | URL → `TODO - POKEVERSE URL REQUIRED` | |
| PokeCenter | `globalMessages.lua:27`, `:28` | "…desenvolvedores do pokecenter? Acesse: http://www.pokecenter.com" / "…the pokecenter developers? Visit now: http://www.pokecenter.com" | Y | RENAME TO POKEVERSE | "…desenvolvedores do PokeVerse? Acesse: TODO - POKEVERSE URL REQUIRED" / "…the PokeVerse developers? Visit now: TODO - POKEVERSE URL REQUIRED" | |
| psoul.net | `data/talkactions/scripts/shutdown.lua:38`, `:39`, `:41`, `:42`, `:44`, `:45` | "…Mais informações em: http://forum.psoul.net/announcements/" | Y | RENAME TO POKEVERSE | URL → `TODO - POKEVERSE URL REQUIRED` (6 lines) | Shutdown countdown broadcast. UTF-8 file. |
| (Pokenordic) | `data/creaturescripts/scripts/login.lua:70` | "This is your first login on Pokenordic! Welcome! …" | Y | RENAME TO POKEVERSE | "This is your first login on PokeVerse! Welcome! …" | First login on Beginner Island. Not passed through `__L`. |
| PSoul | `data/creaturescripts/scripts/login.lua:77` | `__L(cid, "Hello %s! Welcome to PSoul, a MMORPG loyal in the Pokemon series. …")` | Y | RENAME TO POKEVERSE | "Hello %s! Welcome to PokeVerse, …" | Change `pt_br.loc:6870` key and value ("Seja bem-vindo ao PSoul" → "ao PokeVerse") identically. |
| PSoul, psoul.net | `data/creaturescripts/scripts/login.lua:49`, `:51` | commented-out `doPlayerPopupFYI` "Bem vindo ao mundo de PSoul! …" | N | KEEP - HISTORICAL | Keep (dead code) | If re-enabled: PSoul → PokeVerse, URL → TODO. |
| (pokenordic.com) | `data/lib/ps/events/creaturescripts/onJoinChannel.lua:85` | "Acesse nosso site: http://www.pokenordic.com/blogCategories/1-tutorials / … Access our site: http://www.pokenordic.com/…" | Y | RENAME TO POKEVERSE | both URLs → `TODO - POKEVERSE URL REQUIRED` | Sent when a player opens the Help channel. |
| PSoul | `data/lib/ps/config/002-wikiChat.lua:2`, `:3` | "…informações sobre o PSoul." / "…information about PSoul." | Y | RENAME TO POKEVERSE | `PSoul` → `PokeVerse` | Wiki Chat channel greeting. Latin-1. |
| PSoul | `002-wikiChat.lua:4` | commented Spanish line "…acerca de la PSoul" | N | RENAME TO POKEVERSE | `PSoul` → `PokeVerse` | Commented out; rename for consistency with lines 2-3. |
| PSoul | `data/npc/Biff.xml:6` | `message_greet` "Hello, welcome to the PSoul Pokemon world! …" | Y | RENAME TO POKEVERSE | "Hello, welcome to the PokeVerse Pokemon world! …" | Spawned tutorial NPC. Change `pt_br.loc:1830` identically. |
| PSoul | `data/npc/scripts/tutorial_quests.lua:102`, `:115`, `:138` | "…the PSoul follows in fact the official data…", "…spaces by PSoul world…", "…keep PSoul online…" | Y | RENAME TO POKEVERSE | `PSoul` → `PokeVerse` (3 lines) | Used by spawned NPCs (Biff, Flanagan, Gray, Carlton, Cletis, Jimi, Shelley, Gosse, Tracy). No `pt_br.loc` key contains these strings. |
| PSoul | `data/npc/scripts/eggmove_remover.lua:84` | "…fix an Egg Move lost due to PSoul update changes…" | Y | RENAME TO POKEVERSE | "…due to PokeVerse update changes…" | NPCs Kemp/Drummond unspawned. Change `pt_br.loc:6647`. |
| PSoul | `data/npc/scripts/market.lua:27` | "…Try to use the 'beta' version of PSoul client!" | Y | RENAME TO POKEVERSE | "…of PokeVerse client!" | NPC Jaron Jewell unspawned. Change `pt_br.loc:4560`. |
| PSoul | `data/items/items.xml:26432` | `<item fromid="23961" toid="23963" article="a" name="PSoul token"/>` | Y | RENAME TO POKEVERSE | `name="PokeVerse token"` | No Lua/XML references the name or ids 23961-23963. Whether the token sprite shows a PSoul logo is UNVERIFIED. |
| PSoul | `data/items/items.xml:29204-29208` | `name="PSoul letter L/O/P/S/U"` | Y | MANUAL REVIEW | Decide whether to keep, rework or drop the anniversary letters event | The event is a word game spelling P-S-O-U-L; the item sprites show the letters. A rename means new letters, sprites and reward logic. |
| PSoul | `data/items/items.xml:21976`, `:21979`, `:21982`, `:21985`, `:21988` | letters 14438-14442: "Complete the word PSoul to receive your reward!" | Y | MANUAL REVIEW | as above | `pt_br.loc:1043`. |
| PSoul | `data/items/items.xml:29241` | `name="PSoul backpack"` (27937) | Y | MANUAL REVIEW | `PokeVerse backpack` if the sprite carries no PSoul logo | Sprite content UNVERIFIED. Event reward (`048-anniversaryEvent.lua:30`). |
| PSoul | `data/npc/Logan.xml:6`; `data/npc/scripts/event_anniversary.lua:160`, `:166`; `event_anniversary_letters.lua:44-48`; `event_birthday.lua:29`, `:33`, `:36`, `:39`, `:42`; `data/lib/ps/systems/023-achievement.lua:1085`; `048-anniversaryEvent.lua:30`, `:95-99` (comments) | "anniversary of PSoul", "exchange 'psoul' letters", "Trade the PSOUL letters into one gift." | Y | MANUAL REVIEW | Same decision as the letter items | All event NPCs (Logan, Murray, Aaron, Timothy, Kelvin) are unspawned. `pt_br.loc:1338`, `:1816`, `:1974`. |
| PSoul | `server/runtime-data/pt_br.loc:1830`, `:4560`, `:6647`, `:6870` | keys and values of the strings renamed above | Y | RENAME TO POKEVERSE | Rename key and value together (`PSoul` → `PokeVerse`) | Latin-1, CRLF. |
| PSoul, psoul.net | `pt_br.loc:4346` | "This is your first login on PSoul! … http://forum.psoul.net/tutorials/@…" | N | RENAME TO POKEVERSE | `PSoul` → `PokeVerse`, URL → `TODO - POKEVERSE URL REQUIRED` | Orphan key: `login.lua:70` now sends a different, untranslated text. |
| PSoul, psoul.net | `pt_br.loc:4722` | "Welcome to the world of PSoul! …" | N | RENAME TO POKEVERSE | `PSoul` → `PokeVerse`, any URL → TODO | Orphan; its caller (`login.lua:51`) is commented out. |
| PSoul | `pt_br.loc:5742` | "Welcome to PSoul! Stay tuned, Professor Oak…" | N | RENAME TO POKEVERSE | `PSoul` → `PokeVerse` | Orphan key, no caller found. |
| PSoul | `pt_br.loc:1043`, `:1338`, `:1816`, `:1974` | letters-event strings | Y | MANUAL REVIEW | Follow the letters-event decision | |
| PokeCenter | `data/XML/outfits.xml:335`, `:729` | `<!-- LOJA POKECENTER -->` | N | RENAME TO POKEVERSE | `<!-- LOJA POKEVERSE -->` | Brackets the premium-shop outfits of the old PokeCenter server ("loja" = shop). Comment only. |
| psoul.net | `data/lib/ps/systems/038-pokemonAddon.lua:2915`, `:2918` | commented HTML generator `http://www.psoul.net/img/addons/…` | N | KEEP - HISTORICAL | Keep (dead code) | |
| PSoul | `data/lib/ps/config/pokemon.lua:1610` | commented debug `print(… " doesn't exists on PSoul …")` | N | KEEP - UPSTREAM ENGINE | Keep | |
| (lib/ps) | `data/lib/ps/**` directory and `ps` file names | PSoul framework | N | KEEP - UPSTREAM ENGINE | Keep | Renaming paths would break every `dofile` and XML `value="../../lib/ps/…"`. |
| OTClient | `data/lib/ps/functions/player.lua:496`, `systems/010-pokedex.lua:532`, `systems/044-slotMachine.lua:164`, `npc/scripts/market.lua:26`, `npc/scripts/tutorial_quests.lua:74`, `creaturescripts/scripts/login.lua:48` | `getPlayerUsingOtClient(cid)` | N | KEEP - UPSTREAM ENGINE | Keep | Engine function name. |
| TFS | `data/globalevents/scripts/gesior-shop-system.lua:58`, `:92`, `data/lib/050-function.lua:371`, `:373` | comments | N | KEEP - UPSTREAM ENGINE | Keep | |
| Tibia | `data/items/items.xml` (19 lines, see section 4) | "flag of Tibia", "gods of Tibia", "TibiaBR", "tibiacity encyclopedia", … | Y (if the items exist in game) | MANUAL REVIEW | **Flagged:** user-facing Tibia text. Reword or remove if any of these items is obtainable | Stock Tibia items left in `items.xml`; presence on the map or in shops UNVERIFIED. |
| Tibia | `data/actions/scripts/other/watch.lua:2-3,8`, `data/lib/050-function.lua:188`, `data/lib/game_work.lua:16`, `data/actions/scripts/other/furniturebeds.lua:40`, `data/npc/lib/npcsystem/keywordhandler.lua:10`, `modules.lua:16-17`, `data/items/items.xml:22484` | `tibianTime`, `getTibiaTime()`, comments | N | KEEP - UPSTREAM ENGINE | Keep | |
| Pokémon Center | 76 lines (see section 3) | NPC/heal/depot text | Y | KEEP - GAMEPLAY TERM | **Never rename** | |

### 2.5 Database (`database/`, `server/runtime-data/poketibia.sql`)

| Term | File:line | Context | UF | Class | Recommended action / new text | Notes |
|---|---|---|---|---|---|---|
| pokeaventuras | `database/pokeaventuras.sql` (file name) | original dump `pokeaventuras (1).sql` | N | KEEP - COMPATIBILITY | Keep | Referenced by `tools/setup_dev_db.sh:17`, `tools/check_db_tables.py:81`, `tools/verify_import.py:77-78`, `database/migrations/001_phase2_baseline.sql:1`, `database/seeds/dev_accounts.sql:2` and the docs. The runtime database is already called `pokeverse` (`config.lua:118,120`). |
| poketibia | `database/pokeaventuras.sql:22`, `server/runtime-data/poketibia.sql:22` | `-- Banco de dados: \`poketibia\`` | N | KEEP - HISTORICAL | Keep | phpMyAdmin export comment. `poketibia.sql` is a byte-identical copy of the dump; its file name is HISTORICAL too. |
| (Genesis) | `database/pokeaventuras.sql:3187-3188`, `server/runtime-data/poketibia.sql:3187-3188` | `server_motd` rows "Sejá bem vindo ao Pokemon Genesis World, Treinador(a)" | N | KEEP - HISTORICAL | Keep | Imported MOTD history. The server sends `config.lua` `motd`, not these rows (`protocollogin.cpp:419`, `game.cpp:6317-6337`). |
| Jornadas | `database/migrations/001_phase2_baseline.sql:29` | "…never drops Jornadas market data." | N | KEEP - HISTORICAL | Keep | Describes imported data. |
| TFS | `database/migrations/001_phase2_baseline.sql:27` | "TFS 1.x `market_offers` layout" | N | KEEP - UPSTREAM ENGINE | Keep | |
| PokeJornadas | `database/seeds/dev_accounts.sql:9` | "Characters match a fresh PokeJornadas level-8 character" | N | KEEP - HISTORICAL | Keep | |

### 2.6 Tools and CI (`tools/`, `.github/`, root files)

| Term | File:line | Context | UF | Class | Recommended action / new text | Notes |
|---|---|---|---|---|---|---|
| PokeCenter | `tools/smoke_login.sh:26` | `PROFILE="$HOME/.Pokecenter"` | N | RENAME TO POKEVERSE | `PROFILE="$HOME/.pokeverse"` | Only together with `client/source/src/main.cpp:87`. |
| Jornadas | `tools/smoke_login.sh:40` | `xdotool search --name "Jornadas"` | N | RENAME TO POKEVERSE | `xdotool search --name "PokeVerse"` | Only together with `client.lua:85`. `tools/runtime_test.sh` calls `smoke_login.sh`, so it depends on this too. |
| PokeCenter | `tools/runtime_test.sh:14` | `USER_DIR="$HOME/.Pokecenter"` | N | RENAME TO POKEVERSE | `USER_DIR="$HOME/.pokeverse"` | The harness module is copied into this directory; with a mismatched path the harness never loads. |
| PokeJornadas, Jornadas, pokeaventuras | `tools/import/fetch-pokejornadas.sh:2,5,11,14,36`, `tools/verify_import.py:2,77-78`, `tools/updater-hash/README.md:3` | import tooling (archive name, MediaFire URL of the original package) | N | KEEP - HISTORICAL | Keep | The MediaFire URL is the source of the original archive, not a project website. |
| pokeaventuras | `tools/setup_dev_db.sh:17`, `tools/check_db_tables.py:81` | `database/pokeaventuras.sql` | N | KEEP - COMPATIBILITY | Keep | |
| OTClient, TFS | `tools/build_client.sh:33`, `tools/build_redemption.sh:2,26-27`, `tools/stage_redemption.sh:17-18,22,25,29`, `tools/runtime_test.sh:8`, `tools/validate.py:33`, `tools/smoke_server.sh:27` | `$BUILD/otclient`, comments | N | KEEP - UPSTREAM ENGINE | Keep | Build outputs are already renamed to `pokeverse-client*`. |
| Tibia | `.gitattributes:1`, `.github/workflows/validate.yml:28` | LFS rule / comment for `Tibia.spr` | N | KEEP - COMPATIBILITY | Keep | |
| OTClient | `.github/workflows/platforms.yml:29,113,179` | `OTCLIENT_BUILD_TESTS`, `OTCLIENT_ANDROID_ABIS`, `otclientrc.lua` | N | KEEP - UPSTREAM ENGINE | Keep | Lines 267/270 are in section 2.2. Line 179 must follow the `otclientrc.lua` decision there. |
| PokeJornadas, The Forgotten Server | `.gitignore:5` and other `.gitignore` comments | "Original PokeJornadas binaries, kept locally…" | N | KEEP - HISTORICAL | Keep | |
| (verify tool) | `tools/verify_import.py:49-51` | `INTENTIONAL_CHANGES` | N | MANUAL REVIEW | Optionally add each renamed legacy file | `verify_import.py --layout phase2 --no-remote` already reports dozens of intentional "differs" (e.g. `client/source/src/main.cpp`), so the rebrand does not newly break it; listing the files keeps its report readable. |

### 2.7 Docs and README

| Term | File:line | Context | UF | Class | Recommended action / new text | Notes |
|---|---|---|---|---|---|---|
| PokeCenter | `docs/BUILD_BASELINE.md:60` | "…into the client's user directory (`~/.Pokecenter`)…" | N | RENAME TO POKEVERSE | `~/.pokeverse` | Operating instructions; change together with `main.cpp:87`. |
| PokeCenter | `docs/CLIENT_UI.md:3` | "OTClient 0.6.6 fork (app name "Pokecenter")" | N | RENAME TO POKEVERSE | `(app name "PokeVerse")` once `main.cpp:86` changes | Describes the current client, so it goes stale after the rename. |
| PokeJornadas, PSoul, PokeCenter | `README.md:3`, `:7`, `:15`, `:16`, `:17`, `:69` | lineage and component table | N | KEEP - HISTORICAL | Keep | |
| PokeJornadas, PSoul, PokeCenter | `README.md:5`, `:79` | non-affiliation notice; trademark and art provenance | N | KEEP - LEGAL | Keep | |
| PokeNation | `README.md` (1), `docs/POKENATION_FEATURE_PARITY.md` (22), `docs/MISSING_FROM_POKEVERSE.md` (14), `docs/PHASE_2_VIABILITY_REPORT.md` (4), `docs/WORKING_FEATURES.md` (1) | comparisons with the separate PokeNation project | N | KEEP - HISTORICAL | Keep | PokeVerse is not PokeNation; these are comparisons. |
| all old brands | `docs/ARCHITECTURE.md` (30), `IMPORT_VERIFICATION.md` (13), `ORIGINAL_STRUCTURE.md` (15), `SECURITY_AUDIT.md` (13), `UI_AUDIT.md` (18), `EXTENDED_OPCODE_MAP.md` (8), `DATABASE.md` (7), `FEATURES.md`, `FEATURE_AUDIT.md`, `ORIGINAL_BINARY_INVENTORY.md`, `PHASE_3_BASELINE.md`, `REDEMPTION_PROTOCOL_COMPATIBILITY.md`, `DESIGN_ASSET_AUDIT.md` (`PokeCenter - POKE SLOT.psd`), `BUILD_STATUS.md`, `CLIENT_UI.md:12,19,41` | import history, audits, the "PSoul sub-protocol" | N | KEEP - HISTORICAL | Keep | `ARCHITECTURE.md` explicitly describes the codebase "as it was imported". `ARCHITECTURE.md:18` is the only "Nordic SOUL" hit (it refers to the ignored `settings.sav`). |
| Pokémon Jornadas | `docs/SERVER_STARTUP_REPORT.md:52` | "The client window title becomes `Pokémon Jornadas \| Jogador: Trainer`." | N | KEEP - HISTORICAL | Keep | Dated test report. |
| Tibia, OTClient, TFS | all `docs/*.md` (51 + 87 + 18 occurrences) | engine/asset references | N | KEEP - UPSTREAM ENGINE / COMPATIBILITY | Keep | |
| all | `original/MANIFEST.sha256.tsv`, `original/README.md`, `assets/README.md` | manifest of the original archive | N | KEEP - HISTORICAL | Keep | Must stay byte-exact for `verify_import.py`. |

---

## 3. Pokémon Center occurrences (must stay)

Every in-game Pokémon Center reference found. All are **KEEP - GAMEPLAY TERM**. A regression test can assert these strings and counts are unchanged after the rebrand. The scan found **no** `Teleport: Pokemon Center` string and no "Pokemon Center" in `map-house.xml`, `map-sound.xml` (empty `<sounds/>`) or as a byte string in `map.otbm` (OTBM strings can be escaped, so the map result is UNVERIFIED).

### 3.1 Client

| File:line | Text / data | Count |
|---|---|---|
| `client/runtime-data/modules/game_minimap/minimap.lua:100,107,114,121,127,134,141,148,154,160,171,184,199,211,223,236,248,258,267` | `type = MAPMARK_TEMPLE, description = "Pokemon Center"` guide map marks | 19 (table 3.3) |
| `client/runtime-data/modules/game_environment/sounds1.lua` | ambient-sound zones: `[8] = "Pokemon Center"` labels / `[5] = "pokemon_center_01"` sound | 204 labels / 200 sound ids |
| `client/runtime-data/modules/game_environment/sounds2.lua` | same structure | 333 labels / 329 sound ids |
| `client/runtime-data/modules/game_environment/environment.lua:92-93` | `SOUND_FILES["pokemon_center_01"]`, `["pokemon_center_02"]` | 2 |
| `client/runtime-data/data/sounds/environment/pokemon_center_01.ogg`, `pokemon_center_02.ogg`; `data/hash.xml:2877-2878` | sound asset names | 2 files |
| `client/runtime-data/data/locales/pt.lua:1217` | `["Pokemon Center"] = "Centro Pokemon",` | 1 |
| `client/runtime-data/modules/game_tutorial/content/en/23.lua:12` | "…go straight to your backpack or for the Pokemon Center depot." | 1 |
| `…/en/28.lua:5` | "…heal fainted Pokemon with the Nurses Joys of all game Pokemon Centers." | 1 |
| `…/en/36.lua:5` | "…accessed directly by all the game Pokemon Center." (Trade Center) | 1 |
| `…/en/37.lua:5` | "Within all Pokemon Centers of the game you will find machines…" (depot) | 1 |
| `…/pt/23.lua:12`, `…/pt/36.lua:5` | "…depósito do Centro Pokemon", "…acessado diretamente por todos Centro Pokemons do jogo" | 2 |
| `client/runtime-data/modules/game_shop/decoracoes.otui:301,366,430,…` | tooltip "…tem a mesma funcionalidade do depósito do centro pokémon." | 75 |

### 3.2 Server

| File:line | Text / data |
|---|---|
| `data/npc/Nurse Joy.xml:2` | `<npc name="Nurse Joy" script="nurse_joy.lua" …>`; **60** `name="Nurse Joy"` spawns in `data/world/map-spawn.xml` |
| `data/npc/Nurse Chansey.xml:2` | `<npc name="Nurse Chansey" …>`; **24** spawns in `map-spawn.xml` |
| `data/npc/Possessed Joy.xml:2` | quest NPC `Possessed Joy` (`quest_possessed_joy.lua`) |
| `data/npc/scripts/nurse_joy.lua:29` | log "Pokemon Center NPC - Can't find machine for animation." |
| `data/npc/scripts/nurse_joy.lua:174` | "Please enter the Pokemon center to heal your Pokemon." (+ `pt_br.loc:3307`) |
| `data/npc/Darius Chas.xml:6` | "Pokemon Center do not charge to heal your Pokemon, you know?" (+ `pt_br.loc:3346`) |
| `data/npc/tmpCitizen_40.xml:1` (Miss Gide), `tmpCitizen_48.xml:1` (Vernetta Le guin); `data/lib/ps/systems/027-citizens.lua:7` | citizen greets "POKEMON CENTERS heal your tired…", "There's a POKEMON CENTER in every town ahead…" (+ `pt_br.loc:3347`, `:4226`) |
| `data/lib/ps/systems/026-guide.lua:4,11,18,25,31,38,45,52,58,64,75,88,103,115,127,140,152,162,171,175,180,185,191,197,202,207` | 26 guide marks `description = "Pokemon Center"` (table 3.3) |
| `data/lib/ps/config/002-wikiChat.lua` English `:537, 597, 601, 603, 610, 624, 925, 1041`; Portuguese/Spanish `:17, 77, 81, 83, 90, 104, 405, 521, 1057, 1117, 1121, 1123, 1130, 1144, 1445, 1561` | Wiki topics `keywords = {'pokemon center'}`, `{'centro pokemon'}`, "The Pokemon Center is where you can heal your Pokemon and deposit your items.", "Go to the Pokemon Center say 'hi' to Nurse Joy…", "In Pokemon center there is a place where you can store your items…", "…north of the Pokemon Center" (8 English + 16 Portuguese/Spanish lines) |
| `data/lib/ps/config/003-quest.lua:5957` | "…Nurse Joy's Chanseys are simply disappearing from the Pokemon centers…" (+ `pt_br.loc:4679`) |
| `data/lib/ps/config/balls.lua:2149,2165,2184` | "…this ball will be teleported directly to the pokemon center." / "…teleported to the Pokemon Center." (+ `pt_br.loc:1066`, `:4318`, `:4919`, `:5931`) |
| `data/lib/ps/events/actions/surpriseBox/{black,orange,purple,white,yellow}.lua:26-28` | "…The items were teleported to the Pokemon center." (+ `pt_br.loc:4322,4353,4379,4458,4461`) |
| `data/lib/ps/events/creaturescripts/onDeath.lua:42` | "You scurried to a Pokemon Center, protecting the exhausted\nand fainted Pokemon…" (+ `pt_br.loc:5662`); the player is moved to the town temple position |
| `data/lib/ps/events/movements/activationTile.lua:285,1276,1412,1418` | comments "Pokemon Center depots", "Pokemon Center / PokeMart automatic doors" (depot/door tile logic) |
| `data/items/items.xml:17676`, `:24760` | `name="pokemon center sign"` (11887), `name="pokemon center pillar"` (18669) |
| `server/runtime-data/pt_br.loc:3345`, `:4715`, `:4716` | `Pokemon Center@Centro Pokemon`, "Welcome to the Pokemon Center. We restore your tired Pokemon to full health…" (×2, `{restore}` variant) |
| `server/runtime-data/pt_br.loc` | 18 "Pokemon Center" lines and 16 "Centro Pokemon" lines in total (all listed above) |

### 3.3 Guide map marks and teleport destinations (coordinates)

Town → Pokémon Center map mark. The client (`minimap.lua`) and server (`026-guide.lua`) carry the same coordinates for the 18 shared towns. The client also has `Tutorial`; the server also has 8 Orange Archipelago guides.

| Town / guide | Position (x,y,z) | Client line | Server line |
|---|---|---|---|
| Tangelo | 2756,2819,5 | 100 | 4 |
| Mandarin North | 2939,2231,7 | 107 | 11 |
| Kumquat | 3516,1694,7 | 114 | 18 |
| Mikan | 2758,2437,7 | 121 | 25 |
| Pummelo | 3066,1664,7 | 127 | 31 |
| Ascorbia | 4434,1716,7 | 134 | 38 |
| Trovitopolis | 3490,3213,6 | 141 | 45 |
| Moro | 4164,2955,7 | 148 | 52 |
| Sunburst | 3039,2542,5 | 154 | 58 |
| Viridian | 3295,564,7 | 160 | 64 |
| Pewter | 3307,296,7 | 171 | 75 |
| Cerulean | 3884,314,7 | 184 | 88 |
| Saffron | 3942,471,7 | 199 | 103 |
| Celadon | 3701,436,7 | 211 | 115 |
| Vermilion | 3968,640,7 | 223 | 127 |
| Fuchsia | 3860,844,7 | 236 | 140 |
| Cinnabar | 3370,1048,7 | 248 | 152 |
| Lavender | 4188,554,7 | 258 | 162 |
| Tutorial | 5033,741,7 | 267 | — |
| Guide Jo | 2754,2574,5 | — | 171 |
| Guide Pinkan | 3011,2440,6 | — | 175 |
| Guide Tarroco | 3016,1175,5 | — | 180 |
| Guide Hamlin | 3207,1154,7 | — | 185 |
| Guide Shamouti | 3274,1601,7 | — | 191 |
| Guide Butwal | 3864,1427,7 | — | 197 |
| Guide Navel | 4206,1911,6 | — | 202 |
| Guide Murcott | 3960,2847,7 | — | 207 |

**Teleport destinations.** The Pokémon teleport talkaction `data/lib/ps/events/talkactions/teleport.lua:1-49` defines 43 `DESTS` entries keyed by town name (`viridian`, `pewter`, `cerulean`, `saffron`, `celadon`, `vermilion`, `lavender`, `fuchsia`, `cinnabar`, `tangelo`, `sunburst`, `mikan`, `pummelo`, `pinkan`, `valencia`, `hamlin`, `kumquat`, `tarroco`, `butwal`, `navel`, `mandarin north`, `ascorbia`, `seven grapefruit`, `moro`, `shamouti`, `murcott`, `trovitopolis`, `mandarin south` → town `"Mandarin South 02"`, and 15 Hoenn towns `littleroot` … `pacifidlog`). Each destination resolves to `getTownTemplePosition(getTownId(townName))` (lines 158-167), i.e. the town's temple point, which these guides mark as the Pokémon Center. Town names live in `map.otbm` and must not be renamed. `config.lua:341` `defaultTownId = 32 -- Cerulean`.

---

## 4. Tibia reference audit

604 lines containing "tibia" (653 occurrences, including `OpenTibia`, `tibian`, `Tibia.spr`), sorted by a rule-based classifier and then checked by hand.

| Category | Lines | Examples | Action |
|---|---|---|---|
| LEGAL | 188 | `server/source/*.cpp,h:2` `// OpenTibia - an opensource roleplaying game` (GPL header) | Keep |
| UPSTREAM | 206 | `client-redemption/modules/game_shop/serverSIDE/data/scripts/game_shop.lua` (40, "Embrace of Tibia"), `game_cyclopedia/utils.lua` (18 achievements "…the world of Tibia…"), `game_store/*` and `game_market/t_market.lua` ("Tibia Coins"), Redemption `README.md`, `.github` (`opentibiabr/otclient`), `server/source/doc/CHANGELOG`, `CONFIG_HELP`, `LUA_FUNCTIONS`, `server/source/config.lua:56,214` | Keep. About 120 Redemption lines are UI text in store/shop/market/cyclopedia modules; they reach players only if those Tibia-12/13 features are fed by the server. Revisit before enabling them. |
| HISTORICAL | 93 | `docs/*.md`, `original/MANIFEST.sha256.tsv`, `README.md:15` lineage, `docs/ARCHITECTURE.md:8` "OpenTibia → The Forgotten Server 0.3.6" | Keep |
| PROTOCOL | 42 | `gamelib/game.lua:23` `host:ends('.tibia.com') or host:ends('.cipsoft.com')`, `isOfficialTibia()`, `protocolcodes.h:68,203` `// original tibia ONLY`, Redemption `createAccount.lua:113-115` CSP `*.tibia.com`, `npcsystem/modules.lua:16-17` "Tibia 8.2", bot `getClientVersion()` checks | Keep. The Tibia protocol version numbers (`CLIENT_VERSION_MIN 312` / `MAX 1343`, `resources.h:79-80`; Redemption profile `protocol = 1511`, `init.lua:78`) are KEEP - COMPATIBILITY. |
| ASSET FILE | 25 | `Tibia.spr` / `Tibia.dat` / `Tibia.otfi` / `Tibia.otml` (`things.lua:36-38`, `hash.xml:2927-2930`, `Tibia.otfi:6`), Redemption `client_assets.lua:1481-1482`, `things.lua:65-66`, `datdump.cpp:167,199`, `.gitattributes:1`, `validate.yml:28`, `README.md:29,60,67`, `init.lua:13` `dudantas/tibia-client` | Keep (KEEP - COMPATIBILITY) |
| ENGINE COMPATIBILITY | 19 | `watch.lua:2-8` `tibianTime`, `050-function.lua:188` `getTibiaTime()`, `config.lua:57,216` comments, `items.xml:22484` `<!-- TIBIA ITEMS -->`, `console.lua:148`, `gameinterface.lua:182`, `poketibia` in otmod descriptions, the DB comment and `init.lua:9` | Keep, except `init.lua:9` ("PokeTibia" in the fatal dialog), which is renamed with that line in 2.1 |
| USER-FACING BRANDING | 31 | `server/runtime-data/data/items/items.xml:517` "flag of Tibia", `:1195-1207` "The Mystic Secrets of Tibia" (5), `:2293` "Royal Tibia Mail.", `:2768`, `:3326` "gods of Tibia", `:3835` "tibian post officers", `:8364`, `:8556`, `:10497` "tibia doll", `:14859`, `:14898` "TibiaBR", `:14862`, `:14893` "tibiacity encyclopedia", `:14863`, `:14894`, `:14870-14871` "TibiaHispano", `:14881`, `:14886` "Tibia Nordic", `:15964` "Tibia ML", `:16763` "TibiaLottery" (25 lines); the 6 "dash in tibia community" locale lines in the legacy client (orphan, never displayed) | **Flagged:** the 25 `items.xml` lines are MANUAL REVIEW (reword or remove if the items can be obtained; UNVERIFIED). The locale lines are KEEP - UPSTREAM ENGINE because nothing displays them. Redemption `createAccount.otui:155` "Tibia Service Agreement" is MANUAL REVIEW (section 2.2). |

No player-facing "Tibia" text was found in the legacy client UI, the window titles, the login screens or the server's chat and NPC text.

---

## 5. Client identity

| Aspect | Legacy client (`client/`) | Redemption client (`client-redemption/`) | Server | Recommended PokeVerse value |
|---|---|---|---|---|
| Window title | `modules/client/client.lua:85` `"Pokémon Jornadas"`; in game `modules/client_background/background.lua:38` `"Pokémon Jornadas \| Jogador: "..name`; the harness build prefixes `[HARNESS - NOT FOR DISTRIBUTION]` in `x11window.cpp`/`win32window.cpp` (`docs/CLIENT_VARIANTS.md:26`) | `modules/startup/startup.lua:65` `g_window.setTitle(g_app.getName())` → `"OTClient - Redemption"`; live reload `src/framework/core/modulemanager.cpp:150` appends " (LIVE RELOAD ENABLED)"; debug builds append " (DEBUG MODE)" (`application.h:50-52`) | — | `"PokeVerse"` / `"PokeVerse \| Jogador: "..name`. Update `tools/smoke_login.sh:40` and `.github/workflows/platforms.yml:267,270`. |
| Application name | `client/source/src/main.cpp:86` `g_app.setName("Pokecenter")` | `init.lua:100` `g_app.setName("OTClient - Redemption")` (default `application.h:81`) | — | `"PokeVerse"` |
| Compact name / org | `main.cpp:87` `g_app.setCompactName("Pokecenter")` | `init.lua:101` `setCompactName("otclient")`, `init.lua:102` `setOrganizationName("otcr")` | — | `"pokeverse"` (lowercase, like the `pokeverse-client` executables and the `pokeverse` database); org `"pokeverse"` |
| User / settings directory | `init.lua:13` `setupUserWriteDir(compactName)` → Linux `~/.Pokecenter/` (holds `config.otml`, minimap, harness files); Windows `<PHYSFS user dir>\Pokecenter\` (UNVERIFIED) | `init.lua:142` → `PHYSFS_getPrefDir("otcr","otclient")` + `.otclient/` (Linux) or `otclient/` (Windows) (`resourcemanager.cpp:352-385,746-757`); `--user-dir` overrides | — | Legacy `~/.pokeverse`; Redemption under `pokeverse/pokeverse`. **Migrate old settings** (copy the old directory on first start) and update `tools/smoke_login.sh:26`, `tools/runtime_test.sh:14`, `docs/BUILD_BASELINE.md:60`. |
| Log file | `init.lua:16` `userDir .. compactName .. ".log"` → `~/.Pokecenter/Pokecenter.log` | `init.lua:109` `workDir .. "otclient.log"` | `config.lua` `outLogName = ""` (console) | follows the compact name: `pokeverse.log` |
| Crash log | `framework/platform/unixcrashhandler.cpp:45,108-111` writes `crash_report.log` with `== application crashed` / `app name: <g_app.getName()>`; Windows `win32crashhandler.cpp:126-127,147,161` writes `crashreport.log` and shows "Application crashed"; old sample `client/runtime-data/crashreport.log:2` `app name: Pokecenter` (git-ignored) | `unixcrashhandler.cpp:45,108`, `win32crashhandler.cpp:141,178,194` (same pattern) | — | No direct edit: the header follows `setName("PokeVerse")`. The file names `crash_report.log`/`crashreport.log` and "Application crashed" are KEEP - UPSTREAM ENGINE. |
| Login screen branding | `client_entergame/images/logo.png` (`entergame.otui:11-13`) and `client_background/images/logo.png` (`background.otui:288-290`): **"POKÉMON JORNADAS" logo images**; `client_background/background.lua:12` label `"Build: 0.0.1"`; slide images contain placeholder "Lorem Ipsum" text (`client_background/images/slide/text_*.png`) | `client_bottommenu/bottommenu.otui:50` caption `"OTClient Redemption"`; `client_background/background.lua:14` version label `g_app.getName() .. ' ' .. version`; `data/images/background.png` (fantasy art); `createAccount.otui:155` Tibia agreement | — | New PokeVerse logo images (245×99 and 446×186); caption `"PokeVerse"`; replace background art (MANUAL REVIEW) |
| Window icon | `data/images/clienticon.png` (`client.lua:87`), exe icon `client/source/src/otcicon.ico` / `otcicon.rc` | `data/images/clienticon.png` (OTClient knight), `cmake/icon/otcicon.ico` | — | PokeVerse icon (MANUAL REVIEW) |
| Executable / output name | CMake `client/source/CMakeLists.txt:2` `project(otclient)` → `build/client*/otclient`, installed as `dist/client*/pokeverse-client[-debug\|-harness]` by `tools/build_client.sh:21-33` | CMake `client-redemption/src/CMakeLists.txt:1` `project(otclient)` → `otclient[.exe]`, staged as `dist/client-redemption*/pokeverse-client[-debug][.exe]` by `tools/stage_redemption.sh:13-14,22`; macOS bundle `OTClient` (`src/CMakeLists.txt:1056-1076`); Android label `otclient` (`strings.xml:2`) | CMake `server/source/CMakeLists.txt:2` `project(pokeverse-server CXX)`, `:20` `add_executable(pokeverse-server …)`; legacy autotools `Makefile.am:1` `theforgottenserver` | Already PokeVerse for Linux/Windows dist names; keep the CMake target names (KEEP - UPSTREAM ENGINE); macOS/Android labels MANUAL REVIEW |
| Launcher / updater | `modules/game_updater/updater.otui:61-62` uses the "POKÉMON JORNADAS" `images/logo.png`, text "Downloading update files. Please wait." (`:55`); C++ updater URL `client/source/src/client/game.cpp:75` `"http://localhost/otclient/" + dir` | `modules/updater/` inactive (`Services.updater` commented, `init.lua:6`); `Services.status`, `websites`, `createAccount`, `getCoinsUrl` commented (`init.lua:7-10`) | — | Replace the logo; updater URL is a placeholder, set it to `TODO - POKEVERSE URL REQUIRED` once an update server exists (MANUAL REVIEW) |
| Login / entergame | `client_entergame/entergame.lua:197` default host `127.0.0.1`; MOTD from the server (`:29-31`, `:58`) | `init.lua:76-97` `Servers_init` (`http://127.0.0.1/login.php`, protocol 1511) | — | No old branding |
| Server name / MOTD | — | — | `server/runtime-data/config.lua:103` `serverName = "Cristal"`; `:99` `motd = "Sejá bem vindo ao PokeCenter - MMORPG"`; `:104` `loginMessage = "Bem-vindo ao PokeCenter, …"`; `:316` `ownerName = "PokeCenter"`; `:317` `ownerEmail = "contact@pokecenter.net"`; `:318` `url = "http://www.pokecenter.net/"`; `:319` `location = "EUA"`; no `worldName` key exists in this TFS 0.3.6 config (`serverName` plays that role) | motd/loginMessage: "…ao PokeVerse…"; ownerName `"PokeVerse"`; ownerEmail and url `"TODO - POKEVERSE URL REQUIRED"`; serverName MANUAL REVIEW |
| Outdated-client message | — | — | `server/source/resources.h:81` "…please visit http://www.psoul.net…" | "…please visit TODO - POKEVERSE URL REQUIRED…" |
| Server status / console | — | — | `resources.h:83-86` `STATUS_SERVER_NAME "Unknown"`; `otserv.cpp:140,443,462-464` banner; `protocolhttp.cpp:48,59` "The Forgotten Server httpd" | Keep (KEEP - UPSTREAM ENGINE) |
