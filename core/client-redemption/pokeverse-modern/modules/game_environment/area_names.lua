-- Area name banner: which area names pop a banner, which background theme they use and the
-- line under the name. Names are the [8] field of the music areas (sounds1/2.lua and
-- sounds_pokeverse.lua). Keep texts ASCII, the banner fonts have no accented letters.

AREA_BANNER = {}

-- Names containing any of these only update the location label next to the clock.
local BUILDING_WORDS = {
    "Pokemon Center", "Pokemon Mart", "Pokemon Market", "Pokemon Buyer", "House", "Shop", "Store",
    "Hotel", "Bank", "Post", "Bar", "Parlor", "Pizzeria", "Juices", "Fast Food", "Fast Foof",
    "Daycare", "Cassino", "Kennel", "Iglu", "TM's", "Held Itens", "Vitamins", "Item Market",
    "Museum", "Laboratory", "Committee", "Club", "Union Room", "Waiting Area", "Aquarium",
    "Mastery - ", "Academy", "Theater", "Terminal", "Game Corner", "Pharmacy", "Research", "Police",
    "Windmill", "Office",
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
        "Waterfall", "S. S. Anne", "Ship", "Refuge Cold", "Waters", "Archipelago" } },
    { "route", { "Route", "Around", "Outskirts", "Area", "Field", "Meadow", "Pasture", "Saffari", "Nook",
        "Corner", "Muddy", "Aviary", "Region", "Ten", "Fifteen", "Twenty" } },
}

-- Exact names whose words would pick the wrong theme.
local THEME_OVERRIDES = {
    ["Seafoam"] = "sea",
    ["Lavender Tower"] = "special",
    ["Area of the Fight"] = "special",
    ["Bill Lighthouse"] = "special",
    ["Tutorial Island"] = "sea",
    -- Johto
    ["Ice Path"] = "cave",
    ["Whirl Islands"] = "cave",
    ["Mt. Mortar"] = "cave",
    ["Tohjo Falls"] = "cave",
    ["Ruins of Alph"] = "special",
    ["Olivine Lighthouse"] = "special",
    ["Battle Frontier"] = "special",
    ["Battle Factory"] = "special",
    ["Battle Arcade"] = "special",
    ["Battle Hall"] = "special",
    ["Dragon Holy Land"] = "special",
    ["Ilex Shrine"] = "forest",
    ["Arbor Woods"] = "forest",
    ["Azalea South Woods"] = "forest",
    ["National Park"] = "route",
    ["Moomoo Farm"] = "route",
    ["Safari Zone"] = "route",
    ["Rage Marshes"] = "route",
    ["Mortar Badlands"] = "mountain",
    ["Olivine Cliffs"] = "mountain",
    ["Frozen North"] = "mountain",
    ["I.S.S. Raspberry"] = "sea",
    -- Hoenn
    ["Petalburg Woods"] = "forest",
    ["Meteor Falls"] = "cave",
    ["Mt. Chimney"] = "volcano",
    ["Jagged Pass"] = "mountain",
    ["Mt. Pyre"] = "special",
    ["New Mauville"] = "special",
    ["Ever Grande"] = "special",
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
    ["Route 18"] = "A road west of Fuchsia to the foot of the Cycling Road.",
    ["Route 19"] = "Calm waters south of Fuchsia.",
    ["Route 20"] = "Strong currents between Fuchsia, the Seafoam Islands and Cinnabar.",
    ["Route 21"] = "A long stretch of sea between Pallet and Cinnabar.",
    ["Kanto Sea"] = "Open water off the coast of Kanto.",
    ["Route 22"] = "The old road toward the Pokemon League.",
    ["Route 23"] = "The final road to the Indigo Plateau.",
    ["Route 24"] = "A bridge where trainers test newcomers.",
    ["Route 25"] = "A path to the cape north of Cerulean.",
    -- Johto
    ["New Bark"] = "The town where the winds of a new beginning blow.",
    ["Cherrygrove"] = "The city of cute, fragrant flowers.",
    ["Violet"] = "The city of nostalgic scents, home of the Sprout Tower.",
    ["Azalea"] = "Where people and Pokemon live in happy harmony.",
    ["Goldenrod"] = "The festive city of opulent charm.",
    ["Ecruteak"] = "A historical city where the past meets the present.",
    ["Olivine"] = "The port closest to foreign lands.",
    ["Cianwood"] = "A port surrounded by rough seas.",
    ["Mahogany"] = "Welcome to the home of the ninja.",
    ["Blackthorn"] = "A quiet mountain retreat, home of the dragon masters.",
    ["Route 26"] = "A rugged road up to the Pokemon League's gate.",
    ["Route 27"] = "Rough country between New Bark and Tohjo Falls.",
    ["Route 28"] = "A hidden valley at the foot of Mt. Silver.",
    ["Route 29"] = "The first road out of New Bark.",
    ["Route 30"] = "A road of fruit trees and young trainers.",
    ["Route 31"] = "A grassy road by the mouth of Dark Cave.",
    ["Route 32"] = "A long road south to Union Cave, good for fishing.",
    ["Route 33"] = "A rainy hill road into Azalea.",
    ["Route 34"] = "The road by the Day-Care, south of Goldenrod.",
    ["Route 35"] = "A road of ponds and grass north of Goldenrod.",
    ["Route 36"] = "Where a strange tree once blocked the way.",
    ["Route 37"] = "A short road of apricorn trees.",
    ["Route 38"] = "A country road west to the farms.",
    ["Route 39"] = "Pastures where Miltank graze in the sun.",
    ["Route 40"] = "Rough waves between Olivine and the Whirl Islands.",
    ["Route 41"] = "A sea of whirlpools around the Whirl Islands.",
    ["Route 42"] = "A road around the peaks of Mt. Mortar.",
    ["Route 43"] = "A road of tall grass up to the Lake of Rage.",
    ["Route 44"] = "A road of tall grass and ponds before the Ice Path.",
    ["Route 45"] = "A steep mountain road of one-way ledges.",
    ["Route 46"] = "A short rocky road down to Route 29.",
    ["Route 47"] = "Rugged sea cliffs west of Cianwood.",
    ["Route 48"] = "A windswept road to the Safari Zone.",
    ["Sprout Tower"] = "A tall pagoda that sways but never falls.",
    ["Ruins of Alph"] = "Ancient chambers covered in strange letters.",
    ["Union Cave"] = "A cave under the hills between Route 32 and Azalea.",
    ["Slowpoke Well"] = "A damp well where Slowpoke gather.",
    ["Ilex Forest"] = "A dense forest guarded by its shrine.",
    ["Ilex Shrine"] = "A shrine to the protector of the forest.",
    ["National Park"] = "A park of lawns and fountains, famous for its Bug-Catching Contest.",
    ["Radio Tower"] = "The voice of Johto, on the air day and night.",
    ["Bell Tower"] = "Where the legendary Pokemon is said to land.",
    ["Burned Tower"] = "Its ashes still hide the three that rose from the fire.",
    ["Moomoo Farm"] = "Fresh Moomoo Milk from happy Miltank.",
    ["Olivine Lighthouse"] = "Its light guides the ships at night.",
    ["Whirl Islands"] = "Caves under the islands, where the sea god is said to sleep.",
    ["I.S.S. Raspberry"] = "A wreck on the reef, guarded by Mantine.",
    ["Mt. Mortar"] = "A huge mountain hollowed by waterfalls inside.",
    ["Lake of Rage"] = "A lake made by the tears of Gyarados.",
    ["Lake of Life"] = "A calm lake in the hills, teeming with life.",
    ["Lake Slowpoke"] = "A sleepy lake where Slowpoke laze by the shore.",
    ["Rage Marshes"] = "Soggy marshland south of the Lake of Rage.",
    ["Olivine Cliffs"] = "Sheer cliffs over the sea north of Olivine.",
    ["Frozen North"] = "Snowfields and ice where few trainers wander.",
    ["Snowtop Mountain"] = "A snowy peak above the old forest.",
    ["Mount Quena"] = "A lonely snowy peak in the far north.",
    ["Mortar Badlands"] = "Dry, rocky ground in the shadow of Mt. Mortar.",
    ["Rocket Hideout"] = "Something is going on under the souvenir shop.",
    ["Ice Path"] = "A frozen passage of sliding ice floors.",
    ["Dark Cave"] = "A pitch black cave. Flash would help here.",
    ["Dragon Holy Land"] = "Sacred ground of the dragon clan.",
    ["Tohjo Falls"] = "The falls between Johto and Kanto.",
    ["Mt. Silver"] = "Only the strongest trainers are allowed up this mountain.",
    ["Mt. Silver Cave"] = "Deep in the mountain, the toughest Pokemon wait.",
    ["Safari Zone"] = "Pokemon from far away roam its fields.",
    ["Battle Frontier"] = "Five facilities for trainers who want a real challenge.",
    ["Johto Sea"] = "Open water off the coast of Johto.",
    -- Orange Islands
    ["Orange Archipelago"] = "Warm seas dotted with the islands of the Orange Crew.",
    -- Hoenn
    ["Littleroot"] = "A town that can't be shaded any hue.",
    ["Oldale"] = "Where things happily get together.",
    ["Petalburg"] = "Where people mingle with nature.",
    ["Rustboro"] = "The city probing the integration of nature and science.",
    ["Dewford"] = "A tiny island in the blue sea.",
    ["Slateport"] = "The port where people and Pokemon cross paths.",
    ["Mauville"] = "The bright and shiny city of fun.",
    ["Verdanturf"] = "The windswept highlands with the sweet fragrance of grass.",
    ["Fallarbor"] = "A farm community with small gardens.",
    ["Lavaridge"] = "An excellent place for relaxing in the hot springs.",
    ["Fortree"] = "The treetop city that frolics with nature.",
    ["Lilycove"] = "Where the land ends and the sea begins.",
    ["Mossdeep"] = "Our slogan: Cherish Pokemon!",
    ["Sootopolis"] = "The mystical city where history slumbers.",
    ["Pacifidlog"] = "Where the morning sun smiles upon the waters.",
    ["Ever Grande"] = "The paradise of flowers, the sea and Pokemon. The League awaits.",
    ["Petalburg Woods"] = "A forest of tall trees between Petalburg and Rustboro.",
    ["Rusturf Tunnel"] = "A tunnel dug by hand between Rustboro and Verdanturf.",
    ["Granite Cave"] = "A dark cave on Dewford's island, with ancient paintings on its walls.",
    ["Meteor Falls"] = "Falls and caves where a meteor is said to have struck.",
    ["Mt. Chimney"] = "A volcano whose smoke never stops rising.",
    ["Jagged Pass"] = "A rugged trail down the side of Mt. Chimney.",
    ["Route 111 Desert"] = "Sandstorms rage over the dunes. Some goggles would help.",
    ["New Mauville"] = "The abandoned power plant under Route 110.",
    ["Mt. Pyre"] = "A sacred mountain where departed Pokemon rest.",
    ["Shoal Cave"] = "Tides flood and drain this icy cave twice a day.",
    ["Hoenn Sea"] = "Open water between Hoenn's islands.",
}

local function containsWord(name, words)
    for _, word in ipairs(words) do
        if name:find(word, 1, true) then
            return true
        end
    end
    return false
end

-- Places whose names contain one of the building words.
local NOT_BUILDINGS = {
    ["New Bark"] = true,
}

-- The regions' names (sounds_pokeverse.lua's fallback, where no area is) only update the label.
local LABEL_ONLY = {
    ["Kanto"] = true,
    ["Johto"] = true,
    ["Orange Islands"] = true,
    ["Hoenn"] = true,
}

function AREA_BANNER.isBuilding(name)
    return LABEL_ONLY[name] or (not NOT_BUILDINGS[name] and containsWord(name, BUILDING_WORDS))
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
