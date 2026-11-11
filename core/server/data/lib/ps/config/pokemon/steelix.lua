POKEMON["Steelix"] = {
    pTypes = { ELEMENT_STEEL, ELEMENT_GROUND },
    dexStorage = 10208,
    atk = 85,
    def = 200,
    spAtk = 55,
    spDef = 65,
    energy = 100,
    chance = 2000,
    portrait = 17497,
    dexPortrait = 15855,
    fastcallPortrait = 16055,
    catchStorage = 16208,
    evolutions = {},
    description = "It is said that if an ONIX lives for over 100 years, its composition changes to become diamond-like.",
    skills = { "Tackle", 1, "Thunder Fang", 1, "Ice Fang", 1, "Fire Fang", 1, "Mud Sport", 1, "Harden", 1, "Curse", 4, "Rock Throw", 7, "Rock Tomb", 10, "Rage", 13, "Stealth Rock", 16, "Gyro Ball", 20, "Smack Down", 22, "Dragon Breath", 25, "Slam", 28, "Screech", 31, "Rock Slide", 34, "Crunch", 37, "Sand Tomb", 37, "Iron Tail", 40, "Dig", 43, "Stone Edge", 46, "Double-Edge", 49, "Sandstorm", 52 },
    abilities = { POKEMON_ABILITIES.DIG, POKEMON_ABILITIES.ROCK_CLIMB, POKEMON_ABILITIES.STRENGTH, "Cut", "Rock Smash", "Ride", "Headbutt" },
    eggGroup = { POKEMON_EGG_GROUP_MINERAL },
    eggId = 14018,
    eggChance = 20,
    specialAbilities = { POKEMON_SPECIAL_ABILITY_IDS.ROCK_HEAD, POKEMON_SPECIAL_ABILITY_IDS.STURDY },
    learnableTms = { TM_IDS.SOFTBOILED, TM_IDS.ROCK_TOMB, TM_IDS.DEFENSE_CURL, TM_IDS.MUD_SLAP, TM_IDS.IRON_TAIL, TM_IDS.HEADBUTT, TM_IDS.ROCK_SLIDE, TM_IDS.EXPLOSION, TM_IDS.TOXIC, TM_IDS.DOUBLE_EDGE, TM_IDS.HYPER_BEAM, TM_IDS.RAGE, TM_IDS.EARTHQUAKE, TM_IDS.MIMIC, TM_IDS.DOUBLE_TEAM, TM_IDS.REST, TM_IDS.BIDE, TM_IDS.SUBSTITUTE, TM_IDS.ROAR, TM_IDS.TAUNT, TM_IDS.SANDSTORM},
    eggMoves = { "Block", "Defense Curl", "Flail", "Heavy Slam", "Rock Blast", "Rock Climb", "Rollout", "Rototiller", "Stealth Rock" }
}

POKEMON["Cloned Steelix"] = table.deepcopy(POKEMON["Steelix"])
POKEMON["Cloned Steelix"].blockTransform = true

-- Mega form (097-megaEvolution.lua): only while Mega Evolved, never wild or caught
POKEMON["Mega Steelix"] = table.deepcopy(POKEMON["Steelix"])
POKEMON["Mega Steelix"].megaOf = "Steelix"
POKEMON["Mega Steelix"].pTypes = { ELEMENT_STEEL, ELEMENT_GROUND }
POKEMON["Mega Steelix"].atk = 125
POKEMON["Mega Steelix"].def = 230
POKEMON["Mega Steelix"].spAtk = 55
POKEMON["Mega Steelix"].spDef = 95
POKEMON["Mega Steelix"].specialAbilities = { POKEMON_SPECIAL_ABILITY_IDS.SAND_FORCE }
POKEMON["Mega Steelix"].portrait = 30298
POKEMON["Mega Steelix"].fastcallPortrait = 28941
POKEMON["Mega Steelix"].blockTransform = true
