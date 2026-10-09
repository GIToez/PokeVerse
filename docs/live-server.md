# Live server (OVHcloud)

The live game server and the production Discord bot run on one Ubuntu 24.04 server.
GitHub Actions builds them, tests the whole deployment on a disposable Ubuntu 24.04
machine (the "rehearsal"), and then deploys to the server over SSH. Nothing secret is stored
in the repository: the database password and the Discord bridge secret are created on the
server, and the SSH key and the bot token live in GitHub Secrets.

`builds/dev/` stays the localhost development setup. Live packages are `builds/live/`.

## One-time setup

You need: your Windows PC, the server's `ubuntu` login (from OVH), and the GitHub repository settings.

### 1. Create the deploy key (Windows PowerShell)

```powershell
ssh-keygen -t ed25519 -C pokeverse-deploy -f pokeverse-deploy
```

Press Enter twice when asked for a passphrase (GitHub cannot type one). This creates `pokeverse-deploy` (private, for GitHub only) and `pokeverse-deploy.pub` (public).

### 2. Prepare the server (one command)

Log in once with `ssh ubuntu@<server address>` and run, pasting the whole contents of
`pokeverse-deploy.pub` between the quotes:

```bash
curl -fsSL https://raw.githubusercontent.com/GIToez/PokeVerse/main/scripts/live/bootstrap-ovh.sh | sudo bash -s -- "ssh-ed25519 AAAA... pokeverse-deploy"
```

It installs MariaDB (listening on 127.0.0.1 only), creates the `pokeverse` user and the
production database with a random password, installs the systemd services and the daily
backup, and prints the value for `OVH_SSH_HOST_KEY`. Running it again is safe: it keeps the
database, passwords, secrets and backups.

The deploy key only works for the `pokeverse` user, which can only manage the PokeVerse
services (no root access, no password login).

### 3. GitHub settings

Settings > Environments > New environment: `production`. Optionally add yourself as a
required reviewer so every live action waits for your approval.

Settings > Secrets and variables > Actions:

| Kind | Name | Value |
| --- | --- | --- |
| Secret | `OVH_SSH_PRIVATE_KEY` | the whole contents of the `pokeverse-deploy` file |
| Secret | `OVH_SSH_HOST_KEY` | printed at the end of step 2 (`ssh-ed25519 AAAA...`) |
| Secret | `DISCORD_BOT_TOKEN` | token of the **production** bot application |
| Variable | `OVH_HOST` | optional, server IP address (default `40.160.145.24`, the current OVH server) |
| Variable | `LIVE_TIMEZONE` | e.g. `America/Los_Angeles` (server clock for the daily restart) |
| Variable | `LIVE_DAILY_RESTART_TIME` | optional, `HH:MM`, default `06:00` |
| Variable | `LIVE_DAILY_RESTART` | optional, `false` turns the daily restart off |
| Variable | `LIVE_SERVER_HOST` | optional, a domain name players connect to (default `OVH_HOST`) |
| Variable | `OVH_SSH_PORT` | optional, if SSH is not on port 22 |
| Variable | `DISCORD_APPLICATION_ID`, `DISCORD_GUILD_ID` | production bot application and server IDs |
| Variable | `DISCORD_ADMIN_USER_IDS`, `DISCORD_ADMIN_ROLE_IDS` | comma-separated IDs allowed to use admin commands |
| Variable | `LIVE_AUTO_DEPLOY` | optional, `true` deploys every push to `main` after a successful rehearsal |

Use a separate Discord application for production. Never run the development bot with the
production token: two bots with one token disconnect each other.

### 4. Firewall

In the OVH control panel, if the network firewall is enabled, allow TCP **7564** (login)
and **8548** (game). Keep 3306 (database) and 7199 (Discord bridge) closed; they only
listen on 127.0.0.1 anyway.

### 5. First deployment

Actions > **Live server** > Run workflow:

1. `verify`: checks SSH, uploads the package, makes and test-restores a backup, and
   shows the settings that would be applied. Changes nothing in the game.
2. `deploy`: installs the server, starts it, and runs the health check.
3. `discord-setup`: registers the bot's slash commands (once, and after command changes).
4. `set-group` with your character name and group `6` (God) or `4` (Gamemaster).
   The character must be offline.

Then download the **PokeVerse-Windows-Live** artifact from the latest "Windows dev package"
run and log in.

Every live action first checks the secrets and variables and shows the result in the run
summary: which are set, whether the keys are valid (with their fingerprints), and whether
the bot token matches the application ID. Values are never printed. Pushes to `main` run the
same check offline (no connection to the server), for repository-level settings only.

## Workflow actions

| Action | What it does |
| --- | --- |
| `verify` | Dry run: SSH, upload, backup + test restore, settings. No restart. |
| `deploy` | Warn players (`warning_minutes`), save, back up, test the backup, install the new release, start, health check. Rolls back automatically if the health check fails. Also deploys the bot when `DISCORD_BOT_TOKEN` is set. |
| `discord-deploy` | Deploy only the Discord bot. |
| `restart` | Restart the game server only, with the in-game warning. |
| `rollback` | Go back to the previous release (the database is not touched). |
| `backup` | Make a backup now. |
| `restore` | Restore a backup (`backup` = file name, `confirm` = `RESTORE`). A safety backup is made first. |
| `set-group` | Set a character's staff group (`character`, `group`). |
| `discord-setup` | Register the bot's slash commands. |
| `status`, `logs` | Releases, services, backups, and the last log lines. |

The production bot is always built from the `main` branch of
[PokeVerse-Discord](https://github.com/GIToez/PokeVerse-Discord).

Every push and pull request builds both packages and runs the rehearsal, which installs
everything on a fresh Ubuntu 24.04 machine and tests login, character creation, movement,
saved positions, GM restarts with warnings, crash recovery, the daily restart, an update
with a player online, automatic rollback of a broken release, backup and restore, and the
bot deployment. A live `verify`/`deploy` only runs after its rehearsal passed.

## Restarts

- The game server runs as the systemd service `pokeverse-server`. systemd restarts it after
  a crash or a restart. The machine and the database are never restarted.
- Daily restart at `LIVE_DAILY_RESTART_TIME` (server time zone `LIVE_TIMEZONE`). Players
  are warned 30, 15, 10, 5 and 1 minutes and 30 and 10 seconds before.
- Before stopping, the server kicks and saves every player (character, Pokémon, items,
  storages) and saves the houses and global data.

GM commands (Gamemaster and above):

| Command | |
| --- | --- |
| `/restart` | Show the scheduled restart and the daily time. |
| `/restart 15` | Restart in 15 minutes (1–1440). |
| `/restart cancel` | Cancel. A cancelled daily restart comes back the next day. |
| `/restart announce [text]` | Broadcast the time left now, with an optional message. |
| `/restart daily 05:30` | Change the daily time (kept across restarts). |
| `/restart daily off` / `default` | Turn the daily restart off / back to the GitHub setting. |

## Backups

- Before every deployment, restore and on `backup`; plus every day at 05:15 server time.
- Every backup is checked by restoring it into a scratch database.
- Kept on the server in `/opt/pokeverse/backups/`: the last 14 daily and the last 20 others.
  They are on the same disk as the server, so also enable OVH's automated VPS backup
  (or take snapshots) to survive a disk loss.

## Server layout

```
/opt/pokeverse/
  current -> releases/<release id>     active game server release (replaced on deploy)
  releases/                            last releases (for rollback)
  shared/config.local.lua              live settings, database password (never overwritten)
  shared/logs/                         game server logs
  backups/                             database backups
  discord/current, discord/shared/     Discord bot release and its settings (.env.production)
```

`config.local.lua` overrides `config.lua`. Settings between `BEGIN/END DEPLOYMENT SETTINGS`
are written by the workflow; anything else you add there is kept.

## Troubleshooting

- **verify fails at SSH**: check `OVH_HOST`, `OVH_SSH_PORT`, and that both SSH secrets are
  complete (the private key including its `BEGIN`/`END` lines). If the server was
  reinstalled, run step 2 again and update `OVH_SSH_HOST_KEY`.
- **ports not reachable from the internet**: open TCP 7564 and 8548 in the OVH firewall.
- **deploy rolled back**: the job log shows the failed health check and the server log.
  Players keep playing on the previous release.
- **anything else**: run `status` or `logs`.
