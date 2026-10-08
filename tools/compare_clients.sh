#!/usr/bin/env bash
# Run the Redemption and the legacy client one after the other against the same running PokeVerse
# server with the same account and character, in the same window size, and collect for each a
# screenshot in the game, the client log and metrics (time from launch to the game, memory with the
# map loaded, FPS, error counts), plus summary.md with both side by side.
# Linux: a private Xvfb display of exactly the window size, so the screenshots are the client window.
# Windows (Git Bash / MSYS2): the primary screen is captured; MESA_DIR as for the smoke scripts.
# Usage: tools/compare_clients.sh <out-dir> [server-log]
# Env: REDEMPTION_DIR (default dist/client-redemption), LEGACY_DIR (default dist/client),
#      PV_ACCOUNT PV_PASSWORD PV_CHARACTER (default player/player/Trainer), PV_WINDOW_SIZE (1280x720).
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="$(mkdir -p "${1:?usage: $0 <out-dir> [server-log]}" && cd "$1" && pwd)"
SERVER_LOG="${2:-}"
export PV_WINDOW_SIZE="${PV_WINDOW_SIZE:-1280x720}"
case "$(uname -s)" in MINGW*|MSYS*|CYGWIN*) WINDOWS=1 ;; *) WINDOWS=0 ;; esac

if [ "$WINDOWS" = 0 ]; then
    n=95
    while [ -e "/tmp/.X11-unix/X$n" ]; do n=$((n + 1)); done
    Xvfb ":$n" -screen 0 "${PV_WINDOW_SIZE}x24" -nolisten tcp > /dev/null 2>&1 &
    xvfb=$!
    trap 'kill $xvfb 2>/dev/null || true' EXIT
    export DISPLAY=":$n"
    sleep 2
fi

status=0
# The full Redemption smoke runs its gameplay checks too; only its first screenshot (map loaded,
# at the login position) is used, which is where the legacy screenshot is taken as well.
if DIST="${REDEMPTION_DIR:-$ROOT/dist/client-redemption}" SCREENSHOT="$OUT/redemption.png" \
    METRICS="$OUT/redemption-metrics.txt" "$ROOT/tools/smoke_redemption_login.sh" "$OUT/redemption.log" \
    > "$OUT/redemption-smoke.txt" 2>&1; then
    redemption=PASS
else
    redemption=FAIL; status=1
fi
# The server needs a moment to save the character the Redemption smoke logged out.
sleep 5
if CLIENT_DIR="${LEGACY_DIR:-$ROOT/dist/client}" SCREENSHOT="$OUT/legacy.png" \
    METRICS="$OUT/legacy-metrics.txt" "$ROOT/tools/smoke_legacy_login.sh" "$OUT/legacy.log" $SERVER_LOG \
    > "$OUT/legacy-smoke.txt" 2>&1; then
    legacy=PASS
else
    legacy=FAIL; status=1
fi

value() { grep -a "^$2=" "$OUT/$1-metrics.txt" 2>/dev/null | head -1 | cut -d= -f2-; }
{
    echo "# Client comparison run"
    echo
    echo "Server and database: the same running server for both. Account ${PV_ACCOUNT:-player}, character ${PV_CHARACTER:-Trainer}, window ${PV_WINDOW_SIZE}, $( [ "$WINDOWS" = 1 ] && echo Windows || echo "Linux $(. /etc/os-release && echo "$PRETTY_NAME"), Xvfb with Mesa llvmpipe (software OpenGL)")."
    echo
    echo "| | Legacy | Redemption |"
    echo "|---|---|---|"
    echo "| Login smoke | $legacy | $redemption |"
    for key in launch_to_game_ms memory_kb fps texture_errors lua_errors error_lines; do
        echo "| $key | $(value legacy $key) | $(value redemption $key) |"
    done
    echo
    echo "Screenshots: legacy.png and redemption.png (in the game at the login position, map loaded)."
    echo "FPS under software OpenGL measures the CPU renderer, not a real GPU."
} > "$OUT/summary.md"
cat "$OUT/summary.md"
exit $status
