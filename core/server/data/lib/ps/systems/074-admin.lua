-- The Admin window (client game_admin): the server events and a few staff tools, for staff with
-- Admin.ACCESS (the access the event commands need in talkactions.xml). Every request checks the
-- access again, so the window is only a shortcut for what the commands already allow.
--
-- JSON on EXTENDED_IDS.ADMIN:
--   client -> server  {action = "hello"} (at login), {action = "refresh"},
--                     {action = "start", event, multiplier, minutes}, {action = "stop", event},
--                     {action = "broadcast", text, target = "both"|"game"|"discord"}, {action = "save"}, {action = "clean"},
--                     {action = "decorations", catalog}, {action = "deco_add", set, item}, {action = "deco_remove", set},
--                     {action = "deco_preview", set, minutes} (no set: end the preview), {action = "deco_auto", on}
--   server -> client  {type = "state", access, online, events = {{key, label, command, multiplier, left}}}
--                     {type = "result", ok, text}
--                     {type = "decorations", sets = {{id, name}}, theme, preview = {set, left}, town = {name, auto},
--                      radius, total, spots = {{set, item, client, name, x, y, z, by, valid, why}}} (the nearest
--                      Admin.DECO_ROWS), and with catalog one {type = "deco_items", set, items = {{id, client, name,
--                      wall}}} per set first (a message over 8 KB is dropped)
-- Decorations are placed on the tile the staff member faces, like /deco.
-- Nothing is sent to anyone below Admin.ACCESS, so their client never shows the button.

Admin = {}

Admin.ACCESS = 5
Admin.MULTIPLIERS = { 1.5, 2, 3, 5, 10 }
Admin.MINUTES = { 30, 60, 120, 360, 1440, 4320, 10080 }
Admin.BROADCAST_TARGETS = { both = true, game = true, discord = true }

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
    local target = data.target or "both"
    if (not Admin.BROADCAST_TARGETS[target]) then
        return result(cid, false, "Pick where to broadcast.")
    end
    if (target ~= "discord") then
        doBroadcastMessage(getCreatureName(cid) .. ": " .. text, MESSAGE_STATUS_WARNING)
    end
    if (target ~= "game") then
        DiscordBridge.onBroadcast("gm", getCreatureName(cid), text)
    end
    log(cid, string.format("broadcast (%s): %s", target, text))
    result(cid, true, ({ both = "Broadcast sent in game and to Discord.", game = "Broadcast sent in game.",
                         discord = "Broadcast sent to Discord." })[target])
end

Admin.DECO_ROWS = 7

Admin.sendDecorations = function(cid, catalog)
    local sets = {}
    for _, id in ipairs(Decorations.setIds()) do
        sets[#sets + 1] = { id = id, name = Decorations.SETS[id].name }
        if (catalog) then
            local items = {}
            for _, item in ipairs(Decorations.catalog(id)) do
                local info = getItemInfo(item.id)
                items[#items + 1] = { id = item.id, client = info and info.clientId or 0, name = item.name, wall = item.wall }
            end
            send(cid, { type = "deco_items", set = id, items = items })
        end
    end
    local pos = getCreaturePosition(cid)
    local near, spots = Decorations.spotsNear(pos, Decorations.NEARBY), {}
    for index = 1, math.min(#near, Admin.DECO_ROWS) do
        local entry = near[index]
        local spot, info = entry.spot, getItemInfo(entry.spot.itemid)
        spots[#spots + 1] = { set = spot.set, item = spot.itemid, client = info and info.clientId or 0,
                              name = Decorations.itemName(spot.itemid), x = spot.pos.x, y = spot.pos.y, z = spot.pos.z,
                              by = spot.by, valid = entry.valid, why = entry.why }
    end
    local zone = Weather.zoneAt(pos)
    local preview, endsAt = Decorations.getPreview()
    send(cid, { type = "decorations", sets = sets, theme = Decorations.theme(),
                preview = preview and { set = preview, left = endsAt - os.time() } or nil,
                town = zone and { name = zone.name, auto = not Decorations.getNoAuto()[zone.id] } or nil,
                radius = Decorations.NEARBY, total = #near, spots = spots, previewMinutes = Decorations.PREVIEW_MINUTES })
end

local function decoFront(cid)
    local pos = getCreatureLookPosition(cid)
    return { x = pos.x, y = pos.y, z = pos.z }
end

local function decoAdd(cid, data)
    local setId, itemid = Decorations.findSet(data.set), tonumber(data.item)
    if (not setId or not itemid) then
        return result(cid, false, "Pick a set and a prop.")
    end
    local pos = decoFront(cid)
    local ok, replaced = Decorations.addSpot(setId, pos, itemid, getCreatureName(cid))
    if (not ok) then
        return result(cid, false, replaced)
    end
    log(cid, string.format("saved %s for %s at %d, %d, %d", Decorations.itemName(itemid), setId, pos.x, pos.y, pos.z))
    result(cid, true, string.format("Saved %s for %s%s.", Decorations.itemName(itemid), Decorations.SETS[setId].name,
        Decorations.theme() == setId and "" or " (it shows while the set is up; preview it to see it)"))
end

local function decoRemove(cid, data)
    local setId = Decorations.findSet(data.set)
    if (not setId) then
        return result(cid, false, "Pick a set.")
    end
    local pos = decoFront(cid)
    local removed = Decorations.removeSpots(pos, setId)
    if (#removed == 0) then
        return result(cid, false, string.format("No %s prop is saved on the tile you face.", Decorations.SETS[setId].name))
    end
    log(cid, string.format("removed %s's prop at %d, %d, %d", setId, pos.x, pos.y, pos.z))
    result(cid, true, string.format("Removed %s's %s.", Decorations.SETS[setId].name, Decorations.itemName(removed[1].itemid)))
end

local function decoPreview(cid, data)
    if (data.set == nil) then
        Decorations.setPreview(nil)
        log(cid, "ended the decorations preview")
        return result(cid, true, "Preview ended.")
    end
    local setId, minutes = Decorations.findSet(data.set), tonumber(data.minutes) or Decorations.PREVIEW_MINUTES
    if (not setId or minutes < 1 or minutes > Decorations.PREVIEW_MAX_MINUTES) then
        return result(cid, false, "Pick a set to preview.")
    end
    Decorations.setPreview(setId, minutes)
    log(cid, string.format("previews %s for %d minutes", setId, minutes))
    result(cid, true, string.format("%s is up for everyone for %d minutes.", Decorations.SETS[setId].name, minutes))
end

local function decoAuto(cid, data)
    local zone = Weather.zoneAt(getCreaturePosition(cid))
    if (not zone) then
        return result(cid, false, "You are not in a town.")
    end
    Decorations.setAuto(zone.id, data.on == true)
    log(cid, string.format("turned %s's automatic decorations %s", zone.name, data.on == true and "on" or "off"))
    result(cid, true, string.format("%s's automatic props are %s.", zone.name, data.on == true and "on" or "off"))
end

local DECORATION_ACTIONS = { decorations = function() end, deco_add = decoAdd, deco_remove = decoRemove,
                             deco_preview = decoPreview, deco_auto = decoAuto }

Admin.onClientMessage = function(cid, buffer)
    if (not Admin.allowed(cid)) then
        return
    end
    local ok, data = pcall(JSON.decode, buffer)
    if (not ok or type(data) ~= "table") then
        return
    end

    local action = data.action
    if (DECORATION_ACTIONS[action]) then
        DECORATION_ACTIONS[action](cid, data)
        return Admin.sendDecorations(cid, action == "decorations" and data.catalog == true)
    elseif (action == "hello" or action == "refresh") then
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
