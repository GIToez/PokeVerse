-- Runs on the dispatcher thread whenever the Discord bot sent messages (see src/discordbridge.cpp).
function onDiscordBridge()
    DiscordBridge.processIncoming()
    return true
end
