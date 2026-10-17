function onGainExperience(cid, gainExp, referenceItem, target)
    if (getSafariZone(cid)) then
		return false
	elseif (isItem(referenceItem)) then -- referenceItem is a PokeBall that inflicted damage into our target but the Pokemon isnt out anymore
        local ball = getPlayerBall(cid)
        doPlayerPokemonAddExperience(cid, ((isItem(ball) and (ball.uid == referenceItem.uid) and isPokemonOnline(cid)) and
                getPlayerPokemon(cid) or nil), gainExp, nil, referenceItem)
        PokemonStats.onDefeated(cid, referenceItem, target)
        PokemonHeldItem.shareExperience(cid, gainExp, referenceItem.uid, target)
        Tasks.onDefeated(cid, target)
        Vocations.onDefeated(cid, target)
        Pokepedia.onDefeated(cid, target)
    elseif (isPokemonOnline(cid)) then
        doPlayerPokemonAddExperience(cid, getPlayerPokemon(cid), gainExp, nil, referenceItem)
        local ball = getPlayerBall(cid)
        PokemonStats.onDefeated(cid, ball, target)
        if (isItem(ball)) then
            PokemonHeldItem.shareExperience(cid, gainExp, ball.uid, target)
        end
        Tasks.onDefeated(cid, target)
        Vocations.onDefeated(cid, target)
        Pokepedia.onDefeated(cid, target)
    end
	return true
end
