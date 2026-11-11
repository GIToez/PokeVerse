POKEMON["Haunter"] = {
    pTypes = { ELEMENT_GHOST, ELEMENT_POISON },
    dexStorage = 10093,
    atk = 50,
    def = 45,
    spAtk = 115,
    spDef = 55,
    energy = 100,
    chance = 400,
    portrait = 12794,
    dexPortrait = 13594,
    fastcallPortrait = 10727,
    catchStorage = 16093,
    evolutions = { { name = "Gengar", requiredLevel = 55 } },
    description = "If you get the feeling of being watched in darkness when nobody is around, HAUNTER is there.",
    skills = { "Tackle", 1, "Shadow Punch", 1, "Hypnosis", 1, "Lick", 1, "Spite", 1, "Curse", 12, "Night Shade", 15, "Confuse Ray", 19, "Sucker Punch", 22, "Payback", 28, "Shadow Ball", 33, "Dream Eater", 39, "Dark Pulse", 44, "Destiny Bond", 50, "Hex", 55, "Nightmare", 61 },
    abilities = {},
    eggGroup = { POKEMON_EGG_GROUP_AMORPHOUS },
    eggId = 14017,
    eggChance = 20,
    specialAbilities = { POKEMON_SPECIAL_ABILITY_IDS.LEVITATE },
    learnableTms = { TM_IDS.POISON_JAB, TM_IDS.ENERGY_BALL, TM_IDS.NIGHTMARE, TM_IDS.SLUDGE_BOMB, TM_IDS.SHADOW_BALL, TM_IDS.GIGA_DRAIN, TM_IDS.RAIN_DANCE, TM_IDS.ZAP_CANNON, TM_IDS.TOXIC, TM_IDS.RAGE, TM_IDS.MEGA_DRAIN, TM_IDS.THUNDERBOLT, TM_IDS.THUNDER, TM_IDS.PSYCHIC, TM_IDS.MIMIC, TM_IDS.DOUBLE_TEAM, TM_IDS.BIDE, TM_IDS.SELFDESTRUCT, TM_IDS.DREAM_EATER, TM_IDS.REST, TM_IDS.PSYWAVE, TM_IDS.EXPLOSION, TM_IDS.SUBSTITUTE, TM_IDS.TAUNT },
    eggMoves = { "Astonish", "Clear Smog", "Disable", "Fire Punch", "Grudge", "Haze", "Ice Punch", "Perish Song", "Psywave", "Reflect Type", "Scary Face", "Smog", "Thunder Punch" }
}

POKEMON["RC Haunter"] = table.deepcopy(POKEMON["Haunter"])
POKEMON["RC Haunter"].pTypes = { ELEMENT_POISON, ELEMENT_NORMAL }
POKEMON["RC Haunter"].blockTransform = true

POKEMON["Scary Haunter"] = table.deepcopy(POKEMON["Haunter"])