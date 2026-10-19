-- Redemption only measures the ping for protocol 953 and newer, and its ping packet is the keep-alive answer on
-- PokeVerse's protocol. This sends ExtendedIds.Ping instead (the server echoes it) and hands the round trip to
-- the onPingBack listeners, so the Show connection ping option (client_topmenu) has a value to show.
local INTERVAL = 2000
local TIMEOUT = 10000

local seq = 0
local sentAt
local tickEvent

local function report(ms)
    signalcall(g_game.onPingBack, ms)
end

local function tick()
    tickEvent = scheduleEvent(tick, INTERVAL)
    local protocol = g_game.getProtocolGame()
    if not protocol or not g_game.isOnline() or not modules.client_options.getOption('showPing') then
        sentAt = nil
        return
    end
    if sentAt then
        if g_clock.millis() - sentAt < TIMEOUT then
            return
        end
        report(-1)
    end
    seq = seq + 1
    sentAt = g_clock.millis()
    protocol:sendExtendedOpcode(ExtendedIds.Ping, tostring(seq))
end

local function onPing(protocol, opcode, buffer)
    if sentAt and tonumber(buffer) == seq then
        report(math.max(0, g_clock.millis() - sentAt))
        sentAt = nil
    end
end

local function stop()
    removeEvent(tickEvent)
    tickEvent = nil
    sentAt = nil
end

local function onGameStart()
    stop()
    tickEvent = scheduleEvent(tick, 1000)
end

function init()
    ProtocolGame.registerExtendedOpcode(ExtendedIds.Ping, onPing)
    connect(g_game, { onGameStart = onGameStart, onGameEnd = stop })
    if g_game.isOnline() then
        onGameStart()
    end
end

function terminate()
    stop()
    ProtocolGame.unregisterExtendedOpcode(ExtendedIds.Ping)
    disconnect(g_game, { onGameStart = onGameStart, onGameEnd = stop })
end
