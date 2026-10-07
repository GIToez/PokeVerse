# Command Reference (talkactions and other parsed commands)

Source of truth:

- `server/runtime-data/data/talkactions/talkactions.xml` (117 active entries after removing XML comments).
- The scripts it points to (`talkactions/scripts/…` or `lib/ps/events/talkactions/…`).
- C++ functions in `server/source/talkaction.cpp`.
- The guild-channel parser in `server/source/chat.cpp`.

Access levels come from `server/runtime-data/data/XML/groups.xml`:

| Access | Group(s) |
|---|---|
| 0 | 1 Player, 7 Player, 8 Tutor (group 8 has no `access` attribute, so it defaults to 0) |
| 1 | 2 Tutor |
| 2 | 3 Senior Tutor, 9 Senior Tutor |
| 3 | 4 Gamemaster |
| 4 | 5 Community Manager |
| 5 | 6 God |

## Engine behavior

- **Case sensitivity.** Talkactions are case-sensitive by default (`m_sensitive = true` in `talkaction.cpp`) unless the entry sets `case-sensitive="no"`. Mixed-case commands (`/ShopOpen`, `/BuyMasteryRank`, `/SendPass35`, `/SendPass50`, `/parseRank`) only match exactly as written. `/autoTrade`, `/autoloot`, `!walk`, `/dv`, `/sd`, `/cp`, `/pd`, `/tc` and the `s1…m16` moves are case-insensitive.
- **Filters.** The default is `word` (first token). The `word-spaced` filter, used by the house commands, takes the command as the text up to the *second* space, so `!kickhouse Bob` would be read as the command `"!kickhouse Bob"` and not match. Parameter use of the house commands is likely broken (UNVERIFIED), but the client sends the bare obfuscated word, which works.
- **Access denied.** Players without access get no reply; the text is treated as normal speech. Staff below the required level get "You cannot execute this talkaction."
- **Other attributes.** `log="yes"` writes to the talkaction log. `hidden` / `hide` hides the command from `/commands`.
- **`/commands` output.** `/help`, `/commands` etc. show a popup listing the visible commands the player's access allows, built 10 s after startup. It prints the XML `description`, so any Portuguese descriptions appear there (see `TRANSLATION_AUDIT.md`).
- **Aliases.** Words separated by `;` in one entry are aliases.

## Naming policy for the "Proposed canonical English name" column

- Use lowercase, full English words.
- Keep every current word as a **deprecated alias**, so that client modules, the runtime harness (`tools/runtime-harness/pv_harness/pv_harness.lua`) and players' habits keep working.
- "—" means the current name is already acceptable.
- Words the client sends automatically are marked **(client)** and must not be removed.

**Done in Phase 3.** Every row with a single proposed name (38 commands) now uses it as its canonical word in `talkactions.xml`. Each old word is a separate entry directly below it, marked `<!-- deprecated alias of /new -->`, with the same script, access and log settings plus `hidden="yes"`. A separate entry is used instead of a `;` alias because `/commands` lists every registered word, and a `;` alias cannot be hidden on its own. Scripts receive the word that was typed; the two scripts that branch on it (`gamemaster.lua` and `creature.lua`, by the second character) give the same result for the new names.

Not renamed: `/profission` (the access change needs a decision), `/teste` (marked for removal), `/commands` (already English) and every row marked "—".

Verified on the Linux server with `tools/protocol_client.py`: old and new words give identical replies (`/guildlist`/`/list`, `/pokemoninfo`/`/pokeivev`) and are matched and logged identically for GM commands (`/monster`/`/m`, `/givepokemon`/`/cb`, `/broadcast`/`/b`, `/looktype`/`/newtype`, `/playerinfo`/`/info`, `/attribute`/`/attr`, `/temple`/`/t`). The server starts with no duplicate-word warnings. `tools/validate.py commands` checks that every alias runs the same script with the same access as its canonical word, is hidden, and that every word the client or harness sends is still registered.

## Player commands (access 0: Player)

| Command | Access | Arguments | Purpose (English) | Example | Current aliases | Proposed canonical English name | Deprecated aliases |
|---|---|---|---|---|---|---|---|
| /depotpass | 0 Player | `password, <pw>` \| `passchange, <old>, <new>` \| `remove, <pw>` \| `lock` / `closed` | Set, change, remove or lock the depot password; must be next to a depot | `/depotpass password, 1234` | !depotpass | /depotpassword | /depotpass, !depotpass |
| /dprelease | 0 Player | `<password>` | Unlock the depot with its password | `/dprelease 1234` | — | /depotunlock | /dprelease (client) |
| /dpconfig | 0 Player | none | Open the depot-lock window (opcode `DepotLock`) | `/dpconfig` | — | /depotconfig | /dpconfig (client) |
| /task | 0 Player | `accept\|done\|cancel, <taskName>` | Accept, hand in or cancel a task | `/task accept, Rattata` | — | — | — (client) |
| /parseRank | 0 Player | `<rank letter>` (E, D, …) | Send task-rank info to the client | `/parseRank E` | — | /taskrank | /parseRank (client; case-sensitive) |
| /buyrank | 0 Player | `<rank>` | Unlock a task rank | `/buyrank D` | — | /taskbuyrank | /buyrank (client) |
| /showtaskrank | 0 Player | none | Show task rank status | `/showtaskrank` | — | /taskstatus | /showtaskrank (client) |
| /BuyMasteryRank | 0 Player | `<key>` (e.g. gaia5, zen1) | Buy a mastery rank for diamonds (item 34524); premium required | `/BuyMasteryRank gaia5` | — | /buymastery | /BuyMasteryRank (client; case-sensitive) |
| /namediamond | 0 Player | `<new name>` | Rename the character for 25 diamonds (item 34524) | `/namediamond Ash` | — | /renamediamond | /namediamond (client) |
| /namepokecoin | 0 Player | `<new name>` | Rename the character for 50 pokecoins (storage 414141) | `/namepokecoin Ash` | — | /renamepokecoin | /namepokecoin (client) |
| /shopdiamond | 0 Player | `<offer key>` (e.g. sexo, deposito, decoracao, cortina, resetprofission, city names) | Buy a diamond-shop offer | `/shopdiamond sexo` | — | /shopbuy | /shopdiamond (client) |
| /ShopOpen | 0 Player | none | Open the shop (opcode 27 `OpenShop`) | `/ShopOpen` | — | /shopopen | /ShopOpen (client, harness; case-sensitive) |
| /dailysigninopen | 0 Player | none | Open the daily sign-in reward window | `/dailysigninopen` | — | /dailyreward | /dailysigninopen (client, harness) |
| /passopen | 0 Player | none | Open the battle-pass window | `/passopen` | — | /pass | /passopen (client, harness) |
| /pokeivev | 0 Player | none (a Pokémon must be out) | Open the Pokémon Info (IV/EV) window | `/pokeivev` | — | /pokemoninfo | /pokeivev (client, harness) |
| /SendPass35 | 0 Player | `<player name>` | Gift a pass (item 35554) to a player for 35 diamonds | `/SendPass35 Ash` | — | /giftpass35 | /SendPass35 (client; case-sensitive) |
| /SendPass50 | 0 Player | `<player name>` | Gift a pass (item 35554) to a player for 50 diamonds | `/SendPass50 Ash` | — | /giftpass50 | /SendPass50 (client; case-sensitive) |
| /profission | 0 Player | none | **Debug:** calls `learnWork(cid, 1)` and grants a profession to any player | `/profission` | — | /profession (and restrict to access ≥ 4, or remove) | /profission |
| /addon | 0 Player | none | Show the active Pokémon's addons | `/addon` | — | — | — |
| /evolve | 0 Player | none | Evolve the active Pokémon (XML description wrongly says "Show Pokemon addons.") | `/evolve` | — | — | — |
| /coupon | 0 Player | `<code>` | Redeem a coupon code | `/coupon ABC123` | /cupom | — | /cupom |
| /afk | 0 Player | `[message]` (5-50 chars) | Toggle AFK with an optional message | `/afk brb` | — | — | — |
| /time | 0 Player | none | Show the server time | `/time` | — | — | — |
| /commands | 0 Player (hidden) | none | Popup list of available commands | `/commands` | /help, /command, /comando, /comandos | /commands | /command, /comando, /comandos (keep /help) |
| /megusta etc. | 0 Player | none | Meme emote effects | `/trollface` | /megusta, /trollface, /yaomingface, /pokerface, /foreveralone | — | — |
| /autoloot | 0 Player (case-insensitive) | per script (UNVERIFIED) | Configure auto-loot | `/autoloot` | — | — | — |
| /dv | 0 Player (hidden, case-insensitive) | `<dex number>` | Show a Pokédex entry (client-driven) | `/dv 25` | — | /dexview | /dv (client) |
| /exp | 0 Player | none | Show the active Pokémon's experience | `/exp` | — | — | — |
| /held | 0 Player | none | Show held-item experience | `/held` | — | — | — |
| /love | 0 Player | none | Show Pokémon friendship/love | `/love` | — | — | — |
| t1 | 0 Player | none | Turn the active Pokémon N/E/S/W | `t1` | t1, t2, t3, t4 | /turn north (etc.) | t1-t4 (client hotkeys) |
| !walk | 0 Player (case-insensitive) | per script (UNVERIFIED) | Toggle auto-walk | `!walk` | — | /autowalk | !walk |
| /sd | 0 Player (hidden, case-insensitive) | `<client icon id>` | Send a move description to the client | `/sd 12` | — | — | /sd (client) |
| /cp | 0 Player (hidden, case-insensitive) | `<slot>` | Fast-call the Pokémon in a slot | `/cp 1` | — | — | /cp (client) |
| /pd | 0 Player (hidden, case-insensitive) | per client | Send a Pokémon description | `/pd` | — | — | /pd (client) |
| /tc | 0 Player (hidden, case-insensitive) | per client | Choose a TM | `/tc` | — | — | /tc (client) |
| /d1 | 0 Player | none | Use transform memory slot 1-3 (Ditto) | `/d2` | /d1, /d2, /d3 | — | — |
| /boss | 0 Player | none | Check boss reward status | `/boss` | — | — | — |
| /lang | 0 Player | `english` \| `portugues` | Set the account language. Case-sensitive argument; the client locale overwrites it at the next login. | `/lang english` | — | /language | /lang. Also accept `portuguese` / `pt` / `en` (proposal). |
| s1 | 0 Player (hidden, case-insensitive) | none | Use Pokémon move 1-16 | `s3` | s1-s16, m1-m16 | — | — (client hotkeys) |
| /teleport | 0 Player | `<city>` \| `home` \| `house` \| `guild` \| `guild house` | Teleport (lowercased argument) | `/teleport saffron` | /tele, /tp | — | — |
| /up | 0 Player | `[floors]` (default 1) | Fly/levitate up | `/up 2` | h1 | — | h1 (client hotkey) |
| /down | 0 Player | `[floors]` (default 1) | Fly/levitate down | `/down` | h2 | — | h2 (client hotkey) |
| /find | 0 Player | `<player name>` | Locate a player | `/find Ash` | h3 | — | h3 |
| /tvname | 0 Player | `<name>` | Name your TV broadcast | `/tvname My stream` | — | — | — |
| /tvlist | 0 Player | none | List TV viewers | `/tvlist` | — | — | — |
| /tvkick | 0 Player | `<viewer>` | Kick a TV viewer | `/tvkick Bob` | — | — | — |
| /tvban | 0 Player | `<viewer>` | Ban a TV viewer | `/tvban Bob` | — | — | — |
| /tvunban | 0 Player | `<viewer>` | Unban a TV viewer | `/tvunban Bob` | — | — | — |
| /tvpassword | 0 Player | `<password>` | Set the TV password | `/tvpassword 123` | — | — | — |
| /list | 0 Player | none | Guild member list | `/list` | — | /guildlist | /list |
| /setrank | 0 Player | `<name>, <rank>` | Set a guild member's rank | `/setrank Bob, Officer` | — | /guildrank | /setrank |
| /guardian | 0 Player (logged) | none | Show the remaining Guardian time (messages are in Portuguese) | `/guardian` | — | — | — |
| /autoTrade | 0 Player (case-insensitive) | `<message>` (≥ 8 chars) \| `off` | Repeat a trade advert in channel 5 ("Troca") | `/autotrade selling Dratini` | — | /autotrade | /autoTrade |
| $stackemoney$ | 0 Player (hide) | none | Client-triggered money stacking | (client) | — | — | KEEP (client) |
| !buyhouse | 0 Player (word-spaced, C++ `houseBuy`) | none (stand in front of the door) | Buy a house | `!buyhouse` | buyhouseewqnml (client) | /buyhouse | !buyhouse, buyhouseewqnml |
| !sellhouse | 0 Player (word-spaced, C++ `houseSell`) | `<player>` (UNVERIFIED, see filters) | Sell or transfer your house | `!sellhouse` | fsellhousedwq (client) | /sellhouse | !sellhouse, fsellhousedwq |
| !kickhouse | 0 Player (word-spaced, C++ `houseKick`) | `[player]` (UNVERIFIED) | Kick yourself or a player out of the house | `!kickhouse` | chutarrrase (client) | /kickhouse | !kickhouse, chutarrrase |
| !doorhouse | 0 Player (word-spaced, C++ `houseDoorList`) | none (face a door) | Edit the door access list | `!doorhouse` | portassdawt (client) | /housedoor | !doorhouse, portassdawt |
| !invitehouse | 0 Player (word-spaced, C++ `houseGuestList`) | none | Edit the house guest list | `!invitehouse` | hospedeseeq (client) | /houseguests | !invitehouse, hospedeseeq |
| !subhouse | 0 Player (word-spaced, C++ `houseSubOwnerList`) | none | Edit the house sub-owner list | `!subhouse` | subdonoeqwxv (client) | /housesubowners | !subhouse, subdonoeqwxv |
| !leavehouse | 0 Player (word-spaced, leavehouse.lua) | none | Abandon your current house | `!leavehouse` | abandonarweqn (client) | /leavehouse | !leavehouse, abandonarweqn |
| showbuywindowhouse | 0 Player | none | Runs `teste.lua`, which **broadcasts a test notification to all players**. Security issue: restrict or remove. The house-buy window is probably opened client-side (UNVERIFIED). | (client) | — | — (fix the script) | showbuywindowhouse (client) |
| /joinguild | 0 Player (C++ `guildJoin`) | `<guild name>` | Accept a guild invitation | `/joinguild Rockets` | !joinguild | — | !joinguild |

## Staff commands

| Command | Access | Arguments | Purpose (English) | Example | Current aliases | Proposed canonical English name | Deprecated aliases |
|---|---|---|---|---|---|---|---|
| /chatban | 1 Tutor | `[name]` (or the look target) | Mute a player in all game chats for 60 min | `/chatban Bob` | — | /mute | /chatban |
| /notations | 2 Senior Tutor | `<name>` \| `<account>` | Show a player's notations | `/notations Bob` | — | — | — |
| /gethouse | 2 Senior Tutor | `<name>[, teleport]` | Show (and optionally go to) a player's house | `/gethouse Bob, teleport` | — | /playerhouse | /gethouse |
| /mc | 2 Senior Tutor | `[ip \| name]` | List multi-clients (same IP) | `/mc Bob` | — | /multiclient | /mc |
| /baninfo | 2 Senior Tutor (C++ `banishmentInfo`) | `a\|p, <value>` (a = account, p = character) | Show ban details | `/baninfo p, Bob` | — | — | — |
| /ghost | 3 Gamemaster (C++ `ghost`) | none | Toggle invisibility | `/ghost` | — | — | — |
| /squelch | 3 Gamemaster | none | Toggle ignoring private messages (gamemaster.lua) | `/squelch` | — | — | — |
| /cliport | 3 Gamemaster | none | Toggle click-to-teleport (gamemaster.lua) | `/cliport` | — | /clickteleport | /cliport |
| /t | 3 Gamemaster | `[player]` | Teleport to the home temple | `/t Bob` | — | /temple | /t |
| /c | 3 Gamemaster | `<player \| creature>` | Bring a creature to you | `/c Bob` | — | /bring | /c |
| /goto | 3 Gamemaster | `<player \| creature \| waypoint \| x,y,z>` | Teleport to a target | `/goto 1000,1000,7` | — | — | — |
| /a | 3 Gamemaster | `[n][, player]` | Step n tiles forward | `/a 5` | — | /step | /a |
| /kick | 3 Gamemaster | `[name]` (or the look target) | Kick a player | `/kick Bob` | — | — | — |
| /send | 3 Gamemaster | `<player>;<destination>` (`;` separator) | Teleport a player to a destination | `/send Bob;Alice` | — | — | — |
| /unban | 3 Gamemaster | `<name \| account>` | Remove a ban. Bug: uses an undefined `ip` variable (UNVERIFIED impact). | `/unban Bob` | — | — | — |
| /town | 3 Gamemaster | `<town>[, player]` | Teleport to a town | `/town Saffron` | — | — | — |
| /save | 3 Gamemaster | `[minutes]` | Save now or schedule a save | `/save` | — | — | — |
| /clean | 3 Gamemaster | `[minutes \| tile]` | Clean the map. Bug: the `tile,true` branch never matches. | `/clean` | — | — | — |
| /reports | 3 Gamemaster | `[id]` | List or show bug reports | `/reports` | — | — | — |
| /wp | 3 Gamemaster | `[name]` | List or go to waypoints | `/wp temple` | — | /waypoint | /wp |
| /online | 3 Gamemaster | none | List online players | `/online` | — | — | — |
| /info | 3 Gamemaster | `<name>` | Player info | `/info Bob` | — | /playerinfo | /info |
| /b | 3 Gamemaster | `<message>` | Broadcast a message | `/b Server event soon` | — | /broadcast | /b |
| /gmcheck | 3 Gamemaster | `[next]` | GM check / rotation | `/gmcheck` | — | — | — |
| /teste | 4 Community Manager | none | **Debug:** same `teste.lua` test broadcast | `/teste` | — | remove | /teste |
| /newtype | 4 Community Manager | `<looktype>[, player]` | Change outfit looktype | `/newtype 128` | — | /looktype | /newtype |
| /owner | 4 Community Manager | `<name \| none>[, clean]` | Set the house owner (faced door) | `/owner Bob` | — | /houseowner | /owner |
| /storage | 4 Community Manager | `<player>, <key>[, <value>]` | Get or set a player storage. Bug: the message prints the param, not the value. | `/storage Bob, 1000, 1` | — | — | — |
| /config | 4 Community Manager | `<key>` | Show a config value. Bug: `value` is used before it is defined on the hidden-key path. | `/config motd` | — | — | — |
| /i | 4 Community Manager | `<id \| name>[, count=1000][, onGround][, inFront]` | Create an item | `/i 2160, 100` | — | /item | /i (harness) |
| /z | 4 Community Manager | `<effectId>` | Show a magic effect | `/z 10` | — | /effect | /z |
| /x | 4 Community Manager | `<projectileId>` (0-999) | Show a distance/projectile effect | `/x 5` | — | /projectile | /x |
| /y | 4 Community Manager | `<color>[, text]` | Show animated text | `/y 180, hi` | — | /animtext | /y |
| /bc | 4 Community Manager | `[class] <message>`; class is one of advance, event, white, orange, info, green, small, blue, red, warning, status | Broadcast with a message class (the first word is always taken as the class) | `/bc red Restart in 5` | — | /broadcastclass | /bc |
| /mkick | 4 Community Manager | `<rangeX>, <rangeY>[, multifloor]` | Kick all players in an area | `/mkick 10, 10` | — | /masskick | /mkick |
| /addskill | 5 God (C++ `addSkill`) | `<name>, <skill>[, amount]` (`l`/`e` = level, `m` = magic, otherwise a skill name) | Add levels or skills | `/addskill Bob, l, 10` | — | — | — |
| /attr | 5 God (C++ `thingProporties`) | `<attribute> <value>` on the look target (set/erase/action/unique/…, creature and player actions) | Edit thing attributes | `/attr action 1000` | — | /attribute | /attr |
| /serverdiag | 5 God (C++ `diagnostics`) | none | Server diagnostics | `/serverdiag` | — | — | — |
| /closeserver | 5 God | none | Close the server to players | `/closeserver` | — | — | — |
| /openserver | 5 God | none | Reopen the server | `/openserver` | — | — | — |
| /promote | 5 God | `<name>` | Promote a player's group | `/promote Bob` | /demote (same entry) | — | — |
| /shutdown | 5 God | `[minutes \| stop \| kill]` | Scheduled shutdown. Broadcasts PT and EN text; the EN text has grammar errors. | `/shutdown 5` | — | — | — |
| /mode | 5 God | `nopvp \| pvp \| pvpe` | Set the world type | `/mode pvp` | — | /worldtype | /mode |
| /createnpc | 5 God | `<npc name>` | Create a permanent NPC | `/createnpc Nurse Joy` | — | — | — |
| /cb | 5 God | `<Name>[, level=100][, extraPoints=100][, eggMove]` | Create a Pokéball with a Pokémon. **The name is case-sensitive:** `isPokemonName` passes for "charmander", but `POKEMONS[name]` lookups in `getPokemonBaseEnergy` fail ("Unknown poke name.") and then raise a Lua nil-index error. | `/cb Charmander, 15, 10` | — | /givepokemon | /cb (harness) |
| /s | 5 God | `<monster>[, player]` | Summon a monster as your summon | `/s Rattata` | — | /summon | /s |
| /n | 5 God | `<npc>[, player]` | Spawn an NPC | `/n Nurse Joy` | — | /npc | /n |
| /m | 5 God | `<monster>[, player]` | Spawn a monster (case-insensitive) | `/m rattata` | — | /monster | /m (harness) |
| /reload | 5 God | `<type>` | Reload a datapack section | `/reload talkactions` | — | — | — |
| /raid | 5 God | `<raid name>` | Start a raid | `/raid rattata` | — | — | — |
| /r | 5 God | `[amount \| all \| full]` | Remove the thing in front of you | `/r` | — | /remove | /r |
| /addoutfit | 5 God | `<outfitId>, <player>[, addon]` | Grant an outfit | `/addoutfit 10, Bob` | — | — | — |
| /sendplayeruniqueitem | 5 God | `<name>, <itemId>, <count>` | Send an item to a player's depot | `/sendplayeruniqueitem Bob, 2160, 1` | — | /giveitemdepot | /sendplayeruniqueitem |

## Commands parsed elsewhere (guild channel)

Parsed in `server/source/chat.cpp` (~l.960-1595) when `ingameGuildManagement = true` (`config.lua:134`) and the text typed **in the guild channel** starts with `!` or `/`. They are not talkactions, so they do not appear in `/commands`. Access is by guild rank, not by account group.

| Command | Access | Arguments | Purpose (English) | Example | Current aliases | Proposed canonical English name | Deprecated aliases |
|---|---|---|---|---|---|---|---|
| !commands | guild member | none | List guild commands | `!commands` | /commands (in guild channel) | — | — |
| !disband | guild leader | none | Disband the guild | `!disband` | / prefix | — | — |
| !invite | leader/vice | `<name>` | Invite a player | `!invite Bob` | / prefix | — | — |
| !leave | member | none | Leave the guild | `!leave` | / prefix | — | — |
| !revoke | leader/vice | `<name>` | Revoke an invitation | `!revoke Bob` | / prefix | — | — |
| !promote | leader/vice | `<name>` | Promote a member | `!promote Bob` | / prefix | — | — |
| !demote | leader | `<name>` | Demote a member | `!demote Bob` | / prefix | — | — |
| !passleadership | leader | `<name>` | Transfer leadership | `!passleadership Bob` | / prefix | — | — |
| !kick | leader/vice | `<name>` | Kick a member | `!kick Bob` | / prefix | — | — |
| !nick | member/leader | `[<name>,] <nick>` | Set a guild nick | `!nick Boss` | / prefix | — | — |
| !removenick | member/leader | `[<name>]` | Remove a guild nick | `!removenick` | / prefix | — | — |
| !setrankname | leader | `<old>, <new>` | Rename a rank | `!setrankname Member, Recruit` | / prefix | — | — |
| !setmotd | leader/vice | `<text>` | Set the guild MOTD | `!setmotd Meet at 8` | / prefix | — | — |
| !cleanmotd | leader/vice | none | Clear the guild MOTD | `!cleanmotd` | / prefix | /clearmotd | !cleanmotd |
| !broadcast | leader | `<text>` | Broadcast to the guild | `!broadcast hi` | / prefix | — | — |

Note: the in-chat help text lists `list` and `setrank[name,rank]`. Those are the separate talkactions `/list` and `/setrank` above, not chat-parser commands.

## Referenced but not registered

| Command | Referenced from | Status |
|---|---|---|
| /shoppokecoin | Client `modules/game_shop/` `roupas.lua`, `addons.lua`, `decoracoes.lua`, `mercado.lua` (371 sends in total) | **Not registered**, so pokecoin purchases from those pages do nothing on the server (it becomes normal speech). Register a handler (probably `shop/shop.lua` with a pokecoin mode, UNVERIFIED) or change the client to `/shopdiamond`. |
| !taunt | Client `game_shop` tooltips ("Comando: (!taunt)") | Not registered anywhere (UNVERIFIED whether it lives in an unported client module). |
| /ban | — | Does not exist. Banning goes through the rule-violation / report UI and `/unban`, `/baninfo` (UNVERIFIED). |

Script files in `talkactions/scripts/` with no XML entry (dead code): `commands.lua`, `deathlist.lua`, `event.lua`, `frags.lua`, `money.lua`, `pvp.lua`, `serverinfo.lua`, `uptime.lua`, `teleportfloor.lua`, `house/buyhouse.lua`, `task_mod/teste.lua`.

## Issues to fix alongside any renaming

1. **Security:**
   - `showbuywindowhouse` (access 0) broadcasts a test notification to every player. **Fixed in Phase 3** (now a no-op script).
   - `/profission` (access 0) grants a profession through a debug script.
   - `/guardian` has no access attribute; this is fine if it is meant as a player command.
2. **Case sensitivity:**
   - `/ShopOpen`, `/BuyMasteryRank`, `/SendPass35`, `/SendPass50` and `/parseRank` only work with exact case. Add `case-sensitive="no"` or lowercase canonical names.
   - `/cb` needs the exact `POKEMONS` key case.
   - `/lang` needs a lowercase argument.
3. **Wrong help or usage text** (all three **fixed in Phase 3**):
   - `/evolve` description.
   - `pass35/50.lua` usage message: it lists three arguments, but the command takes only a player name.
   - Portuguese descriptions on the seven house commands.
4. **Script bugs:** `/unban` (undefined `ip`), `/clean` (`tile,true` branch), `/storage` (message shows the param), `/config` (`value` used before it is defined).
5. **`word-spaced` house commands:** parameters probably never parse (UNVERIFIED).
6. **Renaming rule:** keep every old word registered, as a hidden entry marked `<!-- deprecated alias of … -->` (see the naming policy). The harness uses `/cb`, `/pokeivev`, `/i`, `/m`, `/passopen`, `/dailysigninopen` and `/ShopOpen`. Client modules send `/task`, `/parseRank`, `/buyrank`, `/showtaskrank`, `/BuyMasteryRank`, `/name*`, `/shopdiamond`, `/ShopOpen`, `/dailysigninopen`, `/passopen`, `/pokeivev`, `/SendPass*`, `/dpconfig`, `/dprelease`, `/depotpass`, `/sd`, `/cp`, `/pd`, `/tc`, `/dv`, the house words, `$stackemoney$` and `showbuywindowhouse`.
