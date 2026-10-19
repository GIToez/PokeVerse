local SAY_HI = 'hi'

function onTalkChannel(cid, channelId, message)
    if (channelId == CHANNEL_HELP and message == SAY_HI) then
        doCreatureSay(cid, SAY_HI, TALKTYPE_SAY)
        return false -- Hide player message
    end

    DiscordBridge.onTalkChannel(cid, channelId, message)
    Reports.onChannelMessage(cid, channelId, message)
    return true
end