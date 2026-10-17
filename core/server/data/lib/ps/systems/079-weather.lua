if (Weather) then
    return
end

-- Weather (docs/upcoming-features.md, "Seasons and weather"). Every live region is split into zones,
-- one per town: a spot belongs to the nearest town of its region. Each zone's weather changes every
-- 20 to 60 minutes, rolled from its region's climate and the season (EventCalendar.seasonId).
--
-- Talkactions, creature events and globalevents run in separate Lua states, so the weather is not
-- kept anywhere: Weather.at(zone, time) works it out from a seeded hash of the zone and the time,
-- and every state gets the same answer. Only what staff set with /weather lives in global storage.
--
-- Clients get EXTENDED_IDS.WEATHER JSON {type = "weather", ...} for the zone they stand in, at login
-- and when it changes. The client draws the effects only where the sky is open over the player.
-- Moves of some types hit harder (or softer) in some weather, outdoors (Weather.getMovePowerModifier);
-- hail and sandstorms chip at trainers' Pokemon and fog makes long-range moves miss.

Weather = {}

Weather.CONFIG = {
    enabled = true,
    seed = 7919,
    battle = true, -- the move power changes of KINDS[...].moves
    chip = true, -- hail and sandstorms hurt trainers' Pokemon outdoors (never below 1 health)
    chipPercent = 3, -- of max health
    chipInterval = 10, -- seconds
    fogMiss = true,
    fogMissChance = 10, -- percent, for moves used from 2 or more tiles away
    holidays = true, -- snow on Christmas Day, fog on Halloween night
    sendInterval = 2, -- seconds between checks of where each trainer stands
}

local MINUTE, HOUR = 60, 3600
local SLOT = 20 * MINUTE
local BLOCK = 3 -- slots: every hour is split in one of PATTERNS, so a weather lasts 20 to 60 minutes
local PATTERNS = { { 3 }, { 1, 2 }, { 2, 1 }, { 1, 1, 1 } }
local CACHE_SECONDS = 2

-- moves: power multipliers by move type; chip: the types the chip damage leaves alone; light: the share
-- of the day or night light that gets through (percent) and its tint (0-215: 36 * red + 6 * green + blue, 0-5 each)
Weather.KINDS = {
    clear = { name = "Clear skies", order = 1, light = { 100, -1 } },
    sunny = { name = "Harsh sunlight", order = 2, light = { 110, -1 },
              moves = { [ELEMENT_FIRE] = 1.2, [ELEMENT_GRASS] = 1.1, [ELEMENT_WATER] = 0.8 } },
    rain = { name = "Rain", order = 3, light = { 80, -1 }, moves = { [ELEMENT_WATER] = 1.2, [ELEMENT_FIRE] = 0.8 } },
    thunderstorm = { name = "Thunderstorm", order = 4, light = { 62, 130 },
                     moves = { [ELEMENT_ELECTRIC] = 1.2, [ELEMENT_WATER] = 1.1, [ELEMENT_FIRE] = 0.8 } },
    fog = { name = "Fog", order = 5, light = { 85, -1 }, moves = { [ELEMENT_GHOST] = 1.1, [ELEMENT_DARK] = 1.1 }, fog = true },
    windy = { name = "Strong winds", order = 6, light = { 96, -1 }, moves = { [ELEMENT_FLYING] = 1.2 } },
    snow = { name = "Snow", order = 7, light = { 106, -1 }, moves = { [ELEMENT_ICE] = 1.2, [ELEMENT_FIRE] = 0.9 } },
    hail = { name = "Hail", order = 8, light = { 80, -1 }, moves = { [ELEMENT_ICE] = 1.2 },
             chip = { [ELEMENT_ICE] = true }, effect = EFFECT_ICEBERG },
    sandstorm = { name = "Sandstorm", order = 9, light = { 84, 214 }, moves = { [ELEMENT_ROCK] = 1.2, [ELEMENT_GROUND] = 1.1 },
                  chip = { [ELEMENT_ROCK] = true, [ELEMENT_GROUND] = true, [ELEMENT_STEEL] = true },
                  effect = EFFECT_SAND_EXPLOSION },
}
Weather.KIND_IDS = { "clear", "sunny", "rain", "thunderstorm", "fog", "windy", "snow", "hail", "sandstorm" }

-- Odds of each kind by climate and season (weights, any scale)
Weather.CLIMATES = {
    temperate = {
        spring = { clear = 34, sunny = 16, rain = 22, thunderstorm = 5, fog = 9, windy = 11, snow = 1, hail = 2 },
        summer = { clear = 33, sunny = 30, rain = 13, thunderstorm = 11, fog = 3, windy = 7, hail = 1, sandstorm = 2 },
        autumn = { clear = 33, sunny = 10, rain = 20, thunderstorm = 5, fog = 15, windy = 14, snow = 2, hail = 1 },
        winter = { clear = 32, sunny = 7, rain = 7, thunderstorm = 1, fog = 12, windy = 9, snow = 27, hail = 5 },
    },
    warm = {
        spring = { clear = 32, sunny = 22, rain = 22, thunderstorm = 7, fog = 7, windy = 10 },
        summer = { clear = 28, sunny = 34, rain = 16, thunderstorm = 14, fog = 2, windy = 6 },
        autumn = { clear = 32, sunny = 16, rain = 22, thunderstorm = 8, fog = 10, windy = 12 },
        winter = { clear = 34, sunny = 10, rain = 14, thunderstorm = 2, fog = 14, windy = 12, snow = 10, hail = 4 },
    },
    tropical = {
        spring = { clear = 34, sunny = 30, rain = 20, thunderstorm = 6, fog = 3, windy = 7 },
        summer = { clear = 26, sunny = 38, rain = 18, thunderstorm = 12, fog = 1, windy = 5 },
        autumn = { clear = 26, sunny = 22, rain = 24, thunderstorm = 14, fog = 3, windy = 11 },
        winter = { clear = 36, sunny = 24, rain = 22, thunderstorm = 4, fog = 6, windy = 8 },
    },
    desert = {
        spring = { clear = 25, sunny = 35, sandstorm = 30, windy = 8, rain = 2 },
        summer = { clear = 20, sunny = 45, sandstorm = 30, windy = 5 },
        autumn = { clear = 25, sunny = 30, sandstorm = 35, windy = 8, rain = 2 },
        winter = { clear = 35, sunny = 25, sandstorm = 30, windy = 8, rain = 2 },
    },
}

-- Checked in order (Johto's box overlaps Hoenn's open sea); Kanto is everything else on the surface
Weather.REGIONS = {
    { id = "johto", name = "Johto", live = false, climate = "temperate", from = { x = 1700, y = 20 }, to = { x = 3048, y = 1270 } },
    { id = "orange", name = "Orange Islands", live = true, climate = "tropical", from = { x = 2641, y = 1311 }, to = { x = 4647, y = 3486 } },
    { id = "hoenn", name = "Hoenn", live = true, climate = "warm", from = { x = 48, y = 773 }, to = { x = 2224, y = 2304 } },
    { id = "kanto", name = "Kanto", live = true, climate = "temperate" },
}

-- Towns whose zone differs from its region: climate, or multipliers on the season's odds
Weather.ZONE_RULES = {
    ["Desert Island 92"] = { climate = "desert" },
    ["Mauville"] = { odds = { sandstorm = 6 } },
    ["Pewter"] = { odds = { sandstorm = 3 } },
    ["Lavaridge"] = { odds = { sunny = 2, snow = 0, hail = 0 } },
    ["Cinnabar"] = { odds = { sunny = 1.5, snow = 0.3 } },
    ["Fallarbor"] = { odds = { fog = 1.6 } },
    ["Fortree"] = { odds = { rain = 1.5 } },
    ["Lavender"] = { odds = { fog = 1.8 } },
    ["Tutorial"] = { none = true },
}

---------------------------------------------------------------------------------------------------
-- Zones
---------------------------------------------------------------------------------------------------

local REGION_BY_ID = {}
for _, region in ipairs(Weather.REGIONS) do
    REGION_BY_ID[region.id] = region
end

function Weather.regionAt(pos)
    for _, region in ipairs(Weather.REGIONS) do
        if (not region.from or (pos.x >= region.from.x and pos.x <= region.to.x and pos.y >= region.from.y
                and pos.y <= region.to.y)) then
            return region
        end
    end
end

local zones = nil

local function slug(name)
    return name:lower():gsub("[^%w]", "")
end

-- Every town with a temple is a zone: { id (town id), name, key, region, climate, odds }
function Weather.getZones()
    if (not zones) then
        zones = {}
        for id = 1, 99 do
            local name = getTownName(id)
            local pos = name and getTownTemplePosition(id)
            if (pos and pos.x > 0) then
                local rule = Weather.ZONE_RULES[name] or {}
                local region = Weather.regionAt(pos)
                zones[#zones + 1] = { id = id, name = name, key = slug(name), pos = pos, region = region,
                                      climate = rule.climate or region.climate, odds = rule.odds, none = rule.none }
            end
        end
    end
    return zones
end

function Weather.getZone(id)
    for _, zone in ipairs(Weather.getZones()) do
        if (zone.id == id) then
            return zone
        end
    end
end

-- The zone of a spot: the nearest town of the same region (underground too, the weather above it)
function Weather.zoneAt(pos)
    local region = Weather.regionAt(pos)
    local best, bestDistance = nil, nil
    for _, zone in ipairs(Weather.getZones()) do
        if (zone.region == region) then
            local distance = math.max(math.abs(zone.pos.x - pos.x), math.abs(zone.pos.y - pos.y))
            if (not bestDistance or distance < bestDistance) then
                best, bestDistance = zone, distance
            end
        end
    end
    return best
end

-- Open sky over the spot: on the surface, no floor straight above it, and no roof drawn over it on the
-- floor just above (higher floors drawn over it are a tall building beside it, not a roof)
function Weather.isOutdoors(pos)
    if (pos.z > 7) then
        return false
    end
    for z = pos.z - 1, 0, -1 do
        local spots = { { x = pos.x, y = pos.y } }
        if (z == pos.z - 1) then
            spots[2] = { x = pos.x + 1, y = pos.y + 1 }
        end
        for _, spot in ipairs(spots) do
            local ground = getTileThingByPos({ x = spot.x, y = spot.y, z = z, stackpos = 0 })
            if (ground and ground.itemid and ground.itemid > 0) then
                return false
            end
        end
    end
    return true
end

---------------------------------------------------------------------------------------------------
-- The weather of a zone
---------------------------------------------------------------------------------------------------

local MODULUS = 2147483647

-- 0 to 1, the same for the same numbers in every Lua state
local function hash(...)
    local h = Weather.CONFIG.seed
    for _, n in ipairs({ ... }) do
        h = (h * 48271 + n) % MODULUS
        h = (h * 48271) % MODULUS
    end
    h = (h * 48271) % MODULUS
    return h / MODULUS
end

-- The segment (a run of slots with one weather) a time falls in: its start, its end and its index
local function segmentAt(zoneId, time)
    local slot = math.floor(time / SLOT)
    local block = math.floor(slot / BLOCK)
    local pattern = PATTERNS[math.floor(hash(zoneId, block, 1) * #PATTERNS) + 1]
    local first = block * BLOCK
    for index, length in ipairs(pattern) do
        if (slot < first + length) then
            return first * SLOT, (first + length) * SLOT, block * 10 + index
        end
        first = first + length
    end
end

local function oddsFor(zone, season)
    local base = Weather.CLIMATES[zone.climate][season]
    local odds = {}
    for _, kind in ipairs(Weather.KIND_IDS) do
        odds[kind] = (base[kind] or 0) * ((zone.odds and zone.odds[kind]) or 1)
    end
    return odds
end

local function roll(zone, segment, season)
    local odds, total = oddsFor(zone, season), 0
    for _, kind in ipairs(Weather.KIND_IDS) do
        total = total + odds[kind]
    end
    local pick = hash(zone.id, segment, 2) * total
    for _, kind in ipairs(Weather.KIND_IDS) do
        pick = pick - odds[kind]
        if (pick < 0) then
            return kind
        end
    end
    return "clear"
end

-- Snow on Christmas Day (restart to restart), fog on Halloween night (20:00 to the restart)
function Weather.holidayAt(zone, time)
    if (not Weather.CONFIG.holidays or zone.climate == "desert") then
        return nil
    end
    local d = os.date("*t", time)
    if (zone.climate ~= "tropical" and ((d.month == 12 and d.day == 25 and d.hour >= 6) or (d.month == 12 and d.day == 26 and d.hour < 6))) then
        return "snow", "Christmas"
    elseif ((d.month == 10 and d.day == 31 and d.hour >= 20) or (d.month == 11 and d.day == 1 and d.hour < 6)) then
        return "fog", "Halloween"
    end
end

-- Staff weather: { [zone id] = { kind, endsAt } } (endsAt 0: until staff clear it)
local overrides, overridesAt = {}, -1

function Weather.getOverrides()
    local now = os.time()
    if (now - overridesAt >= CACHE_SECONDS) then
        overridesAt = now
        overrides = {}
        for kind, endsAt, ids in Weather.readOverrides():gmatch("(%a+):(%d+)=([%d,%-]+)") do
            endsAt = tonumber(endsAt)
            if (Weather.KINDS[kind] and (endsAt == 0 or endsAt > now)) then
                for part in ids:gmatch("[^,]+") do
                    local first, last = part:match("^(%d+)%-(%d+)$")
                    first = tonumber(first or part)
                    for id = first, tonumber(last or first) do
                        overrides[id] = { kind = kind, endsAt = endsAt }
                    end
                end
            end
        end
    end
    return overrides
end

-- "m;<kind>:<until>=<zone ids>;...", the ids as runs ("1-12,15"), so "/weather all" fits the
-- 255 characters of global_storage
local function encodeOverrides(list)
    local groups, keys = {}, {}
    for id, entry in pairs(list) do
        local key = entry.kind .. ":" .. entry.endsAt
        if (not groups[key]) then
            groups[key] = {}
            keys[#keys + 1] = key
        end
        table.insert(groups[key], id)
    end
    table.sort(keys)
    local parts = { "m" }
    for _, key in ipairs(keys) do
        local ids, runs = groups[key], {}
        table.sort(ids)
        local i = 1
        while (i <= #ids) do
            local j = i
            while (ids[j + 1] == ids[j] + 1) do
                j = j + 1
            end
            runs[#runs + 1] = (j > i) and (ids[i] .. "-" .. ids[j]) or tostring(ids[i])
            i = j + 1
        end
        parts[#parts + 1] = key .. "=" .. table.concat(runs, ",")
    end
    return table.concat(parts, ";")
end

-- The stored form of every override, to put back later with Weather.writeOverrides
function Weather.readOverrides()
    return tostring(getStorage(GLOBAL_STORAGES.WEATHER_OVERRIDES) or "")
end

function Weather.writeOverrides(value)
    doSetStorage(GLOBAL_STORAGES.WEATHER_OVERRIDES, value)
    overridesAt = -1
    if (#value > 255) then
        print("[Weather] Too many different staff weathers to keep across a restart; they last until then.")
        return
    end
    db.executeQuery(string.format("REPLACE INTO `global_storage` (`key`, `world_id`, `value`) VALUES (%d, %d, %s);",
        GLOBAL_STORAGES.WEATHER_OVERRIDES, getConfigValue("worldId") or 0, db.escapeString(value)))
end

-- Set (kind) or clear (nil) staff weather on zones; minutes nil or 0: until staff clear it
function Weather.setOverride(zoneIds, kind, minutes)
    overridesAt = -1
    local current = Weather.getOverrides()
    local endsAt = (minutes and minutes > 0) and os.time() + math.floor(minutes * MINUTE) or 0
    for _, id in ipairs(zoneIds) do
        current[id] = kind and { kind = kind, endsAt = endsAt } or nil
    end
    Weather.writeOverrides(encodeOverrides(current))
end

-- A zone's weather at a time: { kind, startsAt, endsAt, source = "natural"|"holiday"|"staff", holiday }
function Weather.at(zone, time)
    time = time or os.time()
    if (not Weather.CONFIG.enabled or not zone or zone.none or not zone.region.live) then
        return { kind = "clear", startsAt = time, endsAt = time + HOUR, source = "none" }
    end
    local staff = Weather.getOverrides()[zone.id]
    if (staff) then
        local kind = (staff.kind == "sunny" and Weather.isNight()) and "clear" or staff.kind
        return { kind = kind, startsAt = time, endsAt = staff.endsAt, source = "staff" }
    end
    local holidayKind, holiday = Weather.holidayAt(zone, time)
    if (holidayKind) then
        return { kind = holidayKind, startsAt = time, endsAt = time + HOUR, source = "holiday", holiday = holiday }
    end
    local startsAt, endsAt, segment = segmentAt(zone.id, time)
    local kind = roll(zone, segment, EventCalendar.seasonId(startsAt))
    if (kind == "sunny" and Weather.isNight()) then
        kind = "clear"
    end
    -- the same weather may roll again: report when it really changes (within 3 hours)
    for _ = 1, 9 do
        local _, nextEnds, nextSegment = segmentAt(zone.id, endsAt)
        if (roll(zone, nextSegment, EventCalendar.seasonId(endsAt)) ~= kind or Weather.holidayAt(zone, endsAt)) then
            break
        end
        endsAt = nextEnds
    end
    return { kind = kind, startsAt = startsAt, endsAt = endsAt, source = "natural" }
end

-- The game clock's night (the sun gives no harsh sunlight then)
function Weather.isNight()
    return getWorldLightState() == WORLD_LIGHT_STATE_NIGHT
end

local creatureCache = {}

-- The weather where a creature stands, cached a few seconds: weather, zone, outdoors
function Weather.forCreature(cid)
    local now = os.time()
    local cached = creatureCache[cid]
    if (cached and now - cached.at < CACHE_SECONDS) then
        return cached.weather, cached.zone, cached.outdoors
    end
    local pos = getCreaturePosition(cid)
    if (not pos or not pos.x) then
        return nil
    end
    local zone = Weather.zoneAt(pos)
    local weather = Weather.at(zone, now)
    local outdoors = Weather.isOutdoors(pos)
    creatureCache[cid] = { at = now, weather = weather, zone = zone, outdoors = outdoors }
    return weather, zone, outdoors
end

function Weather.forget(cid)
    creatureCache[cid] = nil
end

-- The weather that acts on a creature: the kind, or nil indoors, underground and in calm zones
function Weather.activeKind(cid)
    local weather, _, outdoors = Weather.forCreature(cid)
    if (weather and outdoors and weather.kind ~= "clear") then
        return weather.kind
    end
end

---------------------------------------------------------------------------------------------------
-- Battle
---------------------------------------------------------------------------------------------------

-- The power multiplier of a move type for an attacker, and the weather kind behind it
function Weather.getMovePowerModifier(cid, moveType)
    if (not Weather.CONFIG.battle or not isCreature(cid)) then
        return 1
    end
    local kind = Weather.activeKind(cid)
    local value = kind and Weather.KINDS[kind].moves and Weather.KINDS[kind].moves[moveType]
    if (value) then
        return value, kind
    end
    return 1
end

-- Fog: moves from 2 or more tiles away may miss
function Weather.fogMiss(cid, target)
    if (not Weather.CONFIG.fogMiss or not isCreature(target)) then
        return false
    end
    local kind = Weather.activeKind(cid)
    if (not kind or not Weather.KINDS[kind].fog) then
        return false
    end
    return getDistanceBetween(getCreaturePosition(cid), getCreaturePosition(target)) >= 2
        and getRandom(1, 100) <= Weather.CONFIG.fogMissChance
end

local function chipImmune(pokemon, kind)
    for _, element in ipairs(getPokemonTypes(pokemon) or {}) do
        if (Weather.KINDS[kind].chip[element]) then
            return true
        end
    end
    return false
end

-- Hail and sandstorms: trainers' Pokemon outdoors lose a little health, never the last point
function Weather.chip(pokemon)
    local kind = Weather.activeKind(pokemon)
    if (not kind or not Weather.KINDS[kind].chip or chipImmune(pokemon, kind)) then
        return 0
    end
    local health = getCreatureHealth(pokemon)
    local amount = math.min(health - 1, math.max(1, math.floor(getCreatureMaxHealth(pokemon) * Weather.CONFIG.chipPercent / 100)))
    if (amount > 0) then
        doCreatureTrueDamage(pokemon, -amount, Weather.KINDS[kind].effect, COLOR_WHITE)
    end
    return amount
end

---------------------------------------------------------------------------------------------------
-- Clients
---------------------------------------------------------------------------------------------------

function Weather.data(cid)
    local weather, zone, outdoors = Weather.forCreature(cid)
    if (not weather or weather.source == "none") then
        return { type = "weather", kind = "clear", season = EventCalendar.seasonId() }
    end
    local kind = Weather.KINDS[weather.kind]
    local moves = {}
    for element, value in pairs(kind.moves or {}) do
        moves[#moves + 1] = { element = element, value = value }
    end
    table.sort(moves, function(a, b) return a.value > b.value end)
    local name = (weather.kind == "clear" and Weather.isNight()) and "Clear night" or kind.name
    return { type = "weather", zone = zone.name, region = zone.region.name, kind = weather.kind, name = name,
             startsAt = weather.startsAt, endsAt = weather.endsAt, source = weather.source, holiday = weather.holiday,
             outdoors = outdoors, season = EventCalendar.seasonId(), moves = moves, night = Weather.isNight(),
             chip = kind.chip and Weather.CONFIG.chip or false, fog = kind.fog and Weather.CONFIG.fogMiss or false,
             now = os.time() }
end

local function sendData(cid, data)
    if (getPlayerUsingOtClient(cid)) then
        doSendPlayerExtendedOpcode(cid, EXTENDED_IDS.WEATHER, JSON.encode(data))
    end
end

function Weather.send(cid)
    Weather.forget(cid)
    sendData(cid, Weather.data(cid))
    Weather.applyLight(cid, (Weather.forCreature(cid)))
end

-- Clouds dim the day and the night, sun warms them, snow brightens them
function Weather.applyLight(cid, weather)
    if (not doPlayerSetWeatherLight) then
        return
    end
    local light = weather and weather.source ~= "none" and Weather.KINDS[weather.kind].light or { 100, -1 }
    doPlayerSetWeatherLight(cid, light[1], light[2])
end

function Weather.onClientMessage(cid, buffer)
    local ok, data = pcall(JSON.decode, buffer)
    if (ok and type(data) == "table" and data.action == "status") then
        Weather.send(cid)
    end
end

---------------------------------------------------------------------------------------------------
-- Executor (serverExpEvent globalevent, every second)
---------------------------------------------------------------------------------------------------

local lastSent = {}
local lastSend, lastChip = 0, 0

function Weather.onThink()
    local now = os.time()
    if (now - lastSend >= Weather.CONFIG.sendInterval) then
        lastSend = now
        local online = {}
        for _, cid in ipairs(getPlayersOnline()) do
            online[cid] = true
            local weather, zone = Weather.forCreature(cid)
            local key = weather and string.format("%s:%s:%d:%s", zone and zone.id or 0, weather.kind, weather.endsAt,
                tostring(Weather.isNight())) or ""
            if (lastSent[cid] ~= key) then
                lastSent[cid] = key
                sendData(cid, Weather.data(cid))
                Weather.applyLight(cid, weather)
            end
        end
        for cid in pairs(lastSent) do
            if (not online[cid]) then
                lastSent[cid] = nil
            end
        end
        for cid, cached in pairs(creatureCache) do
            if (now - cached.at > 60) then
                creatureCache[cid] = nil
            end
        end
    end

    if (Weather.CONFIG.chip and now - lastChip >= Weather.CONFIG.chipInterval) then
        lastChip = now
        for _, cid in ipairs(getPlayersOnline()) do
            local pokemon = getPlayerPokemon(cid)
            if (isCreature(pokemon)) then
                Weather.chip(pokemon)
            end
        end
    end
end

-- /weather: zones by "here", a town ("viridian", "desertisland92"), a region id or "all"
function Weather.findZones(cid, text)
    text = slug(text or "")
    local list = {}
    if (text == "here") then
        local zone = Weather.zoneAt(getCreaturePosition(cid))
        return zone and { zone } or {}
    end
    for _, zone in ipairs(Weather.getZones()) do
        if (not zone.none and zone.region.live and (text == "all" or zone.key == text or zone.region.id == text)) then
            list[#list + 1] = zone
        end
    end
    return list
end

Weather.getRegion = function(id)
    return REGION_BY_ID[id]
end
