-- Phones and tablets in Pokegear (docs/concepts/phone-layout). The top bar keeps the Store, Settings
-- and Exit; its other buttons fold into an apps drawer of big tiles. Attack / Follow / Look / Use
-- (game_shortcuts) fold into a button beside the moves bar. None of it runs on desktop clients.
Phone = {}

local BAR_KEEPS = { ['Store shop'] = true, optionsButton = true, logoutButton = true }
local BAR_HEIGHT, BAR_BUTTON_SIZE = 44, 30
local TILE_WIDTH, TILE_HEIGHT, TILE_SPACING, TILE_BUTTON_SIZE = 76, 70, 6, 44
local TILE_ICON_SIZE = 28
local DRAWER_COLUMNS, DRAWER_PADDING = 5, 10
local ACTIONS = { 'attack', 'follow', 'look', 'use' }
local ACTION_SIZE, ACTION_SPACING, ACTION_PADDING = 64, 4, 6
-- a root this short is a phone (a tablet is taller, even at the same zoom)
local PHONE_HEIGHT = 640
local TICK_MS = 250
local SWEEP_TICKS = 8

local on = false
local drawer, scrim, appsButton, actionsButton, tickEvent
local ticks, lastArmed = 0, nil
-- top bar buttons in the drawer: { button, tile, index, size, release, source, iconSize }
local taken = {}
local barSizes = {}
local barHeight
local storeFixed

function Phone.isPhone()
    local root = g_ui.getRootWidget()
    return g_platform.isMobile() and root ~= nil and root:getHeight() < PHONE_HEIGHT
end

function Phone.findButton(id)
    for _, entry in ipairs(taken) do
        if entry.button:getId() == id then
            return entry.button
        end
    end
end

-- the chat's corner spot starts right of the joystick while that sits in its own corner
function Phone.chatMarginLeft(margin, parent)
    local joystick = modules.game_joystick
    local pad = g_platform.isMobile() and joystick and joystick.getPanel and joystick.getPanel()
    if not pad or not parent or g_settings.getNode('joystickPos') or pad:getWidth() <= 0 then
        return margin
    end
    -- the pad's picture stops a little short of its right edge
    return pad:getX() + pad:getWidth() - parent:getX() - 8
end

local function topMenu()
    local topmenu = modules.client_topmenu
    return topmenu and topmenu.getTopMenu and topmenu.getTopMenu()
end

local function barPanel()
    local topmenu = modules.client_topmenu
    return topmenu and topmenu.getRightGameButtonsPanel and topmenu.getRightGameButtonsPanel()
end

local function shortcuts()
    local module = modules.game_shortcuts
    return module and module.getPanel and module.getPanel()
end

local function armed()
    local module = modules.game_shortcuts
    return module and module.getShortcut and module.getShortcut() or ''
end

-- the apps drawer

local function closeDrawer()
    if drawer then
        drawer:hide()
        scrim:hide()
    end
    if appsButton then
        appsButton:setOn(false)
    end
end

local function press(button)
    if button.onMouseRelease then
        local pos = button:getPosition()
        button.onMouseRelease(button, { x = pos.x + 1, y = pos.y + 1 }, MouseLeftButton)
    end
end

-- "Quests (Ctrl+Q)" reads "Quests" on a tile
local function tileLabel(button)
    local text = (button:getTooltip() or ''):gsub('%s*%b()%s*$', '')
    return text ~= '' and text or button:getId()
end

local function take(button, index)
    local entry = { button = button, index = index, size = button:getSize(), release = button.onMouseRelease,
                    source = button:getImageSource(), iconSize = button:getIconSize() }
    local tile = g_ui.createWidget('PokegearAppTile', drawer.tiles)
    tile:setId(button:getId() .. 'Tile')
    button:getParent():removeChild(button)
    tile:addChild(button)
    button:addAnchor(AnchorTop, 'parent', AnchorTop)
    button:addAnchor(AnchorHorizontalCenter, 'parent', AnchorHorizontalCenter)
    button:setMarginTop(2)
    button:setSize({ width = TILE_BUTTON_SIZE, height = TILE_BUTTON_SIZE })
    -- the bar's 20px art is drawn with a frame border, so scaled up its middle tiles into copies: the
    -- tile shows it whole instead (the button's clip follows its pressed and on states)
    tile.icon:setImageSource(entry.source)
    button:setImageSource('')
    button:setIconSize({ width = TILE_ICON_SIZE, height = TILE_ICON_SIZE })
    button.onMouseRelease = function(widget, mousePos, mouseButton)
        local done = entry.release and entry.release(widget, mousePos, mouseButton)
        if done then
            closeDrawer()
        end
        return done
    end
    tile.onClick = function()
        press(button)
    end
    entry.tile = tile
    taken[#taken + 1] = entry
end

local function fitDrawer()
    local count = 0
    for _, entry in ipairs(taken) do
        entry.tile:setVisible(entry.button:isExplicitlyVisible())
        entry.tile.icon:setImageClip(entry.button:getImageClip())
        local label = tileLabel(entry.button)
        if entry.tile.label.fullText ~= label then
            Pokegear.fitText(entry.tile.label, label)
        end
        if entry.tile:isExplicitlyVisible() then
            count = count + 1
        end
    end
    local menu = topMenu()
    local top = (menu and menu:getHeight() or 0) + 4
    local root = g_ui.getRootWidget()
    local function width(columns)
        return columns * TILE_WIDTH + (columns - 1) * TILE_SPACING + DRAWER_PADDING * 2
    end
    local function height(columns)
        local rows = math.max(1, math.ceil(count / columns))
        return rows * TILE_HEIGHT + (rows - 1) * TILE_SPACING + DRAWER_PADDING * 2
    end
    -- wider rather than off the bottom of a short screen
    local columns = math.max(1, math.min(DRAWER_COLUMNS, count))
    while columns < count and height(columns) > root:getHeight() - top - 6
        and width(columns + 1) <= root:getWidth() - 12 do
        columns = columns + 1
    end
    drawer.tiles:getLayout():setNumColumns(columns)
    drawer:setSize({ width = width(columns), height = height(columns) })
    drawer:setMarginTop(top)
end

-- whatever is in the top bar besides the Store, Settings and Exit moves into the drawer; buttons that
-- only show up later (unlocked, or a module that loads late) follow on the next sweep
local function sweep()
    local panel = barPanel()
    if not panel or not drawer then
        return
    end
    local children = panel:getChildren()
    for index, child in ipairs(children) do
        local id = child:getId() or ''
        if child ~= appsButton and not BAR_KEEPS[id] and not id:find('^topBarSeparator') then
            take(child, index)
        end
    end
    fitDrawer()
end

local function openDrawer()
    sweep()
    scrim:show()
    scrim:raise()
    drawer:show()
    drawer:raise()
    appsButton:setOn(true)
end

local function enableTopBar()
    local panel, menu = barPanel(), topMenu()
    if not panel or not menu then
        return
    end
    local root = g_ui.getRootWidget()
    scrim = g_ui.createWidget('PokegearPhoneScrim', root)
    scrim.onMousePress = function()
        closeDrawer()
        return true
    end
    drawer = g_ui.createWidget('PokegearAppsDrawer', root)
    drawer:setId('pokegearAppsDrawer')
    drawer:addAnchor(AnchorTop, 'parent', AnchorTop)
    drawer:addAnchor(AnchorRight, 'parent', AnchorRight)
    drawer:setMarginRight(6)
    sweep()

    appsButton = g_ui.createWidget('PokegearPhoneButton')
    appsButton:setId('pokegearAppsButton')
    appsButton:setSize({ width = BAR_BUTTON_SIZE, height = BAR_BUTTON_SIZE })
    appsButton.icon:setImageSource('/modules/game_pokegear/images/apps')
    appsButton:setTooltip(tr('Apps'))
    appsButton.onClick = function()
        if drawer:isVisible() then
            closeDrawer()
        else
            openDrawer()
        end
    end
    local store = panel:getChildById('Store shop')
    if store then
        panel:insertChild(panel:getChildIndex(store), appsButton)
    else
        panel:addChild(appsButton)
    end

    for id in pairs(BAR_KEEPS) do
        local button = panel:getChildById(id)
        if button and id ~= 'Store shop' then
            barSizes[id] = button:getSize()
            button:setFixedSize(true)
            button:setSize({ width = BAR_BUTTON_SIZE, height = BAR_BUTTON_SIZE })
        end
    end
    -- the taller bar would stretch the Store's picture (a two-state sheet)
    local store = panel:getChildById('Store shop')
    if store then
        storeFixed = store:isFixedSize()
        store:setFixedSize(true)
        store:setSize({ width = 108, height = 20 })
    end
    appsButton:setFixedSize(true)
    appsButton:setSize({ width = BAR_BUTTON_SIZE, height = BAR_BUTTON_SIZE })
    barHeight = menu:getHeight()
    menu:setHeight(BAR_HEIGHT)
end

local function disableTopBar()
    closeDrawer()
    local panel, menu = barPanel(), topMenu()
    if appsButton then
        appsButton:destroy()
        appsButton = nil
    end
    table.sort(taken, function(a, b)
        return a.index < b.index
    end)
    for _, entry in ipairs(taken) do
        local button = entry.button
        button.onMouseRelease = entry.release
        if not button:isDestroyed() then
            button:getParent():removeChild(button)
            button:breakAnchors()
            button:setMarginTop(0)
            button:setSize(entry.size)
            button:setImageSource(entry.source)
            button:setIconSize(entry.iconSize)
            if panel then
                panel:insertChild(math.min(entry.index, panel:getChildCount() + 1), button)
            end
        end
    end
    taken = {}
    for id, size in pairs(barSizes) do
        local button = panel and panel:getChildById(id)
        if button then
            button:setFixedSize(false)
            button:setSize(size)
        end
    end
    barSizes = {}
    local store = panel and panel:getChildById('Store shop')
    if store and storeFixed ~= nil then
        store:setFixedSize(storeFixed)
    end
    storeFixed = nil
    if menu and barHeight then
        menu:setHeight(barHeight)
    end
    barHeight = nil
    if drawer then
        drawer:destroy()
        scrim:destroy()
        drawer, scrim = nil, nil
    end
end

-- the actions: a column over a button beside the moves bar. Tapping one arms it as before (tap it,
-- then what to use it on); the button shows the armed one, and tapping it again calls it off.

local layoutActions

local function hideActions()
    local panel = shortcuts()
    if panel then
        panel:hide()
    end
end

local function showActions()
    local panel = shortcuts()
    if not panel or not actionsButton then
        return
    end
    layoutActions(panel)
    local rect = actionsButton:getRect()
    panel:setPosition({
        x = rect.x + math.floor((rect.width - panel:getWidth()) / 2),
        y = rect.y - panel:getHeight() - 6,
    })
    panel:show()
    panel:raise()
end

-- a column over the button, or two by two when the screen is too short for one
layoutActions = function(panel)
    local columns = 1
    local room = actionsButton and (actionsButton:getY() - g_ui.getRootWidget():getY() - 50) or 0
    if room < #ACTIONS * (ACTION_SIZE + ACTION_SPACING) + ACTION_PADDING * 2 then
        columns = 2
    end
    local rows = math.ceil(#ACTIONS / columns)
    panel:breakAnchors()
    panel:setSize({
        width = columns * ACTION_SIZE + (columns - 1) * ACTION_SPACING + ACTION_PADDING * 2,
        height = rows * ACTION_SIZE + (rows - 1) * ACTION_SPACING + ACTION_PADDING * 2,
    })
    panel:setBackgroundColor('alpha')
    panel:setImageSource('/modules/game_pokegear/images/card')
    panel:setImageBorder(12)
    for i, id in ipairs(ACTIONS) do
        local action = panel.shortcutIcons:getChildById(id)
        if action then
            local row, column = math.floor((i - 1) / columns), (i - 1) % columns
            action:breakAnchors()
            action:addAnchor(AnchorTop, 'parent', AnchorTop)
            action:addAnchor(AnchorLeft, 'parent', AnchorLeft)
            action:setMarginTop(ACTION_PADDING + row * (ACTION_SIZE + ACTION_SPACING))
            action:setMarginLeft(ACTION_PADDING + column * (ACTION_SIZE + ACTION_SPACING))
            action:setMarginRight(0)
        end
    end
end

-- game_shortcuts' own corner layout (shortcuts.otui)
local CORNER = {
    attack = { AnchorLeft, 'parent', AnchorLeft, AnchorTop, 'parent', AnchorTop, 4 },
    look = { AnchorLeft, 'parent', AnchorLeft, AnchorTop, 'attack', AnchorBottom, 14 },
    follow = { AnchorRight, 'parent', AnchorRight, AnchorTop, 'parent', AnchorTop, 4 },
    use = { AnchorRight, 'parent', AnchorRight, AnchorTop, 'follow', AnchorBottom, 14 },
}

local function restoreActions(panel)
    panel:breakAnchors()
    panel:addAnchor(AnchorBottom, 'parent', AnchorBottom)
    panel:addAnchor(AnchorRight, 'parent', AnchorRight)
    panel:setSize({ width = 175, height = 150 })
    panel:setImageSource('')
    panel:setBackgroundColor('#00000044')
    for id, a in pairs(CORNER) do
        local action = panel.shortcutIcons:getChildById(id)
        if action then
            action:breakAnchors()
            action:addAnchor(a[1], a[2], a[3])
            action:addAnchor(a[4], a[5], a[6])
            action:setMarginTop(a[7])
            action:setMarginLeft(a[1] == AnchorLeft and 15 or 0)
            action:setMarginRight(a[1] == AnchorRight and 15 or 0)
        end
    end
end

local function enableActions()
    local panel = shortcuts()
    if not panel then
        return
    end
    layoutActions(panel)
    panel:hide()
    actionsButton = g_ui.createWidget('PokegearPhoneButton', modules.game_interface.getRootPanel())
    actionsButton:setId('pokegearActionsButton')
    actionsButton:setSize({ width = 40, height = 40 })
    actionsButton.icon:setSize({ width = 26, height = 26 })
    actionsButton.icon:setImageSource('/modules/game_pokegear/images/more')
    actionsButton:setTooltip(tr('Attack, Follow, Look, Use'))
    -- with the moves bar, under the windows (the open chat card) that cover it
    local root = actionsButton:getParent()
    local moves = root:getChildById('movesWindow')
    if moves then
        root:moveChildToIndex(actionsButton, root:getChildIndex(moves) + 1)
    end
    actionsButton:addAnchor(AnchorLeft, 'movesWindow', AnchorRight)
    actionsButton:addAnchor(AnchorVerticalCenter, 'movesWindow', AnchorVerticalCenter)
    actionsButton:setMarginLeft(6)
    actionsButton.onClick = function()
        if armed() ~= '' then
            modules.game_shortcuts.resetShortcuts()
            hideActions()
        elseif panel:isVisible() then
            hideActions()
        else
            showActions()
        end
    end
    lastArmed = nil
end

local function disableActions()
    if actionsButton then
        actionsButton:destroy()
        actionsButton = nil
    end
    local panel = shortcuts()
    if panel then
        restoreActions(panel)
        panel:setVisible(g_game.isOnline())
    end
end

local function tick()
    local now = armed()
    if now ~= lastArmed and actionsButton then
        lastArmed = now
        if now ~= '' then
            hideActions()
        end
        actionsButton:setOn(now ~= '')
        actionsButton.icon:setImageSource(now ~= '' and ('/images/game/mobile/' .. now)
            or '/modules/game_pokegear/images/more')
    end
    ticks = ticks + 1
    if ticks % SWEEP_TICKS == 0 then
        sweep()
    end
end

function Phone.apply(active)
    local want = active and g_platform.isMobile() and g_game.isOnline()
    if want == on then
        if on then
            sweep()
        end
        return
    end
    on = want
    removeEvent(tickEvent)
    tickEvent = nil
    if on then
        enableTopBar()
        enableActions()
        tickEvent = cycleEvent(tick, TICK_MS)
    else
        disableTopBar()
        disableActions()
    end
end

function Phone.terminate()
    Phone.apply(false)
end
