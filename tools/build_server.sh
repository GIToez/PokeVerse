#!/usr/bin/env bash
# Build the server from server/source into build/server and stage a runnable copy in dist/server.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BUILD="$ROOT/build/server"
DIST="$ROOT/dist/server"

CC=gcc CXX=g++ cmake -S "$ROOT/server/source" -B "$BUILD" -DCMAKE_BUILD_TYPE="${BUILD_TYPE:-RelWithDebInfo}"
cmake --build "$BUILD" -j"$(nproc)"

mkdir -p "$DIST"
install -m 0755 "$BUILD/pokeverse-server" "$DIST/pokeverse-server"
echo "Built $DIST/pokeverse-server (run it with tools/run_server.sh)"
