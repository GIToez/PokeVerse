function onSay(cid, words, param, channel)
	if(param == '') then
		return true
	end

	if(getPlayerFlagValue(cid, PLAYERFLAG_CANBROADCAST)) then
		Announcements.staff(cid, param)
	end
	if(doPlayerBroadcastMessage(cid, param)) then
		DiscordBridge.onBroadcast("gm", getCreatureName(cid), param)
	end
	return true
end
