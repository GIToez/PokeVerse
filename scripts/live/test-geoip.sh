#!/usr/bin/env bash
# Tests `pokeverse-ctl discord geoip` with a stub curl on PATH (no network): a valid file is
# installed, a bad download keeps the old database, the previous-month fallback, and
# GEOIP_DATABASE is only set when it is missing or empty.
set -euo pipefail

root="$(cd "$(dirname "$0")/../.." && pwd)"
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
failed=0
check() {
  if eval "$2"; then echo "PASS  $1"; else echo "FAIL  $1"; failed=1; fi
}

export PV_HOME=$work/opt
export FAKE_FILES=$work/files FAKE_LOG=$work/curl.log
mkdir -p "$PV_HOME/discord/shared" "$FAKE_FILES" "$work/bin"
cat > "$work/bin/curl" <<'CURL'
#!/usr/bin/env bash
out="" url=""
while [ $# -gt 0 ]; do
  case "$1" in
    -o) out=$2; shift ;;
    --max-time|--retry) shift ;;
    -*) ;;
    *) url=$1 ;;
  esac
  shift
done
echo "$url" >> "$FAKE_LOG"
file=$FAKE_FILES/${url##*/}
[ -f "$file" ] || { echo "curl: (22) The requested URL returned error: 404" >&2; exit 22; }
cp "$file" "$out"
CURL
chmod +x "$work/bin/curl"
export PATH=$work/bin:$PATH

ctl="$root/scripts/live/pokeverse-ctl"
db=$PV_HOME/discord/shared/geoip/dbip-city-lite.mmdb
env=$PV_HOME/discord/shared/.env.production
month=$(date -u +%Y-%m)
prev=$(date -u -d "$(date -u +%Y-%m-01) -1 month" +%Y-%m)

# name, size in MB, with the MaxMind metadata marker (yes/no)
make_db() {
  head -c $(($2 * 1024 * 1024)) /dev/zero > "$work/$1.mmdb"
  [ "$3" = no ] || printf '\xab\xcd\xefMaxMind.com%s' "$1" >> "$work/$1.mmdb"
}
serve() { rm -f "$FAKE_FILES"/*; [ -z "${2:-}" ] || gzip -c "$work/$2.mmdb" > "$FAKE_FILES/dbip-city-lite-$1.mmdb.gz"; }
run() { : > "$FAKE_LOG"; "$ctl" discord geoip > "$work/out.log" 2>&1; }
installed() { cmp -s "$db" "$work/$1.mmdb"; }
no_temp_files() { [ -z "$(find "$PV_HOME/discord/shared/geoip" -name '.*' -type f)" ]; }
env_value() { sed -n 's/^GEOIP_DATABASE=//p' "$env"; }

make_db current 21 yes
make_db previous 21 yes
make_db small 5 yes
make_db unmarked 21 no

printf 'DISCORD_TOKEN=x\nGEOIP_DATABASE=\n' > "$env"
serve "$month" current
check "a valid download succeeds" "run"
check "the current month is installed" "installed current"
check "the database is mode 640" '[ "$(stat -c %a "$db")" = 640 ]'
check "the geoip folder is mode 750" '[ "$(stat -c %a "$(dirname "$db")")" = 750 ]'
check "an empty GEOIP_DATABASE is set" '[ "$(env_value)" = "$db" ]'
check "the output asks for one bot restart" 'grep -q "restart the bot once" "$work/out.log"'
check "no temporary files are left" "no_temp_files"

serve "$month"
printf 'garbage' | gzip -c | head -c 10 > "$FAKE_FILES/dbip-city-lite-$month.mmdb.gz"
check "a truncated download fails" "! run"
check "a truncated download keeps the old database" "installed current"
check "a truncated download leaves no temporary files" "no_temp_files"
check "it prints a warning" 'grep -q "WARNING: GeoIP database not updated" "$work/out.log"'

serve "$month" small
check "a too small database fails" "! run"
check "a too small database keeps the old one" "installed current"

serve "$month" unmarked
check "a file without the MaxMind marker fails" "! run"
check "a file without the marker keeps the old one" "installed current"

serve "$prev" previous
check "the previous month is used when this month is missing" "run && installed previous"
check "this month was tried first" '[ "$(head -1 "$FAKE_LOG")" = "https://download.db-ip.com/free/dbip-city-lite-$month.mmdb.gz" ]'
check "then the previous month" '[ "$(sed -n 2p "$FAKE_LOG")" = "https://download.db-ip.com/free/dbip-city-lite-$prev.mmdb.gz" ]'

serve "$month"
check "no download at all fails" "! run"
check "no download keeps the old database" "installed previous"

printf 'DISCORD_TOKEN=x\nGEOIP_DATABASE=/srv/geo/custom.mmdb\n' > "$env"
serve "$month" current
check "an update with a chosen database succeeds" "run && installed current"
check "a chosen GEOIP_DATABASE is kept" '[ "$(env_value)" = /srv/geo/custom.mmdb ]'
check "no restart is asked for then" '! grep -q "restart the bot" "$work/out.log"'

printf 'DISCORD_TOKEN=x\n' > "$env"
check "a missing GEOIP_DATABASE is added" 'run && [ "$(env_value)" = "$db" ] && grep -q "^DISCORD_TOKEN=x$" "$env"'

[ "$failed" = 0 ] && echo "GeoIP tests passed" || { echo "GeoIP tests FAILED"; exit 1; }
