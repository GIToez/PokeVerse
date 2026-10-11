-- Easter egg: at most one wild Pikachu somewhere in Viridian Forest.
local RESPAWN_PLACES = {{3209, 384, 7}, {3243, 381, 7}, {3257, 505, 7}, {3267, 386, 7}, {3277, 389, 7}, {3287, 464, 7}, {3296, 481, 7}, {3304, 451, 7}, {3312, 488, 7}, {3332, 405, 7}}
local FOREST_CENTER = {x = 3270, y = 445, z = 7}
local FOREST_RANGE_X, FOREST_RANGE_Y = 100, 80
local lastPikachu

local function hasWildPikachu()
    if (lastPikachu and isCreature(lastPikachu)) then
        return true
    end

    local spec = getSpectators(FOREST_CENTER, FOREST_RANGE_X, FOREST_RANGE_Y, false)
    if (spec) then
        for _, creature in pairs(spec) do
            local name = getCreatureName(creature)
            if (isPokemonWild(creature) and (name == "Pikachu" or name == "Shiny Pikachu")) then
                return true
            end
        end
    end
    return false
end

function onThink()
    if (hasWildPikachu()) then
        return true
    end

    lastPikachu = nil
    local pos = table.random(RESPAWN_PLACES)
    local m = doCreateMonster("Pikachu", {x = pos[1], y = pos[2], z = pos[3]}, false, true)
    if (isMonster(m)) then
        lastPikachu = m
    else
        log(LOG_TYPES.WARNING, "viridianPikachu - Can't spawn monster at position.", pos[1], pos[2], pos[3])
    end
    return true
end
