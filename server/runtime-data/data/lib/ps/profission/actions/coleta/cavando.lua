function onUse(cid, item, fromPosition, itemEx, toPosition)
-- CHEGAGENS
if getPlayerStorageValue(cid, 17001) > 0 or getPlayerStorageValue(cid, 17000) > 0 or getPlayerStorageValue(cid, 63215) > 0 then
if isInArray({460, 11675, 11676, 11677}, getTileInfo(getThingPos(cid)).itemid) then return true end
local item = getPlayerSlotItem(cid, 8) local pokemon = getItemAttribute(item.uid, "poke") local x = pokes[pokemon]
if getTileInfo(getThingPos(cid)).itemid >= 4820 and getTileInfo(getThingPos(cid)).itemid <= 4825 then return true end
doSummonMonster(cid, pokemon)
local pk = getCreatureSummons(cid)[1] if not isCreature(pk) then pk = doCreateMonster(pokemon, backupPos)
if not isCreature(pk) then return true end doConvinceCreature(cid, pk) end
local outfit = getPokeOutfitColors(item.uid, getPokemonName(getCreatureSummons(cid)[1]), "normal")
doSetCreatureOutfit(pk, outfit, -1) doTeleportThing(pk, getThingPos(cid), false)
doCreatureSetLookDir(pk, getCreatureLookDir(cid)) adjustStatus(pk, item.uid, true, false, true)
doPlayerSay(cid, ""..getPokeName(getCreatureSummons(cid)[1])..", Preciso cavar este buraco!", 19)
doRegainSpeed(cid) doRemoveCondition(cid, CONDITION_OUTFIT) setPlayerStorageValue(cid, 17000, -1)
setPlayerStorageValue(cid, 17001, -1) return true end

if getDirectionTo(getCreaturePosition(cid), getThingPosition(itemEx.uid)) > getCreatureLookDirection(cid) then
doPlayerSendCancel(cid, "Você precisa está na frente do buraco!")return true end

if not isPremium(cid) then
	doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Apenas jogadores VIPS podem cavar buracos.")
	return true
end

if getPlayerProfession(cid) ~= "adventurer" then
    doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Somente aventureiro podem usar este item.")
	return true
end

-- CHEGAGENS

local zPos = math.random(1, 7)
local config = {
    itemid = {16998}, --- ID DO BURACO
    edges = { ---- Para onde o buraco vai ser spawnado depois que for aberto.
        fromPos = {x = 686, y = 2485, z = 15},   --Coordenadas da posição superior esquerda.
        toPos = {x = 695, y = 2491, z = 15}                    --Coordenadas da posição inferior direita.
    }
}

local function isWalkable(pos, creature, proj, pz, water)
    if getTileThingByPos({x = pos.x, y = pos.y, z = pos.z, stackpos = 0}).itemid == 0 then return false end
    if isWater(getTileThingByPos({x = pos.x, y = pos.y, z = pos.z, stackpos = 0}).itemid) and water then return false end
    if getTopCreature(pos).uid > 0 and creature then return false end
    if getTileInfo(pos).protection and pz then return false, true end
    local n = not proj and 3 or 2
    for i = 0, 255 do
        pos.stackpos = i
        local tile = getTileThingByPos(pos)
        if tile.itemid ~= 0 and not isCreature(tile.uid) then
            if hasProperty(tile.uid, n) or hasProperty(tile.uid, 7) then
                return false
            end
        end
    end
    return true
end

local function getRandomPos(f, t)
    local pos = {x = math.random(f.x, t.x), y = math.random(f.y, t.y), z = math.random(f.z, t.z)}
    
    if not isWalkable(pos, true, true, true, true) then
        pos = getRandomPos(f, t)
    end
    
    return pos
end

if itemEx.itemid == 16998 then --- ID DO BURACO
    local pos = {}
    
    for i = 1, #config.itemid do
        table.insert(pos, getRandomPos(config.edges.fromPos, config.edges.toPos))
    end
    
    for i = 1, #pos do  

        
        doCreateItem(config.itemid[i], 1, pos[i])
    end
local outfit = getCreatureOutfit(cid)
if getPlayerSex(cid) == 0 then
doCreatureSetNoMove(cid, true)
doCreatureSetLookDir(cid, getDirectionTo(getThingPos(cid), getThingPos(itemEx.uid)))
doSetCreatureOutfit(cid, {lookType = 3395, lookHead = outfit.lookHead, lookBody = outfit.lookBody, lookLegs = outfit.lookLegs, lookFeet = outfit.lookFeet}, 1250)
else
doCreatureSetNoMove(cid, true)
doCreatureSetLookDir(cid, getDirectionTo(getThingPos(cid), getThingPos(itemEx.uid)))
doSetCreatureOutfit(cid, {lookType = 3394, lookHead = outfit.lookHead, lookBody = outfit.lookBody, lookLegs = outfit.lookLegs, lookFeet = outfit.lookFeet}, 1250)
end

local BURACOS = {
[16998] = 1, 
[16999] = 170, 
[17000] = 340, 
[17001] = 510, 
[17002] = 680,
}
for ids, tempo in pairs(BURACOS) do
function TransformItem(position, itemid)
doRemoveItem(getThingfromPos(position).uid, 1)
doCreateItem(itemid, 1, position)
end
addEvent(TransformItem, tempo, toPosition, ids) -- addEvent da função acima, que transforma os itens
end
addEvent(function()
doCreatureSetNoMove(cid, false)
end, 1500)
else
    doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_RED, "Use sua pá apenas em buracos!")
return true
end
return true
end