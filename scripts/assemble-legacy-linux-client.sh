#!/usr/bin/env bash
# Assembles a runnable legacy PokeVerse client (the fallback engine) for Linux.
#
#   scripts/assemble-legacy-linux-client.sh [options] <out dir> <build dir>
#
# <build dir> is a CMake build of core/client-legacy (pokeverse-client and
# libotc_framework.so). The tree is core/client-legacy's init.lua, data and modules
# plus the binaries and a pokeverse.sh launcher.
#
# Options:
#   --host <address>   point the client at this server instead of 127.0.0.1
#   --port <port>      login port (default 7564; the parity tests use a proxy port)
#   --link             hard-link the data instead of copying it (local testing)
#   --test             also ship the self-test module (scripts/client-test/client_selftest)
set -euo pipefail

root=$(cd "$(dirname "$0")/.." && pwd)
legacy=$root/core/client-legacy
host=""
port=""
link=0
test_module=0

while [ $# -gt 0 ]; do
  case "$1" in
    --host) host=$2; shift 2 ;;
    --port) port=$2; shift 2 ;;
    --link) link=1; shift ;;
    --test) test_module=1; shift ;;
    -*) echo "unknown option: $1" >&2; exit 1 ;;
    *) break ;;
  esac
done
[ $# -eq 2 ] || { sed -n '2,15p' "$0" >&2; exit 1; }
out=$(realpath -m "$1")
build=$(realpath "$2")

if [ -n "$host" ]; then
  [[ "$host" =~ ^[A-Za-z0-9]([A-Za-z0-9.-]*[A-Za-z0-9])?$ ]] || { echo "invalid server address: '$host'" >&2; exit 1; }
fi
if [ -n "$port" ]; then
  [[ "$port" =~ ^[0-9]{1,5}$ ]] || { echo "invalid port: '$port'" >&2; exit 1; }
fi
for f in pokeverse-client libotc_framework.so; do
  [ -f "$build/$f" ] || { echo "missing $build/$f" >&2; exit 1; }
done

rm -rf "$out"
mkdir -p "$out"

if [ "$link" = 1 ]; then
  cp -al "$legacy/data" "$out/data"
else
  cp -r "$legacy/data" "$out/"
fi
cp -r "$legacy/modules" "$out/"
rm -f "$out/modules/corelib.rar"
cp "$legacy/init.lua" "$legacy/LICENSE" "$out/"
cp "$build/pokeverse-client" "$build/libotc_framework.so" "$out/"

cat > "$out/pokeverse.sh" <<'EOF'
#!/bin/sh
# Starts the legacy PokeVerse client. Settings and logs go to ~/.pokeverse.
cd "$(dirname "$0")" || exit 1
LD_LIBRARY_PATH="$PWD${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}" exec ./pokeverse-client "$@"
EOF
chmod +x "$out/pokeverse.sh"

if [ "$test_module" = 1 ]; then
  cp -r "$root/scripts/client-test/client_selftest" "$out/modules/"
fi

"$root/scripts/set-client-server.sh" "$out" "$host" "$port"

echo "Legacy client ready: $out${host:+ (server $host)}${port:+ (port $port)}"
