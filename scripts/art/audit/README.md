# Art audit scripts

These scripts make [docs/art-audit](../../../docs/art-audit/README.md).

## Before you run them

- Run them from a scratch folder. They write `.pkl` files and `pg/*.png` there.
- Copy `docs/sprite-pack-review/rename_plan.csv` and `master_full.csv` into that folder first.
- `core/client-legacy/data/things/*/data.spr` must be the real file, not the LFS pointer, so
  run `git lfs pull` first.
- `PADV` is a checkout of [padventures-sprites](https://github.com/DistTopic/padventures-sprites)
  (default `/tmp/padv/`).
- `PACK6500` is the unzipped 6500 pack folder (default `/tmp/sprites6500/6500 sprite pokemon/`).

## Order

1. `ours.py` indexes our looks. `padv.py`, `pack.py` and `cross.py` then match the two
   sources against ours and against each other.
2. `trainers.py` and `pages.py` find the trainer outfits we lack and draw them.
3. `near.py` and `cand.py` find PAdventures sprites closest to our Pokémon.
   `packpages.py 07 pg/costume` and `packpages.py 09 pg/other` draw the pack's costume and
   other-art folders next to ours.
4. `review.py docs/art-audit/review` draws the better-art review pages and writes
   `better_art_picks.csv`. `costumes.py` and `addons.py` draw the costume and add-on sheets.
   
5. `export.py` writes the CSVs and copies the sheets into `docs/art-audit`.
