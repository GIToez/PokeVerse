-- TEST ONLY - never part of the game data or any package.
-- scripts/test-server-linux.sh copies this file into a temporary server directory to
-- drive real game code paths (monster death, corpse, ball throw, catch) from the
-- Discord bridge integration test.
--
--   /bridgetest catch <pokemon>  real kill + ultra ball throw; catch boost so it succeeds
--   /bridgetest miss <pokemon>   real kill + ultra ball throw without boost (fresh trainers always miss)
--   /bridgetest spawn <monster>  creates a wild monster through doCreateMonster

local function isFree(cid, pos)
    local info = getTileInfo(pos)
    return info and not info.protection and not info.house and doTileQueryAdd(cid, pos) == RETURNVALUE_NOERROR
end

-- Finds a free non-protection tile with a free tile to its east.
local function findArena(cid)
    local origin = getCreaturePosition(cid)
    for radius = 1, 30 do
        for dx = -radius, radius do
            for dy = -radius, radius do
                local a = {x = origin.x + dx, y = origin.y + dy, z = origin.z}
                local b = {x = a.x + 1, y = a.y, z = a.z}
                if (isFree(cid, a) and isFree(cid, b)) then
                    return a, b
                end
            end
        end
    end
    return nil
end

local function throwBall(cid, pos)
    if (not isPlayer(cid)) then
        return
    end
    local corpse = getTileItemByType(pos, ITEM_TYPE_CONTAINER)
    if (not isItem(corpse)) then
        doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "bridgetest: no corpse")
        return
    end
    local itemid = balls["ultra"].empty
    local ball = doPlayerAddItem(cid, itemid, 1)
    emptyBall(cid, {uid = ball, itemid = itemid}, getThingPosition(ball), corpse, pos)
    doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "bridgetest: ball thrown")
end

function onSay(cid, words, param, channel)
    local action, name = param:match("^(%a+)%s+(.+)$")
    if (not action) then
        doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "bridgetest: usage catch|miss|spawn <name>")
        return true
    end

    local playerPos, monsterPos = findArena(cid)
    if (not playerPos) then
        doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "bridgetest: no free tiles")
        return true
    end
    doTeleportThing(cid, playerPos, false)

    if (action == "spawn") then
        local m = doCreateMonster(name, monsterPos, false)
        doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "bridgetest: spawned " .. tostring(isMonster(m)))
        return true
    end

    setPlayerExtraCatchRateTime(cid, action == "catch" and os.time() + 600 or 0)
    setPlayerExtraCatchRateValue(cid, action == "catch" and math.max(getPokemonCatchChance(name) - 1, 0) or 0)

    local m = doCreateMonster(name, monsterPos, false)
    if (not isMonster(m)) then
        doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "bridgetest: can't create " .. name)
        return true
    end
    doTargetCombatHealth(cid, m, COMBAT_PHYSICALDAMAGE, -10000000, -10000000, CONST_ME_NONE)
    addEvent(throwBall, 500, cid, monsterPos)
    return true
end
