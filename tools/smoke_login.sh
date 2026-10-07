#!/usr/bin/env bash
# End-to-end login smoke test with the source-built client (dist/client) against a
# running source-built server: log in as the seeded development account, pick the
# first character and check that the server reports it entering the game.
# Needs an X display (DISPLAY, e.g. Xvfb), xdotool and xwininfo (x11-utils). Saves a screenshot when
# ImageMagick's `import` is available.
# Usage: tools/smoke_login.sh [account] [password] [character] [server-log]
# Environment: SHOT (screenshot path), CLIENT_LOG (client output), KEEP_CLIENT=1,
# CLIENT_DIR (default dist/client).
# Run it with the character logged out; a reconnect to an online character
# does not print a new "has logged in" line on the server.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ACCOUNT="${1:-player}"
PASSWORD="${2:-player}"
CHARACTER="${3:-Trainer}"
SERVER_LOG="${4:-/tmp/server-run.log}"
SHOT="${SHOT:-/tmp/smoke_login.png}"
CLIENT_LOG="${CLIENT_LOG:-/tmp/smoke_client.log}"
: "${DISPLAY:?set DISPLAY (for example run under xvfb-run)}"

[ -f "$SERVER_LOG" ] || { echo "FAIL: server log $SERVER_LOG not found" >&2; exit 1; }
before=$(grep -c "$CHARACTER has logged in" "$SERVER_LOG" || true)

# A fresh profile opens a language picker over the login form; preselect English.
PROFILE="$HOME/.Pokecenter"
mkdir -p "$PROFILE"
grep -qs '^locale:' "$PROFILE/config.otml" || echo "locale: en" >> "$PROFILE/config.otml"

cd "${CLIENT_DIR:-$ROOT/dist/client}"
./pokeverse-client > "$CLIENT_LOG" 2>&1 &
client=$!
# KEEP_CLIENT=1 leaves the client running in the game after a PASS (used by runtime_test.sh).
trap '[ "${KEEP_CLIENT:-0}" = 1 ] && [ "${passed:-0}" = 1 ] || kill $client 2>/dev/null || true' EXIT

window=""
for _ in $(seq 1 60); do
    window=$(xdotool search --name "Jornadas" 2>/dev/null | head -1 || true)
    [ -n "$window" ] && break
    sleep 1
done
[ -n "$window" ] || { echo "FAIL: client window did not appear" >&2; exit 1; }
sleep 8
xdotool windowactivate --sync "$window" 2>/dev/null || xdotool windowfocus --sync "$window"
# Client-area origin. Under a window manager `xdotool getwindowgeometry` reports a
# position offset by the frame decorations; xwininfo's absolute origin does not.
X=$(xwininfo -id "$window" | awk '/Absolute upper-left X/ {print $NF}')
Y=$(xwininfo -id "$window" | awk '/Absolute upper-left Y/ {print $NF}')
# Account and password inputs of the enter-game window, relative to the 800x600 client
# area. Click each one: without a window manager keyboard focus follows the pointer.
xdotool mousemove $((X + 178)) $((Y + 281)) click 1
sleep 0.5
xdotool key ctrl+a BackSpace
xdotool type --delay 50 "$ACCOUNT"
xdotool mousemove $((X + 178)) $((Y + 363)) click 1
sleep 0.5
xdotool key ctrl+a BackSpace
xdotool type --delay 50 "$PASSWORD"
xdotool key Return
sleep 5
# "Selecionar" button of the character list (first character is preselected).
xdotool mousemove $((X + 470)) $((Y + 499)) click 1

# The client titles its window "... | Jogador: <name>" once the character is in the game.
for _ in $(seq 1 30); do
    if xdotool getwindowname "$window" 2>/dev/null | grep -q "Jogador: $CHARACTER"; then
        sleep 5
        command -v import > /dev/null && import -window root "$SHOT" || true
        now=$(grep -c "$CHARACTER has logged in" "$SERVER_LOG" || true)
        passed=1
        echo "PASS: $CHARACTER entered the game (server log logins: $before -> $now, screenshot: $SHOT)"
        exit 0
    fi
    sleep 1
done
command -v import > /dev/null && import -window root "$SHOT" || true
echo "FAIL: $CHARACTER did not enter the game (screenshot: $SHOT)" >&2
exit 1
