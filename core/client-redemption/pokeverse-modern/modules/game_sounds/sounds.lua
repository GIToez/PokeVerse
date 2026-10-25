-- PokeVerse game sounds from /sounds/effects. The server sends "name:delayMs;name:delayMs" on
-- ExtendedIds.Sound (Sounds in the server lib); other modules call play() for what the client
-- already knows about (evolution, level up, the PC).
-- Sounds play as their own sources so they can overlap; a channel plays one sound at a time.
-- Battle and game sounds follow the Item channel (Options: Battle Sounds Volume), menus the UI channel.
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

-- A Pokemon's voice line ("PIKACHU!") plays its overworld cry, quieter with distance. Crowds of
-- wild Pokemon talk a lot, so cries are spaced out overall and per species name. X/Y overworld
-- cries live in /sounds/voice_cries/; the Pokedex auto-play set stays in /sounds/cries/.
local VOICE_CRY_DIR = '/sounds/voice_cries/'
local CRY_DIR = '/sounds/cries/'
local CRY_RANGE = 8
local CRY_GAP_MS = 1200
local CRY_SPEAKER_GAP_MS = 8000
-- the cry files are about 6 dB quieter than the battle sounds (peaks near -6 dB), which made them
-- inaudible on phone speakers at the default 25% master volume
local CRY_GAIN = 2
local CRY_FAR_GAIN = 0.6 -- at CRY_RANGE tiles
local lastCry = -CRY_GAP_MS
local lastCryBy = {}

local function cryNumber(name, text)
    local number = CryVoices[text]
    if number == nil then
        return nil
    end
    return number or CryNames[name:lower()]
end

local function cryPath(number)
    local voice = VOICE_CRY_DIR .. number .. '.ogg'
    if not g_resources or g_resources.fileExists(voice) then
        return voice
    end
    local fallback = CRY_DIR .. number .. '.ogg'
    if g_resources.fileExists(fallback) then
        return fallback
    end
    return nil
end

-- Overworld cry (X/Y when present). The Pokedex entry still plays /sounds/cries/ on its own.
function playVoiceCry(number, gain)
    number = tonumber(number)
    if not number or not g_sounds then
        return nil
    end
    local channel = g_sounds.getChannel(SoundChannels.Item)
    if not channel or not channel:isEnabled() or channel:getGain() <= 0 then
        return nil
    end
    local path = cryPath(number)
    if not path then
        return nil
    end
    return g_sounds.play(path, 0, math.min(1, channel:getGain() * CRY_GAIN * (gain or 1)))
end

local function onTalk(name, level, mode, text, channelId, creaturePos)
    if mode ~= MessageModes.MonsterSay and mode ~= MessageModes.MonsterYell or not creaturePos then
        return
    end
    local player = g_game.getLocalPlayer()
    local here = player and player:getPosition()
    if not here or here.z ~= creaturePos.z then
        return
    end
    local distance = math.max(math.abs(here.x - creaturePos.x), math.abs(here.y - creaturePos.y))
    local number = distance <= CRY_RANGE and cryNumber(name, text)
    if not number then
        return
    end
    local now = g_clock.millis()
    if now - lastCry < CRY_GAP_MS or now - (lastCryBy[name] or -CRY_SPEAKER_GAP_MS) < CRY_SPEAKER_GAP_MS then
        return
    end
    lastCry = now
    lastCryBy[name] = now
    playVoiceCry(number, 1 - (1 - CRY_FAR_GAIN) * distance / CRY_RANGE)
end

local function cancelPending()
    for event in pairs(pending) do
        removeEvent(event)
    end
    pending = {}
    lastCryBy = {}
end

function init()
    ProtocolGame.registerExtendedOpcode(ExtendedIds.Sound, onSound)
    connect(g_game, { onGameEnd = cancelPending, onTalk = onTalk })
end

function terminate()
    ProtocolGame.unregisterExtendedOpcode(ExtendedIds.Sound)
    disconnect(g_game, { onGameEnd = cancelPending, onTalk = onTalk })
    cancelPending()
end
