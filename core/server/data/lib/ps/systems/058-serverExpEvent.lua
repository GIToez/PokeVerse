-- Server-wide experience event, started by staff with /doubleexp. It multiplies kill
-- experience only: the trainer's (Player::rateExperience) and the Pokemon's
-- (doPlayerPokemonAddExperience). Catch, quest and item experience are not affected.
--
-- Only one event runs at a time; starting a new one replaces it. The multiplier lives in
-- C++ (setExperienceEventMultiplier) so every Lua state sees it, and the event is kept in
-- global storage, written to the database at once so it survives a crash or restart.
-- Only the serverExpEvent globalevent (ServerExpEvent.onThink) ends expired events.

ServerExpEvent = {}

local KEY_MULTIPLIER = GLOBAL_STORAGES.EXP_EVENT_MULTIPLIER -- multiplier x100, 0 or -1 = none
local KEY_END = GLOBAL_STORAGES.EXP_EVENT_END               -- unix time the event ends

ServerExpEvent.DEFAULT_MULTIPLIER = 2
ServerExpEvent.MAX_MULTIPLIER = 10
ServerExpEvent.MIN_SECONDS = 60
ServerExpEvent.MAX_SECONDS = 7 * 24 * 60 * 60

local UNITS = {m = 60, h = 60 * 60, d = 24 * 60 * 60}

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
    setExperienceEventMultiplier(1)
end

function ServerExpEvent.formatMultiplier(multiplier)
    return string.format("%g", multiplier) .. "x"
end

function ServerExpEvent.formatDuration(seconds)
    seconds = math.max(0, math.floor(seconds))
    if (seconds < 60) then
        return seconds .. (seconds == 1 and " second" or " seconds")
    end
    local minutes = math.floor(seconds / 60)
    local days, hours = math.floor(minutes / 1440), math.floor(minutes % 1440 / 60)
    minutes = minutes % 60
    local parts = {}
    if (days > 0) then table.insert(parts, days .. (days == 1 and " day" or " days")) end
    if (hours > 0) then table.insert(parts, hours .. (hours == 1 and " hour" or " hours")) end
    if (minutes > 0) then table.insert(parts, minutes .. (minutes == 1 and " minute" or " minutes")) end
    return table.concat(parts, " ")
end

-- Returns the multiplier and end time of the running event, or nil.
function ServerExpEvent.get()
    local multiplier, endsAt = getNumber(KEY_MULTIPLIER), getNumber(KEY_END)
    if (multiplier <= 100 or endsAt <= os.time()) then
        return nil
    end
    return multiplier / 100, endsAt
end

-- "[<multiplier>x] <number><m|h|d>", e.g. "2h", "3x 2h", "1.5x 30m".
-- Returns multiplier, seconds or nil, error message.
function ServerExpEvent.parse(text)
    local tokens = {}
    for token in tostring(text or ""):lower():gmatch("%S+") do
        table.insert(tokens, token)
    end

    local multiplier = ServerExpEvent.DEFAULT_MULTIPLIER
    if (#tokens == 2) then
        multiplier = tonumber(tokens[1]:match("^(%d+%.?%d*)x$") or "")
        if (not multiplier) then
            return nil, "The multiplier must look like 2x or 1.5x."
        end
        table.remove(tokens, 1)
    elseif (#tokens ~= 1) then
        return nil
    end

    local amount, unit = tokens[1]:match("^(%d+)([mhd])$")
    if (not amount) then
        return nil, "The duration must be a whole number followed by m, h or d, such as 30m, 2h or 1d."
    end

    multiplier = math.floor(multiplier * 100 + 0.5) / 100
    if (multiplier <= 1 or multiplier > ServerExpEvent.MAX_MULTIPLIER) then
        return nil, "The multiplier must be above 1x and at most " .. ServerExpEvent.MAX_MULTIPLIER .. "x."
    end
    local seconds = tonumber(amount) * UNITS[unit]
    if (seconds < ServerExpEvent.MIN_SECONDS or seconds > ServerExpEvent.MAX_SECONDS) then
        return nil, "The duration must be between 1 minute and 7 days."
    end
    return multiplier, seconds
end

function ServerExpEvent.start(multiplier, seconds)
    local replaced = ServerExpEvent.get()
    store(KEY_MULTIPLIER, math.floor(multiplier * 100 + 0.5))
    store(KEY_END, os.time() + seconds)
    setExperienceEventMultiplier(multiplier)
    doBroadcastMessage(string.format("%s %s kill experience for trainers and Pokemon for the next %s!",
        replaced and "The experience event changed:" or "Experience event started:",
        ServerExpEvent.formatMultiplier(multiplier), ServerExpEvent.formatDuration(seconds)), MESSAGE_STATUS_WARNING)
end

function ServerExpEvent.stop()
    local multiplier = ServerExpEvent.get()
    if (not multiplier) then
        return false
    end
    clear()
    doBroadcastMessage(string.format("The %s experience event was cancelled.", ServerExpEvent.formatMultiplier(multiplier)),
        MESSAGE_STATUS_WARNING)
    return true
end

function ServerExpEvent.describe()
    local multiplier, endsAt = ServerExpEvent.get()
    if (not multiplier) then
        return "No experience event is running right now."
    end
    return string.format("%s kill experience event: %s left (ends %s server time).", ServerExpEvent.formatMultiplier(multiplier),
        ServerExpEvent.formatDuration(endsAt - os.time()), os.date("%Y-%m-%d %H:%M", endsAt))
end

function ServerExpEvent.onLogin(cid)
    if (ServerExpEvent.get()) then
        doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, ServerExpEvent.describe())
    end
end

-- Executor state (only used in the globalevent's Lua state).
local started = false
local running = nil

function ServerExpEvent.onThink()
    local multiplier = ServerExpEvent.get()
    if (not started) then
        started = true
        if (multiplier) then
            print("> Experience event: " .. ServerExpEvent.describe())
        elseif (getNumber(KEY_MULTIPLIER) > 0) then
            clear()
            print("> Experience event: dropped the event that ended while the server was down")
        end
    elseif (not multiplier and running and getNumber(KEY_MULTIPLIER) > 0) then -- ended, not cancelled
        clear()
        doBroadcastMessage(string.format("The %s experience event has ended.", ServerExpEvent.formatMultiplier(running)),
            MESSAGE_STATUS_WARNING)
    end

    running = multiplier
    if (getExperienceEventMultiplier() ~= (multiplier or 1)) then
        setExperienceEventMultiplier(multiplier or 1)
    end
    return true
end
