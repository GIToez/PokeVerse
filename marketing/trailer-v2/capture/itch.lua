-- scratch server only: staging for the trailer
local TEAM = { "Charizard", "Pikachu", "Blastoise", "Venusaur", "Gyarados", "Rhydon", "Arcanine", "Kingler", "Steelix", "Dragonite" }
local GYM_TIMES = { 9101, 9102, 9103, 9104, 9105, 9106, 9107, 9108, 9508, 9537, 9533, 9518, 9529, 9542, 9504, 9519 }

local function ballOf(cid, name)
	for _, ball in ipairs(getPlayerAllBallsWithPokemon(cid)) do
		if (getBallPokemonName(ball.uid) == name) then
			return ball
		end
	end
end

function onSay(cid, words, param, channel)
	local args = string.explode(param, " ")
	param = (args[1] or ""):lower()
	if (param == "energy") then
		doCreatureAddMana(cid, getCreatureMaxMana(cid) - getCreatureMana(cid))
		local pokemon = getPlayerPokemon and getPlayerPokemon(cid)
		if (pokemon and isCreature(pokemon)) then
			doCreatureAddHealth(pokemon, getCreatureMaxHealth(pokemon))
		end
	elseif (param == "look") then
		doCreatureChangeOutfit(cid, {lookType = 612, lookHead = 94, lookBody = 94, lookLegs = 69, lookFeet = 113, lookAddons = 0})
	elseif (param == "ring") then
		if (getPlayerSlotItem(cid, CONST_SLOT_RING).itemid ~= MEGA_ITEM_IDS.RING) then
			local uid = doPlayerAddItem(cid, MEGA_ITEM_IDS.RING, 1)
			doMovePlayerItem(cid, uid, {x = 65535, y = CONST_SLOT_RING, z = 0})
		end
		MegaEvolution.send(cid)
	elseif (param == "long") then
		MegaEvolution.DURATION = 3600
	elseif (param == "heal") then
		doCreatureAddHealth(cid, getCreatureMaxHealth(cid))
	elseif (param == "team") then
		for _, name in ipairs(TEAM) do
			if (not ballOf(cid, name)) then
				doCreatePokemonBall(cid, "ultra", name, 100, nil, nil, 0, nil, nil, 99999999999, nil, getPokemonRandomSpecialAbility(name))
			end
		end
	elseif (param == "gym") then
		for _, storage in ipairs(GYM_TIMES) do
			doCreatureSetStorage(cid, storage, -1)
		end
		for _, badge in pairs(BADGES) do
			if (type(badge) == "table" and badge.newItemId) then
				local count = getPlayerItemCount(cid, badge.newItemId)
				if (count > 0) then doPlayerRemoveItem(cid, badge.newItemId, count) end
			end
		end
		doPlayerAddRespect(cid, 50)
	elseif (param == "surfboard") then
		local ball = getPlayerBall(cid)
		if (ball and ball.uid > 0 and isPokemonOnline(cid)) then
			doBallAddAddon(ball.uid, PokemonAddon.IDS.SURFBOARD)
			local name = getBallPokemonName(ball.uid)
			local look = ({ ["Pikachu"] = 2898, ["Shiny Pikachu"] = 2900, ["Raichu"] = 2902, ["Shiny Raichu"] = 2904 })[name]
			if (look) then PokemonAddon.onChooseAddon(cid, { lookType = look }) end
		end
	elseif (param == "fly") then
		local want = args[2] and args[2]:lower()
		if (isFlying(cid)) then
			if (want ~= "on") then deFly(cid) end
		elseif (want ~= "off" and isPokemonOnline(cid)) then
			fly(cid)
		end
	elseif (param == "ride") then
		if (isRiding(cid)) then deRide(cid) elseif (isPokemonOnline(cid)) then ride(cid) end
	elseif (param == "speed") then
		doChangeSpeed(cid, (tonumber(args[2]) or 600) - getCreatureSpeed(cid))
	elseif (param == "catch") then
		local p = getCreaturePosition(cid)
		for dx = -6, 6 do
			for dy = -6, 6 do
				local pos = {x = p.x + dx, y = p.y + dy, z = p.z, stackpos = 0}
				local corpse = getTileItemByType(pos, ITEM_TYPE_CONTAINER)
				local who = isItem(corpse) and getItemAttribute(corpse.uid, "pokemon")
				if (who and isCorpse(corpse.uid) and (not args[3] or tostring(who):lower():find(args[3]:lower(), 1, true))) then
					local kind = args[2] or "poke"
					local uid = doPlayerAddItem(cid, balls[kind].empty, 1)
					balls[kind].guaranteedCatch = true
					emptyBall(cid, {uid = uid, itemid = balls[kind].empty}, p, corpse, pos)
					balls[kind].guaranteedCatch = nil
					return true
				end
			end
		end
		doPlayerSendCancel(cid, "itch: no body nearby")
	elseif (param == "weaken") then
		local share = (tonumber(args[2]) or 85) / 100
		local p = getCreaturePosition(cid)
		for _, c in ipairs(getSpectators(p, 9, 7, false) or {}) do
			if (isMonster(c) and not isSummon(c)) then
				doCreatureAddHealth(c, -math.floor(getCreatureHealth(c) * share))
			end
		end
	elseif (param == "hp") then
		local want = tonumber(args[2]) or 300
		for _, c in ipairs(getSpectators(getCreaturePosition(cid), 9, 7, false) or {}) do
			if (isMonster(c) and not isSummon(c) and getCreatureHealth(c) > want) then
				doCreatureAddHealth(c, want - getCreatureHealth(c))
			end
		end
	elseif (param == "back") then
		local ball = getPlayerSlotItem(cid, CONST_SLOT_FEET)
		if (isPokemonOnline(cid) and ball and ball.uid > 0) then inUseBall(cid, ball) end
	elseif (param == "noflee") then
		for _, c in ipairs(getSpectators(getCreaturePosition(cid), 9, 7, false) or {}) do
			if (isMonster(c) and not isSummon(c)) then doCreatureSetStorage(c, WildLegendaries.MON.FLEE_STAGE, 9) end
		end
	elseif (param == "balls") then
		for _, ball in ipairs(getPlayerAllBallsWithPokemon(cid)) do
			doBallHeal(cid, ball)
		end
	end
	return true
end
