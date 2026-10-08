#!/usr/bin/env bash
# Stop the pokeverse-server started from this folder the same way as Ctrl+C in its terminal:
# SIGQUIT makes it save players and the map, then exit. Waits up to two minutes.
set -uo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
SERVER_EXE="$(readlink -f "$HERE/server/pokeverse-server")"
# By executable path: process names are cut to 15 characters, so "pgrep -x pokeverse-server" never matches.
pids=""
for exe in /proc/[0-9]*/exe; do
    [ "$(readlink -f "$exe" 2>/dev/null)" = "$SERVER_EXE" ] || continue
    pid="${exe#/proc/}"; pids="$pids ${pid%/exe}"
done
if [ -z "$pids" ]; then
    echo "No PokeVerse server from $HERE/server is running."
    exit 0
fi
for pid in $pids; do
    echo "Stopping pokeverse-server (process $pid); it saves first."
    kill -QUIT "$pid"
done
for _ in $(seq 1 120); do
    alive=0
    for pid in $pids; do kill -0 "$pid" 2>/dev/null && alive=1; done
    [ "$alive" = 0 ] && { echo "The server saved and stopped."; exit 0; }
    sleep 1
done
echo "ERROR: the server did not stop within 120 s." >&2
exit 1
