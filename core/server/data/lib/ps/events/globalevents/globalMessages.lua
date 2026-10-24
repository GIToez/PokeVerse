-- The rotating tips (093-tips.lua), one every Tips.INTERVAL_MINUTES
function onThink()
	Tips.broadcast()
	return true
end
