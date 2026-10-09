#!/usr/bin/env bash
# Deployment rehearsal on a disposable Ubuntu 24.04 machine (the GitHub Actions runner).
# Runs the real bootstrap-ovh.sh and deploy.sh against this machine over SSH, then checks
# everything the live server relies on: first installation, login/movement/persistence,
# GM restart with warnings, crash recovery, the daily restart, an update with player
# warnings, automatic rollback of a broken release, backup and restore, and the Discord bot
# deployment path. Never run it on the real server.
#
#   scripts/live/rehearsal.sh <server package tar.gz> [<bot package tar.gz> <bot release id>]
set -euo pipefail

server_pkg=$(realpath "$1")
bot_pkg=${2:+$(realpath "$2")}
bot_release=${3:-}
root=$(cd "$(dirname "$0")/../.." && pwd)
work=$(mktemp -d)
ctl() { sudo -u pokeverse /opt/pokeverse/current/tools/pokeverse-ctl "$@"; }
journal() { sudo journalctl -u pokeverse-server.service --no-pager "$@"; }
step() { echo; echo "::group::REHEARSAL: $*"; }
endstep() { echo "::endgroup::"; }
fail() { echo "::error::REHEARSAL FAILED: $*"; journal -n 80 || true; exit 1; }
pt() { python3 -u "$root/scripts/protocol-test.py" "$@"; }
restarts() { systemctl show -p NRestarts --value pokeverse-server.service; }
wait_restarted() {
  local before=$1
  for _ in $(seq 420); do
    [ "$(restarts)" -gt "$before" ] && systemctl is-active --quiet pokeverse-server.service && return 0
    sleep 1
  done
  fail "systemd did not start the game server again"
}

[ "${CI:-}" = true ] || { echo "This script reconfigures the machine; it only runs in CI." >&2; exit 1; }
[ "$(hostname)" != "vps-2582abd3" ] || { echo "Refusing to run on the live server." >&2; exit 1; }

step "SSH server and deploy key"
sudo apt-get install -y -q --no-install-recommends openssh-server >/dev/null
sudo systemctl start ssh
ssh-keygen -q -t ed25519 -N "" -C rehearsal -f "$work/key"
endstep

step "bootstrap-ovh.sh (twice: it must be safe to run again)"
sudo bash "$root/scripts/live/bootstrap-ovh.sh" "$(cat "$work/key.pub")"
sudo bash "$root/scripts/live/bootstrap-ovh.sh" "$(cat "$work/key.pub")" > "$work/bootstrap2.log"
grep -q "Keeping the existing database password" "$work/bootstrap2.log" || fail "second bootstrap run replaced the secrets"
[ "$(sudo grep -c 'restrict ssh-ed25519' /opt/pokeverse/.ssh/authorized_keys)" = 1 ] || fail "deploy key added twice"
endstep

export PV_HOST=127.0.0.1
PV_SSH_KEY=$(cat "$work/key")
PV_SSH_HOST_KEY=$(cut -d' ' -f1,2 /etc/ssh/ssh_host_ed25519_key.pub)
export PV_SSH_KEY PV_SSH_HOST_KEY
export PV_SERVER_PACKAGE=$server_pkg
export PV_TIMEZONE=America/Los_Angeles
export PV_WARNING_MINUTES=0
deploy() { "$root/scripts/live/deploy.sh" "$@"; }

step "Wrong host key is refused"
if PV_SSH_HOST_KEY="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBadBadBadBadBadBadBadBadBadBadBadBadBadBadBad" deploy status; then
  fail "SSH accepted a wrong host key"
fi
endstep

step "verify on a fresh server"
deploy verify
endstep

step "first deployment"
deploy deploy
first=$(basename "$(readlink /opt/pokeverse/current)")
sudo -u pokeverse test -f /opt/pokeverse/backups/"$(sudo ls -1t /opt/pokeverse/backups | head -1)" || fail "no pre-deployment backup"
grep -q '^ip = "127.0.0.1"' <(sudo cat /opt/pokeverse/shared/config.local.lua) || fail "deployment settings not written"
journal | grep -q "Discord bridge listening on 127.0.0.1:7199" || fail "the Discord bridge is not listening"
endstep

step "players: login, movement, persistence"
sudo mariadb pokeverse -e "CALL pokeverse_create_account('rehearsal', 'rehearsal1'); CALL pokeverse_create_character('rehearsal', 'Rehearsal Trainer', 1);
  CALL pokeverse_create_account('rehearsalgm', 'rehearsal1'); CALL pokeverse_create_character('rehearsalgm', 'Rehearsal Admin', 0);" >/dev/null
PV_CHARACTER="Rehearsal Admin" PV_GROUP=6 deploy set-group
player=(--account rehearsal --password rehearsal1 --character "Rehearsal Trainer")
gm=(--account rehearsalgm --password rehearsal1 --character "Rehearsal Admin")
pos=$(pt "${player[@]}" --walk east | tee /dev/stderr | sed -n 's/^POSITION //p')
[ -n "$pos" ] || fail "no position"
endstep

step "GM /restart 1 with warnings, saved and started again by systemd"
before=$(restarts)
pt "${player[@]}" --walk south --stay-online 200 > "$work/hold.log" 2>&1 &
holder=$!
sleep 6
pt "${gm[@]}" --walk west --say "/restart" --say "/restart 1"
wait "$holder" || { cat "$work/hold.log"; fail "the player was not disconnected by the restart"; }
cat "$work/hold.log"
for w in "Server restart in 1 minute" "Server restart in 30 seconds" "Server restart in 10 seconds"; do
  grep -q "$w" "$work/hold.log" || fail "missing warning: $w"
done
pos=$(sed -n 's/^POSITION //p' "$work/hold.log")
wait_restarted "$before"
ctl health
pt "${player[@]}" --walk north --expect-position "$pos" | tee "$work/after.log"
pos=$(sed -n 's/^POSITION //p' "$work/after.log")
endstep

step "crash recovery"
before=$(restarts)
sudo kill -SEGV "$(systemctl show -p MainPID --value pokeverse-server.service)"
wait_restarted "$before"
ctl health
endstep

step "daily restart (time zone $PV_TIMEZONE)"
daily=$(TZ=$PV_TIMEZONE date -d "+4 min" +%H:%M)
ctl configure host=127.0.0.1 daily_restart=true "daily_time=$daily" "timezone=$PV_TIMEZONE"
deploy restart
before=$(restarts)
wait_restarted "$before"
journal -n 400 | grep -q "Restart: daily restart scheduled" || fail "the daily restart was not scheduled"
ctl health
endstep

step "update with players online: warning, save, new release"
mkdir -p "$work/update"
tar -C "$work/update" -xzf "$server_pkg"
second="${first}-update"
sed -i "s/^release=.*/release=$second/" "$work/update/pokeverse-server-linux/RELEASE"
tar -C "$work/update" -czf "$work/update.tar.gz" pokeverse-server-linux
pt "${player[@]}" --walk east --stay-online 300 > "$work/hold2.log" 2>&1 &
holder=$!
sleep 6
PV_SERVER_PACKAGE=$work/update.tar.gz PV_WARNING_MINUTES=1 deploy deploy
wait "$holder" || { cat "$work/hold2.log"; fail "the player was not disconnected by the update"; }
cat "$work/hold2.log"
grep -q "Server update in 1 minute" "$work/hold2.log" || fail "players were not warned about the update"
pos=$(sed -n 's/^POSITION //p' "$work/hold2.log")
[ "$(basename "$(readlink /opt/pokeverse/current)")" = "$second" ] || fail "the update is not active"
pt "${player[@]}" --walk west --expect-position "$pos"
endstep

step "broken release is rolled back automatically"
mkdir -p "$work/broken"
tar -C "$work/broken" -xzf "$server_pkg"
sed -i "s/^release=.*/release=${first}-broken/" "$work/broken/pokeverse-server-linux/RELEASE"
# Starts, but never opens the game ports: only the health check can catch it.
printf '#!/bin/sh\necho "broken build"\nexec sleep 3600\n' > "$work/broken/pokeverse-server-linux/pokeverse-server"
tar -C "$work/broken" -czf "$work/broken.tar.gz" pokeverse-server-linux
if PV_SERVER_PACKAGE=$work/broken.tar.gz HEALTH_TIMEOUT=60 deploy deploy; then
  fail "the broken release was reported as deployed"
fi
[ "$(basename "$(readlink /opt/pokeverse/current)")" = "$second" ] || fail "not rolled back to $second"
ctl health
endstep

step "manual rollback"
deploy rollback
[ "$(basename "$(readlink /opt/pokeverse/current)")" = "$first" ] || fail "manual rollback did not activate $first"
endstep

step "backup and restore"
deploy backup
pt "${player[@]}" --walk south > "$work/moved.log"
latest=$(sudo ls -1t /opt/pokeverse/backups | grep -- '-manual\.sql\.gz$' | head -1)
PV_BACKUP=$latest deploy restore
players=$(sudo mariadb -N pokeverse -e "SELECT COUNT(*) FROM players WHERE name IN ('Rehearsal Trainer', 'Rehearsal Admin', 'Health Monitor')")
[ "$players" = 3 ] || fail "characters missing after the restore"
endstep

if [ -n "$bot_pkg" ]; then
  step "Discord bot deployment (fake token: must not affect the game server)"
  set +e
  PV_BOT_PACKAGE=$bot_pkg PV_BOT_RELEASE=$bot_release DISCORD_TOKEN="MTAwMDAwMDAwMDAwMDAwMDAwMQ.GabcDE.fake-token-for-ci-tests-only-xxxxxxxxx" \
    DISCORD_APPLICATION_ID=100000000000000002 DISCORD_GUILD_ID=100000000000000001 deploy discord-deploy
  echo "bot deployment exit code: $? (a fake token cannot log in to Discord)"
  set -e
  sudo -u pokeverse test -f /opt/pokeverse/discord/shared/.env.production || fail "bot settings not written"
  [ "$(sudo stat -c %a /opt/pokeverse/discord/shared/.env.production)" = 600 ] || fail "bot settings are not private"
  sudo grep -q "^BRIDGE_SECRET=$(sudo sed -n 's/^discordBridgeSecret = "\(.*\)"/\1/p' /opt/pokeverse/shared/config.local.lua)$" \
    /opt/pokeverse/discord/shared/.env.production || fail "bridge secret not shared with the bot"
  ctl health
  endstep
fi

step "final status"
deploy status
if journal | grep -q "MYSQL ERROR"; then journal | grep "MYSQL ERROR" | sort | uniq -c; fail "database errors in the server log"; fi
endstep
echo "REHEARSAL PASSED"
