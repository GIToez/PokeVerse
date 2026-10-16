-- Vocations (docs/upcoming-features.md, section 6): from trainer level 20 a trainer picks one of
-- six vocations, once and for good, and starts at rank 1. Ranks 2 to 5 need a trainer level
-- (Vocations.RANK_LEVELS) and are given by the vocation quests and tasks (Vocations.rankUp).
-- Perks never touch Pokemon damage or stats and never work in duels, the PvP arena or NPC battles.
--
-- The client's vocation window (game_vocation) talks JSON on EXTENDED_IDS.VOCATION:
--   server -> client  {type = "open", level, minLevel, chosen, rank, title, vocations = {{key, name, tagline, perks}, ...}}
--                     {type = "chosen", key, name, rank, title}
--                     {type = "trial", have, need, ready} (the top bar button's "!"; without a vocation
--                      {type = "trial", choose = true, ready} where ready means level 20 is reached)
--                     {type = "result", ok, text}
--   client -> server  {action = "open"} (the U key), {action = "choose", key}, {action = "close"}
-- A choice is only accepted while a window opened by Vocations.open is up. For now every trainer can
-- open it with U; below Vocations.MIN_LEVEL it opens with the choice locked.
--
-- The Ranger radar popup (game_radar) talks JSON on EXTENDED_IDS.RADAR:
--   server -> client  {type = "status", enabled, rank, title, range, cooldown, wait, legendaryWait, unlocks, open}
--                     {type = "scan", ...the status fields, center = {x, y, z}, live, blips = {{id, x, y, z, kind, exact,
--                      distance, direction, band, name, look, types}, ...}}
--                     {type = "error", text, wait}
--                     {type = "live", blips = {{id, x, y, z}}, gone = {ids}}: from liveRank, every liveMs for
--                      liveSeconds after a scan, the exact blips that moved and the ones that are gone
--   client -> server  {action = "hello"}, {action = "scan"}, {action = "live", on}: whether the popup
--                     wants the live updates (it is open, or tracking a target)
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
-- about. goals[r] is the count that takes rank r to rank r + 1; the count starts again at each rank.
Vocations.TRIALS = {
    ace = { text = "Defeat %d wild Pokemon", goals = { 200, 500, 1000, 2000 } },
    catcher = { text = "Catch %d Pokemon", goals = { 20, 50, 100, 200 } },
    breeder = { text = "Hatch %d eggs", goals = { 3, 6, 10, 15 } },
    ranger = { text = "Find wild Pokemon with %d radar scans", goals = { 30, 60, 100, 150 } },
    angler = { text = "Hook %d Pokemon while fishing", goals = { 50, 100, 200, 400 } },
    medic = { text = "Heal %d Pokemon with potions", goals = { 50, 100, 200, 400 } },
}

-- { text, have, need } for the trainer's next rank, nil without a vocation or at the top rank
Vocations.getTrial = function(cid)
    local vocation = Vocations.get(cid)
    local rank = Vocations.getRank(cid)
    if (not vocation or rank >= Vocations.MAX_RANK) then
        return nil
    end
    local trial = Vocations.TRIALS[vocation.key]
    local need = trial.goals[rank]
    return { text = string.format(__L(cid, trial.text), need), need = need,
             have = math.min(need, math.max(0, getPlayerStorageValue(cid, TRIAL))) }
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
    if (trial.have < trial.need) then
        return false, string.format(__L(cid, "Finish your rank-up trial first: %s (%d/%d)."), trial.text, trial.have, trial.need)
    end
    return true
end

-- Counts one step of the trial; called where the vocation's perks are used. Tells the trainer once
-- the trial is done.
Vocations.addTrial = function(cid, key, amount)
    if (not isPlayer(cid) or not Vocations.is(cid, key)) then
        return
    end
    local trial = Vocations.getTrial(cid)
    if (not trial or trial.have >= trial.need) then
        return
    end
    local have = math.min(trial.need, trial.have + (amount or 1))
    setPlayerStorageValue(cid, TRIAL, have)
    if (have >= trial.need) then
        local ready = Vocations.canRankUp(cid)
        doPlayerSendTextMessage(cid, MESSAGE_EVENT_ADVANCE, ready and
            __L(cid, "Rank-up trial done! Open the vocation window to rank up.") or
            string.format(__L(cid, "Rank-up trial done! You can rank up at trainer level %d."),
                Vocations.RANK_LEVELS[Vocations.getRank(cid) + 1]))
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
        send(cid, { type = "trial", have = trial.have, need = trial.need, ready = Vocations.canRankUp(cid) })
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
Vocations.onDefeated = function(cid)
    if (not Vocations.inBattle(cid)) then
        Vocations.addTrial(cid, "ace")
    end
end

-- Ranger's trial: scans that find at least one Pokemon
local function countScan(cid, found)
    if (#found.regular + #found.shiny + #found.legendary > 0) then
        Vocations.addTrial(cid, "ranger")
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
    Vocations.setRank(cid, Vocations.getRank(cid) + 1)
    setPlayerStorageValue(cid, TRIAL, 0)
    doSendMagicEffect(getCreaturePosition(cid), EFFECT_FIREWORK_YELLOW)
    doPlayerSendTextMessage(cid, MESSAGE_EVENT_ADVANCE, string.format(__L(cid, "You are now %s!"),
        withArticle(__L(cid, Vocations.getTitle(cid)))))
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
        return result(cid, false, "Press U to open the vocation window.")
    end
    if (getPlayerLevel(cid) < Vocations.MIN_LEVEL) then
        return result(cid, false, string.format(__L(cid, "You need trainer level %d to choose a vocation."),
            Vocations.MIN_LEVEL))
    end
    setPlayerStorageValue(cid, WINDOW, -1)
    setPlayerStorageValue(cid, STORAGE, vocation.id)
    setPlayerStorageValue(cid, SINCE, os.time())
    setPlayerStorageValue(cid, TRIAL, 0)
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
    setPlayerStorageValue(cid, TRIAL, -1)
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
    data.live = rank >= perks.liveRank or nil
    -- long names and types can still pass the engine's string limit with MAX_BLIPS blips
    JSON.encodeWithin(data, "blips", blips)
    return data
end

local function sendRadar(cid, data)
    doSendPlayerExtendedOpcode(cid, EXTENDED_IDS.RADAR, JSON.encode(data))
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
