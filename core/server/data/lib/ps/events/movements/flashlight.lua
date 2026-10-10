function onEquip(cid, item, slot)
    Flashlight.update(cid)
    return true
end

function onDeEquip(cid, item, slot)
    Flashlight.update(cid)
    return true
end
