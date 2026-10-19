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

**Chosen: A.** It matches the HUD, the Pokepedia, quests and tasks windows, which already use the
navy and gold palette, so one kit covers everything. The tokens below live in `scripts/art/ui_kit.py`,
so B or C stay one rerun away.

## Tokens (A)

| Token | Value | Use |
| --- | --- | --- |
| body | `#0e1729` at 90% | card and window fill |
| header | `#13203a` at 95% | header band |
| edge | `#375284` | 1 px card edge |
| accent | `#d9aa3b` | title underline, the active Pokemon, selection, the primary button |
| text | `#e8ecf4` | text |
| muted | `#96aacd` | labels, hints |
| slot | `#0a121f`, edge `#2c4470` | item and move slots |
| chip | `#1b2a46` | key chips, level badges, counters |
| health | `#43c271`; low `#e0566a` | HP bars and rings |
| energy | `#9366ed` | energy cost chips |
| radius | 8 (cards), 6 (slots), 10 (move slots) | |
| type edges | fire `#f08a3c`, water `#4f9cf0`, grass `#5cc46a`, electric `#f2cf3a`, flying `#8fb6f0`, dragon `#8c6cf0` ... | move slots |

Header: 24 px with the window's line icon and a bold 11 px title, a 2 px gold underline under the
icon, and three round buttons on the right (minimise, menu, close). The menu holds lock, filters and
"open in new window", which are separate tiny buttons today.

## How it is applied

- `scripts/art/ui_kit.py` draws every 9-slice image from the tokens. The images that the engine's own
  styles use (`miniwindow_body`, `miniwindow_header`, `miniwindow_buttons`, `scrollbar`, `buttons`,
  `panel`) are written under their Redemption names in
  `core/client-redemption/pokeverse-modern/data/images/ui/`; the PokeVerse ones go to
  `pokeverse-modern/data/images/pokeverse-ui/`.
- `pokeverse-modern/data/pokeverse-styles/` loads after Redemption's `/styles/`
  (`modules/client_styles/styles.lua`), so a `MiniWindow`, `MainWindow` or `GameSidePanel` defined
  there replaces the default in every module at once.

## Replacement checklist

### Side windows (MiniWindow)
- [ ] MiniWindow base: header, buttons, body, scrollbar, resize border (`pokeverse-styles/miniwindow.otui`)
- [ ] Side panels: no solid frame, gaps between cards (`GameSidePanel`, `pokeverse-styles/sidepanel.otui`)
- [ ] Minimap (`game_minimap`, PhantomMiniWindow): rounded frame, coordinate chip, zoom pill
- [ ] Inventory (`game_inventory`): Order, Dex, Badges as labelled tiles, new slots, Balls and Respect chips
- [ ] Battle List (`game_battle`): rows with HP bars and level badges, target in gold
- [ ] Tracker (`game_pokepedia/tracker.otui`)
- [ ] Simple pokebag and Trainer belt (`game_containers` ContainerWindow; `game_pokehud/belt.lua`)
- [ ] Skills (`game_skills`)
- [ ] Health info and main options panel (`game_healthinfo`, `game_mainpanel`, PhantomMiniWindow)
- [ ] VIP list, trade window, and the Redemption trackers if reachable (analyser, prey, bestiary, imbuements, quest log, task board)

### Popups
- [ ] One shared `PvWindow` style; move the modules that point at `game_dailytasks/images/window` to it:
  dailytasks, pokepedia, quests, fishing, calendar, daycare, vocation, trainercard, badgecase, radar,
  admin, pokemonshop, hotkeys, hints, client_options
- [ ] Move `game_pc`, `game_gts`, `game_dailylogin` off `MainWindow`
- [ ] Base `MainWindow` / `StaticMainWindow` / `Window` for anything else (Redemption leftovers, message boxes)
- [ ] Controls: Button, ScrollBar, TabBar, ComboBox, TextEdit, CheckBox, ProgressBar (`pokeverse-styles/controls.otui`)
- [ ] Message boxes and top menu (`pokeverse-styles/messageboxes.otui`, `topmenu.otui`)

### Bars
- [ ] Swap bar (`game_pokebar`): round portrait sockets with an HP ring, F-key chip, gold ring on the
  Pokemon that's out, faded when fainted
- [ ] Moves bar (`game_pokemoves`): rounded slots with a type edge, key chip, energy cost chip, lock
  badge with the level, radial cooldown with the seconds
