-- Experience boosts for the stamina bar's tooltip: what multiplies the trainer's and the Pokemon's kill experience
-- right now. Trainer EXP gets stamina (Player::getStaminaExperienceRate), the personal bonus (XP Boost Potion,
-- cakes, Stone of Knowledge...), the server event and the Discord server boost perk; Pokemon EXP gets the held Lucky
-- Egg, stamina, the personal bonus, the Ace Trainer perk, the server event and the Discord boost perk
-- (doPlayerPokemonAddExperience).
--
-- The client talks JSON on EXTENDED_IDS.EXP_BOOST:
--   client -> server  {action = "get"} (at login and when its stamina changes)
--   server -> client  {type = "boost", stamina = {minutes, rate}, premium, personal = {rate, left}, event, pokemon =
--                     {name, luckyEgg}, ace, discordBoost, trainer, pokemonTotal}
-- After a client asked once, it also gets one when a personal bonus starts or ends and when the server event changes.

ExpBoost = {}

local CLIENT = playersStorages.expBoostClient

local function round(value)
    return math.floor(value * 1000 + 0.5) / 1000
end

ExpBoost.state = function(cid)
    local stamina = getPlayerStaminaExperienceRate(cid) or 1
    local personal = getPlayerExtraExpRate(cid) or 0
    local left = personal > 0 and math.max(0, getPlayerExtraExpRateTime(cid) - os.time()) or 0
    local event = getExperienceEventMultiplier() or 1
    local discordBoost = DiscordBoostPerks.expMultiplier()

    local luckyEgg, pokemonName = 1, nil
    local ball = getPlayerBall(cid)
    if (isItem(ball) and isBallWithPokemon(ball.uid)) then
        pokemonName = getBallPokemonNickname(ball.uid)
        if (not pokemonName or pokemonName == "" or pokemonName == -1) then
            pokemonName = getBallPokemonName(ball.uid)
        end
        luckyEgg = PokemonHeldItem.getExpRate(ball.uid)
    end
    local ace = Vocations.perk(cid, "ace", "battleExp") or 0

    return { type = "boost", stamina = { minutes = getPlayerStamina(cid), rate = round(stamina) },
             premium = isPremium(cid) or nil, personal = { rate = round(personal), left = left }, event = round(event),
             pokemon = { name = pokemonName, luckyEgg = round(luckyEgg) }, ace = ace > 0 and round(ace) or nil,
             discordBoost = discordBoost > 1 and round(discordBoost) or nil,
             trainer = round(stamina * (1 + personal) * event * discordBoost),
             pokemonTotal = round(luckyEgg * stamina * (1 + personal) * (1 + ace) * event * discordBoost) }
end

ExpBoost.send = function(cid)
    if (isPlayer(cid) and getPlayerStorageValue(cid, CLIENT) == 1) then
        doSendPlayerExtendedOpcode(cid, EXTENDED_IDS.EXP_BOOST, JSON.encode(ExpBoost.state(cid)))
    end
end

ExpBoost.sendAll = function()
    for _, cid in ipairs(getPlayersOnline()) do
        ExpBoost.send(cid)
    end
end

ExpBoost.onLogin = function(cid)
    setPlayerStorageValue(cid, CLIENT, -1)
end

ExpBoost.onClientMessage = function(cid, buffer)
    local ok, data = pcall(JSON.decode, buffer)
    if (ok and type(data) == "table" and data.action == "get") then
        setPlayerStorageValue(cid, CLIENT, 1)
        ExpBoost.send(cid)
    end
end
