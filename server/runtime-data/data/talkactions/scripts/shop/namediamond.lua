local config = {
	item = {Id = 34524, count = 25},
	paramBlacklist = {"account manager", "god", "tutor", "tester", "shiny", "Shiny"},
	kick = {enabled = false, delay = 2 * 1000},
	forceLogout = false,
	namelockCheck = true,
	vowelsCheck = true,
	maxTextLenght = 29,
	minWordLenght = 3,
	maxWordLenght = 14,
	maxWords = 3
}
 
config.kick.enabled = getBooleanFromString(config.kick.enabled)
config.forceLogout = getBooleanFromString(config.forceLogout)
config.namelockCheck = getBooleanFromString(config.namelockCheck)
config.vowelsCheck = getBooleanFromString(config.vowelsCheck)
function onSay(cid, words, param, channel)
	local t = string.explode(param, ",")
	local len, firstWord, wordCount, textCancel, limit = string.len(tostring(t[1])), true, 0, '', ";"
	if(getConfigValue('sqlType') == 'mysql') then
		limit = db.updateLimiter()
	end
 
	if(param == '') then
		return doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Command param required.")
	elseif(getPlayerGUIDByName(t[1], true) ~= nil) then -- nome ja em uso
		local response = {value = "NameComand",text = {str = "notifi/jaemuso",},}
		doSendPlayerExtendedOpcode(cid, 27, json.encode(response))
		textCancel = "close"
	elseif(getPlayerItemCount(cid, config.item.Id) < config.item.count) then -- sem o item requerido
		local response = {value = "NameComand",text = {str = "error/nodiamond",},}
		doSendPlayerExtendedOpcode(cid, 27, json.encode(response))
		textCancel = "close"
	elseif(not getTilePzInfo(getCreaturePosition(cid))) then -- pz zone
		local response = {value = "NameComand",text = {str = "notifi/pzzone",},}
		doSendPlayerExtendedOpcode(cid, 27, json.encode(response))
		textCancel = "close"
	elseif(len > config.maxTextLenght) then -- tamanho do nome
		local response = {value = "NameComand",text = {str = "notifi/pelomenos",},}
		doSendPlayerExtendedOpcode(cid, 27, json.encode(response))
		textCancel = "close"
	elseif(string.find(t[1]:lower(), "[^%l%s]") ~= nil) then  -- letras invalidas
		local response = {value = "NameComand",text = {str = "error/letrainvalida",},}
		doSendPlayerExtendedOpcode(cid, 27, json.encode(response))
		textCancel = "close"
	else
		paramTemp = ''
		for word in string.gmatch(t[1], "%a+") do
			len, wordCount = string.len(word), wordCount + 1
			if(isInArray(config.paramBlacklist, paramTemp:lower())) then
				local response = {value = "NameComand",text = {str = "error/nomebloqueado",},}  -- bloqueado para uso
				doSendPlayerExtendedOpcode(cid, 27, json.encode(response))
				textCancel = "close"
				break
			elseif(len < config.minWordLenght) then
				local response = {value = "NameComand",text = {str = "notifi/menosdetres",},}  -- palavras com menos de 3 letras
				doSendPlayerExtendedOpcode(cid, 27, json.encode(response))
				textCancel = "close"
				break
			elseif(len > config.maxWordLenght) then
				local response = {value = "NameComand",text = {str = "notifi/palavralonga",},}  -- palavra muito longa
				doSendPlayerExtendedOpcode(cid, 27, json.encode(response))
				textCancel = "close"
				break
			elseif(wordCount > config.maxWords) then
				local response = {value = "NameComand",text = {str = "error/maisdetres",},}  -- mais de tres palavras
				doSendPlayerExtendedOpcode(cid, 27, json.encode(response))
				textCancel = "close"
				break
			elseif(config.vowelsCheck and string.find(word:lower(), "[aeiouy]") == nil) then
				local response = {value = "NameComand",text = {str = "error/semvogais",},}  -- sem vogais
				doSendPlayerExtendedOpcode(cid, 27, json.encode(response))
				textCancel = "close"
				break
			else
				wordTemp = ''
				for i = 1, len do
					letter = string.sub(word, i, i)
					if(i == 1) then
						if(getBooleanFromString(firstWord) and string.find(letter, "%l")) then
							letter = string.upper(letter)
						end
					else
						if(string.find(letter, "%u")) then
							letter = string.lower(letter)
						end
					end
 
					firstWord = false
					wordTemp = "" .. wordTemp .. "" .. letter .. ""
				end
			end
 
			paramTemp = "" .. paramTemp .. "" .. (paramTemp ~= '' and " " or '') .. "" .. wordTemp .. ""
		end
	end
 
	if(textCancel ~= '') then
        doSendShopRent(cid)
		return true
	end
 
	local oldName, guid = getCreatureName(cid), getPlayerGUID(cid)
	t[1] = paramTemp

	doPlayerRemoveItem(cid, config.item.Id, config.item.count)
	if(pcall(doPlayerChangeName, guid, oldName, t[1]) ~= true) then
		db.executeQuery("INSERT INTO `player_namelocks` (`player_id`, `name`, `new_name`, `date`) VALUES (" .. guid .. ", " .. db.escapeString(oldName) .. ", " .. db.escapeString(t[1]) .. ", " .. os.time() .. ");")
		db.executeQuery("UPDATE `players` SET `name` = " .. db.escapeString(t[1]) .. " WHERE `id` = " .. guid .. "" .. limit .. "")
	end

    doSendShopRent(cid)
	local response = {value = "NameComand",text = {str = "check/comprei",},}doSendPlayerExtendedOpcode(cid, 27, json.encode(response))

	addEvent(function(cid)
		if(isPlayer(cid)) then
			local response = {value = "NameReset"} doSendPlayerExtendedOpcode(cid, 27, json.encode(response))
		end
	end, 5 * 1000, cid)
	addEvent(function(cid)
		if(isPlayer(cid)) then
			doRemoveCreature(cid, forceLogout)
		end
	end, 5100, cid)
 
	return true
end