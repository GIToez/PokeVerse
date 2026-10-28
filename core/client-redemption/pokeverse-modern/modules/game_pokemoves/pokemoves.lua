-- Moves bar: the legacy game_pokemoves in the PokeVerse HUD style.
-- Same server commands (m1..m12 to use a move); movable, horizontal or vertical. Each move shows how it
-- does against the attacked Pokemon (an arrow badge), and Shift+click opens its card with the boosted
-- power (ExtendedIds.MoveInfo; the server works the numbers out).
pokemonMovesWindow = nil

local HORIZONTAL = 0
local VERTICAL = 1
local SPACING = 4
local SLOT_SIZE = 40

local orientation = HORIZONTAL
local moveEnergy = {} -- move icon item id -> energy cost (ExtendedIds.MoveEnergy)
local moveElement = {} -- move icon item id -> element (ELEMENTS index), for the slot's type edge
local moveInfo = {} -- move icon item id -> { power, final, multiplier } (ExtendedIds.MoveInfo)
local boostedMoves = {} -- lower-case move name -> true while the Mega ability boosts it (game_pokehud/mega.lua)
local moveCard
local closeCard

local IMAGES = '/modules/game_pokemoves/images/'
local ELEMENTS = { [0] = 'Normal', 'Fight', 'Flying', 'Poison', 'Ground', 'Rock', 'Bug', 'Ghost', 'Steel',
    'Fire', 'Water', 'Grass', 'Electric', 'Psychic', 'Ice', 'Dragon', 'Dark', 'Fairy' }
local CATEGORIES = { [0] = 'Physical', 'Special', 'Status' }
local KIT = '/images/pokeverse-ui/'
local COOLDOWN_FRAMES = 24 -- cooldown.png, 40x40 each

local MOVE_COUNT = 12
local KEYBIND_CATEGORY = 'Pokemon'
local ORDER_ACTION = 'Order'
local DEX_ACTION = 'Use Pokedex on target'
local EVOLVE_ACTION = 'Evolve Pokemon'

-- the server's t1-t4 (turn.lua), in WASD mode only: with the chat on, Shift+arrows select text and Shift+Up/Down browse the chat history
local TURNS = {
    { action = 'Turn Pokemon north', words = 't1', wasd = 'W', arrow = 'Up' },
    { action = 'Turn Pokemon east', words = 't2', wasd = 'D', arrow = 'Right' },
    { action = 'Turn Pokemon south', words = 't3', wasd = 'S', arrow = 'Down' },
    { action = 'Turn Pokemon west', words = 't4', wasd = 'A', arrow = 'Left' },
}

local function moveAction(index)
    return 'Use move ' .. index
end

local MOVE_KEYS = { '1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '-', '=' }

-- The number row: plain with the chat off (WASD), with Ctrl while typing; F1-F6 call Pokemon (game_pokebar).
local function moveKeys(index)
    local key = MOVE_KEYS[index]
    return { [CHAT_MODE.ON] = 'Ctrl+' .. key, [CHAT_MODE.OFF] = key }, ''
end

local function slots()
    local list = {}
    for _, child in ipairs(pokemonMovesWindow:getChildren()) do
        if child:getStyleName() == 'MoveSlot' then
            list[#list + 1] = child
        end
    end
    return list
end

local GLOW_FRAMES, GLOW_SIZE = 24, 48 -- mega-glow.png (scripts/art/mega_hud_art.py)
local glowEvent, glowFrame = nil, 0

local function stopGlow()
    removeEvent(glowEvent)
    glowEvent = nil
end

local function animateGlow()
    glowFrame = (glowFrame + 1) % GLOW_FRAMES
    local any = false
    for _, slot in ipairs(slots()) do
        if slot.megaGlow:isVisible() then
            any = true
            slot.megaGlow:setImageClip({ x = glowFrame * GLOW_SIZE, y = 0, width = GLOW_SIZE, height = GLOW_SIZE })
        end
    end
    if not any then
        stopGlow()
    end
end

local function updateKeyLabels()
    if not pokemonMovesWindow then
        return
    end
    for _, slot in ipairs(slots()) do
        local index = tonumber(slot:getId():match('%d+'))
        if index then
            slot.key:setText(Keybind.getShortLabel(KEYBIND_CATEGORY, moveAction(index)))
        end
    end
end

local function applyOrientation()
    local layout
    if orientation == HORIZONTAL then
        layout = UIHorizontalLayout.create(pokemonMovesWindow)
    else
        layout = UIVerticalLayout.create(pokemonMovesWindow)
    end
    layout:setSpacing(SPACING)
    layout:setFitChildren(true)
    pokemonMovesWindow:setLayout(layout)

    local count = math.max(#slots(), 1)
    local padding = pokemonMovesWindow:getPaddingLeft() + pokemonMovesWindow:getPaddingRight()
    local length = padding + count * SLOT_SIZE + (count - 1) * SPACING
    if orientation == HORIZONTAL then
        pokemonMovesWindow:setSize({ width = length, height = padding + SLOT_SIZE })
    else
        pokemonMovesWindow:setSize({ width = padding + SLOT_SIZE, height = length })
    end
    pokemonMovesWindow:bindRectToParent()
end

local function savePosition()
    if pokemonMovesWindow.moved then
        g_settings.set('pokeverse-moves-pos', pokemonMovesWindow:getPosition())
    end
end

-- just over the chat when it floats on the map (full screen view), else at the bottom of the map
function placeDefault()
    if not pokemonMovesWindow or pokemonMovesWindow.moved then
        return
    end
    local floating = modules.game_interface.isChatFloating and modules.game_interface.isChatFloating()
        and modules.game_interface.getBottomPanel():isVisible()
    local anchor = floating and 'gameBottomPanel' or 'gameMapPanel'
    pokemonMovesWindow:breakAnchors()
    pokemonMovesWindow:addAnchor(AnchorBottom, anchor, floating and AnchorTop or AnchorBottom)
    pokemonMovesWindow:addAnchor(AnchorHorizontalCenter, anchor, AnchorHorizontalCenter)
    pokemonMovesWindow:setMarginBottom(floating and 4 or 44)
end

local function resetPosition()
    pokemonMovesWindow.moved = false
    g_settings.remove('pokeverse-moves-pos')
    placeDefault()
end

function switchOrientation()
    orientation = orientation == HORIZONTAL and VERTICAL or HORIZONTAL
    g_settings.set('pokeverse-moves-orientation', orientation)
    applyOrientation()
end

local function openMenu(mousePos)
    local menu = g_ui.createWidget('PopupMenu')
    menu:setGameMenu(true)
    menu:addOption(orientation == HORIZONTAL and tr('Show vertically') or tr('Show horizontally'), switchOrientation)
    menu:addOption(tr('Reset position'), resetPosition)
    menu:display(mousePos)
end

function show()
    pokemonMovesWindow:show()
    pokemonMovesWindow:raise()
end

function hide()
    pokemonMovesWindow:hide()
    closeCard()
end

local function stopCooldown(slot)
    removeEvent(slot.cooldownEvent)
    slot.cooldownEvent = nil
    slot.cooldown:hide()
    slot.timer:hide()
end

function reset()
    closeCard()
    stopGlow()
    for _, slot in ipairs(slots()) do
        stopCooldown(slot)
        slot:destroy()
    end
    applyOrientation()
end

local function updateCooldown(slot, timeStart, timeEnd)
    local now = g_clock.seconds()
    if now >= timeEnd then
        stopCooldown(slot)
        return
    end
    local frame = math.min(COOLDOWN_FRAMES - 1, math.floor((now - timeStart) / (timeEnd - timeStart) * COOLDOWN_FRAMES))
    slot.cooldown:setImageClip({ x = frame * SLOT_SIZE, y = 0, width = SLOT_SIZE, height = SLOT_SIZE })
    slot.timer:setText(string.format('%.0f', timeEnd - now))
    slot.timer:setColor(timeEnd - now > 3.9 and '#ffffff' or '#e8505a')
    slot.cooldownEvent = scheduleEvent(function()
        updateCooldown(slot, timeStart, timeEnd)
    end, 100)
end

function onPokemonMoveCooldown(itemId, cooldown)
    for _, slot in ipairs(slots()) do
        if slot.icon:getItemId() == itemId then
            stopCooldown(slot)
            slot.cooldown:show()
            slot.timer:show()
            local now = g_clock.seconds()
            updateCooldown(slot, now, now + cooldown)
            return
        end
    end
end

local function send(data)
    local protocol = g_game.getProtocolGame()
    if protocol and g_game.isOnline() then
        protocol:sendExtendedJSONOpcode(ExtendedIds.MoveInfo, data)
    end
end

local function attackedId()
    local target = g_game.getAttackingCreature()
    return target and target:getId() or 0
end

-- wild Pokemon are named "Charmander [30]": the level shows on the name plate already
local function plainName(name)
    return (name or ''):gsub('%s*%[%d+%]$', '')
end

local function formatMultiplier(multiplier)
    return string.format('%g', multiplier)
end

-- the badge and words for a type multiplier (the server caps a double weakness at 2.5x); nil for a plain hit
local function matchupStyle(multiplier)
    if multiplier == nil or multiplier == 1 then
        return nil
    elseif multiplier == 0 then
        return 'matchup_immune', tr('No effect'), '#c4cad4'
    elseif multiplier >= 2.5 then
        return 'matchup_double_strong', tr('Double weakness'), '#8ef09a'
    elseif multiplier > 1 then
        return 'matchup_strong', tr('Super effective'), '#8ef09a'
    elseif multiplier <= 0.25 then
        return 'matchup_double_weak', tr('Double resistance'), '#ff8a8a'
    end
    return 'matchup_weak', tr('Not very effective'), '#ff8a8a'
end

-- moves the Pokemon has too little energy for are dimmed, with their cost in red; the badge shows the
-- matchup against the attacked Pokemon
local function updateEnergy()
    if not pokemonMovesWindow then
        return
    end
    local player = g_game.getLocalPlayer()
    local energy = player and player:getMana() or 0
    local target = g_game.getAttackingCreature()
    local anyBoosted = false
    for _, slot in ipairs(slots()) do
        local cost = moveEnergy[slot.icon:getItemId()]
        local element = ELEMENTS[moveElement[slot.icon:getItemId()]]
        slot:setImageSource(KIT .. 'move-' .. (element and (element == 'Fight' and 'fighting' or element:lower()) or 'empty'))
        local info = moveInfo[slot.icon:getItemId()] or {}
        local short = cost ~= nil and cost > energy
        slot.energy:setVisible(cost ~= nil and cost > 0)
        slot.energy:setText(cost or '')
        slot.energy:setOn(short)
        slot.icon:setOpacity(short and 0.35 or 1)

        local badge, words = matchupStyle(info.multiplier)
        slot.matchup:setVisible(badge ~= nil)
        if badge then
            slot.matchup:setImageSource(IMAGES .. badge)
        end

        local weather = info.weather
        slot.weather:setVisible(weather ~= nil)
        if weather then
            slot.weather:setOn(weather.value < 1)
            slot.weather.icon:setImageSource('/modules/game_weather/images/weather_' .. weather.kind .. '_small')
        end

        local boosted = slot.moveName ~= nil and boostedMoves[slot.moveName:lower()] == true
        slot.megaGlow:setVisible(boosted)

        local lines = { slot.moveName }
        if boosted then
            lines[#lines + 1] = tr('Boosted by the Mega Evolution')
        end
        if info.power then
            if info.final and info.final ~= info.power then
                lines[#lines + 1] = tr('Power: %d (%d with boosts)', info.power, info.final)
            else
                lines[#lines + 1] = tr('Power: %d', info.power)
            end
        end
        if cost and cost > 0 then
            lines[#lines + 1] = short and tr('Energy: %d (you have %d)', cost, energy) or tr('Energy: %d', cost)
        end
        if words and target then
            lines[#lines + 1] = tr('%s vs %s (x%s)', words, plainName(target:getName()), formatMultiplier(info.multiplier))
        end
        if weather then
            local percent = math.floor((weather.value - 1) * 100 + 0.5)
            lines[#lines + 1] = weather.value > 1 and tr('%s: %d%% stronger', weather.name, percent)
                or tr('%s: %d%% weaker', weather.name, -percent)
        end
        lines[#lines + 1] = tr('Click to use, Shift+click for the move card')
        slot:setTooltip(table.concat(lines, '\n'))
        anyBoosted = anyBoosted or boosted
    end
    if anyBoosted and not glowEvent then
        glowEvent = cycleEvent(animateGlow, 50)
    end
end

local function requestMoveInfo()
    if not pokemonMovesWindow or not g_game.isOnline() then
        return
    end
    local icons = {}
    for _, slot in ipairs(slots()) do
        icons[#icons + 1] = slot.icon:getItemId()
    end
    if #icons > 0 then
        send({ action = 'matchup', target = attackedId(), icons = icons })
    end
end

-- the Mega Evolution's ability boosts these moves (game_pokehud/mega.lua): they glow green
function setBoostedMoves(moves)
    boostedMoves = {}
    for _, name in ipairs(moves or {}) do
        boostedMoves[tostring(name):lower()] = true
    end
    updateEnergy()
end

-- the weather changed (game_weather): the boosts with it
function refreshMatchup()
    requestMoveInfo()
end

function closeCard()
    if moveCard then
        moveCard:destroy()
        moveCard = nil
    end
end

local function requestCard(icon)
    if moveCard and moveCard.moveIcon == icon then
        closeCard()
        return
    end
    send({ action = 'card', icon = icon, target = attackedId() })
end

-- anchored over the moves bar (beside it when it is vertical), so it follows the bar and its own height;
-- below or on the other side when there is no room
local function placeCard()
    if not moveCard then
        return
    end
    local bar = pokemonMovesWindow
    local root = modules.game_interface.getRootPanel()
    local id = bar:getId()
    moveCard:breakAnchors()
    if orientation == HORIZONTAL then
        moveCard:addAnchor(AnchorHorizontalCenter, id, AnchorHorizontalCenter)
        if bar:getY() - root:getY() > moveCard:getHeight() + 12 then
            moveCard:addAnchor(AnchorBottom, id, AnchorTop)
            moveCard:setMarginBottom(6)
        else
            moveCard:addAnchor(AnchorTop, id, AnchorBottom)
            moveCard:setMarginTop(6)
        end
    else
        moveCard:addAnchor(AnchorVerticalCenter, id, AnchorVerticalCenter)
        if root:getX() + root:getWidth() - (bar:getX() + bar:getWidth()) > moveCard:getWidth() + 12 then
            moveCard:addAnchor(AnchorLeft, id, AnchorRight)
            moveCard:setMarginLeft(6)
        else
            moveCard:addAnchor(AnchorRight, id, AnchorLeft)
            moveCard:setMarginRight(6)
        end
    end
end

local function showCard(data)
    closeCard()
    if not pokemonMovesWindow or not pokemonMovesWindow:isVisible() then
        return
    end
    moveCard = g_ui.createWidget('MoveCard', modules.game_interface.getRootPanel())
    moveCard.moveIcon = tonumber(data.icon)

    local header = moveCard.header
    header.iconFrame.icon:setItemId(tonumber(data.icon) or 0)
    header.name:setText(data.name or '')
    header.close.onClick = closeCard
    local element, category = tonumber(data.element), tonumber(data.category)
    if element and ELEMENTS[element] then
        header.element:setImageSource('/images/types/' .. element)
        header.element:setTooltip(tr(ELEMENTS[element]))
    else
        header.element:hide()
    end
    if category and CATEGORIES[category] then
        header.category:setImageSource('/images/moveCategories/' .. category)
        header.category:setTooltip(tr(CATEGORIES[category]))
    else
        header.category:hide()
    end

    local parts = {}
    if data.power and data.power ~= '--' and data.power ~= '0' then
        parts[#parts + 1] = tr('Power %s', data.power)
    end
    if data.energy then
        parts[#parts + 1] = tr('Energy %d', data.energy)
    end
    if data.cooldown then
        parts[#parts + 1] = tr('Cooldown %ds', data.cooldown)
    end
    if data.range then
        parts[#parts + 1] = tr('Range %d', data.range)
    end
    moveCard.details:setText(table.concat(parts, '  '))
    moveCard.description:setText(data.description or '')
    moveCard.description:setVisible((data.description or '') ~= '')

    local boosts = data.boosts or {}
    for _, boost in ipairs(boosts) do
        local row = g_ui.createWidget('MoveCardBoost', moveCard.boosts)
        row.label:setText(boost.label or '')
        row.value:setText(tr('x%s', formatMultiplier(tonumber(boost.value) or 1)))
    end
    moveCard.boosts:setVisible(#boosts > 0)
    moveCard.final:setVisible(data.final ~= nil and #boosts > 0)
    if data.final then
        moveCard.final:setText(tr('Power with boosts: %d', data.final))
    end

    local matchup = data.target
    moveCard.matchupRow:setVisible(matchup ~= nil)
    if matchup then
        local multiplier = tonumber(matchup.multiplier) or 1
        local badge, words, color = matchupStyle(multiplier)
        moveCard.matchupRow.badge:setVisible(badge ~= nil)
        if badge then
            moveCard.matchupRow.badge:setImageSource(IMAGES .. badge)
        end
        moveCard.matchupRow.text:setText(tr('%s vs %s (x%s)', words or tr('Normal damage'), plainName(matchup.name),
            formatMultiplier(multiplier)))
        moveCard.matchupRow.text:setColor(color or '#d8e4e4')
    end
    moveCard.estimate:setVisible(data.estimate ~= nil)
    if data.estimate then
        moveCard.estimate:setText(tr('About %d damage a hit (more on a critical hit)', data.estimate))
    end
    moveCard.separator:setVisible(#boosts > 0 or matchup ~= nil)

    moveCard:getLayout():update()
    placeCard()
end

local function onMoveInfo(protocol, opcode, buffer)
    local ok, data = pcall(json.decode, buffer)
    if not ok or type(data) ~= 'table' then
        return
    end
    if data.type == 'matchup' then
        local fresh = tonumber(data.target) == attackedId()
        moveInfo = {}
        for _, move in ipairs(data.moves or {}) do
            moveInfo[tonumber(move.icon)] = {
                power = tonumber(move.power),
                final = tonumber(move.final),
                multiplier = fresh and tonumber(move.multiplier) or nil,
                weather = type(move.weather) == 'table' and tonumber(move.weather.value) and {
                    kind = tostring(move.weather.kind), name = tostring(move.weather.name or ''),
                    value = tonumber(move.weather.value) } or nil
            }
        end
        updateEnergy()
    elseif data.type == 'card' then
        showCard(data)
    end
end

local function onAttackingCreatureChange()
    for _, info in pairs(moveInfo) do
        info.multiplier = nil
    end
    updateEnergy()
    requestMoveInfo()
    if moveCard then
        local icon = moveCard.moveIcon
        send({ action = 'card', icon = icon, target = attackedId() })
    end
end

local function onMoveEnergy(protocol, opcode, buffer)
    local ok, costs = pcall(json.decode, buffer)
    if not ok or type(costs) ~= 'table' then
        return
    end
    moveEnergy, moveElement = {}, {}
    for _, move in ipairs(costs) do
        moveEnergy[tonumber(move.icon)] = tonumber(move.energy)
        moveElement[tonumber(move.icon)] = tonumber(move.element)
    end
    updateEnergy()
end

local function onManaChange()
    updateEnergy()
end

local function useMove(index)
    if g_game.isOnline() and pokemonMovesWindow:getChildById('move' .. index) then
        g_game.talkChannel(MessageModes.Say, 0, 'm' .. index)
    end
end

-- the order icon the server keeps in the head slot; using it starts the crosshair like a click on it
function useOrder()
    local player = g_game.isOnline() and g_game.getLocalPlayer()
    local item = player and player:getInventoryItem(InventorySlotHead)
    if item then
        modules.game_interface.startUseWith(item)
    end
end

-- the Pokedex the server keeps in the left hand slot, used on the attacked (or followed) creature; without one, the crosshair
function useDexOnTarget()
    local player = g_game.isOnline() and g_game.getLocalPlayer()
    local item = player and player:getInventoryItem(InventorySlotLeft)
    if not item then
        return
    end
    local target = g_game.getAttackingCreature() or g_game.getFollowingCreature()
    if target then
        g_game.useWith(item, target)
    else
        modules.game_interface.startUseWith(item)
    end
end

local function bindKeys()
    for index = 1, MOVE_COUNT do
        local primary, secondary = moveKeys(index)
        Keybind.new(KEYBIND_CATEGORY, moveAction(index), primary, secondary)
        Keybind.bind(KEYBIND_CATEGORY, moveAction(index), {
            { type = KEY_DOWN, callback = function() useMove(index) end }
        })
    end
    Keybind.new(KEYBIND_CATEGORY, ORDER_ACTION, { [CHAT_MODE.ON] = '', [CHAT_MODE.OFF] = 'E' }, '')
    Keybind.bind(KEYBIND_CATEGORY, ORDER_ACTION, { { type = KEY_DOWN, callback = useOrder } })
    Keybind.new(KEYBIND_CATEGORY, DEX_ACTION, { [CHAT_MODE.ON] = '', [CHAT_MODE.OFF] = 'X' }, '')
    Keybind.bind(KEYBIND_CATEGORY, DEX_ACTION, { { type = KEY_DOWN, callback = useDexOnTarget } })
    Keybind.new(KEYBIND_CATEGORY, EVOLVE_ACTION, '', '')
    Keybind.bind(KEYBIND_CATEGORY, EVOLVE_ACTION, { { type = KEY_DOWN, callback = g_game.evolvePokemon } })
    for _, turn in ipairs(TURNS) do
        Keybind.new(KEYBIND_CATEGORY, turn.action,
            { [CHAT_MODE.ON] = '', [CHAT_MODE.OFF] = 'Shift+' .. turn.wasd },
            { [CHAT_MODE.ON] = '', [CHAT_MODE.OFF] = 'Shift+' .. turn.arrow })
        Keybind.bind(KEYBIND_CATEGORY, turn.action, { { type = KEY_DOWN, callback = function()
            if g_game.isOnline() then
                g_game.talkChannel(MessageModes.Say, 0, turn.words)
            end
        end } })
    end
end

local function unbindKeys()
    for index = 1, MOVE_COUNT do
        Keybind.delete(KEYBIND_CATEGORY, moveAction(index))
    end
    Keybind.delete(KEYBIND_CATEGORY, ORDER_ACTION)
    Keybind.delete(KEYBIND_CATEGORY, DEX_ACTION)
    Keybind.delete(KEYBIND_CATEGORY, EVOLVE_ACTION)
    for _, turn in ipairs(TURNS) do
        Keybind.delete(KEYBIND_CATEGORY, turn.action)
    end
end

local function delegateDrag(slot)
    slot:setDraggable(true)
    slot.onDragEnter = function(self, mousePos)
        return pokemonMovesWindow:onDragEnter(mousePos)
    end
    slot.onDragMove = function(self, mousePos, mouseMoved)
        pokemonMovesWindow:onDragMove(mousePos, mouseMoved)
        return true
    end
    slot.onDragLeave = function(self, droppedWidget, mousePos)
        pokemonMovesWindow:onDragLeave(droppedWidget, mousePos)
        return true
    end
end

local HOLD_FOR_INFO_MS = 500

function onPokemonMoves(iconItemId, moves)
    reset()
    for k, v in pairs(moves) do
        local slot = g_ui.createWidget('MoveSlot', pokemonMovesWindow)
        slot:setId('move' .. k)
        slot.icon:setItemId(v)
        slot.key:setText(Keybind.getShortLabel(KEYBIND_CATEGORY, moveAction(k)))
        slot.moveName = getMoveNameByIconItemId(v)
        delegateDrag(slot)
        slot.onMousePress = function(self)
            self.pressPosition = pokemonMovesWindow:getPosition()
            self.pressTime = g_clock.millis()
            return false
        end
        slot.onMouseRelease = function(self, mousePos, button)
            if button == MouseRightButton then
                openMenu(mousePos)
                return true
            end
            local p = self.pressPosition
            local moved = p and (p.x ~= pokemonMovesWindow:getX() or p.y ~= pokemonMovesWindow:getY())
            if button ~= MouseLeftButton or moved or not self:containsPoint(mousePos) then
                return false
            end
            -- on mobile holding a slot shows its tooltip (corelib tooltip.lua); letting go does not use it
            if g_platform.isMobile() and self.pressTime and g_clock.millis() - self.pressTime >= HOLD_FOR_INFO_MS then
                return true
            end
            if g_keyboard.isShiftPressed() then
                requestCard(v)
            else
                useMove(k)
            end
            return true
        end
    end
    updateEnergy()
    applyOrientation()
    show()
    requestMoveInfo()
end

function onPokemonMovesClose()
    hide()
end

function onPokemonMovesOpen()
    show()
end

function onOnline()
    hide()
    reset()
end

function onOffline()
    hide()
    reset()
    moveEnergy = {}
    moveInfo = {}
    boostedMoves = {}
end

function onInit()
    connect(g_game, {
        onGameStart = onOnline,
        onGameEnd = onOffline,
        onPokemonMoveCooldown = onPokemonMoveCooldown,
        onPokemonMoves = onPokemonMoves,
        onPokemonMovesClose = onPokemonMovesClose,
        onPokemonMovesOpen = onPokemonMovesOpen,
        onAttackingCreatureChange = onAttackingCreatureChange
    })

    connect(LocalPlayer, { onManaChange = onManaChange })
    ProtocolGame.registerExtendedOpcode(ExtendedIds.MoveEnergy, onMoveEnergy)
    ProtocolGame.registerExtendedOpcode(ExtendedIds.MoveInfo, onMoveInfo)

    pokemonMovesWindow = g_ui.loadUI('pokemoves', modules.game_interface.getRootPanel())
    orientation = g_settings.getNumber('pokeverse-moves-orientation', HORIZONTAL)
    pokemonMovesWindow.onDragLeave = function(self)
        self.moved = true
        savePosition()
    end
    pokemonMovesWindow.onMouseRelease = function(self, mousePos, button)
        if button == MouseRightButton then
            openMenu(mousePos)
            return true
        end
        return false
    end

    local saved = g_settings.getPoint('pokeverse-moves-pos')
    if saved and saved.x > 0 and saved.y > 0 then
        scheduleEvent(function()
            pokemonMovesWindow:breakAnchors()
            pokemonMovesWindow:setPosition(saved)
            pokemonMovesWindow.moved = true
        end, 100)
    else
        placeDefault()
    end

    applyOrientation()
    pokemonMovesWindow:hide()
    connect(Keybind, { onBind = updateKeyLabels })
    bindKeys()
    if g_game.isOnline() then
        onOnline()
    end
end

function onTerminate()
    stopGlow()
    disconnect(g_game, {
        onGameStart = onOnline,
        onGameEnd = onOffline,
        onPokemonMoveCooldown = onPokemonMoveCooldown,
        onPokemonMoves = onPokemonMoves,
        onPokemonMovesClose = onPokemonMovesClose,
        onPokemonMovesOpen = onPokemonMovesOpen,
        onAttackingCreatureChange = onAttackingCreatureChange
    })
    disconnect(LocalPlayer, { onManaChange = onManaChange })
    ProtocolGame.unregisterExtendedOpcode(ExtendedIds.MoveEnergy)
    ProtocolGame.unregisterExtendedOpcode(ExtendedIds.MoveInfo)
    closeCard()
    for _, slot in ipairs(slots()) do
        stopCooldown(slot)
    end
    unbindKeys()
    disconnect(Keybind, { onBind = updateKeyLabels })
    savePosition()
    pokemonMovesWindow:destroy()
end
