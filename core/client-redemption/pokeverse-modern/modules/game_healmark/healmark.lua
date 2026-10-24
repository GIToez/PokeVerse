-- A small heal mark after the name of a Pokemon or trainer a health potion is healing, for everyone
-- who can see it. The server (potions/healthPotions.lua) sends ExtendedIds.HealMark JSON
-- {id = creature, s = seconds left} every tick while the heal runs, and s = 0 when it ends.
-- The mark uses the name plate's icon slot, which only NPCs (game_quests badges) use otherwise.
local TEXTURE = '/modules/game_healmark/images/heal_mark'
local ICON_ID = 1 -- any icon but none: the texture is set right after
local TICK_MS = 1000

local marks = {} -- [creatureId] = ends at (g_clock.millis)
local tickEvent

local function setMark(creature, on)
    if not creature or not creature.setIcon or creature:isNpc() then
        return
    end
    if on then
        creature:setIcon(ICON_ID)
        creature:setIconTexture(TEXTURE)
    elseif creature:getIcon() ~= 0 then
        creature:setIcon(0)
    end
end

local function tick()
    tickEvent = nil
    local now = g_clock.millis()
    for id, endsAt in pairs(marks) do
        local creature = g_map.getCreatureById(id)
        if endsAt <= now or not creature then
            marks[id] = nil
            setMark(creature, false)
        end
    end
    if next(marks) then
        tickEvent = scheduleEvent(tick, TICK_MS)
    end
end

local function onMessage(protocol, opcode, buffer)
    local ok, data = pcall(json.decode, buffer)
    if not ok or type(data) ~= 'table' or not tonumber(data.id) then
        return
    end
    local id, seconds = tonumber(data.id), tonumber(data.s) or 0
    local creature = g_map.getCreatureById(id)
    if seconds > 0 then
        marks[id] = g_clock.millis() + seconds * 1000
        setMark(creature, true)
        if not tickEvent then
            tickEvent = scheduleEvent(tick, TICK_MS)
        end
    else
        marks[id] = nil
        setMark(creature, false)
    end
end

local function clearAll()
    for id in pairs(marks) do
        setMark(g_map.getCreatureById(id), false)
    end
    marks = {}
    if tickEvent then
        removeEvent(tickEvent)
        tickEvent = nil
    end
end

function init()
    ProtocolGame.registerExtendedOpcode(ExtendedIds.HealMark, onMessage)
    connect(g_game, { onGameEnd = clearAll })
end

function terminate()
    ProtocolGame.unregisterExtendedOpcode(ExtendedIds.HealMark)
    disconnect(g_game, { onGameEnd = clearAll })
    clearAll()
end
