POKEMON["Victreebel"] = {
    pTypes = { ELEMENT_GRASS, ELEMENT_POISON },
    dexStorage = 10071,
    atk = 105,
    def = 65,
    spAtk = 100,
    spDef = 70,
    energy = 100,
    chance = 400,
    portrait = 12772,
    dexPortrait = 13572,
    fastcallPortrait = 10705,
    catchStorage = 16071,
    evolutions = {},
    description = "Lures prey into its mouth with a honeylike aroma. The helpless prey is melted with a dissolving fluid.",
    skills = { "Tackle", 1, "Leaf Tornado", 1, "Stockpile", 1, "Swallow", 1, "Wrap", 1, "Spit Up", 1, "Vine Whip", 1, "Sleep Powder", 1, "Razor Leaf", 1, "Poison Powder", 15, "Stun Spore", 17, "Acid", 23, "Knock Off", 27, "Leaf Storm", 32, "Gastro Acid", 35, "Poison Jab", 41, "Leaf Blade", 44, "Slam", 47, "Wring Out", 50 },
    abilities = { "Cut" },
    eggGroup = { POKEMON_EGG_GROUP_GRASS },
    eggId = 14006,
    eggChance = 20,
    specialAbilities = { POKEMON_SPECIAL_ABILITY_IDS.CHLOROPHYLL },
    learnableTms = { TM_IDS.SOFTBOILED, TM_IDS.ENERGY_BALL, TM_IDS.SLUDGE_BOMB, TM_IDS.GIGA_DRAIN, TM_IDS.SWORDS_DANCE, TM_IDS.TOXIC, TM_IDS.TAKE_DOWN, TM_IDS.DOUBLE_EDGE, TM_IDS.HYPER_BEAM, TM_IDS.RAGE, TM_IDS.MEGA_DRAIN, TM_IDS.SOLAR_BEAM, TM_IDS.MIMIC, TM_IDS.DOUBLE_TEAM, TM_IDS.REFLECT, TM_IDS.BIDE, TM_IDS.REST, TM_IDS.SUBSTITUTE, TM_IDS.BULLET_SEED },
    eggMoves = { "Acid Spray", "Belch", "Bullet Seed", "Clear Smog", "Encore", "Giga Drain", "Ingrain", "Leech Life", "Magical Leaf", "Natural Gift", "Power Whip", "Synthesis", "Tickle", "Weather Ball", "Worry Seed" }
}

POKEMON["RC Victreebel"] = table.deepcopy(POKEMON["Victreebel"])
POKEMON["RC Victreebel"].pTypes = { ELEMENT_POISON, ELEMENT_NORMAL }
POKEMON["RC Victreebel"].blockTransform = true