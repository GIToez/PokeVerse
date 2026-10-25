local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)

function onCreatureAppear(cid) npcHandler:onCreatureAppear(cid) end
function onCreatureDisappear(cid) npcHandler:onCreatureDisappear(cid) end
function onCreatureSay(cid, type, msg) npcHandler:onCreatureSay(cid, type, msg) end
function onThink() npcHandler:onThink() end

function creatureSayCallback(cid, type, msg)
    if (not npcHandler:isFocused(cid)) then
        return false
    end

    msg = string.lower(msg)
    if (msgcontains(msg, 'shore') or msgcontains(msg, 'praia') or msgcontains(msg, 'leave')
            or msgcontains(msg, 'sair') or msgcontains(msg, 'yes') or msgcontains(msg, 'sim')) then
        selfSay("Here you go.", cid)
        doTeleportThing(cid, { x = 4214, y = 330, z = 7 })
    else
        selfSay("Ok...", cid)
    end
    return true
end

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new())
