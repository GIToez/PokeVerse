-- PokeVerse move bar. Behaviour reference: client/runtime-data/modules/game_pokemoves (legacy client).
pokemonMovesWindow = nil

local ORIENTATIONS = { HORIZONTAL = 0, VERTICAL = 1 }
local orientation = ORIENTATIONS.HORIZONTAL
local defaultWidth = 0
local defaultHeight = 0
local cooldowns = {}
-- The server rebuilds the bar (a new move list) right after most moves; remember when each move
-- becomes ready so its countdown survives the rebuild.
local readyAt = {}

local function stopCooldown(progressRect)
    local cooldown = cooldowns[progressRect]
    if not cooldown then
        return
    end
    removeEvent(cooldown.event)
    cooldowns[progressRect] = nil
    if not progressRect:isDestroyed() then
        progressRect:destroy()
    end
end

local function updateCooldown(progressRect)
    local cooldown = cooldowns[progressRect]
    if not cooldown or progressRect:isDestroyed() then
        cooldowns[progressRect] = nil
        return
    end
    local now = g_clock.seconds()
    if now > cooldown.timeEnd then
        stopCooldown(progressRect)
        return
    end
    progressRect:setPercent((now - cooldown.timeStart) / (cooldown.timeEnd - cooldown.timeStart) * 100)
    cooldown.label:setText(string.format('%.0f', cooldown.timeEnd - now))
    if cooldown.timeEnd - now > 3.9 then
        cooldown.label:setColor(TextColors.white)
    else
        progressRect:setBackgroundColor('#F3161690')
    end
    cooldown.event = scheduleEvent(function() updateCooldown(progressRect) end, 100)
end

local function moveIcons()
    local icons = {}
    for _, child in pairs(pokemonMovesWindow:getChildren()) do
        if child:getStyleName() == 'MoveItem' then
            table.insert(icons, child)
        end
    end
    return icons
end

local function reallocateIcons()
    local last
    for _, icon in ipairs(moveIcons()) do
        icon:breakAnchors()
        if orientation == ORIENTATIONS.HORIZONTAL then
            if last then
                icon:addAnchor(AnchorLeft, last:getId(), AnchorRight)
            else
                icon:addAnchor(AnchorLeft, 'parent', AnchorLeft)
            end
        else
            if last then
                icon:addAnchor(AnchorTop, last:getId(), AnchorBottom)
            else
                icon:addAnchor(AnchorTop, 'parent', AnchorTop)
            end
        end
        last = icon
    end
end

local function resize()
    local icons = moveIcons()
    if #icons == 0 then
        pokemonMovesWindow:resize(defaultWidth, defaultHeight)
        return
    end
    if orientation == ORIENTATIONS.HORIZONTAL then
        local width = pokemonMovesWindow:getPaddingLeft() + pokemonMovesWindow:getPaddingRight()
        for _, icon in ipairs(icons) do
            width = width + icon:getWidth()
        end
        pokemonMovesWindow:resize(width, defaultHeight)
    else
        local height = pokemonMovesWindow:getPaddingTop() + pokemonMovesWindow:getPaddingBottom()
        for _, icon in ipairs(icons) do
            height = height + icon:getHeight()
        end
        pokemonMovesWindow:resize(defaultWidth, height)
    end
end

local function hide()
    pokemonMovesWindow:hide()
end

local function show()
    pokemonMovesWindow:show()
end

local function reset()
    for progressRect in pairs(cooldowns) do
        stopCooldown(progressRect)
    end
    pokemonMovesWindow:destroyChildren()
    resize()
end

function switchOrientation()
    orientation = orientation == ORIENTATIONS.HORIZONTAL and ORIENTATIONS.VERTICAL or ORIENTATIONS.HORIZONTAL
    resize()
    reallocateIcons()
end

local function showCooldown(icon, timeEnd)
    local progressRect = g_ui.createWidget('ProgressRect', icon)
    progressRect:setId(icon:getId() .. 'cooldown')
    progressRect:fill('parent')
    progressRect:setBackgroundColor('#1637F290')
    progressRect:setPercent(0)

    local label = g_ui.createWidget('CooldownLabel', progressRect)
    label:addAnchor(AnchorHorizontalCenter, 'parent', AnchorHorizontalCenter)
    label:addAnchor(AnchorVerticalCenter, 'parent', AnchorVerticalCenter)

    local now = g_clock.seconds()
    local total = readyAt[icon:getItemId()] and readyAt[icon:getItemId()].total or (timeEnd - now)
    cooldowns[progressRect] = { label = label, timeStart = timeEnd - total, timeEnd = timeEnd }
    updateCooldown(progressRect)
end

function onPokemonMoveCooldown(itemId, cooldown)
    local now = g_clock.seconds()
    if cooldown > 0 then
        readyAt[itemId] = { timeEnd = now + cooldown, total = cooldown }
    else
        readyAt[itemId] = nil
    end
    local icon
    for _, child in ipairs(moveIcons()) do
        if child:getItemId() == itemId then
            icon = child
            break
        end
    end
    if not icon then
        return
    end
    local old = icon:getChildById(icon:getId() .. 'cooldown')
    if old then
        stopCooldown(old)
    end
    if cooldown > 0 then
        showCooldown(icon, now + cooldown)
    end
end

-- moves: move slot -> icon item id. Clicking says "m<slot>" (use the move); Shift+click says "/sd <icon>" (describe it).
function onPokemonMoves(iconItemId, moves)
    hide()
    reset()
    for slot, moveIcon in pairs(moves) do
        local icon = g_ui.createWidget('MoveItem', pokemonMovesWindow)
        icon:setId('move' .. slot)
        icon:setItemId(moveIcon)
        icon:setTooltip(getMoveNameByIconItemId(moveIcon))
        icon.onMouseRelease = function(self, mousePosition, mouseButton)
            if mouseButton == MouseLeftButton and g_keyboard.isShiftPressed() then
                g_game.talkChannel(MessageModes.Say, 0, '/sd ' .. moveIcon)
                return true
            end
            g_game.talkChannel(MessageModes.Say, 0, 'm' .. slot)
            return true
        end
        local ready = readyAt[moveIcon]
        if ready and ready.timeEnd > g_clock.seconds() then
            showCooldown(icon, ready.timeEnd)
        end
    end
    resize()
    reallocateIcons()
    show()
end

function onMoveBarClose()
    hide()
end

function onMoveBarOpen()
    show()
end

local function onOnline()
    hide()
    reset()
    readyAt = {}
end

local function onOffline()
    hide()
    reset()
    readyAt = {}
end

function init()
    connect(g_game, {
        onGameStart = onOnline,
        onGameEnd = onOffline,
        onPokemonMoveCooldown = onPokemonMoveCooldown,
        onPokemonMoves = onPokemonMoves,
        onMoveBarClose = onMoveBarClose,
        onMoveBarOpen = onMoveBarOpen
    })

    pokemonMovesWindow = g_ui.loadUI('pokemoves', modules.game_interface.getRootPanel())
    scheduleEvent(function()
        local p = g_settings.getPoint('pokemonmoves-pos')
        if p and p.x > 0 and p.y > 0 then
            pokemonMovesWindow:breakAnchors()
            pokemonMovesWindow:setPosition(p)
        end
    end, 100)
    orientation = g_settings.getInteger('pokemonmoves-orientation', ORIENTATIONS.HORIZONTAL)
    pokemonMovesWindow:hide()

    pokemonMovesWindow.onMouseRelease = function(self, mousePosition, mouseButton)
        if mouseButton == MouseRightButton then
            local menu = g_ui.createWidget('PopupMenu')
            menu:addOption(tr('Switch Orientation'), switchOrientation)
            menu:display(mousePosition)
            return true
        end
        return false
    end

    defaultWidth = pokemonMovesWindow:getWidth()
    defaultHeight = pokemonMovesWindow:getHeight()

    if g_game.isOnline() then
        onOnline()
    end
end

function terminate()
    disconnect(g_game, {
        onGameStart = onOnline,
        onGameEnd = onOffline,
        onPokemonMoveCooldown = onPokemonMoveCooldown,
        onPokemonMoves = onPokemonMoves,
        onMoveBarClose = onMoveBarClose,
        onMoveBarOpen = onMoveBarOpen
    })

    g_settings.set('pokemonmoves-pos', pokemonMovesWindow:getPosition())
    g_settings.set('pokemonmoves-orientation', orientation)

    reset()
    pokemonMovesWindow:destroy()
    pokemonMovesWindow = nil
end
