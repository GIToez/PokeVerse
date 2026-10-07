local config = {
professor = 15012,
stylist = 15000,
adventurer = 15006,
engineer = 15018
}
function onSay(cid, words, param)
-- setPlayerStorageValue(cid, 41399, 0)
-- setPlayerStorageValue(cid, 41398, 0)
-- setPlayerStorageValue(cid, 41397, 0)
-- setPlayerStorageValue(cid, 41396, 0)
-- setPlayerStorageValue(cid, 41395, 0)

-- setPlayerStorageValue(cid, 42400, 0)
-- setPlayerStorageValue(cid, 42399, 0)
-- setPlayerStorageValue(cid, 42398, 0)
-- setPlayerStorageValue(cid, 42397, 0)
-- setPlayerStorageValue(cid, 42396, 0)
-- setPlayerStorageValue(cid, 42395, 0)

doSendMagicEffect(getThingPos(cid), 28)

learnWork(cid, 1)
-- setPlayerStorageValue(cid, config.stylist, 1)
-- doPlayerSetSkillRate(cid, 2, 10)
return true
end