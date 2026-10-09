-- Scheduled game server restarts: the daily restart (dailyRestart* in config.lua) and
-- restarts scheduled by staff with /restart. See docs/live-server.md.
--
-- Talkactions and globalevents run in separate Lua states, so the schedule is kept in
-- global storage. Only the serverRestart globalevent (ServerRestart.onThink) broadcasts
-- warnings and shuts the server down. Shutting down saves every player (with Pokemon and
-- items), houses, the map and global storage; systemd then starts the server again.

ServerRestart = {}

local KEY_AT = GLOBAL_STORAGES.SERVER_RESTART_AT         -- unix time of the scheduled restart, 0 or -1 = none
local KEY_REASON = GLOBAL_STORAGES.SERVER_RESTART_REASON -- REASON_DAILY or REASON_STAFF
local KEY_DAILY = GLOBAL_STORAGES.SERVER_RESTART_DAILY   -- minutes after midnight, DAILY_OFF, or -1 = config.lua
local KEY_SKIP = GLOBAL_STORAGES.SERVER_RESTART_SKIP     -- daily restart time cancelled with /restart cancel

local REASON_DAILY, REASON_STAFF, REASON_UPDATE = 1, 2, 3
local DAILY_OFF = -2
ServerRestart.REASON_DAILY = REASON_DAILY

-- Seconds before the restart at which players are warned.
ServerRestart.WARNINGS = {1800, 900, 600, 300, 60, 30, 10}

local function getNumber(key)
    local value = tonumber(getStorage(key))
    return value or -1
end

function ServerRestart.parseTime(text)
    local hour, minute = tostring(text or ""):match("^%s*(%d%d?):(%d%d)%s*$")
    hour, minute = tonumber(hour), tonumber(minute)
    if (not hour or hour > 23 or minute > 59) then
        return nil
    end
    return hour * 60 + minute
end

function ServerRestart.formatTime(minutes)
    return string.format("%02d:%02d", math.floor(minutes / 60), minutes % 60)
end

function ServerRestart.formatDuration(seconds)
    seconds = math.max(0, math.floor(seconds + 0.5))
    if (seconds < 60) then
        return seconds .. (seconds == 1 and " second" or " seconds")
    end
    local minutes = math.floor((seconds + 30) / 60)
    if (minutes < 60) then
        return minutes .. (minutes == 1 and " minute" or " minutes")
    end
    local hours, rest = math.floor(minutes / 60), minutes % 60
    return hours .. (hours == 1 and " hour" or " hours") .. (rest > 0 and (" " .. rest .. " min") or "")
end

-- Daily restart time in minutes after midnight (server local time), or nil when disabled.
-- /restart daily overrides config.lua until /restart daily default.
function ServerRestart.getDaily()
    local override = getNumber(KEY_DAILY)
    if (override == DAILY_OFF) then
        return nil, "staff"
    elseif (override >= 0) then
        return override, "staff"
    end
    if (getConfigValue("dailyRestartEnabled") ~= true) then
        return nil, "config"
    end
    return ServerRestart.parseTime(getConfigValue("dailyRestartTime")), "config"
end

function ServerRestart.setDaily(minutes)
    doSetStorage(KEY_DAILY, minutes or -1)
end

function ServerRestart.disableDaily()
    doSetStorage(KEY_DAILY, DAILY_OFF)
end

function ServerRestart.nextDaily(minutes, now)
    local t = os.date("*t", now)
    t.hour, t.min, t.sec, t.isdst = math.floor(minutes / 60), minutes % 60, 0, nil
    local at = os.time(t)
    if (at <= now) then
        t.day = t.day + 1
        at = os.time(t)
    end
    return at
end

-- Returns the scheduled restart time and reason, or nil.
function ServerRestart.getScheduled()
    local at = getNumber(KEY_AT)
    if (at <= 0) then
        return nil
    end
    return at, getNumber(KEY_REASON)
end

function ServerRestart.schedule(at, reason)
    doSetStorage(KEY_REASON, reason)
    doSetStorage(KEY_AT, at)
end

function ServerRestart.scheduleIn(seconds)
    ServerRestart.schedule(os.time() + seconds, REASON_STAFF)
end

-- Cancels the scheduled restart. A cancelled daily restart comes back the next day.
function ServerRestart.cancel()
    local at, reason = ServerRestart.getScheduled()
    if (not at) then
        return false
    end
    if (reason == REASON_DAILY) then
        doSetStorage(KEY_SKIP, at)
    end
    doSetStorage(KEY_AT, 0)
    doBroadcastMessage("The scheduled server restart was cancelled.", MESSAGE_STATUS_WARNING)
    DiscordBridge.onRestartWarning("shutdown_cancelled", nil, false)
    print("> Restart: scheduled restart cancelled")
    return true
end

local function label(reason)
    if (reason == REASON_DAILY) then
        return "Daily server restart"
    elseif (reason == REASON_UPDATE) then
        return "Server update"
    end
    return "Server restart"
end

function ServerRestart.announce(seconds, reason)
    local text
    if (seconds >= 60) then
        text = string.format("%s in %s. Your progress is saved automatically; please finish your battle and log out safely.",
            label(reason), ServerRestart.formatDuration(seconds))
    else
        text = string.format("%s in %s!", label(reason), ServerRestart.formatDuration(seconds))
    end
    doBroadcastMessage(text, MESSAGE_STATUS_WARNING)
    if (seconds >= 60) then
        DiscordBridge.onRestartWarning("shutdown", math.floor((seconds + 30) / 60), true)
    end
end

function ServerRestart.describe()
    local lines = {}
    local at, reason = ServerRestart.getScheduled()
    if (at) then
        table.insert(lines, string.format("%s at %s (in %s).", label(reason), os.date("%Y-%m-%d %H:%M:%S", at),
            ServerRestart.formatDuration(at - os.time())))
    else
        table.insert(lines, "No restart is scheduled right now.")
    end
    local daily, source = ServerRestart.getDaily()
    if (daily) then
        table.insert(lines, string.format("Daily restart: %s server time (%s, set by %s).", ServerRestart.formatTime(daily),
            os.date("%Z"), source == "staff" and "/restart daily" or "config.lua"))
    else
        table.insert(lines, string.format("Daily restart: off (set by %s).", source == "staff" and "/restart daily" or "config.lua"))
    end
    return lines
end

local function restartNow()
    doSetStorage(KEY_AT, 0)
    doBroadcastMessage("The server is restarting now. You can log in again in about a minute.", MESSAGE_STATUS_WARNING)
    DiscordBridge.onRestartWarning("shutdown", 0, true)
    print("> Restart: saving and shutting down; systemd starts the server again")
    doSetGameState(GAMESTATE_SHUTDOWN)
end

-- Live deployments (scripts/live/pokeverse-ctl) ask for a warned restart by writing
-- "<unix time>" or "cancel" to restartRequestFile. The deployment stops the server itself
-- just before that time; the countdown only warns the players.
local function readRequest()
    local path = getConfigValue("restartRequestFile")
    if (type(path) ~= "string" or path == "") then
        return
    end
    local f = io.open(path, "r")
    if (not f) then
        return
    end
    local content = f:read("*a") or ""
    f:close()
    os.remove(path)
    local at = tonumber(content:match("^%s*(%d+)"))
    if (at and at > os.time()) then
        ServerRestart.schedule(at, REASON_UPDATE)
        print("> Restart: update restart requested for " .. os.date("%Y-%m-%d %H:%M:%S", at))
    elseif (content:match("^%s*cancel")) then
        ServerRestart.cancel()
    end
end

-- Executor state (only used in the globalevent's Lua state).
local warned = {at = nil, below = math.huge}
local started = false

function ServerRestart.onThink()
    local now = os.time()
    if (not started) then
        started = true
        -- A restart that was due while the server was down already happened, and an update
        -- restart belonged to the release this server just replaced.
        local at, reason = ServerRestart.getScheduled()
        if (at and (at <= now or reason == REASON_UPDATE)) then
            doSetStorage(KEY_AT, 0)
            print("> Restart: dropped the restart left over from the previous run")
        end
    end

    readRequest()
    local at, reason = ServerRestart.getScheduled()

    if (not at) then
        local daily = ServerRestart.getDaily()
        if (daily) then
            local nextAt = ServerRestart.nextDaily(daily, now)
            if (nextAt - now <= ServerRestart.WARNINGS[1] and getNumber(KEY_SKIP) ~= nextAt) then
                ServerRestart.schedule(nextAt, REASON_DAILY)
                print("> Restart: daily restart scheduled for " .. os.date("%Y-%m-%d %H:%M:%S", nextAt))
                at, reason = nextAt, REASON_DAILY
            end
        end
        if (not at) then
            return true
        end
    end

    local remaining = at - now
    if (remaining <= 0) then
        restartNow()
        return true
    end

    -- A new schedule is announced at once; after that only the warning times are announced.
    if (warned.at ~= at) then
        warned.at, warned.below = at, math.huge
        for _, seconds in ipairs(ServerRestart.WARNINGS) do
            if (seconds >= remaining) then
                warned.below = seconds
            end
        end
        ServerRestart.announce(warned.below - remaining < 3 and warned.below or remaining, reason)
        return true
    end

    local threshold = nil
    for _, seconds in ipairs(ServerRestart.WARNINGS) do
        if (remaining <= seconds and seconds < warned.below) then
            threshold = seconds
        end
    end
    if (threshold) then
        warned.below = threshold
        -- The globalevent runs once per second; show the exact warning time when it is that close.
        ServerRestart.announce(remaining > threshold - 3 and threshold or remaining, reason)
    end
    return true
end
