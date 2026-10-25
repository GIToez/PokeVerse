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

local SHOP = "easter_ralp"
local TALK_STATES = {
    NONE = 0,
    DEPOSIT = 1,
    HOW_MUCH_BALLS = 2,
    EXCHANGE_CONFIRM = 3
}
local TALKSTATE_NONE = 0
local TALKSTATE_EXCHANGING = 100

local function addEggs(cid, yellow, red, blue, green, purple)
    setGlobalStorageValue(1000, getGlobalStorageValue(1000) + yellow)
    setGlobalStorageValue(1001, getGlobalStorageValue(1001) + red)
    setGlobalStorageValue(1002, getGlobalStorageValue(1002) + blue)
    setGlobalStorageValue(1003, getGlobalStorageValue(1003) + green)
    setGlobalStorageValue(1004, getGlobalStorageValue(1004) + purple)
    setPlayerDeliveredEasterEggs(cid, getPlayerDeliveredEasterEggs(cid) + yellow + red + blue + green + purple)
end

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

    if (msgcontains(msg, 'egg') or msgcontains(msg, 'colored') or msgcontains(msg, 'ovo') or msgcontains(msg, 'colorido')) then
        selfSay("We are not collecting eggs anymore! Thank you!", cid)
--		talkState[talkUser] = TALK_STATES.DEPOSIT
--		selfSay("You found some colored egg?", cid)

    elseif ((msgcontains(msg, 'yes') or msgcontains(msg, 'sim')) and talkState[talkUser] == TALK_STATES.DEPOSIT) then
        local yellowEgg, redEgg, blueEgg, greenEgg, purpleEgg = getPlayerItemCount(cid, 6541), getPlayerItemCount(cid, 6542), getPlayerItemCount(cid, 6543), getPlayerItemCount(cid, 6544), getPlayerItemCount(cid, 6545)

        if (yellowEgg > 0 or redEgg > 0 or blueEgg > 0 or greenEgg > 0 or purpleEgg > 0) then
            doPlayerRemoveItem(cid, 6541, yellowEgg)
            doPlayerRemoveItem(cid, 6542, redEgg)
            doPlayerRemoveItem(cid, 6543, blueEgg)
            doPlayerRemoveItem(cid, 6544, greenEgg)
            doPlayerRemoveItem(cid, 6545, purpleEgg)
            addEggs(cid, yellowEgg, redEgg, blueEgg, greenEgg, purpleEgg)
            selfSay("Thanks! But do not stop looking, there are still missing eggs.", cid)

        else
            selfSay("No, you have no colored egg.", cid)
        end

        talkState[talkUser] = TALK_STATES.NONE

    elseif (offer) then
        lastOption[talkUser] = offer.id
        talkState[talkUser] = TALKSTATE_EXCHANGING
        selfSay(string.format(__L(cid, "You want to exchange %s golden easter egg for a %s?"), offer.price, offer.name), cid)

    elseif (msgcontains(msg, 'golden easter') or msgcontains(msg, 'easter') or msgcontains(msg, 'trade')) then
        selfSay("Here you can exchange golden easter eggs into gifts, you can see the {options}.", cid)

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
        talkState[talkUser] = TALK_STATES.NONE
        selfSay("Ok...", cid)
    end

    return true
end

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new())
