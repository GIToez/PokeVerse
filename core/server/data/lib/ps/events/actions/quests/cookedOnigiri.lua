local QUEST_STORAGE = 8459

local REQUIRED_FOOD = 2

-- Brock and Salvadore aren't fed: Brock is at the gym and Salvadore is the cook
local NOT_HUNGRY = {
    ["Brock"] = "Brock is busy at the gym. Feed his brothers and sisters at home.",
    ["Brockling Salvadore"] = "Salvadore is the cook. Feed his brothers and sisters.",
}

function onUse(cid, item, fromPosition, itemEx, toPosition)
    if (getCreatureStorage(cid, QUEST_STORAGE) == QUEST_STATUS.FINISHED and not isNpc(itemEx.uid)) then
        return PokemonFood.onUse(cid, item, fromPosition, itemEx, toPosition)
    end

    if (getDistanceBetween(getCreaturePosition(cid), toPosition) > 4) then
        doPlayerSendDefaultCancel(cid, RETURNVALUE_TOOFARAWAY)
        return true
    end

    local name = isNpc(itemEx.uid) and getCreatureName(itemEx.uid)
    if (getCreatureStorage(cid, QUEST_STORAGE) ~= QUEST_STATUS.STARTED or not name or
            not (Brocklings.FOOD[name] or NOT_HUNGRY[name])) then
        doPlayerSendDefaultCancel(cid, RETURNVALUE_NOTPOSSIBLE)
        return true
    end

    if (NOT_HUNGRY[name]) then
        doPlayerSendTextMessage(cid, MESSAGE_EVENT_ADVANCE, __L(cid, NOT_HUNGRY[name]) .. " " .. Brocklings.hungryText(cid))
        return true
    end

    if (Brocklings.fed(cid, name) >= REQUIRED_FOOD) then
        doPlayerSendTextMessage(cid, MESSAGE_EVENT_ADVANCE, __L(cid, "This Brockling is fed.") .. " " .. Brocklings.hungryText(cid))
        return true
    end

    local count = doCreatureIncreaseStorage(cid, Brocklings.FOOD[name])
    local text = string.format(__L(cid, "%s fed [%s/%s]."), name, count, REQUIRED_FOOD)
    if (count >= REQUIRED_FOOD) then
        text = text .. " " .. Brocklings.hungryText(cid)
    end
    doPlayerSendTextMessage(cid, MESSAGE_EVENT_ADVANCE, text)

    doSendDistanceShoot(getCreaturePosition(cid), toPosition, PROJECTILE_GRAVEL)
    doSendMagicEffect(toPosition, EFFECT_EMOTION_HAPPY)
    doRemoveItem(item.uid, 1)

    return true
end
