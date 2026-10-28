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

-- the top bar buttons for the side windows Pokegear replaces
local REPLACED_BUTTONS = { 'miniMap', 'battleButton', 'skillsButton' }

local function applyTopBar()
    for _, id in ipairs(REPLACED_BUTTONS) do
        local button = Pokegear.topButton(id)
        if button then
            button:setVisible(not active)
        end
    end
end

-- The Skills window goes away in Pokegear: experience and Trainer Spirit are on the HUD (experience.lua)
-- and the trainer skills on the Trainer card. Classic gets it back as it was.
local skillsHidden, skillsWasOpen = false, false

local function skillsWindow()
    local skills = modules.game_skills
    return skills and skills.skillsWindow
end

local function keepSkillsHidden(window)
    if active then
        window:hide()
    end
end

local function applySkills()
    local window = skillsWindow()
    if not window then
        return
    end
    if active and g_game.isOnline() then
        if not skillsHidden then
            skillsHidden = true
            skillsWasOpen = window:isVisible()
            connect(window, { onOpen = keepSkillsHidden })
        end
        window:hide()
    elseif skillsHidden then
        skillsHidden = false
        disconnect(window, { onOpen = keepSkillsHidden })
        if skillsWasOpen and g_game.isOnline() then
            window:show()
        end
    end
end

-- Pokegear hangs the right-hand windows (Inventory, Skills, Friends...) under the ring in the
-- top-right corner, and under the Nearby card while it sits below the ring. Dragging either away
-- lifts the column up to whatever is still in place.
local COLUMN_SPACING = 4 -- GameSidePanel's layout spacing
local COLUMN_GAP = 4
local classicColumnHeight

function Pokegear.fitColumn()
    local column = modules.game_interface.getMainRightPanel()
    if not column or classicColumnHeight == nil then
        return
    end
    local height, count = column:getPaddingTop() + column:getPaddingBottom(), 0
    for _, child in ipairs(column:getChildren()) do
        if child:isVisible() then
            height = height + child:getHeight() + child:getMarginTop() + child:getMarginBottom()
            count = count + 1
        end
    end
    column:setHeight(height + math.max(count - 1, 0) * COLUMN_SPACING)
end

function Pokegear.layoutColumn()
    local column = modules.game_interface.getMainRightPanel()
    if not column then
        return
    end
    local on = active and g_game.isOnline()
    local under = on and (Nearby.docked() or Hub.docked())
    column:removeAnchor(AnchorTop)
    if under then
        column:addAnchor(AnchorTop, under:getId(), AnchorBottom)
        column:setMarginTop(COLUMN_GAP)
    else
        column:addAnchor(AnchorTop, 'parent', AnchorTop)
        column:setMarginTop(0)
    end
    if on then
        if classicColumnHeight == nil then
            classicColumnHeight = column:getHeight()
        end
        Pokegear.fitColumn()
    elseif classicColumnHeight ~= nil then
        column:setHeight(classicColumnHeight)
        classicColumnHeight = nil
    end
end

local function apply()
    if g_game.isOnline() then
        applyWalkLock()
        applyTopBar()
    end
    Hub.apply(active)
    Nearby.apply(active)
    Bag.apply(active)
    Sockets.apply(active)
    Experience.apply(active)
    applySkills()
    Pokegear.layoutColumn()
end

function toggleNearby()
    Nearby.toggle()
end

-- the badge case shows in its own window (game_badgecase), so in Pokegear it gets no container window
local function isBadgeCase(container)
    local badgeCase = modules.game_badgecase
    return active and badgeCase ~= nil and badgeCase.isDexContainer ~= nil and badgeCase.isDexContainer(container)
end

function claimsContainer(container)
    return Bag.claimsContainer(container) or isBadgeCase(container)
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

local function onGameEnd()
    Hub.apply(false)
    Nearby.apply(false)
    Bag.reset()
    Sockets.apply(false)
    Experience.apply(false)
    Pokegear.layoutColumn()
end

function init()
    g_ui.importStyle('hub')
    g_ui.importStyle('nearby')
    Bag.init()
    Sockets.init()
    Experience.init()
    active = isActive()
    connect(g_game, { onGameStart = onGameStart, onGameEnd = onGameEnd })
    if g_game.isOnline() then
        onGameStart()
    end
end

function terminate()
    disconnect(g_game, { onGameStart = onGameStart, onGameEnd = onGameEnd })
    if active then
        active = false
        apply()
    end
    Hub.terminate()
    Nearby.terminate()
    Bag.terminate()
    Sockets.terminate()
    Experience.terminate()
end
