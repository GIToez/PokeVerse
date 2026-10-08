#!/usr/bin/env bash
# Full server test on Linux: fresh MariaDB on 127.0.0.1:3307, database setup,
# server start, protocol tests (login, character list, game login, movement)
# and database checks. Used locally and in CI.
#
# Usage: scripts/test-server-linux.sh <path-to-pokeverse-server-binary>
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
binary="$(realpath "$1")"
work="$(mktemp -d)"
db="mariadb --no-defaults --protocol=tcp -h127.0.0.1 -P3307"
server_pid=""
db_pid=""

cleanup() {
  [ -n "$server_pid" ] && kill "$server_pid" 2>/dev/null && wait "$server_pid" 2>/dev/null || true
  [ -n "$db_pid" ] && kill "$db_pid" 2>/dev/null && wait "$db_pid" 2>/dev/null || true
  if [ "${KEEP_WORK:-0}" != 1 ]; then rm -rf "$work"; else echo "Work directory kept: $work"; fi
}
trap cleanup EXIT

step() { echo; echo "=== $*"; }

step "Starting MariaDB on 127.0.0.1:3307"
mariadb-install-db --no-defaults --datadir="$work/db" --auth-root-authentication-method=normal >"$work/db-install.log" 2>&1
mariadbd --no-defaults --datadir="$work/db" --port=3307 --bind-address=127.0.0.1 \
  --socket="$work/db.sock" --log-error="$work/db-error.log" --pid-file="$work/db.pid" &
db_pid=$!
for _ in $(seq 60); do $db -uroot -e "SELECT 1" >/dev/null 2>&1 && break; sleep 1; done
$db -uroot -e "SELECT VERSION()"

step "Setting up the database"
$db -uroot < "$root/core/database/00-create-database.sql"
$db -upokeverse -ppokeverse pokeverse < "$root/core/server/schemas/mysql.sql"
for f in "$root/core/server/schemas/pokeverse-extensions.sql" "$root/core/database/20-world-defaults.sql" \
         "$root/core/database/30-account-tools.sql" "$root/core/database/40-dev-seed.sql"; do
  $db -upokeverse -ppokeverse pokeverse < "$f"
done
echo "Re-applying the idempotent scripts (must not fail)"
for f in "$root/core/server/schemas/pokeverse-extensions.sql" "$root/core/database/20-world-defaults.sql" \
         "$root/core/database/30-account-tools.sql" "$root/core/database/40-dev-seed.sql"; do
  $db -upokeverse -ppokeverse pokeverse < "$f" >/dev/null
done
$db -upokeverse -ppokeverse pokeverse -e "CALL pokeverse_create_account('newuser', 'secret'); CALL pokeverse_create_character('newuser', 'New Trainer', 0);"
tables=$($db -upokeverse -ppokeverse -N pokeverse -e "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='pokeverse'")
echo "Tables: $tables"

step "Starting the server"
mkdir -p "$work/server/logs/server" "$work/server/logs/chat" "$work/server/logs/bots"
cp -r "$root/core/server/data" "$root/core/server/config.lua" "$root/core/server/pt_br.loc" "$work/server/"
cp "$binary" "$work/server/"
(cd "$work/server" && exec "./$(basename "$binary")" >"$work/server.log" 2>&1) &
server_pid=$!
for _ in $(seq 180); do
  grep -q "server Online!" "$work/server.log" 2>/dev/null && break
  kill -0 "$server_pid" 2>/dev/null || { tail -50 "$work/server.log"; echo "FAIL: server exited during startup"; exit 1; }
  sleep 1
done
grep -q "server Online!" "$work/server.log" || { tail -50 "$work/server.log"; echo "FAIL: server did not start"; exit 1; }
grep -E "Global address|Local ports|server Online" "$work/server.log"
grep -q "Global address: 127.0.0.1" "$work/server.log" || { echo "FAIL: server is not bound to 127.0.0.1"; exit 1; }

step "Protocol tests"
python3 "$root/scripts/protocol-test.py" --account test --password wrong --character Trainer --expect-login-failure
python3 "$root/scripts/protocol-test.py" --account test --password test --character Trainer --walk east,east,south,west
python3 "$root/scripts/protocol-test.py" --account admin --password admin --character Admin --walk west,north
python3 "$root/scripts/protocol-test.py" --account newuser --password secret --character "New Trainer" --walk east,south
sleep 3

step "Database checks"
$db -upokeverse -ppokeverse pokeverse -e "SELECT name, level, posx, posy, posz, lastlogin > 0 AS has_logged_in, online FROM players WHERE id > 1"
moved=$($db -upokeverse -ppokeverse -N pokeverse -e "SELECT COUNT(*) FROM players WHERE name IN ('Trainer','Admin','New Trainer') AND lastlogin > 0 AND NOT (posx = 4711 AND posy = 678)")
[ "$moved" = 3 ] || { echo "FAIL: expected 3 characters saved at a new position, got $moved"; exit 1; }
dex=$($db -upokeverse -ppokeverse -N pokeverse -e "SELECT COUNT(*) FROM player_items i JOIN players p ON p.id = i.player_id WHERE p.name = 'New Trainer' AND i.pid = 6 AND i.itemtype = 12281")
[ "$dex" = 1 ] || { echo "FAIL: New Trainer lost the Pokedex"; exit 1; }
island=$($db -upokeverse -ppokeverse -N pokeverse -e "SELECT CONCAT(p.town_id, ',', p.level, ',',
  (SELECT COUNT(*) FROM player_items i WHERE i.player_id = p.id AND i.itemtype IN (13499, 13492, 13497, 13820)))
  FROM players p WHERE p.name = 'New Trainer'")
[ "$island" = "10,1,4" ] || { echo "FAIL: New Trainer should stay on Beginner Island (town 10, level 1) with the island kit, got $island"; exit 1; }

step "Server log errors"
grep -E "^\[Error|ERROR|MYSQL ERROR" "$work/server.log" | sort | uniq -c | sort -rn || true
if grep -q "MYSQL ERROR" "$work/server.log"; then echo "FAIL: database errors in server log"; exit 1; fi

step "Stopping the server"
kill -INT "$server_pid"
for _ in $(seq 60); do kill -0 "$server_pid" 2>/dev/null || break; sleep 1; done
server_pid=""
echo "PASS: database setup, server start, login, character creation, game login and movement verified."
