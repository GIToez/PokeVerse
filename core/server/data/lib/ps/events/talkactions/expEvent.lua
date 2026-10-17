function onSay(cid, words, param)
    doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, ServerExpEvent.describe())
    if (ShinyEvent.get()) then
        doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, ShinyEvent.describe())
    end
    for _, kind in ipairs({ "daycare", "breeding" }) do
        if (Daycare.getEvent(kind)) then
            doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, Daycare.describeEvent(kind))
        end
    end
    for _, event in ipairs(EventCalendar.getActive()) do
        doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, string.format("%s: %s %s.", event.name,
            event.description, EventCalendar.describeLeft(event)))
    end
    local nextEvent = EventCalendar.getNext()
    if (nextEvent) then
        doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, string.format("Next on the calendar: %s, in %s (%s server time).",
            nextEvent.name, ServerExpEvent.formatDuration(nextEvent.startsAt - os.time()), os.date("%Y-%m-%d %H:%M", nextEvent.startsAt)))
    end
    return true
end
