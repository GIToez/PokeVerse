# Legacy Asset Dependency Map

This map lists the assets the legacy client (`client/runtime-data/`) depends on, and what each one means for the Redemption client (`client-redemption/`). It answers one question per asset: is it already available to Redemption, and if not, which ported module would need it.

Scope and method:

- Source of truth is the source tree. No original Windows binary was run.
- Every legacy module under `client/runtime-data/modules/` was scanned (Python, read-only) for image paths, font names and sound paths in its `.lua`, `.otui` and `.otmod` files.
- A reference is **local** when it resolves inside the module folder. It is **shared** when it points into `data/` (for example `/images/game/...`). Shared references were then checked against `client-redemption/data/`.
- Nothing was moved, renamed or re-encoded. Sizes are on-disk sizes in the working tree.

Tibia-named text and branding are covered in `POKEVERSE_REBRAND_AUDIT.md`. This document only covers files.

## 1. Core assets (thing files)

| File | Size | Git storage | Used by | Redemption status |
|---|---|---|---|---|
| `client/runtime-data/data/things/Tibia.spr` | 263 MB | Git LFS (already LFS in the imported history; Phase 3 did not enable LFS) | sprite sheet for every item, creature and effect | **Used as-is.** CI copies it into `data/things/854/Tibia.spr` of the Redemption package and fails if it is still an LFS pointer (`.github/workflows/platforms.yml`). |
| `client/runtime-data/data/things/Tibia.dat` | 1.9 MB | normal Git | thing types (item/creature/effect metadata) | **Used as-is**, copied to `data/things/854/`. |
| `client/runtime-data/data/things/Tibia.otfi` | 112 B | normal Git | `extended: true`, `transparency: true`, `assets-name: Tibia` | Not copied. Redemption sets the same flags in code for `GamePokeVerse` at version 854 (see `REDEMPTION_PROTOCOL_COMPATIBILITY.md`). |
| `client/runtime-data/data/things/Tibia.otml` | 66 KB | normal Git | item/creature overrides loaded by `game_things/things.lua:38` | **Not used by Redemption.** UNVERIFIED whether anything visible depends on it; no missing-sprite symptom has been seen in the smoke screenshots. |

Thing IDs are not renumbered. Redemption reads the same SPR/DAT pair, so client and server item IDs stay identical.

## 2. Shared data folders

Size in the legacy tree, and whether `client-redemption/data/` has an equivalent.

| Legacy folder | Size | In Redemption | Needed by (legacy modules) |
|---|---|---|---|
| `images/pokeicons/` | 2.2 MB | **Copied** (539 files) | `game_pokebar`, `gamelib` |
| `images/types/type_ball/` | small | **Copied** | `game_pokebar` |
| `images/game/npcicons/icon_star.png` | small | **Copied** (this file only) | `game_pokebar` |
| `images/game/` (rest) | 3.3 MB | Partial: Redemption has its own `images/game/` with different content | `game_battle`, `game_chat`, `game_healthinfo`, `game_hotkeys`, `game_inventory`, `game_minimap`, `game_notifications`, `gamelib` |
| `images/pokemon_image/` | 14 MB | Missing | `client_entergame`, `game_advanceeffect`, `game_pokedex`, `game_pokemonInfo` |
| `images/tutorial/` | 6.3 MB | Missing | `game_tutorial` |
| `images/guide/` | 4.0 MB | Missing | `game_guide` |
| `images/tips/` | 2.1 MB | Missing | `game_tips` |
| `images/ICONdex/` | 1.6 MB | Missing | no module references it (orphan, only listed in `hash.xml`) |
| `images/trainerCards/` | 1.2 MB | Missing | `client_entergame`, `game_dungeon` |
| `images/ui/` | 728 KB | Missing (Redemption's UI skin lives in `images/ui` with different files) | `corelib`, `game_badgecase`, `game_console`, `game_containers`, `game_dollcase`, `game_environment`, `game_interface`, `game_market`, `game_poll`, `game_slotmachine`, `game_tips`, `gamelib` |
| `images/slotMachine/` | 624 KB | Missing | `game_slotmachine` |
| `images/poke_sprite/` | 608 KB | Missing | `game_pokekill` |
| `images/topbuttons/` | 536 KB | Missing | `game_bottommenu`, `game_calendar`, `game_pass`, `game_pokemonInfo`, `game_time`, `game_tutorial` |
| `images/messages/` | 468 KB | Missing | `game_duelmessage` |
| `images/advances/` | 76 KB | Missing | `game_advanceeffect` |
| `images/optionstab/` | 44 KB | Missing | `game_pokedex` |
| `images/moveCategories/` | 16 KB | Missing | `game_pokedex` |
| `images/icons/` | 16 KB | Missing | `game_healthinfo` |
| `images/map.png` | 0.6 MB | Missing | `game_minimap` (`g_minimap.loadImage('/images/map', ...)`) |
| `images/new_bar.png` | 1.5 MB | Missing | no module references it (orphan, only listed in `hash.xml`) |
| `sounds/environment/` | 46 MB | Missing | `game_environment` |
| `sounds/cries/` | 5.0 MB | Missing | `game_pokedex` |
| `sounds/alert.ogg`, `sounds/startup.ogg` | 16 KB | Missing | `game_console`, `client` |

`game_depotlock` references nine more folders (`/images/alert`, `/images/buttons`, `/images/config`, `/images/background_*`, ...) that are relative to its own folder in the legacy layout; they move with the module.

## 3. Fonts

| Font | In Redemption | Needed by |
|---|---|---|
| `damas` | **Copied** (`default: true` removed so it does not replace Redemption's default font) | `game_pokebar` |
| `verdana-9px-bold-colored` | **Copied** | `game_pokebar` |
| `lucida-11px-rounded` | Missing | `game_chat`, `game_craft`, `game_inventory`, `game_notifications`, `game_pokemonInfo`, `game_shop`, `game_textmessage` |
| `sans-bold-16px-rounded` | Missing | `client_entergame`, `game_calendar`, `game_dungeon` |
| `sans-bold-16px_cp1252` | Missing | `game_advanceeffect` |
| `verdana-9px-bold-white` | Missing | `game_pokemonInfo` |

## 4. Per-module map

"Shared refs" counts distinct shared paths the module references; "present" is how many of them already exist in `client-redemption/data/`. "Redemption" is the module's state in `client-redemption/modules/`:

- **Ported**: PokeVerse port exists and is smoke-tested (see `REDEMPTION_PARITY_MATRIX.md`).
- **Upstream**: Redemption ships its own module with the same role; the legacy one is the parity reference.
- **Not ported**: no equivalent yet.

| Module | Size | Local PNG | Shared refs (present) | Missing fonts / folders | Redemption |
|---|---|---|---|---|---|
| `client` | 4 KB | 0 | 2 (1) | `/sounds/startup` | Upstream |
| `client_background` | 996 KB | 25 | 1 (1) | - | Upstream |
| `client_entergame` | 221 KB | 22 | 6 (1) | `sans-bold-16px-rounded`; `/images/pokemon_image`, `/images/trainerCards` | Upstream (login works; legacy character art not ported) |
| `client_locales` | 14 KB | 0 | 1 (1) | - | Upstream |
| `client_options` | 17 KB | 0 | 7 (7) | - | Upstream |
| `client_serverlist`, `client_styles`, `client_terminal`, `client_topmenu` | <20 KB | 0 | 0 | - | Upstream |
| `corelib` | 174 KB | 0 | 6 (3) | `/images/ui` | Upstream |
| `gamelib` | 959 KB | 0 | 51 (26) | `/images/game`, `/images/types`, `/images/ui` | Upstream + PokeVerse files (`pokeverse.lua`, `pokemon.lua`, `pokemon_infos.lua`, `moves.lua`) |
| `game_pokebar` | 2.7 MB | 35 | 6 (6) | - | **Ported** |
| `game_pokemoves` | 9 KB | 0 | 0 | - | **Ported** |
| `game_interface` | 70 KB | 14 | 4 (3) | `/images/ui` | Upstream |
| `game_battle` | 19 KB | 0 | 5 (1) | `/images/game` | Upstream |
| `game_chat` | 61 KB | 0 | 16 (9) | `lucida-11px-rounded`; `/images/game` | Not ported (Redemption `game_console` covers chat) |
| `game_console` | 62 KB | 0 | 11 (9) | `/images/ui`, `/sounds/alert` | Upstream |
| `game_combatcontrols` | 6 KB | 0 | 5 (5) | - | Upstream |
| `game_containers` | 5 KB | 0 | 1 (0) | `/images/ui` | Upstream |
| `game_inventory` | 6 KB | 0 | 14 (12) | `lucida-11px-rounded`; `/images/game` | Upstream |
| `game_healthinfo` | 10 KB | 0 | 20 (1) | `/images/game`, `/images/icons` | Upstream |
| `game_hotkeys` | 27 KB | 0 | 2 (1) | `/images/game` | Upstream |
| `game_minimap` | 28 KB | 0 | 4 (2) | `/images/game`, `/images/map` | Upstream |
| `game_skills`, `game_viplist`, `game_questlog` | <20 KB | 0 | all present | - | Upstream |
| `game_npctrade`, `game_outfit`, `game_playertrade`, `game_textwindow`, `game_ruleviolation`, `game_bugreport`, `game_things` | <20 KB | 0 | 0 | - | Upstream |
| `game_textmessage` | 7 KB | 0 | 0 | `lucida-11px-rounded` | Upstream |
| `game_market` | 112 KB | 37 | 7 (3) | `/images/ui` (`/images/pokedex` appears only in a commented-out line and does not exist in the legacy tree either) | Not ported (Redemption's market is the Tibia 13 market; different protocol) |
| `game_pokedex` | 71 KB | 6 | 7 (1) | `/images/moveCategories`, `/images/optionstab`, `/images/pokemon_image`, `/sounds/cries` | Not ported |
| `game_pokemonInfo` | 148 KB | 100 | 6 (4) | `lucida-11px-rounded`, `verdana-9px-bold-white`; `/images/pokemon_image`, `/images/topbuttons` | Not ported |
| `game_pokekill` | 79 KB | 19 | 1 (0) | `/images/poke_sprite` | Not ported |
| `game_advanceeffect` | 14 KB | 0 | 13 (0) | `sans-bold-16px_cp1252`; `/images/advances`, `/images/pokemon_image` | Not ported |
| `game_tmchoose` | 4 KB | 0 | 0 | - | Not ported |
| `poke_create` | 27 KB | 12 | 0 | - | Not ported |
| `game_bottommenu` | 20 KB | 7 | 21 (9) | `/images/topbuttons` | Not ported |
| `game_time` | 55 KB | 6 | 10 (5) | `/images/topbuttons` | Not ported |
| `game_shop` | 24 MB | 2455 | 0 | `lucida-11px-rounded` | Not ported (largest module) |
| `game_calendar` | 5.5 MB | 66 | 1 (0) | `sans-bold-16px-rounded`; `/images/topbuttons` | Not ported |
| `game_environment` | 4.9 MB | 0 | 2 (0) | `/images/ui`, `/sounds/environment` (46 MB) | Not ported |
| `game_dungeon` | 4.0 MB | 66 | 1 (0) | `sans-bold-16px-rounded`; `/images/trainerCards` | Not ported |
| `game_pass` | 752 KB | 101 | 1 (0) | `/images/topbuttons` | Not ported |
| `game_task` | 682 KB | 74 | 0 | - | Not ported |
| `game_notifications` | 616 KB | 33 | 3 (0) | `lucida-11px-rounded`; `/images/game` | Not ported (Redemption has an unrelated upstream module of the same name) |
| `game_craft` | 1.0 MB | 38 | 0 | `lucida-11px-rounded` | Not ported |
| `game_depotlock` | 95 KB | 41 | 22 (0) | module-relative folders (section 2) | Not ported |
| `game_house`, `game_housebuy`, `game_houseowner`, `game_houseownerenter` | 11-25 KB | 2-8 | 0-1 | - | Not ported |
| `game_slotmachine` | 8 KB | 0 | 12 (0) | `/images/slotMachine`, `/images/ui` | Not ported |
| `game_tutorial` | 67 KB | 0 | 65 (0) | `/images/topbuttons`, `/images/tutorial` | Not ported |
| `game_guide`, `game_tips` | 2 KB | 0 | 2-3 (0) | `/images/guide`, `/images/tips`, `/images/ui` | Not ported |
| `game_badgecase`, `game_dollcase`, `game_poll`, `game_duelmessage`, `game_lootlist`, `game_effects`, `game_playerdeath`, `game_statusbar` | <10 KB | 0 | 0-3 | `/images/ui`, `/images/messages` | Not ported |
| `game_updater` | 127 KB | 17 | 0 | - | **Not ported on purpose.** It drives the legacy `hash.xml` updater; replacing the updater is future work. |

## 5. What porting a module needs

1. Copy the module's own folder (local PNGs travel with it).
2. Copy the shared folders and fonts listed for it above into `client-redemption/data/`, under the same paths, so `.otui` files need no path edits. Fonts that set `default: true` must have that line removed.
3. Make image paths absolute (`/modules/<name>/images/...`). The `game_pokebar` port did this so that images set from Lua resolve the same way as images set from `.otui`.
4. Check that no shared folder name collides with a Redemption folder of the same name (`images/game`, `images/ui`, `game_notifications`). Copy individual files, not whole folders, where they collide.

Size budget: the not-ported modules plus their shared folders add roughly 120 MB, of which `game_shop` (24 MB), `sounds/environment` (46 MB) and `images/pokemon_image` (14 MB) are most of it. All files are below GitHub's 100 MB per-file limit, so none of them needs LFS. A real asset pipeline (atlases, compression) is future work and is not done in Phase 3.

## 6. Already copied in Phase 3

| Asset | Source | Destination | For |
|---|---|---|---|
| 539 Pokémon icons | `data/images/pokeicons/` | `client-redemption/data/images/pokeicons/` | Pokémon bar portraits |
| type balls | `data/images/types/type_ball/` | `client-redemption/data/images/types/type_ball/` | Pokémon bar |
| `icon_star.png` | `data/images/game/npcicons/` | same path | shiny marker |
| `damas`, `verdana-9px-bold-colored` | `data/fonts/otfont/` | `client-redemption/data/fonts/otfont/` | Pokémon bar labels |
| `pokemon.lua`, `pokemon_infos.lua`, `moves.lua` | `modules/gamelib/` | `client-redemption/modules/gamelib/` | icon-item → Pokémon / move lookup |
| `Tibia.spr`, `Tibia.dat` | `data/things/` | `data/things/854/` at package time (CI), not committed twice | all rendering |
