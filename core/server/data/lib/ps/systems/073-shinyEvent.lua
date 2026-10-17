-- Server-wide shiny event, started by staff with /bonusshiny. While it runs, every shiny roll
-- (map spawns in src/spawn.cpp, fishing, headbutt, eggs, incubators and abilities) is that many
-- times more likely: a 1 in 8,192 chance becomes 1 in 4,096 at 2x.
--
-- Built like the experience event (058-serverExpEvent.lua): the multiplier lives in C++
-- (setShinyEventMultiplier) so the spawn code and every Lua state see it, and the event is kept
-- in global storage, written to the database at once. Only the serverExpEvent globalevent
-- (ShinyEvent.onThink) ends expired events.

ShinyEvent = {}

local KEY_MULTIPLIER = GLOBAL_STORAGES.SHINY_EVENT_MULTIPLIER -- multiplier x100, 0 or -1 = none
local KEY_END = GLOBAL_STORAGES.SHINY_EVENT_END               -- unix time the event ends

local function getNumber(key)
    return tonumber(getStorage(key)) or -1
end

local function store(key, value)
    doSetStorage(key, value)
    db.executeQuery(string.format("REPLACE INTO `global_storage` (`key`, `world_id`, `value`) VALUES (%d, %d, %s);",
        key, getConfigValue("worldId") or 0, db.escapeString(tostring(value))))
end

local function clear()
    store(KEY_MULTIPLIER, 0)
    store(KEY_END, 0)
    setShinyEventMultiplier(EventCalendar.multiplier("shiny"))
end

-- Returns the multiplier and end time of the running event, or nil.
function ShinyEvent.get()
    local multiplier, endsAt = getNumber(KEY_MULTIPLIER), getNumber(KEY_END)
    if (multiplier <= 100 or endsAt <= os.time()) then
        return nil
    end
    return multiplier / 100, endsAt
end

-- The "1 in chance" to roll right now: getRandom(0, ShinyEvent.chance(SHINY_CHANCE)) == 0
function ShinyEvent.chance(chance)
    return math.max(1, math.floor(chance / getShinyEventMultiplier()))
end

function ShinyEvent.start(multiplier, seconds)
    local replaced = ShinyEvent.get()
    store(KEY_MULTIPLIER, math.floor(multiplier * 100 + 0.5))
    store(KEY_END, os.time() + seconds)
    setShinyEventMultiplier(multiplier * EventCalendar.multiplier("shiny"))
    doBroadcastMessage(string.format("%s %s shiny chance for wild, fished, headbutted and hatched Pokemon for the next %s!",
        replaced and "The shiny event changed:" or "Shiny event started:",
        ServerExpEvent.formatMultiplier(multiplier), ServerExpEvent.formatDuration(seconds)), MESSAGE_STATUS_WARNING)
end

function ShinyEvent.stop()
    local multiplier = ShinyEvent.get()
    if (not multiplier) then
        return false
    end
    clear()
    doBroadcastMessage(string.format("The %s shiny event was cancelled.", ServerExpEvent.formatMultiplier(multiplier)),
        MESSAGE_STATUS_WARNING)
    return true
end

function ShinyEvent.describe()
    local multiplier, endsAt = ShinyEvent.get()
    if (not multiplier) then
        return "No shiny event is running right now."
    end
    return string.format("%s shiny event: %s left (ends %s server time).", ServerExpEvent.formatMultiplier(multiplier),
        ServerExpEvent.formatDuration(endsAt - os.time()), os.date("%Y-%m-%d %H:%M", endsAt))
end

function ShinyEvent.onLogin(cid)
    if (ShinyEvent.get()) then
        doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, ShinyEvent.describe())
    end
end

-- Executor state (only used in the globalevent's Lua state).
local started = false
local running = nil

function ShinyEvent.onThink()
    local multiplier = ShinyEvent.get()
    if (not started) then
        started = true
        if (multiplier) then
            print("> Shiny event: " .. ShinyEvent.describe())
        elseif (getNumber(KEY_MULTIPLIER) > 0) then
            clear()
            print("> Shiny event: dropped the event that ended while the server was down")
        end
    elseif (not multiplier and running and getNumber(KEY_MULTIPLIER) > 0) then -- ended, not cancelled
        clear()
        doBroadcastMessage(string.format("The %s shiny event has ended.", ServerExpEvent.formatMultiplier(running)),
            MESSAGE_STATUS_WARNING)
    end

    running = multiplier
    local total = (multiplier or 1) * EventCalendar.multiplier("shiny")
    if (getShinyEventMultiplier() ~= total) then
        setShinyEventMultiplier(total)
    end
end
