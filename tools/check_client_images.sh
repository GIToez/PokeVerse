#!/usr/bin/env bash
# Print every image of the Redemption client source (client-redemption data/, modules/, mods/,
# without the upstream bot) that is missing from a staged or packaged client folder, or that is
# not a real PNG there (a Git LFS pointer, a truncated or empty file). Prints nothing when the
# client folder has every image. Exit code 2 when the source tree is not available.
# Usage: tools/check_client_images.sh <client-dir>
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SRC="$ROOT/client-redemption"
CLIENT="${1:?usage: $0 <client-dir>}"
[ -d "$SRC/data/images" ] || { echo "no client source at $SRC" >&2; exit 2; }

(cd "$SRC" && find data modules mods -type f -name '*.png' ! -path 'mods/game_bot/*') | while IFS= read -r f; do
    [ -f "$CLIENT/$f" ] || echo "missing $f"
done
(cd "$CLIENT" && find . -type f -name '*.png' -print0) | (cd "$CLIENT" && perl -0ne '
    chomp; s{^\./}{};
    open my $fh, "<:raw", $_ or do { print "unreadable $_\n"; next };
    read $fh, my $head, 8;
    print "not a PNG $_\n" if $head ne "\x89PNG\r\n\x1a\n";')
