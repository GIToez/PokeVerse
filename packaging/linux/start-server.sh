#!/usr/bin/env bash
# Start the PokeVerse server (server/pokeverse-server) in this terminal. The server prints
# "server Online!" when it accepts logins. Ctrl+C saves players and the map, then stops it.
# Environment: POKEVERSE_SKIP_DB_CHECK=1 skips the database check before the start.
set -uo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
cd "$HERE/server" || { echo "ERROR: no server folder next to this script. Extract the whole package again." >&2; exit 3; }

missing=()
for f in pokeverse-server config.lua pt_br.loc data/world/map.otbm data/items/items.otb data/XML/vocations.xml; do
    [ -e "$f" ] || missing+=("$f")
done
if [ ${#missing[@]} -gt 0 ]; then
    echo "ERROR: the server folder is incomplete. Missing: ${missing[*]}" >&2
    echo "Extract the whole PokeVerse package again." >&2
    exit 3
fi
[ -x pokeverse-server ] || { echo "ERROR: server/pokeverse-server is not executable. Extract the .tar.gz with tar, not a tool that drops permissions." >&2; exit 3; }

mkdir -p logs/server logs/chat logs/bots logs/talkactions

port_open() { (exec 3<>"/dev/tcp/127.0.0.1/$1") 2>/dev/null; }
# config.lua comes with CRLF line endings; a CR left in the port would make the in-use check pass.
config_value() {
    tr -d '\r' < config.lua | sed -n -E "s/^[[:space:]]*$1[[:space:]]*=[[:space:]]*(\"([^\"]*)\"|([^[:space:]\"]*)).*/\2\3/p" | head -1
}
login_port=$(config_value loginPort); login_port="${login_port:-7564}"
if port_open "$login_port"; then
    echo "ERROR: port $login_port is in use. Is another PokeVerse server already running?" >&2
    exit 4
fi

if [ "${POKEVERSE_SKIP_DB_CHECK:-0}" != 1 ]; then
    client=$(command -v mariadb || command -v mysql || true)
    if [ -z "$client" ]; then
        echo "WARNING: no mariadb client installed; skipping the database check."
    else
        opt=$(mktemp); chmod 600 "$opt"
        printf '[client]\nhost=%s\nport=%s\nuser="%s"\npassword="%s"\n' "$(config_value sqlHost)" \
            "$(config_value sqlPort)" "$(config_value sqlUser)" "$(config_value sqlPass)" > "$opt"
        db=$(config_value sqlDatabase)
        tables=$("$client" "--defaults-extra-file=$opt" --batch --skip-column-names -e \
            "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = '$db' AND table_name IN ('accounts','players');" 2>&1)
        rm -f "$opt"
        if [ "$tables" != 2 ]; then
            echo "ERROR: the database in server/config.lua is not ready (database '$db')." >&2
            [ -n "$tables" ] && [ "$tables" != 0 ] && echo "$tables" >&2
            echo "Run ./setup-database.sh first." >&2
            exit 5
        fi
        echo "Database '$db' is reachable."
    fi
fi

export LD_LIBRARY_PATH="$HERE/server/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
echo "Starting pokeverse-server in $PWD"
echo "Loading takes a while. The server is ready when it prints \"server Online!\"."
echo "Stop it with Ctrl+C or /shutdown as GM Admin in game (both save first)."
echo

# The server saves and shuts down on SIGQUIT. A background child of this script ignores
# SIGINT, so Ctrl+C reaches only the trap below, which asks the server to save and stop.
./pokeverse-server &
server=$!
stopping=0
stop() {
    [ "$stopping" = 1 ] && return
    stopping=1
    echo
    echo "Saving and shutting down the server..."
    kill -QUIT "$server" 2>/dev/null
}
trap stop INT TERM HUP
status=0
while kill -0 "$server" 2>/dev/null; do
    wait "$server"
    status=$?
done
echo
echo "pokeverse-server exited with code $status."
[ "$status" = 0 ] || [ "$stopping" = 1 ] || echo "Read the lines above for the reason, and the files in server/logs."
exit "$status"
