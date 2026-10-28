-- /warpstyle <style> <trigger>: plays a Warp Style on yourself, for staff testing (lib/ps/systems/102-warpStyles.lua).
-- /warpstyle alone lists them. Warps play their leaving half and then their arriving half.
function onSay(cid, words, param, channel)
    local style, trigger = param:match("^%s*(%a+)%s+(%a+)%s*$")
    local styles, triggers = {}, {}
    for _, s in ipairs(WarpStyles.STYLES) do
        styles[#styles + 1] = s.id
    end
    for _, t in ipairs(WarpStyles.TRIGGERS) do
        triggers[#triggers + 1] = t.id
    end
    if (not style) then
        doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, string.format("Usage: %s <style> <trigger>. Styles: %s. Triggers: %s.",
            words, table.concat(styles, ", "), table.concat(triggers, ", ")))
        return true
    end
    -- warps play through the Teleport slot: both halves on the spot
    local warp = (trigger == "login" or trigger == "logout" or trigger == "teleport")
    local slot = warp and "teleport" or trigger
    local before = WarpStyles.equipped(cid, slot)
    if (not before or not WarpStyles.equip(cid, slot, style)) then
        doPlayerSendCancel(cid, "That style doesn't go in that slot.")
        return true
    end
    if (warp) then
        local pos = getCreaturePosition(cid)
        WarpStyles.play(cid, "teleport", pos, pos)
    else
        WarpStyles.play(cid, trigger)
    end
    WarpStyles.equip(cid, slot, before)
    return true
end
