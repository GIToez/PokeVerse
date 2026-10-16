# IVs, EVs and Natures

Every Pokemon ball carries the official hidden stats: six IVs (0-31), six EVs (0-252 each,
510 in total) and one of the 25 Natures. A ball that has none yet (older balls, new
catches) rolls random IVs and a random Nature the first time the server reads it, and starts
with 0 EVs. Values that are already stored are never rerolled.

The code is in `core/server/data/lib/ps/systems/059-pokemonStats.lua` (`PokemonStats`).

## How they change stats

Each stat is the official formula for the Pokemon's IVs, EVs, Nature and level divided by
the same formula for an average Pokemon (IV 15, 0 EVs, neutral Nature):

```
stat = (2 * base + IV + EV / 4) * level / 100 + 5      (x 1.1 / 0.9 for the Nature)
HP   = (2 * base + IV + EV / 4) * level / 100 + level + 10
multiplier = 1 + IVEV_STAT_WEIGHT * (stat / average stat - 1)
```

An average Pokemon plays exactly as before. `IVEV_STAT_WEIGHT` (default 1.0) scales the
whole effect. Base stats come from the species table (Attack to Sp. Defense) and the monster
XML (HP, and Speed as the XML speed minus 200).

- **Attack, Defense, Sp. Attack, Sp. Defense:** applied in the damage stat getters.
- **HP:** a monster multiplier set in C++ (kept apart from the vitamin bonuses).
- **Speed:** walk speed (C++ multiplier), and for players' Pokemon shorter move cooldowns
  and wind-ups: with `R = Speed / (Speed + 150)`, cooldowns are up to 15% shorter
  (`15% x R`) and wind-ups (Fly, Dig, Focus Punch, Sky Attack...) up to 10% shorter. Whole
  second cooldowns are rounded up or down at random in proportion, so every bit counts on
  average. Wild and NPC Pokemon get no Speed benefit.

The multipliers are set when a Pokemon is called, levels up or evolves, and whenever its
ball's values change.

## Natures

The official 25 Natures: one stat x1.1, another x0.9 (HP is never changed), or neutral
(Hardy, Docile, Serious, Bashful, Quirky).

## Gaining EVs

Only **wild** Pokemon give EVs: defeating one gives your Pokemon that species' official EV
yield (`config/evYields.lua`, generated from PokeAPI by `scripts/make-ev-yields.py`; shiny
forms use the normal yield). Trainers' and players' Pokemon give none. The player gets a
message such as `Your Rattata gained EVs: +1 Speed.`

Caps: 252 per stat and 510 in total; gains stop at the cap.

## Items

Sold by **Josh Pillberg** (say `trade`):

| Item | Price | Effect |
| --- | --- | --- |
| Power Weight / Bracer / Belt / Lens / Band / Anklet | 25,000 | Held: +8 HP / Atk / Def / SpA / SpD / Spe EVs on every wild defeat. In breeding, the holder always passes that IV. |
| Destiny Knot | 50,000 | Held: in breeding, 5 IVs are inherited instead of 3. |
| Everstone | 15,000 | Held: in breeding, the holder always passes its Nature. |
| Pomeg / Kelpsy / Qualot / Hondew / Grepa / Tamato Berry | 1,500 | Use on your Pokemon's ball: -10 HP / Atk / Def / SpA / SpD / Spe EVs (refused at 0). |

Held items have no levels or EXP. Drag one onto a Pokemon on the swap bar (or "Use with" its
ball) to give it; Alt+click the Pokemon, or right-click > Take held item, gives it back.

Item ids: server 30137-30150, client 28779-28792. The client artwork is in
`core/client-legacy/data/images/items` and is wired up in `data/things/things.otml`; the
client entries were added to `data.dat` with `scripts/dat-add-items.py`.

## Breeding (Day Care)

When the Day Care makes an egg, it rolls the egg's IVs and Nature from the parents:

- 3 IVs (5 with a Destiny Knot on either parent) come from a random parent, the rest are random.
- A parent holding a Power item always passes that stat's IV.
- A parent holding an Everstone passes its Nature, otherwise it is random.

The egg (and the incubator while it hatches) carries the values; the hatched Pokemon gets
them with 0 EVs. Eggs from before this system hatch with random values.

## Seeing them

- **Ball look text:** Nature, IVs and EVs.
- **Pokedex:** every entry shows the species' EV yield. Your own Pokemon (the one out, or a
  ball you scan) also shows Nature, IV and EV totals and each stat with its IV, EV and effect.
- **Stat overview (Redemption client):** after the Pokedex shows one of your Pokemon, a
  *Pokemon Stat Overview* window opens beside it. It has a radar chart (blue IVs out of 31,
  yellow EVs out of 252, with Combined / IVs / EVs views), the Nature with red (raised) and
  blue (lowered) markers, and a table of each stat's actual value, IV, EV and effect.
  The server sends the sheet as JSON on extended opcode 12 (`EXTENDED_IDS.POKEMON_STATS`,
  `ExtendedIds.PokemonStats` in the client); the chart is the `UIRadarChart` widget
  (`core/client-redemption/src/client/uiradarchart.cpp`), and the window is
  `pokeverse-modern/modules/game_pokedex/stats.lua`.
- **GTS:** each Pokemon listing shows its Nature and IV total, and opening one shows the
  full stat sheet with IV and EV bars.

Staff can set a ball's values with `/pstats` (access 3).
