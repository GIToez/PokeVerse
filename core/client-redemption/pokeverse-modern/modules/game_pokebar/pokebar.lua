-- Quick call bar: the legacy game_pokebar in the PokeVerse HUD style.
-- Same server commands (/cp to call, /pd for details); movable, horizontal or vertical.
pokemonBar = nil

local HORIZONTAL = 0
local VERTICAL = 1
local SPACING = 4

local orientation = VERTICAL
local activeSlot

local HEALTH_COLORS = { [0] = '#4cdc8c', [1] = '#e8d24c', [2] = '#e8505a' }

local function slots()
    local list = {}
    for _, child in ipairs(pokemonBar:getChildren()) do
        if child:getStyleName() == 'QuickCallSlot' then
            list[#list + 1] = child
        end
    end
    return list
end

local function applyOrientation()
    local layout
    if orientation == HORIZONTAL then
        layout = UIHorizontalLayout.create(pokemonBar)
    else
        layout = UIVerticalLayout.create(pokemonBar)
    end
    layout:setSpacing(SPACING)
    layout:setFitChildren(true)
    pokemonBar:setLayout(layout)

    local count = math.max(#slots(), 1)
    local slotWidth, slotHeight = 42, 56
    local padding = pokemonBar:getPaddingLeft() + pokemonBar:getPaddingRight()
    if orientation == HORIZONTAL then
        pokemonBar:setSize({ width = padding + count * slotWidth + (count - 1) * SPACING, height = padding + slotHeight })
    else
        pokemonBar:setSize({ width = padding + slotWidth, height = padding + count * slotHeight + (count - 1) * SPACING })
    end
    pokemonBar:bindRectToParent()
end

local function savePosition()
    if pokemonBar.moved then
        g_settings.set('pokeverse-quickcall-pos', pokemonBar:getPosition())
    end
end

local function resetPosition()
    pokemonBar.moved = false
    g_settings.remove('pokeverse-quickcall-pos')
    pokemonBar:breakAnchors()
    pokemonBar:addAnchor(AnchorLeft, 'gameMapPanel', AnchorLeft)
    pokemonBar:addAnchor(AnchorVerticalCenter, 'gameMapPanel', AnchorVerticalCenter)
end

local function switchOrientation()
    orientation = orientation == HORIZONTAL and VERTICAL or HORIZONTAL
    g_settings.set('pokeverse-quickcall-orientation', orientation)
    applyOrientation()
end

local function openMenu(mousePos)
    local menu = g_ui.createWidget('PopupMenu')
    menu:setGameMenu(true)
    menu:addOption(orientation == HORIZONTAL and tr('Show vertically') or tr('Show horizontally'), switchOrientation)
    menu:addOption(tr('Reset position'), resetPosition)
    menu:display(mousePos)
end

local function show()
    pokemonBar:show()
    pokemonBar:raise()
end

local function hide()
    pokemonBar:hide()
end

local function reset()
    for _, slot in ipairs(slots()) do
        slot:destroy()
    end
    activeSlot = nil
    applyOrientation()
end

local function updateSlot(slot, textColor, text)
    -- "USE" only marks the Pokemon that is out; it is not its health
    if text == tr('USE') then
        if activeSlot then
            activeSlot:setOn(false)
        end
        activeSlot = slot
        slot:setOn(true)
        return
    elseif slot == activeSlot then
        slot:setOn(false)
        activeSlot = nil
    end

    slot.health:setColor(HEALTH_COLORS[textColor] or '#ffffff')
    slot.portrait:setOpacity(text == 'FNT' and 0.4 or 1)
    slot.health:setText(text)
end

local function findSlot(number)
    return pokemonBar:getChildById('poke' .. number)
end

function onPokemonBarAdd(itemId, number, textColor, text)
    local slot = g_ui.createWidget('QuickCallSlot', pokemonBar)
    slot:setId('poke' .. number)
    slot.portrait:setItemId(itemId)
    slot:setTooltip(getPokemonNameByIconItemId(itemId) .. '\n' .. tr('Click to call, Shift+click for details'))
    slot:setDraggable(true)
    slot.onDragEnter = function(self, mousePos)
        return pokemonBar:onDragEnter(mousePos)
    end
    slot.onDragMove = function(self, mousePos, mouseMoved)
        pokemonBar:onDragMove(mousePos, mouseMoved)
        return true
    end
    slot.onDragLeave = function(self, droppedWidget, mousePos)
        pokemonBar:onDragLeave(droppedWidget, mousePos)
        return true
    end
    slot.onMousePress = function(self, mousePos, button)
        self.pressPosition = pokemonBar:getPosition()
        return false
    end
    slot.onMouseRelease = function(self, mousePos, button)
        if button == MouseRightButton then
            openMenu(mousePos)
            return true
        end
        local p = self.pressPosition
        local moved = p and (p.x ~= pokemonBar:getX() or p.y ~= pokemonBar:getY())
        if button ~= MouseLeftButton or moved or not self:containsPoint(mousePos) then
            return false
        end
        if g_keyboard.isShiftPressed() then
            g_game.talkChannel(MessageModes.Say, 0, '/pd ' .. number)
        else
            g_game.talkChannel(MessageModes.Say, 0, '/cp ' .. number)
        end
        return true
    end
    updateSlot(slot, textColor, text)
    applyOrientation()
    show()
end

function onPokemonBarRemove(number)
    local slot = findSlot(number)
    if slot then
        if slot == activeSlot then
            activeSlot = nil
        end
        slot:destroy()
    end
    applyOrientation()
end

function onPokemonBarUpdate(number, textColor, text)
    local slot = findSlot(number)
    if slot then
        updateSlot(slot, textColor, text)
    end
end

function onPokemonBarOpen()
    show()
end

function onPokemonBarClose()
    hide()
    reset()
end

function onOnline()
    hide()
    reset()
end

function onOffline()
    hide()
    reset()
end

function onCreatureHealthPercentChange(creature, health)
    if creature:isLocalPlayerSummon() and activeSlot then
        local percent = creature:getHealthPercent()
        local color = percent >= 80 and 0 or (percent >= 40 and 1 or 2)
        activeSlot.health:setColor(HEALTH_COLORS[color])
        activeSlot.health:setText(percent .. '%')
    end
end

function onInit()
    connect(g_game, {
        onGameStart = onOnline,
        onGameEnd = onOffline,
        onPokemonBarAdd = onPokemonBarAdd,
        onPokemonBarRemove = onPokemonBarRemove,
        onPokemonBarUpdate = onPokemonBarUpdate,
        onPokemonBarOpen = onPokemonBarOpen,
        onPokemonBarClose = onPokemonBarClose
    })
    connect(Creature, { onHealthPercentChange = onCreatureHealthPercentChange })

    pokemonBar = g_ui.loadUI('pokebar', modules.game_interface.getRootPanel())
    orientation = g_settings.getNumber('pokeverse-quickcall-orientation', VERTICAL)
    pokemonBar.onDragLeave = function(self)
        self.moved = true
        savePosition()
    end
    pokemonBar.onMouseRelease = function(self, mousePos, button)
        if button == MouseRightButton then
            openMenu(mousePos)
            return true
        end
        return false
    end

    local saved = g_settings.getPoint('pokeverse-quickcall-pos')
    if saved and saved.x > 0 and saved.y > 0 then
        scheduleEvent(function()
            pokemonBar:breakAnchors()
            pokemonBar:setPosition(saved)
            pokemonBar.moved = true
        end, 100)
    end

    applyOrientation()
    pokemonBar:hide()
    if g_game.isOnline() then
        onOnline()
    end
end

function onTerminate()
    disconnect(g_game, {
        onGameStart = onOnline,
        onGameEnd = onOffline,
        onPokemonBarAdd = onPokemonBarAdd,
        onPokemonBarRemove = onPokemonBarRemove,
        onPokemonBarUpdate = onPokemonBarUpdate,
        onPokemonBarOpen = onPokemonBarOpen,
        onPokemonBarClose = onPokemonBarClose
    })
    disconnect(Creature, { onHealthPercentChange = onCreatureHealthPercentChange })
    savePosition()
    pokemonBar:destroy()
end
