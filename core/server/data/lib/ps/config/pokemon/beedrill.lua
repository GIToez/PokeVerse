POKEMON["Beedrill"] = {
    pTypes = { ELEMENT_BUG, ELEMENT_POISON },
    dexStorage = 10015,
    atk = 90,
    def = 40,
    spAtk = 45,
    spDef = 80,
    energy = 100,
    chance = 250,
    portrait = 12716,
    dexPortrait = 13516,
    fastcallPortrait = 10649,
    catchStorage = 16015,
    evolutions = {},
    description = "May appear in a swarm. Flies at violent speeds, all the while stabbing with the toxic stinger on its rear.",
    skills = { "Tackle", 1, "Twineedle", 1, "Harden", 1, "Poison Sting", 1, "Fury Attack", 1, "String Shot", 1, "Bug Bite", 9, "Rage", 14, "Pursuit", 17, "Focus Energy", 20, "Venoshock", 23, "Assurance", 26, "Toxic Spikes", 29, "Pin Missile", 32, "Poison Jab", 35, "Agility", 38, "Endeavor", 41, "Fell Stinger", 44 },
    abilities = { "Find", "Cut" },
    eggGroup = { POKEMON_EGG_GROUP_BUG },
    eggId = 13982,
    eggChance = 20,
    specialAbilities = { POKEMON_SPECIAL_ABILITY_IDS.SWARM },
    learnableTms = { TM_IDS.SOFTBOILED, TM_IDS.POISON_JAB, TM_IDS.AERIAL_ACE, TM_IDS.FURY_CUTTER, TM_IDS.SLUDGE_BOMB, TM_IDS.SWORDS_DANCE, TM_IDS.TOXIC, TM_IDS.TAKE_DOWN, TM_IDS.DOUBLE_EDGE, TM_IDS.HYPER_BEAM, TM_IDS.RAGE, TM_IDS.MEGA_DRAIN, TM_IDS.MIMIC, TM_IDS.DOUBLE_TEAM, TM_IDS.REFLECT, TM_IDS.BIDE, TM_IDS.SWIFT, TM_IDS.SKULL_BASH, TM_IDS.REST, TM_IDS.SUBSTITUTE, TM_IDS.BRICK_BREAK }
}

POKEMON["RC Beedrill"] = table.deepcopy(POKEMON["Beedrill"])
POKEMON["RC Beedrill"].pTypes = { ELEMENT_POISON, ELEMENT_NORMAL }
POKEMON["RC Beedrill"].blockTransform = true

-- Mega form (097-megaEvolution.lua): only while Mega Evolved, never wild or caught
POKEMON["Mega Beedrill"] = table.deepcopy(POKEMON["Beedrill"])
POKEMON["Mega Beedrill"].megaOf = "Beedrill"
POKEMON["Mega Beedrill"].pTypes = { ELEMENT_BUG, ELEMENT_POISON }
POKEMON["Mega Beedrill"].atk = 150
POKEMON["Mega Beedrill"].def = 40
POKEMON["Mega Beedrill"].spAtk = 15
POKEMON["Mega Beedrill"].spDef = 80
POKEMON["Mega Beedrill"].specialAbilities = { POKEMON_SPECIAL_ABILITY_IDS.ADAPTABILITY }
POKEMON["Mega Beedrill"].portrait = 30280
POKEMON["Mega Beedrill"].fastcallPortrait = 28923
POKEMON["Mega Beedrill"].blockTransform = true
