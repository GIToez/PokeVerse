#!/usr/bin/env bash
# Two-account test of the player market (ext opcode 64) against the dev database.
# Seeds two listings owned by Trainer, then logs in GM Admin to buy from one, list and cancel an
# item, and offer on the other, then logs in Trainer to accept that offer. The database rows,
# the mailed items and coins, both players' history and logs/market.log are checked after each
# client run. Needs a running server (tools/smoke_server.sh) and a staged client
# (tools/stage_redemption.sh). Linux only (uses the mysql client).
# Usage: tools/smoke_market.sh [LOGDIR]
# Env: MYSQL (default "mysql -upokeverse -ppokeverse-dev"), DB (default pokeverse)
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
LOGDIR="${1:-/tmp}"
MYSQL="${MYSQL:-mysql -upokeverse -ppokeverse-dev}"
DB="${DB:-pokeverse}"
MARKET_LOG="$ROOT/server/runtime-data/logs/market.log"
SEED_BUY=Mkt90000000000000000001
SEED_OFFER=Mkt90000000000000000002
WOOL=12129
GOLD=2152
MARKET_POS_STORAGE=7082

q() { $MYSQL -N -B "$DB" -e "$1"; }
failures=0
check() {
    if [ "$2" = "$3" ]; then echo "DB $1 OK ($2)"; else echo "DB $1 FAILED (got '$2', expected '$3')"; failures=$((failures + 1)); fi
}
depot_count() { q "SELECT COALESCE(SUM(count), 0) FROM player_depotitems WHERE player_id = $1 AND itemtype = $2"; }
historic_has() { q "SELECT COUNT(*) FROM market_historic WHERE player_id = $1 AND historic LIKE '%$2%'"; }
log_lines() { if [ -f "$MARKET_LOG" ]; then grep -c -- "$1" "$MARKET_LOG" || true; else echo 0; fi; }

TRAINER=$(q "SELECT id FROM players WHERE name = 'Trainer'")
GM=$(q "SELECT id FROM players WHERE name = 'GM Admin'")
[ -n "$TRAINER" ] && [ -n "$GM" ] || { echo "dev characters missing; run tools/setup_dev_db.sh" >&2; exit 1; }

cleanup_seed() {
    q "DELETE FROM market_offers WHERE item_code IN ('$SEED_BUY', '$SEED_OFFER');
       DELETE FROM market_items WHERE item_code IN ('$SEED_BUY', '$SEED_OFFER');
       DELETE FROM player_storage WHERE player_id = $TRAINER AND \`key\` = $MARKET_POS_STORAGE;"
}
trap cleanup_seed EXIT
cleanup_seed
q "UPDATE market_historic SET historic = '[]' WHERE player_id IN ($TRAINER, $GM)"
q "INSERT INTO market_items (item_code, playerseller_id, playerseller_name, onlyoffer, itemid, count, price, attributes, time) VALUES
   ('$SEED_BUY', $TRAINER, 'Trainer', 0, $WOOL, 3, 10, '', UNIX_TIMESTAMP() + 86400),
   ('$SEED_OFFER', $TRAINER, 'Trainer', 1, $WOOL, 1, 0, '', UNIX_TIMESTAMP() + 86400)"

trainer_gold=$(depot_count "$TRAINER" "$GOLD")
gm_wool=$(depot_count "$GM" "$WOOL")
trainer_wool=$(depot_count "$TRAINER" "$WOOL")
buys=$(log_lines " buy code=$SEED_BUY ")
offers=$(log_lines " offer code=$SEED_OFFER ")
accepts=$(log_lines " accept code=$SEED_OFFER ")

echo "== GM Admin: buy, sell, cancel, offer"
PV_MARKET=buyer PV_MARKET_SEED_BUY=$SEED_BUY PV_MARKET_SEED_OFFER=$SEED_OFFER PV_ACCOUNT=admin PV_PASSWORD=admin \
    PV_CHARACTER="GM Admin" timeout 280 "$ROOT/tools/smoke_redemption_login.sh" "$LOGDIR/market-buyer.log" > "$LOGDIR/market-buyer.out" 2>&1 \
    || { tail -40 "$LOGDIR/market-buyer.out"; exit 1; }
grep -a '\[pv-smoke\] MARKET' "$LOGDIR/market-buyer.log" | LC_ALL=C sort -u
for line in 'MARKET OPEN OK' 'MARKET LIST OK' 'MARKET FORGED BUY REFUSED' 'MARKET FORGED SELL REFUSED' 'MARKET FORGED ACCEPT REFUSED' \
    'MARKET BUY OK' 'MARKET SELL OK' 'MARKET CANCEL OK' 'MARKET MAKE OFFER OK' 'MARKET FORGED OFFER REFUSED' 'MARKET OFFER OK' \
    'MARKET HISTORY OK' 'MARKET CLOSE OK'; do
    grep -aq "\[pv-smoke\] $line" "$LOGDIR/market-buyer.log" || { echo "CLIENT $line missing"; failures=$((failures + 1)); }
done
check "listing count after buying 1 of 3" "$(q "SELECT count FROM market_items WHERE item_code = '$SEED_BUY'")" 2
check "GM listings after cancel" "$(q "SELECT COUNT(*) FROM market_items WHERE playerseller_id = $GM")" 0
check "GM offer row (state count)" "$(q "SELECT CONCAT(state, ' ', count) FROM market_offers WHERE item_code = '$SEED_OFFER' AND playeroffer_id = $GM")" "1 2"
check "seller paid by mail" "$(( $(depot_count "$TRAINER" "$GOLD") - trainer_gold ))" 10
check "GM history has the purchase" "$(historic_has "$GM" "You bought 1 ")" 1
check "Trainer history has the sale" "$(historic_has "$TRAINER" "You sold 1 ")" 1
check "market.log buy line" "$(( $(log_lines " buy code=$SEED_BUY ") - buys ))" 1
check "market.log offer line" "$(( $(log_lines " offer code=$SEED_OFFER ") - offers ))" 1
check "GM received the bought item and the cancelled listing by mail" "$(( $(depot_count "$GM" "$WOOL") - gm_wool ))" 3
gm_wool=$(depot_count "$GM" "$WOOL")

pos=$(q "SELECT CONCAT(',X:', posx, ',Y:', posy, ',Z:', posz, ',S:0') FROM players WHERE id = $TRAINER")
q "INSERT INTO player_storage (player_id, \`key\`, value) VALUES ($TRAINER, $MARKET_POS_STORAGE, '$pos')"

echo "== Trainer: accept the GM's offer"
PV_MARKET=seller PV_MARKET_SEED_BUY=$SEED_BUY PV_MARKET_SEED_OFFER=$SEED_OFFER \
    timeout 280 "$ROOT/tools/smoke_redemption_login.sh" "$LOGDIR/market-seller.log" > "$LOGDIR/market-seller.out" 2>&1 \
    || { tail -40 "$LOGDIR/market-seller.out"; exit 1; }
grep -a '\[pv-smoke\] MARKET' "$LOGDIR/market-seller.log" | LC_ALL=C sort -u
for line in 'MARKET OPEN OK' 'MARKET OWN LISTINGS OK' 'MARKET OFFERS TO ME OK' 'MARKET OFFER WINDOW OK' 'MARKET ACCEPT OK' \
    'MARKET HISTORY OK' 'MARKET CLOSE OK'; do
    grep -aq "\[pv-smoke\] $line" "$LOGDIR/market-seller.log" || { echo "CLIENT $line missing"; failures=$((failures + 1)); }
done
check "accepted listing removed" "$(q "SELECT COUNT(*) FROM market_items WHERE item_code = '$SEED_OFFER'")" 0
check "accepted offer rows removed" "$(q "SELECT COUNT(*) FROM market_offers WHERE item_code = '$SEED_OFFER'")" 0
check "GM received the listed item" "$(( $(depot_count "$GM" "$WOOL") - gm_wool ))" 1
check "Trainer received the offered items" "$(( $(depot_count "$TRAINER" "$WOOL") - trainer_wool ))" 2
check "Trainer history has the acceptance" "$(historic_has "$TRAINER" "You accepted an offer")" 1
check "GM history has the accepted offer" "$(historic_has "$GM" "Your offer was accepted")" 1
check "market.log accept line" "$(( $(log_lines " accept code=$SEED_OFFER ") - accepts ))" 1

[ "$failures" = 0 ] || { echo "Market smoke: FAIL ($failures)"; exit 1; }
echo "Market smoke: PASS"
