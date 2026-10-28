-- The Pokegear ring (docs/concepts/side-panel): the game's minimap, made round, with the app orbs
-- on its left, zoom and floor buttons on its right, the time of day on its rim and the place under
-- it. The minimap widget itself is game_minimap's, moved in here while Pokegear is on.
local HUB_CENTER = { x = 205, y = 182 }
local MAP_RADIUS = 128
local ORB_RADIUS = 168
local BUTTON_RADIUS = 142
local SUN_RADIUS = 139
local RIBBON_TOP = 352
local POSITION_SETTING = 'pokegearHubPosition'

-- the orbs, top to bottom down the left of the ring; each one presses a top bar button, so it
-- opens the same window and keeps the same key
local ORBS = {
    { id = 'friends', button = 'vipListButton', tooltip = 'Social', open = 'social', key = { 'Windows', 'Show/hide VIP list' } },
    { id = 'trainer', button = 'trainerCardButton', tooltip = 'Trainer card' },
    { id = 'quests', button = 'questLogButton', tooltip = 'Quests', key = { 'Windows', 'Show/hide the Quest Log' } },
    { id = 'pokepedia', button = 'pokepediaButton', tooltip = 'Pokepedia', key = { 'Minimap', 'Open full map' } },
    { id = 'bag', image = '/modules/game_pokegear/images/button_bag', tooltip = 'Bag', open = 'bag', key = { 'Windows', 'Show/hide the Bag' } },
}
local ORB_FIRST_ANGLE, ORB_STEP = 237, -28
local BUTTONS = {
    { id = 'zoomIn', text = '+', angle = -38, tooltip = 'Zoom in' },
    { id = 'zoomOut', text = '-', angle = -14, tooltip = 'Zoom out' },
    { id = 'floorUp', text = '^', angle = 14, tooltip = 'Floor up' },
    { id = 'floorDown', text = 'v', angle = 38, tooltip = 'Floor down' },
}

local hub, minimap, orbs, buttons = nil, nil, {}, {}
local refreshEvent, restorePosition

local function at(angle, radius, size)
    local r = math.rad(angle)
    return HUB_CENTER.x + radius * math.cos(r) - size / 2, HUB_CENTER.y + radius * math.sin(r) - size / 2
end

local function place(widget, x, y)
    widget:addAnchor(AnchorLeft, 'parent', AnchorLeft)
    widget:addAnchor(AnchorTop, 'parent', AnchorTop)
    widget:setMarginLeft(math.floor(x + 0.5))
    widget:setMarginTop(math.floor(y + 0.5))
end

local function floorName(z)
    if z == 7 then
        return tr('Ground')
    elseif z < 7 then
        return (8 - z) .. 'F'
    end
    return 'B' .. (z - 7)
end

local function refreshOrbs()
    for _, def in ipairs(ORBS) do
        local orb = orbs[def.id]
        local button = def.button and Pokegear.topButton(def.button)
        if def.image then
            orb.icon:setImageSource(def.image)
            orb.icon:setImageClip({ x = 0, y = 0, width = 20, height = 20 })
        elseif button then
            orb.icon:setImageSource(button:getImageSource())
            orb.icon:setImageClip(button:getImageClip())
        end
        local key = Pokegear.boundKey(def.key)
        orb.chip:setText(key)
        orb.chip:setVisible(key ~= '')
        if def.open == 'bag' then
            orb:setOn(Bag.isOpen())
        elseif def.open == 'social' then
            orb:setOn(Social.isOpen())
        else
            orb:setOn(button ~= nil and button.isOn ~= nil and button:isOn())
        end
    end
end

local function refreshFloor()
    -- no camera yet while logging in with Pokegear already on
    local position = minimap and minimap:getCameraPosition()
    if position then
        hub.floorLabel:setText(floorName(position.z))
    end
end

-- the sun (or the moon at night) runs round the rim: midnight at the bottom, noon at the top
local function refreshTime()
    local clock = modules.game_minimap.getDayTime and modules.game_minimap.getDayTime()
    local hour, minute = 12, 0
    if clock then
        hour, minute = clock.h, clock.m
    end
    local angle = 90 + (hour * 60 + minute) / (24 * 60) * 360
    local x, y = at(angle, SUN_RADIUS, hub.sun:getWidth())
    hub.sun:setMarginLeft(math.floor(x + 0.5))
    hub.sun:setMarginTop(math.floor(y + 0.5))
    local day = hour >= 6 and hour < 18
    hub.sun:setImageSource('/modules/game_pokegear/images/' .. (day and 'sun' or 'moon'))
    return hour, minute, day
end

local function refreshRibbon()
    local hour, minute, day = refreshTime()
    local placeName = modules.game_time and modules.game_time.getLocation and modules.game_time.getLocation() or ''
    local region = ''
    local player = g_game.getLocalPlayer()
    local map = modules.game_minimap and modules.game_minimap.PokeverseMap
    local position = player and player:getPosition()
    if position and map and map.regionAt then
        region = map.regionAt(position) or ''
        region = region:gsub('^%l', string.upper)
    end
    if placeName == '' then
        placeName = region
    end
    hub.ribbon.place:setText(placeName)
    local suffix = hour >= 12 and 'PM' or 'AM'
    local h12 = hour % 12 == 0 and 12 or hour % 12
    local parts = {}
    if region ~= '' and region ~= placeName then
        parts[#parts + 1] = region
    end
    parts[#parts + 1] = string.format('%d:%02d %s', h12, minute, suffix)
    parts[#parts + 1] = day and tr('Day') or tr('Night')
    hub.ribbon.detail:setText(table.concat(parts, ' - '))
end

local function refresh()
    if not hub or not hub:isVisible() then
        return
    end
    refreshOrbs()
    refreshFloor()
    refreshRibbon()
    Pokegear.fitColumn()
end

local function build()
    hub = g_ui.createWidget('PokegearHub', modules.game_interface.getRootPanel())
    hub:hide()

    place(hub.ring, HUB_CENTER.x - 160, HUB_CENTER.y - 160)
    place(hub.mapSlot, HUB_CENTER.x - MAP_RADIUS, HUB_CENTER.y - MAP_RADIUS)
    hub.sun:addAnchor(AnchorLeft, 'parent', AnchorLeft)
    hub.sun:addAnchor(AnchorTop, 'parent', AnchorTop)
    place(hub.north, HUB_CENTER.x - 5, HUB_CENTER.y - 178)
    place(hub.grip, HUB_CENTER.x - 18, HUB_CENTER.y + 150)
    place(hub.ribbon, HUB_CENTER.x - 130, RIBBON_TOP)
    local fx, fy = at(26, MAP_RADIUS - 30, 0)
    place(hub.floorLabel, fx - 24, fy - 9)

    for i, def in ipairs(ORBS) do
        local orb = g_ui.createWidget('PokegearOrb', hub)
        orb:setId(def.id .. 'Orb')
        orb:setTooltip(tr(def.tooltip))
        place(orb, at(ORB_FIRST_ANGLE + (i - 1) * ORB_STEP, ORB_RADIUS, 70))
        orb.onClick = function()
            if def.open == 'bag' then
                Bag.toggle()
            elseif def.open == 'social' then
                Social.toggle()
            else
                Pokegear.pressTopButton(def.button)
            end
            scheduleEvent(refreshOrbs, 50)
        end
        orbs[def.id] = orb
    end

    for _, def in ipairs(BUTTONS) do
        local button = g_ui.createWidget('PokegearButton', hub)
        button:setId(def.id .. 'Button')
        button:setText(def.text)
        button:setTooltip(tr(def.tooltip))
        place(button, at(def.angle, BUTTON_RADIUS, 42))
        buttons[def.id] = button
    end
    buttons.zoomIn.onClick = function() if minimap then minimap:zoomIn() end end
    buttons.zoomOut.onClick = function() if minimap then minimap:zoomOut() end end
    buttons.floorUp.onClick = function() modules.game_minimap.upLayer() refreshFloor() end
    buttons.floorDown.onClick = function() modules.game_minimap.downLayer() refreshFloor() end

    restorePosition = Pokegear.makeMovable(hub, hub.grip, POSITION_SETTING, function()
        hub:addAnchor(AnchorTop, 'gameMapPanel', AnchorTop)
        hub:addAnchor(AnchorRight, 'parent', AnchorRight)
        hub:setMarginTop(0)
        hub:setMarginRight(0)
    end)
end

local function onCameraPositionChange()
    refreshFloor()
end

local function show()
    if not hub then
        build()
    end
    if minimap then
        refresh()
        return
    end
    minimap = modules.game_minimap.getMiniMapUi()
    modules.game_minimap.setHome(hub.mapSlot)
    minimap:setCircular(true)
    connect(minimap, { onCameraPositionChange = onCameraPositionChange })
    restorePosition()
    hub:show()
    hub:raise()
    refresh()
    if not refreshEvent then
        refreshEvent = cycleEvent(refresh, 1000)
    end
end

local function hide()
    if refreshEvent then
        removeEvent(refreshEvent)
        refreshEvent = nil
    end
    if minimap then
        disconnect(minimap, { onCameraPositionChange = onCameraPositionChange })
        minimap:setCircular(false)
        modules.game_minimap.setHome(nil)
        minimap = nil
    end
    if hub then
        hub:hide()
    end
end

Hub = {}

function Hub.apply(active)
    if active and g_game.isOnline() then
        show()
    else
        hide()
    end
end

function Hub.docked()
    return Pokegear.isDocked(hub, POSITION_SETTING) and hub or nil
end

-- the ribbon under the map grows by extra pixels for a widget of another window (the folded Tracking
-- chip); the ring grows with it, so what hangs under it moves down
local RIBBON_HEIGHT, HUB_HEIGHT = 46, 400

function Hub.ribbon()
    return hub and hub.ribbon
end

function Hub.extendRibbon(extra)
    if not hub then
        return
    end
    hub.ribbon:setHeight(RIBBON_HEIGHT + extra)
    hub:setHeight(HUB_HEIGHT + extra)
    Pokegear.fitColumn()
end

function Hub.terminate()
    hide()
    if hub then
        hub:destroy()
        hub = nil
    end
    orbs, buttons = {}, {}
end
