function onThink()
	if (EventCalendar.isActive("anniversary")) then
		AnniversaryEvent.doStartEvent()
	end
	return true
end
