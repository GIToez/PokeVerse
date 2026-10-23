-- The Admin window (client game_admin) for every staff member (access 1 and up). Each tab and action
-- needs the access of the commands behind it: the window runs most of them as the talkactions
-- themselves ({action = "command"}, so talkactions.xml decides), and checks the access of the rest here
-- (events Admin.EVENT_START_ACCESS, the world settings and legendaries Admin.WORLD_ACCESS, decorations
-- Admin.ACCESS, bans Admin.BAN_ACCESS).
--
-- JSON on EXTENDED_IDS.ADMIN:
--   client -> server  {action = "hello"} (at login), {action = "refresh"},
--                     {action = "start", event, multiplier, minutes}, {action = "stop", event},
--                     {action = "broadcast", text, target = "both"|"game"|"discord"}, {action = "save"}, {action = "clean"},
--                     {action = "decorations", catalog}, {action = "deco_add", set, item}, {action = "deco_remove", set},
--                     {action = "deco_preview", set, minutes} (no set: end the preview), {action = "deco_auto", on},
--                     {action = "command", text} (a talkaction, run with the staff member's own access),
--                     {action = "players", filter}, {action = "ban", name, days (0: for good), reason, comment},
--                     {action = "bans"}, {action = "commands"}
--   server -> client  {type = "state", access, online, events = {{key, label, command, multiplier, left}}, multipliers,
--                      minutes, access, banAccess, banDays, banReasons = {{id, name}}, world = {kinds, regions,
--                      holidays, seasons, legendaries}}
--                     {type = "result", ok, text}
--                     {type = "decorations", sets = {{id, name}}, theme, preview = {set, left}, town = {name, auto},
--                      radius, total, spots = {{set, item, client, name, x, y, z, by, valid, why}}} (the nearest
--                      Admin.DECO_ROWS), and with catalog one {type = "deco_items", set, items = {{id, client, name,
--                      wall}}} per set first (a message over 8 KB is dropped)
--                     {type = "players", total, players = {{name, level, access, place, x, y, z}}, towns = {{id, name}}}
--                     {type = "bans", bans = {{account, names, reason, comment, by, left}}} (left -1: for good)
--                     {type = "commands", part, parts, commands = {{words, access, group, usage, help}}}
-- Decorations are placed on the tile the staff member faces, like /deco.
-- Nothing is sent to players below Admin.STAFF_ACCESS, so their client never shows the button.

Admin = {}

Admin.STAFF_ACCESS = 1
Admin.EVENTS_ACCESS = 3 -- sees the Events tab (broadcasts); starting events needs Admin.EVENT_START_ACCESS
Admin.EVENT_START_ACCESS = 4 -- Community Managers run the events
Admin.BROADCAST_ACCESS = 3
Admin.BAN_ACCESS = 3
Admin.BAN_DAYS = { 1, 3, 7, 30, 0 }
Admin.BAN_REASONS = { 4, 5, 6, 10, 11, 12, 14, 15, 19 } -- ids of getBanReason
Admin.PLAYER_ROWS = 40
Admin.BAN_ROWS = 8
Admin.COMMANDS_PER_MESSAGE = 20
Admin.ACCESS = 5
-- the World and Events tabs' settings: the access of /weather, /calendar and /legendary (talkactions.xml)
Admin.WORLD_ACCESS = 4
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
    return isPlayer(cid) and getPlayerAccess(cid) >= Admin.STAFF_ACCESS
end

local function hasAccess(cid, access)
    return getPlayerAccess(cid) >= access
end

local function worldInfo()
    local kinds, regions, holidays, seasons, legendaries = {}, {}, {}, {}, {}
    for _, id in ipairs(Weather.KIND_IDS) do
        kinds[#kinds + 1] = { id = id, name = Weather.KINDS[id].name }
    end
    for _, region in ipairs(Weather.REGIONS) do
        regions[#regions + 1] = { id = region.id, name = region.name, on = Weather.isRegionOn(region) }
    end
    for _, holiday in ipairs(EventCalendar.HOLIDAYS) do
        holidays[#holidays + 1] = { id = holiday.id, name = holiday.name }
    end
    for _, season in ipairs(EventCalendar.SEASONS) do
        seasons[#seasons + 1] = { id = season.id, name = season.name }
    end
    for _, species in ipairs(WildLegendaries.SPECIES) do
        legendaries[#legendaries + 1] = species.name
    end
    return { kinds = kinds, regions = regions, holidays = holidays, seasons = seasons, legendaries = legendaries,
             legendary = WildLegendaries.adminState() }
end

Admin.sendState = function(cid)
    local events = {}
    for _, event in ipairs(EVENTS) do
        local multiplier, endsAt = event.get()
        events[#events + 1] = { key = event.key, label = event.label, command = event.command,
                                multiplier = multiplier, left = multiplier and endsAt - os.time() or nil }
    end
    local reasons = {}
    for _, id in ipairs(Admin.BAN_REASONS) do
        reasons[#reasons + 1] = { id = id, name = getBanReason(id) }
    end
    send(cid, { type = "state", access = getPlayerAccess(cid), online = #getPlayersOnline(), events = events,
                multipliers = Admin.MULTIPLIERS, minutes = Admin.MINUTES, eventsAccess = Admin.EVENT_START_ACCESS,
                broadcastAccess = Admin.BROADCAST_ACCESS, banAccess = Admin.BAN_ACCESS, banDays = Admin.BAN_DAYS,
                banReasons = reasons, world = hasAccess(cid, Admin.WORLD_ACCESS) and worldInfo() or nil })
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
    local ok, replaced = Decorations.addSpot(setId, pos, itemid, getCreatureName(cid), getCreaturePosition(cid))
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

-- The Commands tab: every talkaction from access 1 up, with its group, usage and what it does
Admin.COMMAND_HELP = {
    ["/goto"] = { "Players", "/goto <player | x,y,z | waypoint>", "Teleport to a player, a position or a waypoint" },
    ["/c"] = { "Players", "/c <player>", "Bring a player (or creature) to you" },
    ["/send"] = { "Players", "/send <player>;<player | x,y,z>", "Send a player somewhere" },
    ["/town"] = { "Players", "/town <town>[,<player>]", "Teleport you (or a player) to a town's temple" },
    ["/kick"] = { "Players", "/kick <player>", "Disconnect a player" },
    ["/mkick"] = { "Players", "/mkick <range x>,<range y>[,multifloor]", "Disconnect every player around you" },
    ["/chatban"] = { "Players", "/chatban <player>", "Mute a player in every chat channel for 60 minutes" },
    ["/info"] = { "Players", "/info <player>", "Character and account details" },
    ["/notations"] = { "Players", "/notations <player | account>", "Notations on the account" },
    ["/baninfo"] = { "Players", "/baninfo <player | account>", "Why and until when an account is banned" },
    ["/unban"] = { "Players", "/unban <player | account>", "Lift an account ban, IP ban or namelock" },
    ["/mc"] = { "Players", "/mc", "Players online from the same IP" },
    ["/gmcheck"] = { "Players", "/gmcheck", "Check the players online" },
    ["/online"] = { "Players", "/online", "Players online and their levels" },
    ["/promote"] = { "Players", "/promote <player>", "Move a player one staff group up" },
    ["/demote"] = { "Players", "/demote <player>", "Move a player one staff group down" },
    ["/pstats"] = { "Players", "/pstats <player>", "A player's Pokemon stats" },
    ["/vocation"] = { "Players", "/vocation <player> ...", "See or change a trainer's vocation and rank" },
    ["/addskill"] = { "Players", "/addskill <player>, <skill>[, amount]", "Add skill levels" },
    ["/addoutfit"] = { "Players", "/addoutfit <player>, <outfit>", "Give a player an outfit" },
    ["/sendplayeruniqueitem"] = { "Players", "/sendplayeruniqueitem <player>, <item>", "Send a player a unique item" },
    ["/storage"] = { "Players", "/storage <player>, <key>[, value]", "Read or set a player storage" },
    ["/gethouse"] = { "Players", "/gethouse <player>", "The house a player owns" },
    ["/t"] = { "Moving", "/t", "Teleport to your temple" },
    ["/a"] = { "Moving", "/a <tiles>", "Step that many tiles forward" },
    ["/wp"] = { "Moving", "/wp", "The waypoints" },
    ["/cliport"] = { "Moving", "/cliport", "Teleport where you click on the map" },
    ["/ghost"] = { "Staff", "/ghost", "Turn invisible, or visible again" },
    ["/squelch"] = { "Staff", "/squelch", "Ignore private messages" },
    ["/reports"] = { "Staff", "/reports", "Open rule violation reports" },
    ["/b"] = { "Staff", "/b <message>", "Broadcast with your name (in game and to Discord)" },
    ["/bc"] = { "Staff", "/bc <color> <message>", "Broadcast in a colour" },
    ["/i"] = { "World", "/i <item id | name>[, count]", "Create an item" },
    ["/m"] = { "World", "/m <monster>", "Summon a monster" },
    ["/n"] = { "World", "/n <npc>", "Summon an NPC" },
    ["/s"] = { "World", "/s <pokemon>", "Summon a wild Pokemon" },
    ["/r"] = { "World", "/r", "Remove the thing in front of you" },
    ["/createnpc"] = { "World", "/createnpc <name>", "Create an NPC" },
    ["/attr"] = { "World", "/attr <attribute> <value>", "Change the item in front of you" },
    ["/owner"] = { "World", "/owner <player>", "Set the owner of the house you stand in" },
    ["/newtype"] = { "World", "/newtype <monster>", "Turn into a monster" },
    ["/z"] = { "World", "/z <effect>", "Show a magic effect" },
    ["/x"] = { "World", "/x <projectile>", "Show a projectile" },
    ["/y"] = { "World", "/y <color> <text>", "Show animated text" },
    ["/weather"] = { "World", "/weather [<zone|region|all|here> <kind> [minutes] | auto | off | time <day|night> | region <region> <on|off>]", "Weather and the game clock" },
    ["/anniversary"] = { "World", "/anniversary [show [minutes] | hide | on | off | auto | start | boss | reset]", "The Anniversary and its cake town" },
    ["/legendary"] = { "Events", "/legendary status | spawn <name> [here] | set <set> | end | move | health | signs <name> | mew [here] | reveal | wake <name> | warn [here] | mode <auto|manual> | next <duration> | flyover <name> [dive] | rayquaza | meteors | impact", "Wild legendaries" },
    ["/raid"] = { "World", "/raid <name>", "Start a raid" },
    ["/deco"] = { "World", "/deco sets | items | add | remove | list | preview | auto", "Hand-placed decorations" },
    ["/mypokemon"] = { "World", "/mypokemon <pokemon> [level]", "Give yourself a Pokemon" },
    ["/pokemonexp"] = { "World", "/pokemonexp <amount>", "EXP for the Pokemon out" },
    ["/doubleexp"] = { "Events", "/doubleexp <multiplier> <duration> | stop", "Kill experience event" },
    ["/bonusshiny"] = { "Events", "/bonusshiny <multiplier> <duration> | stop", "Shiny chance event" },
    ["/bonusdaycare"] = { "Events", "/bonusdaycare <multiplier> <duration> | stop", "Day Care training EXP event" },
    ["/bonusbreeding"] = { "Events", "/bonusbreeding <multiplier> <duration> | stop", "Day Care egg chance event" },
    ["/calendar"] = { "Events", "/calendar [list | add ... | remove <n> | holiday <id> on|off|auto | season <name|auto>]", "Calendar events, holidays and seasons" },
    ["/save"] = { "Server", "/save [minutes]", "Save the server (or every N minutes)" },
    ["/clean"] = { "Server", "/clean [minutes | tile]", "Remove the items lying on the map" },
    ["/restart"] = { "Server", "/restart [<minutes> | cancel | announce | daily <HH:MM>|off|default]", "Restarts" },
    ["/shutdown"] = { "Server", "/shutdown [<minutes> | stop]", "Shut the server down" },
    ["/closeserver"] = { "Server", "/closeserver", "Close the server to players" },
    ["/openserver"] = { "Server", "/openserver", "Open the server to players again" },
    ["/reload"] = { "Server", "/reload <talkactions | actions | npcs | monsters | config | all ...>", "Reload scripts and data" },
    ["/mode"] = { "Server", "/mode <nopvp | pvp | pvpenforced>", "The world's PvP type" },
    ["/config"] = { "Server", "/config <key>", "Read a config.lua value" },
    ["/serverdiag"] = { "Server", "/serverdiag", "Server diagnostics" },
}

-- talkactions.xml's commands from access 1 up, by words
local function talkactions()
    local list = {}
    for _, entry in ipairs(getTalkActionList() or {}) do
        if (entry.access >= Admin.STAFF_ACCESS and not entry.hide) then
            list[entry.words:lower()] = entry
        end
    end
    return list
end

local function trim(text)
    return (tostring(text or ""):gsub("^%s+", ""):gsub("%s+$", ""))
end

Admin.sendCommands = function(cid)
    local access, commands = getPlayerAccess(cid), {}
    for words, entry in pairs(talkactions()) do
        if (entry.access <= access) then
            local help = Admin.COMMAND_HELP[words] or {}
            commands[#commands + 1] = { words = entry.words, access = entry.access, group = help[1] or "Other",
                                        usage = help[2] or entry.words, help = help[3] or entry.description or "" }
        end
    end
    table.sort(commands, function(a, b) return a.words < b.words end)
    local parts = math.max(1, math.ceil(#commands / Admin.COMMANDS_PER_MESSAGE))
    for part = 1, parts do
        local chunk = {}
        for index = (part - 1) * Admin.COMMANDS_PER_MESSAGE + 1, math.min(#commands, part * Admin.COMMANDS_PER_MESSAGE) do
            chunk[#chunk + 1] = commands[index]
        end
        send(cid, { type = "commands", part = part, parts = parts, commands = chunk })
    end
end

local function runCommand(cid, data)
    local text = trim(data.text)
    local words = (text:match("^(%S+)") or ""):lower()
    if (text == "") then
        return result(cid, false, "Type a command.")
    elseif (#text > 255) then
        return result(cid, false, "Commands can be at most 255 characters.")
    end
    local entry = talkactions()[words]
    if (not entry) then
        return result(cid, false, string.format("There is no staff command %s.", words))
    elseif (entry.access > getPlayerAccess(cid)) then
        return result(cid, false, string.format("%s needs access %d.", entry.words, entry.access))
    end
    log(cid, "ran " .. text)
    -- access is checked above; the engine's own check reads the group directly, not getPlayerAccess
    if (not doCreatureExecuteTalkAction(cid, text, 1)) then
        return result(cid, false, "Couldn't run " .. text .. ".")
    end
    result(cid, true, string.format("Ran %s. Its answer is in the Server Log.", text))
end

local function isVisible(cid, pid)
    return not isPlayerGhost(pid) or getPlayerGhostAccess(pid) <= getPlayerGhostAccess(cid)
end

local function towns()
    local list = {}
    for id = 1, 100 do
        local name = getTownName(id)
        if (name and name ~= "") then
            list[#list + 1] = { id = id, name = name }
        end
    end
    return list
end

local function sendPlayers(cid, data)
    local filter, rows = trim(data.filter):lower(), {}
    for _, pid in ipairs(getPlayersOnline()) do
        local name = getCreatureName(pid)
        if (isVisible(cid, pid) and (filter == "" or name:lower():find(filter, 1, true))) then
            local pos = getCreaturePosition(pid)
            local zone = Weather.zoneAt(pos)
            rows[#rows + 1] = { name = name, level = getPlayerLevel(pid), access = getPlayerAccess(pid),
                                place = zone and zone.name or nil, x = pos.x, y = pos.y, z = pos.z }
        end
    end
    table.sort(rows, function(a, b) return a.name:lower() < b.name:lower() end)
    local total = #rows
    for index = #rows, Admin.PLAYER_ROWS + 1, -1 do
        rows[index] = nil
    end
    send(cid, { type = "players", total = total, players = rows, towns = towns() })
end

local function accountNames(account)
    local names = {}
    local query = db.getResult(string.format("SELECT `name` FROM `players` WHERE `account_id` = %d ORDER BY `level` DESC LIMIT 3;", account))
    if (query:getID() ~= -1) then
        repeat
            names[#names + 1] = query:getDataString("name")
        until (not query:next())
        query:free()
    end
    return names
end

Admin.sendBans = function(cid)
    local bans = getBanList(BAN_ACCOUNT) or {}
    table.sort(bans, function(a, b) return a.added > b.added end)
    local rows = {}
    for index = 1, math.min(#bans, Admin.BAN_ROWS) do
        local ban = bans[index]
        rows[#rows + 1] = { account = ban.value, names = accountNames(ban.value), reason = getBanReason(ban.reason),
                            comment = ban.comment, by = ban.adminId ~= 0 and getPlayerNameByGUID(ban.adminId, false, false) or "",
                            left = ban.expires <= 0 and -1 or ban.expires - os.time() }
    end
    send(cid, { type = "bans", total = #bans, bans = rows })
end

-- the access of a character, online or not
local function characterAccess(name, guid)
    local pid = getPlayerByName(name)
    if (pid) then
        return getPlayerAccess(pid)
    end
    local access = 0
    local query = db.getResult(string.format("SELECT `group_id` FROM `players` WHERE `id` = %d;", guid))
    if (query:getID() ~= -1) then
        local group = getGroupInfo(query:getDataInt("group_id"))
        access = group and group.access or 0
        query:free()
    end
    return access
end

local function banAccount(cid, data)
    local name, days, reason = trim(data.name), tonumber(data.days), tonumber(data.reason)
    local comment = trim(data.comment):sub(1, 200)
    if (name == "") then
        return result(cid, false, "Type or pick the player to ban.")
    elseif (not contains(Admin.BAN_DAYS, days) or not contains(Admin.BAN_REASONS, reason)) then
        return result(cid, false, "Pick how long and why.")
    end
    local guid = getPlayerGUIDByName(name)
    local account = guid and getAccountIdByName(name) or 0
    if (not guid or account == 0) then
        return result(cid, false, string.format("There is no player called %s.", name))
    elseif (characterAccess(name, guid) >= getPlayerAccess(cid)) then
        return result(cid, false, string.format("You can't ban %s.", name))
    elseif (isAccountBanished(account)) then
        return result(cid, false, string.format("%s's account is already banned (/baninfo %s).", name, name))
    end
    local expires = days == 0 and -1 or os.time() + days * 86400
    if (not doAddAccountBanishment(account, guid, expires, reason, days == 0 and ACTION_DELETION or ACTION_BANISHMENT,
            comment, getPlayerGUID(cid))) then
        return result(cid, false, "The ban couldn't be saved.")
    end
    local kicked = 0
    for _, pid in ipairs(getPlayersOnline()) do
        if (getPlayerAccountId(pid) == account) then
            doSetDiscordLogoutReason(pid, "kick")
            doRemoveCreature(pid)
            kicked = kicked + 1
        end
    end
    local length = days == 0 and "for good" or string.format("for %d day%s", days, days == 1 and "" or "s")
    log(cid, string.format("banned %s's account %s (%s) %s", name, length, getBanReason(reason), comment))
    result(cid, true, string.format("%s's account is banned %s%s.", name, length, kicked > 0 and " and was disconnected" or ""))
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
    if (DECORATION_ACTIONS[action]) then
        if (not hasAccess(cid, Admin.ACCESS)) then
            return result(cid, false, "Decorations need access " .. Admin.ACCESS .. ".")
        end
        DECORATION_ACTIONS[action](cid, data)
        return Admin.sendDecorations(cid, action == "decorations" and data.catalog == true)
    elseif (action == "command") then
        return runCommand(cid, data)
    elseif (action == "players") then
        return sendPlayers(cid, data)
    elseif (action == "commands") then
        return Admin.sendCommands(cid)
    elseif (action == "bans" or action == "ban") then
        if (not hasAccess(cid, Admin.BAN_ACCESS)) then
            return result(cid, false, "Bans need access " .. Admin.BAN_ACCESS .. ".")
        end
        if (action == "ban") then
            banAccount(cid, data)
        end
        return Admin.sendBans(cid)
    elseif (action == "hello" or action == "refresh") then
        -- falls through to the state below
    elseif (action == "start" or action == "stop") then
        if (not hasAccess(cid, Admin.EVENT_START_ACCESS)) then
            return result(cid, false, "Events need access " .. Admin.EVENT_START_ACCESS .. ".")
        end
        if (action == "start") then
            startEvent(cid, data)
        else
            stopEvent(cid, data)
        end
    elseif (action == "broadcast") then
        if (not hasAccess(cid, Admin.BROADCAST_ACCESS)) then
            return result(cid, false, "Broadcasts need access " .. Admin.BROADCAST_ACCESS .. ".")
        end
        broadcast(cid, data)
    elseif (action == "save" or action == "clean") then
        return runCommand(cid, { text = "/" .. action })
    else
        return
    end
    Admin.sendState(cid)
end
