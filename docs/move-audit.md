# Move audit (October 30)

Which moves to add before the Gen 4 import ([gen4-levels-and-moves.md](gen4-levels-and-moves.md)).
We have 455 moves (`core/server/data/lib/ps/config/moves/`). "Signature" here means a move only
one evolution family learns (PokéAPI, every learn method, Pokémon #1-493). None of the moves below
exists yet in the server, the client move list or `others/moves_disabled/`.

Our legendary moves (Psystrike, Aeroblast, Sacred Fire, Doom Desire, Origin Pulse) are plain data:
damage, element, area or target, effect, projectile and cooldown, with a small spell script and no
special code. Most moves below can be built the same way. The ones marked **needs code** have an
effect we don't have yet.

Every new move needs: a config in `config/moves/`, a spell script in `events/spells/scripts/` and
its line in `spells.xml`, a client entry with its description in `gamelib/moves.lua`, and a
32x32 move icon (client item). We have no icons for these yet: they need drawing or a source.

## 1. Legendary signature moves (add all)

| Move | Pokemon | Type | Power | In our game |
| --- | --- | --- | --- | --- |
| Roar of Time | Dialga | Dragon, special | 150 | big area; the user rests afterwards (a longer cooldown) |
| Spacial Rend | Palkia | Dragon, special | 100 | area, high critical chance (like Aeroblast) |
| Shadow Force | Giratina | Ghost, physical | 120 | **needs code**: vanishes for a moment (can't be hit), then strikes |
| Magma Storm | Heatran | Fire, special | 100 | area that burns every second for a few seconds (a trap) |
| Crush Grip | Regigigas | Normal, physical | up to 120 | **needs code**: stronger the more health the target has left |
| Seed Flare | Shaymin | Grass, special | 120 | area; may lower Sp. Defense |
| Judgment | Arceus | Normal, special | 100 | its type follows Arceus's plate later; Normal for now |
| Dark Void | Darkrai | Dark, status | | area sleep (like Spore in an area) |
| Lunar Dance | Cresselia | Psychic, status | | **needs code**: heals the trainer's other Pokemon fully, Cresselia faints |
| Mystical Power | Uxie, Mesprit, Azelf | Psychic, special | 70 | raises the user's best attack stat (Legends: Arceus) |
| Heart Swap | Manaphy | Psychic, status | | swaps stat changes with the target; low value, can wait |
| Precipice Blades | Groudon (and Primal) | Ground, physical | 120 | area of rising rock; Primal Groudon's move |
| Dragon Ascent | Rayquaza | Flying, physical | 120 | lowers the user's defences; the Mega Rayquaza move |

Kyogre's Origin Pulse is already in. Lunar Blessing (Cresselia) and Take Heart (Manaphy, Phione)
are later remakes of Lunar Dance and Heart Swap: skip them.

## 2. Gen 4 Pokemon's own moves (add)

| Move | Pokemon (#1-493 that learn it) | Type | Power | Note |
| --- | --- | --- | --- | --- |
| Attack Order | Vespiquen | Bug, physical | 90 | high critical chance |
| Defend Order | Vespiquen | Bug, status | | raises Defense and Sp. Defense |
| Heal Order | Vespiquen | Bug, status | | heals half its health |
| Chatter | Chatot | Flying, special | 65 | always confuses |
| Rock Wrecker | Rhyperior | Rock, physical | 150 | the user rests afterwards |
| Headlong Rush | Torterra, Hariyama | Ground, physical | 120 | lowers the user's defences |
| Raging Fury | Infernape, Growlithe, Arcanine | Fire, physical | 120 | a rampage of several hits, then confusion |
| Sacred Sword | Gallade | Fighting, physical | 90 | ignores the target's Defense boosts |
| Aqua Cutter | Gallade | Water, physical | 70 | high critical chance |
| Wave Crash | Buizel, Floatzel, Empoleon, Squirtle line, Kingdra, Swampert | Water, physical | 120 | recoil |

## 3. Shared moves the Gen 4 movesets want (add)

Not signatures, but key moves for several of our Pokemon, and Gen 4 movesets in the plan use them:

| Move | Type | Power | Learned by (examples) |
| --- | --- | --- | --- |
| High Jump Kick | Fighting, physical | 130 | Hitmonlee, Blaziken, Medicham, Lopunny, Lucario |
| Mystical Fire | Fire, special | 75 | Mismagius, Ninetales, Clefable, Mr. Mime (24) |
| Vacuum Wave | Fighting, special | 40 | Lucario, Hitmontop, Machamp line (37) |
| Feint | Normal, physical | 30 | 51 Pokemon; already in `moves_disabled/`, turn it back on |
| Liquidation | Water, physical | 85 | 80 Pokemon (Golduck, Feraligatr, Floatzel...) |
| Body Press | Fighting, physical | 80 | 68 Pokemon (Regigigas, Bastiodon, Steelix...) |

## 4. Gen 1-3 Pokemon's own later moves (optional)

Moves later games gave our existing Pokemon as their own. They suit those Pokemon, but none is
needed for Gen 4.

| Move | Pokemon | Type | Power |
| --- | --- | --- | --- |
| Ice Hammer | Abomasnow (Gen 4) | Ice, physical | 100 |
| Sparkling Aria | Lapras | Water, special | 90 |
| Psyshield Bash | Stantler | Psychic, physical | 70 |
| Barb Barrage | Qwilfish | Poison, physical | 60 |
| Raging Bull | Tauros | Normal, physical | 90 |
| Rage Fist | Primeape | Ghost, physical | 50 |
| Hyper Drill | Dunsparce | Normal, physical | 100 |
| Dragon Hammer | Tropius | Dragon, physical | 90 |

Skip: Barrage, Kinesis, Conversion and Sharpen (weak Gen 1 moves), and the Legends: Arceus moves of
Hisuian forms (Esper Wing, Triple Arrows and so on), which no Pokemon up to #493 learns.

## Egg moves that point at nothing

Egg move lists name 61 moves that don't exist on the server. 11 of them were typos of moves we
have, now fixed ([#361](https://github.com/GIToez/PokeVerse/pull/361)). The other 50 are real moves
we haven't built, so those egg moves can't be learned. The most common: Natural Gift (24 Pokemon),
Beat Up (19), Belly Drum (16), Block (16), Whirlwind (14), Feint (14), Helping Hand (13),
Perish Song (13), Skill Swap (13), Wide Guard (10), Final Gambit (10), Grudge (10), Me First (10),
Morning Sun (10), After You (10), Guard Swap (10). Most are status moves that do little in real-time
fights; Belly Drum, Morning Sun, Perish Song, Whirlwind and Spikes are worth building.

## Mechanics check (October 31)

A script loaded every move config and checked it against the spells, the Pokemon movesets and the
client move list. Movesets, spells and the client list all match (every move a Pokemon learns
exists, has its `script_<name>` spell and its client icon and description). Fixed:

- **Dragon Pulse** had `ooldownTime`, so it fell back to the 10 s default instead of 21 s.
- **Shared cooldowns:** a cooldown is kept on the ball under the move's `cooldownStorage`, so two
  moves with the same number shared one cooldown. Metal Burst (with Echoed Voice), Shell Smash (Aqua
  Jet), Spider Web (Stone Edge) and Stealth Rock (Constrict) now have their own (15482-15485).
- **Bug Bite** had a 5 s cooldown; the other 60-power single-target hits (Bite, Pluck) have 9 s.

Notes, not changed:

- `functionName` in the move configs is not read anywhere: the spell is always `script_<move name>`.
- Final Gambit, Grudge, Me First, Spikes and Wide Guard have spells, but they are copies of Tackle
  (and Me First of Mimic), which is why their configs sit in `others/moves_disabled/`. They need
  their own code before they go on.
- Pressure doubles the cooldown of moves aimed at its Pokemon (Stall: 1.1x). The legendary birds,
  beasts, Mewtwo, Lugia, Ho-Oh and Deoxys have it, so fights against them run at half speed. A
  gentler 1.5x would still mark it.

## Added October 31

Lunar Dance (Cresselia 75), Ice Hammer (Abomasnow 75), Sparkling Aria (Lapras 70), Psyshield Bash
(Stantler 70), Barb Barrage (Qwilfish 70), Raging Bull (Tauros 70), Rage Fist (Primeape 75), Hyper
Drill (Dunsparce 70) and Dragon Hammer (Tropius 70), plus the egg moves Belly Drum, Morning Sun,
Whirlwind and Spikes, which Pokemon already listed but could not learn. Precipice Blades was already
in as "Precipice Blade" (Groudon 55).

- Rage Fist hits up to twice as hard the more HP the user has lost.
- Raging Bull and Hyper Drill lift Protect before they hit, like Feint.
- Whirlwind blows the wild Pokemon in front of the user back up to 2 tiles.
- Spikes hurts everything around the target that touches the ground (not Flying, Levitate or
  Magic Guard). Its old icon (27659) was already its own.
- Belly Drum fails (no cooldown, no energy) at half HP or less.

The icons (client items 29871-29882) are copies of the icon of a similar move, to be replaced: Lunar
Dance (Moonlight), Ice Hammer (Ice Punch), Sparkling Aria (Bubblebeam), Psyshield Bash (Zen
Headbutt), Barb Barrage (Poison Jab), Raging Bull (Take Down), Rage Fist (Shadow Punch), Hyper Drill
(Drill Run), Dragon Hammer (Dragon Rush), Belly Drum (Swords Dance), Morning Sun (Synthesis),
Whirlwind (Roar).

Still out: Heart Swap, Perish Song (a timed faint is too strong against wild and legendary Pokemon in
real time), Final Gambit, Grudge, Me First and Wide Guard.
