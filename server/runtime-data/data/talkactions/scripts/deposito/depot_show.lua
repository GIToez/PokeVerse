function onSay(cid, words, param)
   if not (depotLocker.getPlayerPassword(cid)) then
   local response = {argument = "NoPass",} doSendPlayerExtendedOpcode(cid, GameServerOpcodes.DepotLock, json.encode(response))
	   
   elseif depotLocker.isLocked(cid) then
   local response = {argument = "NoRelease",} doSendPlayerExtendedOpcode(cid, GameServerOpcodes.DepotLock, json.encode(response))

   elseif not depotLocker.isLocked(cid) then
   local response = {argument = "Release",} doSendPlayerExtendedOpcode(cid, GameServerOpcodes.DepotLock, json.encode(response))
      return true
   end
   
   return true
end