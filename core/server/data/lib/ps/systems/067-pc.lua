-- PC: the depot window, one window with four tabs, opened at a Pokemon Center locker
-- (events/actions/pcLocker.lua). Four parts:
--   Poke boxes: Pokemon only, 40 boxes of 30, filled in order. A Pokemon in a box is a database row
--     with its ball's attributes, the same way the GTS and the Day Care keep them.
--   Stash: stackable items, and held items, as item and count.
--   Inbox: deliveries (items that didn't fit, rewards, GTS purchases, mail), no limit.
--   Depot: the old containers, for everything else; "Open depot" opens them as before.
--
-- Modern clients register with a hello over extended opcode at login; only those players get the PC, everyone
-- else keeps the old depot. It sends "/pc <action> ..." (extended opcode JSON) and draws the
-- EXTENDED_IDS.PC JSON that comes back.
--
-- Deliveries still go through doPlayerAddDepotItem: for PC players the item is marked and put in the
-- depot as before (so the script that delivered it can keep using it), and PC.collect moves what is
-- marked, and anything left loose in the locker (mail), into the Poke boxes or the inbox right after.

PC = {}

PC.BOXES = 40
PC.BOX_SIZE = 30
PC.RANGE = 4 -- tiles from the locker
PC.CENTER_RANGE = 10 -- a locker this close to Nurse Joy, on her floor, is in a Pokemon Center
PC.STAFF_ACCESS = 5
PC.LIST_LIMIT = 80
PC.SEARCH_LIMIT = 40
PC.NAME_LENGTH = 16

local MESSAGE_LIMIT = 14000
local SESSION = playersStorages.pcSession
local CLIENT = playersStorages.pcClient
local MIGRATED = playersStorages.pcMigrated
local CLASSIC = playersStorages.pcClassic
local DELIVERED = "pcDelivery" -- item attribute: put in the depot by a delivery
local DEPOT_CHEST = 2594 -- ITEM_DEPOT in the server, the chest every locker holds

local LOCKERS = { [2589] = true, [2590] = true, [2591] = true, [2592] = true, [13015] = true }
PC.LOCKERS = LOCKERS

-- stash categories follow the GTS; held items don't stack but keep nothing of their own (their
-- level and experience are on the Pokemon's ball)
local CATEGORY_OF, HELD = {}, {}
for _, category in ipairs(GTS.CATEGORIES) do
    for _, id in ipairs(category.items) do
        CATEGORY_OF[id] = category.name
        if (category.name == "Held Items") then
            HELD[id] = true
        end
    end
end

local function send(cid, data, list)
    local text = JSON.encode(data)
    while (#text > MESSAGE_LIMIT and list and #list > 0) do
        table.remove(list)
        data.more = true
        text = JSON.encode(data)
    end
    doSendPlayerExtendedOpcode(cid, EXTENDED_IDS.PC, text)
end

local function result(cid, ok, text, ...)
    send(cid, { type = "result", ok = ok, text = string.format(__L(cid, text), ...) })
    return ok
end

local function escape(text)
    return db.escapeString(text)
end

local function itemName(itemid)
    local info = getItemInfo(itemid)
    return info and string.capitalise(info.name) or "?"
end

local function clientId(itemid)
    local info = getItemInfo(itemid)
    return info and info.clientId or 0
end

local function isShiny(name)
    return name:find("^Shiny ") ~= nil
end

local function pokemonRow(name, level)
    return { name = name, level = level, number = getPokemonNumberByName(name), face = GTS.faceOf(name),
        shiny = isShiny(name) or nil }
end

local function getResult(query)
    local r = db.getResult(query)
    if (r:getID() == -1) then
        return nil
    end
    return r
end

local function each(query, fn)
    local r = getResult(query)
    if (not r) then
        return
    end
    repeat
        fn(r)
    until not r:next()
    r:free()
end

local function count(query)
    local r = getResult(query)
    if (not r) then
        return 0
    end
    local total = r:getDataInt('total')
    r:free()
    return total
end

-- a ball (or item) rebuilt from a row, to read it
local function loadRow(r, itemtype)
    local uid = doCreateItemEx(itemtype)
    if (not uid) then
        return nil
    end
    if (r:getDataInt('attrlen') > 0) then
        doItemLoadAttributes(uid, 'attributes', r:getID())
    end
    return uid
end

PC.enabled = function(cid)
    return isPlayer(cid) and getCreatureStorage(cid, CLIENT) == 1
end

-- offline trainers who already use the PC get deliveries in their inbox
local function offlineEnabled(guid)
    return count(string.format("SELECT COUNT(*) AS `total` FROM `player_storage` WHERE `player_id` = %d AND `key` = %d"
        .. " AND `value` = '1'", guid, MIGRATED)) > 0
end

-- Poke boxes

local function boxCounts(guid)
    local counts = {}
    each(string.format("SELECT `box`, COUNT(*) AS `total` FROM `pc_boxes` WHERE `player_id` = %d GROUP BY `box`", guid),
        function(r) counts[r:getDataInt('box')] = r:getDataInt('total') end)
    return counts
end

local function freeSlot(guid, box)
    local used = {}
    each(string.format("SELECT `slot` FROM `pc_boxes` WHERE `player_id` = %d AND `box` = %d", guid, box),
        function(r) used[r:getDataInt('slot')] = true end)
    for slot = 1, PC.BOX_SIZE do
        if (not used[slot]) then
            return slot
        end
    end
    return nil
end

-- the first box with room, in order
local function firstFree(guid)
    local counts = boxCounts(guid)
    for box = 1, PC.BOXES do
        if ((counts[box] or 0) < PC.BOX_SIZE) then
            return box, freeSlot(guid, box)
        end
    end
    return nil
end

PC.boxesFull = function(cid)
    return firstFree(getPlayerGUID(cid)) == nil
end

-- boxes shown: up to the last one in use, plus a new empty one when that is full
local function shownBoxes(counts)
    local last = 0
    for box in pairs(counts) do
        last = math.max(last, box)
    end
    if (last == 0 or (counts[last] or 0) >= PC.BOX_SIZE) then
        last = last + 1
    end
    return math.min(math.max(last, 1), PC.BOXES)
end

local function boxNames(guid)
    local names = {}
    each(string.format("SELECT `box`, `name` FROM `pc_box_names` WHERE `player_id` = %d", guid),
        function(r) names[r:getDataInt('box')] = r:getDataString('name') end)
    return names
end

-- a ball into a box (the first free slot of box, or of the first box with room); the caller removes it
local function storeBall(guid, uid, box, slot)
    if (box) then
        slot = slot or freeSlot(guid, box)
        if (not slot) then
            return nil
        end
    else
        box, slot = firstFree(guid)
        if (not box) then
            return nil
        end
    end

    PokemonStats.ensureBall(uid)
    local attributes = getItemAttributesBlob(uid)
    if (not attributes) then
        return nil
    end
    local ok = db.executeQuery(string.format("INSERT INTO `pc_boxes` (`player_id`, `box`, `slot`, `ball_id`,"
            .. " `pokemon_name`, `pokemon_level`, `attributes`, `created`) VALUES (%d, %d, %d, %d, %s, %d, %s, %d)",
        guid, box, slot, getThing(uid).itemid, escape(getBallPokemonName(uid)), getBallPokemonLevel(uid), attributes,
        os.time()))
    return ok and box or nil
end

-- Inbox

local function storeInbox(guid, uid, source)
    local thing = getThing(uid)
    local attributes = getItemAttributesBlob(uid)
    local name, level = "", 0
    if (isBallWithPokemon(uid)) then
        PokemonStats.ensureBall(uid)
        attributes = getItemAttributesBlob(uid)
        name, level = getBallPokemonName(uid), getBallPokemonLevel(uid)
    end
    local amount = 1
    local info = getItemInfo(thing.itemid)
    if (info and info.stackable) then
        amount = math.max(thing.type, 1)
    end
    return db.executeQuery(string.format("INSERT INTO `pc_inbox` (`player_id`, `itemtype`, `count`, `pokemon_name`,"
            .. " `pokemon_level`, `attributes`, `source`, `created`) VALUES (%d, %d, %d, %s, %d, %s, %s, %d)",
        guid, thing.itemid, amount, escape(name), level, attributes or "NULL", escape(source or "Delivery"), os.time()))
end

-- a delivered item or ball: balls to the boxes (the inbox when they're full), the rest to the inbox
local function store(guid, uid, source)
    if (isBallWithPokemon(uid) and storeBall(guid, uid)) then
        return "box"
    elseif (storeInbox(guid, uid, source)) then
        return "inbox"
    end
    return nil
end

-- what a container holds, deepest first, then the container (containers themselves are dropped)
local function unpack(guid, uid, source, moved)
    if (isContainer(uid)) then
        for slot = getContainerSize(uid) - 1, 0, -1 do
            unpack(guid, getContainerItem(uid, slot).uid, source, moved)
        end
        doRemoveItem(uid)
        return
    end
    local where = store(guid, uid, source)
    if (where) then
        moved[where] = moved[where] + 1
        doRemoveItem(uid)
    end
end

-- Depot

local function depotChest(depot)
    for slot = 0, getContainerSize(depot) - 1 do
        local item = getContainerItem(depot, slot)
        if (item.itemid == DEPOT_CHEST) then
            return item.uid
        end
    end
    return doAddContainerItem(depot, DEPOT_CHEST)
end

-- marked deliveries in the depot chest, and whatever lies loose in the locker (mail), go to the PC
local pending = {}
local sendCounts

local function notifyChanged(cid)
    if (WindowSession.get(cid, SESSION)) then
        send(cid, { type = "changed" })
        sendCounts(cid)
    end
end
PC.collect = function(cid)
    pending[cid] = nil
    if (not PC.enabled(cid)) then
        return
    end
    local depot = getPlayerDepot(cid, 0)
    if (not depot) then
        return
    end

    local guid, moved = getPlayerGUID(cid), { box = 0, inbox = 0 }
    for slot = getContainerSize(depot) - 1, 0, -1 do
        local item = getContainerItem(depot, slot)
        if (item.itemid ~= DEPOT_CHEST) then
            unpack(guid, item.uid, isContainer(item.uid) and "Mail" or "Delivery", moved)
        end
    end

    local chest = depotChest(depot)
    if (chest) then
        for _, item in ipairs(getContainerItems(chest, true)) do
            -- a delivered bag stays in the depot as it is
            if (getItemAttribute(item.uid, DELIVERED)) then
                doItemEraseAttribute(item.uid, DELIVERED)
                if (not isContainer(item.uid)) then
                    local where = store(guid, item.uid)
                    if (where) then
                        moved[where] = moved[where] + 1
                        doRemoveItem(item.uid)
                    end
                end
            end
        end
    end

    if (moved.box + moved.inbox > 0) then
        doPlayerSave(cid)
        notifyChanged(cid)
    end
end

local function collectSoon(cid)
    if (not pending[cid]) then
        pending[cid] = true
        addEvent(PC.collect, 100, cid)
    end
end

local rawAddDepotItem = doPlayerAddDepotItem
local rawAddDepotItemByName = doPlayerAddDepotItemByName

-- stacks lose their attributes when they go into the chest, so they go to the inbox right away
function doPlayerAddDepotItem(cid, depotId, uid, intoChest)
    if (depotId ~= 0 or not PC.enabled(cid)) then
        return rawAddDepotItem(cid, depotId, uid, intoChest)
    end
    local info = getItemInfo(getThing(uid).itemid)
    if (info and info.stackable) then
        if (not storeInbox(getPlayerGUID(cid), uid, "Delivery")) then
            return false
        end
        doRemoveItem(uid)
        notifyChanged(cid)
        return true
    end
    doItemSetAttribute(uid, DELIVERED, 1)
    if (not rawAddDepotItem(cid, 0, uid, true) and not rawAddDepotItem(cid, 0, uid)) then
        doItemEraseAttribute(uid, DELIVERED)
        return false
    end
    collectSoon(cid)
    return true
end

function doPlayerAddDepotItemByName(name, uid)
    local cid = getPlayerByName(name)
    if (cid and isPlayer(cid)) then
        return doPlayerAddDepotItem(cid, 0, uid)
    end
    local guid = getPlayerGUIDByName(name)
    if (guid and offlineEnabled(guid) and store(guid, uid, "Delivery")) then
        doRemoveItem(uid)
        return true
    end
    return rawAddDepotItemByName(name, uid)
end

-- stash

local function stashable(item)
    if (isContainer(item.uid) or isBallWithPokemon(item.uid) or getItemUniqueOwner(item.uid) ~= ITEM_UNIQUE_OWNER_NONE) then
        return false
    end
    local info = getItemInfo(item.itemid)
    return info and (info.stackable or HELD[item.itemid]) and true or false
end

local function stashAdd(guid, itemtype, amount)
    return db.executeQuery(string.format("INSERT INTO `pc_stash` (`player_id`, `itemtype`, `count`) VALUES (%d, %d, %d)"
        .. " ON DUPLICATE KEY UPDATE `count` = `count` + %d", guid, itemtype, amount, amount))
end

local function stashCount(guid, itemtype)
    local r = getResult(string.format("SELECT `count` FROM `pc_stash` WHERE `player_id` = %d AND `itemtype` = %d",
        guid, itemtype))
    if (not r) then
        return 0
    end
    local amount = r:getDataLong('count')
    r:free()
    return amount
end

local function stashSet(guid, itemtype, amount)
    if (amount <= 0) then
        return db.executeQuery(string.format("DELETE FROM `pc_stash` WHERE `player_id` = %d AND `itemtype` = %d",
            guid, itemtype))
    end
    return db.executeQuery(string.format("UPDATE `pc_stash` SET `count` = %d WHERE `player_id` = %d AND `itemtype` = %d",
        amount, guid, itemtype))
end

-- what the bag holds that the stash takes, by item
local function bagStashables(cid)
    local items = {}
    local backpack = getPlayerSlotItem(cid, PLAYER_SLOT_BACKPACK)
    if (not isItem(backpack) or not isContainer(backpack.uid)) then
        return items
    end
    for _, item in ipairs(getContainerItems(backpack.uid, true)) do
        if (stashable(item)) then
            local entry = items[item.itemid]
            if (not entry) then
                entry = { itemtype = item.itemid, count = 0, uids = {} }
                items[item.itemid] = entry
            end
            entry.count = entry.count + math.max(item.type, 1)
            entry.uids[#entry.uids + 1] = { uid = item.uid, count = math.max(item.type, 1) }
        end
    end
    return items
end

-- Migration: the Pokemon in the old depot go to the boxes and what stacks to the stash, once
PC.migrate = function(cid)
    if (getCreatureStorage(cid, MIGRATED) == 1) then
        return
    end
    local depot = getPlayerDepot(cid, 0)
    if (not depot) then
        return
    end

    local guid, pokemon, stashed = getPlayerGUID(cid), 0, 0
    local chest = depotChest(depot)
    if (chest) then
        local items = getContainerItems(chest, true)
        for i = #items, 1, -1 do
            local item = items[i]
            if (isBallWithPokemon(item.uid)) then
                if (storeBall(guid, item.uid)) then
                    doRemoveItem(item.uid)
                    pokemon = pokemon + 1
                end
            elseif (stashable(item) and stashAdd(guid, item.itemid, math.max(item.type, 1))) then
                stashed = stashed + math.max(item.type, 1)
                doRemoveItem(item.uid)
            end
        end
    end

    doCreatureSetStorage(cid, MIGRATED, 1)
    doPlayerSave(cid)
    log(LOG_TYPES.INFO, "PC:migrate", getCreatureName(cid), pokemon, stashed)
    if (pokemon + stashed > 0) then
        doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, string.format(__L(cid,
            "Your depot was sorted: %d Pokemon moved to your Poke boxes and %d items to your stash. Use a locker at a Pokemon Center to see them."),
            pokemon, stashed))
    end
end

-- the client has the PC window
PC.hello = function(cid)
    if (PC.enabled(cid)) then
        return
    end
    doCreatureSetStorage(cid, CLIENT, 1)
    PC.migrate(cid)
    PC.collect(cid)
end

PC.onLogin = function(cid)
    doCreatureSetStorage(cid, CLIENT, -1)
    doCreatureSetStorage(cid, CLASSIC, -1)
    WindowSession.close(cid, SESSION)
end

-- session

PC.isOpen = function(cid)
    local ok, open = WindowSession.inRange(cid, SESSION, PC.RANGE)
    if (ok) then
        return true
    end
    if (open) then
        WindowSession.close(cid, SESSION)
        send(cid, { type = "close" })
        doPlayerSendCancel(cid, __L(cid, "You moved away from the PC."))
    end
    return false
end

PC.close = function(cid)
    WindowSession.close(cid, SESSION)
end

sendCounts = function(cid)
    local guid = getPlayerGUID(cid)
    send(cid, { type = "counts",
        inbox = count(string.format("SELECT COUNT(*) AS `total` FROM `pc_inbox` WHERE `player_id` = %d", guid)),
        pokemon = count(string.format("SELECT COUNT(*) AS `total` FROM `pc_boxes` WHERE `player_id` = %d", guid)),
        stash = count(string.format("SELECT COUNT(*) AS `total` FROM `pc_stash` WHERE `player_id` = %d", guid)) })
end

PC.inPokemonCenter = function(pos)
    for _, creature in ipairs(getSpectators(pos, PC.CENTER_RANGE, PC.CENTER_RANGE) or {}) do
        if (isNpc(creature) and getCreatureName(creature) == "Nurse Joy") then
            return true
        end
    end
    return false
end

-- from the locker; false lets the locker open as a container (lockers outside a Pokemon Center too)
PC.open = function(cid, pos, anywhere)
    if (not PC.enabled(cid) or (not anywhere and not PC.inPokemonCenter(pos))) then
        return false
    end
    if (getCreatureStorage(cid, CLASSIC) == 1) then
        doCreatureSetStorage(cid, CLASSIC, -1)
        return false
    end

    PC.collect(cid)
    WindowSession.open(cid, SESSION, anywhere)
    send(cid, { type = "open", locker = pos, boxes = PC.BOXES, boxSize = PC.BOX_SIZE })
    sendCounts(cid)
    PC.sendBox(cid, 1)
    PC.sendParty(cid)
    return true
end

-- the client uses the locker again right after this
PC.openDepot = function(cid)
    doCreatureSetStorage(cid, CLASSIC, 1)
    WindowSession.close(cid, SESSION)
    send(cid, { type = "useLocker" })
end

-- Poke boxes

PC.sendBox = function(cid, box)
    local guid = getPlayerGUID(cid)
    local counts, names = boxCounts(guid), boxNames(guid)
    local shown = shownBoxes(counts)
    box = math.min(math.max(box or 1, 1), shown)

    local boxes = {}
    for n = 1, shown do
        boxes[n] = { box = n, name = names[n] or string.format(__L(cid, "Box %d"), n), count = counts[n] or 0 }
    end
    local list = {}
    each(string.format("SELECT `id`, `slot`, `pokemon_name`, `pokemon_level`, `ball_id`, `attributes`,"
            .. " LENGTH(`attributes`) AS `attrlen` FROM `pc_boxes` WHERE `player_id` = %d AND `box` = %d", guid, box),
        function(r)
            local row = pokemonRow(r:getDataString('pokemon_name'), r:getDataInt('pokemon_level'))
            row.id, row.slot = r:getDataInt('id'), r:getDataInt('slot')
            local uid = loadRow(r, r:getDataInt('ball_id'))
            if (uid and isBallWithPokemon(uid)) then
                row.sex = getBallPokemonSex(uid)
                local summary = GTS.summary(uid)
                row.ivs, row.nature = summary.ivs, summary.nature
            end
            list[#list + 1] = row
        end)
    send(cid, { type = "box", box = box, boxes = boxes, list = list }, list)
end

local function getBoxRow(guid, id)
    return getResult(string.format("SELECT `id`, `box`, `slot`, `ball_id`, `pokemon_name`, `pokemon_level`, `attributes`,"
        .. " LENGTH(`attributes`) AS `attrlen` FROM `pc_boxes` WHERE `id` = %d AND `player_id` = %d", id, guid))
end

PC.sendPokemon = function(cid, id)
    local r = getBoxRow(getPlayerGUID(cid), id)
    if (not r) then
        return result(cid, false, "This Pokemon is not in your boxes anymore.")
    end
    local name, level = r:getDataString('pokemon_name'), r:getDataInt('pokemon_level')
    local data = pokemonRow(name, level)
    data.type, data.id, data.box, data.slot = "pokemon", id, r:getDataInt('box'), r:getDataInt('slot')
    data.ball = clientId(r:getDataInt('ball_id'))
    local uid = loadRow(r, r:getDataInt('ball_id'))
    r:free()
    if (uid and isBallWithPokemon(uid)) then
        GTS.describe(data, uid, name, level)
        data.nickname = getBallPokemonNickname and getBallPokemonNickname(uid) or nil
    end
    send(cid, data)
end

local function partyProblem(cid, ball)
    if (ball.uid == getPlayerSlotItem(cid, PLAYER_SLOT_BALL).uid
            and (isPokemonOnline(cid) or getPlayerMounted(cid) or isEvolving(cid))) then
        return "Put your Pokemon back in its ball first."
    end
    return nil
end

PC.sendPartyPokemon = function(cid, index, name)
    local ball = getPlayerAllBallsWithPokemon(cid)[index]
    if (not ball or getBallPokemonName(ball.uid) ~= name) then
        return result(cid, false, "This Pokemon is not with you anymore.")
    end
    local level = getBallPokemonLevel(ball.uid)
    local data = pokemonRow(name, level)
    data.type, data.index, data.ball = "pokemon", index, clientId(ball.itemid)
    GTS.describe(data, ball.uid, name, level)
    send(cid, data)
end

PC.sendParty = function(cid)
    local list = {}
    for index, ball in ipairs(getPlayerAllBallsWithPokemon(cid)) do
        local row = pokemonRow(getBallPokemonName(ball.uid), getBallPokemonLevel(ball.uid))
        row.index, row.sex = index, getBallPokemonSex(ball.uid)
        local problem = partyProblem(cid, ball)
        row.problem = problem and __L(cid, problem) or nil
        list[#list + 1] = row
    end
    send(cid, { type = "party", list = list, full = getPlayerFreeCap(cid) < 1 or nil }, list)
end

local function refreshBoxes(cid, box)
    PC.sendBox(cid, box)
    PC.sendParty(cid)
    sendCounts(cid)
end

-- the index-th Pokemon of the party list (uids only last one script run), if it is still that one
PC.deposit = function(cid, index, box, slot, name)
    local ball = getPlayerAllBallsWithPokemon(cid)[index]
    if (not ball or getBallPokemonName(ball.uid) ~= name) then
        return result(cid, false, "This Pokemon is not with you anymore.")
    end
    local problem = partyProblem(cid, ball)
    if (problem) then
        return result(cid, false, problem)
    end

    local guid = getPlayerGUID(cid)
    if (box and box > 0 and slot and slot > 0 and getResult(string.format("SELECT 1 FROM `pc_boxes` WHERE `player_id` = %d"
            .. " AND `box` = %d AND `slot` = %d", guid, box, slot))) then
        slot = nil
    end
    local stored = storeBall(guid, ball.uid, box and box > 0 and box or nil, slot and slot > 0 and slot or nil)
    if (not stored and box and box > 0) then
        stored = storeBall(guid, ball.uid)
    end
    if (not stored) then
        return result(cid, false, "Your Poke boxes are full.")
    end
    doRemoveItem(ball.uid)
    doPlayerSave(cid)
    refreshBoxes(cid, stored)
    return result(cid, true, "%s went to %s.", name, boxNames(guid)[stored] or string.format(__L(cid, "Box %d"), stored))
end

PC.withdraw = function(cid, id)
    local guid = getPlayerGUID(cid)
    local r = getBoxRow(guid, id)
    if (not r) then
        return result(cid, false, "This Pokemon is not in your boxes anymore.")
    end
    local box, name = r:getDataInt('box'), r:getDataString('pokemon_name')
    if (not isGamemaster(cid) and getPlayerFreeCap(cid) < 1) then
        r:free()
        return result(cid, false, "Your party is full. Put a Pokemon in a box first.")
    end
    local ball = doCreatePokemonBall(cid, r:getDataInt('ball_id'), nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
        nil, nil, nil, nil, nil, false, { column = 'attributes', result = r:getID() }, nil, true)
    r:free()
    if (not ball) then
        return result(cid, false, "There is no room in your bag.")
    end
    db.executeQuery(string.format("DELETE FROM `pc_boxes` WHERE `id` = %d", id))
    doPlayerSave(cid)
    refreshBoxes(cid, box)
    return result(cid, true, "%s is with you now.", name)
end

-- to another box (the first free slot, or the given one: a Pokemon there swaps places)
PC.move = function(cid, id, box, slot)
    local guid = getPlayerGUID(cid)
    local r = getBoxRow(guid, id)
    if (not r) then
        return result(cid, false, "This Pokemon is not in your boxes anymore.")
    end
    local fromBox, fromSlot = r:getDataInt('box'), r:getDataInt('slot')
    r:free()
    if (box < 1 or box > PC.BOXES) then
        return false
    end

    if (slot and slot >= 1 and slot <= PC.BOX_SIZE) then
        local other = getResult(string.format("SELECT `id` FROM `pc_boxes` WHERE `player_id` = %d AND `box` = %d"
            .. " AND `slot` = %d", guid, box, slot))
        if (other) then
            local otherId = other:getDataInt('id')
            other:free()
            if (otherId == id) then
                return true
            end
            db.executeQuery(string.format("UPDATE `pc_boxes` SET `box` = 0, `slot` = 0 WHERE `id` = %d", otherId))
            db.executeQuery(string.format("UPDATE `pc_boxes` SET `box` = %d, `slot` = %d WHERE `id` = %d", box, slot, id))
            db.executeQuery(string.format("UPDATE `pc_boxes` SET `box` = %d, `slot` = %d WHERE `id` = %d", fromBox,
                fromSlot, otherId))
        else
            db.executeQuery(string.format("UPDATE `pc_boxes` SET `box` = %d, `slot` = %d WHERE `id` = %d", box, slot, id))
        end
    else
        if (box == fromBox) then
            return true
        end
        slot = freeSlot(guid, box)
        if (not slot) then
            return result(cid, false, "That box is full.")
        end
        db.executeQuery(string.format("UPDATE `pc_boxes` SET `box` = %d, `slot` = %d WHERE `id` = %d", box, slot, id))
    end
    PC.sendBox(cid, fromBox)
    return true
end

PC.rename = function(cid, box, name)
    name = (name or ""):gsub("[^%w%s%-']", ""):gsub("^%s+", ""):gsub("%s+$", ""):sub(1, PC.NAME_LENGTH)
    if (box < 1 or box > PC.BOXES) then
        return false
    end
    local guid = getPlayerGUID(cid)
    if (name == "") then
        db.executeQuery(string.format("DELETE FROM `pc_box_names` WHERE `player_id` = %d AND `box` = %d", guid, box))
    else
        db.executeQuery(string.format("INSERT INTO `pc_box_names` (`player_id`, `box`, `name`) VALUES (%d, %d, %s)"
            .. " ON DUPLICATE KEY UPDATE `name` = %s", guid, box, escape(name), escape(name)))
    end
    PC.sendBox(cid, box)
    return true
end

-- Inbox

PC.sendInbox = function(cid)
    local list = {}
    each(string.format("SELECT `id`, `itemtype`, `count`, `pokemon_name`, `pokemon_level`, `source`, `created`"
            .. " FROM `pc_inbox` WHERE `player_id` = %d ORDER BY `id` DESC LIMIT %d", getPlayerGUID(cid), PC.LIST_LIMIT),
        function(r)
            local name, row = r:getDataString('pokemon_name'), nil
            if (name ~= "") then
                row = pokemonRow(name, r:getDataInt('pokemon_level'))
                row.pokemon = true
            else
                local itemtype = r:getDataInt('itemtype')
                row = { name = itemName(itemtype), client = clientId(itemtype) }
            end
            row.id, row.count = r:getDataInt('id'), r:getDataInt('count')
            row.source, row.created = __L(cid, r:getDataString('source')), r:getDataLong('created')
            list[#list + 1] = row
        end)
    send(cid, { type = "inbox", list = list }, list)
end

-- false when it doesn't fit; partly taken stacks stay with what is left
local function takeInbox(cid, r)
    local id, itemtype, amount = r:getDataInt('id'), r:getDataInt('itemtype'), r:getDataInt('count')
    if (r:getDataString('pokemon_name') ~= "") then
        if (not isGamemaster(cid) and getPlayerFreeCap(cid) < 1) then
            return false, "Your party is full. Send the Pokemon to a box instead."
        end
        local ball = doCreatePokemonBall(cid, itemtype, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
            nil, nil, false, { column = 'attributes', result = r:getID() }, nil, true)
        if (not ball) then
            return false, "There is no room in your bag."
        end
        db.executeQuery(string.format("DELETE FROM `pc_inbox` WHERE `id` = %d", id))
        return true
    end

    local info = getItemInfo(itemtype)
    local stack = info and info.stackable and 100 or 1
    local given = 0
    while (given < amount) do
        local n = math.min(stack, amount - given)
        local uid = doCreateItemEx(itemtype, n)
        if (not uid) then
            break
        end
        if (r:getDataInt('attrlen') > 0) then
            doItemLoadAttributes(uid, 'attributes', r:getID())
        end
        if (doPlayerAddItemEx(cid, uid, false) ~= RETURNVALUE_NOERROR) then
            break
        end
        given = given + n
    end
    if (given >= amount) then
        db.executeQuery(string.format("DELETE FROM `pc_inbox` WHERE `id` = %d", id))
        return true
    elseif (given > 0) then
        db.executeQuery(string.format("UPDATE `pc_inbox` SET `count` = %d WHERE `id` = %d", amount - given, id))
    end
    return false, "There is no room in your bag."
end

local INBOX_SELECT = "SELECT `id`, `itemtype`, `count`, `pokemon_name`, `attributes`, LENGTH(`attributes`) AS `attrlen`"
        .. " FROM `pc_inbox` WHERE `player_id` = %d"

local function afterInbox(cid)
    doPlayerSave(cid)
    PC.sendInbox(cid)
    PC.sendParty(cid)
    sendCounts(cid)
end

PC.take = function(cid, id)
    local r = getResult(string.format(INBOX_SELECT .. " AND `id` = %d", getPlayerGUID(cid), id))
    if (not r) then
        return result(cid, false, "This is not in your inbox anymore.")
    end
    local ok, problem = takeInbox(cid, r)
    r:free()
    afterInbox(cid)
    return ok and result(cid, true, "Taken.") or result(cid, false, problem)
end

PC.takeAll = function(cid)
    local taken, problem = 0, nil
    each(string.format(INBOX_SELECT .. " ORDER BY `id` ASC", getPlayerGUID(cid)), function(r)
        local ok, why = takeInbox(cid, r)
        if (ok) then
            taken = taken + 1
        else
            problem = problem or why
        end
    end)
    afterInbox(cid)
    if (problem) then
        return result(cid, taken > 0, "Took %d. %s", taken, __L(cid, problem))
    end
    return result(cid, true, "Took %d.", taken)
end

-- a Pokemon from the inbox to the first box with room
PC.inboxToBox = function(cid, id)
    local guid = getPlayerGUID(cid)
    local r = getResult(string.format(INBOX_SELECT .. " AND `id` = %d", guid, id))
    if (not r) then
        return result(cid, false, "This is not in your inbox anymore.")
    end
    local uid = r:getDataString('pokemon_name') ~= "" and loadRow(r, r:getDataInt('itemtype')) or nil
    r:free()
    if (not uid or not isBallWithPokemon(uid)) then
        return result(cid, false, "Only Pokemon go in the Poke boxes.")
    end
    local box = storeBall(guid, uid)
    if (not box) then
        return result(cid, false, "Your Poke boxes are full.")
    end
    db.executeQuery(string.format("DELETE FROM `pc_inbox` WHERE `id` = %d", id))
    afterInbox(cid)
    return result(cid, true, "Sent to %s.", boxNames(guid)[box] or string.format(__L(cid, "Box %d"), box))
end

-- Stash

PC.sendStash = function(cid)
    local list = {}
    each(string.format("SELECT `itemtype`, `count` FROM `pc_stash` WHERE `player_id` = %d", getPlayerGUID(cid)),
        function(r)
            local itemtype = r:getDataInt('itemtype')
            list[#list + 1] = { itemtype = itemtype, client = clientId(itemtype), name = itemName(itemtype),
                count = r:getDataLong('count'), category = CATEGORY_OF[itemtype] or "Other" }
        end)
    send(cid, { type = "stash", list = list }, list)
end

PC.sendBag = function(cid)
    local list = {}
    for itemtype, entry in pairs(bagStashables(cid)) do
        list[#list + 1] = { itemtype = itemtype, client = clientId(itemtype), name = itemName(itemtype),
            count = entry.count, category = CATEGORY_OF[itemtype] or "Other" }
    end
    table.sort(list, function(a, b) return a.name < b.name end)
    send(cid, { type = "bag", list = list }, list)
end

local function stowEntry(cid, entry, amount)
    local guid, stowed = getPlayerGUID(cid), 0
    for _, stack in ipairs(entry.uids) do
        if (stowed >= amount) then
            break
        end
        local n = math.min(stack.count, amount - stowed)
        if (doRemoveItem(stack.uid, n)) then
            stowed = stowed + n
        end
    end
    if (stowed > 0) then
        stashAdd(guid, entry.itemtype, stowed)
    end
    return stowed
end

local function afterStash(cid)
    doPlayerSave(cid)
    PC.sendStash(cid)
    PC.sendBag(cid)
    sendCounts(cid)
end

PC.stow = function(cid, itemtype, amount)
    local entry = bagStashables(cid)[itemtype]
    if (not entry) then
        return result(cid, false, "You don't have this item with you.")
    end
    local stowed = stowEntry(cid, entry, math.min(amount, entry.count))
    afterStash(cid)
    return result(cid, stowed > 0, "Stowed %dx %s.", stowed, itemName(itemtype))
end

PC.stowAll = function(cid)
    local stowed = 0
    for _, entry in pairs(bagStashables(cid)) do
        stowed = stowed + stowEntry(cid, entry, entry.count)
    end
    afterStash(cid)
    return result(cid, stowed > 0, stowed > 0 and "Stowed %d items." or "Nothing in your bag goes in the stash.",
        stowed)
end

PC.unstow = function(cid, itemtype, amount)
    local guid = getPlayerGUID(cid)
    local have = stashCount(guid, itemtype)
    amount = math.min(amount, have)
    if (amount <= 0) then
        return result(cid, false, "This is not in your stash.")
    end

    local info = getItemInfo(itemtype)
    local stack = info and info.stackable and 100 or 1
    -- the stash goes down first, so nothing is ever doubled
    stashSet(guid, itemtype, have - amount)
    local given = 0
    while (given < amount) do
        local n = math.min(stack, amount - given)
        local uid = doCreateItemEx(itemtype, n)
        if (not uid or doPlayerAddItemEx(cid, uid, false) ~= RETURNVALUE_NOERROR) then
            break
        end
        given = given + n
    end
    if (given < amount) then
        stashAdd(guid, itemtype, amount - given)
    end
    afterStash(cid)
    if (given == 0) then
        return result(cid, false, "There is no room in your bag.")
    end
    return result(cid, true, "Took %dx %s.", given, itemName(itemtype))
end

-- Depot

local function depotList(cid, filter)
    local list = {}
    local depot = getPlayerDepot(cid, 0)
    if (not depot) then
        return list
    end
    local function walk(uid, inside)
        for slot = 0, getContainerSize(uid) - 1 do
            local item = getContainerItem(uid, slot)
            local name = itemName(item.itemid)
            if (item.itemid == DEPOT_CHEST) then
                walk(item.uid, nil)
            else
                if (not filter or name:lower():find(filter, 1, true)) then
                    list[#list + 1] = { client = clientId(item.itemid), name = name,
                        count = getItemInfo(item.itemid).stackable and math.max(item.type, 1) or 1, inside = inside }
                end
                if (isContainer(item.uid)) then
                    walk(item.uid, name)
                end
            end
        end
    end
    walk(depot, nil)
    return list
end

PC.sendDepot = function(cid)
    local list = depotList(cid)
    send(cid, { type = "depot", list = list }, list)
end

-- Search: species in the boxes and inbox, items in the stash, inbox and depot

PC.search = function(cid, text)
    text = (text or ""):lower()
    if (#text < 2) then
        return send(cid, { type = "search", text = text, list = {} })
    end
    local guid, list = getPlayerGUID(cid), {}
    local like = escape("%" .. text .. "%")

    each(string.format("SELECT `id`, `box`, `slot`, `pokemon_name`, `pokemon_level` FROM `pc_boxes` WHERE `player_id` = %d"
            .. " AND `pokemon_name` LIKE %s ORDER BY `box`, `slot` LIMIT %d", guid, like, PC.SEARCH_LIMIT), function(r)
        local row = pokemonRow(r:getDataString('pokemon_name'), r:getDataInt('pokemon_level'))
        row.where, row.id, row.box = "box", r:getDataInt('id'), r:getDataInt('box')
        list[#list + 1] = row
    end)
    each(string.format("SELECT `itemtype`, `count` FROM `pc_stash` WHERE `player_id` = %d", guid), function(r)
        local itemtype = r:getDataInt('itemtype')
        local name = itemName(itemtype)
        if (name:lower():find(text, 1, true)) then
            list[#list + 1] = { where = "stash", itemtype = itemtype, client = clientId(itemtype), name = name,
                count = r:getDataLong('count') }
        end
    end)
    each(string.format("SELECT `id`, `itemtype`, `count`, `pokemon_name`, `pokemon_level` FROM `pc_inbox`"
            .. " WHERE `player_id` = %d", guid), function(r)
        local pokemon = r:getDataString('pokemon_name')
        local name = pokemon ~= "" and pokemon or itemName(r:getDataInt('itemtype'))
        if (name:lower():find(text, 1, true)) then
            local row = pokemon ~= "" and pokemonRow(pokemon, r:getDataInt('pokemon_level'))
                or { name = name, client = clientId(r:getDataInt('itemtype')) }
            row.where, row.id, row.count = "inbox", r:getDataInt('id'), r:getDataInt('count')
            list[#list + 1] = row
        end
    end)
    for _, row in ipairs(depotList(cid, text)) do
        row.where = "depot"
        list[#list + 1] = row
    end
    while (#list > PC.SEARCH_LIMIT * 2) do
        table.remove(list)
    end
    send(cid, { type = "search", text = text, list = list }, list)
end

-- Client requests (extended opcode EXTENDED_IDS.PC, JSON). No chat commands.
PC.onClientMessage = function(cid, buffer)
    local ok, data = pcall(JSON.decode, buffer)
    if (not ok or type(data) ~= "table") then
        return
    end
    local action = (data.action or ""):lower()

    if (action == "hello") then
        PC.hello(cid)
        return
    elseif (action == "close") then
        PC.close(cid)
        return
    elseif (action == "open") then
        PC.hello(cid)
        if (not PC.enabled(cid)) then
            return
        end
        if (data.staff and getPlayerAccess(cid) >= PC.STAFF_ACCESS) then
            PC.open(cid, getThingPos(cid), true)
        elseif (PC.inPokemonCenter(getThingPos(cid))) then
            PC.open(cid, getThingPos(cid))
        end
        return
    elseif (not PC.isOpen(cid)) then
        return
    end

    local a, b, c = data.a, data.b, data.c
    if (action == "box") then
        PC.sendBox(cid, a or 1)
    elseif (action == "pokemon" and a) then
        PC.sendPokemon(cid, a)
    elseif (action == "partymon" and a) then
        PC.sendPartyPokemon(cid, a, data.name or "")
    elseif (action == "party") then
        PC.sendParty(cid)
    elseif (action == "deposit" and a and b and c) then
        PC.deposit(cid, a, b, c, data.name or "")
    elseif (action == "withdraw" and a) then
        PC.withdraw(cid, a)
    elseif (action == "move" and a and b) then
        PC.move(cid, a, b, c)
    elseif (action == "rename" and a) then
        PC.rename(cid, a, data.name or "")
    elseif (action == "inbox") then
        PC.sendInbox(cid)
    elseif (action == "take" and a) then
        PC.take(cid, a)
    elseif (action == "takeall") then
        PC.takeAll(cid)
    elseif (action == "tobox" and a) then
        PC.inboxToBox(cid, a)
    elseif (action == "stash") then
        PC.sendStash(cid)
    elseif (action == "bag") then
        PC.sendBag(cid)
    elseif (action == "stow" and a and b) then
        PC.stow(cid, a, b)
    elseif (action == "stowall") then
        PC.stowAll(cid)
    elseif (action == "unstow" and a and b) then
        PC.unstow(cid, a, b)
    elseif (action == "depot") then
        PC.sendDepot(cid)
    elseif (action == "opendepot") then
        PC.openDepot(cid)
    elseif (action == "search") then
        PC.search(cid, (data.text or ""):gsub("[^%w%s%.%-']", ""))
    end
end
