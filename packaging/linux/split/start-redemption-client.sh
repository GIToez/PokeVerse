#!/usr/bin/env bash
# Start the REDEMPTION PokeVerse client (redemption-client/pokeverse-client), built from
# client-redemption. It connects to 127.0.0.1:7564. Its settings live in its own user folder
# (~/.local/share/pokeverse), separate from the legacy client's ~/.Pokecenter.
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
cd "$HERE/redemption-client" || { echo "ERROR: no redemption-client folder next to this script. Extract the whole package again." >&2; exit 3; }

missing=()
for f in pokeverse-client VARIANT CLIENT init.lua modules/client/client.otmod data/images/background.png \
         data/things/854/Tibia.dat data/things/854/Tibia.spr; do
    [ -e "$f" ] || missing+=("$f")
done
if [ ${#missing[@]} -gt 0 ]; then
    echo "ERROR: the redemption-client folder is incomplete. Missing: ${missing[*]}" >&2
    echo "Extract the whole PokeVerse package again." >&2
    exit 3
fi
[ "$(cat CLIENT)" = redemption ] || { echo "ERROR: redemption-client/CLIENT is '$(cat CLIENT)', not 'redemption'." >&2; exit 3; }
[ "$(cat VARIANT)" = production ] || { echo "ERROR: redemption-client/VARIANT is '$(cat VARIANT)'; only production builds are started." >&2; exit 3; }
[ -x pokeverse-client ] || { echo "ERROR: redemption-client/pokeverse-client is not executable. Extract the .tar.gz with tar, not a tool that drops permissions." >&2; exit 3; }
if [ "$(head -c 7 data/things/854/Tibia.spr)" = version ] || [ "$(stat -c %s data/things/854/Tibia.spr)" -lt 1000000 ]; then
    echo "ERROR: redemption-client/data/things/854/Tibia.spr is a Git LFS placeholder, not the sprite file." >&2
    exit 3
fi
if [ -z "${DISPLAY:-}" ] && [ -z "${WAYLAND_DISPLAY:-}" ]; then
    echo "ERROR: no graphical session (DISPLAY is not set). Start the client from a desktop session." >&2
    exit 3
fi

echo "Starting the REDEMPTION client. Log in with your account, or player / player when the"
echo "development accounts were installed. The client log is redemption-client/pokeverse.log."
exec ./pokeverse-client "$@"
