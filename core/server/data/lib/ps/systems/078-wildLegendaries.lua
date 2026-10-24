-- Wild legendaries: the 21 legendaries and mythicals live in their own habitats across Kanto, Johto,
-- the Orange Islands and Hoenn, each with its own way of moving and its own signs, for group fights
-- (docs/upcoming-features.md, "Legendary spawning" and "Legendary revamp").
--
-- Talkactions, creature events and globalevents run in separate Lua states, so everything
-- shared lives in global storage (written to the database at once, like 073-shinyEvent.lua)
-- and in the legendary's own creature storage. Only the serverExpEvent globalevent
-- (WildLegendaries.onThink) spawns on schedule, moves, heals, shows signs and ends encounters. The
-- creature events only record hits (wildLegendaryHit) and hand out the rewards (wildLegendaryDeath);
-- the radar only asks for Mew's reveal.
--
-- The wild one is the plain species from its monster file; only its health is raised, for that
-- encounter. A caught one has the normal stats of its species.
--
-- Points come from LEGENDARY_ANCHORS (scripts/make-legendary-anchors.py): spawn spots of the map
-- with their area, zone (town) and tags. A species' habitat is the points of its regions and
-- places, weighted by its tags, and its home areas or zones.
--
-- Finding one: its signs show around it, on the marks of the way it came (the spot it left and every
-- routeSpacing tiles of the last stretch), and around the trainers in its area, a few tiles toward it.
-- Its moves, take-offs, landings and fly-overs reach the Legendary channel and Discord only when a
-- trainer sees them or they happen close to a town (seenBy).

WildLegendaries = {}

local MINUTE, HOUR, DAY = 60, 3600, 86400

-- tier: 1 legendary, 2 major legendary, 3 mythical (at most one out, no area in the announcements)
-- set: spawn together on the set roll (WildLegendaries.SETS)
-- style: how it moves
--   fly        lands anywhere in its habitat, far from the last spot (planned zone first)
--   roam       walks to a zone next to its own (LEGENDARY_ANCHORS.NEIGHBORS)
--   sea        swims along the coasts of its regions
--   territory  stays in the zone it came up in
--   cave       stays where it is; short teleports when hurt
--   sleep      asleep at one of its locations until a trainer wakes it; doesn't move
--   disguise   looks like a Pokemon of its spot until found; short teleports in its zone after
--   teleport   short teleports within its zone and the next ones
--   meteor     lands with a meteor and stays; short teleports when hurt
-- regions: Weather.REGIONS ids; places: outdoor, cave, indoor (home points count anywhere)
-- tags: weight added for each tag of a point (base 1); strict: only points with one of its tags
-- homes: areas or zones; homeShare: percent of the picks made among them
-- storm: weight in thunderstorms (and faster moves for roamers); trainers: weight where trainers are
-- signs: effects on its trail; arrive: effects when it lands; depart: effect where it leaves
-- dive: travels under the sea (only its dark shape shows); quake: shakes the screens around it when it comes up
WildLegendaries.SPECIES = {
    { name = "Articuno", tier = 1, set = "birds", style = "fly", regions = { "kanto", "orange", "johto" },
      places = { "outdoor" }, tags = { cold = 12, high = 2, mountain = 1, water = 1 },
      homes = { "Seafoam Mountain", "Interior Seafoam Mountain", "Within the Iceberg", "Ice Island", "Ice Island Cave", "Mahogany" },
      signs = { EFFECT_LEGENDARY_ARTICUNO_FROST, EFFECT_LEGENDARY_ARTICUNO_FROST, EFFECT_ICE_CRYSTAL_EMERGE } },
    { name = "Zapdos", tier = 1, set = "birds", style = "fly", regions = { "kanto", "johto", "orange" },
      places = { "outdoor" }, tags = { electric = 12, high = 1, mountain = 1 }, storm = 6,
      homes = { "Power Plant", "Power Plant of Hamlin", "Lightning Island", "Lightning Island Cave" },
      signs = { EFFECT_LEGENDARY_ZAPDOS_BOLT, EFFECT_LEGENDARY_ZAPDOS_BOLT, EFFECT_LIGHT_THUNDER } },
    { name = "Moltres", tier = 1, set = "birds", style = "fly", regions = { "kanto", "johto", "orange" },
      places = { "outdoor" }, tags = { fire = 12, mountain = 1, high = 1 },
      homes = { "Volcano", "Volcano Cave", "The Volcano Coast", "Ancient Volcano", "Fire Island", "Fire Island Cave", "Fire Mountain", "Cinnabar" },
      signs = { EFFECT_LEGENDARY_MOLTRES_FEATHER, EFFECT_LEGENDARY_MOLTRES_FEATHER, EFFECT_FIRE } },
    { name = "Raikou", tier = 1, set = "beasts", style = "roam", regions = { "johto", "kanto" },
      places = { "outdoor" }, tags = { electric = 8, remote = 1 }, storm = 6, homes = { "Ecruteak" },
      signs = { EFFECT_LEGENDARY_RAIKOU_SPARKS, EFFECT_LEGENDARY_RAIKOU_SPARKS, EFFECT_ELECTRIC_SPARK } },
    { name = "Entei", tier = 1, set = "beasts", style = "roam", regions = { "johto", "kanto" },
      places = { "outdoor" }, tags = { fire = 8, mountain = 3, rock = 1 }, homes = { "Ecruteak", "Volcano" },
      signs = { EFFECT_LEGENDARY_ENTEI_SCORCH, EFFECT_LEGENDARY_ENTEI_SCORCH, EFFECT_BURNING } },
    { name = "Suicune", tier = 1, set = "beasts", style = "roam", regions = { "johto", "kanto" },
      places = { "outdoor" }, tags = { water = 8, forest = 2 }, homes = { "Ecruteak", "Cianwood" },
      signs = { EFFECT_LEGENDARY_SUICUNE_MIST, EFFECT_LEGENDARY_SUICUNE_MIST, EFFECT_SMOKE } },
    { name = "Regirock", tier = 1, set = "regis", style = "sleep", regions = { "hoenn", "kanto" },
      places = { "outdoor", "cave" }, tags = { rock = 10, cave = 2 }, strict = true,
      homes = { "Rock Tunnel", "Stone Mountain", "Dewford" }, signs = { EFFECT_LEGENDARY_REGIROCK_ROCKS, EFFECT_FAILING_ROCKS } },
    { name = "Regice", tier = 1, set = "regis", style = "sleep", regions = { "hoenn", "kanto", "johto" },
      places = { "outdoor", "cave" }, tags = { cold = 10, cave = 2 }, strict = true,
      homes = { "Seafoam Mountain", "Interior Seafoam Mountain", "Within the Iceberg", "Mahogany" },
      signs = { EFFECT_LEGENDARY_REGICE_FROST, EFFECT_ICE_EMERGE } },
    { name = "Registeel", tier = 1, set = "regis", style = "sleep", regions = { "hoenn", "kanto" },
      places = { "outdoor", "cave" }, tags = { steel = 10, cave = 2 }, strict = true,
      homes = { "Power Plant", "Power Plant of Hamlin", "Dewford" }, signs = { EFFECT_LEGENDARY_REGISTEEL_SPARKS, EFFECT_METAL_CLAW } },
    { name = "Latias", tier = 1, set = "eon", style = "fly", fast = true,
      regions = { "kanto", "johto", "orange", "hoenn" }, places = { "outdoor" },
      tags = { peaceful = 4, forest = 2 }, trainers = 3, signs = { EFFECT_RED_STARS } },
    { name = "Latios", tier = 1, set = "eon", style = "fly", fast = true,
      regions = { "kanto", "johto", "orange", "hoenn" }, places = { "outdoor" },
      tags = { remote = 4, mountain = 2 }, trainers = 0.25, signs = { EFFECT_BIG_BLUE_BLINK } },
    { name = "Mewtwo", tier = 2, style = "cave", regions = { "kanto" }, places = { "outdoor", "cave" },
      tags = { remote = 4, cave = 2 }, homes = { "Cerulean Cave" }, homeShare = 80, warning = true,
      signs = { EFFECT_LEGENDARY_MEWTWO_PSYCHIC, EFFECT_LEGENDARY_MEWTWO_PSYCHIC, EFFECT_PURPLE_ENERGIZE } },
    { name = "Mew", tier = 3, style = "disguise", regions = { "kanto", "johto", "orange", "hoenn" },
      places = { "outdoor", "cave" }, tags = { forest = 4, mystic = 4 }, strict = true,
      homes = { "Pokemansion", "Pokemansion - Secret Area", "Fairchild", "Forgotten Temple", "Temple of Illusion" },
      signs = { EFFECT_LEGENDARY_MEW_SPARKLES, EFFECT_PINK_MINICLOUD }, arrive = { EFFECT_BIG_PINK_CLOUD } },
    { name = "Lugia", tier = 2, style = "sea", dive = true, regions = { "johto", "orange", "kanto" }, places = { "outdoor" },
      tags = { water = 10 }, strict = true, homes = { "Olivine", "Cianwood", "Shamouti" },
      signs = { EFFECT_LEGENDARY_WATER_RIPPLE, EFFECT_LEGENDARY_WATER_RIPPLE, EFFECT_WATER_SPLASH },
      arrive = { EFFECT_WATER_SPLASH, EFFECT_LEGENDARY_WATER_RIPPLE } },
    { name = "Ho-Oh", tier = 2, style = "fly", regions = { "johto", "kanto" }, places = { "outdoor" },
      tags = { high = 6, mountain = 2 }, homes = { "Ecruteak", "Lavender Tower" },
      signs = { EFFECT_LEGENDARY_HOOH_RAINBOW, EFFECT_LEGENDARY_HOOH_RAINBOW, EFFECT_BIG_YELLOW_SPARKS } },
    { name = "Celebi", tier = 3, style = "teleport", regions = { "johto", "kanto" }, places = { "outdoor" },
      tags = { forest = 8 }, strict = true, homes = { "Azalea", "Viridian Forest" },
      signs = { EFFECT_LEGENDARY_CELEBI_SPARKLES, EFFECT_LEGENDARY_CELEBI_SPARKLES, EFFECT_LEAVES } },
    { name = "Kyogre", tier = 2, style = "territory", dive = true, regions = { "hoenn", "orange" }, places = { "outdoor" },
      tags = { water = 10 }, strict = true, homes = { "Pacifidlog", "Sootopolis", "Lilycove", "Slateport" },
      rain = true, signs = { EFFECT_LEGENDARY_WATER_RIPPLE, EFFECT_WATER_TORNADO }, arrive = { EFFECT_WATER_TORNADO }, leave = "dived back into the deep" },
    { name = "Groudon", tier = 2, style = "territory", quake = true, regions = { "hoenn", "kanto" }, places = { "outdoor", "cave" },
      tags = { fire = 6, rock = 4 }, strict = true, homes = { "Lavaridge", "Fallarbor", "Volcano" },
      signs = { EFFECT_LEGENDARY_GROUDON_CRACK, EFFECT_GROUND_SMASH },
      arrive = { EFFECT_LEGENDARY_GROUDON_CRACK, EFFECT_BIG_ROCK_EMERGE }, depart = EFFECT_GROUND_SMASH, leave = "sank back underground" },
    { name = "Rayquaza", tier = 2, style = "fly", regions = { "hoenn", "johto", "kanto" }, places = { "outdoor" },
      tags = { high = 8, mountain = 2 }, strict = true, homes = { "Fortree", "Blackthorn" }, signs = { EFFECT_LEGENDARY_RAYQUAZA_WIND, EFFECT_LEGENDARY_RAYQUAZA_WIND, EFFECT_GREEN_WIND } },
    { name = "Jirachi", tier = 3, style = "meteor", regions = { "kanto", "johto", "orange", "hoenn" },
      places = { "outdoor" }, tags = { remote = 4, high = 2 }, homes = { "Mt. Moon", "Fallarbor" }, lifetime = 45 * MINUTE, shower = true,
      signs = { EFFECT_LEGENDARY_JIRACHI_STAR, EFFECT_FAILING_STARS }, arrive = { EFFECT_LEGENDARY_JIRACHI_STAR, EFFECT_EARTH_CRATER } },
    { name = "Deoxys", tier = 3, style = "meteor", regions = { "kanto", "johto", "orange", "hoenn" },
      places = { "outdoor" }, tags = { remote = 4 }, homes = { "Mt. Moon", "Fallarbor" }, impact = true,
      signs = { EFFECT_PURPLE_ELECTRIC_CLOUD }, arrive = { EFFECT_LEGENDARY_DEOXYS_IMPACT, EFFECT_EARTH_CRATER } },
}

WildLegendaries.SETS = {
    { id = "birds", name = "The legendary birds", members = { "Articuno", "Zapdos", "Moltres" } },
    { id = "beasts", name = "The legendary beasts", members = { "Raikou", "Entei", "Suicune" } },
    { id = "regis", name = "The three Regis", members = { "Regirock", "Regice", "Registeel" } },
    { id = "eon", name = "Latias and Latios", members = { "Latias", "Latios" } },
}

local BY_NAME, BY_INDEX, SET_BY_ID = {}, {}, {}
for index, species in ipairs(WildLegendaries.SPECIES) do
    species.index = index
    BY_NAME[species.name:lower()] = species
    BY_INDEX[index] = species
end
for _, set in ipairs(WildLegendaries.SETS) do
    SET_BY_ID[set.id] = set
end

local STYLE_TEXT = {
    fly = { leave = "flew away", depart = EFFECT_LEGENDARY_TAKEOFF, land = EFFECT_LEGENDARY_LANDING },
    roam = { leave = "ran off", depart = EFFECT_BIG_DUST_UP, land = EFFECT_BIG_DUST_DOWN },
    sea = { leave = "dived back into the sea" },
    territory = { leave = "went back to its territory" },
    cave = { leave = "teleported away" },
    sleep = { leave = "sank back into a deep sleep and vanished" },
    disguise = { leave = "slipped away" },
    teleport = { leave = "vanished" },
    meteor = { leave = "vanished into the sky" },
}

WildLegendaries.CONFIG = {
    maxAlive = 2,               -- scheduled ones out at once; set members don't count
    maxMajorAlive = 1,          -- of those, tier 2
    tierWeight = { 6, 2, 1 },
    setChance = 25,             -- percent: the schedule picks a set member and the whole set comes
    setBringsCooldown = true,   -- set members still on their cooldown come too

    -- Trainers online -> gap to the next spawn and the cooldowns. The gap is drawn at each
    -- spawn and checked again every 5 minutes, so it shrinks when the server fills up.
    -- The second row starts at 5 trainers on live; it is 1 while we test.
    population = {
        { online = 0, gap = { 16 * HOUR, 24 * HOUR }, cooldown = { 30 * HOUR, 4 * DAY } },
        { online = 1, gap = { 4 * HOUR, 8 * HOUR }, cooldown = { 30 * HOUR, 4 * DAY } },
        { online = 15, gap = { 3 * HOUR, 6 * HOUR }, cooldown = { 24 * HOUR, 3 * DAY } },
        { online = 40, gap = { 2 * HOUR, 4 * HOUR }, cooldown = { 16 * HOUR, 2 * DAY } },
    },
    mythicalCooldown = 1.5,     -- times the tier 2 cooldown
    gapCheckInterval = 300,
    retryInterval = 60,         -- when a spawn is due but blocked (limits, restart window)
    quietBeforeRestart = 10 * 60,

    lifetime = { 90 * MINUTE, 120 * MINUTE, 60 * MINUTE },
    sleepLifetime = 4 * HOUR,   -- a Regi asleep
    wakeLifetime = 60 * MINUTE, -- a Regi once woken
    stayWhileHit = 120,         -- doesn't leave while hit within this many seconds
    moveEvery = { 4 * 60, 6 * 60 },
    fastMoveEvery = { 2 * 60, 3 * 60 },
    holdWhileHit = 60,          -- doesn't move on while hit within this many seconds
    minMoveDistance = 120,      -- a flight goes at least this far
    homeShare = 35,
    flee = { { 0.5 }, { 0.5, 0.25 }, { 0.5, 0.25 } },
    healAfter = 3 * 60,
    healPercent = 5,            -- of max health every 5 seconds once left alone

    healthMultiplier = { 30, 60, 60 },
    recommendedLevel = 50,

    rewardRatio = 0.1,
    rewards = { { rareCandy = 1, money = 5000 }, { rareCandy = 2, money = 10000 }, { rareCandy = 2, money = 10000 } },
    rareCandyId = 14463,
    bodyOwnerSeconds = 60,
    bodySeconds = 180,
    catchWindow = 300,          -- a catch this long after the defeat is announced as the legendary's

    signEvery = 6,              -- seconds between signs of a legendary
    faintSignEvery = 15,        -- of a mythical
    disguiseSignEvery = 30,     -- of Mew in disguise
    trailLength = 24,           -- marks of its trail that still show signs (the spots it left and the way it came)
    trailSeconds = 10 * MINUTE,
    trailView = 12,             -- a mark shows its signs while a trainer is this close
    routeSpacing = 8,           -- tiles between the marks it leaves on its way to a new spot
    routeLength = 80,           -- only the last this many tiles of the way are marked
    areaSignRange = 60,         -- trainers this close (same floor, out of sight) find signs leading to it
    areaSignEvery = { 6, 20 },  -- seconds between them for each trainer: right outside its sight, at the edge
    sightRange = { 9, 7 },      -- a trainer this close sees it move or land
    townSightRange = 35,        -- a town sees it within this many tiles of its centre
    saveEvery = 30,
    warningSeconds = 180,       -- Mewtwo's psychic disturbance before it appears
    warningEffectEvery = 4,     -- seconds between bursts, every second in the last warningFinalSeconds
    warningFinalSeconds = 15,
    warningBurst = { 4, 10 },   -- effects in a burst, growing as it gets closer
    warningRadius = 5,
    revealRank = 4,             -- Ranger rank whose radar finds Mew in disguise

    -- Flights: flyers cross to their next spot in the open, Lugia and Kyogre under the sea
    flightSpeed = 6,            -- tiles per second
    fastFlightSpeed = 7,        -- Latias and Latios
    swimSpeed = 4,
    flightSeconds = { 8, 60 },  -- shortest and longest crossing; long ones go faster
    landfallMin = 8,            -- a dive surfaces at the first shore at least this far along its way
    circleSeconds = 4,          -- circling over the landing spot
    flightView = { 18, 14 },    -- trainers this close to where it is are sent the flight
    flightSignEvery = 2,
    flightSightingEvery = 10,   -- at most one "seen flying over" per legendary this often
    shakeRange = 14,            -- Groudon shakes the screens of trainers this close

    -- Events (stage 3)
    showerSeconds = 20,         -- Jirachi's meteor shower around where it lands
    showerStars = 3,            -- falling stars a second
    showerRadius = 7,
    meteorView = { 20, 16 },    -- trainers this close see the meteors cross their screen
    impactDelay = 1200,         -- ms: Deoxys's meteor falls, then the impact
    rayquazaChance = 50,        -- percent, rolled once when Groudon and Kyogre are both out
    rayquazaDelay = 2 * 60,     -- seconds after that it comes down
    clashCheckEvery = 10,
    clashMinutes = 15,          -- the clash weather is set this long and renewed while they stay
    -- two legendaries in the same zone or next ones: the weather there while they stay
    clashes = {
        { "Articuno", "Zapdos", "hail", "a hailstorm breaks out" },
        { "Articuno", "Moltres", "fog", "the air fills with steam" },
        { "Groudon", "Kyogre", "thunderstorm", "a great storm breaks out", broadcast = true, calmedBy = "Rayquaza" },
    },

    channelId = 14,             -- data/XML/channels.xml "Legendaries"
}
local CONFIG = WildLegendaries.CONFIG

local KEY = {
    NEXT_AT = GLOBAL_STORAGES.LEGENDARY_NEXT_AT,
    GAP_FROM = GLOBAL_STORAGES.LEGENDARY_GAP_FROM,
    GAP_ROLL = GLOBAL_STORAGES.LEGENDARY_GAP_ROLL,
    COOLDOWNS = GLOBAL_STORAGES.LEGENDARY_COOLDOWNS,
    ACTIVE = GLOBAL_STORAGES.LEGENDARY_ACTIVE,
    SEQUENCE = GLOBAL_STORAGES.LEGENDARY_SEQUENCE,
    RECENT = GLOBAL_STORAGES.LEGENDARY_RECENT,
    MODE = GLOBAL_STORAGES.LEGENDARY_MODE,
    SAVED = GLOBAL_STORAGES.LEGENDARY_SAVED,
    PENDING = GLOBAL_STORAGES.LEGENDARY_PENDING,
    FLIGHTS = GLOBAL_STORAGES.LEGENDARY_FLIGHTS,
    EVENTS = GLOBAL_STORAGES.LEGENDARY_EVENTS,
    CLASHES = GLOBAL_STORAGES.LEGENDARY_CLASHES,
}

-- Creature storage of the legendary itself.
local MON = {
    ENCOUNTER = 9100,
    ENDS_AT = 9101,
    LAST_HIT = 9102,
    NEXT_MOVE = 9103,
    FLEE_STAGE = 9104,
    FLEE_PENDING = 9105,
    AREA = 9106,
    SPAWNED_AT = 9107,
    LAST_HEAL = 9108,
    ZONE = 9109,         -- the zone (town) it is in
    HOME_ZONE = 9110,    -- where a territory one stays
    NEXT_ZONE = 9111,    -- where it goes next
    TRAIL = 9112,        -- "t;x,y,z,time;..." the spots it left, newest first
    PATH = 9113,         -- "Zone>Zone>..." the zones it passed, newest last
    LAST_SIGN = 9114,
    MOVED_AT = 9115,
    ASLEEP = 9116,
    WAKE_PENDING = 9117,
    DISGUISED = 9118,
    REVEAL_PENDING = 9119,
    FOUND_BY = 9120,     -- who woke or revealed it
    MOVE_PENDING = 9121, -- staff asked it to move on (the globalevent does it)
}

-- Storage ---------------------------------------------------------------------------------------

local function getNumber(key)
    return tonumber(getStorage(key)) or -1
end

local function store(key, value)
    doSetStorage(key, value)
    db.executeQuery(string.format("REPLACE INTO `global_storage` (`key`, `world_id`, `value`) VALUES (%d, %d, %s);",
        key, getConfigValue("worldId") or 0, db.escapeString(tostring(value))))
end

-- "m;Articuno=123;Mewtwo=456": a letter first so getStorage never reads it as a number.
local function readMap(key)
    local map = {}
    local text = getStorage(key)
    if (type(text) == "string") then
        for name, value in text:gmatch("([^;=]+)=([^;]*)") do
            map[name] = value
        end
    end
    return map
end

local function writeMap(key, map)
    local parts = { "m" }
    for name, value in pairs(map) do
        table.insert(parts, name .. "=" .. tostring(value))
    end
    store(key, table.concat(parts, ";"))
end

local function monGet(cid, key)
    local value = getCreatureStorage(cid, key)
    return tonumber(value) or value
end

local function monNumber(cid, key)
    return tonumber(getCreatureStorage(cid, key)) or -1
end

local function monText(cid, key)
    local value = getCreatureStorage(cid, key)
    if (type(value) ~= "string" or tonumber(value)) then
        return nil
    end
    return value
end

-- Active encounters: encounter id -> "cid:Species:flags" (s: set member, d: Mew in disguise). Kept in
-- the database so the encounters open at a restart can be put back or closed on the Discord side.
local function getActive()
    local list = {}
    for encounter, value in pairs(readMap(KEY.ACTIVE)) do
        local cid, name, flags = value:match("^(%d+):([^:]+):?(%a*)$")
        if (cid) then
            table.insert(list, { encounter = tonumber(encounter), cid = tonumber(cid), name = name, flags = flags or "" })
        end
    end
    table.sort(list, function(a, b) return a.encounter < b.encounter end)
    return list
end

local function setActive(encounter, cid, name, flags)
    local map = readMap(KEY.ACTIVE)
    map[tostring(encounter)] = cid and (cid .. ":" .. name .. ":" .. (flags or "")) or nil
    writeMap(KEY.ACTIVE, map)
end

local function activeOf(cid)
    for _, a in ipairs(getActive()) do
        if (a.cid == cid) then
            return a
        end
    end
    return nil
end

function WildLegendaries.getSpecies(name)
    if (not name) then
        return nil
    end
    name = tostring(name):lower():gsub("^shiny ", "")
    return BY_NAME[name]
end

function WildLegendaries.getSet(id)
    return id and SET_BY_ID[tostring(id):lower()] or nil
end

function WildLegendaries.isEncounter(cid)
    return isMonster(cid) and monNumber(cid, MON.ENCOUNTER) > 0
end

function WildLegendaries.isDisguised(cid)
    return isMonster(cid) and monNumber(cid, MON.ENCOUNTER) > 0 and monNumber(cid, MON.DISGUISED) == 1
end

function WildLegendaries.isAsleep(cid)
    return isMonster(cid) and monNumber(cid, MON.ENCOUNTER) > 0 and monNumber(cid, MON.ASLEEP) == 1
end

function WildLegendaries.getCooldowns()
    local cooldowns = {}
    for name, value in pairs(readMap(KEY.COOLDOWNS)) do
        cooldowns[name] = tonumber(value)
    end
    return cooldowns
end

function WildLegendaries.setCooldown(name, untilTime)
    local map = readMap(KEY.COOLDOWNS)
    map[name] = untilTime
    writeMap(KEY.COOLDOWNS, map)
end

function WildLegendaries.clearCooldowns(name)
    if (not name) then
        store(KEY.COOLDOWNS, "m")
        return
    end
    local map = readMap(KEY.COOLDOWNS)
    map[name] = nil
    writeMap(KEY.COOLDOWNS, map)
end

-- Auto: spawns on the schedule. Manual: only staff start them; what is out stays.
function WildLegendaries.isManual()
    return getStorage(KEY.MODE) == "manual"
end

function WildLegendaries.setManual(manual)
    store(KEY.MODE, manual and "manual" or "auto")
end

-- Population -------------------------------------------------------------------------------------

function WildLegendaries.getOnline()
    local players = getPlayersOnline()
    return type(players) == "table" and #players or 0
end

function WildLegendaries.getPopulation(online)
    online = online or WildLegendaries.getOnline()
    local row = CONFIG.population[1]
    for _, r in ipairs(CONFIG.population) do
        if (online >= r.online) then
            row = r
        end
    end
    return row
end

function WildLegendaries.cooldownFor(species)
    local row = WildLegendaries.getPopulation()
    if (species.tier == 3) then
        return math.floor(row.cooldown[2] * CONFIG.mythicalCooldown)
    end
    return row.cooldown[species.tier]
end

local function lerp(range, roll)
    return math.floor(range[1] + (range[2] - range[1]) * roll / 1000)
end

-- Next spawn time with today's population; never later than the time already set.
local function scheduleNext(now, fresh)
    if (fresh or getNumber(KEY.GAP_FROM) <= 0) then
        store(KEY.GAP_FROM, now)
        store(KEY.GAP_ROLL, getRandom(0, 1000))
        store(KEY.NEXT_AT, 0)
    end
    local candidate = getNumber(KEY.GAP_FROM) + lerp(WildLegendaries.getPopulation().gap, getNumber(KEY.GAP_ROLL))
    local current = getNumber(KEY.NEXT_AT)
    if (current <= 0 or candidate < current) then
        store(KEY.NEXT_AT, candidate)
    end
    return getNumber(KEY.NEXT_AT)
end
WildLegendaries.scheduleNext = scheduleNext

function WildLegendaries.getNextSpawn()
    local at = getNumber(KEY.NEXT_AT)
    return at > 0 and at or nil
end

function WildLegendaries.setNextSpawn(at)
    store(KEY.NEXT_AT, at)
end

-- Seconds until the daily restart, or nil.
local function untilRestart(now)
    if (not ServerRestart) then
        return nil
    end
    local at = ServerRestart.getScheduled()
    local daily = ServerRestart.getDaily()
    if (daily) then
        local nextDaily = ServerRestart.nextDaily(daily, now)
        at = (at and math.min(at, nextDaily)) or nextDaily
    end
    return at and (at - now) or nil
end

-- Points -----------------------------------------------------------------------------------------

local WATER = {}
for _, id in ipairs(WATER_IDS or {}) do
    WATER[id] = true
end

local points = nil

-- LEGENDARY_ANCHORS.POINTS read once per Lua state: { index, x, y, z, area, zone, tags, spawn, region, place }
function WildLegendaries.getPoints()
    if (not points) then
        points = {}
        for index, p in ipairs(LEGENDARY_ANCHORS.POINTS) do
            local tags = {}
            for tag in p[6]:gmatch("[^,]+") do
                tags[tag] = true
            end
            local region = Weather.regionAt({ x = p[1], y = p[2], z = p[3] })
            points[index] = { index = index, x = p[1], y = p[2], z = p[3], area = p[4] ~= "" and p[4] or p[5],
                              named = p[4] ~= "", zone = p[5], tags = tags, spawn = p[7], region = region and region.id,
                              place = tags.cave and "cave" or (tags.indoor and "indoor" or "outdoor") }
        end
    end
    return points
end

local function toSet(list)
    local set = {}
    for _, value in ipairs(list or {}) do
        set[value] = true
    end
    return set
end

-- Ground, no water, no protection zone or house. With cid, also room for that creature.
function WildLegendaries.isGoodPoint(pos, cid)
    local ground = getTileThingByPos({ x = pos.x, y = pos.y, z = pos.z, stackpos = STACKPOS_GROUND })
    if (not ground or not ground.itemid or ground.itemid == 0 or WATER[ground.itemid]) then
        return false
    end
    local info = getTileInfo(pos)
    if (not info or info.protection or info.house) then
        return false
    end
    if (cid and doTileQueryAdd(cid, pos, 0, false) ~= RETURNVALUE_NOERROR) then
        return false
    end
    return true
end

-- The habitat of a species, built once per Lua state: { all = { {point, weight} }, home = {...},
-- zones = { [zone] = weight } }
local habitats = {}

function WildLegendaries.getHabitat(species)
    local habitat = habitats[species.name]
    if (habitat) then
        return habitat
    end
    habitat = { all = {}, home = {}, zones = {} }
    local regions, places, homes = toSet(species.regions), toSet(species.places or { "outdoor" }), toSet(species.homes)
    for _, point in ipairs(WildLegendaries.getPoints()) do
        if (regions[point.region]) then
            local home = (point.named and homes[point.area]) or homes[point.zone] or false
            if (home or places[point.place]) then
                local weight, matched = 1, false
                for tag, extra in pairs(species.tags or {}) do
                    if (point.tags[tag]) then
                        weight, matched = weight + extra, true
                    end
                end
                if (home or matched or not species.strict) then
                    local entry = { point = point, weight = weight }
                    table.insert(habitat.all, entry)
                    if (home) then
                        table.insert(habitat.home, entry)
                    end
                    habitat.zones[point.zone] = (habitat.zones[point.zone] or 0) + weight
                end
            end
        end
    end
    habitats[species.name] = habitat
    return habitat
end

-- Zone weather and trainers, a few seconds old at most
local zoneCache = { at = -1, kinds = {}, trainers = nil }

local function weatherZone(name)
    for _, zone in ipairs(Weather.getZones()) do
        if (zone.name == name) then
            return zone
        end
    end
    return nil
end
WildLegendaries.weatherZone = weatherZone

local function refreshZoneCache()
    local now = os.time()
    if (now - zoneCache.at >= 5) then
        zoneCache = { at = now, kinds = {}, trainers = nil }
    end
end

local function zoneWeather(name)
    refreshZoneCache()
    if (zoneCache.kinds[name] == nil) then
        local zone = weatherZone(name)
        zoneCache.kinds[name] = zone and Weather.at(zone).kind or "clear"
    end
    return zoneCache.kinds[name]
end

local function trainerZones()
    refreshZoneCache()
    if (not zoneCache.trainers) then
        zoneCache.trainers = {}
        for _, pid in ipairs(getPlayersOnline() or {}) do
            local zone = Weather.zoneAt(getCreaturePosition(pid))
            if (zone) then
                zoneCache.trainers[zone.name] = true
            end
        end
    end
    return zoneCache.trainers
end

local function regionOn(id)
    return Weather.isRegionOn(Weather.getRegion(id))
end

local function liveWeight(species, point, weight)
    if (species.storm and zoneWeather(point.zone) == "thunderstorm") then
        weight = weight * species.storm
    end
    if (species.trainers and trainerZones()[point.zone]) then
        weight = weight * species.trainers
    end
    return weight
end

local function distance(a, b)
    return math.max(math.abs(a.x - b.x), math.abs(a.y - b.y))
end

local DIRECTIONS = { "east", "south-east", "south", "south-west", "west", "north-west", "north", "north-east" }

local function directionTo(from, to)
    local angle = math.deg(math.atan2(to.y - from.y, to.x - from.x)) -- y grows to the south
    return DIRECTIONS[(math.floor((angle + 22.5) / 45) % 8) + 1]
end

-- A free tile on or around the point (spawn spots, so a wild Pokemon often stands on them)
local function spotAt(point, cid)
    for radius = 0, 3 do
        for dx = -radius, radius do
            for dy = -radius, radius do
                if (math.max(math.abs(dx), math.abs(dy)) == radius) then
                    local pos = { x = point.x + dx, y = point.y + dy, z = point.z }
                    if (WildLegendaries.isGoodPoint(pos, cid)) then
                        return pos
                    end
                end
            end
        end
    end
    return nil
end

-- A point of the species' habitat. options: cid (room for it), from + minDistance, zones (a set of zone
-- names). Returns the tile and the point, or nil.
function WildLegendaries.pickPoint(species, options)
    options = options or {}
    local habitat = WildLegendaries.getHabitat(species)
    local pools = { habitat.all }
    if (#habitat.home > 0 and not options.zones and getRandom(1, 100) <= (species.homeShare or CONFIG.homeShare)) then
        pools = { habitat.home, habitat.all }
    end
    local regionsOn = {}
    for _, region in ipairs(species.regions) do
        regionsOn[region] = regionOn(region)
    end
    for _, pool in ipairs(pools) do
        local list, total = {}, 0
        for _, entry in ipairs(pool) do
            local point = entry.point
            if (regionsOn[point.region] and (not options.zones or options.zones[point.zone]) and
                    (not options.from or distance(point, options.from) >= (options.minDistance or 0))) then
                local weight = liveWeight(species, point, entry.weight)
                if (weight > 0) then
                    total = total + weight
                    list[#list + 1] = { point = point, upTo = total }
                end
            end
        end
        for try = 1, 8 do
            if (total <= 0) then
                break
            end
            local roll = math.random() * total
            local low, high = 1, #list
            while (low < high) do
                local middle = math.floor((low + high) / 2)
                if (list[middle].upTo < roll) then
                    low = middle + 1
                else
                    high = middle
                end
            end
            local point = list[low].point
            local pos = spotAt(point, options.cid)
            if (pos) then
                return pos, point
            end
        end
    end
    return nil
end

-- The nearest point to a spot (for its area, zone and local species), within maxDistance
function WildLegendaries.nearestPoint(pos, maxDistance)
    local best, bestDistance = nil, nil
    for _, point in ipairs(WildLegendaries.getPoints()) do
        if (point.z == pos.z or not best) then
            local d = distance(point, pos) + math.abs(point.z - pos.z) * 20
            if (not bestDistance or d < bestDistance) then
                best, bestDistance = point, d
            end
        end
    end
    if (maxDistance and bestDistance and bestDistance > maxDistance) then
        return nil
    end
    return best
end

-- The area a spot is announced as: the map's area name, or its town
function WildLegendaries.areaAt(pos)
    local point = WildLegendaries.nearestPoint(pos, 60)
    if (point) then
        return point.area, point.zone
    end
    local zone = Weather.zoneAt(pos)
    return zone and zone.name or "an unknown place", zone and zone.name or nil
end

-- A free tile minRadius to maxRadius tiles away on the same floor (short teleports)
local function hopFrom(from, minRadius, maxRadius, cid)
    for try = 1, 30 do
        local r = getRandom(minRadius, maxRadius)
        local pos = { x = from.x + getRandom(-r, r), y = from.y + getRandom(-r, r), z = from.z }
        if (distance(pos, from) >= minRadius and WildLegendaries.isGoodPoint(pos, cid) and
                (not isSightClear or isSightClear(from, pos, false) or try > 20)) then
            return pos
        end
    end
    return nil
end

-- The next zone it heads for: a neighbor for roamers, any zone of its habitat for flyers and swimmers
local function planZone(species, current)
    local habitat = WildLegendaries.getHabitat(species)
    local choices, total = {}, 0
    local function add(zone, weight)
        local point = nil
        for _, entry in ipairs(habitat.all) do
            if (entry.point.zone == zone) then
                point = entry.point
                break
            end
        end
        if (point and weight > 0 and regionOn(point.region)) then
            weight = liveWeight(species, point, weight)
            total = total + weight
            choices[#choices + 1] = { zone = zone, upTo = total }
        end
    end
    if (species.style == "roam") then
        for _, zone in ipairs((LEGENDARY_ANCHORS.NEIGHBORS or {})[current or ""] or {}) do
            add(zone, habitat.zones[zone] or 0)
        end
    elseif (species.style == "fly" or species.style == "sea") then
        for zone, weight in pairs(habitat.zones) do
            if (zone ~= current) then
                add(zone, weight)
            end
        end
    else
        return nil
    end
    if (total <= 0) then
        return nil
    end
    local roll = math.random() * total
    for _, choice in ipairs(choices) do
        if (choice.upTo >= roll) then
            return choice.zone
        end
    end
    return choices[#choices].zone
end

-- Notifications ----------------------------------------------------------------------------------

local function getLook(name)
    local info = getMonsterInfo(name)
    return info and info.outfit and info.outfit.lookType or nil
end

local function cardFor(data)
    data.look = data.look or getLook(data.species)
    data.dexNumber = data.dexNumber or getPokemonNumberByName(data.species)
    return JSON.encode(data)
end

-- Cards for the modern client (EXTENDED_IDS.LEGENDARY); older clients get the text only.
local function sendCard(players, data)
    if (not EXTENDED_IDS.LEGENDARY) then
        return
    end
    local payload = cardFor(data)
    for _, pid in ipairs(players) do
        if (isPlayer(pid) and getPlayerUsingOtClient(pid)) then
            doSendPlayerExtendedOpcode(pid, EXTENDED_IDS.LEGENDARY, payload)
        end
    end
end

local function allPlayers()
    local players = getPlayersOnline()
    return type(players) == "table" and players or {}
end

local function channelPlayers()
    local users = getChannelUsers(CONFIG.channelId)
    return type(users) == "table" and users or {}
end

local function toChannel(text)
    for _, pid in ipairs(channelPlayers()) do
        if (isPlayer(pid)) then
            doPlayerSendChannelMessage(pid, "", text, TALKTYPE_CHANNEL_O, CONFIG.channelId)
        end
    end
end

local function broadcast(text)
    doBroadcastMessage(text, MESSAGE_STATUS_WARNING)
    toChannel(text)
end
WildLegendaries.broadcast = broadcast

local function discord(event)
    if (DiscordBridge and DiscordBridge.emitLegendary) then
        DiscordBridge.emitLegendary(event)
    end
end

local function effectAt(pos, effect)
    if (effect and pos) then
        doSendMagicEffect(pos, effect)
    end
end

local function pick(list)
    return list and #list > 0 and list[getRandom(1, #list)] or nil
end

-- Flights and shakes for the modern client (EXTENDED_IDS.LEGENDARY_FLIGHT)
local function sendFlightData(players, data)
    if (not EXTENDED_IDS.LEGENDARY_FLIGHT) then
        return
    end
    local payload = JSON.encode(data)
    for _, pid in ipairs(players) do
        if (isPlayer(pid) and getPlayerUsingOtClient(pid)) then
            doSendPlayerExtendedOpcode(pid, EXTENDED_IDS.LEGENDARY_FLIGHT, payload)
        end
    end
end

local function playersNear(pos, rangeX, rangeY)
    local list = {}
    for _, cid in ipairs(getSpectators(pos, rangeX, rangeY, true) or {}) do
        if (isPlayer(cid)) then
            list[#list + 1] = cid
        end
    end
    return list
end

-- Who notices it at pos: the name of a trainer in sight, else the town it is close to (nil, town), else nil.
-- Moves, take-offs, landings and fly-overs nobody notices aren't reported.
local function seenBy(pos)
    for _, pid in ipairs(playersNear(pos, CONFIG.sightRange[1], CONFIG.sightRange[2])) do
        if (getCreaturePosition(pid).z == pos.z) then
            return getCreatureName(pid)
        end
    end
    local zone = Weather.zoneAt(pos)
    if (zone and zone.pos and distance(zone.pos, pos) <= CONFIG.townSightRange) then
        return nil, zone.name
    end
    return nil
end
WildLegendaries.seenBy = seenBy

-- "Ash spotted Zapdos near Route 10." / "Zapdos was seen near Route 10, close to Cerulean."
local function seenText(trainer, town, species, verb, area)
    if (trainer) then
        return string.format("%s saw %s %s %s.", trainer, species.name, verb, area)
    elseif (area == town) then
        return string.format("%s was seen %s %s.", species.name, verb, area)
    end
    return string.format("%s was seen %s %s, close to %s.", species.name, verb, area, town)
end

-- Groudon coming up, Deoxys's impact: the screens around it shake, harder the closer they are
local function shakeAround(pos, ms, delay)
    for _, pid in ipairs(playersNear(pos, CONFIG.shakeRange, CONFIG.shakeRange)) do
        local p = getCreaturePosition(pid)
        local d = math.max(math.abs(p.x - pos.x), math.abs(p.y - pos.y))
        sendFlightData({ pid }, { type = "shake", strength = d <= 5 and 3 or (d <= 9 and 2 or 1), ms = ms or 1600,
            delay = delay })
    end
end
WildLegendaries.shakeAround = shakeAround

-- Events: Jirachi's meteor shower, Deoxys's impact ------------------------------------------------

local function setEvent(name, value)
    local map = readMap(KEY.EVENTS)
    map[name] = value
    writeMap(KEY.EVENTS, map)
end

local function getShower()
    local x, y, z, untilTime = (readMap(KEY.EVENTS).shower or ""):match("^(%d+),(%d+),(%d+),(%d+)$")
    return x and { pos = { x = tonumber(x), y = tonumber(y), z = tonumber(z) }, untilTime = tonumber(untilTime) } or nil
end

local function sendMeteors(pos, seconds)
    sendFlightData(playersNear(pos, CONFIG.meteorView[1], CONFIG.meteorView[2]),
        { type = "meteors", seconds = seconds, count = seconds * 3 })
end

-- Falling stars around pos for showerSeconds; the globalevent drops them (runShower) and sends the
-- trainers near it the stars across their screen every 5 seconds
local function startShower(pos)
    setEvent("shower", string.format("%d,%d,%d,%d", pos.x, pos.y, pos.z, os.time() + CONFIG.showerSeconds))
    sendMeteors(pos, 5)
end
WildLegendaries.startShower = startShower
WildLegendaries.getShower = getShower

local function runShower(now)
    local shower = getShower()
    if (not shower) then
        return
    end
    local left = shower.untilTime - now
    if (left <= 0) then
        setEvent("shower", nil)
        return
    end
    for i = 1, CONFIG.showerStars do
        local r = CONFIG.showerRadius
        local spot = { x = shower.pos.x + getRandom(-r, r), y = shower.pos.y + getRandom(-r, r), z = shower.pos.z }
        effectAt(spot, getRandom(1, 4) == 1 and EFFECT_FAILING_STARS or EFFECT_LEGENDARY_JIRACHI_STAR)
    end
    if (left % 5 == 0 and left < CONFIG.showerSeconds) then
        sendMeteors(shower.pos, 5)
    end
end
WildLegendaries.runShower = runShower

-- Deoxys's meteor: it streaks down the screens near it, then the impact and the ground shakes
local function impact(pos, effects)
    sendFlightData(playersNear(pos, CONFIG.meteorView[1], CONFIG.meteorView[2]), { type = "meteors", big = true, seconds = 1 })
    shakeAround(pos, 1400, CONFIG.impactDelay)
    local function hit()
        for _, effect in ipairs(effects or { EFFECT_LEGENDARY_DEOXYS_IMPACT, EFFECT_EARTH_CRATER }) do
            effectAt(pos, effect)
        end
    end
    if (addEvent) then
        addEvent(hit, CONFIG.impactDelay)
    else
        hit()
    end
end
WildLegendaries.impact = impact

-- Encounters -------------------------------------------------------------------------------------

local function healthPercent(cid)
    return math.floor(getCreatureHealth(cid) * 100 / math.max(1, getCreatureMaxHealth(cid)) + 0.5)
end

local function nextMoveDelay(species, cid)
    local range = species.fast and CONFIG.fastMoveEvery or CONFIG.moveEvery
    local delay = getRandom(range[1], range[2])
    -- roamers that like storms run faster in them
    if (cid and species.storm and species.style == "roam") then
        local zone = monText(cid, MON.ZONE)
        if (zone and zoneWeather(zone) == "thunderstorm") then
            delay = math.floor(delay / 2)
        end
    end
    return delay
end

local function boostHealth(cid, species, percent)
    local health = getCreatureMaxHealth(cid) * CONFIG.healthMultiplier[species.tier]
    setCreatureMaxHealth(cid, health)
    local target = math.max(1, math.floor(health * (percent or 100) / 100))
    doCreatureAddHealth(cid, target - getCreatureHealth(cid))
end

local function lifetimeOf(species)
    return species.lifetime or CONFIG.lifetime[species.tier]
end

local function mythicalOut(except)
    for _, a in ipairs(getActive()) do
        local s = WildLegendaries.getSpecies(a.name)
        if (s and s.tier == 3 and a.name ~= except and isMonster(a.cid)) then
            return a.name
        end
    end
    return nil
end

-- An encounter in the air or under the sea is in ACTIVE with cid 0 and flag f
local function isOut(name)
    for _, a in ipairs(getActive()) do
        if (a.name == name and (isMonster(a.cid) or a.flags:find("f"))) then
            return true
        end
    end
    return false
end

-- Flights: encounter -> { species, health, from, to, start, seconds, endsAt, flags, stage, kind ("a" air, "w" water) }
local function getFlights()
    local list = {}
    for encounter, value in pairs(readMap(KEY.FLIGHTS)) do
        local index, health, fx, fy, fz, tx, ty, tz, start, seconds, endsAt, flags, stage, kind = value:match(
            "^(%d+)|(%d+)|(%d+),(%d+),(%d+)|(%d+),(%d+),(%d+)|(%d+)|(%d+)|(%d+)|(%a*)|(%d+)|(%a)$")
        local species = index and BY_INDEX[tonumber(index)]
        if (species) then
            list[tonumber(encounter)] = { encounter = tonumber(encounter), species = species, health = tonumber(health),
                from = { x = tonumber(fx), y = tonumber(fy), z = tonumber(fz) },
                to = { x = tonumber(tx), y = tonumber(ty), z = tonumber(tz) }, start = tonumber(start),
                seconds = tonumber(seconds), endsAt = tonumber(endsAt), flags = flags, stage = tonumber(stage), kind = kind }
        end
    end
    return list
end

-- Returns false when it doesn't fit in the storage (it then moves the old way)
local function setFlight(encounter, f)
    local map = readMap(KEY.FLIGHTS)
    map[tostring(encounter)] = f and string.format("%d|%d|%d,%d,%d|%d,%d,%d|%d|%d|%d|%s|%d|%s", f.species.index, f.health,
        f.from.x, f.from.y, f.from.z, f.to.x, f.to.y, f.to.z, f.start, f.seconds, f.endsAt, f.flags, f.stage, f.kind) or nil
    local length = 1
    for name, value in pairs(map) do
        length = length + #name + #value + 2
    end
    if (length > 255) then
        return false
    end
    writeMap(KEY.FLIGHTS, map)
    return true
end

local function landsAt(f)
    return f.start + f.seconds + (f.kind == "a" and CONFIG.circleSeconds or 0)
end

-- Where it is over the map at time t, and how far along (0 to 1)
local function flightAt(f, t)
    local progress = math.max(0, math.min(1, (t - f.start) / math.max(1, f.seconds)))
    return { x = math.floor(f.from.x + (f.to.x - f.from.x) * progress + 0.5),
             y = math.floor(f.from.y + (f.to.y - f.from.y) * progress + 0.5),
             z = progress < 0.5 and f.from.z or f.to.z }, progress
end

-- Pending warnings (Mewtwo): species -> { at, point, source }
local function getPending()
    local list = {}
    for name, value in pairs(readMap(KEY.PENDING)) do
        local at, point, source = value:match("^(%d+):(%d+):(%a*)$")
        if (at) then
            list[name] = { at = tonumber(at), point = tonumber(point), source = source ~= "" and source or "schedule" }
        end
    end
    return list
end

local function setPending(name, at, pointIndex, source)
    local map = readMap(KEY.PENDING)
    map[name] = at and string.format("%d:%d:%s", at, pointIndex, source or "") or nil
    writeMap(KEY.PENDING, map)
end

-- Kyogre brings rain to its zone while it is out, unless staff set the weather there
local function applyWeather(cid, species, zoneName)
    if (not species.rain or not zoneName) then
        return
    end
    local zone = weatherZone(zoneName)
    if (zone and not Weather.getOverrides()[zone.id]) then
        Weather.setOverride({ zone.id }, "rain", math.ceil(math.max(60, monNumber(cid, MON.ENDS_AT) - os.time()) / 60))
    end
end

local function clearWeather(cid, species)
    if (not species or not species.rain) then
        return
    end
    local zone = weatherZone(monText(cid, MON.HOME_ZONE) or monText(cid, MON.ZONE) or "")
    local override = zone and Weather.getOverrides()[zone.id]
    if (override and override.kind == "rain") then
        Weather.setOverride({ zone.id }, nil)
    end
end

-- Kept through a restart: every 30 seconds and after each change
local function encodeSaved()
    local parts, now = { "m" }, os.time()
    for _, a in ipairs(getActive()) do
        local species = WildLegendaries.getSpecies(a.name)
        if (species and isMonster(a.cid)) then
            local pos = getCreaturePosition(a.cid)
            local flags = a.flags:gsub("[dz]", "")
            if (monNumber(a.cid, MON.DISGUISED) == 1) then
                flags = flags .. "d"
            end
            if (monNumber(a.cid, MON.ASLEEP) == 1) then
                flags = flags .. "z"
            end
            local health = monNumber(a.cid, MON.DISGUISED) == 1 and 100 or healthPercent(a.cid)
            parts[#parts + 1] = string.format("%d=%d|%d|%d,%d,%d|%d|%s", a.encounter, species.index, health,
                pos.x, pos.y, pos.z, math.max(1, math.ceil((monNumber(a.cid, MON.ENDS_AT) - now) / 60)), flags)
        end
    end
    -- one in the air comes back where it was going
    for encounter, f in pairs(getFlights()) do
        parts[#parts + 1] = string.format("%d=%d|%d|%d,%d,%d|%d|%s", encounter, f.species.index, f.health,
            f.to.x, f.to.y, f.to.z, math.max(1, math.ceil((f.endsAt - now) / 60)), f.flags)
    end
    return table.concat(parts, ";")
end

function WildLegendaries.save()
    local value = encodeSaved()
    if (#value > 255) then
        print("> Legendary: too many out to keep across a restart; the last ones are left out.")
        value = value:sub(1, 255):gsub(";[^;]*$", "")
    end
    if (value ~= getStorage(KEY.SAVED)) then
        store(KEY.SAVED, value)
    end
end

local function trailOf(cid)
    local trail, now = {}, os.time()
    for x, y, z, at in tostring(monText(cid, MON.TRAIL) or ""):gmatch("(%d+),(%d+),(%d+),(%d+)") do
        if (now - tonumber(at) <= CONFIG.trailSeconds) then
            trail[#trail + 1] = { x = tonumber(x), y = tonumber(y), z = tonumber(z), at = tonumber(at) }
        end
    end
    return trail
end
WildLegendaries.trailOf = trailOf

local function pathOf(cid)
    local path = {}
    for zone in tostring(monText(cid, MON.PATH) or ""):gmatch("[^>]+") do
        path[#path + 1] = zone
    end
    return path
end
WildLegendaries.pathOf = pathOf

-- Marks on the last stretch of the way from `from` to `to` on one floor, nearest `to` first
local function routeMarks(from, to)
    local marks, d = {}, distance(from, to)
    if (from.z ~= to.z or d < 2 * CONFIG.routeSpacing) then
        return marks
    end
    for back = CONFIG.routeSpacing, math.min(CONFIG.routeLength, d - CONFIG.routeSpacing), CONFIG.routeSpacing do
        local t = (d - back) / d
        marks[#marks + 1] = { x = math.floor(from.x + (to.x - from.x) * t + 0.5),
                              y = math.floor(from.y + (to.y - from.y) * t + 0.5), z = to.z }
    end
    return marks
end
WildLegendaries.routeMarks = routeMarks

-- Records where it was, the way it came (travelled: it walked, flew or swam there) and the zone it is in now
local function arrive(cid, species, from, pos, point, travelled)
    local now = os.time()
    if (from) then
        local parts = {}
        for _, mark in ipairs(travelled and routeMarks(from, pos) or {}) do
            parts[#parts + 1] = string.format("%d,%d,%d,%d", mark.x, mark.y, mark.z, now)
        end
        parts[#parts + 1] = string.format("%d,%d,%d,%d", from.x, from.y, from.z, now)
        for _, spot in ipairs(trailOf(cid)) do
            if (#parts < CONFIG.trailLength) then
                parts[#parts + 1] = string.format("%d,%d,%d,%d", spot.x, spot.y, spot.z, spot.at)
            end
        end
        -- a letter first: getCreatureStorage reads "123,..." as the number 123
        doCreatureSetStorage(cid, MON.TRAIL, "t;" .. table.concat(parts, ";"))
    end
    local area, zone
    if (point) then
        area, zone = point.area, point.zone
    else
        area, zone = WildLegendaries.areaAt(pos)
    end
    doCreatureSetStorage(cid, MON.AREA, area)
    if (zone) then
        local path = pathOf(cid)
        if (path[#path] ~= zone) then
            path[#path + 1] = zone
            while (#path > 4) do
                table.remove(path, 1)
            end
            doCreatureSetStorage(cid, MON.PATH, table.concat(path, ">"))
        end
        doCreatureSetStorage(cid, MON.ZONE, zone)
    end
    doCreatureSetStorage(cid, MON.MOVED_AT, now)
    local nextZone = planZone(species, zone)
    doCreatureSetStorage(cid, MON.NEXT_ZONE, nextZone or "-")
    return area, zone
end

local function register(cid)
    registerCreatureEvent(cid, "wildLegendaryHit")
    registerCreatureEvent(cid, "wildLegendaryDeath")
end

local function createAt(name, pos)
    WildLegendaries.creating = true
    local cid = doCreateMonster(name, pos, false)
    WildLegendaries.creating = false
    return isMonster(cid) and cid or nil
end

local function announceSpawn(species, area, asleep)
    if (species.tier == 3) then
        if (species.style == "disguise") then
            return "Mew is hiding somewhere, disguised as a wild Pokemon. Trainers who find it will see its true self!"
        elseif (species.shower) then
            return string.format("A meteor shower lights up the sky... %s came down with it somewhere. Look for falling stars!",
                species.name)
        elseif (species.impact) then
            return string.format("A meteor struck somewhere! Something came with it: %s is out there. Look for its signs!",
                species.name)
        end
        return string.format("Something mythical has arrived: %s is out there somewhere. Look for its signs!", species.name)
    elseif (asleep) then
        return string.format("%s is sleeping somewhere near %s. Find it and wake it up! Recommended for trainers level %d+.",
            species.name, area, CONFIG.recommendedLevel)
    end
    return string.format("A wild %s has appeared near %s! Recommended for trainers level %d+.", species.name, area,
        CONFIG.recommendedLevel)
end

-- Mew as a Pokemon of its spot. options as for spawn.
local function spawnDisguised(species, pos, point, source, options)
    options = options or {}
    point = point or WildLegendaries.nearestPoint(pos, 40)
    local disguise = options.disguise or (point and point.spawn)
    if (not disguise or not getMonsterInfo(disguise) or WildLegendaries.getSpecies(disguise)) then
        disguise = "Oddish"
    end
    local cid = createAt(disguise, pos)
    if (not cid) then
        return nil, "The disguise could not be placed."
    end
    -- the level of the others of its kind around it
    for _, other in ipairs(getSpectators(getCreaturePosition(cid), 12, 12, false) or {}) do
        if (other ~= cid and isMonster(other) and getCreatureName(other) == disguise and not isSummon(other)) then
            setMonsterLevel(cid, getMonsterLevel(other))
            break
        end
    end
    return cid, disguise
end

-- Creates the legendary. pos/area optional (staff "here"). options: set (a set member), quiet (no
-- announcement), encounter + health + endsAt + restored (put back after a restart), asleep (false: a
-- Regi awake), disguised (false: Mew as itself), warned (the warning is over). Returns cid or nil, error.
function WildLegendaries.spawn(species, pos, area, source, options)
    options = options or {}
    local givenArea = options.area or area
    if (isOut(species.name)) then
        return nil, species.name .. " is already out."
    end
    if (species.tier == 3 and mythicalOut(species.name)) then
        return nil, "A mythical is already out (" .. mythicalOut(species.name) .. ")."
    end
    if (not options.warned and getPending()[species.name]) then
        setPending(species.name, nil)
    end

    local explicit, point = pos ~= nil, nil
    if (not pos) then
        pos, point = WildLegendaries.pickPoint(species)
        if (not pos) then
            return nil, "No free point found for " .. species.name .. "."
        end
    end

    local disguised = species.style == "disguise" and options.disguised ~= false
    local cid, disguise
    for try = 1, 6 do
        if (disguised) then
            cid, disguise = spawnDisguised(species, pos, point, source, options)
        else
            cid = createAt(species.name, pos)
        end
        if (cid or explicit) then
            break
        end
        pos, point = WildLegendaries.pickPoint(species)
        if (not pos) then
            break
        end
    end
    if (not cid) then
        return nil, disguise or "The monster could not be placed."
    end

    local now = os.time()
    local encounter = options.encounter
    if (not encounter) then
        encounter = math.max(0, getNumber(KEY.SEQUENCE)) + 1
        store(KEY.SEQUENCE, encounter)
    end
    local asleep = species.style == "sleep" and options.asleep ~= false
    local endsAt = options.endsAt or (now + (asleep and CONFIG.sleepLifetime or lifetimeOf(species)))

    if (not disguised) then
        boostHealth(cid, species, options.health)
    end
    doCreatureSetStorage(cid, MON.ENCOUNTER, encounter)
    doCreatureSetStorage(cid, MON.SPAWNED_AT, now)
    doCreatureSetStorage(cid, MON.ENDS_AT, endsAt)
    doCreatureSetStorage(cid, MON.NEXT_MOVE, now + nextMoveDelay(species))
    doCreatureSetStorage(cid, MON.FLEE_STAGE, 0)
    doCreatureSetStorage(cid, MON.FLEE_PENDING, 0)
    doCreatureSetStorage(cid, MON.LAST_HIT, 0)
    doCreatureSetStorage(cid, MON.LAST_SIGN, 0)
    doCreatureSetStorage(cid, MON.ASLEEP, asleep and 1 or 0)
    doCreatureSetStorage(cid, MON.DISGUISED, disguised and 1 or 0)
    local here = getCreaturePosition(cid)
    local zone
    area, zone = arrive(cid, species, nil, here, (not explicit) and point or nil)
    if (explicit and givenArea) then
        area = givenArea
        doCreatureSetStorage(cid, MON.AREA, area)
    end
    doCreatureSetStorage(cid, MON.HOME_ZONE, options.homeZone or zone or "-")
    if (asleep) then
        doCreatureSetNoMove(cid, true)
    end
    register(cid)
    local flags = (options.set and "s" or "") .. (disguised and "d" or "")
    setActive(encounter, cid, species.name, flags)

    if (not options.restored) then
        if (species.impact) then
            impact(here, species.arrive)
        else
            for _, effect in ipairs(species.arrive or { (STYLE_TEXT[species.style] or {}).land or EFFECT_TELEPORT_DOWN }) do
                effectAt(here, effect)
            end
        end
        if (species.quake) then
            shakeAround(here)
        end
        if (species.shower) then
            startShower(here)
        end
    end
    applyWeather(cid, species, monText(cid, MON.HOME_ZONE))

    if (not options.restored) then
        if (not options.quiet) then
            broadcast(announceSpawn(species, area, asleep))
        end
        sendCard(allPlayers(), { type = "spawn", species = species.name, tier = species.tier,
            area = species.tier < 3 and area or nil, level = CONFIG.recommendedLevel, endsAt = endsAt })
        local where = species.tier < 3
        if (options.set) then
            -- one Discord post for the whole set (spawnSet)
            options.member = { encounterId = encounter, species = species.name, tier = species.tier,
                area = where and area or nil, position = where and here or nil, endsAt = (not asleep) and endsAt or nil }
        elseif (not disguised) then
            -- Mew hiding as another Pokemon is posted when a trainer finds it ("revealed")
            discord({ event = "spawn", encounterId = encounter, species = species.name, tier = species.tier,
                area = where and area or nil, position = where and here or nil, endsAt = (not asleep) and endsAt or nil,
                source = source or "schedule", level = CONFIG.recommendedLevel, asleep = asleep or nil,
                health = getCreatureMaxHealth(cid) })
        end
    end
    print(string.format("> Legendary: %s #%d near %s (%d, %d, %d), %s%s%s%s", species.name, encounter, tostring(area),
        here.x, here.y, here.z, source or "schedule", options.restored and ", restored" or "",
        disguised and (", disguised as " .. tostring(disguise)) or "", asleep and ", asleep" or ""))
    WildLegendaries.save()
    return cid, area
end

-- The whole set at once (a member already out is skipped). Returns the cids and the announcement.
function WildLegendaries.spawnSet(set, source)
    local cooldowns, now = WildLegendaries.getCooldowns(), os.time()
    local spawned, parts, members = {}, {}, {}
    for _, name in ipairs(set.members) do
        local species = WildLegendaries.getSpecies(name)
        if (species and not isOut(name) and (CONFIG.setBringsCooldown or (cooldowns[name] or 0) <= now)) then
            local options = { set = true, quiet = true }
            local cid, area = WildLegendaries.spawn(species, nil, nil, source, options)
            if (cid) then
                spawned[#spawned + 1] = cid
                parts[#parts + 1] = name .. " near " .. tostring(area)
                members[#members + 1] = options.member
            end
        end
    end
    if (#spawned == 0) then
        return spawned, nil
    end
    local list = #parts > 1 and (table.concat(parts, ", ", 1, #parts - 1) .. " and " .. parts[#parts]) or parts[1]
    local text
    if (set.id == "regis") then
        text = string.format("%s are sleeping across the land: %s. Find them and wake them up! Recommended for trainers level %d+.",
            set.name, list, CONFIG.recommendedLevel)
    else
        text = string.format("%s have appeared together! %s. Recommended for trainers level %d+.", set.name, list,
            CONFIG.recommendedLevel)
    end
    broadcast(text)
    discord({ event = "set", species = set.name, setId = set.id, setName = set.name, members = members,
        asleep = set.id == "regis" or nil, level = CONFIG.recommendedLevel, source = source or "schedule", text = text })
    return spawned, text
end

-- Mewtwo's psychic disturbance, then the spawn at that point. pos optional (staff "here").
function WildLegendaries.warn(species, source, pos)
    if (isOut(species.name)) then
        return false, species.name .. " is already out."
    end
    local point
    if (pos) then
        point = WildLegendaries.nearestPoint(pos)
    else
        local _
        _, point = WildLegendaries.pickPoint(species)
    end
    if (not point) then
        return false, "No free point found for " .. species.name .. "."
    end
    setPending(species.name, os.time() + CONFIG.warningSeconds, point.index, source)
    local text = string.format("A strange psychic disturbance is building near %s... something powerful is coming.", point.area)
    broadcast(text)
    discord({ event = "sign", species = species.name, area = point.area, endsAt = os.time() + CONFIG.warningSeconds,
        text = text })
    toChannel(string.format("The disturbance near %s grows stronger. It will break in about %d minutes.", point.area,
        math.ceil(CONFIG.warningSeconds / 60)))
    return true, point.area
end

local function departEffects(species, from, to, hop)
    local style = STYLE_TEXT[species.style] or {}
    if (species.depart) then
        effectAt(from, species.depart)
        for _, effect in ipairs(species.arrive or {}) do
            effectAt(to, effect)
        end
    elseif (hop or not style.depart) then
        effectAt(from, EFFECT_TELEPORT_UP)
        effectAt(to, EFFECT_TELEPORT_DOWN)
    else
        effectAt(from, style.depart)
        effectAt(to, style.land)
    end
    effectAt(from, pick(species.signs))
end

-- Where it goes next, by its style: pos, point (nil for short hops), hop
local function destination(cid, species, reason)
    local from = getCreaturePosition(cid)
    local style = species.style
    local zone = monText(cid, MON.ZONE)
    local planned = monText(cid, MON.NEXT_ZONE)
    planned = planned ~= "-" and planned or nil
    if (style == "sleep") then
        return nil
    elseif (style == "cave" or style == "meteor") then
        if (style == "meteor" and reason ~= "flee") then
            return nil
        end
        local pos = hopFrom(from, reason == "flee" and 4 or 6, reason == "flee" and 8 or 12, cid)
        return pos, nil, true
    elseif (style == "territory") then
        local home = monText(cid, MON.HOME_ZONE)
        return WildLegendaries.pickPoint(species, { cid = cid, from = from, minDistance = 15,
            zones = (home and home ~= "-") and { [home] = true } or nil })
    elseif (style == "teleport" or style == "disguise") then
        local zones = { [zone or ""] = true }
        for _, other in ipairs((LEGENDARY_ANCHORS.NEIGHBORS or {})[zone or ""] or {}) do
            zones[other] = true
        end
        local pos, point = WildLegendaries.pickPoint(species, { cid = cid, from = from, minDistance = 15, zones = zones })
        return pos, point, true
    elseif (style == "roam") then
        local pos, point
        if (planned) then
            pos, point = WildLegendaries.pickPoint(species, { cid = cid, from = from, minDistance = 15, zones = { [planned] = true } })
        end
        if (not pos) then
            pos, point = WildLegendaries.pickPoint(species, { cid = cid, from = from, minDistance = 15, zones = { [zone or ""] = true } })
        end
        return pos, point
    end
    -- fly and sea
    local minDistance = style == "sea" and 60 or CONFIG.minMoveDistance
    local pos, point
    if (planned) then
        pos, point = WildLegendaries.pickPoint(species, { cid = cid, from = from, minDistance = 30, zones = { [planned] = true } })
    end
    if (not pos) then
        pos, point = WildLegendaries.pickPoint(species, { cid = cid, from = from, minDistance = minDistance })
    end
    if (not pos) then
        pos, point = WildLegendaries.pickPoint(species, { cid = cid })
    end
    return pos, point
end

-- Flights ----------------------------------------------------------------------------------------

-- What the flights carry that the storage can't (trail, path, home zone, who was sent it), kept in the
-- Lua state that runs them; a flight landed by another state lands without its trail.
local flying = {}

local function travelKind(species)
    if (species.style == "fly") then
        return "a"
    elseif (species.dive) then
        return "w"
    end
    return nil
end

-- Where a dive from `from` toward `to` first reaches the shore, in the same zone as `to`: its shape only
-- shows over sea, so it comes up where trainers last saw it instead of somewhere inland. Nil when there's none.
local function landfall(from, to, cid)
    if (from.z ~= to.z) then
        return nil
    end
    local _, zone = WildLegendaries.areaAt(to)
    local steps = distance(from, to)
    local wet = false
    for i = 1, steps - 1 do
        local pos = { x = math.floor(from.x + (to.x - from.x) * i / steps + 0.5),
                      y = math.floor(from.y + (to.y - from.y) * i / steps + 0.5), z = from.z }
        local ground = getTileThingByPos({ x = pos.x, y = pos.y, z = pos.z, stackpos = STACKPOS_GROUND })
        if (ground and ground.itemid and ground.itemid ~= 0) then
            if (WATER[ground.itemid]) then
                wet = true
            elseif (wet) then
                wet = false
                if (i >= CONFIG.landfallMin and select(2, WildLegendaries.areaAt(pos)) == zone) then
                    local spot = spotAt(pos, cid)
                    if (spot) then
                        return spot
                    end
                end
            end
        end
    end
    return nil
end
WildLegendaries.landfall = landfall

local function flightSeconds(species, kind, from, to)
    local speed = kind == "w" and CONFIG.swimSpeed or (species.fast and CONFIG.fastFlightSpeed or CONFIG.flightSpeed)
    local d = math.sqrt((to.x - from.x) ^ 2 + (to.y - from.y) ^ 2)
    return math.max(CONFIG.flightSeconds[1], math.min(CONFIG.flightSeconds[2], math.ceil(d / speed)))
end

local function flightData(f, now)
    return { type = "flight", id = f.encounter, species = f.species.name, look = getLook(f.species.name),
             kind = f.kind == "w" and "dive" or "fly", from = f.from, to = f.to, elapsed = now - f.start,
             seconds = f.seconds, circle = f.kind == "a" and CONFIG.circleSeconds or 0 }
end

-- Sends the flight to the trainers near where it is now that haven't had it
local function showFlight(f, now, memo)
    local pos = flightAt(f, now)
    local fresh = {}
    for _, pid in ipairs(playersNear(pos, CONFIG.flightView[1], CONFIG.flightView[2])) do
        if (not memo.sent[pid]) then
            memo.sent[pid] = true
            fresh[#fresh + 1] = pid
        end
    end
    if (#fresh > 0) then
        sendFlightData(fresh, flightData(f, now))
    end
end

-- Takes it off the map toward pos. Returns the flight, or nil when it can't go (it moves the old way).
local function takeoff(cid, species, pos, reason)
    local kind = travelKind(species)
    local entry = activeOf(cid)
    if (not kind or not entry) then
        return nil
    end
    local from, now = getCreaturePosition(cid), os.time()
    if (kind == "w") then
        pos = landfall(from, pos, cid) or pos
    end
    local flags = entry.flags:gsub("f", "")
    local f = { encounter = entry.encounter, species = species, health = healthPercent(cid), from = from, to = pos,
                start = now, seconds = flightSeconds(species, kind, from, pos), endsAt = monNumber(cid, MON.ENDS_AT),
                flags = flags, stage = math.max(0, monNumber(cid, MON.FLEE_STAGE)), kind = kind }
    if (not setFlight(entry.encounter, f)) then
        return nil
    end
    local memo = { trail = monText(cid, MON.TRAIL), path = monText(cid, MON.PATH), homeZone = monText(cid, MON.HOME_ZONE),
                   area = monText(cid, MON.AREA), zone = monText(cid, MON.ZONE), sent = {}, sightingAt = now,
                   signAt = now, reason = reason }
    flying[entry.encounter] = memo
    effectAt(from, kind == "a" and ((STYLE_TEXT[species.style] or {}).depart or EFFECT_LEGENDARY_TAKEOFF)
        or EFFECT_LEGENDARY_WATER_RIPPLE)
    effectAt(from, pick(species.signs))
    setActive(entry.encounter, 0, species.name, flags .. "f")
    doRemoveCreature(cid)
    showFlight(f, now, memo)
    return f, memo
end
WildLegendaries.takeoff = takeoff

-- Moves the legendary on. Returns the area, or nil and the flight when it took off.
local function relocate(cid, species, reason)
    local from = getCreaturePosition(cid)
    for try = 1, 4 do
        local pos, point, hop = destination(cid, species, reason)
        if (not pos) then
            return nil
        end
        if (not hop) then
            local f = takeoff(cid, species, pos, reason)
            if (f) then
                return nil, f
            end
        end
        doTeleportThing(cid, pos, false)
        if (getSamePosition(getCreaturePosition(cid), pos)) then
            departEffects(species, from, pos, hop)
            if (species.quake) then
                shakeAround(pos)
            end
            if (hop and not point) then
                -- a short hop keeps its area and zone
                doCreatureSetStorage(cid, MON.MOVED_AT, os.time())
                return monText(cid, MON.AREA) or WildLegendaries.areaAt(pos)
            end
            return (arrive(cid, species, from, pos, point, not hop))
        end
    end
    return nil
end

local function announceTakeoff(species, f, memo, reason)
    local heading = directionTo(f.from, f.to)
    local mythical = species.tier == 3
    local where = memo.area or "?"
    if (reason == "flee") then
        local how = f.kind == "w" and "dived into the sea" or "took to the sky"
        broadcast(string.format("%s is hurt and %s, heading %s! It has %d%% health left.", species.name, how, heading, f.health))
        sendCard(allPlayers(), { type = "flee", species = species.name, health = f.health })
        discord({ event = "flee", encounterId = f.encounter, species = species.name,
            area = (not mythical) and where or nil, healthPercent = f.health })
    elseif (not mythical) then
        local trainer, town = seenBy(f.from)
        if (trainer or town) then
            local text = seenText(trainer, town, species, f.kind == "w" and "diving near" or "taking off from", where)
            toChannel((text:gsub("%.$", ", heading " .. heading .. ".")))
        end
    end
end

-- Puts it back on the map where the flight ends
local function land(f, now)
    local memo = flying[f.encounter] or {}
    flying[f.encounter] = nil
    setFlight(f.encounter, nil)
    setActive(f.encounter, nil)
    local species = f.species
    local options = { encounter = f.encounter, health = f.health, endsAt = f.endsAt, restored = true, quiet = true,
                      set = f.flags:find("s") ~= nil, homeZone = (memo.homeZone and memo.homeZone ~= "-") and memo.homeZone or nil }
    local cid = WildLegendaries.spawn(species, f.to, nil, "flight", options)
    if (not cid) then
        cid = WildLegendaries.spawn(species, nil, nil, "flight", options)
    end
    if (not cid) then
        discord({ event = "end", reason = "vanished", encounterId = f.encounter, species = species.name })
        WildLegendaries.save()
        return nil
    end
    if (memo.trail) then
        doCreatureSetStorage(cid, MON.TRAIL, memo.trail)
    end
    if (memo.path) then
        doCreatureSetStorage(cid, MON.PATH, memo.path)
    end
    doCreatureSetStorage(cid, MON.FLEE_STAGE, f.stage)
    local here = getCreaturePosition(cid)
    local area = arrive(cid, species, f.from, here, nil, true)
    if (f.kind == "a") then
        effectAt(here, (STYLE_TEXT[species.style] or {}).land or EFFECT_LEGENDARY_LANDING)
    else
        for _, effect in ipairs(species.arrive or { EFFECT_WATER_SPLASH }) do
            effectAt(here, effect)
        end
    end
    effectAt(here, pick(species.signs))
    local mythical = species.tier == 3
    if (memo.reason == "flee") then
        broadcast(string.format("%s came down near %s with %d%% health.", species.name, mythical and "somewhere" or area,
            healthPercent(cid)))
    end
    local trainer, town = seenBy(here)
    if (memo.reason == "flee" or trainer or town) then
        if (memo.reason ~= "flee" and not mythical) then
            toChannel(seenText(trainer, town, species, f.kind == "w" and "surfacing near" or "landing near", area))
            sendCard(channelPlayers(), { type = "sighting", species = species.name, area = area })
        end
        discord({ event = "sighting", encounterId = f.encounter, species = species.name, area = (not mythical) and area or nil,
            position = (not mythical) and here or nil, trainer = trainer, healthPercent = healthPercent(cid) })
    end
    WildLegendaries.save()
    return cid
end
WildLegendaries.land = land

-- Every second: who sees each flight, its signs below it, the zones it crosses, and the landing
function WildLegendaries.runFlights(now)
    now = now or os.time()
    for encounter, f in pairs(getFlights()) do
        local memo = flying[encounter]
        if (not memo) then
            memo = { sent = {}, sightingAt = 0, signAt = 0 }
            flying[encounter] = memo
        end
        if (now >= landsAt(f)) then
            land(f, now)
        else
            showFlight(f, now, memo)
            local pos, progress = flightAt(f, now)
            if (now - memo.signAt >= CONFIG.flightSignEvery) then
                memo.signAt = now
                effectAt(pos, f.kind == "w" and EFFECT_LEGENDARY_WATER_RIPPLE or pick(f.species.signs))
            end
            -- once per zone, when a trainer under it or the town sees it go over
            local zone = Weather.zoneAt(pos)
            local overTown = zone and zone.pos and distance(zone.pos, pos) <= CONFIG.townSightRange
            local watchers = playersNear(pos, CONFIG.flightView[1], CONFIG.flightView[2])
            local watcher = watchers[1] and getCreatureName(watchers[1])
            if (f.kind == "a" and progress < 1 and zone and zone.name ~= memo.zone and (watcher or overTown) and
                    now - memo.sightingAt >= CONFIG.flightSightingEvery) then
                memo.zone, memo.sightingAt = zone.name, now
                if (f.species.tier < 3) then
                    local text = seenText(watcher, zone.name, f.species, "flying over", zone.name)
                    toChannel((text:gsub("%.$", ", heading " .. directionTo(f.from, f.to) .. ".")))
                    sendCard(channelPlayers(), { type = "sighting", species = f.species.name, area = zone.name })
                end
            end
        end
    end
end

-- Ends a flight without landing: reason "staff", "restart" or "fled" (the cooldown starts)
function WildLegendaries.endFlight(encounter, reason)
    local f = getFlights()[encounter]
    if (not f) then
        return false
    end
    local memo = flying[encounter] or {}
    flying[encounter] = nil
    setFlight(encounter, nil)
    setActive(encounter, nil)
    local species = f.species
    if (reason == "fled") then
        WildLegendaries.setCooldown(species.name, os.time() + WildLegendaries.cooldownFor(species))
    end
    if (species.rain) then
        local zone = weatherZone(memo.homeZone or "")
        local override = zone and Weather.getOverrides()[zone.id]
        if (override and override.kind == "rain") then
            Weather.setOverride({ zone.id }, nil)
        end
    end
    if (reason ~= "restart") then
        local leave = species.leave or (STYLE_TEXT[species.style] or {}).leave or "left"
        broadcast(string.format("The wild %s %s.", species.name, leave))
        sendCard(allPlayers(), { type = "end", reason = reason, species = species.name })
    end
    discord({ event = "end", reason = reason, encounterId = encounter, species = species.name })
    WildLegendaries.save()
    return true
end

-- A fly-over only this trainer sees, across their screen (staff check the drawing without a spawn)
function WildLegendaries.flyover(pid, name, kind)
    local species = WildLegendaries.getSpecies(name)
    if (not species) then
        return false
    end
    local pos = getCreaturePosition(pid)
    local f = { encounter = 0, species = species, from = { x = pos.x - 14, y = pos.y + 3, z = pos.z },
                to = { x = pos.x + 14, y = pos.y - 3, z = pos.z }, start = os.time(), seconds = 6,
                kind = kind == "dive" and "w" or "a" }
    sendFlightData({ pid }, flightData(f, f.start))
    return true
end

function WildLegendaries.move(cid, reason)
    local entry = activeOf(cid)
    local species = WildLegendaries.getSpecies(entry and entry.name or getCreatureName(cid))
    if (not species or monNumber(cid, MON.DISGUISED) == 1) then
        return false
    end
    doCreatureSetStorage(cid, MON.NEXT_MOVE, os.time() + nextMoveDelay(species, cid))
    local area, f = relocate(cid, species, reason)
    if (f) then
        announceTakeoff(species, f, flying[f.encounter] or {}, reason)
        WildLegendaries.save()
        return true
    end
    if (not area) then
        return false
    end
    local encounter = monNumber(cid, MON.ENCOUNTER)
    local mythical = species.tier == 3
    local trainer, town = seenBy(getCreaturePosition(cid))
    if (reason ~= "flee" and not trainer and not town) then
        WildLegendaries.save()
        return true
    end
    if (reason == "flee") then
        if (mythical) then
            broadcast(string.format("%s is hurt and vanished! It has %d%% health left.", species.name, healthPercent(cid)))
        else
            broadcast(string.format("%s is hurt and fled! It was last seen near %s with %d%% health.",
                species.name, area, healthPercent(cid)))
        end
        sendCard(allPlayers(), { type = "flee", species = species.name, area = (not mythical) and area or nil,
            health = healthPercent(cid) })
    elseif (not mythical) then
        toChannel(seenText(trainer, town, species, "near", area))
        sendCard(channelPlayers(), { type = "sighting", species = species.name, area = area })
    end
    discord({ event = reason == "flee" and "flee" or "sighting", encounterId = encounter, species = species.name,
        area = (not mythical) and area or nil, position = (not mythical) and getCreaturePosition(cid) or nil,
        trainer = reason ~= "flee" and trainer or nil, healthPercent = healthPercent(cid) })
    WildLegendaries.save()
    return true
end

-- Staff: the globalevent moves it on within a second
function WildLegendaries.requestMove(cid)
    if (not WildLegendaries.isEncounter(cid)) then
        return false
    end
    doCreatureSetStorage(cid, MON.MOVE_PENDING, 1)
    return true
end

-- Ends an encounter that is still alive: reason "fled" (time up), "staff" or "restart".
-- Only "fled" starts the cooldown.
function WildLegendaries.finish(cid, reason)
    local entry = activeOf(cid)
    local name = entry and entry.name or getCreatureName(cid)
    local species = WildLegendaries.getSpecies(name)
    local encounter = monNumber(cid, MON.ENCOUNTER)
    local area = monText(cid, MON.AREA)
    setActive(encounter, nil)
    if (reason == "fled" and species) then
        WildLegendaries.setCooldown(species.name, os.time() + WildLegendaries.cooldownFor(species))
    end
    clearWeather(cid, species)
    effectAt(getCreaturePosition(cid), EFFECT_TELEPORT_UP)
    doRemoveCreature(cid)
    if (reason ~= "restart") then
        local leave = (species and species.leave) or (STYLE_TEXT[species and species.style or "fly"] or {}).leave or "left"
        local where = (area and species and species.tier < 3) and (" from " .. area) or ""
        broadcast(string.format("The wild %s %s%s.", name, leave, where))
        sendCard(allPlayers(), { type = "end", reason = reason, species = name })
    end
    discord({ event = "end", reason = reason, encounterId = encounter, species = name })
    WildLegendaries.save()
end

-- Mew shows its true self where its disguise stood. by: who found it.
function WildLegendaries.reveal(cid, by)
    local entry = activeOf(cid)
    if (not entry or monNumber(cid, MON.DISGUISED) ~= 1) then
        return nil, "That is not Mew in disguise."
    end
    local species = WildLegendaries.getSpecies(entry.name)
    local pos, disguise = getCreaturePosition(cid), getCreatureName(cid)
    local encounter, endsAt = entry.encounter, monNumber(cid, MON.ENDS_AT)
    local trail, path = monText(cid, MON.TRAIL), monText(cid, MON.PATH)
    setActive(encounter, nil)
    doRemoveCreature(cid)
    local mew = WildLegendaries.spawn(species, pos, nil, "reveal", { encounter = encounter, disguised = false, quiet = true,
        restored = true, endsAt = math.max(endsAt, os.time() + 20 * MINUTE) })
    if (not mew) then
        discord({ event = "end", reason = "vanished", encounterId = encounter, species = species.name })
        WildLegendaries.save()
        return nil, "Mew could not be placed."
    end
    if (trail) then
        doCreatureSetStorage(mew, MON.TRAIL, trail)
    end
    if (path) then
        doCreatureSetStorage(mew, MON.PATH, path)
    end
    effectAt(getCreaturePosition(mew), EFFECT_LEGENDARY_MEW_REVEAL)
    effectAt(getCreaturePosition(mew), EFFECT_BIG_PINK_CLOUD)
    broadcast(string.format("%s found Mew hiding as a wild %s! It shows its true self.", by or "A trainer", disguise))
    sendCard(allPlayers(), { type = "sighting", species = species.name })
    local area = WildLegendaries.areaAt(getCreaturePosition(mew))
    discord({ event = "revealed", encounterId = encounter, species = species.name, trainer = by, disguise = disguise,
        tier = species.tier, area = species.tier < 3 and area or nil, level = CONFIG.recommendedLevel,
        endsAt = monNumber(mew, MON.ENDS_AT), healthPercent = 100 })
    return mew
end

-- A Regi wakes up and can be fought; it stays where it slept.
function WildLegendaries.wake(cid, by)
    local entry = activeOf(cid)
    if (not entry or monNumber(cid, MON.ASLEEP) ~= 1) then
        return false, "That one is not asleep."
    end
    doCreatureSetStorage(cid, MON.ASLEEP, 0)
    doCreatureSetStorage(cid, MON.WAKE_PENDING, 0)
    doCreatureSetStorage(cid, MON.ENDS_AT, os.time() + CONFIG.wakeLifetime)
    doCreatureSetNoMove(cid, false)
    local species = WildLegendaries.getSpecies(entry.name)
    effectAt(getCreaturePosition(cid), pick(species and species.signs))
    effectAt(getCreaturePosition(cid), EFFECT_BIG_ROCK_EMERGE)
    local area = monText(cid, MON.AREA) or "?"
    broadcast(string.format("%s woke %s up near %s! Recommended for trainers level %d+.", by or "A trainer", entry.name,
        area, CONFIG.recommendedLevel))
    discord({ event = "woke", encounterId = entry.encounter, species = entry.name, trainer = by, area = area,
        position = getCreaturePosition(cid), healthPercent = healthPercent(cid), level = CONFIG.recommendedLevel })
    WildLegendaries.save()
    return true
end

-- Species that may spawn now on the schedule, with their weights.
function WildLegendaries.eligible(now)
    now = now or os.time()
    local alive, major = 0, 0
    local out = {}
    for _, a in ipairs(getActive()) do
        out[a.name] = true
        local s = WildLegendaries.getSpecies(a.name)
        if (not a.flags:find("s")) then
            alive = alive + 1
            if (s and s.tier == 2) then
                major = major + 1
            end
        end
    end
    if (alive >= CONFIG.maxAlive) then
        return {}, "two legendaries are out"
    end
    local pending = getPending()
    local mythical = mythicalOut()
    local cooldowns = WildLegendaries.getCooldowns()
    local list = {}
    for _, species in ipairs(WildLegendaries.SPECIES) do
        if (not out[species.name] and not pending[species.name] and (cooldowns[species.name] or 0) <= now and
                (species.tier ~= 2 or major < CONFIG.maxMajorAlive) and (species.tier ~= 3 or not mythical)) then
            local regionsOn = false
            for _, region in ipairs(species.regions) do
                regionsOn = regionsOn or regionOn(region)
            end
            if (regionsOn) then
                table.insert(list, species)
            end
        end
    end
    return list
end

function WildLegendaries.pickSpecies(list)
    local total = 0
    for _, species in ipairs(list) do
        total = total + CONFIG.tierWeight[species.tier]
    end
    if (total <= 0) then
        return nil
    end
    local roll = getRandom(1, total)
    for _, species in ipairs(list) do
        roll = roll - CONFIG.tierWeight[species.tier]
        if (roll <= 0) then
            return species
        end
    end
    return list[#list]
end

-- Why the scheduled spawn can't happen right now, or nil.
function WildLegendaries.blocked(now)
    if (WildLegendaries.isManual()) then
        return "manual mode: only staff start them"
    end
    local remaining = untilRestart(now)
    if (remaining and remaining < CONFIG.quietBeforeRestart) then
        return "the restart is less than 10 minutes away"
    end
    local list, why = WildLegendaries.eligible(now)
    if (#list == 0) then
        return why or "every legendary that may come is out or on cooldown"
    end
    return nil
end

-- The schedule's spawn: one species, its whole set on the set roll, or Mewtwo's warning
function WildLegendaries.scheduledSpawn(species, source)
    source = source or "schedule"
    if (species.set and getRandom(1, 100) <= CONFIG.setChance) then
        local set = WildLegendaries.getSet(species.set)
        local spawned = WildLegendaries.spawnSet(set, source)
        if (#spawned > 0) then
            return true
        end
    end
    if (species.warning) then
        return (WildLegendaries.warn(species, source))
    end
    return WildLegendaries.spawn(species, nil, nil, source) ~= nil
end

-- Defeat, rewards and catch ----------------------------------------------------------------------

-- Called from the wildLegendaryDeath creature event (corpse is not on the map yet).
function WildLegendaries.onDeath(cid, corpse)
    local entry = activeOf(cid)
    local name = entry and entry.name or getCreatureName(cid)
    local species = WildLegendaries.getSpecies(name)
    local encounter = monNumber(cid, MON.ENCOUNTER)
    local area = monText(cid, MON.AREA)
    local position = getCreaturePosition(cid)
    setActive(encounter, nil)
    if (not species) then
        return
    end
    WildLegendaries.setCooldown(species.name, os.time() + WildLegendaries.cooldownFor(species))
    clearWeather(cid, species)

    local reward = CONFIG.rewards[species.tier]
    local winners, top, topRatio = {}, nil, -1
    for _, pid in ipairs(allPlayers()) do
        local ratio = getCreatureDamageRatioByMaster(cid, pid) or 0
        if (ratio >= CONFIG.rewardRatio) then
            table.insert(winners, getCreatureName(pid))
            doPlayerSafeAddItem(pid, CONFIG.rareCandyId, reward.rareCandy, true, false)
            doPlayerAddMoney(pid, reward.money)
            if (Pokepedia and Pokepedia.onLegendaryDefeated) then
                Pokepedia.onLegendaryDefeated(pid, species.name)
            end
            doPlayerSendTextMessage(pid, MESSAGE_STATUS_CONSOLE_ORANGE, string.format(
                "You dealt %d%% of the damage to %s: %d Rare Cand%s and $%d.", math.floor(ratio * 100 + 0.5),
                species.name, reward.rareCandy, reward.rareCandy == 1 and "y" or "ies", reward.money))
            sendCard({ pid }, { type = "reward", species = species.name, share = math.floor(ratio * 100 + 0.5),
                rareCandy = reward.rareCandy, money = reward.money })
        end
        if (ratio > topRatio and ratio > 0) then
            top, topRatio = pid, ratio
        end
    end

    if (isItem(corpse)) then
        doItemSetAttribute(corpse.uid, "duration", CONFIG.bodySeconds * 1000)
        local owner = getItemAttribute(corpse.uid, "corpseowner")
        local ownerPlayer = owner and getPlayerByGUID(owner)
        if (ownerPlayer and isPlayer(ownerPlayer)) then
            doPlayerSendTextMessage(ownerPlayer, MESSAGE_STATUS_CONSOLE_ORANGE, string.format(
                "You have %d seconds to throw a ball at %s before anyone else can.", CONFIG.bodyOwnerSeconds, species.name))
        end
        addEvent(WildLegendaries.releaseBody, CONFIG.bodyOwnerSeconds * 1000, position, corpse.itemid, species.name)
    end

    local recent = readMap(KEY.RECENT)
    recent[species.name] = os.time() .. ":" .. encounter
    writeMap(KEY.RECENT, recent)

    broadcast(string.format("The wild %s was defeated%s!", species.name,
        #winners > 0 and (" by " .. table.concat(winners, ", ")) or ""))
    sendCard(allPlayers(), { type = "end", reason = "defeated", species = species.name, trainers = winners })
    discord({ event = "end", reason = "defeated", encounterId = encounter, species = species.name,
        area = (species.tier < 3) and area or nil, trainers = #winners > 0 and winners or nil,
        topTrainer = top and getCreatureName(top) or nil })
    WildLegendaries.save()
end

-- After the top damage dealer's window anyone may throw at the body.
function WildLegendaries.releaseBody(position, itemid, name)
    local body = getTileItemById(position, itemid)
    if (isItem(body) and getItemAttribute(body.uid, "pokemon") == name) then
        doItemEraseAttribute(body.uid, "corpseowner")
        local spectators = getSpectators(position, 8, 8, false) or {}
        for _, pid in ipairs(spectators) do
            if (isPlayer(pid)) then
                doPlayerSendTextMessage(pid, MESSAGE_STATUS_CONSOLE_ORANGE,
                    string.format("Anyone can throw a ball at the fainted %s now.", name))
            end
        end
    end
end

-- Every catch of a legendary or mythical is announced, wherever it comes from (from DiscordBridge.onCatch's
-- callers). One defeated in the wild in the last minutes is announced as that encounter's.
function WildLegendaries.onCatch(cid, name)
    local species = WildLegendaries.getSpecies(name)
    if (not species) then
        return
    end
    local trainer = getCreatureName(cid)
    local shiny = tostring(name):lower():find("^shiny ") ~= nil
    local recent = readMap(KEY.RECENT)
    local at, encounter = tostring(recent[species.name] or ""):match("^(%d+):(%d+)$")
    if (at and os.time() - tonumber(at) <= CONFIG.catchWindow) then
        recent[species.name] = nil
        writeMap(KEY.RECENT, recent)
        broadcast(string.format("%s caught the wild %s!", trainer, species.name))
        sendCard(allPlayers(), { type = "caught", species = species.name, trainer = trainer })
        discord({ event = "caught", encounterId = tonumber(encounter), species = species.name, trainer = trainer })
        return
    end
    broadcast(string.format("%s caught a%s %s!", trainer, shiny and " shiny" or "", species.name))
    sendCard(allPlayers(), { type = "caught", species = species.name, trainer = trainer })
end

-- A legendary or mythical given by a quest or an NPC
function WildLegendaries.onReward(cid, name)
    local species = WildLegendaries.getSpecies(name)
    if (species and isPlayer(cid)) then
        local text = string.format("%s received %s as a reward!", getCreatureName(cid), species.name)
        broadcast(text)
        discord({ event = "reward", species = species.name, trainer = getCreatureName(cid), text = text })
    end
end

local function trainerOf(attacker)
    if (not attacker or attacker == 0) then
        return nil
    end
    if (isPlayer(attacker)) then
        return getCreatureName(attacker)
    end
    local master = isCreature(attacker) and getCreatureMaster(attacker)
    if (master and master ~= attacker and isPlayer(master)) then
        return getCreatureName(master)
    end
    return nil
end

-- From the wildLegendaryHit creature event; false blocks the damage (a disguise or a sleeper found)
function WildLegendaries.onHit(cid, value, attacker)
    local now = os.time()
    if (monNumber(cid, MON.DISGUISED) == 1) then
        if (monNumber(cid, MON.REVEAL_PENDING) ~= 1) then
            doCreatureSetStorage(cid, MON.REVEAL_PENDING, 1)
            doCreatureSetStorage(cid, MON.FOUND_BY, trainerOf(attacker) or "A trainer")
        end
        return false
    end
    if (monNumber(cid, MON.ASLEEP) == 1) then
        if (monNumber(cid, MON.WAKE_PENDING) ~= 1) then
            doCreatureSetStorage(cid, MON.WAKE_PENDING, 1)
            doCreatureSetStorage(cid, MON.FOUND_BY, trainerOf(attacker) or "A trainer")
        end
        return false
    end
    doCreatureSetStorage(cid, MON.LAST_HIT, now)
    local entry = activeOf(cid)
    local species = WildLegendaries.getSpecies(entry and entry.name or getCreatureName(cid))
    if (not species or species.style == "sleep") then
        return true
    end
    local stage = math.max(0, monNumber(cid, MON.FLEE_STAGE))
    local threshold = CONFIG.flee[species.tier][stage + 1]
    local left = getCreatureHealth(cid) - value
    if (threshold and left > 0 and left <= getCreatureMaxHealth(cid) * threshold) then
        doCreatureSetStorage(cid, MON.FLEE_STAGE, stage + 1)
        doCreatureSetStorage(cid, MON.FLEE_PENDING, 1)
    end
    return true
end

-- From the radar (another Lua state): the globalevent reveals it within a second
function WildLegendaries.requestReveal(cid, by)
    if (WildLegendaries.isDisguised(cid) and monNumber(cid, MON.REVEAL_PENDING) ~= 1) then
        doCreatureSetStorage(cid, MON.REVEAL_PENDING, 1)
        doCreatureSetStorage(cid, MON.FOUND_BY, by or "A Ranger")
        return true
    end
    return false
end

-- Signs ------------------------------------------------------------------------------------------

local function near(pos, radius)
    return { x = pos.x + getRandom(-radius, radius), y = pos.y + getRandom(-radius, radius), z = pos.z }
end

local function hasGround(pos)
    local ground = getTileThingByPos({ x = pos.x, y = pos.y, z = pos.z, stackpos = STACKPOS_GROUND })
    return ground ~= nil and ground.itemid ~= nil and ground.itemid ~= 0
end

-- The online trainers and where they are
local function trainerPositions()
    local list = {}
    for _, pid in ipairs(getPlayersOnline() or {}) do
        list[#list + 1] = { pid = pid, pos = getCreaturePosition(pid) }
    end
    return list
end

local function trainerNear(trainers, pos, range)
    for _, t in ipairs(trainers) do
        if (t.pos.z == pos.z and distance(t.pos, pos) <= range) then
            return true
        end
    end
    return false
end

-- Its signs around it, and on the marks of its trail a trainer is near (fresh marks each time, older ones now
-- and then); faint ones only around it (mythicals). all: every mark (staff).
function WildLegendaries.showSigns(cid, species, all)
    local pos = getCreaturePosition(cid)
    if (monNumber(cid, MON.DISGUISED) == 1) then
        effectAt(near(pos, 1), pick(species.signs))
        return
    end
    if (monNumber(cid, MON.ASLEEP) == 1) then
        effectAt(pos, EFFECT_SLEEPING)
    end
    effectAt(near(pos, species.tier == 3 and 1 or 3), pick(species.signs))
    if (species.tier < 3 or all) then
        local now, trainers = os.time(), trainerPositions()
        for _, spot in ipairs(trailOf(cid)) do
            if (all or (trainerNear(trainers, spot, CONFIG.trailView) and
                    (now - spot.at < CONFIG.trailSeconds / 2 or getRandom(1, 2) == 1))) then
                effectAt(near(spot, 1), pick(species.signs))
                if (all) then
                    effectAt(near(spot, 2), pick(species.signs))
                end
            end
        end
    end
end

-- Signs leading the trainers around it to it: for each trainer on its floor within areaSignRange but out of
-- sight, now and then one a few tiles from them toward it (scattered), more often the closer they are.
-- Mythicals: half the range, half as often.
local guided, guidedAt = {}, 0

local function guideSigns(cid, species, now)
    if (now - guidedAt >= 10 * MINUTE) then
        guided, guidedAt = {}, now
    end
    local pos = getCreaturePosition(cid)
    local mythical = species.tier == 3
    local range = mythical and math.floor(CONFIG.areaSignRange / 2) or CONFIG.areaSignRange
    local low, high = CONFIG.areaSignEvery[1], CONFIG.areaSignEvery[2]
    local encounter = monNumber(cid, MON.ENCOUNTER)
    for _, t in ipairs(trainerPositions()) do
        local d = distance(t.pos, pos)
        if (t.pos.z == pos.z and d > CONFIG.sightRange[1] and d <= range) then
            local key = t.pid .. ":" .. encounter
            local every = (low + (high - low) * d / range) * (mythical and 2 or 1)
            if (now - (guided[key] or 0) >= every) then
                guided[key] = now
                local along = getRandom(3, 5) / d
                local spot = near({ x = math.floor(t.pos.x + (pos.x - t.pos.x) * along + 0.5),
                                    y = math.floor(t.pos.y + (pos.y - t.pos.y) * along + 0.5), z = pos.z }, 2)
                if (hasGround(spot)) then
                    effectAt(spot, pick(species.signs))
                end
            end
        end
    end
end
WildLegendaries.guideSigns = guideSigns

-- Executor ---------------------------------------------------------------------------------------

local function upkeep(cid, now)
    if (getCreatureHealth(cid) <= 0) then
        return
    end
    local entry = activeOf(cid)
    local species = WildLegendaries.getSpecies(entry and entry.name or getCreatureName(cid))
    if (not species) then
        return
    end
    local disguised, asleep = monNumber(cid, MON.DISGUISED) == 1, monNumber(cid, MON.ASLEEP) == 1
    local every = disguised and CONFIG.disguiseSignEvery or (species.tier == 3 and CONFIG.faintSignEvery or CONFIG.signEvery)
    if (now - monNumber(cid, MON.LAST_SIGN) >= every) then
        doCreatureSetStorage(cid, MON.LAST_SIGN, now)
        WildLegendaries.showSigns(cid, species)
    end
    if (not disguised) then
        guideSigns(cid, species, now)
    end

    if (disguised) then
        if (monNumber(cid, MON.REVEAL_PENDING) == 1) then
            WildLegendaries.reveal(cid, monText(cid, MON.FOUND_BY))
        elseif (now >= monNumber(cid, MON.ENDS_AT)) then
            WildLegendaries.finish(cid, "fled")
        end
        return
    end
    if (asleep) then
        if (monNumber(cid, MON.WAKE_PENDING) == 1) then
            WildLegendaries.wake(cid, monText(cid, MON.FOUND_BY))
        elseif (now >= monNumber(cid, MON.ENDS_AT)) then
            WildLegendaries.finish(cid, "fled")
        end
        return
    end

    if (monNumber(cid, MON.FLEE_PENDING) == 1) then
        doCreatureSetStorage(cid, MON.FLEE_PENDING, 0)
        WildLegendaries.move(cid, "flee")
        return
    end
    if (monNumber(cid, MON.MOVE_PENDING) == 1) then
        doCreatureSetStorage(cid, MON.MOVE_PENDING, 0)
        WildLegendaries.move(cid, "staff")
        return
    end
    local lastHit = monNumber(cid, MON.LAST_HIT)
    if (now >= monNumber(cid, MON.ENDS_AT) and now - lastHit >= CONFIG.stayWhileHit) then
        WildLegendaries.finish(cid, "fled")
        return
    end
    if (now >= monNumber(cid, MON.NEXT_MOVE)) then
        if (now - lastHit < CONFIG.holdWhileHit) then
            doCreatureSetStorage(cid, MON.NEXT_MOVE, now + 30)
        elseif (species.style == "sleep" or species.style == "meteor") then
            doCreatureSetStorage(cid, MON.NEXT_MOVE, now + nextMoveDelay(species, cid))
        else
            WildLegendaries.move(cid, "roam")
        end
        return
    end
    if (now - lastHit >= CONFIG.healAfter and now - monNumber(cid, MON.LAST_HEAL) >= 5) then
        local missing = getCreatureMaxHealth(cid) - getCreatureHealth(cid)
        if (missing > 0) then
            doCreatureSetStorage(cid, MON.LAST_HEAL, now)
            doCreatureAddHealth(cid, math.min(missing, math.ceil(getCreatureMaxHealth(cid) * CONFIG.healPercent / 100)))
            if (getCreatureHealth(cid) >= getCreatureMaxHealth(cid)) then
                doCreatureSetStorage(cid, MON.FLEE_STAGE, 0)
            end
        end
    end
end

-- Closes encounters whose monster is gone (removed by staff tools or a crash).
local function sweep()
    local flights = getFlights()
    for _, active in ipairs(getActive()) do
        local gone
        if (active.flags:find("f")) then
            gone = not flights[active.encounter]
        else
            gone = not isMonster(active.cid) or monNumber(active.cid, MON.ENCOUNTER) ~= active.encounter
        end
        if (gone) then
            setActive(active.encounter, nil)
            discord({ event = "end", reason = "vanished", encounterId = active.encounter, species = active.name })
        end
    end
end

-- After a restart: the ones saved come back where they were, with their health and time left. The
-- others close on the Discord side.
function WildLegendaries.restore()
    local saved, now = readMap(KEY.SAVED), os.time()
    local before = getActive()
    store(KEY.ACTIVE, "m")
    store(KEY.FLIGHTS, "m")
    local back = {}
    for encounter, value in pairs(saved) do
        local index, health, x, y, z, minutes, flags = value:match("^(%d+)|(%d+)|(%d+),(%d+),(%d+)|(%d+)|(%a*)$")
        local species = index and BY_INDEX[tonumber(index)]
        if (species) then
            local pos = { x = tonumber(x), y = tonumber(y), z = tonumber(z) }
            local options = { encounter = tonumber(encounter), health = tonumber(health), restored = true,
                endsAt = now + tonumber(minutes) * 60, set = flags:find("s") ~= nil,
                asleep = flags:find("z") ~= nil, disguised = flags:find("d") ~= nil }
            local cid = WildLegendaries.spawn(species, pos, nil, "restart", options)
            if (not cid) then
                cid = WildLegendaries.spawn(species, nil, nil, "restart", options)
            end
            if (cid) then
                back[tonumber(encounter)] = true
            end
        end
    end
    for _, active in ipairs(before) do
        if (not back[active.encounter]) then
            discord({ event = "end", reason = "restart", encounterId = active.encounter, species = active.name })
        end
    end
    WildLegendaries.save()
    return back
end

local function runPending(now)
    for name, pending in pairs(getPending()) do
        local species = WildLegendaries.getSpecies(name)
        local point = WildLegendaries.getPoints()[pending.point]
        if (not species or not point) then
            setPending(name, nil)
        elseif (now >= pending.at) then
            setPending(name, nil)
            local pos = spotAt(point)
            local cid = WildLegendaries.spawn(species, pos, nil, pending.source, { warned = true, area = point.area })
            if (not cid) then
                WildLegendaries.spawn(species, nil, nil, pending.source, { warned = true })
            end
        else
            local left = pending.at - now
            if (left <= CONFIG.warningFinalSeconds or now % CONFIG.warningEffectEvery == 0) then
                local progress = 1 - math.max(0, math.min(1, left / CONFIG.warningSeconds))
                local low, high = CONFIG.warningBurst[1], CONFIG.warningBurst[2]
                effectAt(point, species.signs[1])
                for i = 1, math.floor(low + (high - low) * progress + 0.5) do
                    effectAt(near(point, CONFIG.warningRadius), pick(species.signs))
                end
                if (left == CONFIG.warningFinalSeconds) then
                    shakeAround(point, 1200)
                end
            end
        end
    end
end

-- Rayquaza: when Groudon and Kyogre are both out it may come down to calm them -------------------

local function encounterOut(name)
    for _, a in ipairs(getActive()) do
        if (a.name == name and (isMonster(a.cid) or a.flags:find("f"))) then
            return a.encounter
        end
    end
    return nil
end

-- Spawns it a little way off and flies it in next to Groudon (or Kyogre). Returns true or nil and why.
function WildLegendaries.callRayquaza(source)
    local species = WildLegendaries.getSpecies("Rayquaza")
    if (isOut(species.name)) then
        return nil, "Rayquaza is already out."
    end
    local target = WildLegendaries.find("Groudon") or WildLegendaries.find("Kyogre")
    if (not target) then
        return nil, "Groudon or Kyogre has to be on the map."
    end
    local near = getCreaturePosition(target)
    local landing = hopFrom(near, 3, 7)
    if (not landing) then
        return nil, "No free spot near " .. getCreatureName(target) .. "."
    end
    local start = hopFrom(near, 16, 24)
    local cid = start and WildLegendaries.spawn(species, start, nil, source, { quiet = true })
    local flying = cid and takeoff(cid, species, landing, "rayquaza")
    if (not cid) then
        cid = WildLegendaries.spawn(species, landing, nil, source, { quiet = true })
        if (not cid) then
            return nil, "Rayquaza could not be placed."
        end
    end
    local text = string.format("Rayquaza is coming down from the sky to calm Groudon and Kyogre near %s!",
        WildLegendaries.areaAt(landing))
    broadcast(text)
    discord({ event = "calm", species = "Rayquaza", encounterId = encounterOut("Groudon"), other = "Kyogre",
        otherEncounterId = encounterOut("Kyogre"), area = WildLegendaries.areaAt(landing), text = text })
    if (not flying) then
        WildLegendaries.save()
    end
    return true
end

local function runRayquaza(now)
    local groudon, kyogre = encounterOut("Groudon"), encounterOut("Kyogre")
    local events = readMap(KEY.EVENTS)
    if (not groudon or not kyogre) then
        if (events.rayquaza) then
            setEvent("rayquaza", nil)
        end
        return
    end
    local pair = groudon .. ":" .. kyogre
    local stored, due = (events.rayquaza or ""):match("^(%d+:%d+):(%d+)$")
    if (stored ~= pair) then
        due = getRandom(1, 100) <= CONFIG.rayquazaChance and (now + CONFIG.rayquazaDelay) or 0
        setEvent("rayquaza", pair .. ":" .. due)
        return
    end
    due = tonumber(due)
    if (due > 0 and now >= due and not isOut("Rayquaza") and WildLegendaries.callRayquaza("event")) then
        setEvent("rayquaza", pair .. ":0")
    end
end
WildLegendaries.runRayquaza = runRayquaza

-- Clashes: two legendaries in the same zone (or next ones) change the weather there -------------

local function zonesTouch(a, b)
    if (a == b) then
        return true
    end
    for _, other in ipairs((LEGENDARY_ANCHORS.NEIGHBORS or {})[a] or {}) do
        if (other == b) then
            return true
        end
    end
    return false
end

-- The clash weather every zone should have now: [zone id string] = { kind, clash }
local function wantedClashes(owned)
    local want = {}
    for _, clash in ipairs(CONFIG.clashes) do
        local kind = clash[3]
        if (WildLegendaries.findFlight(clash[1]) or WildLegendaries.findFlight(clash[2])) then
            -- one of them is in the air or under the sea: what it made stays until it lands
            for id, owner in pairs(owned) do
                if (owner == kind) then
                    want[id] = { kind = kind, clash = clash }
                end
            end
        else
            local a, b = WildLegendaries.find(clash[1]), WildLegendaries.find(clash[2])
            local calmed = clash.calmedBy and isOut(clash.calmedBy)
            local za, zb = a and monText(a, MON.ZONE), b and monText(b, MON.ZONE)
            if (za and zb and not calmed and zonesTouch(za, zb)) then
                for _, name in ipairs({ za, zb }) do
                    local zone = weatherZone(name)
                    if (zone) then
                        want[tostring(zone.id)] = { kind = kind, clash = clash, zone = zone }
                    end
                end
            end
        end
    end
    return want
end

function WildLegendaries.runClashes(now)
    now = now or os.time()
    local owned = readMap(KEY.CLASHES)
    local want = wantedClashes(owned)
    local overrides = Weather.getOverrides()
    local changed, started, calmed = false, {}, {}
    for id, wanted in pairs(want) do
        local current = overrides[tonumber(id)]
        local ours = owned[id] and current and current.kind == owned[id]
        local free = not current or ours or (current.kind == "rain" and isOut("Kyogre"))
        if (free and (not ours or current.kind ~= wanted.kind or
                (current.endsAt > 0 and current.endsAt - now < CONFIG.clashMinutes * 60 / 3))) then
            Weather.setOverride({ tonumber(id) }, wanted.kind, CONFIG.clashMinutes)
            if (owned[id] ~= wanted.kind) then
                started[wanted.clash] = started[wanted.clash] or wanted.zone
            end
            owned[id], changed = wanted.kind, true
        end
    end
    for id, kind in pairs(owned) do
        if (not want[id]) then
            local current = overrides[tonumber(id)]
            if (current and current.kind == kind) then
                Weather.setOverride({ tonumber(id) }, nil)
            end
            owned[id], changed = nil, true
            for _, clash in ipairs(CONFIG.clashes) do
                if (clash[3] == kind and clash.calmedBy and isOut(clash.calmedBy)) then
                    calmed[clash] = true
                end
            end
        end
    end
    if (not changed) then
        return
    end
    writeMap(KEY.CLASHES, owned)
    for clash, zone in pairs(started) do
        local text = string.format("%s and %s meet near %s: %s!", clash[1], clash[2], zone and zone.name or "?", clash[4])
        toChannel(text)
        if (clash.broadcast) then
            broadcast(text)
        end
        discord({ event = "clash", species = clash[1], encounterId = encounterOut(clash[1]), other = clash[2],
            otherEncounterId = encounterOut(clash[2]), area = zone and zone.name or nil, text = text })
    end
    for clash in pairs(calmed) do
        local text = string.format("%s calmed the clash of %s and %s.", clash.calmedBy, clash[1], clash[2])
        toChannel(text)
        discord({ event = "calm", species = clash.calmedBy, encounterId = encounterOut(clash[1]), other = clash[2],
            otherEncounterId = encounterOut(clash[2]), text = text })
    end
    -- Kyogre's own rain comes back where the storm was
    local kyogre = WildLegendaries.find("Kyogre")
    if (kyogre) then
        applyWeather(kyogre, WildLegendaries.getSpecies("Kyogre"), monText(kyogre, MON.HOME_ZONE))
    end
end

-- The clash weather out now, for the status: list of { kind, zone }
function WildLegendaries.getClashes()
    local list = {}
    for id, kind in pairs(readMap(KEY.CLASHES)) do
        local zone = Weather.getZone(tonumber(id))
        list[#list + 1] = { kind = kind, zone = zone and zone.name or id }
    end
    table.sort(list, function(a, b) return a.zone < b.zone end)
    return list
end

-- Executor state (only used in the globalevent's Lua state).
local started = false
local lastGapCheck, lastSpawnTry, lastSave, lastClashCheck = 0, 0, 0, 0

function WildLegendaries.onThink()
    local now = os.time()
    if (not started) then
        started = true
        WildLegendaries.restore()
        scheduleNext(now, false)
        print("> Legendary: next wild legendary " .. os.date("%Y-%m-%d %H:%M", WildLegendaries.getNextSpawn()) ..
            (WildLegendaries.isManual() and " (manual mode)" or ""))
    end

    for _, active in ipairs(getActive()) do
        if (isMonster(active.cid)) then
            upkeep(active.cid, now)
        end
    end
    runPending(now)
    WildLegendaries.runFlights(now)
    runShower(now)
    if (now - lastClashCheck >= CONFIG.clashCheckEvery) then
        lastClashCheck = now
        runRayquaza(now)
        WildLegendaries.runClashes(now)
    end

    if (now - lastGapCheck >= CONFIG.gapCheckInterval) then
        lastGapCheck = now
        sweep()
        scheduleNext(now, false)
    end
    if (now - lastSave >= CONFIG.saveEvery) then
        lastSave = now
        WildLegendaries.save()
    end

    local nextAt = WildLegendaries.getNextSpawn()
    if (nextAt and now >= nextAt and now - lastSpawnTry >= CONFIG.retryInterval) then
        lastSpawnTry = now
        if (not WildLegendaries.blocked(now)) then
            local species = WildLegendaries.pickSpecies(WildLegendaries.eligible(now))
            if (species and WildLegendaries.scheduledSpawn(species)) then
                scheduleNext(now, true)
            end
        end
    end
end

-- Status -----------------------------------------------------------------------------------------

local function describeOne(a, now, staff)
    local cid = a.cid
    local species = WildLegendaries.getSpecies(a.name)
    local area = monText(cid, MON.AREA) or "?"
    local state = ""
    if (monNumber(cid, MON.DISGUISED) == 1) then
        state = " disguised as " .. getCreatureName(cid)
    elseif (monNumber(cid, MON.ASLEEP) == 1) then
        state = " asleep"
    end
    local where = (staff or species.tier < 3) and (" near " .. area) or " somewhere"
    local line = string.format("%s%s%s, %d%% health, leaves in %s.", a.name, state, where,
        healthPercent(cid), ServerExpEvent.formatDuration(math.max(0, monNumber(cid, MON.ENDS_AT) - now)))
    if (staff) then
        local p = getCreaturePosition(cid)
        line = string.format("#%d %s (%d, %d, %d) %d/%d HP%s", a.encounter, line, p.x, p.y, p.z,
            getCreatureHealth(cid), getCreatureMaxHealth(cid), a.flags:find("s") and ", set" or "")
    end
    return line
end

-- The events going on, for staff: the meteor shower, Rayquaza's call, the clash weather
local function eventLines(now)
    local lines = {}
    local shower = getShower()
    if (shower and shower.untilTime > now) then
        lines[#lines + 1] = string.format("Meteor shower at (%d, %d, %d) for %ds more.", shower.pos.x, shower.pos.y,
            shower.pos.z, shower.untilTime - now)
    end
    local due = tonumber((readMap(KEY.EVENTS).rayquaza or ""):match(":(%d+)$"))
    if (due and due > 0 and not isOut("Rayquaza")) then
        lines[#lines + 1] = string.format("Rayquaza comes down to Groudon and Kyogre in %s.",
            ServerExpEvent.formatDuration(math.max(0, due - now)))
    end
    for _, clash in ipairs(WildLegendaries.getClashes()) do
        lines[#lines + 1] = string.format("Clash weather: %s near %s.", clash.kind, clash.zone)
    end
    return lines
end

-- Status for /legendary status and the Legendaries channel.
function WildLegendaries.describe(staff)
    local lines, now = {}, os.time()
    for _, a in ipairs(getActive()) do
        if (isMonster(a.cid) and (staff or monNumber(a.cid, MON.DISGUISED) ~= 1)) then
            table.insert(lines, describeOne(a, now, staff))
        end
    end
    for encounter, f in pairs(getFlights()) do
        local pos = flightAt(f, now)
        local zone = Weather.zoneAt(pos)
        local how = f.kind == "w" and "under the sea near" or "in the air over"
        if (staff) then
            table.insert(lines, string.format("#%d %s %s (%d, %d, %d), lands at (%d, %d, %d) in %ds, %d%% health.", encounter,
                f.species.name, how, pos.x, pos.y, pos.z, f.to.x, f.to.y, f.to.z, math.max(0, landsAt(f) - now), f.health))
        elseif (f.species.tier < 3) then
            table.insert(lines, string.format("%s is %s %s.", f.species.name, how, zone and zone.name or "the sea"))
        end
    end
    if (#lines == 0) then
        table.insert(lines, "No wild legendary is out right now.")
    end
    if (staff) then
        for name, pending in pairs(getPending()) do
            local point = WildLegendaries.getPoints()[pending.point]
            table.insert(lines, string.format("%s's warning near %s, appears in %s.", name, point and point.area or "?",
                ServerExpEvent.formatDuration(math.max(0, pending.at - now))))
        end
        for _, line in ipairs(eventLines(now)) do
            table.insert(lines, line)
        end
        local online = WildLegendaries.getOnline()
        local row = WildLegendaries.getPopulation(online)
        local nextAt = WildLegendaries.getNextSpawn()
        table.insert(lines, string.format("Mode: %s. Online %d: gap %s to %s, cooldowns %s / %s.",
            WildLegendaries.isManual() and "manual" or "auto", online,
            ServerExpEvent.formatDuration(row.gap[1]), ServerExpEvent.formatDuration(row.gap[2]),
            ServerExpEvent.formatDuration(row.cooldown[1]), ServerExpEvent.formatDuration(row.cooldown[2])))
        local blocked = WildLegendaries.blocked(now)
        table.insert(lines, nextAt and string.format("Next spawn %s (in %s)%s.", os.date("%Y-%m-%d %H:%M", nextAt),
            ServerExpEvent.formatDuration(math.max(0, nextAt - now)), blocked and (", waiting: " .. blocked) or "")
            or "No spawn scheduled yet.")
        local cooling = {}
        for name, untilTime in pairs(WildLegendaries.getCooldowns()) do
            if (untilTime > now) then
                table.insert(cooling, string.format("%s %s", name, ServerExpEvent.formatDuration(untilTime - now)))
            end
        end
        table.sort(cooling)
        table.insert(lines, "Cooldowns: " .. (#cooling > 0 and table.concat(cooling, ", ") or "none"))
    end
    return lines
end

-- For the Admin window's Legendaries section
function WildLegendaries.adminState()
    local now = os.time()
    local active, cooldowns, pending, species, sets = {}, {}, {}, {}, {}
    for _, a in ipairs(getActive()) do
        if (isMonster(a.cid)) then
            local p = getCreaturePosition(a.cid)
            active[#active + 1] = { name = a.name, encounter = a.encounter, area = monText(a.cid, MON.AREA),
                zone = monText(a.cid, MON.ZONE), health = healthPercent(a.cid),
                left = math.max(0, monNumber(a.cid, MON.ENDS_AT) - now), x = p.x, y = p.y, z = p.z,
                set = a.flags:find("s") ~= nil, asleep = monNumber(a.cid, MON.ASLEEP) == 1,
                disguised = monNumber(a.cid, MON.DISGUISED) == 1 and getCreatureName(a.cid) or nil }
        end
    end
    for encounter, f in pairs(getFlights()) do
        local p = flightAt(f, now)
        local zone = Weather.zoneAt(p)
        active[#active + 1] = { name = f.species.name, encounter = encounter, area = f.kind == "w" and "under the sea" or "in the air",
            zone = zone and zone.name or nil, health = f.health, left = math.max(0, f.endsAt - now), x = p.x, y = p.y, z = p.z,
            set = f.flags:find("s") ~= nil, flying = true, landsIn = math.max(0, landsAt(f) - now) }
    end
    for name, untilTime in pairs(WildLegendaries.getCooldowns()) do
        if (untilTime > now) then
            cooldowns[#cooldowns + 1] = { name = name, left = untilTime - now }
        end
    end
    table.sort(cooldowns, function(a, b) return a.name < b.name end)
    for name, p in pairs(getPending()) do
        pending[#pending + 1] = { name = name, left = math.max(0, p.at - now) }
    end
    for _, s in ipairs(WildLegendaries.SPECIES) do
        species[#species + 1] = { name = s.name, tier = s.tier, style = s.style, set = s.set }
    end
    for _, set in ipairs(WildLegendaries.SETS) do
        sets[#sets + 1] = { id = set.id, name = set.name }
    end
    local nextAt = WildLegendaries.getNextSpawn()
    return { manual = WildLegendaries.isManual(), active = active, cooldowns = cooldowns, pending = pending,
             species = species, sets = sets, nextIn = nextAt and math.max(0, nextAt - now) or nil,
             blocked = WildLegendaries.blocked(now), mythical = mythicalOut(), events = eventLines(now) }
end

-- Ranger radar hints for the legendaries out in the trainer's region, by rank: zone activity (1), the
-- species from its signs (2), the zones it may go to next (3), the direction and how fresh the signs are
-- (4), the zones it came through and where it is heading (5). Never the exact spot. Mythicals from rank 4.
local function listText(items)
    if (#items <= 1) then
        return items[1] or ""
    end
    return table.concat(items, ", ", 1, #items - 1) .. " or " .. items[#items]
end

function WildLegendaries.radarHints(cid, rank)
    local lines = {}
    if (rank <= 0) then
        return lines
    end
    local pos = getCreaturePosition(cid)
    local region = Weather.regionAt(pos)
    local now = os.time()
    for _, a in ipairs(getActive()) do
        local species = WildLegendaries.getSpecies(a.name)
        if (species and isMonster(a.cid) and monNumber(a.cid, MON.DISGUISED) ~= 1) then
            local where = getCreaturePosition(a.cid)
            local mythical = species.tier == 3
            if (Weather.regionAt(where) == region and (not mythical or rank >= 4)) then
                local zone = monText(a.cid, MON.ZONE) or "?"
                local who = rank >= 2 and a.name or "Something powerful"
                local text
                if (mythical) then
                    text = string.format("%s is near, %s of here", rank >= 5 and a.name or "Something mythical",
                        directionTo(pos, where))
                else
                    text = string.format("%s is stirring around %s", who, zone)
                    if (rank >= 3) then
                        local style = species.style
                        if (style == "roam") then
                            local next = (LEGENDARY_ANCHORS.NEIGHBORS or {})[zone] or {}
                            text = text .. (#next > 0 and (", it may run to " .. listText(next)) or ", it stays on this island")
                        elseif (style == "fly" or style == "sea") then
                            text = text .. ", it may " .. (style == "fly" and "fly" or "swim") .. " far"
                        elseif (style == "sleep") then
                            text = text .. ", fast asleep"
                        else
                            text = text .. ", it keeps to this place"
                        end
                    end
                    if (rank >= 4) then
                        local minutes = math.floor(math.max(0, now - monNumber(a.cid, MON.MOVED_AT)) / 60)
                        text = text .. string.format(", %s of here, signs %s", directionTo(pos, where),
                            minutes <= 1 and "fresh" or (minutes .. " minutes old"))
                    end
                    if (rank >= 5) then
                        local path = pathOf(a.cid)
                        if (#path > 1) then
                            text = text .. ", came by " .. table.concat(path, " > ")
                        end
                        local nextZone = monText(a.cid, MON.NEXT_ZONE)
                        if (nextZone and nextZone ~= "-" and nextZone ~= zone) then
                            text = text .. ", heading for " .. nextZone
                        end
                    end
                end
                lines[#lines + 1] = text .. "."
            end
        end
    end
    for _, f in pairs(getFlights()) do
        local where = flightAt(f, now)
        if (f.species.tier < 3 and Weather.regionAt(where) == region) then
            local zone = Weather.zoneAt(where)
            local text = string.format("%s is %s %s", rank >= 2 and f.species.name or "Something powerful",
                f.kind == "w" and "moving under the sea near" or "flying over", zone and zone.name or "the sea")
            if (rank >= 3) then
                text = text .. ", heading " .. directionTo(f.from, f.to)
            end
            if (rank >= 4) then
                text = text .. ", " .. directionTo(pos, where) .. " of here"
            end
            if (rank >= 5) then
                local landing = Weather.zoneAt(f.to)
                text = text .. (landing and (", it will come down around " .. landing.name) or "")
            end
            lines[#lines + 1] = text .. "."
        end
    end
    return lines
end

-- The flight of that species, or nil
function WildLegendaries.findFlight(name)
    local species = WildLegendaries.getSpecies(name)
    for encounter, f in pairs(getFlights()) do
        if (species and f.species == species) then
            return encounter, f
        end
    end
    return nil
end

-- Living legendary of that species, or nil (Mew also in disguise).
function WildLegendaries.find(name)
    local species = WildLegendaries.getSpecies(name)
    for _, a in ipairs(getActive()) do
        if (species and a.name == species.name and isMonster(a.cid)) then
            return a.cid, a
        end
    end
    return nil
end

WildLegendaries.getActive = getActive
WildLegendaries.getPending = getPending
WildLegendaries.getFlights = getFlights
WildLegendaries.setFlight = setFlight
WildLegendaries.flightAt = flightAt
WildLegendaries.landsAt = landsAt
WildLegendaries.runPending = runPending
WildLegendaries.upkeep = upkeep
WildLegendaries.sweep = sweep
WildLegendaries.healthPercent = healthPercent
WildLegendaries.MON = MON
WildLegendaries.KEY = KEY
