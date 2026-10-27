-- The Pokegear Bag's server half: the item categories its rail filters by. They are the GTS categories
-- (GTS.CATEGORIES) followed by the Bag-only ones (ITEM_CATEGORIES_EXTRA, config/itemCategories.lua), with the
-- GTS "Other" last. An item keeps the first category it is in; the client puts any item in none under "Other".
--
-- The client talks JSON on EXTENDED_IDS.BAG:
--   client -> server  {action = "hello"} (at login), {action = "belt"} (when the belt changes)
--   server -> client  {type = "categories", list = {{name, icon}, ...}}, then the items in parts:
--                       {type = "items", category = index, items = {client ids}}
--                     {type = "belt", ball = number, slots = {number, ...}}: the quick call number of the ball
--                       slot's ball and of each belt ball in slot order, 0 for none

Bag = {}

local function clientId(id)
    local info = getItemInfo(id)
    if (info and info.name ~= "" and info.clientId and info.clientId > 0) then
        return info.clientId
    end
end

local function build()
    local sources = {}
    local other
    for _, category in ipairs(GTS.CATEGORIES) do
        if (category.name == "Other") then
            other = category
        else
            sources[#sources + 1] = { name = category.name, items = category.items }
        end
    end
    for _, category in ipairs(ITEM_CATEGORIES_EXTRA) do
        sources[#sources + 1] = category
    end
    if (other) then
        sources[#sources + 1] = { name = other.name, items = other.items }
    end

    local taken, list = {}, {}
    for _, category in ipairs(sources) do
        local items = {}
        for _, id in ipairs(category.items) do
            local client = clientId(id)
            if (client and not taken[client]) then
                taken[client] = true
                items[#items + 1] = client
            end
        end
        if (#items > 0 or category == sources[#sources]) then
            list[#list + 1] = { name = category.name, icon = category.icon and clientId(category.icon) or items[1] or 0,
                items = items }
        end
    end
    return list
end

Bag.CATEGORIES = build()

-- the network message drops a string over 8 KB (and the rest of the packet with it), so the items go in parts
local PART = 500
local MESSAGES = {}
do
    local list = {}
    for _, category in ipairs(Bag.CATEGORIES) do
        list[#list + 1] = { name = category.name, icon = category.icon }
    end
    MESSAGES[1] = JSON.encode({ type = "categories", list = list })
    for index, category in ipairs(Bag.CATEGORIES) do
        for first = 1, #category.items, PART do
            local items = {}
            for i = first, math.min(first + PART - 1, #category.items) do
                items[#items + 1] = category.items[i]
            end
            MESSAGES[#MESSAGES + 1] = JSON.encode({ type = "items", category = index, items = items })
        end
    end
end
Bag.MESSAGES = MESSAGES

Bag.sendCategories = function(cid)
    for _, message in ipairs(MESSAGES) do
        doSendPlayerExtendedOpcode(cid, EXTENDED_IDS.BAG, message)
    end
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

Bag.onClientMessage = function(cid, buffer)
    local ok, data = pcall(JSON.decode, buffer)
    if (not ok or type(data) ~= "table") then
        return
    end
    if (data.action == "hello") then
        Bag.sendCategories(cid)
    elseif (data.action == "belt") then
        Bag.sendBelt(cid)
    end
end
