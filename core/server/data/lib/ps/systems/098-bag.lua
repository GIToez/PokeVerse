-- The Pokegear Bag's server half: the item categories its rail filters by, the same ones as the PC stash
-- and the GTS (ItemCategories, 065-itemCategories.lua), in client ids. The client puts any item in
-- none under Other.
--
-- The client talks JSON on EXTENDED_IDS.BAG:
--   client -> server  {action = "hello"} (at login), {action = "belt"} (when the belt changes)
--                     {action = "rename", slot, item = client id, name}: the bag in that slot of the starting bag
--                       (-1 for the starting bag itself); an empty name gives it back its own
--                     {action = "rules", slot, item}: that bag's sort rules
--                     {action = "setRules", slot, item, categories = {names}, pins = {client ids}}
--                     {action = "sort"}: "Sort my bags now"
--   server -> client  {type = "categories", list = {{name, icon, items = {client ids}}, ...}} (in fragments,
--                       doSendPlayerLongExtendedOpcode)
--                     {type = "belt", ball = number, slots = {number, ...}}: the quick call number of the ball
--                       slot's ball and of each belt ball in slot order, 0 for none
--                     {type = "renamed", slot, name} or {type = "error", text}
--                     {type = "rules", slot, categories, pins, saved}, {type = "sorted", moved}
--
-- Sort rules are kept on the bag item ("sortrules", read by Player::getSortDestination): a new item
-- goes to a stack of the same item, then a bag that pins it, then the first bag taking its category,
-- then the usual search (the starting bag first). setItemCategory gives the server the categories.

Bag = {}

local function clientId(id)
    local info = id and getItemInfo(id)
    if (info and info.clientId and info.clientId > 0) then
        return info.clientId
    end
end

local function build()
    local taken, list, sorted = {}, {}, {}
    for _, category in ipairs(ItemCategories.LIST) do
        local items = {}
        for _, id in ipairs(category.items) do
            if (not sorted[id]) then
                sorted[id] = true
                setItemCategory(id, category.name)
            end
            local client = clientId(id)
            if (client and not taken[client]) then
                taken[client] = true
                items[#items + 1] = client
            end
        end
        list[#list + 1] = { name = category.name, icon = clientId(category.icon) or 0, items = items }
    end
    return list
end

Bag.CATEGORIES = build()
Bag.MESSAGE = JSON.encode({ type = "categories", list = Bag.CATEGORIES })

Bag.sendCategories = function(cid)
    doSendPlayerLongExtendedOpcode(cid, EXTENDED_IDS.BAG, Bag.MESSAGE)
end

local function fastcallOf(item)
    if (isItem(item) and isBallWithPokemon(item.uid)) then
        return tonumber(getFastcallNumber(item.uid)) or 0
    end
    return 0
end

-- the quick call number of each ball, so the client can show the bar's face and key on the belt
Bag.sendBelt = function(cid)
    local slots = {}
    local belt = getPlayerSlotItem(cid, PLAYER_SLOT_BELT)
    if (isItem(belt) and isContainer(belt.uid)) then
        for slot = 0, getContainerSize(belt.uid) - 1 do
            slots[#slots + 1] = fastcallOf(getContainerItem(belt.uid, slot))
        end
    end
    doSendPlayerExtendedOpcode(cid, EXTENDED_IDS.BAG, JSON.encode({ type = "belt",
        ball = fastcallOf(getPlayerSlotItem(cid, PLAYER_SLOT_BALL)), slots = slots }))
end

local NAME_LENGTH = 20

local function sendError(cid, text)
    doSendPlayerExtendedOpcode(cid, EXTENDED_IDS.BAG, JSON.encode({ type = "error", text = text }))
end

-- the bag in that slot of the starting bag (-1: the starting bag), if it's still the item the client saw
local function findBag(cid, slot, item)
    local backpack = getPlayerSlotItem(cid, PLAYER_SLOT_BACKPACK)
    slot = tonumber(slot)
    if (not isItem(backpack) or not isContainer(backpack.uid) or not slot or slot < -1
            or slot >= getContainerSize(backpack.uid)) then
        return nil
    end
    local bag = slot == -1 and backpack or getContainerItem(backpack.uid, slot)
    if (not isItem(bag) or not isContainer(bag.uid) or clientId(bag.itemid) ~= tonumber(item)) then
        return nil
    end
    return bag, slot
end

-- the name is kept on the bag item, so it goes with the bag to the PC, a trade or the ground
Bag.rename = function(cid, slot, item, name)
    name = tostring(name or ""):gsub("[^%w %-'&]", ""):gsub("^%s+", ""):gsub("%s+$", ""):gsub("%s+", " ")
    if (#name > NAME_LENGTH) then
        return sendError(cid, string.format("A bag name can be up to %d letters.", NAME_LENGTH))
    end
    local bag
    bag, slot = findBag(cid, slot, item)
    if (not bag) then
        return sendError(cid, "That bag isn't in your bag anymore.")
    end
    if (name == "") then
        doItemEraseAttribute(bag.uid, "name")
        name = getItemInfo(bag.itemid).name
    else
        doItemSetAttribute(bag.uid, "name", name)
    end
    doSendPlayerExtendedOpcode(cid, EXTENDED_IDS.BAG, JSON.encode({ type = "renamed", slot = slot, name = name }))
end

Bag.MAX_PINS = 12

local CATEGORY_NAMES = {}
for _, category in ipairs(ItemCategories.LIST) do
    CATEGORY_NAMES[category.name] = true
end

-- {categories = {names}, pins = {server ids}} from the bag's "sortrules"
Bag.getRules = function(uid)
    local rules = { categories = {}, pins = {} }
    local text = getItemAttribute(uid, "sortrules")
    if (type(text) ~= "string") then
        return rules
    end
    local names, pins = text:match("^([^;]*);?(.*)$")
    for name in (names or ""):gmatch("[^|]+") do
        rules.categories[#rules.categories + 1] = name
    end
    for id in (pins or ""):gmatch("%d+") do
        rules.pins[#rules.pins + 1] = tonumber(id)
    end
    return rules
end

-- rules = {categories = {names}, pins = {server ids}}; unknown names and ids are dropped
Bag.setRules = function(uid, rules)
    local names, seen = {}, {}
    for _, name in ipairs(rules.categories or {}) do
        name = tostring(name)
        if (CATEGORY_NAMES[name] and not seen[name]) then
            seen[name] = true
            names[#names + 1] = name
        end
    end
    local pins = {}
    for _, id in ipairs(rules.pins or {}) do
        id = tonumber(id)
        if (id and not seen[id] and getItemInfo(id) and #pins < Bag.MAX_PINS) then
            seen[id] = true
            pins[#pins + 1] = id
        end
    end
    if (#names == 0 and #pins == 0) then
        doItemEraseAttribute(uid, "sortrules")
    else
        doItemSetAttribute(uid, "sortrules", table.concat(names, "|") .. ";" .. table.concat(pins, ","))
    end
    return Bag.getRules(uid)
end

local function sendRules(cid, slot, rules, saved)
    local pins = {}
    for _, id in ipairs(rules.pins) do
        pins[#pins + 1] = clientId(id) or 0
    end
    doSendPlayerExtendedOpcode(cid, EXTENDED_IDS.BAG, JSON.encode({ type = "rules", slot = slot,
        categories = rules.categories, pins = pins, saved = saved or nil }))
end

Bag.onRules = function(cid, slot, item)
    local bag
    bag, slot = findBag(cid, slot, item)
    if (not bag or slot == -1) then
        return sendError(cid, "That bag isn't in your bag anymore.")
    end
    sendRules(cid, slot, Bag.getRules(bag.uid))
end

Bag.onSetRules = function(cid, slot, item, categories, pins)
    local bag
    bag, slot = findBag(cid, slot, item)
    if (not bag or slot == -1) then
        return sendError(cid, "That bag isn't in your bag anymore.")
    end
    local serverPins = {}
    for _, id in ipairs(type(pins) == "table" and pins or {}) do
        serverPins[#serverPins + 1] = tonumber(id) and getItemServerId(tonumber(id)) or nil
    end
    sendRules(cid, slot, Bag.setRules(bag.uid, { categories = type(categories) == "table" and categories or {},
        pins = serverPins }), true)
end

local lastSort = {}
Bag.onSort = function(cid)
    local now = os.time()
    if ((lastSort[cid] or 0) + 2 > now) then
        return
    end
    lastSort[cid] = now
    doSendPlayerExtendedOpcode(cid, EXTENDED_IDS.BAG, JSON.encode({ type = "sorted", moved = doPlayerSortBags(cid) or 0 }))
end

Bag.onClientMessage = function(cid, buffer)
    local ok, data = pcall(JSON.decode, buffer)
    if (not ok or type(data) ~= "table") then
        return
    end
    if (data.action == "hello") then
        Bag.sendCategories(cid)
    elseif (data.action == "belt") then
        Bag.sendBelt(cid)
    elseif (data.action == "rename") then
        Bag.rename(cid, data.slot, data.item, data.name)
    elseif (data.action == "rules") then
        Bag.onRules(cid, data.slot, data.item)
    elseif (data.action == "setRules") then
        Bag.onSetRules(cid, data.slot, data.item, data.categories, data.pins)
    elseif (data.action == "sort") then
        Bag.onSort(cid)
    end
end
