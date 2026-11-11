POKEMON["Swampert"] = {
    pTypes = { ELEMENT_WATER, ELEMENT_GROUND },
    dexStorage = 10260,
    atk = 110,
    def = 90,
    spAtk = 85,
    spDef = 90,
    energy = 100,
    chance = 800,
    portrait = 28408,
    dexPortrait = -1,
    fastcallPortrait = 27252,
    catchStorage = 16260,
    evolutions = {  },
    description = "Its arms are hard as rock. With one swing, it can break a boulder into pieces.",
    skills = { "Tackle", 1, "Mud Shot", 1, "Hammer Arm", 1, "Growl", 1, "Water Gun", 1, "Mud-Slap", 1, "Foresight", 12, "Bide", 18, "Mud Sport", 20, "Mud Bomb", 22, "Rock Throw", 25, "Rock Slide", 28, "Protect", 32, "Whirlpool", 33, "Muddy Water", 39, "Hydro Pump", 41, "Take Down", 44, "Earthquake", 51, "Endeavor", 56 },
    abilities = { "Surf", "Strenght", "Rock Smash", "Waterfall", "Dive" },
    eggGroup = { POKEMON_EGG_GROUP_MONSTER, POKEMON_EGG_GROUP_WATER_1 },
    eggId = 28562,
    eggChance = 20,
    specialAbilities = { POKEMON_SPECIAL_ABILITY_IDS.TORRENT },
    learnableTms = { TM_IDS.TOXIC, TM_IDS.ICE_BEAM, TM_IDS.BLIZZARD, TM_IDS.PROTECT, TM_IDS.RAIN_DANCE, TM_IDS.DOUBLE_TEAM, TM_IDS.ROCK_TOMB, TM_IDS.REST, TM_IDS.ROCK_SLIDE, TM_IDS.SUBSTITUTE, TM_IDS.EARTHQUAKE, TM_IDS.HYPER_BEAM, TM_IDS.EARTHQUAKE, TM_IDS.ROCK_SLIDE, TM_IDS.FOCUS_PUNCH, TM_IDS.ROAR, TM_IDS.BRICK_BREAK, TM_IDS.HAIL },
    eggMoves = { "Ancient Power", "Avalanche", "Barrier", "Bite", "Counter", "Curse", "Double-Edge", "Ice Ball", "Mirror Coat", "Mud Bomb", "Refresh", "Sludge", "Stomp", "Uproar", "Yawn" }
}

-- Mega form (097-megaEvolution.lua): only while Mega Evolved, never wild or caught
POKEMON["Mega Swampert"] = table.deepcopy(POKEMON["Swampert"])
POKEMON["Mega Swampert"].megaOf = "Swampert"
POKEMON["Mega Swampert"].pTypes = { ELEMENT_WATER, ELEMENT_GROUND }
POKEMON["Mega Swampert"].atk = 150
POKEMON["Mega Swampert"].def = 110
POKEMON["Mega Swampert"].spAtk = 95
POKEMON["Mega Swampert"].spDef = 110
POKEMON["Mega Swampert"].specialAbilities = { POKEMON_SPECIAL_ABILITY_IDS.SWIFT_SWIM }
POKEMON["Mega Swampert"].portrait = 30308
POKEMON["Mega Swampert"].fastcallPortrait = 28951
POKEMON["Mega Swampert"].blockTransform = true
