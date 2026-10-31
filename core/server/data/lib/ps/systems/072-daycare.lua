-- Day Care window (docs/upcoming-features.md). Any daycare NPC (the Old Man and the Old Lady) opens the
-- same window for the trainer's account: two slots for any two Pokemon, lines from each down to the egg
-- slot, and what the pair can breed. Slot 1 is the daycare_female table and slot 2 daycare_male, so the
-- Pokemon left with the NPCs before the window stay where they are. The Old Man opens the window when greeted;
-- the Old Lady, who also sells incubators, when the trainer says "daycare".
--
-- An egg is rolled from the pair, not from withdrawing one of them: from day 7 of the wait each day has one
-- roll, on day 14 the egg is certain (as the NPCs). The rolls happen whenever the window is built; an egg
-- that hits waits in the egg slot (playersStorages.daycareEgg) until the trainer collects it.
--
-- The window talks JSON on EXTENDED_IDS.DAYCARE:
--   client -> server  {action = "hello"} (at login), {action = "refresh"}, {action = "deposit", key, minutes},
--                     {action = "withdraw", slot}, {action = "cancel", slot}, {action = "collect"},
--                     {action = "plate", item} (deposit), {action = "plate"} (take it back)
--   server -> client  {type = "daycare", slots = {slot, slot}, egg, candidates, plates, plate, rules, events}
--                     {type = "result", ok, text}
-- Every action needs a daycare NPC near the trainer.
--
-- /bonusdaycare and /bonusbreeding start server events like /doubleexp: the first multiplies the training
-- EXP earned while it runs, the second the daily egg chance.

Daycare = {}

Daycare.MIN_LEVEL = 20
Daycare.ENTRY_FEE = 100
Daycare.TRAIN_OPTIONS = { 1440, 2880 } -- minutes
Daycare.TOGETHER_MINUTES = 1440 -- both have to train this long before the pair can make an egg
Daycare.EGG_EARLY_FROM_DAY = 7
Daycare.EGG_GUARANTEED_DAY = 14
Daycare.EGG_EARLY_CHANCE = 0.10
Daycare.NPCS = { ["Old Man"] = true, ["Old Lady"] = true }
Daycare.NPC_RANGE = 5

local DAY = 24 * 60 * 60
local TABLES = { "daycare_female", "daycare_male" }
local CLIENT = playersStorages.daycareClient
local EGG = playersStorages.daycareEgg

local function send(cid, data)
    doSendPlayerExtendedOpcode(cid, EXTENDED_IDS.DAYCARE, JSON.encode(data))
end

local function result(cid, ok, text, ...)
    send(cid, { type = "result", ok = ok, text = string.format(__L(cid, text), ...) })
    return ok
end

Daycare.expPerMinute = function(level)
    if (level >= 100) then
        return 0
    elseif (level > 75) then
        return 210
    elseif (level > 50) then
        return 140
    end
    return 70
end

Daycare.pricePerMinute = function(level)
    if (level > 75) then
        return 4
    elseif (level > 50) then
        return 2
    end
    return 1
end

-- Events ---------------------------------------------------------------------------------------------

-- The start and end stay stored after an event ends: training that overlapped it keeps the bonus
Daycare.EVENTS = {
    daycare = { multiplier = GLOBAL_STORAGES.DAYCARE_EVENT_MULTIPLIER, start = GLOBAL_STORAGES.DAYCARE_EVENT_START,
                ends = GLOBAL_STORAGES.DAYCARE_EVENT_END, label = "Day Care training EXP" },
    breeding = { multiplier = GLOBAL_STORAGES.BREEDING_EVENT_MULTIPLIER, start = GLOBAL_STORAGES.BREEDING_EVENT_START,
                 ends = GLOBAL_STORAGES.BREEDING_EVENT_END, label = "Day Care egg chance" },
}

local function storedNumber(key)
    return tonumber(getStorage(key)) or -1
end

local function store(key, value)
    doSetStorage(key, value)
    db.executeQuery(string.format("REPLACE INTO `global_storage` (`key`, `world_id`, `value`) VALUES (%d, %d, %s);",
        key, getConfigValue("worldId") or 0, db.escapeString(tostring(value))))
end

-- multiplier, start, end of the event's last run (nil when there never was one)
local function lastRun(kind)
    local event = Daycare.EVENTS[kind]
    local multiplier = storedNumber(event.multiplier)
    if (multiplier <= 100) then
        return nil
    end
    return multiplier / 100, storedNumber(event.start), storedNumber(event.ends)
end

-- multiplier, end time of the running event, or nil
Daycare.getEvent = function(kind)
    local multiplier, _, endsAt = lastRun(kind)
    if (not multiplier or endsAt <= os.time()) then
        return nil
    end
    return multiplier, endsAt
end

Daycare.describeEvent = function(kind)
    local multiplier, endsAt = Daycare.getEvent(kind)
    if (not multiplier) then
        return string.format("No %s event is running right now.", Daycare.EVENTS[kind].label)
    end
    return string.format("%s %s event: %s left (ends %s server time).", ServerExpEvent.formatMultiplier(multiplier),
        Daycare.EVENTS[kind].label, ServerExpEvent.formatDuration(endsAt - os.time()), os.date("%Y-%m-%d %H:%M", endsAt))
end

Daycare.startEvent = function(kind, multiplier, seconds)
    local event = Daycare.EVENTS[kind]
    local replaced = Daycare.getEvent(kind)
    local now = os.time()
    store(event.multiplier, math.floor(multiplier * 100 + 0.5))
    store(event.start, now)
    store(event.ends, now + seconds)
    doBroadcastMessage(string.format("%s %s %s for the next %s!",
        replaced and "The Day Care event changed:" or "Day Care event started:",
        ServerExpEvent.formatMultiplier(multiplier), kind == "daycare" and "training EXP at the Day Care" or "egg chance at the Day Care",
        ServerExpEvent.formatDuration(seconds)), MESSAGE_STATUS_WARNING)
end

Daycare.stopEvent = function(kind)
    local multiplier = Daycare.getEvent(kind)
    if (not multiplier) then
        return false
    end
    store(Daycare.EVENTS[kind].ends, os.time())
    doBroadcastMessage(string.format("The %s %s event was cancelled.", ServerExpEvent.formatMultiplier(multiplier),
        Daycare.EVENTS[kind].label), MESSAGE_STATUS_WARNING)
    return true
end

-- The event's extra multiplier for the minutes of [from, to] it ran (0 without one)
local function eventBonusMinutes(kind, from, to)
    local multiplier, startsAt, endsAt = lastRun(kind)
    if (not multiplier) then
        return 0
    end
    local overlap = math.min(to, endsAt) - math.max(from, startsAt)
    return overlap > 0 and math.floor(overlap / 60) * (multiplier - 1) or 0
end

Daycare.onLogin = function(cid)
    for kind in pairs(Daycare.EVENTS) do
        if (Daycare.getEvent(kind)) then
            doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, Daycare.describeEvent(kind))
        end
    end
    setPlayerStorageValue(cid, CLIENT, -1)
end

-- Announces the end (globalevent state only); a cancelled event moved its end, and was announced already
local running = {}
Daycare.onThink = function()
    for kind, event in pairs(Daycare.EVENTS) do
        local multiplier, endsAt = Daycare.getEvent(kind)
        local last = running[kind]
        if (last and not multiplier and storedNumber(event.ends) == last.ends) then
            doBroadcastMessage(string.format("The %s %s event has ended.", ServerExpEvent.formatMultiplier(last.multiplier),
                event.label), MESSAGE_STATUS_WARNING)
        end
        running[kind] = multiplier and { multiplier = multiplier, ends = endsAt } or nil
    end
end

-- Training ---------------------------------------------------------------------------------------------

local function loadRow(guid, slot)
    local r = db.getResult(string.format("SELECT * FROM `%s` WHERE `player_id` = %d LIMIT 1;", TABLES[slot], guid))
    if (r:getID() == -1) then
        return nil
    end
    return r
end

local function trainedMinutes(row)
    return math.max(0, math.min(math.floor((os.time() - row:getDataInt("date")) / 60), row:getDataInt("max_training_minutes")))
end

-- The EXP the Pokemon earns by now, with the training event's bonus for the time it overlapped
Daycare.trainingExp = function(level, startedAt, minutes)
    local rate = Daycare.expPerMinute(level)
    return math.floor(rate * (minutes + eventBonusMinutes("daycare", startedAt, startedAt + minutes * 60)))
end

-- The species' egg item, or nil when it has none (getPokemonEggId raises on unknown names)
local function eggIdOf(species)
    if (not species or not isPokemonName(species, true)) then
        return nil
    end
    local ok, eggId = pcall(getPokemonEggId, species)
    return ok and eggId or nil
end

local function isDitto(name)
    return name == "Ditto" or name == "Shiny Ditto"
end

local function sexName(sex)
    return sex == POKEMON_SEX_FEMALE and "female" or sex == POKEMON_SEX_MALE and "male" or nil
end

-- What the window shows of a slot; row stays open (the caller frees it)
local function slotInfo(row, slot)
    local name, level = row:getDataString("pokemon_name"), row:getDataInt("pokemon_level")
    local info = { slot = slot, name = name, level = level, number = getPokemonNumberByName(name),
                   shiny = isShinyName(name) ~= nil or nil, ditto = isDitto(name) or nil,
                   since = row:getDataInt("date"), max = row:getDataInt("max_training_minutes") }
    local monster = getMonsterInfo(name, false)
    info.look = monster and monster.outfit and monster.outfit.lookType or nil
    local sex = POKEMON_SEX_UNKNOWN
    if (row:getDataInt("pokemon_maxenergy") > 0) then -- left before the balls kept their attributes
        sex = row:getDataInt("pokemon_sex")
        info.nickname = row:getDataString("pokemon_nickname") ~= "" and row:getDataString("pokemon_nickname") or nil
    else
        local uid = PokemonStats.loadStoredBall(row)
        if (uid) then
            sex = getBallPokemonSex(uid)
            local nickname = getBallPokemonNickname(uid)
            info.nickname = (nickname and nickname ~= "" and nickname ~= name) and nickname or nil
            local heldId = getBallHeld(uid)
            if (heldId) then
                local itemInfo = getItemInfo(PokemonHeldItem.getHeldItemId(heldId) or 0)
                info.held = { name = PokemonHeldItem.getHeldName(heldId, uid), text = PokemonHeldItem.getBallDescription(uid),
                              client = itemInfo and itemInfo.clientId or 0 }
            end
            local ivs, evs, natureId = PokemonStats.readBall(uid)
            if (ivs) then
                info.nature = PokemonStats.getNatureName(natureId)
                info.ivs = { total = PokemonStats.getTotal(ivs), max = PokemonStats.IV_MAX * PokemonStats.STAT_COUNT }
                info.evs = { total = PokemonStats.getTotal(evs), max = PokemonStats.EV_TOTAL_MAX }
            end
        elseif (not info.ditto) then
            -- no ball kept with the row: the NPCs only took females (slot 1) and males (slot 2)
            sex = slot == 1 and POKEMON_SEX_FEMALE or POKEMON_SEX_MALE
        end
    end
    info.sexKey = sex
    info.sex = sexName(sex)
    info.trained = trainedMinutes(row)
    info.done = info.trained >= info.max
    info.exp = Daycare.trainingExp(level, info.since, info.trained)
    info.levelNow = math.min(POKEMON_LEVEL_MAX, getLevelByExp(row:getDataLong("pokemon_experience") > 0 and
        row:getDataLong("pokemon_experience") + info.exp or getExperienceForLevel(level) + info.exp))
    info.fee = Daycare.pricePerMinute(level) * info.trained
    return info
end

-- Breeding ---------------------------------------------------------------------------------------------

local function accountGuids(cid)
    return getAllPlayersByAccountId(getPlayerAccountId(cid))
end

local function lastEggTime(cid)
    local last = 0
    for _, guid in ipairs(accountGuids(cid)) do
        local r = db.getResult(string.format("SELECT `lasteggtime` FROM `players` WHERE `id` = %d LIMIT 1;", guid))
        if (r:getID() ~= -1) then
            last = math.max(last, r:getDataInt("lasteggtime"))
            r:free()
        end
    end
    return last
end

-- The wait for an egg starts at the account's last egg, or at the first daycare visit
Daycare.eggWaitStart = function(cid)
    local last = lastEggTime(cid)
    if (last > 0) then
        return last
    end
    local start = getPlayerStorageValue(cid, playersStorages.eggCycleStart)
    if (start <= 0) then
        start = os.time()
        setPlayerStorageValue(cid, playersStorages.eggCycleStart, start)
    end
    return start
end

Daycare.eggChance = function(cid)
    local chance = isPremium(cid) and Vocations.perk(cid, "breeder", "earlyEgg") or Daycare.EGG_EARLY_CHANCE
    chance = chance + getPlayerExtraEggRateValue(cid) / 100
    local multiplier = Daycare.getEvent("breeding")
    return math.min(1, chance * (multiplier or 1) * EventCalendar.multiplier("breeding"))
end

-- One roll for every day of the wait from day 7 that hasn't had one, or the egg from day 14
local function rollEgg(cid)
    local start = Daycare.eggWaitStart(cid)
    local day = math.floor((os.time() - start) / DAY)
    if (day >= Daycare.EGG_GUARANTEED_DAY) then
        return true
    end
    local lastRolled = Daycare.EGG_EARLY_FROM_DAY - 1
    if (getPlayerStorageValue(cid, playersStorages.eggRollCycle) == start) then
        lastRolled = math.max(lastRolled, getPlayerStorageValue(cid, playersStorages.eggRollDay))
    end
    local chance, hit = Daycare.eggChance(cid), false
    for _ = lastRolled + 1, day do
        if (math.random() < chance) then
            hit = true
            break
        end
    end
    setPlayerStorageValue(cid, playersStorages.eggRollCycle, start)
    setPlayerStorageValue(cid, playersStorages.eggRollDay, math.max(lastRolled, day))
    return hit
end

-- Whether the pair can make an egg: status and the egg's species. a and b are slotInfo tables (or nil).
--   empty, twoDitto, noEggs, genderless, sameGender, incompatible, or ok
Daycare.compatibility = function(a, b)
    if (not a or not b) then
        return "empty"
    end
    local species
    if (a.ditto and b.ditto) then
        return "twoDitto"
    elseif (a.ditto or b.ditto) then
        species = a.ditto and b.name or a.name
        if (not canPokemonBreed(species, "Ditto")) then
            return "noEggs", nil, species
        end
    elseif (a.sexKey == POKEMON_SEX_UNKNOWN or b.sexKey == POKEMON_SEX_UNKNOWN) then
        return "genderless"
    elseif (a.sexKey == b.sexKey) then
        return "sameGender"
    else
        local female, male = a, b
        if (b.sexKey == POKEMON_SEX_FEMALE) then
            female, male = b, a
        end
        if (not canPokemonBreed(female.name, male.name)) then
            return "incompatible"
        end
        species = female.name
    end
    if (not eggIdOf(species)) then
        return "noEggs", nil, species
    end
    return "ok", species
end

local function eggSpeciesName(species)
    return getPokemonNameByEggId(eggIdOf(species) or 0) or species
end

-- The egg item's sprite, drawn in the egg slot
local function eggClientId(species)
    local info = getItemInfo(eggIdOf(species) or 0)
    return info and info.clientId or 0
end

local function getPendingEgg(cid)
    local count, species, ivs, natureId = tostring(getPlayerStorageValue(cid, EGG)):match("^e(%d+)|([^|]+)|([%d,]+)|(%d+)$")
    if (not count) then
        return nil
    end
    local list = {}
    for iv in ivs:gmatch("%d+") do
        list[#list + 1] = tonumber(iv)
    end
    return { count = tonumber(count), species = species, ivs = list, natureId = tonumber(natureId) }
end

local function getPlayerEggTries(cid, number)
    local tries, r = 0, db.getResult(string.format("SELECT `tries` FROM `egg_counter` WHERE `player_id` = %d AND `pokemon_id` = %d LIMIT 1;",
        getPlayerGUID(cid), number or 0))
    if (r:getID() ~= -1) then
        tries = r:getDataInt("tries")
        r:free()
    end
    return tries
end

-- Rolls for an egg when the pair can make one; a hit goes to the egg slot with the parents' IVs and Nature
local function updateEgg(cid, rows, infos)
    if (getPendingEgg(cid)) then
        return
    end
    local status, species = Daycare.compatibility(infos[1], infos[2])
    if (status ~= "ok" or infos[1].trained < Daycare.TOGETHER_MINUTES or infos[2].trained < Daycare.TOGETHER_MINUTES) then
        return
    end
    if (math.floor((os.time() - Daycare.eggWaitStart(cid)) / DAY) < Daycare.EGG_EARLY_FROM_DAY or not rollEgg(cid)) then
        return
    end
    if (species == "Nidorana" and (infos[1].ditto or infos[2].ditto)) then
        species = table.random({ "Nidorana", "Nidorano" })
    end
    local count = 1
    local secondEgg = isPremium(cid) and Vocations.perk(cid, "breeder", "secondEgg")
    if (secondEgg and math.random() < secondEgg) then
        count = 2
    end
    local ivs, natureId = PokemonStats.makeEggStats(PokemonStats.readDaycareParent(rows[1]), PokemonStats.readDaycareParent(rows[2]))
    setPlayerStorageValue(cid, EGG, string.format("e%d|%s|%s|%d", count, species, table.concat(ivs, ","), natureId))
    db.executeQuery(string.format("UPDATE `players` SET `lasteggtime` = %d WHERE `id` = %d;", os.time(), getPlayerGUID(cid)))
    doPlayerAddStatistic(cid, PLAYER_STATISTIC_IDS.GENERATE_POKEMON_EGG, count)
    doDatalogEggGenerate(cid, species, os.time(), getPlayerEggTries(cid, getPokemonNumberByName(species)))
    doPlayerSendTextMessage(cid, MESSAGE_EVENT_ADVANCE, count > 1 and __L(cid, "Two eggs are waiting for you at the Day Care!")
        or __L(cid, "An egg is waiting for you at the Day Care!"))
end

local function eggInfo(cid, infos)
    local pending = getPendingEgg(cid)
    local status, species, blocked = Daycare.compatibility(infos[1], infos[2])
    local start = Daycare.eggWaitStart(cid)
    local now = os.time()
    local egg = { status = status, chance = math.floor(Daycare.eggChance(cid) * 1000 + 0.5) / 10,
                  fromDay = Daycare.EGG_EARLY_FROM_DAY, certainDay = Daycare.EGG_GUARANTEED_DAY,
                  day = math.floor((now - start) / DAY) }
    if (species) then
        egg.species = eggSpeciesName(species)
        egg.number = getPokemonNumberByName(egg.species)
        egg.client = eggClientId(species)
    elseif (blocked) then
        egg.blocked = blocked
    end
    if (pending) then
        egg.status = "ready"
        egg.count = pending.count
        egg.species = eggSpeciesName(pending.species)
        egg.number = getPokemonNumberByName(egg.species)
        egg.client = eggClientId(pending.species)
        egg.nature = PokemonStats.getNatureName(pending.natureId)
        egg.ivs = { total = PokemonStats.getTotal(pending.ivs), max = PokemonStats.IV_MAX * PokemonStats.STAT_COUNT }
    elseif (status == "ok") then
        local together = math.min(infos[1].trained, infos[2].trained)
        if (together < Daycare.TOGETHER_MINUTES) then
            egg.status = "together"
            egg.left = (Daycare.TOGETHER_MINUTES - together) * 60
        elseif (egg.day < Daycare.EGG_EARLY_FROM_DAY) then
            egg.status = "waiting"
            egg.left = start + Daycare.EGG_EARLY_FROM_DAY * DAY - now
        else
            egg.status = "chance"
            egg.left = start + Daycare.EGG_GUARANTEED_DAY * DAY - now
        end
    end
    return egg
end

-- Window -----------------------------------------------------------------------------------------------

local function plateOf(cid)
    local r = db.getResult(string.format("SELECT `item_id` FROM `daycare_plates` WHERE `player_id` = %d LIMIT 1;", getPlayerGUID(cid)))
    if (r:getID() == -1) then
        return nil
    end
    local item = r:getDataInt("item_id")
    r:free()
    return item
end

local function itemEntry(itemId)
    local info = getItemInfo(itemId)
    return { item = itemId, name = PLATE_NAME_BY_ITEMID[itemId] or (info and info.name) or "", client = info and info.clientId or 0 }
end

local function ballKey(index, uid)
    return string.format("%d|%s|%d", index, getBallPokemonName(uid), getBallPokemonLevel(uid))
end

local function findBall(cid, key)
    for index, ball in ipairs(getPlayerAllBallsWithPokemon(cid)) do
        if (ballKey(index, ball.uid) == key) then
            return ball
        end
    end
    return nil
end

local function candidates(cid)
    local list = JSON.array()
    for index, ball in ipairs(getPlayerAllBallsWithPokemon(cid)) do
        local name = getBallPokemonName(ball.uid)
        local entry = { key = ballKey(index, ball.uid), name = name, level = getBallPokemonLevel(ball.uid),
                        sex = sexName(getBallPokemonSex(ball.uid)), number = getPokemonNumberByName(name),
                        shiny = isShinyName(name) ~= nil or nil }
        local heldId = getBallHeld(ball.uid)
        if (heldId) then
            entry.held = PokemonHeldItem.getHeldName(heldId, ball.uid)
        end
        list[#list + 1] = entry
    end
    return list
end

-- Another character of the account with a Pokemon at the daycare (one character per account uses it)
local function otherCharacterUsing(cid)
    local own = getPlayerGUID(cid)
    for _, guid in ipairs(accountGuids(cid)) do
        if (guid ~= own) then
            for slot = 1, 2 do
                local row = loadRow(guid, slot)
                if (row) then
                    row:free()
                    return true
                end
            end
        end
    end
    return false
end

-- Opens the rows, rolls for an egg and returns rows, infos (free the rows with closeRows)
local function readSlots(cid)
    local rows, infos = {}, {}
    for slot = 1, 2 do
        rows[slot] = loadRow(getPlayerGUID(cid), slot)
        infos[slot] = rows[slot] and slotInfo(rows[slot], slot) or nil
    end
    updateEgg(cid, rows, infos)
    return rows, infos
end

local function closeRows(rows)
    for slot = 1, 2 do
        if (rows[slot]) then
            rows[slot]:free()
        end
    end
end

Daycare.isNear = function(cid)
    for _, creature in ipairs(getSpectators(getCreaturePosition(cid), Daycare.NPC_RANGE, Daycare.NPC_RANGE, false) or {}) do
        if (isNpc(creature) and Daycare.NPCS[getCreatureName(creature)]) then
            return true
        end
    end
    return false
end

Daycare.enabled = function(cid)
    return isPlayer(cid) and getPlayerStorageValue(cid, CLIENT) == 1
end

Daycare.sendState = function(cid)
    local rows, infos = readSlots(cid)
    local egg = eggInfo(cid, infos)
    closeRows(rows)
    local slots = JSON.array()
    for slot = 1, 2 do
        local info = infos[slot]
        if (info) then
            info.sexKey = nil
            slots[slot] = info
        else
            slots[slot] = { slot = slot, empty = true }
        end
    end

    local plates = JSON.array()
    for itemId in pairs(PLATE_NAME_BY_ITEMID) do
        if (getPlayerItemCount(cid, itemId) > 0) then
            plates[#plates + 1] = itemEntry(itemId)
        end
    end
    table.sort(plates, function(x, y) return x.name < y.name end)
    local plate = plateOf(cid)

    local events = {}
    for kind in pairs(Daycare.EVENTS) do
        local multiplier, endsAt = Daycare.getEvent(kind)
        if (multiplier) then
            events[kind] = { multiplier = multiplier, left = endsAt - os.time() }
        end
    end

    send(cid, {
        type = "daycare", slots = slots, egg = egg, candidates = candidates(cid), plates = plates,
        plate = plate and itemEntry(plate) or nil, events = events,
        rules = { minLevel = Daycare.MIN_LEVEL, level = getPlayerLevel(cid), premium = isPremium(cid) or false,
                  fee = Daycare.ENTRY_FEE, options = Daycare.TRAIN_OPTIONS, otherCharacter = otherCharacterUsing(cid),
                  money = getPlayerMoney(cid) },
    })
    return true
end

Daycare.open = function(cid)
    if (not Daycare.enabled(cid)) then
        return false
    end
    if (not Daycare.sendState(cid)) then
        return false
    end
    Hints.show(cid, "daycare")
    return true
end

-- The egg slot after rolling, for the NPCs' conversation
Daycare.eggState = function(cid)
    local rows, infos = readSlots(cid)
    local egg = eggInfo(cid, infos)
    closeRows(rows)
    return egg
end

-- A keeper greeting the trainer: with the window, opens it (when openWindow) and leaves the egg to it;
-- without, hands over a waiting egg. Returns what the keeper says about the egg, or nil.
Daycare.onGreet = function(cid, openWindow)
    if (Daycare.enabled(cid)) then
        if (openWindow) then
            Daycare.open(cid)
        end
        return nil
    end
    Daycare.eggState(cid)
    local count, species = Daycare.handOverEgg(cid)
    if (not count) then
        return nil
    end
    return string.format(__L(cid, count > 1 and "Your Pokemon left you two %s eggs! Here they are." or
        "Your Pokemon left you a %s egg! Here it is."), species)
end

Daycare.deposit = function(cid, key, minutes)
    minutes = tonumber(minutes)
    if (not isInArray(Daycare.TRAIN_OPTIONS, minutes)) then
        return result(cid, false, "Choose how long it should train.")
    elseif (getPlayerLevel(cid) < Daycare.MIN_LEVEL) then
        return result(cid, false, "Only trainers from level %d can use the Day Care.", Daycare.MIN_LEVEL)
    elseif (not isPremium(cid)) then
        return result(cid, false, "The Day Care is for premium accounts.")
    elseif (isPokemonOnline(cid) or getPlayerMounted(cid) or isEvolving(cid)) then
        return result(cid, false, "You can't do that while your Pokemon is out of its ball.")
    elseif (otherCharacterUsing(cid)) then
        return result(cid, false, "A character of your account is already using the Day Care.")
    elseif (getPlayerMoney(cid) < Daycare.ENTRY_FEE) then
        return result(cid, false, "You need %d dollars to leave a Pokemon here.", Daycare.ENTRY_FEE)
    end
    local slot
    for s = 1, 2 do
        local row = loadRow(getPlayerGUID(cid), s)
        if (row) then
            row:free()
        elseif (not slot) then
            slot = s
        end
    end
    if (not slot) then
        return result(cid, false, "Both places at the Day Care are taken.")
    end
    local ball = findBall(cid, tostring(key or ""))
    if (not ball) then
        return result(cid, false, "You don't have that Pokemon with you anymore.")
    end
    local name = getBallPokemonName(ball.uid)
    PokemonStats.ensureBall(ball.uid)
    local query = string.format("INSERT INTO `%s` (`player_id`, `date`, `ball_id`, `max_training_minutes`, `pokemon_name`, `pokemon_level`, `attributes`) VALUES (%d, %d, %d, %d, %s, %d, %s);",
        TABLES[slot], getPlayerGUID(cid), os.time(), ball.itemid, minutes, db.escapeString(name), getBallPokemonLevel(ball.uid),
        getItemAttributesBlob(ball.uid))
    if (not db.executeQuery(query)) then
        log(LOG_TYPES.ERROR, "Daycare.deposit - Can't query.", query)
        return result(cid, false, "Something went wrong. Please try again later.")
    end
    doPlayerRemoveMoney(cid, Daycare.ENTRY_FEE)
    Daycare.eggWaitStart(cid)
    doRemoveItem(ball.uid)
    doPlayerSave(cid) -- no clone balls
    Daycare.sendState(cid)
    return result(cid, true, "%s will be fine here.", name)
end

-- The ball back with the EXP of the training (none when cancelled), in the bag or the depot
local function giveBack(cid, row, cancelled)
    local startedAt, minutes = row:getDataInt("date"), trainedMinutes(row)
    local beforeDepot = function(ball)
        local level = getBallPokemonLevel(ball)
        local exp = getBallPokemonExp(ball)
        local gained = level
        if (not cancelled) then
            exp = math.min(getExperienceForLevel(POKEMON_LEVEL_MAX), exp + Daycare.trainingExp(level, startedAt, minutes))
            level = getLevelByExp(exp)
        end
        setBallPokemonExp(ball, exp)
        setBallPokemonLevel(ball, level)
        setBallPokemonExtraPoints(ball, getBallPokemonExtraPoints(ball) + math.floor((level - gained) / 2))
        doBallUpdateDescription(ball)
    end
    if (row:getDataInt("pokemon_maxenergy") > 0) then -- left before the balls kept their attributes
        return doCreatePokemonBall(cid, row:getDataInt("ball_id"), row:getDataString("pokemon_name"),
            row:getDataInt("pokemon_level"), row:getDataInt("pokemon_sex"), row:getDataString("pokemon_nickname"),
            row:getDataInt("pokemon_extrapoints"), nil, nil, 999999, row:getDataInt("pokemon_experience"),
            row:getDataInt("pokemon_specialability"), row:getDataInt("pokemon_tm1"), row:getDataInt("pokemon_tm1_slot"),
            row:getDataInt("pokemon_tm2"), row:getDataInt("pokemon_tm2_slot"), row:getDataInt("ball_seal"), nil, nil, beforeDepot)
    end
    return doCreatePokemonBall(cid, row:getDataInt("ball_id"), nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
        nil, nil, nil, true, { column = "attributes", result = row:getID() }, beforeDepot)
end

Daycare.withdraw = function(cid, slot, cancelled)
    slot = tonumber(slot)
    if (slot ~= 1 and slot ~= 2) then
        return false
    end
    local rows = readSlots(cid)
    local row = rows[slot]
    if (not row) then
        closeRows(rows)
        return result(cid, false, "There is no Pokemon in that place.")
    end
    local left = row:getDataInt("max_training_minutes") - math.floor((os.time() - row:getDataInt("date")) / 60)
    local fee = Daycare.pricePerMinute(row:getDataInt("pokemon_level")) * trainedMinutes(row)
    local name = row:getDataString("pokemon_name")
    if (not cancelled and left > 0) then
        closeRows(rows)
        return result(cid, false, "%s still trains for %s. You can stop the training, but it won't get any EXP.", name,
            table.concat(string.timediff(left * 60, cid)))
    elseif (getPlayerMoney(cid) < fee) then
        closeRows(rows)
        return result(cid, false, "You need %d dollars to take %s back.", fee, name)
    end
    local ball = giveBack(cid, row, cancelled)
    if (not ball) then
        closeRows(rows)
        log(LOG_TYPES.ERROR, "Daycare.withdraw - Can't create the ball.", getCreatureName(cid), slot)
        return result(cid, false, "Something went wrong. Please try again later.")
    end
    if (not db.executeQuery(string.format("DELETE FROM `%s` WHERE `player_id` = %d;", TABLES[slot], getPlayerGUID(cid)))) then
        doRemoveItem(ball)
        closeRows(rows)
        return result(cid, false, "Something went wrong. Please try again later.")
    end
    closeRows(rows)
    doPlayerRemoveMoney(cid, fee)
    doPlayerSave(cid) -- no clone balls
    Daycare.sendState(cid)
    return result(cid, true, cancelled and "%s is back, without the training." or "%s is back from the Day Care.", name)
end

-- Gives the waiting egg(s); returns the count and species, or nil
Daycare.handOverEgg = function(cid)
    local egg = getPendingEgg(cid)
    if (not egg) then
        return nil
    end
    local plate = plateOf(cid)
    for _ = 1, egg.count do
        local uid = doPlayerAddItem(cid, eggIdOf(egg.species), 1, true)
        PokemonStats.setEggStats(uid, egg.ivs, egg.natureId)
        if (PokemonEgg.doGenerateEggMove(uid, egg.species, plate and TYPE_BY_PLATE_ITEMID[plate] or nil) and plate) then
            db.executeQuery(string.format("DELETE FROM `daycare_plates` WHERE `player_id` = %d;", getPlayerGUID(cid)))
            plate = nil
        end
    end
    setPlayerStorageValue(cid, EGG, -1)
    doPlayerSave(cid)
    return egg.count, eggSpeciesName(egg.species)
end

Daycare.collect = function(cid)
    closeRows(readSlots(cid))
    local count, species = Daycare.handOverEgg(cid)
    if (not count) then
        return result(cid, false, "There is no egg yet.")
    end
    Daycare.sendState(cid)
    return result(cid, true, count > 1 and "You got two %s eggs!" or "You got a %s egg!", species)
end

Daycare.setPlate = function(cid, itemId)
    local current = plateOf(cid)
    itemId = tonumber(itemId)
    if (not itemId) then
        if (not current) then
            return result(cid, false, "You have no plate here.")
        end
        db.executeQuery(string.format("DELETE FROM `daycare_plates` WHERE `player_id` = %d;", getPlayerGUID(cid)))
        doPlayerSafeAddItem(cid, current, 1, true)
        Daycare.sendState(cid)
        return result(cid, true, "Your %s is back.", PLATE_NAME_BY_ITEMID[current] or "plate")
    end
    if (current) then
        return result(cid, false, "There is a plate here already. Take it back first.")
    elseif (not PLATE_NAME_BY_ITEMID[itemId] or getPlayerItemCount(cid, itemId) < 1) then
        return result(cid, false, "You don't have that plate.")
    end
    if (not db.executeQuery(string.format("INSERT INTO `daycare_plates` (`player_id`, `item_id`) VALUES (%d, %d);",
            getPlayerGUID(cid), itemId))) then
        return result(cid, false, "Something went wrong. Please try again later.")
    end
    doPlayerRemoveItem(cid, itemId, 1)
    Daycare.sendState(cid)
    return result(cid, true, "The %s will guide the next egg's move.", PLATE_NAME_BY_ITEMID[itemId])
end

Daycare.onClientMessage = function(cid, buffer)
    local ok, data = pcall(JSON.decode, buffer)
    if (not ok or type(data) ~= "table") then
        return
    end
    local action = tostring(data.action or "")
    if (action == "hello") then
        setPlayerStorageValue(cid, CLIENT, 1)
        return
    end
    if (not Daycare.isNear(cid)) then
        result(cid, false, "Talk to a Day Care keeper to use the Day Care.")
        return
    end
    if (action == "refresh") then
        Daycare.sendState(cid)
    elseif (action == "deposit") then
        Daycare.deposit(cid, data.key, data.minutes)
    elseif (action == "withdraw") then
        Daycare.withdraw(cid, data.slot, false)
    elseif (action == "cancel") then
        Daycare.withdraw(cid, data.slot, true)
    elseif (action == "collect") then
        Daycare.collect(cid)
    elseif (action == "plate") then
        Daycare.setPlate(cid, data.item)
    end
end
