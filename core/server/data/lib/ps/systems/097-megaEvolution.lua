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

local GAUGE = playersStorages.megaGauge
local ACTIVE = playersStorages.megaActive
local CLIENT = playersStorages.megaClient

-- The abilities that boost the Pokemon's own moves, so those moves glow on the moves bar
local BOOSTING = {
    [POKEMON_SPECIAL_ABILITY_IDS.DROUGHT] = true,
    [POKEMON_SPECIAL_ABILITY_IDS.DRIZZLE] = true,
    [POKEMON_SPECIAL_ABILITY_IDS.TOUGH_CLAWS] = true,
    [POKEMON_SPECIAL_ABILITY_IDS.MEGA_LAUNCHER] = true
}

local actives = {} -- [cid] = { pokemon, ball, form, left }
local charging = {} -- [cid] = { hit, taken, boss, target, streak }
local contexts = {} -- [cid] = the restricted PvP the trainer was last seen in

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
    return actives[cid] ~= nil
end

-- True while the Pokemon of this ball is Mega Evolved, so its stone stays on
MegaEvolution.isStoneLocked = function(cid, ballUid)
    local active = actives[cid]
    return active ~= nil and active.ball == ballUid
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
    local active = actives[cid]
    local ability = active and getPokemonRandomSpecialAbility(active.form)
    local moves = {}
    if (not ability or not BOOSTING[ability]) then
        return moves
    end
    local ball = getPlayerBall(cid)
    for _, move in ipairs(getPokemonSkills(active.form, ball.uid)) do
        if (getPokemonSkillExists(move) and getPokemonSpecialAbilityMoveCheck(ability, move)) then
            moves[#moves + 1] = move
        end
    end
    return moves
end

-- The HUD: whether the ring is worn, the gauge, whether the button is lit, and the Mega while it lasts
MegaEvolution.state = function(cid)
    local active = actives[cid]
    local state = { type = "state", ring = MegaEvolution.hasRing(cid), gauge = MegaEvolution.getGauge(cid),
                    max = MegaEvolution.MAX, active = active ~= nil }
    if (active) then
        state.form, state.left, state.duration = active.form, active.left, MegaEvolution.DURATION
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
    doSendMagicEffect(getCreaturePosition(pokemon), EFFECT_DITTO_TRANSFORM)
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
    doSendMagicEffect(getCreaturePosition(pokemon), EFFECT_DITTO_TRANSFORM)
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
    local active = actives[cid]
    if (not active) then
        return false
    end
    actives[cid] = nil
    if (isCreature(active.pokemon)) then
        MegaEvolution.revert(cid, active.pokemon)
    end
    if (isPlayer(cid)) then
        setPlayerStorageValue(cid, ACTIVE, -1)
        setGauge(cid, 0)
        lockRing(cid, false)
        if (not quiet) then
            MegaEvolution.send(cid)
        end
    end
    return true
end

local function stillOn(cid, active)
    local ball = getPlayerBall(cid)
    return isPlayer(cid) and isCreature(active.pokemon) and getPlayerPokemon(cid) == active.pokemon
        and MegaEvolution.isMega(active.pokemon) and isItem(ball) and ball.uid == active.ball
        and MegaEvolution.hasRing(cid)
end

-- One second of the drain; false once the Mega is over
local function step(cid, active)
    if (not active or actives[cid] ~= active) then
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
    setGauge(cid, MegaEvolution.MAX * active.left / MegaEvolution.DURATION)
    MegaEvolution.send(cid)
    return true
end

MegaEvolution.step = function(cid)
    return step(cid, actives[cid])
end

local function tick(cid, active)
    if (step(cid, active)) then
        addEvent(tick, 1000, cid, active)
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
    if (context ~= contexts[cid]) then
        contexts[cid] = context
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
    elseif (actives[cid] or MegaEvolution.isMega(pokemon)) then
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

-- Mega Evolves the trainer's Pokemon out into the form; the gauge drains from now
MegaEvolution.start = function(cid, form, staff)
    local why = MegaEvolution.problem(cid, staff)
    if (why) then
        return false, why
    end
    local pokemon, ball = getPlayerPokemon(cid), getPlayerBall(cid)
    if (not MegaEvolution.apply(cid, pokemon, form)) then
        return false, "Your Pokemon can't Mega Evolve."
    end
    local active = { pokemon = pokemon, ball = ball.uid, form = form, left = MegaEvolution.DURATION }
    actives[cid] = active
    setPlayerStorageValue(cid, ACTIVE, 1)
    setGauge(cid, MegaEvolution.MAX)
    lockRing(cid, true)
    MegaEvolution.send(cid)
    addEvent(tick, 1000, cid, active)
    return true
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
    doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE,
        string.format(__L(cid, "%s Mega Evolved into %s!"), getCreatureNickname(getPlayerPokemon(cid)), form))
    return true
end

local function charge(cid, amount)
    if (amount <= 0 or not isPlayer(cid) or actives[cid] or not MegaEvolution.hasRing(cid)) then
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

local function chargesOf(cid)
    charging[cid] = charging[cid] or { hit = 0, taken = 0, boss = 0, streak = 0 }
    return charging[cid]
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
            charge(attacker, amount)
        end
    end
    if (isPlayer(defender) and defender ~= toCid and defender ~= attacker) then
        local state = chargesOf(defender)
        if (now - state.taken >= MegaEvolution.TAKEN_DELAY) then
            state.taken = now
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
end

-- The Mega Ring put on or taken off
MegaEvolution.onRingChange = function(cid)
    MegaEvolution.send(cid)
end

-- The trainer's Pokemon came out or went back: the button may light up or go grey
MegaEvolution.onPokemonChange = function(cid)
    local active = actives[cid]
    if (active and not stillOn(cid, active)) then
        MegaEvolution.finish(cid)
    else
        MegaEvolution.send(cid)
    end
end

MegaEvolution.onLogin = function(cid)
    setPlayerStorageValue(cid, CLIENT, -1)
    if (getPlayerStorageValue(cid, ACTIVE) == 1) then -- the server stopped during a Mega
        setPlayerStorageValue(cid, ACTIVE, -1)
        setGauge(cid, 0)
        lockRing(cid, false)
    end
end

MegaEvolution.onLogout = function(cid)
    MegaEvolution.finish(cid, true)
    actives[cid], charging[cid], contexts[cid] = nil, nil, nil
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
    doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, string.format(__L(cid, "%s became %s."), name, form))
    return true
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
        doPlayerSafeAddItem(cid, id, 1, true)
    end
    doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, string.format("You got %d Mega items.", #ids))
end
