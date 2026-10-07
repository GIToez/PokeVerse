depotLocker = {

	config = {
		useBoard = false,
		passMinLength = 5,
		passMaxLength = 12,
		askPassOnlyOneTimePerLogin = true,
		boardIDs = {},
		depotIDs = {26131, 26132, 26130, 26155, 2589, 2590, 2591, 2592}, -- South, West, North and East
		typeYourPassMsg = "Digite sua senha: ",
		rightPassMsg = "Senha correta, depósito liberado.",
		wrongPassMsg = "Senha incorreta, tente novamente.",
		wrongTries = {
			limitTries = true,
			triesBeforeBlock = 999999999999,
			blockTime = 2 * 60, -- 15 Minutos
			triesLeftMsg = "Senha incorreta, você ainda tem %s tentativa.",
			blockMsg = "Depósito bloqueado, tente novamente em %s."
		},
		actionIDs = {
			board = 9991,
			depotTile = 9992
		}
	},
	
	storages = {
		lockState = 42610,
		password = 42611,
		wrongTries = 42612,
		blockTime = 42613,
	}
}

-- FunÃ§Ãµes --
depotLocker.checkPasswordSecurity = function(password)
	if string.len(password) < depotLocker.config.passMinLength then
		return "Sua senha precisa de no minimo "..depotLocker.config.passMinLength.." digitos, digite novamente.", false
	elseif string.len(password) > depotLocker.config.passMaxLength then
		return "Sua senha pode ter no maximo "..depotLocker.config.passMaxLength.." digitos, digite novamente.", false
	end
	return true
end

depotLocker.setPlayerPassword = function(cid, password)
	if setPlayerStorageValue(cid, depotLocker.storages.password, password) then
		return true
	end
	return false
end

depotLocker.getPlayerPassword = function(cid)
	if getPlayerStorageValue(cid, depotLocker.storages.password) and getPlayerStorageValue(cid, depotLocker.storages.password) ~= -1 then
		local password = getPlayerStorageValue(cid, depotLocker.storages.password)
		return password
	end
	return false
end

depotLocker.isLocked = function(cid)
	if depotLocker.getPlayerPassword(cid) and getPlayerStorageValue(cid, depotLocker.storages.lockState) < 1 then
		return true
	end
	return false
end

depotLocker.checkPassword = function(cid, password)
	if depotLocker.getPlayerPassword(cid) then
		if (password == depotLocker.config.typeYourPassMsg) then
			return false
		end	
		if getPlayerStorageValue(cid, depotLocker.storages.blockTime) < os.time() then
			local playerPass = depotLocker.getPlayerPassword(cid)
			if (password == depotLocker.config.typeYourPassMsg..playerPass) or (password == playerPass) then
				setPlayerStorageValue(cid, depotLocker.storages.lockState, 1)
				doSendMagicEffect(getCreaturePosition(cid), CONST_ME_MAGIC_GREEN)
				doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, depotLocker.config.rightPassMsg)
				return true
			else
				if depotLocker.config.wrongTries.limitTries then
					local wrongTries = math.max(0, tonumber(getPlayerStorageValue(cid, depotLocker.storages.wrongTries)))
					setPlayerStorageValue(cid, depotLocker.storages.wrongTries, wrongTries+1)
					if wrongTries >= depotLocker.config.wrongTries.triesBeforeBlock then
						setPlayerStorageValue(cid, depotLocker.storages.wrongTries, 0)
						setPlayerStorageValue(cid, depotLocker.storages.blockTime, os.time() + depotLocker.config.wrongTries.blockTime)
						doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, string.format(depotLocker.config.wrongTries.blockMsg, getTimeString(depotLocker.config.wrongTries.blockTime)))
					else				
						doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, string.format(depotLocker.config.wrongTries.triesLeftMsg, (depotLocker.config.wrongTries.triesBeforeBlock - wrongTries)))
					end
				else
					doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, depotLocker.config.wrongPassMsg)					
				end
				doSendMagicEffect(getCreaturePosition(cid), CONST_ME_MAGIC_RED)
			end
		else
			doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, string.format(depotLocker.config.wrongTries.blockMsg, getTimeString(getPlayerStorageValue(cid, depotLocker.storages.blockTime) - os.time())))
		end
	end
	return false
end

depotLocker.getEvironmentData = function(playerPos)
	data = {}
	local boardIDs = {
		[{depotLocker.config.depotIDs[1], depotLocker.config.depotIDs[3]}] = depotLocker.config.boardIDs[2],
		[{depotLocker.config.depotIDs[2], depotLocker.config.depotIDs[4]}] = depotLocker.config.boardIDs[1],
	}
	local crossDir = {{0, -1}, {1, 0}, {0, 1}, {-1, 0}}
	local depotPos
	for i = 1, #depotLocker.config.depotIDs do
		for k, v in pairs(crossDir) do
			depotPos = {x = playerPos.x, y = playerPos.y, z = playerPos.z, stackpos = playerPos.stackpos}
			depotPos.x = depotPos.x + v[1]
			depotPos.y = depotPos.y + v[2]
			local depot = getTileItemById(depotPos, depotLocker.config.depotIDs[i])
			if depot.itemid == depotLocker.config.depotIDs[i] then
				data.depotID = depotLocker.config.depotIDs[i]
				for a, b in pairs(boardIDs) do
					if depotLocker.config.depotIDs[i] == a[1] or depotLocker.config.depotIDs[i] == a[2] then
						data.boardID = b
						break
					end
				end
				data.depotPos = depotPos
				data.boardPos = {x = depotPos.x, y = depotPos.y, z = depotPos.z, stackpos = depotPos.stackpos}
				if playerPos.y ~= depotPos.y then
					data.boardPos.x = data.boardPos.x - 1
				elseif playerPos.x ~= depotPos.x then
					data.boardPos.y = data.boardPos.y - 1
				end
				break
			end
		end
	end
    return data
end