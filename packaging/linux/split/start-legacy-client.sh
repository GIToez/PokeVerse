#!/usr/bin/env bash
# Start the LEGACY PokeVerse client (legacy-client/pokeverse-legacy-client): the original
# PokeJornadas/PokeVerse interface, compiled from client/source. It connects to 127.0.0.1:7564.
# Its settings live in ~/.Pokecenter, its log in ~/Pokecenter.log (the Redemption client uses others).
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
cd "$HERE/legacy-client" || { echo "ERROR: no legacy-client folder next to this script. Extract the whole package again." >&2; exit 3; }

missing=()
for f in pokeverse-legacy-client libotc_framework.so VARIANT CLIENT init.lua modules/client/client.otmod \
         modules/game_pokebar/pokebar.otmod data/things/Tibia.dat data/things/Tibia.spr; do
    [ -e "$f" ] || missing+=("$f")
done
if [ ${#missing[@]} -gt 0 ]; then
    echo "ERROR: the legacy-client folder is incomplete. Missing: ${missing[*]}" >&2
    echo "Extract the whole PokeVerse package again." >&2
    exit 3
fi
[ "$(cat CLIENT)" = legacy ] || { echo "ERROR: legacy-client/CLIENT is '$(cat CLIENT)', not 'legacy'." >&2; exit 3; }
[ "$(cat VARIANT)" = production ] || { echo "ERROR: legacy-client/VARIANT is '$(cat VARIANT)'; only production builds are started." >&2; exit 3; }
[ -x pokeverse-legacy-client ] || { echo "ERROR: legacy-client/pokeverse-legacy-client is not executable. Extract the .tar.gz with tar, not a tool that drops permissions." >&2; exit 3; }
if [ "$(head -c 7 data/things/Tibia.spr)" = version ] || [ "$(stat -c %s data/things/Tibia.spr)" -lt 1000000 ]; then
    echo "ERROR: legacy-client/data/things/Tibia.spr is a Git LFS placeholder, not the sprite file." >&2
    exit 3
fi
if [ -z "${DISPLAY:-}" ]; then
    echo "ERROR: no X11 session (DISPLAY is not set). Start the client from a desktop session (XWayland works)." >&2
    exit 3
fi

echo "Starting the LEGACY client. Log in with your account, or player / player when the"
echo "development accounts were installed. The client log is ~/Pokecenter.log."
export LD_LIBRARY_PATH="$HERE/legacy-client/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
exec ./pokeverse-legacy-client "$@"
