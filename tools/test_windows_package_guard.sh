#!/usr/bin/env bash
# Self-test for tools/validate_windows_package.sh: a minimal fake package must pass, and
# each forbidden addition (harness, smoke rc, bot, debug build, Mesa DLL, sources, CI
# script, credentials, automation) must be refused. Runs without any build.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT
BASE="$WORK/base"

mkdir -p "$BASE"/{client/modules/client,client/data/things/854,server/data/world,server/data/items,database/schema,database/migrations,database/seeds,scripts}
printf 'MZ fake client' > "$BASE/client/PokeVerse.exe"
echo production > "$BASE/client/VARIANT"
echo '-- init' > "$BASE/client/init.lua"
echo 'Module' > "$BASE/client/modules/client/client.otmod"
echo dat > "$BASE/client/data/things/854/Tibia.dat"
head -c 2048 /dev/zero > "$BASE/client/data/things/854/Tibia.spr"
printf 'MZ fake server' > "$BASE/server/PokeVerseServer.exe"
echo dll > "$BASE/server/lua51.dll"
printf 'lua51.dll\r\n' > "$BASE/server/required-dlls.txt"
for f in config.example.lua pt_br.loc data/world/map.otbm data/items/items.otb; do echo x > "$BASE/server/$f"; done
for f in schema/pokeaventuras.sql migrations/001.sql seeds/dev_accounts.sql required-tables.txt; do echo x > "$BASE/database/$f"; done
for f in "$ROOT"/packaging/windows/*.bat "$ROOT/packaging/windows/README-WINDOWS-TESTING.txt"; do
    sed 's/\r*$/\r/' "$f" > "$BASE/$(basename "$f")"
done
cp "$ROOT/packaging/windows/scripts/PokeVerse-Tools.ps1" "$BASE/scripts/"

"$ROOT/tools/validate_windows_package.sh" "$BASE" > /dev/null || { echo "FAIL: clean fake package refused"; "$ROOT/tools/validate_windows_package.sh" "$BASE"; exit 1; }

cases=(
    "harness executable|cp client/PokeVerse.exe client/pokeverse-client-harness.exe"
    "harness module|mkdir -p client/modules/pv_harness && echo x > client/modules/pv_harness/pv_harness.otmod"
    "harness marker in binary|printf 'HARNESS - NOT FOR DISTRIBUTION' >> client/PokeVerse.exe"
    "smoke rc|echo \"print('[pv-smoke] GAME START')\" > client/otclientrc.lua"
    "auto-login env in Lua|echo \"local a = os.getenv('PV_ACCOUNT')\" > client/modules/client/x.lua"
    "bot module|mkdir -p client/mods/game_bot"
    "debug executable|cp client/PokeVerse.exe client/pokeverse-client-debug.exe"
    "debug C runtime|printf 'VCRUNTIME140D.dll' >> client/PokeVerse.exe"
    "debug variant|echo debug > client/VARIANT"
    "Mesa opengl32|echo x > client/opengl32.dll"
    "pdb|echo x > server/PokeVerseServer.pdb"
    "C++ source|echo x > client/modules/client/creature.cpp"
    "object file|echo x > server/game.obj"
    "CMakeLists|echo x > client/CMakeLists.txt"
    "CI shell script|echo x > scripts/smoke_server.sh"
    "python tool|echo x > scripts/protocol_client.py"
    "workflow|mkdir -p .github/workflows && echo x > .github/workflows/ci.yml"
    "dev credentials in client|echo \"account = 'admin'\" > client/modules/client/login.lua"
    "dev seed outside database|echo \"SHA1('player')\" > server/data/seed.lua"
    "GM automation in launcher|echo 'python protocol_client.py --say /cb' >> Start-PokeVerse-Test.bat"
    "LF batch file|sed -i 's/\r$//' Start-PokeVerse-Server.bat"
    "missing server DLL|rm server/lua51.dll"
    "LFS pointer sprite|echo 'version https://git-lfs.github.com/spec/v1' > client/data/things/854/Tibia.spr"
    "missing launcher|rm Start-PokeVerse-Test.bat"
    "log file|echo x > client/pokeverse.log"
)
failures=0
for c in "${cases[@]}"; do
    name="${c%%|*}"; action="${c#*|}"
    rm -rf "$WORK/case"; cp -a "$BASE" "$WORK/case"
    (cd "$WORK/case" && eval "$action")
    if "$ROOT/tools/validate_windows_package.sh" "$WORK/case" > /dev/null 2>&1; then
        echo "FAIL: not refused: $name"; failures=$((failures + 1))
    else
        echo "ok: refused $name"
    fi
done
[ "$failures" = 0 ] || { echo "$failures guard case(s) not refused"; exit 1; }
echo "Windows package guard: PASS (${#cases[@]} forbidden cases refused)"
