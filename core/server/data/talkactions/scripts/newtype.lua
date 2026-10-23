-- /newtype <look>[, player]: puts any look (a Pokemon, or a client outfit like 2591) on a trainer until
-- they relog or choose an outfit themselves; it isn't added to their outfits
function onSay(cid, words, param, channel)
	if(param == '') then
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Command requires param.")
		return true
	end

	local t = string.explode(param, ",")
	t[1] = tonumber(t[1])
	if(not t[1]) then
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Command requires numeric param.")
		return true
	end

	local pid = cid
	if(t[2]) then
		pid = getPlayerByNameWildcard(t[2])
		if(not pid or (isPlayerGhost(pid) and getPlayerGhostAccess(pid) > getPlayerGhostAccess(cid))) then
			doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Player " .. t[2] .. " not found.")
			return true
		end
	end

	if(t[1] < 2 or t[1] > 65535) then
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Such outfit does not exist.")
		return true
	end

	if(getCreatureCondition(pid, CONDITION_OUTFIT)) then
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, getCreatureName(pid) ..
			" is flying, riding, surfing or transformed right now. Try again when they are back on foot.")
		return true
	end

	doPlayerForceOutfit(pid, t[1])
	doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, getCreatureName(pid) .. " now looks like outfit " .. t[1] ..
		" until they relog or choose an outfit.")
	return true
end
