-- Name plates over creatures (drawn by the engine) and the Pokedex mark on wild Pokemon:
-- a mini Pokedex once the species is registered, a Poke Ball once one is caught.
-- The same mark follows the wild Pokemon's name in the battle list, with the Ranger radar's mark on
-- the Pokemon it is tracking.
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

local RADAR_MARK = '/modules/game_radar/images/battle_mark'

local speciesIcons = {}
local summonOwners = {}
local trackedId -- the creature the Ranger radar is tracking (game_radar)
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

local function markWidget(button, id, size)
    local mark = button:getChildById(id)
    if not mark and button:getChildById('label') then
        mark = g_ui.createWidget('UIWidget', button)
        mark:setId(id)
        mark:setSize({ width = size, height = size })
        mark:setPhantom(true)
        mark:setMarginLeft(3)
    end
    return mark
end

local function placeMark(mark, after)
    mark:breakAnchors()
    mark:addAnchor(AnchorLeft, after, AnchorRight)
    mark:addAnchor(AnchorVerticalCenter, 'label', AnchorVerticalCenter)
end

-- after the name: the Pokedex mark, then the Ranger radar's mark on the Pokemon it is tracking
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
    else
        mark = markWidget(button, 'pokedexMark', 9)
        if mark then
            placeMark(mark, 'label')
            mark:setImageSource(ICON_IMAGES[icon])
            mark:show()
        end
    end

    local radar = button:getChildById('radarMark')
    if not creature or creature:getId() ~= trackedId then
        if radar then
            radar:hide()
        end
        return
    end
    radar = markWidget(button, 'radarMark', 11)
    if radar then
        placeMark(radar, mark and mark:isVisible() and 'pokedexMark' or 'label')
        radar:setImageSource(RADAR_MARK)
        radar:show()
    end
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
    if modules.game_battle and modules.game_battle.refreshPartyFilter then
        modules.game_battle.refreshPartyFilter()
    end
end

function Nameplates.getSummonOwner(creatureId)
    return summonOwners[creatureId]
end

function Nameplates.getTracked()
    return trackedId
end

function Nameplates.setTracked(creatureId)
    if trackedId ~= creatureId then
        trackedId = creatureId
        refreshBattleList()
        if modules.game_battle and modules.game_battle.refreshTracked then
            modules.game_battle.refreshTracked()
        end
    end
end

local function onGameEnd()
    Creature.clearPlateSpeciesIcons()
    Creature.clearPlateOwners()
    speciesIcons = {}
    summonOwners = {}
    trackedId = nil
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
            for _, id in ipairs({ 'pokedexMark', 'radarMark' }) do
                local mark = button:getChildById(id)
                if mark then
                    mark:destroy()
                end
            end
        end
    end
    battleButtons = setmetatable({}, { __mode = 'k' })
    Creature.setDrawPlates(false)
    Creature.clearPlateSpeciesIcons()
    Creature.clearPlateOwners()
    speciesIcons = {}
    summonOwners = {}
    trackedId = nil
end
