-- Kill task data shared by game_task: type backgrounds, display names and outfit ids, keyed by
-- the lowercase task name the server sends.
TABLE_KILL = { 
["bulbasaur"] = {type1 = "Grass", type2 = "Poison", background = "Grass"},
["ivysaur"] = {type1 = "Grass", type2 = "Poison", background = "Grass"},
["venusaur"] = {type1 = "Grass", type2 = "Poison", background = "Grass"},
["charmander"] = {type1 = "Fire", type2 = "", background = "Fire"},
["charmeleon"] = {type1 = "Fire", type2 = "", background = "Fire"},
["charizard"] = {type1 = "Fire", type2 = "Fly", background = "Fire"},
["squirtle"] = {type1 = "Water", type2 = "", background = "Water"},
["wartortle"] = {type1 = "Water", type2 = "", background = "Water"},
["blastoise"] = {type1 = "Water", type2 = "", background = "Water"},
["caterpie"] = {type1 = "Bug", type2 = "", background = "Bug"},
["metapod"] = {type1 = "Bug", type2 = "", background = "Bug"},
["butterfree"] = {type1 = "Bug", type2 = "Fly", background = "Bug"},
["weedle"] = {type1 = "Bug", type2 = "Poison", background = "Bug"},
["kakuna"] = {type1 = "Bug", type2 = "Poison", background = "Bug"},
["beedrill"] = {type1 = "Bug", type2 = "Poison", background = "Bug"},
["pidgey"] = {type1 = "Normal", type2 = "Fly", background = "Fly"},
["pidgeotto"] = {type1 = "Normal", type2 = "Fly", background = "Fly"},
["pidgeot"] = {type1 = "Normal", type2 = "Fly", background = "Fly"},
["rattata"] = {type1 = "Normal", type2 = "", background = "Normal"},
["raticate"] = {type1 = "Normal", type2 = "", background = "Normal"},
["spearow"] = {type1 = "Normal", type2 = "Fly", background = "Fly"},
["fearow"] = {type1 = "Normal", type2 = "Fly", background = "Fly"},
["ekans"] = {type1 = "Poison", type2 = "", background = "Poison"},
["arbok"] = {type1 = "Poison", type2 = "", background = "Poison"},
["pikachu"] = {type1 = "Electric", type2 = "", background = "Electric"},
["raichu"] = {type1 = "Electric", type2 = "", background = "Electric"},
["sandshrew"] = {type1 = "Ground", type2 = "", background = "Ground"},
["sandslash"] = {type1 = "Ground", type2 = "", background = "Ground"},
["nidorana"] = {type1 = "Poison", type2 = "", background = "Poison"},
["nidorina"] = {type1 = "Poison", type2 = "", background = "Poison"},
["nidoqueen"] = {type1 = "Poison", type2 = "Ground", background = "Poison"},
["nidorano"] = {type1 = "Poison", type2 = "", background = "Poison"},
["nidorino"] = {type1 = "Poison", type2 = "", background = "Poison"},
["nidoking"] = {type1 = "Poison", type2 = "Ground", background = "Poison"},
["clefairy"] = {type1 = "Fairy", type2 = "", background = "Fairy"},
["clefable"] = {type1 = "Fairy", type2 = "", background = "Fairy"},
["vulpix"] = {type1 = "Fire", type2 = "", background = "Fire"},
["ninetales"] = {type1 = "Fire", type2 = "", background = "Fire"},
["jigglypuff"] = {type1 = "Normal", type2 = "Fairy", background = "Fairy"},
["wigglytuff"] = {type1 = "Normal", type2 = "Fairy", background = "Fairy"},
["zubat"] = {type1 = "Poison", type2 = "Fly", background = "Poison"},
["golbat"] = {type1 = "Poison", type2 = "Fly", background = "Poison"},
["oddish"] = {type1 = "Grass", type2 = "Poison", background = "Grass"},
["gloom"] = {type1 = "Grass", type2 = "Poison", background = "Grass"},
["vileplume"] = {type1 = "Grass", type2 = "Poison", background = "Grass"},
["paras"] = {type1 = "Bug", type2 = "Grass", background = "Bug"},
["parasect"] = {type1 = "Bug", type2 = "Grass", background = "Bug"},
["venonat"] = {type1 = "Bug", type2 = "Poison", background = "Bug"},
["venomoth"] = {type1 = "Bug", type2 = "Poison", background = "Bug"},
["diglett"] = {type1 = "Ground", type2 = "", background = "Ground"},
["dugtrio"] = {type1 = "Ground", type2 = "", background = "Ground"},
["meowth"] = {type1 = "Normal", type2 = "", background = "Normal"},
["persian"] = {type1 = "Normal", type2 = "", background = "Normal"},
["psyduck"] = {type1 = "Water", type2 = "", background = "Water"},
["golduck"] = {type1 = "Water", type2 = "", background = "Water"},
["mankey"] = {type1 = "Fighting", type2 = "", background = "Fighting"},
["primeape"] = {type1 = "Fighting", type2 = "", background = "Fighting"},
["growlithe"] = {type1 = "Fire", type2 = "", background = "Fire"},
["arcanine"] = {type1 = "Fire", type2 = "", background = "Fire"},
["poliwag"] = {type1 = "Water", type2 = "", background = "Water"},
["poliwhirl"] = {type1 = "Water", type2 = "", background = "Water"},
["poliwrath"] = {type1 = "Water", type2 = "Fighting", background = "Water"},
["abra"] = {type1 = "Psychic", type2 = "", background = "Psychic"},
["kadabra"] = {type1 = "Psychic", type2 = "", background = "Psychic"},
["alakazam"] = {type1 = "Psychic", type2 = "", background = "Psychic"},
["machop"] = {type1 = "Fighting", type2 = "", background = "Fighting"},
["machoke"] = {type1 = "Fighting", type2 = "", background = "Fighting"},
["machamp"] = {type1 = "Fighting", type2 = "", background = "Fighting"},
["bellsprout"] = {type1 = "Grass", type2 = "Poison", background = "Grass"},
["weepinbell"] = {type1 = "Grass", type2 = "Poison", background = "Grass"},
["victreebel"] = {type1 = "Grass", type2 = "Poison", background = "Grass"},
["tentacool"] = {type1 = "Water", type2 = "Poison", background = "Water"},
["tentacruel"] = {type1 = "Water", type2 = "Poison", background = "Water"},
["geodude"] = {type1 = "Rock", type2 = "Ground", background = "Rock"},
["graveler"] = {type1 = "Rock", type2 = "Ground", background = "Rock"},
["golem"] = {type1 = "Rock", type2 = "Ground", background = "Rock"},
["ponyta"] = {type1 = "Fire", type2 = "", background = "Fire"},
["rapidash"] = {type1 = "Fire", type2 = "", background = "Fire"},
["slowpoke"] = {type1 = "Water", type2 = "Psychic", background = "Water"},
["slowbro"] = {type1 = "Water", type2 = "Psychic", background = "Water"},
["magnemite"] = {type1 = "Electric", type2 = "Steel", background = "Electric"},
["magneton"] = {type1 = "Electric", type2 = "Steel", background = "Electric"},
["farfetchd"] = {type1 = "Normal", type2 = "Fly", background = "Fly"},
["doduo"] = {type1 = "Normal", type2 = "Fly", background = "Fly"},
["dodrio"] = {type1 = "Normal", type2 = "Fly", background = "Fly"},
["seel"] = {type1 = "Water", type2 = "", background = "Water"},
["dewgong"] = {type1 = "Water", type2 = "Ice", background = "Water"},
["grimer"] = {type1 = "Poison", type2 = "", background = "Poison"},
["muk"] = {type1 = "Poison", type2 = "", background = "Poison"},
["shellder"] = {type1 = "Water", type2 = "", background = "Water"},
["cloyster"] = {type1 = "Water", type2 = "Ice", background = "Water"},
["gastly"] = {type1 = "Ghost", type2 = "Poison", background = "Ghost"},
["haunter"] = {type1 = "Ghost", type2 = "Poison", background = "Ghost"},
["gengar"] = {type1 = "Ghost", type2 = "Poison", background = "Ghost"},
["onix"] = {type1 = "Rock", type2 = "Ground", background = "Rock"},
["drowzee"] = {type1 = "Psychic", type2 = "", background = "Psychic"},
["hypno"] = {type1 = "Psychic", type2 = "", background = "Psychic"},
["krabby"] = {type1 = "Water", type2 = "", background = "Water"},
["kingler"] = {type1 = "Water", type2 = "", background = "Water"},
["voltorb"] = {type1 = "Electric", type2 = "", background = "Electric"},
["electrode"] = {type1 = "Electric", type2 = "", background = "Electric"},
["exeggcute"] = {type1 = "Grass", type2 = "Psychic", background = "Grass"},
["exeggutor"] = {type1 = "Grass", type2 = "Psychic", background = "Grass"},
["cubone"] = {type1 = "Ground", type2 = "", background = "Ground"},
["marowak"] = {type1 = "Ground", type2 = "", background = "Ground"},
["hitmonlee"] = {type1 = "Fighting", type2 = "", background = "Fighting"},
["hitmonchan"] = {type1 = "Fighting", type2 = "", background = "Fighting"},
["lickitung"] = {type1 = "Normal", type2 = "", background = "Normal"},
["koffing"] = {type1 = "Poison", type2 = "", background = "Poison"},
["weezing"] = {type1 = "Poison", type2 = "", background = "Poison"},
["rhyhorn"] = {type1 = "Ground", type2 = "Rock", background = "Ground"},
["rhydon"] = {type1 = "Ground", type2 = "Rock", background = "Ground"},
["chansey"] = {type1 = "Normal", type2 = "", background = "Normal"},
["tangela"] = {type1 = "Grass", type2 = "", background = "Grass"},
["kangaskhan"] = {type1 = "Normal", type2 = "", background = "Normal"},
["horsea"] = {type1 = "Water", type2 = "", background = "Water"},
["seadra"] = {type1 = "Water", type2 = "", background = "Water"},
["goldeen"] = {type1 = "Water", type2 = "", background = "Water"},
["seaking"] = {type1 = "Water", type2 = "", background = "Water"},
["staryu"] = {type1 = "Water", type2 = "", background = "Water"},
["starmie"] = {type1 = "Water", type2 = "Psychic", background = "Water"},
["mr. mime"] = {type1 = "Psychic", type2 = "Fairy", background = "Psychic"},
["scyther"] = {type1 = "Bug", type2 = "Fly", background = "Bug"},
["jynx"] = {type1 = "Ice", type2 = "Psychic", background = "Ice"},
["electabuzz"] = {type1 = "Electric", type2 = "", background = "Electric"},
["magmar"] = {type1 = "Fire", type2 = "", background = "Fire"},
["pinsir"] = {type1 = "Bug", type2 = "", background = "Bug"},
["tauros"] = {type1 = "Normal", type2 = "", background = "Normal"},
["magikarp"] = {type1 = "Water", type2 = "", background = "Water"},
["gyarados"] = {type1 = "Water", type2 = "Fly", background = "Water"},
["lapras"] = {type1 = "Water", type2 = "Ice", background = "Ice"},
["ditto"] = {type1 = "Normal", type2 = "", background = "Normal"},
["eevee"] = {type1 = "Normal", type2 = "", background = "Normal"},
["vaporeon"] = {type1 = "Water", type2 = "", background = "Water"},
["jolteon"] = {type1 = "Electric", type2 = "", background = "Electric"},
["flareon"] = {type1 = "Fire", type2 = "", background = "Fire"},
["porygon"] = {type1 = "Normal", type2 = "", background = "Normal"},
["omanyte"] = {type1 = "Rock", type2 = "Water", background = "Water"},
["omastar"] = {type1 = "Rock", type2 = "Water", background = "Water"},
["kabuto"] = {type1 = "Rock", type2 = "Water", background = "Water"},
["kabutops"] = {type1 = "Rock", type2 = "Water", background = "Water"},
["aerodactyl"] = {type1 = "Rock", type2 = "Fly", background = "Rock"},
["snorlax"] = {type1 = "Normal", type2 = "", background = "Normal"},
["articuno"] = {type1 = "Ice", type2 = "Fly", background = "Ice"},
["zapdos"] = {type1 = "Electric", type2 = "Fly", background = "Electric"},
["moltres"] = {type1 = "Fire", type2 = "Fly", background = "Fire"},
["dratini"] = {type1 = "Dragon", type2 = "", background = "Dragon"},
["dragonair"] = {type1 = "Dragon", type2 = "", background = "Dragon"},
["dragonite"] = {type1 = "Dragon", type2 = "Fly", background = "Dragon"},
["mewtwo"] = {type1 = "Psychic", type2 = "", background = "Psychic"},
["mew"] = {type1 = "Psychic", type2 = "", background = "Psychic"},
}

CORRECT_NAME = {
["bulbasaur"] = "Bulbasaur",
["ivysaur"] = "Ivysaur",
["venusaur"] = "Venusaur",

["charmander"] = "Charmander",
["charmeleon"] = "Charmeleon",
["charizard"] = "Charizard",

["squirtle"] = "Squirtle",
["wartortle"] = "Wartortle",
["blastoise"] = "Blastoise",

["caterpie"] = "Caterpie",
["metapod"] = "Metapod",
["butterfree"] = "Butterfree",

["weedle"] = "Weedle",
["kakuna"] = "Kakuna",
["beedrill"] = "Beedrill",

["pidgey"] = "Pidgey",
["pidgeotto"] = "Pidgeotto",
["pidgeot"] = "Pidgeot",

["rattata"] = "Rattata",
["raticate"] = "Raticate",

["spearow"] = "Spearow",
["fearow"] = "Fearow",

["ekans"] = "Ekans",
["arbok"] = "Arbok",

["pikachu"] = "Pikachu",
["raichu"] = "Raichu",

["sandshrew"] = "Sandshrew",
["sandslash"] = "Sandslash",

["nidorana"] = "Nidorana",
["nidorina"] = "Nidorina",
["nidoqueen"] = "Nidoqueen",

["nidorano"] = "Nidorano",
["nidorino"] = "Nidorino",
["nidoking"] = "Nidoking",

["clefairy"] = "clefairy",
["clefable"] = "Clefable",

["vulpix"] = "Vulpix",
["ninetales"] = "Ninetales",

["jigglypuff"] = "Jigglypuff",
["wigglytuff"] = "Wigglytuff",

["zubat"] = "Zubat",
["golbat"] = "Golbat",

["oddish"] = "Oddish",
["gloom"] = "Gloom",
["vileplume"] = "Vileplume",

["paras"] = "Paras",
["parasect"] = "Parasect",

["venonat"] = "Venonat",
["venomoth"] = "Venomoth",

["diglett"] = "Diglett",
["dugtrio"] = "Dugtrio",

["meowth"] = "Meowth",
["persian"] = "Persian",

["psyduck"] = "Psyduck",
["golduck"] = "Golduck",

["mankey"] = "Mankey",
["primeape"] = "Primeape",

["growlithe"] = "Growlithe",
["arcanine"] = "Arcanine",

["poliwag"] = "Poliwag",
["poliwhirl"] = "Poliwhirl",
["poliwrath"] = "Poliwrath",

["abra"] = "Abra",
["kadabra"] = "Kadabra",
["alakazam"] = "Alakazam",

["machop"] = "Machop",
["machoke"] = "Machoke",
["machamp"] = "Machamp",

["bellsprout"] = "Bellsprout",
["weepinbell"] = "Weepinbell",
["victreebel"] = "Victreebel",

["tentacool"] = "Tentacool",
["tentacruel"] = "Tentacruel",

["geodude"] = "Geodude",
["graveler"] = "Graveler",
["golem"] = "Golem",

["ponyta"] = "Ponyta",
["rapidash"] = "Rapidash",

["slowpoke"] = "Slowpoke",
["slowbro"] = "Slowbro",

["magnemite"] = "Magnemite",
["magneton"] = "Magneton",

["farfetchd"] = "Farfetch'd",

["doduo"] = "Doduo",
["dodrio"] = "Dodrio",

["seel"] = "Seel",
["dewgong"] = "Dewgong",

["grimer"] = "Grimer",
["muk"] = "Muk",

["shellder"] = "Shellder",
["cloyster"] = "Cloyster",

["gastly"] = "Gastly",
["haunter"] = "Haunter",
["gengar"] = "Gengar",

["onix"] = "Onix",

["drowzee"] = "Drowzee",
["hypno"] = "Hypno",

["krabby"] = "Krabby",
["kingler"] = "Kingler",

["voltorb"] = "Voltorb",
["electrode"] = "Electrode",

["exeggcute"] = "Exeggcute",
["exeggutor"] = "Exeggutor",

["cubone"] = "Cubone",
["marowak"] = "Marowak",

["hitmonlee"] = "Hitmonlee",
["hitmonchan"] = "Hitmonchan",

["lickitung"] = "Lickitung",

["koffing"] = "Koffing",
["weezing"] = "Weezing",

["rhyhorn"] = "Rhyhorn",
["rhydon"] = "Rhydon",

["chansey"] = "Chansey",

["tangela"] = "Tangela",

["kangaskhan"] = "Kangaskhan",

["horsea"] = "Horsea",
["seadra"] = "Seadra",

["goldeen"] = "Goldeen",
["seaking"] = "Seaking",

["staryu"] = "Staryu",
["starmie"] = "Starmie",

["mr. mime"] = "Mr. Mime",

["scyther"] = "Scyther",

["jynx"] = "Jynx",

["electabuzz"] = "Electabuzz",

["magmar"] = "Magmar",

["pinsir"] = "Pinsir",

["tauros"] = "Tauros",

["magikarp"] = "Magikarp",
["gyarados"] = "Gyarados",

["lapras"] = "Lapras",

["ditto"] = "Ditto",

["eevee"] = "Eevee",
["vaporeon"] = "Vaporeon",
["jolteon"] = "Jolteon",
["flareon"] = "Flareon",

["porygon"] = "Porygon",

["omanyte"] = "Omanyte",
["omastar"] = "Omastar",

["kabuto"] = "Kabuto",
["kabutops"] = "Kabutops",

["aerodactyl"] = "Aerodactyl",

["snorlax"] = "Snorlax",

["articuno"] = "Articuno",
["zapdos"] = "Zapdos",
["moltres"] = "Moltres",

["dratini"] = "Dratini",
["dragonair"] = "Dragonair",
["dragonite"] = "Dragonite",

["mewtwo"] = "Mewtwo",
["mew"] = "Mew",
}

POKE_SPRITE = {
["bulbasaur"] = 352,
["ivysaur"] = 353,
["venusaur"] = 354,

["charmander"] = 355,
["charmeleon"] = 356,
["charizard"] = 357,

["squirtle"] = 358,
["wartortle"] = 359,
["blastoise"] = 360,

["caterpie"] = 361,
["metapod"] = 362,
["butterfree"] = 363,

["weedle"] = 364,
["kakuna"] = 365,
["beedrill"] = 366,

["pidgey"] = 367,
["pidgeotto"] = 368,
["pidgeot"] = 369,

["rattata"] = 370,
["raticate"] = 371,

["spearow"] = 372,
["fearow"] = 373,

["ekans"] = 374,
["arbok"] = 375,

["pikachu"] = 376,
["raichu"] = 377,

["sandshrew"] = 378,
["sandslash"] = 379,

["nidorana"] = 380,
["nidorina"] = 381,
["nidoqueen"] = 382,

["nidorano"] = 383,
["nidorino"] = 384,
["nidoking"] = 385,

["clefairy"] = 386,
["clefable"] = 387,

["vulpix"] = 388,
["ninetales"] = 389,

["jigglypuff"] = 390,
["wigglytuff"] = 391,

["zubat"] = 392,
["golbat"] = 393,

["oddish"] = 394,
["gloom"] = 395,
["vileplume"] = 396,

["paras"] = 397,
["parasect"] = 398,

["venonat"] = 399,
["venomoth"] = 400,

["diglett"] = 401,
["dugtrio"] = 402,

["meowth"] = 403,
["persian"] = 404,

["psyduck"] = 405,
["golduck"] = 406,

["mankey"] = 407,
["primeape"] = 408,

["growlithe"] = 409,
["arcanine"] = 410,

["poliwag"] = 411,
["poliwhirl"] = 412,
["poliwrath"] = 413,

["abra"] = 414,
["kadabra"] = 415,
["alakazam"] = 416,

["machop"] = 417,
["machoke"] = 418,
["machamp"] = 419,

["bellsprout"] = 420,
["weepinbell"] = 421,
["victreebel"] = 422,

["tentacool"] = 423,
["tentacruel"] = 424,

["geodude"] = 425,
["graveler"] = 426,
["golem"] = 427,

["ponyta"] = 428,
["rapidash"] = 429,

["slowpoke"] = 430,
["slowbro"] = 431,

["magnemite"] = 432,
["magneton"] = 433,

["farfetchd"] = 434,

["doduo"] = 435,
["dodrio"] = 436,

["seel"] = 437,
["dewgong"] = 438,

["grimer"] = 439,
["muk"] = 440,

["shellder"] = 441,
["cloyster"] = 442,

["gastly"] = 443,
["haunter"] = 444,
["gengar"] = 445,

["onix"] = 2699,

["drowzee"] = 447,
["hypno"] = 448,

["krabby"] = 449,
["kingler"] = 450,

["voltorb"] = 451,
["electrode"] = 452,

["exeggcute"] = 453,
["exeggutor"] = 454,

["cubone"] = 455,
["marowak"] = 456,

["hitmonlee"] = 457,
["hitmonchan"] = 458,

["lickitung"] = 459,

["koffing"] = 460,
["weezing"] = 461,

["rhyhorn"] = 462,
["rhydon"] = 463,

["chansey"] = 464,

["tangela"] = 465,

["kangaskhan"] = 466,

["horsea"] = 467,
["seadra"] = 468,

["goldeen"] = 469,
["seaking"] = 470,

["staryu"] = 471,
["starmie"] = 472,

["mr. mime"] = 473,

["scyther"] = 474,

["jynx"] = 475,

["electabuzz"] = 476,

["magmar"] = 477,

["pinsir"] = 478,

["tauros"] = 479,

["magikarp"] = 480,
["gyarados"] = 481,

["lapras"] = 482,

["ditto"] = 483,

["eevee"] = 484,
["vaporeon"] = 485,
["jolteon"] = 486,
["flareon"] = 487,

["porygon"] = 488,

["omanyte"] = 489,
["omastar"] = 490,

["kabuto"] = 491,
["kabutops"] = 492,

["aerodactyl"] = 493,

["snorlax"] = 494,

["articuno"] = 2696,
["zapdos"] = 2697,
["moltres"] = 2698,

["dratini"] = 498,
["dragonair"] = 499,
["dragonite"] = 500,

["mewtwo"] = 501,
["mew"] = 502,
}
