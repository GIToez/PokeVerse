POKEMON["Seel"] = {
    pTypes = { ELEMENT_WATER },
    dexStorage = 10086,
    atk = 45,
    def = 55,
    spAtk = 45,
    spDef = 70,
    energy = 100,
    chance = 70,
    portrait = 12787,
    dexPortrait = 13587,
    fastcallPortrait = 10720,
    catchStorage = 16086,
    evolutions = { { name = "Dewgong", requiredLevel = 34 } },
    description = "Covered with light blue fur, its hide is thick and tough. It is active in bitter cold of minus 40 degrees Fahrenheit.",
    skills = { "Tackle", 1, "Headbutt", 1, "Growl", 3, "Water Sport", 7, "Icy Wind", 11, "Encore", 13, "Ice Shard", 17, "Rest", 21, "Aqua Ring", 23, "Aurora Beam", 27, "Aqua Jet", 31, "Brine", 33, "Take Down", 37, "Dive", 41, "Aqua Tail", 43, "Ice Beam", 47, "Safeguard", 51, "Hail", 53 },
    abilities = { POKEMON_ABILITIES.STRENGTH, POKEMON_ABILITIES.WATERFALL, "Headbutt", "Rock Smash" },
    eggGroup = { POKEMON_EGG_GROUP_WATER_1, POKEMON_EGG_GROUP_FIELD },
    eggId = 14014,
    eggChance = 20,
    specialAbilities = { POKEMON_SPECIAL_ABILITY_IDS.THICK_FAT, POKEMON_SPECIAL_ABILITY_IDS.HYDRATION },
    learnableTms = { TM_IDS.WATER_PULSE, TM_IDS.RAIN_DANCE, TM_IDS.ICY_WIND, TM_IDS.HEADBUTT, TM_IDS.TOXIC, TM_IDS.HORN_DRILL, TM_IDS.BODY_SLAM, TM_IDS.TAKE_DOWN, TM_IDS.DOUBLE_EDGE, TM_IDS.BUBBLEBEAM, TM_IDS.WATER_GUN, TM_IDS.ICE_BEAM, TM_IDS.BLIZZARD, TM_IDS.PAY_DAY, TM_IDS.RAGE, TM_IDS.MIMIC, TM_IDS.DOUBLE_TEAM, TM_IDS.BIDE, TM_IDS.SKULL_BASH, TM_IDS.REST, TM_IDS.SUBSTITUTE, TM_IDS.HAIL, TM_IDS.SAFEGUARD },
    eggMoves = { "Belch", "Disable", "Encore", "Entrainment", "Fake Out", "Horn Drill", "Icicle Spear", "Iron Tail", "Lick", "Perish Song", "Signal Beam", "Slam", "Sleep Talk", --[["Spit Up", "Stockpile", "Swallow",]] "Water Pulse" }
}

POKEMON["RC Seel"] = table.deepcopy(POKEMON["Seel"])
POKEMON["RC Seel"].pTypes = { ELEMENT_POISON, ELEMENT_NORMAL }
POKEMON["RC Seel"].blockTransform = true

POKEMON["Christmas Seel"] = table.deepcopy(POKEMON["Seel"])
POKEMON["Christmas Seel"].blockTransform = true
POKEMON["Christmas Seel"].evolutions = {}
POKEMON["Christmas Seel"].ignoreBallCounter = true
