function onSay(cid, words, param)
	local autoLoot = not getPlayerAutoLoot(cid)
	setPlayerAutoLoot(cid, autoLoot)
	setPlayerAutoLootSave(cid, autoLoot)
	-- the client's Auto loot setting follows, so the next login doesn't send the old value back
	doSendPlayerExtendedOpcode(cid, EXTENDED_IDS.AUTO_LOOT, autoLoot and "1" or "0")
	doPlayerSendTextMessage(cid, MESSAGE_EVENT_ORANGE, string.format(__L(cid, "Auto Loot %s!"), (autoLoot and "ON" or "OFF")))
	return true
end
