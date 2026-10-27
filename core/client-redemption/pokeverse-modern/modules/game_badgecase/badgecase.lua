-- The badge case window: one region's badges at a time (Kanto first, the arrows go to the next region),
-- the same regions and order as the Trainer Card's badge row (BADGE_REGIONS in the server's 071-trainerCard.lua).
-- The badges come from the badge case container; badges not in the game yet show as locked slots.

local DEX_ITEMIDS = {11241, 17270}
local EMPTY_SLOT_OPACITY = 0.3

-- Client ids of the earned badges and of their empty slots
local REGIONS = {
    { name = 'Kanto', badges = {
        {name = 'Boulder', earned = 11174, empty = 11175},
        {name = 'Cascade', earned = 11176, empty = 11177},
        {name = 'Thunder', earned = 11178, empty = 11179},
        {name = 'Rainbow', earned = 11180, empty = 11181},
        {name = 'Soul', earned = 11182, empty = 11183},
        {name = 'Marsh', earned = 11184, empty = 11185},
        {name = 'Volcano', earned = 11186, empty = 11187},
        {name = 'Earth', earned = 11188, empty = 11189},
    } },
    { name = 'Orange Islands', badges = {
        {name = 'Coral Eye', earned = 16844, empty = 17271},
        {name = 'Sea Ruby', earned = 16845, empty = 17272},
        {name = 'Spike Shell', earned = 16846, empty = 17273},
        {name = 'Jade Star', earned = 16847, empty = 17274},
    } },
    { name = 'Johto', upcoming = {'Zephyr', 'Hive', 'Plain', 'Fog', 'Storm', 'Mineral', 'Glacier', 'Rising'} },
    { name = 'Hoenn', upcoming = {'Stone', 'Knuckle', 'Dynamo', 'Heat', 'Balance', 'Feather', 'Mind', 'Rain'} },
}

local BADGE_BY_ITEMID = {}
for _, region in ipairs(REGIONS) do
    for _, badge in ipairs(region.badges or {}) do
        BADGE_BY_ITEMID[badge.earned] = {name = badge.name, earned = true}
        BADGE_BY_ITEMID[badge.empty] = {name = badge.name, earned = false}
    end
end

local window, openContainer
local region = 1

local function hide()
    window:hide()
end

local function reset()
    if window then
        window.panel.list:destroyChildren()
    end
    openContainer = nil
end

function isDexContainer(container)
    return table.find(DEX_ITEMIDS, container:getContainerItem():getId())
end

-- The earned and empty art of some badges (Boulder) is nearly identical, so empty slots are faded.
local function styleBadgeWidget(widget, item)
    local badge = item and BADGE_BY_ITEMID[item:getId()]
    if (not badge) then
        widget:setOpacity(1)
        widget:removeTooltip()
        return
    end

    widget:setOpacity(badge.earned and 1 or EMPTY_SLOT_OPACITY)
    widget:setTooltip(badge.earned and tr('%s Badge', badge.name) or tr('%s Badge (not earned yet)', badge.name))
end

-- game_containers shows its own window for this container too
local function styleContainerPanel(container)
    if (not container.itemsPanel) then
        return
    end

    for slot = 0, container:getCapacity() - 1 do
        local widget = container.itemsPanel:getChildById('item' .. slot)
        if (widget) then
            styleBadgeWidget(widget, container:getItem(slot))
        end
    end
end

-- The client ids in the case; a case from before a region was added has no slot for its badges
local function caseItems(container)
    local ids = {}
    for slot = 0, container:getCapacity() - 1 do
        local item = container:getItem(slot)
        if (item) then
            ids[item:getId()] = true
        end
    end
    return ids
end

-- the grey slot art of a badge with no item yet (data/images/pokeverse-ui/badges)
function badgeArt(regionName, badgeName)
    return '/images/pokeverse-ui/badges/' .. regionName:lower():gsub('%s+', '-') .. '-' .. badgeName:lower() .. '-slot'
end

local function refresh(container)
    local panel = window.panel
    panel.list:destroyChildren()
    window.icon:setItemId(container:getContainerItem():getId())

    local ids = caseItems(container)
    local earned, total = 0, 0
    for _, r in ipairs(REGIONS) do
        for _, badge in ipairs(r.badges or {}) do
            earned = earned + (ids[badge.earned] and 1 or 0)
        end
        total = total + #(r.badges or {}) + #(r.upcoming or {})
    end
    window.subtitle:setText(tr('%d of %d badges earned', earned, total))

    local shown = REGIONS[region]
    local slots = {}
    local regionEarned = 0
    for _, badge in ipairs(shown.badges or {}) do
        local have = ids[badge.earned] == true
        regionEarned = regionEarned + (have and 1 or 0)
        slots[#slots + 1] = {name = badge.name, item = have and badge.earned or badge.empty, earned = have}
    end
    for _, name in ipairs(shown.upcoming or {}) do
        slots[#slots + 1] = {name = name, upcoming = true}
    end
    panel.region:setText(shown.name)
    panel.count:setText(shown.upcoming and tr('Coming soon') or string.format('%d / %d', regionEarned, #slots))

    -- the list sits between the arrows, whose layout may not have run yet
    local width = panel:getPaddingRect().width - 2 * (panel.prevRegion:getWidth() + 6)
    local cell = 64
    local step = math.min(cell + 6, #slots > 1 and math.floor((width - cell) / (#slots - 1)) or 0)
    local left = math.floor((width - (cell + step * (#slots - 1))) / 2)
    for i, slot in ipairs(slots) do
        local widget = g_ui.createWidget('BcBadge', panel.list)
        widget:addAnchor(AnchorTop, 'parent', AnchorTop)
        widget:addAnchor(AnchorLeft, 'parent', AnchorLeft)
        widget:setMarginLeft(left + (i - 1) * step)
        widget.name:setText(slot.name)
        if (slot.upcoming) then
            widget.item:hide()
            widget.art:setImageSource(badgeArt(shown.name, slot.name))
            widget.art:setOpacity(EMPTY_SLOT_OPACITY)
            widget.art:show()
            widget.name:setColor('#5f6f8f')
            widget:setTooltip(tr('%s Badge (coming soon)', slot.name))
        else
            widget.item:setItemId(slot.item)
            widget.item:setOpacity(slot.earned and 1 or EMPTY_SLOT_OPACITY)
            if (slot.earned) then
                widget.slot:setImageSource('/modules/game_trainercard/images/slot_on')
                widget.name:setColor('#ffffff')
            end
            widget:setTooltip(slot.earned and tr('%s Badge', slot.name) or tr('%s Badge (not earned yet)', slot.name))
        end
    end

    scheduleEvent(function() styleContainerPanel(container) end, 1)
end

function showRegion(step)
    region = (region - 1 + step) % #REGIONS + 1
    if (openContainer) then
        refresh(openContainer)
    end
end

function close()
    hide()
    if (openContainer) then
        g_game.close(openContainer)
    end
end

-- Hooks

function onOnline()
    reset()
end

function onOffline()
    hide()
    reset()
end

function onContainerOpen(container, previousContainer)
    if (isDexContainer(container)) then
        if (not window:isVisible()) then
            region = 1
            local root = rootWidget:getSize()
            window:setPosition({ x = math.floor((root.width - window:getWidth()) / 2),
                                 y = math.max(0, math.floor((root.height - window:getHeight()) / 2)) })
        end
        openContainer = container
        refresh(container)
        window:show()
        window:raise()
        window:focus()
    end
end

function onContainerClose(container)
    if (container == openContainer) then
        openContainer = nil
        hide()
    end
end

local function onContainerChange(container)
    if (container == openContainer) then
        refresh(container)
    end
end

function onInit()
    g_ui.importStyle('badgecase')

    window = g_ui.createWidget('BadgeCaseWindow', rootWidget)
    window:hide()

    connect(g_game, {
        onGameStart = onOnline,
        onGameEnd = onOffline
    })

    connect(Container, {
        onOpen = onContainerOpen,
        onClose = onContainerClose,
        onAddItem = onContainerChange,
        onUpdateItem = onContainerChange,
        onRemoveItem = onContainerChange
    })

    if (g_game.isOnline()) then
        onOnline()
    end
end

function onTerminate()
    disconnect(g_game, {
        onGameStart = onOnline,
        onGameEnd = onOffline
    })

    disconnect(Container, {
        onOpen = onContainerOpen,
        onClose = onContainerClose,
        onAddItem = onContainerChange,
        onUpdateItem = onContainerChange,
        onRemoveItem = onContainerChange
    })

    reset()
    window:destroy()
    window = nil
end
