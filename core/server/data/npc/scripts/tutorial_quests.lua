local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)

--
setCreatureIcon(getNpcId(), CREATURE_ICONS.QUEST)

local battleNpcName = "Flanagan"
local flanaganBattle = NpcBattle:new(battleNpcName, 9287, 9687, npcHandler)
flanaganBattle:setPokemons({"Poliwag"})
flanaganBattle:setOneWin(true)
flanaganBattle:setDifficulty(5)
flanaganBattle:setRequired(function(cid) return getCreatureStorage(cid, 8492) == QUEST_STATUS.STARTED end)
flanaganBattle:setOnEnd(
    function(cid)
        flanaganBattle:setPlayerLastBattleTimeWithNpc(cid, 0) -- Prevent waiting time if loss

        if (not isPokemonOnline(cid)) then
            for _, ball in pairs(getPlayerAllBallsWithPokemon(cid)) do
                doBallHeal(cid, ball) -- Heal the Pokemon if the player lose
            end
        end
    end
)

local function doExitPlayer(cid)
    if (isPokemonOnline(cid)) then -- Try to call Pokemon back
        doPlayerUseBallOnSlot(cid)
    end

    if (isPokemonOnline(cid) or getPlayerMounted(cid) or isEvolving(cid)) then
        selfSay("You can't do that while you have a Pokemon out of its ball.", cid)
        return
    end

    for _, item in pairs(getPlayerAllBallsWithPokemon(cid)) do
        doRemoveItem(item.uid)
    end

    local destination = {x = 3337, y = 812, z = 6}
    doTeleportThing(cid, destination)
    doSendMagicEffect(destination, EFFECT_TELEPORT)
    doPlayerSetTown(cid, 32) -- Pallet
end

local TALKSTATE_SKIP = 400

local function doHandleSkip(cid, msg)
    if (msgcontains(msg, 'skip') or msgcontains(msg, 'pular')) then
        npcHandler.talkState[cid] = TALKSTATE_SKIP
        selfSay("Do you really want to skip the tutorial? {Yes} or {No}", cid)
        return true

    elseif (npcHandler.talkState[cid] == TALKSTATE_SKIP) then
        if (msgcontains(msg, 'yes') or msgcontains(msg, 'sim')) then
            selfSay("Here you go!", cid)
            doExitPlayer(cid)
        else
            selfSay("Ok, so let's move on.", cid)
        end

        npcHandler.talkState[cid] = nil
        return true
    end

    return false
end

local NPCS = {}

-- First NPC
NPCS["Biff"] = function(cid, type, msg)
    if (msgcontains(msg, 'continue') or msgcontains(msg, 'continuar')) then
        if (getPlayerUsingOtClient(cid)) then
            selfSay("Okay, that's a start. All quest NPCs are marked by a balloon with an exclamation mark (!). Now on to our first mission. Remember that you can {SKIP} this tutorial whenever you want. Shall we start your first mission? Just say {YES}.", cid)
        else
            selfSay("Okay, that's a start. Now on to our first mission. Remember that you can {SKIP} this tutorial whenever you want. Shall we start your first mission? Just say {YES}.", cid)
        end

    elseif (msgcontains(msg, 'yes') or msgcontains(msg, 'sim')) then
        selfSay("Go to that door and \"Use\" it to open it. You can Shift + Click to open the context menu and click \"Use\", or select the \"Classic Control\" option in the menu to simply use the right mouse button. Once it's open, speak with the second NPC, Flanagan.", cid)
        doPlayerSendTip(cid, TIP_IDS.OPEN_DOOR)

    else
        selfSay("Some dialogues contain blue words; just say them back to {CONTINUE} the dialogue.", cid)
    end
end

-- Daycare Helper
NPCS["Carlton"] = function(cid, type, msg)
    if (msgcontains(msg, 'daycare')) then
        npcHandler:sayStory(string.createStory("The Pokemon Daycare is a place where you can leave your Pokemon to gain experience without having it in your current team. It was designed for trainers who don't have much time or want to train Pokemon besides the six they carry. You can leave two Pokemon in the Daycare, which gives the system a second use: if a trainer leaves a compatible male and female Pokemon at the Daycare, they may produce a Pokemon Egg. If you get an Egg, you must hatch it. Once it hatches you will have a very good Pokemon in your hands. To learn more, ask other players, the Help channel or the Wiki tab of the Pokepedia (press M). Good luck trainer!"), cid)

    else
        selfSay("Do you know about the {POKEMON DAYCARE}?", cid)
    end
end

-- Pokemon Helper
NPCS["Cletis"] = function(cid, type, msg)
    if (msgcontains(msg, 'tm')) then
        npcHandler:sayStory(string.createStory("A TM (Technical Machine) can teach your Pokemon a move it can't normally learn. Just find a TM like this one beside me and use it on your Pokemon's Poke Ball. Then choose which move the TM move will replace. Remember that PokeVerse follows the official data of the Pokemon universe, so this system has some rules too."), cid)

    elseif (msgcontains(msg, 'vitamin') or msgcontains(msg, 'vitamina')) then
        npcHandler:sayStory(string.createStory("Vitamins are designed to increase the Stats of your Pokemon. The Stats are: HP, Attack, Defense, Special Attack, Special Defense and Speed. Each Pokemon has a limit on how much a Stat can be raised by vitamins: 10 vitamins in total and 3 of each kind. To learn more, visit the Help channel or the Wiki tab of the Pokepedia (press M)."), cid)

    else
        selfSay("Do you know about {TMS} or {VITAMINS}?", cid)
    end
end

-- Berry Helper
NPCS["Tracy"] = function(cid, type, msg)
    if (msgcontains(msg, 'berries')) then
        npcHandler:sayStory(string.createStory("Berries are plants that any trainer can grow at home. There are different species with different effects. There is a cooldown between each use, even in tournament battles! To plant a Berry, you need tools like the ones behind me, used on fertile land, usually found in homes or rented places. You can find these spots around the PokeVerse world. The tools are sold by shop NPCs in the cities."), cid)

    else
        selfSay("Looking to know about {BERRIES}?", cid)
    end
end

-- Ranger Helper
NPCS["Gray"] = function(cid, type, msg)
    if (msgcontains(msg, 'frontier')) then
        npcHandler:sayStory(string.createStory("The Frontier Island gives trainers the chance to test their skill as a Pokemon Master with some challenges. It can be reached directly from the Union Room, and it's a place to visit with friends. There you can earn Frontier Tokens, which let you buy some unique items on the island."), cid)

    elseif (msgcontains(msg, 'ranger')) then
        npcHandler:sayStory(string.createStory("The Ranger Club is a place for trainers who seek adventure. At the Ranger Club you will have the chance to advance in Ranks and become a successful Ranger. There are several missions that give you points to move up in ranks. Each mission gives you rewards and the chance to face a Pokemon Boss. What are you waiting for? Each city has a representative of the Ranger Club!"), cid)

    else
        selfSay("Do you want to hear about the {FRONTIER ISLAND} or the {RANGER CLUB}?", cid)
    end
end

-- Soul Coin Trader
NPCS["Jimi"] = function(cid, type, msg)
    if (msgcontains(msg, 'soul')) then
        npcHandler:sayStory(string.createStory("These are the game's virtual currency. With them you can get a Premium Account, which gives access to various locations on the map and full use of your Pokemon. They are not required to play, but if you want the full experience be sure to get some. You can buy them from other players or by donating to the project through the official site. It's a symbolic way to keep PokeVerse online for your enjoyment. They have several uses, so to see more details read the Wiki tab of the Pokepedia (press M) or ask in the Help channel."), cid)

    else
        selfSay("Do you know what a {SOUL COIN} is?", cid)
    end
end

-- End
NPCS["Oak's Assistant Brenny"] = function(cid, type, msg)
    if (msgcontains(msg, 'yes') or msgcontains(msg, 'sim')) then
        npcHandler:sayStory(string.createStory("Now I will take you to the laboratory of one of the greatest Pokemon researchers who have walked this land. There he will teach you how to do different things and you can also receive your first Pokemon. Remember that you are very vulnerable without a Pokemon, so do the QUEST to start your journey on the right foot. When you're {READY} I'll take you to his lab, it won't take long. Just close your eyes..."), cid)

    elseif (msgcontains(msg, 'ready') or msgcontains(msg, 'pronto')) then
        selfSay("There you go! Good luck!", cid)
        doExitPlayer(cid)

    else
        selfSay("That's fine.", cid)
    end
end
--

function onCreatureAppear(cid) npcHandler:onCreatureAppear(cid) end
function onCreatureDisappear(cid) npcHandler:onCreatureDisappear(cid) end
function onCreatureSay(cid, type, msg) npcHandler:onCreatureSay(cid, type, msg) end
function onThink() npcHandler:onThink() end

function creatureSayCallback(cid, type, msg)
	if(not npcHandler:isFocused(cid)) then
		return false
	end

	local talkUser = NPCHANDLER_CONVBEHAVIOR == CONVERSATION_DEFAULT and 0 or cid

    if (doHandleSkip(cid, msg)) then
        return true
    end

    local npcName = getNpcName()

    if (npcName == battleNpcName and getCreatureStorage(cid, 8492) == QUEST_STATUS.STARTED and
            not getPlayerDefeatedNPC(cid, battleNpcName)) then
        if (msgcontains(msg, 'battle') or msgcontains(msg, 'batalha')) then
            npcHandler.talkState[talkUser] =  flanaganBattle:doTalkStart(getNpcId(), cid)

        elseif (msgcontains(msg, 'yes') or msgcontains(msg, 'sim')) then
            npcHandler.talkState[talkUser] =  flanaganBattle:doTalkEnd(getNpcId(), cid,
                npcHandler.talkState[talkUser])

        else
            selfSay("Do you mean {BATTLE}?", cid)
        end

        return true
    end

    if (getNpcQuests(npcName)) then
        npcHandler.talkState[talkUser] = doQuestTalk(cid, npcName, msg, npcHandler.talkState[talkUser])
        return true
    end

    if (NPCS[npcName]) then
        NPCS[npcName](cid, type, msg)
    end

	return true
end

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
-- the old Tutorial Island chain (Quests.RETIRED_NPCS) has no quest marks or hints
npcHandler.questHint = false

npcHandler:addModule(FocusModule:new())
