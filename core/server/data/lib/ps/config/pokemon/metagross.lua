POKEMON["Metagross"] = {
    pTypes = { ELEMENT_STEEL, ELEMENT_PSYCHIC },
    dexStorage = 10376,
    atk = 135,
    def = 130,
    spAtk = 95,
    spDef = 90,
    energy = 100,
    chance = 1000,
    portrait = 28525,
    dexPortrait = -1,
    fastcallPortrait = 27369,
    catchStorage = -1,
    evolutions = {  },
    description = "With four linked brains, it's more intelligent than a supercomputer, and it uses calculations to analyze foes.",
    skills = { "Tackle", 1, "Confusion", 5, "Metal Claw", 10, "Take Down", 15, "Pursuit", 20, "Iron Defense", 25, "Psychic", 35, "Zen Headbutt", 40, "Bullet Punch", 45, "Hammer Arm", 55, "Hyper Beam", 60, "Agility", 65, "Meteor Mash", 70, "Scary Face", 75 },
    abilities = { "Cut", "Strenght", "Flash", "Rock Smash", "Ride", POKEMON_ABILITIES.BLINK, POKEMON_ABILITIES.TELEPORT },
    eggGroup = { POKEMON_EGG_GROUP_MINERAL },
    eggId = 28542,
    eggChance = 20,
    specialAbilities = { POKEMON_SPECIAL_ABILITY_IDS.CLEAR_BODY },
    learnableTms = { TM_IDS.TOXIC, TM_IDS.HYPER_BEAM, TM_IDS.PROTECT, TM_IDS.RAIN_DANCE, TM_IDS.EARTHQUAKE, TM_IDS.PSYCHIC, TM_IDS.SHADOW_BALL, TM_IDS.DOUBLE_TEAM, TM_IDS.REFLECT, TM_IDS.SLUDGE_BOMB, TM_IDS.ROCK_TOMB, TM_IDS.AERIAL_ACE, TM_IDS.REST, TM_IDS.EXPLOSION, TM_IDS.ROCK_SLIDE, TM_IDS.SUBSTITUTE, TM_IDS.LIGHT_SCREEN, TM_IDS.BRICK_BREAK, TM_IDS.SANDSTORM },
    eggMoves = { --[[ TODO ]] }
}

-- Mega form (097-megaEvolution.lua): only while Mega Evolved, never wild or caught
POKEMON["Mega Metagross"] = table.deepcopy(POKEMON["Metagross"])
POKEMON["Mega Metagross"].megaOf = "Metagross"
POKEMON["Mega Metagross"].pTypes = { ELEMENT_STEEL, ELEMENT_PSYCHIC }
POKEMON["Mega Metagross"].atk = 145
POKEMON["Mega Metagross"].def = 150
POKEMON["Mega Metagross"].spAtk = 105
POKEMON["Mega Metagross"].spDef = 110
POKEMON["Mega Metagross"].specialAbilities = { POKEMON_SPECIAL_ABILITY_IDS.TOUGH_CLAWS }
POKEMON["Mega Metagross"].portrait = 30336
POKEMON["Mega Metagross"].fastcallPortrait = 28979
POKEMON["Mega Metagross"].blockTransform = true
