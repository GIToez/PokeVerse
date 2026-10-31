-- Tiger Kelsey, the PokeTrader. He asks if you're here for the auction; "auction" (or "yes") opens the auction window
-- (PokeTrader in lib/ps/systems/105-pokeTrader.lua). The chat words work too, with the same rules, for clients
-- without the window: offers, bids, time, cancel, and "<item> <amount>" to set a maximum.
local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)

function onCreatureAppear(cid) npcHandler:onCreatureAppear(cid) end
function onCreatureDisappear(cid) npcHandler:onCreatureDisappear(cid) end
function onCreatureSay(cid, type, msg) npcHandler:onCreatureSay(cid, type, msg) end
function onThink()
    npcHandler:onThink()
    PokeTrader.tick(getNpcId())
end

local TALKSTATE_AMOUNT = 1
local TALKSTATE_CONFIRM = 2
local TALKSTATE_CANCEL = 3

local lastLot, lastAmount = {}, {}

local function dollars(amount)
    local text, formatted = tostring(math.floor(amount))
    repeat
        text, formatted = text:gsub("^(-?%d+)(%d%d%d)", "%1,%2")
    until formatted == 0
    return "$" .. text
end

-- "40,000", "40.000" and "40000" are all 40000; nil without a number
local function amountIn(msg)
    local digits = msg:gsub("(%d)[,.](%d%d%d)", "%1%2"):match("%d+")
    return digits and tonumber(digits) or nil
end

local function reset(cid)
    npcHandler.talkState[cid] = nil
    lastLot[cid], lastAmount[cid] = nil, nil
end

local function showOffers(cid)
    local lines = PokeTrader.describe(cid)
    if (#lines == 0) then
        selfSay("Err, I have nothing up for auction right now. Come back soon!", cid)
        return
    end
    selfSay("Mmm... let me see, here they are! Say an item and the most you'd pay, like {" ..
        getItemNameById(PokeTrader.lots()[1].itemId) .. " 30000}.", cid)
    doPlayerPopupFYI(cid, table.concat(lines, "\n"))
end

local function askConfirm(cid, lot, amount)
    lastLot[cid], lastAmount[cid] = lot, amount
    npcHandler.talkState[cid] = TALKSTATE_CONFIRM
    selfSay(string.format(__L(cid, "The most you'd pay for the %s is %s? I only bid what it takes to keep you on top. {Yes}?"),
        getItemNameById(lot.itemId), dollars(amount)), cid)
end

local function openAuction(cid)
    if (not PokeTrader.open(cid, getNpcId())) then
        showOffers(cid)
    else
        selfSay("Here's this week's auction. Take a look!", cid)
    end
    reset(cid)
end

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, function(cid, type, msg)
    if (not npcHandler:isFocused(cid)) then
        return false
    end
    msg = string.lower(msg)
    local state = npcHandler.talkState[cid]

    if (state == TALKSTATE_CONFIRM) then
        if (msgcontains(msg, 'yes') or msgcontains(msg, 'sim')) then
            local _, text = PokeTrader.setMax(cid, lastLot[cid].id, lastAmount[cid])
            selfSay(text, cid)
        else
            selfSay("Why not?! ... ... ... Ok, ok, it's fine.", cid)
        end
        reset(cid)

    elseif (state == TALKSTATE_AMOUNT and amountIn(msg)) then
        askConfirm(cid, lastLot[cid], amountIn(msg))

    elseif (state == TALKSTATE_CANCEL) then
        local lot = PokeTrader.findLot(msg)
        if (lot) then
            local _, text = PokeTrader.takeBack(cid, lot.id)
            selfSay(text, cid)
        else
            selfSay("Ya ya? I don't have that up for auction.", cid)
        end
        reset(cid)

    elseif (msgcontains(msg, 'auction') or msgcontains(msg, 'leilao') or msgcontains(msg, 'yes')
            or msgcontains(msg, 'sim')) then
        openAuction(cid)

    elseif (msgcontains(msg, 'offer') or msgcontains(msg, 'oferta')) then
        showOffers(cid)

    elseif (msgcontains(msg, 'cancel') or msgcontains(msg, 'cancelar')) then
        npcHandler.talkState[cid] = TALKSTATE_CANCEL
        selfSay("I see, which item do you want to take your bid back from?", cid)

    elseif (msgcontains(msg, 'time') or msgcontains(msg, 'tempo')) then
        local left = PokeTrader.timeLeft()
        if (left) then
            selfSay(string.format(__L(cid, "This week's auction ends in %s. No extra time for late bids!"),
                table.concat(string.timediff(left, cid))), cid)
        else
            selfSay("I have nothing up for auction right now.", cid)
        end

    elseif (msgcontains(msg, 'bid') or msgcontains(msg, 'lance')) then
        local mine = PokeTrader.describe(cid, true)
        if (#mine > 0) then
            selfSay("Yes! Here are your bids.", cid)
            doPlayerPopupFYI(cid, table.concat(mine, "\n"))
        else
            selfSay("Argh, you have no bids this week! Take a look at the {auction}.", cid)
        end

    else
        local lot = PokeTrader.findLot(msg)
        local amount = amountIn(msg)
        if (lot and amount) then
            askConfirm(cid, lot, amount)
        elseif (lot) then
            lastLot[cid] = lot
            npcHandler.talkState[cid] = TALKSTATE_AMOUNT
            selfSay(string.format(__L(cid, "The %s! What's the most you'd pay for it?"), getItemNameById(lot.itemId)), cid)
        else
            selfSay("Yaya? Sorry, I can't understand you. Are you here for the {auction}? I can also tell you the {offers}," ..
                " your {bids} and the {time} left.", cid)
        end
    end
    return true
end)
npcHandler:addModule(FocusModule:new())
