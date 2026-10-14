function onUse(cid, item, fromPosition, itemEx, toPosition)
	if (not GTS.open(cid)) then -- the GTS window needs OTClient
		doPlayerSendChannelsDialog(cid, {CHANNEL_HIGHSCORES, CHANNEL_CAUGHTS})
	end
	return true
end
