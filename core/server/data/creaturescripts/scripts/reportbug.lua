function onReportBug(cid, comment)
	local pos = getCreaturePosition(cid)
	if(db.executeQuery("INSERT INTO `server_reports` (`id`, `world_id`, `player_id`, `posx`, `posy`, `posz`, `timestamp`, `report`) VALUES (NULL, " ..
		getConfigValue('worldId') .. ", " .. getPlayerGUID(cid) .. ", " ..
		pos.x .. ", " .. pos.y .. ", " .. pos.z .. ", " ..
		os.time() .. ", " .. db.escapeString(comment) .. ")"))
	then
		doPlayerSendTextMessage(cid, MESSAGE_EVENT_DEFAULT, "Your report has been sent to the PokeVerse team.")
	else
		doPlayerSendTextMessage(cid, MESSAGE_EVENT_DEFAULT, "Your report couldn't be saved, please contact a gamemaster.")
	end

	return true
end
