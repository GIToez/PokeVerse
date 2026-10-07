# Translation Audit (Portuguese → canonical English)

Scope: everything in this repository: `server/source` (TFS 0.3.6 C++), `server/runtime-data` (config, Lua/XML datapack, `pt_br.loc`, SQL), `client/` (OTClient-based PokeJornadas client), `client-redemption/`, `database/`, `tools/`, `docs/`.

Policy assumed by this audit:

- English is canonical for server code, admin/GM text, config, logs, tools, docs and comments.
- Players keep a language choice. The Portuguese localization (`pt_br.loc`, client `pt.lua`, tutorial `content/pt`) stays.
- Identifiers, storage keys, protocol/opcode payload keys, engine-read XML attribute values, DB columns, file/asset paths and command words already sent by the client are **KEEP - COMPATIBILITY**. They are not translated in place.

Files were read as latin-1 where needed. Many server Lua files are latin-1 and some are UTF-8; `shutdown.lua` and `items.xml` are UTF-8. Items marked **UNVERIFIED** were inferred from code reading and were not exercised at runtime.

Line counts come from a regex scanner for Portuguese words and diacritics, reviewed by hand. Counts are "lines containing Portuguese", not unique strings, unless stated otherwise.

---

## 1. How localization works today

### 1.1 Server

| Piece | Location | Notes |
|---|---|---|
| Language enum | `server/source/localization.h` | `LANG_EN_US = 0`, `LANG_PT_BR = 1`, `LANG_ES_ES = 2`. An older `__L_*` enum scheme is still present but commented out. |
| Dictionary loader | `server/source/localization.cpp` | Opens **`pt_br.loc`** by a relative path, from the server working directory (`server/runtime-data/pt_br.loc`). Format: one entry per line, `English text@Portuguese text`, CRLF, latin-1. `\n` in the file is unescaped to a newline. 6906 entries; no line has more than one `@`. The `es_es` map exists but nothing loads into it. |
| Lookup | `Localization::t(lang, str)` | **Exact, whole-string match** on the English text. If there is no match, or the language is EN, the English input is returned unchanged. ES has no data, so it always falls back to English. |
| Singleton | `server/source/otserv.cpp:758` | Created at startup. |
| Explicit C++ call sites | `Localization::t` | game.cpp 45, player.cpp 137, item.cpp 22, chat.cpp 44, quests.cpp 4, monster.cpp 4, monsters.cpp 2, npc.cpp 1, protocolgame.cpp 1, luascript.cpp 1. |
| **Implicit per-player localization** | `server/source/player.h` | Inline `sendCancel` (≈l.683), `sendFYIBox` (≈l.707) and `sendTextMessage` (≈l.719) all pass the message through `Localization::t(language, msg)`. NPC speech to one player is localized in `npc.cpp:1801`. |
| Lua API | `luascript.cpp:2832-2838` | `__L(cid, str)`, `getPlayerLanguage(cid)`, `setPlayerLanguage(cid, id)`. |
| Lua constants | `data/lib/ps/others/constants.lua` | `LANG_IDS = {EN_US=0, PT_BR=1, LAST=PT_BR}`, `LANG_CODES = {portugues=…, english=…}`. |
| Storage | DB `accounts.lang_id` (tinyint, default 0) | Read and written by `IOLoginData::getAccountLanguage` / `setAccountLanguage`. Copied to the player on game login (`protocolgame.cpp:294`) and written back on save (`player.cpp:1586`). |
| Selection: login | `protocollogin.cpp:86-88, 369-371` | If the client OS byte is 0x0A-0x0C (OTClient) and the protocol is ≥ 293, one language byte is read. If it differs from the stored value, the account is updated. **So the client UI locale overwrites the account language at every login.** |
| Selection: in game | `/lang` → `talkactions/scripts/setLanguage.lua` | Accepts `english` / `portugues`. Accents are stripped but case is not normalised, so `/lang English` fails. Because of the login override above, the choice only lasts until the next login (UNVERIFIED end-to-end, but follows from the code). |

**Are server messages localized per player?** Partly, and implicitly:

- Localized when the **complete final string** equals a `pt_br.loc` key. That covers anything sent through `doPlayerSendTextMessage`, `doPlayerSendCancel`, `doPlayerPopupFYI`, `doBroadcastMessage` (which loops `sendTextMessage` per player, `game.cpp:5810`) and `selfSay(msg, cid)`.
- Strings built by concatenation (`"You got " .. n .. " items"`) never match, unless the script calls `__L()` on the constant part first.
- **Not localized:** `doCreatureSay` / channel talk, animated text, text dialogs, extended-opcode JSON payloads, the `motd` in the character list, and anything already written in Portuguese.
- Lua uses `__L(cid, "...")` in 743 places (475 distinct literal keys). About 26 of those keys are missing from `pt_br.loc`, some only because of escape/whitespace differences (UNVERIFIED per key).
- About 240 C++ send-calls hard-code English and rely on the implicit wrapper.

A hard-coded Portuguese string is therefore sent **in Portuguese to every player, including English players**. That is the main defect this audit tracks (section 4).

### 1.2 Client

| Piece | Location | Notes |
|---|---|---|
| Locale module | `client/runtime-data/modules/client_locales/locales.lua` | Global `tr(text, ...)` looks up `currentLocale.translation[text]`, falls back to `text`, then applies `string.format`. |
| Locale files | `client/runtime-data/data/locales/*.lua` | `en` (id 0, empty table), `pt` (id 1, 1690 entries keyed by English), `es`, `de`, `sv`, `pl` (all declare id 2, so the server sees them as ES and falls back to English). |
| Persistence | `g_settings` key `locale` (config.otml) | A language picker appears on first run. The language cannot be changed while online. |
| Sent to server | `modules/gamelib/protocollogin.lua:225` | `msg:addU8(getCurrentLocale().id)` after the OS / version 312 fields. The `sendLocale` extended-opcode path is commented out. |
| Server text | — | The client does **not** translate server-sent text. |
| Tutorial | `modules/game_tutorial/content/{en,pt}` | 39 files each, selected by locale name. Properly PLAYER LOCALIZED. |
| Anti-pattern | `modules/game_shop/*.otui` and several modules | Portuguese strings are used **as `tr()` keys** (e.g. `tr('Você não consegue alterar a cor dessa roupa')`), so English players see Portuguese. Other modules have Portuguese with no `tr()` at all. |

---

## 2. Summary counts

### 2.1 By class

| Class | Approx. lines / items | Main locations |
|---|---|---|
| ADMIN | ~15 | `talkactions.xml` house descriptions (7), `shutdown.lua` PT broadcasts (3), `pass35/50.lua` usage (2), `/evolve` description (wrong, English) |
| DEVELOPER | ~8 | `lib/ps/events/talkactions/teste.lua`, 4 client `.otmod` descriptions, `/profission` debug talkaction |
| LOG | 0 Portuguese found | Server console/log output is English. Client logs are English except the fatal message (counted under ERROR). |
| ERROR | 3 | `protocollogin.cpp:167,176`; client `init.lua:9` fatal |
| COMMENT | ~300 | Server Lua ~265 (profission/coleta 169), `config.lua` 2, `XML/tournaments.xml` ~22, C++ 1 server + 6 client, client `game_pass/pass.lua` |
| PLAYER LOCALIZED | 6906 + 1690 entries, 39 files, ~450 lines | `pt_br.loc`, client `pt.lua`, tutorial `content/pt`, `002-wikiChat.lua` (199), NPC input keywords (251 lines / 231 files) |
| NPC | ~150 send lines | 8 daily NPC scripts (~108), `professorTommy.lua` (15, mojibake), 2 NPC XML greets |
| QUEST | ~60 | Task/daily/pass/dungeon: `taskModule.lua`, `task_kill.lua`, `pokemonTaskKill.lua`, `NpcSerioKill.lua`, `presente*.lua`, `RAMDOMBOX.lua`, `game_pass.lua`, `game_dungeon.lua` |
| CONTENT | ~1,300 lines (~200 unique strings) | `game_market.lua`, `game_craft.lua`, profession/coleta, depot, shop/outfits, `items.xml` (25), `outfits.xml` (24), config motd/loginMessage, client shop otui (~820 lines / ~24 unique keys), `pokekill.lua` (151 Pokédex texts), other client modules (~100) |
| HISTORICAL | ~435 | phpMyAdmin pt-BR comments in the two SQL dumps (~430), `tools/verify_import.py` original paths, docs quoting original filenames |
| THIRD-PARTY | ~210 | `client-redemption/` upstream locales (176) and modules (~30) |
| KEEP - COMPATIBILITY (cross-cutting) | ~120 distinct tokens | Opcode / protocol codes, buffer tags, client-sent param keys, obfuscated house command words, table field names, file and asset paths, channel names |

### 2.2 By area

| Area | PT lines (approx.) | Player-facing hard-coded sends | Notes |
|---|---|---|---|
| `server/source` (C++) | 3 | 2 | 2 disconnect errors and 1 comment |
| `server/runtime-data/config.lua` | 4 | 2 (motd, loginMessage) | 2 comments |
| `data/talkactions` | ~40 | 27 | Plus 7 XML descriptions |
| `data/lib` (incl. `lib/ps`) | ~650 | ~190 | Market, craft, dungeon, profession, dailies, depot |
| `data/npc` | ~400 | ~108 (+15 Tommy) | Plus 251 keyword lines (PLAYER LOCALIZED) |
| `data/creaturescripts` | ~20 | 7 | Plus a comment in `login.lua:49` |
| `data/actions` | ~45 | 7 | Plus ~26 outfit `nome` entries |
| `data/movements`, `globalevents` | ~25 | 7 bilingual pairs (`globalMessages.lua`) | Mostly comments |
| `data/XML`, `data/items` | ~75 | — | Tournaments comment, outfit / item names, channel "Troca" |
| `pt_br.loc` | 6906 | — | PLAYER LOCALIZED |
| SQL dumps (`database/`, `runtime-data/poketibia.sql`) | ~432 each | 2 rows (`server_motd`) | Identical files |
| `client/runtime-data/modules` | ~1,100 | — | Shop otui, pokekill, ~15 other modules |
| `client/runtime-data/data/locales` | 1690 | — | PLAYER LOCALIZED |
| `client/src` (C++) | 6 | — | Comments |
| `client-redemption/` | ~210 | — | THIRD-PARTY |
| `tools/`, `docs/` | ~10 | — | HISTORICAL. `tools/smoke_login.sh:66-68` depends on "Jogador:" |

---

## 3. Classification table

Paths are relative to `server/runtime-data/data/` unless they start with `server/`, `client/`, `database/` or `tools/`. Groups with many lines are summarised by directory with counts and examples.

### 3.1 ADMIN

| File:line | Text (short) | Class | Canonical-English action | Suggested English | Notes |
|---|---|---|---|---|---|
| talkactions/talkactions.xml:156 | "Compre uma casa se estiver na frente dela." | ADMIN | TRANSLATE | "Buy the house you are standing in front of." | `description` is shown by `/commands`. The `words` attribute stays as-is. |
| talkactions/talkactions.xml:157 | "Vender casa propria atual." | ADMIN | TRANSLATE | "Sell your current house." | |
| talkactions/talkactions.xml:158 | "Chute a si mesmo ou a alguem de casa." | ADMIN | TRANSLATE | "Kick yourself or another player out of the house." | |
| talkactions/talkactions.xml:159 | "Liste os jogadores que podem abrir a porta." | ADMIN | TRANSLATE | "List the players allowed to open this door." | |
| talkactions/talkactions.xml:160 | "Lista de hospedes da casa." | ADMIN | TRANSLATE | "Edit the house guest list." | |
| talkactions/talkactions.xml:161 | "Lista de proprietarios de casas." | ADMIN | TRANSLATE | "Edit the house sub-owner list." | |
| talkactions/talkactions.xml:162 | "Abandone a casa atual." | ADMIN | TRANSLATE | "Leave (abandon) your current house." | |
| talkactions/talkactions.xml:156-162 | `buyhouseewqnml`, `fsellhousedwq`, `chutarrrase`, `portassdawt`, `hospedeseeq`, `subdonoeqwxv`, `abandonarweqn` | ADMIN | KEEP - COMPATIBILITY | — | Obfuscated words the client sends (`game_house`, `housebuy`, `houseowner`, `houseownerenter`). Change only together with the client. |
| talkactions/talkactions.xml:28 | `/evolve` description "Show Pokemon addons." | ADMIN | TRANSLATE (fix) | "Evolve your active Pokémon." | English, but a copy-paste error from `/addon`. |
| talkactions/scripts/shutdown.lua:38,41,44 | "O servidor vai cair em … minutos para atualização…" | ADMIN | MOVE TO LOCALIZATION | "Server is going down in %d minute(s) for an update. Please log out now. We will be back in 10 minutes." | PT and EN versions are both broadcast to everyone. Keep one English line (fix "We will back") and add a `pt_br.loc` key, or use per-player `__L`. Needs a fixed key, i.e. no concatenation. |
| talkactions/scripts/pass/pass35.lua:12, pass50.lua:12 | "Comando precisa de parametros: nomedoplayer, iddoitem, quantidade." | ADMIN | TRANSLATE | "Usage: /SendPass35 <player name>" (and /SendPass50) | Also wrong: the only argument is a player name. |
| talkactions/scripts/task_mod/teste.lua | test strings | ADMIN | TRANSLATE or delete | — | Not registered. |

### 3.2 DEVELOPER

| File:line | Text (short) | Class | Canonical-English action | Suggested English | Notes |
|---|---|---|---|---|---|
| lib/ps/events/talkactions/teste.lua:3 | "Mensagem boladamente bolada para teste" | DEVELOPER | TRANSLATE (or remove the talkaction) | "Test broadcast message" | Registered as `showbuywindowhouse` with no access check, so **any player can broadcast this to everyone**. Security issue: restrict or remove. |
| client/runtime-data/modules/game_bottommenu/*.otmod, game_depotlock, game_dungeon, game_pokemonInfo | Portuguese `description:` | DEVELOPER | TRANSLATE | e.g. "Depot lock window", "Dungeon window" | Module metadata only. |
| talkactions `/profission` → testeprofission | (code) | DEVELOPER | — | — | Debug talkaction that calls `learnWork(cid,1)` for any player. Security issue: restrict to access ≥ 4 or remove. |

### 3.3 ERROR

| File:line | Text (short) | Class | Canonical-English action | Suggested English | Notes |
|---|---|---|---|---|---|
| server/source/protocollogin.cpp:167 | "Erro CreateAcc.xml report ao adm." | ERROR | TRANSLATE | "Server error: CreateAcc.xml could not be loaded. Please report this to an administrator." | Disconnect reason shown to the player at login. The player language is not known yet, so English is correct. |
| server/source/protocollogin.cpp:176 | "Erro town report ao adm." | ERROR | TRANSLATE | "Server error: invalid town configuration in CreateAcc.xml. Please report this to an administrator." | Same. |
| client/runtime-data/init.lua:9 | `g_logger.fatal("O aplicativo não pode ser iniciado corretamente … Equipe PokeJornadas BRAZIL …")` | ERROR | TRANSLATE | "The application could not be started correctly. Please reinstall the client." | Fatal log; also mentions the old team name. |

### 3.4 COMMENT

| File:line | Text (short) | Class | Canonical-English action | Suggested English | Notes |
|---|---|---|---|---|---|
| server/runtime-data/config.lua:238 | "NOTA: blessingReduction * refere-se à perda de itens / recipientes." | COMMENT | TRANSLATE | "NOTE: blessingReduction* refers to item/container loss." | latin-1 file |
| server/runtime-data/config.lua:239 | "eachBlessReduction é o quanto cada bênção reduz a perda de experiência / magia / habilidades." | COMMENT | TRANSLATE | "eachBlessReduction is how much each blessing reduces experience/magic/skill loss." | |
| XML/tournaments.xml:150-172 | "habilitado: se está funcionando ou não", "contagem: contagem", … | COMMENT | TRANSLATE | Restore the real attribute names: `enabled`, `count`, `reason`, `unique`, `days` | The PT comment *mistranslates the attribute names*, which is misleading. Attribute values stay unchanged. |
| server/source/protocolgame.cpp:2916 | `//std::cout << "ATENCAO - known esta no fim da lista"` | COMMENT | TRANSLATE | `// "WARNING - known creature is at the end of the list"` | Dead debug line; could also be deleted. |
| client/src/client/download.cpp (5), client/src/client/game.cpp:172 (1) | Portuguese comments | COMMENT | TRANSLATE | — | |
| lib/ps/profission/actions/coleta/*.lua | 169 comment lines (minerios.lua 111, moitas.lua 24, lockpick.lua 19, others 15) | COMMENT | TRANSLATE | — | Largest comment group, mostly table annotations. |
| lib/057-Module_Kill.lua (10), lib/bannerExp (8), movements doreletric (10), creaturescripts shop.lua (3), lib/game_pass.lua (4), others | ~90 lines | COMMENT | TRANSLATE | — | |
| creaturescripts/scripts/login.lua:49 | commented-out PT FYI | COMMENT | TRANSLATE or delete | — | |
| creaturescripts/scripts/dailys/task_kill.lua | comment | COMMENT | TRANSLATE | — | |
| client/runtime-data/modules/game_pass/pass.lua | comments | COMMENT | TRANSLATE | — | |

### 3.5 PLAYER LOCALIZED (keep)

| File:line | Text (short) | Class | Canonical-English action | Suggested English | Notes |
|---|---|---|---|---|---|
| server/runtime-data/pt_br.loc (6906 lines) | `English@Português` | PLAYER LOCALIZED | KEEP - player localized | — | English is already the key; add new keys here when moving strings. |
| client/runtime-data/data/locales/pt.lua (1690) | `["English"] = "Português"` | PLAYER LOCALIZED | KEEP - player localized | — | |
| client/runtime-data/modules/game_tutorial/content/pt/* (39 files) | tutorial pages | PLAYER LOCALIZED | KEEP - player localized | — | An `en` copy exists. |
| lib/ps/config/002-wikiChat.lua (199 literals) | in-game wiki dialog tree | PLAYER LOCALIZED | KEEP - player localized | — | The player picks the PT or EN branch. It could later be keyed through `__L`. |
| npc/scripts/** and npc/lib (251 lines in 231 files) | `msgcontains(msg,'sim')`, `'nao'`, `'batalha'`; `npcsystem.lua` `SHOP_YESWORD={'yes','sim'}`, `SHOP_NOWORD={'no','nao'}`; `002-quest.lua` KEYWORDS | PLAYER LOCALIZED | KEEP - player localized | — | Accepted input words. Removing them breaks Portuguese players. |
| lib/ps/events/globalevents/globalMessages.lua (7 PT/EN pairs) | rotating tips, both languages broadcast | PLAYER LOCALIZED | MOVE TO LOCALIZATION | Keep the English line and add the PT text to `pt_br.loc` | `doBroadcastMessage` already localizes per player when the key matches exactly, so the PT duplicate is not needed. |
| lib/ps/events/creaturescripts/onJoinChannel.lua:86 (3 lines) | "Digite /commands para visualizar os comandos. / Type /commands to view…" | PLAYER LOCALIZED | MOVE TO LOCALIZATION | "Type /commands to view the commands." | Channel text is not auto-localized, so use `__L(cid, …)`. |

### 3.6 NPC

| File:line | Text (short) | Class | Canonical-English action | Suggested English | Notes |
|---|---|---|---|---|---|
| npc/scripts/daily.bernardo.lua, daily.dalkon.lua, daily.leticia.lua (14 each), daily.natasha.lua (13); e.g. l.53 | "Olá treinador, você não pode iniciar uma tarefa comigo, você é muito f…" | NPC | MOVE TO LOCALIZATION | "Hello trainer, you cannot start a task with me yet; you are too weak…" | `selfSay(msg, cid)` is auto-localized, so write the English and add a `pt_br.loc` line. Level numbers are literals and must stay exact for a match. |
| npc/scripts/Daily.catch.{Kendall,Edsel,Beverly,Alekson}.lua (13 each); e.g. l.46 | "Olá treinador, você precisa ter pelo menos lvl 150 …" | NPC | MOVE TO LOCALIZATION | "Hello trainer, you must be at least level 150 to start…" | As above. |
| npc/scripts/professorTommy.lua:38 + 14 more | "{PT-BR}: Voc� est�� nesta ilha…" / "{EN-US}: …" | NPC | MOVE TO LOCALIZATION | Keep the EN half and move the PT half to `pt_br.loc` (re-typed, because of mojibake) | The live code is **mojibake** (`ï¿½`), so the PT text is corrupted for players today. |
| npc/Professor Tommy.xml (greet) | bilingual greet | NPC | MOVE TO LOCALIZATION | English greet | |
| npc/Pokemon Creator.xml | "Diga o nome do Pokemon desejado." | NPC | MOVE TO LOCALIZATION | "Say the name of the Pokémon you want." | |
| npc/*.xml (910), npc/scripts (346) | mostly English | NPC | — | — | 64 scripts already use `__L`. |

### 3.7 QUEST

| File:line | Text (short) | Class | Canonical-English action | Suggested English | Notes |
|---|---|---|---|---|---|
| talkactions/scripts/task_mod/taskModule.lua:16 (+2) | "Vá derrotar todos os …", "Você terminou a missão de …", "Missão do … cancelada" | QUEST | MOVE TO LOCALIZATION | "Go defeat all the %s.", "You finished the %s task.", "%s task cancelled." | Use `__L` on a format string, then `string.format`. |
| creaturescripts/scripts/dailys/task_kill.lua:15,39 | "Parabéns você achou o Pokémon ditto.", "… colete sua recompensa no painel de missões." | QUEST | MOVE TO LOCALIZATION | "Congratulations, you found the Ditto!", "Congratulations, you completed your task. Collect your reward in the task panel." | |
| creaturescripts/scripts/dailys/pokemonTaskKill.lua:10 (+1) | "[Caça Pokémon]: …" | QUEST | MOVE TO LOCALIZATION | "[Pokémon Hunt]: …" | |
| creaturescripts/scripts/dailys/NpcSerioKill.lua:26 | "Você matou …" | QUEST | MOVE TO LOCALIZATION | "You defeated %d/%d …" | |
| lib/ps/functions/ball/empty.lua:116 (+1) | "Você capturou o pokémon, volte e entregue a sua missão." | QUEST | MOVE TO LOCALIZATION | "You caught the Pokémon. Go back and hand in your task." | |
| lib/ps/events/actions/dailys/presente{Kendall,Edsel,Alekson,Beverly,Natasha,Dalkon,Bernardo,Leticia}.lua, RAMDOMBOX.lua (~22 literals, 20 sends) | "Você não tem espaço suficiente!", "Para abrir este presente você precisa coloca-lo na mochila." | QUEST | MOVE TO LOCALIZATION | "You do not have enough space!", "To open this gift you must put it in your backpack." | Spelling varies (Voce/Você); normalize to one English key. |
| lib/game_dungeon.lua (17 sends), e.g. l.159 | "Jogador inválido.", "Este jogador ja foi convidado." | QUEST | MOVE TO LOCALIZATION | "Invalid player.", "This player has already been invited." | |
| lib/game_pass.lua (8) | mission / item `desc` strings sent to the client | QUEST | MOVE TO LOCALIZATION | — | Sent by opcode, so not auto-localized. Pick per player with `__L` before sending. |
| talkactions/scripts/task_mod/* buffers | `[CompleteiAMissao]`, `[TaskNaoCompleta]`, `[MissaoAbandonada]`, `[PegueiUmaMissao]`, `[unlockRank]`, `[unlockedRanks]`, `[delayTask]`, `[pointsHave]` | QUEST | KEEP - COMPATIBILITY | — | Client parses these tags. |
| lib/game_pass.lua, talkactions/scripts/pass/* | `SucessSendPass`, `OffLinePlayer`, `NoDiamondsPass`, `NoDiamondsBuyPass`, `HassMission`, `NoMission`, `Pass35Buyed`, `Pass50Buyed`, `NoVipCollect`, `NoPass`, `NoDiamonds` | QUEST | KEEP - COMPATIBILITY | — | Protocol codes, including the misspellings. |

### 3.8 CONTENT

| File:line | Text (short) | Class | Canonical-English action | Suggested English | Notes |
|---|---|---|---|---|---|
| server/runtime-data/config.lua:99 | `motd = "Sejá bem vindo ao PokeCenter - MMORPG"` | CONTENT | TRANSLATE | "Welcome to PokeCenter - MMORPG" | Sent in the character list; not localizable today. Note `serverName = "Cristal"`. |
| server/runtime-data/config.lua:104 | `loginMessage = "Bem-vindo ao PokeCenter, torne-se um mestre pokémon…"` | CONTENT | MOVE TO LOCALIZATION | "Welcome to PokeCenter! Become a Pokémon master: complete the missions, finish the quests and explore our cities." | Sent with `doPlayerSendTextMessage` (`login.lua:43-45`), so an EN value plus a `pt_br.loc` key localizes it. |
| lib/game_market.lua (51 sends / 62 literals), e.g. l.222 | "Item de mercado inválido" | CONTENT | MOVE TO LOCALIZATION | "Invalid market item." | Largest single file. |
| lib/game_craft.lua (21 / 33), e.g. l.60 | "Você não tem profissão." | CONTENT | MOVE TO LOCALIZATION | "You do not have a profession." | |
| lib/ps/profission/actions/coleta/*.lua (~54 literals: minerios 25, moitas 8, caderno 6, lockpick 5, cavando 4, baucavado 4, arvore 2) | ", Preciso coletar esse minério!", "Você precisa está na frente do arbusto!" | CONTENT | MOVE TO LOCALIZATION | ", I need to mine this ore!", "You must be in front of the bush!" | Some are `doCreatureSay` (not auto-localized), so use `__L`. |
| talkactions/scripts/deposito/depot_passworld.lua (12 + help text), e.g. l.6 | "Você deve estar perto de um depósito…", "Locker System … Criando uma senha …" | CONTENT | MOVE TO LOCALIZATION | "You must be near a depot to use this system." | |
| talkactions/scripts/deposito/depot_release.lua (2) | "Seu depósito já está destravado." | CONTENT | MOVE TO LOCALIZATION | "Your depot is already unlocked." | |
| lib/060-Depot_locker.lua (6) | "Senha correta, depósito liberado.", "Depósito bloqueado, tente novamente em %s." | CONTENT | MOVE TO LOCALIZATION | "Correct password, depot unlocked.", "Depot locked, try again in %s." | |
| talkactions/scripts/leavehouse.lua:5 (+1) | "Você não está dentro de uma casa." | CONTENT | MOVE TO LOCALIZATION | "You are not inside a house." | |
| talkactions/scripts/stacke.lua:7 | "Você tem …" | CONTENT | MOVE TO LOCALIZATION | "You have %d …" | |
| lib/ps/events/talkactions/guardianTime.lua:3 (+1) | "Seu Guardian Possui (…) Minutos Restantes.", "Voce nao possui nenhum GUARDIAN ativo no momento." | CONTENT | MOVE TO LOCALIZATION | "Your Guardian has %d minutes left.", "You have no active Guardian." | |
| lib/guardian.lua:31 (+1) | "Seu Guardian não Foi Sumonado, por você estar dentro de uma house." | CONTENT | MOVE TO LOCALIZATION | "Your Guardian was not summoned because you are inside a house." | |
| lib/game_work.lua:99 (+1), lib/game_pokemonInfo.lua:640 | "Você avançou em …", "Seu pokemon avançou em amizade do nivel …" | CONTENT | MOVE TO LOCALIZATION | "You advanced to %s level %d.", "Your Pokémon advanced to friendship level %d." | |
| lib/ps/events/actions/card/cardcharizard.lua:8 (+2) | "Voce nao pode usar o card, com 1 guardado no fly" | CONTENT | MOVE TO LOCALIZATION | "You cannot use this card while one is stored in fly." | |
| lib/ps/events/actions/clothesKit.lua:66 (+1) | "Você já possui esta roupa." | CONTENT | MOVE TO LOCALIZATION | "You already own this outfit." | |
| actions/scripts/shop/roupas_loja.lua:137 (+2); ~26 `nome` entries; `sexname` "masculino"/"feminino" | "Você deve ser do gênero …", "Cirurgião da Morte" | CONTENT | MOVE TO LOCALIZATION (messages); KEEP - content (needs translator) (outfit names) | "You must be %s to use this outfit." | `sexname` is interpolated into a message: localize it or restructure the sentence. The `nome` / `sexo` field names are KEEP - COMPATIBILITY. |
| actions/scripts/shop/roupas_loja_duplo.lua:9 (+1) | "Parabéns! Você tem uma nova roupa: …" | CONTENT | MOVE TO LOCALIZATION | "Congratulations! You received a new outfit: %s" | |
| actions/scripts/banners/xpplank.lua:4 (+1), creaturescripts/scripts/bannerexp.lua:14 | "Você já está usando um XP Banner!", "Você saiu do alcance, seu Banner quebrou!" | CONTENT | MOVE TO LOCALIZATION | "You are already using an XP Banner!", "You left the range; your Banner broke!" | |
| creaturescripts/scripts/shop.lua:20 | "Desculpe mas você não tem Diamonds suficientes…" | CONTENT | MOVE TO LOCALIZATION | "Sorry, you do not have enough Diamonds to buy this outfit." | |
| items/items.xml (25 names, UTF-8), e.g. 34602 "mãe dos dragões", 35547 "maça" | item names | CONTENT | KEEP - content (needs translator) | "mother of dragons", "apple" | Check scripts that look items up by name (`getItemIdByName`) before renaming. UNVERIFIED. |
| XML/outfits.xml (24 names) | outfit names | CONTENT | KEEP - content (needs translator) | — | Same check: are outfits referenced by name? |
| XML/channels.xml | channel "Troca"; also "Game-Chat[PT-BR]" | CONTENT | KEEP - COMPATIBILITY | — | `/autoTrade` hard-codes channel id 5. The display name could become "Trade" if the client does not match on the name (UNVERIFIED). |
| database/pokeaventuras.sql, server/runtime-data/poketibia.sql rows `server_motd` 3187-3188 | "Sejá bem vindo ao Pokemon Genesis World, Treinador(a)" | CONTENT | TRANSLATE | "Welcome to Pokemon Genesis World, Trainer!" | Seed data only. |
| client/runtime-data/modules/game_shop/*.otui (~820 lines, ~24 unique keys) | `tr('Você não consegue alterar a cor dessa roupa')` ×230, `tr('Essa roupa possui animação de provocação\nComando: (!taunt)')` ×129, `tr('Depósito utilizado para decoração de casa,…')` ×75, clan tooltips, "Troque o nome do seu personagem." | CONTENT | MOVE TO LOCALIZATION | "You cannot change the colors of this outfit", "This outfit has a taunt animation\nCommand: (!taunt)", "Depot used for house decoration…", "Change your character's name." | Replace the keys with English and add the PT values to `pt.lua`. `!taunt` is not a registered command (see `COMMAND_REFERENCE.md`). |
| client/runtime-data/modules/gamelib/pokekill.lua `POKE_DESCRIPTION` (151) | Pokédex descriptions (mojibake) | CONTENT | KEEP - content (needs translator) | — | Used by `game_task`. Needs re-encoding, plus an EN set chosen by locale. |
| client/runtime-data/modules/game_market | 'Nome', 'Preço Unitário', "Preço: $0" | CONTENT | MOVE TO LOCALIZATION | 'Name', 'Unit Price', "Price: $0" | |
| client/runtime-data/modules/game_dungeon | 'Digite o nome do jogador', "Derrote o Pokémon chefe", "Avançado" | CONTENT | MOVE TO LOCALIZATION | 'Enter the player name', "Defeat the boss Pokémon", "Advanced" | |
| client/runtime-data/modules/game_poke_create (or client_createaccount) | "O nome da conta é obrigatório." … (no `tr`) | CONTENT | MOVE TO LOCALIZATION | "The account name is required." | Wrap in `tr()`. |
| client/runtime-data/modules/game_craft, game_task, game_pokekill, game_bottommenu | "Você deve aguardar …", "Missão de caça", "Missão de Captura" | CONTENT | MOVE TO LOCALIZATION | "You must wait …", "Hunt task", "Catch task" | |
| client/runtime-data/modules/client_updater | "Baixando arquivos de atualização." | CONTENT | MOVE TO LOCALIZATION | "Downloading update files." | |
| client/runtime-data/modules/game_house* | 'Confirmar', "Você realmente quer abandonar esta casa ??", 'Não', " dólares" | CONTENT | MOVE TO LOCALIZATION | 'Confirm', "Do you really want to leave this house?", 'No', " dollars" | |
| client/runtime-data/modules/client_entergame, client_updater, game_interface menu | 'Configurações' | CONTENT | MOVE TO LOCALIZATION | 'Settings' | |
| client/runtime-data/modules/game_depotlock `textos` | security questions | CONTENT | MOVE TO LOCALIZATION | — | Questions are sent by id, so the text is safe to translate. |
| client/runtime-data/modules/game_calendar | month names ("Março"), "Coletar recompensa" | CONTENT | MOVE TO LOCALIZATION | "March", "Collect reward" | |
| client/runtime-data/modules/game_notifications | catch tooltip | CONTENT | MOVE TO LOCALIZATION | — | |
| client/runtime-data/modules/client_background/background.lua:38 | window title "Pokémon Jornadas \| Jogador: "..name | CONTENT | TRANSLATE | "Pokémon Jornadas \| Player: "..name | **`tools/smoke_login.sh:66-68` greps "Jogador: $CHARACTER"**, so change both together. |

### 3.9 HISTORICAL

| File:line | Text (short) | Class | Canonical-English action | Suggested English | Notes |
|---|---|---|---|---|---|
| database/pokeaventuras.sql and server/runtime-data/poketibia.sql (identical, ~430 lines each) | "-- Estrutura da tabela" (141), "-- Índices" (134), "AUTO_INCREMENT de tabela" (60), "Limitadores" (58), "Extraindo dados" (25), "Acionadores" (4), header | HISTORICAL | TRANSLATE (by regenerating the dump with an English phpMyAdmin / `mysqldump`) | — | Do not hand-edit. Schema identifiers are already English. `migrations/` and seeds are clean. |
| tools/verify_import.py | "Servidor/Servidor/" paths | HISTORICAL | KEEP - COMPATIBILITY | — | Refers to the original archive layout. |
| docs/*.md | quoted original filenames | HISTORICAL | KEEP - COMPATIBILITY | — | |

### 3.10 THIRD-PARTY

| File:line | Text (short) | Class | Canonical-English action | Suggested English | Notes |
|---|---|---|---|---|---|
| client-redemption/data/locales/* (176) and modules (~30) | upstream OTClient Redemption translations | THIRD-PARTY | KEEP - player localized | — | Upstream code; do not edit. |
| SQL phpMyAdmin header lines | generator boilerplate | THIRD-PARTY | KEEP (regenerate) | — | |

### 3.11 KEEP - COMPATIBILITY tokens (do not translate in place)

| Group | Tokens | Where |
|---|---|---|
| Pokémon-info opcode codes | `SemDinheiro`, `SemStones`, `SemFoodFriend`, `SemExperience`, `SemDiamond`, `IvReseted`, `BaseReseted`, `Iv`, `Base`, `OpenWindow`, `Mkt`; client fn `doSemDinheiro` | `lib/game_pokemonInfo.lua` ↔ client `game_pokemonInfo` |
| Rename-window codes | `NameComand` + `notifi/jaemuso`, `notifi/pzzone`, `notifi/pelomenos`, `notifi/menosdetres`, `notifi/palavralonga`, `error/nodiamond`, `error/nopokecoin`, `error/letrainvalida`, `error/nomebloqueado`, `error/semvogais`, `error/maisdetres`, `check/comprei` | `talkactions/scripts/shop/name*.lua` ↔ client |
| Task buffers | `[CompleteiAMissao]` … `[pointsHave]` | see 3.7 |
| Pass codes | `SucessSendPass` … `NoDiamonds` | see 3.7 |
| Shop codes and params | `NoVipClas`, `NoReqLevelClas`, `ClaBuySucess`, `GoldRent`, `OpenShop`, `nodiamond`, `purchased`, `sexbuy`; client-sent keys `"sexo"`, `"deposito"`, `"decoracao"`, `"cortina"`, `"resetprofission"`, city names, `"Snorlax"` | `talkactions/scripts/shop.lua` ↔ `game_shop` |
| Depot arguments | `NoPass`, `NoRelease`, `Release` | depot scripts ↔ `game_depotlock` |
| Table fields | `nome`, `sexo`, `sexname`, `quantidade`, `minutos` | Lua tables |
| Files and dirs | `deposito/`, `roupas_loja*.lua`, `presente*.lua`, `coleta/arvore.lua`, `moitas.lua`, `minerios.lua`, … | referenced from XML |
| Image paths | `images/fechar`, `sendpass/alert_text/semnome`, `sucesso`, `selecionar`, `enviar`, `cancelar` | client `.otui` |
| Command words | house obfuscated words, `/cupom`, `/comando`, `/comandos`, `$stackemoney$` | client sends them |
| Channels | "Troca" (id 5), "Game-Chat[PT-BR]" | `channels.xml` |
| Language codes | `LANG_CODES` keys `portugues`, `english`; `/lang` arguments | `constants.lua` |

---

## 4. Player-facing hard-coded Portuguese in server Lua

These are send calls whose literal argument contains Portuguese, sent unchanged to every player. Found by a send-call detector over `doPlayerSendTextMessage`, `doPlayerSendCancel`, `doPlayerPopupFYI`, `selfSay`, `doBroadcastMessage`, `doCreatureSay`/`doPlayerSay`, `doSendCustomBroadcastMessage`. **341 send lines in 53 files; none are wrapped in `__L`.**

By function: `selfSay` 122, `doPlayerSendTextMessage` 92, `doPlayerPopupFYI` 86, `doPlayerSendCancel` 32, `doPlayerSay` 4, `doBroadcastMessage` 3, other 2.

Overall there are 672 Portuguese string literals in server Lua; the rest are table data, names or helper strings.

| Count | File (under `server/runtime-data/data/`) | First line | Example |
|---|---|---|---|
| 51 | lib/game_market.lua | 222 | Item de mercado inválido |
| 25 | lib/ps/profission/actions/coleta/minerios.lua | 13 | , Preciso coletar esse minério! |
| 21 | lib/game_craft.lua | 60 | Você não tem profissão. |
| 17 | lib/game_dungeon.lua | 159 | Jogador inválido. |
| 15 | npc/scripts/professorTommy.lua | 38 | {PT-BR}: Voc� est�� nesta ilha … (mojibake) |
| 14 | npc/scripts/daily.bernardo.lua | 53 | Olá treinador, você não pode iniciar uma tarefa comigo … |
| 14 | npc/scripts/daily.dalkon.lua | 53 | (same) |
| 14 | npc/scripts/daily.leticia.lua | 53 | (same) |
| 13 | npc/scripts/daily.natasha.lua | 53 | Olá treinador, você precisa ser pelo menos nível 150 … |
| 13 | npc/scripts/Daily.catch.Kendall.lua | 46 | … pelo menos lvl 150 … |
| 13 | npc/scripts/Daily.catch.Edsel.lua | 46 | … pelo menos lvl 100 … |
| 13 | npc/scripts/Daily.catch.Beverly.lua | 46 | … pelo menos lvl 20 … |
| 13 | npc/scripts/Daily.catch.Alekson.lua | 46 | … pelo menos lvl 50 … |
| 12 | talkactions/scripts/deposito/depot_passworld.lua | 6 | Você deve estar perto de um depósito … |
| 8 | lib/ps/profission/actions/coleta/moitas.lua | 18 | Você precisa está na frente do arbusto! |
| 6 | lib/ps/profission/actions/coleta/caderno.lua | 40 | Você conseguiu … |
| 5 | lib/ps/profission/actions/coleta/lockpick.lua | 13 | , Preciso abrir este baú! |
| 4 | lib/ps/profission/actions/coleta/cavando.lua | 18 | Você precisa está na frente do buraco! |
| 4 | lib/ps/profission/actions/coleta/baucavado.lua | 13 | , Preciso abrir este bau! |
| 4 | lib/ps/events/actions/dailys/RAMDOMBOX.lua | 27 | Voce nao tem espaco para receber o item! |
| 3 | talkactions/scripts/shutdown.lua | 38 | O servidor vai cair em … |
| 3 | talkactions/scripts/task_mod/taskModule.lua | 16 | Vá derrotar todos os … |
| 3 | lib/ps/events/actions/dailys/presenteKendall.lua | 114 | Você não tem espaço suficiente! |
| 3 | lib/ps/events/actions/dailys/presenteEdsel.lua | 52 | (same) |
| 3 | lib/ps/events/actions/dailys/presenteAlekson.lua | 52 | (same) |
| 3 | lib/ps/events/actions/dailys/presenteBeverly.lua | 52 | Voce nao tem espaco para receber o item! |
| 3 | lib/ps/events/actions/card/cardcharizard.lua | 8 | Voce nao pode usar o card … |
| 3 | actions/scripts/shop/roupas_loja.lua | 137 | Você deve ser do gênero … |
| 2 | creaturescripts/scripts/dailys/task_kill.lua | 15 | Parabéns você achou o Pokémon ditto. |
| 2 | creaturescripts/scripts/dailys/pokemonTaskKill.lua | 10 | [Caça Pokémon]: … |
| 2 | talkactions/scripts/leavehouse.lua | 5 | Você não está dentro de uma casa. |
| 2 | talkactions/scripts/deposito/depot_release.lua | 6 | Seu depósito já está destravado. |
| 2 | lib/guardian.lua | 31 | Seu Guardian não Foi Sumonado … |
| 2 | lib/game_work.lua | 99 | Você avançou em … |
| 2 | lib/ps/functions/ball/empty.lua | 116 | Você capturou o pokémon, volte e entregue a sua missão. |
| 2 | lib/ps/profission/actions/coleta/arvore.lua | 18 | Você precisa está na frente da arvore! |
| 2 | lib/ps/events/talkactions/guardianTime.lua | 3 | Seu Guardian Possui ( … |
| 2 | lib/ps/events/actions/clothesKit.lua | 66 | Você já possui esta roupa. |
| 2 | lib/ps/events/actions/dailys/presenteNatasha.lua | 40 | Voce nao tem espaco para receber o item! |
| 2 | actions/scripts/banners/xpplank.lua | 4 | Você já está usando um XP Banner!. |
| 2 | actions/scripts/shop/roupas_loja_duplo.lua | 9 | Parabéns! Você tem uma nova roupa: … |
| 1 | creaturescripts/scripts/bannerexp.lua | 14 | Você saiu do alcance, seu Banner quebrou! |
| 1 | creaturescripts/scripts/shop.lua | 20 | Desculpe mas você não tem Diamonds suficientes … |
| 1 | creaturescripts/scripts/dailys/NpcSerioKill.lua | 26 | Você matou … |
| 1 | talkactions/scripts/stacke.lua | 7 | Você tem … |
| 1 | talkactions/scripts/pass/pass50.lua | 12 | Comando precisa de parametros … |
| 1 | talkactions/scripts/pass/pass35.lua | 12 | Comando precisa de parametros … |
| 1 | lib/game_pokemonInfo.lua | 640 | Seu pokemon avançou em amizade do nivel … |
| 1 | lib/ps/events/creaturescripts/onJoinChannel.lua | 86 | Digite /commands … / Type /commands … |
| 1 | lib/ps/events/talkactions/teste.lua | 3 | Mensagem boladamente bolada para teste |
| 1 | lib/ps/events/actions/dailys/presenteDalkon.lua | 26 | Para abrir este presente você precisa coloca-lo na mochila. |
| 1 | lib/ps/events/actions/dailys/presenteBernardo.lua | 25 | (same) |
| 1 | lib/ps/events/actions/dailys/presenteLeticia.lua | 25 | (same) |

Not in the table, but player-facing: the bilingual broadcasts in `lib/ps/events/globalevents/globalMessages.lua` (7 pairs), `config.lua` `motd` / `loginMessage`, and opcode payload text in `lib/game_pass.lua` (8).

**Mechanics for the fix:**

1. Replace the literal with English.
2. Add `English@Português` to `pt_br.loc`. Keep latin-1 and CRLF, and write newlines as `\n`.
3. For dynamic text, translate a format string and then substitute: `string.format(__L(cid, "You have %d minutes left."), n)`. A plain concatenated string never matches the dictionary.
4. `doCreatureSay`, channel messages and opcode payloads are not auto-localized, so they need an explicit `__L(cid, …)`.

---

## 5. Recommended order of work

**Done in Phase 3:**
- Step 1: house and `/evolve` descriptions; `/SendPass35` and `/SendPass50` usage; the `protocollogin.cpp` errors; the legacy client `init.lua` fatal message.
  - `shutdown.lua` now sends one English format string per player, localized through `__L` and three new `pt_br.loc` keys. This also fixes "We will back" and the UTF-8 Portuguese line that latin-1 clients showed as mojibake.
- Step 2, config: `motd` and `loginMessage` are English, with `pt_br.loc` entries.
  - The character-list MOTD is now passed through `Localization::t` with the account language. Verified: language 0 gets the English MOTD and language 1 the Portuguese one.
  - The `config.lua` blessing comments are translated.
- The `/teste` broadcast text is English.
- Help channel: the three "Portuguese / English" join messages in `onJoinChannel.lua` are now single English strings through `__L`, with `pt_br.loc` entries. Verified with the Redemption client smoke (language 0 gets English). The Wiki Chat greeting stays bilingual because it asks the player to pick a language.
- `XML/tournaments.xml`: the reference comment is English and uses the attribute names the loader actually reads (`tournament.cpp`).
- Commands: 38 commands have English canonical names, with every old word kept as a hidden deprecated alias (`COMMAND_REFERENCE.md`).
- Loader fix: `pt_br.loc` is CRLF, and on Linux every Portuguese value used to keep the `\r`, while Windows text-mode streams dropped it. The loader now strips it on every platform.

Everything below is still open.

1. **Canonical admin/operator text** (small, no compatibility risk):
   - `talkactions.xml` house descriptions and the `/evolve` description.
   - `pass35/50.lua` usage text.
   - `shutdown.lua`: one English broadcast, fix "We will back", PT through `pt_br.loc`.
   - `protocollogin.cpp:167,176` error strings.
   - Client `init.lua:9` fatal.
2. **Config and comments:**
   - `config.lua` comments (238-239).
   - English `motd` / `loginMessage` defaults, with a `pt_br.loc` entry for the login message.
   - `tournaments.xml` comment block, restoring the real attribute names.
   - `protocolgame.cpp:2916`, client C++ comments.
3. **Security and debug items found along the way** (not translation, but they touch the same files):
   - Restrict or remove `showbuywindowhouse` / `teste.lua` and `/profission`.
   - Give `/guardian` an explicit access level if intended.
4. **Server player-facing strings → English + `pt_br.loc`**, biggest first:
   - `game_market.lua`, `game_craft.lua`, `game_dungeon.lua`.
   - The 8 daily NPC scripts (one shared key set).
   - Depot, guardian, dailies/presentes, profession/coleta.
   - `professorTommy.lua` (also fixes the mojibake).
   - Bilingual pairs (`globalMessages.lua`, `onJoinChannel.lua`) → single English key.
5. **Client:**
   - Replace Portuguese `tr()` keys in `game_shop` with English keys and add `pt.lua` entries.
   - Wrap the other modules' literals in `tr()` with English keys.
   - Change the window title together with `tools/smoke_login.sh`.
6. **Language selection fixes:**
   - Lowercase the `/lang` argument.
   - Decide whether the client locale or `/lang` wins; today the login byte overwrites `/lang`.
   - Optionally give es/de/sv/pl distinct ids.
7. **Content needing a translator:** `items.xml` / `outfits.xml` names (check name lookups first), `pokekill.lua` Pokédex texts (re-encode), outfit `nome` lists, `002-wikiChat.lua`.
8. **Profession/coleta comment translation** (169 lines) and the remaining ~95 comment lines.
9. **SQL dump comments:** regenerate the dump with an English generator. Translate the `server_motd` seed rows.

Never rename the KEEP - COMPATIBILITY tokens in 3.11 unless the client and server change in the same release.
