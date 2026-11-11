POKEMON["Tangela"] = {
    pTypes = { ELEMENT_GRASS },
    dexStorage = 10114,
    atk = 55,
    def = 115,
    spAtk = 100,
    spDef = 40,
    energy = 100,
    chance = 400,
    portrait = 12815,
    dexPortrait = 13615,
    fastcallPortrait = 10748,
    catchStorage = 16114,
    evolutions = { { name = "Tangrowth", requiredLevel = 40 } },
    description = "Blue plant vines cloak the POKEMON's identity in a tangled mass. It entangles anything that gets close.",
    skills = { "Tackle", 1, "Ingrain", 1, "Constrict", 1, "Sleep Powder", 4, "Vine Whip", 7, "Absorb", 10, "Poison Powder", 14, "Mega Drain", 23, "Knock Off", 27, "Stun Spore", 30, "Giga Drain", 36, "Ancient Power", 38, "Slam", 41, "Tickle", 44, "Wring Out", 46, "Grassy Terrain", 48, "Power Whip", 50 },
    abilities = { "Cut", "Headbutt" },
    eggGroup = { POKEMON_EGG_GROUP_GRASS },
    eggId = 14030,
    eggChance = 10,
    specialAbilities = { POKEMON_SPECIAL_ABILITY_IDS.CHLOROPHYLL, POKEMON_SPECIAL_ABILITY_IDS.LEAF_GUARD },
    learnableTms = { TM_IDS.SOFTBOILED, TM_IDS.ENERGY_BALL, TM_IDS.SLUDGE_BOMB, TM_IDS.GIGA_DRAIN, TM_IDS.HEADBUTT, TM_IDS.REFLECT, TM_IDS.SWORDS_DANCCE, TM_IDS.TOXIC, TM_IDS.BODY_SLAM, TM_IDS.TAKE_DOWN, TM_IDS.DOUBLE_EDGE, TM_IDS.HYPER_BEAM, TM_IDS.RAGE, TM_IDS.MEGA_DRAIN, TM_IDS.SOLAR_BEAM, TM_IDS.MIMIC, TM_IDS.DOUBLE_TEAM, TM_IDS.BIDE, TM_IDS.SKULL_BASH, TM_IDS.REST, TM_IDS.SUBSTITUTE, TM_IDS.BULLET_SEED, TM_IDS.SHOCK_WAVE },
    eggMoves = { "Amnesia", "Confusion", "Endeavor", "Flail", "Giga Drain", "Leaf Storm", "Leech Seed", "Mega Drain", "Natural Gift", "Nature Power", "Power Swap", "Rage Powder" }
}

POKEMON["RC Tangela"] = table.deepcopy(POKEMON["Tangela"])
POKEMON["RC Tangela"].pTypes = { ELEMENT_POISON, ELEMENT_NORMAL }
POKEMON["RC Tangela"].blockTransform = true