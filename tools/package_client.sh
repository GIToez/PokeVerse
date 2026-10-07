#!/usr/bin/env bash
# Package a production client build as a tarball, after the harness safety guard
# (docs/CLIENT_VARIANTS.md). Packaging fails if anything suggests a harness or test build.
# Usage: tools/package_client.sh [dist-dir] [output.tar.gz]
#   dist-dir defaults to dist/client (legacy client); the Redemption client stages
#   into dist/client-redemption.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DIST="${1:-$ROOT/dist/client}"
OUT="${2:-$ROOT/dist/packages/$(basename "$DIST").tar.gz}"

fail() { echo "PACKAGING REFUSED: $*" >&2; exit 1; }

[ "${VARIANT:-production}" = production ] || fail "VARIANT=$VARIANT is set"
[ -z "${BOT_PROTECTION_DISABLED:-}" ] || fail "BOT_PROTECTION_DISABLED is set"
[ -z "${TEST_AUTOMATION_ENABLED:-}" ] || fail "TEST_AUTOMATION_ENABLED is set"
[ -d "$DIST" ] || fail "$DIST does not exist"
[ "$(cat "$DIST/VARIANT" 2>/dev/null)" = production ] ||
    fail "$DIST/VARIANT is '$(cat "$DIST/VARIANT" 2>/dev/null || echo missing)', expected production"

shopt -s nullglob
exes=("$DIST"/pokeverse-client*)
[ ${#exes[@]} -gt 0 ] || fail "no pokeverse-client executable in $DIST"
for exe in "${exes[@]}"; do
    case "$(basename "$exe")" in *harness*|*debug*) fail "$(basename "$exe") is not a production executable" ;; esac
done
for bin in "${exes[@]}" "$DIST"/*.so*; do
    grep -aq "HARNESS - NOT FOR DISTRIBUTION\|HARNESS BUILD" "$bin" && fail "$(basename "$bin") contains harness markers"
done
if find -L "$DIST" -path '*pv_harness*' -print -quit | grep -q .; then
    fail "test harness module found in $DIST"
fi
if find -L "$DIST" -type d -name game_bot -print -quit | grep -q .; then
    fail "bot module (game_bot) found in $DIST"
fi

mkdir -p "$(dirname "$OUT")"
tar -C "$(dirname "$DIST")" -czhf "$OUT" --exclude='*.log' "$(basename "$DIST")"
echo "Packaged $OUT"
