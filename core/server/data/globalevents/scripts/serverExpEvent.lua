function onThink(interval, lastExecution, thinkInterval)
	EventCalendar.onThink()
	Daycare.onThink()
	ShinyEvent.onThink()
	return ServerExpEvent.onThink()
end
