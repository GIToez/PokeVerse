local INCUBATOR_STORAGE_BORN_DATE = 1000
local INCUBATOR_STORAGE_POKEMON_NAME = 1001
local HATCH_SECONDS = 60 * 60

function onUse(cid, item, fromPosition, itemEx, toPosition)
	if (not isItem(itemEx)) then
		doPlayerSendDefaultCancel(cid, RETURNVALUE_NOTPOSSIBLE)

	else
		local pokemonName = getPokemonNameByEggId(itemEx.itemid)

		if (not pokemonName) then
			doPlayerSendCancel(cid, "You can only use the incubator in an Pokemon egg.")

		else
			local eggMove = getItemAttribute(itemEx.uid, ITEM_ATTRIBUTES.EGG_MOVE)
			doTransformItem(item.uid, 14049) -- Transforming to a full pokemon incubator
			PokemonStats.moveEggStats(itemEx.uid, item.uid)
            doRemoveItem(itemEx.uid) -- Remove egg
			local hatchSeconds = math.floor(HATCH_SECONDS * (1 - (Vocations.perk(cid, "breeder", "hatchTime") or 0)))
			doItemSetAttribute(item.uid, INCUBATOR_STORAGE_BORN_DATE, getCurrentTimeInSeconds() + hatchSeconds)
			doItemSetAttribute(item.uid, INCUBATOR_STORAGE_POKEMON_NAME, pokemonName)
            if (eggMove) then
			    doItemSetAttribute(item.uid, ITEM_ATTRIBUTES.EGG_MOVE, eggMove)
            end
			doItemSetSpecialDescription(item.uid, string.format(__L(cid, "This incubator is hatching %s %s."), getItemArticleById(itemEx.itemid), getItemNameById(itemEx.itemid)))

			doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, string.format(__L(cid, "Your %s egg is hatching now! Use this incubator again after %d minutes."), pokemonName, math.ceil(hatchSeconds / 60)))
			doSendMagicEffect(getCreaturePosition(cid), EFFECT_FIREWORK_BLUE)
		end
	end

	return true
end
