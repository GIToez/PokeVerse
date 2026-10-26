-- Mega Evolution items (docs/upcoming-features.md, Mega Evolution; art in docs/mega-art.md).
-- Server ids 30175-30271 draw client items 28818-28914 in the same order.

MEGA_ITEM_IDS = {
    EMPTY_RING = 30175,
    KEY_STONE = 30176,
    RING = 30177
}

-- { item name, the Pokemon that holds it, the form it becomes }. Every Mega Stone on Bulbapedia
-- (October 2026) and the two Primal orbs, in item id order from 30178. A stone only does something
-- once its form is in MegaEvolution's forms; until then it is held like any other item.
local STONES = {
    -- X/Y and Omega Ruby/Alpha Sapphire
    { "Venusaurite", "Venusaur", "Mega Venusaur" },
    { "Charizardite X", "Charizard", "Mega Charizard X" },
    { "Charizardite Y", "Charizard", "Mega Charizard Y" },
    { "Blastoisinite", "Blastoise", "Mega Blastoise" },
    { "Beedrillite", "Beedrill", "Mega Beedrill" },
    { "Pidgeotite", "Pidgeot", "Mega Pidgeot" },
    { "Alakazite", "Alakazam", "Mega Alakazam" },
    { "Slowbronite", "Slowbro", "Mega Slowbro" },
    { "Gengarite", "Gengar", "Mega Gengar" },
    { "Kangaskhanite", "Kangaskhan", "Mega Kangaskhan" },
    { "Pinsirite", "Pinsir", "Mega Pinsir" },
    { "Gyaradosite", "Gyarados", "Mega Gyarados" },
    { "Aerodactylite", "Aerodactyl", "Mega Aerodactyl" },
    { "Mewtwonite X", "Mewtwo", "Mega Mewtwo X" },
    { "Mewtwonite Y", "Mewtwo", "Mega Mewtwo Y" },
    { "Ampharosite", "Ampharos", "Mega Ampharos" },
    { "Steelixite", "Steelix", "Mega Steelix" },
    { "Scizorite", "Scizor", "Mega Scizor" },
    { "Heracronite", "Heracross", "Mega Heracross" },
    { "Houndoominite", "Houndoom", "Mega Houndoom" },
    { "Tyranitarite", "Tyranitar", "Mega Tyranitar" },
    { "Sceptilite", "Sceptile", "Mega Sceptile" },
    { "Blazikenite", "Blaziken", "Mega Blaziken" },
    { "Swampertite", "Swampert", "Mega Swampert" },
    { "Gardevoirite", "Gardevoir", "Mega Gardevoir" },
    { "Sablenite", "Sableye", "Mega Sableye" },
    { "Mawilite", "Mawile", "Mega Mawile" },
    { "Aggronite", "Aggron", "Mega Aggron" },
    { "Medichamite", "Medicham", "Mega Medicham" },
    { "Manectite", "Manectric", "Mega Manectric" },
    { "Sharpedonite", "Sharpedo", "Mega Sharpedo" },
    { "Cameruptite", "Camerupt", "Mega Camerupt" },
    { "Altarianite", "Altaria", "Mega Altaria" },
    { "Banettite", "Banette", "Mega Banette" },
    { "Absolite", "Absol", "Mega Absol" },
    { "Glalitite", "Glalie", "Mega Glalie" },
    { "Salamencite", "Salamence", "Mega Salamence" },
    { "Metagrossite", "Metagross", "Mega Metagross" },
    { "Latiasite", "Latias", "Mega Latias" },
    { "Latiosite", "Latios", "Mega Latios" },
    { "Lopunnite", "Lopunny", "Mega Lopunny" },
    { "Garchompite", "Garchomp", "Mega Garchomp" },
    { "Lucarionite", "Lucario", "Mega Lucario" },
    { "Abomasite", "Abomasnow", "Mega Abomasnow" },
    { "Galladite", "Gallade", "Mega Gallade" },
    { "Audinite", "Audino", "Mega Audino" },
    { "Diancite", "Diancie", "Mega Diancie" },
    -- Legends: Z-A
    { "Clefablite", "Clefable", "Mega Clefable" },
    { "Victreebelite", "Victreebel", "Mega Victreebel" },
    { "Starminite", "Starmie", "Mega Starmie" },
    { "Dragoninite", "Dragonite", "Mega Dragonite" },
    { "Meganiumite", "Meganium", "Mega Meganium" },
    { "Feraligite", "Feraligatr", "Mega Feraligatr" },
    { "Skarmorite", "Skarmory", "Mega Skarmory" },
    { "Froslassite", "Froslass", "Mega Froslass" },
    { "Emboarite", "Emboar", "Mega Emboar" },
    { "Excadrite", "Excadrill", "Mega Excadrill" },
    { "Scolipite", "Scolipede", "Mega Scolipede" },
    { "Scraftinite", "Scrafty", "Mega Scrafty" },
    { "Eelektrossite", "Eelektross", "Mega Eelektross" },
    { "Chandelurite", "Chandelure", "Mega Chandelure" },
    { "Chesnaughtite", "Chesnaught", "Mega Chesnaught" },
    { "Delphoxite", "Delphox", "Mega Delphox" },
    { "Greninjite", "Greninja", "Mega Greninja" },
    { "Pyroarite", "Pyroar", "Mega Pyroar" },
    { "Floettite", "Floette", "Mega Floette" },
    { "Malamarite", "Malamar", "Mega Malamar" },
    { "Barbaracite", "Barbaracle", "Mega Barbaracle" },
    { "Dragalgite", "Dragalge", "Mega Dragalge" },
    { "Hawluchanite", "Hawlucha", "Mega Hawlucha" },
    { "Zygardite", "Zygarde", "Mega Zygarde" },
    { "Drampanite", "Drampa", "Mega Drampa" },
    { "Falinksite", "Falinks", "Mega Falinks" },
    -- Legends: Z-A Mega Dimension
    { "Raichunite X", "Raichu", "Mega Raichu X" },
    { "Raichunite Y", "Raichu", "Mega Raichu Y" },
    { "Chimechite", "Chimecho", "Mega Chimecho" },
    { "Absolite Z", "Absol", "Mega Absol Z" },
    { "Staraptite", "Staraptor", "Mega Staraptor" },
    { "Garchompite Z", "Garchomp", "Mega Garchomp Z" },
    { "Lucarionite Z", "Lucario", "Mega Lucario Z" },
    { "Heatranite", "Heatran", "Mega Heatran" },
    { "Darkranite", "Darkrai", "Mega Darkrai" },
    { "Golurkite", "Golurk", "Mega Golurk" },
    { "Meowsticite", "Meowstic", "Mega Meowstic" },
    { "Crabominite", "Crabominable", "Mega Crabominable" },
    { "Golisopite", "Golisopod", "Mega Golisopod" },
    { "Magearnite", "Magearna", "Mega Magearna" },
    { "Zeraorite", "Zeraora", "Mega Zeraora" },
    { "Scovillainite", "Scovillain", "Mega Scovillain" },
    { "Baxcalibrite", "Baxcalibur", "Mega Baxcalibur" },
    { "Tatsugirinite", "Tatsugiri", "Mega Tatsugiri" },
    { "Glimmoranite", "Glimmora", "Mega Glimmora" },
    -- Primal Reversion, treated as a Mega
    { "Red Orb", "Groudon", "Primal Groudon" },
    { "Blue Orb", "Kyogre", "Primal Kyogre" }
}

MEGA_FIRST_STONE_ID = 30178

MEGA_STONES = {}
MEGA_STONE_BY_ITEMID = {}
for i, stone in ipairs(STONES) do
    local entry = { name = stone[1], pokemon = stone[2], form = stone[3], itemId = MEGA_FIRST_STONE_ID + i - 1 }
    MEGA_STONES[i] = entry
    MEGA_STONE_BY_ITEMID[entry.itemId] = entry
end

MEGA_LAST_STONE_ID = MEGA_FIRST_STONE_ID + #MEGA_STONES - 1
