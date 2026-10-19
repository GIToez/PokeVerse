-- PokeVerse world map: the map picture, city names (full map only) and the guide NPC marks.
-- The names and regions are map_labels.lua's (scripts/mapper/build_map_labels.py).

MAPMARK_TICK = 0
MAPMARK_QUESTION = 1
MAPMARK_EXCLAMATION = 2
MAPMARK_STAR = 3
MAPMARK_CROSS = 4
MAPMARK_TEMPLE = 5
MAPMARK_KISS = 6
MAPMARK_SHOVEL = 7
MAPMARK_SWORD = 8
MAPMARK_FLAG = 9
MAPMARK_LOCK = 10
MAPMARK_BAG = 11
MAPMARK_SKULL = 12
MAPMARK_DOLLAR = 13
MAPMARK_REDNORTH = 14
MAPMARK_REDSOUTH = 15
MAPMARK_REDEAST = 16
MAPMARK_REDWEST = 17
MAPMARK_GREENNORTH = 18
MAPMARK_GREENSOUTH = 19

local GUIDES = {}
GUIDES["Tangelo"] = { -- Guide Cary
    {position = {x = 2745, y = 2829, z = 6}, type = MAPMARK_DOLLAR, description = "Poke Mart"},
    {position = {x = 2756, y = 2819, z = 5}, type = MAPMARK_TEMPLE, description = "Pokemon Center"},
    {position = {x = 2764, y = 2831, z = 6}, type = MAPMARK_BAG, description = "Food Shop"},
    {position = {x = 2724, y = 2857, z = 6}, type = MAPMARK_FLAG, description = "Travel Ship"},
}

GUIDES["Mandarin North"] = { -- Guide Ross
    {position = {x = 2985, y = 2251, z = 7}, type = MAPMARK_DOLLAR, description = "Poke Mart"},
    {position = {x = 2939, y = 2231, z = 7}, type = MAPMARK_TEMPLE, description = "Pokemon Center"},
    {position = {x = 2956, y = 2253, z = 5}, type = MAPMARK_BAG, description = "Food Shop"},
    {position = {x = 2967, y = 2294, z = 6}, type = MAPMARK_FLAG, description = "Travel Ship"},
}

GUIDES["Kumquat"] = { -- Guide Jay
    {position = {x = 3527, y = 1667, z = 7}, type = MAPMARK_DOLLAR, description = "Poke Mart"},
    {position = {x = 3516, y = 1694, z = 7}, type = MAPMARK_TEMPLE, description = "Pokemon Center"},
    {position = {x = 3490, y = 1717, z = 6}, type = MAPMARK_BAG, description = "Food Shop"},
    {position = {x = 3466, y = 1762, z = 6}, type = MAPMARK_FLAG, description = "Travel Ship"},
}

GUIDES["Mikan"] = { -- Guide Everitt
    {position = {x = 2710, y = 2451, z = 7}, type = MAPMARK_DOLLAR, description = "Poke Mart"},
    {position = {x = 2758, y = 2437, z = 7}, type = MAPMARK_TEMPLE, description = "Pokemon Center"},
    {position = {x = 2678, y = 2502, z = 6}, type = MAPMARK_FLAG, description = "Travel Ship"},
}

GUIDES["Pummelo"] = { -- Guide Jocelyn
    {position = {x = 3050, y = 1697, z = 7}, type = MAPMARK_DOLLAR, description = "Poke Mart"},
    {position = {x = 3066, y = 1664, z = 7}, type = MAPMARK_TEMPLE, description = "Pokemon Center"},
    {position = {x = 3087, y = 1666, z = 7}, type = MAPMARK_BAG, description = "Food Shop"},
    {position = {x = 3083, y = 1744, z = 6}, type = MAPMARK_FLAG, description = "Travel Ship"},
}

GUIDES["Ascorbia"] = { -- Guide David
    {position = {x = 4410, y = 1745, z = 7}, type = MAPMARK_DOLLAR, description = "Poke Mart"},
    {position = {x = 4434, y = 1716, z = 7}, type = MAPMARK_TEMPLE, description = "Pokemon Center"},
    {position = {x = 4420, y = 1728, z = 7}, type = MAPMARK_BAG, description = "Food Shop"},
    {position = {x = 4427, y = 1783, z = 6}, type = MAPMARK_FLAG, description = "Travel Ship"},
}

GUIDES["Trovitopolis"] = { -- Guide Emmerson
    {position = {x = 3494, y = 3244, z = 6}, type = MAPMARK_DOLLAR, description = "Poke Mart"},
    {position = {x = 3490, y = 3213, z = 6}, type = MAPMARK_TEMPLE, description = "Pokemon Center"},
    {position = {x = 3468, y = 3221, z = 6}, type = MAPMARK_BAG, description = "Food Shop"},
    {position = {x = 3425, y = 3228, z = 6}, type = MAPMARK_FLAG, description = "Travel Ship"},
}

GUIDES["Moro"] = { -- Guide Thurstan
    {position = {x = 4159, y = 2970, z = 7}, type = MAPMARK_DOLLAR, description = "Poke Mart"},
    {position = {x = 4164, y = 2955, z = 7}, type = MAPMARK_TEMPLE, description = "Pokemon Center"},
    {position = {x = 4221, y = 2933, z = 7}, type = MAPMARK_BAG, description = "Food Shop"},
    {position = {x = 4261, y = 2927, z = 6}, type = MAPMARK_FLAG, description = "Travel Ship"},
}

GUIDES["Sunburst"] = { -- Guide Brendan
    {position = {x = 3039, y = 2542, z = 5}, type = MAPMARK_TEMPLE, description = "Pokemon Center"},
    {position = {x = 3037, y = 2641, z = 6}, type = MAPMARK_FLAG, description = "Travel Ship"},
}

GUIDES["Viridian"] = { -- Guide Chesley
    {position = {x = 3309, y = 538, z = 7}, type = MAPMARK_DOLLAR, description = "Poke Mart and Bank"},
    {position = {x = 3295, y = 564, z = 7}, type = MAPMARK_TEMPLE, description = "Pokemon Center"},
    {position = {x = 3332, y = 550, z = 7}, type = MAPMARK_BAG, description = "Food Shop"},
    {position = {x = 3267, y = 571, z = 7}, type = MAPMARK_BAG, description = "Berries Shop and Furniture Shop"},
    {position = {x = 3254, y = 565, z = 7}, type = MAPMARK_SWORD, description = "GYM"},
    {position = {x = 3270, y = 528, z = 7}, type = MAPMARK_STAR, description = "Guild House"},
    {position = {x = 3265, y = 600, z = 7}, type = MAPMARK_STAR, description = "Travel Balloon"},
    {position = {x = 3299, y = 551, z = 7}, type = MAPMARK_STAR, description = "Ranger Club"},
}

GUIDES["Pewter"] = { -- Guide Emil
    {position = {x = 3336, y = 276, z = 7}, type = MAPMARK_DOLLAR, description = "Poke Mart and Bank"},
    {position = {x = 3307, y = 296, z = 7}, type = MAPMARK_TEMPLE, description = "Pokemon Center"},
    {position = {x = 3257, y = 293, z = 7}, type = MAPMARK_BAG, description = "Food Shop"},
    {position = {x = 3276, y = 254, z = 7}, type = MAPMARK_BAG, description = "Berries Shop"},
    {position = {x = 3292, y = 253, z = 7}, type = MAPMARK_SWORD, description = "GYM"},
    {position = {x = 3263, y = 281, z = 7}, type = MAPMARK_STAR, description = "Museum"},
    {position = {x = 3272, y = 316, z = 7}, type = MAPMARK_BAG, description = "Furniture Shop"},
    {position = {x = 3326, y = 246, z = 7}, type = MAPMARK_STAR, description = "Guild House"},
    {position = {x = 3290, y = 291, z = 7}, type = MAPMARK_STAR, description = "Ranger Club"},
    {position = {x = 3336, y = 310, z = 7}, type = MAPMARK_STAR, description = "Travel Train"},
}

GUIDES["Cerulean"] = { -- Guide Maddox
    {position = {x = 3859, y = 295, z = 7}, type = MAPMARK_DOLLAR, description = "Poke Mart and Bank"},
    {position = {x = 3884, y = 314, z = 7}, type = MAPMARK_TEMPLE, description = "Pokemon Center"},
    {position = {x = 3872, y = 331, z = 7}, type = MAPMARK_BAG, description = "Food Shop"},
    {position = {x = 3919, y = 303, z = 7}, type = MAPMARK_BAG, description = "Bike Shop"},
    {position = {x = 3866, y = 339, z = 7}, type = MAPMARK_BAG, description = "Furniture Shop"},
    {position = {x = 3919, y = 265, z = 7}, type = MAPMARK_SWORD, description = "GYM"},
    {position = {x = 3864, y = 261, z = 7}, type = MAPMARK_STAR, description = "Daycare"},
    {position = {x = 3883, y = 249, z = 7}, type = MAPMARK_STAR, description = "Guild House"},
    {position = {x = 3874, y = 308, z = 7}, type = MAPMARK_STAR, description = "Ranger Club"},
    {position = {x = 3939, y = 268, z = 7}, type = MAPMARK_STAR, description = "Travel Fly"},
    {position = {x = 3884, y = 273, z = 7}, type = MAPMARK_STAR, description = "Travel Train"},
    {position = {x = 3868, y = 271, z = 7}, type = MAPMARK_BAG, description = "Berry Shop"},
}

GUIDES["Saffron"] = { -- Guide Andie
    {position = {x = 3955, y = 482, z = 7}, type = MAPMARK_DOLLAR, description = "Poke Mart and Bank"},
    {position = {x = 3942, y = 471, z = 7}, type = MAPMARK_TEMPLE, description = "Pokemon Center"},
    {position = {x = 3964, y = 448, z = 7}, type = MAPMARK_BAG, description = "Food Shop and Furniture Shop"},
    {position = {x = 3969, y = 462, z = 7}, type = MAPMARK_SWORD, description = "GYM"},
    {position = {x = 3876, y = 487, z = 7}, type = MAPMARK_STAR, description = "Silph Co."},
    {position = {x = 4006, y = 464, z = 7}, type = MAPMARK_STAR, description = "Guild House"},
    {position = {x = 3895, y = 464, z = 7}, type = MAPMARK_STAR, description = "Travel Fly"},
    {position = {x = 3886, y = 464, z = 7}, type = MAPMARK_STAR, description = "Travel Balloon"},
    {position = {x = 3945, y = 454, z = 7}, type = MAPMARK_BAG, description = "Berry Shop"},
}

GUIDES["Celadon"] = { -- Guide Augustine
    {position = {x = 3677, y = 423, z = 7}, type = MAPMARK_DOLLAR, description = "Poke Mart, Bank and Berries Shop"},
    {position = {x = 3701, y = 436, z = 7}, type = MAPMARK_TEMPLE, description = "Pokemon Center"},
    {position = {x = 3672, y = 415, z = 7}, type = MAPMARK_BAG, description = "Food Shop"},
    {position = {x = 3662, y = 405, z = 7}, type = MAPMARK_SWORD, description = "GYM"},
    {position = {x = 3688, y = 405, z = 7}, type = MAPMARK_STAR, description = "Shopping"},
    {position = {x = 3729, y = 466, z = 7}, type = MAPMARK_STAR, description = "Guild House"},
    {position = {x = 3689, y = 450, z = 7}, type = MAPMARK_STAR, description = "Ranger Club"},
    {position = {x = 3657, y = 476, z = 7}, type = MAPMARK_STAR, description = "Travel Fly"},
    {position = {x = 3630, y = 443, z = 7}, type = MAPMARK_STAR, description = "Casino"},
}

GUIDES["Vermilion"] = { -- Guide Ron
    {position = {x = 3925, y = 636, z = 7}, type = MAPMARK_DOLLAR, description = "Poke Mart"},
    {position = {x = 3968, y = 640, z = 7}, type = MAPMARK_TEMPLE, description = "Pokemon Center"},
    {position = {x = 3902, y = 643, z = 7}, type = MAPMARK_BAG, description = "Food Shop"},
    {position = {x = 3965, y = 660, z = 7}, type = MAPMARK_BAG, description = "Berries Shop"},
    {position = {x = 3965, y = 627, z = 7}, type = MAPMARK_BAG, description = "Furniture Shop"},
    {position = {x = 3929, y = 661, z = 7}, type = MAPMARK_SWORD, description = "GYM"},
    {position = {x = 3865, y = 637, z = 7}, type = MAPMARK_STAR, description = "S. S. Anne"},
    {position = {x = 4007, y = 639, z = 7}, type = MAPMARK_STAR, description = "Travel Fly"},
    {position = {x = 3902, y = 593, z = 7}, type = MAPMARK_STAR, description = "Guild House"},
    {position = {x = 3941, y = 591, z = 7}, type = MAPMARK_STAR, description = "Ranger Club"},
}

GUIDES["Fuchsia"] = { -- Guide Weldon
    {position = {x = 3893, y = 842, z = 7}, type = MAPMARK_DOLLAR, description = "Poke Mart and Bank"},
    {position = {x = 3860, y = 844, z = 7}, type = MAPMARK_TEMPLE, description = "Pokemon Center"},
    {position = {x = 3847, y = 841, z = 7}, type = MAPMARK_BAG, description = "Food Shop"},
    {position = {x = 3828, y = 846, z = 7}, type = MAPMARK_BAG, description = "Berries Shop"},
    {position = {x = 3922, y = 794, z = 7}, type = MAPMARK_STAR, description = "Safari Zone Center"},
    {position = {x = 3857, y = 808, z = 7}, type = MAPMARK_SWORD, description = "GYM"},
    {position = {x = 3824, y = 802, z = 7}, type = MAPMARK_STAR, description = "Guild House"},
    {position = {x = 3879, y = 854, z = 7}, type = MAPMARK_STAR, description = "Ranger Club"},
    {position = {x = 3841, y = 873, z = 7}, type = MAPMARK_BAG, description = "Furniture Shop"},
}

GUIDES["Cinnabar"] = { -- Guide Fran
    {position = {x = 3348, y = 1049, z = 7}, type = MAPMARK_DOLLAR, description = "Poke Mart and Bank"},
    {position = {x = 3370, y = 1048, z = 7}, type = MAPMARK_TEMPLE, description = "Pokemon Center"},
    {position = {x = 3336, y = 1015, z = 7}, type = MAPMARK_BAG, description = "Food Shop"},
    {position = {x = 3384, y = 1030, z = 7}, type = MAPMARK_BAG, description = "Berries Shop"},
    {position = {x = 3366, y = 1006, z = 7}, type = MAPMARK_SWORD, description = "GYM"},
    {position = {x = 3373, y = 1075, z = 7}, type = MAPMARK_STAR, description = "S. S. Anne"},
    {position = {x = 3398, y = 1000, z = 7}, type = MAPMARK_STAR, description = "Guild House"},
}

GUIDES["Lavender"] = { -- Guide Darby
    {position = {x = 4170, y = 572, z = 7}, type = MAPMARK_DOLLAR, description = "Poke Mart and Bank"},
    {position = {x = 4188, y = 554, z = 7}, type = MAPMARK_TEMPLE, description = "Pokemon Center"},
    {position = {x = 4215, y = 574, z = 7}, type = MAPMARK_BAG, description = "Food Shop"},
    {position = {x = 4136, y = 553, z = 7}, type = MAPMARK_STAR, description = "Travel Fly"},
    {position = {x = 4179, y = 552, z = 7}, type = MAPMARK_STAR, description = "Ranger Club"},
    {position = {x = 4210, y = 551, z = 7}, type = MAPMARK_BAG, description = "Berries Shop"},
}

GUIDES["Tutorial"] = {
    {position = {x = 5018, y = 758, z = 7}, type = MAPMARK_DOLLAR, description = "Poke Mart"},
    {position = {x = 5033, y = 741, z = 7}, type = MAPMARK_TEMPLE, description = "Pokemon Center"},
    {position = {x = 5020, y = 788, z = 7}, type = MAPMARK_STAR, description = "Professor Oak Lab"},
}

-- the guide marks' icons (scripts/mapper/make_mark_icons.py), from the first words in a mark's name
-- that have one; a gym shows its town's badge
local MARKS = '/modules/game_minimap/images/marks/'
local MARK_SIZE = { width = 14, height = 14 }
local MARK_WORDS = {
    { 'pokemon center', 'center' }, { 'poke mart', 'mart' }, { 'gym', 'gym' }, { 'food', 'food' },
    { 'berr', 'berry' }, { 'furniture', 'furniture' }, { 'bike', 'bike' }, { 'shopping', 'shopping' },
    { 'guild', 'guild' }, { 'ranger', 'ranger' }, { 'daycare', 'daycare' }, { 'casino', 'casino' },
    { 'museum', 'museum' }, { 'safari', 'safari' }, { 'silph', 'silph' }, { 'oak', 'lab' },
    { 'travel ship', 'ship' }, { 's. s. anne', 'ship' }, { 'travel fly', 'fly' }, { 'travel train', 'train' },
    { 'travel balloon', 'balloon' },
}
local GYM_BADGES = {
    Pewter = 'boulder', Cerulean = 'cascade', Vermilion = 'thunder', Celadon = 'rainbow', Fuchsia = 'soul',
    Saffron = 'marsh', Cinnabar = 'volcano', Viridian = 'earth',
}

local function markIcon(town, description)
    local name = description:lower()
    local icon, at
    for _, entry in ipairs(MARK_WORDS) do
        local found = name:find(entry[1], 1, true)
        if found and (not at or found < at) then
            icon, at = entry[2], found
        end
    end
    if icon == 'gym' and GYM_BADGES[town] then
        icon = 'gym_' .. GYM_BADGES[town]
    end
    return MARKS .. (icon or 'place')
end

for town, marks in pairs(GUIDES) do
    for _, mark in ipairs(marks) do
        mark.icon = markIcon(town, mark.description)
    end
end

local cityLabels = {}
local guidesEnabled = true

local function removeGuides(minimap)
    for _, city in pairs(GUIDES) do
        for _, mark in pairs(city) do
            local flag = minimap:getFlag(mark.position, mark.type, tr(mark.description))
            if flag then
                flag:destroy()
            end
        end
    end
end

local function addGuides(minimap)
    for _, city in pairs(GUIDES) do
        for _, mark in pairs(city) do
            minimap:addFlag(mark.position, mark.icon, tr(mark.description), true)
            local flag = minimap:getFlag(mark.position)
            if flag and flag.icon == mark.icon then
                flag:setSize(MARK_SIZE)
            end
        end
    end
end

-- Position readout at the bottom of the minimap (and the full map): the player's position,
-- or the tile under the mouse while hovering the map. A click on it copies the text.
local coordsLabel = nil

local function formatPosition(pos)
    return string.format('%d, %d, %d', pos.x, pos.y, pos.z)
end

local function showPlayerPosition()
    if not coordsLabel then
        return
    end
    local player = g_game.getLocalPlayer()
    local pos = player and player:getPosition()
    coordsLabel:setText(pos and formatPosition(pos) or '')
end

local function createCoordsLabel(minimap)
    coordsLabel = g_ui.createWidget('UILabel', minimap)
    coordsLabel:setId('coordsLabel')
    coordsLabel:addAnchor(AnchorLeft, 'parent', AnchorLeft)
    coordsLabel:addAnchor(AnchorBottom, 'parent', AnchorBottom)
    coordsLabel:setMarginLeft(1)
    coordsLabel:setMarginBottom(1)
    coordsLabel:setFont('verdana-11px-rounded')
    coordsLabel:setColor('#ffffff')
    coordsLabel:setBackgroundColor('#000000aa')
    coordsLabel:setPaddingLeft(3)
    coordsLabel:setPaddingRight(3)
    coordsLabel:setTextAutoResize(true)
    coordsLabel:setPhantom(false)
    coordsLabel:setTooltip(tr('Click to copy the position'))
    coordsLabel.onClick = function(widget)
        local text = widget:getText()
        if text ~= '' then
            g_window.setClipboardText(text)
            modules.game_textmessage.displayStatusMessage(tr('Position copied: %s', text))
        end
        return true
    end

    minimap.onMouseMove = function(widget, mousePos)
        -- the map keeps receiving moves over the label, which copies the player's position
        if coordsLabel:containsPoint(mousePos) then
            showPlayerPosition()
            return false
        end
        local pos = widget:getTilePosition(mousePos)
        if pos and pos.x > 0 and pos.x < 65535 then
            coordsLabel:setText(formatPosition(pos))
        end
        return false
    end
    minimap.onHoverChange = function(widget, hovered)
        if not hovered then
            showPlayerPosition()
        end
    end
end

PokeverseMap = {}

function PokeverseMap.load(minimap)
    g_minimap.loadImage('/images/map', { x = 0, y = 0, z = 7 }, 0.5)

    if not coordsLabel or coordsLabel:isDestroyed() then
        createCoordsLabel(minimap)
    end
    mapController:registerEvents(LocalPlayer, {
        onPositionChange = showPlayerPosition
    })
    showPlayerPosition()

    for _, label in pairs(cityLabels) do
        label:destroy()
    end
    cityLabels = {}
    for _, city in ipairs(MAP_LABELS) do
        if city.kind == 'city' then
            local label = g_ui.createWidget('MinimapFlag')
            minimap:insertChild(1, label)
            label.pos = city.position
            label:setText(city.name)
            label:setFont('sans-bold-16px')
            label:setTextAutoResize(true)
            label:setVisible(minimap.fullMapView == true)
            minimap:centerInPosition(label, label.pos)
            cityLabels[#cityLabels + 1] = label
        end
    end

    if modules.client_options and modules.client_options.getOption then
        guidesEnabled = modules.client_options.getOption('displayMapGuides') ~= false
    end
    removeGuides(minimap)
    if guidesEnabled then
        addGuides(minimap)
    end
end

-- the region a position is in: MAP_REGIONS' boxes in order, the rest is Kanto
function PokeverseMap.regionAt(pos)
    for _, region in ipairs(MAP_REGIONS) do
        if region.from and pos.x >= region.from.x and pos.x <= region.to.x and pos.y >= region.from.y and
            pos.y <= region.to.y then
            return region.id
        end
    end
    return 'kanto'
end

function PokeverseMap.getRegions()
    return MAP_REGIONS
end

function PokeverseMap.getLabels()
    return MAP_LABELS
end

-- the Pokepedia map's Places list: { { name, town, region, kind, position, type, icon } }. Towns
-- (kind 'town'), routes and landmarks have no type; a route's or landmark's town is its group's name.
function PokeverseMap.getPlaces()
    local places = {}
    local townRegion = {}
    for _, label in ipairs(MAP_LABELS) do
        local place = { name = label.name, region = label.region, kind = label.kind, position = label.position }
        if label.kind == 'city' then
            place.kind = 'town'
            place.town = label.name
            townRegion[label.name] = label.region
        elseif label.kind == 'route' then
            place.town = tr('Routes')
        else
            place.town = tr('Landmarks')
        end
        places[#places + 1] = place
    end
    for town, marks in pairs(GUIDES) do
        local region = townRegion[town] or (marks[1] and PokeverseMap.regionAt(marks[1].position)) or 'kanto'
        for _, mark in ipairs(marks) do
            places[#places + 1] = { name = tr(mark.description), town = town, region = region, position = mark.position,
                type = mark.type, icon = mark.icon }
        end
    end
    return places
end

function PokeverseMap.setFullMapView(fullMapView)
    for _, label in pairs(cityLabels) do
        label:setVisible(fullMapView)
    end
end

function setGuidesDisplay(enabled)
    guidesEnabled = enabled
    local minimap = getMiniMapUi()
    if not minimap then
        return
    end
    removeGuides(minimap)
    if enabled and g_game.isOnline() then
        addGuides(minimap)
    end
end
