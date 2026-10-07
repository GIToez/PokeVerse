#!/usr/bin/env bash
# DEVELOPMENT ONLY. Headless server runtime test that works on Linux and on Windows
# (MSYS2), with no client or display: tools/protocol_client.py speaks the game protocol.
# Starts the source-built server, then checks, in order:
#   character list, wrong password refused, player login and logout, a GM command
#   (/i creates items) saved to the database on logout, clean shutdown with /shutdown,
#   restart, and that the saved items survive the restart and the next login.
# Needs the dev database (tools/setup_dev_db.sh) and no server already running.
# Usage: tools/protocol_smoke.sh [log-dir]
# Environment: MYSQL (default "mysql -upokeverse -ppokeverse-dev"), PYTHON (python3).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
LOGDIR="${1:-/tmp/protocol-smoke}"
MYSQL="${MYSQL:-mysql -upokeverse -ppokeverse-dev}"
PYTHON="${PYTHON:-python3}"
PV="$PYTHON $ROOT/tools/protocol_client.py"
APPLE=35547
mkdir -p "$LOGDIR"

fail() { echo "FAIL: $*" >&2; exit 1; }
pass() { echo "PASS: $*"; }
sql() { $MYSQL pokeverse -N -e "$1" | tr -d '\r'; }
apples() {
    sql "SELECT COALESCE(SUM(i.count), 0) FROM player_items i JOIN players p ON p.id = i.player_id
         WHERE p.name = 'GM Admin' AND i.itemtype = $APPLE"
}
port_open() {
    $PYTHON -c "import socket,sys; s=socket.socket(); s.settimeout(1); sys.exit(s.connect_ex(('127.0.0.1', int(sys.argv[1]))))" "$1"
}
start_server() {
    KEEP_RUNNING=1 "$ROOT/tools/smoke_server.sh" "$1" || fail "server did not start (see $1)"
}
# /shutdown is the GM command for a save-and-shutdown (GAME_STATE_SHUTDOWN). The server
# closes the GM's connection while it shuts down, so the client's exit status is ignored.
shutdown_server() {
    $PV enter admin admin "GM Admin" --say "/shutdown" --stay 1 > /dev/null || true
    for _ in $(seq 1 60); do
        port_open 8548 || port_open 7564 || break
        sleep 1
    done
    ! port_open 8548 && ! port_open 7564 || fail "server still listening 60s after /shutdown"
    grep -q "SAVE: Complete" "$1" || fail "no 'SAVE: Complete' in $1 after /shutdown"
    grep -q "Preparing to shutdown the server- done." "$1" || fail "shutdown did not finish ($1)"
}

port_open 7564 && fail "a server is already listening on 7564; stop it first"

start_server "$LOGDIR/server-1.log"
pass "server started"

$PV charlist player player | tee "$LOGDIR/charlist.txt" | grep -q "^Trainer	" ||
    fail "character list for 'player' has no Trainer"
pass "login server: character list"

{ $PV charlist player wrong-password || true; } | grep -q "LOGIN ERROR" || fail "wrong password was accepted"
pass "login server: wrong password refused"

$PV enter player player Trainer --stay 2 || fail "Trainer could not enter the game"
grep -q "Trainer has logged in." "$LOGDIR/server-1.log" || fail "server did not log Trainer in"
grep -q "Trainer has logged out." "$LOGDIR/server-1.log" || fail "server did not log Trainer out"
pass "game server: player login and logout"

before=$(apples)
$PV enter admin admin "GM Admin" --say "/i $APPLE,2" --stay 2 || fail "GM Admin could not enter the game"
sleep 1
after=$(apples)
[ "$after" -eq $((before + 2)) ] || fail "GM /i: expected $((before + 2)) apples saved, database has $after"
pass "admin command /i, and save on logout ($before -> $after apples)"

shutdown_server "$LOGDIR/server-1.log"
pass "clean shutdown with /shutdown (world saved, ports closed)"

start_server "$LOGDIR/server-2.log"
pass "server restarted"
[ "$(apples)" -eq "$after" ] || fail "items changed across the restart"
$PV enter admin admin "GM Admin" --stay 2 || fail "GM Admin could not enter the game after the restart"
sleep 1
[ "$(apples)" -eq "$after" ] || fail "items lost on load and save after the restart (expected $after, got $(apples))"
$PV enter player player Trainer --stay 1 || fail "Trainer could not enter the game after the restart"
pass "restart persistence: items loaded and saved again after the restart"

shutdown_server "$LOGDIR/server-2.log"
pass "second clean shutdown"
echo "PASS: protocol smoke test complete (logs in $LOGDIR)"
