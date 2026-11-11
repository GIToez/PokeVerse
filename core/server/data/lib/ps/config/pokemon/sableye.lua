POKEMON["Sableye"] = {
    pTypes = { ELEMENT_DARK, ELEMENT_GHOST },
    dexStorage = 10302,
    atk = 75,
    def = 75,
    spAtk = 65,
    spDef = 65,
    energy = 100,
    chance = 400,
    portrait = -1,
    dexPortrait = -1,
    fastcallPortrait = 27295,
    catchStorage = -1,
    evolutions = {  },
    description = "It hides in the darkness of caves. Its diet of gems has transformed its eyes into gemstones.",
    skills = { "Tackle", 1, "Scratch", 1, "Foresight", 4, "Night Shade", 6, "Astonish", 9, "Fury Swipes", 11, "Detect", 14, "Shadow Sneak", 16, "Faint Attack", 19, "Fake Out", 21, "Punishment", 24, "Knock Off", 26, "Shadow Claw", 29, "Confuse Ray", 31, "Zen Headbutt", 34, "Power Gem", 36, "Shadow Ball", 39, "Foul Play", 41 },
    abilities = { "Cut", "Rock Smash", "Flash" },
    eggGroup = { POKEMON_EGG_GROUP_HUMAN_LIKE },
    eggId = 28571,
    eggChance = 20,
    specialAbilities = { POKEMON_SPECIAL_ABILITY_IDS.KEEN_EYE, POKEMON_SPECIAL_ABILITY_IDS.STALL },
    learnableTms = { TM_IDS.TOXIC, TM_IDS.PROTECT, TM_IDS.RAIN_DANCE, TM_IDS.PSYCHIC, TM_IDS.SHADOW_BALL, TM_IDS.DOUBLE_TEAM, TM_IDS.ROCK_TOMB, TM_IDS.AERIAL_ACE, TM_IDS.REST, TM_IDS.POISON_JAB, TM_IDS.DREAM_EATER, TM_IDS.SUBSTITUTE, TM_IDS.FOCUS_PUNCH, TM_IDS.CALM_MIND, TM_IDS.TAUNT, TM_IDS.BRICK_BREAK, TM_IDS.SHOCK_WAVE },
    eggMoves = { "Metal Burst", "Nasty Plot", "Recover", "Sucker Punch" }
}

-- Mega form (097-megaEvolution.lua): only while Mega Evolved, never wild or caught
POKEMON["Mega Sableye"] = table.deepcopy(POKEMON["Sableye"])
POKEMON["Mega Sableye"].megaOf = "Sableye"
POKEMON["Mega Sableye"].pTypes = { ELEMENT_DARK, ELEMENT_GHOST }
POKEMON["Mega Sableye"].atk = 85
POKEMON["Mega Sableye"].def = 125
POKEMON["Mega Sableye"].spAtk = 85
POKEMON["Mega Sableye"].spDef = 115
POKEMON["Mega Sableye"].specialAbilities = { POKEMON_SPECIAL_ABILITY_IDS.MAGIC_BOUNCE }
POKEMON["Mega Sableye"].portrait = 30310
POKEMON["Mega Sableye"].fastcallPortrait = 28953
POKEMON["Mega Sableye"].blockTransform = true
