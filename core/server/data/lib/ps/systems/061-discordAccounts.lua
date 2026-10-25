-- Discord account linking: bridge request handlers for the PokeVerse-Discord bot and
-- helpers for the in-game !discord command (data/talkactions/scripts/discord.lua).
--
-- A link joins one game account (not a character) to one Discord user. The game is
-- authoritative: links live in `discord_account_links` (schemas/pokeverse-extensions.sql)
-- and this is the only file that writes that table. One-time link codes are created and
-- consumed in C++ (src/discordbridge.cpp) and never stored in the database.
--
-- Every request names the Discord user it acts for (`discordUserId`); the bot only passes
-- the id of the user who ran the command, or the target of an admin-only command. Results
-- never include account ids, account names or IP addresses.

DiscordAccounts = {}

local MAX_LIST_LIMIT = 200
local UNLIMITED_PREMIUM_DAYS = 65535

local fail = DiscordBridge.fail
local queryRows = DiscordBridge.queryRows

local function worldId()
    return tonumber(getConfigValue("worldId")) or 0
end

function DiscordAccounts.isEnabled()
    local info = getDiscordBridgeInfo and getDiscordBridgeInfo()
    return info ~= nil and info.accountLinking == true
end

local function validDiscordUserId(id)
    return type(id) == "string" and id:match("^%d+$") ~= nil and #id >= 17 and #id <= 20
end

local function requireDiscordUserId(params, field)
    local id = params[field or "discordUserId"]
    if (not validDiscordUserId(id)) then
        fail("invalid_params", "invalid Discord user id")
    end
    return id
end

local function requireEnabled()
    if (not DiscordAccounts.isEnabled()) then
        fail("disabled", "account linking is disabled on this server")
    end
end

-- Links ---------------------------------------------------------------------------

local LINK_FIELDS = {account_id = "number", discord_user_id = "string", main_player_id = "number",
    linked_at = "long", updated_at = "long"}

local function linkQuery(where)
    return string.concat("SELECT `account_id`, `discord_user_id`, IFNULL(`main_player_id`, 0) AS `main_player_id`, ",
        "`linked_at`, `updated_at` FROM `discord_account_links` WHERE ", where, " LIMIT 1;")
end

function DiscordAccounts.getLinkByDiscordUser(discordUserId)
    return queryRows(linkQuery(string.concat("`discord_user_id` = ", db.escapeString(discordUserId))), LINK_FIELDS)[1]
end

function DiscordAccounts.getLinkByAccount(accountId)
    return queryRows(linkQuery(string.concat("`account_id` = ", tonumber(accountId) or 0)), LINK_FIELDS)[1]
end

-- Characters of an account on this world, oldest (lowest id) first. The schema has no
-- creation date; ids are AUTO_INCREMENT, so the lowest id is the first one created.
function DiscordAccounts.getCharacters(accountId)
    return queryRows(string.concat("SELECT `id`, `name`, `level`, `vocation`, `group_id` FROM `players` WHERE ",
        "`account_id` = ", tonumber(accountId) or 0, " AND `deleted` = 0 AND `world_id` = ", worldId(),
        " ORDER BY `id` ASC;"),
        {id = "number", name = "string", level = "number", vocation = "number", group_id = "number"})
end

-- Distinct group ids of the account's characters (groups.xml), lowest first. Online
-- characters use the live group; others use players.group_id. Not accounts.group_id:
-- pokeverse_set_group never lowers that, so a demoted player would keep the role.
local function characterGroups(characters)
    local seen, ids = {}, JSON.array()
    for _, character in ipairs(characters) do
        local cid = getPlayerByGUID(character.id)
        local groupId
        if (cid and isPlayer(cid)) then
            groupId = getPlayerGroupId(cid)
        else
            groupId = character.group_id
        end
        groupId = tonumber(groupId)
        if (groupId and not seen[groupId]) then
            seen[groupId] = true
            ids[#ids + 1] = groupId
        end
    end
    table.sort(ids)
    return ids
end

local function setMainPlayer(accountId, playerId)
    return db.executeQuery(string.concat("UPDATE `discord_account_links` SET `main_player_id` = ",
        playerId and tostring(playerId) or "NULL", ", `updated_at` = ", os.time(), " WHERE `account_id` = ",
        tonumber(accountId) or 0, ";"))
end

-- Returns the main character row (or nil when the account has no characters) and whether
-- it had to be replaced. A main that was deleted or moved falls back to the first character.
local function resolveMain(link, characters)
    for _, character in ipairs(characters) do
        if (character.id == link.main_player_id) then
            return character, false
        end
    end

    local fallback = characters[1]
    local fallbackId = fallback and fallback.id or 0
    if (fallbackId ~= link.main_player_id) then
        setMainPlayer(link.account_id, fallback and fallback.id or nil)
        link.main_player_id = fallbackId
        return fallback, true
    end
    return fallback, false
end

local function vocationName(character)
    return Vocations.nameOf(character.id)
end

local function liveLevel(character)
    local cid = getPlayerByGUID(character.id)
    if (cid and isPlayer(cid)) then
        return getPlayerLevel(cid), true
    end
    return character.level, false
end

local function premiumDays(accountId)
    return DiscordBridge.queryNumber(string.concat("SELECT `premdays` FROM `accounts` WHERE `id` = ",
        tonumber(accountId) or 0, " LIMIT 1;"), "premdays") or 0
end

local function premiumInfo(accountId)
    local days = premiumDays(accountId)
    return {premium = days > 0, premiumUnlimited = days >= UNLIMITED_PREMIUM_DAYS,
        premiumDays = days >= UNLIMITED_PREMIUM_DAYS and nil or days}
end

-- Summary of a link for the bot. mainChanged is true when the stored main was replaced.
local function linkSummary(link)
    local characters = DiscordAccounts.getCharacters(link.account_id)
    local main, mainChanged = resolveMain(link, characters)
    local summary = premiumInfo(link.account_id)
    summary.linked = true
    summary.discordUserId = link.discord_user_id
    summary.linkedAt = link.linked_at
    summary.characterCount = #characters
    summary.groupIds = characterGroups(characters)
    summary.mainChanged = mainChanged
    if (main) then
        local level = liveLevel(main)
        summary.main = {name = main.name, level = level, vocation = vocationName(main)}
    end
    return summary
end

local function notifyAccount(accountId, message)
    for _, cid in ipairs(getPlayersOnline()) do
        if (getPlayerAccountId(cid) == accountId) then
            doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, message)
        end
    end
end

-- Removes a link and any pending codes. Returns the removed link or nil.
function DiscordAccounts.unlinkAccount(accountId)
    local link = DiscordAccounts.getLinkByAccount(accountId)
    doRevokeDiscordLinkCodes(accountId)
    if (not link) then
        return nil
    end
    if (not db.executeQuery(string.concat("DELETE FROM `discord_account_links` WHERE `account_id` = ",
            tonumber(accountId) or 0, ";"))) then
        return nil
    end
    return link
end

-- Request handlers ---------------------------------------------------------------

local function handleRedeem(params)
    requireEnabled()
    local discordUserId = requireDiscordUserId(params)
    if (type(params.code) ~= "string" or #params.code < 8 or #params.code > 16) then
        fail("invalid_code", "invalid code")
    end

    -- Checked before the code is consumed so a linked user can't burn someone's code.
    if (DiscordAccounts.getLinkByDiscordUser(discordUserId)) then
        fail("already_linked", "this Discord user is already linked to a game account")
    end

    local accountId, err = doConsumeDiscordLinkCode(params.code, discordUserId)
    if (not accountId) then
        fail(err or "invalid_code", "the code was not accepted")
    end

    if (DiscordAccounts.getLinkByAccount(accountId)) then
        fail("account_linked", "the game account is already linked; unlink it in game first")
    end

    local characters = DiscordAccounts.getCharacters(accountId)
    local now = os.time()
    if (not db.executeQuery(string.concat("INSERT INTO `discord_account_links` (`account_id`, `discord_user_id`, ",
            "`main_player_id`, `linked_at`, `updated_at`) VALUES (", accountId, ", ", db.escapeString(discordUserId),
            ", ", characters[1] and tostring(characters[1].id) or "NULL", ", ", now, ", ", now, ");"))) then
        fail("internal", "the link could not be saved")
    end

    notifyAccount(accountId, "Your account is now linked to Discord.")
    local link = DiscordAccounts.getLinkByAccount(accountId)
    if (not link) then
        fail("internal", "the link could not be saved")
    end
    return linkSummary(link)
end

local function handleAccount(params)
    requireEnabled()
    local link = DiscordAccounts.getLinkByDiscordUser(requireDiscordUserId(params))
    if (not link) then
        return {linked = false}
    end
    return linkSummary(link)
end

local function handleCharacters(params)
    requireEnabled()
    local link = DiscordAccounts.getLinkByDiscordUser(requireDiscordUserId(params))
    if (not link) then
        return {linked = false}
    end

    local characters = DiscordAccounts.getCharacters(link.account_id)
    local main = resolveMain(link, characters)
    local out = JSON.array()
    for _, character in ipairs(characters) do
        local level, online = liveLevel(character)
        out[#out + 1] = {name = character.name, level = level, vocation = vocationName(character),
            main = main ~= nil and character.id == main.id, online = online}
    end
    return {linked = true, characters = out}
end

local function handleSetMain(params)
    requireEnabled()
    local link = DiscordAccounts.getLinkByDiscordUser(requireDiscordUserId(params))
    if (not link) then
        fail("not_linked", "this Discord user is not linked")
    end

    local name = DiscordBridge.sanitizeText(params.character, 30)
    if (name == "") then
        fail("invalid_params", "character is required")
    end

    for _, character in ipairs(DiscordAccounts.getCharacters(link.account_id)) do
        if (string.lower(character.name) == string.lower(name)) then
            if (character.id ~= link.main_player_id and not setMainPlayer(link.account_id, character.id)) then
                fail("internal", "the main character could not be saved")
            end
            link.main_player_id = character.id
            return linkSummary(link)
        end
    end
    fail("not_owned", "that character does not belong to the linked account")
end

local function handleUnlink(params)
    requireEnabled()
    local link = DiscordAccounts.getLinkByDiscordUser(requireDiscordUserId(params))
    if (not link) then
        return {unlinked = false}
    end
    if (not DiscordAccounts.unlinkAccount(link.account_id)) then
        fail("internal", "the link could not be removed")
    end
    notifyAccount(link.account_id, "Your account is no longer linked to Discord.")
    return {unlinked = true}
end

-- Paged list of all links, for the bot's periodic role and nickname resync.
local function handleList(params)
    requireEnabled()
    local offset = math.max(0, math.floor(tonumber(params.offset) or 0))
    local limit = math.min(MAX_LIST_LIMIT, math.max(1, math.floor(tonumber(params.limit) or MAX_LIST_LIMIT)))
    local links = queryRows(string.concat("SELECT `account_id`, `discord_user_id`, IFNULL(`main_player_id`, 0) AS ",
        "`main_player_id`, `linked_at`, `updated_at` FROM `discord_account_links` ORDER BY `account_id` ASC LIMIT ",
        limit + 1, " OFFSET ", offset, ";"), LINK_FIELDS)

    local out = JSON.array()
    for i = 1, math.min(#links, limit) do
        out[#out + 1] = linkSummary(links[i])
    end
    return {links = out, nextOffset = #links > limit and offset + limit or nil}
end

-- Online sessions, so the bot can close sessions it missed. No IP addresses.
local function handleSessions()
    local sessions = JSON.array()
    for _, cid in ipairs(getPlayersOnline()) do
        local sessionId = getDiscordSessionId(getPlayerGUID(cid))
        if (sessionId ~= "") then
            sessions[#sessions + 1] = {sessionId = sessionId, character = getCreatureName(cid), level = getPlayerLevel(cid)}
        end
    end
    return {sessions = sessions, playersOnline = #getPlayersOnline()}
end

DiscordBridge.registerHandler("link.redeem", handleRedeem)
DiscordBridge.registerHandler("link.account", handleAccount)
DiscordBridge.registerHandler("link.characters", handleCharacters)
DiscordBridge.registerHandler("link.setMain", handleSetMain)
DiscordBridge.registerHandler("link.unlink", handleUnlink)
DiscordBridge.registerHandler("link.list", handleList)
DiscordBridge.registerHandler("admin.sessions", handleSessions)
