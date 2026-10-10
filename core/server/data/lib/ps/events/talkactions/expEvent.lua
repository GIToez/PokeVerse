function onSay(cid, words, param)
    doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, ServerExpEvent.describe())
    return true
end
