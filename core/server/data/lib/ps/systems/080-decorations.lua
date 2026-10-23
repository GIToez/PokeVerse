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
-- Nothing on the map is saved: a restart starts from a clean map and puts the current set down again.
--
-- Staff also place props by hand (/deco, the Admin window's Decorations tab): each is a row in
-- decoration_spots (set, tile, item) and goes up with its set like the automatic ones. Wall props
-- (wreaths, garlands, tapestries) hang on walls with a hook. A town can be left to hand-placed
-- props only (/deco auto off), and a set can be previewed for a while (/deco preview).

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

local KEY_VERSION = GLOBAL_STORAGES.DECORATIONS_VERSION
local KEY_PREVIEW = GLOBAL_STORAGES.DECORATIONS_PREVIEW
local KEY_NO_AUTO = GLOBAL_STORAGES.DECORATIONS_NO_AUTO

Decorations.PREVIEW_MINUTES = 30
Decorations.PREVIEW_MAX_MINUTES = 24 * 60

local function persist(key, value)
    doSetStorage(key, value)
    db.executeQuery(string.format("REPLACE INTO `global_storage` (`key`, `world_id`, `value`) VALUES (%d, %d, %s);",
        key, getConfigValue("worldId") or 0, db.escapeString(value)))
end

local function version()
    return tonumber(getStorage(KEY_VERSION)) or 0
end

-- The globalevent puts the decorations up again within a second (staff change them from other scripts)
function Decorations.changed()
    doSetStorage(KEY_VERSION, version() + 1)
end

-- The set staff preview and when the preview ends, or nil
function Decorations.getPreview()
    local setId, endsAt = tostring(getStorage(KEY_PREVIEW) or ""):match("^m;(%w+):(%d+)$")
    endsAt = tonumber(endsAt)
    if (setId and Decorations.SETS[setId] and endsAt > os.time()) then
        return setId, endsAt
    end
    return nil
end

-- Preview a set (nil: stop previewing)
function Decorations.setPreview(setId, minutes)
    persist(KEY_PREVIEW, setId and string.format("m;%s:%d", setId, os.time() + minutes * 60) or "m;")
    Decorations.changed()
end

-- Towns that only get hand-placed props: { [zone id] = true }
function Decorations.getNoAuto()
    local list = {}
    for id in (tostring(getStorage(KEY_NO_AUTO) or ""):match("^m;([%d,]*)$") or ""):gmatch("%d+") do
        list[tonumber(id)] = true
    end
    return list
end

function Decorations.setAuto(zoneId, on)
    local list, ids = Decorations.getNoAuto(), {}
    list[zoneId] = not on or nil
    for id in pairs(list) do
        ids[#ids + 1] = id
    end
    table.sort(ids)
    persist(KEY_NO_AUTO, "m;" .. table.concat(ids, ","))
    Decorations.changed()
end

-- The set that should be up now: its id, or nil
function Decorations.theme()
    if (not Decorations.CONFIG.enabled) then
        return nil
    end
    local preview = Decorations.getPreview()
    if (preview) then
        return preview
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

local function checkWalkable(pos, ignoreId)
    local info = tileInfo(pos)
    if (not info or not info.things or info.things < 1 or info.house or info.depot) then
        return false
    end
    for stackpos = 0, info.things - 1 do
        local thing = getTileThingByPos({ x = pos.x, y = pos.y, z = pos.z, stackpos = stackpos })
        if (thing and thing.itemid and thing.itemid > 0 and thing.itemid ~= ignoreId and not isCreature(thing.uid)) then
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
-- Hand-placed props (decoration_spots)
---------------------------------------------------------------------------------------------------

-- Props that hang on a wall with a hook (on a clear tile they stand on the floor); any set can use them
Decorations.WALL_ITEMS = { 6502, 6503, 6504, 6505, 5616, 1857, 1869, 1872, 1880 }
Decorations.NEARBY = 12 -- tiles: what /deco list and the Admin window show
Decorations.MAX_SPOTS = 400 -- per set: they all go down in one script call

-- Every set id: the holidays in calendar order, then the seasons
function Decorations.setIds()
    local ids = {}
    for _, entry in ipairs(Decorations.HOLIDAYS) do
        ids[#ids + 1] = entry[2]
    end
    for _, id in ipairs({ "spring", "autumn", "winter" }) do
        ids[#ids + 1] = id
    end
    return ids
end

local function slug(text)
    return (tostring(text or ""):lower():gsub("[^%w]", ""))
end

-- A set id from its id or its name ("valentines", "Pokemon Day"), or nil
function Decorations.findSet(text)
    text = slug(text)
    for _, id in ipairs(Decorations.setIds()) do
        if (text == id or text == slug(Decorations.SETS[id].name)) then
            return id
        end
    end
    return nil
end

function Decorations.itemName(itemid)
    local info = getItemInfo(itemid)
    return info and info.name ~= "" and info.name or ("item " .. itemid)
end

-- The props offered for a set: its own, then the wall props ({ id, name, wall })
function Decorations.catalog(setId)
    local set, seen, list = Decorations.SETS[setId], {}, {}
    local function add(itemid, wall)
        if (itemid and not seen[itemid]) then
            seen[itemid] = true
            list[#list + 1] = { id = itemid, name = Decorations.itemName(itemid), wall = wall }
        end
    end
    add(set and set.first, false)
    for _, itemid in ipairs(set and set.items or {}) do
        add(itemid, false)
    end
    for _, itemid in ipairs(set and set.noSnow or {}) do
        add(itemid, false)
    end
    for _, itemid in ipairs(Decorations.WALL_ITEMS) do
        add(itemid, true)
    end
    return list
end

-- An item id from a number or a prop name of the set's catalog; nil and why when it's not one
function Decorations.findItem(setId, text)
    local number = tonumber(text)
    if (number) then
        return getItemInfo(number) and number or nil, "There is no item " .. number .. "."
    end
    text = tostring(text or ""):lower():gsub("^%s+", ""):gsub("%s+$", "")
    local matches, names = {}, {}
    for _, item in ipairs(Decorations.catalog(setId)) do
        if (item.name == text) then
            return item.id
        elseif (text ~= "" and item.name:find(text, 1, true) and not names[item.name]) then
            matches[#matches + 1], names[item.name] = item, true
        end
    end
    if (#matches == 1) then
        return matches[1].id
    elseif (#matches > 1) then
        local list = {}
        for _, item in ipairs(matches) do
            list[#list + 1] = item.name
        end
        return nil, "Which one: " .. table.concat(list, ", ") .. "?"
    end
    return nil, "No prop called \"" .. text .. "\". /deco items " .. setId .. " lists them, or give an item id."
end

-- A wall a prop can hang on. With `from`, only a hook on the side seen from there: a prop hangs on
-- a horizontal wall's south face and a vertical wall's east face.
function Decorations.hasHook(pos, from)
    local info = getTileInfo(pos)
    for stackpos = 0, (info and info.things or 1) - 1 do
        local thing = getTileThingByPos({ x = pos.x, y = pos.y, z = pos.z, stackpos = stackpos })
        local item = thing and thing.itemid and thing.itemid > 0 and getItemInfo(thing.itemid)
        if (item and (item.horizontal or item.vertical) and (not from or
                (item.horizontal and from.y == pos.y + 1) or (item.vertical and from.x == pos.x + 1))) then
            return true
        end
    end
    return false
end

-- A prop fits here: a wall prop on a wall with a hook, anything else (and a wall prop off a wall)
-- on a tile a creature could stand on. The prop itself standing there doesn't count. `from` is
-- where whoever places it stands.
function Decorations.checkSpot(pos, itemid, from)
    local item = getItemInfo(itemid)
    if (not item) then
        return false, "There is no item " .. tostring(itemid) .. "."
    end
    local tile = tileInfo(pos)
    if (not tile) then
        return false, "There is no floor there."
    elseif (tile.house or tile.depot) then
        return false, "That tile belongs to a house or a depot."
    elseif (item.hangable and Decorations.hasHook(pos, from)) then
        return true
    elseif (item.hangable and from and Decorations.hasHook(pos)) then
        return false, "Its hook is on the other side: wall props hang on the south or east face of a wall."
    elseif (not checkWalkable(pos, itemid)) then
        return false, item.hangable and "Face a wall with a hook or a clear tile." or
            "That tile is blocked: a wall, water, stairs or something solid."
    end
    return true
end

local function samePos(a, b)
    return a.x == b.x and a.y == b.y and a.z == b.z
end

local spotsCache, spotsCacheVersion = nil, nil

-- Every hand-placed prop: { id, set, pos, itemid, by, at }
function Decorations.getSpots()
    local stamp = version()
    if (spotsCache and spotsCacheVersion == stamp) then
        return spotsCache
    end
    local list = {}
    local result = db.getResult("SELECT `id`, `set_id`, `x`, `y`, `z`, `itemid`, `added_by`, `added_at` FROM `decoration_spots`" ..
        " WHERE `world_id` = " .. (getConfigValue("worldId") or 0) .. " ORDER BY `id`;")
    if (result:getID() ~= -1) then
        repeat
            list[#list + 1] = { id = result:getDataInt("id"), set = result:getDataString("set_id"),
                                pos = { x = result:getDataInt("x"), y = result:getDataInt("y"), z = result:getDataInt("z") },
                                itemid = result:getDataInt("itemid"), by = result:getDataString("added_by"),
                                at = result:getDataInt("added_at") }
        until not result:next()
        result:free()
    end
    spotsCache, spotsCacheVersion = list, stamp
    return list
end

-- Save a prop for a set on a tile (it replaces the set's prop there); true and whether it replaced
-- one, or false and why. `from` is where the author stands.
function Decorations.addSpot(setId, pos, itemid, author, from)
    if (not Decorations.SETS[setId]) then
        return false, "There is no decoration set " .. tostring(setId) .. "."
    end
    local ok, why = Decorations.checkSpot(pos, itemid, from)
    if (not ok) then
        return false, why
    end
    local count, replaced = 0, false
    for _, spot in ipairs(Decorations.getSpots()) do
        if (spot.set == setId) then
            count = count + 1
            replaced = replaced or samePos(spot.pos, pos)
        end
    end
    if (not replaced and count >= Decorations.MAX_SPOTS) then
        return false, string.format("%s already has %d props; remove some first.", Decorations.SETS[setId].name, count)
    end
    db.executeQuery(string.format("INSERT INTO `decoration_spots` (`world_id`, `set_id`, `x`, `y`, `z`, `itemid`, `added_by`, " ..
        "`added_at`) VALUES (%d, %s, %d, %d, %d, %d, %s, %d) ON DUPLICATE KEY UPDATE `itemid` = VALUES(`itemid`), " ..
        "`added_by` = VALUES(`added_by`), `added_at` = VALUES(`added_at`);", getConfigValue("worldId") or 0,
        db.escapeString(setId), pos.x, pos.y, pos.z, itemid, db.escapeString(author or ""), os.time()))
    Decorations.changed()
    return true, replaced
end

-- Delete the props saved on a tile (setId nil: every set's); the spots deleted
function Decorations.removeSpots(pos, setId)
    local removed = {}
    for _, spot in ipairs(Decorations.getSpots()) do
        if (samePos(spot.pos, pos) and (not setId or spot.set == setId)) then
            removed[#removed + 1] = spot
            db.executeQuery(string.format("DELETE FROM `decoration_spots` WHERE `id` = %d;", spot.id))
        end
    end
    if (#removed > 0) then
        Decorations.changed()
    end
    return removed
end

-- The props saved within `radius` of a position, nearest first, each with whether it still fits
function Decorations.spotsNear(pos, radius)
    local list = {}
    for _, spot in ipairs(Decorations.getSpots()) do
        local distance = math.max(math.abs(spot.pos.x - pos.x), math.abs(spot.pos.y - pos.y))
        if (spot.pos.z == pos.z and distance <= radius) then
            local ok, why = Decorations.checkSpot(spot.pos, spot.itemid)
            list[#list + 1] = { spot = spot, distance = distance, valid = ok, why = not ok and why or nil }
        end
    end
    table.sort(list, function(a, b)
        return a.distance < b.distance or (a.distance == b.distance and a.spot.id < b.spot.id)
    end)
    return list
end

---------------------------------------------------------------------------------------------------
-- Putting them down and taking them away
---------------------------------------------------------------------------------------------------

local placed = {} -- the automatic props { pos, itemid }
local handPlaced = {} -- the hand-placed ones
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

local function removeAll(list)
    for _, entry in ipairs(list) do
        local item = getTileItemById(entry.pos, entry.itemid)
        if (item and item.uid and item.uid > 0) then
            doRemoveItem(item.uid)
        end
    end
end

function Decorations.clear()
    removeAll(placed)
    removeAll(handPlaced)
    placed, handPlaced = {}, {}
    current = nil
end

-- Put a set's props down in one town; how many went down
function Decorations.placeZone(theme, zone)
    local set = theme and Decorations.SETS[theme]
    local items, first = nil, nil
    if (set and not zone.none and Weather.isRegionOn(zone.region) and not Decorations.getNoAuto()[zone.id]) then
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

-- Put a set's hand-placed props down (again); how many went down. An automatic prop on the same
-- tile makes way.
function Decorations.placeHand(theme)
    removeAll(handPlaced)
    handPlaced = {}
    local count = 0
    for _, spot in ipairs(theme and Decorations.getSpots() or {}) do
        if (spot.set == theme) then
            for index = #placed, 1, -1 do
                if (samePos(placed[index].pos, spot.pos)) then
                    removeAll({ placed[index] })
                    table.remove(placed, index)
                end
            end
            if (Decorations.checkSpot(spot.pos, spot.itemid)) then
                local uid = doCreateItem(spot.itemid, 1, spot.pos)
                if (uid and uid > 0) then
                    doItemSetAttribute(uid, "scriptprotected", true)
                    handPlaced[#handPlaced + 1] = { pos = spot.pos, itemid = spot.itemid }
                    count = count + 1
                end
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

-- Put a set's props down: the hand-placed ones, then every live town's automatic ones (nil: take
-- them all away). Each town goes down in its own event: a script call registers every thing it
-- reads and looks each new one up in that list, so searching every town in one call takes minutes
-- and blocks the server.
function Decorations.place(theme)
    Decorations.clear()
    generation = generation + 1
    current = theme
    if (theme and Decorations.SETS[theme]) then
        Decorations.placeHand(theme)
        addEvent(placeNext, 0, theme, 1, generation)
    end
end

function Decorations.getPlaced()
    return placed
end

function Decorations.getHandPlaced()
    return handPlaced
end

function Decorations.getCurrent()
    return current
end

---------------------------------------------------------------------------------------------------
-- Executor (serverExpEvent globalevent, every second)
---------------------------------------------------------------------------------------------------

local lastCheck, started, seenVersion, seenNoAuto = 0, false, nil, nil

function Decorations.onThink()
    local now, changes = os.time(), version()
    if (started and changes == seenVersion and now - lastCheck < Decorations.CONFIG.checkInterval) then
        return
    end
    lastCheck = now
    local noAuto = tostring(getStorage(KEY_NO_AUTO) or "") .. "|" .. tostring(getStorage(GLOBAL_STORAGES.WEATHER_REGIONS_OFF) or "")
    local theme = Decorations.theme()
    if (not started or theme ~= current or noAuto ~= seenNoAuto) then
        Decorations.place(theme)
    elseif (changes ~= seenVersion) then
        Decorations.placeHand(theme)
    end
    started, seenVersion, seenNoAuto = true, changes, noAuto
end
