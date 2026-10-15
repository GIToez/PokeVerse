#!/usr/bin/env bash
# Renders the Pokepedia's map pictures from the current map, for a preview before a release.
#
#   scripts/render-map.sh [client dir]
#
# Writes build/map-pictures (scripts/mapper/render_pokepedia.py), which the next
# scripts/assemble-redemption-client.sh adds to the client. With a client dir (an assembled
# or installed client), the pictures are also copied into it, so a restart of that client
# shows them. The client release renders the same pictures by itself; this is only for looking
# at map changes early. Needs python3 with Pillow (apt install python3-pil).
set -euo pipefail

root=$(cd "$(dirname "$0")/.." && pwd)
client=${1:-}
if [ -n "$client" ] && [ ! -d "$client/data" ]; then
  echo "not a client folder (no data/ inside): $client" >&2
  exit 1
fi

python3 "$root/scripts/mapper/render_pokepedia.py" --out "$root/build/map-pictures" --jobs "$(nproc 2>/dev/null || echo 4)"

if [ -n "$client" ]; then
  rm -rf "$client/data/images/pokepedia"
  mkdir -p "$client/data/images/pokepedia"
  cp -r "$root/build/map-pictures/." "$client/data/images/pokepedia/"
  echo "copied into $client/data/images/pokepedia; restart the client to see them"
fi
