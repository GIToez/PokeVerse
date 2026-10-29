-- The Day Care window (lib/ps/systems/072-daycare.lua) does the leaving, training, eggs and plates; the Old Man
-- opens it as soon as he is greeted.
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
    if (msgcontains(string.lower(msg), 'daycare')) then
        if (not Daycare.open(cid)) then
            selfSay("You need the newest client to use the Day Care. Please restart the game to update it.", cid)
        end
    else
        selfSay("Say {daycare} and I'll show you your Pokemon.", cid)
    end
    return true
end

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new())

npcHandler:setCallback(CALLBACK_GREET, function(cid)
    if (npcHandler:isInRange(cid)) then
        local eggMessage = Daycare.onGreet(cid, true)
        if (eggMessage) then
            selfSay(eggMessage, cid)
        end
    end
    return true
end)
