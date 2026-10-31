if (RareSpawns) then
    return
end

-- One-of-a-kind wild Pokemon from the games, each on its own timer:
--   * a Red Gyarados (Shiny Gyarados) at the Lake of Rage, back RESPAWN after it is caught or defeated
--   * a Lapras on Union Cave B2F on Fridays only (server time); back RESPAWN after it is caught or
--     defeated, and it swims off when Friday ends
-- When each is due again is kept in GLOBAL_STORAGES.RARE_SPAWNS, so a restart doesn't bring it back early.
RareSpawns = {}

RareSpawns.CHECK_INTERVAL = 60
RareSpawns.FRIDAY = 6 -- os.date("*t").wday

RareSpawns.LIST = {
    {
        key = "redGyarados",
        name = "Shiny Gyarados",
        area = "Lake of Rage",
        respawn = 6 * 60 * 60,
        z = 7,
        -- around the lake's shore
        spots = { { 2593, 204 }, { 2586, 212 }, { 2548, 223 }, { 2522, 212 }, { 2514, 206 }, { 2506, 163 },
            { 2514, 146 }, { 2592, 149 }, { 2601, 180 } },
    },
    {
        key = "fridayLapras",
        name = "Lapras",
        area = "Union Cave",
        respawn = 3 * 60 * 60,
        wday = RareSpawns.FRIDAY,
        z = 10,
        -- the underground lake on B2F
        spots = { { 2427, 897 }, { 2443, 878 }, { 2449, 880 }, { 2452, 883 }, { 2454, 893 }, { 2450, 903 },
            { 2440, 906 }, { 2432, 905 } },
    },
}

local active = {} -- key -> cid
local lastCheck = 0

local function loadDue()
    local due = {}
    local raw = getGlobalStorageValue(GLOBAL_STORAGES.RARE_SPAWNS)
    if (type(raw) == "string") then
        for key, at in raw:gmatch("(%w+)=(%d+)") do
            due[key] = tonumber(at)
        end
    end
    return due
end

local function saveDue(due)
    local parts = {}
    for key, at in pairs(due) do
        parts[#parts + 1] = key .. "=" .. at
    end
    table.sort(parts)
    setGlobalStorageValue(GLOBAL_STORAGES.RARE_SPAWNS, "m;" .. table.concat(parts, ";"))
end

local function isWild(cid)
    return cid and isCreature(cid) and isPokemonWild(cid)
end

function RareSpawns.find(key)
    for _, entry in ipairs(RareSpawns.LIST) do
        if (entry.key == key) then
            return entry
        end
    end
end

function RareSpawns.get(key)
    local cid = active[key]
    return isWild(cid) and cid or nil
end

-- When it can come back (0: now), or nil while it is out
function RareSpawns.dueAt(key)
    if (RareSpawns.get(key)) then
        return nil
    end
    return loadDue()[key] or 0
end

function RareSpawns.inSeason(entry, time)
    return entry.wday == nil or os.date("*t", time or os.time()).wday == entry.wday
end

function RareSpawns.spawn(entry)
    for _ = 1, 8 do
        local spot = entry.spots[getRandom(1, #entry.spots)]
        local cid = doCreateMonster(entry.name, { x = spot[1], y = spot[2], z = entry.z }, false)
        if (isMonster(cid)) then
            doSendMagicEffect(getCreaturePosition(cid), EFFECT_TELEPORT_DOWN)
            active[entry.key] = cid
            print(string.format("> Rare spawn: %s at %s", entry.name, entry.area))
            return cid
        end
    end
    log(LOG_TYPES.WARNING, "RareSpawns - no free spot for " .. entry.name .. " at " .. entry.area)
end

function RareSpawns.sendAway(entry)
    local cid = RareSpawns.get(entry.key)
    active[entry.key] = nil
    if (cid) then
        doSendMagicEffect(getCreaturePosition(cid), EFFECT_POFF)
        doRemoveCreature(cid)
        return true
    end
    return false
end

-- Clears the timer so it can spawn on the next check (staff and tests)
function RareSpawns.reset(key)
    local due = loadDue()
    due[key] = nil
    saveDue(due)
end

-- Called every second by EventCalendar.onThink; force skips the interval (tests)
function RareSpawns.onThink(force)
    local now = os.time()
    if (not force and now - lastCheck < RareSpawns.CHECK_INTERVAL) then
        return
    end
    lastCheck = now

    local due = loadDue()
    local changed = false
    for _, entry in ipairs(RareSpawns.LIST) do
        local cid = active[entry.key]
        if (cid and not isWild(cid)) then
            -- caught or defeated since the last check
            active[entry.key] = nil
            due[entry.key] = now + entry.respawn
            changed = true
        elseif (cid and not RareSpawns.inSeason(entry, now)) then
            RareSpawns.sendAway(entry)
        elseif (not cid and RareSpawns.inSeason(entry, now) and now >= (due[entry.key] or 0)) then
            RareSpawns.spawn(entry)
        end
    end
    if (changed) then
        saveDue(due)
    end
end
