# Feature Audit

Status of each gameplay system in the imported PokeJornadas base. **Nothing has been built or run**, so no feature is marked "Confirmed". The statuses mean:

- **Appears Implemented**: client, server and data are present and consistent on reading.
- **Partial**: works in part, or content is placeholder or expired.
- **Broken**: a definite defect will stop it working as shipped (for example a missing table or a missing handler).
- **Unknown**: not enough evidence either way.
- **Missing**: does not exist.

Column key: Client and Server name the main module or file; Database names the tables (or "storages" / "item attrs" when there are none).

| Feature | Exists | Client | Server | Database | Working Status | Notes |
|---|---|---|---|---|---|---|
| Pokémon as pokeball items | Yes | `game_pokebar`, `game_pokemonInfo` | `ps/functions`, C++ | item attrs, `player_pokemon` | Appears Implemented | Core design. All Pokémon data is stored on the ball item. |
| Species / shinies (Gen 1–3) | Yes | `data/things` | `ps/config` (434 files), `monster/` | — | Appears Implemented | 386 species, 369 shinies |
| Moves, cooldowns, fast-call | Yes | `game_pokemoves`, `game_pokebar` | `ps/systems/003`, `004`, `006`, `007` | — | Appears Implemented | 456 moves. PSoul sub-opcodes 1, 9. The MoveBarClose/Open (2/3) callbacks have no Lua listener. |
| Catching, ball counter, seals | Yes | — | `020-ballCounter`, `019-ballSeal`, `053-extraCatchRate` | `ball_counter`, `datalog_caughts` | Appears Implemented | |
| Boost (`extraPoints`) | Yes | `game_pokemonInfo` | C++ HP formula, `ps/functions`, daycare | item attrs | Partial | Cap is 109 in one place and 110 in another. Boost stone 12618 is a stub. |
| Base upgrade stones | Yes | `game_pokemonInfo` | `lib/game_pokemonInfo.lua` (opcode 63) | item attrs | Appears Implemented | Cap 150 per stat |
| IVs / EVs | Yes | `game_pokemonInfo` | `lib/game_pokemonInfo.lua`, `pokeivev.lua` | item attrs | Broken | `ballsAttributes.evspendingPoints` is undefined |
| Natures | Yes | `game_pokemonInfo` | `NATURES` table | item attrs | Appears Implemented | 25 natures |
| Vitamins | Yes | — | `040-vitamin.lua` | item attrs | Partial | Zinc's description shows the Calcium values |
| Friendship | Yes | `game_pokemonInfo` | `lib/game_pokemonInfo.lua` | item attrs | Broken | The money check is inverted |
| Held items | Yes | — (no window) | `046-heldItem.lua` | item attrs | Partial | Dragon Fang applies Fire |
| Special abilities | Yes | — | `017-specialAbilities.lua` | item attrs | Appears Implemented | |
| Field abilities (cut, surf, fly…) | Yes | — | `039-pokemonAbility.lua` | — | Appears Implemented | |
| Mastery | Yes | — | `014-mastery.lua` | `datalog_mastery_token_bought` | Appears Implemented | |
| Pokémon addons | Yes | bottom-menu button | `038-pokemonAddon.lua` | item attrs | Appears Implemented | |
| Pokémon food | Yes | — | `047-pokemonFood.lua` | item attrs | Unknown | |
| TMs | Yes | `game_tmchoose` | `018-technicalMachine.lua` | item attrs | Appears Implemented | PSoul sub-opcode 13 |
| Egg moves | Yes | — | egg code | `datalog_egg_move_*` | Appears Implemented | |
| Evolution | Yes | — (no window) | `doPokemonEvolve` | item attrs | Appears Implemented | |
| Eggs / incubators | Yes | — | `045-pokemonEgg.lua` | `egg_counter`, `datalog_egg_generate` | Appears Implemented | About 60 minutes; shiny 1/8192 |
| Daycare / breeding | Yes | — | daycare NPCs | `daycare_*`, `egg_counter` | Appears Implemented | |
| PC boxes | No | — | — | — | Missing | Overflow goes to the depot |
| Pokédex | Yes | `game_pokedex` | `010-pokedex.lua` | storages | Appears Implemented | PSoul 10–12, 17. `/images/game/pokes/` images missing on the client. |
| Doll case | Yes | `game_dollcase` | `041-dollCase.lua` | storages | Appears Implemented | |
| Battle pass | Yes | `game_pass` | `lib/game_pass.lua` (opcode 61) | storages | Partial | Season ended 2021-11-04. `Pass.PassVersion` is undefined. Missions are not wired up. Placeholder rewards. Client uses `loadstring`. |
| Global market | Yes | `game_market` | `lib/game_market.lua` (opcode 64) | `market_items`, `market_historic` (**missing**), `market_offers` (wrong columns) | Broken | Will fail on the first query. Also has the `item_index..item_index` DELETE bug, and the client uses `loadstring`. |
| Pokémon market / PokéTrader | Yes | — (NPC dialogue) | NPC scripts | `pokemon_market`, `poketrader_*` | Appears Implemented | |
| Dungeons | Yes | `game_dungeon` | `lib/game_dungeon.lua` (opcode 41) | `dungeon_ranking` (**missing**), storages | Partial | Only Beginner maps; only Map 1 is fully detailed. The ranking table is missing. |
| Legacy bird dungeons | Yes | — | `028-dungeons.lua` | — | Unknown | |
| Game shop | Yes | `game_shop` | `talkactions/scripts/shop/*` (opcode 27) | storages, `z_shop_history` (**missing**) | Partial | `/shoppokecoin` not registered; bless does nothing; web-shop delivery commented out |
| Currencies (diamonds, PokeCoins, SoulCoins, points) | Yes | `game_shop`, `game_calendar` | various | `accounts.soulcoins`, storages | Appears Implemented | Many separate currencies |
| Daily calendar | Yes | `game_calendar` | `lib/game_calendar.lua` (opcode 62) | storages | Partial | Only September 2021 configured. Client uses `loadstring`. |
| Crafting / professions | Yes | `game_craft` | `lib/game_craft.lua` (opcode 103) | storages | Partial | Only rank E has recipes. Client uses `loadstring`. |
| Kill tasks | Yes | `game_task` | `057-Module_Kill.lua` (opcode 58) | storages | Appears Implemented | Client uses `loadstring` |
| Daily kill / catch | Yes | `game_pokekill` | `057-Daily Kill.lua`, `058-Daily Catch.lua` (opcode 59) | storages | Appears Implemented | |
| Quests / tutorial chain | Yes | `game_guide`, `game_questlog` | `002-quest.lua`, quest NPCs (opcodes 8/9) | storages | Appears Implemented | |
| Achievements | Yes | — (no window) | `000-achievements_lib.lua` and `023-achievement.lua` | storages | Unknown | Two parallel systems |
| Badges / gyms / Elite Four | Yes | `game_badgecase` | `024-badgeCase.lua`, `049-eliteFour.lua`, `001-npcBattle.lua` | storages | Appears Implemented | |
| Ranger Club | Yes | — | `029-rangerClub.lua` | `datalog_rangerclub_*` | Appears Implemented | |
| Bosses | Yes | — | `021-boss.lua` | `datalog_boss_*` | Appears Implemented | |
| Team Rocket battles | Yes | — | `050-rocketBattle.lua` | — | Unknown | |
| Seasonal events | Yes | — | `030`, `037`, `048`, `051`, `055` | `datalog_*_drops` | Unknown | Dates are likely 2021 |
| Rate events | Yes | — | `012`, `052`, `053`, `054` | — | Appears Implemented | |
| Duels | Yes | `game_duelmessage` | C++ `partyduel` | `datalog_duel_bet` | Appears Implemented | |
| PvP arena | Yes | — | C++ `pvparena`, `009-pvpArena.lua` | `datalog_colosseum_arena` | Appears Implemented | |
| Tournaments | Yes | — | C++ `tournament` / `iotournament` | tournament tables | Unknown | |
| Polls | Yes | `game_poll` | C++ `iopoll` | poll tables | Appears Implemented | |
| Highscores | Yes | — | `011`, `013`, `022`, C++ `ioplayerstatistics` | statistics tables | Appears Implemented | |
| Slot machine | Yes | `game_slotmachine` | `044-slotMachine.lua` | `datalog_slot_machine` | Appears Implemented | |
| Surprise box / coupons | Yes | — | `034-surpriseBox.lua` | `datalog_surprise_box` | Unknown | |
| Referral | Yes | — | `035-referral.lua` | `datalog_referral_exchange` | Unknown | |
| Safari, fishing, headbutt, berries, ski, sandboard, diving | Yes | — | `016`, `043`, `036`, `015`, `032`, `042`, `033` | — | Appears Implemented | |
| Houses | Yes | `game_house*` | C++, `look.lua` (opcodes 199, 201, 202) | stock house tables | Partial | Opcode 200 (owner panel) has no server sender |
| Depot password lock | Yes | `game_depotlock` | `060-Depot_locker.lua` (opcode 60) | storages | Appears Implemented | Password commands are talkactions. (The missing `player_stored_items` table is only used by `doPlayerInsertStoredItem`/`doPlayerRemoveStoredItems` in `ps/functions/others.lua`, which nothing calls.) |
| Stack money button | Yes | `game_inventory` | — | — | Broken | Opcode 141 has no server handler |
| Ambient sound | Yes | `game_environment` (not loaded) | `059-AmbientSound.lua` (opcodes 81/85) | — | Broken | The client never handles 81/85 |
| Day/night clock | Yes | `game_time` | C++ world light | — | Appears Implemented | |
| Dash walking | Yes | `client_options` | C++ (opcode 10) | — | Appears Implemented | |
| In-client account creation | Yes | `poke_create` | C++ `protocollogin.cpp` (`0xFC`/`0xFD`) | `accounts`, `players` | Appears Implemented | **Insecure.** See SECURITY_AUDIT finding 15. |
| Locale switching | Yes | `client_locales` | `setLanguage` talkaction | — | Partial | Opcode 1 has no server handler |
| Notifications / broadcasts | Yes | `game_notifications` | `doSendCustomBroadcastMessage` (opcode 25) | — | Appears Implemented | |
| Client auto-updater | Yes | `game_updater`, C++ | HTTP server (not included) | — | Unknown | Insecure (SECURITY_AUDIT finding 2) |
| Website / AAC | No | — | — | Znote/Gesior-style tables | Missing | No web code in the package |
| Payments (PayPal/PayGol) | Schema only | — | `gesior-shop-system.lua` (commented out) | `paypal_*`, `paygol_*` | Missing | Web side not included |
| Data logging | Yes | — | C++ `iodatalog`, `025-datalog.lua` | ~30 `datalog_*`; `datalog_ping` **missing** | Partial | |
