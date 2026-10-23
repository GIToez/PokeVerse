-- /forceoutfit <look>[, player]: puts any look (a Pokemon, or a client outfit like 2591) on a trainer until
-- they relog or choose an outfit themselves; it isn't added to their outfits.
-- /forceoutfit off[, player]: gives them their own outfit back now. /newtype is the old name.
function onSay(cid, words, param, channel)
	if(param == '') then
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Usage: " .. words .. " <look>[, player] or " .. words .. " off[, player]")
		return true
	end

	local t = string.explode(param, ",")
	local what = t[1]:lower():gsub("^%s+", ""):gsub("%s+$", "")
	local look = tonumber(what)
	if(not look and what ~= "off") then
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Give a look number, or off.")
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

	if(not look) then
		if(doPlayerRestoreForcedOutfit(pid)) then
			doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, getCreatureName(pid) .. " has their own outfit back.")
		else
			doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, getCreatureName(pid) .. " has no forced look.")
		end
		return true
	end

	if(look < 2 or look > 65535) then
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Such outfit does not exist.")
		return true
	end

	if(getCreatureCondition(pid, CONDITION_OUTFIT)) then
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, getCreatureName(pid) ..
			" is flying, riding, surfing or transformed right now. Try again when they are back on foot.")
		return true
	end

	doPlayerForceOutfit(pid, look)
	doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, getCreatureName(pid) .. " now looks like outfit " .. look ..
		" until they relog or choose an outfit.")
	return true
end
