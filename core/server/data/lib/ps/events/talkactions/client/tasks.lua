-- Sent by the client's Tasks window: "/tasks <board> [action ...]".
--   daily | weekly: "" (state), "start <difficulty>", "claim <slot>", "bonus", "reroll <slot>"
--   hunting: "" (state), "difficulty <id>", "take <offer> <size>", "claim <slot>", "cancel <slot>", "refresh", "buy <item>"
-- Gods also have "reset" and "progress <slot> <count>" on every board, "points <count>" on hunting,
-- and for tests "kind <slot> <kind>" on daily and weekly and "hook <count>" (hooks Pokemon the way
-- fishing does, through the statistic).
local STAFF_ACCESS = 5

local function periodic(board, cid, staff, action, a, b)
    if (staff and action == "reset") then
        board.reset(cid)
    elseif (staff and action == "progress" and a and tonumber(b)) then
        board.setProgress(cid, a, b)
    elseif (staff and action == "kind" and a and b) then
        board.setKind(cid, a, b)
    elseif (action == "start" and a) then
        board.start(cid, a)
    elseif (action == "claim" and a) then
        board.claim(cid, a)
    elseif (action == "bonus") then
        board.claimBonus(cid)
    elseif (action == "reroll" and a) then
        board.reroll(cid, a)
    else
        board.send(cid)
    end
end

local function hunting(cid, staff, action, a, b)
    if (staff and action == "reset") then
        HuntingTasks.reset(cid)
    elseif (staff and action == "progress" and a and tonumber(b)) then
        HuntingTasks.setProgress(cid, a, b)
    elseif (staff and action == "points" and a) then
        HuntingTasks.setPoints(cid, a)
    elseif (action == "difficulty" and a) then
        HuntingTasks.setDifficulty(cid, a)
    elseif (action == "take" and a and tonumber(b)) then
        HuntingTasks.take(cid, a, b)
    elseif (action == "claim" and a) then
        HuntingTasks.claim(cid, a)
    elseif (action == "cancel" and a) then
        HuntingTasks.cancel(cid, a)
    elseif (action == "refresh") then
        HuntingTasks.refresh(cid)
    elseif (action == "buy" and a) then
        HuntingTasks.buy(cid, a)
    else
        HuntingTasks.send(cid)
    end
end

function onSay(cid, words, param)
    local board, action, a, b = (param or ""):lower():match("^%s*(%a*)%s*(%a*)%s*(%d*)%s*(%w*)%s*$")
    if (not board) then
        return true
    end
    a, b = tonumber(a), tonumber(b) or (b ~= "" and b or nil)
    local staff = getPlayerAccess(cid) >= STAFF_ACCESS
    if (staff and board == "hook") then
        for _ = 1, math.min(a or 0, 50) do
            doPlayerAddStatistic(cid, PLAYER_STATISTIC_IDS.HOOKED_FISH, 1)
        end
    elseif (board == "daily") then
        periodic(DailyTasks, cid, staff, action, a, b)
    elseif (board == "weekly") then
        periodic(WeeklyTasks, cid, staff, action, a, b)
    elseif (board == "hunting") then
        hunting(cid, staff, action, a, b)
    else
        DailyTasks.send(cid)
        WeeklyTasks.send(cid)
        HuntingTasks.send(cid)
    end
    return true
end
