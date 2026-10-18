# Phase 3: PokeVerse on the Redemption client

The Redemption client (`core/client-redemption`) runs the PokeVerse modules and data on the
OTClient Redemption engine. It is the only client: the old one is no longer built, and only
its PokeVerse `data/` and `modules/` remain in `core/client-legacy`.

## How the client is put together

A Redemption package is three layers, assembled by `scripts/assemble-redemption-client.sh`:

1. The legacy PokeVerse `data/` and `modules/` from `core/client-legacy`.
2. The overlay `core/client-redemption/pokeverse/`, copied on top. A file in the overlay
   replaces the legacy file at the same path, so an overlay module is always a whole module.
   It holds `init.lua`, `setup.otml`, the 8.54 feature set, the things loader,
   `client_styles`, the console with Chat On/Off, the updater, and corelib shims for engine
   APIs that changed.
3. The engine binary (`otclient`, `otclient.exe`) built from `core/client-redemption`.

Redemption's own modules do not ship yet. Phase 4 brings them in one at a time, adapted to
PokeVerse (see the Phase 4 plan).

## Engine changes

The full list, file by file, is in [engine-changes.md](engine-changes.md). In short:

All PokeVerse behaviour in the engine is behind the `GamePokeVerse` feature, which the
PokeVerse things loader turns on together with the 8.54 protocol (version 313, login port
7564, game port 8548).

- **Protocol:** opcode 255 with its 26 sub-opcodes, client opcodes 250 and 251 (poll),
  the extra login `lightHour` field and creature bytes, the U16 channel-list count, extended
  opcodes without the handshake, the 8.54 DAT quirks and the OTServ 0.6 OS ids.
- **Rendering:** ghost creatures, the legacy health, experience and icon layout, outfit
  colours, crosshairs and legacy-style outfit widgets.
- **Lua bindings** used by the PokeVerse modules: `setOutfitColor`, `setGhost`,
  `isAttackable`, `isLocalPlayerSummon`, `dashWalk`, the poll functions,
  `setDrawExperienceBars`, `restartImageAnimation`, `setFixedCreatureSize`.
- **Interpreter:** PUC Lua 5.1.5 with legacy's `bit32` (`OPTIONS_USE_LUA51`, on by default)
  instead of LuaJIT, so table iteration order, and therefore list order in the UI, is the
  same as legacy.
- **Legacy UI behaviour:** UI scale 1, legacy `text-offset` and font `y-offset` handling,
  Ctrl as the plain Ctrl modifier, the first value of each player stat reaching Lua,
  message mode and log level constants mapped to Redemption's numbering.
- **Updater:** the executable is replaced under its own name (see
  [client-updates.md](client-updates.md)).

## Building

Linux (needs gcc 14 and vcpkg; `VCPKG_ROOT` set):

```bash
cd core/client-redemption
cmake --preset linux-release -DTOGGLE_BIN_FOLDER=OFF
cmake --build --preset linux-release        # writes core/client-redemption/otclient
cd ../..
scripts/assemble-redemption-client.sh --host 127.0.0.1 /tmp/pokeverse core/client-redemption/otclient
/tmp/pokeverse/otclient
```

Windows builds with the `windows-release` preset (Visual Studio and vcpkg), Android with
`scripts/build-android-client.sh`. The **Client release** workflow builds all three; see
[client-updates.md](client-updates.md) for publishing.

## Parity tests (done)

Before the old client was retired, a parity test ran the same scripted session on both
clients against a throwaway server and compared the packets they sent and their
screenshots. The test is gone with the old client (it is in the git history); its last
results:

| Area | Covered by the self-test | Result |
| --- | --- | --- |
| Login screen, account login, MOTD, character list | yes | identical |
| Game login, map, Pokemon bar, status bars | yes | identical |
| Walking with the arrow keys (5 steps) | yes | identical packets |
| Saying something in Default chat | yes | identical packets |
| Chat Off: WASD walking, Enter for one message, Chat On | yes (Redemption feature) | passes on both |
| Skills, battle, VIP, minimap, inventory, hotkeys windows (keyboard shortcuts) | yes | identical |
| Options and quest log windows (buttons) | yes | identical |
| Player menu and outfit window (Ctrl + right click) | yes | identical |
| Logout prompt and logout | yes | identical |
| Battles, Pokemon commands and moves | no | to do |
| NPC dialogue and shops | no | to do |
| Containers, items, trade | no | to do |
| Pokedex, badge case, daycare | no | to do |

Last full run: all 25 steps pass on both clients, 21 identical client packets, worst
screenshot difference 0.22%.
