#!/usr/bin/env bash
# Full server test on Linux: fresh MariaDB on 127.0.0.1:3307, database setup,
# server start, protocol tests (login, character list, game login, movement)
# and database checks. Used locally and in CI.
#
# Usage: scripts/test-server-linux.sh <path-to-pokeverse-server-binary>
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
binary="$(realpath "$1")"
work="$(mktemp -d)"
db="mariadb --no-defaults --protocol=tcp -h127.0.0.1 -P3307"
server_pid=""
db_pid=""

stop_process() {
  kill "$1" 2>/dev/null || return 0
  for _ in $(seq 30); do kill -0 "$1" 2>/dev/null || return 0; sleep 1; done
  kill -9 "$1" 2>/dev/null || true
}

cleanup() {
  if [ -n "$server_pid" ]; then
    kill -INT "$server_pid" 2>/dev/null || true
    for _ in $(seq 30); do kill -0 "$server_pid" 2>/dev/null || break; sleep 1; done
    kill -9 "$server_pid" 2>/dev/null || true
    wait "$server_pid" 2>/dev/null || true
  fi
  [ -n "$db_pid" ] && stop_process "$db_pid"
  if [ "${KEEP_WORK:-0}" != 1 ]; then rm -rf "$work"; else echo "Work directory kept: $work"; fi
}
trap cleanup EXIT

step() { echo; echo "=== $*"; }

step "Starting MariaDB on 127.0.0.1:3307"
mariadb-install-db --no-defaults --datadir="$work/db" --auth-root-authentication-method=normal >"$work/db-install.log" 2>&1
mariadbd --no-defaults --datadir="$work/db" --port=3307 --bind-address=127.0.0.1 \
  --socket="$work/db.sock" --log-error="$work/db-error.log" --pid-file="$work/db.pid" &
db_pid=$!
for _ in $(seq 60); do $db -uroot -e "SELECT 1" >/dev/null 2>&1 && break; sleep 1; done
$db -uroot -e "SELECT VERSION()"

step "Setting up the database"
$db -uroot < "$root/core/database/00-create-database.sql"
$db -upokeverse -ppokeverse pokeverse < "$root/core/server/schemas/mysql.sql"
for f in "$root/core/server/schemas/pokeverse-extensions.sql" "$root/core/database/20-world-defaults.sql" \
         "$root/core/database/30-account-tools.sql" "$root/core/database/40-dev-seed.sql"; do
  $db -upokeverse -ppokeverse pokeverse < "$f"
done
echo "Re-applying the idempotent scripts (must not fail)"
for f in "$root/core/server/schemas/pokeverse-extensions.sql" "$root/core/database/20-world-defaults.sql" \
         "$root/core/database/30-account-tools.sql" "$root/core/database/40-dev-seed.sql"; do
  $db -upokeverse -ppokeverse pokeverse < "$f" >/dev/null
done
$db -upokeverse -ppokeverse pokeverse -e "CALL pokeverse_create_account('newuser', 'secret'); CALL pokeverse_create_character('newuser', 'New Trainer', 0); CALL pokeverse_create_character('newuser', 'Bag Trainer', 1);"
echo "Bag Trainer gets the old item layout (bag in the hidden slot 3, no duel icon) to test the login repair"
$db -upokeverse -ppokeverse pokeverse -e "DELETE i FROM player_items i JOIN players p ON p.id = i.player_id WHERE p.name = 'Bag Trainer' AND i.pid = 3;
  UPDATE player_items i JOIN players p ON p.id = i.player_id SET i.pid = 3 WHERE p.name = 'Bag Trainer' AND i.pid = 10;"
# Characters used only by the Discord bridge test (each logs in once per run).
$db -upokeverse -ppokeverse pokeverse -e "CALL pokeverse_create_account('bridgetrainer', 'secret'); CALL pokeverse_create_character('bridgetrainer', 'Bridge Trainer', 0); CALL pokeverse_create_account('bridgestaff', 'secret'); CALL pokeverse_create_character('bridgestaff', 'Bridge Staff', 0); CALL pokeverse_set_group('Bridge Staff', 6); CALL pokeverse_create_account('bridgelink', 'secret'); CALL pokeverse_create_character('bridgelink', 'Link Alpha', 0); CALL pokeverse_create_character('bridgelink', 'Link Beta', 1);"
tables=$($db -upokeverse -ppokeverse -N pokeverse -e "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='pokeverse'")
echo "Tables: $tables"

step "Starting the server"
mkdir -p "$work/server/logs/server" "$work/server/logs/chat" "$work/server/logs/bots"
cp -r "$root/core/server/data" "$root/core/server/config.lua" "$root/core/server/pt_br.loc" "$work/server/"
cp "$binary" "$work/server/"
# Discord bridge enabled through the machine-local override file, plus the test-only
# /bridgetest talkaction (scripts/testing/) used to drive real catches and spawns.
bridge_secret="ci-bridge-secret-$(date +%s)-$RANDOM"
cat > "$work/server/config.local.lua" <<LUA
discordBridgeEnabled = true
discordBridgeSecret = "$bridge_secret"
discordBridgeLinkCodeLifetime = 8
LUA
cp "$root/scripts/testing/discord-bridge-test-talkaction.lua" "$work/server/data/talkactions/scripts/bridgetest.lua"
sed -i 's#</talkactions>#\t<talkaction words="/bridgetest" event="script" value="bridgetest.lua"/>\n</talkactions>#' \
  "$work/server/data/talkactions/talkactions.xml"
(cd "$work/server" && exec "./$(basename "$binary")" >"$work/server.log" 2>&1) &
server_pid=$!
for _ in $(seq 180); do
  grep -q "server Online!" "$work/server.log" 2>/dev/null && break
  kill -0 "$server_pid" 2>/dev/null || { tail -50 "$work/server.log"; echo "FAIL: server exited during startup"; exit 1; }
  sleep 1
done
grep -q "server Online!" "$work/server.log" || { tail -50 "$work/server.log"; echo "FAIL: server did not start"; exit 1; }
grep -E "Global address|Local ports|server Online" "$work/server.log"
grep -q "Global address: 127.0.0.1" "$work/server.log" || { echo "FAIL: server is not bound to 127.0.0.1"; exit 1; }
grep -q "Discord bridge listening on 127.0.0.1:7199" "$work/server.log" || { echo "FAIL: Discord bridge did not start"; exit 1; }

step "Protocol tests"
python3 "$root/scripts/protocol-test.py" --account test --password wrong --character Trainer --expect-login-failure
python3 "$root/scripts/protocol-test.py" --account test --password test --character Trainer --walk east,east,south,west
python3 "$root/scripts/protocol-test.py" --account admin --password admin --character Admin --walk west,north --say "/i 12157, 100"
python3 "$root/scripts/protocol-test.py" --account newuser --password secret --character "New Trainer" --walk east,south --quest-log
python3 "$root/scripts/protocol-test.py" --account newuser --password secret --character "Bag Trainer" --walk east,south
sleep 3

step "Discord bridge tests"
python3 "$root/scripts/discord-bridge-test.py" --secret "$bridge_secret" --catch-test \
  --listener "bridgetrainer:secret:Bridge Trainer" --speaker "bridgestaff:secret:Bridge Staff" --staff-character "Bridge Staff" \
  --link-test --linker "bridgelink:secret:Link Alpha:Link Beta" --code-lifetime 8
lua5.1 "$root/scripts/test-lua-json.lua"
sleep 3

step "Database checks"
$db -upokeverse -ppokeverse pokeverse -e "SELECT name, level, posx, posy, posz, lastlogin > 0 AS has_logged_in, online FROM players WHERE id > 1"
moved=$($db -upokeverse -ppokeverse -N pokeverse -e "SELECT COUNT(*) FROM players WHERE name IN ('Trainer','Admin','New Trainer') AND lastlogin > 0 AND NOT (posx = 5000 AND posy = 806)")
[ "$moved" = 3 ] || { echo "FAIL: expected 3 characters saved at a new position, got $moved"; exit 1; }
dex=$($db -upokeverse -ppokeverse -N pokeverse -e "SELECT COUNT(*) FROM player_items i JOIN players p ON p.id = i.player_id WHERE p.name = 'New Trainer' AND i.pid = 6 AND i.itemtype = 12281")
[ "$dex" = 1 ] || { echo "FAIL: New Trainer lost the Pokedex"; exit 1; }
start=$($db -upokeverse -ppokeverse -N pokeverse -e "SELECT CONCAT(p.town_id, ',', p.level) FROM players p WHERE p.name = 'New Trainer'")
[ "$start" = "34,5" ] || { echo "FAIL: New Trainer should be in the tutorial (town 34) at level 5, got $start"; exit 1; }
item_query() {
  $db -upokeverse -ppokeverse -N pokeverse -e "SELECT $2 FROM player_items i JOIN players p ON p.id = i.player_id
    LEFT JOIN player_items c ON c.player_id = i.player_id AND c.sid = i.pid WHERE p.name = '$1' $3"
}
equipped() { item_query "$1" "GROUP_CONCAT(CONCAT(i.pid, ':', i.itemtype) ORDER BY i.pid SEPARATOR ' ')" "AND i.pid <= 10"; }
inside() { item_query "$1" "COUNT(*)" "AND c.pid = $2 AND i.itemtype IN ($3)"; }
kit=$(equipped "New Trainer")
echo "New Trainer equipped: $kit"
[ "$kit" = "1:13206 2:13204 3:13016 4:30151 5:12280 6:12281 10:12282" ] || { echo "FAIL: New Trainer starting kit is wrong"; exit 1; }
skills=$($db -upokeverse -ppokeverse -N pokeverse -e "SELECT GROUP_CONCAT(CONCAT(s.skillid, ':', s.value) ORDER BY s.skillid SEPARATOR ' ') FROM player_skills s JOIN players p ON p.id = s.player_id WHERE p.name = 'New Trainer'")
echo "New Trainer skills: $skills"
[ "$skills" = "0:0 1:0 2:0 3:0 4:0 5:10 6:0" ] || { echo "FAIL: trainer skills should start at 0 (catching at 10)"; exit 1; }
[ "$(inside "New Trainer" 5 "12214,12216,12218,12220,12222,12224,12226,12228")" = 8 ] || { echo "FAIL: badge case should hold the 8 badge slots"; exit 1; }
[ "$(inside "New Trainer" 10 13820)" = 1 ] || { echo "FAIL: starter cookies are not in the bag"; exit 1; }
[ "$(inside "Admin" 10 12157)" = 1 ] || { echo "FAIL: items created for Admin did not go into the bag"; item_query Admin "i.pid, i.sid, i.itemtype, i.count" ""; exit 1; }
kit=$(equipped "Bag Trainer")
echo "Bag Trainer equipped after login: $kit"
case " $kit " in *" 10:12282 "*) ;; *) echo "FAIL: Bag Trainer's bag was not moved to slot 10"; exit 1;; esac

links=$($db -upokeverse -ppokeverse -N pokeverse -e "SELECT COUNT(*) FROM discord_account_links")
[ "$links" = 0 ] || { echo "FAIL: the bridge test should leave no Discord links, found $links"; exit 1; }
deleted=$($db -upokeverse -ppokeverse -N pokeverse -e "SELECT deleted FROM players WHERE name = 'Link Beta'")
[ "$deleted" = 1 ] || { echo "FAIL: Link Beta should be soft-deleted by the bridge test"; exit 1; }

step "Account service tests"
python3 "$root/scripts/account-test.py"
testers=$($db -upokeverse -ppokeverse -N pokeverse -e "SELECT CONCAT(SUM(deleted = 0), ',', SUM(deleted = 1), ',', SUM(name LIKE '%~%')) FROM players WHERE name LIKE 'Tester %'")
[ "$testers" = "0,3,2" ] || { echo "FAIL: a name deleted three times should leave 3 deleted rows, 2 renamed (live,deleted,renamed: $testers)"; exit 1; }

step "Reused character names"
$db -upokeverse -ppokeverse pokeverse -e "CALL pokeverse_create_character('newuser', 'Reuse Trainer', 0);
  UPDATE players SET deleted = 1 WHERE name = 'Reuse Trainer';
  CALL pokeverse_create_character('newuser', 'Reuse Trainer', 1);
  CALL pokeverse_set_group('Reuse Trainer', 4);" >/dev/null
groups=$($db -upokeverse -ppokeverse -N pokeverse -e "SELECT GROUP_CONCAT(CONCAT(deleted, ':', group_id) ORDER BY deleted SEPARATOR ' ') FROM players WHERE name = 'Reuse Trainer'")
[ "$groups" = "0:4 1:1" ] || { echo "FAIL: set_group should change only the live 'Reuse Trainer' (deleted:group = $groups)"; exit 1; }
echo "Reused name: $groups"

step "Daily tasks"
sql() { $db -upokeverse -ppokeverse -N pokeverse -e "$1"; }
tasks_of() { sql "SELECT d.data FROM player_daily_tasks d JOIN players p ON p.id = d.player_id WHERE p.name = '$1'"; }
picked=$(sql "SELECT COUNT(*) FROM player_daily_tasks d JOIN players p ON p.id = d.player_id WHERE p.name = 'Trainer' AND d.day = '$(date +%F)'")
[ "$picked" = 1 ] || { echo "FAIL: Trainer got no daily tasks for today at login"; exit 1; }
tasks_of Trainer | python3 -c "import json,sys; s=json.load(sys.stdin); assert len(s['tasks']) == 3, s; assert len({t['kind'] for t in s['tasks']}) == 3, s"
say_admin() { # the server reads its table at login only through its own connection, so tests use the staff commands
  local args=()
  for text in "$@"; do args+=(--say "$text"); done
  python3 "$root/scripts/protocol-test.py" --account admin --password admin --character Admin "${args[@]}"
}
say_admin "/dailytasks reset" "/dailytasks progress 1 999" "/dailytasks claim 1" "/dailytasks claim 2" \
  "/dailytasks bonus" "/dailytasks progress 2 999" "/dailytasks progress 3 999" "/dailytasks claim 2" \
  "/dailytasks claim 3" "/dailytasks bonus"
tasks_of Admin | python3 -c "import json,sys; s=json.load(sys.stdin); t=s['tasks']
assert all(x['claimed'] and x['progress'] == x['target'] for x in t), s
assert s['bonusClaimed'] and not s['rerolled'], s"
[ "$(inside Admin 10 13295,13292)" -ge 1 ] || { echo "FAIL: the daily bonus (a surprise box) is not in Admin's bag"; exit 1; }
say_admin "/i 2152, 10" "/dailytasks reset" "/dailytasks progress 3 999" "/dailytasks reroll 3" \
  "/dailytasks reroll 1" "/dailytasks reroll 2"
tasks_of Admin | python3 -c "import json,sys; s=json.load(sys.stdin); t=s['tasks']
assert s['rerolled'] and len({x['kind'] for x in t}) == 3, s
assert t[2]['progress'] == t[2]['target'] and t[0]['progress'] == 0, s"
echo "Daily tasks: picked at login, claim, bonus, rewards and one reroll a day"

step "Server log errors"
grep -E "^\[Error|ERROR|MYSQL ERROR" "$work/server.log" | sort | uniq -c | sort -rn || true
if grep -q "MYSQL ERROR" "$work/server.log"; then echo "FAIL: database errors in server log"; exit 1; fi

step "Stopping the server"
kill -INT "$server_pid"
for _ in $(seq 60); do kill -0 "$server_pid" 2>/dev/null || break; sleep 1; done
server_pid=""
echo "PASS: database setup, server start, login, character creation, game login, movement and Discord bridge verified."
