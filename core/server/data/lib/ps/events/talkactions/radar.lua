-- Ranger radar: !radar, or !radar <type> from rank 2 (Vocations.radar)
function onSay(cid, words, param, channel)
    Vocations.radar(cid, param)
    return true
end
