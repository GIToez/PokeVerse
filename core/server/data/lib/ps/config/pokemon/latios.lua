POKEMON["Latios"] = {
    pTypes = { ELEMENT_DRAGON, ELEMENT_PSYCHIC },
    dexStorage = 10381,
    atk = 90,
    def = 80,
    spAtk = 130,
    spDef = 110,
    energy = 100,
    chance = 10000,
    portrait = 28530,
    dexPortrait = -1,
    fastcallPortrait = 27374,
    catchStorage = -1,
    evolutions = {  },
    description = "A highly intelligent Pokemon. By folding back its wings in flight, it can overtake jet planes.",
    skills = { "Tackle", 1, "Memento", 1, "Heal Block", 1, "Psywave", 1, "Safeguard", 1, "Protect", 4, "Dragon Dance", 7, "Stored Power", 10, "Refresh", 13, "Heal Pulse", 16, "Dragon Breath", 20, "Luster Purge", 24, "Psycho Shift", 28, "Recover", 32, "Zen Headbutt", 41, "Psychic", 51, "Dragon Pulse", 56 },
    abilities = { "Cut", "Fly", "Surf", "Flash", "Dive", "Waterfall", POKEMON_ABILITIES.BLINK, POKEMON_ABILITIES.TELEPORT },
    eggGroup = { POKEMON_EGG_GROUP_UNDISCOVERED },
    eggId = x,
    eggChance = 20,
    specialAbilities = { POKEMON_SPECIAL_ABILITY_IDS.LEVITATE },
    learnableTms = { TM_IDS.TOXIC, TM_IDS.DOUBLE_EDGE, TM_IDS.ICE_BEAM, TM_IDS.HYPER_BEAM, TM_IDS.RAGE, TM_IDS.SOLAR_BEAM, TM_IDS.THUNDERBOLT, TM_IDS.THUNDER, TM_IDS.EARTHQUAKE, TM_IDS.PSYCHIC, TM_IDS.MIMIC, TM_IDS.DOUBLE_TEAM, TM_IDS.REFLECT, TM_IDS.BIDE, TM_IDS.SWIFT, TM_IDS.DREAM_EATER, TM_IDS.REST, TM_IDS.THUNDER_WAVE, TM_IDS.SUBSTITUTE },
    eggMoves = { --[[ TODO ]] }
}

-- Mega form (097-megaEvolution.lua): only while Mega Evolved, never wild or caught
POKEMON["Mega Latios"] = table.deepcopy(POKEMON["Latios"])
POKEMON["Mega Latios"].megaOf = "Latios"
POKEMON["Mega Latios"].pTypes = { ELEMENT_DRAGON, ELEMENT_PSYCHIC }
POKEMON["Mega Latios"].atk = 130
POKEMON["Mega Latios"].def = 100
POKEMON["Mega Latios"].spAtk = 160
POKEMON["Mega Latios"].spDef = 120
POKEMON["Mega Latios"].specialAbilities = { POKEMON_SPECIAL_ABILITY_IDS.LEVITATE }
POKEMON["Mega Latios"].portrait = 30327
POKEMON["Mega Latios"].fastcallPortrait = 28970
POKEMON["Mega Latios"].blockTransform = true
