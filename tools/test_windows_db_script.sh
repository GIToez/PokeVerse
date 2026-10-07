#!/usr/bin/env bash
# Run packaging/windows/scripts/PokeVerse-Tools.ps1 (the database part of the Windows test
# package) with PowerShell 7 against a real MariaDB: setup, re-run, verify, SQL error on a
# broken migration, failed first import cleanup, cancelled and forced reset.
# Needs pwsh, the mariadb client, and an administrator account reachable over TCP.
# Env: PV_DB_ADMIN_USER / PV_DB_ADMIN_PASSWORD (default root / root), PWSH (default pwsh),
#      POKEVERSE_MYSQL (default: mariadb on PATH).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PWSH="${PWSH:-pwsh}"
export POKEVERSE_MYSQL="${POKEVERSE_MYSQL:-$(command -v mariadb || command -v mysql)}"
ADMIN_USER="${PV_DB_ADMIN_USER:-root}"
ADMIN_PASSWORD="${PV_DB_ADMIN_PASSWORD:-root}"
DB=pv_pkg_test
APP_PASSWORD='dev"pw\1'
WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT

layout() {
    local dir="$1"
    mkdir -p "$dir"/{scripts,server,database/schema,database/migrations,database/seeds}
    cp "$ROOT/packaging/windows/scripts/PokeVerse-Tools.ps1" "$dir/scripts/"
    cp "$ROOT/database/pokeaventuras.sql" "$dir/database/schema/"
    cp "$ROOT"/database/migrations/*.sql "$dir/database/migrations/"
    cp "$ROOT/database/seeds/dev_accounts.sql" "$dir/database/seeds/"
    python3 "$ROOT/tools/check_db_tables.py" --print-required > "$dir/database/required-tables.txt"
    sed 's/^\(\s*sqlHost\s*=\s*\)"localhost"/\1"127.0.0.1"/' "$ROOT/server/runtime-data/config.lua" > "$dir/server/config.example.lua"
}
tool() { local dir="$1"; shift; "$PWSH" -NoProfile -File "$dir/scripts/PokeVerse-Tools.ps1" "$@"; }
base=(-NonInteractive -AdminUser "$ADMIN_USER" -AdminPassword "$ADMIN_PASSWORD" -AppUser pv_pkg_user -AppPassword "$APP_PASSWORD")
common=("${base[@]}" -Database "$DB")
step() { echo; echo "=== $*"; }
fail() { echo "FAIL: $*" >&2; exit 1; }

layout "$WORK/pkg"
tool "$WORK/pkg" -Action Reset -Force "${common[@]}" -DevSeed No > /dev/null 2>&1 || true

step "setup on a fresh database"
tool "$WORK/pkg" -Action Setup "${common[@]}" -DevSeed Yes || fail "setup failed"
grep -q 'sqlUser = "pv_pkg_user"' "$WORK/pkg/server/config.lua" || fail "config.lua sqlUser not written"
grep -qF 'sqlPass = "dev\"pw\\1"' "$WORK/pkg/server/config.lua" || fail "config.lua sqlPass not escaped"

step "verify with the credentials in config.lua"
tool "$WORK/pkg" -Action Verify || fail "verify failed"

step "setup again keeps the data"
tool "$WORK/pkg" -Action Setup "${common[@]}" -DevSeed Yes | tee "$WORK/rerun.log"
grep -q "exists: applying migrations" "$WORK/rerun.log" || fail "re-run did not detect the existing database"

step "a broken migration stops the setup"
cp -a "$WORK/pkg" "$WORK/broken"
echo 'ALTER TABLE no_such_table ADD COLUMN x int;' > "$WORK/broken/database/migrations/999_broken.sql"
if tool "$WORK/broken" -Action Setup "${common[@]}" -DevSeed No > "$WORK/broken.log" 2>&1; then
    cat "$WORK/broken.log"; fail "broken migration was ignored"
fi
grep -q "no_such_table" "$WORK/broken.log" || fail "the SQL error was not reported"

step "a broken schema on a fresh database is removed again"
echo 'THIS IS NOT SQL;' > "$WORK/broken/database/schema/pokeaventuras.sql"
if tool "$WORK/broken" -Action Setup "${base[@]}" -Database pv_pkg_broken -DevSeed No > "$WORK/broken2.log" 2>&1; then
    fail "broken schema was ignored"
fi
grep -q "incomplete database pv_pkg_broken was removed" "$WORK/broken2.log" || { cat "$WORK/broken2.log"; fail "no cleanup message"; }

step "verify fails on a missing table"
"$POKEVERSE_MYSQL" -h127.0.0.1 -u"$ADMIN_USER" -p"$ADMIN_PASSWORD" "$DB" -e 'RENAME TABLE market_items TO market_items_gone'
if tool "$WORK/pkg" -Action Verify > "$WORK/verify.log" 2>&1; then fail "verify passed without market_items"; fi
grep -q "market_items" "$WORK/verify.log" || fail "missing table not named"

step "reset without confirmation is refused, forced reset rebuilds"
if tool "$WORK/pkg" -Action Reset "${common[@]}" > /dev/null 2>&1; then fail "non-interactive reset ran without -Force"; fi
echo nope | "$PWSH" -NoProfile -File "$WORK/pkg/scripts/PokeVerse-Tools.ps1" -Action Reset -DbHost 127.0.0.1 -DbPort 3306 \
    -AdminUser "$ADMIN_USER" -AdminPassword "$ADMIN_PASSWORD" -Database "$DB" -AppUser pv_pkg_user -AppPassword x -DevSeed No > /dev/null 2>&1 &&
    fail "reset ran after a wrong confirmation" || [ $? = 2 ] || fail "cancelled reset did not exit with 2"
tool "$WORK/pkg" -Action Reset -Force "${common[@]}" -DevSeed Yes || fail "forced reset failed"
tool "$WORK/pkg" -Action Verify || fail "verify after reset failed"

"$POKEVERSE_MYSQL" -h127.0.0.1 -u"$ADMIN_USER" -p"$ADMIN_PASSWORD" -e "DROP DATABASE IF EXISTS $DB; DROP USER IF EXISTS 'pv_pkg_user'@'localhost', 'pv_pkg_user'@'127.0.0.1';"
echo
echo "Windows database script: PASS"
