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

-- Each stat is scaled by the official stat formula divided by the same formula for an average Pokemon
-- (IV 15, 0 EVs, neutral Nature) of the same species and level, so an average Pokemon plays as before.
-- The weight scales the effect: 0 turns it off, 1 is the full official difference.
IVEV_STAT_WEIGHT = 1.0
PokemonStats.AVERAGE_IV = 15

local MONSTER_STAT_BY_STAT = {
    [POKEMON_STAT.HP] = MONSTER_POKE_STATS.MAXHEALTH,
    [POKEMON_STAT.ATTACK] = MONSTER_POKE_STATS.ATTACK,
    [POKEMON_STAT.DEFENSE] = MONSTER_POKE_STATS.DEFENSE,
    [POKEMON_STAT.SPECIAL_ATTACK] = MONSTER_POKE_STATS.SPECIALATTACK,
    [POKEMON_STAT.SPECIAL_DEFENSE] = MONSTER_POKE_STATS.SPECIALDEFENSE,
    [POKEMON_STAT.SPEED] = MONSTER_POKE_STATS.SPEED
}

-- Monster XML speed is the official Speed plus 200
local MONSTER_SPEED_OFFSET = 200

-- Without the official rounding: at low levels it would swamp the IVs (a boosting Nature could even
-- come out as a loss), and only the ratio between two results is used
PokemonStats.officialStat = function(stat, base, iv, ev, level, natureMultiplier)
    local value = (2 * base + iv + ev / 4) * level / 100
    if (stat == POKEMON_STAT.HP) then
        return value + level + 10
    end
    return (value + 5) * natureMultiplier
end

-- Official base stats: Attack to Sp. Defense from the species table, HP and Speed from the monster XML
PokemonStats.getBaseStats = function(pokemonName)
    local definition = getPokemonDefinition(pokemonName)
    local info = getMonsterInfo(pokemonName)
    if (not definition or not info) then
        return nil
    end

    return {
        math.max(1, info.health),
        definition.atk,
        definition.def,
        definition.spAtk,
        definition.spDef,
        math.max(1, info.baseSpeed - MONSTER_SPEED_OFFSET)
    }
end

PokemonStats.getMultipliers = function(pokemonName, level, ivs, evs, natureId)
    local bases = PokemonStats.getBaseStats(pokemonName)
    local multipliers = {}
    for stat = 1, PokemonStats.STAT_COUNT do
        multipliers[stat] = 1
        if (bases) then
            local actual = PokemonStats.officialStat(stat, bases[stat], ivs[stat], evs[stat], level,
                PokemonStats.getNatureMultiplier(natureId, stat))
            local average = PokemonStats.officialStat(stat, bases[stat], PokemonStats.AVERAGE_IV, 0, level, 1)
            multipliers[stat] = 1 + IVEV_STAT_WEIGHT * (actual / average - 1)
        end
    end
    return multipliers
end

PokemonStats.getBallMultipliers = function(ballUid, pokemonName, level)
    local ivs, evs = PokemonStats.getBallIvs(ballUid), PokemonStats.getBallEvs(ballUid)
    if (not ivs or not evs) then
        return nil
    end
    return PokemonStats.getMultipliers(pokemonName or getBallPokemonName(ballUid),
        level or getBallPokemonLevel(ballUid), ivs, evs, PokemonStats.getBallNatureId(ballUid))
end

-- Sets the summoned Pokemon's multipliers from its ball, for its current species and level. Setting the
-- HP multiplier recalculates max HP and refills it, so keepHealth puts the HP percentage back.
PokemonStats.applyToPokemon = function(pokemon, ballUid, keepHealth)
    if (not isMonster(pokemon)) then
        return false
    end

    local multipliers = PokemonStats.getBallMultipliers(ballUid, getCreatureName(pokemon), getMonsterLevel(pokemon))
    if (not multipliers) then
        return false
    end

    local healthPercent = getCreatureHealth(pokemon) / math.max(1, getCreatureMaxHealth(pokemon))
    for stat = 1, PokemonStats.STAT_COUNT do
        setMonsterIvEvStat(pokemon, MONSTER_STAT_BY_STAT[stat], multipliers[stat])
    end

    if (keepHealth) then
        local health = math.max(1, math.ceil(getCreatureMaxHealth(pokemon) * healthPercent))
        doCreatureAddHealth(pokemon, health - getCreatureHealth(pokemon))
    end
    return true
end

-- After a ball's IVs, EVs or Nature change; the Pokemon that is out picks up the new stats here
PokemonStats.onBallChanged = function(cid, ballUid)
    -- the Pokemon that is out always belongs to the ball in the ball slot
    local pokemon = getPlayerPokemon(cid)
    local ball = getPlayerBall(cid)
    if (isMonster(pokemon) and isItem(ball) and ball.uid == ballUid) then
        PokemonStats.applyToPokemon(pokemon, ballUid, true)
    end
end

-- Speed shortens a player's Pokemon's move cooldowns and wind-ups by up to these fractions, scaled by
-- R = Speed / (Speed + SPEED_RATIO_HALF), with Speed the official stat (IVs, EVs and Nature included)
PokemonStats.SPEED_COOLDOWN_REDUCTION = 0.15
PokemonStats.SPEED_WINDUP_REDUCTION = 0.10
PokemonStats.SPEED_RATIO_HALF = 150

PokemonStats.getSpeedStat = function(ballUid, pokemonName, level)
    local bases = PokemonStats.getBaseStats(pokemonName)
    local ivs, evs = PokemonStats.getBallIvs(ballUid), PokemonStats.getBallEvs(ballUid)
    if (not bases or not ivs or not evs) then
        return nil
    end
    local stat = POKEMON_STAT.SPEED
    return PokemonStats.officialStat(stat, bases[stat], ivs[stat], evs[stat], level,
        PokemonStats.getNatureMultiplier(PokemonStats.getBallNatureId(ballUid), stat))
end

-- 0 for wild and NPC Pokemon: only players' Pokemon have the Speed benefits
PokemonStats.getSpeedRatio = function(pokemon)
    if (not isMonster(pokemon) or not isSummon(pokemon)) then
        return 0
    end
    local master = getCreatureMaster(pokemon)
    if (not isPlayer(master)) then
        return 0
    end
    local ball = getPlayerBall(master)
    if (not isItem(ball) or not isBallWithPokemon(ball.uid)) then
        return 0
    end
    local speed = PokemonStats.getSpeedStat(ball.uid, getCreatureName(pokemon), getMonsterLevel(pokemon))
    if (not speed or speed <= 0) then
        return 0
    end
    return speed / (speed + PokemonStats.SPEED_RATIO_HALF)
end

-- Cooldowns are whole seconds, so the reduced time is rounded up or down at random in proportion
-- (9.4 s is 10 s 40% of the time): on average every bit of the reduction counts
PokemonStats.getCooldownTime = function(pokemon, seconds)
    if (seconds <= 0) then
        return seconds
    end
    local reduced = seconds * (1 - PokemonStats.SPEED_COOLDOWN_REDUCTION * PokemonStats.getSpeedRatio(pokemon))
    local whole = math.floor(reduced)
    if (math.random() < reduced - whole) then
        whole = whole + 1
    end
    return math.max(1, whole)
end

PokemonStats.getWindupDelay = function(pokemon, milliseconds)
    return math.floor(milliseconds * (1 - PokemonStats.SPEED_WINDUP_REDUCTION * PokemonStats.getSpeedRatio(pokemon)))
end

-- Everything the own-Pokemon Pokedex view shows; also sent to the Redemption client as JSON
PokemonStats.getStatSheet = function(ballUid, pokemonName, level)
    local ivs, evs = PokemonStats.getBallIvs(ballUid), PokemonStats.getBallEvs(ballUid)
    local natureId = PokemonStats.getBallNatureId(ballUid)
    if (not ivs or not evs) then
        return nil
    end

    local bases = PokemonStats.getBaseStats(pokemonName)
    local multipliers = PokemonStats.getMultipliers(pokemonName, level, ivs, evs, natureId)
    local nature = NATURES[natureId] or NATURES[1]
    local sheet = {
        name = pokemonName,
        level = level,
        nature = { id = natureId, name = nature.name, up = nature.up or 0, down = nature.down or 0 },
        statNames = POKEMON_STAT_NAMES,
        ivs = ivs,
        evs = evs,
        actual = {},
        effect = {},
        ivMax = PokemonStats.IV_MAX,
        evMax = PokemonStats.EV_MAX,
        evTotalMax = PokemonStats.EV_TOTAL_MAX,
        ivTotal = PokemonStats.getTotal(ivs),
        evTotal = PokemonStats.getTotal(evs),
        perfectIvs = 0
    }
    for stat = 1, PokemonStats.STAT_COUNT do
        if (ivs[stat] == PokemonStats.IV_MAX) then
            sheet.perfectIvs = sheet.perfectIvs + 1
        end
        sheet.actual[stat] = bases and math.floor(PokemonStats.officialStat(stat, bases[stat], ivs[stat], evs[stat],
            level, PokemonStats.getNatureMultiplier(natureId, stat)) + 0.5) or 0
        sheet.effect[stat] = math.floor((multipliers[stat] - 1) * 100 + 0.5)
    end
    return sheet
end

PokemonStats.getStatSheetText = function(sheet)
    local lines = {
        string.format("Nature: %s", PokemonStats.getNatureDescription(sheet.nature.id)),
        string.format("IVs: %d/%d, %d perfect", sheet.ivTotal, sheet.ivMax * PokemonStats.STAT_COUNT, sheet.perfectIvs),
        string.format("EVs: %d/%d", sheet.evTotal, sheet.evTotalMax)
    }
    for stat = 1, PokemonStats.STAT_COUNT do
        lines[#lines + 1] = string.format("%s: %d (IV %d, EV %d, %s%d%%)", POKEMON_STAT_NAMES[stat], sheet.actual[stat],
            sheet.ivs[stat], sheet.evs[stat], sheet.effect[stat] >= 0 and "+" or "", sheet.effect[stat])
    end
    return table.concat(lines, "\n")
end

PokemonStats.sendStatSheet = function(cid, sheet)
    if (sheet) then
        doSendPlayerExtendedOpcode(cid, EXTENDED_IDS.POKEMON_STATS, JSON.encode(sheet))
    end
end

-- "1 Speed", "2 Attack, 1 Sp. Defense" or "None"
PokemonStats.getEvYieldText = function(pokemonName)
    local yield = PokemonStats.getEvYield(pokemonName)
    local parts = {}
    for stat = 1, PokemonStats.STAT_COUNT do
        if (yield and yield[stat] > 0) then
            parts[#parts + 1] = yield[stat] .. " " .. POKEMON_STAT_NAMES[stat]
        end
    end
    return #parts > 0 and table.concat(parts, ", ") or "None"
end

PokemonStats.getEvYield = function(pokemonName)
    if (not pokemonName) then
        return nil
    end
    return EV_YIELDS[pokemonName] or EV_YIELDS[(pokemonName:gsub("^[Ss]hiny ", ""))]
end

-- Adds (or with negative amounts removes) EVs within the 252 per stat and 510 total caps.
-- Returns what really changed per stat, or nil when the ball has no Pokemon.
PokemonStats.addEvs = function(ballUid, amounts)
    local evs = PokemonStats.getBallEvs(ballUid)
    if (not evs) then
        return nil
    end

    local changes = {}
    local total = PokemonStats.getTotal(evs)
    for stat = 1, PokemonStats.STAT_COUNT do
        local amount = amounts[stat] or 0
        if (amount > 0) then
            amount = math.min(amount, PokemonStats.EV_MAX - evs[stat], PokemonStats.EV_TOTAL_MAX - total)
        else
            amount = math.max(amount, -evs[stat])
        end
        evs[stat] = evs[stat] + amount
        total = total + amount
        changes[stat] = amount
    end

    PokemonStats.setBallEvs(ballUid, evs)
    return changes
end

local function describeChanges(changes)
    local parts = {}
    for stat = 1, PokemonStats.STAT_COUNT do
        if (changes[stat] ~= 0) then
            parts[#parts + 1] = string.format("%s %s%d", POKEMON_STAT_NAMES[stat], changes[stat] > 0 and "+" or "",
                changes[stat])
        end
    end
    return table.concat(parts, ", ")
end

PokemonStats.describeChanges = describeChanges

-- Extra EVs a held item adds to every defeat (Power items), by stat
PokemonStats.getHeldEvBonus = function(ballUid)
    return PokemonHeldItem.getEvBonus and PokemonHeldItem.getEvBonus(ballUid) or nil
end

-- Pomeg, Kelpsy, Qualot, Hondew, Grepa and Tamato, in stat order
PokemonStats.EV_BERRY_FIRST_ITEMID = 30145
PokemonStats.EV_BERRY_AMOUNT = 10

PokemonStats.onUseEvBerry = function(cid, item, fromPosition, itemEx, toPosition)
    local stat = item.itemid - PokemonStats.EV_BERRY_FIRST_ITEMID + 1
    if (not POKEMON_STAT_NAMES[stat] or not isItem(itemEx) or not isBallWithPokemon(itemEx.uid)) then
        doPlayerSendDefaultCancel(cid, RETURNVALUE_NOTPOSSIBLE)
        return false

    elseif (fromPosition.x ~= CONTAINER_POSITION or toPosition.x ~= CONTAINER_POSITION) then
        doPlayerSendCancel(cid, "You must pick up this item first.")
        return false
    end

    local evs = PokemonStats.getBallEvs(itemEx.uid)
    if (not evs or evs[stat] == 0) then
        doPlayerSendCancel(cid, string.format("This Pokemon has no %s EVs to lose.", POKEMON_STAT_NAMES[stat]))
        return false
    end

    local amounts = { 0, 0, 0, 0, 0, 0 }
    amounts[stat] = -PokemonStats.EV_BERRY_AMOUNT
    local changes = PokemonStats.addEvs(itemEx.uid, amounts)
    doBallUpdateDescription(itemEx.uid)
    PokemonStats.onBallChanged(cid, itemEx.uid)
    doRemoveItem(item.uid, 1)
    doSendMagicEffect(getCreaturePosition(cid), EFFECT_FIREWORK_BLUE)
    doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, string.format(__L(cid, "Your %s lost EVs: %s."),
        getBallPokemonName(itemEx.uid), describeChanges(changes)))
    return true
end

-- Breeding: the egg takes 3 IVs (5 with a Destiny Knot) from random parents, a parent's Power item
-- makes its stat one of them, and a parent's Everstone passes down its Nature. The rest is random,
-- and the hatched Pokemon starts with 0 EVs. Eggs and incubators carry the result until it hatches.
PokemonStats.INHERITED_IVS = 3
PokemonStats.INHERITED_IVS_DESTINY_KNOT = 5
local EGG_IVS_ATTRIBUTE = "eggIvs"
local EGG_NATURE_ATTRIBUTE = "eggNature"

-- Pokemon at the Day Care or on the Pokemon Market are database rows (ball_id and attributes): the
-- ball is rebuilt on a temporary item to read it. Returns the item uid, or nil.
PokemonStats.loadStoredBall = function(dbResult)
    if (not dbResult or dbResult:getDataInt('ball_id') == 0) then
        return nil
    end

    local uid = doCreateItemEx(dbResult:getDataInt('ball_id'))
    if (not uid) then
        return nil
    end
    doItemLoadAttributes(uid, 'attributes', dbResult:getID())
    return isBallWithPokemon(uid) and uid or nil
end

-- IVs, EVs and Nature as stored, without giving a ball its own first (nil when it has none yet)
PokemonStats.readBall = function(uid)
    local ivs = parseStats(getBallPokemonIvsString(uid), PokemonStats.IV_MAX)
    local evs = parseStats(getBallPokemonEvsString(uid), PokemonStats.EV_MAX)
    local natureId = tonumber(getBallPokemonNatureId(uid))
    if (not ivs or not evs or not NATURES[natureId]) then
        return nil
    end
    return ivs, evs, natureId
end

-- "Jolly | IV 142/186 (2x31) | EV 252/510" for listings
PokemonStats.getSummary = function(uid)
    local ivs, evs, natureId = PokemonStats.readBall(uid)
    if (not ivs) then
        return "not checked yet"
    end

    local perfect = 0
    for stat = 1, PokemonStats.STAT_COUNT do
        if (ivs[stat] == PokemonStats.IV_MAX) then
            perfect = perfect + 1
        end
    end
    return string.format("%s | IV %d/%d (%dx%d) | EV %d/%d", PokemonStats.getNatureName(natureId),
        PokemonStats.getTotal(ivs), PokemonStats.IV_MAX * PokemonStats.STAT_COUNT, perfect, PokemonStats.IV_MAX,
        PokemonStats.getTotal(evs), PokemonStats.EV_TOTAL_MAX)
end

PokemonStats.getStoredSummary = function(dbResult)
    local uid = PokemonStats.loadStoredBall(dbResult)
    return uid and PokemonStats.getSummary(uid) or "not checked yet"
end

PokemonStats.readDaycareParent = function(dbResult)
    if (not dbResult or dbResult:getDataInt('pokemon_maxenergy') > 0) then -- older rows have no attributes
        return nil
    end

    local uid = PokemonStats.loadStoredBall(dbResult)
    if (not uid) then
        return nil
    end

    local ivs, _, natureId = PokemonStats.readBall(uid)
    if (not ivs) then
        return nil
    end

    return {
        ivs = ivs,
        natureId = natureId,
        destinyKnot = PokemonHeldItem.hasDestinyKnot(uid),
        everstone = PokemonHeldItem.hasEverstone(uid),
        powerStat = PokemonHeldItem.getPowerStat(uid)
    }
end

-- Either parent may be nil (unknown); returns the egg's IVs and Nature
PokemonStats.makeEggStats = function(mother, father)
    local parents = {}
    for _, parent in ipairs({ mother or false, father or false }) do
        if (parent and parent.ivs) then
            parents[#parents + 1] = parent
        end
    end

    local ivs = PokemonStats.rollIvs()
    local natureId = PokemonStats.rollNature()
    if (#parents == 0) then
        return ivs, natureId
    end

    local count = PokemonStats.INHERITED_IVS
    local everstones, powers = {}, {}
    for _, parent in ipairs(parents) do
        if (parent.destinyKnot) then
            count = PokemonStats.INHERITED_IVS_DESTINY_KNOT
        end
        if (parent.everstone and parent.natureId) then
            everstones[#everstones + 1] = parent
        end
        if (parent.powerStat) then
            powers[#powers + 1] = parent
        end
    end

    if (#everstones > 0) then
        natureId = everstones[math.random(1, #everstones)].natureId
    end

    local remaining = {}
    for stat = 1, PokemonStats.STAT_COUNT do
        remaining[stat] = stat
    end

    local function inherit(stat, parent)
        ivs[stat] = parent.ivs[stat]
        for i, s in ipairs(remaining) do
            if (s == stat) then
                table.remove(remaining, i)
                break
            end
        end
        count = count - 1
    end

    if (#powers > 0) then
        local parent = powers[math.random(1, #powers)]
        inherit(parent.powerStat, parent)
    end

    while (count > 0 and #remaining > 0) do
        inherit(remaining[math.random(1, #remaining)], parents[math.random(1, #parents)])
    end

    return ivs, natureId
end

PokemonStats.setEggStats = function(uid, ivs, natureId)
    doItemSetAttribute(uid, EGG_IVS_ATTRIBUTE, formatStats(ivs))
    doItemSetAttribute(uid, EGG_NATURE_ATTRIBUTE, natureId)
end

PokemonStats.moveEggStats = function(fromUid, toUid)
    local ivs, natureId = getItemAttribute(fromUid, EGG_IVS_ATTRIBUTE), getItemAttribute(fromUid, EGG_NATURE_ATTRIBUTE)
    if (ivs and natureId) then
        doItemSetAttribute(toUid, EGG_IVS_ATTRIBUTE, ivs)
        doItemSetAttribute(toUid, EGG_NATURE_ATTRIBUTE, natureId)
    end
end

-- On the new ball of a hatched Pokemon; eggs from before breeding inheritance keep their random values
PokemonStats.applyEggStats = function(incubatorUid, ballUid)
    local ivs = parseStats(getItemAttribute(incubatorUid, EGG_IVS_ATTRIBUTE), PokemonStats.IV_MAX)
    local natureId = tonumber(getItemAttribute(incubatorUid, EGG_NATURE_ATTRIBUTE))
    PokemonStats.ensureBall(ballUid)
    if (ivs) then
        PokemonStats.setBallIvs(ballUid, ivs)
    end
    if (natureId) then
        PokemonStats.setBallNatureId(ballUid, natureId)
    end
    PokemonStats.setBallEvs(ballUid, { 0, 0, 0, 0, 0, 0 })
    doBallUpdateDescription(ballUid)
end

-- Only defeated wild Pokemon give EVs: NPC trainers' and players' Pokemon are summons
PokemonStats.isWildPokemon = function(target)
    return isMonster(target) and not isSummon(target) and not getPokemonSummon(target)
end

-- From onGainExperience: the ball that earned experience for defeating target also earns its EV yield
PokemonStats.onDefeated = function(cid, ball, target)
    if (not isItem(ball) or not isBallWithPokemon(ball.uid) or getBallFromNpc(ball.uid)
            or not PokemonStats.isWildPokemon(target)) then
        return false
    end

    local yield = PokemonStats.getEvYield(getCreatureName(target))
    local amounts = {}
    for stat = 1, PokemonStats.STAT_COUNT do
        amounts[stat] = yield and yield[stat] or 0
    end

    local bonus = PokemonStats.getHeldEvBonus(ball.uid)
    if (bonus) then
        amounts[bonus.stat] = amounts[bonus.stat] + bonus.amount
    end

    local changes = PokemonStats.addEvs(ball.uid, amounts)
    if (not changes or PokemonStats.getTotal(changes) == 0) then
        return false
    end

    doBallUpdateDescription(ball.uid)
    PokemonStats.onBallChanged(cid, ball.uid)
    return true
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
