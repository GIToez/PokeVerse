function onSay(cid, words, param)
	if (not isPokemonOnline(cid)) then
        doPlayerSendCancel(cid, "You must call your Pokemon first.")
	elseif  (isPokemonOnline(cid)) then
		sendPokemonInfo(cid)
		sendTickesCount(cid)
		local info = {Reset = {code = "OpenWindow"}, protocol = "Info"}
		doSendPlayerExtendedOpcode(cid, GameServerOpcodes.PokemonInfo, json.encode(info))
	end
	return true
end