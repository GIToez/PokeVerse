if (MegaEvolution) then
    return
end

-- Mega Evolution (docs/upcoming-features.md, Mega Evolution). The items are in config/megaItems.lua;
-- the stones are held items (046-heldItem.lua). A form is a config entry with megaOf (config/pokemon/)
-- and a monster file that never spawns (monster/Mega/). Mega Evolving works like Ditto's Transform:
-- the Pokemon keeps its creature and moves, and its reference name (types, stats) becomes the form.
--
-- The Mega gauge (0 to 100) is kept on the trainer and charges in combat while the Mega Ring is worn.
-- Full, the R key or the HUD button Mega Evolves the Pokemon out if it holds its stone; the gauge then
-- drains over DURATION seconds. Recalling or fainting the Pokemon, logging out or entering restricted
-- PvP ends it at once and empties the gauge.

MegaEvolution = {}

MegaEvolution.MAX = 100
MegaEvolution.DURATION = 60
-- The animation (game_megafx) runs this long before the burst, when the form, its stats and the drain start
MegaEvolution.BURST_MS = 1800
-- The players this far away see the animation
MegaEvolution.FX_RANGE_X = 9
MegaEvolution.FX_RANGE_Y = 7
-- Tournaments: the organisers' switch for every tournament until the event rules have one of their own
MegaEvolution.TOURNAMENTS = false

MegaEvolution.CHARGE = {
    HIT = 2, -- a damaging move that hits
    SUPER_EFFECTIVE = 3, -- the same, super effective (in total)
    TAKEN = 1, -- the trainer's Pokemon is hit
    BOSS_HIT = 1, -- a hit on a world boss or a legendary
    WILD_KILL = 5,
    ELITE_KILL = 10 -- world bosses, legendaries and special Pokemon (Ranger Club, dungeons and the like)
}
-- At most one charged hit a second (multi-hit and area moves charge once); hits taken and hits on
-- bosses every TAKEN_DELAY seconds; after SAME_TARGET charged hits in a row on one target its hits give 1
MegaEvolution.HIT_DELAY = 1
MegaEvolution.TAKEN_DELAY = 2
MegaEvolution.SAME_TARGET = 15
-- Each wild Pokemon of a stone's evolution line drops it at 1 in DROP_CHANCE (one roll a defeat; a line with
-- two stones, like Charizard's, gives either). Wild Groudon and Kyogre drop their orbs at 1 in ORB_DROP_CHANCE.
MegaEvolution.DROP_CHANCE = 250000
MegaEvolution.ORB_DROP_CHANCE = 250000

-- Every script interface (actions, talkactions, creature scripts...) has its own copy of this file, so the
-- state lives in storages, never in Lua tables. A storage string starting with a digit reads back as that
-- number, so the packed values start with a letter.
local GAUGE = playersStorages.megaGauge
local ACTIVE = playersStorages.megaActive
local CLIENT = playersStorages.megaClient
local CHARGES = playersStorages.megaCharges
local PVP = playersStorages.megaPvp

-- The abilities that boost the Pokemon's own moves, so those moves glow on the moves bar
local BOOSTING = {
    [POKEMON_SPECIAL_ABILITY_IDS.DROUGHT] = true,
    [POKEMON_SPECIAL_ABILITY_IDS.DRIZZLE] = true,
    [POKEMON_SPECIAL_ABILITY_IDS.TOUGH_CLAWS] = true,
    [POKEMON_SPECIAL_ABILITY_IDS.MEGA_LAUNCHER] = true
}

-- The trainer's Mega while it lasts: { token, pokemon, left, form }, or nil. Before the burst the
-- Pokemon is not the form yet.
local function readActive(cid)
    local value = isPlayer(cid) and getPlayerStorageValue(cid, ACTIVE)
    local token, pokemon, left, form = tostring(value or ""):match("^M(%d+)|(%d+)|(%-?%d+)|?(.*)$")
    if (not token) then
        return nil
    end
    return { token = token, pokemon = tonumber(pokemon), left = tonumber(left), form = form ~= "" and form or nil }
end

local function writeActive(cid, active)
    setPlayerStorageValue(cid, ACTIVE, active and string.format("M%s|%d|%d|%s", active.token, active.pokemon, active.left,
        active.form or "") or -1)
end

-- The animation for the players around the Pokemon whose client has the Mega HUD (game_megafx)
local function sendFx(pokemon, data)
    if (not isCreature(pokemon)) then
        return
    end
    data.type, data.pokemon = "fx", pokemon
    local payload = JSON.encode(data)
    for _, spectator in ipairs(getSpectators(getCreaturePosition(pokemon), MegaEvolution.FX_RANGE_X,
            MegaEvolution.FX_RANGE_Y, false) or {}) do
        if (isPlayer(spectator) and getPlayerStorageValue(spectator, CLIENT) == 1) then
            doSendPlayerExtendedOpcode(spectator, EXTENDED_IDS.MEGA, payload)
        end
    end
end

MegaEvolution.hasForm = function(formName)
    local definition = getPokemonDefinition(formName)
    return definition ~= nil and definition.megaOf ~= nil
end

-- The form a Pokemon becomes with this stone ("Shiny Mega Charizard X" for a Shiny Charizard), or nil
MegaEvolution.formFor = function(pokemonName, stone)
    local shiny = pokemonName:find("^Shiny ") ~= nil
    local species = shiny and pokemonName:sub(7) or pokemonName
    if (not stone or stone.pokemon ~= species or not MegaEvolution.hasForm(stone.form)) then
        return nil
    end
    return shiny and ("Shiny " .. stone.form) or stone.form
end

MegaEvolution.isMega = function(pokemon)
    return isPokemonTransformed(pokemon) and MegaEvolution.hasForm(getPokemonCurrentTransformation(pokemon))
end

MegaEvolution.isActive = function(cid)
    return readActive(cid) ~= nil
end

-- True while the Pokemon of this ball is Mega Evolved, so its stone stays on
MegaEvolution.isStoneLocked = function(cid, ballUid)
    return readActive(cid) ~= nil and getPlayerBall(cid).uid == ballUid
end

MegaEvolution.hasRing = function(cid)
    return getPlayerSlotItem(cid, PLAYER_SLOT_KEY_ITEM).itemid == MEGA_ITEM_IDS.RING
end

MegaEvolution.getGauge = function(cid)
    return math.max(0, math.min(MegaEvolution.MAX, getPlayerStorageValue(cid, GAUGE)))
end

local function setGauge(cid, value)
    setPlayerStorageValue(cid, GAUGE, math.max(0, math.min(MegaEvolution.MAX, math.ceil(value))))
end

-- The Mega form the trainer's Pokemon out can become now with the stone it holds, or nil
MegaEvolution.readyForm = function(cid)
    local pokemon, ball = getPlayerPokemon(cid), getPlayerBall(cid)
    if (not isCreature(pokemon) or not isItem(ball) or isPokemonTransformed(pokemon)) then
        return nil
    end
    return MegaEvolution.formFor(getCreatureName(pokemon), PokemonHeldItem.getMegaStone(ball.uid))
end

-- The moves of the Pokemon out that its Mega ability boosts
MegaEvolution.boostedMoves = function(cid)
    local active = readActive(cid)
    local form = active and isCreature(active.pokemon) and getPokemonCurrentTransformation(active.pokemon)
    local ability = MegaEvolution.hasForm(tostring(form)) and getPokemonRandomSpecialAbility(form)
    local moves = {}
    if (not ability or not BOOSTING[ability]) then
        return moves
    end
    local ball = getPlayerBall(cid)
    for _, move in ipairs(getPokemonSkills(form, ball.uid)) do
        if (getPokemonSkillExists(move) and getPokemonSpecialAbilityMoveCheck(ability, move)) then
            moves[#moves + 1] = move
        end
    end
    return moves
end

-- The HUD: whether the ring is worn, the gauge, whether the button is lit, and the Mega while it lasts
MegaEvolution.state = function(cid)
    local active = readActive(cid)
    local state = { type = "state", ring = MegaEvolution.hasRing(cid), gauge = MegaEvolution.getGauge(cid),
                    max = MegaEvolution.MAX, active = active ~= nil }
    if (active) then
        state.form = active.form or (isCreature(active.pokemon) and getPokemonCurrentTransformation(active.pokemon)) or nil
        state.left, state.duration = active.left, MegaEvolution.DURATION
        state.boosted = MegaEvolution.boostedMoves(cid)
    else
        state.ready = state.ring and state.gauge >= MegaEvolution.MAX and MegaEvolution.readyForm(cid) ~= nil
    end
    return state
end

MegaEvolution.send = function(cid)
    if (isPlayer(cid) and getPlayerStorageValue(cid, CLIENT) == 1) then
        doSendPlayerExtendedOpcode(cid, EXTENDED_IDS.MEGA, JSON.encode(MegaEvolution.state(cid)))
    end
end

local function showForm(cid, pokemon, name)
    local info = getMonsterInfo(name)
    doCreatureChangeOutfit(pokemon, info.outfit)
    if (isPlayer(cid)) then
        doPlayerUpdatePokemonIcons(cid, name, true)
    end
end

-- Turns the trainer's Pokemon into the form; it turns back with MegaEvolution.revert or when called
-- back (the form lives on the creature, not the ball)
MegaEvolution.apply = function(cid, pokemon, formName)
    if (not isCreature(pokemon) or not MegaEvolution.hasForm(formName) or isPokemonTransformed(pokemon)) then
        return false
    end
    doCreatureSetStorage(pokemon, pokemonsStorages.megaAbility, getMonsterSpecialAbility(pokemon))
    doCreatureSetStorage(pokemon, pokemonsStorages.transform, formName)
    setMonsterSpecialAbility(pokemon, getPokemonRandomSpecialAbility(formName))
    showForm(cid, pokemon, formName)
    doSendMagicEffect(getCreaturePosition(pokemon), EFFECT_TRIPLE_SPARK)
    return true
end

MegaEvolution.revert = function(cid, pokemon)
    if (not isCreature(pokemon) or not MegaEvolution.isMega(pokemon)) then
        return false
    end
    doCreatureSetStorage(pokemon, pokemonsStorages.transform, EMPTY_STORAGE)
    local ability = getCreatureStorage(pokemon, pokemonsStorages.megaAbility)
    if (ability ~= EMPTY_STORAGE) then
        setMonsterSpecialAbility(pokemon, ability)
    end
    doCreatureSetStorage(pokemon, pokemonsStorages.megaAbility, EMPTY_STORAGE)
    showForm(cid, pokemon, getCreatureName(pokemon))
    doSendMagicEffect(getCreaturePosition(pokemon), EFFECT_TRIPLE_SPARK)
    return true
end

local function lockRing(cid, locked)
    local ring = getPlayerSlotItem(cid, PLAYER_SLOT_KEY_ITEM)
    if (isItem(ring) and ring.itemid == MEGA_ITEM_IDS.RING) then
        setItemScriptProtected(ring.uid, locked)
    end
end

-- Ends the trainer's Mega Evolution: the Pokemon turns back if it is still out, and the gauge is empty
MegaEvolution.finish = function(cid, quiet)
    local active = readActive(cid)
    if (not active) then
        return false
    end
    writeActive(cid, nil)
    if (isCreature(active.pokemon)) then
        MegaEvolution.revert(cid, active.pokemon)
        sendFx(active.pokemon, { phase = "end" })
    end
    if (isPlayer(cid)) then
        setGauge(cid, 0)
        lockRing(cid, false)
        if (not quiet) then
            MegaEvolution.send(cid)
        end
    end
    return true
end

local function stillOn(cid, active)
    return isPlayer(cid) and isCreature(active.pokemon) and getPlayerPokemon(cid) == active.pokemon
        and MegaEvolution.isMega(active.pokemon) and MegaEvolution.hasRing(cid)
end

-- One second of the drain; false once the Mega is over
local function step(cid, token)
    local active = readActive(cid)
    if (not active or (token and active.token ~= token)) then
        return false
    elseif (not stillOn(cid, active)) then
        MegaEvolution.finish(cid)
        return false
    end
    active.left = active.left - 1
    if (active.left <= 0) then
        MegaEvolution.finish(cid)
        return false
    end
    writeActive(cid, active)
    setGauge(cid, MegaEvolution.MAX * active.left / MegaEvolution.DURATION)
    MegaEvolution.send(cid)
    return true
end

MegaEvolution.step = function(cid)
    return step(cid, nil)
end

local function tick(cid, token)
    if (step(cid, token)) then
        addEvent(tick, 1000, cid, token)
    end
end

-- Restricted PvP: duels, the PvP arenas and tournaments. Entering one empties the gauge and ends a Mega,
-- so no charge is brought in
local function pvpContext(cid)
    if (getPlayerTournamentReady(cid)) then
        return "tournament"
    elseif (isPlayerOnPvpArena(cid)) then
        return "arena"
    elseif (isDueling(cid)) then
        return "duel"
    end
    return nil
end

MegaEvolution.sync = function(cid)
    local context = pvpContext(cid)
    local last = getPlayerStorageValue(cid, PVP)
    if ((context or -1) ~= last) then
        setPlayerStorageValue(cid, PVP, context or -1)
        if (context) then
            MegaEvolution.finish(cid, true)
            setGauge(cid, 0)
            MegaEvolution.send(cid)
        end
    end
    return context
end

-- Why the trainer can't Mega Evolve now, or nil. The staff command skips the ring, gauge and place rules.
MegaEvolution.problem = function(cid, staff)
    local pokemon = getPlayerPokemon(cid)
    local context = MegaEvolution.sync(cid)
    if (not staff and not MegaEvolution.hasRing(cid)) then
        return "Wear the Mega Ring to Mega Evolve."
    elseif (not isCreature(pokemon)) then
        return "Call your Pokemon first."
    elseif (readActive(cid) or MegaEvolution.isMega(pokemon)) then
        return "Your Pokemon is already Mega Evolved."
    elseif (isPokemonTransformed(pokemon)) then
        return "A transformed Pokemon can't Mega Evolve."
    elseif (isEvolving(cid)) then
        return "Wait until your Pokemon has evolved."
    elseif (not staff and context == "tournament" and not MegaEvolution.TOURNAMENTS) then
        return "Mega Evolution is off in this tournament."
    elseif (not staff and MegaEvolution.getGauge(cid) < MegaEvolution.MAX) then
        return "Your Mega gauge isn't full yet. Fight to charge it."
    elseif (not staff and (getTilePzInfo(getCreaturePosition(cid)) or getTilePzInfo(getCreaturePosition(pokemon)))) then
        return "You can't Mega Evolve in a protection zone."
    end
    return nil
end

-- Primal Groudon and Kyogre: Primal Reversion, a Mega in all but name
local function isPrimal(form)
    return tostring(form):find("Primal ") ~= nil
end

-- The burst: the Pokemon becomes the form and the drain starts. False if the Mega was called off before it
local function burst(cid, token)
    local active = readActive(cid)
    if (not active or (token and active.token ~= token)) then
        return false
    end
    local pokemon = active.pokemon
    if (not isPlayer(cid) or not isCreature(pokemon) or getPlayerPokemon(cid) ~= pokemon or not active.form
            or not MegaEvolution.apply(cid, pokemon, active.form)) then
        MegaEvolution.finish(cid)
        return false
    end
    MegaEvolution.send(cid)
    addEvent(tick, 1000, cid, active.token)
    doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, string.format(__L(cid, isPrimal(active.form)
            and "%s underwent Primal Reversion into %s!" or "%s Mega Evolved into %s!"), getCreatureNickname(pokemon),
        active.form))
    return true
end

MegaEvolution.burst = function(cid)
    return burst(cid, nil)
end

-- Mega Evolves the trainer's Pokemon out into the form: the animation plays, and at its burst
-- (BURST_MS later) the form applies and the gauge starts draining. The ring and the stone lock at once.
MegaEvolution.start = function(cid, form, staff)
    local why = MegaEvolution.problem(cid, staff)
    if (why) then
        return false, why
    end
    local pokemon = getPlayerPokemon(cid)
    if (not MegaEvolution.hasForm(form) or isPokemonTransformed(pokemon)) then
        return false, "Your Pokemon can't Mega Evolve."
    end
    local active = { token = os.time() .. math.random(1000, 9999), pokemon = pokemon, left = MegaEvolution.DURATION,
                     form = form }
    writeActive(cid, active)
    setGauge(cid, MegaEvolution.MAX)
    lockRing(cid, true)
    MegaEvolution.send(cid)
    local base = getCreatureName(pokemon):gsub("^Shiny ", "")
    sendFx(pokemon, { phase = "evolve", trainer = cid, form = form, look = getMonsterInfo(form).outfit.lookType,
                      number = getPokemonNumberByName(base), ms = MegaEvolution.BURST_MS })
    BattleText.say(cid, "order", string.format(isPrimal(form) and "%s, Primal Reversion!" or "%s, Mega Evolve!",
        getCreatureNickname(pokemon)), { pokemon = pokemon })
    if (MegaEvolution.BURST_MS > 0) then
        addEvent(burst, MegaEvolution.BURST_MS, cid, active.token)
        return true
    end
    return burst(cid, active.token)
end

-- The R key and the HUD button
MegaEvolution.onPress = function(cid)
    local why = MegaEvolution.problem(cid)
    local form = not why and MegaEvolution.readyForm(cid)
    if (not why and not form) then
        local pokemon = getPlayerPokemon(cid)
        local stone = PokemonHeldItem.getMegaStone(getPlayerBall(cid).uid)
        if (stone and stone.pokemon == getCreatureName(pokemon):gsub("^Shiny ", "")) then
            why = string.format(__L(cid, "%s isn't in the game yet."), stone.form)
        else
            why = "Your Pokemon needs to hold its own Mega Stone."
        end
    end
    if (why) then
        doPlayerSendCancel(cid, __L(cid, why))
        return false
    end
    local ok, problem = MegaEvolution.start(cid, form)
    if (not ok) then
        doPlayerSendCancel(cid, __L(cid, problem))
        return false
    end
    return true
end

local function charge(cid, amount)
    if (amount <= 0 or not isPlayer(cid) or readActive(cid) or not MegaEvolution.hasRing(cid)) then
        return false
    end
    MegaEvolution.sync(cid)
    local before = MegaEvolution.getGauge(cid)
    if (before >= MegaEvolution.MAX) then
        return false
    end
    setGauge(cid, before + amount)
    MegaEvolution.send(cid)
    return true
end
MegaEvolution.charge = charge

local LEGENDARIES = {}
for _, species in ipairs(WildLegendaries and WildLegendaries.SPECIES or {}) do
    LEGENDARIES[species.name] = true
end

local function isBoss(target)
    local name = getCreatureName(target):gsub("^Shiny ", "")
    return WorldBoss.get(getCreatureName(target)) ~= nil or LEGENDARIES[name] == true
end

-- When the trainer last charged from a hit, a hit taken and a boss hit, and the target of its last hits
local function chargesOf(cid)
    local hit, taken, boss, target, streak = tostring(getPlayerStorageValue(cid, CHARGES)):match("^C(%d+)|(%d+)|(%d+)|(%d+)|(%d+)$")
    return { hit = tonumber(hit) or 0, taken = tonumber(taken) or 0, boss = tonumber(boss) or 0,
             target = tonumber(target) or 0, streak = tonumber(streak) or 0 }
end

local function saveCharges(cid, state)
    setPlayerStorageValue(cid, CHARGES, string.format("C%d|%d|%d|%d|%d", state.hit, state.taken, state.boss, state.target,
        state.streak))
end

-- A damaging move hit (004-skillDamage.lua): the attacker's trainer charges, and so does the target's
MegaEvolution.onHit = function(fromCid, toCid, skillName)
    if (not isMonster(fromCid) or not isCreature(toCid)) then
        return
    end
    local now = os.time()
    local attacker, defender = getCreatureMaster(fromCid), getCreatureMaster(toCid)
    if (isPlayer(attacker) and attacker ~= fromCid and isMonster(toCid) and defender ~= attacker) then
        local state = chargesOf(attacker)
        if (isBoss(toCid)) then
            if (now - state.boss >= MegaEvolution.TAKEN_DELAY) then
                state.boss = now
                saveCharges(attacker, state)
                charge(attacker, MegaEvolution.CHARGE.BOSS_HIT)
            end
        elseif (now - state.hit >= MegaEvolution.HIT_DELAY) then
            state.hit = now
            state.streak = state.target == toCid and state.streak + 1 or 1
            state.target = toCid
            local amount = getSkillElementMultiplier(fromCid, toCid, skillName) >= 2 and MegaEvolution.CHARGE.SUPER_EFFECTIVE
                    or MegaEvolution.CHARGE.HIT
            if (state.streak > MegaEvolution.SAME_TARGET) then
                amount = 1
            end
            saveCharges(attacker, state)
            charge(attacker, amount)
        end
    end
    if (isPlayer(defender) and defender ~= toCid and defender ~= attacker) then
        local state = chargesOf(defender)
        if (now - state.taken >= MegaEvolution.TAKEN_DELAY) then
            state.taken = now
            saveCharges(defender, state)
            charge(defender, MegaEvolution.CHARGE.TAKEN)
        end
    end
end

-- The trainer's side defeated a wild Pokemon (onKill)
MegaEvolution.onKill = function(cid, target)
    if (not isPlayer(cid) or not isMonster(target) or not isPokemonWild(target)) then
        return
    end
    local elite = isBoss(target) or not isPokemonName(getCreatureName(target))
    charge(cid, elite and MegaEvolution.CHARGE.ELITE_KILL or MegaEvolution.CHARGE.WILD_KILL)
    MegaEvolution.rollDrop(cid, getCreatureName(target))
    MegaEvolution.onResearchDefeat(cid, getCreatureName(target))
end

local dropsBySpecies
-- The stones a wild Pokemon of this name can drop (its shiny counts as the same species), or nil
MegaEvolution.getDrops = function(name)
    if (not dropsBySpecies) then
        dropsBySpecies = {}
        for _, stone in ipairs(MEGA_STONES) do
            local species, steps = stone.pokemon, 0
            while (species and steps < 5) do
                dropsBySpecies[species] = dropsBySpecies[species] or {}
                table.insert(dropsBySpecies[species], stone)
                species, steps = getPokemonPreEvolution(species), steps + 1
            end
        end
    end
    return dropsBySpecies[(name:gsub("^Shiny ", ""))]
end

MegaEvolution.rollDrop = function(cid, name)
    local drops = MegaEvolution.getDrops(name)
    if (not drops) then
        return nil
    end
    local orb = drops[1].form:find("^Primal") ~= nil
    if (math.random(orb and MegaEvolution.ORB_DROP_CHANCE or MegaEvolution.DROP_CHANCE) ~= 1) then
        return nil
    end
    local stone = drops[math.random(#drops)]
    doPlayerSafeAddItem(cid, stone.itemId, 1, false)
    doSendMagicEffect(getCreaturePosition(cid), EFFECT_FIREWORK_BLUE)
    doPlayerSendTextMessage(cid, MESSAGE_EVENT_ADVANCE, string.format(__L(cid, "The %s dropped %s!"),
        __L(cid, name), __L(cid, stone.name)))
    return stone
end

---------------------------------------------------------------------------------------------------
-- Professor Oak's Mega Ring quests (config/003-quest.lua, Professor Oak). The research: defeat
-- RESEARCH_EACH wild Pokemon from each of RESEARCH_LINES Mega Stone lines, for the empty Mega Ring.
-- Then the Key Stone: use the glowing crystal deep in Cerulean Cave, defeat the Guardian Alakazam
-- that comes out of it, put the Key Stone on the ring and show Oak the Mega Ring, for the stone of
-- the trainer's starter.
---------------------------------------------------------------------------------------------------

MegaEvolution.RESEARCH_QUEST = 8760
MegaEvolution.KEY_STONE_QUEST = 8761
MegaEvolution.KEY_STONE_FOUND = 8762 -- finished once the guardian gave the trainer the Key Stone
MegaEvolution.STONE_CHOICE = 8763 -- started while Oak waits for the trainer to pick a stone
MegaEvolution.RESEARCH_LINES = 3
MegaEvolution.RESEARCH_EACH = 50
MegaEvolution.CRYSTAL = { x = 3825, y = 166, z = 11 }
MegaEvolution.CRYSTAL_ITEM = 8636
MegaEvolution.CRYSTAL_ACTION = 30761
MegaEvolution.GUARDIAN = "Guardian Alakazam"
MegaEvolution.GUARDIAN_TIME = 10 * 60
MegaEvolution.STARTER_LINES = { Bulbasaur = "Venusaur", Charmander = "Charizard", Squirtle = "Blastoise" }

local RESEARCH = playersStorages.megaResearch
local STARTER = playersStorages.megaStarter

local function readResearch(cid)
    local counts, value = {}, getPlayerStorageValue(cid, RESEARCH)
    if (type(value) == "string" and value:sub(1, 1) == "R") then
        for line, count in value:sub(2):gmatch("([^=,]+)=(%d+)") do
            counts[line] = tonumber(count)
        end
    end
    return counts
end

-- have and need: the best RESEARCH_LINES lines count up to RESEARCH_EACH each
MegaEvolution.researchProgress = function(cid)
    local list = {}
    for _, count in pairs(readResearch(cid)) do
        list[#list + 1] = math.min(count, MegaEvolution.RESEARCH_EACH)
    end
    table.sort(list, function(a, b) return a > b end)
    local have = 0
    for i = 1, math.min(#list, MegaEvolution.RESEARCH_LINES) do
        have = have + list[i]
    end
    return have, MegaEvolution.RESEARCH_LINES * MegaEvolution.RESEARCH_EACH
end

local function oakQuest(storage)
    for _, quest in ipairs(getNpcQuests("Professor Oak") or {}) do
        if (quest.storage == storage) then
            return quest
        end
    end
end

MegaEvolution.onResearchDefeat = function(cid, name)
    if (getPlayerStorageValue(cid, MegaEvolution.RESEARCH_QUEST) ~= QUEST_STATUS.STARTED) then
        return
    end
    local drops = MegaEvolution.getDrops(name)
    if (not drops or drops[1].form:find("^Primal")) then
        return
    end
    local line = drops[1].pokemon
    local counts = readResearch(cid)
    if ((counts[line] or 0) >= MegaEvolution.RESEARCH_EACH) then
        return
    end
    counts[line] = (counts[line] or 0) + 1
    local parts = {}
    for key, count in pairs(counts) do
        parts[#parts + 1] = key .. "=" .. count
    end
    setPlayerStorageValue(cid, RESEARCH, "R" .. table.concat(parts, ","))

    local have, need = MegaEvolution.researchProgress(cid)
    local quest = oakQuest(MegaEvolution.RESEARCH_QUEST)
    if (not quest or not Quests.onProgress(cid, quest, have, need)) then
        doPlayerSendTextMessage(cid, MESSAGE_EVENT_ADVANCE, string.format(__L(cid, "Mega research: %s line %d/%d [%d/%d]."),
            __L(cid, line), counts[line], MegaEvolution.RESEARCH_EACH, have, need))
    end
end

-- Worn or in the bag (hasRing is only the worn one)
MegaEvolution.ownsRing = function(cid)
    return MegaEvolution.hasRing(cid) or getPlayerItemCount(cid, MEGA_ITEM_IDS.RING) > 0
end

-- The starter's line ("Charizard"), from what Oak wrote down or, for trainers from before that, the
-- one Pokemon they carry with their own original trainer mark (only starters get it); nil if unknown
MegaEvolution.starterLine = function(cid)
    local starter = getPlayerStorageValue(cid, STARTER)
    if (MegaEvolution.STARTER_LINES[starter]) then
        return MegaEvolution.STARTER_LINES[starter]
    end
    local guid, found = getPlayerGUID(cid), nil
    for _, ball in ipairs(getPlayerAllBallsWithPokemon(cid)) do
        if (getBallOriginalTrainer(ball.uid) == guid) then
            local species, steps = getBallPokemonName(ball.uid), 0
            while (getPokemonPreEvolution(species) and steps < 5) do
                species, steps = getPokemonPreEvolution(species), steps + 1
            end
            local line = MegaEvolution.STARTER_LINES[species]
            if (line and found and found ~= line) then
                return nil
            end
            found = line or found
        end
    end
    return found
end

-- The stones Oak can give: the starter's (Charizard has two), or all four if he can't tell
MegaEvolution.starterStones = function(cid)
    local line, list = MegaEvolution.starterLine(cid), {}
    for _, stone in ipairs(MEGA_STONES) do
        if ((line and stone.pokemon == line) or (not line and table.find({ "Venusaur", "Charizard", "Blastoise" }, stone.pokemon))) then
            list[#list + 1] = stone
        end
    end
    return list
end

local function giveStone(cid, stone)
    doPlayerSafeAddItem(cid, stone.itemId, 1, true, true)
    doCreatureSetStorage(cid, MegaEvolution.STONE_CHOICE, QUEST_STATUS.FINISHED)
    doSendMagicEffect(getCreaturePosition(cid), EFFECT_FIREWORK_BLUE)
end

-- Key Stone quest's end (said by Oak): one stone is given now; with a choice, Oak asks which
MegaEvolution.onKeyStoneQuestEnd = function(cid)
    local stones = MegaEvolution.starterStones(cid)
    if (#stones == 1) then
        giveStone(cid, stones[1])
        selfSay(string.format(__L(cid, "And this is for your partner from the very beginning: %s. Let it hold the stone, and when your Mega gauge is full, Mega Evolve it!"), __L(cid, stones[1].name)), cid)
        return
    end
    doCreatureSetStorage(cid, MegaEvolution.STONE_CHOICE, QUEST_STATUS.STARTED)
    MegaEvolution.askStone(cid, stones)
end

MegaEvolution.askStone = function(cid, stones)
    local names = {}
    for _, stone in ipairs(stones or MegaEvolution.starterStones(cid)) do
        names[#names + 1] = "{" .. __L(cid, stone.name) .. "}"
    end
    selfSay(string.format(__L(cid, "One more thing: a stone for your first partner. Which one do you want? %s"),
        table.concat(names, ", ")), cid)
end

-- Oak's chat while he waits for the pick: true when the message was about it
MegaEvolution.onStoneChoiceTalk = function(cid, msg)
    if (getPlayerStorageValue(cid, MegaEvolution.STONE_CHOICE) ~= QUEST_STATUS.STARTED) then
        return false
    end
    local stones, text = MegaEvolution.starterStones(cid), msg:lower()
    for _, stone in ipairs(stones) do
        local name = stone.name:lower()
        local suffix = name:match(" (%a)$")
        if (text:find(name, 1, true) or (suffix and #stones == 2 and stones[1].pokemon == stones[2].pokemon
                and (text == suffix or text:find("^" .. suffix .. "[%s%p]*$")))) then
            giveStone(cid, stone)
            selfSay(string.format(__L(cid, "Here is %s. Let your partner hold it, and when your Mega gauge is full, Mega Evolve it!"), __L(cid, stone.name)), cid)
            return true
        end
    end
    MegaEvolution.askStone(cid, stones)
    return true
end

-- The crystal in Cerulean Cave (actions.xml, by its action id; placed on the map at startup)
MegaEvolution.placeCrystal = function()
    local item = getTileItemById(MegaEvolution.CRYSTAL, MegaEvolution.CRYSTAL_ITEM)
    if (not isItem(item)) then
        item = { uid = doCreateItem(MegaEvolution.CRYSTAL_ITEM, 1, MegaEvolution.CRYSTAL) }
    end
    if (not item.uid or item.uid == 0) then
        log(LOG_TYPES.ERROR, "MegaEvolution.placeCrystal - Can't place the Key Stone crystal.")
        return
    end
    doItemSetAttribute(item.uid, "aid", MegaEvolution.CRYSTAL_ACTION)
end

local guardian
MegaEvolution.onCrystalUse = function(cid, item)
    if (getPlayerStorageValue(cid, MegaEvolution.KEY_STONE_QUEST) ~= QUEST_STATUS.STARTED) then
        doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, __L(cid, "The crystal glows with a strange light."))
    elseif (getPlayerStorageValue(cid, MegaEvolution.KEY_STONE_FOUND) == QUEST_STATUS.FINISHED) then
        doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, __L(cid, "The crystal is quiet now. You already have its Key Stone."))
    elseif (isCreature(guardian)) then
        doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, __L(cid, "The Guardian Alakazam is already here!"))
    else
        local position = getThingPosition(item.uid)
        doSendMagicEffect(position, EFFECT_TELEPORT_UP)
        guardian = doCreateMonster(MegaEvolution.GUARDIAN, { x = position.x - 1, y = position.y + 1, z = position.z }, false)
        if (isCreature(guardian)) then
            doCreatureSay(guardian, "ALAKAZAM!", TALKTYPE_MONSTER)
            addEvent(function(creature) if (isCreature(creature)) then doRemoveCreature(creature) end end,
                MegaEvolution.GUARDIAN_TIME * 1000, guardian)
        end
        return guardian
    end
    return nil
end

-- The guardian falls (creaturescripts, prepareDeath): every trainer on the quest who fought it gets the Key Stone
MegaEvolution.onGuardianDeath = function(guardianCid, deathList)
    local position = getCreaturePosition(guardianCid)
    doSendMagicEffect(position, EFFECT_TELEPORT_UP)
    doRemoveCreature(guardianCid)
    local done = {}
    for _, killer in ipairs(deathList or {}) do
        local player = isPlayer(killer) and killer or (isCreature(killer) and getCreatureMaster(killer))
        if (isPlayer(player) and not done[player]
                and getPlayerStorageValue(player, MegaEvolution.KEY_STONE_QUEST) == QUEST_STATUS.STARTED
                and getPlayerStorageValue(player, MegaEvolution.KEY_STONE_FOUND) ~= QUEST_STATUS.FINISHED) then
            done[player] = true
            doPlayerSafeAddItem(player, MEGA_ITEM_IDS.KEY_STONE, 1, true, true)
            doCreatureSetStorage(player, MegaEvolution.KEY_STONE_FOUND, QUEST_STATUS.FINISHED)
            doPlayerSendTextMessage(player, MESSAGE_EVENT_ADVANCE, __L(player, "As the guardian fades, the crystal's light gathers into a small stone: the Key Stone! Use it on your empty Mega Ring."))
        end
    end
    return false
end

-- The Mega Ring put on or taken off
MegaEvolution.onRingChange = function(cid)
    MegaEvolution.send(cid)
end

MegaEvolution.onLogin = function(cid)
    setPlayerStorageValue(cid, CLIENT, -1)
    if (readActive(cid)) then -- the server stopped during a Mega
        writeActive(cid, nil)
        setGauge(cid, 0)
        lockRing(cid, false)
    end
end

MegaEvolution.onLogout = function(cid)
    MegaEvolution.finish(cid, true)
    setPlayerStorageValue(cid, CHARGES, -1)
    setPlayerStorageValue(cid, PVP, -1)
end

MegaEvolution.onClientMessage = function(cid, buffer)
    local ok, data = pcall(JSON.decode, buffer)
    if (not ok or type(data) ~= "table") then
        return
    end
    if (data.action == "hello") then
        setPlayerStorageValue(cid, CLIENT, 1)
        MegaEvolution.sync(cid)
        MegaEvolution.send(cid)
    elseif (data.action == "evolve") then
        MegaEvolution.onPress(cid)
    end
end

-- /mega (staff): Mega Evolves the trainer's Pokemon through its held stone, or the form named by the
-- parameter ("x", "y") when it holds none, without the ring or the gauge; "/mega off" turns it back,
-- "/mega full" fills the gauge
MegaEvolution.onStaffCommand = function(cid, param)
    param = (param or ""):lower():trim()
    if (param == "full") then
        setGauge(cid, MegaEvolution.MAX)
        MegaEvolution.send(cid)
        doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Your Mega gauge is full.")
        return true
    end
    local pokemon, ball = getPlayerPokemon(cid), getPlayerBall(cid)
    if (not isCreature(pokemon) or not isItem(ball)) then
        doPlayerSendCancel(cid, "Call your Pokemon first.")
        return false
    end
    if (param == "off") then
        if (not MegaEvolution.finish(cid) and not MegaEvolution.revert(cid, pokemon)) then
            doPlayerSendCancel(cid, "Your Pokemon isn't Mega Evolved.")
            return false
        end
        return true
    end

    local name = getCreatureName(pokemon)
    local form = MegaEvolution.formFor(name, PokemonHeldItem.getMegaStone(ball.uid))
    if (not form) then
        local species = name:gsub("^Shiny ", "")
        for _, stone in ipairs(MEGA_STONES) do
            local candidate = MegaEvolution.formFor(name, stone)
            if (stone.pokemon == species and candidate and (param == "" or stone.form:lower():find(" " .. param .. "$"))) then
                form = candidate
                break
            end
        end
    end
    if (not form) then
        doPlayerSendCancel(cid, string.format(__L(cid, "%s has no Mega form in the game yet."), name))
        return false
    end
    local ok, why = MegaEvolution.start(cid, form, true)
    if (not ok) then
        doPlayerSendCancel(cid, __L(cid, why))
        return false
    end
    return true
end

-- The ring and its parts are unique items (they can't be dropped, traded or sold); one given
-- before they were becomes the trainer's when it is used or worn
MegaEvolution.claim = function(cid, uid)
    if (isPlayer(cid) and getItemUniqueOwner(uid) == ITEM_UNIQUE_OWNER_NONE) then
        setItemUniqueOwner(uid, cid)
    end
end

-- The empty Mega Ring and the Key Stone: either used on the other, both in the trainer's bag,
-- become the Mega Ring
MegaEvolution.onRingPartUse = function(cid, item, fromPosition, itemEx, toPosition)
    local other = item.itemid == MEGA_ITEM_IDS.EMPTY_RING and MEGA_ITEM_IDS.KEY_STONE or MEGA_ITEM_IDS.EMPTY_RING
    if (not isItem(itemEx) or itemEx.itemid ~= other) then
        doPlayerSendCancel(cid, item.itemid == MEGA_ITEM_IDS.EMPTY_RING and "Use the Key Stone on it."
                or "Use it on an empty Mega Ring.")
        return false
    elseif (fromPosition.x ~= CONTAINER_POSITION or toPosition.x ~= CONTAINER_POSITION) then
        doPlayerSendCancel(cid, "You must pick up both first.")
        return false
    end

    local ring = item.itemid == MEGA_ITEM_IDS.EMPTY_RING and item or itemEx
    local stone = item.itemid == MEGA_ITEM_IDS.KEY_STONE and item or itemEx
    doRemoveItem(stone.uid, 1)
    doTransformItem(ring.uid, MEGA_ITEM_IDS.RING)
    MegaEvolution.claim(cid, ring.uid)
    doSendMagicEffect(getCreaturePosition(cid), EFFECT_FIREWORK_BLUE)
    doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE,
        __L(cid, "The Key Stone clicks into place: you made a Mega Ring. Wear it in the key item slot."))
    return true
end

-- /megaitems (staff): the ring parts, the starter stones and the orbs, for testing
MegaEvolution.giveTestItems = function(cid)
    local ids = { MEGA_ITEM_IDS.EMPTY_RING, MEGA_ITEM_IDS.KEY_STONE }
    for _, stone in ipairs(MEGA_STONES) do
        if (stone.pokemon == "Venusaur" or stone.pokemon == "Charizard" or stone.pokemon == "Blastoise"
                or stone.form:find("^Primal")) then
            ids[#ids + 1] = stone.itemId
        end
    end
    for _, id in ipairs(ids) do
        doPlayerSafeAddItem(cid, id, 1, true, id == MEGA_ITEM_IDS.EMPTY_RING or id == MEGA_ITEM_IDS.KEY_STONE)
    end
    doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, string.format("You got %d Mega items.", #ids))
end
