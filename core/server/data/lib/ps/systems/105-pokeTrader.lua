-- The PokeTrader auction (docs/concepts/poketrader/README.md). Tiger Kelsey (npc/scripts/poketrader.lua) offers a
-- few lots every week; trainers bid on them at him, in his chat or in the auction window.
--
-- Trainers set a maximum, the most they would pay, and the auction bids for them: the leader is the highest maximum
-- (a later maximum has to beat it by STEP_PERCENT to take the lead), and the price is STEP_PERCENT over the
-- second-highest maximum, at most the leader's maximum and at least the lot's minimum. The whole maximum is held
-- when it is set (bank first, then carried money); at the end the winner gets the item in their depot and the rest
-- of their maximum back in the bank, everyone else all of theirs. Weeks end every END_WDAY at END_HOUR, with no extra
-- time for late bids, and the next lots come out at once.
--
-- Everything lives in the database (poketrader_offerts, poketrader_bids, poketrader_bid_log and
-- datalog_poketrader_boughts), because the NPC and the window run in different Lua states.
--
-- The client talks JSON on EXTENDED_IDS.POKETRADER:
--   client -> server  {action = "hello"} at login; {action = "bid", id, max}; {action = "takeback", id};
--                     {action = "log", id}; {action = "history"}; {action = "refresh"}; {action = "close"}
--   server -> client  {type = "trader", npc, balance, money, held, ends, now, lots = {{id, item, client, name, count,
--                     kind, min, price, bids, mine, status, lowest}, ...}, won = {{client, name, count, bid, date}}}
--                     opens or refreshes the window; {type = "log", id, rows = {{price, auto, mine, date}}};
--                     {type = "history", rows = {{date, client, name, count, winner, bid}}}; {type = "result", ok,
--                     text}; {type = "outbid", id}; {type = "close"}

PokeTrader = {}

PokeTrader.NPC = "Tiger Kelsey"
PokeTrader.RANGE = 4
PokeTrader.STEP_PERCENT = 1
PokeTrader.END_WDAY = 1 -- Sunday (os.date's wday)
PokeTrader.END_HOUR = 20
PokeTrader.MIN_WEEK = 24 * 60 * 60 -- a week that would end sooner than this (the first one) runs to the next END_WDAY
PokeTrader.TICK = 30 -- seconds between the NPC's checks for the end of the week
PokeTrader.HISTORY_DAYS = 14
PokeTrader.LOG_ROWS = 12

-- kind is the lot's line in the window; once: each trainer can win it once; unique: it belongs to the winner
PokeTrader.GROUPS = {
    { kind = "Evolution item", chance = 30, limit = 1, items = {
        { itemId = 18083, count = 1, minBid = 22500 }, -- Fire Stone
        { itemId = 18086, count = 1, minBid = 22000 }, -- Leaf Stone
        { itemId = 18084, count = 1, minBid = 25500 }, -- Moon Stone
        { itemId = 18085, count = 1, minBid = 24500 }, -- Sun Stone
        { itemId = 18087, count = 1, minBid = 22000 }, -- Thunderstone
        { itemId = 18088, count = 1, minBid = 22500 }, -- Water Stone
        { itemId = 18089, count = 1, minBid = 30000 }, -- Up-Grade
        { itemId = 18090, count = 1, minBid = 30000 }, -- Dragon Scale
        { itemId = 18091, count = 1, minBid = 30500 }, -- King's Rock
        { itemId = 18092, count = 1, minBid = 27500 }, -- Metal Coat
        { itemId = 18093, count = 1, minBid = 25500 }, -- Soothe Bell
        { itemId = 18094, count = 1, minBid = 30000 }, -- Punch Machine
        { itemId = 18095, count = 1, minBid = 30000 }, -- Kick Machine
        { itemId = 18096, count = 1, minBid = 30000 }, -- Spin Machine
        { itemId = 31083, count = 1, minBid = 25000 }, -- Shiny Stone
        { itemId = 31084, count = 1, minBid = 25000 }, -- Dusk Stone
        { itemId = 31085, count = 1, minBid = 25000 }, -- Dawn Stone
        { itemId = 31086, count = 1, minBid = 22500 }, -- Ice Stone
        { itemId = 31087, count = 1, minBid = 22500 }, -- Oval Stone
        { itemId = 31088, count = 1, minBid = 30000 }, -- Razor Claw
        { itemId = 31089, count = 1, minBid = 30000 }, -- Razor Fang
        { itemId = 31090, count = 1, minBid = 30000 }, -- Electirizer
        { itemId = 31091, count = 1, minBid = 30000 }, -- Magmarizer
        { itemId = 31092, count = 1, minBid = 30000 }, -- Protector
        { itemId = 31093, count = 1, minBid = 30000 }, -- Reaper Cloth
        { itemId = 31094, count = 1, minBid = 30000 }, -- Dubious Disc
    } },
    { kind = "TM or plate", chance = 80, limit = 2, items = {
        { itemId = 17346, count = 1, minBid = 10000 }, -- TM Double-Edge
        { itemId = 17349, count = 1, minBid = 10000 }, -- TM Ice Beam
        { itemId = 17352, count = 1, minBid = 5000 }, -- TM Submission
        { itemId = 17357, count = 1, minBid = 10000 }, -- TM Solar Beam
        { itemId = 17358, count = 1, minBid = 1000 }, -- TM Dragon Rage
        { itemId = 17359, count = 1, minBid = 5000 }, -- TM Thunderbolt
        { itemId = 17362, count = 1, minBid = 10000 }, -- TM Fissure
        { itemId = 17363, count = 1, minBid = 5000 }, -- TM Psychic
        { itemId = 17368, count = 1, minBid = 10000 }, -- TM Metronome
        { itemId = 17370, count = 1, minBid = 10000 }, -- TM Egg Bomb
        { itemId = 17371, count = 1, minBid = 10000 }, -- TM Fire Blast
        { itemId = 17375, count = 1, minBid = 5000 }, -- TM Dream Eater
        { itemId = 17376, count = 1, minBid = 10000 }, -- TM Sky Attack
        { itemId = 17378, count = 1, minBid = 5000 }, -- TM Thunder Wave
        { itemId = 17379, count = 1, minBid = 10000 }, -- TM Psywave
        { itemId = 17381, count = 1, minBid = 5000 }, -- TM Rock Slide
        { itemId = 17382, count = 1, minBid = 5000 }, -- TM Tri Attack
        { itemId = 18912, count = 1, minBid = 10000 }, -- TM Dynamic Punch
        { itemId = 18913, count = 1, minBid = 5000 }, -- TM Headbutt
        { itemId = 18914, count = 1, minBid = 5000 }, -- TM Curse
        { itemId = 18915, count = 1, minBid = 10000 }, -- TM Zap Cannon
        { itemId = 18916, count = 1, minBid = 1000 }, -- TM Snore
        { itemId = 18917, count = 1, minBid = 5000 }, -- TM Icy Wind
        { itemId = 18918, count = 1, minBid = 5000 }, -- TM Protect
        { itemId = 18919, count = 1, minBid = 10000 }, -- TM Rain Dance
        { itemId = 18920, count = 1, minBid = 10000 }, -- TM Giga Drain
        { itemId = 18921, count = 1, minBid = 5000 }, -- TM Iron Tail
        { itemId = 18922, count = 1, minBid = 5000 }, -- TM Shadow Ball
        { itemId = 18923, count = 1, minBid = 1000 }, -- TM Mud-Slap
        { itemId = 18924, count = 1, minBid = 5000 }, -- TM Ice Punch
        { itemId = 18925, count = 1, minBid = 5000 }, -- TM Sludge Bomb
        { itemId = 18926, count = 1, minBid = 1000 }, -- TM Defense Curl
        { itemId = 18927, count = 1, minBid = 5000 }, -- TM Thunder Punch
        { itemId = 18928, count = 1, minBid = 5000 }, -- TM Steel Wing
        { itemId = 18929, count = 1, minBid = 5000 }, -- TM Fire Punch
        { itemId = 18930, count = 1, minBid = 5000 }, -- TM Fury Cutter
        { itemId = 12229, count = 1, minBid = 7000 }, -- Flame Plate
        { itemId = 12230, count = 1, minBid = 6000 }, -- Splash Plate
        { itemId = 12231, count = 1, minBid = 3000 }, -- Meadow Plate
        { itemId = 12232, count = 1, minBid = 5000 }, -- Love Plate
        { itemId = 12233, count = 1, minBid = 10000 }, -- Mind Plate
        { itemId = 12234, count = 1, minBid = 4000 }, -- Stone Plate
        { itemId = 12235, count = 1, minBid = 3000 }, -- Toxic Plate
        { itemId = 12236, count = 1, minBid = 5000 }, -- Icicle Plate
        { itemId = 12237, count = 1, minBid = 5000 }, -- Zap Plate
        { itemId = 12240, count = 1, minBid = 15000 }, -- Draco Plate
        { itemId = 12241, count = 1, minBid = 2000 }, -- Insect Plate
        { itemId = 12242, count = 1, minBid = 10000 }, -- Dread Plate
        { itemId = 12243, count = 1, minBid = 10000 }, -- Fist Plate
        { itemId = 13807, count = 1, minBid = 5000 }, -- Earth Plate
        { itemId = 17814, count = 1, minBid = 10000 }, -- Iron Plate
        { itemId = 18081, count = 1, minBid = 5000 }, -- Sky Plate
        { itemId = 18082, count = 1, minBid = 10000 }, -- Spooky Plate
        { itemId = 23946, count = 1, minBid = 8000 }, -- Pixie Plate
    } },
    { kind = "Weekly cookies", chance = 100, limit = 3, items = {
        { itemId = 13305, count = 100, minBid = 5000 }, -- Lava Cookie
    } },
    { kind = "Once per trainer", chance = 100, limit = 1, items = {
        { itemId = 23546, count = 1, minBid = 1000, unique = true, once = true }, -- Blue Flute
    } },
}

local CLIENT = playersStorages.pokeTraderClient
local NPC = playersStorages.pokeTraderNpc
local lastTick = 0

local function formatNumber(amount)
    local text = tostring(math.floor(amount))
    local formatted
    repeat
        text, formatted = text:gsub("^(-?%d+)(%d%d%d)", "%1,%2")
    until formatted == 0
    return text
end

local function dollars(amount)
    return "$" .. formatNumber(amount)
end

local function world()
    return tonumber(getConfigValue("worldId")) or 0
end

local function each(query, fn)
    local r = db.getResult(query)
    if (r:getID() == -1) then
        return
    end
    repeat
        fn(r)
    until not r:next()
    r:free()
end

local function send(cid, data)
    doSendPlayerExtendedOpcode(cid, EXTENDED_IDS.POKETRADER, JSON.encode(data))
end

local function result(cid, ok, text)
    send(cid, { type = "result", ok = ok, text = text })
    return ok, text
end

-- the lowest amount that beats value by the step
PokeTrader.stepUp = function(value)
    return math.ceil(value * (100 + PokeTrader.STEP_PERCENT) / 100)
end

-- The leader and the price of a lot. bids: {{guid, max}, ...} in the order the maximums were set.
PokeTrader.standing = function(bids, minBid)
    local top = 0
    for _, bid in ipairs(bids) do
        top = math.max(top, bid.max)
    end
    local leader
    for _, bid in ipairs(bids) do
        if (PokeTrader.stepUp(bid.max) > top) then
            leader = bid
            break
        end
    end
    if (not leader) then
        return nil, minBid
    end
    local second
    for _, bid in ipairs(bids) do
        if (bid ~= leader and (not second or bid.max > second)) then
            second = bid.max
        end
    end
    local price = second and math.min(leader.max, PokeTrader.stepUp(second)) or minBid
    return leader, math.max(price, minBid)
end

-- the next end of a week after now: END_WDAY at END_HOUR, at least MIN_WEEK away
PokeTrader.nextEnd = function(now)
    local t = os.date("*t", now)
    t.hour, t.min, t.sec, t.isdst = PokeTrader.END_HOUR, 0, 0, nil
    t.day = t.day + (PokeTrader.END_WDAY - t.wday) % 7
    local deadline = os.time(t)
    while (deadline < now + PokeTrader.MIN_WEEK) do
        t.day = t.day + 7
        deadline = os.time(t)
    end
    return deadline
end

local function configOf(itemId, count)
    for _, group in ipairs(PokeTrader.GROUPS) do
        for _, item in ipairs(group.items) do
            if (item.itemId == itemId and item.count == count) then
                return item, group
            end
        end
    end
    return nil
end

PokeTrader.lots = function()
    local lots = {}
    each(string.format("SELECT `id`, `item_id`, `count`, `min_bid`, `deadline` FROM `poketrader_offerts`" ..
            " WHERE `world_id` = %d ORDER BY `id`;", world()), function(r)
        lots[#lots + 1] = { id = r:getDataInt("id"), itemId = r:getDataInt("item_id"), count = r:getDataInt("count"),
                            minBid = r:getDataLong("min_bid"), deadline = r:getDataLong("deadline") }
    end)
    return lots
end

local function lotById(id)
    id = tonumber(id)
    for _, lot in ipairs(PokeTrader.lots()) do
        if (lot.id == id) then
            return lot
        end
    end
    return nil
end

-- the bids on a lot, in the order their maximums were set
PokeTrader.bidsOf = function(lotId)
    local bids = {}
    each(string.format("SELECT `id`, `player_id`, `bid`, `max_bid`, `created` FROM `poketrader_bids`" ..
            " WHERE `offert_id` = %d ORDER BY `created`, `id`;", lotId), function(r)
        bids[#bids + 1] = { id = r:getDataInt("id"), guid = r:getDataInt("player_id"),
                            max = math.max(r:getDataLong("max_bid"), r:getDataLong("bid")) }
    end)
    return bids
end

local function bidOf(bids, guid)
    for _, bid in ipairs(bids) do
        if (bid.guid == guid) then
            return bid
        end
    end
    return nil
end

local function wonBefore(guid, itemId)
    local won = false
    each(string.format("SELECT 1 FROM `datalog_poketrader_boughts` WHERE `player_id` = %d AND `item_id` = %d LIMIT 1;",
        guid, itemId), function() won = true end)
    return won
end

local function nameOf(guid)
    local name = getPlayerNameByGUID(guid)
    return type(name) == "string" and name or nil
end

local function online(guid)
    local name = nameOf(guid)
    local cid = name and getPlayerByName(name)
    return cid and isPlayer(cid) and cid or nil
end

local function refund(guid, amount)
    local name = nameOf(guid)
    if (amount > 0 and not (name and doPlayerAddBalanceByName(name, amount))) then
        log(LOG_TYPES.ERROR, "PokeTrader: could not give back money.", guid, amount)
    end
end

-- takes amount from the bank, then from the money carried
local function hold(cid, amount)
    local balance, money = getPlayerBalance(cid), getPlayerMoney(cid)
    if (balance + money < amount) then
        return false
    end
    local fromBank = math.min(balance, amount)
    if (amount > fromBank and not doPlayerRemoveMoney(cid, amount - fromBank)) then
        return false
    end
    doPlayerSetBalance(cid, balance - fromBank)
    return true
end

PokeTrader.start = function(now)
    now = now or os.time()
    local deadline = PokeTrader.nextEnd(now)
    local values = {}
    for _, group in ipairs(PokeTrader.GROUPS) do
        if (getRandom(1, 100) <= group.chance) then
            local items = table.deepcopy(group.items)
            for _ = 1, group.limit do
                if (#items > 0) then
                    local item = table.randomRemove(items)
                    values[#values + 1] = string.format("(%d, %d, %d, %d, %d, %d)", item.itemId, item.count,
                        item.minBid, now, deadline, world())
                end
            end
        end
    end
    if (#values == 0) then
        return false
    end
    return db.executeQuery("INSERT INTO `poketrader_offerts` (`item_id`, `count`, `min_bid`, `created`, `deadline`," ..
        " `world_id`) VALUES " .. table.concat(values, ", ") .. ";")
end

local function deliver(lot, guid, pos)
    local name = nameOf(guid)
    local item = name and doCreateItem(lot.itemId, lot.count, pos)
    if (not item) then
        return false
    end
    local config = configOf(lot.itemId, lot.count)
    if (config and config.unique) then
        setItemUniqueOwner(item, 0, guid)
    end
    if (not doPlayerAddDepotItemByName(name, item)) then
        doRemoveItem(item)
        return false
    end
    return true
end

-- Ends the week: every lot goes to its leader (to the depot, through pos) or nobody, and the money comes back.
PokeTrader.finish = function(lots, pos)
    local now = os.time()
    for _, lot in ipairs(lots) do
        local bids = PokeTrader.bidsOf(lot.id)
        local leader, price = PokeTrader.standing(bids, lot.minBid)
        local itemName = getItemNameById(lot.itemId)
        for _, bid in ipairs(bids) do
            if (bid == leader) then
                if (deliver(lot, bid.guid, pos)) then
                    doDatalogPokeTraderBought(bid.guid, lot.itemId, lot.count, price, now)
                    refund(bid.guid, bid.max - price)
                    local cid = online(bid.guid)
                    if (cid) then
                        doPlayerSendTextMessage(cid, MESSAGE_EVENT_ADVANCE, string.format(__L(cid,
                            "You won the %s at the PokeTrader auction for %s. It is in your depot."), itemName,
                            dollars(price)))
                    end
                else
                    log(LOG_TYPES.ERROR, "PokeTrader: could not deliver a lot; the bid goes back.", bid.guid, lot.itemId)
                    refund(bid.guid, bid.max)
                end
            else
                refund(bid.guid, bid.max)
                local cid = online(bid.guid)
                if (cid) then
                    doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_ORANGE, string.format(__L(cid,
                        "The PokeTrader auction is over. Someone else won the %s; your %s is back in your bank."),
                        itemName, dollars(bid.max)))
                end
            end
        end
        if (not leader) then
            doDatalogPokeTraderBought(0, lot.itemId, lot.count, 0, now)
        end
        db.executeQuery(string.format("DELETE FROM `poketrader_bids` WHERE `offert_id` = %d;", lot.id))
        db.executeQuery(string.format("DELETE FROM `poketrader_bid_log` WHERE `offert_id` = %d;", lot.id))
        db.executeQuery(string.format("DELETE FROM `poketrader_offerts` WHERE `id` = %d;", lot.id))
    end
end

-- Tiger Kelsey's think: ends the week when it is over and puts out the next lots. force skips the TICK wait.
PokeTrader.tick = function(npc, force)
    local now = os.time()
    if (not force and now - lastTick < PokeTrader.TICK) then
        return
    end
    lastTick = now
    local lots = PokeTrader.lots()
    local deadline
    for _, lot in ipairs(lots) do
        deadline = math.min(deadline or lot.deadline, lot.deadline)
    end
    if (deadline and deadline > now) then
        return
    end
    if (#lots > 0) then
        PokeTrader.finish(lots, getCreaturePosition(npc))
    end
    PokeTrader.start(now)
end

-- Puts the lot's bids in their columns after a change and logs a new price or leader.
local function reprice(lot, before, actor)
    local bids = PokeTrader.bidsOf(lot.id)
    local leader, price = PokeTrader.standing(bids, lot.minBid)
    for _, bid in ipairs(bids) do
        db.executeQuery(string.format("UPDATE `poketrader_bids` SET `bid` = %d WHERE `id` = %d;",
            bid == leader and price or bid.max, bid.id))
    end
    if (leader and (not before.leader or before.leader.guid ~= leader.guid or before.price ~= price)) then
        db.executeQuery(string.format("INSERT INTO `poketrader_bid_log` (`offert_id`, `player_id`, `price`, `auto`," ..
            " `created`) VALUES (%d, %d, %d, %d, %d);", lot.id, leader.guid, price, leader.guid ~= actor and 1 or 0,
            os.time()))
    end
    return leader, price
end

local function isOpen(cid)
    return type(getPlayerStorageValue(cid, NPC)) == "string"
end

local function notifyOutbid(before, leader, price, lot, actor)
    local old = before.leader
    if (not old or (leader and old.guid == leader.guid) or old.guid == actor) then
        return
    end
    local cid = online(old.guid)
    if (not cid) then
        return
    end
    doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_ORANGE, string.format(__L(cid, "You were outbid on the %s (%s)."),
        getItemNameById(lot.itemId), dollars(price)))
    if (isOpen(cid)) then
        send(cid, { type = "outbid", id = lot.id })
        PokeTrader.sendState(cid)
    end
end

-- Sets the trainer's maximum on a lot. Gives back ok and the answer for the trainer.
PokeTrader.setMax = function(cid, lotId, amount)
    local lot = lotById(lotId)
    if (not lot or lot.deadline <= os.time()) then
        return false, __L(cid, "That lot is not up for auction any more.")
    end
    amount = tonumber(amount)
    if (not amount or amount ~= math.floor(amount) or amount < 1) then
        return false, __L(cid, "Say a whole number of dollars.")
    end
    local guid = getPlayerGUID(cid)
    local itemName = getItemNameById(lot.itemId)
    local config = configOf(lot.itemId, lot.count)
    if (config and config.once and wonBefore(guid, lot.itemId)) then
        return false, string.format(__L(cid, "You already won a %s. Each trainer can only have one."), itemName)
    end

    local bids = PokeTrader.bidsOf(lot.id)
    local leader, price = PokeTrader.standing(bids, lot.minBid)
    local mine = bidOf(bids, guid)
    local leading = mine and mine == leader
    if (mine and amount == mine.max) then
        return false, string.format(__L(cid, "Your maximum on the %s is already %s."), itemName, dollars(amount))
    end
    if (leading and amount < mine.max) then
        return false, __L(cid, "Your bid is the highest, so you can only raise your maximum.")
    end
    local lowest = leader and not leading and PokeTrader.stepUp(price) or lot.minBid
    if (amount < lot.minBid or (amount < lowest and not (mine and amount < mine.max))) then
        return false, string.format(__L(cid, "Your maximum has to be at least %s."), dollars(lowest))
    end

    local extra = amount - (mine and mine.max or 0)
    if (extra > 0 and not hold(cid, extra)) then
        return false, string.format(__L(cid, "You need %s in your bank or bag to set that maximum."), dollars(extra))
    end
    if (extra < 0) then
        refund(guid, -extra)
    end
    local now = os.time()
    if (mine) then
        -- the leader raising keeps their place in the order, anyone else's new maximum counts from now
        db.executeQuery(string.format("UPDATE `poketrader_bids` SET `max_bid` = %d%s WHERE `id` = %d;", amount,
            leading and "" or (", `created` = " .. now), mine.id))
    else
        db.executeQuery(string.format("INSERT INTO `poketrader_bids` (`player_id`, `offert_id`, `created`, `bid`," ..
            " `max_bid`) VALUES (%d, %d, %d, 0, %d);", guid, lot.id, now, amount))
        doPlayerAddStatistic(cid, PLAYER_STATISTIC_IDS.BID_ON_POKETRADER, 1)
    end

    local before = { leader = leader, price = price }
    local newLeader, newPrice = reprice(lot, before, guid)
    notifyOutbid(before, newLeader, newPrice, lot, guid)
    if (newLeader and newLeader.guid == guid) then
        return true, string.format(__L(cid, "Your bid on the %s is the highest: %s. Your maximum is %s."), itemName,
            dollars(newPrice), dollars(amount))
    end
    return true, string.format(__L(cid, "Someone's maximum on the %s is higher, so the price is now %s. Your %s stays" ..
        " held until you raise it or take it back."), itemName, dollars(newPrice), dollars(amount))
end

-- Takes the trainer's bid back while someone else leads.
PokeTrader.takeBack = function(cid, lotId)
    local lot = lotById(lotId)
    if (not lot) then
        return false, __L(cid, "That lot is not up for auction any more.")
    end
    local guid = getPlayerGUID(cid)
    local bids = PokeTrader.bidsOf(lot.id)
    local leader, price = PokeTrader.standing(bids, lot.minBid)
    local mine = bidOf(bids, guid)
    if (not mine) then
        return false, __L(cid, "You have no bid on that lot.")
    end
    if (mine == leader) then
        return false, __L(cid, "You can't take your bid back while it is the highest.")
    end
    db.executeQuery(string.format("DELETE FROM `poketrader_bids` WHERE `id` = %d;", mine.id))
    refund(guid, mine.max)
    reprice(lot, { leader = leader, price = price }, guid)
    return true, string.format(__L(cid, "You took back your bid on the %s. Your %s is in your bank."),
        getItemNameById(lot.itemId), dollars(mine.max))
end

-- One line per lot for the chat (only the lots the trainer bid on with mineOnly)
PokeTrader.describe = function(cid, mineOnly)
    local lines = {}
    local guid = getPlayerGUID(cid)
    for _, lot in ipairs(PokeTrader.lots()) do
        local bids = PokeTrader.bidsOf(lot.id)
        local leader, price = PokeTrader.standing(bids, lot.minBid)
        local mine = bidOf(bids, guid)
        local line = string.format("%s (%dx): ", getItemNameById(lot.itemId), lot.count) ..
            (leader and string.format(__L(cid, "highest bid %s"), dollars(price)) or
                string.format(__L(cid, "no bids yet, minimum %s"), dollars(lot.minBid)))
        if (mine) then
            line = line .. string.format(__L(cid, ", your maximum %s (%s)"), dollars(mine.max),
                mine == leader and __L(cid, "the highest") or __L(cid, "outbid"))
        end
        if (mine or not mineOnly) then
            lines[#lines + 1] = line
        end
    end
    return lines
end

-- The lot whose item name has the text in it, for the chat
PokeTrader.findLot = function(text)
    text = text:lower()
    for _, lot in ipairs(PokeTrader.lots()) do
        local name = getItemNameById(lot.itemId):lower()
        if (text:find(name, 1, true) or (#text >= 3 and name:find(text, 1, true))) then
            return lot
        end
    end
    return nil
end

PokeTrader.timeLeft = function()
    local deadline
    for _, lot in ipairs(PokeTrader.lots()) do
        deadline = math.min(deadline or lot.deadline, lot.deadline)
    end
    return deadline and math.max(0, deadline - os.time()) or nil
end

-- the window

PokeTrader.enabled = function(cid)
    return isPlayer(cid) and getPlayerStorageValue(cid, CLIENT) == 1
end

local function npcNear(cid)
    local name = getPlayerStorageValue(cid, NPC)
    if (type(name) ~= "string") then
        return nil
    end
    for _, creature in ipairs(getSpectators(getCreaturePosition(cid), PokeTrader.RANGE, PokeTrader.RANGE, false) or {}) do
        if (isNpc(creature) and getCreatureName(creature) == name) then
            return creature
        end
    end
    return nil
end

local function wonRecently(guid)
    local rows = JSON.array()
    each(string.format("SELECT `item_id`, `count`, `bid`, `date` FROM `datalog_poketrader_boughts` WHERE `player_id` = %d" ..
            " AND `date` >= %d ORDER BY `date` DESC, `id` DESC;", guid, os.time() - PokeTrader.HISTORY_DAYS * 86400),
        function(r)
            local itemId = r:getDataInt("item_id")
            rows[#rows + 1] = { client = getItemClientId(itemId) or 0, name = getItemNameById(itemId),
                                count = r:getDataInt("count"), bid = r:getDataLong("bid"), date = r:getDataLong("date") }
        end)
    return rows
end

PokeTrader.sendState = function(cid)
    local guid = getPlayerGUID(cid)
    local lots, held, ends = JSON.array(), 0, 0
    for _, lot in ipairs(PokeTrader.lots()) do
        local bids = PokeTrader.bidsOf(lot.id)
        local leader, price = PokeTrader.standing(bids, lot.minBid)
        local mine = bidOf(bids, guid)
        local config, group = configOf(lot.itemId, lot.count)
        local status = "open"
        if (config and config.once and wonBefore(guid, lot.itemId)) then
            status = "owned"
        elseif (mine) then
            status = mine == leader and "leading" or "outbid"
        elseif (not leader) then
            status = "none"
        end
        held = held + (mine and mine.max or 0)
        ends = ends == 0 and lot.deadline or math.min(ends, lot.deadline)
        lots[#lots + 1] = {
            id = lot.id, item = lot.itemId, client = getItemClientId(lot.itemId) or 0,
            name = getItemNameById(lot.itemId), count = lot.count, kind = group and group.kind or "",
            min = lot.minBid, price = leader and price or 0, bids = #bids, mine = mine and mine.max or 0,
            status = status,
            lowest = (mine and mine == leader) and mine.max + 1 or (leader and PokeTrader.stepUp(price) or lot.minBid),
        }
    end
    local npc = getPlayerStorageValue(cid, NPC)
    send(cid, { type = "trader", npc = type(npc) == "string" and npc or "", balance = getPlayerBalance(cid),
                money = getPlayerMoney(cid), held = held, ends = ends, now = os.time(), lots = lots,
                won = wonRecently(guid) })
end

local function sendLog(cid, lotId)
    local lot = lotById(lotId)
    if (not lot) then
        return
    end
    local guid = getPlayerGUID(cid)
    local rows = JSON.array()
    each(string.format("SELECT `player_id`, `price`, `auto`, `created` FROM `poketrader_bid_log` WHERE `offert_id` = %d" ..
            " ORDER BY `id` DESC LIMIT %d;", lot.id, PokeTrader.LOG_ROWS), function(r)
        rows[#rows + 1] = { price = r:getDataLong("price"), auto = r:getDataInt("auto") == 1,
                            mine = r:getDataInt("player_id") == guid, date = r:getDataLong("created") }
    end)
    send(cid, { type = "log", id = lot.id, rows = rows })
end

local function sendHistory(cid)
    local rows = JSON.array()
    each(string.format("SELECT `player_id`, `item_id`, `count`, `bid`, `date` FROM `datalog_poketrader_boughts`" ..
            " WHERE `date` >= %d ORDER BY `date` DESC, `id` DESC;", os.time() - PokeTrader.HISTORY_DAYS * 86400),
        function(r)
            local itemId, winner = r:getDataInt("item_id"), r:getDataInt("player_id")
            rows[#rows + 1] = { date = r:getDataLong("date"), client = getItemClientId(itemId) or 0,
                                name = getItemNameById(itemId), count = r:getDataInt("count"),
                                winner = winner > 0 and (nameOf(winner) or "?") or "", bid = r:getDataLong("bid") }
        end)
    send(cid, { type = "history", rows = rows })
end

PokeTrader.onLogin = function(cid)
    setPlayerStorageValue(cid, CLIENT, -1)
    setPlayerStorageValue(cid, NPC, -1)
end

-- Tiger Kelsey's "auction": opens the window. False for clients without it.
PokeTrader.open = function(cid, npc)
    if (not PokeTrader.enabled(cid)) then
        return false
    end
    if (#PokeTrader.lots() == 0) then
        PokeTrader.tick(npc, true)
    end
    setPlayerStorageValue(cid, NPC, getCreatureName(npc))
    PokeTrader.sendState(cid)
    return true
end

PokeTrader.onClientMessage = function(cid, buffer)
    local ok, data = pcall(JSON.decode, buffer)
    if (not ok or type(data) ~= "table") then
        return
    end
    if (data.action == "hello") then
        setPlayerStorageValue(cid, CLIENT, 1)
        return
    end
    if (data.action == "close") then
        setPlayerStorageValue(cid, NPC, -1)
        return
    end
    if (not npcNear(cid)) then
        setPlayerStorageValue(cid, NPC, -1)
        send(cid, { type = "close" })
        return result(cid, false, __L(cid, "You walked away from the PokeTrader."))
    end

    if (data.action == "bid") then
        local done, text = PokeTrader.setMax(cid, data.id, data.max)
        PokeTrader.sendState(cid)
        sendLog(cid, data.id)
        result(cid, done, text)
    elseif (data.action == "takeback") then
        local done, text = PokeTrader.takeBack(cid, data.id)
        PokeTrader.sendState(cid)
        sendLog(cid, data.id)
        result(cid, done, text)
    elseif (data.action == "log") then
        sendLog(cid, data.id)
    elseif (data.action == "history") then
        sendHistory(cid)
    elseif (data.action == "refresh") then
        PokeTrader.sendState(cid)
    end
end
