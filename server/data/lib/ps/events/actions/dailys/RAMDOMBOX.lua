local items = {
  {itemId = 12035, count = 1, chance = 30}, -- ITEM, QUANTIDADE, CHANCE
  {itemId = 12034, count = 1, chance = 20},
  {itemId = 12033, count = 1, chance = 20},
  {itemId = 12032, count = 1, chance = 20},
  {itemId = 12031, count = 1, chance = 20},   
  {itemId = 12030, count = 1, chance = 20},
  {itemId = 12547, count = 1, chance = 10},
  {itemId = 15685, count = 1, chance = 1},     
}
local broadcastitems = {12547, 15685}

function onUse(cid, item, frompos, item2, topos)

  local totalChance, randomTable, randomNumber = 0, {}, 0

  for _, itemInfo in pairs (items) do
    randomTable[itemInfo.itemId] = {min = totalChance + 1, max = itemInfo.chance, count = itemInfo.count or 1}
    totalChance = totalChance + itemInfo.chance
  end

  randomNumber = math.random(1, totalChance)
  for itemId, itemInfo in pairs (randomTable) do
    local min, max = itemInfo.min, itemInfo.min + itemInfo.max
    if randomNumber >= min and randomNumber <= max then
      local newItem = doPlayerAddItem(cid, itemId, itemInfo.count, false)
      if not newItem then return doPlayerSendCancel(cid, "Voce nao tem espaco para receber o item!") end
      doRemoveItem(item.uid, 1)
	  local pos = {x=getPlayerPosition(cid).x+0, y=getPlayerPosition(cid).y+0, z=getPlayerPosition(cid).z+0}
	  doSendMagicEffect(pos, 684) -- Id do efeito.
      local iInfo = getItemInfo(itemId)
      doPlayerSendTextMessage(cid, 25, "Voce ganhou "..itemInfo.count.." "..iInfo.name.."")
      for i, broaditem in ipairs(broadcastitems) do
        if itemId==broaditem then doBroadcastMessage(getCreatureName(cid).." acabou de ganhar: "..itemInfo.count.." "..iInfo.name.." (Raro) na presente box.", 19) end
      end
      break
    end
  end
  return true
end



--================= NEXT FUNCTION ====================--
local config = {
   [90] = {ID, COUNT},
   [80] = {ID, COUNT},
   [59] = {ID, COUNT},
   [50] = {ID, COUNT},
   [40] = {ID, COUNT},
   [30] = {ID, COUNT},
   [20] = {ID, COUNT},
   [10] = {ID, COUNT},
   [3] = {ID, COUNT},
   [1] = {ID, COUNT},
}
 
function onUse(cid)
   
 
   local chance_growing = {}
 
   for chance, _ in pairs(config) do
      table.insert(chance_growing, chance)
   end
 
   table.sort(chance_growing, function(a, b) return a > b end)
 
   local chance = 0
 
   for _, v in pairs(chance_growing) do
      if math.random(100) < v then
         chance = v
         break
      end
   end
 
   local item = config[chance]
   if item then
      doPlayerAddItem(cid, item[1], item[2])
      doPlayerSendTextMessage(cid, MESSAGE_EVENT_ADVANCE, "Você encontrou ".. item[2] .." ".. item[1] .. ".")
      doSendMagicEffect(getThingPos(cid), 13)
   else
      doPlayerSendTextMessage(cid, MESSAGE_EVENT_ADVANCE, "Não foi dessa vez, tente na próxima ):")
   end
 
   return true
end
--================= NEXT FUNCTION ====================--