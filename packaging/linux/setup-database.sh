#!/usr/bin/env bash
# DEVELOPMENT ONLY. Create or upgrade the PokeVerse database on a local MariaDB (or MySQL) server:
# check that it answers, create the database when it is missing, import the schema, apply every
# migration in order, create or update the database user the server logs in with, install the
# development accounts, write server/config.lua and verify every table the server needs.
# Safe to run again: an existing database keeps its data. Nothing is deleted unless you pass
# --reset and confirm by typing the database name.
#
# Usage: ./setup-database.sh [--reset] [--yes] [--no-dev-accounts]
#   --reset            DROP the database first (asks you to type its name; --yes skips that)
#   --no-dev-accounts  do not install player/player and admin/admin
# Environment (defaults in brackets):
#   POKEVERSE_DB_HOST [127.0.0.1]   POKEVERSE_DB_PORT [3306]   POKEVERSE_DB_NAME [pokeverse]
#   POKEVERSE_DB_USER [pokeverse]   POKEVERSE_DB_PASSWORD [pokeverse-dev]
#   POKEVERSE_DB_ADMIN_USER / POKEVERSE_DB_ADMIN_PASSWORD: an administrator login. Without them the
#     script uses "sudo mariadb", the root login every MariaDB package sets up for the local system
#     administrator (you may be asked for your sudo password).
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
DB_DIR="$HERE/database"
CONFIG="$HERE/server/config.lua"

RESET=0; YES=0; DEV_ACCOUNTS=1
for arg in "$@"; do
    case "$arg" in
        --reset) RESET=1 ;;
        --yes) YES=1 ;;
        --no-dev-accounts) DEV_ACCOUNTS=0 ;;
        -h|--help) sed -n '2,19p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
        *) echo "Unknown option: $arg (see --help)" >&2; exit 2 ;;
    esac
done

HOST="${POKEVERSE_DB_HOST:-127.0.0.1}"
PORT="${POKEVERSE_DB_PORT:-3306}"
DB="${POKEVERSE_DB_NAME:-pokeverse}"
APP_USER="${POKEVERSE_DB_USER:-pokeverse}"
APP_PASSWORD="${POKEVERSE_DB_PASSWORD:-pokeverse-dev}"

step() { printf '==> %s\n' "$*"; }
ok() { printf 'OK: %s\n' "$*"; }
die() { printf '\nERROR: %s\n\nDatabase setup: FAILED\n' "$*" >&2; exit 1; }

[[ "$DB" =~ ^[A-Za-z0-9_]+$ ]] || die "database name '$DB' may only contain letters, digits and _"
[[ "$APP_USER" =~ ^[A-Za-z0-9_]+$ ]] || die "database user '$APP_USER' may only contain letters, digits and _"
[[ "$APP_PASSWORD" =~ ^[A-Za-z0-9._@%+=-]+$ ]] || die "the database password may only contain letters, digits and . _ @ % + = -"
[[ "$PORT" =~ ^[0-9]+$ ]] || die "port '$PORT' is not a number"
for f in "$DB_DIR/schema/pokeaventuras.sql" "$DB_DIR/seeds/dev_accounts.sql" "$DB_DIR/required-tables.txt" "$CONFIG"; do
    [ -f "$f" ] || die "missing ${f#"$HERE"/}. Extract the whole PokeVerse package again."
done

CLIENT=$(command -v mariadb || command -v mysql || true)
[ -n "$CLIENT" ] || die "no MariaDB client (mariadb or mysql) found.
Install MariaDB, for example:  sudo apt install mariadb-server   (Debian/Ubuntu)
                               sudo dnf install mariadb-server   (Fedora)
then start it:                 sudo systemctl enable --now mariadb"

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
option_file() {  # option_file <file> <user> <password>: credentials never appear on the command line
    umask 077
    printf '[client]\nhost=%s\nport=%s\nuser="%s"\npassword="%s"\n' "$HOST" "$PORT" "$2" "$3" > "$1"
}
if [ -n "${POKEVERSE_DB_ADMIN_USER:-}" ]; then
    option_file "$TMP/admin.cnf" "$POKEVERSE_DB_ADMIN_USER" "${POKEVERSE_DB_ADMIN_PASSWORD:-}"
    ADMIN=("$CLIENT" "--defaults-extra-file=$TMP/admin.cnf")
    ADMIN_NAME="$POKEVERSE_DB_ADMIN_USER@$HOST:$PORT"
elif [ "$(id -u)" = 0 ]; then
    ADMIN=("$CLIENT"); ADMIN_NAME="root (local socket)"
else
    ADMIN=(sudo "$CLIENT"); ADMIN_NAME="root through sudo (local socket)"
fi
option_file "$TMP/app.cnf" "$APP_USER" "$APP_PASSWORD"
admin_sql() { "${ADMIN[@]}" --batch --skip-column-names "$@"; }
app_sql() { "$CLIENT" "--defaults-extra-file=$TMP/app.cnf" --batch --skip-column-names "$@"; }

step "Connecting to MariaDB as $ADMIN_NAME"
version=$(admin_sql -e 'SELECT VERSION();' 2>"$TMP/err") || die "cannot connect to MariaDB: $(cat "$TMP/err")
Is the MariaDB service running?  sudo systemctl status mariadb
Other administrator login: set POKEVERSE_DB_ADMIN_USER and POKEVERSE_DB_ADMIN_PASSWORD."
ok "connected, server version $version"
case "$version" in *MariaDB*) ;; *) echo "WARNING: this is not MariaDB; PokeVerse is tested with MariaDB 10.11 only" ;; esac

if [ "$RESET" = 1 ]; then
    echo
    echo "!!! --reset DELETES the database '$DB': every account, character, Pokemon and item in it. !!!"
    if [ "$YES" != 1 ]; then
        [ -t 0 ] || die "--reset needs --yes when not run from a terminal"
        read -r -p "Type the database name ($DB) to confirm, anything else cancels: " typed
        [ "$typed" = "$DB" ] || { echo "Cancelled; nothing was changed."; exit 2; }
    fi
    step "Dropping database $DB"
    admin_sql -e "DROP DATABASE IF EXISTS \`$DB\`;" || die "could not drop $DB"
    ok "database $DB dropped"
fi

exists=$(admin_sql -e "SELECT COUNT(*) FROM information_schema.schemata WHERE schema_name = '$DB';") ||
    die "could not check for the database"
if [ "$exists" = 1 ]; then
    step "Database $DB exists: keeping its data, applying migrations and seeds only"
else
    step "Creating database $DB"
    admin_sql -e "CREATE DATABASE \`$DB\` CHARACTER SET latin1;" || die "could not create $DB"
    step "Importing database/schema/pokeaventuras.sql"
    if ! admin_sql "$DB" < "$DB_DIR/schema/pokeaventuras.sql"; then
        admin_sql -e "DROP DATABASE IF EXISTS \`$DB\`;" || true
        die "importing the schema failed; the incomplete database $DB was removed"
    fi
    ok "schema imported"
fi

step "Creating or updating database user $APP_USER for the server"
hosts=(localhost 127.0.0.1)
case "$HOST" in localhost|127.0.0.1|::1) ;; *) hosts=('%') ;; esac
sql=""
for h in "${hosts[@]}"; do
    who="'$APP_USER'@'$h'"
    sql+="CREATE USER IF NOT EXISTS $who IDENTIFIED BY '$APP_PASSWORD'; ALTER USER $who IDENTIFIED BY '$APP_PASSWORD'; GRANT ALL PRIVILEGES ON \`$DB\`.* TO $who; "
done
admin_sql -e "$sql FLUSH PRIVILEGES;" || die "could not create the database user $APP_USER"
ok "user $APP_USER@(${hosts[*]}) can use $DB"

count=0
for migration in "$DB_DIR"/migrations/*.sql; do
    [ -f "$migration" ] || continue
    step "Applying migration $(basename "$migration")"
    admin_sql "$DB" < "$migration" || die "migration $(basename "$migration") failed"
    count=$((count + 1))
done
ok "$count migration(s) applied"

if [ "$DEV_ACCOUNTS" = 1 ]; then
    step "Installing DEVELOPMENT accounts (database/seeds/dev_accounts.sql)"
    admin_sql "$DB" < "$DB_DIR/seeds/dev_accounts.sql" || die "installing the development accounts failed"
    ok "accounts player/player (Trainer) and admin/admin (GM Admin) installed"
else
    step "Development accounts skipped"
fi

step "Writing the database settings into server/config.lua"
sed -i -E \
    -e "s|^([[:space:]]*sqlType[[:space:]]*=[[:space:]]*).*|\1\"mysql\"|" \
    -e "s|^([[:space:]]*sqlHost[[:space:]]*=[[:space:]]*).*|\1\"$HOST\"|" \
    -e "s|^([[:space:]]*sqlPort[[:space:]]*=[[:space:]]*).*|\1$PORT|" \
    -e "s|^([[:space:]]*sqlUser[[:space:]]*=[[:space:]]*).*|\1\"$APP_USER\"|" \
    -e "s|^([[:space:]]*sqlPass[[:space:]]*=[[:space:]]*).*|\1\"$APP_PASSWORD\"|" \
    -e "s|^([[:space:]]*sqlDatabase[[:space:]]*=[[:space:]]*).*|\1\"$DB\"|" \
    "$CONFIG"
grep -q "^[[:space:]]*sqlDatabase[[:space:]]*=[[:space:]]*\"$DB\"" "$CONFIG" || die "could not update server/config.lua"
ok "server/config.lua uses $APP_USER@$HOST:$PORT/$DB"

step "Verifying database $DB as $APP_USER"
have=$(app_sql -e "SELECT LOWER(table_name) FROM information_schema.tables WHERE table_schema = '$DB';" 2>"$TMP/err") ||
    die "the server's database user cannot log in: $(cat "$TMP/err")"
missing=()
while IFS= read -r table; do
    table="${table%$'\r'}"
    case "$table" in ''|'#'*) continue ;; esac
    grep -qxF "$(printf '%s' "$table" | tr 'A-Z' 'a-z')" <<< "$have" || missing+=("$table")
done < "$DB_DIR/required-tables.txt"
[ ${#missing[@]} = 0 ] || die "database $DB is missing ${#missing[@]} required table(s): ${missing[*]}"
ok "every table the server needs is present ($(wc -l <<< "$have") tables)"
counts=$(app_sql "$DB" -e "SELECT (SELECT COUNT(*) FROM accounts), (SELECT COUNT(*) FROM players);")
ok "$(cut -f1 <<< "$counts") accounts, $(cut -f2 <<< "$counts") characters"

echo
if [ -x "$HERE/start-client.sh" ]; then
    echo "Database setup: SUCCESS. Next: ./start-server.sh, then ./start-client.sh"
else
    echo "Database setup: SUCCESS. Next: ./start-server.sh, then start a client."
fi
