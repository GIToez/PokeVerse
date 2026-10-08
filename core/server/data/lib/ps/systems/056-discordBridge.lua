-- Discord bridge: game-side hooks and read-only request handlers for the
-- PokeVerse-Discord companion bot. Transport, authentication and queuing are in
-- src/discordbridge.cpp; the protocol is documented in docs/discord-bridge.md.
--
-- Rules for this file:
--  * Never let a bridge failure break gameplay: every hook is wrapped in pcall and
--    does nothing when the bridge is disabled.
--  * Request handlers are read-only. They never modify players, items or the database.

DiscordBridge = {}

local CONFIG = {
    -- Public channel relayed to Discord (data/XML/channels.xml, needs talkEvent="1").
    chatChannelId = 7, -- Game-Chat[EN-US]
    chatSpeakClass = TALKTYPE_CHANNEL_Y,
    chatAuthorPrefix = "[Discord] ",
    chatAuthorMaxLength = 24,
    chatTextMaxLength = 255, -- Game client limit for a single message.

    -- The game data has no legendary flag. This list is the audited set of legendary
    -- species defined in data/lib/ps/config/pokemon (plus their boss/quest variants);
    -- "Shiny <name>" variants are matched automatically.
    legendary = {
        "Articuno", "Zapdos", "Moltres", "Mewtwo", "Mew",
        "Raikou", "Entei", "Suicune", "Lugia", "Ho-Oh", "Celebi",
        "Regirock", "Regice", "Registeel", "Latias", "Latios",
        "Kyogre", "Groudon", "Rayquaza", "Jirachi", "Deoxys",
        "Boss Articuno", "Frozen Boss Articuno", "Boss Zapdos", "Boss Moltres", "Final Mewtwo",
    },

    -- Script-created legendary/shiny spawns (quest bosses with phases, arenas) are
    -- reported at most once per species within this many seconds.
    scriptSpawnCooldown = 300,

    -- Trainers in a group with access >= this value (staff) are hidden from lookups.
    hiddenTrainerMinAccess = 1,
    trainerAchievementNames = 5,

    -- Highest town id scanned when looking for the nearest town of a spawn.
    maxTownId = 100,

    maxRequestsPerDrain = 50,
    searchLimit = 25,
}

local LEGENDARY = {}
for _, name in ipairs(CONFIG.legendary) do
    LEGENDARY[string.lower(name)] = true
end

local SHINY_PREFIX = "shiny "

local function stripShiny(name)
    if (string.lower(string.sub(name, 1, #SHINY_PREFIX)) == SHINY_PREFIX) then
        return string.sub(name, #SHINY_PREFIX + 1)
    end
    return name
end

function DiscordBridge.isLegendary(name)
    return name ~= nil and LEGENDARY[string.lower(stripShiny(name))] == true
end

function DiscordBridge.isShiny(name)
    return name ~= nil and isShinyName(name) ~= nil
end

function DiscordBridge.getConfig()
    return CONFIG
end

function DiscordBridge.isEnabled()
    local info = getDiscordBridgeInfo and getDiscordBridgeInfo()
    return info ~= nil and info.enabled == true
end

-- Queues an event for the bot. Returns false when the bridge is disabled.
function DiscordBridge.emit(event)
    if (not DiscordBridge.isEnabled()) then
        return false
    end

    local ok, payload = pcall(JSON.encode, event)
    if (not ok) then
        log(LOG_TYPES.ERROR, "DiscordBridge.emit - can't encode event", event.kind, payload)
        return false
    end
    return doDiscordBridgeEmit(payload)
end

local function safeCall(name, fn, ...)
    local ok, err = pcall(fn, ...)
    if (not ok) then
        log(LOG_TYPES.ERROR, "DiscordBridge." .. name .. " failed", err)
    end
end

-- Towns -----------------------------------------------------------------------

local towns = nil

local function getTowns()
    if (not towns) then
        towns = {}
        for id = 1, CONFIG.maxTownId do
            local name = getTownName(id)
            if (name) then
                local pos = getTownTemplePosition(id)
                if (pos) then
                    towns[#towns + 1] = {id = id, name = name, pos = pos}
                end
            end
        end
    end
    return towns
end

-- Nearest town temple on the same floor, by tile distance; nil if none.
local function getNearestTown(pos)
    local best, bestDistance = nil, nil
    for _, town in ipairs(getTowns()) do
        if (town.pos.z == pos.z or (pos.z <= 7 and town.pos.z <= 7)) then
            local distance = math.max(math.abs(town.pos.x - pos.x), math.abs(town.pos.y - pos.y))
            if (not bestDistance or distance < bestDistance) then
                best, bestDistance = town, distance
            end
        end
    end
    return best, bestDistance
end

-- Chat: game -> Discord ---------------------------------------------------------

local function onChat(cid, channelId, message)
    if (channelId ~= CONFIG.chatChannelId or not isPlayer(cid)) then
        return
    end

    DiscordBridge.emit({
        kind = "chat",
        channelId = channelId,
        author = getCreatureName(cid),
        level = getPlayerLevel(cid),
        text = message,
    })
end

function DiscordBridge.onTalkChannel(cid, channelId, message)
    safeCall("onTalkChannel", onChat, cid, channelId, message)
end

-- Catches ---------------------------------------------------------------------

-- Called only after a catch is confirmed: the ball was created and the caught
-- Pokemon was registered for the player.
-- info = {name, level, sex, ball, ballUid, extraPoints, safari}
local function onCatch(cid, info)
    if (not isPlayer(cid) or not info.ballUid) then
        return
    end

    DiscordBridge.emit({
        kind = "catch",
        trainer = getCreatureName(cid),
        species = info.name,
        baseSpecies = stripShiny(info.name),
        dexNumber = getPokemonNumberByName(stripShiny(info.name)),
        level = info.level,
        sex = info.sex,
        shiny = DiscordBridge.isShiny(info.name),
        legendary = DiscordBridge.isLegendary(info.name),
        extraPoints = tonumber(info.extraPoints) or 0,
        ball = info.ball,
        safari = info.safari == true,
    })
end

function DiscordBridge.onCatch(cid, info)
    if (DiscordBridge.isEnabled()) then
        safeCall("onCatch", onCatch, cid, info)
    end
end

-- Spawns ----------------------------------------------------------------------

local lastScriptSpawn = {}

local function onSpawn(cid, source)
    if (not isMonster(cid)) then
        return
    end

    local master = getCreatureMaster(cid)
    if (master and master ~= cid and master ~= 0) then
        return -- Not wild (summon/player Pokemon).
    end

    local name = getCreatureName(cid)
    local shiny = DiscordBridge.isShiny(name)
    local legendary = DiscordBridge.isLegendary(name)
    if (not shiny and not legendary) then
        return
    end

    local base = stripShiny(name)
    if (source ~= "spawn") then
        local now = os.time()
        local key = string.lower(name)
        if (lastScriptSpawn[key] and now - lastScriptSpawn[key] < CONFIG.scriptSpawnCooldown) then
            return
        end
        lastScriptSpawn[key] = now
    end

    local pos = getCreaturePosition(cid)
    local town = getNearestTown(pos)
    local state = getGameState()

    DiscordBridge.emit({
        kind = "spawn",
        species = name,
        baseSpecies = base,
        dexNumber = getPokemonNumberByName(base),
        level = getMonsterLevel and getMonsterLevel(cid) or nil,
        shiny = shiny,
        legendary = legendary,
        source = source,
        startup = (state == GAMESTATE_STARTUP or state == GAMESTATE_INIT),
        creatureId = cid,
        position = {x = pos.x, y = pos.y, z = pos.z},
        nearestTown = town and town.name or nil,
    })
end

-- source: "spawn" (map spawn system/raids), "script", "fishing", "headbutt".
function DiscordBridge.onSpawn(cid, source)
    if (DiscordBridge.isEnabled()) then
        safeCall("onSpawn", onSpawn, cid, source or "script")
    end
end

-- Announcements ---------------------------------------------------------------

function DiscordBridge.onBroadcast(source, author, text)
    safeCall("onBroadcast", DiscordBridge.emit, {kind = "broadcast", source = source, author = author, text = text})
end

function DiscordBridge.onRestartWarning(reason, minutes, shutdown)
    safeCall("onRestartWarning", DiscordBridge.emit,
        {kind = "restart_warning", reason = reason, minutes = minutes, shutdown = shutdown == true})
end

-- Requests (bot -> game) --------------------------------------------------------

local RequestError = {}

local function fail(code, message)
    error(setmetatable({code = code, message = message}, RequestError), 0)
end

local function sanitizeText(text, maxLength)
    if (type(text) ~= "string") then
        return ""
    end
    text = text:gsub("[%c]", " "):gsub("%s+", " ")
    text = text:gsub("^%s+", ""):gsub("%s+$", "")
    if (#text > maxLength) then
        text = text:sub(1, maxLength)
    end
    return text
end

local function handleChatSend(params)
    local author = sanitizeText(params.author, CONFIG.chatAuthorMaxLength)
    local text = sanitizeText(params.text, CONFIG.chatTextMaxLength)
    if (author == "" or text == "") then
        fail("invalid_params", "author and text are required")
    end

    local delivered = 0
    local users = getChannelUsers(CONFIG.chatChannelId)
    if (type(users) == "table") then
        for _, uid in ipairs(users) do
            if (isPlayer(uid) and doPlayerSendChannelMessage(uid, CONFIG.chatAuthorPrefix .. author, text,
                    CONFIG.chatSpeakClass, CONFIG.chatChannelId)) then
                delivered = delivered + 1
            end
        end
    end
    return {delivered = delivered, text = text}
end

local function validPlayerName(name)
    return type(name) == "string" and #name >= 2 and #name <= 30 and name:match("^[%a][%a '%-]*$") ~= nil
end

local function queryNumber(query, field)
    local resultId = db.storeQuery(query)
    if (not resultId) then
        return nil
    end
    local value = result.getDataInt(resultId, field)
    result.free(resultId)
    return value
end

local function queryRows(query, fields)
    local rows = {}
    local resultId = db.storeQuery(query)
    if (not resultId) then
        return rows
    end
    repeat
        local row = {}
        for field, kind in pairs(fields) do
            if (kind == "string") then
                row[field] = result.getDataString(resultId, field)
            else
                row[field] = result.getDataInt(resultId, field)
            end
        end
        rows[#rows + 1] = row
    until not result.next(resultId)
    result.free(resultId)
    return rows
end

-- Duel results are stored as skill levels: every skill starts at level 10 and each
-- win/loss advances the matching skill by exactly one level (src/partyduel.cpp).
local SKILL_START_LEVEL = 10

local function duelCount(skillLevel)
    return math.max(0, (tonumber(skillLevel) or SKILL_START_LEVEL) - SKILL_START_LEVEL)
end

local function isHiddenGroup(groupId)
    local group = getGroupInfo(groupId)
    return group and tonumber(group.access) and tonumber(group.access) >= CONFIG.hiddenTrainerMinAccess
end

local function handleTrainerLookup(params)
    local name = sanitizeText(params.name, 30)
    if (not validPlayerName(name)) then
        fail("invalid_params", "invalid trainer name")
    end

    local rows = queryRows(string.concat(
        "SELECT `p`.`id`, `p`.`name`, `p`.`level`, `p`.`vocation`, `p`.`group_id`, `p`.`lastlogin`, ",
        "IFNULL(`g`.`name`, '') AS `guild` FROM `players` `p` ",
        "LEFT JOIN `guild_ranks` `r` ON `r`.`id` = `p`.`rank_id` ",
        "LEFT JOIN `guilds` `g` ON `g`.`id` = `r`.`guild_id` ",
        "WHERE `p`.`name` = ", db.escapeString(name), " AND `p`.`deleted` = 0 AND `p`.`world_id` = ",
        tonumber(getConfigValue("worldId")) or 0, " LIMIT 1;"),
        {id = "number", name = "string", level = "number", vocation = "number", group_id = "number",
            lastlogin = "number", guild = "string"})

    local row = rows[1]
    if (not row or isHiddenGroup(row.group_id)) then
        return {found = false}
    end

    local guid = row.id
    local trainer = {
        found = true,
        name = row.name,
        level = row.level,
        vocation = getVocationInfo(row.vocation) and getVocationInfo(row.vocation).name or nil,
        guild = row.guild ~= "" and row.guild or nil,
        online = false,
    }

    local cid = getPlayerByName(row.name)
    local function statistic(key)
        return queryNumber(string.concat("SELECT `value` FROM `player_statistics` WHERE `player_id` = ", guid,
            " AND `key` = ", key, " LIMIT 1;"), "value") or 0
    end

    if (cid and isPlayer(cid)) then
        trainer.online = true
        trainer.level = getPlayerLevel(cid)
        trainer.vocation = getVocationInfo(getPlayerVocation(cid)).name
        local guild = getPlayerGuildName(cid)
        trainer.guild = (guild and guild ~= "") and guild or nil
        trainer.caught = getPlayerCaughts(cid)
        trainer.uniqueCaught = math.max(0, tonumber(getCreatureStorage(cid, playersStorages.individualCaughts)) or 0)
        trainer.duelWins = duelCount(getPlayerSkillLevel(cid, PLAYER_SKILL_DUEL_WIN))
        trainer.duelLosses = duelCount(getPlayerSkillLevel(cid, PLAYER_SKILL_DUEL_LOSS))
    else
        local function storage(key)
            local resultId = db.storeQuery(string.concat("SELECT `value` FROM `player_storage` WHERE `player_id` = ",
                guid, " AND `key` = ", key, " LIMIT 1;"))
            if (not resultId) then
                return 0
            end
            local value = tonumber(result.getDataString(resultId, "value")) or 0
            result.free(resultId)
            return math.max(0, value)
        end
        local function skill(skillId)
            return queryNumber(string.concat("SELECT `value` FROM `player_skills` WHERE `player_id` = ", guid,
                " AND `skillid` = ", skillId, " LIMIT 1;"), "value") or 0
        end
        trainer.caught = storage(playersStorages.caughts)
        trainer.uniqueCaught = storage(playersStorages.individualCaughts)
        trainer.duelWins = duelCount(skill(PLAYER_SKILL_DUEL_WIN))
        trainer.duelLosses = duelCount(skill(PLAYER_SKILL_DUEL_LOSS))
    end

    trainer.shinyCaught = statistic(PLAYER_STATISTIC_IDS.CATCH_SHINY_POKEMON)
    trainer.playersDefeated = statistic(PLAYER_STATISTIC_IDS.DEFEAT_PLAYER)
    trainer.tournamentsWon = statistic(PLAYER_STATISTIC_IDS.WIN_TOURNAMENT)

    local achievements = queryRows(string.concat("SELECT `key` FROM `player_achievements` WHERE `player_id` = ", guid,
        " ORDER BY `key` DESC;"), {key = "number"})
    local totalAchievements = 0
    for _ in pairs(ACHIEVEMENT_IDS) do
        totalAchievements = totalAchievements + 1
    end
    local names = JSON.array()
    for _, a in ipairs(achievements) do
        if (#names >= CONFIG.trainerAchievementNames) then
            break
        end
        local achievementName = getAchievementBaseName(a.key)
        if (achievementName and not getAchievementSecret(a.key)) then
            names[#names + 1] = achievementName
        end
    end
    trainer.achievements = {earned = #achievements, total = totalAchievements, recent = names}
    return trainer
end

local function elementNames(types)
    local out = JSON.array()
    for _, element in ipairs(types or {}) do
        if (ELEMENT_NAMES[element]) then
            out[#out + 1] = ELEMENT_NAMES[element]
        end
    end
    return out
end

local POKEMON_NAME_INDEX = nil

local function getPokemonNameIndex()
    if (not POKEMON_NAME_INDEX) then
        POKEMON_NAME_INDEX = {}
        for _, name in ipairs(pokemonsNames) do
            POKEMON_NAME_INDEX[string.lower(name)] = name
        end
    end
    return POKEMON_NAME_INDEX
end

local function evolutionChain(name)
    local root, guard = name, 0
    while (getPokemonPreEvolution(root) and guard < 10) do
        root = getPokemonPreEvolution(root)
        guard = guard + 1
    end

    local chain = JSON.array()
    local function walk(current, depth)
        if (depth > 10) then
            return
        end
        local definition = getPokemonDefinition(current)
        for _, evolution in ipairs(definition and definition.evolutions or {}) do
            chain[#chain + 1] = {from = current, to = evolution.name, level = evolution.requiredLevel,
                items = (evolution.requiredItems and #evolution.requiredItems > 0) and true or nil}
            walk(evolution.name, depth + 1)
        end
    end
    walk(root, 0)
    return chain
end

local function handlePokemonLookup(params)
    if (type(params.name) ~= "string" or #params.name > 40) then
        fail("invalid_params", "invalid pokemon name")
    end

    local name = getPokemonNameIndex()[string.lower(sanitizeText(params.name, 40))]
    local definition = name and getPokemonDefinition(name)
    if (not definition) then
        return {found = false}
    end

    local base = stripShiny(name)
    local info = getMonsterInfo(name, false)

    local moves = JSON.array()
    local skills = definition.skills or {}
    for i = 1, #skills, 2 do
        moves[#moves + 1] = {name = skills[i], level = skills[i + 1]}
    end

    local special = JSON.array()
    for _, ability in ipairs(definition.specialAbilities or {}) do
        local abilityName = getPokemonSpecialAbilityName(ability)
        if (abilityName and abilityName ~= "") then
            special[#special + 1] = abilityName
        end
    end

    local abilities = JSON.array()
    for _, ability in ipairs(definition.abilities or {}) do
        abilities[#abilities + 1] = ability
    end

    return {
        found = true,
        name = name,
        baseSpecies = base,
        dexNumber = getPokemonNumberByName(base),
        generation = getPokemonGenerationByName(name),
        types = elementNames(definition.pTypes),
        stats = {attack = definition.atk, defense = definition.def, specialAttack = definition.spAtk,
            specialDefense = definition.spDef, health = info and info.healthMax or nil, energy = definition.energy},
        description = definition.description,
        evolutions = evolutionChain(name),
        moves = moves,
        abilities = abilities,
        specialAbilities = special,
        shiny = DiscordBridge.isShiny(name),
        legendary = DiscordBridge.isLegendary(name),
        catchable = info and info.catchable or false,
        shinyVariant = info and info.shiny ~= "" and info.shiny or nil,
    }
end

local function handlePokemonSearch(params)
    local query = string.lower(sanitizeText(params.query, 40))
    local limit = math.min(tonumber(params.limit) or CONFIG.searchLimit, CONFIG.searchLimit)
    local prefix, contains = JSON.array(), JSON.array()
    for _, name in ipairs(pokemonsNames) do
        local lower = string.lower(name)
        if (query == "" or lower:sub(1, #query) == query) then
            prefix[#prefix + 1] = name
        elseif (lower:find(query, 1, true)) then
            contains[#contains + 1] = name
        end
    end

    local out = JSON.array()
    for _, list in ipairs({prefix, contains}) do
        for _, name in ipairs(list) do
            if (#out >= limit) then
                return {names = out}
            end
            out[#out + 1] = name
        end
    end
    return {names = out}
end

local GAME_STATE_NAMES = {
    [GAMESTATE_STARTUP] = "startup", [GAMESTATE_INIT] = "init", [GAMESTATE_NORMAL] = "normal",
    [GAMESTATE_MAINTAIN] = "maintain", [GAMESTATE_CLOSED] = "closed", [GAMESTATE_CLOSING] = "closing",
    [GAMESTATE_SHUTDOWN] = "shutdown",
}

local function handleServerStatus()
    local info = getDiscordBridgeInfo()
    return {
        serverName = getConfigValue("serverName"),
        state = GAME_STATE_NAMES[getGameState()] or "unknown",
        playersOnline = #getPlayersOnline(),
        maxPlayers = tonumber(getConfigValue("maxPlayers")),
        uptime = getWorldUpTime(),
        bootId = info.bootId,
    }
end

local function handleBridgeConfig()
    local legendary = JSON.array()
    for _, name in ipairs(CONFIG.legendary) do
        legendary[#legendary + 1] = name
    end
    return {
        chatChannelId = CONFIG.chatChannelId,
        chatAuthorPrefix = CONFIG.chatAuthorPrefix,
        chatTextMaxLength = CONFIG.chatTextMaxLength,
        chatAuthorMaxLength = CONFIG.chatAuthorMaxLength,
        legendary = legendary,
    }
end

local HANDLERS = {
    ["chat.send"] = handleChatSend,
    ["trainer.lookup"] = handleTrainerLookup,
    ["pokemon.lookup"] = handlePokemonLookup,
    ["pokemon.search"] = handlePokemonSearch,
    ["server.status"] = handleServerStatus,
    ["bridge.config"] = handleBridgeConfig,
}

local function respond(requestId, ok, payload)
    local message = {type = "response", requestId = requestId, ok = ok}
    if (ok) then
        message.result = payload
    else
        message.error = payload
    end

    local encoded, json = pcall(JSON.encode, message)
    if (not encoded) then
        json = JSON.encode({type = "response", requestId = requestId, ok = false,
            error = {code = "internal", message = "can't encode response"}})
    end
    doDiscordBridgeSend(json)
end

function DiscordBridge.handleMessage(raw)
    local message, err = JSON.decode(raw)
    if (type(message) ~= "table" or message.type ~= "request") then
        log(LOG_TYPES.WARNING, "DiscordBridge - ignored message", err or (type(message) == "table" and message.type))
        return
    end

    local requestId = message.requestId
    if (type(requestId) ~= "string" or #requestId == 0 or #requestId > 64) then
        return
    end

    local handler = HANDLERS[message.method]
    if (not handler) then
        respond(requestId, false, {code = "unknown_method", message = "unknown method"})
        return
    end

    local params = type(message.params) == "table" and message.params or {}
    local ok, resultOrError = pcall(handler, params)
    if (ok) then
        respond(requestId, true, resultOrError)
    elseif (getmetatable(resultOrError) == RequestError) then
        respond(requestId, false, {code = resultOrError.code, message = resultOrError.message})
    else
        log(LOG_TYPES.ERROR, "DiscordBridge - request failed", message.method, resultOrError)
        respond(requestId, false, {code = "internal", message = "internal error"})
    end
end

-- Called from the "discordbridge" globalevent whenever messages arrive.
function DiscordBridge.processIncoming()
    for _, raw in ipairs(getDiscordBridgeMessages(CONFIG.maxRequestsPerDrain)) do
        safeCall("handleMessage", DiscordBridge.handleMessage, raw)
    end
end
