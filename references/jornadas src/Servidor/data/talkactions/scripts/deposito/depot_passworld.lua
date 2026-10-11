function onSay(cid, words, param)
   local msg = "Locker System\n\n* Criando uma senha: \nPara criar uma senha digite: ".. words .." password, senha. Substituindo senha pela senha que você quer criar!\n\n*Modificando uma senha: ".. words .." passchange, senhaantiga, nova. Substituindo senhaantiga pela sua senha antiga e nova pela sua nova senha.\n\n*Removendo sua senha \n Para remover sua senha digite: ".. words .. " remove, senha(substituindo senha pela sua senha atual)."
   local tmp = string.explode(param, ",")
   
   if not(isItemInRange(getThingPos(cid), 1, depotLocker.config.depotIDs)) then
      return doPlayerSendCancel(cid, "Você deve estar perto de um depósito para poder usar o sistema.")
   end
   
   if not(tmp[1]) then
   if depotLocker.isLocked(cid) then
      local data = depotLocker.getEvironmentData(getThingPos(cid))
		return doShowTextDialog(cid, data.boardID, depotLocker.config.typeYourPassMsg, true)
	elseif not depotLocker.isLocked(cid) and depotLocker.getPlayerPassword(cid) then	
		return doPlayerSendCancel(cid, "Seu depósito ja esta destravado.")	
   end	  
   elseif (tmp[1] == "password") then
      if (depotLocker.getPlayerPassword(cid)) then
         return doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Você já estabeleceu uma senha para seu depósito!")
      end
      if not(tmp[1]) then
         return false
      end
	  if not(depotLocker.checkPasswordSecurity(tostring(tmp[2])) == true) then
	  return doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_RED, tostring(depotLocker.checkPasswordSecurity(tmp[2])))
	  end
      depotLocker.setPlayerPassword(cid, tostring(tmp[2]))
      return doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Sua nova senha é : ".. tostring(tmp[2])) 
	  
   elseif (tmp[1]:lower() == "passchange") then
      if not (tmp[3]) then
         return false
      end
      if (depotLocker.getPlayerPassword(cid) ~= -1) and (tmp[2] ~= tostring(depotLocker.getPlayerPassword(cid))) then
         return doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Digite a sua senha atual corretamente!")
      end
      if (depotLocker.getPlayerPassword(cid) == -1) then
	  return doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Você não tem uma senha para poder alterar.")
	  end
	  if not(depotLocker.checkPasswordSecurity(tostring(tmp[3])) == true) then
	  return doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, tostring(depotLocker.checkPasswordSecurity(tmp[3])))
	  end
	  
      doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Sua senha foi alterada de ".. depotLocker.getPlayerPassword(cid) .." para ".. tmp[3] ..".")
      return depotLocker.setPlayerPassword(cid, tostring(tmp[3]))
	  
   elseif (tmp[1]:lower() == "remove") then
      if (depotLocker.getPlayerPassword(cid) == -1) then
         return doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Você não tem senha para remover!")
      end
      if not (tmp[2]) then
         return false
      end
      if (depotLocker.getPlayerPassword(cid) ~= -1) and (tmp[2] ~= depotLocker.getPlayerPassword(cid)) then
         return doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Digite a sua senha atual corretamente!")
      end
      doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Sua senha foi removida!")
      return depotLocker.setPlayerPassword(cid, nil)
   elseif (tmp[1]:lower() == "lock") or (tmp[1]:lower() == "closed") then
   if depotLocker.isLocked(cid) then
    return doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Seu depósito ja esta trancado.")
	else
    setPlayerStorageValue(cid, depotLocker.storages.lockState, 0)
	return doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Seu depósito foi trancado.")
	end
end	

    return false
end

function doFindItemInPos(ids,pos) -- By Undead Slayer
   local results = {}
   for _ = 0, 255 do
       local findPos = {x = pos.x, y = pos.y, z = pos.z, stackpos = _}
       if isInArray(ids, getThingFromPos(findPos).itemid) then
          table.insert(results, getThingfromPos(findPos))
       end
   end

   return results
end

function isItemInRange(cp, range, ids)
    local extr1 = {x = cp.x - range, y = cp.y -range, z = cp.z}
    local extr2 = {x = cp.x + range, y = cp.y + range, z = cp.z}
    for i = 1, (extr2.y-extr1.y)+1 do
        for s = 1, (extr2.x-extr1.x)+1 do
            local f = {x=extr1.x+s-1, y=extr1.y+i-1, z=extr1.z, stackpos=0}
            local posz = doFindItemInPos(ids, f)
            if (#posz > 0) then
               return true
            end
        end
     end
return false
end