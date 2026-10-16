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
           "features":["playerSessions","accountLinking"]}
       or {"type":"error","code":"auth_failed"} and the connection is closed
```

The client must authenticate within 10 seconds.

### Compatibility

The protocol version stays `1`: everything added later is optional. `features` lists the
optional parts the server has switched on (`playerSessions`, `accountLinking`). Servers
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
| `broadcast` | `/b`, client broadcast (`Game::playerBroadcastMessage`), `/bc` | `source` (`gm`, `staff`), `author` (GM name for `gm`), `text` |
| `chat` | `onTalkChannel` on Game-Chat[EN-US] (channel 7) | `channelId`, `author`, `level`, `text` |
| `catch` | `catchPokemon`, `catchPokemonWithSafariBall`, `catchPokemonWithSoulBall` after the ball was created | `trainer`, `species`, `baseSpecies`, `dexNumber`, `level`, `sex`, `shiny`, `legendary`, `extraPoints`, `ball`, `safari` |
| `spawn` | shiny or legendary wild monsters only | `species`, `baseSpecies`, `dexNumber`, `level`, `shiny`, `legendary`, `source`, `startup`, `creatureId`, `position {x,y,z}`, `nearestTown` (optional) |
| `player_login` | `Player::onPlacedCreature`, after the login scripts accepted the player | `scope` (`admin`), `sessionId`, `character`, `level`, `accountId`, `loginTime`, `ip` (only with `discordBridgeSessionIps`), `clientOs`, `clientVersion`, `playersOnline` |
| `player_logout` | `Game::removeCreature` for a player with an open session | `scope` (`admin`), `sessionId`, `character`, `level`, `accountId`, `loginTime`, `logoutTime`, `duration` (seconds), `reason` (optional), `playersOnline` |
| `account_link` | in-game `!discord unlink confirm` | `scope` (`account`), `action` (`unlinked`), `source` (`game`), `discordUserId` |
| `account_characters` | character created or deleted through the account service, for linked accounts only | `scope` (`account`), `discordUserId`, `change` (`created`, `deleted`), `character` |

Notes:

- Automatic broadcasts (tips from `globalMessages.lua`, banishment notices) are **not**
  forwarded. Global save warnings are sent as structured `restart_warning` events.
- Chat: only messages that passed the channel's level/mute checks are forwarded. Messages
  written by the bot into the channel do not trigger `onTalkChannel`, so they are never
  echoed back.
- Catch: failed throws never produce an event. If a caught Pokemon could not be delivered
  (no ball created) there is no event either. `extraPoints` is the ball's "+N" value at
  catch time, which the game always sets to 0.
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

Error codes: `invalid_params`, `unknown_method`, `internal`, plus the linking codes below.
Requests that are not valid JSON objects are logged and ignored.

All handlers are read-only except `chat.send`, which only displays a message, and the
`link.*` requests, which only change `discord_account_links`.

| Method | Params | Result |
| --- | --- | --- |
| `chat.send` | `author`, `text` | `delivered` (players who received it), `text` (as shown). Shown in channel 7 as `[Discord] <author>: <text>` (yellow). Control characters are removed, author max 24, text max 255 characters (client limit). |
| `trainer.lookup` | `name` | `{found:false}` or `found`, `name`, `level`, `vocation`, `guild` (optional), `online`, `caught`, `uniqueCaught`, `shinyCaught`, `duelWins`, `duelLosses`, `playersDefeated`, `tournamentsWon`, `achievements {earned,total,recent[]}`, `mastery` (optional), `card` (below) |
| `pokemon.lookup` | `name` | `{found:false}` or `found`, `name`, `baseSpecies`, `dexNumber`, `generation`, `types[]`, `stats {attack,defense,specialAttack,specialDefense,health,energy}`, `description`, `evolutions[] {from,to,level,items}`, `moves[] {name,level}`, `abilities[]`, `specialAbilities[]`, `shiny`, `legendary`, `catchable`, `shinyVariant` |
| `pokemon.search` | `query`, `limit` (max 25) | `names[]` (prefix matches first) |
| `server.status` | - | `serverName`, `state`, `playersOnline`, `maxPlayers`, `uptime` (seconds since server start), `bootId` |
| `bridge.config` | - | `chatChannelId`, `chatAuthorPrefix`, `chatTextMaxLength`, `chatAuthorMaxLength`, `legendary[]` |
| `admin.sessions` | - | `sessions[] {sessionId, character, level}` (open sessions, no IPs), `playersOnline` |
| `link.redeem` | `discordUserId`, `code` | link summary (below) |
| `link.account` | `discordUserId` | `{linked:false}` or link summary |
| `link.characters` | `discordUserId` | `{linked:false}` or `linked`, `characters[] {name, level, vocation, main, online}` (oldest first) |
| `link.setMain` | `discordUserId`, `character` | link summary |
| `link.unlink` | `discordUserId` | `unlinked` (`false` when there was no link) |
| `link.list` | `offset`, `limit` (max 200) | `links[]` (link summaries), `nextOffset` (absent on the last page) |

In `trainer.lookup`, `vocation` is the vocation the trainer chose (Ace Trainer, Catcher, ...; `Trainer`
before choosing) and `mastery` the engine vocation when it is a mastery. `card` is the Trainer Card,
also for offline trainers: `title`, `about`, `since`, `vocation {key, name, rank, maxRank, title}`
(absent before choosing), `favorite` and `trophies[]` (`{key, name, level, sex, number, shiny, look,
types}`), `playTime`, `dex {seen, total}`, `badges[] {region, earned[] (badge names), total}` and
`hidden[]`: what the trainer's privacy settings keep off other trainers' view (`playTime`, `stats`,
`trophies`); the matching fields are left out and the bot leaves out the statistics.

Link summary: `linked`, `discordUserId`, `linkedAt`, `characterCount`, `main {name, level,
vocation}` (absent when the account has no characters), `mainChanged`, `premium`,
`premiumUnlimited`, `premiumDays` (absent when unlimited). Results never contain account
ids, account names or IP addresses.

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

## Testing

`scripts/test-server-linux.sh` (also run in CI) starts a server with the bridge enabled and
runs `scripts/discord-bridge-test.py`, which uses real game clients to check
authentication, all requests, chat in both directions, loop prevention, a real catch, a
real failed throw, shiny/legendary spawn events, reconnects, player session events and
logout reasons (`logout`, `kick`, `connection_lost`), and the whole linking flow: in-game
codes, redeeming, wrong, reused and expired codes, the lockout, main character selection and
fallback after a deletion, and unlinking from both sides. The `/bridgetest`
talkaction it needs (`scripts/testing/`) is copied only into the temporary test server and
is never part of the game data. `scripts/test-lua-json.lua` covers the JSON library.
