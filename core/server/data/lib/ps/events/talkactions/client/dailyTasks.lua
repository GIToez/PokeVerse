-- Sent by the client's Daily Tasks window: "" (state), "claim <slot>", "bonus", "reroll <slot>".
-- Gods also have "reset" (new tasks now) and "progress <slot> <count>".
local STAFF_ACCESS = 5

function onSay(cid, words, param)
    local action, slot, count = (param or ""):match("^%s*(%a*)%s*(%d*)%s*(%d*)%s*$")
    slot, count = tonumber(slot), tonumber(count)
    local staff = getPlayerAccess(cid) >= STAFF_ACCESS
    if (staff and action == "reset") then
        DailyTasks.reset(cid)
    elseif (staff and action == "progress" and slot and count) then
        DailyTasks.setProgress(cid, slot, count)
    elseif (action == "claim" and slot) then
        DailyTasks.claim(cid, slot)
    elseif (action == "bonus") then
        DailyTasks.claimBonus(cid)
    elseif (action == "reroll" and slot) then
        DailyTasks.reroll(cid, slot)
    else
        DailyTasks.send(cid)
    end
    return true
end
