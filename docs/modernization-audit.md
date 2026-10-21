# Modernization audit

The PokeVerse systems that still work the old way: typing keywords to an NPC, or using a stock
OTClient window. They are ranked by how often players touch them and how much a window would help.
Each entry gives where the system stands today, what it should become and the files to touch.
Each one is meant to be its own PR.

The modern pieces to copy from:
- **Sell Shop:** `game_pokemonshop` on the client, `081-pokemonShop.lua` on the server.
- **Day Care:** `game_daycare` / `072-daycare.lua`.
- **PC and GTS:** `game_pc` / `067-pc.lua`, `game_gts` / `066-gts.lua`.
- **Trainer Card:** `game_trainercard` / `071-trainerCard.lua`.

They all use the same pattern: a sandboxed module in `core/client-redemption/pokeverse-modern/modules/`,
JSON on its own extended opcode (`EXTENDED_IDS` in `data/lib/ps/others/constants.lua`, `ExtendedIds` in
`gamelib/compat.lua`), a `hello` at login so the server knows the client can show the window, and the
old keyword dialogue left as the fallback for older clients.

| Rank | System | Players touch it | Size |
| --- | --- | --- | --- |
| 1 | Poke Mart buy window (built) | Every session | Medium |
| 2 | Nurse Joy menu (not needed) | Every session | Small |
| 3 | Travel picker (boats, flying NPCs) | Daily | Small |
| 4 | Bank window (built) | Daily | Small |
| 5 | Egg move and TM move manager | Weekly | Medium |
| 6 | Safari Zone check-in | Weekly | Small |
| 7 | Ranger Club and Tournament boards | Weekly | Medium |
| 8 | Berries | Weekly | Medium |
| 9 | Ball paint | Now and then | Small |
| 10 | Name Rater and the Store (Store built) | Now and then | Large (Store) |
| 11 | Houses tab (built) | Now and then | Medium |
| 12 | Stock OTClient modules cleanup (done) | Never (cost only) | Small |
| 13 | Social windows (friends, guild, mail, rematch stars, watch) | Daily | Medium each |

## 1. Poke Mart buy window

**Built (PR #161):** `game_mart` takes over {trade} on the Redemption client, with the cart and a
Sell tab with Sell all and Keep ([upcoming-features.md](upcoming-features.md#order) has the details).
Older clients keep the renamed trade window. What follows is the audit from before.

**Before.** 158 NPCs sell through `module_shop` and the `shop_buyable` / `shop_sellable` lists in their
XML (the Marts use `npc/scripts/quest_pokemart.lua`). Saying {trade} opens stock OTClient's
`game_npctrade`. The `pokeverse-modern/patches/game_npctrade.patch` patch only renames the currency to
Dollars. The window still has Tibia's layout: a plain list, a quantity slider, and Buy and Sell tabs.

**Target.** A Mart window in the Sell Shop's style: item tiles grouped by category (Balls, Potions,
Revives, Tools), a quantity stepper with x1/x10/x100, the price total and your money, and a cart for
buying several items at once. Selling stays in the Sell Shop.

**Files.**
- Client: new `game_mart` (or restyle `game_npctrade` in its patch).
- Server: the `module_shop` path in `npc/lib/npcsystem/modules.lua`, sending the list as JSON when the
  client said hello.

## 2. Nurse Joy menu

**Not needed (decided October 21).** Joy only heals and sets the hometown, and the dialogue
window's blue-word buttons already do both in one click.

**Now.** `npc/scripts/nurse_joy.lua` answers to {heal} and {hometown}. Players type or click the blue
word, and the PC and GTS are separate machines in the Center.

**Target.** Greeting Joy opens a small menu: Heal, Change hometown, and shortcuts to the PC and GTS
when the player is inside the Center. `game_npcdialog` already shows Joy's portrait.

**Files.** `npc/scripts/nurse_joy.lua`, `game_npcdialog` (a button row under the portrait), `game_pc`
and `game_gts` (open from the menu).

## 3. Travel picker

**Now.** 12 NPCs use `npc/scripts/travels.lua`: captains and the flying NPCs (NPC Charizard, NPC Pidgeot
and others). Players have to know the town names and type them; the greeting only lists some.

**Target.** A destination window: each town with its price and travel time, greyed out when a quest or
badge is missing, with the town's Pokepedia map thumbnail.

**Files.** `npc/scripts/travels.lua` (send the table as JSON), a new `game_travel` module.

## 4. Bank window

**Built (October 21):** `game_bank` and `lib/ps/systems/086-bank.lua`; greeting a bank NPC
opens it (`EXTENDED_IDS.BANK`, 44). Deposit, Withdraw, Transfer (no cap, may go to the trainer's own
characters) and History. The keywords stay for older clients. What follows is the audit from before.

**Before.** 19 bank NPCs use `npc/scripts/bank.lua` (with `shop_bank.lua` for one of them):
{balance}, {deposit}, {deposit all}, {withdraw}, {withdraw all} and {transfer}, each a multi-step
dialogue with typed amounts.

**Target.** One window: the balance and the money carried, deposit and withdraw boxes with All buttons,
and transfer with a name box that checks the name before sending.

**Files.** `npc/scripts/bank.lua`, `game_bank`, `lib/ps/systems/086-bank.lua`.

## 5. Egg move and TM move manager

**Now.** Three NPC dialogues: `eggmove_regenerator.lua`, `eggmove_remover.lua` and `tm_remover.lua`.
Teaching a TM uses the legacy `game_tmchoose` window. Players can't see which moves a Pokemon has in each
slot before choosing.

**Target.** A move manager window: the Pokemon's moves with their Move Info card (`076-moveInfo.lua`
already sends move data), and Teach, Remove and Restore buttons with the price on each.

**Files.** The three NPC scripts, `018-technicalMachine.lua`, `045-pokemonEgg.lua`, `game_tmchoose`
(replace), and `game_pokemoves` for the move cards.

## 6. Safari Zone check-in

**Now.** `016-safariZone.lua` and the Safari NPCs (entry, and Hugh with `saffariZoneLeave.lua`).
Check-in, the time left and the ball count are dialogue lines and text messages, and Hugh sells the
bait, cookies, stones and traps through the stock trade window.

**Target.** A check-in window (price, time, balls) and a small Safari HUD showing the time left, balls
and the bait/cookie/stone/trap items as quick buttons.

**Files.** `016-safariZone.lua`, `npc/scripts/saffariZoneLeave.lua`, a new `game_safari` module.

## 7. Ranger Club and Tournament boards

**Now.**
- `029-rangerClub.lua` and `npc/scripts/rangerClub.lua`: Ranger missions are given and checked by
  dialogue.
- `npc/scripts/tournament.lua` (526 lines) and `013-tournamentHighscore.lua`: sign-up, rules and the
  ladder are all dialogue.

**Target.** Boards in the style of the Tasks window: the open missions or brackets, their rewards and
progress, and Sign up / Claim buttons. The tournament ladder shows as a ranked list on the board.

**Files.** The scripts above, plus a new tab in `game_dailytasks` or a `game_boards` module.

## 8. Berries

**Now.** `015-berry.lua` (731 lines): planting, watering and harvesting are item uses on the ground,
with growth shown only as the plant's sprite and a look text.

**Target.** A garden panel on look or use: the berry, its growth stage and time to the next stage, and
water and fertilizer state. A Pokepedia page lists every berry, where its seed drops and what it does.

**Files.** `015-berry.lua`, a new `game_berries` module (or a card in `game_pokehud`), `wiki_data.lua`.

## 9. Ball paint

**Now.** `npc/scripts/shop_ballPaint.lua` (339 lines): ball paints are bought with tokens and the
required items by dialogue, without a preview.

**Target.** A paint shop window with a preview of each painted ball, its token price and the items still
missing, in the Sell Shop's style.

**Files.** `npc/scripts/shop_ballPaint.lua`, `019-ballSeal.lua` (the ball look), a new window in
`game_pokemonshop` or its own module.

## 10. Name Rater and the Store

**Built: the Store** (`game_soulstore`, `lib/ps/systems/084-store.lua`, PR #163), from the top bar's
Store button: everything the Soul Coin NPCs sold, nickname and remove nickname included, with Withdraw
and Deposit. The Soul Coin NPCs are off the map. Still to do: a Name Rater window that picks the
Pokemon and checks the name as it is typed, and buying soul coins (phase 4 in
[upcoming-features.md](upcoming-features.md#19-accounts-soul-coins-and-the-store)).

**Before.**
- **Name Rater:** the soul coin NPCs (`npc/scripts/soulTrade.lua`) give a nickname for 1 soul coin.
  You say {nick change}, type the name and confirm, and it renames the ball in your ball slot. There is
  no window: the name is checked only after it is typed, and players can't see which Pokemon gets it.
- **Store:** the same NPCs sell Premium, addons, a guild, a sex change, bless, a nickname, stamina and
  egg move capsules for soul coins, all by keyword. Buying soul coins isn't built (see
  `docs/upcoming-features.md`), and stock `game_store` is not loaded.

**Target.**
- **Name Rater:** a window at the soul coin NPCs: pick the Pokemon from the bag or party, type the name
  (checked as you type) and see the price.
- **Store:** one Store window (the top bar's Store button) for everything the soul coin NPCs sell, with
  delivery through the PC inbox, and buying soul coins once payments exist.

**Files.** `npc/scripts/soulTrade.lua`, a new system in `data/lib/ps/systems/` and a client module.
Buying soul coins needs payments and the website first (`docs/website.md`).

## 11. Houses tab

**Built:** the Pokepedia's Houses tab (`game_pokepedia/houses.lua`, `069-pokepedia.lua`): buy, leave,
guests and sub-owners, and transfers, with pictures of each house and floor. The talkactions stay as a
fallback. What follows is the audit from before.

**Before.** 683 houses in `world/map-house.xml`, managed with `/house buy`, `/house sell`, `/house kick`,
`/house guest` and the other talkactions in `talkactions/talkactions.xml`. Players have to know the
commands and stand in front of the door.

**Target.** A Houses tab (in the Trainer Card or its own window): your house with its rent and guests,
and Add guest, Kick and Leave buttons. Houses for sale show on the Pokepedia map.

**Files.** The house talkactions, a new `game_houses` module, and `game_pokepedia` for map marks.

## 12. Stock OTClient modules cleanup

**Done:** `scripts/assemble-redemption-client.sh` (`redemption_skip`) deletes the modules below and the
never-loaded Tibia ones from the assembled client. Their source folders still say `autoload: true`.

**Before.** The Redemption base still ships Tibia modules PokeVerse never uses. Most aren't loaded, because
`pokeverse-modern/modules/game_interface/interface.otmod` has its own list, but these load by themselves
with `autoload: true`:
- `dev_otui`
- `game_analyser`
- `game_cyclopedia`
- `game_lootsplitter`
- `game_proficiency`
- `game_taskboard`

`game_healthcircle` also autoloads but is used and patched.

**Target.** Drop the unused autoloads in `scripts/assemble-redemption-client.sh` (delete them from the
assembled tree, as it already does for `updater`), and leave out the never-loaded Tibia modules (prey,
imbuing, forge, wheel, stash, store, quickloot, reward wall and others). This makes the client smaller
and gives fewer errors from Tibia opcodes the server never sends.

**Files.** `scripts/assemble-redemption-client.sh`, then the Windows, Linux and Android packaging
scripts to check nothing else expects those folders.

## 13. Social windows for what already exists

These work today through chat commands or Tibia windows. Each one could get a window:
- **Friends:** a Friends window to replace the VIP list, with online status, a party invite and party
  chat. Parties and shared EXP already work (TFS parties, `experienceShareRadius` in `config.lua`).
- **Guilds:** a Guild window to replace the Guild channel's `!invite`, `!kick` and the other commands,
  with the guild tag on the Trainer Card.
- **Mail:** send items and money through the PC inbox, in place of parcels and letters from the Mart.
- **Gym rematches:** they already exist (pay the leader again). Rematch wins could show as stars on
  the badges in the Trainer Card.
- **Watching duels:** TV broadcasting (`/tvname`, `/tvlist` and the other commands) lets players watch a
  trainer. A "Watch" button on duels and tournament matches could use it.

## Open follow-up: walls 874, 4471 and 4474 in two Marts

The Pokemon Center and Mart walls got hooks so wall decorations (wreaths, banners, tapestries) hang on
them. Three old walls from the original map, 874, 4471 and 4474, still have no hook. They cover only a
couple of spots in two Marts.

The fix is to run `scripts/item-hooks.py` on `core/server/data/items/items.otb` and
`core/client-legacy/data/things/data.dat`:
- `--south` for the walls that run east-west.
- `--east` for the ones that run north-south.

Then check with `--check`. Players need the client update to see props on them. The clerk's booth
pieces (24253, 24254 and 24288) are left without hooks on purpose: they're part of the counter.
