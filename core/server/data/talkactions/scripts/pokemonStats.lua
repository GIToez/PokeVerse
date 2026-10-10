-- Staff test tool for IVs, EVs and Natures, on the ball in the ball slot:
--   /pstats                      show them
--   /pstats iv,atk,+1            raise, lower (-5) or set (31) one stat; "all" for every stat
--   /pstats ev,spe,252
--   /pstats nature,adamant
--   /pstats reroll               new random IVs and Nature, EVs back to 0
--   /pstats Trainer,iv,atk,+1    the same on another online player's ball
-- Gamemasters view anyone's Pokemon but change only their own; Community Managers and Gods change anyone's. Access levels, not group
-- ids, because groups 7 to 9 are player and tutor groups.
local ACCESS_OWN = 3
local ACCESS_OTHERS = 4

local STAT_KEYS = {
    hp = POKEMON_STAT.HP, atk = POKEMON_STAT.ATTACK, def = POKEMON_STAT.DEFENSE,
    spa = POKEMON_STAT.SPECIAL_ATTACK, spd = POKEMON_STAT.SPECIAL_DEFENSE, spe = POKEMON_STAT.SPEED
}

local ACTIONS = { iv = true, ev = true, nature = true, reroll = true }

local function reply(cid, text)
    doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, text)
end

local function applyChange(values, stats, amount, max, totalMax)
    local relative = amount:sub(1, 1) == "+" or amount:sub(1, 1) == "-"
    local number = tonumber(amount)
    if (not number) then
        return false
    end

    for _, stat in ipairs(stats) do
        local limit = max
        if (totalMax) then
            local others = 0
            for other, value in ipairs(values) do
                if (other ~= stat) then
                    others = others + value
                end
            end
            -- The stat being changed takes what is left of the total, so other stats are never trimmed
            limit = math.min(limit, totalMax - others)
        end
        values[stat] = math.max(0, math.min(limit, relative and values[stat] + number or number))
    end
    return true
end

function onSay(cid, words, param, channel)
    if (getPlayerAccess(cid) < ACCESS_OWN) then
        return false
    end

    local args = string.explode(param, ",")
    local target = cid
    local targetPlayer = args[1] and getPlayerByName(string.trim(args[1]))
    if (targetPlayer and isPlayer(targetPlayer)) then
        if (targetPlayer ~= cid and args[2] and getPlayerAccess(cid) < ACCESS_OTHERS) then
            reply(cid, "You can only change your own Pokemon.")
            return true
        end
        target = targetPlayer
        table.remove(args, 1)
    elseif (args[1] and not ACTIONS[string.trim(args[1]):lower()]) then
        reply(cid, string.format("Player %s is not online.", string.trim(args[1])))
        return true
    end

    for i, arg in ipairs(args) do
        args[i] = arg:lower():gsub("%s", "")
    end
    local action = args[1] or ""

    local ball = getPlayerBall(target)
    if (not isItem(ball) or not isBallWithPokemon(ball.uid)) then
        reply(cid, "There is no ball with a Pokemon in the ball slot.")
        return true
    end

    if (action == "iv" or action == "ev") then
        local stats = {}
        if (args[2] == "all") then
            for i = 1, PokemonStats.STAT_COUNT do
                stats[i] = i
            end
        elseif (STAT_KEYS[args[2] or ""]) then
            stats[1] = STAT_KEYS[args[2]]
        else
            reply(cid, "Stats: hp, atk, def, spa, spd, spe or all.")
            return true
        end

        local isIv = action == "iv"
        local values = isIv and PokemonStats.getBallIvs(ball.uid) or PokemonStats.getBallEvs(ball.uid)
        if (not applyChange(values, stats, args[3] or "", isIv and PokemonStats.IV_MAX or PokemonStats.EV_MAX,
            not isIv and PokemonStats.EV_TOTAL_MAX or nil)) then
            reply(cid, "Give an amount: +1, -5 or 31.")
            return true
        end

        if (isIv) then
            PokemonStats.setBallIvs(ball.uid, values)
        else
            PokemonStats.setBallEvs(ball.uid, values)
        end

    elseif (action == "nature") then
        local natureId = PokemonStats.getNatureIdByName(args[2] or "")
        if (not natureId) then
            reply(cid, "Unknown Nature.")
            return true
        end
        PokemonStats.setBallNatureId(ball.uid, natureId)

    elseif (action == "reroll") then
        PokemonStats.setBallIvs(ball.uid, PokemonStats.rollIvs())
        PokemonStats.setBallEvs(ball.uid, { 0, 0, 0, 0, 0, 0 })
        PokemonStats.setBallNatureId(ball.uid, PokemonStats.rollNature())

    elseif (action ~= "") then
        reply(cid, "Use /pstats, /pstats iv,atk,+1, /pstats ev,spe,252, /pstats nature,adamant or /pstats reroll.")
        return true
    end

    if (action ~= "") then
        doBallUpdateDescription(ball.uid)
        PokemonStats.onBallChanged(target, ball.uid)
    end
    reply(cid, string.format("%s's %s%s", getCreatureName(target), getBallPokemonName(ball.uid),
        PokemonStats.getBallDescription(ball.uid)))
    return true
end
