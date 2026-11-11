POKEMON["Gardevoir"] = {
    pTypes = { ELEMENT_PSYCHIC, ELEMENT_FAIRY },
    dexStorage = 10282,
    atk = 65,
    def = 65,
    spAtk = 125,
    spDef = 115,
    energy = 100,
    chance = 800,
    portrait = -1,
    dexPortrait = -1,
    fastcallPortrait = 27275,
    catchStorage = -1,
    evolutions = {},
    description = "To protect its Trainer, it will expend all its psychic power to create a small black hole.",
    skills = { "Tackle", 1, "Moonblast", 1, "Stored Power", 1, "Misty Terrain", 1, "Healing Wish", 1, "Growl", 1, "Confusion", 1, "Double Team", 1, "Disarming Voice", 11, "Wish", 14, "Magical Leaf", 17, "Heal Pulse", 19, "Draining Kiss", 23, "Calm Mind", 26, "Psychic", 31, "Future Sight", 40, "Captivate", 44, "Hypnosis", 49, "Dream Eater", 53 },
    abilities = {POKEMON_ABILITIES.BLINK, POKEMON_ABILITIES.TELEPORT, POKEMON_ABILITIES.FIND},
    eggGroup = { POKEMON_EGG_GROUP_AMORPHOUS },
    eggId = 28568,
    eggChance = 20,
    specialAbilities = { POKEMON_SPECIAL_ABILITY_IDS.SYNCHRONIZE, POKEMON_SPECIAL_ABILITY_IDS.TRACE },
    learnableTms = {TM_IDS.TOXIC, TM_IDS.PROTECT, TM_IDS.RAIN_DANCE, TM_IDS.THUNDERBOLT, TM_IDS.PSYCHIC, TM_IDS.SHADOW_BALL, TM_IDS.DOUBLE_TEAM, TM_IDS.REFLECT, TM_IDS.REST, TM_IDS.THUNDER_WAVE, TM_IDS.DREAM_EATER, TM_IDS.SUBSTITUTE, TM_IDS.HYPER_BEAM, TM_IDS.ENERGY_BALL, TM_IDS.CALM_MIND, TM_IDS.TAUNT, TM_IDS.LIGHT_SCREEN, TM_IDS.SAFEGUARD, TM_IDS.SHOCK_WAVE },
    eggMoves = { "Confuse Ray", "Disable", "Encore", "Grudge", "Memento", "Misty Terrain", "Shadow Sneak", "Synchronoise" }
}

-- Mega form (097-megaEvolution.lua): only while Mega Evolved, never wild or caught
POKEMON["Mega Gardevoir"] = table.deepcopy(POKEMON["Gardevoir"])
POKEMON["Mega Gardevoir"].megaOf = "Gardevoir"
POKEMON["Mega Gardevoir"].pTypes = { ELEMENT_PSYCHIC, ELEMENT_FAIRY }
POKEMON["Mega Gardevoir"].atk = 85
POKEMON["Mega Gardevoir"].def = 65
POKEMON["Mega Gardevoir"].spAtk = 165
POKEMON["Mega Gardevoir"].spDef = 135
POKEMON["Mega Gardevoir"].specialAbilities = { POKEMON_SPECIAL_ABILITY_IDS.PIXILATE }
POKEMON["Mega Gardevoir"].portrait = 30330
POKEMON["Mega Gardevoir"].fastcallPortrait = 28973
POKEMON["Mega Gardevoir"].blockTransform = true
