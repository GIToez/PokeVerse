#!/usr/bin/env bash
# Assembles the Linux live server release (builds/live/server-linux/).
#
#   scripts/live/package-linux-server.sh <server build dir> <output dir> <release id>
#
# Writes <output dir>/pokeverse-server-linux/ and <output dir>/pokeverse-server-linux.tar.gz.
# The package holds no secrets: config.local.lua and the database password live only on the
# server (created by bootstrap-ovh.sh).
set -euo pipefail

build=$(realpath "$1")
out=$(realpath -m "$2")
release=$3
root=$(cd "$(dirname "$0")/../.." && pwd)
[[ "$release" =~ ^[A-Za-z0-9._-]+$ ]] || { echo "invalid release id: $release" >&2; exit 1; }

pkg=$out/pokeverse-server-linux
rm -rf "$pkg" "$out/pokeverse-server-linux.tar.gz"
mkdir -p "$pkg/sql" "$pkg/tools/systemd"

cp "$build/pokeverse-server" "$pkg/"
strip --strip-debug "$pkg/pokeverse-server" 2>/dev/null || true
cp -r "$root/core/server/data" "$root/core/server/config.lua" "$root/core/server/pt_br.loc" "$pkg/"
[ "$(stat -c %s "$pkg/data/world/map.otbm")" -gt 1000000 ] || { echo "data/world/map.otbm is a Git LFS pointer; check out with lfs: true" >&2; exit 1; }

cp "$root/core/server/schemas/mysql.sql" "$pkg/sql/01-base-schema.sql"
cp "$root/core/server/schemas/pokeverse-extensions.sql" "$pkg/sql/10-pokeverse-extensions.sql"
cp "$root/core/database/20-world-defaults.sql" "$root/core/database/30-account-tools.sql" "$pkg/sql/"

cp "$root/scripts/live/pokeverse-ctl" "$root/scripts/live/bootstrap-ovh.sh" \
   "$root/scripts/protocol-test.py" "$root/scripts/account-test.py" "$pkg/tools/"
cp "$root/scripts/live/systemd/"* "$pkg/tools/systemd/"
chmod +x "$pkg/pokeverse-server" "$pkg/tools/pokeverse-ctl" "$pkg/tools/bootstrap-ovh.sh"

cat > "$pkg/RELEASE" <<EOF
release=$release
commit=$(git -C "$root" rev-parse HEAD 2>/dev/null || echo unknown)
built=$(date -u +%Y-%m-%dT%H:%M:%SZ)
EOF

if find "$pkg" -name config.local.lua -o -name '.env*' -o -name '*.pem' | grep -q .; then
  echo "secret-looking files found in the package; refusing to package" >&2
  exit 1
fi

tar -C "$out" -czf "$out/pokeverse-server-linux.tar.gz" pokeverse-server-linux
echo "Package ready: $out/pokeverse-server-linux.tar.gz ($release)"
du -sh "$pkg" "$out/pokeverse-server-linux.tar.gz"
