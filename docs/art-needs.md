# Sprites that need changing

Art in the game that the trainer wants replaced, plus forms with no art yet. Size checks use the
true-size sheets: 32 px tiles, trainer look 612 for scale. The full review sheet of every look is on
the `cursor/pokemon-sheet-c8d5` branch (`review/pokeverse-pokemon-sheet.pdf`).

## Replace

| Pokemon | Look (shiny) | Problem | Wanted |
| --- | --- | --- | --- |
| Mewtwo | 501 (849) | Too small: about 40 px tall, smaller than Mega Mewtwo Y (51-56 px) | About 56 px tall like Armored Mewtwo (pack 8128), no armor. PokeZHero and the 6500 pack have no bigger plain Mewtwo, so it has to come from another sprite resource or an artist |
| Shiny Treecko | 1811 (normal 1431) | The shiny is a different sprite from the normal Treecko | A recolour of the normal sprite, as done for Shiny Charmeleon (670) |
| Mega Lucario | 2606 | Small; the pack also lists this sheet as plain Lucario | Bigger art |
| Mega Altaria | 2620 | About the same size as Altaria | Bigger art |
| Mega Latias, Mega Latios | 2626, 2684 | 64 px sheets, smaller than our 96 px Latias and Latios | Bigger art |

## No art yet

| Form | Notes |
| --- | --- |
| Mega Mewtwo X | Nothing found in PokeZHero or the 6500 pack |
| Mega Medicham | PokeZHero's look 1915 is not Medicham |
| Mega Aggron, Garchomp, Manectric, Houndoom, Gallade, Lopunny, Feraligatr, Meganium | No candidate fits ([mega-art](mega-art.md#still-to-find)) |
| Mega Heracross, Pinsir, Rayquaza | Nothing found |

## Planned uses of existing art

- **Armored Mewtwo** (pack 8128, 96 px sheet, about 56 px tall): a boss. Not added yet; it needs a spawn, level, moves and drops.
