-- Warp Styles on the map (docs/upcoming-features.md, section 28). The server (systems/102-warpStyles.lua)
-- sends ExtendedIds.WarpStyles JSON to the trainers who can see it:
--   {type = "play", c = creature, s = style, h = "out" | "in" | "fx", t = trigger, p = {x, y, z}, o = outfit, d = direction}
--   {type = "state", open, styles = {{id, name, kind, owned, how}}, triggers = {{id, name, kind, default, style}}}
-- "out" plays where a trainer leaves (a copy of their look, since they are gone at once), "in" where they
-- arrive (the trainer is hidden until the reveal), "fx" on a trainer who stays (Victory, Defeat).
-- Options > Interface > Warp styles: Everyone, Only mine (the defaults for everyone else) or Off (the
-- server sends the plain effects). The same animations play on the Warp Styles window's stage (window.lua).
local IMAGES = '/modules/game_warpfx/images/'
local SHADERS = '/modules/game_warpfx/shaders/'
local TICK = 30
local HIDDEN, WHITE, GREY = 'Warp - hidden', 'Warp - white', 'Warp - grey'
local SHADER_FILES = { [HIDDEN] = 'hidden', [WHITE] = 'white', [GREY] = 'grey' }
local SHADER_RANK = { [HIDDEN] = 3, [WHITE] = 2, [GREY] = 1 }
local SPIN = { 2, 1, 0, 3 } -- south, east, north, west: a turn on the spot
local CONFETTI, SPARKLES, DROPS, STARS = 14, 5, 6, 3

DEFAULTS = { login = 'spin', logout = 'spin', teleport = 'spin', victory = 'victory', defeat = 'defeat', faint = 'faint' }
LENGTHS = {
    spin = { out = 1100, ['in'] = 1000 },
    beam = { out = 1100, ['in'] = 1100 },
    victory = { fx = 1700 },
    defeat = { fx = 2300 },
    faint = { out = 1500 },
    gap = { hide = 0 }, -- the window's stage between two halves: the trainer stays hidden
}

local plays = {}
local applied = {} -- [key] = { creature, shader } the shaders this module put on real creatures
local tickEvent
local compiled = false

local function mapPanel()
    return modules.game_interface and modules.game_interface.getMapPanel()
end

function getMode()
    local options = modules.client_options
    local value = options and options.getOption and options.getOption('warpStyles')
    return (value == 'mine' or value == 'off') and value or 'all'
end

local function compileShaders()
    if compiled then
        return
    end
    compiled = true
    for name, file in pairs(SHADER_FILES) do
        g_shaders.createFragmentShaderFromCode(name, g_resources.readFileContents(SHADERS .. file .. '.frag'))
        g_shaders.setupOutfitShader(name)
    end
end

local function clamp(v)
    return math.max(0, math.min(1, v))
end

-- 0 to 1 from a to b
local function span(ms, a, b)
    return clamp((ms - a) / (b - a))
end

-- 1 inside [a, b], fading in over fadeIn ms and out over fadeOut ms
local function window(ms, a, b, fadeIn, fadeOut)
    if ms < a or ms > b then
        return 0
    end
    return clamp(math.min((ms - a) / math.max(1, fadeIn), (b - ms) / math.max(1, fadeOut)))
end

local function samePos(a, b)
    return a and b and a.x == b.x and a.y == b.y and a.z == b.z
end

-- Widgets -------------------------------------------------------------------------------------

local function image(play, name)
    local widget = g_ui.createWidget('WarpFxImage', play.host.parent)
    widget:setImageSource(IMAGES .. name)
    widget:hide()
    table.insert(play.widgets, widget)
    return widget
end

local function images(play, count, name)
    local list = {}
    for i = 1, count do
        list[i] = image(play, type(name) == 'function' and name(i) or name)
    end
    return list
end

local function put(widget, x, y, width, height, opacity)
    if opacity <= 0.01 then
        widget:hide()
        return
    end
    width, height = math.max(1, math.floor(width)), math.max(1, math.floor(height))
    widget:setRect({ x = math.floor(x - width / 2), y = math.floor(y - height / 2), width = width, height = height })
    widget:setOpacity(clamp(opacity))
    widget:show()
    widget:raise()
end

-- A copy of the trainer: they are gone (out) or hidden (in, fx) while it plays
local function copy(play, parent)
    local widget = g_ui.createWidget('WarpFxCreature', parent or play.host.parent)
    widget:setOutfit(play.outfit)
    widget:setDirection(play.dir)
    local creature = widget:getCreature()
    if creature and creature.setDrawFullFrame then
        creature:setDrawFullFrame(true)
    end
    local frame = creature and (creature.getFullFrameSize and creature:getFullFrameSize() or creature:getExactSize())
    play.frame = math.max(32, math.min(128, tonumber(frame) or 64))
    -- the map draws an outfit its displacement up and left of the tile, a widget as far down and right
    local thing = not play.host.widgets and g_things.getThingType(play.outfit.type or 0, ThingCategoryCreature)
    local shift = thing and thing:getDisplacement()
    play.shift = { x = shift and 2 * shift.x or 0, y = shift and 2 * shift.y or 0 }
    widget:hide()
    table.insert(play.widgets, widget)
    return widget
end

-- The copy's rect: the sprite stands on the tile's bottom right; sx, sy scale it around the feet
local function copyRect(play, a, sx, sy, lift)
    local size = play.frame * a.tile / 32
    local shift = play.shift or { x = 0, y = 0 }
    sx, sy = sx or 1, sy or 1
    return { x = math.floor(a.x - (size - a.tile / 2) * sx - shift.x * a.tile / 32),
             y = math.floor(a.y - (lift or 0) - size * sy - shift.y * a.tile / 32),
             width = math.max(1, math.floor(size * sx)), height = math.max(1, math.floor(size * sy)) }
end

local function putCopy(play, widget, a, o)
    local opacity = o.opacity or 1
    if opacity <= 0.01 or (o.sx or 1) <= 0.02 or (o.sy or 1) <= 0.02 then
        widget:hide()
        return
    end
    widget:setRect(copyRect(play, a, o.sx, o.sy, o.lift))
    if o.dir then
        widget:setDirection(o.dir)
    end
    widget:setOpacity(clamp(opacity))
    widget:show()
    widget:raise()
end

-- The outfit's colours are drawn over the shader, so a shaded trainer goes without them
local function shade(creature, name)
    creature:setShader(name or '')
    creature:setDrawOutfitColor(not name)
end

local function copyShader(widget, name)
    local creature = widget:getCreature()
    if creature and widget.shaderName ~= name then
        shade(creature, name)
        widget.shaderName = name
    end
end

local function spinDir(play, steps)
    local start = 1
    for i, dir in ipairs(SPIN) do
        if dir == play.dir then
            start = i
        end
    end
    return SPIN[(start - 1 + steps) % 4 + 1]
end

-- Little stars drifting up and out from (x, y) between from and to
local function drift(list, ms, from, to, x, y, tile, rise)
    for i, sparkle in ipairs(list) do
        local u = span(ms, from + (i - 1) * 40, to)
        local angle = i * 2.4
        put(sparkle, x + math.cos(angle) * tile * (0.25 + 0.35 * u), y - tile * rise * u + math.sin(angle) * tile * 0.15,
            tile * 0.32 * (1 - 0.5 * u), tile * 0.32 * (1 - 0.5 * u), u > 0 and (1 - u) or 0)
    end
end

-- The styles: build makes the widgets, draw places them each tick and returns the shader for the real trainer

local STYLES = {}

STYLES.spin = {
    build = function(play)
        local w = play.w
        w.pad = image(play, 'pad')
        w.streak = image(play, 'streak')
        w.copy = copy(play)
        w.sparkles = images(play, SPARKLES, 'sparkle')
    end,
    out = function(play, a, ms)
        local w, tile = play.w, a.tile
        put(w.pad, a.x, a.y - tile * 0.12, tile * 1.3, tile * 0.5, window(ms, 0, 1100, 150, 250) * 0.9)
        local u = span(ms, 600, 850)
        putCopy(play, w.copy, a, { dir = spinDir(play, math.floor((math.min(ms, 850) / 850) ^ 2 * 14)),
            sx = 1 - 0.8 * u, sy = 1 + 0.7 * u, lift = tile * 1.2 * u * u, opacity = 1 - u })
        local v = span(ms, 600, 1100)
        put(w.streak, a.x, a.y - tile * 1.2 - v * tile * 3, tile * 0.6 * (1 - 0.5 * v), tile * 3.2, ms >= 600 and (1 - v) or 0)
        drift(w.sparkles, ms, 650, 1100, a.x, a.y - tile * 0.5, tile, 1.4)
        return HIDDEN
    end,
    ['in'] = function(play, a, ms)
        local w, tile = play.w, a.tile
        put(w.streak, a.x, a.y - tile * 1.2 - (1 - span(ms, 0, 320)) * tile * 3.5, tile * 0.6, tile * 3.2,
            window(ms, 0, 480, 80, 160))
        put(w.pad, a.x, a.y - tile * 0.12, tile * 1.3, tile * 0.5, window(ms, 200, 1000, 120, 300) * 0.9)
        if ms >= 280 then
            local u = span(ms, 280, 480)
            local v = span(ms, 280, 1000)
            putCopy(play, w.copy, a, { dir = spinDir(play, -math.floor((1 - v) ^ 2 * 14)),
                sx = 0.2 + 0.8 * u, sy = 1.7 - 0.7 * u, lift = tile * 0.8 * (1 - u) ^ 2, opacity = u })
        else
            w.copy:hide()
        end
        drift(w.sparkles, ms, 300, 800, a.x, a.y - tile * 0.4, tile, 0.9)
        return HIDDEN
    end,
}

-- Beam: the trainer is scanned away from the feet up in a column of gold light, and built back from the feet
local function beamDraw(play, a, ms, arriving)
    local w, tile = play.w, a.tile
    put(w.beam, a.x, a.y - tile * 1.25, tile * 1.1, tile * 2.7, window(ms, 0, 1100, 200, 300) * 0.9)
    local u = span(ms, arriving and 200 or 250, arriving and 850 or 900)
    local top = a.y - tile * 1.7
    local scanY = a.y + tile * 0.1 - u * (tile * 1.8)
    local rect = copyRect(play, a)
    local clipTop, clipBottom
    if arriving then
        clipTop, clipBottom = math.floor(scanY), math.floor(a.y + tile * 0.25)
    else
        clipTop, clipBottom = math.floor(math.min(rect.y, top)), math.floor(scanY)
    end
    if clipBottom - clipTop >= 1 then
        w.clip:setRect({ x = rect.x - 2, y = clipTop, width = rect.width + 4, height = clipBottom - clipTop })
        w.clip:show()
        w.clip:raise()
        putCopy(play, w.copy, a, { opacity = 0.85 + 0.15 * math.sin(ms / 40) })
    else
        w.clip:hide()
    end
    put(w.scan, a.x, scanY, tile * 1.25, math.max(3, tile * 0.12), (u > 0 and u < 1) and 1 or 0)
    drift(w.sparkles, ms, 250, 1100, a.x, a.y - tile * 0.6, tile, 1.6)
    return HIDDEN
end

STYLES.beam = {
    build = function(play)
        local w = play.w
        w.beam = image(play, 'beam')
        w.clip = g_ui.createWidget('WarpFxClip', play.host.parent)
        w.clip:hide()
        table.insert(play.widgets, w.clip)
        w.copy = copy(play, w.clip)
        w.scan = image(play, 'scanline')
        w.sparkles = images(play, SPARKLES, 'sparkle')
    end,
    out = function(play, a, ms) return beamDraw(play, a, ms, false) end,
    ['in'] = function(play, a, ms) return beamDraw(play, a, ms, true) end,
}

STYLES.victory = {
    build = function(play)
        local w = play.w
        w.burst = image(play, 'burst')
        w.copy = copy(play)
        w.confetti = images(play, CONFETTI, function(i) return 'confetti-' .. ((i - 1) % 4) end)
        w.glint = image(play, 'glint')
    end,
    fx = function(play, a, ms)
        local w, tile = play.w, a.tile
        local body, head = a.y - tile * 0.6, a.y - tile * 1.1
        w.burst:setRotation(ms * 0.05)
        put(w.burst, a.x, body, tile * (1.2 + 1.6 * span(ms, 150, 1000)), tile * (1.2 + 1.6 * span(ms, 150, 1000)),
            window(ms, 150, 1000, 100, 450))
        local lift = ms < 900 and math.abs(math.sin(ms / 450 * math.pi)) * tile * 0.4 or 0
        putCopy(play, w.copy, a, { dir = Directions.South, lift = lift })
        for i, piece in ipairs(w.confetti) do
            local u = span(ms, 200, 1400)
            local angle = math.pi * (0.15 + 0.7 * (i - 1) / (CONFETTI - 1))
            local speed = 1.3 + 0.5 * ((i * 7) % 5) / 4
            piece:setRotation(ms * (0.3 + i * 0.04))
            put(piece, a.x + math.cos(angle) * tile * 1.5 * speed * u,
                head - math.sin(angle) * tile * 2 * speed * u + tile * 3.2 * u * u,
                tile * 0.22, tile * 0.22, (ms >= 200 and u < 1) and (1 - u ^ 3) or 0)
        end
        w.glint:setRotation(ms * 0.12)
        local beat = 1 + 0.15 * math.sin(ms / 70)
        put(w.glint, a.x, a.y - tile * 1.65, tile * 0.7 * beat, tile * 0.7 * beat, window(ms, 700, 1650, 150, 300))
        return HIDDEN
    end,
}

STYLES.defeat = {
    build = function(play)
        local w = play.w
        w.drops = images(play, DROPS, 'drop')
        w.cloud = image(play, 'cloud')
        w.stars = images(play, STARS, 'star')
    end,
    fx = function(play, a, ms)
        local w, tile = play.w, a.tile
        local shown = window(ms, 0, 2300, 250, 400)
        local cloudY = a.y - tile * 1.95 + math.sin(ms / 300) * tile * 0.04
        put(w.cloud, a.x, cloudY, tile * 1.1, tile * 0.55, shown)
        for i, drop in ipairs(w.drops) do
            local u = ((ms + i * 75) % 450) / 450
            put(drop, a.x + (i - (DROPS + 1) / 2) * tile * 0.14, cloudY + tile * 0.15 + u * tile * 0.9, tile * 0.08,
                tile * 0.2, ms > 250 and shown * (1 - u) or 0)
        end
        for i, star in ipairs(w.stars) do
            local angle = ms / 260 + (i - 1) * 2 * math.pi / STARS
            put(star, a.x + math.cos(angle) * tile * 0.32, a.y - tile * 1.25 + math.sin(angle) * tile * 0.1,
                tile * 0.3, tile * 0.3, shown)
        end
        return GREY
    end,
}

STYLES.faint = {
    build = function(play)
        local w = play.w
        w.copy = copy(play)
        w.orb = image(play, 'orb')
        w.sparkles = images(play, SPARKLES, 'sparkle')
    end,
    out = function(play, a, ms)
        local w, tile = play.w, a.tile
        local body = a.y - tile * 0.5
        local u = span(ms, 350, 800)
        copyShader(w.copy, (ms >= 350 or math.floor(ms / 70) % 2 == 0) and WHITE or nil)
        putCopy(play, w.copy, a, { sx = 1 - u, sy = 1 - u, lift = tile * 0.5 * u, opacity = 1 - 0.5 * u })
        local rise = span(ms, 800, 1500)
        local beat = 1 + 0.12 * math.sin(ms / 60)
        local size = tile * (0.4 + 0.6 * span(ms, 450, 800)) * beat
        put(w.orb, a.x, body - rise * tile * 1.6, size, size, window(ms, 450, 1500, 100, 500))
        drift(w.sparkles, ms, 800, 1500, a.x, body - rise * tile * 1.6, tile, 0.6)
        return HIDDEN
    end,
}

STYLES.gap = {
    build = function() end,
    hide = function() return HIDDEN end,
}

-- Plays ---------------------------------------------------------------------------------------

local function destroy(index)
    local play = plays[index]
    for _, widget in ipairs(play.widgets) do
        if not widget:isDestroyed() then
            widget:destroy()
        end
    end
    table.remove(plays, index)
end

-- Puts the strongest wanted shader on each real trainer, every tick (the engine can drop it when the
-- trainer's look is sent again), and takes this module's shaders off the rest
local function applyShaders(wanted)
    for key, entry in pairs(applied) do
        local want = wanted[key]
        if not want or want.creature:getId() ~= entry.creature:getId() then
            shade(entry.creature, nil)
            applied[key] = nil
        end
    end
    for key, want in pairs(wanted) do
        shade(want.creature, want.shader)
        applied[key] = want
    end
end

local function clearAll()
    for i = #plays, 1, -1 do
        destroy(i)
    end
    applyShaders({})
    removeEvent(tickEvent)
    tickEvent = nil
end

local function update()
    local now = g_clock.millis()
    local wanted = {}
    for i = #plays, 1, -1 do
        local play = plays[i]
        local ms = now - play.startAt
        if ms >= play.length or play.host.parent:isDestroyed() then
            destroy(i)
        else
            local a = ms >= 0 and play.host.anchor(play)
            local shader
            if a then
                shader = STYLES[play.style][play.half](play, a, ms)
            else
                for _, widget in ipairs(play.widgets) do
                    widget:hide()
                end
                shader = ms < 0 and HIDDEN or nil
            end
            local real = shader and play.host.real(play)
            if real then
                local current = wanted[play.key]
                if not current or SHADER_RANK[shader] > SHADER_RANK[current.shader] then
                    wanted[play.key] = { creature = real, shader = shader }
                end
            end
        end
    end
    applyShaders(wanted)
    if #plays == 0 then
        removeEvent(tickEvent)
        tickEvent = nil
    end
end

-- spec: host = {parent, anchor(play) -> {x, y = the feet, tile} or nil, real(play) -> creature or nil,
-- widgets = true when the real trainer is a UICreature too},
-- key (one play per key, except an arrival waiting for a departure), style, half, outfit, dir, pos, length
function playOn(spec)
    local style = STYLES[spec.style]
    local length = spec.length or (LENGTHS[spec.style] and LENGTHS[spec.style][spec.half])
    if not style or not style[spec.half] or not length or not spec.host or not spec.host.parent then
        return nil
    end
    compileShaders()
    local now = g_clock.millis()
    local delay = 0
    for i = #plays, 1, -1 do
        local other = plays[i]
        if other.key == spec.key then
            if other.half == 'out' and spec.half == 'in' then
                if samePos(other.pos, spec.pos) then
                    delay = math.max(delay, other.length - (now - other.startAt))
                end
            else
                destroy(i)
            end
        end
    end
    local play = { host = spec.host, key = spec.key, id = spec.id, style = spec.style, half = spec.half,
                   pos = spec.pos, outfit = spec.outfit or { type = 0 }, dir = spec.dir or Directions.South,
                   follow = spec.half == 'fx', length = length + delay, startAt = now + delay, widgets = {}, w = {},
                   frame = 64 }
    style.build(play)
    table.insert(plays, play)
    if not tickEvent then
        tickEvent = cycleEvent(update, TICK)
    end
    update()
    return play
end

function stopKey(key)
    for i = #plays, 1, -1 do
        if plays[i].key == key then
            destroy(i)
        end
    end
    update()
end

-- The map ---------------------------------------------------------------------------------------

local function mapAnchor(play)
    local map = mapPanel()
    local camera = map and map:getCameraPosition()
    local pos = play.pos
    if play.follow then
        local creature = g_map.getCreatureById(play.id)
        pos = creature and creature:getPosition() or pos
    end
    if not camera or not pos or pos.z ~= camera.z then
        return nil
    end
    local rect = map:getTileRect(pos)
    if not rect or rect.width == 0 then
        return nil
    end
    return { x = rect.x + rect.width / 2, y = rect.y + rect.height, tile = rect.width }
end

-- the trainer on the map; a departure only hides them while they still stand where they leave from
local function mapReal(play)
    local creature = g_map.getCreatureById(play.id)
    if creature and play.half == 'out' and not samePos(creature:getPosition(), play.pos) then
        return nil
    end
    return creature
end

local mapHost

local function toOutfit(o, creature)
    if type(o) == 'table' and tonumber(o.type) then
        return { type = tonumber(o.type), head = tonumber(o.head) or 0, body = tonumber(o.body) or 0,
                 legs = tonumber(o.legs) or 0, feet = tonumber(o.feet) or 0, addons = tonumber(o.addons) or 0 }
    end
    return creature and creature:getOutfit() or { type = 0 }
end

-- Plays a message the server sent; also for tests
function play(data)
    local mode = getMode()
    local map = mapPanel()
    local id = tonumber(data and data.c)
    local pos = data and data.p
    if mode == 'off' or not map or not g_game.isOnline() or not id or type(pos) ~= 'table' then
        return false
    end
    local style = data.s
    local player = g_game.getLocalPlayer()
    if mode == 'mine' and (not player or player:getId() ~= id) then
        style = DEFAULTS[data.t] or style
    end
    if not (STYLES[style] and STYLES[style][data.h]) then
        style = DEFAULTS[data.t]
    end
    if not (style and STYLES[style] and STYLES[style][data.h]) then
        return false
    end
    if not mapHost or mapHost.parent ~= map then
        mapHost = { parent = map, anchor = mapAnchor, real = mapReal }
    end
    local creature = g_map.getCreatureById(id)
    return playOn({ host = mapHost, key = id, id = id, style = style, half = data.h,
                    pos = { x = tonumber(pos.x) or 0, y = tonumber(pos.y) or 0, z = tonumber(pos.z) or 0 },
                    outfit = toOutfit(data.o, creature), dir = tonumber(data.d) }) ~= nil
end

function count()
    return #plays
end

local function send(message)
    local protocol = g_game.getProtocolGame()
    if protocol and g_game.isOnline() then
        protocol:sendExtendedJSONOpcode(ExtendedIds.WarpStyles, message)
    end
end

-- also when the option changes (client_options)
function refresh()
    send({ action = 'hello', fx = getMode() ~= 'off' })
end

function openWindow()
    send({ action = 'open' })
end

function equip(trigger, style)
    send({ action = 'equip', trigger = trigger, style = style })
end

local function onMessage(protocol, opcode, buffer)
    local ok, data = pcall(json.decode, buffer)
    if not ok or type(data) ~= 'table' then
        g_logger.warning('WarpStyles: invalid message')
        return
    end
    if data.type == 'play' then
        play(data)
    elseif data.type == 'state' then
        for _, trigger in ipairs(data.triggers or {}) do
            if type(trigger) == 'table' and trigger.id and trigger.default then
                DEFAULTS[trigger.id] = trigger.default
            end
        end
        WarpWindow.onState(data)
    end
end

local function onGameStart()
    refresh()
end

local function onGameEnd()
    clearAll()
    mapHost = nil
    WarpWindow.close()
end

function init()
    g_ui.importStyle('warpfx')
    ProtocolGame.registerExtendedOpcode(ExtendedIds.WarpStyles, onMessage)
    connect(g_game, { onGameStart = onGameStart, onGameEnd = onGameEnd })
    if g_game.isOnline() then
        onGameStart()
    end
end

function terminate()
    ProtocolGame.unregisterExtendedOpcode(ExtendedIds.WarpStyles)
    disconnect(g_game, { onGameStart = onGameStart, onGameEnd = onGameEnd })
    onGameEnd()
end
