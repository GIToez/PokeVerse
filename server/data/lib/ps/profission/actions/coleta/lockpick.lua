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
doPlayerSay(cid, ""..getPokeName(getCreatureSummons(cid)[1])..", Preciso abrir este baú!", 19)
doRegainSpeed(cid) doRemoveCondition(cid, CONDITION_OUTFIT) setPlayerStorageValue(cid, 17000, -1)
setPlayerStorageValue(cid, 17001, -1) return true end

if getDirectionTo(getCreaturePosition(cid), getThingPosition(itemEx.uid)) > getCreatureLookDirection(cid) then
doPlayerSendCancel(cid, "Você precisa está na frente do baú!")return true end

if not isPremium(cid) then
	doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Apenas jogadores VIP'S podem abrir baús.")
	return true
end

if getPlayerProfession(cid) ~= "adventurer" then
    doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Somente aventureiro podem usar este item.")
	return true
end

-- CHEGAGENS


local zPos = math.random(1, 7)
local config = {
    itemid = {17003}, --- ID DO BAU normal
    edges = { ---- Para onde o bau vai ser spawnado depois que for aberto.
        fromPos = {x = 0, y = 0, z = 0},
        toPos = {x = 1646, y = 2068, z = 7}  
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

----------------- BAU NORMAL COMEÇA AQUI ---------------------
if itemEx.itemid == 17003 then --- ID DO BAU
doPlayerRemoveItem(cid, 17064, 1) --- ID DO LOCKPICK

---------- PRIMEIRA LISTA PARA SER ADICIONADA
addEvent(function() -- addEvent que remove a condição NoMove
local ITENS = { --- premios que podem vir no bau ( aleatóriamente )
{[15981] = math.random(1, 35)}, --- great ball
{[15982] = math.random(1, 35)}, --- super ball
{[15774] = math.random(1, 50)}, --- Potion Class (C)
{[15776] = math.random(1, 50)}, --- Potion Class (C)
{[15775] = math.random(1, 50)}, --- Potion Class (C+)
{[15783] = math.random(1, 50)}, --- Revive (0-125)

{[17781] = math.random(1, 1)}, --- Pokebag. (Vol:8)
{[17782] = math.random(1, 1)}, --- Great Bag. (Vol:12)
{[17783] = math.random(1, 1)}, --- Super Bag. (Vol:16)
{[17784] = math.random(1, 1)}, --- Ultra Bag. (Vol:24)
}
local randomNormal = math.random(1,#ITENS)
for item, quantidade in pairs(ITENS[randomNormal]) do
local itemzin = doPlayerAddItem(cid, item, quantidade)
local itemzin1 = doPlayerAddItem(cid, 17102, math.random(1, 10))
doItemSetAttribute(itemzin1, "unique", 1)
doSendMagicEffect(getThingPos(cid), 173)
end
end, 5200)
---------- PRIMEIRA LISTA PARA SER ADICIONADA

---------- ENVIA O BAU PARA OUTRO LOCAL
addEvent(function() -- addEvent que remove a condição NoMove
local pos = {}
for i = 1, #config.itemid do
    table.insert(pos, getRandomPos(config.edges.fromPos, config.edges.toPos))
end
for i = 1, #pos do doCreateItem(config.itemid[i], 1, pos[i]) end
end, 300000)
---------- ENVIA O BAU PARA OUTRO LOCAL

local outfit = getCreatureOutfit(cid)
if getPlayerSex(cid) == 0 then
doCreatureSetNoMove(cid, true)
doCreatureSetLookDir(cid, getDirectionTo(getThingPos(cid), getThingPos(itemEx.uid)))
doSetCreatureOutfit(cid, {lookType = 3397, lookHead = outfit.lookHead, lookBody = outfit.lookBody, lookLegs = outfit.lookLegs, lookFeet = outfit.lookFeet}, 3800)
else
doCreatureSetNoMove(cid, true)
doCreatureSetLookDir(cid, getDirectionTo(getThingPos(cid), getThingPos(itemEx.uid)))
doSetCreatureOutfit(cid, {lookType = 3396, lookHead = outfit.lookHead, lookBody = outfit.lookBody, lookLegs = outfit.lookLegs, lookFeet = outfit.lookFeet}, 3800)
end
local normalChestIds = {
[17003] = 1, 
[17004] = 4000, 
[17005] = 4200, 
[17006] = 4400, 
[17007] = 4600, 
[17008] = 4800, 
[17009] = 5000, 
[17010] = 5200,
}
for ids, tempo in pairs(normalChestIds) do
function TransformItem(position, itemid)
doRemoveItem(getThingfromPos(position).uid, 1)
doCreateItem(itemid, 1, position)
end
addEvent(TransformItem, tempo, toPosition, ids) -- addEvent da função acima, que transforma os itens
end
addEvent(function() -- addEvent que remove a condição NoMove
doCreatureSetNoMove(cid, false)
end, 5200)
addEvent(function() -- addEvent que remove o chest final
doRemoveItem(getThingfromPos(toPosition).uid, 1)
end, 300000)
return true
end
----------------- BAU NORMAL TERMINA AQUI ---------------------

----------------- BAU DE PRATA COMEÇA AQUI ---------------------
if itemEx.itemid == 17028 then --- ID DO BAU
doPlayerRemoveItem(cid, 17064, 1) --- ID DO LOCKPICK

---------- PRIMEIRA LISTA PARA SER ADICIONADA
addEvent(function() -- addEvent que remove a condição NoMove
local ITENS = { --- premios que podem vir no bau ( aleatóriamente )
{[15983] = math.random(1, 50)}, --- ultra ball
{[16880] = math.random(1, 1)}, --- XP BOOST
{[15781] = math.random(1, 50)}, --- Potion Class (A+)
{[15784] = math.random(1, 50)}, --- Revive (125-250)

{[16014] = math.random(1, 1)}, --- Bracelete Venusaurs
{[16003] = math.random(1, 1)}, --- Winer Charizards
{[16605] = math.random(1, 1)}, --- Rock Backpack. (Vol:24)
{[16683] = math.random(1, 1)}, --- Scyther arranhados
{[16005] = math.random(1, 1)}, --- Secret Ninja Blastoises
}
local randomNormal = math.random(1,#ITENS)
for item, quantidade in pairs(ITENS[randomNormal]) do
local itemzin = doPlayerAddItem(cid, item, quantidade)
local itemzin1 = doPlayerAddItem(cid, 17102, math.random(1, 27)) --- Coin
local itemzin2 = doPlayerAddItem(cid, 15996, math.random(1, 5)) --- premier ball
doItemSetAttribute(itemzin1, "unique", 1)
doItemSetAttribute(itemzin2, "unique", 1)
doSendMagicEffect(getThingPos(cid), 173)
end
end, 5000)
---------- PRIMEIRA LISTA PARA SER ADICIONADA

---------- ENVIA O BAU PARA OUTRO LOCAL
addEvent(function() -- addEvent que remove a condição NoMove
local pos = {}
for i = 1, #config.itemid do
    table.insert(pos, getRandomPos(config.edges.fromPos, config.edges.toPos))
end
for i = 1, #pos do doCreateItem(17028, 1, pos[i]) end
end, 300000)
---------- ENVIA O BAU PARA OUTRO LOCAL

local outfit = getCreatureOutfit(cid)
if getPlayerSex(cid) == 0 then
doCreatureSetNoMove(cid, true)
doCreatureSetLookDir(cid, getDirectionTo(getThingPos(cid), getThingPos(itemEx.uid)))
doSetCreatureOutfit(cid, {lookType = 3397, lookHead = outfit.lookHead, lookBody = outfit.lookBody, lookLegs = outfit.lookLegs, lookFeet = outfit.lookFeet}, 3600)
else
doCreatureSetNoMove(cid, true)
doCreatureSetLookDir(cid, getDirectionTo(getThingPos(cid), getThingPos(itemEx.uid)))
doSetCreatureOutfit(cid, {lookType = 3396, lookHead = outfit.lookHead, lookBody = outfit.lookBody, lookLegs = outfit.lookLegs, lookFeet = outfit.lookFeet}, 3600)
end
local normalChestIds = {
[17028] = 1, 
[17029] = 4000, 
[17030] = 4200, 
[17031] = 4400, 
[17032] = 4600, 
[17033] = 4800, 
[17034] = 5000, 
}
for ids, tempo in pairs(normalChestIds) do
function TransformItem(position, itemid)
doRemoveItem(getThingfromPos(position).uid, 1)
doCreateItem(itemid, 1, position)
end
addEvent(TransformItem, tempo, toPosition, ids) -- addEvent da função acima, que transforma os itens
end
addEvent(function() -- addEvent que remove a condição NoMove
doCreatureSetNoMove(cid, false)
end, 5000)
addEvent(function() -- addEvent que remove o chest final
doRemoveItem(getThingfromPos(toPosition).uid, 1)
end, 300000)
return true
end
----------------- BAU DE PRATA TERMINA AQUI ---------------------

----------------- BAU DE OURO COMEÇA AQUI ---------------------
if itemEx.itemid == 17012 then --- ID DO BAU
doPlayerRemoveItem(cid, 17064, 1) --- ID DO LOCKPICK

---------- PRIMEIRA LISTA PARA SER ADICIONADA
addEvent(function() -- addEvent que remove a condição NoMove
local ITENS = { --- premios que podem vir no bau ( aleatóriamente )
{[12618] = math.random(1, 1)}, --- boost stone
{[17103] = math.random(1, 1)}, --- fragmento de ouro
{[16880] = math.random(1, 1)}, --- booster
{[17351] = math.random(1, 1)}, --- toy box
{[17503] = math.random(1, 1)}, --- shiny toy box
{[15999] = math.random(1, 1)}, --- addon box
{[16868] = math.random(1, 1)}, --- Kangaskhan Cowboys
{[16882] = math.random(1, 1)}, --- Shiny charm
}
local randomNormal = math.random(1,#ITENS)
for item, quantidade in pairs(ITENS[randomNormal]) do
local itemzin = doPlayerAddItem(cid, item, quantidade)
local itemzin1 = doPlayerAddItem(cid, 17102, math.random(1, 40)) --- Coin
local itemzin2 = doPlayerAddItem(cid, 15996, math.random(1, 10)) --- premier ball
doItemSetAttribute(itemzin1, "unique", 1)
doItemSetAttribute(itemzin2, "unique", 1)
doSendMagicEffect(getThingPos(cid), 173)
end
end, 5200)
---------- PRIMEIRA LISTA PARA SER ADICIONADA

---------- ENVIA O BAU PARA OUTRO LOCAL
addEvent(function() -- addEvent que remove a condição NoMove
local pos = {}
for i = 1, #config.itemid do
    table.insert(pos, getRandomPos(config.edges.fromPos, config.edges.toPos))
end
for i = 1, #pos do doCreateItem(17012, 1, pos[i]) end
end, 300000)
---------- ENVIA O BAU PARA OUTRO LOCAL

local outfit = getCreatureOutfit(cid)
if getPlayerSex(cid) == 0 then
doCreatureSetNoMove(cid, true)
doCreatureSetLookDir(cid, getDirectionTo(getThingPos(cid), getThingPos(itemEx.uid)))
doSetCreatureOutfit(cid, {lookType = 3397, lookHead = outfit.lookHead, lookBody = outfit.lookBody, lookLegs = outfit.lookLegs, lookFeet = outfit.lookFeet}, 3800)
else
doCreatureSetNoMove(cid, true)
doCreatureSetLookDir(cid, getDirectionTo(getThingPos(cid), getThingPos(itemEx.uid)))
doSetCreatureOutfit(cid, {lookType = 3396, lookHead = outfit.lookHead, lookBody = outfit.lookBody, lookLegs = outfit.lookLegs, lookFeet = outfit.lookFeet}, 3800)
end
local normalChestIds = {
[17012] = 1, 
[17013] = 4000, 
[17014] = 4200, 
[17015] = 4400, 
[17016] = 4600, 
[17017] = 4800, 
[17018] = 5000, 
[17019] = 5200, 
}
for ids, tempo in pairs(normalChestIds) do
function TransformItem(position, itemid)
doRemoveItem(getThingfromPos(position).uid, 1)
doCreateItem(itemid, 1, position)
end
addEvent(TransformItem, tempo, toPosition, ids) -- addEvent da função acima, que transforma os itens
end
addEvent(function() -- addEvent que remove a condição NoMove
doCreatureSetNoMove(cid, false)
end, 5200)
addEvent(function() -- addEvent que remove o chest final
doRemoveItem(getThingfromPos(toPosition).uid, 1)
end, 300000)
----------------- BAU DE OURO TERMINA AQUI ---------------------
else
    doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_RED, "Use suas palhetas apenas em baús!")
return true
end

return true
end