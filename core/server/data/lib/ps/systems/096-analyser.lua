-- The Analyser window's server half: the catch chances of the last wild Pokemon the trainer defeated, worked out
-- with the same formula the throw uses (getCatchRollMaxFor in functions/ball/empty.lua, the Catcher perk and the
-- Discord boost perk), and the EXP of the trainer's Pokemon. The trainer's own EXP the client already has.
--
-- The client talks JSON on EXTENDED_IDS.ANALYSER:
--   client -> server  {action = "get"} (at login and when the window opens)
--   server -> client  {type = "catch", kill, name, level, chance, tries, unlockAt, skill, catcher, boost, safari, balls =
--                       {{name, item, rate, roll, chance, expected, half, unlock, blocked}, ...}}
--                     {type = "catch"} when there is no Pokemon to show
--                     {type = "pokemon", name, level, exp, prev, next, max, capped, amount}
-- After a client asked once it also gets a "catch" after every wild Pokemon it defeats and every ball it throws,
-- and a "pokemon" after every EXP its Pokemon gets.

Analyser = {}

local CLIENT = playersStorages.analyserClient
local LAST_KILL = playersStorages.analyserLastKill

local SHOWN_BALLS = { "poke", "great", "ultra" }
local HIDDEN_BALLS = { safari = true, soul = true }
local MAX_BALLS = 8
local MAX_THROWS = 5000 -- the simulation stops here; past it "expected" is unknown

local function round(value, places)
    local scale = 10 ^ (places or 4)
    return math.floor(value * scale + 0.5) / scale
end

local function send(cid, data)
    doSendPlayerExtendedOpcode(cid, EXTENDED_IDS.ANALYSER, JSON.encode(data))
end

Analyser.enabled = function(cid)
    return isPlayer(cid) and getPlayerStorageValue(cid, CLIENT) == 1
end

-- The total EXP a Pokemon needs to reach level + 1 (doPlayerPokemonAddExperience)
Analyser.pokemonExpFor = function(level)
    if (level <= 0) then
        return 0
    end
    return ((50 * level * level * level) - (150 * level * level) + (400 * level)) / 3
end

-- The chance one throw catches, 0 to 1, when the roll is getRandom(1, max) against the ball's rate: the roll,
-- then the Catcher's second chance, then the Discord boost perk (rollCatch in functions/ball/empty.lua)
Analyser.throwChance = function(rate, max, catcher, boost)
    if (not max) then
        return 0
    end
    local chance = getCatchRollChance(rate, max)
    if (chance >= 1) then
        return 1
    end
    chance = math.min(1, chance * (1 + (catcher or 0)))
    if (chance <= 0 or chance >= 1) then
        return chance
    end
    return math.min(1, chance * (boost or 1))
end

-- Throws of one ball until the catch: every throw adds `step` to the ball counter before its own roll.
-- Returns the next throw's chance, the expected number of throws (nil when it is past MAX_THROWS), the throws
-- for a 50% chance in all, the throws that can't catch yet and the next throw's roll max (nil while it can't).
Analyser.simulate = function(params)
    local tries, survive, expected, half, unlock = params.tries, 1, 0, nil, 0
    local first, firstMax
    for throw = 1, MAX_THROWS do
        tries = tries + params.step
        local max = getCatchRollMaxFor(params.catchChance, params.ignoreBallCounter, tries, params.skill)
        local chance = params.guaranteed and 1 or Analyser.throwChance(params.rate, max, params.catcher, params.boost)
        if (not first) then
            first, firstMax = chance, max
        end
        if (chance <= 0 and survive == 1) then
            unlock = throw
        end
        expected = expected + survive
        survive = survive * (1 - chance)
        if (not half and survive <= 0.5) then
            half = throw
        end
        if (survive < 0.0001) then
            return first, expected, half, unlock, firstMax
        end
    end
    return first, nil, half, unlock, firstMax
end

local function counterStep(ballName)
    return getBallCatchRate(balls[ballName].useCounter and ballName or "poke")
end

local function blockedReason(ballName, pokemonName)
    local config = balls[ballName]
    if (config.allowedElements and not table.findAsTable(config.allowedElements, getPokemonTypes(nil, pokemonName))) then
        return "type"
    end
    local allowed = getPokemonAllowedBall(pokemonName)
    if (allowed and allowed ~= ballName) then
        return "species"
    end
    return nil
end

local function ballsToShow(cid)
    local names, seen = {}, {}
    for _, name in ipairs(SHOWN_BALLS) do
        names[#names + 1], seen[name] = name, true
    end
    local carried = {}
    for name, config in pairs(balls) do
        if (not seen[name] and not HIDDEN_BALLS[name] and config.charged and getPlayerItemCount(cid, config.charged) > 0) then
            carried[#carried + 1], seen[name] = name, true
        end
    end
    table.sort(carried)
    for _, name in ipairs(carried) do
        if (#names >= MAX_BALLS) then
            break
        end
        names[#names + 1] = name
    end
    return names
end

Analyser.catchAudit = function(cid, pokemonName, level)
    if (not pokemonName or not isPokemonName(pokemonName) or not tonumber(getPokemonCatchChance(pokemonName))) then
        return { type = "catch" }
    end
    if (getSafariZone(cid)) then
        return { type = "catch", name = pokemonName, level = level, safari = true }
    end

    local catchChance = getPlayerPokemonCatchChance(cid, pokemonName)
    local ignoreBallCounter = getPokemonIgnoreBallCounter(pokemonName) and true or false
    local tries = getPlayerCatchTries(cid, getPokemonNumberByName(pokemonName))
    local skill = math.min(getPlayerSkillLevel(cid, PLAYER_SKILL_CATCHING), PLAYER_SKILL_CATCHING_MAX)
    local catcher = Vocations.perk(cid, "catcher", "catchChance") or 0
    local boost = DiscordBoostPerks.catchMultiplier() or 1

    local rows = {}
    for _, ballName in ipairs(ballsToShow(cid)) do
        local config = balls[ballName]
        local info = getItemInfo(config.charged)
        local row = { name = ballName, item = info and info.clientId or 0, rate = getBallCatchRate(ballName) }
        row.blocked = blockedReason(ballName, pokemonName)
        if (not row.blocked) then
            local chance, expected, half, unlock, roll = Analyser.simulate({ catchChance = catchChance,
                ignoreBallCounter = ignoreBallCounter, tries = tries, skill = skill, step = counterStep(ballName),
                rate = row.rate, catcher = catcher, boost = boost, guaranteed = config.guaranteedCatch })
            row.chance = round(chance)
            row.expected = expected and round(expected, 1) or nil
            row.half, row.unlock = half, unlock > 0 and unlock or nil
            row.roll = not config.guaranteedCatch and roll and math.max(1, math.floor(roll)) or nil
        end
        rows[#rows + 1] = row
    end

    return { type = "catch", name = pokemonName, level = level, chance = round(catchChance, 2), tries = round(tries, 2),
             unlockAt = not ignoreBallCounter and round(catchChance * 0.25, 2) or nil, skill = skill,
             catcher = catcher > 0 and round(catcher) or nil, boost = boost > 1 and round(boost) or nil, balls = rows }
end

local function lastKill(cid)
    local value = getPlayerStorageValue(cid, LAST_KILL)
    if (type(value) ~= "string") then
        return nil
    end
    local level, name = value:match("^(%d+)|(.+)$")
    return name, tonumber(level)
end

Analyser.sendCatch = function(cid, kill)
    if (Analyser.enabled(cid)) then
        local data = Analyser.catchAudit(cid, lastKill(cid))
        data.kill = kill or nil
        send(cid, data)
    end
end

Analyser.pokemonState = function(cid, amount)
    local ball = getPlayerBall(cid)
    if (not isItem(ball) or not isBallWithPokemon(ball.uid)) then
        return { type = "pokemon", amount = amount }
    end
    local name = getBallPokemonNickname(ball.uid)
    if (not name or name == "" or name == -1) then
        name = getBallPokemonName(ball.uid)
    end
    local level = getBallPokemonLevel(ball.uid)
    return { type = "pokemon", name = name, level = level, exp = getBallPokemonExp(ball.uid),
             prev = math.floor(Analyser.pokemonExpFor(level - 1)), next = math.floor(Analyser.pokemonExpFor(level)),
             max = level >= POKEMON_LEVEL_MAX or nil,
             capped = level - getPlayerLevel(cid) >= MAX_LEVEL_DIFF_BETWEEN_PLAYER_POKEMON or nil, amount = amount }
end

Analyser.onPokemonExp = function(cid, amount)
    if (Analyser.enabled(cid)) then
        send(cid, Analyser.pokemonState(cid, amount))
    end
end

Analyser.onKill = function(cid, target)
    if (not isPlayer(cid) or not isMonster(target)) then
        return
    end
    local name = getCreatureName(target)
    if (not isPokemonName(name)) then
        return
    end
    setPlayerStorageValue(cid, LAST_KILL, string.format("%d|%s", getMonsterLevel(target) or 0, name))
    Analyser.sendCatch(cid, true)
end

Analyser.onThrow = function(cid, pokemonName)
    local name = lastKill(cid)
    if (name == pokemonName) then
        Analyser.sendCatch(cid)
    end
end

Analyser.onLogin = function(cid)
    setPlayerStorageValue(cid, CLIENT, -1)
end

Analyser.onClientMessage = function(cid, buffer)
    local ok, data = pcall(JSON.decode, buffer)
    if (ok and type(data) == "table" and data.action == "get") then
        setPlayerStorageValue(cid, CLIENT, 1)
        Analyser.sendCatch(cid)
        send(cid, Analyser.pokemonState(cid))
    end
end
