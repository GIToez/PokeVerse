# Redemption Parity Matrix

How far the Redemption client (`client-redemption/`) matches the legacy reference client (`client/`) against the same PokeVerse server.

Statuses: **PASS**, **PARTIAL**, **FAIL**, **NOT TESTED**, **BLOCKED**. A row is PASS only when the feature ran against the server and the result was checked. A screenshot that merely looks right is not enough.

## Evidence

- `tools/smoke_redemption_login.sh` runs the staged client, never the shipped dist, with `tools/redemption_smoke_rc.lua` as its user script.
  - It logs in through the real `ProtocolLogin` and `ProtocolGame` code paths.
  - It then checks the character list, game start, map tiles, a parsed PokeVerse 0xFF signal, a step, a chat line and logout.
  - With `PV_EXPECT_POKEBAR=1` (GM Admin) it also requires a Pokémon bar portrait, a summon by clicking it, a filled move bar, and a cooldown back from a move used on a Rattata it spawns with `/m`. CI first gives GM Admin a Charmander and a Bulbasaur with `/cb`. The Pokémon steps run at 3325,806,6, outside the starting temple, because the server refuses moves in a protection zone.
  - It fails on any `Unhandled opcode`, parse exception, checksum error, unknown 0xFF sub-opcode or Lua error in the client log.
- Local Linux runs against the Linux server pass for `player`/Trainer and `admin`/GM Admin.
  - Screenshots: `redemption-linux-ingame-trainer.png`, `redemption-linux-ingame-gm.png`.
- CI runs the same script as follows:
  - Windows: the Release client against the Windows server, in `platforms.yml` → `windows-e2e`.
  - Linux: the Release client against the Linux server, in the `linux-client` release job.
- The legacy client's results come from the runtime harness (`FEATURE_TEST_MATRIX.md`).

## Wire protocol (C++ and gamelib)

Everything here sits behind `GamePokeVerse`, which is enabled at version 854 only (`modules/game_features/features.lua`). The wire formats are in `REDEMPTION_PROTOCOL_COMPATIBILITY.md`.

| Packet / field | Legacy | Redemption | Status | Evidence |
|---|---|---|---|---|
| Login packet language byte | sends the locale id | sends 0 (en), 1 (pt) or 2 (es) from the current locale | PASS | Character list returned (the server refuses the RSA block without it) |
| Character list: level, vocation, outfit, Pokémon team, poll flag | parsed | parsed into `character.level`, `.vocation`, `.outfit`, `.pokemonTeam` and `account.pollAvailable` | PASS | `CHARACTER name=Trainer ... level=8 vocation=1 lookType=612 team=0`; GM Admin `team=1` |
| Login light hour (u16) | `onLightHour` | `g_game.onLightHour` | PASS | `LIGHT HOUR 927` |
| Creature extra fields (summon, attackable, types, level, experience) | `onSetNewInfo` | stored on `Creature`, with Lua getters and `onSetNewInfo` | PASS (parse) | NPCs and players parse with no stream error. Values for a wild Pokémon or a summon are NOT TESTED |
| Item held-Pokémon trailer (inventory, containers) | parsed | `Item:getPokeName/Level/Gender` | PASS | GM Admin's feet-slot ball reports `pokeName=Charmander` |
| Channel list u16 count | parsed | parsed | NOT TESTED | The channel dialog was not opened |
| Extended opcodes (0x32) without the opcode-0 handshake | always on | enabled on connect | PARTIAL | Enabled; no PokeVerse module sends one yet |
| 0xFF sub-protocol (26 sub-opcodes) | C++ | Lua (`modules/gamelib/pokeverse.lua`), same `g_game` signals | PARTIAL | Received and parsed: `MoveBarUpdate`, `MoveBarOpen`, `PokemonBarAdd` (9 fields), `PokemonBarOpen`, `PokemonBarClose`. The other 21 are written from the legacy parser but not yet received |
| Poll window request / vote (0xFA / 0xFB) | sent | `g_game.sendPokeVersePollOpen()` / `sendPokeVersePollAnswer()` | NOT TESTED | No poll is configured in the dev database |
| Map aware range 32×28 | 15/13 | `viewport: 15 13` in `data/setup.otml` | PASS | 852–856 tiles on the floor and walking stays in sync |
| Count u16, magic effect u16, u32 sprites, alpha sprites | on | on at 854 | PASS | The 854 SPR/DAT load; inventory counts are correct |

## Gameplay and modules

Ported so far: `game_pokebar` and `game_pokemoves`. The other PokeVerse Lua modules (`client/runtime-data/modules/game_*`) are not ported yet. Redemption shows its own upstream UI, so a feature whose server data arrives but has no window is PARTIAL: the protocol works, the UI does not.

| Feature | Legacy (harness) | Redemption | Status | Notes |
|---|---|---|---|---|
| Login and character list | PASS | PASS | PASS | Linux local; Windows and Linux in CI |
| Enter game and render map | PASS | PASS | PASS | The PokeVerse map, NPCs (Nurse Joy, Professor Oak) and HUD sprites draw (screenshots) |
| Walking | PASS | PASS | PASS | One step and the position is confirmed by the server |
| Chat (say, server messages, NPC speech) | PASS | PASS | PASS | Own line echoed; Wiki Chat, Professor Oak and server broadcasts received |
| Inventory | PASS | PASS | PASS | Slots and item ids match the server |
| Containers / pokébag | PASS | NOT TESTED | NOT TESTED | Parsing is ported; no container was opened |
| Logout | PASS | PASS | PASS | Clean logout; the server saves |
| Pokémon bar display (`game_pokebar`) | PASS | PASS | PASS | One portrait per carried ball, built from `onPokemonBarAdd`: icon, name, level, types and health label. `MODULE game_pokebar visible=true portraits=2 poke46=Charmander,poke47=Bulbasaur`. Screenshot: `redemption-linux-pokebar-summon.png` |
| Summon and switch from the bar (`/cp`) | PASS | PASS | PASS | Clicking a portrait summons that Pokémon, and clicking a second one swaps it (`SUMMON OK creature=Charmander level=15`, `SWITCH OK creature=Bulbasaur level=10`). The active portrait expands and shows its health. Windows and Linux CI (run 37631181970): `SUMMON OK creature=Charmander level=15`; `SWITCH OK creature=Bulbasaur level=15` (run 37635170266) |
| Move bar (`game_pokemoves`) | PASS | PASS | PASS | Fills with the summoned Pokémon's moves (`moves=5 Tackle,Bite,Bubble,Water Gun,Protect` for Squirtle). Screenshot: `redemption-linux-movebar.png` |
| Use a move from the bar, with its cooldown | PASS | PASS | PASS | Clicking Tackle with a spawned Rattata targeted: the server reports damage and the Rattata's health falls (`health=96->92`). The cooldown overlay appears (`cooldown=1 overlay=true`) and survives the move-list rebuild the server sends right after each move. Windows CI against the Windows server (run 37631181970): `MOVE OK move=Scratch cooldown=6 overlay=true … health=100->79`; Linux CI `health=100->72` |
| Recall by using the ball | PASS | NOT TESTED | NOT TESTED | `/cp` on the active Pokémon re-summons it, as in the legacy client; recall goes through using the ball, which the smoke does not do yet |
| Pokémon Info, EVs, vitamins, friendship, held items | PASS | BLOCKED | BLOCKED | These are extended-opcode modules (`EXTENDED_OPCODE_MAP.md`) that are not ported |
| Pokédex | PASS | BLOCKED | BLOCKED | The 0xFF Pokédex packets are parsed; no window |
| Battle Pass, calendar, dungeons, crafting, tasks | PASS / PARTIAL | BLOCKED | BLOCKED | Module port pending |
| Shop, Market | PARTIAL | BLOCKED | BLOCKED | Module port pending. Redemption's own Tibia store and market are not PokeVerse features |
| Combat (summon attacks a wild Pokémon) | PARTIAL | PASS | PASS | See the move rows above; the wild Pokémon also attacks the summon |
| Catching | NOT TESTED | NOT TESTED | NOT TESTED | — |
| Settings persistence | NOT TESTED | NOT TESTED | NOT TESTED | Settings live under `pokeverse/` (compact name) |

## Next steps (in order)

1. Done: the Pokémon bar and the move bar.
2. Port the extended-opcode modules (Pokémon Info, Pokédex, Battle Pass, calendar, dungeons, crafting, tasks, shop, market), using the opcode ids in `EXTENDED_OPCODE_MAP.md`.
3. Extend `redemption_smoke_rc.lua` the way the legacy runtime harness does, one module at a time, so each row above is decided by a run rather than by inspection.
