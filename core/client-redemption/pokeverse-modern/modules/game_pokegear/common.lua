-- What the Pokegear windows share: key chips, the top bar's buttons and dragging a window around.
Pokegear = {}

-- the key bound now, in the current preset (empty when nothing is bound)
function Pokegear.boundKey(key)
    if not key or not Keybind.getKeybindKeys then
        return ''
    end
    local ok, keys = pcall(Keybind.getKeybindKeys, key[1], key[2], Keybind.chatMode, Keybind.currentPreset)
    if not ok or type(keys) ~= 'table' then
        return ''
    end
    return keys.primary ~= '' and keys.primary or (keys.secondary or '')
end

-- the text, cut short with "..." when it's wider than the label; again whenever the label resizes
function Pokegear.fitText(label, text)
    label.fullText = text
    local function fit()
        local full = label.fullText
        local width = label:getWidth() - label:getPaddingLeft() - label:getPaddingRight()
        label:setText(full)
        if width <= 0 or label:getTextSize().width <= width then
            return
        end
        local cut = #full
        repeat
            cut = cut - 1
            label:setText(full:sub(1, cut):gsub('%s+$', '') .. '...')
        until cut <= 1 or label:getTextSize().width <= width
    end
    label.onGeometryChange = fit
    fit()
end

-- the top bar's own panel: other widgets share some of these ids
function Pokegear.topButton(id)
    local mainPanel = modules.game_mainpanel
    return (mainPanel and mainPanel.getButton and mainPanel.getButton(id))
        or (modules.client_topmenu and modules.client_topmenu.getButton(id))
end

function Pokegear.pressTopButton(id)
    local button = Pokegear.topButton(id)
    if button and button.onMouseRelease then
        local pos = button:getPosition()
        button.onMouseRelease(button, { x = pos.x + 1, y = pos.y + 1 }, MouseLeftButton)
    end
end

local function clampToScreen(window, pos)
    local rect = modules.game_interface.getRootPanel():getRect()
    pos.x = math.max(rect.x - 40, math.min(pos.x, rect.x + rect.width - window:getWidth() + 40))
    pos.y = math.max(rect.y - 20, math.min(pos.y, rect.y + rect.height - window:getHeight() + 40))
    return pos
end

-- The map's width depends on the right column and the column hangs under the ring and Tracking, so
-- those hang from the map's top edge by a margin read from it: an anchor would close a loop that
-- crashes the layout (seen on logout).
local hung = {}
local hangConnected = false

local function mapTop()
    return modules.game_interface.getMapPanel():getY() - modules.game_interface.getRootPanel():getY()
end

local function rehang()
    local top = mapTop()
    for widget in pairs(hung) do
        if widget:isDestroyed() or widget.pokegearHangMargin == nil then
            hung[widget] = nil
        else
            widget:setMarginTop(top + widget.pokegearHangMargin)
        end
    end
end

function Pokegear.hangFromMapTop(widget, margin)
    if not hangConnected then
        connect(modules.game_interface.getMapPanel(), { onGeometryChange = rehang })
        hangConnected = true
    end
    widget.pokegearHangMargin = margin
    hung[widget] = true
    widget:addAnchor(AnchorTop, 'parent', AnchorTop)
    widget:setMarginTop(mapTop() + margin)
end

function Pokegear.unhang(widget)
    widget.pokegearHangMargin = nil
    hung[widget] = nil
end

function Pokegear.terminateHang()
    if hangConnected then
        disconnect(modules.game_interface.getMapPanel(), { onGeometryChange = rehang })
        hangConnected = false
    end
    hung = {}
end

-- whether window is showing in its own spot: never dragged, or put back with a double click
function Pokegear.isDocked(window, setting)
    if not window or not window:isVisible() or window.pokegearDragging then
        return false
    end
    local saved = g_settings.getPoint(setting)
    return not saved or (saved.x == 0 and saved.y == 0)
end

-- Dragging handle moves window; the spot is saved under setting. A double click on the handle, or
-- no saved spot, puts it back with placeDefault().
function Pokegear.makeMovable(window, handle, setting, placeDefault)
    local function restore()
        local saved = g_settings.getPoint(setting)
        Pokegear.unhang(window)
        window:breakAnchors()
        if saved and (saved.x ~= 0 or saved.y ~= 0) then
            window:setPosition(clampToScreen(window, saved))
        else
            placeDefault()
        end
    end
    handle.onDragEnter = function(widget, mousePos)
        local pos = window:getPosition()
        widget.dragOffset = { x = mousePos.x - pos.x, y = mousePos.y - pos.y }
        Pokegear.unhang(window)
        window:breakAnchors()
        window.pokegearDragging = true
        Pokegear.layoutColumn()
        return true
    end
    handle.onDragMove = function(widget, mousePos)
        window:setPosition(clampToScreen(window,
            { x = mousePos.x - widget.dragOffset.x, y = mousePos.y - widget.dragOffset.y }))
        return true
    end
    handle.onDragLeave = function()
        g_settings.set(setting, window:getPosition())
        window.pokegearDragging = nil
        Pokegear.layoutColumn()
        return true
    end
    handle.onDoubleClick = function()
        g_settings.set(setting, { x = 0, y = 0 })
        Pokegear.unhang(window)
        window:breakAnchors()
        placeDefault()
        Pokegear.layoutColumn()
        return true
    end
    return restore
end
