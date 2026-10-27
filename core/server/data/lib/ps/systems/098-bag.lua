-- The Pokegear Bag's server half: the item categories its rail filters by, the same ones as the PC stash
-- and the GTS (ItemCategories, 065-itemCategories.lua), in client ids. The client puts any item in
-- none under Other.
--
-- The client talks JSON on EXTENDED_IDS.BAG:
--   client -> server  {action = "hello"} (at login), {action = "belt"} (when the belt changes)
--   server -> client  {type = "categories", list = {{name, icon, items = {client ids}}, ...}} (in fragments,
--                       doSendPlayerLongExtendedOpcode)
--                     {type = "belt", ball = number, slots = {number, ...}}: the quick call number of the ball
--                       slot's ball and of each belt ball in slot order, 0 for none

Bag = {}

local function clientId(id)
    local info = id and getItemInfo(id)
    if (info and info.clientId and info.clientId > 0) then
        return info.clientId
    end
end

local function build()
    local taken, list = {}, {}
    for _, category in ipairs(ItemCategories.LIST) do
        local items = {}
        for _, id in ipairs(category.items) do
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
