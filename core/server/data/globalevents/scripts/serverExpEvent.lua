function onThink(interval, lastExecution, thinkInterval)
	Daycare.onThink()
	return ServerExpEvent.onThink()
end
