#!/usr/bin/env bash
# Refuse a Linux development package (tools/package_linux.sh) that is incomplete, has lost its
# executable bits, ships a Git LFS pointer instead of the sprites, has unresolved libraries, or
# contains anything that must never reach a tester (harness, smoke-test scripts, bot module,
# debug builds, sources, development credentials in code).
# Usage: tools/validate_linux_package.sh <package-dir>
set -euo pipefail
PKG="${1:?usage: $0 <package-dir>}"
[ -d "$PKG" ] || { echo "PACKAGE INVALID: $PKG does not exist" >&2; exit 1; }
problems=()
bad() { problems+=("$*"); }

for f in client/pokeverse-client client/VARIANT client/init.lua client/modules/client/client.otmod \
         client/modules/game_pokebar/pokebar.otmod client/modules/game_pokemoves/pokemoves.otmod \
         client/modules/gamelib/pokeverse.lua client/data/things/854/Tibia.dat client/data/things/854/Tibia.spr \
         server/pokeverse-server server/config.lua server/pt_br.loc server/json.lua \
         server/data/world/map.otbm server/data/items/items.otb server/data/XML/vocations.xml \
         database/schema/pokeaventuras.sql database/seeds/dev_accounts.sql database/required-tables.txt \
         setup-database.sh start-server.sh stop-server.sh start-client.sh README.txt VERSION.txt; do
    [ -e "$PKG/$f" ] || bad "missing $f"
done
ls "$PKG"/database/migrations/*.sql > /dev/null 2>&1 || bad "no database/migrations/*.sql"
if [ -d "$PKG/client" ]; then
    image_problems=$("$(dirname "$0")/check_client_images.sh" "$PKG/client") || true
    [ -z "$image_problems" ] || bad "client images: $(echo "$image_problems" | wc -l) problem(s), first: $(echo "$image_problems" | head -3 | tr '\n' ';')"
fi
for f in client/pokeverse-client server/pokeverse-server setup-database.sh start-server.sh stop-server.sh start-client.sh; do
    [ ! -e "$PKG/$f" ] || [ -x "$PKG/$f" ] || bad "$f is not executable"
done
for f in client/pokeverse-client server/pokeverse-server; do
    [ -f "$PKG/$f" ] && [ "$(head -c 4 "$PKG/$f" | od -An -tx1 | tr -d ' \n')" != 7f454c46 ] && bad "$f is not an ELF executable"
done
[ "$(cat "$PKG/client/VARIANT" 2>/dev/null)" = production ] || bad "client/VARIANT is not 'production'"
spr="$PKG/client/data/things/854/Tibia.spr"
if [ -f "$spr" ]; then
    [ "$(head -c 7 "$spr")" != version ] || bad "client Tibia.spr is a Git LFS pointer"
    [ "$(stat -c %s "$spr")" -ge 1000000 ] || bad "client Tibia.spr is only $(stat -c %s "$spr") bytes"
fi
grep -q 'sqlHost = "127.0.0.1"' "$PKG/server/config.lua" 2>/dev/null || bad "server/config.lua does not use the local database at 127.0.0.1"
grep -qE '^\s*ip\s*=\s*"127\.0\.0\.1"' "$PKG/server/config.lua" 2>/dev/null || bad "server/config.lua does not listen on 127.0.0.1"

if [ -x "$PKG/server/pokeverse-server" ]; then
    unresolved=$(LD_LIBRARY_PATH="$PKG/server/lib" ldd "$PKG/server/pokeverse-server" 2>&1 | grep 'not found' || true)
    [ -z "$unresolved" ] || bad "server libraries not found: $(echo "$unresolved" | awk '{print $1}' | tr '\n' ' ')"
    # Every library except glibc must come from server/lib, not from what the build host happens to have.
    libdir=$(cd "$PKG/server/lib" 2>/dev/null && pwd -P)
    while read -r name path; do
        case "$name" in linux-vdso*|ld-linux*|libc.so*|libm.so*|libdl.so*|libpthread.so*|librt.so*|libresolv.so*|libutil.so*) continue ;; esac
        [ -n "$libdir" ] && [ "$(dirname "$(readlink -f "$path")")" = "$libdir" ] || bad "server needs $name from the host ($path); it must be in server/lib"
    done < <(LD_LIBRARY_PATH="$libdir" ldd "$PKG/server/pokeverse-server" 2>/dev/null | awk '/=> \// {print $1, $3}')
    for lib in "$PKG"/server/lib/*.so*; do
        [ -f "$lib" ] || continue
        case "$(basename "$lib")" in libc.so*|ld-linux*|libm.so*) bad "server/lib ships glibc ($(basename "$lib"))" ;; esac
    done
fi
if [ -x "$PKG/client/pokeverse-client" ]; then
    unresolved=$(ldd "$PKG/client/pokeverse-client" 2>&1 | grep 'not found' || true)
    [ -z "$unresolved" ] || bad "client libraries not found: $(echo "$unresolved" | awk '{print $1}' | tr '\n' ' ')"
fi
for f in setup-database.sh start-server.sh stop-server.sh start-client.sh; do
    [ -f "$PKG/$f" ] && ! bash -n "$PKG/$f" 2>/dev/null && bad "$f has a shell syntax error"
done

while IFS= read -r path; do
    bad "forbidden file ${path#"$PKG"/}"
done < <(find "$PKG" \( -iname '*harness*' -o -iname '*smoke_rc*' -o -iname '*-debug*' \
    -o -iname '*.o' -o -iname '*.a' -o -iname '*.cpp' -o -iname '*.cc' -o -iname '*.c' -o -iname '*.h' -o -iname '*.hpp' \
    -o -iname 'CMakeLists.txt' -o -iname 'CMakeCache.txt' -o -iname '*.cmake' -o -iname '*.py' -o -iname '*.yml' \
    -o -iname 'protocol_client*' -o -iname '*.log' -o -iname '*.bak' -o -iname '*.exe' -o -iname '*.dll' \) -print)
while IFS= read -r path; do
    bad "unexpected shell script ${path#"$PKG"/}"
done < <(find "$PKG" -name '*.sh' ! -path "$PKG/setup-database.sh" ! -path "$PKG/start-server.sh" ! -path "$PKG/stop-server.sh" ! -path "$PKG/start-client.sh" -print)
while IFS= read -r path; do
    bad "forbidden directory ${path#"$PKG"/}"
done < <(find "$PKG" -type d \( -name game_bot -o -name .github -o -name .git -o -name CMakeFiles \) -print)
for bin in "$PKG"/client/pokeverse-client "$PKG"/server/pokeverse-server; do
    [ -f "$bin" ] || continue
    grep -aq "HARNESS - NOT FOR DISTRIBUTION\|HARNESS BUILD" "$bin" && bad "$(basename "$bin") contains harness markers"
done
markers='\[pv-smoke\]|PV_EXPECT_POKEBAR|PV_ACCOUNT|PV_PASSWORD|redemption_smoke_rc|TEST_AUTOMATION_ENABLED|BOT_PROTECTION_DISABLED|pv_harness'
while IFS= read -r path; do
    bad "test automation marker in ${path#"$PKG"/}"
done < <(grep -rlIE --include='*.lua' --include='*.otml' --include='*.otmod' --include='*.otui' --include='*.sh' \
    --include='*.txt' --include='*.xml' "$markers" "$PKG" 2>/dev/null || true)
while IFS= read -r path; do
    bad "development account credentials in ${path#"$PKG"/}"
done < <(grep -rlIE "SHA1\('(player|admin)'\)|(account|password)[\"' ]*[=:][ ]*[\"'](player|admin)[\"']" \
    "$PKG/client" "$PKG/server" 2>/dev/null || true)

if [ ${#problems[@]} -gt 0 ]; then
    echo "PACKAGE INVALID: $PKG" >&2
    printf '  - %s\n' "${problems[@]}" >&2
    exit 1
fi
echo "Linux development package valid: $PKG"
