function doPlayerAddDepotItem(cid, item, count)
   local item,count,pid = type(item)=="table" and item or {item},type(count)=="table" and count or {(count or 1)},getPlayerGUID(cid)
   doRemoveCreature(cid)
   for k,v in ipairs(item) do
    local ls = db.getResult("SELECT `sid` FROM `player_depotitems` WHERE `player_id` = "..pid.." ORDER BY `sid` DESC LIMIT 1")
    return db.executeQuery("INSERT INTO `player_depotitems` (`player_id`, `sid`, `pid`, `itemtype`, `count`, `attributes`) VALUES ("..pid..", "..(ls:getDataInt("sid")+1)..", 101, "..v..", "..count[k]..", '"..(count[k] > 1 and string.format("%x",count[k]) or '').."')") or false
   end
end

function onSay(cid, words, param, channel)
   if(param == '') then
       doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Comando precisa de parametros: nomedoplayer, iddoitem, quantidade.")
       return true
   end

   local t = string.explode(param, ",")
   local diamondID = 34524
   local diamondCount = 35
   local PassID = 35554

   local player = getPlayerByNameWildcard(tostring(t[1]))
   local playerCid = getPlayerByNameWildcard(cid)
   if(not isPlayer(player)) then -- verifica se o jogador ta online
		local protocol = Protocol_create('OffLinePlayer')
		doSendPlayerExtendedOpcode(cid, Pass.opcode, table.tostring(protocol))
       return true
   end

   if getPlayerItemCount(cid, diamondID) < diamondCount then -- verifica se o jogador tem diamante
		local protocol = Protocol_create('NoDiamondsPass')
		doSendPlayerExtendedOpcode(cid, Pass.opcode, table.tostring(protocol))
      return true
   end
 
   local playername = tostring(t[1])

   doPlayerRemoveItem(cid, diamondID, diamondCount)
   setItemUniqueOwner(doPlayerAddItem(player, PassID, 1), player)
   local protocol = Protocol_create('SucessSendPass')
   doSendPlayerExtendedOpcode(cid, Pass.opcode, table.tostring(protocol))

   return true
end