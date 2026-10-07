#!/usr/bin/env bash
# Refuse a Windows development package (tools/package_windows.sh) that is incomplete or contains
# anything that must never reach a tester: the test harness, smoke-test or auto-login
# scripts, GM automation, bot modules, debug or bot-protection-off builds, Mesa software
# OpenGL, sources, build intermediates, CI scripts, or development credentials in code.
# With --check-imports (needs objdump), every DLL an .exe or .dll imports must be shipped next
# to it or be part of Windows itself, so the package runs on a clean Windows 10/11 machine.
# Usage: tools/validate_windows_package.sh [--check-imports] <package-dir>
set -euo pipefail
CHECK_IMPORTS=0
[ "${1:-}" = --check-imports ] && { CHECK_IMPORTS=1; shift; }
PKG="${1:?usage: $0 [--check-imports] <package-dir>}"
[ -d "$PKG" ] || { echo "PACKAGE INVALID: $PKG does not exist" >&2; exit 1; }
problems=()
bad() { problems+=("$*"); }

# Completeness
for f in client/pokeverse-client.exe client/VARIANT client/init.lua client/modules/client/client.otmod \
         client/modules/game_pokebar/pokebar.otmod client/modules/game_pokemoves/pokemoves.otmod \
         client/modules/gamelib/pokeverse.lua \
         client/data/things/854/Tibia.dat client/data/things/854/Tibia.spr \
         server/pokeverse-server.exe server/required-dlls.txt server/config.lua server/config.example.lua server/pt_br.loc \
         server/data/world/map.otbm server/data/items/items.otb server/data/XML/vocations.xml \
         database/schema/pokeaventuras.sql database/seeds/dev_accounts.sql database/required-tables.txt \
         "Setup Database.bat" "Reset Development Database.bat" "Start Server.bat" \
         "Start Client.bat" "Start Server and Client.bat" README.txt scripts/PokeVerse-Tools.ps1; do
    [ -e "$PKG/$f" ] || bad "missing $f"
done
ls "$PKG"/database/migrations/*.sql > /dev/null 2>&1 || bad "no database/migrations/*.sql"
[ "$(cat "$PKG/client/VARIANT" 2>/dev/null)" = production ] || bad "client/VARIANT is not 'production'"
if [ -f "$PKG/client/data/things/854/Tibia.spr" ]; then
    [ "$(head -c 7 "$PKG/client/data/things/854/Tibia.spr" | tr -d '\0')" != version ] || bad "client Tibia.spr is a Git LFS pointer"
fi
if [ -f "$PKG/server/required-dlls.txt" ]; then
    while IFS= read -r dll; do
        dll="${dll//$'\r'/}"; [ -n "$dll" ] || continue
        [ -f "$PKG/server/$dll" ] || bad "server/required-dlls.txt lists $dll, which is missing"
    done < "$PKG/server/required-dlls.txt"
fi
for exe in "$PKG"/client/*.exe; do [ "$(basename "$exe")" = pokeverse-client.exe ] || bad "extra client executable $(basename "$exe")"; done
for exe in "$PKG"/server/*.exe; do [ "$(basename "$exe")" = pokeverse-server.exe ] || bad "extra server executable $(basename "$exe")"; done
for f in "$PKG"/*.bat "$PKG/README.txt" "$PKG/server/required-dlls.txt" "$PKG/database/required-tables.txt"; do
    [ -f "$f" ] || continue
    # Count bytes: grep on Windows strips the CR before matching unless given -U.
    [ "$(tr -cd '\r' < "$f" | wc -c)" -gt 0 ] || bad "$(basename "$f") does not have CRLF line endings"
    [ "$(tr -cd '\r' < "$f" | wc -c)" -eq "$(tr -cd '\n' < "$f" | wc -c)" ] || bad "$(basename "$f") has stray carriage returns (CR CR LF)"
done

# DLL imports (Windows system DLLs are the ones every Windows 10/11 installation has)
SYSTEM_DLLS=' kernel32 user32 gdi32 gdiplus advapi32 shell32 shlwapi ole32 oleaut32 comdlg32 comctl32 ws2_32 wsock32
 mswsock iphlpapi dnsapi winmm opengl32 glu32 imm32 version setupapi cfgmgr32 crypt32 bcrypt ncrypt secur32 sspicli
 dbghelp uxtheme dwmapi hid winhttp wininet wldap32 normaliz rpcrt4 userenv psapi ntdll powrprof xinput1_4 xinput9_1_0
 dinput8 dsound avrt mmdevapi ksuser msvcrt ucrtbase wtsapi32 msimg32 d3d9 d3d11 d3d12 dxgi shcore wintrust netapi32
 mpr usp10 dxva2 mf mfplat mfreadwrite propsys '
SYSTEM_DLLS=" $(printf '%s' "$SYSTEM_DLLS" | tr -s '\n\t ' '   ') "
if [ "$CHECK_IMPORTS" = 1 ]; then
    command -v objdump > /dev/null || bad "--check-imports needs objdump (binutils)"
    for bin in "$PKG"/client/*.exe "$PKG"/client/*.dll "$PKG"/server/*.exe "$PKG"/server/*.dll; do
        [ -f "$bin" ] || continue
        command -v objdump > /dev/null || break
        imports=$(objdump -p "$bin" 2>/dev/null | sed -n 's/^\s*DLL Name: //p' | tr -d '\r') ||
            { bad "objdump cannot read $(basename "$bin")"; continue; }
        [ -n "$imports" ] || { bad "$(basename "$bin") has no import table (not a PE file?)"; continue; }
        while IFS= read -r dll; do
            lower=$(printf '%s' "$dll" | tr 'A-Z' 'a-z'); base="${lower%.dll}"
            case "$lower" in api-ms-win-*|ext-ms-win-*) continue ;; esac
            case "$SYSTEM_DLLS" in *" $base "*) continue ;; esac
            dir=$(dirname "$bin")
            ls "$dir" | tr 'A-Z' 'a-z' | grep -qxF "$lower" ||
                bad "$(basename "$bin") needs $dll, which is neither shipped in ${dir#"$PKG"/} nor a Windows system DLL"
        done <<< "$imports"
    done
fi

# Forbidden files
while IFS= read -r path; do
    bad "forbidden file ${path#"$PKG"/}"
done < <(find "$PKG" \( -iname '*harness*' -o -iname '*smoke_rc*' -o -iname '*-debug*' \
    -o -iname '*.pdb' -o -iname '*.ilk' -o -iname '*.obj' -o -iname '*.o' -o -iname '*.lib' -o -iname '*.exp' -o -iname '*.a' \
    -o -iname '*.cpp' -o -iname '*.cc' -o -iname '*.c' -o -iname '*.h' -o -iname '*.hpp' \
    -o -iname 'CMakeLists.txt' -o -iname 'CMakeCache.txt' -o -iname '*.cmake' -o -iname '*.vcxproj' -o -iname '*.sln' \
    -o -iname '*.sh' -o -iname '*.py' -o -iname '*.yml' -o -iname '*.yaml' -o -iname 'protocol_client*' \
    -o -iname '*.log' -o -iname '*.bak' \
    -o -iname 'opengl32.dll' -o -iname 'libgallium_wgl.dll' -o -iname 'libglapi.dll' -o -iname 'dxil.dll' \
    -o -iname 'vcruntime140d.dll' -o -iname 'msvcp140d.dll' -o -iname 'ucrtbased.dll' \) -print)
while IFS= read -r path; do
    bad "forbidden directory ${path#"$PKG"/}"
done < <(find "$PKG" -type d \( -name game_bot -o -name .github -o -name .git -o -name CMakeFiles \
    -o -path "$PKG/tools" -o -path "$PKG/build" -o -path "$PKG/client/tools" -o -path "$PKG/client/build" \
    -o -path "$PKG/server/tools" -o -path "$PKG/server/build" \) -print)

# Forbidden content
for bin in "$PKG"/client/*.exe "$PKG"/client/*.dll "$PKG"/server/*.exe "$PKG"/server/*.dll; do
    [ -f "$bin" ] || continue
    grep -aq "HARNESS - NOT FOR DISTRIBUTION\|HARNESS BUILD" "$bin" && bad "$(basename "$bin") contains harness markers"
    grep -aiq "vcruntime140d\.dll\|msvcp140d\.dll\|ucrtbased\.dll" "$bin" && bad "$(basename "$bin") links the debug C runtime"
done
markers='\[pv-smoke\]|PV_EXPECT_POKEBAR|PV_ACCOUNT|PV_PASSWORD|redemption_smoke_rc|TEST_AUTOMATION_ENABLED|BOT_PROTECTION_DISABLED|pv_harness'
while IFS= read -r path; do
    bad "test automation marker in ${path#"$PKG"/}"
done < <(grep -rlIE --include='*.lua' --include='*.otml' --include='*.otmod' --include='*.otui' --include='*.ini' \
    --include='*.bat' --include='*.ps1' --include='*.txt' --include='*.xml' "$markers" "$PKG" 2>/dev/null || true)
# The development accounts live only in database/seeds and the instructions.
while IFS= read -r path; do
    bad "development account credentials in ${path#"$PKG"/}"
done < <(grep -rlIE "SHA1\('(player|admin)'\)|(account|password)[\"' ]*[=:][ ]*[\"'](player|admin)[\"']" \
    "$PKG/client" "$PKG/server" "$PKG/scripts" 2>/dev/null || true)
# No automatic login or typed commands in the launchers.
while IFS= read -r path; do
    bad "launcher automates the game: ${path#"$PKG"/}"
done < <(grep -lIiE 'sendkeys|--say|autologin|/cb |/shutdown"' "$PKG"/*.bat "$PKG"/scripts/*.ps1 2>/dev/null || true)

if [ ${#problems[@]} -gt 0 ]; then
    echo "PACKAGE INVALID: $PKG" >&2
    printf '  - %s\n' "${problems[@]}" >&2
    exit 1
fi
echo "Windows development package valid: $PKG"
