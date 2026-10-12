-- Sent by the client's Daily Tasks window: "" (state), "claim <slot>", "bonus", "reroll <slot>".
function onSay(cid, words, param)
    local action, slot = (param or ""):match("^%s*(%a*)%s*(%d*)%s*$")
    slot = tonumber(slot)
    if (action == "claim" and slot) then
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
