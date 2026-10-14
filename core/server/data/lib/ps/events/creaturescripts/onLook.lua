-- Looking at an item discovers it in the Pokepedia's Items tab.
function onLook(cid, thing, position, lookDistance)
    if (isItem(thing) and thing.itemid) then
        Pokepedia.discover(cid, thing.itemid)
    end
    return true
end
