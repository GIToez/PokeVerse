-- The Ranger radar popup. The server (Vocations.radar in the server lib) talks JSON on ExtendedIds.Radar:
-- {type = "status", enabled, rank, title, range, cooldown, wait, unlocks, open} says whether the trainer has a
-- radar (the top bar button only shows for Rangers), {type = "scan", ...the status fields, center, blips, total} is
-- one scan (total counts the Pokemon past the blips cap too) and {type = "error", text, wait} a refused one. The popup sends {action = "hello"} and
-- {action = "scan"}. Blips stay where the scan saw them, except from the live rank (scan.live): then exact
-- blips follow their Pokemon, from the game map while they are on screen and from the server's
-- {type = "live", blips, gone} otherwise, while the popup is open or tracking ({action = "live", on}).
-- Filtering happens here. A tracked target gets the cone on the radar, an arrow beside the trainer on the
-- game map and a flag on the minimap. From the prints rank the popup also sends {action = "track", id} (or
-- {action = "track"} to stop), and the server sends {type = "print", id, x, y, z, way} for each step the
-- Pokemon takes on soft ground, which shows as a glowing footprint on the game map.
local IMAGES = '/modules/game_radar/images/'
local RADIUS = 176 -- pixels from the middle of the radar image to its edge (scripts/art/radar_ui.py)
local TICK_MS = 150
local ARROW_TILES = 1.7 -- how far from the middle of the trainer's sprite the map arrow sits
local SPRITE_LIFT = 0.45 -- tiles: trainer sprites stand on their tile and reach up into the one above
local MUTED_COLOR = '#96aacd'
local ERROR_COLOR = '#ff8a80'
local MESSAGE_MS = 4000
local PRINT_MS = 90000 -- how long a footprint of the tracked Pokemon stays
local PRINT_FADE_MS = 30000 -- the end of that, when it fades out
local PRINT_TICK_MS = 30 -- prints follow the map smoothly while the trainer walks
local MAX_PRINTS = 40
local PRINT_ROTATION = { north = 0, east = 90, south = 180, west = 270 }

local KIND_NAMES = { common = 'Common', uncommon = 'Uncommon', rare = 'Rare', shiny = 'Shiny',
                     legendary = 'Legendary', unknown = 'Unknown' }
local KIND_COLORS = { common = '#ff6b6b', uncommon = '#5aa8ff', rare = '#c07bff', shiny = '#7dffe6',
                      legendary = '#ffad33', unknown = '#ff6b6b' }
local RARITIES = { 'common', 'uncommon', 'rare' }
local TYPE_COLORS = {
    normal = '#a8a878', fight = '#c03028', flying = '#a890f0', poison = '#a040a0', ground = '#e0c068',
    rock = '#b8a038', bug = '#a8b820', ghost = '#705898', steel = '#b8b8d0', fire = '#f08030',
    water = '#6890f0', grass = '#78c850', electric = '#f8c830', psychic = '#f85888', ice = '#98d8d8',
    dragon = '#7038f8', dark = '#705848', fairy = '#ee99ac'
}
local TYPE_LABELS = { fight = 'Fighting' }
local DIRECTION_NAMES = { east = 'East', ['south-east'] = 'South-East', south = 'South', ['south-west'] = 'South-West',
                          west = 'West', ['north-west'] = 'North-West', north = 'North', ['north-east'] = 'North-East' }
local DIRECTIONS = { 'east', 'south-east', 'south', 'south-west', 'west', 'north-west', 'north', 'north-east' }
local BAND_NAMES = { near = 'Near', far = 'Far', ['very far'] = 'Very far' }
local FILTERS = { 'all', 'species', 'type', 'rarity', 'shiny', 'legendary' }
local FILTER_NAMES = { all = 'All', species = 'Species', type = 'Type', rarity = 'Rarity', shiny = 'Shiny Only',
                       legendary = 'Legendaries Only' }

local window, button, mapArrow
local arrowOwner -- the map panel the map arrow is on
local arrowRect -- the trainer's tile on the map panel, from when they last stood still
local layoutKey -- what the blips were last laid out for
local status = { enabled = false }
local blips = {} -- the last scan's blips, each with .widget and .halo
local filter = { mode = 'all' }
local target -- one of blips
local flagPos
local readyAt = 0
local tickEvent, messageEvent, printsEvent
local prints = {} -- the tracked Pokemon's footprints, oldest first: { widget, x, y, z, way, at }
local printsId -- the Pokemon the server was asked to send footprints of

local function send(data)
    local protocol = g_game.getProtocolGame()
    if protocol and g_game.isOnline() then
        protocol:sendExtendedJSONOpcode(ExtendedIds.Radar, data)
    end
end

local function playerPos()
    local player = g_game.getLocalPlayer()
    return player and player:getPosition() or nil
end

local function typeLabel(name)
    return TYPE_LABELS[name] or (name:sub(1, 1):upper() .. name:sub(2))
end

local function directionOf(dx, dy)
    if dx == 0 and dy == 0 then
        return nil
    end
    return DIRECTIONS[(math.floor((math.deg(math.atan2(dy, dx)) + 22.5) / 45) % 8) + 1]
end

local function unlocked(what)
    local rank = tonumber((status.unlocks or {})[what])
    return rank == nil or (status.rank or 0) >= rank
end

-- where the target is now: on screen an exact blip follows its creature
local function targetPos()
    if not target then
        return nil
    end
    if target.exact and target.id then
        local creature = g_map.getCreatureById(target.id)
        if creature then
            local pos = creature:getPosition()
            if pos then
                target.x, target.y, target.z = pos.x, pos.y, pos.z
            end
        end
    end
    return { x = target.x, y = target.y, z = target.z }
end

local function matches(blip)
    local mode, value = filter.mode, filter.value
    if mode == 'species' then
        return blip.name == value
    elseif mode == 'type' then
        return table.find(blip.types or {}, value) ~= nil
    elseif mode == 'rarity' then
        return blip.kind == value
    elseif mode == 'shiny' then
        return blip.kind == 'shiny'
    elseif mode == 'legendary' then
        return blip.kind == 'legendary'
    end
    return true
end

local function showMessage(text, color)
    removeEvent(messageEvent)
    window.message:setColor(color or ERROR_COLOR)
    window.message:setText(text)
    messageEvent = scheduleEvent(function()
        messageEvent = nil
        window.message:setText('')
    end, MESSAGE_MS)
end

-- Minimap flag and map arrow ----------------------------------------------------------------------

local function minimap()
    local mm = modules.game_minimap
    local ok, ui = pcall(function() return mm and mm.getMiniMapUi and mm.getMiniMapUi() end)
    return ok and ui or nil
end

local function clearFlag()
    local ui = minimap()
    if ui and flagPos then
        ui:removeFlag(flagPos)
    end
    flagPos = nil
end

local function placeFlag(pos)
    if flagPos and math.abs(flagPos.x - pos.x) + math.abs(flagPos.y - pos.y) < 2 and flagPos.z == pos.z then
        return
    end
    clearFlag()
    local ui = minimap()
    if ui then
        ui:addFlag(pos, IMAGES .. 'flag', target.name or tr('Radar target'), true)
        flagPos = pos
    end
end

local function hideArrow()
    if mapArrow then
        mapArrow:hide()
    end
end

local function destroyArrow()
    if mapArrow and not mapArrow:isDestroyed() then
        mapArrow:destroy()
    end
    mapArrow, arrowOwner, arrowRect = nil, nil, nil
end

-- The arrow sits on the map panel around the trainer's tile. It is not attached to the trainer
-- (creature:attachWidget): the client engine crashes laying out widgets attached to creatures.
-- The camera follows the trainer, so while they walk their sprite stays where it was at rest.
local function updateArrow(from, to)
    local mapPanel = modules.game_interface and modules.game_interface.getMapPanel()
    local player = g_game.getLocalPlayer()
    if not mapPanel or not player or from.z ~= to.z then
        hideArrow()
        return
    end
    if not arrowRect or not player:isWalking() then
        local rect = mapPanel:getTileRect(from)
        arrowRect = rect and rect.width > 0 and rect or nil
    end
    local rect = arrowRect
    if not rect then
        hideArrow()
        return
    end
    if not mapArrow or mapArrow:isDestroyed() or arrowOwner ~= mapPanel then
        destroyArrow()
        mapArrow = g_ui.createWidget('RadarMapArrow', mapPanel)
        arrowOwner = mapPanel
        arrowRect = rect
    end
    local dx, dy = to.x - from.x, to.y - from.y
    local angle = math.atan2(dy, dx)
    local reach = rect.width * ARROW_TILES
    mapArrow:setPosition({ x = math.floor(rect.x + rect.width / 2 + math.cos(angle) * reach - mapArrow:getWidth() / 2),
                           y = math.floor(rect.y + rect.height * (0.5 - SPRITE_LIFT) + math.sin(angle) * reach - mapArrow:getHeight() / 2) })
    mapArrow.icon:setRotation(math.deg(angle))
    mapArrow.distance:setText(tostring(math.max(math.abs(dx), math.abs(dy))))
    mapArrow:show()
end

-- Footprints ---------------------------------------------------------------------------------------

local function clearPrints()
    for _, p in ipairs(prints) do
        if not p.widget:isDestroyed() then
            p.widget:destroy()
        end
    end
    prints = {}
    removeEvent(printsEvent)
    printsEvent = nil
end

-- each print sits on its tile of the game map, fading out at the end of its time
local function updatePrints()
    local mapPanel = modules.game_interface and modules.game_interface.getMapPanel()
    local now = g_clock.millis()
    while prints[1] and now - prints[1].at >= PRINT_MS do
        local p = table.remove(prints, 1)
        if not p.widget:isDestroyed() then
            p.widget:destroy()
        end
    end
    if not mapPanel or #prints == 0 then
        clearPrints()
        return
    end
    local camera = mapPanel:getCameraPosition()
    local area = mapPanel:getRect()
    for _, p in ipairs(prints) do
        local rect = camera and p.z == camera.z and mapPanel:getTileRect({ x = p.x, y = p.y, z = p.z })
        if rect and rect.width > 0 and rect.x >= area.x and rect.y >= area.y and
                rect.x + rect.width <= area.x + area.width and rect.y + rect.height <= area.y + area.height then
            if p.widget:getParent() ~= mapPanel then
                p.widget:setParent(mapPanel)
            end
            p.widget:setRect(rect)
            local left = PRINT_MS - (now - p.at)
            p.widget.icon:setOpacity(left < PRINT_FADE_MS and left / PRINT_FADE_MS or 1)
            p.widget:show()
        else
            p.widget:hide()
        end
    end
end

local function addPrint(data)
    local mapPanel = modules.game_interface and modules.game_interface.getMapPanel()
    if not mapPanel or tonumber(data.id) ~= printsId then
        return
    end
    local p = { x = tonumber(data.x) or 0, y = tonumber(data.y) or 0, z = tonumber(data.z) or 0,
                way = PRINT_ROTATION[data.way] and data.way or 'north', at = g_clock.millis() }
    for i = #prints, 1, -1 do
        local old = prints[i]
        if old.x == p.x and old.y == p.y and old.z == p.z then
            old.widget:destroy()
            table.remove(prints, i)
        end
    end
    p.widget = g_ui.createWidget('RadarPrint', mapPanel)
    p.widget.icon:setRotation(PRINT_ROTATION[p.way])
    p.widget:hide()
    prints[#prints + 1] = p
    while #prints > MAX_PRINTS do
        table.remove(prints, 1).widget:destroy()
    end
    updatePrints()
    if not printsEvent then
        printsEvent = cycleEvent(updatePrints, PRINT_TICK_MS)
    end
end

-- Asks the server for the footprints of the tracked Pokemon (nil: none). Shinies and legendaries
-- stay vague, so only the other blips are tracked by their prints.
local function trackPrints(blip)
    local id = blip and blip.id and not blip.band and unlocked('prints') and blip.id or nil
    if id == printsId then
        return
    end
    if printsId then
        clearPrints()
    end
    printsId = id
    send(id and { action = 'track', id = id } or { action = 'track' })
end

-- Radar drawing -----------------------------------------------------------------------------------

local function refreshTarget()
    local info = window.target
    if not target then
        info.creature:setVisible(false)
        info.unknown:setVisible(false)
        info.name:setText(tr('No target'))
        info.badges:destroyChildren()
        info.distance:setText(tr('Click a blip on the radar'))
        info.direction:setText(tr('to track it.'))
        info.stop:setVisible(false)
        window.radar.cone:hide()
        return
    end
    if target.look then
        info.creature:setOutfit({ type = target.look })
        info.creature:setVisible(true)
        info.unknown:setVisible(false)
    else
        info.creature:setVisible(false)
        info.unknown:setVisible(true)
        info.unknown:setImageSource(IMAGES .. 'blip_' .. target.kind)
    end
    info.name:setText(target.name or tr('Unknown Pokemon'))
    info.badges:destroyChildren()
    if target.kind ~= 'unknown' then
        local badge = g_ui.createWidget('RadarBadge', info.badges)
        badge:setText(tr(KIND_NAMES[target.kind]):upper())
        badge:setImageColor(KIND_COLORS[target.kind])
    end
    for _, t in ipairs(target.types or {}) do
        local badge = g_ui.createWidget('RadarBadge', info.badges)
        badge:setText(tr(typeLabel(t)):upper())
        badge:setImageColor(TYPE_COLORS[t] or '#8899aa')
    end
    info.stop:setVisible(true)
end

local function refreshTargetDistance(from, to)
    local info = window.target
    local dx, dy = to.x - from.x, to.y - from.y
    local distance = math.max(math.abs(dx), math.abs(dy))
    if target.band then
        info.distance:setText(tr('Distance: %s', tr(BAND_NAMES[target.band] or target.band)))
    else
        info.distance:setText(tr('Distance: %s%d tiles', target.exact and '' or '~', distance))
    end
    local direction = target.band and target.direction or directionOf(dx, dy)
    info.direction:setText(tr('Direction: %s', direction and tr(DIRECTION_NAMES[direction]) or tr('Here')))
end

local liveWanted -- what the server was last told about the live updates

-- the battle list marks the tracked Pokemon (game_pokehud nameplates.lua)
local function markTarget()
    local nameplates = modules.game_pokehud and modules.game_pokehud.Nameplates
    if nameplates and nameplates.setTracked then
        nameplates.setTracked(target and target.id or nil)
    end
end

local function setLive(on)
    on = on and status.live == true
    if liveWanted ~= on then
        liveWanted = on
        send({ action = 'live', on = on })
    end
end

local function stopTracking()
    target = nil
    markTarget()
    trackPrints(nil)
    layoutKey = nil
    clearFlag()
    hideArrow()
    for _, blip in ipairs(blips) do
        blip.widget:setChecked(false)
    end
    if window then
        window.radar.selected:hide()
        refreshTarget()
        if not window:isVisible() then
            setLive(false)
        end
    end
end

-- Live blips on the game map's screen move here every tick; the server sends the others
local function followOnScreen()
    if not status.live then
        return
    end
    for _, blip in ipairs(blips) do
        if blip.exact and blip.id then
            local creature = g_map.getCreatureById(blip.id)
            local pos = creature and creature:getPosition()
            if pos and (pos.x ~= blip.x or pos.y ~= blip.y or pos.z ~= blip.z) then
                blip.x, blip.y, blip.z = pos.x, pos.y, pos.z
                layoutKey = nil
            end
        end
    end
end

local function removeBlip(blip)
    for i, other in ipairs(blips) do
        if other == blip then
            table.remove(blips, i)
            break
        end
    end
    blip.widget:destroy()
    if blip.halo then
        blip.halo:destroy()
    end
    layoutKey = nil
end

-- puts each blip where it is from the trainer now, so walking moves the radar under the blips
local function layoutBlips(from)
    local key = string.format('%d,%d,%d,%d,%s', from.x, from.y, from.z, status.range or 0,
        target and (target.x .. ',' .. target.y) or '')
    if key == layoutKey then
        return
    end
    layoutKey = key
    local range = math.max(1, status.range or 1)
    local radar = window.radar
    local half = radar:getWidth() / 2
    for _, blip in ipairs(blips) do
        local dx, dy = blip.x - from.x, blip.y - from.y
        local px, py = dx / range * RADIUS, dy / range * RADIUS
        local length = math.sqrt(px * px + py * py)
        -- the scan covers a square: its corners go on the rim
        if length > RADIUS then
            px, py = px * RADIUS / length, py * RADIUS / length
        end
        local visible = matches(blip) and blip.z == from.z and math.max(math.abs(dx), math.abs(dy)) <= range
        blip.widget:setVisible(visible)
        if visible then
            blip.widget:setMarginLeft(math.floor(half + px - blip.widget:getWidth() / 2))
            blip.widget:setMarginTop(math.floor(half + py - blip.widget:getHeight() / 2))
        end
        if blip.halo then
            blip.halo:setVisible(visible)
            if visible then
                blip.halo:setMarginLeft(math.floor(half + px - blip.halo:getWidth() / 2))
                blip.halo:setMarginTop(math.floor(half + py - blip.halo:getHeight() / 2))
            end
        end
    end
    local selected = radar.selected
    if target and target.widget:isVisible() then
        selected:setMarginLeft(target.widget:getMarginLeft() + math.floor((target.widget:getWidth() - selected:getWidth()) / 2))
        selected:setMarginTop(target.widget:getMarginTop() + math.floor((target.widget:getHeight() - selected:getHeight()) / 2))
        selected:show()
    else
        selected:hide()
    end
end

local function countVisible()
    local count = 0
    for _, blip in ipairs(blips) do
        if matches(blip) then
            count = count + 1
        end
    end
    return count
end

local function refreshStatusLine()
    if not status.enabled then
        window.subtitle:setText(tr('Only Rangers can use the radar.'))
        return
    end
    local text = tr('%s, rank %d', status.title or '', status.rank or 1) .. '  \183  ' ..
        tr('Range %d tiles', status.range or 0)
    if status.scanned then
        local shown = countVisible()
        if status.total and status.total > #blips and filter.mode == 'all' then
            text = text .. '  \183  ' .. tr('%d of %d shown', shown, status.total)
        else
            text = text .. '  \183  ' .. tr('%d found', shown)
        end
    end
    window.subtitle:setText(text)
end

local function refreshScanButton()
    local wait = math.ceil(readyAt - g_clock.seconds())
    local scan = window.scan
    if wait > 0 then
        scan:setText(tr('Recharging %ds', wait))
        scan:setEnabled(false)
    else
        scan:setText(tr('Scan'))
        scan:setEnabled(status.enabled == true)
    end
end

local function tick()
    if not g_game.isOnline() then
        return
    end
    local from = playerPos()
    followOnScreen()
    if window:isVisible() then
        refreshScanButton()
        if from then
            layoutBlips(from)
        end
    end
    if not target or not from then
        hideArrow()
        window.radar.cone:hide()
        return
    end
    local to = targetPos()
    local dx, dy = to.x - from.x, to.y - from.y
    if to.z == from.z and math.max(math.abs(dx), math.abs(dy)) <= 1 then
        local name = target.name or tr('the Pokemon')
        stopTracking()
        modules.game_textmessage.displayGameMessage(tr('Radar: you reached %s.', name))
        return
    end
    updateArrow(from, to)
    placeFlag(to)
    if window:isVisible() then
        refreshTargetDistance(from, to)
        local cone = window.radar.cone
        if to.z == from.z and (dx ~= 0 or dy ~= 0) then
            cone:setRotation(math.deg(math.atan2(dy, dx)))
            cone:show()
        else
            cone:hide()
        end
    end
end

local function selectBlip(blip)
    if target == blip then
        return
    end
    for _, other in ipairs(blips) do
        other.widget:setChecked(other == blip)
    end
    target = blip
    markTarget()
    trackPrints(blip)
    layoutKey = nil
    clearFlag()
    refreshTarget()
    tick()
end

local function clearBlips()
    for _, blip in ipairs(blips) do
        blip.widget:destroy()
        if blip.halo then
            blip.halo:destroy()
        end
    end
    blips = {}
    layoutKey = nil
end

local function buildBlips(list)
    local oldId = target and target.id
    target = nil
    clearBlips()
    clearFlag()
    local layer = window.radar.blips
    for _, data in ipairs(list or {}) do
        local kind = KIND_NAMES[data.kind] and data.kind or 'unknown'
        local blip = { id = tonumber(data.id), x = tonumber(data.x) or 0, y = tonumber(data.y) or 0,
                       z = tonumber(data.z) or 0, kind = kind, exact = data.exact == true, name = data.name,
                       look = tonumber(data.look), types = type(data.types) == 'table' and data.types or {},
                       direction = data.direction, band = data.band }
        if data.band then
            blip.halo = g_ui.createWidget('RadarHalo', layer)
            blip.halo:setImageSource(IMAGES .. 'halo_' .. (kind == 'legendary' and 'legendary' or
                kind == 'shiny' and 'shiny' or 'unknown'))
        end
        local widget = g_ui.createWidget((kind == 'shiny' or kind == 'legendary') and 'RadarStarBlip' or 'RadarBlip', layer)
        widget:setImageSource(IMAGES .. 'blip_' .. kind)
        widget:setTooltip((blip.name or tr('Unknown Pokemon')) .. (kind ~= 'unknown' and (' (' .. tr(KIND_NAMES[kind]) .. ')') or ''))
        widget.onClick = function() selectBlip(blip) end
        blip.widget = widget
        blips[#blips + 1] = blip
        if oldId and blip.id == oldId then
            target = blip
        end
    end
    if target then
        target.widget:setChecked(true)
    else
        hideArrow()
    end
    markTarget()
    trackPrints(target)
    refreshTarget()
end

-- Filters -----------------------------------------------------------------------------------------

local refreshFilters

local function setFilter(mode, value)
    filter = { mode = mode, value = value }
    layoutKey = nil
    if target and not matches(target) then
        stopTracking()
    end
    refreshFilters()
    refreshStatusLine()
    tick()
end

local function choices(mode)
    local seen, list = {}, {}
    local function add(value, text)
        if value and not seen[value] then
            seen[value] = true
            list[#list + 1] = { value = value, text = text }
        end
    end
    if mode == 'rarity' then
        for _, kind in ipairs(RARITIES) do
            add(kind, tr(KIND_NAMES[kind]))
        end
        return list
    end
    for _, blip in ipairs(blips) do
        if mode == 'species' and blip.name then
            add(blip.name, blip.name)
        elseif mode == 'type' then
            for _, t in ipairs(blip.types) do
                add(t, tr(typeLabel(t)))
            end
        end
    end
    table.sort(list, function(a, b) return a.text < b.text end)
    return list
end

local function openChoices(mode, row)
    local list = choices(mode)
    local menu = g_ui.createWidget('PopupMenu')
    menu:setGameMenu(true)
    if #list == 0 then
        menu:addOption(mode == 'species' and tr('Scan to see the species') or tr('Scan to see the types'), function() end)
    end
    for _, choice in ipairs(list) do
        menu:addOption(choice.text, function() setFilter(mode, choice.value) end)
    end
    local pos = row:getPosition()
    menu:display({ x = pos.x + row:getWidth(), y = pos.y })
end

refreshFilters = function()
    local unlocks = status.unlocks or {}
    for _, mode in ipairs(FILTERS) do
        local row = window.filters[mode]
        local open = mode == 'all' or unlocked(mode)
        local text = tr(FILTER_NAMES[mode])
        if filter.mode == mode and filter.value then
            local value = filter.value
            if mode == 'type' then
                value = tr(typeLabel(value))
            elseif mode == 'rarity' then
                value = tr(KIND_NAMES[value])
            end
            text = text .. ': ' .. value
        end
        row.label:setText(text)
        row:setOn(filter.mode == mode)
        row:setEnabled(open)
        row.chevron:setVisible(open and (mode == 'species' or mode == 'type' or mode == 'rarity'))
        row.lock:setVisible(not open)
        row:setTooltip(open and '' or tr('From Ranger rank %d', tonumber(unlocks[mode]) or 0))
    end
end

local function setupFilters()
    for _, mode in ipairs(FILTERS) do
        local row = window.filters[mode]
        row.onClick = function()
            if mode == 'species' or mode == 'type' or mode == 'rarity' then
                openChoices(mode, row)
            else
                setFilter(mode)
            end
        end
    end
end

-- Window ------------------------------------------------------------------------------------------

local function refreshPlayer()
    local player = g_game.getLocalPlayer()
    if player then
        window.radar.center.creature:setOutfit(player:getOutfit())
    end
end

function show()
    if not status.enabled then
        modules.game_textmessage.displayFailureMessage(tr('Only Rangers can use the radar.'))
        return
    end
    local root = rootWidget:getSize()
    if not window:isVisible() then
        window:setPosition({ x = math.floor((root.width - window:getWidth()) / 2),
                             y = math.max(0, math.floor((root.height - window:getHeight()) / 2)) })
    end
    refreshPlayer()
    refreshFilters()
    refreshStatusLine()
    refreshTarget()
    window:show()
    window:raise()
    window:focus()
    if button then
        button:setOn(true)
    end
    if not status.scanned and readyAt <= g_clock.seconds() then
        send({ action = 'scan' })
    end
    setLive(true)
    tick()
end

function hide()
    if window then
        window:hide()
    end
    if not target then
        setLive(false)
    end
    if button then
        button:setOn(false)
    end
end

function toggle()
    if window:isVisible() then
        hide()
    else
        show()
    end
end

function scan()
    if readyAt <= g_clock.seconds() then
        send({ action = 'scan' })
    end
end

function stop()
    stopTracking()
end

local function applyStatus(data)
    local scanned, live, total = status.scanned, status.live, status.total
    status = { enabled = data.enabled == true, rank = tonumber(data.rank), title = data.title,
               range = tonumber(data.range), cooldown = tonumber(data.cooldown), unlocks = data.unlocks or {},
               scanned = scanned, live = live, total = total }
    readyAt = g_clock.seconds() + (tonumber(data.wait) or 0)
    if button then
        button:setVisible(status.enabled)
    end
    if not status.enabled then
        stopTracking()
        clearBlips()
        status.scanned = nil
        hide()
        return
    end
    if not unlocked(filter.mode) then
        filter = { mode = 'all' }
    end
    refreshFilters()
    refreshStatusLine()
end

local function onLive(data)
    local byId = {}
    for _, blip in ipairs(blips) do
        if blip.id then
            byId[blip.id] = blip
        end
    end
    for _, moved in ipairs(type(data.blips) == 'table' and data.blips or {}) do
        local blip = byId[tonumber(moved.id)]
        if blip and blip.exact then
            blip.x, blip.y, blip.z = tonumber(moved.x) or blip.x, tonumber(moved.y) or blip.y, tonumber(moved.z) or blip.z
            layoutKey = nil
        end
    end
    for _, id in ipairs(type(data.gone) == 'table' and data.gone or {}) do
        local blip = byId[tonumber(id)]
        if blip then
            if blip == target then
                local name = target.name or tr('the Pokemon')
                stopTracking()
                modules.game_textmessage.displayGameMessage(tr('Radar: you lost track of %s.', name))
            end
            removeBlip(blip)
        end
    end
    if window:isVisible() then
        refreshStatusLine()
    end
end

local function onRadar(protocol, opcode, buffer)
    local ok, data = pcall(json.decode, buffer)
    if not ok or type(data) ~= 'table' then
        g_logger.warning('Radar: invalid message')
        return
    end
    if data.type == 'status' then
        applyStatus(data)
        if data.open and status.enabled then
            show()
        end
    elseif data.type == 'scan' then
        applyStatus(data)
        status.scanned = true
        status.live = data.live == true
        status.total = tonumber(data.total)
        liveWanted = status.live or nil
        buildBlips(type(data.blips) == 'table' and data.blips or {})
        refreshStatusLine()
        if not window:isVisible() then
            show()
        end
        tick()
    elseif data.type == 'live' then
        onLive(data)
    elseif data.type == 'print' then
        addPrint(data)
    elseif data.type == 'track' then
        if data.id and tonumber(data.id) == printsId and window:isVisible() then
            showMessage(tr('Its footprints show on dirt, grass and sand for %d seconds.', tonumber(data.seconds) or 0),
                MUTED_COLOR)
        end
    elseif data.type == 'error' then
        if data.wait then
            readyAt = g_clock.seconds() + (tonumber(data.wait) or 0)
        end
        if window:isVisible() and data.text then
            showMessage(data.text)
        elseif data.text then
            modules.game_textmessage.displayFailureMessage(data.text)
        end
    end
end

local function onGameStart()
    send({ action = 'hello' })
end

local function onGameEnd()
    removeEvent(messageEvent)
    messageEvent = nil
    stopTracking()
    clearPrints()
    printsId = nil
    clearBlips()
    status = { enabled = false }
    liveWanted = nil
    filter = { mode = 'all' }
    readyAt = 0
    if button then
        button:setVisible(false)
    end
    hide()
    destroyArrow()
end

function init()
    g_ui.importStyle('radar')
    window = g_ui.createWidget('RadarWindow', rootWidget)
    window:hide()
    setupFilters()

    button = modules.client_topmenu.addRightGameToggleButton('radarButton', tr('Ranger radar (U)'),
        IMAGES .. 'button_radar', toggle)
    button:setVisible(false)

    modules.game_vocation.registerTool('radar', { enabled = function() return status.enabled end, toggle = toggle })

    ProtocolGame.registerExtendedOpcode(ExtendedIds.Radar, onRadar)
    connect(g_game, { onGameStart = onGameStart, onGameEnd = onGameEnd })
    tickEvent = cycleEvent(tick, TICK_MS)
    if g_game.isOnline() then
        onGameStart()
    end
end

function terminate()
    modules.game_vocation.unregisterTool('radar')
    ProtocolGame.unregisterExtendedOpcode(ExtendedIds.Radar)
    disconnect(g_game, { onGameStart = onGameStart, onGameEnd = onGameEnd })
    removeEvent(tickEvent)
    removeEvent(messageEvent)
    tickEvent, messageEvent = nil, nil
    clearPrints()
    clearFlag()
    clearBlips()
    destroyArrow()
    for _, widget in ipairs({ button, window }) do
        if widget then
            widget:destroy()
        end
    end
    button, window = nil, nil
end
