-- Name plates over creatures (drawn by the engine) and the Pokedex mark on wild Pokemon:
-- a mini Pokedex once the species is registered, a Poke Ball once one is caught.
Nameplates = {}

local DEX_UNKNOWN = 0
local DEX_REGISTERED = 1

local ICON_NONE = 0
local ICON_REGISTERED = 1
local ICON_CAUGHT = 2

local function iconForStatus(status)
    if status == DEX_UNKNOWN or status == nil then
        return ICON_NONE
    elseif status == DEX_REGISTERED then
        return ICON_REGISTERED
    end
    return ICON_CAUGHT
end

local function setSpecies(number, status)
    local name = getPokemonNameByNumber(number)
    if not name then
        return
    end
    local icon = iconForStatus(status)
    Creature.setPlateSpeciesIcon(name, icon)
    Creature.setPlateSpeciesIcon('Shiny ' .. name, icon)
end

local function onPokedexStatus(status)
    Creature.clearPlateSpeciesIcons()
    for number, value in pairs(status) do
        setSpecies(number, value)
    end
end

local function onPokedexUpdate(number, status)
    setSpecies(number, status)
end

local function onGameEnd()
    Creature.clearPlateSpeciesIcons()
end

function Nameplates.init()
    Creature.setDrawPlates(true)
    connect(g_game, {
        onPokedexStatus = onPokedexStatus,
        onPokedexUpdate = onPokedexUpdate,
        onGameEnd = onGameEnd
    })
end

function Nameplates.terminate()
    disconnect(g_game, {
        onPokedexStatus = onPokedexStatus,
        onPokedexUpdate = onPokedexUpdate,
        onGameEnd = onGameEnd
    })
    Creature.setDrawPlates(false)
    Creature.clearPlateSpeciesIcons()
end
