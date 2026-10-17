if (Decorations) then
    return
end

-- Seasonal and holiday decorations (docs/upcoming-features.md, "Seasons and weather"): a few props
-- around each live town's temple, put down at startup and swapped when the season or a decorated
-- holiday starts or ends. The map itself never changes.
--
-- Spots are picked by script: open sky, a clear walkable tile with nothing on it, and every tile
-- within 2 of it walkable, so a prop never closes a path or stands at a door; props stand at least
-- 3 tiles apart.
-- They are script protected: players can't move or pick them up, and the map clean leaves them.
-- Nothing is saved: a restart starts from a clean map and puts the current set down again.

Decorations = {}

Decorations.CONFIG = {
    enabled = true,
    perTown = 6,
    minDistance = 2, -- from the temple spot
    maxDistance = 16,
    clearance = 2, -- tiles around a spot that must be walkable (2: nothing next to a door, a wall or a bench)
    spacing = 3,
    checkInterval = 60, -- seconds between looks at the season and the holidays
    zoneDelay = 100, -- ms between towns while a set goes down
}

-- climates: the climates a set is for (nil: all); first: a centrepiece on the spot nearest the temple
Decorations.SETS = {
    christmas = { name = "Christmas", first = 2105, items = { 6502, 7171, 7173, 486 },
                  noSnow = { 2105, 6502 } }, -- for tropical and desert towns
    halloween = { name = "Halloween", items = { 2097, 2096, 5812, 2097 } },
    newyear = { name = "New Year", first = 6280, items = { 6280, 12256, 2746, 2112 } },
    lunarnewyear = { name = "Lunar New Year", items = { 11200, 1435, 11200, 2744 } },
    valentines = { name = "Valentine's", items = { 1685, 2744, 2112, 2762 } },
    pokemonday = { name = "Pokemon Day", first = 12256, items = { 12271, 12270, 12263, 12272, 12258 } },
    easter = { name = "Easter", items = { 12154, 2749, 2750, 12154, 2751 } },
    summerfestival = { name = "Summer Festival", items = { 2753, 5417, 12258, 12257 } },
    harvestmoon = { name = "Harvest Moon", items = { 2096, 2739, 3848, 2740 } },
    clefairy = { name = "Clefairy Night", items = { 12268, 12270, 2740, 4152 } },
    anniversary = { name = "Anniversary", first = 6280, items = { 12254, 12256, 2744, 12271 } },
    winter = { name = "Winter", items = { 7171, 7173, 2697, 486 }, climates = { temperate = true, warm = true } },
    spring = { name = "Spring", items = { 2749, 2750, 2751, 2753, 6226, 6230 } },
    autumn = { name = "Autumn", items = { 2096, 2739, 3848, 4183, 2737 } },
}

-- Every calendar holiday and its set, first match wins when two overlap; a holiday's set comes
-- before the season's
Decorations.HOLIDAYS = {
    { "christmas", "christmas" },
    { "halloween", "halloween" },
    { "newyear", "newyear" },
    { "lunarnewyear", "lunarnewyear" },
    { "valentines", "valentines" },
    { "pokemonday", "pokemonday" },
    { "easter", "easter" },
    { "anniversary", "anniversary" },
    { "summer", "summerfestival" }, -- the holiday id "summer" is also a season id
    { "harvestmoon", "harvestmoon" },
    { "clefairy", "clefairy" },
}

-- The set of the first active holiday, or nil
function Decorations.holidayTheme()
    for _, entry in ipairs(Decorations.HOLIDAYS) do
        if (EventCalendar.isActive(entry[1])) then
            return entry[2]
        end
    end
    return nil
end

-- The set that should be up now: its id, or nil
function Decorations.theme()
    if (not Decorations.CONFIG.enabled) then
        return nil
    end
    local holiday = Decorations.holidayTheme()
    if (holiday) then
        return holiday
    end
    local season = EventCalendar.seasonId()
    return Decorations.SETS[season] and season or nil
end

---------------------------------------------------------------------------------------------------
-- Spots
---------------------------------------------------------------------------------------------------

local floorChanges = {}

local function changesFloor(itemid)
    if (floorChanges[itemid] == nil) then
        local info = getItemInfo(itemid)
        local changes = false
        for _, value in pairs(info and info.floorChange or {}) do
            changes = changes or value
        end
        floorChanges[itemid] = changes
    end
    return floorChanges[itemid]
end

local function tileInfo(pos)
    local ground = getTileThingByPos({ x = pos.x, y = pos.y, z = pos.z, stackpos = 0 })
    if (not ground or not ground.itemid or ground.itemid == 0) then
        return nil
    end
    return getTileInfo(pos), ground
end

-- A creature could stand here: a ground, nothing solid on it and no stairs (cached while searching)
local walkableCache = nil

local function checkWalkable(pos)
    local info = tileInfo(pos)
    if (not info or not info.things or info.things < 1 or info.house or info.depot) then
        return false
    end
    for stackpos = 0, info.things - 1 do
        local thing = getTileThingByPos({ x = pos.x, y = pos.y, z = pos.z, stackpos = stackpos })
        if (thing and thing.itemid and thing.itemid > 0 and not isCreature(thing.uid)) then
            if (hasItemProperty(thing.uid, CONST_PROP_BLOCKSOLID) or changesFloor(thing.itemid)) then
                return false
            end
        end
    end
    return true
end

local function walkable(pos)
    if (not walkableCache) then
        return checkWalkable(pos)
    end
    local key = pos.x * 65536 + pos.y
    local value = walkableCache[key]
    if (value == nil) then
        value = checkWalkable(pos)
        walkableCache[key] = value
    end
    return value
end

function Decorations.isSpot(pos)
    local info, ground = tileInfo(pos)
    if (not info or info.downItems ~= 0 or info.creatures ~= 0 or (ground.actionid or 0) ~= 0) then
        return false
    end
    if (not walkable(pos) or not Weather.isOutdoors(pos)) then
        return false
    end
    local clearance = Decorations.CONFIG.clearance
    for dx = -clearance, clearance do
        for dy = -clearance, clearance do
            if ((dx ~= 0 or dy ~= 0) and not walkable({ x = pos.x + dx, y = pos.y + dy, z = pos.z })) then
                return false
            end
        end
    end
    return true
end

local spotsByZone = {}

-- Up to CONFIG.perTown spots around a town's temple, nearest first (the same every time)
function Decorations.spotsFor(zone)
    if (spotsByZone[zone.id]) then
        return spotsByZone[zone.id]
    end
    local config, center = Decorations.CONFIG, zone.pos
    local candidates = {}
    for dx = -config.maxDistance, config.maxDistance do
        for dy = -config.maxDistance, config.maxDistance do
            local distance = math.max(math.abs(dx), math.abs(dy))
            if (distance >= config.minDistance) then
                candidates[#candidates + 1] = { x = center.x + dx, y = center.y + dy, z = center.z,
                                                order = distance * 1000 + ((dx * 7919 + dy * 104729) % 997) }
            end
        end
    end
    table.sort(candidates, function(a, b) return a.order < b.order end)
    walkableCache = {}
    local spots = {}
    for _, pos in ipairs(candidates) do
        if (#spots >= config.perTown) then
            break
        end
        local apart = true
        for _, spot in ipairs(spots) do
            if (math.max(math.abs(spot.x - pos.x), math.abs(spot.y - pos.y)) < config.spacing) then
                apart = false
                break
            end
        end
        if (apart and Decorations.isSpot(pos)) then
            spots[#spots + 1] = { x = pos.x, y = pos.y, z = pos.z }
        end
    end
    walkableCache = nil
    spotsByZone[zone.id] = spots
    return spots
end

---------------------------------------------------------------------------------------------------
-- Putting them down and taking them away
---------------------------------------------------------------------------------------------------

local placed = {} -- { pos, itemid }
local current = nil

local function itemsFor(set, zone)
    if (set.climates and not set.climates[zone.climate]) then
        return nil
    end
    if (set.noSnow and (zone.climate == "tropical" or zone.climate == "desert")) then
        return set.noSnow, set.first
    end
    return set.items, set.first
end

function Decorations.clear()
    for _, entry in ipairs(placed) do
        local item = getTileItemById(entry.pos, entry.itemid)
        if (item and item.uid and item.uid > 0) then
            doRemoveItem(item.uid)
        end
    end
    placed = {}
    current = nil
end

-- Put a set's props down in one town; how many went down
function Decorations.placeZone(theme, zone)
    local set = theme and Decorations.SETS[theme]
    local items, first = nil, nil
    if (set and not zone.none and zone.region.live) then
        items, first = itemsFor(set, zone)
    end
    local count = 0
    for index, pos in ipairs(items and Decorations.spotsFor(zone) or {}) do
        local itemid = (index == 1 and first) or items[(index + zone.id) % #items + 1]
        local info = tileInfo(pos)
        if (info and info.creatures == 0 and info.downItems == 0) then
            local uid = doCreateItem(itemid, 1, pos)
            if (uid and uid > 0) then
                doItemSetAttribute(uid, "scriptprotected", true)
                placed[#placed + 1] = { pos = pos, itemid = itemid }
                count = count + 1
            end
        end
    end
    return count
end

local generation = 0

local function placeNext(theme, index, gen)
    local zones = Weather.getZones()
    if (gen ~= generation or not zones[index]) then
        return
    end
    Decorations.placeZone(theme, zones[index])
    addEvent(placeNext, Decorations.CONFIG.zoneDelay, theme, index + 1, gen)
end

-- Put a set's props down in every live town (nil: take them all away). Each town goes down in its
-- own event: a script call registers every thing it reads and looks each new one up in that list,
-- so searching every town in one call takes minutes and blocks the server.
function Decorations.place(theme)
    Decorations.clear()
    generation = generation + 1
    current = theme
    if (theme and Decorations.SETS[theme]) then
        addEvent(placeNext, 0, theme, 1, generation)
    end
end

function Decorations.getPlaced()
    return placed
end

function Decorations.getCurrent()
    return current
end

---------------------------------------------------------------------------------------------------
-- Executor (serverExpEvent globalevent, every second)
---------------------------------------------------------------------------------------------------

local lastCheck, started = 0, false

function Decorations.onThink()
    local now = os.time()
    if (started and now - lastCheck < Decorations.CONFIG.checkInterval) then
        return
    end
    lastCheck = now
    local theme = Decorations.theme()
    if (not started or theme ~= current) then
        started = true
        Decorations.place(theme)
    end
end
