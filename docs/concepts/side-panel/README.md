# Side panel concepts

The top HUD, the swap bar and the moves bar already have their own look. The right-hand side is
still Tibia's in shape, even after the D restyle ([ui-redesign.md](../../ui-redesign.md)), because
only the colours changed:

- a column of stacked, resizable boxes, each with a title strip and tiny header buttons;
- one box for every backpack you open, with a square slot grid inside;
- a square minimap with its coordinates underneath;
- the Battle List as rows of names;
- Skills as a text list (Level, Experience, Hit Points, Free Ball Slots...);
- an empty VIP box.

These concepts change the layout itself, not the colours. They are drawn over a real 1920x1080 frame
with the game's own item pictures, Pokemon portraits and the real Route 1 map. They keep the D colours
(navy, gold, light text), so they match the HUD that's already built.

| | |
| --- | --- |
| Today | ![Today](today.jpg) |
| A. Rotom Phone | ![A](concept-a-rotom-phone.jpg) |
| B. Pokegear | ![B](concept-b-pokegear.jpg) |
| C. Dock and drawers | ![C](concept-c-dock.jpg) |

The right side of each, at full size: [detail.jpg](detail.jpg). All four together: [board.jpg](board.jpg).

## The three directions

**A. Rotom Phone.** One device, Rotom's red body with its eyes, on the right edge.
- The screen has the time, the weather and the position, a rounded map, and an app row: Bag, Party,
  Dex, Quests, Trainer, Friends.
- The app you pick fills the rest of the screen.
- Nearby wild Pokemon stay outside the phone, as portrait cards with level and HP.
- Tab folds the phone down to just its map.
- The most "Pokemon" of the three, and the easiest to learn, since everything is in one place.
- It also covers the most of the map.

**B. Pokegear.** A round map hub, after HeartGold and SoulSilver.
- The ring around the map carries the time of day and the weather.
- The apps orbit the ring as round buttons, each with its key.
- The place name sits on a ribbon underneath.
- Nearby Pokemon are capsules with their portrait, level, type dots and HP.
- The Bag opens as a real Pokemon-game bag: pockets on the side, a list, and the selected item's
  description at the bottom.

**C. Dock and drawers.** The quietest, and made for Android too.
- A slim dock of round buttons sits on the edge, with a badge for new items or quests.
- The map is a lens inside a Poke Ball.
- Nearby Pokemon fold into a pill of portraits.
- Everything else is a drawer that slides out over the map, one at a time, and closes with Esc.
- The Bag drawer is a grid of big tiles with a search field and pocket filters.

## What replaces what

| Today (Tibia) | A | B | C |
| --- | --- | --- | --- |
| Minimap box | Rounded map on the phone screen | Round map in the ring | Poke Ball lens |
| Backpack boxes, one per bag | Bag app: one list by pocket | Bag: pocket rail, list, description | Bag drawer: tile grid, search, filters |
| Inventory box (Order, Pokedex, Badges, ring, ball) | Apps on the phone | Orbit buttons | Dock buttons |
| Battle List | Nearby cards under the phone | Nearby capsules | Nearby pill, opens to the list |
| Skills text | Trainer app (the Trainer Card) | Trainer orbit button | Trainer drawer |
| VIP box | Friends app | Friends orbit button | Friends drawer |
| Resizing, header buttons, scrollbars | Gone: fixed size, one app at a time | Gone | Gone |

Coordinates move to a tooltip on the map (or the staff view). Level and experience are already on the HUD.

## How it would be built

- **Classic and new.** Today's side windows stay as a **Classic** layout in Options. The new one is
  the default and is built on top of the same modules, so both keep working.
- **Bag.** Items stay in the server's backpacks; the tabs are only a different view of them.
  - The Bag uses the same tabs as the PC stash and the GTS, in the same order. All three read the
    server's `GTS.CATEGORIES`: Poke Balls, Medicine, Evolution Stones, Held Items, Mega Stones,
    Berries, Berry Seeds, Vitamins, Technical Machines and Other, plus All.
  - It uses an item by its id (`g_game.useInventoryItem`, the call the hotkeys use), so no backpack
    has to be shown.
  - What it can't open locally (bags inside bags) comes from the server on an extended opcode, the
    way the PC and the GTS already do.
  - The server sends the category list with the bag, so a new category shows up in all three windows
    at once.
- **Map.** The same minimap widget, with a round or rounded mask and new buttons, then the Pokepedia
  map behind a click. The real map pictures already exist (`scripts/mapper/render_pokepedia.py`).
- **Apps** reuse windows that are already built: the Trainer Card, the Pokedex, the Quest log,
  Pokepedia and the Daycare.
- **Nearby** reads the Battle List's data, so targeting and follow keep working.
- **Order of work.** Drop the old side column and add the Bag view first, because the backpacks are
  the most Tibia part. Then the map frame, then the app buttons, then Nearby.
- **Android.** All three fit on a phone. C needs the least change there.

## Picked so far

- **Pokegear (B)** for the map and the Bag.
- **The swap bar stays**, with its first slot redesigned (see Equipment).
- **Nearby** is its own window, separate from your Pokemon, and keeps the Battle List's filters.
- **Every window can be dragged.**
- **Default keys:** E Order, F key item, X Pokedex, R Mega Evolution.

| | |
| --- | --- |
| Pokegear, all together | ![Pokegear layout](pokegear-layout.jpg) |
| Chat, folded | ![Chat folded](chat-folded.jpg) |
| Chat, open | ![Chat open](chat-open.jpg) |
| Equipment | ![Equipment](equipment.jpg) |
| Top bar | ![Top bar](topbar.jpg) |

**Pokegear, all together.** The ring map with its app buttons, Nearby and the Bag are separate windows.
- Drag a window by its header; the hub has a tab under the ring for this. Windows snap to the
  screen edges and to each other.
- The layout is saved per character. Lock windows and Reset layout go in the gear menu.
- **Nearby** keeps the PokeVerse Battle List's filters and sorts:
  - filters: Wild, Trainers, NPCs, Party (`hideMonsters`, `hidePlayers`, `hideNPCs`, `hideParty`);
  - sorts: distance, HP, name, level;
  - Ctrl+B still toggles it.
- **The Bag** is the Pokegear bag: All plus the PC's and the GTS's pockets on the rail, a list, and the
  selected item's description.

**Chat.** No docked box with tabs along the bottom.
- **Folded (the default).**
  - The last few lines float over the bottom left of the map and fade after a few seconds. Each line
    starts with its channel's tag.
  - An input pill shows the channel and "Press Enter to chat".
  - A friend who messages you shows up as a face with a count.
- **Open.**
  - A rounded card. Channels are chips: Local, Global EN, Help, NPCs, and + to join more.
  - DMs are faces on the right of the header.
  - Shift-click an item or a Pokemon to put a link chip in the message. Staff get a badge.
- **NPCs** get an NPC tag and their own colour, teal (#42e0c4), which no player channel uses. NPC lines
  stay apart from players even in Local. The colours:

  | Channel | Colour |
  | --- | --- |
  | Local | White |
  | Global | Blue |
  | Help | Green |
  | NPC | Teal |
  | DM | Purple |
  | You | Gold |
  | Staff | Red badge |

- **The Server Log** turns into toasts that slide away (catches, loot), plus an Activity list behind a
  bell in the top bar.

**Equipment.** There is no equipment window. Each slot moves to where it is used:

| Slot today | Goes to |
| --- | --- |
| Pokemon (the one that's out) | Slot 1 of the swap bar: big, with its portrait, name, level and HP. Swapping puts the new one in slot 1 and sends the old one back to its slot, so no slot sits empty |
| Order (helmet) | A button on slot 1, since it commands that Pokemon (E) |
| Key item | A socket left of the HUD (F): click to use, right-click to pick another key item. The Ranger radar and the Fishing guide go here too |
| Pokedex (sword) | Its own socket right of the HUD (X). Not a key item |
| Badges (shield), Balls, Respect | The Trainer card |
| Bag | The Bag |
| Evolve, Duel | Unused, so they go |

**Key chips show the key that is bound now, not the default.**
- Each chip reads `Keybind.getKeybindKeys(category, action)`, which uses the current preset and chat
  mode.
- With chat on, letter keys are unbound, so their chips hide.
- `keybind.lua` has no event when a key changes. `setPrimaryActionKey`, `setSecondaryActionKey`,
  `selectPreset` and `setChatMode` need to send one, so the chips can refresh.

**Top bar.** The buttons in the top-right row, left to right, in the groups that
`sortTopBar` (patches/game_mainpanel.patch) puts them in:

| Group | Buttons (key) | Goes to |
| --- | --- | --- |
| Adventure | Pokepedia (M), Tasks (T), Quest Log (L), Daily login reward, Pokepedia tracker | Dex app, Quests app (with a Tasks tab), a popup at login, a Tracking chip under the map |
| Side windows | Minimap, Inventory, Skills, Battle List, VIP | Gone: these are the windows the redesign replaces |
| System | Item hotkeys (Ctrl+K), Audio, Options, Exit (Ctrl+L) | One gear button with a menu |
| Other windows | Trainer Card (P), Vocation (V), Admin (staff), Reports, Analyser | Trainer app (with a Vocation tab), the gear menu, Activity |
| | Store | Stays |

The Ranger radar (U) and the Fishing guide (U) are hidden until unlocked. The minimap has its own
buttons too: a dial with the time of day (a click on its rim walks that way), a floor ladder, zoom
and the full map. The new map shows the time on its frame, has floor arrows and zooms with the
mouse wheel; M still opens the full map. That leaves the top bar with status on the left and the
bell, the gear and the Store on the right.

## To decide

1. Bag as a list (as drawn) or a tile grid.
2. Whether items like the Mega Ring, rods and the Badge Case get a Key Items tab in the Bag, the PC
   and the GTS. Today they fall under Other. The Key Item socket argues for one.
3. Whether the chat starts folded or open for new players.
