-- The layout switch (Options > Interface > Layout). Classic is the side panels as they always were;
-- Pokegear replaces them piece by piece. Other modules ask isActive() and listen with
-- connect(modules.game_pokegear, { onLayoutChange = function(active) end }).
local active = false

function isActive()
    local options = modules.client_options
    return options ~= nil and options.getOption('uiLayout') == 'pokegear'
end

-- Pokegear has no Chat On / Chat Off: WASD always walks, and Enter opens one line (game_console
-- sends you back to walking after it)
local function applyWalkLock()
    local console = modules.game_console
    local toggle = console and console.consoleToggleChat
    if not toggle or g_platform.isMobile() then
        return
    end
    local textEdit = console.consoleTextEdit
    if active then
        if not toggle.isChecked and not (textEdit and textEdit:isVisible() and textEdit:getText() ~= '') then
            console.toggleChat()
        end
        toggle:hide()
        if textEdit then
            textEdit:removeAnchor(AnchorRight)
            textEdit:addAnchor(AnchorRight, 'parent', AnchorRight)
        end
    else
        toggle:show()
        if textEdit then
            textEdit:removeAnchor(AnchorRight)
            textEdit:addAnchor(AnchorRight, 'toggleChat', AnchorLeft)
        end
    end
end

local function apply()
    if g_game.isOnline() then
        applyWalkLock()
    end
end

function refresh()
    local now = isActive()
    if now ~= active then
        active = now
        apply()
        signalcall(onLayoutChange, active)
        return
    end
    apply()
end

local function onGameStart()
    -- after game_console has restored the saved Chat On / Chat Off
    scheduleEvent(apply, 100)
end

function init()
    active = isActive()
    connect(g_game, { onGameStart = onGameStart })
    if g_game.isOnline() then
        onGameStart()
    end
end

function terminate()
    disconnect(g_game, { onGameStart = onGameStart })
    if active then
        active = false
        apply()
    end
end
