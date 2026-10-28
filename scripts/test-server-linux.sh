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
smtp_pid=""
paypal_pid=""
payments_pid=""

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
  [ -n "$payments_pid" ] && stop_process "$payments_pid"
  [ -n "$paypal_pid" ] && stop_process "$paypal_pid"
  [ -n "$smtp_pid" ] && stop_process "$smtp_pid"
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
$db -upokeverse -ppokeverse pokeverse -e "CALL pokeverse_create_account('bridgetrainer', 'secret'); CALL pokeverse_create_character('bridgetrainer', 'Bridge Trainer', 0); CALL pokeverse_create_account('bridgestaff', 'secret'); CALL pokeverse_create_character('bridgestaff', 'Bridge Staff', 0); CALL pokeverse_set_group('Bridge Staff', 6); CALL pokeverse_create_account('bridgelink', 'secret'); CALL pokeverse_create_character('bridgelink', 'Link Alpha', 0); CALL pokeverse_set_group('Link Alpha', 2); CALL pokeverse_create_character('bridgelink', 'Link Beta', 1); CALL pokeverse_create_account('bridgebooster', 'secret'); CALL pokeverse_create_character('bridgebooster', 'Booster Trainer', 0); CALL pokeverse_create_account('voctester', 'secret'); CALL pokeverse_create_character('voctester', 'Vocation Tester', 0); CALL pokeverse_create_account('vocfriend', 'secret'); CALL pokeverse_create_character('vocfriend', 'Vocation Friend', 1); CALL pokeverse_create_account('orbbuyer', 'secret'); CALL pokeverse_create_character('orbbuyer', 'Orb Buyer', 0); CALL pokeverse_create_account('questgreeter', 'secret'); CALL pokeverse_create_character('questgreeter', 'Quest Greeter', 0);"
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
discordBridgeBoosterRewards = true
discordBridgeBoostPerks = true
LUA
cp "$root/scripts/testing/discord-bridge-test-talkaction.lua" "$work/server/data/talkactions/scripts/bridgetest.lua"
sed -i 's#</talkactions>#\t<talkaction words="/bridgetest" event="script" value="bridgetest.lua"/>\n</talkactions>#' \
  "$work/server/data/talkactions/talkactions.xml"
# /vocationtest (scripts/testing/) drives every vocation perk through the real game code.
cp "$root/scripts/testing/vocation-test-talkaction.lua" "$work/server/data/talkactions/scripts/vocationtest.lua"
sed -i 's#</talkactions>#\t<talkaction words="/vocationtest" event="script" value="vocationtest.lua"/>\n</talkactions>#' \
  "$work/server/data/talkactions/talkactions.xml"
# /questtest (scripts/testing/) sets the level and puts the trainer next to an NPC for the greeting checks.
cp "$root/scripts/testing/quest-greet-test-talkaction.lua" "$work/server/data/talkactions/scripts/questtest.lua"
sed -i 's#</talkactions>#\t<talkaction words="/questtest" event="script" value="questtest.lua"/>\n</talkactions>#' \
  "$work/server/data/talkactions/talkactions.xml"
# /paytest (scripts/testing/) drives the Store's Buy Verse Orbs button, Withdraw and the payment messages.
cp "$root/scripts/testing/payments-test-talkaction.lua" "$work/server/data/talkactions/scripts/paytest.lua"
sed -i 's#</talkactions>#\t<talkaction words="/paytest" event="script" value="paytest.lua"/>\n</talkactions>#' \
  "$work/server/data/talkactions/talkactions.xml"
start_server() {
  (cd "$work/server" && exec "./$(basename "$binary")" >"$work/server.log" 2>&1) &
  server_pid=$!
  for _ in $(seq 180); do
    grep -q "server Online!" "$work/server.log" 2>/dev/null && break
    kill -0 "$server_pid" 2>/dev/null || { tail -50 "$work/server.log"; echo "FAIL: server exited during startup"; exit 1; }
    sleep 1
  done
  grep -q "server Online!" "$work/server.log" || { tail -50 "$work/server.log"; echo "FAIL: server did not start"; exit 1; }
}
stop_server() {
  kill -INT "$server_pid"
  for _ in $(seq 60); do kill -0 "$server_pid" 2>/dev/null || break; sleep 1; done
  server_pid=""
}
start_server
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

# Before the bridge tests: those leave a server boost level on for the restart check.
step "Vocation tests"
python3 "$root/scripts/vocation-test.py" --tester "voctester:secret:Vocation Tester" --friend "vocfriend:secret:Vocation Friend" \
  || { grep "vocationtest: FAIL" "$work/server.log"; exit 1; }
sleep 3

step "Quest NPC greeting tests"
python3 "$root/scripts/quest-greet-test.py" --tester "questgreeter:secret:Quest Greeter"
sleep 3

step "Discord bridge tests"
python3 "$root/scripts/discord-bridge-test.py" --secret "$bridge_secret" --catch-test \
  --listener "bridgetrainer:secret:Bridge Trainer" --speaker "bridgestaff:secret:Bridge Staff" --staff-character "Bridge Staff" \
  --link-test --linker "bridgelink:secret:Link Alpha:Link Beta" --code-lifetime 8 \
  --booster-test --booster "bridgebooster:secret:Booster Trainer" --sql "$db -upokeverse -ppokeverse pokeverse" \
  --boost-test
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
[ "$skills" = "0:0 1:0 2:0 3:0 4:1 5:1 6:1" ] || { echo "FAIL: duel and battle counters should start at 0, headbutting, catching and fishing at 1"; exit 1; }
[ "$(inside "New Trainer" 5 "12214,12216,12218,12220,12222,12224,12226,12228")" = 8 ] || { echo "FAIL: badge case should hold the 8 badge slots"; exit 1; }
[ "$(inside "New Trainer" 10 13820)" = 1 ] || { echo "FAIL: starter cookies are not in the bag"; exit 1; }
[ "$(inside "Admin" 10 12157)" = 1 ] || { echo "FAIL: items created for Admin did not go into the bag"; item_query Admin "i.pid, i.sid, i.itemtype, i.count" ""; exit 1; }
kit=$(equipped "Bag Trainer")
echo "Bag Trainer equipped after login: $kit"
case " $kit " in *" 10:12282 "*) ;; *) echo "FAIL: Bag Trainer's bag was not moved to slot 10"; exit 1;; esac

links=$($db -upokeverse -ppokeverse -N pokeverse -e "SELECT COUNT(*) FROM discord_account_links")
[ "$links" = 0 ] || { echo "FAIL: the bridge test should leave no Discord links, found $links"; exit 1; }
boosted=$($db -upokeverse -ppokeverse -N pokeverse -e "SELECT CONCAT(a.soulcoins, ',', COUNT(r.id), ',', SUM(r.total)) FROM accounts a JOIN discord_booster_rewards r ON r.account_id = a.id WHERE a.name = 'bridgebooster' GROUP BY a.id")
[ "$boosted" = "32,5,32" ] || { echo "FAIL: the booster account should hold 32 Soul Coins from 5 ledger rows (soulcoins,rows,total: $boosted)"; exit 1; }
boost_level=$($db -upokeverse -ppokeverse -N pokeverse -e "SELECT value FROM global_storage WHERE \`key\` = 7156")
[ "$boost_level" = 2 ] || { echo "FAIL: the server boost level should be stored as 2, got '$boost_level'"; exit 1; }
grep -q "> Discord boost perks: server boost level 2 -> 3 (14 boosts)." "$work/server.log" \
  || { echo "FAIL: boost level changes are not logged"; exit 1; }
! grep -qE "1234567890123456789|98765432109876543210|11111111111111111|22222222222222222222" "$work/server.log" \
  || { echo "FAIL: a Discord user id reached the server log"; exit 1; }
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
board_of() { sql "SELECT b.data FROM player_task_boards b JOIN players p ON p.id = b.player_id WHERE p.name = '$1' AND b.board = '$2'"; }
picked=$(sql "SELECT COUNT(*) FROM player_daily_tasks d JOIN players p ON p.id = d.player_id WHERE p.name = 'Trainer' AND d.day = '$(date +%F)'")
[ "$picked" = 1 ] || { echo "FAIL: Trainer has no daily board for today after logging in"; exit 1; }
tasks_of Trainer | python3 -c "import json,sys; s=json.load(sys.stdin); assert not s['tasks'] and 'difficulty' not in s, s"
say_admin() { # the server reads its table at login only through its own connection, so tests use the staff commands
  local args=()
  for text in "$@"; do args+=(--say "$text"); done
  python3 "$root/scripts/protocol-test.py" --account admin --password admin --character Admin "${args[@]}"
}
# the difficulty is picked once a day: the second start must not change it; Medium and Easy below need level 35
say_admin "/addskill Admin, level, 40" "/dailytasks reset" "/dailytasks claim 1" "/dailytasks start 1" "/dailytasks start 5" \
  "/dailytasks progress 1 999" "/dailytasks claim 1" "/dailytasks claim 2" \
  "/dailytasks bonus" "/dailytasks progress 2 999" "/dailytasks progress 3 999" "/dailytasks claim 2" \
  "/dailytasks claim 3" "/dailytasks bonus"
tasks_of Admin | python3 -c "import json,sys; s=json.load(sys.stdin); t=s['tasks']
assert s['difficulty'] == 1 and len(t) == 3 and len({x['kind'] for x in t}) == 3, s
assert all(x['claimed'] and x['progress'] == x['target'] for x in t), s
assert s['bonusClaimed'] and not s['rerolled'], s"
[ "$(inside Admin 10 13295,13292)" -ge 1 ] || { echo "FAIL: the daily bonus (a surprise box) is not in Admin's bag"; exit 1; }
say_admin "/i 2152, 10" "/tasks daily reset" "/tasks daily start 3" "/tasks daily progress 3 999" "/tasks daily reroll 3" \
  "/tasks daily reroll 1" "/tasks daily reroll 2" "/tasks daily progress 2 1"
# a new login must load the saved board, not pick a new one
say_admin "/tasks"
tasks_of Admin | python3 -c "import json,sys; s=json.load(sys.stdin); t=s['tasks']
assert s['difficulty'] == 3 and s['rerolled'] and len({x['kind'] for x in t}) == 3, s
assert t[2]['progress'] == t[2]['target'] and t[0]['progress'] == 0 and t[1]['progress'] == 1, s"
echo "Daily tasks: difficulty picked once, claim, bonus, rewards, one reroll a day, kept across logins"
# picked in the window (a talkaction) and counted by fishing (a creaturescript) in the same session
say_admin "/tasks daily reset" "/tasks daily start 1" "/tasks daily kind 1 fish" "/tasks hook 2"
tasks_of Admin | python3 -c "import json,sys; s=json.load(sys.stdin); t=s['tasks'][0]
assert s['difficulty'] == 1 and t['kind'] == 'fish' and t['progress'] == 2, s"
echo "Daily tasks: hooking Pokemon counts right after the tasks are picked"

step "Daily login calendar"
in_bag() { item_query Admin "COALESCE(SUM(i.count), 0)" "AND c.pid = 10 AND i.itemtype = $1"; }
balls=$(in_bag 12157)
say_admin "/tasks login reset" "/tasks login claim" "/tasks login claim"
[ "$(in_bag 12157)" = "$((balls + 10))" ] || { echo "FAIL: day 1 should give 10 poke balls, once ($balls before, $(in_bag 12157) after)"; exit 1; }
candies=$(in_bag 14463)
say_admin "/tasks login streak 6" "/tasks login claim"
[ "$(in_bag 14463)" = "$((candies + 1))" ] || { echo "FAIL: day 7 should give a rare candy ($candies before, $(in_bag 14463) after)"; exit 1; }
# day 3 claimed three days ago: the round is lost and today is day 1 again
today=$(python3 -c "import datetime, time; d = datetime.date.today(); print(int(time.mktime((d.year, d.month, d.day, 12, 0, 0, 0, 0, -1)) // 86400))")
sql "UPDATE player_storage s JOIN players p ON p.id = s.player_id SET s.value = IF(s.key = 7084, '3', '$((today - 3))')
  WHERE p.name = 'Admin' AND s.key IN (7084, 7085)"
balls=$(in_bag 12157)
say_admin "/tasks login claim"
[ "$(in_bag 12157)" = "$((balls + 10))" ] || { echo "FAIL: after a missed day the calendar should start over at day 1 ($balls before, $(in_bag 12157) after)"; exit 1; }
echo "Daily login calendar: day 1 once a day, day 7 gives a rare candy, a missed day starts over"

step "Weekly tasks"
say_admin "/tasks weekly reset" "/tasks weekly start 2" "/tasks weekly start 4" "/tasks weekly reroll 1" \
  "/tasks weekly progress 2 3"
say_admin "/tasks"
board_of Admin weekly | python3 -c "import json,sys; s=json.load(sys.stdin); t=s['tasks']
assert s['difficulty'] == 2 and len(t) == 5 and s['rerolled'], s
assert t[1]['progress'] == 3 and all(x['target'] >= 5 for x in t), s"
monday=$(python3 -c "import datetime; d=datetime.date.today(); print(d - datetime.timedelta(days=d.weekday()))")
[ "$(sql "SELECT period FROM player_task_boards b JOIN players p ON p.id = b.player_id WHERE p.name = 'Admin' AND b.board = 'weekly'")" = "$monday" ] \
  || { echo "FAIL: the weekly board should be for the week starting $monday"; exit 1; }
echo "Weekly tasks: 5 tasks for the week of $monday, free reroll, kept across logins"

step "Hunting board"
hunting=$(say_admin "/tasks hunting reset" "/tasks hunting take 1 1" "/tasks hunting difficulty 1" \
  "/tasks hunting take 1 1" "/tasks hunting take 1 2" "/tasks hunting difficulty 3" "/tasks hunting progress 1 999" \
  "/tasks hunting claim 1" "/tasks hunting points 100" "/tasks hunting buy 1")
board_of Admin hunting | python3 -c "
import json, sys
s = json.load(sys.stdin)
assert s['difficulty'] == 1 and s['completed'] == 1, s
assert s['earned'] == 10 and s['points'] == 80, s  # a Small hunt, then 20 points spent in the shop
assert len(s['offers']) == 3, s"
echo "$hunting" | python3 -c '
import json, sys
boards = [json.loads(l.split("extended opcode 17: ", 1)[1]) for l in sys.stdin if "extended opcode 17: " in l]
hunts = [b for b in boards if b["board"] == "hunting" and b.get("difficulty") == 1]
assert hunts, "no hunting board messages"
for b in hunts:
    for o in b["offers"]:
        assert o["maxLevel"] <= 70 and o["look"] > 0, o
first = hunts[0]
assert len(first["offers"]) == 3 and len(first["offers"][0]["sizes"]) == 3, first
print("Hunting offers at Beginner:", ", ".join("%s (%d-%d)" % (o["species"], o["minLevel"], o["maxLevel"]) for o in first["offers"]))
'
[ "$(inside Admin 10 13295)" -ge 1 ] || { echo "FAIL: the hunting shop item is not in Admin's bag"; exit 1; }
say_admin "/tasks hunting take 1 1" "/tasks hunting difficulty 2" >/dev/null
taken=$(board_of Admin hunting | python3 -c "import json,sys; s=json.load(sys.stdin); assert len(s['active']) == 1 and len(s['offers']) == 2, s; print(s['active'][0]['species'])")
say_admin "/tasks hunting cancel 1" >/dev/null
board_of Admin hunting | TAKEN="$taken" python3 -c "
import json, os, sys
s = json.load(sys.stdin)
assert len(s['offers']) == 3 and os.environ['TAKEN'] in s['offers'], s  # giving up returns the offer"
say_admin "/tasks hunting cancel 1" "/tasks hunting difficulty 2"
board_of Admin hunting | python3 -c "import json,sys; s=json.load(sys.stdin); assert s['difficulty'] == 2 and not s['active'], s"
# the free refresh comes back at midnight, so it is kept as the day it was used
say_admin "/tasks hunting refresh" >/dev/null
board_of Admin hunting | TODAY="$(date +%F)" python3 -c "import json,os,sys; s=json.load(sys.stdin); assert s.get('freeRefreshDay') == os.environ['TODAY'] and len(s['offers']) == 3, s"
echo "Hunting board: difficulty locked while hunting, claim, points, shop, giving up returns the offer"

step "Level-up banners"
# only the banner messages matter here, not whether the walk succeeded
banners=$(python3 "$root/scripts/protocol-test.py" --account admin --password admin --character Admin --walk west,east,north,south \
  --say "/addskill Admin, level, 2" --say "/mypokemon Bulbasaur, 12" --say "/pokemonexp 3, Bulbasaur" || true)
echo "$banners" | grep "extended opcode 16" || true
echo "$banners" | python3 -c '
import json, sys
banners = [json.loads(line.split("extended opcode 16: ", 1)[1]) for line in sys.stdin if "extended opcode 16: " in line]
trainer = [b for b in banners if b["kind"] == "trainer"]
pokemon = [b for b in banners if b["kind"] == "pokemon"]
assert trainer, "no trainer banner"
t = trainer[0]
assert t["to"] - t["from"] == 2, t
assert t["hp"]["new"] - t["hp"]["old"] == 20, t
assert t["pokemonCap"] == t["to"] + 10, t
assert pokemon, "no Pokemon banner"
p = pokemon[0]
assert (p["name"], p["from"], p["to"]) == ("Bulbasaur", 12, 15), p
assert len(p["stats"]) == 6 and all(s["new"] >= s["old"] for s in p["stats"]), p
assert any(s["new"] > s["old"] for s in p["stats"]), p
moves = [m["name"] for m in p["moves"]]
assert moves == ["Vine Whip"], moves
m = p["moves"][0]
assert m["element"] == 11 and m["energy"] > 0 and m["cooldown"] > 0 and m["description"], m
print("Level-up banners: trainer %d -> %d, %s %d -> %d learned %s" % (t["from"], t["to"], p["name"], p["from"], p["to"], ", ".join(moves)))
' || { echo "$banners" | tail -30; echo "FAIL: level-up banner messages are wrong"; exit 1; }

step "Character limit"
max_characters=$(tr -d '\r' < "$root/core/server/config.lua" | sed -n 's/^\s*maxCharactersPerAccount = \([0-9]*\).*/\1/p')
python3 "$root/scripts/account-test.py" --slot-limit "$max_characters"

step "News banner"
news=$(python3 "$root/scripts/protocol-test.py" --account admin --password admin --character Admin --walk "" \
  --say "/b Test broadcast" || true)
echo "$news" | grep "extended opcode 47" || true
echo "$news" | python3 -c '
import json, sys
news = [json.loads(line.split("extended opcode 47: ", 1)[1]) for line in sys.stdin if "extended opcode 47: " in line]
assert {"c": "staff", "h": "Admin", "x": "Test broadcast", "f": "Admin: Test broadcast"} in news, news'
echo "News banner: /b is a Staff announcement with the staff name"

step "Warp Styles"
$db -upokeverse -ppokeverse pokeverse -e "UPDATE accounts SET soulcoins = 12 WHERE name = 'admin'; DELETE w FROM player_warp_styles w JOIN players p ON p.id = w.player_id WHERE p.name = 'Admin'"
warp=$(python3 "$root/scripts/protocol-test.py" --account admin --password admin --character Admin --walk "" \
  --send-opcode '57:{"action":"hello"}' \
  --send-opcode '57:{"action":"equip","trigger":"logout","style":"beam"}' \
  --send-opcode '57:{"action":"equip","trigger":"login","style":"victory"}' \
  --send-opcode '41:{"action":"buy","offer":"warp_pokeball"}' \
  --send-opcode '41:{"action":"buy","offer":"warp_pokeball"}' \
  --say "/warpstyle beam teleport" --say "/warpstyle defeat defeat" \
  --say "/warpstyle pokeball teleport" --say "/warpstyle ghost defeat" --say "/warpstyle fireworks victory" || true)
bought=$($db -upokeverse -ppokeverse -N pokeverse -e "SELECT CONCAT(a.soulcoins, ',', COUNT(w.style)) FROM accounts a JOIN players p ON p.account_id = a.id LEFT JOIN player_warp_styles w ON w.player_id = p.id AND w.style = 'pokeball' WHERE p.name = 'Admin' GROUP BY a.id")
[ "$bought" = "2,1" ] || { echo "$warp" | grep "opcode 41" | tail -5; echo "FAIL: buying the Poke Ball Warp once should leave 2 Soul Coins and one owned row (coins,rows: $bought)"; exit 1; }
echo "$warp" | grep -q "You already have this Warp Style" || { echo "FAIL: buying an owned Warp Style again should be refused"; exit 1; }
echo "$warp" | grep "extended opcode 57" || true
echo "$warp" | python3 -c '
import json, sys
msgs = [json.loads(line.split("extended opcode 57: ", 1)[1]) for line in sys.stdin if "extended opcode 57: " in line]
states = [m for m in msgs if m["type"] == "state"]
plays = [m for m in msgs if m["type"] == "play"]
assert len(states) >= 3, msgs
first = states[0]
assert [t["id"] for t in first["triggers"]] == ["login", "logout", "teleport", "victory", "defeat", "faint"], first
assert {s["id"] for s in first["styles"]} == {"spin", "beam", "pokeball", "victory", "fireworks", "trophy", "defeat",
                                             "sweatdrop", "ghost", "faint"}, first
assert all(s["owned"] for s in first["styles"]), "staff own every style"
slots = {t["id"]: t["style"] for t in states[-1]["triggers"]}
assert slots["logout"] == "beam", slots
assert slots["login"] == "spin", "a victory style must not go in the login slot"
halves = [(p["s"], p["h"], p["t"]) for p in plays]
assert ("beam", "out", "teleport") in halves and ("beam", "in", "teleport") in halves, halves
assert ("defeat", "fx", "defeat") in halves, halves
assert ("pokeball", "out", "teleport") in halves and ("pokeball", "in", "teleport") in halves, halves
assert ("ghost", "fx", "defeat") in halves and ("fireworks", "fx", "victory") in halves, halves
p = plays[0]
assert p["o"]["type"] > 0 and set(p["p"]) == {"x", "y", "z"}, p
print("Warp Styles: %d states, plays %s" % (len(states), halves))
' || { echo "$warp" | tail -30; echo "FAIL: Warp Styles messages are wrong"; exit 1; }

step "Server log errors"
grep -E "^\[Error|ERROR|MYSQL ERROR" "$work/server.log" | sort | uniq -c | sort -rn || true
if grep -q "MYSQL ERROR" "$work/server.log"; then echo "FAIL: database errors in server log"; exit 1; fi

step "Stopping the server"
stop_server

step "Account emails (emailRequired, STARTTLS to a local SMTP server)"
mkdir -p "$work/mail/box"
openssl req -x509 -newkey rsa:2048 -nodes -days 2 -subj /CN=localhost -addext subjectAltName=DNS:localhost \
  -keyout "$work/mail/key.pem" -out "$work/mail/cert.pem" 2>/dev/null
python3 -u "$root/scripts/testing/fake-smtp.py" --port 2526 --mailbox "$work/mail/box" --cert "$work/mail/cert.pem" \
  --key "$work/mail/key.pem" --user ci@pokeverse.test --password ci-app-password > "$work/smtp.log" 2>&1 &
smtp_pid=$!
cat >> "$work/server/config.local.lua" <<LUA
discordBridgeBoosterRewards = false
discordBridgeBoostPerks = false
emailRequired = true
smtpHost = "localhost"
smtpPort = 2526
smtpStartTls = true
smtpUser = "ci@pokeverse.test"
smtpPassword = "ci-app-password"
smtpFrom = "ci@pokeverse.test"
smtpCaFile = "$work/mail/cert.pem"
paymentsUrl = "http://127.0.0.1:7200"
LUA
mv "$work/server.log" "$work/server-1.log"
start_server
grep -q "Account emails go through localhost:2526" "$work/server.log" || { echo "FAIL: the mailer did not start"; exit 1; }
python3 "$root/scripts/discord-bridge-test.py" --secret "$bridge_secret" --booster-disabled
for _ in $(seq 10); do grep -q "> Discord boost perks: server boost level 2 restored" "$work/server.log" && break; sleep 1; done
grep -q "> Discord boost perks: server boost level 2 restored (perks are off in config.lua)." "$work/server.log" \
  || { echo "FAIL: the server boost level was not restored after the restart"; exit 1; }
python3 "$root/scripts/account-email-test.py" --mailbox "$work/mail/box" --sql "$db -upokeverse -ppokeverse pokeverse" \
  || { tail -40 "$work/server.log"; cat "$work/smtp.log"; echo "FAIL: account email test"; exit 1; }
python3 "$root/scripts/protocol-test.py" --account test --password test --character Trainer --walk east \
  || { echo "FAIL: an older account must keep playing during its 7 days"; exit 1; }

step "Buying Verse Orbs (payment service against a fake PayPal)"
python3 -u "$root/scripts/testing/fake-paypal.py" --port 7290 --client-id ci-paypal-client --client-secret ci-paypal-secret \
  > "$work/paypal.log" 2>&1 &
paypal_pid=$!
PAYPAL_CLIENT_ID=ci-paypal-client PAYPAL_CLIENT_SECRET=ci-paypal-secret PAYPAL_API=http://127.0.0.1:7290 \
  PAYPAL_SDK_URL=http://127.0.0.1:7290/sdk/js PAYMENTS_PUBLIC_URL=http://127.0.0.1:7200 \
  python3 -u "$root/core/payments/payments.py" --server-dir "$work/server" --port 7200 > "$work/payments.log" 2>&1 &
payments_pid=$!
for _ in $(seq 30); do curl -fs http://127.0.0.1:7200/healthz >/dev/null 2>&1 && break; sleep 1; done
grep -q "PayPal webhook WH-" "$work/payments.log" || { cat "$work/payments.log"; echo "FAIL: the payment service did not register its webhook"; exit 1; }
python3 "$root/scripts/payments-test.py" --service http://127.0.0.1:7200 --paypal http://127.0.0.1:7290 \
  --sql "$db -upokeverse -ppokeverse pokeverse" --buyer "orbbuyer:secret:Orb Buyer" --mailbox "$work/mail/box" \
  || { tail -60 "$work/payments.log"; tail -20 "$work/paypal.log"; tail -40 "$work/server.log"; echo "FAIL: payments test"; exit 1; }
! grep -qE "[?&]t=[0-9a-f]{32}" "$work/payments.log" "$work/server.log" || { echo "FAIL: a buy link reached a log"; exit 1; }
codes=$(python3 -c 'import glob, json, re, sys
for f in glob.glob(sys.argv[1] + "/*.json"):
    for c in re.findall(r"\b\d{6}\b", json.load(open(f))["subject"]): print(c)' "$work/mail/box" | sort -u)
[ -n "$codes" ] || { echo "FAIL: no codes in the mailbox"; exit 1; }
for code in $codes; do
  ! grep -qw "$code" "$work/server.log" || { echo "FAIL: a code from an email reached the server log"; exit 1; }
done
if grep -q "MYSQL ERROR" "$work/server.log"; then grep "MYSQL ERROR" "$work/server.log" | sort | uniq -c; echo "FAIL: database errors in server log"; exit 1; fi
stop_server
echo "PASS: database setup, server start, login, character creation, game login, movement, Discord bridge, account emails and buying Verse Orbs verified."
