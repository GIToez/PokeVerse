# PokeVerse-Discord patches

Bot-side changes that go with features in this repo, kept as `git format-patch`
files for whoever works on [GIToez/PokeVerse-Discord](https://github.com/GIToez/PokeVerse-Discord).

## Wild legendary threads

- Base commit: `d5357174d0c95bac5f090ce4f8aec1ff35d219ea`
- Patches: `patches/0001-*.patch`, `patches/0002-*.patch`

Apply them in the bot repo:

```bash
git checkout -b legendary-threads d5357174d0c95bac5f090ce4f8aec1ff35d219ea   # or rebase onto main afterwards
git am /path/to/PokeVerse/integrations/pokeverse-discord/patches/*.patch
npm ci && npx tsc --noEmit && npx vitest run && npm run lint
```

What they do:

- Handle the game's `legendary` events (`spawn`, `sighting`, `flee`, `end`, `caught`).
- Each spawn posts an embed with artwork in `#legendary-spawns` and opens a thread on it. Later events go in that thread as one line each.
- `end` and `caught` edit the post with the outcome. The thread is archived, except after a defeat, when it stays open for the catch.
- Encounters are kept in the state file (`legendaryEncounters`) for one day.
- The `trainers` field also accepts `{}`, which is how the server's JSON encoder writes an empty list.
- The feature can be switched off with `spawns.legendaryEnabled`.

Discord setup: the bot needs two new permissions, **Create Public Threads** and
**Send Messages in Threads**. The invite permission integer is now `309640416272`.
Re-run channel setup after deploying so `#legendary-spawns` gets the new topic and
permission overwrites.

## Report forums

- Base commit: `9b0f15808d772384bf037a6ad55c0aa1befdaffb` (bot `main`)
- Patches: `patches/reports/0001-*.patch` to `0003-*.patch`

```bash
git checkout -b report-forums 9b0f15808d772384bf037a6ad55c0aa1befdaffb
git am /path/to/PokeVerse/integrations/pokeverse-discord/patches/reports/*.patch
npm ci && npx tsc --noEmit && npx vitest run && npm run lint
```

What they do:

- Channel setup creates two forums with status and category tags:
  - `#bug-reports`, public.
  - `#player-reports`, private in Admin Logs, with the same viewers as `#player-activity`. Nothing is posted there while it is not private.
- Each report from the game's Reports window (the `report` event, action `created`) becomes a forum post named `[#id] title`, tagged with its status and category. The first message has:
  - the reporter, with level and vocation, and a ping when their account is linked (bug reports only);
  - the coordinates and area, and the Pokemon they had out;
  - the reported player and the reported chat line (player reports);
  - the client: OS, version, renderer, window size, fps and ping.
- Its screenshot is fetched in slices with `report.screenshot` and attached as a PNG (action `screenshot`).
- Updates (action `updated`) edit the first message and add one line to the post:
  - a status change or note, with a ping for the linked reporter;
  - a staff member taking the report or letting it go;
  - a report merged into another. The duplicate's post links the original and is archived, and the original lists it.
- Closed statuses archive the post.
- A status tag picked on Discord calls `report.setStatus`, so the game answers the reporter. The game records the staff member as "name (Discord)". If the game refuses, the bot puts the old tag back.
- The posts are kept in the state file (`reportPosts`).

New settings (all default `true`): `BUG_REPORTS_ENABLED`, `PLAYER_REPORTS_ENABLED`,
`REPORT_MENTION_REPORTER`, `REPORT_TAG_SYNC`.

Discord setup:

- New permissions: **Manage Threads**, which is needed for the moderated status tags and is only required while the report forums are on, and **Send Messages in Threads**.
- Optional: **View Audit Log**, so the bot can name who changed a tag.
- **Manage Channels** is used to create the forums and their tags.
- The invite permission integer is now `326820285456`.
- Re-run channel setup after deploying.
