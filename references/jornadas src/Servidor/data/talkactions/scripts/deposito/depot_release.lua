function onSay(cid, words, param)
   local pass = string.explode(param, ",")

   	if (pass[1]) then
		if not depotLocker.isLocked(cid) then
			return doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Seu depósito já está destravado.")
		elseif not(isItemInRange(getThingPos(cid), 1, depotLocker.config.depotIDs)) then
			return doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Você deve estar perto de um depósito.")
		end
		depotLocker.checkPassword(cid, tostring(pass[1]))
	elseif (isItemInRange(getThingPos(cid), 1, depotLocker.config.depotIDs)) then
		depotLocker.checkPassword(cid, tostring(pass[1]))
	end
	
    return true
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