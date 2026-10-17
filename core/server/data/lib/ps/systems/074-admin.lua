-- The Admin window (client game_admin): the server events and a few staff tools, for staff with
-- Admin.ACCESS (the access the event commands need in talkactions.xml). Every request checks the
-- access again, so the window is only a shortcut for what the commands already allow.
--
-- JSON on EXTENDED_IDS.ADMIN:
--   client -> server  {action = "hello"} (at login), {action = "refresh"},
--                     {action = "start", event, multiplier, minutes}, {action = "stop", event},
--                     {action = "broadcast", text}, {action = "save"}, {action = "clean"}
--   server -> client  {type = "state", access, online, events = {{key, label, command, multiplier, left}}}
--                     {type = "result", ok, text}
-- Nothing is sent to anyone below Admin.ACCESS, so their client never shows the button.

Admin = {}

Admin.ACCESS = 5
Admin.MULTIPLIERS = { 1.5, 2, 3, 5 }
Admin.MINUTES = { 30, 60, 120, 360, 1440, 4320 }

local EVENTS = {
    { key = "exp", label = "Kill experience", command = "/doubleexp",
      get = function() return ServerExpEvent.get() end,
      start = function(multiplier, seconds) ServerExpEvent.start(multiplier, seconds) end,
      stop = function() return ServerExpEvent.stop() end },
    { key = "shiny", label = "Shiny chance", command = "/bonusshiny",
      get = function() return ShinyEvent.get() end,
      start = function(multiplier, seconds) ShinyEvent.start(multiplier, seconds) end,
      stop = function() return ShinyEvent.stop() end },
    { key = "daycare", label = "Day Care training EXP", command = "/bonusdaycare",
      get = function() return Daycare.getEvent("daycare") end,
      start = function(multiplier, seconds) Daycare.startEvent("daycare", multiplier, seconds) end,
      stop = function() return Daycare.stopEvent("daycare") end },
    { key = "breeding", label = "Day Care egg chance", command = "/bonusbreeding",
      get = function() return Daycare.getEvent("breeding") end,
      start = function(multiplier, seconds) Daycare.startEvent("breeding", multiplier, seconds) end,
      stop = function() return Daycare.stopEvent("breeding") end },
}

local function findEvent(key)
    for _, event in ipairs(EVENTS) do
        if (event.key == key) then
            return event
        end
    end
    return nil
end

local function contains(list, value)
    for _, v in ipairs(list) do
        if (v == value) then
            return true
        end
    end
    return false
end

local function send(cid, data)
    doSendPlayerExtendedOpcode(cid, EXTENDED_IDS.ADMIN, JSON.encode(data))
end

local function result(cid, ok, text)
    send(cid, { type = "result", ok = ok, text = text })
end

local function log(cid, text)
    print(string.format("> Admin window: %s %s", getCreatureName(cid), text))
end

Admin.allowed = function(cid)
    return isPlayer(cid) and getPlayerAccess(cid) >= Admin.ACCESS
end

Admin.sendState = function(cid)
    local events = {}
    for _, event in ipairs(EVENTS) do
        local multiplier, endsAt = event.get()
        events[#events + 1] = { key = event.key, label = event.label, command = event.command,
                                multiplier = multiplier, left = multiplier and endsAt - os.time() or nil }
    end
    send(cid, { type = "state", access = getPlayerAccess(cid), online = #getPlayersOnline(), events = events,
                multipliers = Admin.MULTIPLIERS, minutes = Admin.MINUTES })
end

-- The client's hello can go out before the opcode handshake, so staff also get the state pushed after login.
Admin.onLogin = function(cid)
    if (Admin.allowed(cid)) then
        addEvent(function()
            if (Admin.allowed(cid)) then
                Admin.sendState(cid)
            end
        end, 1000)
    end
end

local function startEvent(cid, data)
    local event = findEvent(data.event)
    local multiplier, minutes = tonumber(data.multiplier), tonumber(data.minutes)
    if (not event) then
        return result(cid, false, "Unknown event.")
    elseif (not contains(Admin.MULTIPLIERS, multiplier) or not contains(Admin.MINUTES, minutes)) then
        return result(cid, false, "Pick a multiplier and a duration.")
    end
    event.start(multiplier, minutes * 60)
    log(cid, string.format("started %s %s for %s", event.label, ServerExpEvent.formatMultiplier(multiplier),
        ServerExpEvent.formatDuration(minutes * 60)))
    result(cid, true, string.format("%s event started: %s for %s.", event.label,
        ServerExpEvent.formatMultiplier(multiplier), ServerExpEvent.formatDuration(minutes * 60)))
end

local function stopEvent(cid, data)
    local event = findEvent(data.event)
    if (not event) then
        return result(cid, false, "Unknown event.")
    elseif (not event.stop()) then
        return result(cid, false, string.format("No %s event is running.", event.label:lower()))
    end
    log(cid, "cancelled " .. event.label)
    result(cid, true, event.label .. " event cancelled.")
end

local function broadcast(cid, data)
    local text = tostring(data.text or ""):gsub("^%s+", ""):gsub("%s+$", "")
    if (text == "") then
        return result(cid, false, "Type a message to broadcast.")
    elseif (#text > 255) then
        return result(cid, false, "Broadcasts can be at most 255 characters.")
    end
    doBroadcastMessage(getCreatureName(cid) .. ": " .. text, MESSAGE_STATUS_WARNING)
    log(cid, "broadcast: " .. text)
    result(cid, true, "Broadcast sent.")
end

Admin.onClientMessage = function(cid, buffer)
    if (not Admin.allowed(cid)) then
        return
    end
    local ok, data = pcall(JSON.decode, buffer)
    if (not ok or type(data) ~= "table") then
        return
    end

    local action = data.action
    if (action == "hello" or action == "refresh") then
        -- falls through to the state below
    elseif (action == "start") then
        startEvent(cid, data)
    elseif (action == "stop") then
        stopEvent(cid, data)
    elseif (action == "broadcast") then
        broadcast(cid, data)
    elseif (action == "save") then
        doSaveServer()
        log(cid, "saved the server")
        result(cid, true, "Server saved.")
    elseif (action == "clean") then
        local count = doCleanMap()
        log(cid, "cleaned the map")
        result(cid, true, string.format("Map cleaned: %d items removed.", count or 0))
    else
        return
    end
    Admin.sendState(cid)
end
