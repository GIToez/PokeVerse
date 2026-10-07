#!/usr/bin/env bash
# Server startup smoke test: start the source-built server (dist/server) against the
# local dev database, wait until it reports "server Online!", fail on any startup
# error line, then shut it down. Needs the database from tools/setup_dev_db.sh.
# Usage: tools/smoke_server.sh [log-file]   KEEP_RUNNING=1 leaves the server up.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
LOG="${1:-/tmp/smoke_server.log}"
TIMEOUT="${TIMEOUT:-300}"

"$ROOT/tools/run_server.sh" > "$LOG" 2>&1 &
server=$!
# MSYS2 cannot deliver signals to the native Windows server process.
case "$(uname -s)" in
    MINGW*|MSYS*) stop() { taskkill //F //IM pokeverse-server.exe > /dev/null 2>&1 || true; wait "$server" 2>/dev/null || true; } ;;
    *) stop() { kill -INT "$server" 2>/dev/null && wait "$server" 2>/dev/null || true; } ;;
esac
[ "${KEEP_RUNNING:-0}" = 1 ] || trap stop EXIT

for _ in $(seq 1 "$TIMEOUT"); do
    grep -q "server Online!" "$LOG" && break
    kill -0 "$server" 2>/dev/null || { echo "FAIL: server exited during startup" >&2; tail -20 "$LOG" >&2; exit 1; }
    sleep 1
done
grep -q "server Online!" "$LOG" || { echo "FAIL: server not online after ${TIMEOUT}s" >&2; tail -20 "$LOG" >&2; exit 1; }

# libmariadb reports its own 3.x client version, which TFS 0.3.6 calls "outdated".
problems=$(grep -n -i -E "error|warning|cannot|failed|not found" "$LOG" \
    | grep -v "Outdated MySQL server detected" || true)
if [ -n "$problems" ]; then
    echo "FAIL: startup log has problems:" >&2
    echo "$problems" >&2
    exit 1
fi
echo "PASS: server online with a clean startup log ($LOG)"
