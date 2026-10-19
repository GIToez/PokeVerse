-- Reports: bug reports and player reports from the in-game Reports window (game_reports). Each report is a
-- row in `reports` with its history in `report_events`; staff read and answer them in the same window, and
-- the Discord bridge posts each one as a forum post (docs/reports.md).
--
-- The client talks JSON on EXTENDED_IDS.REPORT:
--   client -> server  {action = "hello"}                                   (at login)
--                     {action = "submit", kind, category, title, description, target, statement, client}
--                     {action = "mine"}
--   staff            {action = "list", kind, status, query, offset}
--                     {action = "get", id}
--                     {action = "status", id, status, note}
--                     {action = "goto", id, where}       (where: report, target, reporter, targetNow)
--   server -> client  {type = "config", kinds, staff, canEdit}
--                     {type = "submitted", id} / {type = "error", text}
--                     {type = "mine", reports}
--                     {type = "list", reports, total, offset} / {type = "report", report}
--                     {type = "changed", id, title, status, note}     (to the reporter)
--
-- Discord: a new report sends {kind = "report", action = "created", report}; a status change or a note sends
-- {kind = "report", action = "updated", report, change}. Player reports are "admin" scoped. The bot answers
-- tags changed on Discord with the "report.setStatus" request.

Reports = {}

Reports.VIEW_ACCESS = 1 -- Tutor and up read the reports
Reports.EDIT_ACCESS = 3 -- Gamemaster and up change the status, add notes and go to the spot
Reports.PAGE = 30
Reports.TITLE_MIN, Reports.TITLE_MAX = 4, 80
Reports.TEXT_MIN, Reports.TEXT_MAX = 15, 1500
Reports.NOTE_MAX = 500
Reports.PER_HOUR = 4 -- per account
Reports.PER_DAY = 12
Reports.MINE = 30

-- Keys are stored in the database and are the Discord tag names' keys: only add new ones.
Reports.KINDS = {
    bug = {
        name = "Bug",
        categories = {
            { key = "client", name = "Client and windows" },
            { key = "map", name = "Map" },
            { key = "npc", name = "NPCs and quests" },
            { key = "pokemon", name = "Pokemon and moves" },
            { key = "items", name = "Items and shops" },
            { key = "tasks", name = "Tasks and events" },
            { key = "other", name = "Other" },
        },
        statuses = {
            { key = "open", name = "Open" },
            { key = "confirmed", name = "Confirmed" },
            { key = "planned", name = "Planned" },
            { key = "in_progress", name = "In progress" },
            { key = "fixed", name = "Fixed", closed = true },
            { key = "wont_fix", name = "Won't fix", closed = true },
            { key = "duplicate", name = "Duplicate", closed = true },
        },
    },
    player = {
        name = "Player report",
        categories = {
            { key = "cheating", name = "Cheating or botting" },
            { key = "bug_abuse", name = "Bug abuse" },
            { key = "harassment", name = "Harassment or insults" },
            { key = "scam", name = "Scamming" },
            { key = "name", name = "Offensive name" },
            { key = "spam", name = "Spam or advertising" },
            { key = "other", name = "Other" },
        },
        statuses = {
            { key = "open", name = "Open" },
            { key = "investigating", name = "Investigating" },
            { key = "action_taken", name = "Action taken", closed = true },
            { key = "no_action", name = "No action", closed = true },
            { key = "duplicate", name = "Duplicate", closed = true },
        },
    },
}
Reports.KIND_ORDER = { "bug", "player" }

local FIELDS = {
    id = "number", kind = "string", category = "string", status = "string", title = "string",
    description = "string", account_id = "number", player_id = "number", player_name = "string",
    player_level = "number", target_id = "number", target_name = "string", statement = "string",
    posx = "number", posy = "number", posz = "number", area = "string", pokemon = "string",
    client = "string", context = "string", staff_note = "string", handled_by = "string",
    reporter_seen = "number", created_at = "number", updated_at = "number",
}
local SUMMARY_FIELDS = {
    id = "number", kind = "string", category = "string", status = "string", title = "string",
    player_name = "string", target_name = "string", staff_note = "string", reporter_seen = "number",
    created_at = "number", updated_at = "number",
}
local EVENT_FIELDS = { at = "number", author = "string", source = "string", status = "string", note = "string" }

local recent = {} -- account id -> { times of the reports sent }
local chats = {} -- player guid -> { {at, channel, text} }, the newest last
local CHAT_KEEP, CHAT_AGE = 10, 900
local PRIVATE_CHANNELS = { [CHANNEL_STAFF or 2] = true, [CHANNEL_COUNSELOR or 4] = true }

-- Called for every channel message (onTalkChannel): a player report sends the reported player's last lines.
Reports.onChannelMessage = function(cid, channelId, message)
    if (not isPlayer(cid) or PRIVATE_CHANNELS[channelId]) then
        return
    end
    local guid = getPlayerGUID(cid)
    local lines = chats[guid] or {}
    lines[#lines + 1] = { at = os.time(), channel = channelId, text = tostring(message):sub(1, 255) }
    if (#lines > CHAT_KEEP) then
        table.remove(lines, 1)
    end
    chats[guid] = lines
end

local function recentChatOf(guid)
    local list = JSON.array()
    local cutoff = os.time() - CHAT_AGE
    for _, line in ipairs(chats[guid] or {}) do
        if (line.at >= cutoff) then
            list[#list + 1] = line
        end
    end
    return list
end

local function worldId()
    return getConfigValue("worldId") or 0
end

local function send(cid, data)
    doSendPlayerExtendedOpcode(cid, EXTENDED_IDS.REPORT, JSON.encode(data))
end

local function fail(cid, text)
    send(cid, { type = "error", text = text })
end

local function lookup(list, key)
    for _, entry in ipairs(list) do
        if (entry.key == key) then
            return entry
        end
    end
end

local function categoryOf(kind, key)
    local info = Reports.KINDS[kind]
    return info and lookup(info.categories, key)
end

local function statusOf(kind, key)
    local info = Reports.KINDS[kind]
    return info and lookup(info.statuses, key)
end

-- One line of plain text: control characters and the NPC keyword braces go
local function clean(text, max, multiline)
    text = tostring(text or "")
    if (multiline) then
        text = text:gsub("\r\n?", "\n"):gsub("[%z\1-\9\11-\31\127]", ""):gsub("\n\n\n+", "\n\n")
    else
        text = text:gsub("[%z\1-\31\127]", " ")
    end
    text = text:gsub("[{}]", ""):gsub("^%s+", ""):gsub("%s+$", "")
    if (#text > max) then
        text = text:sub(1, max)
    end
    return text
end

local function query(sql, fields)
    return DiscordBridge.queryRows(sql, fields)
end

local function access(cid)
    return isPlayer(cid) and getPlayerAccess(cid) or 0
end

Reports.canView = function(cid)
    return access(cid) >= Reports.VIEW_ACCESS
end

Reports.canEdit = function(cid)
    return access(cid) >= Reports.EDIT_ACCESS
end

---------------------------------------------------------------------------------------------------
-- What goes with a report
---------------------------------------------------------------------------------------------------

local function areaOf(pos)
    local zone = Weather and Weather.zoneAt and Weather.zoneAt(pos)
    if (zone) then
        return zone.region and zone.region.name and string.format("near %s, %s", zone.name, zone.region.name)
            or string.format("near %s", zone.name)
    end
    return ""
end

local function pokemonOf(cid)
    local pokemon = getPlayerPokemon and getPlayerPokemon(cid)
    if (pokemon and isCreature(pokemon)) then
        local health = math.floor(getCreatureHealth(pokemon) * 100 / math.max(1, getCreatureMaxHealth(pokemon)))
        return string.format("%s, level %d, %d%% health", getCreatureName(pokemon),
            tonumber(getPlayerPokemonLevel(cid)) or 0, health)
    end
    local ball = getPlayerBall and getPlayerBall(cid)
    if (ball and isItem(ball) and getBallPokemonName) then
        local name = getBallPokemonName(ball.uid)
        if (name and name ~= -1) then
            return string.format("%s, level %d, in its ball", name, tonumber(getPlayerPokemonLevel(cid)) or 0)
        end
    end
    return ""
end

local function vocationOf(cid)
    if (Vocations and Vocations.get) then
        local vocation = Vocations.get(cid)
        if (vocation) then
            return vocation.name
        end
    end
    local info = getVocationInfo(getPlayerVocation(cid))
    return info and info.name or ""
end

-- The client's own description: {os, version, build, renderer, window, fps, ping}
local function clientText(client)
    if (type(client) ~= "table") then
        return ""
    end
    local parts = {}
    for _, key in ipairs({ "os", "version", "build", "renderer", "window", "fps", "ping" }) do
        local value = client[key]
        if (value ~= nil and value ~= "") then
            parts[#parts + 1] = string.format("%s: %s", key, clean(value, 60))
        end
    end
    return clean(table.concat(parts, "; "), 255)
end

---------------------------------------------------------------------------------------------------
-- Rows
---------------------------------------------------------------------------------------------------

local function getRow(id)
    return query(string.format("SELECT * FROM `reports` WHERE `id` = %d AND `world_id` = %d;",
        tonumber(id) or 0, worldId()), FIELDS)[1]
end

local function getEvents(id)
    return query(string.format("SELECT `at`, `author`, `source`, `status`, `note` FROM `report_events` " ..
        "WHERE `report_id` = %d ORDER BY `id`;", tonumber(id) or 0), EVENT_FIELDS)
end

local function addEvent(id, author, source, status, note)
    db.executeQuery(string.format("INSERT INTO `report_events` (`report_id`, `at`, `author`, `source`, `status`, " ..
        "`note`) VALUES (%d, %d, %s, %s, %s, %s);", id, os.time(), db.escapeString(author), db.escapeString(source),
        db.escapeString(status or ""), db.escapeString(note or "")))
end

local function summary(row)
    local status = statusOf(row.kind, row.status)
    return {
        id = row.id, kind = row.kind, category = row.category, status = row.status, title = row.title,
        reporter = row.player_name, target = row.target_name ~= "" and row.target_name or nil,
        note = row.staff_note ~= "" and row.staff_note or nil, created = row.created_at, updated = row.updated_at,
        closed = status and status.closed == true or false, unseen = row.reporter_seen == 0 or nil,
    }
end

local function details(row)
    local data = summary(row)
    data.description = row.description
    data.statement = row.statement ~= "" and row.statement or nil
    data.position = { x = row.posx, y = row.posy, z = row.posz }
    data.area = row.area ~= "" and row.area or nil
    data.pokemon = row.pokemon ~= "" and row.pokemon or nil
    data.client = row.client ~= "" and row.client or nil
    data.level = row.player_level
    data.handledBy = row.handled_by ~= "" and row.handled_by or nil
    local context = row.context ~= "" and JSON.decode(row.context)
    data.context = type(context) == "table" and context or nil
    local events = JSON.array()
    for _, event in ipairs(getEvents(row.id)) do
        events[#events + 1] = event
    end
    data.events = events
    data.online = getPlayerByName(row.player_name) ~= nil
    if (row.target_name ~= "") then
        data.targetOnline = getPlayerByName(row.target_name) ~= nil
    end
    return data
end

---------------------------------------------------------------------------------------------------
-- Discord
---------------------------------------------------------------------------------------------------

local function discordIdOf(accountId)
    local link = DiscordAccounts and DiscordAccounts.getLinkByAccount and DiscordAccounts.getLinkByAccount(accountId)
    return link and link.discord_user_id or nil
end

local function bridgeReport(row)
    local category = categoryOf(row.kind, row.category)
    local status = statusOf(row.kind, row.status)
    local context = row.context ~= "" and JSON.decode(row.context)
    local report = {
        id = row.id,
        kind = row.kind,
        kindName = Reports.KINDS[row.kind].name,
        category = row.category,
        categoryName = category and category.name or row.category,
        status = row.status,
        statusName = status and status.name or row.status,
        closed = status and status.closed == true or false,
        title = row.title,
        description = row.description,
        reporter = { name = row.player_name, level = row.player_level, discordUserId = discordIdOf(row.account_id) },
        createdAt = row.created_at,
        updatedAt = row.updated_at,
    }
    if (type(context) == "table") then
        report.reporter.vocation = context.vocation
    end
    if (row.kind == "bug") then
        report.position = { x = row.posx, y = row.posy, z = row.posz }
    end
    report.area = row.area ~= "" and row.area or nil
    report.pokemon = row.pokemon ~= "" and row.pokemon or nil
    report.client = row.client ~= "" and row.client or nil
    if (row.target_name ~= "") then
        report.target = { name = row.target_name }
        if (type(context) == "table" and type(context.target) == "table") then
            report.target.level = context.target.level
            report.target.online = context.target.online
            report.target.position = context.target.position
            report.target.chat = context.target.chat
        end
        report.position = { x = row.posx, y = row.posy, z = row.posz }
    end
    report.statement = row.statement ~= "" and row.statement or nil
    return report
end

local function emit(action, row, change)
    if (not (DiscordBridge and DiscordBridge.isEnabled())) then
        return
    end
    DiscordBridge.safeCall("Reports.emit", function()
        DiscordBridge.emit({
            kind = "report",
            scope = row.kind == "player" and "admin" or nil,
            action = action,
            report = bridgeReport(row),
            change = change,
        })
    end)
end

---------------------------------------------------------------------------------------------------
-- Sending a report
---------------------------------------------------------------------------------------------------

local function rateLimited(accountId)
    local now = os.time()
    local times = recent[accountId] or {}
    local kept, lastHour = {}, 0
    for _, time in ipairs(times) do
        if (now - time < 86400) then
            kept[#kept + 1] = time
            if (now - time < 3600) then
                lastHour = lastHour + 1
            end
        end
    end
    recent[accountId] = kept
    if (lastHour >= Reports.PER_HOUR) then
        return "You sent several reports this hour. Please wait a little before sending another."
    end
    if (#kept >= Reports.PER_DAY) then
        return "You sent the most reports for today. Thank you! You can send more tomorrow."
    end
end

-- Returns the new report's id, or nil and the reason
Reports.create = function(cid, data)
    local kind = Reports.KINDS[data.kind] and data.kind or nil
    if (not kind) then
        return nil, "Pick what you want to report."
    end
    local category = categoryOf(kind, data.category) and data.category or "other"
    local title = clean(data.title, Reports.TITLE_MAX)
    local description = clean(data.description, Reports.TEXT_MAX, true)
    if (#title < Reports.TITLE_MIN) then
        return nil, string.format("Give your report a title of at least %d letters.", Reports.TITLE_MIN)
    end
    if (#description < Reports.TEXT_MIN) then
        return nil, string.format("Describe it in at least %d letters, so the team can follow it.", Reports.TEXT_MIN)
    end

    local accountId = getPlayerAccountId(cid)
    if (not data.internal) then
        local limited = rateLimited(accountId)
        if (limited) then
            return nil, limited
        end
    end

    local context = { vocation = vocationOf(cid) }
    local targetName, targetId = "", 0
    if (kind == "player") then
        targetName = clean(data.target, 30)
        if (targetName == "") then
            return nil, "Write the name of the player you report."
        end
        targetId = tonumber(getPlayerGUIDByName(targetName)) or 0
        if (targetId == 0) then
            return nil, string.format("There is no player called %s.", targetName)
        end
        targetName = getPlayerNameByGUID(targetId) or targetName
        if (targetId == getPlayerGUID(cid)) then
            return nil, "You can't report yourself."
        end
        local target = getPlayerByName(targetName)
        context.target = { online = target ~= nil }
        local lines = recentChatOf(targetId)
        if (#lines > 0) then
            context.target.chat = lines
        end
        if (target) then
            local pos = getCreaturePosition(target)
            context.target.level = getPlayerLevel(target)
            context.target.position = { x = pos.x, y = pos.y, z = pos.z }
        end
    end

    local pos = getCreaturePosition(cid)
    local now = os.time()
    local ok = db.executeQuery(string.format("INSERT INTO `reports` (`world_id`, `kind`, `category`, `status`, " ..
        "`title`, `description`, `account_id`, `player_id`, `player_name`, `player_level`, `target_id`, " ..
        "`target_name`, `statement`, `posx`, `posy`, `posz`, `area`, `pokemon`, `client`, `context`, `staff_note`, " ..
        "`created_at`, `updated_at`) VALUES (%d, %s, %s, 'open', %s, %s, %d, %d, %s, %d, %d, %s, %s, %d, %d, %d, " ..
        "%s, %s, %s, %s, '', %d, %d);",
        worldId(), db.escapeString(kind), db.escapeString(category), db.escapeString(title),
        db.escapeString(description), accountId, getPlayerGUID(cid), db.escapeString(getCreatureName(cid)),
        getPlayerLevel(cid), targetId, db.escapeString(targetName),
        db.escapeString(clean(data.statement, 255)), pos.x, pos.y, pos.z, db.escapeString(areaOf(pos)),
        db.escapeString(clean(pokemonOf(cid), 64)), db.escapeString(clientText(data.client)),
        db.escapeString(JSON.encode(context)), now, now))
    if (not ok) then
        return nil, "The report could not be saved. Please try again later."
    end
    local id = db.lastInsertId()
    recent[accountId] = recent[accountId] or {}
    table.insert(recent[accountId], now)

    local row = getRow(id)
    if (row) then
        emit("created", row)
    end
    for _, staff in ipairs(getPlayersOnline()) do
        if (Reports.canView(staff) and staff ~= cid) then
            doPlayerSendTextMessage(staff, MESSAGE_STATUS_CONSOLE_BLUE, string.format(
                "[Reports] New %s #%d from %s: %s", kind == "bug" and "bug report" or "player report", id,
                getCreatureName(cid), title))
            send(staff, { type = "new", id = id })
        end
    end
    if (kind == "bug" and ACHIEVEMENT_IDS and ACHIEVEMENT_IDS.REPORT_BUG) then
        doPlayerAchievementCheck(cid, ACHIEVEMENT_IDS.REPORT_BUG)
    end
    return id
end

---------------------------------------------------------------------------------------------------
-- Answering a report
---------------------------------------------------------------------------------------------------

-- Tells the reporter, now or at their next login
local function tellReporter(row, status, note)
    local reporter = getPlayerByName(row.player_name)
    if (not reporter) then
        return
    end
    local info = statusOf(row.kind, status)
    if (row.kind == "player") then
        note = nil -- what staff did about another player stays with staff
    end
    local text = string.format("Your report #%d \"%s\" is now: %s.", row.id, row.title, info and info.name or status)
    if (note and note ~= "") then
        text = text .. " Staff: " .. note
    end
    doPlayerSendTextMessage(reporter, MESSAGE_EVENT_ADVANCE, text)
    send(reporter, { type = "changed", id = row.id, title = row.title, status = status, note = note })
    db.executeQuery(string.format("UPDATE `reports` SET `reporter_seen` = 1 WHERE `id` = %d;", row.id))
end

-- Changes the status and/or adds a note. Returns the updated row, or nil and the reason.
Reports.update = function(id, status, note, author, source)
    local row = getRow(id)
    if (not row) then
        return nil, "There is no such report."
    end
    status = status and status ~= "" and status or row.status
    if (not statusOf(row.kind, status)) then
        return nil, "That status doesn't exist for this kind of report."
    end
    note = clean(note, Reports.NOTE_MAX, true)
    if (status == row.status and note == "") then
        return row, nil, false
    end
    local now = os.time()
    db.executeQuery(string.format("UPDATE `reports` SET `status` = %s, `staff_note` = %s, `handled_by` = %s, " ..
        "`updated_at` = %d, `reporter_seen` = 0 WHERE `id` = %d;", db.escapeString(status),
        db.escapeString(note ~= "" and note or row.staff_note), db.escapeString(author), now, row.id))
    addEvent(row.id, author, source, status ~= row.status and status or "", note)
    local previous = row.status
    row = getRow(id)
    emit("updated", row, {
        status = status, previousStatus = previous, note = note ~= "" and note or nil, by = author, source = source,
    })
    tellReporter(row, status, note)
    return row, nil, true
end

---------------------------------------------------------------------------------------------------
-- Lists
---------------------------------------------------------------------------------------------------

local function sendMine(cid)
    local rows = query(string.format("SELECT `id`, `kind`, `category`, `status`, `title`, `player_name`, " ..
        "`target_name`, `staff_note`, `reporter_seen`, `created_at`, `updated_at` FROM `reports` WHERE " ..
        "`account_id` = %d AND `world_id` = %d ORDER BY `id` DESC LIMIT %d;", getPlayerAccountId(cid), worldId(),
        Reports.MINE), SUMMARY_FIELDS)
    local list = JSON.array()
    for _, row in ipairs(rows) do
        local entry = summary(row)
        if (row.kind == "player") then
            entry.note = nil -- what staff did about another player stays with staff
        end
        list[#list + 1] = entry
    end
    send(cid, { type = "mine", reports = list })
    db.executeQuery(string.format("UPDATE `reports` SET `reporter_seen` = 1 WHERE `account_id` = %d AND " ..
        "`reporter_seen` = 0;", getPlayerAccountId(cid)))
end

local function sendList(cid, data)
    local where = { string.format("`world_id` = %d", worldId()) }
    if (Reports.KINDS[data.kind]) then
        where[#where + 1] = "`kind` = " .. db.escapeString(data.kind)
    end
    if (data.status == "active" or data.status == "closed") then
        local closed = {}
        for _, info in pairs(Reports.KINDS) do
            for _, status in ipairs(info.statuses) do
                if (status.closed) then
                    closed[db.escapeString(status.key)] = true
                end
            end
        end
        local keys = {}
        for key in pairs(closed) do
            keys[#keys + 1] = key
        end
        where[#where + 1] = string.format("`status` %s (%s)", data.status == "closed" and "IN" or "NOT IN",
            table.concat(keys, ", "))
    elseif (type(data.status) == "string" and data.status ~= "" and data.status ~= "all") then
        where[#where + 1] = "`status` = " .. db.escapeString(clean(data.status, 16))
    end
    local search = clean(data.query, 40)
    if (search ~= "") then
        local id = tonumber((search:gsub("^#", "")))
        local like = db.escapeString("%" .. search:gsub("[%%_\\]", "\\%0") .. "%")
        where[#where + 1] = string.format("(`title` LIKE %s OR `player_name` LIKE %s OR `target_name` LIKE %s%s)",
            like, like, like, id and string.format(" OR `id` = %d", id) or "")
    end
    local offset = math.max(0, math.floor(tonumber(data.offset) or 0))
    local clause = table.concat(where, " AND ")
    local total = DiscordBridge.queryNumber("SELECT COUNT(*) AS `count` FROM `reports` WHERE " .. clause .. ";",
        "count") or 0
    local rows = query(string.format("SELECT `id`, `kind`, `category`, `status`, `title`, `player_name`, " ..
        "`target_name`, `staff_note`, `reporter_seen`, `created_at`, `updated_at` FROM `reports` WHERE %s " ..
        "ORDER BY `id` DESC LIMIT %d OFFSET %d;", clause, Reports.PAGE, offset), SUMMARY_FIELDS)
    local list = JSON.array()
    for _, row in ipairs(rows) do
        local entry = summary(row)
        entry.unseen = nil
        list[#list + 1] = entry
    end
    send(cid, { type = "list", reports = list, total = total, offset = offset, page = Reports.PAGE })
end

local function openCount()
    local closed = {}
    for _, info in pairs(Reports.KINDS) do
        for _, status in ipairs(info.statuses) do
            if (status.closed) then
                closed[#closed + 1] = db.escapeString(status.key)
            end
        end
    end
    return DiscordBridge.queryNumber(string.format("SELECT COUNT(*) AS `count` FROM `reports` WHERE `world_id` = %d " ..
        "AND `status` NOT IN (%s);", worldId(), table.concat(closed, ", ")), "count") or 0
end

local function sendConfig(cid)
    local kinds = JSON.array()
    for _, key in ipairs(Reports.KIND_ORDER) do
        local info = Reports.KINDS[key]
        kinds[#kinds + 1] = { key = key, name = info.name, categories = info.categories, statuses = info.statuses }
    end
    local unseen = DiscordBridge.queryNumber(string.format("SELECT COUNT(*) AS `count` FROM `reports` WHERE " ..
        "`account_id` = %d AND `reporter_seen` = 0;", getPlayerAccountId(cid)), "count") or 0
    local staff = Reports.canView(cid)
    local open = staff and openCount() or nil
    send(cid, {
        type = "config", kinds = kinds, staff = staff, canEdit = Reports.canEdit(cid),
        unseen = unseen, open = open, limits = { titleMin = Reports.TITLE_MIN, titleMax = Reports.TITLE_MAX,
        textMin = Reports.TEXT_MIN, textMax = Reports.TEXT_MAX, noteMax = Reports.NOTE_MAX },
    })
    if (unseen > 0) then
        doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, string.format(
            "[Reports] The team answered %d of your reports. Open the Reports window to see them.", unseen))
    end
    if (open and open > 0) then
        doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, string.format(
            "[Reports] %d open report%s. Open the Reports window (All reports) or say /reports.", open,
            open == 1 and "" or "s"))
    end
end

Reports.get = getRow

-- Where "Go there" takes staff: "report" (where it was sent), "target" (where the reported player stood
-- then), "reporter" or "targetNow" (where that player is now, when online)
Reports.destination = function(row, where)
    if (where == "target") then
        local context = row.context ~= "" and JSON.decode(row.context)
        local pos = type(context) == "table" and type(context.target) == "table" and context.target.position
        if (type(pos) ~= "table") then
            return nil, "The reported player was offline when the report was sent."
        end
        return { x = pos.x, y = pos.y, z = pos.z }
    elseif (where == "reporter" or where == "targetNow") then
        local name = where == "reporter" and row.player_name or row.target_name
        local player = name ~= "" and getPlayerByName(name)
        if (not player) then
            return nil, string.format("%s is not online.", name ~= "" and name or "The player")
        end
        return getCreaturePosition(player)
    end
    return { x = row.posx, y = row.posy, z = row.posz }
end


-- The /reports talkaction: the newest open reports, or one of them in full
Reports.sayList = function(cid)
    local rows = query(string.format("SELECT `id`, `kind`, `category`, `status`, `title`, `player_name`, " ..
        "`target_name`, `staff_note`, `reporter_seen`, `created_at`, `updated_at` FROM `reports` WHERE " ..
        "`world_id` = %d ORDER BY `id` DESC LIMIT 200;", worldId()), SUMMARY_FIELDS)
    local lines = {}
    for _, row in ipairs(rows) do
        local status = statusOf(row.kind, row.status)
        if (not (status and status.closed) and #lines < 15) then
            lines[#lines + 1] = string.format("#%d [%s, %s] %s - by %s%s", row.id, row.kind,
                status and status.name or row.status, row.title, row.player_name,
                row.target_name ~= "" and (" about " .. row.target_name) or "")
        end
    end
    if (#lines == 0) then
        doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "There are no open reports.")
        return
    end
    doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Open reports (newest first, the Reports window " ..
        "on the top bar has them all):")
    for _, line in ipairs(lines) do
        doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, line)
    end
end

Reports.sayOne = function(cid, id)
    local row = getRow(id)
    if (not row) then
        doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "There is no report #" .. id .. ".")
        return
    end
    local status = statusOf(row.kind, row.status)
    local text = string.format("Report #%d (%s, %s)\n%s\n\nFrom: %s, level %d\n%sPosition: %d, %d, %d %s\n" ..
        "Sent: %s\n\n%s", row.id, row.kind, status and status.name or row.status, row.title, row.player_name,
        row.player_level, row.target_name ~= "" and ("About: " .. row.target_name .. "\n") or "", row.posx, row.posy,
        row.posz, row.area, os.date("%c", row.created_at), row.description)
    if (row.staff_note ~= "") then
        text = text .. "\n\nStaff note (" .. row.handled_by .. "): " .. row.staff_note
    end
    doPlayerPopupFYI(cid, text)
end

Reports.onClientMessage = function(cid, buffer)
    local data = JSON.decode(buffer)
    if (type(data) ~= "table") then
        return
    end
    local action = data.action
    if (action == "hello") then
        sendConfig(cid)
    elseif (action == "submit") then
        data.internal = nil
        local id, reason = Reports.create(cid, data)
        if (id) then
            send(cid, { type = "submitted", id = id })
        else
            fail(cid, reason)
        end
    elseif (action == "mine") then
        sendMine(cid)
    elseif (not Reports.canView(cid)) then
        return
    elseif (action == "list") then
        sendList(cid, data)
    elseif (action == "get") then
        local row = getRow(data.id)
        if (row) then
            send(cid, { type = "report", report = details(row) })
        else
            fail(cid, "There is no such report.")
        end
    elseif (not Reports.canEdit(cid)) then
        fail(cid, "Only Gamemasters and up can answer reports.")
    elseif (action == "status") then
        local row, reason = Reports.update(data.id, data.status, data.note, getCreatureName(cid), "game")
        if (row) then
            send(cid, { type = "report", report = details(row) })
        else
            fail(cid, reason)
        end
    elseif (action == "goto") then
        local row = getRow(data.id)
        if (not row) then
            return fail(cid, "There is no such report.")
        end
        local pos, reason = Reports.destination(row, data.where)
        if (not pos) then
            return fail(cid, reason)
        end
        doTeleportThing(cid, pos)
        doSendMagicEffect(getCreaturePosition(cid), CONST_ME_TELEPORT)
    end
end

---------------------------------------------------------------------------------------------------
-- Bridge requests (the bot)
---------------------------------------------------------------------------------------------------

DiscordBridge.registerHandler("report.setStatus", function(params)
    local id = tonumber(params.id)
    if (not id) then
        DiscordBridge.fail("invalid_params", "id is required")
    end
    local author = clean(params.by, 32)
    local row, reason, changed = Reports.update(id, clean(params.status, 16), params.note,
        author ~= "" and author .. " (Discord)" or "Discord", "discord")
    if (not row) then
        DiscordBridge.fail("invalid_params", reason)
    end
    return { id = row.id, status = row.status, changed = changed == true }
end)

DiscordBridge.registerHandler("report.get", function(params)
    local row = getRow(params.id)
    if (not row) then
        return { found = false }
    end
    return { found = true, report = bridgeReport(row) }
end)
