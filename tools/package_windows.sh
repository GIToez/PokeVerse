#!/usr/bin/env bash
# Assemble the Windows local test package (docs/BUILD_WINDOWS.md, README-WINDOWS-TESTING.txt):
#   <out>/client/    PokeVerse.exe + Redemption runtime files + PokeVerse 854 SPR/DAT
#   <out>/server/    PokeVerseServer.exe + MinGW DLLs + data + config.example.lua
#   <out>/database/  schema, migrations, development seed, required-tables.txt
#   <out>/*.bat, scripts/, README-WINDOWS-TESTING.txt (from packaging/windows)
# then runs tools/validate_windows_package.sh on the result.
# Inputs: a staged Release client (tools/stage_redemption.sh release, Windows build) and a
# Windows server build (tools/build_server.sh in MSYS2 UCRT64).
# Usage: tools/package_windows.sh [client-dist] [server-dist] [out-dir]
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CLIENT="${1:-$ROOT/dist/client-redemption}"
SERVER="${2:-$ROOT/dist/server}"
OUT="${3:-$ROOT/dist/windows/PokeVerse-Windows-Test}"
TEMPLATES="$ROOT/packaging/windows"
RUNTIME="$ROOT/server/runtime-data"

fail() { echo "PACKAGING REFUSED: $*" >&2; exit 1; }
# perl, not sed: MSYS2 tools may drop or add carriage returns in text mode.
crlf() { perl -pe 's/\r*\n/\r\n/' "$1" > "$2"; }

[ -f "$CLIENT/pokeverse-client.exe" ] || fail "no $CLIENT/pokeverse-client.exe (Windows Release client, tools/stage_redemption.sh release)"
[ "$(cat "$CLIENT/VARIANT" 2>/dev/null)" = production ] || fail "$CLIENT/VARIANT is not production"
[ -f "$SERVER/pokeverse-server.exe" ] || fail "no $SERVER/pokeverse-server.exe (Windows server build, tools/build_server.sh)"

rm -rf "$OUT"
mkdir -p "$OUT/client" "$OUT/server" "$OUT/database/schema" "$OUT/database/migrations" "$OUT/database/seeds" "$OUT/scripts"

# Client: everything staged except logs, the Mesa software-OpenGL DLLs CI adds for its
# GPU-less runners (they would replace the real driver), and the user rc file.
MESA='opengl32.dll libgallium_wgl.dll libglapi.dll dxil.dll'
(cd "$CLIENT" && find . -mindepth 1 -maxdepth 1) | while read -r entry; do
    name="${entry#./}"
    case " $MESA " in *" $name "*) continue ;; esac
    case "$name" in *.log|pokeverse-client.exe|otclientrc.lua) continue ;; esac
    cp -a "$CLIENT/$name" "$OUT/client/$name"
done
cp "$CLIENT/pokeverse-client.exe" "$OUT/client/PokeVerse.exe"
cp "$ROOT/client-redemption/otclientrc.lua" "$OUT/client/otclientrc.lua"
find "$OUT/client" -name '*.log' -delete
# Upstream modules carry reference server sources (game_paperdolls/server/*.cpp); a test package ships none.
find "$OUT/client" -type f \( -name '*.cpp' -o -name '*.h' -o -name '*.hpp' -o -name '*.c' \) -delete
find "$OUT/client/modules" "$OUT/client/mods" -type d -name server -empty -delete
THINGS="$ROOT/client/runtime-data/data/things"
mkdir -p "$OUT/client/data/things/854"
for f in Tibia.dat Tibia.spr; do
    dst="$OUT/client/data/things/854/$f"
    if [ ! -s "$dst" ] || [ "$(head -c 7 "$dst")" = version ]; then
        [ "$(head -c 7 "$THINGS/$f")" != version ] || fail "$THINGS/$f is a Git LFS pointer; run: git lfs pull --include client/runtime-data/data/things/$f"
        rm -f "$dst"; cp "$THINGS/$f" "$dst"
    fi
done

# Server: the executable without its debug sections, the MinGW runtime DLLs it was linked
# against, and the runtime data (no logs, no saved state, no editor/backup files).
STRIP="${STRIP:-}"
if [ -z "$STRIP" ]; then
    for s in x86_64-w64-mingw32-strip strip; do command -v "$s" > /dev/null && { STRIP=$s; break; }; done
fi
cp "$SERVER/pokeverse-server.exe" "$OUT/server/PokeVerseServer.exe"
if [ -n "$STRIP" ] && "$STRIP" --strip-debug "$OUT/server/PokeVerseServer.exe" 2>/dev/null; then
    echo "Stripped debug info from PokeVerseServer.exe with $STRIP"
else
    cp "$SERVER/pokeverse-server.exe" "$OUT/server/PokeVerseServer.exe"
    echo "WARNING: PokeVerseServer.exe keeps its debug info (no PE-capable strip)" >&2
fi
: > "$OUT/server/required-dlls.txt.tmp"
for dll in "$SERVER"/*.dll; do
    [ -e "$dll" ] || fail "no DLLs next to $SERVER/pokeverse-server.exe (build it with tools/build_server.sh in MSYS2 UCRT64)"
    cp "$dll" "$OUT/server/"
    basename "$dll" >> "$OUT/server/required-dlls.txt.tmp"
done
LC_ALL=C sort "$OUT/server/required-dlls.txt.tmp" | perl -pe 's/\r*\n/\r\n/' > "$OUT/server/required-dlls.txt"
rm "$OUT/server/required-dlls.txt.tmp"
tar -C "$RUNTIME" --exclude='*.bak' --exclude='.idea' --exclude='.gitkeep' --exclude='*.log' -cf - data | tar -C "$OUT/server" -xf -
cp "$RUNTIME/pt_br.loc" "$RUNTIME/json.lua" "$OUT/server/"
{
    printf -- '-- PokeVerse server configuration for the Windows local test package.\r\n'
    printf -- '-- Start-PokeVerse-Server.bat copies this file to config.lua when config.lua is missing;\r\n'
    printf -- '-- Setup-PokeVerse-Database.bat writes the database settings (sql*) into config.lua.\r\n'
    printf -- '-- DEVELOPMENT ONLY: the server listens on 127.0.0.1; never expose it to a network.\r\n\r\n'
    sed 's/^\(\s*sqlHost\s*=\s*\)"localhost"/\1"127.0.0.1"/' "$RUNTIME/config.lua"
} > "$OUT/server/config.example.lua"
grep -q 'sqlHost = "127.0.0.1"' "$OUT/server/config.example.lua" || fail "could not set sqlHost in config.example.lua"

# Database
cp "$ROOT/database/pokeaventuras.sql" "$OUT/database/schema/"
cp "$ROOT"/database/migrations/*.sql "$OUT/database/migrations/"
cp "$ROOT/database/seeds/dev_accounts.sql" "$OUT/database/seeds/"
{
    printf '# Tables the server code uses (tools/check_db_tables.py --print-required).\r\n'
    printf '# Setup and Start-PokeVerse-Test.bat fail when one is missing.\r\n'
    python3 "$ROOT/tools/check_db_tables.py" --print-required | perl -pe 's/\r*\n/\r\n/'
} > "$OUT/database/required-tables.txt"

# Launchers and instructions (CRLF for cmd.exe and Notepad)
for f in "$TEMPLATES"/*.bat "$TEMPLATES"/README-WINDOWS-TESTING.txt; do crlf "$f" "$OUT/$(basename "$f")"; done
crlf "$TEMPLATES/scripts/PokeVerse-Tools.ps1" "$OUT/scripts/PokeVerse-Tools.ps1"
{
    printf 'PokeVerse Windows local test package\r\n'
    printf 'commit   %s\r\n' "$(git -C "$ROOT" rev-parse HEAD 2>/dev/null || echo unknown)"
    printf 'built    %s\r\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
    printf 'client   Redemption (client-redemption), Release, VARIANT=production\r\n'
    printf 'server   TFS 0.3.6 PokeVerse (server/source), MinGW-w64 UCRT64\r\n'
} > "$OUT/VERSION.txt"

"$ROOT/tools/validate_windows_package.sh" "$OUT"
echo "Windows test package: $OUT ($(du -sh "$OUT" | cut -f1))"
