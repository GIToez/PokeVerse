#!/usr/bin/env bash
# DEVELOPMENT ONLY. (Re)create the local `pokeverse` MariaDB database used by
# server/runtime-data/config.lua: imported dump + migrations + dev accounts.
# Usage: tools/setup_dev_db.sh [--reset]   (MYSQL="sudo mariadb" by default)
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
MYSQL="${MYSQL:-sudo mariadb}"
DB=pokeverse

if [ "${1:-}" = "--reset" ]; then
    $MYSQL -e "DROP DATABASE IF EXISTS \`$DB\`"
fi
if $MYSQL -N -e "SHOW DATABASES LIKE '$DB'" | grep -qx "$DB"; then
    echo "Database $DB exists; applying migrations and seeds only (use --reset to rebuild)"
else
    $MYSQL -e "CREATE DATABASE \`$DB\` CHARACTER SET latin1"
    $MYSQL "$DB" < "$ROOT/database/pokeaventuras.sql"
fi
$MYSQL -e "CREATE USER IF NOT EXISTS 'pokeverse'@'localhost' IDENTIFIED BY 'pokeverse-dev';
           GRANT ALL ON \`$DB\`.* TO 'pokeverse'@'localhost';"
for migration in "$ROOT"/database/migrations/*.sql; do
    echo "Applying $(basename "$migration")"
    $MYSQL "$DB" < "$migration"
done
$MYSQL "$DB" < "$ROOT/database/seeds/dev_accounts.sql"
python3 "$ROOT/tools/check_db_tables.py" --database "$DB" --mysql "$MYSQL"
