# Mega Evolution art

The Mega walk sprites and the item icons in the client (`core/client-legacy/data/things`), for
[Mega Evolution](upcoming-features.md#27-mega-evolution-planned-not-built). Nothing in the game uses them yet: the
forms, items and drops are still to build. The sprites are placeholders chosen by the trainer
on October 25 from the "6500 sprite pokemon" pack ([sprite-pack-review](sprite-pack-review/)), drawn in with
`scripts/dat-set-outfit.py`. Many need rework later; see the notes.

## Walk sprites (outfits)

"Size" compares the Pokemon's drawn height and width with its normal form's, from the pack
sheets (100% = same size). A Mega should be clearly bigger than its normal form.

| Look | Mega | Pack file | Tile | Size | Rework |
| --- | --- | --- | --- | --- | --- |
| 2595 | Venusaur | 1863 | 64 | 100% | same size as Venusaur |
| 2596 | Charizard X | 8231 | 96 | 123% | |
| 2597 | Charizard Y | 8233 | 96 | 126% | |
| 2598 | Blastoise | 1657 | 64 | 115% | |
| 2599 | Alakazam | 1853 | 64 | 79% | too small: smaller than Alakazam |
| 2600 | Gengar | 1851 | 64 | 197% | |
| 2601 | Kangaskhan | 2060 | 64 | 109% | |
| 2602 | Ampharos | 1858 | 64 | | |
| 2603 | Ampharos, shiny | 2134 | 64 | | too red: shiny Mega Ampharos is pink with a white mane and blue orbs, like the trainer's upload |
| 2604 | Tyranitar | 1854 | 64 | 107% | |
| 2605 | Blaziken | 1857 | 64 | 115% | |
| 2606 | Lucario | 16 | 64 | 100% | needs better art; small, and the pack also lists this sheet as plain Lucario |
| 2607 | Beedrill | 79 | 64 | 152% | |
| 2608 | Pidgeot | 2081 | 64 | | |
| 2609 | Slowbro | 6140 | 64 | 91% | too small: smaller than Slowbro |
| 2610 | Gyarados | 6139 | 128 | | |
| 2611 | Gyarados, shiny | 8037 | 128 | | |
| 2612 | Aerodactyl | 2061 | 64 | 100% | same size as Aerodactyl |
| 2613 | Steelix | 2138 | 96 | 102% | same size as Steelix; white swirl rings around it in the sheet |
| 2614 | Scizor | 1892 | 64 | 105% | about the same size as Scizor |
| 2615 | Sceptile | 2071 | 64 | 109% | |
| 2616 | Swampert | 7156 | 64 | 104% | about the same size as Swampert |
| 2617 | Sableye | 2070 | 64 | 112% | |
| 2618 | Sharpedo | 8120 | 64 | 159% | |
| 2619 | Camerupt | 5853 | 96 | 127% | |
| 2620 | Altaria | 2062 | 64 | 103% | needs work (trainer); about the same size as Altaria |
| 2621 | Absol | 6414 | 64 | 109% | |
| 2622 | Glalie | 2066 | 64 | 153% | |
| 2623 | Abomasnow | 6136 | 96 | 130% | |
| 2624 | Audino | 6211 | 64 | 165% | recolour: Mega Audino is white and cream, not pink |
| 2625 | Mawile | 1859 | 64 | 127% | |
| 2626 | Latias | 4089 | 64 | 75% | too small: our Latias is 96 px. Mega Latias has yellow eyes, Mega Latios red |
| 2627 | Primal Groudon | 4099 | 64 | 55% | too small: our Groudon is 96 px |
| 2628 | Primal Kyogre | 4098 | 64 | 55% | too small: our Kyogre is 96 px |
| 2629 | Dragonite | 8261 | 96 | 127% | |

Ampharos, Pidgeot and Gyarados have no size: their normal forms' pack sheets weren't found.

Shiny Megas without their own sheet will be recolours of the normal one (see the plan).

### Still to find

None of the candidates fit for these: Aggron, Metagross, Garchomp, Manectric, Houndoom,
Gallade, Lopunny, Diancie (the one found looks unfinished), Feraligatr, Meganium (pack 8191 is
close but not right) and Mega Latios. Nothing was found for Mewtwo X and Y, Heracross, Medicham,
Banette, Pinsir, Rayquaza or Salamence, nor for the other Legends: Z-A Megas.

### Things to watch when reworking

- **Too small:** a Mega that isn't clearly bigger than its normal form reads as the same
  Pokemon. Scaling a 64 px sheet up to 96 px doubles its pixels and looks blocky next to the rest,
  so redraw or find a bigger sheet instead.
- **Pixelated:** sheets that were scaled up by their artist show square double pixels; check at
  1x in game.
- **Doesn't match the art:** compare with the official Mega design (Bulbapedia) for colours,
  eye colour and shape, and with our normal form so the outline style is the same.
- **Shinies:** compare with the official shiny colours.

## Item icons

Each item has its own 32x32 picture in data.spr, added by `scripts/dat-add-sprite-items.py` as
copies of the Everstone (client 28780: still, pickupable). The server items (items.otb and
items.xml) are still to add.

| Client ids | Items |
| --- | --- |
| 28818 | Empty Mega Ring |
| 28819 | Key Stone |
| 28820 | Mega Ring |
| 28821-28867 | the 47 X/Y and Omega Ruby/Alpha Sapphire stones, in the plan's order (Venusaurite to Diancite) |
| 28868-28893 | the 26 Legends: Z-A stones (Clefablite to Falinksite) |
| 28894-28912 | the 19 Mega Dimension stones (Raichunite X to Glimmoranite) |
| 28913 | Red Orb |
| 28914 | Blue Orb |

The icons are PokéAPI's `sprites/items/<name>.png`.

- The 47 older stones, the orbs and the Key Stone are game pixel art (30x30, put on 32x32).
- The Legends: Z-A and Mega Dimension stones only exist as 160 px artwork, shrunk here to 15 px
  and cut to a small palette. They are readable but softer than the pixel-art ones; redraw them
  by hand if they look off in the bag.
- PokéAPI's Mega Ring is a bare ring, so it is the **Empty Mega Ring** here. The **Mega Ring** is
  that ring with a shrunk Key Stone set on top; redraw it if it looks pasted on.

## The first four forms

Mega Venusaur, Mega Charizard X and Y and Mega Blastoise are playable (staff `/mega` for now).
`scripts/art/mega_forms_art.py` makes their art from the pack sheets, Pokémon Showdown and pokesprite.

| Form | Look | Shiny look | Face (server / client) | Shiny face (server / client) |
| --- | --- | --- | --- | --- |
| Mega Venusaur | 2595 | 2630 | 30272 / 28915 | 30273 / 28916 |
| Mega Charizard X | 2596 | 2631 | 30274 / 28917 | 30275 / 28918 |
| Mega Charizard Y | 2597 | 2632 | 30276 / 28919 | 30277 / 28920 |
| Mega Blastoise | 2598 | 2633 | 30278 / 28921 | 30279 / 28922 |

- **Shiny looks** are recolours of the normal sheet, not drawn art. Venusaur and Blastoise use a
  colour map learned from Showdown's normal and shiny sprites; the Charizards use hand-picked hue
  rules. Shiny Mega Charizard Y keeps the normal orange tail flame (`keep_flame`).
- **Faces** (the 4-frame portrait in the Pokemon bar) are pokesprite's box icons with a small bob,
  smaller and plainer than our other faces. Redraw them when the Megas get their own art.
- **Client images:** `staticPortraits/<dex>-<form>.png` (Showdown gen 5),
  `pictures/<dex>-<form>.png` (Showdown 3D still) and `pokeicons/<dex>-<form>.png` (pokesprite), for
  example `6-mega-x.png`. Nothing reads them yet; the Mega HUD and the Pokedex will.
- **Standing on the tile:** the pack draws a Pokemon centred in its frame, our outfits stand on the
  bottom right tile. `scripts/art/mega_align.py` lines each Mega's feet up with its base form: a
  signed outfit offset (dat attribute 25; the client reads it signed and only moves the sprite, not
  the name bar) plus small per-direction shifts. Run it again after drawing in a Mega sheet.

## The other Megas and the Primals

Every Mega with a walk sprite above whose Pokemon is in the game, and Primal Groudon and Kyogre,
built the same way (`scripts/art/mega_forms_art.py`). Faces are server items 30280-30326 drawing
client items 28923-28969, normal then shiny for each form in this order.

| Form | Look | Shiny look | Ability |
| --- | --- | --- | --- |
| Mega Beedrill | 2607 | 2634 | Adaptability |
| Mega Pidgeot | 2608 | 2635 | No Guard |
| Mega Alakazam | 2599 | 2636 | Trace |
| Mega Slowbro | 2609 | 2637 | Shell Armor |
| Mega Gengar | 2600 | 2638 | Shadow Tag |
| Mega Kangaskhan | 2601 | 2639 | Parental Bond (new) |
| Mega Gyarados | 2610 | 2611 (pack sheet) | Mold Breaker (new) |
| Mega Aerodactyl | 2612 | 2640 | Tough Claws |
| Mega Ampharos | 2602 | 2603 (now a recolour) | Mold Breaker (new) |
| Mega Steelix | 2613 | 2641 | Sand Force (new) |
| Mega Scizor | 2614 | 2642 | Technician |
| Mega Tyranitar | 2604 | 2643 | Sand Stream |
| Mega Sceptile | 2615 | 2644 | Lightning Rod |
| Mega Blaziken | 2605 | 2645 | Speed Boost |
| Mega Swampert | 2616 | 2646 | Swift Swim |
| Mega Sableye | 2617 | 2647 | Magic Bounce (new) |
| Mega Mawile | 2625 | 2648 | Huge Power |
| Mega Sharpedo | 2618 | 2649 | Strong Jaw (new) |
| Mega Camerupt | 2619 | 2650 | Sheer Force (new) |
| Mega Altaria | 2620 | 2651 | Pixilate (new) |
| Mega Absol | 2621 | 2652 | Magic Bounce (new) |
| Mega Glalie | 2622 | 2653 | Refrigerate (new) |
| Mega Latias | 2626 | none | Levitate |
| Primal Kyogre | 2628 | none | Primordial Sea (new) |
| Primal Groudon | 2627 | none | Desolate Land (new) |

Shiny Latias, Groudon and Kyogre aren't in the game, so their forms have no shiny.

- **The Primals** are our own 96 px Groudon (1562) and Kyogre (1561) repainted in the Primal
  colours from Showdown, replacing the 64 px pack placeholders on 2627 and 2628. Groudon's glowing
  lines are only the thin seams between its plates, far fewer than the official design: paint the
  magma lines in by hand. Kyogre's red markings became the glowing cyan lines; its mouth is cyan
  too and should stay dark.
- **Shiny recolours to rework:** Mega Alakazam and Mega Blaziken barely change, and Mega Altaria's
  cloud gets an orange rim (its shiny is a yellow-tinted cloud). The colours come from Showdown's
  normal and shiny sprites, so a pack sheet drawn in other colours picks up odd ones.
- **Not built:** Mega Lucario, Abomasnow and Audino (the Pokemon aren't in the game), Mega Dragonite
  (no box icon for its face yet) and every Mega in "Still to find". Mega Latias is still the small
  64 px sheet, and the faces are still pokesprite box icons.
