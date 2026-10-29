-- Vocations (docs/upcoming-features.md, section 6): from trainer level 20 a trainer picks one of
-- six vocations, once and for good, and starts at rank 1. Ranks 2 to 5 need a trainer level
-- (Vocations.RANK_LEVELS) and the rank's trial; then the vocation window's Rank up button gives them
-- (Vocations.rankUp).
-- Perks never touch Pokemon damage or stats and never work in duels, the PvP arena or NPC battles.
--
-- The client's vocation window (game_vocation) talks JSON on EXTENDED_IDS.VOCATION:
--   server -> client  {type = "open", level, minLevel, chosen, rank, title, vocations = {{key, name, tagline, perks}, ...}}
--                     {type = "chosen", key, name, rank, title}
--                     {type = "trial", have, need, goals = {{id, text, have, need}}, ready} (the goals done and
--                      of the rank, each goal's count; the top bar button's "!"; without a vocation
--                      {type = "trial", choose = true, ready} where ready means level 20 is reached)
--                     {type = "result", ok, text}
--   client -> server  {action = "open"} (the U key), {action = "choose", key}, {action = "close"}
-- A choice is only accepted while a window opened by Vocations.open is up. For now every trainer can
-- open it with U; below Vocations.MIN_LEVEL it opens with the choice locked.
--
-- The Ranger radar popup (game_radar) talks JSON on EXTENDED_IDS.RADAR:
--   server -> client  {type = "status", enabled, rank, title, range, cooldown, wait, legendaryWait, unlocks, open}
--                     {type = "scan", ...the status fields, center = {x, y, z}, live, blips = {{id, x, y, z, kind, exact,
--                      distance, direction, band, name, look, types}, ...}, total}: at most MAX_BLIPS blips,
--                      spread over the range; total is how many Pokemon the scan found
--                     {type = "error", text, wait}
--                     {type = "live", blips = {{id, x, y, z}}, gone = {ids}}: from liveRank, every liveMs for
--                      liveSeconds after a scan, the exact blips that moved and the ones that are gone
--                     {type = "print", id, x, y, z, way}: from printsRank, a step of the tracked Pokemon on soft
--                      ground (way: north, east, south or west); {type = "track", id, seconds} or {type = "track"}
--                      when a track starts or ends
--   client -> server  {action = "hello"}, {action = "scan"}, {action = "live", on}: whether the popup
--                     wants the live updates (it is open, or tracking a target); {action = "track", id}: follow
--                     that blip's footprints, {action = "track"} stops
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

-- id is what the storage keeps, so ids never change or get reused. outfit is the XML/outfits.xml id that only
-- this vocation can wear, looks its female and male look types.
Vocations.LIST = {
    { id = 1, key = "ace", outfit = 40, looks = { 1200, 1201 }, name = "Ace Trainer", tagline = "Battles and experience",
      perks = { "Battle EXP +2% to +10%", "Titles up to Ace Trainer", "Bonus grows with each rank" },
      titles = { "Novice Trainer", "Pokemon Trainer", "Experienced Trainer", "Veteran Trainer", "Ace Trainer" } },
    { id = 2, key = "catcher", outfit = 37, looks = { 1184, 1185 }, name = "Catcher", tagline = "Catching",
      perks = { "Catch chance +2% to +10%", "Ball back after a failed throw", "Bonus grows with each rank" },
      titles = { "Rookie Catcher", "Ball Adept", "Seasoned Catcher", "Elite Catcher", "Master Catcher" } },
    { id = 3, key = "breeder", outfit = 80, looks = { 2574, 2573 }, name = "Breeder", tagline = "Eggs and the daycare",
      perks = { "Hatching up to 25% faster", "Chance of a second egg", "Better early egg chance" },
      titles = { "Novice Breeder", "Egg Keeper", "Skilled Breeder", "Expert Breeder", "Master Breeder" } },
    { id = 4, key = "ranger", outfit = 49, looks = { 1202, 1203 }, name = "Ranger", tagline = "Tracking wild Pokemon",
      perks = { "Radar for nearby spawns", "Filter by type, see direction", "Rare finds at top ranks" },
      titles = { "Ranger Cadet", "Field Ranger", "Area Ranger", "Ranger Captain", "Top Ranger" } },
    { id = 5, key = "angler", outfit = 9, looks = { 627, 628 }, name = "Angler", tagline = "Fishing",
      perks = { "Faster fishing skill", "See what bites, fishing map", "Only Anglers use cranes" },
      titles = { "Novice Angler", "Angler", "Skilled Angler", "Expert Angler", "Master Angler" } },
    { id = 6, key = "medic", outfit = 81, looks = { 1310, 1309 }, name = "Medic", tagline = "Healing and support",
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
        liveRank = 3, -- exact blips follow their Pokemon after the scan (shinies and legendaries stay vague)
        liveMs = 2000, -- how often the server sends where they went
        liveSeconds = 120, -- how long after a scan
        printsRank = 2, -- the tracked Pokemon's footprints show on soft ground (dirt, grass, sand)
        printsSeconds = 180, -- how long a track lasts
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
local OUTFITS_MIGRATED = playersStorages.vocationOutfits
local TRIAL = playersStorages.vocationTrial
local SINCE = playersStorages.vocationSince
local RADAR_AT = playersStorages.vocationRadarAt
local LEGENDARY_AT = playersStorages.vocationLegendaryAt

local byKey, byId, byLook = {}, {}, {}
for _, vocation in ipairs(Vocations.LIST) do
    byKey[vocation.key] = vocation
    byId[vocation.id] = vocation
    for _, look in ipairs(vocation.looks) do
        byLook[look] = vocation
    end
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

-- The chosen vocation's name for a character who may be offline ("Trainer" before choosing)
Vocations.nameOf = function(guid)
    local cid = getPlayerByGUID(guid)
    local id
    if (cid and isPlayer(cid)) then
        id = getPlayerStorageValue(cid, STORAGE)
    else
        local r = db.getResult(string.format("SELECT `value` FROM `player_storage` WHERE `player_id` = %d AND `key` = %d LIMIT 1",
            tonumber(guid) or 0, STORAGE))
        if (r:getID() ~= -1) then
            id = tonumber(r:getDataString("value"))
            r:free()
        end
    end
    return byId[id] and byId[id].name or "Trainer"
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

-- Rank-up trials: besides the trainer level, each rank is earned by doing what the vocation is
-- about. Every goal of the rank has to be done. goals[r] is what takes rank r to rank r + 1 (0: not a
-- goal at that rank); the counts start again at each rank.
--   on      the event that counts (Vocations.addTrial): defeat, catch, hatch, scan, find, hook, heal, healOther
--   unique  only species not counted yet at this rank (one unique goal per vocation: a single bitmap)
--   shiny   only shiny Pokemon
--   skill   the skill level itself is the count (on = "skill", sent from onAdvance)
-- Goal ids are their place in the list and the storage keeps counts in that order, so only add goals at the end.
Vocations.TRIALS = {
    ace = {
        { on = "defeat", text = "Defeat %d wild Pokemon", goals = { 200, 500, 1000, 2000 } },
        { on = "defeat", unique = true, text = "Defeat %d different wild species", goals = { 15, 30, 50, 80 } },
    },
    catcher = {
        { on = "catch", text = "Catch %d Pokemon", goals = { 50, 150, 300, 600 } },
        { on = "catch", unique = true, text = "Catch %d different species", goals = { 10, 25, 45, 70 } },
        { on = "catch", shiny = true, text = "Catch %d shiny Pokemon", goals = { 0, 0, 1, 2 } },
    },
    breeder = {
        { on = "hatch", text = "Hatch %d eggs", goals = { 2, 4, 6, 10 } },
        { on = "hatch", unique = true, text = "Hatch %d different species", goals = { 1, 2, 3, 5 } },
    },
    ranger = {
        { on = "scan", text = "Find wild Pokemon with %d radar scans", goals = { 100, 300, 600, 1200 } },
        { on = "find", unique = true, text = "Find %d different species on the radar", goals = { 10, 25, 45, 70 } },
        { on = "find", shiny = true, text = "Find %d shiny Pokemon on the radar", goals = { 0, 0, 0, 1 } },
    },
    angler = {
        { on = "hook", text = "Hook %d Pokemon while fishing", goals = { 100, 300, 600, 1200 } },
        { on = "hook", unique = true, text = "Hook %d different species", goals = { 4, 8, 14, 20 } },
        { on = "skill", skill = PLAYER_SKILL_FISHING, text = "Reach fishing skill %d", goals = { 15, 30, 45, 60 } },
    },
    medic = {
        { on = "heal", text = "Heal %d Pokemon with potions", goals = { 50, 150, 300, 600 } },
        { on = "healOther", text = "Heal %d of other trainers' Pokemon", goals = { 5, 15, 30, 50 } },
    },
}

local TRIAL_SPECIES = playersStorages.vocationTrialSpecies

-- The species counted by the rank's unique goal: a hex bitmap of Pokedex numbers, bit n - 1 for number n.
-- Stored after an "s" and the counts after a "g": the server reads a value that starts with a digit as a number.
local function hasSpecies(map, number)
    local digit = tonumber(map:sub(math.ceil(number / 4), math.ceil(number / 4)), 16) or 0
    return math.floor(digit / 2 ^ ((number - 1) % 4)) % 2 == 1
end

local function addSpecies(map, number)
    local at = math.ceil(number / 4)
    if (#map < at) then
        map = map .. string.rep("0", at - #map)
    end
    local digit = (tonumber(map:sub(at, at), 16) or 0) + 2 ^ ((number - 1) % 4)
    return map:sub(1, at - 1) .. string.format("%x", digit) .. map:sub(at + 1)
end

local function speciesMap(cid)
    local map = tostring(getPlayerStorageValue(cid, TRIAL_SPECIES)):match("^s(%x*)$")
    return map or ""
end

-- The counts, in TRIALS order. Before there were several goals the storage was the first goal's number.
local function trialCounts(cid)
    local counts, value = {}, tostring(getPlayerStorageValue(cid, TRIAL)):gsub("^g", "")
    for count in value:gmatch("[^,]+") do
        counts[#counts + 1] = math.max(0, tonumber(count) or 0)
    end
    return counts
end

local function goalCount(cid, goal, counts, i)
    if (goal.skill) then
        return getPlayerSkillLevel(cid, goal.skill)
    end
    return counts[i] or 0
end

-- { goals = {{id, text, have, need}}, have, need } for the trainer's next rank, nil without a vocation or at
-- the top rank. have and need of the whole trial are the goals done and the goals of the rank.
Vocations.getTrial = function(cid)
    local vocation = Vocations.get(cid)
    local rank = Vocations.getRank(cid)
    if (not vocation or rank >= Vocations.MAX_RANK) then
        return nil
    end
    local counts = trialCounts(cid)
    -- text is for clients from before the goals, which show "Trial: <text>  <have> / <need>"
    local trial = { goals = {}, have = 0, need = 0, text = __L(cid, "rank-up goals done") }
    for i, goal in ipairs(Vocations.TRIALS[vocation.key]) do
        local need = goal.goals[rank] or 0
        if (need > 0) then
            local have = math.min(need, goalCount(cid, goal, counts, i))
            trial.goals[#trial.goals + 1] = { id = i, text = string.format(__L(cid, goal.text), need), have = have, need = need }
            trial.need = trial.need + 1
            trial.have = trial.have + (have >= need and 1 or 0)
        end
    end
    trial.goals = JSON.array(trial.goals)
    return trial
end

-- Whether the trainer may take the next rank now, and why not
Vocations.canRankUp = function(cid)
    local rank = Vocations.getRank(cid)
    if (rank == 0 or rank >= Vocations.MAX_RANK) then
        return false
    end
    if (getPlayerLevel(cid) < Vocations.RANK_LEVELS[rank + 1]) then
        return false, string.format(__L(cid, "You need trainer level %d for the next rank."), Vocations.RANK_LEVELS[rank + 1])
    end
    local trial = Vocations.getTrial(cid)
    for _, goal in ipairs(trial.goals) do
        if (goal.have < goal.need) then
            return false, string.format(__L(cid, "Finish your rank-up trial first: %s (%d/%d)."), goal.text, goal.have, goal.need)
        end
    end
    return true
end

Vocations.resetTrial = function(cid)
    setPlayerStorageValue(cid, TRIAL, 0)
    setPlayerStorageValue(cid, TRIAL_SPECIES, "")
end

-- Counts an event for the trial's goals; called where the vocation's perks are used. name is the
-- Pokemon's, for the unique and shiny goals. For "skill", amount is the level before the advance.
-- Tells the trainer as goals and the whole trial get done.
Vocations.addTrial = function(cid, key, event, name, amount)
    if (not isPlayer(cid) or not Vocations.is(cid, key)) then
        return
    end
    local rank = Vocations.getRank(cid)
    if (rank >= Vocations.MAX_RANK) then
        return
    end
    local counts, map = trialCounts(cid), nil
    local changed, finished = event == "skill", {}
    for i, goal in ipairs(Vocations.TRIALS[key]) do
        local need = goal.goals[rank] or 0
        local before = goal.skill and (amount or 0) or goalCount(cid, goal, counts, i)
        if (goal.on == event and need > 0 and before < need) then
            local step = amount or 1
            if (goal.shiny and not (name and isShinyName(name))) then
                step = 0
            elseif (goal.unique) then
                local number = name and getPokemonNumberByName(name)
                map = map or speciesMap(cid)
                if (not number or hasSpecies(map, number)) then
                    step = 0
                else
                    map, step = addSpecies(map, number), 1
                end
            end
            if (step > 0 and not goal.skill) then
                counts[i] = math.min(need, before + step)
                changed = true
            end
            if (goalCount(cid, goal, counts, i) >= need) then
                finished[#finished + 1] = string.format(__L(cid, goal.text), need)
            end
        end
    end
    if (not changed and #finished == 0) then
        return
    end
    if (changed and event ~= "skill") then
        for i = 1, #Vocations.TRIALS[key] do
            counts[i] = counts[i] or 0
        end
        setPlayerStorageValue(cid, TRIAL, "g" .. table.concat(counts, ","))
        if (map) then
            setPlayerStorageValue(cid, TRIAL_SPECIES, "s" .. map)
        end
    end
    local trial = Vocations.getTrial(cid)
    if (#finished > 0 and trial.have >= trial.need) then
        local ready = Vocations.canRankUp(cid)
        doPlayerSendTextMessage(cid, MESSAGE_EVENT_ADVANCE, ready and
            __L(cid, "Rank-up trial done! Open the vocation window to rank up.") or
            string.format(__L(cid, "Rank-up trial done! You can rank up at trainer level %d."),
                Vocations.RANK_LEVELS[rank + 1]))
    else
        for _, text in ipairs(finished) do
            doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE,
                string.format(__L(cid, "Rank-up goal done: %s (%d of %d goals)."), text, trial.have, trial.need))
        end
    end
    Vocations.sendTrial(cid)
end

-- The trial count and whether the rank up is ready (the top bar button's "!"); at login and level ups.
-- Without a vocation, ready is whether the trainer can choose one (choose = true).
Vocations.sendTrial = function(cid)
    if (not isPlayer(cid)) then
        return
    end
    if (not Vocations.get(cid)) then
        send(cid, { type = "trial", choose = true, ready = getPlayerLevel(cid) >= Vocations.MIN_LEVEL })
        return
    end
    local trial = Vocations.getTrial(cid)
    if (trial) then
        send(cid, { type = "trial", have = trial.have, need = trial.need, goals = trial.goals, ready = Vocations.canRankUp(cid) })
    else
        send(cid, { type = "trial", ready = false })
    end
end

-- Puts the vocation's outfit on, keeping the trainer's colors
Vocations.wear = function(cid)
    local vocation = Vocations.get(cid)
    if (not vocation) then
        return false
    end
    Vocations.updateOutfit(cid)
    local outfit = getCreatureOutfit(cid)
    outfit.lookType = vocation.looks[getPlayerSex(cid) == PLAYERSEX_FEMALE and 1 or 2]
    outfit.lookAddons = 0
    doCreatureChangeOutfit(cid, outfit)
    return true
end

-- Ace Trainer's trial: wild Pokemon defeated outside duels and battles (onGainExperience)
Vocations.onDefeated = function(cid, target)
    if (not Vocations.inBattle(cid)) then
        Vocations.addTrial(cid, "ace", "defeat", isCreature(target) and getCreatureName(target) or nil)
    end
end

-- Ranger's trial: scans that find at least one Pokemon, and what they found
local function countScan(cid, found)
    if (#found.regular + #found.shiny + #found.legendary > 0) then
        Vocations.addTrial(cid, "ranger", "scan")
    end
    local seen = {}
    for _, list in ipairs({ found.regular, found.shiny }) do
        for _, entry in ipairs(list) do
            if (not seen[entry.name]) then
                seen[entry.name] = true
                Vocations.addTrial(cid, "ranger", "find", entry.name)
            end
        end
    end
end

-- The next rank, when the trainer's level and trial allow it (the window's Rank up button)
Vocations.rankUp = function(cid)
    local ok, why = Vocations.canRankUp(cid)
    if (not ok) then
        if (why) then
            doPlayerSendCancel(cid, why)
        end
        return false
    end
    local from = Vocations.getRank(cid)
    Vocations.setRank(cid, from + 1)
    Vocations.resetTrial(cid)
    doSendMagicEffect(getCreaturePosition(cid), EFFECT_FIREWORK_YELLOW)
    doPlayerSendTextMessage(cid, MESSAGE_EVENT_ADVANCE, string.format(__L(cid, "Congratulations! You are now %s!"),
        withArticle(__L(cid, Vocations.getTitle(cid)))))
    Vocations.sendRankBanner(cid, from, from + 1)
    return true
end

-- What the vocation window shows for each rank: { id, icon, text, value, num, lower } rows, only the
-- perks the rank has. num is compared between ranks for the "next rank" badges (lower: less is better).
local function percent(value)
    return math.floor(value * 100 + 0.5)
end

local PERK_ROWS = {
    ace = function(cid, rank, p)
        return {
            { id = "exp", icon = "exp", text = "Pokemon EXP from battles", value = "+" .. percent(p.battleExp[rank]) .. "%",
              num = percent(p.battleExp[rank]), unit = "%" },
        }
    end,
    catcher = function(cid, rank, p)
        return {
            { id = "catch", icon = "ball", text = "Catch chance", value = "+" .. percent(p.catchChance[rank]) .. "%",
              num = percent(p.catchChance[rank]), unit = "%" },
            { id = "back", icon = "back", text = "Ball back after a failed throw", value = percent(p.ballBack[rank]) .. "%",
              num = percent(p.ballBack[rank]), unit = "%" },
        }
    end,
    breeder = function(cid, rank, p)
        local minutes = math.floor(60 * (1 - p.hatchTime[rank]) + 0.5)
        return {
            { id = "hatch", icon = "egg", text = "Hatching an egg", value = string.format(__L(cid, "%d minutes"), minutes),
              num = minutes, unit = " min", lower = true },
            { id = "second", icon = "eggs", text = "Second daycare egg (Premium)", value = percent(p.secondEgg[rank]) .. "%",
              num = percent(p.secondEgg[rank]), unit = "%" },
            { id = "early", icon = "clock", text = "Daily early egg chance (Premium)", value = percent(p.earlyEgg[rank]) .. "%",
              num = percent(p.earlyEgg[rank]), unit = "%" },
        }
    end,
    ranger = function(cid, rank, p)
        local accuracy = p.accuracy[rank]
        local rows = {
            { id = "range", icon = "radar", text = "Radar range", value = string.format(__L(cid, "%d tiles"), p.range[rank]),
              num = p.range[rank], unit = "" },
            { id = "wait", icon = "clock", text = "Scan wait", value = string.format(__L(cid, "%d seconds"), p.cooldown[rank]),
              num = p.cooldown[rank], unit = " s", lower = true },
            { id = "accuracy", icon = "target", text = "Positions", num = accuracy, lower = true, badge = "Sharper",
              value = accuracy <= 1 and __L(cid, "Exact") or string.format(__L(cid, "Within %d tiles"), accuracy) },
        }
        local unlocks = {
            { p.typeFilterRank, "filter", "filter", "Filter by type" },
            { p.printsRank, "prints", "map", "Footprints of the Pokemon you track" },
            { p.speciesRank, "species", "compass", "Species, direction, distance" },
            { p.liveRank, "live", "target", "Blips follow the Pokemon live" },
            { p.shinyRank, "shiny", "star", "Shiny Pokemon show on the radar" },
            { p.legendaryRank, "legendary", "crown", "Legendaries and event Pokemon" },
        }
        for _, unlock in ipairs(unlocks) do
            if (rank >= unlock[1]) then
                rows[#rows + 1] = { id = unlock[2], icon = unlock[3], text = unlock[4], value = __L(cid, "On") }
            end
        end
        return rows
    end,
    angler = function(cid, rank, p)
        local rows = {
            { id = "skill", icon = "fish", text = "Fishing skill gain", value = "+" .. percent(p.fishingExp[rank]) .. "%",
              num = percent(p.fishingExp[rank]), unit = "%" },
        }
        local unlocks = {
            { p.spotInfoRank, "spot", "target", "See what can bite" },
            { p.fastBiteRank, "bite", "clock", "Faster first bite" },
            { p.mapRank, "guide", "map", "Fishing Guide" },
            { p.cranesRank, "cranes", "crane", "Cranes" },
        }
        for _, unlock in ipairs(unlocks) do
            if (rank >= unlock[1]) then
                rows[#rows + 1] = { id = unlock[2], icon = unlock[3], text = unlock[4], value = __L(cid, "On") }
            end
        end
        return rows
    end,
    medic = function(cid, rank, p)
        return {
            { id = "heal", icon = "heal", text = "Health potions", value = "+" .. percent(p.healing[rank]) .. "%",
              num = percent(p.healing[rank]), unit = "%" },
            { id = "others", icon = "heart", text = "Heal other trainers' Pokemon", value = __L(cid, "On") },
        }
    end,
}

local function perkRows(cid, vocation, rank)
    local rows = PERK_ROWS[vocation.key](cid, rank, Vocations.PERKS[vocation.key])
    for _, row in ipairs(rows) do
        row.text = __L(cid, row.text)
    end
    table.insert(rows, { id = "outfit", icon = "outfit", text = string.format(__L(cid, "%s outfit"), __L(cid, vocation.name)),
                         value = __L(cid, "Unlocked") })
    return rows
end

-- The rows that change from one rank to the next, each with a badge: the difference, or "New"
local function gains(cid, from, to)
    local before = {}
    for _, row in ipairs(from) do
        before[row.id] = row
    end
    local list = {}
    for _, row in ipairs(to) do
        local old = before[row.id]
        local gain = { icon = row.icon, text = row.text, value = row.value }
        if (not old) then
            gain.badge = __L(cid, "New")
        elseif (row.num and old.num and row.num ~= old.num) then
            local diff = row.num - old.num
            gain.badge = row.badge and __L(cid, row.badge) or
                ((diff > 0 and "+" or "-") .. math.abs(diff) .. (row.unit or ""))
        end
        if (gain.badge) then
            list[#list + 1] = gain
        end
    end
    return list
end

-- The rank-up banner (game_levelup, LevelUpBanner.sendRank): the new title and what the rank improved
Vocations.sendRankBanner = function(cid, from, to)
    local vocation = Vocations.get(cid)
    if (not vocation or not LevelUpBanner) then
        return
    end
    LevelUpBanner.sendRank(cid, {
        key = vocation.key,
        name = __L(cid, vocation.name),
        title = __L(cid, vocation.titles[to]),
        from = from,
        to = to,
        maxRank = Vocations.MAX_RANK,
        gains = JSON.array(gains(cid, perkRows(cid, vocation, from), perkRows(cid, vocation, to)))
    })
end

-- The progress window for a trainer with a vocation (U, or the top bar button)
Vocations.progress = function(cid)
    local vocation = Vocations.get(cid)
    local rank = Vocations.getRank(cid)
    local ranks, titles = {}, {}
    for r = 1, Vocations.MAX_RANK do
        ranks[r] = perkRows(cid, vocation, r)
        titles[r] = __L(cid, vocation.titles[r])
    end
    local data = { type = "progress", key = vocation.key, name = __L(cid, vocation.name),
                   tagline = __L(cid, vocation.tagline), rank = rank, maxRank = Vocations.MAX_RANK,
                   title = titles[rank], titles = titles, levels = Vocations.RANK_LEVELS, level = getPlayerLevel(cid),
                   since = math.max(0, getPlayerStorageValue(cid, SINCE)), perks = ranks[rank], ranks = ranks,
                   look = vocation.looks[getPlayerSex(cid) == PLAYERSEX_FEMALE and 1 or 2],
                   wearing = byLook[getCreatureOutfit(cid).lookType] == vocation }
    if (rank < Vocations.MAX_RANK) then
        local ready, why = Vocations.canRankUp(cid)
        data.next = { rank = rank + 1, title = titles[rank + 1], level = Vocations.RANK_LEVELS[rank + 1],
                      trial = Vocations.getTrial(cid), gains = JSON.array(gains(cid, ranks[rank], ranks[rank + 1])),
                      ready = ready, why = why }
    end
    return data
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
    if (chosen) then
        setPlayerStorageValue(cid, WINDOW, -1)
        send(cid, Vocations.progress(cid))
        return true
    end
    setPlayerStorageValue(cid, WINDOW, 1)
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
        return result(cid, false, "Press V to open the vocation window.")
    end
    if (getPlayerLevel(cid) < Vocations.MIN_LEVEL) then
        return result(cid, false, string.format(__L(cid, "You need trainer level %d to choose a vocation."),
            Vocations.MIN_LEVEL))
    end
    setPlayerStorageValue(cid, WINDOW, -1)
    setPlayerStorageValue(cid, STORAGE, vocation.id)
    setPlayerStorageValue(cid, SINCE, os.time())
    Vocations.resetTrial(cid)
    Vocations.setRank(cid, 1)
    Vocations.wear(cid)
    doSendMagicEffect(getCreaturePosition(cid), EFFECT_FIREWORK_YELLOW)
    doPlayerSendTextMessage(cid, MESSAGE_EVENT_ADVANCE,
        string.format(__L(cid, "You are now %s!"), withArticle(__L(cid, vocation.name))))
    reply(cid, string.format(__L(cid, "You are now wearing the %s outfit. You can change it in the outfit window."),
        __L(cid, vocation.name)))
    send(cid, { type = "chosen", key = vocation.key, name = __L(cid, vocation.name), rank = 1,
                title = __L(cid, vocation.titles[1]) })
    send(cid, Vocations.progress(cid))
    Vocations.sendTrial(cid)
    return true
end

Vocations.reset = function(cid)
    setPlayerStorageValue(cid, STORAGE, -1)
    setPlayerStorageValue(cid, RANK, -1)
    setPlayerStorageValue(cid, WINDOW, -1)
    Vocations.resetTrial(cid)
    setPlayerStorageValue(cid, SINCE, -1)
    Vocations.updateDescription(cid)
    Vocations.sendRadarStatus(cid)
    Fishing.sendStatus(cid)
    Vocations.updateOutfit(cid)
    Vocations.sendTrial(cid)
end

-- Gives the vocation its outfit, and takes a vocation outfit off a trainer who can't wear it (another
-- vocation, or none). The outfits.xml storage check already keeps it out of the outfit window.
Vocations.updateOutfit = function(cid)
    local vocation = Vocations.get(cid)
    if (vocation and not canPlayerWearOutfitId(cid, vocation.outfit, 0)) then
        doPlayerAddOutfitId(cid, vocation.outfit, 0)
    end
    local outfit = getCreatureOutfit(cid)
    local owner = byLook[outfit.lookType]
    if (owner and owner ~= vocation) then
        outfit.lookType = getPlayerSex(cid) == PLAYERSEX_FEMALE and 611 or 612 -- Trainer
        outfit.lookAddons = 0
        doCreatureChangeOutfit(cid, outfit)
    end
end

-- Outfits that were quest and shop rewards before they became vocation outfits; who earned one gets
-- the outfit that replaced it as the reward
local REPLACED_OUTFITS = {
    { outfit = 40, vocation = "ace", replacement = 83, name = "Master Trainer", replacementName = "Voyager" },
    { outfit = 49, vocation = "ranger", replacement = 84, name = "Ranger", replacementName = "Wanderer" },
    { outfit = 37, vocation = "catcher", replacement = 85, name = "Catcher", replacementName = "Duelist" },
}

Vocations.migrateOutfits = function(cid)
    if (getPlayerStorageValue(cid, OUTFITS_MIGRATED) == 1) then
        return
    end
    setPlayerStorageValue(cid, OUTFITS_MIGRATED, 1)
    local own = getPlayerStorageValue(cid, STORAGE)
    for _, replaced in ipairs(REPLACED_OUTFITS) do
        local id = byKey[replaced.vocation].id
        -- the wear check needs the outfit's vocation in the storage, so it only tells whether it was earned
        setPlayerStorageValue(cid, STORAGE, id)
        local earned = canPlayerWearOutfitId(cid, replaced.outfit, 0)
        setPlayerStorageValue(cid, STORAGE, own)
        if (earned and own ~= id) then
            doPlayerAddOutfitId(cid, replaced.replacement, 0)
            reply(cid, string.format(__L(cid, "The %s outfit now belongs to a vocation. You got the %s outfit instead."),
                __L(cid, replaced.name), __L(cid, replaced.replacementName)))
        end
    end
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
    local seesDisguise = Vocations.is(cid, "ranger") and Vocations.getRank(cid) >= WildLegendaries.CONFIG.revealRank
    for _, creature in ipairs(getSpectators(pos, range, range, false) or {}) do
        if (isMonster(creature) and not isSummon(creature)) then
            local name = getCreatureName(creature)
            -- a Ranger's radar picks Mew out of its disguise
            local unmasked = seesDisguise and WildLegendaries.isDisguised(creature)
            if (unmasked) then
                WildLegendaries.requestReveal(creature, getCreatureName(cid))
                name = "Mew"
            end
            if (isPokemon(name) and (not typeId or hasType(name, typeId))) then
                local where = getCreaturePosition(creature)
                local entry = { cid = creature, name = name, pos = where, distance = getDistanceBetween(pos, where),
                                direction = direction(pos, where) }
                if (unmasked or DiscordBridge.isLegendary(name) or isSpecial(name)) then
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
             unlocks = { type = perks.typeFilterRank, prints = perks.printsRank, species = perks.speciesRank,
                         rarity = perks.speciesRank,
                         shiny = perks.shinyRank, legendary = perks.legendaryRank } }
end

local SPREAD_RINGS = 4 -- the rings drawn on the radar

-- The nearest-first list reordered so the blips cap keeps Pokemon in every ring and direction: one
-- from each ring and direction in turn, nearest first, instead of only the closest crowd
local function spread(list, range)
    local buckets, order = {}, {}
    for _, entry in ipairs(list) do
        local ring = math.min(SPREAD_RINGS, math.floor(entry.distance * SPREAD_RINGS / math.max(1, range)) + 1)
        local key = ring .. ":" .. entry.direction
        if (not buckets[key]) then
            buckets[key] = {}
            order[#order + 1] = key
        end
        table.insert(buckets[key], entry)
    end
    local out, round = {}, 1
    while (#out < #list) do
        for _, key in ipairs(order) do
            local entry = buckets[key][round]
            if (entry) then
                out[#out + 1] = entry
            end
        end
        round = round + 1
    end
    return out
end

-- One scan for the popup (the recharge already started): the state plus center and blips
Vocations.radarScan = function(cid)
    local rank = rangerRank(cid)
    local perks = Vocations.PERKS.ranger
    local range = perks.range[rank]
    local center = getCreaturePosition(cid)
    local found = Vocations.scan(cid, range)
    countScan(cid, found)
    local blips = {}
    local function add(list, kindOf)
        for _, entry in ipairs(list) do
            if (#blips >= MAX_BLIPS) then
                return
            end
            blips[#blips + 1] = blip(center, entry, kindOf(entry), rank, range)
        end
    end
    -- the rare finds first, so the cap only drops regular Pokemon
    if (legendaryReady(cid, rank, found)) then
        add(found.legendary, function() return "legendary" end)
    end
    if (rank >= perks.shinyRank) then
        add(found.shiny, function() return "shiny" end)
    end
    local total = #blips + #found.regular
    add(spread(found.regular, range), function(entry)
        return rank >= perks.speciesRank and rarity(entry.name) or "unknown"
    end)
    local data = Vocations.radarState(cid)
    data.type = "scan"
    data.center = { x = center.x, y = center.y, z = center.z }
    data.total = total
    data.live = rank >= perks.liveRank or nil
    -- long names and types can still pass the engine's string limit with MAX_BLIPS blips
    JSON.encodeWithin(data, "blips", blips)
    return data
end

local function sendRadar(cid, data)
    doSendPlayerExtendedOpcode(cid, EXTENDED_IDS.RADAR, JSON.encode(data))
end

-- What the radar picks up of the wild legendaries out in the region, by rank (WildLegendaries.radarHints)
local function sendLegendaryHints(cid, rank)
    for _, line in ipairs(WildLegendaries.radarHints(cid, rank)) do
        reply(cid, "Radar: " .. line)
    end
end

-- The live view: per trainer the last scan's exact blips, where they were last sent and until when.
-- Each update only reads those Pokemon's positions, no new search of the area.
local live = {}

-- Sends where the live blips went; false once the live view is over or paused
Vocations.radarLiveUpdate = function(cid)
    local state = live[cid]
    if (not state) then
        return false
    end
    if (not isPlayer(cid) or os.time() >= state.untilTime) then
        live[cid] = nil
        return false
    end
    if (not state.on) then
        return false
    end
    local moved, gone = {}, {}
    for id, last in pairs(state.blips) do
        local pos = isCreature(id) and getCreaturePosition(id)
        if (not pos) then
            gone[#gone + 1] = id
            state.blips[id] = nil
        elseif (pos.x ~= last.x or pos.y ~= last.y or pos.z ~= last.z) then
            moved[#moved + 1] = { id = id, x = pos.x, y = pos.y, z = pos.z }
            state.blips[id] = { x = pos.x, y = pos.y, z = pos.z }
        end
    end
    if (#moved > 0 or #gone > 0) then
        local data = { type = "live", gone = JSON.array(gone) }
        JSON.encodeWithin(data, "blips", moved)
        sendRadar(cid, data)
    end
    return true
end

local function liveTick(cid)
    local state = live[cid]
    if (state) then
        state.event = nil
        if (Vocations.radarLiveUpdate(cid) and live[cid] == state) then
            state.event = addEvent(liveTick, Vocations.PERKS.ranger.liveMs, cid)
        end
    end
end

local function startLive(cid)
    local state = live[cid]
    if (state and state.on and not state.event and os.time() < state.untilTime) then
        state.event = addEvent(liveTick, Vocations.PERKS.ranger.liveMs, cid)
    end
end

local function trackLive(cid, rank, blips)
    local state = live[cid]
    if (state and state.event) then
        stopEvent(state.event)
    end
    live[cid] = nil
    if (rank < Vocations.PERKS.ranger.liveRank) then
        return
    end
    state = { blips = {}, on = true, untilTime = os.time() + Vocations.PERKS.ranger.liveSeconds }
    local count = 0
    for _, b in ipairs(blips) do
        if (b.exact and b.id) then
            state.blips[b.id] = { x = b.x, y = b.y, z = b.z }
            count = count + 1
            -- wild Pokemon with no trainer in view stand still, so the blips would never move
            if (doMonsterKeepAwake) then
                doMonsterKeepAwake(b.id, Vocations.PERKS.ranger.liveSeconds * 1000)
            end
        end
    end
    if (count > 0) then
        live[cid] = state
        startLive(cid)
    end
end

Vocations.setRadarLive = function(cid, on)
    local state = live[cid]
    if (state) then
        state.on = on and true or false
        startLive(cid)
    end
end

-- Footprint tracking. The Ranger's storage names the Pokemon and until when, and the Pokemon's storage
-- lists its trackers, so the footprints movement script (its own Lua state) can find them.
local TRACK = playersStorages.vocationTrack
-- Both are strings that start with a letter: the engine reads one starting with a digit as a number.
local TRACKERS = 9190 -- creature storage of a tracked wild Pokemon: "p<pid>:<until>;..."
local TRACK_SLACK = 10 -- tiles it may have moved since the scan

local function readTrackers(mon)
    local list = {}
    local value = getCreatureStorage(mon, TRACKERS)
    if (type(value) == "string") then
        for pid, untilTime in value:gmatch("p(%d+):(%d+)") do
            list[#list + 1] = { pid = tonumber(pid), untilTime = tonumber(untilTime) }
        end
    end
    return list
end

local function writeTrackers(mon, list)
    local parts = {}
    for _, t in ipairs(list) do
        parts[#parts + 1] = "p" .. t.pid .. ":" .. t.untilTime
    end
    doCreatureSetStorage(mon, TRACKERS, #parts > 0 and table.concat(parts, ";") or -1)
end

-- The Pokemon a Ranger follows by its footprints and until when, or nil
Vocations.trackedPrints = function(cid)
    local id, untilTime = tostring(getPlayerStorageValue(cid, TRACK)):match("^m(%d+):(%d+)$")
    if (id and tonumber(untilTime) > os.time()) then
        return tonumber(id), tonumber(untilTime)
    end
    return nil
end

-- The Rangers still following this Pokemon's footprints
Vocations.printTrackers = function(mon)
    local now, out, keep = os.time(), {}, {}
    local list = readTrackers(mon)
    for _, t in ipairs(list) do
        if (t.untilTime > now and isPlayer(t.pid) and Vocations.trackedPrints(t.pid) == mon) then
            out[#out + 1] = t.pid
            keep[#keep + 1] = t
        end
    end
    if (#keep ~= #list) then
        writeTrackers(mon, keep)
    end
    return out
end

-- A blip picked in the popup: follow that wild Pokemon's footprints (no id: stop). Shinies and
-- legendaries stay vague, so they can't be tracked. Returns true or false and why.
Vocations.trackPrints = function(cid, id)
    local old = Vocations.trackedPrints(cid)
    setPlayerStorageValue(cid, TRACK, -1)
    if (old and isCreature(old)) then
        local keep = {}
        for _, t in ipairs(readTrackers(old)) do
            if (t.pid ~= cid) then
                keep[#keep + 1] = t
            end
        end
        writeTrackers(old, keep)
    end
    id = tonumber(id)
    if (not id) then
        if (old) then
            sendRadar(cid, { type = "track" })
        end
        return true
    end
    local rank = rangerRank(cid)
    local perks = Vocations.PERKS.ranger
    if (rank < perks.printsRank) then
        return false, "rank"
    end
    if (not isMonster(id) or isSummon(id) or isPokemonOfPlayer(id) or isPokemonOfNpc(id)) then
        return false, "gone"
    end
    local name = getCreatureName(id)
    if (not isPokemon(name) or DiscordBridge.isLegendary(name) or isSpecial(name) or isShinyName(name)
            or WildLegendaries.isDisguised(id)) then
        return false, "vague"
    end
    local pos, mine = getCreaturePosition(id), getCreaturePosition(cid)
    if (pos.z ~= mine.z or getDistanceBetween(pos, mine) > perks.range[rank] + TRACK_SLACK) then
        return false, "far"
    end
    local untilTime = os.time() + perks.printsSeconds
    setPlayerStorageValue(cid, TRACK, "m" .. id .. ":" .. untilTime)
    local list = {}
    for _, t in ipairs(readTrackers(id)) do
        if (t.pid ~= cid and t.untilTime > os.time()) then
            list[#list + 1] = t
        end
    end
    list[#list + 1] = { pid = cid, untilTime = untilTime }
    writeTrackers(id, list)
    if (doMonsterKeepAwake) then
        doMonsterKeepAwake(id, perks.printsSeconds * 1000)
    end
    sendRadar(cid, { type = "track", id = id, seconds = perks.printsSeconds })
    return true
end

-- A step of a wild Pokemon on soft ground (events/movements/traces.lua): its trackers see the print
Vocations.sendPrint = function(mon, pos, way)
    local trackers = Vocations.printTrackers(mon)
    if (#trackers == 0) then
        return 0
    end
    local data = JSON.encode({ type = "print", id = mon, x = pos.x, y = pos.y, z = pos.z, way = way })
    for _, pid in ipairs(trackers) do
        doSendPlayerExtendedOpcode(pid, EXTENDED_IDS.RADAR, data)
    end
    return #trackers
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
    local data = Vocations.radarScan(cid)
    sendRadar(cid, data)
    trackLive(cid, rank, data.blips or {})
    sendLegendaryHints(cid, rank)
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
    countScan(cid, found)
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
    sendLegendaryHints(cid, rank)
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
    elseif (action == "live") then
        Vocations.setRadarLive(cid, data.on == true)
    elseif (action == "track") then
        Vocations.trackPrints(cid, data.id)
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
    elseif (action == "rankup") then
        local ok, why = Vocations.canRankUp(cid)
        if (ok and Vocations.rankUp(cid)) then
            send(cid, Vocations.progress(cid))
        else
            result(cid, false, why or "You can't rank up now.")
        end
    elseif (action == "wear") then
        if (Vocations.wear(cid)) then
            send(cid, Vocations.progress(cid))
        end
    end
end

Vocations.onLogin = function(cid)
    setPlayerStorageValue(cid, WINDOW, -1)
    if (Vocations.get(cid) and getPlayerStorageValue(cid, SINCE) <= 0) then
        setPlayerStorageValue(cid, SINCE, os.time())
    end
    Vocations.migrateOutfits(cid)
    Vocations.updateOutfit(cid)
    Vocations.updateDescription(cid)
    Vocations.sendRadarStatus(cid)
    Fishing.sendStatus(cid)
    Vocations.sendTrial(cid)
end

Vocations.onLogout = function(cid)
    setPlayerStorageValue(cid, WINDOW, -1)
end
