-- The Pokegear Social window's server half: the friends list (the VIP list) with levels and where
-- friends are, the guild roster by rank and the party. The client asks while the window is open.
--
-- Where someone is (pos) is only sent for a friend who has you on their own list, a guild mate
-- or a party member. Staff never show as online.
--
-- The client talks JSON on EXTENDED_IDS.SOCIAL:
--   client -> server  {action = "refresh", friends = {VIP ids}}, {action = "leaveGuild"}
--   server -> client  {type = "social",
--                       friends = {{id (the VIP id), name, online, level, outfit, pos, dueling, lastSeen}, ...},
--                       guild = {name, rank, level, members = {{name, rank, level, rankLevel, online, outfit, pos}, ...}}
--                         (nil without one; rankLevel 3 is the leader),
--                       party = {leader, members = {{name, level, outfit, pos}, ...}} (nil without one)}
--                     (in fragments, doSendPlayerLongExtendedOpcode)
--                     {type = "error", text} or {type = "left"}

Social = {}

Social.MAX_FRIENDS = 200
Social.MAX_GUILD = 300
Social.REFRESH_SECONDS = 2

local STAFF_ACCESS = 1
local lastRefresh = {}

local function worldId()
    return tonumber(getConfigValue("worldId")) or 0
end

local function rows(query, fields)
    local list = {}
    local r = db.getResult(query)
    if (r:getID() ~= -1) then
        repeat
            local row = {}
            for field, kind in pairs(fields) do
                row[field] = kind == "string" and r:getDataString(field) or r:getDataInt(field)
            end
            list[#list + 1] = row
        until not r:next()
        r:free()
    end
    return list
end

local function isStaffGroup(groupId)
    local group = getGroupInfo(groupId)
    return group ~= nil and (tonumber(group.access) or 0) >= STAFF_ACCESS
end

local PLAYER_FIELDS = { id = "number", name = "string", level = "number", group_id = "number",
                        lastlogout = "number", looktype = "number", lookhead = "number", lookbody = "number",
                        looklegs = "number", lookfeet = "number", lookaddons = "number" }
local PLAYER_COLUMNS = "`p`.`id`, `p`.`name`, `p`.`level`, `p`.`group_id`, `p`.`lastlogout`, `p`.`looktype`, " ..
    "`p`.`lookhead`, `p`.`lookbody`, `p`.`looklegs`, `p`.`lookfeet`, `p`.`lookaddons`"

local function outfitOf(row)
    return { type = row.looktype, head = row.lookhead, body = row.lookbody, legs = row.looklegs,
             feet = row.lookfeet, addons = row.lookaddons }
end

local function liveOutfit(pid)
    local o = getCreatureOutfit(pid) or {}
    return { type = o.lookType, head = o.lookHead, body = o.lookBody, legs = o.lookLegs, feet = o.lookFeet,
             addons = o.lookAddons }
end

local function withFields(extra)
    local fields = {}
    for k, v in pairs(PLAYER_FIELDS) do
        fields[k] = v
    end
    for k, v in pairs(extra) do
        fields[k] = v
    end
    return fields
end

local function positionOf(pid)
    local pos = getCreaturePosition(pid)
    return { x = pos.x, y = pos.y, z = pos.z }
end

-- an online trainer cid may see as online: themself, or anyone but staff
local function onlineTrainer(cid, row)
    local pid = getPlayerByName(row.name)
    if (pid and (pid == cid or not isStaffGroup(row.group_id))) then
        return pid
    end
end

-- ids: the VIP ids (player ids) the client has; the server's copy of the list is only saved at logout
local function friends(cid, ids)
    local guids = {}
    for _, id in ipairs(type(ids) == "table" and ids or {}) do
        id = tonumber(id)
        if (id and id > 0 and #guids < Social.MAX_FRIENDS) then
            guids[#guids + 1] = string.format("%d", id)
        end
    end
    if (#guids == 0) then
        return {}
    end
    local list = rows(string.format("SELECT %s, (SELECT COUNT(*) FROM `account_viplist` `b` WHERE " ..
        "`b`.`account_id` = `p`.`account_id` AND `b`.`player_id` = %d) AS `mutual` FROM `players` `p` " ..
        "WHERE `p`.`id` IN (%s) AND `p`.`world_id` = %d AND `p`.`deleted` = 0;", PLAYER_COLUMNS, getPlayerGUID(cid),
        table.concat(guids, ","), worldId()), withFields({ mutual = "number" }))
    local out = {}
    for _, row in ipairs(list) do
        local pid = onlineTrainer(cid, row)
        local friend = { id = row.id, name = row.name, online = pid ~= nil, level = row.level, outfit = outfitOf(row),
                         lastSeen = row.lastlogout }
        if (pid) then
            friend.level = getPlayerLevel(pid)
            friend.outfit = liveOutfit(pid)
            friend.dueling = getPlayerDueling(pid) and true or nil
            if (row.mutual > 0) then
                friend.pos = positionOf(pid)
            end
        end
        out[#out + 1] = friend
    end
    return out
end

local function guild(cid)
    local guildId = getPlayerGuildId(cid)
    if (not guildId or guildId == 0) then
        return nil
    end
    local list = rows(string.format("SELECT %s, `r`.`name` AS `rank`, `r`.`level` AS `rank_level` FROM `players` `p` " ..
        "JOIN `guild_ranks` `r` ON `r`.`id` = `p`.`rank_id` WHERE `r`.`guild_id` = %d AND `p`.`deleted` = 0 " ..
        "ORDER BY `r`.`level` DESC, `p`.`level` DESC LIMIT %d;", PLAYER_COLUMNS, guildId, Social.MAX_GUILD),
        withFields({ rank = "string", rank_level = "number" }))
    local members = {}
    for _, row in ipairs(list) do
        local pid = onlineTrainer(cid, row)
        local member = { name = row.name, rank = row.rank, rankLevel = row.rank_level, level = row.level,
                         online = pid ~= nil, outfit = outfitOf(row) }
        if (pid) then
            member.level = getPlayerLevel(pid)
            member.outfit = liveOutfit(pid)
            member.pos = positionOf(pid)
        end
        members[#members + 1] = member
    end
    return { name = getPlayerGuildName(cid), rank = getPlayerGuildRank(cid), level = getPlayerGuildLevel(cid),
             members = members }
end

local function party(cid)
    local leader = getPlayerParty(cid)
    if (not leader) then
        return nil
    end
    local members = {}
    for _, pid in ipairs(getPartyMembers(leader) or {}) do
        if (isPlayer(pid)) then
            members[#members + 1] = { name = getCreatureName(pid), level = getPlayerLevel(pid),
                                      outfit = liveOutfit(pid), pos = positionOf(pid) }
        end
    end
    return { leader = getCreatureName(leader), members = members }
end

Social.send = function(cid, ids)
    local now = os.time()
    if (lastRefresh[cid] and now - lastRefresh[cid] < Social.REFRESH_SECONDS) then
        return
    end
    lastRefresh[cid] = now
    doSendPlayerLongExtendedOpcode(cid, EXTENDED_IDS.SOCIAL, JSON.encode({ type = "social", friends = friends(cid, ids),
                                                                         guild = guild(cid), party = party(cid) }))
end

local function sendError(cid, text)
    doSendPlayerExtendedOpcode(cid, EXTENDED_IDS.SOCIAL, JSON.encode({ type = "error", text = __L(cid, text) }))
end

-- the same rule as "!leave" in the guild channel (Chat::parseGuildCommand)
Social.leaveGuild = function(cid)
    local guildId = getPlayerGuildId(cid)
    if (not guildId or guildId == 0) then
        return sendError(cid, "You are not in a guild.")
    elseif (getPlayerGuildLevel(cid) >= GUILDLEVEL_LEADER) then
        return sendError(cid, "You cannot leave your guild because you are the leader of it, you have to pass the leadership to another member of your guild or disband the guild.")
    end
    doPlayerSetGuildId(cid, 0)
    lastRefresh[cid] = nil
    doSendPlayerExtendedOpcode(cid, EXTENDED_IDS.SOCIAL, JSON.encode({ type = "left" }))
end

Social.onClientMessage = function(cid, buffer)
    local ok, data = pcall(JSON.decode, buffer)
    if (not ok or type(data) ~= "table") then
        return
    end
    if (data.action == "refresh") then
        Social.send(cid, data.friends)
    elseif (data.action == "leaveGuild") then
        Social.leaveGuild(cid)
    end
end
