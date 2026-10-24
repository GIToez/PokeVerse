# Art for new Pokémon (#387 and up)

Research notes for adding Pokémon past Deoxys. Nothing here is imported yet. To see the
sources next to our own art, run:

    git lfs pull --include core/client-legacy/data/things/data.spr
    python3 scripts/art/new_pokemon_art_preview.py /tmp/pv-newart/out

## What a Pokémon needs

| Art | Where it lives | Format | Have |
| --- | --- | --- | --- |
| Portrait | `images/staticPortraits/<dex>.png` | 96x96 PNG | 1–386 |
| 3D Pokédex picture | `images/pictures/<dex>.png` | 100x100 PNG still (big Pokémon are bigger) | 1–386 |
| Box icon | `images/pokeicons/<NNN>.png` | PNG | 1–386 |
| Swap bar face (`portrait` / `fastcallPortrait`) | item sprite in `data.dat`/`data.spr` | 32x32, 4 hand-drawn frames, dark outline | 1–386 |
| Dex face (`dexPortrait`) | item sprite | 32x32, 1 frame | 1–386 |
| In-game walk sprite (`<look type>`) | outfit in `data.dat`/`data.spr` | 4 directions (N, E, S, W) x 3 frames, 32x32 or 64x64 | 1–386 |

Face ids are not in one block: Gen 1 faces are client items 10635–10785, Gen 2 15999–16098 and
Gen 3 27244–27379. New item art does not have to go into `data.spr`: `scripts/dat-add-items.py`
adds items, and an `image:` entry in `things.otml` draws a PNG instead (still items only).

## Sources

**Portraits: exact match.** Our `staticPortraits` are Pokémon Showdown's Gen 5 sprites
(Bulbasaur is pixel-identical). Showdown has the same style for every Pokémon up to Gen 9:
`https://play.pokemonshowdown.com/sprites/gen5/<name>.png`. Gen 6–9 ones are fan-made by the
Smogon sprite project and they ask for credit.

**3D Pokédex pictures: same style.** Our `pictures` are stills of the 3D models; Showdown's
animated models are the same size and style: `https://play.pokemonshowdown.com/sprites/ani/<name>.gif`
(also `xyani/`). Every Pokémon tried exists (Turtwig, Chespin, Sprigatito, ...). `gen5ani/` is
missing Gen 6+.

**Swap bar faces: close, needs conversion.** Ours are pixel redraws of the Pokémon Shuffle icons
(same poses). Shuffle covers up to #809 only; the 256x256 icons are on Bulbagarden Archives as
`File:Shuffle<NNN>.png`. The preview script shrinks them to 32x32, cuts them to 20 colors and adds
the outline. Two gaps:
- the 4-frame idle is a placeholder bob; ours are hand-animated;
- Gen 8–9 have no Shuffle art. The only full set is the Mystery Dungeon portraits
  (`PMDCollab/SpriteCollab`, `portrait/<dex>/Normal.png`, 40x40), which are square painted busts
  and do not match.

**Swap bar faces for #387–718: ready in `art/sprites/faces/<dex>/0.png` to `3.png`.** They are
the Pokémon Battle Trozei "Small Pokémon Icons" (spriters-resource.com, 3DS, asset 64891), cut
out by `scripts/art/trozei_faces.py` and kept at their own 64x64: shrunk to our 32x32 they look
blurry. They bob like ours: 4 frames that lift the face 0, 2, 4 and 2 pixels (ours lift 0, 1, 2
and 1 at half the size). They do not blink yet; some of ours do, and that needs the eyes redrawn
per Pokémon. Our own faces for #1–386 stay; these only fill the gap. When a new Pokémon is added
its face is drawn with an `image-frames: /images/faces/<dex> 4` line in `things.otml` (the
folder copied to `data/images/faces/<dex>/`), on a 4-phase face item of 2x2 tiles so it is not
scaled down, and the swap bar slot sized to match. Gen 7–9 are not on the sheet.

**Chosen instead (October 24): PAdventures' 32x32 faces** (items 13825 to 14591, Gen 1 to 6),
which are these Trozei drawings cropped to fill the square and cleaned up by hand. They match
our Gen 1 to 3 faces and fit the current slot. The face for each Pokémon is in
[`gen4-6-checklist.csv`](gen4-6-checklist.csv).

**In-game walk sprites: Mystery Dungeon sprites are the best fit.** After Gen 5 the games are 3D,
so there are no official top-down sprites. `PMDCollab/SpriteCollab` has hand-made pixel walk
animations for every Pokémon through Gen 9, in 8 directions:
`sprite/<dex>/Walk-Anim.png` with frame sizes in `sprite/<dex>/AnimData.xml`. Rows 0, 2, 4 and
6 are S, E, N and W. They are about half our size; pixel-doubled they match our 64x64 sprites
in size and outline. They have more walk frames than our 3, so frames would be picked or the
outfit given more frames. Licence: credit the listed contributors (see the repo's credits files).

In use: Deoxys is the PAdventures art (used with permission): Normal Forme on look 1565 and the
other formes on new looks, Attack 2592, Defense 2593 and Speed 2594. All four are 3x3 tiles with
5 walk frames, from PAdventures creatures 45480, 45479, 45481 and 45482. Nothing switches between
the formes yet.

**PAdventures walk sprites: in our own format, but another server's art.**
`DistTopic/padventures-sprites` on GitHub is an extraction of the PAdventures client: 8,256
creature sheets, unnamed, 4 directions with frames side by side. 688 match our outfits tile for
tile and 1,308 match the 6500 pack; of the rest, the sprites in
[`sprite-pack-review/padventures_found.csv`](sprite-pack-review/padventures_found.csv) were
named by comparing them with the Black/White sprites and checked by eye. They cover 61 of the
109 Gen 4–6 species the pack has no walk sprite for, plus flying Latias, Latios and Rayquaza
(none for Kyogre). The extraction is CC BY-NC-SA (no commercial use), and the art belongs to
the PAdventures server, which never released it, so it is a reference rather than something to
ship as is.

## Open decisions

- Whether to apply the Gen 7 stat buffs and the other fixes from the stats audit before importing
  stats for new Pokémon from PokéAPI.
- Faces for Gen 7–9 (not on the Trozei sheet): Shuffle conversions or commissioned.
- Pixel-doubled Mystery Dungeon sprites for every new Pokémon, or redraw at our native size.
