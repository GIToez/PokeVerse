local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)
local talkState = {}

function onCreatureAppear(cid)				npcHandler:onCreatureAppear(cid)			end
function onCreatureDisappear(cid)			npcHandler:onCreatureDisappear(cid)			end
function onCreatureSay(cid, type, msg)			npcHandler:onCreatureSay(cid, type, msg)		end
function onThink()					npcHandler:onThink()					end

-- function greetCallback(cid)
	-- talkState[cid] = 0
	-- return true
-- end

-- npcHandler:setCallback(CALLBACK_GREET, greetCallback)

local function timeString(timeDiff)
	local dateFormat = {
		{"dia", timeDiff / 60 / 60 / 24},
		{"hora", timeDiff / 60 / 60 % 24},
		{"minuto", timeDiff / 60 % 60},
		{"segundo", timeDiff % 60}
	}

    local out = {}
	for k, t in ipairs(dateFormat) do
        local v = math.floor(t[2])
		if(v > 0) then
            table.insert(out, (k < #dateFormat and (#out > 0 and ', ' or '') or ' e ') .. v .. ' ' .. t[1] .. (v ~= 1 and 's' or ''))
        end
    end

    local ret = table.concat(out)
	if ret:len() < 16 and ret:find("segundo") then
        local a, b = ret:find(" e ")
        ret = ret:sub(b+1)
    end
return ret
end

function creatureSayCallback(cid, type, msg)
	if(not npcHandler:isFocused(cid)) then
		return false
	end

	local talkUser = NPCHANDLER_CONVBEHAVIOR == CONVERSATION_DEFAULT and 0 or cid
	if talkState[talkUser] == nil then
		talkState[talkUser] = 0
	end
	
	if (getTaskDificultyByLevel(getPlayerLevel(cid)) > DIFFICULTY_HARD) then
		selfSay("Olá treinador, você não pode iniciar uma tarefa comigo, você é muito forte.", cid)
		talkState[talkUser] = 0
	return true
	end
	
	if (getTaskDificultyByLevel(getPlayerLevel(cid)) < DIFFICULTY_HARD) then
		selfSay("Olá treinador, você precisa ser pelo menos nível 100 para fazer uma tarefa comigo.", cid)
		talkState[talkUser] = 0
	return true
	end
	
	if (msgcontains(msg, 'iniciar')) then
		if (hasTaskStarted(cid) == true) then
			selfSay("Desculpe, você não pode iniciar outra tarefa até concluir a tarefa iniciada... ("..getStartedTask(cid)..")", cid)
			talkState[talkUser] = 0
		elseif getTaskCooldown(cid) > 1 then
			selfSay("Desculpe, você já concluiu todas as três tarefas de hoje! Volte amanhã para novas tarefas.", cid)
			talkState[talkUser] = 0
		else
			if not hasDualList(cid) then
				if not generateDualList(cid) then
					selfSay("Desculpe, não tenho tarefas para você agora.", cid)
					talkState[talkUser] = 0
					return true
				end
			end
			
			if (getFirstTaskPokemon(cid) and getSecondTaskPokemon(cid)) then
				selfSay("Nesse nível difício você pode derrotar ( "..getFirstTaskPokemon(cid).." ) ou ( "..getSecondTaskPokemon(cid).." ) qual você escolhe ?", cid)
				talkState[talkUser] = 1
			else
				selfSay("Desculpe, você precisa ter pelo menos nível 100 para fazer uma tarefa comigo.", cid)
				talkState[talkUser] = 0
			end
		end
	elseif (msgcontains(msg, 'entregar')) then
		if hasTaskStarted(cid) then
			if getTaskRemainingTime(cid) < 0 then
				selfSay("Você não conseguiu derrotar os pokémons a tempo e falhou em sua tarefa, tente iniciar uma nova terefa.", cid)
				doFinishTask(cid, getStartedTaskId(cid), true)
				talkState[talkUser] = 0
			else
				if (getCurrentTaskKills(cid) >= getTaskKillsById(getStartedTaskId(cid))) then
					selfSay("Parabéns, você terminou a tarefa.", cid)
					doFinishTask(cid, getStartedTaskId(cid), false)
					talkState[talkUser] = 0
				else
					selfSay("Desculpe, você ainda precisa derrotar "..(getTaskKillsById(getStartedTaskId(cid)) - getCurrentTaskKills(cid)).." "..getStartedTask(cid).." para concluir esta tarefa.", cid)
					talkState[talkUser] = 0
				end
			end
		else
			selfSay("Desculpe, você não tem nenhuma tarefa iniciada.", cid)
			talkState[talkUser] = 0
		end
	elseif (talkState[talkUser] >= 1 and talkState[talkUser] < 100) then
		for i = 1, #pokemonTaskTable do
			if (msgcontains(msg, getTaskNameById(i))) then 
				if hasTaskStarted(cid) then
					selfSay("Desculpe, você não pode iniciar outra tarefa até concluir a tarefa iniciada. ( "..getStartedTask(cid).." )", cid)
					talkState[talkUser] = 0
					break
				else
					if canStartTask(cid, i) then
						selfSay("Você terá que derrotar "..getTaskKillsById(i).." "..getTaskNameById(i).."s, tem certeza?", cid)
						talkState[talkUser] = 100 + i
						break
					else
						selfSay(EXCEED_TASK_LEVEL_ERROR, cid)
						break
					end
				end
			end
		end
	elseif talkState[talkUser] > 100 then
		local taskId = talkState[talkUser] - 100
		selfSay("Tudo bem, não perca seu tempo! Você deve derrotar todos esses pokémons e voltar aqui para receber sua recompensa!", cid)
		startTask(cid, taskId)
		talkState[talkUser] = 0
	end
return true
end

npcHandler:setMessage(MESSAGE_GREET, "Olá, eu posso te dar uma tarefa diária para derrotar Pokémons! Pode ajudá-lo a treinar sua experiência de batalha. Eu posso te dar três missões no nível Difício por dia. Oque você deseja ( iniciar ) ou ( entregar )?")
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new())