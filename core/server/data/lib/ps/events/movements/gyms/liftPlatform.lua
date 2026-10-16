-- Gym lifts: a wooden platform that carries players a floor up (actionid 46001) to the tile north of
-- it, or a floor down (actionid 46002) to the tile south of it.
local LIFTS = {
    [46001] = { dy = -1, dz = -1, text = "The lift carries you up." },
    [46002] = { dy = 1, dz = 1, text = "The lift carries you down." },
}

function onStepIn(cid, item, position, lastPosition, fromPosition, toPosition, actor)
    if (not isPlayer(cid) or isPlayerGhost(cid, true)) then
        return true
    end

    local lift = LIFTS[item.actionid]
    if not lift then
        return true
    end

    local to = { x = position.x, y = position.y + lift.dy, z = position.z + lift.dz }
    if not isWalkable(cid, to) then
        return true
    end

    doSendMagicEffect(position, EFFECT_TELEPORT)
    doTeleportThing(cid, to, false)
    doSendMagicEffect(to, EFFECT_TELEPORT)
    doPlayerSendCancel(cid, lift.text)
    return true
end
