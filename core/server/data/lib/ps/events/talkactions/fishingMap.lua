-- Angler fishing guide from rank 4: the window in the PokeVerse client, text in others (Fishing.openGuide)
function onSay(cid, words, param, channel)
    Fishing.openGuide(cid)
    return true
end
