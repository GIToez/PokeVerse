#!/usr/bin/env bash
# Stage a runnable Redemption client from build/client-redemption/<type>/bin plus the
# client-redemption runtime files (data, modules, mods, init.lua, ...).
#   release -> dist/client-redemption        (VARIANT=production, packageable)
#   debug   -> dist/client-redemption-debug  (VARIANT=debug, refused by tools/package_client.sh)
# Usage: tools/stage_redemption.sh [release|debug]
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TYPE="${1:-release}"
SRC="$ROOT/client-redemption"
BIN="$ROOT/build/client-redemption/$TYPE/bin"
case "$TYPE" in
    release) DIST="$ROOT/dist/client-redemption"; VARIANT=production; NAME=pokeverse-client ;;
    debug) DIST="$ROOT/dist/client-redemption-debug"; VARIANT=debug; NAME=pokeverse-client-debug ;;
    *) echo "usage: $0 [release|debug]" >&2; exit 2 ;;
esac
EXE=$(cd "$BIN" 2>/dev/null && ls otclient otclient.exe 2>/dev/null | head -1 || true)
[ -n "$EXE" ] || { echo "no otclient executable in $BIN; run tools/build_redemption.sh $TYPE" >&2; exit 1; }

rm -rf "$DIST"
mkdir -p "$DIST"
cp "$BIN/$EXE" "$DIST/$NAME${EXE#otclient}"
# Windows builds with dynamic vcpkg triplets place their DLLs next to the executable.
find "$BIN" -maxdepth 1 -name '*.dll' -exec cp {} "$DIST/" \;
for entry in data modules mods init.lua otclientrc.lua config.ini cacert.pem LICENSE AUTHORS; do
    if [ -e "$SRC/$entry" ]; then cp -a "$SRC/$entry" "$DIST/$entry"; fi
done
# Upstream ships a bot (vBot); PokeVerse builds must not.
rm -rf "$DIST/mods/game_bot"
sed -i '/^ *- game_bot *$/d' "$DIST/mods/client_mods/mods.otmod"
echo "$VARIANT" > "$DIST/VARIANT"
echo "Staged $DIST/$NAME${EXE#otclient} ($VARIANT)"
