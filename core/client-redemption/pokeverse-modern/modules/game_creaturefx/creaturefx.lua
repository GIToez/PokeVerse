-- Shaders on Pokemon: shiny ones shimmer, and burn, freeze, paralysis, poison, sleep and confusion
-- show on the Pokemon itself. Shinies are known by their sprites (ShinyLooks, from the server's
-- monsters). The statuses come from the server (008-conditions.lua) as ExtendedIds.CreatureStatus
-- "creatureId,status,ms", ms 0 when one ends early. A creature has one shader, so a status shows
-- over the shimmer until it ends. Every effect is compiled VARIANTS times at different points in its
-- cycle, picked by creature id, so Pokemon side by side don't pulse together. Option: pokemonEffects.
local DIR = '/modules/game_creaturefx/shaders/'
local VARIANTS = 6
local EFFECTS = { 'shiny', 'burn', 'freeze', 'paralysis', 'poison', 'sleep', 'confusion' }
-- the server's CREATURE_STATUS_* ids
local STATUS_EFFECTS = { [0] = 'burn', [1] = 'freeze', [2] = 'paralysis', [3] = 'poison', [4] = 'sleep', [5] = 'confusion',
                         [14] = 'poison' }
-- the one that shows when a Pokemon has more than one
local PRIORITY = { freeze = 6, sleep = 5, paralysis = 4, burn = 3, poison = 2, confusion = 1 }

local statuses = {} -- [creatureId] = { [effect] = ends at (g_clock.millis) }
local shaded = {} -- [creatureId] = true while this module has a shader on it
local tickEvent, sweepEvent

local function shaderName(effect, variant)
    return 'Pokemon - ' .. effect .. ' ' .. variant
end

local function enabled()
    local options = modules.client_options
    local value = options and options.getOption and options.getOption('pokemonEffects')
    return value ~= false
end

local function compileShaders()
    local common = g_resources.readFileContents(DIR .. 'common.frag')
    for _, effect in ipairs(EFFECTS) do
        local body = g_resources.readFileContents(DIR .. effect .. '.frag')
        for variant = 0, VARIANTS - 1 do
            local name = shaderName(effect, variant)
            local code = (common .. '\n' .. body):gsub('PHASE', string.format('%.4f', variant / VARIANTS))
            g_shaders.createFragmentShaderFromCode(name, code)
            g_shaders.setupOutfitShader(name)
        end
    end
end

function isShiny(creature)
    local outfit = creature:getOutfit()
    return outfit ~= nil and ShinyLooks[outfit.type] == true
end

local function wantedShader(creature)
    if not enabled() then
        return ''
    end
    local id = creature:getId()
    local best
    local now = g_clock.millis()
    for effect, endsAt in pairs(statuses[id] or {}) do
        if endsAt > now and (not best or PRIORITY[effect] > PRIORITY[best]) then
            best = effect
        end
    end
    if not best and isShiny(creature) then
        best = 'shiny'
    end
    return best and shaderName(best, id % VARIANTS) or ''
end

-- always set, even when it looks unchanged: the server can send a creature again, and the client
-- then makes a new object with the same id
local function refresh(creature)
    if not creature or creature:getId() == 0 or creature:isPlayer() then
        return
    end
    local name = wantedShader(creature)
    creature:setShader(name)
    shaded[creature:getId()] = name ~= '' or nil
end

function refreshAll()
    local player = g_game.getLocalPlayer()
    if not player then
        return
    end
    for _, creature in ipairs(g_map.getSpectators(player:getPosition(), true)) do
        refresh(creature)
    end
end

local function stopTick()
    removeEvent(tickEvent)
    tickEvent = nil
end

-- statuses run out on their own: drop them and put the shimmer (or nothing) back
local function tick()
    local now = g_clock.millis()
    for id, list in pairs(statuses) do
        local changed = false
        for effect, endsAt in pairs(list) do
            if endsAt <= now then
                list[effect] = nil
                changed = true
            end
        end
        if next(list) == nil then
            statuses[id] = nil
        end
        if changed then
            refresh(g_map.getCreatureById(id))
        end
    end
    if next(statuses) == nil then
        stopTick()
    end
end

local function onCreatureStatus(protocol, opcode, buffer)
    local id, status, ms = buffer:match('^(%d+),(%d+),(%d+)$')
    local effect = STATUS_EFFECTS[tonumber(status or -1)]
    if not id or not effect then
        return
    end
    id, ms = tonumber(id), tonumber(ms)
    local list = statuses[id] or {}
    list[effect] = ms > 0 and g_clock.millis() + ms or nil
    statuses[id] = next(list) and list or nil
    refresh(g_map.getCreatureById(id))
    if statuses[id] and not tickEvent then
        tickEvent = cycleEvent(tick, 250)
    end
end

local function onAppear(creature)
    refresh(creature)
end

local function onDisappear(creature)
    shaded[creature:getId()] = nil
    creature:setShader('')
end

local function onOutfitChange(creature)
    refresh(creature)
end

-- When the server sends a creature the client already has (around login, or coming back into
-- view), the engine puts the server's shader on it, none, without telling Lua: so look again
-- now and then
local function startSweep()
    removeEvent(sweepEvent)
    sweepEvent = cycleEvent(refreshAll, 1000)
end

local function onGameStart()
    scheduleEvent(refreshAll, 300)
    startSweep()
end

local function onGameEnd()
    stopTick()
    removeEvent(sweepEvent)
    sweepEvent = nil
    statuses = {}
    shaded = {}
end

function init()
    compileShaders()
    ProtocolGame.registerExtendedOpcode(ExtendedIds.CreatureStatus, onCreatureStatus)
    connect(Creature, { onAppear = onAppear, onDisappear = onDisappear, onOutfitChange = onOutfitChange })
    connect(g_game, { onGameStart = onGameStart, onGameEnd = onGameEnd })
    if g_game.isOnline() then
        scheduleEvent(refreshAll, 100)
        startSweep()
    end
end

function terminate()
    ProtocolGame.unregisterExtendedOpcode(ExtendedIds.CreatureStatus)
    disconnect(Creature, { onAppear = onAppear, onDisappear = onDisappear, onOutfitChange = onOutfitChange })
    disconnect(g_game, { onGameStart = onGameStart, onGameEnd = onGameEnd })
    stopTick()
    removeEvent(sweepEvent)
    sweepEvent = nil
    for id in pairs(shaded) do
        local creature = g_map.getCreatureById(id)
        if creature then
            creature:setShader('')
        end
    end
    statuses = {}
    shaded = {}
end
