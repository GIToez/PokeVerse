-- Josh Pillberg: the shop module sells his EV and breeding items; his vitamin reset moved to the Store.
local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)
function onCreatureAppear(cid) npcHandler:onCreatureAppear(cid) end
function onCreatureDisappear(cid) npcHandler:onCreatureDisappear(cid) end
function onCreatureSay(cid, type, msg)    npcHandler:onCreatureSay(cid, type, msg)      end
function onThink() npcHandler:onThink() end


npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, function(cid, type, msg)
    if(not npcHandler:isFocused(cid)) then
		return false
	end

    if (msgcontains(msg, 'reset') or msgcontains(msg, 'vitamin') or msgcontains(msg, 'resetar') or msgcontains(msg, 'vitamina')) then
        selfSay("Vitamin resets are in the Store now: press the Store button on the top bar, then Services.", cid)

    else
        selfSay("I {trade} items for EV training and breeding.", cid)
    end
	return true
end)

npcHandler:addModule(FocusModule:new())
