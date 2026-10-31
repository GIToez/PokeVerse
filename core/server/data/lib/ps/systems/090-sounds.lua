-- Battle and game sounds. The client plays /sounds/effects/<name>.ogg; one message can carry a
-- timed sequence: "name:delayMs;name:delayMs" on EXTENDED_IDS.SOUND (game_sounds in the client).
Sounds = {}

Sounds.HEAR_RANGE_X = 8
Sounds.HEAR_RANGE_Y = 6
Sounds.HIT_INTERVAL_MS = 350

local STATUS_SOUNDS = {
    [CREATURE_STATUS_BURN] = "status_burn",
    [CREATURE_STATUS_FREEZE] = "status_frozen",
    [CREATURE_STATUS_PARALYSIS] = "status_paralyzed",
    [CREATURE_STATUS_POISON] = "status_poison",
    [CREATURE_STATUS_BADPOISON] = "status_poison",
    [CREATURE_STATUS_SLEEP] = "status_sleep",
    [CREATURE_STATUS_CONFUSION] = "status_confused",
    [CREATURE_STATUS_LOWACCURACY] = "stat_down",
}

local STAT_STATUSES = { CREATURE_STATUS_EXTRASPEED, CREATURE_STATUS_EXTRASPATK, CREATURE_STATUS_EXTRASPDEF }

local lastHit = {}

local function encode(sequence)
    if (type(sequence) == "string") then
        return sequence .. ":0"
    end
    local parts = {}
    for _, step in ipairs(sequence) do
        parts[#parts + 1] = step[1] .. ":" .. math.floor(step[2] or 0)
    end
    return table.concat(parts, ";")
end

-- sequence: a sound name, or { {name, delayMs}, ... }
function Sounds.send(cid, sequence)
    if (isPlayer(cid) and getPlayerUsingOtClient(cid)) then
        doSendPlayerExtendedOpcode(cid, EXTENDED_IDS.SOUND, encode(sequence))
    end
end

function Sounds.around(pos, sequence)
    if (not pos) then
        return
    end
    local buffer = encode(sequence)
    for _, spectator in ipairs(getSpectators(pos, Sounds.HEAR_RANGE_X, Sounds.HEAR_RANGE_Y, false) or {}) do
        if (isPlayer(spectator) and getPlayerUsingOtClient(spectator)) then
            doSendPlayerExtendedOpcode(spectator, EXTENDED_IDS.SOUND, buffer)
        end
    end
end

-- Move sounds play whole on the client's Moves channel; the server says when a move is over, so a
-- faster or slower move needs no sound edit. A move is over once its Pokemon has hit nothing for
-- MOVE_QUIET_MS (after MOVE_MIN_MS at least, MOVE_MAX_MS at most), or when it uses its next move.
-- A move with a warm-up can start its sound later with soundDelay (ms) in its config.
Sounds.MOVE_POLL_MS = 100
Sounds.MOVE_QUIET_MS = 400
Sounds.MOVE_MIN_MS = 700
Sounds.MOVE_MAX_MS = 6000

local moves = {} -- [pokemon] = {id, listeners, elapsed, quiet}
local lastCast = 0

local function sendMove(listeners, buffer)
    for _, player in ipairs(listeners) do
        if (isPlayer(player)) then
            doSendPlayerExtendedOpcode(player, EXTENDED_IDS.MOVE_SOUND, buffer)
        end
    end
end

local function stopMove(cid)
    local move = moves[cid]
    if (move) then
        moves[cid] = nil
        sendMove(move.listeners, "stop;" .. move.id)
    end
end

local function watchMove(cid, id)
    local move = moves[cid]
    if (not move or move.id ~= id) then
        return
    end
    move.elapsed = move.elapsed + Sounds.MOVE_POLL_MS
    move.quiet = move.quiet + Sounds.MOVE_POLL_MS
    if (not isCreature(cid) or move.elapsed >= Sounds.MOVE_MAX_MS or
            (move.elapsed >= Sounds.MOVE_MIN_MS and move.quiet >= Sounds.MOVE_QUIET_MS)) then
        stopMove(cid)
        return
    end
    addEvent(watchMove, Sounds.MOVE_POLL_MS, cid, id)
end

local function startMove(cid, skillName)
    if (not isCreature(cid)) then
        return
    end
    stopMove(cid)
    local pos = getCreaturePosition(cid)
    local listeners = {}
    for _, spectator in ipairs(getSpectators(pos, Sounds.HEAR_RANGE_X, Sounds.HEAR_RANGE_Y, false) or {}) do
        if (isPlayer(spectator) and getPlayerUsingOtClient(spectator)) then
            listeners[#listeners + 1] = spectator
        end
    end
    if (#listeners == 0) then
        return
    end
    lastCast = lastCast % 1000000 + 1
    moves[cid] = { id = lastCast, listeners = listeners, elapsed = 0, quiet = 0 }
    sendMove(listeners, table.concat({ "start", lastCast, skillName, pos.x, pos.y, pos.z }, ";"))
    addEvent(watchMove, Sounds.MOVE_POLL_MS, cid, lastCast)
end

function Sounds.onMove(cid, skillName)
    local delay = getPokemonSkillSoundDelay(skillName)
    if (delay > 0) then
        addEvent(startMove, delay, cid, skillName)
    else
        startMove(cid, skillName)
    end
end

-- Only the trainers in the fight hear hits, at most one every HIT_INTERVAL_MS per Pokemon hit.
function Sounds.onHit(fromCid, toCid, multiplier)
    if (moves[fromCid]) then
        moves[fromCid].quiet = 0
    end
    if (lastHit[toCid]) then
        return
    end
    lastHit[toCid] = true
    addEvent(function() lastHit[toCid] = nil end, Sounds.HIT_INTERVAL_MS)

    local name = "hit_normal"
    if (multiplier > 1) then
        name = "hit_super"
    elseif (multiplier < 1) then
        name = "hit_weak"
    end

    local heard = {}
    for _, creature in ipairs({ fromCid, toCid }) do
        local master = isCreature(creature) and getCreatureMaster(creature)
        if (isPlayer(master) and not heard[master]) then
            heard[master] = true
            Sounds.send(master, name)
        end
    end
end

function Sounds.onStatus(cid, status, badStatus)
    local name = STATUS_SOUNDS[status]
    if (not name and table.find(STAT_STATUSES, status)) then
        name = badStatus and "stat_down" or "stat_up"
    end
    if (name) then
        Sounds.around(getCreaturePosition(cid), name)
    end
end

-- The catch animation: a catch resolves after 5.5 s (catchPokemon), a miss after 4 s (catchMiss).
function Sounds.onBallThrow(pos, caught)
    local sequence = { { "ball_throw", 0 }, { "ball_absorb", 450 }, { "ball_drop", 1000 },
                       { "ball_shake", 1700 }, { "ball_shake", 2700 } }
    if (caught) then
        sequence[#sequence + 1] = { "ball_shake", 3700 }
    end
    Sounds.around(pos, sequence)
end

function Sounds.onCatch(cid)
    Sounds.around(getCreaturePosition(cid), "catch_success")
end

function Sounds.onCatchMiss(pos)
    Sounds.around(pos, "ball_open")
end

function Sounds.onSendOut(pos)
    Sounds.around(pos, "send_out")
end

function Sounds.onRecall(pos, fainted)
    Sounds.around(pos, fainted and "recall_fainted" or "recall")
end

function Sounds.onFaint(pos)
    Sounds.around(pos, "faint")
end
