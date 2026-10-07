-- Pokemon status conditions (burn, sleep, stat changes...). The server adds an icon with a cooldown
-- (0xFF 0x0E), removes it (0x0F) or clears the bar (0x10, e.g. on recall).
statusBar = nil

local STATUS_BY_ITEMID = {
    [16715] = "Burn",
    [16716] = "Freeze",
    [16717] = "Paralyze",
    [16718] = "Poison",
    [16719] = "Sleep",
    [16720] = "Confusion",
    [16721] = "Low Accuracy",
    [16722] = "Extra Speed",
    [16723] = "Lower Attack",
    [16724] = "Extra Attack",
    [16725] = "Lower Defense",
    [16726] = "Extra Defense",
    [16727] = "Insomnia",
    [16728] = "Reflect",
    [16729] = "Prevent Status",
    [16730] = "Flinch",
    [16731] = "Bad Poison",
    [16732] = "High Critical Chance",
    [16733] = "Recharge",
    [16734] = "Infatuate",
    [16735] = "Store Damage",
    [16736] = "Counter",
    [16737] = "Substitute",
    [16738] = "Charge",
    [11205] = "Health +1",
    [11206] = "Health +2",
    [11207] = "Health +3",
    [11208] = "Health +4",
    [17393] = "Blink",
    [17587] = "Stockpile Charge 1",
    [17588] = "Stockpile Charge 2",
    [17589] = "Stockpile Charge 3",
}

local defaultWidth, defaultHeight = 0, 0

local function layout()
    local last
    local width = statusBar:getPaddingLeft() + statusBar:getPaddingRight()
    for _, icon in ipairs(statusBar:getChildren()) do
        icon:breakAnchors()
        icon:addAnchor(AnchorTop, 'parent', AnchorTop)
        if last then
            icon:addAnchor(AnchorLeft, last:getId(), AnchorRight)
        else
            icon:addAnchor(AnchorLeft, 'parent', AnchorLeft)
        end
        width = width + icon:getWidth() + icon:getMarginLeft()
        last = icon
    end
    if last then
        statusBar:resize(width, defaultHeight)
    else
        statusBar:resize(defaultWidth, defaultHeight)
    end
end

local function removeIcon(icon)
    removeEvent(icon.cooldownEvent)
    icon.cooldownEvent = nil
    icon:destroy()
end

local function updateCooldown(icon)
    icon.cooldownEvent = nil
    local now = g_clock.seconds()
    if now >= icon.timeEnd then
        removeIcon(icon)
        layout()
        return
    end
    local progress = icon:getChildById('progressRect')
    progress:setPercent((now - icon.timeStart) / (icon.timeEnd - icon.timeStart) * 100)
    local left = icon.timeEnd - now
    local label = progress:getChildById('cooldown')
    label:setText(string.format('%.0f', left))
    label:setColor(left > 3.9 and '#ffffff' or '#ff0000')
    icon.cooldownEvent = scheduleEvent(function() updateCooldown(icon) end, 100)
end

function reset()
    for _, icon in ipairs(statusBar:getChildren()) do
        removeIcon(icon)
    end
    layout()
end

function onStatusBarAdd(itemId, cooldown)
    local id = 'status' .. itemId
    local old = statusBar:getChildById(id)
    if old then
        removeIcon(old)
    end
    local icon = g_ui.createWidget('StatusItem', statusBar)
    icon:setId(id)
    icon:setItemId(itemId)
    icon:setTooltip(tr(STATUS_BY_ITEMID[itemId] or tostring(itemId)))
    icon.timeStart = g_clock.seconds()
    icon.timeEnd = icon.timeStart + cooldown
    layout()
    statusBar:show()
    updateCooldown(icon)
end

function onStatusBarRemove(itemId)
    local icon = statusBar:getChildById('status' .. itemId)
    if icon then
        removeIcon(icon)
        layout()
    end
end

function onStatusBarClear()
    reset()
end

function getState()
    local icons = {}
    for _, icon in ipairs(statusBar:getChildren()) do
        icons[#icons + 1] = icon:getItemId() .. '=' .. icon:getChildById('progressRect'):getChildById('cooldown'):getText()
    end
    return { visible = statusBar:isVisible(), icons = icons }
end

local function onGameStart()
    reset()
    statusBar:show()
end

local function onGameEnd()
    reset()
    statusBar:hide()
end

function onInit()
    statusBar = g_ui.loadUI('statusbar', modules.game_interface.getRootPanel())
    defaultWidth, defaultHeight = statusBar:getWidth(), statusBar:getHeight()
    connect(g_game, {
        onGameStart = onGameStart,
        onGameEnd = onGameEnd,
        onStatusBarAdd = onStatusBarAdd,
        onStatusBarRemove = onStatusBarRemove,
        onStatusBarClear = onStatusBarClear })
    if g_game.isOnline() then
        onGameStart()
    else
        statusBar:hide()
    end
end

function onTerminate()
    disconnect(g_game, {
        onGameStart = onGameStart,
        onGameEnd = onGameEnd,
        onStatusBarAdd = onStatusBarAdd,
        onStatusBarRemove = onStatusBarRemove,
        onStatusBarClear = onStatusBarClear })
    reset()
    statusBar:destroy()
    statusBar = nil
end
