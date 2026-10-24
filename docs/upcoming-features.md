# Upcoming features

Planned work, roughly in the order it will be done. Nothing here is built yet unless it says
so. Items marked **To decide** need an answer before work starts.

## Order

**Built:**

- [New depot](#1-new-depot) and [Pokémon storage](#7-pokémon-storage): the PC with Poké
  boxes, stash, inbox, depot and search, opened from every locker.
- [Auto-walk and world map](#2-auto-walk-and-world-map): the auto-walk fix and the
  Pokepedia (map, houses, Pokédex knowledge levels, items, waypoints, routes, tracker).
- [GTS](#8-gts-global-trading-system).
- [Website](#4-website): home, downloads, Pokédex and moves pages, Discord button (not the live
  status or the Discord card yet).
- Most of the [bug fixes and small ideas](#11-bug-fixes-and-small-ideas), including the
  energy bar.
- The [level requirement audit](#12-level-requirement-audit) and the unlock ladder.
- The first [economy](#14-economy-audit) tuning.
- The [daily login reward](#15-daily-login-rewards-and-events) (7-day streak).
- [Android](#17-android-touch-controls): a tap works as smart left click.
- Not in this plan before: the Tasks window redesign, gym leader duels with banners, the
  Redemption login and character screens.
- The [in-game wiki](#9-in-game-wiki-and-tutorial): a Wiki tab in the Pokepedia, checked
  against the code, in place of the Wiki Chat channel.
- The Pokepedia's [real world map](#real-world-map-built), drawn from the game's sprites and
  updated by each client release, with a list of regions to keep hidden until they launch.
- Houses tab pictures of each house and floor, the Houses and Places lists grouped by region and
  then town, and filters by region, kind of place, for sale and size.
- Pokemon [minimap marks](#minimap-marks-built) in place of Tibia's flags.
- The new top menu bar (grouped icons, Store button) and one hotkey system for items and moves.
- [Slot machine and world boss fixes](#11-bug-fixes-and-small-ideas).
- [Vocations](#6-vocations): six to choose from at level 20, five ranks with rank-up trials,
  vocation outfits and the Rookie starter, the Ranger radar and the Angler Fishing Guide.
- The NPC dialogue window, the 1634 rewritten NPC lines, the quest log, quest notices, NPC role
  badges and chat portraits for the famous NPCs ([section 3](#3-npc-dialogue-quests-and-tasks)).
- The Trainer Card (also in Discord's /trainer), the Day Care window, held items given by
  dragging, and the Pokemon Trade window (sell Pokemon to Ron and Joel Morris).
- The [event calendar](#15-daily-login-rewards-and-events) with holidays, seasons and weather,
  rotating server events, seasonal decorations (automatic and placed by hand) and wild
  legendaries (work in progress).
- The Admin window for all staff, and event boosts up to 10x for 7 days.
- Visual styles (Off, Vibrant, Toon), shiny and status effects on Pokemon, and the Union Room
  plaza.
- Johto, still being built: air and sea travel, the Magnet Train, signs, the region fence and
  Zephyr Gym.
- Keys: M the Pokepedia map, P the Trainer Card, C the calendar. First-visit hints (Pokemon
  Center, Mart, Day Care and more) with a Settings switch and a wiki page.
- The anniversary cake town only opens during the Anniversary (staff test it with
  `/anniversary show`), and the Troca chat channel is now Trade.
- Crash fixes on Windows (the shader list, Lua errors inside C++) and saved crash reports.
- The old client's red ring under the target again (or a Poke Ball ring, or Tibia's square),
  Poke Ball corners for the mouse-over crosshair, both in Options > Interface.
- Names on the Pokepedia map by zoom (regions, cities, routes, landmarks) with an Aa toggle,
  and the Places list grouped by region with routes, landmarks and a region filter.
- [Accounts, login security and the Store](#19-accounts-soul-coins-and-the-store): signup
  email codes, Forgot password, the Account window (with Link Discord and Join Discord),
  PBKDF2 passwords, account lockout, the PokeVerse login key, and the Store in place of the
  Soul Coin NPCs.
- The Poke Mart and Bank windows ([modernization audit](modernization-audit.md)).
- The battle list sorts by level, keeps your own Pokemon first and the radar's target second;
  the Pokédex Details tab; Pokemon mouse cursors; the gold Premium badge in the Pokepedia;
  held item icons that no longer flicker.
- Android: the map keeps 23x13 tiles and the game stays in landscape; the APK is signed with
  the release key.
- Stage 1 of the [legendary revamp](#22-legendary-revamp-stages-1-to-3-built): habitats in all four
  regions, a way of moving per species, the sets, trails of signs, Mew's disguise, Mewtwo's
  warning, the sleeping Regis, the radar by rank, and the new Admin Events tab. Stages 2 and 3:
  flights and dives drawn on the client, Jirachi's meteor shower, Deoxys's impact, Rayquaza's
  event and the clash weather.

**Next, in order (agreed October 15):**

1. **Updater** (built): four files at a time, written to disk every 25 so an interrupted
   update resumes, "File X of N, MB left" and the speed; the client's own files come last.
   On Android the game keeps running in the background with a notification ("PokeVerse is
   updating in the background", or still connected while logged in). No "update the client
   first" step. The map pictures stay as they are.
2. **NPC fixes** (built) from the [NPC audit](npc-audit.md): the shared code (battles, travel, quests,
   Ranger Club, bank), greetings that hide what the NPC answers to, and missing {yes}/{no}.
   NPCs that only have one line are their own category, not a problem.
3. **[NPC dialogue window](#3-npc-dialogue-quests-and-tasks)** (built): portrait (the leaders',
   Oak's and Red's portraits; everyone without one shows their outfit, no new portraits are
   made), the blue words as buttons, big Yes/No for questions. The NPCs tab stays as it is: it
   still opens when an NPC talks, keeps the history, and is where answers are typed.
4. **Mission notices** (built, see [the quest log](#quest-log-notices-and-npc-icons)):
   a banner when a quest starts or is done, a small card for progress and when the goal is
   reached.
5. **NPC role icons** (built): quest, battle, shop, travel, bank, healing and daycare, from
   what each NPC really does; NPCs with several rotate them. The quest icon is per player:
   it only shows when that player has a quest they can start or hand in there (level,
   earlier quests and cooldown checked by the server). Needs the new client build.
6. The NPCs with their own scripts, town by town.
7. [Vocations](#6-vocations) (built).
8. The [in-game wiki and tutorial](#9-in-game-wiki-and-tutorial) for the new dialogue.
9. [Factions](#10-factions).
10. The [modernization audit](modernization-audit.md): the old keyword systems get windows,
    in its ranked order (Poke Mart, bank, travel picker and the rest; Nurse Joy needs no menu).
    - **Poke Mart window first (built, PR #161).** {trade} at the 158 shop NPCs opens it on
      the Redemption client; older clients keep Tibia's trade window, renamed to Dollars. The window is
      in the Sell Shop's style: item tiles by category (Balls, Potions, Revives, Tools), a
      quantity stepper with x1/x10/x100, the total and your money, and a cart to buy several
      items at once ([details](modernization-audit.md#1-poke-mart-buy-window)). The server
      checks money and bag space for the whole cart first. A Sell tab keeps **Sell all**
      (mostly for monster drops): it lists what the NPC buys from your bag, shows the count
      and total, and a **Keep** tick on each item leaves it out (remembered per NPC); a
      row still sells just that item. Selling Pokemon stays in the Sell Shop. On Android
      the tiles are bigger and the cart slides up from the bottom. Its tiles, categories,
      quantities and cart are what the
      [Store](#19-accounts-soul-coins-and-the-store) needs too, so the Mart comes before
      the Store and the Store reuses them.
    - **Bank window (built, added October 21).** Greeting any of the 19 bank NPCs opens it
      (`game_bank`, `lib/ps/systems/086-bank.lua`): the balance and the money carried, Deposit
      and Withdraw with +1,000/+10,000/+100,000 and All, Transfer with a name check that says
      when the name is one of your own characters (allowed, with no cap) and a confirmation,
      and History with the last 20 deposits, withdrawals and transfers. Every action needs the
      trainer within 4 tiles of the banker; walking away closes the window. The keywords still
      work for older clients.

Items 1 to 5 and 7 are done.

Alongside, as small separate changes: what's left of the
[bug fixes and small ideas](#11-bug-fixes-and-small-ideas) (hunting task time limit),
[switching off the old PSoul and anniversary content](#13-switch-off-the-old-psoul-and-anniversary-content),
the [event calendar and double shiny](#15-daily-login-rewards-and-events),
[reports to Discord forums](#16-reports-and-feature-requests-to-discord-forums), the website's
[live status and Discord card](#4-website), the level-up banner that lists what just unlocked,
and the Android phone UI pass.

Also open: [move sounds and volume sliders](#20-move-sounds-and-volume-sliders), a phone UI pass and a security check of the live server (open ports, SSH,
firewall). The [Android signing key](client-updates.md#one-time-setup) is set up: client
releases sign the APK with `ANDROID_KEYSTORE_BASE64`.

Also open: the bugs and gaps the wiki check found ([list](#found-while-checking-the-wiki)),
buying Soul Coins with PayPal ([phase 4](#19-accounts-soul-coins-and-the-store); accounts and
email, login security and the Store are built, and the Soul Coin NPCs are off the map), the
[travel picker](modernization-audit.md#3-travel-picker), the
[new Pokémon #387 to #718](#23-new-pokémon-gen-4-to-6), the
[news banner, call-out bubbles and Discord announcements](#25-announcements-news-banner-call-out-bubbles-discord-and-the-calendar), and putting Johto in
`scripts/mapper/hidden-regions.txt` while it is built, so the map doesn't show it before launch.

## 1. New depot

**Built** (`lib/ps/systems/067-pc.lua`, client `game_pc`): one PC window with Poké boxes,
stash, inbox and depot tabs and a search over all of them. Using any depot locker opens it
straight away (the locker action calls `PC.open`; the container no longer opens first). "Open
depot" in the PC opens the old locker and its depot chest. Old clients without the PC keep the
classic container. The client talks over extended opcode JSON, not chat commands. Where it differs from the plan below:

- A Pokémon in a Poké box is a database row with its ball's attributes (`pc_boxes`), the
  same way the GTS and the Day Care keep them, not an item in a container. Nothing about
  the Pokémon changes, and it takes no depot space.
- Throwing a ball is refused ("Your Poke boxes are full.") when the bag has no room and
  every box is full. Deliveries still go to the inbox when the boxes are full.
- Deliveries still call `doPlayerAddDepotItem`. For PC players, stacks go straight to the
  inbox; Pokémon and other items are marked, put in the depot chest and moved right after
  the script that delivered them is done (it may still use the item). Mail and parcels
  left in the locker are unpacked into the inbox. A delivered bag stays in the depot.
- The stash takes stackable items and held items only.
- Search results open the tab they are in; they are not taken straight to the bag.
- Not built yet: the reward chest, and the GTS filters (type, IVs, nature) in the boxes.

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

## 2. Auto-walk and world map

**Built.** Phase A (the client's auto-walk stopping on long walks) is fixed, and phases B to F
are the [Pokepedia](#pokepedia-cyclopedia-style-window). The plan below is kept for reference.

Click-to-walk (game map, minimap, full map) must feel reliable again. On top of that, the
**M** / full map becomes the place to orient, drop waypoints, build routes, and walk them.
Route following reuses the same auto-walk engine as a single click, so we build and test them
together rather than as two separate features.

### What exists today

| Piece | Where |
| --- | --- |
| Server diagonal step timing | `lastStepCost = 1.25` on diagonal moves in `core/server/src/creature.cpp` (must match client `diagonal-walk-speed` in `data/setup.otml`, **1.25** on the Redemption client). |
| Client path + auto-walk | `LocalPlayer::autoWalk`, `Game::autoWalk`, 127-step packets, continue-walk when the path ends before the destination (`localplayer.cpp`). |
| Minimap click walk | `modules/gamelib/ui/uiminimap.lua` (`autowalk = true`). |
| Full map (protocol 854) | `game_minimap/minimap.lua` `fullscreen()` — **does not** center on the player when opened; it restores `oldPos` from the last session. Side panel minimap already follows the player when `fullMapView` is false. |
| Town names + guide marks | `pokeverse-modern/modules/game_minimap/map_labels.lua` (`MAP_REGIONS`, `MAP_LABELS`, written by `scripts/mapper/build_map_labels.py`) and `pokeverse.lua` (`GUIDES`, coord copy label). |
| Cyclopedia map | Not shipped (stripped in `assemble-redemption-client.sh`); **M** opens the Pokepedia's Map tab (the fullscreen minimap only when the Pokepedia is missing). |

### Auto-walk: symptoms and likely causes

Players report stutter, stopping short, or “fighting” the path after diagonals got faster on
the server. Before adding routes, we should **reproduce on 854** (map click, minimap click,
long diagonal paths, corners, stairs, doors) and fix the core loop:

1. **Timing alignment** — Server step interval vs client `getStepDuration()` / diagonal
   multiplier vs A* diagonal cost in `map.cpp`. Any mismatch shows up as cancel-walk retries
   (`retryAutoWalk`, `onAutoWalkFail`) or pre-walk desync on old protocol.
2. **Chaining** — Destinations farther than 127 steps must seamlessly re-path (`m_lastAutoWalkPosition`
   continuation); routes will hit this constantly.
3. **Interrupts** — Manual WASD, combat, dialogs, teleport, and `stopAutoWalk()` in
   `gameinterface.lua` must leave a predictable state for “resume route” later.
4. **Floors** — Clicks on another floor: confirm whether we keep the legacy z-adjust hack in
   `uigamemap.lua` or require same-floor clicks on the world map only.

**Phase A (auto-walk only):** fix and regression-check the above; no new UI beyond maybe a
status line (“Walking…”) and clearer cancel. Optional: small `game_nav` module that only wraps
`player:autoWalk` with logging hooks for QA.

### World map: phases (after Phase A is stable)

**Phase B — Open on the player**

- On `fullscreen()` **open**, set camera to local player position and current floor; keep
  `oldPos` only for “return to where I was looking” if we add that as a secondary action.
- **Recenter** button (reuse hidden `resetButton` or new PokeVerse-styled control) snaps to
  player + matching floor.
- Call `PokeverseMap.setFullMapView(true)` as today for town labels.

**Phase C — Waypoints**

- Player-placed marks: name, icon, position, floor; list in a side panel on the full map.
- **Persistence:** per character in `g_settings` (same pattern as minimap flags in
  `uiminimap.lua:save`). Server sync is optional later (extended opcode + one table) if we
  want waypoints across reinstalls.
- Left-click existing waypoint → `autoWalk` (respect 250-tile flag limit or raise for routes
  only). Right-click → rename / delete.

**Phase D — Routes**

- A **route** is an ordered list of stops: waypoint refs, town labels from `MAP_LABELS`,
  or a raw clicked tile.
- UI: build route from waypoints, show polyline + per-leg distance, checklist of stops.
- **Navigation controller** (client Lua): current stop index, on `onPositionChange` mark stop
  reached within N tiles, then `autoWalk` next stop; on failure show message and pause.
- **Pauses (agreed defaults — change if you want):**
  - Wild battle / forced battle → pause; offer **Resume route** when combat ends.
  - NPC dialog open → pause.
  - Manual walk or click elsewhere → cancel route (or “Pause route” — **To decide**).
  - Stairs / holes → auto-continue if the next stop is on another floor (**To decide**:
    full multi-floor pathing is hard; v1 may be same-floor routes only).

**Phase E — Search and POIs**

- Search box over town names (already in data) + guide POIs; jump camera and optional “Add to
  route”.
- Later: gyms, Pokémon Centers, routes as a structured layer (extend `GUIDES` or a new JSON
  file generated from the wiki).

### Pokepedia (Cyclopedia-style window)

**Built (phases B to F)** (server `lib/ps/systems/069-pokepedia.lua`, client `game_pokepedia`):
the window with the Map, Houses, Pokédex and Items tabs, waypoints and routes, Pokédex
knowledge levels and the tracker panel, as agreed below. M opens the Map tab (not while
typing); the window itself has no key by default (Settings > Controls). Choices made:

- Waypoints and the route are saved per character on the client (`g_settings`). A route walks
  its stops in order; a battle or an NPC talk pauses it, and walking somewhere else stops it.
  A stop on another floor waits until the player takes the stairs.
- Houses: the tab buys from anywhere, premium only, one house per account
  (`housesPerAccount = 1`); the transfer asks the buyer to confirm and moves the money and the
  house in one step.
- Long messages are sent in pieces the client joins back together, because the server drops
  strings over 8 KB, and `sendExtendedOpcode` (C++) now starts a new packet when a message
  doesn't fit in the current one. The Live server `deploy` action builds the new binary and
  adds the two new tables (`player_item_discoveries`, `player_dex_kills`, in
  `schemas/pokeverse-extensions.sql`) on its own; nothing to run by hand.
- "Open in Pokedex" opens the old Pokédex window, which only shows species scanned with the
  Pokédex item; the button is disabled until then.

One window with tabs, modelled on Redemption's Cyclopedia (`modules/game_cyclopedia`) but
built for protocol 854: our own JSON messages (like the PC and GTS), not Tibia's cyclopedia
packets. The Cyclopedia module itself stays out of the client (it unloads below 13.10).

- **Map:** the world map from the phases above (centred on the player, floors, mark filters,
  Places search, waypoints and routes). M opens this tab directly.
- **Houses:** replaces the `/house` commands, the way Tibia's house tab works.
  - Today: 683 houses (8 guild halls) in `data/world/map-house.xml`; price is 50 per tile
    and the weekly rent equals the price (`config.lua`); level 25, premium, one house per
    player; buying needs the player to face the door (`TalkAction::houseBuy`).
  - List with search and filters (town, free or rented, size, guild hall); details: size,
    beds, price, weekly rent, owner, paid until; a small map centred on the entrance with
    the house tiles highlighted (the server sends the tiles).
  - Buttons: Buy, Leave, Show on map, Walk here; guest and sub-owner lists edited in the
    window. They call the same server code as the commands, which keep working.
  - **Agreed:** first come, first served at the fixed price (no auctions for now); bought
    from the tab anywhere; still premium only; one house per account (`housesPerAccount`
    goes from 0, no limit, to 1).
  - **Transfer (agreed):** an owner can transfer or sell the house to another player. Today
    that is `/house sell <name>`: both stand within 3 tiles and trade a house deed in the
    trade window. In the tab: the owner enters the name and a price, the buyer gets a confirm
    window, and the money and the house change hands in one step, anywhere. The buyer must
    meet the buy rules (level, premium, no house on the account).
  - Fixed with it: `TalkAction::houseSell` checked premium the wrong way round.
- **Pokédex:** opens the current Pokédex window (asks the server, which opens it as today
  through `doPlayerSendPokedexOpen`). Its Details tab (built October 21) shows each species
  in sections, gated by Pokédex knowledge, from `getDexDetails` in `010-pokedex.lua` on
  `EXTENDED_IDS.POKEDEX_DETAILS` (43).
- **Items (agreed):** everything sold in shops is listed from the start; everything else (rare
  drops, held items, quest and event items) shows as "???" until the player has had one in
  the bag or depot or looked at one, with a count per category ("Held items 4/32").
  Discoveries are saved on the server per character.
- **Wiki (built):** see [section 9](#9-in-game-wiki-and-tutorial).
- **Later, Help:** "what to do next" hints from the tutorial, pointing at routes on the map.

**Agreed keys:** M opens the Pokepedia on its map tab; the top bar button opens it too. (P was the Pokepedia key at first; it now opens the Trainer Card.)

### Pokédex knowledge levels (like Tibia's bestiary)

Using the Pokédex on your own Pokémon shows everything, as today (`detailed` in
`010-pokedex.lua`). On a wild Pokémon it shows what you know about the species, and you learn
more by defeating and catching it:

| Level | How | Shows |
| --- | --- | --- |
| Seen | Use the Pokédex on one (today's registration) | Name, picture, types, type matchups, evolution family |
| 1 | A few defeats, or one catch | Base stats, abilities and field moves, move list |
| 2 | More defeats | EV yield, item drops, a catch-rate hint |
| 3 (complete) | Many defeats | Spawn areas on the map, with Show on map and Route here |

- Types and matchups are never hidden: they are needed to battle.
- A defeat counts when your Pokémon knocks it out or you catch it. A catch counts as level 1
  plus extra defeats.
- **Agreed:** defeats needed rise with each level: 25 for level 1, 100 for level 2, 500 for
  level 3 (complete). A grind, but reachable by hunting normally. Event Pokémon unlock by
  catching only.
- No charms or bestiary points: Tibia's charm system has no fit in a Pokémon setting.
- Kill counts per player and species are kept on the server (one table); the hunting tasks
  (`064-huntingTasks.lua`) already count kills and can use the same count.
- Spawn areas come from the spawn files (`data/world/*-spawn.xml`), grouped into areas with
  the nearest town; rare and event spawns are left out. The website's "where it spawns" uses
  the same data.
- Existing players start each species they have registered or caught at the matching level.

- **Agreed:** rare spawns that are not legendary (Dratini, for example) need fewer defeats,
  about half (roughly 10, 50 and 250). The list of rare species is set by hand from the spawn
  files.
- **Agreed:** legendaries need 1, 5 and 15 defeats (or catches).
- **Rewards (agreed):** completing a species gives experience or money; completing the whole
  Pokédex (100%) gives a Master Ball, once per character.

### Tracker panel (agreed)

A side panel like Tibia's bestiary tracker, in the right column under the minimap. It
follows what the player picks:

- **Pokédex:** chosen species with their level and defeats to the next level
  ("Rattata 63/100").
- **Daily, weekly and hunting tasks:** progress of the active tasks ("Defeat 30 Water
  Pokémon 12/30"), from the same data the Tasks window already gets
  (`game_dailytasks/tasks.lua`); a finished task shows a Claim button that opens the Tasks
  window.
- Each line can be removed or pinned; a click opens the Pokédex entry or the Tasks tab. The
  panel can be collapsed or hidden like the other side panels, and what is tracked is saved
  per character.

### Suggested delivery order

```text
Phase A  Auto-walk fix                  → playable click-walk everywhere
Phase B  Pokepedia + Map tab            → centred map, Places search, Pokédex button
Phase C  Houses tab                     → buy, leave and manage houses without commands
Phase D  Waypoints + routes             → walk a trail; depends on A
Phase E  Items tab with discovery
Phase F  Pokédex knowledge levels       → spawn areas need the map (B) and routes (D)
         + tracker panel (Pokédex and tasks; the task part can come first)
Later    Help tab (hints, tutorials)
```

Phases A to F are built, and so is a Wiki tab; the Help hints are still to come.

### Decided while building

1. **Full map entry:** M opens the Pokepedia's Map tab, its own window, not the fullscreen
   minimap.
2. **Waypoint storage:** on the client, per character. Server sync can come later.
3. **Route cancel rule:** walking with the keys or clicking somewhere to walk stops the route;
   the Route tab has Pause and Resume.
4. **Multi-floor routes:** stops can be on any floor; the route waits until the player takes
   the stairs.
5. **Range limit:** routes walk one leg at a time and try shorter steps toward a stop when no
   path reaches it.

### Real world map (built)

The Map tab shows the real map, drawn from the game's sprites, instead of the minimap; a button
under the zoom switches back to the minimap. The HUD minimap is unchanged.

- `scripts/mapper/render_pokepedia.py` draws the ground floor and the floors above it at 4
  pixels per tile (and coarser copies for zooming out) in the format of Redemption's satellite
  map (`satellitemap.cpp`), which draws only what is on screen. Underground floors are left
  out and show the explored minimap; house pictures still cover every floor. The local
  preview (`scripts/render-map.sh`) still draws the underground, for mapping. The client has a 4 pixels per tile level and keeps at
  most 64 chunks in memory.
- The client release renders it and caches it; after a map change only the pieces that
  changed are drawn again (about 12 minutes for the whole map on 4 cores, a few minutes
  after a small change). About 120 MB with the house pictures, downloaded once.
- **Hidden regions:** a region listed in `scripts/mapper/hidden-regions.txt` is left out of
  the map and the house pictures until its line is removed and a client is published. Its
  `bounds` line (0,0 - 4650,3530) leaves out everything outside: the instances, Beginner
  Island and the tutorial island.
- A piece is drawn again only when its tiles or the sprites of the items on it change, so new
  art redraws just the pieces that show it. Only main saves the render to the Actions cache.
- `scripts/render-map.sh [client folder]` renders it locally, hidden regions included, to
  check a region while it is built.
- Still to do: places where the map has no tiles show the minimap's sea colour on the ground
  floor (a few inland spots look like lakes); black is a small change if wanted.

### Minimap marks (built)

The guide marks use Pokemon icons drawn from the game's item sprites
(`scripts/mapper/make_mark_icons.py`) instead of Tibia's flags: a Poke Ball for Pokemon
Centers, a Potion for marts, each gym's badge, a Pidgeot for Travel Fly, and so on. The
icon comes from the words in the mark's name, so new marks (Johto) get one on their own; a
gym in a new town needs its badge added to the script and to `pokeverse.lua`.

## 3. NPC dialogue, quests and tasks

Many NPCs from the old system are missing the blue clickable responses. There are 910 NPC
files and 339 NPC scripts (`core/server/data/npc`).

1. One modern dialogue window for every NPC: name and portrait, blue clickable responses,
   and a notice when a quest is accepted or a task updated. **Window built**
   (`pokeverse-modern/modules/game_npcdialog`):
   - Docked at the bottom of the game screen above the console. It shows the NPC's lines since
     your last reply, with that reply greyed out above them.
   - Every blue word is also a button. A {yes} question gets a big green Yes and a red No.
     Buttons send through the NPCs tab, like clicking the link there. They are never greyed
     out: the client can't tell whether asking again would say something new.
   - There is no text box in the window, so WASD isn't affected; typed answers (bank amounts,
     bids, names) go in the NPCs tab.
   - Goodbye says "bye" and closes it. The X closes it like walking away, without a goodbye.
     Walking away, the NPC leaving the screen, or two quiet minutes close it too. That NPC's
     later lines don't reopen it until you talk to it again.
   - When several NPCs answer a "hi", the closest one keeps the window.
   - Long answers wrap inside the window and the buttons wrap to more rows.
   - The role line ("Gym Leader, Pewter City") is a client list for the NPCs with portraits.
   - The mission notices are built (below).
2. A checker that lists every NPC whose responses are not clickable.
3. Convert the NPCs, quests and tasks town by town. Quests and the task boards show up in
   the quest log.

### Quest log, notices and NPC icons

**Built** (server `data/lib/ps/systems/075-quests.lua`, opcode 31; client
`pokeverse-modern/modules/game_quests`, which replaces Redemption's Tibia quest log):

- **Quest log** (top bar button or L): Active, Available and Completed tabs with counts, a
  search (quest, NPC, town), and groups: Main story, Gyms, Getting started, Side quests,
  Daily, Addons, Events. Every NPC quest in `002-quest.lua` is listed; the names and
  descriptions come from `XML/quests.xml` ("Kanto Main #01 - A new mystery!", "Part 1 of 5"),
  and quests without one are "<NPC>'s request #n". Available lists what the NPCs offer now;
  quests from a higher level are greyed with the level, and quests of NPCs that aren't on the
  map (events) only show once started.
- **Details:** the giver's portrait (or outfit) and nearest town, Go there (the Pokepedia's
  route), Track, the objective with a progress bar (defeat, catch, bring items, bring a
  Pokémon, Pokédex count), the rewards with their item pictures and EXP, the level needed,
  and "daily: again after the server restart".
- **Tracker:** a started quest is tracked on its own (the Pokepedia's tracker panel); a
  finished goal gets a Go button that walks back to the NPC. Untrack in the window or with
  the line's X.
- **Notices:** "Quest started" and "Quest complete!" banners (with the rewards), and a card
  at the top right of the map for progress: every step up to 10, then every tenth of the way
  and the last three ("Defeat 30 Golem 12 / 30"), and a green "Done! Go back to Noah". The
  old "Defeat Task ... step complete" chat lines only go to old clients.
- **NPC icons:** a badge next to the name plate. Gold "!" a quest to start, grey "?" one under
  way, gold "?" one to hand in (per trainer, from the server), then crossed swords (battle),
  coin bag (shop), ship wheel (travel), coin (bank), pink cross (Nurse Joy) and egg (Day
  Care). NPCs with several show them in turn. The roles come from the NPC files
  (`scripts/make-npc-roles.py` writes `npc_roles.lua`; run it again after adding NPCs), the
  art from `scripts/art/quest_ui.py`. The server's static quest bubble is replaced by the
  trainer's own mark. The badges need the new client build (`Creature:setIcon`); older
  builds keep the server's icons.
- Marks refresh when a quest starts, finishes or reaches its goal, at level-up and when the
  log opens; a "bring items" quest shows "?" gold only after one of those.

## 4. Website

Static site on the PokeVerse-Clients `gh-pages` branch ([website.md](website.md)).

**Built:** home and downloads, Pokédex and moves pages from the game data, the world map
(the Pokepedia's, with the names of places by zoom, updated by each client release), and a Discord
button with the game's invite. Still to do: the live server status (the panel says "coming
soon"), the Discord card, and the pages below.

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
  - Vocation pages and GTS listings (both are in the game; the site pages are still to do).
  - A better download section: detect the player's platform, show the version, and tell
    Android players to open the link in Chrome (the GitHub app catches `github.com` links).
- **Later, with a domain:** rankings (level, catches, shinies) and trainer profiles.

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
roll 11–15% by rank, so at the top rank about two thirds get it early. The NPC's messages
say day 14.

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
| 5 | Master Angler | Most fishing experience; the only trainers who can use cranes |

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
- **Proposed:** the rank-up trial goal counts. The rank levels and perk percentages are in
  `Vocations.RANK_LEVELS` and `Vocations.PERKS`.
- **Built: the vocation window** (client `game_vocation`, server `Vocations` in
  `data/lib/ps/systems/070-vocations.lua`, `EXTENDED_IDS.VOCATION`). A scrolling grid of
  cards, three per row, each with a picture, the vocation's icon, name, tagline and three
  perks. Select turns into Confirm and Back with "This choice is permanent"; the server checks
  trainer level 20 and that the trainer has no vocation, then keeps the choice in the
  `vocation` storage. Below level 20 the buttons are greyed out; after the choice the card shows
  "Your vocation". `Vocations.open(cid)` opens it, and a choice only counts while a window it
  opened is up. For now every trainer opens it with `U` (the vocation key, `{action = "open"}`);
  below level 20 it opens with the buttons locked. Staff can also test it with
  `/vocation`, `/vocation reset`, `/vocation rank,3` and `/vocation Name` (or `Name,rank,3`).
  Artwork: `scripts/art/vocation_ui.py`, with the card pictures in
  `scripts/art/vocation-banners`.
- **Built: ranks and perks.** Every number is in `Vocations.PERKS` (`070-vocations.lua`).
  A new vocation starts at rank 1; `Vocations.rankUp(cid)` gives the next rank when the
  trainer's level allows it and the rank-up trial below is done.
  The title shows when others look at the trainer ("Vocation: Catcher, Rookie Catcher
  (rank 1)") and in the vocation window. No perk works in a duel, the PvP arena or an NPC
  battle.
  - Ace Trainer: the bonus is added to Pokémon EXP from defeated Pokémon only.
  - Catcher: ball rates are small whole numbers compared with a whole-number roll, so the
    bonus can't scale the rate. A failed roll gets a second chance sized so the overall
    chance is exactly ×1.02 to ×1.10. Pokémon that can't be caught yet (under 25% of the
    tries) stay uncatchable, and Safari and Master Balls are unchanged.
  - Breeder: faster hatching is set when the egg goes into the incubator. The daycare now
    uses the agreed wait for everyone: from day 7 since the last egg (or the first daycare
    visit), one 10% roll per day, and a certain egg on day 14. A late visit rolls once for
    each day it missed. The old 15-day wait and the "out of 300" chance with failure counter
    are gone; the timed extra egg rate item adds its value as percentage points to the daily
    roll. Breeders with Premium roll 11–15% and have the second egg chance.
  - Day Care window (client `game_daycare`, `EXTENDED_IDS.DAYCARE`): the Old Man, the Old
    Lady and the "daycare" word open it. Two places take any Pokémon in either order;
    lines run from them down to the egg slot, blue for male, pink for female and lilac
    for Ditto or genderless. It shows compatibility, time trained, EXP and fee, held
    items, the egg wait and chance, the plates, and the running Day Care events. When an
    egg is ready its sprite, nature and IVs show and "Take egg" puts it in the bag. Old
    clients keep the NPC text and get waiting eggs on greeting.
  - Ranger: the radar popup (client `game_radar`, `EXTENDED_IDS.RADAR`), opened with `U`,
    the top bar radar button (Rangers only) or `!radar`. A scan draws every wild Pokémon in
    range as a blip around the trainer, coloured common, uncommon or rare (catch rate under
    100, 100–399, 400 and up or a Pokepedia rare species), shiny or legendary. Ranks 1 and 2
    see unnamed blips snapped to 5 and 3 tiles (types from rank 2); from rank 3 blips are exact
    with species and sprite. Shinies (rank 4), legendaries and event Pokémon (rank 5) sit in a
    halo at their direction and distance band only; legendary results have a 10-minute
    cooldown. Filters (all, species, type, rarity, shiny only, legendaries only) work on the
    last scan; rows show the rank they need. Clicking a blip tracks it: Target Info, a cone on
    the radar, an arrow beside the trainer on the game map (with the distance) and a flag on
    the minimap, until the trainer reaches it or presses Stop. Ranks 1 and 2 are a snapshot;
    from rank 3 the exact blips follow their Pokémon live for 2 minutes after a scan (shinies
    and legendaries stay a direction and band). Pokémon on screen move every tick from the
    client's own map; for the rest the server re-reads only the scanned Pokémon's positions
    every 2 seconds (no new search of the area), sends only the ones that moved or are gone
    (caught or defeated: the blip goes and tracking stops), and pauses while the popup is
    closed and nothing is tracked. From rank 2 the tracked Pokémon also leaves footprints
    that only the Ranger sees (section 11, "Ranger tracking leaves footprints"). Without the
    PokeVerse client
    `!radar` and `!radar <type>` answer in text as before. Artwork: `scripts/art/radar_ui.py`.
  - Angler: +20% to +100% fishing skill gain. From rank 2 casting the line lists what can
    bite there; from rank 3 the first bite comes after half the rod's wait, and each bite roll
    is a little luckier. From rank 4 the Fishing Guide (client `game_fishing`,
    `EXTENDED_IDS.FISHING`), opened with `U`, the top bar button (Anglers only) or `!fishing`,
    shows what bites in each region: a tab per region (pinned where the trainer is), one row per
    skill tier with the Pokedex portraits, the Pokémon level range and "Can hook now" or the
    skill it needs. A region's rows are the Kanto pool plus that region's own Pokémon, which
    get a gold frame. Clicking a portrait shows its types, rods and catches; side panels show the
    progress to the next skill and the rods. Without the PokeVerse client `!fishing` answers in
    text as before. Cranes (skill 60) are for rank 5 Anglers only. Artwork:
    `scripts/art/fishing_ui.py`.
  - `U` is the vocation key: the radar for Rangers, the Fishing Guide for Anglers from rank 4,
    and the vocation window for everyone else (`game_vocation` keeps the key; `registerTool`
    adds a tool). The Pokepedia's Wiki has a Vocations category with a page for each.
  - The radar's map arrow is attached to the trainer (`attachWidget`), so the map moves it with
    every step instead of a 150 ms timer, and the blips are only laid out again when the
    trainer or the target moves.
  - Medic: +3% to +15% from health potions, and health potions work on another trainer's
    Pokémon when neither trainer is in a duel, the arena or an NPC battle.
  - Tests: `scripts/vocation-test.py` with `scripts/testing/vocation-test-talkaction.lua`
    (checks against a live server, run by `scripts/test-server-linux.sh`).
- **Built: the vocation progress window** (`game_vocation/progress.otui`). Trainers with a
  vocation get it from `U` or the Vocation button on the top bar; trainers without one still
  get the choice window. It shows the vocation's banner, the five ranks as a track (done,
  current, next, locked), the perks active now, and the next rank with its level, its new
  perks and the rank-up trial with a progress bar per goal. Rank up is enabled once the level and
  every goal are done, and the top bar button shows a red dot when it is. Wear outfit puts the
  vocation's outfit on again. Artwork: `scripts/art/vocation_progress_ui.py`.
- **Built, goals proposed: rank-up trials** (`Vocations.TRIALS`). Besides the trainer level,
  each rank has two or three goals about what the vocation does, and all of them have to be
  done; the counts start again at each rank. "Different species" counts each species once per
  rank (shiny forms count as their species), and "Reach fishing skill" is the skill itself.
  A dash means the goal is not part of that rank. The numbers are a proposal to tune.

  | Vocation | Goal | Rank 2 | Rank 3 | Rank 4 | Rank 5 |
  | --- | --- | --- | --- | --- | --- |
  | Ace Trainer | Defeat wild Pokémon | 200 | 500 | 1000 | 2000 |
  | | Defeat different wild species | 15 | 30 | 50 | 80 |
  | Catcher | Catch Pokémon | 50 | 150 | 300 | 600 |
  | | Catch different species | 10 | 25 | 45 | 70 |
  | | Catch shiny Pokémon | – | – | 1 | 2 |
  | Breeder | Hatch eggs (daycare eggs come about every 1–2 weeks; eggs can also be bought) | 2 | 4 | 6 | 10 |
  | | Hatch different species | 1 | 2 | 3 | 5 |
  | Ranger | Radar scans that find Pokémon (a scan every 30–60 seconds) | 100 | 300 | 600 | 1200 |
  | | Find different species on the radar | 10 | 25 | 45 | 70 |
  | | Find a shiny on the radar (they show from rank 4) | – | – | – | 1 |
  | Angler | Hook Pokémon while fishing | 100 | 300 | 600 | 1200 |
  | | Hook different species | 4 | 8 | 14 | 20 |
  | | Reach fishing skill | 15 | 30 | 45 | 60 |
  | Medic | Heal Pokémon with potions | 50 | 150 | 300 | 600 |
  | | Heal other trainers' Pokémon | 5 | 15 | 30 | 50 |
- **Built: the top bar.** Its right side is Hotkeys, Tasks, Daily login, Pokepedia, Tracker,
  Trainer Card and Vocation, then the Radar (Rangers only) and the Fishing Guide (Anglers
  only). The order is the module load order in `game_interface/interface.otmod`. Icons: `scripts/art/topbar_icons.py`.
- **Built: the Trainer Card** (client `game_trainercard`, server `TrainerCard` in
  `data/lib/ps/systems/071-trainerCard.lua`, `EXTENDED_IDS.TRAINER_CARD`). It opens from the
  top bar (your own card), from "Trainer Card" in the right-click menu on a trainer, and in
  place of the old Pokédex look at a trainer when the client supports it (the client says so
  with a hello message at login). Only online trainers have a card.
  - Left side: a scene where the trainer's outfit walks with their favorite Pokémon over
    their hometown (pictures rendered from the map by `scripts/art/trainercard_scenes.py`),
    the name with ♂/♀, the title, the vocation and rank, and the favorite Pokémon.
  - Overview: Trainer Information (level, hometown, guild, mastery, play time, trainer
    since, duels won, respect), the badges (one region at a time with arrows: Kanto 8, Orange Islands 4, Johto 8 and Hoenn 8; the ones not in the game yet are locked slots, and the badge case window works the same way), six trophy Pokémon, statistics (caught,
    Pokédex, unique, shinies, tournaments, achievements, trainers defeated) and an About
    text of up to 160 letters and four lines. Other tabs: Trophies, Achievements (secret
    achievements are hidden from others) and Pokédex.
  - Buttons on another trainer's card: View Trophies, Add to VIP, Trade (a hint, because a
    trade needs an item), Message and Duel (the same checks as the duel item, within 7
    tiles).
  - Your own card has edit buttons: the favorite and the trophies are picked from the
    Pokémon in the belt, the bag and the PC (trophies in click order), the title from a list
    (vocation ranks reached and achievements), and the About text. Change Outfit, Privacy
    (hide play time, statistics or trophies from others), Preview as Others, Cancel and Save.
    The server refuses Pokémon the trainer doesn't own and drops favorites and trophies that
    were released or traded.
  - "Trainer since" counts from the first login after the card was added, because the
    `players` table has no creation date.
  - Artwork: `scripts/art/trainercard_ui.py`.
  - Discord's /trainer shows the card, also for offline trainers (`056-discordBridge.lua`).

### To decide

1. What the mastery items are used for. Ideas: outfits as vocation rewards, plates and
   tokens for rank-ups or crafting.
2. The vocation quest line and the rank-up quests and tasks that call `Vocations.open` and
   `Vocations.rankUp`.

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
- Server tests that check the bonuses never touch combat stats and never apply in PvP.
- Vocation pages on the website. (Done: the values are in one table, `Vocations.PERKS` and
  `RANK_LEVELS`; Discord's trainer lookup shows the vocation and rank.)

## 7. Pokémon storage

**Built** as part of the [new depot](#1-new-depot): the Poké boxes.

## 8. GTS (Global Trading System)

**Built** (`lib/ps/systems/066-gts.lua`, client `game_gts`): item offers to sell or buy and
Pokémon offers to sell, from the Pokémon Center computer. Offers are held until they are sold,
cancelled or expire (7 days), sellers are paid into the bank less a 1% tax even when offline,
at most 30 offers each, Pokémon with face icons, and a history of the player's trades. The
Pokémon and item market NPCs are retired and their listings moved over. Not built yet: price
history ("last sold for"), GTS sales in the Bank window's History (it lists deposits,
withdrawals and transfers), staff tools beyond opening it anywhere, and Discord posts.

Replaces the player marketplace. Built on the existing market module (the legacy
`game_market`; Redemption has one too) and extended:

- Players list items and Pokémon for others to buy.
- Sort, filter and search by species, type, level, IVs, EVs, nature, shiny, price and
  seller.
- Pokémon are shown with their face icons instead of a ball.
- **Escrow:** a listed item or Pokémon leaves the seller's inventory, and comes back if the
  listing expires or is cancelled. This prevents duplicates.
- **Payment:** sales go straight to the seller's bank balance, so they work offline. The
  Bank window (built) has a History tab; GTS sales are not written to it yet.
- Listing fee, a maximum number of listings per player, and an expiry time.
- Price history ("last sold for").
- Safety:
  - Pokémon in the party or on loan cannot be listed.
  - Buying needs a confirmation.
  - Every listing and sale is logged, and staff have tools to look into them.
- Optional: big sales or new listings posted to a Discord channel.

## 9. In-game wiki and tutorial

**Wiki built:** the Pokepedia's Wiki tab (`game_pokepedia/wiki_data.lua`, 96 topics in 8
categories, with search, pictures, tables and links between topics). Every topic was checked
against the code: most of the old Wiki Chat text was out of date (controls, berries, banks,
houses, guilds, tournaments, the Safari Zone, TMs, the daycare) and is corrected. The Wiki Chat
channel is switched off (`channels.xml`), and the texts that pointed to it now say "the Wiki
tab of the Pokepedia (press M)".

Still to do:

- The guide and tutorial windows (`game_guide`, `game_tutorial`).
- The wiki and the website from the same data, so they always agree (the wiki is a Lua table
  in the client today).
- The tutorial uses the new dialogue window and the waypoint trails (for example "follow
  the trail to the Pokémon Center").
- Keep the wiki up to date when systems change; the topics say which files they come from.

### Found while checking the wiki

Not fixed yet:

- **Soul Coins (decided: the premium currency).** Players buy them with real money and
  spend them in the Store (built: `game_soulstore` and `lib/ps/systems/084-store.lua`). It has
  everything the 23 Soul Coin NPCs sold, plus the first Trainer Outfits (Business, Rider,
  Shiny Poke Maniac, 15 each) and their referral rewards. The 16 of those NPCs that were on the
  map are commented out in `map-spawn.xml`; their files stay. Josh Pillberg stays for his EV
  shop; his vitamin reset moved to the Store. Not built: buying Soul Coins
  with money, planned in [section 19](#19-accounts-soul-coins-and-the-store).
- **Vital mastery:** its "longer buffs" perk makes buffs shorter (13 s instead of 20 s).
  The masteries go with the [vocations](#6-vocations), so it may not need a fix.
- **Surprise boxes** only spawn in the west of the map (Hoenn), never in Kanto or the Orange
  Islands. Check whether players can reach Hoenn at all: the Mauville daycare and casino and
  the Lilycove TM NPC are there too.
- **Sandboards** work in the code but can't be obtained.
- The per-tournament trophy is switched off; only the weekly trophy is given.
- Checked since: the slot machines are Eugene Oliver's in Celadon and Dusty Kaylyn's in
  Mauville, and the Quest Log lists PokeVerse quests. Still not checked: what Rocket Grunts give.

## 10. Factions

Team Rocket and other factions, separate from vocations:

- any vocation can join any faction;
- players earn faction points from faction tasks, like the Pokémon Ranger tasks in the
  games, and the points raise their faction rank;
- faction reputation and ranks are separate from vocation ranks;
- faction membership does not change vocation bonuses.

## 11. Bug fixes and small ideas

From the `#notes` channel:

- **Look text for field moves (done):** looking at an object a field move works on says
  so, for example "You see a stone. It looks like it can be smashed." for the Rock Smash
  stone (item 1285), and the same for holes, grass, nest trees, waterfalls, big rocks and
  climbing rocks.
- **Battle list (fixed):** a Pokémon's level did not update until one of the filters was
  clicked; an entry now refreshes when the creature's name (and so its level) changes.
- **Battle list sorting (done):** sort by level up or down; your own Pokémon is always
  first and the one the Ranger radar tracks second, with a radar mark on its row
  (`patches/game_battle.patch`, `game_pokehud/nameplates.lua`).
- **Mouse cursors (done):** Pokémon-themed map cursors a size up from the stock ones, and
  potion, revive, antidote, elixir and energy cursors while using those on a Pokémon
  (`pokeverse-modern/data/cursors`).
- **Held item icons (fixed):** the eight held items, the Lucky Egg and the Exp Share no
  longer swap pictures (their `data.dat` entries are still images now).
- **Premium badge in the Pokepedia (done):** the Premium ability pages show the Pokédex's
  gold PREMIUM badge, which opens the Premium topic.
- **Discord from the Account window (done):** Link Discord shows a code with Copy command
  (`/link code:...` on the clipboard) and Join Discord.
- **WASD double step (fixed):** binding the walk keys again after a relog stacked their
  handlers, so one press walked twice.
- **Default key bindings (done):** every key below is a Settings > Controls entry. The
  letter keys only work with the chat off, and they don't fire while a text field (a search
  box, a name field) has the focus.

  | Key | Action |
  | --- | --- |
  | W A S D | Walk (Movement). The diagonals (Q E Z C before) have no key; players can add them |
  | Ctrl + W A S D | Turn (Ctrl + arrows too). Clear All Texts keeps Ctrl+W only with the chat open |
  | Q / Z | Fly or levitate up / down a floor (`/up`, `/down`) |
  | E | Order (was R) |
  | X | Pokedex on the target |
  | V | Vocation window |
  | U | Vocation tool (radar, fishing guide), or the window without one |
  | P | Your Trainer Card (was C) |
  | C | Event calendar |
  | T | Tasks |
  | L / M | Quest Log / Pokepedia on its map (P opened the Pokepedia before) |
  | 1–0, -, = and F1–F6 | Moves and calling Pokémon (unchanged) |

  The daily login reward, tracker, Pokepedia (other than M), minimap, inventory, options,
  store and admin panel have an entry under Windows with no default key. Tab attacks the next
  target: the battle list's next entry, or with the battle list closed the nearest attackable
  creature on screen. Arrows, numpad and Ctrl + arrows stay
  fixed. R is free.
- **Switching Pokémon (done):** the trainer is protected until the next Pokémon is out (at
  most 1.5 seconds), not in duels or trainer battles.
- **Bugged stairs (fixed, check on live):** stairs that land on more stairs sent two full map
  descriptions in one message, which overflowed it; each now goes in its own message. Known
  spots: the stone stairway (item 3220) at 3295, 252, 7, and the stairs at 3853, 813, 7.
- **Gym leaders (done)** say how many of the gym's trainers are left to beat (or which one,
  when one is left). Gym duels also got banners with each leader's portrait.
- **Hunting tasks get a time limit** (`data/lib/ps/systems/064-huntingTasks.lua`): a hunt
  not finished in time fails on its own and is removed. **To decide:** how long (for
  example by size), and whether a failed hunt costs anything.

- **Slot machine pairs (fixed):** two matching symbols paid by the reel's position, so every
  pair paid 0 coins; they now pay a third of the symbol's payout (Great and Ultra Ball 1,
  Master Ball 3, Amulet Coin 10). A $100 spin returns 0.81 coins on average, not 0.12.
- **Held items (redone):** held items no longer gain levels or EXP; a type item (Charcoal,
  Dragon Fang and the rest) is a flat +20% to that type's moves. Drag one from the bag onto a
  Pokémon on the swap bar to give it (or "Use with" its ball); dropping another on it swaps
  them. A small icon in the slot's corner shows what it holds, the slot's tooltip names it,
  and Alt+click (or right-click > Take held item) gives it back, so Mitchell Meade, who
  took held items off, is off the map (his spawn is commented out in `map-spawn.xml`). Polkadot Bow boosts Normal moves by 10% (as on Bulbapedia; Silk Scarf is the
  full 20%).
- **Lucky Egg and Exp Share (built):** the Lucky Egg gives its holder +50% EXP from defeating
  wild Pokémon. Exp Share holders on the belt that are not out and not fainted split a pool of
  50% of the EXP the active Pokémon earns (and get its EVs). Both are rare drops or event
  prizes only, never in a shop: Lucky Egg from Chansey (0.3%), Blissey (0.5%) and shiny
  Chansey (2%), Easter eggs and the July rare chest; Exp Share from Porygon (0.3%), Porygon2
  (0.5%) and the July legendary chest; both from anniversary surprise bags. They can be traded
  on the GTS.
- **World boss repeats (fixed):** a typo in the storage key meant the server never knew which
  boss spawned last, so the same one could come twice in a row.
- **Fishing tasks don't count up (fixed):** the server runs actions, creature events and
  talk commands in separate Lua environments, and each kept its own copy of the task
  board. The Tasks window picks tasks through a talk command, so fishing, wild defeats and
  NPC trainer wins (creature events) kept counting on the copy loaded at login, which had
  no tasks yet, until the next login. The boards are now read from the database every
  time, and the server test picks tasks and hooks Pokémon in one session.

- **Legendary spawning (audited October 2026, read only).** There is no wild legendary
  system: no legendary can be met or caught in the wild today.
  - **Map spawns:** none. Not one of the 21 legendaries (or their shiny forms) is in
    `world/map-spawn.xml` (26,959 spawns).
  - **What creates legendaries:**
    - The three bird dungeons (`legendaryOrbs.lua`, `028-dungeons.lua`) spawn Boss Zapdos,
      Boss Moltres and Boss Articuno (Boss Articuno turns into Frozen Boss Articuno). On
      death they leave a reward chest (doll, Deepsoul Stone, 5 feathers), never a corpse,
      so they can't be caught. All three share one storage (8370), so each trainer can do
      **one bird, once, ever**.
    - The New Island quest's Mewtwo is an NPC; using the Master Ball prototype spawns
      Final Mewtwo, a boss.
    - The Ranger radar test spawns an Articuno. That's the only plain legendary created
      anywhere, and it's in the test only.
    - The world bosses (`021-boss.lua`, every 3 days) are renamed regular Pokémon
      ("Winged Wisdom" is a Pidgeot), not legendaries.
    - The wave arena, citizens and the doll case exclude legendaries; the old Pokémon shop
      price list (100,000 each) is commented out.
  - **The plain legendary monsters are ordinary:** level 100 with normal-looking stats
    (a wild Articuno has about the health of a wild Dragonite), corpse, no boss behaviour.
    Gen 1 has shiny forms; the Gen 3 shiny forms are commented out in `monsters.xml`.
  - **Catching is effectively impossible:** a catch needs the Pokémon's `chance` worth of
    "tries" (each ball thrown adds its catch rate: Ultra 3, Safari 4). The catch can't
    happen before 25% of that. Articuno, Zapdos, Moltres and Mewtwo have chance 10,000:
    at least 834 Ultra Balls, about 3,300 to be likely, and each throw needs its own
    defeat. The other 17 have 100,000, ten times that. Only the Master Ball
    (`guaranteedCatch`) would catch one, on the first try.
  - **What already expects wild legendaries:** the Ranger radar (rank 5, a direction and
    distance band, 10-minute cooldown), the Discord bridge (posts legendary spawns, 5
    minutes apart per species), the Pokepedia (legendary tier: 1, 5 and 15 defeats or
    catches, $15,000) and the highscores (Caught Articuno and others). For 17 of the 21 the
    Pokepedia goals can't be reached, and the bird bosses likely don't count as defeats
    (their death is cancelled before the kill events run).
  - **Decided (October 2026):** wild legendaries are separate from the dungeon and quest
    bosses and live on the main map. All of them roam, and all 21 visit Kanto until their own
    region is live. They are built for group fights, but a high-level trainer can beat one
    alone. Level 50 is recommended, not required. The catch chances stay as they are for now.
    Trainers can catch more than one, and can trade them on the GTS.
  - **Plan (agreed, steps 1–3 built):** one new system file (`systems/078-wildLegendaries.lua`)
    with a table per species, not the map spawns.
    - **Tiers:** tier 1 is the birds, the beasts, the Regis and Latias/Latios. Tier 2 is
      Mewtwo, Mew, Lugia, Ho-Oh, Celebi, Kyogre, Groudon, Rayquaza, Jirachi and Deoxys.
    - **Where:** one pool of anchor points spread over all of Kanto: outdoor, walkable and
      reachable without Surf, and checked with a tile-check script like the raid points. Each
      species also has a home area that fits it (Articuno and Regice the Seafoam Islands,
      Zapdos and Registeel the Power Plant, Moltres, Entei and Groudon Cinnabar's volcano,
      Raikou Routes 11–12, Suicune the rivers and lakes, Regirock Rock Tunnel, Latias and
      Latios the coasts, Mewtwo Cerulean Cave, Mew the Cinnabar Mansion, Lugia and Kyogre
      the southern shores, Ho-Oh and Rayquaza the Indigo Plateau, Celebi Viridian Forest,
      Jirachi and Deoxys Mt. Moon). Spawns and moves pick the home area half the time and any
      point in Kanto the other half, so they can turn up anywhere. Other regions' points join
      the pool when those maps are live.
    - **Limits:** at most 2 alive at once, never two of the same species, never two tier 2.
    - **Population scaling:** the gap between spawns and the cooldowns depend on the
      trainers online. The gap is worked out at each spawn and checked again every 5 minutes,
      so it gets shorter when the server fills up:

      | Online | Gap to the next spawn | About per day | Cooldown tier 1 / tier 2 |
      | --- | --- | --- | --- |
      | 0–4 | 16–24 h | about 1 | 30 h / 4 days |
      | 5–14 | 4–8 h | 4 | 30 h / 4 days |
      | 15–39 | 3–6 h | 5–6 | 24 h / 3 days |
      | 40 or more | 2–4 h | 8 | 16 h / 2 days |

      Below 5 online they still spawn, slowly, even with nobody online, so the Discord post
      can pull players in. The thresholds are settings. The species is drawn from
      those off cooldown, tier 1 three times as likely as tier 2. The cooldown counts from
      when it is beaten, caught or flies off. No spawns in the 2 hours before the daily
      restart (midnight), and one still alive at the restart counts as fled with no cooldown. The next
      spawn time and the cooldowns are kept in global storages.
    - **Time in the world:** 90 minutes (tier 1), 120 minutes (tier 2). It doesn't fly off
      while someone has hit it in the last 2 minutes.
    - **Roaming:** it wanders near its anchor point and moves to another one far away every
      4–6 minutes (Latias and Latios every 2–3). It stays put while being hit. At 50% health
      (tier 2 also at 25%) it flees to another point with the health it has left. Left alone
      for 3 minutes, it slowly heals back to full.
    - **Notifications:**
      - Spawn: server-wide, with the area and "Recommended for trainers level 50+".
      - Each move: "Articuno was spotted near Route 20" in a Legendary chat tab, plus a
        last-seen pin on the Pokepedia world map.
      - Fleeing at 50% or 25%, and the end (beaten, caught, or flew away): server-wide.
      - Discord: one thread per encounter with the spawn, sightings and end (new bridge
        event kinds; the bridge's 5-minute limit per species doesn't apply to them).
      - The Ranger radar (rank 5) stays the exact tracker.
    - **Fight:** the wild one is the plain species (same name, stats, moves and type from
      its monster file), with its health raised by the spawner for that encounter only. A
      caught one has the normal stats of its species; a test checks that the boost doesn't
      carry over. Boss health: 4–5 trainers around level 80 beat a tier 1 in about 5 minutes,
      a level 100 trainer alone in about 15–20 with potions. Tier 2 has about twice that.
      Signature moves, with area attacks that punish groups standing together.
    - **Rewards:** everyone with at least 10% of the damage gets the Pokepedia defeat, Rare
      Candy (item 14463) and money. First amounts: tier 1 one Rare Candy and $5,000, tier 2
      two Rare Candies and $10,000. The trainer or party with the most damage has the body to
      themselves for 60 seconds for the catch throw, then anyone can throw. Caught
      legendaries are not marked unique, so the GTS takes them. Highscores and achievements
      count wild catches.
    - **Staff:** `/legendary status`, `/legendary spawn <name>`, `/legendary end <name>`,
      `/legendary next 5m`.
    - **Tests:** the limits, the cooldowns and population scaling, roaming, the flee, the
      damage shares and rewards, and the notifications.
    - **Order:** (1) spawner, pool, limits, timers, roaming and staff commands (server Lua,
      no new build); (2) notifications and the Discord threads; (3) boss health, damage
      shares and rewards; (4) the world map pin and the radar check (client release);
      (5) tuning on live.
    - **Built (steps 1–3 on the server, plus the client cards and the Discord threads):**
      - `systems/078-wildLegendaries.lua` with all the settings in `WildLegendaries.CONFIG`.
        The `serverExpEvent` globalevent runs it every second; the `wildLegendaryHit` and
        `wildLegendaryDeath` creature events record hits and hand out the rewards. The next
        spawn, the cooldowns and the open encounters are global storages 7140–7146.
      - Anchor points: `config/legendaryAnchors.lua`, made by
        `scripts/make-legendary-anchors.py` from the area names and the map spawns (no
        water species' spawns, outdoor only for the Kanto pool): 1,150 Kanto points plus
        the 13 home areas. A move looks for a free tile up to 3 tiles from the point.
      - The 5-trainer population row is set to 1 while we test.
      - Health: 30 times (tier 1) and 60 times (tier 2) the monster file's health, for the
        encounter only. Signature moves and area attacks are not built yet.
      - Notifications: server-wide messages, a locked **Legendaries** chat channel (id 14,
        shows what's out when you open it), Discord `legendary` events (see
        `docs/discord-bridge.md`) and pop-up card data on extended opcode 34
        (`EXTENDED_IDS.LEGENDARY`: `spawn`, `sighting`, `flee`, `end`, `caught` and the
        personal `reward`). The world map pin comes with step 4.
      - Client cards (`game_eventcards`): a big banner for the spawn (strength tier,
        recommended level, time until it flies off) and for your reward (Rare Candies,
        money, the Pokepedia defeat), and small cards top right for sightings (one per
        species every 5 minutes), flees, the end and catches. They wait for the level-up
        and evolution banners. Options > Interface > "Show event pop-up cards" turns them
        off; the chat messages still show. The 10% damage rule is explained in the
        Pokepedia wiki ("Wild legendaries") instead of on the banner.
      - Discord: the bot keeps one post and thread per encounter in `#legendary-spawns`.
        The bot repo can't be pushed from here, so the change is kept as patches in
        `integrations/pokeverse-discord/` (it needs two new bot permissions).
      - The body: the monster's own corpse, kept 3 minutes; the top damage dealer has it
        alone for 60 seconds. Only damage from a trainer's Pokémon (or balls) counts toward
        the share. Mewtwo's monster file had no corpse; it now uses "fainted mewtwo".
      - Staff: `/legendary status`, `spawn <name> [here]`, `end <name>`, `next <time>`
        (`30s`, `5m`, `2h`, `1d`) and `cooldowns clear [name]`.
      - Tests: the legendary part of the vocation test talkaction, with a real Mewtwo defeat.
    - **Revamped (stage 1 of [section 22](#22-legendary-revamp-stages-1-to-3-built)):** the Kanto-only
      pool, the half-home rule and the roaming above are replaced by habitats in four regions
      and a way of moving per species; the limits, timers, flee, healing, health, rewards and
      notifications stay. No spawns in the 10 minutes before the daily restart (was 2 hours),
      and the ones still out are saved and come back after it.
  - **The bird dungeons stay as they are:** they are the end of the Ancient Times quest,
    one bird per trainer, once, and not a repeatable raid.
  - Related: the radar test's Articuno did not spawn when the test spot was a small upper
    floor (5017, 790, 6 on Tutorial Island), because no tile 12–16 tiles away was walkable;
    the test now also tries nearer spots.
- **Footprints turn (built):** each set has a trace item per ground and direction (north,
  east, south, west) in `lib/ps/config/footprints.lua`; `scripts/add-footprints.py --turn`
  adds the turned ones (18 items, server ids 30157 to 30174) and `ds_world.py --write-prints`
  draws them turned into data.spr. `events/movements/traces.lua` picks the direction from
  `fromPosition` to `toPosition` (a diagonal by its longer side, a jump by where the walker
  faces).
- **Ranger tracking leaves footprints (built):** wild Pokémon still leave no prints, so routes
  don't fill with tracks. From rank 2 (`printsRank`), picking a blip in the radar tracks that
  Pokémon's footprints for 3 minutes (`printsSeconds`): each step it takes on dirt, grass or
  sand is sent to the tracking Ranger only (`{type = "print"}` on the radar opcode) and drawn
  by the radar module as a glowing paw print on that tile, pointing the way it went, fading
  out after 90 seconds. The ground doesn't change for anyone else, and the Pokémon is kept
  awake so it walks with nobody in view. Shinies and legendaries stay vague and can't be
  tracked this way. Stop, a new target or reaching it ends the track.

The missing clickable responses (gym leaders and others) are part of the
[NPC dialogue](#3-npc-dialogue-quests-and-tasks) work.

### Pokémon energy

Energy works today, but only for the player's Pokémon: it is the trainer's mana
(`getPokemonEnergy` in `data/lib/ps/functions/pokemon.lua`). Most species start at 100 energy
(200 for shinies) plus 10 per level, and it refills 1 per second (`XML/vocations.xml`).
Moves cost 40 to 120, most often 100 (`requiredEnergy` in `config/moves`); not enough
energy blocks the move (`003-skill.lua`). Wild and NPC trainer Pokémon have no energy,
only move cooldowns.

- **Show it clearly (done):** an energy bar right under the Pokémon's health bar, each
  move's cost on the move bar, and moves it can't afford dimmed.
- **Balance (still to check):** at level 50 a Pokémon has about 600 energy and gets 60 back a minute, so
  energy may rarely run out. Check it in the [economy audit](#14-economy-audit) together
  with energy potions and food.
- **Who has energy (agreed):** players only. Wild and NPC trainer Pokémon keep just
  cooldowns: energy would make them stop attacking and easier to beat, and they would
  need an AI that manages it.

## 12. Level requirement audit

**Done:** every "Now" level below is in the game, with the unlock ladder.

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
| Tournaments | by Pokémon level (0–100, 20–40, 41–50, 45–100, 50–100, 51–65, 66–80, 80–100); trainer level at least the minimum + 5 (`level - 5 < minLevel` refuses); Elite and Master are commented out | `XML/tournaments.xml`, `npc/scripts/tournament.lua` | keep |
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
(`activationTile.lua`). The Wiki Chat channel that opened at login below level 30 is gone;
the Pokepedia's Wiki tab has the new levels.

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

**Level-up banner (fixed):** `LevelUpBanner.UNLOCKS` in `lib/ps/systems/063-levelUpBanner.lua`
still had the old levels (daycare 85, Safari Zone 30, tournaments at the Pokémon minimum, the
switched-off Elite and Master tournaments). It now follows the real checks: Safari Zone 15,
daycare 20, houses and Starter tournament 25, guilds 30, Pro tournament 46, Epic tournaments
50, Titan and Mastery tournaments 85, Elite Four 95. The Wiki's "Trainer levels" and
"Tournaments" pages match. Not in the banner yet: slot machine, tasks, wave arena, the
vocation quest and the Frontier Island arenas.

**To decide:** whether the Elite Four moves to 80, and what the level 70 quest group is (76
quests at the same level). The daycare stays Premium (agreed with the Breeder perks).

## 13. Switch off the old PSoul and anniversary content

Switch off, but keep, the content left from PSoul (the original game) so it can be reused
for PokeVerse later. Do not delete it.

- **PSoul:** about 18 files mention it, including quests (`quests.xml`, the
  `quest_chief*` and `quest_prophetSlowking` NPCs, `legendaryChest.lua`), achievements,
  Pokémon addons and the Logan NPC. The old psoul.net links (welcome popup, server URL,
  owner email) are already gone; the rest is still on.
- **Anniversary and birthday events:** done differently. The anniversary content (the cake
  raid, the surprise bags, the magic flame) now only runs during the anniversary on the event
  calendar (Oct 3 to 5), and the Easter, July, Halloween and Christmas content only on their
  dates (see section 15). Before, the surprise bags dropped all year and the hourly
  anniversary raid failed (`executeRaid` did not exist).
  The cake town itself is closed too: its only way in, the sign and teleport in the Union Room,
  is only there during the Anniversary. When it ends, players in the town are sent back, the
  cakes are removed and the town is put back. Staff can show the entrance to test it
  (`/anniversary show [minutes]`, `hide`) or force the whole event (`/anniversary on|off|auto`),
  also from the Admin window's Server tab.
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
| Selling Pokémon to the NPC | catch difficulty × $10 (× 2 for shinies) + $5 a level, from the party or straight from the PC boxes in the Pokémon Trade window | `getPokemonPrice`, `PokemonShop` (`081-pokemonShop.lua`, client `game_pokemonshop`) |

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

- **Daily login reward (built,** `lib/ps/systems/065-dailyLogin.lua`, client
  `game_dailylogin`**):** a 7-day streak that repeats: a reward for each day in a row, rare
  candy on day 7, then it starts again at day 1. A missed day resets the streak. A red flag
  on the top menu button shows while today's reward is unclaimed.
- **Event calendar (built,** `lib/ps/systems/077-eventCalendar.lua`, `/calendar`, client
  `game_calendar`**):** holidays, staff events and the moon on one calendar. Still to build:
  the website page and the Discord bot posts.
  - **Banner:** next to the clock on the top bar (or under the HUD). While an event runs it
    shows the event in its colour and the time left (`Anniversary: 1d 4h left`, `+1 more`
    when several run); when nothing runs it counts down to the next one
    (`Next: Halloween in 7d 1h`). The tooltip has the details; a click opens the window.
  - **Window:** a month grid (Monday first) drawn by code for any month, with the moon phase
    on each day, the events as coloured strips, and a list of the month's events beside it.
    Clicking a day lists that day's events. Times show in the player's own time zone.
  - **Rules instead of dates:** once, every weekend, the nth or last weekend of a month,
    every year on a date, or a computed holiday. A **weekend** runs from Friday 17:00 to
    Monday 05:00 (server time, `LIVE_TIMEZONE`; not tied to the midnight restart). Staff events are rows of the `event_calendar` table
    (`schemas/pokeverse-extensions.sql`), added in game:
    - `/calendar` lists the next 30 days, `/calendar list` the staff events,
      `/calendar remove <n>` removes one.
    - `/calendar add once 2026-11-06 18:00 2d exp=2 Double Friday`,
      `/calendar add weekend exp=1.5 Double Weekend`, `/calendar add weekend last loot=2 Loot Weekend`,
      `/calendar add yearly 12-24 18:00 1d shiny=2 Christmas Eve`.
    - Bonuses: `exp`, `shiny`, `loot`, `breeding` (Day Care egg chance) and `fishing` (bites),
      above 1x and up to 10x each.
    - `/calendar holiday <id> on|off|auto` forces a holiday on or off, or back to its dates.
    - Changes take effect within a minute; starts and ends are broadcast.
  - **Events stack** and multiply, also with `/doubleexp`, `/bonusshiny` and the trainer's
    own boosts. Loot needs the new server build (`setLootEventMultiplier`).
  - **Holidays are automatic.** Each one starts and ends at 06:00 unless noted (the midnight restart doesn't move it).
    Dates in brackets are 2027's.

    | Holiday | When | What happens |
    |---|---|---|
    | New Year | Dec 31 to Jan 2 | 1.5x EXP, a gift on login ($10,000 and a rare candy) |
    | Lunar New Year | 3 days from the second new moon after the winter solstice (Feb 6) | 1.5x loot, a red envelope on login ($8,888) |
    | Valentine's | Feb 13 to 15 | 2x Day Care egg chance, 1 in 4 fishing bites are Luvdisc, a rare candy |
    | Pokémon Day | Feb 27, one day | 2x shiny, a rare candy |
    | Easter | Good Friday to Easter Monday (Mar 26 to 29) | the existing egg drops and Easter spawns (`030-easterEvent`) |
    | Summer Festival | July 1 to 31 | 1.5x fishing bites, the existing reward chests (`055-julyVacationEvent`) |
    | Harvest Moon | the day before the full moon nearest the autumn equinox to the day after (Sep 14 to 16) | berry trees grow twice as fast and give up to 8 berries, 5% of wild Pokémon drop a berry, seed boxes give twice the seeds |
    | Clefairy Night | every full moon, 20:00 to 06:00 server time | 2 Clefairy and a Clefable at 8 spots in Mt. Moon, 2% Moon Stone from each |
    | Anniversary | Oct 3 to 5 (the anniversary is Oct 4) | 2x EXP, 2x shiny, the old anniversary content (cake raid, surprise bags, see section 13), a gift on login (a cake and a rare candy) |
    | Halloween | Oct 24 to Nov 1 | the existing Halloween drops and spawns, and a Halloween raid every 45 minutes |
    | Christmas | Dec 18 to 27 | the existing presents and Christmas spawns, and a Christmas raid every 35 minutes |

    - Moon phases use the standard astronomical formula (Meeus), accurate to minutes. Easter
      uses the Western computus.
    - Each holiday gift is given once per occurrence, at login or when the holiday starts.
    - The old holiday content (Easter, July, anniversary, Halloween and Christmas drops,
      spawns and raids) used to run all year or not at all; it now only runs on its dates.
    - Not built from the first plan: the "spawns up" for types (Dragon, Water, Grass, Ghost,
      Ice), fireworks at midnight and higher starter catch rates.
- **Seasons and weather (agreed October 2026; build steps 1 to 4 done):**
  - **Built so far** (needs the new server build and a client release):
    - **Seasons:** `EventCalendar.currentSeason` / `seasonId` in `077-eventCalendar.lua`. The
      season starts at 06:00 after its equinox or solstice (2026: Mar 21, Jun 22,
      Sep 23, Dec 22), and its start is announced. `/calendar` names it, and
      `/calendar season <spring|summer|autumn|winter|auto>` forces one. The calendar window
      shows the season in its header, a coloured band under every day and an icon on the
      day a season begins; the banner tooltips name it.
    - **Weather** (`lib/ps/systems/079-weather.lua`): every town with a temple in a live
      region is a zone, and a spot belongs to the nearest town of its region. Kanto is
      temperate, Hoenn warm, the Orange Islands tropical and Desert Island 92 a desert; some
      towns change the odds (sandstorms at Mauville and Pewter, fog at Lavender and
      Fallarbor, rain at Fortree, sun at Lavaridge and Cinnabar). Johto's zones are listed
      but stay calm until `live = true`, with their odds ready: wind at New Bark, Violet,
      Olivine and Blackthorn, rain at Azalea, fog at Ecruteak, storms at Cianwood, snow and
      hail at Mahogany and snow at Blackthorn. The Tutorial has no weather.
      - Each zone's weather lasts 20 to 60 minutes, rolled from the climate's odds for the
        season. The roll is a seeded hash of the zone and the time, so every Lua state gets the
        same answer without sharing anything; only staff weather is stored (global storage 7151).
      - Snow on Christmas Day (not in the tropics or the desert) and fog on Halloween night.
        There's no harsh sunlight at night: it's "Clear night" instead.
      - `/weather` (or `/weather status`) shows the season, the zone you stand in, and the
        weather of every zone. `/weather <town|region|all|here> <kind> [minutes]` sets it,
        `... auto` gives it back to the roll, and `/weather off` clears all staff weather.
        `/weather time <day|night|dawn|dusk|HH:MM>` moves the game clock, to test the light.
      - Clients get it on extended opcode 35 (`{type = "weather", ...}`) at login and when it
        changes.
    - **Light:** each weather lets a share of the day or night light through and can tint it
      (`KINDS[kind].light`): rain 80%, thunderstorms 62% with a blue tint, fog 85%, hail
      80%, sandstorms 84% with a sand tint, snow 106%, harsh sun 110%. The server sends it per
      player (`doPlayerSetWeatherLight`, applied in `ProtocolGame::AddWorldLight`), so the
      night stays dark and a storm makes the day dim. Characters with the `HasFullLight`
      flag (gods) and clients with the Lights option off don't see the darkening.
    - **Client** (`modules/game_weather`): a map shader for each weather (rain, thunderstorm,
      snow, hail, fog, sandstorm, strong winds, harsh sunlight), drawn only where the sky is
      open over the player (no floor above, the same rule as the server). Thunderstorms flash
      the screen and play thunder; rain, storms and wind have looping sounds. A weather icon
      sits next to the area name; its tooltip gives the zone, the time left, the move changes,
      the chip damage or fog note, and the season.
      - Options (Interface): Show weather on the map, Lighter weather effects (half
        strength), Weather sounds (at the Ambience volume) and Lightning flashes. They only
        change the look; the light and the battle effects still apply.
    - **Battle** (outdoors only; `Weather.CONFIG` turns each part off):
      - Move power: harsh sun Fire x1.2, Grass x1.1, Water x0.8; rain Water x1.2, Fire x0.8;
        thunderstorms Electric x1.2, Water x1.1, Fire x0.8; fog Ghost and Dark x1.1; strong
        winds Flying x1.2; snow Ice x1.2, Fire x0.9; hail Ice x1.2; sandstorms Rock x1.2,
        Ground x1.1. Applied in `004-skillDamage.lua` after held items.
      - Hail and sandstorms take 3% of max health every 10 seconds from trainers' Pokémon
        (never the last point). Ice types are immune to hail; Rock, Ground and Steel types to
        sandstorms.
      - Fog: moves used from 2 or more tiles away miss 10% of the time.
      - Moves bar: a move the weather changes gets a small weather icon on its slot (green
        border for stronger, red for weaker) with "Rain: 20% stronger" in the tooltip. The
        shift-click move card lists the weather in its power breakdown.
    - **Decorations** (`lib/ps/systems/080-decorations.lua`): up to 6 props around each live
      town's temple, put down at startup and swapped within a minute or two when the season
      or a holiday changes. Spots are picked by script: open sky, nothing on the tile, and
      every tile within 2 walkable, so a prop never closes a path or stands at a door; props
      stand 3 tiles apart. They're script protected (players can't move or pick them up, and
      `/clean` leaves them), and nothing is saved, so a restart starts from a clean map.
      - Christmas: a Christmas tree on the spot nearest the temple, a wreath, snowmen and
        heaps of snow (no snow in tropical and desert towns). Halloween: jack-o'-lanterns
        and skull candles. Winter: snowmen, snowy dead trees and heaps of snow (not in the
        tropics or the desert). Spring: flowers. Autumn: pumpkins, wheat, hay and mushrooms.
        Summer has none.
      - Every other holiday has its own set too, and it goes up on its own when the holiday
        starts: New Year (party cakes, a Pikachu doll, teddy bears, roses), Lunar New Year (red
        lanterns, a dragon flag, red roses), Valentine's (heart pillows, roses, teddy bears),
        Pokemon Day (Pokemon dolls around a Pikachu), Easter (eggs and tulips), Summer
        Festival (sunflowers, sea stars, Lapras and Seel dolls), Harvest Moon (pumpkins,
        wheat, hay, moon flowers), Clefairy Night (Chansey and Jigglypuff dolls, moon
        flowers, meadow stars) and Anniversary (a party cake by the temple, Mew, Pikachu and
        Bulbasaur dolls, roses).
      - When two holidays overlap, the first in this order wins: Christmas, Halloween, New
        Year, Lunar New Year, Valentine's, Pokemon Day, Easter, Anniversary, Summer
        Festival, Harvest Moon, Clefairy Night. A holiday's set always beats the season's.
      - **Props placed by hand** (God accounts): stand facing a tile or a wall and save a prop
        for a set, with `/deco add <set> <prop name or id>` or the Admin window's
        Decorations tab (pick the set and the prop, press Place in front of me). Each one is
        a row in the `decoration_spots` table (set, tile, item, who and when), so it survives
        restarts and updates and goes up every time its set is up, next to the automatic
        props; there's no config file to edit. Wall props (Christmas wreath, red and blue
        garlands, skull, purple, red, blue and white tapestries) hang on walls with a hook,
        from the side the prop shows on: a wall running east-west from the south, one running
        north-south from the east. The Pokemon Center walls have hooks too (set with
        `scripts/item-hooks.py`, in items.otb and the client's data.dat);
        everything else stands on a tile a player could walk on, never on a house or a
        depot tile. A tile holds one prop per set: saving another replaces it.
      - `/deco` shows the set up now, the town's automatic props and the props saved within
        12 tiles (a prop that no longer fits, for example after a map change, is flagged).
        `/deco remove [set]` deletes the prop on the tile you face, `/deco list`,
        `/deco sets` and `/deco items <set>` list them, `/deco preview <set> [minutes]` puts
        a set up for everyone for a while (30 minutes by default, `/deco preview off` ends
        it) and `/deco auto <on|off>` leaves a town to its hand-placed props only. The Admin
        window has a button for each.
    - Tests: the season, weather and decoration parts of the vocation test talkaction.
  - **Seasons follow the real calendar** (northern hemisphere), not a sped-up cycle, so it's
    never summer at Christmas. Spring starts at the March equinox, summer at the June
    solstice, autumn at the September equinox and winter at the December solstice. The
    event calendar already works out these dates (`EventCalendar.seasonTime` in
    `077-eventCalendar.lua`). The season changes at 06:00 after the date.
    The calendar shows it as a long band, the banner names it, and staff can force one
    (`/calendar season winter`) to test or for an event.
  - **Seasonal Pokémon:** a table of swaps applied in the C++ spawner (`Spawn::spawnMonster`,
    where the shiny roll is). In winter, some share of a species' spawns becomes another
    species, so the swapped Pokémon spawn in sensible places and the map's spawn file
    doesn't change. The shiny roll still applies. First ideas, all already in the game:
    - Spring: Hoppip, Skiploom, Jumpluff, Oddish line and Bellossom, Ledyba, Volbeat and
      Illumise, Lotad, Surskit.
    - Summer: Sunkern and Sunflora, Wingull and Pelipper, Corsola, Mantine, Remoraid,
      Chinchou, Tropius; more Water types at sea.
    - Autumn: Seedot, Shroomish, Pineco and Forretress, Teddiursa, Stantler, Murkrow,
      Misdreavus, Hoothoot and Noctowl, Houndour, Phanpy.
    - Winter: Swinub and Piloswine, Snorunt and Glalie, Sneasel, Delibird, Smoochum and
      Jynx, Seel and Dewgong, Shellder and Cloyster, Spheal, Lapras.
    - These count for the Pokepedia, tasks and the radar like any other spawn.
  - **Weather all year, weighted by the season.** Weather is random all year round, not
    only in its season. The season only changes the odds (snow is common in winter, rare
    in late autumn and never in summer).
    - Kinds: clear, sunny (harsh sun, heat haze), rain, thunderstorm (rain with lightning
      flashes and thunder), fog, snow, hail, sandstorm (only in desert areas and on rocky
      routes) and windy (leaves or petals blowing, depending on the season).
    - Regions: every region gets weather, not only Kanto: Kanto, Johto, Hoenn and the
      Orange Islands (Johto since October 23, when it opened).
      The zone list is per region, so adding a region is a data change, not new code.
    - Zones: each region's outdoor areas are grouped into a few weather zones (by area
      name, as on the area banner), so it can rain on Route 1 while Cerulean is sunny. Buildings,
      caves and dungeons have no weather. Each zone rolls its next weather every 20 to 60
      minutes, using that season's odds and the zone's own rules (no snow at sea in
      summer, sandstorms only where there's sand).
    - Client: the existing map shaders (`game_shaders`: Rain, Snow, Fog, Heat) plus new
      particle effects (raindrops, snowflakes, leaves, lightning flashes on the screen,
      thunder sounds) only outdoors. There's a weather icon next to the area name; hover
      it to see the weather and the effects that apply. The server sends the zone's
      weather on login and when you enter a new zone (a new extended opcode).
    - Player options: show weather effects (on, light, off), weather sounds, and flashing
      lightning (off for people sensitive to flashes). Options only change the look; the
      gameplay effects still apply.
  - **Weather settings that change other systems.** All in one config table on the server
    (`CONFIG.effects[weather]`), so each effect can be tuned or turned off without touching
    code:
    - Battle (like the main games): rain makes Water moves 20% stronger and Fire moves 20%
      weaker; harsh sun does the opposite. Thunderstorms make Electric moves 20% stronger.
      Hail and sandstorms deal a little damage every few seconds to Pokémon that aren't
      Ice (hail) or Rock, Ground or Steel (sandstorm). Fog lowers the accuracy of ranged
      moves a little.
    - Moves bar: a move that the weather makes stronger (or weaker) gets a small weather
      icon on its slot (a raindrop, sun or lightning bolt, green for stronger, red for
      weaker), next to the type matchup arrow. Hovering it says why ("Rain: Water moves
      +20%"), and the shift-click move card shows the weather in its power breakdown.
    - Spawns: each weather has a list of species that spawn more often, through the same
      swap table as the seasons (Water and Bug types in rain, Electric types in
      thunderstorms, Ghost types in fog, Ice types in snow and hail, Ground types in
      sandstorms, Fire and Grass types in sun).
    - Castform changes form to match the weather (Rainy, Sunny or Snowy).
    - Fishing: rain and thunderstorms make bites a little faster.
    - Ranger radar: fog cuts its range by a quarter.
    - Events: staff can set the weather for one zone or everywhere for a while
      (`/weather <zone|all> <kind> <time>`, `/weather status`, `/weather off`), and
      holidays or events can set it too (snow on Christmas Day, fog on Halloween night).
      Daily tasks and quests can ask for a weather ("catch a Water type in the rain").
  - **Seasonal decorations (server, at the restart):** placed and removed by script at
    fixed spots, like the Clefairy spawns: snowmen and snowy fir trees in towns in winter,
    a Christmas tree in each town over Christmas, jack-o'-lanterns at Halloween, flowers
    in spring and leaf heaps in autumn.
  - **Not planned for now:** changing the map itself (snowy ground or new tiles in winter).
    It could come later as a mapper's winter copy of chosen areas, applied at the restart.
  - **Season events:** a holiday can depend on the season (the Harvest Moon is already the
    autumn full moon), and staff events can be limited to a season.
  - **Build order** (1 to 4 done):
    1. The season in the calendar, with the staff command.
    2. Basic weather: zones for Kanto, Hoenn and the Orange Islands, the timer, the client
       effects and icon, the options and `/weather`.
    3. Decorations, in every live region.
    4. Battle effects, with the weather icons on the moves bar.
    5. Spawn swaps, first for weather, then for seasons, and Castform.
    6. Fishing, radar, tasks.
    7. Johto's zones (done, October 23) and decorations.
- **Double EXP:** already exists. `/doubleexp 2h` starts 2x for 2 hours, and
  `/doubleexp 5x 1d` starts 5x for a day: any multiplier above 1x up to 100x, from 1 minute
  to 7 days; `/doubleexp off` and `/doubleexp status` too
  (`data/lib/ps/systems/058-serverExpEvent.lua`).
- **Shiny event:** done. `/bonusshiny 2x 2h` makes every shiny roll that many times more
  likely (1 in 8,192 becomes 1 in 4,096 at 2x), with the same arguments as `/doubleexp`;
  `/expevent` lists it. Map spawns roll in C++ (`src/spawn.cpp`, `getShinyEventMultiplier`),
  and fishing, Safari fishing, headbutt, eggs, incubators, abilities and `doCreateMonster`
  roll through `ShinyEvent.chance` (`data/lib/ps/systems/073-shinyEvent.lua`). Needs the
  new server build.
- **Day Care events:** done. `/bonusdaycare 3x 2h` multiplies the training EXP Pokémon
  get in the Day Care, and `/bonusbreeding 2x 1d` multiplies the daily early egg chance
  (from day 7). Same arguments as `/doubleexp` (up to 100x, 1 minute to 7 days, `off`,
  `status`); `/expevent` lists them too. Training EXP only counts the minutes that
  overlap the event. Code: `data/lib/ps/systems/072-daycare.lua`,
  `talkactions/scripts/daycareevent.lua`.
- Both events are announced in game and on Discord, and show on the calendar.
- **Admin window:** done. A crown button on the top bar for every staff account (access 1
  and up). Each staff member sees the tabs and buttons their rank can use:
  - **Events** (access 3; starting events and the calendar need 5): start, replace or stop
    the four events above (1.5x to 10x, 30 minutes to 7 days), force a season or a holiday
    or put it back to its dates, and broadcast in game, to Discord or both.
  - **Players** (access 1): the players online with a search, and for the player you pick
    or type: go to, bring here, kick, chat ban, info, notations, ban info, unban,
    promote/demote and send to a town's temple. Ban the account for 1, 3, 7 or 30 days or
    for good with a reason and a comment (access 3); the banned player is disconnected.
    The banned accounts are listed with an Unban button.
  - **World** (access 5): set the weather here, in a region or everywhere for a while or
    until auto, clear it, move the game clock, and spawn, send away or check the wild
    legendaries.
  - **Decorations** (access 5): save props by hand for a set on the tile or wall you face,
    remove them, preview a set, turn a town's automatic props on or off, and list the
    props saved near you (see Decorations above).
  - **Server** (access 3 and 5): save, clean the map, restarts, close or open the server,
    PvP mode, ghost and the other staff toggles, and reload any part of the scripts.
  - **Commands** (access 1): every staff command the staff member can use, by group, with
    its usage and what it does; typing filters the list and Run runs it.
  The buttons run the staff commands themselves, so talkactions.xml's access decides and
  the answers show in the Server Log; the server also checks the access on every action
  and logs it. Code: `data/lib/ps/systems/074-admin.lua` (opcode 30), `modules/game_admin`.

## 16. Reports and feature requests to Discord forums

An in-game window to send a bug report, a feature request or a player report. Each one
becomes a post in a Discord forum channel, with tags.

- **Done (bug and player reports):**
  - The Reports window has Bug, Player and My reports, with an optional screenshot. The staff reader has filters (status, kind, taken by me, not taken), a teleport to the spot, notes and statuses, Take, Merge as duplicate (both reporters get the answer) and a screenshot viewer.
  - The staff world map shows open reports as marks.
  - The bot posts each report in `#bug-reports` or the private `#player-reports` forum. It pings the linked reporter, attaches the screenshot and adds a line for every update.
  - A status tag picked on Discord answers the report in game.
  - Bot patches: [`integrations/pokeverse-discord`](../integrations/pokeverse-discord/README.md#report-forums).
  - Feature requests and voting are still to do.
- **Before:** the client's bug report (`onReportBug`,
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

- **Tap = smart left click (done):** with no shortcut button selected, a tap talks to an
  NPC, attacks a Pokémon, uses an object (lockers and other containers too), walks there or
  looks, the same as smart left click on the computer.
- **Long press = right click (done):** a long press (over 0.5 s) opens the menu
  (`src/framework/platform/androidwindow.cpp`). Still to add: a small vibration or circle so
  the player knows the menu is coming. Double tap is not recommended: every single tap would
  have to wait to see if a second one follows, so walking and attacking would feel slow.
- **Volume buttons (done):** they control the phone's media volume.
- The shortcut buttons keep working for look and follow.
- **Map shape (done):** the map keeps 23x13 tiles on wide phones, and the game stays in
  landscape (`sensorLandscape`).
- **Joystick (done):** hold its middle to drag it anywhere (kept per device); Reset joystick
  on the Help page puts it back. The chat buttons sit clear of the move bar.
- Still to do in the phone UI pass: button sizes and windows that don't fit the screen.

## 18. Ideas (not agreed)

Features other Pokemon games and MMOs have that PokeVerse doesn't yet. All are **To decide**.
Sizes are rough: small is a few files on one side, large touches the server, client and map.

Already in the game, so not listed here: gym rematches (pay the leader again), TV broadcasting
to watch a player, parties with shared EXP, guilds and guild halls, the VIP list, parcels and
letters, referrals, Pokedex achievements (1, 50, 100, 200 and 251 species), nicknames at the
soul coin NPCs, Fly, world bosses, wild legendaries and legendary dungeons, the Elite Four, the
Frontier Island battle tower, tournaments, duels with bets, Safari, fishing, Headbutt, eggs,
berries and the GTS. Making some of those nicer is in the
[modernization audit](modernization-audit.md) instead.

**Johto**
- **Bug-Catching Contest** in the National Park (Tue, Thu and Sat): 20 minutes with lent Sport
  Balls and one Pokemon, judged by species, level, IVs and HP left, with prizes for the top
  three. Builds on the Safari check-in and the event calendar. Medium.
- **Kurt's Apricorn balls:** pick Apricorns from trees around Johto (the berry code) and the
  Azalea ball maker turns them into Level, Lure, Moon, Fast, Friend, Heavy and Love Balls, each
  with its own catch rule. The Kurt in the game today is a newspaper quest. Medium.
- **Ruins of Alph:** the Unown slide puzzles, each opening a chamber where more Unown forms
  appear. Medium.
- **Red on Mt. Silver:** a post-game duel after the 16 badges, with a weekly rematch. Red exists
  today only as the tutorial guide. Small, with the gym leader code.

**Battle**
- **Ranked PvP ladder:** queue from a window, Elo seasons that follow the calendar's seasons,
  season rewards (an outfit, a ball paint, a title) and the ladder on the website and in
  Discord. The tournaments today only have fixed times and a highscore. Large.
- **Co-op raid dens:** a party of 2 to 4 against one strong Pokemon with shields and a timer,
  and everyone who helped gets one catch try. World bosses are free-for-all with no catch.
  The dens rotate with the calendar. Large.

**Collecting**
- **Real Pokedex rewards:** items at the Pokedex achievements (they only give points now), a
  shiny charm for the full dex, and a reward for each region's dex. Small.
- **Shiny chains:** a Poke Radar chain in grass and a fishing streak that raise the shiny
  chance. Medium.
- **Move tutors and a move relearner**, in the move manager from the modernization audit.
  Medium.
- **Mystery Gift codes:** staff make codes in the Admin window that players redeem for items,
  Pokemon or outfits, for Discord giveaways. Small.
- **Season pass:** a free and a premium track per season, filled by the daily and weekly
  tasks. Premium uses soul coins (the Store is built). Large.

**World**
- **Team Rocket takeovers:** a calendar event where Rocket holds a town, with waves of grunts,
  an Executive boss and a reward bar for the whole town. Today the grunts only wander near
  their hideouts. Medium.
- **Voltorb Flip** at the Game Corner, next to the slot machines. Small.
- **Photo mode:** hide the UI, add a frame and save the picture for Discord. Small.
- **Pokemon that follow you** in towns, just for looks. Medium, mostly client work.

**Quality of life**
- **Sort and bulk actions** in the PC and the bag (sort by number, level or type; release or
  move several at once). Small.

## 19. Accounts, Soul Coins and the Store

Planned October 20, for going public. Phases 1 to 3 are built: password security (PR #167),
accounts and email (PR #168) and the Store (PR #163). Phase 4, buying Soul Coins, is not.

### Now

- **Signing up** needs an email and the 6-digit code sent to it; older accounts have 7 days
  to add one. Forgot password is on the login screen, and the Account window (character list)
  changes the password or the email and links Discord. Mail goes through Gmail on the live
  server (`GMAIL_ADDRESS`, `GMAIL_APP_PASSWORD`).
- **Passwords** use PBKDF2-SHA256, upgraded at each player's next login. The live server uses
  the PokeVerse login key; 10 wrong passwords in a row lock the account for 15 minutes.
- **The Store** (`game_soulstore`, `084-store.lua`) sells everything the Soul Coin NPCs did,
  with Withdraw and Deposit. The Soul Coin NPCs are off the map (commented out in
  `map-spawn.xml`). Buying Soul Coins with PayPal is not built.

### Before (October 20)

- **Creating an account** asks only for an account name and a password (3 accounts per IP
  per hour). The `accounts.email` column exists but is never filled. There is no email,
  verification, password reset or 2FA; the only recovery is the Account Manager's recovery
  key.
- **Passwords** are stored as plain SHA-256 with no salt (`encryptionType` in
  `core/server/config.lua`).
- **The login encryption key is the default Open Tibia RSA key,** whose private half is
  public (`core/server/src/otserv.cpp`, and `OTSERV_RSA` in the client's
  `modules/gamelib/const.lua`). Anyone who records a player's login traffic can read the
  password.
- **Logins** lock for a while after 10 wrong tries from one IP; nothing locks per account.
- **Soul Coins** are an account balance (`accounts.soulcoins`) and an item (6500). Nothing in
  the game adds to the balance. 23 NPCs use `soulTrade.lua` (Premium, Pokemon addons, sex
  change, nickname, stamina, egg move capsule, guild), paid with the item; the full list is
  under phase 3.
- **The Store button** says "coming soon". There is no PayPal or donation link anywhere.

### Decided

- **Email is required.** One email per account (an account already holds 3 characters).
  New accounts type a 6-digit code from the email into the create-account window before they
  can play, with Resend code and Change email buttons. Signups not verified within 24 hours
  are deleted, which frees the name and the email.
- **Existing accounts** get a window at login to add and verify an email. It can be skipped
  for 7 days, then it is needed to enter the game.
- **Buying Soul Coins needs a verified email.**
- **Email is sent through `thepokeversemmo@gmail.com`**, a free Gmail address made for the game, with an App Password
  (`smtp.gmail.com`, port 587). It can move to Google Workspace later (Business Starter, $7
  a month on a yearly plan or $8.40 monthly, one user plus free aliases) for mail from
  `@pokeverse.quest`; only the account service's settings change. A free Gmail address sends
  to about 500 people a day.
- **PayPal only.** No Google Play: the Android app stays a download from the website, GitHub
  and itch. Soul Coins are sold as digital goods with PayPal Checkout on a PayPal Business
  account, not with a Donate button (PayPal's donation tools are not for things given in
  return).
- **Soul Coins work like a bank,** as they always have: bought coins go onto the account's
  balance (`accounts.soulcoins`, shared by its 3 characters), and **Withdraw** turns them
  into the coin item (6500) in the bag. **Deposit** (new) puts coin items back on the
  balance. The item trades and sells on the market like any item, so players who don't buy
  coins can still get them. Balances players have today stay as they are.
- **The balance changes in one database step (agreed fix).** Today's withdraw reads the
  balance and then writes it back, so anything else changing it in between is lost (for
  example coins bought with PayPal landing at that moment). Withdraw, deposit, Store
  purchases and the PayPal credit each check and change the balance in a single update that
  can't go below zero. Only one character per account can be online
  (`onePlayerOnlinePerAccount`), except staff accounts.
- **The Soul Coin NPCs are removed** in favour of the Store, along with their mentions in
  the wiki and quest hints. The vitamin reset (Josh Pillberg, 1 SC) moves to the Store too.
- **Premium:** 15 SC for 30 days and 40 SC for 90 days. Other Store prices stay as the NPCs
  have them unless changed.
- **Coin packs,** cheaper per coin the bigger they are:

| Pack | Price | Per coin | Discount |
| --- | --- | --- | --- |
| 15 SC | $7.50 | $0.50 | none |
| 40 SC | $18.00 | $0.45 | 10% |
| 85 SC | $36.00 | $0.42 | 15% |
| 160 SC | $64.00 | $0.40 | 20% |

At these prices 30 days of Premium is $6 to $7.50, against about €10 in Tibia. The smallest
pack stays at $7.50 or more because PayPal takes roughly 3.5% plus about 50 cents on each
payment. Packs and prices live in one list on the server, so they can change without a
client update.

### Phases

**Build order (agreed October 20):** the
[Poke Mart window](#order) (item 10) first, then the Store (phase 3), then
phases 1 and 2 together. Buying Soul Coins (phase 4) comes later. Each is its own PR.

1. **Password security** (built, PR #167; [live-server.md](live-server.md#login-key) has the
   details). The live server accepts only the PokeVerse key; local servers keep the open key.
   Passwords use PBKDF2-SHA256 from OpenSSL, which the server already links (decided October
   21). Argon2id stays a possible later change: it needs libsodium on every server build and
   running `bootstrap-ovh.sh` again on the live server. As planned:
   - **A PokeVerse RSA key (agreed).** A new key pair for the live server. The private half
     lives only on the live server, in a file the server reads at start (outside the
     repository, like the other live secrets); local test servers keep a test key. The
     clients get the new public half. Old clients can't log in once the server switches, so
     the Client release goes out first and the Live server deploy right after; the updater
     doesn't use the key, so players update as usual and then log in.
   - Passwords upgraded the next time each player logs in (built with PBKDF2-SHA256, see
     above; the plan said Argon2id).
   - At least 8 characters and no very common passwords. An account locks for 15 minutes
     after 10 wrong passwords from any IP.
2. **Accounts and email** (built; [live-server.md](live-server.md#account-emails) has the
   details). It lives in the game server's account protocol, which already creates accounts,
   with a mail thread that sends through Gmail; `account.pokeverse.quest` comes with
   phase 4. Still to do: the security log lookup in the Admin window, removing the Account
   Manager's password and recovery key keywords, and the Privacy Policy and Terms. As
   planned:
   - ~~A small account service on the OVH server~~, reached only on the server itself like the
     Discord bridge, and through Cloudflare at `account.pokeverse.quest` for PayPal later.
   - Email and Confirm email when creating an account, and the verification code.
   - Forgot password on the login screen: a code by email, then the new password, in the
     app. The answer is the same whether the account exists or not. The recovery key stays
     as a backup.
   - An Account window in the app: change password, change email (needs the password and a
     code sent to the old email), resend the code, and whether a recovery key and a Discord
     link are set. It replaces the Account Manager's password and recovery key keywords.
   - Emails when the password or email changes.
   - New tables for the codes (stored hashed, 15 minutes, 5 tries) and a security log of
     logins, failures and changes, which staff can look up in the Admin window.
   - Privacy Policy and Terms (with a refund policy and a minimum age) on the website.
3. **The Store** (built, PR #163: `game_soulstore` and `lib/ps/systems/084-store.lua`; the
   Blessing stays out, Stamina Recover is the Spirit Tonic, and the first Trainer Outfits are
   Business, Rider and Shiny Poke Maniac at 15 SC):
   - The Store window from the top bar, laid out like Redemption's own store (categories
     on the left, the offers in the middle, the chosen offer on the right) in the PokeVerse
     colours. Categories: Featured (first: discounts, limited editions and the holiday
     outfits while their event runs), Premium, Pokemon Addons, Trainer Outfits, Services,
     Consumables and Guild. Offers that need a choice, such as a Pokemon to nickname or a
     guild name, ask for it in the window.
   - **Trainer Outfits, the candidates** (**To decide:** which ones and their prices). In
     `XML/outfits.xml` but with no way to get them in the game today:
     - Rocket, Business, Rider and Shiny Poke Maniac: nothing gives them.
     - Epic: needs storage 7065, which nothing sets.
     - Poke Maniac: the reward of Snap's quest, and Snap is not placed on the map.
     - Wak Lady / Wak Lord: the quest that gave it is commented out.
     - Pirate #1, #3 and #4: rewards of Calico, Javy Dones and Ed Blackhood, none of them
       placed on the map. Pirate #2 (Nagumo Harbor, who appears during the pirate quest)
       can still be earned.
   - **Holiday outfits for Featured** (earned today with event tokens, drops or event
     rewards, only while the event runs): Halloween #1 to #7, Phantomaniac, Halloween
     Monster, Christmas #1 to #3, Santa Grinch, Elfin, Helper Grinch, Easter #1, Explorer
     (anniversary), and the Azurill/Blastoise and Pikachu/Charizard costumes (anniversary).
     **To decide:** sold only in the Store, or in the Store as well as by the event.
   - A Soul Coin bank strip at the top: the balance, Withdraw and Deposit (in place of the
     NPCs' withdraw), Buy Soul Coins (from phase 4) and the purchase history. The Bank
     window from the modernization audit can show the same strip.
   - Purchases take the balance first, then coin items in the bag, so nobody has to
     withdraw to shop.
   - One catalog on the server; each purchase takes the coins and gives the item in one
     step, so coins can't be spent twice.
   - The 23 Soul Coin NPCs removed (done: their spawns are commented out in `map-spawn.xml`).
   - **Everything Soul Coins buy today**, all of it moving to the Store (from
     `npc/scripts/soulTrade.lua` and Josh Pillberg's `vitamin_reset.lua`):

     | Offer | Today | Store |
     |---|---|---|
     | Premium | 10 SC for 30 days | 15 SC for 30 days, 40 SC for 90 days |
     | Sex change | 3 SC | 3 SC |
     | Pokemon nickname (the ball slot's Pokemon, 4 to 20 letters) | 1 SC | 1 SC |
     | Remove a nickname | free | free |
     | Vitamin reset (Josh Pillberg) | 1 SC | 1 SC |
     | Stamina recover (10 hours of stamina) | 1 SC | 1 SC |
     | Egg move capsule | 1 SC | 1 SC |
     | Create a guild (level 30) | 5 SC | 5 SC |
     | New guild rank (leaders) | 1 SC | 1 SC |
     | Pokemon addons: Fossilized Kabutops, Aerodactyl, Armaldo and Omastar, Greybeard Costume (Slowking) | 15 SC each | 15 SC each |

     Bless (1 SC) and hometown change (5 SC) are switched off in the NPC script and stay
     out. The NPCs' **referral** rewards (paint tickets, hunter outfit, rare seal box,
     Pikachu backpack, doll box) cost referral points, not Soul Coins, and are not part of
     this.
4. **Buying Soul Coins with PayPal** (needs the PayPal Business account):
   - Buy Soul Coins in the Store makes a one-time code for the account (like the Discord
     `/link` codes) and opens `account.pokeverse.quest/buy` with it. No website login.
   - The page shows the packs and PayPal's buttons. When PayPal confirms the payment, the
     service checks the message really came from PayPal and adds the coins, once per
     payment even if PayPal sends it twice. The player gets a message in game and a receipt
     by email.
   - Bought coins can be spent in the Store at once, but can't be withdrawn (so can't be
     traded) for 7 days, when most payment reversals happen.
   - A refund or chargeback takes the coins back. Below zero, spending is blocked and staff
     are told; reversing a payment on purpose is a ban under the Terms.
   - Every purchase, exchange and coin trade is logged.
   - Built and tested on PayPal's sandbox before real money.
5. **Later, optional:** authenticator-app 2FA and emails for logins from a new device.

### Needed before starting

- Phases 1 to 3 are built and needed nothing else.
- Phase 2 (done): `thepokeversemmo@gmail.com` with 2-Step Verification and an App Password. In this
  repository's Settings > Secrets and variables > Actions: the variable `GMAIL_ADDRESS`
  (`thepokeversemmo@gmail.com`) and the secret `GMAIL_APP_PASSWORD` (the 16 letters); the
  Live server workflow copies them to the server, as it does the bot token. The tests use a
  local SMTP server (`scripts/testing/fake-smtp.py`), so the Cursor Dashboard needs neither.
  Changing the Gmail password cancels the App Password: make a new one and update the
  secret. Access to the `pokeverse.quest` DNS, ideally on Cloudflare (phase 4).
- Phase 4: a PayPal Business account and a PayPal developer app (sandbox and live keys),
  added the same way.

## 20. Move sounds and volume sliders

Planned for after October 2026 (not started).

**Volume sliders for PokeVerse's sounds.** Options (Sound) still has Redemption's Tibia
sliders (Master, Music, Ambience, Item, Event, UI), and they don't match what plays: the town
and route music (`game_environment`) plays on the Ambient channel, so Ambience is the music
slider; weather loops play on the secondary channel; thunder and Pokémon cries share the Effect
channel. The Sound tab gets one slider per kind of sound, each with its own channel:

- Master
- Town and route music
- Ambience (weather loops, thunder)
- Moves (see below)
- Pokémon cries (the Pokédex, and wherever else a cry plays)
- Interface (clicks, windows, the alert)

Item and Event go (Tibia's), and saved values from the old sliders carry over where they match
(Ambience to Town and route music). The startup tune follows Town and route music.

**Move sounds.** Today the client plays Pokémon cries, area music,
weather loops, the startup tune and the alert, but moves have no sound.

- **Sounds by type first:** about 18 types × 2 or 3 kinds (a hit, a beam or projectile, a buff or
  status move), so 40 to 50 sounds. Then the most used moves get their own sound over time.
  The sounds come from the games' recordings (the same Pokemon SFX pack as the battle sounds).
- **The client shapes the sound, not the file:** each sound is recorded longer than any move
  needs (or loops), with no fade baked in. The server tells the client when a move starts, which
  sound to use and how long the move lasts, from the move's own settings. The client plays the
  sound and fades it out (the engine's `SoundSource:setFading`) when the move ends. A move made
  shorter or longer later needs no sound edit.
- **Client:** a small module that plays the move's sound near the Pokémon using it, quieter
  with distance, on the Moves slider (0 turns them off).
- **Server:** one extended opcode when a move starts: the sound (move name, or its type and
  kind), the position and the duration in milliseconds.

**Battle sounds (wired up October 2026).** The server's `Sounds` (`lib/ps/systems/090-sounds.lua`)
sends `name:delayMs;name:delayMs` on extended opcode 3 to the trainers who can see it (hits only
to the two trainers in the fight, at most one every 350 ms per Pokémon); the client's `game_sounds`
plays them as separate sources so they overlap. Wired: the catch (throw, pull-in, landing, wobbles,
then the caught jingle or the break-out), send-out, recall, faint (wild and your own), hits by
effectiveness, statuses and stat changes, Potions, Antidotes and Revives, the Pokémon Center,
the fishing plop and the slot machine on the server; evolution (music, then the "evolved"
jingle), level up, TMs, Gym badges, quests done and the PC in the client. They play on the Item
channel, set by Options > Sound > Battle Sounds Volume (times Master Volume); the menu, PC and
save sounds follow UI Volume.
Not wired yet: menus, doors and walking, items received, held items and abilities, weather
damage, low HP, the shiny sparkle and the surf music.

Sources: The non-move sounds from
BellBlitzKing's "Pokemon SFX Attack Moves & Sound Effects Collection" (Sun and Moon recordings,
Gen 5 for the status heal), and Sun and Moon's jingles, converted to `.ogg` in
`core/client-legacy/data/sounds/effects/`:

| File | Plays when |
| --- | --- |
| `send_out` | a Pokémon comes out of its ball |
| `recall`, `recall_fainted` | a Pokémon goes back (alive, fainted) |
| `forced_retreat` | a Pokémon is forced back (Roar, Whirlwind, Dragon Tail) |
| `flee` | running from a fight |
| `faint` | a Pokémon faints |
| `hit_normal`, `hit_super`, `hit_weak` | damage, by effectiveness |
| `status_burn`, `status_confused`, `status_frozen`, `status_paralyzed`, `status_poison`, `status_sleep` | a status is inflicted |
| `stat_up`, `stat_down` | a stat rises or falls |
| `heal_hp`, `heal_status` | HP healed, status cured |
| `low_hp_loop` | the player's Pokémon is low on HP (loops) |
| `held_item`, `eat_berry`, `ability` | a held item, berry or ability activates |
| `weather_hail_damage`, `weather_sand_damage`, `leech_seed_damage`, `nightmare_damage` | damage each turn |
| `catch_success` | a Pokémon is caught |
| `level_up` | a Pokémon levels up |
| `evolution_start` | an evolution starts |
| `pokecenter_heal` | the Pokémon Center heals the team |
| `item_get`, `key_item_get`, `berry_get`, `egg_get`, `tm_get`, `mega_stone` | an item, key item, berry, egg, TM or Mega Stone is received |
| `ball_throw`, `ball_absorb`, `ball_drop`, `ball_shake`, `ball_open` | a catch: the throw, the Pokémon pulled in, the ball landing, each wobble, a break-out |
| `shiny` | a shiny appears |
| `exp_full` | the experience bar fills |
| `menu_open`, `menu_select`, `menu_choose`, `menu_error` | menus: open, move, confirm, refused |
| `nav_open`, `nav_close`, `dex_select` | the Pokédex and other big windows |
| `pc_open`, `pc_access`, `pc_close` | the PC |
| `save` | the game saves |
| `door_enter`, `door_exit`, `bump`, `ledge_jump` | walking: doors, walking into a wall, a ledge hop |
| `stairs`, `bike_bell` | walking: stairs, the bicycle bell |
| `exp_gain` | the experience bar filling |
| `text_blip` | an NPC's text box |
| `slots_coin`, `slots_stop`, `slots_win`, `slots_big_win` | the slot machine |
| `fishing_plop` | the lure lands in the water |

Surf music: `sounds/environment/surf_01.ogg` (Black and White's "Surf", 84 s with a fade at the
end) replaces the area music while the player surfs, and the area music fades back in after.

| `evolution` | during an evolution (Black and White's "Evolution", 37 s, fading out from 33 s) |
| `evolution_done`, `badge_get` | an evolution finishes, a Gym badge is won |
| `quest_complete`, `quest_failed` | a quest or task is done or failed |

An evolution plays `evolution_start`, then `evolution` from the beginning for as long as the
evolution lasts (it should end before the track's own fade at 33 s); the client then fades it out
and plays `evolution_done`.

The ball, shiny, menu, PC and walking sounds are from Pokémon Essentials' audio (DS era); the
last four jingles are Black and White's. The Black and White and Black 2 and White 2 sound
effect packs (The Sounds Resource, in the owner's Drive) have the rest of those games' battle,
menu and field sounds, under numbered names.
The battle sounds play on a Battle effects slider, next to Moves; the menu, PC and save sounds
on Interface.

## 21. Staff groups

Audit (October 2026) of `data/XML/groups.xml`. The groups are TFS's Tibia set: Player (1), Tutor
(2, access 1), Senior Tutor (3, access 2), Gamemaster (4, access 3), Community Manager (5, access
4) and God (6, access 5). Groups 7 to 9 are the "can't be attacked" copies of 1 to 3 that
`setPlayerVulnerable` switches to and back; they stay.

**Fixed:**

- A group's `outfit` replaces the character's look at every login. The Gamemaster's was 75,
  which is blank in PokeVerse's sprites, so Gamemasters logged in invisible. The Community
  Manager's (266) and God's (302) were Tibia's staff outfits. All three now wear PokeVerse's
  Gamemaster outfit (535), which access 3 and up can also choose in the outfit window (it was
  God only).
- The Gamemaster had Tibia's "can't pick up items" flag, so every Pokémon portrait the server
  gives (`doPlayerUpdatePokemonIcons`, each time a Pokémon is called or changed) fell to the
  floor. The flag is gone.

- Gamemasters, Community Managers and Gods keep the colors they chose: the forced outfit only
  replaces the look. With look 75 every outfit change was refused (it isn't in `outfits.xml`),
  so the colors were never saved.

**The groups (agreed October 22):** Senior Tutor is the top group that plays. Gamemasters and up
are staff characters: they can't battle, gain experience or get loot, so they stay out of the
economy. Staff who want to play use a normal character on their account.

| Group | Access | Plays | Job |
|---|---|---|---|
| Tutor | 1 | Yes | Help channel, mutes, reads reports |
| Senior Tutor | 2 | Yes | Tutor, plus handling reports (status, notes, go to the spot) and broadcasts |
| Gamemaster | 3 | No | Investigating: ghost, teleport, kick, ban, item and creature details, viewing Pokemon stats |
| Community Manager | 4 | No | Gamemaster, plus events (double exp, daycare and breeding, shiny, legendaries, weather, calendar, anniversary) and Discord posts |
| God | 5 | No | Everything: items (`/i`), storages, house owners, server config, Pokemon stats and vocation ranks, restart and shutdown, spawns, the terminal |

Done: `/restart` and the tools that change a player (`/i`, `/storage`, `/owner`, `/config`,
`/vocation`, changing `/pstats`) need God; the event commands and the Admin window's events need
Community Manager (`Admin.EVENT_START_ACCESS`); reports are handled from Senior Tutor
(`Reports.EDIT_ACCESS`); quest doors open for Community Managers and Gods only (not Gamemasters).

Still to do:

- A Gamemaster outfit of their own; until then they wear the Community Manager's (535).
- Tibia's leftovers: rule violation reasons and name lock flags, the Portuguese game chat channel
  opened for Gamemasters on login, Tibia's VIP and depot limits per group.

## 22. Legendary revamp (stages 1 to 3 built)

Today every wild legendary ([section 11](#11-bug-fixes-and-small-ideas), "Legendary spawning")
behaves the same: it appears at a random anchor point, jumps to another far away every few
minutes and flies off. The revamp keeps what is built (spawn timing by population, cooldowns,
flee with the health left, healing when left alone, the top damage dealer's 60 seconds on the
body, rewards by damage share, the chat channel, cards and Discord threads) and gives each
species its own habitat, way of moving and signs that it is near.

### Decided (October 2026)

- **Regions:** Kanto, Johto, the Orange Islands and Hoenn all have regions and towns
  (`Weather.REGIONS`, a zone per town). Habitats are lists of those zones, so legendaries live in
  their own regions, not only Kanto. Johto is open (walk in through the Indigo Plateau, west of
  Pewter), so its zones are used from the start. Every region has weather; staff can switch a
  region off for maintenance (`/weather region <region> off`), and legendaries leave it alone
  while it is off.
- **Sets:** the three birds (Articuno, Zapdos, Moltres), the three beasts (Raikou, Entei,
  Suicune) and the three Regis (Regirock, Regice, Registeel). The 25% roll (a setting) happens
  only when the normal spawn schedule picks an eligible member of a set (off cooldown, not out);
  staff and event spawns don't roll. On a 25% the whole set spawns together, spread over their
  habitats (the Regis asleep at their locations); otherwise the picked one spawns alone. A
  member still on its cooldown comes too (a setting, on by default), and its cooldown is set
  again as usual, like every member's, when its encounter ends (beaten, caught or left); a
  member already out is skipped. A set doesn't count against the limit on the others. Latias and
  Latios work the same way as a pair.
- **Never two of the same:** never two of one species out at once, legendary or mythical,
  whatever started it (the schedule, a set, an event or staff).
- **Never two mythicals:** at most one of Mew, Celebi, Jirachi and Deoxys out at once on the
  whole server, events and staff spawns included.
- **Catch chances** stay as they are (section 11).
- **Mythicals** (Mew, Celebi, Jirachi, Deoxys): the rarest (lowest chance, longest cooldowns)
  and the hardest to find: no area in the announcement, only faint signs. The Master Ball still
  catches them; they are hard to find, not hard to catch.
- **Mew** disguises itself as a Pokémon of the zone it is in, at that zone's levels. When a
  trainer discovers it (attacks it, or a Ranger's radar picks it out), it shows its true self.
- **Regis** sleep at one of their locations until a trainer finds them or the time runs out. No
  puzzle rooms. They don't roam.
- **Catch announcements:** every catch of a legendary or mythical is announced server-wide,
  wherever it comes from (wild, dungeon or quest), not only wild catches within 5 minutes.
- **Announcements and hints** name the area, never the exact spot (mythicals not even the area).
- **Level cap:** Pokémon stay capped at level 100; extra points remain the progression after it.

### Each species

| Species | Moves | Habitat | Signs |
| --- | --- | --- | --- |
| Raikou | Ground roamer, faster in thunderstorms | Open routes, stormy zones | Sparks on its trail |
| Entei | Ground roamer | Mountains, volcanoes | Scorch marks, heat shimmer |
| Suicune | Ground roamer, also along waterways | Rivers, lakes, coasts, forests | Mist |
| Articuno | Flies between zones, lands | Snowy mountains, cold zones | Snow, ice, feathers |
| Zapdos | Flies, follows thunderstorms | Stormy zones | Lightning |
| Moltres | Flies | Volcanoes, warm zones | Fire, feathers |
| Latias | Fast flyer, lands near trainers more often | Peaceful zones, forests | Brief fly-overs |
| Latios | Faster flyer, avoids busy zones | Wild remote zones, mountains | Brief fly-overs |
| Lugia | Ocean roamer | Sea zones | Storms, waves; underwater shadow |
| Ho-Oh | Flies between towers and peaks, circles before landing | Elevated zones | Rainbows, golden sparkles |
| Kyogre | Stays in its sea territory | Deep water | Heavy rain; underwater shadow |
| Groudon | Stays in its territory, rises out of the ground | Volcanic, underground | Earthquakes, heat |
| Rayquaza | Flies, lands at Sky Pillar or a high place | Sky Pillar, peaks | Wind; may appear when Groudon and Kyogre are both out |
| Mewtwo | Mostly Cerulean Cave, sometimes remote Kanto; short teleports in battle, doesn't flee between zones | Cerulean Cave | Psychic disturbance before it appears |
| Regirock, Regice, Registeel | Asleep, don't move | One of their locations each | Falling rocks / frost / metallic sparks near it |
| Mew (mythical) | Disguised as a local Pokémon, teleports to escape | Forests, ruins, islands | Pink sparkles |
| Celebi (mythical) | Mostly Ilex Forest, sometimes other old forests; short teleports | Forests | Green sparkles, unusual Pokémon near it |
| Jirachi (mythical) | Lands with a meteor shower, stays a limited time | Meteor landing spots | Falling stars |
| Deoxys (mythical) | Arrives by meteor impact, changes form in battle | Wild meteor sites | Strange energy at the impact |

Ground roamers walk only to zones next to their own (a zone map made once from the map and
checked by hand); flyers can go anywhere suitable; ocean roamers only through water zones.

### Stages

1. **Server only:**
   - catch announcements everywhere;
   - habitats and movement styles per species;
   - the sets (birds, beasts, Regis, Latias and Latios): the 25% roll when the schedule picks a
     member, bringing members still on cooldown too; one of each species and one mythical at a time;
   - weather links (Raikou, Zapdos, Kyogre);
   - trails of signs with the effects we have;
   - Mew's disguise, Mewtwo's warning, the sleeping Regis;
   - active ones kept through a restart with their health;
   - the Ranger radar by rank: zone activity (1), species from signs (2), next zones (3), direction
     and freshness (4), recent path and rough destination (5), never exact coordinates.
2. **Client:** fly-overs. The client draws the Pokémon raised above the map moving along the
   path the server sends, with a dark copy on the ground as its shadow; the same module draws only
   the dark copy on water for Lugia and Kyogre. Screen shake for Groudon.
3. **Events:** meteor showers (Jirachi) and impacts (Deoxys), Rayquaza's appearance, the weather
   when two legendaries' areas overlap (Articuno and Zapdos, Articuno and Moltres, Groudon and
   Kyogre), and switching Deoxys between its formes (the sprites are in).

All times, chances and limits stay in `WildLegendaries.CONFIG`.

### Flights (stage 2)

Flyers (the birds, Latias and Latios, Ho-Oh, Rayquaza, and Lugia over land) travel to an
adjacent zone in the open, crossing what lies between, so trainers can see them go by:

1. **Takeoff:** a takeoff effect, and the creature leaves the map. In the air it can't be fought.
2. **Route:** the server picks an adjacent zone that fits its habitat and a path into it (zone to
   zone, from the zone map stage 1 makes), and flies it at a set speed in tiles per second
   (Latias and Latios faster). The flight is kept in global storage (from, to, start time,
   speed), so the position at any moment is worked out, not stepped.
3. **Who sees it:** each second the server finds the outdoor trainers within view of the path
   and sends each one the flight once (species, look, from, to, start time, speed) on a new
   extended opcode; their client animates it from there.
4. **What they see:** a client module draws the Pokémon above the map (`UIMap:getTilePoint`
   gives the screen spot of a tile), a little higher than the tiles, with a dark copy of it on
   the ground as its shadow, offset as if high up; its signs (snow, lightning, sparkles) follow
   the path. Trainers under a roof don't see it. It is drawn the same on every floor.
5. **Sightings:** crossing a zone counts as a sighting: "Articuno was seen flying over Route 5,
   heading north" (the area and the direction, never the spot), and the Ranger radar picks it up
   by rank.
6. **Landing:** it circles over the new zone for a few seconds, then lands on a valid tile with a
   landing effect and can be fought again.
7. **Fleeing:** a flyer that flees takes off the same way, so the chase can be seen.

Lugia uses the same module at sea: while it travels underwater only the dark shape is drawn, on
the water. A flight crosses only the screens its path goes through; a far-off sight (a speck at
the screen edge, a cry) is a later idea.

### Admin controls

The Admin window's World tab already has a Legendaries panel (pick a species: Spawn somewhere,
Spawn at my feet, Send away, Next spawn in 5 min, Status, Clear cooldowns). The tabs change:

- **Boosts:** today's Events tab (the experience and shiny events), renamed.
- **Events (new tab):** every game event, one section each: Legendaries (below), then Pokémon
  swarms, the Bug-Catching Contest and the next events, each with the same Auto / Manual
  switch and start and stop buttons. The Legendaries panel moves here from the World tab.

Each stage adds its buttons to the Legendaries section, with a `/legendary` command behind each
one, so staff can set off any of it for events and for testing:

- **Auto / Manual**, like the weather: Auto spawns on the schedule; Manual stops scheduled spawns
  so only staff start them, without touching what is already out. Kept through a restart.
- **Sets:** spawn the bird trio, the beast trio, the Regis or Latias and Latios together (the
  same rules: a member already out is skipped, and staff can't break the one-of-each or
  one-mythical rules).
- **Per species:** spawn in its habitat or at my feet, send away, move it now (a flight or walk to
  its next zone), set its health, clear its cooldown, and show its trail and signs.
- **Special ones:** spawn Mew disguised (here or in a zone) and reveal it, put a Regi to sleep at
  one of its locations or wake it, Mewtwo's warning, a meteor shower (Jirachi), a meteor impact
  (Deoxys), Groudon and Kyogre together (Rayquaza's event), and a fly-over seen by me only (to
  check the client drawing without spawning anything).
- **Status:** what is out and where (staff see exact spots), the sets, the mythical slot, the
  next spawn and the cooldowns.

### Stage 1 (built)

Server Lua only, plus the Admin window in the Redemption client. All settings are in
`WildLegendaries.CONFIG` (`systems/078-wildLegendaries.lua`).

- **Habitats:** `config/legendaryAnchors.lua` (made by `scripts/make-legendary-anchors.py`) now
  has 7,652 points over Kanto, Johto, the Orange Islands and Hoenn, each with its area, its zone
  (town), whether it is outdoor, a cave or indoors, and tags (cold, fire, electric, water, forest,
  mountain, high, rock, steel, remote, peaceful, mystic), plus the map of which zones touch which.
  Each species has its regions, the kinds of place it goes, tag weights and home areas
  (35% of picks by default, Mewtwo 80% in Cerulean Cave). Points in a region switched off by
  `/weather region <region> off` aren't used.
- **Ways of moving:** flyers land anywhere in their habitat, far from the last spot; the beasts
  walk only to a zone next to theirs (Raikou faster in a thunderstorm); Lugia swims the coasts;
  Kyogre and Groudon stay in the zone they came up in; Mewtwo stays and teleports a short way
  when hurt; Celebi teleports within its zone and the next ones; Jirachi and Deoxys land with a
  meteor and stay (Jirachi 45 minutes).
- **Sets:** when the schedule picks a bird, beast, Regi, Latias or Latios, a 25% roll brings the
  whole set (members on cooldown too; one already out is skipped). Set members don't count
  against the limit of 2. Staff can spawn a set with `/legendary set <id>`.
- **Limits:** never two of a species, never two mythicals, at most one tier 2 among the
  scheduled ones. The schedule weighs each species 6 (tier 1), 2 (tier 2) or 1 (mythical), and
  mythicals have 1.5 times the tier 2 cooldown.
- **Weather:** Zapdos and Raikou are drawn to zones with a thunderstorm; Kyogre brings rain to
  its zone while it is out (a weather override that ends with it, unless staff set the weather
  there).
- **Signs:** every 6 seconds (mythicals 15, Mew in disguise 30) its effects show where it is
  and on the last 6 spots it left (for 10 minutes): snow and ice for Articuno, sparks for
  Raikou, pink clouds for Mew and so on. These are effects we already have; the new art from
  [#207](https://github.com/GIToez/PokeVerse/pull/207) comes with the client.
- **Mew** appears as a Pokémon of its spot at that spot's level. A hit, or the radar of a
  Ranger of rank 4 or more, makes it show its true self ("X found Mew hiding as a wild Y!"),
  with its full health from then on.
- **Mewtwo:** three minutes of psychic disturbance (purple effects) where it will appear,
  announced server-wide ("A strange psychic disturbance is building near Cerulean Cave...") and
  in the Legendaries channel, then it appears there.
- **Regis** sleep at one of their locations (4 hours). The first hit is blocked and wakes it:
  "X woke Regirock up near Rock Tunnel!", and it has 60 minutes from then.
- **Catch announcements:** every legendary or mythical caught anywhere is announced; the wild
  one still says "caught the wild X", and one given as a quest reward is announced too ("X
  received Mew as a reward!").
- **Restarts:** the ones out are saved every 30 seconds (species, health, spot, time left,
  asleep, disguised) and come back after a restart. No new spawns in the last 10 minutes
  before it.
- **Ranger radar:** after a scan, a Ranger gets one line per legendary out in their region, by
  rank: activity in a zone (1), which species from its signs (2), the zones it may go next (3),
  the direction and how fresh the signs are (4), and the zones it came through and where it is
  heading (5). Mythicals only from rank 4. Never the exact spot.
- **Admin window:** the Events tab is now **Boosts** (experience and shiny events, as before).
  A new **Events** tab has the Legendaries section: Auto / Manual, the four sets, a species
  grid, then Spawn in its habitat, Spawn at my feet, Send away, Move it now, Health 50% / 100%,
  Clear its cooldown, Show its signs, and the special ones (Mew disguised here, Reveal Mew, Wake
  the Regi, Mewtwo warning, Next spawn in 5 min, Clear all cooldowns); below them the
  status (what is out, exact spots, the mode, the next spawn and the cooldowns). It is gone
  from the World tab. Each button runs a `/legendary` command: `status`, `spawn <name> [here]`,
  `set <birds|beasts|regis|eon>`, `end <name>`, `move <name>`, `health <name> <percent>`,
  `signs <name>`, `mew [here]`, `reveal`, `wake <name>`, `warn [here]`, `mode <auto|manual>`,
  `next <duration>` and `cooldowns clear [name]`. Manual mode is kept through a restart.
- **Tests:** the legendary part of the vocation test talkaction covers the habitats, the sets
  and their roll, the limits, roaming and the trail, the radar by rank, the Regis, Mew, Mewtwo's
  warning, Kyogre's rain, the restart save, the flee, manual mode, the catch announcements and
  a real Mewtwo defeat.

Stage 1 left the fly-overs and shadows to stage 2 and the events to stage 3.

### Stage 2 (built)

Server Lua, the new `game_legendaryflight` module and one engine fix in the Redemption client.
The settings are in `WildLegendaries.CONFIG` under "Flights".

- **Effect art:** 21 new client effects (1140 to 1160) from
  [#207](https://github.com/GIToez/PokeVerse/pull/207), with server constants, used for the
  signs, takeoffs and landings.
- **Flights:** when a flyer moves (the schedule, a flee or staff), it takes off with its takeoff
  effect and leaves the map. The flight (from, to, start, length, health, flee stage) is kept in
  global storage (`LEGENDARY_FLIGHTS`), so its position is worked out at any moment. It flies 6
  tiles a second (Latias and Latios 7), each crossing 8 to 60 seconds, circles for 4 seconds over
  the landing spot, then lands with its landing effect and can be fought again. It can't be
  fought in the air, still counts as out, and a flight in progress is saved through a restart
  with its landing spot. A flyer that flees flies off the same way and lands with the health it
  had.
- **Dives:** Lugia and Kyogre swim the same way, 4 tiles a second (Kyogre stays in its zone).
- **Who sees it:** every second the server finds the trainers within 18 by 14 tiles of where it
  is and sends each one the flight once, on extended opcode 45 (`LEGENDARY_FLIGHT`, JSON).
- **Drawing:** the client draws the flyer raised above the map with a bob, moving along the path,
  and a dark copy of it on the ground as its shadow (an outfit shader), circling before it lands.
  A dive draws only the dark shape, and only where every tile under it is sea (sea tiles are
  walkable when surfing, so the module tells water by its ground ids). Nothing shows under a
  roof or underground. A flight is drawn the same on every floor.
- **Signs and sightings:** its signs follow the path every 2 seconds, and crossing into a zone is
  a sighting, at most every 10 seconds: "Articuno was seen flying over Route 5, heading north",
  in the Legendaries channel, and the Ranger radar picks it up.
- **Groudon** shakes the screens of trainers within 14 tiles when it comes up and as it moves,
  harder the closer they are.
- **Engine fix:** UI creatures drew into a 64 pixel buffer, which cut and smeared the big 3x3
  legendaries (Ho-Oh is 95 pixels); the buffer now grows with the creature
  (`Creature::drawOutfitPokeVerse`).
- **Admin:** **Move it now** is a flight; the status says which ones are in the air and where they
  land; **Fly-over (me only)** and **Dive-over (me only)** (`/legendary flyover <name> [dive]`)
  send a flight of the picked species past the staff member only, without spawning anything.

### Stage 3 (built)

- **Jirachi** lands with a meteor shower: 20 seconds of falling stars, 3 a second, within 7
  tiles, drawn on the screens of trainers within 20 by 16 tiles ("A meteor shower lights up the
  sky..."). A restart doesn't start it again.
- **Deoxys** arrives with one big meteor, then the impact effects and a shake 1.2 seconds later
  ("A meteor struck somewhere!...").
- **Rayquaza:** when Groudon and Kyogre are both out, a 50% roll, once for that pair. On a hit,
  2 minutes later Rayquaza comes down from the sky near Groudon (or Kyogre), flying in from 16 to
  24 tiles away and landing 3 to 7 tiles from it, announced server-wide: "Rayquaza is coming down
  from the sky to calm Groudon and Kyogre near X!". The pending call is kept through a restart.
- **Clash weather:** two legendaries in the same zone or next ones change the weather there for
  15 minutes, renewed while they stay: Articuno and Zapdos bring hail, Articuno and Moltres fog,
  Groudon and Kyogre a thunderstorm (announced server-wide). Rayquaza calms Groudon and Kyogre's
  storm, and Kyogre's rain comes back. When they part, the weather goes back. Weather staff set
  there stays (only rain in Kyogre's zone gives way, since Kyogre may have brought it).
- **Status:** the shower, the coming Rayquaza and the clash weather show in `/legendary status`
  and in the Admin window.
- **Admin:** **Rayquaza's event** (`/legendary rayquaza`: spawns the two if they aren't
  out and calls Rayquaza now), **Meteor shower here** (`/legendary meteors`) and **Meteor impact
  here** (`/legendary impact`).
- **Deoxys's forms**: the sprites are in (Normal on look 1565, Attack 2592, Defense 2593, Speed
  2594), but nothing switches between them yet.
- **Tests:** the vocation test talkaction covers flights (staff moves, ending one, landing,
  fleeing with its health, the restart save, who is sent it, the staff-only fly-over), Kyogre's
  dive staying in its zone, Groudon's shake, Jirachi's shower, Deoxys's impact, the clash
  weather, and Rayquaza's call, landing and calming the storm.

### After stage 3 (built)

- **Latias and Latios art:** their looks (1559 and 1560) had no sprites, so a wild one and its
  fly-overs drew nothing. They are now the sprite pack's 96 pixel sheets (`outfit_4344_` and
  `outfit_4342_`, put in by `scripts/dat-set-outfit.py`).
- **Bigger Lugia:** look 1075 is a 192 pixel sheet (6 by 6 tiles: standing, then 4 flying
  frames), about twice the old one. Fly-overs and dives draw up to 192 pixels; a dive shows
  while the sea is under the middle of its shape (not its wing tips).
- **Bigger effects:** Latias and Latios are drawn at least 64 pixels in a flight and fly 7
  tiles a second instead of 9, so they stay on screen longer. Mewtwo's
  warning bursts every 4 seconds instead of 15, 4 to 10 effects within 5 tiles growing as it
  nears, every second in the last 15 seconds, with a shake around it 15 seconds before it
  appears.
- **Ranger tracking by footprints** ([section 11](#11-bug-fixes-and-small-ideas)).
- **Pokepedia:** the Wild legendaries page describes the revamp, with a line for the
  Rangers' hints by rank.

## 23. New Pokémon (Gen 4 to 6)

**To add:** the 332 Pokémon from #387 Turtwig to #718 Zygarde, the ones the Battle Trozei face
sheet covers. The game has #1 to #386 today. Diancie, Hoopa and Volcanion (#719 to #721) and
Gen 7 on are not part of this, since there are no faces for them yet.

**Art that is ready:**

| Art | Gen 4 (107) | Gen 5 (156) | Gen 6 (69) | Where |
| --- | --- | --- | --- | --- |
| Swap bar face | 107 | 156 | 69 | `art/sprites/faces/<dex>/`, 64x64 from Battle Trozei, 4-frame bob |
| Walk sprite in the 6500 pack (named with high or medium confidence) | 53 | 122 | 3 | `docs/sprite-pack-review/new_species.csv` |
| Walk sprite from Mystery Dungeon at 2x | all | all | all | PMDCollab SpriteCollab |
| Portrait and 3D Pokédex picture | all | all | all | Pokémon Showdown (`gen5/`, `ani/`) |

See [new-pokemon-art.md](new-pokemon-art.md) for the formats and how each is converted.

**What each Pokémon needs:**

- Server: a `lib/ps/config/pokemon/<name>.lua` config (types, stats, moves, `dexStorage`,
  description, catch storage, portraits), a monster file in `monster/Pokemons`, its number and
  name in `pokemonsNumbers.lua` and `pokemonsNames.lua`, and `POKEMON_NUMBER` raised from 386
  (the Pokédex, the Pokepedia and the trainer card count up to it).
- Client: the walk sprite as an outfit (`scripts/dat-set-outfit.py new`), the face item, the
  `staticPortraits`, `pictures` and `pokeicons` images, the cry, and the name in `gamelib/pokemon.lua`.
  The Pokédex grid works its face ids out from the number (Gen 3 ends where Treecko's swap face
  starts), so it needs a new id block from #387.
- Spawns, evolutions, ride, fly, surf and dive outfits where they apply, and loot.

**To decide:**

- The order: a generation at a time (Sinnoh first), or a few families at a time.
- Where they live: new regions (Sinnoh, Unova, Kalos) or mixed into Kanto and Johto.
- The legendaries: in the [legendary revamp](#22-legendary-revamp-stages-1-to-3-built) with
  their own habitats and events, or held back.
- The faces are 64x64: a bigger swap bar slot for every Pokémon, or new faces shrunk to 32x32 by
  hand.
- Stats from PokéAPI with or without the stat audit's fixes ([new-pokemon-art.md](new-pokemon-art.md#open-decisions)).

**Gen 4 (#387 to #493, 107):** Turtwig, Grotle, Torterra, Chimchar, Monferno, Infernape, Piplup,
Prinplup, Empoleon, Starly, Staravia, Staraptor, Bidoof, Bibarel, Kricketot, Kricketune, Shinx,
Luxio, Luxray, Budew, Roserade, Cranidos, Rampardos, Shieldon, Bastiodon, Burmy, Wormadam,
Mothim, Combee, Vespiquen, Pachirisu, Buizel, Floatzel, Cherubi, Cherrim, Shellos, Gastrodon,
Ambipom, Drifloon, Drifblim, Buneary, Lopunny, Mismagius, Honchkrow, Glameow, Purugly,
Chingling, Stunky, Skuntank, Bronzor, Bronzong, Bonsly, Mime Jr., Happiny, Chatot, Spiritomb,
Gible, Gabite, Garchomp, Munchlax, Riolu, Lucario, Hippopotas, Hippowdon, Skorupi, Drapion,
Croagunk, Toxicroak, Carnivine, Finneon, Lumineon, Mantyke, Snover, Abomasnow, Weavile,
Magnezone, Lickilicky, Rhyperior, Tangrowth, Electivire, Magmortar, Togekiss, Yanmega, Leafeon,
Glaceon, Gliscor, Mamoswine, Porygon-Z, Gallade, Probopass, Dusknoir, Froslass, Rotom.

Legendary and mythical: Uxie, Mesprit, Azelf, Dialga, Palkia, Heatran, Regigigas, Giratina,
Cresselia, Phione, Manaphy, Darkrai, Shaymin, Arceus.

**Gen 5 (#494 to #649, 156):** Snivy, Servine, Serperior, Tepig, Pignite, Emboar, Oshawott,
Dewott, Samurott, Patrat, Watchog, Lillipup, Herdier, Stoutland, Purrloin, Liepard, Pansage,
Simisage, Pansear, Simisear, Panpour, Simipour, Munna, Musharna, Pidove, Tranquill, Unfezant,
Blitzle, Zebstrika, Roggenrola, Boldore, Gigalith, Woobat, Swoobat, Drilbur, Excadrill, Audino,
Timburr, Gurdurr, Conkeldurr, Tympole, Palpitoad, Seismitoad, Throh, Sawk, Sewaddle, Swadloon,
Leavanny, Venipede, Whirlipede, Scolipede, Cottonee, Whimsicott, Petilil, Lilligant, Basculin,
Sandile, Krokorok, Krookodile, Darumaka, Darmanitan, Maractus, Dwebble, Crustle, Scraggy,
Scrafty, Sigilyph, Yamask, Cofagrigus, Tirtouga, Carracosta, Archen, Archeops, Trubbish,
Garbodor, Zorua, Zoroark, Minccino, Cinccino, Gothita, Gothorita, Gothitelle, Solosis, Duosion,
Reuniclus, Ducklett, Swanna, Vanillite, Vanillish, Vanilluxe, Deerling, Sawsbuck, Emolga,
Karrablast, Escavalier, Foongus, Amoonguss, Frillish, Jellicent, Alomomola, Joltik, Galvantula,
Ferroseed, Ferrothorn, Klink, Klang, Klinklang, Tynamo, Eelektrik, Eelektross, Elgyem, Beheeyem,
Litwick, Lampent, Chandelure, Axew, Fraxure, Haxorus, Cubchoo, Beartic, Cryogonal, Shelmet,
Accelgor, Stunfisk, Mienfoo, Mienshao, Druddigon, Golett, Golurk, Pawniard, Bisharp, Bouffalant,
Rufflet, Braviary, Vullaby, Mandibuzz, Heatmor, Durant, Deino, Zweilous, Hydreigon, Larvesta,
Volcarona.

Legendary and mythical: Victini, Cobalion, Terrakion, Virizion, Tornadus, Thundurus, Reshiram,
Zekrom, Landorus, Kyurem, Keldeo, Meloetta, Genesect.

**Gen 6 (#650 to #718, 69):** Chespin, Quilladin, Chesnaught, Fennekin, Braixen, Delphox,
Froakie, Frogadier, Greninja, Bunnelby, Diggersby, Fletchling, Fletchinder, Talonflame,
Scatterbug, Spewpa, Vivillon, Litleo, Pyroar, Flabébé, Floette, Florges, Skiddo, Gogoat,
Pancham, Pangoro, Furfrou, Espurr, Meowstic, Honedge, Doublade, Aegislash, Spritzee, Aromatisse,
Swirlix, Slurpuff, Inkay, Malamar, Binacle, Barbaracle, Skrelp, Dragalge, Clauncher, Clawitzer,
Helioptile, Heliolisk, Tyrunt, Tyrantrum, Amaura, Aurorus, Sylveon, Hawlucha, Dedenne, Carbink,
Goomy, Sliggoo, Goodra, Klefki, Phantump, Trevenant, Pumpkaboo, Gourgeist, Bergmite, Avalugg,
Noibat, Noivern.

Legendary and mythical: Xerneas, Yveltal, Zygarde.

## 24. Battle text: call-out bubbles and hit numbers

Built (October 24). See "How it's built" at the end of this section.

**Before.** When a trainer's Pokémon uses a move, the trainer says "Pikachu, Thunderbolt!" as
orange chat text over their head (`003-skill.lua`, `doCreatureSay`), and a wild Pokémon yells
the move's name. Damage is the engine's plain number floating up from the target, coloured by
type. A critical hit is a separate red "CRITICAL!" over the attacker (`004-skillDamage.lua`),
so it lands on top of the call-out and away from the number it belongs to. Super effective and
not very effective hits look the same as any other hit.

**Call-outs.**

- **Trainers:** every trainer's call-out (yours, other players', NPC trainers' and gym leaders')
  is a speech bubble that pops out over the trainer, with its tail pointing at them. It scales in
  (small, a bit too big, then settled) and stays about 1.5 seconds. It says the Pokémon's
  nickname, or its species when it has none ("Sparky, Thunderbolt!" or "Pikachu,
  Thunderbolt!"), and the move's name is in its type's colour. The server's nickname already
  falls back to the species.
- **Wild Pokémon:** no bubble. They stop yelling their move's name; their hits still show
  numbers.
- **Local Chat** still gets the "Pikachu, Thunderbolt!" line, so the log stays the same.

**Back-to-back moves.** Four ways to show them:

- **A. Replace:** one bubble, and the text swaps with a bounce. It's the cleanest, but earlier
  moves vanish.
- **B. Grow:** one bubble gains a line per move, 3 at most. The newest line is full size and
  coloured; older ones are smaller and grey, and the oldest drops off.
- **C. Stack bubbles:** each move gets its own bubble, and older ones float up and fade. This is
  the busiest on screen.
- **D. Combo count:** the same move again adds x2, x3 instead of a new line. It works with A or
  B.

Chosen: C. Each call-out is its own bubble and lives about 1.5 seconds. When a new one comes,
the older ones float up a step, shrink a little and turn see-through, then fade out. A trainer
has at most 3 at once; a fourth pushes the oldest out early. Moves can come about once a second
(`BATTLE_ROUND_INTERVAL`), so a trainer in a steady fight usually has 2 showing.

**Hit numbers.** One number per hit, on the target. It pops in, rises and fades, and moves a
few pixels to the side each time so quick hits don't cover each other. Fast multi-hits still
add up into one number, like today. Size and style show how good the hit was:

| Hit | Look |
| --- | --- |
| Normal | White, outlined |
| Super effective | Bigger, orange-gold, "SUPER EFFECTIVE" under it |
| Not very effective | Smaller, grey, "resisted" under it |
| Critical | Biggest, red-gold with a glow and a burst behind it, "CRIT!" tag, a tiny screen shake |
| Heal or drain | Green "+35" |
| Miss, dodge, protect, immune | A tag; see below |

**Outcome tags.** Today a miss, a dodge, a block and a status all look like the same floating
word, so you can't tell them apart. Each becomes a rounded tag with its own colour and icon:

| Outcome | Tag | Where |
| --- | --- | --- |
| The move missed | Grey "MISS" with a swoosh | On the target |
| The target dodged (evasion abilities, mastery) | Blue "DODGED", and the Pokémon blurs aside | On the target |
| Protect or Reflect blocked it | Green "PROTECTED" with a shield | On the target |
| Immune | Dark "NO EFFECT" with a cross | On the target |
| Status (burn, paralysis, sleep, poison, freeze, confusion, love, flinch) | The status's colour and icon, e.g. yellow "PARALYZED" with a bolt | On the Pokémon it hits |
| Stat change | Red "ATTACK UP" with an up arrow, blue "ATTACK DOWN" with a down arrow | On the Pokémon it hits |
| The move failed, or the Pokémon is tired | Purple "FAIL" or "TIRED" | On the user |

**Lanes.** Each kind of text has its own spot around the Pokémon: numbers above it, stat
changes beside it, statuses under its feet. A hit, a stat drop and a paralysis at the same time
don't land on top of each other.

**Agreed (October 23):** nickname, or species when there's none. Every trainer's call-out shows
as a bubble; wild Pokémon don't get one. A switch between new and classic. Back-to-back moves
stack as separate bubbles that float up and fade (C).

**How it's built.**

- **Server (`091-battleText.lua`):** extended opcode 46 (`EXTENDED_IDS.BATTLE_TEXT`) sends JSON
  to the players who can see the fight: a trainer's call-out (trainer, nickname, move, type), a
  wild Pokémon's move, a miss, and each hit's kind (normal, super, weak, crit, immune) worked
  out from `getFinalDamage`'s type multiplier and crit roll. The old `doCreatureSay`,
  "CRITICAL!" and damage numbers are still sent, so older clients and Classic mode don't
  change.
- **Engine (`protocolgameparse.cpp`):** each animated text is offered to
  `g_game.onAnimatedText` first; when the module returns true, the engine doesn't draw it.
- **Client (`game_battletext`):** draws the bubbles, numbers and tags as widgets over the map
  in Pixelify Sans. Damage numbers ("-N") take their style from the hit kind, green "+N" is a
  heal, "CRITICAL!" is dropped (the crit number has its own tag), and known words (MISS!,
  EVADED, PROTECTED, statuses, "+ATK"/"-DEF" and the rest) become tags. Unknown text stays
  classic. The console patch lets the module take the call-out's overhead text (and hides a
  wild Pokémon's yell); Local Chat still gets the line.
- **Options:** Options > Interface > General has "Battle text: New/Classic" and "Screen shake on
  critical hits" (on by default).
- **Immune hits:** a type multiplier of 0 still deals the attack-minus-defense part of the
  damage, so "NO EFFECT" shows as a small grey number with that caption, not a bare tag.

## 25. Announcements: news banner, call-out bubbles, Discord and the calendar

Plan (not started). The aim is that nothing needs adding by hand: a new holiday, weekend event,
staff event or legendary shows up in game, on Discord and in Discord's event calendar on its
own.

### Calling out and recalling Pokémon

The [battle text](#24-battle-text-call-out-bubbles-and-hit-numbers) bubbles cover moves only.
Calling out a Pokémon still uses plain yellow speech: one of 5 random lines like "Pikachu, I
choose you!" (`doPokemonCall`, `functions/others.lua`). Recalling uses one of 4 lines like
"Pikachu, back!" (`functions/ball/inUse.lua`).

- **Bubbles:** both become bubbles over the trainer, with the trainer's ball as a small icon on
  the bubble, the nickname in the Pokémon's type colour, and the same random lines. A swap
  (recall, then call) stacks as two bubbles, like back-to-back moves.
- **NPC trainers too:** gym leaders, NPC battles and Team Rocket ("Go, X!" and "Back, X!" in
  `001-npcBattle.lua` and `050-rocketBattle.lua`).
- **Orders as bubbles:** "X, push it!", "let's climb!", "headbutt it!", "go there!", "shoot
  there!", and throwing a ball ("Great ball, go!"), each with a small icon (rock, ladder, tree,
  arrow, ball).
- **How:** the same `BATTLE_TEXT` opcode gets `summon`, `recall` and `order` messages. The
  console patch takes their overhead text, like a move call-out, and Local Chat keeps the
  line. "Battle text: Classic" turns them back to plain text.

### The news banner

Today every server-wide message is Tibia's red text in the middle of the screen, and it's gone
in a few seconds. There are 44 broadcasts: events starting and ending, wild legendaries,
restarts and saves, the World Boss, the new Champion, a completed Pokédex, staff broadcasts and
the rotating tips. All of them go through one function, `doBroadcastMessage`
(`lib/050-function.lua`).

The banner is for the calendar, events, broadcasts and tips. The pop-up cards for spawns
(`game_eventcards`, used for legendaries today) stay as they are and aren't touched.

**The look:** a Poké Ball drops in at the top centre of the screen, just under the top bar, and
pulses twice. It splits open
with a white flash, the two halves slide left and right, and a news banner unrolls between
them, with the
category's icon and colour, a title and the text. It stays about 5 seconds (longer for long
text), rolls back into the ball, and the ball shrinks away. A soft chime plays (muted with the
sound effects volume). More announcements queue up, one at a time. Hovering keeps it open, and
clicking opens the full text in chat. The banner is about 45% of the game window's width (it
scales with the window, within a smallest and largest size) and about two lines tall, so it
never covers the middle of the screen where the player is.

| Category | Colour and icon | For |
| --- | --- | --- |
| Event | Gold, star | Holidays, weekend events, bonus events starting and ending |
| Legendary | Purple, the Pokémon's face | Spawns, sightings, sets, clashes, catches |
| Server | Red, wrench | Restarts, saves, shutdowns, cleaning |
| Staff | Blue, megaphone | `/b` and the admin window's broadcast, with the staff name |
| Milestone | Green, trophy | New Champion, completed Pokédex, World Boss defeated |
| Tip | Grey, light bulb | The rotating tips (see below) |

Every category gets the full banner.

**How it stays automatic:**

- **One place:** `doBroadcastMessage` gets an optional category and title. Old calls with no
  category are guessed from where they're called from (calendar, legendaries, restart, staff),
  and anything else is "news", so every existing broadcast gets the banner without being
  touched.
- **Old clients keep working:** the server sends an `ANNOUNCEMENT` opcode (JSON: category,
  title, text, icon, how long), and the old text too. The new client hides the text it already
  showed as a banner, the same way battle text does.
- **A new module, nothing existing edited:** the banner is its own client module,
  `game_newsbanner`, with its own queue, art and sound. `game_eventcards` and its "Show event
  pop-up cards" switch are left alone. The banner gets its own switch in Options > Interface,
  "Show news banner"; off brings back the red text.
- **Personal red messages later:** 35 personal messages ("You need level X", quest notices)
  also use the red centre text. They'd become a small card on the right side, as a second step.

### Rotating tips

There are 5 tips today, in `lib/ps/events/globalevents/globalMessages.lua`, sent as red,
white or green text in turn.

- **More tips:** a longer list (about 40) in its own file, covering hotkeys, the Poképedia,
  Day Care, Union Room, the GTS, tasks, fishing, Soul Coins and Discord linking. Adding a tip is
  one line.
- **Shown as Tip banners, about once an hour** (a setting), in a shuffled order so the same tip
  doesn't come back soon. They wait their turn behind other announcements.
- **Never in combat:** a tip that comes up while the player is in a fight (a wild or trainer
  battle, a duel, a gym, or hit in the last 30 seconds) waits until they've been out of combat
  for a while. If an hour goes by it's skipped.
- **A "Turn off tips" button on the Tip banner** turns them off with one click. They can be
  turned back on, or off, in Options > Interface ("Show tips"). This doesn't touch the other
  announcements.
- **Fitting the player, later:** tips can say who they're for (a level range, or players who
  haven't used a feature yet), and each player gets one that fits.
- Not posted to Discord.

### Discord

The bot (GIToez/PokeVerse-Discord) posts staff broadcasts and restart warnings to
`#game-announcements`, and one post with a thread per wild legendary to `#legendary-spawns`.
Nothing else reaches Discord.

**Every announcement goes to Discord automatically.** The same `ANNOUNCEMENT` data is sent to
the bot (`kind = "announcement"`). It posts an embed in the category's colour, with art for
legendaries and events, in `#game-announcements` (legendaries stay in `#legendary-spawns`).
Tips are not posted. A setting per category turns posting on or off.

**Pings: roles and @everyone.**

- **Holiday and weekend events ping Verified Trainer** when they start, end or change (a new
  time or new bonuses). Verified Trainer is the role the bot already gives linked players
  (`config.linking.verifiedRoleName`), so no new roles are needed. Nothing else pings on its
  own: legendaries, restarts, milestones and staff bonus events are posted without a ping.
  Each category's ping is a bot setting.
- **@everyone is only ever by hand,** by Gamemasters and up (access 3 and up). Nothing
  automatic pings @everyone.
- **Staff choose the ping:** `/b @everyone Server event tonight!`, `/b @verified ...`, any other
  role by name (`/b @Premium ...`, checked against the server's roles), or no tag. In game the
  tag is taken out of the text. The admin window's broadcast gets a "Ping on Discord" picker
  that lists the server's roles. `@everyone` and `@here` only work for Gamemasters and up; for
  a Senior Tutor the tag is dropped and the post goes out without the ping. The bot only allows
  those mentions on these posts.
- **The bot needs** the Mention Everyone permission for `@everyone` (it already has Manage
  Roles).

**Legendaries, brought up to date with the revamp.** These go in game but not to Discord yet:

- the signs before a spawn ("A strange psychic disturbance is building near ...");
- a set appearing together (birds, beasts, Regis asleep, Latias and Latios). On Discord this
  becomes one post for the set, with a line per member;
- waking a sleeping Regi, and Mew showing its true self;
- Groudon and Kyogre clashing, and Rayquaza coming down to calm them;
- the reward messages.

The bridge also has its own hand-written legendary list (`056-discordBridge.lua`) that can
drift from the revamp's. It would read the revamp's species list, so new legendaries (Gen 4 to
6) need no Discord change.

### Events on the calendar

The game's calendar (`077-eventCalendar.lua`) already knows every event ahead of time:

- the holidays, by rule;
- the server events on a schedule, like the double weekends;
- staff events added with `/calendar`.

`EventCalendar.getEvents(from, to)` lists them, and `onThink` sees each one start and end.

- **Discord's event calendar:** the bot asks the game for the next 30 days every 15 minutes (a
  new `calendar.range` bridge request, read-only like the others). It creates a Discord
  scheduled event for each one, with name, start, end, description, bonuses and a cover image.
  Each is keyed by the game's event id, so the bot updates an event when its time or text
  changes and deletes it when staff remove it. Adding a holiday to `EventCalendar.HOLIDAYS` or
  a `/calendar` event is all it takes.
- **Start and end:** the start and end broadcasts become Event announcements, so they get the
  banner, the Discord post and the ping on their own.
- **Reminders:** an hour before an event starts, a short post in `#game-announcements` (a
  setting). Discord's own "Interested" button also reminds players who clicked it.
- **Staff bonus events too:** `/doubleexp`, `/bonusshiny` and the Day Care event announce the
  same way. Planned ones go on the calendar; ones started on the spot only get the
  announcement.
- **The bot needs** the Manage Events permission (shown as Create Events and Manage Events).

### Order of work

1. Call-out and recall bubbles, NPC trainers and orders (game and client only).
2. `doBroadcastMessage` categories, the `ANNOUNCEMENT` opcode and the new `game_newsbanner`
   module.
3. The rotating tips.
4. Discord announcements with the Verified Trainer and @everyone pings, and the `/b` tags.
5. The legendary Discord updates.
6. The calendar sync, start and end posts, and reminders.
7. Later: the personal red messages as cards.

Steps 4 to 6 need bot changes in PokeVerse-Discord, sent as patches in
`integrations/pokeverse-discord/patches/` like the legendary threads.

### To decide

- The banner's colours (a concept is in the PR for this plan).
- The tip list itself.

## Going private

Everything is ready ([client-updates.md](client-updates.md)). Switch this repository to
private once these features are in and the game is ready to go public. PokeVerse-Clients
stays public. A private repository gets 2,000 free GitHub Actions minutes a month.
