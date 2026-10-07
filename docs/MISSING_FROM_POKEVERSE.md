# Missing from PokeVerse (relative to PokeNation)

This list covers PokeNation features that PokeVerse lacks, or has in a changed or weaker form. The source is the static comparison in `POKENATION_FEATURE_PARITY.md` (PokeNation commit `e272654`, read-only), plus the Phase 2 runtime results in `FEATURE_TEST_MATRIX.md`.

**Nothing was ported in Phase 2.** The recommendations below are for later phases.

Recommendation key:

- **KEEP POKEVERSE VERSION**: Verse's replacement is adequate or better.
- **PORT LATER FROM POKENATION**: Nation's implementation is the better base. Port it in an explicit porting phase.
- **REBUILD**: neither version is a good base, so write it fresh against Verse's systems.
- **NOT NEEDED**: out of scope for the Jornadas design.
- **INVESTIGATE**: needs a decision or a runtime check first.

Importance: **High** means it affects core play or safety. **Medium** means it is a visible feature. **Low** means cosmetic, event-only, or content.

## Gameplay systems

| PokeNation Feature | Importance | Missing/Changed in Verse | Replacement | Recommendation |
|---|---|---|---|---|
| Server-wide EXP event (`/doubleexp`, `/expevent`, `sys/056`, C++ multiplier) | Medium | Missing | Per-player EXP potions (`sys/012`) and area XP banners (`lib/bannerExp.lua`). Their scope differs. | PORT LATER FROM POKENATION |
| PSoul binary item market (C++ `iomarket`, packets 0xF4–0xF9) | Medium | Removed from C++. `npc/market.lua` still calls the unregistered `doPlayerSendMarketEnter` (that NPC is unspawned). | Graphical Lua market (opcode 64). Its tables were created in Phase 2 and its DELETE queries fixed. | KEEP POKEVERSE VERSION |
| Mastery (35 mastery NPCs) | Medium | The code loads, but no mastery NPC is placed on the Jornadas map, so it is unreachable | `/BuyMasteryRank` shop purchase | INVESTIGATE (place NPCs on the map, or keep the shop-only design) |
| Hometown change at Nurse Joy | Low | Commented out (`npc/nurse_joy.lua:238-247`) | None | INVESTIGATE (Jornadas may have removed it on purpose) |
| Surprise-box spawning | Low | Startup step commented out (`globalevents/scripts/start.lua:229-232`) | None | INVESTIGATE (the spawn positions are for Nation's map; x<2048 has no Verse land) |
| Sudowoodo respawn event | Low | Globalevent commented out | None | INVESTIGATE |
| Startup quest spawns (Wampi tree, Juanito letter, Crystal Onix, Aerodactyl whirlpool, 5 random NPCs) | Low | Commented out (`start.lua:50-93`) | None | INVESTIGATE (check that the positions exist on the Jornadas map) |
| Anniversary event | Low | Globalevent and `onKill`/`onSpawn` hooks commented out | None | KEEP POKEVERSE VERSION (Nation's version is permanently on, BUG-14) |
| Larger PSoul world (Orange Archipelago, southern regions, about 10k more spawns, 381 more houses, more quest/bank/Soul Trade NPCs) | High (content) | Verse ships the smaller Jornadas map (see `MAP_AUDIT.md`) | Jornadas map | NOT NEEDED in this phase. A map merge is a separate project. |
| Pokédex status list sent at login | Medium | Removed (`fn/player.lua:1062` commented out). The client still waits for it. | Sent only on Pokédex upgrade | INVESTIGATE. Registering a Pokémon with the dex works at runtime after the Phase 2 `getPokemonDexStorage` fix (`FEATURE_TEST_MATRIX.md`). The login status list is still not sent; restoring one line may be enough. |
| Pokémon details window (`pn/game_pokemondetails`) | Low | Not present | `game_pokemonInfo` window (stats, IV/EV/base, friendship) | KEEP POKEVERSE VERSION |
| Old disabled task system | Low | Unloaded in both | `057-Module_Kill.lua` tasks plus daily kill/catch | KEEP POKEVERSE VERSION |
| `/house …` commands | Low | Renamed to `!buyhouse`/`!sellhouse`, with house UI modules | Graphical house windows | KEEP POKEVERSE VERSION. The owner panel (opcode 200) has no server sender: REBUILD that panel. |
| Fishing cast range (4 tiles) | Low | Range check removed | Unlimited cast | INVESTIGATE (a design choice or an exploit) |
| Localization login validation and extended opcode 1 handler | Medium | The language byte is not validated (BUG-08); opcode 1 has no handler | `/lang` works | PORT LATER FROM POKENATION (small, self-contained fix) |

## Engine fixes Nation has and Verse lacks

| PokeNation Feature | Importance | Missing/Changed in Verse | Replacement | Recommendation |
|---|---|---|---|---|
| BUG-01 combat fix (consented fights under `no-pvp`) | Medium | `combat.cpp` unpatched | `worldType = "pvp"` (the workaround Nation verified) | PORT LATER FROM POKENATION |
| BUG-05 GM energy reporting | Low | Not applicable: every Verse move costs 0 energy | — | NOT NEEDED |
| BUG-68 login-challenge check | High (security) | The challenge is skipped in `protocolgame.cpp` | None | PORT LATER FROM POKENATION |
| BUG-72 shutdown bug (`server.cpp`) | Medium | Present | None | PORT LATER FROM POKENATION |
| Boost.Asio port (`connection.*`, `server.*`) | Medium | Verse compiles against Boost 1.83 with minimal fixes (`BUILD_BASELINE.md`) | Minimal fixes | KEEP POKEVERSE VERSION for now; INVESTIGATE if network issues appear |
| C++ extended-opcode dispatcher (`extendedopcodes.h`) | Low | Verse dispatches in Lua (`creaturescripts/scripts/opcode.lua`) | Lua dispatcher | KEEP POKEVERSE VERSION |
| Nation client fixes (TM chooser listener leak BUG-57, U16 counts BUG-59/60, jump assertion BUG-75) | Medium | Verse's client has the legacy behavior | — | PORT LATER FROM POKENATION. The wire formats differ (see the parity doc), so port per fix, not per file. |
| New OTClient Redemption client (`client-pokenation/`) | Medium | Verse keeps its own OTClient 0.6.6 fork | Verse client, now building on Linux | KEEP POKEVERSE VERSION. Porting the client means reconciling the Verse Pokébar, item and creature packet fields first. |
| SQL schema directory (`schemas/`), including `datalog_ping` | Low | Verse uses its dump plus `database/migrations/` | Migrations | KEEP POKEVERSE VERSION. `datalog_ping` is only used by commented-out C++. |

## Broken Jornadas additions found in Phase 2 (no Nation equivalent)

These are not Nation features, but they belong on the same work list.

| Feature | Importance | State after Phase 2 | Recommendation |
|---|---|---|---|
| Stack-money button (`game_inventory` sends opcode 141) | Low | No server handler. The `$stackemoney$` talkaction exists but the client never sends it. | REBUILD (small) |
| House owner panel (opcode 200) | Low | No sender | REBUILD |
| `/shoppokecoin` used by `mercado.lua` | Low | Not registered | INVESTIGATE |
| Battle Pass season (ended 2021-11-04), calendar (only Sep 2021 configured) | Medium | Stale content | INVESTIGATE (new season content is out of scope for Phase 2) |
| Friendship bonuses (crit, loot luck, shiny charm, energy regen) | Medium | Written but never read by game code | INVESTIGATE (a design decision; not fixed in Phase 2, which avoids rebalancing) |
| IV/EV/nature/base stats other than HP | Medium | Only HP values affect stats | INVESTIGATE (same reason) |
| Graphical market, EV spending | High | Fixed in Phase 2 (tables, DELETEs, `evspendingPoints`). See the runtime results. | KEEP POKEVERSE VERSION |

## VITAMIN_AUDIT

Phase 3 audit of the vitamin system against PokeNation. Nothing was changed; this section records the current behaviour so later phases do not redesign it by accident.

**Verdict: PRESENT IN BOTH, same system.** Verse uses `server/runtime-data/data/lib/ps/systems/040-vitamin.lua`, the same `sys/040` module as Nation (`POKENATION_FEATURE_PARITY.md`, Moves and development). The only Verse-side difference found is the Phase 2 Zinc description fix. Recommendation: **KEEP POKEVERSE VERSION**. The Nation vitamin import is future work and is not part of Phase 3.

| Vitamin | Item ID | Stat | Value at 1 / 2 / 3 applies | Max applies |
|---|---|---|---|---|
| HP Up | 23452 | Max HP | +5% / +8% / +10% | 3 |
| Protein | 23456 | Attack | +5% / +8% / +10% | 3 |
| Iron | 23453 | Defense | +5% / +8% / +10% | 3 |
| Calcium | 23450 | Special Attack | +5% / +8% / +10% | 3 |
| Zinc | 23457 | Special Defense | +5% / +8% / +10% | 3 |
| Carbos | 23451 | Speed | +10% / +16% / +20% | 3 |
| PP Up | 23455 | Max Energy | +5% / +8% / +10% | 3 |
| PP Max | 23454 | Max Energy | +10% | 1 |

Rules (`Vitamin.onUse`):

- The target must be a ball holding a Pokémon, and no Pokémon may be out of its ball.
- The vitamin and the ball must both be in the player's containers ("You must pick up this item first."). The source comment notes this check does not prove the player is carrying the item.
- A ball accepts at most 10 vitamins in total and 3 of each kind (PP Max: 1).
- Level gate: the next vitamin needs Pokémon level ≥ (vitamins already applied) × 10. The first vitamin has no level requirement; the tenth needs level 90.
- The value is looked up by apply count, not summed: three Zinc give +10%, not +23%.
- Applied on summon by `Vitamin.onPokemonCall`, which calls `setMonsterVarPokeStat`. The C++ side (`Monster::setVarPokeStat`) adds the modifier to a 1.0 multiplier, so different vitamins stack, and PP Up and PP Max stack on Max Energy.
- `Vitamin.doResetBall` clears all counts. `Vitamin.getBallDescription` lists them in the ball description.
- Player messages go through `__L(cid, ...)`, except the "Pokemon out of the ball" and "pick up this item first" messages, which are hard-coded English.

Notes for later phases (not fixed, to avoid rebalancing):

- Every Verse move costs 0 energy (BUG-05 above), so PP Up and PP Max have no gameplay effect today.
- Runtime coverage: only Zinc was exercised (harness PASS, `FEATURE_TEST_MATRIX.md`). The other seven share the same code path but are NOT TESTED.
