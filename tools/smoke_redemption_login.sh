#!/usr/bin/env bash
# Log the staged Redemption client into a running PokeVerse server and walk one step.
# Runs a throwaway copy of dist/client-redemption with tools/redemption_smoke_rc.lua as
# otclientrc.lua, so the shipped dist never contains test code.
# Usage: tools/smoke_redemption_login.sh [LOGFILE]
# Env: PV_ACCOUNT PV_PASSWORD PV_CHARACTER (default player/player/Trainer), PV_HOST, PV_LOGIN_PORT,
#      PV_TIMEOUT_MS, DIST (default dist/client-redemption), DISPLAY (Xvfb :99 is started if unset).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DIST="${DIST:-$ROOT/dist/client-redemption}"
LOG="${1:-/tmp/redemption-smoke.log}"
EXE=$(cd "$DIST" && ls pokeverse-client pokeverse-client.exe pokeverse-client-debug pokeverse-client-debug.exe 2>/dev/null | head -1 || true)
[ -n "$EXE" ] || { echo "no client in $DIST; run tools/stage_redemption.sh" >&2; exit 1; }
[ -f "$DIST/data/things/854/Tibia.spr" ] || { echo "no 854 assets in $DIST (git lfs pull, then restage)" >&2; exit 1; }

RUN=$(mktemp -d /tmp/redemption-smoke.XXXXXX)
trap 'rm -rf "$RUN"; [ -n "${XVFB_PID:-}" ] && kill "$XVFB_PID" 2>/dev/null || true' EXIT
cp -al "$DIST/." "$RUN/" 2>/dev/null || cp -a "$DIST/." "$RUN/"
rm -f "$RUN/otclientrc.lua"
cp "$ROOT/tools/redemption_smoke_rc.lua" "$RUN/otclientrc.lua"

export DISPLAY="${DISPLAY:-:99}"
DISPLAY_NUM="${DISPLAY#*:}"; DISPLAY_NUM="${DISPLAY_NUM%%.*}"
if [ ! -S "/tmp/.X11-unix/X$DISPLAY_NUM" ]; then
    Xvfb ":$DISPLAY_NUM" -screen 0 1280x1024x24 >/dev/null 2>&1 &
    XVFB_PID=$!
    sleep 2
fi

export HOME="$RUN/home"
mkdir -p "$HOME"
( cd "$RUN" && timeout 120 "./$EXE" ) > "$LOG" 2>&1 || true

fail() { echo "FAIL: $1" >&2; grep -a '\[pv-smoke\]\|ERROR\|rror' "$LOG" | tail -30 >&2; exit 1; }
need() { grep -aq -- "$1" "$LOG" || fail "$2"; }
need '\[pv-smoke\] THINGS LOADED' "854 SPR/DAT did not load"
need '\[pv-smoke\] CHARLIST count=' "no character list"
need "\[pv-smoke\] CHARACTER name=${PV_CHARACTER:-Trainer} " "character ${PV_CHARACTER:-Trainer} missing from the list"
need '\[pv-smoke\] GAME START' "did not enter the game"
need '\[pv-smoke\] POKEVERSE ' "no PokeVerse 0xFF sub-protocol signal parsed"
need '\[pv-smoke\] MAP tiles=[1-9]' "no map tiles received"
need '\[pv-smoke\] WALK OK' "walking did not move the player"
need '\[pv-smoke\] GAME END' "did not log out"
need '\[pv-smoke\] EXIT 0' "client reported failure"
if grep -aE 'Unhandled opcode|parse message exception|invalid checksum|unable to load|unknown 0xFF sub-opcode|LUA ERROR|lua_pcall' "$LOG" >&2; then
    fail "protocol errors in the client log"
fi
grep -a '\[pv-smoke\]' "$LOG"
echo "Redemption login smoke: PASS"
