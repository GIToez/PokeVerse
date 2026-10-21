local CACHE = {}

function onKill(cid, target, lastHit)
    if (CACHE[getPlayerGUID(cid)]) then
        return true
    end

    doSendPlayerExtendedOpcode(cid, EXTENDED_IDS.GAMEPLAY_TUTORIAL_IMAGE, "006-loot")
    doSendPlayerExtendedOpcode(cid, EXTENDED_IDS.GAMEPLAY_TUTORIAL_TEXT, __L(cid, "Very well, you defeated a wild Pokemon! Left-click its body to collect the loot. It goes straight to your bag."))

    addEvent(function(cid)
        if (isCreature(cid)) then
            doSendPlayerExtendedOpcode(cid, EXTENDED_IDS.GAMEPLAY_TUTORIAL_IMAGE, "007-catch")
            doSendPlayerExtendedOpcode(cid, EXTENDED_IDS.GAMEPLAY_TUTORIAL_TEXT, __L(cid, "Now try to catch one: left-click an empty Poke Ball in your bag, then left-click the body of a Pokemon you defeated. If the ball breaks, defeat another and try again."))
        end
    end, 10000, cid)

    CACHE[getPlayerGUID(cid)] = true

    return true
end
