# PokeTrader auction window: concept

This is a concept only; nothing is built yet. Today the auction lives only in Tiger Kelsey's chat
(`npc/scripts/poketrader.lua`): you say "offers", the item's name, "bids", "cancel" and "time". The
window shows the same auction, so players can see the lots and bid without typing.

The art comes from the game's own UI: the Tasks window frame, the Fishing Guide's rows, tabs and
panels, and the login screen's fields and buttons. It matches the Event Shop and Bank windows. The
item icons are the real sprites. The lots, bids and money in the pictures are made up. To redraw the
pictures, run `scripts/art/poketrader_concept.py`.

![This week](auction.jpg)

![My bids](mybids.jpg)

![Phone](phone.jpg)

## Opening it

- Talk to Tiger Kelsey and say "hi". The window opens, and the chat words still work.
- Optional: a PokeGear button that opens the window from anywhere, either only to look or also to bid.
  This needs a decision (see the open questions).

## This week

- The window shows one row per lot: the item, what kind of lot it is (rare evolution item,
  semi-rare TM or plate, the weekly Lava Cookies, the Blue Flute) and the current highest bid.
  Lots without a bid show the minimum bid instead.
- Each row can carry a tag: **Outbid**, **Your bid is the highest**, **No bids yet**, or
  **You already have one**. The last tag is for the Blue Flute, which each trainer can buy only once;
  that row is greyed out.
- Clicking a lot shows its details on the right: the minimum bid, the highest bid, your bid and
  the number of bids. Below them is the bid box, filled in with the lowest bid allowed (the highest
  bid plus 1%), and buttons to set it to that lowest bid, +5% or +10%.
- **Place bid** or **Raise bid** shows how much more money will leave your bank.
  **Take my bid back** only works while your bid is not the highest, which is the same rule as today.
- The top right shows your bank balance. The bottom shows when the new lots arrive, plus a one-line
  reminder of the rules.

## My bids

- This tab shows your bids this week. **Raise** is available when you've been outbid. **Take back**
  is locked while your bid is the highest.
- The header shows how much money is currently tied up in your bids.
- **Won** lists the items you've won and says they were sent to your depot.
- On the right is the bid history of the selected lot: amounts and times, with your own bids
  highlighted. Other bidders stay anonymous ("A trainer"), just as Tiger Kelsey never names them.

## History

- This tab lists past weeks' lots and what each one sold for. Players can use it to judge a fair
  bid.

## Phone

- Phones get one full-screen window with bigger rows and buttons, gated on `g_platform.isMobile()`.
  The bid panel stays on the right.
- The phone version has no History tab and no rules line. Both are in the Pokepedia's PokeTrader page.

## Notifications

- When someone outbids you, you get an orange console message: "You were outbid on the Dusk Stone
  ($31,815)". If the window is open, the My bids tab also gets a dot.
- When the week ends, winners get a message saying the item is in their depot, and the Won tab
  shows it.

## What the server needs

- A JSON extended opcode, like the Bank window uses, with these messages: list the lots, place a
  bid, raise a bid, take a bid back, and get history. The server keeps all the rules it has now:
  - the 1% step;
  - money taken when you bid;
  - no cancelling the highest bid;
  - the depot delivery and the bank refunds;
  - the Blue Flute once per trainer.
- **Raise** is new. Today a trainer has one bid per item and has to cancel it before bidding again.
  Raise would replace your bid in one step and take only the difference from your bank.
- The bid history and the History tab read from the tables that already exist (`poketrader_bids`
  has a time for each bid, and `poketrader_offerts` lists past lots). The database doesn't change.
- Outbid messages are new. They are sent when a bid beats yours.

## Open questions

1. Should players be able to open and bid from anywhere (PokeGear), or only at Tiger Kelsey? A
   middle option: look at the auction from anywhere, but bid only at Tiger Kelsey.
2. Should Raise be added, or do players keep cancelling and bidding again?
3. Should the bid history show amounts only (as in the picture), or also the bidders' names?
4. Should the History tab go back a few weeks, or all the way?
