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

On startup the server prints either `>> Discord bridge listening on 127.0.0.1:7199 ...` or
the reason it is disabled.

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
server -> {"type":"welcome","protocol":1,"bootId":"<id>","serverName":"PokeVerse","queued":N}
       or {"type":"error","code":"auth_failed"} and the connection is closed
```

The client must authenticate within 10 seconds.

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
| `restart_warning` | `Game::prepareGlobalSave`, `/shutdown` | `reason` (`global_save`, `shutdown`, `shutdown_cancelled`), `minutes` (absent when cancelled), `shutdown` |
| `broadcast` | `/b`, client broadcast (`Game::playerBroadcastMessage`), `/bc` | `source` (`gm`, `staff`), `author` (GM name for `gm`), `text` |
| `chat` | `onTalkChannel` on Game-Chat[EN-US] (channel 7) | `channelId`, `author`, `level`, `text` |
| `catch` | `catchPokemon`, `catchPokemonWithSafariBall`, `catchPokemonWithSoulBall` after the ball was created | `trainer`, `species`, `baseSpecies`, `dexNumber`, `level`, `sex`, `shiny`, `legendary`, `extraPoints`, `ball`, `safari` |
| `spawn` | shiny or legendary wild monsters only | `species`, `baseSpecies`, `dexNumber`, `level`, `shiny`, `legendary`, `source`, `startup`, `creatureId`, `position {x,y,z}`, `nearestTown` (optional) |

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

### Requests (client -> server)

```
client -> {"type":"request","requestId":"<1..64 chars>","method":"<name>","params":{...}}
server -> {"type":"response","requestId":"...","ok":true,"result":{...}}
       or {"type":"response","requestId":"...","ok":false,"error":{"code":"...","message":"..."}}
```

Error codes: `invalid_params`, `unknown_method`, `internal`. Requests that are not valid
JSON objects are logged and ignored.

All handlers are read-only except `chat.send`, which only displays a message.

| Method | Params | Result |
| --- | --- | --- |
| `chat.send` | `author`, `text` | `delivered` (players who received it), `text` (as shown). Shown in channel 7 as `[Discord] <author>: <text>` (yellow). Control characters are removed, author max 24, text max 255 characters (client limit). |
| `trainer.lookup` | `name` | `{found:false}` or `found`, `name`, `level`, `vocation`, `guild` (optional), `online`, `caught`, `uniqueCaught`, `shinyCaught`, `duelWins`, `duelLosses`, `playersDefeated`, `tournamentsWon`, `achievements {earned,total,recent[]}` |
| `pokemon.lookup` | `name` | `{found:false}` or `found`, `name`, `baseSpecies`, `dexNumber`, `generation`, `types[]`, `stats {attack,defense,specialAttack,specialDefense,health,energy}`, `description`, `evolutions[] {from,to,level,items}`, `moves[] {name,level}`, `abilities[]`, `specialAbilities[]`, `shiny`, `legendary`, `catchable`, `shinyVariant` |
| `pokemon.search` | `query`, `limit` (max 25) | `names[]` (prefix matches first) |
| `server.status` | - | `serverName`, `state`, `playersOnline`, `maxPlayers`, `uptime` (seconds since server start), `bootId` |
| `bridge.config` | - | `chatChannelId`, `chatAuthorPrefix`, `chatTextMaxLength`, `chatAuthorMaxLength`, `legendary[]` |

Trainer lookup details:

- Only characters of this world that are not deleted. Staff characters (group access >= 1)
  are reported as not found.
- Online characters use live values; offline characters use the saved database values.
- `duelWins`/`duelLosses`: duel results are stored as skill levels that start at 10, so
  the counts are `skill level - 10`.
- `recent` lists up to 5 achievement names, never secret achievements.

## Testing

`scripts/test-server-linux.sh` (also run in CI) starts a server with the bridge enabled and
runs `scripts/discord-bridge-test.py`, which uses real game clients to check
authentication, all requests, chat in both directions, loop prevention, a real catch, a
real failed throw, shiny/legendary spawn events and reconnects. The `/bridgetest`
talkaction it needs (`scripts/testing/`) is copied only into the temporary test server and
is never part of the game data. `scripts/test-lua-json.lua` covers the JSON library.
