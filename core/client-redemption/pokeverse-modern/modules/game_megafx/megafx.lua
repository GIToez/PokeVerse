-- The Mega Evolution animation on the map (docs/upcoming-features.md, "The animation"). The server
-- (097-megaEvolution.lua) sends it on ExtendedIds.Mega to the players around, through game_pokehud/mega.lua:
--   {type = "fx", phase = "evolve", pokemon, trainer, form, look, number, ms}  ms until the burst
--   {type = "fx", phase = "end", pokemon}
-- Evolve: the Key Stone sparkles on the trainer, streams of light run to the Pokemon and its stone glows,
-- the Pokemon becomes a white cocoon (game_creaturefx) in a swirling orb that pulses faster, and at the
-- burst the orb breaks into rainbow shards, the Mega symbol shows above it, the map shakes and it cries.
-- The server changes the look at the burst. End: the Pokemon flashes white once. Drawn over the map,
-- sized to the zoom; nothing is blocked. With "Pokemon effects" off only the server's sparkle shows.
local IMAGES = '/modules/game_megafx/images/'
local TICK = 30
local ORB_FRAMES = 4
local STREAMS = 10
local SHARDS = 12
local SHARD_IMAGES = 6
local BURST_SHOW_MS = 600
local SHAKE_MS = 320
local END_FLASH_MS = 240

local plays = {} -- [pokemonId] = { data, startedAt, burstAt, widgets, cocoon, burst }
local tickEvent
local shake = { event = nil, active = false, left = 0, top = 0 }

local function mapPanel()
    return modules.game_interface and modules.game_interface.getMapPanel()
end

local function effectsOn()
    local options = modules.client_options
    local value = options and options.getOption and options.getOption('pokemonEffects')
    return value ~= false
end

local function newImage(image)
    local widget = g_ui.createWidget('MegaFxImage', mapPanel())
    widget:setImageSource(IMAGES .. image)
    widget:hide()
    return widget
end

local function place(widget, x, y, size, opacity)
    size = math.max(1, math.floor(size))
    widget:setRect({ x = math.floor(x - size / 2), y = math.floor(y - size / 2), width = size, height = size })
    widget:setOpacity(math.max(0, math.min(1, opacity or 1)))
    widget:show()
    widget:raise()
end

-- Where a creature is drawn: the centre of its sprite (big sprites stand on their tile's bottom right and
-- reach up and left), the tile size and the sprite size on the screen; nil when it isn't on this floor
local function centreOf(map, creatureId)
    local creature = creatureId and g_map.getCreatureById(creatureId)
    local camera = map:getCameraPosition()
    local pos = creature and creature:getPosition()
    if not pos or not camera or pos.z ~= camera.z then
        return nil
    end
    local rect = map:getTileRect(pos)
    if not rect or rect.width == 0 then
        return nil
    end
    local size = math.max(32, creature:getExactSize() or 32) * rect.width / 32
    return { x = rect.x + rect.width - size / 2, y = rect.y + rect.height - size / 2, tile = rect.width, size = size }
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

local function startShake()
    local map = mapPanel()
    if not map then
        return
    end
    if not shake.active then
        shake.left, shake.top = map:getMarginLeft(), map:getMarginTop()
        shake.active = true
    end
    removeEvent(shake.event)
    local started = g_clock.millis()
    shake.event = cycleEvent(function()
        local t = g_clock.millis() - started
        if t >= SHAKE_MS or not g_game.isOnline() then
            stopShake()
            return
        end
        local a = math.floor(3 * (1 - t / SHAKE_MS) + 0.5)
        map:setMarginLeft(shake.left + math.random(-a, a))
        map:setMarginTop(shake.top + math.random(-a, a))
    end, 40)
end

local function setCocoon(pokemonId, ms)
    local fx = modules.game_creaturefx
    if fx and fx.setCocoon then
        fx.setCocoon(pokemonId, ms)
    end
end

local function destroyPlay(id)
    local play = plays[id]
    if not play then
        return
    end
    for _, widget in pairs(play.widgets) do
        if type(widget) == 'table' then
            for _, part in ipairs(widget) do
                part:destroy()
            end
        else
            widget:destroy()
        end
    end
    plays[id] = nil
end

local function clearAll()
    for id in pairs(plays) do
        destroyPlay(id)
    end
    removeEvent(tickEvent)
    tickEvent = nil
    stopShake()
end

local function hideAll(play)
    for _, widget in pairs(play.widgets) do
        if type(widget) == 'table' then
            for _, part in ipairs(widget) do
                part:hide()
            end
        else
            widget:hide()
        end
    end
end

local function updateEvolve(play, map, ms)
    local data, w = play.data, play.widgets
    local burstAt = play.burstAt
    local keyEnd, streamsEnd, cocoonAt = burstAt * 0.22, burstAt * 0.55, burstAt * 0.55
    local pokemon = centreOf(map, data.pokemon)
    local trainer = centreOf(map, data.trainer) or pokemon
    hideAll(play)
    if not pokemon then
        return
    end
    local tile = pokemon.tile

    -- the Key Stone
    if ms < keyEnd then
        local u = ms / keyEnd
        local opacity = u < 0.25 and u / 0.25 or (u > 0.75 and (1 - u) / 0.25 or 1)
        place(w.spark, trainer.x, trainer.y - tile * 0.4, tile * (1.1 + 0.5 * math.sin(u * math.pi)), opacity)
    end

    -- the streams and the stone's glow
    if ms >= keyEnd and ms < streamsEnd + 200 then
        local span = (streamsEnd - keyEnd) * 0.6
        for i, stream in ipairs(w.streams) do
            local start = keyEnd + (i - 1) * (streamsEnd - keyEnd - span) / STREAMS
            local u = (ms - start) / span
            if u >= 0 and u <= 1 then
                local dx, dy = pokemon.x - trainer.x, pokemon.y - trainer.y
                local length = math.max(1, math.sqrt(dx * dx + dy * dy))
                local bend = math.sin(u * math.pi) * tile * 0.7 * (i % 2 == 0 and 1 or -1)
                place(stream, trainer.x + dx * u - dy / length * bend, trainer.y + dy * u + dx / length * bend,
                      tile * 0.8, 1 - 0.3 * u)
            end
        end
    end
    if ms >= keyEnd and ms < burstAt then
        local u = (ms - keyEnd) / (burstAt - keyEnd)
        place(w.glow, pokemon.x, pokemon.y + pokemon.size * 0.15, tile * (0.7 + 1.1 * u), 0.55 + 0.35 * u)
    end

    -- the cocoon in its orb, pulsing faster up to the burst
    if ms >= cocoonAt and ms < burstAt then
        if not play.cocoon then
            play.cocoon = true
            setCocoon(data.pokemon, burstAt - ms + 120)
        end
        local u = (ms - cocoonAt) / (burstAt - cocoonAt)
        local turns = u * u * 10
        local frame = math.floor(turns * ORB_FRAMES) % ORB_FRAMES + 1
        local beat = 0.5 + 0.5 * math.sin(turns * 2 * math.pi)
        local size = tile * 3 * (0.88 + 0.12 * beat) * (0.6 + 0.4 * math.min(1, u * 4))
        place(w.orbs[frame], pokemon.x, pokemon.y, size, 0.75 + 0.25 * beat)
    end

    -- the burst
    if ms >= burstAt then
        if not play.burst then
            play.burst = true
            startShake()
            local sounds = modules.game_sounds
            if data.number and sounds and sounds.playVoiceCry then
                sounds.playVoiceCry(data.number)
            end
        end
        local u = (ms - burstAt) / BURST_SHOW_MS
        for i, piece in ipairs(w.shards) do
            local angle = (i - 1) * 2 * math.pi / SHARDS + 0.3
            local reach = tile * (0.6 + 2.2 * u)
            place(piece, pokemon.x + math.cos(angle) * reach, pokemon.y + math.sin(angle) * reach * 0.8,
                  tile * 0.5 * (1 - 0.4 * u), 1 - u)
        end
        local fade = u < 0.2 and u / 0.2 or (u > 0.7 and (1 - u) / 0.3 or 1)
        place(w.symbol, pokemon.x, pokemon.y - pokemon.size * 0.55 - tile * 0.35 * u, tile * 1.1, fade)
        place(w.burstGlow, pokemon.x, pokemon.y, tile * (2.4 + 1.6 * u), (1 - u) * 0.9)
    end
end

local function updateEnd(play, map, ms)
    local pokemon = centreOf(map, play.data.pokemon)
    hideAll(play)
    if pokemon then
        local u = ms / END_FLASH_MS
        place(play.widgets.spark, pokemon.x, pokemon.y, pokemon.tile * (1 + u), 1 - u)
    end
end

local function update()
    local map = mapPanel()
    if not map or not g_game.isOnline() then
        clearAll()
        return
    end
    local now = g_clock.millis()
    for id, play in pairs(plays) do
        local ms = now - play.startedAt
        if ms >= play.length then
            destroyPlay(id)
        elseif play.data.phase == 'end' then
            updateEnd(play, map, ms)
        else
            updateEvolve(play, map, ms)
        end
    end
    if next(plays) == nil then
        removeEvent(tickEvent)
        tickEvent = nil
    end
end

local function newPlay(data)
    local widgets = { spark = newImage('spark') }
    local length = END_FLASH_MS
    if data.phase == 'evolve' then
        widgets.glow = newImage('stone-glow')
        widgets.burstGlow = newImage('stone-glow')
        widgets.symbol = newImage('symbol')
        widgets.streams, widgets.orbs, widgets.shards = {}, {}, {}
        for i = 1, STREAMS do
            widgets.streams[i] = newImage('stream')
        end
        for i = 1, ORB_FRAMES do
            widgets.orbs[i] = newImage('orb-' .. (i - 1))
        end
        for i = 1, SHARDS do
            widgets.shards[i] = newImage('shard-' .. ((i - 1) % SHARD_IMAGES))
            widgets.shards[i]:setRotation((i - 1) * 360 / SHARDS)
        end
        length = data.ms + BURST_SHOW_MS
    end
    return { data = data, startedAt = g_clock.millis(), burstAt = data.ms, length = length, widgets = widgets }
end

-- Plays an animation the server sent (game_pokehud/mega.lua passes it on); also for tests and screenshots
function play(data)
    local id = tonumber(data and data.pokemon)
    if not id or not mapPanel() or not g_game.isOnline() then
        return false
    end
    data.pokemon = id
    data.trainer = tonumber(data.trainer)
    data.ms = math.max(300, math.min(5000, tonumber(data.ms) or 1800))
    destroyPlay(id)
    if not effectsOn() then
        return false
    end
    if data.phase == 'end' then
        setCocoon(id, END_FLASH_MS)
    elseif data.phase ~= 'evolve' then
        return false
    end
    plays[id] = newPlay(data)
    if not tickEvent then
        tickEvent = cycleEvent(update, TICK)
    end
    update()
    return true
end

function count()
    local n = 0
    for _ in pairs(plays) do
        n = n + 1
    end
    return n
end

function init()
    g_ui.importStyle('megafx')
    connect(g_game, { onGameEnd = clearAll })
end

function terminate()
    disconnect(g_game, { onGameEnd = clearAll })
    clearAll()
end
