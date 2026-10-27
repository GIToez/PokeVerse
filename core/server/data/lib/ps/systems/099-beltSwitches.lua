-- The two switches under the Pokegear Bag's belt (docs/concepts/side-panel/README.md). The client only sends
-- the setting ({action = "switches", defense, autoSwap} on EXTENDED_IDS.BAG, answered with
-- {type = "switches", defense, autoSwap}); the server does both, so they work the same on any connection.
--   Defense mode (off by default): something attacks the trainer, or the trainer targets something, with no
--     Pokemon out: the ball slot's Pokemon comes out, or the next living one down the belt. Not in safe zones,
--     and not while surfing, flying or riding.
--   Auto swap (on by default): the Pokemon that's out faints in a fight: after FAINT_DELAY the next living one
--     down the belt comes out and becomes the ball slot's. With nobody left, one "No Pokemon left to call".
-- Both wait for the call cooldown, and stay off in duels and NPC battles, where the trainer chooses.

BeltSwitches = {}

local FAINT_DELAY = 2000
local COOLDOWN_RETRY = 500
local COOLDOWN_TRIES = 6
local FIGHT_RANGE = 8

BeltSwitches.isDefense = function(cid)
    return getCreatureStorage(cid, playersStorages.beltDefense) == 1
end

BeltSwitches.isAutoSwap = function(cid)
    return getCreatureStorage(cid, playersStorages.beltAutoSwapOff) ~= 1
end

BeltSwitches.send = function(cid)
    doSendPlayerExtendedOpcode(cid, EXTENDED_IDS.BAG, JSON.encode({ type = "switches",
        defense = BeltSwitches.isDefense(cid), autoSwap = BeltSwitches.isAutoSwap(cid) }))
end

BeltSwitches.set = function(cid, defense, autoSwap)
    if (type(defense) == "boolean") then
        doCreatureSetStorage(cid, playersStorages.beltDefense, defense and 1 or -1)
    end
    if (type(autoSwap) == "boolean") then
        doCreatureSetStorage(cid, playersStorages.beltAutoSwapOff, autoSwap and -1 or 1)
    end
    BeltSwitches.send(cid)
end

local function isLiving(item)
    local name = isItem(item) and ballsNames[item.itemid]
    return name ~= nil and balls[name].charged == item.itemid and isBallWithPokemon(item.uid)
end

-- the ball slot's ball if it can fight, else the first one down the belt that can
local function nextBall(cid)
    local ball = getPlayerSlotItem(cid, PLAYER_SLOT_BALL)
    if (isLiving(ball)) then
        return ball, false
    end
    local belt = getPlayerBelt(cid)
    if (belt) then
        for slot = 0, getContainerSize(belt) - 1 do
            local item = getContainerItem(belt, slot)
            if (isLiving(item)) then
                return item, true
            end
        end
    end
end

BeltSwitches.nextBall = nextBall

local function isFree(cid)
    return isPlayer(cid) and not isPokemonOnline(cid) and not getPlayerDueling(cid) and not getPlayerBattleing(cid)
        and not getPlayerMounted(cid)
end

local function call(cid)
    local item, fromBelt = nextBall(cid)
    if (not item) then
        return false
    end
    if (fromBelt) then
        local current = getPlayerSlotItem(cid, PLAYER_SLOT_BALL)
        if (isItem(current)) then
            if (not doSwapItems(item.uid, current.uid)) then
                return false
            end
        else
            doMovePlayerItem(cid, item.uid, { y = PLAYER_SLOT_BALL, z = 0 })
        end
    end
    doPlayerUseBallOnSlot(cid)
    return true
end

BeltSwitches.callNext = call

local defending = {}

local function defend(cid, tries)
    defending[cid] = nil
    if (not isFree(cid) or not BeltSwitches.isDefense(cid) or getTilePzInfo(getCreaturePosition(cid))) then
        return
    end
    if (isExhaust(cid)) then
        if (tries > 0) then
            defending[cid] = true
            addEvent(defend, COOLDOWN_RETRY, cid, tries - 1)
        end
        return
    end
    call(cid)
end

-- something attacked the trainer, or the trainer targeted something
BeltSwitches.onThreat = function(cid)
    if (not defending[cid] and BeltSwitches.isDefense(cid) and isFree(cid)) then
        defending[cid] = true
        addEvent(defend, 0, cid, COOLDOWN_TRIES)
    end
end

local function inFight(cid, foe)
    if (getCreatureTarget(cid) ~= 0) then
        return true
    end
    if (not foe or not isCreature(foe)) then
        return false
    end
    local a, b = getCreaturePosition(cid), getCreaturePosition(foe)
    return a.z == b.z and math.max(math.abs(a.x - b.x), math.abs(a.y - b.y)) <= FIGHT_RANGE
end

local function swap(cid, foe, tries)
    if (not isFree(cid) or not BeltSwitches.isAutoSwap(cid) or not inFight(cid, foe)) then
        return
    end
    if (isExhaust(cid)) then
        if (tries > 0) then
            addEvent(swap, COOLDOWN_RETRY, cid, foe, tries - 1)
        end
        return
    end
    if (not call(cid)) then
        doPlayerSendCancel(cid, __L(cid, "No Pokemon left to call."))
    end
end

-- the trainer's Pokemon fainted; foe is what knocked it out
BeltSwitches.onFaint = function(cid, foe)
    if (isPlayer(cid) and BeltSwitches.isAutoSwap(cid)) then
        addEvent(swap, FAINT_DELAY, cid, type(foe) == "number" and foe or nil, COOLDOWN_TRIES)
    end
end
