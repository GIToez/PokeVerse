-- /pokemonexp [levels]: the first Pokemon on your belt gains enough experience for that many levels
function onSay(cid, words, param, channel)
    local levels = math.max(1, tonumber(param) or 1)
    local summon = getCreatureSummons(cid)[1]
    local ball = summon and getPlayerSlotItem(cid, PLAYER_SLOT_BALL) or getPlayerAllBallsWithPokemon(cid)[1]
    if (not ball or not isItem(ball)) then
        doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "You have no Pokemon.")
        return true
    end

    local level = getBallPokemonLevel(ball.uid)
    local amount = math.ceil(getExperienceForLevel(level + levels) - getBallPokemonExp(ball.uid))
    doPlayerPokemonAddExperience(cid, summon, math.max(1, amount), false, ball)
    return true
end
