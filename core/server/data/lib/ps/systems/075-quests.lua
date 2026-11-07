-- Quest log, quest notices and the NPCs' quest marks for the modern client (EXTENDED_IDS.QUEST).
-- The quests are the NPCs' lists in 002-quest.lua; their names and descriptions come from
-- XML/quests.xml. The client says hello at login (playersStorages.questClient); a client that never
-- does keeps the old chat lines for quest progress.
--
-- Client -> server: { action = "hello" }, { action = "list" }
-- Server -> client:
--   { type = "list", quests = { row, ... } }: what the trainer has started, can start now ("available",
--     or "later" from a higher level), and has done. A row: id (the quest's storage), name, step
--     ("Part 2 of 3"), group, category, npc, state, text, objective, have, need, level, exp, rewards,
--     daily, place ({ x, y, z, town } of the NPC).
--   { type = "active", quests = { row, ... } }: only the started ones, after the hello
--   { type = "notice", kind = "started" | "progress" | "ready" | "complete", ... }
--   { type = "marks", npcs = { [npc name] = "available" | "active" | "ready" } }
--   { type = "found", npc }: the trainer met a quest NPC, so its quests are no longer "???" in the log.
--     An undiscovered row is { id, hidden = true, state, category, level, daily, place = { town } }.

Quests = {}

local CLIENT = playersStorages.questClient
local QUESTS_XML = "data/XML/quests.xml"

-- the values of QUEST_TYPE and REWARD_TYPE in 002-quest.lua
local BRING_ITEMS, BRING_POKEMON, DEX_POKEMONS, DEFEAT_POKEMON, CATCH_POKEMON = 0, 1, 2, 3, 4
local REWARD_ITEM, REWARD_POKEMON, REWARD_ADDON = 1, 2, 3
-- a daily quest keeps the time it was done, and a new one can start after the next server restart
local DAILY_DONE = 100000
local MISSING_RETRY = 600 -- an NPC that isn't on the map (events, script-placed NPCs) is looked for again after this

Quests.CATEGORIES = { "Main story", "Gyms", "Getting started", "Side quests", "Daily", "Addons", "Events" }

local EVENT_WORDS = { "easter", "grinch", "christmas", "halloween", "santa", "anniversary", "birthday" }
local START_WORDS = { "tutorial", "beginner", "professor oak" }
-- the old Tutorial Island chain, replaced by Professor Oak's first lessons: kept out of the quest log and its marks
Quests.RETIRED_NPCS = { ["Flanagan"] = true, ["Gosse"] = true, ["Shelley"] = true }

local FRAGMENT_SIZE = 3500
local fragmentId = math.random(1, 900000)

-- AddString drops strings over 8 KB: longer messages go as "#id:index:count:" fragments
local function send(cid, data)
    local text = JSON.encode(data)
    if (#text <= FRAGMENT_SIZE) then
        doSendPlayerExtendedOpcode(cid, EXTENDED_IDS.QUEST, text)
        return
    end
    fragmentId = fragmentId % 1000000 + 1
    local count = math.ceil(#text / FRAGMENT_SIZE)
    for index = 1, count do
        doSendPlayerExtendedOpcode(cid, EXTENDED_IDS.QUEST, string.format("#%d:%d:%d:", fragmentId, index, count)
            .. text:sub((index - 1) * FRAGMENT_SIZE + 1, index * FRAGMENT_SIZE))
    end
end

Quests.isClient = function(cid)
    return isPlayer(cid) and getPlayerStorageValue(cid, CLIENT) == 1
end

---------------------------------------------------------------------------------------------------
-- Names (XML/quests.xml)
---------------------------------------------------------------------------------------------------

local ENTITIES = { quot = '"', amp = "&", lt = "<", gt = ">", apos = "'" }

-- the NPCs' {keywords} braces mean nothing outside the chat
local function unescape(text)
    return (text:gsub("&(%a+);", function(name) return ENTITIES[name] end):gsub("[{}]", ""))
end

local names -- storage -> { group = { name, missions }, mission, step, text }

local function getNames()
    if (names) then
        return names
    end
    names = {}
    local file = io.open(QUESTS_XML, "r")
    if (not file) then
        log(LOG_TYPES.ERROR, "Quests - Can't read " .. QUESTS_XML)
        return names
    end
    local group, last
    for line in file:lines() do
        local questName = line:match('<quest [^>]*name="([^"]*)"')
        if (questName) then
            group, last = { name = unescape(questName), missions = {} }, nil
        end
        local mission = line:match("<mission [^>]*>")
        if (mission and group) then
            local storage = tonumber(mission:match('storageid="(%d+)"'))
            local entry = { group = group, mission = unescape(mission:match('name="([^"]*)"') or "") }
            group.missions[#group.missions + 1] = entry
            entry.step = #group.missions
            if (storage and not names[storage]) then
                names[storage] = entry
            end
            last = entry
        end
        local text = line:match('<missionstate [^>]*description="([^"]*)"')
        if (text and last and not last.text) then
            last.text = unescape(text)
        end
    end
    file:close()
    return names
end

---------------------------------------------------------------------------------------------------
-- The catalog: every NPC quest, in a stable order
---------------------------------------------------------------------------------------------------

local catalog, byStorage, retired

local function containsAny(text, words)
    text = text:lower()
    for _, word in ipairs(words) do
        if (text:find(word, 1, true)) then
            return true
        end
    end
    return false
end

-- NPCs that are only out while their holiday runs (HalloweenEvent.NPCS, AnniversaryEvent.NPCS)
local function isHolidayNpc(npcName)
    for _, list in ipairs({ HalloweenEvent and HalloweenEvent.NPCS, AnniversaryEvent and AnniversaryEvent.NPCS }) do
        for _, name in ipairs(list or {}) do
            if (name == npcName) then
                return true
            end
        end
    end
    return false
end

local function categoryOf(group, npcName, quest)
    if (quest.category) then
        return quest.category
    elseif (quest.daily) then
        return "Daily"
    end
    local text = (group or "") .. " " .. npcName
    if (containsAny(text, EVENT_WORDS) or isHolidayNpc(npcName)) then
        return "Events"
    elseif (containsAny(group or "", { "main" })) then
        return "Main story"
    elseif (containsAny(group or "", { "gym" })) then
        return "Gyms"
    elseif (containsAny(group or "", { "addon" })) then
        return "Addons"
    elseif (containsAny(text, START_WORDS)) then
        return "Getting started"
    end
    return "Side quests"
end

local function describe(entry, npcQuests)
    local info = getNames()[entry.id]
    local quest = entry.quest
    if (info) then
        local missions = info.group.missions
        -- later chapters name each part after the NPC that gives it: those take the chapter's name
        if (info.mission == "" or info.mission == entry.npc or getNpcQuests(info.mission)) then
            entry.name = info.group.name
            if (#missions > 1) then
                entry.step = string.format("Part %d of %d", info.step, #missions)
            end
        else
            entry.name = info.mission
        end
        entry.group = info.group.name
        entry.text = info.text
    else
        entry.name = #npcQuests > 1 and string.format("%s's request #%d", entry.npc, entry.index) or
                string.format("%s's request", entry.npc)
    end
    entry.category = categoryOf(entry.group, entry.npc, quest)
end

local function getCatalog()
    if (catalog) then
        return catalog
    end
    catalog, byStorage = {}, {}
    local all = getAllNpcQuests()
    local npcNames = {}
    retired = {}
    for npcName in pairs(all) do
        if (Quests.RETIRED_NPCS[npcName]) then
            for _, quest in ipairs(all[npcName]) do
                if (quest.storage) then
                    retired[quest.storage] = true
                end
            end
        else
            npcNames[#npcNames + 1] = npcName
        end
    end
    table.sort(npcNames)
    for _, npcName in ipairs(npcNames) do
        for index, quest in ipairs(all[npcName]) do
            if (quest.storage and not byStorage[quest.storage]) then
                local entry = { id = quest.storage, npc = npcName, index = index, quest = quest }
                describe(entry, all[npcName])
                catalog[#catalog + 1] = entry
                byStorage[quest.storage] = entry
            end
        end
    end
    return catalog
end

Quests.getEntry = function(storage)
    getCatalog()
    return byStorage[storage]
end

Quests.isRetired = function(quest)
    getCatalog()
    return quest ~= nil and quest.storage ~= nil and retired[quest.storage] == true
end

---------------------------------------------------------------------------------------------------
-- What a quest asks, how far the trainer is, what it gives
---------------------------------------------------------------------------------------------------

local function itemName(id, count)
    local name = getItemNameById(id) or "item"
    if (count > 1) then
        local plural = getItemPluralNameById(id)
        name = (plural and plural ~= "") and plural or name
    end
    return name
end

Quests.objective = function(quest)
    local request = quest.questRequest
    if (quest.objective) then
        return quest.objective
    elseif (quest.questType == BRING_ITEMS) then
        local list = {}
        for i = 1, #request, 2 do
            list[#list + 1] = request[i + 1] .. " " .. itemName(request[i], request[i + 1])
        end
        return "Bring " .. table.concat(list, ", ")
    elseif (quest.questType == BRING_POKEMON) then
        return "Bring a " .. tostring(request)
    elseif (quest.questType == DEX_POKEMONS) then
        return string.format("Register %d Pokemon in your Pokedex", request)
    elseif (quest.questType == DEFEAT_POKEMON) then
        return string.format("Defeat %d %s", request[2], request[1])
    elseif (quest.questType == CATCH_POKEMON) then
        return string.format("Catch %d %s", request[2], request[1])
    end
    return nil
end

-- have, need; nil for the custom quests, whose checks only the NPC knows, unless they give progress(cid)
Quests.progress = function(cid, quest)
    local request = quest.questRequest
    if (quest.progress) then
        return quest.progress(cid)
    elseif (quest.steps) then -- the quest's own steps (not the found ones: those only lead the way)
        local done = 0
        for _, step in ipairs(quest.steps) do
            if (tonumber(getCreatureStorage(cid, step.storage)) == QUEST_STATUS.FINISHED) then
                done = done + 1
            end
        end
        return done, #quest.steps
    elseif (quest.questType == BRING_ITEMS) then
        local have, need = 0, 0
        for i = 1, #request, 2 do
            need = need + request[i + 1]
            have = have + math.min(getPlayerItemCount(cid, request[i]), request[i + 1])
        end
        return have, need
    elseif (quest.questType == BRING_POKEMON) then
        for _, ball in ipairs(getPlayerAllBallsWithPokemon(cid)) do
            if (getBallPokemonName(ball.uid) == request) then
                return 1, 1
            end
        end
        return 0, 1
    elseif (quest.questType == DEX_POKEMONS) then
        return math.min(getPlayerTotalDexedPokemons(cid), request), request
    elseif (quest.questType == DEFEAT_POKEMON or quest.questType == CATCH_POKEMON) then
        local count = math.max(0, tonumber(getCreatureStorage(cid, quest.counterStorage)) or 0)
        return math.min(count, request[2]), request[2]
    end
    return nil, nil
end

local function rewardsOf(quest)
    local list = {}
    for _, reward in ipairs(quest.rewardItems or {}) do
        if (reward.type == REWARD_ITEM) then
            local info = getItemInfo(reward.id)
            local count = reward.count or 1
            list[#list + 1] = { kind = "item", client = info and info.clientId or 0, count = count,
                                name = itemName(reward.id, count) }
        elseif (reward.type == REWARD_POKEMON) then
            list[#list + 1] = { kind = "pokemon", name = reward.name, level = reward.level,
                                number = getPokemonNumberByName(reward.name) }
        elseif (reward.type == REWARD_ADDON) then
            list[#list + 1] = { kind = "outfit", name = "New outfit" }
        end
    end
    return list
end

---------------------------------------------------------------------------------------------------
-- Where the NPCs stand
---------------------------------------------------------------------------------------------------

local towns -- { { name, pos } }

local function nearestTown(x, y)
    if (not towns) then
        towns = {}
        for id = 1, 200 do
            local name = getTownName(id)
            if (name and name ~= "") then
                towns[#towns + 1] = { name = name, pos = getTownTemplePosition(id) }
            end
        end
    end
    local best, bestDistance
    for _, town in ipairs(towns) do
        local pos = town.pos
        if (pos and pos.x and pos.x > 0) then
            local distance = math.max(math.abs(pos.x - x), math.abs(pos.y - y))
            if (not bestDistance or distance < bestDistance) then
                best, bestDistance = town.name, distance
            end
        end
    end
    return best or ""
end

local places = {} -- npc name -> { x, y, z, town } or { missing = time }

Quests.placeOf = function(npcName)
    local place = places[npcName]
    if (not place or (place.missing and os.time() - place.missing >= MISSING_RETRY)) then
        local npc = getCreatureByName(npcName)
        if (npc and isNpc(npc)) then
            local pos = getCreaturePosition(npc)
            local look = getCreatureOutfit(npc) or {}
            place = { x = pos.x, y = pos.y, z = pos.z, town = nearestTown(pos.x, pos.y),
                      look = { type = look.lookType, head = look.lookHead, body = look.lookBody,
                               legs = look.lookLegs, feet = look.lookFeet } }
        else
            place = { missing = os.time() }
        end
        places[npcName] = place
    end
    return not place.missing and place or nil
end

---------------------------------------------------------------------------------------------------
-- The trainer's quests
---------------------------------------------------------------------------------------------------

local function doneToday(quest, status)
    return quest.daily and status > DAILY_DONE and status > getGlobalStorageValue(GLOBAL_STORAGES.SERVER_START_TIME)
end

-- "active", "done", "available", "later" (the NPC offers it from a higher level) or nil (not yet)
Quests.stateOf = function(cid, quest, current)
    local status = tonumber(getCreatureStorage(cid, quest.storage)) or QUEST_STATUS.UNSTARTED
    if (status == QUEST_STATUS.STARTED) then
        return "active"
    elseif (status == QUEST_STATUS.FINISHED or doneToday(quest, status)) then
        return "done"
    elseif (current ~= quest) then
        return (quest.daily and status > DAILY_DONE) and "done" or nil
    elseif (quest.requiredLevel and getPlayerLevel(cid) < quest.requiredLevel) then
        return "later"
    end
    return "available"
end

---------------------------------------------------------------------------------------------------
-- Go there: the quest's next step
---------------------------------------------------------------------------------------------------

local function distance(a, b)
    -- another floor counts as far: stairs are seldom right there
    return math.max(math.abs(a.x - b.x), math.abs(a.y - b.y)) + math.abs(a.z - b.z) * 50
end

local function nearest(list, from)
    local best, bestDistance
    for _, pos in ipairs(list) do
        local d = from and distance(pos, from) or 0
        if (not best or d < bestDistance) then
            best, bestDistance = pos, d
        end
    end
    return best
end

local function placeAt(pos, label)
    return { x = pos.x, y = pos.y, z = pos.z, town = nearestTown(pos.x, pos.y), label = label }
end

-- POKEPEDIA_SPAWNS areas { x, y, z, points } of a species, the closest one
local function spawnPlace(species, from, label)
    local areas = {}
    for _, area in ipairs(POKEPEDIA_SPAWNS and POKEPEDIA_SPAWNS[species] or {}) do
        areas[#areas + 1] = { x = area[1], y = area[2], z = area[3] }
    end
    local pos = nearest(areas, from)
    return pos and placeAt(pos, label)
end

-- item id -> { { species, chance }, ... }: the wild Pokemon that drop it (built on first use)
local droppedBy
local function dropPlace(item, from)
    if (not droppedBy) then
        droppedBy = {}
        for species in pairs(POKEPEDIA_SPAWNS or {}) do
            -- wild Pokemon only: not the cloned, ancient or boss monsters of dungeons and events
            local info = getPokemonNumberByName(species) and getMonsterInfo(species)
            for _, loot in ipairs(info and info.loot or {}) do
                for _, id in ipairs(loot.ids or { loot.id }) do
                    droppedBy[id] = droppedBy[id] or {}
                    table.insert(droppedBy[id], { species = species, chance = loot.chance or 0 })
                end
            end
        end
    end
    -- the least effort: how far away times how many to defeat (a 22% drop next door beats a 92% one
    -- far away), among the species that drop it at least a tenth as often as the best one
    local list, best = droppedBy[item] or {}, 0
    for _, drop in ipairs(list) do
        best = math.max(best, drop.chance)
    end
    local place, placeCost
    for _, drop in ipairs(list) do
        if (drop.chance > 0 and drop.chance * 10 >= best) then
            local p = spawnPlace(drop.species, from, string.format("Defeat %s for the %s", drop.species,
                    getItemNameById(item) or "item"))
            local cost = p and ((from and distance(p, from) or 0) + 10) * best / drop.chance
            if (p and (not place or cost < placeCost)) then
                place, placeCost = p, cost
            end
        end
    end
    return place
end

local function itemPlace(item, from)
    local sources = QUEST_ITEM_SOURCES and QUEST_ITEM_SOURCES[item]
    if (sources) then
        local pos = nearest(sources, from)
        return placeAt(pos, pos.label)
    end
    return dropPlace(item, from)
end

local function stepDone(cid, step)
    if (step.storage) then
        local value = tonumber(getCreatureStorage(cid, step.storage)) or -1
        if (step.atLeast) then
            return value >= step.atLeast
        end
        return value == QUEST_STATUS.FINISHED
    elseif (step.battle) then
        return (tonumber(getCreatureStorage(cid, step.battle)) or -1) > 1 -- getPlayerDefeatedNPC
    elseif (step.item) then
        return getPlayerItemCount(cid, step.item) >= (step.count or 1)
    end
    return true
end

-- the steps a quest leads through: its own (quest.steps in 003-quest.lua) or the ones
-- scripts/make-quest-steps.py found (QUEST_STEPS in questSteps.lua)
local function stepsOf(quest)
    return quest.steps or (QUEST_STEPS and QUEST_STEPS[quest.storage])
end

-- where the quest under way leads next, before going back to the NPC; nil when it's time to go back
local function nextStep(cid, quest)
    local from = isPlayer(cid) and getCreaturePosition(cid) or nil
    local steps = stepsOf(quest)
    if (steps) then
        for _, step in ipairs(steps) do
            if (not stepDone(cid, step)) then
                if (step.pos) then
                    return placeAt(step.pos, step.label)
                elseif (step.places) then
                    local pos = nearest(step.places, from)
                    return placeAt(pos, pos.label)
                elseif (step.item) then
                    return itemPlace(step.item, from)
                end
            end
        end
        return nil
    end
    local request = quest.questRequest
    if (quest.questType == CATCH_POKEMON or quest.questType == DEFEAT_POKEMON) then
        local have, need = Quests.progress(cid, quest)
        if (have and need and have < need) then
            local verb = quest.questType == CATCH_POKEMON and "Catch" or "Defeat"
            return spawnPlace(request[1], from, string.format("%s %s", verb, request[1]))
        end
    elseif (quest.questType == BRING_POKEMON) then
        local have, need = Quests.progress(cid, quest)
        if (have and need and have < need) then
            return spawnPlace(request, from, string.format("Catch %s", request))
        end
    elseif (quest.questType == BRING_ITEMS) then
        for i = 1, #request, 2 do
            if (getPlayerItemCount(cid, request[i]) < request[i + 1]) then
                local place = itemPlace(request[i], from)
                if (place) then
                    return place
                end
            end
        end
    end
    return nil
end

-- Where the trainer goes for a quest. Under way: its next step (above), then back to the NPC.
-- An NPC can stand in several places (Gary Oak is in Viridian, Pewter, Mt. Moon...), and a quest
-- only starts at its startPosition and is handed in at its finishPosition, so those come first: the
-- hand-in spot once it is under way, the start spot before. Without them, wherever the NPC is.
Quests.questPlace = function(entry, state, cid)
    if (state == "active" and cid) then
        local step = nextStep(cid, entry.quest)
        if (step) then
            return step
        end
    end
    return Quests.npcPlace(entry, state)
end

-- the NPC's own spot for this quest: where it starts, or where it is handed in once under way
Quests.npcPlace = function(entry, state)
    local quest = entry.quest
    local npcPlace = Quests.placeOf(entry.npc)
    local pos = (state == "active" and quest.finishPosition) or quest.startPosition or quest.finishPosition
    if (not pos) then
        return npcPlace
    end
    return { x = pos.x, y = pos.y, z = pos.z, town = nearestTown(pos.x, pos.y), look = npcPlace and npcPlace.look }
end

local function row(cid, entry, state)
    local quest = entry.quest
    local data = { id = entry.id, name = entry.name, step = entry.step, group = entry.group, category = entry.category,
                   npc = entry.npc, state = state, text = entry.text, objective = Quests.objective(quest),
                   level = quest.requiredLevel, exp = quest.rewardExp, rewards = rewardsOf(quest),
                   daily = quest.daily and true or nil }
    if (state == "active") then
        data.have, data.need = Quests.progress(cid, quest)
    end
    if (state ~= "done") then
        data.place = Quests.questPlace(entry, state, cid)
        -- "Given by Gary Oak, near Viridian" names the NPC's town even while Go there leads elsewhere
        local npcPlace = Quests.npcPlace(entry, state)
        data.npcTown = npcPlace and npcPlace.town
    end
    return data
end

-- the state of each catalog quest for this trainer; with onlyActive just the started ones (the tracker
-- at login), without asking the NPCs what they offer
local function questState(cid, entry, currents, onlyActive)
    if (onlyActive) then
        return tonumber(getCreatureStorage(cid, entry.id)) == QUEST_STATUS.STARTED and "active" or nil
    end
    local current = currents[entry.npc]
    if (current == nil) then
        current = getNpcCurrentQuest(cid, entry.npc) or false
        currents[entry.npc] = current
    end
    return Quests.stateOf(cid, entry.quest, current or nil)
end

-- Undiscovered quests: until the trainer has talked to the NPC (or done one of its quests), the log only
-- shows "???" with the town, the category and the level. The story and the first steps always show.
local ALWAYS_SHOWN = { ["Main story"] = true, ["Getting started"] = true }
local MET_STORAGE_BASE = 60000000 -- + a hash of the NPC's name, up to 999999

function Quests.metKey(npcName)
    local hash = 5381
    for i = 1, #npcName do
        hash = (hash * 33 + npcName:byte(i)) % 1000000
    end
    return MET_STORAGE_BASE + hash
end

Quests.hasMet = function(cid, npcName)
    return tonumber(getCreatureStorage(cid, Quests.metKey(npcName))) == 1
end

-- an NPC greeted the trainer (NpcHandler:greet)
Quests.onMeet = function(cid, npcName)
    if (not isPlayer(cid) or not npcName or not getAllNpcQuests()[npcName] or Quests.hasMet(cid, npcName)) then
        return
    end
    setPlayerStorageValue(cid, Quests.metKey(npcName), 1)
    if (Quests.isClient(cid)) then
        send(cid, { type = "found", npc = npcName })
    end
end

local function hiddenRow(entry, state)
    local place = Quests.questPlace(entry, state)
    return { id = entry.id, hidden = true, state = state, category = entry.category, level = entry.quest.requiredLevel,
             daily = entry.quest.daily and true or nil, place = place and { town = place.town } or nil }
end

Quests.getList = function(cid, onlyActive)
    local list, currents, states, seen = {}, {}, {}, {}
    local catalog = getCatalog()
    for index, entry in ipairs(catalog) do
        states[index] = questState(cid, entry, currents, onlyActive)
        if (states[index] == "active" or states[index] == "done") then
            seen[entry.npc] = true
        end
    end
    for index, entry in ipairs(catalog) do
        local state = states[index]
        -- quests from NPCs that aren't on the map now (events) only show once started
        if (state and (state == "active" or state == "done" or Quests.placeOf(entry.npc))) then
            if (state == "active" or state == "done" or ALWAYS_SHOWN[entry.category] or seen[entry.npc] or
                    Quests.hasMet(cid, entry.npc)) then
                list[#list + 1] = row(cid, entry, state)
            else
                list[#list + 1] = hiddenRow(entry, state)
            end
        end
    end
    return list
end

Quests.sendList = function(cid, onlyActive)
    send(cid, { type = onlyActive and "active" or "list", quests = Quests.getList(cid, onlyActive) })
end

-- the mark over an NPC for this trainer: a quest to start, one under way, or one to hand in
Quests.markOf = function(cid, npcName)
    local quest = getNpcCurrentQuest(cid, npcName)
    if (not quest) then
        return nil
    end
    local state = Quests.stateOf(cid, quest, quest)
    if (state == "active") then
        local have, need = Quests.progress(cid, quest)
        return (have and have >= need) and "ready" or "active"
    end
    return state == "available" and "available" or nil
end

Quests.sendMarks = function(cid)
    if (not Quests.isClient(cid)) then
        return
    end
    local marks = {}
    for npcName in pairs(getAllNpcQuests()) do
        if (not Quests.RETIRED_NPCS[npcName]) then
            marks[npcName] = Quests.markOf(cid, npcName)
        end
    end
    send(cid, { type = "marks", npcs = marks })
end

---------------------------------------------------------------------------------------------------
-- Notices
---------------------------------------------------------------------------------------------------

local function notice(cid, kind, quest, extra)
    local entry = Quests.getEntry(quest.storage)
    local data = { type = "notice", kind = kind, id = quest.storage, name = entry and entry.name or "Quest",
                   step = entry and entry.step, npc = entry and entry.npc, objective = Quests.objective(quest) or
                   (entry and entry.text) }
    -- under way, the quest log's Go there leads to the next step or where it is handed in
    if (entry and kind ~= "complete") then
        data.place = Quests.questPlace(entry, "active", cid)
        local npcPlace = Quests.npcPlace(entry, "active")
        data.npcTown = npcPlace and npcPlace.town
    end
    for key, value in pairs(extra or {}) do
        data[key] = value
    end
    send(cid, data)
end

Quests.onStart = function(cid, quest, npcName)
    if (not Quests.isClient(cid) or Quests.isRetired(quest)) then
        return
    end
    local have, need = Quests.progress(cid, quest)
    notice(cid, "started", quest, { have = have, need = need })
    Quests.sendMarks(cid)
end

-- every step up to 10, then each tenth of the way and the last three
local function isMilestone(count, need)
    if (need <= 10 or count >= need - 3) then
        return true
    end
    local step = need / 10
    return math.floor(count / step) > math.floor((count - 1) / step)
end

-- true when the client shows it, so the old chat line is left out
Quests.onProgress = function(cid, quest, count, need)
    if (not Quests.isClient(cid) or Quests.isRetired(quest)) then
        return false
    end
    if (count >= need) then
        notice(cid, "ready", quest, { have = count, need = need })
        Quests.sendMarks(cid)
    elseif (isMilestone(count, need)) then
        notice(cid, "progress", quest, { have = count, need = need })
    end
    return true
end

-- one of the quest's steps is done (quest.steps): the quest log's Go there moves on to the next
Quests.onStep = function(cid, quest)
    if (not Quests.isClient(cid) or Quests.isRetired(quest)) then
        return
    end
    local have, need = Quests.progress(cid, quest)
    if (have and need and have >= need) then
        notice(cid, "ready", quest, { have = have, need = need })
        Quests.sendMarks(cid)
    else
        notice(cid, "progress", quest, { have = have, need = need })
    end
end

-- storage -> { { quest, step }, ... } for every step done by a storage or an NPC battle (built on first use)
local stepIndex
local function stepsByStorage()
    if (not stepIndex) then
        stepIndex = {} -- built once: a failure leaves it empty instead of retrying on every storage
        local index = {}
        for _, entry in ipairs(getCatalog()) do
            for _, step in ipairs(stepsOf(entry.quest) or {}) do
                local key = step.storage or step.battle
                if (key) then
                    index[key] = index[key] or {}
                    table.insert(index[key], { quest = entry.quest, step = step })
                end
            end
        end
        stepIndex = index
    end
    return stepIndex
end

-- a script set a storage: when that finished a step of a quest under way, Go there moves on
Quests.onStorage = function(cid, key)
    local list = stepsByStorage()[key]
    if (not list or not isPlayer(cid)) then
        return
    end
    for _, item in ipairs(list) do
        if (tonumber(getCreatureStorage(cid, item.quest.storage)) == QUEST_STATUS.STARTED and stepDone(cid, item.step)) then
            Quests.onStep(cid, item.quest)
        end
    end
end

Quests.onFinish = function(cid, quest)
    if (not Quests.isClient(cid) or Quests.isRetired(quest)) then
        return
    end
    notice(cid, "complete", quest, { exp = quest.rewardExp, rewards = rewardsOf(quest), daily = quest.daily and true or nil })
    local entry = Quests.getEntry(quest.storage)
    doPlayerAddActivity(cid, "quest", string.format(__L(cid, "Quest complete: %s"), entry and entry.name or __L(cid, "Quest")))
    Quests.sendMarks(cid)
end

Quests.onLevelUp = function(cid)
    Quests.sendMarks(cid)
end

Quests.onLogin = function(cid)
    setPlayerStorageValue(cid, CLIENT, -1)
end

Quests.onClientMessage = function(cid, buffer)
    local ok, data = pcall(JSON.decode, buffer)
    if (not ok or type(data) ~= "table") then
        return
    end
    if (data.action == "hello") then
        setPlayerStorageValue(cid, CLIENT, 1)
        Quests.sendList(cid, true)
        Quests.sendMarks(cid)
    elseif (data.action == "list") then
        Quests.sendList(cid)
        Quests.sendMarks(cid)
    end
end

-- Every storage a script sets goes past Quests.onStorage, so Go there moves on as soon as a step is done,
-- whichever script did it (a magnifier, a step on a tile, a talk, a battle). A quest log error never
-- stops the storage itself from being set.
if (not rawDoCreatureSetStorage) then
    rawDoCreatureSetStorage = doCreatureSetStorage
end
function doCreatureSetStorage(cid, key, ...)
    local result = rawDoCreatureSetStorage(cid, key, ...)
    local ok, err = pcall(Quests.onStorage, cid, key)
    if (not ok) then
        log(LOG_TYPES.ERROR, "Quests.onStorage", key, err)
    end
    return result
end
-- 100-compat.lua's aliases were taken before this
doPlayerSetStorageValue = doCreatureSetStorage
setPlayerStorageValue = doCreatureSetStorage
