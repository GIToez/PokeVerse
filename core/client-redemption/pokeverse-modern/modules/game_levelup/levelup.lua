-- Level-up and TM banners. The server sends JSON on ExtendedIds.LevelUp (LevelUpBanner in the
-- server lib): kind "pokemon" (stat changes and the moves learned), "trainer" (HP, Pokemon level
-- cap, unlocked features), "tm" (the move taught) or "rank" (a vocation rank-up: the new title and perks).
local IMAGES = '/modules/game_levelup/images/'
local TOP_MARGIN = 128
local SHOW_MS = 4200
local PER_MOVE_MS = 1400
local MOVE_DELAY_MS = 250
local FADE_IN_MS = 300
local FADE_OUT_MS = 500
local SLIDE = 16
local GAP_MS = 200
local MAX_PER_GROUP = 2
local MAX_UNLOCK_BOXES = 4

local STATS = {
    ['HP'] = { label = 'HP', icon = 'stat-hp' },
    ['Attack'] = { label = 'Attack', icon = 'stat-attack' },
    ['Defense'] = { label = 'Defense', icon = 'stat-defense' },
    ['Sp. Attack'] = { label = 'Sp. Atk', icon = 'stat-spattack' },
    ['Sp. Defense'] = { label = 'Sp. Def', icon = 'stat-spdefense' },
    ['Speed'] = { label = 'Speed', icon = 'stat-speed' },
}

local ELEMENTS = { [0] = 'Normal', 'Fight', 'Flying', 'Poison', 'Ground', 'Rock', 'Bug', 'Ghost', 'Steel',
    'Fire', 'Water', 'Grass', 'Electric', 'Psychic', 'Ice', 'Dragon', 'Dark', 'Fairy' }
local CATEGORIES = { [0] = 'Physical', 'Special', 'Status' }

local queue = {}
local stack
local events = {}

local function schedule(fn, delay)
    local event
    event = scheduleEvent(function()
        table.removevalue(events, event)
        fn()
    end, delay)
    table.insert(events, event)
end

local function cancelEvents()
    for _, event in ipairs(events) do
        removeEvent(event)
    end
    events = {}
end

local function clearStack()
    if stack then
        g_effects.cancelFade(stack)
        stack:destroy()
        stack = nil
    end
end

local function reset()
    cancelEvents()
    clearStack()
    queue = {}
end

local function shorten(text, max)
    text = text or ''
    if #text > max then
        return text:sub(1, max - 3) .. '...'
    end
    return text
end

local function addChip(banner, spec)
    local chip = g_ui.createWidget('LevelUpChip', banner.chips)
    chip.icon:setImageSource(spec.icon or '')
    chip.label:setText(spec.label or '')
    chip.value:setText(spec.value or '')
    if not spec.up then
        chip.arrow:hide()
        chip.value:addAnchor(AnchorLeft, 'label', AnchorLeft)
        chip.value:setMarginLeft(0)
        chip.value:setColor(spec.color or '#ffffff')
    end
    if spec.width then
        chip:setWidth(spec.width)
    end
    return chip
end

local function createBanner(parent)
    local banner = g_ui.createWidget('LevelUpBanner', parent)
    return banner
end

local function setPortrait(banner, look, number)
    if look then
        banner.creature:setSize({ width = 96, height = 96 })
        banner.creature:setOutfit({ type = look })
        banner.creature:show()
    elseif number then
        banner.picture:setImageSource('/images/staticPortraits/' .. number)
        banner.picture:show()
    end
end

local function moveDetails(move)
    local parts = {}
    if move.power and move.power ~= '--' and move.power ~= '0' then
        table.insert(parts, tr('Power %s', move.power))
    end
    if move.energy then
        table.insert(parts, tr('Energy %d', move.energy))
    end
    if move.cooldown then
        table.insert(parts, tr('Cooldown %ds', move.cooldown))
    end
    return table.concat(parts, '   ')
end

local function addMoveBox(parent, move, title)
    local box = g_ui.createWidget('LevelUpMoveBox', parent)
    box.title:setText(title)
    box.moveName:setText(move.name or '')
    if move.icon then
        box.iconFrame.icon:setItemId(move.icon)
    end
    if move.element and ELEMENTS[move.element] then
        box.element:setImageSource('/images/types/' .. move.element)
        box.element:setTooltip(tr(ELEMENTS[move.element]))
    else
        box.element:setWidth(0)
    end
    if move.category and CATEGORIES[move.category] then
        box.category:setImageSource('/images/moveCategories/' .. move.category)
        box.category:setTooltip(tr(CATEGORIES[move.category]))
    else
        box.category:setWidth(0)
    end
    box.details:setText(moveDetails(move))
    box.description:setText(shorten(move.description, 92))
    return box
end

local function addUnlockBox(parent, unlock, level)
    local box = g_ui.createWidget('LevelUpMoveBox', parent)
    box.title:setText((unlock.title or tr('New Feature')) .. ':')
    box.moveName:setText(unlock.text or '')
    box.iconFrame.icon:hide()
    local picture = g_ui.createWidget('UIWidget', box.iconFrame)
    picture:setSize({ width = 34, height = 34 })
    picture:addAnchor(AnchorHorizontalCenter, 'parent', AnchorHorizontalCenter)
    picture:addAnchor(AnchorVerticalCenter, 'parent', AnchorVerticalCenter)
    picture:setImageSource(unlock.icon and ('/images/advances/' .. unlock.icon) or (IMAGES .. 'unlock'))
    picture:setPhantom(true)
    box.element:hide()
    box.category:hide()
    box.details:addAnchor(AnchorLeft, 'title', AnchorLeft)
    box.details:setMarginLeft(0)
    if unlock.summary then
        box.details:setText(shorten(unlock.summary, 60))
    else
        box.details:setText(tr('Unlocked at trainer level %d', unlock.level or level or 0))
    end
    return box
end

local function buildPokemon(parent, data)
    local banner = createBanner(parent)
    setPortrait(banner, tonumber(data.look), data.number)
    local gained = (tonumber(data.to) or 0) - (tonumber(data.from) or 0)
    banner.name:setText(shorten(data.name, 16))
    banner.highlight:setText(gained > 1 and tr('+%d Levels!', gained) or tr('Leveled Up!'))
    banner.subtitle:setText(tr('Level %d  ->  %d   -   Stats increased', data.from or 0, data.to or 0))
    for _, stat in ipairs(data.stats or {}) do
        local info = STATS[stat.name] or { label = stat.name, icon = 'unlock' }
        local delta = (tonumber(stat.new) or 0) - (tonumber(stat.old) or 0)
        addChip(banner, {
            icon = IMAGES .. info.icon,
            label = tr(info.label),
            value = string.format('+%d', delta),
            up = delta > 0,
            color = '#8a9ab8'
        })
    end
    local moves = {}
    for _, move in ipairs(data.moves or {}) do
        table.insert(moves, function() return addMoveBox(parent, move, tr('New move:')) end)
    end
    return banner, moves
end

local function buildTrainer(parent, data)
    local banner = createBanner(parent)
    local player = g_game.getLocalPlayer()
    if player then
        banner.creature:setOutfit(player:getOutfit())
        banner.creature:show()
    end
    local gained = (tonumber(data.to) or 0) - (tonumber(data.from) or 0)
    banner.name:setText(tr('Trainer'))
    banner.highlight:setText(gained > 1 and tr('+%d Levels!', gained) or tr('Level Up!'))
    banner.subtitle:setText(tr('Level %d  ->  %d   -   %s', data.from or 0, data.to or 0, data.name or ''))

    local hp = data.hp or {}
    local hpGain = (tonumber(hp.new) or 0) - (tonumber(hp.old) or 0)
    addChip(banner, {
        icon = IMAGES .. 'stat-hp',
        label = tr('Max HP %d', tonumber(hp.new) or 0),
        value = string.format('+%d', hpGain),
        up = hpGain > 0,
        width = 96
    })
    if data.pokemonCap then
        addChip(banner, {
            icon = IMAGES .. 'cap',
            label = tr('Pokemon level cap'),
            value = tr('Level %d', data.pokemonCap),
            up = data.pokemonCap > (tonumber(data.pokemonCapOld) or 0),
            color = '#8a9ab8',
            width = 112
        })
    end
    local unlocks = data.unlocks or {}
    if #unlocks > MAX_UNLOCK_BOXES then
        local rest = {}
        for index = MAX_UNLOCK_BOXES, #unlocks do
            table.insert(rest, unlocks[index].text)
        end
        local shown = { unpack(unlocks, 1, MAX_UNLOCK_BOXES - 1) }
        table.insert(shown, { title = tr('And'), text = tr('%d more features', #rest), summary = table.concat(rest, ', ') })
        unlocks = shown
    end
    local boxes = {}
    for _, unlock in ipairs(unlocks) do
        table.insert(boxes, function() return addUnlockBox(parent, unlock, data.to) end)
    end
    return banner, boxes
end

local function buildTm(parent, data)
    local banner = createBanner(parent)
    setPortrait(banner, tonumber(data.look), data.number)
    banner.badge:show()
    local move = data.move or {}
    banner.name:setText(tr('%s learned', shorten(data.name, 14)))
    banner.highlight:setText((move.name or '') .. '!')
    banner.subtitle:setText(shorten(tr('Technical Machine') .. '   -   ' .. (move.description or ''), 66))
    if move.element and ELEMENTS[move.element] then
        addChip(banner, { icon = '/images/types/' .. move.element, label = tr('Type'), value = tr(ELEMENTS[move.element]), width = 92 })
    end
    if move.category and CATEGORIES[move.category] then
        addChip(banner, { icon = '/images/moveCategories/' .. move.category, label = tr('Category'), value = tr(CATEGORIES[move.category]), width = 92 })
    end
    if move.power and move.power ~= '--' and move.power ~= '0' then
        addChip(banner, { icon = IMAGES .. 'stat-attack', label = tr('Power'), value = move.power, width = 80 })
    end
    if move.energy then
        addChip(banner, { icon = IMAGES .. 'stat-spattack', label = tr('Energy'), value = tostring(move.energy), width = 80 })
    end
    if move.cooldown then
        addChip(banner, { icon = IMAGES .. 'stat-speed', label = tr('Cooldown'), value = tr('%ds', move.cooldown), width = 84 })
    end
    return banner, {}
end

local VOCATION_IMAGES = '/modules/game_vocation/images/'

local function addPerkBox(parent, gain)
    local box = g_ui.createWidget('LevelUpMoveBox', parent)
    local isNew = gain.badge == tr('New')
    box.title:setText(isNew and tr('New perk:') or tr('Better:'))
    box.moveName:setText(gain.text or '')
    box.iconFrame.icon:hide()
    local picture = g_ui.createWidget('UIWidget', box.iconFrame)
    picture:setSize({ width = 24, height = 24 })
    picture:addAnchor(AnchorHorizontalCenter, 'parent', AnchorHorizontalCenter)
    picture:addAnchor(AnchorVerticalCenter, 'parent', AnchorVerticalCenter)
    picture:setImageSource(VOCATION_IMAGES .. 'perk_' .. (gain.icon or 'star'))
    picture:setImageSmooth(true)
    picture:setPhantom(true)
    box.element:hide()
    box.category:hide()
    box.details:addAnchor(AnchorLeft, 'title', AnchorLeft)
    box.details:setMarginLeft(0)
    local details = gain.value or ''
    if not isNew and gain.badge then
        details = details .. '   (' .. gain.badge .. ')'
    end
    box.details:setText(shorten(details, 60))
    return box
end

local function buildRank(parent, data)
    local banner = createBanner(parent)
    local player = g_game.getLocalPlayer()
    if player then
        banner.creature:setOutfit(player:getOutfit())
        banner.creature:show()
    end
    if data.key then
        banner.badge:setImageSource(VOCATION_IMAGES .. 'icon_' .. data.key)
        banner.badge:setImageSmooth(true)
        banner.badge:show()
    end
    banner.name:setText(shorten(data.name or tr('Vocation'), 16))
    banner.highlight:setText(tr('Rank Up!'))
    banner.subtitle:setText(tr('Congratulations! You are now %s', data.title or ''))
    addChip(banner, {
        icon = VOCATION_IMAGES .. 'perk_ranks',
        label = tr('Rank'),
        value = tr('%d of %d', tonumber(data.to) or 0, tonumber(data.maxRank) or 5),
        up = true,
        width = 84
    })
    addChip(banner, {
        icon = VOCATION_IMAGES .. 'perk_title',
        label = tr('Title'),
        value = shorten(data.title, 22),
        color = '#ffd75a',
        width = 160
    })
    local gains = data.gains or {}
    local boxes = {}
    for index = 1, math.min(#gains, MAX_UNLOCK_BOXES) do
        table.insert(boxes, function() return addPerkBox(parent, gains[index]) end)
    end
    return banner, boxes
end

local BUILDERS = { pokemon = buildPokemon, trainer = buildTrainer, tm = buildTm, rank = buildRank }

local function topMargin()
    local root = modules.game_interface.getRootPanel()
    local area = root and root:recursiveGetChildById('environment')
    if area and area:isVisible() then
        return area:getMarginTop() + area:getHeight() + 6
    end
    return TOP_MARGIN
end

local function slideIn(widget, elapsed, base)
    if widget:isDestroyed() then
        return
    end
    local t = math.min(elapsed / FADE_IN_MS, 1)
    widget:setMarginTop(math.floor(base - SLIDE * (1 - t) + 0.5))
    if t < 1 then
        schedule(function() slideIn(widget, elapsed + 30, base) end, 30)
    end
end

local function evolutionShowing()
    local evolution = modules.game_evolution
    return evolution and evolution.isShowing and evolution.isShowing()
end

local showNext

local function display(entries)
    local root = modules.game_interface.getRootPanel()
    stack = g_ui.createWidget('LevelUpStack', root)
    local base = topMargin()
    stack:setMarginTop(base - SLIDE)
    g_effects.fadeIn(stack, FADE_IN_MS)
    slideIn(stack, 0, base)

    local moveBoxes = {}
    for _, data in ipairs(entries) do
        local _, moves = BUILDERS[data.kind](stack, data)
        for _, build in ipairs(moves) do
            table.insert(moveBoxes, build)
        end
    end
    for index, build in ipairs(moveBoxes) do
        schedule(function()
            if stack then
                local box = build()
                g_effects.fadeIn(box, FADE_IN_MS)
            end
        end, FADE_IN_MS + MOVE_DELAY_MS * index)
    end

    local hold = SHOW_MS + PER_MOVE_MS * #moveBoxes + 800 * (#entries - 1)
    schedule(function()
        if not stack then
            return
        end
        g_effects.fadeOut(stack, FADE_OUT_MS)
        schedule(function()
            clearStack()
            schedule(showNext, GAP_MS)
        end, FADE_OUT_MS)
    end, FADE_IN_MS + hold)
end

showNext = function()
    if stack or #queue == 0 then
        return
    end
    if evolutionShowing() then
        schedule(showNext, 500)
        return
    end
    local entries = {}
    while #queue > 0 and #entries < MAX_PER_GROUP do
        table.insert(entries, table.remove(queue, 1))
    end
    display(entries)
end

local lastJingleAt = 0

local function onLevelUp(protocol, opcode, buffer)
    local ok, data = pcall(json.decode, buffer)
    if not ok or type(data) ~= 'table' or not BUILDERS[data.kind] then
        g_logger.warning('LevelUp: invalid message')
        return
    end
    table.insert(queue, data)
    local now = g_clock.millis()
    if modules.game_sounds and now - lastJingleAt > 1000 then
        lastJingleAt = now
        modules.game_sounds.play(data.kind == 'tm' and 'tm_get' or 'level_up')
    end
    -- the exp message and the trainer level-up arrive together: show them in one stack
    schedule(showNext, 100)
end

function isShowing()
    return stack ~= nil
end

function init()
    g_ui.importStyle('levelup')
    ProtocolGame.registerExtendedOpcode(ExtendedIds.LevelUp, onLevelUp)
    connect(g_game, { onGameEnd = reset })
end

function terminate()
    ProtocolGame.unregisterExtendedOpcode(ExtendedIds.LevelUp)
    disconnect(g_game, { onGameEnd = reset })
    reset()
end
