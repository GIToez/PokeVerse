POKEMON["Jolteon"] = {
    pTypes = { ELEMENT_ELECTRIC },
    dexStorage = 10135,
    atk = 65,
    def = 60,
    spAtk = 110,
    spDef = 95,
    energy = 100,
    chance = 500,
    portrait = 12836,
    dexPortrait = 13636,
    fastcallPortrait = 10769,
    catchStorage = 16135,
    evolutions = {},
    description = "If it is angered or startled, the fur all over its body bristles like sharp needles that pierce foes.",
    skills = { "Tackle", 1, "Thunder Shock", 1, "Sand-Attack", 5, "Quick Attack", 13, "Double Kick", 17, "Thunder Fang", 20, "Pin Missile", 25, "Agility", 29, "Thunder Wave", 33, "Discharge", 37, "Last Resort", 41, "Thunder", 45 },
    abilities = { POKEMON_ABILITIES.DIG, POKEMON_ABILITIES.STRENGTH, "Find", "Flash", "Headbutt" },
    eggGroup = { POKEMON_EGG_GROUP_FIELD },
    eggId = 14044,
    eggChance = 1,
    specialAbilities = { POKEMON_SPECIAL_ABILITY_IDS.VOLT_ABSORB },
    learnableTms = { TM_IDS.SOFTBOILED, TM_IDS.MUD_SLAP, TM_IDS.SHADOW_BALL, TM_IDS.IRON_TAIL, TM_IDS.RAIN_DANCE, TM_IDS.ZAP_CANNON, TM_IDS.HEADBUTT, TM_IDS.TOXIC, TM_IDS.BODY_SLAM, TM_IDS.TAKE_DOWN, TM_IDS.DOUBLE_EDGE, TM_IDS.HYPER_BEAM, TM_IDS.RAGE, TM_IDS.THUNDERBOLT, TM_IDS.THUNDER, TM_IDS.MIMIC, TM_IDS.DOUBLE_TEAM, TM_IDS.REFLECT, TM_IDS.BIDE, TM_IDS.SWIFT, TM_IDS.SKULL_BASH, TM_IDS.REST, TM_IDS.THUNDER_WAVE, TM_IDS.SUBSTITUTE, TM_IDS.ROAR, TM_IDS.LIGHT_SCREEN, TM_IDS.SHOCK_WAVE },
    eggMoves = { "Captivate", "Charm", "Covet", "Curse", "Detect", "Endure", "Fake Tears", "Flail", "Natural Gift", "Stored Power", "Synchronoise", "Tickle", "Wish", "Yawn" }
}

POKEMON["RC Jolteon"] = table.deepcopy(POKEMON["Jolteon"])
POKEMON["RC Jolteon"].pTypes = { ELEMENT_POISON, ELEMENT_NORMAL }
POKEMON["RC Jolteon"].blockTransform = true