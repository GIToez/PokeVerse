-- Daily login calendar: a reward for each day in a row the trainer claims it, the biggest on day 7,
-- then it starts over at day 1. A missed day starts it over too. Days turn over at midnight in the
-- server's time zone, like the daily tasks.
--
-- Progress is two player storages (loginStreak, loginStreakDay), so every Lua environment sees the
-- same values. The client's calendar window (game_dailylogin) sends "/tasks login [claim]" and
-- draws the EXTENDED_IDS.DAILY_LOGIN JSON that comes back.

local DAYS = {
    { items = { { 12157, 10 } } }, -- empty poke balls
    { items = { { 12244, 5 } } }, -- pokemon health potions
    { money = 1000 },
    { items = { { 12161, 10 } } }, -- empty great balls
    { items = { { 12245, 3 } } }, -- great health potions
    { items = { { 12248, 2 } } }, -- pokemon revives
    { items = { { 14463, 1 } } }, -- rare candy
}

DailyLogin = {}

-- noon of today keeps daylight saving changes away from the day boundary
local function dayNumber()
    local now = os.date("*t")
    return math.floor(os.time({ year = now.year, month = now.month, day = now.day, hour = 12 }) / 86400)
end

-- days already done in the current round, whether today's is one of them, and whether a round
-- in progress was lost to a missed day
local function progress(cid)
    local today = dayNumber()
    local last = getCreatureStorage(cid, playersStorages.loginStreakDay)
    local done = math.max(getCreatureStorage(cid, playersStorages.loginStreak), 0)
    if (last == today) then
        return done, true, false
    elseif (last == today - 1 and done < #DAYS) then
        return done, false, false
    end
    return 0, false, done > 0 and done < #DAYS
end

local function rewardText(reward)
    local parts = {}
    if ((reward.money or 0) > 0) then
        parts[#parts + 1] = string.format("$%d", reward.money)
    end
    for _, item in ipairs(reward.items or {}) do
        parts[#parts + 1] = string.format("%d %s", item[2],
            item[2] > 1 and getItemPluralNameById(item[1]) or getItemNameById(item[1]))
    end
    return table.concat(parts, ", ")
end

function DailyLogin.send(cid)
    local done, claimedToday, missed = progress(cid)
    local days = {}
    for day, reward in ipairs(DAYS) do
        days[day] = { day = day, reward = TaskBoards.rewardJson(reward.money or 0, reward.items or {}) }
    end
    doSendPlayerExtendedOpcode(cid, EXTENDED_IDS.DAILY_LOGIN, JSON.encode({
        days = JSON.array(days),
        done = done,
        claimedToday = claimedToday,
        missed = missed,
        resetsIn = TaskBoards.secondsUntilMidnight(),
    }))
end

function DailyLogin.claim(cid)
    local done, claimedToday = progress(cid)
    if (claimedToday) then
        doPlayerSendCancel(cid, __L(cid, "You already claimed today's login reward. Come back tomorrow!"))
        DailyLogin.send(cid)
        return false
    end
    local day = done + 1
    local reward = DAYS[day]
    TaskBoards.giveReward(cid, reward.money or 0, reward.items or {})
    doCreatureSetStorage(cid, playersStorages.loginStreak, day)
    doCreatureSetStorage(cid, playersStorages.loginStreakDay, dayNumber())
    if (day == #DAYS) then
        doPlayerSendTextMessage(cid, MESSAGE_EVENT_ADVANCE, string.format(
            __L(cid, "Day %d in a row! You received %s. The calendar starts over tomorrow."), day, rewardText(reward)))
    else
        doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, string.format(
            __L(cid, "Login reward, day %d of %d: %s. Come back tomorrow for day %d."), day, #DAYS,
            rewardText(reward), day + 1))
    end
    DailyLogin.send(cid)
    return true
end

-- Staff test tools: as if this many days were claimed by yesterday, or nothing claimed yet.
function DailyLogin.setStreak(cid, days)
    doCreatureSetStorage(cid, playersStorages.loginStreak, math.max(0, math.min(days or 0, #DAYS)))
    doCreatureSetStorage(cid, playersStorages.loginStreakDay, dayNumber() - 1)
    DailyLogin.send(cid)
end

function DailyLogin.reset(cid)
    doCreatureSetStorage(cid, playersStorages.loginStreak, -1)
    doCreatureSetStorage(cid, playersStorages.loginStreakDay, -1)
    DailyLogin.send(cid)
end

function DailyLogin.onLogin(cid)
    DailyLogin.send(cid)
end
