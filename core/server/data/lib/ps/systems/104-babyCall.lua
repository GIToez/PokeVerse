-- A wild baby Pokemon hit by a trainer's Pokemon cries out (its own cry), and the wild Pokemon of its
-- evolution line within RANGE_X x RANGE_Y on its floor turn on the attacker: Pichu calls Pikachu and Raichu.
-- The range reaches past the client's screen (11 x 7 tiles from the middle); a monster drops a target outside
-- its view (Map::maxViewportX/Y, 13 x 11), so only those that have the attacker in view answer.
-- Once every COOLDOWN seconds per baby.

BabyCall = {}

BabyCall.RANGE_X = 12
BabyCall.RANGE_Y = 9
local VIEW_X, VIEW_Y = 13, 11
BabyCall.COOLDOWN = 30
BabyCall.BABIES = {
    "Pichu", "Cleffa", "Igglybuff", "Togepi", "Tyrogue", "Smoochum", "Elekid", "Magby", "Azurill", "Wynaut",
    "Budew", "Chingling", "Bonsly", "Mime Jr.", "Happiny", "Munchlax", "Mantyke",
}

local lines -- baby -> { species = true } of the Pokemon it evolves into, at any stage
local voices = {}
local lastCall = {}
local lastCallCount = 0

local function speciesOf(cid)
    local name = getCreatureName(cid)
    return name:sub(1, 6) == "Shiny " and name:sub(7) or name
end

local function addEvolutions(line, name)
    local pokemon = getPokemonDefinition(name)
    for _, evolution in ipairs(pokemon and pokemon.evolutions or {}) do
        if (not line[evolution.name]) then
            line[evolution.name] = true
            addEvolutions(line, evolution.name)
        end
    end
end

BabyCall.lineOf = function(baby)
    if (not lines) then
        lines = {}
        for _, name in ipairs(BabyCall.BABIES) do
            if (getPokemonDefinition(name)) then
                lines[name] = {}
                addEvolutions(lines[name], name)
            end
        end
    end
    return lines[baby]
end

local monsterFiles
local function voiceOf(species)
    if (voices[species] == nil) then
        if (not monsterFiles) then
            monsterFiles = {}
            local file = io.open(getDataDir() .. "monster/monsters.xml", "r")
            if (file) then
                for name, path in file:read("*a"):gmatch('<monster name="([^"]+)" file="([^"]+)"') do
                    monsterFiles[name] = path
                end
                file:close()
            end
        end
        voices[species] = false
        local path = monsterFiles[species]
        local file = path and io.open(getDataDir() .. "monster/" .. path, "r")
        if (file) then
            voices[species] = file:read("*a"):match('<voice sentence="([^"]+)"') or false
            file:close()
        end
    end
    return voices[species]
end

-- The wild Pokemon that answer: the baby's line, wild, near it on its floor, with the attacker in view
BabyCall.helpers = function(baby, attacker)
    local line = BabyCall.lineOf(speciesOf(baby))
    local helpers = {}
    if (not line) then
        return helpers
    end
    local pos, target = getCreaturePosition(baby), getCreaturePosition(attacker)
    for _, cid in ipairs(getSpectators(pos, BabyCall.RANGE_X, BabyCall.RANGE_Y, false) or {}) do
        local at = getCreaturePosition(cid)
        if (cid ~= baby and isPokemonWild(cid) and line[speciesOf(cid)] and at.z == target.z
                and math.abs(at.x - target.x) <= VIEW_X and math.abs(at.y - target.y) <= VIEW_Y) then
            helpers[#helpers + 1] = cid
        end
    end
    return helpers
end

-- Called when attacker's move hits baby; returns how many Pokemon came, or nil when it didn't call
BabyCall.onHit = function(baby, attacker)
    if (not isCreature(baby) or not isCreature(attacker) or not isPokemonWild(baby)) then
        return nil
    end
    local species = speciesOf(baby)
    if (not BabyCall.lineOf(species)) then
        return nil
    end
    local trainer = isPlayer(attacker) and attacker or getCreatureMaster(attacker)
    if (not trainer or not isPlayer(trainer)) then
        return nil
    end
    local now = os.time()
    if (lastCall[baby] and now - lastCall[baby] < BabyCall.COOLDOWN) then
        return nil
    end
    if (lastCallCount > 500) then
        for cid, time in pairs(lastCall) do
            if (not isCreature(cid) or now - time >= BabyCall.COOLDOWN) then
                lastCall[cid] = nil
                lastCallCount = lastCallCount - 1
            end
        end
    end
    if (not lastCall[baby]) then
        lastCallCount = lastCallCount + 1
    end
    lastCall[baby] = now

    doCreatureSay(baby, voiceOf(species) or (species:upper() .. "!"), TALKTYPE_MONSTER_YELL)
    doSendMagicEffect(getCreaturePosition(baby), EFFECT_EMOTION_EXCLAMATION)

    local came = 0
    for _, cid in ipairs(BabyCall.helpers(baby, attacker)) do
        if (doMonsterSetTarget(cid, attacker)) then
            came = came + 1
            doSendMagicEffect(getCreaturePosition(cid), EFFECT_EMOTION_EXCLAMATION)
        end
    end
    if (came > 0) then
        doPlayerSendTextMessage(trainer, MESSAGE_STATUS_CONSOLE_ORANGE, string.format(__L(trainer,
            "The wild %s cried out for help, and %d of its family came to its side!"), species, came))
    end
    return came
end
