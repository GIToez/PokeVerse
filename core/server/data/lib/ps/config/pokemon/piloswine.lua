POKEMON["Piloswine"] = {
    pTypes = { ELEMENT_ICE, ELEMENT_GROUND },
    dexStorage = 10221,
    atk = 100,
    def = 80,
    spAtk = 60,
    spDef = 60,
    energy = 100,
    chance = 700,
    portrait = 17510,
    dexPortrait = 15868,
    fastcallPortrait = 16068,
    catchStorage = 16221,
    evolutions = { { name = "Mamoswine", requiredLevel = 60 } },
    description = "If it charges at an enemy, the hairs on its back stand up straight. It is very sensitive to sound.",
    skills = { "Tackle", 1, "Fury Attack", 1, "Ancient Power", 1, "Peck", 1, "Mud Sport", 1, "Powder Snow", 1, "Mud-Slap", 11, "Endure", 14, "Mud Bomb", 18, "Icy Wind", 21, "Ice Fang", 24, "Ice Shard", 24, "Take Down", 28, "Mist", 37, "Flail", 40, "Thrash", 41, "Earthquake", 46, "Blizzard", 52, "Amnesia", 58 },
    abilities = { POKEMON_ABILITIES.DIG, POKEMON_ABILITIES.STRENGTH, "Rock Smash", "Ride", "Headbutt" },
    eggGroup = { POKEMON_EGG_GROUP_FIELD },
    eggId = 17773,
    eggChance = 20,
    specialAbilities = { POKEMON_SPECIAL_ABILITY_IDS.OBLIVIOUS, POKEMON_SPECIAL_ABILITY_IDS.SNOW_CLOAK },
    learnableTms = { TM_IDS.AVALANCHE, TM_IDS.ROCK_TOMB, TM_IDS.DEFENSE_CURL, TM_IDS.MUD_SLAP, TM_IDS.RAIN_DANCE, TM_IDS.ICY_WIND, TM_IDS.HEADBUTT, TM_IDS.BLIZZARD, TM_IDS.ROCK_SLIDE, TM_IDS.REFLECT, TM_IDS.TOXIC, TM_IDS.DOUBLE_EDGE, TM_IDS.ICE_BEAM, TM_IDS.HYPER_BEAM, TM_IDS.RAGE, TM_IDS.EARTHQUAKE, TM_IDS.MIMIC, TM_IDS.DOUBLE_TEAM, TM_IDS.REST, TM_IDS.BIDE, TM_IDS.SUBSTITUTE, TM_IDS.ROAR, TM_IDS.HAIL, TM_IDS.LIGHT_SCREEN, TM_IDS.SANDSTORM },
    eggMoves = { "Ancient Power", "Avalanche", "Bite", "Body Slam", "Curse", "Double-Edge", "Fissure", "Freeze-Dry", "Icicle Crash", "Icicle Spear", "Mud Shot", "Stealth Rock", "Take Down" }
}

POKEMON["Cloned Piloswine"] = table.deepcopy(POKEMON["Piloswine"])
POKEMON["Cloned Piloswine"].blockTransform = true