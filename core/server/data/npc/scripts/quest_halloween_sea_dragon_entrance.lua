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
    if (msgcontains(msg, 'exile') or msgcontains(msg, 'enter') or msgcontains(msg, 'entrar')) then
        if (HalloweenEvent.tryEnterShip(cid, 8694, { x = 5798, y = 168, z = 6 })) then
            selfSay("I can take you in, but only Sotashi decides if you can stay, or not.", cid)
        else
            selfSay("You are not allowed to enter this ship!", cid)
        end
    else
        selfSay("Ok...", cid)
    end
    return true
end

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new())
