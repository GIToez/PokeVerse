local SAND_ITEMID = 231

-- Pokemon that float over the ground and leave no prints
local NO_FOOTPRINTS = {
    ["Gastly"] = true, ["Haunter"] = true, ["Koffing"] = true, ["Weezing"] = true,
    ["Magnemite"] = true, ["Magneton"] = true, ["Misdreavus"] = true, ["Unown"] = true,
}

-- Which set of footprints (lib/ps/config/footprints.lua) a creature leaves, or nil for none.
-- Wild Pokemon leave none, so routes are not covered in tracks.
local function footprintSet(cid)
    if (isPlayer(cid)) then
        if (isPlayerGhost(cid, true) or isBiking(cid)) then
            return nil
        end
        return "trainer"
    end
    if (isNpc(cid)) then
        return "trainer"
    end
    if (isPokemon(cid) and (isPokemonOfPlayer(cid) or isPokemonOfNpc(cid))) then
        local species = getCreatureName(cid):gsub("^Shiny ", "")
        if (NO_FOOTPRINTS[species]) then
            return nil
        end
        return FOOTPRINT_SPECIES[species] or "pokemon"
    end
    return nil
end

function onStepIn(cid, item, position, lastPosition, fromPosition, toPosition, actor)
    local set = footprintSet(cid)
    if (set == "trainer" and isPlayer(cid) and item.itemid == SAND_ITEMID and Sandboard.isUsing(cid)) then
        Sandboard.onStepIn(cid, item, position, lastPosition, fromPosition, toPosition, actor)
    end

    local trace = set and FOOTPRINTS[set][FOOTPRINT_GROUNDS[item.itemid]]
    if (trace and getRandom(0, 1) == 0) then
        doTransformItem(item.uid, trace)
        doDecayItem(item.uid)
    end
	return true
end
