-- A window bigger than the screen shrinks to it, its lists scroll the rest; one dragged or opened
-- off an edge moves back on. The window keeps its own size again once the screen has room for it.
local CHECK_MS = 250
local MARGIN = 6
local MIN_WIDTH, MIN_HEIGHT = 200, 150
-- the game's own panels and widgets that place themselves
local SKIP_PREFIXES = { 'game', 'pokegear', 'pokeHud', 'topMenu', 'mainPanel' }

local checkEvent

local function skipped(widget)
    local id = widget:getId() or ''
    for _, prefix in ipairs(SKIP_PREFIXES) do
        if id:sub(1, #prefix) == prefix then
            return true
        end
    end
    return widget:isPhantom() or widget:getWidth() < MIN_WIDTH or widget:getHeight() < MIN_HEIGHT
end

local function fit(widget, room)
    local width, height = widget:getWidth(), widget:getHeight()
    local clamped = widget.screenFitClamped
    -- the screen grew back: the window gets its own size again, unless it has resized itself since
    if clamped and clamped.width == width and clamped.height == height then
        local own = widget.screenFitOwn
        local w, h = math.min(own.width, room.width), math.min(own.height, room.height)
        if w ~= width or h ~= height then
            widget:setSize({ width = w, height = h })
            width, height = w, h
        end
        if w == own.width and h == own.height then
            widget.screenFitClamped, widget.screenFitOwn = nil, nil
        else
            widget.screenFitClamped = { width = w, height = h }
        end
    elseif width > room.width or height > room.height then
        widget.screenFitOwn = { width = width, height = height }
        width, height = math.min(width, room.width), math.min(height, room.height)
        widget:setSize({ width = width, height = height })
        widget.screenFitClamped = { width = width, height = height }
        widget:setPosition({ x = room.x + math.floor((room.width - width) / 2),
            y = room.y + math.floor((room.height - height) / 2) })
    end
    local x, y = widget:getX(), widget:getY()
    local nx = math.max(room.x, math.min(x, room.x + room.width - width))
    local ny = math.max(room.y, math.min(y, room.y + room.height - height))
    if nx ~= x or ny ~= y then
        widget:setPosition({ x = nx, y = ny })
    end
end

local function room()
    local root = g_ui.getRootWidget()
    return { x = MARGIN, y = MARGIN, width = root:getWidth() - 2 * MARGIN, height = root:getHeight() - 2 * MARGIN }
end

local function tryFit(widget, space)
    if widget:isVisible() and not skipped(widget) then
        local ok, err = pcall(fit, widget, space)
        if not ok then
            g_logger.warning('screenfit: ' .. tostring(widget:getId()) .. ': ' .. tostring(err))
        end
    end
end

local function check()
    local root = g_ui.getRootWidget()
    local space = room()
    local parents = { root }
    local gameRoot = modules.game_interface and modules.game_interface.getRootPanel()
    if gameRoot then
        parents[#parents + 1] = gameRoot
    end
    for _, parent in ipairs(parents) do
        for _, widget in ipairs(parent:getChildren()) do
            tryFit(widget, space)
        end
    end
end

-- a window takes the focus as it opens: fit it before it is drawn off the screen
local function onChildFocusChange(parent, child)
    if child and child:getParent() == parent then
        tryFit(child, room())
    end
end

function init()
    checkEvent = cycleEvent(check, CHECK_MS)
    connect(rootWidget, { onChildFocusChange = onChildFocusChange })
end

function terminate()
    disconnect(rootWidget, { onChildFocusChange = onChildFocusChange })
    if checkEvent then
        removeEvent(checkEvent)
        checkEvent = nil
    end
end

-- fit now, without waiting for the next check
function fitAll()
    check()
end
