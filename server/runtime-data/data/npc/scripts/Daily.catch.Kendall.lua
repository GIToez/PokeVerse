local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)
local talkState = {} -- VERY HARD -->

function onCreatureAppear(cid)				npcHandler:onCreatureAppear(cid)			end
function onCreatureDisappear(cid)			npcHandler:onCreatureDisappear(cid)			end
function onCreatureSay(cid, type, msg)			npcHandler:onCreatureSay(cid, type, msg)		end
function onThink()					npcHandler:onThink()					end

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
	
	if (getCatchDificultyByLevel(getPlayerLevel(cid)) < PCATCH_DIFFICULTY_VERY_HARD) then
		selfSay("Olá treinador, você precisa ter pelo menos lvl 150 para iniciar uma tarefa de captura.", cid)
		talkState[talkUser] = 0
	return true
	end
	
	if (getCatchDificultyByLevel(getPlayerLevel(cid)) > PCATCH_DIFFICULTY_VERY_HARD) then
		selfSay("Olá treinador, suas habilidades são muito maior do que as que eu procuro.", cid)
		talkState[talkUser] = 0
	return true
	end
	
	if (msgcontains(msg, 'tarefa')) then
		if (hasCatchStarted(cid) == true) then
			selfSay("Desculpe, você não pode iniciar outra tarefa de captura até concluir a tarefa iniciada... ("..getStartedCatch(cid)..")", cid)
			talkState[talkUser] = 0
		elseif getCatchCooldown(cid) < 1 then
			selfSay("Desculpe, você já concluiu todas as três tarefas diarias! Volte amanhã para mais tarefas.", cid)
			talkState[talkUser] = 0
		else
			if not hasDualCList(cid) then
				if not generateDualCList(cid) then
					selfSay("Desculpe, não tenho tarefas de captura para você agora.", cid)
					talkState[talkUser] = 0
					return true
				end
			end
			
			if (getFirstCatchPokemon(cid) and getSecondCatchPokemon(cid)) then
				selfSay("Você já é forte o suficiente para começar com uma captura Muito dificil, você pode tentar pegar um "..getFirstCatchPokemon(cid).." ou um "..getSecondCatchPokemon(cid)..", qual você quer tentar?", cid)
				talkState[talkUser] = 1
			else
				selfSay("Desculpe, você precisa ter pelo menos lvl 150 para iniciar uma tarefa de captura.", cid)
				talkState[talkUser] = 0
			end
		end
	elseif (msgcontains(msg, 'entregar')) then
		if hasCatchStarted(cid) then
			if haveDoneCatchTask(cid) then
				selfSay("Parabéns conseguiu capturar o pokémon, vamos para a próxima missão ? diga ( tarefa ) novamente.", cid)
				doFinishCatch(cid, getStartedCatchId(cid), false)
				talkState[talkUser] = 0
			else
				selfSay("Desculpe, você ainda precisa pegar um "..getStartedCatch(cid).." para concluir esta tarefa.", cid)
				talkState[talkUser] = 0
			end
		else
			selfSay("Desculpe, você não tem nenhuma tarefa de captura iniciada.", cid)
			talkState[talkUser] = 0
		end
	elseif (talkState[talkUser] >= 1 and talkState[talkUser] < 100) then
		for i = 1, #pokemonCatchTable do
			if (msgcontains(msg, getCatchNameById(i))) then 
				if hasCatchStarted(cid) then
					selfSay("Desculpe, você não pode iniciar outra tarefa de captura até concluir a tarefa iniciada. ("..getStartedCatch(cid)..")", cid)
					talkState[talkUser] = 0
					break
				else
					if canStartCatch(cid, i) then
						selfSay("Você terá que capturar um "..getCatchNameById(i)..", tem certeza?", cid)
						talkState[talkUser] = 100 + i
						break
					else
						selfSay(EXCEED_CTASK_LEVEL_ERROR, cid)
						break
					end
				end
			end
		end
	elseif talkState[talkUser] > 100 then
		local taskId = talkState[talkUser] - 100
		selfSay("Ok, não perca seu tempo! você deve capturar o pokémon e voltar aqui para continuar sua missão antes que o dia acabe, vejo você em breve.", cid)
		startCatch(cid, taskId)
		talkState[talkUser] = 0
	end
return true
end

npcHandler:setMessage(MESSAGE_GREET, "Olá, posso dar-lhe algumas tarefas diárias de captura! Pode ajudar a melhorar sua experiência de captura. Eu posso te dar tres tarefas por dia, você quer começar ? Deseja iniciar uma ( tarefa ) ou ( entregar )?")
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new())