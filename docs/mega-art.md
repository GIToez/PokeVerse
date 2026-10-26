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

### Repainting our own sprites (proposed)

Where a Mega is too small, its normal form in our game can be painted into the Mega instead.
It keeps our size and art style, and changes only what the Mega changes:

- **Primal Groudon and Kyogre:** our 96 px Groudon (look 1562) and Kyogre (1561). The Primals keep
  the same body and add glowing lines: yellow and orange magma lines on Groudon, cyan lines on
  Kyogre, with the darker body colours. A good fit.
- **Mega Latias and Latios:** our 96 px Latias (1559) and Latios (1560), recoloured purple
  with the Mega's swept-back jet shape on the wings. Mega Latias has yellow eyes, Mega Latios red.
- **Alakazam, Slowbro and the same-size ones:** harder, because their Megas change shape
  (Mega Alakazam's beard and floating spoons, Mega Slowbro's shell over the body). These need a
  real redraw on top of our sprite, larger than the normal one.

Each is drawn here, shown to the trainer, and swapped onto its look with `scripts/dat-set-outfit.py`.

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
