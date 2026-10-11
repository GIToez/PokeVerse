-- Area name banner: which area names pop a banner, which background theme they use and the
-- line under the name. Names are the [8] field of the music areas (sounds1/2.lua and
-- sounds_pokeverse.lua). Keep texts ASCII, the banner fonts have no accented letters.

AREA_BANNER = {}

-- Names containing any of these only update the location label under the clock.
local BUILDING_WORDS = {
    "Pokemon Center", "Pokemon Mart", "Pokemon Market", "Pokemon Buyer", "House", "Shop", "Store",
    "Hotel", "Bank", "Post", "Bar", "Parlor", "Pizzeria", "Juices", "Fast Food", "Fast Foof",
    "Daycare", "Cassino", "Kennel", "Iglu", "TM's", "Held Itens", "Vitamins", "Item Market",
    "Museum", "Laboratory", "Committee", "Club", "Trading Area", "Waiting Area", "Aquarium",
    "Mastery - ",
}

-- Checked in order, the first theme with a matching word wins; anything else is "city".
local THEME_WORDS = {
    { "special", { "Gym", "Tower", "Temple", "Castle", "Plateau", "Elite Four", "Arena", "Colosseum",
        "Lair", "Base", "Hideout", "Society", "Pokemansion", "Silph", "Power Plant", "Dream World",
        "Null Dimension", "Prophecy Room", "Hall of", "Reserve", "Tomb", "Witches", "Test Dungeon",
        "Reception Gate", "Challenge" } },
    { "volcano", { "Volcano", "Fire Island", "Fire Mountain", "Hot Cave" } },
    { "cave", { "Cave", "Tunnel", "Grotto", "Cavern", "Hole", "Mine", "Culvert", "Well", "Metro",
        "Within the Iceberg", "Archaeological" } },
    { "forest", { "Forest", "Jungle", "Woodland", "Rainforest", "Leaf", "Nature" } },
    { "mountain", { "Mountain", "Mt.", "Mount ", "Canyon", "Hill", "Nest High" } },
    { "sea", { "Island", "Isle", "Beach", "Sea", "Lake", "Coast", "Harbor", "Iceberg", "River",
        "Waterfall", "S. S. Anne", "Ship", "Refuge Cold" } },
    { "route", { "Route", "Around", "Area", "Field", "Meadow", "Pasture", "Saffari", "Nook",
        "Corner", "Muddy", "Aviary", "Region", "Ten", "Fifteen", "Twenty" } },
}

-- Exact names whose words would pick the wrong theme.
local THEME_OVERRIDES = {
    ["Seafoam"] = "sea",
    ["Lavender Tower"] = "special",
    ["Area of the Fight"] = "special",
    ["Bill Lighthouse"] = "special",
    ["Tutorial Island"] = "sea",
}

local THEME_SUBTITLES = {
    city = "A lively town where trainers rest, shop and trade stories.",
    route = "A peaceful path between cities, filled with tall grass and wild Pokemon.",
    forest = "Thick trees hide all kinds of Bug and Grass Pokemon.",
    cave = "A dark passage. Watch your step and keep a Repel handy.",
    mountain = "Steep rocky trails where strong Pokemon roam.",
    sea = "Salty winds and open water as far as the eye can see.",
    volcano = "The ground is hot to the touch. Fire Pokemon thrive here.",
    special = "Only the bravest trainers make it this far.",
}

local SUBTITLES = {
    ["Tutorial Island"] = "Where every trainer's journey begins.",
    ["Pallet"] = "A quiet town of fresh starts and Professor Oak's lab.",
    ["Viridian"] = "The eternally green gateway to the rest of the region.",
    ["Viridian Forest"] = "A natural maze of trees, home to Bug Pokemon.",
    ["Pewter"] = "A stone gray city between rugged mountains.",
    ["Mt. Moon"] = "A mystic mountain where meteorites are said to fall.",
    ["Cerulean"] = "A mysterious, blue aura surrounds this city by the water.",
    ["Vermilion"] = "The port of exquisite sunsets.",
    ["Lavender"] = "The noble purple town, where trainers honour departed Pokemon.",
    ["Lavender Tower"] = "Something stirs among the graves at night.",
    ["Rock Tunnel"] = "A pitch black tunnel cutting through the mountains.",
    ["Celadon"] = "The city of rainbow dreams and the biggest store around.",
    ["Saffron"] = "The shining, golden land of commerce.",
    ["Fuchsia"] = "Behold! It's passion pink! Home of the Safari Zone.",
    ["Cinnabar"] = "The fiery town of burning desire.",
    ["Seafoam"] = "Icy caves where the currents meet.",
    ["Route 01"] = "A short path of tall grass between Pallet and Viridian.",
    ["Route 02"] = "A peaceful path between cities, filled with tall grass and wild Pokemon.",
    ["Route 03"] = "A rough trail of hills leading toward Mt. Moon.",
    ["Route 04"] = "A path down the mountain toward Cerulean.",
    ["Route 05"] = "A grassy road heading south of Cerulean.",
    ["Route 06"] = "A calm path along the water toward Vermilion.",
    ["Route 07"] = "A short road on the edge of Celadon.",
    ["Route 08"] = "A busy road between Saffron and Lavender.",
    ["Route 09"] = "A winding, rocky road east of Cerulean.",
    ["Route 10"] = "A road by the river, near the Power Plant.",
    ["Route 11"] = "An open road east of Vermilion.",
    ["Route 12"] = "A long fishing pier stretching south.",
    ["Route 13"] = "A twisting maze of fences and tall grass.",
    ["Route 14"] = "A quiet road through the southern grasslands.",
    ["Route 15"] = "A road of trainers on the way to Fuchsia.",
    ["Route 16"] = "A road where a sleeping Pokemon may block the way.",
    ["Route 17 - Cycling Road"] = "A long downhill slope. Hold on to your bike!",
    ["Route 19"] = "Calm waters south of Fuchsia.",
    ["Route 22"] = "The old road toward the Pokemon League.",
    ["Route 23"] = "The final road to the Indigo Plateau.",
    ["Route 24"] = "A bridge where trainers test newcomers.",
    ["Route 25"] = "A path to the cape north of Cerulean.",
}

local function containsWord(name, words)
    for _, word in ipairs(words) do
        if name:find(word, 1, true) then
            return true
        end
    end
    return false
end

function AREA_BANNER.isBuilding(name)
    return containsWord(name, BUILDING_WORDS)
end

function AREA_BANNER.theme(name)
    if THEME_OVERRIDES[name] then
        return THEME_OVERRIDES[name]
    end
    for _, rule in ipairs(THEME_WORDS) do
        if containsWord(name, rule[2]) then
            return rule[1]
        end
    end
    return "city"
end

function AREA_BANNER.subtitle(name)
    return SUBTITLES[name] or THEME_SUBTITLES[AREA_BANNER.theme(name)]
end

-- data/images/area_banner/place_<name>.png (lower case, other characters as _) replaces the
-- theme background for that one place, e.g. place_viridian_forest.png
function AREA_BANNER.image(name)
    local place = '/images/area_banner/place_' .. name:lower():gsub('[^%w]+', '_'):gsub('^_', ''):gsub('_$', '')
    if g_resources.fileExists(place .. '.png') then
        return place
    end
    return '/images/area_banner/theme_' .. AREA_BANNER.theme(name)
end
