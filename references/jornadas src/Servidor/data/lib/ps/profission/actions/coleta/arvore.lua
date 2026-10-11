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
doPlayerSay(cid, ""..getPokeName(getCreatureSummons(cid)[1])..", Preciso cortar esta arvore!", 19)
doRegainSpeed(cid) doRemoveCondition(cid, CONDITION_OUTFIT) setPlayerStorageValue(cid, 17000, -1)
setPlayerStorageValue(cid, 17001, -1) return true end

if getDirectionTo(getCreaturePosition(cid), getThingPosition(itemEx.uid)) > getCreatureLookDirection(cid) then
doPlayerSendCancel(cid, "Você precisa está na frente da arvore!")return true end

-- if not isPremium(cid) then
	-- doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Apenas jogadores VIP'S podem cortar arvores.")
	-- return true
-- end

-- if getPlayerProfession(cid) ~= "stylist" then
    -- doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Somente estilista podem cortar arvores.")
	-- return true
-- end

local nomal_chest_rewards = { --- premios que podem vir no bau ( aleatóriamente )
{[17094] = math.random(1, 4)},
}
local randomNormal = math.random(1,#nomal_chest_rewards)

if itemEx.itemid == 2711 then --- ID DO BAU
addEvent(function()
for item, quantidade in pairs(nomal_chest_rewards[randomNormal]) do
local itemzin = doPlayerAddItem(cid, item, quantidade)
doItemSetAttribute(itemzin, "unique", 1)
end
end, 4100)

local outfit = getCreatureOutfit(cid)
if getPlayerSex(cid) == 0 then
doCreatureSetNoMove(cid, true)
doCreatureSetLookDir(cid, getDirectionTo(getThingPos(cid), getThingPos(itemEx.uid)))
doSetCreatureOutfit(cid, {lookType = 3391, lookHead = outfit.lookHead, lookBody = outfit.lookBody, lookLegs = outfit.lookLegs, lookFeet = outfit.lookFeet}, 3700)
else
doCreatureSetNoMove(cid, true)
doCreatureSetLookDir(cid, getDirectionTo(getThingPos(cid), getThingPos(itemEx.uid)))
doSetCreatureOutfit(cid, {lookType = 3390, lookHead = outfit.lookHead, lookBody = outfit.lookBody, lookLegs = outfit.lookLegs, lookFeet = outfit.lookFeet}, 3700)
end

local ArvoreAnimation = { --- tempo usado com MILISEGUNDOS
[2711] = 1,
[17052] = 4000, 
[17053] = 4200, 
[17054] = 4400, 
[17055] = 4600, 
[17056] = 4800,
[17057] = 100000, ---- trava aqui até 1 minuto e 40 segundos.
[17058] = 200000, ---- trava aqui até 3 minuto e 20 segundos.
[2711] = 300000, --- trava aqui até 5 minuto.
}
for ids, tempo in pairs(ArvoreAnimation) do
function TransformItem(position, itemid)
doRemoveItem(getThingfromPos(position).uid, 1)
doCreateItem(itemid, 1, position)
end
addEvent(TransformItem, tempo, toPosition, ids) -- addEvent da função acima, que transforma os itens
end
addEvent(function() -- addEvent que remove o chest final
doCreatureSetNoMove(cid, false)
end, 3700)
else
    doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_RED, "Isso não é uma arvore!")
return true
end
return true
end