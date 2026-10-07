# Windows Hands-On Testing

A checklist for a person playing the Windows test package on a real Windows 10/11 PC with a GPU. CI already runs the scripted smoke on a headless Windows runner with software OpenGL (`PLATFORM_COMPATIBILITY.md`). This list covers what CI cannot judge: real drivers, mouse and keyboard, window behaviour, how things look, and longer play.

## Before you start

1. Download the `PokeVerse-Windows-Test` artifact from the latest green "Platforms" run, or build it (`BUILD_WINDOWS.md`).
2. Extract it to a folder such as `C:\PokeVerse-Test\`.
3. Follow `README-WINDOWS-TESTING.txt` in that folder: install MariaDB 10.11, run `Setup-PokeVerse-Database.bat` with development accounts, then `Start-PokeVerse-Test.bat`.
4. Record the Windows version (`winver`), the GPU and its driver version.

Mark every row **PASS**, **FAIL** or **NOT TESTED**, with a note. For each FAIL, attach a screenshot (Win+Shift+S) and the logs:
- `client\pokeverse.log`
- `server\logs\` (including `market.log` for market rows)
- the last lines of the "PokeVerse Server" window

The development accounts are `player`/`player` (Trainer) and `admin`/`admin` (GM Admin). They are DEVELOPMENT ONLY.

## 1. Package and startup

| # | Check | Expected | Result |
|---|---|---|---|
| 1.1 | `Setup-PokeVerse-Database.bat`, first run | Ends with "Database setup: SUCCESS" | |
| 1.2 | `Setup-PokeVerse-Database.bat`, second run | SUCCESS, data kept | |
| 1.3 | `Start-PokeVerse-Test.bat` | Server window reaches "server Online!", then the client opens | |
| 1.4 | SmartScreen / antivirus | Note any prompt (the build is unsigned) | |
| 1.5 | Folder with spaces in its path (e.g. `C:\PokeVerse Test\`) | Everything above still works | |

## 2. Client basics

| # | Check | Expected | Result |
|---|---|---|---|
| 2.1 | First start | Language picker appears; English and Portuguese both selectable | |
| 2.2 | Window | Resize, maximize, fullscreen toggle, minimize and restore; no black screen | |
| 2.3 | Login as `player` | Character list shows Trainer; enter game | |
| 2.4 | Map | Temple, NPCs (Nurse Joy, Professor Oak), no missing or garbled sprites | |
| 2.5 | Walk with arrow keys and by clicking the map | Smooth movement, no rubber-banding | |
| 2.6 | Chat | Say a line; NPC "hi" answers; channels open | |
| 2.7 | Frame rate | Note the FPS if shown, and any stutter | |
| 2.8 | Logout and log back in | Position and inventory kept | |
| 2.9 | Close the client with the window X | Closes cleanly; no crash dialog | |

## 3. Pokémon (as GM Admin)

As GM Admin, walk out of the temple (moves are refused in protection zones). Then say `/cb Charmander, 15, 10` and `/cb Bulbasaur, 15, 10`.

| # | Check | Expected | Result |
|---|---|---|---|
| 3.1 | Pokémon bar | Two portraits with names, levels and health | |
| 3.2 | Click a portrait | That Pokémon is summoned; the portrait expands | |
| 3.3 | Click the other portrait | Switches Pokémon | |
| 3.4 | Move bar | Shows the summoned Pokémon's moves with icons | |
| 3.5 | `/m rattata`, target it, use a move | Damage, cooldown overlay counting down | |
| 3.6 | Defeat it, then use its corpse with `/autoloot` on | Loot icons appear above the map for a few seconds | |
| 3.7 | HUD | Trainer health, Pokémon energy and level update | |
| 3.8 | Pokémon Info | Opens from the main panel. Spending an EV point sticks after recall and summon | |
| 3.9 | Pokédex | Opens. Search, details, moves and types tabs | |
| 3.10 | Status conditions | Icons appear during a fight with status moves (note which) | |
| 3.11 | Catching | Throw a ball at a weakened wild Pokémon | |

## 4. Windows and systems

| # | Check | How | Expected | Result |
|---|---|---|---|---|
| 4.1 | Quest log and achievements | Main panel | Achievements list loads | |
| 4.2 | Battle Pass | Main panel | Window, levels, missions; purchase refused when the season has ended | |
| 4.3 | Tasks | Main panel. Accept the Rattata task, defeat a Rattata | Kill popup "Rattata 1/40" in the middle of the screen | |
| 4.4 | Crafting (GM) | `/learnwork`, `/craftopen`, `/i 12129,5` | Create Cloth from wool; collect it after the timer | |
| 4.5 | Diamond shop | Store button | Opens; purchase with diamonds; insufficient balance refused | |
| 4.6 | TM chooser | Use a TM item | Choose and confirm a move | |

## 5. Market (two accounts)

Run two clients, or log in one after the other. GM Admin opens the market anywhere with `/marketopen`; normal players use a market tile (action item 32137). Give the GM coins with `/i 2152,100` and wool with `/i 12129,5`.

| # | Check | Expected | Result |
|---|---|---|---|
| 5.1 | Open, browse categories, search, change pages | Listings show with seller, price and time left | |
| 5.2 | Sell: drag an item onto the sell slot, set a price, confirm | Fee taken; listing appears under your offers | |
| 5.3 | Cancel your listing | Item mailed back to the depot | |
| 5.4 | Buy from the other account's listing | Money taken; item mailed to your depot; seller paid by mail | |
| 5.5 | Offer on an "offers only" listing (drag items into the offer slots) | Offer shows for the seller | |
| 5.6 | Seller accepts the offer | Both sides get the items by mail | |
| 5.7 | Seller refuses an offer | Offered items return to the bidder | |
| 5.8 | History tab | Purchases, sales and offers listed in English (Portuguese locale: Portuguese) | |
| 5.9 | Log out and in, restart the server | Listings and history kept | |

## 6. Language

| # | Check | Expected | Result |
|---|---|---|---|
| 6.1 | English locale | Ported windows in English. Known exception: market button art is Portuguese (`KNOWN_ISSUES.md` #20) | |
| 6.2 | Portuguese locale (delete `%APPDATA%\pokeverse` or pick at first start) | Window text and server messages in Portuguese | |

## 7. Stop

| # | Check | Expected | Result |
|---|---|---|---|
| 7.1 | GM `/shutdown` | Server saves and its window closes with exit code 0 | |
| 7.2 | Close the server window with X instead | Saves before exiting | |
| 7.3 | `Reset-PokeVerse-Database.bat` | Asks for the database name, rebuilds it | |

## Reporting

Copy the tables into an issue or `PHASE_3C_REPORT.md` follow-up, with the environment from "Before you start". Nothing in this checklist has been run on a real Windows desktop yet. Every row is NOT TESTED until a person runs it.
