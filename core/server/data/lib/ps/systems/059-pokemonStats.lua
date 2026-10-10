if (PokemonStats) then
    return
end

-- IVs, EVs and Natures, kept on the ball like every other Pokemon attribute (balls.lua)
PokemonStats = {}

POKEMON_STAT = {
    HP = 1,
    ATTACK = 2,
    DEFENSE = 3,
    SPECIAL_ATTACK = 4,
    SPECIAL_DEFENSE = 5,
    SPEED = 6
}

POKEMON_STAT_NAMES = { "HP", "Attack", "Defense", "Sp. Attack", "Sp. Defense", "Speed" }

PokemonStats.STAT_COUNT = 6
PokemonStats.IV_MAX = 31
PokemonStats.EV_MAX = 252
PokemonStats.EV_TOTAL_MAX = 510
PokemonStats.NATURE_MODIFIER = 0.1

-- Official order and ids (Hardy = 1 ... Quirky = 25); increased and decreased stats, nil when neutral
local A, D, SA, SD, S = POKEMON_STAT.ATTACK, POKEMON_STAT.DEFENSE, POKEMON_STAT.SPECIAL_ATTACK,
    POKEMON_STAT.SPECIAL_DEFENSE, POKEMON_STAT.SPEED
local NATURES = {
    { name = "Hardy" }, { name = "Lonely", up = A, down = D }, { name = "Brave", up = A, down = S },
    { name = "Adamant", up = A, down = SA }, { name = "Naughty", up = A, down = SD },
    { name = "Bold", up = D, down = A }, { name = "Docile" }, { name = "Relaxed", up = D, down = S },
    { name = "Impish", up = D, down = SA }, { name = "Lax", up = D, down = SD },
    { name = "Timid", up = S, down = A }, { name = "Hasty", up = S, down = D }, { name = "Serious" },
    { name = "Jolly", up = S, down = SA }, { name = "Naive", up = S, down = SD },
    { name = "Modest", up = SA, down = A }, { name = "Mild", up = SA, down = D },
    { name = "Quiet", up = SA, down = S }, { name = "Bashful" }, { name = "Rash", up = SA, down = SD },
    { name = "Calm", up = SD, down = A }, { name = "Gentle", up = SD, down = D },
    { name = "Sassy", up = SD, down = S }, { name = "Careful", up = SD, down = SA }, { name = "Quirky" }
}
PokemonStats.NATURE_COUNT = #NATURES

local function parseStats(value, max)
    if (type(value) ~= "string") then
        return nil
    end

    local stats = {}
    for number in value:gmatch("[^,]+") do
        number = tonumber(number)
        if (not number) then
            return nil
        end
        stats[#stats + 1] = math.max(0, math.min(max, math.floor(number)))
    end

    return #stats == PokemonStats.STAT_COUNT and stats or nil
end

local function formatStats(stats)
    return table.concat(stats, ",")
end

-- EV totals over the cap lose points from the last stats first, so the stored value is always valid
local function capEvs(evs)
    local total = 0
    for i = 1, PokemonStats.STAT_COUNT do
        evs[i] = math.max(0, math.min(PokemonStats.EV_MAX, evs[i]))
        total = total + evs[i]
    end

    local i = PokemonStats.STAT_COUNT
    while (total > PokemonStats.EV_TOTAL_MAX and i > 0) do
        local removed = math.min(evs[i], total - PokemonStats.EV_TOTAL_MAX)
        evs[i] = evs[i] - removed
        total = total - removed
        i = i - 1
    end

    return evs
end

PokemonStats.rollIvs = function()
    local ivs = {}
    for i = 1, PokemonStats.STAT_COUNT do
        ivs[i] = math.random(0, PokemonStats.IV_MAX)
    end
    return ivs
end

PokemonStats.rollNature = function()
    return math.random(1, PokemonStats.NATURE_COUNT)
end

PokemonStats.getNature = function(natureId)
    return NATURES[natureId]
end

PokemonStats.getNatureName = function(natureId)
    local nature = NATURES[natureId]
    return nature and nature.name or "Unknown"
end

PokemonStats.getNatureIdByName = function(name)
    name = name:lower()
    for id, nature in ipairs(NATURES) do
        if (nature.name:lower() == name) then
            return id
        end
    end
    return nil
end

-- 1.1 for the stat the Nature raises, 0.9 for the one it lowers, 1 otherwise (HP is never changed)
PokemonStats.getNatureMultiplier = function(natureId, stat)
    local nature = NATURES[natureId]
    if (not nature or not nature.up) then
        return 1
    elseif (nature.up == stat) then
        return 1 + PokemonStats.NATURE_MODIFIER
    elseif (nature.down == stat) then
        return 1 - PokemonStats.NATURE_MODIFIER
    end
    return 1
end

-- Gives a ball that has no IVs, EVs or Nature yet its own, once; values that are already there are only
-- clamped into range, never rerolled. Returns true when the ball changed.
PokemonStats.ensureBall = function(uid)
    if (not isBallWithPokemon(uid)) then
        return false
    end

    local changed = false

    local storedIvs = getBallPokemonIvsString(uid)
    local ivs = parseStats(storedIvs, PokemonStats.IV_MAX)
    if (not ivs) then
        ivs = PokemonStats.rollIvs()
    end
    if (formatStats(ivs) ~= storedIvs) then
        setBallPokemonIvsString(uid, formatStats(ivs))
        changed = true
    end

    local storedEvs = getBallPokemonEvsString(uid)
    local evs = parseStats(storedEvs, PokemonStats.EV_MAX) or { 0, 0, 0, 0, 0, 0 }
    evs = capEvs(evs)
    if (formatStats(evs) ~= storedEvs) then
        setBallPokemonEvsString(uid, formatStats(evs))
        changed = true
    end

    local natureId = tonumber(getBallPokemonNatureId(uid))
    if (not natureId or not NATURES[natureId]) then
        setBallPokemonNatureId(uid, PokemonStats.rollNature())
        changed = true
    end

    if (changed) then
        doBallUpdateDescription(uid)
    end

    return changed
end

PokemonStats.getBallIvs = function(uid)
    PokemonStats.ensureBall(uid)
    return parseStats(getBallPokemonIvsString(uid), PokemonStats.IV_MAX)
end

PokemonStats.getBallEvs = function(uid)
    PokemonStats.ensureBall(uid)
    return parseStats(getBallPokemonEvsString(uid), PokemonStats.EV_MAX)
end

PokemonStats.getBallNatureId = function(uid)
    PokemonStats.ensureBall(uid)
    return tonumber(getBallPokemonNatureId(uid))
end

PokemonStats.setBallIvs = function(uid, ivs)
    local valid = parseStats(formatStats(ivs), PokemonStats.IV_MAX)
    if (valid) then
        setBallPokemonIvsString(uid, formatStats(valid))
    end
    return valid ~= nil
end

PokemonStats.setBallEvs = function(uid, evs)
    local valid = parseStats(formatStats(evs), PokemonStats.EV_MAX)
    if (valid) then
        setBallPokemonEvsString(uid, formatStats(capEvs(valid)))
    end
    return valid ~= nil
end

PokemonStats.setBallNatureId = function(uid, natureId)
    if (not NATURES[natureId]) then
        return false
    end
    setBallPokemonNatureId(uid, natureId)
    return true
end

PokemonStats.getTotal = function(stats)
    local total = 0
    for i = 1, PokemonStats.STAT_COUNT do
        total = total + (stats[i] or 0)
    end
    return total
end

local SHORT_STAT_NAMES = { "HP", "Atk", "Def", "SpA", "SpD", "Spe" }

PokemonStats.getNatureDescription = function(natureId)
    local nature = NATURES[natureId]
    if (not nature) then
        return "Unknown"
    elseif (not nature.up) then
        return nature.name .. " (neutral)"
    end
    return string.format("%s (+%s, -%s)", nature.name, POKEMON_STAT_NAMES[nature.up], POKEMON_STAT_NAMES[nature.down])
end

local function describeStats(stats, max)
    local parts = {}
    for i = 1, PokemonStats.STAT_COUNT do
        parts[i] = SHORT_STAT_NAMES[i] .. " " .. stats[i]
    end
    return string.format("%s (%d/%d)", table.concat(parts, ", "), PokemonStats.getTotal(stats), max)
end

-- The ball's look text: anyone looking at a ball sees all of it
PokemonStats.getBallDescription = function(uid)
    local ivs, evs = PokemonStats.getBallIvs(uid), PokemonStats.getBallEvs(uid)
    if (not ivs or not evs) then
        return ""
    end

    return string.format("\nNature: %s.\nIVs: %s.\nEVs: %s.",
        PokemonStats.getNatureDescription(PokemonStats.getBallNatureId(uid)),
        describeStats(ivs, PokemonStats.IV_MAX * PokemonStats.STAT_COUNT),
        describeStats(evs, PokemonStats.EV_TOTAL_MAX))
end

-- After a ball's IVs, EVs or Nature change; the Pokemon that is out picks up the new stats here
PokemonStats.onBallChanged = function(cid, ballUid)
end

-- Balls in the ball slot and the backpack; the depot and other storage are filled when a ball is
-- created, called, listed on the market or left at the daycare
PokemonStats.onLogin = function(cid)
    local changed = 0
    for _, ball in ipairs(getPlayerAllBallsWithPokemon(cid)) do
        if (PokemonStats.ensureBall(ball.uid)) then
            changed = changed + 1
        end
    end

    if (changed > 0) then
        log(LOG_TYPES.INFO, "PokemonStats - IVs, EVs and Nature added to Pokemon.", getCreatureName(cid), changed)
    end
end
