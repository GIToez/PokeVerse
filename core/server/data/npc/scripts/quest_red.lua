setCreatureIcon(getNpcId(), CREATURE_ICONS.QUEST)

local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)

function onCreatureAppear(cid) npcHandler:onCreatureAppear(cid) end

function onCreatureDisappear(cid) npcHandler:onCreatureDisappear(cid) end

function onCreatureSay(cid, type, msg) npcHandler:onCreatureSay(cid, type, msg) end

function onThink() npcHandler:onThink() end

function sayStory(...) return npcHandler:sayStory(...) end

local FIRST_POKEMON_STORAGE = 8506
local FIRSTY_CITY_STORAGE = 8507

local starterTowns = { "pallet", "viridian", "pewter", "cerulean", "saffron", "celadon", "vermilion", "fuchsia" }
local inverseStarterTowns = table.inverse(starterTowns)

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, function(cid, type, msg)
    if (not npcHandler:isFocused(cid)) then
        return false
    end

    local talkUser = NPCHANDLER_CONVBEHAVIOR == CONVERSATION_DEFAULT and 0 or cid

    if (--getCreatureStorage(cid, FIRSTY_CITY_STORAGE) ~= QUEST_STATUS.FINISHED and
            getCreatureStorage(cid, FIRST_POKEMON_STORAGE) == QUEST_STATUS.FINISHED) then
        msg = string.lower(msg):gsub("%s+town$", "")
        if (inverseStarterTowns[msg]) then
            local townId = getTownId(msg)
            doPlayerSetTown(cid, townId)
            if (msg == "pallet") then
                selfSay("Good choice! Here you go! Go see Professor Oak in his lab, he has some missions that will teach you the basics.", cid)
            else
                selfSay("Here you go! Good luck! Remember that Pallet is always open to trainers that want to help!", cid)
            end
            doCreatureSetStorage(cid, FIRSTY_CITY_STORAGE, QUEST_STATUS.FINISHED)
            doTeleportThing(cid, getTownTemplePosition(townId), false)
            doPlayerPopupFYI(cid, string.format(__L(cid, 'You are now in %s! Try to walk around and talk with NPCs to start out quests!\nSimple speak out "Hi" and "Quest".'), msg))
            doSendPlayerExtendedOpcode(cid, EXTENDED_IDS.GAMEPLAY_TUTORIAL_IMAGE, "") -- Hide
            doSendPlayerExtendedOpcode(cid, EXTENDED_IDS.GAMEPLAY_TUTORIAL_TEXT, "") -- Hide

        else
            selfSay("Now, which city do you want to start in? If you're new, I recommend {Pallet}: Professor Oak and his assistants have missions there that teach you fishing, Headbutt and more.", cid)
            selfSay("You can also pick {Viridian}, {Pewter}, {Cerulean}, {Saffron}, {Celadon}, {Vermilion} or {Fuchsia}.", cid)
        end
    end

    return true
end)

npcHandler:setCallback(CALLBACK_GREET, function(cid)
    doSendPlayerExtendedOpcode(cid, EXTENDED_IDS.GAMEPLAY_TUTORIAL_TEXT, "") -- Hide
    doSendPlayerExtendedOpcode(cid, EXTENDED_IDS.GAMEPLAY_TUTORIAL_IMAGE, "") -- hide
    return true
end)

npcHandler:addModule(FocusModule:new())
