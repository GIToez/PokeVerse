-- Buffs and status effects with their time left (the server's onStatusBarAdd/Remove/Clear), in a bar
-- under the trainer HUD. Drag it anywhere; right click puts it back.
local STATUS_BY_ITEMID = {
    [16715] = "Burn", [16716] = "Freeze", [16717] = "Paralyze", [16718] = "Poison", [16719] = "Sleep",
    [16720] = "Confusion", [16721] = "Low Accuracy", [16722] = "Extra Speed", [16723] = "Lower Attack",
    [16724] = "Extra Attack", [16725] = "Lower Defense", [16726] = "Extra Defense", [16727] = "Insomnia",
    [16728] = "Reflect", [16729] = "Prevent Status", [16730] = "Flinch", [16731] = "Bad Poison",
    [16732] = "High Critical Chance", [16733] = "Recharge", [16734] = "Infatuate", [16735] = "Store Damage",
    [16736] = "Counter", [16737] = "Substitute", [16738] = "Charge",
    [11205] = "Health +1", [11206] = "Health +2", [11207] = "Health +3", [11208] = "Health +4",
    [17393] = "Blink", [17587] = "Stockpile Charge 1", [17588] = "Stockpile Charge 2", [17589] = "Stockpile Charge 3",
}

local POSITION_SETTING = 'pokeverse-buffbar-pos'
local WARN_SECONDS = 4
local TICK_MS = 200

statusBar = nil
local tickEvent = nil

local function timeText(left)
    if left >= 60 then
        return string.format('%d:%02d', math.floor(left / 60), math.floor(left % 60))
    end
    return tostring(math.ceil(left))
end

local function refreshVisible()
    statusBar:setVisible(g_game.isOnline() and statusBar:getChildCount() > 0)
end

local function tick()
    tickEvent = nil
    local now = g_clock.seconds()
    for _, slot in ipairs(statusBar:getChildren()) do
        local left = slot.endsAt - now
        if left <= 0 then
            slot:destroy()
        else
            local inner = slot:getHeight() - 6
            slot.shade:setHeight(math.floor(inner * math.min(1, (now - slot.startsAt) / slot.duration)))
            slot.time:setText(timeText(left))
            slot.time:setColor(left < WARN_SECONDS and '#ff5a5a' or '#ffffff')
        end
    end
    refreshVisible()
    if statusBar:getChildCount() > 0 then
        tickEvent = scheduleEvent(tick, TICK_MS)
    end
end

local function startTicking()
    if not tickEvent then
        tick()
    end
end

local function stopTicking()
    if tickEvent then
        removeEvent(tickEvent)
        tickEvent = nil
    end
end

local function forwardDrag(slot)
    slot:setDraggable(true)
    slot.onDragEnter = function(self, mousePos) return statusBar:onDragEnter(mousePos) end
    slot.onDragMove = function(self, mousePos, moved) return statusBar:onDragMove(mousePos, moved) end
    slot.onDragLeave = function(self, dropped, mousePos) return statusBar:onDragLeave(dropped, mousePos) end
    slot.onMouseRelease = function(self, mousePos, button) return statusBar:onMouseRelease(mousePos, button) end
end

function onStatusBarAdd(itemId, cooldown)
    onStatusBarRemove(itemId)
    local duration = math.max(tonumber(cooldown) or 0, 0.1)
    local slot = g_ui.createWidget('BuffSlot', statusBar)
    slot.item:setItemId(itemId)
    slot:setTooltip(tr(tostring(STATUS_BY_ITEMID[itemId] or 'Effect')))
    slot.startsAt = g_clock.seconds()
    slot.duration = duration
    slot.endsAt = slot.startsAt + duration
    forwardDrag(slot)
    refreshVisible()
    stopTicking()
    startTicking()
end

function onStatusBarRemove(itemId)
    for _, slot in ipairs(statusBar:getChildren()) do
        if slot.item:getItemId() == itemId then
            slot:destroy()
        end
    end
    refreshVisible()
end

function onStatusBarClear()
    stopTicking()
    statusBar:destroyChildren()
    refreshVisible()
end

function hide()
    statusBar:hide()
end

function show()
    refreshVisible()
end

function reset()
    onStatusBarClear()
end

local function resetPosition()
    g_settings.remove(POSITION_SETTING)
    statusBar:breakAnchors()
    statusBar:addAnchor(AnchorTop, 'gameMapPanel', AnchorTop)
    statusBar:addAnchor(AnchorHorizontalCenter, 'gameMapPanel', AnchorHorizontalCenter)
    statusBar:setMarginTop(146)
end

local function onOnline()
    onStatusBarClear()
end

local function onOffline()
    onStatusBarClear()
end

function onInit()
    connect(g_game, {
        onGameStart = onOnline,
        onGameEnd = onOffline,
        onStatusBarAdd = onStatusBarAdd,
        onStatusBarRemove = onStatusBarRemove,
        onStatusBarClear = onStatusBarClear })

    statusBar = g_ui.loadUI('statusbar', modules.game_interface.getRootPanel())
    statusBar:hide()
    statusBar.onDragLeave = function(self)
        self:bindRectToParent()
        g_settings.set(POSITION_SETTING, self:getPosition())
        return true
    end
    statusBar.onMouseRelease = function(self, mousePos, button)
        if button ~= MouseRightButton then
            return false
        end
        local menu = g_ui.createWidget('PopupMenu')
        menu:addOption(tr('Reset position'), resetPosition)
        menu:display(mousePos)
        return true
    end

    local saved = g_settings.getPoint(POSITION_SETTING)
    if saved and saved.x > 0 and saved.y > 0 then
        scheduleEvent(function()
            statusBar:breakAnchors()
            statusBar:setPosition(saved)
            statusBar:bindRectToParent()
        end, 100)
    end

    if g_game.isOnline() then
        onOnline()
    end
end

function onTerminate()
    disconnect(g_game, {
        onGameStart = onOnline,
        onGameEnd = onOffline,
        onStatusBarAdd = onStatusBarAdd,
        onStatusBarRemove = onStatusBarRemove,
        onStatusBarClear = onStatusBarClear })
    stopTicking()
    statusBar:destroy()
end
