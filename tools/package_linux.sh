#!/usr/bin/env bash
# Assemble the Linux development package PokeVerse-Linux-Dev (docs/DOWNLOAD_AND_RUN.md) and
# pack it as <out-dir>/PokeVerse-Linux-Dev.tar.gz (the archive keeps the executable bits):
#   client/    pokeverse-client + Redemption runtime files + PokeVerse 854 SPR/DAT
#   server/    pokeverse-server + server/lib (every shared library except glibc) + data + config.lua
#   database/  schema, migrations, development seed, required-tables.txt
#   setup-database.sh, start-server.sh, start-client.sh, README.txt (packaging/linux), VERSION.txt
# then runs tools/validate_linux_package.sh on the folder.
# Inputs: a staged Linux Release client (tools/stage_redemption.sh release) and a Linux server
# build (tools/build_server.sh).
# Usage: tools/package_linux.sh [client-dist] [server-dist] [out-dir]
# Environment: POKEVERSE_VERSION (default dev) is written to VERSION.txt.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CLIENT="${1:-$ROOT/dist/client-redemption}"
SERVER="${2:-$ROOT/dist/server}"
OUTDIR="${3:-$ROOT/dist/linux}"
OUT="$OUTDIR/PokeVerse-Linux-Dev"
VERSION="${POKEVERSE_VERSION:-dev}"
TEMPLATES="$ROOT/packaging/linux"
RUNTIME="$ROOT/server/runtime-data"

fail() { echo "PACKAGING REFUSED: $*" >&2; exit 1; }
[ -x "$CLIENT/pokeverse-client" ] || fail "no $CLIENT/pokeverse-client (Linux Release client, tools/stage_redemption.sh release)"
[ "$(cat "$CLIENT/VARIANT" 2>/dev/null)" = production ] || fail "$CLIENT/VARIANT is not production"
[ -x "$SERVER/pokeverse-server" ] || fail "no $SERVER/pokeverse-server (Linux server build, tools/build_server.sh)"

rm -rf "$OUT" "$OUTDIR/PokeVerse-Linux-Dev.tar.gz"
mkdir -p "$OUT/client" "$OUT/server/lib" "$OUT/database/schema" "$OUT/database/migrations" "$OUT/database/seeds"

# Client: the staged Release client without logs, the user rc file or upstream source files.
(cd "$CLIENT" && find . -mindepth 1 -maxdepth 1) | while read -r entry; do
    name="${entry#./}"
    case "$name" in *.log|otclientrc.lua) continue ;; esac
    cp -aL "$CLIENT/$name" "$OUT/client/$name"
done
cp "$ROOT/client-redemption/otclientrc.lua" "$OUT/client/otclientrc.lua"
find "$OUT/client" -name '*.log' -delete
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
strip --strip-debug "$OUT/client/pokeverse-client" 2>/dev/null || true

# Server: the stripped executable and every shared library it loads except the C library
# itself (glibc must come from the host), so no -dev or runtime packages are needed.
install -m 0755 "$SERVER/pokeverse-server" "$OUT/server/pokeverse-server"
strip --strip-debug "$OUT/server/pokeverse-server"
ldd "$SERVER/pokeverse-server" | awk '/=> \// {print $1, $3}' | while read -r name path; do
    case "$name" in
        linux-vdso*|ld-linux*|libc.so*|libm.so*|libdl.so*|libpthread.so*|librt.so*|libresolv.so*|libutil.so*) continue ;;
    esac
    install -m 0644 "$(readlink -f "$path")" "$OUT/server/lib/$name"
done
ldd "$SERVER/pokeverse-server" | grep -q 'not found' && fail "the server build has unresolved libraries"
tar -C "$RUNTIME" --exclude='*.bak' --exclude='.idea' --exclude='.gitkeep' --exclude='*.log' -cf - data | tar -C "$OUT/server" -xf -
cp "$RUNTIME/pt_br.loc" "$RUNTIME/json.lua" "$OUT/server/"
{
    echo '-- PokeVerse server configuration for the Linux development package.'
    echo '-- ./setup-database.sh writes the database settings (sql*) into this file.'
    echo '-- DEVELOPMENT ONLY: the server listens on 127.0.0.1; never expose it to a network.'
    echo
    sed 's/^\(\s*sqlHost\s*=\s*\)"localhost"/\1"127.0.0.1"/' "$RUNTIME/config.lua"
} > "$OUT/server/config.lua"
grep -q 'sqlHost = "127.0.0.1"' "$OUT/server/config.lua" || fail "could not set sqlHost in config.lua"

# Database
cp "$ROOT/database/pokeaventuras.sql" "$OUT/database/schema/"
cp "$ROOT"/database/migrations/*.sql "$OUT/database/migrations/"
cp "$ROOT/database/seeds/dev_accounts.sql" "$OUT/database/seeds/"
{
    echo '# Tables the server code uses (tools/check_db_tables.py --print-required).'
    echo '# setup-database.sh fails when one is missing.'
    python3 "$ROOT/tools/check_db_tables.py" --print-required
} > "$OUT/database/required-tables.txt"

# Launchers and instructions
for f in setup-database.sh start-server.sh start-client.sh; do install -m 0755 "$TEMPLATES/$f" "$OUT/$f"; done
install -m 0644 "$TEMPLATES/README.txt" "$OUT/README.txt"
glibc=$(objdump -T "$OUT/server/pokeverse-server" "$OUT/client/pokeverse-client" "$OUT"/server/lib/*.so* 2>/dev/null |
    grep -o 'GLIBC_[0-9.]*' | sort -uV | tail -1)
{
    echo 'PokeVerse Linux development package'
    echo "version  $VERSION"
    echo "commit   $(git -C "$ROOT" rev-parse HEAD 2>/dev/null || echo unknown)"
    echo "built    $(date -u +%Y-%m-%dT%H:%M:%SZ) on $(. /etc/os-release && echo "$PRETTY_NAME")"
    echo "needs    ${glibc:-glibc} or newer on the host"
    echo 'client   Redemption (client-redemption), Release, VARIANT=production'
    echo 'server   TFS 0.3.6 PokeVerse (server/source), GCC'
} > "$OUT/VERSION.txt"

"$ROOT/tools/validate_linux_package.sh" "$OUT"
tar -C "$OUTDIR" --owner=0 --group=0 --numeric-owner -czf "$OUTDIR/PokeVerse-Linux-Dev.tar.gz" PokeVerse-Linux-Dev
echo "Linux development package: $OUTDIR/PokeVerse-Linux-Dev.tar.gz ($(du -h "$OUTDIR/PokeVerse-Linux-Dev.tar.gz" | cut -f1)), needs ${glibc:-glibc}"
