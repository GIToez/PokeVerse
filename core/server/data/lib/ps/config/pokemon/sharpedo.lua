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
    skills = { "Tackle", 1, "Slash", 1, "Night Slash", 1, "Feint", 1, "Bite", 1, "Rage", 1, "Focus Energy", 1, "Aqua Jet", 11, "Assurance", 15, "Screech", 18, "Ice Fang", 25, "Scary Face", 29, "Poison Fang", 34, "Crunch", 40, "Agility", 45, "Skull Bash", 51 },
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
