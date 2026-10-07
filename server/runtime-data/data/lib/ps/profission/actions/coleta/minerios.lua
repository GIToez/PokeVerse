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
doPlayerSay(cid, ""..getPokeName(getCreatureSummons(cid)[1])..", Preciso coletar esse minério!", 19)
doRegainSpeed(cid) doRemoveCondition(cid, CONDITION_OUTFIT) setPlayerStorageValue(cid, 17000, -1)
setPlayerStorageValue(cid, 17001, -1) return true end

if getDirectionTo(getCreaturePosition(cid), getThingPosition(itemEx.uid)) > getCreatureLookDirection(cid) then
doPlayerSendCancel(cid, "Você precisa está na frente do minério!")return true end

if not isPremium(cid) then
	doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Apenas jogadores VIP'S podem coletar minérios.")
	return true
end

if getPlayerProfession(cid) ~= "engineer" then
    doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Somente engenheiros podem usar este item.")
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

----------------- Minerio pequeno de terra  COMEÇA AQUI ---------------------
if itemEx.itemid == 17083 then --- ID DO BAU
local nomal_chest_rewards = {{[17088] = math.random(1, 3)},}
local randomNormal = math.random(1,#nomal_chest_rewards)

addEvent(function() -- addEvent ONDE DA O ITEM
for item, quantidade in pairs(nomal_chest_rewards[randomNormal]) do
local itemzin = doPlayerAddItem(cid, item, quantidade)
doItemSetAttribute(itemzin, "unique", 1)
doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Você conseguiu ".. quantidade .." estanhos.") --  17088
end
end, 3700)

--- POS PARA ONDE VAI
local pos = {}
for i = 1, #config.itemid do -- MODIFICAR AQUI \/
    table.insert(pos, getRandomPosTerraTile(config.edges.fromPos, config.edges.toPos))
end

addEvent(function() -- addEvent onde spawna o item em outro lugar
for i = 1, #pos do doCreateItem(17084, 1, pos[i]) end
end, 300000)

--- POS PARA ONDE VAI
--- OUTFIT
local outfit = getCreatureOutfit(cid)
if getPlayerSex(cid) == 0 then
doCreatureSetNoMove(cid, true)
doCreatureSetLookDir(cid, getDirectionTo(getThingPos(cid), getThingPos(itemEx.uid)))
doSetCreatureOutfit(cid, {lookType = 3389, lookHead = outfit.lookHead, lookBody = outfit.lookBody, lookLegs = outfit.lookLegs,lookFeet = outfit.lookFeet}, 3300)
else
doCreatureSetNoMove(cid, true)
doCreatureSetLookDir(cid, getDirectionTo(getThingPos(cid), getThingPos(itemEx.uid)))
doSetCreatureOutfit(cid, {lookType = 3388, lookHead = outfit.lookHead, lookBody = outfit.lookBody, lookLegs = outfit.lookLegs, lookFeet = outfit.lookFeet}, 3300)
end
--- OUTFIT

local normalChestIds = {
[17083] = 1, 
[17109] = 3700,
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
doRemoveItem(getThingfromPos(toPosition).uid, 1)
end, 300000)
addEvent(function() -- addEvent que remove o chest final
doCreatureSetNoMove(cid, false)
end, 3300)
return true
end
----------------- Minerio pequeno de terra TERMINA AQUI ---------------------

----------------- Minerio grande de terra COMEÇA AQUI ---------------------
if itemEx.itemid == 17084 then --- ID DO BAU
local nomal_chest_rewards = {{[17088] = math.random(1, 8)},}
local randomNormal = math.random(1,#nomal_chest_rewards)

addEvent(function() -- addEvent ONDE DA O ITEM
for item, quantidade in pairs(nomal_chest_rewards[randomNormal]) do
local itemzin = doPlayerAddItem(cid, item, quantidade)
doItemSetAttribute(itemzin, "unique", 1)
doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Você conseguiu ".. quantidade .." estanhos.") --  17088
end
end, 3700)

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
doSetCreatureOutfit(cid, {lookType = 3389, lookHead = outfit.lookHead, lookBody = outfit.lookBody, lookLegs = outfit.lookLegs,lookFeet = outfit.lookFeet}, 3300)
else
doCreatureSetNoMove(cid, true)
doCreatureSetLookDir(cid, getDirectionTo(getThingPos(cid), getThingPos(itemEx.uid)))
doSetCreatureOutfit(cid, {lookType = 3388, lookHead = outfit.lookHead, lookBody = outfit.lookBody, lookLegs = outfit.lookLegs, lookFeet = outfit.lookFeet}, 3300)
end
--- OUTFIT

local normalChestIds = {
[17084] = 1, 
[17083] = 3700, -- item que vai ser transformado depois de coletado
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
end, 3300)
return true
end
----------------- Minerio grande de terra TERMINA AQUI ---------------------
----------------- Minerio pequeno de terra COMEÇA AQUI ---------------------
if itemEx.itemid == 17081 then --- ID DO BAU
local nomal_chest_rewards = {{[17086] = math.random(1, 3)},}
local randomNormal = math.random(1,#nomal_chest_rewards)

addEvent(function() -- addEvent ONDE DA O ITEM
for item, quantidade in pairs(nomal_chest_rewards[randomNormal]) do
local itemzin = doPlayerAddItem(cid, item, quantidade)
doItemSetAttribute(itemzin, "unique", 1)
doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Você conseguiu ".. quantidade .." cobaltos.") -- 17086
end
end, 3700)

--- POS PARA ONDE VAI
local pos = {}
for i = 1, #config.itemid do -- MODIFICAR AQUI \/
    table.insert(pos, getRandomPosTerraTile(config.edges.fromPos, config.edges.toPos))
end

addEvent(function() -- addEvent onde spawna o item em outro lugar
for i = 1, #pos do doCreateItem(17082, 1, pos[i]) end
end, 300000)

--- POS PARA ONDE VAI
--- OUTFIT
local outfit = getCreatureOutfit(cid)
if getPlayerSex(cid) == 0 then
doCreatureSetNoMove(cid, true)
doCreatureSetLookDir(cid, getDirectionTo(getThingPos(cid), getThingPos(itemEx.uid)))
doSetCreatureOutfit(cid, {lookType = 3389, lookHead = outfit.lookHead, lookBody = outfit.lookBody, lookLegs = outfit.lookLegs,lookFeet = outfit.lookFeet}, 3300)
else
doCreatureSetNoMove(cid, true)
doCreatureSetLookDir(cid, getDirectionTo(getThingPos(cid), getThingPos(itemEx.uid)))
doSetCreatureOutfit(cid, {lookType = 3388, lookHead = outfit.lookHead, lookBody = outfit.lookBody, lookLegs = outfit.lookLegs, lookFeet = outfit.lookFeet}, 3300)
end
--- OUTFIT

local normalChestIds = {
[17081] = 1, 
[17109] = 3700,
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
doRemoveItem(getThingfromPos(toPosition).uid, 1)
end, 300000)
addEvent(function() -- addEvent que remove o chest final
doCreatureSetNoMove(cid, false)
end, 3300)
return true
end
----------------- Minerio pequeno de terra TERMINA AQUI ---------------------

----------------- Minerio grande de terra COMEÇA AQUI ---------------------
if itemEx.itemid == 17082 then --- ID DO BAU
local nomal_chest_rewards = {{[17086] = math.random(1, 8)},}
local randomNormal = math.random(1,#nomal_chest_rewards)

addEvent(function() -- addEvent ONDE DA O ITEM
for item, quantidade in pairs(nomal_chest_rewards[randomNormal]) do
local itemzin = doPlayerAddItem(cid, item, quantidade)
doItemSetAttribute(itemzin, "unique", 1)
doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Você conseguiu ".. quantidade .." cobaltos.") -- 17086
end
end, 3700)

--- POS PARA ONDE VAI
local pos = {}
for i = 1, #config.itemid do -- MODIFICAR AQUI \/
    table.insert(pos, getRandomPosTerraJungleTile(config.edges.fromPos, config.edges.toPos))
end

--- POS PARA ONDE VAI
--- OUTFIT
local outfit = getCreatureOutfit(cid)
if getPlayerSex(cid) == 0 then
doCreatureSetNoMove(cid, true)
doCreatureSetLookDir(cid, getDirectionTo(getThingPos(cid), getThingPos(itemEx.uid)))
doSetCreatureOutfit(cid, {lookType = 3389, lookHead = outfit.lookHead, lookBody = outfit.lookBody, lookLegs = outfit.lookLegs,lookFeet = outfit.lookFeet}, 3300)
else
doCreatureSetNoMove(cid, true)
doCreatureSetLookDir(cid, getDirectionTo(getThingPos(cid), getThingPos(itemEx.uid)))
doSetCreatureOutfit(cid, {lookType = 3388, lookHead = outfit.lookHead, lookBody = outfit.lookBody, lookLegs = outfit.lookLegs, lookFeet = outfit.lookFeet}, 3300)
end
--- OUTFIT

local normalChestIds = {
[17082] = 1, 
[17081] = 3700, -- item que vai ser transformado depois de coletado
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
end, 3300)
return true
end
----------------- Minerio grande de terra TERMINA AQUI ---------------------
----------------- Minerio pequeno de jungle COMEÇA AQUI ---------------------
if itemEx.itemid == 17079 then --- ID DO BAU
local nomal_chest_rewards = {{[17088] = math.random(1, 3)},}
local randomNormal = math.random(1,#nomal_chest_rewards)

addEvent(function() -- addEvent ONDE DA O ITEM
for item, quantidade in pairs(nomal_chest_rewards[randomNormal]) do
local itemzin = doPlayerAddItem(cid, item, quantidade)
doItemSetAttribute(itemzin, "unique", 1)
doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Você conseguiu ".. quantidade .." estanhos.") --  17088
end
end, 3700)

--- POS PARA ONDE VAI
local pos = {}
for i = 1, #config.itemid do -- MODIFICAR AQUI \/
    table.insert(pos, getRandomPosTerraTile(config.edges.fromPos, config.edges.toPos))
end

addEvent(function() -- addEvent onde spawna o item em outro lugar
for i = 1, #pos do doCreateItem(17080, 1, pos[i]) end
end, 300000)

--- POS PARA ONDE VAI
--- OUTFIT
local outfit = getCreatureOutfit(cid)
if getPlayerSex(cid) == 0 then
doCreatureSetNoMove(cid, true)
doCreatureSetLookDir(cid, getDirectionTo(getThingPos(cid), getThingPos(itemEx.uid)))
doSetCreatureOutfit(cid, {lookType = 3389, lookHead = outfit.lookHead, lookBody = outfit.lookBody, lookLegs = outfit.lookLegs,lookFeet = outfit.lookFeet}, 3300)
else
doCreatureSetNoMove(cid, true)
doCreatureSetLookDir(cid, getDirectionTo(getThingPos(cid), getThingPos(itemEx.uid)))
doSetCreatureOutfit(cid, {lookType = 3388, lookHead = outfit.lookHead, lookBody = outfit.lookBody, lookLegs = outfit.lookLegs, lookFeet = outfit.lookFeet}, 3300)
end
--- OUTFIT

local normalChestIds = {
[17079] = 1, 
[17109] = 3700,
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
doRemoveItem(getThingfromPos(toPosition).uid, 1)
end, 300000)
addEvent(function() -- addEvent que remove o chest final
doCreatureSetNoMove(cid, false)
end, 3300)
return true
end
----------------- Minerio pequeno de jungle TERMINA AQUI ---------------------

----------------- Minerio grande de jungle COMEÇA AQUI ---------------------
if itemEx.itemid == 17080 then --- ID DO BAU
local nomal_chest_rewards = {{[17088] = math.random(1, 8)},}
local randomNormal = math.random(1,#nomal_chest_rewards)

addEvent(function() -- addEvent ONDE DA O ITEM
for item, quantidade in pairs(nomal_chest_rewards[randomNormal]) do
local itemzin = doPlayerAddItem(cid, item, quantidade)
doItemSetAttribute(itemzin, "unique", 1)
doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Você conseguiu ".. quantidade .." estanhos.") --  17088
end
end, 3700)

--- POS PARA ONDE VAI
local pos = {}
for i = 1, #config.itemid do -- MODIFICAR AQUI \/
    table.insert(pos, getRandomPosTerraJungleTile(config.edges.fromPos, config.edges.toPos))
end

--- POS PARA ONDE VAI
--- OUTFIT
local outfit = getCreatureOutfit(cid)
if getPlayerSex(cid) == 0 then
doCreatureSetNoMove(cid, true)
doCreatureSetLookDir(cid, getDirectionTo(getThingPos(cid), getThingPos(itemEx.uid)))
doSetCreatureOutfit(cid, {lookType = 3389, lookHead = outfit.lookHead, lookBody = outfit.lookBody, lookLegs = outfit.lookLegs,lookFeet = outfit.lookFeet}, 3300)
else
doCreatureSetNoMove(cid, true)
doCreatureSetLookDir(cid, getDirectionTo(getThingPos(cid), getThingPos(itemEx.uid)))
doSetCreatureOutfit(cid, {lookType = 3388, lookHead = outfit.lookHead, lookBody = outfit.lookBody, lookLegs = outfit.lookLegs, lookFeet = outfit.lookFeet}, 3300)
end
--- OUTFIT

local normalChestIds = {
[17080] = 1, 
[17079] = 3700, -- item que vai ser transformado depois de coletado
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
end, 3300)
return true
end
----------------- Minerio grande de jungle TERMINA AQUI ---------------------
----------------- Minerio pequeno de jungle COMEÇA AQUI ---------------------
if itemEx.itemid == 17077 then --- ID DO BAU
local nomal_chest_rewards = {{[17086] = math.random(1, 3)},}
local randomNormal = math.random(1,#nomal_chest_rewards)

addEvent(function() -- addEvent ONDE DA O ITEM
for item, quantidade in pairs(nomal_chest_rewards[randomNormal]) do
local itemzin = doPlayerAddItem(cid, item, quantidade)
doItemSetAttribute(itemzin, "unique", 1)
doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Você conseguiu ".. quantidade .." cobaltos.") -- 17086
end
end, 3700)

--- POS PARA ONDE VAI
local pos = {}
for i = 1, #config.itemid do -- MODIFICAR AQUI \/
    table.insert(pos, getRandomPosTerraJungleTile(config.edges.fromPos, config.edges.toPos))
end

addEvent(function() -- addEvent onde spawna o item em outro lugar
for i = 1, #pos do doCreateItem(17078, 1, pos[i]) end
end, 300000)

--- POS PARA ONDE VAI
--- OUTFIT
local outfit = getCreatureOutfit(cid)
if getPlayerSex(cid) == 0 then
doCreatureSetNoMove(cid, true)
doCreatureSetLookDir(cid, getDirectionTo(getThingPos(cid), getThingPos(itemEx.uid)))
doSetCreatureOutfit(cid, {lookType = 3389, lookHead = outfit.lookHead, lookBody = outfit.lookBody, lookLegs = outfit.lookLegs,lookFeet = outfit.lookFeet}, 3300)
else
doCreatureSetNoMove(cid, true)
doCreatureSetLookDir(cid, getDirectionTo(getThingPos(cid), getThingPos(itemEx.uid)))
doSetCreatureOutfit(cid, {lookType = 3388, lookHead = outfit.lookHead, lookBody = outfit.lookBody, lookLegs = outfit.lookLegs, lookFeet = outfit.lookFeet}, 3300)
end
--- OUTFIT

local normalChestIds = {
[17077] = 1, 
[17109] = 3700,
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
doRemoveItem(getThingfromPos(toPosition).uid, 1)
end, 300000)
addEvent(function() -- addEvent que remove o chest final
doCreatureSetNoMove(cid, false)
end, 3300)
return true
end
----------------- Minerio pequeno de jungle TERMINA AQUI ---------------------

----------------- Minerio grande de jungle COMEÇA AQUI ---------------------
if itemEx.itemid == 17078 then --- ID DO BAU
local nomal_chest_rewards = {{[17086] = math.random(1, 8)},}
local randomNormal = math.random(1,#nomal_chest_rewards)

addEvent(function() -- addEvent ONDE DA O ITEM
for item, quantidade in pairs(nomal_chest_rewards[randomNormal]) do
local itemzin = doPlayerAddItem(cid, item, quantidade)
doItemSetAttribute(itemzin, "unique", 1)
doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Você conseguiu ".. quantidade .." cobaltos.") -- 17086
end
end, 3700)

--- POS PARA ONDE VAI
local pos = {}
for i = 1, #config.itemid do -- MODIFICAR AQUI \/
    table.insert(pos, getRandomPosTerraJungleTile(config.edges.fromPos, config.edges.toPos))
end

--- POS PARA ONDE VAI
--- OUTFIT
local outfit = getCreatureOutfit(cid)
if getPlayerSex(cid) == 0 then
doCreatureSetNoMove(cid, true)
doCreatureSetLookDir(cid, getDirectionTo(getThingPos(cid), getThingPos(itemEx.uid)))
doSetCreatureOutfit(cid, {lookType = 3389, lookHead = outfit.lookHead, lookBody = outfit.lookBody, lookLegs = outfit.lookLegs,lookFeet = outfit.lookFeet}, 3300)
else
doCreatureSetNoMove(cid, true)
doCreatureSetLookDir(cid, getDirectionTo(getThingPos(cid), getThingPos(itemEx.uid)))
doSetCreatureOutfit(cid, {lookType = 3388, lookHead = outfit.lookHead, lookBody = outfit.lookBody, lookLegs = outfit.lookLegs, lookFeet = outfit.lookFeet}, 3300)
end
--- OUTFIT

local normalChestIds = {
[17078] = 1, 
[17077] = 3700, -- item que vai ser transformado depois de coletado
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
end, 3300)
return true
end
----------------- Minerio grande de jungle TERMINA AQUI ---------------------
----------------- Minerio pequeno de areia COMEÇA AQUI ---------------------
if itemEx.itemid == 17075 then --- ID DO BAU
local nomal_chest_rewards = {{[17088] = math.random(1, 3)},}
local randomNormal = math.random(1,#nomal_chest_rewards)

addEvent(function() -- addEvent ONDE DA O ITEM
for item, quantidade in pairs(nomal_chest_rewards[randomNormal]) do
local itemzin = doPlayerAddItem(cid, item, quantidade)
doItemSetAttribute(itemzin, "unique", 1)
doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Você conseguiu ".. quantidade .." estanhos.") --  17088
end
end, 3700)

--- POS PARA ONDE VAI
local pos = {}
for i = 1, #config.itemid do -- MODIFICAR AQUI \/
    table.insert(pos, getRandomPosPraiaTile(config.edges.fromPos, config.edges.toPos))
end

addEvent(function() -- addEvent onde spawna o item em outro lugar
for i = 1, #pos do doCreateItem(17076, 1, pos[i]) end
end, 300000)

--- POS PARA ONDE VAI
--- OUTFIT
local outfit = getCreatureOutfit(cid)
if getPlayerSex(cid) == 0 then
doCreatureSetNoMove(cid, true)
doCreatureSetLookDir(cid, getDirectionTo(getThingPos(cid), getThingPos(itemEx.uid)))
doSetCreatureOutfit(cid, {lookType = 3389, lookHead = outfit.lookHead, lookBody = outfit.lookBody, lookLegs = outfit.lookLegs,lookFeet = outfit.lookFeet}, 3300)
else
doCreatureSetNoMove(cid, true)
doCreatureSetLookDir(cid, getDirectionTo(getThingPos(cid), getThingPos(itemEx.uid)))
doSetCreatureOutfit(cid, {lookType = 3388, lookHead = outfit.lookHead, lookBody = outfit.lookBody, lookLegs = outfit.lookLegs, lookFeet = outfit.lookFeet}, 3300)
end
--- OUTFIT

local normalChestIds = {
[17075] = 1, 
[17110] = 3700,
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
doRemoveItem(getThingfromPos(toPosition).uid, 1)
end, 300000)
addEvent(function() -- addEvent que remove o chest final
doCreatureSetNoMove(cid, false)
end, 3300)
return true
end
----------------- Minerio pequeno de areia TERMINA AQUI ---------------------

----------------- Minerio grande de areia COMEÇA AQUI ---------------------
if itemEx.itemid == 17076 then --- ID DO BAU
local nomal_chest_rewards = {{[17088] = math.random(1, 8)},}
local randomNormal = math.random(1,#nomal_chest_rewards)

addEvent(function() -- addEvent ONDE DA O ITEM
for item, quantidade in pairs(nomal_chest_rewards[randomNormal]) do
local itemzin = doPlayerAddItem(cid, item, quantidade)
doItemSetAttribute(itemzin, "unique", 1)
doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Você conseguiu ".. quantidade .." estanhos.") --  17088
end
end, 3700)

--- POS PARA ONDE VAI
local pos = {}
for i = 1, #config.itemid do -- MODIFICAR AQUI \/
    table.insert(pos, getRandomPosPraiaTile(config.edges.fromPos, config.edges.toPos))
end

--- POS PARA ONDE VAI
--- OUTFIT
local outfit = getCreatureOutfit(cid)
if getPlayerSex(cid) == 0 then
doCreatureSetNoMove(cid, true)
doCreatureSetLookDir(cid, getDirectionTo(getThingPos(cid), getThingPos(itemEx.uid)))
doSetCreatureOutfit(cid, {lookType = 3389, lookHead = outfit.lookHead, lookBody = outfit.lookBody, lookLegs = outfit.lookLegs,lookFeet = outfit.lookFeet}, 3300)
else
doCreatureSetNoMove(cid, true)
doCreatureSetLookDir(cid, getDirectionTo(getThingPos(cid), getThingPos(itemEx.uid)))
doSetCreatureOutfit(cid, {lookType = 3388, lookHead = outfit.lookHead, lookBody = outfit.lookBody, lookLegs = outfit.lookLegs, lookFeet = outfit.lookFeet}, 3300)
end
--- OUTFIT

local normalChestIds = {
[17076] = 1, 
[17075] = 3700, -- item que vai ser transformado depois de coletado
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
end, 3300)
return true
end
----------------- Minerio grande de areia TERMINA AQUI ---------------------
----------------- Minerio pequeno de areia COMEÇA AQUI ---------------------
if itemEx.itemid == 17073 then --- ID DO BAU
local nomal_chest_rewards = {{[17086] = math.random(1, 3)},}
local randomNormal = math.random(1,#nomal_chest_rewards)

addEvent(function() -- addEvent ONDE DA O ITEM
for item, quantidade in pairs(nomal_chest_rewards[randomNormal]) do
local itemzin = doPlayerAddItem(cid, item, quantidade)
doItemSetAttribute(itemzin, "unique", 1)
doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Você conseguiu ".. quantidade .." cobaltos.") -- 17086
end
end, 3700)

--- POS PARA ONDE VAI
local pos = {}
for i = 1, #config.itemid do -- MODIFICAR AQUI \/
    table.insert(pos, getRandomPosPraiaTile(config.edges.fromPos, config.edges.toPos))
end

addEvent(function() -- addEvent onde spawna o item em outro lugar
for i = 1, #pos do doCreateItem(17074, 1, pos[i]) end
end, 300000)

--- POS PARA ONDE VAI
--- OUTFIT
local outfit = getCreatureOutfit(cid)
if getPlayerSex(cid) == 0 then
doCreatureSetNoMove(cid, true)
doCreatureSetLookDir(cid, getDirectionTo(getThingPos(cid), getThingPos(itemEx.uid)))
doSetCreatureOutfit(cid, {lookType = 3389, lookHead = outfit.lookHead, lookBody = outfit.lookBody, lookLegs = outfit.lookLegs,lookFeet = outfit.lookFeet}, 3300)
else
doCreatureSetNoMove(cid, true)
doCreatureSetLookDir(cid, getDirectionTo(getThingPos(cid), getThingPos(itemEx.uid)))
doSetCreatureOutfit(cid, {lookType = 3388, lookHead = outfit.lookHead, lookBody = outfit.lookBody, lookLegs = outfit.lookLegs, lookFeet = outfit.lookFeet}, 3300)
end
--- OUTFIT

local normalChestIds = {
[17073] = 1,
[17110] = 3700,
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
doRemoveItem(getThingfromPos(toPosition).uid, 1)
end, 300000)
addEvent(function() -- addEvent que remove o chest final
doCreatureSetNoMove(cid, false)
end, 3300)
return true
end
----------------- Minerio pequeno de areia TERMINA AQUI ---------------------

----------------- Minerio grande de areia COMEÇA AQUI ---------------------
if itemEx.itemid == 17074 then --- ID DO BAU
local nomal_chest_rewards = {{[17086] = math.random(1, 8)},}
local randomNormal = math.random(1,#nomal_chest_rewards)

addEvent(function() -- addEvent ONDE DA O ITEM
for item, quantidade in pairs(nomal_chest_rewards[randomNormal]) do
local itemzin = doPlayerAddItem(cid, item, quantidade)
doItemSetAttribute(itemzin, "unique", 1)
doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Você conseguiu ".. quantidade .." cobaltos.") -- 17086
end
end, 3700)

--- POS PARA ONDE VAI
local pos = {}
for i = 1, #config.itemid do -- MODIFICAR AQUI \/
    table.insert(pos, getRandomPosPraiaTile(config.edges.fromPos, config.edges.toPos))
end

--- POS PARA ONDE VAI
--- OUTFIT
local outfit = getCreatureOutfit(cid)
if getPlayerSex(cid) == 0 then
doCreatureSetNoMove(cid, true)
doCreatureSetLookDir(cid, getDirectionTo(getThingPos(cid), getThingPos(itemEx.uid)))
doSetCreatureOutfit(cid, {lookType = 3389, lookHead = outfit.lookHead, lookBody = outfit.lookBody, lookLegs = outfit.lookLegs,lookFeet = outfit.lookFeet}, 3300)
else
doCreatureSetNoMove(cid, true)
doCreatureSetLookDir(cid, getDirectionTo(getThingPos(cid), getThingPos(itemEx.uid)))
doSetCreatureOutfit(cid, {lookType = 3388, lookHead = outfit.lookHead, lookBody = outfit.lookBody, lookLegs = outfit.lookLegs, lookFeet = outfit.lookFeet}, 3300)
end
--- OUTFIT

local normalChestIds = {
[17074] = 1, 
[17073] = 3700, -- item que vai ser transformado depois de coletado
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
end, 3300)
return true
end
----------------- Minerio grande de areia TERMINA AQUI ---------------------

----------------- Minerio pequeno de pedra COMEÇA AQUI ---------------------
if itemEx.itemid == 17071 then --- ID DO BAU
local nomal_chest_rewards = {{[17088] = math.random(1, 3)},}
local randomNormal = math.random(1,#nomal_chest_rewards)

addEvent(function() -- addEvent ONDE DA O ITEM
for item, quantidade in pairs(nomal_chest_rewards[randomNormal]) do
local itemzin = doPlayerAddItem(cid, item, quantidade)
doItemSetAttribute(itemzin, "unique", 1)
doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Você conseguiu ".. quantidade .." estanhos.") --  17088
end
end, 3700)

--- POS PARA ONDE VAI
local pos = {}
for i = 1, #config.itemid do -- MODIFICAR AQUI \/
    table.insert(pos, getRandomPosPedraTile(config.edges.fromPos, config.edges.toPos))
end

addEvent(function() -- addEvent onde spawna o item em outro lugar
for i = 1, #pos do doCreateItem(17072, 1, pos[i]) end
end, 300000)

--- POS PARA ONDE VAI
--- OUTFIT
local outfit = getCreatureOutfit(cid)
if getPlayerSex(cid) == 0 then
doCreatureSetNoMove(cid, true)
doCreatureSetLookDir(cid, getDirectionTo(getThingPos(cid), getThingPos(itemEx.uid)))
doSetCreatureOutfit(cid, {lookType = 3389, lookHead = outfit.lookHead, lookBody = outfit.lookBody, lookLegs = outfit.lookLegs,lookFeet = outfit.lookFeet}, 3300)
else
doCreatureSetNoMove(cid, true)
doCreatureSetLookDir(cid, getDirectionTo(getThingPos(cid), getThingPos(itemEx.uid)))
doSetCreatureOutfit(cid, {lookType = 3388, lookHead = outfit.lookHead, lookBody = outfit.lookBody, lookLegs = outfit.lookLegs, lookFeet = outfit.lookFeet}, 3300)
end
--- OUTFIT

local normalChestIds = {
[17071] = 1,
[17108] = 3700,
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
doRemoveItem(getThingfromPos(toPosition).uid, 1)
end, 300000)
addEvent(function() -- addEvent que remove o chest final
doCreatureSetNoMove(cid, false)
end, 3300)
return true
end
----------------- Minerio pequeno de pedra TERMINA AQUI ---------------------

----------------- Minerio grande de pedra COMEÇA AQUI ---------------------
if itemEx.itemid == 17072 then --- ID DO BAU
local nomal_chest_rewards = {{[17088] = math.random(1, 8)},}
local randomNormal = math.random(1,#nomal_chest_rewards)

addEvent(function() -- addEvent ONDE DA O ITEM
for item, quantidade in pairs(nomal_chest_rewards[randomNormal]) do
local itemzin = doPlayerAddItem(cid, item, quantidade)
doItemSetAttribute(itemzin, "unique", 1)
doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Você conseguiu ".. quantidade .." estanhos.") --  17088
end
end, 3700)

--- POS PARA ONDE VAI
local pos = {}
for i = 1, #config.itemid do -- MODIFICAR AQUI \/
    table.insert(pos, getRandomPosPedraTile(config.edges.fromPos, config.edges.toPos))
end

--- POS PARA ONDE VAI
--- OUTFIT
local outfit = getCreatureOutfit(cid)
if getPlayerSex(cid) == 0 then
doCreatureSetNoMove(cid, true)
doCreatureSetLookDir(cid, getDirectionTo(getThingPos(cid), getThingPos(itemEx.uid)))
doSetCreatureOutfit(cid, {lookType = 3389, lookHead = outfit.lookHead, lookBody = outfit.lookBody, lookLegs = outfit.lookLegs,lookFeet = outfit.lookFeet}, 3300)
else
doCreatureSetNoMove(cid, true)
doCreatureSetLookDir(cid, getDirectionTo(getThingPos(cid), getThingPos(itemEx.uid)))
doSetCreatureOutfit(cid, {lookType = 3388, lookHead = outfit.lookHead, lookBody = outfit.lookBody, lookLegs = outfit.lookLegs, lookFeet = outfit.lookFeet}, 3300)
end
--- OUTFIT

local normalChestIds = {
[17072] = 1, 
[17071] = 3700, -- item que vai ser transformado depois de coletado
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
end, 3300)
return true
end
----------------- Minerio grande de pedra TERMINA AQUI ---------------------
----------------- Minerio pequeno de pedra COMEÇA AQUI ---------------------
if itemEx.itemid == 17069 then --- ID DO BAU
local nomal_chest_rewards = {{[17086] = math.random(1, 3)},}
local randomNormal = math.random(1,#nomal_chest_rewards)

addEvent(function() -- addEvent ONDE DA O ITEM
for item, quantidade in pairs(nomal_chest_rewards[randomNormal]) do
local itemzin = doPlayerAddItem(cid, item, quantidade)
doItemSetAttribute(itemzin, "unique", 1)
doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Você conseguiu ".. quantidade .." cobaltos.") -- 17086
end
end, 3700)

--- POS PARA ONDE VAI
local pos = {}
for i = 1, #config.itemid do -- MODIFICAR AQUI \/
    table.insert(pos, getRandomPosPedraTile(config.edges.fromPos, config.edges.toPos))
end

addEvent(function() -- addEvent onde spawna o item em outro lugar
for i = 1, #pos do doCreateItem(17070, 1, pos[i]) end
end, 300000)

--- POS PARA ONDE VAI
--- OUTFIT
local outfit = getCreatureOutfit(cid)
if getPlayerSex(cid) == 0 then
doCreatureSetNoMove(cid, true)
doCreatureSetLookDir(cid, getDirectionTo(getThingPos(cid), getThingPos(itemEx.uid)))
doSetCreatureOutfit(cid, {lookType = 3389, lookHead = outfit.lookHead, lookBody = outfit.lookBody, lookLegs = outfit.lookLegs,lookFeet = outfit.lookFeet}, 3300)
else
doCreatureSetNoMove(cid, true)
doCreatureSetLookDir(cid, getDirectionTo(getThingPos(cid), getThingPos(itemEx.uid)))
doSetCreatureOutfit(cid, {lookType = 3388, lookHead = outfit.lookHead, lookBody = outfit.lookBody, lookLegs = outfit.lookLegs, lookFeet = outfit.lookFeet}, 3300)
end
--- OUTFIT

local normalChestIds = {
[17069] = 1,
[17108] = 3700,
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
doRemoveItem(getThingfromPos(toPosition).uid, 1)
end, 300000)
addEvent(function() -- addEvent que remove o chest final
doCreatureSetNoMove(cid, false)
end, 3300)
return true
end
----------------- Minerio pequeno de pedra TERMINA AQUI ---------------------

----------------- Minerio grande de pedra COMEÇA AQUI ---------------------
if itemEx.itemid == 17070 then --- ID DO BAU
local nomal_chest_rewards = {{[17088] = math.random(1, 8)},}
local randomNormal = math.random(1,#nomal_chest_rewards)

addEvent(function() -- addEvent ONDE DA O ITEM
for item, quantidade in pairs(nomal_chest_rewards[randomNormal]) do
local itemzin = doPlayerAddItem(cid, item, quantidade)
doItemSetAttribute(itemzin, "unique", 1)
doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Você conseguiu ".. quantidade .." estanhos.") --  17088
end
end, 3700)

--- POS PARA ONDE VAI
local pos = {}
for i = 1, #config.itemid do -- MODIFICAR AQUI \/
    table.insert(pos, getRandomPosPedraTile(config.edges.fromPos, config.edges.toPos))
end

--- POS PARA ONDE VAI
--- OUTFIT
local outfit = getCreatureOutfit(cid)
if getPlayerSex(cid) == 0 then
doCreatureSetNoMove(cid, true)
doCreatureSetLookDir(cid, getDirectionTo(getThingPos(cid), getThingPos(itemEx.uid)))
doSetCreatureOutfit(cid, {lookType = 3389, lookHead = outfit.lookHead, lookBody = outfit.lookBody, lookLegs = outfit.lookLegs,lookFeet = outfit.lookFeet}, 3300)
else
doCreatureSetNoMove(cid, true)
doCreatureSetLookDir(cid, getDirectionTo(getThingPos(cid), getThingPos(itemEx.uid)))
doSetCreatureOutfit(cid, {lookType = 3388, lookHead = outfit.lookHead, lookBody = outfit.lookBody, lookLegs = outfit.lookLegs, lookFeet = outfit.lookFeet}, 3300)
end
--- OUTFIT

local normalChestIds = {
[17070] = 1, 
[17069] = 3700, -- item que vai ser transformado depois de coletado
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
end, 3300)
return true
end
----------------- Minerio grande de pedra TERMINA AQUI ---------------------

----------------- Minerio pequeno de neve COMEÇA AQUI ---------------------
if itemEx.itemid == 17067 then --- ID DO BAU
local nomal_chest_rewards = {{[17088] = math.random(1, 3)},}
local randomNormal = math.random(1,#nomal_chest_rewards)

addEvent(function() -- addEvent ONDE DA O ITEM
for item, quantidade in pairs(nomal_chest_rewards[randomNormal]) do
local itemzin = doPlayerAddItem(cid, item, quantidade)
doItemSetAttribute(itemzin, "unique", 1)
doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Você conseguiu ".. quantidade .." estanhos.") --  17088
end
end, 3700)

--- POS PARA ONDE VAI
local pos = {}
for i = 1, #config.itemid do -- MODIFICAR AQUI \/
    table.insert(pos, getRandomPosSnowTile(config.edges.fromPos, config.edges.toPos))
end

addEvent(function() -- addEvent onde spawna o item em outro lugar
for i = 1, #pos do doCreateItem(17068, 1, pos[i]) end
end, 300000)

--- POS PARA ONDE VAI
--- OUTFIT
local outfit = getCreatureOutfit(cid)
if getPlayerSex(cid) == 0 then
doCreatureSetNoMove(cid, true)
doCreatureSetLookDir(cid, getDirectionTo(getThingPos(cid), getThingPos(itemEx.uid)))
doSetCreatureOutfit(cid, {lookType = 3389, lookHead = outfit.lookHead, lookBody = outfit.lookBody, lookLegs = outfit.lookLegs,lookFeet = outfit.lookFeet}, 3300)
else
doCreatureSetNoMove(cid, true)
doCreatureSetLookDir(cid, getDirectionTo(getThingPos(cid), getThingPos(itemEx.uid)))
doSetCreatureOutfit(cid, {lookType = 3388, lookHead = outfit.lookHead, lookBody = outfit.lookBody, lookLegs = outfit.lookLegs, lookFeet = outfit.lookFeet}, 3300)
end
--- OUTFIT

local normalChestIds = {
[17067] = 1,
[17108] = 3700,
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
doRemoveItem(getThingfromPos(toPosition).uid, 1)
end, 300000)
addEvent(function() -- addEvent que remove o chest final
doCreatureSetNoMove(cid, false)
end, 3300)
return true
end
----------------- Minerio pequeno de neve TERMINA AQUI ---------------------

----------------- Minerio grande de neve COMEÇA AQUI ---------------------
if itemEx.itemid == 17068 then --- ID DO BAU
local nomal_chest_rewards = {{[17088] = math.random(1, 8)},}
local randomNormal = math.random(1,#nomal_chest_rewards)

addEvent(function() -- addEvent ONDE DA O ITEM
for item, quantidade in pairs(nomal_chest_rewards[randomNormal]) do
local itemzin = doPlayerAddItem(cid, item, quantidade)
doItemSetAttribute(itemzin, "unique", 1)
doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Você conseguiu ".. quantidade .." estanhos.") --  17088
end
end, 3700)

--- POS PARA ONDE VAI
local pos = {}
for i = 1, #config.itemid do -- MODIFICAR AQUI \/
    table.insert(pos, getRandomPosSnowTile(config.edges.fromPos, config.edges.toPos))
end

--- POS PARA ONDE VAI
--- OUTFIT
local outfit = getCreatureOutfit(cid)
if getPlayerSex(cid) == 0 then
doCreatureSetNoMove(cid, true)
doCreatureSetLookDir(cid, getDirectionTo(getThingPos(cid), getThingPos(itemEx.uid)))
doSetCreatureOutfit(cid, {lookType = 3389, lookHead = outfit.lookHead, lookBody = outfit.lookBody, lookLegs = outfit.lookLegs,lookFeet = outfit.lookFeet}, 3300)
else
doCreatureSetNoMove(cid, true)
doCreatureSetLookDir(cid, getDirectionTo(getThingPos(cid), getThingPos(itemEx.uid)))
doSetCreatureOutfit(cid, {lookType = 3388, lookHead = outfit.lookHead, lookBody = outfit.lookBody, lookLegs = outfit.lookLegs, lookFeet = outfit.lookFeet}, 3300)
end
--- OUTFIT

local normalChestIds = {
[17068] = 1, 
[17067] = 3700, -- item que vai ser transformado depois de coletado
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
end, 3300)
return true
end
----------------- Minerio grande de neve TERMINA AQUI ---------------------

----------------- Minerio pequeno de neve COMEÇA AQUI ---------------------
if itemEx.itemid == 17065 then --- ID DO BAU
local nomal_chest_rewards = {{[17086] = math.random(1, 3)},}
local randomNormal = math.random(1,#nomal_chest_rewards)

addEvent(function() -- addEvent ONDE DA O ITEM
for item, quantidade in pairs(nomal_chest_rewards[randomNormal]) do
local itemzin = doPlayerAddItem(cid, item, quantidade)
doItemSetAttribute(itemzin, "unique", 1)
doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Você conseguiu ".. quantidade .." cobaltos.") -- 17086
end
end, 3700)

--- POS PARA ONDE VAI
local pos = {}
for i = 1, #config.itemid do -- MODIFICAR AQUI \/
    table.insert(pos, getRandomPosSnowTile(config.edges.fromPos, config.edges.toPos))
end

addEvent(function() -- addEvent onde spawna o item em outro lugar
for i = 1, #pos do doCreateItem(17066, 1, pos[i]) end
end, 300000)

--- POS PARA ONDE VAI
--- OUTFIT
local outfit = getCreatureOutfit(cid)
if getPlayerSex(cid) == 0 then
doCreatureSetNoMove(cid, true)
doCreatureSetLookDir(cid, getDirectionTo(getThingPos(cid), getThingPos(itemEx.uid)))
doSetCreatureOutfit(cid, {lookType = 3389, lookHead = outfit.lookHead, lookBody = outfit.lookBody, lookLegs = outfit.lookLegs,lookFeet = outfit.lookFeet}, 3300)
else
doCreatureSetNoMove(cid, true)
doCreatureSetLookDir(cid, getDirectionTo(getThingPos(cid), getThingPos(itemEx.uid)))
doSetCreatureOutfit(cid, {lookType = 3388, lookHead = outfit.lookHead, lookBody = outfit.lookBody, lookLegs = outfit.lookLegs, lookFeet = outfit.lookFeet}, 3300)
end
--- OUTFIT

local normalChestIds = {
[17065] = 1,
[17108] = 3700,
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
doRemoveItem(getThingfromPos(toPosition).uid, 1)
end, 300000)
addEvent(function() -- addEvent que remove o chest final
doCreatureSetNoMove(cid, false)
end, 3300)
return true
end
----------------- Minerio pequeno de neve TERMINA AQUI ---------------------

----------------- Minerio grande de neve COMEÇA AQUI ---------------------
if itemEx.itemid == 17066 then --- ID DO BAU
local nomal_chest_rewards = {{[17086] = math.random(1, 8)},}
local randomNormal = math.random(1,#nomal_chest_rewards)

addEvent(function() -- addEvent ONDE DA O ITEM
for item, quantidade in pairs(nomal_chest_rewards[randomNormal]) do
local itemzin = doPlayerAddItem(cid, item, quantidade)
doItemSetAttribute(itemzin, "unique", 1)
doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Você conseguiu ".. quantidade .." cobaltos.") -- 17086
end
end, 3700)

--- POS PARA ONDE VAI
local pos = {}
for i = 1, #config.itemid do -- MODIFICAR AQUI \/
    table.insert(pos, getRandomPosSnowTile(config.edges.fromPos, config.edges.toPos))
end

--- POS PARA ONDE VAI
--- OUTFIT
local outfit = getCreatureOutfit(cid)
if getPlayerSex(cid) == 0 then
doCreatureSetNoMove(cid, true)
doCreatureSetLookDir(cid, getDirectionTo(getThingPos(cid), getThingPos(itemEx.uid)))
doSetCreatureOutfit(cid, {lookType = 3389, lookHead = outfit.lookHead, lookBody = outfit.lookBody, lookLegs = outfit.lookLegs,lookFeet = outfit.lookFeet}, 3300)
else
doCreatureSetNoMove(cid, true)
doCreatureSetLookDir(cid, getDirectionTo(getThingPos(cid), getThingPos(itemEx.uid)))
doSetCreatureOutfit(cid, {lookType = 3388, lookHead = outfit.lookHead, lookBody = outfit.lookBody, lookLegs = outfit.lookLegs, lookFeet = outfit.lookFeet}, 3300)
end
--- OUTFIT

local normalChestIds = {
[17066] = 1, 
[17065] = 3700, -- item que vai ser transformado depois de coletado
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
end, 3300)
----------------- Minerio grande de neve TERMINA AQUI ---------------------

else---------- REMOVER O RETURN TRUE DO UTIMO MINERIO
    doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_RED, "Use sua picareta apenas para coletar minérios!")
return true
end

return true
end