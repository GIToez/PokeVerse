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

Sheet layout in the pack: 4 directions (N, E, S, W) across, animation frames down. Sheets that
are twice as wide have the colour mask column next to each direction; it goes in as the
outfit's second layer.
