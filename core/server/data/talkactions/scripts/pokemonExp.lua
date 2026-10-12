-- /pokemonexp [levels][, name]: your Pokemon out (or the first one on your belt or in your bag,
-- or the first one with that name) gains enough experience for that many levels
function onSay(cid, words, param, channel)
    local params = string.explode(param, ",")
    local levels = math.max(1, tonumber(params[1]) or 1)
    local name = params[2] and params[2]:trim():lower()

    local summon = getCreatureSummons(cid)[1]
    local ball = summon and not name and getPlayerSlotItem(cid, PLAYER_SLOT_BALL) or nil
    if (not ball) then
        summon = nil
        for _, item in ipairs(getPlayerAllBallsWithPokemon(cid)) do
            if (not name or getBallPokemonName(item.uid):lower() == name) then
                ball = item
                break
            end
        end
    end
    if (not ball or not isItem(ball)) then
        doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "No such Pokemon.")
        return true
    end

    local level = getBallPokemonLevel(ball.uid)
    local amount = math.ceil(getExperienceForLevel(level + levels) - getBallPokemonExp(ball.uid))
    doPlayerPokemonAddExperience(cid, summon, math.max(1, amount), false, ball)
    return true
end
