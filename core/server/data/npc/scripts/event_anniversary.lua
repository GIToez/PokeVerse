setCreatureIcon(getNpcId(), CREATURE_ICONS.QUEST)

local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)
local talkState = {}
local lastOption = {}

function onCreatureAppear(cid) npcHandler:onCreatureAppear(cid) end
function onCreatureDisappear(cid) npcHandler:onCreatureDisappear(cid) end
function onCreatureSay(cid, type, msg) npcHandler:onCreatureSay(cid, type, msg) end
function onThink() npcHandler:onThink() end

local SHOP = "anniversary_gifts"
local TALKSTATE_NONE = 0
local TALKSTATE_EXCHANGING = 100

local function openShop(cid)
    if (EventShop.open(cid, SHOP, getNpcId())) then
        selfSay("Take a look at the gifts.", cid)
        return true
    end
    doPlayerPopupFYI(cid, EventShop.fyi(SHOP))
    return false
end

function creatureSayCallback(cid, type, msg)
    if (not npcHandler:isFocused(cid)) then
        return false
    end

    local talkUser = NPCHANDLER_CONVBEHAVIOR == CONVERSATION_DEFAULT and 0 or cid
    msg = string.lower(msg)
    local offer = EventShop.findOffer(SHOP, msg)

    if (msgcontains(msg, 'gift') or msgcontains(msg, 'presente') or msgcontains(msg, 'trade')) then
        selfSay("Here you can exchange anniversary tokens for gifts, and the letters P, S, O, U and L for exclusive items. See the {options}.", cid)
        openShop(cid)

    elseif (offer) then
        lastOption[talkUser] = offer.id
        talkState[talkUser] = TALKSTATE_EXCHANGING
        if (offer.costItems) then
            selfSay(string.format(__L(cid, "Do you really want to exchange the letters P, S, O, U and L for a %s? {Yes} or {No}"), offer.name), cid)
        else
            selfSay(string.format(__L(cid, "Do you want to exchange %s anniversary token for a %s? {Yes} or {No}"), offer.price, offer.name), cid)
        end

    elseif (msgcontains(msg, 'anniversary') or msgcontains(msg, 'aniversário')) then
        selfSay("Here you can exchange anniversary tokens for gifts. You can see the {options}.", cid)

    elseif (msgcontains(msg, 'option') or msgcontains(msg, 'opcoes')) then
        openShop(cid)

    elseif ((msgcontains(msg, 'yes') or msgcontains(msg, 'sim')) and talkState[talkUser] == TALKSTATE_EXCHANGING and
            lastOption[talkUser]) then
        local ok, text = EventShop.exchange(cid, SHOP, lastOption[talkUser], 1)
        selfSay(text, cid)
        talkState[talkUser] = TALKSTATE_NONE

    elseif (msgcontains(msg, 'no') or msgcontains(msg, 'nao')) then
        selfSay("Ok.", cid)
        talkState[talkUser] = TALKSTATE_NONE

    else
        talkState[talkUser] = TALKSTATE_NONE
        selfSay("Ok...", cid)
    end
    return true
end

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new())
