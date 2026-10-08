function onSay(cid, words, param, channel)
	if(param == '') then
		return true
	end

	if(doPlayerBroadcastMessage(cid, param)) then
		DiscordBridge.onBroadcast("gm", getCreatureName(cid), param)
	end
	return true
end
