#!/usr/bin/env bash
# End-to-end login smoke test with the source-built client (dist/client) against a
# running source-built server: log in as the seeded development account, pick the
# first character and check that the server reports it entering the game.
# Needs an X display (DISPLAY, e.g. Xvfb) and xdotool. Saves a screenshot when
# ImageMagick's `import` is available.
# Usage: tools/smoke_login.sh [account] [password] [character] [server-log]
# Run it with the character logged out; a reconnect to an online character
# does not print a new "has logged in" line on the server.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ACCOUNT="${1:-player}"
PASSWORD="${2:-player}"
CHARACTER="${3:-Trainer}"
SERVER_LOG="${4:-/tmp/server-run.log}"
SHOT="${SHOT:-/tmp/smoke_login.png}"
: "${DISPLAY:?set DISPLAY (for example run under xvfb-run)}"

[ -f "$SERVER_LOG" ] || { echo "FAIL: server log $SERVER_LOG not found" >&2; exit 1; }
before=$(grep -c "$CHARACTER has logged in" "$SERVER_LOG" || true)

cd "$ROOT/dist/client"
./pokeverse-client > /tmp/smoke_client.log 2>&1 &
client=$!
trap 'kill $client 2>/dev/null || true' EXIT

window=""
for _ in $(seq 1 60); do
    window=$(xdotool search --name "Jornadas" 2>/dev/null | head -1 || true)
    [ -n "$window" ] && break
    sleep 1
done
[ -n "$window" ] || { echo "FAIL: client window did not appear" >&2; exit 1; }
sleep 8
xdotool windowactivate --sync "$window" 2>/dev/null || xdotool windowfocus --sync "$window"
eval "$(xdotool getwindowgeometry --shell "$window")"
# Account field of the enter-game window, relative to the 800x600 client area.
xdotool mousemove $((X + 173)) $((Y + 254)) click 1
sleep 0.5
xdotool type --delay 50 "$ACCOUNT"
xdotool key Tab
xdotool type --delay 50 "$PASSWORD"
xdotool key Return
sleep 5
# "Selecionar" button of the character list (first character is preselected).
xdotool mousemove $((X + 467)) $((Y + 471)) click 1

# The client titles its window "... | Jogador: <name>" once the character is in the game.
for _ in $(seq 1 30); do
    if xdotool getwindowname "$window" 2>/dev/null | grep -q "Jogador: $CHARACTER"; then
        sleep 5
        command -v import > /dev/null && import -window root "$SHOT" || true
        now=$(grep -c "$CHARACTER has logged in" "$SERVER_LOG" || true)
        echo "PASS: $CHARACTER entered the game (server log logins: $before -> $now, screenshot: $SHOT)"
        exit 0
    fi
    sleep 1
done
command -v import > /dev/null && import -window root "$SHOT" || true
echo "FAIL: $CHARACTER did not enter the game (screenshot: $SHOT)" >&2
exit 1
