POKEMON["Seaking"] = {
    pTypes = { ELEMENT_WATER },
    dexStorage = 10119,
    atk = 92,
    def = 65,
    spAtk = 65,
    spDef = 80,
    energy = 100,
    chance = 250,
    portrait = 12820,
    dexPortrait = 13620,
    fastcallPortrait = 10753,
    catchStorage = 16119,
    evolutions = {},
    description = "The horn on its head is sharp like a drill. It bores a hole in a boulder to make its nest.",
    skills = { "Tackle", 1, "Megahorn", 1, "Poison Jab", 1, "Peck", 1, "Water Sport", 1, "Supersonic", 1, "Horn Attack", 8, "Flail", 13, "Water Pulse", 16, "Aqua Ring", 21, "Fury Attack", 24, "Agility", 29, "Waterfall", 32, "Horn Drill", 40 },
    abilities = { POKEMON_ABILITIES.WATERFALL, "Surf", "Dive" },
    eggGroup = { POKEMON_EGG_GROUP_WATER_2 },
    eggId = 14033,
    eggChance = 20,
    specialAbilities = { POKEMON_SPECIAL_ABILITY_IDS.SWIFT_SWIM, POKEMON_SPECIAL_ABILITY_IDS.WATER_VEIL },
    learnableTms = { TM_IDS.POISON_JAB, TM_IDS.WATER_PULSE, TM_IDS.RAIN_DANCE, TM_IDS.ICY_WIND, TM_IDS.TOXIC, TM_IDS.TAKE_DOWN, TM_IDS.DOUBLE_EDGE, TM_IDS.BUBBLEBEAM, TM_IDS.WATER_GUN, TM_IDS.ICE_BEAM, TM_IDS.BLIZZARD, TM_IDS.HYPER_BEAM, TM_IDS.RAGE, TM_IDS.MIMIC, TM_IDS.DOUBLE_TEAM, TM_IDS.BIDE, TM_IDS.SWIFT, TM_IDS.SKULL_BASH, TM_IDS.REST, TM_IDS.SUBSTITUTE, TM_IDS.HAIL },
    eggMoves = { "Aqua Tail", "Body Slam", "Haze", "Hydro Pump", "Mud Shot", "Mud Sport", "Mud-Slap", "Psybeam", "Signal Beam", "Skull Bash", "Sleep Talk" }
}

POKEMON["Oily Seaking"] = table.deepcopy(POKEMON["Seaking"])
POKEMON["Oily Seaking"].pTypes = { ELEMENT_POISON, ELEMENT_NORMAL }
POKEMON["Oily Seaking"].blockTransform = true