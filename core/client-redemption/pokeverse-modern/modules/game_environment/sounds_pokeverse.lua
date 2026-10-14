-- Our own music and name areas, on top of the legacy ones (sounds1.lua, sounds2.lua).
--
-- These win over the legacy areas and are checked on every step, so an area here can sit
-- inside a legacy one (a new route through "Around the Viridian", say). Within this file the
-- first area containing the player wins, so put buildings before the town around them.
--
--   area(fromPos, toPos, track, priority, name)
--     fromPos, toPos  corners of the rectangle; z can span floors (fromPos.z to toPos.z)
--     track           a key of SOUND_FILES (environment.lua), or nil to keep the music that
--                     is playing and only change the name
--     priority        kept for the legacy format, unused here
--     name            shown in the area banner and next to the clock; its banner theme and
--                     line come from area_names.lua
--
-- The minimap shows the coordinates under the mouse; click it to copy your own position.

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
add(area({ x = 4985, y = 725, z = 6 }, { x = 5060, y = 815, z = 7 }, "random_city_05_10", 1, "Tutorial Island"))

-- New routes. Example (fill in the corners from the minimap, then remove the --):
-- add(area({ x = 0, y = 0, z = 7 }, { x = 0, y = 0, z = 7 }, nil, 1, "Route 02"))
