POKEMON["Voltorb"] = {
    pTypes = { ELEMENT_ELECTRIC },
    dexStorage = 10100,
    atk = 30,
    def = 50,
    spAtk = 55,
    spDef = 55,
    energy = 100,
    chance = 40,
    portrait = 12801,
    dexPortrait = 13601,
    fastcallPortrait = 10734,
    catchStorage = 16100,
    evolutions = { { name = "Electrode", requiredLevel = 30 } },
    description = "A life-form whose identity is unknown. It is said to SCREECH or suddenly SELFDESTRUCT.",
    skills = { "Tackle", 1, "Charge", 1, "Sonic Boom", 4, "Eerie Impulse", 6, "Spark", 9, "Rollout", 11, "Screech", 13, "Charge Beam", 16, "Swift", 20, "Electro Ball", 22, "Selfdestruct", 26, "Light Screen", 29, "Magnet Rise", 34, "Discharge", 37, "Explosion", 41, "Gyro Ball", 46, "Mirror Coat", 48 },
    abilities = { "Flash", "Headbutt" },
    eggGroup = { POKEMON_EGG_GROUP_MINERAL },
    eggId = 14021,
    eggChance = 20,
    specialAbilities = { POKEMON_SPECIAL_ABILITY_IDS.SOUNDPROOF, POKEMON_SPECIAL_ABILITY_IDS.STATIC },
    learnableTms = { TM_IDS.RAIN_DANCE, TM_IDS.ZAP_CANNON, TM_IDS.HEADBUTT, TM_IDS.TOXIC, TM_IDS.TAKE_DOWN, TM_IDS.RAGE, TM_IDS.THUNDERBOLT, TM_IDS.THUNDER, TM_IDS.MIMIC, TM_IDS.DOUBLE_TEAM, TM_IDS.REFLECT, TM_IDS.BIDE, TM_IDS.SELFDESTRUCT, TM_IDS.SWIFT, TM_IDS.REST, TM_IDS.THUNDER_WAVE, TM_IDS.EXPLOSION, TM_IDS.SUBSTITUTE, TM_IDS.TAUNT, TM_IDS.LIGHT_SCREEN, TM_IDS.SHOCK_WAVE }
}

POKEMON["Unstable Voltorb"] = table.deepcopy(POKEMON["Voltorb"])

POKEMON["Rocket's Voltorb"] = table.deepcopy(POKEMON["Voltorb"])