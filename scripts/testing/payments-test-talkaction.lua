-- TEST ONLY - never part of the game data or any package.
-- scripts/test-server-linux.sh copies this file into a temporary server directory as "/paytest" and
-- scripts/payments-test.py says it. It drives the Store's real code for buying Verse Orbs:
--
--   /paytest link         the Store's Buy Verse Orbs button (the answer is a Store message)
--   /paytest withdraw <n> the Store's Withdraw
--   /paytest buy <offer>  a Store purchase
--   /paytest notices      shows the payment service's messages now instead of within 5 seconds
--   /paytest state        "paytest: balance <n> held <n>"

function onSay(cid, words, param, channel)
    local action, arg = param:match("^%s*(%S+)%s*(.-)%s*$")
    if (action == "link") then
        Store.onClientMessage(cid, JSON.encode({ action = "buy-orbs" }))
    elseif (action == "withdraw") then
        Store.onClientMessage(cid, JSON.encode({ action = "withdraw", amount = tonumber(arg) }))
    elseif (action == "buy") then
        Store.onClientMessage(cid, JSON.encode({ action = "buy", offer = arg, count = 1, text = "" }))
    elseif (action == "notices") then
        Payments.deliverNotices()
    elseif (action == "state") then
        local account = getPlayerAccountId(cid)
        doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, string.format("paytest: balance %d held %d",
            Store.getBalance(account), Payments.getHeld(account)))
    end
    return true
end
