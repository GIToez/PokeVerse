-- Discord server boost perks: while the PokeVerse Discord has server boost level 1, 2 or 3,
-- everyone online gets more experience (level 1+), a better catch chance (level 2+) and a better
-- shiny chance (level 3). Switched by discordBridgeBoostPerks; the percentages are in config.lua.
--
-- Only the bridge's boost.level request changes the level. It is kept in global storage, written
-- to the database at once, so the perks survive a restart and keep working while the bot is away;
-- the serverExpEvent globalevent (DiscordBoostPerks.onThink) puts it back into C++ after a start.
--
-- The multipliers live in C++ (Game::getDiscordBoost*Multiplier) so every Lua state and the
-- spawn code see the same values. Each is applied once, on top of every other bonus:
--   experience  Player::rateExperience (trainer kill experience) and doPlayerPokemonAddExperience
--               (Pokemon kill experience), after the experience event
--   catch       rollCatch (ball/empty.lua) and the Safari Zone: the final chance, Catcher perk
--               included, times the multiplier, never above a sure catch; guaranteed catches skip it
--   shiny       ShinyEvent.chance (fishing, headbutt, eggs, incubators, abilities, script spawns)
--               and Spawn::spawnMonster (map spawns), after the shiny event

DiscordBoostPerks = {}

local KEY_LEVEL = GLOBAL_STORAGES.DISCORD_BOOST_LEVEL
local KEY_BOOSTS = GLOBAL_STORAGES.DISCORD_BOOST_COUNT
local MAX_LEVEL = 3
local MAX_BOOSTS = 1000

local fail = DiscordBridge.fail

local function storedNumber(key)
    return tonumber(getStorage(key)) or 0
end

local function store(key, value)
    doSetStorage(key, value)
    db.executeQuery(string.format("REPLACE INTO `global_storage` (`key`, `world_id`, `value`) VALUES (%d, %d, %s);",
        key, getConfigValue("worldId") or 0, db.escapeString(tostring(value))))
end

local function isInteger(value)
    return type(value) == "number" and value == math.floor(value)
end

function DiscordBoostPerks.isEnabled()
    return getDiscordBoostPerks().enabled == true
end

function DiscordBoostPerks.storedLevel()
    local level = storedNumber(KEY_LEVEL)
    return (isInteger(level) and level >= 0 and level <= MAX_LEVEL) and level or 0
end

-- Every configured perk with the level it needs (a perk set to 0% is left out).
function DiscordBoostPerks.list()
    local perks = getDiscordBoostPerks()
    local list = {}
    if (perks.expPercent > 0) then
        list[#list + 1] = {level = 1, text = string.format("+%d%% experience", perks.expPercent)}
    end
    if (perks.catchPercent > 0) then
        list[#list + 1] = {level = 2, text = string.format("+%d%% catch rate", perks.catchPercent)}
    end
    if (perks.shinyPercent > 0) then
        list[#list + 1] = {level = 3, text = string.format("+%d%% shiny spawn rate", perks.shinyPercent)}
    end
    return list
end

function DiscordBoostPerks.activeTexts(level)
    local texts = {}
    for _, perk in ipairs(DiscordBoostPerks.list()) do
        if (perk.level <= level) then
            texts[#texts + 1] = perk.text
        end
    end
    return texts
end

local function joinTexts(texts)
    if (#texts <= 1) then
        return texts[1] or ""
    end
    return table.concat(texts, ", ", 1, #texts - 1) .. " and " .. texts[#texts]
end

-- "Server Boost Level 2: everyone gets +5% experience and +5% catch rate.", or nil at level 0 or when off.
function DiscordBoostPerks.describe()
    if (not DiscordBoostPerks.isEnabled()) then
        return nil
    end
    local level = getDiscordBoostPerks().level
    local texts = DiscordBoostPerks.activeTexts(level)
    if (level < 1 or #texts == 0) then
        return nil
    end
    return string.format("PokeVerse Discord Server Boost Level %d: everyone gets %s.", level, joinTexts(texts))
end

function DiscordBoostPerks.expMultiplier()
    return getDiscordBoostPerks().exp
end

function DiscordBoostPerks.shinyMultiplier()
    return getDiscordBoostPerks().shiny
end

function DiscordBoostPerks.catchMultiplier()
    return getDiscordBoostPerks().catch
end

-- The catch chance after the perk: chance (0 to 1) times the multiplier, at most a sure catch.
function DiscordBoostPerks.catchChance(chance)
    if (chance <= 0 or chance >= 1) then
        return chance
    end
    return math.min(1, chance * getDiscordBoostPerks().catch)
end

-- Called after a throw missed at `chance` (the final chance, every other bonus included): rolls
-- again for the difference, so the throw catches with DiscordBoostPerks.catchChance(chance) in all.
function DiscordBoostPerks.catchBonusRoll(chance)
    local boosted = DiscordBoostPerks.catchChance(chance)
    if (boosted <= chance) then
        return false
    end
    return math.random() < (boosted - chance) / (1 - chance)
end

local function broadcastChange(old, level)
    local texts = DiscordBoostPerks.activeTexts(level)
    local message
    if (level > old) then
        message = string.format("The PokeVerse Discord reached Server Boost Level %d!", level)
    else
        message = string.format("The PokeVerse Discord dropped to Server Boost Level %d.", level)
    end
    if (#texts > 0) then
        message = string.format("%s Everyone now gets %s.", message, joinTexts(texts))
    else
        message = message .. " The server boost perks are paused until it reaches Level 1 again."
    end
    doBroadcastMessage(message, MESSAGE_STATUS_WARNING)
end

local function handleLevel(params)
    if (not DiscordBoostPerks.isEnabled()) then
        fail("disabled", "server boost perks are disabled on this server")
    end
    local level, boosts = params.level, params.boosts
    if (not isInteger(level) or level < 0 or level > MAX_LEVEL) then
        fail("invalid_params", string.format("level must be an integer from 0 to %d", MAX_LEVEL))
    end
    if (not isInteger(boosts) or boosts < 0 or boosts > MAX_BOOSTS) then
        fail("invalid_params", string.format("boosts must be an integer from 0 to %d", MAX_BOOSTS))
    end

    local old = DiscordBoostPerks.storedLevel()
    if (storedNumber(KEY_BOOSTS) ~= boosts) then
        store(KEY_BOOSTS, boosts)
    end
    if (old ~= level) then
        store(KEY_LEVEL, level)
        print(string.format("> Discord boost perks: server boost level %d -> %d (%d boosts).", old, level, boosts))
    end
    setDiscordBoostLevel(level)
    if (old ~= level) then
        broadcastChange(old, level)
        if (ExpBoost) then ExpBoost.sendAll() end
    end

    local perks = JSON.array()
    for _, text in ipairs(DiscordBoostPerks.activeTexts(level)) do
        perks[#perks + 1] = text
    end
    return {level = level, perks = perks}
end

local restored = false

function DiscordBoostPerks.onThink()
    local level = DiscordBoostPerks.storedLevel()
    if (getDiscordBoostPerks().level ~= level) then
        setDiscordBoostLevel(level)
        if (ExpBoost) then ExpBoost.sendAll() end
    end
    if (not restored) then
        restored = true
        if (level > 0) then
            print(string.format("> Discord boost perks: server boost level %d restored%s.", level,
                DiscordBoostPerks.isEnabled() and "" or " (perks are off in config.lua)"))
        end
    end
end

function DiscordBoostPerks.onLogin(cid)
    local text = DiscordBoostPerks.describe()
    if (text) then
        doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, text)
    end
end

DiscordBridge.registerHandler("boost.level", handleLevel)
