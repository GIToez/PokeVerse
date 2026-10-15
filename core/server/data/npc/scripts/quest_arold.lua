setCreatureIcon(getNpcId(), CREATURE_ICONS.QUEST)

local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)

function onCreatureAppear(cid) npcHandler:onCreatureAppear(cid) end
function onCreatureDisappear(cid) npcHandler:onCreatureDisappear(cid) end
function onCreatureSay(cid, type, msg) npcHandler:onCreatureSay(cid, type, msg) end
function onThink() npcHandler:onThink() end

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, function(cid, type, msg)
	if(not npcHandler:isFocused(cid)) then
		return false
	end

    if (msgcontains(msg, 'orange') or msgcontains(msg, 'archipelago') or msgcontains(msg, 'laranja')) then
        selfSay("Ahh! It's a nice place, full of cute {Pokemon}. It's a group of islands... I don't know how many... but they are quite large and full of experienced trainers.", cid)

    elseif (msgcontains(msg, 'pokemon')) then
        selfSay("I like your interest in Pokemon. They come in a huge {variety}, and some I know nothing about. There are many strong ones, especially one called Kingdra. I heard it's a dragon type... does that scare you?", cid)

    elseif (msgcontains(msg, 'variety') or msgcontains(msg, 'variedade')) then
        doCreatureSetStorage(cid, 8340, QUEST_STATUS.FINISHED)
        doCreatureSetStorage(cid, 8341, QUEST_STATUS.STARTED)
        selfSay("You are very curious! Why not ask my friend Juhn about it? While I was doing business on the islands, he visited the most mysterious places... Think about it. Want to buy a trinket? Don't tell anyone. Hehe!", cid)

	else
		selfSay("Hmm?", cid)
	end
	return true
end)

npcHandler:addModule(FocusModule:new())
