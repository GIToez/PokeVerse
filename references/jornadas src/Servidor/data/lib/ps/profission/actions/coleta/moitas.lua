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
doPlayerSay(cid, ""..getPokeName(getCreatureSummons(cid)[1])..", Preciso coletar esse arbusto!", 19)
doRegainSpeed(cid) doRemoveCondition(cid, CONDITION_OUTFIT) setPlayerStorageValue(cid, 17000, -1)
setPlayerStorageValue(cid, 17001, -1) return true end

if getDirectionTo(getCreaturePosition(cid), getThingPosition(itemEx.uid)) > getCreatureLookDirection(cid) then
doPlayerSendCancel(cid, "Você precisa está na frente do arbusto!")return true end

if not isPremium(cid) then
	doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Apenas jogadores VIP'S podem coletar arbustos.")
	return true
end

if getPlayerProfession(cid) ~= "professor" then
    doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Somente professores podem usar este item.")
return true
end

-- CHEGAGENS

local zPos = math.random(1, 7)
local config = {
    itemid = {17083}, --- ID DO BAU normal
    edges = { ---- Para onde o bau vai ser spawnado depois que for aberto.
        fromPos = {x = 0, y = 0, z = 0},
        toPos = {x = 1646, y = 2068, z = 7}  
    }
}

----------------- Arbusto pequeno COMEÇA AQUI ---------------------
if itemEx.itemid == 2767 then --- ID DO BAU
local nomal_chest_rewards = {{[17098] = math.random(1, 2)},}
local randomNormal = math.random(1,#nomal_chest_rewards)

addEvent(function() -- addEvent ONDE DA O ITEM
for item, quantidade in pairs(nomal_chest_rewards[randomNormal]) do
local itemzin = doPlayerAddItem(cid, item, quantidade)
doItemSetAttribute(itemzin, "unique", 1)
doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Você conseguiu ".. quantidade .." gramas.") --  17088
end
end, 4000)

--- POS PARA ONDE VAI
local pos = {}
for i = 1, #config.itemid do -- MODIFICAR AQUI \/
    table.insert(pos, getRandomPosTerraTile(config.edges.fromPos, config.edges.toPos))
end

--- POS PARA ONDE VAI
--- OUTFIT
local outfit = getCreatureOutfit(cid)
if getPlayerSex(cid) == 0 then
doCreatureSetNoMove(cid, true)
doCreatureSetLookDir(cid, getDirectionTo(getThingPos(cid), getThingPos(itemEx.uid)))
doSetCreatureOutfit(cid, {lookType = 3393, lookHead = outfit.lookHead, lookBody = outfit.lookBody, lookLegs = outfit.lookLegs,lookFeet = outfit.lookFeet}, 3620)
else
doCreatureSetNoMove(cid, true)
doCreatureSetLookDir(cid, getDirectionTo(getThingPos(cid), getThingPos(itemEx.uid)))
doSetCreatureOutfit(cid, {lookType = 3392, lookHead = outfit.lookHead, lookBody = outfit.lookBody, lookLegs = outfit.lookLegs, lookFeet = outfit.lookFeet}, 3620)
end
--- OUTFIT

local normalChestIds = {
[2767] = 1, 
[18603] = 4000,
[18604] = 4170,
[18605] = 4440,
[18602] = 4510,
[18606] = 120000,
[18607] = 180000,
[18608] = 240000,
[2767] = 300000,
}
for ids, tempo in pairs(normalChestIds) do
function TransformItem(position, itemid)
doRemoveItem(getThingfromPos(position).uid, 1)
doCreateItem(itemid, 1, position)
end
addEvent(TransformItem, tempo, toPosition, ids) -- addEvent da função acima, que transforma os itens
end
addEvent(function() -- addEvent que remove o chest final
doCreatureSetNoMove(cid, false)
end, 3300)
return true
end
----------------- Arbusto pequeno TERMINA AQUI ---------------------

----------------- Moita grande COMEÇA AQUI ---------------------
if itemEx.itemid == 16986 then --- ID DO BAU
local nomal_chest_rewards = {{[17098] = math.random(1, 8)},}
local randomNormal = math.random(1,#nomal_chest_rewards)

addEvent(function() -- addEvent ONDE DA O ITEM
for item, quantidade in pairs(nomal_chest_rewards[randomNormal]) do
local itemzin = doPlayerAddItem(cid, item, quantidade)
doItemSetAttribute(itemzin, "unique", 1)
doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Você conseguiu ".. quantidade .." gramas.") --  17088
end
end, 4000)

--- POS PARA ONDE VAI
local pos = {}
for i = 1, #config.itemid do -- MODIFICAR AQUI \/
    table.insert(pos, getRandomPosTerraJungleTile(config.edges.fromPos, config.edges.toPos))
end

addEvent(function() -- addEvent onde spawna o item em outro lugar
for i = 1, #pos do doCreateItem(16986, 1, pos[i]) end
end, 300000)

--- POS PARA ONDE VAI
--- OUTFIT
local outfit = getCreatureOutfit(cid)
if getPlayerSex(cid) == 0 then
doCreatureSetNoMove(cid, true)
doCreatureSetLookDir(cid, getDirectionTo(getThingPos(cid), getThingPos(itemEx.uid)))
doSetCreatureOutfit(cid, {lookType = 3393, lookHead = outfit.lookHead, lookBody = outfit.lookBody, lookLegs = outfit.lookLegs,lookFeet = outfit.lookFeet}, 3620)
else
doCreatureSetNoMove(cid, true)
doCreatureSetLookDir(cid, getDirectionTo(getThingPos(cid), getThingPos(itemEx.uid)))
doSetCreatureOutfit(cid, {lookType = 3392, lookHead = outfit.lookHead, lookBody = outfit.lookBody, lookLegs = outfit.lookLegs, lookFeet = outfit.lookFeet}, 3620)
end
--- OUTFIT

local normalChestIds = {
[16986] = 1, 
[16987] = 4000, -- item que vai ser transformado depois de coletado
}
for ids, tempo in pairs(normalChestIds) do
function TransformItem(position, itemid)
doRemoveItem(getThingfromPos(position).uid, 1)
doCreateItem(itemid, 1, position)
end
addEvent(TransformItem, tempo, toPosition, ids) -- addEvent da função acima, que transforma os itens
end
addEvent(function() -- addEvent que remove a condição de mover do jogador
doCreatureSetNoMove(cid, false)
end, 3620)
addEvent(function() -- addEvent que remove o chest final
doCreatureSetNoMove(cid, false)
doRemoveItem(getThingfromPos(toPosition).uid, 1)
end, 300000)
return true
end
----------------- Moita grande TERMINA AQUI ---------------------

----------------- Moita grande de neve COMEÇA AQUI ---------------------
if itemEx.itemid == 16985 then --- ID DO BAU
local nomal_chest_rewards = {{[17098] = math.random(1, 8)},}
local randomNormal = math.random(1,#nomal_chest_rewards)

addEvent(function() -- addEvent ONDE DA O ITEM
for item, quantidade in pairs(nomal_chest_rewards[randomNormal]) do
local itemzin = doPlayerAddItem(cid, item, quantidade)
doItemSetAttribute(itemzin, "unique", 1)
doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Você conseguiu ".. quantidade .." gramas.") --  17088
end
end, 4000)

--- POS PARA ONDE VAI
local pos = {}
for i = 1, #config.itemid do -- MODIFICAR AQUI \/
    table.insert(pos, getRandomPosSnowTile(config.edges.fromPos, config.edges.toPos))
end

addEvent(function() -- addEvent onde spawna o item em outro lugar
for i = 1, #pos do doCreateItem(16985, 1, pos[i]) 
end
end, 300000)

--- POS PARA ONDE VAI
--- OUTFIT
local outfit = getCreatureOutfit(cid)
if getPlayerSex(cid) == 0 then
doCreatureSetNoMove(cid, true)
doCreatureSetLookDir(cid, getDirectionTo(getThingPos(cid), getThingPos(itemEx.uid)))
doSetCreatureOutfit(cid, {lookType = 3393, lookHead = outfit.lookHead, lookBody = outfit.lookBody, lookLegs = outfit.lookLegs,lookFeet = outfit.lookFeet}, 3620)
else
doCreatureSetNoMove(cid, true)
doCreatureSetLookDir(cid, getDirectionTo(getThingPos(cid), getThingPos(itemEx.uid)))
doSetCreatureOutfit(cid, {lookType = 3392, lookHead = outfit.lookHead, lookBody = outfit.lookBody, lookLegs = outfit.lookLegs, lookFeet = outfit.lookFeet}, 3620)
end
--- OUTFIT

local normalChestIds = {
[16985] = 1, 
[16987] = 4000, -- item que vai ser transformado depois de coletado
}
for ids, tempo in pairs(normalChestIds) do
function TransformItem(position, itemid)
doRemoveItem(getThingfromPos(position).uid, 1)
doCreateItem(itemid, 1, position)
end
addEvent(TransformItem, tempo, toPosition, ids) -- addEvent da função acima, que transforma os itens
end
addEvent(function() -- addEvent que remove a condição de mover do jogador
doCreatureSetNoMove(cid, false)
end, 3620)
addEvent(function() -- addEvent que remove o chest final
doCreatureSetNoMove(cid, false)
doRemoveItem(getThingfromPos(toPosition).uid, 1)
end, 300000)
return true
end
----------------- Moita grande de neve TERMINA AQUI ---------------------

----------------- Moita grande de grama alta COMEÇA AQUI ---------------------
if itemEx.itemid == 16984 then --- ID DO BAU
local nomal_chest_rewards = {{[17098] = math.random(1, 8)},}
local randomNormal = math.random(1,#nomal_chest_rewards)

addEvent(function() -- addEvent ONDE DA O ITEM
for item, quantidade in pairs(nomal_chest_rewards[randomNormal]) do
local itemzin = doPlayerAddItem(cid, item, quantidade)
doItemSetAttribute(itemzin, "unique", 1)
doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Você conseguiu ".. quantidade .." gramas.") --  17088
end
end, 4000)

--- POS PARA ONDE VAI
local pos = {}
for i = 1, #config.itemid do -- MODIFICAR AQUI \/
    table.insert(pos, getRandomPosGramaTile(config.edges.fromPos, config.edges.toPos))
end

addEvent(function() -- addEvent onde spawna o item em outro lugar
for i = 1, #pos do doCreateItem(16984, 1, pos[i])end
end, 300000)

--- POS PARA ONDE VAI
--- OUTFIT
local outfit = getCreatureOutfit(cid)
if getPlayerSex(cid) == 0 then
doCreatureSetNoMove(cid, true)
doCreatureSetLookDir(cid, getDirectionTo(getThingPos(cid), getThingPos(itemEx.uid)))
doSetCreatureOutfit(cid, {lookType = 3393, lookHead = outfit.lookHead, lookBody = outfit.lookBody, lookLegs = outfit.lookLegs,lookFeet = outfit.lookFeet}, 3620)
else
doCreatureSetNoMove(cid, true)
doCreatureSetLookDir(cid, getDirectionTo(getThingPos(cid), getThingPos(itemEx.uid)))
doSetCreatureOutfit(cid, {lookType = 3392, lookHead = outfit.lookHead, lookBody = outfit.lookBody, lookLegs = outfit.lookLegs, lookFeet = outfit.lookFeet}, 3620)
end
--- OUTFIT

local normalChestIds = {
[16984] = 1, 
[16987] = 4000, -- item que vai ser transformado depois de coletado
}
for ids, tempo in pairs(normalChestIds) do
function TransformItem(position, itemid)
doRemoveItem(getThingfromPos(position).uid, 1)
doCreateItem(itemid, 1, position)
end
addEvent(TransformItem, tempo, toPosition, ids) -- addEvent da função acima, que transforma os itens
end
addEvent(function() -- addEvent que remove a condição de mover do jogador
doCreatureSetNoMove(cid, false)
end, 3620)
addEvent(function() -- addEvent que remove o chest final
doCreatureSetNoMove(cid, false)
doRemoveItem(getThingfromPos(toPosition).uid, 1)
end, 300000)
----------------- Moita grande de grama alta TERMINA AQUI ---------------------

else---------- REMOVER O RETURN TRUE DO UTIMO MINERIO
    doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_RED, "Use sua bolsa de folhas apenas para coletar arbusto!")
return true
end

return true
end