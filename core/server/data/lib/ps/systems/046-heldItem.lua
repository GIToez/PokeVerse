if (PokemonHeldItem) then
    return
end

-- Held items: one per Pokemon, kept on its ball. The type items boost one type of moves by a fixed
-- HELD_TYPE_BOOST (Polkadot Bow 10%; no levels, no experience); the Elemental Stone boosts the two types it was
-- charged with. The breeding and EV items only matter to the Day Care and EV gain (PokemonStats).
--
-- Trainers give and take them themselves: drag the item onto a Pokemon on the swap bar, or use it
-- on the ball ("Use with"); "Take held item" on the swap bar gives it back (EXTENDED_IDS.HELD_ITEM,
-- PokemonHeldItem.onClientMessage). A Pokemon that is out gets the change at once.

PokemonHeldItem = {}

HELD_TYPE_BOOST = 20 -- percent, for the type items and the Elemental Stone

-- Constants
HELD_IDS = {}
HELD_IDS.BLACK_BELT = 0
HELD_IDS.BLACK_GLASSES = 1
HELD_IDS.CHARCOAL = 2
HELD_IDS.DRAGON_FANG = 3
HELD_IDS.HARD_STONE = 4
HELD_IDS.MAGNET = 5
HELD_IDS.METAL_COAT = 6
HELD_IDS.MIRACLE_SEED = 7
HELD_IDS.MYSTIC_WATER = 8
HELD_IDS.NEVER_MELT_ICE = 9
HELD_IDS.PINK_BOW = 10
HELD_IDS.POISON_BARB = 11
HELD_IDS.POLKADOT_BOW = 12
HELD_IDS.SHARP_BEAK = 13
HELD_IDS.SILK_SCARF = 14
HELD_IDS.SILVER_POWDER = 15
HELD_IDS.SOFT_SAND = 16
HELD_IDS.SPELL_TAG = 17
HELD_IDS.TWISTED_SPOON = 18
HELD_IDS.ELEMENTAL_STONE = 19
HELD_IDS.DESTINY_KNOT = 20
HELD_IDS.EVERSTONE = 21
HELD_IDS.POWER_WEIGHT = 22
HELD_IDS.POWER_BRACER = 23
HELD_IDS.POWER_BELT = 24
HELD_IDS.POWER_LENS = 25
HELD_IDS.POWER_BAND = 26
HELD_IDS.POWER_ANKLET = 27

POWER_ITEM_EV_BONUS = 8

local HELDS = {}

local function setBoost(pokemon, types, percent)
    setPokemonHeldMovePowerModifier(pokemon, #types > 0 and (percent or HELD_TYPE_BOOST) or 0)
    for slot = 1, 2 do
        setPokemonHeldMovePowerType(pokemon, types[slot] or EMPTY_STORAGE, slot)
    end
end

local function addTypeHeld(heldId, name, itemId, element, percent)
    percent = percent or HELD_TYPE_BOOST
    HELDS[heldId] = {
        name = name,
        itemId = itemId,
        onApply = function(pokemon, ballUid)
            setBoost(pokemon, { element }, percent)
        end,
        getDescription = function(uid)
            return string.format("%s: %s moves +%d%%", name, ELEMENT_NAMES[element], percent)
        end
    }
end

addTypeHeld(HELD_IDS.BLACK_BELT, "Black Belt", 23513, ELEMENT_FIGHT)
addTypeHeld(HELD_IDS.BLACK_GLASSES, "Black Glasses", 23514, ELEMENT_DARK)
addTypeHeld(HELD_IDS.CHARCOAL, "Charcoal", 23515, ELEMENT_FIRE)
addTypeHeld(HELD_IDS.DRAGON_FANG, "Dragon Fang", 23516, ELEMENT_DRAGON)
addTypeHeld(HELD_IDS.HARD_STONE, "Hard Stone", 23517, ELEMENT_ROCK)
addTypeHeld(HELD_IDS.MAGNET, "Magnet", 23518, ELEMENT_ELECTRIC)
addTypeHeld(HELD_IDS.METAL_COAT, "Metal Coat", 23519, ELEMENT_STEEL)
addTypeHeld(HELD_IDS.MIRACLE_SEED, "Miracle Seed", 23520, ELEMENT_GRASS)
addTypeHeld(HELD_IDS.MYSTIC_WATER, "Mystic Water", 23521, ELEMENT_WATER)
addTypeHeld(HELD_IDS.NEVER_MELT_ICE, "Never Melt Ice", 23522, ELEMENT_ICE)
addTypeHeld(HELD_IDS.PINK_BOW, "Pink Bow", 23523, ELEMENT_FAIRY)
addTypeHeld(HELD_IDS.POISON_BARB, "Poison Barb", 23524, ELEMENT_POISON)
addTypeHeld(HELD_IDS.SHARP_BEAK, "Sharp Beak", 23526, ELEMENT_FLYING)
addTypeHeld(HELD_IDS.SILK_SCARF, "Silk Scarf", 23527, ELEMENT_NORMAL)
addTypeHeld(HELD_IDS.SILVER_POWDER, "Silver Powder", 23528, ELEMENT_BUG)
addTypeHeld(HELD_IDS.SOFT_SAND, "Soft Sand", 23529, ELEMENT_GROUND)
addTypeHeld(HELD_IDS.SPELL_TAG, "Spell Tag", 23530, ELEMENT_GHOST)
addTypeHeld(HELD_IDS.TWISTED_SPOON, "Twisted Spoon", 23531, ELEMENT_PSYCHIC)

-- As in the games, the weaker Normal item: Silk Scarf is the full boost
addTypeHeld(HELD_IDS.POLKADOT_BOW, "Polkadot Bow", 23525, ELEMENT_NORMAL, 10)

local function stoneElements(ballUid)
    local elements = {}
    local heldVariables = getBallHeldVariables(ballUid)
    if (heldVariables and isString(heldVariables)) then
        for _, v in pairs(string.explode(heldVariables, ";")) do
            elements[#elements + 1] = tonumber(v)
        end
    end
    return elements
end

local function stoneElementNames(ballUid)
    local names = {}
    for _, element in ipairs(stoneElements(ballUid)) do
        names[#names + 1] = ELEMENT_NAMES[element]
    end
    return table.concat(names, " / ")
end

HELDS[HELD_IDS.ELEMENTAL_STONE] = {
    name = "Elemental Stone",
    itemId = 25048,
    onApply = function(pokemon, ballUid)
        setBoost(pokemon, stoneElements(ballUid))
    end,
    getDescription = function(uid)
        return string.format("Elemental Stone: %s moves +%d%%", stoneElementNames(uid), HELD_TYPE_BOOST)
    end,
    onInstall = function(ballUid, heldUid)
        local vars = {}
        for _, attribute in ipairs({ ITEM_ATTRIBUTES.ELEMENTAL_STONE_SLOT1, ITEM_ATTRIBUTES.ELEMENTAL_STONE_SLOT2 }) do
            local element = getItemAttribute(heldUid, attribute)
            if (element) then
                vars[#vars + 1] = element
            end
        end
        setBallHeldVariables(ballUid, table.concat(vars, ";"))
    end,
    -- the stone comes back uncharged with its plates, to be charged again
    onTake = function(cid, ballUid)
        doPlayerSafeAddItem(cid, HELDS[HELD_IDS.ELEMENTAL_STONE].itemId, 1, true)
        for _, element in ipairs(stoneElements(ballUid)) do
            doPlayerSafeAddItem(cid, PLATE_ITEMID_BY_TYPE[element], 1, true)
        end
    end,
    getName = function(ballUid)
        return "Elemental Stone (" .. stoneElementNames(ballUid) .. ")"
    end,
    canInstall = function(ballUid, heldUid)
        return getItemAttribute(heldUid, ITEM_ATTRIBUTES.ELEMENTAL_STONE_SLOT1)
    end
}

-- Breeding and EV training items: no move power, they only matter to EV gain and the Day Care
local function addStatHeld(heldId, name, itemId, values)
    HELDS[heldId] = {
        name = name,
        itemId = itemId,
        onApply = function(pokemon, ballUid)
            setBoost(pokemon, {})
        end,
        getDescription = function(uid)
            return HELDS[heldId].summary
        end
    }
    for key, value in pairs(values) do
        HELDS[heldId][key] = value
    end
end

addStatHeld(HELD_IDS.DESTINY_KNOT, "Destiny Knot", 30137,
    { destinyKnot = true, summary = "Destiny Knot (passes down 5 IVs at the Day Care)" })
addStatHeld(HELD_IDS.EVERSTONE, "Everstone", 30138,
    { everstone = true, summary = "Everstone (passes down its Nature at the Day Care)" })

local POWER_ITEMS = {
    { HELD_IDS.POWER_WEIGHT, "Power Weight" }, { HELD_IDS.POWER_BRACER, "Power Bracer" },
    { HELD_IDS.POWER_BELT, "Power Belt" }, { HELD_IDS.POWER_LENS, "Power Lens" },
    { HELD_IDS.POWER_BAND, "Power Band" }, { HELD_IDS.POWER_ANKLET, "Power Anklet" }
}
local POWER_STAT_NAMES = { "HP", "Attack", "Defense", "Sp. Attack", "Sp. Defense", "Speed" }
for stat, power in ipairs(POWER_ITEMS) do
    addStatHeld(power[1], power[2], 30138 + stat, {
        powerStat = stat,
        summary = string.format("%s (+%d %s EVs per wild Pokemon)", power[2], POWER_ITEM_EV_BONUS, POWER_STAT_NAMES[stat])
    })
end

local HELD_BY_ITEMID = {}
for id, held in pairs(HELDS) do
    HELD_BY_ITEMID[held.itemId] = id
end

local FIRST_ELEMENTAL_STONE = 24724
local LAST_ELEMENTAL_STONE = 25047
for i = FIRST_ELEMENTAL_STONE, LAST_ELEMENTAL_STONE do -- the charged stones
    HELD_BY_ITEMID[i] = HELD_IDS.ELEMENTAL_STONE
end

local function getBallHeldDefinition(ballUid)
    local heldId = getBallHeld(ballUid)
    return heldId and HELDS[heldId] or nil
end

-- The Pokemon of this ball when it is out
local function summonOf(cid, ballUid)
    local ball = getPlayerBall(cid)
    if (isItem(ball) and ball.uid == ballUid and isPokemonOnline(cid)) then
        return getPlayerPokemon(cid)
    end
    return nil
end

-- Global
PokemonHeldItem.getHeldItemId = function(heldId)
    return HELDS[heldId] and HELDS[heldId].itemId or nil
end

PokemonHeldItem.getHeldName = function(heldId, ballUid)
    if (not HELDS[heldId]) then
        return nil
    end

    if (ballUid and HELDS[heldId].getName) then
        return HELDS[heldId].getName(ballUid)
    end

    return HELDS[heldId].name
end

PokemonHeldItem.isHeldItem = function(itemId)
    return HELD_BY_ITEMID[itemId] ~= nil
end

-- Gives back the item a ball holds and empties it. Returns the name of the item, or nil and why not.
PokemonHeldItem.take = function(cid, ballUid)
    local heldId = getBallHeld(ballUid)
    if (not heldId) then
        return nil, "This Pokemon isn't holding an item."
    elseif (isEvolving(cid)) then
        return nil, "Wait until your Pokemon has evolved."
    end

    local held = HELDS[heldId]
    local name = PokemonHeldItem.getHeldName(heldId, ballUid) or "held item"
    if (held and held.onTake) then
        held.onTake(cid, ballUid)
    elseif (held) then
        doPlayerSafeAddItem(cid, held.itemId, 1, true)
    end

    setBallHeld(ballUid, nil, true)
    setBallHeldVariables(ballUid, "")
    doBallUpdateDescription(ballUid)
    local pokemon = summonOf(cid, ballUid)
    if (pokemon) then
        setBoost(pokemon, {})
    end
    PokemonHeldItem.sendBar(cid)
    return name
end

-- Puts the held item (an item the trainer carries) on the ball's Pokemon; an item it held already
-- comes back. Returns the name of the item, or nil and why not.
PokemonHeldItem.give = function(cid, ballUid, item)
    local heldId = HELD_BY_ITEMID[item.itemid]
    local held = heldId and HELDS[heldId]
    if (not held) then
        return nil, "Only held items can be given to a Pokemon."
    elseif (not isBallWithPokemon(ballUid)) then
        return nil, "Give it to a Pokemon."
    elseif (isEvolving(cid)) then
        return nil, "Wait until your Pokemon has evolved."
    elseif (held.canInstall and not held.canInstall(ballUid, item.uid)) then
        return nil, "Charge the Elemental Stone with a plate first."
    end

    if (getBallHeld(ballUid)) then
        PokemonHeldItem.take(cid, ballUid)
    end

    setBallHeld(ballUid, heldId)
    if (held.onInstall) then
        held.onInstall(ballUid, item.uid)
    end
    doRemoveItem(item.uid, 1)
    doBallUpdateDescription(ballUid)

    local pokemon = summonOf(cid, ballUid)
    if (pokemon) then
        held.onApply(pokemon, ballUid)
    end
    PokemonHeldItem.sendBar(cid)
    return PokemonHeldItem.getHeldName(heldId, ballUid)
end

-- "Use with" a held item on a Pokemon's ball
PokemonHeldItem.onUse = function(cid, item, fromPosition, itemEx, toPosition)
    if (not isItem(itemEx) or not isBallWithPokemon(itemEx.uid)) then
        doPlayerSendCancel(cid, "Use it on a Pokemon's ball, or drag it onto a Pokemon on the swap bar.")
        return true

    elseif (fromPosition.x ~= CONTAINER_POSITION or toPosition.x ~= CONTAINER_POSITION) then
        doPlayerSendCancel(cid, "You must pick up this item first.")
        return true
    end

    local name, err = PokemonHeldItem.give(cid, itemEx.uid, item)
    if (not name) then
        doPlayerSendCancel(cid, err)
        return true
    end
    doSendMagicEffect(getCreaturePosition(cid), EFFECT_FIREWORK_BLUE)
    doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, string.format(__L(cid, "Your %s is now holding %s."),
        getBallPokemonName(itemEx.uid), name))
    return true
end

-- { stat, amount } for a Power item, nil otherwise
PokemonHeldItem.getEvBonus = function(ballUid)
    local held = getBallHeldDefinition(ballUid)
    if (held and held.powerStat) then
        return { stat = held.powerStat, amount = POWER_ITEM_EV_BONUS }
    end
    return nil
end

-- The stat a Power item passes down at the Day Care, nil otherwise
PokemonHeldItem.getPowerStat = function(ballUid)
    local held = getBallHeldDefinition(ballUid)
    return held and held.powerStat or nil
end

PokemonHeldItem.hasDestinyKnot = function(ballUid)
    local held = getBallHeldDefinition(ballUid)
    return held and held.destinyKnot or false
end

PokemonHeldItem.hasEverstone = function(ballUid)
    local held = getBallHeldDefinition(ballUid)
    return held and held.everstone or false
end

PokemonHeldItem.getMovePowerModifier = function(cid, moveType)
    for slot = 1, 2 do
        local type = getPokemonHeldMovePowerType(cid, slot)
        if (type ~= EMPTY_STORAGE and type == moveType) then
            return 1 + (getPokemonHeldMovePowerModifier(cid) / 100)
        end
    end
    return 1
end

PokemonHeldItem.onPokemonCall = function(pokemon, ball)
    local held = getBallHeldDefinition(ball.uid)
    if (held) then
        held.onApply(pokemon, ball.uid)
    elseif (getBallHeld(ball.uid)) then
        log(LOG_TYPES.ERROR, "PokemonHeldItem.onPokemonCall - Unknown heldId", getBallHeld(ball.uid),
            getCreatureName(getCreatureMaster(pokemon)))
    end
end

PokemonHeldItem.getBallDescription = function(uid)
    local heldId = getBallHeld(uid)
    if (not heldId) then
        return "None."
    end

    if (not HELDS[heldId]) then
        log(LOG_TYPES.ERROR, "PokemonHeldItem.getBallDescription - Unknown heldId", heldId)
        return "None."
    end

    return HELDS[heldId].getDescription(uid)
end

-- /held: what the Pokemon in the ball slot holds
PokemonHeldItem.doSendPlayerHeldMessage = function(cid)
    local ball = getPlayerBall(cid)
    if (not isItem(ball) or not isBallWithPokemon(ball.uid)) then
        doPlayerSendCancel(cid, "First put your Pokemon's ball in the ball slot.")
    elseif (not getBallHeld(ball.uid)) then
        doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, string.format(__L(cid,
            "Your %s isn't holding an item. Drag a held item onto it on the swap bar to give it one."), getBallPokemonName(ball.uid)))
    else
        doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, string.format(__L(cid, "Your %s is holding %s."),
            getBallPokemonName(ball.uid), PokemonHeldItem.getBallDescription(ball.uid)))
    end
end

-- What each Pokemon on the swap bar holds, for its icon and tooltip
PokemonHeldItem.sendBar = function(cid)
    local items = {}
    for _, ball in pairs(getPlayerAllBallsWithPokemon(cid)) do
        local number = tonumber(getFastcallNumber(ball.uid))
        local heldId = getBallHeld(ball.uid)
        if (number and heldId and HELDS[heldId]) then
            local info = getItemInfo(HELDS[heldId].itemId)
            items[#items + 1] = { number = number, name = PokemonHeldItem.getHeldName(heldId, ball.uid),
                                  text = PokemonHeldItem.getBallDescription(ball.uid), client = info and info.clientId or 0 }
        end
    end
    doSendPlayerExtendedOpcode(cid, EXTENDED_IDS.HELD_ITEM, JSON.encode({ type = "bar", items = items }))
end

local function clientIdOf(itemId)
    local info = getItemInfo(itemId)
    return info and info.clientId or nil
end

-- The client's bag view can be sorted differently from the server's container, so the position is
-- only trusted when the item there has the client id that was dragged; otherwise any carried held
-- item with that client id is used.
local function findDraggedItem(cid, dragged)
    local clientId = tonumber(dragged.id)
    local item = getPlayerItemFromClientPos(cid, { x = tonumber(dragged.x) or 0, y = tonumber(dragged.y) or 0,
                                                   z = tonumber(dragged.z) or 0, stackpos = 0 })
    if (isItem(item) and (not clientId or clientIdOf(item.itemid) == clientId)) then
        return item
    end
    if (not clientId) then
        return nil
    end
    for itemId in pairs(HELD_BY_ITEMID) do
        if (clientIdOf(itemId) == clientId) then
            local found = getPlayerItemById(cid, true, itemId)
            if (isItem(found)) then
                return found
            end
        end
    end
    return nil
end

-- Swap bar (client game_pokebar), JSON on EXTENDED_IDS.HELD_ITEM:
--   {action = "refresh"}                                     -> {type = "bar", items = {{number, name, text, client}}}
--   {action = "give", number = <swap bar number>, item = {x, y, z, id = <client id>}}
--   {action = "take", number = <swap bar number>}            (both answer with the bar too)
PokemonHeldItem.onClientMessage = function(cid, buffer)
    local ok, data = pcall(JSON.decode, buffer)
    if (not ok or type(data) ~= "table") then
        return
    end
    if (data.action == "refresh") then
        PokemonHeldItem.sendBar(cid)
        return
    end
    if (isExhaust(cid)) then
        doPlayerSendCancel(cid, "You're exhausted.")
        return
    end
    local ballUid = getFastcallBall(cid, data.number)
    if (not ballUid) then
        doPlayerSendCancel(cid, "That Pokemon isn't with you.")
        return
    end

    if (data.action == "give" and type(data.item) == "table") then
        local item = findDraggedItem(cid, data.item)
        if (not isItem(item)) then
            doPlayerSendCancel(cid, "You must pick up this item first.")
            return
        end
        local name, err = PokemonHeldItem.give(cid, ballUid, item)
        if (not name) then
            doPlayerSendCancel(cid, err)
            return
        end
        doSendMagicEffect(getCreaturePosition(cid), EFFECT_FIREWORK_BLUE)
        doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, string.format(__L(cid, "Your %s is now holding %s."),
            getBallPokemonName(ballUid), name))

    elseif (data.action == "take") then
        local name, err = PokemonHeldItem.take(cid, ballUid)
        if (not name) then
            doPlayerSendCancel(cid, err)
            return
        end
        doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, string.format(__L(cid, "You took the %s from your %s."),
            name, getBallPokemonName(ballUid)))
    end
end
