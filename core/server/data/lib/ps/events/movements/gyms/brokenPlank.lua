-- Cracked gym planks (actionid 46000): they give way under a player, who falls to the first floor
-- below that holds them, and mend themselves after a while. A plank that is still broken drops
-- anyone who steps on it too.
local CRACKED = 9231
local BROKEN = 9232
local MEND_TIME = 8 * 1000
local MAX_FALL = 4

local function landing(cid, position)
    for z = position.z + 1, math.min(position.z + MAX_FALL, 15) do
        local pos = { x = position.x, y = position.y, z = z }
        if isWalkable(cid, pos) then
            return pos
        end
    end
    return nil
end

local function mend(position)
    local plank = getTileItemById(position, BROKEN)
    if isItem(plank) then
        doTransformItem(plank.uid, CRACKED)
        doSendMagicEffect(position, EFFECT_POFF)
    end
end

function onStepIn(cid, item, position, lastPosition, fromPosition, toPosition, actor)
    if (not isPlayer(cid) or isPlayerGhost(cid, true)) then
        return true
    end

    local below = landing(cid, position)
    if not below then
        return true
    end

    if item.itemid == CRACKED then
        doTransformItem(item.uid, BROKEN)
        addEvent(mend, MEND_TIME, { x = position.x, y = position.y, z = position.z })
    end

    doSendMagicEffect(position, EFFECT_POFF)
    doTeleportThing(cid, below, false)
    doSendMagicEffect(below, EFFECT_POFF)
    doPlayerSendCancel(cid, "The plank gave way!")
    return true
end
