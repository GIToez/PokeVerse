#!/usr/bin/env bash
# Points an assembled client tree at a server: set-client-server.sh <tree> <host|""> [port]
# Empty values keep the defaults (127.0.0.1, 7564). Used by the client assemblers.
set -euo pipefail

entergame=$1/modules/client_entergame/entergame.lua
host=${2:-}
port=${3:-}

if [ -n "$host" ]; then
  sed -i "s/^local SERVER_HOST = '127\.0\.0\.1'/local SERVER_HOST = '$host'/" "$entergame"
  grep -q "^local SERVER_HOST = '$host'$" "$entergame" || { echo "could not set the server address in entergame.lua" >&2; exit 1; }
fi
if [ -n "$port" ]; then
  sed -i "s/^local SERVER_PORT = 7564$/local SERVER_PORT = $port/" "$entergame"
  grep -q "^local SERVER_PORT = $port$" "$entergame" || { echo "could not set the server port in entergame.lua" >&2; exit 1; }
fi
