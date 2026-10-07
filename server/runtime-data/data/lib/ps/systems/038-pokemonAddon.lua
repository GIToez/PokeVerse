if (PokemonAddon) then
    return
end

PokemonAddon = {}

-- Constants
PokemonAddon.IDS = {
    NONE = 0,
    BLUE_CAP = 1,
    BEAUTIFUL_FLOWER = 2,
    CHRISTMAS_HAT = 3,
    SCAR_MAKEUP = 4,
    GOLD_BRACELET = 5,
    SILVER_BRACELET = 6,
    MUMMY_PACK = 7,
    NINJA_MASK = 8,
    TRAVELER_BAG = 9,
    BLUE_NINJA_PACK = 10,
    RED_NINJA_PACK = 11,
    ORANGE_NINJA_PACK = 12,
    PURPLE_NINJA_PACK = 13,
    SQUAD_JACKET = 14,
    RED_STRIPE = 15,
    SWORD_NINJA_PACK = 16,
    SAI_NINJA_PACK = 17,
    NUNCHAKU_NINJA_PACK = 18,
    STAFF_NINJA_PACK = 19,
    GREEN_BERET = 20,
    RAMBO_BAND = 21,
    PURPLE_BAND = 22,
    LIGHT_YELLOW_SCARF = 23,
    LIGHT_RED_SCARF = 24,
    CAPTAIN_HAT = 25,
    FANTASY_HAT = 26,
    BONE_CAP = 27,
    ZOMBIE_CAP = 28,
    BIG_FLYING_GLASSES = 29,
    FLYING_GLASSES = 30,
    PURPLE_SCARF = 31,
    GREEN_SCARF = 32,
    BLUE_SCARF = 33,
    SHOWER_CAP = 34,
    CHRISTMAS_CAR = 35,
    SPLINTER_KIMONO = 36,
    YELLOW_RIBBON = 37,
    RED_SCARF = 38,
    GREEN_SCARF = 39,
    PINK_BOW = 40,
    YELLOW_BOW = 41,
    LIGHT_GHOST_COSTUME = 42,
    LIGHT_JESTER_HAT = 43,
    LIGHT_ORANGE_SCARF = 44,
    LIGHT_GREEN_SCARF = 45,
    LIGHT_BLUE_SCARF = 46,
    ASH_KETCHUM_CAP = 47,
    GREEK_COSTUME = 48,
    PIRATE_COSTUME = 49,
    --    SCARF_MAKEUP = 50,
    GOD_OF_OLYMPUS_COSTUME = 51,
    SKULL_CAP = 52,
    METAL_CLAW = 53,
    OLD_MAN_GLASSES = 54,
    Z_KIMONO = 55,
    QUEEN_CROWN = 56,
    RED_STRIPE = 57,
    PURPLE_STRIPE = 58,
    KING_CROWN = 59,
    ANGEL_HALO = 60,
    CLOWN_NOSE = 61,
    SINGER_MICROPHONE = 62,
    ICE_CREAM = 63,
    ROMAN_HELMET = 64,
    COWBOY_HAT = 65,
    NINJA_MASK = 66,
    VIKING_HELMET = 67,
    SQUAD_COSTUME = 68,
    FREDDY_KRUEGER_COSTUME = 69,
    FRANKESTEIN_CAP = 70,
    RED_KARATE_HEADBAND = 71,
    YELLOW_KARATE_HEADBAND = 72,
    BLACK_KARATE_HEADBAND = 73,
    BANANA = 74,
    TRUE_CHAMPION_BELT = 75,
    DOG_COLLAR = 76,
    BLOODY_MAKEUP = 77,
    RARE_PURPLE_SCARF = 78,
    RARE_BLUE_SCARF = 79,
    RARE_GREEN_SCARF = 80,
    PITBULL_COLLAR = 81,
    YELLOW_BELT_KARATE_KIMONO = 82,
    BLACK_BELT_KARATE_KIMONO = 83,
    DRAGON_KARATE_KIMONO = 84,
    GREEN_BELT_KARATE_KIMONO = 85,
    MAGIC_KIT = 86,
    WIZARD_HAT = 87,
    MAGE_HAT = 88,
    WARLOCK_HAT = 89,
    INDIANA_JONES_COSTUME = 90,
    WRESTING_MASK = 91,
    GLADIATOR_HELMET = 92,
    DRAGON_TATTOO = 93,
    WRESTLING_MASK = 94,
    DISGUISE = 95,
    SLIME_BRAIN_CAP = 96,
    BLOODY_BRAIN_CAP = 97,
    WATER_BRAIN_CAP = 98,
    KID_CAP = 99,
    SUICIDE_COSTUME = 100,
    STEEL_HELMET = 101,
    PONY_SADDLE = 102,
    HORSE_SADDLE = 103,
    PIMP_HAT = 104,
    CLOWN_MASK = 105,
    DJ_CAP = 106,
    PIRATE_FLAG = 107,
    RED_GLASSES = 108,
    HEAVY_GHOST_COSTUME = 109,
    EYE_PATCH = 110,
    PURPLE_BANDANA = 111,
    BLACK_BANDANA = 112,
    GREEN_BANDANA = 113,
    PIRATE_PACK = 114,
    EMERALD_TURBAN = 115,
    RUBY_TURBAN = 116,
    OLD_BEARD = 117,
    PUMPKIN_HEAD = 118,
    PUMPKIN_PACK = 119,
    REAPER_COSTUME = 120,
    LUNCH_PACK = 121,
    KISS_MAKEUP = 122,
    HEAVY_PIRATE_COSTUME = 123,
    PIPE = 124,
    HEAVY_TORN_BALL = 125,
    THORN_SHOULDER = 126,
    RED_STRIPES = 127,
    NURSE_COSTUME = 128,
    WITCH_COSTUME = 129,
    FAKE_FORK = 130,
    JESTER_HAT = 131,
    GHOST_COSTUME = 132,
    COWGIRL_HAT = 133,
    GENTLEMAN_HAT = 134,
    MAGICIAN_HAT = 135,
    GREEN_APRON = 136,
    NAMEKIAN_CAPE = 137,
    BLACK_CAPE = 138,
    MONK_CAPE = 139,
    WEDDING_DRESS = 140,
    DARK_WITCH_COSTUME = 141,
    MRS_CLAUS_CLOTHES = 142,
    RAIDEN_HAT = 143,
    METAL_PACK = 144,
    BANDIT_MASK = 145,
    BLUE_SCOUTER = 146,
    GREEN_SCOUTER = 147,
    FLAMETHROW_KIT = 148,
--    YELLOW_KARATE_HEADBAND = 149,
    PURPLE_STRIPE = 150,
    BULL_BLACK_SADDLE = 151,
    BULL_RED_SADDLE = 152,
    ORIENTAL_DRAGON_MASK = 153,
    RED_DRAGON_MASK = 154,
    RETRO_DRAGON_MASK = 155,
    WATER_PENDANT = 156,
    PEARL_NECKLACE = 157,
    PINK_SHELL = 158,
    YELLOW_SHELL = 159,
    DARK_PENDANT = 160,
    CLASSIC_VAMPIRE_COSTUME = 161,
    VAMPIRE_COSTUME = 162,
    RED_CAPE = 163,
    PARTY_CAP = 164,
    STAR_GLASSES = 165,
    CHEF_COSTUME = 166,
    OBELIX_COSTUME = 167,
    BEAR_CAP = 168,
    POLAR_BEAR_CAP = 169,
    RED_DRAGON_SCARF = 170,
    GREEN_DRAGON_SCARF = 171,
    YELLOW_DRAGON_SCARF = 172,
    RED_POSTMAN_BAG = 173,
    BLUE_POSTMAN_BAG = 174,
    GRAY_POSTMAN_BAG = 175,
    BLACK_CAPE = 176,
    RED_TAEK_HEADBAND = 177,
    BLUE_TAEK_HEADBAND = 178,
    --    RED_TAEK_HEADBAND = 179,
    WHITE_HEADBAND = 180,
    FIRE_SAMURAI_ARMOR = 181,
    --    FIRE_SAMURAI_ARMOR = 182,
    --    FIRE_SAMURAI_ARMOR = 183,
    SPIKES = 184,
    THUNDER_SAMURAI_ARMOR = 185,
    MURMILO_HELMET = 186,
    BANE_COSTUME = 187,
    --    ADDON = 188,
    --    ADDON = 189,
    BATSUIT = 190,
    RASTAFARI = 191,
    BABY_BOTTLE = 192,
    COW_SUIT = 193,
    COW_SADDLE = 194,
    ILLIDAN_COSTUME = 195,
    GUITAR_PLAYER = 196,
    FLAT_IRON = 197,
    MAGMAR_IRON_MASK = 198,
    SAYAN_ARMOR = 199,
    TRANSFORMER_ARMOR = 200,
    RYU_COSTUME = 201,
    KEN_COSTUME = 202,
    COWGIRL_COSTUME = 203,
    FARMER_COSTUME = 204,
    SANTA_CLAUS_COSTUME = 205,
    LORD_IRON_MASK = 206,
    ELDER_IRON_MASK = 207,
    RED_DYNOMUTT_COSTUME = 208,
    DYNOMUTT_COSTUME = 209,
    PIRATE_EMPRESS_RED_DRESS = 210,
    PIRATE_EMPRESS_BLUE_DRESS = 211,
    POKEMON_TRAINER_COSTUME = 212,
    CHAVES_COSTUME = 213,
    NINJA_COSTUME = 214,
    CLAN_COSTUME = 215,
    SAILOR_COSTUME = 216,
    HUNTER_COSTUME = 217,
    LIFE_JACKET = 218,
    TITANIUM_ARMOR = 219,
    --    ADDON = 220,
    SEA_KNIGHT_COSTUME = 221,
    LIFESAVER_COSTUME = 222,
    ROYAL_ARMOR = 223,
    BOO_COSTUME = 224,
    NURSE_COSTUME = 225,
    FLOWER_COSTUME = 226,
    CYBER_MASK = 227,
    PARASITE_COSTUME = 228,
    TANUKI_HAT = 229,
    FOSSILZED_KABUTOPS = 230,
    FOSSILZED_AERODACTYL = 231,
    FOSSILZED_BASTIODON = 232,
    FOSSILZED_ARMALDO = 233,
    FOSSILZED_OMASTAR = 234,
    FOSSILZED_KABUTO = 235,
    FOSSILZED_OMANYTE = 236,
    UKULELE_PLAYER = 237,
    EVIL_ILLIDAN_COSTUME = 238,
    LUFFY_COSTUME = 239,
    MAFIA_CAP = 240,
    SANTORYU_COSTUME = 241,
    POWER_TOPAZ = 242,
    POWER_EMERALD = 243,
    POWER_RUBY = 244,
    SACK = 245,
    SUPERHERO_COSTUME = 246,
    TRIBAL_HEADDRESS = 247,
    HANNYA_MASK = 248,
    SKARMORY_BATTLE_ARMOR = 250,
    KINGDRA_BATTLE_ARMOR = 251,
    BATTLE_ARMOR = 252,
    MERCENARY_MASK = 253,
    SILVER_NINJA_COSTUME = 254,
    GREYBEARD_COSTUME = 255,
    METALIC_PACK = 256,
    CHARIZARD_BATTLE_ARMOR = 257,
    SUPERHERO_CAPE = 258,
    NINJA_CLOTHES = 259,
    MECHANICAL_CLOTHES = 260,
    GENTLEMAN_CLOTHES = 261,
    IRON_JAW = 258,


    LEONCIO_COSTUME = 259,
    BEAR_COSTUME = 260,
    ICE_BEAR_COSTUME = 261,
    BATTLE_ARMOR = 262,
    DJ_COSTUME = 263,
    COWBOY_COSTUME = 264,
    ADVENTUROUS_PIRATE = 265,
    ANCIENT = 266,
    ARMOR_CORE = 267,
    BLACK_ADAM_COSTUME = 268,
    SHAZAM_COSTUME = 269,
    BLUE_FLAMES_MAGE = 270,
    FIRE_MAGE = 271,
    CYBORG_ARMOR1 = 272,
    CYBORG_ARMOR2 = 273,
    CYBORG_ARMOR3 = 274,
    CYBORG_ARMOR4 = 275,
    CYBORG_ARMOR5 = 276,
    DEFINITELY_NOT_MAGIKARP = 277,
    FLASH_COSTUME = 278,
    FLINSTONE = 279,
    GENIUS = 280,
    GIRL_POWER = 281,
    GUARD = 282,
    GUARDIAN_ARMOR = 283,
    HAPPY_OCTOPUS_COSTUME = 284,
    LANCES_CLOTHES = 285,
    MALEVOLA_COSTUME = 286,
    MARIO_COSTUME = 287,
    OCTOPUS_COSTUME = 288,
    PEAKY_BLINDERS_COSTUME1 = 289,
    PEAKY_BLINDERS_COSTUME2 = 290,
    PUFFER_FISH_COSTUME = 291,
    YAKUZA_COSTUME = 292,
    WONDER_WOMAN = 293,
    WORD_CHAMPION_ROBE = 294,
    THOR_COSTUME = 295,
    RYUJIN_COSTUME = 296,
    SERPENT_ARMOR = 297,
    TROPICAL_COSTUME = 298,
    CYBORG_ARMOR6 = 299,
    ROCKSTAR = 300,
    METAL_ARMOR = 301,
    ROBOT_UNICORN = 302,
    PEGASUS_COSTUME = 303,
    DEATH_UNICORN = 304,
    DEATH = 305,
    CYBORG_ARMOR7 = 306,

    MILLNENNIUM_INSPIRATION = 307,
    SUPREME_DEITY = 308,
    BLACK_RAVEN = 309,
    DIAMOND_FURY = 310,
    ALDEBARAN_COSTUME = 311,
    BABY_KURAMA = 312,
    SHINY_CYBORG_ARMOR1 = 313,
    SHINY_CYBORG_ARMOR2 = 314,
    SHINY_CYBORG_ARMOR3 = 315,
    SHINY_CYBORG_ARMOR4 = 316,
    SHINY_CYBORG_ARMOR5 = 317,
    SHINY_CYBORG_ARMOR6 = 318,
    DEATH_COSTUME = 319,
    DEMON_COSTUME = 320,
    ANGEL_COSTUME = 321,
    JIGSAW_COSTUME = 322,
    JOKER_COSTUME = 323,
    THORN_ARMOR = 324,
    SHINY_METAL_ARMOR1 = 325,
    SHINY_METAL_ARMOR2 = 326,
    SHINY_METAL_ARMOR3 = 327,
    SHINY_METAL_ARMOR4 = 328,
    SHINY_METAL_ARMOR5 = 329,
    TERMINATOR = 330,
    REGGAE_COSTUME = 331,
    MATLACHINES = 332,
    VAMPIRE_COSTUME1 = 333,
    VAMPIRE_COSTUME2 = 334,
    WITCH_COSTUME1 = 335,
    PANIC_COSTUME = 336,
    WEREWOLF_COSTUME = 337,
    ZOMBIE_COSTUME = 339,
    DEATH_SKULL = 340,
    ALPHA_WEREWOLF_COSTUME = 341,
    JASON_COSTUME = 342,
    BATMAN_COSTUME = 343,
    SHINY_COWBOY_COSTUME = 344,
    BONE_ARMOR = 345,
    ANBU_MASK = 346,
    WITCH_COSTUME2 = 347,
    BRIDE_COSTUME = 348,
    BEAR_COAT = 349,
    ENJOYING_SUMMER1 = 350,
    ENJOYING_SUMMER2 = 351,
    MOON_FAIRY = 352,
    KYUBIMON_COSTUME = 353,
    AHRI_ATARI = 354,
    KURAMA_ASURA = 355,
    GREYMON_COSTUME = 356,
    CAVE_GLADIATOR = 357,
    GABUMON_COSTUME = 358,
    DREGGMAN_COSTUME = 359,
    KILLER_CLOAK = 360,
	
    --ADDON = 361,
    --ADDON = 362,
    --ADDON = 363,
    --ADDON = 364,
    --ADDON = 365,
    --ADDON = 366,
    --ADDON = 367,
    --ADDON = 368,
    --ADDON = 369,
    --ADDON = 370,
    --ADDON = 371,
    --ADDON = 372,
    --ADDON = 373,
    --ADDON = 374,
    --ADDON = 375,
}

local ADDONS = {}

ADDONS[PokemonAddon.IDS.NONE] = {
    id = PokemonAddon.IDS.NONE,
    name = "None",
    itemId = 0
}

ADDONS[PokemonAddon.IDS.BLUE_CAP] = {
    outfits = {
        ["Bulbasaur"] = { lookType = 2091 }
    },
    itemId = 29562,
}

ADDONS[PokemonAddon.IDS.BEAUTIFUL_FLOWER] = {
    outfits = {
        ["Bulbasaur"] = { lookType = 2093 },
        ["Venusaur"] = { lookType = 2094, ride = 2095 },
        ["Charizard"] = { lookType = 2112, fly = 2113 },
    },
    itemId = 29563,
}

--ADDONS[PokemonAddon.IDS.CHRISTMAS_HAT] = {
--    outfits = {
--        ["Bulbasaur"] = { lookType = 0 },
--        ["Caterpie"] = { lookType = 0 },
--        ["Charmander"] = { lookType = 0 },
--        ["Diglett"] = { lookType = 0 },
--        ["Ditto"] = { lookType = 0 },
--        ["Eevee"] = { lookType = 0 },
--        ["Pikachu"] = { lookType = 0 },
--        ["Psyduck"] = { lookType = 0 },
--        ["Seel"] = { lookType = 0 },
--        ["Squirtle"] = { lookType = 0 },
--    },
--    itemId = 29564,
--}

ADDONS[PokemonAddon.IDS.SCAR_MAKEUP] = {
    outfits = {
        ["Alakazam"] = { lookType = 2073 },
        ["Arcanine"] = { lookType = 2215, ride = 2216 },
        ["Blastoise"] = { lookType = 2146, surf = 2147 },
        ["Charizard"] = { lookType = 2116, fly = 2117 },
        --        ["Gengar"] = { lookType = 0 },
        ["Gyarados"] = { lookType = 2341, surf = 2343 },
        --        ["Magmar"] = { lookType = 0 },
        --        ["Onix"] = { lookType = 0 },
        ["Raichu"] = { lookType = 2168 },
        ["Scyther"] = { lookType = 2324 },
        ["Venusaur"] = { lookType = 2097, ride = 2096 },
    },
    itemId = 29565,
}

ADDONS[PokemonAddon.IDS.GOLD_BRACELET] = {
    outfits = {
        ["Venusaur"] = { lookType = 2162, ride = 2175 }
    },
    itemId = 29567,
}

ADDONS[PokemonAddon.IDS.SILVER_BRACELET] = {
    outfits = {
        ["Venusaur"] = { lookType = 2252, ride = 2253 }
    },
    itemId = 29568,
}

ADDONS[PokemonAddon.IDS.MUMMY_PACK] = {
    outfits = {
        ["Charmander"] = { lookType = 2099 }
    },
    itemId = 29569,
}

ADDONS[PokemonAddon.IDS.NINJA_MASK] = {
    outfits = {
        ["Charmander"] = { lookType = 2098 }
    },
    itemId = 29570,
}

ADDONS[PokemonAddon.IDS.TRAVELER_BAG] = {
    outfits = {
        ["Charizard"] = { lookType = 2114, fly = 2115 }
    },
    itemId = 29572,
}

ADDONS[PokemonAddon.IDS.BLUE_NINJA_PACK] = {
    outfits = {
        ["Squirtle"] = { lookType = 2118, surf = 2119 }
    },
    itemId = 29575,
}

ADDONS[PokemonAddon.IDS.RED_NINJA_PACK] = {
    outfits = {
        ["Squirtle"] = { lookType = 2120, surf = 2121 }
    },
    itemId = 29576,
}

ADDONS[PokemonAddon.IDS.ORANGE_NINJA_PACK] = {
    outfits = {
        ["Squirtle"] = { lookType = 2125, surf = 2124 }
    },
    itemId = 29577,
}

ADDONS[PokemonAddon.IDS.PURPLE_NINJA_PACK] = {
    outfits = {
        ["Squirtle"] = { lookType = 2122, surf = 2123 }
    },
    itemId = 29578,
}

--ADDONS[PokemonAddon.IDS.SQUAD_JACKET] = {
--    outfits = {
--        ["Squirtle"] = { lookType = 0 }
--    },
--    itemId = 29579,
--}

ADDONS[PokemonAddon.IDS.RED_STRIPE] = {
    outfits = {
        ["Nidoqueen"] = { lookType = 0 }
    },
    itemId = 29581,
}

ADDONS[PokemonAddon.IDS.SWORD_NINJA_PACK] = {
    outfits = {
        ["Blastoise"] = { lookType = 2130, surf = 2141 }
    },
    itemId = 29583,
}

ADDONS[PokemonAddon.IDS.SAI_NINJA_PACK] = {
    outfits = {
        ["Blastoise"] = { lookType = 2139, surf = 2142 }
    },
    itemId = 29584,
}

ADDONS[PokemonAddon.IDS.NUNCHAKU_NINJA_PACK] = {
    outfits = {
        ["Blastoise"] = { lookType = 2140, surf = 2143 }
    },
    itemId = 29585,
}

ADDONS[PokemonAddon.IDS.STAFF_NINJA_PACK] = {
    outfits = {
        ["Blastoise"] = { lookType = 2131, surf = 2144 }
    },
    itemId = 29586,
}

ADDONS[PokemonAddon.IDS.GREEN_BERET] = {
    outfits = {
        ["Caterpie"] = { lookType = 2103 }
    },
    itemId = 29587,
}

ADDONS[PokemonAddon.IDS.RAMBO_BAND] = {
    outfits = {
        ["Caterpie"] = { lookType = 2105 }
    },
    itemId = 29588,
}

ADDONS[PokemonAddon.IDS.PURPLE_BAND] = {
    outfits = {
        ["Caterpie"] = { lookType = 2104 }
    },
    itemId = 29589,
}

ADDONS[PokemonAddon.IDS.LIGHT_YELLOW_SCARF] = {
    outfits = {
        ["Butterfree"] = { lookType = 2106 }
    },
    itemId = 29591,
}

ADDONS[PokemonAddon.IDS.LIGHT_RED_SCARF] = {
    outfits = {
        ["Butterfree"] = { lookType = 2107 }
    },
    itemId = 29592,
}

ADDONS[PokemonAddon.IDS.CAPTAIN_HAT] = {
    outfits = {
        ["Butterfree"] = { lookType = 2108 }
    },
    itemId = 29593,
}

ADDONS[PokemonAddon.IDS.FANTASY_HAT] = {
    outfits = {
        ["Pidgey"] = { lookType = 2110 }
    },
    itemId = 29594,
}

ADDONS[PokemonAddon.IDS.BONE_CAP] = {
    outfits = {
        ["Pidgey"] = { lookType = 2111 }
    },
    itemId = 29595,
}

ADDONS[PokemonAddon.IDS.ZOMBIE_CAP] = {
    outfits = {
        ["Pidgey"] = { lookType = 2109 }
    },
    itemId = 29596,
}

ADDONS[PokemonAddon.IDS.BIG_FLYING_GLASSES] = {
    outfits = {
        ["Pidgeot"] = { lookType = 2127, fly = 2128 }
    },
    itemId = 29597,
}

ADDONS[PokemonAddon.IDS.FLYING_GLASSES] = {
    outfits = {
        ["Pidgeotto"] = { lookType = 2126 }
    },
    itemId = 29598,
}

ADDONS[PokemonAddon.IDS.PURPLE_SCARF] = {
    outfits = {
        ["Pidgeot"] = { lookType = 2153, fly = 2154 }
    },
    itemId = 29599,
}

ADDONS[PokemonAddon.IDS.GREEN_SCARF] = {
    outfits = {
        ["Pidgeot"] = { lookType = 2151, fly = 2152 }
    },
    itemId = 29600,
}

ADDONS[PokemonAddon.IDS.BLUE_SCARF] = {
    outfits = {
        ["Pidgeot"] = { lookType = 2155, fly = 2156 }
    },
    itemId = 29601,
}

ADDONS[PokemonAddon.IDS.SHOWER_CAP] = {
    outfits = {
        ["Rattata"] = { lookType = 2137 }
    },
    itemId = 29602,
}

--ADDONS[PokemonAddon.IDS.CHRISTMAS_CAR] = {
--    outfits = {
--        ["Rattata"] = { lookType = 0 }
--    },
--    itemId = 29603,
--}

ADDONS[PokemonAddon.IDS.SPLINTER_KIMONO] = {
    outfits = {
        ["Raticate"] = { lookType = 2145 }
    },
    itemId = 29604,
}

ADDONS[PokemonAddon.IDS.YELLOW_RIBBON] = {
    outfits = {
        ["Pinsir"] = { lookType = 2273 }
    },
    itemId = 29605,
}

ADDONS[PokemonAddon.IDS.RED_SCARF] = {
    outfits = {
        ["Fearow"] = { lookType = 2188, fly = 2191 }
    },
    itemId = 29606,
}

ADDONS[PokemonAddon.IDS.GREEN_SCARF] = {
    outfits = {
        ["Fearow"] = { lookType = 2186, fly = 2189 }
    },
    itemId = 29607,
}

ADDONS[PokemonAddon.IDS.PINK_BOW] = {
    outfits = {
        ["Arbok"] = { lookType = 2148 }
    },
    itemId = 29608,
}

ADDONS[PokemonAddon.IDS.YELLOW_BOW] = {
    outfits = {
        ["Arbok"] = { lookType = 2161 }
    },
    itemId = 29609,
}

ADDONS[PokemonAddon.IDS.LIGHT_GHOST_COSTUME] = {
    outfits = {
        ["Pikachu"] = { lookType = 2132 }
    },
    itemId = 29610,
}

ADDONS[PokemonAddon.IDS.LIGHT_JESTER_HAT] = {
    outfits = {
        ["Pikachu"] = { lookType = 2135 }
    },
    itemId = 29611,
}

ADDONS[PokemonAddon.IDS.LIGHT_ORANGE_SCARF] = {
    outfits = {
        ["Pikachu"] = { lookType = 2133 }
    },
    itemId = 29612,
}

ADDONS[PokemonAddon.IDS.LIGHT_GREEN_SCARF] = {
    outfits = {
        ["Pikachu"] = { lookType = 2134 }
    },
    itemId = 29613,
}

ADDONS[PokemonAddon.IDS.LIGHT_BLUE_SCARF] = {
    outfits = {
        ["Pikachu"] = { lookType = 2136 }
    },
    itemId = 29614,
}

ADDONS[PokemonAddon.IDS.ASH_KETCHUM_CAP] = {
    outfits = {
        ["Pikachu"] = { lookType = 2319 }
    },
    itemId = 29616,
}

ADDONS[PokemonAddon.IDS.GREEK_COSTUME] = {
    outfits = {
        ["Raichu"] = { lookType = 2166 }
    },
    itemId = 29617,
}

ADDONS[PokemonAddon.IDS.PIRATE_COSTUME] = {
    outfits = {
        ["Raichu"] = { lookType = 2167 }
    },
    itemId = 29618,
}

ADDONS[PokemonAddon.IDS.GOD_OF_OLYMPUS_COSTUME] = {
    outfits = {
        ["Raichu"] = { lookType = 2169 }
    },
    itemId = 29620,
}

ADDONS[PokemonAddon.IDS.SKULL_CAP] = {
    outfits = {
        ["Sandshrew"] = { lookType = 2171 }
    },
    itemId = 29621,
}

ADDONS[PokemonAddon.IDS.METAL_CLAW] = {
    outfits = {
        ["Sandslash"] = { lookType = 2172 }
    },
    itemId = 29622,
}

ADDONS[PokemonAddon.IDS.OLD_MAN_GLASSES] = {
    outfits = {
        ["Sandslash"] = { lookType = 2173 }
    },
    itemId = 29623,
}

ADDONS[PokemonAddon.IDS.Z_KIMONO] = {
    outfits = {
        ["Sandslash"] = { lookType = 2174 }
    },
    itemId = 29624,
}

ADDONS[PokemonAddon.IDS.QUEEN_CROWN] = {
    outfits = {
        ["Nidoqueen"] = { lookType = 2149 }
    },
    itemId = 29625,
}

ADDONS[PokemonAddon.IDS.RED_STRIPE] = {
    outfits = {
        ["Nidoqueen"] = { lookType = 2165 }
    },
    itemId = 29626,
}

ADDONS[PokemonAddon.IDS.PURPLE_STRIPE] = {
    outfits = {
        ["Nidoqueen"] = { lookType = 0 }
    },
    itemId = 29627,
}

ADDONS[PokemonAddon.IDS.KING_CROWN] = {
    outfits = {
        ["Nidoking"] = { lookType = 2150 }
    },
    itemId = 29628,
}

ADDONS[PokemonAddon.IDS.ANGEL_HALO] = {
    outfits = {
        ["Clefable"] = { lookType = 2076 }
    },
    itemId = 29629,
}

ADDONS[PokemonAddon.IDS.CLOWN_NOSE] = {
    outfits = {
        ["Clefable"] = { lookType = 2164 }
    },
    itemId = 29630,
}

ADDONS[PokemonAddon.IDS.SINGER_MICROPHONE] = {
    outfits = {
        ["Wigglytuff"] = { lookType = 2077 }
    },
    itemId = 29631,
}

ADDONS[PokemonAddon.IDS.ICE_CREAM] = {
    outfits = {
        ["Wigglytuff"] = { lookType = 2163 }
    },
    itemId = 29632,
}

ADDONS[PokemonAddon.IDS.ROMAN_HELMET] = {
    outfits = {
        ["Golbat"] = { lookType = 2170 }
    },
    itemId = 29633,
}

ADDONS[PokemonAddon.IDS.COWBOY_HAT] = {
    outfits = {
        ["Diglett"] = { lookType = 2158 }
    },
    itemId = 29634,
}

ADDONS[PokemonAddon.IDS.NINJA_MASK] = {
    outfits = {
        ["Diglett"] = { lookType = 2160 }
    },
    itemId = 29635,
}

ADDONS[PokemonAddon.IDS.VIKING_HELMET] = {
    outfits = {
        ["Diglett"] = { lookType = 2157 }
    },
    itemId = 29636,
}

ADDONS[PokemonAddon.IDS.SQUAD_COSTUME] = {
    outfits = {
        ["Dugtrio"] = { lookType = 2159 }
    },
    itemId = 29638,
}

ADDONS[PokemonAddon.IDS.FREDDY_KRUEGER_COSTUME] = {
    outfits = {
        ["Meowth"] = { lookType = 2100 }
    },
    itemId = 29639,
}

ADDONS[PokemonAddon.IDS.FRANKESTEIN_CAP] = {
    outfits = {
        ["Psyduck"] = { lookType = 2176 }
    },
    itemId = 29640,
}

ADDONS[PokemonAddon.IDS.RED_KARATE_HEADBAND] = {
    outfits = {
        ["Golduck"] = { lookType = 2177, surf = 2180 }
    },
    itemId = 29642,
}

ADDONS[PokemonAddon.IDS.YELLOW_KARATE_HEADBAND] = {
    outfits = {
        ["Golduck"] = { lookType = 2178, surf = 2181 }
    },
    itemId = 29643,
}

ADDONS[PokemonAddon.IDS.BLACK_KARATE_HEADBAND] = {
    outfits = {
        ["Golduck"] = { lookType = 2179, surf = 2182 }
    },
    itemId = 29644,
}

ADDONS[PokemonAddon.IDS.BANANA] = {
    outfits = {
        ["Mankey"] = { lookType = 2184 }
    },
    itemId = 29645,
}

ADDONS[PokemonAddon.IDS.TRUE_CHAMPION_BELT] = {
    outfits = {
        ["Primeape"] = { lookType = 2185 }
    },
    itemId = 29646,
}

ADDONS[PokemonAddon.IDS.DOG_COLLAR] = {
    outfits = {
        ["Growlithe"] = { lookType = 2212 }
    },
    itemId = 29647,
}

ADDONS[PokemonAddon.IDS.BLOODY_MAKEUP] = {
    outfits = {
        ["Gyarados"] = { lookType = 2342, surf = 2344 }
    },
    itemId = 29648,
}

ADDONS[PokemonAddon.IDS.RARE_BLUE_SCARF] = {
    outfits = {
        ["Arcanine"] = { lookType = 2217, ride = 2218 }
    },
    itemId = 29649,
}

ADDONS[PokemonAddon.IDS.RARE_GREEN_SCARF] = {
    outfits = {
        ["Arcanine"] = { lookType = 2217, ride = 2218 }
    },
    itemId = 29650,
}

ADDONS[PokemonAddon.IDS.RARE_PURPLE_SCARF] = {
    outfits = {
        ["Arcanine"] = { lookType = 2217, ride = 2218 }
    },
    itemId = 29651,
}

ADDONS[PokemonAddon.IDS.PITBULL_COLLAR] = {
    outfits = {
        ["Arcanine"] = { lookType = 2223, ride = 2224 }
    },
    itemId = 29652,
}

ADDONS[PokemonAddon.IDS.YELLOW_BELT_KARATE_KIMONO] = {
    outfits = {
        ["Poliwrath"] = { lookType = 2205, surf = 2207 }
    },
    itemId = 29653,
}

ADDONS[PokemonAddon.IDS.BLACK_BELT_KARATE_KIMONO] = {
    outfits = {
        ["Poliwrath"] = { lookType = 2202, surf = 2208 }
    },
    itemId = 29654,
}

ADDONS[PokemonAddon.IDS.DRAGON_KARATE_KIMONO] = {
    outfits = {
        ["Poliwrath"] = { lookType = 2206, surf = 2209 }
    },
    itemId = 29655,
}

ADDONS[PokemonAddon.IDS.GREEN_BELT_KARATE_KIMONO] = {
    outfits = {
        ["Poliwrath"] = { lookType = 2211, surf = 2210 }
    },
    itemId = 29656,
}

ADDONS[PokemonAddon.IDS.MAGIC_KIT] = {
    outfits = {
        ["Abra"] = { lookType = 2213 }
    },
    itemId = 29657,
}

ADDONS[PokemonAddon.IDS.WIZARD_HAT] = {
    outfits = {
        ["Alakazam"] = { lookType = 2074 }
    },
    itemId = 29658,
}

ADDONS[PokemonAddon.IDS.MAGE_HAT] = {
    outfits = {
        ["Alakazam"] = { lookType = 2072 }
    },
    itemId = 29659,
    name = "Mage Hat",
}

ADDONS[PokemonAddon.IDS.WARLOCK_HAT] = {
    outfits = {
        ["Alakazam"] = { lookType = 2198 }
    },
    itemId = 29660,
    name = "Warlock Hat",
}

ADDONS[PokemonAddon.IDS.INDIANA_JONES_COSTUME] = {
    outfits = {
        ["Alakazam"] = { lookType = 2071 }
    },
    itemId = 29662,
    name = "Indiana Jones Costume",
}

ADDONS[PokemonAddon.IDS.WRESTING_MASK] = {
    outfits = {
        ["Machamp"] = { lookType = 2214 }
    },
    itemId = 29663,
}

ADDONS[PokemonAddon.IDS.GLADIATOR_HELMET] = {
    outfits = {
        ["Machamp"] = { lookType = 2193 }
    },
    itemId = 29664,
}

ADDONS[PokemonAddon.IDS.DRAGON_TATTOO] = {
    outfits = {
        ["Machamp"] = { lookType = 2204 }
    },
    itemId = 29665,
}

ADDONS[PokemonAddon.IDS.WRESTLING_MASK] = {
    outfits = {
        ["Machop"] = { lookType = 2192 }
    },
    itemId = 29666,
}

ADDONS[PokemonAddon.IDS.DISGUISE] = {
    outfits = {
        ["Victreebel"] = { lookType = 2254 }
    },
    itemId = 29667,
}

ADDONS[PokemonAddon.IDS.SLIME_BRAIN_CAP] = {
    outfits = {
        ["Tentacruel"] = { lookType = 2255 }
    },
    itemId = 29668,
}

ADDONS[PokemonAddon.IDS.BLOODY_BRAIN_CAP] = {
    outfits = {
        ["Tentacruel"] = { lookType = 2256 }
    },
    itemId = 29669,
}

ADDONS[PokemonAddon.IDS.WATER_BRAIN_CAP] = {
    outfits = {
        ["Tentacruel"] = { lookType = 2257 }
    },
    itemId = 29670,
}

ADDONS[PokemonAddon.IDS.KID_CAP] = {
    outfits = {
        ["Geodude"] = { lookType = 2233 }
    },
    itemId = 29671,
}

ADDONS[PokemonAddon.IDS.SUICIDE_COSTUME] = {
    outfits = {
        ["Golem"] = { lookType = 2225 }
    },
    itemId = 29672,
}

ADDONS[PokemonAddon.IDS.STEEL_HELMET] = {
    outfits = {
        ["Golem"] = { lookType = 2226 }
    },
    itemId = 29673,
}

ADDONS[PokemonAddon.IDS.PONY_SADDLE] = {
    outfits = {
        ["Ponyta"] = { lookType = 2267, ride = 2268 }
    },
    itemId = 29674,
}

ADDONS[PokemonAddon.IDS.HORSE_SADDLE] = {
    outfits = {
        ["Rapidash"] = { lookType = 2531, ride = 2419 }
    },
    itemId = 29675,
}

ADDONS[PokemonAddon.IDS.PIMP_HAT] = {
    outfits = {
        ["Farfetchd"] = { lookType = 2234 }
    },
    itemId = 29676,
}

ADDONS[PokemonAddon.IDS.CLOWN_MASK] = {
    outfits = {
        ["Dewgong"] = { lookType = 2229, surf = 2230 }
    },
    itemId = 29678,
}

ADDONS[PokemonAddon.IDS.DJ_CAP] = {
    outfits = {
        ["Muk"] = { lookType = 2231 }
    },
    itemId = 29679,
}

ADDONS[PokemonAddon.IDS.PIRATE_FLAG] = {
    outfits = {
        ["Cloyster"] = { lookType = 2228 }
    },
    itemId = 29680,
}

ADDONS[PokemonAddon.IDS.RED_GLASSES] = {
    outfits = {
        ["Cloyster"] = { lookType = 2232 }
    },
    itemId = 29681,
}

ADDONS[PokemonAddon.IDS.HEAVY_GHOST_COSTUME] = {
    outfits = {
        ["Haunter"] = { lookType = 2236 }
    },
    itemId = 29682,
}

ADDONS[PokemonAddon.IDS.EYE_PATCH] = {
    outfits = {
        ["Haunter"] = { lookType = 2235 }
    },
    itemId = 29683,
}

ADDONS[PokemonAddon.IDS.PURPLE_BANDANA] = {
    outfits = {
        ["Gengar"] = { lookType = 2082 }
    },
    itemId = 29684,
}

ADDONS[PokemonAddon.IDS.BLACK_BANDANA] = {
    outfits = {
        ["Gengar"] = { lookType = 2240 }
    },
    itemId = 29685,
}

ADDONS[PokemonAddon.IDS.GREEN_BANDANA] = {
    outfits = {
        ["Gengar"] = { lookType = 2239 }
    },
    itemId = 29686,
}

ADDONS[PokemonAddon.IDS.PIRATE_PACK] = {
    outfits = {
        ["Gengar"] = { lookType = 2082 }
    },
    itemId = 29687,
}

ADDONS[PokemonAddon.IDS.EMERALD_TURBAN] = {
    outfits = {
        ["Hypno"] = { lookType = 2246 }
    },
    itemId = 29690,
}

ADDONS[PokemonAddon.IDS.RUBY_TURBAN] = {
    outfits = {
        ["Hypno"] = { lookType = 2247 }
    },
    itemId = 29691,
}

ADDONS[PokemonAddon.IDS.OLD_BEARD] = {
    outfits = {
        ["Exeggutor"] = { lookType = 2265 }
    },
    itemId = 29692,
}

ADDONS[PokemonAddon.IDS.PUMPKIN_HEAD] = {
    outfits = {
        ["Cubone"] = { lookType = 2101 }
    },
    itemId = 29693,
}

ADDONS[PokemonAddon.IDS.PUMPKIN_PACK] = {
    outfits = {
        ["Marowak"] = { lookType = 2248 }
    },
    itemId = 29694,
}

ADDONS[PokemonAddon.IDS.REAPER_COSTUME] = {
    outfits = {
        ["Marowak"] = { lookType = 2203 }
    },
    itemId = 29695,
}

ADDONS[PokemonAddon.IDS.LUNCH_PACK] = {
    outfits = {
        ["Lickitung"] = { lookType = 2277 }
    },
    itemId = 29696,
}

ADDONS[PokemonAddon.IDS.KISS_MAKEUP] = {
    outfits = {
        ["Lickitung"] = { lookType = 2285 }
    },
    itemId = 29697,
}

ADDONS[PokemonAddon.IDS.HEAVY_PIRATE_COSTUME] = {
    outfits = {
        ["Weezing"] = { lookType = 2264 }
    },
    itemId = 29698,
}

ADDONS[PokemonAddon.IDS.PIPE] = {
    outfits = {
        ["Weezing"] = { lookType = 2266 }
    },
    itemId = 29699,
}

ADDONS[PokemonAddon.IDS.HEAVY_TORN_BALL] = {
    outfits = {
        ["Rhydon"] = { lookType = 2249 }
    },
    itemId = 29700,
}

ADDONS[PokemonAddon.IDS.THORN_SHOULDER] = {
    outfits = {
        ["Rhydon"] = { lookType = 2259 }
    },
    itemId = 29701,
}

ADDONS[PokemonAddon.IDS.RED_STRIPES] = {
    outfits = {
        ["Rhydon"] = { lookType = 2258 }
    },
    itemId = 29702,
}

ADDONS[PokemonAddon.IDS.NURSE_COSTUME] = {
    outfits = {
        ["Chansey"] = { lookType = 2075 }
    },
    itemId = 29703,
}

ADDONS[PokemonAddon.IDS.WITCH_COSTUME] = {
    outfits = {
        ["Chansey"] = { lookType = 2263 }
    },
    itemId = 29704,
}

ADDONS[PokemonAddon.IDS.FAKE_FORK] = {
    outfits = {
        ["Tangela"] = { lookType = 2335 }
    },
    itemId = 29705,
}

ADDONS[PokemonAddon.IDS.JESTER_HAT] = {
    outfits = {
        ["Tangela"] = { lookType = 2336 }
    },
    itemId = 29706,
}

ADDONS[PokemonAddon.IDS.GHOST_COSTUME] = {
    outfits = {
        ["Tangela"] = { lookType = 2337 }
    },
    itemId = 29707,
}

ADDONS[PokemonAddon.IDS.COWGIRL_HAT] = {
    outfits = {
        ["Kangaskhan"] = { lookType = 2290 }
    },
    itemId = 29708,
}

ADDONS[PokemonAddon.IDS.GENTLEMAN_HAT] = {
    outfits = {
        ["Kangaskhan"] = { lookType = 2138 }
    },
    itemId = 29709,
}

ADDONS[PokemonAddon.IDS.MAGICIAN_HAT] = {
    outfits = {
        ["Mr. Mime"] = { lookType = 2201 }
    },
    itemId = 29710,
}

ADDONS[PokemonAddon.IDS.GREEN_APRON] = {
    outfits = {
        ["Mr. Mime"] = { lookType = 2200 }
    },
    itemId = 29711,
}

ADDONS[PokemonAddon.IDS.NAMEKIAN_CAPE] = {
    outfits = {
        ["Scyther"] = { lookType = 2250 }
    },
    itemId = 29712,
}

ADDONS[PokemonAddon.IDS.BLACK_CAPE] = {
    outfits = {
        ["Scyther"] = { lookType = 2320 }
    },
    itemId = 29713,
}

ADDONS[PokemonAddon.IDS.MONK_CAPE] = {
    outfits = {
        ["Scyther"] = { lookType = 2322 }
    },
    itemId = 29714,
}

ADDONS[PokemonAddon.IDS.WEDDING_DRESS] = {
    outfits = {
        ["Jynx"] = { lookType = 2275 }
    },
    itemId = 29716,
}

ADDONS[PokemonAddon.IDS.DARK_WITCH_COSTUME] = {
    outfits = {
        ["Jynx"] = { lookType = 2276 }
    },
    itemId = 29717,
}

--ADDONS[PokemonAddon.IDS.MRS_CLAUS_CLOTHES] = {
--    outfits = {
--        ["Jynx"] = { lookType = 0 }
--    },
--    itemId = 29718,
--}

ADDONS[PokemonAddon.IDS.RAIDEN_HAT] = {
    outfits = {
        ["Electabuzz"] = { lookType = 2080 }
    },
    itemId = 29719,
}

ADDONS[PokemonAddon.IDS.METAL_PACK] = {
    outfits = {
        ["Electabuzz"] = { lookType = 2079 }
    },
    itemId = 29720,
}

ADDONS[PokemonAddon.IDS.BANDIT_MASK] = {
    outfits = {
        ["Electabuzz"] = { lookType = 2078 }
    },
    itemId = 29721,
}

ADDONS[PokemonAddon.IDS.BLUE_SCOUTER] = {
    outfits = {
        ["Magmar"] = { lookType = 2084 }
    },
    itemId = 29723,
}

ADDONS[PokemonAddon.IDS.GREEN_SCOUTER] = {
    outfits = {
        ["Magmar"] = { lookType = 2281 }
    },
    itemId = 29724,
}

ADDONS[PokemonAddon.IDS.FLAMETHROW_KIT] = {
    outfits = {
        ["Magmar"] = { lookType = 2286 }
    },
    itemId = 29725,
}

--ADDONS[PokemonAddon.IDS.YELLOW_KARATE_HEADBAND] = {
--    outfits = {
--        ["Golduck"] = { lookType = 0 }
--    },
--    itemId = 29726,
--}

ADDONS[PokemonAddon.IDS.PURPLE_STRIPE] = {
    outfits = {
        ["Nidoqueen"] = { lookType = 2183 }
    },
    itemId = 29727,
}

ADDONS[PokemonAddon.IDS.BULL_BLACK_SADDLE] = {
    outfits = {
        ["Tauros"] = { lookType = 2291, ride = 2292 }
    },
    itemId = 29728,
}

ADDONS[PokemonAddon.IDS.BULL_RED_SADDLE] = {
    outfits = {
        ["Tauros"] = { lookType = 2293, ride = 2294 }
    },
    itemId = 29729,
}

ADDONS[PokemonAddon.IDS.ORIENTAL_DRAGON_MASK] = {
    outfits = {
        ["Gyarados"] = { lookType = 2338, surf = 2345 }
    },
    itemId = 29732,
}

ADDONS[PokemonAddon.IDS.RED_DRAGON_MASK] = {
    outfits = {
        ["Gyarados"] = { lookType = 2340, surf = 2347 }
    },
    itemId = 29733,
}

ADDONS[PokemonAddon.IDS.RETRO_DRAGON_MASK] = {
    outfits = {
        ["Gyarados"] = { lookType = 2339, surf = 2346 }
    },
    itemId = 29734,
}

ADDONS[PokemonAddon.IDS.WATER_PENDANT] = {
    outfits = {
        ["Lapras"] = { lookType = 2308, surf = 2313 }
    },
    itemId = 29735,
}

ADDONS[PokemonAddon.IDS.PEARL_NECKLACE] = {
    outfits = {
        ["Lapras"] = { lookType = 2307, surf = 2312 }
    },
    itemId = 29736,
}

ADDONS[PokemonAddon.IDS.PINK_SHELL] = {
    outfits = {
        ["Lapras"] = { lookType = 2309, surf = 2314 }
    },
    itemId = 29737,
}

ADDONS[PokemonAddon.IDS.YELLOW_SHELL] = {
    outfits = {
        ["Lapras"] = { lookType = 2310, surf = 2315 }
    },
    itemId = 29738,
}

ADDONS[PokemonAddon.IDS.DARK_PENDANT] = {
    outfits = {
        ["Lapras"] = { lookType = 2311, surf = 2316 }
    },
    itemId = 29739,
}

ADDONS[PokemonAddon.IDS.CLASSIC_VAMPIRE_COSTUME] = {
    outfits = {
        ["Kabutops"] = { lookType = 2329, surf = 2332 }
    },
    itemId = 29742,
}

ADDONS[PokemonAddon.IDS.VAMPIRE_COSTUME] = {
    outfits = {
        ["Kabutops"] = { lookType = 2326, surf = 2331 }
    },
    itemId = 29743,
}

ADDONS[PokemonAddon.IDS.RED_CAPE] = {
    outfits = {
        ["Kabutops"] = { lookType = 2330, surf = 2333 }
    },
    itemId = 29744,
}

ADDONS[PokemonAddon.IDS.PARTY_CAP] = {
    outfits = {
        ["Omastar"] = { lookType = 2327 }
    },
    itemId = 29745,
}

ADDONS[PokemonAddon.IDS.STAR_GLASSES] = {
    outfits = {
        ["Omastar"] = { lookType = 2328, surf = 2334 }
    },
    itemId = 29746,
}

ADDONS[PokemonAddon.IDS.CHEF_COSTUME] = {
    outfits = {
        ["Snorlax"] = { lookType = 2317 }
    },
    itemId = 29747,
}

ADDONS[PokemonAddon.IDS.OBELIX_COSTUME] = {
    outfits = {
        ["Snorlax"] = { lookType = 2288 }
    },
    itemId = 29748,
}

ADDONS[PokemonAddon.IDS.BEAR_CAP] = {
    outfits = {
        ["Snorlax"] = { lookType = 2348 }
    },
    itemId = 29749,
}

ADDONS[PokemonAddon.IDS.POLAR_BEAR_CAP] = {
    outfits = {
        ["Snorlax"] = { lookType = 2350 }
    },
    itemId = 29750,
}

ADDONS[PokemonAddon.IDS.RED_DRAGON_SCARF] = {
    outfits = {
        ["Dragonite"] = { lookType = 2301, fly = 2302 }
    },
    itemId = 29751,
}

ADDONS[PokemonAddon.IDS.GREEN_DRAGON_SCARF] = {
    outfits = {
        ["Dragonite"] = { lookType = 2303, fly = 2304 }
    },
    itemId = 29752,
}

ADDONS[PokemonAddon.IDS.YELLOW_DRAGON_SCARF] = {
    outfits = {
        ["Dragonite"] = { lookType = 2305, fly = 2306 }
    },
    itemId = 29753,
}

ADDONS[PokemonAddon.IDS.RED_POSTMAN_BAG] = {
    outfits = {
        ["Dragonite"] = { lookType = 2299, fly = 2300 }
    },
    itemId = 29754,
}

ADDONS[PokemonAddon.IDS.BLUE_POSTMAN_BAG] = {
    outfits = {
        ["Dragonite"] = { lookType = 2295, fly = 2296 }
    },
    itemId = 29755,
}

ADDONS[PokemonAddon.IDS.GRAY_POSTMAN_BAG] = {
    outfits = {
        ["Dragonite"] = { lookType = 2297, fly = 2298 }
    },
    itemId = 29756,
}

--ADDONS[PokemonAddon.IDS.BLACK_CAPE] = {
--    outfits = {
--        ["Elite Hitmonlee"] = { lookType = 0 }
--    },
--    itemId = 29757,
--}

--ADDONS[PokemonAddon.IDS.RED_TAEK_HEADBAND] = {
--    outfits = {
--        ["Elite Hitmonlee"] = { lookType = 0 }
--    },
--    itemId = 29758,
--}

--ADDONS[PokemonAddon.IDS.BLUE_TAEK_HEADBAND] = {
--    outfits = {
--        ["Elite Hitmonlee"] = { lookType = 0 }
--    },
--    itemId = 29759,
--}

--ADDONS[PokemonAddon.IDS.WHITE_HEADBAND] = {
--    outfits = {
--        ["Elite Hitmonchan"] = { lookType = 0 }
--    },
--    itemId = 29761,
--}

--ADDONS[PokemonAddon.IDS.FIRE_SAMURAI_ARMOR] = {
--    outfits = {
--        ["Shiny Flareon"] = { lookType = 0 }
--    },
--    itemId = 29763,
--}

--ADDONS[PokemonAddon.IDS.SPIKES] = {
--    outfits = {
--        ["Shiny Golem"] = { lookType = 0 }
--    },
--    itemId = 29766,
--}

--ADDONS[PokemonAddon.IDS.THUNDER_SAMURAI_ARMOR] = {
--    outfits = {
--        ["Shiny Jolteon"] = { lookType = 0 }
--    },
--    itemId = 29767,
--}

--ADDONS[PokemonAddon.IDS.MURMILO_HELMET] = {
--    outfits = {
--        ["Shiny Nidoking"] = { lookType = 0 }
--    },
--    itemId = 29768,
--}

ADDONS[PokemonAddon.IDS.BANE_COSTUME] = {
    outfits = {
        ["Machamp"] = { lookType = 2413 }
    },
    itemId = 29773,
}

--ADDONS[PokemonAddon.IDS.BATSUIT] = {
--    outfits = {
--        ["Elite Hitmonchan"] = { lookType = 0 }
--    },
--    itemId = 29776,
--}

--ADDONS[PokemonAddon.IDS.RASTAFARI] = {
--    outfits = {
--        ["Shiny Vileplume"] = { lookType = 0 }
--    },
--    itemId = 29777,
--}

--ADDONS[PokemonAddon.IDS.BABY_BOTTLE] = {
--    outfits = {
--        ["Dragonite"] = { lookType = 0 }
--    },
--    itemId = 29778,
--}

ADDONS[PokemonAddon.IDS.COW_SUIT] = {
    outfits = {
        ["Miltank"] = { lookType = 2422 }
    },
    itemId = 29782,
}

--ADDONS[PokemonAddon.IDS.COW_SADDLE] = {
--    outfits = {
--        ["Miltank"] = { lookType = 2424 }
--    },
--    itemId = 29783,
--}

ADDONS[PokemonAddon.IDS.ILLIDAN_COSTUME] = {
    outfits = {
        ["Scizor"] = { lookType = 2534 }
    },
    itemId = 29784,
}

ADDONS[PokemonAddon.IDS.GUITAR_PLAYER] = {
    outfits = {
        ["Electabuzz"] = { lookType = 2428 }
    },
    itemId = 29785,
}

ADDONS[PokemonAddon.IDS.FLAT_IRON] = {
    outfits = {
        ["Gardevoir"] = { lookType = 2429 }
    },
    itemId = 29786,
}

ADDONS[PokemonAddon.IDS.MAGMAR_IRON_MASK] = {
    outfits = {
        ["Magmar"] = { lookType = 2430 }
    },
    itemId = 29787,
}

ADDONS[PokemonAddon.IDS.SAYAN_ARMOR] = {
    outfits = {
        ["Swampert"] = { lookType = 2436 }
    },
    itemId = 29788,
}

ADDONS[PokemonAddon.IDS.TRANSFORMER_ARMOR] = {
    outfits = {
        ["Tyranitar"] = { lookType = 2437 }
    },
    itemId = 29789,
}

ADDONS[PokemonAddon.IDS.RYU_COSTUME] = {
    outfits = {
        ["Heracross"] = { lookType = 2442, fly = 2444 }
    },
    itemId = 29791,
}

ADDONS[PokemonAddon.IDS.KEN_COSTUME] = {
    outfits = {
        ["Heracross"] = { lookType = 2443, fly = 2446 }
    },
    itemId = 29792,
}

ADDONS[PokemonAddon.IDS.COWGIRL_COSTUME] = {
    outfits = {
        ["Miltank"] = { lookType = 2426 }
    },
    itemId = 29793,
}

ADDONS[PokemonAddon.IDS.FARMER_COSTUME] = {
    outfits = {
        ["Miltank"] = { lookType = 2424 }
    },
    itemId = 29794,
}

--ADDONS[PokemonAddon.IDS.SANTA_CLAUS_COSTUME] = {
--    outfits = {
--        ["Snorlax"] = { lookType = 0 }
--    },
--    itemId = 29796,
--}

ADDONS[PokemonAddon.IDS.LORD_IRON_MASK] = {
    outfits = {
        ["Manectric"] = { lookType = 2452, ride = 2453 }
    },
    itemId = 29797,
}

ADDONS[PokemonAddon.IDS.ELDER_IRON_MASK] = {
    outfits = {
        ["Manectric"] = { lookType = 2450, ride = 2451 }
    },
    itemId = 29798,
}

ADDONS[PokemonAddon.IDS.RED_DYNOMUTT_COSTUME] = {
    outfits = {
        ["Houndoom"] = { lookType = 2455, ride = 2456 }
    },
    itemId = 29799,
}

ADDONS[PokemonAddon.IDS.DYNOMUTT_COSTUME] = {
    outfits = {
        ["Houndoom"] = { lookType = 2448, ride = 2449 }
    },
    itemId = 29800,
}

ADDONS[PokemonAddon.IDS.PIRATE_EMPRESS_RED_DRESS] = {
    outfits = {
        ["Gardevoir"] = { lookType = 2438 }
    },
    itemId = 29801,
}

ADDONS[PokemonAddon.IDS.PIRATE_EMPRESS_BLUE_DRESS] = {
    outfits = {
        ["Gardevoir"] = { lookType = 2439 }
    },
    itemId = 29802,
}

ADDONS[PokemonAddon.IDS.POKEMON_TRAINER_COSTUME] = {
    outfits = {
        ["Typhlosion"] = { lookType = 2468 }
    },
    itemId = 29804,
}

--ADDONS[PokemonAddon.IDS.CHAVES_COSTUME] = {
--    outfits = {
--        [""] = { lookType = 0 }
--    },
--    itemId = 29805,
--}

ADDONS[PokemonAddon.IDS.NINJA_COSTUME] = {
    outfits = {
        ["Typhlosion"] = { lookType = 2466 }
    },
    itemId = 29806,
}

ADDONS[PokemonAddon.IDS.CLAN_COSTUME] = {
    outfits = {
        ["Typhlosion"] = { lookType = 2467 }
    },
    itemId = 29807,
}

ADDONS[PokemonAddon.IDS.SAILOR_COSTUME] = {
    outfits = {
        ["Meganium"] = { lookType = 2465, ride = 2469 }
    },
    itemId = 29808,
}

ADDONS[PokemonAddon.IDS.HUNTER_COSTUME] = {
    outfits = {
        ["Feraligatr"] = { lookType = 2457, surf = 2475 }
    },
    itemId = 29810,
}

ADDONS[PokemonAddon.IDS.LIFE_JACKET] = {
    outfits = {
        ["Feraligatr"] = { lookType = 2461, surf = 2470 }
    },
    itemId = 29811,
}

ADDONS[PokemonAddon.IDS.TITANIUM_ARMOR] = {
    outfits = {
        ["Feraligatr"] = { lookType = 2462, surf = 2471 }
    },
    itemId = 29812,
}

--ADDONS[PokemonAddon.IDS.ADDON] = {
--    outfits = {
--        [""] = { lookType = 0 }
--    },
--    itemId = 29813,
--}

ADDONS[PokemonAddon.IDS.SEA_KNIGHT_COSTUME] = {
    outfits = {
        ["Feraligatr"] = { lookType = 2464, surf = 2474 }
    },
    itemId = 29814,
}

ADDONS[PokemonAddon.IDS.LIFESAVER_COSTUME] = {
    outfits = {
        ["Feraligatr"] = { lookType = 2458, surf = 2472 }
    },
    itemId = 29815,
}

ADDONS[PokemonAddon.IDS.ROYAL_ARMOR] = {
    outfits = {
        ["Aggron"] = { lookType = 2483 }
    },
    itemId = 29818,
}

ADDONS[PokemonAddon.IDS.BOO_COSTUME] = {
    outfits = {
        ["Blissey"] = { lookType = 2480 }
    },
    itemId = 29819,
}

ADDONS[PokemonAddon.IDS.NURSE_COSTUME] = {
    outfits = {
        ["Blissey"] = { lookType = 2479 }
    },
    itemId = 29820,
}

ADDONS[PokemonAddon.IDS.FLOWER_COSTUME] = {
    outfits = {
        ["Blissey"] = { lookType = 2477 }
    },
    itemId = 29821,
}

ADDONS[PokemonAddon.IDS.CYBER_MASK] = {
    outfits = {
        ["Crobat"] = { lookType = 2481 }
    },
    itemId = 29822,
}

ADDONS[PokemonAddon.IDS.PARASITE_COSTUME] = {
    outfits = {
        ["Crobat"] = { lookType = 2482 }
    },
    itemId = 29823,
}

ADDONS[PokemonAddon.IDS.TANUKI_HAT] = {
    outfits = {
        ["Ursaring"] = { lookType = 2491 }
    },
    itemId = 29825,
}

ADDONS[PokemonAddon.IDS.FOSSILZED_KABUTOPS] = {
    outfits = {
        ["Kabutops"] = { lookType = 2496, surf = 2498 }
    },
    itemId = 29826,
}

ADDONS[PokemonAddon.IDS.FOSSILZED_AERODACTYL] = {
    outfits = {
        ["Aerodactyl"] = { lookType = 2494, fly = 2495 }
    },
    itemId = 29827,
}

--ADDONS[PokemonAddon.IDS.FOSSILZED_BASTIODON] = {
--    outfits = {
--        ["Bastiodon"] = { lookType = 0 }
--    },
--    itemId = 29828,
--}

ADDONS[PokemonAddon.IDS.FOSSILZED_ARMALDO] = {
    outfits = {
        ["Armaldo"] = { lookType = 2497 }
    },
    itemId = 29829,
}

ADDONS[PokemonAddon.IDS.FOSSILZED_OMASTAR] = {
    outfits = {
        ["Omastar"] = { lookType = 2478, surf = 2499 }
    },
    itemId = 29830,
}

ADDONS[PokemonAddon.IDS.FOSSILZED_KABUTO] = {
    outfits = {
        ["Kabuto"] = { lookType = 2500 }
    },
    itemId = 29831,
}

ADDONS[PokemonAddon.IDS.FOSSILZED_OMANYTE] = {
    outfits = {
        ["Omanyte"] = { lookType = 2501 }
    },
    itemId = 29832,
}

ADDONS[PokemonAddon.IDS.UKULELE_PLAYER] = {
    outfits = {
        ["Ludicolo"] = { lookType = 2502, surf = 2504 }
    },
    itemId = 29833,
}

ADDONS[PokemonAddon.IDS.EVIL_ILLIDAN_COSTUME] = {
    outfits = {
        ["Scizor"] = { lookType = 2505 }
    },
    itemId = 29834,
}

ADDONS[PokemonAddon.IDS.LUFFY_COSTUME] = {
    outfits = {
        ["Smeargle"] = { lookType = 2507 }
    },
    itemId = 29835,
}

ADDONS[PokemonAddon.IDS.MAFIA_CAP] = {
    outfits = {
        ["Smeargle"] = { lookType = 2506 }
    },
    itemId = 29836,
}

ADDONS[PokemonAddon.IDS.SANTORYU_COSTUME] = {
    outfits = {
        ["Scyther"] = { lookType = 2512 }
    },
    itemId = 29837,
}

--ADDONS[PokemonAddon.IDS.POWER_TOPAZ] = {
--    outfits = {
--        ["Brozong"] = { lookType = 0 }
--    },
--    itemId = 29839,
--}

--ADDONS[PokemonAddon.IDS.POWER_EMERALD] = {
--    outfits = {
--        ["Brozong"] = { lookType = 0 }
--    },
--    itemId = 29840,
--}

--ADDONS[PokemonAddon.IDS.POWER_RUBY] = {
--    outfits = {
--        ["Brozong"] = { lookType = 0 }
--    },
--    itemId = 29841,
--}

ADDONS[PokemonAddon.IDS.SACK] = {
    outfits = {
        ["Medicham"] = { lookType = 2537 }
    },
    itemId = 29842,
}

ADDONS[PokemonAddon.IDS.SUPERHERO_COSTUME] = {
    outfits = {
        ["Ampharos"] = { lookType = 2513 }
    },
    itemId = 29845,
}

ADDONS[PokemonAddon.IDS.TRIBAL_HEADDRESS] = {
    outfits = {
        ["Xatu"] = { lookType = 2523, fly = 2525 }
    },
    itemId = 29846,
}

ADDONS[PokemonAddon.IDS.HANNYA_MASK] = {
    outfits = {
        ["Steelix"] = { lookType = 2526, ride = 2527 }
    },
    itemId = 29847,
}

ADDONS[PokemonAddon.IDS.SKARMORY_BATTLE_ARMOR] = {
    outfits = {
        ["Skarmory"] = { lookType = 2372, fly = 2373 }
    },
    itemId = 29848,
}

ADDONS[PokemonAddon.IDS.KINGDRA_BATTLE_ARMOR] = {
    outfits = {
        ["Kingdra"] = { lookType = 2374, surf = 2375 }
    },
    itemId = 29849,
}

ADDONS[PokemonAddon.IDS.BATTLE_ARMOR] = {
    outfits = {
        ["Arcanine"] = { lookType = 2370, ride = 2371 }
    },
    itemId = 29850,
}

ADDONS[PokemonAddon.IDS.MERCENARY_MASK] = {
    outfits = {
        ["Scizor"] = { lookType = 2369 }
    },
    itemId = 29852,
}

ADDONS[PokemonAddon.IDS.SILVER_NINJA_COSTUME] = {
    outfits = {
        ["Blastoise"] = { lookType = 2376, surf = 2377 }
    },
    itemId = 29853,
}

ADDONS[PokemonAddon.IDS.GREYBEARD_COSTUME] = {
    outfits = {
        ["Slowking"] = { lookType = 2380 }
    },
    itemId = 29855,
}

ADDONS[PokemonAddon.IDS.METALIC_PACK] = {
    outfits = {
        ["Girafarig"] = { lookType = 2384, ride = 2385 }
    },
    itemId = 29856,
}

ADDONS[PokemonAddon.IDS.CHARIZARD_BATTLE_ARMOR] = {
    outfits = {
        ["Charizard"] = { lookType = 2382, fly = 2383 }
    },
    itemId = 29857,
}

ADDONS[PokemonAddon.IDS.SUPERHERO_CAPE] = {
    outfits = {
        ["Sudowoodo"] = { lookType = 2386 }
    },
    itemId = 29858,
}

ADDONS[PokemonAddon.IDS.NINJA_CLOTHES] = {
    outfits = {
        ["Scizor"] = { lookType = 2409 }
    },
    itemId = 29859,
}

ADDONS[PokemonAddon.IDS.MECHANICAL_CLOTHES] = {
    outfits = {
        ["Exeggutor"] = { lookType = 2404 }
    },
    itemId = 29860,
}

ADDONS[PokemonAddon.IDS.GENTLEMAN_CLOTHES] = {
    outfits = {
        ["Golduck"] = { lookType = 2403, surf = 2408 }
    },
    itemId = 29861,
}

ADDONS[PokemonAddon.IDS.IRON_JAW] = {
    outfits = {
        ["Steelix"] = { lookType = 2405, ride = 2406 }
    },
    itemId = 29862,
}

ADDONS[PokemonAddon.IDS.LEONCIO_COSTUME] = {
    outfits = {
        ["Snorlax"] = { lookType = 2707}
    },
    itemId = 34771,
}

ADDONS[PokemonAddon.IDS.BEAR_COSTUME] = {
    outfits = {
        ["Snorlax"] = { lookType = 2709}
    },
    itemId = 34772,
}

ADDONS[PokemonAddon.IDS.ICE_BEAR_COSTUME] = {
    outfits = {
        ["Snorlax"] = { lookType = 2710}
    },
    itemId = 34773,
}

ADDONS[PokemonAddon.IDS.BATTLE_ARMOR] = {
    outfits = {
        ["Arcanine"] = { lookType = 2747, ride = 2759 }
    },
    itemId = 34774,
}

ADDONS[PokemonAddon.IDS.DJ_COSTUME] = {
    outfits = {
        ["Gengar"] = { lookType = 2743, levitate = 2764 }
    },
    itemId = 34775,
}

ADDONS[PokemonAddon.IDS.COWBOY_COSTUME] = {
    outfits = {
        ["Kangaskhan"] = { lookType = 2708}
    },
    itemId = 34776,
}

ADDONS[PokemonAddon.IDS.ADVENTUROUS_PIRATE] = {
    outfits = {
        ["Ninetales"] = { lookType = 2726, ride = 2727}
    },
    itemId = 34777,
}

ADDONS[PokemonAddon.IDS.ANCIENT] = {
    outfits = {
        ["Magneton"] = { lookType = 2702}
    },
    itemId = 34778,
}

ADDONS[PokemonAddon.IDS.ARMOR_CORE] = {
    outfits = {
        ["Arcanine"] = { lookType = 2746, ride = 2758}
    },
    itemId = 34779,
}

ADDONS[PokemonAddon.IDS.BLACK_ADAM_COSTUME] = {
    outfits = {
        ["Electabuzz"] = { lookType = 2749}
    },
    itemId = 34780,
}

ADDONS[PokemonAddon.IDS.SHAZAM_COSTUME] = {
    outfits = {
        ["Electabuzz"] = { lookType = 2748}
    },
    itemId = 34781,
}

ADDONS[PokemonAddon.IDS.BLUE_FLAMES_MAGE] = {
    outfits = {
        ["Ninetales"] = { lookType = 2724, ride = 2725}
    },
    itemId = 34782,
}

ADDONS[PokemonAddon.IDS.FIRE_MAGE] = {
    outfits = {
        ["Ninetales"] = { lookType = 2730, ride = 2731}
    },
    itemId = 34783,
}

ADDONS[PokemonAddon.IDS.CYBORG_ARMOR1] = {
    outfits = {
        ["Venusaur"] = { lookType = 2722, ride = 2723}
    },
    itemId = 34784,
}

ADDONS[PokemonAddon.IDS.CYBORG_ARMOR2] = {
    outfits = {
        ["Blastoise"] = { lookType = 2720, surf = 2721}
    },
    itemId = 34785,
}

ADDONS[PokemonAddon.IDS.CYBORG_ARMOR3] = {
    outfits = {
        ["Charizard"] = { lookType = 2718, fly = 2719}
    },
    itemId = 34786,
}

ADDONS[PokemonAddon.IDS.CYBORG_ARMOR4] = {
    outfits = {
        ["Machoke"] = { lookType = 2742}
    },
    itemId = 34787,
}

ADDONS[PokemonAddon.IDS.CYBORG_ARMOR5] = {
    outfits = {
        ["Machamp"] = { lookType = 2741}
    },
    itemId = 34788,
}

ADDONS[PokemonAddon.IDS.DEFINITELY_NOT_MAGIKARP] = {
    outfits = {
        ["Magikarp"] = { lookType = 2755}
    },
    itemId = 34789,
}

ADDONS[PokemonAddon.IDS.FLASH_COSTUME] = {
    outfits = {
        ["Raichu"] = { lookType = 2767}
    },
    itemId = 34790,
}

ADDONS[PokemonAddon.IDS.FLINSTONE] = {
    outfits = {
        ["Rhydon"] = { lookType = 2700}
    },
    itemId = 34791,
}

ADDONS[PokemonAddon.IDS.GENIUS] = {
    outfits = {
        ["Machamp"] = { lookType = 2754}
    },
    itemId = 34792,
}

ADDONS[PokemonAddon.IDS.GIRL_POWER] = {
    outfits = {
        ["Clefable"] = { lookType = 2750}
    },
    itemId = 34793,
}

ADDONS[PokemonAddon.IDS.GUARD] = {
    outfits = {
        ["Rhydon"] = { lookType = 2701}
    },
    itemId = 34794,
}

ADDONS[PokemonAddon.IDS.GUARDIAN_ARMOR] = {
    outfits = {
        ["Charizard"] = { lookType = 2711, fly = 2712}
    },
    itemId = 34795,
}

ADDONS[PokemonAddon.IDS.HAPPY_OCTOPUS_COSTUME] = {
    outfits = {
        ["Flareon"] = { lookType = 2765}
    },
    itemId = 34796,
}

ADDONS[PokemonAddon.IDS.LANCES_CLOTHES] = {
    outfits = {
        ["Dragonite"] = { lookType = 2760, fly = 2761}
    },
    itemId = 34797,
}

ADDONS[PokemonAddon.IDS.MALEVOLA_COSTUME] = {
    outfits = {
        ["Lapras"] = { lookType = 2716, surf = 2717}
    },
    itemId = 34798,
}

ADDONS[PokemonAddon.IDS.MARIO_COSTUME] = {
    outfits = {
        ["Exeggutor"] = { lookType = 2715}
    },
    itemId = 34799,
}

ADDONS[PokemonAddon.IDS.OCTOPUS_COSTUME] = {
    outfits = {
        ["Jolteon"] = { lookType = 2766}
    },
    itemId = 34800,
}

ADDONS[PokemonAddon.IDS.PEAKY_BLINDERS_COSTUME1] = {
    outfits = {
        ["Mr. Mime"] = { lookType = 2705}
    },
    itemId = 34801,
}

ADDONS[PokemonAddon.IDS.PEAKY_BLINDERS_COSTUME2] = {
    outfits = {
        ["Golduck"] = { lookType = 2713, surf = 2714}
    },
    itemId = 34802,
}

ADDONS[PokemonAddon.IDS.PUFFER_FISH_COSTUME] = {
    outfits = {
        ["Vaporeon"] = { lookType = 2762, surf = 2763}
    },
    itemId = 34803,
}

ADDONS[PokemonAddon.IDS.YAKUZA_COSTUME] = {
    outfits = {
        ["Lickitung"] = { lookType = 2745 }
    },
    itemId = 34805,
}

ADDONS[PokemonAddon.IDS.WONDER_WOMAN] = {
    outfits = {
        ["Nidoqueen"] = { lookType = 2756 }
    },
    itemId = 34806,
}

ADDONS[PokemonAddon.IDS.WORD_CHAMPION_ROBE] = {
    outfits = {
        ["Machamp"] = { lookType = 2753 }
    },
    itemId = 34807,
}

ADDONS[PokemonAddon.IDS.THOR_COSTUME] = {
    outfits = {
        ["Electabuzz"] = { lookType = 2740 }
    },
    itemId = 34808,
}

ADDONS[PokemonAddon.IDS.RYUJIN_COSTUME] = {
    outfits = {
        ["Gyarados"] = { lookType = 2751, surf = 2752 }
    },
    itemId = 34809,
}

ADDONS[PokemonAddon.IDS.SERPENT_ARMOR] = {
    outfits = {
        ["Giant Onix"] = { lookType = 2757}
    },
    itemId = 34810,
}

ADDONS[PokemonAddon.IDS.TROPICAL_COSTUME] = {
    outfits = {
        ["Exeggutor"] = { lookType = 2744}
    },
    itemId = 34811,
}

ADDONS[PokemonAddon.IDS.CYBORG_ARMOR6] = {
    outfits = {
        ["Aerodactyl"] = { lookType = 2728, fly = 2729}
    },
    itemId = 34812,
}

ADDONS[PokemonAddon.IDS.ROCKSTAR] = {
    outfits = {
        ["Electabuzz"] = { lookType = 2738 }
    },
    itemId = 34813,
}

ADDONS[PokemonAddon.IDS.METAL_ARMOR] = {
    outfits = {
        ["Magmar"] = { lookType = 2430 }
    },
    itemId = 34814,
}

ADDONS[PokemonAddon.IDS.ROBOT_UNICORN] = {
    outfits = {
        ["Rapidash"] = { lookType = 2736, ride = 2737 }
    },
    itemId = 34815,
}

ADDONS[PokemonAddon.IDS.PEGASUS_COSTUME] = {
    outfits = {
        ["Rapidash"] = { lookType = 2734, ride = 2735 }
    },
    itemId = 34816,
}

ADDONS[PokemonAddon.IDS.DEATH_UNICORN] = {
    outfits = {
        ["Rapidash"] = { lookType = 2732, ride = 2733 }
    },
    itemId = 34817,
}

ADDONS[PokemonAddon.IDS.DEATH] = {
    outfits = {
        ["Marowak"] = { lookType = 2706 }
    },
    itemId = 34818,
}

ADDONS[PokemonAddon.IDS.CYBORG_ARMOR7] = {
    outfits = {
        ["Ninetales"] = { lookType = 2703, ride = 2704 }
    },
    itemId = 34819,
}

--ADDONS_SHINY

ADDONS[PokemonAddon.IDS.MILLNENNIUM_INSPIRATION] = {
    outfits = {
        ["Shiny Magneton"] = { lookType = 2843}
    },
    itemId = 34872,
}
ADDONS[PokemonAddon.IDS.SUPREME_DEITY] = {
    outfits = {
        ["Shiny Dodrio"] = { lookType = 2844 , ride = 2845 }
    },
    itemId = 34873,
}
ADDONS[PokemonAddon.IDS.BLACK_RAVEN] = {
    outfits = {
        ["Shiny Fearow"] = { lookType = 2781, fly = 2780}
    },
    itemId = 34827,
}
ADDONS[PokemonAddon.IDS.DIAMOND_FURY] = {
    outfits = {
        ["Shiny Onix"] = { lookType = 2834, ride = 2835}
    },
    itemId = 34864,
}
ADDONS[PokemonAddon.IDS.ALDEBARAN_COSTUME] = {
    outfits = {
        ["Shiny Rhydon"] = { lookType = 2836}
    },
    itemId = 34865,
}
ADDONS[PokemonAddon.IDS.BABY_KURAMA] = {
    outfits = {
        ["Shiny Ninetales"] = { lookType = 2828, ride = 2829 }
    },
    itemId = 34861,
}
ADDONS[PokemonAddon.IDS.SHINY_CYBORG_ARMOR1] = {
    outfits = {
        ["Shiny Charizard"] = { lookType = 2770, fly = 2771}
    },
    itemId = 34822,
}
ADDONS[PokemonAddon.IDS.SHINY_CYBORG_ARMOR2] = {
    outfits = {
        ["Shiny Snorlax"] = { lookType = 2772 }
    },
    itemId = 34823,
}
ADDONS[PokemonAddon.IDS.SHINY_CYBORG_ARMOR3] = {
    outfits = {
        ["Shiny Rhydon"] = { lookType = 2773 }
    },
    itemId = 34824,
}
ADDONS[PokemonAddon.IDS.SHINY_CYBORG_ARMOR4] = {
    outfits = {
        ["Shiny Onix"] = { lookType = 2774, ride = 2775}
    },
    itemId = 34825,
}
ADDONS[PokemonAddon.IDS.SHINY_CYBORG_ARMOR5] = {
    outfits = {
        ["Shiny Dodrio"] = { lookType = 2778, ride = 2779}
    },
    itemId = 34826,
}
ADDONS[PokemonAddon.IDS.SHINY_CYBORG_ARMOR6] = {
    outfits = {
        ["Shiny Golduck"] = { lookType = 2790, surf = 2791}
    },
    itemId = 34835,
}
ADDONS[PokemonAddon.IDS.DEATH_COSTUME] = {
    outfits = {
        ["Shiny Marowak"] = { lookType = 2787 }
    },
    itemId = 34832,
}
ADDONS[PokemonAddon.IDS.DEMON_COSTUME] = {
    outfits = {
        ["Shiny Marowak"] = { lookType = 2788 }
    },
    itemId = 34833,
}
ADDONS[PokemonAddon.IDS.ANGEL_COSTUME] = {
    outfits = {
        ["Shiny Marowak"] = { lookType = 2789}
    },
    itemId = 34834,
}
ADDONS[PokemonAddon.IDS.JIGSAW_COSTUME] = {
    outfits = {
        ["Shiny Hypno"] = { lookType = 2803 }
    },
    itemId = 34846,
}
ADDONS[PokemonAddon.IDS.JOKER_COSTUME] = {
    outfits = {
        ["Shiny Hypno"] = { lookType = 2804}
    },
    itemId = 34874,
}
ADDONS[PokemonAddon.IDS.THORN_ARMOR] = {
    outfits = {
        ["Shiny Golem"] = { lookType = 2809 }
    },
    itemId = 34850,
}
ADDONS[PokemonAddon.IDS.SHINY_METAL_ARMOR1] = {
    outfits = {
        ["Shiny Nidoking"] = { lookType = 2811 }
    },
    itemId = 34830,
}
ADDONS[PokemonAddon.IDS.SHINY_METAL_ARMOR2] = {
    outfits = {
        ["Shiny Fearow"] = { lookType = 2812, fly = 2813}
    },
    itemId = 34831,
}
ADDONS[PokemonAddon.IDS.SHINY_METAL_ARMOR3] = {
    outfits = {
        ["Shiny Flareon"] = { lookType = 2805 }
    },
    itemId = 34847,
}
ADDONS[PokemonAddon.IDS.SHINY_METAL_ARMOR4] = {
    outfits = {
        ["Shiny Jolteon"] = { lookType = 2806 }
    },
    itemId = 34848,
}
ADDONS[PokemonAddon.IDS.SHINY_METAL_ARMOR5] = {
    outfits = {
        ["Shiny Vaporeon"] = { lookType = 2807, surf = 2808 }
    },
    itemId = 34849,
}
ADDONS[PokemonAddon.IDS.TERMINATOR] = {
    outfits = {
        ["Shiny Rhydon"] = { lookType = 2839}
    },
    itemId = 34868,
}
ADDONS[PokemonAddon.IDS.REGGAE_COSTUME] = {
    outfits = {
        ["Shiny Vileplume"] = { lookType = 2783}
    },
    itemId = 34829,
}
ADDONS[PokemonAddon.IDS.MATLACHINES] = {
    outfits = {
        ["Shiny Vileplume"] = { lookType = 2782}
    },
    itemId = 34828,
}
ADDONS[PokemonAddon.IDS.VAMPIRE_COSTUME1] = {
    outfits = {
        ["Shiny Flareon"] = { lookType = 2792 }
    },
    itemId = 34836,
}
ADDONS[PokemonAddon.IDS.VAMPIRE_COSTUME2] = {
    outfits = {
        ["Shiny Jolteon"] = { lookType = 2793 }
    },
    itemId = 34837,
}
ADDONS[PokemonAddon.IDS.WITCH_COSTUME1] = {
    outfits = {
        ["Shiny Vaporeon"] = { lookType = 2794, surf = 2795}
    },
    itemId = 34838,
}
ADDONS[PokemonAddon.IDS.PANIC_COSTUME] = {
    outfits = {
        ["Shiny Hypno"] = { lookType = 2796 }
    },
    itemId = 34839,
}
ADDONS[PokemonAddon.IDS.WEREWOLF_COSTUME] = {
    outfits = {
        ["Shiny Nidoking"] = { lookType = 2797}
    },
    itemId = 34840,
}
ADDONS[PokemonAddon.IDS.ZOMBIE_COSTUME] = {
    outfits = {
        ["Shiny Vileplume"] = { lookType = 2798}
    },
    itemId = 34841,
}
ADDONS[PokemonAddon.IDS.DEATH_SKULL] = {
    outfits = {
        ["Shiny Golem"] = { lookType = 2799}
    },
    itemId = 34842,
}
ADDONS[PokemonAddon.IDS.ALPHA_WEREWOLF_COSTUME] = {
    outfits = {
        ["Shiny Nidoking"] = { lookType = 2800}
    },
    itemId = 34843,
}
ADDONS[PokemonAddon.IDS.JASON_COSTUME] = {
    outfits = {
        ["Shiny Machamp"] = { lookType = 2801}
    },
    itemId = 34844,
}
ADDONS[PokemonAddon.IDS.BATMAN_COSTUME] = {
    outfits = {
        ["Shiny Hitmonchan"] = { lookType = 2802 }
    },
    itemId = 34845,
}
ADDONS[PokemonAddon.IDS.SHINY_COWBOY_COSTUME] = {
    outfits = {
        ["Shiny Alakazam"] = { lookType = 2814}
    },
    itemId = 34851,
}
ADDONS[PokemonAddon.IDS.BONE_ARMOR] = {
    outfits = {
        ["Shiny Alakazam"] = { lookType = 2815}
    },
    itemId = 34852,
}
ADDONS[PokemonAddon.IDS.ANBU_MASK] = {
    outfits = {
        ["Shiny Exeggutor"] = { lookType = 2816}
    },
    itemId = 34853,
}
ADDONS[PokemonAddon.IDS.WITCH_COSTUME2] = {
    outfits = {
        ["Shiny Jynx"] = { lookType = 2817}
    },
    itemId = 34854,
}
ADDONS[PokemonAddon.IDS.BRIDE_COSTUME] = {
    outfits = {
        ["Shiny Jynx"] = { lookType = 2818}
    },
    itemId = 34855,
}
ADDONS[PokemonAddon.IDS.BEAR_COAT] = {
    outfits = {
        ["Shiny Kangaskhan"] = { lookType = 2819}
    },
    itemId = 34856,
}
ADDONS[PokemonAddon.IDS.ENJOYING_SUMMER1] = {
    outfits = {
        ["Shiny Fearow"] = { lookType = 2820, fly = 2821}
    },
    itemId = 34857,
}
ADDONS[PokemonAddon.IDS.ENJOYING_SUMMER2] = {
    outfits = {
        ["Shiny Golem"] = { lookType = 2822}
    },
    itemId = 34858,
}
ADDONS[PokemonAddon.IDS.MOON_FAIRY] = {
    outfits = {
        ["Shiny Ninetales"] = { lookType = 2824, ride = 2825}
    },
    itemId = 34859,
}
ADDONS[PokemonAddon.IDS.KYUBIMON_COSTUME] = {
    outfits = {
        ["Shiny Ninetales"] = { lookType = 2826, ride = 2827}
    },
    itemId = 34860,
}
ADDONS[PokemonAddon.IDS.AHRI_ATARI] = {
    outfits = {
        ["Shiny Ninetales"] = { lookType = 2830, ride = 2831}
    },
    itemId = 34862,
}
ADDONS[PokemonAddon.IDS.KURAMA_ASURA] = {
    outfits = {
        ["Shiny Ninetales"] = { lookType = 2832, ride = 2833}
    },
    itemId = 34863,
}
ADDONS[PokemonAddon.IDS.GREYMON_COSTUME] = {
    outfits = {
        ["Shiny Rhydon"] = { lookType = 2837}
    },
    itemId = 34866,
}
ADDONS[PokemonAddon.IDS.CAVE_GLADIATOR] = {
    outfits = {
        ["Shiny Rhydon"] = { lookType = 2838}
    },
    itemId = 34867,
}
ADDONS[PokemonAddon.IDS.GABUMON_COSTUME] = {
    outfits = {
        ["Shiny Rhydon"] = { lookType = 2840}
    },
    itemId = 34869,
}
ADDONS[PokemonAddon.IDS.DREGGMAN_COSTUME] = {
    outfits = {
        ["Shiny Rhydon"] = { lookType = 2841}
    },
    itemId = 34870,
}
ADDONS[PokemonAddon.IDS.KILLER_CLOAK] = {
    outfits = {
        ["Shiny Scyther"] = { lookType = 2842}
    },
    itemId = 34871,
}

--local ADDONS_ABILITY_CONDITION_FLY = {}
--local ADDONS_ABILITY_CONDITION_LEVITATE = {}
--local ADDONS_ABILITY_CONDITION_RIDE = {}
--local ADDONS_ABILITY_CONDITION_SURF = {}
--local ADDONS_ABILITY_CONDITION_DIVE = {}

local ADDON_BY_ITEMID = {}
local OUTFITS_BY_LOOKTYPE = {}

for addonId, addon in pairs(ADDONS) do
    if (addon.itemId > 0) then
        addon.id = addonId
        addon.name = getItemNameById(addon.itemId)
        ADDON_BY_ITEMID[addon.itemId] = addon

        for pokemonName, outfits in pairs(addon.outfits) do
            OUTFITS_BY_LOOKTYPE[outfits.lookType] = outfits

            --            if (outfits.fly) then
            --                ADDONS_ABILITY_CONDITION_FLY[outfits.lookType] = createConditionObject(CONDITION_OUTFIT, -1, nil, CONDITION_SUBID.OUTFITS.ABILITIES)
            --                addOutfitCondition(ADDONS_ABILITY_CONDITION_FLY[outfits.lookType], { lookType = outfits.fly })
            --
            --            elseif (outfits.ride) then
            --                ADDONS_ABILITY_CONDITION_RIDE[outfits.lookType] = createConditionObject(CONDITION_OUTFIT, -1, nil, CONDITION_SUBID.OUTFITS.ABILITIES)
            --                addOutfitCondition(ADDONS_ABILITY_CONDITION_RIDE[outfits.lookType], { lookType = outfits.ride })
            --
            --            elseif (outfits.surf) then
            --                ADDONS_ABILITY_CONDITION_SURF[outfits.lookType] = createConditionObject(CONDITION_OUTFIT, -1, nil, CONDITION_SUBID.OUTFITS.ABILITIES)
            --                addOutfitCondition(ADDONS_ABILITY_CONDITION_SURF[outfits.lookType], { lookType = outfits.surf })
            --
            --            elseif (outfits.dive) then
            --                ADDONS_ABILITY_CONDITION_DIVE[outfits.lookType] = createConditionObject(CONDITION_OUTFIT, -1, nil, CONDITION_SUBID.OUTFITS.ABILITIES)
            --                addOutfitCondition(ADDONS_ABILITY_CONDITION_DIVE[outfits.lookType], { lookType = outfits.dive })
            --
            --            elseif (outfits.levitate) then
            --                ADDONS_ABILITY_CONDITION_LEVITATE[outfits.lookType] = createConditionObject(CONDITION_OUTFIT, -1, nil, CONDITION_SUBID.OUTFITS.ABILITIES)
            --                addOutfitCondition(ADDONS_ABILITY_CONDITION_LEVITATE[outfits.lookType], { lookType = outfits.levitate })
            --            end
        end
    end
end

--local out = ""
--for addonId, addon in pairs(ADDONS) do
--    if (addon.itemId > 0) then
--        local tmpOutfits = ""
--
--        for pokemonName, outfits in pairs(addon.outfits) do
--            tmpOutfits = tmpOutfits .. "<img src=\"http://www.psoul.net/img/addons/Outfits/".. outfits.lookType .."_2_0_0.png\" alt=\"".. pokemonName .."\"/> "
--        end
--
--        out = out .. "<tr>\n<td><img src=\"http://www.psoul.net/img/addons/Items/".. getItemClientId(addon.itemId) ..".png\" alt=\"".. addon.name .."\"/></td>\n<td>" .. addon.name .. "</td>\n<td>".. tmpOutfits .."</td>\n</tr>"
--    end
--end
--print(out)

-- Vars

-- Methods Local
local function canPokemonWearAddon(pokemon, addonId, ballUid)
    return ADDONS[addonId].outfits[getCreatureName(pokemon)] and not table.find(getBallAddons(ballUid), addonId)
end

-- Methods Global
PokemonAddon.doPlayerSendWindow = function(cid)
    if (not isPokemonOnline(cid)) then
        doPlayerSendCancel(cid, "You must call your Pokemon first.")
        return
    end

    local ballUid = getPlayerBall(cid).uid
    local pokemonName = getBallPokemonName(ballUid)
    local addons = getBallAddons(ballUid)
    local currentAddon = getBallCurrentAddon(ballUid)
    local defaultOutfit = getMonsterInfo(getPlayerPokemonName(cid)).outfit

    local lookTypes = {}
    lookTypes[#lookTypes + 1] = { lookType = defaultOutfit.lookType, name = "default" }

    for _, addonId in pairs(addons) do
        if (ADDONS[addonId] and ADDONS[addonId].outfits[pokemonName]) then
            lookTypes[#lookTypes + 1] = { lookType = ADDONS[addonId].outfits[pokemonName].lookType, name = ADDONS[addonId].name }
        end
    end

    return doPlayerSendCustomOutfitWindow(cid, (currentAddon and currentAddon or defaultOutfit), lookTypes)
end

PokemonAddon.onPlayerUseAddon = function(cid, item, fromPosition, itemEx, toPosition)
    local addon = ADDON_BY_ITEMID[item.itemid]
    if (not addon or not isMonster(itemEx.uid) or getCreatureMaster(itemEx.uid) ~= cid) then
        doPlayerSendDefaultCancel(cid, RETURNVALUE_NOTPOSSIBLE)
        return true

    elseif (not isPokemonOnline(cid)) then
        doPlayerSendCancel(cid, "You must call your Pokemon first.")
        return true

    elseif (not canPokemonWearAddon(itemEx.uid, addon.id, getPlayerBall(cid).uid)) then
        doPlayerSendCancel(cid, "Your Pokemon cannot wear this addon.")
        return true
    end

    doBallAddAddon(getPlayerBall(cid).uid, addon.id)
    PokemonAddon.doPlayerSendWindow(cid)
    doSendMagicEffect(getCreaturePosition(cid), EFFECT_FIREWORK_BLUE)
    doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, string.concat("Your Pokemon received the ", addon.name, " addon."))
    doRemoveItem(item.uid, 1)
    return true
end

PokemonAddon.onChooseAddon = function(cid, outfit)
    if (not isPokemonOnline(cid)) then
        return false
    end

    local pokemon = getPlayerPokemon(cid)
    doSendMagicEffect(getCreaturePosition(pokemon), EFFECT_POFF)
    doSetCreatureOutfit(pokemon, outfit, -1)

    local defaultOutfit = getMonsterInfo(getCreatureName(pokemon)).outfit
    if (outfit.lookType == defaultOutfit.lookType) then
        doBallSaveAddon(getPlayerBall(cid).uid, nil, true)
    else
        doBallSaveAddon(getPlayerBall(cid).uid, outfit)
    end
end

PokemonAddon.onPokemonCall = function(pokemon, ball)
    local outfit = getBallCurrentAddon(ball.uid)
    if (outfit) then
        doSetCreatureOutfit(pokemon, outfit, -1)
    end
end

PokemonAddon.doUpdateAbilityOutfitCondition = function(cid)
    local outfit = getBallCurrentAddon(getPlayerBall(cid).uid)
    if (not outfit) then
        return false
    end

    local addon = OUTFITS_BY_LOOKTYPE[outfit.lookType]
    if (not addon) then
        return false
    end

    local lookType = nil
    if (isFlying(cid)) then
        lookType = addon.fly

    elseif (isLevitating(cid)) then
        lookType = addon.levitate

    elseif (isRiding(cid)) then
        lookType = addon.ride

    elseif (isSurfing(cid)) then
        lookType = addon.surf

    elseif (isDiving(cid)) then
        lookType = addon.dive
    end

    if (lookType) then
        outfit.lookType = lookType
        doSetCreatureOutfit(cid, outfit, -1, CONDITION_SUBID.OUTFITS.ABILITIES)
        return true
    end

    return false
end