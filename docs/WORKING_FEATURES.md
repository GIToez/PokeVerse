# Working Features (Phase 2 baseline)

This is the state of PokeVerse at the end of Phase 2. Evidence for every entry is in `FEATURE_TEST_MATRIX.md`. "Verified" means it was exercised at runtime on the source-built server and client, with no server or client error.

## VERIFIED WORKING

- **Build and run**
  - Server and client build from source on Ubuntu 24.04 (GCC 13).
  - This also works from a fresh clone plus `git lfs pull`.
  - CI builds both components.
- **Server startup.** The startup log is clean (one harmless MySQL-version warning). The server listens on 127.0.0.1 only.
- **Database.** Every table the Lua code references exists (`tools/check_db_tables.py`).
- **Login and entering the game**
  - Account login and the character list work, as does entering the game for both development accounts.
  - The map, inventory, minimap, health and chat panels render.
- **Walking.**
- **Chat.** Typing in the Default tab works, and NPC greetings arrive.
- **Speech bubbles and containers.** NPC and Pokémon speech bubbles show; containers and the pokébag open.
- **Pokémon basics**
  - Summon and recall from the feet-slot ball, including the player-level rule.
  - Pokémon Info window: IVs, EVs, base stats and friendship.
- **EV spend and EV reset.**
- **Friendship.** Feeding gives EXP. A level-up checks funds and charges the correct amount.
- **Items on Pokémon**
  - Held items (Dragon Fang tested).
  - Vitamins (Zinc tested).
- **Pokédex.** Registering a Pokémon gives XP and an achievement.
- **Achievements.**
- **Opening the feature windows.** Battle Pass, the daily calendar, the dungeon map list, crafting, tasks, the shop and the market all load their data from the server and open.
- **Client payload decoding.** It uses a data-only parser and rejects code.
- **GM tools.** `/i` (create item) and `/cb` (create Pokémon) work with exact names.

## PARTIAL

- **Wild Pokémon combat.** Damage, kill, loot and XP were verified once. In later runs the GM-spawned Rattata was unreachable from the temple spawn tile.
- **Dungeons, crafting, tasks, shop, market.** The windows and server data work. Doing the actual action (entering a dungeon, crafting, finishing a task, buying, trading) was not exercised.
- **Daily calendar and Battle Pass.**
  - Their data loads.
  - Claiming rewards was not exercised.
  - The content dates are stale (2021).
  - `Pass.PassVersion` is undefined but harmless while the version is 1.
- **`/cb`.** A lower-case Pokémon name raises a script error (GM-only).
- **NPCs.** Greetings work. Shops and quest dialogues were not exercised.

## IMPLEMENTED BUT UNTESTED

- Catching (throwing an empty ball at a corpse). The harness never had a fresh corpse.
- Duels, the PvP arena and tournaments (these need two players).
- Eggs, daycare and breeding.
- Fishing, headbutt, and surf/fly/ride movement.
- Houses (buying, selling, owner panel).
- Quests, bosses, the Elite Four, the Ranger Club, the Safari Zone, slot machines, and the doll and badge cases.
- Seasonal events (date-gated).
- Mastery. The code loads, but no mastery NPC is placed on the map.

## BROKEN

- **Stack-money button.** The client sends opcode 141, which has no server handler.
- **House owner panel.** Opcode 200 has no server sender.
- **`/shoppokecoin`.** Referenced, but not registered.
- **House 221 on shutdown.** An uninitialized `warnings` value is rejected by MySQL, so that house row is not saved.

## DISABLED

These are disabled on purpose, for security or policy (`SECURITY_AUDIT.md`):

- The client updater (`LEGACY_UPDATER` OFF).
- Account creation over the login protocol (0xFC/0xFD; compiled only with `__ACCOUNT_CREATION__`).
- Database root and no-password settings. They were replaced by local development credentials.

## MISSING

See `MISSING_FROM_POKEVERSE.md` for features PokeNation has and PokeVerse lacks. The main ones:

- a server-wide EXP event;
- the BUG-68 login-challenge fix;
- the BUG-72 shutdown fix;
- the Nation client fixes;
- the larger PSoul world map.

Nothing was ported in Phase 2.

## Bugs fixed in Phase 2

### Build, startup and login

- **Linux build blockers:** see `BUILD_BASELINE.md`.
- **Spells directory:** spells never loaded on POSIX.
- **Latin-1 charset:** the database connection now uses it.
- **Encryption marker:** it blocked login.
- **Market and dungeon tables:** these were missing.
- **Log directories:** missing on a fresh clone.

### Security

- `loadstring` on server payloads was replaced by a data-only parser.
- The updater is disabled.
- Account creation (0xFD) is compiled out.
- The default credentials are gone.

### Gameplay and client logic

- **EV spending:** points were never recorded.
- **EV boost cap.**
- **Dragon Fang:** used the wrong element.
- **Zinc:** the description used the wrong id.
- **Friendship:** money was charged when funds were insufficient.
- **Market DELETE queries:** each had a doubled index.
- **Pokédex:** `getPokemonDexStorage` was undefined, so every dex use failed.
- **Pokémon Info:** the reply errored with no summon.
- **Client crash on Pokémon/monster speech:** a Lua stack leak.
- **Container window crash.**
- **Chat Ctrl+A error.**
