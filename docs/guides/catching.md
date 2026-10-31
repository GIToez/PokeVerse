# How catching works

A player guide to catching, for Discord. It follows the server code on `main` as of October 31, 2026:
`getCatchRollMaxFor` and `rollCatch` in `lib/ps/functions/ball/empty.lua`, the ball counter in
`lib/ps/systems/020-ballCounter.lua` and the ball values in `lib/ps/config/balls.lua`. The ball counts
in post 3 come from running that formula (average over every possible run, no skill or perks).
Five posts, each under Discord's 2,000-character limit.

## Post 1 of 5

```text
🎯 **How catching actually works**
A full guide, straight from the server code. No myths.

**The basics**
1. Defeat a wild Pokémon. The body belongs to the trainer whose Pokémon did the most damage; only they can throw at it.
2. Click an empty ball in your bag, then click the body.
3. The throw takes about five seconds. Gotcha, or "Ouch! Your ball broke."

**Every throw uses up the body, caught or not.** For another try you need to defeat another one. So the real cost of a catch is balls *and* defeats.

**What does NOT matter**
- The Pokémon's level, HP, status, nature or IVs. It's already defeated, so none of it counts.
- Shiny or not: a shiny is exactly as hard as the normal one.
- Luck streaks: every throw is its own roll.

**What matters**
- The species (how hard it is)
- Your **ball counter** for that species
- The ball you throw
- Your Catching skill, Catcher vocation and a few bonuses

A catch gives experience (the Pokémon's experience x its level x 2) and registers it in your Pokédex. With six Pokémon on you, it goes to your PC boxes. If those are full too, you can't throw.
```

## Post 2 of 5

```text
🔢 **The ball counter: the heart of catching**
Every species has a **difficulty**. Some examples:
- Rattata, Caterpie: 2 · Magikarp: 5 · Pidgey: 10
- Growlithe: 60 · Abra: 100 · Pikachu, Bulbasaur: 150 · Eevee: 200
- Dratini, Larvitar: 500 · Dragonite, Gyarados, Lapras, Snorlax: 800
- Ditto: 1,500 · Tyranitar: 2,000 · Legendaries: 10,000

Every ball you throw at a species adds to **your counter** for it, hit or miss:
- Poke Ball +1 · Great Ball +2 · Ultra Ball +3 · type balls +4

The counter is yours, for that species only, and it's kept until you catch one. Then it starts again at 0. A species and its shiny **share** one counter, so all those broken balls on Charizards count toward a shiny Charizard too.

**Three stages**
1️⃣ **Counter at a quarter of the difficulty or less:** no ball can catch it yet. The throws still count!
2️⃣ **Up to the difficulty:** flat odds, the ball's value ÷ the difficulty. An Ultra Ball on a Pikachu: 3 ÷ 150 = **2%**.
3️⃣ **Past the difficulty:** every extra point makes your odds better, and at **double** the difficulty they're at their best:
- Poke Ball **20%** · Great **40%** · Ultra **60%** · type ball **80%**

Rule of thumb: **on average a catch takes about difficulty ÷ ball value balls.**
Very easy species (difficulty under 5) are easier still: a Great Ball always catches a Rattata.
```

## Post 3 of 5

```text
⚾ **Which ball should I use?**
Average balls (and defeats) for one catch:
`Species       Poke   Great  Ultra  Type`
`Pikachu        152     76     50    38`
`Dratini        507    253    169   127`
`Dragonite      811    406    270   203`
`Tyranitar     2028   1014    675   507`
`Legendary    10138   5069   3379  2535`

The first throw that *can* catch a Pikachu is the 38th Poke Ball, the 19th Great or the 13th Ultra.

**Money vs time**
Poke Balls ($8) give the most counter per dollar. Ultra Balls ($130) need the fewest defeats. A Pikachu costs on average:
- Poke: ~$1,200 and 152 Pikachu defeated
- Great: ~$2,700 and 76 defeated
- Ultra: ~$6,500 and 50 defeated
So: poke balls when money is tight, the best ball you can afford when the species is rare or slow to find.

You can mix balls. Each one adds its own value, so switching never loses progress.

**The balls**
- **Poke, Great, Ultra:** Poke Ball shops. +1, +2, +3.
- **Type balls** (+4, only on their types), from the mastery shops: Avalanche (Ice, Water), Blaze (Fire), Gaia (Grass, Bug), Heremit (Ground, Rock), Hurricane (Flying, Dragon), Spectrum (Ghost, Poison), Vital (Fighting, Normal, Fairy), Voltagic (Electric, Steel), Zen (Psychic, Dark).
- **Master Ball:** always catches. The Pokepedia gives you one when your Pokédex is complete.
```

## Post 4 of 5

```text
📈 **What makes it easier**
**Catching skill**
Each level makes the catch roll 0.1% smaller: 10% at 100, up to **25.5% at 255**. You gain skill with every throw, more for a catch than a miss. Up to 100 it comes quickly; past 100 every level takes 6% more throws than the one before.
Pikachu with Ultra Balls: 50 balls at skill 0, 47 at 100, 44 at 200.

**Catcher vocation**
- Every throw's chance goes up by 2% to 10% of itself (rank 1 to 5): +10% turns 20% into 22%.
- When a ball breaks, a 2% to 10% chance to get it back.

**Bonuses**
- **Discord Server Boost Level 2:** +5% catch chance for everyone online.
- **Bonus catch** rewards (from events) make every species easier while they last.

**The Analyser** (top bar) has a **Catch** tab for the last Pokémon you defeated:
- your ball counter for it, and when it becomes catchable
- the exact chance of your next throw with each ball you carry
- your skill and Catcher bonus
Press its **?** for a short version of this guide.
```

## Post 5 of 5

```text
🌟 **Special cases**
- **Event Pokémon** (Christmas, Easter, Surfing Pikachu and others) ignore the counter. Every throw has the same odds, ball value ÷ difficulty, and some need their own ball.
- **Safari Zone:** only Safari Balls (+4), thrown at a Pokémon that's still standing. First calm it with small stones or cookies until you see "You're able to try caught it now". The same counter rules apply.
- **Legendaries:** difficulty 10,000. The body goes to the trainer who did the most damage, so team up and agree who throws.
- **Wild babies:** attack one and its whole family nearby comes for you.

💡 **Tips**
- Throws that can't catch yet still fill your counter. They're never wasted.
- The counter waits for you: log out, come back next month, it's still there.
- Hunting a shiny? Every normal one you fail on helps. Catching a normal one resets the shared counter, though.
- At double the difficulty your odds stop improving. That's the moment for your best balls.
- Level, HP and status don't matter, so there's no need to keep a Pokémon at low HP or put it to sleep before you throw.

Questions? Ask in the help channel. Happy hunting! 🎣
```
