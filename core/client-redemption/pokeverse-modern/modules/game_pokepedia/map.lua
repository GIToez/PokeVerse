-- The Map tab: the world map centred on the player with floors, zoom and a way back to the player,
-- and a side column with Places (towns and guide marks), Waypoints and the Route. Left-click on the
-- map walks there; right-click adds waypoints and stops. Marks only show on their own floor.
MapTab = {}

local page, minimap
local sub = 'places'
local places
local waypoints = {} -- { name, icon, x, y, z }
local route = {} -- { name, x, y, z, reached }
local playerMark, focusMark
local waypointMarks, stopMarks, dots, shownMarks = {}, {}, {}, {}
local dialog
local placesEvent

local MAX_DOTS = 700
local FLAG_ICONS = { 'pin', 0, 3, 4, 5, 8, 9, 11, 12, 13 }

local function iconPath(icon)
    if icon == nil or icon == 'pin' then
        return Pp.IMAGES .. 'mark_waypoint'
    end
    return '/images/game/minimap/flag' .. tostring(icon)
end

local function toPosition(entry)
    return { x = tonumber(entry.x) or 0, y = tonumber(entry.y) or 0, z = tonumber(entry.z) or 7 }
end

local function camera()
    return minimap:getCameraPosition()
end

-- marks

local function placeMark(mark, pos)
    mark.pos = pos
    minimap:centerInPosition(mark, pos)
    mark:setVisible(pos.z == camera().z)
end

local function newMark(image, size, phantom)
    local mark = g_ui.createWidget('PpMapMark', minimap)
    mark:setImageSource(image)
    mark:setSize({ width = size or 16, height = size or 16 })
    mark:setPhantom(phantom == true)
    return mark
end

local function refreshVisibility()
    local z = camera().z
    for _, list in ipairs({ waypointMarks, stopMarks, dots, shownMarks }) do
        for _, mark in ipairs(list) do
            mark:setVisible(mark.pos.z == z)
        end
    end
    if focusMark and focusMark.pos then
        focusMark:setVisible(focusMark.pos.z == z)
    end
    local player = g_game.getLocalPlayer()
    if playerMark and player then
        playerMark:setVisible(player:getPosition().z == z)
    end
    page.mapFrame.controls.floor:setText(Pp.floorName(z))
    page.mapFrame.controls.floor:setTooltip(tr('Floor %d', z))
end

local function updatePlayerMark()
    local player = g_game.getLocalPlayer()
    if not playerMark or not player then
        return
    end
    local pos = player:getPosition()
    if pos and pos.x > 0 then
        placeMark(playerMark, pos)
    end
end

local function clearList(list)
    for _, widget in ipairs(list) do
        widget:destroy()
    end
    for i = #list, 1, -1 do
        list[i] = nil
    end
end

-- the route line: dots between the stops on the same floor, closer together when zoomed out
local function drawDots()
    clearList(dots)
    local scale = math.max(0.05, minimap:getScale())
    local spacing = math.max(2, math.floor(14 / scale + 0.5))
    local points = {}
    local player = g_game.getLocalPlayer()
    local state = Navigation.state()
    if player and not (Navigation.isActive() and state.mode ~= 'route') then
        points[#points + 1] = player:getPosition()
    end
    for _, stop in ipairs(route) do
        if not stop.reached or state.mode ~= 'route' then
            points[#points + 1] = toPosition(stop)
        end
    end
    for i = 2, #points do
        local a, b = points[i - 1], points[i]
        if a.z == b.z then
            local length = Pp.distance(a, b)
            for d = spacing, length - 1, spacing do
                if #dots >= MAX_DOTS then
                    return
                end
                local t = d / length
                local dot = g_ui.createWidget('PpRouteDot', minimap)
                placeMark(dot, { x = math.floor(a.x + (b.x - a.x) * t + 0.5), y = math.floor(a.y + (b.y - a.y) * t + 0.5), z = a.z })
                dots[#dots + 1] = dot
            end
        end
    end
end

-- waypoints

local function saveWaypoints()
    Pp.save('waypoints', waypoints)
end

local function saveRoute()
    Pp.save('route', route)
end

local drawWaypoints, drawRoute

local function openDialog(title, pos, name, icon, onSave)
    if dialog then
        dialog:destroy()
    end
    dialog = g_ui.createWidget('PpWaypointDialog', rootWidget)
    dialog.title:setText(title)
    dialog.position:setText(Pp.formatPosition(pos))
    dialog.name:setText(name or '')
    local chosen = icon or 'pin'
    local buttons = {}
    for _, choice in ipairs(FLAG_ICONS) do
        local widget = g_ui.createWidget('PpIconChoice', dialog.icons)
        widget:setIcon(iconPath(choice))
        local size = choice == 'pin' and 18 or 22
        local offset = math.floor((widget:getWidth() - size) / 2)
        widget:setIconRect({ x = offset, y = offset, width = size, height = size })
        widget:setChecked(tostring(choice) == tostring(chosen))
        widget.onClick = function()
            chosen = choice
            for _, other in ipairs(buttons) do
                other:setChecked(other == widget)
            end
        end
        buttons[#buttons + 1] = widget
    end
    local function close()
        if dialog then
            dialog:destroy()
            dialog = nil
        end
    end
    local function save()
        local text = dialog.name:getText():gsub('^%s+', ''):gsub('%s+$', '')
        if text == '' then
            text = tr('Waypoint')
        end
        onSave(text, chosen)
        close()
    end
    dialog.ok.onClick = save
    dialog.cancel.onClick = close
    dialog.onEnter = save
    dialog.onEscape = close
    dialog:raise()
    dialog:focus()
    dialog.name:focus()
end

local function addWaypoint(pos)
    openDialog(tr('New waypoint'), pos, '', 'pin', function(name, icon)
        waypoints[#waypoints + 1] = { name = name, icon = icon, x = pos.x, y = pos.y, z = pos.z }
        saveWaypoints()
        drawWaypoints()
        Pp.status(tr('Waypoint %s saved.', name), true)
    end)
end

local function editWaypoint(index)
    local waypoint = waypoints[index]
    if not waypoint then
        return
    end
    openDialog(tr('Edit waypoint'), toPosition(waypoint), tostring(waypoint.name), waypoint.icon, function(name, icon)
        waypoint.name, waypoint.icon = name, icon
        saveWaypoints()
        drawWaypoints()
    end)
end

local function deleteWaypoint(index)
    table.remove(waypoints, index)
    saveWaypoints()
    drawWaypoints()
end

function MapTab.addStop(pos, name)
    route[#route + 1] = { name = name or tr('Stop %d', #route + 1), x = pos.x, y = pos.y, z = pos.z, reached = false }
    saveRoute()
    drawRoute()
end

local function waypointMenu(index, mousePos)
    local waypoint = waypoints[index]
    local menu = g_ui.createWidget('PopupMenu')
    menu:setGameMenu(true)
    menu:addOption(tr('Walk here'), function() Navigation.goTo(toPosition(waypoint), tostring(waypoint.name)) end)
    menu:addOption(tr('Add to route'), function() MapTab.addStop(toPosition(waypoint), tostring(waypoint.name)) end)
    menu:addSeparator()
    menu:addOption(tr('Rename'), function() editWaypoint(index) end)
    menu:addOption(tr('Delete'), function() deleteWaypoint(index) end)
    menu:display(mousePos)
end

local function centerOn(pos)
    minimap:setCameraPosition(pos)
    refreshVisibility()
end

drawWaypoints = function()
    clearList(waypointMarks)
    local list = page.side.waypointsPanel.list
    list:destroyChildren()
    for index, waypoint in ipairs(waypoints) do
        local pos = toPosition(waypoint)
        local name = tostring(waypoint.name)
        local mark = newMark(iconPath(waypoint.icon), waypoint.icon == 'pin' and 16 or 11)
        mark:setTooltip(name)
        placeMark(mark, pos)
        mark.onMouseRelease = function(widget, mousePos, mouseButton)
            if mouseButton == MouseLeftButton then
                Navigation.goTo(pos, name)
            elseif mouseButton == MouseRightButton then
                waypointMenu(index, mousePos)
            end
            return true
        end
        waypointMarks[#waypointMarks + 1] = mark

        local row = g_ui.createWidget('PpPlaceRow', list)
        row.icon:setImageSource(iconPath(waypoint.icon))
        row.icon:setSize(waypoint.icon == 'pin' and { width = 14, height = 14 } or { width = 11, height = 11 })
        row.name:setText(name)
        row.town:setText(tr('Floor %s', Pp.floorName(pos.z)))
        row:setTooltip(tr('Click to show it, double-click to walk there, right-click for more.'))
        row.onClick = function() centerOn(pos) end
        row.onDoubleClick = function() Navigation.goTo(pos, name) end
        row.onMouseRelease = function(widget, mousePos, mouseButton)
            if mouseButton == MouseRightButton then
                waypointMenu(index, mousePos)
                return true
            end
            return false
        end
    end
    if #waypoints == 0 then
        local hint = g_ui.createWidget('TkMuted', list)
        hint:setText(tr('No waypoints yet.'))
        hint:setMarginLeft(6)
        hint:setMarginTop(6)
    end
    refreshVisibility()
end

-- route

local function resetRoute()
    for _, stop in ipairs(route) do
        stop.reached = false
    end
end

local function startRoute()
    if #route == 0 then
        Pp.status(tr('Add stops first: right-click the map, or use Add to route on a place.'), false)
        return
    end
    local open = false
    for _, stop in ipairs(route) do
        open = open or not stop.reached
    end
    if not open then
        resetRoute()
    end
    for _, stop in ipairs(route) do
        stop.x, stop.y, stop.z = tonumber(stop.x), tonumber(stop.y), tonumber(stop.z)
        stop.name = tostring(stop.name)
        stop.reached = stop.reached == true
    end
    Navigation.start(route, 'route')
end

drawRoute = function()
    local panel = page.side.routePanel
    clearList(stopMarks)
    panel.list:destroyChildren()
    local player = g_game.getLocalPlayer()
    local previous = player and player:getPosition()
    local reached = 0
    local state = Navigation.state()
    for index, stop in ipairs(route) do
        local pos = toPosition(stop)
        local name = tostring(stop.name)
        if stop.reached then
            reached = reached + 1
        end
        local mark = newMark(Pp.IMAGES .. (stop.reached and 'mark_reached' or 'mark_stop'), 16)
        mark:setTooltip(string.format('%d. %s', index, name))
        placeMark(mark, pos)
        mark.onMouseRelease = function(widget, mousePos, mouseButton)
            if mouseButton == MouseRightButton then
                local menu = g_ui.createWidget('PopupMenu')
                menu:setGameMenu(true)
                menu:addOption(tr('Remove stop'), function()
                    table.remove(route, index)
                    saveRoute()
                    drawRoute()
                end)
                menu:display(mousePos)
            end
            return true
        end
        stopMarks[#stopMarks + 1] = mark

        local row = g_ui.createWidget('PpStopRow', panel.list)
        row.icon:setImageSource(Pp.IMAGES .. (stop.reached and 'mark_reached' or 'mark_stop'))
        row.name:setText(string.format('%d. %s', index, name))
        row.name:setColor(stop.reached and '#8fe08f' or (state.mode == 'route' and state.index == index and '#ffd75a' or '#dce6ff'))
        if previous and previous.z == pos.z then
            row.distance:setText(tr('%d tiles', Pp.distance(previous, pos)))
        else
            row.distance:setText(previous and tr('floor %s', Pp.floorName(pos.z)) or '')
        end
        row:setTooltip(Pp.formatPosition(pos))
        previous = pos
        row.onClick = function() centerOn(pos) end
        row.up:setEnabled(index > 1)
        row.up.onClick = function()
            route[index], route[index - 1] = route[index - 1], route[index]
            saveRoute()
            drawRoute()
        end
        row.down:setEnabled(index < #route)
        row.down.onClick = function()
            route[index], route[index + 1] = route[index + 1], route[index]
            saveRoute()
            drawRoute()
        end
        row.remove.onClick = function()
            table.remove(route, index)
            saveRoute()
            drawRoute()
        end
    end
    if #route == 0 then
        local hint = g_ui.createWidget('TkMuted', panel.list)
        hint:setText(tr('No stops yet.'))
        hint:setMarginLeft(6)
        hint:setMarginTop(6)
    end
    Pp.setTrack(panel.track, reached, math.max(1, #route), reached == #route and #route > 0 and 'fill_green' or 'fill_blue')
    panel.count:setText(string.format('%d / %d', reached, #route))
    local active = Navigation.isActive('route')
    panel.status:setText(active and (Navigation.describe() or '') or
        (#route == 1 and tr('1 stop. Press Start to walk there.') or
        #route > 1 and tr('%d stops. Press Start to walk them in order.', #route) or tr('Plan a route')))
    panel.buttons.start:setText(active and tr('Stop') or tr('Start'))
    panel.buttons.pause:setEnabled(active)
    panel.buttons.pause:setText((active and state.paused) and tr('Resume') or tr('Pause'))
    drawDots()
    refreshVisibility()
end

function MapTab.onStopReached(index, stop)
    saveRoute()
    drawRoute()
end

-- places

local function getPlaces()
    if places then
        return places
    end
    local map = modules.game_minimap and modules.game_minimap.PokeverseMap
    places = map and map.getPlaces and map.getPlaces() or {}
    table.sort(places, function(a, b)
        if (a.type == nil) ~= (b.type == nil) then
            return a.type == nil
        end
        if a.town ~= b.town then
            return a.town < b.town
        end
        return a.name < b.name
    end)
    return places
end

local selectedPlace

local function drawPlaces()
    local panel = page.side.placesPanel
    local filter = panel.search:getText():lower()
    panel.list:destroyChildren()
    local shown = 0
    for _, place in ipairs(getPlaces()) do
        if filter == '' or place.name:lower():find(filter, 1, true) or place.town:lower():find(filter, 1, true) then
            local row = g_ui.createWidget('PpPlaceRow', panel.list)
            row.icon:setImageSource(place.type and iconPath(place.type) or '/modules/client_entergame/images/town')
            row.icon:setSize(place.type and { width = 11, height = 11 } or { width = 12, height = 12 })
            row.name:setText(place.name)
            row.town:setText(place.type and place.town or tr('Town'))
            row:setTooltip(Pp.formatPosition(place.position))
            row.place = place
            row.onDoubleClick = function() Navigation.goTo(place.position, place.name) end
            shown = shown + 1
        end
    end
    if shown == 0 then
        local hint = g_ui.createWidget('TkMuted', panel.list)
        hint:setText(tr('Nothing matches.'))
        hint:setMarginLeft(6)
        hint:setMarginTop(6)
    end
end

local function setFocus(pos, text)
    if not focusMark then
        focusMark = newMark(Pp.IMAGES .. 'mark_spawn', 16, true)
    end
    focusMark:setTooltip(text or '')
    placeMark(focusMark, pos)
end

-- the tabs and the other pages

local function showSub(name)
    sub = name
    for _, id in ipairs({ 'places', 'waypoints', 'route' }) do
        page.side[id .. 'Tab']:setChecked(id == name)
        page.side[id .. 'Panel']:setVisible(id == name)
    end
    if name == 'route' then
        drawRoute()
    end
end

function MapTab.showPosition(pos, text)
    show('map')
    setFocus(pos, text)
    centerOn(pos)
end

-- marks for a list of spots (a Pokemon's spawn areas), centred on the nearest one
function MapTab.showPositions(list, text)
    show('map')
    clearList(shownMarks)
    local player = g_game.getLocalPlayer()
    local here = player and player:getPosition()
    local best, bestDistance
    for _, entry in ipairs(list) do
        local pos = toPosition(entry)
        local mark = newMark(Pp.IMAGES .. 'mark_spawn', 16)
        mark:setTooltip(entry.text or text or '')
        placeMark(mark, pos)
        mark.onMouseRelease = function(widget, mousePos, mouseButton)
            if mouseButton == MouseLeftButton then
                Navigation.goTo(pos, entry.text or text)
            end
            return true
        end
        shownMarks[#shownMarks + 1] = mark
        local distance = here and (Pp.distance(here, pos) + (here.z == pos.z and 0 or 100000)) or 0
        if not bestDistance or distance < bestDistance then
            best, bestDistance = pos, distance
        end
    end
    if best then
        centerOn(best)
    end
end

function MapTab.routeTo(pos, name)
    MapTab.addStop(pos, name)
    show('map')
    showSub('route')
    centerOn(pos)
    Pp.status(tr('%s was added to your route. Press Start to go.', name), true)
end

-- the map widget

local function mapMenu(pos, mousePos)
    local menu = g_ui.createWidget('PopupMenu')
    menu:setGameMenu(true)
    menu:addOption(tr('Walk here'), function() Navigation.goTo(pos) end)
    menu:addOption(tr('Add a waypoint here'), function() addWaypoint(pos) end)
    menu:addOption(tr('Add a route stop here'), function()
        MapTab.addStop(pos)
        showSub('route')
    end)
    menu:addSeparator()
    menu:addOption(tr('Copy position'), function()
        g_window.setClipboardText(Pp.formatPosition(pos))
        Pp.status(tr('Position copied: %s', Pp.formatPosition(pos)), true)
    end)
    menu:display(mousePos)
end

local function setupMinimap()
    minimap = page.mapFrame.minimap
    minimap:setZoom(1)
    playerMark = newMark('/images/game/minimap/cross', 16, true)

    minimap.onMousePress = function(widget, mousePos, mouseButton)
        widget.dragged = false
        return false
    end
    minimap.onDragEnter = function(widget, mousePos)
        widget.dragged = true
        return UIMinimap.onDragEnter(widget, mousePos)
    end
    minimap.onMouseRelease = function(widget, mousePos, mouseButton)
        if widget.dragged then
            widget.dragged = false
            return true
        end
        local pos = widget:getTilePosition(mousePos)
        if not pos or pos.x <= 0 then
            return false
        end
        if mouseButton == MouseLeftButton then
            Navigation.goTo(pos)
            return true
        elseif mouseButton == MouseRightButton then
            mapMenu(pos, mousePos)
            return true
        end
        return false
    end
    minimap.onMouseMove = function(widget, mousePos)
        local pos = widget:getTilePosition(mousePos)
        if pos and pos.x > 0 and pos.x < 65535 then
            page.mapFrame.coords:setText(Pp.formatPosition(pos))
        end
        return false
    end
    minimap.onHoverChange = function(widget, hovered)
        if not hovered then
            local player = g_game.getLocalPlayer()
            page.mapFrame.coords:setText(player and Pp.formatPosition(player:getPosition()) or '')
        end
    end
    minimap.onCameraPositionChange = function(widget, pos)
        refreshVisibility()
    end
    local zoomEvent
    minimap.onZoomChange = function(widget, zoom)
        removeEvent(zoomEvent)
        zoomEvent = scheduleEvent(drawDots, 50)
    end

    local controls = page.mapFrame.controls
    controls.center.onClick = function()
        minimap:reset()
        updatePlayerMark()
        refreshVisibility()
    end
    controls.floorUp.onClick = function() minimap:floorUp(1); refreshVisibility() end
    controls.floorDown.onClick = function() minimap:floorDown(1); refreshVisibility() end
    controls.zoomIn.onClick = function() minimap:zoomIn() end
    controls.zoomOut.onClick = function() minimap:zoomOut() end
    page.mapFrame.pokedexButton.onClick = function() Pp.send({ action = 'pokedex' }) end
    page.mapFrame.pokedexButton:setTooltip(tr('Open your Pokedex'))
end

local function onPositionChange(player, newPos, oldPos)
    if not page or not page:isVisible() then
        return
    end
    local followed = oldPos and camera().x == oldPos.x and camera().y == oldPos.y and camera().z == oldPos.z
    updatePlayerMark()
    if followed and not minimap:isDragging() then
        minimap:setCameraPosition(newPos)
    end
    if not minimap:isHovered() then
        page.mapFrame.coords:setText(Pp.formatPosition(newPos))
    end
    if #route > 0 and not (Navigation.isActive() and not Navigation.isActive('route')) then
        drawDots()
    end
    refreshVisibility()
end

function MapTab.setup(widget)
    page = widget
    setupMinimap()
    local side = page.side
    for _, id in ipairs({ 'places', 'waypoints', 'route' }) do
        side[id .. 'Tab'].onClick = function() showSub(id) end
    end
    side.waypointsTab:setIcon(Pp.IMAGES .. 'mark_waypoint')
    side.waypointsTab:setIconSize({ width = 14, height = 14 })
    side.waypointsTab:setIconOffsetX(8)
    side.placesTab:setIcon(Pp.IMAGES .. 'icon_map')
    side.placesTab:setIconSize({ width = 14, height = 14 })
    side.placesTab:setIconOffsetX(8)

    local placesPanel = side.placesPanel
    placesPanel.search.onTextChange = function()
        removeEvent(placesEvent)
        placesEvent = scheduleEvent(drawPlaces, 150)
    end
    placesPanel.list.onChildFocusChange = function(list, focused)
        if focused and focused.place then
            selectedPlace = focused.place
            setFocus(focused.place.position, focused.place.name)
            centerOn(focused.place.position)
        end
    end
    local buttons = placesPanel.buttons
    buttons.walk.onClick = function()
        if selectedPlace then
            Navigation.goTo(selectedPlace.position, selectedPlace.name)
        else
            Pp.status(tr('Pick a place first.'), false)
        end
    end
    buttons.stop.onClick = function()
        if selectedPlace then
            MapTab.addStop(selectedPlace.position, selectedPlace.name)
            Pp.status(tr('%s was added to your route.', selectedPlace.name), true)
        else
            Pp.status(tr('Pick a place first.'), false)
        end
    end
    buttons.save.onClick = function()
        if not selectedPlace then
            Pp.status(tr('Pick a place first.'), false)
            return
        end
        local place = selectedPlace
        waypoints[#waypoints + 1] = { name = place.name, icon = place.type or 'pin', x = place.position.x,
            y = place.position.y, z = place.position.z }
        saveWaypoints()
        drawWaypoints()
        Pp.status(tr('Waypoint %s saved.', place.name), true)
    end
    buttons.save:setTooltip(tr('Save the place as a waypoint'))

    local routeButtons = side.routePanel.buttons
    routeButtons.start.onClick = function()
        if Navigation.isActive('route') then
            Navigation.stop(tr('The route stopped.'))
        else
            startRoute()
        end
    end
    routeButtons.pause.onClick = function()
        if Navigation.state().paused then
            Navigation.resume()
        else
            Navigation.pause('manual')
        end
    end
    routeButtons.clear.onClick = function()
        if Navigation.isActive('route') then
            Navigation.stop()
        end
        route = {}
        saveRoute()
        drawRoute()
    end
    Navigation.listen(function()
        if page and page:isVisible() then
            drawRoute()
        end
    end)
    connect(LocalPlayer, { onPositionChange = onPositionChange })
    showSub('places')
end

function MapTab.onShow()
    if not g_game.isOnline() then
        return
    end
    if page.side.placesPanel.list:getChildCount() == 0 then
        drawPlaces()
    end
    minimap:reset()
    updatePlayerMark()
    drawWaypoints()
    drawRoute()
    local player = g_game.getLocalPlayer()
    page.mapFrame.coords:setText(player and Pp.formatPosition(player:getPosition()) or '')
end

function MapTab.onGameStart()
    waypoints = Pp.list(Pp.load('waypoints'))
    route = Pp.list(Pp.load('route'))
    for _, stop in ipairs(route) do
        stop.reached = stop.reached == true
    end
end

function MapTab.onGameEnd()
    clearList(shownMarks)
    if focusMark then
        focusMark:destroy()
        focusMark = nil
    end
    if dialog then
        dialog:destroy()
        dialog = nil
    end
end

function MapTab.getRoute()
    return route
end

function MapTab.startRoute()
    startRoute()
end

function MapTab.terminate()
    disconnect(LocalPlayer, { onPositionChange = onPositionChange })
    removeEvent(placesEvent)
    if dialog then
        dialog:destroy()
        dialog = nil
    end
end

Pp.registerPage('map', MapTab)
