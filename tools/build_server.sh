#!/usr/bin/env bash
# Build the server from server/source into build/server and stage a runnable copy in dist/server.
# Linux: GCC (docs/BUILD_SERVER_LINUX.md). Windows: MSYS2 UCRT64 shell (docs/BUILD_SERVER_WINDOWS.md);
# the MinGW runtime DLLs the server needs are copied next to pokeverse-server.exe.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BUILD="$ROOT/build/server"
DIST="$ROOT/dist/server"
EXE=""
case "$(uname -s)" in MINGW*|MSYS*) EXE=".exe" ;; esac

GENERATOR=()
[ -n "$EXE" ] && [ ! -f "$BUILD/CMakeCache.txt" ] && GENERATOR=(-G Ninja)
CC=gcc CXX=g++ cmake -S "$ROOT/server/source" -B "$BUILD" "${GENERATOR[@]}" \
    -DCMAKE_BUILD_TYPE="${BUILD_TYPE:-RelWithDebInfo}"
cmake --build "$BUILD" -j"$(nproc)"

mkdir -p "$DIST"
install -m 0755 "$BUILD/pokeverse-server$EXE" "$DIST/pokeverse-server$EXE"
if [ -n "$EXE" ]; then
    prefix="${MINGW_PREFIX:-/ucrt64}"
    ldd "$DIST/pokeverse-server$EXE" | awk -v p="$prefix/bin/" 'index($3, p) == 1 {print $3}' |
        sort -u | while read -r dll; do install -m 0755 "$dll" "$DIST/"; done
    echo "Runtime DLLs: $(cd "$DIST" && ls *.dll | tr '\n' ' ')"
fi
echo "Built $DIST/pokeverse-server$EXE (run it with tools/run_server.sh)"
