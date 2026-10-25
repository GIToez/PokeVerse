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

local SHOP = "july_walter"
local TALKSTATE_NONE = 0
local TALKSTATE_EXCHANGING = 10

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

    if (offer) then
        lastOption[talkUser] = offer.id
        talkState[talkUser] = TALKSTATE_EXCHANGING
        selfSay(string.format(__L(cid, "You want to exchange %s tokens for a %s?"), offer.price, offer.name), cid)

    elseif (msgcontains(msg, 'option') or msgcontains(msg, 'opcoes') or msgcontains(msg, 'trade')
            or msgcontains(msg, 'fragment') or msgcontains(msg, 'gift')) then
        selfSay("Here you can exchange Fragments of The Choosen One into gifts, you can see the {options}.", cid)
        if (msgcontains(msg, 'option') or msgcontains(msg, 'opcoes')) then
            openShop(cid)
        end

    elseif ((msgcontains(msg, 'yes') or msgcontains(msg, 'sim')) and talkState[talkUser] == TALKSTATE_EXCHANGING and
            lastOption[talkUser]) then
        local ok, text = EventShop.exchange(cid, SHOP, lastOption[talkUser], 1)
        selfSay(text, cid)
        talkState[talkUser] = TALKSTATE_NONE

    elseif (msgcontains(msg, 'no') or msgcontains(msg, 'nao')) then
        selfSay("Ho ho ho!", cid)
        talkState[talkUser] = TALKSTATE_NONE

    else
        selfSay("Here you can exchange Fragments of The Choosen One into gifts, you can see the {options}.", cid)
    end

    return true
end

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new())
