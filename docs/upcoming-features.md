# Upcoming features

Planned work, roughly in the order it will be done. Nothing here is built yet unless it says
so. Items marked **To decide** need an answer before work starts.

## Order

1. [New depot](#1-new-depot): Poké boxes, inbox and stash.
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

Alongside, as small separate changes: the [bug fixes and small ideas](#11-bug-fixes-and-small-ideas),
the [level requirement audit](#12-level-requirement-audit) and
[switching off the old PSoul and anniversary content](#13-switch-off-the-old-psoul-and-anniversary-content),
the [economy audit](#14-economy-audit) (before the GTS), the
[daily login rewards and event calendar](#15-daily-login-rewards-and-events), [reports to Discord forums](#16-reports-and-feature-requests-to-discord-forums), and
[Android touch controls](#17-android-touch-controls).

Also open: the [Android signing key](client-updates.md#one-time-setup) (needed before
players install the APK for real), a phone UI pass, and a security check of the live
server (open ports, SSH, firewall).

## 1. New depot

A player's depot holds up to 2,000 items (`Group::getDepotLimit` in `src/group.cpp`; staff
groups have 3,000 to 5,000 in `data/XML/groups.xml`). A Pokémon caught or given as a reward
goes to the depot when the bag is full (`doCreatePokemonBall` in
`data/lib/ps/config/balls.lua`, `doPlayerEnforcePokemonLimit` in
`data/lib/ps/functions/player.lua`). These deliveries go in even past the limit, so a full
depot does not lose Pokémon (checked in the code; see below). An over-limit depot only
stops the player from putting more items in by hand.

### Audit: PokeVerse depot today

- One depot (number 0) shared by every Pokémon Center: a depot locker that holds a depot
  chest (item 2594); everything else is normal containers inside it.
- `doPlayerAddDepotItem` (`src/luascript.cpp`) moves the item with `FLAG_NOLIMIT`, which
  skips both the depot limit (`Depot::__queryAdd` in `src/depot.cpp`) and the full
  container check (`Container::__queryAdd` and `__queryMaxCount` in `src/container.cpp`).
  So deliveries never fail because the depot is full. The `Can't send to depot` log line
  is only reached for other errors (no player, no item).
- Each Pokémon ball counts as one item, the same as a potion or a stone.
- The code already warns that lowering the limit makes items disappear
  (`group.cpp`: "THIS IS VERY DANGEROUS, ITEMS CAN DISAPPEAR").
- Used by NPC battles, Rocket battles, the Frontier Island arenas, the Pokémon market and
  PokéTrader NPCs, and surprise boxes.

### Audit: the Redemption depot

Only the Redemption client is in this repository (`references/otclient-redemption`); its
server (Canary) is not, so this part comes from the client code plus how Canary works.

- **Depot locker** with four parts:
  - **Depot chest** with numbered depot boxes for sorting.
  - **Inbox:** mail, store purchases and returned market items arrive here. It is not
    limited by the depot limit, so a delivery never fails.
  - **Supply stash:** stackable items kept as "item and count" in their own table, not as
    items in a container. The client window is `modules/game_stash`, with categories,
    search and sorting.
  - **Reward chest:** boss loot.
- **Depot limit:** applies to the depot chest only; free and premium accounts have
  different limits.
- **Depot search:** search every item in the depot by name and take it out
  (`parseCloseDepotSearch` and the related messages in `src/client/protocolgameparse.cpp`).
- These are newer Tibia protocol messages. The PokeVerse server speaks the old protocol,
  so none of them work as they are. Using them would mean new server code, or sending the
  data over our own extended messages (like the Tasks window does) and reusing the
  client windows.

### The new depot (agreed): Redemption's depot, redesigned for Pokémon

The depot is already one depot shared by every Pokémon Center, so it can be opened
anywhere (like the PC in the games); the new depot stays shared. All five parts, built on our own extended messages (JSON, like the Tasks window) and
reusing the Redemption client windows where they exist.

1. **Inbox:** deliveries arrive here: mail (items and Pokémon mailed to the player),
   items that don't fit in the bag, rewards, and later GTS purchases (items and Pokémon)
   and returned listings. Caught Pokémon never go to the inbox (agreed). No limit, so a delivery
   never fails. The player takes things out from there.
2. **Poké boxes** (the numbered depot boxes): they only hold Pokémon balls.
   - Caught Pokémon that don't fit in the party go straight to the Poké boxes (agreed),
     and so do Pokémon moved out by the party limit.
   - Each box holds 30 Pokémon (agreed), and boxes fill in order: when Box 1 is full, the next Pokémon goes into Box 2, and so on. A new empty
     box appears when the last one fills.
   - At most 40 boxes, so 1,200 Pokémon, the same for everyone (agreed to leave the
     number to us; the games have 32 boxes). When every box is full, throwing a ball is
     refused with "Your Poké boxes are full", so a caught Pokémon is never lost; anything
     else (a reward or the party limit) goes to the inbox as a last resort.
   - Each box uses the current depot box sprite with its number added (Box 1, Box 2...).
   - Boxes can be renamed ("Box 1" by default), and Pokémon can be dragged between boxes
     and the party.
   - Pokémon are shown with their face icons, with sorting, search and filters (species,
     type, level, IVs, EVs, nature, shiny), the same as the GTS.
   - The balls stay real items, so every Pokémon keeps all its details (stats, IVs,
     nature, moves) with no change to how they are saved. They don't count toward the
     depot limit.
3. **Supply stash:** every stackable item (balls, potions, stones, berries, food,
   vitamins...) and every item that doesn't stack but has nothing of its own, like Tibia
   equipment, as item and count, in its own table (`player_stash`). Held items go here
   (agreed): they don't stack, but their level and experience are saved on the Pokémon's
   ball, not on the item (`046-heldItem.lua`). Items with their own details can't, the same
   as imbued items in Tibia: an elemental stone with its slots set stays in the depot chest. It takes no depot
   space. "Stow" from the bag or depot, take out any amount. Redemption's `game_stash`
   window (search, sorting, categories) is reused, with PokeVerse categories instead of
   Tibia ones.
4. **Depot chest:** what's left (items with their own details, such as written letters
   or elemental stones with slots set), with the normal limit.
5. **Reward chest:** boss and event loot, for each player who took part, so loot is
   never lost to a full bag.
6. **Depot search:** one search box across the Poké boxes, stash, depot chest and inbox;
   Pokémon by species, type or stats, items by name; take the result straight to the bag.

**Only Pokémon are moved for the player (agreed).** Loot from defeated Pokémon never goes
to the depot, the inbox or the stash: when the bag is full, the player can't loot and the
loot stays in the corpse. Auto loot already works this way (`src/monster.cpp`: it stops
and says "Loot not collected! Check your backpack.").

**Moving existing depots:** at a player's first login after the update, the Pokémon in
their depot move into Poké boxes and the stackable items into the stash; the rest stays.
Logged, so it can be checked.

**Order:** the inbox, Poké boxes, stash, depot search, and the reward chest
when bosses or raids need it.

**To decide:**

- Whether Premium gets anything extra (for example box wallpapers or names), never more
  safety.

- To be sure, search the live server logs for `Can't send to depot`.
- Raising the depot limit for everyone is not a fix on its own: it moves the problem, and
  every depot item is saved again on each save.

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
refunding. The mastery items (type plates, mastery tokens, outfits) stay in the game. Ideas (not
decided): give the outfits to the vocations (for example as rank rewards), and use the type
plates and tokens as rank-up quest costs or for crafting.

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
| Chance of a second daycare egg | 2% | 4% | 6% | 8% | 10% |
| Daily early egg chance (others: 10%) | 11% | 12% | 13% | 14% | 15% |

**Premium (agreed):** Breeder can be chosen by everyone and its perks never pause. The
daycare stays Premium, so the daycare perks (second egg, early egg chance) apply while the
player has Premium; faster hatching always works, for every egg (eggs can also be bought).
When Premium runs out, Pokémon in the daycare and eggs in incubators can still be
collected.

Uses the existing breeding and daycare. IV, EV and nature limits do not change. Hatching
is time based: an egg in an incubator hatches after 60 minutes
(`data/lib/ps/events/actions/eggIncubator/emptyIncubator.lua`). At the top rank it takes 45
minutes (agreed). The daycare wait is the same for everyone; Breeder adds a chance of a
second egg and a better daily early egg chance (agreed).

How the daycare makes eggs today (`npc/scripts/daycareFemale.lua`): a female and a
compatible male train for at least 24 hours (players pick 24 or 48). When the female is
taken out, there is a chance of an egg: `eggChance` out of 300 (20 for most species, so
about 7%), plus held-item bonuses. Each failure raises the next chance, so an egg takes
about 10 tries on average (about 18 for species with chance 10). After an egg, the player
must wait 15 days before the next one. That is about 10 days for the first egg and about
25 days between eggs, which is far too long. Agreed for everyone: the egg is guaranteed after 14 days (per player, the pair must have
trained for 24 hours), with a chance of getting it sooner. Early chance (agreed): from day 7,
one roll a day at 10%, so about half of players get their egg before day 14. Breeders
roll 11–15% by rank, so at the top rank about two thirds get it early. The NPC's "fifteen
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
- Specials are event Pokémon, such as Christmas Pikachu (agreed).

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
  The egg is guaranteed at 14 days with a chance to come sooner; Breeder gets a chance of a
  second egg.
  The early egg chance is from day 7 at 10% a day, and Breeders get 11–15%.
  Ranger specials are event Pokémon, such as Christmas Pikachu.
- **Proposed:** the rank levels and the other percentages.

### To decide

1. What the mastery items are used for. Ideas: outfits as vocation rewards, plates and
   tokens for rank-ups or crafting.

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

Now part of the [new depot](#the-new-depot-agreed-redemptions-depot-redesigned-for-pokémon):
the Poké boxes. The GTS uses the same search and filters.

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

## 11. Bug fixes and small ideas

From the `#notes` channel:

- **Look text for field moves:** looking at an object a field move works on says so, for
  example "You see a stone. It looks like it can be smashed." for the Rock Smash stone
  (item 1285), and the same for Cut, Strength and the others.
- **Battle list:** a Pokémon's level does not update until one of the filters is clicked.
- **WASD double step:** walking with WASD sometimes moves two tiles instead of one; the
  arrow keys do not. Cause unknown.
- **Switching Pokémon:** the player is invulnerable for 0.5 seconds after switching.
- **Bugged stairs:** going down some stairs works but lags or disconnects the player. Known:
  the stone stairway (item 3220) at 3295, 252, 7, and the stairs at 3853, 813, 7. Check
  for more.
- **Gym leaders** say how many of the gym's trainers are left to beat before the player
  can challenge them.
- **Hunting tasks get a time limit** (`data/lib/ps/systems/064-huntingTasks.lua`): a hunt
  not finished in time fails on its own and is removed. **To decide:** how long (for
  example by size), and whether a failed hunt costs anything.

- **Fishing tasks don't count up (fixed):** the server runs actions, creature events and
  talk commands in separate Lua environments, and each kept its own copy of the task
  board. The Tasks window picks tasks through a talk command, so fishing, wild defeats and
  NPC trainer wins (creature events) kept counting on the copy loaded at login, which had
  no tasks yet, until the next login. The boards are now read from the database every
  time, and the server test picks tasks and hooks Pokémon in one session.

The missing clickable responses (gym leaders and others) are part of the
[NPC dialogue](#3-npc-dialogue-quests-and-tasks) work, and more Pokémon boxes are part of
[Pokémon storage](#7-pokémon-storage).

### Pokémon energy

Energy works today, but only for the player's Pokémon: it is the trainer's mana
(`getPokemonEnergy` in `data/lib/ps/functions/pokemon.lua`). Most species start at 100 energy
(200 for shinies) plus 10 per level, and it refills 1 per second (`XML/vocations.xml`).
Moves cost 40 to 120, most often 100 (`requiredEnergy` in `config/moves`); not enough
energy blocks the move (`003-skill.lua`). Wild and NPC trainer Pokémon have no energy,
only move cooldowns.

- **Show it clearly (agreed):** the client shows energy as the blue mana bar, which
  doesn't say it belongs to the Pokémon. Show it as an energy bar right under the
  Pokémon's health bar, show each move's cost on the move bar, and grey out moves it can't afford.
- **Balance:** at level 50 a Pokémon has about 600 energy and gets 60 back a minute, so
  energy may rarely run out. Check it in the [economy audit](#14-economy-audit) together
  with energy potions and food.
- **Who has energy (agreed):** players only. Wild and NPC trainer Pokémon keep just
  cooldowns: energy would make them stop attacking and easier to beat, and they would
  need an AI that manages it.

## 12. Level requirement audit

Every player level requirement found in the server code (October 2026). The first six rows
are changed to the new level (agreed); the rest are kept.

| Feature | Before | Where | Now |
| --- | --- | --- | --- |
| Buy a house | 50 | `levelToBuyHouse`, `config.lua` | 25 |
| Safari Zone | 30 | `npc/scripts/saffariZoneEnter.lua` | 15 |
| Daycare (both NPCs) | 85 and Premium | `npc/scripts/daycareFemale.lua`, `daycareMale.lua` | 20, the Breeder level; still Premium |
| Form a guild | 40 | `levelToFormGuild`, `config.lua` | 30 |
| Slot machine | 50 | `lib/ps/systems/044-slotMachine.lua` | 15 |
| Frontier Island arenas (gladiator, cooperative, survive) | 50 | `npc/scripts/fi_stadiumarena.lua` | keep |
| Wave arena | 20 | `npc/scripts/wavearena.lua` | keep |
| Elite Four | 95 | `lib/ps/systems/049-eliteFour.lua` | keep, or 80 if the badges already gate it |
| Tournaments | by Pokémon level (0–100, 20–40, 41–50, 45–100, 50–100, 51–65, 66–80, 80–100); trainer level at least the minimum − 5 | `XML/tournaments.xml`, `npc/scripts/tournament.lua` | keep |
| Daily and weekly tasks | Beginner 1, Easy 15, Medium 35, Hard 55, Extreme 80; two task kinds need 10 | `lib/ps/systems/062-dailyTasks.lua` | keep |
| Ranger Club ranks | Rookie 10, Mentor 25, Coordinator 50, Coach 75 | `lib/ps/config/001-rangerClub.lua` | keep (becomes [factions](#10-factions)) |
| Referral reward | the friend reaches 50 | `lib/ps/systems/035-referral.lua` | 30 |
| Quests | 258 have no level; the rest 10–100, with 76 at level 70 | `lib/ps/config/003-quest.lua` | check the level 70 group |
| Professor Josh Rock and William Rock quests | 80 | `npc/scripts/quest_*Rock.lua` | keep |
| Masteries | 85–130 | `lib/ps/systems/014-mastery.lua` | removed with the [vocations](#6-vocations) |
| Calling a Pokémon | its level at most the trainer's level + 10 | `MAX_LEVEL_DIFF_BETWEEN_PLAYER_POKEMON`, `others/constants.lua` | keep |
| Level doors on the map | the door's action id − 1000 | `movements/scripts/tiles.lua` | list them from the map |
| Experience loss on death | from level 20 | `deathProtection`, `config.lua` | keep |
| Gym leaders | none (`NpcBattle:setRequiredLevel` is never used) | `lib/ps/systems/001-npcBattle.lua` | keep |

Not requirements, but level based: the tutorial sends players on from level 10
(`activationTile.lua`), and the wiki channel opens at login below level 30 (`login.lua`).

The house and guild texts in the in-game wiki (`002-wikiChat.lua`) say the new levels too.

**Unlock ladder (agreed)**, so something new opens every few levels instead of everything
at 20:

| Level | Unlocks |
| --- | --- |
| 10 | End of the tutorial, Ranger Club Rookie, two task kinds |
| 15 | Safari Zone, slot machine, Easy tasks |
| 20 | Vocation quest, daycare, wave arena |
| 25 | Houses, Ranger Club Mentor |
| 30 | Guilds, referral reward |
| 35 | Medium tasks |
| 50 | Frontier Island arenas, Ranger Club Coordinator |
| 55 | Hard tasks |
| 75 | Ranger Club Coach |
| 80 | Extreme tasks, the Josh Rock and William Rock quests |
| 95 | Elite Four |

Planned: the level-up banner lists what just unlocked ("Level 25: you can now buy a
house").

**To decide:** whether the daycare stays Premium (it is today), whether the Elite Four
moves to 80, and what the level 70 quest group is (76 quests at the same level).

## 13. Switch off the old PSoul and anniversary content

Switch off, but keep, the content left from PSoul (the original game) so it can be reused
for PokeVerse later. Do not delete it.

- **PSoul:** about 18 files mention it, including quests (`quests.xml`, the
  `quest_chief*` and `quest_prophetSlowking` NPCs, `legendaryChest.lua`), achievements,
  Pokémon addons, the Logan NPC, and a psoul.net link in the welcome message
  (`creaturescripts/scripts/login.lua`).
- **Anniversary and birthday events:** about 38 files, including the global event
  (`globalevents/scripts/start.lua`, `lib/ps/events/globalevents/anniversary.lua`), the
  cake monsters (`monster/Events/Anniversary`), the surprise bag, the magic flame, and the
  `event_anniversary` and `event_birthday` NPCs.
- Switch them off in one place where possible (a config flag), so turning them back on is
  easy.

## 14. Economy audit

Check that money and rewards are balanced against each other, and fix what is too high or
too low.

- Every way money and items come in: task and hunting rewards (the biggest worry), daily
  tasks, quests, selling items to NPCs, drops, and later GTS sales.
- Every way money goes out: NPC shops, healing, travel, refreshing the hunting offers,
  houses, and later the GTS fees.
- Compare them per hour of play at each level range, write the numbers in one table, and
  balance from there.
- Keep all reward values in config tables, so tuning is easy.
- Track it over time: total money on the server (bank plus inventories), shown by a staff
  command or the Discord bot.

### Findings (October 2026, read only)

The first pass read every NPC shop (144 NPCs, 227 items for sale, 582 items they buy), the
wild Pokémon loot tables, the task boards and the fixed prices in the NPC scripts. Nothing
is changed yet.

**Money coming in**

| Source | Amount | Where |
| --- | --- | --- |
| Loot sold to NPCs | about $27 a kill for a typical wild Pokémon, $70 for the best common ones (Alakazam, Jynx, Tentacruel, Houndoom) | `monster/Pokemons`, NPC `shop_sellable` lists |
| Hunting tasks | $10 + $2 × the species' level per kill, + up to 30% by rank: a Small hunt (100 kills) of a level 30 species pays about $7,000 | `moneyFor`, `064-huntingTasks.lua` |
| Daily tasks (3 tasks + the all-done bonus) | Beginner about $3,200, Hard $19,500, Extreme $48,000 a day | `TASK_DIFFICULTIES`, `062-dailyTasks.lua` |
| Weekly tasks (5 tasks + bonus) | Beginner about $18,000, Hard $110,000, Extreme $270,000 a week | the same table, money × 4 |
| Selling Pokémon to the NPC | catch difficulty × $10 (× 2 for shinies) + $5 a level | `getPokemonPrice`, `npc/scripts/shop_pokemonShop.lua` |

**Money going out**

| Sink | Price | Where |
| --- | --- | --- |
| Poké, Great and Ultra Balls | $8, $35, $130 | Poké Mart NPCs |
| Potions and revives | $10 to $130, revive $200 | Poké Mart NPCs |
| Houses (Premium only) | $50 a tile (median house $3,900, largest $39,250), and the same again as rent every 30 days (`housePriceAsRent`), from the bank, else the depot; 7 daily warnings, then the house is lost | `housePriceEachSquare`, `houseRentPeriod`, `config.lua`; `Houses::payRent`, `src/house.cpp` |
| Daycare | $1 to $4 a minute by level, + $100 | `getPricePerMinute`, `daycareMale.lua` |
| Travel | $50 to $300 a trip | captain NPCs (`travel_destinations`) |
| Safari Zone | $1,000 | `saffariZoneEnter.lua` |
| Slot machine | $100 a spin, at most 90 a day; pays casino coins, not money | `044-slotMachine.lua` |
| Late game buys | berry pot $150,000; egg move remover $100,000; Bill's assistant quest $100,000; ball pillar $100,000; destiny knot $50,000; power items $25,000; egg move regenerator $25,000 | NPC shops and scripts |

**What looks wrong**

1. **The task boards pay far more than anything else.** A trainer on Extreme gets about
   $600,000 a week from daily and weekly tasks, while the most expensive things to buy
   cost $150,000 once. Hunting tasks pay about 2.5 times the loot of the same kills. Once a
   trainer owns the late game items, money only piles up (inflation). Lower the top two
   difficulties, or add money sinks that repeat.
2. **Houses are cheap.** A median house, and its monthly rent, is about one Beginner day
   of tasks. Raise `housePriceEachSquare`, which sets both, or make the rent weekly.
3. **Rare candy comes from the boards every week** (Extreme gives one a day plus three a
   week, Hard one a week). Check it against how fast levelling is meant to be.
4. **Few repeating sinks.** Balls, potions, travel and the house rent are small. Ideas: the
   GTS fee, a higher rent, paid hunting refreshes (they exist: $1,000 to $20,000), cosmetic shops.

**Checked and fine**

- No money loop between NPCs: no NPC buys an item for more than another sells it, and
  prices for the same item agree across NPCs (except brass legs, see below).
- Catching and selling Pokémon pays about double the Poké Balls used (one ball a kill), on
  top of the loot. It is a fair income, not an exploit.
- Soya buys old Tibia equipment for up to $400,000 (steel boots) and $20,000 for brass
  legs, against $100 elsewhere, but Soya is not on the map and no monster drops those
  items. Remove Soya or keep it off the map.

### First tuning (done)

| What | Before | Now |
| --- | --- | --- |
| Daily task money (Beginner to Extreme) | 400, 700, 1,000, 2,500, 6,000 | 300, 500, 800, 1,500, 2,500 |
| Daily bonus money | 2,000, 3,500, 5,000, 12,000, 30,000 | 1,000, 1,500, 2,500, 5,000, 8,000 |
| Weekly bonus money | 10,000, 16,000, 25,000, 60,000, 150,000 | 5,000, 8,000, 12,000, 25,000, 50,000 |
| Weekly task money | 4 × a daily task | 3 × |
| Reroll cost, Hard and Extreme | 2,000 and 5,000 | 1,500 and 2,500 (one task's money) |
| Hunting money per kill | $10 + $2 × the species' level | $5 + $1 × the level |
| A week of tasks (Beginner / Hard / Extreme) | $40,400 / $246,500 / $606,000 | $22,800 / $114,000 / $196,000 |
| Rare candy | Extreme daily bonus and task items, Hard weekly 1, Extreme weekly 3, shop 80 points | all daily tasks done 7 days in a row (repeats), Extreme weekly 1, shop 250 points |
| House rent | the price every 30 days | the price every week (`houseRentPeriod`), still from the bank first |

Boards already rolled keep their rewards; new ones use these values.

**Next:** decide the target income per hour for each level range, then tune again from
play data. Pokémon energy balance (see [energy](#pokémon-energy)) is still to check.

## 15. Daily login rewards and events

- **Daily login reward:** a 7-day streak that repeats (agreed): a reward for each day in a
  row, a bigger one on day 7, then it starts again at day 1. A missed day resets the
  streak. The values
  come from the [economy audit](#14-economy-audit).
- **Event calendar:** one calendar that shows the upcoming events (double EXP, double
  shiny, holiday events, tournaments): in a game window, on the website, and posted by
  the Discord bot. Staff add events with a date, time and length, and they start and
  stop on their own.
- **Double EXP:** already exists. `/doubleexp 2h` starts 2x for 2 hours, and
  `/doubleexp 5x 1d` starts 5x for a day: any multiplier above 1x up to 10x, from 1 minute
  to 7 days; `/doubleexp off` and `/doubleexp status` too
  (`data/lib/ps/systems/058-serverExpEvent.lua`).
- **Double shiny:** new, built the same way: `/doubleshiny 2x 2h` up to 10x. Shiny chance
  is 1 in 8,192 (`shinyAppearChance` in `config.lua`). Map spawns roll it in the C++ code
  (`src/spawn.cpp`), and fishing, headbutt, eggs and abilities roll it in Lua, each
  reading the value once at start. All of them must use the event multiplier, so it needs
  a server build.
- Both events are announced in game and on Discord, and show on the calendar.

## 16. Reports and feature requests to Discord forums

An in-game window to send a bug report, a feature request or a player report. Each one
becomes a post in a Discord forum channel, with tags.

- **Today:** the client's bug report (`onReportBug`,
  `data/lib/ps/events/creaturescripts/onReportBug.lua`) only writes to a log file on the
  server, together with the player's IP address. Nobody sees it unless they read the file.
- **In-game window:** pick the kind (bug, feature request, player report), a category
  (for example client, map, NPC or quest, Pokémon or moves, tasks, economy, other), a
  title and a description.
- **Sent along automatically:** character name, position, client version and platform
  (Windows, Linux, Android), and the Pokémon out. Never the IP address.
- **Discord:** the game sends a new `report` event over the [Discord bridge](discord-bridge.md);
  the [PokeVerse-Discord](https://github.com/GIToez/PokeVerse-Discord) bot creates the forum
  post and applies the tags (kind, category, platform). Bugs and feature requests go to
  public forums, player reports to a staff-only forum.
- **Discord setup (agreed):** the bot creates the forum channels and their tags itself
  when they don't exist yet, so no manual setup is needed.
- **Ticket system in game (agreed):** reports are stored as tickets in the database
  instead of a log file. Staff (GM and above) open a ticket window in game: list, filter
  by kind, category and status, read the details, jump to the reported position, add a
  note, and set the status: Open, Confirmed, Accepted, Fixed, Added, Won't do, Duplicate.
- **Statuses stay in sync:** a status set in game updates the Discord post's tags (and
  posts the note), and a tag changed on Discord updates the ticket. The player gets an
  in-game message (or mail, if offline) when the status of their report changes, and a
  Discord ping too if they linked their Discord account ([account linking](discord-bridge.md#account-linking))
  (agreed).
- **My reports (agreed):** players see their own tickets and each one's status in game.
- **Voting (agreed):** players vote on feature requests with a reaction on the Discord
  post. The vote count shows on the ticket in game, and staff can sort by it.
- **Limits:** a few reports per player per hour, and a minimum length, against spam.

## 17. Android touch controls

Today a long press (over 0.5 s) already works as a right
click and opens the menu (`src/framework/platform/androidwindow.cpp`). A tap only does
something with one of the shortcut buttons (look, use, attack, follow) selected, or walks;
on phones the client skips the smart left click (`processMouseAction` in
`modules/game_interface/gameinterface.lua`).

- **Tap = smart left click (agreed idea):** talk to an NPC, attack a Pokémon, use an
  object, or walk there, the same as smart left click on the computer.
- **Long press = right click:** keep it, with a small vibration or circle so the player
  knows the menu is coming. Double tap is not recommended: every single tap would have to
  wait to see if a second one follows, so walking and attacking would feel slow.
- The shortcut buttons keep working for look and follow.
- Then a phone UI pass: button sizes, the joystick, and windows that don't fit the
  screen.

## Going private

Everything is ready ([client-updates.md](client-updates.md)). Switch this repository to
private once these features are in and the game is ready to go public. PokeVerse-Clients
stays public. A private repository gets 2,000 free GitHub Actions minutes a month.
