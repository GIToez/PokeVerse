-- The Map tab: the world map centred on the player with floors, zoom and a way back to the player,
-- and a side column with Places (towns and guide marks), Waypoints and the Route. Left-click on the
-- map walks there; right-click adds waypoints and stops. Marks only show on their own floor.
-- The map is the real one, drawn from the game's sprites (the minimap's satellite mode, with the
-- chunks from scripts/mapper/render_pokepedia.py), with a button to switch to the minimap.
MapTab = {}

local page, minimap
local sub = 'places'
local places
local waypoints = {} -- { name, icon, x, y, z }
local route = {} -- { name, x, y, z, reached }
local playerMark
local pointer, pointerEvent
local showPointer
local waypointMarks, stopMarks, dots, shownMarks = {}, {}, {}, {}
local dialog
local placesEvent

local MAX_DOTS = 700
local WORLD = '/images/pokepedia/world'
local REAL_MAP_SETTING = 'pokepedia-real-map'
-- how much of the ground shows under the floors above it
local GROUND_OPACITY = 0.4
local hasWorld
local FLAG_ICONS = { 'pin', 0, 3, 4, 5, 8, 9, 11, 12, 13 }

-- an icon is 'pin', a minimap flag number, or the path of a guide mark's icon
local function iconPath(icon)
    if icon == nil or icon == 'pin' then
        return Pp.IMAGES .. 'mark_waypoint'
    end
    if type(icon) == 'string' and icon:sub(1, 1) == '/' then
        return icon
    end
    return '/images/game/minimap/flag' .. tostring(icon)
end

local function iconSize(icon, pin)
    if icon == nil or icon == 'pin' then
        return pin
    end
    return (type(icon) == 'string' and icon:sub(1, 1) == '/') and 14 or 11
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

-- the map's names (game_minimap's map_labels.lua): the regions zoomed out, then the cities, the
-- routes and the landmarks as the map zooms in; only on the ground floor, where they are
local LABELS_SETTING = 'pokepedia-map-labels'
local LABEL_STYLES = { region = 'PpMapRegionLabel', city = 'PpMapLabel', route = 'PpMapRouteLabel',
    landmark = 'PpMapLandmarkLabel' }
-- the zoom each kind shows from; the regions show below the cities' zoom
local LABEL_ZOOMS = { city = -1, route = 0, landmark = 1 }
local SURFACE = 7
local labelWidgets = {}

local function mapData()
    local map = modules.game_minimap and modules.game_minimap.PokeverseMap
    return map and map.getLabels and map or nil
end

local function labelsOn()
    return g_settings.getBoolean(LABELS_SETTING, true)
end

local function refreshLabels()
    local cam = camera()
    local shown = labelsOn() and cam ~= nil and cam.z == SURFACE
    local zoom = minimap:getZoom()
    for _, label in ipairs(labelWidgets) do
        if label.kind == 'region' then
            label:setVisible(shown and zoom < LABEL_ZOOMS.city)
        else
            label:setVisible(shown and zoom >= LABEL_ZOOMS[label.kind])
        end
    end
    local button = page.mapFrame.controls.labels
    button:setColor(labelsOn() and '#ffd75a' or '#6f7f99')
    button:setTooltip(labelsOn() and tr('Hide the names of places') or tr('Show the names of places'))
end

local function drawLabels()
    for _, label in ipairs(labelWidgets) do
        label:destroy()
    end
    labelWidgets = {}
    local map = mapData()
    if not map then
        return
    end
    local function add(kind, text, pos)
        local label = g_ui.createWidget(LABEL_STYLES[kind])
        minimap:insertChild(1, label)
        label:setText(text)
        label.kind = kind
        label.pos = pos
        minimap:centerInPosition(label, pos)
        labelWidgets[#labelWidgets + 1] = label
    end
    for _, region in ipairs(map.getRegions()) do
        if region.position then
            add('region', tr(region.name), region.position)
        end
    end
    for _, label in ipairs(map.getLabels()) do
        add(label.kind, tr(label.name), label.position)
    end
    refreshLabels()
end

local function refreshVisibility()
    local z = camera().z
    for _, list in ipairs({ waypointMarks, stopMarks, dots, shownMarks }) do
        for _, mark in ipairs(list) do
            mark:setVisible(mark.pos.z == z)
        end
    end
    if pointer and pointer.pos then
        pointer:setVisible(pointer.pos.z == z)
    end
    local player = g_game.getLocalPlayer()
    if playerMark and player then
        playerMark:setVisible(player:getPosition().z == z)
    end
    page.mapFrame.controls.floor:setText(Pp.floorName(z))
    page.mapFrame.controls.floor:setTooltip(tr('Floor %d', z))
    refreshLabels()
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
        local mark = newMark(iconPath(waypoint.icon), iconSize(waypoint.icon, 16))
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
        local size = iconSize(waypoint.icon, 14)
        row.icon:setSize({ width = size, height = size })
        row.name:setText(name)
        row.town:setText(tr('Floor %s', Pp.floorName(pos.z)))
        row:setTooltip(tr('Click to show it, double-click to walk there, right-click for more.'))
        row.onClick = function()
            showPointer(pos, name)
            centerOn(pos)
        end
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
        row.onClick = function()
            showPointer(pos, name)
            centerOn(pos)
        end
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
    local map = mapData()
    places = map and map.getPlaces() or {}
    return places
end

local selectedPlace, selectPlace
local expandedTowns = {}
-- region id: open; the player's region starts open
local expandedRegions

-- the guide marks only carry a name, so the kind comes from the words in it (first match wins)
local KINDS = {
    { id = 'center', name = 'Pokemon Centers', words = { 'pokemon center' } },
    { id = 'travel', name = 'Travel', words = { 'travel', 's. s.', 'ship', 'fly', 'train', 'balloon' } },
    { id = 'shop', name = 'Shops and banks', words = { 'mart', 'bank', 'shop', 'store' } },
    { id = 'gym', name = 'Gyms', words = { 'gym' } },
    { id = 'club', name = 'Guilds and clubs', words = { 'guild', 'ranger', 'club' } },
    { id = 'route', name = 'Routes' },
    { id = 'landmark', name = 'Landmarks' },
    { id = 'other', name = 'Other places' },
}

-- towns, routes and landmarks carry their kind; a guide mark's comes from its name
local function placeKind(place)
    if not place.type then
        return place.kind or 'town'
    end
    if not place.kind then
        local name = place.name:lower()
        place.kind = 'other'
        for _, kind in ipairs(KINDS) do
            for _, word in ipairs(kind.words or {}) do
                if name:find(word, 1, true) then
                    place.kind = kind.id
                    break
                end
            end
            if place.kind ~= 'other' then
                break
            end
        end
    end
    return place.kind
end

local function groupIcon(kind)
    if kind == 'route' then
        return Pp.IMAGES .. 'icon_route'
    elseif kind == 'landmark' then
        return Pp.IMAGES .. 'icon_map'
    end
    return '/modules/client_entergame/images/town'
end

-- zooms in to at least zoom, never out
local function zoomTo(zoom)
    if minimap:getZoom() < zoom then
        minimap:setZoom(zoom)
    end
end

local function addPlaceRow(list, place)
    local row = g_ui.createWidget('PpPlaceRow', list)
    local kind = placeKind(place)
    row.icon:setImageSource(place.type and iconPath(place.icon or place.type) or groupIcon(kind))
    local size = place.type and iconSize(place.icon or place.type) or 12
    row.icon:setSize({ width = size, height = size })
    row.name:setText(kind == 'town' and tr('Town centre') or place.name)
    row.town:setText('')
    row:setTooltip(tr('%s. Click to show it, double-click to walk there.', Pp.formatPosition(place.position)))
    row.place = place
    row.onClick = function() selectPlace(place) end
    row.onDoubleClick = function() Navigation.goTo(place.position, place.name) end
    return row
end

-- the order inside a region: its towns by name, then the routes, then the landmarks
local GROUP_ORDER = { town = 0, route = 1, landmark = 2 }

local function routeNumber(place)
    return tonumber(place.name:match('(%d+)$')) or 0
end

-- game_minimap may load after the Pokepedia, so the regions are filled in once it has
local function fillRegions()
    local combo = page.side.placesPanel.region
    local map = mapData()
    if combo.filled or not map then
        return
    end
    combo.filled = true
    combo:addOption(tr('All regions'), '')
    for _, region in ipairs(map.getRegions()) do
        combo:addOption(tr(region.name), region.id)
    end
end

local function drawPlaces()
    local panel = page.side.placesPanel
    fillRegions()
    local filter = panel.search:getText():lower()
    local kind = (panel.kind:getCurrentOption() or {}).data or ''
    local regionFilter = (panel.region:getCurrentOption() or {}).data or ''
    local openAll = filter ~= '' or kind ~= ''
    local map = mapData()
    if not expandedRegions then
        expandedRegions = {}
        local player = g_game.getLocalPlayer()
        if map and player then
            expandedRegions[map.regionAt(player:getPosition())] = true
        end
    end

    local byRegion, count = {}, 0
    for _, place in ipairs(getPlaces()) do
        local wanted = (kind == '' or placeKind(place) == kind) and (regionFilter == '' or place.region == regionFilter)
        if wanted and (filter == '' or place.name:lower():find(filter, 1, true) or place.town:lower():find(filter, 1, true)) then
            local region = byRegion[place.region]
            if not region then
                region = { groups = {}, byTown = {}, count = 0 }
                byRegion[place.region] = region
            end
            local group = region.byTown[place.town]
            if not group then
                local groupKind = place.type and 'town' or placeKind(place)
                group = { key = place.region .. '/' .. place.town, name = place.town, kind = groupKind,
                    icon = groupIcon(groupKind), entries = {} }
                region.byTown[place.town] = group
                region.groups[#region.groups + 1] = group
            end
            group.entries[#group.entries + 1] = place
            region.count = region.count + 1
            count = count + 1
        end
    end

    local list = panel.list
    list:destroyChildren()
    local focus
    for _, info in ipairs(map and map.getRegions() or {}) do
        local region = byRegion[info.id]
        if region then
            table.sort(region.groups, function(a, b)
                if a.kind ~= b.kind then
                    return (GROUP_ORDER[a.kind] or 0) < (GROUP_ORDER[b.kind] or 0)
                end
                return a.name < b.name
            end)
            for _, group in ipairs(region.groups) do
                -- the town itself first, then its places by name; routes by number
                table.sort(group.entries, function(a, b)
                    local aTown, bTown = placeKind(a) == 'town', placeKind(b) == 'town'
                    if aTown ~= bTown then
                        return aTown
                    end
                    if group.kind == 'route' then
                        return routeNumber(a) < routeNumber(b)
                    end
                    return a.name < b.name
                end)
                group.note = tostring(#group.entries)
                if group.kind == 'town' then
                    for _, entry in ipairs(group.entries) do
                        if placeKind(entry) == 'town' then
                            group.onClick = function()
                                showPointer(entry.position, entry.name)
                                centerOn(entry.position)
                                zoomTo(1)
                            end
                            break
                        end
                    end
                end
            end

            Pp.addRegionTree(list, {
                region = info,
                count = region.count,
                groups = region.groups,
                expanded = expandedTowns,
                regions = expandedRegions,
                openAll = openAll,
                keepOpen = regionFilter ~= '',
                addEntry = function(rows, place)
                    local row = addPlaceRow(rows, place)
                    if place == selectedPlace then
                        focus = row
                    end
                    return row
                end,
                onClick = function()
                    if info.position then
                        centerOn(info.position)
                        minimap:setZoom(LABEL_ZOOMS.city)
                    end
                end
            })
        end
    end
    if count == 0 then
        local hint = g_ui.createWidget('TkMuted', list)
        hint:setText(tr('Nothing matches.'))
        hint:setMarginLeft(6)
        hint:setMarginTop(6)
    end
    if focus then
        Pp.revealRow(list, focus)
    end
end

local function clearPointer()
    removeEvent(pointerEvent)
    pointerEvent = nil
    if pointer then
        pointer:destroy()
        pointer = nil
    end
end

local function animatePointer()
    if not pointer or not pointer:isVisible() then
        return
    end
    local t = g_clock.millis() / 1000
    pointer.arrow:setMarginBottom(math.floor(math.abs(math.sin(t * math.pi / 0.9)) * 12 + 0.5))
    local phase = (t % 1.4) / 1.4
    local size = math.floor(12 + 50 * phase)
    pointer.ring:setSize({ width = size, height = size })
    pointer.ring:setOpacity(1 - phase)
end

-- the bigger, animated mark for the spot being shown (a quest's NPC, a house, a place...); left-click
-- walks there unless onClick is given
showPointer = function(pos, text, onClick)
    clearPointer()
    pointer = g_ui.createWidget('PpMapPointer', minimap)
    pointer.arrow:setTooltip(text or '')
    pointer.arrow.onMouseRelease = function(widget, mousePos, mouseButton)
        if mouseButton == MouseLeftButton then
            if onClick then
                onClick()
            else
                Navigation.goTo(pos, text)
            end
        end
        return true
    end
    placeMark(pointer, pos)
    pointerEvent = cycleEvent(animatePointer, 33)
end

selectPlace = function(place)
    selectedPlace = place
    showPointer(place.position, place.name)
    centerOn(place.position)
    zoomTo(place.type and 2 or 1)
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
    showPointer(pos, text)
    centerOn(pos)
end

-- marks for a list of spots (a Pokemon's spawn areas, the staff's open reports), centred on the nearest
-- one; an entry may bring its own icon (an image path), size and onClick instead of walking there
function MapTab.showPositions(list, text)
    show('map')
    clearList(shownMarks)
    clearPointer()
    local player = g_game.getLocalPlayer()
    local here = player and player:getPosition()
    local best, bestEntry, bestDistance
    for _, entry in ipairs(list) do
        local pos = toPosition(entry)
        local mark = newMark(entry.icon or (Pp.IMAGES .. 'mark_spawn'), entry.size or 16)
        mark:setTooltip(entry.text or text or '')
        placeMark(mark, pos)
        mark.onMouseRelease = function(widget, mousePos, mouseButton)
            if mouseButton == MouseLeftButton then
                if entry.onClick then
                    entry.onClick(entry)
                else
                    Navigation.goTo(pos, entry.text or text)
                end
            end
            return true
        end
        shownMarks[#shownMarks + 1] = mark
        local distance = here and (Pp.distance(here, pos) + (here.z == pos.z and 0 or 100000)) or 0
        if not bestDistance or distance < bestDistance then
            best, bestEntry, bestDistance = pos, entry, distance
        end
    end
    if best then
        showPointer(best, bestEntry.text or text, bestEntry.onClick and function() bestEntry.onClick(bestEntry) end)
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

local function worldAvailable()
    if hasWorld == nil then
        hasWorld = g_resources.directoryExists(WORLD) and g_satelliteMap.loadDirectory(WORLD) > 0
    end
    return hasWorld
end

local function applyView()
    local real = worldAvailable() and g_settings.getBoolean(REAL_MAP_SETTING, true)
    minimap:setSatelliteMode(real)
    minimap:setUseStaticMinimap(real)
    local button = page.mapFrame.controls.view
    button:setVisible(worldAvailable())
    button:setIcon(Pp.IMAGES .. (real and 'icon_view_minimap' or 'icon_view_real'))
    button:setTooltip(real and tr('Show the minimap') or tr('Show the real map'))
end

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
        refreshLabels()
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
    controls.labels.onClick = function()
        g_settings.set(LABELS_SETTING, not labelsOn())
        refreshLabels()
    end
    controls.view.onClick = function()
        g_settings.set(REAL_MAP_SETTING, not g_settings.getBoolean(REAL_MAP_SETTING, true))
        applyView()
    end
    minimap:setFloorSeparatorOpacity(GROUND_OPACITY)
    applyView()
    drawLabels()
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
    placesPanel.kind:addOption(tr('All places'), '')
    for _, kind in ipairs(KINDS) do
        placesPanel.kind:addOption(tr(kind.name), kind.id)
    end
    placesPanel.kind.onOptionChange = drawPlaces
    fillRegions()
    placesPanel.region.onOptionChange = drawPlaces
    placesPanel.list.onChildFocusChange = function(list, focused)
        if focused and focused.place and focused.place ~= selectedPlace then
            selectPlace(focused.place)
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
        waypoints[#waypoints + 1] = { name = place.name, icon = place.icon or place.type or 'pin', x = place.position.x,
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
    if #labelWidgets == 0 then
        drawLabels()
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
    clearPointer()
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
    clearPointer()
    if dialog then
        dialog:destroy()
        dialog = nil
    end
end

Pp.registerPage('map', MapTab)
