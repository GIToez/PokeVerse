-- Constants
local DEX_ITEMIDS = {11241, 17270}
local EMPTY_SLOT_OPACITY = 0.3

-- Client ids of the earned badges and of their empty slots, by badge name
local BADGES = {
    {name = 'Boulder', earned = 11174, empty = 11175},
    {name = 'Cascade', earned = 11176, empty = 11177},
    {name = 'Thunder', earned = 11178, empty = 11179},
    {name = 'Rainbow', earned = 11180, empty = 11181},
    {name = 'Soul', earned = 11182, empty = 11183},
    {name = 'Marsh', earned = 11184, empty = 11185},
    {name = 'Volcano', earned = 11186, empty = 11187},
    {name = 'Earth', earned = 11188, empty = 11189},
    {name = 'Coral Eye', earned = 16844, empty = 17271},
    {name = 'Sea Ruby', earned = 16845, empty = 17272},
    {name = 'Spike Shell', earned = 16846, empty = 17273},
    {name = 'Jade Star', earned = 16847, empty = 17274},
}

local BADGE_BY_ITEMID = {}
for _, badge in ipairs(BADGES) do
    BADGE_BY_ITEMID[badge.earned] = {name = badge.name, earned = true}
    BADGE_BY_ITEMID[badge.empty] = {name = badge.name, earned = false}
end

-- Vars
local window, panel, openContainer

-- Methods
local function hide()
    window:hide()
end

local function show()
    window:show()
end

local function reset()
    panel:destroyChildren()
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

local function refresh(container)
    panel:destroyChildren()
    window:getChildById('icon'):setItemId(container:getContainerItem():getId())

    for slot = 0, container:getCapacity() - 1 do
        local item = container:getItem(slot)
        local itemWidget = g_ui.createWidget('BadgeItem', panel)
        itemWidget:setId('item' .. slot)
        itemWidget:setMargin(0)
        itemWidget:setItem(item)
        itemWidget.position = container:getSlotPosition(slot)
        styleBadgeWidget(itemWidget, item)
    end

    -- Runs after game_containers fills its own window, where it shows one for this container too
    scheduleEvent(function() styleContainerPanel(container) end, 1)
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
        openContainer = container
        refresh(container)
        show()
    end
end

function onContainerClose(container)
    if (container == openContainer) then
        openContainer = nil
    end
end

local function onContainerChange(container)
    if (container == openContainer) then
        refresh(container)
    end
end

function onInit()
    g_ui.importStyle('badgecase')

    window = g_ui.createWidget('BadgeCaseWindow', modules.game_interface.getRootPanel())
    window:setup()
    window:setPosition({
        x = (g_window.getDisplaySize().width - window:getWidth()) / 2,
        y = (g_window.getDisplaySize().height - window:getHeight()) / 2})
    window:setVisible(false)
    window:setDroppable(false)

    panel = window:recursiveGetChildById('ownDexContainer')

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
    window:destroyChildren()
    window:destroy()
end
