-- Reports: bug reports and player reports from the in-game Reports window (game_reports). Each report is a
-- row in `reports` with its history in `report_events`; staff read and answer them in the same window, and
-- the Discord bridge posts each one as a forum post (docs/reports.md).
--
-- The client talks JSON on EXTENDED_IDS.REPORT:
--   client -> server  {action = "hello"}                                   (at login)
--                     {action = "submit", kind, category, title, description, target, statement, client}
--                     {action = "mine"}
--                     {action = "shot", id, i, n, data}           (the screenshot, base64 PNG in parts)
--   staff            {action = "list", kind, status, assigned, query, offset}
--                     {action = "get", id} / {action = "getShot", id} / {action = "marks"}
--                     {action = "status", id, status, note}
--                     {action = "assign", id, to}  (to: "me" or "")  / {action = "duplicate", id, of}
--                     {action = "goto", id, where}       (where: report, target, reporter, targetNow)
--   server -> client  {type = "config", kinds, staff, canEdit}
--                     {type = "submitted", id} / {type = "error", text}
--                     {type = "mine", reports}
--                     {type = "list", reports, total, offset} / {type = "report", report}
--                     {type = "changed", id, title, status, note}     (to the reporter)
--                     {type = "shotSaved", id} / {type = "shot", id, i, n, data} / {type = "marks", marks}
--
-- Discord: a new report sends {kind = "report", action = "created", report}; a status change or a note sends
-- {kind = "report", action = "updated", report, change}; a finished screenshot sends action = "screenshot" (the
-- bot reads it with "report.screenshot"). Player reports are "admin" scoped. The bot answers tags changed on
-- Discord with the "report.setStatus" request.

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
    assigned_to = "string", duplicate_of = "number", reporter_seen = "number", created_at = "number",
    updated_at = "number",
}
local SUMMARY_FIELDS = {
    id = "number", kind = "string", category = "string", status = "string", title = "string",
    player_name = "string", target_name = "string", staff_note = "string", reporter_seen = "number",
    assigned_to = "string", duplicate_of = "number", created_at = "number", updated_at = "number",
}
local SUMMARY_COLUMNS = "`id`, `kind`, `category`, `status`, `title`, `player_name`, `target_name`, `staff_note`, " ..
    "`reporter_seen`, `assigned_to`, `duplicate_of`, `created_at`, `updated_at`"
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

local function duplicatesOf(id)
    return query(string.format("SELECT `id`, `player_name` FROM `reports` WHERE `duplicate_of` = %d ORDER BY `id`;",
        tonumber(id) or 0), { id = "number", player_name = "string" })
end

local function shotOf(id)
    return query(string.format("SELECT `parts`, `received`, `done` FROM `report_screenshots` WHERE `report_id` = %d;",
        tonumber(id) or 0), { parts = "number", received = "number", done = "number" })[1]
end

local function summary(row)
    local status = statusOf(row.kind, row.status)
    return {
        id = row.id, kind = row.kind, category = row.category, status = row.status, title = row.title,
        reporter = row.player_name, target = row.target_name ~= "" and row.target_name or nil,
        note = row.staff_note ~= "" and row.staff_note or nil, created = row.created_at, updated = row.updated_at,
        closed = status and status.closed == true or false, unseen = row.reporter_seen == 0 or nil,
        assignedTo = row.assigned_to ~= "" and row.assigned_to or nil,
        duplicateOf = row.duplicate_of > 0 and row.duplicate_of or nil,
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
    local duplicates = JSON.array()
    for _, dup in ipairs(duplicatesOf(row.id)) do
        duplicates[#duplicates + 1] = { id = dup.id, reporter = dup.player_name }
    end
    data.duplicates = duplicates
    local shot = shotOf(row.id)
    data.screenshot = shot ~= nil and shot.done == 1
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
    report.assignedTo = row.assigned_to ~= "" and row.assigned_to or nil
    report.duplicateOf = row.duplicate_of > 0 and row.duplicate_of or nil
    report.duplicates = #duplicatesOf(row.id)
    local shot = shotOf(row.id)
    report.screenshot = shot ~= nil and shot.done == 1
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
local function tellReporter(row, status, note, original)
    local reporter = getPlayerByName(row.player_name)
    if (not reporter) then
        return
    end
    local info = statusOf(row.kind, status)
    if (row.kind == "player") then
        note = nil -- what staff did about another player stays with staff
    end
    local text = string.format("Your report #%d \"%s\" is now: %s.", row.id, row.title, info and info.name or status)
    if (original) then
        text = string.format("Your report #%d \"%s\" is the same as #%d, which is now: %s.", row.id, row.title,
            original, info and info.name or status)
    end
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
    -- out of "duplicate" means it is its own report again
    local duplicateOf = status == "duplicate" and row.duplicate_of or 0
    db.executeQuery(string.format("UPDATE `reports` SET `status` = %s, `staff_note` = %s, `handled_by` = %s, " ..
        "`updated_at` = %d, `reporter_seen` = 0, `duplicate_of` = %d WHERE `id` = %d;", db.escapeString(status),
        db.escapeString(note ~= "" and note or row.staff_note), db.escapeString(author), now, duplicateOf, row.id))
    addEvent(row.id, author, source, status ~= row.status and status or "", note)
    local previous = row.status
    row = getRow(id)
    emit("updated", row, {
        status = status, previousStatus = previous, note = note ~= "" and note or nil, by = author, source = source,
    })
    tellReporter(row, status, note)
    if (status ~= previous) then
        db.executeQuery(string.format("UPDATE `reports` SET `reporter_seen` = 0 WHERE `duplicate_of` = %d;", row.id))
        for _, dup in ipairs(duplicatesOf(row.id)) do
            local dupRow = getRow(dup.id)
            if (dupRow) then
                tellReporter(dupRow, status, note, row.id)
            end
        end
    end
    return row, nil, true
end

-- Takes a report ("" to let it go). Returns the row, or nil and the reason.
Reports.assign = function(id, name, author, source)
    local row = getRow(id)
    if (not row) then
        return nil, "There is no such report."
    end
    name = clean(name, 32)
    if (name == row.assigned_to) then
        return row
    end
    db.executeQuery(string.format("UPDATE `reports` SET `assigned_to` = %s, `updated_at` = %d WHERE `id` = %d;",
        db.escapeString(name), os.time(), row.id))
    addEvent(row.id, author, source, "", name ~= "" and ("Took the report: " .. name) or "Let the report go")
    row = getRow(id)
    emit("updated", row, { assignedTo = name ~= "" and name or nil, by = author, source = source })
    return row
end

-- Marks a report as the same as another one; its reporter hears about the other one from then on.
Reports.markDuplicate = function(id, of, author, source)
    local row = getRow(id)
    local original = getRow(of)
    if (not row or not original) then
        return nil, "There is no such report."
    end
    for _ = 1, 5 do
        if (original.duplicate_of > 0) then
            original = getRow(original.duplicate_of) or original
        end
    end
    if (original.id == row.id) then
        return nil, "A report can't be the same as itself."
    end
    if (original.kind ~= row.kind) then
        return nil, "Both reports must be of the same kind."
    end
    local previous = row.status
    db.executeQuery(string.format("UPDATE `reports` SET `status` = 'duplicate', `duplicate_of` = %d, `handled_by` = %s, " ..
        "`updated_at` = %d, `reporter_seen` = 0 WHERE `id` = %d;", original.id, db.escapeString(author), os.time(),
        row.id))
    db.executeQuery(string.format("UPDATE `reports` SET `duplicate_of` = %d WHERE `duplicate_of` = %d;", original.id,
        row.id))
    local note = string.format("Same as #%d", original.id)
    addEvent(row.id, author, source, "duplicate", note)
    addEvent(original.id, author, source, "", string.format("#%d from %s is the same", row.id, row.player_name))
    row = getRow(id)
    emit("updated", row, { status = "duplicate", previousStatus = previous, note = note, duplicateOf = original.id,
        by = author, source = source })
    emit("updated", original, { duplicate = row.id, by = author, source = source })
    tellReporter(row, original.status, nil, original.id)
    return row
end

---------------------------------------------------------------------------------------------------
-- Screenshots
---------------------------------------------------------------------------------------------------

Reports.SHOT_PARTS = 400 -- of up to 3000 characters: about 900 KB of PNG
Reports.SHOT_PART = 3000
Reports.SHOT_WINDOW = 600 -- seconds after sending the report
Reports.SHOT_SLICE = 12000 -- for the bot: a bridge line is at most 16 KB
local shots = {} -- report id -> next part expected

local function receiveShot(cid, data)
    local id, part, parts = tonumber(data.id), tonumber(data.i), tonumber(data.n)
    local chunk = type(data.data) == "string" and data.data or ""
    if (not id or not part or not parts or parts < 1 or parts > Reports.SHOT_PARTS or part < 1 or part > parts
        or #chunk == 0 or #chunk > Reports.SHOT_PART + 100 or chunk:find("[^%w%+/=]")) then
        return
    end
    local row = getRow(id)
    if (not row or row.account_id ~= getPlayerAccountId(cid) or os.time() - row.created_at > Reports.SHOT_WINDOW) then
        return
    end
    if (part == 1) then
        if (shotOf(id)) then
            return
        end
        db.executeQuery(string.format("INSERT INTO `report_screenshots` (`report_id`, `parts`, `received`, `data`) " ..
            "VALUES (%d, %d, 0, '');", id, parts))
        shots[id] = 1
    end
    if (shots[id] ~= part) then
        return
    end
    db.executeQuery(string.format("UPDATE `report_screenshots` SET `data` = CONCAT(`data`, %s), `received` = %d, " ..
        "`done` = %d WHERE `report_id` = %d;", db.escapeString(chunk), part, part == parts and 1 or 0, id))
    if (part < parts) then
        shots[id] = part + 1
        return
    end
    shots[id] = nil
    send(cid, { type = "shotSaved", id = id })
    emit("screenshot", getRow(id) or row)
end

local function sendShot(cid, id)
    local rows = query(string.format("SELECT `data` FROM `report_screenshots` WHERE `report_id` = %d AND `done` = 1;",
        tonumber(id) or 0), { data = "string" })
    local data = rows[1] and rows[1].data
    if (not data or data == "") then
        return fail(cid, "That report has no screenshot.")
    end
    local size = Reports.SHOT_PART
    local parts = math.ceil(#data / size)
    for part = 1, parts do
        send(cid, { type = "shot", id = tonumber(id), i = part, n = parts, data = data:sub((part - 1) * size + 1,
            part * size) })
    end
end

-- Open reports with a position, for the staff map
local function sendMarks(cid)
    local closed = {}
    for _, info in pairs(Reports.KINDS) do
        for _, status in ipairs(info.statuses) do
            if (status.closed) then
                closed[#closed + 1] = db.escapeString(status.key)
            end
        end
    end
    local rows = query(string.format("SELECT `id`, `kind`, `status`, `title`, `posx`, `posy`, `posz` FROM `reports` " ..
        "WHERE `world_id` = %d AND `status` NOT IN (%s) AND `posx` > 0 ORDER BY `id` DESC LIMIT 300;", worldId(),
        table.concat(closed, ", ")), { id = "number", kind = "string", status = "string", title = "string",
        posx = "number", posy = "number", posz = "number" })
    local marks = JSON.array()
    for _, row in ipairs(rows) do
        marks[#marks + 1] = { id = row.id, kind = row.kind, status = row.status, title = row.title, x = row.posx,
            y = row.posy, z = row.posz }
    end
    send(cid, { type = "marks", marks = marks })
end

---------------------------------------------------------------------------------------------------
-- Lists
---------------------------------------------------------------------------------------------------

local function sendMine(cid)
    local rows = query(string.format("SELECT " .. SUMMARY_COLUMNS .. " FROM `reports` WHERE " ..
        "`account_id` = %d AND `world_id` = %d ORDER BY `id` DESC LIMIT %d;", getPlayerAccountId(cid), worldId(),
        Reports.MINE), SUMMARY_FIELDS)
    local list = JSON.array()
    for _, row in ipairs(rows) do
        local entry = summary(row)
        if (row.kind == "player") then
            entry.note = nil -- what staff did about another player stays with staff
        end
        if (row.duplicate_of > 0) then
            local original = getRow(row.duplicate_of)
            if (original) then
                entry.original = { id = original.id, status = original.status,
                    closed = (statusOf(original.kind, original.status) or {}).closed == true }
                entry.closed = entry.original.closed
            end
        end
        entry.assignedTo = nil
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
    if (data.assigned == "me") then
        where[#where + 1] = "`assigned_to` = " .. db.escapeString(getCreatureName(cid))
    elseif (data.assigned == "none") then
        where[#where + 1] = "`assigned_to` = ''"
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
    local rows = query(string.format("SELECT " .. SUMMARY_COLUMNS .. " FROM `reports` WHERE %s " ..
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
    local rows = query(string.format("SELECT " .. SUMMARY_COLUMNS .. " FROM `reports` WHERE " ..
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
    elseif (action == "shot") then
        receiveShot(cid, data)
    elseif (not Reports.canView(cid)) then
        return
    elseif (action == "getShot") then
        sendShot(cid, data.id)
    elseif (action == "marks") then
        sendMarks(cid)
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
    elseif (action == "assign") then
        local row, reason = Reports.assign(data.id, data.to == "me" and getCreatureName(cid) or "", getCreatureName(cid),
            "game")
        if (row) then
            send(cid, { type = "report", report = details(row) })
        else
            fail(cid, reason)
        end
    elseif (action == "duplicate") then
        local row, reason = Reports.markDuplicate(data.id, tonumber(data.of) or 0, getCreatureName(cid), "game")
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

DiscordBridge.registerHandler("report.screenshot", function(params)
    local id = tonumber(params.id) or 0
    local offset = math.max(0, math.floor(tonumber(params.offset) or 0))
    local length = math.min(Reports.SHOT_SLICE, math.max(1, math.floor(tonumber(params.length) or Reports.SHOT_SLICE)))
    local rows = query(string.format("SELECT `done`, CHAR_LENGTH(`data`) AS `total`, SUBSTRING(`data`, %d, %d) AS " ..
        "`slice` FROM `report_screenshots` WHERE `report_id` = %d;", offset + 1, length, id),
        { done = "number", total = "number", slice = "string" })
    local row = rows[1]
    if (not row) then
        return { found = false }
    end
    return { found = true, done = row.done == 1, total = row.total, offset = offset, data = row.slice }
end)
