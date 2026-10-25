setCreatureIcon(getNpcId(), CREATURE_ICONS.QUEST)

local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)
local talkState = {}
local lastOption = {}
local lastCount = {}

function onCreatureAppear(cid) npcHandler:onCreatureAppear(cid) end
function onCreatureDisappear(cid) npcHandler:onCreatureDisappear(cid) end
function onCreatureSay(cid, type, msg) npcHandler:onCreatureSay(cid, type, msg) end
function onThink() npcHandler:onThink() end

local SHOP = "anniversary_letters"
local TALKSTATE_NONE = 0
local TALKSTATE_COUNT = 150
local TALKSTATE_EXCHANGING = 100

local function openShop(cid)
    if (EventShop.open(cid, SHOP, getNpcId())) then
        selfSay("Hand me the letters you want to turn in.", cid)
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
        talkState[talkUser] = TALKSTATE_COUNT
        selfSay("And how many letters do you want to exchange?", cid)

    elseif (msgcontains(msg, 'gift') or msgcontains(msg, 'presente') or msgcontains(msg, 'letter') or
            msgcontains(msg, 'letra') or msgcontains(msg, 'token') or msgcontains(msg, 'trade')) then
        selfSay("Here you can exchange the letters for anniversary tokens, you can see the {options}.", cid)

    elseif (talkState[talkUser] == TALKSTATE_COUNT) then
        local count = string.extractNumber(msg)
        if (count <= 0) then
            selfSay("And how many letters do you want to exchange?", cid)
            return true
        end
        local opt = EventShop.findOffer(SHOP, lastOption[talkUser])
        lastCount[talkUser] = count
        talkState[talkUser] = TALKSTATE_EXCHANGING
        selfSay(string.format(__L(cid, "You want to exchange %s %s for %s anniversary token(s)? {Yes} or {No}"),
            count, opt.name, count * opt.price), cid)

    elseif (msgcontains(msg, 'option') or msgcontains(msg, 'opcoes')) then
        openShop(cid)

    elseif ((msgcontains(msg, 'yes') or msgcontains(msg, 'sim')) and talkState[talkUser] == TALKSTATE_EXCHANGING and
            lastOption[talkUser]) then
        local ok, text = EventShop.exchange(cid, SHOP, lastOption[talkUser], lastCount[talkUser])
        selfSay(text, cid)
        talkState[talkUser] = TALKSTATE_NONE
        lastCount[talkUser] = nil

    elseif (msgcontains(msg, 'no') or msgcontains(msg, 'nao')) then
        selfSay("Ok.", cid)
        talkState[talkUser] = TALKSTATE_NONE
        lastCount[talkUser] = nil

    else
        talkState[talkUser] = TALKSTATE_NONE
        lastCount[talkUser] = nil
        selfSay("Ok...", cid)
    end
    return true
end

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new())
