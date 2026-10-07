#!/usr/bin/env bash
# Re-download and extract the original PokeJornadas package into .downloads/ and _import/.
# Nothing from the package is executed; it is only downloaded, verified and unpacked.
#
# Requirements: curl, unrar (RARLAB unrar 5+, needed for the RAR5 "pokeaventuras (1).sql" entry), 7z.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
DL="$ROOT/.downloads"
STAGE="$ROOT/_import"
ARCHIVE="$DL/pokejornadas_src.rar"
PASSWORD='naoetrote1234567890@'
SHA256='238dce875523c59bb4e065b8ea7a140bbaedd7dd84e5f74e7d4e585e5bd5bc06'
MEDIAFIRE_PAGE='https://www.mediafire.com/file/d89t3ol1beq8129/poke+jornadas+completo+++src.rar/file'
MEGA_MIRROR='https://mega.nz/file/6dIwRaxT#y2nRFVckLLTLFSBRRtEUJVb-KBAwVPfMhqxyTEEv4Cs'

mkdir -p "$DL" "$STAGE/archive" "$STAGE/extracted"

if [ ! -f "$ARCHIVE" ]; then
  page="$(curl -fsSL -A 'Mozilla/5.0' "$MEDIAFIRE_PAGE")"
  url="$(printf '%s' "$page" | grep -oE 'href="https?://download[^"]+"' | head -1 | sed 's/^href="//; s/"$//')"
  if [ -z "$url" ]; then
    echo "Could not resolve the MediaFire download URL. Download manually from: $MEGA_MIRROR" >&2
    exit 1
  fi
  curl -fL -A 'Mozilla/5.0' "$url" -o "$ARCHIVE"
fi

echo "$SHA256  $ARCHIVE" | sha256sum -c -

unrar x -p"$PASSWORD" -o+ "$ARCHIVE" "$STAGE/archive/"
for z in "$STAGE"/archive/*.zip; do
  name="$(basename "$z" .zip)"
  7z x -p"$PASSWORD" -y -o"$STAGE/extracted/$name" "$z" >/dev/null
done
cp "$STAGE/archive/pokeaventuras (1).sql" "$STAGE/extracted/"

echo "Extracted to $STAGE/extracted. Verify against original/MANIFEST.sha256.tsv"
