#!/usr/bin/env bash
# End-to-end test of the Linux development package as a tester would use it: extract
# PokeVerse-Linux-Dev.tar.gz outside the repository, run setup-database.sh (fresh, again, then
# --reset --yes) on a separate test database, start the server with start-server.sh, log in with
# the packaged client (Trainer, then GM Admin with the Pokemon bar), and stop the server through
# start-server.sh's Ctrl+C handler, which must save and exit cleanly. The handler is driven with
# SIGTERM: a script started in the background (as here) cannot trap SIGINT.
# Needs a running MariaDB (administrator: POKEVERSE_DB_ADMIN_USER/PASSWORD, or sudo mariadb),
# an X display (DISPLAY, e.g. Xvfb) and no server on port 7564.
# Usage: tools/test_linux_package.sh <PokeVerse-Linux-Dev.tar.gz> [log-dir]
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TARBALL="$(readlink -f "${1:?usage: $0 <PokeVerse-Linux-Dev.tar.gz> [log-dir]}")"
LOGDIR="$(mkdir -p "${2:-/tmp/linux-package-test}" && cd "${2:-/tmp/linux-package-test}" && pwd)"
export POKEVERSE_DB_NAME="${POKEVERSE_DB_NAME:-pokeverse_pkgtest}"
WORK=$(mktemp -d /tmp/pokeverse-package.XXXXXX)
PKG="$WORK/PokeVerse-Linux-Dev"
server=""

fail() { echo "FAIL: $*" >&2; exit 1; }
pass() { echo "PASS: $*"; }
cleanup() {
    [ -n "$server" ] && kill -TERM "$server" 2>/dev/null && sleep 10
    pkill -9 -f "$PKG/server/pokeverse-server" 2>/dev/null || true
    [ "${KEEP_PACKAGE_TEST:-0}" = 1 ] || { rm -rf "$WORK"; drop_test_db 2>/dev/null; }
}
trap cleanup EXIT
port_open() { (exec 3<>"/dev/tcp/127.0.0.1/$1") 2>/dev/null; }
drop_test_db() {
    if [ -n "${POKEVERSE_DB_ADMIN_USER:-}" ]; then
        MYSQL_PWD="${POKEVERSE_DB_ADMIN_PASSWORD:-}" mariadb -h"${POKEVERSE_DB_HOST:-127.0.0.1}" -u"$POKEVERSE_DB_ADMIN_USER" \
            -e "DROP DATABASE IF EXISTS \`$POKEVERSE_DB_NAME\`"
    else
        sudo mariadb -e "DROP DATABASE IF EXISTS \`$POKEVERSE_DB_NAME\`"
    fi
}
port_open 7564 && fail "a server already listens on 7564; stop it first"

[ "$POKEVERSE_DB_NAME" != pokeverse ] || fail "use a separate test database (POKEVERSE_DB_NAME)"
drop_test_db || fail "could not drop the old test database $POKEVERSE_DB_NAME"
tar -xzf "$TARBALL" -C "$WORK" || fail "could not extract $TARBALL"
for f in setup-database.sh start-server.sh start-client.sh server/pokeverse-server client/pokeverse-client; do
    [ -x "$PKG/$f" ] || fail "$f lost its executable bit in the archive"
done
pass "archive extracts with executable scripts and binaries ($WORK)"

cd "$PKG" || fail "no $PKG"
for run in fresh again; do
    ./setup-database.sh > "$LOGDIR/setup-$run.log" 2>&1 || { cat "$LOGDIR/setup-$run.log"; fail "setup-database.sh ($run) failed"; }
    grep -q "Database setup: SUCCESS" "$LOGDIR/setup-$run.log" || fail "setup-database.sh ($run) did not report SUCCESS"
done
grep -q "Creating database $POKEVERSE_DB_NAME" "$LOGDIR/setup-fresh.log" || fail "the first setup did not create the database"
grep -q "exists: keeping its data" "$LOGDIR/setup-again.log" || fail "the second setup did not keep the existing database"
pass "setup-database.sh creates $POKEVERSE_DB_NAME, and a second run keeps it"
./setup-database.sh --reset < /dev/null > "$LOGDIR/setup-reset-unconfirmed.log" 2>&1 &&
    fail "--reset without confirmation from a non-terminal was accepted"
./setup-database.sh --reset --yes > "$LOGDIR/setup-reset.log" 2>&1 || { cat "$LOGDIR/setup-reset.log"; fail "setup-database.sh --reset --yes failed"; }
grep -q "database $POKEVERSE_DB_NAME dropped" "$LOGDIR/setup-reset.log" || fail "--reset --yes did not drop the database"
pass "--reset needs confirmation; --reset --yes rebuilds the database"

./start-server.sh > "$LOGDIR/server.log" 2>&1 &
server=$!
for _ in $(seq 1 300); do
    grep -q "server Online!" "$LOGDIR/server.log" && break
    kill -0 "$server" 2>/dev/null || { tail -30 "$LOGDIR/server.log"; fail "start-server.sh exited during startup"; }
    sleep 1
done
grep -q "server Online!" "$LOGDIR/server.log" || fail "server not online after 300 s"
grep -q "Database '$POKEVERSE_DB_NAME' is reachable" "$LOGDIR/server.log" || fail "start-server.sh did not check the database"
for _ in $(seq 1 30); do port_open 7564 && port_open 8548 && break; sleep 1; done
port_open 7564 || fail "login port 7564 is not open"
port_open 8548 || fail "game port 8548 is not open"
pass "start-server.sh: database checked, map loaded, login and game ports open"

export DIST="$PKG/client"
"$ROOT/tools/smoke_redemption_login.sh" "$LOGDIR/client-trainer.log" || fail "packaged client: Trainer smoke failed"
python3 "$ROOT/tools/protocol_client.py" enter admin admin "GM Admin" \
    --say "/cb Charmander, 15, 10" --say "/cb Bulbasaur, 15, 10" > "$LOGDIR/gm-setup.log" 2>&1 ||
    fail "could not give GM Admin Pokemon"
PV_ACCOUNT=admin PV_PASSWORD=admin PV_CHARACTER="GM Admin" PV_EXPECT_POKEBAR=1 \
    "$ROOT/tools/smoke_redemption_login.sh" "$LOGDIR/client-gm.log" || fail "packaged client: GM Admin smoke failed"
pass "packaged client: character list, enter game and gameplay smoke (Trainer, GM Admin)"

kill -TERM "$server"
for _ in $(seq 1 90); do kill -0 "$server" 2>/dev/null || break; sleep 1; done
kill -0 "$server" 2>/dev/null && fail "the server did not stop within 90 s"
wait "$server"; status=$?
server=""
grep -q "Saving and shutting down" "$LOGDIR/server.log" || fail "start-server.sh did not forward the stop request"
grep -q "SAVE: Complete" "$LOGDIR/server.log" || fail "no 'SAVE: Complete' after the stop request"
[ "$status" = 0 ] || fail "start-server.sh exited with $status after the stop request"
pass "start-server.sh stop handler saves and stops the server (exit code 0)"
echo "PASS: Linux package end-to-end test complete (logs in $LOGDIR)"
