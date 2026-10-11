function onSay(cid, words, param)
local response = {
	value = "OpenShop",
    Drent = getPlayerItemCount(cid, 34524),
    Prent = getPlayerStorageValue(cid, 414141),
}
doSendPlayerExtendedOpcode(cid, 27, json.encode(response))

return true
end