if (MegaEvolution) then
    return
end

-- Mega Evolution (docs/upcoming-features.md, Mega Evolution). The items are in config/megaItems.lua;
-- the stones are held items (046-heldItem.lua). A form is a config entry with megaOf (config/pokemon/)
-- and a monster file that never spawns (monster/Mega/). Mega Evolving works like Ditto's Transform:
-- the Pokemon keeps its creature and moves, and its reference name (types, stats) becomes the form.

MegaEvolution = {}

MegaEvolution.hasForm = function(formName)
    local definition = getPokemonDefinition(formName)
    return definition ~= nil and definition.megaOf ~= nil
end

-- True while the Pokemon of this ball is Mega Evolved, so its stone stays on
MegaEvolution.isStoneLocked = function(cid, ballUid)
    return false
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

-- /mega (staff): Mega Evolves the trainer's Pokemon through its held stone, or the form named by the
-- parameter ("x", "y") when it holds none, without the gauge; "/mega off" turns it back
MegaEvolution.onStaffCommand = function(cid, param)
    local pokemon, ball = getPlayerPokemon(cid), getPlayerBall(cid)
    if (not isCreature(pokemon) or not isItem(ball)) then
        doPlayerSendCancel(cid, "Call your Pokemon first.")
        return false
    end
    param = (param or ""):lower():trim()
    if (param == "off") then
        if (not MegaEvolution.revert(cid, pokemon)) then
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
    elseif (not MegaEvolution.apply(cid, pokemon, form)) then
        doPlayerSendCancel(cid, "Your Pokemon is already transformed.")
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
