-- <!-- Pokemon Tasks -->
-- <event type="kill" name="pokemonTask" script="pokemonTask.lua"/>

function onKill(cid, target, lastHit)
    if hasTaskStarted(cid) then
		if (getCreatureName(target):lower() == getStartedTask(cid):lower()) then
			if (getCurrentTaskKills(cid) < getTaskKillsById(getStartedTaskId(cid))) then
				addTaskKill(cid, 1)
			else
				doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "[Caça Pokémon]: "..getStartedTask(cid)..", Tarefa completa venha receber sua recompensa..")
			return true
			end
			
			doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "[Caça Pokémon]: "..getCurrentTaskKills(cid).." de "..getTaskKillsById(getStartedTaskId(cid)).." "..getStartedTask(cid).."s.")
		end
	end
return true
end