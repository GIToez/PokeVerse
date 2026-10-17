function onThink(interval, lastExecution, thinkInterval)
	EventCalendar.onThink()
	Daycare.onThink()
	ShinyEvent.onThink()
	WildLegendaries.onThink()
	Weather.onThink()
	Decorations.onThink()
	return ServerExpEvent.onThink()
end
