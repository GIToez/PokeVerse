local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)
local talkState = {}
local tmSlot = {}
local tmSlotChange = {}
local tmMoveChange = {}

local TALKSTATE_TM_SLOT = 1
local TALKSTATE_CONFIRM = 2
local TALKSTATE_TM_SLOT_CHANGE = 3
local TALKSTATE_MOVE_CHANGE = 4
local TALKSTATE_CONFIRM_CHANGE = 5

function onCreatureAppear(cid) npcHandler:onCreatureAppear(cid) end
function onCreatureDisappear(cid) npcHandler:onCreatureDisappear(cid) end
function onCreatureSay(cid, type, msg)    npcHandler:onCreatureSay(cid, type, msg)      end
function onThink() npcHandler:onThink() end

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, function(cid, type, msg)
    if(not npcHandler:isFocused(cid)) then
		return false
	end

	local talkUser = NPCHANDLER_CONVBEHAVIOR == CONVERSATION_DEFAULT and 0 or cid

    if (msgcontains(msg, 'remove') or msgcontains(msg, 'remover')) then
        selfSay("So, what TM slot do you want to remove? {1} or {2}.", cid)
        talkState[talkUser] = TALKSTATE_TM_SLOT

    elseif (msgcontains(msg, 'change') or msgcontains(msg, 'mover') or msgcontains(msg, 'alterar')) then
        selfSay("Yes, I can restore the move your Pokemon forgot when it learned a TM move. Which TM slot do you want to change? {1} or {2}.", cid)
        talkState[talkUser] = TALKSTATE_TM_SLOT_CHANGE

    elseif (talkState[talkUser] == TALKSTATE_TM_SLOT) then
        if (msg ~= "1" and msg ~= "2") then
            selfSay("I didn't understand. What TM slot do you want to remove? {1} or {2}.", cid)

        else
            local ball = getPlayerBall(cid)
            if (not isItem(ball)) then
                selfSay("Please put a poke ball in your ball slot first.", cid)
                talkState[talkUser] = 0

            else
                local slot = msg == "1" and 1 or 2
                if (getBallTm(ball.uid, slot) == TM_IDS.NONE) then
                    selfSay("Your Pokemon doesn't have a TM in that slot.", cid)
                    talkState[talkUser] = 0

                else
                    selfSay(string.format(__L(cid, "Do you really want to remove the move %s from your %s?"), getTmMove(getBallTm(ball.uid, slot)), getBallPokemonName(ball.uid)), cid)

                    talkState[talkUser] = TALKSTATE_CONFIRM
                    tmSlot[talkUser] = slot

                    if (not getTmUnique(getBallTm(ball.uid, tmSlot[talkUser]))) then
                        doPlayerPopupFYI(cid, "WARNING: You are about to remove a not unique TM! If you remove it, you will not receive the TM again!")
                    end
                end
            end
        end

    elseif (talkState[talkUser] == TALKSTATE_TM_SLOT_CHANGE) then
        if (msg ~= "1" and msg ~= "2") then
            selfSay("I didn't understand. What TM slot do you want to change? {1} or {2}.", cid)

        else
            local ball = getPlayerBall(cid)
            if (not isItem(ball)) then
                selfSay("Please put a poke ball in your ball slot first.", cid)
                talkState[talkUser] = 0

            else
                local slot = msg == "1" and 1 or 2
                if (getBallTm(ball.uid, slot) == TM_IDS.NONE) then
                    selfSay("Your Pokemon doesn't have a TM in that slot.", cid)
                    talkState[talkUser] = 0

                else
                    selfSay("Ok, now which of your Pokemon's moves do you want to replace with that TM? Type the name exactly!", cid)

                    talkState[talkUser] = TALKSTATE_MOVE_CHANGE
                    tmSlotChange[talkUser] = slot
                end
            end
        end

    elseif (talkState[talkUser] == TALKSTATE_MOVE_CHANGE) then
        local ball = getPlayerBall(cid)
        if (not isItem(ball)) then
            selfSay("Please put a poke ball in your ball slot first.", cid)
            talkState[talkUser] = 0

        else
            local moves = getPokemonSkills(getBallPokemonName(ball.uid), ball.uid)
            local moveSlot = table.find(moves, msg)
            if (not moveSlot) then
                selfSay("Your Pokemon hasn't learned that move, please try again. Remember to type its name exactly!", cid)
                return true
            end

            selfSay(string.format(__L(cid, "Do you really want to move the TM %s from your %s to replace the move %s?"), getTmMove(getBallTm(ball.uid, tmSlotChange[talkUser])), getBallPokemonName(ball.uid), moves[moveSlot]), cid)

            talkState[talkUser] = TALKSTATE_CONFIRM_CHANGE
            tmMoveChange[talkUser] = moveSlot
        end

    elseif (talkState[talkUser] == TALKSTATE_CONFIRM) then
        if (msgcontains(msg, 'yes') or msgcontains(msg, 'sim')) then
            local ball = getPlayerBall(cid)
            if (not isItem(ball)) then
                selfSay("Please put a poke ball in your ball slot first.", cid)

            else
                if (getItemUniqueOwner(ball.uid) ~= ITEM_UNIQUE_OWNER_NONE and
                        getItemUniqueOwner(ball.uid) ~= getPlayerGUID(cid)) then
                    selfSay("You aren't the owner of this item.", cid)

                elseif (getBallTm(ball.uid, tmSlot[talkUser]) == TM_IDS.NONE) then
                    selfSay("Your Pokemon doesn't have a TM in that slot.", cid)

                else
                    if (getTmUnique(getBallTm(ball.uid, tmSlot[talkUser]))) then
                        doPlayerSafeAddItem(cid, getTmItemId(getBallTm(ball.uid, tmSlot[talkUser])),
                            1, true, true)
                    end

                    selfSay(__L(cid, "Done!"), cid)
                    setBallTm(ball.uid, tmSlot[talkUser], nil, TM_IDS.NONE)
                    setBallUniqueFromTmSlot(ball.uid, tmSlot[talkUser], false)
                    doBallUpdateDescription(ball.uid)
                    doPlayerUpdatePokemonMoves(cid, ball.uid)

                    if (getBallUniqueFromTm(ball.uid)) then
                        local tmpSlot = (tmSlot[talkUser] == 1 and 2 or 1)
                        local tmpTm = getBallTm(ball.uid, tmpSlot)
                        if (tmpTm == TM_IDS.NONE or not (getBallUniqueFromTmSlot(ball.uid, tmpSlot) or
                                getTmUnique(tmpTm))) then -- We can't remove the unique if the other TM is unique too
                            doItemEraseUniqueOwner(ball.uid)
                        end
                    end
                end
            end

        else
            selfSay("Ok buddy.", cid)
        end

        talkState[talkUser] = 0
        tmSlot[talkUser] = nil

    elseif (talkState[talkUser] == TALKSTATE_CONFIRM_CHANGE) then
        if (msgcontains(msg, 'yes') or msgcontains(msg, 'sim')) then
            local ball = getPlayerBall(cid)
            if (not isItem(ball)) then
                selfSay("Please put a poke ball in your ball slot first.", cid)

            else
                if (getBallTm(ball.uid, tmSlotChange[talkUser]) == TM_IDS.NONE) then
                    selfSay("Your Pokemon doesn't have a TM in that slot.", cid)

                elseif (not canTmReplaceMove(getPokemonSkills(getBallPokemonName(ball.uid), ball.uid)[tmMoveChange[talkUser]],
                    getBallTm(ball.uid, tmSlotChange[talkUser]), ball)) then
                    selfSay("That is not possible!", cid)

                else

                    selfSay(__L(cid, "Done!"), cid)

                    setBallTm(ball.uid, tmSlotChange[talkUser], tmMoveChange[talkUser],
                        getBallTm(ball.uid, tmSlotChange[talkUser]))
                    doBallUpdateDescription(ball.uid)
                    doPlayerUpdatePokemonMoves(cid, ball.uid)
                end
            end

        else
            selfSay("Ok buddy.", cid)
        end

        talkState[talkUser] = 0
        tmSlotChange[talkUser] = nil
        tmMoveChange[talkUser] = nil

    else
        selfSay("Here you can {remove} and {change} TM moves that you taught your Pokemon!", cid)
    end
	return true
end)

npcHandler:addModule(FocusModule:new())
