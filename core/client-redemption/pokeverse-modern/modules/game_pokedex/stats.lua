-- Stat overview of your own Pokemon beside the Pokedex: IVs and EVs on a radar chart, the official
-- stats and the Nature, from the sheet the server sends after the Pokedex shows one of your Pokemon
-- (PokemonStats.getStatSheet)
local statsInit = onInit
local statsTerminate = onTerminate

local IV_FILL, IV_LINE = '#5aa0e660', '#5aa0e6'
local EV_FILL, EV_LINE = '#e6c34a60', '#e6c34a'
local RAISED_COLOR, LOWERED_COLOR, NEUTRAL_COLOR = '#ff7a70', '#7ab0ff', '#dfdfdf'
local LABEL_DISTANCE = 1.2
local STAT_COUNT = 6

local statsWindow
local viewGroup
local ivLayer, evLayer
local axisLabels = {}
local axisMarks = {}
local rows = {}

local function markImage(stat, nature)
    if nature.up ~= nature.down then
        if stat == nature.up then
            return '/modules/game_pokedex/images/stat-up'
        elseif stat == nature.down then
            return '/modules/game_pokedex/images/stat-down'
        end
    end
    return '/modules/game_pokedex/images/stat-neutral'
end

local function statColor(stat, nature)
    if nature.up ~= nature.down then
        if stat == nature.up then
            return RAISED_COLOR
        elseif stat == nature.down then
            return LOWERED_COLOR
        end
    end
    return NEUTRAL_COLOR
end

local function applyView()
    local selected = viewGroup:getSelectedWidget()
    local id = selected and selected:getId() or 'viewCombined'
    local radar = statsWindow.radar
    radar:setLayerVisible(ivLayer, id ~= 'viewEvs')
    radar:setLayerVisible(evLayer, id ~= 'viewIvs')
end

local function placeWindow()
    local root = modules.game_interface.getRootPanel()
    local x, y = root:getX(), root:getY()
    if pokedexWindow and pokedexWindow:isVisible() then
        local width = statsWindow:getWidth()
        local right = root:getX() + root:getWidth()
        y = pokedexWindow:getY()
        x = pokedexWindow:getX() + pokedexWindow:getWidth() + 4
        if x + width > right then
            x = pokedexWindow:getX() - width - 4
            -- no room on either side: cover the Pokedex list on the right rather than the entry text
            if x < root:getX() then
                x = right - width
            end
        end
    end
    statsWindow:setPosition({ x = x, y = y })
    statsWindow:bindRectToParent()
    statsWindow:raise()
end

local function showSheet(sheet)
    local nature = sheet.nature or {}
    local names = sheet.statNames or {}
    local ivs, evs = sheet.ivs or {}, sheet.evs or {}
    local actual, effect = sheet.actual or {}, sheet.effect or {}
    local ivMax, evMax = sheet.ivMax or 31, sheet.evMax or 252

    statsWindow.pokemonName:setText(string.format('%s  Lv. %d', sheet.name or '?', sheet.level or 0))
    statsWindow.natureTag:setText(tr('%s Nature', nature.name or '?'))
    statsWindow.natureTag:setWidth(statsWindow.natureTag:getTextSize().width + 14)

    local ivValues, evValues = {}, {}
    for stat = 1, STAT_COUNT do
        ivValues[stat] = math.min(1, (ivs[stat] or 0) / ivMax)
        evValues[stat] = math.min(1, (evs[stat] or 0) / evMax)

        axisLabels[stat]:setText(names[stat] or '')
        axisLabels[stat]:setColor(statColor(stat, nature))
        axisMarks[stat]:setImageSource(markImage(stat, nature))

        local row = rows[stat]
        row.mark:setImageSource(markImage(stat, nature))
        row.name:setText(names[stat] or '')
        row.actual:setText(tostring(actual[stat] or 0))
        row.actual:setColor(statColor(stat, nature))
        row.iv:setText(tostring(ivs[stat] or 0))
        row.iv:setColor(ivs[stat] == ivMax and IV_LINE or NEUTRAL_COLOR)
        row.ev:setText(tostring(evs[stat] or 0))
        row.ev:setColor(evs[stat] == evMax and EV_LINE or NEUTRAL_COLOR)
        local percent = effect[stat] or 0
        row.effect:setText(string.format('%s%d%%', percent >= 0 and '+' or '', percent))
    end
    statsWindow.radar:setLayerValues(ivLayer, ivValues)
    statsWindow.radar:setLayerValues(evLayer, evValues)

    statsWindow.totals:setText(tr('IVs %d/%d (%d perfect)    EVs %d/%d', sheet.ivTotal or 0, ivMax * STAT_COUNT,
        sheet.perfectIvs or 0, sheet.evTotal or 0, sheet.evTotalMax or 510))

    applyView()
    statsWindow:show()
    placeWindow()
end

local function onPokemonStats(protocol, opcode, buffer)
    local ok, sheet = pcall(json.decode, buffer)
    if not ok or type(sheet) ~= 'table' then
        g_logger.warning('Pokedex: invalid Pokemon stat sheet')
        return
    end
    showSheet(sheet)
end

local function hideStats()
    if statsWindow then
        statsWindow:hide()
    end
end

local function onPokedexVisibility(widget, visible)
    if not visible then
        hideStats()
    end
end

local function buildAxes()
    local radar = statsWindow.radar
    for stat = 1, STAT_COUNT do
        local point = radar:getAxisPoint(stat - 1, LABEL_DISTANCE)
        local label = g_ui.createWidget('StatAxisLabel', statsWindow)
        label:addAnchor(AnchorHorizontalCenter, 'radar', AnchorLeft)
        label:addAnchor(AnchorVerticalCenter, 'radar', AnchorTop)
        label:setMarginLeft(point.x)
        label:setMarginTop(point.y)
        axisLabels[stat] = label

        local mark = g_ui.createWidget('StatMark', statsWindow)
        mark:addAnchor(AnchorLeft, 'prev', AnchorRight)
        mark:addAnchor(AnchorVerticalCenter, 'prev', AnchorVerticalCenter)
        mark:setMarginLeft(3)
        axisMarks[stat] = mark
    end
end

local function buildRows()
    local header = statsWindow.header
    header.name:setText(tr('Stat'))
    header.actual:setText(tr('Actual'))
    header.iv:setText(tr('IV'))
    header.ev:setText(tr('EV'))
    header.effect:setText(tr('Effect'))
    for _, cell in ipairs({ header.name, header.actual, header.iv, header.ev, header.effect }) do
        cell:setColor('#9a9a9a')
    end

    for stat = 1, STAT_COUNT do
        rows[stat] = g_ui.createWidget('StatRow', statsWindow.rows)
    end
end

function onInit()
    statsInit()
    g_ui.importStyle('stats')
    statsWindow = g_ui.createWidget('PokemonStatsWindow', modules.game_interface.getRootPanel())
    statsWindow:hide()

    local radar = statsWindow.radar
    ivLayer = radar:addLayer(IV_FILL, IV_LINE, 2)
    evLayer = radar:addLayer(EV_FILL, EV_LINE, 2)
    statsWindow.legend.ivSwatch:setBackgroundColor(IV_FILL)
    statsWindow.legend.ivSwatch:setBorderColor(IV_LINE)
    statsWindow.legend.evSwatch:setBackgroundColor(EV_FILL)
    statsWindow.legend.evSwatch:setBorderColor(EV_LINE)

    buildAxes()
    buildRows()

    viewGroup = UIRadioGroup.create()
    for _, id in ipairs({ 'viewCombined', 'viewIvs', 'viewEvs' }) do
        viewGroup:addWidget(statsWindow[id])
    end
    viewGroup:selectWidget(statsWindow.viewCombined)
    viewGroup.onSelectionChange = applyView

    connect(g_game, { onPokedexInfo = hideStats, onGameEnd = hideStats })
    if pokedexWindow then
        connect(pokedexWindow, { onVisibilityChange = onPokedexVisibility })
    end
    ProtocolGame.registerExtendedOpcode(ExtendedIds.PokemonStats, onPokemonStats)
end

function onTerminate()
    ProtocolGame.unregisterExtendedOpcode(ExtendedIds.PokemonStats)
    disconnect(g_game, { onPokedexInfo = hideStats, onGameEnd = hideStats })
    if pokedexWindow then
        disconnect(pokedexWindow, { onVisibilityChange = onPokedexVisibility })
    end
    if viewGroup then
        viewGroup:destroy()
        viewGroup = nil
    end
    if statsWindow then
        statsWindow:destroy()
        statsWindow = nil
    end
    axisLabels, axisMarks, rows = {}, {}, {}
    statsTerminate()
end
