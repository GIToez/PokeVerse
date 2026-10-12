-- Level-up banners in the client (game_levelup), sent as JSON on EXTENDED_IDS.LEVEL_UP:
--   {kind = "pokemon", name, number, from, to, stats = {{name, old, new}, ...}, moves = {move, ...}}
--   {kind = "trainer", name, from, to, hp = {old, new}, pokemonCap, unlocks = {{icon, title, text}, ...}}
--   {kind = "tm", name, number, move = move}
-- with move = {name, icon, element, category, power, energy, cooldown, description}.

LevelUpBanner = {}

-- Trainer levels that open something new; icon is an image in the client's /images/advances
LevelUpBanner.UNLOCKS = {
    [10] = { { icon = "rangerclub", title = "New Feature", text = "Ranger Club - Rookie" } },
    [15] = { { icon = "tournament", title = "New Feature", text = "Tournament - Starter" } },
    [25] = { { icon = "rangerclub", title = "New Feature", text = "Ranger Club - Mentor" } },
    [30] = { { icon = "safarizone", title = "New Feature", text = "The Safari Zone" } },
    [41] = { { icon = "tournament", title = "New Feature", text = "Tournament - Pro" } },
    [46] = { { icon = "tournament", title = "New Feature", text = "Tournament - Master" } },
    [50] = { { icon = "rangerclub", title = "New Feature", text = "Ranger Club - Coordinator" } },
    [61] = { { icon = "tournament", title = "New Feature", text = "Tournament - Elite" } },
    [70] = { { icon = "battletower", title = "New Feature", text = "Battle Tower - Twenty" } },
    [75] = {
        { icon = "rangerclub", title = "New Feature", text = "Ranger Club - Coach" },
        { icon = "tournament", title = "New Feature", text = "Tournament - Titan" }
    },
    [80] = { { icon = "battletower", title = "New Feature", text = "Battle Tower - Fifteen" } },
    [85] = {
        { icon = "daycare", title = "New Feature", text = "Day Care" },
        { icon = "mastery", title = "New Feature", text = "Mastery" }
    },
    [90] = { { icon = "battletower", title = "New Feature", text = "Battle Tower - Ten" } },
}

local function send(cid, data)
    if (isPlayer(cid) and getPlayerUsingOtClient(cid)) then
        doSendPlayerExtendedOpcode(cid, EXTENDED_IDS.LEVEL_UP, JSON.encode(data))
    end
end

LevelUpBanner.getMoveInfo = function(cid, moveName)
    if (not getPokemonSkillExists(moveName)) then
        return { name = moveName }
    end
    local description = getPokemonSkillDescription(moveName)
    return {
        name = moveName,
        icon = getPokemonSkillClientIconId(moveName),
        element = getPokemonSkillDamageType(moveName),
        category = getPokemonSkillCategory(moveName),
        power = tostring(getPokemonSkillDamageText(moveName)),
        energy = getPokemonSkillRequiredEnergy(moveName),
        cooldown = getPokemonSkillCooldownTime(moveName),
        description = description and __L(cid, description) or ""
    }
end

LevelUpBanner.getStatChanges = function(ballUid, pokemonName, fromLevel, toLevel)
    if (PokemonStats.ensureBall) then
        PokemonStats.ensureBall(ballUid)
    end
    local before = PokemonStats.getStatSheet(ballUid, pokemonName, fromLevel)
    local after = PokemonStats.getStatSheet(ballUid, pokemonName, toLevel)
    local stats = {}
    if (before and after) then
        for stat = 1, PokemonStats.STAT_COUNT do
            stats[#stats + 1] = { name = POKEMON_STAT_NAMES[stat], old = before.actual[stat], new = after.actual[stat] }
        end
    end
    return stats
end

LevelUpBanner.sendPokemon = function(cid, ballUid, pokemonName, displayName, fromLevel, toLevel, moveNames)
    local moves = {}
    for _, moveName in ipairs(moveNames or {}) do
        moves[#moves + 1] = LevelUpBanner.getMoveInfo(cid, moveName)
    end
    send(cid, {
        kind = "pokemon",
        name = displayName or pokemonName,
        number = getPokemonNumberByName(pokemonName),
        from = fromLevel,
        to = toLevel,
        stats = LevelUpBanner.getStatChanges(ballUid, pokemonName, fromLevel, toLevel),
        moves = moves
    })
end

LevelUpBanner.getUnlocks = function(cid, fromLevel, toLevel)
    local unlocks = {}
    for level = fromLevel + 1, toLevel do
        for _, unlock in ipairs(LevelUpBanner.UNLOCKS[level] or {}) do
            unlocks[#unlocks + 1] = { icon = unlock.icon, title = __L(cid, unlock.title), text = __L(cid, unlock.text) }
        end
    end
    return unlocks
end

LevelUpBanner.sendTrainer = function(cid, fromLevel, toLevel)
    local vocation = getVocationInfo(getPlayerVocation(cid))
    local hpGain = (vocation and vocation.healthGain or 0) * (toLevel - fromLevel)
    local maxHealth = getCreatureMaxHealth(cid)
    send(cid, {
        kind = "trainer",
        name = getCreatureName(cid),
        from = fromLevel,
        to = toLevel,
        hp = { old = maxHealth - hpGain, new = maxHealth },
        pokemonCap = math.min(toLevel + MAX_LEVEL_DIFF_BETWEEN_PLAYER_POKEMON, POKEMON_LEVEL_MAX),
        unlocks = LevelUpBanner.getUnlocks(cid, fromLevel, toLevel)
    })
end

LevelUpBanner.sendTm = function(cid, pokemonName, displayName, moveName)
    send(cid, {
        kind = "tm",
        name = displayName or pokemonName,
        number = getPokemonNumberByName(pokemonName),
        move = LevelUpBanner.getMoveInfo(cid, moveName)
    })
end
