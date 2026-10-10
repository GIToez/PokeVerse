#!/usr/bin/env bash
# Assembles a runnable PokeVerse client on the Redemption engine.
#
#   scripts/assemble-redemption-client.sh [options] <out dir> [binary...]
#
# The tree is Redemption's modules and data (core/client-redemption) with the PokeVerse
# modules and artwork from the legacy client added, and the PokeVerse adaptations
# (core/client-redemption/pokeverse-modern) copied on top, plus the given binaries
# (otclient, otclient.exe, DLLs...).
#
# With --classic the tree is the previous layout instead: the legacy modules and data with
# the overlay core/client-redemption/pokeverse on top and no Redemption modules. The parity
# tests use it as the reference for unchanged behaviour.
#
# Options:
#   --classic          the previous layout (see above)
#   --host <address>   point the client at this server instead of 127.0.0.1
#   --port <port>      login port (default 7564; the parity tests use a proxy port)
#   --updater <url>    enable the updater with this manifest URL (live packages only)
#   --link             hard-link the legacy data instead of copying it (local testing)
#   --test             also ship the self-test module (scripts/client-test/client_selftest)
set -euo pipefail

root=$(cd "$(dirname "$0")/.." && pwd)
legacy=$root/core/client-legacy
redemption=$root/core/client-redemption
overlay=$redemption/pokeverse-modern
classic=0
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
    --classic) classic=1; shift ;;
    -*) echo "unknown option: $1" >&2; exit 1 ;;
    *) break ;;
  esac
done
[ $# -ge 1 ] || { sed -n '2,21p' "$0" >&2; exit 1; }
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

# Redemption modules that are Tibia systems PokeVerse does not have, or that a later stage
# brings in (store, cyclopedia, analysers, notifications)
redemption_skip=(client_assets client_bottommenu client_debug_info dev_otui game_htmlsample game_soundDebug
  game_forge game_wheel game_prey game_imbuing game_imbuementtracker game_blessing game_highscore
  game_paperdolls game_playermount game_proficiency game_rewardwall game_spelllist game_stash
  game_taskboard game_unjustifiedpoints game_inspect game_quickloot
  game_shop game_store game_cyclopedia game_analyser game_lootsplitter game_notifications)
# PokeVerse modules taken from the legacy client, replacing a Redemption module of the same name
legacy_modules=(client_entergame game_advanceeffect game_badgecase game_combatcontrols game_dollcase
  game_duelmessage game_effects game_guide game_lootlist game_market game_pokebar game_pokedex
  game_pokemoves game_poll game_slotmachine game_statusbar game_time game_tips game_tmchoose game_tutorial)
# PokeVerse game data and protocol files from the legacy gamelib
legacy_gamelib=(pokemon moves items types)
legacy_protocol=(protocollogin protocolaccount)
# PokeVerse artwork that replaces Redemption's file of the same name
legacy_data_wins=(images/background.png images/clienticon.png images/game/slots images/game/npcicons
  images/game/combatmodes)

copy_tree() { # <from> <to>: hard links with --link, otherwise a copy; existing files are kept
  if [ "$link" = 1 ]; then cp -al --update=none "$1/." "$2/"; else cp -a --update=none "$1/." "$2/"; fi
}

overlay_tree() { # <from> <to>: every file replaces the file at the same path
  (cd "$1" && find . -type f) | while read -r f; do
    mkdir -p "$2/$(dirname "$f")"
    cp --remove-destination "$1/$f" "$2/$f"
  done
}

rm -rf "$out"
mkdir -p "$out"

if [ "$classic" = 1 ]; then
  overlay=$redemption/pokeverse
  if [ "$link" = 1 ]; then
    cp -al "$legacy/data" "$out/data"
    cp -r "$legacy/modules" "$out/modules"
  else
    cp -r "$legacy/data" "$legacy/modules" "$out/"
  fi
  rm -f "$out/modules/corelib.rar"
else
  mkdir -p "$out/data" "$out/modules"
  # Redemption's look wins where both have a file; everything else PokeVerse is added
  copy_tree "$redemption/data" "$out/data"
  rm -f "$out/data/things/README.md"
  # the legacy styles load first (client_styles), so the PokeVerse windows keep their styles
  # and Redemption's same-named styles replace the legacy look
  mkdir -p "$out/data/legacy-styles"
  copy_tree "$legacy/data/styles" "$out/data/legacy-styles"
  (cd "$legacy/data" && find . -path ./styles -prune -o -type f -print) | while read -r f; do
    [ -e "$out/data/$f" ] && continue
    mkdir -p "$out/data/$(dirname "$f")"
    if [ "$link" = 1 ]; then ln "$legacy/data/$f" "$out/data/$f"; else cp "$legacy/data/$f" "$out/data/$f"; fi
  done
  for f in "${legacy_data_wins[@]}"; do
    (cd "$legacy/data" && find "$f" -type f) | while read -r g; do
      mkdir -p "$out/data/$(dirname "$g")"
      rm -f "$out/data/$g"
      if [ "$link" = 1 ]; then ln "$legacy/data/$g" "$out/data/$g"; else cp "$legacy/data/$g" "$out/data/$g"; fi
    done
  done

  cp -r "$redemption/modules/." "$out/modules/"
  for m in "${redemption_skip[@]}" "${legacy_modules[@]}"; do
    rm -rf "${out:?}/modules/$m"
  done
  for m in "${legacy_modules[@]}"; do
    cp -r "$legacy/modules/$m" "$out/modules/"
  done
  mkdir -p "$out/modules/gamelib/pokeverse"
  for f in "${legacy_gamelib[@]}"; do
    cp "$legacy/modules/gamelib/$f.lua" "$out/modules/gamelib/pokeverse/"
  done
  for f in "${legacy_protocol[@]}"; do
    cp "$legacy/modules/gamelib/$f.lua" "$out/modules/gamelib/"
  done
  cp "$redemption/init.lua" "$out/"
fi
cp "$legacy/LICENSE" "$out/"

if [ "$classic" = 0 ]; then
  # engine-level PokeVerse modules are the same for both layouts
  for m in game_features game_things updater; do
    overlay_tree "$redemption/pokeverse/modules/$m" "$out/modules/$m"
  done
fi
overlay_tree "$overlay" "$out"
rm -rf "$out/patches"

# small changes to Redemption's own modules, kept as patches so they stay reviewable
if [ "$classic" = 0 ]; then
  for p in "$overlay"/patches/*.patch; do
    [ -e "$p" ] || continue
    # data may be hard links into the repository (--link), so patches stay inside modules/
    if grep -E '^(\+\+\+|---) ' "$p" | grep -vqE '^(\+\+\+|---) [ab]/modules/'; then
      echo "patch touches files outside modules/: $p" >&2; exit 1
    fi
    patch -s -p1 -d "$out" --no-backup-if-mismatch -r - < "$p" || { echo "patch does not apply: $p" >&2; exit 1; }
  done
fi

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
