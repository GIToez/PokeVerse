POKEMON["Arbok"] = {
    pTypes = { ELEMENT_POISON },
    dexStorage = 10024,
    atk = 95,
    def = 69,
    spAtk = 65,
    spDef = 79,
    energy = 100,
    chance = 250,
    portrait = 12725,
    dexPortrait = 13525,
    fastcallPortrait = 10658,
    catchStorage = 16024,
    evolutions = {},
    description = "The pattern on its belly appears to be a frightening face. Weak foes will flee just at the sight of the pattern.",
    skills = { "Tackle", 1, "Crunch", 1, "Ice Fang", 1, "Thunder Fang", 1, "Fire Fang", 1, "Wrap", 1, "Poison Sting", 1, "Bite", 1, "Glare", 12, "Screech", 17, "Acid", 20, "Stockpile", 27, "Swallow", 27, "Spit Up", 27, "Acid Spray", 32, "Mud Bomb", 39, "Gastro Acid", 44, "Belch", 48, "Haze", 51, "Coil", 56, "Gunk Shot", 63 },
    abilities = { POKEMON_ABILITIES.DIG, POKEMON_ABILITIES.STRENGTH, "Rock Smash", "Headbutt" },
    eggGroup = { POKEMON_EGG_GROUP_FIELD, POKEMON_EGG_GROUP_DRAGON },
    eggId = 13986,
    eggChance = 20,
    specialAbilities = { POKEMON_SPECIAL_ABILITY_IDS.INTIMIDATE, POKEMON_SPECIAL_ABILITY_IDS.SHED_SKIN },
    learnableTms = { TM_IDS.POISON_JAB, TM_IDS.ROCK_TOMB, TM_IDS.SLUDGE_BOMB, TM_IDS.IRON_TAIL, TM_IDS.GIGA_DRAIN, TM_IDS.RAIN_DANCE, TM_IDS.HEADBUTT, TM_IDS.TOXIC, TM_IDS.BODY_SLAM, TM_IDS.TAKE_DOWN, TM_IDS.DOUBLE_EDGE, TM_IDS.HYPER_BEAM, TM_IDS.RAGE, TM_IDS.MEGA_DRAIN, TM_IDS.EARTHQUAKE, TM_IDS.FISSURE, TM_IDS.MIMIC, TM_IDS.DOUBLE_TEAM, TM_IDS.BIDE, TM_IDS.SKULL_BASH, TM_IDS.REST, TM_IDS.ROCK_SLIDE, TM_IDS.SUBSTITUTE },
    eggMoves = { "Beat Up", "Disable", "Iron Tail", "Poison Fang", "Poison Tail", "Pursuit", "Scary Face", "Slam", "Snatch", "Spite", "Sucker Punch", "Switcheroo" }
}

POKEMON["RC Arbok"] = table.deepcopy(POKEMON["Arbok"])
POKEMON["RC Arbok"].pTypes = { ELEMENT_POISON, ELEMENT_NORMAL }
POKEMON["RC Arbok"].blockTransform = true