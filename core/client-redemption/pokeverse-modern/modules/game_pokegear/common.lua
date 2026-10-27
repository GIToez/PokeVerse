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

-- Dragging handle moves window; the spot is saved under setting. A double click on the handle, or
-- no saved spot, puts it back with placeDefault().
function Pokegear.makeMovable(window, handle, setting, placeDefault)
    local function restore()
        local saved = g_settings.getPoint(setting)
        if saved and (saved.x ~= 0 or saved.y ~= 0) then
            window:breakAnchors()
            window:setPosition(clampToScreen(window, saved))
        else
            window:breakAnchors()
            placeDefault()
        end
    end
    handle.onDragEnter = function(widget, mousePos)
        local pos = window:getPosition()
        widget.dragOffset = { x = mousePos.x - pos.x, y = mousePos.y - pos.y }
        window:breakAnchors()
        return true
    end
    handle.onDragMove = function(widget, mousePos)
        window:setPosition(clampToScreen(window,
            { x = mousePos.x - widget.dragOffset.x, y = mousePos.y - widget.dragOffset.y }))
        return true
    end
    handle.onDragLeave = function()
        g_settings.set(setting, window:getPosition())
        return true
    end
    handle.onDoubleClick = function()
        g_settings.set(setting, { x = 0, y = 0 })
        window:breakAnchors()
        placeDefault()
        return true
    end
    return restore
end
