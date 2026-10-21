#!/usr/bin/env bash
# Runs on the GitHub Actions runner and drives the live server over SSH. Used by the
# "Live server" workflow for OVH and by its rehearsal job (same script, target 127.0.0.1).
#
#   scripts/live/deploy.sh <action>
#
# Actions: verify, deploy, discord-deploy, restart, rollback, status, backup, restore,
#          set-group, set-premium, discord-setup, logs
#
# Environment:
#   PV_HOST            server address for SSH (required)
#   PV_SSH_PORT        SSH port (default 22)
#   PV_SSH_USER        SSH user (default pokeverse)
#   PV_SSH_KEY         private deploy key (GitHub secret OVH_SSH_PRIVATE_KEY)
#   PV_SSH_KEY_PASSPHRASE  its passphrase, if it has one (GitHub secret OVH_SSH_KEY_PASSPHRASE)
#   PV_SSH_HOST_KEY    server host key "ssh-ed25519 AAAA..." (GitHub secret OVH_SSH_HOST_KEY)
#   PV_SERVER_PACKAGE  pokeverse-server-linux.tar.gz (verify, deploy)
#   PV_BOT_PACKAGE     pokeverse-discord-linux-x64.tar.gz (deploy, discord-deploy; optional)
#   PV_PUBLIC_HOST     address players connect to (default PV_HOST)
#   PV_DAILY_RESTART   true/false (default true), PV_DAILY_TIME HH:MM (default 00:00),
#   PV_TIMEZONE        e.g. America/New_York (default: the server's time zone)
#   PV_SERVER_NAME     world name on the character list (default LeafGreen)
#   PV_WARNING_MINUTES warning before a restart when players are online (default 5)
#   PV_BACKUP          backup file name (restore), PV_CHARACTER / PV_GROUP (set-group),
#                      PV_CHARACTER / PV_PREMIUM_DAYS (set-premium: days or unlimited)
#   DISCORD_TOKEN, DISCORD_APPLICATION_ID, DISCORD_GUILD_ID, DISCORD_ADMIN_USER_IDS,
#   DISCORD_ADMIN_ROLE_IDS   production bot settings (the bot is skipped without a token)
#   PV_RSA_PRIVATE_KEY the private login key, PEM (GitHub secret POKEVERSE_RSA_PRIVATE_KEY; verify, deploy)
#   PV_RSA_PUBLIC      its public modulus, which the clients have (default scripts/live/rsa-public.txt)
#   PV_MAIL_USER       account email sender (GitHub variable GMAIL_ADDRESS) and PV_MAIL_PASSWORD its
#                      app password (GitHub secret GMAIL_APP_PASSWORD); without both, emails are off
#   PV_SMTP_HOST, PV_SMTP_PORT, PV_SMTP_CA_FILE  mail server (default smtp.gmail.com:587, system CAs)
set -euo pipefail

action=${1:?action}
root=$(cd "$(dirname "$0")/../.." && pwd)
: "${PV_HOST:?PV_HOST (GitHub variable OVH_HOST) is not set}"
PV_SSH_PORT=${PV_SSH_PORT:-22}
PV_SSH_USER=${PV_SSH_USER:-pokeverse}
PV_PUBLIC_HOST=${PV_PUBLIC_HOST:-$PV_HOST}
PV_DAILY_RESTART=${PV_DAILY_RESTART:-true}
PV_DAILY_TIME=${PV_DAILY_TIME:-00:00}
PV_TIMEZONE=${PV_TIMEZONE:-}
PV_SERVER_NAME=${PV_SERVER_NAME:-LeafGreen}
PV_WARNING_MINUTES=${PV_WARNING_MINUTES:-5}
PV_RSA_PUBLIC=${PV_RSA_PUBLIC:-$(cat "$root/scripts/live/rsa-public.txt")}
REMOTE=/opt/pokeverse
CTL=$REMOTE/current/tools/pokeverse-ctl

step() { echo; echo "::group::$*" 2>/dev/null || true; echo "==> $*"; }
endstep() { echo "::endgroup::"; }
fail() { echo "::error::$*"; echo "ERROR: $*" >&2; exit 1; }

[[ "$PV_WARNING_MINUTES" =~ ^[0-9]+$ ]] && [ "$PV_WARNING_MINUTES" -le 30 ] || fail "warning minutes must be 0-30"

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT

# --- SSH ---------------------------------------------------------------------------------
[ -n "${PV_SSH_KEY:-}" ] || fail "the secret OVH_SSH_PRIVATE_KEY is not set"
[ -n "${PV_SSH_HOST_KEY:-}" ] || fail "the secret OVH_SSH_HOST_KEY is not set (bootstrap-ovh.sh prints it)"
printf '%s\n' "$PV_SSH_KEY" | tr -d '\r' > "$work/key"
chmod 600 "$work/key"
if [ -n "${PV_SSH_KEY_PASSPHRASE:-}" ]; then
  # Unlocks the temporary copy only; it is deleted when this script exits.
  ssh-keygen -p -P "$PV_SSH_KEY_PASSPHRASE" -N "" -f "$work/key" >/dev/null 2>&1 \
    || fail "OVH_SSH_KEY_PASSPHRASE does not unlock OVH_SSH_PRIVATE_KEY"
fi
ssh-keygen -y -P "" -f "$work/key" >/dev/null 2>&1 || fail "OVH_SSH_PRIVATE_KEY cannot be read (passphrase? set OVH_SSH_KEY_PASSPHRASE)"
host_key=$(printf '%s' "$PV_SSH_HOST_KEY" | tr -d '\r' | awk '{for (i = 1; i < NF; i++) if ($i ~ /^(ssh-|ecdsa-)/) {print $i, $(i + 1); exit}}')
[ -n "$host_key" ] || fail "OVH_SSH_HOST_KEY must look like: ssh-ed25519 AAAA..."
{
  echo "$PV_HOST $host_key"
  echo "[$PV_HOST]:$PV_SSH_PORT $host_key"
} > "$work/known_hosts"
SSH_OPTS=(-i "$work/key" -p "$PV_SSH_PORT" -o IdentitiesOnly=yes -o BatchMode=yes
          -o StrictHostKeyChecking=yes -o UserKnownHostsFile="$work/known_hosts"
          -o ConnectTimeout=20 -o ServerAliveInterval=30 -o ServerAliveCountMax=6)
target="$PV_SSH_USER@$PV_HOST"
remote() { ssh "${SSH_OPTS[@]}" "$target" "$@"; }
# Quotes every argument for the remote shell.
remote_ctl() {
  local cmd
  cmd=$(printf '%q ' "$@")
  if [ -n "${HEALTH_TIMEOUT:-}" ]; then
    [[ "$HEALTH_TIMEOUT" =~ ^[0-9]+$ ]] || fail "HEALTH_TIMEOUT must be a number of seconds"
    cmd="HEALTH_TIMEOUT=$HEALTH_TIMEOUT $cmd"
  fi
  remote "$cmd"
}

check_ssh() {
  step "SSH connection to $target (port $PV_SSH_PORT)"
  local who err
  if ! who=$(remote 'echo "$(id -un)@$(hostname)"' 2> "$work/ssh.err"); then
    err=$(cat "$work/ssh.err")
    echo "$err"
    case "$err" in
      *"Permission denied"*)
        fail "The server is reachable and its host key matches, but it does not accept the deploy key (fingerprint $(ssh-keygen -lf "$work/key" | awk '{print $2}')). Run bootstrap-ovh.sh on the server with the .pub file of this key (docs/live-server.md, step 2)." ;;
      *"Host key verification failed"*|*"REMOTE HOST IDENTIFICATION"*)
        fail "The server's host key does not match OVH_SSH_HOST_KEY. If the server was reinstalled, run bootstrap-ovh.sh again and update the secret." ;;
      *)
        fail "SSH connection failed. Check OVH_HOST, OVH_SSH_PORT and the OVH firewall." ;;
    esac
  fi
  echo "Connected as $who; host key matches OVH_SSH_HOST_KEY"
  endstep
}

# --- packages ----------------------------------------------------------------------------
server_release=""
unpack_server() {
  [ -f "${PV_SERVER_PACKAGE:-}" ] || fail "server package not found: ${PV_SERVER_PACKAGE:-}"
  tar -C "$work" -xzf "$PV_SERVER_PACKAGE"
  server_release=$(sed -n 's/^release=//p' "$work/pokeverse-server-linux/RELEASE")
  [ -n "$server_release" ] || fail "the package has no release id"
}

upload_server() {
  unpack_server
  step "Uploading release $server_release"
  local cur
  cur=$(remote "basename \"\$(readlink $REMOTE/current 2>/dev/null)\" 2>/dev/null || true")
  if [ "$cur" = "$server_release" ]; then
    echo "Release $server_release is already active; not uploading it again"
    endstep
    return
  fi
  local copy_dest=()
  [ -n "$cur" ] && copy_dest=(--copy-dest="$REMOTE/current/")
  rsync -a --delete --stats --exclude /config.local.lua --exclude /logs "${copy_dest[@]}" \
    -e "ssh ${SSH_OPTS[*]}" "$work/pokeverse-server-linux/" "$target:$REMOTE/releases/$server_release/" | tail -n 4
  endstep
}

bot_release=""
upload_bot() {
  [ -f "${PV_BOT_PACKAGE:-}" ] || fail "bot package not found: ${PV_BOT_PACKAGE:-}"
  mkdir -p "$work/bot"
  tar -C "$work/bot" -xzf "$PV_BOT_PACKAGE"
  local dir
  dir=$(echo "$work"/bot/*/)
  bot_release=$(cat "$work/bot/RELEASE_ID" 2>/dev/null || basename "$PV_BOT_PACKAGE" .tar.gz)
  bot_release=${PV_BOT_RELEASE:-$bot_release}
  step "Uploading Discord bot $bot_release"
  rsync -a --delete --stats --exclude /.env.production --exclude /data --exclude /logs \
    -e "ssh ${SSH_OPTS[*]}" "$dir" "$target:$REMOTE/discord/releases/$bot_release/" | tail -n 4
  endstep
}

# The clients encrypt the login with the public half; a different key would lock every player out.
check_rsa_key() {
  [ -n "${PV_RSA_PRIVATE_KEY:-}" ] || fail "the secret POKEVERSE_RSA_PRIVATE_KEY is not set (docs/live-server.md, login key)"
  local modulus
  modulus=$(printf '%s\n' "$PV_RSA_PRIVATE_KEY" | tr -d '\r' | python3 "$root/scripts/live/rsa-key.py" modulus) \
    || fail "POKEVERSE_RSA_PRIVATE_KEY is not a valid login key"
  [ "$modulus" = "$PV_RSA_PUBLIC" ] \
    || fail "POKEVERSE_RSA_PRIVATE_KEY does not match the clients' key (scripts/live/rsa-public.txt)"
  echo "Login key matches the clients' key"
}

check_mail() {
  if [ -n "${PV_MAIL_USER:-}" ] && [ -z "${PV_MAIL_PASSWORD:-}" ]; then fail "GMAIL_ADDRESS is set but the secret GMAIL_APP_PASSWORD is not"; fi
  if [ -z "${PV_MAIL_USER:-}" ] && [ -n "${PV_MAIL_PASSWORD:-}" ]; then fail "the secret GMAIL_APP_PASSWORD is set but the variable GMAIL_ADDRESS is not"; fi
  return 0
}

mail_summary() {
  if [ -n "${PV_MAIL_USER:-}" ]; then
    echo "required, sent as $PV_MAIL_USER through ${PV_SMTP_HOST:-smtp.gmail.com}:${PV_SMTP_PORT:-587}"
  else
    echo "off (GMAIL_ADDRESS and GMAIL_APP_PASSWORD are not set)"
  fi
}

configure() {
  step "Live settings"
  check_rsa_key
  check_mail
  printf '%s\n' "$PV_RSA_PRIVATE_KEY" | tr -d '\r' \
    | remote "$(printf '%q ' "$REMOTE/releases/$server_release/tools/pokeverse-ctl" set-rsa-key)"
  # The app password goes through stdin, never through the command line.
  {
    printf 'SMTP_HOST=%s\n' "${PV_SMTP_HOST:-}"
    printf 'SMTP_PORT=%s\n' "${PV_SMTP_PORT:-}"
    printf 'SMTP_USER=%s\n' "${PV_MAIL_USER:-}"
    printf 'SMTP_PASSWORD=%s\n' "${PV_MAIL_PASSWORD:-}"
    printf 'SMTP_CA_FILE=%s\n' "${PV_SMTP_CA_FILE:-}"
  } | tr -d '\r' | remote "$(printf '%q ' "$REMOTE/releases/$server_release/tools/pokeverse-ctl" set-mail)"
  remote_ctl "$REMOTE/releases/$server_release/tools/pokeverse-ctl" configure \
    "host=$PV_PUBLIC_HOST" "daily_restart=$PV_DAILY_RESTART" "daily_time=$PV_DAILY_TIME" "timezone=$PV_TIMEZONE" \
    "server_name=$PV_SERVER_NAME"
  endstep
}

deploy_bot() {
  if [ -z "${DISCORD_TOKEN:-}" ]; then
    echo "DISCORD_BOT_TOKEN is not set: skipping the Discord bot"
    return 0
  fi
  [ -n "${PV_BOT_PACKAGE:-}" ] || fail "no Discord bot package"
  upload_bot
  step "Deploying the Discord bot $bot_release"
  # Settings (including the token) go through stdin, never through the command line.
  {
    printf 'DISCORD_TOKEN=%s\n' "$DISCORD_TOKEN"
    printf 'DISCORD_APPLICATION_ID=%s\n' "${DISCORD_APPLICATION_ID:-}"
    printf 'DISCORD_GUILD_ID=%s\n' "${DISCORD_GUILD_ID:-}"
    printf 'DISCORD_ADMIN_USER_IDS=%s\n' "${DISCORD_ADMIN_USER_IDS:-}"
    printf 'DISCORD_ADMIN_ROLE_IDS=%s\n' "${DISCORD_ADMIN_ROLE_IDS:-}"
  } | remote "$(printf '%q ' "$CTL" discord-deploy "$bot_release")"
  endstep
}

# Checks from outside the server, like a player's client would connect.
external_check() {
  step "Reachability from the internet ($PV_PUBLIC_HOST)"
  python3 - "$PV_PUBLIC_HOST" <<'PY' || fail "the game ports are not reachable from outside. Open TCP 7564 and 8548 in the OVH firewall."
import socket, sys
host = sys.argv[1]
for port in (7564, 8548):
    socket.create_connection((host, port), timeout=15).close()
    print("port %d reachable" % port)
PY
  PV_RSA_MODULUS=$PV_RSA_PUBLIC python3 "$root/scripts/protocol-test.py" --host "$PV_PUBLIC_HOST" --account "probe$RANDOM$RANDOM" \
    --password "not-a-real-account" --character x --expect-login-failure \
    || fail "the login server did not answer correctly from outside"
  endstep
}

case "$action" in
  verify)
    check_rsa_key
    check_ssh
    upload_server
    step "Preflight checks"
    remote_ctl "$REMOTE/releases/$server_release/tools/pokeverse-ctl" verify "$server_release" || fail "preflight checks failed"
    endstep
    step "Backup test (backup of the live database, then a test restore)"
    backup=$(remote_ctl "$REMOTE/releases/$server_release/tools/pokeverse-ctl" backup verify) || fail "backup failed"
    remote_ctl "$REMOTE/releases/$server_release/tools/pokeverse-ctl" check-backup "$backup" || fail "backup test restore failed"
    endstep
    step "Production configuration (dry run, not applied)"
    echo "Players will connect to: $PV_PUBLIC_HOST"
    echo "Daily restart:           $PV_DAILY_RESTART at $PV_DAILY_TIME ${PV_TIMEZONE:-(server time zone)}"
    echo "Discord bot:             $([ -n "${DISCORD_TOKEN:-}" ] && echo "token set, guild ${DISCORD_GUILD_ID:-<missing>}" || echo "no token (skipped)")"
    echo "Login key:               PokeVerse key only"
    echo "Account emails:          $(mail_summary)"
    check_mail
    [[ "$PV_DAILY_TIME" =~ ^([01][0-9]|2[0-3]):[0-5][0-9]$ ]] || fail "LIVE_DAILY_RESTART_TIME must be HH:MM"
    if [ -n "${DISCORD_TOKEN:-}" ] && [ -z "${DISCORD_GUILD_ID:-}" ]; then fail "DISCORD_GUILD_ID is required with a bot token"; fi
    endstep
    echo
    echo "VERIFIED: SSH, server setup, database, backup/restore and settings are ready for deployment."
    ;;
  deploy)
    check_rsa_key
    check_ssh
    upload_server
    configure
    step "Deploying release $server_release"
    remote_ctl "$REMOTE/releases/$server_release/tools/pokeverse-ctl" deploy "$server_release" "$PV_WARNING_MINUTES" \
      || fail "deployment failed (see the log above; a failed health check rolls back automatically)"
    endstep
    external_check
    deploy_bot
    step "Status"
    remote_ctl "$CTL" status
    endstep
    ;;
  discord-deploy)
    check_ssh
    deploy_bot
    ;;
  restart|rollback)
    check_ssh
    remote_ctl "$CTL" "$action" "$PV_WARNING_MINUTES"
    ;;
  status)
    check_ssh
    remote_ctl "$CTL" status
    ;;
  backup)
    check_ssh
    backup=$(remote_ctl "$CTL" backup manual)
    remote_ctl "$CTL" check-backup "$backup"
    echo "Backup: $backup"
    ;;
  restore)
    check_ssh
    [ -n "${PV_BACKUP:-}" ] || fail "choose the backup file to restore (see the status action)"
    remote_ctl "$CTL" restore "$(basename "$PV_BACKUP")" --yes
    ;;
  set-group)
    check_ssh
    remote_ctl "$CTL" set-group "${PV_CHARACTER:?character}" "${PV_GROUP:?group}"
    ;;
  set-premium)
    check_ssh
    remote_ctl "$CTL" set-premium "${PV_CHARACTER:?character}" "${PV_PREMIUM_DAYS:?days or unlimited}"
    ;;
  discord-setup)
    check_ssh
    remote_ctl "$CTL" discord setup
    ;;
  logs)
    check_ssh
    remote_ctl "$CTL" logs
    remote_ctl "$CTL" discord logs | tail -n 60 || true
    ;;
  *)
    fail "unknown action: $action"
    ;;
esac
