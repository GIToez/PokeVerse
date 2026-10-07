function onDeEquip(cid, item)
	setPlayerIcons(cid, item, false)
	doSendShopRent(cid)
	sendTickesCount(cid)
	return true
end

function onEquip(cid, item)
	if (isItem(item)) then
		setPlayerIcons(cid, item, true)
		doSendShopRent(cid)
		sendTickesCount(cid)
		return true
	end
	return false
end

