-- Server-wide announcements for the modern client's news banner (game_newsbanner). doBroadcastMessage sends
-- EXTENDED_IDS.ANNOUNCEMENT to every player just before its text message (the engine's raids and tournaments go
-- through Announcements.fromEngine):
--   {c = category, h = title, x = text, f = the text message as sent}
-- The client shows the banner and hides the red text it already showed; old clients only see the text.
-- Categories: event, legendary, server, staff, milestone, tip and news. A broadcast that doesn't say its
-- category gets one from the script that sent it (BY_SOURCE), so every existing broadcast gets the banner.
--
-- Every announcement but the tips also goes to the Discord bot (DiscordBridge.onAnnouncement), which posts the
-- categories it is set to. Optional fields of the announcement table, for Discord only:
--   ping     "everyone", "here", "verified" or a role name, picked by staff (Announcements.takePing)
--   author   the staff member's name
--   calendar {key, id, state = "started"|"ended", type = "holiday"|"server"|"staff"} for calendar events
--   discord  false keeps it in game
Announcements = {}

Announcements.CATEGORIES = {
    event = true, legendary = true, server = true, staff = true, milestone = true, tip = true, news = true
}

Announcements.TITLE_MAX = 40

-- the first match in the calling script's path wins
Announcements.BY_SOURCE = {
    { "077-eventCalendar", "event" },
    { "058-serverExpEvent", "event" },
    { "073-shinyEvent", "event" },
    { "072-daycare", "event" },
    { "030-easterEvent", "event" },
    { "048-anniversaryEvent", "event" },
    { "089-discordBoostPerks", "event" },
    { "021-boss", "event" },
    { "raids/", "event" },
    { "078-wildLegendaries", "legendary" },
    { "057-serverRestart", "server" },
    { "talkactions/scripts/shutdown", "server" },
    { "talkactions/scripts/restart", "server" },
    { "talkactions/scripts/clean", "server" },
    { "talkactions/scripts/mode", "server" },
    { "globalevents/scripts/clean", "server" },
    { "globalevents/scripts/save", "server" },
    { "074-admin", "staff" },
    { "talkactions/scripts/broadcastclass", "staff" },
    { "talkactions/scripts/promote", "staff" },
    { "049-eliteFour", "milestone" },
    { "069-pokepedia", "milestone" },
    { "globalevents/scripts/record", "milestone" },
    { "globalMessages", "tip" },
}

function Announcements.categoryFor(source)
    source = source or ""
    for _, rule in ipairs(Announcements.BY_SOURCE) do
        if (source:find(rule[1], 1, true)) then
            return rule[2]
        end
    end
    return "news"
end

-- "Weekend Event has started: Double EXP ..." gives the title "Weekend Event has started" and the rest as the
-- text; a short first sentence ("The Evil Cake has appeared!") works the same. Otherwise the client shows the
-- category's name as the title.
function Announcements.split(text)
    local head, rest = text:match("^(.-):%s+(.+)$")
    if (head and #head <= Announcements.TITLE_MAX) then
        return head, rest
    end
    head, rest = text:match("^(.-[!%.])%s+(.+)$")
    if (head and #head <= Announcements.TITLE_MAX) then
        return head, rest
    end
    return nil, text
end

-- "@data/lib/ps/systems/077-eventCalendar.lua" gives "077-eventCalendar"
local function scriptName(source)
    return source and tostring(source):match("([^/\\]+)%.lua$") or nil
end

-- The announcement with everything filled in: category, title, text, full (the text message), source.
function Announcements.resolve(text, announcement, caller)
    announcement = announcement or {}
    local category = announcement.category
    if (not Announcements.CATEGORIES[category]) then
        category = Announcements.categoryFor(caller and caller.source)
    end
    local title, body = announcement.title, announcement.text
    if (not body) then
        title, body = Announcements.split(text)
        title = announcement.title or title
    end
    return { category = category, title = title, text = body, full = text, source = scriptName(caller and caller.source),
             ping = announcement.ping, author = announcement.author, calendar = announcement.calendar,
             discord = announcement.discord }
end

function Announcements.payload(text, announcement, caller)
    local a = Announcements.resolve(text, announcement, caller)
    return JSON.encode({ c = a.category, h = a.title, x = a.text, f = a.full })
end

-- To the Discord bot; never the tips.
function Announcements.toDiscord(a)
    if (a.category == "tip" or a.discord == false or not (DiscordBridge and DiscordBridge.onAnnouncement)) then
        return
    end
    DiscordBridge.onAnnouncement({ category = a.category, title = a.title, text = a.text, full = a.full,
                                   source = a.source, author = a.author, ping = a.ping, calendar = a.calendar })
end

function Announcements.send(players, text, announcement, caller)
    local ok, a = pcall(Announcements.resolve, tostring(text), announcement, caller)
    if (not ok) then
        print("> Announcements: " .. tostring(a))
        return
    end
    if (EXTENDED_IDS.ANNOUNCEMENT) then
        local payload = JSON.encode({ c = a.category, h = a.title, x = a.text, f = a.full })
        for _, pid in ipairs(players) do
            if (isPlayer(pid)) then
                doSendPlayerExtendedOpcode(pid, EXTENDED_IDS.ANNOUNCEMENT, payload)
            end
        end
    end
    local sent, err = pcall(Announcements.toDiscord, a)
    if (not sent) then
        print("> Announcements: " .. tostring(err))
    end
end

-- The tournament countdown (every hour from 3 hours, then 45, 30, 15, 10 and every minute from 5) gets a banner
-- on the hours and at 30, 15, 5 and 1 minutes, and Discord at 1 hour; the winner gets both.
local TOURNAMENT_BANNER_MINUTES = { [30] = true, [15] = true, [5] = true, [1] = true }

function Announcements.tournament(text)
    local name, levels, count, unit = text:match("^The (.-) tournament %((.-)%) will begin in (%d+) (%a+)")
    if (name) then
        count = tonumber(count)
        local hours = unit:find("^hour") ~= nil
        if (not hours and not TOURNAMENT_BANNER_MINUTES[count]) then
            return nil
        end
        return { category = "event", title = name .. " Tournament", discord = hours and count == 1,
                 text = string.format("Starts in %d %s (%s). Sign up with Joey at the PvP area.", count, unit, levels) }
    end
    local winner, tournament = text:match("^(.-) won the (.-) tournament!$")
    if (winner) then
        return { category = "event", title = tournament .. " Tournament", text = winner .. " won the tournament!" }
    end
    return { category = "event", title = "Tournament" }
end

-- Broadcasts from the engine (Game::broadcastAnnouncement), which sends the text message itself: the raids'
-- <announce> (source "raids/<raid name>", in game only: a holiday raid comes every 35-45 minutes) and the
-- tournaments' countdown and winner ("tournament").
function Announcements.fromEngine(text, source)
    local announcement = { category = "event", discord = false }
    if (source == "tournament") then
        announcement = Announcements.tournament(text)
        if (not announcement) then
            return
        end
    end
    Announcements.send(getPlayersOnline(), text, announcement, { source = source })
end

-- @everyone and @here: Gamemasters and up
Announcements.PING_EVERYONE_ACCESS = 3

-- Whether this staff member may use the ping; returns the ping to send (nil: none).
function Announcements.checkPing(cid, ping)
    ping = ping and tostring(ping):gsub("^@", ""):gsub("^%s+", ""):gsub("%s+$", "") or ""
    if (ping == "" or #ping > 100) then
        return nil
    end
    local lower = ping:lower()
    if (lower == "everyone" or lower == "here") then
        return getPlayerAccess(cid) >= Announcements.PING_EVERYONE_ACCESS and lower or nil
    end
    return lower == "verified" and "verified" or ping
end

-- A leading "@everyone", "@verified" or "@RoleName" picks the Discord ping and is taken out of the text:
-- "@everyone Server event tonight!" gives "everyone", "Server event tonight!". A role name has no spaces
-- (the bot ignores case, spaces and punctuation, so @SeniorTutor finds "Senior Tutor"). The third value is
-- the tag as typed, also when it isn't allowed.
function Announcements.takePing(cid, text)
    local tag, rest = tostring(text):match("^%s*@([%w_%-%.]+)%s+(.+)$")
    if (not tag) then
        return nil, text, nil
    end
    return Announcements.checkPing(cid, tag), rest, tag
end

-- a staff broadcast from /b (the protocol's own broadcast, which the client shows as "Name: text")
function Announcements.staff(cid, text, ping)
    local name = getCreatureName(cid)
    Announcements.send(getPlayersOnline(), name .. ": " .. text,
        { category = "staff", title = name, text = text, author = name, ping = ping })
end

-- The Discord roles staff can pick in the Admin window, sent by the bot (announcements.roles), and whether the
-- bot may ping @everyone. Kept in a global storage (shared by the Lua states, at most 255 characters saved).
Announcements.MAX_ROLES = 25

function Announcements.pingRoles()
    local raw = getStorage(GLOBAL_STORAGES.DISCORD_PING_ROLES)
    local data = type(raw) == "string" and raw:sub(1, 1) == "{" and JSON.decode(raw) or nil
    if (type(data) ~= "table") then
        return { roles = {}, everyone = false }
    end
    return { roles = type(data.roles) == "table" and data.roles or {}, everyone = data.everyone == true }
end

local function handleRoles(params)
    if (type(params.roles) ~= "table") then
        DiscordBridge.fail("invalid_params", "roles must be a list of role names")
    end
    local roles = {}
    for _, name in ipairs(params.roles) do
        if (type(name) == "string" and #name > 0 and #name <= 100 and #roles < Announcements.MAX_ROLES) then
            roles[#roles + 1] = DiscordBridge.sanitizeText(name, 100)
        end
    end
    local everyone = params.everyone == true
    local encoded = JSON.encode({ roles = roles, everyone = everyone })
    while (#encoded > 250 and #roles > 0) do
        table.remove(roles)
        encoded = JSON.encode({ roles = roles, everyone = everyone })
    end
    doSetStorage(GLOBAL_STORAGES.DISCORD_PING_ROLES, encoded)
    return { roles = #roles }
end

-- The calendar's occurrences overlapping [from, to] for Discord's scheduled events (at most 60 days).
local function handleCalendarRange(params)
    local from, to = tonumber(params.from), tonumber(params.to)
    if (not from or not to or to <= from or to - from > 60 * 86400) then
        DiscordBridge.fail("invalid_params", "from and to must be unix seconds at most 60 days apart")
    end
    local events = JSON.array()
    for _, event in ipairs(EventCalendar.rangeData(from, to).events) do
        events[#events + 1] = event
    end
    return { from = math.floor(from), to = math.floor(to), events = events }
end

if (DiscordBridge and DiscordBridge.registerHandler) then
    DiscordBridge.registerHandler("announcements.roles", handleRoles)
    DiscordBridge.registerHandler("calendar.range", handleCalendarRange)
end
