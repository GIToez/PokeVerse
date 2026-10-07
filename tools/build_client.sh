#!/usr/bin/env bash
# Build the client from client/source into build/client and stage a runnable copy in dist/client.
# dist/client links data/, modules/ and init.lua from client/runtime-data (COPY_DATA=1 copies instead).
# VARIANT=harness builds build/client-harness -> dist/client-harness with BOT_PROTECTION off,
# so tools/runtime_test.sh can drive game actions from Lua. Never ship that variant.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DATA="$ROOT/client/runtime-data"
EXTRA=()
if [ "${VARIANT:-}" = harness ]; then
    BUILD="$ROOT/build/client-harness"
    DIST="$ROOT/dist/client-harness"
    EXTRA+=(-DBOT_PROTECTION=OFF)
else
    BUILD="$ROOT/build/client"
    DIST="$ROOT/dist/client"
fi

CC=gcc CXX=g++ cmake -S "$ROOT/client/source" -B "$BUILD" -Wno-dev \
    -DCMAKE_BUILD_TYPE="${BUILD_TYPE:-RelWithDebInfo}" \
    -DLUAJIT=OFF -DUSE_STATIC_LIBS=OFF \
    -DCMAKE_BUILD_WITH_INSTALL_RPATH=ON -DCMAKE_INSTALL_RPATH='$ORIGIN' "${EXTRA[@]}"
cmake --build "$BUILD" -j"$(nproc)"

mkdir -p "$DIST"
install -m 0755 "$BUILD/otclient" "$DIST/pokeverse-client"
install -m 0644 "$BUILD/libotc_framework.so" "$DIST/libotc_framework.so"
for entry in data modules init.lua; do
    rm -rf "${DIST:?}/$entry"
    if [ "${COPY_DATA:-0}" = 1 ]; then
        cp -a "$DATA/$entry" "$DIST/$entry"
    else
        ln -s "$DATA/$entry" "$DIST/$entry"
    fi
done
echo "Built $DIST/pokeverse-client (run it from $DIST)"
