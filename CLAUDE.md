# CLAUDE.md

Project rules for agents working on PokeVerse (moved from `.cursor/rules/`).


## Client modules: Redemption first

The live client is Redemption (`core/client-redemption`), assembled by
`scripts/assemble-redemption-client.sh`.

- When Redemption has a module for something, build on it and restyle or adapt it to PokeVerse
  with the `core/client-redemption/pokeverse-modern` overlay (new files) or
  `pokeverse-modern/patches/*.patch` (changes to Redemption files). Do not bring in or extend the
  legacy client's (`core/client-legacy`) module of the same name.
- Legacy modules are only for PokeVerse features Redemption has no module for (pokebar, pokedex,
  badge case, ...).
- Login and the character list are Redemption's `client_entergame` and `protocollogin`
  (`patches/client_entergame.patch`, `patches/gamelib.patch`); the overlay adds the PokeVerse
  screens and `gamelib/protocolaccount.lua`.
- Still on legacy and due to move to Redemption: `game_market` and `game_tutorial`
  (`legacy_modules` in the assemble script). New work on these should start by moving them, not
  by changing the legacy copy.

_Applies to: `core/client-redemption/**`, `core/client-legacy/modules/**`, `scripts/assemble-redemption-client.sh`_


## New quests go in the quest log

The quest log (`lib/ps/systems/075-quests.lua`, client `game_quests`) lists every NPC quest in
`lib/ps/config/003-quest.lua` on its own, but its name and description come from
`data/XML/quests.xml`. A quest without a mission there shows as "<NPC>'s request" with no text.

Whenever a quest is added (or a quest line gets a new part):

- Add a `<mission>` with the quest's `storage` as `storageid` to `quests.xml`, inside the quest
  line's `<quest>` (or a new `<quest>` with the next free id), with a `missionstate` that says
  what to do and where, and a "This mission is done." state.
- Two exceptions don't need a `quests.xml` mission, because the log shows their objective:
  - holiday and special event quests, under the log's Events category (an NPC in a holiday's NPC
    list, like `HalloweenEvent.NPCS`, or with a holiday word in its name);
  - daily quests (`daily = true`), under the Daily category.
- Run the server test: "quests: every new quest has its mission in quests.xml for the quest log"
  fails for any quest without one. There's no exemption list: every live quest has its entry.

Retired quest givers (`Quests.RETIRED_NPCS` in `075-quests.lua`, now the old Tutorial Island chain:
Flanagan, Gosse and Shelley) are left out of the log, its NPC marks and its notices. Add an NPC
there only when its quests are no longer part of the game.

_Applies to: `core/server/data/lib/ps/config/003-quest.lua`, `core/server/data/XML/quests.xml`, `core/server/data/npc/**`, `core/server/data/lib/ps/systems/075-quests.lua`_

