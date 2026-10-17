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
