-- Our own music and name areas, on top of the legacy ones (sounds1.lua, sounds2.lua).
--
-- These win over the legacy areas and are checked on every step, so an area here can sit
-- inside a legacy one (a new route through "Around the Viridian", say). Within this file the
-- first area containing the player wins, so put buildings before the town around them.
--
-- SOUNDS_FALLBACK comes after the legacy areas: it only names what nothing else does (the seas,
-- the edges of Johto, and last each region's name), so it can be drawn with broad strokes.
-- LEGACY_RENAMES gives legacy areas lying wholly inside a box another name.
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

-- Johto, generated with the map (areas_johto.lua), and Hoenn (areas_hoenn.lua, by
-- scripts/mapper/build_hoenn_areas.py). One entry spans its floors: there are thousands.
local function addGenerated(list, into)
    for _, a in ipairs(list) do
        into[#into + 1] = {
            [1] = math.floor((a[1] + a[4]) / 2),
            [2] = math.floor((a[2] + a[5]) / 2),
            [3] = a[6],
            [4] = math.max(a[4] - a[1], a[5] - a[2]),
            [5] = a[8],
            [6] = 1,
            [7] = 0,
            [8] = a[7],
            fromPos = { x = a[1], y = a[2], z = a[3] },
            toPos = { x = a[4], y = a[5], z = a[6] },
        }
    end
end

dofile("areas_johto.lua")
addGenerated(AREAS_JOHTO, SOUNDS_POKEVERSE)
AREAS_JOHTO = nil
dofile("areas_hoenn.lua")
addGenerated(AREAS_HOENN, SOUNDS_POKEVERSE)
AREAS_HOENN = nil

-- The old map called the road west of Fuchsia (to the Cycling Road's foot) Route 19
LEGACY_RENAMES = {
    { from = "Route 19", to = "Route 18", fromPos = { x = 3670, y = 740, z = 0 }, toPos = { x = 3850, y = 870, z = 15 } },
}

-- The seas and Johto's edges (areas_world.lua, by scripts/mapper/build_world_areas.py), then the
-- regions (the server's boxes, 079-weather.lua: Johto's overlaps Hoenn's sea so it comes first).
SOUNDS_FALLBACK = {}
dofile("areas_world.lua")
addGenerated(AREAS_WORLD, SOUNDS_FALLBACK)
AREAS_WORLD = nil

local function region(x0, y0, x1, y1, name)
    SOUNDS_FALLBACK[#SOUNDS_FALLBACK + 1] = {
        [1] = math.floor((x0 + x1) / 2), [2] = math.floor((y0 + y1) / 2), [3] = 15,
        [4] = math.max(x1 - x0, y1 - y0), [6] = 1, [7] = 0, [8] = name,
        fromPos = { x = x0, y = y0, z = 0 }, toPos = { x = x1, y = y1, z = 15 },
    }
end
region(1700, 20, 3048, 1270, "Johto")
region(2641, 1311, 4647, 3486, "Orange Islands")
region(48, 773, 2224, 2304, "Hoenn")
region(0, 0, 4689, 3600, "Kanto")
