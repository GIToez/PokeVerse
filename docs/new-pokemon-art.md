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

**In-game walk sprites: Mystery Dungeon sprites are the best fit.** After Gen 5 the games are 3D,
so there are no official top-down sprites. `PMDCollab/SpriteCollab` has hand-made pixel walk
animations for every Pokémon through Gen 9, in 8 directions:
`sprite/<dex>/Walk-Anim.png` with frame sizes in `sprite/<dex>/AnimData.xml`. Rows 0, 2, 4 and
6 are S, E, N and W. They are about half our size; pixel-doubled they match our 64x64 sprites
in size and outline. They have more walk frames than our 3, so frames would be picked or the
outfit given more frames. Licence: credit the listed contributors (see the repo's credits files).

In use: Deoxys (look 1565) is the SpriteCollab #0386 walk animation, frames 0, 2, 4 and 6, at
2x on a 96 pixel sheet (credited to Chunsoft in SpriteCollab), until it gets its own art.

## Open decisions

- Whether to apply the Gen 7 stat buffs and the other fixes from the stats audit before importing
  stats for new Pokémon from PokéAPI.
- Faces for Gen 7–9 (not on the Trozei sheet): Shuffle conversions or commissioned.
- Pixel-doubled Mystery Dungeon sprites for every new Pokémon, or redraw at our native size.
