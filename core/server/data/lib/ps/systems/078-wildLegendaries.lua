-- Wild legendaries: the 21 legendaries roam Kanto one or two at a time, for group fights
-- (docs/upcoming-features.md, "Legendary spawning").
--
-- Talkactions, creature events and globalevents run in separate Lua states, so everything
-- shared lives in global storage (written to the database at once, like 073-shinyEvent.lua)
-- and in the legendary's own creature storage. Only the serverExpEvent globalevent
-- (WildLegendaries.onThink) spawns on schedule, moves, heals and ends encounters. The creature
-- events only record hits (wildLegendaryHit) and hand out the rewards (wildLegendaryDeath).
--
-- The wild one is the plain species from its monster file; only its health is raised, for that
-- encounter. A caught one has the normal stats of its species.

WildLegendaries = {}

local HOUR, DAY = 3600, 86400

WildLegendaries.SPECIES = {
    { name = "Articuno", tier = 1, home = "seafoam" },
    { name = "Zapdos", tier = 1, home = "power_plant" },
    { name = "Moltres", tier = 1, home = "volcano" },
    { name = "Raikou", tier = 1, home = "routes_11_12" },
    { name = "Entei", tier = 1, home = "volcano" },
    { name = "Suicune", tier = 1, home = "rivers" },
    { name = "Regirock", tier = 1, home = "rock_tunnel" },
    { name = "Regice", tier = 1, home = "seafoam" },
    { name = "Registeel", tier = 1, home = "power_plant" },
    { name = "Latias", tier = 1, home = "coasts", fast = true },
    { name = "Latios", tier = 1, home = "coasts", fast = true },
    { name = "Mewtwo", tier = 2, home = "cerulean_cave" },
    { name = "Mew", tier = 2, home = "mansion" },
    { name = "Lugia", tier = 2, home = "southern_shores" },
    { name = "Ho-Oh", tier = 2, home = "indigo" },
    { name = "Celebi", tier = 2, home = "viridian_forest" },
    { name = "Kyogre", tier = 2, home = "southern_shores" },
    { name = "Groudon", tier = 2, home = "volcano" },
    { name = "Rayquaza", tier = 2, home = "indigo" },
    { name = "Jirachi", tier = 2, home = "mt_moon" },
    { name = "Deoxys", tier = 2, home = "mt_moon" },
}

local BY_NAME = {}
for _, species in ipairs(WildLegendaries.SPECIES) do
    BY_NAME[species.name:lower()] = species
end

WildLegendaries.CONFIG = {
    maxAlive = 2,
    maxTier2Alive = 1,
    tierWeight = { 3, 1 },

    -- Trainers online -> gap to the next spawn and the cooldowns. The gap is drawn at each
    -- spawn and checked again every 5 minutes, so it shrinks when the server fills up.
    -- The second row starts at 5 trainers on live; it is 1 while we test.
    population = {
        { online = 0, gap = { 16 * HOUR, 24 * HOUR }, cooldown = { 30 * HOUR, 4 * DAY } },
        { online = 1, gap = { 4 * HOUR, 8 * HOUR }, cooldown = { 30 * HOUR, 4 * DAY } },
        { online = 15, gap = { 3 * HOUR, 6 * HOUR }, cooldown = { 24 * HOUR, 3 * DAY } },
        { online = 40, gap = { 2 * HOUR, 4 * HOUR }, cooldown = { 16 * HOUR, 2 * DAY } },
    },
    gapCheckInterval = 300,
    retryInterval = 60,         -- when a spawn is due but blocked (limits, restart window)
    quietBeforeRestart = 2 * HOUR,

    lifetime = { 90 * 60, 120 * 60 },
    stayWhileHit = 120,         -- doesn't fly off while hit within this many seconds
    moveEvery = { 4 * 60, 6 * 60 },
    fastMoveEvery = { 2 * 60, 3 * 60 },
    holdWhileHit = 60,          -- doesn't move on while hit within this many seconds
    minMoveDistance = 120,      -- a move to the Kanto pool goes at least this far
    homeChance = 50,
    flee = { { 0.5 }, { 0.5, 0.25 } },
    healAfter = 3 * 60,
    healPercent = 5,            -- of max health every 5 seconds once left alone

    healthMultiplier = { 30, 60 },
    recommendedLevel = 50,

    rewardRatio = 0.1,
    rewards = { { rareCandy = 1, money = 5000 }, { rareCandy = 2, money = 10000 } },
    rareCandyId = 14463,
    bodyOwnerSeconds = 60,
    bodySeconds = 180,
    catchWindow = 300,          -- a catch this long after the defeat is announced as the legendary's

    channelId = 14,             -- data/XML/channels.xml "Legendaries"
}
local CONFIG = WildLegendaries.CONFIG

local KEY = {
    NEXT_AT = GLOBAL_STORAGES.LEGENDARY_NEXT_AT,
    GAP_FROM = GLOBAL_STORAGES.LEGENDARY_GAP_FROM,
    GAP_ROLL = GLOBAL_STORAGES.LEGENDARY_GAP_ROLL,
    COOLDOWNS = GLOBAL_STORAGES.LEGENDARY_COOLDOWNS,
    ACTIVE = GLOBAL_STORAGES.LEGENDARY_ACTIVE,
    SEQUENCE = GLOBAL_STORAGES.LEGENDARY_SEQUENCE,
    RECENT = GLOBAL_STORAGES.LEGENDARY_RECENT,
}

-- Creature storage of the legendary itself.
local MON = {
    ENCOUNTER = 9100,
    ENDS_AT = 9101,
    LAST_HIT = 9102,
    NEXT_MOVE = 9103,
    FLEE_STAGE = 9104,
    FLEE_PENDING = 9105,
    AREA = 9106,
    SPAWNED_AT = 9107,
    LAST_HEAL = 9108,
}

-- Storage ---------------------------------------------------------------------------------------

local function getNumber(key)
    return tonumber(getStorage(key)) or -1
end

local function store(key, value)
    doSetStorage(key, value)
    db.executeQuery(string.format("REPLACE INTO `global_storage` (`key`, `world_id`, `value`) VALUES (%d, %d, %s);",
        key, getConfigValue("worldId") or 0, db.escapeString(tostring(value))))
end

-- "c;Articuno=123;Mewtwo=456": a letter first so getStorage never reads it as a number.
local function readMap(key)
    local map = {}
    local text = getStorage(key)
    if (type(text) == "string") then
        for name, value in text:gmatch("([^;=]+)=([^;]*)") do
            map[name] = value
        end
    end
    return map
end

local function writeMap(key, map)
    local parts = { "m" }
    for name, value in pairs(map) do
        table.insert(parts, name .. "=" .. tostring(value))
    end
    store(key, table.concat(parts, ";"))
end

local function monGet(cid, key)
    local value = getCreatureStorage(cid, key)
    return tonumber(value) or value
end

local function monNumber(cid, key)
    return tonumber(getCreatureStorage(cid, key)) or -1
end

-- Active encounters: encounter id -> "cid:Species". Kept in the database so the encounters
-- open at a restart can be closed on the Discord side.
local function getActive()
    local list = {}
    for encounter, value in pairs(readMap(KEY.ACTIVE)) do
        local cid, name = value:match("^(%d+):(.+)$")
        if (cid) then
            table.insert(list, { encounter = tonumber(encounter), cid = tonumber(cid), name = name })
        end
    end
    table.sort(list, function(a, b) return a.encounter < b.encounter end)
    return list
end

local function setActive(encounter, cid, name)
    local map = readMap(KEY.ACTIVE)
    map[tostring(encounter)] = cid and (cid .. ":" .. name) or nil
    writeMap(KEY.ACTIVE, map)
end

function WildLegendaries.getSpecies(name)
    return name and BY_NAME[tostring(name):lower()] or nil
end

function WildLegendaries.isEncounter(cid)
    return isMonster(cid) and monNumber(cid, MON.ENCOUNTER) > 0
end

function WildLegendaries.getCooldowns()
    local cooldowns = {}
    for name, value in pairs(readMap(KEY.COOLDOWNS)) do
        cooldowns[name] = tonumber(value)
    end
    return cooldowns
end

function WildLegendaries.setCooldown(name, untilTime)
    local map = readMap(KEY.COOLDOWNS)
    map[name] = untilTime
    writeMap(KEY.COOLDOWNS, map)
end

function WildLegendaries.clearCooldowns(name)
    if (not name) then
        store(KEY.COOLDOWNS, "m")
        return
    end
    local map = readMap(KEY.COOLDOWNS)
    map[name] = nil
    writeMap(KEY.COOLDOWNS, map)
end

-- Population -------------------------------------------------------------------------------------

function WildLegendaries.getOnline()
    local players = getPlayersOnline()
    return type(players) == "table" and #players or 0
end

function WildLegendaries.getPopulation(online)
    online = online or WildLegendaries.getOnline()
    local row = CONFIG.population[1]
    for _, r in ipairs(CONFIG.population) do
        if (online >= r.online) then
            row = r
        end
    end
    return row
end

local function lerp(range, roll)
    return math.floor(range[1] + (range[2] - range[1]) * roll / 1000)
end

-- Next spawn time with today's population; never later than the time already set.
local function scheduleNext(now, fresh)
    if (fresh or getNumber(KEY.GAP_FROM) <= 0) then
        store(KEY.GAP_FROM, now)
        store(KEY.GAP_ROLL, getRandom(0, 1000))
        store(KEY.NEXT_AT, 0)
    end
    local candidate = getNumber(KEY.GAP_FROM) + lerp(WildLegendaries.getPopulation().gap, getNumber(KEY.GAP_ROLL))
    local current = getNumber(KEY.NEXT_AT)
    if (current <= 0 or candidate < current) then
        store(KEY.NEXT_AT, candidate)
    end
    return getNumber(KEY.NEXT_AT)
end
WildLegendaries.scheduleNext = scheduleNext

function WildLegendaries.getNextSpawn()
    local at = getNumber(KEY.NEXT_AT)
    return at > 0 and at or nil
end

function WildLegendaries.setNextSpawn(at)
    store(KEY.NEXT_AT, at)
end

-- Seconds until the daily restart, or nil.
local function untilRestart(now)
    if (not ServerRestart) then
        return nil
    end
    local at = ServerRestart.getScheduled()
    local daily = ServerRestart.getDaily()
    if (daily) then
        local nextDaily = ServerRestart.nextDaily(daily, now)
        at = (at and math.min(at, nextDaily)) or nextDaily
    end
    return at and (at - now) or nil
end

-- Points -----------------------------------------------------------------------------------------

local WATER = {}
for _, id in ipairs(WATER_IDS or {}) do
    WATER[id] = true
end

local function toPosition(point)
    return { x = point[1], y = point[2], z = point[3] }
end

-- Ground, no water, no protection zone or house. With cid, also room for that creature.
function WildLegendaries.isGoodPoint(pos, cid)
    local ground = getTileThingByPos({ x = pos.x, y = pos.y, z = pos.z, stackpos = STACKPOS_GROUND })
    if (not ground or not ground.itemid or ground.itemid == 0 or WATER[ground.itemid]) then
        return false
    end
    local info = getTileInfo(pos)
    if (not info or info.protection or info.house) then
        return false
    end
    if (cid and doTileQueryAdd(cid, pos, 0, false) ~= RETURNVALUE_NOERROR) then
        return false
    end
    return true
end

local function farEnough(point, from, distance)
    if (not from) then
        return true
    end
    return math.max(math.abs(point[1] - from.x), math.abs(point[2] - from.y)) >= distance
end

-- A point for the species: its home area half the time, anywhere in Kanto otherwise.
function WildLegendaries.pickPoint(species, cid, from)
    local anchors = LEGENDARY_ANCHORS
    local home = anchors.HOMES[species.home] or anchors.ROAM
    for try = 1, 40 do
        local useHome = getRandom(1, 100) <= CONFIG.homeChance
        local pool = useHome and home or anchors.ROAM
        local point = pool[getRandom(1, #pool)]
        local distance = useHome and 20 or CONFIG.minMoveDistance
        if (try > 30 or farEnough(point, from, distance)) then
            -- the points are spawn spots, so a wild Pokemon often stands on them
            for radius = 0, 3 do
                for dx = -radius, radius do
                    for dy = -radius, radius do
                        if (math.max(math.abs(dx), math.abs(dy)) == radius) then
                            local pos = { x = point[1] + dx, y = point[2] + dy, z = point[3] }
                            if (WildLegendaries.isGoodPoint(pos, cid)) then
                                return pos, point[4]
                            end
                        end
                    end
                end
            end
        end
    end
    return nil
end

-- Notifications ----------------------------------------------------------------------------------

local function getLook(name)
    local info = getMonsterInfo(name)
    return info and info.outfit and info.outfit.lookType or nil
end

local function cardFor(data)
    data.look = data.look or getLook(data.species)
    data.dexNumber = data.dexNumber or getPokemonNumberByName(data.species)
    return JSON.encode(data)
end

-- Cards for the modern client (EXTENDED_IDS.LEGENDARY); older clients get the text only.
local function sendCard(players, data)
    if (not EXTENDED_IDS.LEGENDARY) then
        return
    end
    local payload = cardFor(data)
    for _, pid in ipairs(players) do
        if (isPlayer(pid) and getPlayerUsingOtClient(pid)) then
            doSendPlayerExtendedOpcode(pid, EXTENDED_IDS.LEGENDARY, payload)
        end
    end
end

local function allPlayers()
    local players = getPlayersOnline()
    return type(players) == "table" and players or {}
end

local function channelPlayers()
    local users = getChannelUsers(CONFIG.channelId)
    return type(users) == "table" and users or {}
end

local function toChannel(text)
    for _, pid in ipairs(channelPlayers()) do
        if (isPlayer(pid)) then
            doPlayerSendChannelMessage(pid, "", text, TALKTYPE_CHANNEL_O, CONFIG.channelId)
        end
    end
end

local function broadcast(text)
    doBroadcastMessage(text, MESSAGE_STATUS_WARNING)
    toChannel(text)
end

local function discord(event)
    if (DiscordBridge and DiscordBridge.emitLegendary) then
        DiscordBridge.emitLegendary(event)
    end
end

-- Encounters -------------------------------------------------------------------------------------

local function nextMoveDelay(species)
    local range = species.fast and CONFIG.fastMoveEvery or CONFIG.moveEvery
    return getRandom(range[1], range[2])
end

local function boostHealth(cid, species)
    local health = getCreatureMaxHealth(cid) * CONFIG.healthMultiplier[species.tier]
    setCreatureMaxHealth(cid, health)
    doCreatureAddHealth(cid, health)
end

local function healthPercent(cid)
    return math.floor(getCreatureHealth(cid) * 100 / math.max(1, getCreatureMaxHealth(cid)) + 0.5)
end

-- Creates the legendary. pos/area optional (staff "here"). Returns cid or nil, error.
function WildLegendaries.spawn(species, pos, area, source)
    for _, active in ipairs(getActive()) do
        if (active.name == species.name and isMonster(active.cid)) then
            return nil, species.name .. " is already out."
        end
    end
    local explicit = pos ~= nil
    if (not pos) then
        pos, area = WildLegendaries.pickPoint(species)
        if (not pos) then
            return nil, "No free point found for " .. species.name .. "."
        end
    end

    WildLegendaries.creating = true
    local cid = doCreateMonster(species.name, pos, false, false)
    for try = 1, 5 do
        if (isMonster(cid) or explicit) then
            break
        end
        pos, area = WildLegendaries.pickPoint(species)
        if (pos) then
            cid = doCreateMonster(species.name, pos, false, false)
        end
    end
    WildLegendaries.creating = false
    if (not isMonster(cid)) then
        return nil, "The monster could not be placed."
    end

    local now = os.time()
    local encounter = math.max(0, getNumber(KEY.SEQUENCE)) + 1
    store(KEY.SEQUENCE, encounter)
    area = area or "an unknown place"

    boostHealth(cid, species)
    doCreatureSetStorage(cid, MON.ENCOUNTER, encounter)
    doCreatureSetStorage(cid, MON.SPAWNED_AT, now)
    doCreatureSetStorage(cid, MON.ENDS_AT, now + CONFIG.lifetime[species.tier])
    doCreatureSetStorage(cid, MON.NEXT_MOVE, now + nextMoveDelay(species))
    doCreatureSetStorage(cid, MON.FLEE_STAGE, 0)
    doCreatureSetStorage(cid, MON.FLEE_PENDING, 0)
    doCreatureSetStorage(cid, MON.LAST_HIT, 0)
    doCreatureSetStorage(cid, MON.AREA, area)
    registerCreatureEvent(cid, "wildLegendaryHit")
    registerCreatureEvent(cid, "wildLegendaryDeath")
    setActive(encounter, cid, species.name)
    doSendMagicEffect(getCreaturePosition(cid), EFFECT_TELEPORT_DOWN)

    broadcast(string.format("A wild %s has appeared near %s! Recommended for trainers level %d+.",
        species.name, area, CONFIG.recommendedLevel))
    sendCard(allPlayers(), { type = "spawn", species = species.name, tier = species.tier, area = area,
        level = CONFIG.recommendedLevel, endsAt = now + CONFIG.lifetime[species.tier] })
    local position = getCreaturePosition(cid)
    discord({ event = "spawn", encounterId = encounter, species = species.name, tier = species.tier, area = area,
        position = position, endsAt = now + CONFIG.lifetime[species.tier], source = source or "schedule",
        health = getCreatureMaxHealth(cid) })
    print(string.format("> Legendary: %s #%d near %s (%d, %d, %d), %s", species.name, encounter, area,
        position.x, position.y, position.z, source or "schedule"))
    return cid
end

-- Moves the legendary to another point. Returns the area or nil.
local function relocate(cid, species)
    local from = getCreaturePosition(cid)
    for try = 1, 5 do
        local pos, area = WildLegendaries.pickPoint(species, cid, from)
        if (pos) then
            doTeleportThing(cid, pos, false)
            if (getSamePosition(getCreaturePosition(cid), pos)) then
                doSendMagicEffect(from, EFFECT_TELEPORT_UP)
                doSendMagicEffect(pos, EFFECT_TELEPORT_DOWN)
                doCreatureSetStorage(cid, MON.AREA, area)
                return area
            end
        end
    end
    return nil
end

function WildLegendaries.move(cid, reason)
    local species = WildLegendaries.getSpecies(getCreatureName(cid))
    if (not species) then
        return false
    end
    local area = relocate(cid, species)
    doCreatureSetStorage(cid, MON.NEXT_MOVE, os.time() + nextMoveDelay(species))
    if (not area) then
        return false
    end
    local encounter = monNumber(cid, MON.ENCOUNTER)
    if (reason == "flee") then
        broadcast(string.format("%s is hurt and fled! It was last seen near %s with %d%% health.",
            species.name, area, healthPercent(cid)))
        sendCard(allPlayers(), { type = "flee", species = species.name, area = area, health = healthPercent(cid) })
    else
        toChannel(string.format("%s was spotted near %s.", species.name, area))
        sendCard(channelPlayers(), { type = "sighting", species = species.name, area = area })
    end
    discord({ event = reason == "flee" and "flee" or "sighting", encounterId = encounter, species = species.name,
        area = area, position = getCreaturePosition(cid), healthPercent = healthPercent(cid) })
    return true
end

-- Ends an encounter that is still alive: reason "fled" (time up), "staff" or "restart".
-- Only "fled" starts the cooldown.
function WildLegendaries.finish(cid, reason)
    local name = getCreatureName(cid)
    local species = WildLegendaries.getSpecies(name)
    local encounter = monNumber(cid, MON.ENCOUNTER)
    local area = monGet(cid, MON.AREA)
    setActive(encounter, nil)
    if (reason == "fled" and species) then
        WildLegendaries.setCooldown(species.name, os.time() + WildLegendaries.getPopulation().cooldown[species.tier])
    end
    doSendMagicEffect(getCreaturePosition(cid), EFFECT_TELEPORT_UP)
    doRemoveCreature(cid)
    if (reason ~= "restart") then
        broadcast(string.format("The wild %s flew away%s.", name, type(area) == "string" and (" from " .. area) or ""))
        sendCard(allPlayers(), { type = "end", reason = reason, species = name })
    end
    discord({ event = "end", reason = reason, encounterId = encounter, species = name })
end

-- Species that may spawn now, with their weights.
function WildLegendaries.eligible(now)
    now = now or os.time()
    local active = getActive()
    if (#active >= CONFIG.maxAlive) then
        return {}, "two legendaries are out"
    end
    local out, tier2 = {}, 0
    for _, a in ipairs(active) do
        out[a.name] = true
        local s = WildLegendaries.getSpecies(a.name)
        if (s and s.tier == 2) then
            tier2 = tier2 + 1
        end
    end
    local cooldowns = WildLegendaries.getCooldowns()
    local list = {}
    for _, species in ipairs(WildLegendaries.SPECIES) do
        if (not out[species.name] and (cooldowns[species.name] or 0) <= now and
                (species.tier == 1 or tier2 < CONFIG.maxTier2Alive)) then
            table.insert(list, species)
        end
    end
    return list
end

function WildLegendaries.pickSpecies(list)
    local total = 0
    for _, species in ipairs(list) do
        total = total + CONFIG.tierWeight[species.tier]
    end
    if (total <= 0) then
        return nil
    end
    local roll = getRandom(1, total)
    for _, species in ipairs(list) do
        roll = roll - CONFIG.tierWeight[species.tier]
        if (roll <= 0) then
            return species
        end
    end
    return list[#list]
end

-- Why the scheduled spawn can't happen right now, or nil.
function WildLegendaries.blocked(now)
    local remaining = untilRestart(now)
    if (remaining and remaining < CONFIG.quietBeforeRestart) then
        return "the daily restart is less than 2 hours away"
    end
    local list, why = WildLegendaries.eligible(now)
    if (#list == 0) then
        return why or "every legendary that may come is out or on cooldown"
    end
    return nil
end

-- Defeat, rewards and catch ----------------------------------------------------------------------

-- Called from the wildLegendaryDeath creature event (corpse is not on the map yet).
function WildLegendaries.onDeath(cid, corpse)
    local name = getCreatureName(cid)
    local species = WildLegendaries.getSpecies(name)
    local encounter = monNumber(cid, MON.ENCOUNTER)
    local area = monGet(cid, MON.AREA)
    local position = getCreaturePosition(cid)
    setActive(encounter, nil)
    if (not species) then
        return
    end
    WildLegendaries.setCooldown(species.name, os.time() + WildLegendaries.getPopulation().cooldown[species.tier])

    local reward = CONFIG.rewards[species.tier]
    local winners, top, topRatio = {}, nil, -1
    for _, pid in ipairs(allPlayers()) do
        local ratio = getCreatureDamageRatioByMaster(cid, pid) or 0
        if (ratio >= CONFIG.rewardRatio) then
            table.insert(winners, getCreatureName(pid))
            doPlayerSafeAddItem(pid, CONFIG.rareCandyId, reward.rareCandy, true, false)
            doPlayerAddMoney(pid, reward.money)
            if (Pokepedia and Pokepedia.onLegendaryDefeated) then
                Pokepedia.onLegendaryDefeated(pid, species.name)
            end
            doPlayerSendTextMessage(pid, MESSAGE_STATUS_CONSOLE_ORANGE, string.format(
                "You dealt %d%% of the damage to %s: %d Rare Cand%s and $%d.", math.floor(ratio * 100 + 0.5),
                species.name, reward.rareCandy, reward.rareCandy == 1 and "y" or "ies", reward.money))
            sendCard({ pid }, { type = "reward", species = species.name, share = math.floor(ratio * 100 + 0.5),
                rareCandy = reward.rareCandy, money = reward.money })
        end
        if (ratio > topRatio and ratio > 0) then
            top, topRatio = pid, ratio
        end
    end

    if (isItem(corpse)) then
        doItemSetAttribute(corpse.uid, "duration", CONFIG.bodySeconds * 1000)
        local owner = getItemAttribute(corpse.uid, "corpseowner")
        local ownerPlayer = owner and getPlayerByGUID(owner)
        if (ownerPlayer and isPlayer(ownerPlayer)) then
            doPlayerSendTextMessage(ownerPlayer, MESSAGE_STATUS_CONSOLE_ORANGE, string.format(
                "You have %d seconds to throw a ball at %s before anyone else can.", CONFIG.bodyOwnerSeconds, species.name))
        end
        addEvent(WildLegendaries.releaseBody, CONFIG.bodyOwnerSeconds * 1000, position, corpse.itemid, species.name)
    end

    local recent = readMap(KEY.RECENT)
    recent[species.name] = os.time() .. ":" .. encounter
    writeMap(KEY.RECENT, recent)

    broadcast(string.format("The wild %s was defeated%s!", species.name,
        #winners > 0 and (" by " .. table.concat(winners, ", ")) or ""))
    sendCard(allPlayers(), { type = "end", reason = "defeated", species = species.name, trainers = winners })
    discord({ event = "end", reason = "defeated", encounterId = encounter, species = species.name,
        area = type(area) == "string" and area or nil, trainers = winners,
        topTrainer = top and getCreatureName(top) or nil })
end

-- After the top damage dealer's window anyone may throw at the body.
function WildLegendaries.releaseBody(position, itemid, name)
    local body = getTileItemById(position, itemid)
    if (isItem(body) and getItemAttribute(body.uid, "pokemon") == name) then
        doItemEraseAttribute(body.uid, "corpseowner")
        local spectators = getSpectators(position, 8, 8, false) or {}
        for _, pid in ipairs(spectators) do
            if (isPlayer(pid)) then
                doPlayerSendTextMessage(pid, MESSAGE_STATUS_CONSOLE_ORANGE,
                    string.format("Anyone can throw a ball at the fainted %s now.", name))
            end
        end
    end
end

-- From DiscordBridge.onCatch's caller: a catch of a species defeated in the last minutes.
function WildLegendaries.onCatch(cid, name)
    local species = WildLegendaries.getSpecies(name)
    if (not species) then
        return
    end
    local recent = readMap(KEY.RECENT)
    local at, encounter = tostring(recent[species.name] or ""):match("^(%d+):(%d+)$")
    if (not at or os.time() - tonumber(at) > CONFIG.catchWindow) then
        return
    end
    recent[species.name] = nil
    writeMap(KEY.RECENT, recent)
    broadcast(string.format("%s caught the wild %s!", getCreatureName(cid), species.name))
    sendCard(allPlayers(), { type = "caught", species = species.name, trainer = getCreatureName(cid) })
    discord({ event = "caught", encounterId = tonumber(encounter), species = species.name, trainer = getCreatureName(cid) })
end

-- From the wildLegendaryHit creature event.
function WildLegendaries.onHit(cid, value)
    local now = os.time()
    doCreatureSetStorage(cid, MON.LAST_HIT, now)
    local species = WildLegendaries.getSpecies(getCreatureName(cid))
    if (not species) then
        return
    end
    local stage = math.max(0, monNumber(cid, MON.FLEE_STAGE))
    local threshold = CONFIG.flee[species.tier][stage + 1]
    local left = getCreatureHealth(cid) - value
    if (threshold and left > 0 and left <= getCreatureMaxHealth(cid) * threshold) then
        doCreatureSetStorage(cid, MON.FLEE_STAGE, stage + 1)
        doCreatureSetStorage(cid, MON.FLEE_PENDING, 1)
    end
end

-- Executor ---------------------------------------------------------------------------------------

local function upkeep(cid, now)
    if (getCreatureHealth(cid) <= 0) then
        return
    end
    if (monNumber(cid, MON.FLEE_PENDING) == 1) then
        doCreatureSetStorage(cid, MON.FLEE_PENDING, 0)
        WildLegendaries.move(cid, "flee")
        return
    end
    local lastHit = monNumber(cid, MON.LAST_HIT)
    if (now >= monNumber(cid, MON.ENDS_AT) and now - lastHit >= CONFIG.stayWhileHit) then
        WildLegendaries.finish(cid, "fled")
        return
    end
    if (now >= monNumber(cid, MON.NEXT_MOVE)) then
        if (now - lastHit < CONFIG.holdWhileHit) then
            doCreatureSetStorage(cid, MON.NEXT_MOVE, now + 30)
        else
            WildLegendaries.move(cid, "roam")
        end
        return
    end
    if (now - lastHit >= CONFIG.healAfter and now - monNumber(cid, MON.LAST_HEAL) >= 5) then
        local missing = getCreatureMaxHealth(cid) - getCreatureHealth(cid)
        if (missing > 0) then
            doCreatureSetStorage(cid, MON.LAST_HEAL, now)
            doCreatureAddHealth(cid, math.min(missing, math.ceil(getCreatureMaxHealth(cid) * CONFIG.healPercent / 100)))
            if (getCreatureHealth(cid) >= getCreatureMaxHealth(cid)) then
                doCreatureSetStorage(cid, MON.FLEE_STAGE, 0)
            end
        end
    end
end

-- Closes encounters whose monster is gone (removed by staff tools, a crash or a restart).
local function sweep(restart)
    for _, active in ipairs(getActive()) do
        if (restart or not isMonster(active.cid) or getCreatureName(active.cid) ~= active.name) then
            setActive(active.encounter, nil)
            discord({ event = "end", reason = restart and "restart" or "vanished", encounterId = active.encounter,
                species = active.name })
        end
    end
end

-- Executor state (only used in the globalevent's Lua state).
local started = false
local lastGapCheck, lastSpawnTry = 0, 0

function WildLegendaries.onThink()
    local now = os.time()
    if (not started) then
        started = true
        sweep(true) -- one still alive at the restart counts as fled with no cooldown
        scheduleNext(now, false)
        print("> Legendary: next wild legendary " .. os.date("%Y-%m-%d %H:%M", WildLegendaries.getNextSpawn()))
    end

    for _, active in ipairs(getActive()) do
        if (isMonster(active.cid)) then
            upkeep(active.cid, now)
        end
    end

    if (now - lastGapCheck >= CONFIG.gapCheckInterval) then
        lastGapCheck = now
        sweep(false)
        scheduleNext(now, false)
    end

    local nextAt = WildLegendaries.getNextSpawn()
    if (nextAt and now >= nextAt and now - lastSpawnTry >= CONFIG.retryInterval) then
        lastSpawnTry = now
        if (not WildLegendaries.blocked(now)) then
            local species = WildLegendaries.pickSpecies(WildLegendaries.eligible(now))
            if (species and WildLegendaries.spawn(species)) then
                scheduleNext(now, true)
            end
        end
    end
end

-- Status for /legendary status and the Legendaries channel.
function WildLegendaries.describe(staff)
    local lines, now = {}, os.time()
    local active = getActive()
    for _, a in ipairs(active) do
        if (isMonster(a.cid)) then
            local area = monGet(a.cid, MON.AREA)
            local line = string.format("%s near %s, %d%% health, leaves in %s.", a.name, tostring(area),
                healthPercent(a.cid), ServerExpEvent.formatDuration(monNumber(a.cid, MON.ENDS_AT) - now))
            if (staff) then
                local p = getCreaturePosition(a.cid)
                line = string.format("#%d %s (%d, %d, %d) %d/%d HP", a.encounter, line, p.x, p.y, p.z,
                    getCreatureHealth(a.cid), getCreatureMaxHealth(a.cid))
            end
            table.insert(lines, line)
        end
    end
    if (#lines == 0) then
        table.insert(lines, "No wild legendary is out right now.")
    end
    if (staff) then
        local online = WildLegendaries.getOnline()
        local row = WildLegendaries.getPopulation(online)
        local nextAt = WildLegendaries.getNextSpawn()
        table.insert(lines, string.format("Online %d: gap %s to %s, cooldowns %s / %s.", online,
            ServerExpEvent.formatDuration(row.gap[1]), ServerExpEvent.formatDuration(row.gap[2]),
            ServerExpEvent.formatDuration(row.cooldown[1]), ServerExpEvent.formatDuration(row.cooldown[2])))
        table.insert(lines, nextAt and string.format("Next spawn %s (in %s)%s.", os.date("%Y-%m-%d %H:%M", nextAt),
            ServerExpEvent.formatDuration(nextAt - now),
            WildLegendaries.blocked(now) and (", waiting: " .. WildLegendaries.blocked(now)) or "")
            or "No spawn scheduled yet.")
        local cooling = {}
        for name, untilTime in pairs(WildLegendaries.getCooldowns()) do
            if (untilTime > now) then
                table.insert(cooling, string.format("%s %s", name, ServerExpEvent.formatDuration(untilTime - now)))
            end
        end
        table.sort(cooling)
        table.insert(lines, "Cooldowns: " .. (#cooling > 0 and table.concat(cooling, ", ") or "none"))
    end
    return lines
end

-- Living legendary of that species, or nil.
function WildLegendaries.find(name)
    for _, a in ipairs(getActive()) do
        if (a.name:lower() == tostring(name):lower() and isMonster(a.cid)) then
            return a.cid, a
        end
    end
    return nil
end

WildLegendaries.getActive = getActive
WildLegendaries.upkeep = upkeep
WildLegendaries.sweep = sweep
WildLegendaries.MON = MON
WildLegendaries.KEY = KEY
