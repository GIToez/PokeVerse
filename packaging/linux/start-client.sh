#!/usr/bin/env bash
# Start the PokeVerse Redemption client (client/pokeverse-client). It connects to the local
# development server at 127.0.0.1 (login port 7564) without any editing.
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
cd "$HERE/client" || { echo "ERROR: no client folder next to this script. Extract the whole package again." >&2; exit 3; }

missing=()
for f in pokeverse-client VARIANT init.lua modules/client/client.otmod data/things/854/Tibia.dat data/things/854/Tibia.spr; do
    [ -e "$f" ] || missing+=("$f")
done
if [ ${#missing[@]} -gt 0 ]; then
    echo "ERROR: the client folder is incomplete. Missing: ${missing[*]}" >&2
    echo "Extract the whole PokeVerse package again." >&2
    exit 3
fi
[ -x pokeverse-client ] || { echo "ERROR: client/pokeverse-client is not executable. Extract the .tar.gz with tar, not a tool that drops permissions." >&2; exit 3; }
if [ "$(head -c 7 data/things/854/Tibia.spr)" = version ] || [ "$(stat -c %s data/things/854/Tibia.spr)" -lt 1000000 ]; then
    echo "ERROR: client/data/things/854/Tibia.spr is a Git LFS placeholder, not the sprite file." >&2
    exit 3
fi
if [ -z "${DISPLAY:-}" ] && [ -z "${WAYLAND_DISPLAY:-}" ]; then
    echo "ERROR: no graphical session (DISPLAY is not set). Start the client from a desktop session." >&2
    exit 3
fi

echo "Starting pokeverse-client. Log in with the account you created, or player / player"
echo "when the development accounts were installed. The client log is client/pokeverse.log."
[ -d "$HERE/client/lib" ] && export LD_LIBRARY_PATH="$HERE/client/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
exec ./pokeverse-client "$@"
