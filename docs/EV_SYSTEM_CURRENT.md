# EV System (current behaviour, preserved in Phase 3)

PokeVerse EVs (effort values) are **manually allocated** by the player in the Pokémon Info window. They are **not** earned by defeating Pokémon. Phase 3 keeps this exactly as it is.

> **FUTURE PHASE: Convert EVs to species-specific battle-earned EV yields. NOT PART OF PHASE 3.**

## Storage

All EV data lives on the Pokémon's **ball item** as item attributes (`server/runtime-data/data/lib/ps/config/balls.lua`):

| Attribute | Key | Meaning |
|---|---|---|
| `evhp`, `evatq`, `evdef`, `evspatq`, `evspdef`, `evspd` | `base + 80` to `base + 85` | EVs in HP, Attack, Defense, Sp. Attack, Sp. Defense and Speed |
| `evspendingPoints` (same slot as the legacy `evpoints`) | `base + 86` | Total EV points already spent |

The values move with the ball through trades, the market and the depot, because they are item attributes.

## Points available

```
available = pokemonLevel * 5 - evspendingPoints        -- getBallPokemonEvPoints (game_pokemonInfo.lua)
```

A level-15 Pokémon has 75 points. Points come only from level, and nothing else grants EV points.

## Allocation (EV spend)

- **Client.** The Pokémon Info window sends extended opcode `GameServerOpcodes.PokemonInfo` with `{"protocol":"upgrade","patternId":"ivev","tab":[{"id":"hp","value":10}, ...]}`.
- **Server.** `creaturescripts/scripts/opcode.lua` calls `upgradeEv(cid, tab)` in `lib/game_pokemonInfo.lua`. Validation:

| Rule | Value | Code |
|---|---|---|
| Needs the Pokémon's ball (`getPlayerBall`) | — | `upgradeEv` |
| Nothing happens with 0 available points | — | `if points == 0 then return end` |
| **Per-stat cap** | **250** (a stat entry is skipped if it would pass 250) | `value + ev.value <= 250` |
| Cannot spend more than available | `spendingReq <= points` | |
| **Total cap** | **500** across all six stats | `spendingReq + sum(evs) > 500 → return` |

On success the six attributes and `evspendingPoints` are written. The ball description is refreshed: the look text shows `IV (+EV)` for each stat. The server then sends `sendPokemonInfo`.

## Reset

- **Client.** Sends `{"protocol":"reset","type":"ivev"}`.
- **Server.** Requires one **EV reset ticket** (item 35552). The server removes the ticket and calls `doResetEvs`, which sets all six EVs and `evspendingPoints` to 0, refreshes the ball, resends the Info payload, and replies `{"Reset":{"code":"IvReseted"},"protocol":"Info"}`.
- **Without the ticket** the server replies `{"Reset":{"code":"Iv"},"protocol":"Info"}` and changes nothing.

The `"IvReseted"` and `"Iv"` codes are matched by the client and must not be renamed (`TRANSLATION_AUDIT.md`: KEEP - COMPATIBILITY).

## Effect on stats

The formulas are in `lib/game_pokemonInfo.lua`; `getPokemonAtk` and `getPokemonAtkByBall` are representative:

```
stat = ((2 * speciesBase + IV + EV + BaseUpgrade) * level / 100) + 5      -- Atk, Def, SpAtk, SpDef, Speed
stat = nature boosts it ×1.1, nature lowers it by −10 %, neutral leaves it
```

HP is applied when the Pokémon is summoned (`lib/ps/functions/others.lua`):

```
maxHP = engineMaxHP + IV_hp * 100 + EV_hp * 10 + BaseUpgrade_hp * 10
```

Base Upgrades (`upgradeBase`, `doResetBase`, the separate +Base system with its own items and the "BASE recovery ticket" 35553) are a different system and are not part of EVs. Vitamins are applied separately in `Vitamin.onPokemonCall` (`VITAMIN_AUDIT` section in `MISSING_FROM_POKEVERSE.md`).

## Verified at runtime (Phase 2 and Phase 3 harness, Linux server and legacy client)

| Case | Result |
|---|---|
| Level-15 Charmander starts with 75 points, all EVs +0 | PASS |
| Spend HP +10 and Sp.Def +5: points 75 → 60; ball shows `Hp: x (+10)` | PASS |
| Reset with ticket 35552: all +0, points back to 75, reply `IvReseted` | PASS |

Not yet exercised: the 250 per-stat cap, the 500 total cap, reset without a ticket, and allocation through the Redemption client.

## Phase 3 rules

- Do not change the formulas, caps, storage keys or opcode payloads.
- The Redemption port of the Pokémon Info window must send the same payloads and handle `IvReseted` and `Iv` (`REDEMPTION_PARITY_MATRIX.md`).
