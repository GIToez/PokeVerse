POKEMON["Pinsir"] = {
    pTypes = { ELEMENT_BUG },
    dexStorage = 10127,
    atk = 125,
    def = 100,
    spAtk = 55,
    spDef = 70,
    energy = 100,
    chance = 400,
    portrait = 12828,
    dexPortrait = 13628,
    fastcallPortrait = 10761,
    catchStorage = 16127,
    evolutions = {},
    description = "Its two long pincer horns are powerful. Once they grip an enemy, they won't release until the foe is torn.",
    skills = { "Tackle", 1, "Vice Grip", 1, "Focus Energy", 1, "Seismic Toss", 8, "Harden", 11, "Revenge", 15, "Vital Throw", 18, "Double Hit", 22, "Brick Break", 26, "X-Scissor", 29, "Submission", 33, "Swords Dance", 40, "Thrash", 43, "Superpower", 47, "Guillotine", 50 },
    abilities = { POKEMON_ABILITIES.DIG, POKEMON_ABILITIES.ROCK_CLIMB, POKEMON_ABILITIES.STRENGTH, "Headbutt", "Cut", "Rock Smash" },
    eggGroup = { POKEMON_EGG_GROUP_BUG },
    eggId = 14040,
    eggChance = 20,
    specialAbilities = { POKEMON_SPECIAL_ABILITY_IDS.HYPER_CUTTER --[[, POKEMON_SPECIAL_ABILITY_IDS.MOLD_BREAKER]] },
    learnableTms = { TM_IDS.ROCK_TOMB, TM_IDS.FURY_CUTTER, TM_IDS.RAIN_DANCE, TM_IDS.HEADBUTT, TM_IDS.ROCK_SLIDE, TM_IDS.EARTHQUAKE, TM_IDS.SWORDS_DANCE, TM_IDS.TOXIC, TM_IDS.BODY_SLAM, TM_IDS.TAKE_DOWN, TM_IDS.DOUBLE_EDGE, TM_IDS.HYPER_BEAM, TM_IDS.SUBMISSION, TM_IDS.SEISMIC_TOSS, TM_IDS.RAGE, TM_IDS.MIMIC, TM_IDS.DOUBLE_TEAM, TM_IDS.BIDE, TM_IDS.REST, TM_IDS.SUBSTITUTE, TM_IDS.FOCUS_PUNCH, TM_IDS.BULK_UP, TM_IDS.BRICK_BREAK },
    eggMoves = { "Bug Bite", "Close Combat", "Feint", "Faint Attack", "Flail", "Fury Attack", "Me First", "Quick Attack", "Superpower" }
}

POKEMON["Cloned Pinsir"] = table.deepcopy(POKEMON["Pinsir"])
POKEMON["Cloned Pinsir"].blockTransform = true