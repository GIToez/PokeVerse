-- Name plates over creatures (drawn by the engine) and the Pokedex mark on wild Pokemon:
-- a mini Pokedex once the species is registered, a Poke Ball once one is caught.
-- The same mark follows the wild Pokemon's name in the battle list.
Nameplates = {}

local DEX_UNKNOWN = 0
local DEX_REGISTERED = 1

local ICON_NONE = 0
local ICON_REGISTERED = 1
local ICON_CAUGHT = 2

local ICON_IMAGES = {
    [ICON_REGISTERED] = '/modules/game_pokehud/images/plate-dex',
    [ICON_CAUGHT] = '/modules/game_pokehud/images/plate-caught'
}

local speciesIcons = {}
local summonOwners = {}
local battleButtons = setmetatable({}, { __mode = 'k' })
local originalSetup = nil

local function iconForStatus(status)
    if status == DEX_UNKNOWN or status == nil then
        return ICON_NONE
    elseif status == DEX_REGISTERED then
        return ICON_REGISTERED
    end
    return ICON_CAUGHT
end

local function isWild(creature)
    return creature:isMonster() and not creature:isLocalPlayerSummon() and not summonOwners[creature:getId()] and
               creature:isAttackable()
end

-- the server names Pokemon "Name [level]"
local function speciesKey(name)
    return (name:gsub(' %[%d+%]$', '')):lower()
end

local function updateButtonMark(button)
    local creature = button.creature
    local icon = ICON_NONE
    if creature and isWild(creature) then
        icon = speciesIcons[speciesKey(creature:getName())] or ICON_NONE
    end

    local mark = button:getChildById('pokedexMark')
    if icon == ICON_NONE then
        if mark then
            mark:hide()
        end
        return
    end

    if not mark then
        local label = button:getChildById('label')
        if not label then
            return
        end
        mark = g_ui.createWidget('UIWidget', button)
        mark:setId('pokedexMark')
        mark:setSize({ width = 9, height = 9 })
        mark:setPhantom(true)
        mark:addAnchor(AnchorLeft, 'label', AnchorRight)
        mark:addAnchor(AnchorVerticalCenter, 'label', AnchorVerticalCenter)
        mark:setMarginLeft(3)
    end
    mark:setImageSource(ICON_IMAGES[icon])
    mark:show()
end

local function refreshBattleList()
    for button in pairs(battleButtons) do
        if not button:isDestroyed() then
            updateButtonMark(button)
        end
    end
end

local function setupWithMark(self, creature, onlyOutfit)
    originalSetup(self, creature, onlyOutfit)
    battleButtons[self] = true
    updateButtonMark(self)
end

local function setSpecies(number, status)
    local name = getPokemonNameByNumber(number)
    if not name then
        return
    end
    local icon = iconForStatus(status)
    Creature.setPlateSpeciesIcon(name, icon)
    Creature.setPlateSpeciesIcon('Shiny ' .. name, icon)
    speciesIcons[speciesKey(name)] = icon
    speciesIcons[speciesKey('Shiny ' .. name)] = icon
end

local function onPokedexStatus(status)
    Creature.clearPlateSpeciesIcons()
    speciesIcons = {}
    for number, value in pairs(status) do
        setSpecies(number, value)
    end
    refreshBattleList()
end

local function onPokedexUpdate(number, status)
    setSpecies(number, status)
    refreshBattleList()
end

-- "creatureId,ownerId": another trainer's Pokemon, so its plate can follow its trainer's
local function onSummonOwner(protocol, opcode, buffer)
    local creatureId, ownerId = buffer:match('^(%d+),(%d+)$')
    if not creatureId then
        return
    end
    creatureId, ownerId = tonumber(creatureId), tonumber(ownerId)
    summonOwners[creatureId] = ownerId
    Creature.setPlateOwner(creatureId, ownerId)
    refreshBattleList()
end

local function onGameEnd()
    Creature.clearPlateSpeciesIcons()
    Creature.clearPlateOwners()
    speciesIcons = {}
    summonOwners = {}
end

function Nameplates.init()
    Creature.setDrawPlates(true)
    connect(g_game, {
        onPokedexStatus = onPokedexStatus,
        onPokedexUpdate = onPokedexUpdate,
        onGameEnd = onGameEnd
    })
    ProtocolGame.registerExtendedOpcode(ExtendedIds.SummonOwner, onSummonOwner)
    originalSetup = UICreatureButton.setup
    UICreatureButton.setup = setupWithMark
end

function Nameplates.terminate()
    disconnect(g_game, {
        onPokedexStatus = onPokedexStatus,
        onPokedexUpdate = onPokedexUpdate,
        onGameEnd = onGameEnd
    })
    ProtocolGame.unregisterExtendedOpcode(ExtendedIds.SummonOwner)
    if originalSetup then
        UICreatureButton.setup = originalSetup
        originalSetup = nil
    end
    for button in pairs(battleButtons) do
        if not button:isDestroyed() then
            local mark = button:getChildById('pokedexMark')
            if mark then
                mark:destroy()
            end
        end
    end
    battleButtons = setmetatable({}, { __mode = 'k' })
    Creature.setDrawPlates(false)
    Creature.clearPlateSpeciesIcons()
    Creature.clearPlateOwners()
    speciesIcons = {}
    summonOwners = {}
end
