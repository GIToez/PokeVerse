setCreatureIcon(getNpcId(), CREATURE_ICONS.QUEST)

local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)

function onCreatureAppear(cid) npcHandler:onCreatureAppear(cid) end
function onCreatureDisappear(cid) npcHandler:onCreatureDisappear(cid) end
function onCreatureSay(cid, type, msg) npcHandler:onCreatureSay(cid, type, msg) end
function onThink() npcHandler:onThink() end
function sayStory(...) return npcHandler:sayStory(...) end

local TALKSTATES = {}
TALKSTATES.NONE = 0
TALKSTATES.HEAR_STORY = 10 -- Higher to not conflict with quest system talk state

keywordHandler:addKeyword(
    {'yes', 'sim'},
    function(cid, message, keywords, parameters, node)
        if (not npcHandler:isFocused(cid) or npcHandler.talkState[cid] ~= TALKSTATES.HEAR_STORY) then
            return false
        end

        npcHandler:sayStory(string.createStory(__L(cid, "Once there were three kings who ruled small tribes that were always hidden. These tribes secretly helped each other to keep balance in the Islands. One day an evil being sought to awaken an ancient guardian of the seas to bring chaos to the archipelago, and for that he needed the mystical artifacts of the three legendary birds. Knowing his plan, the three kings went after the villain and sealed him and his household inside a Stone using psychic powers. Sadly, the three kings perished from exhaustion after using so much energy. This is the story I know, and I've been seeking the {location of prophecy} ever since.")), cid)
        npcHandler.talkState[cid] = TALKSTATES.NONE

        return true
    end,
    {})

keywordHandler:addKeyword(
    {'elder', 'sabio', 'sábio'},
    function(cid, message, keywords, parameters, node)
        if (not npcHandler:isFocused(cid)) then
            return false
        end

        selfSay("I know! An old Slowking lives as a hermit on the Shamouti Island. Try to communicate with him and maybe he has the answer!", cid)

        return true
    end,
    {})

keywordHandler:addKeyword(
    {'.*'},
    function(cid, message, keywords, parameters, node)
        if (not npcHandler:isFocused(cid)) then
            return false
        end

        npcHandler.talkState[cid] = doQuestTalk(cid, "Adventurer Lucy", message, npcHandler.talkState[cid])

        return true
    end,
    {})

npcHandler:setCallback(CALLBACK_GREET, function(cid)
    if (getCreatureStorage(cid, 8229) ~= QUEST_STATUS.FINISHED) then -- Orange Archipelago Main #3 completed?
        selfSay("Excuse me, I'm busy now!", cid)
        return false
    end

    local status = getCreatureStorage(cid, 8240)
    if (status == QUEST_STATUS.UNSTARTED and not getQuestGreetHint(cid, "Adventurer Lucy")) then
        npcHandler:setMessage(MESSAGE_GREET, "Hello |PLAYERNAME|! Forgive the mess, I've been reading old maps of the islands all night.")

    elseif (status == QUEST_STATUS.UNSTARTED) then
        npcHandler:setMessage(MESSAGE_GREET, "Hello |PLAYERNAME|, do you want to hear a good story? {Yes} or {No}")
        npcHandler.talkState[cid] = TALKSTATES.HEAR_STORY

    elseif (status == QUEST_STATUS.STARTED) then
        npcHandler:setMessage(MESSAGE_GREET, "Hey, how are you doing? Any news about the {prophecy}?")

    else
        npcHandler:setMessage(MESSAGE_GREET, "Hey! Did you find the {elder}?")
    end
	return true
end)

-- her greetings already lead into her quest
npcHandler.questHint = false

npcHandler:addModule(FocusModule:new())
