function onUse(cid, item, fromPosition, itemEx, toPosition)
	if (PokemonHabitat and PokemonHabitat.useBall(cid, item, fromPosition, itemEx, toPosition)) then
		return true
	end
	onUseChargedBall(cid, item)
	return true
end
