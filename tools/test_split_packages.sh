#!/usr/bin/env bash
# End-to-end test of the separate packages (tools/package_split.sh) as a tester uses them, outside
# the repository in a folder whose path has spaces:
#   Linux    the three .tar.gz extracted side by side (server, Redemption, legacy)
#   Windows  PokeVerse-Client-Comparison-Windows (its parts are identical to the separate
#            packages, tools/validate_split_packages.sh checks that)
# 1. database setup with the package's own script (fresh, then again)
# 2. "Start Both Clients" refuses while no server runs (Windows)
# 3. the server started with the package's start script
# 4. each client launcher, unmodified, starts exactly its packaged executable from that folder
# 5. both clients, one after the other, log the same character into that one server, enter the
#    game and leave again (tools/compare_clients.sh: screenshots at the same window size,
#    launch-to-game time, memory, FPS, error counts into <log-dir>/comparison)
# 6. the server stopped with the package's stop script: it saves and exits
# Windows runners have no GPU: step 5 runs throwaway copies with MESA_DIR; step 4 needs none.
# Needs MariaDB (POKEVERSE_DB_ADMIN_USER/PASSWORD, or sudo mariadb on Linux), an X display on
# Linux, and no server on port 7564.
# Usage: tools/test_split_packages.sh <windows|linux> <packages-dir> [log-dir]
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OS="${1:?usage: $0 <windows|linux> <packages-dir> [log-dir]}"
SRC="$(cd "${2:?packages dir}" && pwd)"
LOGDIR="$(mkdir -p "${3:-/tmp/split-package-test}" && cd "${3:-/tmp/split-package-test}" && pwd)"
export POKEVERSE_NO_PAUSE=1 POKEVERSE_NONINTERACTIVE=1
fail() { echo "FAIL: $*" >&2; exit 1; }
pass() { echo "PASS: $*"; }
port_open() { (exec 3<>"/dev/tcp/127.0.0.1/$1") 2>/dev/null; }
port_open 7564 && fail "a server already listens on 7564; stop it first"

if [ "$OS" = windows ]; then
    BASE="${SPLIT_TEST_DIR:-/c/PokeVerse Comparison Test}"
    rm -rf "$BASE"; mkdir -p "$BASE"
    cp -a "$SRC/PokeVerse-Client-Comparison-Windows/." "$BASE/"
    SERVER_DIR="$BASE"; LEGACY_DIR="$BASE"; REDEMPTION_DIR="$BASE"
    bat() { # <dir> <bat file> [args]: runs a package .bat file like a double click (cmd.exe in that folder)
        local dir="$1" file="$2"; shift 2
        (cd "$dir" && env MSYS2_ARG_CONV_EXCL='*' cmd.exe /d /c "$file" "$@")
    }
    exe_running() { # <image name> <folder>: a process of that image runs from exactly that folder
        local win; win=$(cygpath -w "$2")
        powershell -NoProfile -Command "\$p = Get-Process -Name '${1%.exe}' -ErrorAction SilentlyContinue | Where-Object { \$_.Path -eq '$win\\$1' }; if (\$p) { exit 0 } else { exit 1 }"
    }
    # Polls: without a GPU a client may stop at its OpenGL check; the launcher test only needs
    # to see that exactly this executable was started from this folder.
    wait_running() { for _ in $(seq 1 20); do exe_running "$@" && return 0; sleep 1; done; return 1; }
else
    BASE="$(mktemp -d /tmp/pokeverse-split.XXXXXX)/PokeVerse Split Test"
    mkdir -p "$BASE"
    for name in Server Redemption Legacy; do
        tar -C "$BASE" -xzf "$SRC/PokeVerse-$name-Linux.tar.gz" || fail "cannot extract PokeVerse-$name-Linux.tar.gz"
    done
    SERVER_DIR="$BASE/PokeVerse-Server-Linux"; LEGACY_DIR="$BASE/PokeVerse-Legacy-Linux"; REDEMPTION_DIR="$BASE/PokeVerse-Redemption-Linux"
    export POKEVERSE_DB_NAME="${POKEVERSE_DB_NAME:-pokeverse_splittest}"
    [ "$POKEVERSE_DB_NAME" != pokeverse ] || fail "use a separate test database (POKEVERSE_DB_NAME)"
fi
server=""
cleanup() {
    if [ "$OS" = windows ]; then
        taskkill //F //IM pokeverse-legacy-client.exe > /dev/null 2>&1; taskkill //F //IM pokeverse-client.exe > /dev/null 2>&1
        [ -n "$server" ] && taskkill //F //IM pokeverse-server.exe > /dev/null 2>&1
    else
        pkill -f "$BASE/.*/pokeverse-legacy-client" 2>/dev/null; pkill -f "$BASE/.*/pokeverse-client" 2>/dev/null
        [ -n "$server" ] && kill -TERM "$server" 2>/dev/null && sleep 10
        pkill -9 -f "$SERVER_DIR/server/pokeverse-server" 2>/dev/null
    fi
    true
}
trap cleanup EXIT
pass "packages placed in '$BASE'"

# 1. Database
if [ "$OS" = windows ]; then
    bat "$SERVER_DIR" "Setup Database.bat" > "$LOGDIR/setup-1.log" 2>&1 || { cat "$LOGDIR/setup-1.log"; fail "Setup Database.bat failed"; }
    bat "$SERVER_DIR" "Setup Database.bat" > "$LOGDIR/setup-2.log" 2>&1 || { cat "$LOGDIR/setup-2.log"; fail "Setup Database.bat failed on the second run"; }
else
    (cd "$SERVER_DIR" && ./setup-database.sh) > "$LOGDIR/setup-1.log" 2>&1 || { cat "$LOGDIR/setup-1.log"; fail "setup-database.sh failed"; }
    (cd "$SERVER_DIR" && ./setup-database.sh) > "$LOGDIR/setup-2.log" 2>&1 || { cat "$LOGDIR/setup-2.log"; fail "setup-database.sh failed on the second run"; }
fi
grep -q "Database setup: SUCCESS" "$LOGDIR/setup-2.log" || fail "database setup did not report SUCCESS"
pass "database setup (fresh, then again)"

# 2. Start Both Clients never starts a server
if [ "$OS" = windows ]; then
    bat "$BASE" "Start Both Clients.bat" > "$LOGDIR/both-without-server.log" 2>&1; code=$?
    [ "$code" = 6 ] || { cat "$LOGDIR/both-without-server.log"; fail "Start Both Clients.bat without a server: exit code $code, expected 6"; }
    tasklist | grep -qi "pokeverse-server.exe" && fail "Start Both Clients.bat started a server"
    tasklist | grep -qiE "pokeverse-(legacy-)?client.exe" && fail "Start Both Clients.bat started a client without a server"
    pass "Start Both Clients.bat refuses without a server and starts none"
fi

# 3. Server
if [ "$OS" = windows ]; then
    (cd "$SERVER_DIR" && env MSYS2_ARG_CONV_EXCL='*' cmd.exe /d /c start "PokeVerse Server" cmd.exe /d /c "Start Server.bat") || fail "could not start Start Server.bat"
    server=started
else
    (cd "$SERVER_DIR" && exec ./start-server.sh) > "$LOGDIR/server.log" 2>&1 &
    server=$!
fi
for _ in $(seq 1 300); do port_open 7564 && port_open 8548 && break; sleep 1; done
port_open 7564 && port_open 8548 || { tail -30 "$LOGDIR/server.log" 2>/dev/null; fail "the server did not open ports 7564 and 8548 within 300 s"; }
sleep 3
pass "server started with the package's start script"
if [ "$OS" = windows ]; then
    (cd "$SERVER_DIR" && timeout 120 env MSYS2_ARG_CONV_EXCL='*' cmd.exe /d /c "Start Server.bat") > "$LOGDIR/second-server.log" 2>&1 &&
        fail "a second Start Server.bat did not refuse"
    [ "$(tasklist | grep -ci pokeverse-server.exe)" = 1 ] || fail "more than one pokeverse-server.exe runs"
    pass "a second Start Server.bat refuses; one server runs"
else
    (cd "$SERVER_DIR" && timeout 120 ./start-server.sh) > "$LOGDIR/second-server.log" 2>&1
    code=$?
    [ "$code" = 4 ] || { pkill -9 -f "$SERVER_DIR/server/pokeverse-server"; fail "a second start-server.sh did not refuse (exit code $code, expected 4)"; }
    pass "a second start-server.sh refuses; one server runs"
fi

# 4. Launchers start exactly the packaged executables
if [ "$OS" = windows ]; then
    bat "$BASE" "Start Both Clients.bat" > "$LOGDIR/both.log" 2>&1 || { cat "$LOGDIR/both.log"; fail "Start Both Clients.bat failed with a running server"; }
    wait_running pokeverse-legacy-client.exe "$LEGACY_DIR/legacy-client" || fail "Start Both Clients.bat: legacy-client\\pokeverse-legacy-client.exe is not running"
    wait_running pokeverse-client.exe "$REDEMPTION_DIR/redemption-client" || fail "Start Both Clients.bat: redemption-client\\pokeverse-client.exe is not running"
    powershell -NoProfile -Command "Get-Process -Name pokeverse-* | Format-Table Id, Path -AutoSize" | tee "$LOGDIR/launched.txt"
    taskkill //F //IM pokeverse-legacy-client.exe > /dev/null 2>&1; taskkill //F //IM pokeverse-client.exe > /dev/null 2>&1
    sleep 3
    pass "Start Both Clients.bat starts legacy-client\\pokeverse-legacy-client.exe and redemption-client\\pokeverse-client.exe"
    for which in Legacy Redemption; do
        bat "$BASE" "Start $which Client.bat" > "$LOGDIR/start-$which.log" 2>&1 || { cat "$LOGDIR/start-$which.log"; fail "Start $which Client.bat failed"; }
        if [ "$which" = Legacy ]; then wait_running pokeverse-legacy-client.exe "$LEGACY_DIR/legacy-client" || fail "Start Legacy Client.bat did not start the legacy client"
        else wait_running pokeverse-client.exe "$REDEMPTION_DIR/redemption-client" || fail "Start Redemption Client.bat did not start the Redemption client"; fi
        taskkill //F //IM pokeverse-legacy-client.exe > /dev/null 2>&1; taskkill //F //IM pokeverse-client.exe > /dev/null 2>&1
        sleep 3
        pass "Start $which Client.bat starts its own client"
    done
else
    for which in legacy redemption; do
        dir="$LEGACY_DIR"; exe=pokeverse-legacy-client
        [ "$which" = redemption ] && { dir="$REDEMPTION_DIR"; exe=pokeverse-client; }
        (cd "$dir" && exec "./start-$which-client.sh") > "$LOGDIR/start-$which.log" 2>&1 &
        pid=$!
        sleep 15
        kill -0 "$pid" 2>/dev/null || { cat "$LOGDIR/start-$which.log"; fail "start-$which-client.sh exited within 15 s"; }
        [ "$(readlink -f "/proc/$pid/exe")" = "$(readlink -f "$dir/$which-client/$exe")" ] ||
            fail "start-$which-client.sh runs $(readlink -f "/proc/$pid/exe"), not $dir/$which-client/$exe"
        kill -9 "$pid"; wait "$pid" 2>/dev/null
        pass "start-$which-client.sh runs $which-client/$exe"
    done
fi

# 5. Both clients against this one server, same character, same window size
SERVER_LOG_ARG=""
[ "$OS" = linux ] && SERVER_LOG_ARG="$LOGDIR/server.log"
REDEMPTION_DIR="$REDEMPTION_DIR/redemption-client" LEGACY_DIR="$LEGACY_DIR/legacy-client" \
    "$ROOT/tools/compare_clients.sh" "$LOGDIR/comparison" $SERVER_LOG_ARG || fail "client comparison run failed (see $LOGDIR/comparison)"
pass "legacy and Redemption client in game on the same server (comparison in $LOGDIR/comparison)"

# 6. Stop
if [ "$OS" = windows ]; then
    bat "$SERVER_DIR" "Stop Server.bat" > "$LOGDIR/stop.log" 2>&1 || { cat "$LOGDIR/stop.log"; fail "Stop Server.bat failed"; }
    for _ in $(seq 1 60); do tasklist | grep -qi pokeverse-server.exe || break; sleep 1; done
    tasklist | grep -qi pokeverse-server.exe && fail "the server still runs after Stop Server.bat"
    server=""
    cp -r "$SERVER_DIR/server/logs" "$LOGDIR/server-logs" 2>/dev/null
    pass "Stop Server.bat stopped the server"
else
    (cd "$SERVER_DIR" && ./stop-server.sh) > "$LOGDIR/stop.log" 2>&1 || { cat "$LOGDIR/stop.log"; fail "stop-server.sh failed"; }
    for _ in $(seq 1 30); do kill -0 "$server" 2>/dev/null || break; sleep 1; done
    kill -0 "$server" 2>/dev/null && { cat "$LOGDIR/stop.log"; fail "the server still runs 30 s after stop-server.sh returned"; }
    wait "$server"; status=$?
    server=""
    grep -q "SAVE: Complete" "$LOGDIR/server.log" || fail "no 'SAVE: Complete' after stop-server.sh"
    [ "$status" = 0 ] || fail "start-server.sh exited with $status after stop-server.sh"
    pass "stop-server.sh: the server saved and exited with 0"
fi
echo "Split package test: PASS ($OS)"
