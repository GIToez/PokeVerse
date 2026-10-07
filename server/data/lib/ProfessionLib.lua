local storages = {
professor = 15012,
stylist = 15000,
adventurer = 15006,
engineer = 15018
}

function getPlayerProfession(cid)
if getPlayerStorageValue(cid, storages.professor) >= 1 then
return "professor"
elseif getPlayerStorageValue(cid, storages.stylist) >= 1 then
return "stylist"
elseif getPlayerStorageValue(cid, storages.adventurer) >= 1 then
return "adventurer"
elseif getPlayerStorageValue(cid, storages.engineer) >= 1 then
return "engineer"
else
return "no profession"
end
end

function professionReturnStorage(cid)
if getPlayerProfession(cid) == "professor" then
return storages.professor
elseif getPlayerProfession(cid) == "stylist" then
return storages.stylist
elseif getPlayerProfession(cid) == "adventurer" then
return storages.adventurer
elseif getPlayerProfession(cid) == "engineer" then
return storages.engineer
else
return 11561564989
end
return true
end

function doPlayerSetProfession(cid, profession)
local oldProfession = professionReturnStorage(cid)

if profession == "professor" then
setPlayerStorageValue(cid, storages.professor, 1)
setPlayerStorageValue(cid, oldProfession, -1)
elseif profession == "stylist" then
setPlayerStorageValue(cid, storages.stylist, 1)
setPlayerStorageValue(cid, oldProfession, -1)
elseif profession == "adventurer" then
setPlayerStorageValue(cid, storages.adventurer, 1)
setPlayerStorageValue(cid, oldProfession, -1)
elseif profession == "engineer" then
setPlayerStorageValue(cid, storages.engineer, 1)
setPlayerStorageValue(cid, oldProfession, -1)
return true
end

return true
end

function getPlayerProfessionRank(cid)
if getPlayerProfession(cid) == "no profession" then return true end
if getPlayerSkill(cid, 2) <= 40 then
return "rank c"
elseif getPlayerSkill(cid, 2) <= 70 and getPlayerSkill(cid, 2) >= 41 then
return "rank bc"
elseif getPlayerSkill(cid, 2) <= 100 and getPlayerSkill(cid, 2) >= 71 then
return "rank abc"
end
return true
end

function getPlayerProfessionSkill(cid)
return getPlayerSkillLevel(cid, 2)
end

function setPlayerProfessionSkill(cid, q)
return doPlayerAddSkillTry(cid, 2, q)
end

function isPluralName(cid, config)
if config.item[2] >= 2 then
return getItemPluralNameById(config.item[1])
else
return getItemNameById(config.item[1])
end
return true
end

function doPlayerSetTimeToCraft(cid, config)
if getPlayerStorageValue(cid, config.storageSystem2) >= 5 then
doPlayerSendCancel(cid, "You are Exhausted.")
addEvent(function()
setPlayerStorageValue(cid, config.storageSystem2, 2)
end, 500)
return true
end
return true
end

function doPlayerSetDungeonStatus(cid, param)
if param == "inside" then
setPlayerStorageValue(cid, 25748, 3)
elseif param == "outside" then
setPlayerStorageValue(cid, 25748, 1)
return true
end
return true
end

function playerIsInDungeon(cid)
if getPlayerStorageValue(cid, 25748) >= 3 then
return true
else
return false
end
return true
end

function playerIsInMoto(cid)
if getPlayerStorageValue(cid, 148971) >= 5 then
return true
else
return false
end
return true
end

function playerIsInMecha(cid)
if getPlayerStorageValue(cid, 248971) >= 5 then
return true
else
return false
end
return true
end

function playerHaveChip2(cid)
if getPlayerStorageValue(cid, 32905) >= 4 then
return true
else
return false
end
return true
end

function playerHaveChip3(cid)
if getPlayerStorageValue(cid, 32906) >= 4 then
return true
else
return false
end
return true
end

function isHouseTile(item)
local houseTilesId = {11674, 406, 405, 1284, 14219, 14220, 14219, 14220, 14221, 14222, 14223, 14224, 14225, 14226, 14227, 14228, 14229, 14230, 14231, 14232, 14233, 14234, 14235, 14236, 14237, 14238, 14239, 14240, 14241, 14242, 14243, 14244, 14245, 14246, 14247, 14248, 14249, 14250, 14251, 14252, 14253, 14254, 14255, 14256, 14257, 14258, 14259, 14260, 14261, 14262, 14263, 14264, 14265, 14266, 
14267, 14268, 14269, 14270, 14271, 14272, 14273, 14274, 14275, 14276, 14277, 14278, 4279, 14280, 14281, 14282, 14283, 14284, 14285, 14286, 14287, 14288, 14289, 14290, 14291, 14292, 14293, 14294, 14295, 14296, 14297, 14298, 14299, 14300, 14301, 14302, 14303, 14304, 14305, 14306, 14307, 14308, 14309, 14310, 14311, 14312, 14313, 14314, 14315}
if isInArray(houseTilesId, item) then
return true
else
return false
end
return true
end

function haveBerry(cid, berry)
if getItemAttribute(getPlayerSlotItem(getCreatureMaster(cid), 8).uid, berry) or getItemAttribute(getPlayerSlotItem(getCreatureMaster(cid), 8).uid, berry) then return true end
return true
end