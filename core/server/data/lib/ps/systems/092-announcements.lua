-- Server-wide announcements for the modern client's news banner (game_newsbanner). doBroadcastMessage sends
-- EXTENDED_IDS.ANNOUNCEMENT to every player just before its text message:
--   {c = category, h = title, x = text, f = the text message as sent}
-- The client shows the banner and hides the red text it already showed; old clients only see the text.
-- Categories: event, legendary, server, staff, milestone, tip and news. A broadcast that doesn't say its
-- category gets one from the script that sent it (BY_SOURCE), so every existing broadcast gets the banner.
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

function Announcements.payload(text, announcement, caller)
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
    return JSON.encode({ c = category, h = title, x = body, f = text })
end

function Announcements.send(players, text, announcement, caller)
    if (not EXTENDED_IDS.ANNOUNCEMENT) then
        return
    end
    local ok, payload = pcall(Announcements.payload, tostring(text), announcement, caller)
    if (not ok) then
        print("> Announcements: " .. tostring(payload))
        return
    end
    for _, pid in ipairs(players) do
        if (isPlayer(pid)) then
            doSendPlayerExtendedOpcode(pid, EXTENDED_IDS.ANNOUNCEMENT, payload)
        end
    end
end

-- a staff broadcast from /b (the protocol's own broadcast, which the client shows as "Name: text")
function Announcements.staff(cid, text)
    local name = getCreatureName(cid)
    Announcements.send(getPlayersOnline(), name .. ": " .. text, { category = "staff", title = name, text = text })
end
