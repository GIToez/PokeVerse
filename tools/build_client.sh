#!/usr/bin/env bash
# Build the legacy client from client/source and stage a runnable copy.
# dist/<variant> links data/, modules/ and init.lua from client/runtime-data (COPY_DATA=1 copies instead).
#
# VARIANT (docs/CLIENT_VARIANTS.md):
#   production (default)  build/client         -> dist/client/pokeverse-client
#   debug                 build/client-debug   -> dist/client-debug/pokeverse-client-debug
#   harness               build/client-harness -> dist/client-harness/pokeverse-client-harness
# The harness variant has bot protection off so tools/runtime_test.sh can drive game actions
# from Lua. It is marked as such at runtime and must never be shipped.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DATA="$ROOT/client/runtime-data"
VARIANT="${VARIANT:-production}"
case "$VARIANT" in
    production) SUFFIX=""; TYPE="${BUILD_TYPE:-RelWithDebInfo}"; BOT=ON ;;
    debug) SUFFIX="-debug"; TYPE="${BUILD_TYPE:-Debug}"; BOT=ON ;;
    harness) SUFFIX="-harness"; TYPE="${BUILD_TYPE:-RelWithDebInfo}"; BOT=OFF ;;
    *) echo "VARIANT must be production, debug or harness" >&2; exit 2 ;;
esac
BUILD="$ROOT/build/client$SUFFIX"
DIST="$ROOT/dist/client$SUFFIX"
EXE="pokeverse-client$SUFFIX"

CC=gcc CXX=g++ cmake -S "$ROOT/client/source" -B "$BUILD" -Wno-dev \
    -DCMAKE_BUILD_TYPE="$TYPE" -DBUILD_VARIANT="$VARIANT" -DBOT_PROTECTION="$BOT" \
    -DLUAJIT=OFF -DUSE_STATIC_LIBS=OFF \
    -DCMAKE_BUILD_WITH_INSTALL_RPATH=ON -DCMAKE_INSTALL_RPATH='$ORIGIN'
cmake --build "$BUILD" -j"$(nproc)"

mkdir -p "$DIST"
rm -f "$DIST"/pokeverse-client*
install -m 0755 "$BUILD/otclient" "$DIST/$EXE"
install -m 0644 "$BUILD/libotc_framework.so" "$DIST/libotc_framework.so"
echo "$VARIANT" > "$DIST/VARIANT"
for entry in data modules init.lua; do
    rm -rf "${DIST:?}/$entry"
    if [ "${COPY_DATA:-0}" = 1 ]; then
        cp -a "$DATA/$entry" "$DIST/$entry"
    else
        ln -s "$DATA/$entry" "$DIST/$entry"
    fi
done
echo "Built $DIST/$EXE ($VARIANT, $TYPE; run it from $DIST)"
