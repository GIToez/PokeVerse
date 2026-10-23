-- PokeVerse game sounds from /sounds/effects. The server sends "name:delayMs;name:delayMs" on
-- ExtendedIds.Sound (Sounds in the server lib); other modules call play() for what the client
-- already knows about (evolution, level up, the PC).
-- Sounds play as their own sources so they can overlap; a channel plays one sound at a time.
-- Battle and game sounds follow the Item channel (Options: Battle Effects Volume), menus the UI channel.
local DIR = '/sounds/effects/'
local MAX_DELAY_MS = 10000

local INTERFACE = {
    menu_open = true, menu_select = true, menu_choose = true, menu_error = true,
    nav_open = true, nav_close = true, dex_select = true, text_blip = true,
    pc_open = true, pc_access = true, pc_close = true, save = true,
}

local pending = {}

local function channelFor(name)
    return g_sounds.getChannel(INTERFACE[name] and SoundChannels.SoundUI or SoundChannels.Item)
end

-- Returns the sound source, so a long sound (the evolution music) can be faded out.
function play(name, gain)
    if not g_sounds or type(name) ~= 'string' or not name:match('^[%w_]+$') then
        return nil
    end
    local channel = channelFor(name)
    if not channel or not channel:isEnabled() or channel:getGain() <= 0 then
        return nil
    end
    return g_sounds.play(DIR .. name .. '.ogg', 0, channel:getGain() * (gain or 1))
end

function fadeOut(source, seconds)
    if source and source:isPlaying() then
        source:setFading(2, seconds or 1) -- SoundSource::FadingOff
    end
end

local function onSound(protocol, opcode, buffer)
    for name, delay in buffer:gmatch('([%w_]+):(%d+)') do
        delay = math.min(tonumber(delay) or 0, MAX_DELAY_MS)
        if delay == 0 then
            play(name)
        else
            local event
            event = scheduleEvent(function()
                pending[event] = nil
                if g_game.isOnline() then
                    play(name)
                end
            end, delay)
            pending[event] = true
        end
    end
end

local function cancelPending()
    for event in pairs(pending) do
        removeEvent(event)
    end
    pending = {}
end

function init()
    ProtocolGame.registerExtendedOpcode(ExtendedIds.Sound, onSound)
    connect(g_game, { onGameEnd = cancelPending })
end

function terminate()
    ProtocolGame.unregisterExtendedOpcode(ExtendedIds.Sound)
    disconnect(g_game, { onGameEnd = cancelPending })
    cancelPending()
end
