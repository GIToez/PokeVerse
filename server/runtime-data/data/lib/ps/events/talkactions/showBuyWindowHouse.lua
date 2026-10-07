-- The legacy client says "showbuywindowhouse" when it opens the buy window of an unowned house.
-- Consume the word so it is not spoken in public chat; there is nothing to do server-side.
function onSay(cid, words, param, channel)
	return true
end
