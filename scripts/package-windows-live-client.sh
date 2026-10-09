#!/usr/bin/env bash
# Assembles the PokeVerse live client for Windows (builds/live/client-legacy-windows/).
# Runs in an MSYS2 MINGW64 shell after the client is built.
#
#   scripts/package-windows-live-client.sh <client build dir> <server address> <output dir>
#
# Same client as the development package, but it connects to the live server instead of
# 127.0.0.1. The package is written to <output dir>/PokeVerse-Windows/.
set -euo pipefail

client_build=$(realpath "$1")
host=$2
out=$(realpath -m "$3")/PokeVerse-Windows
root=$(cd "$(dirname "$0")/.." && pwd)

[[ "$host" =~ ^[A-Za-z0-9]([A-Za-z0-9.-]*[A-Za-z0-9])?$ ]] || { echo "invalid server address: '$host'" >&2; exit 1; }
case "$host" in 127.*|localhost) echo "the live client must not point to $host" >&2; exit 1 ;; esac

rm -rf "$out"
mkdir -p "$out"
cp "$client_build/pokeverse-client.exe" "$out/"
if [ -f "$client_build/libotc_framework.dll" ]; then
  cp "$client_build/libotc_framework.dll" "$out/"
fi
ldd "$out"/*.exe "$out"/*.dll 2>/dev/null | awk '{print $3}' | grep -i '^/mingw64/' | sort -u | while read -r dll; do
  cp -n "$dll" "$out/"
done
cp -r "$root/core/client-legacy/data" "$root/core/client-legacy/modules" "$root/core/client-legacy/init.lua" \
      "$root/core/client-legacy/LICENSE" "$out/"

entergame=$out/modules/client_entergame/entergame.lua
sed -i "s/^local SERVER_HOST = '127\.0\.0\.1'/local SERVER_HOST = '$host'/" "$entergame"
grep -q "^local SERVER_HOST = '$host'" "$entergame" || { echo "could not set the server address in entergame.lua" >&2; exit 1; }

cp "$root/scripts/windows-live-client/README.txt" "$out/"
sed -i "s/@SERVER@/$host/g" "$out/README.txt"

echo "Live client ready: $out (server $host)"
du -sh "$out"
