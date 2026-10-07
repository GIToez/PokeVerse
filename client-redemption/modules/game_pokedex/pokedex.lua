local ITEM_STATUS = {}
ITEM_STATUS.UNKNOWN = 0
ITEM_STATUS.DEXED = 1
ITEM_STATUS.CATCHED = 2
ITEM_STATUS.SHINYCATCHED = 3
ITEM_STATUS.DEXED_CATCHED = 4
ITEM_STATUS.DEXED_SHINYCATCHED = 5
ITEM_STATUS.DEXED_CATCHED_SHINYCATCHED = 6
ITEM_STATUS.CATCHED_SHINYCATCHED = 7

local ITEMID_BY_STATUS = {}
ITEMID_BY_STATUS[ITEM_STATUS.CATCHED] = 12854
ITEMID_BY_STATUS[ITEM_STATUS.DEXED_CATCHED] = 12854

ITEMID_BY_STATUS[ITEM_STATUS.DEXED_SHINYCATCHED] = 12855
ITEMID_BY_STATUS[ITEM_STATUS.SHINYCATCHED] = 12855

ITEMID_BY_STATUS[ITEM_STATUS.DEXED_CATCHED_SHINYCATCHED] = 12856
ITEMID_BY_STATUS[ITEM_STATUS.CATCHED_SHINYCATCHED] = 12856

local UNKNOWN_ITEMID = 16410

local SOUND_FILES_FOLDER = "/sounds/cries/"
local SOUND_FADE_DURATION = 0
local DEX_VIEW_COMMAND = '/dexview '

pokedexWindow = nil
panel = nil
local optionsTabBar, detailsPanel, movesPanel, effectivenessPanel, pokePicture, pokeName, pokeId,
    lastSelectedItem, type1, type2, playingSound, family, pokedexButton

local itemStatus = {}
local lastStatus = {}

function hide()
    if pokedexWindow then
        pokedexWindow:hide()
    end
    if pokedexButton then
        pokedexButton:setOn(false)
    end
end

function show()
    if not pokedexWindow:isVisible() then
        local root = pokedexWindow:getParent()
        pokedexWindow:setPosition({
            x = root:getX() + math.max(0, (root:getWidth() - pokedexWindow:getWidth()) / 2),
            y = root:getY() + math.max(0, (root:getHeight() - pokedexWindow:getHeight()) / 2)})
    end
    pokedexWindow:show()
    pokedexWindow:raise()
    pokedexWindow:focus()
    if pokedexButton then
        pokedexButton:setOn(true)
    end
end

function isVisible()
    return pokedexWindow and pokedexWindow:isVisible() or false
end

function getEntryCount()
    return panel and panel:getChildCount() or 0
end

function getStatus(pokemonNumber)
    return lastStatus[pokemonNumber]
end

-- The Pokedex window is opened by the server when the player uses the Pokedex
-- item on himself, so the button just performs that use.
function toggle()
    if isVisible() then
        hide()
        return
    end
    local player = g_game.getLocalPlayer()
    local dex = player and player:getInventoryItem(InventorySlotLeft)
    if not dex then
        modules.game_textmessage.displayFailureMessage(tr('You do not have a Pokedex.'))
        return
    end
    g_game.useWith(dex, player)
end

local function reset()
    panel:destroyChildren()
    itemStatus = {}
    lastStatus = {}
    lastSelectedItem = nil
end

local function updateItem(item, status)
    local id = tonumber(item:getId())

    local itemId = 0
    if (id <= 151) then
        itemId = 11873 + id
    elseif (id <= 251) then
        itemId = (15798 - 151) + id
    else
        itemId = (27108 - 251) + id
    end

    item:setItemId(((status ~= ITEM_STATUS.UNKNOWN and status ~= ITEM_STATUS.CATCHED and
            status ~= ITEM_STATUS.SHINYCATCHED and status ~= ITEM_STATUS.CATCHED_SHINYCATCHED) and
            itemId) or UNKNOWN_ITEMID)

    if (status ~= ITEM_STATUS.UNKNOWN) then
        item.onMouseRelease = function(self, mousePosition, mouseButton)
            g_game.talk(DEX_VIEW_COMMAND .. id)
            return true
        end

    else
        item.onMouseRelease = function(self, mousePosition, mouseButton)
            onPokedexInfoUnknown()
            return true
        end
    end

    id = item:getId()
    if (itemStatus[id]) then
        item:destroyChildren() --itemStatus[id]:destroy()
        itemStatus[id] = nil
    end

    local statusItem
    if (ITEMID_BY_STATUS[status]) then
        statusItem = g_ui.createWidget('DexStatusItem', item)
        statusItem:setItemId(ITEMID_BY_STATUS[status])
        statusItem:fill('parent')
    end

    itemStatus[id] = statusItem
end

--

function onPokedexUpdate(pokemonNumber, status)
    lastStatus[pokemonNumber] = status
    for k, v in pairs(panel:getChildren()) do
        if (tonumber(v:getId()) == pokemonNumber) then
            updateItem(v, status)
            break
        end
    end
end

function onPokedexStatus(status)
    -- Sent at login and every time the Pokedex is opened or upgraded.
    reset()
    for k, v in ipairs(status) do
        lastStatus[k] = v
        local item = g_ui.createWidget('Item', panel)
        item:setId(k)
        item:setMargin(0)
        item:setVirtual(true)

        updateItem(item, v)
    end

    if (#status <= 151) then
        pokedexWindow:getChildById('dexItem'):setItemId(11242)
    else
        pokedexWindow:getChildById('dexItem'):setItemId(16808)
    end
end

-- Second details line is "Type: Grass and Poison", localised by the server
-- (pt: "Tipo: Grama e Venenoso"), so split on both forms of " and ".
local function extractTypes(msg)
    local value = (msg:match("^[^\n]*\n([^\n]*)") or ""):match(":%s*(.-)%s*$") or ""
    local ids = {}
    for _, separator in ipairs({' and ', tr(' and ')}) do
        local parts = value:split(separator)
        if #parts > 1 or separator == ' and ' then
            ids = {}
            for _, name in ipairs(parts) do
                local id = getTypeIdByName(name:trim())
                if id then
                    ids[#ids + 1] = id
                end
            end
            if #ids > 1 then
                break
            end
        end
    end
    return ids[1], ids[2]
end

local function getSoundChannel()
    if not g_sounds or not SoundChannels then
        return nil
    end
    return g_sounds.getChannel(SoundChannels.Effect)
end

local function stopSound()
    local channel = getSoundChannel()
    if channel then
        channel:stop(SOUND_FADE_DURATION)
    end
    playingSound = nil
end

local function playSound(sound)
    local channel = getSoundChannel()
    if not channel or not g_resources.fileExists(sound .. '.ogg') then
        return
    end
    stopSound()
    channel:play(sound .. '.ogg', SOUND_FADE_DURATION, channel:getGain())
    playingSound = sound
end

local MOVE_COLUMNS = {
    {name = '#', width = 24},
    {name = 'Type', short = 'T', width = 24},
    {name = 'Name', width = 114},
    {name = 'Category', short = 'Cat.', width = 30},
    {name = 'Power', width = 80},
    {name = 'Energy', short = 'En', width = 20},
    {name = 'Level', width = 71},
    {name = 'Cooldown', short = 'Cd', width = 20},
    {name = 'Range', width = 55},
}

local function buildMoveHeader()
    local typebar = movesPanel:recursiveGetChildById('typebar')
    if not typebar or typebar:getChildCount() > 0 then
        return
    end
    for i, column in ipairs(MOVE_COLUMNS) do
        local widget = g_ui.createWidget('UIWidget', typebar)
        if i == 1 then
            widget:addAnchor(AnchorLeft, 'parent', AnchorLeft)
            widget:setMarginLeft(5)
        else
            widget:addAnchor(AnchorLeft, 'prev', AnchorRight)
        end
        if i == #MOVE_COLUMNS then
            widget:addAnchor(AnchorRight, 'parent', AnchorRight)
        else
            widget:setWidth(column.width)
        end
        widget:addAnchor(AnchorTop, 'parent', AnchorTop)
        widget:addAnchor(AnchorBottom, 'parent', AnchorBottom)
        widget:setFont('verdana-11px-rounded')
        widget:setColor('#e7e7e7')
        widget:setTextAlign(AlignCenter)
        widget:setText(column.short or (column.name == '#' and '#' or tr(column.name)))
        if column.short then
            widget:setTooltip(tr(column.name))
        else
            widget:setPhantom(true)
        end
    end
end

local function updateMovesSection(moves)
    local movesContent = movesPanel:recursiveGetChildById('content')
    movesContent:destroyChildren()

    local categories = MOVE_COLUMNS

    moves = moves:split(";")

    for __, moveInfos in pairs(moves) do
        local moveLine = g_ui.createWidget('PokedexMoveSection', movesContent)
        if movesContent:getChildCount() == 1 then
            moveLine:addAnchor(AnchorTop, 'parent', AnchorTop)
        else
            moveLine:addAnchor(AnchorTop, 'prev', AnchorBottom)
        end
        moveLine:addAnchor(AnchorLeft, 'parent', AnchorLeft)
        moveLine:addAnchor(AnchorRight, 'parent', AnchorRight)
        moveLine:setHeight(32)

        for j, info in pairs(moveInfos:split(",")) do
            local widget = g_ui.createWidget('UIWidget', moveLine)

            if (j ~= 1) then
                widget:addAnchor(AnchorLeft, 'prev', AnchorRight)
            else
                widget:addAnchor(AnchorLeft, 'parent', AnchorLeft)
            end

            if (j == #MOVE_COLUMNS) then
                widget:addAnchor(AnchorRight, 'parent', AnchorRight)
            else
                widget:setWidth(categories[j] and categories[j].width or 20)
            end

            widget:addAnchor(AnchorTop, 'parent', AnchorTop)
            widget:addAnchor(AnchorBottom, 'parent', AnchorBottom)

            if (j == 2) then -- Type
                widget:setImageSource("/images/types/" .. info)
                widget:setTooltip(getTypeNameById(info))
            elseif (j == 3) then -- Name
                widget:setText(info)
                widget:setTooltip(getMoveDescriptionByName(info))
            elseif (j == 4) then -- Category
                widget:setImageSource("/images/moveCategories/" .. info)
                widget:setTooltip(getMoveCategoryNameById(info))
            else
                widget:setText(info)
            end
        end
    end
end

function onPokedexInfo(pokemonId, details, moves, effectiveness, families)
    pokePicture:setImageSource("/images/pokemon_image/" .. getPokemonNameByNumber(pokemonId))
    pokeName:setText(getPokemonNameByNumber(pokemonId))
    pokeId:setText(string.format("#%03d", pokemonId))

    local type1Id, type2Id = extractTypes(details)
    if (type1Id) then
        type1:setImageSource("/images/types/" .. type1Id)
        type1:setTooltip(getTypeNameById(type1Id))
    else
        type1:setImageSource("")
        type1:setTooltip("")
    end

    if (type2Id) then
        type2:setImageSource("/images/types/" .. type2Id)
        type2:setTooltip(getTypeNameById(type2Id))
    else
        type2:setImageSource("")
        type2:setTooltip("")
    end

    family:destroyChildren()
    families = families:split(",") or families
    for k, v in pairs(families) do
        local widget = g_ui.createWidget('UIWidget', family)
        widget:setImageSource("/images/pokemon_image/" .. getPokemonNameByNumber(v))
        widget:setTooltip(getPokemonNameByNumber(v))
        widget.onMouseRelease = function(self, mousePosition, mouseButton)
            g_game.talk(DEX_VIEW_COMMAND .. v)
            return true
        end
    end

    local text = detailsPanel:recursiveGetChildById('aaaText')
    if (text) then
        text:setText(details)
    end
    text = nil

    --[[text = movesPanel:recursiveGetChildById('aaaText')
    if (text) then
        text:setText(moves)
    end
    text = nil]]
    updateMovesSection(moves)

    --[[
    text = effectivenessPanel:recursiveGetChildById('aaaText')
    if (text) then
        text:setText(effectiveness)
    end
    text = nil

    text = effectivenessPanel:recursiveGetChildById('aaaText')
    if (text) then
        text:setText(effectiveness)
    end
    text = nil
    ]]
    local content = effectivenessPanel:recursiveGetChildById('content')
    content:destroyChildren()
    effectiveness = effectiveness:explode(";")

    local first = true
    for k, sectionName in pairs({'Normal', 'Immune', 'Resistant', 'Weak'}) do
        local section = g_ui.createWidget('PokedexEffectSection', content)
        section:addAnchor(AnchorLeft, 'parent', AnchorLeft)
        section:addAnchor(AnchorRight, 'parent', AnchorRight)
        if (first) then
            section:addAnchor(AnchorTop, 'parent', AnchorTop)
            first = nil
        else
            section:addAnchor(AnchorTop, 'prev', AnchorBottom)
        end

        local header = g_ui.createWidget('UIWidget', section)
        header:setWidth(80)
        header:addAnchor(AnchorLeft, 'parent', AnchorLeft)
        header:addAnchor(AnchorTop, 'parent', AnchorTop)
        header:addAnchor(AnchorBottom, 'parent', AnchorBottom)
        header:setText(tr(sectionName))

        local typeBox = g_ui.createWidget('PokedexTypeBox', section)
        typeBox:addAnchor(AnchorLeft, 'prev', AnchorRight)
        typeBox:addAnchor(AnchorRight, 'parent', AnchorRight)
        typeBox:addAnchor(AnchorTop, 'parent', AnchorTop)
        typeBox:addAnchor(AnchorBottom, 'parent', AnchorBottom)

        if (effectiveness[k] and effectiveness[k] ~= "") then
            local types = effectiveness[k]:split(",")
            for _, type in pairs(types) do
                local widget = g_ui.createWidget('UIWidget', typeBox)
                widget:setImageSource("/images/types/" .. type)
                widget:setTooltip(getTypeNameById(type))
            end
            section:setHeight(25 + (math.ceil(#types / 25) * 25)) -- (margem + preenchimento) + # tipos / 5 por linha * altura da imagem
        else
            section:setHeight(25)
        end
    end
    content = nil

    if (lastSelectedItem) then
        lastSelectedItem:setBorderWidth(0)
    end

    for k, v in pairs(panel:getChildren()) do
        if (tonumber(v:getId()) == pokemonId) then
            v:setBorderColor('white')
            v:setBorderWidth(1)
            lastSelectedItem = v
            break
        end
    end

    playSound(SOUND_FILES_FOLDER .. pokemonId)
    show()
end

function onPokedexInfoUnknown()
    pokeName:setText(tr("Unknown"))
    pokeId:setText("#000")
    family:destroyChildren()

    local text = detailsPanel:recursiveGetChildById('aaaText')
    if (text) then
        text:setText("???")
    end
    text = nil

    text = movesPanel:recursiveGetChildById('content')
    if (text) then
        text:destroyChildren()
    end
    text = nil

    text = effectivenessPanel:recursiveGetChildById('content')
    if (text) then
        text:destroyChildren()
    end
    text = nil

    type1:setImageSource("")
    type1:setTooltip("")

    type2:setImageSource("")
    type2:setTooltip("")
end

function onPokedexOpen()
    show()
end

-- The status list may arrive in the same batch as the login packets, so the
-- grid is cleared on logout instead of on game start.
function onOnline()
end

function selectTab(index)
    local tab = optionsTabBar:getTabs()[index]
    if tab then
        optionsTabBar:selectTab(tab)
    end
end

function getMoveRowCount()
    local content = movesPanel and movesPanel:recursiveGetChildById('content')
    return content and content:getChildCount() or 0
end

function onOffline()
    hide()
    stopSound()
    reset()
end

function onInit()
    g_ui.importStyle('pokedex')

    connect(g_game, {
        onGameStart = onOnline,
        onGameEnd = onOffline,
        onPokedexUpdate = onPokedexUpdate,
        onPokedexStatus = onPokedexStatus,
        onPokedexOpen = onPokedexOpen,
        onPokedexInfo = onPokedexInfo})

    pokedexWindow = g_ui.createWidget('DexWindow', modules.game_interface.getRootPanel())
    pokedexWindow:setVisible(false)
    pokedexWindow:getChildById('dexItem'):setItemId(11242)
    pokedexWindow.onEscape = hide

    panel = pokedexWindow:recursiveGetChildById('ownDexContainer')

    pokePicture = pokedexWindow:recursiveGetChildById('pokePicture')
    family = pokedexWindow:recursiveGetChildById('family')
    pokeName = pokedexWindow:recursiveGetChildById('pokeName')
    pokeId = pokedexWindow:recursiveGetChildById('pokeId')
    type1 = pokedexWindow:recursiveGetChildById('pokeType1')
    type2 = pokedexWindow:recursiveGetChildById('pokeType2')

    optionsTabBar = pokedexWindow:recursiveGetChildById('optionsTabBar')
    optionsTabBar:setContentWidget(pokedexWindow:recursiveGetChildById('optionsTabContent'))
    optionsTabBar:recursiveGetChildById('buttonsPanel'):setImageSource("")

    detailsPanel = g_ui.loadUI('details')
    optionsTabBar:addTab(tr('Information'), detailsPanel, '/modules/game_pokedex/images/tab_info')

    movesPanel = g_ui.loadUI('moves')
    optionsTabBar:addTab(tr('Moves'), movesPanel, '/modules/game_pokedex/images/tab_moves')

    effectivenessPanel = g_ui.loadUI('effectiveness')
    optionsTabBar:addTab(tr('Types'), effectivenessPanel, '/modules/game_pokedex/images/tab_types')
    buildMoveHeader()

    onPokedexInfoUnknown()

    if modules.game_mainpanel then
        pokedexButton = modules.game_mainpanel.addToggleButton('pokedexButton', tr('Pokedex'),
            '/modules/game_pokedex/images/button', toggle, false, 6)
    end

    if (g_game.isOnline()) then
        onOnline()
    end
end

function onTerminate()
    disconnect(g_game, {
        onGameStart = onOnline,
        onGameEnd = onOffline,
        onPokedexUpdate = onPokedexUpdate,
        onPokedexStatus = onPokedexStatus,
        onPokedexOpen = onPokedexOpen,
        onPokedexInfo = onPokedexInfo})

    reset()
    if pokedexButton then
        pokedexButton:destroy()
        pokedexButton = nil
    end
    pokedexWindow:destroyChildren()
    pokedexWindow:destroy()
end