-- Loot: what auto loot picks up, listed under the HUD; the window a body opens in when you open it
-- yourself; and the Auto loot setting, kept the same in that window, Settings and /autoloot.
Loot = {}

local FEED_ROWS = 4
local FEED_TIME = 5000
local FADE_TIME = 600
local COLUMNS = 5
local CELL = 38
local CELL_SPACING = 3
-- the server's words when the bags are full (monster.cpp); the list comes just before it
local FULL_TEXT = 'Loot not collected! Check your backpack.'
local POSITION_SETTING = 'pokegearLootPos'

local active = false
local feed, window, restorePosition
local rows = {} -- key (an item id, or 'full') -> { widget, count, event }
local body -- the open body's container
local lastListAt = 0

local function autoLootOn()
    local options = modules.client_options
    return options ~= nil and options.getOption('autoLoot') == true
end

-- "fainted pidgey" is a body; the bags and the PC are not
local function isBody(container)
    return container ~= nil and not container:hasParent() and container:getName():lower():find('^fainted ') ~= nil
end

local function speciesOf(container)
    local name = container:getName():gsub('^[Ff]ainted ', '')
    return (name:gsub('(%a)(%w*)', function(first, rest) return first:upper() .. rest end))
end

local function nameOf(itemId)
    local name = getItemNameByClientId and getItemNameByClientId(itemId) or ''
    return name ~= '' and (name:gsub('^%l', string.upper)) or nil
end

-- game_lootlist (from the legacy client) draws its own fading icons; the list under the HUD takes over
local function classicList(visible)
    local classic = modules.game_lootlist
    if classic and classic.lootList then
        classic.lootList:setVisible(visible)
    end
end

-- Feed -------------------------------------------------------------------------------------------

local function removeRow(key)
    local row = rows[key]
    if not row then
        return
    end
    rows[key] = nil
    if row.event then
        removeEvent(row.event)
    end
    if not row.widget:isDestroyed() then
        row.widget:destroy()
    end
end

local function clearFeed()
    for key in pairs(rows) do
        removeRow(key)
    end
end

local function fadeLater(key)
    local row = rows[key]
    if row.event then
        removeEvent(row.event)
    end
    row.event = scheduleEvent(function()
        g_effects.fadeOut(row.widget, FADE_TIME)
        row.event = scheduleEvent(function()
            row.event = nil
            if rows[key] == row then
                removeRow(key)
            end
        end, FADE_TIME)
    end, FEED_TIME)
end

local function placeFeed()
    feed:breakAnchors()
    if feed:getParent():getChildById('pokeHud') then
        feed:addAnchor(AnchorTop, 'pokeHud', AnchorBottom)
        feed:addAnchor(AnchorHorizontalCenter, 'pokeHud', AnchorHorizontalCenter)
        feed:setMarginTop(6)
    else
        feed:addAnchor(AnchorTop, 'gameMapPanel', AnchorTop)
        feed:addAnchor(AnchorHorizontalCenter, 'gameMapPanel', AnchorHorizontalCenter)
        feed:setMarginTop(120)
    end
end

-- newest on top; a second Feather while the first still shows adds to its count
local function addRow(key, itemId, count, text, warn)
    if not active or not feed then
        return
    end
    local row = rows[key]
    if row then
        g_effects.cancelFade(row.widget)
        row.widget:setOpacity(1)
        feed:moveChildToIndex(row.widget, 1)
    else
        row = { widget = g_ui.createWidget('PokegearLootRow', feed), count = 0 }
        rows[key] = row
        feed:moveChildToIndex(row.widget, 1)
        local children = feed:getChildren()
        if #children > FEED_ROWS then
            for k, other in pairs(rows) do
                if other.widget == children[#children] then
                    removeRow(k)
                    break
                end
            end
        end
    end
    row.count = row.count + (count or 0)
    local pill = row.widget.pill
    pill.item:setVisible(itemId ~= nil)
    if itemId then
        pill.item:setItemId(itemId)
        local name = nameOf(itemId)
        if name then
            text = row.count > 1 and tr('%dx %s', row.count, name) or name
        else
            text = tr('%dx', row.count)
        end
    end
    pill.text:setText(text)
    pill.text:setColor(warn and '#ffb38a' or '#eef2ff')
    pill.text:setMarginLeft(itemId and 6 or 12)
    pill:setOn(warn == true)
    pill:setWidth(pill.text:getTextSize().width + (itemId and 44 or 24))
    fadeLater(key)
end

local function onLootList(list)
    lastListAt = g_clock.millis()
    if active then
        -- it shows itself again at every login
        classicList(false)
    end
    for itemId, count in pairs(list) do
        addRow(itemId, itemId, count)
    end
end

local function onTextMessage(mode, text)
    if text ~= FULL_TEXT then
        return
    end
    local partial = g_clock.millis() - lastListAt < 500
    addRow('full', nil, nil, partial and tr('Some loot stayed on the body, your bags are full')
        or tr('Nothing looted, your bags are full'), true)
end

-- Body window ------------------------------------------------------------------------------------

local function hideWindow()
    if window then
        window:hide()
    end
end

local function refreshWindow()
    if not window or not body then
        return
    end
    local species = speciesOf(body)
    window.header.title:setText(species)
    local number = getPokemonNumberByName and getPokemonNumberByName(species)
    window.header.portrait:setImageSource(number and ('/images/staticPortraits/' .. number) or '')
    -- the portraits are 96x96 with the Pokemon in the middle
    window.header.portrait:setImageClip({ x = 22, y = 22, width = 52, height = 52 })
    local grid = window.grid
    grid:destroyChildren()
    local shown = 0
    for slot = 0, body:getCapacity() - 1 do
        local item = body:getItem(slot)
        if item then
            local widget = g_ui.createWidget('PokegearLootItem', grid)
            widget:setId('item' .. slot)
            widget:setItem(item)
            widget.position = body:getSlotPosition(slot)
            shown = shown + 1
        end
    end
    local lines = math.max(1, math.ceil(shown / COLUMNS))
    local height = lines * (CELL + CELL_SPACING) - CELL_SPACING
    grid:setHeight(height)
    window.empty:setVisible(shown == 0)
    window.takeAll:setEnabled(shown > 0)
    window.autoLoot:setOn(autoLootOn())
    window:setHeight(window:getPaddingTop() + window.header:getHeight() + grid:getMarginTop() + height +
        window.takeAll:getMarginTop() + window.takeAll:getHeight() + window:getPaddingBottom())
end

local function showWindow()
    if not window then
        return
    end
    restorePosition()
    window:show()
    window:raise()
    refreshWindow()
end

-- the Bag's own bag: the back slot, or the ammo slot where PokeVerse keeps it
local function backpackSlot()
    local player = g_game.getLocalPlayer()
    for _, slot in ipairs({ InventorySlotBack, InventorySlotAmmo }) do
        local item = player and player:getInventoryItem(slot)
        if item and item:isContainer() then
            return slot
        end
    end
    return InventorySlotBack
end

local function takeAll()
    if not body then
        return
    end
    local to = { x = 65535, y = backpackSlot(), z = 0 }
    for slot = body:getCapacity() - 1, 0, -1 do
        local item = body:getItem(slot)
        if item then
            g_game.move(item, to, item:getCount())
        end
    end
end

local function closeBody()
    if body then
        g_game.close(body)
    end
    body = nil
    hideWindow()
end

function Loot.claimsContainer(container)
    return active and isBody(container)
end

local function onContainerOpen(container, previousContainer)
    if not Loot.claimsContainer(container) then
        if previousContainer and previousContainer == body then
            body = nil
            hideWindow()
        end
        return
    end
    if body and body ~= container and body ~= previousContainer then
        g_game.close(body)
    end
    body = container
    showWindow()
end

local function onContainerClose(container)
    if container == body then
        body = nil
        hideWindow()
    end
end

local function onContainerChange(container)
    if container == body then
        refreshWindow()
    end
end

local function onAutoLoot(protocol, opcode, buffer)
    local on = buffer == '1'
    local options = modules.client_options
    if options and options.getOption('autoLoot') ~= on then
        options.setOption('autoLoot', on)
    end
    if window and window:isVisible() then
        window.autoLoot:setOn(on)
    end
end

-- Layout -----------------------------------------------------------------------------------------

local function adoptBodies()
    local containers = modules.game_containers
    for _, container in pairs(g_game.getContainers()) do
        if isBody(container) then
            if body and body ~= container then
                g_game.close(body)
            end
            if containers then
                containers.destroy(container)
            end
            body = container
        end
    end
    if body then
        showWindow()
    end
end

local function releaseBody()
    local open = body
    body = nil
    hideWindow()
    if open and modules.game_containers then
        modules.game_containers.onContainerOpen(open)
    end
end

function Loot.apply(isActive)
    local now = isActive and g_game.isOnline()
    if now == active then
        return
    end
    active = now
    if active then
        placeFeed()
        feed:show()
        classicList(false)
        adoptBodies()
    else
        clearFeed()
        feed:hide()
        classicList(true)
        releaseBody()
    end
end

-- logging out: the body and the list go with the game
function Loot.reset()
    active = false
    body = nil
    hideWindow()
    clearFeed()
    if feed then
        feed:hide()
    end
end

function Loot.init()
    g_ui.importStyle('loot')
    local root = modules.game_interface.getRootPanel()
    feed = g_ui.createWidget('PokegearLootFeed', root)
    feed:hide()
    window = g_ui.createWidget('PokegearLoot', root)
    window:hide()
    window.header.close.onClick = closeBody
    window.takeAll.onClick = takeAll
    window.autoLoot.onClick = function()
        local options = modules.client_options
        if options then
            options.setOption('autoLoot', not autoLootOn())
        end
        window.autoLoot:setOn(autoLootOn())
    end
    restorePosition = Pokegear.makeMovable(window, window.header, POSITION_SETTING, function()
        window:addAnchor(AnchorVerticalCenter, 'gameMapPanel', AnchorVerticalCenter)
        window:addAnchor(AnchorRight, 'gameMapPanel', AnchorHorizontalCenter)
        window:setMarginRight(90)
    end)
    connect(Container, {
        onOpen = onContainerOpen,
        onClose = onContainerClose,
        onSizeChange = onContainerChange,
        onUpdateItem = onContainerChange,
        onAddItem = onContainerChange,
        onRemoveItem = onContainerChange,
    })
    connect(g_game, { onLootList = onLootList, onTextMessage = onTextMessage })
    ProtocolGame.registerExtendedOpcode(ExtendedIds.AutoLoot, onAutoLoot)
end

function Loot.terminate()
    disconnect(Container, {
        onOpen = onContainerOpen,
        onClose = onContainerClose,
        onSizeChange = onContainerChange,
        onUpdateItem = onContainerChange,
        onAddItem = onContainerChange,
        onRemoveItem = onContainerChange,
    })
    disconnect(g_game, { onLootList = onLootList, onTextMessage = onTextMessage })
    ProtocolGame.unregisterExtendedOpcode(ExtendedIds.AutoLoot)
    clearFeed()
    if feed then
        feed:destroy()
        feed = nil
    end
    if window then
        window:destroy()
        window = nil
    end
    active = false
    body = nil
end
