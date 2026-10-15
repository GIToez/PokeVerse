local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)
local talkState = {}
local lastMove = {}

local TALKSTATE_CONFIRM = 1

function onCreatureAppear(cid) npcHandler:onCreatureAppear(cid) end
function onCreatureDisappear(cid) npcHandler:onCreatureDisappear(cid) end
function onCreatureSay(cid, type, msg)    npcHandler:onCreatureSay(cid, type, msg)      end
function onThink() npcHandler:onThink() end


npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, function(cid, type, msg)
    if(not npcHandler:isFocused(cid)) then
		return false
	end

	local talkUser = NPCHANDLER_CONVBEHAVIOR == CONVERSATION_DEFAULT and 0 or cid

    if (msgcontains(msg, 'remove') or msgcontains(msg, 'held') or msgcontains(msg, 'remover')) then
        selfSay("I can {remove} your Pokemon held! Do you want that? Your Pokemon's held item level will be reset if you do that. {Yes} or {No}", cid)
        talkState[talkUser] = TALKSTATE_CONFIRM

    elseif (talkState[talkUser] == TALKSTATE_CONFIRM) then
        if (msgcontains(msg, 'yes') or msgcontains(msg, 'sim')) then
            if (isPokemonOnline(cid) or getPlayerMounted(cid) or isEvolving(cid)) then
                selfSay("You can't do that while your Pokemon is out of its ball.", cid)
                return true
            end

            local ball = getPlayerBall(cid)
            if (not isItem(ball)) then
                selfSay("Please put a Poke Ball in your ball slot first.", cid)

            elseif (not getBallHeld(ball.uid)) then
                selfSay("Your Pokemon doesn't have any held item.", cid)

            else
                doPlayerSafeAddItem(cid, PokemonHeldItem.getHeldItemId(getBallHeld(ball.uid)), 1, true)
                PokemonHeldItem.doResetBall(ball, cid)
                selfSay(__L(cid, "Done!"), cid)
            end

        else
            selfSay("Ok.", cid)
        end

        talkState[talkUser] = 0
        lastMove[talkUser] = nil

    else
        selfSay("I can {remove} your Pokemon Held.", cid)
    end
	return true
end)

npcHandler:addModule(FocusModule:new())
