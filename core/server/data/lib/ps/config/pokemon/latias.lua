POKEMON["Latias"] = {
    pTypes = { ELEMENT_DRAGON, ELEMENT_PSYCHIC },
    dexStorage = 10380,
    atk = 80,
    def = 90,
    spAtk = 110,
    spDef = 130,
    energy = 100,
    chance = 10000,
    portrait = 28529,
    dexPortrait = -1,
    fastcallPortrait = 27373,
    catchStorage = -1,
    evolutions = {  },
    description = "It communicates using telepathy. Its body is covered in down that refracts light to make it invisible.",
    skills = { "Tackle", 1, "Healing Wish", 1, "Wish", 1, "Psywave", 1, "Safeguard", 1, "Water Sport", 4, "Charm", 7, "Stored Power", 10, "Refresh", 13, "Heal Pulse", 16, "Dragon Breath", 20, "Mist Ball", 24, "Psycho Shift", 28, "Recover", 32, "Reflect Type", 36, "Zen Headbutt", 41, "Psychic", 51, "Dragon Pulse", 56 },
    abilities = { "Cut", "Fly", "Surf", "Flash", "Dive", "Waterfall", POKEMON_ABILITIES.BLINK, POKEMON_ABILITIES.TELEPORT },
    eggGroup = { POKEMON_EGG_GROUP_UNDISCOVERED },
    eggId = x,
    eggChance = 20,
    specialAbilities = { POKEMON_SPECIAL_ABILITY_IDS.LEVITATE },
    learnableTms = { --[[ TODO ]] },
    eggMoves = { --[[ TODO ]] }
}

-- Mega form (097-megaEvolution.lua): only while Mega Evolved, never wild or caught
POKEMON["Mega Latias"] = table.deepcopy(POKEMON["Latias"])
POKEMON["Mega Latias"].megaOf = "Latias"
POKEMON["Mega Latias"].pTypes = { ELEMENT_DRAGON, ELEMENT_PSYCHIC }
POKEMON["Mega Latias"].atk = 100
POKEMON["Mega Latias"].def = 120
POKEMON["Mega Latias"].spAtk = 140
POKEMON["Mega Latias"].spDef = 150
POKEMON["Mega Latias"].specialAbilities = { POKEMON_SPECIAL_ABILITY_IDS.LEVITATE }
POKEMON["Mega Latias"].portrait = 30324
POKEMON["Mega Latias"].fastcallPortrait = 28967
POKEMON["Mega Latias"].blockTransform = true
