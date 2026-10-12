-- Daily and weekly tasks. At the start of each period the trainer picks a difficulty (one their
-- level allows); that picks the tasks, their counts and rewards, and stays until the period ends.
-- Each task has a reward, finishing them all gives a bonus, and one task per period can be
-- rerolled. A day turns over at midnight and a week on Monday at midnight, in the server's time
-- zone (pokeverse-ctl configure timezone=).
--
-- Daily state lives in `player_daily_tasks` and weekly state in `player_task_boards`
-- (schemas/pokeverse-extensions.sql), one JSON row per character, written on every change.
-- The client's Tasks window (game_dailytasks) sends "/tasks daily|weekly [start <difficulty>|
-- claim <slot>|bonus|reroll <slot>]". Daily state comes back as EXTENDED_IDS.DAILY_TASKS JSON
-- and weekly state as EXTENDED_IDS.TASK_BOARDS JSON with board = "weekly".

local DAY = 24 * 60 * 60

-- Shared by every task board, the hunting board included. huntLevels is the level range of the
-- species the hunting board offers.
TASK_DIFFICULTIES = {
    { name = "Beginner", minLevel = 1, huntLevels = { 1, 20 }, money = 400, rerollCost = 300, refreshCost = 1000,
      items = { { 12244, 5 }, { 12157, 10 } }, -- pokemon health potions, empty poke balls
      bonus = { money = 2000, items = { { 13295, 1 } } }, -- white surprise box
      weeklyBonus = { money = 10000, items = { { 13292, 1 }, { 12248, 3 } } } }, -- black surprise box, revives
    { name = "Easy", minLevel = 15, huntLevels = { 15, 40 }, money = 700, rerollCost = 500, refreshCost = 2000,
      items = { { 12244, 8 }, { 12161, 8 } }, -- pokemon health potions, empty great balls
      bonus = { money = 3500, items = { { 13295, 1 }, { 12248, 1 } } },
      weeklyBonus = { money = 16000, items = { { 13292, 1 }, { 12248, 4 } } } },
    { name = "Medium", minLevel = 35, huntLevels = { 35, 60 }, money = 1000, rerollCost = 800, refreshCost = 4000,
      items = { { 12245, 5 }, { 12161, 10 } }, -- great health potions, empty great balls
      bonus = { money = 5000, items = { { 13295, 1 }, { 12248, 2 } } },
      weeklyBonus = { money = 25000, items = { { 13292, 1 }, { 12248, 5 } } } },
    { name = "Hard", minLevel = 55, huntLevels = { 55, 85 }, money = 2500, rerollCost = 2000, refreshCost = 10000,
      items = { { 12246, 5 }, { 12165, 10 }, { 12248, 2 } }, -- ultra health potions, empty ultra balls
      bonus = { money = 12000, items = { { 13292, 1 } } },
      weeklyBonus = { money = 60000, items = { { 13292, 2 }, { 14463, 1 } } } }, -- + rare candy
    { name = "Extreme", minLevel = 80, huntLevels = { 80, 150 }, money = 6000, rerollCost = 5000, refreshCost = 20000,
      items = { { 12247, 5 }, { 12165, 20 }, { 14463, 1 } }, -- super health potions, ultra balls, rare candy
      bonus = { money = 30000, items = { { 13292, 1 }, { 14463, 1 } } },
      weeklyBonus = { money = 150000, items = { { 13292, 2 }, { 14463, 3 } } } },
}

-- saved states from before difficulties had a level band (4 of them) instead
local OLD_BAND_DIFFICULTY = { 1, 3, 4, 5 }

-- types that live near every town, so a typed task can always be done
local COMMON_TYPES = { ELEMENT_NORMAL, ELEMENT_BUG, ELEMENT_GRASS, ELEMENT_WATER, ELEMENT_FLYING,
    ELEMENT_POISON, ELEMENT_FIRE, ELEMENT_ELECTRIC, ELEMENT_GROUND, ELEMENT_ROCK }

-- counts[difficulty] for a daily task; weight scales the difficulty's money reward
local KINDS = {
    defeat = { event = "defeat", title = "Defeat %d wild Pokemon", counts = { 15, 25, 35, 50, 80 }, weight = 1 },
    defeatType = { event = "defeat", typed = true, title = "Defeat %d wild %s-type Pokemon",
                   counts = { 8, 12, 18, 25, 40 }, weight = 1.2 },
    catch = { event = "catch", title = "Catch %d Pokemon", counts = { 2, 3, 4, 5, 8 }, weight = 1.2 },
    catchType = { event = "catch", typed = true, title = "Catch %d %s-type Pokemon",
                  counts = { 1, 2, 2, 3, 4 }, weight = 1.5 },
    fish = { event = "fish", title = "Hook %d Pokemon while fishing", counts = { 3, 4, 6, 8, 12 }, weight = 1 },
    headbutt = { event = "headbutt", title = "Headbutt %d trees that hide Pokemon", counts = { 2, 3, 4, 6, 10 },
                 weight = 1, minLevel = 10 },
    trainer = { event = "trainer", title = "Win %d battles against NPC trainers", counts = { 1, 2, 2, 3, 5 },
                weight = 1.5, minLevel = 10 },
}
local KIND_NAMES = {}
for name in pairs(KINDS) do
    KIND_NAMES[#KIND_NAMES + 1] = name
end
table.sort(KIND_NAMES)

local function secondsUntilMidnight()
    local t = os.date("*t")
    return (23 - t.hour) * 3600 + (59 - t.min) * 60 + (60 - t.sec)
end

-- the date of this week's Monday; noon keeps daylight saving changes away from the day boundary
local function thisMonday()
    local t = os.date("*t")
    local sinceMonday = (t.wday + 5) % 7
    return os.date("%Y-%m-%d", os.time({ year = t.year, month = t.month, day = t.day - sinceMonday, hour = 12 }))
end

local function secondsUntilMonday()
    local t = os.date("*t")
    local daysLeft = 6 - (t.wday + 5) % 7
    return daysLeft * DAY + secondsUntilMidnight()
end

local function rewardJson(money, items)
    local list = {}
    for _, item in ipairs(items) do
        list[#list + 1] = { id = getItemClientId(item[1]) or 0, count = item[2],
                            name = item[2] > 1 and getItemPluralNameById(item[1]) or getItemNameById(item[1]) }
    end
    return { money = money, items = JSON.array(list) }
end

local function giveReward(cid, money, items)
    if (money > 0) then
        doPlayerAddMoney(cid, money)
    end
    for _, item in ipairs(items) do
        doPlayerAddItem(cid, item[1], item[2], true)
    end
end

local function loadJson(cid, query, what)
    local resultId = db.storeQuery(query)
    if (not resultId) then
        return nil
    end
    local raw = result.getDataString(resultId, "data")
    result.free(resultId)
    local ok, state = pcall(JSON.decode, raw)
    if (not ok or type(state) ~= "table") then
        log(LOG_TYPES.ERROR, what .. " - invalid saved state: " .. tostring(raw):sub(1, 200), getCreatureName(cid))
        return nil
    end
    return state
end

local function execute(cid, query, what)
    if (not db.executeQuery(query)) then
        log(LOG_TYPES.ERROR, what .. " - saving failed.", getCreatureName(cid))
        return false
    end
    return true
end

-- Shared by the task boards: rows of `player_task_boards` are keyed by character and board.
TaskBoards = {
    rewardJson = rewardJson,
    giveReward = giveReward,
    secondsUntilMidnight = secondsUntilMidnight,
}

function TaskBoards.save(cid, board, period, state)
    return execute(cid, string.concat("REPLACE INTO `player_task_boards` (`player_id`, `board`, `period`, `data`, `updated_at`) VALUES (",
        getPlayerGUID(cid), ", ", db.escapeString(board), ", ", db.escapeString(period), ", ",
        db.escapeString(JSON.encode(state)), ", ", os.time(), ")"), "TaskBoards " .. board)
end

function TaskBoards.load(cid, board)
    return loadJson(cid, string.concat("SELECT `data` FROM `player_task_boards` WHERE `player_id` = ", getPlayerGUID(cid),
        " AND `board` = ", db.escapeString(board)), "TaskBoards " .. board)
end

-- The difficulties for the client's picker: which the trainer's level allows.
function TaskBoards.difficultiesJson(cid)
    local level = getPlayerLevel(cid)
    local list = {}
    for id, difficulty in ipairs(TASK_DIFFICULTIES) do
        list[id] = { id = id, name = difficulty.name, minLevel = difficulty.minLevel,
                     available = level >= difficulty.minLevel,
                     huntLevels = { difficulty.huntLevels[1], difficulty.huntLevels[2] } }
    end
    return JSON.array(list)
end

-- The highest difficulty the trainer's level allows, suggested by the picker.
function TaskBoards.suggestedDifficulty(cid)
    local level, best = getPlayerLevel(cid), 1
    for id, difficulty in ipairs(TASK_DIFFICULTIES) do
        if (level >= difficulty.minLevel) then
            best = id
        end
    end
    return best
end

-- Whether the trainer may pick this difficulty; tells them why not.
function TaskBoards.canPick(cid, id)
    local difficulty = TASK_DIFFICULTIES[id]
    if (not difficulty) then
        doPlayerSendCancel(cid, "Pick one of the listed difficulties.")
        return false
    elseif (getPlayerLevel(cid) < difficulty.minLevel) then
        doPlayerSendCancel(cid, string.format(__L(cid, "%s tasks need trainer level %d."), difficulty.name,
            difficulty.minLevel))
        return false
    end
    return true
end

--[[ A board of tasks that renews every period. config:
    taskCount      tasks per period
    period()       the current period's key; a new key starts a new period
    secondsLeft()  until the next period
    countScale     multiplies KINDS counts
    moneyScale     multiplies the difficulty's money reward
    itemScale      multiplies the difficulty's reward item counts
    bonusKey       the TASK_DIFFICULTIES field with the all-done bonus
    freeReroll     the reroll costs nothing
    load(cid), save(cid, state)
    send(cid, json)
    text           player messages
]]
local function newBoard(config)
    local board = {}
    board.TASK_COUNT = config.taskCount
    local cache = {} -- player guid -> state

    local function newTask(kindName, difficulty)
        local kind = KINDS[kindName]
        local tier = TASK_DIFFICULTIES[difficulty]
        local task = { kind = kindName, target = kind.counts[difficulty] * config.countScale, progress = 0, claimed = false }
        if (kind.typed) then
            task.type = COMMON_TYPES[math.random(#COMMON_TYPES)]
        end
        local item = tier.items[math.random(#tier.items)]
        task.money = math.floor(tier.money * kind.weight * config.moneyScale / 100) * 100
        task.item = { item[1], item[2] * config.itemScale }
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

    -- a new period has no tasks until the trainer picks its difficulty
    local function newPeriod()
        return { day = config.period(), tasks = {}, rerolled = false, bonusClaimed = false }
    end

    local function rerollCost(state)
        return config.freeReroll and 0 or TASK_DIFFICULTIES[state.difficulty].rerollCost
    end

    -- The state for this period.
    function board.get(cid)
        local guid = getPlayerGUID(cid)
        local state = cache[guid]
        if (not state) then
            state = config.load(cid)
            if (state and type(state.tasks) ~= "table") then
                state = nil
            end
            if (state and not state.difficulty and state.band and #state.tasks > 0) then
                state.difficulty = OLD_BAND_DIFFICULTY[state.band] or 1
            end
        end
        if (not state or state.day ~= config.period()) then
            state = newPeriod()
            config.save(cid, state)
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

    function board.send(cid)
        local state = board.get(cid)
        local data = {
            resetsIn = config.secondsLeft(),
            difficulties = TaskBoards.difficultiesJson(cid),
            suggested = TaskBoards.suggestedDifficulty(cid),
        }
        local tasks = {}
        if (state.difficulty) then
            local bonus = TASK_DIFFICULTIES[state.difficulty][config.bonusKey]
            local allClaimed = true
            for slot, task in ipairs(state.tasks) do
                tasks[slot] = { slot = slot, title = taskTitle(cid, task), progress = math.min(task.progress, task.target),
                                target = task.target, claimed = task.claimed, reward = rewardJson(task.money, { task.item }) }
                allClaimed = allClaimed and task.claimed
            end
            data.difficulty = state.difficulty
            data.reroll = { available = not state.rerolled, cost = rerollCost(state) }
            data.bonus = { ready = allClaimed and not state.bonusClaimed, claimed = state.bonusClaimed,
                           reward = rewardJson(bonus.money, bonus.items) }
        else
            -- clients from before difficulties read these on every message
            data.reroll = { available = false, cost = 0 }
            data.bonus = { ready = false, claimed = false, reward = rewardJson(0, {}) }
        end
        data.tasks = JSON.array(tasks)
        config.send(cid, data)
    end

    -- Picks this period's difficulty and with it the tasks.
    function board.start(cid, difficulty)
        local state = board.get(cid)
        if (state.difficulty) then
            doPlayerSendCancel(cid, __L(cid, config.text.locked))
            return false
        elseif (not TaskBoards.canPick(cid, difficulty)) then
            return false
        end
        local level = getPlayerLevel(cid)
        state.difficulty = difficulty
        for slot = 1, config.taskCount do
            state.tasks[slot] = newTask(pickKind(state, level) or KIND_NAMES[math.random(#KIND_NAMES)], difficulty)
        end
        config.save(cid, state)
        board.send(cid)
        return true
    end

    local function matches(task, info)
        if (not KINDS[task.kind].typed) then
            return true
        end
        return info and info.name and table.find(getPokemonTypes(nil, info.name) or {}, task.type) ~= nil
    end

    -- A trainer did something a task may count: event is one of the KINDS events.
    function board.onEvent(cid, event, info)
        if (not isPlayer(cid)) then
            return
        end
        local state = board.get(cid)
        local changed = false
        for _, task in ipairs(state.tasks) do
            if (KINDS[task.kind].event == event and not isComplete(task) and matches(task, info)) then
                task.progress = task.progress + 1
                changed = true
                if (isComplete(task)) then
                    doPlayerSendTextMessage(cid, MESSAGE_EVENT_ADVANCE, string.format(
                        __L(cid, config.text.complete), taskTitle(cid, task)))
                end
            end
        end
        if (changed) then
            config.save(cid, state)
            board.send(cid)
        end
    end

    function board.onDefeated(cid, target)
        if (PokemonStats.isWildPokemon(target)) then
            board.onEvent(cid, "defeat", { name = getCreatureName(target) })
        end
    end

    function board.claim(cid, slot)
        local state = board.get(cid)
        local task = state.tasks[slot]
        if (not task or task.claimed or not isComplete(task)) then
            doPlayerSendCancel(cid, "This task is not complete yet.")
            return false
        end
        task.claimed = true
        config.save(cid, state)
        giveReward(cid, task.money, { task.item })
        doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, string.format(
            __L(cid, "You claimed the reward for '%s'."), taskTitle(cid, task)))
        doSendMagicEffect(getCreaturePosition(cid), EFFECT_EMOTION_HAPPY)
        board.send(cid)
        return true
    end

    function board.claimBonus(cid)
        local state = board.get(cid)
        if (not state.difficulty) then
            return false
        end
        for _, task in ipairs(state.tasks) do
            if (not task.claimed) then
                doPlayerSendCancel(cid, __L(cid, config.text.claimAllFirst))
                return false
            end
        end
        if (state.bonusClaimed) then
            doPlayerSendCancel(cid, __L(cid, config.text.bonusTaken))
            return false
        end
        state.bonusClaimed = true
        config.save(cid, state)
        local bonus = TASK_DIFFICULTIES[state.difficulty][config.bonusKey]
        giveReward(cid, bonus.money, bonus.items)
        doPlayerSendTextMessage(cid, MESSAGE_EVENT_ADVANCE, __L(cid, config.text.bonus))
        board.send(cid)
        return true
    end

    function board.reroll(cid, slot)
        local state = board.get(cid)
        local task = state.tasks[slot]
        if (not task or task.claimed or isComplete(task)) then
            doPlayerSendCancel(cid, "Only an unfinished task can be rerolled.")
            return false
        end
        local cost = rerollCost(state)
        if (state.rerolled) then
            doPlayerSendCancel(cid, __L(cid, config.text.rerollTaken))
            return false
        elseif (cost > 0 and (getPlayerMoney(cid) < cost or not doPlayerRemoveMoney(cid, cost))) then
            doPlayerSendCancel(cid, string.format(__L(cid, "A reroll costs %d dollars."), cost))
            return false
        end
        state.rerolled = true
        state.tasks[slot] = newTask(pickKind(state, getPlayerLevel(cid), task.kind) or task.kind, state.difficulty)
        config.save(cid, state)
        board.send(cid)
        return true
    end

    -- Staff tools (reset, progress <slot> <count>). The server reads the tables only through its
    -- own connection, which may not see changes made from outside while it runs, so fix a
    -- character's tasks with these instead of editing the tables. A reset clears the difficulty.
    function board.reset(cid)
        local state = newPeriod()
        cache[getPlayerGUID(cid)] = state
        config.save(cid, state)
        board.send(cid)
    end

    function board.setProgress(cid, slot, count)
        local state = board.get(cid)
        local task = state.tasks[slot]
        if (not task) then
            return false
        end
        task.progress = math.max(0, math.min(count, task.target))
        config.save(cid, state)
        board.send(cid)
        return true
    end

    function board.onLogin(cid)
        cache[getPlayerGUID(cid)] = nil
        board.send(cid)
    end

    function board.onLogout(cid)
        cache[getPlayerGUID(cid)] = nil
    end

    return board
end

DailyTasks = newBoard({
    taskCount = 3,
    period = function() return os.date("%Y-%m-%d") end,
    secondsLeft = secondsUntilMidnight,
    countScale = 1, moneyScale = 1, itemScale = 1,
    bonusKey = "bonus",
    load = function(cid)
        return loadJson(cid, string.concat("SELECT `data` FROM `player_daily_tasks` WHERE `player_id` = ",
            getPlayerGUID(cid)), "DailyTasks")
    end,
    save = function(cid, state)
        return execute(cid, string.concat("REPLACE INTO `player_daily_tasks` (`player_id`, `day`, `data`, `updated_at`) VALUES (",
            getPlayerGUID(cid), ", ", db.escapeString(state.day), ", ", db.escapeString(JSON.encode(state)), ", ",
            os.time(), ")"), "DailyTasks")
    end,
    send = function(cid, data)
        doSendPlayerExtendedOpcode(cid, EXTENDED_IDS.DAILY_TASKS, JSON.encode(data))
    end,
    text = {
        complete = "Daily task complete: %s! Open Tasks to claim your reward.",
        claimAllFirst = "Claim all three daily tasks first.",
        bonusTaken = "You already claimed today's bonus.",
        bonus = "All daily tasks done! You received the daily bonus. New tasks arrive at midnight.",
        rerollTaken = "You already rerolled a task today.",
        locked = "Today's difficulty is set. Pick again after midnight.",
    },
})

WeeklyTasks = newBoard({
    taskCount = 5,
    period = thisMonday,
    secondsLeft = secondsUntilMonday,
    countScale = 5, moneyScale = 4, itemScale = 3,
    bonusKey = "weeklyBonus",
    freeReroll = true,
    load = function(cid) return TaskBoards.load(cid, "weekly") end,
    save = function(cid, state) return TaskBoards.save(cid, "weekly", state.day, state) end,
    send = function(cid, data)
        data.board = "weekly"
        doSendPlayerExtendedOpcode(cid, EXTENDED_IDS.TASK_BOARDS, JSON.encode(data))
    end,
    text = {
        complete = "Weekly task complete: %s! Open Tasks to claim your reward.",
        claimAllFirst = "Claim all five weekly tasks first.",
        bonusTaken = "You already claimed this week's bonus.",
        bonus = "All weekly tasks done! You received the weekly bonus. New tasks arrive on Monday.",
        rerollTaken = "You already rerolled a task this week.",
        locked = "This week's difficulty is set. Pick again on Monday.",
    },
})

-- at midnight, online trainers get their new tasks without having to do anything; the
-- timer survives /reload (the event keeps the first version of the function)
local function onMidnight()
    for _, cid in ipairs(getPlayersOnline()) do
        DailyTasks.send(cid)
        WeeklyTasks.send(cid)
    end
    addEvent(onMidnight, secondsUntilMidnight() * 1000 + 1000)
end
if (not DAILY_TASKS_MIDNIGHT_SCHEDULED) then
    DAILY_TASKS_MIDNIGHT_SCHEDULED = true
    addEvent(onMidnight, secondsUntilMidnight() * 1000 + 1000)
end
