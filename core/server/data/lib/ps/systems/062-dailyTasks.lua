-- Daily tasks: three tasks a day picked for the trainer's level, a reward for each, a bonus
-- for finishing all three and one reroll a day. The day turns over at midnight in the
-- server's time zone (pokeverse-ctl configure timezone=).
--
-- State lives in `player_daily_tasks` (schemas/pokeverse-extensions.sql), one JSON row per
-- character, written on every change. The client's Daily Tasks window (game_dailytasks)
-- sends "/dailytasks [claim <slot>|bonus|reroll <slot>]" and gets the state back as
-- EXTENDED_IDS.DAILY_TASKS JSON.

DailyTasks = {}

DailyTasks.TASK_COUNT = 3

local DOLLAR = 2148

-- counts and rewards grow with the trainer's level
local BANDS = {
    { minLevel = 1, money = 400, rerollCost = 300,
      items = { { 12244, 5 }, { 12157, 10 } }, -- pokemon health potions, empty poke balls
      bonus = { money = 2000, items = { { 13295, 1 } } } }, -- white surprise box
    { minLevel = 20, money = 1000, rerollCost = 800,
      items = { { 12245, 5 }, { 12161, 10 } }, -- great health potions, empty great balls
      bonus = { money = 5000, items = { { 13295, 1 }, { 12248, 2 } } } }, -- + pokemon revives
    { minLevel = 50, money = 2500, rerollCost = 2000,
      items = { { 12246, 5 }, { 12165, 10 }, { 12248, 2 } }, -- ultra health potions, empty ultra balls
      bonus = { money = 12000, items = { { 13292, 1 } } } }, -- black surprise box
    { minLevel = 100, money = 6000, rerollCost = 5000,
      items = { { 12247, 5 }, { 12165, 20 }, { 14463, 1 } }, -- super health potions, ultra balls, rare candy
      bonus = { money = 30000, items = { { 13292, 1 }, { 14463, 1 } } } },
}

-- types that live near every town, so a typed task can always be done
local COMMON_TYPES = { ELEMENT_NORMAL, ELEMENT_BUG, ELEMENT_GRASS, ELEMENT_WATER, ELEMENT_FLYING,
    ELEMENT_POISON, ELEMENT_FIRE, ELEMENT_ELECTRIC, ELEMENT_GROUND, ELEMENT_ROCK }

-- counts[band]; weight scales the band's money reward
local KINDS = {
    defeat = { event = "defeat", title = "Defeat %d wild Pokemon", counts = { 15, 30, 50, 80 }, weight = 1 },
    defeatType = { event = "defeat", typed = true, title = "Defeat %d wild %s-type Pokemon",
                   counts = { 8, 15, 25, 40 }, weight = 1.2 },
    catch = { event = "catch", title = "Catch %d Pokemon", counts = { 2, 3, 5, 8 }, weight = 1.2 },
    catchType = { event = "catch", typed = true, title = "Catch %d %s-type Pokemon",
                  counts = { 1, 2, 3, 4 }, weight = 1.5 },
    fish = { event = "fish", title = "Hook %d Pokemon while fishing", counts = { 3, 5, 8, 12 }, weight = 1 },
    headbutt = { event = "headbutt", title = "Headbutt %d trees that hide Pokemon", counts = { 2, 4, 6, 10 },
                 weight = 1, minLevel = 10 },
    trainer = { event = "trainer", title = "Win %d battles against NPC trainers", counts = { 1, 2, 3, 5 },
                weight = 1.5, minLevel = 10 },
}
local KIND_NAMES = {}
for name in pairs(KINDS) do
    KIND_NAMES[#KIND_NAMES + 1] = name
end
table.sort(KIND_NAMES)

local cache = {} -- player guid -> state

local function today()
    return os.date("%Y-%m-%d")
end

local function secondsUntilMidnight()
    local t = os.date("*t")
    return (23 - t.hour) * 3600 + (59 - t.min) * 60 + (60 - t.sec)
end

local function bandIndex(level)
    local index = 1
    for i, band in ipairs(BANDS) do
        if (level >= band.minLevel) then
            index = i
        end
    end
    return index
end

local function newTask(kindName, band)
    local kind = KINDS[kindName]
    local task = { kind = kindName, target = kind.counts[band], progress = 0, claimed = false }
    if (kind.typed) then
        task.type = COMMON_TYPES[math.random(#COMMON_TYPES)]
    end
    local item = BANDS[band].items[math.random(#BANDS[band].items)]
    task.money = math.floor(BANDS[band].money * kind.weight / 100) * 100
    task.item = { item[1], item[2] }
    return task
end

-- a kind not in use yet, that the trainer's level allows
local function pickKind(state, level, except)
    local used = {}
    for _, task in ipairs(state.tasks) do
        used[task.kind] = true
    end
    local choices = {}
    for _, name in ipairs(KIND_NAMES) do
        local kind = KINDS[name]
        if (not used[name] and name ~= except and level >= (kind.minLevel or 1)) then
            choices[#choices + 1] = name
        end
    end
    return choices[math.random(#choices)]
end

local function newDay(cid)
    local level = getPlayerLevel(cid)
    local state = { day = today(), band = bandIndex(level), tasks = {}, rerolled = false, bonusClaimed = false }
    for slot = 1, DailyTasks.TASK_COUNT do
        state.tasks[slot] = newTask(pickKind(state, level), state.band)
    end
    return state
end

local function save(cid, state)
    db.executeQuery(string.concat("REPLACE INTO `player_daily_tasks` (`player_id`, `day`, `data`, `updated_at`) VALUES (",
        getPlayerGUID(cid), ", ", db.escapeString(state.day), ", ", db.escapeString(JSON.encode(state)), ", ",
        os.time(), ")"))
end

local function load(cid)
    local guid = getPlayerGUID(cid)
    local resultId = db.storeQuery(string.concat("SELECT `data` FROM `player_daily_tasks` WHERE `player_id` = ", guid))
    if (not resultId) then
        return nil
    end
    local raw = result.getDataString(resultId, "data")
    result.free(resultId)
    local ok, state = pcall(JSON.decode, raw)
    if (not ok or type(state) ~= "table" or type(state.tasks) ~= "table") then
        log(LOG_TYPES.ERROR, "DailyTasks - invalid saved state.", getCreatureName(cid))
        return nil
    end
    return state
end

-- The state for today; a new day picks new tasks.
function DailyTasks.get(cid)
    local guid = getPlayerGUID(cid)
    local state = cache[guid]
    if (not state) then
        state = load(cid)
    end
    if (not state or state.day ~= today()) then
        state = newDay(cid)
        save(cid, state)
    end
    cache[guid] = state
    return state
end

local function isComplete(task)
    return task.progress >= task.target
end

local function taskTitle(cid, task)
    local kind = KINDS[task.kind]
    if (kind.typed) then
        return string.format(__L(cid, kind.title), task.target, ELEMENT_NAMES[task.type] or "?")
    end
    return string.format(__L(cid, kind.title), task.target)
end

local function rewardJson(money, items)
    local list = {}
    for _, item in ipairs(items) do
        list[#list + 1] = { id = getItemClientId(item[1]) or 0, count = item[2],
                            name = item[2] > 1 and getItemPluralNameById(item[1]) or getItemNameById(item[1]) }
    end
    return { money = money, items = JSON.array(list) }
end

function DailyTasks.send(cid)
    local state = DailyTasks.get(cid)
    local band = BANDS[state.band]
    local tasks = {}
    local allClaimed = true
    for slot, task in ipairs(state.tasks) do
        tasks[slot] = { slot = slot, title = taskTitle(cid, task), progress = math.min(task.progress, task.target),
                        target = task.target, claimed = task.claimed, reward = rewardJson(task.money, { task.item }) }
        allClaimed = allClaimed and task.claimed
    end
    doSendPlayerExtendedOpcode(cid, EXTENDED_IDS.DAILY_TASKS, JSON.encode({
        tasks = JSON.array(tasks),
        resetsIn = secondsUntilMidnight(),
        reroll = { available = not state.rerolled, cost = band.rerollCost },
        bonus = { ready = allClaimed and not state.bonusClaimed, claimed = state.bonusClaimed,
                  reward = rewardJson(band.bonus.money, band.bonus.items) },
    }))
end

local function matches(task, info)
    if (not KINDS[task.kind].typed) then
        return true
    end
    return info and info.name and table.find(getPokemonTypes(nil, info.name) or {}, task.type) ~= nil
end

-- A trainer did something a task may count: event is one of the KINDS events.
function DailyTasks.onEvent(cid, event, info)
    if (not isPlayer(cid)) then
        return
    end
    local state = DailyTasks.get(cid)
    local changed = false
    for _, task in ipairs(state.tasks) do
        if (KINDS[task.kind].event == event and not isComplete(task) and matches(task, info)) then
            task.progress = task.progress + 1
            changed = true
            if (isComplete(task)) then
                doPlayerSendTextMessage(cid, MESSAGE_EVENT_ADVANCE, string.format(
                    __L(cid, "Daily task complete: %s! Open Daily Tasks to claim your reward."), taskTitle(cid, task)))
            end
        end
    end
    if (changed) then
        save(cid, state)
        DailyTasks.send(cid)
    end
end

function DailyTasks.onDefeated(cid, target)
    if (PokemonStats.isWildPokemon(target)) then
        DailyTasks.onEvent(cid, "defeat", { name = getCreatureName(target) })
    end
end

local function giveReward(cid, money, items)
    if (money > 0) then
        doPlayerAddMoney(cid, money)
    end
    for _, item in ipairs(items) do
        doPlayerAddItem(cid, item[1], item[2], true)
    end
end

function DailyTasks.claim(cid, slot)
    local state = DailyTasks.get(cid)
    local task = state.tasks[slot]
    if (not task or task.claimed or not isComplete(task)) then
        doPlayerSendCancel(cid, "This task is not complete yet.")
        return false
    end
    task.claimed = true
    save(cid, state)
    giveReward(cid, task.money, { task.item })
    doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, string.format(
        __L(cid, "You claimed the reward for '%s'."), taskTitle(cid, task)))
    doSendMagicEffect(getCreaturePosition(cid), EFFECT_EMOTION_HAPPY)
    DailyTasks.send(cid)
    return true
end

function DailyTasks.claimBonus(cid)
    local state = DailyTasks.get(cid)
    for _, task in ipairs(state.tasks) do
        if (not task.claimed) then
            doPlayerSendCancel(cid, "Claim all three daily tasks first.")
            return false
        end
    end
    if (state.bonusClaimed) then
        doPlayerSendCancel(cid, "You already claimed today's bonus.")
        return false
    end
    state.bonusClaimed = true
    save(cid, state)
    local bonus = BANDS[state.band].bonus
    giveReward(cid, bonus.money, bonus.items)
    doPlayerSendTextMessage(cid, MESSAGE_EVENT_ADVANCE, __L(cid, "All daily tasks done! You received the daily bonus. New tasks arrive at midnight."))
    DailyTasks.send(cid)
    return true
end

function DailyTasks.reroll(cid, slot)
    local state = DailyTasks.get(cid)
    local task = state.tasks[slot]
    local cost = BANDS[state.band].rerollCost
    if (not task or task.claimed or isComplete(task)) then
        doPlayerSendCancel(cid, "Only an unfinished task can be rerolled.")
        return false
    elseif (state.rerolled) then
        doPlayerSendCancel(cid, "You already rerolled a task today.")
        return false
    elseif (getPlayerMoney(cid) < cost or not doPlayerRemoveMoney(cid, cost)) then
        doPlayerSendCancel(cid, string.format(__L(cid, "A reroll costs %d dollars."), cost))
        return false
    end
    state.rerolled = true
    state.tasks[slot] = newTask(pickKind(state, getPlayerLevel(cid), task.kind) or task.kind, state.band)
    save(cid, state)
    DailyTasks.send(cid)
    return true
end

-- the database is the truth between sessions (staff may edit it while the character is offline)
function DailyTasks.onLogin(cid)
    cache[getPlayerGUID(cid)] = nil
    DailyTasks.send(cid)
end

function DailyTasks.onLogout(cid)
    cache[getPlayerGUID(cid)] = nil
end

-- at midnight, online trainers get their new tasks without having to do anything; the
-- timer survives /reload (the event keeps the first version of the function)
local function onMidnight()
    for _, cid in ipairs(getPlayersOnline()) do
        DailyTasks.send(cid)
    end
    addEvent(onMidnight, secondsUntilMidnight() * 1000 + 1000)
end
if (not DAILY_TASKS_MIDNIGHT_SCHEDULED) then
    DAILY_TASKS_MIDNIGHT_SCHEDULED = true
    addEvent(onMidnight, secondsUntilMidnight() * 1000 + 1000)
end
