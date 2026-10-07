local outfits = {
    [34682] = {storage = 8194, nome = "Hot-Dog" },
}
local msg = MESSAGE_STATUS_CONSOLE_BLUE
function onUse(cid, item, fromPosition, itemEx, toPosition)

    if (getPlayerStorageValue(cid, outfits[item.itemid].storage) == -1) then
            setPlayerStorageValue(cid, outfits[item.itemid].storage, 1)
            doPlayerSendTextMessage(cid, msg, "Parabéns! Você tem uma nova roupa: "..outfits[item.itemid].nome)
			doPlayerSendOutfitWindow(cid)
			doRemoveItem(item.uid)
			doSendMagicEffect(getCreaturePosition(cid), 167)
		else
            doPlayerSendTextMessage(cid, msg, "Você já possui essa roupa.")
			doSendMagicEffect(getCreaturePosition(cid), 1142)
	end
    return true
end