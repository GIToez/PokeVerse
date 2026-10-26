if (MegaEvolution) then
    return
end

-- Mega Evolution (docs/upcoming-features.md, Mega Evolution). The items are in config/megaItems.lua;
-- the stones are held items (046-heldItem.lua).

MegaEvolution = {}

-- form name ("Mega Venusaur") -> definition, filled in as the forms are added
local FORMS = {}

MegaEvolution.hasForm = function(formName)
    return FORMS[formName] ~= nil
end

-- True while the Pokemon of this ball is Mega Evolved, so its stone stays on
MegaEvolution.isStoneLocked = function(cid, ballUid)
    return false
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
