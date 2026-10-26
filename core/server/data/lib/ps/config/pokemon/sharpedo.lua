POKEMON["Sharpedo"] = {
    pTypes = { ELEMENT_WATER, ELEMENT_DARK },
    dexStorage = 10319,
    atk = 120,
    def = 40,
    spAtk = 95,
    spDef = 40,
    energy = 100,
    chance = 450,
    portrait = 28469,
    dexPortrait = -1,
    fastcallPortrait = 27313,
    catchStorage = -1,
    evolutions = {  },
    description = "Its fangs rip through sheet iron. It swims at 75 mph and is known as “The Bully of the Sea.”",
    skills = { "Tackle", 1, "Bite", 5, "Aqua Jet", 10, "Assurance", 15, "Rage", 20, "Focus Energy", 25, "Night Slash", 35, "Crunch", 40, "Ice Fang", 45, "Poison Fang", 50, "Scary Face", 55, "Skull Bash", 60, "Scald", 65 },
    abilities = { "Surf", "Dive", "Waterfall", "Strenght", "Rock Smash" },
    eggGroup = { POKEMON_EGG_GROUP_WATER_2 },
    eggId = 28544,
    eggChance = 20,
    specialAbilities = { POKEMON_SPECIAL_ABILITY_IDS.ROUGH_SKIN },
    learnableTms = { TM_IDS.TOXIC, TM_IDS.ICE_BEAM, TM_IDS.BLIZZARD, TM_IDS.PROTECT, TM_IDS.RAIN_DANCE, TM_IDS.DOUBLE_TEAM, TM_IDS.REST, TM_IDS.SUBSTITUTE, TM_IDS.HYPER_BEAM, TM_IDS.EARTHQUAKE, TM_IDS.ROCK_TOMB, TM_IDS.POISON_JAB, TM_IDS.ROAR, TM_IDS.HAIL, TM_IDS.TAUNT },
    eggMoves = { "Ancient Power", "Brine", "Double-Edge", "Hydro Pump", "Psychic Fangs", "Swift", "Thrash" }
}

-- Mega form (097-megaEvolution.lua): only while Mega Evolved, never wild or caught
POKEMON["Mega Sharpedo"] = table.deepcopy(POKEMON["Sharpedo"])
POKEMON["Mega Sharpedo"].megaOf = "Sharpedo"
POKEMON["Mega Sharpedo"].pTypes = { ELEMENT_WATER, ELEMENT_DARK }
POKEMON["Mega Sharpedo"].atk = 140
POKEMON["Mega Sharpedo"].def = 70
POKEMON["Mega Sharpedo"].spAtk = 110
POKEMON["Mega Sharpedo"].spDef = 65
POKEMON["Mega Sharpedo"].specialAbilities = { POKEMON_SPECIAL_ABILITY_IDS.STRONG_JAW }
POKEMON["Mega Sharpedo"].portrait = 30314
POKEMON["Mega Sharpedo"].fastcallPortrait = 28957
POKEMON["Mega Sharpedo"].blockTransform = true
