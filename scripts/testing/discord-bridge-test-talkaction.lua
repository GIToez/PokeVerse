-- TEST ONLY - never part of the game data or any package.
-- scripts/test-server-linux.sh copies this file into a temporary server directory to
-- drive real game code paths (monster death, corpse, ball throw, catch) from the
-- Discord bridge integration test.
--
--   /bridgetest catch <pokemon>  real kill + ultra ball throw; catch boost so it succeeds
--   /bridgetest miss <pokemon>   real kill + ultra ball throw without boost (fresh trainers always miss)
--   /bridgetest spawn <monster>  creates a wild monster through doCreateMonster
--   /bridgetest perks            the Discord server boost perks as the game code applies them (JSON)
--   /bridgetest killexp <pokemon> real kill; replies with the trainer experience it gave

local function isFree(cid, pos)
    -- getTileInfo logs an error for positions without a tile.
    local ground = getTileThingByPos({x = pos.x, y = pos.y, z = pos.z, stackpos = 0})
    if (not ground or ground.itemid == 0) then
        return false
    end
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

local function throwBall(cid, pos, tries)
    if (not isPlayer(cid)) then
        return
    end
    local corpse = getTileItemByType(pos, ITEM_TYPE_CONTAINER)
    if (not isItem(corpse)) then
        -- the death (and its corpse) can come a moment later when the server is busy
        if ((tries or 0) < 10) then
            addEvent(throwBall, 500, cid, pos, (tries or 0) + 1)
        else
            doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "bridgetest: no corpse")
        end
        return
    end
    local itemid = balls["ultra"].empty
    local ball = doPlayerAddItem(cid, itemid, 1)
    emptyBall(cid, {uid = ball, itemid = itemid}, getThingPosition(ball), corpse, pos)
    doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "bridgetest: ball thrown")
end

local function reply(cid, text)
    doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, text)
end

local function catchRate(chance, trials)
    local caught = 0
    for _ = 1, trials do
        if (math.random() < chance or DiscordBoostPerks.catchBonusRoll(chance)) then
            caught = caught + 1
        end
    end
    return caught / trials
end

local function perks(cid)
    local p = getDiscordBoostPerks()
    reply(cid, "bridgetest perks " .. JSON.encode({level = p.level, exp = p.exp, catch = p.catch, shiny = p.shiny,
        catch40 = DiscordBoostPerks.catchChance(0.4), catch99 = DiscordBoostPerks.catchChance(0.99),
        catch100 = DiscordBoostPerks.catchChance(1), catchRolled40 = catchRate(0.4, 200000),
        shiny4096 = ShinyEvent.chance(4096), describe = DiscordBoostPerks.describe() or ""}))
end

local function reportExp(cid, before)
    if (isPlayer(cid)) then
        reply(cid, "bridgetest killexp " .. (getPlayerExperience(cid) - before))
    end
end

function onSay(cid, words, param, channel)
    if (param == "perks") then
        perks(cid)
        return true
    end
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

    if (action == "killexp") then
        local m = doCreateMonster(name, monsterPos, false)
        if (not isMonster(m)) then
            reply(cid, "bridgetest: can't create " .. name)
            return true
        end
        -- Same experience for every kill: a fixed monster level, and a trainer in the flat level
        -- 31-50 stage that one kill can't level up.
        setMonsterLevel(m, 10)
        if (getPlayerLevel(cid) < 40) then
            doPlayerAddExperience(cid, getExperienceForLevel(40) - getPlayerExperience(cid))
        end
        local before = getPlayerExperience(cid)
        doTargetCombatHealth(cid, m, COMBAT_PHYSICALDAMAGE, -10000000, -10000000, CONST_ME_NONE)
        addEvent(reportExp, 1000, cid, before)
        return true
    end

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
    -- doCreateMonster may place it next to monsterPos when that tile is taken
    local corpsePos = getCreaturePosition(m)
    doTargetCombatHealth(cid, m, COMBAT_PHYSICALDAMAGE, -10000000, -10000000, CONST_ME_NONE)
    addEvent(throwBall, 500, cid, corpsePos)
    return true
end
