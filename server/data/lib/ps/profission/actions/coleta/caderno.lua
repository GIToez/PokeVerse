local corpseIDs = {11836,11839,11840,11841,11842,11843,11844,11845,11846,11847,11848,11849,11850,11851,11852,11853,11854,11855,18856,11857,11859,11860,11861,11862,11863,11864,11865,11866,11867,11868,11869,11870,11871,11872,11873,11874,11875,11876,11877,11878,11879,11880,11881,11882,11883,11884,11885,12140,11886,11887,11888,11889,11890,11891,11892,11893,11894,11895,11896,11897,11898,11899,11900,11901,11902,11903,11904,11905,11906,11907,11908,11909,11910,11911,11912,11913,11914,11915,11916,11917,11918,11919,11920,11921,11922,11923,11924,11925,11926,11927,11928,11929,11930,11931,11932,11934,11935,11936,11937,11938,11939,11940,11941,11942,11943,11944,11945,11946,11947,11948,11949,11950,11951,11952,11953,11954,11955,11956,11957,11958,11959,11960,11961,11962,11963,11964,11965,11966,11967,11968,11969,11970,11971,11972,11973,11974,11975,11976,11977,11978,11979,11980,11981,11982,11983,11984,11985,11986,11987,11988,12482,12484,12473,12434,12583,12431,13076,12425,16301,12524,16301,12524,12604,12568,12569,12567,12545,12520,12502,16299,16311,12461,16305,12507,12477,12550,16308,16307,12536,16306,16310,12544,12518,12517,13082,15802,12773,12549,12599,12525,12595,12508,16302,12597,12462,12582,12465,12466,12437,12547,12949,12445,12439,12438,12596,12543,12537,12563,12603,12534,12827,12491,12492,16309,12468,12467,12422,16304,12519,16303,12460}

function checkTiles(cid, item)
	local pos = getThingPosition(item)
	local fromPos = {x = pos.x - 6, y = pos.y - 6, z = pos.z}
	local toPos = {x = pos.x + 6, y = pos.y + 6, z = pos.z}
	local amount = 0
	local monsterAmount = 1
	
	local outfit = getCreatureOutfit(cid)
	doCreatureSetNoMove(cid, true)
	
	for sX = fromPos.x, toPos.x do
		for sY = fromPos.y, toPos.y do
			local specialPosition = {x = sX, y = sY, z = pos.z, stackpos = 1}
			local specialItem = getTileThingByPos(specialPosition)
			
			if isInArray(corpseIDs, specialItem.itemid) then
				if getItemAttribute(specialItem.uid, "drawn") then
					doCreatureSetNoMove(cid, false)
				else
					local valor = math.random(1, 5)
					doItemSetAttribute(specialItem.uid, "drawn", "true")
		            
					amount = amount + valor
					monsterAmount = monsterAmount + 1
				end
			end
		end
	end
	
	if getPlayerSex(cid) == 0 then --- FEMALE \/
		doSetCreatureOutfit(cid, {lookType = 3385, lookHead = outfit.lookHead, lookBody = outfit.lookBody, lookLegs = outfit.lookLegs, lookFeet = outfit.lookFeet}, 1000 * monsterAmount)
	else --- MALE \/
		doSetCreatureOutfit(cid, {lookType = 3384, lookHead = outfit.lookHead, lookBody = outfit.lookBody, lookLegs = outfit.lookLegs, lookFeet = outfit.lookFeet}, 1000 * monsterAmount)
	end

	addEvent(function()
		doCreatureSetNoMove(cid, false)
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Você conseguiu ".. amount .." pontos de estilo.")
		
		local itemzin = doPlayerAddItem(cid, 17090, amount)
		doItemSetAttribute(itemzin, "unique", 1)
		doSendMagicEffect(getThingPos(cid), 28)
	end, 1000 * monsterAmount)
return true
end

function onUse(cid, item, fromPos, item2, toPos)
	if not isInArray(corpseIDs, getTileThingByPos(toPos).itemid) then
		doPlayerSendCancel(cid, "Você não pode usar isso neste item.") 
	return true
	end

	-- CHEGAGENS
	if getPlayerStorageValue(cid, 17001) > 0 or getPlayerStorageValue(cid, 17000) > 0 or getPlayerStorageValue(cid, 63215) > 0 then
		if isInArray({460, 11675, 11676, 11677}, getTileInfo(getThingPos(cid)).itemid) then return true end
		local item = getPlayerSlotItem(cid, 8) local pokemon = getItemAttribute(item.uid, "poke") local x = pokes[pokemon]
		if getTileInfo(getThingPos(cid)).itemid >= 4820 and getTileInfo(getThingPos(cid)).itemid <= 4825 then return true end
			doSummonMonster(cid, pokemon)
			local pk = getCreatureSummons(cid)[1] if not isCreature(pk) then pk = doCreateMonster(pokemon, backupPos)
			if not isCreature(pk) then return true end doConvinceCreature(cid, pk) end

			local outfit = getPokeOutfitColors(item.uid, getPokemonName(getCreatureSummons(cid)[1]), "normal")
			doSetCreatureOutfit(pk, outfit, -1) doTeleportThing(pk, getThingPos(cid), false)
			doCreatureSetLookDir(pk, getCreatureLookDir(cid)) adjustStatus(pk, item.uid, true, false, true)
			doPlayerSay(cid, ""..getPokeName(getCreatureSummons(cid)[1])..", Preciso desenhar este Pokémon!", 19)
			-- doRegainSpeed(cid) doRemoveCondition(cid, CONDITION_OUTFIT) setPlayerStorageValue(cid, 17000, -1)
			setPlayerStorageValue(cid, 17001, -1) 
	return true 
	end

	if not isPremium(cid) then
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Apenas jogadores VIP'S podem desenhar pokémons.")
		return true
	end

	if getPlayerProfession(cid) ~= "stylist" then
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Somente estilistas podem usar este item.")
		return true
	end

	-- CHEGAGENS

	if getItemAttribute(item2.uid, "drawn") then
		doPlayerSendCancel(cid, "Você já desenhou este pokemon.") 
	return true
	end

	if not isCreature(item2.uid) then			
		checkTiles(cid, item2.uid)
	end
    return true
end