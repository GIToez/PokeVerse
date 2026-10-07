function doPlayerGiveItem(cid, itemid, amount, subType)
	local item = 0
	if(isItemStackable(itemid)) then
		item = doCreateItemEx(itemid, amount)
		if(doPlayerAddItemEx(cid, item, true) ~= RETURNVALUE_NOERROR) then
			return false
		end
	else
		for i = 1, amount do
			item = doCreateItemEx(itemid, subType)
			if(doPlayerAddItemEx(cid, item, true) ~= RETURNVALUE_NOERROR) then
				return false
			end
		end
	end

	return true
end


--/////////////////////////////////////////////////////////////////////////////////---
function getPlayerDesc(cid, thing, TV)
if (not isCreature(cid) or not isCreature(thing)) and not TV then return "" end

local pos = getThingPos(thing)
local ocup = youAre[getPlayerGroupId(thing)]
local rank = (getPlayerStorageValue(thing, 86228) <= 0) and "Treinador Pokémon" or lookClans[getPlayerStorageValue(thing, 86228)][getPlayerStorageValue(thing, 862281)]
local name = thing == cid and "" or getCreatureName(thing)     
local art = thing == cid and "You are" or (getPlayerSex(thing) == 0 and "She is" or "He is")

local str = {}  

table.insert(str, ""..name.." \n")
local townName = getTownName(getPlayerTown(thing))
    if not townName then
	  townName = "Server para Testes"
	end
if getPlayerProfession(thing) == "stylist" then
table.insert(str, "Um Estilista e ")
elseif getPlayerProfession(thing) == "adventurer" then
table.insert(str, "Um Aventureiro e ")
elseif getPlayerProfession(thing) == "engineer" then
table.insert(str, "Um Engenheiro e ")
elseif getPlayerProfession(thing) == "professor" then
table.insert(str, "Um Professor e ")
end
if youAre[getPlayerGroupId(thing)] then
   table.insert(str, (ocup).."\n "..rank.." de ".. townName..".\n ")       
else
   table.insert(str, (rank).." de ".. townName..". ")
end
if getPlayerGuildId(thing) > 0 then
   table.insert(str, " "..getPlayerGuildRank(thing).." da guilda: "..getPlayerGuildName(thing)..".")
end
table.insert(str, ((isPlayer(cid) and youAre[getPlayerGroupId(cid)]) and "\nPosition: [X: "..pos.x.."][Y: "..pos.y.."][Z: "..pos.z.."]" or "")) 

return table.concat(str) 
end
-------------------------------------------------------------------------------------------------   /\/\

function getThingPosWithDebug(what)
	if not isCreature(what) or getCreatureHealth(what) <= 0 then
	return {x = 1, y = 1, z = 10}
	end
return getThingPos(what)
end

function doPlayerGiveItemContainer(cid, containerid, itemid, amount, subType)
	for i = 1, amount do
		local container = doCreateItemEx(containerid, 1)
		for x = 1, getContainerCapById(containerid) do
			doAddContainerItem(container, itemid, subType)
		end

		if(doPlayerAddItemEx(cid, container, true) ~= RETURNVALUE_NOERROR) then
			return false
		end
	end

	return true
end

function doPlayerTakeItem(cid, itemid, amount)
	return getPlayerItemCount(cid, itemid) >= amount and doPlayerRemoveItem(cid, itemid, amount)
end

function doPlayerBuyItem(cid, itemid, count, cost, charges)
	return doPlayerRemoveMoney(cid, cost) and doPlayerGiveItem(cid, itemid, count, charges)
end

function doPlayerBuyItemContainer(cid, containerid, itemid, count, cost, charges)
	return doPlayerRemoveMoney(cid, cost) and doPlayerGiveItemContainer(cid, containerid, itemid, count, charges)
end

function doPlayerSellItem(cid, itemid, count, cost)
	if(not doPlayerTakeItem(cid, itemid, count)) then
		return false
	end

	if(not doPlayerAddMoney(cid, cost)) then
		error('[doPlayerSellItem] Could not add money to: ' .. getPlayerName(cid) .. ' (' .. cost .. 'gp).')
	end

	return true
end

function doPlayerWithdrawMoney(cid, amount)
	if(not getBooleanFromString(getConfigInfo('bankSystem'))) then
		return false
	end

	local balance = getPlayerBalance(cid)
	if(amount > balance or not doPlayerAddMoney(cid, amount)) then
		return false
	end

	doPlayerSetBalance(cid, balance - amount)
	return true
end

function doPlayerDepositMoney(cid, amount)
	if(not getBooleanFromString(getConfigInfo('bankSystem'))) then
		return false
	end

	if(not doPlayerRemoveMoney(cid, amount)) then
		return false
	end

	doPlayerSetBalance(cid, getPlayerBalance(cid) + amount)
	return true
end

function isPremium(cid)
	return (isPlayer(cid) and (getPlayerPremiumDays(cid) > 0 or getBooleanFromString(getConfigInfo('freePremium'))))
end

function getMonthDayEnding(day)
	if(day == "01" or day == "21" or day == "31") then
		return "st"
	elseif(day == "02" or day == "22") then
		return "nd"
	elseif(day == "03" or day == "23") then
		return "rd"
	end

	return "th"
end

function getMonthString(m)
	return os.date("%B", os.time{year = 1970, month = m, day = 1})
end

function getArticle(str)
	return str:find("[AaEeIiOoUuYy]") == 1 and "an" or "a"
end

function isNumber(str)
	return tonumber(str) ~= nil
end

function doPlayerAddAddons(cid, addon)
	for i = 0, table.maxn(maleOutfits) do
		doPlayerAddOutfit(cid, maleOutfits[i], addon)
	end

	for i = 0, table.maxn(femaleOutfits) do
		doPlayerAddOutfit(cid, femaleOutfits[i], addon)
	end
end

function doPlayerWithdrawAllMoney(cid)
	return doPlayerWithdrawMoney(cid, getPlayerBalance(cid))
end

function doPlayerDepositAllMoney(cid)
	return doPlayerDepositMoney(cid, getPlayerMoney(cid))
end

function doPlayerTransferAllMoneyTo(cid, target)
	return doPlayerTransferMoneyTo(cid, target, getPlayerBalance(cid))
end

function playerExists(name)
	return getPlayerGUIDByName(name) ~= 0
end

function getTibiaTime()
	local minutes = getWorldTime()
	local hours = 0
	while (minutes > 60) do
		hours = hours + 1
		minutes = minutes - 60
	end

	return {hours = hours, minutes = minutes}
end

function doWriteLogFile(file, text)
	local f = io.open(file, "a+")
	if(not f) then
		return false
	end

	f:write("[" .. os.date("%d/%m/%Y %H:%M:%S") .. "] " .. text .. "\n")
	f:close()
	return true
end

function getExperienceForLevel(lv)
	lv = lv - 1
	return ((50 * lv * lv * lv) - (150 * lv * lv) + (400 * lv)) / 3
end

function doMutePlayer(cid, time)
	local condition = createConditionObject(CONDITION_MUTED)
	setConditionParam(condition, CONDITION_PARAM_TICKS, time * 1000)
	return doAddCondition(cid, condition)
end

function getPlayerGroupName(cid)
	return getGroupInfo(getPlayerGroupId(cid)).name
end

function getPlayerVocationName(cid)
	return getVocationInfo(getPlayerVocation(cid)).name
end

function getPromotedVocation(vid)
	return getVocationInfo(vid).promotedVocation
end

function doPlayerRemovePremiumDays(cid, days)
	return doPlayerAddPremiumDays(cid, -days)
end

function getPlayerMasterPos(cid)
	return getTownTemplePosition(getPlayerTown(cid))
end

function getHouseOwner(houseId)
	return getHouseInfo(houseId).owner
end

function getHouseName(houseId)
	return getHouseInfo(houseId).name
end

function getHouseEntry(houseId)
	return getHouseInfo(houseId).entry
end

function getHouseRent(houseId)
	return getHouseInfo(houseId).rent
end

function getHousePrice(houseId)
	return getHouseInfo(houseId).price
end

function getHouseTown(houseId)
	return getHouseInfo(houseId).town
end

function getHouseTilesCount(houseId)
	return getHouseInfo(houseId).tiles
end

function getItemNameById(itemid)
	local r = getItemDescriptionsById(itemid)
	return r and r.name or ''
end

function getItemPluralNameById(itemid)
	return getItemDescriptionsById(itemid).plural
end

function getItemArticleById(itemid)
	return getItemDescriptionsById(itemid).article
end

function getItemName(uid)
	return getItemDescriptions(uid).name
end

function getItemPluralName(uid)
	return getItemDescriptions(uid).plural
end

function getItemArticle(uid)
	return getItemDescriptions(uid).article
end

function getItemText(uid)
	return getItemDescriptions(uid).text
end

function getItemSpecialDescription(uid)
	return getItemDescriptions(uid).special
end

function getItemWriter(uid)
	return getItemDescriptions(uid).writer
end

function getItemDate(uid)
	return getItemDescriptions(uid).date
end

function getTilePzInfo(pos)
	return getTileInfo(pos).protection
end

function getTileZoneInfo(pos)
	local tmp = getTileInfo(pos)
	if(tmp.pvp) then
		return 2
	end

	if(tmp.nopvp) then
		return 1
	end

	return 0
end

function doShutdown()
	return doSetGameState(GAMESTATE_SHUTDOWN)
end

function doSummonCreature(name, pos, displayError)
	local displayError, cid = displayError or false, doCreateMonster(name, pos, displayError)
	if(not cid) then
		cid = doCreateNpc(name, pos, displayError)
	end

	return cid
end

function getOnlinePlayers()
	local tmp = getPlayersOnline()
	local players = {}
	for i, cid in ipairs(tmp) do
		table.insert(players, getCreatureName(cid))
	end

	return players
end

function getPlayerByName(name)
	local cid = getCreatureByName(name)
	return isPlayer(cid) and cid or nil
end

function isPlayer(cid)
	return isCreature(cid) and cid >= AUTOID_PLAYERS and cid < AUTOID_MONSTERS
end

function isPlayerGhost(cid, onlyCondition)
	if(not isPlayer(cid)) then
		return false
	end

	return getCreatureCondition(cid, CONDITION_GAMEMASTER, GAMEMASTER_INVISIBLE) or
            (not onlyCondition and getPlayerFlagValue(cid, PLAYERFLAG_CANNOTBESEEN))
end

function isMonster(cid)
	return isCreature(cid) and cid >= AUTOID_MONSTERS and cid < AUTOID_NPCS
end
--[[ This function now is implemented on source due to bug with tfs
function isNpc(cid)
	return isCreature(cid) and math.abs(cid) >= AUTOID_NPCS -- TFS has a bug with NPCs uids (uint32 x int32, m_lastUID)
end
]]
function doPlayerSetExperienceRate(cid, value)
	return doPlayerSetRate(cid, SKILL__LEVEL, value)
end

function doPlayerSetMagicRate(cid, value)
	return doPlayerSetRate(cid, SKILL__MAGLEVEL, value)
end

function doPlayerAddLevel(cid, amount, round)
	local experience, level = 0, getPlayerLevel(cid)
	if(amount > 0) then
		experience = getExperienceForLevel(level + amount) - (round and getPlayerExperience(cid) or getExperienceForLevel(level))
	else
		experience = -((round and getPlayerExperience(cid) or getExperienceForLevel(level)) - getExperienceForLevel(level + amount))
	end

	return doPlayerAddExperience(cid, experience)
end

function doPlayerAddMagLevel(cid, amount)
	for i = 1, amount do
		doPlayerAddSpentMana(cid, (getPlayerRequiredMana(cid, getPlayerMagLevel(cid, true) + 1) - getPlayerSpentMana(cid)) / getConfigInfo('rateMagic'))
	end
	return true
end

function doPlayerAddSkill(cid, skill, amount, round)
	if(skill == SKILL__LEVEL) then
		return doPlayerAddLevel(cid, amount, round)
	elseif(skill == SKILL__MAGLEVEL) then
		return doPlayerAddMagLevel(cid, amount)
	end

	return doPlayerAddSkillTry(cid, skill, (getPlayerRequiredSkillTries(cid, skill, getPlayerSkillLevel(cid, skill) + 1) - getPlayerSkillTries(cid, skill)) / getConfigInfo('rateSkill'))
end

function getPartyLeader(cid)
	local party = getPartyMembers(cid)
	if(type(party) ~= 'table') then
		return 0
	end

	return party[1]
end

function isInParty(cid)
	return type(getPartyMembers(cid)) == 'table'
end

function isPrivateChannel(channelId)
	return channelId >= CHANNEL_PRIVATE
end

function doPlayerResetIdleTime(cid)
	return doPlayerSetIdleTime(cid, 0)
end

-- doSendCustomBroadcastMessage("texto aqui", "#75e545", "images/broadcast/megaphone", 5500, 0.8)

function doSendCustomBroadcastMessage(str, color, icon, time, opacity)
    local infoToSend = {
        action = "showBroadcastNotification",
        background_color = color,
        opacity = opacity,
        icon = icon,
        time = time,
        text = str,
    }

	local players = getPlayersOnline()
	for _, pid in ipairs(players) do
        doSendPlayerExtendedOpcode(pid, 25, json.encode(infoToSend))
	end
end

function doSendShopRent(cid)
local response = {
	value = "GoldRent",
    Drent = getPlayerItemCount(cid, 34524),
    Prent = getPlayerStorageValue(cid, 414141),
}
doSendPlayerExtendedOpcode(cid, 27, json.encode(response))
end

function doBroadcastMessage(text, class)
	local class = class or MESSAGE_STATUS_WARNING
	if(type(class) == 'string') then
		local className = MESSAGE_TYPES[class]
		if(className == nil) then
			return false
		end

		class = className
	elseif(class < MESSAGE_FIRST or class > MESSAGE_LAST) then
		return false
	end

	local players = getPlayersOnline()
	for _, pid in ipairs(players) do
		doPlayerSendTextMessage(pid, class, text)
	end

	log(LOG_TYPES.INFO, "> Broadcasted message: \"" .. text .. "\".")
	return true
end

function doPlayerBroadcastMessage(cid, text, class, checkFlag, ghost)
	local checkFlag, ghost, class = checkFlag or true, ghost or false, class or TALKTYPE_BROADCAST
	if(checkFlag and not getPlayerFlagValue(cid, PLAYERFLAG_CANBROADCAST)) then
		return false
	end

	if(type(class) == 'string') then
		local className = TALKTYPE_TYPES[class]
		if(className == nil) then
			return false
		end

		class = className
	elseif(class < TALKTYPE_FIRST or class > TALKTYPE_LAST) then
		return false
	end

	local players = getPlayersOnline()
	for _, pid in ipairs(players) do
		doCreatureSay(cid, text, class, ghost, pid)
	end

	log(LOG_TYPES.INFO, "> " .. getCreatureName(cid) .. " broadcasted message: \"" .. text .. "\".")
	return true
end

function getBooleanFromString(input)
	local tmp = type(input)
	if(tmp == 'boolean') then
		return input
	end

	if(tmp == 'number') then
		return input > 0
	end

	local str = string.lower(tostring(input))
	return (str == "yes" or str == "true" or (tonumber(str) ~= nil and tonumber(str) > 0))
end

function doCopyItem(item, attributes)
	local attributes = attributes or false

	local ret = doCreateItemEx(item.itemid, item.type)
	if(attributes) then
		if(item.actionid > 0) then
			doItemSetAttribute(ret, "aid", item.actionid)
		end
	end

	if(isContainer(item.uid)) then
		for i = (getContainerSize(item.uid) - 1), 0, -1 do
			local tmp = getContainerItem(item.uid, i)
			if(tmp.itemid > 0) then
				doAddContainerItemEx(ret, doCopyItem(tmp, true).uid)
			end
		end
	end

	return getThing(ret)
end

function doRemoveThing(uid)
	if(isCreature(uid)) then
		return doRemoveCreature(uid)
	end

	return doRemoveItem(uid)
end

function setAttackFormula(combat, type, minl, maxl, minm, maxm, min, max)
	local min, max = min or 0, max or 0
	return setCombatFormula(combat, type, -1, 0, -1, 0, minl, maxl, minm, maxm, min, max)
end

function setHealingFormula(combat, type, minl, maxl, minm, maxm, min, max)
	local min, max = min or 0, max or 0
	return setCombatFormula(combat, type, 1, 0, 1, 0, minl, maxl, minm, maxm, min, max)
end

function doChangeTypeItem(uid, subtype)
	local thing = getThing(uid)
	if(thing.itemid < 100) then
		return false
	end

	local subtype = subtype or 1
	return doTransformItem(thing.uid, thing.itemid, subtype)
end

function doSetItemText(uid, text, writer, date)
	local thing = getThing(uid)
	if(thing.itemid < 100) then
		return false
	end

	doItemSetAttribute(uid, "text", text)
	if(writer ~= nil) then
		doItemSetAttribute(uid, "writer", tostring(writer))
		if(date ~= nil) then
			doItemSetAttribute(uid, "date", tonumber(date))
		end
	end

	return true
end

function getFluidSourceType(itemid)
	local item = getItemInfo(itemid)
	return item and item.fluidSource or false
end

function getDepotId(uid)
	return getItemAttribute(uid, "depotid") or false
end

function getItemDescriptions(uid)
	local thing = getThing(uid)
	if(thing.itemid < 100) then
		return false
	end

	local item = getItemInfo(thing.itemid)
	return {
		name = getItemAttribute(uid, "name") or item.name,
		plural = getItemAttribute(uid, "pluralname") or item.plural,
		article = getItemAttribute(uid, "article") or item.article,
		special = getItemAttribute(uid, "description") or "",
		text = getItemAttribute(uid, "text") or "",
		writer = getItemAttribute(uid, "writer") or "",
		date = getItemAttribute(uid, "date") or 0
	}
end

function getItemWeightById(itemid, count, precision)
	local item, count, precision = getItemInfo(itemid), count or 1, precision or false
	if(not item) then
		return false
	end

	if(count > 100) then
		-- print a warning, as its impossible to have more than 100 stackable items without "cheating" the count
		print('[Warning] getItemWeightById', 'Calculating weight for more than 100 items!')
	end

	local weight = item.weight * count
	--[[if(precision) then
		return weight
	end

	local t = string.explode(tostring(weight), ".")
	if(table.maxn(t) == 2) then
		return tonumber(t[1] .. "." .. string.sub(t[2], 1, 2))
	end]]--

	return weight
end

function getItemWeaponType(uid)
	local thing = getThing(uid)
	if(thing.itemid < 100) then
		return false
	end

	return getItemInfo(thing.itemid).weaponType
end

function getItemRWInfo(uid)
	local thing = getThing(uid)
	if(thing.itemid < 100) then
		return false
	end

	local item, flags = getItemInfo(thing.itemid), 0
	if(item.readable) then
		flags = 1
	end

	if(item.writable) then
		flags = flags + 2
	end

	return flags
end

function getItemLevelDoor(itemid)
	local item = getItemInfo(itemid)
	return item and item.levelDoor or false
end

function isItemStackable(itemid)
	local item = getItemInfo(itemid)
	return item and item.stackable or false
end

function isItemRune(itemid)
	local item = getItemInfo(itemid)
	return item and item.clientCharges or false
end

function isItemDoor(itemid)
	local item = getItemInfo(itemid)
	return item and item.type == 5 or false
end

function isItemContainer(itemid)
	local item = getItemInfo(itemid)
	return item and item.group == 2 or false
end

function isItemFluidContainer(itemid)
	local item = getItemInfo(itemid)
	return item and item.group == 12 or false
end

function isItemMovable(itemid)
	local item = getItemInfo(itemid)
	return item and item.movable or false
end

function isCorpse(uid)
	local thing = getThing(uid)
	if(thing.itemid < 100) then
		return false
	end

	local item = getItemInfo(thing.itemid)
	return item and item.corpseType ~= 0 or false
end

function getContainerCapById(itemid)
	local item = getItemInfo(itemid)
	if(not item or item.group ~= 2) then
		return false
	end

	return item.maxItems
end

function getMonsterAttackSpells(name)
	local monster = getMonsterInfo(name)
	return monster and monster.attacks or false
end

function getMonsterHealingSpells(name)
	local monster = getMonsterInfo(name)
	return monster and monster.defenses or false
end

function getMonsterLootList(name)
	local monster = getMonsterInfo(name)
	return monster and monster.loot or false
end

function getMonsterSummonList(name)
	local monster = getMonsterInfo(name)
	return monster and monster.summons or false
end

function getTimeString(self)
    local format = {
        {'dia', self / 60 / 60 / 24},
        {'hora', self / 60 / 60 % 24},
        {'minuto', self / 60 % 60},
        {'segundo', self % 60}
    }
    
    local out = {}
    for k, t in ipairs(format) do
        local v = math.floor(t[2])
        if(v > 0) then
            table.insert(out, (k < #format and (#out > 0 and ', ' or '') or ' e ') .. v .. ' ' .. t[1] .. (v ~= 1 and 's' or ''))
        end
    end
    local ret = table.concat(out)
    if ret:len() < 16 and ret:find('segundo') then
        local a, b = ret:find(' e ')
        ret = ret:sub(b+1)
    end
    return ret
end

function isPlayerOnline(name)
	local queryResult = db.storeQuery("SELECT `online` FROM `players` WHERE `name` = '"..name.."'")
	local result = result.getDataInt(queryResult, "online") > 0 and true or false
	return result
end

function getOfflinePlayerStorage(guid, storage)
	if not isPlayerOnline(getPlayerNameByGUID(guid)) then
		local queryResult = db.storeQuery("SELECT `value` FROM `player_storage` WHERE `key` = '"..storage.."' and `player_id` = "..guid.."")
		local result = queryResult and result.getDataInt(queryResult, "value") or -1
		return result
	end
end

function setOfflinePlayerStorage(guid, storage, value)
	if not isPlayerOnline(getPlayerNameByGUID(guid)) then
		db.query("UPDATE `player_storage` SET `value` = '"..value.."' WHERE `key` = '"..storage.."' and `player_id` = "..guid.."")
	end
end

function getItemNameByCount(itemID, count)
	if tonumber(count) and count > 1 and isItemStackable(itemID) then
		return getItemInfo(itemID).plural
	end
	return getItemNameById(itemID)
end

function printTable(_table)
	local function getTable(_table, expand, tabs)
		
		local aux = ""
		if not type(_table) == "table" then
			return _table
		else
			for key,value in pairs(_table) do
				if type(value) == "table" then
				
					for i = 1, tabs -1 do
						aux = aux.."\t"
					end
					
					if type(key)  == "string" then
						aux = aux.. '["'..key..'"] =\t{ \n'..getTable(value, true, tabs +1)
					else
						aux = aux.. "["..key.."] =\t{ \n"..getTable(value, true, tabs +1)
					end
					
					for i = 1, tabs do
						aux = aux.. "\t"
					end
					
					aux = aux.."},\n"				
				else
					if expand then
						for i = 1, tabs -1 do
							aux = aux.. "\t"
						end
					end
					if type(key)  == "string" then
						aux = aux.. '["'..key..'"] = '..(type(value) == "string" and '"'..value..'"' or tostring(value))..",\n"
					else
						aux = aux.. '['..key..'] = '..(type(value) == "string" and '"'..value..'"' or tostring(value))..",\n"
					end
				end
			end
		end

		return aux
	end
    if type(_table) == "table" then
        print(getTable(_table, false, 1))
        return true
    else
        error("Parameter is not a table!")
        return false
    end
end