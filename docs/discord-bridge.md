# Discord bridge

The game server can expose a small local bridge for the
[PokeVerse-Discord](https://github.com/GIToez/PokeVerse-Discord) companion bot. The bot
runs as a separate process; the game never waits for it, and a missing, slow or crashed bot
has no effect on gameplay.

The bridge is **disabled by default**.

## Enabling it

Create `config.local.lua` next to `config.lua` (same folder as the server executable). The
file is optional, loaded after `config.lua`, and ignored by git, so secrets never end up in
the repository or in packages:

```lua
discordBridgeEnabled = true
discordBridgeSecret = "a long random value shared with the bot (16+ characters)"
```

All settings (defaults in `config.lua`):

| Setting | Default | Meaning |
| --- | --- | --- |
| `discordBridgeEnabled` | `false` | Start the bridge listener. |
| `discordBridgeHost` | `"127.0.0.1"` | Listen address. |
| `discordBridgePort` | `7199` | Listen port (TCP). |
| `discordBridgeSecret` | `""` | Shared secret. With fewer than 16 characters the bridge stays disabled. |
| `discordBridgeQueueSize` | `2000` | Events kept while no bot is connected (oldest dropped first). |
| `discordBridgeAllowRemote` | `false` | Must be `true` to listen on a non-loopback address. Keep it `false`; use an SSH tunnel or a private network if the bot runs elsewhere. |
| `discordBridgePlayerSessions` | `true` | Send admin-only `player_login`/`player_logout` events (the bot's private `#player-activity` channel). |
| `discordBridgeSessionIps` | `true` | Include the player's IPv4 address in `player_login`. Set `false` to never send IPs to the bot. |
| `discordBridgeAccountLinking` | `true` | Allow Discord account linking (`!discord` in game, `link.*` requests). |
| `discordBridgeBoosterRewards` | `true` | Pay Soul Coins to server boosters with a linked account (`booster.*` requests). Needs `discordBridgeAccountLinking`. |
| `discordBridgeBoosterWeekly` | `1` | Soul Coins for every completed boost week. |
| `discordBridgeBoosterLoyaltyEvery` | `4` | Every this many weeks the loyalty bonus is added (`0` = never). |
| `discordBridgeBoosterLoyalty` | `1` | The loyalty bonus. |
| `discordBridgeBoosterYearlyEvery` | `52` | Every this many weeks the yearly bonus is added (`0` = never). |
| `discordBridgeBoosterYearly` | `15` | The yearly bonus. |
| `discordBridgeBoosterCommunityEvery` | `5` | On loyalty weeks, +1 Soul Coin per this many server boosts (`0` = no community bonus). |
| `discordBridgeBoosterCommunityMax` | `5` | The most the community bonus can pay in one week. |
| `discordBridgeBoostPerks` | `true` | Server-wide perks for everyone online by the Discord server's boost level (`boost.level`). |
| `discordBridgeBoostPerkExpPercent` | `5` | Level 1 and up: kill experience +this % (`0` = no perk). |
| `discordBridgeBoostPerkCatchPercent` | `5` | Level 2 and up: catch chance x(1 + this/100) (`0` = no perk). |
| `discordBridgeBoostPerkShinyPercent` | `10` | Level 3: shiny chance x(1 + this/100) (`0` = no perk). |
| `discordBridgeStaffChat` | `true` | Relay the in-game Counselor (Tutor+) and Staff (Gamemaster+) channels with the bot's private `#tutor-room` and `#gm-room`. |

On startup the server prints either `>> Discord bridge listening on 127.0.0.1:7199 ...` or
the reason it is disabled.

On the live server, `bootstrap-ovh.sh` enables the bridge with a random secret and the
workflow gives the same secret to the production bot. See [`live-server.md`](live-server.md).

## Design

- `src/discordbridge.cpp`: TCP listener on its own thread and `io_context`. Game code only
  appends to bounded in-memory queues; the network thread does all I/O.
- One authenticated bot connection at a time. A new authenticated connection replaces the
  old one.
- Events are queued while no bot is connected and delivered on the next connection
  (at-most-once delivery, no persistence across server restarts).
- Messages from the bot are queued (max 500) and handed to Lua on the dispatcher thread
  through the `discordbridge` globalevent (`onDiscordBridge`).
- `data/lib/ps/systems/056-discordBridge.lua`: game hooks and read-only request handlers.
  Every hook is wrapped in `pcall` and does nothing while the bridge is disabled.
- `src/discordbridgesessions.cpp`: player sessions (login/logout events) and the
  character created/deleted notice for linked accounts.
- `data/lib/ps/systems/061-discordAccounts.lua`: account linking requests. It is the only
  code that writes the `discord_account_links` table.
- `data/lib/ps/systems/087-discordBoosters.lua`: booster reward requests. The ledger row
  and the Soul Coins are written by `DiscordBridge::depositBoosterWeek` in C++.
- `data/lib/ps/systems/089-discordBoostPerks.lua`: the server boost level (`boost.level`) and
  its perks; the multipliers are `Game::getDiscordBoost*Multiplier` in C++.
- `data/talkactions/scripts/discord.lua`: the in-game `!discord` command.
- `data/lib/013-json.lua`: JSON encoder/decoder for Lua 5.1.

## Wire protocol (version 1)

Newline-delimited JSON (UTF-8, one object per line, max 16 KB per line) over TCP.

Game strings are Latin-1. The server writes bytes >= 0x7F as `\u00XX`, so its output is
plain ASCII. Incoming text is mapped back to Latin-1; characters the game client cannot
display become `?`.

### Handshake

```
server -> {"type":"hello","protocol":1,"nonce":"<64 hex chars>"}
client -> {"type":"auth","hmac":"<hex HMAC-SHA256(secret, nonce)>"}
server -> {"type":"welcome","protocol":1,"bootId":"<id>","serverName":"PokeVerse","queued":N,
           "features":["playerSessions","accountLinking","boosterRewards","boostPerks","staffChat"]}
       or {"type":"error","code":"auth_failed"} and the connection is closed
```

The client must authenticate within 10 seconds.

### Compatibility

The protocol version stays `1`: everything added later is optional. `features` lists the
optional parts the server has switched on (`playerSessions`, `accountLinking`,
`boosterRewards`, only when account linking is on too, `boostPerks`, `staffChat`,
`announcements` and `calendar`). Servers
built before these features send no `features` field; clients must treat a missing field
as an empty list and keep using the rest of the protocol. Clients must ignore event kinds
and fields they do not know. Unknown request methods are answered with `unknown_method`.

### Keepalive

The server sends `{"type":"ping"}` every 15 seconds and closes connections that sent
nothing for 45 seconds. Clients answer `{"type":"pong"}` and may send `{"type":"ping"}`
themselves (answered with `pong`).

### Events (server -> client)

```
{"type":"event","id":"<bootId>-<sequence>","time":<unix seconds>,"event":{...}}
```

`id` is unique per server run. `bootId` changes on every server start, so clients can
detect restarts and de-duplicate deliveries.

| `event.kind` | Source | Fields |
| --- | --- | --- |
| `server_state` | `Game::setGameState` | `state` (`init`, `normal`, `maintain`, `closed`, `closing`, `shutdown`), `players` |
| `restart_warning` | `Game::prepareGlobalSave`, `/shutdown`, `/restart` and the daily restart | `reason` (`global_save`, `shutdown`, `shutdown_cancelled`), `minutes` (absent when cancelled), `shutdown` |
| `broadcast` | `/b`, client broadcast (`Game::playerBroadcastMessage`), `/bc` | `source` (`gm`, `staff`), `author` (GM name for `gm`), `text`. Still sent with the `announcements` feature, for older bots. |
| `announcement` | every server-wide announcement but the tips (`092-announcements.lua`) | `category` (`event`, `legendary`, `server`, `staff`, `milestone`, `news`), `title` (optional), `text`, `full` (the message as shown in game), `source` (the script, like `077-eventCalendar`), `author` (staff), `ping` (`everyone`, `here`, `verified` or a role name; staff only), `calendar {key, id, state (started, ended), type (holiday, server, staff)}` |
| `chat` | `onTalkChannel` on Game-Chat[EN-US] (channel 7) | `channelId`, `author`, `level`, `text` |
| `staff_chat` | `onTalkChannel` on Counselor (4) or Staff (2) | `scope` (`admin`), `room` (`tutors`, `gamemasters`), `channelId`, `author`, `level`, `text` |
| `catch` | `catchPokemon`, `catchPokemonWithSafariBall`, `catchPokemonWithSoulBall` after the ball was created | `trainer`, `species`, `baseSpecies`, `dexNumber`, `level`, `sex`, `shiny`, `legendary`, `extraPoints`, `ball`, `safari` |
| `spawn` | shiny or legendary wild monsters only | `species`, `baseSpecies`, `dexNumber`, `level`, `shiny`, `legendary`, `source`, `startup`, `creatureId`, `position {x,y,z}`, `nearestTown` (optional) |
| `legendary` | wild legendaries (`078-wildLegendaries.lua`) | `event` (`spawn`, `sighting`, `flee`, `end`, `caught`, `set`, `sign`, `woke`, `revealed`, `clash`, `calm`, `reward`), `encounterId`, `species`, `dexNumber`, `text` (the in-game message, optional); spawn: `tier`, `area`, `position {x,y,z}`, `nearestTown`, `endsAt` (absent while asleep), `source` (`schedule`, `staff`, `test`), `health`, `level`, `asleep`; set: `setId`, `setName`, `level`, `asleep`, `source`, `members[] {encounterId, species, dexNumber, tier, area, position, endsAt}` (no member `spawn` events); sign (Mewtwo's disturbance, no encounter): `area`, `endsAt`; woke: `trainer`, `area`, `position`, `healthPercent`, `level`; revealed (Mew, who sent no `spawn`): `trainer`, `disguise`, `tier`, `area`, `level`, `endsAt`, `healthPercent`; clash and calm: `other`, `otherEncounterId`, `area`; reward (no encounter): `trainer`; sighting and flee: `area`, `position`, `nearestTown`, `healthPercent`; end: `reason` (`defeated`, `fled`, `staff`, `restart`, `vanished`), and for `defeated` also `area`, `trainers[]` (10% of the damage or more), `topTrainer`; caught: `trainer` |
| `player_login` | `Player::onPlacedCreature`, after the login scripts accepted the player | `scope` (`admin`), `sessionId`, `character`, `level`, `accountId`, `loginTime`, `ip` (only with `discordBridgeSessionIps`), `clientOs`, `clientVersion`, `playersOnline` |
| `player_logout` | `Game::removeCreature` for a player with an open session | `scope` (`admin`), `sessionId`, `character`, `level`, `accountId`, `loginTime`, `logoutTime`, `duration` (seconds), `reason` (optional), `playersOnline` |
| `account_link` | in-game `!discord unlink confirm` | `scope` (`account`), `action` (`unlinked`), `source` (`game`), `discordUserId` |
| `account_characters` | character created or deleted through the account service, for linked accounts only | `scope` (`account`), `discordUserId`, `change` (`created`, `deleted`), `character` |
| `report` | the Reports window and the staff reader (`083-reports.lua`) | `scope` (`admin` for player reports), `action` (`created`, `updated`, `screenshot`), `report` (below), `change` (`updated` only): `status`, `previousStatus`, `note`, `by`, `source` (`game`, `discord`), `assignedTo` (a take; absent when let go), `duplicateOf` (this report was merged into that one), `duplicate` (that report was merged into this one) |

Notes:

- Automatic broadcasts (tips from `globalMessages.lua`, banishment notices) are **not**
  forwarded.
- Announcement pings: `/b @everyone text`, `/b @verified text` or `/b @RoleName text` (no
  spaces in the tag) takes the tag out of the in-game text. @everyone and @here need access 3
  (Gamemaster) or more; otherwise the message goes out without the ping and the staff member
  is told. The Admin window's **Ping on Discord** offers the Verified role, the bot's roles,
  and @here/@everyone when the bot may use them. The bot decides the rest (default: holiday and
  weekend calendar events ping the Verified Trainer role). Global save warnings are sent as structured `restart_warning` events.
- Chat: only messages that passed the channel's level/mute checks are forwarded. Messages
  written by the bot into the channel do not trigger `onTalkChannel`, so they are never
  echoed back. Staff rooms use a separate `staff_chat` event (`tutors` = Counselor / Tutor
  and up, `gamemasters` = Staff / Gamemaster and up). The bot never sends a channel id;
  `chat.staff` takes `room` only.
- Catch: failed throws never produce an event. If a caught Pokemon could not be delivered
  (no ball created) there is no event either. `extraPoints` is the ball's "+N" value at
  catch time, which the game always sets to 0.
- Legendary: one `encounterId` per wild legendary, so the bot can keep one thread per
  encounter. Wild legendaries never send a `spawn` event, and the 5-minute limit per
  species does not apply. `caught` is sent when someone catches the species within 5
  minutes of its defeat. `trainers` is left out when nobody reached 10% (the server's JSON
  encoder would write an empty list as `{}`).
- Spawn `source`: `spawn` (map spawn system and raids, `onMonsterSpawn`), `script`
  (`doCreateMonster`: quests, bosses, events), `fishing`, `headbutt`. `startup` is `true`
  for monsters placed while the server was starting. Script spawns of the same species are
  reported at most once per 300 seconds (boss phases recreate the monster).
- Legendary: the game data has no legendary flag. The list in `056-discordBridge.lua`
  (`CONFIG.legendary`) is the audited set of legendary species and their boss/quest
  variants. `Shiny <name>` variants match automatically. Legendaries are not part of the
  map spawn data; they only appear through quest scripts.
- `nearestTown`: the town whose temple is closest on the same floor (or any surface floor
  for surface positions). Omitted when no town is on that floor.
- `scope`: `admin` events contain personal data (account id, IP address) and must only be
  shown to authorized staff. `account` events concern one linked Discord user. Events
  without `scope` are public.

Player sessions:

- A session starts only when a login fully succeeded: failed passwords, bans, full servers
  and logins refused by an `onLogin` script produce no event. `sessionId` is
  `<bootId>-s<counter>`, unique across restarts.
- A reconnect to a character that is still in the world (the client dropped, or the same
  character logged in again with `replaceKickOnLogin`) keeps the existing session: there is
  no extra login and no logout.
- A logout cancelled by an `onLogout` script (for example during a fight) produces nothing;
  the session continues.
- `reason` is set only where the server knows it: `logout` (the client asked to log out),
  `connection_lost` (the client disappeared and the character was removed), `timeout` (no
  answer to pings), `kick` (`/kick`, `/mkick`), `death`, `shutdown`, `server_closed`. Other
  removals have no `reason`.
- Sessions live in memory only. If the server stops without removing players (crash,
  `kill -9`), no logout events are sent; the bot sees a new `bootId` on the next connection
  and closes those sessions itself. A bot disconnect does not end sessions: queued events
  are delivered when it reconnects (up to `discordBridgeQueueSize`).
- `clientOs`: `windows`, `linux`, `flash`, `otclient-windows`, `otclient-linux`,
  `otclient-mac` or `unknown`. `ip` is IPv4 only (the game protocol has no IPv6 support).

### Requests (client -> server)

```
client -> {"type":"request","requestId":"<1..64 chars>","method":"<name>","params":{...}}
server -> {"type":"response","requestId":"...","ok":true,"result":{...}}
       or {"type":"response","requestId":"...","ok":false,"error":{"code":"...","message":"..."}}
```

Error codes: `invalid_params`, `unknown_method`, `internal`, `unsupported` (`chat.staff`
when `discordBridgeStaffChat` is off), plus the linking, booster and boost perk codes below.
Requests that are not valid JSON objects are logged and ignored.

All handlers are read-only except `chat.send` and `chat.staff`, which only display a message, the
`link.*` requests, which only change `discord_account_links`, `report.setStatus`, which only
changes that report, `booster.week`, which only adds a ledger row and the Soul Coins it pays, and
`boost.level`, which only stores the server boost level.

| Method | Params | Result |
| --- | --- | --- |
| `chat.send` | `author`, `text` | `delivered` (players who received it), `text` (as shown). Shown in channel 7 as `[Discord] <author>: <text>` (yellow). Control characters are removed, author max 24, text max 255 characters (client limit). |
| `chat.staff` | `room` (`tutors`, `gamemasters`), `author`, `text` | `delivered`, `text`. Same prefix and limits as `chat.send`, in Counselor (4) or Staff (2). Never takes a channel id. `unsupported` when `discordBridgeStaffChat` is off. |
| `trainer.lookup` | `name` | `{found:false}` or `found`, `name`, `level`, `vocation`, `guild` (optional), `online`, `caught`, `uniqueCaught`, `shinyCaught`, `duelWins`, `duelLosses`, `playersDefeated`, `tournamentsWon`, `achievements {earned,total,recent[]}`, `mastery` (optional), `card` (below) |
| `pokemon.lookup` | `name` | `{found:false}` or `found`, `name`, `baseSpecies`, `dexNumber`, `generation`, `types[]`, `stats {attack,defense,specialAttack,specialDefense,health,energy}`, `description`, `evolutions[] {from,to,level,items}`, `moves[] {name,level}`, `abilities[]`, `specialAbilities[]`, `shiny`, `legendary`, `catchable`, `shinyVariant` |
| `pokemon.search` | `query`, `limit` (max 25) | `names[]` (prefix matches first) |
| `server.status` | - | `serverName`, `state`, `playersOnline`, `maxPlayers`, `uptime` (seconds since server start), `bootId`, optional `restart { at, reason }` (`daily` / `staff` / `update`, unix seconds; omitted when nothing is planned) |
| `bridge.config` | - | `chatChannelId`, `chatAuthorPrefix`, `chatTextMaxLength`, `chatAuthorMaxLength`, `legendary[]` (`CONFIG.legendary` and every wild legendary species) |
| `announcements.roles` | `roles[]` (Discord role names), `everyone` (the bot may ping @everyone) | `roles` (how many were kept: at most 25, 100 characters each, and as many as fit in 250 characters of JSON). The Admin window lists them under **Ping on Discord** (global storage `DISCORD_PING_ROLES`). |
| `calendar.range` | `from`, `to` (unix seconds, at most 60 days apart) | `from`, `to`, `events[] {key, id, name, description, color, startsAt, endsAt, bonuses[] {kind, label, value}, holiday, night, forced}` (the calendar's occurrences overlapping the range) |
| `admin.sessions` | - | `sessions[] {sessionId, character, level}` (open sessions, no IPs), `playersOnline` |
| `link.redeem` | `discordUserId`, `code` | link summary (below) |
| `link.account` | `discordUserId` | `{linked:false}` or link summary |
| `link.characters` | `discordUserId` | `{linked:false}` or `linked`, `characters[] {name, level, vocation, main, online}` (oldest first) |
| `link.setMain` | `discordUserId`, `character` | link summary |
| `link.unlink` | `discordUserId` | `unlinked` (`false` when there was no link) |
| `link.list` | `offset`, `limit` (max 200) | `links[]` (link summaries), `nextOffset` (absent on the last page) |
| `booster.rules` | - | `weekly`, `loyaltyEvery`, `loyalty`, `yearlyEvery`, `yearly`, `communityEvery`, `communityMax` (the config values), `perks[] {level, text}` (the [server boost perks](#server-boost-perks); empty when they are off) |
| `booster.week` | `discordUserId`, `boostSince` (unix seconds), `week` (1-5200), `serverBoosts` (0-1000) | `deposited`, `week`, `weekly`, `loyalty`, `yearly`, `community`, `total` ([Booster rewards](#booster-rewards)) |
| `boost.level` | `level` (0-3), `boosts` (0-1000) | `level`, `perks[]` (the texts of the perks active at that level) ([Server boost perks](#server-boost-perks)) |
| `report.setStatus` | `id`, `status`, `note` (optional), `by` | `id`, `status`, `changed`. The game records `<by> (Discord)` and tells the reporter (and the reporters of its duplicates). Unknown ids and statuses fail with `invalid_params`. |
| `report.get` | `id` | `{found:false}` or `found`, `report` |
| `report.screenshot` | `id`, `offset`, `length` (max 12000) | `{found:false}` or `found`, `done` (the upload finished), `total`, `offset`, `data` (that slice of the base64 PNG). Slices stay under the 16 KB line limit. |

A `report` has `id`, `kind` (`bug`, `player`), `kindName`, `category`, `categoryName`, `status`,
`statusName`, `closed`, `title`, `description`, `reporter {name, level, vocation, discordUserId}`
(`discordUserId` when the account is linked), `createdAt`, `updatedAt`, `position {x,y,z}`, `area`,
`pokemon`, `client`, `statement`, `assignedTo`, `duplicateOf`, `duplicates` (how many were merged
into it) and `screenshot` (an uploaded screenshot is waiting). Player reports also have `target
{name, level, online, position, chat}`, where `chat` is the reported chat line.

In `trainer.lookup`, `vocation` is the vocation the trainer chose (Ace Trainer, Catcher, ...; `Trainer`
before choosing) and `mastery` the engine vocation when it is a mastery. `card` is the Trainer Card,
also for offline trainers: `title`, `about`, `since`, `vocation {key, name, rank, maxRank, title}`
(absent before choosing), `favorite` and `trophies[]` (`{key, name, level, sex, number, shiny, look,
types}`), `playTime`, `dex {seen, total}`, `badges[] {region, earned[] (badge names), total}` and
`hidden[]`: what the trainer's privacy settings keep off other trainers' view (`playTime`, `stats`,
`trophies`); the matching fields are left out and the bot leaves out the statistics.

Link summary: `linked`, `discordUserId`, `linkedAt`, `characterCount`, `groupIds[]` (the
distinct `players.group_id` values of the account's characters, lowest first; an online
character uses its live group, not `accounts.group_id`), `main {name, level,
vocation}` (absent when the account has no characters), `mainChanged`, `premium`,
`premiumUnlimited`, `premiumDays` (absent when unlimited). The bot gives the linked member
the Discord role of their highest staff group (Tutor, Senior Tutor, Gamemaster, Community
Manager, God). Group changes reach Discord at the 15-minute `link.list` resync or `/sync`.
Results never contain account ids, account names or IP addresses.

Linking error codes: `disabled`, `invalid_code`, `expired`, `locked`, `already_linked` (the
Discord user already has a link), `account_linked` (the game account already has a link),
`not_linked`, `not_owned` (the character is not on the linked account).

### Authorization

The bridge has a single client, the bot, authenticated with the shared secret. Per
operation:

- `discordUserId` (a Discord snowflake, sent as a string of 17-20 digits) names the
  Discord user a `link.*` request acts for. The bot sends the id of the user who ran the
  command; only its admin recovery command (`/pokeverse unlink`) sends another user's id.
- `admin.sessions`, `link.list` and the `admin`-scoped events are for the bot's own
  reconciliation and staff-only output.
- No request can create a link without a code shown in game to a logged-in character of the
  account, and no request returns or changes passwords, account names or characters.

## Account linking

A link joins one game account (all its characters) to one Discord user.

1. In game: `!discord link` (or `/discord link`). The server creates an 8-character code
   (`XXXX-XXXX`, Crockford base32, 40 bits from OpenSSL `RAND_bytes`) and shows it only to
   that player, in the console and a popup.
2. In Discord: `/link code:XXXX-XXXX`. The bot sends `link.redeem`.
3. The server consumes the code (once, atomically on the dispatcher thread) and stores the
   link with the account's first character as main.

Codes:

- Kept in memory only, as SHA-256 hashes; lost on restart. Valid for 10 minutes
  (`discordBridgeLinkCodeLifetime`, seconds, for tests only). A new code replaces the
  account's previous one; unlinking revokes pending codes.
- Matching ignores case, spaces and `-`; `O` reads as `0`, `I` and `L` as `1`.
- At most one code per 30 seconds and 5 per hour per account (`rate_limited`).
- Wrong codes: after 5 failures in 15 minutes a Discord user is `locked`; after 50 failures
  in 10 minutes from all users, redeeming is `locked` for everyone until the window ends.
  An expired code answers `expired` and does not count as a failure.

Rules:

- One account per Discord user and one Discord user per account (`UNIQUE` keys).
  `!discord link` refuses an account that is already linked. To move a link to another
  Discord user, the owner logs in and runs `!discord unlink`, then links again: logging in
  to the game is the ownership proof. This is also the recovery path for a lost Discord
  account.
- Main character: the account's first character on this world (lowest `players.id`; the
  schema has no creation date and ids are `AUTO_INCREMENT`). If the main is deleted, the
  next request falls back to the first remaining character and saves it
  (`mainChanged:true`). There is no character rename feature in this server.
- Premium (for the bot's Ace Trainer role) is `accounts.premdays > 0`; `65535` means
  unlimited. The server's daily premium update lowers `premdays`.

In-game command (`!discord` or `/discord`, any player):

| Command | Effect |
| --- | --- |
| `!discord link` | Shows a new one-time code. |
| `!discord status` | Shows whether the account is linked and since when. |
| `!discord unlink` | Asks for confirmation; `!discord unlink confirm` within 60 seconds removes the link and sends `account_link`. |

Database: `discord_account_links` in `schemas/pokeverse-extensions.sql` (created with
`CREATE TABLE IF NOT EXISTS`, so re-running the script is safe; rollback is
`DROP TABLE discord_account_links`, no existing table is changed). Discord ids are stored as
`VARCHAR(20)` so they never lose precision. Deleting an account removes its link
(`ON DELETE CASCADE`).

Trainer lookup details:

- Only characters of this world that are not deleted. Staff characters (group access >= 1)
  are reported as not found.
- Online characters use live values; offline characters use the saved database values.
- `duelWins`/`duelLosses`: duel results are stored as skill levels that start at 0, so
  the counts are the skill levels.
- `recent` lists up to 5 achievement names, never secret achievements.

## Booster rewards

Server boosters earn Soul Coins on their linked game account (`discordBridgeBoosterRewards`,
on in `config.lua`; it also needs account linking, and the server's built-in default is off). The bot watches who boosts
and, for each completed week of a boost, sends `booster.week` with the Discord user, the
streak start (`boostSince`, Discord's "boosting since" time), the week number and the
server's current boost count (`serverBoosts`). Removing
or moving the boost ends a streak; the next boost has a new `boostSince`.

The game owns the amounts and the ledger. Requests carry no amounts (any extra fields are
ignored); week `n` pays:

- `weekly` = `discordBridgeBoosterWeekly`
- `loyalty` = `discordBridgeBoosterLoyalty` when `n` is a multiple of `discordBridgeBoosterLoyaltyEvery`
- `community` = `min(discordBridgeBoosterCommunityMax, floor(serverBoosts / discordBridgeBoosterCommunityEvery))`
  on loyalty weeks (the same weeks as `loyalty`), 0 on other weeks or when either setting is 0
- `yearly` = `discordBridgeBoosterYearly` when `n` is a multiple of `discordBridgeBoosterYearlyEvery`
- `total` = the sum

With the defaults: 1 a week, 2 every 4th week plus 1 per 5 server boosts (at most 5), and in
week 52 1 + 1 + 15 + the community bonus (52 is also a 4th week). With 14 server boosts week 4
pays 1 + 1 + 2 = 4; with 100 the community bonus stops at 5. The boost count only sets the
community bonus, which the config caps; a request without `serverBoosts` (a bot from before
the bonus) counts as 0.

`booster.week` checks, in this order:

| Code | When |
| --- | --- |
| `disabled` | booster rewards (or account linking) are off; `booster.rules` answers the same |
| `invalid_params` | `discordUserId` is not a snowflake, `boostSince` is not an integer > 0 or is in the future, `week` is not an integer from 1 to 5200, `serverBoosts` is not an integer from 0 to 1000 |
| `not_linked` | the Discord user has no `discord_account_links` row |
| `not_due` | `boostSince + week * 604800` is more than 300 seconds (clock skew) in the future |
| (already paid) | a ledger row for this user, `boostSince` and `week` exists: the stored amounts come back with `deposited:false`, nothing is paid |
| `before_link` | the week was completed before the link's `linked_at` |
| `stale_streak` | the user was already paid for a streak with a newer `boostSince`, or this is a different streak that started before the user's last payout (an old streak sent again) |

Otherwise the week is paid in one database transaction: the ledger row is inserted first
(`INSERT IGNORE`; a duplicate key means another request paid it, and the stored row is
returned with `deposited:false`), then `accounts.soulcoins = soulcoins + total` for the
linked account. If the update fails the ledger row is rolled back. Soul Coins are never
read and written back from Lua. Online characters of the account are told "Thank you for
boosting the PokeVerse Discord! N Soul Coins were added to your Soul Coin balance (spend them
in the Store)." The Soul Coins go to the account balance that the Store uses. The server log
records the week, amount and account id, never the Discord id.

Database: `discord_booster_rewards` in `schemas/pokeverse-extensions.sql` (`CREATE TABLE IF
NOT EXISTS`; rollback is `DROP TABLE discord_booster_rewards`, no existing table is changed,
and Soul Coins already paid stay on the accounts):

| Column | Meaning |
| --- | --- |
| `id` | `AUTO_INCREMENT` key |
| `discord_user_id` | the booster (`VARCHAR(20)`) |
| `account_id` | the account that was paid (`ON DELETE CASCADE`) |
| `boost_since` | streak start, unix seconds |
| `week` | week of the streak |
| `weekly`, `loyalty`, `yearly`, `community`, `total` | the amounts paid |
| `server_boosts` | the boost count the bot reported for that week |
| `created_at` | payout time, unix seconds |

`UNIQUE (discord_user_id, boost_since, week)` makes payouts idempotent: retries, a lost bot
state file or two bots racing never pay a week twice. Ledgers created before the community
bonus get `community` and `server_boosts` from an `ALTER TABLE ... ADD COLUMN IF NOT EXISTS`
in the same script (undo: `ALTER TABLE discord_booster_rewards DROP COLUMN community, DROP
COLUMN server_boosts`).

## Server boost perks

While the PokeVerse Discord has server boost level 1 or more, everyone online gets perks
(`discordBridgeBoostPerks`, on in `config.lua`; the server's built-in default is off). Each level keeps the perks below it:

| Level | Perk (defaults) | Applied |
| --- | --- | --- |
| 1 | +5% experience | Kill experience of trainers (`Player::rateExperience`) and Pokemon (`doPlayerPokemonAddExperience`), the same gains the experience event multiplies. Quest, catch, Pokedex and item experience and Rare Candies are fixed amounts and stay as they are. |
| 2 | +5% catch rate | The final catch chance of a throw, the Catcher perk included, times 1.05 (40% becomes 42%, never above a sure catch): `rollCatch` in `ball/empty.lua` and the Safari Zone. Guaranteed catches (Master Ball) skip the roll and are unchanged. |
| 3 | +10% shiny spawn rate | The shiny chance times 1.1 (1 in 4,096 becomes about 1 in 3,724): map spawns (`Spawn::spawnMonster`) and every roll through `ShinyEvent.chance` (fishing, headbutt, script spawns, eggs, incubators, abilities). |

Each multiplier is applied once, after every other bonus (stages, stamina, Premium, personal
boosts, Lucky Egg, Ace Trainer, the experience and shiny events and the event calendar), so
it never compounds with itself. The experience tooltip (`085-expBoost.lua`) includes it as
`discordBoost`.

The bot sends `boost.level` when it connects and whenever the level changes. The level is
the only input; the percentages come from the config, and a perk set to `0` is left out.

| Code | When |
| --- | --- |
| `disabled` | the perks are off |
| `invalid_params` | `level` is not an integer from 0 to 3 or `boosts` is not an integer from 0 to 1000 |

The level is kept in global storage (key 7156, the boost count in 7157), written to the
database at once, so the perks survive a restart and keep working while the bot is
disconnected. Only `boost.level` changes it; there is no command for it. Changes are logged
(`> Discord boost perks: server boost level 1 -> 2 (7 boosts).`) and broadcast in game ("The
PokeVerse Discord reached Server Boost Level 2! Everyone now gets +5% experience and +5% catch
rate." or "...dropped to Server Boost Level 1. ..."). Players see the active perks at login
and with `!discord perks`.

## Testing

`scripts/test-server-linux.sh` (also run in CI) starts a server with the bridge enabled and
runs `scripts/discord-bridge-test.py`, which uses real game clients to check
authentication, all requests, chat in both directions, loop prevention, a real catch, a
real failed throw, shiny/legendary spawn events, reconnects, player session events and
logout reasons (`logout`, `kick`, `connection_lost`), and the whole linking flow: in-game
codes, redeeming, wrong, reused and expired codes, the lockout, main character selection and
fallback after a deletion, and unlinking from both sides. With `--booster-test` it checks
booster rewards: the rules, parameter checks, `not_linked`, `not_due`, `before_link`,
deposits (1, then 2 in week 4 and 17 in week 52) with the `soulcoins` balance and the
in-game message, repeats that pay nothing, `stale_streak` for old and replayed streaks, and
a new streak after the last payout, and the community bonus (week 4 with 14 server boosts
pays 4, 100 boosts cap it at 5, week 52 pays 19). With `--boost-test` it checks the boost
perks: `boost.level` parameter checks, each level's perks, the in-game broadcasts, the
multipliers through the game code (`/bridgetest perks`: experience, catch 40% -> 42% and a
200,000-throw roll, sure catches, shiny 1 in 4096 -> 3723), a real kill giving 5% more
trainer experience, `!discord perks`, and the level after a bridge reconnect. After a
restart with both features off, `--booster-disabled` checks the `disabled` answers, and the
script checks the stored level came back. The `/bridgetest`
talkaction it needs (`scripts/testing/`) is copied only into the temporary test server and
is never part of the game data. `scripts/test-lua-json.lua` covers the JSON library.
