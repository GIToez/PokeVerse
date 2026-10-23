function onOutfit(cid, old, current)
    local forced = getPlayerForcedOutfit(cid)
    if (forced and current.lookType ~= forced) then
        -- they chose an outfit themselves, so that one stays
        setPlayerStorageValue(cid, playersStorages.forcedOutfit, -1)
    end
    return true
end
