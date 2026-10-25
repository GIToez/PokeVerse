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

local SHOP = "christmas_santa"
local TALKSTATE_NONE = 0
local TALKSTATE_EXCHANGING = 10
local firstTmRewardStorage = 8374
local secondTmRewardStorage = 8376

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

    -- First TM Quest
    if (getCreatureStorage(cid, 8373) == QUEST_STATUS.FINISHED and
            getCreatureStorage(cid, firstTmRewardStorage) ~= QUEST_STATUS.FINISHED) then
        local tmItemId = 0
        if (msgcontains(msg, '16')) then
            tmItemId = 17352
        elseif (msgcontains(msg, '23')) then
            tmItemId = 17359
        elseif (msgcontains(msg, '27')) then
            tmItemId = 17363
        elseif (msgcontains(msg, '39')) then
            tmItemId = 17375
        elseif (msgcontains(msg, '46')) then
            tmItemId = 17382
        end

        if (tmItemId == 0) then
            selfSay("What reward you want? Your options are: {TM 16} (Submission), {TM 23} (Thunderbolt), {TM 27} (Psychic), {TM 39} (Dream Eater) and {TM 46} (Tri Attack).", cid)
            return true
        end

        if (doPlayerSafeAddItem(cid, tmItemId, 1, true, true)) then
            doCreatureSetStorage(cid, firstTmRewardStorage, QUEST_STATUS.FINISHED)
            selfSay("Ok, here is!", cid)
        end

        return true
    end

    -- Second TM Quest
    if (getCreatureStorage(cid, 8375) == QUEST_STATUS.FINISHED and
            getCreatureStorage(cid, secondTmRewardStorage) ~= QUEST_STATUS.FINISHED) then
        local tmItemId = 0
        if (msgcontains(msg, '10')) then
            tmItemId = 17346
        elseif (msgcontains(msg, '13')) then
            tmItemId = 17349
        elseif (msgcontains(msg, '21')) then
            tmItemId = 17357
        elseif (msgcontains(msg, '26')) then
            tmItemId = 17362
        elseif (msgcontains(msg, '32')) then
            tmItemId = 17368
        end

        if (tmItemId == 0) then
            selfSay("What reward you want? Your options are: {TM 10} (Double-Edge), {TM 13} (Ice Beam), {TM 21} (Solar Beam), {TM 26} (Fissure) and {TM 32} (Metronome).", cid)
            return true
        end

        if (doPlayerSafeAddItem(cid, tmItemId, 1, true, true)) then
            doCreatureSetStorage(cid, secondTmRewardStorage, QUEST_STATUS.FINISHED)
            selfSay("Ok, here is!", cid)
        end

        return true
    end

    msg = string.lower(msg)
    local offer = EventShop.findOffer(SHOP, msg)

    if (offer) then
        lastOption[talkUser] = offer.id
        talkState[talkUser] = TALKSTATE_EXCHANGING
        selfSay(string.format(__L(cid, "You want to exchange %s christmas tokens for a %s?"), offer.price, offer.name), cid)

    elseif (msgcontains(msg, 'christmas') or msgcontains(msg, 'gift') or msgcontains(msg, 'presente') or
            msgcontains(msg, 'natal') or msgcontains(msg, 'trade')) then
        selfSay("Here you can exchange christmas tokens into christmas gifts, you can see the {options}.", cid)

    elseif (msgcontains(msg, 'option') or msgcontains(msg, 'opcoes')) then
        openShop(cid)

    elseif ((msgcontains(msg, 'yes') or msgcontains(msg, 'sim')) and talkState[talkUser] == TALKSTATE_EXCHANGING and
            lastOption[talkUser]) then
        local ok, text = EventShop.exchange(cid, SHOP, lastOption[talkUser], 1)
        selfSay(text, cid)
        talkState[talkUser] = TALKSTATE_NONE

    elseif (msgcontains(msg, 'no') or msgcontains(msg, 'nao')) then
        selfSay("Ho ho ho!", cid)
        talkState[talkUser] = TALKSTATE_NONE

    else
        npcHandler.talkState[talkUser] = doQuestTalk(cid, "Santa Claus", msg, npcHandler.talkState[talkUser])
    end

    return true
end

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new())
