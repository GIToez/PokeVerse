#!/bin/bash
# usage: go.sh <scenes.lua> [timeout] [display size scale]
set -e
pkill -9 -f /tmp/trailer/run.sh || true
pkill -9 -f /tmp/trailer/watch.sh || true
for p in $(pgrep -x otclient); do
  [ "$(readlink /proc/$p/cwd)" = /tmp/trailer-client ] && kill -9 $p
done
ss -ltn | grep -q ':7664 ' || { echo "TRAILER SERVER DOWN"; exit 1; }
cp /tmp/trailer/lib.lua /tmp/trailer-client/trailerscenes.lua
cp "$1" /tmp/trailer-client/scene.lua
cp /tmp/trailer/trailershots.lua /tmp/trailer-client/
PV_ENCRYPTION_KEY=$(grep -oP 'PV_ENCRYPTION_KEY:STRING=\K.*' /workspace/build/client-redemption/CMakeCache.txt) python3 /workspace/scripts/encrypt-client.py /tmp/trailer-client >/dev/null
tmux -f /exec-daemon/tmux.portal.conf kill-session -t trailer-client 2>/dev/null || true
rm -f /tmp/trailer/status
tmux -f /exec-daemon/tmux.portal.conf new-session -d -s trailer-client -- /tmp/trailer/run.sh ${2:-300} ${3:-:96} ${4:-3840x2160} ${5:-2}
