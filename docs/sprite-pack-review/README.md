# "6500 sprite pokemon" pack review

The pack (7,249 PNG sheets, `outfit_<n>_.png`) sorted by content. The file numbers are not
reliable, so everything was matched by pixels. Sources: `scripts/art/sprite_pack/`.

| Status | Sheets |
| --- | --- |
| Exact duplicate of another sheet in the pack | 1,767 |
| Same tiles as an outfit we already have | 1,069 |
| To import | 4,413 |

The sheets to import that are not already named from our files are grouped by shape (recolours
and shinies of the same sprite share a shape) into 3,186 codes like `P12-30`, shown on
`pages/page_NN.png` (front and side view, `C` = colourable player outfit with a colour mask).

- `master_review.csv`: one row per code with the first-pass name, use (walk, ride, fly, surf,
  dive, outfit, effect, other), confidence, dex number, generation (forms count from their
  own generation: Mega 6, Alolan 7, Galarian 8) and the files in the group. The last-but-one
  columns are left blank for corrections.
- `master_full.csv`: every pack file with its status, code and name.
- `names/page_NN.json`: the first-pass names per page.
- `new_species.csv`: one row per Pokémon past #386 found in the pack, with its best confidence,
  the uses seen (walk, ride, fly, ...) and the codes to look at.

Pokémon past #386 in the pack (`?` names in `new_species.csv` are low-confidence guesses):

| Gen | Species | In the pack | Low confidence | Not in the pack |
| --- | --- | --- | --- | --- |
| 4 | 107 | 53 | 21 | 33 |
| 5 | 156 | 122 | 15 | 19 |
| 6 | 72 | 4 | 13 | 55 |
| 7 | 88 | 4 | 6 | 78 |
| 8 | 96 | 2 | 1 | 93 |
| 9 | 120 | 0 | 0 | 120 |

Sheet layout in the pack: 4 directions (N, E, S, W) across, animation frames down. Sheets that
are twice as wide have the colour mask column next to each direction; it goes in as the
outfit's second layer.

## Sorting the Drive folder

`rename_plan.csv` gives every pack sheet in the Drive folder (by file id) a readable name like
`0452 Drapion - walk #3781.png` (`#3781` is the old `outfit_3781_.png` number, `unsure` marks a
low-confidence name) and a subfolder:

| Folder | Sheets |
| --- | --- |
| 00 Fills a gap in our game | 3 |
| 01 Already in our game (do not import) | 1,036 |
| 02 to 06 New Pokemon - Gen 4 to Gen 8 | 668 |
| 07 Pokemon wearing outfits (costumes) | 156 |
| 08 Recolours and edits of Pokemon we have | 502 |
| 09 Other art for Pokemon we have (Gen 1-3) | 656 |
| 10 Forms (Mega, Alolan, Galarian, Primal) | 189 |
| 11 Trainer outfits | 863 |
| 12 Effects | 87 |
| 13 NPCs, items and other | 58 |
| 14 Not named yet | 1,206 |
| 15 Exact duplicates | 1,765 |

Costumes are sheets whose pixels mostly match a plain sprite of the same Pokémon with extra
pixels added (hats, scarves, outfits). Files that were already renamed by hand are left alone.

`drive_sort.gs` applies it: paste it into a new project at script.google.com, run `sortPack` and
allow Drive access. It works about five minutes at a time and schedules itself until all files
are done (it logs its progress under Executions). `undoSort` puts the old names back.
