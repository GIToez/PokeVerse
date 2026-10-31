if (BeachPikachu) then
    return
end

-- Surfing Pikachu (config/pokemon/pikachu.lua) on the beaches, only in summer (EventCalendar season) and
-- only while the beach's zone has harsh sunlight (079-weather.lua):
--   * a rare one: every CHECK_INTERVAL each sunny beach without one has SPAWN_CHANCE to get one, and it
--     leaves when the sun goes (if nobody caught it)
--   * a swarm: SWARM_SIZE of them on one sunny beach for SWARM_DURATION, by staff (/beachswarm, or the
--     "Beach Swarm" raid) or on its own, SWARM_CHANCE per check and at most one every SWARM_GAP
BeachPikachu = {}

BeachPikachu.CHECK_INTERVAL = 10 * 60
BeachPikachu.SPAWN_CHANCE = 4000 -- of RANDOM_CHANCE_MAX: 4%, about one per four hours of sun on a beach
BeachPikachu.RAICHU_CHANCE = 10000 -- 10%: a rare one is a Surfing Raichu instead
BeachPikachu.SWARM_CHANCE = 1000
BeachPikachu.SWARM_GAP = 12 * 60 * 60
BeachPikachu.SWARM_SIZE = 10
BeachPikachu.SWARM_RAICHUS = 1
BeachPikachu.SWARM_DURATION = 30 * 60

-- Spots on the sand (the shore spawns of Krabby, Wingull, Corphish, Shellder and Staryu)
BeachPikachu.BEACHES = {
    { name = "Slateport Beach", spots = { { 630, 1864 }, { 636, 1852 }, { 637, 1859 }, { 641, 1838 }, { 643, 1867 }, { 645, 1843 }, { 645, 1858 }, { 652, 1842 } } },
    { name = "Route 115 Beach", spots = { { 239, 1449 }, { 245, 1431 }, { 249, 1446 }, { 253, 1419 }, { 255, 1437 }, { 264, 1427 }, { 274, 1422 } } },
    { name = "Lilycove Shore", spots = { { 1415, 1347 }, { 1425, 1339 }, { 1427, 1347 }, { 1435, 1338 }, { 1435, 1352 }, { 1448, 1333 }, { 1456, 1349 } } },
    { name = "Tarroco Beach", spots = { { 3183, 1485 }, { 3188, 1475 }, { 3192, 1484 }, { 3201, 1469 }, { 3224, 1459 }, { 3233, 1451 }, { 3274, 1472 } } },
    { name = "Tangelo Beach", spots = { { 2670, 2750 }, { 2681, 2787 }, { 2683, 2731 }, { 2720, 2699 }, { 2769, 2795 }, { 2779, 2813 }, { 2787, 2804 } } },
    { name = "Great Beach", spots = { { 3779, 2625 }, { 3781, 2648 }, { 3799, 2660 }, { 3807, 2669 }, { 3818, 2660 }, { 3836, 2673 }, { 3849, 2677 }, { 3865, 2651 } } },
    { name = "Fuchsia Shore", spots = { { 3852, 914 }, { 3854, 899 }, { 3859, 922 } } },
}

local rare = {} -- beach index -> cid
local swarm = nil -- { beach, cids, endsAt }
local lastCheck = 0
local lastSwarm = 0

local function spotPosition(beach, spot)
    return { x = spot[1] + getRandom(-2, 2), y = spot[2] + getRandom(-2, 2), z = 7 }
end

local function spawnAt(beach, name)
    for _ = 1, 6 do
        local cid = doCreateMonster(name, spotPosition(beach, beach.spots[getRandom(1, #beach.spots)]), false)
        if (isCreature(cid)) then
            doSendMagicEffect(getCreaturePosition(cid), EFFECT_TELEPORT_DOWN)
            return cid
        end
    end
end

local function sendAway(cid)
    if (cid and isCreature(cid) and isPokemonWild(cid)) then
        doSendMagicEffect(getCreaturePosition(cid), EFFECT_POFF)
        doRemoveCreature(cid)
    end
end

function BeachPikachu.isSummer()
    return EventCalendar.seasonId() == "summer"
end

function BeachPikachu.isSunny(beach)
    local first = beach.spots[1]
    local zone = Weather.zoneAt({ x = first[1], y = first[2], z = 7 })
    return zone ~= nil and Weather.at(zone).kind == "sunny"
end

function BeachPikachu.findBeach(name)
    name = name and name:lower()
    for index, beach in ipairs(BeachPikachu.BEACHES) do
        if (beach.name:lower() == name or beach.name:lower():find(name, 1, true)) then
            return beach, index
        end
    end
end

function BeachPikachu.sunnyBeaches()
    local list = {}
    for index, beach in ipairs(BeachPikachu.BEACHES) do
        if (BeachPikachu.isSunny(beach)) then
            list[#list + 1] = index
        end
    end
    return list
end

function BeachPikachu.getRare()
    return rare
end

function BeachPikachu.getSwarm()
    return swarm
end

-- beach: a BEACHES entry, or nil for a sunny one (staff get a random one when none is)
function BeachPikachu.startSwarm(beach, byStaff)
    if (swarm) then
        return false, string.format("A swarm is already on %s.", swarm.beach.name)
    end
    if (not beach) then
        local sunny = BeachPikachu.sunnyBeaches()
        if (#sunny > 0) then
            beach = BeachPikachu.BEACHES[sunny[getRandom(1, #sunny)]]
        elseif (byStaff) then
            beach = BeachPikachu.BEACHES[getRandom(1, #BeachPikachu.BEACHES)]
        else
            return false, "No beach has harsh sunlight."
        end
    end
    local cids = {}
    for i = 1, BeachPikachu.SWARM_SIZE do
        local cid = spawnAt(beach, i <= BeachPikachu.SWARM_RAICHUS and "Surfing Raichu" or "Surfing Pikachu")
        if (cid) then
            cids[#cids + 1] = cid
        end
    end
    if (#cids == 0) then
        return false, string.format("Nothing could spawn on %s.", beach.name)
    end
    swarm = { beach = beach, cids = cids, endsAt = os.time() + BeachPikachu.SWARM_DURATION }
    lastSwarm = os.time()
    local text = string.format("Surfing Pikachu have taken to %s! Catch them before they paddle off.", beach.name)
    doBroadcastMessage("Beach swarm: " .. text, MESSAGE_STATUS_WARNING,
        { category = "event", title = "Beach swarm", text = text })
    print(string.format("> Beach swarm: %d on %s%s", #cids, beach.name, byStaff and " (staff)" or ""))
    return true, beach
end

function BeachPikachu.endSwarm()
    if (not swarm) then
        return false
    end
    for _, cid in ipairs(swarm.cids) do
        sendAway(cid)
    end
    print(string.format("> Beach swarm: %s is over", swarm.beach.name))
    swarm = nil
    return true
end

-- Called every second by EventCalendar.onThink; force skips the interval (tests)
function BeachPikachu.onThink(force)
    local now = os.time()
    if (swarm and now >= swarm.endsAt) then
        BeachPikachu.endSwarm()
    end
    if (not force and now - lastCheck < BeachPikachu.CHECK_INTERVAL) then
        return
    end
    lastCheck = now

    local summer = BeachPikachu.isSummer()
    for index, beach in ipairs(BeachPikachu.BEACHES) do
        local cid = rare[index]
        if (cid and (not isCreature(cid) or not isPokemonWild(cid))) then
            rare[index], cid = nil, nil
        end
        local sunny = summer and BeachPikachu.isSunny(beach)
        if (cid and not sunny) then
            sendAway(cid)
            rare[index] = nil
        elseif (not cid and sunny and getRandom(RANDOM_CHANCE_MIN, RANDOM_CHANCE_MAX) <= BeachPikachu.SPAWN_CHANCE) then
            local raichu = getRandom(RANDOM_CHANCE_MIN, RANDOM_CHANCE_MAX) <= BeachPikachu.RAICHU_CHANCE
            rare[index] = spawnAt(beach, raichu and "Surfing Raichu" or "Surfing Pikachu")
        end
    end

    if (summer and not swarm and now - lastSwarm >= BeachPikachu.SWARM_GAP
            and getRandom(RANDOM_CHANCE_MIN, RANDOM_CHANCE_MAX) <= BeachPikachu.SWARM_CHANCE) then
        BeachPikachu.startSwarm(nil, false)
    end
end
