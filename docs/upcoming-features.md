# Upcoming features

Planned work, roughly in the order it will be done. Nothing here is built yet unless it says
so. Items marked **To decide** need an answer before work starts.

## Order

1. [Depot overflow fix](#1-depot-overflow-fix-pokémon-are-lost-today): Pokémon are lost today.
2. [Auto-walk fix](#2-auto-walk-fix).
3. [Modern NPC dialogue window](#3-npc-dialogue-quests-and-tasks).
4. [Website: live status and Discord card](#4-website).
5. [World map and waypoints](#5-world-map).
6. [Vocations](#6-vocations), replacing the old vocations.
7. [Pokémon storage](#7-pokémon-storage) and the [GTS](#8-gts-global-trading-system),
   together: they share the search, filters and windows.
8. Convert every NPC, quest and task to the new dialogue, then the
   [in-game wiki and tutorial](#9-in-game-wiki-and-tutorial).
9. [Factions](#10-factions).

Also open: the [Android signing key](client-updates.md#one-time-setup) (needed before
players install the APK for real), a phone UI pass, and a security check of the live
server (open ports, SSH, firewall).

## 1. Depot overflow fix (Pokémon are lost today)

A player's depot holds up to 2,000 items (`group.depotLimit`, default in
`src/player.cpp`). A Pokémon caught or given as a reward goes to the depot when the bag is
full. When the depot is full too, `doCreatePokemonBall` (`data/lib/ps/config/balls.lua`)
and `doPlayerEnforcePokemonLimit` (`data/lib/ps/functions/player.lua`) only log
`Can't send to depot` and the ball is lost.

- Never delete: when both are full, the Pokémon goes to overflow storage and the player is
  told. Later it moves into [Pokémon storage](#7-pokémon-storage).
- Search the live server logs for `Can't send to depot` to find Pokémon already lost.

## 2. Auto-walk fix

Auto-walk (clicking on the map or minimap) misbehaves since diagonal walking became faster.
The waypoint walking of the [world map](#5-world-map) depends on it.

## 3. NPC dialogue, quests and tasks

Many NPCs from the old system are missing the blue clickable responses. There are 906 NPC
files and 338 NPC scripts (`core/server/data/npc`).

1. One modern dialogue window for every NPC: name and portrait, blue clickable responses,
   and a notice when a quest is accepted or a task updated.
2. A checker that lists every NPC whose responses are not clickable.
3. Convert the NPCs, quests and tasks town by town. Quests and the task boards show up in
   the quest log.

## 4. Website

Static site on the PokeVerse-Clients `gh-pages` branch ([website.md](website.md)).

- **Live server status:** online or offline, players online, uptime, and who's online. The
  bot already asks the game for these (`server.status`; the online list, `admin.sessions`,
  is staff only today, so a public version with names and levels only is needed).
  - First, without a domain: the bot writes a small status file to a public GitHub gist
    about once a minute and the site reads it.
  - Later, with a domain: a Cloudflare Tunnel to the bot for live data. It needs no
    open port on the server.
  - **To decide:** whether players can hide from the online list (in-game command), and
    whether staff are left out.
- **Discord card:** member count, online count and a Join button, drawn in the site's own
  style from Discord's widget data (Server Settings → Widget must be on). No bot needed.
- **More pages:**
  - Where each Pokémon spawns and the nearest town, on its Pokédex page.
  - Items: balls, stones and held items.
  - Guides: getting started, controls (Chat On/Off, WASD), commands, and IVs, EVs and
    natures (from [pokemon-iv-ev.md](pokemon-iv-ev.md)).
  - Type chart and evolution chains.
  - Live feed of shiny catches and legendary sightings, from the events the bot already
    receives.
  - Countdown to the next restart.
  - Patch notes for each client release.
  - Vocation pages and GTS listings, once those exist.
  - A better download section: detect the player's platform, show the version, and tell
    Android players to open the link in Chrome (the GitHub app catches `github.com` links).
- **Later, with a domain:** rankings (level, catches, shinies) and trainer profiles.

## 5. World map

The full map (from the minimap, or the M key) gets a modern look:

- waypoints the player can set;
- a trail on the map from the player to the selected waypoint;
- auto-walk to a waypoint (after the [auto-walk fix](#2-auto-walk-fix)).

The Redemption client's encyclopedia window (`game_cyclopedia`) has a map to build on.

## 6. Vocations

The old vocation entries in `data/XML/vocations.xml` go, and so does the old mastery system
(see [the old masteries](#the-old-masteries)). Nobody has a mastery yet, so nothing needs
refunding. The mastery items (type plates, mastery tokens, outfits) stay in the game; what
they are used for is not decided yet.

### Rules

1. Players begin as regular Trainers.
2. From player level 20 they choose one vocation through a quest line. The choice is
   permanent: there is no paid change. A player who wants another vocation plays another
   character slot. (A Soul Coins change item was considered and is leaning no.)
3. Each rank needs a player level (20, 30, 40, 50, 60) and is earned through that
   vocation's quests and tasks, not automatically. There is no separate vocation level or
   EXP.
4. Every vocation has five ranks.
5. Vocation bonuses never increase Pokémon damage, HP, Attack, Defense, Special Attack,
   Special Defense or Speed.
6. Every player keeps the normal catching, battling, breeding, healing and exploring.
7. Vocation perks never bypass PvP rules.
8. One vocation per character.
9. [Factions](#10-factions) are a separate system.

| Player level | Rank |
| --- | --- |
| 1–19 | — (regular Trainer) |
| 20–29 | 1 |
| 30–39 | 2 |
| 40–49 | 3 |
| 50–59 | 4 |
| 60+ | 5 |

Rank titles (agreed):

| Rank | Ace Trainer | Catcher | Breeder | Ranger | Angler | Medic |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | Novice Trainer | Rookie Catcher | Novice Breeder | Ranger Cadet | Novice Angler | Medic Trainee |
| 2 | Pokémon Trainer | Ball Adept | Egg Keeper | Field Ranger | Angler | Field Medic |
| 3 | Experienced Trainer | Seasoned Catcher | Skilled Breeder | Area Ranger | Skilled Angler | Senior Medic |
| 4 | Veteran Trainer | Elite Catcher | Expert Breeder | Ranger Captain | Expert Angler | Pokémon Doctor |
| 5 | Ace Trainer | Master Catcher | Master Breeder | Top Ranger | Master Angler | Chief Medic |

### The vocations

**Ace Trainer**: battles and experience. Its ranks are the Trainer titles, ending at Ace
Trainer.

| Rank | 1 | 2 | 3 | 4 | 5 |
| --- | --- | --- | --- | --- | --- |
| Pokémon EXP from battles | +2% | +4% | +6% | +8% | +10% |

No extra damage or combat stats, and no extra Trainer EXP.

**Catcher**: catching Pokémon and getting balls back.

| Rank | 1 | 2 | 3 | 4 | 5 |
| --- | --- | --- | --- | --- | --- |
| Catch chance (relative) | +2% | +4% | +6% | +8% | +10% |
| Ball recovered after a failed throw | 2% | 4% | 6% | 8% | 10% |

The catch bonus multiplies the normal chance; it does not add percentage points. A
successful catch uses the ball as usual. The Master Ball keeps its guaranteed catch.

**Breeder**: eggs, hatching and the daycare.

| Rank | 1 | 2 | 3 | 4 | 5 |
| --- | --- | --- | --- | --- | --- |
| Hatching time | -5% | -10% | -15% | -20% | -25% |
| Hatching an egg (now 60 minutes) | 57 min | 54 min | 51 min | 48 min | 45 min |
| Time until the daycare gives an egg | -5% | -10% | -15% | -20% | -25% |

Uses the existing breeding and daycare. IV, EV and nature limits do not change. Hatching
is time based: an egg in an incubator hatches after 60 minutes
(`data/lib/ps/events/actions/eggIncubator/emptyIncubator.lua`). At the top rank it takes 45
minutes (agreed), and the same percentages shorten the time until the daycare gives an egg.

How the daycare makes eggs today (`npc/scripts/daycareFemale.lua`): a female and a
compatible male train for at least 24 hours (players pick 24 or 48). When the female is
taken out, there is a chance of an egg: `eggChance` out of 300 (20 for most species, so
about 7%), plus held-item bonuses. Each failure raises the next chance, so an egg takes
about 10 tries on average (about 18 for species with chance 10). After an egg, the player
must wait 15 days before the next one. That is about 10 days for the first egg and about
25 days between eggs, which is far too long. Agreed: one egg every two weeks. Proposal: a 14-day wait per player (as today), and the
egg is guaranteed once the wait is over and the pair has trained for 24 hours, with no
extra roll. Breeder shortens the wait: rank 5 is about 10½ days. The NPC's "fifteen
days" message is hard-coded and needs updating too.

**Ranger**: tracking wild Pokémon with a radar.

| Rank | Ability | Range (proposed) | Cooldown (proposed) |
| --- | --- | --- | --- |
| 1 | Radar for nearby regular Pokémon | 30 tiles (about 2 screens) | 60 s |
| 2 | Pick a type to look for | 50 tiles | 50 s |
| 3 | See the species and direction | 80 tiles | 40 s |
| 4 | Shiny Pokémon show up | 120 tiles | 35 s |
| 5 | Legendaries and specials show up | 200 tiles (about a route or a town) | 30 s |

Only Pokémon that have actually spawned are found, including off screen. Spawns and
shiny or legendary rates do not change. To keep it balanced: a cooldown between scans,
a limited range, and one type filter at a time (agreed). The rank 5 abilities (normal,
shiny, legendary, maybe special Pokémon at a long distance) are agreed; the ranges and
cooldowns are proposed and accepted as the plan.

For scale: the map is about 5,700 by 3,400 tiles with about 19,000 spawn points, and the
screen shows about 15 by 11 tiles. Proposed limits on "too far":

- Never the whole map. Past the range, the radar shows nothing, so exploring still
  matters.
- Only the player's floor.
- Shinies, legendaries and specials show as a direction and a distance band ("far to the
  north-east") instead of an exact spot, so a Ranger can't race straight to them.
- Legendary scans get their own longer cooldown (for example 10 minutes).
- Legendaries only appear through quests and events (they are not in the map spawns), so
  legendary tracking mostly matters for event spawns.
- "Specials" still needs defining (event Pokémon, bosses?).

**Angler**: fishing. Replaces the Researcher, which is dropped.

| Rank | Title | Ability |
| --- | --- | --- |
| 1 | Novice Angler | Bonus fishing experience |
| 2 | Angler | More fishing experience; see which Pokémon can be fished at a spot |
| 3 | Skilled Angler | Faster bites |
| 4 | Expert Angler | A map of where each Pokémon can be fished |
| 5 | Master Angler | Most fishing experience and all fishing tools |

Fishing today (`data/lib/ps/systems/043-fishing.lua`): a fishing skill that rises with
use, rods that need a skill level (Old 0, Good 30, Super 50, cranes 60), and what can bite
depends on the skill and the region (Kanto, Orange Archipelago, Hoenn). "Fishing
experience" means faster fishing-skill gain. No change to what can be fished or to shiny
rates.

**Medic**: healing and support.

| Rank | 1 | 2 | 3 | 4 | 5 |
| --- | --- | --- | --- | --- | --- |
| Healing item effect | +3% | +6% | +9% | +12% | +15% |

| Situation | Medic bonus |
| --- | --- |
| Outside combat | Yes |
| Fighting wild Pokémon | Yes |
| In a duel with a player or an NPC trainer | No |

Medics may heal other players' Pokémon, but nobody who is in a duel with a player or an
NPC trainer: in practice only during fights with wild Pokémon. The PvP healing-item rules
do not change.

### Status

- **Confirmed:** permanent choice from level 20 through a quest line, ranks earned through
  quests and tasks at the required levels, no paid vocation change, no combat-stat bonuses,
  ball recovery after failed throws, the Ranger radar (regular Pokémon first, shinies and
  legendaries at higher ranks, with a cooldown, limited range and one type filter), Medics
  only heal outside duels, the Ace Trainer titles, the Angler in place of the Researcher,
  the Breeder values (hatching 45 minutes at the top rank, the same percentages for daycare
  eggs), the Angler ranks, and removing the masteries while keeping their items.
  All the rank titles are agreed, and the top Ranger rank tracks normal, shiny, legendary
  and maybe special Pokémon at a long distance.
  The Ranger radar plan (ranges, cooldowns, limits) and a two-week egg wait are agreed.
- **Proposed:** the rank levels, the other percentages, and whether the egg is
  guaranteed after the wait.

### To decide

1. What the mastery items (type plates, mastery tokens, outfits) are used for.
2. What counts as a "special" for the Ranger radar.
3. Whether the two-week egg is guaranteed or still a chance.

### The old masteries

Nine masteries from the original game (`data/lib/ps/systems/014-mastery.lua`, the
`mastery_*` NPCs and `shop_mastery.lua`). Each is tied to one or more Pokémon types:

| Mastery | Types | Perk |
| --- | --- | --- |
| Blaze | Fire | Burn damage |
| Hurricane | Flying, Dragon | Fly speed, finding without energy, evasion |
| Voltagic | Electric, Steel | Energy regeneration, paralyze duration |
| Spectrum | Ghost, Poison | Poison damage, levitate speed |
| Vital | Fighting, Normal, Fairy | Ride speed, buff duration |
| Gaia | Grass, Bug | Food regeneration |
| Avalanche | Ice, Water | Surf and dive speed, freeze chance |
| Heremit | Ground, Rock | Low-accuracy duration |
| Zen | Psychic, Dark | Blink and teleport cooldown |

- **Joining** (one per character): trainer level 85, a payment in type plates (for
  example 12 Flame Plates for Blaze) and an NPC trainer battle.
- **Ranks:** Starter plus five more. Each needs a higher level (85 up to 130), mastery
  tokens (9 up to 42) and a mastery dungeon (dungeon level 70 up to 90).
- **Bonus:** the player's Pokémon of the mastery's types get extra attack: +1, +3, +6, +12
  and +20 by rank (not in tournaments). The defense bonus is switched off in the code. The
  perk unlocks at one of the higher ranks, plus outfits and a mastery shop.

The attack bonus is a direct combat-stat boost, which goes against the new vocation rules.
Keeping the masteries would mean at least removing or replacing that bonus.

### Also planned

- The vocation quest line starts at level 20 and presents the vocations, with a
  confirmation before the permanent choice.
- Rank-up quests and tasks in the task list, and a banner at each rank-up (reusing the
  level-up banners).
- All values (levels, percentages) in one config table, so tuning is a one-line change.
- Server tests that check the bonuses never touch combat stats and never apply in PvP.
- Vocation and rank in the Discord bot's trainer lookup, and vocation pages on the website.

## 7. Pokémon storage

Pokémon storage with no practical limit, replacing the depot for Pokémon (see the
[depot overflow fix](#1-depot-overflow-fix-pokémon-are-lost-today)).

- The Redemption stash (`game_stash`) is the modern Tibia supply stash. It only holds
  stackable items, and every Pokémon ball is unique (stats, IVs, nature, moves), so it
  cannot hold Pokémon. Pokémon get their own PC storage instead: boxes in the database,
  as many as needed.
- Pokémon shown with their face icons.
- Same search and filters as the GTS: species, type, level, IVs, EVs, nature, shiny.

## 8. GTS (Global Trading System)

Replaces the player marketplace. Built on the existing market module (the legacy
`game_market`; Redemption has one too) and extended:

- Players list items and Pokémon for others to buy.
- Sort, filter and search by species, type, level, IVs, EVs, nature, shiny, price and
  seller.
- Pokémon are shown with their face icons instead of a ball.
- **Escrow:** a listed item or Pokémon leaves the seller's inventory, and comes back if the
  listing expires or is cancelled. This prevents duplicates.
- **Payment:** sales go straight to the seller's bank balance, so they work offline. The
  bank (`npc/scripts/bank.lua`, `datalog_bank_transactions`) gets an upgrade: a history
  window that shows GTS sales.
- Listing fee, a maximum number of listings per player, and an expiry time.
- Price history ("last sold for").
- Safety:
  - Pokémon in the party or on loan cannot be listed.
  - Buying needs a confirmation.
  - Every listing and sale is logged, and staff have tools to look into them.
- Optional: big sales or new listings posted to a Discord channel.

## 9. In-game wiki and tutorial

- Update the in-game wiki (`data/lib/ps/config/002-wikiChat.lua`) and the guide and
  tutorial windows (`game_guide`, `game_tutorial`).
- The in-game wiki and the website come from the same game data, so they always agree.
- The tutorial uses the new dialogue window and the waypoint trails (for example "follow
  the trail to the Pokémon Center").

## 10. Factions

Team Rocket and other factions, separate from vocations:

- any vocation can join any faction;
- players earn faction points from faction tasks, like the Pokémon Ranger tasks in the
  games, and the points raise their faction rank;
- faction reputation and ranks are separate from vocation ranks;
- faction membership does not change vocation bonuses.

## Going private

Everything is ready ([client-updates.md](client-updates.md)). Switch this repository to
private once these features are in and the game is ready to go public. PokeVerse-Clients
stays public. A private repository gets 2,000 free GitHub Actions minutes a month.
