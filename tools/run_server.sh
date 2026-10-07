#!/usr/bin/env bash
# Run the source-built server against server/runtime-data (config.lua, data/, map).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BIN="$ROOT/dist/server/pokeverse-server"
[ -x "$BIN" ] || { echo "Missing $BIN; run tools/build_server.sh first" >&2; exit 1; }
cd "$ROOT/server/runtime-data"
exec "$BIN" "$@"
