#!/usr/bin/env bash
# Checks the GitHub secrets and variables of the "Live server" workflow before anything
# connects to the server. Prints whether each one is set and well formed, never its value
# (only the deploy key fingerprint, which is safe to show and can be compared on the server).
#
#   scripts/live/check-settings.sh      (uses the PV_* and DISCORD_* environment of deploy.sh)
set -uo pipefail

action=${ACTION:-}
errors=0
rows=()
report() { # status name detail
  rows+=("| $1 | \`$2\` | $3 |")
  printf '%-5s %-26s %s\n' "$1" "$2" "$3"
  [ "$1" = FAIL ] && errors=$((errors + 1))
  return 0
}
is_set() { [ -n "${!1:-}" ]; }

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT

# SSH (every action needs it)
if ! is_set PV_SSH_KEY; then
  report FAIL OVH_SSH_PRIVATE_KEY "secret missing: paste the whole pokeverse-deploy file"
else
  printf '%s\n' "$PV_SSH_KEY" | tr -d '\r' > "$work/key"
  chmod 600 "$work/key"
  if ! grep -q -- '-----BEGIN .*PRIVATE KEY-----' "$work/key"; then
    report FAIL OVH_SSH_PRIVATE_KEY "not a private key: use the file WITHOUT .pub, including the BEGIN/END lines"
  elif ! ssh-keygen -y -P '' -f "$work/key" > "$work/key.pub" 2>/dev/null; then
    report FAIL OVH_SSH_PRIVATE_KEY "cannot be read: incomplete, or it has a passphrase (create it again and press Enter twice)"
  else
    report OK OVH_SSH_PRIVATE_KEY "$(ssh-keygen -lf "$work/key.pub" | awk '{print $1, $2, $NF}')"
  fi
fi

if ! is_set PV_SSH_HOST_KEY; then
  report FAIL OVH_SSH_HOST_KEY "secret missing: printed at the end of bootstrap-ovh.sh"
elif host_key=$(printf '%s' "$PV_SSH_HOST_KEY" | tr -d '\r' | awk '{for (i = 1; i < NF; i++) if ($i ~ /^(ssh-|ecdsa-)/) {print $i, $(i + 1); exit}}') \
     && [ -n "$host_key" ] && echo "$host_key" | ssh-keygen -lf - >/dev/null 2>&1; then
  if [ -s "$work/key.pub" ] && [ "$(cut -d' ' -f1,2 "$work/key.pub")" = "$host_key" ]; then
    report FAIL OVH_SSH_HOST_KEY "this is your deploy key; use the server key printed by bootstrap-ovh.sh"
  else
    report OK OVH_SSH_HOST_KEY "${host_key%% *} $(echo "$host_key" | ssh-keygen -lf - | awk '{print $2}')"
  fi
else
  report FAIL OVH_SSH_HOST_KEY "must look like: ssh-ed25519 AAAA..."
fi

host_re='^[A-Za-z0-9]([A-Za-z0-9.-]*[A-Za-z0-9])?$'
if [[ "${PV_HOST:-}" =~ $host_re ]]; then
  report OK OVH_HOST "$PV_HOST"
else
  report FAIL OVH_HOST "not a valid address: '${PV_HOST:-}'"
fi
if [[ "${PV_SSH_PORT:-22}" =~ ^[0-9]+$ ]]; then
  report OK OVH_SSH_PORT "${PV_SSH_PORT:-22}"
else
  report FAIL OVH_SSH_PORT "must be a number"
fi
if [[ "${PV_PUBLIC_HOST:-}" =~ $host_re ]] && [[ ! "$PV_PUBLIC_HOST" =~ ^(127\.|localhost$) ]]; then
  report OK LIVE_SERVER_HOST "players connect to $PV_PUBLIC_HOST"
else
  report FAIL LIVE_SERVER_HOST "not a public address: '${PV_PUBLIC_HOST:-}'"
fi

# Daily restart
case "${PV_DAILY_RESTART:-true}" in
  true|false) report OK LIVE_DAILY_RESTART "${PV_DAILY_RESTART:-true}" ;;
  *) report FAIL LIVE_DAILY_RESTART "must be true or false" ;;
esac
if [[ "${PV_DAILY_TIME:-06:00}" =~ ^([01][0-9]|2[0-3]):[0-5][0-9]$ ]]; then
  report OK LIVE_DAILY_RESTART_TIME "${PV_DAILY_TIME:-06:00}"
else
  report FAIL LIVE_DAILY_RESTART_TIME "must be HH:MM (24 hours), e.g. 06:00"
fi
if [ -z "${PV_TIMEZONE:-}" ]; then
  report INFO LIVE_TIMEZONE "not set: the server's own time zone is used (OVH default: UTC)"
elif [ -f "/usr/share/zoneinfo/$PV_TIMEZONE" ] && [[ "$PV_TIMEZONE" != *..* ]]; then
  report OK LIVE_TIMEZONE "$PV_TIMEZONE (now $(TZ=$PV_TIMEZONE date +%H:%M) there)"
else
  report FAIL LIVE_TIMEZONE "unknown time zone '$PV_TIMEZONE' (example: America/Los_Angeles)"
fi

# Discord bot
snowflake='^[0-9]{17,20}$'
bot_needed=false
case "$action" in discord-deploy|discord-setup) bot_needed=true ;; esac
if ! is_set DISCORD_TOKEN; then
  if $bot_needed; then
    report FAIL DISCORD_BOT_TOKEN "secret missing (needed for $action)"
  else
    report INFO DISCORD_BOT_TOKEN "not set: deployments skip the Discord bot"
  fi
else
  if [[ "$DISCORD_TOKEN" =~ ^[A-Za-z0-9_-]{20,}\.[A-Za-z0-9_-]{4,}\.[A-Za-z0-9_-]{20,}$ ]]; then
    report OK DISCORD_BOT_TOKEN "set (${#DISCORD_TOKEN} characters)"
  else
    report FAIL DISCORD_BOT_TOKEN "does not look like a bot token (Developer Portal > Bot > Reset Token)"
  fi
  if [[ "${DISCORD_APPLICATION_ID:-}" =~ $snowflake ]]; then
    report OK DISCORD_APPLICATION_ID "$DISCORD_APPLICATION_ID"
  else
    report FAIL DISCORD_APPLICATION_ID "missing or not a Discord ID (Developer Portal > General Information)"
  fi
  if [[ "${DISCORD_GUILD_ID:-}" =~ $snowflake ]]; then
    report OK DISCORD_GUILD_ID "$DISCORD_GUILD_ID"
  else
    report FAIL DISCORD_GUILD_ID "missing or not a Discord ID (right-click the server > Copy Server ID)"
  fi
  if [[ "${DISCORD_TOKEN%%.*}" =~ ^[A-Za-z0-9_-]+$ ]] && [[ "${DISCORD_APPLICATION_ID:-}" =~ $snowflake ]]; then
    token_app=$(printf '%s' "${DISCORD_TOKEN%%.*}" | tr '_-' '/+' | { b=$(cat); while [ $(( ${#b} % 4 )) -ne 0 ]; do b+="="; done; echo "$b"; } | base64 -d 2>/dev/null || true)
    if [[ "$token_app" =~ $snowflake ]] && [ "$token_app" != "$DISCORD_APPLICATION_ID" ]; then
      report WARN DISCORD_BOT_TOKEN "belongs to bot $token_app, not DISCORD_APPLICATION_ID (wrong bot?)"
    fi
  fi
  for name in DISCORD_ADMIN_USER_IDS DISCORD_ADMIN_ROLE_IDS; do
    value=${!name:-}
    if [ -z "$value" ]; then
      report INFO "$name" "not set"
    elif [[ "${value// /}" =~ ^[0-9]{17,20}(,[0-9]{17,20})*$ ]]; then
      report OK "$name" "$(tr ',' '\n' <<< "${value// /}" | wc -l) ID(s)"
    else
      report FAIL "$name" "must be Discord IDs separated by commas"
    fi
  done
  if [ -z "${DISCORD_ADMIN_USER_IDS:-}${DISCORD_ADMIN_ROLE_IDS:-}" ]; then
    report WARN DISCORD_ADMIN_USER_IDS "no bot admins: nobody can use the bot's admin commands"
  fi
fi

if [ -n "${GITHUB_STEP_SUMMARY:-}" ]; then
  {
    echo "### GitHub settings"
    echo "| | Name | Detail |"
    echo "| --- | --- | --- |"
    printf '%s\n' "${rows[@]}"
  } >> "$GITHUB_STEP_SUMMARY"
fi

if [ "$errors" -gt 0 ]; then
  echo "::error::$errors setting(s) need fixing (Settings > Secrets and variables > Actions)"
  exit 1
fi
echo "All required settings are present."
