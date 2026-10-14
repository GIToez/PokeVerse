#!/usr/bin/env bash
# Points an assembled client tree at a server: set-client-server.sh <tree> <host|""> [port]
# Empty values keep the defaults (127.0.0.1, 7564). Used by the client assemblers.
# The Redemption layout keeps the server in init.lua (Servers_init), the classic layout in
# modules/client_entergame/entergame.lua.
set -euo pipefail

tree=$1
host=${2:-}
port=${3:-}

entergame=$tree/modules/client_entergame/entergame.lua
if grep -q "^local SERVER_HOST = " "$entergame" 2>/dev/null; then
  if [ -n "$host" ]; then
    sed -i "s/^local SERVER_HOST = '127\.0\.0\.1'/local SERVER_HOST = '$host'/" "$entergame"
    grep -q "^local SERVER_HOST = '$host'$" "$entergame" || { echo "could not set the server address in entergame.lua" >&2; exit 1; }
  fi
  if [ -n "$port" ]; then
    sed -i "s/^local SERVER_PORT = 7564$/local SERVER_PORT = $port/" "$entergame"
    grep -q "^local SERVER_PORT = $port$" "$entergame" || { echo "could not set the server port in entergame.lua" >&2; exit 1; }
  fi
  exit 0
fi

init=$tree/init.lua
line='^  \["127\.0\.0\.1"\] = { port = 7564, '
grep -q "$line" "$init" || { echo "no Servers_init entry for 127.0.0.1:7564 in init.lua" >&2; exit 1; }
sed -i "s/$line/  [\"${host:-127.0.0.1}\"] = { port = ${port:-7564}, /" "$init"
grep -qF "  [\"${host:-127.0.0.1}\"] = { port = ${port:-7564}, " "$init" || { echo "could not set the server in init.lua" >&2; exit 1; }
