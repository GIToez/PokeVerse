#!/usr/bin/env bash
# Assembles a runnable PokeVerse client on the Redemption engine.
#
#   scripts/assemble-redemption-client.sh [options] <out dir> [binary...]
#
# The tree is the legacy PokeVerse modules and data (core/client-legacy) with the
# Redemption overlay (core/client-redemption/pokeverse) copied on top, plus the given
# binaries (otclient, otclient.exe, DLLs...). Only modules from these two folders ship;
# Redemption's own modules stay out of the package.
#
# Options:
#   --host <address>   point the client at this server instead of 127.0.0.1
#   --port <port>      login port (default 7564; the parity tests use a proxy port)
#   --updater <url>    enable the updater with this manifest URL (live packages only)
#   --link             hard-link the legacy data instead of copying it (local testing)
#   --test             also ship the self-test module (scripts/client-test/client_selftest)
set -euo pipefail

root=$(cd "$(dirname "$0")/.." && pwd)
legacy=$root/core/client-legacy
overlay=$root/core/client-redemption/pokeverse
host=""
port=""
updater=""
link=0
test_module=0

while [ $# -gt 0 ]; do
  case "$1" in
    --host) host=$2; shift 2 ;;
    --port) port=$2; shift 2 ;;
    --updater) updater=$2; shift 2 ;;
    --link) link=1; shift ;;
    --test) test_module=1; shift ;;
    -*) echo "unknown option: $1" >&2; exit 1 ;;
    *) break ;;
  esac
done
[ $# -ge 1 ] || { sed -n '2,17p' "$0" >&2; exit 1; }
out=$(realpath -m "$1")
shift

if [ -n "$host" ]; then
  [[ "$host" =~ ^[A-Za-z0-9]([A-Za-z0-9.-]*[A-Za-z0-9])?$ ]] || { echo "invalid server address: '$host'" >&2; exit 1; }
fi
if [ -n "$port" ]; then
  [[ "$port" =~ ^[0-9]{1,5}$ ]] || { echo "invalid port: '$port'" >&2; exit 1; }
fi
if [ -n "$updater" ]; then
  [[ "$updater" =~ ^(https://[A-Za-z0-9./_-]+|http://(127\.0\.0\.1|localhost)(:[0-9]+)?/[A-Za-z0-9./_-]*)$ ]] || { echo "invalid updater URL: '$updater' (https, or http on localhost for tests)" >&2; exit 1; }
fi

rm -rf "$out"
mkdir -p "$out"

if [ "$link" = 1 ]; then
  cp -al "$legacy/data" "$out/data"
  cp -r "$legacy/modules" "$out/modules"
else
  cp -r "$legacy/data" "$legacy/modules" "$out/"
fi
rm -f "$out/modules/corelib.rar"
cp "$legacy/LICENSE" "$out/"

# overlay: files replace the legacy file at the same path
(cd "$overlay" && find . -type f) | while read -r f; do
  mkdir -p "$out/$(dirname "$f")"
  cp --remove-destination "$overlay/$f" "$out/$f"
done

if [ "$test_module" = 1 ]; then
  cp -r "$root/scripts/client-test/client_selftest" "$out/modules/"
fi

for bin in "$@"; do
  cp "$bin" "$out/"
done

"$root/scripts/set-client-server.sh" "$out" "$host" "$port"

if [ -n "$updater" ]; then
  sed -i "s#^  updater = \"\",#  updater = \"$updater\",#" "$out/init.lua"
  grep -q "^  updater = \"$updater\"," "$out/init.lua" || { echo "could not set the updater URL in init.lua" >&2; exit 1; }
else
  rm -rf "$out/modules/updater"
fi

echo "Redemption client ready: $out${host:+ (server $host)}${port:+ (port $port)}${updater:+ (updater $updater)}"
