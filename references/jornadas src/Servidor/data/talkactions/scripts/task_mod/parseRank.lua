function onSay(cid, words, param)
   if isInArray(TABLE_RANKS, param) then
      if getPlayerStorageValue(cid, STORAGE_TASK.RANK) < TABLE_RANK_LEVEL[param][2] then  
         if param == "E" then return true end
         local p = 1
         for i=1,#TABLE_RANKS do
            if param == TABLE_RANKS[i] then
               p = i
            end
         end
         local __buffer = {}
         __buffer["[unlockRank]"] = {level = TABLE_RANK_LEVEL[param][1][1], points = TABLE_RANK_LEVEL[param].points, rank = TABLE_RANKS[p-1]}
         doSendPlayerExtendedOpcode(cid, GameServerOpcodes.TaskModule, table.tostring(__buffer))
         return true
      end
      setPlayerStorageValue(cid,STORAGE_TASK.VIEW,param)
      task.doParseTasks(cid)
   end
   return true
end