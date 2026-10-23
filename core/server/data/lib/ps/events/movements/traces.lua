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

local WAYS = { [NORTH] = "north", [EAST] = "east", [SOUTH] = "south", [WEST] = "west" }

-- The way a step went (a diagonal by its longer side, a jump or a turn on the spot by where it faces)
local function footprintWay(cid, fromPosition, toPosition)
    local dx, dy = toPosition.x - fromPosition.x, toPosition.y - fromPosition.y
    if (fromPosition.z ~= toPosition.z or (dx == 0 and dy == 0) or math.max(math.abs(dx), math.abs(dy)) > 1) then
        return WAYS[getCreatureLookDirection(cid)] or "north"
    end
    if (math.abs(dx) > math.abs(dy)) then
        return dx > 0 and "east" or "west"
    end
    return dy > 0 and "south" or "north"
end

function onStepIn(cid, item, position, lastPosition, fromPosition, toPosition, actor)
    local set = footprintSet(cid)
    if (set == "trainer" and isPlayer(cid) and item.itemid == SAND_ITEMID and Sandboard.isUsing(cid)) then
        Sandboard.onStepIn(cid, item, position, lastPosition, fromPosition, toPosition, actor)
    end

    if (not set and isMonster(cid) and FOOTPRINT_GROUNDS[item.itemid]) then
        -- wild ones leave prints only on the screens of Rangers tracking them
        Vocations.sendPrint(cid, position, footprintWay(cid, fromPosition, toPosition))
        return true
    end

    local ways = set and FOOTPRINTS[set][FOOTPRINT_GROUNDS[item.itemid]]
    local trace = ways and ways[footprintWay(cid, fromPosition, toPosition)]
    if (trace and getRandom(0, 1) == 0) then
        doTransformItem(item.uid, trace)
        doDecayItem(item.uid)
    end
	return true
end
