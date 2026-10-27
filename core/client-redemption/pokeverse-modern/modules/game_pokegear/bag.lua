-- The Pokegear Bag (docs/concepts/side-panel): the backpack (the ammo slot) as a grid, with a tab
-- for every bag inside it and the trainer belt on top: the ball slot (the one you call) and then the
-- belt container (the armor slot), which game_pokehud opens with the backpack. The squares are the containers' own item slots, so using,
-- dragging and dropping work as in the backpack windows; game_containers leaves these containers
-- to this window (claimsContainer) while Pokegear is on.
-- The server (systems/098-bag.lua, ExtendedIds.Bag) sends the item categories the rail filters by,
-- and the quick call number of every belt ball, so the belt shows the quick call bar's faces and keys.
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
local categories = {} -- { name, icon } from the server, in rail order
local categoryOf = {} -- client item id -> index in categories
local otherCategory -- where an item in no category goes
local filter -- index in categories; nil shows everything
local beltNumbers -- { ball = number, slots = { number, ... } }, 0 for none
local beltRequest
local fillGrid, requestBelt

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

-- the space used across every bag
local function refreshCount()
    local used, capacity = 0, 0
    for _, id in ipairs(tabs) do
        local container = containerById(id)
        if container then
            used = used + container:getItemsCount()
            capacity = capacity + container:getCapacity()
        end
    end
    window.header.count:setText(capacity > 0 and string.format('%d / %d', used, capacity) or '')
end

local function categoryIndex(item)
    return categoryOf[item:getId()] or otherCategory
end

local function matches(item)
    return filter == nil or (item ~= nil and categoryIndex(item) == filter)
end

local function setFilter(index)
    filter = index
    fillGrid()
end

local function railButton(index, count)
    local button = g_ui.createWidget('PokegearBagRailButton', window.rail)
    button:setOn(filter == index)
    if index and index ~= otherCategory then
        local category = categories[index]
        button.icon:setItemId(category.icon or 0)
        button:setTooltip(string.format('%s (%d)', tr(category.name), count or 0))
    elseif index then
        button.icon:hide()
        button:setText(tr('Etc'))
        button:setTooltip(string.format('%s (%d)', tr(categories[index].name), count or 0))
    else
        button.icon:hide()
        button:setText(tr('All'))
        button:setTooltip(tr('Everything in this bag'))
    end
    button.onClick = function()
        setFilter(index)
    end
end

-- All, then each category with something in the open bag (and the one picked, even when empty)
local function fillRail(container)
    local rail = window.rail
    rail:destroyChildren()
    local counts = {}
    if container and #categories > 0 then
        for _, item in ipairs(container:getItems()) do
            local index = categoryIndex(item)
            if index then
                counts[index] = (counts[index] or 0) + 1
            end
        end
    end
    railButton(nil)
    for index in ipairs(categories) do
        if counts[index] or filter == index then
            railButton(index, counts[index])
        end
    end
    local buttons = #rail:getChildren()
    rail:setHeight(buttons * 24 + (buttons - 1) * 2)
end

fillGrid = function()
    local container = containerById(selected)
    local grid = window.grid
    grid:destroyChildren()
    refreshCount()
    if filter and not categories[filter] then
        filter = nil
    end
    fillRail(container)
    window.gridTitle:setText(filter and tr(categories[filter].name) or tr('All'))
    local shown = 0
    if container then
        for slot = 0, container:getCapacity() - 1 do
            local item = container:getItem(slot)
            if matches(item) then
                local widget = g_ui.createWidget('PokegearBagItem', grid)
                widget:setId('item' .. slot)
                widget:setItem(item)
                widget.position = container:getSlotPosition(slot)
                widget.onMouseRelease = onGridItemRelease
                shown = shown + 1
            end
        end
    end
    local rows = math.max(1, math.ceil(shown / COLUMNS))
    local height = math.min(rows, MAX_VISIBLE_ROWS) * (CELL + CELL_SPACING) - CELL_SPACING
    grid:setHeight(height)
    window.gridScroll:setHeight(height)
    window:setHeight(8 + 24 + 16 + 36 + 10 + 24 + 8 + 16 + 4 + math.max(height, window.rail:getHeight()) + 10)
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
            local space = string.format('%d / %d', container:getItemsCount(), container:getCapacity())
            tab:setTooltip((index == 1 and tr('Your bag') or tr('Right-click to close this tab')) .. '\n' .. space)
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

local function sendBag(data)
    local protocol = g_game.getProtocolGame()
    if protocol and g_game.isOnline() then
        protocol:sendExtendedJSONOpcode(ExtendedIds.Bag, data)
    end
end

-- the belt moved: ask for its quick call numbers once things settle
requestBelt = function()
    if beltRequest or not active then
        return
    end
    beltRequest = scheduleEvent(function()
        beltRequest = nil
        sendBag({ action = 'belt' })
    end, 300)
end

-- the quick call bar's slot for that number: its face, and its key (F1 to F6 by position)
local function quickCall(number)
    local bar = modules.game_pokebar and modules.game_pokebar.pokemonBar
    if not number or number == 0 or not bar then
        return
    end
    local position = 0
    for _, child in ipairs(bar:getChildren()) do
        if child:getStyleName() == 'QuickCallSlot' then
            position = position + 1
            if child.number == number then
                local face = child.portrait and child.portrait:getItemId() or 0
                return face, Keybind.getShortLabel('Pokemon', 'Call Pokemon ' .. position)
            end
        end
    end
end

local function showQuickCall(slot, number)
    local face, key = quickCall(slot:getItem() and number)
    slot.face:setItemId(face or 0)
    slot.face:setVisible(face ~= nil and face > 0)
    slot.key:setText(key or '')
end

local function refreshFaces()
    if not window then
        return
    end
    local children = window.belt:getChildren()
    for index, slot in ipairs(children) do
        local number
        if beltNumbers then
            number = index == 1 and beltNumbers.ball or beltNumbers.slots[index - 1]
        end
        showQuickCall(slot, number)
    end
end

local function beltSlot(item, position)
    local slot = g_ui.createWidget('PokegearBeltSlot', window.belt)
    slot:setItem(item)
    slot.position = position
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
    refreshFaces()
    refreshOut()
end

local function onBagMessage(protocol, opcode, buffer)
    local ok, data = pcall(json.decode, buffer)
    if not ok or type(data) ~= 'table' then
        return
    end
    if data.type == 'categories' and type(data.list) == 'table' then
        categories, categoryOf, otherCategory = {}, {}, nil
        for index, category in ipairs(data.list) do
            categories[index] = { name = tostring(category.name), icon = tonumber(category.icon) or 0 }
            if category.name == 'Other' then
                otherCategory = index
            end
        end
        if window and window:isVisible() then
            fillGrid()
        end
    elseif data.type == 'items' and categories[data.category] and type(data.items) == 'table' then
        for _, id in ipairs(data.items) do
            categoryOf[id] = categoryOf[id] or data.category
        end
        if window and window:isVisible() then
            fillGrid()
        end
    elseif data.type == 'belt' then
        local slots = {}
        for index, number in ipairs(type(data.slots) == 'table' and data.slots or {}) do
            slots[index] = tonumber(number) or 0
        end
        beltNumbers = { ball = tonumber(data.ball) or 0, slots = slots }
        refreshFaces()
    end
end

local function onGameStart()
    categories, categoryOf, otherCategory, filter, beltNumbers = {}, {}, nil, nil, nil
    sendBag({ action = 'hello' })
end

-- the quick call bar changes after the belt does, so the faces and keys follow it
local function onQuickCallChange()
    scheduleEvent(refreshFaces, 50)
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
    requestBelt()
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
        requestBelt()
        return
    end
    if not window or not window:isVisible() or not isTab(container:getId()) then
        return
    end
    if container:getId() == selected then
        fillGrid()
    else
        refreshCount()
    end
end

local function onContainerUpdateItem(container, slot, item)
    if window and container:getId() == beltId then
        fillBelt()
        requestBelt()
        return
    end
    if not window or container:getId() ~= selected then
        return
    end
    local widget = window.grid:getChildById('item' .. slot)
    if filter or not widget then
        fillGrid()
    else
        widget:setItem(item)
        fillRail(container)
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
        requestBelt()
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
    connect(g_game, { onGameStart = onGameStart, onPokemonBarAdd = onQuickCallChange,
        onPokemonBarRemove = onQuickCallChange })
    connect(Keybind, { onBind = onQuickCallChange })
    ProtocolGame.registerExtendedOpcode(ExtendedIds.Bag, onBagMessage)
    if g_game.isOnline() then
        onGameStart()
    end
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
    filter, beltNumbers = nil, nil
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
    disconnect(g_game, { onGameStart = onGameStart, onPokemonBarAdd = onQuickCallChange,
        onPokemonBarRemove = onQuickCallChange })
    disconnect(Keybind, { onBind = onQuickCallChange })
    ProtocolGame.unregisterExtendedOpcode(ExtendedIds.Bag)
    if beltRequest then
        removeEvent(beltRequest)
        beltRequest = nil
    end
    Keybind.delete(KEY[1], KEY[2])
    active = false
    if window then
        window:destroy()
        window = nil
    end
    tabs, selected, pending, queued = {}, nil, {}, {}
end
