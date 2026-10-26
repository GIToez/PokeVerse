local function update(cid)
    if (isPlayer(cid)) then
        MegaEvolution.onRingChange(cid)
    end
end

function onEquip(cid, item, slot)
    addEvent(update, 100, cid)
    return true
end

function onDeEquip(cid, item, slot)
    addEvent(update, 100, cid)
    return true
end
