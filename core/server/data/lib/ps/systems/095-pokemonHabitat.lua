-- Pokemon Habitat: a house-only stand. You put a charged ball on it and that Pokemon
-- walks the house (houser NPC). The ball stays the same item as in the bag, so a Great
-- Ball still looks like a Great Ball. House tiles + ball_pillars survive a restart.

if (PokemonHabitat) then
    return
end

PokemonHabitat = {}
PokemonHabitat.EMPTY_ID = 18650
PokemonHabitat.LEGACY_FILLED_ID = 18649

local WALKER_NAMES = { "Pillar Model", "Pillar Model Slow", "Pillar Model Fast" }

local function worldId()
    return getConfigValue("worldId")
end

local function posKey(pos)
    return string.format("%d:%d:%d", pos.x, pos.y, pos.z)
end

function PokemonHabitat.ownsHouseTile(cid, pos)
    local houseId = getHouseFromPos(pos)
    if (not houseId) then
        return false
    end
    local info = getHouseInfo(houseId, false)
    if (not info or info.owner == 0) then
        return false
    end
    if (info.guildHall) then
        return info.owner == getPlayerGuildId(cid) and getPlayerGuildLevel(cid) == GUILDLEVEL_LEADER
    end
    return info.owner == getPlayerGUID(cid)
end

function PokemonHabitat.isChargedBall(item)
    return isItem(item) and isBallWithPokemon(item.uid) and ballsNames[item.itemid]
        and item.itemid == balls[ballsNames[item.itemid]].charged
end

function PokemonHabitat.itemOn(pos, pred)
    for stack = 1, 20 do
        local thing = getTileThingByPos({ x = pos.x, y = pos.y, z = pos.z, stackpos = stack })
        if (not thing or thing.uid == 0 or thing.itemid == 0) then
            break
        end
        if (isItem(thing) and pred(thing)) then
            return thing
        end
    end
end

function PokemonHabitat.standOn(pos)
    local stand = PokemonHabitat.itemOn(pos, function(item) return item.itemid == PokemonHabitat.EMPTY_ID end)
        or getTileItemById(pos, PokemonHabitat.EMPTY_ID)
    return isItem(stand) and stand or nil
end

function PokemonHabitat.ballOn(pos)
    return PokemonHabitat.itemOn(pos, PokemonHabitat.isChargedBall)
end

function PokemonHabitat.legacyOn(pos)
    local item = getTileItemById(pos, PokemonHabitat.LEGACY_FILLED_ID)
    return isItem(item) and item or nil
end

local function walkerName(ball)
    if (getBallPokemonNickname(ball.uid)) then
        return string.concat(getBallPokemonNickname(ball.uid), " [", getBallPokemonLevel(ball.uid), "]")
    end
    return string.concat(getBallPokemonName(ball.uid), " [", getBallPokemonLevel(ball.uid), "]")
end

local function dressWalker(npc, ball, name, sex)
    setNpcHouser(npc, true)
    setCreatureNickname(npc, name)
    local outfit = getBallCurrentAddon(ball.uid)
    if (outfit) then
        doSetCreatureOutfit(npc, outfit, -1)
    else
        doCreatureChangeOutfit(npc, getMonsterInfo(getBallPokemonName(ball.uid)).outfit)
    end
    if (sex == POKEMON_SEX_MALE) then
        doCreatureSetSkullType(npc, SKULL_BLACK)
    elseif (sex == POKEMON_SEX_FEMALE) then
        doCreatureSetSkullType(npc, SKULL_RED)
    else
        doCreatureSetSkullType(npc, SKULL_YELLOW)
    end
end

local function spawnWalker(ball, standPos)
    local npc = doCreateNpc(table.random(WALKER_NAMES), standPos)
    if (not npc) then
        return nil
    end
    setNpcHouser(npc, true)
    local walkPos = getPositionAdjacent(npc, standPos)
    if (walkPos and getHouseFromPos(walkPos)) then
        doTeleportThing(npc, walkPos)
    end
    local name = walkerName(ball)
    dressWalker(npc, ball, name, getBallPokemonSex(ball.uid))
    return npc, name
end

local function findWalker(pos, name)
    local houseId = getHouseFromPos(pos)
    for _, cid in ipairs(getSpectators(pos, 20, 20, true) or {}) do
        if (isNpc(cid) and getCreatureNickname(cid) == name and getHouseFromPos(getCreaturePosition(cid)) == houseId) then
            return cid
        end
    end
end

function PokemonHabitat.hasRow(pos)
    local r = db.getResult(string.concat("SELECT `id` FROM `ball_pillars` WHERE `world_id` = ", worldId(),
        " AND `positionx`=", pos.x, " AND `positiony`=", pos.y, " AND `positionz`=", pos.z, " LIMIT 1;"))
    if (r:getID() == -1) then
        return false
    end
    r:free()
    return true
end

function PokemonHabitat.saveRow(pos, ball, name)
    PokemonStats.ensureBall(ball.uid)
    local query = string.concat(
        "INSERT INTO ball_pillars (world_id, positionx, positiony, positionz, attributes, ball_id, creature_name, creature_sex) VALUES (",
        worldId(), ",", pos.x, ",", pos.y, ",", pos.z, ",",
        getItemAttributesBlob(ball.uid), ",", ball.itemid, ",",
        "'", name, "',", getBallPokemonSex(ball.uid), ");")
    if (not db.executeQuery(query)) then
        log(LOG_TYPES.ERROR, "PokemonHabitat.saveRow - Can't query.", posKey(pos), query)
        return false
    end
    return true
end

function PokemonHabitat.deleteRow(pos)
    db.executeQuery(string.concat("DELETE FROM `ball_pillars` WHERE `world_id` = ", worldId(),
        " AND `positionx`=", pos.x, " AND `positiony`=", pos.y, " AND `positionz`=", pos.z, ";"))
end

function PokemonHabitat.recall(pos)
    local r = db.getResult(string.concat("SELECT `creature_name` FROM `ball_pillars` WHERE `world_id` = ",
        worldId(), " AND `positionx`=", pos.x, " AND `positiony`=", pos.y, " AND `positionz`=", pos.z, " LIMIT 1;"))
    local name
    if (r:getID() ~= -1) then
        name = r:getDataString("creature_name")
        r:free()
    end
    if (name) then
        local npc = findWalker(pos, name)
        if (npc) then
            doSendDistanceShoot(getCreaturePosition(npc), pos, PROJECTILE_POKEBALL)
            doSendMagicEffect(getCreaturePosition(npc), EFFECT_POKEBALL_USE)
            doRemoveCreature(npc)
        end
    end
    PokemonHabitat.deleteRow(pos)
end

function PokemonHabitat.release(cid, ball, pos)
    if (not PokemonHabitat.isChargedBall(ball) or not getHouseFromPos(pos)) then
        return false
    end
    if (PokemonHabitat.hasRow(pos)) then
        return false
    end
    local unique = getItemUniqueOwner(ball.uid)
    if (unique ~= ITEM_UNIQUE_OWNER_NONE and unique ~= getPlayerGUID(cid)) then
        return false
    end
    local npc, name = spawnWalker(ball, pos)
    if (not npc) then
        return false
    end
    if (not PokemonHabitat.saveRow(pos, ball, name)) then
        doRemoveCreature(npc)
        return false
    end
    doSendDistanceShoot(getCreaturePosition(cid), pos, PROJECTILE_POKEBALL)
    doSendMagicEffect(pos, EFFECT_POKEBALL_USE)
    return true
end

local function bounceToPlayer(cid, item)
    if (not isPlayer(cid) or not isItem(item)) then
        return false
    end
    if (doPlayerAddBallToBelt(cid, item.uid)) then
        return true
    end
    return doMovePlayerItem(cid, item.uid, { y = PLAYER_SLOT_BACKPACK, z = 0 })
end

function PokemonHabitat.placeStand(cid, item, fromPosition)
    if (fromPosition.x == CONTAINER_POSITION) then
        doPlayerSendCancel(cid, "Put the habitat on the floor of your house first.")
        return true
    end
    if (not PokemonHabitat.ownsHouseTile(cid, fromPosition)) then
        doPlayerSendCancel(cid, "You can only place a Pokemon habitat in your own house.")
        return true
    end
    return true
end

function PokemonHabitat.attach(cid, ball, stand, standPos)
    if (not PokemonHabitat.isChargedBall(ball)) then
        doPlayerSendDefaultCancel(cid, RETURNVALUE_NOTPOSSIBLE)
        return true
    end
    local unique = getItemUniqueOwner(ball.uid)
    if (unique ~= ITEM_UNIQUE_OWNER_NONE and unique ~= getPlayerGUID(cid)) then
        doPlayerSendDefaultCancel(cid, RETURNVALUE_NOTPOSSIBLE)
        return true
    end
    if (not PokemonHabitat.ownsHouseTile(cid, standPos)) then
        doPlayerSendCancel(cid, "You can only use a Pokemon habitat in your own house.")
        return true
    end
    if (PokemonHabitat.hasRow(standPos) or PokemonHabitat.ballOn(standPos)) then
        doPlayerSendCancel(cid, "This habitat already has a Pokemon.")
        return true
    end
    if (not doMoveItem(ball.uid, standPos)) then
        doPlayerSendDefaultCancel(cid, RETURNVALUE_NOTENOUGHROOM)
        return true
    end
    -- dropping the ball on the stand also runs onAddItem, which releases it
    if (not PokemonHabitat.hasRow(standPos)) then
        local sitting = PokemonHabitat.ballOn(standPos) or getThing(ball.uid) or ball
        if (not PokemonHabitat.release(cid, sitting, standPos)) then
            bounceToPlayer(cid, sitting)
            doPlayerSendDefaultCancel(cid, RETURNVALUE_NOTPOSSIBLE)
            return true
        end
    end
    doPlayerSave(cid)
    return true
end

function PokemonHabitat.useEmpty(cid, item, fromPosition, itemEx, toPosition)
    -- Use-with: the stand on a charged ball in the bag (same result as dropping the ball on it)
    if (PokemonHabitat.isChargedBall(itemEx)) then
        if (fromPosition.x == CONTAINER_POSITION) then
            doPlayerSendCancel(cid, "Put the habitat on the floor of your house first.")
            return true
        end
        if (toPosition.x ~= CONTAINER_POSITION) then
            doPlayerSendCancel(cid, "Pick up the Poke Ball first, or drop it on the habitat.")
            return true
        end
        if (not PokemonHabitat.ownsHouseTile(cid, fromPosition)) then
            doPlayerSendCancel(cid, "You can only use a Pokemon habitat in your own house.")
            return true
        end
        return PokemonHabitat.attach(cid, itemEx, item, fromPosition)
    end
    if (fromPosition.x ~= CONTAINER_POSITION) then
        local sitting = PokemonHabitat.ballOn(fromPosition)
        if (sitting) then
            return PokemonHabitat.takeBack(cid, sitting, fromPosition)
        end
    end
    return PokemonHabitat.placeStand(cid, item, fromPosition)
end

function PokemonHabitat.useBall(cid, item, fromPosition, itemEx, toPosition)
    -- doPlayerUseItem (quick call, the swap bar) passes the trainer's tile even for the ball in the ball slot
    local onFloor = fromPosition.x ~= CONTAINER_POSITION
        and PokemonHabitat.itemOn(fromPosition, function(thing) return thing.uid == item.uid end)
    if (onFloor and (PokemonHabitat.standOn(fromPosition) or PokemonHabitat.legacyOn(fromPosition))) then
        return PokemonHabitat.takeBack(cid, item, fromPosition)
    end
    if (isItem(itemEx) and itemEx.itemid == PokemonHabitat.EMPTY_ID) then
        local standPos = toPosition
        if (toPosition.x == CONTAINER_POSITION) then
            doPlayerSendCancel(cid, "Put the habitat on the floor of your house first.")
            return true
        end
        return PokemonHabitat.attach(cid, item, itemEx, standPos)
    end
    return false
end

function PokemonHabitat.takeBack(cid, ball, pos)
    if (PokemonHabitat.legacyOn(pos) and ball.itemid == PokemonHabitat.LEGACY_FILLED_ID) then
        return false
    end
    PokemonHabitat.recall(pos)
    if (not bounceToPlayer(cid, ball)) then
        doPlayerSendDefaultCancel(cid, RETURNVALUE_NOTPOSSIBLE)
        return true
    end
    return true
end

function PokemonHabitat.onAddItem(moveItem, tileItem, position, cid)
    if (moveItem.itemid == PokemonHabitat.EMPTY_ID) then
        if (isPlayer(cid) and not PokemonHabitat.ownsHouseTile(cid, position)) then
            doPlayerSendCancel(cid, "You can only place a Pokemon habitat in your own house.")
            if (not bounceToPlayer(cid, moveItem)) then
                doRemoveItem(moveItem.uid)
                doPlayerSafeAddItem(cid, PokemonHabitat.EMPTY_ID, 1, false, false)
            end
        end
        return true
    end
    if (not isItem(tileItem) or tileItem.itemid ~= PokemonHabitat.EMPTY_ID) then
        return true
    end
    if (not PokemonHabitat.isChargedBall(moveItem)) then
        return true
    end
    if (not isPlayer(cid) or not PokemonHabitat.ownsHouseTile(cid, position)) then
        if (isPlayer(cid)) then
            doPlayerSendCancel(cid, "You can only use a Pokemon habitat in your own house.")
            bounceToPlayer(cid, moveItem)
        end
        return true
    end
    if (PokemonHabitat.hasRow(position)) then
        doPlayerSendCancel(cid, "This habitat already has a Pokemon.")
        bounceToPlayer(cid, moveItem)
        return true
    end
    if (not PokemonHabitat.release(cid, moveItem, position)) then
        doPlayerSendDefaultCancel(cid, RETURNVALUE_NOTPOSSIBLE)
        bounceToPlayer(cid, moveItem)
    else
        doPlayerSave(cid)
    end
    return true
end

function PokemonHabitat.onRemoveItem(moveItem, tileItem, position, cid)
    if (moveItem.itemid == PokemonHabitat.EMPTY_ID) then
        if (PokemonHabitat.hasRow(position)) then
            PokemonHabitat.recall(position)
        end
        return true
    end
    if (PokemonHabitat.isChargedBall(moveItem) and PokemonHabitat.hasRow(position)) then
        PokemonHabitat.recall(position)
    end
    return true
end

function PokemonHabitat.onStartup()
    local r = db.getResult("SELECT `positionx`, `positiony`, `positionz`, `attributes`, `ball_id`, `creature_name`, `creature_sex` FROM `ball_pillars` WHERE `world_id` = "
        .. worldId() .. ";")
    if (r:getID() == -1) then
        return
    end
    repeat
        local pos = { x = r:getDataInt("positionx"), y = r:getDataInt("positiony"), z = r:getDataInt("positionz") }
        local live = PokemonHabitat.ballOn(pos)
        if (live) then
            local npc = doCreateNpc(table.random(WALKER_NAMES), pos)
            if (npc) then
                local walkPos = getPositionAdjacent(npc, pos)
                if (walkPos and getHouseFromPos(walkPos)) then
                    local nextNpc = doCreateNpc(table.random(WALKER_NAMES), walkPos)
                    if (nextNpc) then
                        doRemoveCreature(npc)
                        npc = nextNpc
                    end
                end
                dressWalker(npc, live, r:getDataString("creature_name"), r:getDataInt("creature_sex"))
            else
                log(LOG_TYPES.ERROR, "PokemonHabitat.onStartup - Can't create NPC.", posKey(pos))
            end
        elseif (PokemonHabitat.legacyOn(pos)) then
            local ball = doCreateItemEx(r:getDataInt("ball_id"), 1)
            if (ball) then
                doItemLoadAttributes(ball, "attributes", r)
                local npc = doCreateNpc(table.random(WALKER_NAMES), pos)
                if (npc) then
                    local walkPos = getPositionAdjacent(npc, pos)
                    if (walkPos and getHouseFromPos(walkPos)) then
                        local nextNpc = doCreateNpc(table.random(WALKER_NAMES), walkPos)
                        if (nextNpc) then
                            doRemoveCreature(npc)
                            npc = nextNpc
                        end
                    end
                    dressWalker(npc, { uid = ball }, r:getDataString("creature_name"), r:getDataInt("creature_sex"))
                else
                    log(LOG_TYPES.ERROR, "PokemonHabitat.onStartup - Can't create NPC.", posKey(pos))
                end
                doRemoveItem(ball)
            else
                log(LOG_TYPES.ERROR, "PokemonHabitat.onStartup - Can't create ball.", posKey(pos))
            end
        else
            PokemonHabitat.deleteRow(pos)
        end
    until not r:next()
    r:free()
end
