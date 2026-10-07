#!/usr/bin/env bash
# Log the staged Redemption client into a running PokeVerse server and walk one step.
# Runs a throwaway copy of dist/client-redemption with tools/redemption_smoke_rc.lua as
# otclientrc.lua, so the shipped dist never contains test code. Linux (Xvfb) and Windows
# (Git Bash / MSYS2; the client needs an OpenGL driver, e.g. Mesa llvmpipe DLLs in DIST).
# Usage: tools/smoke_redemption_login.sh [LOGFILE]
# Env: PV_ACCOUNT PV_PASSWORD PV_CHARACTER (default player/player/Trainer), PV_HOST, PV_LOGIN_PORT,
#      PV_TIMEOUT_MS, DIST (default dist/client-redemption; the client folder of the Windows test
#      package works too), DISPLAY (Linux; Xvfb is started if
#      the display is not running), SCREENSHOT (PNG path, captured once the map has loaded, or at
#      the first smoke line starting with SCREENSHOT_AT),
#      PV_EXPECT_POKEBAR=1 (a GM with Pokemon: the bar must show a portrait, clicking it must summon
#      that Pokemon, its moves must fill the move bar, and a move used on a spawned Rattata must
#      come back with a cooldown; Pokemon Info must open, spend one EV point, refuse a forged
#      upgrade and keep the EVs after recall and summon).
#      Every character with a Pokedex must get the status list at login, open the Pokedex window
#      from the main panel and see a known entry's details (PV_DEX_HOLD_MS keeps it open longer,
#      PV_DEX_TAB=1|2|3 shows the Information, Moves or Types tab).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DIST="${DIST:-$ROOT/dist/client-redemption}"
LOG="${1:-/tmp/redemption-smoke.log}"
EXE=$(cd "$DIST" && ls pokeverse-client pokeverse-client.exe pokeverse-client-debug pokeverse-client-debug.exe PokeVerse.exe 2>/dev/null | head -1 || true)
[ -n "$EXE" ] || { echo "no client in $DIST; run tools/stage_redemption.sh" >&2; exit 1; }
[ -f "$DIST/data/things/854/Tibia.spr" ] || { echo "no 854 assets in $DIST (git lfs pull, then restage)" >&2; exit 1; }
case "$(uname -s)" in MINGW*|MSYS*|CYGWIN*) WINDOWS=1 ;; *) WINDOWS=0 ;; esac
export PV_TIMEOUT_MS="${PV_TIMEOUT_MS:-120000}"

RUN=$(mktemp -d "${TMPDIR:-/tmp}/redemption-smoke.XXXXXX")
cleanup() {
    [ "$WINDOWS" = 1 ] && taskkill //F //IM "$EXE" > /dev/null 2>&1 || true
    [ -n "${XVFB_PID:-}" ] && kill "$XVFB_PID" 2>/dev/null || true
    rm -rf "$RUN"
}
trap cleanup EXIT
cp -al "$DIST/." "$RUN/" 2>/dev/null || cp -a "$DIST/." "$RUN/"
rm -f "$RUN/otclientrc.lua"
cp "$ROOT/tools/redemption_smoke_rc.lua" "$RUN/otclientrc.lua"

if [ "$WINDOWS" = 0 ]; then
    export DISPLAY="${DISPLAY:-:99}"
    DISPLAY_NUM="${DISPLAY#*:}"; DISPLAY_NUM="${DISPLAY_NUM%%.*}"
    if [ ! -S "/tmp/.X11-unix/X$DISPLAY_NUM" ]; then
        Xvfb ":$DISPLAY_NUM" -screen 0 1280x1024x24 >/dev/null 2>&1 &
        XVFB_PID=$!
        sleep 2
    fi
    export HOME="$RUN/home"
    mkdir -p "$HOME"
fi

screenshot() {
    if [ "$WINDOWS" = 1 ]; then
        powershell -NoProfile -Command "Add-Type -AssemblyName System.Windows.Forms, System.Drawing;
            \$b = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds;
            \$bmp = New-Object System.Drawing.Bitmap \$b.Width, \$b.Height;
            [System.Drawing.Graphics]::FromImage(\$bmp).CopyFromScreen(\$b.Location, [System.Drawing.Point]::Empty, \$b.Size);
            \$bmp.Save('$(cygpath -w "$1" 2>/dev/null || echo "$1")')" || true
    else
        import -window root "$1" || true
    fi
}

# The client's own log file (<compact name>.log in its work dir) is the reliable output on
# Windows, where a GUI executable's stdout may not reach the pipe.
client_log() { cat "$RUN/stdout.log" "$RUN"/*.log 2>/dev/null | grep -a '' || true; }

( cd "$RUN" && "./$EXE" ) > "$RUN/stdout.log" 2>&1 &
CLIENT_PID=$!
shot_taken=0
deadline=$((SECONDS + PV_TIMEOUT_MS / 1000 + 30))
while kill -0 "$CLIENT_PID" 2>/dev/null && [ "$SECONDS" -lt "$deadline" ]; do
    if [ -n "${SCREENSHOT:-}" ] && [ "$shot_taken" = 0 ] && client_log | grep -aq "\[pv-smoke\] ${SCREENSHOT_AT:-MAP tiles=}"; then
        sleep 0.3; screenshot "$SCREENSHOT"; shot_taken=1
    fi
    client_log | grep -aq '\[pv-smoke\] EXIT ' && sleep 2 && break
    sleep 0.5
done
kill "$CLIENT_PID" 2>/dev/null || true
[ "$WINDOWS" = 1 ] && taskkill //F //IM "$EXE" > /dev/null 2>&1 || true
wait "$CLIENT_PID" 2>/dev/null || true
cp "$RUN/stdout.log" "$LOG"
for f in "$RUN"/*.log; do [ "$f" = "$RUN/stdout.log" ] || { echo "== $(basename "$f")"; cat "$f"; } >> "$LOG"; done

fail() { echo "FAIL: $1" >&2; grep -a '\[pv-smoke\]\|ERROR\|rror' "$LOG" | tail -30 >&2; exit 1; }
need() { grep -aq -- "$1" "$LOG" || fail "$2"; }
need '\[pv-smoke\] THINGS LOADED' "854 SPR/DAT did not load"
need '\[pv-smoke\] CHARLIST count=' "no character list"
need "\[pv-smoke\] CHARACTER name=${PV_CHARACTER:-Trainer} " "character ${PV_CHARACTER:-Trainer} missing from the list"
need '\[pv-smoke\] GAME START' "did not enter the game"
need '\[pv-smoke\] POKEVERSE ' "no PokeVerse 0xFF sub-protocol signal parsed"
need '\[pv-smoke\] MAP tiles=[1-9]' "no map tiles received"
need '\[pv-smoke\] MODULE game_pokebar visible=' "game_pokebar module not loaded"
if [ "${PV_EXPECT_POKEBAR:-0}" = 1 ]; then
    need '\[pv-smoke\] MODULE game_pokebar visible=true portraits=[1-9]' "Pokemon bar shows no portrait"
    need '\[pv-smoke\] SUMMON OK' "clicking a Pokemon bar portrait did not summon that Pokemon"
    if grep -aq '\[pv-smoke\] SWITCH ' "$LOG"; then
        need '\[pv-smoke\] SWITCH OK' "clicking a second portrait did not switch the summoned Pokemon"
    fi
    need '\[pv-smoke\] HUD trainer=[1-9][0-9]*/[1-9][0-9]* energy=[0-9]*/[1-9][0-9]* pokemonLevel=[1-9]' "the HUD stats (trainer health, Pokemon energy and level) were not received"
    need '\[pv-smoke\] MODULE game_pokemoves visible=true moves=[1-9]' "move bar empty for the summoned Pokemon"
    need '\[pv-smoke\] MOVE OK' "using a move from the move bar got no cooldown from the server"
    need '\[pv-smoke\] MODULE game_pokemonInfo button=true' "Pokemon Info button missing from the main panel"
    need '\[pv-smoke\] INFO OPEN OK visible=true' "Pokemon Info did not open with the server's data"
    if ! grep -aq '\[pv-smoke\] EV SKIPPED' "$LOG"; then
        need '\[pv-smoke\] EV ALLOCATE OK' "spending an EV point was not applied by the server"
        need '\[pv-smoke\] EV FORGED REJECTED' "the server accepted a forged EV upgrade"
        need '\[pv-smoke\] RECALL OK' "clicking the summoned Pokemon's portrait did not recall it"
        need '\[pv-smoke\] RESUMMON OK' "the recalled Pokemon was not summoned again"
        need '\[pv-smoke\] EV PERSIST OK' "spent EVs were lost after recall and summon"
    fi
fi
need '\[pv-smoke\] MODULE game_pokedex button=true' "Pokedex button missing from the main panel"
if ! grep -aq '\[pv-smoke\] DEX SKIPPED' "$LOG"; then
    need '\[pv-smoke\] POKEVERSE onPokedexStatus ' "the Pokedex status list was not sent"
    need '\[pv-smoke\] DEX LOGIN STATUS OK' "the Pokedex status list did not arrive at login"
    need '\[pv-smoke\] DEX OPEN OK visible=true' "using the Pokedex did not open the Pokedex window"
    if ! grep -aq '\[pv-smoke\] DEX INFO SKIPPED' "$LOG"; then
        need '\[pv-smoke\] DEX INFO OK' "clicking a known Pokedex entry did not show its details"
    fi
    need '\[pv-smoke\] DEX CLOSE OK' "the Pokedex window did not close"
fi
need '\[pv-smoke\] QUESTLOG OK' "the quest log did not arrive (the server crashed on it before the Quest::getName fix)"
need '\[pv-smoke\] ACHIEVEMENTS OK entries=[1-9]' "the Achievements quest line was empty"
need '\[pv-smoke\] TM WINDOW OK moves=3' "the TM chooser did not show the Pokemon's moves"
need '\[pv-smoke\] TM CONFIRM OK' "choosing a move did not open the TM confirmation"
need '\[pv-smoke\] TM BACK OK' "cancelling the TM confirmation did not go back to the move list"
need '\[pv-smoke\] TM FORGED REJECTED closed=true' "the server accepted /tc without a TM in use"
need '\[pv-smoke\] STATUSBAR ADD OK visible=true' "status condition icons did not show"
need '\[pv-smoke\] STATUSBAR REMOVE OK' "removing a status condition did not remove its icon"
need '\[pv-smoke\] STATUSBAR CLEAR OK' "clearing the status bar left icons"
need '\[pv-smoke\] MODULE game_pass button=true' "Battle Pass module or its main panel button is missing"
need '\[pv-smoke\] PASS OPEN OK visible=true' "the Battle Pass window did not open with rewards from the server"
need '\[pv-smoke\] PASS FORGED COLLECT IGNORED' "the server answered a forged Battle Pass collect"
need '\[pv-smoke\] PASS BUY REFUSED' "buying a Battle Pass for the ended season was not refused"
need '\[pv-smoke\] PASS CLOSE OK' "the Battle Pass window did not close"
need '\[pv-smoke\] WALK OK' "walking did not move the player"
need '\[pv-smoke\] GAME END' "did not log out"
need '\[pv-smoke\] EXIT 0' "client reported failure"
if grep -aE 'Unhandled opcode|parse message exception|invalid checksum|unable to load|unknown 0xFF sub-opcode|pokebar: no Pokemon for icon item|LUA ERROR|lua_pcall' "$LOG" >&2; then
    fail "protocol errors in the client log"
fi
grep -a '\[pv-smoke\]' "$LOG" | LC_ALL=C sort -u
echo "Redemption login smoke: PASS"
