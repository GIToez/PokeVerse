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

## To decide

1. Which direction, or which mix. For example: B's ring map and Nearby, with C's drawers for the Bag.
2. Bag as a list (A, B) or a tile grid (C).
3. Whether Nearby shows only wild Pokemon, or trainers and NPCs too.
4. Whether items like the Mega Ring, rods, the Pokedex and the Badge Case get a Key Items tab.
   Today they fall under Other in the PC and the GTS too.
