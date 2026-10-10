#!/usr/bin/env bash
# Edits the PokeVerse patch of one Redemption module.
#
#   scripts/redemption-patch.sh edit <module>   # build/redemption-patches/modules/<module>, patch applied
#   scripts/redemption-patch.sh save <module>   # writes core/client-redemption/pokeverse-modern/patches/<module>.patch
#
# The assembler applies every patch in pokeverse-modern/patches to the assembled package.
set -euo pipefail

root=$(cd "$(dirname "$0")/.." && pwd)
upstream=$root/core/client-redemption/modules
patches=$root/core/client-redemption/pokeverse-modern/patches
work=$root/build/redemption-patches

[ $# -eq 2 ] || { sed -n '2,7p' "$0" >&2; exit 1; }
action=$1 module=$2
[ -d "$upstream/$module" ] || { echo "no Redemption module: $module" >&2; exit 1; }
patch=$patches/$module.patch

case "$action" in
  edit)
    rm -rf "$work/modules/$module"
    mkdir -p "$work/modules"
    cp -r "$upstream/$module" "$work/modules/"
    if [ -f "$patch" ]; then
      patch -s -p1 -d "$work" --no-backup-if-mismatch < "$patch"
    fi
    echo "$work/modules/$module"
    ;;
  save)
    [ -d "$work/modules/$module" ] || { echo "run edit first" >&2; exit 1; }
    mkdir -p "$patches"
    rm -rf "$work/pristine"
    mkdir -p "$work/pristine/modules"
    cp -r "$upstream/$module" "$work/pristine/modules/"
    if (cd "$work" && diff -ruN "pristine/modules/$module" "modules/$module") \
        | sed -e "s#^--- pristine/#--- a/#" -e "s#^+++ modules/#+++ b/modules/#" > "$patch.tmp"; then
      rm -f "$patch.tmp" "$patch"
      echo "no changes; $patch removed"
    else
      sed -i -E 's#^(---|\+\+\+) ([ab]/[^\t]*)\t.*#\1 \2#' "$patch.tmp"
      mv "$patch.tmp" "$patch"
      echo "$patch"
    fi
    rm -rf "$work/pristine"
    ;;
  *) sed -n '2,7p' "$0" >&2; exit 1 ;;
esac
