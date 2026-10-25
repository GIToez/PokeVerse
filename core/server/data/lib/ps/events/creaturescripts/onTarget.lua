function onTarget(cid, target)
	if (isPokemonWild(target)) then
		if (getPlayerDueling(cid) or getPlayerBattleing(cid)) then
			doPlayerSendCancel(cid, __L(cid, "You can't fight wild Pokemon during a duel."))
			return false
		end
	else
		local master = getCreatureMaster(target)
        if (isNpc(master) and getNpcOpponent(master) ~= cid) then
            doPlayerSendCancel(cid, "You aren't battleing with this NPC.")
            return false
        end
    end
	return true
end
