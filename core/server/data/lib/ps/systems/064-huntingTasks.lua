-- The hunting board: pick a difficulty (the level range of the species offered), pick a species
-- from three offers, choose a size (how many to defeat), hunt, claim money and Hunt Points,
-- repeat. The difficulty can only change while no hunt is running. Points raise the
-- trainer's hunting rank (more money per hunt) and buy items in the board's shop. The offers
-- can be refreshed for free once a day (it comes back at midnight), or any time for money. Premium trainers
-- can run two hunts at once.
--
-- State lives in `player_task_boards` (board = "hunting"). The client's Tasks window sends
-- "/tasks hunting [difficulty <id>|take <offer> <size>|claim <slot>|cancel <slot>|refresh|buy <item>]" and gets
-- the state back as EXTENDED_IDS.TASK_BOARDS JSON with board = "hunting".

HuntingTasks = {}

local OFFER_COUNT = 3
local MIN_SPAWNS = 20 -- species with fewer spawns in the world are too rare to hunt

HuntingTasks.SIZES = {
    { name = "Small", kills = 100, points = 10 },
    { name = "Medium", kills = 250, points = 30 },
    { name = "Large", kills = 500, points = 70 },
}

-- by lifetime points earned; bonus is extra money on every claimed hunt
HuntingTasks.RANKS = {
    { name = "Bronze", points = 0, bonus = 0 },
    { name = "Silver", points = 150, bonus = 10 },
    { name = "Gold", points = 600, bonus = 20 },
    { name = "Master", points = 1500, bonus = 30 },
}

HuntingTasks.SHOP = {
    { id = 13295, count = 1, cost = 20 }, -- white surprise box
    { id = 12248, count = 5, cost = 25 }, -- pokemon revives
    { id = 12165, count = 25, cost = 30 }, -- empty ultra balls
    { id = 13292, count = 1, cost = 60 }, -- black surprise box
    { id = 14463, count = 1, cost = 80 }, -- rare candy
}

-- Wild species that spawn often enough to hunt, with their level range, read once from the
-- map's spawn file (kept across /reload).
local function species()
    if (HUNTING_SPECIES) then
        return HUNTING_SPECIES
    end
    local path = string.concat(getDataDir(), "world/", getConfigValue("mapName"), "-spawn.xml")
    local file = io.open(path, "r")
    if (not file) then
        log(LOG_TYPES.ERROR, "HuntingTasks - can't read the spawn file.", path)
        return {}
    end
    local counts = {}
    for name in file:read("*a"):gmatch('<monster name="([^"]+)"') do
        counts[name] = (counts[name] or 0) + 1
    end
    file:close()
    local list = {}
    for name, count in pairs(counts) do
        local info = count >= MIN_SPAWNS and isPokemonName(name, true) and getMonsterInfo(name, false)
        if (info and (info.maxLevel or 0) > 0) then
            list[#list + 1] = { name = name, minLevel = info.minLevel, maxLevel = info.maxLevel,
                                level = math.floor((info.minLevel + info.maxLevel) / 2) }
        end
    end
    table.sort(list, function(a, b) return a.level < b.level or (a.level == b.level and a.name < b.name) end)
    HUNTING_SPECIES = list
    return list
end

local function findSpecies(name)
    for _, s in ipairs(species()) do
        if (s.name == name) then
            return s
        end
    end
    return nil
end

local function slotCount(cid)
    return isPremium(cid) and 2 or 1
end

local function rankOf(earned)
    local index = 1
    for i, rank in ipairs(HuntingTasks.RANKS) do
        if (earned >= rank.points) then
            index = i
        end
    end
    return index
end

-- OFFER_COUNT species in the difficulty's level range, none of them already being hunted
local function newOffers(cid, state)
    if (not state.difficulty) then
        return {}
    end
    local range = TASK_DIFFICULTIES[state.difficulty].huntLevels
    local busy = {}
    for _, hunt in ipairs(state.active) do
        busy[hunt.species] = true
    end
    local all = species()
    local choices = {}
    for widen = 0, 50, 5 do
        choices = {}
        for _, s in ipairs(all) do
            if (not busy[s.name] and s.level >= range[1] - widen and s.level <= range[2] + widen) then
                choices[#choices + 1] = s.name
            end
        end
        if (#choices >= OFFER_COUNT) then
            break
        end
    end
    local offers = {}
    while (#offers < OFFER_COUNT and #choices > 0) do
        offers[#offers + 1] = table.remove(choices, math.random(#choices))
    end
    return offers
end

local function save(cid, state)
    TaskBoards.save(cid, "hunting", "", state)
end

-- Read from the table every time, like the daily board: the window's talkactions and the
-- creaturescripts that count defeats run in different Lua states.
function HuntingTasks.get(cid)
    local state = TaskBoards.load(cid, "hunting")
    if (not state or type(state.active) ~= "table" or type(state.offers) ~= "table") then
        state = { active = {}, offers = {}, savedOffers = {}, points = 0, earned = 0, completed = 0 }
        save(cid, state)
    end
    state.savedOffers = state.savedOffers or {}
    return state
end

local function moneyFor(cid, state, speciesName, size)
    local s = findSpecies(speciesName)
    local perKill = 10 + 2 * (s and s.level or 1)
    local bonus = HuntingTasks.RANKS[rankOf(state.earned)].bonus
    return math.floor(perKill * HuntingTasks.SIZES[size].kills * (100 + bonus) / 100 / 100) * 100
end

local function lookOf(name)
    local info = getMonsterInfo(name, false)
    return info and info.outfit and info.outfit.lookType or 0
end

function HuntingTasks.send(cid)
    local state = HuntingTasks.get(cid)
    local rankIndex = rankOf(state.earned)
    local rank, nextRank = HuntingTasks.RANKS[rankIndex], HuntingTasks.RANKS[rankIndex + 1]

    local active = {}
    for slot, hunt in ipairs(state.active) do
        active[slot] = { slot = slot, species = hunt.species, look = lookOf(hunt.species), size = hunt.size,
                         sizeName = HuntingTasks.SIZES[hunt.size].name, progress = math.min(hunt.progress, hunt.target),
                         target = hunt.target, money = moneyFor(cid, state, hunt.species, hunt.size),
                         points = HuntingTasks.SIZES[hunt.size].points }
    end

    local offers = {}
    for index, name in ipairs(state.offers) do
        local s = findSpecies(name)
        local sizes = {}
        for size, info in ipairs(HuntingTasks.SIZES) do
            sizes[size] = { size = size, name = info.name, kills = info.kills, points = info.points,
                            money = moneyFor(cid, state, name, size) }
        end
        offers[index] = { offer = index, species = name, look = lookOf(name), minLevel = s and s.minLevel or 0,
                          maxLevel = s and s.maxLevel or 0, sizes = JSON.array(sizes) }
    end

    local shop = {}
    for index, item in ipairs(HuntingTasks.SHOP) do
        shop[index] = { item = index, id = getItemClientId(item.id) or 0, count = item.count, cost = item.cost,
                        name = item.count > 1 and getItemPluralNameById(item.id) or getItemNameById(item.id) }
    end

    local today = os.date("%Y-%m-%d")
    doSendPlayerExtendedOpcode(cid, EXTENDED_IDS.TASK_BOARDS, JSON.encode({
        board = "hunting",
        slots = slotCount(cid),
        active = JSON.array(active),
        offers = JSON.array(offers),
        points = state.points,
        completed = state.completed,
        rank = { name = rank.name, bonus = rank.bonus, earned = state.earned,
                 next = nextRank and nextRank.name or nil, nextAt = nextRank and nextRank.points or nil },
        refresh = { free = state.freeRefreshDay ~= today, freeIn = state.freeRefreshDay ~= today and 0 or TaskBoards.secondsUntilMidnight(),
                    cost = state.difficulty and TASK_DIFFICULTIES[state.difficulty].refreshCost or 0 },
        difficulty = state.difficulty,
        difficulties = TaskBoards.difficultiesJson(cid),
        suggested = TaskBoards.suggestedDifficulty(cid),
        locked = #state.active > 0,
        shop = JSON.array(shop),
    }))
end

-- Picks the level range of the offered species. Each difficulty keeps its own offers, so
-- switching back and forth does not refresh them.
function HuntingTasks.setDifficulty(cid, difficulty)
    local state = HuntingTasks.get(cid)
    if (#state.active > 0) then
        doPlayerSendCancel(cid, __L(cid, "Finish or give up your hunts before changing the difficulty."))
        return false
    elseif (state.difficulty == difficulty) then
        HuntingTasks.send(cid)
        return true
    elseif (not TaskBoards.canPick(cid, difficulty)) then
        return false
    end
    if (state.difficulty) then
        state.savedOffers[tostring(state.difficulty)] = state.offers
    end
    state.difficulty = difficulty
    state.offers = state.savedOffers[tostring(difficulty)] or newOffers(cid, state)
    state.savedOffers[tostring(difficulty)] = nil
    save(cid, state)
    HuntingTasks.send(cid)
    return true
end

function HuntingTasks.take(cid, offer, size)
    local state = HuntingTasks.get(cid)
    local name = state.offers[offer]
    if (not name or not HuntingTasks.SIZES[size]) then
        doPlayerSendCancel(cid, "Pick one of the offered hunts.")
        return false
    elseif (#state.active >= slotCount(cid)) then
        doPlayerSendCancel(cid, __L(cid, isPremium(cid) and "You are already on two hunts."
            or "You are already on a hunt. Premium trainers can run two at once."))
        return false
    end
    table.remove(state.offers, offer)
    state.active[#state.active + 1] = { species = name, size = size, target = HuntingTasks.SIZES[size].kills, progress = 0 }
    save(cid, state)
    doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, string.format(
        __L(cid, "Hunt started: defeat %d wild %s."), HuntingTasks.SIZES[size].kills, name))
    HuntingTasks.send(cid)
    return true
end

function HuntingTasks.cancel(cid, slot)
    local state = HuntingTasks.get(cid)
    local hunt = state.active[slot]
    if (not hunt) then
        return false
    end
    table.remove(state.active, slot)
    if (#state.offers < OFFER_COUNT and not isInArray(state.offers, hunt.species)) then
        state.offers[#state.offers + 1] = hunt.species
    end
    save(cid, state)
    doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, string.format(__L(cid, "You gave up the %s hunt."), hunt.species))
    HuntingTasks.send(cid)
    return true
end

function HuntingTasks.claim(cid, slot)
    local state = HuntingTasks.get(cid)
    local hunt = state.active[slot]
    if (not hunt or hunt.progress < hunt.target) then
        doPlayerSendCancel(cid, "This hunt is not complete yet.")
        return false
    end
    local money = moneyFor(cid, state, hunt.species, hunt.size)
    local points = HuntingTasks.SIZES[hunt.size].points
    local oldRank = rankOf(state.earned)
    table.remove(state.active, slot)
    state.points = state.points + points
    state.earned = state.earned + points
    state.completed = state.completed + 1
    state.offers = newOffers(cid, state)
    save(cid, state)
    TaskBoards.giveReward(cid, money, {})
    doPlayerSendTextMessage(cid, MESSAGE_EVENT_ADVANCE, string.format(
        __L(cid, "Hunt complete! You received %d dollars and %d Hunt Points."), money, points))
    local newRank = rankOf(state.earned)
    if (newRank > oldRank) then
        doPlayerSendTextMessage(cid, MESSAGE_EVENT_ADVANCE, string.format(
            __L(cid, "Your hunting rank is now %s: +%d%% money on every hunt."),
            HuntingTasks.RANKS[newRank].name, HuntingTasks.RANKS[newRank].bonus))
    end
    doSendMagicEffect(getCreaturePosition(cid), EFFECT_EMOTION_HAPPY)
    HuntingTasks.send(cid)
    return true
end

function HuntingTasks.refresh(cid)
    local state = HuntingTasks.get(cid)
    if (not state.difficulty) then
        return false
    end
    local today = os.date("%Y-%m-%d")
    if (state.freeRefreshDay ~= today) then
        state.freeRefreshDay = today
    else
        local cost = TASK_DIFFICULTIES[state.difficulty].refreshCost
        if (getPlayerMoney(cid) < cost or not doPlayerRemoveMoney(cid, cost)) then
            doPlayerSendCancel(cid, string.format(__L(cid, "New offers cost %d dollars until the free refresh."), cost))
            return false
        end
    end
    state.offers = newOffers(cid, state)
    save(cid, state)
    HuntingTasks.send(cid)
    return true
end

function HuntingTasks.buy(cid, index)
    local state = HuntingTasks.get(cid)
    local item = HuntingTasks.SHOP[index]
    if (not item) then
        return false
    elseif (state.points < item.cost) then
        doPlayerSendCancel(cid, string.format(__L(cid, "You need %d Hunt Points."), item.cost))
        return false
    end
    state.points = state.points - item.cost
    save(cid, state)
    TaskBoards.giveReward(cid, 0, { { item.id, item.count } })
    doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, string.format(__L(cid, "You bought %d %s for %d Hunt Points."),
        item.count, item.count > 1 and getItemPluralNameById(item.id) or getItemNameById(item.id), item.cost))
    HuntingTasks.send(cid)
    return true
end

function HuntingTasks.onDefeated(cid, target)
    if (not isPlayer(cid) or not PokemonStats.isWildPokemon(target)) then
        return
    end
    local name = getCreatureName(target):gsub("^Shiny ", "")
    local state = HuntingTasks.get(cid)
    for _, hunt in ipairs(state.active) do
        if (hunt.species == name and hunt.progress < hunt.target) then
            hunt.progress = hunt.progress + 1
            if (hunt.progress >= hunt.target) then
                doPlayerSendTextMessage(cid, MESSAGE_EVENT_ADVANCE, string.format(
                    __L(cid, "Hunt complete: %d %s defeated! Open Tasks to claim your reward."), hunt.target, name))
            elseif (hunt.progress % 25 == 0) then
                doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, string.format(
                    __L(cid, "Hunt: %d / %d %s."), hunt.progress, hunt.target, name))
            end
            save(cid, state)
            HuntingTasks.send(cid)
            return
        end
    end
end

-- Staff tools: reset (clears the difficulty too), progress <slot> <count>, points <count>
function HuntingTasks.reset(cid)
    local state = { active = {}, offers = {}, savedOffers = {}, points = 0, earned = 0, completed = 0 }
    save(cid, state)
    HuntingTasks.send(cid)
end

function HuntingTasks.setProgress(cid, slot, count)
    local state = HuntingTasks.get(cid)
    local hunt = state.active[slot]
    if (not hunt) then
        return false
    end
    hunt.progress = math.max(0, math.min(count, hunt.target))
    save(cid, state)
    HuntingTasks.send(cid)
    return true
end

function HuntingTasks.setPoints(cid, count)
    local state = HuntingTasks.get(cid)
    state.points = math.max(0, count)
    save(cid, state)
    HuntingTasks.send(cid)
end

function HuntingTasks.onLogin(cid)
    HuntingTasks.send(cid)
end

-- Everything that feeds the task boards goes through here.
Tasks = {}

function Tasks.onEvent(cid, event, info)
    DailyTasks.onEvent(cid, event, info)
    WeeklyTasks.onEvent(cid, event, info)
end

function Tasks.onDefeated(cid, target)
    DailyTasks.onDefeated(cid, target)
    WeeklyTasks.onDefeated(cid, target)
    HuntingTasks.onDefeated(cid, target)
end

-- a broken board must not stop the trainer from logging in
function Tasks.onLogin(cid)
    for name, board in pairs({ daily = DailyTasks, weekly = WeeklyTasks, hunting = HuntingTasks }) do
        local ok, err = pcall(board.onLogin, cid)
        if (not ok) then
            log(LOG_TYPES.ERROR, "Tasks - " .. name .. " board failed at login: " .. tostring(err), getCreatureName(cid))
        end
    end
end
