-- Vocations (docs/upcoming-features.md, section 6): from trainer level 20 a trainer picks one of
-- six vocations, once and for good, and starts at rank 1. Ranks 2 to 5 need a trainer level
-- (Vocations.RANK_LEVELS) and are given by the vocation quests and tasks (Vocations.rankUp).
-- Perks never touch Pokemon damage or stats and never work in duels, the PvP arena or NPC battles.
--
-- The client's vocation window (game_vocation) talks JSON on EXTENDED_IDS.VOCATION:
--   server -> client  {type = "open", level, minLevel, chosen, rank, title, vocations = {{key, name, tagline, perks}, ...}}
--                     {type = "chosen", key, name, rank, title}
--                     {type = "result", ok, text}
--   client -> server  {action = "open"} (the U key), {action = "choose", key}, {action = "close"}
-- A choice is only accepted while a window opened by Vocations.open is up. For now every trainer can
-- open it with U; below Vocations.MIN_LEVEL it opens with the choice locked.
--
-- The Ranger radar popup (game_radar) talks JSON on EXTENDED_IDS.RADAR:
--   server -> client  {type = "status", enabled, rank, title, range, cooldown, wait, legendaryWait, unlocks, open}
--                     {type = "scan", ...the status fields, center = {x, y, z}, blips = {{id, x, y, z, kind, exact,
--                      distance, direction, band, name, look, types}, ...}}
--                     {type = "error", text, wait}
--   client -> server  {action = "hello"}, {action = "scan"}
-- kind is common, uncommon, rare, shiny or legendary ("unknown" before speciesRank). Names and looks
-- come from speciesRank, types from typeFilterRank; filtering happens in the popup.
--
-- Where the perks are used:
--   Ace Trainer  doPlayerPokemonAddExperience (functions/player.lua): Pokemon EXP from defeats
--   Catcher      emptyBall and catchMiss (functions/ball/empty.lua)
--   Breeder      the incubator (events/actions/eggIncubator) and the daycare (npc/scripts/daycareFemale.lua)
--   Ranger       Vocations.radar, the !radar command
--   Angler       Fishing (systems/043-fishing.lua), the Fishing Guide window (!fishing) and the cranes
--   Medic        the health potions (events/actions/potions/healthPotions.lua)

Vocations = {}

Vocations.MIN_LEVEL = 20
Vocations.RANK_LEVELS = { 20, 30, 40, 50, 60 }
Vocations.MAX_RANK = #Vocations.RANK_LEVELS

-- id is what the storage keeps, so ids never change or get reused
Vocations.LIST = {
    { id = 1, key = "ace", name = "Ace Trainer", tagline = "Battles and experience",
      perks = { "Battle EXP +2% to +10%", "Titles up to Ace Trainer", "Bonus grows with each rank" },
      titles = { "Novice Trainer", "Pokemon Trainer", "Experienced Trainer", "Veteran Trainer", "Ace Trainer" } },
    { id = 2, key = "catcher", name = "Catcher", tagline = "Catching",
      perks = { "Catch chance +2% to +10%", "Ball back after a failed throw", "Bonus grows with each rank" },
      titles = { "Rookie Catcher", "Ball Adept", "Seasoned Catcher", "Elite Catcher", "Master Catcher" } },
    { id = 3, key = "breeder", name = "Breeder", tagline = "Eggs and the daycare",
      perks = { "Hatching up to 25% faster", "Chance of a second egg", "Better early egg chance" },
      titles = { "Novice Breeder", "Egg Keeper", "Skilled Breeder", "Expert Breeder", "Master Breeder" } },
    { id = 4, key = "ranger", name = "Ranger", tagline = "Tracking wild Pokemon",
      perks = { "Radar for nearby spawns", "Filter by type, see direction", "Rare finds at top ranks" },
      titles = { "Ranger Cadet", "Field Ranger", "Area Ranger", "Ranger Captain", "Top Ranger" } },
    { id = 5, key = "angler", name = "Angler", tagline = "Fishing",
      perks = { "Faster fishing skill", "See what bites, fishing map", "Only Anglers use cranes" },
      titles = { "Novice Angler", "Angler", "Skilled Angler", "Expert Angler", "Master Angler" } },
    { id = 6, key = "medic", name = "Medic", tagline = "Healing and support",
      perks = { "Healing items +3% to +15%", "Heal other players' team", "Bonus grows with each rank" },
      titles = { "Medic Trainee", "Field Medic", "Senior Medic", "Pokemon Doctor", "Chief Medic" } },
}

-- Every tunable number, by rank 1 to 5
Vocations.PERKS = {
    ace = {
        battleExp = { 0.02, 0.04, 0.06, 0.08, 0.10 }, -- extra Pokemon EXP from defeated Pokemon
    },
    catcher = {
        catchChance = { 0.02, 0.04, 0.06, 0.08, 0.10 }, -- relative: multiplies the normal chance
        ballBack = { 0.02, 0.04, 0.06, 0.08, 0.10 }, -- chance to get the ball back after a failed throw
    },
    breeder = {
        hatchTime = { 0.05, 0.10, 0.15, 0.20, 0.25 }, -- shorter hatching, every egg
        secondEgg = { 0.02, 0.04, 0.06, 0.08, 0.10 }, -- daycare, Premium
        earlyEgg = { 0.11, 0.12, 0.13, 0.14, 0.15 }, -- daycare daily early egg chance (others 0.10), Premium
    },
    ranger = {
        range = { 30, 50, 80, 120, 200 }, -- tiles
        cooldown = { 60, 50, 40, 35, 30 }, -- seconds
        accuracy = { 5, 3, 1, 1, 1 }, -- tiles: the popup snaps blips to this grid, 1 is exact
        typeFilterRank = 2,
        speciesRank = 3, -- species, direction and distance instead of a count
        shinyRank = 4,
        legendaryRank = 5, -- legendaries and event Pokemon
        legendaryCooldown = 10 * 60,
    },
    angler = {
        fishingExp = { 0.20, 0.40, 0.60, 0.80, 1.00 }, -- extra fishing skill tries
        spotInfoRank = 2, -- which Pokemon can bite where the line is cast
        fastBiteRank = 3,
        fastBiteDelay = 0.5, -- of the rod's wait before the first bite
        fastBiteLuck = 0.15, -- added to each bite roll
        mapRank = 4, -- the !fishing guide: what bites in each region at which skill
        cranesRank = 5, -- cranes are for these Anglers only (and still need fishing skill 60)
    },
    medic = {
        healing = { 0.03, 0.06, 0.09, 0.12, 0.15 }, -- health potion effect
        healOthersRank = 1, -- health potions on other trainers' Pokemon, outside duels and battles
    },
}

local STORAGE = playersStorages.vocation
local RANK = playersStorages.vocationRank
-- a storage, not a table: talkactions, NPCs and creature scripts each have their own Lua state
local WINDOW = playersStorages.vocationWindow
local RADAR_AT = playersStorages.vocationRadarAt
local LEGENDARY_AT = playersStorages.vocationLegendaryAt

local byKey, byId = {}, {}
for _, vocation in ipairs(Vocations.LIST) do
    byKey[vocation.key] = vocation
    byId[vocation.id] = vocation
end

local function send(cid, data)
    doSendPlayerExtendedOpcode(cid, EXTENDED_IDS.VOCATION, JSON.encode(data))
end

local function result(cid, ok, text)
    send(cid, { type = "result", ok = ok, text = __L(cid, text) })
    return ok
end

local function withArticle(text)
    return (text:match("^[AEIOUaeiou]") and "an " or "a ") .. text
end

local function reply(cid, text)
    doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, text)
end

Vocations.get = function(cid)
    return byId[getPlayerStorageValue(cid, STORAGE)]
end

Vocations.is = function(cid, key)
    local vocation = Vocations.get(cid)
    return vocation ~= nil and vocation.key == key
end

Vocations.getRank = function(cid)
    if (not Vocations.get(cid)) then
        return 0
    end
    return math.max(1, math.min(Vocations.MAX_RANK, getPlayerStorageValue(cid, RANK)))
end

Vocations.getTitle = function(cid)
    local vocation = Vocations.get(cid)
    return vocation and vocation.titles[Vocations.getRank(cid)] or nil
end

-- The value of one perk for this trainer, or nil when the trainer is not of that vocation.
-- Rank tables give the value at the trainer's rank; a "...Rank" number gives true once reached.
Vocations.perk = function(cid, key, perk)
    if (not isPlayer(cid) or not Vocations.is(cid, key)) then
        return nil
    end
    local value = Vocations.PERKS[key][perk]
    local rank = Vocations.getRank(cid)
    if (type(value) == "table") then
        return value[rank]
    elseif (perk:sub(-4) == "Rank") then
        return rank >= value or nil
    end
    return value
end

-- Duels, the PvP arena and NPC trainer battles
Vocations.inBattle = function(cid)
    return (getPlayerDueling(cid) or getPlayerPvpArena(cid) or getPlayerBattleing(cid)) and true or false
end

Vocations.updateDescription = function(cid)
    local vocation = Vocations.get(cid)
    if (not vocation) then
        doPlayerSetSpecialDescription(cid, "")
        return
    end
    doPlayerSetSpecialDescription(cid, string.format(__L(cid, ". Vocation: %s, %s (rank %d)"),
        __L(cid, vocation.name), __L(cid, Vocations.getTitle(cid)), Vocations.getRank(cid)))
end

Vocations.setRank = function(cid, rank)
    if (not Vocations.get(cid)) then
        return false
    end
    rank = math.max(1, math.min(Vocations.MAX_RANK, rank))
    setPlayerStorageValue(cid, RANK, rank)
    Vocations.updateDescription(cid)
    Vocations.sendRadarStatus(cid)
    Fishing.sendStatus(cid)
    return true
end

-- For the rank-up quests and tasks: the next rank, when the trainer's level allows it
Vocations.rankUp = function(cid)
    local vocation = Vocations.get(cid)
    local rank = Vocations.getRank(cid)
    if (not vocation or rank >= Vocations.MAX_RANK) then
        return false
    end
    if (getPlayerLevel(cid) < Vocations.RANK_LEVELS[rank + 1]) then
        doPlayerSendCancel(cid, string.format(__L(cid, "You need trainer level %d for the next rank."),
            Vocations.RANK_LEVELS[rank + 1]))
        return false
    end
    Vocations.setRank(cid, rank + 1)
    doSendMagicEffect(getCreaturePosition(cid), EFFECT_FIREWORK_YELLOW)
    doPlayerSendTextMessage(cid, MESSAGE_EVENT_ADVANCE, string.format(__L(cid, "You are now %s!"),
        withArticle(__L(cid, Vocations.getTitle(cid)))))
    return true
end

Vocations.open = function(cid)
    if (not isPlayer(cid)) then
        return false
    end
    if (not getPlayerUsingOtClient(cid)) then
        reply(cid, __L(cid, "Choosing a vocation needs the PokeVerse client."))
        return false
    end
    local list = {}
    for _, vocation in ipairs(Vocations.LIST) do
        local perks = {}
        for _, perk in ipairs(vocation.perks) do
            perks[#perks + 1] = __L(cid, perk)
        end
        list[#list + 1] = { key = vocation.key, name = __L(cid, vocation.name), tagline = __L(cid, vocation.tagline),
                            perks = perks }
    end
    local chosen = Vocations.get(cid)
    setPlayerStorageValue(cid, WINDOW, chosen and -1 or 1)
    send(cid, { type = "open", level = getPlayerLevel(cid), minLevel = Vocations.MIN_LEVEL,
                chosen = chosen and chosen.key or nil, rank = chosen and Vocations.getRank(cid) or nil,
                title = chosen and __L(cid, Vocations.getTitle(cid)) or nil, vocations = list })
    return true
end

Vocations.choose = function(cid, key)
    local vocation = byKey[tostring(key or "")]
    if (not vocation) then
        return false
    end
    if (Vocations.get(cid)) then
        return result(cid, false, "You already have a vocation.")
    end
    if (getPlayerStorageValue(cid, WINDOW) ~= 1) then
        return result(cid, false, "Press U to open the vocation window.")
    end
    if (getPlayerLevel(cid) < Vocations.MIN_LEVEL) then
        return result(cid, false, string.format(__L(cid, "You need trainer level %d to choose a vocation."),
            Vocations.MIN_LEVEL))
    end
    setPlayerStorageValue(cid, WINDOW, -1)
    setPlayerStorageValue(cid, STORAGE, vocation.id)
    Vocations.setRank(cid, 1)
    doSendMagicEffect(getCreaturePosition(cid), EFFECT_FIREWORK_YELLOW)
    doPlayerSendTextMessage(cid, MESSAGE_EVENT_ADVANCE,
        string.format(__L(cid, "You are now %s!"), withArticle(__L(cid, vocation.name))))
    send(cid, { type = "chosen", key = vocation.key, name = __L(cid, vocation.name), rank = 1,
                title = __L(cid, vocation.titles[1]) })
    return true
end

Vocations.reset = function(cid)
    setPlayerStorageValue(cid, STORAGE, -1)
    setPlayerStorageValue(cid, RANK, -1)
    setPlayerStorageValue(cid, WINDOW, -1)
    Vocations.updateDescription(cid)
    Vocations.sendRadarStatus(cid)
    Fishing.sendStatus(cid)
end

-- Catcher: a failed roll gets a second chance sized so the catch chance becomes chance * (1 + bonus)
Vocations.catchSecondChance = function(cid, chance)
    local bonus = Vocations.perk(cid, "catcher", "catchChance")
    if (not bonus or chance <= 0 or chance >= 1) then
        return false
    end
    local wanted = math.min(1, chance * (1 + bonus))
    return math.random() < (wanted - chance) / (1 - chance)
end

-- Ranger radar ---------------------------------------------------------------------------------

local DIRECTIONS = { "east", "south-east", "south", "south-west", "west", "north-west", "north", "north-east" }

local function direction(from, to)
    local dx, dy = to.x - from.x, to.y - from.y
    if (dx == 0 and dy == 0) then
        return "here"
    end
    local angle = math.deg(math.atan2(dy, dx)) -- y grows to the south
    return DIRECTIONS[(math.floor((angle + 22.5) / 45) % 8) + 1]
end

local function band(distance)
    if (distance <= 30) then
        return "near"
    elseif (distance <= 100) then
        return "far"
    end
    return "very far"
end

local TYPE_NAMES = {}
for id, name in pairs(ELEMENT_NAMES) do
    TYPE_NAMES[name:lower()] = id
end
TYPE_NAMES["fighting"] = TYPE_NAMES["fight"]

local pokemonNames

local function isPokemon(name)
    if (not pokemonNames) then
        pokemonNames = {}
        for _, n in ipairs(pokemonsNames) do
            pokemonNames[n] = true
        end
    end
    return pokemonNames[name] == true
end

local function hasType(name, typeId)
    for _, t in ipairs(getPokemonTypes(nil, name) or {}) do
        if (t == typeId) then
            return true
        end
    end
    return false
end

local function isSpecial(name)
    return (getPokemonAllowedBall(name) or getPokemonIgnoreBallCounter(name)) and true or false
end

-- What the radar would show the trainer: { regular = {...}, shiny = {...}, legendary = {...} }, each
-- entry { cid, name, pos, distance, direction }, nearest first. Only wild Pokemon on the trainer's floor.
Vocations.scan = function(cid, range, typeId)
    local pos = getCreaturePosition(cid)
    local found = { regular = {}, shiny = {}, legendary = {} }
    for _, creature in ipairs(getSpectators(pos, range, range, false) or {}) do
        if (isMonster(creature) and not isSummon(creature)) then
            local name = getCreatureName(creature)
            if (isPokemon(name) and (not typeId or hasType(name, typeId))) then
                local where = getCreaturePosition(creature)
                local entry = { cid = creature, name = name, pos = where, distance = getDistanceBetween(pos, where),
                                direction = direction(pos, where) }
                if (DiscordBridge.isLegendary(name) or isSpecial(name)) then
                    table.insert(found.legendary, entry)
                elseif (isShinyName(name)) then
                    table.insert(found.shiny, entry)
                else
                    table.insert(found.regular, entry)
                end
            end
        end
    end
    for _, list in pairs(found) do
        table.sort(list, function(a, b) return a.distance < b.distance end)
    end
    return found
end

local MAX_BLIPS = 40 -- one scan has to fit in one network message
local RARITY_CHANCE = { uncommon = 100, rare = 400 } -- getPokemonCatchChance: Rattata 2, Pikachu 150, Dragonite 800
local BAND_DISTANCE = { near = 15, far = 60, ["very far"] = 150 }
local DIRECTION_ANGLES = {} -- degrees from east, clockwise: y grows to the south
for i, name in ipairs(DIRECTIONS) do
    DIRECTION_ANGLES[name] = (i - 1) * 45
end

local function rarity(name)
    local chance = getPokemonCatchChance(name) or 0
    if (chance >= RARITY_CHANCE.rare or (Pokepedia.tier and Pokepedia.tier(name) == "rare")) then
        return "rare"
    elseif (chance >= RARITY_CHANCE.uncommon) then
        return "uncommon"
    end
    return "common"
end

local function rangerRank(cid)
    return Vocations.is(cid, "ranger") and Vocations.getRank(cid) or 0
end

-- Starts the recharge; false and the seconds left while it is still recharging
local function charge(cid, rank)
    local now = os.time()
    local wait = getPlayerStorageValue(cid, RADAR_AT) - now
    if (wait > 0) then
        return false, wait
    end
    setPlayerStorageValue(cid, RADAR_AT, now + Vocations.PERKS.ranger.cooldown[rank])
    return true
end

-- Legendaries show once per legendaryCooldown, from legendaryRank
local function legendaryReady(cid, rank, found)
    local perks = Vocations.PERKS.ranger
    if (rank < perks.legendaryRank or #found.legendary == 0) then
        return false
    end
    local now = os.time()
    if (getPlayerStorageValue(cid, LEGENDARY_AT) > now) then
        return false
    end
    setPlayerStorageValue(cid, LEGENDARY_AT, now + perks.legendaryCooldown)
    return true
end

-- Where the popup draws a blip. Exact from speciesRank, snapped to a grid of accuracy tiles below it.
-- Shinies and legendaries only at the middle of their direction and distance band.
local function blipPosition(center, entry, rank, range, vague)
    if (vague) then
        local distance = math.min(BAND_DISTANCE[band(entry.distance)], range)
        local angle = math.rad(DIRECTION_ANGLES[entry.direction] or 0)
        return { x = center.x + math.floor(math.cos(angle) * distance + 0.5),
                 y = center.y + math.floor(math.sin(angle) * distance + 0.5), z = center.z }, false
    end
    local grid = Vocations.PERKS.ranger.accuracy[rank]
    if (grid <= 1) then
        return { x = entry.pos.x, y = entry.pos.y, z = entry.pos.z }, true
    end
    local function snap(value, from)
        return from + math.floor((value - from) / grid + 0.5) * grid
    end
    return { x = snap(entry.pos.x, center.x), y = snap(entry.pos.y, center.y), z = center.z }, false
end

local function blip(center, entry, kind, rank, range)
    local perks = Vocations.PERKS.ranger
    local vague = kind == "shiny" or kind == "legendary"
    local pos, exact = blipPosition(center, entry, rank, range, vague)
    local data = { id = entry.cid, x = pos.x, y = pos.y, z = pos.z, kind = kind, exact = exact,
                   distance = exact and entry.distance or getDistanceBetween(center, pos),
                   direction = entry.direction, band = vague and band(entry.distance) or nil }
    if (rank >= perks.speciesRank or kind == "legendary") then
        data.name = entry.name
        local outfit = getCreatureOutfit(entry.cid)
        data.look = outfit and outfit.lookType or nil
    end
    if (rank >= perks.typeFilterRank) then
        local types = {}
        for _, id in ipairs(getPokemonTypes(nil, entry.name) or {}) do
            if (ELEMENT_NAMES[id]) then
                types[#types + 1] = ELEMENT_NAMES[id]:lower()
            end
        end
        data.types = JSON.array(types)
    end
    return data
end

-- What the popup needs besides the blips: rank, range, the recharge and which filters are open
Vocations.radarState = function(cid)
    local rank = rangerRank(cid)
    if (rank == 0) then
        return { type = "status", enabled = false }
    end
    local perks = Vocations.PERKS.ranger
    local now = os.time()
    return { type = "status", enabled = true, rank = rank, title = __L(cid, Vocations.getTitle(cid)),
             range = perks.range[rank], cooldown = perks.cooldown[rank],
             wait = math.max(0, getPlayerStorageValue(cid, RADAR_AT) - now),
             legendaryWait = rank >= perks.legendaryRank and math.max(0, getPlayerStorageValue(cid, LEGENDARY_AT) - now) or nil,
             unlocks = { type = perks.typeFilterRank, species = perks.speciesRank, rarity = perks.speciesRank,
                         shiny = perks.shinyRank, legendary = perks.legendaryRank } }
end

-- One scan for the popup (the recharge already started): the state plus center and blips
Vocations.radarScan = function(cid)
    local rank = rangerRank(cid)
    local perks = Vocations.PERKS.ranger
    local range = perks.range[rank]
    local center = getCreaturePosition(cid)
    local found = Vocations.scan(cid, range)
    local blips = {}
    local function add(list, kindOf)
        for _, entry in ipairs(list) do
            if (#blips >= MAX_BLIPS) then
                return
            end
            blips[#blips + 1] = blip(center, entry, kindOf(entry), rank, range)
        end
    end
    -- the rare finds first, so the cap only drops the farthest regular Pokemon
    if (legendaryReady(cid, rank, found)) then
        add(found.legendary, function() return "legendary" end)
    end
    if (rank >= perks.shinyRank) then
        add(found.shiny, function() return "shiny" end)
    end
    add(found.regular, function(entry)
        return rank >= perks.speciesRank and rarity(entry.name) or "unknown"
    end)
    local data = Vocations.radarState(cid)
    data.type = "scan"
    data.center = { x = center.x, y = center.y, z = center.z }
    data.blips = JSON.array(blips)
    return data
end

local function sendRadar(cid, data)
    doSendPlayerExtendedOpcode(cid, EXTENDED_IDS.RADAR, JSON.encode(data))
end

Vocations.sendRadarStatus = function(cid, open)
    if (isPlayer(cid)) then
        local data = Vocations.radarState(cid)
        data.open = open or nil
        sendRadar(cid, data)
    end
end

-- The popup's Scan button
Vocations.radarPopupScan = function(cid)
    local rank = rangerRank(cid)
    if (rank == 0) then
        sendRadar(cid, { type = "error", text = __L(cid, "Only Rangers can use the radar.") })
        return false
    end
    local ok, wait = charge(cid, rank)
    if (not ok) then
        sendRadar(cid, { type = "error", wait = wait,
            text = string.format(__L(cid, "Your radar is recharging. Try again in %d seconds."), wait) })
        return false
    end
    doSendMagicEffect(getCreaturePosition(cid), EFFECT_WATER_PULSE)
    sendRadar(cid, Vocations.radarScan(cid))
    return true
end

-- !radar [type]: opens the popup in the PokeVerse client (scanning when the radar is charged),
-- text replies in other clients
Vocations.radar = function(cid, param)
    local rank = rangerRank(cid)
    if (rank == 0) then
        doPlayerSendCancel(cid, "Only Rangers can use the radar.")
        return false
    end
    if (getPlayerUsingOtClient(cid)) then
        if (getPlayerStorageValue(cid, RADAR_AT) > os.time()) then
            Vocations.sendRadarStatus(cid, true)
            return true
        end
        return Vocations.radarPopupScan(cid)
    end

    local perks = Vocations.PERKS.ranger
    local typeId
    param = (param or ""):trim():lower()
    if (param ~= "") then
        if (rank < perks.typeFilterRank) then
            doPlayerSendCancel(cid, string.format(__L(cid, "You can pick a type from Ranger rank %d."), perks.typeFilterRank))
            return false
        end
        typeId = TYPE_NAMES[param]
        if (not typeId) then
            doPlayerSendCancel(cid, "Unknown type.")
            return false
        end
    end

    local ok, wait = charge(cid, rank)
    if (not ok) then
        doPlayerSendCancel(cid, string.format(__L(cid, "Your radar is recharging. Try again in %d seconds."), wait))
        return false
    end

    local range = perks.range[rank]
    local found = Vocations.scan(cid, range, typeId)
    local typeText = typeId and (" " .. ELEMENT_NAMES[typeId]) or ""
    doSendMagicEffect(getCreaturePosition(cid), EFFECT_WATER_PULSE)

    if (rank < perks.speciesRank) then
        reply(cid, string.format(__L(cid, "Radar: %d wild%s Pokemon within %d tiles."), #found.regular, typeText, range))
    elseif (#found.regular == 0) then
        reply(cid, string.format(__L(cid, "Radar: no wild%s Pokemon within %d tiles."), typeText, range))
    else
        local groups, order = {}, {}
        for _, entry in ipairs(found.regular) do
            if (not groups[entry.name]) then
                groups[entry.name] = { count = 0, nearest = entry }
                order[#order + 1] = entry.name
            end
            groups[entry.name].count = groups[entry.name].count + 1
        end
        local parts = {}
        for i, name in ipairs(order) do
            if (i > 8) then
                parts[#parts + 1] = string.format(__L(cid, "and %d more species"), #order - 8)
                break
            end
            local group = groups[name]
            parts[#parts + 1] = string.format("%s%s (%s, %d tiles)", name,
                group.count > 1 and (" x" .. group.count) or "", __L(cid, group.nearest.direction), group.nearest.distance)
        end
        reply(cid, string.format(__L(cid, "Radar, %d tiles: %s."), range, table.concat(parts, ", ")))
    end

    if (rank >= perks.shinyRank) then
        for _, entry in ipairs(found.shiny) do
            reply(cid, string.format(__L(cid, "Radar: a shiny %s, %s to the %s!"), (entry.name:gsub("^[Ss]hiny ", "")),
                __L(cid, band(entry.distance)), __L(cid, entry.direction)))
        end
    end
    if (legendaryReady(cid, rank, found)) then
        for _, entry in ipairs(found.legendary) do
            reply(cid, string.format(__L(cid, "Radar: something rare, %s to the %s: %s!"),
                __L(cid, band(entry.distance)), __L(cid, entry.direction), entry.name))
        end
    end
    return true
end

Vocations.onRadarMessage = function(cid, buffer)
    local ok, data = pcall(JSON.decode, buffer)
    if (not ok or type(data) ~= "table") then
        return
    end
    local action = tostring(data.action or "")
    if (action == "scan") then
        Vocations.radarPopupScan(cid)
    elseif (action == "hello") then
        Vocations.sendRadarStatus(cid)
    end
end

-- Events ---------------------------------------------------------------------------------------

Vocations.onClientMessage = function(cid, buffer)
    local ok, data = pcall(JSON.decode, buffer)
    if (not ok or type(data) ~= "table") then
        return
    end
    local action = tostring(data.action or "")
    if (action == "open") then
        Vocations.open(cid)
    elseif (action == "choose") then
        Vocations.choose(cid, data.key)
    elseif (action == "close") then
        setPlayerStorageValue(cid, WINDOW, -1)
    end
end

Vocations.onLogin = function(cid)
    setPlayerStorageValue(cid, WINDOW, -1)
    Vocations.updateDescription(cid)
    Vocations.sendRadarStatus(cid)
    Fishing.sendStatus(cid)
end

Vocations.onLogout = function(cid)
    setPlayerStorageValue(cid, WINDOW, -1)
end
