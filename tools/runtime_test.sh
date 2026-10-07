#!/usr/bin/env bash
# DEVELOPMENT ONLY. Scripted runtime test of the in-game systems against a running
# source-built server: installs the pv_harness client module into the client's user
# directory, logs in as the seeded GM account, lets the harness drive each system
# (see tools/runtime-harness/pv_harness/pv_harness.lua), screenshots every step and
# collects the [PVH] log lines. The harness is removed again afterwards.
# Uses the dist/client-harness build (VARIANT=harness tools/build_client.sh), which has
# OTClient bot protection off so Lua can issue game actions.
# Usage: tools/runtime_test.sh [out-dir] [server-log]   (needs DISPLAY and xdotool)
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="${1:-/tmp/runtime-harness}"
SERVER_LOG="${2:-/tmp/server-run.log}"
USER_DIR="$HOME/.Pokecenter"
MODULE_DIR="$USER_DIR/pv_harness"
STEP_FILE="$USER_DIR/harness_step.txt"
: "${DISPLAY:?set DISPLAY (for example run under xvfb-run)}"

mkdir -p "$OUT" "$USER_DIR"
rm -rf "$MODULE_DIR" "$STEP_FILE"
cp -r "$ROOT/tools/runtime-harness/pv_harness" "$MODULE_DIR"
cleanup() {
    # The client ignores SIGTERM.
    pkill -9 -f "client-harness/pokeverse-client|^./pokeverse-client" 2>/dev/null || true
    rm -rf "$MODULE_DIR" "$STEP_FILE"
}
trap cleanup EXIT

# Start from the seeded inventory: drop everything the previous run left in containers
# and the feet (ball) slot. Only safe while the character is logged out.
MYSQL="${MYSQL:-mysql -upokeverse -ppokeverse-dev}"
$MYSQL pokeverse -e "DELETE FROM player_items WHERE (pid >= 101 OR pid = 8)
    AND player_id = (SELECT id FROM players WHERE name = '${CHARACTER:-GM Admin}')
    AND itemtype NOT BETWEEN 12214 AND 12228"

server_lines_before=$(wc -l < "$SERVER_LOG")
PV_HARNESS=1 KEEP_CLIENT=1 CLIENT_LOG="$OUT/client.log" SHOT="$OUT/00-login.png" \
    CLIENT_DIR="${CLIENT_DIR:-$ROOT/dist/client-harness}" \
    "$ROOT/tools/smoke_login.sh" "${ACCOUNT:-admin}" "${PASSWORD:-admin}" "${CHARACTER:-GM Admin}" "$SERVER_LOG"

last=""
for _ in $(seq 1 600); do
    step=$(cat "$STEP_FILE" 2>/dev/null || true)
    if [ -n "$step" ] && [ "$step" != "$last" ]; then
        last="$step"
        [ "$step" = DONE ] && break
        case "$step" in *-end) import -window root "$OUT/$step.png" 2>/dev/null || true ;; esac
    fi
    sleep 0.5
done
sleep 5  # the harness logs out after DONE; let the server save the character

grep -a "\[PVH\]" "$OUT/client.log" | iconv -f latin1 -t utf-8 > "$OUT/harness.log" || true
tail -n +"$((server_lines_before + 1))" "$SERVER_LOG" > "$OUT/server.log"
grep -a -E "^ERROR|attempt to|stack traceback" "$OUT/client.log" > "$OUT/client-errors.log" || true
echo "Harness finished at step '$last'. Results in $OUT (harness.log, server.log, client-errors.log, *.png)"
[ "$last" = DONE ]
