-- Moves bar: the legacy game_pokemoves in the PokeVerse HUD style.
-- Same server commands (m1..m12 to use a move, /sd for its description); movable, horizontal or vertical.
pokemonMovesWindow = nil

local HORIZONTAL = 0
local VERTICAL = 1
local SPACING = 4
local SLOT_SIZE = 40

local orientation = HORIZONTAL

local MOVE_COUNT = 12
local KEYBIND_CATEGORY = 'Pokemon'
local ORDER_ACTION = 'Order'
local DEX_ACTION = 'Use Pokedex on target'
local EVOLVE_ACTION = 'Evolve Pokemon'

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

local function resetPosition()
    pokemonMovesWindow.moved = false
    g_settings.remove('pokeverse-moves-pos')
    pokemonMovesWindow:breakAnchors()
    pokemonMovesWindow:addAnchor(AnchorBottom, 'gameMapPanel', AnchorBottom)
    pokemonMovesWindow:addAnchor(AnchorHorizontalCenter, 'gameMapPanel', AnchorHorizontalCenter)
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
end

local function stopCooldown(slot)
    removeEvent(slot.cooldownEvent)
    slot.cooldownEvent = nil
    slot.cooldown:hide()
    slot.timer:hide()
end

function reset()
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
    slot.cooldown:setPercent((now - timeStart) / (timeEnd - timeStart) * 100)
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

local function useMove(index)
    if g_game.isOnline() and pokemonMovesWindow:getChildById('move' .. index) then
        g_game.talkChannel(MessageModes.Say, 0, 'm' .. index)
    end
end

-- the order icon the server keeps in the head slot; using it starts the crosshair like a click on it
local function useOrder()
    local player = g_game.isOnline() and g_game.getLocalPlayer()
    local item = player and player:getInventoryItem(InventorySlotHead)
    if item then
        modules.game_interface.startUseWith(item)
    end
end

-- the Pokedex the server keeps in the left hand slot, used on the attacked (or followed) creature; without one, the crosshair
local function useDexOnTarget()
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
    Keybind.new(KEYBIND_CATEGORY, ORDER_ACTION, { [CHAT_MODE.ON] = '', [CHAT_MODE.OFF] = 'R' }, '')
    Keybind.bind(KEYBIND_CATEGORY, ORDER_ACTION, { { type = KEY_DOWN, callback = useOrder } })
    Keybind.new(KEYBIND_CATEGORY, DEX_ACTION, { [CHAT_MODE.ON] = '', [CHAT_MODE.OFF] = 'X' }, '')
    Keybind.bind(KEYBIND_CATEGORY, DEX_ACTION, { { type = KEY_DOWN, callback = useDexOnTarget } })
    Keybind.new(KEYBIND_CATEGORY, EVOLVE_ACTION, '', '')
    Keybind.bind(KEYBIND_CATEGORY, EVOLVE_ACTION, { { type = KEY_DOWN, callback = g_game.evolvePokemon } })
end

local function unbindKeys()
    for index = 1, MOVE_COUNT do
        Keybind.delete(KEYBIND_CATEGORY, moveAction(index))
    end
    Keybind.delete(KEYBIND_CATEGORY, ORDER_ACTION)
    Keybind.delete(KEYBIND_CATEGORY, DEX_ACTION)
    Keybind.delete(KEYBIND_CATEGORY, EVOLVE_ACTION)
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

function onPokemonMoves(iconItemId, moves)
    reset()
    for k, v in pairs(moves) do
        local slot = g_ui.createWidget('MoveSlot', pokemonMovesWindow)
        slot:setId('move' .. k)
        slot.icon:setItemId(v)
        slot.key:setText(Keybind.getShortLabel(KEYBIND_CATEGORY, moveAction(k)))
        slot:setTooltip(getMoveNameByIconItemId(v) .. '\n' .. tr('Click to use, Shift+click for details'))
        delegateDrag(slot)
        slot.onMousePress = function(self)
            self.pressPosition = pokemonMovesWindow:getPosition()
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
            if g_keyboard.isShiftPressed() then
                g_game.talkChannel(MessageModes.Say, 0, '/sd ' .. v)
            else
                useMove(k)
            end
            return true
        end
    end
    applyOrientation()
    show()
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
end

function onInit()
    connect(g_game, {
        onGameStart = onOnline,
        onGameEnd = onOffline,
        onPokemonMoveCooldown = onPokemonMoveCooldown,
        onPokemonMoves = onPokemonMoves,
        onPokemonMovesClose = onPokemonMovesClose,
        onPokemonMovesOpen = onPokemonMovesOpen
    })

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
    disconnect(g_game, {
        onGameStart = onOnline,
        onGameEnd = onOffline,
        onPokemonMoveCooldown = onPokemonMoveCooldown,
        onPokemonMoves = onPokemonMoves,
        onPokemonMovesClose = onPokemonMovesClose,
        onPokemonMovesOpen = onPokemonMovesOpen
    })
    for _, slot in ipairs(slots()) do
        stopCooldown(slot)
    end
    unbindKeys()
    disconnect(Keybind, { onBind = updateKeyLabels })
    savePosition()
    pokemonMovesWindow:destroy()
end
