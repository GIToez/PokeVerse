#!/usr/bin/env bash
# Refuse the separate PokeVerse packages (tools/package_split.sh) when one is incomplete,
# mislabeled or carries anything that must not reach a tester:
#   all       no harness/smoke/auto-login files or markers, sources, logs, CI scripts, Mesa,
#             bot module, LFS pointers, or any original PokeJornadas binary (by name or by the
#             SHA-256 in original/MANIFEST.sha256.tsv)
#   server    server + database + setup/start/stop, no client, config on 127.0.0.1
#   redemption  the Redemption executable ('Redemption' marker, no 'Pokecenter'), every image,
#             the module and mod set of client-redemption (without the bot), no legacy files
#   legacy    the legacy executable ('Pokecenter' marker, no 'Redemption'), the complete
#             client/runtime-data file set with identical sizes, no WinINet import (legacy
#             updater compiled out), no opengl32.dll, libraries resolve (Linux)
#   comparison (Windows) the same server and clients as the separate packages, all launchers
# With --check-imports (Windows, needs objdump) every DLL an .exe or .dll imports must be shipped
# next to it or be part of Windows.
# Usage: tools/validate_split_packages.sh [--check-imports] <windows|linux> <dir-with-packages>
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CHECK_IMPORTS=0
[ "${1:-}" = --check-imports ] && { CHECK_IMPORTS=1; shift; }
OS="${1:?usage: $0 [--check-imports] <windows|linux> <dir>}"
DIR="${2:?usage: $0 [--check-imports] <windows|linux> <dir>}"
case "$OS" in windows) OSNAME=Windows; X=.exe ;; linux) OSNAME=Linux; X= ;; *) echo "unknown OS $OS" >&2; exit 2 ;; esac
problems=()
bad() { problems+=("$*"); }

SERVER_PKG="$DIR/PokeVerse-Server-$OSNAME"
REDEMPTION_PKG="$DIR/PokeVerse-Redemption-$OSNAME"
LEGACY_PKG="$DIR/PokeVerse-Legacy-$OSNAME"
COMPARISON_PKG="$DIR/PokeVerse-Client-Comparison-Windows"
PACKAGES=("$SERVER_PKG" "$REDEMPTION_PKG" "$LEGACY_PKG")
[ "$OS" = windows ] && PACKAGES+=("$COMPARISON_PKG")

need() { # <package> <relative paths...>
    local pkg="$1"; shift
    for f in "$@"; do [ -e "$pkg/$f" ] || bad "$(basename "$pkg"): missing $f"; done
}
crlf_ok() { # <file>
    local cr lf
    cr=$(tr -cd '\r' < "$1" | wc -c); lf=$(tr -cd '\n' < "$1" | wc -c)
    [ "$cr" -gt 0 ] && [ "$cr" -eq "$lf" ]
}

# Original PokeJornadas binaries: refused by name, and by content whatever their name.
# Names only the PokeJornadas package uses; generic library names (zlib1.dll...) are left to the hash check.
is_original_name() {
    case "$1" in
        otclient.exe|ps.exe|hash.exe|iidking*.exe|'large address aware.exe'|d3dx9_43.dll|ex.dll|irrklang.dll|ikp*.dll|\
        libegl.dll|libglesv2.dll|lua5.1.dll|libeay32.dll|libmysql.dll|mysql.dll) return 0 ;;
    esac
    return 1
}
MANIFEST="${POKEVERSE_ORIGINAL_MANIFEST:-$ROOT/original/MANIFEST.sha256.tsv}"
declare -A ORIGINAL_HASH=() ORIGINAL_SIZE=()
if [ -f "$MANIFEST" ]; then
    while IFS=$'\t' read -r path size sha; do
        case "$path" in *.exe|*.dll|*.EXE|*.DLL) ORIGINAL_HASH[$sha]="$path"; ORIGINAL_SIZE[$size]=1 ;; esac
    done < <(tail -n +3 "$MANIFEST")
else
    bad "no $MANIFEST to recognise the original binaries"
fi

common_checks() { # <package>
    local pkg="$1" name; name=$(basename "$pkg")
    [ -d "$pkg" ] || { bad "$name does not exist"; return; }
    need "$pkg" README.txt VERSION.txt
    while IFS= read -r path; do bad "$name: forbidden file ${path#"$pkg"/}"; done < <(find "$pkg" \( -iname '*harness*' \
        -o -iname '*smoke_rc*' -o -iname 'smoke_*' -o -iname 'pv_*smoke*' -o -iname 'compare_clients*' -o -iname '*-debug*' \
        -o -iname '*.pdb' -o -iname '*.ilk' -o -iname '*.obj' -o -iname '*.o' -o -iname '*.lib' -o -iname '*.exp' -o -iname '*.a' \
        -o -iname '*.cpp' -o -iname '*.cc' -o -iname '*.c' -o -iname '*.h' -o -iname '*.hpp' \
        -o -iname 'CMakeLists.txt' -o -iname 'CMakeCache.txt' -o -iname '*.cmake' -o -iname '*.vcxproj' -o -iname '*.sln' \
        -o -iname '*.py' -o -iname '*.yml' -o -iname '*.yaml' -o -iname 'protocol_client*' -o -iname '*.log' -o -iname '*.bak' \
        -o -iname 'opengl32.dll' -o -iname 'libgallium_wgl.dll' -o -iname 'libglapi.dll' -o -iname 'dxil.dll' \
        -o -iname 'vcruntime140d.dll' -o -iname 'msvcp140d.dll' -o -iname 'ucrtbased.dll' -o -iname 'otclientrc.lua.bak' \) -print)
    if [ "$OS" = windows ]; then
        while IFS= read -r path; do bad "$name: shell script ${path#"$pkg"/} in a Windows package"; done < <(find "$pkg" -iname '*.sh')
    else
        while IFS= read -r path; do bad "$name: unexpected script ${path#"$pkg"/}"; done < <(find "$pkg" -mindepth 2 -iname '*.sh')
    fi
    while IFS= read -r path; do bad "$name: forbidden directory ${path#"$pkg"/}"; done < <(find "$pkg" -type d \( -name game_bot \
        -o -name pv_harness -o -name pv_legacy_smoke -o -name .github -o -name .git -o -name CMakeFiles \) -print)
    while IFS= read -r path; do bad "$name: forbidden directory ${path#"$pkg"/}"; done < <(find "$pkg" -maxdepth 2 -type d \
        \( -name tools -o -name build -o -name source -o -name src \) -print)
    local f lower
    while IFS= read -r -d '' f; do
        lower=$(basename "$f" | tr 'A-Z' 'a-z')
        ! is_original_name "$lower" || bad "$name: original PokeJornadas binary name ${f#"$pkg"/}"
    done < <(find "$pkg" -type f \( -iname '*.exe' -o -iname '*.dll' \) -print0)
    local rec size
    while IFS= read -r -d '' rec; do
        size="${rec%% *}"; f="${rec#* }"
        [ -n "${ORIGINAL_SIZE[$size]:-}" ] || continue
        sha=$(sha256sum "$f" | cut -d' ' -f1)
        [ -z "${ORIGINAL_HASH[$sha]:-}" ] || bad "$name: ${f#"$pkg"/} is the original ${ORIGINAL_HASH[$sha]}"
    done < <(find "$pkg" -type f -printf '%s %p\0')
    while IFS= read -r path; do bad "$name: Git LFS pointer ${path#"$pkg"/}"; done < <(find "$pkg" -type f -size -200c \
        \( -iname '*.spr' -o -iname '*.dat' -o -iname '*.otbm' -o -iname '*.otb' -o -iname '*.png' -o -iname '*.ogg' -o -iname '*.wav' \) \
        -exec grep -l '^version https://git-lfs' {} + 2>/dev/null || true)
    local markers='\[pv-smoke\]|\[pv-legacy-smoke\]|PV_EXPECT_POKEBAR|PV_ACCOUNT|PV_PASSWORD|PV_CHARACTER|redemption_smoke_rc|pv_legacy_smoke|TEST_AUTOMATION_ENABLED|BOT_PROTECTION_DISABLED|pv_harness'
    while IFS= read -r path; do bad "$name: test automation marker in ${path#"$pkg"/}"; done < <(grep -rlIE \
        --include='*.lua' --include='*.otml' --include='*.otmod' --include='*.otui' --include='*.ini' --include='*.bat' \
        --include='*.ps1' --include='*.txt' --include='*.xml' --include='*.sh' "$markers" "$pkg" 2>/dev/null || true)
    while IFS= read -r path; do bad "$name: development account credentials in ${path#"$pkg"/}"; done < <(grep -rlIE \
        "SHA1\('(player|admin)'\)|(account|password)[\"' ]*[=:][ ]*[\"'](player|admin)[\"']" "$pkg" \
        --exclude-dir=database --exclude=README.txt 2>/dev/null || true)
    while IFS= read -r path; do bad "$name: launcher automates the game: ${path#"$pkg"/}"; done < <(grep -lIiE \
        'sendkeys|xdotool|--say|autologin|/cb |/shutdown"' "$pkg"/*.bat "$pkg"/*.sh "$pkg"/scripts/*.ps1 2>/dev/null || true)
    while IFS= read -r -d '' f; do
        grep -aq "HARNESS - NOT FOR DISTRIBUTION\|HARNESS BUILD" "$f" && bad "$name: ${f#"$pkg"/} contains harness markers"
        grep -aiq "vcruntime140d\.dll\|msvcp140d\.dll\|ucrtbased\.dll" "$f" && bad "$name: ${f#"$pkg"/} links the debug C runtime"
    done < <(find "$pkg" -maxdepth 2 -type f \( -name '*.exe' -o -name '*.dll' -o -name 'pokeverse-*' -o -name '*.so' \) -print0)
    if [ "$OS" = windows ]; then
        while IFS= read -r -d '' f; do
            crlf_ok "$f" || bad "$name: ${f#"$pkg"/} does not have CRLF line endings"
        done < <(find "$pkg" -maxdepth 1 -type f \( -name '*.bat' -o -name '*.txt' \) -print0)
        [ ! -f "$pkg/legacy-client/required-dlls.txt" ] || crlf_ok "$pkg/legacy-client/required-dlls.txt" ||
            bad "$name: legacy-client/required-dlls.txt does not have CRLF line endings"
    else
        for f in "$pkg"/*.sh; do [ ! -f "$f" ] || [ -x "$f" ] || bad "$name: $(basename "$f") is not executable"; done
    fi
}

check_imports() { # <dir>: every imported DLL is next to the binary or a Windows DLL
    local dir="$1" bin imports dll lower base
    local system=' kernel32 user32 gdi32 gdiplus advapi32 shell32 shlwapi ole32 oleaut32 comdlg32 comctl32 ws2_32 wsock32
 mswsock iphlpapi dnsapi winmm opengl32 glu32 imm32 version setupapi cfgmgr32 crypt32 bcrypt ncrypt secur32 sspicli
 dbghelp uxtheme dwmapi hid winhttp wininet wldap32 normaliz rpcrt4 userenv psapi ntdll powrprof xinput1_4 xinput9_1_0
 dinput8 dsound avrt mmdevapi ksuser msvcrt ucrtbase wtsapi32 msimg32 d3d9 d3d11 d3d12 dxgi shcore wintrust netapi32
 mpr usp10 dxva2 mf mfplat mfreadwrite propsys '
    system=" $(printf '%s' "$system" | tr -s '\n\t ' '   ') "
    for bin in "$dir"/*.exe "$dir"/*.dll; do
        [ -f "$bin" ] || continue
        imports=$(objdump -p "$bin" 2>/dev/null | sed -n 's/^\s*DLL Name: //p' | tr -d '\r') ||
            { bad "objdump cannot read ${bin#"$DIR"/}"; continue; }
        [ -n "$imports" ] || { bad "${bin#"$DIR"/} has no import table"; continue; }
        while IFS= read -r dll; do
            lower=$(printf '%s' "$dll" | tr 'A-Z' 'a-z'); base="${lower%.dll}"
            case "$lower" in api-ms-win-*|ext-ms-win-*) continue ;; esac
            case "$system" in *" $base "*) continue ;; esac
            ls "$dir" | tr 'A-Z' 'a-z' | grep -qxF "$lower" || bad "${bin#"$DIR"/} needs $dll, which is neither shipped next to it nor a Windows DLL"
        done <<< "$imports"
    done
}

module_set() { (cd "$1" && find . -name '*.otmod' ! -path './mods/game_bot/*' | LC_ALL=C sort); }

# --- server
pkg="$SERVER_PKG"; common_checks "$pkg"
need "$pkg" "server/pokeverse-server$X" server/config.lua server/pt_br.loc server/data/world/map.otbm \
    server/data/items/items.otb server/data/XML/vocations.xml database/schema/pokeaventuras.sql \
    database/seeds/dev_accounts.sql database/required-tables.txt
ls "$pkg"/database/migrations/*.sql > /dev/null 2>&1 || bad "$(basename "$pkg"): no database/migrations/*.sql"
grep -q 'sqlHost = "127.0.0.1"' "$pkg/server/config.lua" 2>/dev/null || bad "$(basename "$pkg"): server/config.lua does not use 127.0.0.1"
for d in client redemption-client legacy-client; do [ ! -e "$pkg/$d" ] || bad "$(basename "$pkg"): contains $d/"; done
if [ "$OS" = windows ]; then
    need "$pkg" server/required-dlls.txt server/config.example.lua scripts/PokeVerse-Tools.ps1 "Setup Database.bat" \
        "Reset Development Database.bat" "Start Server.bat" "Stop Server.bat"
    while IFS= read -r dll; do
        dll="${dll//$'\r'/}"; [ -n "$dll" ] || continue
        [ -f "$pkg/server/$dll" ] || bad "$(basename "$pkg"): server/required-dlls.txt lists $dll, which is missing"
    done < "$pkg/server/required-dlls.txt"
    [ "$CHECK_IMPORTS" = 0 ] || check_imports "$pkg/server"
else
    need "$pkg" setup-database.sh start-server.sh stop-server.sh
    if [ -f "$pkg/server/pokeverse-server" ]; then
        LD_LIBRARY_PATH="$pkg/server/lib" ldd "$pkg/server/pokeverse-server" | grep -q 'not found' &&
            bad "$(basename "$pkg"): server/pokeverse-server has unresolved libraries"
    fi
fi

# --- Redemption client
pkg="$REDEMPTION_PKG"; R="$pkg/redemption-client"; common_checks "$pkg"
need "$pkg" "redemption-client/pokeverse-client$X" redemption-client/VARIANT redemption-client/CLIENT \
    redemption-client/init.lua redemption-client/otclientrc.lua redemption-client/modules/client/client.otmod \
    redemption-client/modules/game_pokebar/pokebar.otmod redemption-client/modules/gamelib/pokeverse.lua \
    redemption-client/data/things/854/Tibia.dat redemption-client/data/things/854/Tibia.spr
[ "$(cat "$R/CLIENT" 2>/dev/null)" = redemption ] || bad "$(basename "$pkg"): redemption-client/CLIENT is not 'redemption'"
[ "$(cat "$R/VARIANT" 2>/dev/null)" = production ] || bad "$(basename "$pkg"): redemption-client/VARIANT is not 'production'"
if [ -f "$R/pokeverse-client$X" ]; then
    grep -aq Redemption "$R/pokeverse-client$X" || bad "$(basename "$pkg"): redemption-client/pokeverse-client$X is not the Redemption client"
    grep -aq Pokecenter "$R/pokeverse-client$X" && bad "$(basename "$pkg"): redemption-client/pokeverse-client$X is the legacy client"
fi
for f in pokeverse-legacy-client pokeverse-legacy-client.exe libotc_framework.so libotc_framework.dll data/things/Tibia.spr; do
    [ ! -e "$R/$f" ] || bad "$(basename "$pkg"): legacy file redemption-client/$f"
done
image_problems=$("$ROOT/tools/check_client_images.sh" "$R" 2>&1) || true
[ -z "$image_problems" ] || bad "$(basename "$pkg"): client images: $(wc -l <<< "$image_problems") problem(s), first: $(sed -n 1,3p <<< "$image_problems" | tr '\n' ';')"
[ "$(module_set "$R")" = "$(module_set "$ROOT/client-redemption")" ] ||
    bad "$(basename "$pkg"): the module set differs from client-redemption: $(diff <(module_set "$R") <(module_set "$ROOT/client-redemption") | grep '^[<>]' | head -5 | tr '\n' ' ')"
if [ "$OS" = windows ]; then
    need "$pkg" "Start Redemption Client.bat"
    [ "$CHECK_IMPORTS" = 0 ] || check_imports "$R"
else
    need "$pkg" start-redemption-client.sh
fi

# --- legacy client
pkg="$LEGACY_PKG"; L="$pkg/legacy-client"; common_checks "$pkg"
need "$pkg" "legacy-client/pokeverse-legacy-client$X" legacy-client/VARIANT legacy-client/CLIENT legacy-client/init.lua \
    legacy-client/modules/client/client.otmod legacy-client/modules/game_pokebar/pokebar.otmod \
    legacy-client/data/things/Tibia.dat legacy-client/data/things/Tibia.spr
[ "$(cat "$L/CLIENT" 2>/dev/null)" = legacy ] || bad "$(basename "$pkg"): legacy-client/CLIENT is not 'legacy'"
[ "$(cat "$L/VARIANT" 2>/dev/null)" = production ] || bad "$(basename "$pkg"): legacy-client/VARIANT is not 'production'"
[ ! -e "$L/pokeverse-client$X" ] || bad "$(basename "$pkg"): legacy-client/pokeverse-client$X has the Redemption client's name"
for b in "$L/pokeverse-legacy-client$X" "$L"/libotc_framework.*; do
    [ -f "$b" ] || { bad "$(basename "$pkg"): missing legacy-client/$(basename "$b")"; continue; }
    grep -aq Redemption "$b" && bad "$(basename "$pkg"): legacy-client/$(basename "$b") contains the Redemption client"
    grep -aq 'localhost/otclient/' "$b" && bad "$(basename "$pkg"): legacy-client/$(basename "$b") contains the legacy auto-updater"
done
grep -aqs Pokecenter "$L/pokeverse-legacy-client$X" "$L"/libotc_framework.* || bad "$(basename "$pkg"): the legacy executable has no 'Pokecenter' marker"
for f in otclientrc.lua data/things/854 modules/gamelib/pokeverse.lua mods; do
    [ ! -e "$L/$f" ] || bad "$(basename "$pkg"): Redemption file legacy-client/$f"
done
LEGACY_SRC="$ROOT/client/runtime-data"
if [ -d "$LEGACY_SRC/data" ] && [ -d "$L" ]; then
    listing() { (cd "$1" && find data modules init.lua -type f ! -name '*.log' -printf '%p %s\n' | LC_ALL=C sort); }
    if [ "$(head -c 7 "$LEGACY_SRC/data/things/Tibia.spr")" = version ]; then
        echo "note: $LEGACY_SRC/data/things/Tibia.spr is an LFS pointer here; comparing without it" >&2
        diffs=$(diff <(listing "$L" | grep -v '^data/things/Tibia.spr ') <(listing "$LEGACY_SRC" | grep -v '^data/things/Tibia.spr ') | grep '^[<>]' || true)
    else
        diffs=$(diff <(listing "$L") <(listing "$LEGACY_SRC") | grep '^[<>]' || true)
    fi
    [ -z "$diffs" ] || bad "$(basename "$pkg"): legacy-client differs from client/runtime-data ($(wc -l <<< "$diffs") lines): $(head -4 <<< "$diffs" | tr '\n' ' ')"
fi
[ "$(stat -c %s "$L/data/things/Tibia.spr" 2>/dev/null || echo 0)" -gt 1000000 ] || bad "$(basename "$pkg"): legacy-client/data/things/Tibia.spr is not the sprite file"
if [ "$OS" = windows ]; then
    need "$pkg" "Start Legacy Client.bat" legacy-client/libotc_framework.dll legacy-client/required-dlls.txt
    if [ -f "$L/required-dlls.txt" ]; then
        listed=$(tr -d '\r' < "$L/required-dlls.txt" | LC_ALL=C sort)
        shipped=$(cd "$L" && ls *.dll 2>/dev/null | LC_ALL=C sort)
        [ "$listed" = "$shipped" ] || bad "$(basename "$pkg"): legacy-client/required-dlls.txt does not list exactly the shipped DLLs"
    fi
    if command -v objdump > /dev/null; then
        for b in "$L/pokeverse-legacy-client.exe" "$L/libotc_framework.dll"; do
            [ -f "$b" ] || continue
            objdump -p "$b" | grep -qi 'DLL Name: wininet.dll' && bad "$(basename "$pkg"): $(basename "$b") imports WinINet (the legacy updater must stay compiled out)"
        done
    elif [ "$CHECK_IMPORTS" = 1 ]; then
        bad "--check-imports needs objdump"
    fi
    [ "$CHECK_IMPORTS" = 0 ] || check_imports "$L"
else
    need "$pkg" start-legacy-client.sh legacy-client/libotc_framework.so
    if [ -f "$L/pokeverse-legacy-client" ]; then
        [ -x "$L/pokeverse-legacy-client" ] || bad "$(basename "$pkg"): legacy-client/pokeverse-legacy-client is not executable"
        unresolved=$(LD_LIBRARY_PATH="$L/lib" ldd "$L/pokeverse-legacy-client" 2>&1 | grep 'not found' || true)
        [ -z "$unresolved" ] || bad "$(basename "$pkg"): unresolved libraries: $(tr -s ' \t\n' ' ' <<< "$unresolved")"
        # A library the host happens to have must still come from lib/, unless the host provides it everywhere.
        while read -r lname lpath; do
            case "$lname" in
                linux-vdso*|ld-linux*|libc.so*|libm.so*|libdl.so*|libpthread.so*|librt.so*|libresolv.so*|libutil.so*) continue ;;
                libstdc++.so*|libgcc_s.so*|libGL.so*|libGLX*|libGLdispatch*|libEGL*|libOpenGL*|libGLU*|libdrm*|libgbm*|libwayland*) continue ;;
                libX*|libxcb*|libxkb*|libasound.so*|libpulse*|libjack*) continue ;;
            esac
            case "$(readlink -f "$lpath")" in "$(readlink -f "$L")"/*) ;; *) bad "$(basename "$pkg"): $lname is not bundled in legacy-client/lib (resolved to $lpath)" ;; esac
        done < <(LD_LIBRARY_PATH="$L/lib:$L" ldd "$L/pokeverse-legacy-client" "$L/libotc_framework.so" 2>/dev/null | awk '/=> \// {print $1, $3}' | sort -u)
        for lib in "$L"/lib/*; do
            case "$(basename "$lib")" in libc.so*|libstdc++*|libGL.so*|libGLX*|libGLdispatch*|libX11*|libxcb*) bad "$(basename "$pkg"): host library bundled: lib/$(basename "$lib")" ;; esac
        done
    fi
fi

# --- comparison (Windows)
if [ "$OS" = windows ]; then
    pkg="$COMPARISON_PKG"; common_checks "$pkg"
    need "$pkg" "Setup Database.bat" "Reset Development Database.bat" "Start Server.bat" "Stop Server.bat" \
        "Start Legacy Client.bat" "Start Redemption Client.bat" "Start Both Clients.bat" scripts/PokeVerse-Tools.ps1
    for part in server database scripts:"$SERVER_PKG" redemption-client:"$REDEMPTION_PKG" legacy-client:"$LEGACY_PKG"; do
        case "$part" in *:*) sub="${part%%:*}"; src="${part#*:}" ;; *) sub="$part"; src="$SERVER_PKG" ;; esac
        if [ -d "$pkg/$sub" ] && [ -d "$src/$sub" ]; then
            diff -rq "$pkg/$sub" "$src/$sub" > /dev/null || bad "$(basename "$pkg"): $sub/ differs from $(basename "$src")/$sub/"
        else
            bad "$(basename "$pkg"): missing $sub/"
        fi
    done
    for f in "Start Legacy Client.bat" "Start Redemption Client.bat"; do
        cmp -s "$pkg/$f" "$(dirname "$pkg")/$( [ "$f" = "Start Legacy Client.bat" ] && basename "$LEGACY_PKG" || basename "$REDEMPTION_PKG")/$f" ||
            bad "$(basename "$pkg"): $f differs from the separate package's"
    done
    grep -qi 'pokeverse-server' "$pkg/Start Both Clients.bat" && bad "$(basename "$pkg"): Start Both Clients.bat must not start a server"
    [ ! -e "$pkg/client" ] || bad "$(basename "$pkg"): ambiguous client/ folder"
fi

if [ ${#problems[@]} -gt 0 ]; then
    echo "PACKAGES INVALID ($DIR):" >&2
    printf '  - %s\n' "${problems[@]}" >&2
    exit 1
fi
echo "Split $OSNAME packages valid: $(for p in "${PACKAGES[@]}"; do printf '%s ' "$(basename "$p")"; done)"
