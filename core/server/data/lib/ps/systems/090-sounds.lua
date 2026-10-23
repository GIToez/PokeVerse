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

-- Only the trainers in the fight hear hits, at most one every HIT_INTERVAL_MS per Pokemon hit.
function Sounds.onHit(fromCid, toCid, multiplier)
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
