-- The trainer belt holds the carried Pokemon in the hidden armor slot. Its window opens and
-- closes together with the pokebag in the ammo slot.
Belt = {}

local function slotItem(slot)
    local player = g_game.getLocalPlayer()
    return player and player:getInventoryItem(slot)
end

local function isSlotContainer(container, slot)
    local item = container:getContainerItem()
    local equipped = slotItem(slot)
    return item and equipped and item:getId() == equipped:getId() and not container:hasParent()
end

local function findOpen(slot)
    for _, container in pairs(g_game.getContainers()) do
        if isSlotContainer(container, slot) then
            return container
        end
    end
end

local function onOpen(container, previousContainer)
    if previousContainer or not isSlotContainer(container, InventorySlotAmmo) then
        return
    end
    local belt = slotItem(InventorySlotBody)
    if belt and belt:isContainer() and not findOpen(InventorySlotBody) then
        g_game.open(belt)
    end
end

local function onClose(container)
    if not isSlotContainer(container, InventorySlotAmmo) then
        return
    end
    local belt = findOpen(InventorySlotBody)
    if belt then
        g_game.close(belt)
    end
end

function Belt.init()
    connect(Container, { onOpen = onOpen, onClose = onClose })
end

function Belt.terminate()
    disconnect(Container, { onOpen = onOpen, onClose = onClose })
end
