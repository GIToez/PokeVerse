-- Brock's family (Brockling Salvadore #02, quest 8459): two cooked onigiri for each of the eight Brocklings at
-- home (events/actions/quests/cookedOnigiri.lua). Brock (at the gym) and Salvadore (the cook) aren't fed.
--
-- Their counters used to be storages 8476-8483, which other quests use too: 8477-8481 are the spots of
-- Rebbeca's ribbons and 8483 a spot of the Rocket Captain's broom, so either quest could undo a feeding (or
-- the other way round). They have their own storages now, 8764-8771. A trainer who was feeding when this
-- changed keeps every Brockling already fed twice (only the feeding sets 2: the other quests set 1).

Brocklings = {}

Brocklings.ORDER = { "Brockling Yolanda", "Brockling Suzie", "Brockling Timmy", "Brockling Billy",
                     "Brockling Tilly", "Brockling Cindy", "Brockling Tommy", "Brockling Forrest" }

Brocklings.FOOD = {} -- name -> its counter
local OLD = {} -- name -> the counter it used before
for i, name in ipairs(Brocklings.ORDER) do
    Brocklings.FOOD[name] = 8763 + i
    OLD[name] = 8475 + i
end

local REQUIRED_FOOD = 2

-- the counters at their new storages, carried over once from the old ones
local function migrate(cid)
    if (getCreatureStorage(cid, Brocklings.FOOD[Brocklings.ORDER[1]]) >= 0) then
        return
    end
    for _, name in ipairs(Brocklings.ORDER) do
        local old = getCreatureStorage(cid, OLD[name])
        doCreatureSetStorage(cid, Brocklings.FOOD[name], old >= REQUIRED_FOOD and REQUIRED_FOOD or 0)
    end
end

Brocklings.fed = function(cid, name)
    migrate(cid)
    return math.max(0, getCreatureStorage(cid, Brocklings.FOOD[name]))
end

Brocklings.allFed = function(cid)
    for _, name in ipairs(Brocklings.ORDER) do
        if (Brocklings.fed(cid, name) < REQUIRED_FOOD) then
            return false
        end
    end
    return true
end

-- a new feeding round (Salvadore #01 is done): every counter at 0
Brocklings.reset = function(cid)
    for _, name in ipairs(Brocklings.ORDER) do
        doCreatureSetStorage(cid, Brocklings.FOOD[name], 0)
    end
end

-- "Still hungry: Billy (outside, east of the house), Tilly." or "Everyone is fed! ..."
Brocklings.hungryText = function(cid)
    local hungry = {}
    for _, name in ipairs(Brocklings.ORDER) do
        if (Brocklings.fed(cid, name) < REQUIRED_FOOD) then
            local short = name:gsub("^Brockling ", "")
            if (name == "Brockling Billy") then
                short = short .. " " .. __L(cid, "(playing outside, east of the house)")
            end
            hungry[#hungry + 1] = short
        end
    end
    if (#hungry == 0) then
        return __L(cid, "Everyone is fed! Go back to Salvadore.")
    end
    return __L(cid, "Still hungry:") .. " " .. table.concat(hungry, ", ") .. "."
end
