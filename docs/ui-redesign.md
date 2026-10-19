# PokeVerse UI redesign

The side windows (Inventory, Battle List, Tracker, Simple pokebag, Trainer belt, Skills, containers) are
still Redemption's Tibia `MiniWindow`: a 17 px header strip, a row of tiny header buttons, square slots
and a thick scrollbar, only recoloured navy. The top HUD (trainer, Pokemon and energy) is already the
modern look; this redesign brings the side windows, popups, the swap bar and the moves bar to it.

## Concept boards

`scripts/art/ui_concept.py --shot <forest battle screenshot>` draws three directions over a real
1920x1080 screenshot into `build/ui-concept/`: `board.png` (all three, with each right column at twice
the size), `concept-<a|b|c>.png` and `detail-<a|b|c>.png` (the popup and both bars, twice the size).

| Direction | Look |
| --- | --- |
| A. Pokedex Glass | Floating rounded navy cards with a thin blue edge, a gold title accent and a soft shadow, like the HUD. The map shows between the cards; there is no solid panel frame. |
| B. Trainer Gear | Red Poke Ball headers over white bodies, ball-socket slots. Brighter and more "Pokemon", but loud next to the map and the HUD. |
| C. Minimal HUD | Translucent dark cards with no header bar: a small icon tab and the title in capitals. Quiet, but harder to tell windows apart. |

**Chosen: D**, a mix of A and C: C's see-through cards with A's navy and gold, light text with a dark
outline so it reads over the map, and the inventory Poke Ball next to the Pokemon head. The tokens
live in `scripts/art/ui_kit.py` (the concept itself is `ui_concept.py --theme d`), so a change of colour
or opacity is one rerun away.

## Tokens (D)

| Token | Value | Use |
| --- | --- | --- |
| body | `#0e1729` at 72% (side cards), 94% (popups) | card and window fill |
| edge | `#375284` at 50% | 1 px card edge |
| accent | `#d9aa3b` | title underline, the active Pokemon, the primary button |
| text | `#eef2ff` | titles and text |
| muted | `#b4c2dc` | labels, hints |
| slot | `#0a121f` at 55% | item and move slots |
| chip | `#060a14` | key chips, energy cost, counters |
| hover | `#283e68` | hovered buttons and sockets |
| radius | 7 (side cards), 6 (popups), 9 (move slots) | |
| type edges | one colour per element (`TYPE_COLORS`) | move slots |

Header: 20 px with the window's icon, the title in verdana 11 rounded with a 22 px gold underline, and
round buttons on the right. A title that doesn't fit switches to the narrower font, then is cut with
".." and shows the full name as a tooltip.

## How it is applied

- `scripts/art/ui_kit.py` draws every 9-slice image from the tokens. The images that the engine's own
  styles use (`miniwindow_body`, `miniwindow_header`, `miniwindow_buttons`, `scrollbar`, `buttons`,
  `item`, `window`) are written under their Redemption names in
  `core/client-redemption/pokeverse-modern/data/images/ui/`; the PokeVerse ones go to
  `pokeverse-modern/data/images/pokeverse-ui/`.
- The header widgets are created by each module, so `UIMiniWindow` (corelib patch) restyles the
  title, icon and underline in Lua.
- `pokeverse-modern/data/pokeverse-styles/` loads after Redemption's `/styles/`
  (`modules/client_styles/styles.lua`), so a `MiniWindow`, `MainWindow` or `GameSidePanel` defined
  there replaces the default in every module at once.

## Replacement checklist

### Side windows (MiniWindow)
- [x] MiniWindow base: header, round buttons, see-through body, scrollbar, resize border (`pokeverse-styles/miniwindow.otui`, header in the corelib patch)
- [x] Side panels: no solid frame, gaps between cards (`GameSidePanel` in the game_interface patch)
- [x] Inventory (`game_inventory`): Order, Dex, Badges on top, then ring, Pokemon head, Poke Ball, bag
- [x] Battle List, Tracker, Simple pokebag, Trainer belt, Skills: through the MiniWindow base
- [ ] Minimap: rounded frame, coordinate chip, zoom pill
- [ ] Battle List rows: HP bars and level badges, target in gold
- [ ] VIP list, trade window, and the Redemption trackers if reachable

### Popups
- [x] The shared window image (`game_dailytasks/images/window`) used by dailytasks, pokepedia, quests,
  fishing, calendar, daycare, vocation, trainercard, badgecase, radar, admin, pokemonshop, hotkeys,
  hints, client_options
- [x] `MainWindow` / `Window` (`/images/ui/window`): PC, GTS, daily login, message boxes, Redemption leftovers
- [x] Buttons and scrollbars (`pokeverse-styles/controls.otui`, `buttons`, `scrollbar`)
- [ ] TabBar, ComboBox, TextEdit, CheckBox, ProgressBar
- [ ] Login, create-character and background screens

### Bars
- [x] Swap bar (`game_pokebar`): round portrait sockets with an HP ring, F-key chip, gold ring on the
  Pokemon that's out, "FNT" when fainted
- [x] Moves bar (`game_pokemoves`): rounded slots with the move's type edge (the server sends the
  element with the energy costs), key chip, energy cost chip, cooldown sweep
