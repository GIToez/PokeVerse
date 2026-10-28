function onPrepareDeath(cid, deathList)
    if (getPlayerFrontierIsland(cid)) then
        doTeleportThing(cid, FRONTIER_ISLAND_SAFE_POSITION, false)
        return false
    end
    if (isPlayer(cid)) then
        WarpStyles.play(cid, "faint")
    end
	return true
end
