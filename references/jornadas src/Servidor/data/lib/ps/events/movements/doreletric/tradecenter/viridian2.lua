-- CONFIGURAÇÕES --

local doors = {32145, 32147, 32146}
local door_pos = {x = 3259, y = 556, z = 6}



-- FIM CONFIGURAÇÕES --
local top_left = {x = door_pos.x + 1, y = door_pos.y + 1, z = door_pos.z}
local bottom_right = {x = door_pos.x - 1, y = door_pos.y - 1, z = door_pos.z}


local function areThereCreaturesInArea(top_left, bottom_right)

	for x = top_left.x, bottom_right.x do
		for y = top_left.y, bottom_right.y do
			if isCreature(getTopCreature({x=x, y=y, z=top_left.z}).uid) then
				return true
			end
		end
	end
	
	return false
end

local function open(pos, i)

if i < #doors then

	current = doors[i]
	next_ = doors[i+1]

	local door = getTileItemById(pos, current)
	if door.uid > 0 then
		doTransformItem(door.uid, next_)
		addEvent(open, 250, pos, i+1)
	end
end
	
end

local function close_(pos, i)

if areThereCreaturesInArea(top_left, bottom_right) then
	return true
end

if i <= #doors and i > 1 then

	current = doors[i]
	next_ = doors[i-1]
	
	local door = getTileItemById(pos, current)
	if door.uid > 0 then
		doTransformItem(door.uid, next_)
		addEvent(close_, 250, pos, i-1)
	end
end
	
end

function onStepIn(cid, item, position, lastPosition, fromPosition, toPosition, actor)

	for i = 1, #doors do
		local door = getTileItemById(door_pos, doors[i])
		if door.uid > 0 then
			open(door_pos, i)
			break
		end
	end

	return true
end

function onStepOut(cid, item, position, lastPosition, fromPosition, toPosition, actor)

	close_(door_pos, #doors)

	return true
end