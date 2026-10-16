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
    return true
end
