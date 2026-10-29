-- Quick call bar: the legacy game_pokebar in the PokeVerse HUD style.
-- Same server commands (/cp to call, /pd for details); movable, horizontal or vertical.
pokemonBar = nil

local HORIZONTAL = 0
local VERTICAL = 1
local SPACING = 6
local SLOT_SIZE = 46
local RING_STEPS = 20 -- ring-*.png frames (scripts/art/ui_kit.py)

local orientation = VERTICAL
local activeSlot

local HEALTH_RINGS = { [0] = 'health', [1] = 'mid', [2] = 'low' }

local KEYBIND_CATEGORY = 'Pokemon'
local CALL_KEYS = 6

local function callAction(position)
    return 'Call Pokemon ' .. position
end

local function slots()
    local list = {}
    for _, child in ipairs(pokemonBar:getChildren()) do
        if child:getStyleName() == 'QuickCallSlot' then
            list[#list + 1] = child
        end
    end
    return list
end

-- F1 to F6 go by place on the bar, and the bar keeps its order per character: a Pokemon keeps its number
-- (006-fastcall.lua) and its place while its ball moves around, and only a new one goes to the end.
-- "Move up" and "Move down" (right click) rearrange it.
local ORDER_SETTING = 'pokeverse-quickcall-order'
local order -- fast call numbers, top to bottom

local function orderKey()
    local player = g_game.getLocalPlayer()
    return ORDER_SETTING .. '_' .. (player and player:getName() or '')
end

local function loadOrder()
    order = {}
    for number in g_settings.getString(orderKey()):gmatch('%d+') do
        order[#order + 1] = tonumber(number)
    end
end

local function saveOrder()
    local list = {}
    for i, number in ipairs(order) do
        list[i] = tostring(number)
    end
    g_settings.set(orderKey(), table.concat(list, ','))
end

local function placeOf(number)
    for i, n in ipairs(order) do
        if n == number then
            return i
        end
    end
end

-- the bar's slots in the saved order
local function sortSlots()
    local list = slots()
    table.sort(list, function(a, b)
        return (placeOf(a.number) or math.huge) < (placeOf(b.number) or math.huge)
    end)
    local first = 0
    for index, child in ipairs(pokemonBar:getChildren()) do
        if child:getStyleName() == 'QuickCallSlot' then
            first = index
            break
        end
    end
    for i, slot in ipairs(list) do
        pokemonBar:moveChildToIndex(slot, first + i - 1)
    end
end

local function updateKeyLabels()
    if not pokemonBar then
        return
    end
    for position, slot in ipairs(slots()) do
        -- phones and tablets have no F keys: the chip numbers the slot instead
        if g_platform.isMobile() then
            slot.key:setText(tostring(position))
        else
            slot.key:setText(position <= CALL_KEYS and Keybind.getShortLabel(KEYBIND_CATEGORY, callAction(position)) or '')
        end
    end
end

-- calls the Pokemon in that position of the bar (top to bottom, or left to right); the server
-- calls back the one that is out
local function callPosition(position)
    local slot = slots()[position]
    if slot then
        g_game.talkChannel(MessageModes.Say, 0, '/cp ' .. slot.number)
    end
end

local function bindKeys()
    for position = 1, CALL_KEYS do
        Keybind.new(KEYBIND_CATEGORY, callAction(position), 'F' .. position, '')
        Keybind.bind(KEYBIND_CATEGORY, callAction(position), {
            { type = KEY_DOWN, callback = function() callPosition(position) end }
        })
    end
end

local function unbindKeys()
    for position = 1, CALL_KEYS do
        Keybind.delete(KEYBIND_CATEGORY, callAction(position))
    end
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
    local slotWidth, slotHeight = SLOT_SIZE, SLOT_SIZE
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

-- held items (server PokemonHeldItem.onClientMessage): drop one on a Pokemon to give it, Alt+click
-- or the menu to take it back; the icon in the corner shows what it holds
local heldByNumber = {}
local refreshEvent

local function sendHeld(data)
    local protocol = g_game.getProtocolGame()
    if protocol and g_game.isOnline() then
        protocol:sendExtendedJSONOpcode(ExtendedIds.HeldItem, data)
    end
end

local function showHeld(slot)
    local held = heldByNumber[slot.number]
    if held and held.client and held.client > 0 then
        slot.held:setItemId(held.client)
        slot.held:show()
    else
        slot.held:hide()
    end
    local tooltip = slot.baseTooltip
    if held then
        tooltip = tooltip .. '\n\n' .. tr('Holding %s', held.text or held.name) .. '\n' .. tr('Alt+click to take it back')
    end
    slot:setTooltip(tooltip)
end

local function requestHeld()
    removeEvent(refreshEvent)
    refreshEvent = scheduleEvent(function()
        refreshEvent = nil
        sendHeld({ action = 'refresh' })
    end, 300)
end

local function onHeldMessage(protocol, opcode, buffer)
    local ok, data = pcall(json.decode, buffer)
    if not ok or type(data) ~= 'table' or data.type ~= 'bar' then
        return
    end
    heldByNumber = {}
    for _, held in ipairs(data.items or {}) do
        heldByNumber[tonumber(held.number)] = held
    end
    for _, slot in ipairs(slots()) do
        showHeld(slot)
    end
end

local function takeHeld(slot)
    sendHeld({ action = 'take', number = slot.number })
end

local function giveHeld(slot, dragged)
    local item = dragged and dragged.currentDragThing
    if not item or not item.isItem or not item:isItem() then
        return false
    end
    -- the bag's slot widgets know their slot; an item's own position can be out of date
    local pos = dragged.position or item:getPosition()
    if not pos or pos.x ~= 65535 then
        modules.game_textmessage.displayFailureMessage(tr('You must pick up this item first.'))
        return true
    end
    sendHeld({ action = 'give', number = slot.number, item = { x = pos.x, y = pos.y, z = pos.z, id = item:getId() } })
    return true
end

-- swaps the slot with its neighbour on the bar, and their F keys with it
local function moveSlot(slot, step)
    local list = slots()
    for i, other in ipairs(list) do
        if other == slot then
            local neighbour = list[i + step]
            if not neighbour then
                return
            end
            local a, b = placeOf(slot.number), placeOf(neighbour.number)
            if a and b then
                order[a], order[b] = order[b], order[a]
                saveOrder()
                sortSlots()
                updateKeyLabels()
                -- the Bag's belt shows the keys too
                signalcall(g_game.onPokemonBarOrder)
            end
            return
        end
    end
end

local function openMenu(mousePos, slot)
    local menu = g_ui.createWidget('PopupMenu')
    menu:setGameMenu(true)
    if slot and slot == activeSlot then
        menu:addOption(tr('Evolve'), g_game.evolvePokemon)
    end
    if slot then
        if heldByNumber[slot.number] then
            menu:addOption(tr('Take held item'), function() takeHeld(slot) end, '(Alt)')
        end
        local list = slots()
        if list[1] ~= slot then
            menu:addOption(orientation == HORIZONTAL and tr('Move left') or tr('Move up'), function() moveSlot(slot, -1) end)
        end
        if list[#list] ~= slot then
            menu:addOption(orientation == HORIZONTAL and tr('Move right') or tr('Move down'), function() moveSlot(slot, 1) end)
        end
        menu:addSeparator()
    end
    menu:addOption(orientation == HORIZONTAL and tr('Show vertically') or tr('Show horizontally'), switchOrientation)
    menu:addOption(tr('Reset position'), resetPosition)
    menu:display(mousePos)
end

-- the slot of the Pokemon that's out (nil when none is)
function getActiveSlot()
    return activeSlot
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

-- the health ring: the colour the server picked for the text, the share of the circle the percent
local function setRing(slot, color, percent)
    local frame = math.max(0, math.min(RING_STEPS, math.ceil(percent / 100 * RING_STEPS)))
    slot.ring:setImageSource('/images/pokeverse-ui/ring-' .. (HEALTH_RINGS[color] or 'health'))
    slot.ring:setImageClip({ x = frame * SLOT_SIZE, y = 0, width = SLOT_SIZE, height = SLOT_SIZE })
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

    local fainted = text == 'FNT'
    slot.portrait:setOpacity(fainted and 0.4 or 1)
    slot.health:setText(text)
    slot.health:setVisible(fainted)
    setRing(slot, textColor, fainted and 0 or tonumber(tostring(text):match('(%d+)%%')) or 100)
end

-- the summon is out when one of the creatures around is ours; using the ball in the ball slot (the feet slot) calls it back
local function recallPokemon()
    local player = g_game.getLocalPlayer()
    for _, creature in ipairs(getCreaturesAroundPlayer()) do
        if creature:isLocalPlayerSummon() then
            local ball = player:getInventoryItem(InventorySlotFeet)
            if ball then
                g_game.use(ball)
            end
            return
        end
    end
end

local function findSlot(number)
    return pokemonBar:getChildById('poke' .. number)
end

function onPokemonBarAdd(itemId, number, textColor, text)
    -- the same ball linked again (it moved, or evolved): this one replaces it
    local old = findSlot(number)
    if old then
        if old == activeSlot then
            activeSlot = nil
        end
        old:destroy()
    end
    if not order then
        loadOrder()
    end
    if not placeOf(number) then
        -- Pokemon left in the PC keep their place for a while, so they come back to it
        if #order >= 60 then
            local kept = {}
            for _, n in ipairs(order) do
                if findSlot(n) then
                    kept[#kept + 1] = n
                end
            end
            order = kept
        end
        order[#order + 1] = number
        saveOrder()
    end
    local slot = g_ui.createWidget('QuickCallSlot', pokemonBar)
    slot:setId('poke' .. number)
    slot.number = number
    slot.portrait:setItemId(itemId)
    slot.baseTooltip = getPokemonNameByIconItemId(itemId) .. '\n' .. tr('Click to call, Ctrl+click to call back, Shift+click for details') ..
        '\n' .. tr('Drop a held item here to give it to this Pokemon')
    showHeld(slot)
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
    slot.onDrop = function(self, dragged, mousePos)
        return giveHeld(self, dragged)
    end
    slot.onMousePress = function(self, mousePos, button)
        self.pressPosition = pokemonBar:getPosition()
        return false
    end
    slot.onMouseRelease = function(self, mousePos, button)
        if button == MouseRightButton then
            openMenu(mousePos, self)
            return true
        end
        local p = self.pressPosition
        local moved = p and (p.x ~= pokemonBar:getX() or p.y ~= pokemonBar:getY())
        if button ~= MouseLeftButton or moved or not self:containsPoint(mousePos) then
            return false
        end
        if g_keyboard.isAltPressed() then
            if heldByNumber[number] then
                takeHeld(self)
            end
        elseif g_keyboard.isShiftPressed() then
            g_game.talkChannel(MessageModes.Say, 0, '/pd ' .. number)
        elseif g_keyboard.isCtrlPressed() then
            recallPokemon()
        else
            g_game.talkChannel(MessageModes.Say, 0, '/cp ' .. number)
        end
        return true
    end
    updateSlot(slot, textColor, text)
    sortSlots()
    applyOrientation()
    updateKeyLabels()
    show()
    requestHeld()
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
    updateKeyLabels()
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
    heldByNumber = {}
    order = nil
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
        activeSlot.health:setText(percent .. '%')
        setRing(activeSlot, color, percent)
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
    ProtocolGame.registerExtendedOpcode(ExtendedIds.HeldItem, onHeldMessage)

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
        onPokemonBarAdd = onPokemonBarAdd,
        onPokemonBarRemove = onPokemonBarRemove,
        onPokemonBarUpdate = onPokemonBarUpdate,
        onPokemonBarOpen = onPokemonBarOpen,
        onPokemonBarClose = onPokemonBarClose
    })
    disconnect(Creature, { onHealthPercentChange = onCreatureHealthPercentChange })
    ProtocolGame.unregisterExtendedOpcode(ExtendedIds.HeldItem)
    removeEvent(refreshEvent)
    unbindKeys()
    disconnect(Keybind, { onBind = updateKeyLabels })
    savePosition()
    pokemonBar:destroy()
end
