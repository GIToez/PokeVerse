local HEALTH_DURATION = 60 -- Seconds
local HEALTH_DELAY = 5000 -- Interval between each regeneration
local HEALTH_TICKS = math.floor(HEALTH_DURATION / (HEALTH_DELAY / 1000)) -- How much regenerations will occur, current: 1 minute full potion work

local health1 = createConditionObject(CONDITION_REGENERATION, HEALTH_DURATION * 1000, false,
    CONDITION_SUBID.REGENERATION.HEALTH_POTION)
setConditionParam(health1, CONDITION_PARAM_HEALTHGAIN, math.floor(3000 / HEALTH_TICKS))
setConditionParam(health1, CONDITION_PARAM_HEALTHTICKS, HEALTH_DELAY)
setConditionParam(health1, CONDITION_PARAM_LIGHT_LEVEL, true) -- Show effect

local health2 = createConditionObject(CONDITION_REGENERATION, HEALTH_DURATION * 1000, false,
    CONDITION_SUBID.REGENERATION.HEALTH_POTION)
setConditionParam(health2, CONDITION_PARAM_HEALTHGAIN, math.floor(6000 / HEALTH_TICKS))
setConditionParam(health2, CONDITION_PARAM_HEALTHTICKS, HEALTH_DELAY)
setConditionParam(health2, CONDITION_PARAM_LIGHT_LEVEL, true) -- Show effect

local health3 = createConditionObject(CONDITION_REGENERATION, HEALTH_DURATION * 1000, false,
    CONDITION_SUBID.REGENERATION.HEALTH_POTION)
setConditionParam(health3, CONDITION_PARAM_HEALTHGAIN, math.floor(12000 / HEALTH_TICKS))
setConditionParam(health3, CONDITION_PARAM_HEALTHTICKS, HEALTH_DELAY)
setConditionParam(health3, CONDITION_PARAM_LIGHT_LEVEL, true) -- Show effect

local health4 = createConditionObject(CONDITION_REGENERATION, HEALTH_DURATION * 1000, false,
    CONDITION_SUBID.REGENERATION.HEALTH_POTION)
setConditionParam(health4, CONDITION_PARAM_HEALTHGAIN, math.floor(18000 / HEALTH_TICKS))
setConditionParam(health4, CONDITION_PARAM_HEALTHTICKS, HEALTH_DELAY)
setConditionParam(health4, CONDITION_PARAM_LIGHT_LEVEL, true) -- Show effect

local HEALTH_POTIONS = {
    [12244] = {healthGain = math.floor(3000 / HEALTH_TICKS), condition = health1, msg = "1", onlyPokemon = false, iconItemId = 11205}, -- Pokemon Health Potion
    [12245] = {healthGain = math.floor(6000 / HEALTH_TICKS), condition = health2, msg = "2", onlyPokemon = true, iconItemId = 11206}, -- Great Pokemon Health Potion
    [12246] = {healthGain = math.floor(12000 / HEALTH_TICKS), condition = health3, msg = "3", onlyPokemon = true, iconItemId = 11207}, -- Ultra Pokemon Health Potion
    [12247] = {healthGain = math.floor(18000 / HEALTH_TICKS), condition = health4, msg = "4", onlyPokemon = true, iconItemId = 11208}, -- Super Pokemon Health Potion
}

local EVENTS = {}
local MARK_EVENTS = {} -- [target] = the next heal mark refresh

-- The heal mark over the creature's name, for every player who can see it; sent again every tick so
-- players who come closer see it too
local MARK_RANGE_X, MARK_RANGE_Y = 9, 7
local function sendHealMark(target, seconds)
    if (not EXTENDED_IDS.HEAL_MARK or not isCreature(target)) then
        return
    end
    local payload = JSON.encode({ id = target, s = seconds })
    for _, spectator in ipairs(getSpectators(getCreaturePosition(target), MARK_RANGE_X, MARK_RANGE_Y, false) or {}) do
        if (isPlayer(spectator)) then
            doSendPlayerExtendedOpcode(spectator, EXTENDED_IDS.HEAL_MARK, payload)
        end
    end
end

local function refreshHealMark(target, endsAt)
    MARK_EVENTS[target] = nil
    local left = endsAt - os.time()
    if (not isCreature(target) or left <= 0) then
        return
    end
    sendHealMark(target, left)
    MARK_EVENTS[target] = addEvent(refreshHealMark, HEALTH_DELAY, target, endsAt)
end

local function stopHealMark(target)
    if (MARK_EVENTS[target]) then
        stopEvent(MARK_EVENTS[target])
        MARK_EVENTS[target] = nil
    end
    sendHealMark(target, 0)
end

-- The Medic's stronger potions: the same condition with more health per tick, for every potion and
-- Medic bonus. Conditions can only be created while the script loads.
local medicConditions = {}
for itemid, potion in pairs(HEALTH_POTIONS) do
    for _, bonus in ipairs(Vocations.PERKS.medic.healing) do
        local gain = math.floor(potion.healthGain * (1 + bonus))
        local condition = createConditionObject(CONDITION_REGENERATION, HEALTH_DURATION * 1000, false,
            CONDITION_SUBID.REGENERATION.HEALTH_POTION)
        setConditionParam(condition, CONDITION_PARAM_HEALTHGAIN, gain)
        setConditionParam(condition, CONDITION_PARAM_HEALTHTICKS, HEALTH_DELAY)
        setConditionParam(condition, CONDITION_PARAM_LIGHT_LEVEL, true)
        medicConditions[itemid .. ":" .. bonus] = { condition = condition, gain = gain }
    end
end

local function getHealCondition(itemid, bonus)
    local medic = bonus and medicConditions[itemid .. ":" .. bonus]
    if (not medic) then
        return HEALTH_POTIONS[itemid].condition, HEALTH_POTIONS[itemid].healthGain
    end
    return medic.condition, medic.gain
end

-- Another trainer's Pokemon on that tile, when a Medic may heal it (neither trainer in a duel or battle)
local function getOtherTrainerPokemon(cid, position)
    if (not Vocations.perk(cid, "medic", "healOthersRank")) then
        return nil
    end
    local creature = getTopCreature(position).uid
    if (not isCreature(creature) or not isMonster(creature) or not isSummon(creature)) then
        return nil
    end
    local owner = getCreatureMaster(creature)
    if (not isPlayer(owner) or owner == cid or Vocations.inBattle(owner)) then
        return nil
    end
    return creature, owner
end

local function onHealEnd(cid, msg)
    stopHealMark(cid)
    if (isCreature(cid)) then
        setIsPokemonUsingHealthPotion(cid, false)
        doSendAnimatedText(getCreaturePosition(cid), "HEAL -" .. msg, COLOR_RED)
        EVENTS[cid] = nil
        if (isMonster(cid)) then
            doPlayerSendTextMessage(getCreatureMaster(cid), MESSAGE_STATUS_CONSOLE_BLUE, "The increased health regeneration of your Pokemon has ended.")
        else
            doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Your increased health regeneration has ended.")
        end
    end
end

local function onHealStart(cid, target, item, targetPosition, playerPosition, forceFirstHeal)
    -- the Medic's trial counts real heals: a hurt Pokemon without a potion already running
    local counts = forceFirstHeal and getCreatureHealth(target) < getCreatureMaxHealth(target)
    local condition, healthGain = getHealCondition(item.itemid, Vocations.perk(cid, "medic", "healing"))
    setIsPokemonUsingHealthPotion(target, true)
    doAddCondition(target, condition)
    EVENTS[target] = addEvent(onHealEnd, HEALTH_DURATION * 1000, target, HEALTH_POTIONS[item.itemid].msg)
    if (MARK_EVENTS[target]) then
        stopEvent(MARK_EVENTS[target])
    end
    refreshHealMark(target, os.time() + HEALTH_DURATION)
    doSendAnimatedText(targetPosition, "HEAL +" .. HEALTH_POTIONS[item.itemid].msg, COLOR_LIGHTGREEN)
    doSendMagicEffect(targetPosition, EFFECT_GREEN_BUFF)
    Sounds.around(targetPosition, "heal_hp")
    doSendDistanceShoot(playerPosition, targetPosition, PROJECTILE_GRAVEL)
    doRemoveItem(item.uid, 1)
    if (target ~= cid and counts) then
        Vocations.addTrial(cid, "medic", "heal")
        if (getCreatureMaster(target) ~= cid) then
            Vocations.addTrial(cid, "medic", "healOther")
        end
    end

    if (forceFirstHeal) then
        doCreatureAddHealth(target, healthGain, true)
    end
end

function onUse(cid, item, fromPosition, itemEx, toPosition)
	if (getPlayerDueling(cid) or getPlayerPvpArena(cid) or getPlayerBattleing(cid) or not HEALTH_POTIONS[item.itemid]) then
		doPlayerSendDefaultCancel(cid, RETURNVALUE_NOTPOSSIBLE)
		return true
	end

	local target, pokemon, playerPosition, msg, targetPosition = nil, getPlayerPokemon(cid), getCreaturePosition(cid), "Sorry, not possible.", nil
    local replacing = false
    local owner = cid
	if (getDistanceBetween(playerPosition, toPosition) > 4) then
		msg = "Too far."

	elseif (isCreature(pokemon)) then
		local pokemonPosition = getCreaturePosition(pokemon)
		if (getSamePosition(pokemonPosition, toPosition)) then
			if (isPokemonUsingHealthPotion(pokemon)) then
				replacing = true
            end

            target = pokemon
            targetPosition = pokemonPosition

		elseif (getSamePosition(playerPosition, toPosition)) then
			if (HEALTH_POTIONS[item.itemid].onlyPokemon) then
                msg = "You can not use this potion on yourself."
            else
                target = cid
                targetPosition = playerPosition
            end
		end

	elseif (getSamePosition(playerPosition, toPosition)) then
		if (HEALTH_POTIONS[item.itemid].onlyPokemon) then
            msg = "You can not use this potion on yourself."
        else
            target = cid
            targetPosition = playerPosition
        end
    end

    if (not target and getDistanceBetween(playerPosition, toPosition) <= 4) then
        local other, otherOwner = getOtherTrainerPokemon(cid, toPosition)
        if (other) then
            target, owner, targetPosition = other, otherOwner, getCreaturePosition(other)
            replacing = isPokemonUsingHealthPotion(other)
        end
    end

    if (target == cid and isPokemonUsingHealthPotion(cid)) then
        replacing = true
    end

	if (isCreature(target)) then
        if (replacing and EVENTS[target]) then
            stopEvent(EVENTS[target])
            EVENTS[target] = nil
            doRemoveCondition(target, CONDITION_REGENERATION, CONDITION_SUBID.REGENERATION.HEALTH_POTION)

            for _, potion in pairs(HEALTH_POTIONS) do
                doPlayerSendPokemonStatusRemove(getCreatureMaster(target), potion.iconItemId) -- We dont know what is the currently potion, lets send an all clear
            end
        end

        local iconItemId = HEALTH_POTIONS[item.itemid].iconItemId
        onHealStart(cid, target, item, targetPosition, playerPosition, not replacing)
        if (owner ~= cid) then
            doPlayerSendTextMessage(owner, MESSAGE_STATUS_CONSOLE_BLUE, string.format(__L(owner, "Medic %s is healing your Pokemon."), getCreatureName(cid)))
            doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, string.format(__L(cid, "You are healing %s's Pokemon."), getCreatureName(owner)))
        end

        if (replacing) then
            addEvent(function() -- Ugly hack due to slow connections
                    if (isCreature(owner)) then
                        doPlayerSendPokemonStatusAdd(owner, iconItemId, HEALTH_DURATION)
                    end
                end, 100)
        else
            doPlayerSendPokemonStatusAdd(owner, iconItemId, HEALTH_DURATION)
        end


	else
		doPlayerSendCancel(cid, msg)
	end
	return true
end
