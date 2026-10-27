-- The Pokegear Bag (docs/concepts/side-panel): the backpack (the ammo slot) as a grid, with a tab
-- for every bag inside it and the trainer belt on top: the ball slot (the one you call) and then the
-- belt container (the armor slot), which game_pokehud opens with the backpack. The squares are the containers' own item slots, so using,
-- dragging and dropping work as in the backpack windows; game_containers leaves these containers
-- to this window (claimsContainer) while Pokegear is on.
Bag = {}

local POSITION_SETTING = 'pokegearBagPosition'
local KEY = { 'Windows', 'Show/hide the Bag' }
local MAX_VISIBLE_ROWS = 5
local COLUMNS = 6
local CELL, CELL_SPACING = 42, 3
-- a bag asked for by the Bag; the server answers with an open container shortly after
local PENDING_TIMEOUT = 3000

local window, restorePosition, beltEvent
local tabs = {} -- container ids in tab order; the first is the backpack
local selected
local pending = {} -- { itemId, untilTime, select }
-- bags to open one at a time: an open without a previous container takes the first free id, so
-- two asked for before the server answers would share one (and the second replaces the first)
local queued = {}
local active = false
local beltId

local function slotItem(slot)
    local player = g_game.getLocalPlayer()
    return player and player:getInventoryItem(slot)
end

local function backpackItem()
    for _, slot in ipairs({ InventorySlotAmmo, InventorySlotBack }) do
        local item = slotItem(slot)
        if item and item:isContainer() then
            return item
        end
    end
end

local function isSlotContainer(container, equipped)
    local item = container:getContainerItem()
    return item ~= nil and equipped ~= nil and item:getId() == equipped:getId() and not container:hasParent()
end

local function containerById(id)
    return id and g_game.getContainer(id)
end

local function isTab(id)
    for _, tabId in ipairs(tabs) do
        if tabId == id then
            return true
        end
    end
    return false
end

local function dropExpired()
    local now = g_clock.millis()
    for i = #pending, 1, -1 do
        if pending[i].untilTime < now then
            table.remove(pending, i)
        end
    end
end

local function takePending(itemId)
    dropExpired()
    for i, entry in ipairs(pending) do
        if entry.itemId == itemId then
            table.remove(pending, i)
            return entry
        end
    end
end

local function isBackpack(container)
    return isSlotContainer(container, backpackItem())
end

local function isBelt(container)
    return isSlotContainer(container, slotItem(InventorySlotBody))
end

-- select: the trainer opened it, so its tab is shown
local function openBag(item, select)
    pending[#pending + 1] = { itemId = item:getId(), untilTime = g_clock.millis() + PENDING_TIMEOUT, select = select }
    g_game.open(item)
end

local function pump()
    dropExpired()
    if #pending > 0 then
        return
    end
    local item = table.remove(queued, 1)
    if item then
        openBag(item, false)
        scheduleEvent(pump, PENDING_TIMEOUT + 100)
    end
end

local function queueBag(item)
    queued[#queued + 1] = item
end

local function titleOf(container)
    local name = container:getName()
    return name:sub(1, 1):upper() .. name:sub(2)
end

local function onGridItemRelease(widget, mousePos, button)
    local item = widget:getItem()
    -- a bag opens as a tab of its own instead of taking the backpack's place
    if button == MouseRightButton and item and item:isContainer() and not g_keyboard.isCtrlPressed()
        and not g_keyboard.isShiftPressed() then
        openBag(item, true)
        return true
    end
    return UIItem.onMouseRelease(widget, mousePos, button)
end

local function refreshCount(container)
    window.header.count:setText(container and string.format('%d / %d', container:getItemsCount(),
        container:getCapacity()) or '')
end

local function fillGrid()
    local container = containerById(selected)
    local grid = window.grid
    grid:destroyChildren()
    refreshCount(container)
    if not container then
        return
    end
    for slot = 0, container:getCapacity() - 1 do
        local widget = g_ui.createWidget('PokegearBagItem', grid)
        widget:setId('item' .. slot)
        widget:setItem(container:getItem(slot))
        widget.position = container:getSlotPosition(slot)
        widget.onMouseRelease = onGridItemRelease
    end
    local rows = math.max(1, math.ceil(container:getCapacity() / COLUMNS))
    grid:setHeight(math.min(rows, MAX_VISIBLE_ROWS) * (CELL + CELL_SPACING) - CELL_SPACING)
    window:setHeight(8 + 24 + 6 + 14 + 4 + 36 + 10 + 24 + 8 + grid:getHeight() + 10)
end

local function fillTabs()
    local bar = window.tabs
    bar:destroyChildren()
    for index, id in ipairs(tabs) do
        local container = containerById(id)
        if container then
            local tab = g_ui.createWidget('PokegearBagTab', bar)
            tab:setText(index == 1 and tr('Bag') or titleOf(container))
            tab:setOn(id == selected)
            tab:setTooltip(index == 1 and tr('Your bag') or tr('Right-click to close this tab'))
            tab.onClick = function()
                selected = id
                fillTabs()
                fillGrid()
            end
            tab.onMouseRelease = function(widget, mousePos, button)
                if button == MouseRightButton and index > 1 then
                    g_game.close(container)
                    return true
                end
                return false
            end
        end
    end
end

local function isOut()
    for _, creature in ipairs(getCreaturesAroundPlayer()) do
        if creature:isLocalPlayerSummon() then
            return true
        end
    end
    return false
end

local function refreshOut()
    local first = window.belt:getChildren()[1]
    if first and first.out then
        first.out:setVisible(first:getItem() ~= nil and isOut())
    end
end

local function beltSlot(item, position, key)
    local slot = g_ui.createWidget('PokegearBeltSlot', window.belt)
    slot:setItem(item)
    slot.position = position
    slot.key:setText(key or '')
    slot.onMouseRelease = onGridItemRelease
    return slot
end

-- the ball slot first, in gold, then the belt's balls
local function fillBelt()
    local belt = window.belt
    belt:destroyChildren()
    local called = beltSlot(slotItem(InventorySlotFeet), { x = 65535, y = InventorySlotFeet, z = 0 })
    called:setOn(true)
    called:setTooltip(tr('The ball you call'))
    local container = containerById(beltId)
    if container then
        for slot = 0, container:getCapacity() - 1 do
            beltSlot(container:getItem(slot), container:getSlotPosition(slot))
        end
    end
    refreshOut()
end

local function refreshKey()
    local key = Pokegear.boundKey(KEY)
    window.header.keyChip:setText(key)
    window.header.keyChip:setVisible(key ~= '')
end

local function refresh()
    if not window or not window:isVisible() then
        return
    end
    if not containerById(selected) then
        selected = tabs[1]
    end
    fillBelt()
    fillTabs()
    fillGrid()
    refreshKey()
end

local function build()
    window = g_ui.createWidget('PokegearBag', modules.game_interface.getRootPanel())
    window:hide()
    window.header.close.onClick = function()
        Bag.close()
    end
    restorePosition = Pokegear.makeMovable(window, window.header, POSITION_SETTING, function()
        -- left of the ring
        window:addAnchor(AnchorTop, 'pokegearHub', AnchorTop)
        window:addAnchor(AnchorRight, 'pokegearHub', AnchorLeft)
        window:setMarginTop(130)
        window:setMarginRight(-6)
    end)
end

local function showWindow()
    if not window then
        build()
    end
    if not window:isVisible() then
        restorePosition()
        window:show()
    end
    window:raise()
    refresh()
    if not beltEvent then
        beltEvent = cycleEvent(function() if window and window:isVisible() then refreshOut() end end, 1000)
    end
end

local function hideWindow()
    if beltEvent then
        removeEvent(beltEvent)
        beltEvent = nil
    end
    if window then
        window:hide()
    end
end

-- every bag in the backpack gets a tab, once the belt (opened with the backpack) is in
local function openInnerBags(container)
    for _, item in ipairs(container:getItems()) do
        if item:isContainer() then
            queueBag(item)
        end
    end
    if beltId or not slotItem(InventorySlotBody) then
        pump()
    else
        scheduleEvent(pump, 1000)
    end
end

-- asked by game_containers and by onContainerOpen, in either order, so the answer is kept
function Bag.claimsContainer(container)
    if not active then
        return false
    end
    if container.pokegearClaimed == nil then
        local item = container:getContainerItem()
        local asked = item ~= nil and not isBackpack(container) and not isBelt(container) and takePending(item:getId())
        container.pokegearSelect = asked and asked.select or false
        container.pokegearClaimed = isTab(container:getId()) or isBackpack(container) or isBelt(container)
            or asked ~= nil
    end
    return container.pokegearClaimed
end

local function onContainerOpen(container, previousContainer)
    if not active then
        return
    end
    local id = container:getId()
    if not Bag.claimsContainer(container) then
        return
    end
    if isBelt(container) then
        beltId = id
        if window and window:isVisible() then
            fillBelt()
        end
        pump()
        return
    end
    if previousContainer and isTab(previousContainer:getId()) and previousContainer:getId() ~= id then
        for i, tabId in ipairs(tabs) do
            if tabId == previousContainer:getId() then
                table.remove(tabs, i)
                break
            end
        end
    end
    if isBackpack(container) then
        for i, tabId in ipairs(tabs) do
            if tabId == id then
                table.remove(tabs, i)
                break
            end
        end
        table.insert(tabs, 1, id)
        selected = selected or id
        showWindow()
        openInnerBags(container)
        return
    end
    if not isTab(id) then
        tabs[#tabs + 1] = id
    end
    if container.pokegearSelect or not containerById(selected) then
        selected = id
    end
    showWindow()
    pump()
end

local function onContainerClose(container)
    local id = container:getId()
    if id == beltId then
        beltId = nil
        if window and window:isVisible() then
            fillBelt()
        end
        return
    end
    for i, tabId in ipairs(tabs) do
        if tabId == id then
            table.remove(tabs, i)
            break
        end
    end
    if selected == id then
        selected = tabs[1]
    end
    if #tabs == 0 then
        hideWindow()
    else
        refresh()
    end
end

local function onContainerChange(container)
    if window and window:isVisible() and container:getId() == beltId then
        fillBelt()
        return
    end
    if not window or not window:isVisible() or not isTab(container:getId()) then
        return
    end
    if container:getId() == selected then
        fillGrid()
    end
end

local function onContainerUpdateItem(container, slot, item)
    if window and container:getId() == beltId then
        fillBelt()
        return
    end
    if not window or container:getId() ~= selected then
        return
    end
    local widget = window.grid:getChildById('item' .. slot)
    if widget then
        widget:setItem(item)
    end
end

local function onContainerAddItem(container, slot, item)
    onContainerChange(container)
    if container:getId() == tabs[1] and item and item:isContainer() then
        queueBag(item)
        pump()
    end
end

local function closeAll()
    for i = #tabs, 1, -1 do
        local container = containerById(tabs[i])
        if container then
            g_game.close(container)
        end
    end
    tabs, selected, beltId, queued = {}, nil, nil, {}
    hideWindow()
end

function Bag.open()
    local back = backpackItem()
    if not back then
        return
    end
    local container = containerById(tabs[1])
    if container then
        showWindow()
    else
        g_game.open(back)
    end
end

function Bag.close()
    closeAll()
end

function Bag.isOpen()
    return window ~= nil and window:isVisible()
end

function Bag.toggle()
    if window and window:isVisible() then
        Bag.close()
    else
        Bag.open()
    end
end

local function onInventoryChange(player, slot)
    if slot == InventorySlotFeet and window and window:isVisible() then
        fillBelt()
    end
end

local function onKey()
    if active then
        Bag.toggle()
    else
        local back = backpackItem()
        if back then
            g_game.open(back)
        end
    end
end


function Bag.init()
    g_ui.importStyle('bag')
    Keybind.new(KEY[1], KEY[2], { [CHAT_MODE.ON] = '', [CHAT_MODE.OFF] = 'B' }, '')
    Keybind.bind(KEY[1], KEY[2], { { type = KEY_DOWN, callback = onKey } })
    connect(Container, {
        onOpen = onContainerOpen,
        onClose = onContainerClose,
        onSizeChange = onContainerChange,
        onUpdateItem = onContainerUpdateItem,
        onAddItem = onContainerAddItem,
    })
    connect(LocalPlayer, { onInventoryChange = onInventoryChange })
end

-- switching layouts moves the open backpack, its bags and the belt between the backpack windows and
-- the Bag, without closing them
local function adoptOpenContainers()
    local containers = modules.game_containers
    local backpack
    for _, container in pairs(g_game.getContainers()) do
        if isBackpack(container) then
            backpack = container
        end
    end
    if not backpack then
        return
    end
    for _, container in pairs(g_game.getContainers()) do
        local belt = isBelt(container)
        if belt or container == backpack or container:hasParent() then
            if containers then
                containers.destroy(container)
            end
            container.pokegearClaimed = true
            if belt then
                beltId = container:getId()
            elseif container ~= backpack then
                tabs[#tabs + 1] = container:getId()
            end
        end
    end
    table.insert(tabs, 1, backpack:getId())
    selected = backpack:getId()
    showWindow()
    if #tabs == 1 then
        openInnerBags(backpack)
    end
end

local function releaseContainers()
    local ids = {}
    for _, id in ipairs(tabs) do
        ids[#ids + 1] = id
    end
    ids[#ids + 1] = beltId
    tabs, selected, beltId, pending, queued = {}, nil, nil, {}, {}
    hideWindow()
    local containers = modules.game_containers
    for _, id in ipairs(ids) do
        local container = containerById(id)
        if container then
            container.pokegearClaimed = nil
            if containers then
                containers.onContainerOpen(container)
            end
        end
    end
end

function Bag.apply(isActive)
    local now = isActive and g_game.isOnline()
    if now == active then
        return
    end
    active = now
    if active then
        adoptOpenContainers()
    else
        releaseContainers()
    end
end

-- logging out: the containers are going away with the game
function Bag.reset()
    active = false
    tabs, selected, beltId, pending, queued = {}, nil, nil, {}, {}
    hideWindow()
end

function Bag.terminate()
    disconnect(Container, {
        onOpen = onContainerOpen,
        onClose = onContainerClose,
        onSizeChange = onContainerChange,
        onUpdateItem = onContainerUpdateItem,
        onAddItem = onContainerAddItem,
    })
    disconnect(LocalPlayer, { onInventoryChange = onInventoryChange })
    Keybind.delete(KEY[1], KEY[2])
    active = false
    if window then
        window:destroy()
        window = nil
    end
    tabs, selected, pending, queued = {}, nil, {}, {}
end
