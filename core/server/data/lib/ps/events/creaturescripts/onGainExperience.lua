function onGainExperience(cid, gainExp, referenceItem, target)
    if (getSafariZone(cid)) then
		return false
	elseif (isItem(referenceItem)) then -- referenceItem is a PokeBall that inflicted damage into our target but the Pokemon isnt out anymore
        local ball = getPlayerBall(cid)
        doPlayerPokemonAddExperience(cid, ((isItem(ball) and (ball.uid == referenceItem.uid) and isPokemonOnline(cid)) and
                getPlayerPokemon(cid) or nil), gainExp, nil, referenceItem)
        PokemonStats.onDefeated(cid, referenceItem, target)
        Tasks.onDefeated(cid, target)
        Vocations.onDefeated(cid)
        Pokepedia.onDefeated(cid, target)
    elseif (isPokemonOnline(cid)) then
        doPlayerPokemonAddExperience(cid, getPlayerPokemon(cid), gainExp, nil, referenceItem)
        PokemonStats.onDefeated(cid, getPlayerBall(cid), target)
        Tasks.onDefeated(cid, target)
        Vocations.onDefeated(cid)
        Pokepedia.onDefeated(cid, target)
    end
	return true
end
