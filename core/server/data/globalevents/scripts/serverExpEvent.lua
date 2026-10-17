function onThink(interval, lastExecution, thinkInterval)
	EventCalendar.onThink()
	Daycare.onThink()
	ShinyEvent.onThink()
	WildLegendaries.onThink()
	return ServerExpEvent.onThink()
end
