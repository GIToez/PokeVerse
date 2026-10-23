-- Wild legendaries seen from the ground (docs/upcoming-features.md, legendary revamp stage 2). The server
-- (078-wildLegendaries.lua) sends ExtendedIds.LegendaryFlight JSON to the trainers near a flight:
--   {type = "flight", id, species, look, kind = "fly"|"dive", from, to, elapsed, seconds, circle}
--   {type = "shake", strength = 1 to 3, ms, delay}
--   {type = "meteors", seconds, count, big}
-- A flyer is drawn above the map moving from `from` to `to` over `seconds`, raised off the ground and
-- bobbing, with its own sprite dark and see-through on the ground as its shadow; then it circles down
-- over `to` for `circle` seconds, when the server puts the real one there. A dive (Lugia, Kyogre) is
-- only the dark shape, and only over water. Nothing shows under a roof or underground (game_weather's
-- open-sky check); it is drawn the same on every floor. A shake jolts the map for Groudon. Meteors
-- streak down across the screen (Jirachi's shower; one big one for Deoxys's impact).
local DIR = '/modules/game_legendaryflight/'
local FLY_SHADOW = 'Legendary - flight shadow'
local DIVE_SHADOW = 'Legendary - dive shadow'
local LIFT = 2.4 -- tiles between a flyer and its shadow
local BOB = 0.18 -- tiles up and down while flying
local CIRCLE_RADIUS = 1.6
local CIRCLE_TURN = 2.2 -- seconds per circle
local TICK = 30
local FRAME_MS = 140 -- each flying or swimming frame

local METEOR_IMAGE = '/images/effects/legendary_jirachi_star/4'
local METEOR_MS = { 700, 1100 }
local BIG_METEOR_MS = 1300

local flights = {} -- [id] = { data, startedAt, sprite, shadow, scale }
local tickEvent
local shake = { event = nil, left = 0, top = 0 }
local meteors = { list = {}, event = nil } -- list of { widget, startAt, ms, from, to, size }

local function mapPanel()
    return modules.game_interface and modules.game_interface.getMapPanel()
end

local function openSky()
    local weather = modules.game_weather
    if weather and weather.isUnderOpenSky then
        return weather.isUnderOpenSky()
    end
    local player = g_game.getLocalPlayer()
    return player ~= nil and player:getPosition().z <= 7
end

-- Otc directions: 0 north, 1 east, 2 south, 3 west
local function facing(dx, dy)
    if math.abs(dx) >= math.abs(dy) then
        return dx >= 0 and 1 or 3
    end
    return dy >= 0 and 2 or 0
end

local function destroyFlight(id)
    local flight = flights[id]
    if not flight then
        return
    end
    if flight.sprite then
        flight.sprite:destroy()
    end
    if flight.shadow then
        flight.shadow:destroy()
    end
    flights[id] = nil
end

local function clearAll()
    for id in pairs(flights) do
        destroyFlight(id)
    end
    removeEvent(tickEvent)
    tickEvent = nil
end

-- Where it is (in tiles, fractional), how high, and which way it faces, ms after it started
local function placeAt(data, ms)
    local t = ms / 1000
    local from, to = data.from, data.to
    if t <= data.seconds then
        local u = t / math.max(0.1, data.seconds)
        return from.x + (to.x - from.x) * u, from.y + (to.y - from.y) * u, 1, facing(to.x - from.x, to.y - from.y)
    end
    local c = t - data.seconds
    local angle = c / CIRCLE_TURN * 2 * math.pi
    local shrink = 1 - c / math.max(0.1, data.circle)
    local r = CIRCLE_RADIUS * math.max(0.2, shrink)
    local x, y = to.x + math.cos(angle) * r, to.y + math.sin(angle) * r * 0.6
    return x, y, math.max(0, shrink), facing(-math.sin(angle), math.cos(angle))
end

-- client ids of the server's WATER_IDS (constants.lua) through items.otb; sea tiles are walkable
-- here (surfing), so the ground id is the only way to tell
local WATER = {}
for _, range in ipairs({ { 629, 634 }, { 4609, 4614 }, { 4654, 4655 }, { 4809, 4814 }, { 7326, 7326 } }) do
    for id = range[1], range[2] do
        WATER[id] = true
    end
end

local function isWater(x, y, z)
    local tile = g_map.getTile({ x = math.floor(x + 0.5), y = math.floor(y + 0.5), z = z })
    local ground = tile and tile:getGround()
    return ground ~= nil and WATER[ground:getId()] == true
end

-- A creature in a widget never walks, so it would stay on its first (standing) frame: loop the moving ones
local function animate(widget, phases, ms)
    local creature = widget:getCreature()
    if creature and creature.setWalkAnimationPhase and phases > 1 then
        creature:setWalkAnimationPhase(1 + math.floor(ms / FRAME_MS) % (phases - 1))
    end
end

local function newCreature(look, shader)
    local widget = g_ui.createWidget('LegendaryFlyer', mapPanel())
    widget:setOutfit({ type = look })
    widget:setDirection(2)
    if shader then
        widget:getCreature():setShader(shader)
    end
    return widget
end

local function update()
    local map = mapPanel()
    local now = g_clock.millis()
    if not map or not g_game.isOnline() then
        clearAll()
        return
    end
    local camera = map:getCameraPosition()
    local ref = camera and map:getTileRect(camera)
    local sky = openSky()
    local area = map:getRect()
    for id, flight in pairs(flights) do
        local data = flight.data
        local ms = now - flight.startedAt
        if ms > (data.seconds + data.circle) * 1000 then
            destroyFlight(id)
        elseif not ref or ref.width == 0 or not sky then
            flight.shadow:hide()
            if flight.sprite then
                flight.sprite:hide()
            end
        else
            local x, y, height, dir = placeAt(data, ms)
            local tw, th = ref.width, ref.height
            -- a creature stands with its sprite's bottom right on its tile's bottom right
            local right = ref.x + (x - camera.x + 1) * tw
            local bottom = ref.y + (y - camera.y + 1) * th
            local size = flight.size * tw / 32
            local inside = right > area.x and right - size < area.x + area.width and bottom > area.y and
                bottom - size - LIFT * th < area.y + area.height
            if data.kind == 'dive' then
                -- the shape covers the tiles up and left of its own; it shows only with sea under them,
                -- leaving out the outer quarter of a big shape, which is mostly its wing tips
                local tiles = math.max(1, math.ceil(size / tw - 0.25))
                local edge = math.floor(tiles / 4)
                local show = inside
                for ty = edge, tiles - 1 - edge do
                    for tx = edge, tiles - 1 - edge do
                        show = show and isWater(x - tx, y - ty, camera.z)
                    end
                end
                flight.shadow:setVisible(show)
                if show then
                    flight.shadow:setDirection(dir)
                    animate(flight.shadow, flight.phases, ms)
                    flight.shadow:setRect({ x = right - size, y = bottom - size, width = size, height = size })
                end
            else
                flight.shadow:setVisible(inside)
                flight.sprite:setVisible(inside)
                if inside then
                    local flat = math.floor(size * 0.55)
                    local spread = math.floor(size * (0.85 + 0.15 * height))
                    flight.shadow:setDirection(dir)
                    flight.shadow:setOpacity(0.55 + 0.45 * height)
                    flight.shadow:setRect({ x = right - spread + math.floor(tw * 0.3), y = bottom - flat + math.floor(th * 0.2),
                                            width = spread, height = flat })
                    local lift = (LIFT * height + BOB * math.sin(ms / 260) * height) * th
                    flight.sprite:setDirection(dir)
                    animate(flight.sprite, flight.phases, ms)
                    animate(flight.shadow, flight.phases, ms)
                    flight.sprite:setRect({ x = right - size, y = bottom - size - math.floor(lift), width = size, height = size })
                    flight.sprite:raise()
                end
            end
        end
    end
    if next(flights) == nil then
        removeEvent(tickEvent)
        tickEvent = nil
    end
end

local function startFlight(data)
    if type(data.from) ~= 'table' or type(data.to) ~= 'table' or not tonumber(data.look) or not mapPanel() then
        return
    end
    data.seconds = tonumber(data.seconds) or 8
    data.circle = tonumber(data.circle) or 0
    local id = tostring(data.id or 0) .. ':' .. tostring(data.species)
    destroyFlight(id)
    local flight = { data = data, startedAt = g_clock.millis() - (tonumber(data.elapsed) or 0) * 1000 }
    if data.kind == 'dive' then
        flight.shadow = newCreature(data.look, DIVE_SHADOW)
    else
        flight.shadow = newCreature(data.look, FLY_SHADOW)
        flight.sprite = newCreature(data.look)
    end
    local creature = flight.shadow:getCreature()
    local thing = g_things.getThingType(tonumber(data.look), ThingCategoryCreature)
    flight.phases = thing and thing:getAnimationPhases() or 1
    flight.size = math.max(64, math.min(192, creature and creature:getExactSize() or 64))
    flight.shadow:hide()
    if flight.sprite then
        flight.sprite:hide()
    end
    flights[id] = flight
    if not tickEvent then
        tickEvent = cycleEvent(update, TICK)
    end
    update()
end

local function clearMeteors()
    removeEvent(meteors.event)
    meteors.event = nil
    for _, m in ipairs(meteors.list) do
        m.widget:destroy()
    end
    meteors.list = {}
end

local function updateMeteors()
    local map = mapPanel()
    if not map or not g_game.isOnline() then
        clearMeteors()
        return
    end
    local now, area = g_clock.millis(), map:getRect()
    for i = #meteors.list, 1, -1 do
        local m = meteors.list[i]
        local t = (now - m.startAt) / m.ms
        if t >= 1 then
            m.widget:destroy()
            table.remove(meteors.list, i)
        elseif t < 0 then
            m.widget:hide()
        else
            local x = area.x + (m.from.x + (m.to.x - m.from.x) * t) * area.width
            local y = area.y + (m.from.y + (m.to.y - m.from.y) * t) * area.height
            m.widget:setRect({ x = math.floor(x - m.size / 2), y = math.floor(y - m.size / 2), width = m.size, height = m.size })
            m.widget:setOpacity(t < 0.15 and t / 0.15 or (t > 0.8 and (1 - t) / 0.2 or 1))
            m.widget:show()
            m.widget:raise()
        end
    end
    if #meteors.list == 0 then
        removeEvent(meteors.event)
        meteors.event = nil
    end
end

-- Stars falling from the top right toward the bottom left, in screen fractions so the zoom doesn't matter
local function startMeteors(seconds, total, big)
    local map = mapPanel()
    if not map or not openSky() then
        return
    end
    local tile = map:getTileRect(map:getCameraPosition())
    local tw = (tile and tile.width > 0) and tile.width or 32
    local now = g_clock.millis()
    total = math.max(1, math.min(80, tonumber(total) or 12))
    seconds = math.max(0.5, math.min(30, tonumber(seconds) or 6))
    for i = 1, (big and 1 or total) do
        local widget = g_ui.createWidget('LegendaryMeteor', map)
        widget:setImageSource(METEOR_IMAGE)
        widget:hide()
        local m = { widget = widget }
        if big then
            m.startAt, m.ms, m.size = now, BIG_METEOR_MS, tw * 6
            m.from, m.to = { x = 1.05, y = -0.15 }, { x = 0.5, y = 0.45 }
        else
            local sx, sy = math.random(30, 115) / 100, math.random(-20, 25) / 100
            local reach = math.random(35, 60) / 100
            m.startAt, m.ms, m.size = now + math.random(0, math.floor(seconds * 1000)), math.random(METEOR_MS[1], METEOR_MS[2]),
                math.floor(tw * math.random(25, 40) / 10)
            m.from, m.to = { x = sx, y = sy }, { x = sx - reach, y = sy + reach }
        end
        table.insert(meteors.list, m)
    end
    if not meteors.event then
        meteors.event = cycleEvent(updateMeteors, TICK)
    end
end

local function stopShake()
    removeEvent(shake.event)
    shake.event = nil
    local map = mapPanel()
    if map and shake.active then
        map:setMarginLeft(shake.left)
        map:setMarginTop(shake.top)
    end
    shake.active = false
end

local function startShake(strength, ms)
    local map = mapPanel()
    if not map then
        return
    end
    if not shake.active then
        shake.left, shake.top = map:getMarginLeft(), map:getMarginTop()
        shake.active = true
    end
    removeEvent(shake.event)
    local amplitude = math.max(1, math.min(3, tonumber(strength) or 1)) * 2
    local started, length = g_clock.millis(), math.max(200, math.min(4000, tonumber(ms) or 1500))
    shake.event = cycleEvent(function()
        local t = g_clock.millis() - started
        if t >= length or not g_game.isOnline() then
            stopShake()
            return
        end
        local a = math.floor(amplitude * (1 - t / length) + 0.5)
        map:setMarginLeft(shake.left + math.random(-a, a))
        map:setMarginTop(shake.top + math.random(-a, a))
    end, 40)
end

local function onMessage(protocol, opcode, buffer)
    local ok, data = pcall(json.decode, buffer)
    if not ok or type(data) ~= 'table' then
        g_logger.warning('LegendaryFlight: invalid message')
        return
    end
    if data.type == 'flight' then
        startFlight(data)
    elseif data.type == 'shake' then
        local delay = tonumber(data.delay) or 0
        if delay > 0 then
            scheduleEvent(function() startShake(data.strength, data.ms) end, math.min(delay, 5000))
        else
            startShake(data.strength, data.ms)
        end
    elseif data.type == 'meteors' then
        startMeteors(data.seconds, data.count, data.big == true)
    end
end

local function onGameEnd()
    clearAll()
    clearMeteors()
    stopShake()
end

local function compileShaders()
    local code = g_resources.readFileContents(DIR .. 'shadow.frag')
    g_shaders.createFragmentShaderFromCode(FLY_SHADOW, (code:gsub('ALPHA', '0.5')))
    g_shaders.setupOutfitShader(FLY_SHADOW)
    g_shaders.createFragmentShaderFromCode(DIVE_SHADOW, (code:gsub('ALPHA', '0.55')))
    g_shaders.setupOutfitShader(DIVE_SHADOW)
end

-- for tests and the screenshots: a flight as if the server sent it
function showFlight(data)
    startFlight(data)
end

function showMeteors(seconds, total, big)
    startMeteors(seconds, total, big)
end

function count()
    local n = 0
    for _ in pairs(flights) do
        n = n + 1
    end
    return n
end

function init()
    g_ui.importStyle('legendaryflight')
    compileShaders()
    ProtocolGame.registerExtendedOpcode(ExtendedIds.LegendaryFlight, onMessage)
    connect(g_game, { onGameEnd = onGameEnd })
end

function terminate()
    ProtocolGame.unregisterExtendedOpcode(ExtendedIds.LegendaryFlight)
    disconnect(g_game, { onGameEnd = onGameEnd })
    clearAll()
    clearMeteors()
    stopShake()
end
