if (MoveInfo) then
    return
end

-- Type matchups on the moves bar and the move cards for the modern client (EXTENDED_IDS.MOVE_INFO).
-- The numbers come from the same checks as the real damage (getSkillElementMultiplier, the held
-- item and same-type bonus in getFinalDamage), so the arrows and cards never disagree with a hit.
--
-- Client -> server:
--   { action = "matchup", target = creature id, icons = { move icon, ... } }
--   { action = "card", icon = move icon, target = creature id or 0 }
-- Server -> client:
--   { type = "matchup", target, moves = { { icon, power, final, multiplier }, ... } }: final is the power
--     with the boosts; multiplier is nil for moves with no power and for targets that aren't Pokemon
--   { type = "card", name, icon, element, category, power, energy, cooldown, range, description,
--     boosts = { { label, value }, ... }, final, target = { name, multiplier }, estimate }

MoveInfo = {}

local SAME_TYPE_BONUS = 1.1 -- getFinalDamage's STAB
local MAX_TARGET_DISTANCE = 10

local function send(cid, data)
    doSendPlayerExtendedOpcode(cid, EXTENDED_IDS.MOVE_INFO, JSON.encode(data))
end

local function round(value, places)
    local factor = 10 ^ (places or 0)
    return math.floor(value * factor + 0.5) / factor
end

-- A Pokemon the trainer can see, nil otherwise
local function visibleTarget(cid, target)
    target = tonumber(target)
    if (not target or target == 0 or not isCreature(target) or not isMonster(target)) then
        return nil
    end
    local from, to = getCreaturePosition(cid), getCreaturePosition(target)
    if (from.z ~= to.z or getDistanceBetween(from, to) > MAX_TARGET_DISTANCE) then
        return nil
    end
    return target
end

-- The multiplier a hit of this move gets against the target: 0 for an immunity (type or ability)
function MoveInfo.getMultiplier(pokemon, target, skillName)
    if (getPokemonSkillDamage(skillName) <= 0) then
        return nil
    end

    if (doPokemonSpecialAbilityCheck(target, POKEMON_SPECIAL_ABILITY_IDS.LEVITATE, nil, skillName) or
            doPokemonSpecialAbilityCheck(target, POKEMON_SPECIAL_ABILITY_IDS.MAGIC_GUARD, nil, skillName) or
            doPokemonSpecialAbilityCheck(target, POKEMON_SPECIAL_ABILITY_IDS.LIGHTNINGROD, nil, skillName) or
            doPokemonSpecialAbilityCheck(target, POKEMON_SPECIAL_ABILITY_IDS.DAMAGEONE, nil)) then
        return 0
    end

    local ok, multiplier = pcall(getSkillElementMultiplier, pokemon or 0, target, skillName)
    if (not ok) then
        return nil -- a monster that isn't a Pokemon
    end
    if (doPokemonSpecialAbilityCheck(target, POKEMON_SPECIAL_ABILITY_IDS.WONDER_GUARD, nil, multiplier)) then
        return 0
    end
    return multiplier
end

local function outPokemon(cid)
    local pokemon = getPlayerPokemon(cid)
    return isCreature(pokemon) and pokemon or nil
end

-- The move's power with the same-type bonus and the held item, and the boosts that made it
function MoveInfo.getPower(cid, pokemon, skillName)
    local basePower = getPokemonSkillDamage(skillName)
    if (basePower <= 0) then
        return nil, {}
    end

    local power, boosts = basePower, {}
    local element = getPokemonSkillDamageType(skillName)
    local ball = getPlayerBall(cid)
    local pokemonName = isItem(ball) and getBallPokemonName(ball.uid) or nil
    local types = pokemon and getPokemonTypes(pokemon) or (pokemonName and getPokemonTypes(nil, pokemonName)) or {}
    if (table.find(types, element)) then
        power = power * SAME_TYPE_BONUS
        boosts[#boosts + 1] = { label = __L(cid, "Same type as your Pokemon"), value = SAME_TYPE_BONUS }
    end

    if (pokemon) then
        local held = PokemonHeldItem.getMovePowerModifier(pokemon, element)
        if (held ~= 1) then
            power = power * held
            local heldName = isItem(ball) and PokemonHeldItem.getHeldName(getBallHeld(ball.uid), ball.uid)
            boosts[#boosts + 1] = { label = heldName or __L(cid, "Held item"), value = round(held, 2) }
        end
    end

    local weather, kind = Weather.getMovePowerModifier(pokemon or cid, element)
    if (weather ~= 1) then
        power = power * weather
        boosts[#boosts + 1] = { label = __L(cid, Weather.KINDS[kind].name), value = weather, weather = kind }
    end
    return power, boosts
end

-- The weather's part of a move's power: { kind, value }, or nil
local function weatherBoost(cid, pokemon, skillName)
    local value, kind = Weather.getMovePowerModifier(pokemon or cid, getPokemonSkillDamageType(skillName))
    if (value ~= 1 and getPokemonSkillDamage(skillName) > 0) then
        return { kind = kind, name = Weather.KINDS[kind].name, value = value }
    end
end

-- getFinalDamage's formula without the random parts (critical hits) and the abilities; nil for no damage
function MoveInfo.estimateDamage(pokemon, target, skillName, power, multiplier)
    if (multiplier <= 0) then
        return nil
    end
    local level, targetLevel = getMonsterLevel(pokemon), getMonsterLevel(target)
    local ok, attack, defense = pcall(function()
        if (getPokemonSkillCategory(skillName) == MOVE_CATEGORY.PHYSICAL) then
            return getPokemonAtk(pokemon, level), getPokemonDef(target, targetLevel)
        end
        return getPokemonSpAtk(pokemon, level), getPokemonSpDef(target, targetLevel)
    end)
    if (not ok) then
        return nil
    end
    local damage = (power * multiplier * ((level + 10) * 0.2)) + (attack - defense)
    damage = damage * (1 + getPokemonBonusAttack(pokemon)) / (1 + getPokemonBonusDefense(target))
    return math.max(1, math.ceil(damage))
end

local function onMatchup(cid, data)
    local target = visibleTarget(cid, data.target)
    local pokemon = outPokemon(cid)

    local moves = {}
    for _, icon in ipairs(type(data.icons) == "table" and data.icons or {}) do
        local skillName = getPokemonSkillByClientIconId(tonumber(icon))
        if (skillName) then
            local power = MoveInfo.getPower(cid, pokemon, skillName)
            moves[#moves + 1] = {
                icon = tonumber(icon),
                power = getPokemonSkillDamage(skillName) > 0 and getPokemonSkillDamage(skillName) or nil,
                final = power and round(power) or nil,
                multiplier = target and MoveInfo.getMultiplier(pokemon, target, skillName) or nil,
                weather = weatherBoost(cid, pokemon, skillName)
            }
        end
        if (#moves >= 12) then
            break
        end
    end
    send(cid, { type = "matchup", target = tonumber(data.target) or 0, moves = moves })
end

local function onCard(cid, data)
    local skillName = getPokemonSkillByClientIconId(tonumber(data.icon))
    if (not skillName) then
        return
    end

    local card = LevelUpBanner.getMoveInfo(cid, skillName)
    card.type = "card"
    card.range = getPokemonSkillMaxDistance(skillName)
    card.icon = tonumber(data.icon)

    local pokemon = outPokemon(cid)
    local power, boosts = MoveInfo.getPower(cid, pokemon, skillName)
    card.boosts = boosts
    if (power) then
        card.final = round(power)

        local target = visibleTarget(cid, data.target)
        if (target) then
            local multiplier = MoveInfo.getMultiplier(pokemon, target, skillName)
            if (multiplier) then
                card.target = { name = getCreatureName(target), multiplier = multiplier }
            end
            if (multiplier and pokemon) then
                card.estimate = MoveInfo.estimateDamage(pokemon, target, skillName, power, multiplier)
            end
        end
    end
    send(cid, card)
end

function MoveInfo.onClientMessage(cid, buffer)
    local ok, data = pcall(JSON.decode, buffer)
    if (not ok or type(data) ~= "table") then
        return
    end
    if (data.action == "matchup") then
        onMatchup(cid, data)
    elseif (data.action == "card") then
        onCard(cid, data)
    end
end
