POKEMON["Camerupt"] = {
    pTypes = { ELEMENT_FIRE, ELEMENT_GROUND },
    dexStorage = 10323,
    atk = 100,
    def = 70,
    spAtk = 105,
    spDef = 75,
    energy = 100,
    chance = 300,
    portrait = 28473,
    dexPortrait = -1,
    fastcallPortrait = 27317,
    catchStorage = -1,
    evolutions = {  },
    description = "The volcanoes on its back have a major eruption every 10 years--or whenever it becomes really angry.",
    skills = { "Tackle", 1, "Ember", 5, "Magnitude", 10, "Flame Burst", 15, "Flamethrower", 20, "Amnesia", 25, "Lava Plume", 35, "Rock Slide", 40, "Earth Power", 45, "Take Down", 50, "Earthquake", 55, "Eruption", 60, "Fissure", 65 },
    abilities = { "Strenght", "Rock Smash", "Ride" },
    eggGroup = { POKEMON_EGG_GROUP_FIELD },
    eggId = 28565,
    eggChance = 20,
    specialAbilities = { POKEMON_SPECIAL_ABILITY_IDS.MAGMA_ARMOR, POKEMON_SPECIAL_ABILITY_IDS.SOLID_ROCK },
    learnableTms = { TM_IDS.TOXIC, TM_IDS.PROTECT, TM_IDS.EARTHQUAKE, TM_IDS.DOUBLE_TEAM, TM_IDS.FLAMETHROWER, TM_IDS.FIRE_BLAST, TM_IDS.ROCK_TOMB, TM_IDS.REST, TM_IDS.ROCK_SLIDE, TM_IDS.SUBSTITUTE, TM_IDS.HYPER_BEAM, TM_IDS.SOLAR_BEAM, TM_IDS.REST, TM_IDS.EXPLOSION, TM_IDS.ROAR, TM_IDS.SANDSTORM, TM_IDS.OVERHEAT },
    eggMoves = { "Ancient Power", "Body Slam", "Defense Curl", "Endure", "Heat Wave", "Iron Head", "Mud Bomb", "Rollout", "Scary Face", "Stomp", "Yawn" }
}

-- Mega form (097-megaEvolution.lua): only while Mega Evolved, never wild or caught
POKEMON["Mega Camerupt"] = table.deepcopy(POKEMON["Camerupt"])
POKEMON["Mega Camerupt"].megaOf = "Camerupt"
POKEMON["Mega Camerupt"].pTypes = { ELEMENT_FIRE, ELEMENT_GROUND }
POKEMON["Mega Camerupt"].atk = 120
POKEMON["Mega Camerupt"].def = 100
POKEMON["Mega Camerupt"].spAtk = 145
POKEMON["Mega Camerupt"].spDef = 105
POKEMON["Mega Camerupt"].specialAbilities = { POKEMON_SPECIAL_ABILITY_IDS.SHEER_FORCE }
POKEMON["Mega Camerupt"].portrait = 30316
POKEMON["Mega Camerupt"].fastcallPortrait = 28959
POKEMON["Mega Camerupt"].blockTransform = true
