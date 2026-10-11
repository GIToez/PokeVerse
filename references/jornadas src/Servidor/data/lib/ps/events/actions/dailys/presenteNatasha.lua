function onUse(cid, item, frompos, item2, topos)

local presente = {box = {34531, 1}}

if getPlayerItemCount(cid, presente.box[1]) >= presente.box[2] then
local Pokebolas = {
{[12157] = math.random(1, 75)}, --- Pokeball
{[12161] = math.random(1, 75)}, --- greatball
{[12165] = math.random(1, 30)}, --- superball
}
local potion = {
{[12247] = math.random(1, 50)},
{[13819] = math.random(1, 50)},
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
local broadcastitems = {12547, 15685}

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

local PokeBalls = math.random(1,#Pokebolas)
for item, quantidade in pairs(Pokebolas[PokeBalls]) do
doPlayerAddItem(cid, item, quantidade)
end
local Potions = math.random(1,#potion)
for item, quantidade in pairs(potion[Potions]) do
doPlayerAddItem(cid, item, quantidade)
end
doRemoveItem(item.uid, 1)
else
doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_RED, "Para abrir este presente você precisa coloca-lo na mochila.")
doSendMagicEffect(getCreaturePosition(cid), 2)
return true
end 
end