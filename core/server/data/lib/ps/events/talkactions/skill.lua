-- s1..s24 and m1..m24: the Pokemon's move in that slot (the client's moves bar has two rows of 12)
local WORDS = {}
for slot = 1, 24 do
    WORDS["s" .. slot] = slot
    WORDS["m" .. slot] = slot
end

function onSay(cid, words, param, channel)
    words = string.lower(words)
	if (isPokemonOnline(cid)) then
		if (isExhaust(cid)) then
			doPlayerSendCancel(cid, "Your Pokemon is exhaust.")
		elseif (hasCondition(cid, CONDITION_PACIFIED)) then
			doPlayerSendCancel(cid, "You can not attack this target right now.")
        elseif (getTilePzInfo(getCreaturePosition(cid))) then
            doPlayerSendCancel(cid, "Your Pokemon can't use moves while you're in the protection zone.")
		else
			local playerPokemon = getPlayerPokemon(cid)
            if (getTilePzInfo(getCreaturePosition(playerPokemon))) then
                doPlayerSendCancel(cid, "Your Pokemon can't use moves while he is inside a protected zone.")
                return true
            end

            local moves = (isPokemonTransformed(playerPokemon) and
                    getPokemonDefaultSkills(getPokemonCurrentTransformation(playerPokemon)) or
                    getPokemonSkills(getCreatureName(playerPokemon), getPlayerBall(cid).uid))
			if (moves[WORDS[words]] ~= nil) then
				doPokemonUseSkill(getPlayerPokemon(cid), moves[WORDS[words]])
			end
		end
	end
	return true
end
