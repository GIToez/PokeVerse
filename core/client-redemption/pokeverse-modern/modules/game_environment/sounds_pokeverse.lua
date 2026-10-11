-- Music areas of the map parts the old map (sounds1.lua, sounds2.lua) does not have, in the
-- same format. Areas are checked in order and the first one containing the player wins, so
-- buildings go before the town around them. The minimap shows the coordinates under the mouse.

local function area(fromPos, toPos, track, priority, message)
    local list = {}
    for z = fromPos.z, toPos.z do
        list[#list + 1] = {
            [1] = math.floor((fromPos.x + toPos.x) / 2),
            [2] = math.floor((fromPos.y + toPos.y) / 2),
            [3] = z,
            [4] = math.max(toPos.x - fromPos.x, toPos.y - fromPos.y),
            [5] = track,
            [6] = priority,
            [7] = 0,
            [8] = message,
            fromPos = { x = fromPos.x, y = fromPos.y, z = z },
            toPos = { x = toPos.x, y = toPos.y, z = z },
        }
    end
    return list
end

SOUNDS_POKEVERSE = {}

local function add(list)
    for _, entry in ipairs(list) do
        SOUNDS_POKEVERSE[#SOUNDS_POKEVERSE + 1] = entry
    end
end

-- Tutorial town (Professor Oak's quest lab, where new trainers start)
add(area({ x = 5026, y = 736, z = 7 }, { x = 5040, y = 748, z = 7 }, "pokemon_center_01", 3, "Pokemon Center"))
add(area({ x = 5013, y = 752, z = 7 }, { x = 5024, y = 762, z = 7 }, "random_city_05_10", 2, "Pokemon Mart"))
add(area({ x = 4985, y = 725, z = 6 }, { x = 5060, y = 815, z = 7 }, "random_city_05_10", 1))
