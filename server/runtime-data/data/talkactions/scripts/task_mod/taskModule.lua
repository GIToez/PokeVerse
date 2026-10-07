function onSay(cid, words, param)
   local explode = string.explode(param, ",") 
   if #explode < 2 then return false end  
   
   local t = TABLE_TASKS[ explode[2] ]
   if not t then return false end
   
   if explode[1] == "accept" then
      if getPlayerStorageValue(cid,task.getStorage(TABLE_TASKS[explode[2]].id, STORAGE_TASK.CONST.OFFSET.DELAY))-os.time() > 0 then
         local __buffer = {}
         __buffer["[delayTask]"] = math.floor((getPlayerStorageValue(cid,task.getStorage(TABLE_TASKS[explode[2]].id, STORAGE_TASK.CONST.OFFSET.DELAY))-os.time())/60) + 1      
         doSendPlayerExtendedOpcode(cid, GameServerOpcodes.TaskModule, table.tostring(__buffer))  
         return true
      end        
      if not task.doing(cid, explode[2]) and getDoingTasks(cid) ~= "" then
         doPlayerSendCancel(cid, __L(cid, 'You are already doing a task. Finish or cancel it first.'))
         return true
      end
      if task.doSaveSlot(cid, explode[2]) then
         doPlayerSendCancel(cid, string.format(__L(cid, 'Go and defeat %d %s.'), t.count, explode[2]))   
         task.doStart(cid, explode[2])     
      end
   elseif explode[1] == "done" then
      if task.doing(cid, explode[2]) then
         if task.killedNeededCount(cid, explode[2]) then
            doPlayerSendCancel(cid, string.format(__L(cid, 'You finished the %s task and gained %d experience points.'), explode[2], TABLE_TASKS[explode[2]].exp))
            task.doComplete(cid, explode[2])
			local __buffer = {}
			__buffer["[CompleteiAMissao]"] = {}
			doSendPlayerExtendedOpcode(cid, GameServerOpcodes.TaskModule, table.tostring(__buffer))
            if TABLE_TASKS[explode[2]].msg then
               doPlayerSendTextMessage(cid,MESSAGE_EVENT_ADVANCE,TABLE_TASKS[explode[2]].msg)
            end
		 else

         local __buffer = {}
         __buffer["[TaskNaoCompleta]"] = {}
         doSendPlayerExtendedOpcode(cid, GameServerOpcodes.TaskModule, table.tostring(__buffer))		

        end
      end
   elseif explode[1] == "cancel" then
      if(task.doCancel(cid, explode[2])) then  
         doPlayerSendCancel(cid, string.format(__L(cid, 'The %s task was cancelled.'), explode[2])) 
         local __buffer = {}
         __buffer["[MissaoAbandonada]"] = {}
         doSendPlayerExtendedOpcode(cid, GameServerOpcodes.TaskModule, table.tostring(__buffer))
      end 
      task.doParsePlayer(cid)
      task.doParseTask(cid, explode[2]) 
   end
   return true
end