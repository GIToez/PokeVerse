-- The Pokegear Bag (docs/concepts/side-panel): the backpack (the ammo slot) as a grid, with a tab
-- for every bag inside it and the trainer belt on top: the ball slot (the one you call) and then the
-- belt container (the armor slot), which game_pokehud opens with the backpack. The squares are the containers' own item slots, so using,
-- dragging and dropping work as in the backpack windows; game_containers leaves these containers
-- to this window (claimsContainer) while Pokegear is on.
-- The server (systems/098-bag.lua, ExtendedIds.Bag) sends the item categories the rail filters by (the
-- same as the PC's and the GTS's), and the quick call number of every belt ball, so the belt shows the
-- quick call bar's faces and keys. A tab renamed keeps its name on the bag item (Bag.rename on the server).
Bag = {}

local POSITION_SETTING = 'pokegearBagPosition'
local KEY = { 'Windows', 'Show/hide the Bag' }
local MAX_VISIBLE_ROWS, COMPACT_ROWS = 5, 4 -- fewer on small screens (Pokegear.isCompact)
local COLUMNS = 6
local CELL, CELL_SPACING = 42, 3
-- a bag asked for by the Bag; the server answers with an open container shortly after
local PENDING_TIMEOUT = 3000
-- bags opened as tabs on their own; the server keeps 16 open containers per trainer, and the belt,
-- corpses and the PC need some of them. Right-clicking another bag opens it once a tab is closed.
local MAX_TABS = 5
local ARROW_WIDTH, TAB_SPACING = 18, 4
local NAME_LENGTH = 20
local NAME_WIDTH = 120 -- the open tab's name, in pixels

local window, restorePosition, beltEvent
local tabs = {} -- container ids in tab order; the first is the backpack
-- container id -> the bag's slot in the backpack (-1 for the backpack), kept up as items come and go
local tabSlot = {}
local tabNames = {} -- container id -> the name the trainer just gave it
-- container id -> where its Classic window was (panel, index, height) when Pokegear took it; nil when
-- Pokegear started without Classic windows, then switching back opens every bag as before
local classicWindows
local tabOffset = 1 -- the first tab shown when they don't all fit
local selected
local pending = {} -- { itemId, untilTime, select, slot }
-- bags to open one at a time: an open without a previous container takes the first free id, so
-- two asked for before the server answers would share one (and the second replaces the first)
local queued = {}
-- an open names a slot in the backpack; bags added together are opened once the server is done
-- adding, or the slot has moved on by the time the open gets there
local SETTLE_TIME = 300
local settleEvent
local active = false
local beltId
local categories = {} -- { name, icon } from the server, in rail order
local categoryOf = {} -- client item id -> index in categories
local otherCategory -- where an item in no category goes
local equipNames = {} -- client item id -> name, for the items that go in the equipment slot
local filter -- index in categories; nil shows everything
local beltNumbers -- { ball = number, slots = { number, ... } }, 0 for none
local beltRequest
local switches = { defense = false, autoSwap = true } -- the belt switches; the server keeps them and does both
local fillGrid, requestBelt, sendBag

local slotItem = Pokegear.slotItem

local backpackItem = Pokegear.backpackItem

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

-- an open the server never answered (an older server drops it while the trainer is asleep or busy)
-- is tried again, at the back of the queue
local OPEN_TRIES = 3

local function dropExpired()
    local now = g_clock.millis()
    for i = #pending, 1, -1 do
        local entry = pending[i]
        if entry.untilTime < now then
            table.remove(pending, i)
            if entry.item and (entry.tries or 1) < OPEN_TRIES then
                queued[#queued + 1] = { item = entry.item, tries = (entry.tries or 1) + 1 }
            end
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

-- a bag of the same kind on the ground has no parent either, so once the backpack has its tab only
-- that container is it
local function isBackpack(container)
    return isSlotContainer(container, backpackItem()) and (tabs[1] == nil or tabs[1] == container:getId())
end

local function isBelt(container)
    return isSlotContainer(container, slotItem(InventorySlotBody))
end

-- select: the trainer opened it, so its tab is shown; tries: opens of it sent so far, for one from the queue
local function openBag(item, select, tries)
    local pos = item:getPosition()
    local slot
    if pos and pos.x == 65535 and tabs[1] and pos.y == 64 + tabs[1] then
        slot = pos.z
    end
    pending[#pending + 1] = { itemId = item:getId(), untilTime = g_clock.millis() + PENDING_TIMEOUT, select = select,
        slot = slot, item = tries and item, tries = tries }
    g_game.open(item)
end

-- the belt opens with the backpack (game_pokehud); bags wait for it, since two opens in flight take
-- the same container id. One that never came is asked for again.
local beltAsked, beltTries = 0, 0

local function awaitingBelt()
    local belt = slotItem(InventorySlotBody)
    if beltId or not belt or not belt:isContainer() then
        return false
    end
    if g_clock.millis() < beltAsked + PENDING_TIMEOUT then
        return true
    end
    if beltTries >= OPEN_TRIES then
        return false
    end
    beltAsked, beltTries = g_clock.millis(), beltTries + 1
    g_game.open(belt)
    return true
end

-- the bag's slot in the backpack, checked against what's there now; a tab picked up when switching
-- layouts is found by its item when only one bag in the backpack has it
local function bagSlot(id)
    if id == tabs[1] then
        return -1
    end
    local backpack, container = containerById(tabs[1]), containerById(id)
    local bag = container and container:getContainerItem()
    if not backpack or not bag then
        return nil
    end
    local slot = tabSlot[id]
    local there = slot and backpack:getItem(slot)
    if there and there:getId() == bag:getId() then
        return slot
    end
    if slot ~= false then
        return nil
    end
    local found
    for index, item in ipairs(backpack:getItems()) do
        if item:getId() == bag:getId() and item:isContainer() then
            if found then
                return nil
            end
            found = index - 1
        end
    end
    tabSlot[id] = found
    return found
end

local function tabsFull()
    return #tabs - 1 >= MAX_TABS
end

-- a bag already shown as a tab, or gone from the backpack; the server closes a bag that's opened again
local function isShown(item)
    local pos = item:getPosition()
    local backpack = containerById(tabs[1])
    if not pos or not backpack or pos.x ~= 65535 or pos.y ~= 64 + tabs[1] then
        return false
    end
    local there = backpack:getItem(pos.z)
    if not there or there:getId() ~= item:getId() or not there:isContainer() then
        return true
    end
    for id, slot in pairs(tabSlot) do
        if slot == pos.z and id ~= tabs[1] then
            return true
        end
    end
    for _, entry in ipairs(pending) do
        if entry.slot == pos.z then
            return true
        end
    end
    return false
end

local function pump()
    dropExpired()
    if #pending > 0 or settleEvent then
        return
    end
    if awaitingBelt() then
        scheduleEvent(pump, PENDING_TIMEOUT + 100)
        return
    end
    if tabsFull() then
        queued = {}
        return
    end
    local entry = table.remove(queued, 1)
    while entry and isShown(entry.item) do
        entry = table.remove(queued, 1)
    end
    if entry then
        openBag(entry.item, false, entry.tries)
        scheduleEvent(pump, PENDING_TIMEOUT + 100)
    end
end

local function cancelSettle()
    if settleEvent then
        removeEvent(settleEvent)
        settleEvent = nil
    end
end

local function queueBag(item)
    queued[#queued + 1] = { item = item, tries = 1 }
end

local function titleOf(container)
    local name = tabNames[container:getId()] or container:getName()
    return name:sub(1, 1):upper() .. name:sub(2)
end

local function onGridItemRelease(widget, mousePos, button)
    local item = widget:getItem()
    -- a bag opens as a tab of its own instead of taking the backpack's place
    if button == MouseRightButton and item and item:isContainer() and not g_keyboard.isCtrlPressed()
        and not g_keyboard.isShiftPressed() then
        if tabsFull() then
            modules.game_textmessage.displayFailureMessage(tr('You have %d bags open as tabs. Close one to open another.',
                MAX_TABS))
        else
            openBag(item, true)
        end
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

-- the name the server gave an item that goes in the equipment slot (bikes, running shoes, the
-- flashlight...); nil for any other item
function Bag.equipmentName(itemId)
    return equipNames[itemId]
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
    local height = math.min(rows, Pokegear.isCompact() and COMPACT_ROWS or MAX_VISIBLE_ROWS) * (CELL + CELL_SPACING) - CELL_SPACING
    grid:setHeight(height)
    window.gridScroll:setHeight(height)
    window:setHeight(8 + 24 + 16 + 36 + 10 + 18 + 8 + 24 + 8 + 16 + 4 + math.max(height, window.rail:getHeight()) + 10)
end

local fillTabs, layoutTabs

-- what's dropped on a tab goes into that bag, in its first free slot
local function dropInto(id, dragged)
    local item = dragged and dragged.currentDragThing
    local container = containerById(id)
    if not item or not item.isItem or not item:isItem() or not container then
        return false
    end
    if container:getItemsCount() >= container:getCapacity() then
        modules.game_textmessage.displayFailureMessage(tr('That bag is full.'))
        return true
    end
    g_game.move(item, container:getSlotPosition(container:getItemsCount()), item:getCount())
    return true
end

local function startRename(id, tab)
    local container = containerById(id)
    if not container then
        return
    end
    local edit = g_ui.createWidget('PokegearBagNameEdit', window.tabs)
    window.tabs:moveChildToIndex(edit, window.tabs:getChildIndex(tab))
    tab:hide()
    edit:setMaxLength(NAME_LENGTH)
    edit:setText(titleOf(container))
    edit:selectAll()
    edit:focus()
    local done = false
    local function finish(save)
        if done then
            return
        end
        done = true
        local slot = bagSlot(id)
        if save and slot then
            sendBag({ action = 'rename', slot = slot, item = container:getContainerItem():getId(),
                name = edit:getText() })
        elseif save then
            modules.game_textmessage.displayFailureMessage(tr('Only the bags in your bag can be renamed here.'))
        end
        scheduleEvent(fillTabs, 1)
    end
    edit.onKeyPress = function(widget, keyCode)
        if keyCode == KeyEnter or keyCode == KeyReturn then
            finish(true)
            return true
        elseif keyCode == KeyEscape then
            finish(false)
            return true
        end
        return false
    end
    edit.onFocusChange = function(widget, focused)
        if not focused then
            finish(true)
        end
    end
end

local function openAsWindow(id)
    local container = containerById(id)
    if not container then
        return
    end
    for i, tabId in ipairs(tabs) do
        if tabId == id then
            table.remove(tabs, i)
            break
        end
    end
    tabSlot[id], tabNames[id] = nil, nil
    container.pokegearClaimed = false
    if selected == id then
        selected = tabs[1]
    end
    fillTabs()
    fillGrid()
    if modules.game_containers then
        modules.game_containers.onContainerOpen(container)
    end
end

-- sort rules: the server keeps them on the bag item; this edits one bag's at a time
local MAX_PINS = 12
local rulesWindow
local rulesEdit -- { id, slot, item } of the bag being edited

local function closeRules()
    if rulesWindow then
        rulesWindow:destroy()
        rulesWindow = nil
    end
    rulesEdit = nil
end

local function setPin(pin, itemId)
    pin.pinned = itemId
    pin:setItemId(itemId or 0)
    pin:setTooltip(itemId and tr('Right-click to unpin') or tr('Drop an item here to pin it'))
end

local function showRules(data)
    local container = rulesEdit and containerById(rulesEdit.id)
    if not container or tonumber(data.slot) ~= rulesEdit.slot then
        return
    end
    if data.saved then
        modules.game_textmessage.displayStatusMessage(tr('Sort rules saved for %s.', titleOf(container)))
        closeRules()
        return
    end
    if rulesWindow then
        rulesWindow:destroy()
    end
    rulesWindow = g_ui.createWidget('PokegearBagRules', modules.game_interface.getRootPanel())
    rulesWindow:addAnchor(AnchorTop, 'pokegearBag', AnchorTop)
    rulesWindow:addAnchor(AnchorRight, 'pokegearBag', AnchorLeft)
    rulesWindow:setMarginRight(6)
    rulesWindow.title:setText(tr('Sort rules: %s', titleOf(container)))

    local taken = {}
    for _, name in ipairs(type(data.categories) == 'table' and data.categories or {}) do
        taken[tostring(name)] = true
    end
    for _, category in ipairs(categories) do
        if category.name ~= 'Other' then
            local pill = g_ui.createWidget('PokegearBagRulePill', rulesWindow.categories)
            pill:setText(category.name)
            pill.categoryName = category.name
            pill:setOn(taken[category.name] == true)
            pill.onClick = function(widget) widget:setOn(not widget:isOn()) end
        end
    end

    local pinned = type(data.pins) == 'table' and data.pins or {}
    for index = 1, MAX_PINS do
        local pin = g_ui.createWidget('PokegearBagPin', rulesWindow.pins)
        local id = tonumber(pinned[index])
        setPin(pin, id and id > 0 and id or nil)
        pin.onDrop = function(widget, dragged)
            local item = dragged and dragged.currentDragThing
            if not item or not item.isItem or not item:isItem() or item:isContainer() then
                return false
            end
            for _, other in ipairs(rulesWindow.pins:getChildren()) do
                if other.pinned == item:getId() then
                    return true
                end
            end
            setPin(widget, item:getId())
            return true
        end
        pin.onMouseRelease = function(widget, mousePos, button)
            if button == MouseRightButton and widget.pinned then
                setPin(widget, nil)
                return true
            end
            return false
        end
    end

    rulesWindow.close.onClick = closeRules
    rulesWindow.cancel.onClick = closeRules
    rulesWindow.clear.onClick = function()
        for _, pill in ipairs(rulesWindow.categories:getChildren()) do
            pill:setOn(false)
        end
        for _, pin in ipairs(rulesWindow.pins:getChildren()) do
            setPin(pin, nil)
        end
    end
    rulesWindow.save.onClick = function()
        local names, pins = {}, {}
        for _, pill in ipairs(rulesWindow.categories:getChildren()) do
            if pill:isOn() then
                names[#names + 1] = pill.categoryName
            end
        end
        for _, pin in ipairs(rulesWindow.pins:getChildren()) do
            if pin.pinned then
                pins[#pins + 1] = pin.pinned
            end
        end
        sendBag({ action = 'setRules', slot = rulesEdit.slot, item = rulesEdit.item, categories = names, pins = pins })
    end
    rulesWindow:setHeight(rulesWindow.save:getY() - rulesWindow:getY() + rulesWindow.save:getHeight() + 10)
    scheduleEvent(function()
        if rulesWindow then
            rulesWindow:setHeight(rulesWindow.save:getY() - rulesWindow:getY() + rulesWindow.save:getHeight() + 10)
        end
    end, 1)
end

local function openRules(id)
    local container = containerById(id)
    local slot = bagSlot(id)
    if not container or not slot or slot < 0 then
        modules.game_textmessage.displayFailureMessage(tr('Only the bags in your bag can have sort rules.'))
        return
    end
    closeRules()
    rulesEdit = { id = id, slot = slot, item = container:getContainerItem():getId() }
    sendBag({ action = 'rules', slot = slot, item = rulesEdit.item })
end

local function openTabMenu(id, tab, first, mousePos)
    local container = containerById(id)
    local menu = g_ui.createWidget('PopupMenu')
    menu:setGameMenu(true)
    menu:addOption(tr('Rename'), function() startRename(id, tab) end)
    if not first then
        menu:addOption(tr('Sort rules...'), function() openRules(id) end)
        menu:addOption(tr('Open as its own window'), function() openAsWindow(id) end)
        menu:addOption(tr('Close tab'), function() if container then g_game.close(container) end end)
    end
    menu:display(mousePos)
end

local scrolling = false

local function scrollTabs(by)
    tabOffset = tabOffset + by
    scrolling = true
    fillTabs()
    scrolling = false
end

-- the tabs that fit from tabOffset on, with arrows either side when some don't; the open one stays in view
layoutTabs = function()
    local bar = window.tabs
    local entries = {}
    for _, child in ipairs(bar:getChildren()) do
        entries[#entries + 1] = child
    end
    local function widthOf(first, last)
        local total = 0
        for i = first, last do
            total = total + entries[i]:getWidth() + (i > first and TAB_SPACING or 0)
        end
        return total
    end
    if #entries == 0 or widthOf(1, #entries) <= bar:getWidth() then
        tabOffset = 1
        return
    end
    local room = bar:getWidth() - 2 * (ARROW_WIDTH + TAB_SPACING)
    local open = 1
    for i, child in ipairs(entries) do
        if child:isOn() then
            open = i
        end
    end
    tabOffset = math.max(1, math.min(tabOffset, #entries))
    local function lastFrom(first)
        local last = first
        while last < #entries and widthOf(first, last + 1) <= room do
            last = last + 1
        end
        return last
    end
    if not scrolling then
        if open < tabOffset then
            tabOffset = open
        end
        while lastFrom(tabOffset) < open do
            tabOffset = tabOffset + 1
        end
    end
    while tabOffset > 1 and lastFrom(tabOffset - 1) == #entries do
        tabOffset = tabOffset - 1
    end
    local last = lastFrom(tabOffset)
    for i, child in ipairs(entries) do
        child:setVisible(i >= tabOffset and i <= last)
    end
    local left = g_ui.createWidget('PokegearBagArrow', bar)
    left:setText('<')
    bar:moveChildToIndex(left, 1)
    left:setEnabled(tabOffset > 1)
    left.onClick = function() scrollTabs(-1) end
    local right = g_ui.createWidget('PokegearBagArrow', bar)
    right:setText('>')
    right:setEnabled(last < #entries)
    right.onClick = function() scrollTabs(1) end
end

fillTabs = function()
    local bar = window.tabs
    bar:destroyChildren()
    local backpack = containerById(tabs[1])
    for index, id in ipairs(tabs) do
        local container = containerById(id)
        if container then
            local first = index == 1
            local tab = g_ui.createWidget('PokegearBagTab', bar)
            local name = titleOf(container)
            tab.bagName = name
            -- the open bag shows its name; the others only their sprite, so six tabs fit
            tab:setOn(id == selected)
            tab.name:setText(name)
            tab.name:setVisible(id == selected)
            if id == selected then
                tab.name:setTextAutoResize(true)
                local width = tab.name:getTextSize().width
                if width > NAME_WIDTH then
                    tab.name:setTextAutoResize(false)
                    tab.name:setWidth(NAME_WIDTH)
                    width = NAME_WIDTH
                end
                tab:setWidth(6 + 18 + 4 + width + 10)
            else
                tab:setWidth(30)
            end
            -- the bag itself, so dragging the icon takes the bag out like dragging it from the grid
            local slot = bagSlot(id)
            local item = first and backpackItem() or (slot and backpack and backpack:getItem(slot))
            if item and not first then
                tab.icon:setItem(item)
            else
                tab.icon:setVirtual(true)
                tab.icon:setItemId(item and item:getId() or container:getContainerItem():getId())
            end
            local space = string.format('%d / %d', container:getItemsCount(), container:getCapacity())
            tab:setTooltip(name .. '  ' .. space .. '\n' .. (first and tr('Your starting bag')
                or tr('Drag the bag icon to take it out')) .. '\n' .. tr('Right-click to rename'))
            local function select()
                selected = id
                fillTabs()
                fillGrid()
            end
            local function release(widget, mousePos, button)
                if button == MouseRightButton then
                    openTabMenu(id, tab, first, mousePos)
                    return true
                end
                return false
            end
            tab.onClick = select
            tab.onMouseRelease = release
            tab.onDrop = function(widget, dragged) return dropInto(id, dragged) end
            tab.icon.onClick = select
            tab.icon.onMouseRelease = function(widget, mousePos, button)
                if release(widget, mousePos, button) then
                    return true
                end
                if button == MouseLeftButton and widget:containsPoint(mousePos) then
                    select()
                    return true
                end
                return false
            end
            tab.icon.onDrop = tab.onDrop
        end
    end
    if backpack then
        local add = g_ui.createWidget('PokegearBagAddTab', bar)
        add:setTooltip(tr('Drop a bag here to add it as a tab'))
        add.onDrop = function(widget, dragged) return dropInto(tabs[1], dragged) end
    end
    layoutTabs()
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

sendBag = function(data)
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

-- while either switch is on, the gold ball shows a mark
local function refreshSwitches()
    if not window then
        return
    end
    window.switches.defense:setOn(switches.defense)
    window.switches.autoSwap:setOn(switches.autoSwap)
    local first = window.belt:getChildren()[1]
    if first and first.mark then
        first.mark:setVisible(first:getItem() ~= nil and (switches.defense or switches.autoSwap))
    end
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
    refreshSwitches()
end

local function onBagMessage(protocol, opcode, buffer)
    buffer = ProtocolGame.joinFragments(opcode, buffer)
    if not buffer then
        return
    end
    local ok, data = pcall(json.decode, buffer)
    if not ok or type(data) ~= 'table' then
        return
    end
    if data.type == 'categories' and type(data.list) == 'table' then
        categories, categoryOf, otherCategory, equipNames = {}, {}, nil, {}
        for _, entry in ipairs(type(data.equipment) == 'table' and data.equipment or {}) do
            if type(entry) == 'table' and tonumber(entry.id) then
                equipNames[tonumber(entry.id)] = tostring(entry.name or '')
            end
        end
        for index, category in ipairs(data.list) do
            categories[index] = { name = tostring(category.name), icon = tonumber(category.icon) or 0 }
            if category.name == 'Other' then
                otherCategory = index
            end
            for _, id in ipairs(type(category.items) == 'table' and category.items or {}) do
                categoryOf[id] = categoryOf[id] or index
            end
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
    elseif data.type == 'switches' then
        switches.defense = data.defense == true
        switches.autoSwap = data.autoSwap ~= false
        refreshSwitches()
    elseif data.type == 'renamed' then
        for id in pairs(tabSlot) do
            if bagSlot(id) == tonumber(data.slot) then
                tabNames[id] = tostring(data.name or '')
            end
        end
        if window and window:isVisible() then
            fillTabs()
        end
    elseif data.type == 'rules' then
        showRules(data)
    elseif data.type == 'sorted' then
        local moved = tonumber(data.moved) or 0
        modules.game_textmessage.displayStatusMessage(moved > 0 and tr('Sorted: %d items moved to their bags.', moved)
            or tr('Everything is already in the bag its rules choose.'))
    elseif data.type == 'error' then
        modules.game_textmessage.displayFailureMessage(tostring(data.text or ''))
    end
end

local function onGameStart()
    categories, categoryOf, otherCategory, filter, beltNumbers = {}, {}, nil, nil, nil
    switches = { defense = false, autoSwap = true }
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
    window.header.sort.onClick = function()
        sendBag({ action = 'sort' })
    end
    for _, name in ipairs({ 'defense', 'autoSwap' }) do
        window.switches[name].onClick = function()
            switches[name] = not switches[name]
            refreshSwitches()
            sendBag({ action = 'switches', [name] = switches[name] })
        end
    end
    window.tabs.onMouseWheel = function(widget, mousePos, direction)
        scrollTabs(direction == MouseWheelUp and -1 or 1)
        return true
    end
    restorePosition = Pokegear.makeMovable(window, window.header, POSITION_SETTING, function()
        -- left of the ring
        window:addAnchor(AnchorTop, 'pokegearHub', AnchorTop)
        window:addAnchor(AnchorRight, 'pokegearHub', AnchorLeft)
        window:setMarginTop(130)
        -- clear of Nearby under the small ring
        window:setMarginRight(Pokegear.isCompact() and 4 or -6)
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
    closeRules()
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
    pump()
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
        container.pokegearSlot = asked and asked.slot
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
        beltId, beltTries = id, 0
        if window and window:isVisible() then
            fillBelt()
        end
        pump()
        return
    end
    -- a tab's bag sent again after it moved out of the backpack
    if previousContainer and previousContainer:getId() == id and id ~= tabs[1] and isTab(id)
        and not container:hasParent() then
        g_game.close(container)
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
        tabSlot[id] = -1
        selected = selected or id
        if not beltId then
            -- game_pokehud asks for the belt as the backpack comes in
            beltAsked, beltTries = g_clock.millis(), 1
        end
        showWindow()
        openInnerBags(container)
        return
    end
    if not isTab(id) then
        tabs[#tabs + 1] = id
    end
    tabSlot[id] = container.pokegearSlot
    if container.pokegearSelect or not containerById(selected) then
        selected = id
    end
    showWindow()
    pump()
end

local closeAll

local function onContainerClose(container)
    local id = container:getId()
    if id == tabs[1] then
        closeAll()
        return
    end
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
    tabSlot[id], tabNames[id] = nil, nil
    if rulesEdit and rulesEdit.id == id then
        closeRules()
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

-- the backpack's items moved up or down a slot: so did the bags with tabs
local function shiftTabSlots(container, slot, by)
    if container:getId() ~= tabs[1] then
        return
    end
    for id, tabSlotNow in pairs(tabSlot) do
        if id ~= tabs[1] and tabSlotNow and tabSlotNow >= slot then
            if by < 0 and tabSlotNow == slot then
                -- the bag left the backpack (to the ground, the PC or another bag): so does its tab
                tabSlot[id] = nil
                local leaving = containerById(id)
                if leaving then
                    g_game.close(leaving)
                end
            else
                tabSlot[id] = tabSlotNow + by
            end
        end
    end
    for _, entry in ipairs(pending) do
        if entry.slot and entry.slot >= slot then
            entry.slot = (by < 0 and entry.slot == slot) and nil or entry.slot + by
        end
    end
end

local function onContainerRemoveItem(container, slot, item)
    shiftTabSlots(container, slot, -1)
    if window and window:isVisible() and container:getId() == tabs[1] then
        fillTabs()
    end
end

local function onContainerAddItem(container, slot, item)
    shiftTabSlots(container, slot, 1)
    if window and window:isVisible() and container:getId() == tabs[1] then
        fillTabs()
    end
    onContainerChange(container)
    if container:getId() == tabs[1] and item and item:isContainer() then
        queueBag(item)
        if settleEvent then
            removeEvent(settleEvent)
        end
        settleEvent = scheduleEvent(function()
            settleEvent = nil
            pump()
        end, SETTLE_TIME)
    end
end

closeAll = function()
    for i = #tabs, 1, -1 do
        local container = containerById(tabs[i])
        if container then
            g_game.close(container)
        end
    end
    tabs, selected, beltId, queued, tabSlot, tabNames, tabOffset = {}, nil, nil, {}, {}, {}, 1
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
        beltTries = 0
        pump()
    else
        g_game.open(back)
    end
end

function Bag.close()
    closeAll()
end

function Bag.backpackContainer()
    return containerById(tabs[1])
end

-- the screen crossed the compact size
function Bag.relayout()
    if Bag.isOpen() then
        restorePosition()
        fillGrid()
    end
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
        onRemoveItem = onContainerRemoveItem,
    })
    connect(LocalPlayer, { onInventoryChange = onInventoryChange })
    connect(g_game, { onGameStart = onGameStart, onPokemonBarAdd = onQuickCallChange,
        onPokemonBarRemove = onQuickCallChange, onPokemonBarOrder = onQuickCallChange })
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
    classicWindows = nil
    for _, container in pairs(g_game.getContainers()) do
        local belt = isBelt(container)
        if belt or container == backpack or container:hasParent() then
            local w = container.window
            if w and not w:isDestroyed() and w:getParent() then
                classicWindows = classicWindows or {}
                classicWindows[container:getId()] = { panel = w:getParent(), index = w:getParent():getChildIndex(w),
                    height = w:getHeight() }
            end
            if containers then
                containers.destroy(container)
            end
            container.pokegearClaimed = true
            if belt then
                beltId = container:getId()
            elseif container ~= backpack then
                tabs[#tabs + 1] = container:getId()
                tabSlot[container:getId()] = false
            end
        end
    end
    table.insert(tabs, 1, backpack:getId())
    tabSlot[backpack:getId()] = -1
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
    local keep = { [tabs[1] or -1] = true, [beltId or -1] = true }
    tabs, selected, beltId, pending, queued, tabSlot, tabNames = {}, nil, nil, {}, {}, {}, {}
    cancelSettle()
    hideWindow()
    local containers = modules.game_containers
    local restore = classicWindows
    classicWindows = nil
    local reopened = {}
    for _, id in ipairs(ids) do
        local container = containerById(id)
        if container then
            container.pokegearClaimed = nil
            local spot = restore and restore[id]
            if not keep[id] and not spot then
                -- opened by the Bag; Classic gets back the windows it had, and always the backpack and the belt
                g_game.close(container)
            elseif containers then
                reopened[#reopened + 1] = { container = container, spot = spot }
            end
        end
    end
    table.sort(reopened, function(a, b) return (a.spot and a.spot.index or 1000) < (b.spot and b.spot.index or 1000) end)
    -- after the whole switch: until the right column has its Classic size, a side panel closes what doesn't
    -- fit. A container without a window to go back to (Pokegear since login) goes where game_containers puts it.
    addEvent(function()
        if active then
            return
        end
        for _, entry in ipairs(reopened) do
            local container, spot = entry.container, entry.spot
            if containerById(container:getId()) == container then
                if not container.window then
                    containers.onContainerOpen(container)
                end
                local w = container.window
                if w and spot and not w:isDestroyed() and not spot.panel:isDestroyed() then
                    if w:getParent() ~= spot.panel then
                        w:getParent():removeChild(w)
                        spot.panel:insertChild(math.min(spot.index, spot.panel:getChildCount() + 1), w)
                    end
                    w:setHeight(spot.height)
                end
            end
        end
    end)
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
    tabs, selected, beltId, pending, queued, tabSlot, tabNames = {}, nil, nil, {}, {}, {}, {}
    classicWindows = nil
    cancelSettle()
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
        onRemoveItem = onContainerRemoveItem,
    })
    disconnect(LocalPlayer, { onInventoryChange = onInventoryChange })
    disconnect(g_game, { onGameStart = onGameStart, onPokemonBarAdd = onQuickCallChange,
        onPokemonBarRemove = onQuickCallChange, onPokemonBarOrder = onQuickCallChange })
    disconnect(Keybind, { onBind = onQuickCallChange })
    ProtocolGame.unregisterExtendedOpcode(ExtendedIds.Bag)
    if beltRequest then
        removeEvent(beltRequest)
        beltRequest = nil
    end
    Keybind.delete(KEY[1], KEY[2])
    active = false
    hideWindow()
    if window then
        window:destroy()
        window = nil
    end
    tabs, selected, pending, queued = {}, nil, {}, {}
    cancelSettle()
end
