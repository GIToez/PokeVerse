-- Written by scripts/make-quest-steps.py from the quests, their scripts, the NPCs and the map. Don't edit:
-- run it again after changing them. Where the quest log's Go there leads (lib/ps/systems/075-quests.lua).

-- the custom quests' steps, in the order their finishing check lists them
QUEST_STEPS = {
    [8204] = { -- Professor Oak
        { storage = 8205, places = { { x = 5527, y = 249, z = 6, label = "Talk to Misty" }, { x = 3915, y = 285, z = 10, label = "Talk to Misty" } } },
    },
    [8206] = { -- Professor Oak
        { storage = 8343, places = { { x = 3180, y = 659, z = 7, label = "Talk to Aleb" }, { x = 4145, y = 412, z = 8, label = "Talk to Denis" } } },
    },
    [8207] = { -- Runford
        { storage = 8353, places = { { x = 3337, y = 809, z = 6, label = "Talk to Professor Oak" }, { x = 5020, y = 788, z = 7, label = "Talk to Professor Oak" } } },
    },
    [8214] = { -- Professor Ivy
        { item = 18246, count = 1, places = { { x = 2759, y = 2782, z = 5, label = "Get the tangel rue leaves" }, { x = 2763, y = 2782, z = 5, label = "Get the tangel rue leaves" }, { x = 2764, y = 2780, z = 5, label = "Get the tangel rue leaves" }, { x = 2772, y = 2776, z = 5, label = "Get the tangel rue leaves" }, { x = 2773, y = 2777, z = 5, label = "Get the tangel rue leaves" }, { x = 2771, y = 2783, z = 6, label = "Get the tangel rue leaves" }, { x = 2779, y = 2780, z = 6, label = "Get the tangel rue leaves" }, { x = 2763, y = 2786, z = 5, label = "Get the tangel rue leaves" } } },
    },
    [8218] = { -- Professor Ivy
        { storage = 8233, places = { { x = 2931, y = 2931, z = 7, label = "Use the green cookie on Young Bellossom" } } },
        { storage = 8234, places = { { x = 2980, y = 2914, z = 5, label = "Use the green cookie on Young Butterfree" } } },
        { storage = 8235, places = { { x = 3045, y = 2940, z = 6, label = "Use the green cookie on Young Paras" } } },
        { storage = 8236, places = { { x = 3033, y = 2971, z = 8, label = "Use the green cookie on Young Raticate" } } },
        { storage = 8237, places = { { x = 3015, y = 2951, z = 6, label = "Use the green cookie on Young Spinarak" }, { x = 2940, y = 2989, z = 6, label = "Use the green cookie on Young Spinarak" } } },
        { storage = 8238, places = { { x = 3035, y = 2983, z = 6, label = "Use the green cookie on Young Vileplume" } } },
    },
    [8221] = { -- Hope
        { storage = 8222, places = { { x = 3031, y = 2556, z = 6, label = "Talk to Sir John" } } },
    },
    [8231] = { -- Professor Ivy
        { storage = 8213, places = { { x = 3337, y = 809, z = 6, label = "Talk to Professor Oak" }, { x = 5020, y = 788, z = 7, label = "Talk to Professor Oak" } } },
    },
    [8240] = { -- Adventurer Lucy
        { storage = 8241, places = { { x = 3502, y = 1947, z = 11, label = "Use it on the mystical flames" }, { x = 3504, y = 1946, z = 11, label = "Use it on the mystical flames" }, { x = 3505, y = 1944, z = 11, label = "Use it on the mystical flames" }, { x = 3511, y = 1944, z = 11, label = "Use it on the mystical flames" }, { x = 3512, y = 1946, z = 11, label = "Use it on the mystical flames" }, { x = 3514, y = 1947, z = 11, label = "Use it on the mystical flames" }, { x = 3502, y = 1952, z = 11, label = "Use it on the mystical flames" }, { x = 3505, y = 1953, z = 11, label = "Use it on the mystical flames" } } },
    },
    [8242] = { -- Prophet Slowking
        { storage = 8243, places = { { x = 4526, y = 2311, z = 9, label = "Talk to Chief Vaporeon" } } },
    },
    [8243] = { -- Chief Vaporeon
        { item = 18172, count = 2, places = { { x = 3320, y = 2376, z = 8, label = "Talk to Guardian Mantine" }, { x = 3678, y = 1655, z = 11, label = "Get the restore stone" } } },
    },
    [8248] = { -- Juanito Cruz
        { storage = 8249, places = { { x = 3668, y = 3229, z = 7, label = "Talk to Tereza Mendes" } } },
    },
    [8250] = { -- Pepper Denis
        { storage = 8251, places = { { x = 3447, y = 1736, z = 7, label = "Talk to Jayla Nonie" }, { x = 3481, y = 1694, z = 7, label = "Talk to Thorburn Tylor" }, { x = 3535, y = 1700, z = 7, label = "Talk to Lucas Ross" }, { x = 3570, y = 1726, z = 7, label = "Talk to Clemency Pamela" }, { x = 3556, y = 1691, z = 7, label = "Talk to Karaugh Janae" } } },
        { storage = 8252, places = { { x = 3447, y = 1736, z = 7, label = "Talk to Jayla Nonie" }, { x = 3481, y = 1694, z = 7, label = "Talk to Thorburn Tylor" }, { x = 3535, y = 1700, z = 7, label = "Talk to Lucas Ross" }, { x = 3570, y = 1726, z = 7, label = "Talk to Clemency Pamela" }, { x = 3556, y = 1691, z = 7, label = "Talk to Karaugh Janae" } } },
        { storage = 8253, places = { { x = 3447, y = 1736, z = 7, label = "Talk to Jayla Nonie" }, { x = 3481, y = 1694, z = 7, label = "Talk to Thorburn Tylor" }, { x = 3535, y = 1700, z = 7, label = "Talk to Lucas Ross" }, { x = 3570, y = 1726, z = 7, label = "Talk to Clemency Pamela" }, { x = 3556, y = 1691, z = 7, label = "Talk to Karaugh Janae" } } },
        { storage = 8254, places = { { x = 3447, y = 1736, z = 7, label = "Talk to Jayla Nonie" }, { x = 3481, y = 1694, z = 7, label = "Talk to Thorburn Tylor" }, { x = 3535, y = 1700, z = 7, label = "Talk to Lucas Ross" }, { x = 3570, y = 1726, z = 7, label = "Talk to Clemency Pamela" }, { x = 3556, y = 1691, z = 7, label = "Talk to Karaugh Janae" } } },
        { storage = 8255, places = { { x = 3447, y = 1736, z = 7, label = "Talk to Jayla Nonie" }, { x = 3481, y = 1694, z = 7, label = "Talk to Thorburn Tylor" }, { x = 3535, y = 1700, z = 7, label = "Talk to Lucas Ross" }, { x = 3570, y = 1726, z = 7, label = "Talk to Clemency Pamela" }, { x = 3556, y = 1691, z = 7, label = "Talk to Karaugh Janae" } } },
    },
    [8263] = { -- Farmer Steve
        { storage = 8347, atLeast = 5, places = { { x = 4098, y = 1769, z = 7, label = "Use the farmer steve seed here" }, { x = 4098, y = 1770, z = 7, label = "Use the farmer steve seed here" }, { x = 4098, y = 1771, z = 7, label = "Use the farmer steve seed here" }, { x = 4099, y = 1769, z = 7, label = "Use the farmer steve seed here" }, { x = 4099, y = 1770, z = 7, label = "Use the farmer steve seed here" }, { x = 4099, y = 1771, z = 7, label = "Use the farmer steve seed here" }, { x = 4100, y = 1769, z = 7, label = "Use the farmer steve seed here" }, { x = 4100, y = 1770, z = 7, label = "Use the farmer steve seed here" } } },
    },
    [8295] = { -- Kurt Fastman McGaryson
        { storage = 8299, atLeast = 10, places = { { x = 2943, y = 2223, z = 7, label = "Talk to Darius Linton" }, { x = 4441, y = 1757, z = 5, label = "Talk to Brigham Corwin" }, { x = 3341, y = 3205, z = 6, label = "Talk to Karin Sybil" }, { x = 2957, y = 2975, z = 6, label = "Talk to Robby Drummond" }, { x = 4448, y = 2258, z = 6, label = "Talk to Irene Jaylyn" }, { x = 3587, y = 1704, z = 6, label = "Talk to Giles Shaw" }, { x = 3062, y = 2575, z = 6, label = "Talk to Dusty Cheyenne" }, { x = 3261, y = 2777, z = 6, label = "Talk to Delaney Dinah" } } },
    },
    [8296] = { -- Kurt Fastman McGaryson
        { storage = 8297, places = { { x = 4144, y = 1780, z = 8, label = "Talk to Bud Jude" } } },
    },
    [8310] = { -- Jarrod
        { storage = 8337, atLeast = 10, places = { { x = 3001, y = 2231, z = 8, label = "Use it on Test Elekid" }, { x = 2990, y = 2238, z = 9, label = "Use it on Test Elekid" }, { x = 2993, y = 2214, z = 8, label = "Use it on Test Cleffa" }, { x = 2999, y = 2239, z = 8, label = "Use it on Test Cleffa" }, { x = 2999, y = 2242, z = 9, label = "Use it on Test Cleffa" }, { x = 2999, y = 2221, z = 8, label = "Use it on Test Igglybuff" }, { x = 2997, y = 2222, z = 9, label = "Use it on Test Igglybuff" }, { x = 2990, y = 2214, z = 9, label = "Use it on Test Magby" } } },
    },
    [8317] = { -- Woodworker Courts Ted
        { storage = 8318, places = { { x = 3687, y = 409, z = 7, label = "Talk to Beatriz" } } },
    },
    [8320] = { -- Woodworker Courts Ted
        { storage = 8323, atLeast = 5, places = { { x = 4892, y = 307, z = 4, label = "Use the mango on Courts Ted's Machop" }, { x = 2683, y = 2378, z = 7, label = "Use the mango on Courts Ted's Machop" } } },
    },
    [8328] = { -- Professor Oak
        { storage = 8368, places = { { x = 3508, y = 1990, z = 4, label = "Talk to Prophet Slowking" } } },
    },
    [8338] = { -- Professor Oak
        { storage = 8333, places = { { x = 3881, y = 916, z = 6, label = "Talk to Dr. Oravaf" } } },
    },
    [8369] = { -- Ancient Times
        { storage = 8371, places = { { x = 4939, y = 580, z = 7, label = "Defeat Ancient Blastoise" }, { x = 4926, y = 682, z = 7, label = "Defeat Ancient Charizard" }, { x = 4935, y = 500, z = 7, label = "Defeat Ancient Venusaur" } } },
    },
    [8396] = { -- Darion Clive
        { storage = 60023, places = { { x = 3684, y = 226, z = 5, label = "Go here" }, { x = 4013, y = 157, z = 9, label = "Go here" }, { x = 4052, y = 199, z = 11, label = "Go here" }, { x = 3298, y = 303, z = 9, label = "Go here" }, { x = 3296, y = 392, z = 8, label = "Go here" }, { x = 3583, y = 279, z = 7, label = "Go here" }, { x = 3576, y = 317, z = 7, label = "Go here" }, { x = 3555, y = 320, z = 7, label = "Go here" } } },
    },
    [8410] = { -- Assistant Guyli
        { storage = 8412, places = { { x = 3306, y = 809, z = 7, label = "Talk to Daisy Oak" } } },
    },
    [8411] = { -- Daisy Oak
        { storage = 8413, places = { { x = 3304, y = 603, z = 7, label = "Talk to Gary Oak" } } },
    },
    [8413] = { -- Gary Oak
        { storage = 8415, places = { { x = 3275, y = 610, z = 7, label = "Use the gary oak's magnifier on the shrapnel" } } },
        { storage = 8416, places = { { x = 3277, y = 608, z = 7, label = "Use the gary oak's magnifier on the branch" } } },
    },
    [8414] = { -- Gary Oak
        { battle = 9674, places = { { x = 3450, y = 245, z = 7, label = "Battle Gary Oak" }, { x = 3282, y = 262, z = 7, label = "Battle Gary Oak" }, { x = 3304, y = 603, z = 7, label = "Battle Gary Oak" } } },
    },
    [8417] = { -- Gary Oak
        { storage = 8509, places = { { x = 5216, y = 410, z = 7, label = "Go here" } } },
    },
    [8419] = { -- Gary Oak
        { storage = 8418, places = { { x = 3279, y = 813, z = 7, label = "Talk to Delia Ketchum" } } },
    },
    [8421] = { -- Bill
        { storage = 8422, places = { { x = 3316, y = 277, z = 7, label = "Talk to Officer Jenny" }, { x = 3913, y = 318, z = 7, label = "Talk to Officer Jenny" }, { x = 3295, y = 356, z = 7, label = "Talk to Officer Jenny" }, { x = 3672, y = 441, z = 7, label = "Talk to Officer Jenny" }, { x = 3963, y = 469, z = 7, label = "Talk to Officer Jenny" }, { x = 3290, y = 506, z = 7, label = "Talk to Officer Jenny" }, { x = 3280, y = 552, z = 7, label = "Talk to Officer Jenny" }, { x = 4201, y = 580, z = 7, label = "Talk to Officer Jenny" } } },
    },
    [8422] = { -- Officer Jenny
        { storage = 8423, places = { { x = 3336, y = 282, z = 7, label = "Use the police poster here" } } },
        { storage = 8424, places = { { x = 3288, y = 259, z = 7, label = "Use the police poster here" } } },
        { storage = 8425, places = { { x = 3297, y = 353, z = 7, label = "Use the police poster here" } } },
        { storage = 8426, places = { { x = 3311, y = 302, z = 7, label = "Use the police poster here" } } },
        { storage = 8427, places = { { x = 3892, y = 275, z = 7, label = "Use the police poster here" } } },
        { storage = 8428, places = { { x = 3859, y = 291, z = 7, label = "Use the police poster here" } } },
        { storage = 8429, places = { { x = 3879, y = 320, z = 7, label = "Use the police poster here" } } },
        { storage = 8430, places = { { x = 3927, y = 291, z = 7, label = "Use the police poster here" } } },
    },
    [8433] = { -- Captain Neil Pace
        { battle = 9675, places = { { x = 3852, y = 632, z = 7, label = "Battle Sailor Barrie Kaeden" } } },
        { battle = 9676, places = { { x = 3862, y = 632, z = 7, label = "Battle Sailor Carlton Tennyson" } } },
        { battle = 9677, places = { { x = 3862, y = 641, z = 7, label = "Battle Sailor Humphry Iggy" } } },
        { battle = 9678, places = { { x = 3862, y = 647, z = 6, label = "Battle Sailor Tex Garrick" } } },
        { battle = 9679, places = { { x = 3852, y = 632, z = 6, label = "Battle Sailor Whitaker Adolph" } } },
    },
    [8436] = { -- Rocket Captain
        { storage = 8437, places = { { x = 5022, y = 472, z = 7, label = "Use the captain rocket broom here" } } },
        { storage = 8438, places = { { x = 5025, y = 476, z = 7, label = "Use the captain rocket broom here" } } },
        { storage = 8483, places = { { x = 5040, y = 480, z = 7, label = "Use the captain rocket broom here" }, { x = 3283, y = 240, z = 7, label = "Use the cooked onigiri on Brockling Forrest" } } },
        { storage = 8484, places = { { x = 5039, y = 481, z = 7, label = "Use the captain rocket broom here" } } },
        { storage = 8485, places = { { x = 5038, y = 494, z = 7, label = "Use the captain rocket broom here" } } },
        { storage = 8486, places = { { x = 5022, y = 498, z = 7, label = "Use the captain rocket broom here" } } },
        { storage = 8487, places = { { x = 5038, y = 502, z = 7, label = "Use the captain rocket broom here" } } },
    },
    [8439] = { -- Justin Flowers
        { storage = 8440, places = { { x = 3257, y = 307, z = 7, label = "Use the blue flute on Sleeping Tauros" } } },
    },
    [8441] = { -- London Hamnet
        { storage = 8443, places = { { x = 3806, y = 266, z = 8, label = "Go here" } } },
    },
    [8444] = { -- London Hamnet
        { storage = 8445, places = { { x = 3811, y = 270, z = 8, label = "Use the pokemon gas medicine on Poisonous Weezing" } } },
    },
    [8446] = { -- Rick
        { storage = 8447, places = { { x = 3912, y = 849, z = 7, label = "Talk to Chewba" } } },
        { storage = 8449, places = { { x = 3876, y = 888, z = 7, label = "Talk to Luken" } } },
        { storage = 8450, places = { { x = 3910, y = 853, z = 6, label = "Talk to Lia" } } },
    },
    [8447] = { -- Chewba
        { storage = 8448, atLeast = 8, places = { { x = 3914, y = 844, z = 7, label = "Go here" }, { x = 3914, y = 845, z = 7, label = "Go here" }, { x = 3915, y = 844, z = 7, label = "Go here" }, { x = 3915, y = 845, z = 7, label = "Go here" }, { x = 3916, y = 844, z = 7, label = "Go here" }, { x = 3916, y = 845, z = 7, label = "Go here" }, { x = 3917, y = 844, z = 7, label = "Go here" }, { x = 3917, y = 845, z = 7, label = "Go here" } } },
    },
    [8449] = { -- Luken
        { storage = 8451, atLeast = 8, places = { { x = 3875, y = 1948, z = 7, label = "Use the order icon on the loose stone pile" }, { x = 3475, y = 3257, z = 8, label = "Use the order icon on the loose stone pile" }, { x = 2920, y = 1963, z = 8, label = "Use the order icon on the shallow water" }, { x = 2929, y = 1973, z = 8, label = "Use the order icon on the shallow water" }, { x = 3692, y = 1085, z = 7, label = "Use the order icon on the shallow water" }, { x = 3694, y = 1086, z = 7, label = "Use the order icon on the shallow water" }, { x = 3695, y = 1087, z = 7, label = "Use the order icon on the shallow water" }, { x = 4809, y = 275, z = 7, label = "Use the order icon on the shallow water" } } },
    },
    [8450] = { -- Lia
        { storage = 8452, atLeast = 6, places = { { x = 3875, y = 1948, z = 7, label = "Use the order icon on the loose stone pile" }, { x = 3475, y = 3257, z = 8, label = "Use the order icon on the loose stone pile" }, { x = 2920, y = 1963, z = 8, label = "Use the order icon on the shallow water" }, { x = 2929, y = 1973, z = 8, label = "Use the order icon on the shallow water" }, { x = 3692, y = 1085, z = 7, label = "Use the order icon on the shallow water" }, { x = 3694, y = 1086, z = 7, label = "Use the order icon on the shallow water" }, { x = 3695, y = 1087, z = 7, label = "Use the order icon on the shallow water" }, { x = 4809, y = 275, z = 7, label = "Use the order icon on the shallow water" } } },
    },
    [8456] = { -- Brock
        { storage = 8457, places = { { x = 3283, y = 240, z = 7, label = "Talk to Brockling Forrest" } } },
    },
    [8457] = { -- Brockling Forrest
        { storage = 8459, places = { { x = 3274, y = 245, z = 7, label = "Talk to Brockling Salvadore" } } },
        { storage = 8460, places = { { x = 3267, y = 250, z = 7, label = "Talk to Brockling Yolanda" } } },
        { storage = 8461, places = { { x = 3263, y = 244, z = 7, label = "Talk to Brockling Timmy" } } },
    },
    [8459] = { -- Brockling Salvadore
        { storage = 8476, places = { { x = 3267, y = 250, z = 7, label = "Use the cooked onigiri on Brockling Yolanda" } } },
        { storage = 8477, places = { { x = 3705, y = 488, z = 7, label = "Go here" }, { x = 3277, y = 241, z = 5, label = "Use the cooked onigiri on Brockling Suzie" } } },
        { storage = 8478, places = { { x = 3719, y = 477, z = 7, label = "Go here" }, { x = 3263, y = 244, z = 7, label = "Use the cooked onigiri on Brockling Timmy" } } },
        { storage = 8479, places = { { x = 3705, y = 482, z = 7, label = "Go here" }, { x = 3291, y = 238, z = 7, label = "Use the cooked onigiri on Brockling Billy" } } },
        { storage = 8480, places = { { x = 3715, y = 484, z = 7, label = "Go here" }, { x = 3282, y = 239, z = 6, label = "Use the cooked onigiri on Brockling Tilly" } } },
        { storage = 8481, places = { { x = 3717, y = 479, z = 7, label = "Go here" }, { x = 3274, y = 244, z = 6, label = "Use the cooked onigiri on Brockling Cindy" } } },
        { storage = 8482, places = { { x = 3280, y = 252, z = 7, label = "Use the cooked onigiri on Brockling Tommy" } } },
        { storage = 8483, places = { { x = 5040, y = 480, z = 7, label = "Use the captain rocket broom here" }, { x = 3283, y = 240, z = 7, label = "Use the cooked onigiri on Brockling Forrest" } } },
    },
    [8460] = { -- Brockling Yolanda
        { storage = 8462, places = { { x = 3268, y = 239, z = 7, label = "Use the esmeril on Flint's Golem" } } },
        { storage = 8463, places = { { x = 3268, y = 239, z = 7, label = "Use the crystal nugget on Flint's Golem" } } },
        { storage = 8464, places = { { x = 3266, y = 240, z = 7, label = "Use the golem's food on the empty pokemon bowl" }, { x = 3545, y = 274, z = 7, label = "Use the golem's food on the earth" }, { x = 3585, y = 278, z = 8, label = "Use the golem's food on the earth" }, { x = 4088, y = 3218, z = 9, label = "Use the golem's food on the earth" } } },
    },
    [8466] = { -- Misty
        { item = 12106, count = 50, drop = true }, -- tangela hair
    },
    [8468] = { -- Luther Lacey
        { item = 12106, count = 50, drop = true }, -- tangela hair
    },
    [8474] = { -- Sabrina
        { storage = 8475, places = { { x = 3860, y = 757, z = 6, label = "Use the psychic weaver on the stony pond" }, { x = 4075, y = 1735, z = 3, label = "Use the psychic weaver on the stony pond" }, { x = 3080, y = 2493, z = 5, label = "Use the psychic weaver on the stony pond" }, { x = 3090, y = 2502, z = 6, label = "Use the psychic weaver on the stony pond" }, { x = 3356, y = 3229, z = 5, label = "Use the psychic weaver on the stony pond" }, { x = 3985, y = 3432, z = 5, label = "Use the psychic weaver on the stony pond" }, { x = 4149, y = 418, z = 8, label = "Use the psychic weaver on the stony pond" }, { x = 4724, y = 1070, z = 6, label = "Use the psychic weaver on the stony pond" } } },
    },
    [8489] = { -- Flanagan
        { storage = 60028, places = { { x = 3684, y = 226, z = 5, label = "Go here" }, { x = 4013, y = 157, z = 9, label = "Go here" }, { x = 4052, y = 199, z = 11, label = "Go here" }, { x = 3298, y = 303, z = 9, label = "Go here" }, { x = 3296, y = 392, z = 8, label = "Go here" }, { x = 3583, y = 279, z = 7, label = "Go here" }, { x = 3576, y = 317, z = 7, label = "Go here" }, { x = 3555, y = 320, z = 7, label = "Go here" } } },
    },
    [8510] = { -- Bill
        { storage = 8511, places = { { x = 4256, y = 523, z = 3, label = "Talk to Mr. Fuji" } } },
    },
    [8511] = { -- Mr. Fuji
        { storage = 8512, places = { { x = 4132, y = 483, z = 6, label = "Use the empty mr. fuji poke ball on Fuji's Eevee" } } },
        { storage = 8513, places = { { x = 4158, y = 523, z = 8, label = "Use the empty mr. fuji poke ball on Fuji's Cubone" } } },
        { storage = 8514, places = { { x = 4056, y = 516, z = 7, label = "Use the empty mr. fuji poke ball on Fuji's Lickitung" } } },
        { storage = 8515, places = { { x = 4207, y = 613, z = 7, label = "Use the empty mr. fuji poke ball on Fuji's Totodile" } } },
        { storage = 8516, places = { { x = 4204, y = 503, z = 7, label = "Use the empty mr. fuji poke ball on Fuji's Pupitar" } } },
        { item = 25051, count = 5, places = { { x = 4132, y = 483, z = 6, label = "Get the charged mr. fuji poke ball" }, { x = 4158, y = 523, z = 8, label = "Get the charged mr. fuji poke ball" }, { x = 4056, y = 516, z = 7, label = "Get the charged mr. fuji poke ball" }, { x = 4207, y = 613, z = 7, label = "Get the charged mr. fuji poke ball" }, { x = 4204, y = 503, z = 7, label = "Get the charged mr. fuji poke ball" } } },
    },
    [8518] = { -- Briscoe Len
        { storage = 8522, places = { { x = 5796, y = 168, z = 6, label = "Use the activation tile on Sotashi" }, { x = 5799, y = 168, z = 6, label = "Use the activation tile on Nagumo Harbor" }, { x = 5515, y = 239, z = 6, label = "Use the activation tile on Ash's Pikachu" }, { x = 3748, y = 439, z = 9, label = "Use the activation tile on Ash's Pikachu" }, { x = 5080, y = 603, z = 9, label = "Use the activation tile on Mistery Guy" }, { x = 3251, y = 563, z = 5, label = "Use the activation tile on Giovanni" }, { x = 5031, y = 484, z = 8, label = "Use the activation tile on Giovanni" }, { x = 5032, y = 574, z = 9, label = "Use the activation tile on Giovanni" } } },
    },
    [8519] = { -- Briscoe Len
        { battle = 9697, places = { { x = 5080, y = 603, z = 9, label = "Battle Mistery Guy" } } },
    },
    [8520] = { -- Gary Oak
        { storage = 8525, places = { { x = 5517, y = 237, z = 6, label = "Talk to Ash Ketchum" }, { x = 5207, y = 502, z = 7, label = "Talk to Ash Ketchum" }, { x = 3898, y = 625, z = 7, label = "Talk to Ash Ketchum" } } },
    },
    [8527] = { -- Bill
        { storage = 8529, places = { { x = 5080, y = 603, z = 9, label = "Talk to Mistery Guy" } } },
    },
    [8542] = { -- Bill
        { storage = 8546, places = { { x = 5080, y = 603, z = 9, label = "Talk to Mistery Guy" } } },
    },
    [8544] = { -- Briscoe Len
        { storage = 8547, places = { { x = 3251, y = 563, z = 5, label = "Talk to Giovanni" }, { x = 5031, y = 484, z = 8, label = "Talk to Giovanni" }, { x = 5032, y = 574, z = 9, label = "Talk to Giovanni" }, { x = 3316, y = 277, z = 7, label = "Talk to Officer Jenny" }, { x = 3913, y = 318, z = 7, label = "Talk to Officer Jenny" }, { x = 3295, y = 356, z = 7, label = "Talk to Officer Jenny" }, { x = 3672, y = 441, z = 7, label = "Talk to Officer Jenny" }, { x = 3963, y = 469, z = 7, label = "Talk to Officer Jenny" } } },
    },
    [8546] = { -- Mistery Guy
        { storage = 8547, places = { { x = 3251, y = 563, z = 5, label = "Talk to Giovanni" }, { x = 5031, y = 484, z = 8, label = "Talk to Giovanni" }, { x = 5032, y = 574, z = 9, label = "Talk to Giovanni" }, { x = 3316, y = 277, z = 7, label = "Talk to Officer Jenny" }, { x = 3913, y = 318, z = 7, label = "Talk to Officer Jenny" }, { x = 3295, y = 356, z = 7, label = "Talk to Officer Jenny" }, { x = 3672, y = 441, z = 7, label = "Talk to Officer Jenny" }, { x = 3963, y = 469, z = 7, label = "Talk to Officer Jenny" } } },
    },
    [8548] = { -- Bill
        { storage = 8546, places = { { x = 5080, y = 603, z = 9, label = "Talk to Mistery Guy" } } },
    },
    [8639] = { -- Santa Claus
        { storage = 8640, atLeast = 45, places = { { x = 4899, y = 292, z = 8, label = "Use the normal present bag on the wooden floor" }, { x = 4904, y = 292, z = 8, label = "Use the normal present bag on the wooden floor" }, { x = 4899, y = 298, z = 8, label = "Use the normal present bag on the wooden floor" }, { x = 4904, y = 298, z = 8, label = "Use the normal present bag on the wooden floor" }, { x = 3566, y = 395, z = 6, label = "Use the normal present bag on the rock" }, { x = 3096, y = 1886, z = 7, label = "Use the normal present bag on the rock" }, { x = 3720, y = 502, z = 11, label = "Use the normal present bag on the dwarven statue" }, { x = 2523, y = 399, z = 11, label = "Use the normal present bag on the dwarven statue" } } },
    },
    [8673] = { -- Nagumo Harbor
        { storage = 8692, places = { { x = 5853, y = 140, z = 6, label = "Talk to Calico" } } },
    },
    [8674] = { -- Nagumo Harbor
        { storage = 8677, places = { { x = 5765, y = 188, z = 6, label = "Talk to Ed Blackhood" } } },
    },
    [8675] = { -- Nagumo Harbor
        { storage = 8716, places = { { x = 5796, y = 168, z = 6, label = "Use the activation tile on Sotashi" }, { x = 5799, y = 168, z = 6, label = "Use the activation tile on Nagumo Harbor" }, { x = 5515, y = 239, z = 6, label = "Use the activation tile on Ash's Pikachu" }, { x = 3748, y = 439, z = 9, label = "Use the activation tile on Ash's Pikachu" }, { x = 5080, y = 603, z = 9, label = "Use the activation tile on Mistery Guy" }, { x = 3251, y = 563, z = 5, label = "Use the activation tile on Giovanni" }, { x = 5031, y = 484, z = 8, label = "Use the activation tile on Giovanni" }, { x = 5032, y = 574, z = 9, label = "Use the activation tile on Giovanni" } } },
    },
    [8676] = { -- Nagumo Harbor
        { storage = 8683, places = { { x = 5765, y = 188, z = 6, label = "Talk to Ed Blackhood" } } },
    },
    [8682] = { -- Ed Blackhood
        { storage = 8694, places = { { x = 4661, y = 104, z = 7, label = "Talk to Peter Paul" }, { x = 4634, y = 122, z = 7, label = "Talk to Peter Paul" } } },
        { storage = 8695, places = { { x = 4661, y = 104, z = 7, label = "Talk to Peter Paul" }, { x = 4634, y = 122, z = 7, label = "Talk to Peter Paul" } } },
        { storage = 8696, places = { { x = 4661, y = 104, z = 7, label = "Talk to Peter Paul" }, { x = 4634, y = 122, z = 7, label = "Talk to Peter Paul" } } },
    },
    [8692] = { -- Calico
        { storage = 8717, places = { { x = 5796, y = 168, z = 6, label = "Talk to Sotashi" } } },
    },
    [8693] = { -- Calico
        { storage = 8687, places = { { x = 5826, y = 218, z = 6, label = "Talk to Javy Dones" } } },
    },
    [8699] = { -- Ed Blackhood
        { storage = 8706, places = { { x = 5796, y = 168, z = 6, label = "Talk to Sotashi" } } },
        { storage = 8707, places = { { x = 5826, y = 218, z = 6, label = "Talk to Javy Dones" } } },
        { storage = 8708, places = { { x = 5853, y = 140, z = 6, label = "Talk to Calico" } } },
    },
    [8700] = { -- Ed Blackhood
        { storage = 8709, places = { { x = 5853, y = 140, z = 6, label = "Talk to Calico" } } },
    },
    [8701] = { -- Ed Blackhood
        { storage = 8711, places = { { x = 5826, y = 218, z = 6, label = "Talk to Javy Dones" } } },
    },
}

-- where a quest item comes from when no wild Pokemon drops it
QUEST_ITEM_SOURCES = {
    [2120] = { { x = 3310, y = 537, z = 7, label = "Buy it from Brian" }, { x = 3954, y = 480, z = 7, label = "Buy it from Erick" }, { x = 3588, y = 3181, z = 7, label = "Buy it from Dale" }, { x = 3863, y = 293, z = 7, label = "Buy it from Wilson" }, { x = 4138, y = 1762, z = 7, label = "Buy it from Tristan" }, { x = 4172, y = 571, z = 7, label = "Buy it from Mark" }, { x = 2745, y = 2829, z = 6, label = "Buy it from Mel" }, { x = 3678, y = 422, z = 7, label = "Buy it from Joseph" } }, -- rope
    [2348] = { { x = 3905, y = 3082, z = 8, label = "The ancient rune is here" }, { x = 4794, y = 929, z = 3, label = "The ancient rune is here" }, { x = 4161, y = 2983, z = 5, label = "The ancient rune is here" } }, -- ancient rune
    [2553] = { { x = 3514, y = 318, z = 6, label = "Buy it from Fletcher" } }, -- pick
    [5091] = { { x = 3576, y = 317, z = 7, label = "The treasure map is here" }, { x = 5762, y = 118, z = 6, label = "The treasure map is here" }, { x = 5838, y = 213, z = 6, label = "The treasure map is here" } }, -- treasure map
    [5805] = { { x = 4025, y = 452, z = 5, label = "Battle Yushiro Lee for the golden goblet" } }, -- golden goblet
    [5806] = { { x = 4091, y = 418, z = 4, label = "Battle Kojiro Lee for the silver goblet" } }, -- silver goblet
    [5807] = { { x = 4047, y = 456, z = 5, label = "Battle Toshikazu Lee for the bronze goblet" } }, -- bronze goblet
    [5880] = { { x = 3510, y = 317, z = 6, label = "Get the iron ore" } }, -- iron ore
    [12157] = { { x = 3920, y = 792, z = 7, label = "Talk to Jeffrey" }, { x = 5791, y = 283, z = 6, label = "Talk to Selam" }, { x = 3988, y = 325, z = 9, label = "Talk to Selam" }, { x = 3310, y = 537, z = 7, label = "Buy it from Brian" }, { x = 3954, y = 480, z = 7, label = "Buy it from Erick" }, { x = 3588, y = 3181, z = 7, label = "Buy it from Dale" }, { x = 3863, y = 293, z = 7, label = "Buy it from Wilson" }, { x = 4138, y = 1762, z = 7, label = "Buy it from Tristan" } }, -- empty poke ball
    [12165] = { { x = 3920, y = 792, z = 7, label = "Talk to Jeffrey" }, { x = 3310, y = 537, z = 7, label = "Buy it from Brian" }, { x = 3954, y = 480, z = 7, label = "Buy it from Erick" }, { x = 3588, y = 3181, z = 7, label = "Buy it from Dale" }, { x = 3863, y = 293, z = 7, label = "Buy it from Wilson" }, { x = 4138, y = 1762, z = 7, label = "Buy it from Tristan" }, { x = 4172, y = 571, z = 7, label = "Buy it from Mark" }, { x = 2745, y = 2829, z = 6, label = "Buy it from Mel" } }, -- empty ultra ball
    [12204] = { { x = 529, y = 1522, z = 7, label = "Buy it from Dax Dane" }, { x = 1004, y = 1159, z = 5, label = "Buy it from Dreda Roni" }, { x = 448, y = 1144, z = 7, label = "Buy it from Upton Gavin" }, { x = 3844, y = 840, z = 7, label = "Buy it from Kris Sandy" }, { x = 3672, y = 415, z = 7, label = "Buy it from Owen" }, { x = 4216, y = 571, z = 7, label = "Buy it from Tomy" }, { x = 3960, y = 448, z = 7, label = "Buy it from Rian" }, { x = 1368, y = 1284, z = 4, label = "Buy it from Keira Toria" } }, -- churros with chocolate
    [12205] = { { x = 4221, y = 2933, z = 7, label = "Buy it from Stacy David" }, { x = 2764, y = 2831, z = 6, label = "Buy it from Gabriel Wright" }, { x = 540, y = 1717, z = 7, label = "Buy it from Cherette Kendal" }, { x = 355, y = 1692, z = 6, label = "Buy it from Narelle Geena" }, { x = 3490, y = 1717, z = 6, label = "Buy it from Shirley Rocky" }, { x = 285, y = 1521, z = 7, label = "Buy it from Coreen Chrystal" }, { x = 3336, y = 1015, z = 7, label = "Buy it from Robin" }, { x = 3258, y = 294, z = 7, label = "Buy it from Ray" } }, -- burger
    [12208] = { { x = 814, y = 1448, z = 6, label = "Buy it from Cohen Dacre" }, { x = 529, y = 1522, z = 7, label = "Buy it from Dax Dane" }, { x = 1004, y = 1159, z = 5, label = "Buy it from Dreda Roni" }, { x = 1585, y = 1546, z = 5, label = "Buy it from Anderson Dalton" }, { x = 3844, y = 840, z = 7, label = "Buy it from Kris Sandy" }, { x = 3960, y = 448, z = 7, label = "Buy it from Rian" }, { x = 1368, y = 1284, z = 4, label = "Buy it from Keira Toria" }, { x = 3695, y = 408, z = 5, label = "Buy it from Sam" } }, -- sushi
    [12210] = { { x = 707, y = 1840, z = 6, label = "Buy it from Lou Kimmie" }, { x = 792, y = 1503, z = 7, label = "Buy it from Poppy Laila" }, { x = 3436, y = 1479, z = 7, label = "Buy it from Deven Rusty" }, { x = 3468, y = 3221, z = 6, label = "Buy it from Roydon Haywood" }, { x = 2965, y = 2979, z = 4, label = "Buy it from Wilkie Joshua" }, { x = 3332, y = 548, z = 7, label = "Buy it from Ren" } }, -- pizza
    [12212] = { { x = 814, y = 1448, z = 6, label = "Buy it from Cohen Dacre" }, { x = 529, y = 1522, z = 7, label = "Buy it from Dax Dane" }, { x = 1004, y = 1159, z = 5, label = "Buy it from Dreda Roni" }, { x = 3490, y = 1717, z = 6, label = "Buy it from Shirley Rocky" }, { x = 1585, y = 1546, z = 5, label = "Buy it from Anderson Dalton" }, { x = 4402, y = 1719, z = 7, label = "Buy it from Percy Page" }, { x = 3087, y = 1666, z = 7, label = "Buy it from Angus Ward" }, { x = 3844, y = 840, z = 7, label = "Buy it from Kris Sandy" } }, -- lemonade
    [12248] = { { x = 3310, y = 537, z = 7, label = "Buy it from Brian" }, { x = 3954, y = 480, z = 7, label = "Buy it from Erick" }, { x = 3588, y = 3181, z = 7, label = "Buy it from Dale" }, { x = 3863, y = 293, z = 7, label = "Buy it from Wilson" }, { x = 4138, y = 1762, z = 7, label = "Buy it from Tristan" }, { x = 4172, y = 571, z = 7, label = "Buy it from Mark" }, { x = 2745, y = 2829, z = 6, label = "Buy it from Mel" }, { x = 3678, y = 422, z = 7, label = "Buy it from Joseph" } }, -- pokemon revive
    [13011] = { { x = 3725, y = 1060, z = 7, label = "Talk to Agustin" } }, -- agustin message to rock
    [13012] = { { x = 3272, y = 906, z = 10, label = "The professor mark book is here" } }, -- professor mark book
    [13219] = { { x = 3310, y = 537, z = 7, label = "Buy it from Brian" }, { x = 3954, y = 480, z = 7, label = "Buy it from Erick" }, { x = 3588, y = 3181, z = 7, label = "Buy it from Dale" }, { x = 3863, y = 293, z = 7, label = "Buy it from Wilson" }, { x = 4138, y = 1762, z = 7, label = "Buy it from Tristan" }, { x = 4172, y = 571, z = 7, label = "Buy it from Mark" }, { x = 2745, y = 2829, z = 6, label = "Buy it from Mel" }, { x = 3678, y = 422, z = 7, label = "Buy it from Joseph" } }, -- flashlight
    [13812] = { { x = 3593, y = 543, z = 10, label = "Battle Basam for the rocket key" } }, -- rocket key
    [13813] = { { x = 3591, y = 559, z = 10, label = "Battle Drew for the rocket key" } }, -- rocket key
    [13814] = { { x = 3577, y = 559, z = 10, label = "Battle Kate for the rocket key" } }, -- rocket key
    [13815] = { { x = 3574, y = 544, z = 10, label = "Battle Jenny for the rocket key" } }, -- rocket key
    [13817] = { { x = 3584, y = 530, z = 10, label = "Get the charged nurse chansey ball" }, { x = 3581, y = 531, z = 10, label = "Get the charged nurse chansey ball" }, { x = 3586, y = 532, z = 10, label = "Get the charged nurse chansey ball" }, { x = 3582, y = 534, z = 10, label = "Get the charged nurse chansey ball" }, { x = 3587, y = 534, z = 10, label = "Get the charged nurse chansey ball" } }, -- charged nurse chansey ball
    [13972] = { { x = 3591, y = 284, z = 10, label = "The moon stone fragment is here" } }, -- moon stone fragment
    [18158] = { { x = 4119, y = 2993, z = 8, label = "Get the misty pokemon egg" } }, -- misty pokemon egg
    [18163] = { { x = 2710, y = 2451, z = 7, label = "Buy it from Ashton" } }, -- empty flask
    [18165] = { { x = 3050, y = 1697, z = 7, label = "Buy it from Dusty" } }, -- toolbox
    [18166] = { { x = 3048, y = 2564, z = 6, label = "Talk to Mateo" } }, -- crystal statue
    [18167] = { { x = 4812, y = 1032, z = 11, label = "The secret recipe is here" } }, -- secret recipe
    [18171] = { { x = 3525, y = 1633, z = 2, label = "Get the wampi fruit" }, { x = 3615, y = 1649, z = 5, label = "Get the wampi fruit" }, { x = 3921, y = 1972, z = 6, label = "Get the wampi fruit" }, { x = 3922, y = 1972, z = 6, label = "Get the wampi fruit" } }, -- wampi fruit
    [18173] = { { x = 3687, y = 412, z = 5, label = "Get the deepsoul stone" }, { x = 769, y = 1443, z = 6, label = "Get the deepsoul stone" }, { x = 3486, y = 1727, z = 5, label = "Get the deepsoul stone" }, { x = 2966, y = 2255, z = 6, label = "Get the deepsoul stone" }, { x = 2335, y = 723, z = 5, label = "Get the deepsoul stone" }, { x = 767, y = 1443, z = 6, label = "Get the deepsoul stone" }, { x = 3486, y = 1724, z = 5, label = "Get the deepsoul stone" }, { x = 5087, y = 509, z = 7, label = "Get the deepsoul stone" } }, -- deepsoul stone
    [18181] = { { x = 3588, y = 3181, z = 7, label = "Buy it from Dale" } }, -- lipstick
    [18184] = { { x = 3874, y = 2646, z = 13, label = "The oliver bear is here" } }, -- oliver bear
    [18188] = { { x = 4150, y = 3189, z = 7, label = "Get the donphan toy ball" } }, -- donphan toy ball
    [18192] = { { x = 4055, y = 313, z = 6, label = "The codex motor is here" }, { x = 5821, y = 294, z = 6, label = "The codex motor is here" } }, -- codex motor
    [18193] = { { x = 4055, y = 313, z = 6, label = "Get the energy transformer" }, { x = 5821, y = 294, z = 6, label = "Get the energy transformer" } }, -- energy transformer
    [18194] = { { x = 4055, y = 313, z = 6, label = "Get the bignose gear" }, { x = 5821, y = 294, z = 6, label = "Get the bignose gear" } }, -- bignose gear
    [18196] = { { x = 2723, y = 2834, z = 7, label = "Get the flavia necklace" }, { x = 2723, y = 2835, z = 7, label = "Get the flavia necklace" }, { x = 2724, y = 2834, z = 7, label = "Get the flavia necklace" }, { x = 2724, y = 2835, z = 7, label = "Get the flavia necklace" }, { x = 2725, y = 2834, z = 7, label = "Get the flavia necklace" }, { x = 2725, y = 2835, z = 7, label = "Get the flavia necklace" }, { x = 2722, y = 2837, z = 7, label = "Get the flavia necklace" }, { x = 2723, y = 2836, z = 7, label = "Get the flavia necklace" } }, -- flavia necklace
    [18245] = { { x = 2972, y = 2220, z = 6, label = "Talk to Albert" } }, -- tangel rue extraction
    [18246] = { { x = 2759, y = 2782, z = 5, label = "Get the tangel rue leaves" }, { x = 2763, y = 2782, z = 5, label = "Get the tangel rue leaves" }, { x = 2764, y = 2780, z = 5, label = "Get the tangel rue leaves" }, { x = 2772, y = 2776, z = 5, label = "Get the tangel rue leaves" }, { x = 2773, y = 2777, z = 5, label = "Get the tangel rue leaves" }, { x = 2771, y = 2783, z = 6, label = "Get the tangel rue leaves" }, { x = 2779, y = 2780, z = 6, label = "Get the tangel rue leaves" }, { x = 2763, y = 2786, z = 5, label = "Get the tangel rue leaves" } }, -- tangel rue leaves
    [18256] = { { x = 4299, y = 2486, z = 7, label = "Get the grape flower" }, { x = 4286, y = 2513, z = 7, label = "Get the grape flower" }, { x = 4324, y = 2512, z = 7, label = "Get the grape flower" }, { x = 4349, y = 2527, z = 7, label = "Get the grape flower" }, { x = 4315, y = 2543, z = 6, label = "Get the grape flower" }, { x = 4335, y = 2533, z = 5, label = "Get the grape flower" }, { x = 4333, y = 2538, z = 4, label = "Get the grape flower" }, { x = 4295, y = 2548, z = 7, label = "Get the grape flower" } }, -- grape flower
    [18302] = { { x = 4878, y = 278, z = 6, label = "Get the wood" }, { x = 4899, y = 289, z = 6, label = "Get the wood" }, { x = 4901, y = 288, z = 6, label = "Get the wood" }, { x = 4902, y = 320, z = 6, label = "Get the wood" } }, -- wood
    [18634] = { { x = 4691, y = 415, z = 6, label = "Get the baby ticket" }, { x = 4697, y = 422, z = 7, label = "Get the baby ticket" }, { x = 4705, y = 444, z = 7, label = "Get the baby ticket" }, { x = 4687, y = 448, z = 7, label = "Get the baby ticket" } }, -- baby ticket
    [18876] = { { x = 2800, y = 1802, z = 7, label = "Get the black pearl" }, { x = 3912, y = 3024, z = 5, label = "Get the black pearl" }, { x = 5007, y = 205, z = 7, label = "Get the black pearl" }, { x = 4688, y = 421, z = 7, label = "Get the black pearl" }, { x = 4684, y = 447, z = 7, label = "Get the black pearl" }, { x = 4704, y = 445, z = 7, label = "Get the black pearl" }, { x = 4193, y = 2509, z = 7, label = "Get the black pearl" }, { x = 4292, y = 2528, z = 7, label = "Get the black pearl" } }, -- black pearl
    [18880] = { { x = 4141, y = 1796, z = 3, label = "Get the ice yolk stone" }, { x = 4141, y = 1798, z = 3, label = "Get the ice yolk stone" }, { x = 4114, y = 1818, z = 5, label = "Get the ice yolk stone" }, { x = 4117, y = 1818, z = 5, label = "Get the ice yolk stone" }, { x = 4120, y = 1818, z = 5, label = "Get the ice yolk stone" }, { x = 4123, y = 1818, z = 5, label = "Get the ice yolk stone" }, { x = 4126, y = 1818, z = 5, label = "Get the ice yolk stone" }, { x = 4408, y = 2582, z = 6, label = "Get the ice yolk stone" } }, -- ice yolk stone
    [18883] = { { x = 3108, y = 380, z = 2, label = "Get the piece of cloth" }, { x = 3116, y = 383, z = 2, label = "Get the piece of cloth" }, { x = 3029, y = 1884, z = 8, label = "Get the piece of cloth" }, { x = 3027, y = 1896, z = 9, label = "Get the piece of cloth" }, { x = 3207, y = 1500, z = 4, label = "Get the piece of cloth" }, { x = 4422, y = 1747, z = 7, label = "Get the piece of cloth" }, { x = 2857, y = 1804, z = 6, label = "Get the piece of cloth" }, { x = 3402, y = 1650, z = 7, label = "Get the piece of cloth" } }, -- piece of cloth
    [23532] = { { x = 5080, y = 603, z = 9, label = "Get the acid foxglove extraction" } }, -- acid foxglove extraction
    [23538] = { { x = 3278, y = 812, z = 6, label = "Get the ash's letter" } }, -- ash's letter
    [23564] = { { x = 3875, y = 1948, z = 7, label = "Get the blue weed" }, { x = 3475, y = 3257, z = 8, label = "Get the blue weed" }, { x = 2920, y = 1963, z = 8, label = "Get the blue weed" }, { x = 2929, y = 1973, z = 8, label = "Get the blue weed" }, { x = 3692, y = 1085, z = 7, label = "Get the blue weed" }, { x = 3694, y = 1086, z = 7, label = "Get the blue weed" }, { x = 3695, y = 1087, z = 7, label = "Get the blue weed" }, { x = 4809, y = 275, z = 7, label = "Get the blue weed" } }, -- blue weed
    [23588] = { { x = 3875, y = 1948, z = 7, label = "Get the blue pollen" }, { x = 3475, y = 3257, z = 8, label = "Get the blue pollen" }, { x = 2920, y = 1963, z = 8, label = "Get the blue pollen" }, { x = 2929, y = 1973, z = 8, label = "Get the blue pollen" }, { x = 3692, y = 1085, z = 7, label = "Get the blue pollen" }, { x = 3694, y = 1086, z = 7, label = "Get the blue pollen" }, { x = 3695, y = 1087, z = 7, label = "Get the blue pollen" }, { x = 4809, y = 275, z = 7, label = "Get the blue pollen" } }, -- blue pollen
    [23594] = { { x = 3546, y = 273, z = 7, label = "Get the toy" }, { x = 3586, y = 277, z = 8, label = "Get the toy" }, { x = 3544, y = 272, z = 7, label = "Get the toy" }, { x = 3584, y = 276, z = 8, label = "Get the toy" } }, -- toy
    [25052] = { { x = 5796, y = 168, z = 6, label = "Get the ash's pikachu poke ball" }, { x = 5799, y = 168, z = 6, label = "Get the ash's pikachu poke ball" }, { x = 5515, y = 239, z = 6, label = "Get the ash's pikachu poke ball" }, { x = 3748, y = 439, z = 9, label = "Get the ash's pikachu poke ball" }, { x = 5080, y = 603, z = 9, label = "Get the ash's pikachu poke ball" }, { x = 3251, y = 563, z = 5, label = "Get the ash's pikachu poke ball" }, { x = 5031, y = 484, z = 8, label = "Get the ash's pikachu poke ball" }, { x = 5032, y = 574, z = 9, label = "Get the ash's pikachu poke ball" } }, -- ash's pikachu poke ball
    [25053] = { { x = 5796, y = 168, z = 6, label = "Get the pikachu's cage key" }, { x = 5799, y = 168, z = 6, label = "Get the pikachu's cage key" }, { x = 5515, y = 239, z = 6, label = "Get the pikachu's cage key" }, { x = 3748, y = 439, z = 9, label = "Get the pikachu's cage key" }, { x = 5080, y = 603, z = 9, label = "Get the pikachu's cage key" }, { x = 3251, y = 563, z = 5, label = "Get the pikachu's cage key" }, { x = 5031, y = 484, z = 8, label = "Get the pikachu's cage key" }, { x = 5032, y = 574, z = 9, label = "Get the pikachu's cage key" } }, -- pikachu's cage key
    [25244] = { { x = 5796, y = 168, z = 6, label = "Get the grinch's cloak" }, { x = 5799, y = 168, z = 6, label = "Get the grinch's cloak" }, { x = 5515, y = 239, z = 6, label = "Get the grinch's cloak" }, { x = 3748, y = 439, z = 9, label = "Get the grinch's cloak" }, { x = 5080, y = 603, z = 9, label = "Get the grinch's cloak" }, { x = 3251, y = 563, z = 5, label = "Get the grinch's cloak" }, { x = 5031, y = 484, z = 8, label = "Get the grinch's cloak" }, { x = 5032, y = 574, z = 9, label = "Get the grinch's cloak" } }, -- grinch's cloak
    [25245] = { { x = 5796, y = 168, z = 6, label = "Get the saw" }, { x = 5799, y = 168, z = 6, label = "Get the saw" }, { x = 5515, y = 239, z = 6, label = "Get the saw" }, { x = 3748, y = 439, z = 9, label = "Get the saw" }, { x = 5080, y = 603, z = 9, label = "Get the saw" }, { x = 3251, y = 563, z = 5, label = "Get the saw" }, { x = 5031, y = 484, z = 8, label = "Get the saw" }, { x = 5032, y = 574, z = 9, label = "Get the saw" } }, -- saw
    [27428] = { { x = 5499, y = 225, z = 6, label = "Get the ash's pokemon belt" } }, -- ash's pokemon belt
    [27429] = { { x = 5502, y = 245, z = 5, label = "Get the corey's pokemon belt" } }, -- corey's pokemon belt
    [27430] = { { x = 5541, y = 207, z = 5, label = "Get the neesha's pokemon belt" } }, -- neesha's pokemon belt
    [27431] = { { x = 5514, y = 223, z = 3, label = "Get the misty's pokemon belt" } }, -- misty's pokemon belt
    [27432] = { { x = 5536, y = 212, z = 3, label = "Get the brock's pokemon belt" } }, -- brock's pokemon belt
    [27433] = { { x = 5536, y = 238, z = 3, label = "Get the fergu's pokemon belt" } }, -- fergu's pokemon belt
    [28048] = { { x = 3836, y = 870, z = 7, label = "Buy it from Yancy Melville" } }, -- cup
    [28049] = { { x = 4709, y = 130, z = 6, label = "Get the cash bag" } }, -- cash bag
    [28053] = { { x = 5796, y = 168, z = 6, label = "Get the sotashi parchment" }, { x = 5799, y = 168, z = 6, label = "Get the sotashi parchment" }, { x = 5515, y = 239, z = 6, label = "Get the sotashi parchment" }, { x = 3748, y = 439, z = 9, label = "Get the sotashi parchment" }, { x = 5080, y = 603, z = 9, label = "Get the sotashi parchment" }, { x = 3251, y = 563, z = 5, label = "Get the sotashi parchment" }, { x = 5031, y = 484, z = 8, label = "Get the sotashi parchment" }, { x = 5032, y = 574, z = 9, label = "Get the sotashi parchment" } }, -- sotashi parchment
    [28054] = { { x = 5796, y = 168, z = 6, label = "Get the suspicious parchment" }, { x = 5799, y = 168, z = 6, label = "Get the suspicious parchment" }, { x = 5515, y = 239, z = 6, label = "Get the suspicious parchment" }, { x = 3748, y = 439, z = 9, label = "Get the suspicious parchment" }, { x = 5080, y = 603, z = 9, label = "Get the suspicious parchment" }, { x = 3251, y = 563, z = 5, label = "Get the suspicious parchment" }, { x = 5031, y = 484, z = 8, label = "Get the suspicious parchment" }, { x = 5032, y = 574, z = 9, label = "Get the suspicious parchment" } }, -- suspicious parchment
    [28055] = { { x = 3672, y = 415, z = 7, label = "Buy it from Owen" } }, -- tea
    [28056] = { { x = 5796, y = 168, z = 6, label = "Get the Nagumo's diary" }, { x = 5799, y = 168, z = 6, label = "Get the Nagumo's diary" }, { x = 5515, y = 239, z = 6, label = "Get the Nagumo's diary" }, { x = 3748, y = 439, z = 9, label = "Get the Nagumo's diary" }, { x = 5080, y = 603, z = 9, label = "Get the Nagumo's diary" }, { x = 3251, y = 563, z = 5, label = "Get the Nagumo's diary" }, { x = 5031, y = 484, z = 8, label = "Get the Nagumo's diary" }, { x = 5032, y = 574, z = 9, label = "Get the Nagumo's diary" } }, -- Nagumo's diary
    [28057] = { { x = 3310, y = 537, z = 7, label = "Buy it from Brian" } }, -- telescope
    [28142] = { { x = 5796, y = 168, z = 6, label = "Get the sea shell" }, { x = 5799, y = 168, z = 6, label = "Get the sea shell" }, { x = 5515, y = 239, z = 6, label = "Get the sea shell" }, { x = 3748, y = 439, z = 9, label = "Get the sea shell" }, { x = 5080, y = 603, z = 9, label = "Get the sea shell" }, { x = 3251, y = 563, z = 5, label = "Get the sea shell" }, { x = 5031, y = 484, z = 8, label = "Get the sea shell" }, { x = 5032, y = 574, z = 9, label = "Get the sea shell" } }, -- sea shell
    [28160] = { { x = 5796, y = 168, z = 6, label = "Get the Calico's diary" }, { x = 5799, y = 168, z = 6, label = "Get the Calico's diary" }, { x = 5515, y = 239, z = 6, label = "Get the Calico's diary" }, { x = 3748, y = 439, z = 9, label = "Get the Calico's diary" }, { x = 5080, y = 603, z = 9, label = "Get the Calico's diary" }, { x = 3251, y = 563, z = 5, label = "Get the Calico's diary" }, { x = 5031, y = 484, z = 8, label = "Get the Calico's diary" }, { x = 5032, y = 574, z = 9, label = "Get the Calico's diary" } }, -- Calico's diary
    [28161] = { { x = 5796, y = 168, z = 6, label = "Get the Javy Done's diary" }, { x = 5799, y = 168, z = 6, label = "Get the Javy Done's diary" }, { x = 5515, y = 239, z = 6, label = "Get the Javy Done's diary" }, { x = 3748, y = 439, z = 9, label = "Get the Javy Done's diary" }, { x = 5080, y = 603, z = 9, label = "Get the Javy Done's diary" }, { x = 3251, y = 563, z = 5, label = "Get the Javy Done's diary" }, { x = 5031, y = 484, z = 8, label = "Get the Javy Done's diary" }, { x = 5032, y = 574, z = 9, label = "Get the Javy Done's diary" } }, -- Javy Done's diary
    [28162] = { { x = 5796, y = 168, z = 6, label = "Get the Sotashi's diary" }, { x = 5799, y = 168, z = 6, label = "Get the Sotashi's diary" }, { x = 5515, y = 239, z = 6, label = "Get the Sotashi's diary" }, { x = 3748, y = 439, z = 9, label = "Get the Sotashi's diary" }, { x = 5080, y = 603, z = 9, label = "Get the Sotashi's diary" }, { x = 3251, y = 563, z = 5, label = "Get the Sotashi's diary" }, { x = 5031, y = 484, z = 8, label = "Get the Sotashi's diary" }, { x = 5032, y = 574, z = 9, label = "Get the Sotashi's diary" } }, -- Sotashi's diary
}
