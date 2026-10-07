function onAddItem(moveitem, tileitem, position, cid)  
	doSendShopRent(cid)
	return true
end

function onRemoveItem(moveitem, tileitem, position, cid)
	doSendShopRent(cid)
	return false
end

