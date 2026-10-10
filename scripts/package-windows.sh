#!/usr/bin/env bash
# Assembles the PokeVerse Windows development package.
# Runs in an MSYS2 MINGW64 shell after the server is built.
#
#   scripts/package-windows.sh <server build dir> <mariadb winx64 zip> <output dir>
#
# The package is written to <output dir>/PokeVerse-Windows-Dev/. The game client
# (client-windows/, the Redemption client) is added afterwards by the workflow's dev-client job.
set -euo pipefail

server_build=$(realpath "$1")
mariadb_zip=$(realpath "$2")
out=$(realpath -m "$3")/PokeVerse-Windows-Dev
root=$(cd "$(dirname "$0")/.." && pwd)

rm -rf "$out"
mkdir -p "$out"

# Copies the MinGW DLLs a program needs (system DLLs from C:\Windows are skipped).
copy_dlls() {
  local dest=$1; shift
  ldd "$@" | awk '{print $3}' | grep -i '^/mingw64/' | sort -u | while read -r dll; do
    cp -n "$dll" "$dest/"
  done
}

echo "== Server"
srv="$out/server-windows"
mkdir -p "$srv/logs/server" "$srv/logs/chat" "$srv/logs/bots"
cp "$server_build/pokeverse-server.exe" "$srv/"
copy_dlls "$srv" "$srv/pokeverse-server.exe"
cp -r "$root/core/server/data" "$root/core/server/config.lua" "$root/core/server/pt_br.loc" "$srv/"

echo "== Database"
db="$out/database"
mkdir -p "$db/sql"
cp "$root/core/database/00-create-database.sql" "$db/sql/"
cp "$root/core/server/schemas/mysql.sql" "$db/sql/01-base-schema.sql"
cp "$root/core/server/schemas/pokeverse-extensions.sql" "$db/sql/10-pokeverse-extensions.sql"
cp "$root/core/database/20-world-defaults.sql" "$root/core/database/30-account-tools.sql" \
   "$root/core/database/40-dev-seed.sql" "$db/sql/"

tmp=$(mktemp -d)
unzip -q "$mariadb_zip" -d "$tmp"
src=$(echo "$tmp"/mariadb-*-winx64)
mkdir -p "$db/mariadb/bin"
for f in mariadbd.exe mysqld.exe server.dll mariadb.exe mariadb-admin.exe mariadb-dump.exe mariadb-install-db.exe; do
  cp "$src/bin/$f" "$db/mariadb/bin/"
done
cp "$src"/bin/*.dll "$db/mariadb/bin/"
cp -r "$src/share" "$db/mariadb/"
rm -f "$db/mariadb/share"/*.jar
cp "$src/COPYING" "$db/mariadb/" 2>/dev/null || true
cp "$src/README.md" "$db/mariadb/" 2>/dev/null || true
rm -rf "$tmp"

echo "== Scripts"
cp -r "$root/scripts/windows-package/." "$out/"

if find "$out" -name config.local.lua | grep -q .; then
  echo "config.local.lua found in the package (it holds machine-local secrets); refusing to package." >&2
  exit 1
fi

echo "Package ready: $out"
du -sh "$out" "$srv" "$db"
