local TILES = {
	[NORTH] = {
		{x = -1, y = 1},
		{x = 0, y = 1},
		{x = 1, y = 1}
	},
	[EAST] = {
		{x = -1, y = -1},
		{x = -1, y = 0},
		{x = -1, y = 1}
	},
	[SOUTH] = {
		{x = -1, y = -1},
		{x = 0, y = -1},
		{x = 1, y = -1},
	},
	[WEST] = {
		{x = 1, y = -1},
		{x = 1, y = 0},
		{x = 1, y = 1}
	},
	[SOUTHWEST] = {
		{x = -1, y = -1},
		{x = 0, y = -1},
		{x = 1, y = -1},
		{x = 1, y = 0},
		{x = 1, y = 1}
	},
	[SOUTHEAST] = {
		{x = -1, y = -1},
		{x = 0, y = -1},
		{x = 1, y = -1},
		{x = -1, y = 0},
		{x = -1, y = 1}
	},
	[NORTHWEST] = {
		{x = 1, y = -1},
		{x = 1, y = 0},
		{x = 1, y = 1},
		{x = 0, y = 1},
		{x = -1, y = 1}
	},
	[NORTHEAST] = {
		{x = -1, y = -1},
		{x = -1, y = 0},
		{x = -1, y = 1},
		{x = 0, y = 1},
		{x = 1, y = 1}
	}
}

local function canDeleteTile(cid, pos)
    local specs = getSpectators(pos, 1, 1, false)
    if (specs) then
        for k, v in pairs(specs) do
            if (cid ~= v) then
                return false
            end
        end
    end
    return true
end

-- Same box as getPlayerInsideJohto, on every floor: flying keeps to the region you took off in
local JOHTO_FROM, JOHTO_TO = {x = 1700, y = 20}, {x = 3048, y = 1270}
local BOUNCED = {}

local function crossesJohtoBorder(fromPosition, toPosition)
	return isInRange(fromPosition, JOHTO_FROM, JOHTO_TO, true) ~= isInRange(toPosition, JOHTO_FROM, JOHTO_TO, true)
end

function onStepIn(cid, item, position, lastPosition, fromPosition, toPosition, actor)
	if (not isPlayer(cid)) then
		doTeleportThing(cid, fromPosition, false)

	elseif (not isFlying(cid) and not isLevitating(cid) and not getPlayerTraveling(cid)) then
		doTeleportThing(cid, fromPosition, false)
		doPlayerSendDefaultCancel(cid, RETURNVALUE_NOTPOSSIBLE)

	elseif (BOUNCED[cid]) then
		BOUNCED[cid] = nil

	elseif (not getPlayerTraveling(cid) and crossesJohtoBorder(fromPosition, toPosition)) then
		-- stepping back onto the void tile fires this again, the other way across the border
		BOUNCED[cid] = true
		doTeleportThing(cid, fromPosition, false)
		BOUNCED[cid] = nil
		doPlayerSendCancel(cid, "You can't fly out of this region. Land and go on foot, or take a ship or the train.")

	else
		for i, tile in ipairs(TILES[getDirectionTo(fromPosition, toPosition)]) do
            local tmpPos = {x = fromPosition.x + tile.x, y = fromPosition.y + tile.y, z = fromPosition.z}
			local item = getTileItemById(tmpPos, VOID_TILE_ID)
			if (isItem(item) and canDeleteTile(cid, tmpPos)) then
                doRemoveItem(item.uid)
			end
		end

		for j, unsetTilePosition in ipairs(getUnsetTilesArroundPosition(toPosition)) do
			doCreateTileInPosition(VOID_TILE_ID, unsetTilePosition)
		end
	end
	return true
end

function onStepOut(cid, item, position, lastPosition, fromPosition, toPosition, actor)
	local tile = getTileThingByPos({x = toPosition.x, y = toPosition.y, z = toPosition.z,
        stackpos = STACKPOS_GROUND})
	if (isItem(tile) and tile.itemid ~= VOID_TILE_ID) then -- If I'm leaving  fly tiles
		deleteTilesArroundPositionWithId(fromPosition, VOID_TILE_ID,
            function(tmpPos)
                return canDeleteTile(cid, tmpPos)
            end)
	end
	return true
end

function onAddItem(moveItem, tileItem, position, cid)
	local removeItem = true
	for i = 1, MAP_LAYER_MID - position.z  do
		if (doTeleportThing(moveItem.uid, {x = position.x, y = position.y, z = position.z + i})) then
			removeItem = false
			break
		end
	end
	if (removeItem) then
		doRemoveItem(moveItem.uid)
	end
	return true
end