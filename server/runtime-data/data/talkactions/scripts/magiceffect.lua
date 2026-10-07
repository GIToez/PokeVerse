function onSay(cid, words, param, channel)
	param = tonumber(param)

	doSendMagicEffect(getCreaturePosition(cid), param)
	return true
end
