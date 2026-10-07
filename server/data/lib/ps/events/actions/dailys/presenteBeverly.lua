function onUse(cid, item, frompos, item2, topos)

local presente = {box = {34535, 1}}

if getPlayerItemCount(cid, presente.box[1]) >= presente.box[2] then
local Pokebolas = {
{[12157] = math.random(1, 100)}, --- Pokeball
{[12161] = math.random(1, 100)}, --- greatball
{[12165] = math.random(1, 100)}, --- ultraball
{[12247] = math.random(1, 100)}, --- potion
{[13819] = math.random(1, 100)}, --- potion
}
local rareballs = {
  {itemId = 19029, count = 20, chance = 10}, -- AVALANCHE  
  {itemId = 19033, count = 20, chance = 10}, -- BLAZE  
  {itemId = 19037, count = 20, chance = 10}, -- GAIA
  {itemId = 19041, count = 20, chance = 10}, -- HEREMIT
  {itemId = 19045, count = 20, chance = 10}, -- HURRICANE
  {itemId = 19049, count = 20, chance = 10}, -- SPECTRUM
  {itemId = 19053, count = 20, chance = 10}, -- VITAL
  {itemId = 19057, count = 20, chance = 10}, -- VOLTAGIC
  {itemId = 19061, count = 20, chance = 10}, -- ZEN
}
local PaintTicket = {
  {PaintID = 14449, count = 1, chance = 10},
  {PaintID = 14450, count = 1, chance = 10},
  {PaintID = 14459, count = 1, chance = 10},
  {PaintID = 14460, count = 1, chance = 10},
  {PaintID = 18734, count = 1, chance = 10},   
  {PaintID = 18735, count = 1, chance = 10},
  {PaintID = 18736, count = 1, chance = 10},
  {PaintID = 18867, count = 1, chance = 10},     
  {PaintID = 18868, count = 1, chance = 10},     
  {PaintID = 18869, count = 1, chance = 10},     
  {PaintID = 18870, count = 1, chance = 10},     
  {PaintID = 18871, count = 1, chance = 10},     
}

-------------------- PAINT TICKET
local totalChance, randomTable, randomNumber = 0, {}, 0

for _, PaintInfo in pairs (PaintTicket) do
  randomTable[PaintInfo.PaintID] = {min = totalChance + 1, max = PaintInfo.chance, count = PaintInfo.count or 1}
  totalChance = totalChance + PaintInfo.chance
end

randomNumber = math.random(1, totalChance)
for PaintID, PaintInfo in pairs (randomTable) do
  local min, max = PaintInfo.min, PaintInfo.min + PaintInfo.max
  if randomNumber >= min and randomNumber <= max then
    local newItem = doPlayerAddItem(cid, PaintID, PaintInfo.count, false)
    if not newItem then return doPlayerSendCancel(cid, "Voce nao tem espaco para receber o item!") end
    break
  end
end
-------------------- PAINT TICKET
-------------------- ELEMENT BALL
local totalChance, randomTable, randomNumber = 0, {}, 0

for _, itemInfo in pairs (rareballs) do
  randomTable[itemInfo.itemId] = {min = totalChance + 1, max = itemInfo.chance, count = itemInfo.count or 1}
  totalChance = totalChance + itemInfo.chance
end

randomNumber = math.random(1, totalChance)
for itemId, itemInfo in pairs (randomTable) do
  local min, max = itemInfo.min, itemInfo.min + itemInfo.max
  if randomNumber >= min and randomNumber <= max then
    local newItem = doPlayerAddItem(cid, itemId, math.random(1, 20), false)
    if not newItem then return doPlayerSendCancel(cid, "Voce nao tem espaco para receber o item!") end
    break
  end
end
-------------------- ELEMENT BALL
local PokeBalls = math.random(1,#Pokebolas)
for item, quantidade in pairs(Pokebolas[PokeBalls]) do
local PokeBalls1 = math.random(1,#Pokebolas)
for item1, quantidade in pairs(Pokebolas[PokeBalls1]) do
local PokeBalls2 = math.random(1,#Pokebolas)
for item2, quantidade in pairs(Pokebolas[PokeBalls2]) do
doPlayerAddItem(cid, item, quantidade)
doPlayerAddItem(cid, item1, quantidade)
doPlayerAddItem(cid, item2, quantidade)
end
end
end
--------------------

doRemoveItem(item.uid, 1)
else
doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_RED, "Para abrir este presente você precisa coloca-lo na mochila.")
doSendMagicEffect(getCreaturePosition(cid), 2)
return true
end 
end