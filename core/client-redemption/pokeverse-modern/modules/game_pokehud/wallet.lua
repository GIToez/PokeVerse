-- Dollars and soul coins the player carries, counted from the equipment and the containers.
-- The server only sends a container's items once it is open, so a closed bag keeps the
-- count it had when it was last open.
Wallet = {}

-- client item ids (server ids 2148, 2152, 2160 and 6500)
local DOLLAR_WORTH = { [3031] = 1, [3035] = 100, [3043] = 10000 }
local SOUL_COIN = 6499

local closedBags = {}
local listener
local autoOpenEvent

local function bagKey(container)
    local item = container:getContainerItem()
    return (item and item:getId() or 0) .. ':' .. container:getName()
end

local function addItem(total, item)
    if not item then
        return
    end
    local id = item:getId()
    if DOLLAR_WORTH[id] then
        total.dollars = total.dollars + DOLLAR_WORTH[id] * item:getCount()
    elseif id == SOUL_COIN then
        total.soulCoins = total.soulCoins + item:getCount()
    end
end

local function countBag(container)
    local total = { dollars = 0, soulCoins = 0 }
    for _, item in pairs(container:getItems()) do
        addItem(total, item)
    end
    return total
end

function Wallet.get()
    local total = { dollars = 0, soulCoins = 0 }
    local player = g_game.getLocalPlayer()
    if not player then
        return total
    end

    for slot = InventorySlotFirst, InventorySlotLast do
        addItem(total, player:getInventoryItem(slot))
    end

    local openBags = {}
    for _, container in pairs(g_game.getContainers()) do
        openBags[bagKey(container)] = true
        local bag = countBag(container)
        total.dollars = total.dollars + bag.dollars
        total.soulCoins = total.soulCoins + bag.soulCoins
    end

    for key, bag in pairs(closedBags) do
        if not openBags[key] then
            total.dollars = total.dollars + bag.dollars
            total.soulCoins = total.soulCoins + bag.soulCoins
        end
    end
    return total
end

local function changed()
    if listener then
        listener(Wallet.get())
    end
end

local function onBagOpen(container)
    closedBags[bagKey(container)] = nil
    changed()
end

local function onBagClose(container)
    local bag = countBag(container)
    if bag.dollars > 0 or bag.soulCoins > 0 then
        closedBags[bagKey(container)] = bag
    else
        closedBags[bagKey(container)] = nil
    end
    changed()
end

local function mainBackpack()
    local player = g_game.getLocalPlayer()
    if not player then
        return nil
    end
    -- the PokeVerse backpack sits in the ammo slot
    for _, slot in ipairs({ InventorySlotAmmo, InventorySlotBack }) do
        local item = player:getInventoryItem(slot)
        if item and item:isContainer() then
            return item
        end
    end
end

local function openMainBackpack()
    autoOpenEvent = nil
    local backpack = mainBackpack()
    if not backpack then
        return
    end
    for _, container in pairs(g_game.getContainers()) do
        local item = container:getContainerItem()
        if item and item:getId() == backpack:getId() and not container:hasParent() then
            return
        end
    end
    g_game.open(backpack)
end

local function onGameStart()
    closedBags = {}
    removeEvent(autoOpenEvent)
    autoOpenEvent = scheduleEvent(openMainBackpack, 1000)
    changed()
end

local function onGameEnd()
    removeEvent(autoOpenEvent)
    autoOpenEvent = nil
    closedBags = {}
end

function Wallet.init(onChange)
    listener = onChange
    connect(Container, {
        onOpen = onBagOpen,
        onClose = onBagClose,
        onAddItem = changed,
        onUpdateItem = changed,
        onRemoveItem = changed
    })
    connect(LocalPlayer, { onInventoryChange = changed })
    connect(g_game, { onGameStart = onGameStart, onGameEnd = onGameEnd })
end

function Wallet.terminate()
    disconnect(Container, {
        onOpen = onBagOpen,
        onClose = onBagClose,
        onAddItem = changed,
        onUpdateItem = changed,
        onRemoveItem = changed
    })
    disconnect(LocalPlayer, { onInventoryChange = changed })
    disconnect(g_game, { onGameStart = onGameStart, onGameEnd = onGameEnd })
    removeEvent(autoOpenEvent)
    listener = nil
end
