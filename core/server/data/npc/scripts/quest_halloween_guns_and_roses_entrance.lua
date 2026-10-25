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
    if (msgcontains(msg, 'bosses') or msgcontains(msg, 'chefes') or msgcontains(msg, 'entrar')) then
        selfSay("If you want to talk to Javy Dones, I can take you to {Roses}, now if you're interested in talking to Barba Roja, I'll take you to the {Guns}.", cid)
    elseif (msgcontains(msg, 'roses')) then
        if (HalloweenEvent.tryEnterShip(cid, 8695, { x = 5825, y = 218, z = 6 })) then
            selfSay("Ok!", cid)
        else
            selfSay("You are not allowed to enter this ship!", cid)
        end
    elseif (msgcontains(msg, 'guns')) then
        if (HalloweenEvent.tryEnterShip(cid, 8695, { x = 5749, y = 123, z = 6 })) then
            selfSay("Ok!", cid)
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
