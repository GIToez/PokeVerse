-- Buying Verse Orbs with PayPal (docs/payments.md). Verse Orbs are the player-facing name of Soul Coins: bought
-- orbs go onto `accounts`.`soulcoins` like every other Soul Coin.
--
-- The payment service (core/payments/payments.py) runs next to the game server and owns everything PayPal. The game
-- server only:
--   - makes the buy link the Store's Buy Verse Orbs button opens (`payment_links`, 30 minutes);
--   - keeps orbs bought in the last 7 days on the balance: they can be spent but not withdrawn (Store.withdraw);
--   - shows the messages the service leaves in `payment_notices` (globalevents/payments.lua): to the account's
--     character when it is online, and to the staff online for refunds, reversals and disputes.
-- paymentsUrl in config.lua is the address of the service (empty: no button).

Payments = {}

Payments.LINK_LIFETIME = 30 * 60
Payments.LINKS_PER_ACCOUNT = 10 -- live links at a time
Payments.HOLD_DAYS = 7
Payments.NOTICES_PER_RUN = 50

Payments.url = function()
    local url = getConfigValue("paymentsUrl")
    return type(url) == "string" and url:gsub("/+$", "") or ""
end

Payments.enabled = function()
    return Payments.url() ~= ""
end

local function randomToken()
    local f = io.open("/dev/urandom", "rb")
    if (not f) then
        return nil
    end
    local bytes = f:read(16)
    f:close()
    if (not bytes or #bytes ~= 16) then
        return nil
    end
    return (bytes:gsub(".", function(c) return string.format("%02x", c:byte()) end))
end

-- The SQL for the orbs bought in the last HOLD_DAYS that are still on the balance, for one statement with the change
Payments.heldSql = function(accountId)
    return string.format("(SELECT COALESCE(SUM(`orbs` - `taken_back`), 0) FROM `payment_orders` WHERE `account_id` = %d"
        .. " AND `status` = 'completed' AND `credited_at` > %d)", accountId, os.time() - Payments.HOLD_DAYS * 86400)
end

Payments.getHeld = function(accountId)
    local r = db.getResult("SELECT " .. Payments.heldSql(accountId) .. " AS `n`")
    if (r:getID() == -1) then
        return 0
    end
    local n = r:getDataInt("n")
    r:free()
    return n
end

local function emailVerified(accountId)
    local r = db.getResult(string.format("SELECT `email_verified` FROM `accounts` WHERE `id` = %d", accountId))
    if (r:getID() == -1) then
        return false
    end
    local verified = r:getDataInt("email_verified") == 1
    r:free()
    return verified
end

-- The buy page's address for the player's account, or nil and why not
Payments.createLink = function(cid)
    if (not Payments.enabled()) then
        return nil, "Buying Verse Orbs isn't open yet."
    end
    local account = getPlayerAccountId(cid)
    if (not emailVerified(account)) then
        return nil, "Buying Verse Orbs needs a verified email. Verify it in Account, on the character list."
    end
    local token = randomToken()
    if (not token) then
        return nil, "Buying Verse Orbs isn't available on this server."
    end
    local now = os.time()
    db.executeQuery(string.format("DELETE FROM `payment_links` WHERE `expires_at` < %d", now))
    db.executeQuery(string.format("DELETE FROM `payment_links` WHERE `account_id` = %d AND `token` NOT IN (SELECT `token` FROM"
        .. " (SELECT `token` FROM `payment_links` WHERE `account_id` = %d ORDER BY `created_at` DESC LIMIT %d) `newest`)",
        account, account, Payments.LINKS_PER_ACCOUNT - 1))
    if (not db.executeQuery(string.format("INSERT INTO `payment_links` (`token`, `account_id`, `player_id`, `created_at`, `expires_at`)"
            .. " VALUES ('%s', %d, %d, %d, %d)", token, account, getPlayerGUID(cid), now, now + Payments.LINK_LIFETIME))) then
        return nil, "Buying Verse Orbs isn't available right now. Try again later."
    end
    return Payments.url() .. "/buy?t=" .. token
end

local function onlineByAccount()
    local players = {}
    for _, cid in ipairs(getPlayersOnline()) do
        players[getPlayerAccountId(cid)] = cid
    end
    return players
end

local function markDelivered(ids)
    if (#ids > 0) then
        db.executeQuery("UPDATE `payment_notices` SET `delivered` = 1 WHERE `id` IN (" .. table.concat(ids, ",") .. ")")
    end
end

-- Shows the service's messages; a player's waits until one of the account's characters is online
Payments.deliverNotices = function()
    local online = onlineByAccount()
    local accounts = {}
    for account in pairs(online) do
        accounts[#accounts + 1] = account
    end
    local staff = {}
    for _, cid in pairs(online) do
        if (getPlayerAccess(cid) >= ((Admin and Admin.STAFF_ACCESS) or 1)) then
            staff[#staff + 1] = cid
        end
    end
    local where = "`kind` = 'staff'"
    if (#accounts > 0) then
        where = where .. " OR `account_id` IN (" .. table.concat(accounts, ",") .. ")"
    end
    local r = db.getResult(string.format("SELECT `id`, `account_id`, `kind`, `text` FROM `payment_notices` WHERE `delivered` = 0 AND (%s)"
        .. " ORDER BY `id` LIMIT %d", where, Payments.NOTICES_PER_RUN))
    if (r:getID() == -1) then
        return
    end
    local done, refresh = {}, {}
    repeat
        local id, kind, text = r:getDataInt("id"), r:getDataString("kind"), r:getDataString("text")
        if (kind == "staff") then
            print("> " .. text)
            for _, cid in ipairs(staff) do
                doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_RED, text)
            end
            done[#done + 1] = id
        else
            local cid = online[r:getDataInt("account_id")]
            if (cid and isPlayer(cid)) then
                doPlayerSendActivity(cid, "store", MESSAGE_EVENT_ADVANCE, text)
                refresh[cid] = true
                done[#done + 1] = id
            end
        end
    until not r:next()
    r:free()
    markDelivered(done)
    for cid in pairs(refresh) do
        if (isPlayer(cid)) then
            Store.sendState(cid)
        end
    end
end
