# Website

The public website is the PokeVerse-Clients Pages site,
`https://gitoez.github.io/PokeVerse-Clients/`, the same site that serves the client updates
from `updater/`. It is static and read-only: no logins, no server of its own.

- **Home:** download buttons (latest release in PokeVerse-Clients), and a server panel.
- **Pokédex:** every Pokémon with a monster file in `core/server/data/monster/Pokemons/`,
  with types, stats, evolutions, moves by level, egg moves, TMs, field and special
  abilities, wild levels, HP, experience and drops. Search and type and generation filters.
- **Moves:** every move with type, category, power, energy, cooldown and effect.

Everything is generated from the repository by `website/build.py`:

- Pokémon and moves from the server config (`core/server/data/lib/ps/config/pokemon/` and
  `moves/`), read by running the Lua files in `lua5.1` (`website/export-game-data.lua`).
- Wild levels and drops from the monster files, item names from `items.xml`.
- Portraits, in-game sprites, move icons and item pictures drawn from the client's
  `data.spr` through `items.otb` and `data.dat` (`website/sprites.py`).

Build it locally (needs `lua5.1` and the LFS files):

    python3 website/build.py --out /tmp/site
    python3 -m http.server -d /tmp/site 8000

## Publishing

- Every published **Client release** rebuilds the website into the PokeVerse-Clients site
  together with the updater, so game data on the site matches the latest client.
- The **Website** workflow (`.github/workflows/website.yml`) republishes only the website
  when `website/` changes on `main`, or when started by hand (for example to show new
  server data without a client release). It keeps `updater/` as it is. Pull requests
  build the site and attach it as the `website` artifact.
- The Discord button links to the same invite as the game's top menu
  (`https://discord.gg/P88WNBB56E`); the repository variable `DISCORD_INVITE_URL` overrides it
  on the website and in the Windows, Linux and Android packages (a `discord.gg/...` or
  `discord.com/invite/...` link). Clients pick up a changed invite with the next release.

The server status panel says "coming soon": a live status needs a small read-only API
on the server side, which comes later with a domain and Cloudflare in front of it.
