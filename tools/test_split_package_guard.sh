#!/usr/bin/env bash
# Self-test for tools/validate_split_packages.sh on real packages (tools/package_split.sh output):
# the packages must pass, and each tampered copy (mislabeled or swapped executables, legacy files
# in the Redemption client, missing assets, modules or libraries, harness or smoke files, an
# original PokeJornadas binary name, the legacy updater, Mesa, a client in the server package...)
# must be refused. Copies are hard-linked; files are replaced, never written through the link.
# Usage: tools/test_split_package_guard.sh <windows|linux> <packages-dir>
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OS="${1:?usage: $0 <windows|linux> <packages-dir>}"
SRC="$(cd "${2:?packages dir}" && pwd)"
case "$OS" in windows) N=Windows; X=.exe; FW=libotc_framework.dll ;; linux) N=Linux; X=; FW=libotc_framework.so ;; esac
WORK=$(mktemp -d "${TMPDIR:-/tmp}/split-guard.XXXXXX")
trap 'rm -rf "$WORK"' EXIT
mkdir -p "$WORK/base"
for p in "$SRC"/PokeVerse-*-"$N" "$SRC"/PokeVerse-Client-Comparison-Windows; do
    [ -d "$p" ] && { cp -al "$p" "$WORK/base/" 2>/dev/null || cp -a "$p" "$WORK/base/"; }
done
"$ROOT/tools/validate_split_packages.sh" "$OS" "$WORK/base" > /dev/null ||
    { echo "FAIL: the untampered packages are refused"; "$ROOT/tools/validate_split_packages.sh" "$OS" "$WORK/base"; exit 1; }

S="PokeVerse-Server-$N"; R="PokeVerse-Redemption-$N/redemption-client"; L="PokeVerse-Legacy-$N/legacy-client"
# replace <file> <command producing the new content>: never writes through a hard link
replace() { local f="$1"; shift; "$@" > "$f.new"; rm -f "$f"; mv "$f.new" "$f"; }
cases=(
    "legacy executable as the Redemption client|rm $R/pokeverse-client$X; cp $L/pokeverse-legacy-client$X $R/pokeverse-client$X"
    "Redemption executable as the legacy client|rm $L/pokeverse-legacy-client$X; cp $R/pokeverse-client$X $L/pokeverse-legacy-client$X"
    "legacy executable name in the Redemption package|cp $L/pokeverse-legacy-client$X $R/"
    "legacy sprite file in the Redemption client|cp $L/data/things/Tibia.spr $R/data/things/"
    "legacy framework library in the Redemption client|cp $L/$FW $R/"
    "wrong CLIENT marker|replace $L/CLIENT echo redemption"
    "debug VARIANT|replace $R/VARIANT echo debug"
    "missing legacy image|rm $L/data/images/game/slots/body.png 2>/dev/null || rm \"\$(find $L/data -name '*.png' | head -1)\""
    "missing Redemption image|rm $R/data/images/background.png"
    "missing Redemption module|rm -r $R/modules/game_pokedex"
    "missing legacy module|rm -r $L/modules/game_pokebar"
    "LFS pointer legacy sprite|replace $L/data/things/Tibia.spr echo 'version https://git-lfs.github.com/spec/v1'"
    "harness executable|cp $R/pokeverse-client$X $R/pokeverse-client-harness$X"
    "legacy smoke module|mkdir -p $L/modules/pv_legacy_smoke && echo x > $L/modules/pv_legacy_smoke/pv_legacy_smoke.otmod"
    "smoke rc in the Redemption client|cp '$ROOT/tools/redemption_smoke_rc.lua' $R/otclientrc.lua.new && rm $R/otclientrc.lua && mv $R/otclientrc.lua.new $R/otclientrc.lua"
    "original PokeJornadas DLL name|echo x > $L/irrKlang.dll"
    "original PokeJornadas executable name|cp $L/pokeverse-legacy-client$X $L/otclient.exe"
    "legacy updater in the binary|replace $L/pokeverse-legacy-client$X sh -c 'cat $L/pokeverse-legacy-client$X; printf http://localhost/otclient/'"
    "Mesa opengl32.dll|echo x > $L/opengl32.dll"
    "client in the server package|mkdir -p $S/client && echo x > $S/client/x"
    "server config not on 127.0.0.1|replace $S/server/config.lua sh -c \"sed 's/127.0.0.1/0.0.0.0/' $S/server/config.lua\""
    "log file|echo x > $L/Pokecenter.log"
    "missing launcher|rm PokeVerse-Legacy-$N/start-legacy-client.sh PokeVerse-Legacy-$N/'Start Legacy Client.bat' 2>/dev/null; true"
)
if [ "$OS" = linux ]; then
    cases+=("missing legacy library|rm $L/lib/libphysfs.so*"
            "host C++ runtime bundled|cp \"\$(ldconfig -p | awk '/libstdc\\+\\+.so.6 .*x86-64/ {print \$NF; exit}')\" $L/lib/")
else
    C=PokeVerse-Client-Comparison-Windows
    cases+=("missing legacy DLL|rm \"$L/\$(tr -d '\\r' < $L/required-dlls.txt | grep -v otc_framework | head -1)\""
            "comparison client differs|echo x > $C/redemption-client/extra.txt"
            "comparison without Start Both Clients|rm '$C/Start Both Clients.bat'"
            "LF launcher|replace '$C/Start Legacy Client.bat' tr -d '\\r' < '$C/Start Legacy Client.bat'")
fi
failures=0
for c in "${cases[@]}"; do
    name="${c%%|*}"; action="${c#*|}"
    rm -rf "$WORK/case"; mkdir -p "$WORK/case"
    for p in "$WORK"/base/*; do cp -al "$p" "$WORK/case/" 2>/dev/null || cp -a "$p" "$WORK/case/"; done
    (cd "$WORK/case" && eval "$action") || { echo "FAIL: could not apply: $name"; failures=$((failures + 1)); continue; }
    if "$ROOT/tools/validate_split_packages.sh" "$OS" "$WORK/case" > /dev/null 2>&1; then
        echo "FAIL: not refused: $name"; failures=$((failures + 1))
    else
        echo "ok: refused $name"
    fi
done
# An original binary under an innocent name is recognised by its SHA-256 (a stand-in file is
# added to a copy of the manifest, since the original binaries are not in the repository).
rm -rf "$WORK/case"; mkdir -p "$WORK/case"
for p in "$WORK"/base/*; do cp -al "$p" "$WORK/case/" 2>/dev/null || cp -a "$p" "$WORK/case/"; done
printf 'MZ stand-in for an original PokeJornadas binary\n' > "$WORK/case/$L/sound.dll"
{ cat "$ROOT/original/MANIFEST.sha256.tsv"
  printf 'Cliente/Cliente/standin.dll\t%s\t%s\n' "$(stat -c %s "$WORK/case/$L/sound.dll")" "$(sha256sum "$WORK/case/$L/sound.dll" | cut -d' ' -f1)"
} > "$WORK/manifest.tsv"
if POKEVERSE_ORIGINAL_MANIFEST="$WORK/manifest.tsv" "$ROOT/tools/validate_split_packages.sh" "$OS" "$WORK/case" > /dev/null 2>&1; then
    echo "FAIL: not refused: original binary under another name"; failures=$((failures + 1))
else
    echo "ok: refused original binary under another name"
fi
[ "$failures" = 0 ] || { echo "$failures guard case(s) not refused"; exit 1; }
echo "Split package guard: PASS ($((${#cases[@]} + 1)) tampered cases refused)"
