function onThink(interval, lastExecution, thinkInterval)
	Daycare.onThink()
	ShinyEvent.onThink()
	return ServerExpEvent.onThink()
end
