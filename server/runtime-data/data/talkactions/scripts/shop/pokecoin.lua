-- The legacy client shows PokeCoin prices, but the server never had a PokeCoin price list or debit.
-- Refuse explicitly so the command is not broadcast as chat and nothing is granted.
function onSay(cid, words, param, channel)
	SHOP.log(cid, "pokecoin " .. param, 0, "unavailable")
	doSendPlayerExtendedOpcode(cid, 27, json.encode({value = "noactive"}))
	return true
end
