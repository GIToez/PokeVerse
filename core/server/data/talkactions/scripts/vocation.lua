-- Staff test tool for the vocation window until the vocation quest line opens it:
--   /vocation                 open the window (choosing still needs trainer level 20)
--   /vocation reset           back to a regular Trainer
--   /vocation Trainer         open it for another online player
--   /vocation Trainer,reset
function onSay(cid, words, param, channel)
    local args = string.explode(param, ",")
    local target = cid
    if (args[1] and args[1]:trim() ~= "" and args[1]:trim():lower() ~= "reset") then
        target = getPlayerByName(args[1]:trim())
        if (not target) then
            doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Player not found.")
            return true
        end
        table.remove(args, 1)
    end

    if (args[1] and args[1]:trim():lower() == "reset") then
        Vocations.reset(target)
        doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, getCreatureName(target) .. " is a regular Trainer again.")
        return true
    end

    local vocation = Vocations.get(target)
    doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, getCreatureName(target) .. ": "
        .. (vocation and vocation.name or "regular Trainer") .. ".")
    Vocations.open(target)
    return true
end
