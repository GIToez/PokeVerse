local coins = {
	[ITEM_GOLD_COIN] = {
		to = ITEM_TRILLION_NOTE, 
		effect = TEXTCOLOR_YELLOW
	},
	[ITEM_TRILLION_NOTE] = {
		from = ITEM_GOLD_COIN, 
		effect = TEXTCOLOR_BLUE
	},
}

function onUse(cid, item, fromPosition, itemEx, toPosition)
	if(getPlayerFlagValue(cid, PLAYERFLAG_CANNOTPICKUPITEM)) then
		return false
	end

	local coin = coins[item.itemid]
	if(not coin) then
		return false
	end

	if(coin.to ~= nil and item.type == ITEMCOUNT_MAX) then
		doChangeTypeItem(item.uid, item.type - item.type)
		doPlayerAddItem(cid, coin.to, 1)
		doSendAnimatedText(fromPosition, "$$$", coins[coin.to].effect)
	elseif(coin.from ~= nil) then
		doChangeTypeItem(item.uid, item.type - 1)
		doPlayerAddItem(cid, coin.from, ITEMCOUNT_MAX)
		doSendAnimatedText(fromPosition, "$$$", coins[coin.from].effect)
	end
	return true
end
