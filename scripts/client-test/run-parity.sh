#!/usr/bin/env bash
# Client parity test (Linux): runs the same scripted session (client_selftest) on the
# legacy and the Redemption client against a throwaway server, through the packet
# recorder, and compares what they sent and what they showed.
#
#   scripts/client-test/run-parity.sh --legacy-build <dir> --redemption <otclient binary> \
#       --server <pokeverse-server binary> --out <dir> [--only legacy|redemption]
#
# <dir> for --legacy-build is a CMake build of core/client-legacy. Uses $DISPLAY when
# set, otherwise starts Xvfb on :99 (Mesa software rendering). Needs mariadb, ffmpeg,
# xdotool and python3 with PIL and numpy.
#
# Results in <out>: <client>/client.log, <client>/packets.log, <client>/shots/*.png,
# packets.diff, screenshots/report.md and summary.txt. Exit code 0 means every self-test
# step passed on both clients, the packet logs are identical and the screenshots match.
set -euo pipefail

root=$(cd "$(dirname "$0")/../.." && pwd)
tests=$root/scripts/client-test
legacy_build="" redemption="" server="" out="" only=""
while [ $# -gt 0 ]; do
  case "$1" in
    --legacy-build) legacy_build=$(realpath "$2"); shift 2 ;;
    --redemption) redemption=$(realpath "$2"); shift 2 ;;
    --server) server=$(realpath "$2"); shift 2 ;;
    --out) out=$(realpath -m "$2"); shift 2 ;;
    --only) only=$2; shift 2 ;;
    *) sed -n '2,15p' "$0" >&2; exit 1 ;;
  esac
done
[ -n "$legacy_build" ] && [ -n "$redemption" ] && [ -n "$server" ] && [ -n "$out" ] || { sed -n '2,15p' "$0" >&2; exit 1; }

LOGIN_PROXY=17564
GAME_PROXY=18548
SESSION_TIMEOUT=240
WIDTH=1280 HEIGHT=1024

rm -rf "$out"
mkdir -p "$out"
pids=()
cleanup() {
  for pid in "${pids[@]}"; do kill "$pid" 2>/dev/null || true; done
  "$tests/server.sh" stop "$out/server" || true
}
trap cleanup EXIT

if [ -z "${DISPLAY:-}" ]; then
  export DISPLAY=:99
  Xvfb "$DISPLAY" -screen 0 ${WIDTH}x${HEIGHT}x24 -nolisten tcp >"$out/xvfb.log" 2>&1 &
  pids+=($!)
  sleep 2
fi
export LIBGL_ALWAYS_SOFTWARE=1

"$tests/server.sh" start "$server" "$out/server"

"$root/scripts/assemble-legacy-linux-client.sh" --link --test --port "$LOGIN_PROXY" "$out/legacy/client" "$legacy_build"
"$root/scripts/assemble-redemption-client.sh" --link --test --port "$LOGIN_PROXY" "$out/redemption/client" "$redemption"
for c in legacy redemption; do
  cat > "$out/$c/client/modules/client_selftest/config.lua" <<'EOF'
SELFTEST = { account = 'selftest', password = 'selftest', character = 'Self Test' }
EOF
  # Animated PNGs (the login background, Pokemon pictures...) loop forever, so the
  # screenshots would catch the two clients at different frames. Both get the last
  # frame as a still image. The data folder is hard-linked to the repository: each file
  # is replaced, never written into.
  python3 - "$out/$c/client/data/images" <<'EOF'
import os, sys
from PIL import Image
for root, _, names in os.walk(sys.argv[1]):
    for name in names:
        if not name.lower().endswith(".png"):
            continue
        path = os.path.join(root, name)
        with Image.open(path) as im:
            frames = getattr(im, "n_frames", 1)
            if frames < 2:
                continue
            im.seek(frames - 1)
            still = im.convert("RGBA")
        os.remove(path)
        still.save(path)
EOF
done

# Carries out one request from the self-test: "SELFTEST <action> <arguments>".
act() {
  local dir=$1 window=$2 action arg
  read -r _ action arg <<<"$3"
  case "$action" in
    SHOT)
      sleep 0.5
      ffmpeg -loglevel error -y -f x11grab -video_size ${WIDTH}x${HEIGHT} -i "$DISPLAY" -frames:v 1 "$dir/shots/$arg.png" ;;
    KEY)
      timeout 10 xdotool windowfocus --sync "$window" key --delay 100 $arg || echo "KEY $arg failed" >&2 ;;
    TYPE)
      timeout 20 xdotool windowfocus --sync "$window" type --delay 40 "$arg" || echo "TYPE failed" >&2 ;;
    CLICK)
      read -r x y button modifier <<<"$arg"
      # --sync waits for the pointer to move, so it must not already be on the target
      timeout 10 xdotool mousemove --window "$window" --sync "$((x + 1))" "$((y + 1))" \
        mousemove --window "$window" --sync "$x" "$y" \
        ${modifier:+keydown $modifier} click "$button" ${modifier:+keyup $modifier} || echo "CLICK $arg failed" >&2 ;;
  esac
}

# Runs one client through the session. The self-test prints "SELFTEST SHOT <name>"
# and waits; the screenshot is taken here.
run_client() {
  local name=$1 userdir=$2; shift 2
  local dir=$out/$name
  mkdir -p "$dir/shots" "$userdir"
  printf 'locale: en\n' > "$userdir/config.otml"

  "$tests/server.sh" reset "$out/server"
  python3 "$tests/packet-recorder.py" record --log "$dir/packets.log" \
    --listen-login "$LOGIN_PROXY" --listen-game "$GAME_PROXY" >"$dir/recorder.out" 2>&1 &
  local recorder=$!
  pids+=("$recorder")
  sleep 1

  (cd "$dir/client" && HOME=$dir/home exec "$@") >"$dir/client.log" 2>&1 &
  local client=$!
  pids+=("$client")

  local seen=0 deadline=$((SECONDS + SESSION_TIMEOUT)) window=""
  while kill -0 "$client" 2>/dev/null && [ $SECONDS -lt $deadline ]; do
    mapfile -t actions < <(grep -o 'SELFTEST \(SHOT\|KEY\|CLICK\|TYPE\) .*' "$dir/client.log")
    while [ "$seen" -lt "${#actions[@]}" ]; do
      [ -n "$window" ] || window=$(xdotool search --onlyvisible --name . 2>/dev/null | tail -1 || true)
      act "$dir" "$window" "${actions[$seen]}"
      seen=$((seen + 1))
    done
    sleep 0.2
  done
  if kill -0 "$client" 2>/dev/null; then
    echo "$name: session timed out" >> "$dir/client.log"
    kill "$client"
    sleep 5
    kill -9 "$client" 2>/dev/null || true
  fi
  wait "$client" 2>/dev/null || true
  sleep 1
  kill "$recorder" 2>/dev/null || true
  wait "$recorder" 2>/dev/null || true
}

[ "$only" = redemption ] || run_client legacy "$out/legacy/home/.pokeverse" env LD_LIBRARY_PATH="$out/legacy/client" ./pokeverse-client
[ "$only" = legacy ] || run_client redemption "$out/redemption/user" ./otclient "--user-dir=$out/redemption/user"

status=0
{
  for c in legacy redemption; do
    echo "== $c"
    grep -o 'SELFTEST \(STEP\|DONE\).*' "$out/$c/client.log" || true
    grep -q 'SELFTEST DONE [0-9]* 0$' "$out/$c/client.log" || { echo "$c: self-test did not pass"; status=1; }
    grep -E 'ERROR|lua_|stack traceback' "$out/$c/client.log" | sed "s/^/$c: /" | head -40 || true
  done
  echo "== packets"
  python3 "$tests/packet-recorder.py" diff "$out/legacy/packets.log" "$out/redemption/packets.log" \
    --report "$out/packets.diff" | head -60 || status=1
  echo "== screenshots"
  python3 "$tests/compare-screenshots.py" "$out/legacy/shots" "$out/redemption/shots" "$out/screenshots" || status=1
} > "$out/summary.txt" 2>&1
cat "$out/summary.txt"
echo "parity: $([ "$status" = 0 ] && echo PASS || echo FAIL) (details in $out)"
exit "$status"
