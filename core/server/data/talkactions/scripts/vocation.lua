-- Staff test tool for vocations until the vocation quest line opens the window:
--   /vocation                 show the vocation and rank, and open the window (choosing still needs level 20)
--   /vocation reset           back to a regular Trainer
--   /vocation rank,3          set the rank (1-5) without the level or the trial
--   /vocation Trainer         the same for another online player: /vocation Trainer,reset, /vocation Trainer,rank,3
function onSay(cid, words, param, channel)
    local args = string.explode(param, ",")
    for i, arg in ipairs(args) do
        args[i] = arg:trim()
    end
    local target = cid
    local first = args[1] and args[1]:lower() or ""
    if (first ~= "" and first ~= "reset" and first ~= "rank") then
        target = getPlayerByName(args[1])
        if (not target) then
            doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Player not found.")
            return true
        end
        table.remove(args, 1)
    end
    local action = args[1] and args[1]:lower() or ""

    if (action == "reset") then
        Vocations.reset(target)
        doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, getCreatureName(target) .. " is a regular Trainer again.")
        return true
    elseif (action == "rank") then
        local rank = tonumber(args[2])
        if (not rank or not Vocations.setRank(target, rank)) then
            doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Usage: /vocation rank,1-5 (the trainer needs a vocation).")
            return true
        end
    end

    local vocation = Vocations.get(target)
    doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, getCreatureName(target) .. ": " .. (vocation and
        string.format("%s, %s (rank %d)", vocation.name, Vocations.getTitle(target), Vocations.getRank(target))
        or "regular Trainer") .. ".")
    if (action ~= "rank") then
        Vocations.open(target)
    end
    return true
end
