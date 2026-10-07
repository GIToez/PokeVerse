local shutdownEvent = 0

-- English keys of pt_br.loc; players get them in their own language.
local SHUTDOWN_MESSAGES = {
	oneMinute = "Server is going down in %d minute for an update, please log out now! We will be back in 10 minutes. More information on: TODO - POKEVERSE URL REQUIRED",
	fewMinutes = "Server is going down in %d minutes for an update, please log out. We will be back in 10 minutes. More information on: TODO - POKEVERSE URL REQUIRED",
	minutes = "Server is going down in %d minutes for an update. We will be back in 10 minutes. More information on: TODO - POKEVERSE URL REQUIRED",
}

function onSay(cid, words, param, channel)
	if(param == '') then
		doSetGameState(GAMESTATE_SHUTDOWN)
		return true
	end

	if(param:lower() == "stop") then
		stopEvent(shutdownEvent)
		shutdownEvent = 0
		return true
	elseif(param:lower() == "kill") then
		os.exit()
		return true
	end

	param = tonumber(param)
	if(not param or param < 0) then
		doPlayerSendCancel(cid, "Numeric param may not be lower than 0.")
		return true
	end

	if(shutdownEvent ~= 0) then
		stopEvent(shutdownEvent)
	end

	return prepareShutdown(math.abs(math.ceil(param)))
end

function prepareShutdown(minutes)
	if(minutes <= 0) then
		doSetGameState(GAMESTATE_SHUTDOWN)
		return false
	end

	local text
	if(minutes == 1) then
		text = SHUTDOWN_MESSAGES.oneMinute
	elseif(minutes <= 3) then
		text = SHUTDOWN_MESSAGES.fewMinutes
	else
		text = SHUTDOWN_MESSAGES.minutes
	end
	for _, pid in ipairs(getPlayersOnline()) do
		doPlayerSendTextMessage(pid, MESSAGE_STATUS_WARNING, string.format(__L(pid, text), minutes))
	end
	log(LOG_TYPES.INFO, "> Broadcasted message: \"" .. string.format(text, minutes) .. "\".")

	shutdownEvent = addEvent(prepareShutdown, 60000, minutes - 1)
	return true
end
