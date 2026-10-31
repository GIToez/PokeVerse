-- Move sounds from /sounds/moves/<move>.ogg (scripts/make-move-sounds.py), on the Moves channel
-- (Options: Move Sounds Volume). The server sends "start;cast;move;x;y;z" on ExtendedIds.MoveSound
-- when a move goes off and "stop;cast" when it is over (Sounds.onMove); the sound plays whole from
-- the start and fades out on stop, so it follows the move however long the move takes.
local MOVE_DIR = '/sounds/moves/'
local MOVE_RANGE = 8
local MOVE_FAR_GAIN = 0.5 -- at MOVE_RANGE tiles
local FADE_SECONDS = 0.6
local MAX_PLAYING = 6

local playing = {} -- [cast] = source
local order = {}

local function moveFile(name)
    return MOVE_DIR .. name:lower():gsub('[^%w]+', '_'):gsub('^_+', ''):gsub('_+$', '') .. '.ogg'
end

local function forget(cast)
    playing[cast] = nil
    for i, id in ipairs(order) do
        if id == cast then
            table.remove(order, i)
            break
        end
    end
end

local function stopMove(cast)
    local source = playing[cast]
    forget(cast)
    if source and source:isPlaying() then
        source:setFading(2, FADE_SECONDS) -- SoundSource::FadingOff
    end
end

local function startMove(cast, name, pos)
    local channel = g_sounds.getChannel(SoundChannels.Spells)
    if not channel or not channel:isEnabled() or channel:getGain() <= 0 then
        return
    end
    local player = g_game.getLocalPlayer()
    local here = player and player:getPosition()
    if not here or here.z ~= pos.z then
        return
    end
    local distance = math.max(math.abs(here.x - pos.x), math.abs(here.y - pos.y))
    if distance > MOVE_RANGE then
        return
    end
    local path = moveFile(name)
    if g_resources and not g_resources.fileExists(path) then
        return
    end
    while #order >= MAX_PLAYING do
        stopMove(order[1])
    end
    local gain = 1 - (1 - MOVE_FAR_GAIN) * distance / MOVE_RANGE
    local source = g_sounds.play(path, 0, channel:getGain() * gain)
    if source then
        playing[cast] = source
        order[#order + 1] = cast
    end
end

local function onMoveSound(protocol, opcode, buffer)
    if not g_sounds then
        return
    end
    local action, cast, rest = buffer:match('^(%a+);(%d+);?(.*)$')
    if action == 'start' then
        local name, x, y, z = rest:match('^([^;]+);(%d+);(%d+);(%d+)$')
        if name then
            startMove(cast, name, { x = tonumber(x), y = tonumber(y), z = tonumber(z) })
        end
    elseif action == 'stop' then
        stopMove(cast)
    end
end

function stopMoveSounds()
    for cast in pairs(playing) do
        stopMove(cast)
    end
    playing, order = {}, {}
end

function initMoveSounds()
    ProtocolGame.registerExtendedOpcode(ExtendedIds.MoveSound, onMoveSound)
    connect(g_game, { onGameEnd = stopMoveSounds })
end

function terminateMoveSounds()
    ProtocolGame.unregisterExtendedOpcode(ExtendedIds.MoveSound)
    disconnect(g_game, { onGameEnd = stopMoveSounds })
    stopMoveSounds()
end
