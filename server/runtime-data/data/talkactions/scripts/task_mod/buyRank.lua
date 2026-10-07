function onSay(cid, words, param)
   if getPlayerStorageValue(cid, STORAGE_TASK.RANK)+1 == TABLE_RANK_LEVEL[param][2] then
      if getPlayerStorageValue(cid, STORAGE_TASK.POINTS) >= TABLE_RANK_LEVEL[param].points then
         if getPlayerLevel(cid) >= TABLE_RANK_LEVEL[param][1][1] then
            setPlayerStorageValue(cid, STORAGE_TASK.RANK, TABLE_RANK_LEVEL[param][2])
            setPlayerStorageValue(cid, STORAGE_TASK.POINTS, getPlayerStorageValue(cid, STORAGE_TASK.POINTS) - TABLE_RANK_LEVEL[param].points)
            task.doParsePlayer(cid)
         end      
      end
   end
   return true
end