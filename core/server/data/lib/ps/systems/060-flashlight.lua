-- The flashlight lights up the player while it is in the key item slot; its items.otb entry has no light of its own.
Flashlight = {
    ITEM_ID = 13219,
    LIGHT_LEVEL = 8,
    LIGHT_COLOR = 215,
}

local flashlightCondition = createConditionObject(CONDITION_LIGHT, -1)
setConditionParam(flashlightCondition, CONDITION_PARAM_LIGHT_LEVEL, Flashlight.LIGHT_LEVEL)
setConditionParam(flashlightCondition, CONDITION_PARAM_LIGHT_COLOR, Flashlight.LIGHT_COLOR)
setConditionParam(flashlightCondition, CONDITION_PARAM_TICKS, -1)

function Flashlight.isEquipped(cid)
    return getPlayerSlotItem(cid, PLAYER_SLOT_KEY_ITEM).itemid == Flashlight.ITEM_ID
end

-- Given like the starting kit, straight into the key item slot when it is free.
function Flashlight.give(cid)
    local uid = doPlayerAddItem(cid, Flashlight.ITEM_ID, 1, false)
    if (not uid) then
        return false
    end

    if (getPlayerSlotItem(cid, PLAYER_SLOT_KEY_ITEM).uid == 0) then
        doMovePlayerItem(cid, uid, {x = 65535, y = PLAYER_SLOT_KEY_ITEM, z = 0})
    end
    doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, string.format(__L(cid, "You received %sx %s."), 1, getItemNameById(Flashlight.ITEM_ID)))
    return true
end

-- Equip events also fire while the server only checks whether an item fits the slot, so the light follows what is
-- really in the slot once the move has finished.
function Flashlight.update(cid)
    addEvent(function()
        if (not isPlayer(cid)) then
            return
        end

        if (Flashlight.isEquipped(cid)) then
            doAddCondition(cid, flashlightCondition)
        else
            doRemoveCondition(cid, CONDITION_LIGHT)
        end
    end, 0)
end
