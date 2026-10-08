#!/usr/bin/env bash
# Log the legacy client (client/source + client/runtime-data) into a running PokeVerse server with
# the test-only Lua module tools/legacy-smoke/pv_legacy_smoke, without xdotool, so it also runs on
# Windows (Git Bash / MSYS2). Runs a throwaway copy of the client folder; the module is copied into
# the client's user directory (~/.Pokecenter, %USERPROFILE%\Pokecenter) for this run only.
# Usage: tools/smoke_legacy_login.sh [LOGFILE] [SERVER_LOG]
#   With SERVER_LOG (the running server's output), the character must log in and out there.
# Env: CLIENT_DIR (default dist/client; the legacy-client folder of a package works too),
#      PV_ACCOUNT PV_PASSWORD PV_CHARACTER (default player/player/Trainer), PV_IN_GAME_MS,
#      PV_TIMEOUT_MS, SCREENSHOT (PNG, taken in the game), METRICS (file for startup time, memory,
#      FPS and error counts), MESA_DIR (Windows without a GPU: Mesa opengl32.dll and friends to put
#      into the run copy), DISPLAY (Linux; Xvfb is started when the display is not running).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CLIENT_DIR="${CLIENT_DIR:-$ROOT/dist/client}"
LOG="${1:-/tmp/legacy-smoke.log}"
SERVER_LOG="${2:-}"
case "$(uname -s)" in MINGW*|MSYS*|CYGWIN*) WINDOWS=1 ;; *) WINDOWS=0 ;; esac
EXE=$(cd "$CLIENT_DIR" && ls pokeverse-legacy-client pokeverse-legacy-client.exe pokeverse-client pokeverse-client.exe 2>/dev/null | head -1 || true)
[ -n "$EXE" ] || { echo "no legacy client executable in $CLIENT_DIR" >&2; exit 1; }
[ -f "$CLIENT_DIR/modules/gamelib/info" ] || [ -f "$CLIENT_DIR/modules/game_pokebar/pokebar.otmod" ] ||
    { echo "$CLIENT_DIR is not a legacy client folder" >&2; exit 1; }
export PV_TIMEOUT_MS="${PV_TIMEOUT_MS:-180000}"

RUN=$(mktemp -d "${TMPDIR:-/tmp}/legacy-smoke.XXXXXX")
if [ "$WINDOWS" = 1 ]; then
    USER_DIR="$(cygpath -u "$USERPROFILE")/Pokecenter"
else
    export HOME="$RUN/home"
    USER_DIR="$HOME/.Pokecenter"
fi
MODULE="$USER_DIR/pv_legacy_smoke"
# init.lua writes the log into the user's home folder itself, next to the settings folder.
CLIENT_LOG="$(dirname "$USER_DIR")/Pokecenter.log"
cleanup() {
    [ "$WINDOWS" = 1 ] && taskkill //F //IM "$EXE" > /dev/null 2>&1 || true
    [ -n "${CLIENT_PID:-}" ] && kill -9 "$CLIENT_PID" 2>/dev/null || true
    [ -n "${XVFB_PID:-}" ] && kill "$XVFB_PID" 2>/dev/null || true
    rm -rf "$MODULE" "$RUN"
}
trap cleanup EXIT

cp -aL "$CLIENT_DIR/." "$RUN/"
rm -f "$RUN"/*.log
if [ -n "${MESA_DIR:-}" ]; then
    cp "$MESA_DIR"/*.dll "$RUN/"
    # init.lua refuses to start next to an opengl32.dll (a wrapper DLL could be a cheat). Only this
    # throwaway copy, which needs Mesa's software OpenGL on a GPU-less runner, drops that check.
    perl -0pi -e 's/ or file_exists\(g_resources\.getWorkDir\(\) \.\. "opengl32\.dll"\)//' "$RUN/init.lua"
fi
mkdir -p "$USER_DIR"
rm -rf "$MODULE" "$CLIENT_LOG"
cp -r "$ROOT/tools/legacy-smoke/pv_legacy_smoke" "$MODULE"
# A fresh profile opens a language picker over the login window; preselect English.
grep -qs '^locale:' "$USER_DIR/config.otml" || echo "locale: en" >> "$USER_DIR/config.otml"

if [ "$WINDOWS" = 0 ]; then
    export DISPLAY="${DISPLAY:-:99}"
    n="${DISPLAY#*:}"; n="${n%%.*}"
    if [ ! -S "/tmp/.X11-unix/X$n" ]; then
        Xvfb ":$n" -screen 0 1280x1024x24 > /dev/null 2>&1 &
        XVFB_PID=$!
        sleep 2
    fi
fi

screenshot() {
    if [ "$WINDOWS" = 1 ]; then
        powershell -NoProfile -Command "Add-Type -AssemblyName System.Windows.Forms, System.Drawing;
            \$b = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds;
            \$bmp = New-Object System.Drawing.Bitmap \$b.Width, \$b.Height;
            [System.Drawing.Graphics]::FromImage(\$bmp).CopyFromScreen(\$b.Location, [System.Drawing.Point]::Empty, \$b.Size);
            \$bmp.Save('$(cygpath -w "$1")')" || true
    else
        import -window root "$1" || true
    fi
}
memory_kb() {
    if [ "$WINDOWS" = 1 ]; then
        powershell -NoProfile -Command "(Get-Process -Name '${EXE%.exe}' -ErrorAction SilentlyContinue | Select-Object -First 1).WorkingSet64 / 1024" 2>/dev/null | tr -d '\r' | cut -d. -f1
    else
        awk '/^VmRSS/ {print $2}' "/proc/$CLIENT_PID/status" 2>/dev/null
    fi
}
client_log() { cat "$RUN/stdout.log" "$CLIENT_LOG" 2>/dev/null | grep -a '' || true; }

count() { [ -n "$SERVER_LOG" ] || { echo 0; return; }; grep -ac "${PV_CHARACTER:-Trainer} has logged $1" "$SERVER_LOG" || true; }
logins_before=$(count in); logouts_before=$(count out)
launched=$(date +%s%3N)
( cd "$RUN" && { [ ! -d lib ] || export LD_LIBRARY_PATH="$RUN/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"; } && exec "./$EXE" ) > "$RUN/stdout.log" 2>&1 &
CLIENT_PID=$!
shot=0 memory="" game_ms=""
deadline=$((SECONDS + PV_TIMEOUT_MS / 1000 + 30))
while kill -0 "$CLIENT_PID" 2>/dev/null && [ "$SECONDS" -lt "$deadline" ]; do
    if [ -z "$game_ms" ] && client_log | grep -aq '\[pv-smoke\] GAME START'; then
        game_ms=$(( $(date +%s%3N) - launched ))
    fi
    if [ "$shot" = 0 ] && client_log | grep -aq '\[pv-smoke\] SCREENSHOT'; then
        memory=$(memory_kb || true)
        [ -n "${SCREENSHOT:-}" ] && { sleep 0.5; screenshot "$SCREENSHOT"; }
        shot=1
    fi
    client_log | grep -aq '\[pv-smoke\] EXIT ' && sleep 2 && break
    sleep 0.5
done
kill "$CLIENT_PID" 2>/dev/null || true
for _ in 1 2 3 4 5 6 7 8 9 10; do kill -0 "$CLIENT_PID" 2>/dev/null || break; sleep 0.5; done
kill -9 "$CLIENT_PID" 2>/dev/null || true
cat "$CLIENT_LOG" > "$LOG" 2>/dev/null || cp "$RUN/stdout.log" "$LOG"
CLIENT_PID=""

fail() { echo "FAIL: $1" >&2; grep -a '\[pv-smoke\]\|ERROR\|rror' "$LOG" | tail -30 >&2; exit 1; }
need() { grep -aq -- "$1" "$LOG" || fail "$2"; }
need '\[pv-smoke\] LOADED' "the smoke module did not load"
need '\[pv-smoke\] LOGIN SCREEN' "the login window did not appear"
need '\[pv-smoke\] CHARLIST count=[1-9]' "no character list"
need "\[pv-smoke\] CHARACTER name=${PV_CHARACTER:-Trainer}" "character ${PV_CHARACTER:-Trainer} missing from the list"
need '\[pv-smoke\] GAME START' "did not enter the game"
need '\[pv-smoke\] MAP pos=[0-9]*,[0-9]*,[0-9]* tile=true' "no map tile under the player"
need '\[pv-smoke\] MODULE game_pokebar loaded=true' "game_pokebar module not loaded"
need '\[pv-smoke\] EXIT 0' "client reported failure"
if [ -n "$SERVER_LOG" ]; then
    for _ in $(seq 1 20); do [ "$(count out)" -gt "$logouts_before" ] && break; sleep 1; done
    [ "$(count in)" -gt "$logins_before" ] || fail "the server did not log ${PV_CHARACTER:-Trainer} in"
    [ "$(count out)" -gt "$logouts_before" ] || fail "the server did not log ${PV_CHARACTER:-Trainer} out after the client closed"
fi
if grep -a 'caught a lua call to a bot protected game function' "$LOG" >&2; then
    fail "the smoke module triggered bot protection"
fi

if [ -n "${METRICS:-}" ]; then
    {
        echo "client=legacy"
        echo "launch_to_game_ms=${game_ms:-unknown}"
        echo "memory_kb=${memory:-unknown}"
        grep -a '\[pv-smoke\] FPS' "$LOG" | head -1 | sed 's/.*FPS foreground=\([0-9]*\).*/fps=\1/'
        echo "texture_errors=$(grep -aci 'unable to load texture\|unable to load image' "$LOG" || true)"
        echo "lua_errors=$(grep -aciE 'lua error|lua_pcall|attempt to (index|call|compare|perform|concatenate)' "$LOG" || true)"
        echo "error_lines=$(grep -aci '\berror\b' "$LOG" || true)"
    } > "$METRICS"
fi
grep -a '\[pv-smoke\]' "$LOG" | sed 's/^.*\[pv-smoke\]/[pv-smoke]/' | LC_ALL=C sort -u
echo "Legacy login smoke: PASS"
