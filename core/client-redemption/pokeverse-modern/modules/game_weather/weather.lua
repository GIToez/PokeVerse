-- The weather where the trainer stands. The server (079-weather.lua) sends ExtendedIds.Weather JSON
-- {type = "weather", zone, kind, name, endsAt, moves, ...} at login and whenever it changes there; it
-- also dims or tints the day and night light itself. This module draws the weather on the map (a map
-- shader, only where the sky is open over the trainer), flashes lightning, plays the weather sounds
-- and shows the badge beside the clock. Options: weatherEffects, weatherLight (fewer drops and flakes),
-- weatherSounds, weatherLightning, and visualStyle (off, vibrant, toon), which the same map shader
-- draws everywhere, under a roof and underground too. areaMoods adds the area's mood to it: a purple
-- haze in Lavender Town (thinner under weather), and caves on the surface floors dark but for a circle
-- around the trainer, wider with the Flashlight or a Pokemon using Flash (the engine already darkens
-- the floors below the surface). The server sends {type = "light", flashlight, pokemon} for that.
local badge, flash
local current -- the last "weather" message
local offset = 0 -- server clock - local clock
local shaders = {} -- [kind .. strength] = registered
local activeShader
local outdoors = false
local loopChannel, loopFile
local lit = { flashlight = false, pokemon = 0 }
local moodKey = ''
local lightningEvent, flashEvent, checkEvent, placeEvent, matchupEvent

local DIR = '/modules/game_weather/'
local SHADER_FADE = 1.5
local SOUND_FADE = 2
-- the map texture's v runs up the screen, so things fall toward smaller v
local FALL = '-1.0'
local KINDS_WITH_SHADER = { rain = true, thunderstorm = true, snow = true, hail = true, fog = true, sandstorm = true,
                            windy = true, sunny = true }
local LOOPS = { rain = 'rain_01', thunderstorm = 'rain_01', windy = 'wind_low_01', sandstorm = 'wind_high_01',
                hail = 'wind_low_01' }
local STYLES = { 'vibrant', 'toon' }
local STYLE_LEVELS = { off = 0, vibrant = 1, toon = 2 }
local CAVE_THEMES = { cave = true, volcano = true, mountain = true }
local NO_MOOD = { name = '', MOOD = '0.0', HAZE = '0.0', RADIUS = '0.0', CAVEFLOOR = '1.0', MAPW = '1.0', MAPH = '1.0' }
local ELEMENT_NAMES = { [0] = 'Normal', 'Fighting', 'Flying', 'Poison', 'Ground', 'Rock', 'Bug', 'Ghost', 'Steel', 'Fire',
                        'Water', 'Grass', 'Electric', 'Psychic', 'Ice', 'Dragon', 'Dark', 'Fairy' }

local function option(name, default)
    local options = modules.client_options
    local value = options and options.getOption and options.getOption(name)
    if value == nil then
        return default
    end
    return value
end

-- 0 off, 1 light, 2 full
local function effectsLevel()
    if not option('weatherEffects', true) then
        return 0
    end
    return option('weatherLight', false) and 1 or 2
end

-- 0 off, 1 vibrant, 2 toon
local function visualStyle()
    return STYLE_LEVELS[option('visualStyle', 'off')] or 0
end

local function send(data)
    local protocol = g_game.getProtocolGame()
    if protocol and g_game.isOnline() then
        protocol:sendExtendedJSONOpcode(ExtendedIds.Weather, data)
    end
end

function getCurrent()
    return current
end

function getKind()
    return current and current.kind or 'clear'
end

-- open sky over a spot: on the surface, no floor straight above it, and no roof drawn over it on the
-- floor just above (higher floors drawn over it are a tall building beside it, not a roof)
local function isOutdoors(pos)
    if not pos or pos.z > 7 then
        return false
    end
    for z = pos.z - 1, 0, -1 do
        local spots = { { x = pos.x, y = pos.y } }
        if z == pos.z - 1 then
            spots[2] = { x = pos.x + 1, y = pos.y + 1 }
        end
        for _, spot in ipairs(spots) do
            local tile = g_map.getTile({ x = spot.x, y = spot.y, z = z })
            if tile and tile:getGround() then
                return false
            end
        end
    end
    return true
end

-- the mood of the area the trainer is in, for the map shader (NO_MOOD for none)
local function areaMood(weather)
    local environment = modules.game_environment
    local banner = environment and environment.AREA_BANNER
    local player = g_game.getLocalPlayer()
    if not option('areaMoods', true) or not banner or not player or not environment.getAreaName then
        return NO_MOOD
    end
    local name = environment.getAreaName()
    if name == '' or banner.isBuilding(name) then
        return NO_MOOD
    end
    if name:find('Lavender', 1, true) then
        local thick = weather and '0.85' or '1.0'
        return { name = ' lavender ' .. thick, MOOD = '1.0', HAZE = thick, RADIUS = '0.0', CAVEFLOOR = '1.0',
                 MAPW = '1.0', MAPH = '1.0' }
    end
    if outdoors or player:getPosition().z > 7 or not CAVE_THEMES[banner.theme(name)] then
        return NO_MOOD
    end
    local map = modules.game_interface.getMapPanel()
    local tiles = map and map:getVisibleDimension()
    if not tiles then
        return NO_MOOD
    end
    local bright = lit.flashlight or (lit.pokemon ~= 0 and g_map.getCreatureById(lit.pokemon) ~= nil)
    local ambient = (tonumber(option('ambientLight', 0)) or 0) / 100
    local floor = math.floor(math.max(bright and 0.3 or 0.12, ambient) * 20 + 0.5) / 20
    local radius = bright and '5.5' or '2.5'
    local w, h = tiles.width + 3, tiles.height + 3
    return { name = string.format(' cave %s %.2f %dx%d', radius, floor, w, h), MOOD = '2.0', HAZE = '0.0',
             RADIUS = radius, CAVEFLOOR = string.format('%.2f', floor), MAPW = w .. '.0', MAPH = h .. '.0' }
end

-- shaders

local commonCode

local function shaderName(kind, level, style, mood)
    return 'Weather - ' .. kind .. (level == 1 and ' (light)' or '') .. (style > 0 and ' ' .. STYLES[style] or '')
        .. mood.name
end

-- the engine compiles it on its next frame: the name is usable from then on (returns true when new)
local function ensureShader(kind, level, style, mood)
    mood = mood or NO_MOOD
    local name = shaderName(kind, level, style, mood)
    if shaders[name] then
        return name, false
    end
    if not commonCode then
        commonCode = g_resources.readFileContents(DIR .. 'shaders/common.frag')
    end
    local body = g_resources.readFileContents(DIR .. 'shaders/' .. kind .. '.frag')
    local code = (commonCode .. '\n' .. body):gsub('STRENGTH', level == 1 and '0.5' or '1.0'):gsub('FALL', FALL)
        :gsub('STYLE', style .. '.0')
    for _, key in ipairs({ 'MOOD', 'HAZE', 'RADIUS', 'CAVEFLOOR', 'MAPW', 'MAPH' }) do
        code = code:gsub(key, mood[key])
    end
    g_shaders.createFragmentShaderFromCode(name, code)
    g_shaders.setupMapShader(name)
    shaders[name] = true
    return name, true
end

local shaderEvent

-- the engine ignores a switch while it is fading out the same shader, and a shader it is still
-- compiling counts as none: wait for both
local function pushShader(tries)
    shaderEvent = nil
    local map = modules.game_interface.getMapPanel()
    if not map then
        return
    end
    local name = activeShader or ''
    if tries > 0 and (map:isSwitchingShader() or (name ~= '' and not g_shaders.getShader(name))) then
        shaderEvent = scheduleEvent(function()
            pushShader(tries - 1)
        end, 100)
        return
    end
    map:setShader(name, SHADER_FADE, SHADER_FADE)
end

local function setShader(name)
    if activeShader == name then
        return
    end
    activeShader = name
    removeEvent(shaderEvent)
    pushShader(50)
end

-- sounds

local function stopLoop()
    if loopChannel and loopFile then
        loopChannel:stop(SOUND_FADE)
    end
    loopFile = nil
end

local function playLoop(name)
    if not g_sounds or not loopChannel then
        return
    end
    local file = name and '/sounds/environment/' .. name .. '.ogg'
    if file == loopFile then
        return
    end
    stopLoop()
    if file then
        loopFile = file
        local ambience = tonumber(option('soundAmbience', 5)) or 5
        local master = tonumber(option('soundMaster', 100)) or 100
        loopChannel:setGain(math.max(0.15, ambience / 100) * master / 100)
        loopChannel:enqueue(file, SOUND_FADE)
    end
end

-- lightning

local function stopLightning()
    removeEvent(lightningEvent)
    lightningEvent = nil
end

local function strike()
    if not flash then
        return
    end
    local map = modules.game_interface.getMapPanel()
    if map then
        flash:setParent(map)
        flash:fill('parent')
    end
    flash:show()
    flash:raise()
    local start, double = g_clock.millis(), math.random() < 0.45
    removeEvent(flashEvent)
    flashEvent = cycleEvent(function()
        local t = g_clock.millis() - start
        local opacity
        if t < 70 then
            opacity = 0.75
        elseif double and t < 140 then
            opacity = 0.15
        elseif double and t < 200 then
            opacity = 0.6
        else
            opacity = math.max(0, 0.6 - (t - (double and 200 or 70)) / 500)
        end
        flash:setOpacity(opacity)
        if opacity <= 0 then
            removeEvent(flashEvent)
            flashEvent = nil
            flash:hide()
        end
    end, 16)
    if option('weatherSounds', true) and g_sounds then
        local channel = g_sounds.getChannel(SoundChannels.Effect)
        scheduleEvent(function()
            if channel and g_game.isOnline() then
                channel:play('/sounds/environment/thunder_low_01.ogg', 0, 1.0)
            end
        end, math.random(250, 1400))
    end
end

local function scheduleLightning()
    stopLightning()
    lightningEvent = scheduleEvent(function()
        lightningEvent = nil
        if getKind() == 'thunderstorm' and outdoors and effectsLevel() > 0 then
            if option('weatherLightning', true) then
                strike()
            end
            scheduleLightning()
        end
    end, math.random(6000, 20000))
end

-- badge

local function formatLeft(seconds)
    seconds = math.max(0, seconds)
    local hours, minutes = math.floor(seconds / 3600), math.floor(seconds % 3600 / 60)
    if hours > 0 then
        return tr('%dh %02dm', hours, minutes)
    end
    return tr('%dm', math.max(1, minutes))
end

local function capitalize(text)
    return (text:gsub('^%l', string.upper))
end

local function badgeTooltip()
    local lines = { tr('%s, %s', current.zone or '', current.region or '') }
    lines[#lines + 1] = current.name or ''
    if current.source == 'staff' then
        lines[#lines + 1] = current.endsAt and current.endsAt > 0 and tr('Set by staff, %s left', formatLeft(current.endsAt - os.time() - offset))
            or tr('Set by staff')
    elseif current.source == 'holiday' then
        lines[#lines + 1] = tr('%s weather', current.holiday or '')
    elseif current.endsAt then
        lines[#lines + 1] = tr('Changes in about %s', formatLeft(current.endsAt - os.time() - offset))
    end
    local moves = {}
    for _, move in ipairs(current.moves or {}) do
        local percent = math.floor((move.value - 1) * 100 + 0.5)
        moves[#moves + 1] = tr('%s moves %s%d%%', ELEMENT_NAMES[move.element] or '?', percent > 0 and '+' or '', percent)
    end
    if #moves > 0 then
        lines[#lines + 1] = ''
        lines[#lines + 1] = table.concat(moves, ', ') .. ' ' .. tr('(outdoors)')
    end
    if current.chip then
        lines[#lines + 1] = tr('Hurts Pokemon outdoors a little, except %s types.', current.kind == 'hail' and tr('Ice') or tr('Rock, Ground and Steel'))
    end
    if current.fog then
        lines[#lines + 1] = tr('Moves from 2 or more tiles away may miss.')
    end
    if current.season then
        lines[#lines + 1] = ''
        lines[#lines + 1] = tr('Season: %s', tr(capitalize(current.season)))
    end
    if not outdoors then
        lines[#lines + 1] = tr('You are under a roof or underground.')
    end
    return table.concat(lines, '\n')
end

local function relayoutCalendar()
    if modules.game_calendar and modules.game_calendar.relayout then
        modules.game_calendar.relayout()
    end
end

local function placeBadge()
    if not badge then
        return
    end
    local clock = rootWidget:recursiveGetChildById('timeWindow')
    badge:breakAnchors()
    if clock and clock:getParent() then
        badge:setParent(clock:getParent())
        local topMenu = modules.client_topmenu and modules.client_topmenu.getTopMenu and modules.client_topmenu.getTopMenu()
        if topMenu and clock:getParent() == topMenu then
            badge:addAnchor(AnchorLeft, 'timeWindow', AnchorRight)
            badge:addAnchor(AnchorVerticalCenter, 'timeWindow', AnchorVerticalCenter)
            badge:setMarginLeft(14)
            badge:setMarginTop(0)
        else
            badge:addAnchor(AnchorTop, 'timeWindow', AnchorBottom)
            badge:addAnchor(AnchorHorizontalCenter, 'timeWindow', AnchorHorizontalCenter)
            badge:setMarginLeft(0)
            badge:setMarginTop(2)
        end
    else
        badge:setParent(modules.game_interface.getRootPanel())
        badge:addAnchor(AnchorTop, 'parent', AnchorTop)
        badge:addAnchor(AnchorLeft, 'parent', AnchorLeft)
        badge:setMarginTop(4)
    end
    badge:setVisible(g_game.isOnline() and current ~= nil and current.zone ~= nil)
    relayoutCalendar()
end

local function updateBadge()
    if not badge or not current or not current.zone then
        if badge and badge:isVisible() then
            badge:hide()
            relayoutCalendar()
        end
        return
    end
    local icon = current.kind
    badge:getChildById('icon'):setImageSource(DIR .. 'images/weather_' .. icon)
    local label = badge:getChildById('label')
    label:setText(current.name or '')
    label:setColor(outdoors and '#ffffff' or '#96aacd')
    badge:getChildById('icon'):setOpacity(outdoors and 1 or 0.6)
    badge:setWidth(badge:getChildById('icon'):getWidth() + label:getMarginLeft() + label:getWidth() + 2)
    badge:setTooltip(badgeTooltip())
    if not badge:isVisible() then
        placeBadge()
    end
end

-- applying it

local function apply()
    local kind = getKind()
    local level = effectsLevel()
    local style = visualStyle()
    local weather = g_game.isOnline() and outdoors and level > 0 and KINDS_WITH_SHADER[kind]
    local mood = g_game.isOnline() and areaMood(weather) or NO_MOOD
    moodKey = mood.name
    if weather then
        setShader(ensureShader(kind, level, style, mood))
    elseif g_game.isOnline() and (style > 0 or mood ~= NO_MOOD) then
        setShader(ensureShader('clear', 2, style, mood))
    else
        setShader(nil)
    end

    if g_game.isOnline() and outdoors and option('weatherSounds', true) then
        playLoop(LOOPS[kind])
    else
        playLoop(nil)
    end

    if kind == 'thunderstorm' and outdoors and level > 0 then
        if not lightningEvent then
            scheduleLightning()
        end
    else
        stopLightning()
    end
    updateBadge()
end

function refresh()
    apply()
end

local function checkOutdoors()
    local player = g_game.getLocalPlayer()
    local now = player and isOutdoors(player:getPosition()) or false
    if now ~= outdoors then
        outdoors = now
        apply()
        -- the server keeps where a creature stands for 2 seconds
        removeEvent(matchupEvent)
        matchupEvent = scheduleEvent(function()
            matchupEvent = nil
            if modules.game_pokemoves and modules.game_pokemoves.refreshMatchup then
                modules.game_pokemoves.refreshMatchup()
            end
        end, 2200)
    end
end

-- the area name changes in game_environment's own step handler, the light when Flash's Pokemon goes
local function checkMood()
    if not g_game.isOnline() then
        return
    end
    local kind = getKind()
    if areaMood(outdoors and effectsLevel() > 0 and KINDS_WITH_SHADER[kind]).name ~= moodKey then
        apply()
    end
end

local moodEvent
local function onPositionChange(creature, newPos, oldPos)
    if creature:isLocalPlayer() then
        checkOutdoors()
        removeEvent(moodEvent)
        moodEvent = scheduleEvent(function()
            moodEvent = nil
            checkMood()
        end, 50)
    end
end

local function onWeather(protocol, opcode, buffer)
    local ok, data = pcall(json.decode, buffer)
    if not ok or type(data) ~= 'table' then
        g_logger.warning('Weather: invalid message')
        return
    end
    if data.now then
        offset = data.now - os.time()
    end
    if data.type == 'light' then
        lit = { flashlight = data.flashlight == true, pokemon = tonumber(data.pokemon) or 0 }
        checkMood()
    elseif data.type == 'weather' then
        local changed = not current or current.kind ~= data.kind
        current = data
        local player = g_game.getLocalPlayer()
        outdoors = player and isOutdoors(player:getPosition()) or false
        apply()
        placeBadge()
        if changed and modules.game_pokemoves and modules.game_pokemoves.refreshMatchup then
            modules.game_pokemoves.refreshMatchup()
        end
    end
end

local function onGameStart()
    current = nil
    send({ action = 'status' })
    removeEvent(placeEvent)
    placeEvent = scheduleEvent(placeBadge, 400)
end

local function onGameEnd()
    current = nil
    outdoors = false
    lit = { flashlight = false, pokemon = 0 }
    moodKey = ''
    removeEvent(placeEvent)
    placeEvent = nil
    setShader(nil)
    activeShader = nil
    playLoop(nil)
    stopLightning()
    if badge then
        badge:hide()
    end
end

local function onTopMenuVisibility()
    if g_game.isOnline() then
        removeEvent(placeEvent)
        placeEvent = scheduleEvent(placeBadge, 50)
    end
end

function isBadgeVisible()
    return badge ~= nil and badge:isVisible()
end

function getBadge()
    return badge
end

function init()
    g_ui.importStyle('weather')
    local style = visualStyle()
    for kind in pairs(KINDS_WITH_SHADER) do
        ensureShader(kind, 2, style)
        ensureShader(kind, 1, style)
    end
    ensureShader('clear', 2, 1)
    ensureShader('clear', 2, 2)
    badge = g_ui.createWidget('WeatherBadge', modules.game_interface.getRootPanel())
    badge:setId('weatherBadge')
    badge:hide()
    flash = g_ui.createWidget('WeatherFlash', modules.game_interface.getMapPanel())
    flash:hide()
    if g_sounds then
        loopChannel = g_sounds.getChannel(SoundChannels.secundaryChannel)
    end

    local topMenu = modules.client_topmenu and modules.client_topmenu.getTopMenu and modules.client_topmenu.getTopMenu()
    if topMenu then
        connect(topMenu, { onVisibilityChange = onTopMenuVisibility })
    end
    ProtocolGame.registerExtendedOpcode(ExtendedIds.Weather, onWeather)
    connect(g_game, { onGameStart = onGameStart, onGameEnd = onGameEnd })
    connect(LocalPlayer, { onPositionChange = onPositionChange })
    -- roofs and floors above load in after a step: look again now and then
    checkEvent = cycleEvent(function()
        if g_game.isOnline() then
            checkOutdoors()
            checkMood()
            if current and badge and badge:isVisible() then
                badge:setTooltip(badgeTooltip())
            end
        end
    end, 1000)
    if g_game.isOnline() then
        onGameStart()
    end
end

function terminate()
    local topMenu = modules.client_topmenu and modules.client_topmenu.getTopMenu and modules.client_topmenu.getTopMenu()
    if topMenu then
        disconnect(topMenu, { onVisibilityChange = onTopMenuVisibility })
    end
    ProtocolGame.unregisterExtendedOpcode(ExtendedIds.Weather)
    disconnect(g_game, { onGameStart = onGameStart, onGameEnd = onGameEnd })
    disconnect(LocalPlayer, { onPositionChange = onPositionChange })
    removeEvent(checkEvent)
    removeEvent(placeEvent)
    removeEvent(flashEvent)
    removeEvent(matchupEvent)
    removeEvent(moodEvent)
    stopLightning()
    activeShader = nil
    removeEvent(shaderEvent)
    pushShader(0)
    playLoop(nil)
    if badge then
        badge:destroy()
    end
    if flash then
        flash:destroy()
    end
    badge, flash, current = nil, nil, nil
    relayoutCalendar()
end
