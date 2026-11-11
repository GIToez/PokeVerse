POKEMON["Butterfree"] = {
    pTypes = { ELEMENT_BUG, ELEMENT_FLYING },
    dexStorage = 10012,
    atk = 45,
    def = 50,
    spAtk = 90,
    spDef = 80,
    energy = 100,
    chance = 250,
    portrait = 12713,
    dexPortrait = 13513,
    fastcallPortrait = 10646,
    catchStorage = 16012,
    evolutions = {},
    description = "The wings are protected by rain-repellent dust. As a result, this POKEMON can fly about even in rain.",
    skills = { "Tackle", 1, "Gust", 1, "Confusion", 1, "Poison Powder", 13, "Stun Spore", 13, "Sleep Powder", 13, "Psybeam", 17, "Silver Wind", 19, "Supersonic", 23, "Safeguard", 25, "Whirlwind", 29, "Bug Buzz", 31, "Rage Powder", 35, "Captivate", 37, "Tailwind", 41, "Air Slash", 43, "Quiver Dance", 47 },
    abilities = { "Flash" },
    eggGroup = { POKEMON_EGG_GROUP_BUG },
    eggId = 13981,
    eggChance = 20,
    specialAbilities = { POKEMON_SPECIAL_ABILITY_IDS.COMPOUNDEYES },
    learnableTms = { TM_IDS.SOFTBOILED, TM_IDS.ENERGY_BALL, TM_IDS.AERIAL_ACE, TM_IDS.NIGHTMARE, TM_IDS.SHADOW_BALL, TM_IDS.GIGA_DRAIN, TM_IDS.RAIN_DANCE, TM_IDS.DREAM_EATER, TM_IDS.RAZOR_WIND, TM_IDS.WHIRLWIND, TM_IDS.TOXIC, TM_IDS.TAKE_DOWN, TM_IDS.DOUBLE_EDGE, TM_IDS.HYPER_BEAM, TM_IDS.RAGE, TM_IDS.MEGA_DRAIN, TM_IDS.SOLAR_BEAM, TM_IDS.PSYCHIC, TM_IDS.MIMIC, TM_IDS.DOUBLE_TEAM, TM_IDS.REFLECT, TM_IDS.BIDE, TM_IDS.SWIFT, TM_IDS.REST, TM_IDS.PSYWAVE, TM_IDS.SUBSTITUTE, TM_IDS.SAFEGUARD }
}

POKEMON["RC Butterfree"] = table.deepcopy(POKEMON["Butterfree"])
POKEMON["RC Butterfree"].pTypes = { ELEMENT_POISON, ELEMENT_NORMAL }
POKEMON["RC Butterfree"].blockTransform = true