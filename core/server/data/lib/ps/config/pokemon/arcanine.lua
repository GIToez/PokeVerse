POKEMON["Arcanine"] = {
    pTypes = { ELEMENT_FIRE },
    dexStorage = 10059,
    atk = 110,
    def = 80,
    spAtk = 100,
    spDef = 80,
    energy = 100,
    chance = 500,
    portrait = 12760,
    dexPortrait = 13560,
    fastcallPortrait = 10693,
    catchStorage = 16059,
    evolutions = {},
    description = "A POKEMON that is described in Chinese legends. It is said to race at an unbelievable speed.",
    skills = { "Tackle", 1, "Thunder Fang", 1, "Bite", 1, "Roar", 1, "Fire Fang", 1, "Ember", 6, "Flame Wheel", 17, "Reversal", 19, "Take Down", 23, "Flame Burst", 28, "Agility", 30, "Extreme Speed", 34, "Flamethrower", 34, "Crunch", 39, "Heat Wave", 41, "Outrage", 43, "Flare Blitz", 45 },
    abilities = { POKEMON_ABILITIES.DIG, POKEMON_ABILITIES.ROCK_CLIMB, POKEMON_ABILITIES.STRENGTH, "Find", "Ride", "Headbutt" },
    eggGroup = { POKEMON_EGG_GROUP_FIELD },
    eggId = 14002,
    eggChance = 20,
    specialAbilities = { POKEMON_SPECIAL_ABILITY_IDS.INTIMIDATE, POKEMON_SPECIAL_ABILITY_IDS.FLASH_FIRE },
    learnableTms = { TM_IDS.FLAMETHROWER, TM_IDS.AERIAL_ACE, TM_IDS.IRON_TAIL, TM_IDS.HEADBUTT, TM_IDS.SOLAR_BEAM, TM_IDS.TOXIC, TM_IDS.BODY_SLAM, TM_IDS.TAKE_DOWN, TM_IDS.DOUBLE_EDGE, TM_IDS.HYPER_BEAM, TM_IDS.RAGE, TM_IDS.DRAGON_RAGE, TM_IDS.MIMIC, TM_IDS.DOUBLE_TEAM, TM_IDS.REFLECT, TM_IDS.BIDE, TM_IDS.FIRE_BLAST, TM_IDS.SWIFT, TM_IDS.SKULL_BASH, TM_IDS.REST, TM_IDS.SUBSTITUTE, TM_IDS.TAUNT, TM_IDS.SAFEGUARD, TM_IDS.OVERHEAT },
    eggMoves = { "Body Slam", "Close Combat", "Covet", "Crunch", "Double Kick", "Double-Edge", "Fire Spin", "Flare Blitz", "Heat Wave", "Howl", "Iron Tail", "Morning Sun", "Thrash" }
}

POKEMON["RC Arcanine"] = table.deepcopy(POKEMON["Arcanine"])
POKEMON["RC Arcanine"].pTypes = { ELEMENT_POISON, ELEMENT_NORMAL }
POKEMON["RC Arcanine"].blockTransform = true

POKEMON["Cloned Arcanine"] = table.deepcopy(POKEMON["Arcanine"])
POKEMON["Cloned Arcanine"].blockTransform = true