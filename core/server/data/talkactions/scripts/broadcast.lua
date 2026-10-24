function onSay(cid, words, param, channel)
	if(param == '') then
		return true
	end

	-- "/b @everyone text": the tag picks the Discord ping and isn't shown in game
	local ping, text, tag = Announcements.takePing(cid, param)
	if(tag and not ping) then
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Only Gamemasters and up can ping @" .. tag .. " on Discord. Sent without the ping.")
	end
	if(getPlayerFlagValue(cid, PLAYERFLAG_CANBROADCAST)) then
		Announcements.staff(cid, text, ping)
	end
	if(doPlayerBroadcastMessage(cid, text)) then
		DiscordBridge.onBroadcast("gm", getCreatureName(cid), text)
	end
	return true
end
