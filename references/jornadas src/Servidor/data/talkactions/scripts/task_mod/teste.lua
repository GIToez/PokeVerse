function onSay(cid, words, param)
   setPlayerStorageValue(cid, STORAGE_TASK.RANK, -1)
   setPlayerStorageValue(cid, STORAGE_TASK.POINTS, 100)
   task.doParsePlayer(cid)
   task.doParseTask(cid)
   return true
end