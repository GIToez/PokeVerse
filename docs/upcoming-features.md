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

All the old vocations go: the "Trainer" entries and the nine element masteries (Blaze,
Hurricane, Voltagic, Spectrum, Vital, Gaia, Avalanche, Heremit, Zen) in
`data/XML/vocations.xml` and `data/lib/ps/systems/014-mastery.lua`.

### Rules

1. Players begin as regular Trainers.
2. At player level 20 they choose one vocation. The choice is permanent.
3. Ranks unlock automatically with player level: 20, 30, 40, 50 and 60. There is no
   separate vocation level or EXP.
4. Every vocation has five ranks.
5. Vocation bonuses never increase Pokémon damage, HP, Attack, Defense, Special Attack,
   Special Defense or Speed.
6. Every player keeps the normal catching, battling, breeding, healing and exploring.
7. Vocation perks never bypass PvP rules.
8. One vocation per character.
9. [Factions](#10-factions) are a separate system.

| Player level | Rank | Title (placeholder) |
| --- | --- | --- |
| 1–19 | — | Regular Trainer |
| 20–29 | 1 | Novice |
| 30–39 | 2 | Intermediate |
| 40–49 | 3 | Advanced |
| 50–59 | 4 | Expert |
| 60+ | 5 | Master |

### The six vocations

**Ace Trainer**: battles and experience.

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
| Hatching speed | +3% | +6% | +9% | +12% | +15% |
| Daycare efficiency | +2% | +4% | +6% | +8% | +10% |

Uses the existing breeding and daycare. IV, EV and nature limits do not change.

**Ranger**: tracking wild Pokémon.

| Rank | Ability |
| --- | --- |
| 1 | Detect nearby spawned Pokémon |
| 2 | Longer tracking range |
| 3 | See the species and direction |
| 4 | Filter tracking by species |
| 5 | Longest range and advanced filters |

Only Pokémon that have actually spawned are found, including off screen. Spawns and
shiny or legendary rates do not change.

**Researcher**: Pokédex knowledge and analysis.

| Rank | Ability |
| --- | --- |
| 1 | Basic Pokémon research |
| 2 | Advanced species information |
| 3 | IV analysis and research rewards |
| 4 | Expanded Pokédex research |
| 5 | All research tools and rewards |

No changes to IVs, EVs or base stats and no combat bonus. Every player can still see the
IVs and EVs of their own Pokémon.

**Medic**: healing and support.

| Rank | 1 | 2 | 3 | 4 | 5 |
| --- | --- | --- | --- | --- | --- |
| Healing item effect | +3% | +6% | +9% | +12% | +15% |

| Situation | Medic bonus |
| --- | --- |
| Outside combat | Yes |
| PvE combat | Yes |
| PvP combat | No |

Healing items work in PvE. Medics may heal other players' Pokémon where target healing
supports it. The PvP healing-item rules do not change.

### Status

- **Confirmed:** permanent choice at level 20, ranks from player level, no combat-stat
  bonuses, ball recovery after failed throws, Ranger tracking, and Medic bonuses in PvE
  but not PvP.
- **Proposed:** the rank levels, the percentages, the Breeder values, and the details of
  the Ranger and Researcher ranks.
- **Rank titles:** Novice to Master are placeholders. The earlier Trainer titles were
  Novice Trainer, Pokémon Trainer, Experienced Trainer, Veteran Trainer and Ace Trainer.
  Each vocation's titles are still to be chosen.

### To decide

1. The masteries: the spec also says "the nine-category mastery progression stays
   independent", which conflicts with removing all the old vocations. Do the masteries go,
   or stay as their own system?
2. "Ace Trainer" is both a vocation and the old rank-5 Trainer title. Rename one.
3. Characters that already have a mastery vocation go back to Trainer. Are the stones and
   tokens they spent refunded?
4. Is there a rare paid item to change vocation after a wrong pick?
5. Can Rangers track shinies and legendaries, or only regular spawns?
6. What are the Researcher rewards (for example items for Pokédex entries, or research
   tasks)?
7. What counts as "in PvP combat" for the Medic (for example X seconds after attacking or
   being attacked by a player)?
8. Is hatching based on steps or time, and what does "daycare efficiency" improve (leveling
   speed, cost, results)?

### Also planned

- At level 20, a window or NPC presents the six vocations with a confirmation step.
- A banner at each rank-up (reusing the level-up banners).
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
- faction reputation and ranks are separate from vocation ranks;
- faction membership does not change vocation bonuses.

Possibly faction quests and rewards.

## Going private

Everything is ready ([client-updates.md](client-updates.md)). Switch this repository to
private once these features are in and the game is ready to go public. PokeVerse-Clients
stays public. A private repository gets 2,000 free GitHub Actions minutes a month.
