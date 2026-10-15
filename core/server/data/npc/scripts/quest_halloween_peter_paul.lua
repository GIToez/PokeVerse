setCreatureIcon(getNpcId(), CREATURE_ICONS.QUEST)

local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)

function onCreatureAppear(cid) npcHandler:onCreatureAppear(cid) end

function onCreatureDisappear(cid) npcHandler:onCreatureDisappear(cid) end

function onCreatureSay(cid, type, msg) npcHandler:onCreatureSay(cid, type, msg) end

function onThink() npcHandler:onThink() end

function sayStory(...) return npcHandler:sayStory(...) end

local name = getNpcName()

local WILL_KID_LAST_BATTLE_STORAGE = 9712

local TALK_SEQUENCE_STATE = {}
local TALK_SEQUENCE = {}
TALK_SEQUENCE[#TALK_SEQUENCE + 1] = {
    keywords = { 'sea', 'mar', 'yes', 'sim' },
    onSay = function(cid)
        selfSay("I'm looking for adventurers who can help me with a {problem}! Interested?", cid)
        return true
    end
}

TALK_SEQUENCE[#TALK_SEQUENCE + 1] = {
    keywords = { 'problem', 'problema' },
    onSay = function(cid)
        selfSay("A few days ago, one of my most reliable sailors told me he saw a {ghost ship}. I didn't believe him, I thought he was drunk or gone mad from the sea, but when I went to the place, I saw it with my own eyes.", cid)
        return true
    end
}

TALK_SEQUENCE[#TALK_SEQUENCE + 1] = {
    keywords = { 'ghost', 'ship', 'embarcacao', 'fantasma' },
    onSay = function(cid)
        selfSay("It was the Exile, a Japanese ship belonging to the {Alliance of the 4 Seas}, a group of pirates made up of four factions who, united, dominated the seas of the world for decades, but were defeated 200 years ago.", cid)
        return true
    end
}

TALK_SEQUENCE[#TALK_SEQUENCE + 1] = {
    keywords = { 'alliance of the 4 seas', 'aliança dos 4 mares', 'alliance', 'alianca' },
    onSay = function(cid)
        selfSay("As I said, it was an alliance of four great pirate captains, Nagumo, Javy Dones, Jack Spearow and Ed Blackhood. The four commanded the pirate groups Sea Dragons, Guns And Roses, Lunatticus and Cold Waters, and were feared in all 4 corners of the planet, but were defeated in the battle of {Black Water}.", cid)
        return true
    end
}

TALK_SEQUENCE[#TALK_SEQUENCE + 1] = {
    keywords = { 'black', 'water' },
    onSay = function(cid)
        selfSay("This battle was between the Alliance of the 4 Seas and an alliance of Lords who wanted to put an end to all pirates. Some say the Lords could never have won without an act of treason by someone on the pirates' side. But these are legends of the sea. The problem is that this happened 200 years ago and these {factions} no longer exist, well, at least until a few days ago.", cid)
        return true
    end
}

TALK_SEQUENCE[#TALK_SEQUENCE + 1] = {
    keywords = { 'factions', 'faccoes' },
    onSay = function(cid)
        selfSay("I know the {location} of each one of them. You could go check them all and prove that I haven't gone mad from the sea, but be careful, each faction has its peculiarities.", cid)
        return true
    end
}

TALK_SEQUENCE[#TALK_SEQUENCE + 1] = {
    keywords = { 'location', 'localizacao' },
    onSay = function(cid)
        selfSay("Before I tell you where they are, I need to tell you about each of them. Which faction do you want to know about first? {Sea Dragons}, {Guns and Roses}, {Lunatticus} or {Cold Waters}?", cid)
        return true
    end
}

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, function(cid, type, msg)
    if (not npcHandler:isFocused(cid)) then
        return false
    end

    if (msgcontains(msg, 'dragon') or msgcontains(msg, 'dragoes')) then
        selfSay("This faction is commanded by Captain Nagumo Harbor, aided by her first mate Sotashi. She is considered the greatest strategist of the seas. They are pirates, but disciplined and honorable. If you prove your honor to them, perhaps you'll win their respect.", cid)
        selfSay("It is located northeast of Viridian, on a beach near the mountain.", cid)
        selfSay("Which other faction do you want to know about? {Guns and Roses}, {Lunatticus} or {Cold Waters}?", cid)
        doCreatureSetStorage(cid, 8694, QUEST_STATUS.STARTED) -- Mark as faction started
        return true
    end

    if (msgcontains(msg, 'guns')) then
        selfSay("Led by Javy Dones, this faction is the most aggressive of all. Despite their aggressiveness, they may listen to adventurers. But beware, Javy Dones loves doing business, and if he doesn't make a profit he'll ask Redbeard to get it some other way.", cid)
        selfSay("It is located south of Fuchsia, on the beach.", cid)
        selfSay("Which other faction do you want to know about? {Sea Dragons}, {Lunatticus} or {Cold Waters}?", cid)
        doCreatureSetStorage(cid, 8695, QUEST_STATUS.STARTED) -- Mark as faction started
        return true
    end

    if (msgcontains(msg, 'lunatticus')) then
        selfSay("This faction is in this business for adventure, but they are still pirates. They usually bet on the improbable and are famous for succeeding. Its leader, Captain Jack Spearow, likes to have fun, but he'll frown if you don't call him Captain. Brother Calico only runs the business and is usually more sensible.", cid)
        selfSay("It is located north of Cerulean, next to Bill's Laboratory.", cid)
        selfSay("Which other faction do you want to know about? {Sea Dragons}, {Guns And Roses} or {Cold Waters}?", cid)
        doCreatureSetStorage(cid, 8696, QUEST_STATUS.STARTED) -- Mark as faction started
        return true
    end

    if (msgcontains(msg, 'cold')) then
        selfSay("I wouldn't call it a faction, as there are only 2 of them, Ed Blackhood and Will Kid. It seems they seek revenge for Rickon, Ed's eldest son and Will's brother. I can only say they have no interest in anything you want to offer them.", cid)
        selfSay("It is located east of Cerulean, near the Power Plant, on the coast.", cid)
        selfSay("Which other faction do you want to know about? {Sea Dragons}, {Guns And Roses} or {Lunatticus}?", cid)
        doCreatureSetStorage(cid, 8697, QUEST_STATUS.STARTED) -- Mark as faction started
        return true
    end

    local sequenceReturn, TALK_SEQUENCE_STATE = doTalkSequence(cid, msg, TALK_SEQUENCE, TALK_SEQUENCE_STATE)
    if (not sequenceReturn) then
        selfSay("Hello adventurer, you look like someone who likes the {sea}, am I correct?", cid)
    end

    return true
end)

npcHandler:setCallback(CALLBACK_GREET, function(cid)
    if (getPlayerDefeatedNPC(cid, WILL_KID_LAST_BATTLE_STORAGE)) then
        npcHandler:sayStory(string.createStory(__L(cid, "You're one tough cookie!! I saw everything, you were fantastic, you fought those aberrations and survived. Well, I healed you, but you stayed alive until I arrived... I was looking for you, you forgot to tell me if it was true that they had returned... Then I saw Will Kid shooting at you with my own eyes... lucky I got there in time, the sleeping dose was high and you almost didn't make it... While taking you home, I boarded a boat near Nagumo's ship to get a closer look, when Nagumo told me to stop... she wanted to know what I had done to you. I got caught, and they took care of you... I explained everything I saw... so I thought I'd better get you to the city... I think you should go and thank Nagumo, she defended you, and that's an honor few get.")), cid)
        return false
    end

    return true
end)

npcHandler:addModule(FocusModule:new())
