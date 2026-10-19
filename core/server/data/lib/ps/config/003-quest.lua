-- LAST STORAGE: 8755

local REWARD_TYPE = {}
REWARD_TYPE.ITEM = 1
REWARD_TYPE.POKEMON = 2
REWARD_TYPE.ADDON = 3

local QUEST_TYPE = {}
QUEST_TYPE.BRING_ITEMS = 0
QUEST_TYPE.BRING_POKEMON = 1
QUEST_TYPE.DEX_POKEMONS = 2
QUEST_TYPE.DEFEAT_POKEMON = 3 -- NOTE: This quest type only works with one defeat, example: Defeat 30 Charmander. Never try to: Defeat 30 Charmander and 25 Pikachu, this does not work
QUEST_TYPE.CATCH_POKEMON = 4 -- NOTE: This quest type only works with one caught, example: Caught 30 Charmander. Never try to: Caught 30 Charmander and 25 Pikachu, this does not work
QUEST_TYPE.CUSTOM = 5 -- Custom request function

QUEST_STATUS = {} -- Set as global to be used inside other systems
QUEST_STATUS.UNSTARTED = -1
QUEST_STATUS.STARTED = 0
QUEST_STATUS.FINISHED = 1
QUEST_STATUS.ERROR = 2 -- This fix the problem if the quest inst correctly configured, on getQuestStatus.

local TALK_STATE = {}
TALK_STATE.ERASE = 0
TALK_STATE.ACCEPTING = 1
TALK_STATE.FINISHING = 2

QUESTS_CONFIG = {
    ["Jack Simps"] = {
        {
            storage = 8001,
            talk_questStarting = "Well, I'm doing some experiments and I need a few ingredients, do you want to help me?",
            talk_questStarted = "Ok, the ingredients that I need are 25 bitten apples, come back when you have them.",
            talk_questFinishing = "Have you got what I asked for?",
            talk_questFinished = "Oh yeah, thank you, now I can finally finish my experiments.",
            talk_questFinishFail = "No... You don't have them. Go get the ingredients and come back to me.",
            talk_questDone = "Thanks, but, I have no missions for you now.",
            questType = QUEST_TYPE.BRING_ITEMS, -- Quest type
            questRequest = { 12115, 25 }, -- The request of the quest
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 2152, count = 5 } }, -- The player reward after finish the quest
            rewardExp = 2000, -- The player exp reward after finish the quest
            requiredLevel = 10, -- Required level to do the quest
        }
    },
    ["John Rouver"] = {
        {
            storage = 8002,
            talk_questStarting = "I'm building a collection of items and I'm having trouble finding some things, do you want to help me?",
            talk_questStarted = "Ok, the items that I need are 10 bat wings, come back when you have them.",
            talk_questFinishing = "Have you got what I asked for?",
            talk_questFinished = "Oh yeah, thank you, now I can finish my collection.",
            talk_questFinishFail = "First get the items and then come back here.",
            talk_questDone = "Thanks, but, I have no missions for you now.",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 12124, 10 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 2152, count = 3 } },
            rewardExp = 2000,
            requiredLevel = 10,
        }
    },
    ["Mary Vinn"] = {
        {
            storage = 8003,
            talk_questStarting = "My family was famous for its extensive collection of Pokemon teeth. I'm very busy lately and need help collecting some teeth... want to join me on this journey? Maybe I will reward you.",
            talk_questStarted = "Ok, the item I need is 15 teeth. Come back when you have them.",
            talk_questFinishing = "Have you got what I asked for?",
            talk_questFinished = "Thank you, my family will be very proud.",
            talk_questFinishFail = "No... you don't have them. Come back when you do.",
            talk_questDone = "Thanks, but, I have no missions for you now.",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 12117, 15 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 2152, count = 4 } },
            rewardExp = 1000,
            requiredLevel = 10,
        }
    },
    ["Rock Jhonson"] = {
        {
            storage = 8004,
            talk_questStarting = "Want to earn a reward? I need a few items and I can't find them.",
            talk_questStarted = "Ok, the items I need are 10 razor fangs. Come back when you have them.",
            talk_questFinishing = "Did you get what I asked for?",
            talk_questFinished = "Thank you, here is your reward. Take care.",
            talk_questFinishFail = "No... you don't have them. Come back when you do.",
            talk_questDone = "Thanks, but, I have no missions for you now.",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 12096, 10 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 2152, count = 3 } },
            rewardExp = 1200,
            requiredLevel = 10,
        }
    },
    ["Mary Nady"] = {
        {
            storage = 8005,
            talk_questStarting = "Uh, I don't usually do this but... I'm running a science event and I need some items to finish my experiment. Do you want to help me?",
            talk_questStarted = "Ok, the items I need are 50 water gems and 50 bottles of poison. Come back when you have them.",
            talk_questFinishing = "Have you got what I asked for?",
            talk_questFinished = "Yup! Thanks!",
            talk_questFinishFail = "No... you don't have them. Go get the ingredients and come back to me.",
            talk_questDone = "Thanks, but, I have no missions for you now.",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 12100, 50, 12104, 50 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 2152, count = 4 } },
            rewardExp = 1500,
            requiredLevel = 10,
        }
    },
    ["Joe Tiff"] = {
        {
            storage = 8006,
            talk_questStarting = "Uh, I need some items that smell of nature, want to help me?",
            talk_questStarted = "Alright, the items that I need are 13 pot of moss mug, come back when you have them.",
            talk_questFinishing = "Have you got what I asked for?",
            talk_questFinished = "Thank you, take your reward.",
            talk_questFinishFail = "No... You don't have them. Go get the ingredients and come back to me.",
            talk_questDone = "Thanks, but, I have no missions for you now.",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 12113, 13 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 2152, count = 5 } },
            rewardExp = 2000,
            requiredLevel = 10,
        }
    },
    ["Bob Lop"] = {
        {
            storage = 8007,
            talk_questStarting = "Well, I collect little things from the beach and need help finding some items, are you willing to help me?",
            talk_questStarted = "Ok, the items I need are 10 crab claws, come back when you have them.",
            talk_questFinishing = "Have you got what I asked for?",
            talk_questFinished = "Thank you, take your reward.",
            talk_questFinishFail = "No... You don't have them, go get the items and come back to me.",
            talk_questDone = "Thanks, but, I have no missions for you now.",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 12149, 10 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 2152, count = 3 } },
            rewardExp = 1750,
            requiredLevel = 10,
        }
    },
    ["Eric Garinson"] = {
        {
            storage = 8009,
            talk_questStarting = "My family is very frustrated with me lately because I don't have much talent as a Pokemon trainer; they don't know my dream is something else... So I need some help, what do you think?",
            talk_questStarted = "Ok, catch a Pidgey and come back here.",
            talk_questFinishing = "Did you get what I asked for?",
            talk_questFinished = "Thanks! Here is your reward.",
            talk_questFinishFail = "No... You don't have it. Catch a Pidgey and come back here.",
            talk_questDone = "Thanks, but, I have no missions for you now.",
            questType = QUEST_TYPE.BRING_POKEMON,
            questRequest = "Pidgey",
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 2152, count = 5 } },
            rewardExp = 500,
            requiredLevel = 10,
        }
    },
    ["Professor Oak"] = {
        {
            storage = 8751,
            talk_questStarting = "",
            talk_questStarted = "",
            talk_questFinishing = "Did you call your Pokemon out?",
            talk_questFinished = "I see you succeeded, congratulations!",
            talk_questFinishFail = "No... you haven't done it yet.",
            questType = QUEST_TYPE.CUSTOM,
            questRequest = function(cid) return true end,
            startPosition = {x = 5020, y = 788, z = 7},
            finishPosition = {x = 5020, y = 788, z = 7},
            onEnd = function(cid)
                doSendPlayerExtendedOpcode(cid, EXTENDED_IDS.GAMEPLAY_TUTORIAL_IMAGE, "003-pokedex")
                doPlayerStartQuest(cid, nil, "Professor Oak", 8752)
            end
        },
        {
            storage = 8752,
            talk_questStarting = "",
            talk_questStarted = "Now try using your Pokedex on your {Pokemon}.",
            talk_questFinishing = "Did you use your Pokedex?",
            talk_questFinished = "I see you are doing very well. Right, now you will have a harder task...",
            talk_questFinishFail = "No... you haven't done it yet.",
            questType = QUEST_TYPE.CUSTOM,
            questRequest = function(cid) return getPlayerTotalDexedPokemons(cid) > 0 end,
            startPosition = {x = 5020, y = 788, z = 7},
            finishPosition = {x = 5020, y = 788, z = 7},
            onEnd = function(cid)
                doPlayerStartQuest(cid, nil, "Professor Oak", 8753)
                doSendMagicEffect({x = 5025, y = 785, z = 7}, EFFECT_TUTORIAL_ARROW)
                doSendMagicEffect({x = 5025, y = 785, z = 7}, EFFECT_TUTORIAL_SQUARE)
            end
        },
        {
            storage = 8753,
            counterStorage = 8754,
            talk_questStarting = "",
            talk_questStarted = "Lately some Rattata have been infesting my basement. Could you defeat 5 of them for me?",
            talk_questFinishing = "Did you defeat all the Rattatas?",
            talk_questFinished = "All right, take this reward. You can bring these items to the PokeMart and sell them there for a fair price. Just head north until you find the blue building.",
            talk_questFinishFail = "No... you haven't done it yet.",
            questType = QUEST_TYPE.DEFEAT_POKEMON,
            questRequest = { "Rattata", 5 },
            startPosition = {x = 5020, y = 788, z = 7},
            finishPosition = {x = 5020, y = 788, z = 7},
            onStart = function(cid)
                doSendPlayerExtendedOpcode(cid, EXTENDED_IDS.GAMEPLAY_TUTORIAL_IMAGE, "004-sewer")
                Flashlight.give(cid)
            end,
--            onEnd = function(cid) doSendPlayerExtendedOpcode(cid, EXTENDED_IDS.GAMEPLAY_TUTORIAL_IMAGE, "004-sewer") end,
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 12115, count = 5 } },
        },
        -- Beginner Quest - A work for Oak
        {
            storage = 8498,
            talk_questStarting = "Good to know that you are busy with your journey. I need a hand with some things. Can you help me?",
            talk_questStarted = "I placed an order at the Pallet PokeMart. Please pick it up for me. We will see if you are a good trainer.",
            talk_questFinishing = "Did my order arrive?",
            talk_questFinished = "Now I'll learn how to make barbecue sauce! ... ... You still need to learn some things to get ready. Go talk to my assistant, Jofrey. He is just outside the lab, by the pond to the east.",
            talk_questFinishFail = "No... you haven't done it yet.",
            talk_questDone = "Thanks, but, I have no missions for you now.",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 23950, 1 },
            canStart = function(cid)
                -- up to level 20, after Professor Oak's tutorial (8753) or with a Pokemon from Professor Tommy's island
                return getPlayerLevel(cid) <= 20 and
                        (getCreatureStorage(cid, 8753) == QUEST_STATUS.FINISHED or not getPlayerGotStarterPokemon(cid))
            end,
            onStart = function(cid)
                doCreatureSetStorage(cid, 8500, QUEST_STATUS.STARTED)
                doPlayerAddMapMark(cid, { x = 3286, y = 804, z = 7 }, MAPMARK_EXCLAMATION, "Pallet PokeMart")
                doPlayerAddMapMark(cid, { x = 3324, y = 822, z = 6 }, MAPMARK_EXCLAMATION, "Stairs to Pallet")
            end,
            onEnd = function(cid)
                doPlayerAddMapMark(cid, { x = 3349, y = 814, z = 6 }, MAPMARK_EXCLAMATION, "Assistant Jofrey")
            end,
        },
        {
            storage = 8204,
            talk_questStarting = "How nice to see you again! I have an emergency right now.",
            talk_questStarted = "The Cerulean Gym Leader is in trouble. Go help her!",
            talk_questFinishing = "Did you help the Cerulean Gym Leader?",
            talk_questFinished = "You handled the situation in Cerulean well. I'm curious what Pokemon will come out of that egg found in a canyon... By the way, I have news, come talk to me when you're ready.",
            talk_questFinishFail = "No... you haven't done it yet.",
            talk_questDone = "Thanks, but, I have no missions for you now.",
            questType = QUEST_TYPE.CUSTOM,
            questRequest = function(cid) return getCreatureStorage(cid, 8205) == QUEST_STATUS.FINISHED end,
            rewardItems = {},
            rewardExp = 0,
            requiredLevel = 70,
            canStart = function(cid) return getPlayerLevel(cid) >= 70 and getPlayerHasKantoBadges(cid) end
        },
        {
            storage = 8338,
            talk_questStarting = "So you want to upgrade your Pokedex?",
            talk_questStarted = "Oh, that's right! But we have a problem... the last trainer who came here to upgrade broke my device. Can you go ask my friend Dr. Oravaf to come fix it? The last I heard, his house faces the sea. I do not remember where...",
            talk_questFinishing = "Did you find Dr. Oravaf?",
            talk_questFinished = "Very well! Now I will upgrade your Pokedex. A moment... 3... 2... 1... Done! Here it is!",
            talk_questFinishFail = "No... you haven't done it yet.",
            talk_questDone = "Thanks, but, I have no missions for you now.",
            questType = QUEST_TYPE.CUSTOM,
            questRequest = function(cid) return getCreatureStorage(cid, 8333) == QUEST_STATUS.FINISHED end,
            rewardItems = {},
            rewardExp = 0,
            requiredLevel = 70,
            onEnd = function(cid)
                doPlayerUpgradePokedex(cid, DEX_IDS.KANTO)
                doPlayerUpgradeBadgeCase(cid, BADGE_CASE_IDS.KANTO)
                doPlayerAchievementCheck(cid, ACHIEVEMENT_IDS.UPGRADE_POKEDEX)
            end,
            canStart = function(cid) return getCreatureStorage(cid, 8204) == QUEST_STATUS.FINISHED end
        },
        {
            storage = 8206,
            talk_questStarting = "As you know there is a group of islands south of the continent. They are called the Orange Archipelago and from what I know it is a fascinating place. How about investigating it further?",
            talk_questStarted = "Sweet! First, you need to gather information from a friend of mine who has visited the islands. Look for Arold, he will give you some answers. Hmmm, I just do not remember where he lives.",
            talk_questFinishing = "Did you get enough information about the Orange Archipelago?",
            talk_questFinished = "Very good to hear! Talk to me again when you're ready.",
            talk_questFinishFail = "No... you haven't done it yet.",
            talk_questDone = "Thanks, but, I have no missions for you now.",
            questType = QUEST_TYPE.CUSTOM,
            questRequest = function(cid) return getCreatureStorage(cid, 8343) == QUEST_STATUS.FINISHED end,
            rewardItems = {},
            rewardExp = 0,
            requiredLevel = 70,
            onStart = function(cid) doCreatureSetStorage(cid, 8340, QUEST_STATUS.STARTED) end,
            canStart = function(cid) return getCreatureStorage(cid, 8338) == QUEST_STATUS.FINISHED end
        },
        {
            storage = 8353,
            talk_questStarting = "Now we need to find the map of the Orange Archipelago.",
            talk_questStarted = "Great, you need to find Runford. He has more information on where we can find the map.",
            talk_questFinishing = "Did you find Runford?",
            talk_questFinished = "Very good to hear! Talk to me again when you're ready.",
            talk_questFinishFail = "No... you haven't done it yet.",
            talk_questDone = "Thanks, but, I have no missions for you now.",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 18202, 1 },
            rewardItems = {},
            rewardExp = 0,
            requiredLevel = 70,
            canStart = function(cid) return getCreatureStorage(cid, 8206) == QUEST_STATUS.FINISHED end,
            onEnd = function(cid) doPlayerAchievementCheck(cid, ACHIEVEMENT_IDS.AFTER_KANTO) end
        },
        {
            storage = 8213,
            talk_questStarting = "Hello, did you make your preparations? I need your help again. Are you prepared to travel to the Orange Archipelago?",
            talk_questStarted = "Great. Professor Ivy, who lives in the archipelago, has a new type of Pokeball she calls the GS Ball. She still could not open it and asked for my help to continue the research. I need you to fetch it for me. Go ahead champion! Tip: take the ship at Vermilion and reach Valencia Island.",
            talk_questFinishing = "Did you bring the GS ball?",
            talk_questFinished = "Thank you! I'm starting research on this mysterious artifact. Go see Ivy again, maybe she needs your help.",
            talk_questFinishFail = "No... you haven't done it yet.",
            talk_questDone = "Thanks, but, I have no missions for you now.",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 18159, 1 },
            rewardItems = {},
            rewardExp = 0,
            requiredLevel = 70,
            canStart = function(cid) return getCreatureStorage(cid, 8353) == QUEST_STATUS.FINISHED end,
            onEnd = function(cid)
                setPlayerOrangeArchipelagoAccess(cid, 2)
                doPlayerAchievementCheck(cid, ACHIEVEMENT_IDS.ORANGE_ARCHIPELAGO_MAIN1)
            end
        },
        {
            storage = 8328,
            talk_questStarting = "Ok, I've been informed of everything. There's no time to lose. Listen to me carefully right now.",
            talk_questStarted = "This stone is being kept on Shamouti Island. Run to the south end of the main island and find the way. Go!",
            talk_questFinishing = "Did you find the Deepsoul Stone?",
            talk_questFinished = "Great job! Congratulations!",
            talk_questFinishFail = "No... you haven't done it yet.",
            talk_questDone = "Thanks, but, I have no missions for you now.",
            questType = QUEST_TYPE.CUSTOM,
            questRequest = function(cid) return getCreatureStorage(cid, 8368) == QUEST_STATUS.FINISHED end,
            rewardItems = {
                { type = REWARD_TYPE.ITEM, id = 17377, count = 1, unique = true }, -- TM 41 - Rest
                { type = REWARD_TYPE.ADDON, female = { looktype = 2543, addons = 0 }, male = { looktype = 2544, addons = 0 } },
            },
            rewardExp = 0,
            requiredLevel = 70,
            canStart = function(cid) return getCreatureStorage(cid, 8368) == QUEST_STATUS.STARTED end
        },
    },
    ["Zazi"] = {
        {
            storage = 8014,
            talk_questStarting = "Please help me, I lost my fishing rod and I need to feed my 11 children! I need to build a new fishing rod. Do you accept?",
            talk_questStarted = "Thank you! I'll need: 20 balls of wool, 10 stone orbs, 10 shell bells and 6 rubies.",
            talk_questFinishing = "Do you have the items I need? Please!",
            talk_questFinished = "Oh! I forgot to tell you, I found my fishing rod. But thanks for the help, I'll make one for you! Take it.",
            talk_questFinishFail = "No, you don't have them...",
            talk_questDone = "Thanks, I already found my fishing rod.",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 12129, 20, 12138, 10, 12145, 10, 12130, 6 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 12293, count = 1, unique = true } },
            rewardExp = 500,
            requiredLevel = 20,
        },
        {
            storage = 8035,
            talk_questStarting = "Hey! Long time no see, how are you? I've been looking for you. I never properly thanked you for your help, so I want to make a better fishing rod for you. Do you want it?",
            talk_questStarted = "I'll need: 500 water gems, 200 metal spikes, 50 balls of wool, 100 screws, 50 electrizers, 20 tangela hairs and a splash plate.",
            talk_questFinishing = "Do you have the items I need?",
            talk_questFinished = "It's here! Please enjoy!",
            talk_questFinishFail = "No, you don't have it...",
            talk_questDone = "Thanks, I already found my fishing rod.",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 12100, 500, 13308, 200, 12129, 50, 12103, 100, 12118, 50, 12106, 20, 12230, 1 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 12294, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 50,
        }
    },
    -- storage 8015 is reserved (professor mark book)
    ["Professor Mark"] = {
        {
            storage = 8016,
            talk_questStarting = "I lost some notes when I worked in the Pokemon mansion, if you find them and bring them to me, I will give you a nice reward... you will not regret it. Do you accept?",
            talk_questStarted = "Ok, I don't remember where I lost them, but be careful there. The Pokemon mansion is on Cinnabar Island.",
            talk_questFinishing = "Do you have my notes? My book?",
            talk_questFinished = "Thank you. Now, as promised, here is your reward. I found this box during one of my research trips, it is very special.",
            talk_questFinishFail = "No, you don't have my notes. Please do not waste my time!",
            talk_questDone = "I have nothing else to talk about it.",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 13012, 1 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 13811, count = 1 } },
            rewardExp = 5000,
            requiredLevel = 60,
            onEnd = function(cid) doCreatureSetStorage(cid, 8203, 1) end -- Quest refund storage, new players doesn't need it
        }
    },
    ["Rock"] = {
        {
            storage = 8018,
            talk_questStarting = "Want to know the secret of Pokemon strength? I have many stories to tell. But first I want you to do something for me. Deal?",
            talk_questStarted = "Now I'm a little hungry. Bring me a burger and I'll tell you something. Haha.",
            talk_questFinishing = "Who are you? Ahh, my burger?",
            talk_questFinished = "Thanks, I'm really hungry. I can give you something valuable if you help me with some {tasks}...",
            talk_questFinishFail = "Are you kidding me? WHERE IS MY BURGER!",
            talk_questDone = "Ha?",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 12205, 1 },
            rewardItems = {},
            rewardExp = 0,
            requiredLevel = 0,
        },
        {
            storage = 8019,
            talk_questStarting = "Are you interested?",
            talk_questStarted = "Let's see how strong you are. Bring me 50 stone orbs and 4 fist plates. Easy, no?",
            talk_questFinishing = "Got it?",
            talk_questFinished = "Hmm, you're not as weak as I thought. But that's not all, we are just beginning, I have more {tasks} for you.",
            talk_questFinishFail = "Where? ...",
            talk_questDone = "Ha?",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 12138, 50, 12243, 4 },
            rewardItems = {},
            rewardExp = 5000,
            requiredLevel = 30,
        },
        {
            storage = 8020,
            talk_questStarting = "Next task?",
            talk_questStarted = "Ok, I have an old friend I haven't seen in a long time, I want you to find him for me. You will find him on Ice Island. Bring something back from there to prove you went.",
            talk_questFinishing = "Did you find my friend?",
            talk_questFinished = "Hum, you're getting interesting. I have more {tasks} for you.",
            talk_questFinishFail = "NO!",
            talk_questDone = "Ha?",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 13011, 1 },
            rewardItems = {},
            rewardExp = 8000,
            requiredLevel = 40,
        },
        -- storage 8021 reserved to Agustin message
        {
            storage = 8022,
            talk_questStarting = "Do you really want it?",
            talk_questStarted = "I think this is too much for you! Haha! Simple: beat the three Lee brothers. You'll find them on the mountain northeast of Saffron.",
            talk_questFinishing = "Did you beat them?!",
            talk_questFinished = "You're really impressing me. I underestimated you. But now there is only the {final test}.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Ha?",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 5807, 1, 5806, 1, 5805, 1 },
            rewardItems = {},
            rewardExp = 10000,
            requiredLevel = 70,
        },
        {
            storage = 8023,
            talk_questStarting = "Want to take the final test?",
            talk_questStarted = "Alright. Thousands of fighters have tried this mission and failed, so be careful. Go to the south of this mountain, there is a secret passage to the Natural Mountain. Go there and bring me a special stone called Ancient Rune.",
            talk_questFinishing = "Do you have my special stone?",
            talk_questFinished = "Congratulations, you passed all tests! Here is your reward!",
            talk_questFinishFail = "No, you don't have it...",
            talk_questDone = "Ha?",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 2348, 1 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 17783, count = 1 } },
            rewardExp = 15000,
            requiredLevel = 80,
            onEnd = function(cid) doCreatureSetStorage(cid, 8202, 1) end -- Quest refund storage, new players doesn't need it
        },
    },
    -- storage 8024 reserved to choose betwen Hitmonchan/Hitmonlee
    ["George Carter"] = {
        {
            storage = 8025,
            talk_questStarting = "Well, I am looking for people interested in helping me with the research I'm doing on Mt Moon. Are you interested in helping me?",
            talk_questStarted = "Great! So let's get to work, we'll need some equipment to start our research. You will need: a Pick, a Flashlight and a Rope. You can buy the Pick from a blacksmith who lives in Mt Moon. Come back when you have the tools.",
            talk_questFinishing = "Do you have the tools?",
            talk_questFinished = "Good work! I need your help to do my {research}!",
            talk_questFinishFail = "No, you don't.",
            talk_questDone = "Thanks, but I have no more missions for now.",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 2553, 1, 13219, 1, 2120, 1 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 2553, count = 1 }, { type = REWARD_TYPE.ITEM, id = 13219, count = 1 }, { type = REWARD_TYPE.ITEM, id = 2120, count = 1 } },
            rewardExp = 0,
            requiredLevel = 40,
        },
        {
            storage = 8026,
            talk_questStarting = "Your next task will be tough, do you accept?",
            talk_questStarted = "Alright, now you need to train your skills with these tools! Haha! Go to Mt Moon and look for the entrance to the old mines. From there go north until you find Earth Piles. Then use your Pick on the Earth Piles until you get 10 Iron Ores.",
            talk_questFinishing = "Did you get 10 Iron Ores?",
            talk_questFinished = "Thanks! I need your help to do my {research}!",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks, but I have no more missions for now.",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 5880, 10, 2553, 1 },
            rewardItems = {},
            rewardExp = 0,
            requiredLevel = 40,
        },
        {
            storage = 8027,
            talk_questStarting = "I have heard rumors that the famous Moon Stone can be found in this mountain. Do you want to continue the research?",
            talk_questStarted = "Search through the old mine at Mt Moon and look for the maps left there; they can lead us to secret paths used by the miners.",
            talk_questFinishing = "Have you found the maps?",
            talk_questFinished = "Thanks! I need your help to do my {research}!",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks, but I have no more missions for now.",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 1956, 1, 1957, 1, 5091, 1 },
            rewardItems = {},
            rewardExp = 0,
            requiredLevel = 40,
        },
        {
            storage = 8028,
            talk_questStarting = "I checked the maps and I think I found something very interesting, perhaps the way to the Moon Stone! Want to do this for me?",
            talk_questStarted = "Look for a hole in the mines of Mt Moon; there you will find a door and some paths. Explore the area and find the Moon Stone fragment!",
            talk_questFinishing = "Did you get the Moon Stone fragment?",
            talk_questFinished = "Thanks for everything. As thanks I'll give you something special, a good reward. You can choose a {Fire Stone} or a {Water Stone} or a {Leaf Stone}. What is your choice?",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks, but I have no more missions for now.",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 13972, 1 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 17374, count = 1, unique = true } }, -- TM 38 (Move Softboiled)
            rewardExp = 0,
            requiredLevel = 40,
            onEnd = function(cid) doCreatureSetStorage(cid, 8665, QUEST_STATUS.FINISHED) end -- New players doesnt need the next quest, cuz this exists only to make old-players take the new reward
        },
        {
            storage = 8665,
            talk_questStarting = "Oh, I have a present for you.",
            talk_questStarted = "It's a reward for your previous {mission}.",
            talk_questFinishing = "Are you ready to take it?",
            talk_questFinished = "Oh ok, take it.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks, but I have no more missions for now.",
            questType = QUEST_TYPE.CUSTOM,
            questRequest = function(cid) return true end,
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 17374, count = 1, unique = true } }, -- TM 38 (Move Softboiled)
            rewardExp = 0,
            requiredLevel = 40,
        }
    },
    -- storage 8029 reserved to get George Carter quest reward
    ["Maurice"] = {
        {
            storage = 8034,
            talk_questStarting = "I can build a TV camera for you. The only thing you need to do is get some parts for me. Do you want that?",
            talk_questStarted = "Sure, the parts I need are: 200x Screws, 30x Electrizers and 30x Metal Spikes.",
            talk_questFinishing = "Did you get the parts that I need?",
            talk_questFinished = "Well done! Here's your camera! Make good use of it.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more missions for now.",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 12103, 200, 12118, 30, 13308, 30 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14359, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 40,
        }
    },
    -- storage 8035 reserved to Zazi quest #2
    -- storage 8036 reserved to Zazi quest #2
    -- storage 8037 reserved to Professor Josh Rock quest(quest)
    -- storage 8038 reserved to Professor Josh Rock quest(time)
    -- storage 8039 reserved to William Rock quest(quest)
    -- storage 8040 reserved to William Rock quest(message)
    -- storage 8041 reserved to William Rock quest(time)
    ["Stiller"] = {
        -- Social
        {
            storage = 8042,
            talk_questStarting = "People of high society stand out when they wear nice clothes. With good money and some items, I can help you.",
            talk_questStarted = "Okay, bring me 200x Fancy Fabrics, 200x Long Silks and 5000 dollars in hundred-dollar notes (50 notes).",
            talk_questFinishing = "Is that what I asked for?",
            talk_questFinished = "Perfect, just in time. Here!",
            talk_questFinishFail = "Do not waste my time! Go get the parts.",
            talk_questDone = "Sorry?",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 14627, 200, 14630, 200, 2152, 50 },
            rewardItems = {
                { type = REWARD_TYPE.ADDON, female = { looktype = 621, addons = 1 }, male = { looktype = 622, addons = 1 } },
            },
            rewardExp = 0,
            requiredLevel = 0,
        },
        {
            storage = 8043,
            talk_questStarting = "Accessories are very important to create a beautiful look, but they are not cheap. I can get you some accessories, but you can't get them with money.",
            talk_questStarted = "I'll need rare gems. Bring me 50x Fire Orbs, 50x White Orbs and 50x Black Diamonds.",
            talk_questFinishing = "Is that what I asked for?",
            talk_questFinished = "Wonderful! Here, now you're all dressed up.",
            talk_questFinishFail = "Do not waste my time! Go get the parts.",
            talk_questDone = "Sorry, I can't help you.",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 14514, 50, 14516, 50, 14517, 50 },
            rewardItems = {
                { type = REWARD_TYPE.ADDON, female = { looktype = 621, addons = 2 }, male = { looktype = 622, addons = 2 } },
            },
            rewardExp = 0,
            requiredLevel = 0,
        }
    },
    ["Roman"] = {
        -- Punk
        {
            storage = 8044,
            talk_questStarting = "Let's make a deal, you bring me some items and I'll give you a special cage.",
            talk_questStarted = "I need: 1500x Light Feathers and 100x Big Feathers.",
            talk_questFinishing = "Did you bring the items I asked for?",
            talk_questFinished = "Great! Here is your cage. Be careful.",
            talk_questFinishFail = "Where are they?",
            talk_questDone = "You already get the cage, I can't help you.",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 14484, 1500, 14624, 100 },
            rewardItems = {
                { type = REWARD_TYPE.ADDON, female = { looktype = 625, addons = 1 }, male = { looktype = 626, addons = 1 } },
            },
            rewardExp = 0,
            requiredLevel = 0,
        },
        {
            storage = 8045,
            talk_questStarting = "Oh! You again! Did you like the cage? I hope so... because I have more equipment to give you.",
            talk_questStarted = "Ok! Bring me: 500x Downy Feather and 50x Resistant Fabric.",
            talk_questFinishing = "Do you have my items?",
            talk_questFinished = "Good job, here it is. Now you have all the equipment you need to catch your Pokemon!",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "You already get all the necessary equipment, I can't help you.",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 14478, 500, 14626, 50 },
            rewardItems = {
                { type = REWARD_TYPE.ADDON, female = { looktype = 625, addons = 2 }, male = { looktype = 626, addons = 2 } },
            },
            rewardExp = 0,
            requiredLevel = 0,
        }
    },
    ["Julia"] = {
        -- Fisher (Angler vocation outfit)
        {
            storage = 8046,
            canStart = function(cid) return Vocations.is(cid, "angler") end,
            talk_questStarting = "Insect Pokemon are very slippery, I use a net to capture them! I can build one for you.",
            talk_questStarted = "I'll need the following items: 50x Spool of Yarn and 500x Bamboo Leaves.",
            talk_questFinishing = "Have you got the items?",
            talk_questFinished = "Great! Now you can get your insects.",
            talk_questFinishFail = "Come back here when you get all the items!",
            talk_questDone = "Done.",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 14507, 50, 14466, 500 },
            rewardItems = {
                { type = REWARD_TYPE.ADDON, female = { looktype = 627, addons = 1 }, male = { looktype = 628, addons = 1 } },
            },
            rewardExp = 0,
            requiredLevel = 0,
        },
        {
            storage = 8047,
            canStart = function(cid) return Vocations.is(cid, "angler") end,
            talk_questStarting = "Great insect hunters spend days in the forest, so they need to carry heavy equipment. You can't carry everything in your arms, but I can get you a backpack for it. Let's make a deal.",
            talk_questStarted = "You bring me some rare items and I'll build a backpack for you. Bring me 100x Insect Skins and 150x Hard Nails.",
            talk_questFinishing = "Have you got the items?",
            talk_questFinished = "Congratulations, here it is.",
            talk_questFinishFail = "Come back here when you get all the items!",
            talk_questDone = "Done.",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 14625, 100, 14498, 150 },
            rewardItems = {
                { type = REWARD_TYPE.ADDON, female = { looktype = 627, addons = 2 }, male = { looktype = 628, addons = 2 } },
            },
            rewardExp = 0,
            requiredLevel = 0,
        }
    },
    ["Abi"] = {
        -- Oriental
        {
            storage = 8048,
            talk_questStarting = "The desert is a very dangerous place, you could walk to your death. I need some items. If you bring them to me, I'll make you some clothes for walking in the desert.",
            talk_questStarted = "Bring me 1000x Lightweight Fabrics and 100x Exquisite Silks.",
            talk_questFinishing = "Have you got what I asked for?",
            talk_questFinished = "Good work, here it is.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "I can't help you now.",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 14629, 1000, 14483, 100 },
            rewardItems = {
                { type = REWARD_TYPE.ADDON, female = { looktype = 635, addons = 1 }, male = { looktype = 636, addons = 1 } },
            },
            rewardExp = 0,
            requiredLevel = 0,
        },
        {
            storage = 8049,
            talk_questStarting = "The sun is getting stronger, you will need better protection against it! Maybe we can make a deal to fix this.",
            talk_questStarted = "Fine, bring me 50x Healing Oil and 50x Old Bandage.",
            talk_questFinishing = "Have you got what I asked for?",
            talk_questFinished = "Nice job, now you have a good protection.",
            talk_questFinishFail = "No! Where is it?",
            talk_questDone = "I can't help you now.",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 14628, 50, 14631, 50 },
            rewardItems = {
                { type = REWARD_TYPE.ADDON, female = { looktype = 635, addons = 2 }, male = { looktype = 636, addons = 2 } },
            },
            rewardExp = 0,
            requiredLevel = 0,
        }
    },
    --[[["Santa Claus"] = {
        {
            storage = 8373,
            talk_questStarting = "I'm desperate, I need to recover my gifts! The team rocket stole all the Christmas gifts! Are you willing to help me save Christmas?",
            talk_questStarted = "Thank you, I need you to find my christmas tokens, you will find them with rockets. I need at least 350 tokens. Please help me!",
            talk_questFinishing = "Did you find the christmas tokens?",
            talk_questFinished = "Oh! Thank you! Be blessed. I have a reward for you! Your options are: {TM 16} (Submission), {TM 23} (Thunderbolt), {TM 27} (Psychic), {TM 39} (Dream Eater) and {TM 46} (Tri Attack).",
            talk_questFinishFail = "No you could not...",
            talk_questDone = "The christmas is saved! Thanks!",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = {14632, 350},
            rewardItems = {},
            rewardExp = 0,
            requiredLevel = 35,
        },
        {
            storage = 8375,
            talk_questStarting = "There are still many gifts to be rescued, you want to help me?",
            talk_questStarted = "Thank you, I need you to find my christmas tokens, you will find them with rockets. I need at least 500 tokens. Please help me!",
            talk_questFinishing = "Did you find the christmas tokens?",
            talk_questFinished = "Ho ho ho! Thank you. I have a reward for you! Your options are: {TM 10} (Double-Edge), {TM 13} (Ice Beam), {TM 21} (Solar Beam), {TM 26} (Fissure) and {TM 32} (Metronome).",
            talk_questFinishFail = "No you could not...",
            talk_questDone = "The christmas is saved! Thanks!",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = {14632, 500},
            rewardItems = {},
            rewardExp = 0,
            requiredLevel = 55,
        },
        ]]--[[{
			storage = 8050,
			talk_questStarting = "I'm desperate, I need to recover my gifts! The team rocket stole all the Christmas gifts! Are you willing to help me save Christmas?",
			talk_questStarted = "Thank you, I need you to find me 9 red christmas present, you will find them with rockets. I heard rumors that there are rockets scattered all cities. Please help me!",
			talk_questFinishing = "You find my gifts?",
			talk_questFinished = "Oh! Thank you! Be blessed. There are still many gifts to be {saved}.",
			talk_questFinishFail = "No you could not...",
			talk_questDone = "The christmas is saved! Thanks!",
			questType = QUEST_TYPE.BRING_ITEMS,
			questRequest = {14636, 9},
			rewardItems = {{type = REWARD_TYPE.ITEM, id = 14639, count = 1, unique = true}},
			rewardExp = 0,
			requiredLevel = 0,
			daily = true
		},
		{
			storage = 8051,
			talk_questStarting = "There are still many gifts to be rescued, you want to help me?",
			talk_questStarted = "Okay, I need you to search for me 18 blue christmas present! The rockets are with them!",
			talk_questFinishing = "You find my gifts?",
			talk_questFinished = "Ho ho ho! Thank you. I need to {save} the Christmas.",
			talk_questFinishFail = "No you could not...",
			talk_questDone = "The christmas is saved! Thanks!",
			questType = QUEST_TYPE.BRING_ITEMS,
			questRequest = {14637, 18},
			rewardItems = {{type = REWARD_TYPE.ITEM, id = 14640, count = 1, unique = true}},
			rewardExp = 0,
			requiredLevel = 0,
			daily = true
		},
		{
			storage = 8052,
			talk_questStarting = "I'm looking for more gifts. Want to help?",
			talk_questStarted = "Bring me 40 red christmas present, 40 blue christmas present and 40 green christmas present.",
			talk_questFinishing = "You find my gifts?",
			talk_questFinished = "Ho ho ho! Thank you. I need to {save} the Christmas.",
			talk_questFinishFail = "No you could not...",
			talk_questDone = "The christmas is saved! Thanks! Back tomorrow to more missions.",
			questType = QUEST_TYPE.BRING_ITEMS,
			questRequest = {14636, 40, 14637, 40, 14638, 40},
			rewardItems = {{type = REWARD_TYPE.ITEM, id = 14641, count = 1, unique = true}},
			rewardExp = 0,
			requiredLevel = 0,
		},]]--[[
    },]]
    --[[
    FROM storage 8053 TO storage 8079 reserved to masterys
    ]]
    -- Blaze Mastery
    ["Gurtab"] = {
        -- Item
        {
            storage = 8080,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! I need you to bring me these items: 338x Fire Element.",
            talk_questFinishing = "Did you get the items?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 12101, 338 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14740, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
        {
            storage = 8080,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! I need you to bring me these items: 26x Pot of Lava.",
            talk_questFinishing = "Did you get the items?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 12087, 26 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14740, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
        {
            storage = 8080,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! I need you to bring me these items: 12x Flame Orb.",
            talk_questFinishing = "Did you get the items?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 13303, 12 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14740, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
        {
            storage = 8080,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! I need you to bring me these items: 5x Eternal Flames.",
            talk_questFinishing = "Did you get the items?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 14482, 5 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14740, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
        {
            storage = 8080,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! I need you to bring me these items: 3x Burning Heart.",
            talk_questFinishing = "Did you get the items?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 14471, 3 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14740, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
    },
    ["Noah"] = {
        -- Defeat
        {
            storage = 8085,
            counterStorage = 8082,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! Your task is to defeat 30 Golem.",
            talk_questFinishing = "Is the task done?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.DEFEAT_POKEMON,
            questRequest = { "Golem", 30 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14740, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
        {
            storage = 8086,
            counterStorage = 8082,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! Your task is to defeat 30 Onix.",
            talk_questFinishing = "Is the task done?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.DEFEAT_POKEMON,
            questRequest = { "Onix", 30 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14740, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
        {
            storage = 8087,
            counterStorage = 8082,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! Your task is to defeat 30 Charizard.",
            talk_questFinishing = "Is the task done?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.DEFEAT_POKEMON,
            questRequest = { "Charizard", 30 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14740, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
        {
            storage = 8088,
            counterStorage = 8082,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! Your task is to defeat 30 Ninetales.",
            talk_questFinishing = "Is the task done?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.DEFEAT_POKEMON,
            questRequest = { "Ninetales", 30 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14740, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
        {
            storage = 8089,
            counterStorage = 8082,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! Your task is to defeat 30 Arcanine.",
            talk_questFinishing = "Is the task done?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.DEFEAT_POKEMON,
            questRequest = { "Arcanine", 30 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14740, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
        {
            storage = 8090,
            counterStorage = 8082,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! Your task is to defeat 30 Rapidash.",
            talk_questFinishing = "Is the task done?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.DEFEAT_POKEMON,
            questRequest = { "Rapidash", 30 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14740, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
        {
            storage = 8091,
            counterStorage = 8082,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! Your task is to defeat 30 Blastoise.",
            talk_questFinishing = "Is the task done?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.DEFEAT_POKEMON,
            questRequest = { "Blastoise", 30 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14740, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
        {
            storage = 8092,
            counterStorage = 8082,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! Your task is to defeat 30 Golduck.",
            talk_questFinishing = "Is the task done?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.DEFEAT_POKEMON,
            questRequest = { "Golduck", 30 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14740, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
        {
            storage = 8093,
            counterStorage = 8082,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! Your task is to defeat 30 Tentacruel.",
            talk_questFinishing = "Is the task done?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.DEFEAT_POKEMON,
            questRequest = { "Tentacruel", 30 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14740, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
        {
            storage = 8094,
            counterStorage = 8082,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! Your task is to defeat 30 Dewgong.",
            talk_questFinishing = "Is the task done?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.DEFEAT_POKEMON,
            questRequest = { "Dewgong", 30 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14740, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
    },
    ["Aila"] = {
        -- Catch
        {
            storage = 8095,
            counterStorage = 8084,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! Your task is to catch 1 Charmander and bring it to me.",
            talk_questFinishing = "Is the task done?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.CATCH_POKEMON,
            questRequest = { "Charmander", 1 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14740, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
        {
            storage = 8096,
            counterStorage = 8084,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! Your task is to catch 1 Vulpix and bring it to me.",
            talk_questFinishing = "Is the task done?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.CATCH_POKEMON,
            questRequest = { "Vulpix", 1 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14740, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
        {
            storage = 8097,
            counterStorage = 8084,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! Your task is to catch 1 Growlithe and bring it to me.",
            talk_questFinishing = "Is the task done?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.CATCH_POKEMON,
            questRequest = { "Growlithe", 1 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14740, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
        {
            storage = 8098,
            counterStorage = 8084,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! Your task is to catch 1 Ponyta and bring it to me.",
            talk_questFinishing = "Is the task done?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.CATCH_POKEMON,
            questRequest = { "Ponyta", 1 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14740, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
    },
    -- Hurricane Mastery
    ["Farrel"] = {
        -- Item
        {
            storage = 8080,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! I need you to bring me these items: 26x Feather.",
            talk_questFinishing = "Did you get the items?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 12142, 26 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14741, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
        {
            storage = 8080,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! I need you to bring me these items: 68x Light Feather.",
            talk_questFinishing = "Did you get the items?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 14484, 68 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14741, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
        {
            storage = 8080,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! I need you to bring me these items: 3x Royal Feather.",
            talk_questFinishing = "Did you get the items?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 14502, 3 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14741, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
        {
            storage = 8080,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! I need you to bring me these items: 3x Big Feather.",
            talk_questFinishing = "Did you get the items?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 14624, 3 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14741, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
    },
    ["Eden"] = {
        -- Defeat
        {
            storage = 8099,
            counterStorage = 8082,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! Your task is to defeat 30 Magneton.",
            talk_questFinishing = "Is the task done?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.DEFEAT_POKEMON,
            questRequest = { "Magneton", 30 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14741, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
        {
            storage = 8100,
            counterStorage = 8082,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! Your task is to defeat 30 Electrode.",
            talk_questFinishing = "Is the task done?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.DEFEAT_POKEMON,
            questRequest = { "Electrode", 30 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14741, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
        {
            storage = 8101,
            counterStorage = 8082,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! Your task is to defeat 15 Electabuzz.",
            talk_questFinishing = "Is the task done?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.DEFEAT_POKEMON,
            questRequest = { "Electabuzz", 15 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14741, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
    },
    ["Cayl"] = {
        -- Catch
        {
            storage = 8102,
            counterStorage = 8084,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! Your task is to catch 2 Pidgey and bring them to me.",
            talk_questFinishing = "Is the task done?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.CATCH_POKEMON,
            questRequest = { "Pidgey", 2 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14741, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
        {
            storage = 8103,
            counterStorage = 8084,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! Your task is to catch 2 Spearow and bring them to me.",
            talk_questFinishing = "Is the task done?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.CATCH_POKEMON,
            questRequest = { "Spearow", 2 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14741, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
        {
            storage = 8104,
            counterStorage = 8084,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! Your task is to catch 3 Zubat and bring them to me.",
            talk_questFinishing = "Is the task done?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.CATCH_POKEMON,
            questRequest = { "Zubat", 3 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14741, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
    },
    -- Voltagic Mastery
    ["Tate"] = {
        -- Item
        {
            storage = 8080,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! I need you to bring me these items: 11x Electrizer.",
            talk_questFinishing = "Did you get the items?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 12118, 11 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14742, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
        {
            storage = 8080,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! I need you to bring me these items: 8x Metal Spikes.",
            talk_questFinishing = "Did you get the items?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 13308, 8 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14742, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
        {
            storage = 8080,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! I need you to bring me these items: 39x Gear Wheel.",
            talk_questFinishing = "Did you get the items?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 14490, 39 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14742, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
        {
            storage = 8080,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! I need you to bring me these items: 6x Hard Nail.",
            talk_questFinishing = "Did you get the items?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 14498, 6 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14742, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
        {
            storage = 8080,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! I need you to bring me these items: 14x Magnet.",
            talk_questFinishing = "Did you get the items?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 12140, 14 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14742, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
    },
    ["Ryne"] = {
        -- Defeat
        {
            storage = 8105,
            counterStorage = 8082,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! Your task is to defeat 30 Raichu.",
            talk_questFinishing = "Is the task done?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.DEFEAT_POKEMON,
            questRequest = { "Raichu", 30 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14742, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
        {
            storage = 8106,
            counterStorage = 8082,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! Your task is to defeat 30 Magneton.",
            talk_questFinishing = "Is the task done?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.DEFEAT_POKEMON,
            questRequest = { "Magneton", 30 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14742, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
        {
            storage = 8107,
            counterStorage = 8082,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! Your task is to defeat 30 Electrode.",
            talk_questFinishing = "Is the task done?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.DEFEAT_POKEMON,
            questRequest = { "Electrode", 30 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14742, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
        {
            storage = 8108,
            counterStorage = 8082,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! Your task is to defeat 15 Electabuzz.",
            talk_questFinishing = "Is the task done?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.DEFEAT_POKEMON,
            questRequest = { "Electabuzz", 15 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14742, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
        {
            storage = 8109,
            counterStorage = 8082,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! Your task is to defeat 30 Sandslash.",
            talk_questFinishing = "Is the task done?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.DEFEAT_POKEMON,
            questRequest = { "Sandslash", 30 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14742, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
        {
            storage = 8110,
            counterStorage = 8082,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! Your task is to defeat 30 Dugtrio.",
            talk_questFinishing = "Is the task done?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.DEFEAT_POKEMON,
            questRequest = { "Dugtrio", 30 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14742, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
        {
            storage = 8111,
            counterStorage = 8082,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! Your task is to defeat 30 Golem.",
            talk_questFinishing = "Is the task done?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.DEFEAT_POKEMON,
            questRequest = { "Golem", 30 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14742, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
        {
            storage = 8112,
            counterStorage = 8082,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! Your task is to defeat 30 Golem.",
            talk_questFinishing = "Is the task done?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.DEFEAT_POKEMON,
            questRequest = { "Golem", 30 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14742, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
        {
            storage = 8113,
            counterStorage = 8082,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! Your task is to defeat 30 Venusaur.",
            talk_questFinishing = "Is the task done?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.DEFEAT_POKEMON,
            questRequest = { "Venusaur", 30 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14742, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
        {
            storage = 8114,
            counterStorage = 8082,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! Your task is to defeat 30 Vileplume.",
            talk_questFinishing = "Is the task done?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.DEFEAT_POKEMON,
            questRequest = { "Vileplume", 30 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14742, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
        {
            storage = 8115,
            counterStorage = 8082,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! Your task is to defeat 30 Victreebel.",
            talk_questFinishing = "Is the task done?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.DEFEAT_POKEMON,
            questRequest = { "Victreebel", 30 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14742, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
    },
    ["Ozias"] = {
        -- Catch
        {
            storage = 8116,
            counterStorage = 8084,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! Your task is to catch 1 Pikachu and bring it to me.",
            talk_questFinishing = "Is the task done?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.CATCH_POKEMON,
            questRequest = { "Pikachu", 1 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14742, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
        {
            storage = 8117,
            counterStorage = 8084,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! Your task is to catch 1 Magnemite and bring it to me.",
            talk_questFinishing = "Is the task done?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.CATCH_POKEMON,
            questRequest = { "Magnemite", 1 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14742, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
        {
            storage = 8118,
            counterStorage = 8084,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! Your task is to catch 1 Voltorb and bring it to me.",
            talk_questFinishing = "Is the task done?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.CATCH_POKEMON,
            questRequest = { "Voltorb", 1 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14742, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
    },
    -- Spectrum Mastery
    ["Sakura"] = {
        -- Item
        {
            storage = 8080,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! I need you to bring me these items: 11x Reaper Cloth.",
            talk_questFinishing = "Did you get the items?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 12146, 11 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14743, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
        {
            storage = 8080,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! I need you to bring me these items: 9x Essence of Bad Dream.",
            talk_questFinishing = "Did you get the items?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 14481, 9 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14743, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
        {
            storage = 8080,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! I need you to bring me these items: 12x Cursed Hand.",
            talk_questFinishing = "Did you get the items?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 14476, 12 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14743, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
        {
            storage = 8080,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! I need you to bring me these items: 6x Petrified Scream.",
            talk_questFinishing = "Did you get the items?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 14499, 6 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14743, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
        {
            storage = 8080,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! I need you to bring me these items: 315x Bottle of Poison.",
            talk_questFinishing = "Did you get the items?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 12104, 315 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14743, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
        {
            storage = 8080,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! I need you to bring me these items: 26x Black Sludge.",
            talk_questFinishing = "Did you get the items?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 12144, 26 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14743, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
        {
            storage = 8080,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! I need you to bring me these items: 39x Venom Pendant.",
            talk_questFinishing = "Did you get the items?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 14511, 39 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14743, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
    },
    ["Taya"] = {
        -- Defeat
        {
            storage = 8119,
            counterStorage = 8082,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! Your task is to defeat 30 Arbok.",
            talk_questFinishing = "Is the task done?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.DEFEAT_POKEMON,
            questRequest = { "Arbok", 30 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14743, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
        {
            storage = 8120,
            counterStorage = 8082,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! Your task is to defeat 30 Venomoth.",
            talk_questFinishing = "Is the task done?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.DEFEAT_POKEMON,
            questRequest = { "Venomoth", 30 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14743, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
        {
            storage = 8121,
            counterStorage = 8082,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! Your task is to defeat 30 Muk.",
            talk_questFinishing = "Is the task done?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.DEFEAT_POKEMON,
            questRequest = { "Muk", 30 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14743, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
        {
            storage = 8122,
            counterStorage = 8082,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! Your task is to defeat 30 Gengar.",
            talk_questFinishing = "Is the task done?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.DEFEAT_POKEMON,
            questRequest = { "Gengar", 30 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14743, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
        {
            storage = 8123,
            counterStorage = 8082,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! Your task is to defeat 30 Raichu.",
            talk_questFinishing = "Is the task done?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.DEFEAT_POKEMON,
            questRequest = { "Raichu", 30 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14743, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
        {
            storage = 8124,
            counterStorage = 8082,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! Your task is to defeat 30 Magneton.",
            talk_questFinishing = "Is the task done?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.DEFEAT_POKEMON,
            questRequest = { "Magneton", 30 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14743, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
        {
            storage = 8125,
            counterStorage = 8082,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! Your task is to defeat 30 Electrode.",
            talk_questFinishing = "Is the task done?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.DEFEAT_POKEMON,
            questRequest = { "Electrode", 30 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14743, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
        {
            storage = 8126,
            counterStorage = 8082,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! Your task is to defeat 15 Electabuzz.",
            talk_questFinishing = "Is the task done?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.DEFEAT_POKEMON,
            questRequest = { "Electabuzz", 15 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14743, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
        {
            storage = 8127,
            counterStorage = 8082,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! Your task is to defeat 30 Sandslash.",
            talk_questFinishing = "Is the task done?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.DEFEAT_POKEMON,
            questRequest = { "Sandslash", 30 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14743, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
        {
            storage = 8128,
            counterStorage = 8082,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! Your task is to defeat 30 Dugtrio.",
            talk_questFinishing = "Is the task done?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.DEFEAT_POKEMON,
            questRequest = { "Dugtrio", 30 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14743, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
        {
            storage = 8129,
            counterStorage = 8082,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! Your task is to defeat 30 Golem.",
            talk_questFinishing = "Is the task done?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.DEFEAT_POKEMON,
            questRequest = { "Golem", 30 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14743, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
        {
            storage = 8130,
            counterStorage = 8082,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! Your task is to defeat 30 Golem.",
            talk_questFinishing = "Is the task done?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.DEFEAT_POKEMON,
            questRequest = { "Golem", 30 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14743, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
        {
            storage = 8131,
            counterStorage = 8082,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! Your task is to defeat 30 Venusaur.",
            talk_questFinishing = "Is the task done?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.DEFEAT_POKEMON,
            questRequest = { "Venusaur", 30 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14743, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
        {
            storage = 8132,
            counterStorage = 8082,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! Your task is to defeat 30 Vileplume.",
            talk_questFinishing = "Is the task done?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.DEFEAT_POKEMON,
            questRequest = { "Vileplume", 30 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14743, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
        {
            storage = 8133,
            counterStorage = 8082,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! Your task is to defeat 30 Victreebel.",
            talk_questFinishing = "Is the task done?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.DEFEAT_POKEMON,
            questRequest = { "Victreebel", 30 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14743, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
    },
    ["Kane"] = {
        -- Catch
        {
            storage = 8134,
            counterStorage = 8084,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! Your task is to catch 2 Ekans and bring them to me.",
            talk_questFinishing = "Is the task done?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.CATCH_POKEMON,
            questRequest = { "Ekans", 2 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14743, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
        {
            storage = 8135,
            counterStorage = 8084,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! Your task is to catch 2 Nidorana and bring them to me.",
            talk_questFinishing = "Is the task done?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.CATCH_POKEMON,
            questRequest = { "Nidorana", 2 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14743, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
        {
            storage = 8136,
            counterStorage = 8084,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! Your task is to catch 2 Nidorano and bring them to me.",
            talk_questFinishing = "Is the task done?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.CATCH_POKEMON,
            questRequest = { "Nidorano", 2 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14743, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
        {
            storage = 8137,
            counterStorage = 8084,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! Your task is to catch 1 Grimer and bring it to me.",
            talk_questFinishing = "Is the task done?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.CATCH_POKEMON,
            questRequest = { "Grimer", 1 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14743, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
        {
            storage = 8138,
            counterStorage = 8084,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! Your task is to catch 1 Gastly and bring it to me.",
            talk_questFinishing = "Is the task done?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.CATCH_POKEMON,
            questRequest = { "Gastly", 1 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14743, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
    },
    -- Vital Mastery
    ["Beau"] = {
        -- Item
        {
            storage = 8080,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! I need you to bring me these items: 9x Box Gloves.",
            talk_questFinishing = "Did you get the items?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 12133, 9 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14744, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
        {
            storage = 8080,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! I need you to bring me these items: 18x Microphone.",
            talk_questFinishing = "Did you get the items?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 12099, 18 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14744, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
        {
            storage = 8080,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! I need you to bring me these items: 3x White Orb.",
            talk_questFinishing = "Did you get the items?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 14516, 3 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14744, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
        {
            storage = 8080,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! I need you to bring me these items: 6x Black Diamond.",
            talk_questFinishing = "Did you get the items?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 14517, 6 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14744, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
    },
    ["Satya"] = {
        -- Defeat
        {
            storage = 8139,
            counterStorage = 8082,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! Your task is to defeat 30 Machamp.",
            talk_questFinishing = "Is the task done?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.DEFEAT_POKEMON,
            questRequest = { "Machamp", 30 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14744, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
        {
            storage = 8140,
            counterStorage = 8082,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! Your task is to defeat 30 Wigglytuff.",
            talk_questFinishing = "Is the task done?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.DEFEAT_POKEMON,
            questRequest = { "Wigglytuff", 30 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14744, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
        {
            storage = 8141,
            counterStorage = 8082,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! Your task is to defeat 30 Clefable.",
            talk_questFinishing = "Is the task done?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.DEFEAT_POKEMON,
            questRequest = { "Clefable", 30 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14744, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
        {
            storage = 8142,
            counterStorage = 8082,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! Your task is to defeat 30 Persian.",
            talk_questFinishing = "Is the task done?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.DEFEAT_POKEMON,
            questRequest = { "Persian", 30 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14744, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
        {
            storage = 8143,
            counterStorage = 8082,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! Your task is to defeat 30 Primeape.",
            talk_questFinishing = "Is the task done?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.DEFEAT_POKEMON,
            questRequest = { "Primeape", 30 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14744, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
        {
            storage = 8144,
            counterStorage = 8082,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! Your task is to defeat 30 Arbok.",
            talk_questFinishing = "Is the task done?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.DEFEAT_POKEMON,
            questRequest = { "Arbok", 30 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14744, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
        {
            storage = 8145,
            counterStorage = 8082,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! Your task is to defeat 30 Venomoth.",
            talk_questFinishing = "Is the task done?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.DEFEAT_POKEMON,
            questRequest = { "Venomoth", 30 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14744, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
        {
            storage = 8146,
            counterStorage = 8082,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! Your task is to defeat 30 Muk.",
            talk_questFinishing = "Is the task done?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.DEFEAT_POKEMON,
            questRequest = { "Muk", 30 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14744, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
        {
            storage = 8147,
            counterStorage = 8082,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! Your task is to defeat 30 Gengar.",
            talk_questFinishing = "Is the task done?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.DEFEAT_POKEMON,
            questRequest = { "Gengar", 30 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14744, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
        {
            storage = 8148,
            counterStorage = 8082,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! Your task is to defeat 30 Pidgeot.",
            talk_questFinishing = "Is the task done?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.DEFEAT_POKEMON,
            questRequest = { "Pidgeot", 30 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14744, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
        {
            storage = 8149,
            counterStorage = 8082,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! Your task is to defeat 30 Fearow.",
            talk_questFinishing = "Is the task done?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.DEFEAT_POKEMON,
            questRequest = { "Fearow", 30 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14744, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
    },
    ["Samira"] = {
        -- Catch
        {
            storage = 8150,
            counterStorage = 8084,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! Your task is to catch 1 Machop and bring it to me.",
            talk_questFinishing = "Is the task done?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.CATCH_POKEMON,
            questRequest = { "Machop", 1 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14744, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
        {
            storage = 8151,
            counterStorage = 8084,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! Your task is to catch 2 Mankey and bring them to me.",
            talk_questFinishing = "Is the task done?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.CATCH_POKEMON,
            questRequest = { "Mankey", 2 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14744, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
        {
            storage = 8152,
            counterStorage = 8084,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! Your task is to catch 1 Clefairy and bring it to me.",
            talk_questFinishing = "Is the task done?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.CATCH_POKEMON,
            questRequest = { "Clefairy", 1 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14744, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
        {
            storage = 8153,
            counterStorage = 8084,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! Your task is to catch 1 Jigglypuff and bring it to me.",
            talk_questFinishing = "Is the task done?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.CATCH_POKEMON,
            questRequest = { "Jigglypuff", 1 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14744, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
    },
    -- Gaia Mastery
    ["Jett"] = {
        -- Item
        {
            storage = 8080,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! I need you to bring me these items: 30x Leaves.",
            talk_questFinishing = "Did you get the items?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 12091, 30 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14745, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
        {
            storage = 8080,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! I need you to bring me these items: 15x Bulb.",
            talk_questFinishing = "Did you get the items?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 12090, 15 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14745, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
        {
            storage = 8080,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! I need you to bring me these items: 38x Pot of Moss Mug.",
            talk_questFinishing = "Did you get the items?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 12113, 38 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14745, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
        {
            storage = 8080,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! I need you to bring me these items: 14x Sample of Sand Wasp Honey.",
            talk_questFinishing = "Did you get the items?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 14503, 14 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14745, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
    },
    ["Gerry"] = {
        -- Defeat
        {
            storage = 8154,
            counterStorage = 8082,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! Your task is to defeat 30 Machamp.",
            talk_questFinishing = "Is the task done?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.DEFEAT_POKEMON,
            questRequest = { "Machamp", 30 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14745, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
        {
            storage = 8155,
            counterStorage = 8082,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! Your task is to defeat 30 Primeape.",
            talk_questFinishing = "Is the task done?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.DEFEAT_POKEMON,
            questRequest = { "Primeape", 30 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14745, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
        {
            storage = 8156,
            counterStorage = 8082,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! Your task is to defeat 30 Arbok.",
            talk_questFinishing = "Is the task done?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.DEFEAT_POKEMON,
            questRequest = { "Arbok", 30 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14745, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
        {
            storage = 8157,
            counterStorage = 8082,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! Your task is to defeat 30 Venomoth.",
            talk_questFinishing = "Is the task done?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.DEFEAT_POKEMON,
            questRequest = { "Venomoth", 30 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14745, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
        {
            storage = 8158,
            counterStorage = 8082,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! Your task is to defeat 30 Muk.",
            talk_questFinishing = "Is the task done?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.DEFEAT_POKEMON,
            questRequest = { "Muk", 30 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14745, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
        {
            storage = 8159,
            counterStorage = 8082,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! Your task is to defeat 30 Gengar.",
            talk_questFinishing = "Is the task done?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.DEFEAT_POKEMON,
            questRequest = { "Gengar", 30 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14745, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
        {
            storage = 8160,
            counterStorage = 8082,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! Your task is to defeat 30 Pidgeot.",
            talk_questFinishing = "Is the task done?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.DEFEAT_POKEMON,
            questRequest = { "Pidgeot", 30 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14745, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
        {
            storage = 8161,
            counterStorage = 8082,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! Your task is to defeat 30 Fearow.",
            talk_questFinishing = "Is the task done?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.DEFEAT_POKEMON,
            questRequest = { "Fearow", 30 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14745, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
        {
            storage = 8162,
            counterStorage = 8082,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! Your task is to defeat 30 Charizard.",
            talk_questFinishing = "Is the task done?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.DEFEAT_POKEMON,
            questRequest = { "Charizard", 30 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14745, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
        {
            storage = 8163,
            counterStorage = 8082,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! Your task is to defeat 30 Ninetales.",
            talk_questFinishing = "Is the task done?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.DEFEAT_POKEMON,
            questRequest = { "Ninetales", 30 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14745, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
        {
            storage = 8164,
            counterStorage = 8082,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! Your task is to defeat 30 Arcanine.",
            talk_questFinishing = "Is the task done?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.DEFEAT_POKEMON,
            questRequest = { "Arcanine", 30 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14745, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
        {
            storage = 8165,
            counterStorage = 8082,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! Your task is to defeat 30 Rapidash.",
            talk_questFinishing = "Is the task done?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.DEFEAT_POKEMON,
            questRequest = { "Rapidash", 30 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14745, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
    },
    ["Harley"] = {
        -- Catch
        {
            storage = 8166,
            counterStorage = 8084,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! Your task is to catch 1 Bulbasaur and bring it to me.",
            talk_questFinishing = "Is the task done?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.CATCH_POKEMON,
            questRequest = { "Bulbasaur", 1 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14745, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
        {
            storage = 8167,
            counterStorage = 8084,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! Your task is to catch 3 Caterpie and bring them to me.",
            talk_questFinishing = "Is the task done?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.CATCH_POKEMON,
            questRequest = { "Caterpie", 3 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14745, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
        {
            storage = 8168,
            counterStorage = 8084,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! Your task is to catch 3 Weedle and bring them to me.",
            talk_questFinishing = "Is the task done?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.CATCH_POKEMON,
            questRequest = { "Weedle", 3 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14745, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
        {
            storage = 8169,
            counterStorage = 8084,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! Your task is to catch 2 Oddish and bring them to me.",
            talk_questFinishing = "Is the task done?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.CATCH_POKEMON,
            questRequest = { "Oddish", 2 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14745, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
        {
            storage = 8170,
            counterStorage = 8084,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! Your task is to catch 2 Paras and bring them to me.",
            talk_questFinishing = "Is the task done?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.CATCH_POKEMON,
            questRequest = { "Paras", 2 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14745, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
        {
            storage = 8171,
            counterStorage = 8084,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! Your task is to catch 2 Bellsprout and bring them to me.",
            talk_questFinishing = "Is the task done?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.CATCH_POKEMON,
            questRequest = { "Bellsprout", 2 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14745, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
    },
    -- Mastery Avalanche
    ["Reese"] = {
        -- Item
        {
            storage = 8080,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! I need you to bring me these items: 495x Water Gem.",
            talk_questFinishing = "Did you get the items?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 12100, 495 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14746, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
        {
            storage = 8080,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! I need you to bring me these items: 8x Blastoise Hull.",
            talk_questFinishing = "Did you get the items?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 14509, 8 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14746, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
        {
            storage = 8080,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! I need you to bring me these items: 27x Pot of Water.",
            talk_questFinishing = "Did you get the items?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 14515, 27 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14746, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
        {
            storage = 8080,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! I need you to bring me these items: 14x Shell Bell.",
            talk_questFinishing = "Did you get the items?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 12145, 14 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14746, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
        {
            storage = 8080,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! I need you to bring me these items: 14x Ice Crystal.",
            talk_questFinishing = "Did you get the items?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 14494, 14 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14746, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
    },
    ["Tucker"] = {
        -- Defeat
        {
            storage = 8172,
            counterStorage = 8082,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! Your task is to defeat 30 Blastoise.",
            talk_questFinishing = "Is the task done?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.DEFEAT_POKEMON,
            questRequest = { "Blastoise", 30 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14746, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
        {
            storage = 8173,
            counterStorage = 8082,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! Your task is to defeat 30 Golduck.",
            talk_questFinishing = "Is the task done?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.DEFEAT_POKEMON,
            questRequest = { "Golduck", 30 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14746, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
        {
            storage = 8174,
            counterStorage = 8082,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! Your task is to defeat 30 Dewgong.",
            talk_questFinishing = "Is the task done?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.DEFEAT_POKEMON,
            questRequest = { "Dewgong", 30 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14746, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
        {
            storage = 8175,
            counterStorage = 8082,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! Your task is to defeat 30 Cloyster.",
            talk_questFinishing = "Is the task done?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.DEFEAT_POKEMON,
            questRequest = { "Cloyster", 30 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14746, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
        {
            storage = 8176,
            counterStorage = 8082,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! Your task is to defeat 30 Kingler.",
            talk_questFinishing = "Is the task done?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.DEFEAT_POKEMON,
            questRequest = { "Kingler", 30 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14746, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
        {
            storage = 8177,
            counterStorage = 8082,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! Your task is to defeat 30 Venusaur.",
            talk_questFinishing = "Is the task done?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.DEFEAT_POKEMON,
            questRequest = { "Venusaur", 30 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14746, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
        {
            storage = 8178,
            counterStorage = 8082,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! Your task is to defeat 30 Vileplume.",
            talk_questFinishing = "Is the task done?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.DEFEAT_POKEMON,
            questRequest = { "Vileplume", 30 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14746, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
        {
            storage = 8179,
            counterStorage = 8082,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! Your task is to defeat 30 Victreebel.",
            talk_questFinishing = "Is the task done?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.DEFEAT_POKEMON,
            questRequest = { "Victreebel", 30 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14746, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
    },
    ["Xyler"] = {
        -- Catch
        {
            storage = 8180,
            counterStorage = 8084,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! Your task is to catch 1 Squirtle and bring it to me.",
            talk_questFinishing = "Is the task done?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.CATCH_POKEMON,
            questRequest = { "Squirtle", 1 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14746, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
        {
            storage = 8181,
            counterStorage = 8084,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! Your task is to catch 1 Psyduck and bring it to me.",
            talk_questFinishing = "Is the task done?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.CATCH_POKEMON,
            questRequest = { "Psyduck", 1 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14746, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
        {
            storage = 8182,
            counterStorage = 8084,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! Your task is to catch 2 Poliwag and bring them to me.",
            talk_questFinishing = "Is the task done?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.CATCH_POKEMON,
            questRequest = { "Poliwag", 2 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14746, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
        {
            storage = 8183,
            counterStorage = 8084,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! Your task is to catch 1 Seel and bring it to me.",
            talk_questFinishing = "Is the task done?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.CATCH_POKEMON,
            questRequest = { "Seel", 1 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14746, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
        {
            storage = 8184,
            counterStorage = 8084,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! Your task is to catch 2 Horsea and bring them to me.",
            talk_questFinishing = "Is the task done?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.CATCH_POKEMON,
            questRequest = { "Horsea", 2 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14746, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
    },
    -- Heremit Mastery
    ["Rukia"] = {
        -- Item
        {
            storage = 8080,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! I need you to bring me these items: 21x Stone Orb.",
            talk_questFinishing = "Did you get the items?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 12138, 21 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14747, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
        {
            storage = 8080,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! I need you to bring me these items: 11x Heavy Stone.",
            talk_questFinishing = "Did you get the items?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 14492, 11 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14747, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
        {
            storage = 8080,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! I need you to bring me these items: 20x Shadow Rock.",
            talk_questFinishing = "Did you get the items?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 14505, 20 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14747, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
        {
            storage = 8080,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! I need you to bring me these items: 6x Piece of Onix.",
            talk_questFinishing = "Did you get the items?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 12147, 6 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14747, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
    },
    ["Susie"] = {
        -- Defeat
        {
            storage = 8185,
            counterStorage = 8082,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! Your task is to defeat 30 Sandslash.",
            talk_questFinishing = "Is the task done?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.DEFEAT_POKEMON,
            questRequest = { "Sandslash", 30 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14747, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
        {
            storage = 8186,
            counterStorage = 8082,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! Your task is to defeat 30 Dugtrio.",
            talk_questFinishing = "Is the task done?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.DEFEAT_POKEMON,
            questRequest = { "Dugtrio", 30 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14747, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
        {
            storage = 8187,
            counterStorage = 8082,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! Your task is to defeat 30 Golem.",
            talk_questFinishing = "Is the task done?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.DEFEAT_POKEMON,
            questRequest = { "Golem", 30 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14747, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
        {
            storage = 8188,
            counterStorage = 8082,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! Your task is to defeat 30 Onix.",
            talk_questFinishing = "Is the task done?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.DEFEAT_POKEMON,
            questRequest = { "Onix", 30 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14747, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
        {
            storage = 8189,
            counterStorage = 8082,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! Your task is to defeat 30 Marowak.",
            talk_questFinishing = "Is the task done?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.DEFEAT_POKEMON,
            questRequest = { "Marowak", 30 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14747, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
        {
            storage = 8190,
            counterStorage = 8082,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! Your task is to defeat 30 Machamp.",
            talk_questFinishing = "Is the task done?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.DEFEAT_POKEMON,
            questRequest = { "Machamp", 30 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14747, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
        {
            storage = 8191,
            counterStorage = 8082,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! Your task is to defeat 30 Primeape.",
            talk_questFinishing = "Is the task done?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.DEFEAT_POKEMON,
            questRequest = { "Primeape", 30 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14747, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
    },
    ["Demetrius"] = {
        -- Catch
        {
            storage = 8192,
            counterStorage = 8084,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! Your task is to catch 1 Sandshrew and bring it to me.",
            talk_questFinishing = "Is the task done?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.CATCH_POKEMON,
            questRequest = { "Sandshrew", 1 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14747, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
        {
            storage = 8193,
            counterStorage = 8084,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! Your task is to catch 2 Diglett and bring them to me.",
            talk_questFinishing = "Is the task done?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.CATCH_POKEMON,
            questRequest = { "Diglett", 2 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14747, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
        {
            storage = 8194,
            counterStorage = 8084,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! Your task is to catch 1 Geodude and bring it to me.",
            talk_questFinishing = "Is the task done?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.CATCH_POKEMON,
            questRequest = { "Geodude", 1 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14747, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
        {
            storage = 8195,
            counterStorage = 8084,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! Your task is to catch 1 Cubone and bring it to me.",
            talk_questFinishing = "Is the task done?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.CATCH_POKEMON,
            questRequest = { "Cubone", 1 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14747, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
    },
    -- Zen Mastery
    ["Mikko"] = {
        -- Item
        {
            storage = 8080,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! I need you to bring me these items: 45x Twisted Spoon.",
            talk_questFinishing = "Did you get the items?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 12135, 45 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14748, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
        {
            storage = 8080,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! I need you to bring me these items: 30x Night Orb.",
            talk_questFinishing = "Did you get the items?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 14512, 30 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14748, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
        {
            storage = 8080,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! I need you to bring me these items: 14x linearly guided hypnose pendant.",
            talk_questFinishing = "Did you get the items?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 12148, 14 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14748, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
    },
    ["Ozy"] = {
        -- Defeat
        {
            storage = 8195,
            counterStorage = 8082,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! Your task is to defeat 30 Raichu.",
            talk_questFinishing = "Is the task done?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.DEFEAT_POKEMON,
            questRequest = { "Raichu", 30 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14748, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
        {
            storage = 8196,
            counterStorage = 8082,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! Your task is to defeat 30 Magneton.",
            talk_questFinishing = "Is the task done?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.DEFEAT_POKEMON,
            questRequest = { "Magneton", 30 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14748, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
        {
            storage = 8197,
            counterStorage = 8082,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! Your task is to defeat 30 Electrode.",
            talk_questFinishing = "Is the task done?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.DEFEAT_POKEMON,
            questRequest = { "Electrode", 30 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14748, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
        {
            storage = 8198,
            counterStorage = 8082,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! Your task is to defeat 15 Electabuzz.",
            talk_questFinishing = "Is the task done?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.DEFEAT_POKEMON,
            questRequest = { "Electabuzz", 15 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14748, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
    },
    ["Rakin"] = {
        -- Catch
        {
            storage = 8199,
            counterStorage = 8084,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! Your task is to catch 1 Drowzee and bring it to me.",
            talk_questFinishing = "Is the task done?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.CATCH_POKEMON,
            questRequest = { "Drowzee", 1 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14748, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
        {
            storage = 8200,
            counterStorage = 8084,
            talk_questStarting = "Do you want to help me with a task?",
            talk_questStarted = "Thanks! Your task is to catch 1 Abra and bring it to me.",
            talk_questFinishing = "Is the task done?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.CATCH_POKEMON,
            questRequest = { "Abra", 1 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14748, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            daily = true
        },
    },
    -- storage 8201 reserved to chansey quest refund
    -- storage 8202 reserved to hitmonlee/hitmonchan quest refund 8023
    -- storage 8203 reserved to porygon/ditto/mr.mime quest refund 8016
    -- storage 8204 used in Prof Oak quest up there
    -- storage 8206 used in Prof Oak quest up there
    ["Runford"] = {
        {
            storage = 8207,
            talk_questStarting = "Oh wonderful! You want to go there?",
            talk_questStarted = "Cool buddy, I hope you have fun there! But first, I guess you already have a map, right? No...? I think Pistachio has one. Can you get it from him? Go after that crazy old guy. But watch out! He bites!",
            talk_questFinishing = "Do you have the map?",
            talk_questFinished = "Great! Good luck on your adventure! I think Professor Oak is looking for you.",
            talk_questFinishFail = "No, you don't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.CUSTOM,
            questRequest = function(cid) return getPlayerItemCount(cid, 18202) > 0 or getCreatureStorage(cid, 8353) == QUEST_STATUS.FINISHED end,
            rewardItems = {},
            rewardExp = 0,
            requiredLevel = 70,
            canStart = function(cid) return getCreatureStorage(cid, 8343) == QUEST_STATUS.FINISHED end
        },
    },
    ["Pistachio"] = {
        {
            storage = 8208,
            talk_questStarting = "I need some items for my experiments, would you like to help me? If you don't help me, you will never have the map! MUAHAHAHAHA!",
            talk_questStarted = "I need 1x Burning Heart and 1x Frozen Heart.",
            talk_questFinishing = "Have you got what I asked for?",
            talk_questFinished = "Great! But I need your help again with my {tasks}.",
            talk_questFinishFail = "No!",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 14471, 1, 14488, 1 },
            rewardItems = {},
            rewardExp = 0,
            requiredLevel = 70,
            canStart = function(cid) return getCreatureStorage(cid, 8207) == QUEST_STATUS.STARTED end
        },
        {
            storage = 8209,
            talk_questStarting = "Will you help me again?",
            talk_questStarted = "This time I'll need 1x Blastoise Hull and 1x Colourful Feather. Come on, hurry up.",
            talk_questFinishing = "So you brought the items I asked for?",
            talk_questFinished = "Yup! Perfect! But the tasks are not over yet, I need more things.",
            talk_questFinishFail = "No!",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 14509, 1, 14472, 1 },
            rewardItems = {},
            rewardExp = 0,
            requiredLevel = 70,
            canStart = function(cid) return getCreatureStorage(cid, 8207) == QUEST_STATUS.STARTED end
        },
        {
            storage = 8210,
            talk_questStarting = "I need more stuff, will you keep helping me?",
            talk_questStarted = "Bring me 1x Petrified Scream and 1x Black Diamond. Remember that if you do not bring me the items, you will never have the map! Muahaha!",
            talk_questFinishing = "So you brought the items I asked for?",
            talk_questFinished = "Wow! You're pretty good! But I'll ask you one last favor.",
            talk_questFinishFail = "No!",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 14499, 1, 14517, 1 },
            rewardItems = {},
            rewardExp = 0,
            requiredLevel = 70,
            canStart = function(cid) return getCreatureStorage(cid, 8207) == QUEST_STATUS.STARTED end
        },
        {
            storage = 8211,
            talk_questStarting = "I'll ask one last favor, okay?",
            talk_questStarted = "You will need to bring me 1x Pincer Horn and 1x Scyther Razor.",
            talk_questFinishing = "So you brought the items I asked for?",
            talk_questFinished = "Wow! You're pretty good! You thought that was the last job? Muahahaha! I still have one more.",
            talk_questFinishFail = "No!",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 12084, 1, 12108, 1 },
            rewardItems = {},
            rewardExp = 0,
            requiredLevel = 70,
            canStart = function(cid) return getCreatureStorage(cid, 8207) == QUEST_STATUS.STARTED end
        },
        {
            storage = 8212,
            talk_questStarting = "Want to continue?",
            talk_questStarted = "For this last task, bring me 1x Box Gloves and 1x Yellow Tail.",
            talk_questFinishing = "So you brought the items I asked for?",
            talk_questFinished = "Thank you! I'm very glad you brought me all of these items. You know what I'm gonna do with them? Absolutely NOTHING! Muahahaha! Here, here's your map.",
            talk_questFinishFail = "No!",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 12133, 1, 12110, 1 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 18202, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 70,
            canStart = function(cid) return getCreatureStorage(cid, 8207) == QUEST_STATUS.STARTED end
        },
    },
    -- storage 8213 used in Prof Oak quest up there
    ["Professor Ivy"] = {
        {
            storage = 8231,
            talk_questStarting = "I would give you a GS Ball, but it was stolen by an Aipom! Unfortunately no one can reach him. My friend Bill is preparing a bait to attract the Aipom. Please go to him and get the bait.",
            talk_questStarted = "Contact Bill in Kanto, he can help us! I don't want to hurt the Aipom, but we need this Pokeball. Take this net to use when you trap the Aipom.",
            talk_questFinishing = "Did you find the GS Ball?",
            talk_questFinished = "Great, now you can deliver it to Professor Oak.",
            talk_questFinishFail = "No, you don't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.CUSTOM,
            questRequest = function(cid) return getPlayerItemCount(cid, 18159) > 0 or getCreatureStorage(cid, 8213) == QUEST_STATUS.FINISHED end, -- The storage will ocurr when the player delivery the GS ball to Oak before talk with Ivy
            rewardItems = {},
            rewardExp = 0,
            requiredLevel = 70,
            questStartItems = { 18321, 1 },
            canStart = function(cid) return getCreatureStorage(cid, 8213) ~= QUEST_STATUS.UNSTARTED end
        },
        {
            storage = 8214,
            talk_questStarting = "Cool! Here in my lab we do research, including developing new rations to feed Pokemon. I recently discovered that a plant native to Tangelo Island, the Tangel Rue, may have a property that helps newborn Pokemon develop better. Can you bring me some of its leaves?",
            talk_questStarted = "Great, I hope you return successfully!",
            talk_questFinishing = "Did you find the plant?",
            talk_questFinished = "Thank you! But we have a small {problem}.",
            talk_questFinishFail = "No, you don't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.CUSTOM,
            questRequest = function(cid) return getPlayerItemCount(cid, 18246) >= 1 end,
            rewardItems = {},
            rewardExp = 0,
            requiredLevel = 70,
            canStart = function(cid) return getCreatureStorage(cid, 8231) == QUEST_STATUS.FINISHED and
                    getCreatureStorage(cid, 8213) == QUEST_STATUS.FINISHED
            end
        },
        {
            storage = 8215,
            talk_questStarting = "I can not use plants in research with Pokemon until I have approval from the ECP (Pokemon Ethics Committee), and they are on Mandarin Island. Do this: take the plant there so they can catalog it in their database, and extract the plant essence for me. Can you do it?",
            talk_questStarted = "Good luck finding them!",
            talk_questFinishing = "Did you bring my extract?",
            talk_questFinished = "Great! Now I need some time to finish the formula and produce the feed. Do not go away, I still need your {help}!",
            talk_questFinishFail = "No, you don't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 18245, 1 },
            rewardItems = {},
            rewardExp = 0,
            requiredLevel = 70,
            onEnd = function(cid) doCreatureSetStorage(cid, 8293, os.time()) end,
            canStart = function(cid) return getCreatureStorage(cid, 8214) == QUEST_STATUS.FINISHED end
        },
        {
            storage = 8218,
            talk_questStarting = "I finished the formula! Take these cookies and try feeding them to some Pokemon for me! Can you...?",
            talk_questStarted = "Use the cookies on these young Pokemon: Paras, Butterfree, Vileplume, Raticate, Spinarak and Bellossom.",
            talk_questFinishing = "Did you test the cookies?",
            talk_questFinished = "Great! You have helped me a lot, thanks. You remind me of a kid who came here three years ago, a magnificent trainer... where is he now? Don't think this is the last time I'll need your help! My assistants want to talk to you. Go, and good luck.",
            talk_questFinishFail = "No, you don't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.CUSTOM,
            questRequest = function(cid)
                local storages = { 8233, 8234, 8235, 8236, 8237, 8238 }
                for _, storage in pairs(storages) do
                    if (getCreatureStorage(cid, storage) ~= QUEST_STATUS.FINISHED) then
                        return false
                    end
                end
                return true
            end,
            canStart = function(cid)
                if (getCreatureStorage(cid, 8215) ~= QUEST_STATUS.FINISHED) then
                    return false
                end

                local diff = (getCreatureStorage(cid, 8293) + (60 * 60) - os.time())
                if (diff > 0) then
                    selfSay(string.format(__L(cid, "You must wait %s to continue."), table.concat(string.timediff(diff, cid))), cid)
                    return false
                end
                return true
            end,
            rewardItems = {},
            rewardExp = 0,
            requiredLevel = 70,
            questStartItems = { 18164, 6 }
        },
    },
    ["Albert"] = {
        {
            storage = 8216,
            talk_questStarting = "Oh, Ivy told me you were bringing a new plant, let me see it. Hmmm... it has unique characteristics. Could you buy a flask for me at the Poke Mart?",
            talk_questStarted = "Ok, I'll be waiting.",
            talk_questFinishing = "Have you got the flask?",
            talk_questFinished = "Thanks for the flask. Come back in 30 minutes, I will have finished the {extraction} process.",
            talk_questFinishFail = "No, you don't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 18246, 1, 18163, 1 },
            rewardItems = {},
            rewardExp = 0,
            requiredLevel = 70,
            onEnd = function(cid) doCreatureSetStorage(cid, 8217, os.time()) end,
            canStart = function(cid) return getCreatureStorage(cid, 8215) == QUEST_STATUS.STARTED end
        },
    },
    -- storage 8217 used in Albert flask waiting time
    -- storage 8219 used in Misty incubator egg
    ["Charity"] = {
        {
            storage = 8220,
            talk_questStarting = "You're so beautif... I mean, can you do me a personal favor? I always wanted a Sunkern to help me fertilize our lands, can you catch one for me?",
            talk_questStarted = "Thanks and good luck!",
            talk_questFinishing = "Did you catch a Sunkern for me?",
            talk_questFinished = "Thank you! You're so beautiful! Go see my other sisters!",
            talk_questFinishFail = "No, you don't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.BRING_POKEMON,
            questRequest = "Sunkern",
            rewardItems = {},
            rewardExp = 0,
            requiredLevel = 70,
            canStart = function(cid) return getCreatureStorage(cid, 8218) == QUEST_STATUS.FINISHED end
        },
    },
    ["Hope"] = {
        {
            storage = 8221,
            talk_questStarting = "We have a problem right here in the lab... the roof. Could you ask Sir John to fix it for us? Be careful, he's kinda grumpy.",
            talk_questStarted = "Thanks and good luck!",
            talk_questFinishing = "Did you manage to talk with Sir John?",
            talk_questFinished = "Thank you!",
            talk_questFinishFail = "No, you don't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.CUSTOM,
            questRequest = function(cid) return getCreatureStorage(cid, 8222) == QUEST_STATUS.FINISHED end,
            rewardItems = {},
            rewardExp = 0,
            requiredLevel = 70,
            canStart = function(cid) return getCreatureStorage(cid, 8220) == QUEST_STATUS.FINISHED end
        },
    },
    ["Sir John"] = {
        {
            storage = 8222,
            talk_questStarting = "Those girls broke the roof again? Argh! I won't fix it for free this time, you will help me with something. {Yes} or {no}?",
            talk_questStarted = "Great, I need: 20x Piece of Royal Steel, 10x Ruby, 10x Cure Herb and 10x Pot of Water.",
            talk_questFinishing = "Got everything, brat? I don't want excuses...",
            talk_questFinished = "Great, now I need you to do one more {task} for me.",
            talk_questFinishFail = "No, you don't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 14500, 20, 12130, 10, 17802, 10, 14515, 10 },
            rewardItems = {},
            rewardExp = 0,
            requiredLevel = 70,
            canStart = function(cid) return getCreatureStorage(cid, 8221) == QUEST_STATUS.STARTED end
        },
        {
            storage = 8223,
            talk_questStarting = "Will you help me with one more task?",
            talk_questStarted = "Go buy a toolbox for me on Pummelo Island.",
            talk_questFinishing = "Did you get the toolbox for me?",
            talk_questFinished = "I will repair the roof as soon as possible, thanks.",
            talk_questFinishFail = "No, you don't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 18165, 1 },
            rewardItems = {},
            rewardExp = 0,
            requiredLevel = 70,
            canStart = function(cid) return getCreatureStorage(cid, 8222) == QUEST_STATUS.FINISHED end
        },
    },
    ["Faith"] = {
        {
            storage = 8224,
            talk_questStarting = "Can you buy a crystal statue for me?",
            talk_questStarted = "Thank you, I just love how beautiful they are.",
            talk_questFinishing = "Did you get the crystal statue?",
            talk_questFinished = "Thank you! Do not forget that Mateo wants to talk to you.",
            talk_questFinishFail = "No, you don't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 18166, 1 },
            rewardItems = {},
            rewardExp = 0,
            requiredLevel = 70,
            canStart = function(cid) return getCreatureStorage(cid, 8223) == QUEST_STATUS.FINISHED end,
            onEnd = function(cid)
                setPlayerOrangeArchipelagoAccess(cid, 3)
                doPlayerAchievementCheck(cid, ACHIEVEMENT_IDS.ORANGE_ARCHIPELAGO_MAIN2)
            end
        },
    },
    -- storage 8225 used in Mateo Crystal Statue
    ["Merv Kelley"] = {
        {
            storage = 8226,
            talk_questStarting = "My father, who started this research a long time ago, hid a fruit recipe in a secret place in the Kanto Safari Zone, but I don't know where the secret area is. Do you want to look for that recipe for me?",
            talk_questStarted = "Go carefully, I heard that there are many strong Pokemon around this recipe, I recommend you do not go alone.",
            talk_questFinishing = "Did you find the secret recipe?",
            talk_questFinished = "Great, you got the recipe! Now with it I can produce enough seeds to complete the study my father started. I'm just a bit puzzled by the {ingredients}.",
            talk_questFinishFail = "No, you don't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 18167, 1 },
            rewardItems = {},
            rewardExp = 0,
            requiredLevel = 70,
            canStart = function(cid) return getCreatureStorage(cid, 8224) == QUEST_STATUS.FINISHED end
        },
        {
            storage = 8227,
            talk_questStarting = "I have most of the ingredients, but three will be hard for me to get because they're on other islands, and I can't leave here, I need to continue my study. Would you like to help me get the three remaining ingredients?",
            talk_questStarted = "Well, the remaining ingredients come from three ancient trees in the Orange Archipelago. These trees are famous for their delicious fruit and have lived for a very long time. Your first mission is to bring the Lichi fruit, found on the Wayne family land north of Ascorbia Island.",
            talk_questFinishing = "Did you find the Lichi fruit?",
            talk_questFinished = "Very good, now I need the {second} fruit.",
            talk_questFinishFail = "No, you don't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 18168, 1 },
            rewardItems = {},
            rewardExp = 0,
            requiredLevel = 70,
            canStart = function(cid) return getCreatureStorage(cid, 8226) == QUEST_STATUS.FINISHED end
        },
        {
            storage = 8228,
            talk_questStarting = "Now I need the second fruit, will you help me?",
            talk_questStarted = "Your second mission is to go to the square in the center of the Mikan Island and bring the Orenji fruit.",
            talk_questFinishing = "Did you find the Orenji fruit?",
            talk_questFinished = "Wow, you got it! Now there's only one {fruit} remaining.",
            talk_questFinishFail = "No, you don't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 18169, 1 },
            rewardItems = {},
            rewardExp = 0,
            requiredLevel = 70,
            canStart = function(cid) return getCreatureStorage(cid, 8227) == QUEST_STATUS.FINISHED end
        },
        {
            storage = 8229,
            talk_questStarting = "Will you help me find the last fruit?",
            talk_questStarted = "Your third mission is to find the tree that bears the Wampi fruit. No one knows for sure where this tree is. Many people tell stories about this fruit: some say it is the best fruit they ever ate, others say a Pokemon that eats it becomes invincible. If you bring me this fruit, I will be able to finish my study. I'm counting on you.",
            talk_questFinishing = "Did you find the Wampi fruit?",
            talk_questFinished = "THANK YOU! Now I'll finally be able to finish my studies.",
            talk_questFinishFail = "No, you don't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 18171, 1 },
            rewardItems = {},
            rewardExp = 0,
            requiredLevel = 70,
            canStart = function(cid) return getCreatureStorage(cid, 8228) == QUEST_STATUS.FINISHED end,
            onEnd = function(cid)
                setPlayerOrangeArchipelagoAccess(cid, 4)
                doPlayerAchievementCheck(cid, ACHIEVEMENT_IDS.ORANGE_ARCHIPELAGO_MAIN3)
            end
        },
    },
    ["Jeana Maxene"] = {
        {
            storage = 8230,
            talk_questStarting = "Oh! So you are interested in Lichi fruit. I can give you one, but I see that you are a Pokemon trainer and I dream of being one too. Would you like an exchange?",
            talk_questStarted = "Bring me a Heracross and in return I will give you the Lichi fruit.",
            talk_questFinishing = "Yup! Did you bring me the Heracross?",
            talk_questFinished = "Thank you, I'm so glad you brought me this wonderful Heracross! Here is the Lichi fruit.",
            talk_questFinishFail = "No, you don't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.BRING_POKEMON,
            questRequest = "Heracross",
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 18168, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 70,
            canStart = function(cid) return getCreatureStorage(cid, 8227) == QUEST_STATUS.STARTED end
        },
    },
    -- storage 8231 used in Professor Ivy quest, up
    -- storage 8232 used in Bill banana check
    -- storage 8233-8238 used in Young's NPCs quests
    -- storage 8239 in Wampi Tree fruit
    ["Adventurer Lucy"] = {
        {
            storage = 8240,
            talk_questStarting = "I have three clues about where the stone of prophecy is. Will you help me look?",
            talk_questStarted = "It may be on Golden or Butwal Island. Thanks buddy, pay close attention to where you go!",
            talk_questFinishing = "Did you find something about the prophecy?",
            talk_questFinished = "My goodness! What a wonderful thing... it speaks of an {elder}?",
            talk_questFinishFail = "No, you don't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.CUSTOM,
            questRequest = function(cid) return getCreatureStorage(cid, 8241) == QUEST_STATUS.FINISHED end,
            rewardItems = {},
            rewardExp = 0,
            requiredLevel = 70,
        },
    },
    -- storage 8241 in Prophecy Slab Stone
    ["Prophet Slowking"] = {
        {
            storage = 8242,
            talk_questStarting = "Yes, I'm the elder. Long ago I made this prophecy, even before the three kings were born. Are you ready for this journey?",
            talk_questStarted = "You need to help the three tribes restore the balance that is breaking. They are not far from my house. First go to the Sea Tribe and ask their Chief about the 'Deepsoul Stone'.",
            talk_questFinishing = "Did you find Chief Vaporeon and get the restore stones?",
            talk_questFinished = "Great! Now we are entering a dangerous stage!",
            talk_questFinishFail = "No, you don't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.CUSTOM,
            questRequest = function(cid) return getCreatureStorage(cid, 8243) == QUEST_STATUS.FINISHED end,
            rewardItems = {},
            rewardExp = 174350,
            requiredLevel = 70,
            onEnd = function(cid)
                setPlayerOrangeArchipelagoAccess(cid, 5)
                doPlayerAchievementCheck(cid, ACHIEVEMENT_IDS.ORANGE_ARCHIPELAGO_MAIN4)
            end
        },
        {
            storage = 8368,
            talk_questStarting = "Great, you have reached an important stage of your adventure. From now on there is no turning back... ",
            talk_questStarted = "The Deepsoul Stone was recently removed from its original location and is now guarded by a large Pokemon. You need to go after a new treasure to reach it. Go talk to your professor, he is already aware of the situation. Then come back to me. Good luck!",
            talk_questFinishing = "Did you find the Deepsoul Stone?",
            talk_questFinished = "Thank you trainer. For now our mission is accomplished. Enjoy a period of peace, and be sure to talk with your professor. What reward do you want? Your options are: {Dragon Scale}, {King's Rock} or {Metal Coat}.",
            talk_questFinishFail = "No, you don't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 18173, 1 },
            rewardItems = {},
            rewardExp = 174350,
            requiredLevel = 100,
            onEnd = function(cid)
                setPlayerOrangeArchipelagoAccess(cid, 6)
                doPlayerAchievementCheck(cid, ACHIEVEMENT_IDS.ORANGE_ARCHIPELAGO_MAIN5)
                doProphetSlowkingEffect()
            end
        },
    },
    ["Chief Vaporeon"] = {
        {
            storage = 8243,
            talk_questStarting = "We know the stone is weakening VAPPPOR and we are thinking of a way VAPPORE to strengthen its protection. Meanwhile... you could help us! Do you agree?",
            talk_questStarted = "Great. We need two other Stones called Restore Stones. VAPOREONN They will help disperse the evil that weighs on the Deepsoul Stone. Go talk to the other VAPPOR two {Chiefs} and find out where the Restore Stones are. Come back here later.",
            talk_questFinishing = "Did you get REONN the Restore Stones?",
            talk_questFinished = "Great, now we need to talk to VAPPOREON the elder. Thanks for VAPP your help.",
            talk_questFinishFail = "No, you don't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.CUSTOM,
            questRequest = function(cid) return getPlayerItemCount(cid, 18172) >= 2 end,
            rewardItems = {},
            rewardExp = 0,
            requiredLevel = 70,
        },
    },
    ["Gord Scottie"] = {
        {
            storage = 8244,
            talk_questStarting = "Can you bring me 20 grape fruits?",
            talk_questStarted = "Good luck finding them!",
            talk_questFinishing = "Did you bring what I asked for?",
            talk_questFinished = "I'll keep 10. Go to Curtis Sacheverell and deliver the other 10.",
            talk_questFinishFail = "No, you don't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 18247, 20 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 18247, count = 10, unique = true } },
            rewardExp = 0,
            requiredLevel = 70,
            onEnd = function(cid) doCreatureSetStorage(cid, 8246, QUEST_STATUS.STARTED) end
        },
        {
            storage = 8247,
            talk_questStarting = "",
            talk_questStarted = "",
            talk_questFinishing = "A letter for me?",
            talk_questFinished = "Look, he's apologizing to me! Thanks for everything buddy.",
            talk_questFinishFail = "No, you don't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 18249, 1 },
            rewardItems = {},
            rewardExp = 34870,
            requiredLevel = 70,
            blockStart = true
        },
    },
    ["Queenie Jerrie"] = {
        {
            storage = 8245,
            talk_questStarting = "I have a proposal for you: gather 20 grape flowers for me and in return I will give you grape fruits.",
            talk_questStarted = "They're right there, come back soon.",
            talk_questFinishing = "Did you get the grape flowers?",
            talk_questFinished = "Thanks, here are your fruits.",
            talk_questFinishFail = "No, you don't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 18256, 20 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 18247, count = 20, unique = true } },
            rewardExp = 0,
            requiredLevel = 70,
            onEnd = function(cid) doPlayerRemoveItem(cid, 18256, getPlayerItemCount(cid, 18256)) end
        },
    },
    ["Curtis Sacheverell"] = {
        {
            storage = 8246,
            talk_questStarting = "Hey, have you got something for me?",
            talk_questStarted = "What is it? The 10 grape fruits from Gord Scottie? Bring them to me.",
            talk_questFinishing = "Did you bring me the grape fruits from Gord Scottie?",
            talk_questFinished = "Thanks buddy, I was waiting for them. Please give Gord Scottie this letter.",
            talk_questFinishFail = "No, you don't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 18247, 10 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 18249, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 70,
            onEnd = function(cid) doCreatureSetStorage(cid, 8247, QUEST_STATUS.STARTED) end,
            blockStart = true
        },
    },
    -- storage 8247 in Gord Scottie quest #2
    ["Juanito Cruz"] = {
        {
            storage = 8248,
            talk_questStarting = "Will you help me find a reason to live?",
            talk_questStarted = "I need a new reason to live... maybe a new person. Tereza is a great person... could you talk to her for me?",
            talk_questFinishing = "Did you find me a reason to live?",
            talk_questFinished = "Thanks, here, take this gift.",
            talk_questFinishFail = "No, you don't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.CUSTOM,
            questRequest = function(cid) return getCreatureStorage(cid, 8249) == QUEST_STATUS.FINISHED end,
            rewardItems = {},
            rewardExp = 0,
            requiredLevel = 70,
            canStart = function(cid) return getCreatureStorage(cid, 8345) == QUEST_STATUS.FINISHED end
        },
    },
    ["Tereza Mendes"] = {
        {
            storage = 8249,
            talk_questStarting = "Can you find a lipstick for me?",
            talk_questStarted = "I will be waiting, good luck.",
            talk_questFinishing = "Did you find a lipstick?",
            talk_questFinished = "Thanks, thanks! Now I can meet with Juanito.",
            talk_questFinishFail = "No, you don't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 18181, 1 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 18640, count = 1 } },
            rewardExp = 34870,
            requiredLevel = 70,
            canStart = function(cid) return getCreatureStorage(cid, 8248) == QUEST_STATUS.STARTED end
        },
    },
    ["Pepper Denis"] = {
        {
            storage = 8250,
            talk_questStarting = "Hey man! Ready to play hide and seek?",
            talk_questStarted = "You'll have to find my five friends! They could be anyone in the city! Hahahahahaha! Say 'hidden' to the people you suspect to find them.",
            talk_questFinishing = "Did you find my friends?",
            talk_questFinished = "You are very good! Take this reward.",
            talk_questFinishFail = "No, you don't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.CUSTOM,
            questRequest = function(cid)
                local storages = { 8251, 8252, 8253, 8254, 8255 }
                for _, storage in pairs(storages) do
                    if (getCreatureStorage(cid, storage) ~= QUEST_STATUS.FINISHED) then
                        return false
                    end
                end
                return true
            end,
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 18641, count = 1 } },
            rewardExp = 17435,
            requiredLevel = 70,
        },
    },
    -- storage 8251 - 8255 Pepper Denis hidden and seek NPCs
    ["Tilly Dianna"] = {
        {
            storage = 8256,
            counterStorage = 8257,
            talk_questStarting = "For a few days now I've had this big problem I can't solve. Could you help me stop this plague?",
            talk_questStarted = "Great, I need you to defeat 30 Spinaraks. That should be enough.",
            talk_questFinishing = "Is the task done?",
            talk_questFinished = "Thanks! Here, take it.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.DEFEAT_POKEMON,
            questRequest = { "Spinarak", 30 },
            rewardItems = {--[[TODO: reward]] },
            rewardExp = 17435,
            requiredLevel = 0,
        },
    },
    ["Jewel Annice"] = {
        {
            storage = 8258,
            talk_questStarting = "Oh no! That Team Rocket thief stole my Pokemon! Please defeat him and bring my Pokemon back.",
            talk_questStarted = "Please help...",
            talk_questFinishing = "Did you find my Pokemon???",
            talk_questFinished = "Thank you, I don't know what I would do without him!",
            talk_questFinishFail = "No, you don't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 18284, 1 },
            rewardItems = {--[[TODO: reward]] },
            rewardExp = 34870,
            requiredLevel = 70,
        },
    },
    ["Saruman"] = {
        {
            storage = 8259,
            talk_questStarting = "My Donphan lost his ball while playing around. It could be anywhere. Can you help us find it?",
            talk_questStarted = "Check back soon, the Donphan is getting very depressed.",
            talk_questFinishing = "Did you find my Donphan's ball?",
            talk_questFinished = "Thanks trainer!",
            talk_questFinishFail = "No, you don't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 18188, 1 },
            rewardItems = {--[[TODO: reward]] },
            rewardExp = 17435,
            requiredLevel = 70,
        },
    },
    ["Gollum"] = {
        {
            storage = 8260,
            talk_questStarting = "I was packing my picnic when Pinsir and Ledyba came and ate all my food. Could you help me collect food for the picnic?",
            talk_questStarted = "Bring me 15x Red Apples, 15x Oranges, 15x Blueberries, 15x Melons, 15x Pears and 15x Strawberries.",
            talk_questFinishing = "Did you bring my picnic food?",
            talk_questFinished = "You are very kind, I do not know how to thank you. Take this.",
            talk_questFinishFail = "No, you don't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 2674, 15, 2675, 15, 2677, 15, 2682, 15, 2673, 15, 2680, 15 },
            rewardItems = {--[[TODO: reward]] },
            rewardExp = 17435,
            requiredLevel = 70,
        },
    },
    ["Slash"] = {
        {
            storage = 8261,
            talk_questStarting = "My TV is faulty, could you bring me some items so I can fix it?",
            talk_questStarted = "Bring me 300x Screws and 50x Electrizers. Thanks!",
            talk_questFinishing = "Did you bring me what I asked for?",
            talk_questFinished = "Haha! Thanks buddy!",
            talk_questFinishFail = "No, you don't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 12103, 300, 12118, 50 },
            rewardItems = {--[[TODO: reward]] },
            rewardExp = 17435,
            requiredLevel = 70,
        },
    },
    ["Ernest Upper"] = {
        {
            storage = 8262,
            talk_questStarting = "Thanks for your concern! My Pokemon got lost in the middle of these woods and I need you to find him. I'm tired of yelling, I can't find him. Can you do this for me?",
            talk_questStarted = "Thanks and good luck! Use this Pokeball when you find him.",
            talk_questFinishing = "Did you find my Pokemon?",
            talk_questFinished = "Thank you! You are very brave.",
            talk_questFinishFail = "No, you don't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 18286, 1 },
            rewardItems = {--[[TODO: reward]] },
            rewardExp = 17435,
            requiredLevel = 70,
            questStartItems = { 18285, 1 }
        },
    },
    ["Farmer Steve"] = {
        {
            storage = 8263,
            counterStorage = 8347,
            talk_questStarting = "I need help planting some berries, what do you think?",
            talk_questStarted = "Do the following: plant 5 seeds in my field for me. Here, take these.",
            talk_questFinishing = "Did you plant the seeds?",
            talk_questFinished = "Cool, I'll give you some seeds now. You can come back tomorrow if you want to help me again.",
            talk_questFinishFail = "No, you don't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.CUSTOM,
            questRequest = function(cid) return getCreatureStorage(cid, 8347) >= 5 end,
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 18638, count = 1 } },
            rewardExp = 0,
            requiredLevel = 70,
            daily = true,
            questStartItems = { 18287, 5 }
        },
    },
    ["Raymund Headley"] = {
        {
            storage = 8264,
            talk_questStarting = "I need 30 Bitten Apples, 25 Sandbags, 40 Fur, 30 Gracideas and 10 Horn. Can you do that?",
            talk_questStarted = "Ok, thanks.",
            talk_questFinishing = "Did you bring what I asked for?",
            talk_questFinished = "Thanks! Here, take it.",
            talk_questFinishFail = "No, you don't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 12115, 30, 12119, 25, 12123, 40, 13304, 30, 12120, 10 },
            rewardItems = {--[[TODO]] },
            rewardExp = 5230,
            requiredLevel = 70,
            canStart = function(cid) return getCreatureStorage(cid, 8352) == QUEST_STATUS.STARTED end
        },
    },
    ["Charlie Anselm"] = {
        {
            storage = 8265,
            counterStorage = 8266,
            talk_questStarting = "I need you to defeat some Pokemon for me. What do you think?",
            talk_questStarted = "Ok, start with 30 Bellsprouts.",
            talk_questFinishing = "Is the task done?",
            talk_questFinished = "Thanks! Here, take it.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.DEFEAT_POKEMON,
            questRequest = { "Bellsprout", 30 },
            rewardItems = {--[[TODO: reward]] },
            rewardExp = 2000,
            requiredLevel = 0,
            canStart = function(cid) return getCreatureStorage(cid, 8352) == QUEST_STATUS.STARTED end
        },
        {
            storage = 8267,
            counterStorage = 8266,
            talk_questStarting = "Are you ready to the next task?",
            talk_questStarted = "Now defeat 30 Sunkerns.",
            talk_questFinishing = "Is the task done?",
            talk_questFinished = "Thanks! Here, take it.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.DEFEAT_POKEMON,
            questRequest = { "Sunkern", 30 },
            rewardItems = {--[[TODO: reward]] },
            rewardExp = 2000,
            requiredLevel = 0,
            canStart = function(cid) return getCreatureStorage(cid, 8352) == QUEST_STATUS.STARTED end
        },
        {
            storage = 8268,
            counterStorage = 8266,
            talk_questStarting = "Are you ready to the next task?",
            talk_questStarted = "Now defeat 30 Poliwag.",
            talk_questFinishing = "Is the task done?",
            talk_questFinished = "Thanks! Here, take it.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.DEFEAT_POKEMON,
            questRequest = { "Poliwag", 30 },
            rewardItems = {--[[TODO: reward]] },
            rewardExp = 2000,
            requiredLevel = 0,
            canStart = function(cid) return getCreatureStorage(cid, 8352) == QUEST_STATUS.STARTED end
        },
        {
            storage = 8269,
            counterStorage = 8266,
            talk_questStarting = "Are you ready to the next task?",
            talk_questStarted = "Now defeat 30 Horsea.",
            talk_questFinishing = "Is the task done?",
            talk_questFinished = "Thanks! Here, take it.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.DEFEAT_POKEMON,
            questRequest = { "Horsea", 30 },
            rewardItems = {--[[TODO: reward]] },
            rewardExp = 2000,
            requiredLevel = 0,
            canStart = function(cid) return getCreatureStorage(cid, 8352) == QUEST_STATUS.STARTED end
        },
        {
            storage = 8270,
            counterStorage = 8266,
            talk_questStarting = "Are you ready to the next task?",
            talk_questStarted = "Now defeat 40 Tentacool.",
            talk_questFinishing = "Is the task done?",
            talk_questFinished = "Great job. I'm done now. Take your last reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.DEFEAT_POKEMON,
            questRequest = { "Tentacool", 40 },
            rewardItems = {--[[TODO: reward]] },
            rewardExp = 2000,
            requiredLevel = 0,
            canStart = function(cid) return getCreatureStorage(cid, 8352) == QUEST_STATUS.STARTED end
        },
        {
            storage = 8285,
            counterStorage = 8266,
            talk_questStarting = "Are you ready to the next task?",
            talk_questStarted = "Now catch 2 Bellsprout.",
            talk_questFinishing = "Is the task done?",
            talk_questFinished = "Great job. I'm done now. Take your last reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.CATCH_POKEMON,
            questRequest = { "Bellsprout", 2 },
            rewardItems = {--[[TODO: reward]] },
            rewardExp = 2000,
            requiredLevel = 0,
            canStart = function(cid) return getCreatureStorage(cid, 8352) == QUEST_STATUS.STARTED end
        },
        {
            storage = 8286,
            counterStorage = 8266,
            talk_questStarting = "Are you ready to the next task?",
            talk_questStarted = "Now catch 2 Sunkern.",
            talk_questFinishing = "Is the task done?",
            talk_questFinished = "Great job. I'm done now. Take your last reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.CATCH_POKEMON,
            questRequest = { "Sunkern", 2 },
            rewardItems = {--[[TODO: reward]] },
            rewardExp = 2000,
            requiredLevel = 0,
            canStart = function(cid) return getCreatureStorage(cid, 8352) == QUEST_STATUS.STARTED end
        },
        {
            storage = 8287,
            counterStorage = 8266,
            talk_questStarting = "Are you ready to the next task?",
            talk_questStarted = "Now catch 2 Poliwag.",
            talk_questFinishing = "Is the task done?",
            talk_questFinished = "Great job. I'm done now. Take your last reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.CATCH_POKEMON,
            questRequest = { "Poliwag", 2 },
            rewardItems = {--[[TODO: reward]] },
            rewardExp = 2000,
            requiredLevel = 0,
            canStart = function(cid) return getCreatureStorage(cid, 8352) == QUEST_STATUS.STARTED end
        },
        {
            storage = 8288,
            counterStorage = 8266,
            talk_questStarting = "Are you ready to the next task?",
            talk_questStarted = "Now catch 2 Horsea.",
            talk_questFinishing = "Is the task done?",
            talk_questFinished = "Great job. I'm done now. Take your last reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.CATCH_POKEMON,
            questRequest = { "Horsea", 2 },
            rewardItems = {--[[TODO: reward]] },
            rewardExp = 2000,
            requiredLevel = 0,
            canStart = function(cid) return getCreatureStorage(cid, 8352) == QUEST_STATUS.STARTED end
        },
        {
            storage = 8289,
            counterStorage = 8266,
            talk_questStarting = "Are you ready to the next task?",
            talk_questStarted = "Now catch 2 Tentacool.",
            talk_questFinishing = "Is the task done?",
            talk_questFinished = "Great job. I'm done now. Take your last reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.CATCH_POKEMON,
            questRequest = { "Tentacool", 2 },
            rewardItems = {--[[TODO: reward]] },
            rewardExp = 2000,
            requiredLevel = 0,
            canStart = function(cid) return getCreatureStorage(cid, 8352) == QUEST_STATUS.STARTED end
        },
    },
    ["Sanford Fulk"] = {
        {
            storage = 8271,
            counterStorage = 8272,
            talk_questStarting = "I need you to capture some Pokemon for me, you in?",
            talk_questStarted = "Ok, start with 2 Magnemite.",
            talk_questFinishing = "Is the task done?",
            talk_questFinished = "Congratulations, here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.CATCH_POKEMON,
            questRequest = { "Magnemite", 2 },
            rewardItems = {--[[TODO: reward]] },
            rewardExp = 2000,
            requiredLevel = 0,
            canStart = function(cid) return getCreatureStorage(cid, 8352) == QUEST_STATUS.STARTED end
        },
        {
            storage = 8273,
            counterStorage = 8272,
            talk_questStarting = "Are you ready to the next task?",
            talk_questStarted = "Now bring me 2 Pikachu.",
            talk_questFinishing = "Is the task done?",
            talk_questFinished = "Thank you! Here is your reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.CATCH_POKEMON,
            questRequest = { "Pikachu", 2 },
            rewardItems = {--[[TODO: reward]] },
            rewardExp = 2000,
            requiredLevel = 0,
            canStart = function(cid) return getCreatureStorage(cid, 8352) == QUEST_STATUS.STARTED end
        },
    },
    ["Paulina Megan"] = {
        {
            storage = 8274,
            talk_questStarting = "Bring me 50x Empty Poke Ball and 50x Empty Ultra Ball. Can you do that?",
            talk_questStarted = "Ok, thanks.",
            talk_questFinishing = "Did you bring what I asked for?",
            talk_questFinished = "Thanks! Here, take it.",
            talk_questFinishFail = "No, you don't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 12157, 50, 12165, 50 },
            rewardItems = {--[[TODO]] },
            rewardExp = 5230,
            requiredLevel = 70,
            canStart = function(cid) return getCreatureStorage(cid, 8352) == QUEST_STATUS.STARTED end
        },
    },
    ["Regena Loraine"] = {
        {
            storage = 8275,
            counterStorage = 8276,
            talk_questStarting = "I need you to defeat some Pokemon for me. What do you think?",
            talk_questStarted = "Ok, start with 10 Ampharos.",
            talk_questFinishing = "Is the task done?",
            talk_questFinished = "Thanks! Here, take it.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.DEFEAT_POKEMON,
            questRequest = { "Ampharos", 10 },
            rewardItems = {--[[TODO: reward]] },
            rewardExp = 1000,
            requiredLevel = 0,
            canStart = function(cid) return getCreatureStorage(cid, 8352) == QUEST_STATUS.STARTED end
        },
        {
            storage = 8277,
            counterStorage = 8276,
            talk_questStarting = "Are you ready to the next task?",
            talk_questStarted = "Now defeat 10 Crobat.",
            talk_questFinishing = "Is the task done?",
            talk_questFinished = "Thanks! Here, take it.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.DEFEAT_POKEMON,
            questRequest = { "Crobat", 10 },
            rewardItems = {--[[TODO: reward]] },
            rewardExp = 1000,
            requiredLevel = 0,
            canStart = function(cid) return getCreatureStorage(cid, 8352) == QUEST_STATUS.STARTED end
        },
        {
            storage = 8278,
            counterStorage = 8276,
            talk_questStarting = "Are you ready to the next task?",
            talk_questStarted = "Now defeat 10 Quagsire.",
            talk_questFinishing = "Is the task done?",
            talk_questFinished = "Thanks! Here, take it.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.DEFEAT_POKEMON,
            questRequest = { "Quagsire", 10 },
            rewardItems = {--[[TODO: reward]] },
            rewardExp = 1000,
            requiredLevel = 0,
            canStart = function(cid) return getCreatureStorage(cid, 8352) == QUEST_STATUS.STARTED end
        },
        {
            storage = 8279,
            counterStorage = 8276,
            talk_questStarting = "Are you ready to the next task?",
            talk_questStarted = "Now defeat 10 Meganium.",
            talk_questFinishing = "Is the task done?",
            talk_questFinished = "Thanks! Here, take it.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.DEFEAT_POKEMON,
            questRequest = { "Meganium", 10 },
            rewardItems = {--[[TODO: reward]] },
            rewardExp = 1000,
            requiredLevel = 0,
            canStart = function(cid) return getCreatureStorage(cid, 8352) == QUEST_STATUS.STARTED end
        },
        {
            storage = 8280,
            counterStorage = 8276,
            talk_questStarting = "Are you ready to the next task?",
            talk_questStarted = "Now defeat 10 Charizard.",
            talk_questFinishing = "Is the task done?",
            talk_questFinished = "Great job. I'm done now. Take your last reward.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.DEFEAT_POKEMON,
            questRequest = { "Charizard", 10 },
            rewardItems = {--[[TODO: reward]] },
            rewardExp = 1000,
            requiredLevel = 0,
            canStart = function(cid) return getCreatureStorage(cid, 8352) == QUEST_STATUS.STARTED end
        },
    },
    ["Hettie Sibyl"] = {
        {
            storage = 8281,
            talk_questStarting = "Bring me: 1x Shiny Stone Orb, 1x Shiny Feather, 1x Shiny Bulb and 1x Shiny Pot of Lava. Can you do that?",
            talk_questStarted = "Ok, thanks.",
            talk_questFinishing = "Did you bring what I asked for?",
            talk_questFinished = "Thanks! Here, take it.",
            talk_questFinishFail = "No, you don't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 14563, 1, 14567, 1, 14524, 1, 14523, 1 },
            rewardItems = {--[[TODO]] },
            rewardExp = 5230,
            requiredLevel = 70,
            canStart = function(cid) return getCreatureStorage(cid, 8352) == QUEST_STATUS.STARTED end
        },
    },
    ["Harmonie Rainbow"] = {
        {
            storage = 8282,
            talk_questStarting = "I am thirsty. You can bring a lemonade?",
            talk_questStarted = "Ok, thanks.",
            talk_questFinishing = "Did you bring what I asked for?",
            talk_questFinished = "Thanks! Here, take it.",
            talk_questFinishFail = "No, you don't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 12212, 1 },
            rewardItems = {--[[TODO]] },
            rewardExp = 5230,
            requiredLevel = 70,
            canStart = function(cid) return getCreatureStorage(cid, 8352) == QUEST_STATUS.STARTED end
        },
    },
    ["Flossie Cherise"] = {
        {
            storage = 8283,
            talk_questStarting = "I want: 1x Butterfree doll, 1x Alakazam doll, 1x Charizard doll, 1x Pikachu doll, 1x Koffing doll, 1x Diglett doll and 1x Kingdra doll.",
            talk_questStarted = "Ok, thanks.",
            talk_questFinishing = "Did you bring what I asked for?",
            talk_questFinished = "Thanks! Here, take it.",
            talk_questFinishFail = "No, you don't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 17830, 1, 17877, 1, 17824, 1, 12256, 1, 17918, 1, 17864, 1, 18029, 1 },
            rewardItems = {--[[TODO]] },
            rewardExp = 5230,
            requiredLevel = 70,
            canStart = function(cid) return getCreatureStorage(cid, 8352) == QUEST_STATUS.STARTED end
        },
    },
    ["Joetta Mabella"] = {
        {
            storage = 8284,
            talk_questStarting = "I need 100x Fire Element, 100x Water Gem, 100x Seed, 100x Leaves, 100x Screw and 50x Energy Soil.",
            talk_questStarted = "Ok, thanks.",
            talk_questFinishing = "Did you bring what I asked for?",
            talk_questFinished = "Thanks! Here, take it.",
            talk_questFinishFail = "No, you don't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 12101, 100, 12100, 100, 12102, 100, 12091, 100, 12103, 100, 14480, 50 },
            rewardItems = {--[[TODO]] },
            rewardExp = 5230,
            requiredLevel = 70,
            canStart = function(cid) return getCreatureStorage(cid, 8352) == QUEST_STATUS.STARTED end
        },
    },
    ["Nolan Peter"] = {
        {
            storage = 8290,
            talk_questStarting = "I need 10x Churros With Chocolate, 15x Burger, 20x Sushi, 10x Pizza and 15x Lemonade.",
            talk_questStarted = "Ok, thanks.",
            talk_questFinishing = "Did you bring what I asked for?",
            talk_questFinished = "Thanks! Here, take it.",
            talk_questFinishFail = "No, you don't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 12204, 10, 12205, 15, 12208, 20, 12210, 10, 12212, 15 },
            rewardItems = {--[[TODO]] },
            rewardExp = 5230,
            requiredLevel = 70,
            canStart = function(cid) return getCreatureStorage(cid, 8352) == QUEST_STATUS.STARTED end
        },
    },
    ["Jane Hills"] = {
        {
            storage = 8291,
            talk_questStarting = "Hey, can you bring some food for my Pokemon?",
            talk_questStarted = "His favorite food is Onigiri, please bring me 20. Thanks for helping me.",
            talk_questFinishing = "Did you bring what I asked for?",
            talk_questFinished = "Thanks! Here, take it.",
            talk_questFinishFail = "No, you don't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 14464, 20 },
            rewardItems = {--[[TODO]] },
            rewardExp = 17435,
            requiredLevel = 70,
        },
    },
    ["Flavia"] = {
        {
            storage = 8346,
            talk_questStarting = "I need to find my necklace... I lost it on this beach. Can you help me?",
            talk_questStarted = "Take this shovel, dig around and find it for me! Thank you.",
            talk_questFinishing = "Did you bring what I asked for?",
            talk_questFinished = "Thanks! Here, take it.",
            talk_questFinishFail = "No, you don't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 18196, 1, 18195, 1 },
            rewardItems = {--[[TODO]] },
            rewardExp = 17435,
            requiredLevel = 70,
            questStartItems = { 18195, 1 },
        },
    },
    -- storage 8292 flavia necklace (shovel)
    -- storage 8293 professor ivy waiting time
    -- storage 8294 tangel rue leaves
    ["Kurt Fastman McGaryson"] = {
        {
            storage = 8295,
            talk_questStarting = "Cool of you, do you want to earn some money helping me?",
            talk_questStarted = "Cool! You have to deliver newspapers to 10 people in the Orange Archipelago, don't forget. The names are on this list. Are you ready? Go, go!",
            talk_questFinishing = "Did you deliver the newspapers?",
            talk_questFinished = "Yup! You made all the deliveries! Take your money. By the way, I always need help. Come back tomorrow and you can help me again.",
            talk_questFinishFail = "No, you don't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.CUSTOM,
            questRequest = function(cid) return getCreatureStorage(cid, 8299) >= 10 end,
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 2152, count = 5 } },
            rewardExp = 0,
            requiredLevel = 70,
            questStartItems = { 18190, 10, 18323, 1 },
            onStart = function(cid)
                local storages = { 8299, 8300, 8301, 8302, 8303, 8304, 8305, 8306, 8307, 8308, 8309 }
                for _, storage in pairs(storages) do
                    doCreatureSetStorage(cid, storage, 0)
                end
            end,
            onEnd = function(cid)
                local v = getCreatureStorage(cid, 8298)
                if (v < 0) then
                    v = 0
                end
                doCreatureSetStorage(cid, 8298, v + 1)
                doCreatureSetStorage(cid, 8336, os.time())
                doPlayerRemoveItem(cid, 18323, getPlayerItemCount(cid, 18323))
                doCreatureSetStorage(cid, 8295, QUEST_STATUS.UNSTARTED)
            end,
            canStart = function(cid) return os.time() - getCreatureStorage(cid, 8336) >= 86400 and getCreatureStorage(cid, 8296) ~= QUEST_STATUS.STARTED end
        },
        {
            storage = 8296,
            talk_questStarting = "You completed your 10th delivery! Cool, now you can do another favor for me! This one is important, and I'll tell you something very important. You in?",
            talk_questStarted = "Great. Give this special newspaper to a great client. He lives on Butwal Island in an underground house. Once finished, come back. Oh, his name is Bud Jude.",
            talk_questFinishing = "Did you bring what I asked for?",
            talk_questFinished = "Thanks! Here, take it.",
            talk_questFinishFail = "No, you don't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.CUSTOM,
            questRequest = function(cid) return getCreatureStorage(cid, 8297) == QUEST_STATUS.FINISHED end,
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 18089, count = 1 } },
            rewardExp = 0,
            requiredLevel = 70,
            questStartItems = { 18190, 1 },
            canStart = function(cid) return getCreatureStorage(cid, 8298) >= 10 end
        },
    },
    -- storage 8297 Bud Jude newspaper
    -- storage 8298 Kurt Fastman McGaryson quest count
    -- storage 8299 Kurt Fastman McGaryson deliver count
    ["Jarrod"] = {
        {
            storage = 8310,
            talk_questStarting = "Great, we are looking for trainers who can test our new inventions. How about helping us?",
            talk_questStarted = "Take the new poke balls and try to capture the Pokemon in our laboratory. Get their attention and then throw the balls. You do not need to hurt them. When you're ready, go through the door at the back of our lab; the poke balls and baits are there. Good luck!",
            talk_questFinishing = "Did you test the new poke balls?",
            talk_questFinished = "Great! Thank you for doing this favor for us. I think it's time for us to do some {tests} on other Pokemon.",
            talk_questFinishFail = "No, you don't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.CUSTOM,
            questRequest = function(cid) return getCreatureStorage(cid, 8337) >= 10 end,
            rewardItems = {--[[TODO]] },
            rewardExp = 52305,
            requiredLevel = 70,
            onStart = function(cid) doCreatureSetStorage(cid, 8337, 0) end
        },
        {
            storage = 8311,
            talk_questStarting = "How about helping us again?",
            talk_questStarted = "Cool. All you need to do is bring the items to us. As soon as you bring them, we'll make something for you! Items: 10x Electrizer, 5x Metal Spike, 50x Gear Wheel and 10x Magnet.",
            talk_questFinishing = "Did you test the new poke balls?",
            talk_questFinished = "Good job! Here is your reward. If you come back tomorrow I will give you another task!",
            talk_questFinishFail = "No, you don't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 12118, 10, 13308, 5, 14490, 50, 12140, 10 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 18628, count = 8 } },
            rewardExp = 0,
            requiredLevel = 70,
            daily = true
        },
    },
    -- storage 8312 Oliver Vase
    ["Oliver Terrel"] = {
        {
            storage = 8313,
            talk_questStarting = "I've run out of supplies... can you help me?",
            talk_questStarted = "Great, bring me 6 revives. My Pokemon have fainted and I have no way out of here. When you come back I'll give you some information.",
            talk_questFinishing = "Did you bring me the revives?",
            talk_questFinished = "Great, but you also have to {help} me with something else.",
            talk_questFinishFail = "No, you don't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 12248, 6 },
            rewardItems = {--[[TODO]] },
            rewardExp = 0,
            requiredLevel = 70,
        },
        {
            storage = 8314,
            talk_questStarting = "You will not believe... A flying Pokemon came and took my backpack and the key. Can you help me again?",
            talk_questStarted = "Get my backpack back and return here! He can't have gone far...",
            talk_questFinishing = "Did you find my backpack?",
            talk_questFinished = "You are very brave, thank you for doing my family this great favor. In his last days, my grandfather gathered his Pokemon in that house and stayed there. Maybe one day I'll be able to get there... here, take this, it should help you.",
            talk_questFinishFail = "No, you don't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 18304, 1 },
            rewardItems = {},
            rewardExp = 0,
            requiredLevel = 70,
            onEnd = function(cid)
                doCreatureSetStorage(cid, 8350, QUEST_STATUS.STARTED)
                doItemSetAttribute(doPlayerAddUniqueItem(cid, 18636, 1, true), "aid", 1000)
            end
        },
        {
            storage = 8350,
            talk_questStarting = "",
            talk_questStarted = "",
            talk_questFinishing = "Did you find anything from my family?",
            talk_questFinished = "You are incredible! I don't know how to thank you. How about choosing one of my Technical Machines? Your options are: {TM 05} (Mega Kick), {TM 25} (Earthquake) and {TM 37} (Skull Bash).",
            talk_questFinishFail = "No, you don't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 18184, 1 },
            rewardItems = {},
            rewardExp = 0,
            requiredLevel = 70,
            blockStart = true
        },
    },
    ["Max Fegan"] = {
        {
            storage = 8315,
            talk_questStarting = "The enclosure for my Miltanks broke, and I was going to Mikan Island to pick up boards from Woodworker Courts Ted to make a new fence, but I'm afraid to leave my Miltanks alone. Could you go there and pick up the boards for me?",
            talk_questStarted = "Go to Mikan Island and see the woodworker. His name is Woodworker Courts Ted.",
            talk_questFinishing = "Got my boards?",
            talk_questFinished = "Now you need to do two more deliveries.",
            talk_questFinishFail = "No, you don't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 18189, 1 },
            rewardItems = {--[[TODO]] },
            rewardExp = 0,
            requiredLevel = 70,
        },
        {
            storage = 8319,
            talk_questStarting = "Will you make another delivery?",
            talk_questStarted = "I still need a lot of boards. Go and do not be late!",
            talk_questFinishing = "Got my boards?",
            talk_questFinished = "Now you need to do one more delivery.",
            talk_questFinishFail = "No, you don't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 18189, 1 },
            rewardItems = {--[[TODO]] },
            rewardExp = 0,
            requiredLevel = 70,
        },
        {
            storage = 8322,
            talk_questStarting = "Will you make another delivery?",
            talk_questStarted = "Cool, I think I'll have a surprise for you when you're back. Go in peace.",
            talk_questFinishing = "Got my boards?",
            talk_questFinished = "Great! Thanks for helping me with this. As a reward, I'll give you the chance to win one of the Miltank eggs we produce here. Every 24 hours, bring me 50 oranges, they love them. Once you bring the oranges, come back in 24 hours and I'll tell you if you got your egg. Deal? Great, good luck!",
            talk_questFinishFail = "No, you don't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 18189, 1 },
            rewardItems = {--[[TODO]] },
            rewardExp = 0,
            requiredLevel = 70,
        },
        {
            storage = 8324,
            talk_questStarting = "Do you want to bring some oranges for my Miltanks?",
            talk_questStarted = "Ok, I think 50 is enough.",
            talk_questFinishing = "Did you get the oranges?",
            talk_questFinished = "Great! Thanks for helping me with this. As a reward, I'll give you the chance to win one of the Miltank eggs we produce here. Every 24 hours, bring me 50 oranges, they love them. Once you bring the oranges, come back in 24 hours and I'll tell you if you got your egg. Deal? Great, good luck!",
            talk_questFinishFail = "No, you don't.",
            talk_questDone = "Thanks, let's see the egg now...",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 2675, 50 },
            rewardItems = {},
            rewardExp = 0,
            requiredLevel = 70,
            onEnd = function(cid)
                if (getRandom(0, 200) > 10) then
                    selfSay("No eggs was generated... try again tomorrow!", cid)
                    doCreatureSetStorage(cid, 8324, QUEST_STATUS.UNSTARTED)
                    doCreatureSetStorage(cid, 8351, os.time())
                    return

                elseif (not doPlayerAddItem(cid, 17784, 1, false)) then
                    doPlayerAddDepotItem(cid, 0, doCreateItem(17784, 1, getCreaturePosition(cid)))
                end

                selfSay("Congratulations! An egg was generated!", cid)
                doCreatureSetStorage(cid, 8325, QUEST_STATUS.FINISHED)
            end,
            canStart = function(cid)
                if (getCreatureStorage(cid, 8325) == QUEST_STATUS.FINISHED) then
                    return false
                end

                local diff = (getCreatureStorage(cid, 8351) + (24 * 60 * 60) - os.time())
                if (diff > 0) then
                    selfSay(string.format(__L(cid, "You must wait %s to continue."), table.concat(string.timediff(diff, cid))), cid)
                    return false
                end
                return true
            end
        },
    },
    ["Woodworker Courts Ted"] = {
        {
            storage = 8316,
            talk_questStarting = "Oops! He's coming today and I totally forgot the fence... Can you do this for me?",
            talk_questStarted = "Go, take my axe and cut some trees for me. I think 5 is enough. Once you're done, bring the wood to me and I'll work on it.",
            talk_questFinishing = "Were you able to cut the trees?",
            talk_questFinished = "Great, I'll start making the {boards} for the fence.",
            talk_questFinishFail = "No, you don't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 18302, 5, 18301, 1 },
            rewardItems = {--[[TODO]] },
            rewardExp = 0,
            requiredLevel = 70,
            questStartItems = { 18301, 1 },
            onEnd = function(cid) doPlayerRemoveItem(cid, 18302, getPlayerItemCount(cid, 18302)) end, -- Just to prevent abuse
            canStart = function(cid) return getCreatureStorage(cid, 8315) == QUEST_STATUS.STARTED end
        },
        {
            storage = 8317,
            talk_questStarting = "I don't think you can carry them all in one trip... I will give you the lumber in three batches, which means three trips. Can you help me with some tasks while I prepare the boards?",
            talk_questStarted = "Can you take this message to my wife in Celadon? Her name is Beatriz.",
            talk_questFinishing = "Did you deliver the message to my wife?",
            talk_questFinished = "Thank you. The first batch of boards is ready, take it.",
            talk_questFinishFail = "No, you don't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.CUSTOM,
            questRequest = function(cid) return getCreatureStorage(cid, 8318) == QUEST_STATUS.FINISHED end,
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 18189, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 70,
            questStartItems = { 18306, 1 },
            canStart = function(cid) return getCreatureStorage(cid, 8316) == QUEST_STATUS.FINISHED end
        },
        {
            storage = 8320,
            talk_questStarting = "I'm finishing the second round, could you feed my Pokemon?",
            talk_questStarted = "He lives underground on the island. Take some fruit. I thank you immensely for it.",
            talk_questFinishing = "Did you feed my Pokemon?",
            talk_questFinished = "Thank you. The second batch of boards is ready, take it.",
            talk_questFinishFail = "No, you don't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.CUSTOM,
            questRequest = function(cid) return getCreatureStorage(cid, 8323) >= 5 end,
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 18189, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 70,
            questStartItems = { 18303, 5 },
            onStart = function(cid) doCreatureSetStorage(cid, 8323, 0) end,
            canStart = function(cid) return getCreatureStorage(cid, 8317) == QUEST_STATUS.FINISHED end
        },
        {
            storage = 8321,
            counterStorage = 8348,
            talk_questStarting = "Great that you're back... I'm in trouble. Can you help me?",
            talk_questStarted = "It seems my Pokemon is being attacked by Murkrow! I know you can help him: defeat 30 of them. When you're ready, step into the teleport machine.",
            talk_questFinishing = "Did you help my Pokemon?",
            talk_questFinished = "Thank you. The last batch of boards is ready, take it. Good luck!",
            talk_questFinishFail = "No, you don't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.DEFEAT_POKEMON,
            questRequest = { "Murkrow", 30 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 18189, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 70,
            canStart = function(cid) return getCreatureStorage(cid, 8320) == QUEST_STATUS.FINISHED end
        },
    },
    -- storage 8318 Beatriz message
    -- storage 8323 Woodworker Courts Ted Mango counter
    -- storage 8325 Max Fegan miltank egg
    ["Mateo"] = {
        {
            storage = 8326,
            talk_questStarting = "They say the Crystal Onix actually exists. If you find it, come back here and talk to me, ok?",
            talk_questStarted = "Take this camera to prove that it really exists. Have you ever heard of a Pokemon researcher named Merv Kelley? He might have some new information for you.",
            talk_questFinishing = "Did you bring what I asked for?",
            talk_questFinished = "Thanks! Here, take it.",
            talk_questFinishFail = "No, you don't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 18309, 1, 18182, 1 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 18310, count = 1 } },
            rewardExp = 52305,
            requiredLevel = 70,
            questStartItems = { 18182, 1 },
            canStart = function(cid) return getCreatureStorage(cid, 8224) == QUEST_STATUS.FINISHED end
        },
    },
    -- storage 8327 Crystal Onix picture
    ["Kimberly Downson"] = {
        {
            storage = 8329,
            talk_questStarting = "Can you help me with something that's been bothering my family?",
            talk_questStarted = "Great. Our house is suffering from a Rattata infestation. I know you can handle it. I need you to go down to the basement and turn on the machine there, the key is inside one of the trunks.",
            talk_questFinishing = "Did you turn on my machine?",
            talk_questFinished = "Thanks! Here, take it.",
            talk_questFinishFail = "No, you don't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.CUSTOM,
            questRequest = function(cid) return getCreatureStorage(cid, 8330) == QUEST_STATUS.FINISHED end,
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 2152, count = 10 }, { type = REWARD_TYPE.ITEM, id = 18639, count = 1 } },
            rewardExp = 52305,
            requiredLevel = 70
        },
    },
    -- storage 8330 Kimberly key
    -- storage 8331 Kimberly chest
    ["Dr. Oravaf"] = {
        {
            storage = 8332,
            talk_questStarting = "What? You're saying the Pokedex Upgrader is broken? Never thought it would happen, but don't worry, I'll fix it. I have all the tools needed for the repair.",
            talk_questStarted = "Well... this is not a common repair, that machine has high-tech parts. I'm gonna need you to go to the Power Plant and bring me a Codex Motor, an Energy Transformer and a Bignose Gear. To get these parts you'll have to search the machines there. Many of them are ruined, but some still have fully functional parts. Good luck!",
            talk_questFinishing = "Did you bring what I asked for?",
            talk_questFinished = "Great! Now I just need you for one more task.",
            talk_questFinishFail = "No, you don't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 18192, 1, 18193, 1, 18194, 1 },
            rewardItems = {},
            rewardExp = 0,
            requiredLevel = 70,
            onEnd = function(cid)
                for _, itemid in pairs({ 18192, 18193, 18194 }) do
                    doPlayerRemoveItem(cid, itemid, getPlayerItemCount(cid, itemid))
                end
            end,
            canStart = function(cid) return getCreatureStorage(cid, 8338) == QUEST_STATUS.STARTED end
        },
        {
            storage = 8333,
            talk_questStarting = "Will you help me with the last task?",
            talk_questStarted = "Bring me an Electrode, I need electricity to repair the machine.",
            talk_questFinishing = "Did you bring what I asked for?",
            talk_questFinished = "Very good! I'm going right now to fix the machine! Go talk to Professor Oak.",
            talk_questFinishFail = "No, you don't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.BRING_POKEMON,
            questRequest = "Electrode",
            rewardItems = {},
            rewardExp = 0,
            requiredLevel = 70,
            canStart = function(cid) return getCreatureStorage(cid, 8338) == QUEST_STATUS.STARTED end
        },
    },
    -- storage 8334 Saruman Donphan Toy Ball
    -- storage 8335 Oliver Terrel Backpack Drop
    -- storage 8336 Kurt Fastman daily
    -- storage 8337 Jarrod Catch counter
    ["Oak's Assistant"] = {
        {
            storage = 8008,
            talk_questStarting = "I am collecting information about Pokemon and need you to collect some for me. Do you want to help me?",
            talk_questStarted = "Ok, I need you to collect information about 30 Pokemon. Use your Pokedex on them and come back to me.",
            talk_questFinishing = "Have you got what I asked for?",
            talk_questFinished = "Very nice, thanks, here is your reward.",
            talk_questFinishFail = "No... you don't have it. Collect the information and come back to me.",
            talk_questDone = "Thanks, but, I have no missions for you now.",
            questType = QUEST_TYPE.DEX_POKEMONS,
            questRequest = 30,
            rewardItems = {},
            rewardExp = 4000,
            requiredLevel = 10,
        },
        {
            storage = 8010,
            talk_questStarting = "Well, my research isn't finished yet... I'm just beginning. I need help collecting more information about Pokemon. Can you help me?",
            talk_questStarted = "Alright, I need more information. Register a total of 50 Pokemon with your Pokedex and then come back to me.",
            talk_questFinishing = "Have you got what I asked for?",
            talk_questFinished = "Thanks! Here is your reward.",
            talk_questFinishFail = "No... you don't have it. Collect the information and come back to me.",
            talk_questDone = "Thanks, but, I have no missions for you now.",
            questType = QUEST_TYPE.DEX_POKEMONS,
            questRequest = 50,
            rewardItems = {},
            rewardExp = 5000,
            requiredLevel = 10,
        },
        {
            storage = 8011,
            talk_questStarting = "I need more information to complete my research. Do you want to help me?",
            talk_questStarted = "Register a total of 100 Pokemon with your Pokedex and then come back to me.",
            talk_questFinishing = "Do you have the information for the research?",
            talk_questFinished = "Thanks!",
            talk_questFinishFail = "No... you don't have it. Collect the information and come back to me.",
            talk_questDone = "Thanks, but, I have no missions for you now.",
            questType = QUEST_TYPE.DEX_POKEMONS,
            questRequest = 100,
            rewardItems = {},
            rewardExp = 10000,
            requiredLevel = 10,
        },
        {
            storage = 8012,
            talk_questStarting = "I have another task for you, want to help?",
            talk_questStarted = "The task is to register a total of 140 Pokemon with your Pokedex, good luck!",
            talk_questFinishing = "Did you complete the task?",
            talk_questFinished = "Thank you!",
            talk_questFinishFail = "Come back when you have the information...",
            talk_questDone = "Thanks, but, I have no missions for you now.",
            questType = QUEST_TYPE.DEX_POKEMONS,
            questRequest = 140,
            rewardItems = {},
            rewardExp = 50000,
            requiredLevel = 10,
        },
        {
            storage = 8013,
            talk_questStarting = "This is the last task, it's a very important step for my research. Do you want to help me?",
            talk_questStarted = "This is the last step: register a total of 151 Pokemon with your Pokedex and then come back to me.",
            talk_questFinishing = "Did you complete the research?",
            talk_questFinished = "Thanks! Thanks! You are a hero to the Pokemon world! Based on the information you collected, I can create better technology to improve Pokemon life.",
            talk_questFinishFail = "No... you don't have it. Collect the information and come back to me.",
            talk_questDone = "Thanks, but, I have no missions for you now.",
            questType = QUEST_TYPE.DEX_POKEMONS,
            questRequest = 151,
            rewardItems = {},
            rewardExp = 100000,
            requiredLevel = 10,
        },
    },
    ["Harold Sheen"] = {
        {
            storage = 8339,
            talk_questStarting = "Are you willing to help me with our new machinery?",
            talk_questStarted = "Cool. We need three fearless trainers to enter our challenge and win a cool prize. Get the ticket and come back!",
            talk_questFinishing = "Great, you made it. Did you get the ticket?",
            talk_questFinished = "Here, you deserve it. Thanks for helping!",
            talk_questFinishFail = "No, you don't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 18634, 1 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 18632, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 70
        },
    },
    -- storage 8340 Arold talk
    -- storage 8341 Juhn talk
    -- storage 8342 Denis talk
    -- storage 8343 Aleb talk
    -- storage 8344 Juanito letter 1
    -- storage 8345 Juanito letter 2
    -- storage 8347 Farmer Steve counter
    -- storage 8349 Baby Dungeon chest
    -- storage 8351 Max Fegan daily system
    -- storage 8352 Hilari
    -- storage 8354 Oliver Terrel TM Choose
    ["Ray Fitz"] = {
        {
            storage = 8358,
            talk_questStarting = "My task here is to help you with your first steps as a Pokemon trainer! Shall we begin?",
            talk_questStarted = "Okay, first let's know the Pokedex! It is located in your inventory, your mission is to release your Pokemon and use your Pokedex to collect information about it! Do this and talk to me again.",
            talk_questFinishing = "Were you able to collect the information of your Pokemon?",
            talk_questFinished = "Congratulations! Remember to always use your Pokedex when you need information about the Pokemon! Type {mission} when you want to get your next task!",
            talk_questFinishFail = "Looks like no. First release your Pokemon and then use the Pokedex that is in your inventory on the Pokemon.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.DEX_POKEMONS,
            questRequest = 1,
            rewardItems = {},
            rewardExp = 700,
            requiredLevel = 0
        },
        {
            storage = 8359,
            talk_questStarting = "Your next task is to know the store PokeMart! A store that will provide you with all the necessary supplies for your Pokemon training! Are you ready?",
            talk_questStarted = "Ok, the PokeMart is marked on your minimap! (A dollar sign) Your job is to communicate with the seller and ask for my {order}.",
            talk_questFinishing = "You could find the PokeMart?",
            talk_questFinished = "Great! Thank you for seeking my order, take this reward! Type {mission} when you want to get your next task!",
            talk_questFinishFail = "Looks like no. You must go to the PokeMart and ask for my {order}.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 18718, 1 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 12157, count = 10, unique = true } },
            rewardExp = 225,
            requiredLevel = 0,
            onStart = function(cid) doCreatureSetStorage(cid, 8367, QUEST_STATUS.STARTED) end -- Start PokeMart also to get directly into the finishing question
        },
        {
            storage = 8360,
            counterStorage = 8366,
            talk_questStarting = "You're doing great, I think you're ready for your first Pokemon battle! What do you think?",
            talk_questStarted = "Your task is to defeat 1x Rattata, you can find this Pokemon in the city sewers. Take care! Good luck! Remeber that you can order your Pokemon moves clicking on the move bar or saying 'm1' for first move, 'm2' for second move...",
            talk_questFinishing = "You could defeat the Rattata?",
            talk_questFinished = "Very good to hear, I believe you will become a great Pokemon trainer! Type {mission} when you want to get your next task!",
            talk_questFinishFail = "Looks like no. You must go to the sewers and defeat 1x Rattata.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.DEFEAT_POKEMON,
            questRequest = { "Rattata", 1 },
            rewardItems = {},
            rewardExp = 1500,
            requiredLevel = 0
        },
        {
            storage = 8361,
            talk_questStarting = "Capturing Pokemon is one of the biggest challenges of the trainers. You are ready for this?",
            talk_questStarted = "Your next task is to defeat and catch 1x Rattata. Take these Poke Balls.",
            talk_questFinishing = "You could defeat and catch the Rattata?",
            talk_questFinished = "Haha, great news! I'm really enjoying help you, take this reward! Type {mission} when you want to get your next task!",
            talk_questFinishFail = "Looks like no. You must go to the sewers, defeat and catch 1x Rattata.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.BRING_POKEMON,
            questRequest = "Rattata",
            rewardItems = { { type = REWARD_TYPE.POKEMON, name = "Bellsprout", level = 10, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            onStart = function(cid) doPlayerSafeAddItem(cid, 12157, 10, true, true) end
        },
        {
            storage = 8362,
            talk_questStarting = "Now that you are already taking your first steps in the Pokemon world, I have a challenge for you. Do you accept?",
            talk_questStarted = "Okay, your task is to collect information from 3 different Pokemon with your Pokedex!",
            talk_questFinishing = "You could collect the information that I ask?",
            talk_questFinished = "Congratulations, you really show a brave trainer. Type {mission} when you want to get your next task!",
            talk_questFinishFail = "Looks like no. You must use your Pokedex on 3 different Pokemon.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.DEX_POKEMONS,
            questRequest = 3,
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 12244, count = 10, unique = true } },
            rewardExp = 500,
            requiredLevel = 0
        },
        {
            storage = 8363,
            talk_questStarting = "There are several types of Pokemon in this world and also several ways to find them. Your next mission will show you a new way of doing it. Do you accept?",
            talk_questStarted = "Inside your backpack you can locate your fishing rod (Old Fishing Rod). Get close to a lake or river and fish until you reach fishing skill 5.",
            talk_questFinishing = "You raise your fishing skill?",
            talk_questFinished = "I knew you could! Take this gift. Type {mission} when you want to get your next task!",
            talk_questFinishFail = "Looks like no. You must get next a river or lake and fish until you reach fishing skill 5.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.CUSTOM,
            questRequest = function(cid) return getPlayerSkillLevel(cid, PLAYER_SKILL_FISHING) >= 5 end,
            rewardItems = { { type = REWARD_TYPE.POKEMON, name = "Krabby", level = 10, unique = true } },
            rewardExp = 0,
            requiredLevel = 0
        },
        --[[{
            storage = 8364,
            talk_questStarting = "What do you think to test your skills in a real Pokemon battle?",
            talk_questStarted = "Prepare yourself!",
            talk_questFinishing = "",
            talk_questFinished = "",
            talk_questFinishFail = "",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = {18634, 1},
            rewardItems = {},
            rewardExp = 0,
            requiredLevel = 0
        },]]
        {
            storage = 8365,
            talk_questStarting = "I really liked to introduce you to the Pokemon world. Now it's just one last task.",
            talk_questStarted = "Your last task is to buy 1x Pokemon Revive at the PokeMart and bring to me. You may defeat some Pokemon and grab the items that they drop to sell at the PokeMart and then buy the Pokemon Revive!",
            talk_questFinishing = "Did you buy the item that I ask?",
            talk_questFinished = "Very well! You are ready for your adventures in the Pokemon world, my job ends here. Good luck my friend!",
            talk_questFinishFail = "Looks like no. You must go to the PokeMart and type {trade} then locate and buy 1x Pokemon Revive. You may defeat some Pokemon and grab the items that they drop to sell at the PokeMart and then buy the Pokemon Revive!",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 12248, 1 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 2152, count = 2 } },
            rewardExp = 2000,
            requiredLevel = 0
        },
    },
    ["PokeMart"] = {
        -- Default name, isn't really a NPC name
        {
            storage = 8367,
            talk_questStarting = "",
            talk_questStarted = "",
            talk_questFinishing = "Oh! You came here to take Ray's order?",
            talk_questFinished = "Here is! Take carefully. Remember that you can always return here to buy supplies!",
            talk_questFinishFail = "Looks like you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.CUSTOM,
            questRequest = function(cid) return true end,
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 18718, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            blockStart = true, -- Auto started
        }
    },
    ["Ancient Times"] = {
        {
            storage = 8369,
            talk_questStarting = "Are you ready for the next step of your journey?",
            talk_questStarted = "You have to go through a new trial. Decipher our little secret and go where no one has dared to go.",
            talk_questFinishing = "Have you solved our secret?",
            talk_questFinished = "Now go to the island matching the element. The islands lie around this main island; place the Orb in the correct spot there. Then come to Deepsoul Stone.",
            talk_questFinishFail = "Looks like you haven't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.CUSTOM,
            questRequest = function(cid) return getCreatureStorage(cid, 8371) == QUEST_STATUS.FINISHED end, -- Defeat Ancients
            rewardItems = {},
            rewardExp = 0,
            requiredLevel = 70,
            canStart = function(cid) return getCreatureStorage(cid, 8328) == QUEST_STATUS.STARTED end
        }
    },
    ["Ash Ketchum"] = {
        {
            storage = 8659,
            talk_questStarting = "Pikachu! I can't believe they took Pikachu <crying>...",
            talk_questStarted = "We have to recover our Pokemon, please go ahead. The nurse's body must have a key.",
            talk_questFinishing = "Did you find our Pokemon?",
            talk_questFinished = "I can't believe it! You did it! Thank you!",
            talk_questFinishFail = "Looks like you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 27428, 1 },
            rewardExp = 0,
            requiredLevel = 60,
            startPosition = { x = 5517, y = 237, z = 6 },
            finishPosition = { x = 5517, y = 237, z = 6 },
            canStart = function(cid) return getPlayerDefeatedNPC(cid, 9707) end,
            onEnd = function(cid)
                for v = 8659, 8664 do
                    if (getCreatureStorage(cid, v) ~= QUEST_STATUS.FINISHED) then
                        return
                    end
                end

                doCreatureSay(cid, "Late kid, I do not need your Pokemon. I'm waiting for you in my battle arena, if you are so good come here without problems.", TALKTYPE_MONSTER_YELL)
            end
        },
        {
            storage = 8378,
            talk_questStarting = "",
            talk_questStarted = "",
            talk_questFinishing = "Did you bring the honey pot?",
            talk_questFinished = "Thank you! This will be very useful to {save} those Pokemon! But where are Brock and Misty?! Grr!",
            talk_questFinishFail = "Looks like you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.CUSTOM,
            questRequest = function(cid) return getPlayerItemCount(cid, 18755) >= 1 end,
            rewardItems = {},
            rewardExp = 0,
            requiredLevel = 60,
            startPosition = { x = 3898, y = 625, z = 7 },
            finishPosition = { x = 3898, y = 625, z = 7 },
            blockStart = true -- This is started by Delia Ketchum 8377
        },
        {
            storage = 8379,
            talk_questStarting = "Brock and Misty are late! Would you help us again?",
            talk_questStarted = "Go east of Fuchsia to route 15; on top of a mountain you will find a special tree. Use this honey on the tree and be careful, a hungry Beedrill will come after you. Defeat this Beedrill and bring a special mushroom back for us.",
            talk_questFinishing = "Were you able to find the mushroom?",
            talk_questFinished = "Thank you! Now Brock will be able to complete the recipe and save those poor Pokemon, thanks! Take this reward, you deserve it.",
            talk_questFinishFail = "Looks like you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 18756, 1, 18755, 1 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 18754, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 60,
            canStart = function(cid) return getCreatureStorage(cid, 8378) == QUEST_STATUS.FINISHED end,
            onEnd = function(cid) doCreatureSetStorage(cid, 8377, QUEST_STATUS.FINISHED) end, -- AutoEnd Delia Ketchum 8377
            startPosition = { x = 3898, y = 625, z = 7 },
            finishPosition = { x = 3898, y = 625, z = 7 },
        },
        {
            storage = 8523,
            talk_questStarting = "Finally... someone got here.",
            talk_questStarted = "It was a very long and exhausting journey. They kidnapped me and held me here. I've gone days without eating or drinking ... we need to get out of here quickly. Come on!",
            talk_questFinishing = "Are we safe now?",
            talk_questFinished = "Thank you. We don't have much time before they come after us with everything again. I'll hide for a while. Tell Bill and Gary that I will be in the usual place. Thanks again, trainer.",
            talk_questFinishFail = "Looks like you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 18756, 1, 18755, 1 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 18754, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 60,
            canStart = function(cid) return getCreatureStorage(cid, 8378) == QUEST_STATUS.FINISHED end,
            onEnd = function(cid) doCreatureSetStorage(cid, 8377, QUEST_STATUS.FINISHED) end, -- AutoEnd Delia Ketchum 8377
            startPosition = { x = 3898, y = 625, z = 7 },
            finishPosition = { x = 3898, y = 625, z = 7 },
        },
    },
    ["Dr. Alan Grant"] = {
        {
            storage = 8383,
            talk_questStarting = "Oh MY GOD! You found an Old Amber?",
            talk_questStarted = "I've been looking for it for years! Listen, I developed this resynthesizer; with it we can try to extract the DNA in the Old Amber. Take it, use it on the Old Amber and come back once it is 100% charged.",
            talk_questFinishing = "Did you bring the charged resynthesizer?",
            talk_questFinished = "Ok, let's try!",
            talk_questFinishFail = "Looks like you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.CUSTOM,
            questStartItems = { 18177, 1 }, -- resynthesizer
            questRequest = function(cid) -- Resynthesizer Charged Up
                local item = getPlayerItemById(cid, true, 18177)
                if (not isItem(item)) then
                    return false
                end

                local status = getItemAttribute(item.uid, 1200)
                if (not status) then
                    return false
                end

                return math.round(((getCurrentTimeInSeconds() - status) / (7 * 24 * 60 * 60)) * 100, 2) >= 1.0
            end,
            rewardItems = {},
            rewardExp = 0,
            requiredLevel = 100,
            canStart = function(cid) return getCreatureStorage(cid, 8382) == QUEST_STATUS.FINISHED end, -- Finished Aerodactyl Old Amber dungeon
            onEnd = function(cid)
                local item = getPlayerItemById(cid, true, 18177)
                local oldAmber = getPlayerItemById(cid, true, 12094)
                if (not isItem(item) or not isItem(oldAmber)) then
                    selfSay("You must carry the Old Amber and the Resynthesizer!", cid)
                    return
                end

                if (getRandom(1, 100) > 30) then
                    selfSay("Grr! This extraction failed! Please try again and back later.", cid)
                    doItemSetAttribute(item.uid, 1200, getCurrentTimeInSeconds())
                    doCreatureSetStorage(cid, 8383, QUEST_STATUS.STARTED) -- Reset self quest
                    return
                end

                selfSay("Yes! That WORKED! Congratulations, you successfully extracted the Aerodactyl DNA! Please, be careful with this egg!", cid)
                doPlayerSafeAddItem(cid, 18765, 1, true, false)
                doPlayerAchievementCheck(cid, ACHIEVEMENT_IDS.AERODACTYL_EGG)
                doRemoveItem(item.uid)
                doRemoveItem(oldAmber.uid)
            end
        },
    },
    ["Snap"] = {
        {
            storage = 8384,
            talk_questStarting = "My father gave me this camera a long time ago and she seems to be special. I ended up doing a very bad thing with her. The other day I found a different rabbit carrying several eggs, and found it so beautiful that I was taking his picture. But what I did not anticipate was that the camera would do something so sinister. The instant I pressed the button to take the picture of the rabbit, a very strong light threw me back and I fainted. When I woke up, he was there, standing where I had seen moments before taking the picture. When caught him he awoke and began to SPEAK! He told me it was the Easter Bunny, can you believe it! Now I need to help him... would you be willing to help too?",
            talk_questStarted = "Great! He is resting upstairs... he will explain everything.",
            talk_questFinishing = "You could help that poor creature?",
            talk_questFinished = "Oh, that's wonderful! I think we just are creating a better Easter to everyone! Yeah, I think this fits you, take as a reward!",
            talk_questFinishFail = "Looks like you didn't.",
            talk_questDone = "We already helped that creature! Good job.",
            questType = QUEST_TYPE.CUSTOM,
            questRequest = function(cid) return getCreatureStorage(cid, 8385) == QUEST_STATUS.FINISHED end,
            rewardItems = {
                { type = REWARD_TYPE.ADDON, female = { looktype = 1250, addons = 0 }, male = { looktype = 1250, addons = 0 } },
            },
            rewardExp = 0,
            requiredLevel = 0,
        },
    },
    ["Easter Rabbit"] = {
        {
            storage = 8385,
            talk_questStarting = "Have you talked to the photographer down there? Very good if you want to help me. I need to explain the situation. We in the world of fantasy are made of good energy. We are magical beings. When we left our world to accomplish our purposes we have to be very careful with the outside world or the consequences can be huge and we never know what can happen. When he took my picture a part of me fell off my body. This part wants to become free, away from all our obligations and objectives. This not happened  because his camera is special, but we can not be seen, much less recorded in photographs. You can search for this piece of me and bring it to me to follow my path?",
            talk_questStarted = "Thank you! It is a lot like me, but it can be dangerous, so be careful! Ah, my appearance is according to the size that I am. Being a Pikachu is amazing...",
            talk_questFinishing = "Did you find my other part?",
            talk_questFinished = "You are really special! Thank you! Happy Easter!",
            talk_questFinishFail = "Looks like you didn't.",
            talk_questDone = "I am complete now, thanks.",
            rewardItems = {},
            rewardExp = 0,
            requiredLevel = 0,
            counterStorage = 8386,
            questType = QUEST_TYPE.DEFEAT_POKEMON,
            questRequest = { "Easter Rabbit Shadow", 1 },
            canStart = function(cid) return getCreatureStorage(cid, 8384) == QUEST_STATUS.STARTED end,
            onEnd = function(cid) doPlayerAchievementCheck(cid, ACHIEVEMENT_IDS.EASTER_RABBIT) end
        },
        {
            storage = 8650,
            talk_questStarting = "I have a new mission for you!",
            talk_questStarted = "There remain some shadows of that creature yet! Please check back to that cave and defeat them.",
            talk_questFinishing = "Did you defeat the shadows?",
            talk_questFinished = "Thank you! Take this as a gift.",
            talk_questFinishFail = "Looks like you didn't.",
            talk_questDone = "I am complete now, thanks.",
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 25431, count = 1 } }, -- golden rabbit figurine
            rewardExp = 0,
            requiredLevel = 0,
            counterStorage = 8651,
            questType = QUEST_TYPE.DEFEAT_POKEMON,
            questRequest = { "Easter Rabbit Shadow", 5 },
            canStart = function(cid) return getCreatureStorage(cid, 8385) == QUEST_STATUS.FINISHED end,
            onEnd = function(cid) doPlayerAchievementCheck(cid, ACHIEVEMENT_IDS.EASTER_SHADOW_5_KILLS) end
        },
    },
    ["Alex"] = {
        {
            storage = 8387,
            talk_questStarting = "Oh, you want to test the new dive equipment? It's a long process though... First you must get some items that I can bring to the clothing manufacturer.",
            talk_questStarted = "You must bring me 200 furs, 30 ape hairs, 5 gyarados tails and 30 shell bells.",
            talk_questFinishing = "Did you get the items for the clothing manufacturer?",
            talk_questFinished = "That's great. The first part has been completed. Now we need to go {forward}.",
            talk_questFinishFail = "No!",
            talk_questDone = "",
            rewardItems = {},
            rewardExp = 0,
            requiredLevel = 50,
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 12086, 5, 14465, 30, 12145, 30, 12123, 200 },
        },
        {
            storage = 8388,
            talk_questStarting = "Now you need to get the oil of a Pokemon that lives in the lake of my land. Use the bottle on it. Do you want to go now?",
            talk_questStarted = "You can find the entrance to the south, remember to use your dive equipment. Good luck!",
            talk_questFinishing = "Did you get the Pokemon oil?",
            talk_questFinished = "Now you're ready for the {last} part, which is a favor for me.",
            talk_questFinishFail = "No!",
            talk_questDone = "",
            rewardItems = {},
            rewardExp = 0,
            requiredLevel = 50,
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 18881, 1 },
            questStartItems = { 18878, 1 }, -- empty bottle
        },
        {
            storage = 8389,
            talk_questStarting = "Hehe... Your new equipment is ready, but before I give it to you, I want you to find a black pearl in the sea. Can you do this for me?",
            talk_questStarted = "You will need to look into the depths of the ocean! Look for the old black shell, there you will find my pearl.",
            talk_questFinishing = "Did you get the black pearl?",
            talk_questFinished = "Congratulations, here is your dive equipment. Take good care!",
            talk_questFinishFail = "No!",
            talk_questDone = "",
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 18874, count = 1, unique = true } }, -- Good oxygen mask
            rewardExp = 0,
            requiredLevel = 50,
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 18876, 1 },
        },
    },
    ["Drew Wisdom"] = {
        {
            storage = 8391,
            talk_questStarting = "I've been studying ski clothing and finally figured out the best way to make it. It's not easy to make this outfit because it takes time and dedication, but if you bring me the necessary resources I can make one for you.",
            talk_questStarted = "First, I'll need 200 furs, 30 jynx clothes, 40 frozen hearts and 60 shards.",
            talk_questFinishing = "Did you get the items?",
            talk_questFinished = "Great. Now you are ready for the {second} part.",
            talk_questFinishFail = "Unfortunately not.",
            talk_questDone = "",
            rewardItems = {},
            rewardExp = 0,
            requiredLevel = 65,
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 12123, 200, 12109, 30, 14488, 40, 14506, 60 },
        },
        {
            storage = 8392,
            talk_questStarting = "For the second part, you need to bring me a piece of special cloth. There are many of them in my house, I can take you there, but you have to be careful when handling them because they are very fragile and tear easily. Are you ready?",
            talk_questStarted = "Ok, you'll find my house to the south! Good luck.",
            talk_questFinishing = "Did you bring the special piece of cloth?",
            talk_questFinished = "Congratulations, you have completed the second part successfully! But before I hand over your ski clothing, I need your {help} once again.",
            talk_questFinishFail = "Unfortunately not.",
            talk_questDone = "",
            rewardItems = {},
            rewardExp = 0,
            requiredLevel = 65,
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 18883, 1 },
        },
        {
            storage = 8393,
            talk_questStarting = "There is a very rare stone called the ice yolk stone; it's at the end of a large cave, guarded by powerful ice Pokemon. If you bring it to me, I will give you the ski clothing.",
            talk_questStarted = "Look for the large cave with the stone, good luck.",
            talk_questFinishing = "Did you bring the stone?",
            talk_questFinished = "Good job. Take your equipment.",
            talk_questFinishFail = "Unfortunately not.",
            talk_questDone = "",
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 18872, count = 1, unique = true } }, -- ski equipment
            rewardExp = 0,
            requiredLevel = 65,
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 18880, 1 },
        },
    },
    ["Darion Clive"] = {
        {
            storage = 8396,
            talk_questStarting = "It seems you've already proven your worth in our club. I have a new challenge for you, something really special. What do you think?",
            talk_questStarted = "There is a passage on that tile. Go through it and follow the dungeon's instructions. I'll wait here for your news.",
            talk_questFinishing = "Did you finish the dungeon?",
            talk_questFinished = "Brilliant. Congratulations, I bet you found a pleasant surprise over there.",
            talk_questFinishFail = "Unfortunately not. Maybe later...",
            talk_questDone = "",
            rewardItems = {},
            rewardExp = 0,
            requiredLevel = 80,
            questType = QUEST_TYPE.CUSTOM,
            questRequest = function(cid) return getCreatureStorage(cid, 60023) == QUEST_STATUS.FINISHED end,
            canStart = function(cid) return RangerClub.getPlayerRank(cid) >= RangerClub.RANK_IDS.COACH end
        },
    },
    ["Aldo Vumblevore"] = {
        --    {
        --      storage = 8406,
        --      talk_questStarting = "I'm preparing a powerful weapon to defeat Suramoon. But for this I need your help to collect some special items.",
        --      talk_questStarted = "Suramoon has seven special relics that he kept in his evil creatures. I need that you defeat these evil creatures and bring me the seven relics. You will find the creatures at the invasions that he send to the towns.",
        --      talk_questFinishing = "Did you find the seven relics?",
        --      talk_questFinished = "Wonderrrfulll! You are ... aaa .. great person, thank you! Now I'll build the weapon to defeat him.",
        --      talk_questFinishFail = "Unfortunately not. Maybe later...",
        --      talk_questDone = "",
        --      rewardItems = {{type = REWARD_TYPE.ADDON, female = {looktype = 1294, addons = 0}, male = {looktype = 1294, addons = 0}}},
        --      rewardExp = 0,
        --      requiredLevel = 0,
        --      questType = QUEST_TYPE.BRING_ITEMS,
        --      questRequest = {19092, 1, 19093, 1, 19094, 1, 19095, 1, 19096, 1, 19097, 1, 19098, 1},
        --    },
        {
            storage = 8670,
            talk_questStarting = "Friend! I'm working on a sinister cloth! How about helping me with this task?",
            talk_questStarted = "Great! I will need the following items: 50x Cursed Hand, 30x Cutting Fang, 50x Sharp Beak, 30x Spider Silk and 15x Shadow Orb.",
            talk_questFinishing = "Did you find what I asked for?",
            talk_questFinished = "Muauhauhmauha! Errr ... All right, congratulations! Here is the cloth I promised.",
            talk_questFinishFail = "Unfortunately not. Maybe later...",
            talk_questDone = "",
            rewardItems = { { type = REWARD_TYPE.ADDON, female = { looktype = 1705, addons = 3 }, male = { looktype = 1706, addons = 3 } } },
            rewardExp = 0,
            requiredLevel = 0,
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 14476, 50, 14477, 30, 12114, 50, 17811, 30, 12136, 15 },
        },
    },
    ["Selam"] = {
        {
            storage = 8408,
            talk_questStarting = "That damn Suramoon is using poor creatures as his evil army. I need your help to rescue them.",
            talk_questStarted = "Take this wand, it will purify the evil creatures' souls. But please, be very careful, they are not to blame!",
            talk_questFinishing = "Did you purify the poor creatures' souls?",
            talk_questFinished = "Really, you are very kind, thank you.",
            talk_questFinishFail = "Unfortunately not. Maybe later...",
            talk_questDone = "",
            rewardItems = { { type = REWARD_TYPE.ADDON, female = { looktype = 1296, addons = 0 }, male = { looktype = 1295, addons = 0 } } },
            rewardExp = 0,
            requiredLevel = 0,
            questType = QUEST_TYPE.CUSTOM,
            questRequest = function(cid) return getCreatureStorage(cid, 8409) >= 40 end,
            questStartItems = { 19099, 1 }, -- purifier wand
            onStart = function(cid)
                doCreatureSetStorage(cid, 8409, 0) -- Reset count storage
            end
        },
    },
    ["Assistant Guyli"] = {
        {
            storage = 8410,
            talk_questStarting = "Hello trainer, I see the Poke Ball... congratulations. Did the professor send you?",
            talk_questStarted = "I asked him for help. Some Pokemon from our reserves have been stressed lately, and we don't know how to handle it. Can you find help? We can't leave the lab for long. I'm sure someone in Pallet can help us. A girl, yes! I don't remember her name... ask her if she has a mission for you. Take a look around Pallet and return with good news!",
            talk_questFinishing = "Did you get the help?",
            talk_questFinished = "I knew it was a girl. Don't tell the professor that I forgot his granddaughter's name! Hehehe. Take this reward for your effort. And please, next time don't take so long... we were worried.",
            talk_questFinishFail = "No!",
            talk_questDone = "",
            rewardItems = {
                { type = REWARD_TYPE.ITEM, id = 12244, count = 15, unique = true }, -- potions
                { type = REWARD_TYPE.ITEM, id = 2152, count = 5 }, -- 500 dollars
            },
            rewardExp = 500,
            requiredLevel = 10,
            questType = QUEST_TYPE.CUSTOM,
            questRequest = function(cid) return getCreatureStorage(cid, 8412) == QUEST_STATUS.FINISHED end, -- Daisy Oak quest #2
        },
    },
    ["Daisy Oak"] = {
        {
            storage = 8411,
            talk_questStarting = "I treat Pokemon's emotional problems with special treatments. How did you find out about me?",
            talk_questStarted = "Oh yes, the Pokemon feel cramped in the reserve and end up stressed. I'll see what I can do. I was going to see my brother Gary; he called me sounding worried. Can you check on him while I go to the lab? Please come back after talking to him. He is in Viridian City.",
            talk_questFinishing = "I see you're back. Any news from my brother?",
            talk_questFinished = "Hmmm... His suspicions were confirmed. We are facing something bigger than we imagined. Be sure to help my brother. I need you to get an herb from the {mountain} for me, so I can make some Pokemon tea.",
            talk_questFinishFail = "Looks like you didn't.",
            talk_questDone = "",
            rewardItems = {},
            rewardExp = 0,
            requiredLevel = 10,
            questType = QUEST_TYPE.CUSTOM,
            canStart = function(cid) return getCreatureStorage(cid, 8410) ~= QUEST_STATUS.UNSTARTED end, -- Guyli's Assitant quest #1
            questRequest = function(cid) return getCreatureStorage(cid, 8413) == QUEST_STATUS.FINISHED end, -- Gary Oak quest #1
        },
        {
            storage = 8412,
            talk_questStarting = "I need you to get an herb from the mountain for me, so I can make some Pokemon tea.",
            talk_questStarted = "It has a powerful sedative. Take this knife, use it on the plant and bring me back a piece.",
            talk_questFinishing = "Did you get the plant extract?",
            talk_questFinished = "Great, tell Assistant Guyli that I'm already on my way. Thanks for all your help.",
            talk_questFinishFail = "Looks like you didn't.",
            talk_questDone = "",
            rewardItems = {},
            rewardExp = 0,
            requiredLevel = 10,
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 23532, 1 }, -- a acid foxglove extraction (the knife is taken when the player cut the plant)
            canStart = function(cid) return getCreatureStorage(cid, 8411) ~= QUEST_STATUS.UNSTARTED end, -- Daisy Oak quest #1
            questStartItems = { 23534, 1 }, -- daisy oak's knife
        },
    },
    ["Gary Oak"] = {
        {
            storage = 8413,
            talk_questStarting = "My sister isn't coming? Great, she sent a trainer I don't know to help me. Don't bother me, I'm on a mission... But since you're so interested, you might be useful.",
            talk_questStarted = "I'm investigating a disappearance. I need to check some places west of here. You will help me. Take this magnifier, you may need it. Use it on suspicious places. Report to me when you find something.",
            talk_questFinishing = "Did you find something?",
            talk_questFinished = "I found signs of battle here too. But it seems the fight moved away from here. I'll keep looking. But first, I want to test you. Let's {battle}.",
            talk_questFinishFail = "No... Keep looking.",
            talk_questDone = "",
            rewardItems = {},
            rewardExp = 0,
            requiredLevel = 10,
            questType = QUEST_TYPE.CUSTOM,
            canStart = function(cid) return getCreatureStorage(cid, 8411) ~= QUEST_STATUS.UNSTARTED end, -- Guyli's Assitant quest #1
            questRequest = function(cid) return getCreatureStorage(cid, 8415) == QUEST_STATUS.FINISHED and
                    getCreatureStorage(cid, 8416) == QUEST_STATUS.FINISHED and
                    getPlayerItemCount(cid, 23533) > 0
            end,
            questStartItems = { 23533, 1 }, -- gary oak's magnifier
            onEnd = function(cid) doPlayerRemoveItem(cid, 23533, getPlayerItemCount(cid, 23533)) end, -- remove gary oak's magnifier
            startPosition = { x = 3304, y = 603, z = 7 },
            finishPosition = { x = 3304, y = 603, z = 7 }
        },
        {
            -- Started automatically by the battle
            storage = 8414,
            talk_questStarting = "",
            talk_questStarted = "",
            talk_questFinishing = "Hah, what about our battle, huh?",
            talk_questFinished = "Beautiful battle. Tell my sister that I'm fine and that my suspicions were confirmed. I see I can trust you. Meet me again at Mt. Moon. Before that you can visit Pewter and see the city. Some people may need help. But be sure to talk to my sister Daisy first.",
            talk_questFinishFail = "No... Keep looking.",
            talk_questDone = "",
            rewardItems = {},
            rewardExp = 0,
            requiredLevel = 10,
            questType = QUEST_TYPE.CUSTOM,
            canStart = function(cid) return getCreatureStorage(cid, 8413) == QUEST_STATUS.FINISHED end, -- Gary Oak quest #1
            questRequest = function(cid) return getPlayerDefeatedNPC(cid, 9674) end,
            startPosition = { x = 3304, y = 603, z = 7 },
            finishPosition = { x = 3304, y = 603, z = 7 }
        },
        {
            storage = 8417,
            talk_questStarting = "Glad you came. We are all very worried and any help is welcome. Are you willing to help us now?",
            talk_questStarted = "Now there's no turning back. I'll tell you everything. Ash Ketchum from Pallet Town is gone. Our last contact was when he was coming home from a visit to another continent with info about new Pokemon. He emailed me the location of his arrival, but I couldn't find him myself. The battle signs we saw in Viridian show he was there. We were supposed to meet there. I talked to his mother and she knew nothing. My grandfather can't contact him, and since he is the league champion... everyone is concerned. He may have been ambushed. The clues I followed brought me here. Everything indicates he was taken by someone. Ash kept a diary where he wrote his achievements and some notes. I found one of its torn pages near here. If we could find more of this diary... so we need to split up. Take this magnifier and see what you can do. I will mark on your map where you must begin the search; use the magnifier everywhere. The trail could be anywhere.",
            talk_questFinishing = "How did you end up here...?",
            talk_questFinished = "It doesn't matter now. I found a piece of torn page that might give me some information. Go to Pallet Town and talk to Delia, Ash's mom. Tell her we're making progress. I'll call you when I need you. Now go!",
            talk_questFinishFail = "Looks like you didn't.",
            talk_questDone = "",
            rewardItems = {},
            rewardExp = 500,
            requiredLevel = 10,
            questType = QUEST_TYPE.CUSTOM,
            questRequest = function(cid)
                return getPlayerItemCount(cid, 23533) > 0 and getCreatureStorage(cid, 8509) == QUEST_STATUS.FINISHED
            end,
            canStart = function(cid) return getCreatureStorage(cid, 8410) == QUEST_STATUS.FINISHED --[[ and getSamePosition(getCreaturePosition(getNpcId()), {x = 932, y = 262, z = 7})]] end, -- Kanto Main #1 complete (Assistant Guyli)
            questStartItems = { 23533, 1 }, -- gary oak's magnifier
            onEnd = function(cid)
                doPlayerRemoveItem(cid, 23533, getPlayerItemCount(cid, 23533)) -- remove gary oak's magnifier
                doCreatureSetStorage(cid, 8419, QUEST_STATUS.STARTED) -- Autostart 8419
            end,
            onStart = function(cid)
                doPlayerAddMapMark(cid, { x = 3546, y = 300, z = 5 }, MAPMARK_EXCLAMATION, "Ash Ketchum search location.")
            end,
            startPosition = { x = 3304, y = 603, z = 7 },
            finishPosition = { x = 3450, y = 245, z = 7 }
        },
        {
            -- Auto started by 8417
            storage = 8419,
            talk_questStarting = "",
            talk_questStarted = "",
            talk_questFinishing = "Have you already spoken to Delia?",
            talk_questFinished = "I've made more progress; this time you should go alone. I need to take care of some of my own business. Talk to Bill, he knows everything. He is in his tower north of Cerulean.",
            talk_questFinishFail = "Looks like you didn't.",
            talk_questDone = "",
            rewardItems = {
                { type = REWARD_TYPE.ITEM, id = 12245, count = 10, unique = true }, -- pokemon great health potion
                { type = REWARD_TYPE.ITEM, id = 13653, count = 15, unique = true }, -- pokemon energy potion
            },
            rewardExp = 500,
            requiredLevel = 10,
            questType = QUEST_TYPE.CUSTOM,
            questRequest = function(cid) return getCreatureStorage(cid, 8418) == QUEST_STATUS.FINISHED end,
            blockStart = true, -- Auto started
            finishPosition = { x = 3282, y = 262, z = 7 }
        },
        {
            storage = 8520,
            talk_questStarting = "Good to see you again. We are grateful for your help so far, trainer. My recent research and your findings lead me to believe that Ash is locked inside the Silph Co. building. It keeps many secrets and everything suggests it is Team Rocket's lair. All you need to do is get in unnoticed and expose them all. Do you think you can?",
            talk_questStarted = "Beware of any kind of trap there. Pay attention to the floors and doors, and remember not to make too much noise. If you find a Rocket, fight him. I think Ash is there. Take this elevator access card. Good luck.",
            talk_questFinishing = "Did you find him?",
            talk_questFinished = "You found him! Very good! We need to be discreet now. We must put an end to Team Rocket and go after those responsible for all this. Ash needs to recover and we're counting on you to expose everything! Tell Bill what happened and let's begin!",
            talk_questFinishFail = "Looks like you didn't.",
            talk_questDone = "",
            rewardItems = {
                { type = REWARD_TYPE.ADDON, female = { looktype = 1382, addons = 0 }, male = { looktype = 1383, addons = 0 } },
            },
            rewardExp = 0,
            requiredLevel = 10,
            questStartItems = { 25056, 1 },
            questType = QUEST_TYPE.CUSTOM,
            questRequest = function(cid) return getCreatureStorage(cid, 8525) == QUEST_STATUS.FINISHED end, -- Ash Ketchum following
            canStart = function(cid) return getCreatureStorage(cid, 8517) == QUEST_STATUS.FINISHED end,
            onEnd = function(cid)
                doCreatureSetStorage(cid, 8526, QUEST_STATUS.STARTED) -- Auto start Bill part
            end
        },
    },
    ["Delia Ketchum"] = {
        {
            storage = 8418,
            talk_questStarting = "Oh, I'm so worried! Have you and Gary made any progress?",
            talk_questStarted = "Oh, Ash! He must be going through trouble. I received a letter from him days ago. I put it in my trunk upstairs. Read it yourself and return here.",
            talk_questFinishing = "Did you read the letter?",
            talk_questFinished = "I'm sure someone got hold of this information. I think Ash has been kidnapped! Gary asked you to go see him in Pewter. Please find Ash!",
            talk_questFinishFail = "Looks like you didn't.",
            talk_questDone = "",
            rewardItems = {},
            rewardExp = 0,
            requiredLevel = 10,
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 23538, 1 }, -- ash's letter
            canStart = function(cid) return getCreatureStorage(cid, 8417) == QUEST_STATUS.FINISHED end, -- Gary Oak quest #3
        },
        {
            storage = 8377,
            talk_questStarting = "Are you very busy? I need a big favor!",
            talk_questStarted = "My Ash needs this honey pot to save a sick Pokemon, please take it to him. You will find him next to the S.S. Anne boat in Vermilion.",
            talk_questFinishing = "Did you find Ash?",
            talk_questFinished = "Congratulations, you are a great Pokemon trainer!",
            talk_questFinishFail = "Looks like you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.CUSTOM,
            questRequest = function(cid) return false end, -- AutoEnd with Ash Ketchum 8379
            rewardItems = {},
            rewardExp = 0,
            requiredLevel = 60,
            questStartItems = { 18755, 1 },
            onStart = function(cid) doCreatureSetStorage(cid, 8378, QUEST_STATUS.STARTED) end
        }
    },
    ["Bill"] = {
        {
            storage = 8421,
            talk_questStarting = "So you are the trainer Gary told me about... I see.",
            talk_questStarted = "I have new information on Ash's whereabouts. I sent him to the Sevii Islands a while ago to collect data for my research. When he came back, he told me he might be being followed. He had my equipment, and luckily I put a tracking device inside. I need to track him. Meanwhile, go to Cerulean and warn the authorities about this case. Come back when you've done it.",
            talk_questFinishing = "Did you notify the authorities?",
            talk_questFinished = "Finally some good news. Good to know that everyone is working to {find} Ash.",
            talk_questFinishFail = "Looks like you haven't.",
            talk_questDone = "",
            rewardItems = {},
            rewardExp = 0,
            requiredLevel = 10,
            questType = QUEST_TYPE.CUSTOM,
            questRequest = function(cid) return getCreatureStorage(cid, 8422) == QUEST_STATUS.FINISHED end, -- Officer Jeny quest #1
            canStart = function(cid) return getCreatureStorage(cid, 8419) ~= QUEST_STATUS.UNSTARTED end, -- Gary Oak quest #4
        },
        {
            storage = 8431,
            talk_questStarting = "My device is sending signals from Vermilion. Go investigate.",
            talk_questStarted = "It's the city south of Saffron.",
            talk_questFinishing = "Did you find the device?",
            talk_questFinished = "I can't believe it! So the rumors may be true. Does he exist? Thanks for the help. I think the next step is to follow the meaning of this message. Try searching the town, I bet that's it. Take this ticket to the S.S. Anne and investigate it for clues about Ash. It's the ship docked at Vermilion. You need a ticket to board.",
            talk_questFinishFail = "Looks like you didn't.",
            talk_questDone = "",
            rewardItems = {
                { type = REWARD_TYPE.ITEM, id = 23540, count = 1, unique = true }, -- S.S. Anne Ticket
                { type = REWARD_TYPE.ITEM, id = 2152, count = 35 }, -- 3500 dollars
                { type = REWARD_TYPE.ITEM, id = 12246, count = 20 }, -- pokemon ultra health potion
            },
            rewardExp = 1000,
            requiredLevel = 10,
            questType = QUEST_TYPE.CUSTOM,
            questRequest = function(cid) return getCreatureStorage(cid, 8432) == QUEST_STATUS.FINISHED end, -- Bill signal device used
            canStart = function(cid) return getCreatureStorage(cid, 8421) == QUEST_STATUS.FINISHED end, -- Bill quest #4
        },
        {
            storage = 8510,
            talk_questStarting = "I see you found a lot of things! Are you saying you saw the legendary Mew? You're the only person I know who has seen it! I'll need more details later. For now we have a big problem.",
            talk_questStarted = "Dr. Fuji was a great Pokemon researcher on Cinnabar Island. He was living in Lavender, where he took care of orphaned Pokemon. He was kidnapped for some reason and is being held by Team Rocket at the top of the tower. Please rescue him from the clutches of these criminals, maybe we can learn something from this... everything about this story is very strange.",
            talk_questFinishing = "Did you help Dr. Fuji?",
            talk_questFinished = "Very nice, thanks! I've got another {task} for you when you're ready.",
            talk_questFinishFail = "Looks like you didn't.",
            talk_questDone = "",
            rewardItems = {},
            rewardExp = 2000,
            requiredLevel = 10,
            questType = QUEST_TYPE.CUSTOM,
            questRequest = function(cid) return getCreatureStorage(cid, 8511) == QUEST_STATUS.FINISHED end, -- Mr Fuji
            canStart = function(cid) return getCreatureStorage(cid, 60026) == QUEST_STATUS.FINISHED end, -- Bill quest #4
        },
        {
            storage = 8517,
            talk_questStarting = "Great news about Mr. Fuji. You are doing a very good job trainer. Tell me what happened there.",
            talk_questStarted = "It can't be true! We must find Ash's Pikachu quickly, he must be scared! I have to think of a way... the real work begins now, trainer! You look for information on the balloon Mr. Fuji saw, and I'll tell Gary about our findings, we need a way to find Pikachu. Go to Celadon, maybe someone can help there. Contact the owner of the hotel there, Briscoe Len. He's an old friend of mine. Good luck.",
            talk_questFinishing = "I can't believe it... this organization is going too far. We will need all the help we can get to stop them. You mean you found Ash's Pikachu?",
            talk_questFinished = "That's great. Give him to me... there. I'll let him rest. He's been through a lot. I need you to talk to Gary for the next step. I believe we are getting closer to finding Ash. When Pikachu wakes up I'll learn what I can from him... once again, congratulations. Take this Doll Case I developed, it can store all your dolls without taking up space in your backpack.",
            talk_questFinishFail = "Looks like you didn't.",
            talk_questDone = "",
            rewardItems = {
                { type = REWARD_TYPE.ITEM, id = 23463, count = 1, unique = true }, -- doll case
            },
            rewardExp = 0,
            requiredLevel = 10,
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 25052, 1, 25053, 1 },
            canStart = function(cid) return getCreatureStorage(cid, 8510) == QUEST_STATUS.FINISHED end,
            onEnd = function(cid)
                local pos1 = { x = 4029, y = 149, z = 3 }

                if (isItem(getTileItemById(pos1, 25054))) then
                    return
                end

                local relocatePos = { x = 4030, y = 149, z = 3 }
                doRelocate(pos1, relocatePos, true)
                doCreateItem(25054, 1, pos1)
                doSendMagicEffect(pos1, EFFECT_POFF)

                local pos2 = { x = 4029, y = 150, z = 3 }
                doRelocate(pos2, relocatePos, true)
                doCreateItem(14432, 1, pos2)
                doSendMagicEffect(pos2, EFFECT_POFF)

                addEvent(function()
                    doRemoveItem(getTileItemById(pos1, 25054).uid)
                    doRemoveItem(getTileItemById(pos2, 14432).uid)
                end, 10 * 60 * 1000)
            end
        },
        {
            storage = 8526,
            blockStart = true, -- Auto started
            talk_questStarting = "",
            talk_questStarted = "",
            talk_questFinishing = "Finally! Congratulations trainer. Now I must meet Ash to clear up this whole story, and we're counting on you for the next step. Ok?",
            talk_questFinished = "Meanwhile, you can {help} us on another task.",
            talk_questFinishFail = "Looks like you didn't.",
            talk_questDone = "",
            rewardItems = {},
            rewardExp = 0,
            requiredLevel = 10,
            questType = QUEST_TYPE.CUSTOM,
            questRequest = function(cid) return true end, -- There is nothing really to do
        },
        {
            storage = 8527,
            talk_questStarting = "We saw a strange figure walking by the other day, wearing a coat and hood. We need to know his intentions... and above all, who he is. Maybe you could look into it.",
            talk_questStarted = "Okay, as soon as you find something, come to me!",
            talk_questFinishing = "Did you find out something about the strange guy?",
            talk_questFinished = "Amazing! So the masked one is supposedly on our side. If Team Rocket is behind all this, then we must return to the Team Rocket base in Celadon and try to break down the closed doors. Go there and look for more clues; meanwhile I will find out more about this island mentioned in the book.",
            talk_questFinishFail = "Looks like you didn't.",
            talk_questDone = "",
            rewardItems = {},
            rewardExp = 0,
            requiredLevel = 10,
            questType = QUEST_TYPE.CUSTOM,
            questRequest = function(cid) return getCreatureStorage(cid, 8529) == QUEST_STATUS.FINISHED end,
            canStart = function(cid) return getCreatureStorage(cid, 8526) == QUEST_STATUS.FINISHED end, -- Bill quest
        },
        {
            storage = 8542,
            talk_questStarting = "Amazing! So the masked one is supposedly on our side.",
            talk_questStarted = "If Team Rocket is behind all this, then we must return to the Team Rocket base in Celadon and try to break down the closed doors. Go there and look for more clues; meanwhile I will find out more about this island mentioned in the book.",
            talk_questFinishing = "Did you find anything there?",
            talk_questFinished = "I knew I could still count on my dear friend Briscoe Len! Now we'll find out more about Team Rocket. Come back in one hour, I'll find out everything on this HD.",
            talk_questFinishFail = "Looks like you didn't.",
            talk_questDone = "",
            rewardItems = {},
            rewardExp = 0,
            requiredLevel = 10,
            questType = QUEST_TYPE.CUSTOM,
            questRequest = function(cid)
                return getCreatureStorage(cid, 8546) == QUEST_STATUS.FINISHED and isItem(getPlayerItemById(cid, true, 25191))
            end, -- Mistery Guy
            canStart = function(cid) return getCreatureStorage(cid, 8527) == QUEST_STATUS.FINISHED end, -- Bill quest
            onStart = function(cid)
                doCreatureSetStorage(cid, 8543, 0)
            end,
            onEnd = function(cid)
                doCreatureSetStorage(cid, 8549, os.time())
                doCreatureSetStorage(cid, 8550, QUEST_STATUS.STARTED)
                doPlayerRemoveItem(cid, 25191, getPlayerItemCount(cid, 25191))
            end
        },
        --[[{
            storage = 8548,
            talk_questStarting = "Amazing! Then the masked supposedly is on our side.",
            talk_questStarted = "If the rocket team is behind it all then we must return to the base of the rocket team in Celadon, try to destroy the closed doors. Go there and look for more clues about it all the meantime I will find out more about this island mentioned in the book.",
            talk_questFinishing = "Can you find something there?",
            talk_questFinished = "I knew I could still count on my dear friend Briscoe Len!",
            talk_questFinishFail = "Likes no.",
            talk_questDone = "",
            rewardItems = {
            },
            rewardExp = 0,
            requiredLevel = 10,
            questType = QUEST_TYPE.CUSTOM,
            questRequest = function(cid) return getCreatureStorage(cid, 8546) == QUEST_STATUS.FINISHED end, -- Mistery Guy
            canStart = function(cid) return getCreatureStorage(cid, 8527) == QUEST_STATUS.FINISHED end, -- Bill quest
            onStart = function(cid)
                doCreatureSetStorage(cid, 8543, 0)
            end,
            onEnd = function(cid)
                doCreatureSetStorage(cid, 8549, os.time())
                doCreatureSetStorage(cid, 8550, QUEST_STATUS.STARTED)
            end
        },]]
        {
            storage = 8550,
            talk_questStarting = "",
            talk_questStarted = "",
            talk_questFinishing = "Oh, you came to see the HD result?",
            talk_questFinished = "I discovered that Team Rocket has a very powerful pokeball and they intend to recapture Mewtwo, we need to {capture} Mewtwo before them!",
            talk_questFinishFail = "Looks like you didn't.",
            talk_questDone = "",
            rewardItems = {},
            rewardExp = 0,
            requiredLevel = 10,
            questType = QUEST_TYPE.CUSTOM,
            questRequest = function(cid)
                local diff = (getCreatureStorage(cid, 8549) + (60 * 60) - os.time())
                if (diff > 0) then
                    selfSay(string.format(__L(cid, "You must wait %s to continue."), table.concat(string.timediff(diff, cid))), cid)
                    return false
                end
                return true
            end, -- todo
            blockStart = true,
        },
        {
            storage = 8551,
            talk_questStarting = "First we need the Master Ball they have.",
            talk_questStarted = "Go to Silph Co. again and ask the scientist in charge if he knows something, his name is Charley Aden.",
            talk_questFinishing = "Did you find the Master Ball?",
            talk_questFinished = "Great, now with the Master Ball we have a chance. I found out where the island Dr. Fuji mentioned is: it's southwest of Kanto. According to him, the laboratory there was destroyed. Go there and look for more clues about Mewtwo.",
            talk_questFinishFail = "Looks like you didn't.",
            talk_questDone = "",
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 17364, count = 1, unique = true }, { type = REWARD_TYPE.ITEM, id = 27774, count = 1, unique = true } }, -- TM 28 (Move Mimic), Small Asteroid Fragment
            rewardExp = 0,
            requiredLevel = 10,
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 27425, 1 },
            onEnd = function(cid)
                doCreatureSetStorage(cid, 8555, QUEST_STATUS.STARTED)
            end,
            canStart = function(cid) return getCreatureStorage(cid, 8550) == QUEST_STATUS.FINISHED end, -- Bill quest
        },
        {
            storage = 8555,
            talk_questStarting = "",
            talk_questStarted = "",
            talk_questFinishing = "Did you find the laboratory?",
            talk_questFinished = "I can't believe we couldn't capture Mewtwo, but at least Team Rocket is out of the way for now. I still can't believe all this happened... I almost forgot, I have a gift for you, it's the way I found to reward you for this great help. Thank you, trainer.",
            talk_questFinishFail = "Looks like you didn't.",
            talk_questDone = "",
            rewardItems = {
                { type = REWARD_TYPE.ITEM, id = 18931, count = 1, unique = true }, -- TM 67 (Move Nightmare)
                { type = REWARD_TYPE.ITEM, id = 27773, count = 1, unique = true }, -- Big Asteroid Fragment
                { type = REWARD_TYPE.ADDON, female = { looktype = 1703, addons = 0 }, male = { looktype = 1704, addons = 0 } }
            },
            rewardExp = 0,
            requiredLevel = 10,
            questType = QUEST_TYPE.CUSTOM,
            questRequest = function(cid)
                return getCreatureStorage(cid, 8561) == QUEST_STATUS.FINISHED
            end,
            blockStart = true
        },
    },
    ["Officer Jeny"] = {
        --[[{
            storage = 8563,
            talk_questStarting = "It was like this picture?",
            talk_questStarted = "So is what we think, Grinch is the prime suspect, there are reports that he may have a hideout. Unfortunately I have to stay here as he can appears, please, if you find out anything about this hideout tell me, can you help me? Okay, so look for any clues. The sewers are a nice place to start out.",
            talk_questFinishing = "You found any clues?",
            talk_questFinished = "Hm, this old rag has the green furs, seems to be the same suspect we talk, please come back to the place and use this device to show if there is a false wall nearby, I will inform my superiors, we will met there.",
            talk_questFinishFail = "Likes no.",
            talk_questDone = "",
            rewardItems = {
                {type = REWARD_TYPE.ITEM, id = 25246, count = 1, unique = true}, -- jenny's radar
            },
            rewardExp = 0,
            requiredLevel = 10,
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = {25244, 1},
            startPosition = {x = 3073, y = 383, z = 7},
            finishPosition = {x = 3073, y = 383, z = 7},
            onEnd = function(cid)
                doCreatureSetStorage(cid, 8649, QUEST_STATUS.STARTED) -- Just for questlog
            end
        },
        {
            storage = 8641,
            talk_questStarting = "Glad you came, I should not have come alone, I fell into a trap, can you help me?",
            talk_questStarted = "Please try to find some way to get me out, but beware, here is full of traps, the suspect is very cunning, stay tuned.",
            talk_questFinishing = "You found anything to help me?",
            talk_questFinished = "To this must help, thank you, but I turn here, please collect some clues in this house did I think while I try to get rid of here. Go.",
            talk_questFinishFail = "Where is the saw?",
            talk_questDone = "",
            rewardItems = {
            },
            rewardExp = 0,
            requiredLevel = 10,
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = {25245, 1},
            startPosition = {x = 1548, y = 329, z = 10},
            finishPosition = {x = 1548, y = 329, z = 10},
            onStart = function(cid)
                doCreatureSetStorage(cid, 8649, QUEST_STATUS.FINISHED) -- Just for questlog
            end
        },]]
        {
            storage = 8422,
            talk_questStarting = "I understand! Will you help me with this problem?",
            talk_questStarted = "Take these 8 posters to Cerulean and Pewter and put them up. I will tell the authorities in other cities to do the same. I'll mark on your map the spots where you need to put them up, 4 in each city. Go!",
            talk_questFinishing = "Did you put up all the posters?",
            talk_questFinished = "Great. That's all we can do for now. We are putting all our efforts into finding the Pokemon League Champion. Let us know about any new leads! Take this money for your effort.",
            talk_questFinishFail = "Looks like you don't have it yet.",
            talk_questDone = "",
            rewardItems = {
                { type = REWARD_TYPE.ITEM, id = 2152, count = 15 }, -- 1500 dollars
            },
            rewardExp = 500,
            requiredLevel = 10,
            questType = QUEST_TYPE.CUSTOM,
            questRequest = function(cid)
                for storage = 8423, 8430 do -- Check if all posters were placeds
                    if (getCreatureStorage(cid, storage) ~= QUEST_STATUS.FINISHED) then
                        return false
                    end
                end
                return true
            end,
            canStart = function(cid) return getCreatureStorage(cid, 8421) == QUEST_STATUS.STARTED end, -- Bill quest #1
            questStartItems = { 23555, 8 },
            onStart = function(cid)
                local POSTERS = {
                    { x = 3336, y = 282, z = 7 },
                    { x = 3288, y = 259, z = 7 },
                    { x = 3297, y = 353, z = 7 },
                    { x = 3311, y = 302, z = 7 },
                    { x = 3892, y = 275, z = 7 },
                    { x = 3859, y = 291, z = 7 },
                    { x = 3879, y = 320, z = 7 },
                    { x = 3927, y = 291, z = 7 },
                }

                for _, pos in pairs(POSTERS) do
                    doPlayerAddMapMark(cid, pos, MAPMARK_EXCLAMATION, "Officer Jeny poster location")
                end
            end
        },
        {
            storage = 8017,
            talk_questStarting = "We're on a very strange case: Nurse Joy's Chanseys are simply disappearing from the Pokemon centers... We are accepting help from everyone. Will you help us?",
            talk_questStarted = "Thanks! We know Team Rocket is involved in this, so we need to find them. We have information that one of their bases is in Celadon. Take these 5 special balls, and use them on the Chanseys when you find them.",
            talk_questFinishing = "Did you find Team Rocket? The Chanseys?",
            talk_questFinished = "Thank you! You helped us a lot. Hmm? It seems one of the Chanseys likes you, take care of it!",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more missions for now.",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 13817, 5, 13812, 1, 13813, 1, 13814, 1, 13815, 1 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14029, count = 1 } }, -- chansey egg
            rewardExp = 5000,
            requiredLevel = 70,
            questStartItems = { 13816, 5 },
            onEnd = function(cid) doCreatureSetStorage(cid, 8201, 1) end -- Quest refund storage, new players doesn't need it
        }
    },
    ["Captain Neil Pace"] = {
        {
            storage = 8433,
            talk_questStarting = "Aha! You're the new recruit! We were waiting for you. Before I show you where you'll sleep and hand you the broom to clean the ship, you must prove yourself in front of the entire crew. Can you do that?",
            talk_questStarted = "Go and prove your worth against my sailors. Defeat them all and then you will have your place on our ship!",
            talk_questFinishing = "Did you defeat all our brave and valiant sailors?",
            talk_questFinished = "Everyone told me that you are a great trainer, that's a great start. Open that box in the corner and take your uniform. I hope I can count on you again.",
            talk_questFinishFail = "Looks like you didn't.",
            talk_questDone = "",
            rewardItems = {},
            rewardExp = 0,
            requiredLevel = 40,
            questType = QUEST_TYPE.CUSTOM,
            questRequest = function(cid)
                for storage = 9675, 9679 do
                    if (not getPlayerDefeatedNPC(cid, storage)) then
                        return false
                    end
                end
                return true
            end,
            canStart = function(cid) return getCreatureStorage(cid, 8431) == QUEST_STATUS.FINISHED end, -- Bill quest #2
        },
        {
            storage = 8435,
            talk_questStarting = "Recruit, you have to help us!",
            talk_questStarted = "They fled with the ship's ignition key! Talk to the First Mate to find out where they went! Please hurry!",
            talk_questFinishing = "Did you recover the ignition key?",
            talk_questFinished = "You did a very good thing, my lad. Sorry for mistaking you for a recruit for our ship. You were a true hero today and deserve to be rewarded. Oh, I almost forgot... upstairs you will find my trunk with a reward. Make good use of it, you have our eternal gratitude! Damn Rockets! I don't know what they wanted with my ship. I recently heard rumors of a secret facility in Celadon.",
            talk_questFinishFail = "Looks like you didn't.",
            talk_questDone = "",
            rewardItems = {},
            rewardExp = 15000, -- 20% from level 40 to 41
            requiredLevel = 40,
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 23542, 1 }, -- ignition key
            canStart = function(cid) return getCreatureStorage(cid, 8434) == QUEST_STATUS.FINISHED end, -- Captain Neil Pace trunk opened
        },
    },
    ["Rocket Captain"] = {
        {
            storage = 8436,
            talk_questStarting = "That useless guard let you in. What do you want?!",
            talk_questStarted = "You want to know what we're doing here? Okay... since you're snooping, take this broom and help us clean up this mess. Use it to clean the floor of this room. Clean 7 places and return.",
            talk_questFinishing = "Did you do the cleaning?",
            talk_questFinished = "Great, that helped. Now go look for whatever you came for. Do not enter the lab, this is a warning! To get in you need the card. We lost it, so try to find that too... now get lost!",
            talk_questFinishFail = "Looks like you didn't.",
            talk_questDone = "",
            rewardItems = {},
            rewardExp = 15000, -- 12% from level 50 to 51
            requiredLevel = 50,
            questType = QUEST_TYPE.CUSTOM,
            questRequest = function(cid)
                for _, storage in pairs({ 8437, 8438, 8483, 8484, 8485, 8486, 8487 }) do
                    if (getCreatureStorage(cid, storage) ~= QUEST_STATUS.FINISHED) then
                        return false
                    end
                end
                return true
            end,
            questStartItems = { 23560, 1 }, -- captain rocket broom
            canStart = function(cid) return getCreatureStorage(cid, 8431) == QUEST_STATUS.FINISHED end, -- Bill quest #2
            onEnd = function(cid)
                doPlayerRemoveItem(cid, 23560, getPlayerItemCount(cid, 23560)) -- captain rocket broom
            end
        },
    },
    ["Justin Flowers"] = {
        {
            storage = 8439,
            talk_questStarting = "My Pokemon is undergoing a treatment with exotic blooms. He really likes music, and I believe that is the only way to wake him up in time.",
            talk_questStarted = "You must find a Blue Flute to wake him.",
            talk_questFinishing = "Did you find the flute and wake up my Pokemon?",
            talk_questFinished = "Thanks, now he can eat before going back to sleep and meditating. Thanks again, keep this for being a very nice trainer.",
            talk_questFinishFail = "Doesn't look like it.",
            talk_questDone = "",
            rewardItems = {
                { type = REWARD_TYPE.ADDON, female = { looktype = 2575, addons = 0 }, male = { looktype = 2576, addons = 0 } },
                { type = REWARD_TYPE.ITEM, id = 2152, count = 50 }
            },
            rewardExp = 37100, -- 50% of 40 to 41
            requiredLevel = 40,
            questType = QUEST_TYPE.CUSTOM,
            questRequest = function(cid)
                return getCreatureStorage(cid, 8440) == QUEST_STATUS.FINISHED
            end,
        },
    },
    ["London Hamnet"] = {
        {
            storage = 8441,
            talk_questStarting = "This home has a problem. It is smelly, some problem! I know it's not your problem, but could you help this old man?",
            talk_questStarted = "Take a look around to see from where comes this smell of poop!",
            talk_questFinishing = "You found the problem?",
            talk_questFinished = "I can not believe! And he is with a {red} smoke?!",
            talk_questFinishFail = "Looks like you didn't.",
            talk_questDone = "",
            rewardItems = {},
            rewardExp = 0,
            requiredLevel = 20,
            questType = QUEST_TYPE.CUSTOM,
            questRequest = function(cid)
                return getCreatureStorage(cid, 8443) == QUEST_STATUS.FINISHED
            end,
        },
        {
            storage = 8442,
            talk_questStarting = "This only indicates that he is sick and lost. That can only be the work of another trainer who left his Pokemon out there. A shame!",
            talk_questStarted = "Well, I know a way to help him. Look for a mushroom around Mt. Moon. It is blue in color. Use a Pokemon to cut it. Bring to me and we can heal Weezing.",
            talk_questFinishing = "You got the mushroom?",
            talk_questFinished = "Great. Here is, take it to the Weezing. Once it heals, take him by the passage that I found when I went to visit him. He liked to see the sun again. Thank you trainer.",
            talk_questFinishFail = "Looks like you didn't.",
            talk_questDone = "",
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 23565, count = 1, unique = true } }, -- pokemon gas medicine, to use on the next quest
            rewardExp = 0,
            requiredLevel = 20,
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 23564, 1 }, -- blue weed
            onEnd = function(cid)
                doCreatureSetStorage(cid, 8444, QUEST_STATUS.STARTED) -- Autostart 8444
            end
        },
        {
            -- Auto started by 8442
            storage = 8444,
            talk_questStarting = "",
            talk_questStarted = "",
            talk_questFinishing = "Did you helped the Weezing?",
            talk_questFinished = "Thanks for your great help. Take this as thanks!",
            talk_questFinishFail = "Looks like you didn't.",
            talk_questDone = "",
            rewardItems = {
                { type = REWARD_TYPE.ITEM, id = 12249, count = 10 }, -- pokemon antidote
                { type = REWARD_TYPE.ITEM, id = 13178, count = 2 }, -- seed of pecha berry
                { type = REWARD_TYPE.ITEM, id = 2152, count = 9 }, -- 900 dl
            },
            rewardExp = 17200, -- Exp from level 20 to 21
            requiredLevel = 20,
            questType = QUEST_TYPE.CUSTOM,
            questRequest = function(cid) return getCreatureStorage(cid, 8445) == QUEST_STATUS.FINISHED end,
            blockStart = true, -- Auto started
            onEnd = function(cid)
                doPlayerRemoveItem(cid, 23565, getPlayerItemCount(cid, 23565)) -- pokemon gas medicine
            end
        },
    },
    ["Rick"] = {
        {
            storage = 8446,
            talk_questStarting = "Oh! We have a new candidate! I invented a system where people post messages on the Mission Board so trainers can take jobs and earn rewards. The Mission Board is right beside me, and to use it you just have to show you can handle the requests. What do you think?",
            talk_questStarted = "Ok. The paper I gave you has the names of three people here in Fuchsia who asked me for help. Complete these three tasks and then talk to me.",
            talk_questFinishing = "Did you complete the tasks?",
            talk_questFinished = "Very nice. Now you can use the Mission Board to take a daily task every 24 hours and a weekly task every seven days. They guarantee you several rewards. Thank you and good luck.",
            talk_questFinishFail = "Looks like you didn't.",
            talk_questDone = "",
            rewardItems = {
                { type = REWARD_TYPE.ITEM, id = 23453, count = 1 }, -- iron vitamin
            },
            rewardExp = 0,
            requiredLevel = 30,
            questType = QUEST_TYPE.CUSTOM,
            questStartItems = { 23566, 1 }, -- Rick's list
            questRequest = function(cid)
                for _, storage in pairs({ 8447, 8449, 8450 }) do -- Chewba, Luken and Lia quests
                    if (getCreatureStorage(cid, storage) ~= QUEST_STATUS.FINISHED) then
                        return false
                    end
                end
                return true
            end,
            onEnd = function(cid)
                doPlayerRemoveItem(cid, 23566, getPlayerItemCount(cid, 23566)) -- Rick's list
            end
        },
    },
    ["Chewba"] = {
        {
            storage = 8447,
            counterStorage = 8448,
            talk_questStarting = "Hey, did Rick send you?",
            talk_questStarted = "I need you to plant these berries for me. There are eight of them. Go to the ground outside my house and use the tools there.",
            talk_questFinishing = "Hah, did you already plant them all?!",
            talk_questFinished = "Thank you, Rick will like this.",
            talk_questFinishFail = "Looks like you didn't.",
            talk_questDone = "",
            rewardItems = {
                { type = REWARD_TYPE.ITEM, id = 2152, count = 5 }, -- 500 dl
            },
            rewardExp = 10175, -- 25% from level 30 to 31
            requiredLevel = 30,
            questType = QUEST_TYPE.CUSTOM,
            questRequest = function(cid) return getCreatureStorage(cid, 8448) >= 8 end,
            questStartItems = { 23567, 8, 23570, 1 }, -- chewba's berry seed and chewba's hoe
            canStart = function(cid) return getCreatureStorage(cid, 8446) == QUEST_STATUS.STARTED end, -- Rick quest #1
            onEnd = function(cid)
                doPlayerRemoveItem(cid, 23570, getPlayerItemCount(cid, 23570))
            end
        },
    },
    ["Luken"] = {
        {
            storage = 8449,
            counterStorage = 8451,
            talk_questStarting = "Trainer, I need your help with a little problem.",
            talk_questStarted = "Some Haunters are living in my basement. Light all the torches down there with one of your Fire Pokemon and I will be very grateful.",
            talk_questFinishing = "Did you light the torches?",
            talk_questFinished = "Thanks!",
            talk_questFinishFail = "Looks like you don't have it yet.",
            talk_questDone = "",
            rewardItems = {
                { type = REWARD_TYPE.ITEM, id = 2152, count = 5 }, -- 500 dl
            },
            rewardExp = 10175, -- 25% from level 30 to 31
            requiredLevel = 30,
            questType = QUEST_TYPE.CUSTOM,
            questRequest = function(cid) return getCreatureStorage(cid, 8451) >= 8 end,
            canStart = function(cid) return getCreatureStorage(cid, 8446) == QUEST_STATUS.STARTED end, -- Rick quest #1
        },
    },
    ["Lia"] = {
        {
            storage = 8450,
            counterStorage = 8452,
            talk_questStarting = "I have some wardrobes in my house that are old and I need to destroy them. Can you help me?",
            talk_questStarted = "Use a strong Pokemon.",
            talk_questFinishing = "Did you destroy the wardrobes?",
            talk_questFinished = "Cool! I am grateful for that.",
            talk_questFinishFail = "Looks like you don't have it yet.",
            talk_questDone = "",
            rewardItems = {
                { type = REWARD_TYPE.ITEM, id = 2152, count = 5 }, -- 500 dl
            },
            rewardExp = 10175, -- 25% from level 30 to 31
            requiredLevel = 30,
            questType = QUEST_TYPE.CUSTOM,
            questRequest = function(cid) return getCreatureStorage(cid, 8452) >= 6 end,
            canStart = function(cid) return getCreatureStorage(cid, 8446) == QUEST_STATUS.STARTED end, -- Rick quest #1
        },
    },
    ["Rebbeca"] = {
        {
            storage = 8453,
            talk_questStarting = "Trainer, I must find my Pokemon ribbons, please help!",
            talk_questStarted = "My Pokemon are free to walk around when they are not preparing for beauty contests. They all lost their special ribbons, this can only be a curse! Use every trick you know to find them, please. There are five.",
            talk_questFinishing = "Did you find the ribbons?",
            talk_questFinished = "Thanks, I feel so relieved. Take this small token of thanks for your effort. Thank you.",
            talk_questFinishFail = "Looks like you didn't.",
            talk_questDone = "",
            rewardItems = {
                { type = REWARD_TYPE.ITEM, id = 23947, count = 1 }, -- lovely seal box
            },
            rewardExp = 5000, -- 18% of level 25 to 26
            requiredLevel = 25,
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 23551, 5 }, -- yellow ribbon
        },
    },
    ["Hanzo Hasashi"] = {
        {
            storage = 8454,
            talk_questStarting = "My Charizard got angry about something I did and fled to the caves near here. Can you help me with this?",
            talk_questStarted = "All you need to do is return him to his PokeBall. We'll have to put him to sleep. Try this device I recently created; just use it on the floor to make it work. But watch the time: in my tests it didn't work for very long.",
            talk_questFinishing = "Did you help my Charizard?!",
            talk_questFinished = "Thank you, take this simple reward for your effort.",
            talk_questFinishFail = "Looks like you didn't.",
            talk_questDone = "",
            rewardItems = {
                { type = REWARD_TYPE.ITEM, id = 23450, count = 1 }, -- calcium vitamin
                { type = REWARD_TYPE.ITEM, id = 13179, count = 5 }, -- seed of rawst berry
            },
            rewardExp = 23675, -- 25% from level 45 to 46
            requiredLevel = 45,
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 23552, 1, 23554, 1 }, -- sleep device and hanzo hasashi poke ball (charizard)
            questStartItems = { 23552, 1, 23553, 1 }, -- sleep device and hanzo hasashi empty poke ball
        },
    },
    ["Brock"] = {
        {
            storage = 8456,
            talk_questStarting = "My brother Forrest is at our house and needs help. Today I must stay at the gym for a long time and don't have time to help him. Would you do that for me?",
            talk_questStarted = "Go talk to him in our home. I'm sure that he will be nice to you.",
            talk_questFinishing = "Did you find Forrest?",
            talk_questFinished = "Thanks for your help. Take this as a reward. You can check with the other leaders if they also need help. Good luck on your journey!",
            talk_questFinishFail = "Looks like you didn't.",
            talk_questDone = "",
            rewardItems = {
                { type = REWARD_TYPE.ITEM, id = 2152, count = 5 }, -- 500 dl
            },
            rewardExp = 5000,
            requiredLevel = 15,
            questType = QUEST_TYPE.CUSTOM,
            questRequest = function(cid) return getCreatureStorage(cid, 8457) == QUEST_STATUS.FINISHED end,
            canStart = function(cid) return getPlayerDefeatedNPC(cid, 9508) end, -- Defeated Brock GYM
        },
        {
            storage = 8663,
            talk_questStarting = "Grr! Mewtwo!",
            talk_questStarted = "You need to help me find the Pokemon.",
            talk_questFinishing = "Did you find our Pokemon?",
            talk_questFinished = "You are truly a great person, congratulations. Thank you!",
            talk_questFinishFail = "Looks like you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 27432, 1 },
            rewardExp = 0,
            requiredLevel = 60,
            startPosition = { x = 5521, y = 247, z = 6 },
            finishPosition = { x = 5521, y = 247, z = 6 },
            canStart = function(cid) return getPlayerDefeatedNPC(cid, 9707) end,
            onEnd = function(cid)
                for v = 8659, 8664 do
                    if (getCreatureStorage(cid, v) ~= QUEST_STATUS.FINISHED) then
                        return
                    end
                end

                doCreatureSay(cid, "Late kid, I do not need your Pokemon. I'm waiting for you in my battle arena, if you are so good come here without problems.", TALKTYPE_MONSTER_YELL)
            end
        },
    },
    ["Brockling Forrest"] = {
        {
            storage = 8457,
            talk_questStarting = "Did Brock send you?",
            talk_questStarted = "That's great. I'm kinda ill today... coff, coff... and some of my brothers need help. I'll tell you what to do. Okay? First, help Salvadore. He is the eldest after me... you'll know who he is.",
            talk_questFinishing = "Did you help my brothers?",
            talk_questFinished = "Thank you for helping us today. We hope we didn't cause too many problems. When you want to prepare your Onigiri, talk to Salvadore. He will sell you the sauce. It's a great way to restore your Pokemon. Tell Brock about what happened here today.",
            talk_questFinishFail = "Looks like you didn't.",
            talk_questDone = "",
            rewardItems = {}, -- todo
            rewardExp = 0,
            requiredLevel = 15,
            questType = QUEST_TYPE.CUSTOM,
            questRequest = function(cid)
                for _, storage in pairs({ 8459, 8460, 8461 }) do -- Salvadore, Yolanda and Timmy quests
                    if (getCreatureStorage(cid, storage) ~= QUEST_STATUS.FINISHED) then
                        return false
                    end
                end
                return true
            end,
            canStart = function(cid) return getCreatureStorage(cid, 8456) == QUEST_STATUS.STARTED end, -- Brock Quest #1
        },
    },
    ["Brockling Salvadore"] = {
        {
            storage = 8458,
            talk_questStarting = "Can you help me with the food for today?",
            talk_questStarted = "We need to prepare 40 cooked onigiri. Now take this sauce and put it on them.",
            talk_questFinishing = "Did you put the sauce on the onigiris?",
            talk_questFinished = "Great. Now take them to the stove and serve two to each brother. You can keep the leftovers, they're great for regaining energy.",
            talk_questFinishFail = "Looks like you didn't.",
            talk_questDone = "",
            rewardItems = {}, -- todo
            rewardExp = 0,
            requiredLevel = 15,
            questType = QUEST_TYPE.CUSTOM,
            questRequest = function(cid)
                return getPlayerItemCount(cid, 23590) >= 40 -- seasoned onigiri
            end,
            canStart = function(cid) return getCreatureStorage(cid, 8457) == QUEST_STATUS.STARTED end, -- Brockling Forrest #1
            questStartItems = { 23572, 1 }, -- onigiri sauce
            onEnd = function(cid)
                doCreatureSetStorage(cid, 8459, QUEST_STATUS.STARTED) -- Autostart 8459
                for storage = 8476, 8483 do
                    doCreatureSetStorage(cid, storage, 0) -- reset counter storage
                end
            end
        },
        {
            -- Auto started by 8458
            storage = 8459,
            talk_questStarting = "",
            talk_questStarted = "",
            talk_questFinishing = "Did you deliver the cooked onigiris?",
            talk_questFinished = "Phew, what a job... go see my sister Yolanda. She said something about my father's Golem.",
            talk_questFinishFail = "Looks like you didn't.",
            talk_questDone = "",
            rewardItems = {},
            rewardExp = 0,
            requiredLevel = 20,
            questType = QUEST_TYPE.CUSTOM,
            questRequest = function(cid)
                for storage = 8476, 8483 do
                    if (getCreatureStorage(cid, storage) < 2) then
                        return false
                    end
                end

                return true
            end,
            blockStart = true, -- Auto started
        },
        {
            storage = 8508,
            talk_questStarting = "Hey, do you want to buy a sauce for Onigiri?",
            talk_questStarted = "Sure, it will {cost} you a little.",
            talk_questFinishing = "Do you want to buy a sauce for 500 dollars?",
            talk_questFinished = "Here it is! If you want to buy more, come back tomorrow.",
            talk_questFinishFail = "Looks like you didn't.",
            talk_questDone = "",
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 23572, count = 1 } }, -- onigiri sauce
            rewardExp = 0,
            requiredLevel = 15,
            questType = QUEST_TYPE.CUSTOM,
            questRequest = function(cid)
                return getPlayerMoney(cid) >= 500
            end,
            canStart = function(cid) return getCreatureStorage(cid, 8457) == QUEST_STATUS.FINISHED end, -- Brockling Forrest #1
            onEnd = function(cid)
                doPlayerRemoveMoney(cid, 500)
            end,
            daily = true
        },
    },
    ["Brockling Yolanda"] = {
        {
            storage = 8460,
            talk_questStarting = "Can you help me take care of my father's Golem?",
            talk_questStarted = "My father went to meet my mother in another town and left his old friend to rest here. Go to him and give him this nugget he loves. Then use this tool to polish his edges so he's faster in battle. And lastly, fill his food pot with it.",
            talk_questFinishing = "Did you help my friend?",
            talk_questFinished = "That's great. Thank you for your help. Finally, go see the twins Timmy and Billy. I think they're up to something.",
            talk_questFinishFail = "Looks like you didn't.",
            talk_questDone = "",
            rewardItems = {}, -- todo
            rewardExp = 0,
            requiredLevel = 15,
            questType = QUEST_TYPE.CUSTOM,
            questRequest = function(cid)
                for _, storage in pairs({ 8462, 8463, 8464 }) do -- Yolanda crystal nugget, esmeril and golem's food
                    if (getCreatureStorage(cid, storage) ~= QUEST_STATUS.FINISHED) then
                        return false
                    end
                end
                return true
            end,
            canStart = function(cid) return getCreatureStorage(cid, 8459) == QUEST_STATUS.FINISHED end, -- Brockling Salvadore #2
            questStartItems = { 23575, 1, 23576, 1, 23577, 1 }, -- crystal nugget, esmeril and golem's food
        },
    },
    ["Brockling Timmy"] = {
        {
            storage = 8461,
            talk_questStarting = "Our toy is in the basement and we forgot that our brother Brock's Zubat is sleeping right now. He doesn't like being woken up and we're afraid. Can you get it for us?",
            talk_questStarted = "Thank you. Be careful not to make noise there. He becomes a beast when he wakes up!",
            talk_questFinishing = "Did you get the toy?",
            talk_questFinished = "Thanks! Hahaha!",
            talk_questFinishFail = "Looks like you didn't.",
            talk_questDone = "",
            rewardItems = {}, -- todo
            rewardExp = 0,
            requiredLevel = 15,
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 23594, 1 }, -- toy (moveable)
            canStart = function(cid) return getCreatureStorage(cid, 8460) == QUEST_STATUS.FINISHED end, -- Brockling Yolanda #1
        },
    },
    ["Misty"] = {
        {
            storage = 8466,
            talk_questStarting = "Thanks, trainer. My boyfriend J. Fox has a birthday in a few days and I need to find a suitable gift for him. The problem is that I haven't had time to leave the gym lately, with all my duties and battles with Pokemon trainers. My sisters don't help me at all and went on vacation again. He is a skilled archer and likes to test his skills in tournaments. I want to give him a very good bow. Can you help me?",
            talk_questStarted = "Great. The bow maker gave me a list of materials I need to collect. Get them for me and you will have your reward.",
            talk_questFinishing = "Did you get the items?",
            talk_questFinished = "Great. Put them in this bag and hand it to the bow maker in Lavender. Once he has it, return to me! Thank you!",
            talk_questFinishFail = "Looks like you don't have it yet.",
            talk_questDone = "",
            rewardExp = 5000,
            rewardItems = {
                { type = REWARD_TYPE.ITEM, id = 23589, count = 1, unique = true }, -- shopping bag
                { type = REWARD_TYPE.ITEM, id = 2152, count = 10 }, -- 1000 dl
            }, -- shopping bag, to use on the next quest
            requiredLevel = 30,
            questType = QUEST_TYPE.CUSTOM,
            questRequest = function(cid)
                local requireds = {
                    { id = 23581, count = 10 }, -- sea shells
                    { id = 23580, count = 15 }, -- fine wood
                    { id = 12106, count = 50 }, -- tangela hair
                }
                for _, item in pairs(requireds) do
                    if (getPlayerItemCount(cid, item.id) < item.count) then
                        return false
                    end
                end
                return true
            end,
            questStartItems = { 23579, 1 }, -- misty's list
            canStart = function(cid) return getPlayerDefeatedNPC(cid, 9537) end, -- Defeated Misty GYM
            onEnd = function(cid)
                doCreatureSetStorage(cid, 8467, QUEST_STATUS.STARTED) -- Autostart 8467
                doCreatureSetStorage(cid, 8468, QUEST_STATUS.STARTED) -- Autostart 8468
            end
        },
        {
            -- Auto started by 8466
            storage = 8467,
            talk_questStarting = "",
            talk_questStarted = "",
            talk_questFinishing = "Did you get the bow?",
            talk_questFinished = "Oh, thank you for your effort. Take your reward!",
            talk_questFinishFail = "Looks like you didn't.",
            talk_questDone = "",
            rewardItems = {},
            rewardExp = 0,
            requiredLevel = 20,
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 23595, 1 }, -- good bow
            blockStart = true, -- Auto started
        },
        {
            storage = 8205,
            talk_questStarting = "Please help me, Team Rocket stole my Pokemon egg, I'm desperate! This egg was a gift from a magnificent trainer to me, it is very important!",
            talk_questStarted = "They fled north! Go!",
            talk_questFinishing = "Did you rescue my Unknown Egg?",
            talk_questFinished = "Wow! Thank you, I don't know what I'd do without your help. By the way, Prof. Oak asked you to go back to him. He said he has something for you to do in the Orange Archipelago.",
            talk_questFinishFail = "No, you couldn't do it yet. Please help me!",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 18158, 1 },
            rewardItems = {},
            rewardExp = 0,
            requiredLevel = 70,
            canStart = function(cid) return getCreatureStorage(cid, 8204) == QUEST_STATUS.STARTED end
        },
        {
            storage = 8662,
            talk_questStarting = "My Togepi!",
            talk_questStarted = "He's still a baby, please save him.",
            talk_questFinishing = "Did you find my Togepi?",
            talk_questFinished = "Ohh! There he is!",
            talk_questFinishFail = "Looks like you didn't find him yet.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 27431, 1 },
            rewardExp = 0,
            requiredLevel = 60,
            startPosition = { x = 5527, y = 249, z = 6 },
            finishPosition = { x = 5527, y = 249, z = 6 },
            canStart = function(cid) return getPlayerDefeatedNPC(cid, 9707) end,
            onEnd = function(cid)
                for v = 8659, 8664 do
                    if (getCreatureStorage(cid, v) ~= QUEST_STATUS.FINISHED) then
                        return
                    end
                end

                doCreatureSay(cid, "Late kid, I do not need your Pokemon. I'm waiting for you in my battle arena, if you are so good come here without problems.", TALKTYPE_MONSTER_YELL)
            end
        },
    },
    ["Luther Lacey"] = {
        {
            storage = 8468,
            talk_questStarting = "",
            talk_questStarted = "",
            talk_questFinishing = "Ah yes, Misty ordered a bow from me. Very well. Did you bring all the necessary items?",
            talk_questFinished = "Very well. Come back in two hours and it will be ready.",
            talk_questFinishFail = "Looks like you don't have it yet.",
            talk_questDone = "",
            rewardItems = {}, -- todo
            rewardExp = 0,
            requiredLevel = 15,
            questType = QUEST_TYPE.CUSTOM,
            questRequest = function(cid)
                local bag = getPlayerItemById(cid, true, 23589) -- shopping bag
                if (isItem(bag)) then
                    local requireds = {
                        { id = 23581, count = 10, found = false }, -- sea shells
                        { id = 23580, count = 15, found = false }, -- fine wood
                        { id = 12106, count = 50, found = false }, -- tangela hair
                    }
                    for _, item in pairs(getContainerItems(bag.uid)) do
                        for _, required in pairs(requireds) do
                            if (required.id == item.itemid and required.count == item.type) then
                                required.found = true
                                break
                            end
                        end
                    end

                    for _, required in pairs(requireds) do
                        if (not required.found) then
                            return false
                        end
                    end

                    return true
                end
                return false
            end,
            blockStart = true, -- Auto started
            onEnd = function(cid)
                doRemoveItem(getPlayerItemById(cid, true, 23589).uid) -- shopping bag
                doCreatureSetStorage(cid, 8469, QUEST_STATUS.STARTED) -- Autostart 8469
                doCreatureSetStorage(cid, 8470, os.time()) -- To be used on 8469
            end
        },
        {
            -- Auto started by 8468
            storage = 8469,
            talk_questStarting = "",
            talk_questStarted = "",
            talk_questFinishing = "Oh, you came to get the bow?",
            talk_questFinished = "Here it is.",
            talk_questFinishFail = "The bow isn't ready yet.",
            talk_questDone = "",
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 23595, count = 1, unique = true } }, -- good bow, to use on the misty quest
            rewardExp = 0,
            requiredLevel = 20,
            questType = QUEST_TYPE.CUSTOM,
            questRequest = function(cid)
                local diff = (getCreatureStorage(cid, 8470) + (2 * 60 * 60) - os.time())
                if (diff > 0) then
                    selfSay(string.format(__L(cid, "You must wait %s to continue."), table.concat(string.timediff(diff, cid))), cid)
                    return false
                end
                return true
            end,
            blockStart = true, -- Auto started
        },
    },
    ["Lt. Surge"] = {
        {
            storage = 8471,
            talk_questStarting = "One of my main batteries has too little energy to keep running here in the gym. I got a replacement, but it's not as strong as this one. Do you think you can help me?",
            talk_questStarted = "The task is simple, soldier! Defeat Electric type Pokemon and use the battery on them after they faint to energize it. The higher the Pokemon's level, the more energy absorbed! You'll get a message when you're done. Then return to me for your reward.",
            talk_questFinishing = "Did you get the energy?",
            talk_questFinished = "That's it, soldier, we need efficient people like you. Take your reward and use it wisely.",
            talk_questFinishFail = "Looks like you don't have it yet.",
            talk_questDone = "",
            rewardItems = {
                { type = REWARD_TYPE.ITEM, id = 2152, count = 15 }, -- 1500 dl
            },
            rewardExp = 5000,
            requiredLevel = 35,
            questType = QUEST_TYPE.CUSTOM,
            questRequest = function(cid)
                local item = getPlayerItemById(cid, true, 23582) -- Lt. Surge battery
                if (not isItem(item)) then
                    return false
                end

                local status = getItemAttribute(item.uid, 1200) -- energy status storage
                if (not status) then
                    return false
                end

                return status >= 100
            end,
            questStartItems = { 23582, 1 }, -- Lt. Surge battery
            canStart = function(cid) return getPlayerDefeatedNPC(cid, 9533) end, -- Defeated Lt. Surge GYM
            onEnd = function(cid) doPlayerRemoveItem(cid, 23582, getPlayerItemCount(cid, 23582)) end -- Lt. Surge battery
        },
    },
    ["Erika"] = {
        {
            storage = 8472,
            talk_questStarting = "My Pokemon need a special juice that I prepare to restore their energy. Can you help?",
            talk_questStarted = "I need you to prepare a berry juice for them. I built a machine in the gym to extract the juice. I need you to make 5 juices for me. It's a combination of five berries: Sitrus, Pecha, Leppa, Oran and Chesto. But there is a correct order, and that is my challenge to you. Find the correct order and use these flasks to collect the juice. It's very special, and this tempered glass keeps it free of any virus like Pokerus. Once you get the mix right, just collect it. Come back to me with 5 full flasks and be careful with them.",
            talk_questFinishing = "Did you make the juice?",
            talk_questFinished = "Very well. This was a beautiful test. Give me 3 bottles and keep 2. This juice boosts your Pokemon's HP and Energy regeneration for 30 minutes. Use it well. Take this for all your work.",
            talk_questFinishFail = "Looks like you didn't.",
            talk_questDone = "",
            rewardItems = {
                { type = REWARD_TYPE.ITEM, id = 23596, count = 2 }, -- Erika's juice flask
                { type = REWARD_TYPE.ITEM, id = 2152, count = 20 }, -- 2000 dl
            },
            rewardExp = 5000,
            requiredLevel = 40,
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 23596, 5 }, -- Erika's juice flask
            questStartItems = { 23584, 5 }, -- Erika's empty juice flask
            canStart = function(cid) return getPlayerDefeatedNPC(cid, 9518) end, -- Defeated Erika GYM
        },
    },
    ["Koga"] = {
        {
            storage = 8473,
            talk_questStarting = "I need to gather some Blue Pollen for an experiment. Can you collect it for me?",
            talk_questStarted = "The plants are on Route 13, all you need to do is use a Pokemon with CUT ability to collect them. Be careful because they are poisonous. I need 30 Blue Pollens. When finished, bring them to me.",
            talk_questFinishing = "Did you collect the Blue Pollen?",
            talk_questFinished = "Great, take this as a reward.",
            talk_questFinishFail = "Doesn't look like it.",
            talk_questDone = "",
            rewardItems = {
                { type = REWARD_TYPE.ITEM, id = 2152, count = 25 }, -- 2500 dl
            },
            rewardExp = 5000,
            requiredLevel = 45,
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 23588, 30 }, -- blue pollen
            canStart = function(cid) return getPlayerDefeatedNPC(cid, 9529) end, -- Defeated Koga GYM
        },
    },
    ["Sabrina"] = {
        {
            storage = 8474,
            talk_questStarting = "I have a test for trainers with courage and determination. If you think you can do it, just confirm. Then get ready: you will be mesmerized by my Pokemon and taken to the world of dreams. There you will have to unravel my mystery, all thanks to recent advances by Devon Corporation. We will be connected to the Dream World, a world of Pokemon dreams, where I created a challenge for trainers. Unravel the mystery and you will succeed. Are you ready?",
            talk_questStarted = "When you feel ready to enter the {dream}, come to me.",
            talk_questFinishing = "Did you complete my test?",
            talk_questFinished = "Okay, you passed my test. Take this reward. I will soon have news about the Dream World, so stay tuned. See ya.",
            talk_questFinishFail = "Looks like you didn't.",
            talk_questDone = "",
            rewardItems = {
                { type = REWARD_TYPE.ITEM, id = 2152, count = 30 }, -- 3000 dl
            },
            rewardExp = 5000,
            requiredLevel = 50,
            questType = QUEST_TYPE.CUSTOM,
            questRequest = function(cid) return getCreatureStorage(cid, 8475) == QUEST_STATUS.FINISHED end,
            canStart = function(cid) return getPlayerDefeatedNPC(cid, 9542) end, -- Defeated Sabrina GYM
            questStartItems = { 23598, 1 }, -- psychic weaver
        },
    },
    ["Gary's Assistant"] = {
        {
            storage = 8030,
            talk_questStarting = "I am seeking the best Pokemon trainers! If you think you are talented I'll give you a test.",
            talk_questStarted = "Your mission is to bring me these items: 50x Water Gem, 50x Bottle of Poison, 7x Bitten Apple, 7x Tooth and 5x Bat Wing.",
            talk_questFinishing = "Did you get the items?",
            talk_questFinished = "Congratulations kid, here is your reward. I have more missions for you; come talk to me whenever you want.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more missions for now.",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 12100, 50, 12104, 50, 12115, 7, 12117, 7, 12124, 5 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 13973, count = 1 } },
            rewardExp = 0,
            requiredLevel = 15,
        },
        {
            storage = 8031,
            talk_questStarting = "Are you prepared for the second test?",
            talk_questStarted = "Your mission is to bring me these items: 12x Bulb, 200x Fire Element, 10x Pot of Lava, 15x Hull, 20x Electrizer and 200x Screw.",
            talk_questFinishing = "Did you get the items?",
            talk_questFinished = "Congratulations, here is your reward. I have more missions for you; come talk to me whenever you want.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more missions for now.",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 12090, 12, 12101, 200, 12087, 10, 12097, 15, 12118, 20, 12103, 200 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 13974, count = 1 } },
            rewardExp = 0,
            requiredLevel = 30,
        },
        {
            storage = 8032,
            talk_questStarting = "Are you prepared for the third test?",
            talk_questStarted = "Your mission is to bring me these items: 25x Leaf, 10x Bulb, 20x Hull, 25x Pot of Lava, 10x Flame Orb, 35x Pot of Moss Mug, 15x Gracidea, 15x Revival Herb, 28x Water Pendant, 18x Stone Orb, 50x Feather, 40x Fur, 10x Tangela Hair, 30x Black Sludge, 400x Bottle of Poison, 10x Slowpoke Tail, 15x metal spikes and 30x Electrizer.",
            talk_questFinishing = "Did you get the items?",
            talk_questFinished = "Congratulations, here is your reward. I have more missions for you; come talk to me whenever you want.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more missions for now.",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 12091, 25, 12090, 10, 12097, 20, 12087, 25, 13303, 10, 12113, 35, 13304, 15, 13309, 15, 12112, 28, 12138, 18, 12142, 50, 12123, 40, 12106, 10, 12144, 30, 12104, 400, 12139, 10, 13308, 15, 12118, 30 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 13975, count = 1 } },
            rewardExp = 0,
            requiredLevel = 50,
        },
        {
            storage = 8033,
            talk_questStarting = "Are you prepared for the fourth and final test?",
            talk_questStarted = "Your mission is to bring me these items: 20x Gyarados Tail, 10x Yellow Tail, 1x Scyther Razor, 5x Jynx Clothes, 20x Magma Stone, 20x Ruby, 30x Twisted Spoon, 20x Reaper Cloth, 200x Water Gem, 200x Fire Element, 200x Screw, 200x Seed, 50x Leaves, 30x Stone Orb, 30x Flame Orb and 30x Razor Fang.",
            talk_questFinishing = "Did you get the items?",
            talk_questFinished = "Congratulations, here is your reward. I liked your results. I'll keep doing my tests and maybe someday I'll call you. Haha.",
            talk_questFinishFail = "No, you didn't.",
            talk_questDone = "Thanks but I have no more missions for now.",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 12086, 20, 12110, 10, 12108, 1, 12109, 5, 13306, 20, 12130, 20, 12135, 30, 12146, 20, 12100, 200, 12101, 200, 12103, 200, 12102, 200, 12091, 50, 12138, 30, 13303, 30, 12096, 30 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 13976, count = 1 } },
            rewardExp = 0,
            requiredLevel = 80,
        }
    },
    ["Flanagan"] = {
        {
            storage = 8489,
            talk_questStarting = "Great. First \"Use\" the Reward Chest right there to receive a Pikachu. Remember that he will only be with you during the tutorial; later you will choose your first Pokemon. Go and get him. Once you're done, you will see your QUEST LOG update. This window shows your current quests. Okay?",
            talk_questStarted = "Once you've done the {action}, come back here.",
            talk_questFinishing = "In some dialogs you will have the choice of YES or NO. Pay close attention before you answer and read everything an NPC tells you. Did you get the Pikachu?",
            talk_questFinished = "Ok, when you feel ready, let's {CONTINUE}.",
            talk_questFinishFail = "Looks like you didn't.",
            talk_questDone = "",
            rewardExp = 0,
            requiredLevel = 0,
            questType = QUEST_TYPE.CUSTOM,
            questRequest = function(cid) return getCreatureStorage(cid, 60028) == 1 end, -- Tutorial Pikachu taken
            onStart = function(cid) doPlayerSendTip(cid, TIP_IDS.OPEN_CHEST) end
        },
        {
            storage = 8490,
            talk_questStarting = "Great! Now you'll notice that your Inventory has a specific place for the Poke Ball; we call it the Ball Slot.",
            talk_questStarted = "Place the Poke Ball there and \"Use\" the Ball Slot to call your Pokemon out. Once you're done I will give you further {instructions}.",
            talk_questFinishing = "Were you able to call your Pokemon?",
            talk_questFinished = "Ok, when you feel ready, let's {CONTINUE}.",
            talk_questFinishFail = "Looks like you didn't.",
            talk_questDone = "",
            rewardExp = 0,
            requiredLevel = 0,
            questType = QUEST_TYPE.CUSTOM,
            questRequest = function(cid) return true end,
            onStart = function(cid) doPlayerSendTip(cid, TIP_IDS.CALL_POKEMON) end
        },
        {
            storage = 8491,
            talk_questStarting = "You will also notice that your Inventory has another button called \"Order\". Use it and a selection cursor will appear.",
            talk_questStarted = "Now click anywhere on the floor to move your Pokemon. Once you're done I will give you further {INSTRUCTIONS}.",
            talk_questFinishing = "Were you able to order your Pokemon?",
            talk_questFinished = "This is used to position your Pokemon for battle and also to perform specific attacks. Note that the inventory menu has other buttons you can explore to perform actions. Ok, when you feel ready, let's {CONTINUE}.",
            talk_questFinishFail = "Looks like you didn't.",
            talk_questDone = "",
            rewardExp = 0,
            requiredLevel = 0,
            questType = QUEST_TYPE.CUSTOM,
            questRequest = function(cid) return true end,
            onStart = function(cid) doPlayerSendTip(cid, TIP_IDS.ORDER_POKEMON) end
        },
        {
            storage = 8492,
            talk_questStarting = "Now you will have your big test with me. I will fight you with my Pokemon.",
            talk_questStarted = "All you need to do is keep your Pokemon out of its Poke Ball during the battle. To attack you have two options: the window with the move icons, or putting \"m1\", \"m2\", etc. in your Hotkeys (Ctrl + K). If you need a more detailed explanation, check the Help Channel. Say {BATTLE} when you feel ready.",
            talk_questFinishing = "So, ready for the {BATTLE}?",
            talk_questFinished = "Congratulations! The moves window also lets you see the detailed description of each of your Pokemon's moves. Just Shift + Click on the move icon. Go through the door and talk to the next NPC.",
            talk_questFinishFail = "Looks like you didn't.",
            talk_questDone = "",
            rewardExp = 0,
            requiredLevel = 0,
            questType = QUEST_TYPE.CUSTOM,
            questRequest = function(cid) return getPlayerDefeatedNPC(cid, "Flanagan") end,
            onStart = function(cid) doPlayerSendTip(cid, TIP_IDS.MOVE_WINDOW) end
        },
    },
    ["Gosse"] = {
        {
            storage = 8493,
            talk_questStarting = "Here you will learn how to capture a Pokemon using an empty Poke Ball. I see you already have a Pokemon with you, which is a very important part of this task. All you need to do is defeat the wild Pokemon and \"Use\" the empty Poke Ball from your Backpack on the body lying on the floor. Got it?",
            talk_questStarted = "Great, go through that door and catch one Magikarp. Take these empty Poke Balls. Remember that items obtained in this tutorial will not stay with you after you leave.",
            talk_questFinishing = "Did you catch the Magikarp?",
            talk_questFinished = "Congratulations, you are learning the basics of becoming a real trainer. Know that there are different types of Poke Ball with different catch rates; all you need to do is study a little more. Let's {CONTINUE}.",
            talk_questFinishFail = "Looks like you didn't.",
            talk_questDone = "",
            rewardExp = 0,
            requiredLevel = 0,
            questType = QUEST_TYPE.BRING_POKEMON,
            questRequest = "Magikarp",
            onStart = function(cid) doPlayerSendTip(cid, TIP_IDS.DEFEAT_CATCH) end,
            questStartItems = { 12157, 50 }, -- empty poke ball
            onEnd = function(cid) doPlayerRemoveItem(cid, 12157, getPlayerItemCount(cid, 12157)) end -- remove empty poke balls
        },
        {
            storage = 8494,
            talk_questStarting = "The only place where you don't need to defeat a Pokemon to catch it is the Safari Zone in Fuchsia.",
            talk_questStarted = "It works {DIFFERENT} there...",
            talk_questFinishing = "Ok! In the Safari Zone you need to use some items to make the Pokemon show an exclamation mark (!), which allows the catch. At that moment you can throw the Poke Ball at it directly. Roger that?",
            talk_questFinished = "Go through the door up there and talk to the next NPC.",
            talk_questFinishFail = "Looks like you didn't.",
            talk_questDone = "",
            rewardExp = 0,
            requiredLevel = 0,
            questType = QUEST_TYPE.CUSTOM,
            questRequest = function(cid) return true end,
        },
    },
    ["Shelley"] = {
        {
            storage = 8495,
            talk_questStarting = "Notice that on the tables next to me are the machines that catalog Pokemon: the Pokedex. When trainers start their journey, they receive their own Pokedex. It is an important device that stores all the information about the Pokemon you own. Here you will find your Pokemon's Stats, its attacks (Moves) and their strengths and weaknesses. Extra information such as Egg Group, HMs, the Pokemon description and so on is also very important and is explained in the Wiki tab of the Pokepedia (press M). Copy that?",
            talk_questStarted = "Now take your Pokedex and use it on the Psyduck. Just \"Use\" the Pokedex and then select the Pokemon. Check the details and come back to talk to me.",
            talk_questFinishing = "Did you get the Psyduck's information?",
            talk_questFinished = "Great, let's {CONTINUE}",
            talk_questFinishFail = "Looks like you didn't.",
            talk_questDone = "",
            rewardExp = 0,
            requiredLevel = 0,
            questType = QUEST_TYPE.CUSTOM,
            questRequest = function(cid) return hasPlayerDexedPokemon(cid, "Psyduck") end,
        },
        {
            storage = 8496,
            talk_questStarting = "Great. Now use it on the other Pokemon, the Skarmory.",
            talk_questStarted = "He is the steel-gray bird. See what happens and come talk to me.",
            talk_questFinishing = "Did you get the Skarmory's information?",
            talk_questFinished = "No! That's because your Pokedex isn't updated yet. To see information about second generation Pokemon, you need to update it first. You can use the Pokedex on wild Pokemon and tamed ones too. If you use the Pokedex on trainers, you will get some cool information. Now let's move on to {HM}.",
            talk_questFinishFail = "Looks like you didn't.",
            talk_questDone = "",
            rewardExp = 0,
            requiredLevel = 0,
            questType = QUEST_TYPE.CUSTOM,
            questRequest = function(cid) return true end,
        },
        {
            storage = 8497,
            talk_questStarting = "HMs are special moves your Pokemon can use on the map to perform a specific action. If your Pokemon has the Surf HM, it can travel through water with you. Just use the ORDER button in the Inventory at the water's edge.",
            talk_questStarted = "To fly through the air, just use a Pokemon with the Fly HM. Use ORDER on your character and your Pokemon will fly with you. To go up and down, say \"/up\" and \"/down\". I can {continue} when you feel ready.",
            talk_questFinishing = "To see which HMs your Pokemon has, use the Pokedex on your Pokemon. For a more detailed explanation, read the Wiki tab of the Pokepedia (press M).",
            talk_questFinished = "Now go through the next door into the next room. Your goal in the next room is to talk to all NPCs. Once you're done, talk to Oak's Assistant at the end and you'll be ready for your journey.",
            talk_questFinishFail = "Looks like you didn't.",
            talk_questDone = "",
            rewardExp = 0,
            requiredLevel = 0,
            questType = QUEST_TYPE.CUSTOM,
            questRequest = function(cid) return true end,
        },
    },
    ["Patton"] = {
        {
            storage = 8500,
            talk_questStarting = "",
            talk_questStarted = "",
            talk_questFinishing = "Oh, you are Oak's pupil?",
            talk_questFinished = "The order arrived this morning. Here it is. Keep in mind that we merchants are always in need of help. When you get to a new city, try looking for missions.",
            talk_questFinishFail = "Looks like you don't have it yet.",
            talk_questDone = "",
            rewardExp = 0,
            requiredLevel = 0,
            questType = QUEST_TYPE.CUSTOM,
            questRequest = function(cid) return true end,
            blockStart = true,
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 23950, count = 1, unique = true } },
        },
    },
    ["Assistant Jofrey"] = {
        {
            storage = 8501,
            counterStorage = 8504,
            talk_questStarting = "Did the Professor send you?",
            talk_questStarted = "I'm here to teach you about fishing. Take this little Oddish and use the fishing rod on the water. Then hook 5 Magikarp and defeat them. Come back and talk to me when you're done.",
            talk_questFinishing = "Did you hook and defeat the Pokemon?",
            talk_questFinished = "I see that you did well. Take these rewards. Now I will teach you to fish in trees! Hahaha, I mean... the {Headbutting} skill.",
            talk_questFinishFail = "Looks like you didn't.",
            talk_questDone = "",
            rewardExp = 0,
            requiredLevel = 0,
            questType = QUEST_TYPE.DEFEAT_POKEMON,
            questRequest = { "Magikarp", 5 },
            canStart = function(cid) return getCreatureStorage(cid, 8498) == QUEST_STATUS.FINISHED end,
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 2687, count = 50, unique = true } }, -- cookie
            onStart = function(cid)
                local ball = doCreatePokemonBall(cid, "poke", "Oddish", 10, nil, "Jofrey's Oddish", 0, cid, false,
                    nil, nil, nil, nil, nil, nil, nil, nil, false)
                if (ball) then
                    setBallFromNpc(ball, true)
                end

                doPlayerAddMapMark(cid, { x = 3358, y = 813, z = 6 }, MAPMARK_EXCLAMATION, "Nest Tree")
                doPlayerAddMapMark(cid, { x = 3349, y = 807, z = 6 }, MAPMARK_EXCLAMATION, "Nest Tree")
                doPlayerAddMapMark(cid, { x = 3345, y = 805, z = 6 }, MAPMARK_EXCLAMATION, "Nest Tree")
                doPlayerAddMapMark(cid, { x = 3343, y = 800, z = 6 }, MAPMARK_EXCLAMATION, "Nest Tree")
                doPlayerAddMapMark(cid, { x = 3364, y = 804, z = 6 }, MAPMARK_EXCLAMATION, "Nest Tree")
            end,
            canFinish = function(cid)
                if (isPokemonOnline(cid)) then -- Try to call Pokemon back
                    doPlayerUseBallOnSlot(cid)
                end

                if (isPokemonOnline(cid) or getPlayerMounted(cid) or isEvolving(cid)) then
                    return false
                end

                for _, ball in pairs(getPlayerAllBallsWithPokemon(cid)) do
                    if (getBallFromNpc(ball.uid) and getBallPokemonName(ball.uid) == "Oddish") then
                        return true
                    end
                end
                return false
            end,
            onEnd = function(cid)
                for _, ball in pairs(getPlayerAllBallsWithPokemon(cid)) do
                    if (getBallFromNpc(ball.uid) and getBallPokemonName(ball.uid) == "Oddish") then
                        doRemoveItem(ball.uid)
                    end
                end
            end
        },
        {
            storage = 8502,
            counterStorage = 8505,
            talk_questStarting = "Yes, today I will teach you about Headbutting, are you ready?",
            talk_questStarted = "Ok, Headbutt works like fishing, but instead of using a rod on the water, you will use your Pokemon's Headbutt ability on a nest tree! Take this Caterpie and go east, you will find some Nest Trees. Just release your Pokemon and use the Order command on the Nest Tree.",
            talk_questFinishing = "Did you hook and defeat the Pokemon?",
            talk_questFinished = "Yup! Nice. Now you must talk to Doroty. She will teach you more about Pokeballs. You can find her inside the Oak Lab.",
            talk_questFinishFail = "Looks like you didn't.",
            talk_questDone = "",
            rewardExp = 0,
            requiredLevel = 0,
            questType = QUEST_TYPE.DEFEAT_POKEMON,
            questRequest = { "Caterpie", 1 },
            canStart = function(cid) return getCreatureStorage(cid, 8501) == QUEST_STATUS.FINISHED end,
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 12244, count = 10, unique = true } }, -- pokemon health potion
            onStart = function(cid)
                local ball = doCreatePokemonBall(cid, "poke", "Caterpie", 10, nil, "Jofrey's Caterpie", 0, cid, false,
                    nil, nil, nil, nil, nil, nil, nil, nil, false)
                if (ball) then
                    setBallFromNpc(ball, true)
                end
            end,
            canFinish = function(cid)
                if (isPokemonOnline(cid)) then -- Try to call Pokemon back
                    doPlayerUseBallOnSlot(cid)
                end

                if (isPokemonOnline(cid) or getPlayerMounted(cid) or isEvolving(cid)) then
                    return false
                end

                for _, ball in pairs(getPlayerAllBallsWithPokemon(cid)) do
                    if (getBallFromNpc(ball.uid) and getBallPokemonName(ball.uid) == "Caterpie") then
                        return true
                    end
                end
                return false
            end,
            onEnd = function(cid)
                for _, ball in pairs(getPlayerAllBallsWithPokemon(cid)) do
                    if (getBallFromNpc(ball.uid) and getBallPokemonName(ball.uid) == "Caterpie") then
                        doRemoveItem(ball.uid)
                    end
                end
            end
        },
    },
    ["Doroty"] = {
        {
            storage = 8503,
            talk_questStarting = "So you talked to Jofrey?",
            talk_questStarted = "I'll show you how to use seals on Poke Balls. Take this Weedle and this seal. Use the seal on the Poke Ball before releasing your Pokemon and see what happens. Then come back and talk to me.",
            talk_questFinishing = "Did you attach the seal to the Poke Ball?",
            talk_questFinished = "That's right! Now you have learned about seals. Using TMs, Vitamins and Held Items on your Pokemon is as simple as seals. Select the desired TM and use it on the Poke Ball. There are three types of Poke Balls: Poke Ball, Great Ball and Ultra Ball. These are sold at any PokeMart. There are other special balls for decoration and events. There is also the coveted Master Ball... but I must research it more. Take these Poke Balls to help you.",
            talk_questFinishFail = "Looks like you didn't.",
            talk_questDone = "",
            rewardExp = 0,
            requiredLevel = 0,
            questType = QUEST_TYPE.CUSTOM,
            questRequest = function(cid)
                for _, ball in pairs(getPlayerAllBallsWithPokemon(cid)) do
                    if (getBallFromNpc(ball.uid) and getBallPokemonName(ball.uid) == "Weedle" and
                            getBallSeal(ball.uid) ~= BALL_SEAL_IDS.NONE) then
                        return true
                    end
                end
                return false
            end,
            canStart = function(cid) return getCreatureStorage(cid, 8502) == QUEST_STATUS.FINISHED end,
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 12157, count = 50, unique = true } }, -- empty poke ball
            questStartItems = { 17436, 1 }, -- burst seal
            canFinish = function(cid)
                if (isPokemonOnline(cid)) then -- Try to call Pokemon back
                    doPlayerUseBallOnSlot(cid)
                end

                if (isPokemonOnline(cid) or getPlayerMounted(cid) or isEvolving(cid)) then
                    return false
                end

                return true
            end,
            onStart = function(cid)
                local ball = doCreatePokemonBall(cid, "poke", "Weedle", 10, nil, "Doroty's Weedle", 0, cid, false,
                    nil, nil, nil, nil, nil, nil, nil, nil, false)
                if (ball) then
                    setBallFromNpc(ball, true)
                end

                local seal = getPlayerItemById(cid, true, 17436) -- burst seal
                if (isItem(seal)) then
                    setSealFromNpc(seal.uid, true)
                else
                    log(LOG_TYPES.ERROR, "Quest::onStart Doroty - Can't find seal.", getCreatureName(cid), ball, seal)
                end
            end,
            onEnd = function(cid)
                for _, ball in pairs(getPlayerAllBallsWithPokemon(cid)) do
                    if (getBallFromNpc(ball.uid) and getBallPokemonName(ball.uid) == "Weedle") then
                        doRemoveItem(ball.uid)
                    end
                end
            end
        },
    },
    ["Mr. Fuji"] = {
        {
            storage = 8511,
            talk_questStarting = "Thanks for coming to save me. I knew Bill would get my message. I'm just a little stunned by all this. I'll tell you how it all happened.",
            talk_questStarted = "I was at my house here in Lavender when a loud noise caught my attention. I ran to the window and saw many lights and lanterns. A boy was being taken by hooded thieves, it was a kidnapping. I take care of Pokemon abandoned by their trainers, and I couldn't stand by and watch. I ran out to help the boy, but my Pokemon are afraid of battles, and I was soon captured and brought here. I don't know who the boy was, but he shouted: 'Run Pikachu! Escape to safety!' Through the window I could only see them fading into the horizon in a balloon. I need you to do me a favor and bring back my 5 lost Pokemon. Use these 5 Poke Balls on them when you find them. Do you think you can do it?",
            talk_questFinishing = "Did you find my Pokemon?",
            talk_questFinished = "Thanks, buddy, you were a great help. For now I'll stick around, I think I can help these evildoers find the light at the end of the tunnel. They should know me, but that was a long time ago and my past haunts me. I miss my {Amber}. I did many wrong things, I know. Help me fix what I started with {Mewtwo}. Good luck finding the boy.",
            talk_questFinishFail = "Looks like you don't have it yet.",
            talk_questDone = "",
            rewardExp = 0,
            requiredLevel = 0,
            questType = QUEST_TYPE.CUSTOM,
            questStartItems = { 25050, 5 },
            questRequest = function(cid)
                local storages = { 8512, 8513, 8514, 8515, 8516 }
                for _, storage in pairs(storages) do
                    if (getCreatureStorage(cid, storage) ~= QUEST_STATUS.FINISHED) then
                        return false
                    end
                end
                return getPlayerItemCount(cid, 25051) >= 5
            end,
            canStart = function(cid) return getCreatureStorage(cid, 8510) == QUEST_STATUS.STARTED end,
            rewardItems = {},
            onEnd = function(cid)
                doPlayerRemoveItem(cid, 25051, getPlayerItemCount(cid, 25051))
            end
        },
    },
    ["Briscoe Len"] = {
        {
            storage = 8518,
            talk_questStarting = "You are the trainer Bill told me about. Let's meet in my room downstairs.",
            talk_questStarted = "Wait for me and do not touch anything.",
            talk_questFinishing = "So you went to my room?",
            talk_questFinished = "I'm sorry, they forced me to do this. That was my secret room for saving money and they turned it into a dungeon. I had nothing to do with it. They took my son... I don't know how to get him back, I need {help}.",
            talk_questFinishFail = "Looks like you haven't.",
            talk_questDone = "",
            rewardExp = 0,
            requiredLevel = 0,
            questType = QUEST_TYPE.CUSTOM,
            questRequest = function(cid) return getCreatureStorage(cid, 8522) == QUEST_STATUS.FINISHED end,
            canStart = function(cid) return getCreatureStorage(cid, 8517) == QUEST_STATUS.STARTED end,
            rewardItems = {},
            canFinish = function(cid)
                return true
            end,
            onStart = function(cid)
            end,
            onEnd = function(cid)
                --todo
            end
        },
        {
            storage = 8519,
            talk_questStarting = "Y-You're gonna help me?",
            talk_questStarted = "They made me keep quiet because they kidnapped my dear son. I don't know where he is... but I haven't lost hope. Bring him back to me as soon as possible. OK?",
            talk_questFinishing = "Did you find something about my son?",
            talk_questFinished = "Thanks!",
            talk_questFinishFail = "Looks like you didn't.",
            talk_questDone = "",
            rewardExp = 0,
            requiredLevel = 0,
            questType = QUEST_TYPE.CUSTOM,
            questRequest = function(cid) return getPlayerDefeatedNPC(cid, 9697) end,
            rewardItems = {},
        },
        {
            storage = 8544,
            talk_questStarting = "MY son was trying to destroy Team Rocket? I'm so proud! But he was caught again?? Oh my God, you have to help me save my son. I have something that can be useful, but I'm too old for this, can you help me?",
            talk_questStarted = "Since our last meeting the Rockets haven't suspected I knew anything, and they are still there... out of fear I never handed this over, but now it'll be useful. I just sent the data about the secret base at the casino to the police. Go back quickly and save my son before the police arrest him too!",
            talk_questFinishing = "Did you save my son?",
            talk_questFinished = "Thank you for saving my son, he is waiting for you right there.",
            talk_questFinishFail = "Looks like you didn't.",
            talk_questDone = "",
            rewardExp = 0,
            requiredLevel = 0,
            questType = QUEST_TYPE.CUSTOM,
            questRequest = function(cid) return getCreatureStorage(cid, 8547) == QUEST_STATUS.FINISHED end, -- todo
            canStart = function(cid) return getCreatureStorage(cid, 8545) == QUEST_STATUS.FINISHED end,
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 17367, count = 1, unique = true } },
            onEnd = function(cid)
                doTeleportThing(cid, { x = 5082, y = 603, z = 9 })
            end
        },
    },
    ["Mistery Guy"] = {
        {
            storage = 8529,
            talk_questStarting = "Rumor has it they managed to create a genetically modified Pokemon. Can you imagine what that could do to the Pokemon world if it's true?",
            talk_questStarted = "We need to discover the truth about Mewtwo! I need more information about this Pokemon. I learned that a lab in Cinnabar is where it all started, but I couldn't find the secret door. Here, take this access card I found hidden inside a book in the Pokemon Mansion. Try to find a secret area and look into any files you find there. Come back here when you're done.",
            talk_questFinishing = "Did you find something?",
            talk_questFinished = "So Mewtwo really was created... Damn, I was afraid of that. At least we know more about it and its origin. Thank you, now I can go back to my dad as soon as possible.",
            talk_questFinishFail = "Looks like you don't have it yet.",
            talk_questDone = "",
            rewardExp = 0,
            requiredLevel = 0,
            questType = QUEST_TYPE.CUSTOM,
            questStartItems = { 25058, 1 },
            questRequest = function(cid)
                --[[for storage = 8528, 8538 do
                    if (getCreatureStorage(cid, storage) ~= QUEST_STATUS.FINISHED) then
                        return false
                    end
                end
                return true]]
                return getCreatureStorage(cid, 8539) >= 10
            end,
            canStart = function(cid) return getCreatureStorage(cid, 8527) == QUEST_STATUS.STARTED end, -- Bill
            rewardItems = {},
            onStart = function(cid) doCreatureSetStorage(cid, 8539, 0) end
        },
        {
            storage = 8546,
            talk_questStarting = "",
            talk_questStarted = "",
            talk_questFinishing = "Did you speak to my father?",
            talk_questFinished = "Thanks again for saving me. My father gathered Team Rocket's data and put it on this hard drive. Take it, it contains everything Team Rocket was working on at this site. It might be useful to you and our friend Bill. I'm weak and can't continue this mission with you, but I have faith in you.",
            talk_questFinishFail = "Looks like you didn't.",
            talk_questDone = "",
            rewardExp = 0,
            requiredLevel = 0,
            questType = QUEST_TYPE.CUSTOM,
            questRequest = function(cid) return getCreatureStorage(cid, 8547) == QUEST_STATUS.FINISHED end,
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 25191, count = 1, unique = true }, { type = REWARD_TYPE.ITEM, id = 17353, count = 1, unique = true } },
            blockStart = true
        }
    },
    ["Queter Phill"] = {
        --  {
        --    storage = 8541,
        --    talk_questStarting = "It sounds crazy but it's not... It is true, yes, I traveled back in time with this machine. Believe me, the future is not pleasant. We need your help.",
        --    talk_questStarted = "Suramoon, himself! We thought that everything was resolved, but somehow he returned. But this time things got ugly. In one of the battles that I fought against him I could steal some of his magic to create this machine. Unfortunately I'm hurt and I can not fight anymore, I need you to do this for me. As soon as you sense his evil, get into the portal that is downthere to get to the Suramoon dimension. Collect his magic, this is our chance to defeat him once and for all.",
        --    talk_questFinishing = "Did you get his essence?",
        --    talk_questFinished = "You have no idea how much you are being helpful! Now yes, I will put an end to all this evil. Together we can! Soon I will return to my dimension, I'll leave you with this to remember me.",
        --    talk_questFinishFail = "Looks like you didn't.",
        --    talk_questDone = "",
        --    rewardExp = 0,
        --    requiredLevel = 0,
        --    questType = QUEST_TYPE.BRING_ITEMS,
        --    questRequest = {25185, 63},
        --    rewardItems = {{type = REWARD_TYPE.ADDON, female = {looktype = 1386, addons = 3}, male = {looktype = 1387, addons = 3}}},
        --  },
        {
            storage = 8667,
            talk_questStarting = "Thanks to Bill's help I can now return to the past any time! So I created this battle simulator to prepare our young people for the future! Do you want to join us?",
            talk_questStarted = "Great, very good! Your task is simple: wait for the battle simulator to send the global message, enter the teleport and defeat the copy of Suramoon. To prove your feat, bring me 5 of the essences you find on his body.",
            talk_questFinishing = "Did you get his essence?",
            talk_questFinished = "Congratulations, you just passed our first test! When you're {ready} to {continue} let me know.",
            talk_questFinishFail = "Looks like you don't.",
            talk_questDone = "",
            rewardExp = 0,
            requiredLevel = 0,
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 25185, 5 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14461, count = 15, unique = true } },
        },
        {
            storage = 8668,
            talk_questStarting = "It's good to see you're ready! Shall we continue?",
            talk_questStarted = "OK! You will now be on the second level of the simulator. Do the same thing: wait for the call, enter the teleport and defeat Suramoon! Then bring me 5 of his essences.",
            talk_questFinishing = "Did you get his essence?",
            talk_questFinished = "Congratulations, you just passed our second test! When you're {ready} to {continue} let me know.",
            talk_questFinishFail = "Looks like you didn't.",
            talk_questDone = "",
            rewardExp = 0,
            requiredLevel = 0,
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 25185, 5 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14461, count = 15, unique = true } },
        },
        {
            storage = 8669,
            talk_questStarting = "You're doing great! Now we will have our last test, are you ready?",
            talk_questStarted = "All right. You are now on the third level! For the last time I need you to defeat Suramoon in our simulator, after that bring me 5 of his essences.",
            talk_questFinishing = "Did you get his essence?",
            talk_questFinished = "Very well! You did it! You are now part of the Allied Force! Congratulations, my friend, here is your uniform. Now watch out, for evil can lurk in every corner of this continent!",
            talk_questFinishFail = "Looks like you didn't.",
            talk_questDone = "",
            rewardExp = 0,
            requiredLevel = 0,
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 25185, 5 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14461, count = 15, unique = true }, { type = REWARD_TYPE.ADDON, female = { looktype = 1735, addons = 0 }, male = { looktype = 1736, addons = 0 } } },
        }
    },
    ["Charley Aden"] = {
        {
            storage = 8552,
            talk_questStarting = "Do you want to know about the Master Ball? I am responsible for its creation, but unfortunately Team Rocket took the only prototype, quickly destroyed all the research and hid it away somewhere safe.",
            talk_questStarted = "I can try to create another prototype, but I can't guarantee it will work, the Master Ball is extremely complex. Creating it takes money we don't have at Silph Co.; as you know, Team Rocket caused us many problems. Could you {help} us with 130k?",
            talk_questFinishing = "Will you help us fund the prototype?",
            talk_questFinished = "Okay! Come back in 2 hours and the prototype will be ready.",
            talk_questFinishFail = "Looks like you won't.",
            talk_questDone = "",
            rewardExp = 0,
            requiredLevel = 0,
            questType = QUEST_TYPE.CUSTOM,
            questRequest = function(cid)
                return doPlayerRemoveMoney(cid, 130000)
            end,
            onEnd = function(cid)
                doCreatureSetStorage(cid, 8554, os.time())
                doCreatureSetStorage(cid, 8553, QUEST_STATUS.STARTED)
            end,
            canStart = function(cid) return getCreatureStorage(cid, 8551) == QUEST_STATUS.STARTED end, -- Bill
        },
        {
            storage = 8553,
            talk_questStarting = "",
            talk_questStarted = "",
            talk_questFinishing = "Oh, you came for the prototype, right?",
            talk_questFinished = "Here it is, good luck trying to stop Team Rocket. Please say hello to Bill for me.",
            talk_questFinishFail = "Looks like you didn't.",
            talk_questDone = "",
            rewardExp = 0,
            requiredLevel = 0,
            questType = QUEST_TYPE.CUSTOM,
            questRequest = function(cid)
                local diff = (getCreatureStorage(cid, 8554) + (2 * 60 * 60) - os.time())
                if (diff > 0) then
                    selfSay(string.format(__L(cid, "You must wait %s to continue."), table.concat(string.timediff(diff, cid))), cid)
                    return false
                end
                return true
            end,
            blockStart = true,
            onEnd = function(cid)
                doPlayerSafeAddItem(cid, 27425, 1, true, true)
            end
        }
    },
    ["Martha May"] = {
        {
            storage = 8568,
            talk_questStarting = "Then I'll tell you some of his secrets so you can help me bring back the real Grinch. He loves walnut cake with strawberries. Could you bring me the ingredients so I can bake him one?",
            talk_questStarted = "So bring me 10 acorns and 20 strawberries.",
            talk_questFinishing = "Did you get the ingredients?",
            talk_questFinished = "Well, now here's another secret about him.",
            talk_questFinishFail = "Looks like you don't have it yet.",
            talk_questDone = "",
            rewardExp = 0,
            requiredLevel = 0,
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 17786, 10, 2680, 20 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 25258, count = 1, unique = true } },
            canStart = function(cid)
                return getPlayerDefeatedNPC(cid, 9706)
            end
        },
        {
            storage = 8569,
            talk_questStarting = "He is very fond of lemonade with honey. Could you bring me 5 lemons and 5 samples of sand wasp honey?",
            talk_questStarted = "So bring me 5 lemons and 5 samples of sand wasp honey.",
            talk_questFinishing = "Did you get the ingredients?",
            talk_questFinished = "Wow, you are amazing! I'll need another favor.",
            talk_questFinishFail = "Looks like you didn't.",
            talk_questDone = "",
            rewardExp = 0,
            requiredLevel = 0,
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 8841, 5, 14503, 5 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 25259, count = 1, unique = true } },
            canStart = function(cid)
                return getPlayerDefeatedNPC(cid, 9706)
            end
        },
        {
            storage = 8570,
            talk_questStarting = "Could you help me?",
            talk_questStarted = "The Grinch loves toasty warm socks made of exclusive materials. I'll need 5 balls of wool and 2 spider silks. Can you get me those?",
            talk_questFinishing = "Did you get the materials?",
            talk_questFinished = "Thanks for helping me, but I need one last favor.",
            talk_questFinishFail = "Looks like you didn't.",
            talk_questDone = "",
            rewardExp = 0,
            requiredLevel = 0,
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 12129, 5, 17811, 2 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 25256, count = 1, unique = true } },
            canStart = function(cid)
                return getPlayerDefeatedNPC(cid, 9706)
            end
        },
        {
            storage = 8571,
            talk_questStarting = "You must give him this letter, along with the cake, the lemonade and the socks. Can you do this?",
            talk_questStarted = "I would be very grateful, and you'd be helping the poor Grinch who is so sad in that cave. Take this key. I've watched him without him noticing, and once I saw him drop this key.",
            talk_questFinishing = "So he liked it and regrets his wickedness?",
            talk_questFinished = "I knew he was good after all! He'll be waiting anxiously. Thanks again, you helped a lot. Now go find him as agreed.",
            talk_questFinishFail = "Looks like you didn't.",
            talk_questDone = "",
            rewardExp = 0,
            requiredLevel = 0,
            questType = QUEST_TYPE.CUSTOM,
            questRequest = function(cid)
                return getCreatureStorage(cid, 8572) == QUEST_STATUS.FINISHED
            end,
            questStartItems = { 25260, 1, 25257, 1 },
            canStart = function(cid)
                return getPlayerDefeatedNPC(cid, 9706)
            end
        }
    },
    ["Santa Claus"] = {
        {
            storage = 8639,
            counterStorage = 8640,
            talk_questStarting = "Disguise, I'm disguised as Santa to prevent it get me, it worked so far, I'm all present and must deliver all the houses so that Christmas is not lost, so can you help me?",
            talk_questStarted = "So talk to my Rundolph, my Stantler, he has the ability to talk to you mentally, do not worry no one will listen to you, he was here somewhere, I can not look it now why I have to keep avoiding appearances they discover us, when you find Rundolph, tell him what city you want to get that in time he will inform me, do not worry, it will take you to this city. Remember to take the presents in the sleighs.",
            talk_questFinishing = "Did you helped Rundolph?",
            talk_questFinished = "Thank you! This was the best Christmas ever!",
            talk_questFinishFail = "Likes no. You are also carrying the jenny's radar? I need it too!",
            talk_questDone = "",
            rewardExp = 0,
            requiredLevel = 0,
            questType = QUEST_TYPE.CUSTOM,
            questRequest = function(cid)
                return getPlayerItemCountByUnique(cid, 25246) >= 1 and getCreatureStorage(cid, 8640) >= 45
            end,
            onEnd = function(cid)
                doPlayerRemoveItemByUnique(cid, 25246, 1)
                doPlayerAchievementCheck(cid, ACHIEVEMENT_IDS.GRINCH_XMAS_QUEST)
            end,
            rewardItems = {
                { type = REWARD_TYPE.ITEM, id = 25279, count = 3, unique = true },
                { type = REWARD_TYPE.ADDON, female = { looktype = 1404, addons = 3 }, male = { looktype = 1404, addons = 3 } }
            },
            canStart = function(cid)
                return getCreatureStorage(cid, 8572) == QUEST_STATUS.FINISHED
            end
        }
    },
    ["Corey"] = {
        {
            storage = 8660,
            talk_questStarting = "Nooo! My Pokemon! Someone took them! Will you help me?",
            talk_questStarted = "Can you help me get my Pokemon back?",
            talk_questFinishing = "Did you find my Pokemon?",
            talk_questFinished = "You are very good. Thank you!",
            talk_questFinishFail = "Looks like you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 27429, 1 },
            rewardExp = 0,
            requiredLevel = 60,
            startPosition = { x = 5529, y = 237, z = 6 },
            finishPosition = { x = 5529, y = 237, z = 6 },
            canStart = function(cid) return getPlayerDefeatedNPC(cid, 9707) end,
            onEnd = function(cid)
                for v = 8659, 8664 do
                    if (getCreatureStorage(cid, v) ~= QUEST_STATUS.FINISHED) then
                        return
                    end
                end

                doCreatureSay(cid, "Late kid, I do not need your Pokemon. I'm waiting for you in my battle arena, if you are so good come here without problems.", TALKTYPE_MONSTER_YELL)
            end
        },
    },
    ["Neesha"] = {
        {
            storage = 8661,
            talk_questStarting = "My Pokemon! What do I do now?",
            talk_questStarted = "Can you help me get my Pokemon back?",
            talk_questFinishing = "Did you find my Pokemon?",
            talk_questFinished = "You are very kind. Thank you.",
            talk_questFinishFail = "Looks like you haven't found them yet.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 27430, 1 },
            rewardExp = 0,
            requiredLevel = 60,
            startPosition = { x = 5532, y = 244, z = 6 },
            finishPosition = { x = 5532, y = 244, z = 6 },
            canStart = function(cid) return getPlayerDefeatedNPC(cid, 9707) end,
            onEnd = function(cid)
                for v = 8659, 8664 do
                    if (getCreatureStorage(cid, v) ~= QUEST_STATUS.FINISHED) then
                        return
                    end
                end

                doCreatureSay(cid, "Late kid, I do not need your Pokemon. I'm waiting for you in my battle arena, if you are so good come here without problems.", TALKTYPE_MONSTER_YELL)
            end
        },
    },
    ["Fergus"] = {
        {
            storage = 8664,
            talk_questStarting = "DAMN!",
            talk_questStarted = "This thing has stolen our Pokemon, help us find them!",
            talk_questFinishing = "Did you find our Pokemon?",
            talk_questFinished = "You really know what you're doing.",
            talk_questFinishFail = "Looks like you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 27433, 1 },
            rewardExp = 0,
            requiredLevel = 60,
            startPosition = { x = 5515, y = 243, z = 6 },
            finishPosition = { x = 5515, y = 243, z = 6 },
            canStart = function(cid) return getPlayerDefeatedNPC(cid, 9707) end,
            onEnd = function(cid)
                for v = 8659, 8664 do
                    if (getCreatureStorage(cid, v) ~= QUEST_STATUS.FINISHED) then
                        return
                    end
                end

                doCreatureSay(cid, "Late kid, I do not need your Pokemon. I'm waiting for you in my battle arena, if you are so good come here without problems.", TALKTYPE_MONSTER_YELL)
            end
        },
    },
    ["Sotashi"] = {
        {
            storage = 8671,
            talk_questStarting = "",
            talk_questStarted = "",
            talk_questFinishing = "Hum, do you found it?",
            talk_questFinished = "You really did it! Now we can have some answers... Here, take this, I've got them a long time ago, but I'm sure they still can be used to something.",
            talk_questFinishFail = "Looks like you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 28056, 1 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14461, count = 40, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            blockStart = true
        },
        {
            storage = 8672,
            talk_questStarting = "Ow, you, I can see you are trying hat to help us, but you haven't yet proved your honor. Before I let you talk to the Captain, do one more errand to me?",
            talk_questStarted = "Go to the nearest town and buy a mobile telescope, mine is broken and I cant get out to buy one.",
            talk_questFinishing = "So, you brought what I need?",
            talk_questFinished = "Excellent, you have a god taste. You solved a great problem with this. Seems like I can thrust you. Captain Nagumo was watching. She wants to see you, at her cabin. Here, take this and go see her.",
            talk_questFinishFail = "Looks like you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 28057, 1 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14461, count = 50, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            canStart = function(cid) return getCreatureStorage(cid, 8671) == QUEST_STATUS.FINISHED end
        },
        {
            storage = 8717,
            talk_questStarting = "",
            talk_questStarted = "",
            talk_questFinishing = "Hm, a letter from Calico, he trusts you so.",
            talk_questFinished = "All right, take this for your services.",
            talk_questFinishFail = "Looks like you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 28053, 1 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14461, count = 50, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            canStart = function(cid) return getCreatureStorage(cid, 8672) == QUEST_STATUS.FINISHED end,
        },
    },
    ["Nagumo Harbor"] = {
        {
            storage = 8673,
            talk_questStarting = "",
            talk_questStarted = "",
            talk_questFinishing = "Did you find Calico?",
            talk_questFinished = "He is alive, Calico is alive too! And he thrust you, I he does, so do I. Take this, came back when you are ready.",
            talk_questFinishFail = "Looks like you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.CUSTOM,
            questRequest = function(cid) return getCreatureStorage(cid, 8692) ~= QUEST_STATUS.UNSTARTED end,
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14461, count = 100, unique = true }, { type = REWARD_TYPE.ITEM, id = 28071, count = 1, unique = false } },
            rewardExp = 0,
            requiredLevel = 0,
        },
        {
            storage = 8674,
            talk_questStarting = "You are here, Ed Blackhood is building something and need these parts to finish. Can you take it to him?",
            talk_questStarted = "Right, I'll be waiting.",
            talk_questFinishing = "Dind you find Ed?",
            talk_questFinished = "Well done, Ed Blackhood already talked to me. I have some other busines to take care now, go talk to Sotashi.",
            talk_questFinishFail = "Looks like you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.CUSTOM,
            questRequest = function(cid) return getCreatureStorage(cid, 8677) ~= QUEST_STATUS.UNSTARTED end,
            rewardItems = {},
            questStartItems = { 28143, 1 },
            rewardExp = 0,
            requiredLevel = 0,
        },
        {
            storage = 8675,
            talk_questStarting = "Hello! Very well, you have been tested by Sotashi, it seems that it went very well, I see in you a discipline that can be used in our favor. As you know, I was trying to understand how I came to stop here, and I discovered, it's actually very sad, but there was a battle that I do not have memories of, and someone betrayed us, it would not be news to us pirates that someone was not But within our Alliance I can not say who could do this, but Blackhood informed me that he has a suspect. Blackhood believes that Calico could have enough reason to end the alliance, he was very quiet, did not mention his plans and it seems that it was not his dream to become someone from the sea, but from his brother, maybe he did not want to be There, and I really remember that Calico was not on his ship as we headed for 'Black Water.' If you could infiltrate the Lunatticus and find out something, I would be grateful, if you bring us answers, maybe I can give you an invitation. Are you going to help us?",
            talk_questStarted = "Ok, try to gain the trust of Jack and Calico and find out something.",
            talk_questFinishing = "So he asked you to deliver a letter to Sotashi, but Sotashi did not tell me anything.",
            talk_questFinished = "And this other {paper} you gave me, how did you do it?",
            talk_questFinishFail = "Looks like you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.CUSTOM,
            questRequest = function(cid) return getCreatureStorage(cid, 8716) == QUEST_STATUS.FINISHED end,
            rewardItems = {},
            rewardExp = 0,
            requiredLevel = 0,
            canStart = function(cid) return getPlayerDefeatedNPC(cid, 9709) end
        },
        {
            storage = 8676,
            talk_questStarting = "I understand, you got the document he asked for and this paper was together, it was very wise of me to hand him over, but he only has drawings that look like some kind of ritual, I do not understand.",
            talk_questStarted = "Take this paper and bring it to BlackHood, he understands these obscure things better, maybe he has some clue.",
            talk_questFinishing = "So that paper had information on black magic, from which to bring the dead to life, surely our return has to do with Calico.",
            talk_questFinished = "I can not trust anyone but you and Sotashi. Ed is trustworthy, but what puzzles me is he's aware of what these runes were, he's always dealt with something obscure, and he seems to know everything, it intrigues me. Tell Sotashi, I have to plan something to find out what Calico is planning. How? Did Sotashi get a letter from Calico? But he did not warn me of any recent information, is even Sotashi not reliable? I can not trust you too, I'm sorry, I need some time, take this in exchange for your favors, now go ... before I forget, Ed said he forgot to give you a bonus.",
            talk_questFinishFail = "Looks like you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.CUSTOM,
            questRequest = function(cid) return getCreatureStorage(cid, 8683) ~= QUEST_STATUS.UNSTARTED end,
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14461, count = 100, unique = true }, { type = REWARD_TYPE.ITEM, id = 14461, count = 50, unique = true }, { type = REWARD_TYPE.ADDON, female = { looktype = 1709, addons = 0 }, male = { looktype = 1710, addons = 0 } } },
            rewardExp = 0,
            requiredLevel = 0,
            canStart = function(cid) return getPlayerDefeatedNPC(cid, 9709) end
        },
    },
    ["Ed Blackhood"] = {
        {
            storage = 8677,
            talk_questStarting = "So you're not a Sea Dragon, that does not interest me, you brought me what I needed. What you have of special for Nagumo to trust you with such an important task, well it does not matter, since you're here, there's something I need you to do.",
            talk_questStarted = "Give this to Will, he's in the observation tower. Will does not like talking to strangers, just tell him it's the new bezel for his rifle.",
            talk_questFinishing = "Hmm, you've been useful to me, maybe I can use you one more time. Are you interested?",
            talk_questFinished = "It seems we are not the only ones who can not get away from our boats, Nagumo informed me that she is also stuck on your boat, I need you to test a device that I did. But first I need some ingredients to activate it. Bring me 100 water gem, 100 fire elements and 30 screws, that should be enough.",
            talk_questFinishFail = "Looks like you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questStartItems = { 28041, 1 },
            questType = QUEST_TYPE.CUSTOM,
            questRequest = function(cid) return getCreatureStorage(cid, 8714) == QUEST_STATUS.FINISHED end,
            rewardItems = {},
            rewardExp = 0,
            requiredLevel = 0,
            onEnd = function(cid)
                doCreatureSetStorage(cid, 8678, QUEST_STATUS.STARTED) -- Autostart 8678
            end,
            canStart = function(cid) return getPlayerItemCount(cid, 28143) > 0 end,
            onStart = function(cid) doPlayerRemoveItem(cid, 28143, 1) end
        },
        {
            storage = 8678,
            talk_questStarting = "",
            talk_questStarted = "",
            talk_questFinishing = "Hello, do you have my order there?",
            talk_questFinished = "Hum, it's all here, now I'm going to need some time to finish it, come back here in 1 hour.",
            talk_questFinishFail = "Looks like you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 12100, 100, 12101, 100, 12103, 30 },
            rewardItems = {},
            rewardExp = 0,
            requiredLevel = 0,
            onEnd = function(cid)
                doCreatureSetStorage(cid, 8679, QUEST_STATUS.STARTED) -- Autostart 8678
                doCreatureSetStorage(cid, 8680, os.time())
            end,
        },
        {
            storage = 8679,
            talk_questStarting = "",
            talk_questStarted = "",
            talk_questFinishing = "Oh, you are back.",
            talk_questFinished = "I finished the parts I needed, now I need you to take these 3 cores and put them in the right places, remember that they are organized by color, after activating them if everything happens well, we can travel to all ships in a flash Eyes. But of course, you can only use this if it is reliable.",
            talk_questFinishFail = "Looks like you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.CUSTOM,
            questRequest = function(cid)
                local diff = (getCreatureStorage(cid, 8680) + (60 * 60) - os.time())
                if (diff > 0) then
                    selfSay(string.format(__L(cid, "You must wait %s to continue."), table.concat(string.timediff(diff, cid))), cid)
                    return false
                end
                return true
            end,
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 28039, count = 1, unique = true }, { type = REWARD_TYPE.ITEM, id = 28040, count = 1, unique = true }, { type = REWARD_TYPE.ITEM, id = 28046, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            onEnd = function(cid)
                doCreatureSetStorage(cid, 8681, QUEST_STATUS.STARTED) -- Autostart 8681
            end,
        },
        {
            storage = 8681,
            talk_questStarting = "",
            talk_questStarted = "",
            talk_questFinishing = "Hmmm, I see you did it correctly.",
            talk_questFinished = "When you're worthy to use the teleportation, come back here, for now, take this, for all the help you have given me.",
            talk_questFinishFail = "Looks like you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.CUSTOM,
            questRequest = function(cid)
                local storages = { 8718, 8719, 8720 }
                for _, storage in pairs(storages) do
                    if (getCreatureStorage(cid, storage) ~= QUEST_STATUS.FINISHED) then
                        return false
                    end
                end
                return true
            end,
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14461, count = 100, unique = true }, { type = REWARD_TYPE.ITEM, id = 14461, count = 100, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            onEnd = function(cid)
                doCreatureSetStorage(cid, 8682, QUEST_STATUS.STARTED) -- Autostart 8682
            end,
        },
        {
            storage = 8682,
            talk_questStarting = "",
            talk_questStarted = "",
            talk_questFinishing = "I see you're a trustworthy member of our alliance, I do not think it's okay to let you use teleportation.",
            talk_questFinished = "With this teleportation you can travel to any of the boats in our alliance, and take this, with this device you can return here whenever you want, but it needs about 5 minutes to recharge.",
            talk_questFinishFail = "Looks like you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.CUSTOM,
            questRequest = function(cid)
                local storages = { 8694, 8695, 8696 }
                for _, storage in pairs(storages) do
                    if (getCreatureStorage(cid, storage) == QUEST_STATUS.UNSTARTED) then
                        return false
                    end
                end
                return true
            end,
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 28045, count = 1, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
        },
        {
            storage = 8683,
            talk_questStarting = "You're back, is there something important?",
            talk_questStarted = "You have a document with pictures for me to analyze, let me see. Where did you get this document? ... Calico ?? What does this do to him? What could he be planning with this ... Do you have any idea what this is? These are ancient runes used by ancient magicians who were able to bring the dead to life, now we are here, we come back from the dead and you tell me that this document with ancient runes was in the possession of one of us ... Special attention. Go to Nagumo, she will know what to ask, now I need to study these runes better.",
            talk_questFinishing = "Ah!! Glad you came back, I forgot to give you this.",
            talk_questFinished = "I have another {mission} for you.",
            talk_questFinishFail = "Looks like you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.BRING_ITEMS,
            --            questRequest = function(cid) return getCreatureStorage(cid, 8676) == QUEST_STATUS.FINISHED end,
            questRequest = { 28054, 1 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14461, count = 50, unique = true }, { type = REWARD_TYPE.ITEM, id = 28075, count = 5, unique = true }, { type = REWARD_TYPE.ADDON, female = { looktype = 1739, addons = 0 }, male = { looktype = 1740, addons = 0 } } },
            rewardExp = 0,
            requiredLevel = 0,
            canStart = function(cid) return getCreatureStorage(cid, 8682) == QUEST_STATUS.FINISHED end,
        },
        {
            storage = 8698,
            talk_questStarting = "Look, it's never been my custom to trust strangers, but I'm worried about Nagumo, she was an important ally, the only one I could trust, and from her reports you're trustworthy. I think I need to reciprocate years of help I got from her, do you want to help me?",
            talk_questStarted = "Well, I need to tell you a secret. When I lost my son Rickon, I sought revenge all my life in the quest for vengeance, there was hope of finding it again, so I tried every possible method for this, until a wizard pirate I met at the Pirate's Sanctuary told me there was A way of bringing the dead to life, in exchange for this knowledge I should enter into a sect. This Seite is called The Circle, later I should recruit members for it, while learning everything about black magic, I got some members for the Seita, among them Sotashi, Calico, Javy Dones and Nagumo. Redbeard and Jack did not agree to participate in this. One day, this magician who was my mentor was mysteriously killed and the Seita weakened, I left it aside, and tried to seek the knowledge that is in these drawings in other ways, Nagumo was only an apprentice but she gave up, however Javy Dones, Calico and Sotashi remained in the sect. I do not know their purpose, but it seems that some of them are involved around us. You must be thinking, as for me, if I would not be involved. You do not have to believe my words, but I can assure you that if I could bring someone to life, it would not be me again, but my son Rickon, and he is not here. Now that you know about these things, I need you to get the diaries of all 3 I spoke to, Sotashi, Calico and Javy Dones, and we'll find out what's going on. Look for the ships, you must find somewhere.",
            talk_questFinishing = "You found the diaries.",
            talk_questFinished = "Come back in one hour, I need to read everyone carefully and I must be alone.",
            talk_questFinishFail = "Looks like you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 28160, 1, 28161, 1, 28162, 1 },
            rewardItems = {}, -- todo
            rewardExp = 0,
            requiredLevel = 0,
            canStart = function(cid) return getCreatureStorage(cid, 8683) == QUEST_STATUS.FINISHED end,
            onEnd = function(cid) doCreatureSetStorage(cid, 8705, os.time()) end
        },
        {
            storage = 8699,
            talk_questStarting = "I have not found anything that proves anything, but there is some information here.",
            talk_questStarted = "Sotashi, was studying sacrificial runes, if he got what he planned, if I was right, he could have done something for Nagumo to die, so bringing her life back, he would live forever by his side, I think it's probably true , He seems to have a crush on Nagumo. Already Javy Dones was looking for a way to use these runes to bring the dead to life and to use them in some way, I believe it makes sense that he can ask questions of the dead and use them as brute force if he could enrich himself in that way, This is questionable. Calico already seemed to be more interested in some kind of revenge, because he seems to be the only one who already knew the effect of imprisonment, near the place of his death, which leaves us trapped in the ship, but why would he do it with us ? Does not make sense. I see no alternative but to confront all 3, they will have to explain themselves, go in them and say everything they know, and make them say what they planned, we have no other option.",
            talk_questFinishing = "It is not possible, someone is lying.",
            talk_questFinished = "Well, we can not know who the liar is, we're on zero again... let me {think}...",
            talk_questFinishFail = "Looks like you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.CUSTOM,
            questRequest = function(cid)
                for storage = 8706, 8708 do
                    if (getCreatureStorage(cid, storage) ~= QUEST_STATUS.FINISHED) then
                        return false
                    end
                end
                return true
            end,
            rewardItems = {}, -- todo
            rewardExp = 0,
            requiredLevel = 0,
            canStart = function(cid)
                if (getCreatureStorage(cid, 8698) ~= QUEST_STATUS.FINISHED) then
                    return false
                end

                local diff = (getCreatureStorage(cid, 8705) + (60 * 60) - os.time())
                if (diff > 0) then
                    selfSay(string.format(__L(cid, "You must wait %s to continue."), table.concat(string.timediff(diff, cid))), cid)
                    return false
                end
                return true
            end
        },
        {
            storage = 8700,
            talk_questStarting = "Look, I do not believe Calico very much, but I was curious about this rune he mentioned, I need you to go back to him, and ask him to draw that rune, let's suppose we believe what he said, and see how far it takes. Will you do it?",
            talk_questStarted = "Ok, find Calico and ask him.",
            talk_questFinishing = "Hmm, this symbol is familiar to me, I've seen it before ... let me remember ... ah yes of course, Sotashi, himself ... would it be him then?",
            talk_questFinished = "This symbol was in a medal that Sotashi has in his cabin, had seen in a meeting there, I {remembered} why the medal did not fit with anything in that cabin, it does not look like a Japanese medallion...",
            talk_questFinishFail = "Looks like you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.CUSTOM,
            questRequest = function(cid)
                return getCreatureStorage(cid, 8709) == QUEST_STATUS.FINISHED
            end,
            rewardItems = {},
            rewardExp = 0,
            requiredLevel = 0,
            canStart = function(cid) return getCreatureStorage(cid, 8699) == QUEST_STATUS.FINISHED end,
        },
        {
            storage = 8701,
            talk_questStarting = "I have a new guess, are you ready to investigate?",
            talk_questStarted = "Go to Nagumo, and ask her about Sotashi's medallion.",
            talk_questFinishing = "This medallion was never Will's... I'm sure...",
            talk_questFinished = "!",
            talk_questFinishFail = "Looks like you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.CUSTOM,
            questRequest = function(cid)
                return getCreatureStorage(cid, 8711) == QUEST_STATUS.FINISHED
            end,
            rewardItems = {}, -- todo
            rewardExp = 0,
            requiredLevel = 0,
            canStart = function(cid) return getCreatureStorage(cid, 8700) == QUEST_STATUS.FINISHED end,
            onEnd = function(cid)
                doCreatureAddStatus(cid, CREATURE_STATUS_SLEEP)
                doTeleportThing(cid, { x = 5745, y = 267, z = 5 })
                doCreatureSetNoMove(cid, true)
                doMutePlayer(cid, 60)
                setPlayerBlockLogout(cid, true)

                if (not getNpcAtPosition({ x = 5745, y = 263, z = 5 }, "Will Kid")) then
                    local npcPos = { x = 5745, y = 263, z = 5 }
                    local npcId = doCreateNpc("Will Kid", npcPos)
                    doSendMagicEffect(npcPos, EFFECT_TELEPORT_FRAME)
                    doCreatureSetLookDirection(npcId, SOUTH)
                end
            end
        },
    },
    ["Barba Roja"] = {
        {
            storage = 8684,
            talk_questStarting = "Well, I promised you 1 Rum Punch, but there's a problem, well something bizarre prevents us from leaving the ships, that's bad, we can not steal ... er I mean, make profits, and our seats are all destroyed due to time. ..you could go to the city and get new ones, then I can pay you what I owe, and you pay what you owe for taking my time. Will you do this?",
            talk_questStarted = "Ok, I'll be waiting.",
            talk_questFinishing = "",
            talk_questFinished = "Hmm, you brought them all, solved a problem of mine, in exchange take this, 'I found' those boxes, I'll give you 1 for each pocket you bought, that of ... 10 boxes. Take your payment.",
            talk_questFinishFail = "Looks like you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 28048, 20 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 28073, count = 10 } },
            rewardExp = 0,
            requiredLevel = 0,
        },
        {
            storage = 8685,
            talk_questStarting = "I realized that you like gold, and if you want to prove the greatness of gold, you must prove your worth. For many years I was looking for a treasure that a banker buried, well he willingly told me how to find ... hehe. Since I can not get away from my ship, you must find this treasure, are you interested?",
            talk_questStarted = "So you need to know a few things ... while I beat up, I mean, politely asked the banker about the treasure, I ended up finding him with that compass. She does not seem to work, but according to him, next to the treasure she will point to him. I learned that he used to travel to Pewter, where he had a beautiful old town, the problem is that the city was buried thanks to an earthquake, maybe you look there. Use this to dig, it is my personal shovel, many treasures were unearthed with it, it is tradition.",
            talk_questFinishing = "I see you have found my treasure!",
            talk_questFinished = "Wonder, take this, it was in here, maybe it interests you. Well, you look like a guy I can work with, but now I need to get some sleep, and I do not like being around, go see if Javy has nothing to occupy you.",
            talk_questFinishFail = "Looks like you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questStartItems = { 28050, 1, 28047, 1 },
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 28051, 1 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14461, count = 100, unique = true }, { type = REWARD_TYPE.ITEM, id = 28074, count = 5 } },
            rewardExp = 0,
            requiredLevel = 0,
            canStart = function(cid) return getCreatureStorage(cid, 8686) == QUEST_STATUS.FINISHED end,
        },
    },
    ["Javy Dones"] = {
        {
            storage = 8686,
            talk_questStarting = "It does not interest you, but if you're curious, I can tell you something if you do a service, I pay well, well not very well, but if I earn enough, your percentage increases, are you interested?",
            talk_questStarted = "I have business with the Kanto bank, the bank owes me a sum, since I said I would end the robberies to the bank, if they paid me an annual security fee, as I am a man of words, I ensured that robberies to the bank ended , Now I want my money. Go to the bank and put that coin on the counter, they will give you a bag of money, bring me the money and I will give you a share. Oh, do not try to keep the money, I have business all over Kanto, and surely one of our scouts will be watching you ...",
            talk_questFinishing = "Hmm! It's all here, good.",
            talk_questFinished = "I promised a part was not, but I'll give you more than this, take some of it, certainly worth more than the percentage of money that would give you ...",
            talk_questFinishFail = "Looks like you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questStartItems = { 28169, 1 },
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 28049, 1 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14461, count = 100, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
        },
        {
            storage = 8687,
            talk_questStarting = "You're back in good time, I need you to do another job, are you willing?",
            talk_questStarted = "I need you to go get a paycheck from Calico, Jack Spearow's brother, that miserable little fellow owes me a fair sum, if you do that I can give you some reward.",
            talk_questFinishing = "Hmm! It's all here, good.",
            talk_questFinished = "I promised a part was not, but I'll give you more than this, take some of it, certainly worth more than the percentage of money that would give you ...",
            talk_questFinishFail = "Looks like you didn't.",
            talk_questDone = "That little clown asked me for some difficult things, I had to talk to a wizard to get it, and wizards are not usually easy to fool, so he owed me so much, take your share here.",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 28052, 1 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14461, count = 100, unique = true }, { type = REWARD_TYPE.ITEM, id = 14461, count = 100, unique = true }, { type = REWARD_TYPE.ADDON, female = { looktype = 1737, addons = 0 }, male = { looktype = 1738, addons = 0 } } },
            rewardExp = 0,
            requiredLevel = 0,
            canStart = function(cid) return getCreatureStorage(cid, 8685) == QUEST_STATUS.FINISHED end -- todo The player must have started the quest where Calico sends the player to deliver a diamond to Javy Dones.
        },
    },
    ["Jack Spearow"] = {
        {
            storage = 8688,
            talk_questStarting = "I want tea!!! You came from far away, did not you? You could bring us some tea, I'd be very grateful.",
            talk_questStarted = "Go to Celadon, at the food store there, have some tea I love, buy 100 packages and I'll reward you.",
            talk_questFinishing = "Where is?",
            talk_questFinished = "Yup! You brought me enough tea for months, as a reward take this.",
            talk_questFinishFail = "Looks like you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 28055, 100 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14461, count = 50, unique = true } },
            rewardExp = 0,
            requiredLevel = 0
        },
        {
            storage = 8690,
            talk_questStarting = "For some reason we can not get away from the ship, whenever we try a sensation takes care of us, it seems that our soul is gone, yesterday was looking for shells on the beach, and I saw a beautiful shell, but for 2 steps I could not get you Could you search for it? I can reward you for this.",
            talk_questStarted = "She's on the coast, I do not remember exactly where, but she's beautiful, you'll see her easily, find her and bring me here.",
            talk_questFinishing = "Ohh! She's beautiful, I'll clean her.",
            talk_questFinished = "Take this as a reward.",
            talk_questFinishFail = "Looks like you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 28142, 1 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14461, count = 50, unique = true } },
            rewardExp = 0,
            requiredLevel = 0
        },
    },
    ["Calico"] = {
        {
            storage = 8692,
            talk_questStarting = "Okay, Nagumo trusts you, I do not know if she explained it right, but whenever someone tells you Molor Varghalis, you should answer Molor Vahoaris, this means that you have the confidence of someone in the circle, but you are not yet ready to know Something about the circle. Since you're reliable, I can ask you a favor.",
            talk_questStarted = "At the corner table there is a sealed document, I need to give it to Sotashi, you should not read its contents and be careful what you do there, it's the first document, take it and take it to Sotashi.",
            talk_questFinishing = "Well, you did everything right.",
            talk_questFinished = "Do you know {Guns and Roses}?",
            talk_questFinishFail = "Looks like you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.CUSTOM,
            questRequest = function(cid) return getCreatureStorage(cid, 8717) == QUEST_STATUS.FINISHED end,
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14461, count = 50, unique = true } },
            rewardExp = 0,
            requiredLevel = 0,
            onStart = function(cid)
                doCreatureSetStorage(cid, 8717, QUEST_STATUS.STARTED) -- Autostart 8717
            end
        },
        {
            storage = 8693,
            talk_questStarting = "This is not your concern, but you can go there to make the payment, are you willing?",
            talk_questStarted = "Then deliver this diamond to Javy Dones, but be careful that Redbeard does not see it, this is a personal debt, not the faction, Redbeard may not like that Javy has not informed him of something that involves profits.",
            talk_questFinishing = "You made the payment.",
            talk_questFinished = "Very well, now I need some time to study some things here, and you can not stay, because you will disturb me, take this in your favor.",
            talk_questFinishFail = "Looks like you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.CUSTOM,
            questRequest = function(cid) return getCreatureStorage(cid, 8687) == QUEST_STATUS.FINISHED end,
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14461, count = 100, unique = true }, { type = REWARD_TYPE.ADDON, female = { looktype = 1707, addons = 0 }, male = { looktype = 1708, addons = 0 } } },
            rewardExp = 0,
            requiredLevel = 0,
            questStartItems = { 28052, 1 }
        },
    },
    ["Kenelm Reilly"] = {
        {
            storage = 8723,
            talk_questStarting = "Oh, you became interested! Hihihi, I saw by the look on your face... I can tell you more about it, but first I need you to bring me some cool items.",
            talk_questStarted = "Very cool! That's right! Find me the following: 5x Bitten Apple and 5x Mouldy Cheese.",
            talk_questFinishing = "My friend! Did you bring the items I ordered?",
            talk_questFinished = "That's it! Thank you, take your reward. My {research} will be a success!",
            talk_questFinishFail = "Looks like you don't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 12115, 5, 14497, 5 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 12244, count = 10 }, { type = REWARD_TYPE.ITEM, id = 12161, count = 5 } },
            rewardExp = 500,
        },
        {
            storage = 8724,
            talk_questStarting = "Since you have so much interest, I will tell you. But before that, could you do me one more favor?",
            talk_questStarted = "This time I will need the following items: 3x Tooth and 20x Bottle of Poison.",
            talk_questFinishing = "So fast, did you get it all?",
            talk_questFinished = "That's what I needed, you're getting good at it! My {research} is moving fast.",
            talk_questFinishFail = "Looks like you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 12117, 3, 12104, 20 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 12161, count = 5 }, { type = REWARD_TYPE.ITEM, id = 2152, count = 2 } },
            rewardExp = 750,
        },
        {
            storage = 8725,
            talk_questStarting = "Okay, this time I'll tell you, I promise! I just need you to bring me one more thing. Please!",
            talk_questStarted = "Actually it's two things, haha! 40x Water Gem and 40x Bottle of Poison.",
            talk_questFinishing = "My friend, do you have everything there?",
            talk_questFinished = "THANK YOU! You are amazing! Now, my {research} will change the world.",
            talk_questFinishFail = "Looks like you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 12100, 40, 12104, 40 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 12248, count = 1 }, { type = REWARD_TYPE.ITEM, id = 12244, count = 10 } },
            rewardExp = 1000,
        },
        {
            storage = 8726,
            talk_questStarting = "All right, I'll tell you, no more secrets. The truth is ... I AM ASH KETCHUM! Shiiii, do not tell anyone. Now I need one more favor.",
            talk_questStarted = "I knew I could count on you, bring me the following: 5x Bat Wing, 5x Tooth, 10x Mouldy Cheese, and 10x Bitten Apple.",
            talk_questFinishing = "Got it all for your friend Ash??",
            talk_questFinished = "Thank you, Pikachu! My research will reach the stars now!",
            talk_questFinishFail = "Looks like you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.BRING_ITEMS,
            questRequest = { 12124, 5, 12117, 5, 14497, 10, 12115, 10 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 12165, count = 5 }, { type = REWARD_TYPE.ITEM, id = 12245, count = 10 }, { type = REWARD_TYPE.ITEM, id = 18639, count = 1 } },
            rewardExp = 1250,
        },
    },
    ["Arron Deforest"] = {
        {
            storage = 8727,
            talk_questStarting = "Err... Actually I still haven't got my first Pokemon, could you help me?",
            talk_questStarted = "My dream is to start my journey with a Rattata, my favorite Pokemon! If you bring one for me, I will give you a very good reward.",
            talk_questFinishing = "Did you get my Rattata?",
            talk_questFinished = "Beautiful! Thank you very much! I'll take good care of him... now I will really become a {Pokemon} trainer.",
            talk_questFinishFail = "Looks like you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.BRING_POKEMON,
            questRequest = "Rattata",
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 2152, count = 4 } },
            rewardExp = 500,
        },
        {
            storage = 8728,
            talk_questStarting = "Errr! Are you available? I need your help one more time.",
            talk_questStarted = "I don't know what I'm doing wrong, but no Pokemon wants to get into the Pokeballs I throw! Could you catch a Zubat for me?",
            talk_questFinishing = "The Zubat? Did you do it?",
            talk_questFinished = "Exactly! That's what I needed, thank you very much. Take your reward. You can tell I'm a real {Pokemon} trainer, right?",
            talk_questFinishFail = "Looks like you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.BRING_POKEMON,
            questRequest = "Zubat",
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 2152, count = 6 } },
            rewardExp = 750,
        },
        {
            storage = 8729,
            talk_questStarting = "Grrr! I hate this Professor Oak!",
            talk_questStarted = "Can you believe he never wanted to give me a Pokemon? Thanks to you I have some now, but... can you bring a Poliwag for me? Thank you.",
            talk_questFinishing = "Where's Poliwag?",
            talk_questFinished = "Poliwag! It was the missing Pokemon on my team, thank you! Huhu! I'm becoming a great {Pokemon} trainer.",
            talk_questFinishFail = "Looks like you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.BRING_POKEMON,
            questRequest = "Poliwag",
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 2152, count = 7 } },
            rewardExp = 1000,
        },
        {
            storage = 8730,
            talk_questStarting = "I'm missing a grass-type Pokemon on my team!",
            talk_questStarted = "Please, I need an Oddish.",
            talk_questFinishing = "Did you find Oddish?",
            talk_questFinished = "Wow! You're awesome, thank you! My mother won't even believe I became the greatest {Pokemon} trainer in the world.",
            talk_questFinishFail = "Looks like you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.BRING_POKEMON,
            questRequest = "Oddish",
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 2152, count = 8 } },
            rewardExp = 1250,
        },
        {
            storage = 8731,
            talk_questStarting = "Okay, actually, I still need more Pokemon, then I'll really become the best of all.",
            talk_questStarted = "Do not tell anyone, but I need an Ekans. It will be my great triumph.",
            talk_questFinishing = "Did you bring me Ekans?",
            talk_questFinished = "Wow! Thank you! Err... Don't you ever dare challenge me to a duel. Now I'm going to show Oak who I am.",
            talk_questFinishFail = "Looks like you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.BRING_POKEMON,
            questRequest = "Ekans",
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 2152, count = 10 } },
            rewardExp = 1500,
        },
    },
    ["Warwick Howard"] = {
        {
            storage = 8732,
            talk_questStarting = "Yes, I'm a Pokemon fan! I want to get information on every Pokemon. Can you help me out a bit?",
            talk_questStarted = "I need you to collect information from 5 Pokemon with your Pokedex!",
            talk_questFinishing = "Did you get the information I asked for?",
            talk_questFinished = "Really cool, thanks! When you're ready, I have another {task} for you.",
            talk_questFinishFail = "Looks like you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.DEX_POKEMONS,
            questRequest = 5,
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 12244, count = 10 } },
            rewardExp = 500,
        },
        {
            storage = 8733,
            talk_questStarting = "Hahaha! I've always really enjoyed Pokemon, they're so cool... Can you help me with some more information?",
            talk_questStarted = "Okay, now I need you to gather information from 10 Pokemon.",
            talk_questFinishing = "Did you get the information??",
            talk_questFinished = "THIS! Thank you. I really needed this information, I love these {Pokemon}.",
            talk_questFinishFail = "Looks like you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.DEX_POKEMONS,
            questRequest = 10,
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 12161, count = 10 } },
            rewardExp = 750,
        },
        {
            storage = 8734,
            talk_questStarting = "You're very good at it, can you help me one more time, please?",
            talk_questStarted = "Now, I'm going to need information on 20 Pokemon!",
            talk_questFinishing = "Wow, did you get the information?",
            talk_questFinished = "Very well! Yes! Yes! Yes! I want information on all types of {Pokemon}! Take your reward.",
            talk_questFinishFail = "Looks like you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.DEX_POKEMONS,
            questRequest = 20,
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 12248, count = 3 } },
            rewardExp = 1000,
        },
        {
            storage = 8735,
            talk_questStarting = "Since I was little I wanted to be a Squirtle, but as a teenager I wanted to be a Golduck. Oops! I mean... can you get some more information?",
            talk_questStarted = "Hehe! I need information on 30 Pokemon now.",
            talk_questFinishing = "Wow, you got it?",
            talk_questFinished = "Congratulations, you really impressed me. You got all the {Pokemon} I asked for. Thank you.",
            talk_questFinishFail = "Looks like you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.DEX_POKEMONS,
            questRequest = 30,
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 12250, count = 2 } },
            rewardExp = 1250,
        },
        {
            storage = 8736,
            talk_questStarting = "In fact, Venusaur has always been my favorite Pokemon, but I never told anyone. Now you know! So, can you do one last task for me?",
            talk_questStarted = "Can you bring me... information on 50 Pokemon?!",
            talk_questFinishing = "Did you get all the information?",
            talk_questFinished = "I have no words to thank you, you really helped me a lot. I will be forever grateful, take your reward.",
            talk_questFinishFail = "Looks like you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.DEX_POKEMONS,
            questRequest = 50,
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 17347, count = 1 } },
            rewardExp = 1500,
        },
    },
    ["Bertina Stacy"] = {
        {
            storage = 8737,
            counterStorage = 8747,
            talk_questStarting = "It's all the fault of the city's filthy sewers. That's why I don't like Pokemon, they destroy all my flowers. Can you help me?",
            talk_questStarted = "Okay, I need you to defeat 10x Rattata in the city manholes.",
            talk_questFinishing = "Have you already done it?",
            talk_questFinished = "Thank you very much, here's a reward. When you are available, I need a little more {help}.",
            talk_questFinishFail = "Looks like you haven't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.DEFEAT_POKEMON,
            questRequest = { "Rattata", 10 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 12161, count = 5 } },
            rewardExp = 500,
        },
        {
            storage = 8738,
            counterStorage = 8748,
            talk_questStarting = "In fact I discovered that the cause of the infestation are other Pokemon!",
            talk_questStarted = "It's those Zubats that are eating all my flowers, could you defeat 5x Zubat?",
            talk_questFinishing = "Did you defeat them?",
            talk_questFinished = "Wow thank you very much. Hopefully these {Pokemon} will not haunt me anymore.",
            talk_questFinishFail = "Looks like you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.DEFEAT_POKEMON,
            questRequest = { "Zubat", 5 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 12244, count = 10 } },
            rewardExp = 750,
        },
        {
            storage = 8739,
            counterStorage = 8749,
            talk_questStarting = "You will not believe it, but the infestation is not over yet.",
            talk_questStarted = "I thought it was over, but these terrible ones showed up. Please defeat 5x Weedle.",
            talk_questFinishing = "Did you get them out of my yard?",
            talk_questFinished = "It's good to be able to count on you, thank you. Hope these {Pokemon} never come back.",
            talk_questFinishFail = "Looks like you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.DEFEAT_POKEMON,
            questRequest = { "Weedle", 5 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 2152, count = 3 } },
            rewardExp = 1000,
        },
        {
            storage = 8740,
            counterStorage = 8750,
            talk_questStarting = "My biggest fear is these horrible snakes that have appeared, I can't even get into my house anymore.",
            talk_questStarted = "Yes, they are very dangerous. I need you to defeat 10x Ekans.",
            talk_questFinishing = "Did you get them out of my yard?",
            talk_questFinished = "Uf! Now, this is all over. I will be able to grow my flowers again, take your reward, thank you very much.",
            talk_questFinishFail = "Looks like you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.DEFEAT_POKEMON,
            questRequest = { "Ekans", 10 },
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 2152, count = 5 }, { type = REWARD_TYPE.ITEM, id = 12248, count = 2 } },
            rewardExp = 1250,
        },
    },
    ["Rusty Barret"] = {
        {
            storage = 8741,
            talk_questStarting = "I know I'm the best of all fishermen. Do you happen to want to be my pupil? I can give you the best advice from the seven seas.",
            talk_questStarted = "Okay, first reach fishing level 5.",
            talk_questFinishing = "Did you get what I asked for?",
            talk_questFinished = "Okay, that's a start. The life of a {fisherman} is not easy.",
            talk_questFinishFail = "Looks like you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.CUSTOM,
            questRequest = function(cid)
                return getPlayerSkillLevel(cid, PLAYER_SKILL_FISHING) >= 5
            end,
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 14633, count = 5, unique = true }, { type = REWARD_TYPE.ITEM, id = 12244, count = 5 } },
            rewardExp = 500,
        },
        {
            storage = 8742,
            talk_questStarting = "You're just getting started, now let's go to the next step.",
            talk_questStarted = "Now reach fishing level 10.",
            talk_questFinishing = "Did you get what I asked for?",
            talk_questFinished = "You're doing well, but do not think you already know everything! We have a long way to go. When you're ready, come back for the next {mission}.",
            talk_questFinishFail = "Looks like you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.CUSTOM,
            questRequest = function(cid)
                return getPlayerSkillLevel(cid, PLAYER_SKILL_FISHING) >= 10
            end,
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 2152, count = 3 } },
            rewardExp = 1000,
        },
        {
            storage = 8743,
            talk_questStarting = "You're just getting started, now let's go to the next step.",
            talk_questStarted = "Now you have to reach fishing level 15.",
            talk_questFinishing = "Did you get the level I asked for?",
            talk_questFinished = "Now, I'm seeing some progress! I will make you a great {fisherman}.",
            talk_questFinishFail = "Looks like you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.CUSTOM,
            questRequest = function(cid)
                return getPlayerSkillLevel(cid, PLAYER_SKILL_FISHING) >= 15
            end,
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 2152, count = 5 } },
            rewardExp = 1250,
        },
        {
            storage = 8744,
            talk_questStarting = "The best fish are caught early in the morning, so you can't be lazy! Let's move on to the next mission.",
            talk_questStarted = "Reach fishing level 20!",
            talk_questFinishing = "Did you reach fishing level 20?",
            talk_questFinished = "Good! good! Take your reward for it. Your next {mission} will not be that easy.",
            talk_questFinishFail = "Looks like you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.CUSTOM,
            questRequest = function(cid)
                return getPlayerSkillLevel(cid, PLAYER_SKILL_FISHING) >= 20
            end,
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 12161, count = 10 }, { type = REWARD_TYPE.ITEM, id = 12244, count = 10 } },
            rewardExp = 1500,
        },
        {
            storage = 8745,
            talk_questStarting = "Now things are heating up!",
            talk_questStarted = "Show me what you are capable of, reach fishing level 30!",
            talk_questFinishing = "Have you already achieved fishing level 30?",
            talk_questFinished = "At first I did not put much faith in you, but now I have to admit, you are becoming a great {fisherman}.",
            talk_questFinishFail = "Looks like you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.CUSTOM,
            questRequest = function(cid)
                return getPlayerSkillLevel(cid, PLAYER_SKILL_FISHING) >= 30
            end,
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 12165, count = 10 }, { type = REWARD_TYPE.ITEM, id = 12248, count = 3 } },
            rewardExp = 1750,
        },
        {
            storage = 8746,
            talk_questStarting = "The secret of fishing is patience, you need to have a lot of patience. That's how I got my biggest fish. Let's continue? Your last mission with me.",
            talk_questStarted = "After this last step, you'll officially be a professional fisherman. Reach fishing level 50.",
            talk_questFinishing = "Did you get the last level already?",
            talk_questFinished = "Congratulations! You have proved that you are capable! Take your reward. Now go explore the world beyond this continent, maybe one day we'll talk again.",
            talk_questFinishFail = "Looks like you didn't.",
            talk_questDone = "Thanks but I have no more tasks for now.",
            questType = QUEST_TYPE.CUSTOM,
            questRequest = function(cid)
                return getPlayerSkillLevel(cid, PLAYER_SKILL_FISHING) >= 50
            end,
            rewardItems = { { type = REWARD_TYPE.ITEM, id = 17355, count = 1 } },
            rewardExp = 2000,
        },
    }
}