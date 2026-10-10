#!/usr/bin/env bash
# Starts or stops a throwaway PokeVerse server for the client tests (Linux).
#
#   scripts/client-test/server.sh start <pokeverse-server binary> <work dir>
#   scripts/client-test/server.sh stop <work dir>
#   scripts/client-test/server.sh reset <work dir>    # put the test characters back at the start
#
# MariaDB listens on 127.0.0.1:3307 and the server on the ports from core/server/config.lua
# (login 7564, game 8548). Test accounts: test/test (Trainer), admin/admin (Admin, GM) and
# selftest/selftest (Self Test, created here).
set -euo pipefail

root=$(cd "$(dirname "$0")/../.." && pwd)
db="mariadb --no-defaults --protocol=tcp -h127.0.0.1 -P3307"

wait_for() {
  for _ in $(seq "$2"); do eval "$1" && return 0; sleep 1; done
  return 1
}

reset_characters() {
  $db -upokeverse -ppokeverse pokeverse -e "UPDATE players p JOIN selftest_start s ON s.id = p.id
    SET p.posx = s.posx, p.posy = s.posy, p.posz = s.posz, p.direction = s.direction"
}

case "${1:-}" in
  start)
    binary=$(realpath "$2")
    work=$(realpath -m "$3")
    "$0" stop "$work"
    rm -rf "$work"
    mkdir -p "$work"
    mariadb-install-db --no-defaults --datadir="$work/db" --auth-root-authentication-method=normal >"$work/db-install.log" 2>&1
    mariadbd --no-defaults --datadir="$work/db" --port=3307 --bind-address=127.0.0.1 \
      --socket="$work/db.sock" --log-error="$work/db-error.log" --pid-file="$work/db.pid" &
    echo $! > "$work/db.pid.shell"
    wait_for "$db -uroot -e 'SELECT 1' >/dev/null 2>&1" 60 || { echo "MariaDB did not start" >&2; exit 1; }

    $db -uroot < "$root/core/database/00-create-database.sql"
    $db -upokeverse -ppokeverse pokeverse < "$root/core/server/schemas/mysql.sql"
    for f in "$root/core/server/schemas/pokeverse-extensions.sql" "$root/core/database/20-world-defaults.sql" \
             "$root/core/database/30-account-tools.sql" "$root/core/database/40-dev-seed.sql"; do
      $db -upokeverse -ppokeverse pokeverse < "$f"
    done
    $db -upokeverse -ppokeverse pokeverse -e "CALL pokeverse_create_account('selftest', 'selftest');
      CALL pokeverse_create_character('selftest', 'Self Test', 0);
      CREATE TABLE selftest_start AS SELECT id, posx, posy, posz, direction FROM players;"

    mkdir -p "$work/server/logs/server" "$work/server/logs/chat" "$work/server/logs/bots"
    cp -r "$root/core/server/data" "$root/core/server/config.lua" "$root/core/server/pt_br.loc" "$work/server/"
    cp "$binary" "$work/server/"
    (cd "$work/server" && exec "./$(basename "$binary")" >"$work/server.log" 2>&1) &
    echo $! > "$work/server.pid"
    wait_for "grep -q 'server Online!' '$work/server.log' 2>/dev/null" 180 || {
      tail -50 "$work/server.log"; echo "server did not start" >&2; exit 1; }
    echo "Server online (work dir $work)"
    ;;
  stop)
    work=$(realpath -m "$2")
    if [ -f "$work/server.pid" ]; then
      pid=$(cat "$work/server.pid")
      kill -INT "$pid" 2>/dev/null || true
      wait_for "! kill -0 $pid 2>/dev/null" 60 || kill -9 "$pid" 2>/dev/null || true
      rm -f "$work/server.pid"
    fi
    if [ -f "$work/db.pid.shell" ]; then
      pid=$(cat "$work/db.pid.shell")
      kill "$pid" 2>/dev/null || true
      wait_for "! kill -0 $pid 2>/dev/null" 30 || kill -9 "$pid" 2>/dev/null || true
      rm -f "$work/db.pid.shell"
    fi
    ;;
  reset)
    for _ in $(seq 30); do
      [ "$($db -upokeverse -ppokeverse -N pokeverse -e "SELECT COUNT(*) FROM players WHERE online = 1")" = 0 ] && break
      sleep 1
    done
    reset_characters
    ;;
  *)
    sed -n '2,10p' "$0" >&2
    exit 1
    ;;
esac
